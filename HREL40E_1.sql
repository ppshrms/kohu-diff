--------------------------------------------------------
--  DDL for Package Body HREL40E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL40E" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    p_codcatexm         := hcm_util.get_string_t(json_obj,'p_codcatexm');
    p_codexam           := hcm_util.get_string_t(json_obj,'p_codexam');
    p_remark            := hcm_util.get_string_t(json_obj,'p_remark');
    p_syncond           := hcm_util.get_json_t(json_obj,'p_syncond');
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_index');

    -- save index
    json_params         := hcm_util.get_json_t(json_obj, 'param_json');
    params_syncond      := hcm_util.get_json_t(json_obj,'p_syncond');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  procedure gen_index(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;

    v_row               number := 0;
    v_count             number := 0;
    v_codexam           ttestchk.codexam%type;
    v_codpos            ttestchk.codposc%type;
    v_codcomp           ttestchk.codcomp%type;
    v_codempid          ttestchk.codempidc%type;
    v_staemp            temploy1.staemp%type;
    v_flggrade          varchar2(2 char);
    v_table             varchar2(100 char);
    v_ttestset          ttestset%rowtype;
    v_dte_tempst        date;
    v_dte_tempend       date;

    cursor c1 is
        select *
          from ttestset
         where codcomp like p_codcomp||'%'
           and codcatexm = nvl(p_codcatexm, codcatexm)
           and codexam = nvl(p_codexam, codexam)
           and ( (p_dtestrt is null and p_dteend is null) or (
               ((v_dte_tempst between to_date(to_char(dtetestst,'dd/mm/yyyy'), 'dd/mm/yyyy')and to_date(to_char(dtetesten,'dd/mm/yyyy'), 'dd/mm/yyyy')
                 or
                 v_dte_tempend between to_date(to_char(dtetestst,'dd/mm/yyyy'), 'dd/mm/yyyy') and to_date(to_char(dtetesten,'dd/mm/yyyy'), 'dd/mm/yyyy')
                 or
                 to_date(to_char(dtetestst,'dd/mm/yyyy'), 'dd/mm/yyyy') between v_dte_tempst and v_dte_tempend
                 or
                 to_date(to_char(dtetesten,'dd/mm/yyyy'), 'dd/mm/yyyy') between v_dte_tempst and v_dte_tempend)
                 and (p_dtestrt is not null and p_dteend is not null)
                 )))
      order by codcomp,codcatexm,codexam,dtetestst;
  begin
    v_dte_tempst    := to_date(to_char(p_dtestrt,'dd/mm/yyyy'), 'dd/mm/yyyy');
    v_dte_tempend   := to_date(to_char(p_dteend,'dd/mm/yyyy'), 'dd/mm/yyyy');
    obj_row         := json_object_t();
    for r1 in c1 loop
      v_row := v_row + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
      obj_data.put('codcatexm', r1.codcatexm);
      if r1.codcatexm <> '%' then
        obj_data.put('desc_codcatexm', get_tcodec_name('TCODCATEXM', r1.codcatexm, global_v_lang));
      else
        obj_data.put('desc_codcatexm', '');
      end if;
      obj_data.put('codexam', r1.codexam);
      if r1.codexam <> '%' then
        --<< #4598 || 11/05/2022
        --obj_data.put('namexame', get_tcodec_name('TCODEXAM', r1.codexam, global_v_lang));
        obj_data.put('namexame', get_tvtest_name(r1.codexam,global_v_lang));
        -->> #4598 || 11/05/2022
      else
        obj_data.put('namexame', '');
      end if;
      obj_data.put('qtyexam', '');
      if r1.dtetestst < trunc(sysdate) then
        obj_data.put('flgDisabled', 'Y');
      else
        obj_data.put('flgDisabled', 'N');
      end if;
      obj_data.put('datest', to_char(r1.dtetestst,'dd/mm/yyyy'));
      obj_data.put('dateen', to_char(r1.dtetesten,'dd/mm/yyyy'));

      obj_row.put(to_char(v_row - 1), obj_data);
    end loop;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
     --
  procedure check_index is
    v_count_comp  number := 0;
    v_chkExist    number := 0;
    v_secur  boolean := false;
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
      return;
    else
      begin
        select count(*) into v_count_comp
          from tcenter
         where codcomp like p_codcomp || '%' ;
      exception when others then null;
      end;
      if v_count_comp < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
      end if;
      v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_codcatexm is not null then
      begin
        select count(*) into v_chkExist
          from tcodcatexm
         where codcodec = p_codcatexm;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATEXM');
        return;
      end if;
    end if;
    /*
    if p_codexam is not null then
      begin
        select count(*) into v_chkExist
          from tcodexam
         where codcodec = p_codexam;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEXAM');
        return;
      end if;
    end if;
    */
    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end;

  procedure get_index (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail(json_str_output out clob) is
    obj_data            json_object_t;
    obj_data_child      json_object_t;
    obj_row             json_object_t;
    obj_row_child       json_object_t;

    v_row               number := 0;
    v_row_child         number := 0;
    v_count             number := 0;
    v_codexam           ttestset.codexam%type;
    v_codpos            temploy1.codpos%type;
    v_codcomp           temploy1.codcomp%type;
    v_codempid          ttestsetd.codempid%type;
    v_staemp            temploy1.staemp%type;
    v_numlvl            temploy1.numlvl%type;
    v_flggrade          varchar2(2 char);
    v_table             varchar2(100 char);
    v_ttestset          ttestset%rowtype;

    cursor c1 is
      select codempid
        from ttestsetd
       where codcomp = p_codcomp
         and dtetestst = p_dtestrt
         and dtetesten = p_dteend
         and codcatexm = nvl(p_codcatexm,codcatexm)
         and codexam = nvl(p_codexam,codexam);
  begin
    obj_data := json_object_t();

--    if p_codcatexm is null then
--        p_codcatexm := '%';
--    end if;
--    if p_codexam is null then
--        p_codexam := '%';
--    end if;

    begin
      select *
        into v_ttestset
        from ttestset
       where codcomp = p_codcomp
         and dtetestst = p_dtestrt
         and dtetesten = p_dteend
         and codcatexm = nvl(p_codcatexm,codcatexm)
         and codexam = nvl(p_codexam,codexam);
    exception when no_data_found then
      v_ttestset := null;
    end;

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('code', v_ttestset.syncond);
    obj_data.put('statement', nvl(v_ttestset.statement,'[]'));
    obj_data.put('description', get_logical_desc(v_ttestset.statement));
    obj_data.put('remark', v_ttestset.remark);
    if v_ttestset.dtetestst < trunc(sysdate) then
      obj_data.put('flgDisabled', 'Y');
    else
      obj_data.put('flgDisabled', 'N');
    end if;
    --
    obj_row    := json_object_t();
    for r1 in c1 loop
      begin
        select codcomp,codpos,numlvl
          into v_codcomp, v_codpos, v_numlvl
          from temploy1
         where codempid = r1.codempid;
      exception when no_data_found then
        v_codcomp := '';
        v_codpos := '';
      end;
      v_row := v_row + 1;
      obj_data_child    := json_object_t();
      obj_data_child.put('coderror', '200');
      obj_data_child.put('codempid', r1.codempid);
      obj_data_child.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
      obj_data_child.put('codcomp', v_codcomp);
      obj_data_child.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
      obj_data_child.put('codpos', v_codpos);
      obj_data_child.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
      obj_data_child.put('numlvl', v_numlvl);
      obj_row.put(to_char(v_row - 1), obj_data_child);
    end loop;
    obj_data.put('table',obj_row);
    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
     --
  procedure check_detail is
    v_count_comp  number := 0;
    v_chkExist    number := 0;
    v_secur  boolean := false;
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
      return;
    else
      begin
        select count(*) into v_count_comp
          from tcenter
         where codcomp like p_codcomp || '%' ;
      exception when others then null;
      end;
      if v_count_comp < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
      end if;
      v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_codcatexm is not null and p_codcatexm != '%' then
      begin
        select count(*) into v_chkExist
          from tcodcatexm
         where codcodec = p_codcatexm;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATEXM');
        return;
      end if;
    end if;
    /*
    if p_codexam is not null then
      begin
        select count(*) into v_chkExist
          from tcodexam
         where codcodec = p_codexam;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEXAM');
        return;
      end if;
    end if;
    */
    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end;

  procedure get_detail (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure process_data(json_str_input in clob,json_str_output out clob) as
    obj_result      json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;

    v_response      varchar2(1000 char);
    v_flg           varchar2(100 char);
    v_row           number := 0;
    v_syncond       ttestset.syncond%type;
    v_statement     ttestset.statement%type;
    v_stmt_main     clob;
    v_stmt_query    clob;
    v_join          varchar2(4000 char) := 'temploy1';
    v_where         varchar2(4000 char) := ' where ';
    v_flgpass       boolean;
    v_dummy         integer;
    v_cursor_main   number;
    v_cursor_query  number;
    v_chkExist      number;

    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_numlvl        varchar2(100 char);
    v_codpos        temploy1.codpos%type;
    v_codcatexm     ttestset.codcatexm%type;
    v_codexam       ttestset.codexam%type;

    cursor c_report2 is
      select distinct namtbl
        from treport2
       where codapp = 'HRPMA1X';

    cursor c_chk_sal is
      select distinct namtbl||'.'||rp2.namfld as colmn
        from treport2 rp2, tcoldesc cd
       where rp2.codapp   = 'HRPMA1X'
         and rp2.namtbl   = cd.codtable
         and rp2.namfld   = cd.codcolmn
         and cd.flgchksal = 'Y';
  begin
    -- start process
    v_syncond   := hcm_util.get_string_t(p_syncond, 'code');
    v_statement := hcm_util.get_string_t(p_syncond, 'statement');
    numYearReport := HCM_APPSETTINGS.get_additional_year();
    --
    for r_treport2 in c_report2 loop
      if instr(v_syncond,r_treport2.namtbl) > 0 then
        if upper(r_treport2.namtbl) in ('TAPPLDOC','TEMPOTHR','TCMPTNCY','TAPPLWEX','TAPPLREF','TTRAINBF','TEDUCATN') then
          v_join  := v_join||' join '||r_treport2.namtbl||' on '||r_treport2.namtbl||'.numappl = temploy1.numappl ';
        elsif upper(r_treport2.namtbl) <> 'TEMPLOY1' then
          v_join  := v_join||' join '||r_treport2.namtbl||' on '||r_treport2.namtbl||'.codempid = temploy1.codempid ';
        end if;
      end if;
    end loop;
    v_where := v_where||v_syncond;
    for r_chk_sal in c_chk_sal loop
      if instr(v_syncond,r_chk_sal.colmn) > 0 then
        v_where   := replace(v_where,r_chk_sal.colmn,'stddec('||r_chk_sal.colmn||',temploy1.codempid,'||global_v_chken||')');
      end if;
    end loop;

    if v_where like '%AGEEMPMT%' then
      v_where := replace(v_where,'TEMPLOY1.AGEEMPMT','TRUNC( MONTHS_BETWEEN(NVL(TEMPLOY1.DTEEFFEX,SYSDATE),TEMPLOY1.DTEEMPMT))');
    elsif v_where like '%AGEEMP%' then
      v_where := replace(v_where,'TEMPLOY1.AGEEMP','TRUNC( MONTHS_BETWEEN(SYSDATE,TEMPLOY1.DTEEMPDB)/12)');
    elsif v_where like '%AGELEVEL%' then
      v_where := replace(v_where,'TEMPLOY1.AGELEVEL','TRUNC( MONTHS_BETWEEN(NVL(TEMPLOY1.DTEEFFEX,SYSDATE),TEMPLOY1.DTEEFLVL))');
    elsif v_where like '%AGEPOS%' then
      v_where := replace(v_where,'TEMPLOY1.AGEPOS','TRUNC( MONTHS_BETWEEN(NVL(TEMPLOY1.DTEEFFEX,SYSDATE),TEMPLOY1.DTEEFPOS))');
    elsif v_where like '%AGEJOBGRADE%' then
      v_where := replace(v_where,'TEMPLOY1.AGEJOBGRADE','TRUNC( MONTHS_BETWEEN(NVL(TEMPLOY1.DTEEFFEX,SYSDATE),TEMPLOY1.DTEEFSTEP))');
    end if;

    if v_where is not null then
      v_where := v_where || ' and TEMPLOY1.codcomp like '''|| p_codcomp || '%''';
    end if;

    v_stmt_main  := ' select temploy1.codempid,temploy1.codcomp,temploy1.codpos,temploy1.numlvl '||
                    ' from '||v_join||v_where||
                    ' order by temploy1.codcomp,temploy1.codempid,temploy1.codpos,temploy1.numlvl';

    v_cursor_main   := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor_main,v_stmt_main,dbms_sql.native);
    dbms_sql.define_column(v_cursor_main,1,v_codempid,1000);
    dbms_sql.define_column(v_cursor_main,2,v_codcomp,1000);
    dbms_sql.define_column(v_cursor_main,3,v_codpos,1000);
    dbms_sql.define_column(v_cursor_main,4,v_numlvl,1000);
    v_dummy := dbms_sql.execute(v_cursor_main);

    v_cursor_query  := dbms_sql.open_cursor;
    obj_row := json_object_t();
    while (dbms_sql.fetch_rows(v_cursor_main) > 0) loop
      dbms_sql.column_value(v_cursor_main,1,v_codempid);
      dbms_sql.column_value(v_cursor_main,2,v_codcomp);
      dbms_sql.column_value(v_cursor_main,3,v_codpos);
      dbms_sql.column_value(v_cursor_main,4,v_numlvl);

      v_flgpass     := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_flgpass then
        v_row := v_row + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', v_codempid);
        obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
        obj_data.put('codcomp', v_codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
        obj_data.put('codpos', v_codpos);
        obj_data.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
        obj_data.put('numlvl', v_numlvl);
        obj_data.put('flgAdd',true);
        obj_row.put(to_char(v_row - 1), obj_data);
      end if;
    end loop;
    commit;
    obj_result          := json_object_t();
    param_msg_error     := get_error_msg_php('HR2715',global_v_lang);
    v_response          := get_response_message(null,param_msg_error,global_v_lang);
    obj_result.put('coderror', '200');
    obj_result.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
    obj_result.put('table', obj_row);
    json_str_output := obj_result.to_clob;

  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end process_data;
  --
  procedure post_process(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      process_data(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_codemp(json_str_output out clob)as
    obj_data        json_object_t;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_numlvl        temploy1.numlvl%type;
    v_year          number;
    v_month         number;
    v_day           number;
  begin
    begin
      begin
        select codcomp,codpos,numlvl
          into v_codcomp,v_codpos,v_numlvl
          from temploy1
         where codempid = b_index_codempid;
      end;
    exception when no_data_found then
      v_codcomp   := '';
      v_codpos    := '';
      v_numlvl    := null;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', b_index_codempid);
    obj_data.put('desc_codempid', get_temploy_name(b_index_codempid, global_v_lang));
    obj_data.put('codcomp', v_codcomp);
    obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
    obj_data.put('codpos', v_codpos);
    obj_data.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
    obj_data.put('numlvl', v_numlvl);
    obj_data.put('flgAdd',true);

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_codemp(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_codemp(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    v_flg               varchar2(100 char);
    v_codcomp	        ttestset.codcomp%type;
    v_codexam	        ttestset.codexam%type;
    v_codcatexm	        ttestset.codcatexm%type;
    v_datest	        ttestset.dtetestst%type;
    v_dateen	        ttestset.dtetesten%type;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        v_codcomp         := upper(hcm_util.get_string_t(json_row, 'codcomp'));
        v_codexam         := upper(hcm_util.get_string_t(json_row, 'codexam'));
        v_codcatexm       := upper(hcm_util.get_string_t(json_row, 'codcatexm'));
        v_datest          := to_date(hcm_util.get_string_t(json_row, 'datest'), 'dd/mm/yyyy');
        v_dateen          := to_date(hcm_util.get_string_t(json_row, 'dateen'), 'dd/mm/yyyy');

        if v_codexam is null then
          v_codexam := '%';
        end if;
        if v_codcatexm is null then
          v_codcatexm := '%';
        end if;

        if v_flg = 'delete' then
          begin
            Delete
              From ttestset
             where codcomp = v_codcomp
               and codexam  = v_codexam
               and codcatexm  = v_codcatexm
               and dtetestst  = v_datest
               and dtetesten  = v_dateen;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end;

          begin
            Delete ttestsetd
             where codcomp = v_codcomp
               and codexam  = v_codexam
               and codcatexm  = v_codcatexm
               and dtetestst  = v_datest
               and dtetesten  = v_dateen;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2425', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;

  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    obj_row             json_object_t;
    obj_syncond         json_object_t;
    param_json_row      json_object_t;
    param_object        json_object_t;
    v_condition         ttalent.syncond%type;
    v_syncond           ttalent.syncond%type;
    v_statement         clob;
    v_stmt              varchar2(4000 char);
    v_flg               varchar2(10 char);
    v_codempid          temploy1.codempid%type;
    v_codcomp           temploy1.codcomp%type;
    v_codpos            temploy1.codpos%type;
    v_numlvl            temploy1.numlvl%type;
    v_chkExist          number;
    v_codcatexm         ttestset.codcatexm%type;
    v_codexam           ttestset.codexam%type;
    v_flgAdd            boolean;
    v_flgDelete         boolean;
    v_codcomp2          temploy1.codcomp%type;
  begin
    initial_value(json_str_input);
--    check_save;
    if param_msg_error is null then
      v_syncond        := hcm_util.get_string_t(params_syncond, 'code');
      v_statement      := hcm_util.get_string_t(params_syncond, 'statement');

      if p_codcatexm is null then
        v_codcatexm := '%';
      else
        v_codcatexm := p_codcatexm;
      end if;
      if p_codexam is null then
        v_codexam := '%';
        hrel21e.get_random_exam_by_category(p_codcatexm,v_codexam,param_msg_error);
      else
        v_codexam := p_codexam;
      end if;

      -- insert/ update ttestset
      begin
        select count(*)
          into v_chkExist
          from ttestset
         where codcomp = p_codcomp
           and dtetestst = p_dtestrt
           and dtetesten = p_dteend
           and codcatexm = v_codcatexm
           and codexam = v_codexam;
      exception when no_data_found then
        v_chkExist := 0;
      end;

      if v_chkexist = 0 then
        begin
            insert into ttestset(codcomp,dtetestst,dtetesten,codcatexm,codexam,
                                 syncond,statement,remark,dtecreate,codcreate)
                          values(p_codcomp, p_dtestrt, p_dteend, v_codcatexm, v_codexam,
                                 v_syncond, v_statement, p_remark, sysdate, global_v_coduser);
        end;
      else
        begin
          update ttestset
             set syncond = v_syncond,
                 statement = v_statement,
                 remark = p_remark,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where codcomp = p_codcomp
             and dtetestst = p_dtestrt
             and dtetesten = p_dteend
             and codcatexm = v_codcatexm
             and codexam = v_codexam;
        end;
      end if;

      begin
        delete ttestsetd
         where codcomp = p_codcomp
           and dtetestst = p_dtestrt
           and dtetesten = p_dteend
           and codcatexm = v_codcatexm
           and codexam = v_codexam;
      end;
      for i in 0..json_params.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(json_params,to_char(i));
        v_flgAdd     		:= hcm_util.get_boolean_t(param_json_row, 'flgAdd');
        v_flgDelete         := hcm_util.get_boolean_t(param_json_row, 'flgDelete');
        v_codempid		    := hcm_util.get_string_t(param_json_row, 'codempid');
        v_codcomp		    := hcm_util.get_string_t(param_json_row, 'codcomp');
        v_codpos		    := hcm_util.get_string_t(param_json_row, 'codpos');
        v_numlvl		    := hcm_util.get_string_t(param_json_row, 'numlvl');

        if v_flgDelete = true then
          begin
            delete ttestsetd
             where codcomp = p_codcomp
               and dtetestst = p_dtestrt
               and dtetesten = p_dteend
               and codcatexm = v_codcatexm
               and codexam = v_codexam
               and codempid = v_codempid;
          end;
        else
--< #4600 || 27/05/2022
          -- Check HR2104 no_data_found  
          begin
            select codcomp into v_codcomp2
            from temploy1
            where codempid = v_codempid
            and codcomp like p_codcomp || '%';
          exception when no_data_found then
            rollback;
            param_msg_error := get_error_msg_php('HR2104',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
          end;

          -- Check HR2101 staemp = '9' 
          begin
            select codcomp into v_codcomp2
            from temploy1
            where codempid = v_codempid
            and staemp = '9';
            rollback;
            param_msg_error := get_error_msg_php('HR2101',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
          exception when no_data_found then
            null;
          end;

          -- Check HR2102 staemp = '0'
          begin
            select codcomp into v_codcomp2
            from temploy1
            where codempid = v_codempid
            and staemp = '0';
            rollback;
            param_msg_error := get_error_msg_php('HR2102',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
          exception when no_data_found then
            null;
          end;
--< #4600 || 27/05/2022

          begin
            insert into ttestsetd(codcomp,dtetestst,dtetesten,codcatexm,codexam,codempid,dtecreate,codcreate,coduser)
                          values(p_codcomp, p_dtestrt, p_dteend, v_codcatexm, v_codexam,v_codempid, sysdate, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then null;
          end;
        end if;
      end loop;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

end hrel40e;

/

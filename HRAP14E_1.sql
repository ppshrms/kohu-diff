--------------------------------------------------------
--  DDL for Package Body HRAP14E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP14E" as
  procedure initial_value(json_str in clob) is
    json_obj                json_object_t;
  begin
    v_chken                 := hcm_secur.get_v_chken;
    json_obj                := json_object_t(json_str);
    --global
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index

    p_codcomp               := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codaplvl              := hcm_util.get_string_t(json_obj,'p_codaplvl');
    p_dteeffec              := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'ddmmyyyy');

    p_codcompQuery          := hcm_util.get_string_t(json_obj,'p_codcompQuery');
    p_codaplvlQuery         := hcm_util.get_string_t(json_obj,'p_codaplvlQuery');
    p_dteeffecQuery         := to_date(hcm_util.get_string_t(json_obj,'p_dteeffecQuery'),'ddmmyyyy');

    p_condition             := hcm_util.get_string_t(json_obj,'p_condition');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row_attention   json_object_t;
    obj_row_behavior    json_object_t;
    obj_row_kpi         json_object_t;
    obj_row_taplvld     json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_dteeffec          taplvl.dteeffec%type;
    v_flgDisabled       boolean;
    v_flgAdd            boolean := false;

    v_codform           taplvl.codform%type;
    v_condap            taplvl.condap%type;
    v_statement         taplvl.statement%type;
    v_pctbeh            taplvl.pctbeh %type;
    v_pctcmp            taplvl.pctcmp%type;
    v_pctkpicp          taplvl.pctkpicp%type;
    v_pctkpiem          taplvl.pctkpiem%type;
    v_pctkpirt          taplvl.pctkpirt%type;
    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;
    obj_syncond         json_object_t;
    v_cmpweight         number := 0;

    obj_dataX           json_object_t;
    obj_dataY           json_object_t;
    obj_dataY_row       json_object_t;
    obj_graph           json_object_t;
    obj_dataY_data      json_object_t;
    obj_dataY_bg        json_object_t;

    v_rcnt              number := 0;
    cursor c1 is
      select *
        from taplvld
       where codcomp = p_codcomp
         and codaplvl = p_codaplvl
         and dteeffec = v_dteeffec
    order by codtency;
  begin
    if p_codcompQuery is not null and p_codaplvlQuery is not null  and p_dteeffecQuery is not null then
      p_isCopy          :=  'Y';
      v_flgDisabled     := false;
      v_dteeffec        := p_dteeffec;
      v_flgAdd          := true;
    else
        begin
            select max(dteeffec)
              into v_dteeffec
              from taplvl
             where codcomp = p_codcomp
               and codaplvl = p_codaplvl
               and dteeffec <= p_dteeffec;
        exception when others then
            v_dteeffec := null;
        end;

        if p_dteeffec < trunc(sysdate) then
            if v_dteeffec is null then
                v_flgDisabled   := false;
                v_flgAdd        := true;
            else
                v_flgDisabled := true;
            end if;
        else
            v_flgDisabled := false;
            if v_dteeffec is null or v_dteeffec < p_dteeffec  then
                v_flgAdd := true;
            end if;
        end if;
    end if;

    begin
        select codform,condap,statement,pctbeh,
               pctcmp,pctkpicp,pctkpiem,pctkpirt,pctta,pctpunsh

          into v_codform, v_condap, v_statement, v_pctbeh,
               v_pctcmp, v_pctkpicp, v_pctkpiem, v_pctkpirt, v_pctta, v_pctpunsh
          from taplvl
         where codcomp = p_codcomp
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec;
    exception when  no_data_found then
        v_codform       := null;
        v_condap        := null;
        v_statement     := null;
        v_pctbeh        := null;
        v_pctcmp        := null;
        v_pctkpicp      := null;
        v_pctkpiem      := null;
        v_pctkpirt      := null;
        v_pctta         := null;
        v_pctpunsh      := null;
    end;

    -- attention
    obj_row_attention := json_object_t();
    v_rcnt := 0;
    v_rcnt := v_rcnt+1;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('description', get_label_name('HRAP14E', global_v_lang, 140));
    obj_data.put('fieldname', 'PCTTA');
    obj_data.put('pct', v_pctta);
    obj_row_attention.put(to_char(v_rcnt-1),obj_data);
    v_rcnt := v_rcnt+1;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('description', get_label_name('HRAP14E', global_v_lang, 150));
    obj_data.put('fieldname', 'PCTPUNSH');
    obj_data.put('pct', v_pctpunsh);
    obj_row_attention.put(to_char(v_rcnt-1),obj_data);

    -- behavior
    obj_row_behavior := json_object_t();
    v_rcnt := 0;
    v_rcnt := v_rcnt+1;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('description', get_label_name('HRAP14E', global_v_lang, 180));
    obj_data.put('fieldname', 'PCTBEH');
    obj_data.put('pct', v_pctbeh);
    obj_row_behavior.put(to_char(v_rcnt-1),obj_data);

    -- taplvld
    obj_row_taplvld := json_object_t();
    v_rcnt := 0;
    for i in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codtency', i.codtency);
      obj_data.put('qtywgt', i.qtywgt);
      obj_data.put('flgAdd', v_flgAdd);
      v_cmpweight := v_cmpweight + nvl(i.qtywgt,0);
      if not v_flgAdd then
        obj_data.put('disabled', true);
      else
        obj_data.put('disabled', false);
      end if;
      obj_row_taplvld.put(to_char(v_rcnt-1),obj_data);
    end loop;

    -- kpi
    obj_row_kpi := json_object_t();
    v_rcnt := 0;
    v_rcnt := v_rcnt+1;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('description', get_label_name('HRAP14E', global_v_lang, 210));
    obj_data.put('fieldname', 'PCTKPICP');
    obj_data.put('pct', v_pctkpicp);
    obj_row_kpi.put(to_char(v_rcnt-1),obj_data);
    v_rcnt := v_rcnt+1;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('description', get_label_name('HRAP14E', global_v_lang, 220));
    obj_data.put('fieldname', 'PCTKPIRT');
    obj_data.put('pct', v_pctkpirt);
    obj_row_kpi.put(to_char(v_rcnt-1),obj_data);
    v_rcnt := v_rcnt+1;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('description', get_label_name('HRAP14E', global_v_lang, 230));
    obj_data.put('fieldname', 'PCTKPIEM');
    obj_data.put('pct', v_pctkpiem);
    obj_row_kpi.put(to_char(v_rcnt-1),obj_data);

    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('isCopy', p_isCopy);
    obj_result.put('flgDisabled', v_flgDisabled);
    obj_result.put('codform', v_codform);
    obj_result.put('weight', nvl(v_pctbeh,0)+ nvl(v_pctcmp,0) + nvl(v_pctkpicp,0) + nvl(v_pctkpiem,0) + nvl(v_pctkpirt,0) + nvl(v_pctta,0) + nvl(v_pctpunsh,0));

    obj_syncond := json_object_t();
    obj_syncond.put('code', v_condap);
    obj_syncond.put('description', get_logical_name('HRAP14E', v_condap, global_v_lang));
    obj_syncond.put('statement', v_statement);
    obj_result.put('syncond', obj_syncond);

    if v_flgDisabled then
        obj_result.put('msgerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
    end if;
    obj_result.put('attention', obj_row_attention);
    obj_result.put('behavior', obj_row_behavior);
    obj_result.put('taplvld', obj_row_taplvld);
    obj_result.put('kpi', obj_row_kpi);

    obj_dataX := json_object_t();
    obj_dataX.put(to_char(0),get_label_name('HRAP14E', global_v_lang, 130));
    obj_dataX.put(to_char(1),get_label_name('HRAP14E', global_v_lang, 170));
    obj_dataX.put(to_char(2),get_label_name('HRAP14E', global_v_lang, 190));
    obj_dataX.put(to_char(3),get_label_name('HRAP14E', global_v_lang, 200));

    obj_dataY_data  := json_object_t();
    obj_dataY_data.put(to_char(0), nvl(v_pctta,0) + nvl(v_pctpunsh,0));
    obj_dataY_data.put(to_char(1), nvl(v_pctbeh,0));
    obj_dataY_data.put(to_char(2), nvl(v_pctcmp,0));
    obj_dataY_data.put(to_char(3), nvl(v_pctkpicp,0) + nvl(v_pctkpiem,0) + nvl(v_pctkpirt,0));



    obj_dataY := json_object_t();
    obj_dataY.put('data', obj_dataY_data);

    obj_dataY_bg    := json_object_t();
    obj_dataY_bg.put(to_char(0), '#E34C4C');
    obj_dataY_bg.put(to_char(1), '#F7B422');
    obj_dataY_bg.put(to_char(2), '#ffeb3b');
    obj_dataY_bg.put(to_char(3), '#56BD5B');
    obj_dataY.put('backgroundColor', obj_dataY_bg);

--    obj_dataY_bg    := json_object_t();
--    obj_dataY_bg.put(to_char(0), '#E34C4C');
--    obj_dataY_bg.put(to_char(1), '#F7B422');
--    obj_dataY_bg.put(to_char(2), '#ffeb3b');
--    obj_dataY_bg.put(to_char(3), '#56BD5B');
    obj_dataY.put('hoverBackgroundColor', obj_dataY_bg);

    obj_dataY_row := json_object_t();
    obj_dataY_row.put(to_char(0), obj_dataY);

    obj_graph := json_object_t();
    obj_graph.put('datasets', obj_dataY_row);
    obj_graph.put('labels', obj_dataX);
    obj_result.put('graph', obj_graph);

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_index is
     v_codcomp   tcenter.codcomp%type;
     v_codaplvl  tcodaplv.codcodec%type;
  begin
    if p_codcomp is not null then
      begin
        select codcomp into v_codcomp
          from tcenter
         where codcomp = get_compful(p_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_codaplvl is not null then
      begin
        select codcodec into v_codaplvl
          from tcodaplv
         where codcodec = p_codaplvl;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCODAPLV');
        return;
      end;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_copy_list(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    cursor c1 is
      select codcomp, codaplvl, max(dteeffec) dteeffec
        from taplvl
    group by codcomp, codaplvl
    order by codcomp, codaplvl;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcomp', i.codcomp);
      obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
      obj_data.put('codaplvl', i.codaplvl);
      obj_data.put('desc_codaplvl', get_tcodec_name('TCODAPLV', i.codaplvl, global_v_lang));
      obj_data.put('dteeffec', to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_copy_list(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_copy_list(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_emp_list(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    v_stment        clob;
    v_where         clob;
    v_cursor        number;
    type descol is table of varchar2(2500) index by binary_integer;
    data_file       descol;
    v_data_file     varchar2(2500);
    v_dummy         integer;
    v_count         number;
    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_jobgrade      temploy1.jobgrade%type;

  begin
    obj_row := json_object_t();
    v_where := ' and codcomp like '''||p_codcomp||'%''';
    if p_condition is not null then
        v_where := v_where ||' and ' ||p_condition;
    end if;

    v_stment := 'select codempid, codcomp, codpos, jobgrade from v_hrap14e where staemp <> 9 ' ||v_where|| ' order by codempid';
    v_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

    for j in 1..4 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
    end loop;

    v_dummy := dbms_sql.execute(v_cursor);

    loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
            exit;
        end if;
        for j in 1..4 loop
            dbms_sql.column_value(v_cursor,j,v_data_file);
            data_file(j) := v_data_file;
        end loop;

        v_codempid  := data_file(1);
        v_codcomp   := data_file(2);
        v_codpos    := data_file(3);
        v_jobgrade  := data_file(4);
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', v_codempid);
        obj_data.put('desc_codempid', get_temploy_name(v_codempid,global_v_lang));
        obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
        obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
        obj_data.put('desc_jobgrade',get_tcodec_name('TCODJOBG', v_jobgrade, global_v_lang));
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    dbms_sql.close_cursor(v_cursor);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_emp_list(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_emp_list(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_save(json_str_input in clob) is
     v_codcomp      tcenter.codcomp%type;
     param_json     json_object_t;
     obj_formula    json_object_t;
     obj_table      json_object_t;
  begin
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'params');
    obj_formula   := hcm_util.get_json_t(param_json,'formula');
    obj_table     := hcm_util.get_json_t(param_json,'table');
  end;
  --
  procedure post_save (json_str_input in clob, json_str_output out clob) as
    param_json          json_object_t;
    param_json_row      json_object_t;

    v_flg	            varchar2(1000 char);
    v_isCopy            varchar2(1 char);
    v_count             number;

    obj_attention       json_object_t;
    obj_behavior        json_object_t;
    obj_kpi             json_object_t;
    obj_taplvld         json_object_t;

    obj_row_attention   json_object_t;
    obj_row_behavior    json_object_t;
    obj_row_kpi         json_object_t;
    obj_row_taplvld     json_object_t;

    v_codform           taplvl.codform%type;
    v_condap            taplvl.condap%type;
    v_statement         taplvl.statement%type;
    v_pctbeh            taplvl.pctbeh %type;
    v_pctcmp            taplvl.pctcmp%type;
    v_pctkpicp          taplvl.pctkpicp%type;
    v_pctkpiem          taplvl.pctkpiem%type;
    v_pctkpirt          taplvl.pctkpirt%type;
    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;
    obj_syncond         json_object_t;
    v_cmpweight         number := 0;
    v_fieldname         varchar2(100);
    v_pct               number;
    v_codtency          taplvld.codtency%type;
    v_qtywgt            taplvld.qtywgt%type;
  begin
    initial_value(json_str_input);
--    check_save(json_str_input);

    param_json      := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    v_isCopy        := hcm_util.get_string_t(param_json,'isCopy');
    v_codform       := hcm_util.get_string_t(param_json,'codform');
    obj_attention   := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(param_json),'attention'),'rows');
    obj_behavior    := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(param_json),'behavior'),'rows');
    obj_kpi         := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(param_json),'kpi'),'rows');
    obj_taplvld     := hcm_util.get_json_t(json_object_t(param_json),'taplvld');
--    obj_taplvld     := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(param_json),'taplvld'),'rows');
    obj_syncond     := hcm_util.get_json_t(json_object_t(param_json),'syncond');
    v_condap        := hcm_util.get_string_t(json_object_t(obj_syncond),'code');
    v_statement     := hcm_util.get_string_t(json_object_t(obj_syncond),'statement');

    if v_isCopy = 'Y' then
        begin
          delete taplvl
           where codcomp = p_codcomp
             and codaplvl = p_codaplvl
             and dteeffec = p_dteeffec;
        end;
    end if;

    -- attention
    for i in 0..obj_attention.get_size-1 loop
        obj_row_attention   := hcm_util.get_json_t(obj_attention,to_char(i));
        v_fieldname         := hcm_util.get_string_t(obj_row_attention,'fieldname');
        v_pct               := to_number(hcm_util.get_string_t(obj_row_attention,'pct'));
        if v_fieldname = 'PCTTA' then
            v_pctta         := v_pct;
        elsif v_fieldname = 'PCTPUNSH' then
            v_pctpunsh      := v_pct;
        end if;
    end loop;

    -- behavior
    for i in 0..obj_behavior.get_size-1 loop
        obj_row_behavior    := hcm_util.get_json_t(obj_behavior,to_char(i));
        v_fieldname         := hcm_util.get_string_t(obj_row_behavior,'fieldname');
        v_pct               := to_number(hcm_util.get_string_t(obj_row_behavior,'pct'));
        if v_fieldname = 'PCTBEH' then
            v_pctbeh        := v_pct;
        end if;
    end loop;

    -- kpi
    for i in 0..obj_kpi.get_size-1 loop
        obj_row_kpi         := hcm_util.get_json_t(obj_kpi,to_char(i));
        v_fieldname         := hcm_util.get_string_t(obj_row_kpi,'fieldname');
        v_pct               := to_number(hcm_util.get_string_t(obj_row_kpi,'pct'));
        if v_fieldname = 'PCTKPICP' then
            v_pctkpicp      := v_pct;
        elsif v_fieldname = 'PCTKPIRT' then
            v_pctkpirt      := v_pct;
        elsif v_fieldname = 'PCTKPIEM' then
            v_pctkpiem      := v_pct;
        end if;
    end loop;

    -- competency
    for i in 0..obj_taplvld.get_size-1 loop
      obj_row_taplvld       := hcm_util.get_json_t(obj_taplvld,to_char(i));
      v_flg                 := hcm_util.get_string_t(obj_row_taplvld,'flg');
      v_codtency            := hcm_util.get_string_t(obj_row_taplvld,'codtency');
      v_qtywgt		        := hcm_util.get_string_t(obj_row_taplvld,'qtywgt');
      if v_flg = 'add' then
        begin
          insert into taplvld(codcomp,codaplvl,dteeffec,codtency,qtywgt,
                              dtecreate,codcreate,dteupd,coduser)
          values (p_codcomp, p_codaplvl, p_dteeffec,v_codtency,v_qtywgt,
                  sysdate,global_v_coduser,sysdate,global_v_coduser);
        end;
      elsif v_flg = 'delete' then
        begin
          delete taplvld
           where codcomp = p_codcomp
             and codaplvl = p_codaplvl
             and dteeffec = p_dteeffec
             and codtency = v_codtency;
        end;
      elsif v_flg = 'edit' then
        begin
          update taplvld
             set codtency =	v_codtency,
                 qtywgt = v_qtywgt,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where codcomp = p_codcomp
             and codaplvl = p_codaplvl
             and dteeffec = p_dteeffec
             and codtency = v_codtency;
        end;
      end if;
    end loop;


    select nvl(sum(nvl(qtywgt,0)),0)
      into v_pctcmp
      from taplvld
     where codcomp = p_codcomp
       and codaplvl = p_codaplvl
       and dteeffec = p_dteeffec;

    if  nvl(v_pctbeh,0)+ nvl(v_pctcmp,0) + nvl(v_pctkpicp,0) + nvl(v_pctkpiem,0) + nvl(v_pctkpirt,0) + nvl(v_pctta,0) + nvl(v_pctpunsh,0) <> 100 then
        param_msg_error := get_error_msg_php('AP0002',global_v_lang);
    end if;

    begin
        insert into taplvl (codcomp, codaplvl, dteeffec, codform, condap,
                            statement, pctbeh, pctcmp, pctkpicp, pctkpiem,
                            pctkpirt, pctta, pctpunsh,
                            dtecreate, codcreate, dteupd, coduser)
                    values (p_codcomp, p_codaplvl, p_dteeffec, v_codform, v_condap,
                            v_statement, v_pctbeh, v_pctcmp, v_pctkpicp, v_pctkpiem,
                            v_pctkpirt, v_pctta, v_pctpunsh,
                            sysdate, global_v_coduser, sysdate, global_v_coduser);
    exception when dup_val_on_index then
        update taplvl
           set codform = v_codform,
               condap = v_condap,
               statement = v_statement,
               pctbeh = v_pctbeh,
               pctcmp = v_pctcmp,
               pctkpicp = v_pctkpicp,
               pctkpiem = v_pctkpiem,
               pctkpirt = v_pctkpirt,
               pctta = v_pctta,
               pctpunsh = v_pctpunsh,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codcomp = p_codcomp
           and codaplvl = p_codaplvl
           and dteeffec = p_dteeffec;
    end;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      rollback;
      return;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --
end HRAP14E;

/

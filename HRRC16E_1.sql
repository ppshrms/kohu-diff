--------------------------------------------------------
--  DDL for Package Body HRRC16E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC16E" AS

  procedure initial_current_user_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_current_user_value;

  procedure initial_params(data_obj json_object_t) as
  begin
--  get index parameter
        p_codcomp            := hcm_util.get_string_t(data_obj,'p_codcomp');
        p_numreqst           := hcm_util.get_string_t(data_obj,'p_numreqst');
        p_codpos             := hcm_util.get_string_t(data_obj,'p_codpos');
        p_syncond            := hcm_util.get_string_t(data_obj,'p_syncond');
        p_typelogical        := hcm_util.get_string_t(data_obj,'p_typelogical');-- '1' = ตามที่ระบุในใบคำขอ , '3' =  กำหนดขึ้นใหม่
--  get drilldown parameter
        p_query_codempid     := hcm_util.get_string_t(data_obj,'p_query_codempid');
--  save index parameter
        p_dtereq             := to_date(hcm_util.get_string_t(data_obj,'p_dtereq'), 'dd/mm/yyyy');


  end initial_params;

  function check_index return boolean as
    v_temp    varchar(1 char);
    v_qtyreq  number := 0;
    v_qtyact  number := 0;
  begin
-- check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
        return false;
    end;

    if secur_main.secur7(p_codcomp, global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return false;
    end if;

--  check codpos
    begin
        select 'X' into v_temp
        from tpostn
        where codpos = p_codpos;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TPOSTN');
        return false;
    end;

--  check data in treqest2
    begin
      select nvl(qtyreq,0),nvl(qtyact,0) into v_qtyreq,v_qtyact
        from treqest2
       where codcomp  like p_codcomp||'%'
         and codpos   = nvl(p_codpos,codpos)
         and numreqst = nvl(p_numreqst,numreqst)
         and flgrecut in ('I','O');
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TREQEST2');
      return false;
    end;
    if v_qtyact >= v_qtyreq then
      param_msg_error := get_error_msg_php('HR4502', global_v_lang);
      return false;
    end if;

    return true;
  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_count         number := 0;
    v_count_secur   number := 0;
    v_year          number;
    v_month         number;
    v_day           number;
    v_statement     long;
    v_check_logical number := 0;
    v_syncond       treqest2.syncond%type;--nut
    v_data          varchar2(1 char) := 'N';
    v_secure        varchar2(1 char) := 'N';
    v_typelogical   varchar2(1 char) := p_typelogical;
    v_flgjob        treqest2.flgjob%type;
    v_flgcond       treqest2.flgcond%type;

    cursor c1 is
      select a.numreqst, a.codempid, b.codcomp, b.codpos, b.dteempmt, b.numlvl,
             a.dtereq, a.codappr, a.dteappr, a.status
        from tappeinf a, temploy1 b
       where a.codempid = b.codempid
         and a.numreqst = p_numreqst
         and a.codcomp  like p_codcomp||'%'
         and a.codpos   = p_codpos
         and a.status   = 'P'
    order by a.codempid;

  begin
    v_typelogical := p_typelogical;
    if v_typelogical = '1' then-- 1 = ตามที่ระบุในใบคำขอ , 3 =  กำหนดขึ้นใหม่
      begin
        select flgjob,flgcond
          into v_flgjob,v_flgcond
          from treqest2
         where codpos   = p_codpos
           and numreqst = p_numreqst;
      exception when no_data_found then null;
      end;

      if v_flgcond = 'Y' then
        v_typelogical := '1';
      elsif v_flgjob = 'Y' then
        v_typelogical := '2';
      end if;
    end if;
    obj_rows := json_object_t();
    for i in c1 loop
      v_count := v_count + 1;
      if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
        v_secure  := 'Y';
        v_syncond := null;
        if p_syncond is not null then
          v_syncond := ' and '||p_syncond;
        end if;
        if v_typelogical = '1' then
          if v_syncond is not null then
            v_syncond := replace(v_syncond,'V_HRRC26','V_HRPMA1');
          end if;
          v_statement := 'select count(v_hrpma1.codempid) '||
                         '  from v_hrpma1 '||
                         ' where v_hrpma1.codempid = '||''''||i.codempid||''''||' '||v_syncond;
        elsif v_typelogical = '2' then
          if v_syncond is not null then
            v_syncond := replace(v_syncond,'V_HRCO21.AGEEMP','V_HRPMA1.AGE');
            v_syncond := replace(v_syncond,'V_HRCO21.SV_YR','V_HRPMA1.SERVICEYEAR');
            v_syncond := replace(v_syncond,'V_HRCO21.CODCNTY','V_HRPMA1.CODCOUNT');
            v_syncond := replace(v_syncond,'V_HRCO21','V_HRPMA1');
          end if;
          v_statement := 'select count(v_hrpma1.codempid) '||
                         '  from v_hrpma1 '||
                         ' where v_hrpma1.codempid = '||''''||i.codempid||''''||' '||v_syncond;
        elsif v_typelogical = '3' then
          v_statement := 'select count(v_hrpma1.codempid) '||
                         '  from v_hrpma1 '||
                         ' where v_hrpma1.codempid = '||''''||i.codempid||''''||' '||v_syncond;
        end if;
        execute immediate v_statement into v_check_logical;

        if v_check_logical > 0 then
          v_data := 'Y';
          v_count_secur := v_count_secur + 1;
          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('image',get_emp_img(i.codempid));
          obj_data.put('flgstatus',i.status);
          obj_data.put('codempid',i.codempid);
          obj_data.put('desc_codempid',get_temploy_name(i.codempid, global_v_lang));
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp, global_v_lang));
          obj_data.put('desc_codpos',get_tpostn_name(i.codpos, global_v_lang));
          get_service_year(i.dteempmt, sysdate, 'Y', v_year, v_month, v_day);

          obj_data.put('agework',v_year||'('||v_month||')');
          obj_data.put('level',i.numlvl);
          obj_data.put('dteappl',to_char(i.dtereq, 'dd/mm/yyyy'));
          obj_data.put('approvby',get_temploy_name(i.codappr, global_v_lang));
          obj_data.put('dteapprov',to_char(i.dteappr, 'dd/mm/yyyy'));
          obj_data.put('numreqst',i.numreqst);
          obj_rows.put(to_char(v_row-1),obj_data);
        end if; -- v_check_logical > 0
      end if; -- secur_main.secur2
    end loop; -- i in c1

    if v_count > 0 and v_secure = 'N' then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
    elsif v_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TAPPEINF');
    end if;

    if param_msg_error is null then
      dbms_lob.createtemporary(json_str_output, true);
      obj_rows.to_clob(json_str_output);
    else
      json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end if;
  end gen_index;

  procedure gen_drilldown(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_count         number := 0;
    cursor c1 is
        select a.dtereq, a.codcompe, a.codpose, a.codcomp, a.codpos,
               a.codbrlc, a.codasapl
        from tappeinf a
        where a.codempid = p_query_codempid
        order by a.dtereq;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_count := v_count + 1;
        obj_data := json_object_t();
        obj_data.put('dtereq',to_char(i.dtereq, 'dd/mm/yyyy'));
        obj_data.put('desc_codcomp',get_tcenter_name(i.codcompe, global_v_lang));
        obj_data.put('current_codpos',get_tpostn_name(i.codpose, global_v_lang));
        obj_data.put('codcomp_appl',get_tcenter_name(i.codcomp, global_v_lang));
        obj_data.put('desc_codpos',get_tpostn_name(i.codpos, global_v_lang));
        obj_data.put('branc_appl',get_tcodec_name('TCODLOCA', i.codbrlc, global_v_lang));
--        obj_data.put('result',get_tcodec_name('TCODLOCA', i.codasapl, global_v_lang)); -- <<user25 Date: 18/10/2021 #4335
          obj_data.put('result',get_tlistval_name('CODASAPL', i.codasapl, global_v_lang));-- <<user25 Date: 18/10/2021 #4335
        obj_rows.put(to_char(v_count-1),obj_data);
    end loop;

    if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPEINF');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    else
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end if;

  end gen_drilldown;

  procedure update_tappeinf as
  begin
    update tappeinf
    set status = 'A',
        dtefoll = sysdate,
        coduser = global_v_coduser
    where codempid = p_query_codempid
      and dtereq = p_dtereq
      and numreqst = p_numreqst
      and codcomp like p_codcomp||'%'
      and codpos = p_codpos;

  end update_tappeinf;

  procedure update_treqest1 as
  begin
    update treqest1
    set dterec = sysdate,
        coduser = global_v_coduser
    where numreqst = p_numreqst;

  end update_treqest1;

  procedure update_treqest2 as
  begin
    update treqest2
    set dtechoose = sysdate,
        coduser = global_v_coduser
    where numreqst = p_numreqst
      and codpos = p_codpos;

  end update_treqest2;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    if check_index then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index;

  procedure get_drilldown(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_drilldown(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_drilldown;

  procedure save_index(json_str_input in clob, json_str_output out clob) AS
    json_obj       json_object_t;
    data_obj       json_object_t;
    v_qtypos       number := 0;
  begin
    initial_current_user_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    for i in 0..param_json.get_size-1 loop
        data_obj  := hcm_util.get_json_t(param_json, to_char(i));
        initial_params(data_obj);
        update_tappeinf;
        update_treqest1;
        update_treqest2;

    end loop;

    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END save_index;

    procedure send_mail_a(data_obj json_object_t) as
        v_rowid         varchar(20);

        json_obj        json_object_t;
        v_codform       TFWMAILH.codform%TYPE;
        v_codapp        TFWMAILH.codapp%TYPE;

        v_error             varchar2(4000 char);
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr           varchar2(500 char);
        v_subject           varchar2(500 char);

        v_msg         	clob;

        v_email         varchar(200);
        v_codintview    treqest1.codintview%type;

        v_numreqst      tappeinf.numreqst%type;
        v_codcomp       tappeinf.codcomp%type;
        v_codpos        tappeinf.codpos%type;
        v_codempid      tappeinf.codempid%type;
        v_dtereq        tappeinf.dtereq%type;
        v_maillang      varchar2(10);
    begin

        v_subject  := get_label_name('HRRC16E', global_v_lang, 10);
        v_codapp   := 'HRRC16E';

        begin
            select codform into v_codform
            from tfwmailh
            where codapp = v_codapp;
        exception when no_data_found then
            v_codform  := 'HRRC16E';
        end;


        v_numreqst  := hcm_util.get_string_t(data_obj, 'numreqst');
        begin
            select codintview into v_codintview
            from treqest1
            where numreqst = v_numreqst;
        exception when no_data_found then
            v_codintview := '';
        end;

        v_codcomp   := hcm_util.get_string_t(data_obj, 'codcomp');
        v_codpos    := hcm_util.get_string_t(data_obj, 'codpos');
        v_codempid  := hcm_util.get_string_t(data_obj, 'codempid');
        v_dtereq    := to_date(hcm_util.get_string_t(data_obj, 'dtereq'),'dd/mm/yyyy');
        v_maillang  :=  chk_flowmail.get_emp_mail_lang(v_codintview);
        chk_flowmail.get_message(v_codapp, v_maillang, v_msg_to, v_templete_to, v_func_appr);

        -- replace employee param
        begin
            select rowid into v_rowid
            from tappeinf
            where numreqst = v_numreqst
            and codcomp    like v_codcomp||'%'
            and codpos     = v_codpos
            and codempid   = v_codempid
            and dtereq     = v_dtereq;
        exception when no_data_found then
            v_rowid := '';
        end;
        chk_flowmail.replace_text_frmmail(v_templete_to, 'TAPPEINF', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, v_maillang, v_msg_to, p_chkparam => 'N');
        -- replace employee param email reciever param
      /*  begin
            select rowid,codintview into v_rowid,v_codintview
            from treqest1
            where numreqst = v_numreqst;
        exception when no_data_found then
            v_rowid := '';
            v_codintview := '';
        end;
        chk_flowmail.replace_text_frmmail(v_templete_to, 'TREQEST1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');
*/
        -- replace sender
        begin
            select rowid into v_rowid
            from temploy1
            where codempid = v_codempid;
        exception when no_data_found then
            v_rowid := '';
        end;
        --chk_flowmail.replace_text_frmmail(v_templete_to, 'TEMPLOY1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

        chk_flowmail.replace_param('TEMPLOY1',v_rowid,v_codform,'1',v_maillang,v_msg_to,'N');
        begin
            select email into v_email
            from temploy1
            where codempid = v_codintview;
        exception when no_data_found then
            v_email := '';
        end;
        --
        v_error := chk_flowmail.send_mail_to_emp (v_codintview, global_v_coduser, v_msg_to, NULL, v_subject, 'E', v_maillang, null,null,null, null);
    end send_mail_a;

  procedure send_email(json_str_input in clob, json_str_output out clob) AS
        json_obj        json_object_t;
        data_obj        json_object_t;
    begin
        initial_current_user_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            data_obj    := hcm_util.get_json_t(param_json, to_char(i));
            send_mail_a(data_obj);
        end loop;
        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end send_email;

    procedure gen_syncond(json_str_output out clob) as
      obj_rows        json_object_t;
      obj_data        json_object_t;
      v_flgjob        treqest2.flgjob%type;
      v_codjob        treqest2.codjob%type;
      v_flgcond       treqest2.flgcond%type;
      v_syncond       treqest2.syncond%type;
      v_statement     treqest2.statement%type;
    begin
      begin
        select flgjob,codjob,flgcond,syncond,statement
          into v_flgjob,v_codjob,v_flgcond,v_syncond,v_statement
          from treqest2
         where codpos   = p_codpos
           and numreqst = p_numreqst;
      exception when no_data_found then
        v_flgjob    := null;
        v_codjob    := null;
        v_flgcond   := null;
        v_syncond   := null;
        v_statement := null;
      end;

      if v_flgcond = 'Y' then
        v_syncond   := v_syncond;
        v_statement := v_statement;
      end if;
      if v_flgjob = 'Y' then
        begin
          select syncond,statement into v_syncond,v_statement
            from tjobcode
           where codjob = v_codjob;
        exception when no_data_found then
          v_syncond   := null;
          v_statement := null;
        end;
      end if;
      obj_data := json_object_t();
      obj_data.put('code',v_syncond);
      obj_data.put('description',get_logical_desc(v_statement));
      obj_data.put('statement',v_statement);
      obj_rows := json_object_t();
      obj_rows.put('0',obj_data);
      dbms_lob.createtemporary(json_str_output, true);
      obj_rows.to_clob(json_str_output);
    end gen_syncond;

    procedure get_index_syncond(json_str_input in clob, json_str_output out clob) as
    begin
        initial_current_user_value(json_str_input);
        initial_params(json_object_t(json_str_input));
        gen_syncond(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index_syncond;

    procedure gen_codbrlc(json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_codbrlc   treqest2.codbrlc%type;
    begin
        begin
            select codbrlc into v_codbrlc
              from treqest2
             where codpos = p_codpos
               and numreqst = p_numreqst;
        exception when no_data_found then
            v_codbrlc := '';
        end;
        obj_data := json_object_t();
        obj_data.put('codbrlc',v_codbrlc);
        obj_rows := json_object_t();
        obj_rows.put('0',obj_data);
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_codbrlc;

    procedure get_index_codbrlc(json_str_input in clob, json_str_output out clob) as
    begin
        initial_current_user_value(json_str_input);
        initial_params(json_object_t(json_str_input));
        gen_codbrlc(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index_codbrlc;

END HRRC16E;

/

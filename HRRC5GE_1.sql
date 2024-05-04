--------------------------------------------------------
--  DDL for Package Body HRRC5GE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC5GE" AS

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
        p_codcomp           := hcm_util.get_string_t(data_obj,'p_codcomp');
        p_numreqst          := hcm_util.get_string_t(data_obj,'p_numreqst');

        p_codpos            := hcm_util.get_string_t(data_obj,'p_codpos');

--  save index parameter
        p_query_codempid     := hcm_util.get_string_t(data_obj,'p_query_codempid');
        p_dtereq             := to_date(hcm_util.get_string_t(data_obj,'p_dtereq'), 'dd/mm/yyyy');
        p_dteappoi           := to_date(hcm_util.get_string_t(data_obj,'p_dteappoi'), 'dd/mm/yyyy');
        p_codempts           := hcm_util.get_string_t(data_obj,'p_codempts');
        p_numscore           := hcm_util.get_string_t(data_obj,'p_numscore');
        p_perscore           := hcm_util.get_string_t(data_obj,'p_perscore');
        p_codasapl           := hcm_util.get_string_t(data_obj,'p_codasapl');
        p_dtestrt            := to_date(hcm_util.get_string_t(data_obj,'p_dtestrt'),'dd/mm/yyyy');
        p_dtestrt            := to_date(hcm_util.get_string_t(data_obj,'p_dtestrt'),'dd/mm/yyyy');
        p_numreqst_emp       := hcm_util.get_string_t(data_obj,'p_numreqst_emp');
        p_codpose            := hcm_util.get_string_t(data_obj,'p_codpose');
        p_codcompe           := hcm_util.get_string_t(data_obj,'p_codcompe');
  end initial_params;

  function check_index return boolean as
    v_temp          varchar(1 char);
    v_qtyact        treqest2.qtyact%type;
    v_qtyreq        treqest2.qtyreq%type;
   /* v_found         varchar(1 char);
    v_check         varchar(1 char);

    cursor c1 is
      select qtyact, qtyreq
        from treqest2
       where codcomp  like p_codcomp||'%'
         and codpos   = nvl(p_codpos,codpos)
         and numreqst = nvl(p_numreqst,numreqst)
         and flgrecut in ('I','O')
    order by numreqst desc; */

  begin
--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
        return false;
    end;

--  check secur7
    if secur_main.secur7(p_codcomp , global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return false;
    end if;

--  check position
    if p_codpos is not null then--nut
    begin
        select 'X' into v_temp
        from tpostn
        where codpos = p_codpos;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TPOSTN');
        return false;
    end;
    end if;

--  check data in treqest2
    /*v_found    := 'N';
    v_check    := 'N';
    for i in c1 loop
      v_found    := 'Y';
      if nvl(i.qtyreq,0) > nvl(i.qtyact,0) then
        v_check  := 'Y';
        exit;
      end if;
    end loop;
    if v_found = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TREQEST2');
      return false;
    elsif v_check = 'N' then
      param_msg_error := get_error_msg_php('HR4502', global_v_lang);
      return false;
    end if;*/

    return true;

  end;

  function check_params return boolean as
    v_temp    varchar(1 char);
    v_codintview    treqest1.codintview%type;
  begin
    if p_codasapl = 'P' and p_dtestrt is null then
        param_msg_error := get_error_msg_php('HR2020', global_v_lang);
        return false;
    end if;

    if p_codasapl = 'F' and p_dtestrt is not null then
        param_msg_error := get_error_msg_php('HR2020', global_v_lang);
        return false;
    end if;
    begin
        select codintview
        into v_codintview
        from treqest1
        where numreqst = p_numreqst_emp
        and codintview = p_codempts;
    exception when no_data_found then
        v_codintview := null;
    end;

    if v_codintview is null then
        param_msg_error := get_error_msg_php('RC0039', global_v_lang);
        return false;
    end if;
    ---sann
    return true;
  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_count         number := 0;
    v_count_secur   number := 0;
    v_count_trequest2   number := 0;
    v_found         varchar(1 char);
    v_check         varchar(1 char);
    v_numreqst      varchar(40 char);
    v_codpos        varchar(40 char);
    v_codcomp       varchar(40 char);

    cursor c1 is
      select numreqst,codpos,codcomp, qtyreq, qtyact
        from treqest2
       where codcomp  like p_codcomp||'%'
         and codpos   = nvl(p_codpos,codpos)
         and numreqst = nvl(p_numreqst,numreqst)
         and flgrecut in ('I','O')
    order by numreqst desc;

    cursor c2 is
       select a.numreqst,a.codempid, a.codcompe, a.codpose, a.dteappoi, a.codempts,
              a.numscore, a.perscore, a.codasapl, a.dtestrt, a.dtereq
         from tappeinf a
        where a.numreqst = nvl(p_numreqst, a.numreqst)         -- 17/03/2023 14:24 Adisak redmine 4448#8909 : change param prefix from v_ => p_ (this from payload)
          and a.codcomp  like p_codcomp||'%'
          and a.codpos   = p_codpos
          and a.status   = 'A'
     order by a.codempid;

  begin
    insert into a(a) values (p_codcomp); commit;
    v_found    := 'N';
    v_check    := 'N';
    for i in c1 loop
      v_found    := 'Y';
      if nvl(i.qtyreq,0) > nvl(i.qtyact,0) then
        v_check    := 'Y';
        v_numreqst := i.numreqst;
        v_codpos   := i.codpos;
        v_codcomp  := i.codcomp;
        exit;
      end if;
    end loop;
    if v_found = 'N' then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TREQEST2');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    elsif v_check = 'N' then
      param_msg_error := get_error_msg_php('HR4502',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    /*for i in c2 loop
        if i.qtyact >= i.qtyreq then
            param_msg_error := get_error_msg_php('HR4502',global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
        v_count_trequest2 := v_count_trequest2+1;
        p_numreqst := i.numreqst;
        exit;
    end loop;
    if v_count_trequest2 = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TREQEST2');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;*/

    obj_rows := json_object_t();
    for i in c2 loop
        v_count := v_count + 1;
        if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
            v_count_secur := v_count_secur + 1;
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('numreqst', i.numreqst);
            obj_data.put('image', get_emp_img(i.codempid));
            obj_data.put('codempid', i.codempid);
            obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
            obj_data.put('codcompe', i.codcompe);
            obj_data.put('desc_codcomp', i.codcompe||' '||get_tcenter_name(i.codcompe, global_v_lang));
            obj_data.put('codpose',i.codpose);
            obj_data.put('desc_codpos',i.codpose||' '|| get_tpostn_name(i.codpose, global_v_lang));
            obj_data.put('dteintview', to_char(i.dteappoi, 'dd/mm/yyyy'));
            obj_data.put('intviewby', i.codempts);
            obj_data.put('grade', '');
            obj_data.put('graded', i.numscore);
            obj_data.put('score', i.perscore);
            obj_data.put('result', i.codasapl);
            obj_data.put('desc_result', get_tlistval_name('TCODASAPL',i.codasapl,global_v_lang));
            obj_data.put('dtereq', to_char(i.dtereq, 'dd/mm/yyyy'));
            obj_data.put('dtework', to_char(i.dtestrt, 'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    if v_count != 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    elsif v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPEINF');
    end if;

    if param_msg_error is null then
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  end gen_index;

  procedure update_tappeinf as
  begin
    update tappeinf
    set dteappoi = p_dteappoi,
        codempts = p_codempts,
        numscore = p_numscore,
        perscore = p_perscore,
        codasapl = p_codasapl,
        dtestrt = p_dtestrt,
        dtefoll = sysdate,
        coduser = global_v_coduser



    where codempid = p_query_codempid
      and dtereq = p_dtereq
--      and numreqst = p_numreqst
      and numreqst = p_numreqst_emp
      and codcompe = p_codcompe
--      and codcomp = p_codcomp
      and codpose = p_codpose
--      and codpos = p_codpos
      ;

  end update_tappeinf;

  procedure update_treqest1 as
  begin
    update treqest1
    set dterec = sysdate,
        coduser = global_v_coduser
    where numreqst = p_numreqst_emp;
--    where numreqst = p_numreqst;

  end update_treqest1;

  procedure update_treqest2 as
  begin
    update treqest2
    set dteintview = sysdate,
        coduser = global_v_coduser
--    where numreqst = p_numreqst
    where numreqst = p_numreqst_emp
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
        if check_params then
            update_tappeinf;
            update_treqest1;
            update_treqest2;
        else
            exit;
        end if;
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

        v_msg           clob;

        v_email         varchar(200);
        v_codappchse     treqest1.codappchse%type;

        v_numreqst      tappeinf.numreqst%type;
        v_codcomp       tappeinf.codcomp%type;
        v_codpos        tappeinf.codpos%type;
        v_codempid      tappeinf.codempid%type;
        v_dtereq        tappeinf.dtereq%type;

    begin

        v_subject  := get_label_name('HRRC5GEC1', global_v_lang, 140);
        v_codapp   := 'HRRC5GE';

        begin
            select codform into v_codform
            from tfwmailh
            where codapp = v_codapp;
        exception when no_data_found then
            v_codform  := 'HRRC5GE';
        end;

        v_numreqst  := hcm_util.get_string_t(data_obj, 'numreqst');
        v_codcomp   := hcm_util.get_string_t(data_obj, 'codcomp');
        v_codpos    := hcm_util.get_string_t(data_obj, 'codpos');
        v_codempid  := hcm_util.get_string_t(data_obj, 'codempid');
        v_dtereq    := to_date(hcm_util.get_string_t(data_obj, 'dtereq'),'dd/mm/yyyy');

        chk_flowmail.get_message(v_codapp, global_v_lang, v_msg_to, v_templete_to, v_func_appr);

        -- replace employee param
        begin
            select rowid into v_rowid
            from tappeinf
            where numreqst = v_numreqst
            and codcomp like v_codcomp||'%'
            and codpos  = v_codpos
            and codempid = v_codempid
            and dtereq = v_dtereq;
        exception when no_data_found then
            v_rowid := '';
        end;
        chk_flowmail.replace_text_frmmail(v_templete_to, 'TAPPEINF', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

        -- replace employee param email reciever param
        begin
            select rowid,codappchse  into v_rowid,v_codappchse
            from treqest1
            where numreqst = v_numreqst;
        exception when no_data_found then
            v_rowid := '';
            v_codappchse := '';
        end;
        chk_flowmail.replace_text_frmmail(v_templete_to, 'TREQEST1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

        -- replace sender
        begin
            select rowid into v_rowid
            from temploy1
            where codempid = global_v_codempid;
        exception when no_data_found then
            v_rowid := '';
        end;
        chk_flowmail.replace_text_frmmail(v_templete_to, 'TEMPLOY1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

        begin
            select email into v_email
            from temploy1
            where codempid = v_codappchse;
        exception when no_data_found then
            v_codappchse := '';
        end;

        v_error := chk_flowmail.send_mail_to_emp (v_codappchse, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, null,null,null, null);

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

END HRRC5GE;

/

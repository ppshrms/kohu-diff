--------------------------------------------------------
--  DDL for Package Body HRRC48X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC48X" AS

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
        p_codcomp         := hcm_util.get_string_t(data_obj,'p_codcomp');
        p_codemprc        := hcm_util.get_string_t(data_obj,'p_codemprc');
        p_dteempmtst      := to_date(hcm_util.get_string_t(data_obj,'p_dteempmtst'),'dd/mm/yyyy');
        p_dteempmten      := to_date(hcm_util.get_string_t(data_obj,'p_dteempmten'),'dd/mm/yyyy');

  end initial_params;

  function check_index return boolean as
    v_temp     varchar(1 char);
  begin
    if p_codcomp is not null then
--      check codcomp
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp || '%'
              and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
            return false;
        end;

--      check secur7
        if secur_main.secur7(p_codcomp, global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return false;
        end if;
    end if;

    if p_codemprc is not null then
--      check recruiter
        begin
            select 'X' into v_temp
            from temploy1
            where codempid = p_codemprc;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            return false;
        end;

--      check secur2
        if secur_main.secur2(p_codemprc,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return false;
        end if;
    end if;

--  check date
    if p_dteempmtst > p_dteempmten then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return false;
    end if;

    return true;

  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_salary        tapplcfm.amtincom1%type;
    v_codrej        tappfoll.codrej%type;
    v_count         number := 0;

    cursor c1 is
        select b.codcomp, b.numreqst, c.codpos, b.codemprc,
               c.qtyreq, a.numappl, a.amtincto,decode(global_v_lang,'101',a.namempe,'102',a.namempt,'103',a.namemp3,'104',a.namemp4,'105',a.namemp5) namemp
        from tapplinf a, treqest1 b, treqest2 c
        where a.numreqc = b.numreqst
          and c.numreqst = b.numreqst
          and a.codposc = c.codpos
          and b.codcomp like p_codcomp || '%'
          and b.codemprc =  nvl(p_codemprc , b.codemprc )
          and a.dteempmt between p_dteempmtst and p_dteempmten
          and statappl = '62'
        order by b.numreqst, c.codpos, a.numappl;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        if secur_main.secur7(i.codcomp,global_v_coduser) then
            v_row := v_row+1;
            v_count := v_count + 1;
            obj_data := json_object_t();
            obj_data.put('reqno', i.numreqst);
            obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
            obj_data.put('codempid', i.codemprc);
            obj_data.put('desc_codempid', get_temploy_name(i.codemprc, global_v_lang));
            obj_data.put('amount', i.qtyreq);
            obj_data.put('recutno', v_count);
            obj_data.put('codrecut', i.numappl);
            obj_data.put('desc_codrecut',i.namemp);
            begin
                select amtincom1 into v_salary
                from tapplcfm
                where numappl = i.numappl
                  and codcomp = i.codcomp
                  and codposl = i.codpos
                  and rownum = 1;
            exception when no_data_found then
                v_salary := 0;
            end;

            obj_data.put('salary', v_salary);
            obj_data.put('salaryreq', i.amtincto);
            obj_data.put('dtestrt', '');
            begin
                select codrej into v_codrej
                from tappfoll
                where numappl = i.numappl
                  and statappl = '62'
                  and numreqst = i.numreqst
                  and codpos = i.codpos;
            exception when no_data_found then
                v_codrej := '';
            end;

            obj_data.put('reareject', get_tcodec_name('TCODREJE',v_codrej,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
       end if;
    end loop;
    if  v_row = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPLINF');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    else
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end if;
  end gen_index;

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

    procedure send_mail_a as
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

        v_numreqst      tappeinf.numreqst%type;
        v_codcomp       tappeinf.codcomp%type;
        v_codpos        tappeinf.codpos%type;
        v_codempid      tappeinf.codempid%type;
        v_dtereq        tappeinf.dtereq%type;

    cursor c1 is
        select b.codemprq, b.rowid treqest1_id, a.rowid tapplinf_id
        from tapplinf a, treqest1 b, treqest2 c
        where a.numreqc = b.numreqst
          and c.numreqst = b.numreqst
          and a.codposc = c.codpos
          and b.codcomp like p_codcomp || '%'
          and b.codemprc =  nvl(p_codemprc , b.codemprc )
          and a.dteempmt between p_dteempmtst and p_dteempmten
          and statappl = '62'
        order by b.numreqst, c.codpos, a.numappl;

    begin

        v_subject  := get_label_name('HRRC48X', global_v_lang, 10);
        v_codapp   := 'HRRC48X';

        begin
            select codform into v_codform
            from tfwmailh
            where codapp = v_codapp;
        exception when no_data_found then
            v_codform  := 'HRRC48X';
        end;
        for i in c1 loop
            chk_flowmail.get_message(v_codapp, global_v_lang, v_msg_to, v_templete_to, v_func_appr);
            -- replace employee param
            chk_flowmail.replace_text_frmmail(v_templete_to, 'TAPPLINF', i.tapplinf_id, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

            -- replace employee param email reciever param
            chk_flowmail.replace_text_frmmail(v_templete_to, 'TREQEST1', i.treqest1_id, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

            -- replace sender
            begin
                select rowid into v_rowid
                from temploy1
                where codempid = global_v_codempid;
            exception when no_data_found then
                v_rowid := '';
            end;
            chk_flowmail.replace_text_frmmail(v_templete_to, 'TEMPLOY1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');
            v_error := chk_flowmail.send_mail_to_emp (i.codemprq, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, null,null,null, null);
        end loop;
    end send_mail_a;

  procedure send_email(json_str_input in clob, json_str_output out clob) AS

    begin
        initial_current_user_value(json_str_input);
        initial_params(json_object_t(json_str_input));
        send_mail_a;
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

END HRRC48X;

/

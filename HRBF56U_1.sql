--------------------------------------------------------
--  DDL for Package Body HRBF56U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF56U" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index AS
    v_codcomp           temploy1.codcomp%type;
  begin
    if p_codcomp is not null then
      begin
        select codcompy
          into v_codcomp
          from tcenter
         where codcomp = hcm_util.get_codcomp_level(p_codcomp, null, null, 'Y');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_found             boolean := false;
    v_check             varchar2(100 char);
    p_approvno          tloaninf.approvno%type := 1;

    cursor c1 is
     select numcont, codempid, dteappr, codappr, staappr, amtlon, codlon,
            dtelonst, dtelonen, codreq, approvno
       from tloaninf
      where codcomp like p_codcomp || '%'
        and staappr in ('P', 'A')
      order by numcont;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      if param_msg_error is null then
        v_found     := true;
        p_approvno  := nvl(i.approvno, 0) + 1;
        if chk_flowmail.check_approve('HRBF53E', i.codempid, p_approvno, global_v_codempid, null, null, v_check) then
          v_rcnt      := v_rcnt + 1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('numcont', i.numcont);
          obj_data.put('codempid', i.codempid);
          obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
          obj_data.put('dteappr', to_char(i.dteappr, 'DD/MM/YYYY'));
          obj_data.put('staappr', i.staappr);
          obj_data.put('desc_staappr', get_tlistval_name('ESSTAREQ', i.staappr, global_v_lang));
          obj_data.put('amtlon', i.amtlon);
          obj_data.put('codlon', i.codlon);
          obj_data.put('desc_codlon', get_ttyploan_name(i.codlon, global_v_lang));
          obj_data.put('dtelonst', to_char(i.dtelonst, 'DD/MM/YYYY'));
          obj_data.put('dtelonen', to_char(i.dtelonen, 'DD/MM/YYYY'));
          obj_data.put('codreq', i.codreq);
          obj_data.put('approvno', i.approvno);
          obj_data.put('codappr', i.codappr);

          obj_rows.put(to_char(v_rcnt - 1), obj_data);
        else
          if v_check = 'HR2010' then
            param_msg_error := get_error_msg_php(v_check, global_v_lang, 'tfwmailc');
            exit;
          end if;
        end if;
      end if;
    end loop;
    if v_found then
      if param_msg_error is null then
        if obj_rows.get_size > 0 then
          json_str_output := obj_rows.to_clob;
        else
          param_msg_error := get_error_msg_php('HR3008', global_v_lang);
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;
      else
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tloaninf');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;

  procedure get_popup (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_popup;

  procedure gen_popup (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    obj_params          json_object_t;
    v_rcnt              number := 0;
    v_numcont           tapploan.numcont%type;
    v_codempid          tapploan.codempid%type;
    v_approvno          tapploan.approvno%type;

    cursor c1 is
     select numcont, approvno, codempid, codappr, dteappr, staappr, remark
       from tapploan
      where numcont  = v_numcont
        and codempid = v_codempid
      order by numcont, approvno desc;
  begin
    obj_rows    := json_object_t();
    for k in 0 .. json_params.get_size - 1 loop
      obj_params            := hcm_util.get_json_t(json_params, to_char(k));
      v_numcont             := hcm_util.get_string_t(obj_params, 'numcont');
      v_codempid            := hcm_util.get_string_t(obj_params, 'codempid');
      begin
        select nvl(max(approvno), 0) + 1
          into v_approvno
          from tapploan
         where numcont  = v_numcont
           and codempid = v_codempid;
      exception when no_data_found then
        v_approvno        := 1;
      end;
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('disable', 'N');
      obj_data.put('numcont', v_numcont);
      obj_data.put('approvno', v_approvno);
      obj_data.put('codempid', v_codempid);
      obj_data.put('codappr', global_v_codempid);
      obj_data.put('dteappr', to_char(sysdate, 'DD/MM/YYYY'));
      obj_data.put('staappr', 'Y');
      obj_data.put('remark', '');

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
      for i in c1 loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('disable', 'Y');
        obj_data.put('numcont', i.numcont);
        obj_data.put('approvno', i.approvno);
        obj_data.put('codempid', i.codempid);
        obj_data.put('codappr', i.codappr);
        obj_data.put('dteappr', to_char(i.dteappr, 'DD/MM/YYYY'));
        obj_data.put('staappr', i.staappr);
        obj_data.put('remark', i.remark);

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_popup;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_params          json_object_t;
    v_numcont           tapploan.numcont%type;
    v_codempid          tapploan.codempid%type;
    v_approvno          tapploan.approvno%type;
    v_codappr           tapploan.codappr%type;
    v_dteappr           tapploan.dteappr%type;
    v_staappr           tapploan.staappr%type;
    v_remark            tapploan.remark%type;
    b_staappr           tloaninf.staappr%type := 'A';
    v_check             varchar2(100 char);
    v_flgcheck          boolean := false;
    v_rcnt              number := 0;
    v_codlon            tloaninf.codlon%type;
    v_dtelonst          tloaninf.dtelonst%type;
    v_amtlon            tloaninf.amtlon%type;
    v_excel_filename    varchar2(1000 char);
    v_filepath          varchar2(1000 char);
    v_column            varchar2(1000 char);
    v_labels            varchar2(1000 char);
    v_msg_to            clob;
    v_template_to       clob;
    v_func_appr         tfwmailh.codappap%type;
    v_rowidmail         rowid;
    v_codfrm_to         tfwmailh.codform%type;
		v_error             varchar2(4000 char);
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      for k in 0 .. json_params.get_size - 1 loop
        obj_params            := hcm_util.get_json_t(json_params, to_char(k));
        v_numcont             := hcm_util.get_string_t(obj_params, 'numcont');
        v_codempid            := hcm_util.get_string_t(obj_params, 'codempid');
        v_approvno            := to_number(hcm_util.get_number_t(obj_params, 'approvno'));
        v_codappr             := hcm_util.get_string_t(obj_params, 'codappr');
        v_dteappr             := to_date(hcm_util.get_string_t(obj_params, 'dteappr'), 'DD/MM/YYYY');
        v_staappr             := hcm_util.get_string_t(obj_params, 'staappr');
        v_remark              := hcm_util.get_string_t(obj_params, 'remark');
        if v_staappr = 'Y' then
          v_flgcheck := chk_flowmail.check_approve('HRBF53E', v_codempid, v_approvno, global_v_codempid, null, null, v_check);
          if v_check = 'Y' then
            b_staappr := 'Y';
          end if;
        else
          b_staappr             := v_staappr;
        end if;
        if param_msg_error is null then
          begin
            insert into tapploan
                   (numcont, codempid, approvno, codappr, dteappr, staappr, remark, dtecreate, codcreate, coduser)
            values (v_numcont, v_codempid, v_approvno, v_codappr, v_dteappr, v_staappr, v_remark, sysdate, global_v_coduser, global_v_coduser);
            begin
              update tloaninf
                 set staappr  = b_staappr,
                     approvno = v_approvno,
                     remarkap = v_remark,
                     dteappr  = v_dteappr,
                     codappr  = v_codappr
               where numcont  = v_numcont;
            exception when others then
              null;
            end;
            begin
              delete from ttemprpt
               where codempid = global_v_codempid
                 and codapp   = 'HRBF56U';
            exception when others then
              null;
            end;
            begin
              delete from ttempprm
               where codempid = global_v_codempid
                 and codapp   = 'HRBF56U';
            exception when others then
              null;
            end;
            v_rcnt       := v_rcnt + 1;
            begin
              select codlon, dtelonst, amtlon, rowid
                into v_codlon, v_dtelonst, v_amtlon, v_rowidmail
                from tloaninf
              where numcont = v_numcont;
            exception when no_data_found then
              null;
            end;
-- fix issue Phase1 #3596 user18  20210408
--            begin
--              insert into ttemprpt (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6)
--                   values (global_v_codempid, 'HRBF56U', v_rcnt, v_numcont, v_codempid, get_temploy_name(v_codempid, global_v_lang), get_ttyploan_name(v_codlon, global_v_lang), to_char(v_amtlon, 'fm99,999,990.90'), to_char(v_dtelonst, 'DD/MM/YYYY'));
--            exception when dup_val_on_index then
--              param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'ttemprpt');
--            end;
--            begin
--              insert into ttempprm (codempid, codapp,namrep,pdate,ppage,
--                                    label1, label2, label3, label4, label5, label6)
--                  values (global_v_codempid, 'HRBF56U','namrep',to_char(sysdate,'dd/mm/yyyy'),'page1',
--                          get_label_name('HRBF56U', global_v_lang, 40), get_label_name('HRBF56U', global_v_lang, 60), get_label_name('HRBF56U', global_v_lang, 70), get_label_name('HRBF56U', global_v_lang, 80), get_label_name('HRBF56U', global_v_lang, 160), get_label_name('HRBF56U', global_v_lang, 30));
--            exception when dup_val_on_index then
--              param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'ttempprm');
--            end;
            if param_msg_error is null then
--              v_excel_filename      := v_codempid || '_excelmail';
--              v_filepath            := get_tsetup_value('PATHEXCEL') || v_excel_filename;
--              v_column              := 'item1, item2, item3, item4, item5, item6';
--              v_labels              := 'label1, label2, label3, label4, label5, label6';
--              excel_mail(v_column, v_labels, null, global_v_codempid, 'HRBF56U', v_filepath);
              begin
                v_error := chk_flowmail.send_mail_for_approve('HRBF53E', v_codempid, global_v_codempid, global_v_coduser, null, 'HRBF56U', 170, 'U', b_staappr, v_approvno + 1, null, null,'TLOANINF',v_rowidmail, '1', null);
              exception when others then
                v_error := '2403';
              end;
            end if;
          exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tapploan');
          end;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      if v_error is null or v_error = '2401' then
        v_error := '2403';
      end if;
      param_msg_error := get_error_msg_php('HR' || v_error, global_v_lang);
      if v_error in ('2403','2402') then
        json_str_output := get_response_message(200, param_msg_error, global_v_lang);
      else
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
      return;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;
end HRBF56U;

/

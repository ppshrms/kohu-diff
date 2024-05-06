--------------------------------------------------------
--  DDL for Package Body HRRC43U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC43U" AS
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
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DD/MM/YYYY');
    p_codpos            := hcm_util.get_string_t(json_obj, 'p_codpos');
    -- save detail
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy          tcenter.codcompy%type;
  begin
    if p_codcomp is not null then
      begin
        select codcompy
          into v_codcompy
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
  end check_index;

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
    p_approvno          temploy1.approvno%type := 1;
    v_codrej            tappfoll.codrej%type;

    cursor c1 is
      select codempid, codcomp, codpos, dteempmt, staemp, approvno, numappl
        from temploy1
       where codcomp  like p_codcomp || '%'
         and dteempmt between p_dtestrt and p_dteend
         and staemp   = '0'
         and staappr  in ('P', 'A')
       order by codempid;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      if param_msg_error is null then
        v_found     := true;
        p_approvno  := nvl(i.approvno, 0) + 1;
        if chk_flowmail.check_approve('HRRC41E', i.codempid, p_approvno, global_v_codempid, null, null, v_check) then
          v_rcnt              := v_rcnt + 1;
          obj_data            := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('image', get_emp_img(i.codempid));
          obj_data.put('codempid', i.codempid);
          obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
          obj_data.put('codcomp', i.codcomp);
          obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
          obj_data.put('codpos', i.codpos);
          obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
          obj_data.put('dteempmt', to_char(i.dteempmt, 'DD/MM/YYYY'));
          obj_data.put('staemp', i.staemp);
          obj_data.put('desc_staemp', get_tlistval_name('NAMSTATA', i.staemp, global_v_lang));
          v_codrej            := null;
          begin
            select codrej
              into v_codrej
              from tappfoll
             where numappl = i.numappl
               and codrej  is not null
               and dtefoll = (select max(dtefoll)
                                from tappfoll
                               where numappl = i.numappl
                                 and codrej  is not null);
          exception when no_data_found then
            null;
          end;
          obj_data.put('codrej', v_codrej);
          obj_data.put('desc_codrej', get_tcodec_name('TCODREJE', v_codrej, global_v_lang));

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
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;

  procedure check_detail is
  begin
    null;
  end check_detail;

  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    obj_params          json_object_t;
    v_rcnt              number := 0;
    v_codempid          tapemploy.codempid%type;
    v_approvno          tapemploy.approvno%type;

    cursor c1 is
     select codempid, approvno, codappr, dteappr, staappr, remark
       from tapemploy
      where codempid = v_codempid
      order by approvno desc;
  begin
    obj_rows    := json_object_t();
    for k in 0 .. json_params.get_size - 1 loop
      obj_params            := hcm_util.get_json_t(json_params, to_char(k));
      v_codempid            := hcm_util.get_string_t(obj_params, 'codempid');
      p_codcomp             := hcm_util.get_string_t(obj_params, 'codcomp');
      p_codpos              := hcm_util.get_string_t(obj_params, 'codpos');
      begin
        select nvl(max(approvno), 0) + 1
          into v_approvno
          from tapemploy
         where codempid = v_codempid;
      exception when no_data_found then
        v_approvno        := 1;
      end;
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('disable', 'N');
      obj_data.put('codempid', v_codempid);
      obj_data.put('codcomp', p_codcomp);
      obj_data.put('codpos', p_codpos);
      obj_data.put('approvno', v_approvno);
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
  end gen_detail;

  procedure get_detail_table (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail_table(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail_table;

  procedure gen_detail_table (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select numcolla
        from tnempaset
       where codcomp = p_codcomp
         and codpos  = p_codpos
       order by numcolla;
  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      obj_data            := json_object_t();
      v_rcnt              := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('numcolla', i.numcolla);
      obj_data.put('descolla', get_tasetinf_name(i.numcolla, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_detail_table;

  function get_numappl (v_codempid temploy1.codempid%type) return temploy1.numappl%type is
    v_numappl             temploy1.numappl%type;
  begin
    begin
      select numappl
        into v_numappl
        from temploy1
       where codempid = v_codempid;
    exception when no_data_found then
      null;
    end;
    return v_numappl;
  end get_numappl;

  procedure gen_users (v_codempid temploy1.codempid%type, v_numlvl temploy1.numlvl%type, v_codcomp temploy1.codcomp%type, v_codpswd_hash users.password%type) as
    tusrprof_codempid             tusrprof.codempid%type;
    tusrprof_coduser              tusrprof.coduser%type;
    tusrprof_codpswd              tusrprof.codpswd%type;
    tusrprof_userdomain           tusrprof.userdomain%type;
    tusrprof_flgact               tusrprof.flgact%type;
    tusrprof_flgauth              tusrprof.flgauth%type;
    tusrprof_codsecu              tusrprof.codsecu%type;
    tusrprof_timepswd             tusrprof.timepswd%type;
    tusrprof_typeauth             tusrprof.typeauth%type;
    tusrprof_typeuser             tusrprof.typeuser%type;
    tusrprof_numlvlst             tusrprof.numlvlst%type;
    tusrprof_numlvlen             tusrprof.numlvlen%type;
    tusrprof_numlvlsalst          tusrprof.numlvlsalst%type;
    tusrprof_numlvlsalen          tusrprof.numlvlsalen%type;
    tusrprof_flgchgpass           tusrprof.numlvlsalen%type;
    v_dteempmt                    temploy1.dteempmt%type;
    v_codempmt                    temploy1.codempmt%type;
    v_numreqst                    temploy1.numreqst%type;
    v_codpos                      temploy1.codpos%type;
    v_codjob                      temploy1.codjob%type;
    v_codbrlc                     temploy1.codbrlc%type;
    v_codcalen                    temploy1.codcalen%type;
    v_flgatten                    temploy1.flgatten%type;
    v_qtydatrq                    temploy1.qtydatrq%type;
    v_dteduepr                    temploy1.dteduepr%type;
    v_staemp                      temploy1.staemp%type;
    v_codedlv                     temploy1.codedlv%type;
    v_typemp                      temploy1.typemp%type;
    v_typpayroll                  temploy1.typpayroll%type;
    v_jobgrade                    temploy1.jobgrade%type;
    v_codgrpgl                    temploy1.codgrpgl%type;
    v_amtincom1                   temploy3.amtincom1%type;
    v_amtincom2                   temploy3.amtincom2%type;
    v_amtincom3                   temploy3.amtincom3%type;
    v_amtincom4                   temploy3.amtincom4%type;
    v_amtincom5                   temploy3.amtincom5%type;
    v_amtincom6                   temploy3.amtincom6%type;
    v_amtincom7                   temploy3.amtincom7%type;
    v_amtincom8                   temploy3.amtincom8%type;
    v_amtincom9                   temploy3.amtincom9%type;
    v_amtincom10                  temploy3.amtincom10%type;
    v_codcurr                     temploy3.codcurr%type;
    v_amtothr                     temploy3.amtothr%type;
  begin
    if param_msg_error is null then
      tusrprof_codempid             := v_codempid;
      tusrprof_coduser              := v_codempid;
      tusrprof_codpswd              := v_codempid;
      tusrprof_userdomain           := null;
      tusrprof_flgact               := '1';
      tusrprof_flgauth              := '2';
      tusrprof_codsecu              := null;
      tusrprof_timepswd             := 0;
      tusrprof_typeauth             := '2';
      tusrprof_typeuser             := '2';
      tusrprof_numlvlst             := v_numlvl;
      tusrprof_numlvlen             := v_numlvl;
      tusrprof_numlvlsalst          := 0;
      tusrprof_numlvlsalen          := 0;
      tusrprof_flgchgpass           := 'N';
      begin
        select dteempmt, codempmt, numreqst, codpos, codjob, codbrlc,
               codcalen, flgatten, qtydatrq, dteduepr, staemp,
               codedlv, typemp, typpayroll, jobgrade, codgrpgl
          into v_dteempmt, v_codempmt, v_numreqst, v_codpos, v_codjob, v_codbrlc,
               v_codcalen, v_flgatten, v_qtydatrq, v_dteduepr, v_staemp,
               v_codedlv, v_typemp, v_typpayroll, v_jobgrade, v_codgrpgl
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      begin
        select amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
               amtincom6, amtincom7, amtincom8, amtincom9, amtincom10,
               codcurr, amtothr
          into v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
               v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10,
               v_codcurr, v_amtothr
          from temploy3
         where codempid = v_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      begin
        insert into tusrprof
              (
                coduser, codempid, userdomain,
                flgact, codpswd, flgauth,
                codsecu, timepswd, typeauth,
                numlvlst, numlvlen, numlvlsalst, numlvlsalen,
                typeuser, dtecreate, usrcreate, flgchgpass, coduser2,
                flgalter, flgtranl
              )
        values
              (
                tusrprof_coduser, tusrprof_codempid, tusrprof_userdomain,
                tusrprof_flgact, pwdenc(tusrprof_codpswd, tusrprof_coduser, v_chken), tusrprof_flgauth,
                tusrprof_codsecu, tusrprof_timepswd, tusrprof_typeauth,
                pwdenc(tusrprof_numlvlst, tusrprof_coduser, v_chken), pwdenc(tusrprof_numlvlen, tusrprof_coduser, v_chken), pwdenc(tusrprof_numlvlsalst, tusrprof_coduser, v_chken), pwdenc(tusrprof_numlvlsalen, tusrprof_coduser, v_chken),
                tusrprof_typeuser, sysdate, global_v_coduser, tusrprof_flgchgpass, global_v_coduser,
                'N', 'N'
              );
      exception when dup_val_on_index then
        update tusrprof
           set codempid    = tusrprof_codempid,
               userdomain  = tusrprof_userdomain,
               codpswd     = pwdenc(tusrprof_codpswd, tusrprof_coduser, v_chken),
               flgact      = tusrprof_flgact,
               flgauth     = tusrprof_flgauth,
               codsecu     = tusrprof_codsecu,
               timepswd    = tusrprof_timepswd,
               typeauth    = tusrprof_typeauth,
               typeuser    = tusrprof_typeuser,
               numlvlst    = pwdenc(tusrprof_numlvlst, tusrprof_coduser, v_chken),
               numlvlen    = pwdenc(tusrprof_numlvlen, tusrprof_coduser, v_chken),
               numlvlsalst = pwdenc(tusrprof_numlvlsalst, tusrprof_coduser, v_chken),
               numlvlsalen = pwdenc(tusrprof_numlvlsalen, tusrprof_coduser, v_chken),
               dtercupd    = sysdate,
               rcupdid     = global_v_coduser,
               dteupd      = sysdate,
               flgchgpass  = tusrprof_flgchgpass,
               flgalter    = 'N',
               flgtranl    = 'N',
               coduser2    = global_v_coduser
         where coduser     = tusrprof_coduser;
      end;
      begin
        insert into ttnewemp
               (codempid, dteempmt, codempmt, numreqst, codcomp, codpos, codjob, numlvl, codbrlc,
                codcalen, codshift, flgatten, flgcrinc, qtydatrq, dteduepr, staemp,
                amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
                amtincom6, amtincom7, amtincom8, amtincom9, amtincom10,
                amtothr, flgrp, flgupd, codedlv, typemp, typpayroll, codcurr,
                jobgrade, codgrpgl, dtecreate, codcreate, dteupd, coduser)
        values (v_codempid, v_dteempmt, v_codempmt, v_numreqst, v_codcomp, v_codpos, v_codjob, v_numlvl, v_codbrlc,
                v_codcalen, null, v_flgatten, null, v_qtydatrq, v_dteduepr, v_staemp,
                v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10,
                v_amtothr, null, null, v_codedlv, v_typemp, v_typpayroll, v_codcurr,
                v_jobgrade, v_codgrpgl, sysdate, global_v_coduser, sysdate, global_v_coduser);
      exception when dup_val_on_index then
        update ttnewemp
           set dteempmt   = v_dteempmt,
               codempmt   = v_codempmt,
               numreqst   = v_numreqst,
               codcomp    = v_codcomp,
               codpos     = v_codpos,
               codjob     = v_codjob,
               numlvl     = v_numlvl,
               codbrlc    = v_codbrlc,
               codcalen   = v_codcalen,
               flgatten   = v_flgatten,
               qtydatrq   = v_qtydatrq,
               dteduepr   = v_dteduepr,
               staemp     = v_staemp,
               amtincom1  = v_amtincom1,
               amtincom2  = v_amtincom2,
               amtincom3  = v_amtincom3,
               amtincom4  = v_amtincom4,
               amtincom5  = v_amtincom5,
               amtincom6  = v_amtincom6,
               amtincom7  = v_amtincom7,
               amtincom8  = v_amtincom8,
               amtincom9  = v_amtincom9,
               amtincom10 = v_amtincom10,
               amtothr    = v_amtothr,
               codedlv    = v_codedlv,
               typemp     = v_typemp,
               typpayroll = v_typpayroll,
               codcurr    = v_codcurr,
               jobgrade   = v_jobgrade,
               codgrpgl   = v_codgrpgl,
               dteupd     = sysdate,
               coduser    = global_v_coduser
         where codempid = v_codempid;
      end;
      -- users
      begin
        insert into users (name, email, password, is_client, created_at, updated_at, username, codempid)
        values (tusrprof_coduser, tusrprof_coduser, v_codpswd_hash, '1', sysdate, sysdate, tusrprof_coduser, tusrprof_codempid);
      exception when dup_val_on_index then
        update users
           set codempid   = tusrprof_codempid,
               password   = v_codpswd_hash,
               updated_at = sysdate
         where email      = tusrprof_coduser;
      end;
      begin
        insert into tusrcom (coduser, codcomp, dteupd, rcupdid, codcreate, dtecreate)
        values (tusrprof_coduser, v_codcomp, sysdate, global_v_coduser, global_v_coduser, sysdate);
      exception when dup_val_on_index then
        null;
      end;
      begin
        insert
          into tusrproc (coduser, codproc, flgauth, dteupd, rcupdid, codcreate)
        values (tusrprof_coduser, 'N.ES', '1', sysdate, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        update tusrproc
           set flgauth = '1',
               dteupd  = sysdate,
               rcupdid = global_v_coduser
         where coduser = tusrprof_coduser
           and codproc = 'N.ES';
      end;
    end if;
  end gen_users;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_params          json_object_t;
    v_dteempmt          temploy1.dteempmt%type;
    v_staemp            temploy1.staemp%type;
    v_numlvl            temploy1.numlvl%type;
    v_codcomp           temploy1.codcomp%type;
    v_codempid          tapemploy.codempid%type;
    v_approvno          tapemploy.approvno%type;
    v_codappr           tapemploy.codappr%type;
    v_dteappr           tapemploy.dteappr%type;
    v_staappr           tapemploy.staappr%type;
    v_remark            tapemploy.remark%type;
    b_staappr           tapemploy.staappr%type := 'A';
    v_numappl           tapplinf.numappl%type;
    v_check             varchar2(100 char);
    v_flgcheck          boolean := false;
    v_rcnt              number := 0;
    v_msg_to            clob;
    v_template_to       clob;
    v_func_appr         tfwmailh.codappap%type;
    v_rowidmail         rowid;
    v_codfrm_to         tfwmailh.codform%type;
    v_error             varchar2(4000 char);
    v_codpswd_hash      users.password%type;
    v_statappl          tapplinf.statappl%type;

    v_subject           varchar2(4000 char); -- softberry || 25/04/2023 || #8797
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      for k in 0 .. json_params.get_size - 1 loop
        obj_params            := hcm_util.get_json_t(json_params, to_char(k));
        v_codempid            := hcm_util.get_string_t(obj_params, 'codempid');
        v_approvno            := to_number(hcm_util.get_number_t(obj_params, 'approvno'));
        v_codappr             := hcm_util.get_string_t(obj_params, 'codappr');
        v_dteappr             := to_date(hcm_util.get_string_t(obj_params, 'dteappr'), 'DD/MM/YYYY');
        v_staappr             := hcm_util.get_string_t(obj_params, 'staappr');
        v_remark              := hcm_util.get_string_t(obj_params, 'remark');
        v_codpswd_hash        := hcm_util.get_string_t(obj_params, 'codpswd_hash');
        v_numappl             := get_numappl(v_codempid);
        v_flgcheck := chk_flowmail.check_approve('HRRC41E', v_codempid, v_approvno, global_v_codempid, null, null, v_check);
        if v_staappr = 'Y' then
          if v_check = 'Y' then
            b_staappr := 'Y';
          end if;
        else
          b_staappr             := v_staappr;
        end if;
        if param_msg_error is null then
          begin
            insert into tapemploy
                   (codempid, approvno, codappr, dteappr, staappr, remark, coduser, dteupd)
            values (v_codempid, v_approvno, v_codappr, v_dteappr, v_staappr, v_remark, global_v_coduser, sysdate);
            if v_check = 'Y' then
              if b_staappr = 'Y' then
                begin
                  select dteempmt, numlvl, codcomp
                    into v_dteempmt, v_numlvl, v_codcomp
                    from temploy1
                   where codempid = v_codempid;
                exception when no_data_found then
                  param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
                end;
                if trunc(v_dteempmt) >= trunc(sysdate) then
                  v_staemp := '1';
                end if;
                if param_msg_error is null then
                  gen_users(v_codempid, v_numlvl, v_codcomp, v_codpswd_hash);
                end if;
                v_statappl        := '61';
              else
                v_statappl        := '63';
                b_staappr         := 'N';
              end if;
              begin
                update tapplinf
                   set statappl = v_statappl,
                       dteconff = sysdate,
                       codconf  = global_v_codempid,
                       coduser  = global_v_coduser,
                       dteupd   = sysdate
                 where numappl  = v_numappl;
              exception when others then
                null;
              end;
            end if;
            ------------------------------------------------------------
            begin
              update temploy1
                 set staappr  = b_staappr,
                     staemp   = nvl(v_staemp, staemp),
                     approvno = v_approvno,
                     remarkap = v_remark,
                     dteappr  = v_dteappr,
                     codappr  = v_codappr
               where codempid = v_codempid;
            exception when others then
              null;
            end;
          exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tapemploy');
          end;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
--<< softberry || 25/04/2023 || #8797
    /*
      begin
        select rowid
          into v_rowidmail
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        null;
      end;
    */
-->> softberry || 25/04/2023 || #8797

--<< softberry || 25/04/2023 || #8797
      begin
        select rowid
          into v_rowidmail
          from tapplinf
         where numappl = v_numappl;
      exception when no_data_found then
        null;
      end;      
      v_codfrm_to := 'HRRC43UCC'; 
        begin
          select decode(global_v_lang,'101',descode,
                               '102',descodt,
                               '103',descod3,
                               '104',descod4,
                               '105',descod5,
                               '101',descode) msg
            into v_subject
            from tfrmmail
           where codform = v_codfrm_to;
        exception when others then
          v_subject := null;
        end ;      
-->> softberry || 25/04/2023 || #8797
      chk_flowmail.get_message('HRRC43U', global_v_lang, v_msg_to, v_template_to, v_func_appr);
      chk_flowmail.replace_text_frmmail(v_template_to, 'tapplinf', v_rowidmail, v_subject, v_codfrm_to, null, v_func_appr, global_v_coduser, global_v_lang, v_msg_to); -- softberry || 25/04/2023 || #8797 || chk_flowmail.replace_text_frmmail(v_template_to, 'temploy1', v_rowidmail, get_label_name('HRRC43U1', global_v_lang, 130), v_codfrm_to, null, v_func_appr, global_v_coduser, global_v_lang, v_msg_to);
      v_error := chk_flowmail.send_mail_to_approve ('HRRC43U' , v_codempid, global_v_coduser, v_msg_to, null, v_subject, 'U', b_staappr, global_v_lang, v_approvno, null, null); -- softberry || 25/04/2023 || #8797 || v_error := chk_flowmail.send_mail_to_approve ('HRRC43U' , v_codempid, global_v_coduser, v_msg_to, null, get_label_name('HRRC43U1', global_v_lang, 130), 'U', b_staappr, global_v_lang, v_approvno, null, null);

      commit;
      if v_error is null then
        v_error := '2401';
      end if;
      param_msg_error := get_error_msg_php('HR' || v_error, global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;
end HRRC43U;

/

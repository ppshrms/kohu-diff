--------------------------------------------------------
--  DDL for Package Body HRPY5ZB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5ZB" as

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    old_global_v_lang   := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_numperiod         := hcm_util.get_string_t(json_obj,'p_numperiod');
    p_dtemthpay         := hcm_util.get_string_t(json_obj,'p_dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj,'p_dteyrepay');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_numlvlst          := to_number(hcm_util.get_string_t(json_obj,'p_numlvlst'));
    p_numlvlen          := to_number(hcm_util.get_string_t(json_obj,'p_numlvlen'));
    p_flgsend           := hcm_util.get_string_t(json_obj,'p_flgsend');
    p_flgslip           := hcm_util.get_string_t(json_obj,'p_flgslip');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_typpayroll    tcodtypy.codcodec%type;
    v_codempid      temploy1.codempid%type;
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_typpayroll is not null then
      begin
        select codcodec
          into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodtypy');
        return;
      end;
    end if;

    if p_numlvlst is not null then
      if p_numlvlen is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_numlvlen');
      end if;
    end if;

    if p_numlvlen is not null then
      if p_numlvlst is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_numlvlst');
      end if;
    end if;

    if p_numlvlst is not null and p_numlvlen is not null then
      if p_numlvlst > p_numlvlen then
        param_msg_error := get_error_msg_php('HR2020', global_v_lang, 'p_numlvlst');
      end if;
    end if;

    if p_codempid is not null then
      begin
        select codempid into v_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
  end check_index;

  procedure replace_text(p_msg out varchar2,p_filename in varchar2,p_format in varchar2,p_codempid in varchar2) is
    data_file      varchar2(7000 char);
    v_msg          varchar2(7000 char);
    crlf           varchar2(2 char):= chr( 13 ) || chr( 10 );
    v_coduser      tusrprof.coduser%type;
    v_lang_codempid varchar2(10 char) := '102'; -- KOHU | 000311-J-Jaturong-Dev | 28/03/2024 | check year depends on lang
    v_dteyrepay     varchar2(10 char); -- KOHU | 000311-J-Jaturong-Dev | 28/03/2024 | check year depends on lang
    v_dtepaymt      varchar2(100 char); -- KOHU | 000311-J-Jaturong-Dev | 28/03/2024 | check year depends on lang
  begin
    begin
      select  decode(global_v_lang,'101',messagee,
                                    '102',messaget,
                                    '103',message3,
                                    '104',message4,
                                    '105',message5,
                                    '101',messagee) msg into v_msg
      from tfrmmail
      where codform = 'HRPY5ZB';
    exception when no_data_found then
      v_msg := null;
    end;

    -------------------------------------------------------
    data_file   := v_msg;
    data_file   := replace(data_file,'<param-05>','<param-05><br><br><br><param-06>');
    data_file   := replace(data_file, '[PARAM-TO]', get_temploy_name(p_codempid, global_v_lang)); -- Adisak redmine#8354 21/08/2023 10:28 || add replace parameter PARAM-TO with codempid

    -- Replace Text
    if data_file like ('%<param-01>%') then
       data_file := replace(data_file ,'<param-01>',p_numperiod );
    end if;

    if data_file like ('%<param-02>%') then
       data_file  := replace(data_file  ,'<param-02>',get_tlistval_name('DTEMTHPAY',p_dtemthpay,global_v_lang));
    end if;

     --<< KOHU | 000311-J-Jaturong-Dev | 28/03/2024 | check year depends on lang
    v_lang_codempid  := chk_flowmail.get_emp_mail_lang(p_codempid, '102');
    v_dteyrepay := p_dteyrepay;
    v_dtepaymt  := to_char(p_dtepaymt,'dd/mm/yyyy');
    if v_lang_codempid = '102' then
        v_dteyrepay := hcm_util.get_year_buddhist_era(p_dteyrepay);
        v_dtepaymt  := hcm_util.get_date_buddhist_era(p_dtepaymt);
    end if;
    
    if data_file like ('%<param-03>%') then
--        data_file  := replace(data_file  ,'<param-03>',hcm_util.get_year_buddhist_era(p_dteyrepay));
        data_file  := replace(data_file  ,'<param-03>',v_dteyrepay);
    end if;

    if data_file like ('%<param-04>%') then
--        data_file  := replace(data_file  ,'<param-04>',hcm_util.get_date_buddhist_era(p_dtepaymt));
        data_file  := replace(data_file  ,'<param-04>',v_dtepaymt);
    end if;

    if data_file like ('%<param-05>%') then
       if p_format = 'TUSRPROF' then
        begin
          select coduser
            into v_coduser
            from tusrprof
           where codempid = p_codempid
             and rownum = 1;
        exception when no_data_found then
          v_coduser := null;
        end;
        data_file  := replace(data_file  ,'<param-05>',get_label_name('HRPY5ZBC3',global_v_lang,270)||crlf||get_label_name('HRPY5ZBC3',global_v_lang,271)||' '||v_coduser||crlf||crlf);
       elsif p_format = 'ddmmYYYY' then
        data_file  := replace(data_file  ,'<param-05>',get_label_name('HRPY5ZBC3',global_v_lang,270)||crlf||get_label_name('HRPY5ZBC3',global_v_lang,272)||crlf||'     '||
                      get_label_name('HRPY5ZBC3',global_v_lang,281)||crlf||'     '||get_label_name('HRPY5ZBC3',global_v_lang,282)||crlf||'     '||get_label_name('HRPY5ZBC3',global_v_lang,285)||crlf||
                      get_label_name('HRPY5ZBC3',global_v_lang,290)||get_label_name('HRPY5ZBC3',global_v_lang,291)||crlf||crlf);
       elsif p_format = 'ddMonYYYY' then
        data_file  := replace(data_file  ,'<param-05>',get_label_name('HRPY5ZBC3',global_v_lang,270)||crlf||get_label_name('HRPY5ZBC3',global_v_lang,273)||crlf||'     '||
                      get_label_name('HRPY5ZBC3',global_v_lang,281)||crlf||'     '||get_label_name('HRPY5ZBC3',global_v_lang,283)||get_label_name('HRPY5ZBC3',global_v_lang,284)||crlf||'     '||get_label_name('HRPY5ZBC3',global_v_lang,285)||crlf||
                      get_label_name('HRPY5ZBC3',global_v_lang,290)||get_label_name('HRPY5ZBC3',global_v_lang,292)||crlf||crlf);
       elsif p_format = 'mmddYYYY' then
        data_file  := replace(data_file  ,'<param-05>',get_label_name('HRPY5ZBC3',global_v_lang,270)||crlf||get_label_name('HRPY5ZBC3',global_v_lang,274)||crlf||'     '||
                      get_label_name('HRPY5ZBC3',global_v_lang,282)||crlf||'     '||get_label_name('HRPY5ZBC3',global_v_lang,281)||crlf||'     '||get_label_name('HRPY5ZBC3',global_v_lang,285)||crlf||
                      get_label_name('HRPY5ZBC3',global_v_lang,290)||get_label_name('HRPY5ZBC3',global_v_lang,294)||crlf||crlf);
       elsif p_format = 'IDCARDNO' then
        data_file  := replace(data_file  ,'<param-05>',get_label_name('HRPY5ZBC3',global_v_lang,270)||crlf||get_label_name('HRPY5ZBC3',global_v_lang,275)||crlf||crlf);
       elsif p_format = 'MODIFY' then
        data_file  := replace(data_file  ,'<param-05>',get_label_name('HRPY5ZBC3',global_v_lang,270)||crlf||get_label_name('HRPY5ZBC3',global_v_lang,276)||crlf||crlf);
       end if;
    end if;

    if data_file like ('%<param-06>%') then
        data_file  := replace(data_file  ,'<param-06>','');
    end if;

    data_file := REPLACE(data_file,chr(10),'<br>');
    data_file := replace(data_file,' ','&nbsp;');
    p_msg := data_file;
  end;

  procedure get_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);

    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data;

  procedure gen_data(json_str_output out clob) is
    flgpass           boolean := true;
    v_flgpass         varchar2(1) := 'N';
    obj_row           json_object_t := json_object_t();
    obj_data          json_object_t;
    v_row             number := 0;
    v_flg             varchar2(1 char);
    v_flgsend         varchar2(1 char);
    v_exist           boolean;

    cursor c1 is
      select a.codempid,a.codcomp,a.numlvl,b.codpos,b.email
        from tsincexp a,temploy1 b ,temploy3 c
       where a.codempid   = b.codempid
         and a.numperiod  = p_numperiod
         and a.dtemthpay  = p_dtemthpay
         and a.dteyrepay  = p_dteyrepay
         and a.codcomp like p_codcomp||'%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.codempid   = nvl(p_codempid,a.codempid)
         and b.codempid   = c.codempid
         and a.numlvl between nvl(p_numlvlst,a.numlvl) and nvl(p_numlvlen,a.numlvl)
         and a.flgslip    = '1'
         and ( p_flgslip is null or (p_flgslip is not null and c.flgslip = p_flgslip ) )
         and (
               (v_flg = '1' and exists (select c.codempid -- already send
                                          from teslip c
                                         where c.codempid  = a.codempid
                                           and c.numperiod = p_numperiod
                                           and c.dtemthpay = p_dtemthpay
                                           and c.dteyrepay = p_dteyrepay
                                           and c.flgsend = 'Y'))
            or (v_flg = '2' and not exists (select c.codempid  -- not send
                                              from teslip c
                                             where c.codempid  = a.codempid
                                               and c.numperiod = p_numperiod
                                               and c.dtemthpay = p_dtemthpay
                                               and c.dteyrepay = p_dteyrepay
                                               and c.flgsend = 'Y'))
            or (v_flg = '3')  -- all
          )
      group by a.codcomp,a.codempid,a.numlvl,b.codpos,b.email
      order by a.codcomp,a.codempid;
  begin

    obj_row := json_object_t();

    if p_flgsend = 'Y' then
      v_flg := '1';
    elsif p_flgsend = 'N' then
      v_flg := '2';
    else
      v_flg := '3';
    end if;

    if p_flgslip = 'A' then
      p_flgslip := null;
    end if;

    for r1 in c1 loop
        v_exist := true;
        exit;
    end loop;
    if not v_exist then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tsincexp');
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
    for r1 in c1 loop
      flgpass := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if flgpass then
        v_flgpass := 'Y';
        v_row := v_row + 1;
        begin
         select flgsend
           into v_flgsend
           from teslip
          where codempid  = r1.codempid
            and numperiod = p_numperiod
            and dtemthpay = p_dtemthpay
            and dteyrepay = p_dteyrepay;
        exception when no_data_found then
          v_flgsend := null;
        end;

        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos', get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('email', r1.email);
        obj_data.put('flgsend',get_tlistval_name('FLGEPAY',nvl(v_flgsend,'N'),global_v_lang));
        obj_row.put(to_char(v_row - 1), obj_data);

      end if;
    end loop;
    if v_flgpass = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    end if;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;

  procedure get_password(json_str_input in clob,json_str_output out clob) is
    param_json        json_object_t;
    param_json_row    json_object_t;
    v_codempid        varchar2(4000 char);
    v_password        varchar2(4000 char);
    v_pwdformat       varchar2(4000 char);
    obj_data          json_object_t;
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    param_json        := json_object_t(hcm_util.get_clob_t(json_object_t(json_str_input),'json_input_str'));

    obj_row := json_object_t();
    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row := hcm_util.get_json_t(param_json, to_char(i));
        v_codempid     := hcm_util.get_string_t(param_json_row,'codempid');

        gen_password(v_codempid, v_password, v_pwdformat);

        obj_data := json_object_t();
        obj_data.put('codempid',v_codempid);
        obj_data.put('password',v_password);
        obj_data.put('pwdformat',v_pwdformat);
        obj_data.put('lang',chk_flowmail.get_emp_mail_lang(v_codempid, '102'));
        obj_row.put(to_char(i), obj_data);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_password;

  procedure gen_password(p_codempid in varchar2, p_password out varchar2, p_pwdformat out varchar2) is
    v_hbd         date;
    v_numoffid    varchar2(4000 char);
    v_coduser     varchar2(4000 char);
    v_codpswd     varchar2(4000 char);
  begin
    begin
      select t1.dteempdb,t2.numoffid,t3.codpswd,t3.coduser
        into v_hbd,v_numoffid,v_codpswd,v_coduser
        from temploy1 t1,temploy2 t2,tusrprof t3
       where t1.codempid = p_codempid and
             t2.codempid = t1.codempid and
             t3.codempid(+) = t1.codempid and
             rownum = 1
      order by t3.coduser;
    exception when no_data_found then
      v_hbd := null; v_numoffid := null; v_codpswd := null;
    end;

    if v_codpswd is not null then
      begin
        v_codpswd := pwddec(v_codpswd,v_coduser,v_chken);
      exception when others then
        v_codpswd := null;
      end;
    end if;

    if v_codpswd is not null then
      p_pwdformat := 'TUSRPROF';
      p_password  := v_codpswd;
    else
      p_pwdformat := 'IDCARDNO';
      p_password  := v_numoffid;
    end if;

    begin
      insert into tpaypwd(codempid,codpwd,pwdformat,coddate,
                          dtecreate,codcreate,dteupd,coduser)
                   values(p_codempid,pwdenc(p_password,p_codempid,v_chken),p_pwdformat,pwdenc(to_char(v_hbd,'DDMMYYYY'),p_codempid,v_chken),
                          sysdate,global_v_coduser,sysdate,global_v_coduser);
    exception when dup_val_on_index then
      update tpaypwd
         set codpwd    = pwdenc(p_password,p_codempid,v_chken),
             pwdformat = p_pwdformat,
             coddate   = pwdenc(to_char(v_hbd,'DDMMYYYY'),p_codempid,v_chken),
             dteupd    = sysdate,
             coduser   = global_v_coduser
       where codempid = p_codempid;
    end;
    commit;
    p_password := utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(p_password)));
  end;

  procedure post_mail(json_str_input in clob,json_str_output out clob) is
    param_json            json_object_t;
    param_json_row        json_object_t;
    v_codempid            varchar2(4000 char);
    v_filename            varchar2(4000 char);
    v_password            varchar2(4000 char);
    v_pwdformat           varchar2(4000 char);
    -- << Apisit || 08/03/2024 || fix issue #1746 || https://hrmsd.peopleplus.co.th:4449/redmine/issues/1746
    v_maillang            varchar2(100);
    -- >>
    
  begin
    initial_value(json_str_input);
    param_json        := json_object_t(hcm_util.get_clob_t(json_object_t(json_str_input),'json_input_str'));
    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row := hcm_util.get_json_t(param_json, to_char(i));
        v_codempid     := hcm_util.get_string_t(param_json_row,'codempid');
        v_filename     := hcm_util.get_string_t(param_json_row,'filename');
        v_password     := hcm_util.get_string_t(param_json_row,'password');
        v_pwdformat    := hcm_util.get_string_t(param_json_row,'pwdformat');
        
        global_v_lang  := chk_flowmail.get_emp_mail_lang(v_codempid, '102'); -- KOHU-SS2301 | 000537-Boy-Apisit-Dev | 28/03/2024 | Fix issue 4449#1746

        v_password := utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(v_password)));
        send_mail_payslip(v_codempid,v_filename,v_password,v_pwdformat);
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php(p_error,old_global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,old_global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,old_global_v_lang);
  end post_mail;

  procedure send_mail_payslip (p_codempid varchar2, p_filename varchar2, p_password varchar2, p_pwdformat varchar2)is
    v_codcomp     temploy1.codcomp%type;
    v_typpayroll  temploy1.typpayroll%type;
    v_err         varchar2(4000 char);
    v_email       varchar2(4000 char);
    crlf          varchar2( 2 ):= chr( 13 ) || chr( 10 );
    v_msg         clob;
    v_msg_to      clob;
    v_dup         number;
    v_empemail    varchar2(4000 char);
    v_subject     varchar2(4000 char);
    v_codpswd     varchar2(4000 char);
    v_lang_codempid varchar2(10 char) := '102'; -- KOHU | 000311-J-Jaturong-Dev | 28/03/2024 | check year depends on lang
    v_dteyrepay     varchar2(10 char); -- KOHU | 000311-J-Jaturong-Dev | 28/03/2024 | check year depends on lang

  begin
    begin
      select codcomp,typpayroll
        into v_codcomp,v_typpayroll
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      null;
    end;

    -->>user8:Nirantee :27/11/2014 17:46 Assign By P'Teep and P'Somchai
    begin
      select dtepaymt into p_dtepaymt
        from tdtepay
       where codcompy   = hcm_util.get_codcomp_level(v_codcomp,'1')
         and typpayroll = v_typpayroll
         and dteyrepay  = (p_dteyrepay - global_v_zyear)
         and dtemthpay  = p_dtemthpay
         and numperiod  = p_numperiod;
    exception when no_data_found then
--<< user36 ST11 09/03/2024, as HRES81X (user22 : 06/06/2019 : SMTL620332)
      begin
        select dtepaymt into p_dtepaymt
          from tdtepay2
         where codcompy   = hcm_util.get_codcomp_level(v_codcomp,'1')
           and typpayroll = v_typpayroll
           and dteyrepay  = (p_dteyrepay - global_v_zyear)
           and dtemthpay  = p_dtemthpay
           and numperiod  = p_numperiod;
      exception when no_data_found then
        p_dtepaymt := null;
      end;
-->> user36 ST11 09/03/2024      
    end;
    --<<user8:Nirantee :27/11/2014 17:46 Assign By P'Teep and P'Somchai
    replace_text(v_msg_to,p_filename,p_pwdformat,p_codempid);
    begin
      select email into v_empemail
      from temploy1
      where codempid = p_codempid;
    exception when no_data_found then
      v_empemail := null ;
    end ;
    -->>user8:Nirantee 01/12/2014 13:18 Assign By P'Teep and P'Somchai
    v_email   :=  get_tsetup_value('MAILEMAIL');
    
    --<< KOHU | 000311-J-Jaturong-Dev | 28/03/2024 | check year depends on lang
    v_lang_codempid  := chk_flowmail.get_emp_mail_lang(p_codempid, '102');
    v_dteyrepay := p_dteyrepay;
    if v_lang_codempid = '102' then
        v_dteyrepay := hcm_util.get_year_buddhist_era(p_dteyrepay);
    end if;
    -- v_subject := get_label_name('HRPY5ZBC3',global_v_lang,260)||' '||p_numperiod||' '||get_label_name('HRPY5ZBC3',global_v_lang,30)||' '||get_tlistval_name('DTEMTHPAY',p_dtemthpay,global_v_lang)||' '||get_label_name('HRPY5ZBC3',global_v_lang,40)||' '||p_dteyrepay;  -- hcm_util.get_year_buddhist_era(p_dteyrepay);
    -->> KOHU | 000537-BOY-Apisit-Dev | 28/03/2024 | Delete p_numperiod
--    v_subject := get_label_name('HRPY5ZBC3',global_v_lang,260)||' '||p_numperiod||' '||get_label_name('HRPY5ZBC3',global_v_lang,30)||' '||get_tlistval_name('DTEMTHPAY',p_dtemthpay,global_v_lang)||' '||get_label_name('HRPY5ZBC3',global_v_lang,40)||' '||v_dteyrepay;
    v_subject := get_label_name('HRPY5ZBC3',global_v_lang,260)||''||get_label_name('HRPY5ZBC3',global_v_lang,30)||get_tlistval_name('DTEMTHPAY',p_dtemthpay,global_v_lang)||' '||v_dteyrepay;
    -- >> End Delete p_numperiod
    
    -->> KOHU | 000311-J-Jaturong-Dev | 28/03/2024 | check year depends on lang
    
     
    --<<user8:Nirantee 01/12/2014 13:18 Assign By P'Teep and P'Somchai
    v_err := '0000';

    if v_empemail is not null then
      v_err := sendmail_attachfile(v_email,v_empemail,v_subject,v_msg_to,p_filename);
    end if;
    if v_err = '7521' then
        begin
          select count(*) into v_dup
          from teslip
          where dteyrepay = (p_dteyrepay - global_v_zyear)
          and dtemthpay = p_dtemthpay
          and numperiod = p_numperiod
          and codempid  = p_codempid ;
        exception when no_data_found then
          v_dup := 0;
        end;
        v_codpswd := pwdenc(p_password,global_v_coduser,v_chken) ;
        if v_dup = 0 then
         insert into teslip
                (dteyrepay,dtemthpay,numperiod,
                 codempid,flgsend,dteupd,
                 codcreate,coduser,codpswd
                )
              values
                ((p_dteyrepay - global_v_zyear),p_dtemthpay,p_numperiod,
                 p_codempid,'Y',trunc(sysdate),
                 global_v_coduser,global_v_coduser,v_codpswd);
        else
          update teslip set flgsend = 'Y',
                            dteupd  = trunc(sysdate),
                            coduser = global_v_coduser,
                            codpswd = v_codpswd
                            where dteyrepay = p_dteyrepay
                            and dtemthpay = p_dtemthpay
                            and numperiod = p_numperiod
                            and codempid = p_codempid;
        end if;
    end if;

    if v_err = '7521' then
      p_error :=  'HR2046';
    else
      p_error :=  'HR7522';
    end if;
  end ;

end HRPY5ZB;

/

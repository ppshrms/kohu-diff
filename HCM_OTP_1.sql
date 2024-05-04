--------------------------------------------------------
--  DDL for Package Body HCM_OTP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_OTP" is
-- last update: 12/07/2021 11:31

  function rand(p_digit number) return varchar2 is
    v_char  varchar2(100 char);
    v_mode  number;
  begin
    for i in 1..p_digit loop
      v_mode := trunc(DBMS_RANDOM.value(1,4)); -- random mode 1,2,3
      if v_mode = 1 then    -- A-Z
        v_char := v_char||chr(trunc(DBMS_RANDOM.value(65,91)));
      elsif v_mode = 2 then -- a-z
        v_char := v_char||chr(trunc(DBMS_RANDOM.value(97,123)));
      else                  -- number
        v_char := v_char||trunc(DBMS_RANDOM.value(0,10));
      end if;
    end loop;
    return v_char;
  end;
  --
  procedure call_tsetpass is
  begin
    p_timeotp   	    := null;
    p_qtyotp 	        := null;

    select timeotp ,qtyotp
      into p_timeotp,p_qtyotp
      from tsetpass
     where trunc(dteeffec) = (select max(dteeffec) from tsetpass where dteeffec <= trunc(sysdate));
  exception when no_data_found then
      null;
  end;
  --
  procedure get_otp_config(json_str_input in clob,json_str_output out clob) is
    json_obj        json_object_t;
    obj_data        json_object_t;
    v_otptype       varchar2(10 char);
    obj_data_params json_object_t;
    obj_rows_params json_object_t;
    v_rcnt          number := 0;
    
    cursor c1 is
      select parameter,value
        from tsmsconfig;
  begin
    json_obj        := json_object_t(json_str_input);
    v_otptype       := upper(hcm_util.get_string_t(json_obj,'p_otptype'));
    p_otptype       := nvl(v_otptype,nvl(get_tsetup_value('OTPTYPE'),'M'));
    
    obj_data   := json_object_t();
    obj_data.put('coderror', '200');
    obj_rows_params := json_object_t();
    for r1 in c1 loop
      v_rcnt := v_rcnt + 1;
      obj_data_params := json_object_t();
      obj_data_params.put(to_char(r1.parameter),to_char(r1.value));
      obj_rows_params.put(to_char(v_rcnt - 1), obj_data_params);
    end loop;
    obj_data.put('otp_apiurl', get_tsetup_value('OTPAPIURL'));
    obj_data.put('otp_username', get_tsetup_value('OTPUSERNAME'));
    obj_data.put('otp_password', get_tsetup_value('OTPPASSWORD'));
    obj_data.put('otp_type', p_otptype);
    obj_data.put('otp_post_params', obj_rows_params.to_clob);
    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,'102');
  end;
  --
  procedure insert_tlogsms(p_nummobile varchar2, p_length_msg varchar2,p_codform varchar2,p_coduser varchar2) is
  begin
    begin
      insert into tlogsms (dteupd,nummobile,msglength,codapp,
                           dtecreate,codcreate,coduser)
       values(sysdate, p_nummobile, p_length_msg, p_codform,
              sysdate, p_coduser, p_coduser);
    exception when dup_val_on_index then
      update tlogsms
         set msglength = p_length_msg,
             codapp    = p_codform,
             coduser   = p_coduser
       where dteupd    = sysdate
         and nummobile = p_nummobile;
    end;
    commit;
  end;
  --
  procedure get_otp_setup(json_str_input in clob,json_str_output out clob) is
    json_obj        json_object_t;
    obj_data        json_object_t;
    p_coduser       varchar2(100 char);
    p_codempid      varchar2(100 char);
    v_nummobile     temploy1.nummobile%type;
    v_otptype 			varchar2(200 char);
  begin
    json_obj        := json_object_t(json_str_input);
    p_coduser       := upper(hcm_util.get_string_t(json_obj,'p_coduser'));
    p_codempid      := upper(hcm_util.get_string_t(json_obj,'p_codempid'));

    call_tsetpass;

    begin
      select nummobile
        into v_nummobile
        from temploy1
       where codempid = (select codempid from tusrprof where coduser = p_coduser)
         and rownum = 1;
    exception when no_data_found then
      v_nummobile := null;
    end;

    v_otptype := nvl(get_tsetup_value('OTPTYPE'),'M');

    if v_otptype = 'M' then
      v_nummobile := nvl(v_nummobile,'-');
    end if;

    obj_data   := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('otpType', v_otptype);
    obj_data.put('otpDigits', p_qtyotp);
    obj_data.put('phone', v_nummobile);
    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,'102');
  end;
  --
  procedure send_otp(p_codform in varchar2, p_coduser in varchar2, p_phone in varchar2, p_lang in varchar2,
                     p_ref out varchar2, p_message_sms out long) is
    v_msg           long := null;
    v_msgsms        long := null;
    p_msg           long := null;
    v_error         varchar2(20 char);
    p_error         varchar2(20 char) ;
    v_subject       varchar2(1000 char);
    v_send					temploy1.email%type;
    v_nummobile			temploy1.nummobile%type;
    v_maillang			temploy1.nummobile%type;
    v_codempid			varchar2(200 char);
    v_name          varchar2(200 char);
    v_emp 					varchar2(200 char);
    crlf            varchar2( 2 ):= chr( 13 ) || chr( 10 );
    v_date    	    date;
    v_otp           varchar2(1000 char);
    format1         number;
    format2         number;
  begin
    global_v_lang := p_lang;
    call_tsetpass;
    p_ref := dbms_random.string('X', 6);

    -- generage otp
    v_date := sysdate;
    if p_qtyotp is null then
        format1 := 100000;
        format2 := 999999;
    else
      if p_qtyotp = 1 then
        format1 := 0;
        format2 := 9;
      else
        format1 := to_number(rpad('1',p_qtyotp,'0'));
        format2 := to_number(rpad('9',p_qtyotp,'9'));
      end if;
    end if;
    v_otp := trunc(dbms_random.value(format1,format2));

    begin
      update 	tusrprof
        set 	otpcode = v_otp,
              dteotp  = sysdate
      where 	upper(coduser) = upper(p_coduser);
      commit;
    end;

    if p_coduser is not null then
      begin
        select a.codempid, b.email, b.nummobile, b.maillang
          into v_emp, v_send, v_nummobile, v_maillang
          from tusrprof a, temploy1 b
         where a.codempid = b.codempid
           and a.coduser = upper(p_coduser);
      exception when no_data_found then
       v_emp       :=  null;
       v_send      :=  null;
       v_nummobile :=  null;
      end;
    elsif p_phone is not null then
      begin
        select codempid, email, nummobile, maillang
          into v_emp, v_send, v_nummobile, v_maillang
          from temploy1
         where replace(nummobile,'-') = replace(p_phone,'-');
      exception when no_data_found then
       v_emp       :=  null;
       v_send      :=  null;
       v_nummobile :=  null;
      end;
    end if;
    if lower(v_maillang) = 'en' then
      v_maillang    := '101';
    elsif lower(v_maillang) = 'th' then
      v_maillang    := '102';
    else
      v_maillang    := nvl(v_maillang,global_v_lang);
    end if;
    
    -- get message for send otp (mail)
    begin
      select  decode(v_maillang,    '101', messagee,
                                    '102', messaget,
                                    '103', message3,
                                    '104', message4,
                                    '105', message5,
                                           messaget)
       into  v_msg
       from  tfrmmail
      where  codform  = upper(p_codform);
    exception when others then
      v_msg := null;
    end;

    -- get message for send otp (sms)
    begin
      select  decode(v_maillang,    '101', messagee,
                                    '102', messaget,
                                    '103', message3,
                                    '104', message4,
                                    '105', message5,
                                           messaget)
       into  v_msgsms
       from  tfrmmail
      where  codform  = upper('OTP');
    exception when others then
      v_msgsms := null;
    end;

    if p_otptype = 'M' or p_otptype = 'A' then -- E-Mail
      if v_msg is not null then
        if v_send is not null then
          -- replace message for send otp
          v_name := get_temploy_name(v_emp,v_maillang);
          v_msg       := replace(v_msg,'[PARAM-TO]',v_name);
          v_msg				:= replace(v_msg,'[PARAM-01]',v_otp||' <Ref. '||p_ref||'>');
          v_msg				:= replace(v_msg,'[PARAM-CODUSER]',p_coduser);
          v_msg				:= replace(v_msg,'[PARAM-TIME]',to_char(v_date+(1/1440*nvl(p_timeotp,5)),'dd/mm/yyyy hh24:mi:ss'));
          v_subject   := 'OTP CODE';
          v_codempid	:=	get_tsetup_value('MAILEMAIL');
          p_msg := 'From: ' ||v_codempid|| crlf ||
                   'To: '||v_send||crlf||
                   'Subject: '||v_subject||crlf||
                   'Content-Type: text/html';
          p_msg := p_msg||crlf||crlf||v_msg;

          v_error := send_mail(v_send,p_msg);
          if v_error = '7522' then -- error
              p_error :=  'HR7522';
          end if;
        end if;
      end if;
    end if;

    if p_otptype = 'S' or p_otptype = 'A' then -- SMS
      if v_msgsms is not null then
        if v_nummobile is not null then
          v_nummobile := replace(v_nummobile,'-');
          -- replace message for send otp
          v_msgsms		:= replace(v_msgsms,'[PARAM-OTP]',v_otp||' <Ref. '||p_ref||'>');
          v_msgsms		:= replace(v_msgsms,'[PARAM-TIME]',p_timeotp);
          p_message_sms := v_msgsms;
          insert_tlogsms(v_nummobile,length(v_msgsms),p_codform,p_coduser);
        end if;
      end if;
    end if;
    commit;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
  procedure get_otp(json_str_input in clob,json_str_output out clob) is
    json_obj        json_object_t;
    obj_data        json_object_t;
    p_coduser       varchar2(100 char);
    p_codempid      varchar2(100 char);
    p_codform       varchar2(100 char);
    p_phone         varchar2(100 char);
    v_ref           varchar2(100 char);
    v_otptype       varchar2(100 char);
    v_message_sms   long;
  begin
    json_obj        := json_object_t(json_str_input);
    p_coduser       := upper(hcm_util.get_string_t(json_obj,'p_coduser'));
    global_v_lang   := hcm_util.get_string_t(json_obj,'p_lang');
    p_codform       := upper(hcm_util.get_string_t(json_obj,'p_codform'));
    p_phone         := upper(hcm_util.get_string_t(json_obj,'p_phone'));
    v_otptype       := upper(hcm_util.get_string_t(json_obj,'p_otptype'));
    p_otptype       := nvl(v_otptype,nvl(get_tsetup_value('OTPTYPE'),'M'));

    call_tsetpass;

    -- send otp
    send_otp(p_codform, p_coduser, p_phone, global_v_lang, v_ref, v_message_sms);

    if v_ref is not null then
      obj_data   := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('phone', p_phone);
      obj_data.put('message_sms', v_message_sms);
      obj_data.put('ref', to_char(v_ref));
      obj_data.put('otptype', p_otptype);
      obj_data.put('timeotp', to_char(p_timeotp));
      json_str_output := obj_data.to_clob;
    else
      param_msg_error := get_error_msg_php('HR7522', global_v_lang, null, null, false);
      json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,'102');
  end;
  --
  procedure post_otp(json_str_input in clob,json_str_output out clob) is
    json_obj      json_object_t;
    obj_data      json_object_t;
    p_coduser     varchar2(1000 char);
    p_otpcode     varchar2(1000 char);
    v_otp         varchar2(1000 char);
    v_dateotp     date;
  begin
    json_obj      := json_object_t(json_str_input);
    p_coduser     := upper(hcm_util.get_string_t(json_obj,'p_coduser'));
    p_otpcode     := upper(hcm_util.get_string_t(json_obj,'p_otpcode'));
    global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');

    call_tsetpass;

    begin
      select  otpcode,dteotp
      into    v_otp,v_dateotp
      from    tusrprof
      where   coduser   = p_coduser;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TUSRPROF', null, false);
    end;

    if param_msg_error is null then
      if (v_dateotp+(1/1440*nvl(p_timeotp,5))) >= sysdate then
        if v_otp = p_otpcode then
          update 	tusrprof
             set 	timepswd = 0,
                  otpcode  = null,
                  dteotp   = null
           where 	upper(coduser) = upper(p_coduser);
        else
          param_msg_error := get_error_msg_php('HR8853', global_v_lang, null, null, false);
        end if;
      else
        param_msg_error := get_error_msg_php('HR8852', global_v_lang, null, null, false);
      end if;
    end if;

    obj_data  := json_object_t();
    obj_data.put('coderror', '200');
    if param_msg_error is not null then
      obj_data.put('status','error');
      obj_data.put('message',replace(param_msg_error,'@#$%400'));
    else
      obj_data.put('status','success');
    end if;
    json_str_output := obj_data.to_clob;
  exception when others then
    obj_data  := json_object_t();
    obj_data.put('coderror', '400');
    obj_data.put('status','error');
    obj_data.put('message',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
  end;
end;

/

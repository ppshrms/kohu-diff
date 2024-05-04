--------------------------------------------------------
--  DDL for Package Body HREL42E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL42E" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    global_v_lang       := nvl(global_v_lang,'102');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempidQuery');

    p_codlogin          := hcm_util.get_string_t(json_obj,'p_codlogin');
    p_codpwd            := hcm_util.get_string_t(json_obj,'p_codpwd');



   hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_count_comp  number := 0;
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

  end;

  procedure gen_index_emp(json_str_output out clob) is
    obj_data            json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_codpos            temploy1.codpos%type;
    v_codcomp           temploy1.codcomp%type;
    v_staemp            temploy1.staemp%type;
    v_flggrade          varchar2(2 char);

    begin
        begin
          select codpos,codcomp,staemp
           into v_codpos,v_codcomp,v_staemp
            from temploy1
           where codempid  = p_codempid;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang);
        end;

        if param_msg_error is null then
           if v_staemp = 9 then
              param_msg_error := get_error_msg_php('HR2101', global_v_lang);
           elsif v_staemp = 0 then
              param_msg_error := get_error_msg_php('HR2102', global_v_lang);
           else
             obj_data := json_object_t();
             obj_data.put('coderror','200');
             obj_data.put('codpos',v_codpos);
             obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
             obj_data.put('codcomp',v_codcomp);
             obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
           end if;
        end if;

        if param_msg_error is null then
           json_str_output := obj_data.to_clob;
          return;
        else
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
        end if;

  end gen_index_emp;

  procedure get_index_emp (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
--        check_index();
        if param_msg_error is null then
            gen_index_emp(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_appl(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_numappl           tappoinf.numappl%type;
    v_numreqrq           tappoinf.numreqrq%type;
    v_codposrq           tappoinf.codposrq%type;
    v_numapseq           tappoinf.numapseq%type;
    v_codexam           tappoinf.codexam%type;
    v_dteappoi          tappoinf.dteappoi%type;
    v_namempt           tapplinf.namempt%type;
    v_codcompl          tapplinf.codcompl%type;
    v_codposl           tapplinf.codposl%type;
    v_flgtest_tr        varchar2(2 char);
    v_codcompyl         tcenter.codcomp%type;
    begin
        begin
          select a.numappl,a.numreqrq,a.codposrq,a.numapseq, codexam, dteappoi, codcompl, codposl,
          decode(global_v_lang,'101',namempe,
                                  '102',namempt,
                                  '103',namemp3,
                                  '104',namemp4,
                                  '105',namemp5) as namempt
             into v_numappl, v_numreqrq, v_codposrq, v_numapseq, v_codexam, v_dteappoi, v_codcompl, v_codposl,v_namempt

          from tappoinf a, tapplinf b
          where a.numappl = b.numappl          
          and codlogin = p_codlogin
          and codpwd  = pwdenc(p_codpwd,p_codlogin,v_chken)
          and trunc(a.dteappoi)  = trunc(sysdate)  
             ;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tappoinf');
        end;

        if param_msg_error is null then
             begin
                select 'Y'
                into v_flgtest_tr
                from ttestemp
                where codempid = p_codlogin
                  and codexam = v_codexam
                  and trunc(dtetest) = trunc(v_dteappoi)
                  and typtest = '1';                                                      
              exception when no_data_found then
                v_flgtest_tr := 'N';
              end;

              if v_flgtest_tr = 'Y' then
                 param_msg_error := get_error_msg_php('EL0054', global_v_lang);
                 json_str_output := get_response_message('403',param_msg_error,global_v_lang);
              else
                 obj_data := json_object_t();
                 obj_data.put('coderror','200');
                 v_codcompyl := hcm_util.get_codcomp_level(v_codcompl,1);
                 obj_data.put('numappl',v_numappl);
                 obj_data.put('numreqrq',v_numreqrq);
                 obj_data.put('codposrq',v_codposrq);
                 obj_data.put('numapseq',v_numapseq);
                 obj_data.put('codexam',v_codexam);
                 obj_data.put('namempt',v_namempt);
                 obj_data.put('codposl',v_codposl);
                 obj_data.put('desc_codposl',get_tpostn_name(v_codposl,global_v_lang)); --#4629 || 30/05/2022
                 obj_data.put('codcompl',v_codcompl);
                 obj_data.put('desc_codcompl',get_tcenter_name(v_codcompl,global_v_lang)); --#4629 || 30/05/2022                 
                 obj_data.put('codcompyl',get_tcenter_name(v_codcompyl,global_v_lang)); --#4629 || 30/05/2022
                 json_str_output := obj_data.to_clob;
              end if;
        else
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        end if;

  end gen_detail_appl;

  procedure get_detail_appl (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
--        check_index();
        if param_msg_error is null then
            gen_detail_appl(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure forgot_password(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_row               number := 0;
    v_count             number := 0;

    v_numappl          tappoinf.numappl%type;
    v_codpwd           tappoinf.codpwd%type;
    v_email            tapplinf.email%type;
     v_codlogin         tappoinf.codlogin%type;

    v_msg_to        long := null;
    v_template_to   long := null;
    v_msg           long := null;
    v_msge          long := null;
    v_msgt          long := null;
    v_msg3          long := null;
    v_msg4          long := null;
    v_msg5          long := null;
    v_func_appr     varchar2(20) ;
    v_error         varchar2(20) ;
    p_error         varchar2(20) ;
    v_temp					varchar2(4000) ;
    v_subject       varchar2(100);
    v_coduser       varchar2(20) ;
    v_report        varchar2(200);
    v_head          varchar2(200);
    v_send		    varchar2(4000) ;
    v_codempid	    varchar2(200);
    v_namerep	    varchar2(200);
    v_space         varchar2(200);
    v_to		    varchar2(200);
    v_name          varchar2(200);
    v_emp 		    varchar2(200);
    p_msg           long := null;
    crlf            varchar2( 2 ):= chr( 13 ) || chr( 10 );
    begin

        begin
          select codlogin,a.numappl, codpwd, email,
                 decode(global_v_lang,'101',namempe,
                                      '102',namempt,
                                      '103',namemp3,
                                      '104',namemp4,
                                      '105',namemp5) as namemp
             into v_codlogin,v_numappl, v_codpwd, v_email, v_name
             from tappoinf a, tapplinf b
             where a.numappl = b.numappl
               and codlogin = p_codlogin;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tappoinf');
        end;

        begin
            select  decode(global_v_lang, '101', descode,
                                          '102', descodt,
                                          '103', descod3,
                                          '104', descod4,
                                          '105', descod5,
                                          descodt),
                    decode(global_v_lang, '101', messagee,
                    '102', messaget,
                    '103', message3,
                    '104', message4,
                    '105', message5,
                    messaget)
             into  v_subject,v_msg
             from  tfrmmail
            where  codform  = 'HREL42E';
        exception when others then null;
        end;


        if param_msg_error is null then
             begin
                -- Send Mail
               v_codpwd    := pwddec(v_codpwd,v_codlogin,v_chken);
               v_msg       := replace(v_msg,'[PARAM-TO]',v_name);
               v_msg			 := replace(v_msg,'[PARAM-01]',v_codlogin);
               v_msg			 := replace(v_msg,'[PARAM-02]',v_codpwd);
               v_codempid	:=	get_tsetup_value('MAILEMAIL');
                if v_email is not null then
                  p_msg := 'From: ' ||v_codempid|| crlf ||
                           'To: '||v_email||crlf||
                           'Subject: '||v_subject||crlf||
                           'Content-Type: text/html';
                  p_msg := p_msg||crlf||crlf||v_msg;

                  v_error := send_mail(v_email,p_msg);

                  if v_error = '7521' then
                      p_error :=  '2046';
                  else
                      p_error :=  '7522';
                  end if;
                  commit;
                  param_msg_error := get_label_name('SCRLABEL',global_v_lang,2370);
                  json_str_output := get_response_message('200',param_msg_error,global_v_lang);
                end if;
              end;
        else
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        end if;


  end forgot_password;

  procedure post_forgot_password (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            forgot_password(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end hrel42e;

/

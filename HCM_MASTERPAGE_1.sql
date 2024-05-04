--------------------------------------------------------
--  DDL for Package Body HCM_MASTERPAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_MASTERPAGE" is
-- last update : 07/02/2020 10:37

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
    v_arr      arr_1d;
  begin
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codcomp  := hcm_util.get_string_t(json_obj,'p_codcomp');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_codapp          := hcm_util.get_string_t(json_obj,'p_codapp');
    p_main_color      := hcm_util.get_string_t(json_obj,'p_main_color');
    p_advance_color   := hcm_util.get_string_t(json_obj,'p_advance_color');
    p_file_name       := hcm_util.get_string_t(json_obj,'p_file_name');
    p_maillang        := hcm_util.get_string_t(json_obj,'p_maillang');

    v_limit           := to_number(hcm_util.get_string_t(json_obj,'p_limit'));
    v_start           := to_number(hcm_util.get_string_t(json_obj,'p_start'));
    v_codempid        := hcm_util.get_string_t(json_obj,'p_codempid');
    v_codapp          := upper(hcm_util.get_string_t(json_obj,'p_codapp'));
    v_staappr         := nvl(hcm_util.get_string_t(json_obj,'p_staappr'),'P,A');

    v_arr              := explode(',',v_staappr,null);
    for i in 1..5 loop
      v_arr_staappr(i) := '';
      if i <= v_arr.count then
        v_arr_staappr(i) := v_arr(i);
      end if;
    end loop;

  end initial_value;

  procedure gen_favorite(json_str_output out clob) as
    obj_row   json_object_t;
    obj_data  json_object_t;
    v_rcnt    number := 0;
    v_flgdata boolean := false;

    cursor c1 is
      select codapp
        from tusrfavor
       where coduser = global_v_coduser
      order by codapp;

  begin
    obj_row  := json_object_t();

    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
      v_flgdata := true;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codapp', r1.codapp);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    if not v_flgdata then
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codapp', '');
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_favorite(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_favorite(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_favorite;

  procedure change_favorite(json_str_output out clob) as
    v_check   varchar2(100 char);
  begin
    begin
      select count(*)
        into v_check
        from tusrfavor
       where coduser = global_v_coduser
         and codapp  = p_codapp;
    exception when no_data_found then
      v_check := 0;
    end;
    if v_check = 0 then
      begin
        insert into tusrfavor(coduser,codapp)
             values(global_v_coduser,p_codapp);
      end;
    else
      delete from  tusrfavor
       where coduser = global_v_coduser
         and codapp  = p_codapp;
    end if;
    commit;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;

  procedure save_favorite(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      change_favorite(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_favorite;

  ------------------- Theme -----------------------------
  procedure change_theme(json_str_output out clob) as
    v_check     varchar2(100 char);
    p_value     varchar2(100 char);
    p_codvalue  varchar2(4000 char);
    p_remarks   varchar2(4000 char);
   begin
    if p_main_color is not null then
       p_codvalue := 'THEMEMAIN';
       p_remarks  := 'Theme Color (Main)';
       p_value    := p_main_color;
    else
       p_codvalue := 'THEMEADV';
       p_remarks  := 'Theme Color (Advance)';
       p_value    := p_advance_color;
    end if;
    -- delete before insert
    begin
      delete from tusrconfig
       where coduser  = global_v_coduser
         and codvalue in ('THEMEMAIN','THEMEADV');
    end;

    begin
       insert into tusrconfig(coduser,codvalue,remarks,value)
              values(global_v_coduser,p_codvalue,p_remarks,p_value);
    exception when dup_val_on_index then
       update tusrconfig
          set value    = p_value
        where coduser  = global_v_coduser
          and codvalue = p_codvalue;
    end;
    commit;
    param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_theme(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       change_theme(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_theme;
  -----------------------------------------------------------------
  --------------------------- Setting -----------------------------
  procedure gen_setting(json_str_output out clob) as
    obj_data     json_object_t;
    v_thememain  tusrconfig.value%type;
    v_themeadv   tusrconfig.value%type;
    v_logo       tsysconf.value%type;
    v_maillang   temploy1.maillang%type;
    v_profileimg tusrconfig.value%type;
    v_codcompy   varchar2(10 char);

    cursor c_thememain is
      select value
        from tusrconfig
       where coduser  = global_v_coduser
         and codvalue = 'THEMEMAIN';
    cursor c_themeadv is
      select value
        from tusrconfig
       where coduser  = global_v_coduser
         and codvalue = 'THEMEADV';
    cursor c_logo is
      select value
        from tsysconf
       where codcompy = v_codcompy
         and codvalue = 'LOGO';
    cursor c_maillang is
      select maillang
        from temploy1
       where codempid = global_v_codempid;
    cursor c_profileimg IS
        SELECT VALUE img
        FROM tusrconfig
        WHERE coduser = global_v_coduser
        AND codvalue = 'PROFILEIMG';

  begin
    v_codcompy := hcm_util.get_codcomp_level(global_v_coduser,1);
    for r_thememain in c_thememain loop
      v_thememain := r_thememain.value;
    end loop;
    for r_themeadv in c_themeadv loop
      v_themeadv := r_themeadv.value;
    end loop;
    for r_logo in c_logo loop
      v_logo  := r_logo.value;
    end loop;
    for r_maillang in c_maillang loop
      v_maillang  := r_maillang.maillang;
    end loop;
    for r_profileimg in c_profileimg loop
      v_profileimg  := r_profileimg.img;
    end loop;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('logo', v_logo);
    obj_data.put('maillang', lower(v_maillang));
    obj_data.put('theme_main', v_thememain);
    obj_data.put('theme_adv', v_themeadv);
    obj_data.put('profileimg', v_profileimg);

    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_setting(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_setting(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_setting;

  -----------------------------------------------------------------

  ---------------------------- Logo -------------------------------
  procedure change_logo(json_str_output out clob) as
    obj_data    json_object_t;
    v_check     varchar2(100 char);
    p_value     varchar2(100 char);
    v_codcompy  varchar2(10 char);
   begin
    v_codcompy := hcm_util.get_codcomp_level(global_v_coduser,1);
    begin
      select count(*) into v_check
        from  tsysconf
        where codcompy =  v_codcompy
          and codvalue = 'LOGO';
    exception when no_data_found then
      v_check := 0;
    end;
    if v_check = 0 then
       insert into tsysconf(codcompy,codvalue,remarks,value)
              values(v_codcompy,'LOGO','Logo Name',p_file_name);
    else
       update tsysconf set value = p_file_name
        where codcompy =  v_codcompy
          and codvalue = 'LOGO';
    end if;

    begin
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('logo', p_file_name);
      json_str_output := obj_data.to_clob;
    end;
    commit;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_logo(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       change_logo(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_logo;
  -----------------------------------------------------------------
  ------------------------- Email Language ------------------------

  procedure change_email_language(json_str_output out clob) as
    v_check   varchar2(100 char);
   begin
    begin
       update temploy1
          set maillang = lower(p_maillang)
        where codempid = global_v_codempid;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      commit;
    exception when others then null;
    end;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_email_language(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       change_email_language(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_email_language;
  -----------------------------------------------------------------
  ---------------------------- Account ----------------------------
  procedure gen_all_account(json_str_output out clob) as
    obj_row          json_object_t;
    obj_data         json_object_t;
    json_obj         json_object_t;
    obj_user         json_object_t;
    obj_user_clob    clob;
    v_rcnt           number := 0;
    p_coduser        varchar2(100 char);
    p_codempid       varchar2(100 char);
    p_username       varchar2(100 char);
    p_empnamee       varchar2(100 char);
    p_empnamet       varchar2(100 char);
    p_empname3       varchar2(100 char);
    p_empname4       varchar2(100 char);
    p_empname5       varchar2(100 char);
    p_desc_codpos    varchar2(100 char);
    p_desc_codpose   varchar2(100 char);
    p_desc_codpost   varchar2(100 char);
    p_desc_codpos3   varchar2(100 char);
    p_desc_codpos4   varchar2(100 char);
    p_desc_codpos5   varchar2(100 char);
    p_desc_codcomp   varchar2(100 char);
    p_desc_codcompe  varchar2(100 char);
    p_desc_codcompt  varchar2(100 char);
    p_desc_codcomp3  varchar2(100 char);
    p_desc_codcomp4  varchar2(100 char);
    p_desc_codcomp5  varchar2(100 char);
    p_codpos         varchar2(100 char);
    p_codcomp        varchar2(100 char);
    p_usrcom         varchar2(3000 char);
    p_namimage       varchar2(100 char);
    p_path_image     varchar2(100 char);
    p_namimageprof   varchar2(100 char);
    p_path_imageprof varchar2(100 char);
    v_flgdata boolean := false;

    cursor c1 is
      select *
        from  tusrprof
        where codempid = global_v_codempid
        and flgact = '1';

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
      v_flgdata := true;
      obj_data := json_object_t();

      obj_user := json_object_t();
      obj_user.put('p_coduser',r1.coduser );
      obj_user.put('p_codempid',global_v_codempid );
      obj_user.put('p_lang',global_v_lang );

      obj_user_clob := obj_user.to_clob;

       json_obj        := json_object_t(hcm_login.get_user(obj_user_clob));
       p_coduser       := hcm_util.get_string_t(json_obj,'p_coduser');
       p_codempid      := hcm_util.get_string_t(json_obj,'p_codempid');
       p_empnamee      := hcm_util.get_string_t(json_obj,'empnamee');
       p_empnamet      := hcm_util.get_string_t(json_obj,'empnamet');
       p_empname3      := hcm_util.get_string_t(json_obj,'empname3');
       p_empname4      := hcm_util.get_string_t(json_obj,'empname4');
       p_empname5      := hcm_util.get_string_t(json_obj,'empname5');
       p_desc_codpose  := hcm_util.get_string_t(json_obj,'desc_codpose');
       p_desc_codpost  := hcm_util.get_string_t(json_obj,'desc_codpost');
       p_desc_codpos3  := hcm_util.get_string_t(json_obj,'desc_codpos3');
       p_desc_codpos4  := hcm_util.get_string_t(json_obj,'desc_codpos4');
       p_desc_codpos5  := hcm_util.get_string_t(json_obj,'desc_codpos5');
       p_desc_codcompe := hcm_util.get_string_t(json_obj,'desc_codcompe');
       p_desc_codcompt := hcm_util.get_string_t(json_obj,'desc_codcompt');
       p_desc_codcomp3 := hcm_util.get_string_t(json_obj,'desc_codcomp3');
       p_desc_codcomp4 := hcm_util.get_string_t(json_obj,'desc_codcomp4');
       p_desc_codcomp5 := hcm_util.get_string_t(json_obj,'desc_codcomp5');
       p_codpos        := hcm_util.get_string_t(json_obj,'p_codpos');
       p_codcomp       := hcm_util.get_string_t(json_obj,'p_codcomp');
       p_usrcom        := hcm_util.get_string_t(json_obj,'usrcom');
       p_namimage      := hcm_util.get_string_t(json_obj,'namimage');
       p_path_image    := hcm_util.get_string_t(json_obj,'path_image');
       p_namimageprof      := hcm_util.get_string_t(json_obj,'namimageprof');
       p_path_imageprof    := hcm_util.get_string_t(json_obj,'path_imageprof');

      if global_v_lang = '101' then
          p_username       := p_empnamee;
          p_desc_codpos    := p_desc_codpose;
          p_desc_codcomp   := p_desc_codcompe;
      elsif global_v_lang  = '102' then
          p_username       := p_empnamet;
          p_desc_codpos    := p_desc_codpost;
          p_desc_codcomp   := p_desc_codcompt;
      elsif global_v_lang  = '103' then
          p_username       := p_empname3;
          p_desc_codpos    := p_desc_codpos3;
          p_desc_codcomp   := p_desc_codcomp3;
      elsif global_v_lang  = '104' then
          p_username       := p_empname4;
          p_desc_codpos    := p_desc_codpos4;
          p_desc_codcomp   := p_desc_codcomp4;
      elsif global_v_lang  = '105' then
          p_username       := p_empname5;
          p_desc_codpos    := p_desc_codpos5;
          p_desc_codcomp   := p_desc_codcomp5;
      end if;

      obj_data.put('coderror', '200');
      obj_data.put('p_coduser',p_coduser );
      obj_data.put('p_codempid',p_codempid );
      obj_data.put('username',p_username );
      obj_data.put('p_codpos',p_codpos );
      obj_data.put('desc_codpos',p_desc_codpos );
      obj_data.put('p_codcomp',p_codcomp );
      obj_data.put('desc_codcomp',p_desc_codcomp );
      obj_data.put('usrcom',p_usrcom );
      obj_data.put('p_namimage',p_namimage );
      obj_data.put('p_path_image',p_path_image );
      obj_data.put('p_namimageprof',p_namimageprof );
      obj_data.put('p_path_imageprof',p_path_imageprof );

      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;
    if not v_flgdata then
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('p_coduser', '');
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_all_account(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_all_account(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_all_account;

  -----------------------------------------------------------------

  ----------------------- Approve Message -------------------------

  procedure get_approve(json_str_input in clob, json_str_output out clob) is
    json_obj        json_object_t;
    resp_json_obj   json_object_t := json_object_t();
    v_count         number := 0;
    v_codempid      varchar2(100 char);

  begin
    json_obj                := json_object_t(json_str_input);
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
    v_codempid              := global_v_codempid;

    v_count := chkapprovehres32e('HRMS33U',v_codempid);  resp_json_obj.put('HRMS33U',to_char(v_count));
    v_count := chkapprovehres34e('HRMS35U',v_codempid);  resp_json_obj.put('HRMS35U',to_char(v_count));
    v_count := chkapprovehres36e('HRMS37U',v_codempid);  resp_json_obj.put('HRMS37U',to_char(v_count));
    v_count := chkapprovehres3be('HRMS3CU',v_codempid);  resp_json_obj.put('HRMS3CU',to_char(v_count));
    v_count := chkapprovehres62e('HRMS63U',v_codempid);  resp_json_obj.put('HRMS63U',to_char(v_count));
    v_count := chkapprovehres6ae('HRMS6BU',v_codempid);  resp_json_obj.put('HRMS6BU',to_char(v_count));
    v_count := chkapprovehres6de('HRMS6EU',v_codempid);  resp_json_obj.put('HRMS6EU',to_char(v_count));
    v_count := chkapprovehres6ie('HRMS6JU',v_codempid);  resp_json_obj.put('HRMS6JU',to_char(v_count));
    v_count := chkapprovehres6ke('HRMS6LU',v_codempid);  resp_json_obj.put('HRMS6LU',to_char(v_count));
    v_count := chkapprovehres6me('HRMS6NU',v_codempid);  resp_json_obj.put('HRMS6NU',to_char(v_count));
    v_count := chkapprovehres71e('HRMS72U',v_codempid);  resp_json_obj.put('HRMS72U',to_char(v_count));
    v_count := chkapprovehres74e('HRMS75U',v_codempid);  resp_json_obj.put('HRMS75U',to_char(v_count));
    v_count := chkapprovehres77e('HRMS78U',v_codempid);  resp_json_obj.put('HRMS78U',to_char(v_count));
    v_count := chkapprovehres84e('HRMS85U',v_codempid);  resp_json_obj.put('HRMS85U',to_char(v_count));
    v_count := chkapprovehres86e('HRMS87U',v_codempid);  resp_json_obj.put('HRMS87U',to_char(v_count));
    v_count := chkapprovehres88e('HRMS89U',v_codempid);  resp_json_obj.put('HRMS89U',to_char(v_count));
    v_count := chkapprovehres91e('HRMS92U',v_codempid);  resp_json_obj.put('HRMS92U',to_char(v_count));
    v_count := chkapprovehres93e('HRMS94U',v_codempid);  resp_json_obj.put('HRMS94U',to_char(v_count));
    v_count := chkapprovehres95e('HRMS96U',v_codempid);  resp_json_obj.put('HRMS96U',to_char(v_count));
    v_count := chkapprovehress2e('HRMSS3U',v_codempid);  resp_json_obj.put('HRMSS3U',to_char(v_count));
    v_count := chkapprovehress4e('HRMSS5U',v_codempid);  resp_json_obj.put('HRMSS5U',to_char(v_count));

    -- for mockup (phase 2)
    --resp_json_obj.put('HRMS33U','0');
    --resp_json_obj.put('HRMS35U','0');
    --resp_json_obj.put('HRMS37U','0');
    --resp_json_obj.put('HRMS3CU','0');
    --resp_json_obj.put('HRMS6JU','0');
    --resp_json_obj.put('HRMS72U','0');
    --resp_json_obj.put('HRMS75U','0');
    --resp_json_obj.put('HRMS78U','0');
    --resp_json_obj.put('HRMS85U','0');
    --resp_json_obj.put('HRMS87U','0');
    --resp_json_obj.put('HRMS89U','0');
    --resp_json_obj.put('HRMS92U','0');
    --resp_json_obj.put('HRMS94U','0');
    --resp_json_obj.put('HRMS96U','0');
    --resp_json_obj.put('HRMSS3U','0');
    --resp_json_obj.put('HRMSS5U','0');

    resp_json_obj.put('coderror', '200');

    json_str_output := resp_json_obj.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_approve;

  --HRES72U
    function chkapprovehres71e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
      v_flgapp   varchar2(4 char);
      v_approvno number ;
    begin
       begin
           select count(*)
           into   v_qty
           from   tmedreq a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES71E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
           or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES71E'))) ;
       end ;
       return v_qty ;
    end;

    --HRES74U
    function chkapprovehres74e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
      v_approvno number := 0;
      v_flgapp   varchar2(4 char);
    begin
          begin
           select count(*)
           into   v_qty
           from   tobfreq a,twkflowh b
           where  a.routeno = b.routeno
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES74E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES74E'))) ;
       end ;

      return v_qty ;
    end;
    --HRES78U
    function chkapprovehres77e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
      v_approvno number := 0;
      v_flgapp   varchar2(4 char);
    begin
       begin
           select count(*)
           into   v_qty
           from   tloanreq a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES77E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES77E'))) ;
       end ;

      return v_qty ;
    end;
    --HRES33U
    function chkapprovehres32e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
    begin
       begin
           select count(*)
           into   v_qty
           from   tempch a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES32E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES32E'))) ;
       end ;

      return v_qty ;
    end;
    --HRES37U
    function chkapprovehres36e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
      v_approvno number := 0;
      v_flgapp   varchar2(4 char);
    begin
       begin
           select count(*)
           into   v_qty
           from   trefreq a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES36E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES36E'))) ;
       end ;

      return v_qty ;
    end;
    --HRES63U
    function chkapprovehres62e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
      v_approvno number := 0;
      v_flgapp   varchar2(4 char);
    begin
      begin
           select count(*)
           into   v_qty
           from   tleaverq a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES62E',codempid,dtereq,seqno,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES62E'))) ;
       end ;

      return v_qty ;
    end;
    --HRES6BU
    function chkapprovehres6ae(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
      v_approvno number := 0;
      v_flgapp   varchar2(4 char);
    begin
       begin
           select count(*)
           into   v_qty
           from   ttimereq a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES6AE',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES6AE'))) ;
       end ;

      return v_qty ;
    end;
    --HRES35U
    function chkapprovehres34e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
      v_approvno number := 0;
      v_flgapp   varchar2(4 char);
    begin
       begin
           select count(*)
           into   v_qty
           from   tmovereq a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES34E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES34E'))) ;
       end ;
      return v_qty ;
    end;
    --HRES6EU
    function chkapprovehres6de(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
      v_approvno number := 0;
      v_flgapp   varchar2(4 char);
    begin
      begin
           select count(*)
           into   v_qty
           from   tworkreq a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES6DE',codempid,dtereq,seqno,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES6DE'))) ;
       end ;

      return v_qty ;
    end;
    --HRES6JU
    function chkapprovehres6ie(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
      v_approvno number := 0;
      v_flgapp   varchar2(4 char);
    begin
          begin
           select count(*)
           into   v_qty
           from   ttrnreq a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES6IE',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES6IE'))) ;
       end ;


      return v_qty ;
    end;
    --HRES6LU
    function chkapprovehres6ke(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
      v_approvno number := 0;
      v_flgapp   varchar2(4 char);
    begin
          begin
           select count(*)
           into  v_qty
           from  ttotreq a     -- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | issue kohu 4449: #1905 | bk --> from   ttotreq a,twkflowh b
          where  -- a.routeno = b.routeno     -- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | issue kohu 4449: #1905 | bk --> where  a.routeno = b.routeno
                 codcomp like '%'             -- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | issue kohu 4449: #1905 | bk --> and    codcomp like '%'
            and  staappr in ('P','A')
            and  'Y' = chk_workflow.check_privilege('HRES6KE',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr); -- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | issue kohu 4449: #1905 | BK --> and  ('Y' = chk_workflow.check_privilege('HRES6KE',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
-- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | issue kohu 4449: #1905
--            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
--                                                      from   twkflowde c
--                                                      where  c.routeno  = a.routeno
--                                                      and    c.codempid = p_codappr)
--            and (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES6KE')));
-- >> KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | issue kohu 4449: #1905 
       end ;
      return v_qty ;
    end;
    --HRES85U
    function chkapprovehres81e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty     number := 0;
      v_approvno number := 0;
      v_flgapp  varchar2(4 char);
    begin
       begin
           select count(*)
           into   v_qty
           from   ttravreq a,twkflowh b
           where  a.routeno = b.routeno
--           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES81E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES81E'))) ;
       end ;
      return v_qty ;
    end;
    --HRES87U
    function chkapprovehres86e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty     number := 0;
      v_approvno number := 0;
      v_flgapp  varchar2(4 char);
    begin
       begin
           select count(*)
           into   v_qty
           from   tresreq a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES86E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES86E'))) ;
       end ;
      return v_qty ;
    end;

    --HRESZ5U
    function chkapprovehres88e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty     number := 0;
      v_approvno number := 0;
      v_flgapp  varchar2(4 char);
    begin
       begin
           select count(*)
           into   v_qty
           from   tjobreq a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES88E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES88E'))) ;
       end ;

      return v_qty ;
    end;


    function chkapprovehress2e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
      v_approvno number := 0;
      v_flgapp   varchar2(4 char);
    begin
       begin
           select count(*)
           into   v_qty
           from   tpfmemrq a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRESS2E',codempid,dtereq,seqno,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRESS2E'))) ;
       end ;
      return v_qty ;
    end;

    function chkapprovehres3be(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
      v_approvno number := 0;
      v_flgapp   varchar2(4 char);
    begin
       begin
          select count(*)
            into v_qty
            from (select distinct a.codempid codemp,a.codappv codapv,a.numcomp numcom,a.dtecompl dcompl,
                         a.typcompl typecompl,get_temploy_name(a.codempid,global_v_lang) ename,a.stacompl stacomp,
                         get_tlistval_name('ESSTACOMP',a.stacompl,global_v_lang) status,
                         get_tcodec_name('TCODCOMP',a.typcompl,global_v_lang) v_typcomp,
                         get_tcenter_name(codcomp,global_v_lang) namcomp,codcomp
                    from tcompln a,tcomappv b
                   where 'Y' = chk_workflow.check_privilege('HRES3BE',a.codempid,a.dtecompl,a.numcomp,1,p_codappr)
                     and a.numcomp = b.numcomp(+)
                     and a.codcomp like '%'
                     and stacompl in ('N','D'));
--           select count(*)
--           into   v_qty
--           from   tcompln a,twkflowh b
--           where  a.routeno = b.routeno
--           and    codcomp like '%'
--           and    stacompl in ('N','D')
--           and   ((codempap in (select codempid
--                                from  tempappr
--                                where codapp  = 'HRES3BE'
--                                and   codappr = p_codappr ))
--                  or ((codcompap,codposap)in(select codcomp,codpos
--                                            from  tempappr
--                                            where codapp  = 'HRES3BE'
--                                            and   codappr = p_codappr))) ;
      end ;
      return v_qty ;
    end;

    --HRESS5U
    function chkapprovehress4e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
    begin
       begin
           select count(*)
           into   v_qty
           from   tircreq a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRESS4E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRESS4E'))) ;
       end ;
      return v_qty ;
    end;

    --HRES6NU
    function chkapprovehres6me(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
    begin
       begin
           select count(*)
           into   v_qty
           from   tleavecc a,twkflowh b
           where  a.routeno = b.routeno
           and    codcomp like '%'
           and    staappr in ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES6ME',codempid,dtereq,seqno,(nvl(a.approvno,0) + 1),p_codappr)
              -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = p_codappr)
           and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES6ME'))) ;
       end ;
      return v_qty ;
    end;

    --HRES96U
    function chkapprovehres95e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
    begin
       begin
            select count(*)
            into   v_qty
            from   treplacerq a ,twkflowh b
           where   codcomp like '%'
             and   staappr in ('P','A')
             and ('Y' = chk_workflow.check_privilege('HRES95E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
          -- Replace Approve
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                          from twkflowde c
                                                         where c.routeno  = a.routeno
                                                           and c.codempid = p_codappr))
                 and  (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES95E'))
          and  a.routeno = b.routeno ;
       end ;
      return v_qty ;
    end;

    --HRES92U
   function chkapprovehres91e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
    begin
       begin
            select count(*)
            into   v_qty
            from   ttrncerq a ,twkflowh b
           where   codcomp like '%'
             and   staappr in ('P','A')
             and ('Y' = chk_workflow.check_privilege('HRES91E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
          -- Replace Approve
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                          from twkflowde c
                                                         where c.routeno  = a.routeno
                                                           and c.codempid = p_codappr))
                 and  (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES91E'))
          and  a.routeno = b.routeno ;
       end ;
      return v_qty ;
    end;

    --HRES94U
   function chkapprovehres93e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
    begin
       begin
            select count(*)
            into   v_qty
            from   ttrncanrq a,twkflowh b
           where   codcomp like '%'
             and   stappr in ('P','A')
             and ('Y' = chk_workflow.check_privilege('HRES93E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
          -- Replace Approve
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                          from twkflowde c
                                                         where c.routeno  = a.routeno
                                                           and c.codempid = p_codappr))
                 and  (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES93E'))
          and  a.routeno = b.routeno ;
       end ;
      return v_qty ;
    end;

  --HRES85U
   function chkapprovehres84e(p_codapp in varchar2,p_codappr in varchar2) return number is
      v_qty      number := 0;
    begin
       begin
            select count(*)
            into   v_qty
            from   ttravreq a ,twkflowh b
           where   staappr in ('P','A')

--              and   codcomp like '%'
             and ('Y' = chk_workflow.check_privilege('HRES81E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codappr)
          -- Replace Approve
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                          from twkflowde c
                                                         where c.routeno  = a.routeno
                                                           and c.codempid = p_codappr))
                 and  (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES81E'))
          and  a.routeno = b.routeno ;
       end ;
      return v_qty ;
    end;
    --

  -----------------------------------------------------------------
  ----------------------- Request Message -------------------------
  function explode(p_delimiter varchar2, p_string long, p_limit number) return arr_1d as
    v_str1        varchar2(4000 char);
    v_comma_pos   number := 0;
    v_start_pos   number := 1;
    v_loop_count  number := 0;

    arr_result    arr_1d;

  begin
    arr_result(1) := null;
    loop
      v_loop_count := v_loop_count + 1;
      if v_loop_count-1 = p_limit then
        exit;
      end if;
      v_comma_pos := to_number(nvl(instr(p_string,p_delimiter,v_start_pos),0));
      v_str1 := substr(p_string,v_start_pos,(v_comma_pos - v_start_pos));
      arr_result(v_loop_count) := v_str1;

      if v_comma_pos = 0 then
        v_str1 := substr(p_string,v_start_pos);
        arr_result(v_loop_count) := v_str1;
        exit;
      end if;
      v_start_pos := v_comma_pos + length(p_delimiter);
    end loop;
    return arr_result;
  end explode;
  --

   procedure get_request_total(json_str_input in clob, json_str_output out clob) is
    v_total       number := 0;
    obj_data      json_object_t;
   begin
    initial_value(json_str_input);
    begin
      select count(*)
        into v_total
        from v_noti
        where codempid = v_codempid
         and ((v_arr_staappr(1) is not null and staappr = v_arr_staappr(1))
          or (v_arr_staappr(2) is not null and staappr = v_arr_staappr(2))
          or (v_arr_staappr(3) is not null and staappr = v_arr_staappr(3))
          or (v_arr_staappr(4) is not null and staappr = v_arr_staappr(4))
          or (v_arr_staappr(5) is not null and staappr = v_arr_staappr(5)))
         and codapp like nvl(v_codapp,codapp)
         and staappr in ('P','A');
      exception when no_data_found then
        v_total := 0;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror','');
    obj_data.put('total',v_total);

    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_request(json_str_input in clob, json_str_output out clob) is--quey limit about 85 record , if >86 record then error
    v_rcnt        number;
    v_total       number := 0;
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_flgdata boolean := false;

     cursor c1 is
      select codapp,descapp,desc_staappr,staappr,detail1,detail2,codempid,dtereq,numseq from (
      select codapp,descapp,desc_staappr,staappr,detail1,detail2,codempid,dtereq,numseq,rownum cnt from (
      select codapp,get_tprocapp_name(codapp,global_v_lang) descapp,get_tlistval_name('ESSTAREQ',staappr,global_v_lang) desc_staappr,
      staappr,detail1,detail2,codempid,dtereq,numseq
        from v_noti
        where codempid = v_codempid
         and ((v_arr_staappr(1) is not null and staappr = v_arr_staappr(1))
          or (v_arr_staappr(2) is not null and staappr = v_arr_staappr(2))
          or (v_arr_staappr(3) is not null and staappr = v_arr_staappr(3))
          or (v_arr_staappr(4) is not null and staappr = v_arr_staappr(4))
          or (v_arr_staappr(5) is not null and staappr = v_arr_staappr(5)))
         and codapp like nvl(v_codapp,codapp)
         and staappr in ('P','A')
      order by dtereq desc,numseq desc,codapp ))
      where cnt between v_start and  (v_start + v_limit)-1;
  begin

    initial_value(json_str_input);
    hcm_util.set_lang(global_v_lang);

    obj_row := json_object_t();
    v_rcnt := 0;
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
      v_flgdata := true;
      obj_data := json_object_t();
      obj_data.put('coderror','');
      obj_data.put('desc_coderror','');
      obj_data.put('httpcode','');
      obj_data.put('flg','');
      obj_data.put('total',to_char('0'));
      obj_data.put('codapp',r1.codapp);
      obj_data.put('desc_staappr',r1.desc_staappr);
      obj_data.put('descapp',r1.descapp);
      obj_data.put('staappr',r1.staappr);
      obj_data.put('detail1',r1.detail1);
      obj_data.put('detail2',r1.detail2);
      obj_data.put('dtereq',hcm_util.get_date_buddhist_era(r1.dtereq));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if not v_flgdata then
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('coderror','');
      obj_data.put('desc_coderror','');
      obj_data.put('httpcode','');
      obj_data.put('flg','');
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  -----------------------------------------------------------------

end;

/

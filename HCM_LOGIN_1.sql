--------------------------------------------------------
--  DDL for Package Body HCM_LOGIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_LOGIN" is
-- last update: 03/07/2023 10:32

  function base64_encode(t in varchar2) return varchar2 is
    begin
      return utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(t)));
  end base64_encode;

  function base64_decode(t in varchar2) return varchar2 is
    begin
      return utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(t)));
  end base64_decode;

  function get_special_char return varchar2 is
    v_special           varchar2(4000 char);
    v_special_concat    varchar2(10 char);

    cursor c_special is
      select code,text
        from tchkpass
       where code in (33,36,37,38,42,43,45,46,58,60,61,62,63,64,91,93,94,95,124)
--       where (code between 36 and 47) or (code between 58 and 64) or
--             (code between 91 and 96) or (code between 123 and 126)
      order by code;
  begin
    for r_special in c_special loop
      v_special := v_special||v_special_concat||r_special.text;
      v_special_concat := '';
    end loop;
    return v_special;
  end;

  function msg_error(p_code in varchar2,p_lang in varchar2,p_table in varchar2 default null) return varchar2 is
     v_desc        varchar2(4000 char);
  begin
    if p_table is null then
        v_desc := pdk.error_msg(p_code,p_lang);
    else
        v_desc := pdk.error_table(p_table,p_code,p_lang) ;
    end if;
    return v_desc;
  end;
  --

  FUNCTION check_pwd2 RETURN varchar2 IS
    v_dd        number;--varchar2(2);
    v_mm        number;--varchar2(2);
    v_yy        number;--varchar2(4);
    v_sum       varchar2(10 char);
    v_tail      varchar2(10 char);
    v_codpass   varchar2(6 char);
    a           number;
    b           number;
    c           number;
    d           number;
    v_date_gen  number; -- period change
  BEGIN
    v_dd := to_char(sysdate,'dd');
    v_mm := to_char(sysdate,'mm');
    v_yy := to_char(sysdate,'yyyy');
    if v_yy > 2500 then
       v_yy := v_yy - 543;
    end if;

    begin
        v_date_gen := to_number(nvl(get_tsetup_value('PPSIMPPWD'),0));
    exception when others then
        v_date_gen := 0;
    end;

    v_sum := to_char(((v_dd * v_mm * v_yy ) + v_date_gen) mod 10000);
    a := ascii(nvl(substr(v_sum,1,1),' ')) mod 9;
    b := ascii(nvl(substr(v_sum,2,1),' ')) mod 8;
    c := ascii(nvl(substr(v_sum,3,1),' ')) mod 7;
    d := ascii(nvl(substr(v_sum,4,1),' ')) mod 6;
    v_tail := to_char(ascii(to_char((a*b*c*d) mod 10)) mod 10);
    v_codpass := a||b||c||d||v_tail;
    return base64_encode(v_codpass);
  end;
  --
  procedure call_tsetpass is
  begin
    p_timeotp   	    := null;
    ctrl_da_01 		    := null;
    ctrl_da_02		    := null;
    ctrl_da_03		    := null;
    ctrl_da_04 		    := null;
    p_qtyotp 	        := null;
    p_qtypassmax      := null;
    p_qtypassmin      := null;
    p_qtynopass       := null;
    p_agepass 	      := null;
    p_alepass         := null;
    p_qtymistake      := null;
    p_flgchang        := null;

    select nvl(qtyalpbup,0)	,nvl(qtyalpblow,0) ,nvl(qtyspecail,0) ,nvl(qtynumdigit,0)  ,timeotp ,
           qtyotp           ,qtypassmax        ,qtypassmin        ,qtynopass           ,agepass	,
           alepass 	        ,qtymistake        ,flgchang

    into 	 ctrl_da_01,        ctrl_da_02,             ctrl_da_03,             ctrl_da_04,           p_timeotp,
           p_qtyotp,          p_qtypassmax,           p_qtypassmin,           p_qtynopass,          p_agepass,
           p_alepass,         p_qtymistake,           p_flgchang
    from tsetpass
    where trunc(dteeffec) = (select max(dteeffec) from tsetpass where dteeffec <= trunc(sysdate))
    and rownum = 1;

  exception when no_data_found then
      null;
  end;

  function get_license_mock(p_module varchar) return number is
  begin
    if p_module = 'RP' then
      return 100;
    elsif p_module = 'RC' then
      return 100;
    elsif p_module = 'PM' then
      return 100;
    elsif p_module = 'TR' then
      return 100;
    elsif p_module = 'AP' then
      return 100;
    elsif p_module = 'AL' then
      return 100;
    elsif p_module = 'BF' then
      return 100;
    elsif p_module = 'PY' then
      return 100;
    elsif p_module = 'MS' then
      return 300;
    elsif p_module = 'ES' then
      return 300;
    elsif p_module = 'CO' then
      return 100;
    elsif p_module = 'SC' then
      return 100;
    else --home
      return 999;
    end if;
  end;

  function essenc(v_data in varchar2) return varchar2 is
  v_data01 varchar2(1 char);  v_data02 varchar2(1 char);  v_data03 varchar2(1 char);  v_data04 varchar2(1 char);  v_data05 varchar2(1 char);
  v_data06 varchar2(1 char);  v_data07 varchar2(1 char);  v_data08 varchar2(1 char);  v_data09 varchar2(1 char);  v_data10 varchar2(1 char);
  v_data11 varchar2(1 char);  v_data12 varchar2(1 char);  v_data13 varchar2(1 char);  v_data14 varchar2(1 char);  v_data15 varchar2(1 char);
  v_chk01 number; v_chk02 number; v_chk03 number; v_chk04 number; v_chk05 number;
  v_chk06 number; v_chk07 number; v_chk08 number; v_chk09 number; v_chk10 number;
  v_chk11 number; v_chk12 number; v_chk13 number; v_chk14 number; v_chk15 number;
  v_data_enc varchar2(200 char);
  BEGIN
    v_data01 := substr(v_data,1,1);
    v_data02 := substr(v_data,2,1);
    v_data03 := substr(v_data,3,1);
    v_data04 := substr(v_data,4,1);
    v_data05 := substr(v_data,5,1);
    v_data06 := substr(v_data,6,1);
    v_data07 := substr(v_data,7,1);
    v_data08 := substr(v_data,8,1);
    v_data09 := substr(v_data,9,1);
    v_data10 := substr(v_data,10,1);
    v_data11 := substr(v_data,11,1);
    v_data12 := substr(v_data,12,1);
    v_data13 := substr(v_data,13,1);
    v_data14 := substr(v_data,14,1);
    v_data15 := substr(v_data,15,1);
    v_chk01 := trunc(dbms_random.value(1,9));
    v_chk02 := trunc(dbms_random.value(1,9));
    v_chk03 := trunc(dbms_random.value(1,9));
    v_chk04 := trunc(dbms_random.value(1,9));
    v_chk05 := trunc(dbms_random.value(1,9));
    v_chk06 := trunc(dbms_random.value(1,9));
    v_chk07 := trunc(dbms_random.value(1,9));
    v_chk08 := trunc(dbms_random.value(1,9));
    v_chk09 := trunc(dbms_random.value(1,9));
    v_chk10 := trunc(dbms_random.value(1,9));
    v_chk11 := trunc(dbms_random.value(1,9));
    v_chk12 := trunc(dbms_random.value(1,9));
    v_chk13 := trunc(dbms_random.value(1,9));
    v_chk14 := trunc(dbms_random.value(1,9));
    v_chk15 := trunc(dbms_random.value(1,9));
    v_data_enc := v_chk14||ltrim(to_char(nvl(ascii(v_data12),0)+(v_chk12*12),'000'))||
                  v_chk03||ltrim(to_char(nvl(ascii(v_data06),0)+(v_chk06*6),'000'))||
                  v_chk13||ltrim(to_char(nvl(ascii(v_data02),0)+(v_chk02*2),'000'))||
                  v_chk05||ltrim(to_char(nvl(ascii(v_data01),0)+(v_chk01*1),'000'))||
                  v_chk06||ltrim(to_char(nvl(ascii(v_data13),0)+(v_chk13*13),'000'))||
                  v_chk15||ltrim(to_char(nvl(ascii(v_data05),0)+(v_chk05*5),'000'))||
                  v_chk04||ltrim(to_char(nvl(ascii(v_data03),0)+(v_chk03*3),'000'))||
                  v_chk08||ltrim(to_char(nvl(ascii(v_data07),0)+(v_chk07*7),'000'))||
                  v_chk07||ltrim(to_char(nvl(ascii(v_data14),0)+(v_chk14*14),'000'))||
                  v_chk09||ltrim(to_char(nvl(ascii(v_data11),0)+(v_chk11*11),'000'))||
                  v_chk12||ltrim(to_char(nvl(ascii(v_data08),0)+(v_chk08*8),'000'))||
                  v_chk01||ltrim(to_char(nvl(ascii(v_data04),0)+(v_chk04*4),'000'))||
                  v_chk10||ltrim(to_char(nvl(ascii(v_data15),0)+(v_chk15*15),'000'))||
                  v_chk02||ltrim(to_char(nvl(ascii(v_data09),0)+(v_chk09*9),'000'))||
                  v_chk11||ltrim(to_char(nvl(ascii(v_data10),0)+(v_chk10*10),'000'));
      RETURN v_data_enc;
  exception when others then
    return DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
  END ESSENC;

  function ess_get_lrunning(json_str clob) return varchar2 is
    json_obj        json_object_t;
    v_lrunning      number;
  begin
    json_obj       := json_object_t(json_str);
    v_lrunning     := to_number(hcm_util.get_string_t(json_obj,'p_lrunning')); --lrunning
    if v_lrunning is null or v_lrunning = '' then
      begin
        select nvl(max(lrunning)+1,1)	into v_lrunning
        from 	tlogin;
        exception when no_data_found then
          v_lrunning := 1;
      end;
    end if;

    return v_lrunning;
  end;

  function get_lrunning(json_str clob) return varchar2 is
    json_obj        json_object_t;
    v_lrunning      number;
  begin
    json_obj       := json_object_t(json_str);
    v_lrunning     := to_number(hcm_util.get_string_t(json_obj,'p_lrunning')); --lrunning
    if v_lrunning is null or v_lrunning = '' then
      begin
        select nvl(max(lrunning)+1,1)	into v_lrunning
        from 	tlogin;
        exception when no_data_found then
          v_lrunning := 1;
      end;
    end if;

    return v_lrunning;
  end;

  procedure authen_middleware(json_str_input in clob,json_str_output out clob) is
    json_obj        json_object_t;
    obj_data        json_object_t;
    v_lrunning      number;
    v_coduser       varchar2(100 char);
    v_loginid       varchar2(100 char);
    v_ldtein        date;
    v_ldteout       date;
    v_lterminal     varchar2(30 char);
    v_lipaddress    varchar2(20 char);
    o_lcodrun       varchar2(30 char);
    v_lcodrun       varchar2(30 char);
    v_lcodsub       varchar2(10 char);
    v_laccess       varchar2(20 char);
    v_sid           number;
    v_serial        number;
    v_license_used  number := 0;
    v_license_max   number := 0;
    bool_license    boolean := false;
    bool_active     boolean := false;
    bool_newuser    boolean := false;
    bool_lock       boolean := false;

    v_codapp        varchar2(30 char);
    v_result        varchar2(1000 char);
    v_remark        varchar2(200 char);
    v_codproc       varchar2(200 char);
    v_flgauth       varchar2(200 char);
    v_permission    varchar2(200 char);
    v_flgpermis     boolean := false;
    v_chk_codapp    number := 0;
    numYearReport   number := 0;

    v_logpm         number;
    v_logpy         number;
    v_logal         number;
    v_logtr         number;
    v_logap         number;
    v_logbf         number;
    v_logrc         number;
    v_logrp         number;
    v_loges         number;
    v_logms         number;
    v_logel         number;
    v_logjo         number;

    p_type_license  varchar2(10 char);
    p_license       number;
    p_license_Emp   number;
    v_rand          number := 1;

    cursor c_permission is
      select b.codproc,b.flgauth
        from tprocapp a,tusrproc b
       where a.codproc = b.codproc(+)
         and a.codapp  = v_codapp
         and b.coduser = v_coduser
         and b.codproc = nvl(v_codproc, b.codproc)
      order by b.codproc;

  begin
    json_obj       := json_object_t(json_str_input);

    v_lrunning     := to_number(hcm_util.get_string_t(json_obj,'p_lrunning')); --lrunning

    v_coduser      := upper(hcm_util.get_string_t(json_obj,'p_coduser')); --coduser
    v_loginid      := hcm_util.get_string_t(json_obj,'p_loginid'); --username
    v_ldtein       := sysdate;
    v_ldteout      := null;
    --v_lterminal    := hcm_util.get_string_t(json_obj,'p_lterminal'); --hostname
    v_lipaddress   := substr(replace(hcm_util.get_string_t(json_obj,'p_lipaddress'),':'),1,20); --ipaddress
    v_codapp       := upper(hcm_util.get_string_t(json_obj,'p_codapp'));
    v_codproc      := upper(hcm_util.get_string_t(json_obj,'p_codproc'));
    v_laccess      := 'HRMSONLINE';
    v_sid          := null;
    v_serial       := null;

    numYearReport := HCM_APPSETTINGS.get_additional_year();
    if substr(v_codapp,1,2) = 'HR' then
      v_lcodrun := v_codapp;
      v_lcodsub := substr(v_codapp,3,2);
    else
      v_lcodrun := 'MENU';
    end if;
    v_license_max  := get_license('', v_lcodsub);
--    v_license_max  := get_license_mock(v_lcodsub);

    if v_coduser is not null then
      clear_session_php;  -- check timeout
      begin
        select lrunning into v_lrunning
          from tlogin
         where lrunning = v_lrunning
           and luserid  = v_coduser;
         bool_active   := true;
      exception when no_data_found then
        null;
      end;


      if bool_active then
        --check license
        if v_lcodrun in ('MENU','LOGIN','PROFILEIMG') then
          bool_license := true;
          v_lcodsub := null;
        else

--<< user22 : 07/08/2022 : ST11 ||
          std_sc.get_license_Info(p_type_license, p_license, p_license_Emp);
          if v_lcodsub in ('ES','MS') and nvl(p_type_license,'1') = '2' then
            if p_license_Emp <= p_license then
              bool_license := true;
            end if;
          else
            if v_lcodsub is not null then
              begin
                select count(lcodsub) into v_license_used
                  from tlogin
                 where lcodsub = v_lcodsub
                   and lrunning <> v_lrunning
                   and (luserid not in ('PPSIMP','PPSADM') or (luserid not like 'PPS%'));
              exception when no_data_found then
                v_license_used := 0;
              end;
            end if;          
            if v_license_used < v_license_max then
              bool_license := true;
            end if;
          end if;
          /*
          if v_lcodsub is not null then
            begin
              select count(lcodsub) into v_license_used
                from tlogin
               where lcodsub = v_lcodsub
                 and lrunning <> v_lrunning
                 and (luserid not in ('PPSIMP','PPSADM') or (luserid not like 'PPS%'));
            exception when no_data_found then
              v_license_used := 0;
            end;
          end if;          
          if v_license_used < v_license_max then
            bool_license := true;
          end if;*/          
-->> user22 : 07/08/2022 : ST11 ||   
          if v_coduser in ('PPSIMP','PPSADM') or v_codapp in ('HRSC14D','HRSC08X') or v_coduser like 'PPS%' then
            bool_license := true;
          end if;
        end if;

        if bool_license = true then
          update tlogin set lcodrun = v_lcodrun,lcodsub = v_lcodsub where lrunning = v_lrunning and luserid  = v_coduser;
          update tusrprof set timepswd = 0, llogidte = sysdate where coduser = v_coduser;
          commit;
        else
          begin
            insert into thislogin2 (
              lrunning, ldteacc, luserid, loginid,
              ldtein, ldteout, lterminal, lipaddress,
              lcodrun, lcodsub, laccess
            )
            values (
              v_lrunning, sysdate, v_coduser, v_loginid,
              v_ldtein, v_ldteout, v_lterminal, v_lipaddress,
              v_lcodrun, v_lcodsub, v_laccess
            );
          exception when others then
            null;
          end;
        end if;
        begin  -- user32 : 19/06/2020 , change select remark to select dtestrt - dteend
          select remark||chr(10)||to_char(add_months(dtestrt, numYearReport*12),'dd/mm/yyyy')|| ' ' ||to_char(to_date(timstrt,'hh24:mi'),'hh24:mi')
                 ||' - '||
                 to_char(add_months(dteend, numYearReport*12),'dd/mm/yyyy') || ' ' || to_char(to_date(timend,'hh24:mi'),'hh24:mi')
            into v_remark
            from tfunclock
           where codapp = v_lcodrun
             and sysdate between to_date(to_char(dtestrt,'dd/mm/yyyy')||timstrt,'dd/mm/yyyyhh24mi')
             and to_date(to_char(dteend,'dd/mm/yyyy')||timend,'dd/mm/yyyyhh24mi');
            bool_lock := true;
          exception when no_data_found then
              v_remark := null;
              bool_lock := false;
        end;
      end if; --bool_active
    end if;

    if bool_active then
      if bool_license then
        if bool_lock then
          v_result := 'LOCK';
        else
          --<< for security Pentest
--          v_result := 'SUCCESS';
          v_rand := trunc(DBMS_RANDOM.value(1,5)); -- random mode 1,2,3,4
          if v_rand = 1 then
            v_result := replace(base64_encode(v_codproc||'$'||v_codapp||'#'||'SUCCESS'||trunc(DBMS_RANDOM.value(100,999))),'=='); 
          elsif v_rand = 2 then
            v_result := replace(base64_encode(v_codapp||'#'||'SUCCESS'||'&'||v_codproc||trunc(DBMS_RANDOM.value(100,999))),'==');  
          elsif v_rand = 3 then
            v_result := replace(base64_encode('SUCCESS'||'@'||v_codproc||'$'||v_codapp||trunc(DBMS_RANDOM.value(100,999))),'=='); 
          else
            v_result := replace(base64_encode('SUCCESS'||'&'||v_codapp||'@'||v_codproc||trunc(DBMS_RANDOM.value(100,999))),'==');  
          end if;
          v_result := base64_encode(DBMS_RANDOM.string('x',5)||v_result||DBMS_RANDOM.string('x',5));
          v_result := base64_encode(DBMS_RANDOM.string('x',5)||v_result||DBMS_RANDOM.string('x',5));
          v_result := replace(DBMS_RANDOM.string('x',5)||v_result||DBMS_RANDOM.string('x',5),'==');
          -->> for security Pentest
        end if;
        if v_lcodsub = 'PM' then
          v_logpm := v_license_used + 1;
        elsif v_lcodsub = 'PY' then
          v_logpy := v_license_used + 1;
        elsif v_lcodsub = 'AL' then
          v_logal := v_license_used + 1;
        elsif v_lcodsub = 'TR' then
          v_logtr := v_license_used + 1;
        elsif v_lcodsub = 'AP' then
          v_logap := v_license_used + 1;
        elsif v_lcodsub = 'BF' then
          v_logbf := v_license_used + 1;
        elsif v_lcodsub = 'RC' then
          v_logrc := v_license_used + 1;
        elsif v_lcodsub = 'RP' then
          v_logrp := v_license_used + 1;
        elsif v_lcodsub = 'ES' then
          v_loges := v_license_used + 1;
        elsif v_lcodsub = 'MS' then
          v_logms := v_license_used + 1;
        elsif v_lcodsub = 'EL' then
          v_logel := v_license_used + 1;
        elsif v_lcodsub = 'JO' then
          v_logjo := v_license_used + 1;
        end if;
        begin
          insert into tsumlogin(datesum,logpm,logpy,logal,logtr,logap,logbf,logrc,logrp,loges,logms,logel,logjo)
                         values(trunc(sysdate),nvl(v_logpm,0),nvl(v_logpy,0),nvl(v_logal,0),nvl(v_logtr,0),nvl(v_logap,0),nvl(v_logbf,0),nvl(v_logrc,0),nvl(v_logrp,0),nvl(v_loges,0),nvl(v_logms,0),nvl(v_logel,0),nvl(v_logjo,0));
        exception when dup_val_on_index then
          update tsumlogin
             set logpm = greatest(logpm,nvl(v_logpm,0)),
                 logpy = greatest(logpy,nvl(v_logpy,0)),
                 logal = greatest(logal,nvl(v_logal,0)),
                 logtr = greatest(logtr,nvl(v_logtr,0)),
                 logap = greatest(logap,nvl(v_logap,0)),
                 logbf = greatest(logbf,nvl(v_logbf,0)),
                 logrc = greatest(logrc,nvl(v_logrc,0)),
                 logrp = greatest(logrp,nvl(v_logrp,0)),
                 loges = greatest(loges,nvl(v_loges,0)),
                 logms = greatest(logms,nvl(v_logms,0)),
                 logel = greatest(logel,nvl(v_logel,0)),
                 logjo = greatest(logjo,nvl(v_logjo,0))
           where datesum  = trunc(sysdate);
        end;
      else
        v_result := 'LICENSE';
        v_remark := nvl(get_tsetup_value('WAITINGTIME'),'10'); -- time for waiting when full license (second)
      end if;
    else
      v_result := 'TIMEOUT';
    end if;
    commit;

    --<< find permission
    v_flgauth := null;
    for r_permission in c_permission loop
      v_flgpermis := true;
      v_codproc := r_permission.codproc;
      v_flgauth := r_permission.flgauth;
      exit;
    end loop;

    begin
      select count(*)
        into v_chk_codapp
        from tprocapp a, tusrproc b
       where a.codproc = b.codproc
         and b.coduser = v_coduser
         and a.codapp  = v_codapp;
    exception when others then
      v_chk_codapp := 0;
    end;

    if v_chk_codapp > 0 then
      if not v_flgpermis then
        v_result := 'LOCK';
      end if;
    else
      if v_codapp like 'HR%' then
        v_result := 'LOCK';
      end if;
    end if;

    v_permission := nvl(v_flgauth,'1');
    if v_flgauth = '3' then
      begin
        select codapp
          into v_lcodrun
          from tusrproac
         where coduser = v_coduser
           and codproc = v_codproc
           and codapp  = v_codapp;
        v_permission := '2';
      exception when no_data_found then
        v_permission := '1';
      end;
    end if;

    -- function report must have permission (hres67x)
    if substr(v_codapp,7,1) = 'X' then
      v_permission := '2';
    end if;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('status', v_result);
    obj_data.put('message',v_remark);
    obj_data.put('permission', v_permission); -- 1=read only, 2=read+write

    json_str_output := obj_data.to_clob;

  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end authen_middleware;

  procedure remove_tlogin(json_str_input in clob,json_str_output out clob) is
    json_obj        json_object_t;
    obj_data        json_object_t;
    v_lrunning      number;
    v_result        varchar2(100 char);
    v_coduser       varchar2(100 char);
  begin
    json_obj       := json_object_t(json_str_input);
    v_lrunning     := to_number(hcm_util.get_string_t(json_obj,'p_lrunning')); --lrunning

    begin
      select luserid
        into v_coduser
        from tlogin
       where lrunning = v_lrunning;
    exception when no_data_found then
      null;
    end;
    if v_coduser in ('PPSADM','PPSIMP') then
      delete from tusrproc where coduser = v_coduser;
      delete from users    where email   = v_coduser;
      delete from tusrprof where coduser = v_coduser;
      delete from tusrcom  where coduser = v_coduser;
    end if;

    update tlogin set ldteout = sysdate,lcodsub = null where lrunning = v_lrunning;
    delete from tlogin where lrunning = v_lrunning;
    commit;

    v_result := 'SUCCESS';
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('status', v_result);

    json_str_output := obj_data.to_clob;

  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end remove_tlogin;

  procedure update_access_time(json_str_input in clob,json_str_output out clob) is
    json_obj        json_object_t;
    obj_data        json_object_t;
    v_lrunning      number;
    v_result        varchar2(30 char);
  begin
    json_obj       := json_object_t(json_str_input);
    v_lrunning     := to_number(hcm_util.get_string_t (json_obj,'p_lrunning')); --lrunning

    update tlogin set ldteacc = sysdate where lrunning = v_lrunning;
    commit;
    v_result := 'SUCCESS';

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('status', v_result);
    json_str_output := obj_data.to_clob;

  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end update_access_time;

  procedure check_catch_authentication(json_str_input in clob,json_str_output out clob) is
    p_coduser            varchar2(100 char);
    p_codpswd            varchar2(100 char);
    v_loginid            varchar2(100 char);
    v_lipaddress         varchar2(100 char);
    v_coduser            varchar2(100 char);
    v_userdomain         varchar2(100 char);
    v_userpswd           varchar2(100 char);
    v_pwddec             varchar2(100 char);
    v_chk_usr_domain     varchar2(100 char);
    v_flgact             varchar2(1 char);
    json_obj             json_object_t;
    global_timepswd      number ;
    v_timepswd           number := 0;
    obj_data             json_object_t;
  begin
     json_obj       := json_object_t(json_str_input);
     p_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
     p_codpswd      := hcm_util.get_string_t(json_obj,'p_codpswd');
     global_v_lang  := hcm_util.get_string_t(json_obj,'p_lang');
     v_loginid      := hcm_util.get_string_t(json_obj,'p_loginid');
     v_lipaddress   := substr(replace(hcm_util.get_string_t(json_obj,'p_lipaddress'),':'),1,20);

      begin
        select    userdomain,codpswd,coduser
          into    v_userdomain,v_userpswd,v_coduser
          from    tusrprof a
          where   a.userdomain  = upper(p_coduser)
          or      a.coduser     = upper(p_coduser);
      exception when others then
      v_userdomain  := null;
      v_userpswd  := null;
      v_coduser  := null;
      end;

      if v_userdomain is not null then
         v_chk_usr_domain := check_user_domain(v_userdomain,p_codpswd);
          if v_chk_usr_domain = 'Y' then
            v_pwddec := pwddec(v_userpswd,v_coduser,v_chken);
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('status', v_coduser);
            obj_data.put('message', base64_encode(v_pwddec));
            json_str_output := obj_data.to_clob;
            return;
          end if;
      end if;

      begin
        select    flgact
          into    v_flgact
          from    tusrprof a, users b
          where   a.coduser  = upper(p_coduser)
          and     a.coduser  = b.email;
      exception when no_data_found then
      v_flgact  := null;
      end;
      if v_flgact is null then
--        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TUSRPROF', null, false);
        param_msg_error := get_error_msg_php('HR3018', global_v_lang,null, null, false);
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      elsif v_flgact is not null then
        call_tsetpass;
        begin
          select timepswd
            into v_timepswd
            from tusrprof
           where coduser = upper(p_coduser);
        end;

        if p_qtymistake is not null then
          global_timepswd := p_qtymistake;
        else
          global_timepswd := 3;
        end if;

        if v_timepswd >= global_timepswd then
          param_msg_error := get_error_msg_php('HR3045', global_v_lang);
          json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        else
         param_msg_error := get_error_msg_php('HR3018', global_v_lang); -- HR3015
         json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        end if;

        -- insert log login fail
        begin
          insert into terrlogin (lterminal,loginid,ldteacc,luserid,lipaddress,lremark)
          values(v_loginid,v_loginid,sysdate,p_coduser,v_lipaddress,'Invalid Password');
        exception when others then
            update terrlogin
               set luserid    = p_coduser,
                   lipaddress = v_lipaddress,
                   lremark    = 'Invalid Password'
             where lterminal  = v_loginid
               and loginid    = v_loginid
               and ldteacc    = sysdate;
        end;

        -- update login time fail
        begin
         update tusrprof
             set timepswd = timepswd + 1
           where coduser = upper(p_coduser);
        end;
        commit;

      end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,'102');
  end check_catch_authentication;

  function get_user(json_str_input in clob) return varchar2 is
    obj_data             json_object_t;
    obj_data_comp        json_object_t;
    json_obj             json_object_t;
    p_output             clob;
    v_codcomp            varchar2(4000 char);
    v_codcompy           varchar2(4000 char);
    v_codpos             varchar2(4000 char);
    v_index_arr          number;
    v_namimage           varchar2(500 char);
    v_folder             varchar2(4000 char);
    v_path_image         varchar2(500) := get_tsetup_value('PATHWORKPHP');
    v_namimageprof       varchar2(500 char);
    v_folderprof         varchar2(4000 char);
    v_email              varchar2(500 char);
    v_error_msg          varchar2(500 char);
    v_staemp             varchar2(1 char);
    v_flgact             varchar2(1 char);

    global_timepswd      number ;
    v_timepswd           number := 0;
    v_lupswdte           date;
    v_warn_text          varchar2(500 char);
    v_flgchgpass         varchar2(1 char);
    v_lrunning           number ;
    v_loginid            varchar2(100 char);
    v_ldtein             date;
    v_ldteout            date;
    v_lterminal          varchar2(100 char);
    v_lipaddress         varchar2(100 char);
    o_lcodrun            varchar2(30 char);
    v_lcodrun            varchar2(30 char);
    v_lcodsub            varchar2(10 char);
    v_laccess            varchar2(20 char);
    v_sid                number;
    v_serial             number;
    v_codapp             varchar2(100 char);
    p_coduser            varchar2(100 char);
    p_codempid           varchar2(100 char);
    v_flg_act            varchar2(20 char);

    -- pdpa
    obj_row_pdpa         json_object_t;
    obj_data_pdpa        json_object_t;
    v_pdpa_rcnt          number;
    v_pdpa_numitem       tempconst.numitem%type;
    v_pdpa_dteeffec      tempconst.dteeffec%type;
    v_flgconst           tempconst.flgconst%type;
    v_comlevel           tcenter.comlevel%type;
    v_codcomp_by_level   tcenter.codcomp%type;

    v_typeuser           tusrprof.typeuser%type;

    -- license
    obj_row_license      json_object_t;
    obj_data_license     json_object_t;

    p_type_license  varchar2(10 char);
    p_license       number;
    p_license_Emp   number;
    v_license       number;

    -- get comp for lov
    cursor c_tusrcom is
      select codcomp
      from   tusrcom
      where  coduser = upper(p_coduser);

    -- get pdpa
    cursor c_tpdpaitem is
      select dteeffec,numitem,
             decode(global_v_lang,'101',desobjte,
                                  '102',desobjtt,
                                  '103',desobjt3,
                                  '104',desobjt4,
                                  '105',desobjt5,desobjtt
                                  ) desobjt,
             decode(global_v_lang,'101',desiteme,
                                  '102',desitemt,
                                  '103',desitem3,
                                  '104',desitem4,
                                  '105',desitem5,desitemt
                                  ) desitem
        from tpdpaitem
       where codcompy        = v_codcompy
         and trunc(dteeffec) = v_pdpa_dteeffec
      order by numitem;

    cursor c_license is
      select list_value as codproc,desc_label as module, get_license('',desc_label) license
        from tlistval
       where codapp  = 'STDMODULE'
         and codlang = '102'
      order by list_value;

  begin
      json_obj       := json_object_t(json_str_input);
      p_coduser      := upper(hcm_util.get_string_t(json_obj,'p_coduser')); --coduser
      p_codempid      := upper(hcm_util.get_string_t(json_obj,'p_codempid')); --coduser
      v_loginid      := hcm_util.get_string_t(json_obj,'p_loginid'); --username
      v_lrunning     := to_number(hcm_util.get_string_t(json_obj,'p_lrunning')); --lrunning
      v_ldtein       := sysdate;
      v_ldteout      := null;
      v_lipaddress   := substr(replace(hcm_util.get_string_t(json_obj,'p_lipaddress'),':'),1,20); --ipaddress
      v_codapp       := upper(hcm_util.get_string_t(json_obj,'p_codapp'));
      global_v_lang  := upper(hcm_util.get_string_t(json_obj,'p_lang'));
      v_flg_act      := (hcm_util.get_string_t(json_obj,'p_flg_act'));
      v_loginid      := hcm_util.get_string_t(json_obj,'p_loginid'); --username

  -- check user status
    begin
      select    staemp,timepswd,lupswdte,flgchgpass,flgact
        into    v_staemp,v_timepswd,v_lupswdte,v_flgchgpass,v_flgact
        from    temploy1 a, tusrprof b
        where   b.coduser  = upper(p_coduser)
        and     a.codempid = b.codempid;
      exception when no_data_found then
      v_staemp  := null;
    end;
    call_tsetpass;

    if p_qtymistake is not null then
       global_timepswd := p_qtymistake;
    else
       global_timepswd := 3;
    end if;

    if v_flgact = '2' then
      obj_data := json_object_t();
      obj_data.put('coderror','400');
      v_error_msg := get_error_msg_php('HR3025',global_v_lang);
      v_error_msg := replace(v_error_msg,'@#$%400','');
      obj_data.put('message',v_error_msg);
      p_output := obj_data.to_clob;
      return p_output;
    elsif v_flgact = '3' then
      obj_data := json_object_t();
      obj_data.put('coderror','400');
      v_error_msg := get_error_msg_php('HR3053',global_v_lang);
      v_error_msg := replace(v_error_msg,'@#$%400','');
      obj_data.put('message',v_error_msg);
      p_output := obj_data.to_clob;
      return p_output;
    elsif v_staemp is null then -- not found
      obj_data := json_object_t();
      obj_data.put('coderror','400');
      v_error_msg := get_error_msg_php('HR2010',global_v_lang,'temploy1', null, false);
      v_error_msg := replace(v_error_msg,'@#$%400','');
      obj_data.put('message',v_error_msg);
      p_output := obj_data.to_clob;
      if v_timepswd >= global_timepswd then
         v_error_msg := get_error_msg_php('HR3045',global_v_lang);
         v_error_msg := replace(v_error_msg,'@#$%400','');
         obj_data.put('message',v_error_msg);
         p_output := obj_data.to_clob;
      end if;
      return p_output;
    elsif v_staemp is not null then -- found user
      obj_data := json_object_t();
      if v_timepswd >= global_timepswd then
         obj_data.put('coderror','400');
         v_error_msg := get_error_msg_php('HR3045',global_v_lang);
         v_error_msg := replace(v_error_msg,'@#$%400','');
         obj_data.put('message',v_error_msg);
         p_output := obj_data.to_clob;
         return p_output;
      elsif p_flgchang = 'Y' and trunc(sysdate) - v_lupswdte > p_agepass then
         if v_lupswdte is not null then
           obj_data.put('coderror','400');
           v_error_msg := get_error_msg_php('HR3047',global_v_lang);
           v_error_msg := replace(v_error_msg,'@#$%400','');
           obj_data.put('message',v_error_msg);
           p_output := obj_data.to_clob;
           return p_output;
         end if;
      elsif (v_flgchgpass is null or v_flgchgpass = 'N') and p_flgchang = 'Y' then
         obj_data.put('coderror','400');
         obj_data.put('firstlogin','Y');
         p_output := obj_data.to_clob;
         return p_output;
      elsif (trunc(v_lupswdte) + p_agepass - 1 - p_alepass) < trunc(sysdate) then
           obj_data.put('coderror','400');
           v_error_msg := get_error_msg_php('HR8854',global_v_lang);
           v_error_msg := replace(v_error_msg,'@#$%400','');
           v_warn_text := v_error_msg;
      end if;
    end if;

    if v_flg_act = 'login' then
      -- Insert Lruning
      begin
        select    nvl(max(lrunning)+1,1)	into v_lrunning
        from 	    tlogin;
        exception when no_data_found then
        v_lrunning := 1;
      end;

      v_laccess      := 'HRMSONLINE';
      v_sid          := null;
      v_serial       := null;
      v_lcodrun      := null;
      v_lcodsub      := null;

      v_lterminal    := substr(essenc(hcm_util.get_string_t(json_obj,'p_codpswd')),1,30); --key for encode decode
      begin
        insert into tlogin (
          lrunning,     luserid,      loginid,    ldtein,
          lterminal,    lipaddress,   lcodrun,    lcodsub,
          laccess,      sid,          serial
        )
        values(
          v_lrunning,   p_coduser,    v_loginid,  v_ldtein,
          v_lterminal,  v_lipaddress, v_lcodrun,  v_lcodsub,
          v_laccess,    v_sid,        v_serial
        );
      exception when others then
        null;
      end;
    else  -- case switch user
      update tlogin
         set luserid  = p_coduser,
             ldtein   = v_ldtein
       where lrunning = v_lrunning;
    end if;

    -- get employee image (PM)
    begin
      select  namimage
      into    v_namimage
      from    tempimge
      where   codempid  = p_codempid;
    exception when no_data_found then
      v_namimage  := null;
    end;

    begin
      select  folder
      into    v_folder
      from    tfolderd
      where   codapp  = 'HRPMC2E1';
    exception when no_data_found then
      v_folder := null;
    end;

    -- get image profile (Dashboard)
    begin
      select value
        into v_namimageprof
        from tusrconfig
        where coduser = p_coduser
        and codvalue = 'PROFILEIMG';
    exception when no_data_found then
      v_namimageprof  := null;
    end;

    begin
      select  folder
      into    v_folderprof
      from    tfolderd
      where   codapp  = 'PROFILEIMG';
    exception when no_data_found then
      v_folderprof := null;
    end;

    -- success
    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('p_coduser',p_coduser);
    obj_data.put('p_codempid',p_codempid);
    obj_data.put('empnamee',get_temploy_name(p_codempid,'101'));
    obj_data.put('empnamet',get_temploy_name(p_codempid,'102'));
    obj_data.put('empname3',get_temploy_name(p_codempid,'103'));
    obj_data.put('empname4',get_temploy_name(p_codempid,'104'));
    obj_data.put('empname5',get_temploy_name(p_codempid,'105'));
    --
    begin
      select codcomp, codpos, email
        into v_codcomp, v_codpos, v_email
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      v_codcomp := null;
      v_codpos  := null;
    end;

    begin
        select comlevel
          into v_comlevel
          from tcenter
         where codcomp = v_codcomp;
    exception when no_data_found then
        v_comlevel := null;
    end;
    begin
      select typeuser
        into v_typeuser
        from tusrprof
       where coduser = p_coduser;
    exception when no_data_found then
       v_typeuser := null;
    end;
    v_codcomp_by_level := hcm_util.get_codcomp_level(v_codcomp,v_comlevel);
    obj_data.put('p_codcomp_level',v_comlevel);
    obj_data.put('p_codcomp_by_level',v_codcomp_by_level);

    obj_data.put('p_email',v_email);
    obj_data.put('p_codpos',v_codpos);
    obj_data.put('desc_codpose',get_tpostn_name(v_codpos,'101'));
    obj_data.put('desc_codpost',get_tpostn_name(v_codpos,'102'));
    obj_data.put('desc_codpos3',get_tpostn_name(v_codpos,'103'));
    obj_data.put('desc_codpos4',get_tpostn_name(v_codpos,'104'));
    obj_data.put('desc_codpos5',get_tpostn_name(v_codpos,'105'));
    obj_data.put('p_codcomp',v_codcomp);
    obj_data.put('desc_codcompe',get_tcenter_name(v_codcomp,'101'));
    obj_data.put('desc_codcompt',get_tcenter_name(v_codcomp,'102'));
    obj_data.put('desc_codcomp3',get_tcenter_name(v_codcomp,'103'));
    obj_data.put('desc_codcomp4',get_tcenter_name(v_codcomp,'104'));
    obj_data.put('desc_codcomp5',get_tcenter_name(v_codcomp,'105'));
    v_codcompy := get_codcompy(v_codcomp);
    obj_data.put('p_codcompy',v_codcompy);
    obj_data.put('desc_codcompye',get_tcenter_name(v_codcompy,'101'));
    obj_data.put('desc_codcompyt',get_tcenter_name(v_codcompy,'102'));
    obj_data.put('desc_codcompy3',get_tcenter_name(v_codcompy,'103'));
    obj_data.put('desc_codcompy4',get_tcenter_name(v_codcompy,'104'));
    obj_data.put('desc_codcompy5',get_tcenter_name(v_codcompy,'105'));
    obj_data.put('namimage',v_namimage);
    obj_data.put('path_image',v_path_image||v_folder);
    obj_data.put('namimageprof',v_namimageprof);
    obj_data.put('path_imageprof',v_folderprof);
    obj_data.put('p_qtyavgwk',hcm_util.get_qtyavgwk(v_codcomp,p_codempid));
    obj_data.put('warning',v_warn_text);
    obj_data.put('lrunning',v_lrunning);
    obj_data.put('typeuser',v_typeuser);

    obj_data_comp := json_object_t();
    v_index_arr := 0;
    for i in c_tusrcom loop
      obj_data_comp.put(to_char(v_index_arr),i.codcomp);
      v_index_arr := v_index_arr+1;
    end loop;
    obj_data.put('usrcom',obj_data_comp.to_clob);

    --<< pdpa
    begin
      select max(dteeffec)
        into v_pdpa_dteeffec
        from tpdpaitem
       where codcompy = v_codcompy
         and dteeffec <= trunc(sysdate)
         and rownum   = 1;
    exception when no_data_found then
      v_pdpa_dteeffec := null;
    end;

    v_flgconst := 'N';
    if v_pdpa_dteeffec is not null then
      begin
        select 'Y' into v_flgconst
          from tempconst
         where codempid = p_codempid
           and dteeffec = v_pdpa_dteeffec
           and rownum   = 1;
      exception when no_data_found then
        v_flgconst := 'N';
      end;
    end if;

    obj_row_pdpa := json_object_t();
    if v_flgconst = 'N' then
      v_pdpa_rcnt := 0;
      for r_tpdpaitem in c_tpdpaitem loop
        v_pdpa_rcnt := v_pdpa_rcnt + 1;
        obj_data_pdpa := json_object_t();
        obj_data_pdpa.put('codcompy',v_codcompy);
        obj_data_pdpa.put('numitem',r_tpdpaitem.numitem);
        obj_data_pdpa.put('dteeffec',to_char(r_tpdpaitem.dteeffec,'dd/mm/yyyy'));
        obj_data_pdpa.put('desobj',r_tpdpaitem.desobjt);
        obj_data_pdpa.put('desitem',r_tpdpaitem.desitem);
        obj_data_pdpa.put('flgconst','');
        obj_data_pdpa.put('reason','');
        obj_row_pdpa.put(to_char(v_pdpa_rcnt-1),obj_data_pdpa);
      end loop;
    end if;
    obj_data.put('pdpa',obj_row_pdpa.to_clob);
    -->> pdpa

    --<< license
    obj_row_license := json_object_t();
    for r_license in c_license loop
      obj_data_license := json_object_t();
      v_license := r_license.license;

      --<< license ess
      std_sc.get_license_Info(p_type_license, p_license, p_license_Emp);
      if r_license.module in ('ES','MS') and nvl(p_type_license,'1') = '2' then
        if p_license > 0 then -- has license
          v_license := p_license;
        end if;
      end if;
      -->> license ess

      obj_row_license.put(r_license.module,v_license);
    end loop;
    obj_data.put('license',obj_row_license.to_clob);
    -->> license

    p_output := obj_data.to_clob;

    return p_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  procedure get_autologin(json_str_input in clob,json_str_output out clob) is
    json_obj      json_object_t := json_object_t(json_str_input);
    obj_data      json_object_t;
    v_coduser     varchar2(100 char);
    v_chken       varchar2(4000 char);
    v_codpswdenc  varchar2(4000 char);
    v_codpswddec  varchar2(4000 char);
    v_esspswdenc  varchar2(4000 char);
    v_codapp      varchar2(100 char);
    v_codlang     varchar2(100 char);
    v_runno       varchar2(4000 char) := hcm_util.get_string_t(json_obj,'p_runno');
    v_round       number := 1;
    v_flg_exists  boolean := false;

    cursor c1 is
      select coduser,codapp,codlang
        from tmaillog
       where runno = v_runno;

  begin
    v_chken := hcm_secur.get_v_chken;
    for i in c1 loop
      v_flg_exists := true;
      v_coduser := i.coduser;
      v_codapp  := i.codapp;
      v_codlang := i.codlang;
    end loop;

    if v_flg_exists then
      begin
        select codpswd
          into v_codpswdenc
          from tusrprof
         where coduser = v_coduser;
      exception when no_data_found then
        v_codpswdenc := '';
      end;

      -- set first login is true for skip change password
      begin
        update tusrprof
           set flgchgpass = 'Y',
               timepswd = 0
         where coduser  = v_coduser;
      exception when others then
        null;
      end;

      v_codpswddec := pwddec(v_codpswdenc, v_coduser, v_chken);
      v_esspswdenc := v_codpswddec;
      v_round := to_number(floor(dbms_random.value(1,5)));
      for i in 1..v_round loop
        v_esspswdenc := base64_encode(v_esspswdenc);
      end loop;
      v_esspswdenc := to_char(v_round)||v_esspswdenc;

      begin
        delete from tmaillog where runno = v_runno;
      end;
      commit;

    end if;

    obj_data  := json_object_t();
    obj_data.put('coderror','');
    obj_data.put('desc_coderror','');
    obj_data.put('httpcode','');
    obj_data.put('flg','');
    obj_data.put('coduser',v_coduser);
    obj_data.put('codpswd',v_esspswdenc);
    obj_data.put('codapp',v_codapp);
    obj_data.put('codlang',v_codlang);
    json_str_output := obj_data.to_clob;
  end get_autologin;
  --
  ----------------------------- Change Password New ---------------------
  procedure check_format_password(p_password varchar2) is
    v_cnt_upper     number := 0;
    v_cnt_lower     number := 0;
    v_cnt_special   number := 0;
    v_cnt_number	  number := 0;
    v_code_upper    number := 0;
    v_code_lower    number := 0;
    v_code_special  number := 0;
    v_code_number   number := 0;
--    v_cntpass				number;
  begin
    if p_qtypassmin is not null then
      if length(p_password) < p_qtypassmin then
        param_msg_error := msg_error('HR8851',global_v_lang);
        return;
      end if;
    end if;

    if p_qtypassmax is not null then
      if length(p_password) > p_qtypassmax then
        param_msg_error := msg_error('HR8851',global_v_lang);
        return;
      end if;
    end if;

    for i in 1..length(p_password) loop
      if nvl(ctrl_da_01,0) > 0 then
      -- Upper
        begin
          select code into v_code_upper
          from   tchkpass
          where  text = substr(p_password,i,1)
          and    code between 65 and 90;
          v_cnt_upper := v_cnt_upper + 1;
          --
        exception when no_data_found then
          v_code_upper := null;
        end;
      end if;

      if nvl(ctrl_da_02,0) > 0 then
      -- Lower
        begin
          select code into v_code_lower
          from tchkpass
          where text = substr(p_password,i,1)
          and code between 97 and 122;
          v_cnt_lower := v_cnt_lower + 1;
          --
        exception when no_data_found then
          v_code_lower := null;
        end;
      end if;

      if nvl(ctrl_da_03,0) > 0 then
      -- Special
        begin
          select code into v_code_special
          from tchkpass
          where text = substr(p_password,i,1)
          and (
            (code between 32 and 47) or (code between 58 and 64) or
            (code between 91 and 96) or (code between 123 and 126)
              );
          v_cnt_special := v_cnt_special + 1;
          --
        exception when no_data_found then
          v_code_special := null;
        end;
      end if;

      if nvl(ctrl_da_04,0) > 0 then
      -- Number
        begin
          select code into v_code_number
          from tchkpass
          where text = substr(p_password,i,1)
          and code between 48 and 57;
          v_cnt_number := v_cnt_number + 1;
          --
        exception when no_data_found then
          v_code_number := null;
        end;
      end if;
    end loop;

    if  ctrl_da_01 > 0 then --upper
      if 	v_cnt_upper < ctrl_da_01 then
        param_msg_error := msg_error('HR8851',global_v_lang);
        return;
      end if;
    end if;
    if	ctrl_da_02 > 0 then --lower
      if  v_cnt_lower < ctrl_da_02 then
        param_msg_error := msg_error('HR8851',global_v_lang);
        return;
      end if;
    end if;
    if ctrl_da_03 > 0 then
      if v_cnt_special < ctrl_da_03 then
        param_msg_error := msg_error('HR8851',global_v_lang);
        return;
      end if;
    end if;
    if ctrl_da_04 > 0 then
      if v_cnt_number < ctrl_da_04 then
        param_msg_error := msg_error('HR8851',global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure change_password(json_str_input in clob,json_str_output out clob) is
    json_obj            json_object_t;
    obj_data            json_object_t;
    obj_format          json_object_t;
    obj_row             json_object_t;
    p_coduser           varchar2(1000 char);
    p_codpswd           varchar2(1000 char);
    p_codpswd_new       varchar2(1000 char);
    p_codpswd_hash      varchar2(1000 char);
    p_codpswd_base64    varchar2(1000 char);
    v_code              varchar2(1000 char);
    v_num               number;
    v_timepswd          number;
    v_dateotp           date;

    v_msg_qtypassmax    varchar2(1000 char);
    v_msg_qtypassmin    varchar2(1000 char);
    v_msg_qtynumdigit   varchar2(1000 char);
    v_msg_qtyspecail    varchar2(1000 char);
    v_msg_qtyalpbup     varchar2(1000 char);
    v_msg_qtyalpblow    varchar2(1000 char);
    v_msg_unit          varchar2(1000 char);
    v_special           varchar2(4000 char);

    cursor c_tchangpass is
      select codpswd
        from tchangpass
       where coduser  = p_coduser
         and rownum   <= p_qtynopass
      order by dtechng desc;
  begin
    json_obj      := json_object_t(json_str_input);
    p_coduser     := upper(hcm_util.get_string_t(json_obj,'p_coduser'));
    p_codpswd     := hcm_util.get_string_t(json_obj,'p_codpswd');
    p_codpswd_new := hcm_util.get_string_t(json_obj,'p_codpswd_new');
    p_flgaction   := hcm_util.get_string_t(json_obj,'p_flgaction');
    global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');

    p_codpswd_hash := p_codpswd;
    p_codpswd_base64 := p_codpswd_new;
    p_codpswd_new := base64_decode(p_codpswd_new);
    --
    call_tsetpass;
    if p_flgaction = 'change' then
      for r_tchangpass in c_tchangpass loop
        if r_tchangpass.codpswd = p_codpswd_base64 then
          param_msg_error := msg_error('HR8850',global_v_lang);
          exit;
        end if;
      end loop;
    elsif p_flgaction = 'forgot' then
       begin
        select coduser,dteotp
          into v_code,v_dateotp
          from tusrprof
         where coduser = p_coduser
           and rownum   = 1;
       exception when no_data_found then
        v_code := null;
        param_msg_error := msg_error('HR2010',global_v_lang,'TUSRPROF');
       end;

      if param_msg_error is null then
         if (v_dateotp+(1/1440*nvl(p_timeotp,5))) < sysdate then
            param_msg_error := msg_error('HR8852',global_v_lang);
         end if;
      end if;

    end if;
    v_num       := 0;
    obj_data    := json_object_t();
    obj_row     := json_object_t();
    if param_msg_error is null then
       check_format_password(p_codpswd_new);

      if param_msg_error is not null then
        begin
          select  max(decode(numseq,10,decode(global_v_lang,'101',desclabele,
                                                     '102',desclabelt,
                                                     '103',desclabel3,
                                                     '104',desclabel4,
                                                     '105',desclabel5))),
                  max(decode(numseq,20,decode(global_v_lang,'101',desclabele,
                                                     '102',desclabelt,
                                                     '103',desclabel3,
                                                     '104',desclabel4,
                                                     '105',desclabel5))),
                  max(decode(numseq,30,decode(global_v_lang,'101',desclabele,
                                                     '102',desclabelt,
                                                     '103',desclabel3,
                                                     '104',desclabel4,
                                                     '105',desclabel5))),
                  max(decode(numseq,40,decode(global_v_lang,'101',desclabele,
                                                     '102',desclabelt,
                                                     '103',desclabel3,
                                                     '104',desclabel4,
                                                     '105',desclabel5))),
                  max(decode(numseq,50,decode(global_v_lang,'101',desclabele,
                                                     '102',desclabelt,
                                                     '103',desclabel3,
                                                     '104',desclabel4,
                                                     '105',desclabel5))),
                  max(decode(numseq,60,decode(global_v_lang,'101',desclabele,
                                                     '102',desclabelt,
                                                     '103',desclabel3,
                                                     '104',desclabel4,
                                                     '105',desclabel5))),
                  max(decode(numseq,70,decode(global_v_lang,'101',desclabele,
                                                     '102',desclabelt,
                                                     '103',desclabel3,
                                                     '104',desclabel4,
                                                     '105',desclabel5)))
          into    v_msg_qtypassmax,
                  v_msg_qtypassmin,
                  v_msg_qtynumdigit,
                  v_msg_qtyspecail,
                  v_msg_qtyalpblow,
                  v_msg_qtyalpbup,
                  v_msg_unit
          from    tapplscr
          where   codapp = 'MSGLOGIN';
        exception when no_data_found then
          null;
        end;

        if p_qtypassmax is not null then
          v_num             := v_num + 1;
          v_msg_qtypassmax  := v_msg_qtypassmax||' '||p_qtypassmax||' '||v_msg_unit;
          obj_format        := json_object_t();
          obj_format.put('message_alert',v_msg_qtypassmax);
          obj_row.put(to_char(v_num-1),obj_format);
        end if;

        if p_qtypassmin is not null then
          v_num             := v_num + 1;
          v_msg_qtypassmin  := v_msg_qtypassmin||' '||p_qtypassmin||' '||v_msg_unit;
          obj_format        := json_object_t();
          obj_format.put('message_alert',v_msg_qtypassmin);
          obj_row.put(to_char(v_num-1),obj_format);
        end if;

        if ctrl_da_01 > 0 then --upper
          v_num             := v_num + 1;
          v_msg_qtyalpbup   := v_msg_qtyalpbup||' '||ctrl_da_01||' '||v_msg_unit;
          obj_format        := json_object_t();
          obj_format.put('message_alert',v_msg_qtyalpbup);
          obj_row.put(to_char(v_num-1),obj_format);
        end if;

        if ctrl_da_02 > 0 then --lower
          v_num             := v_num + 1;
          v_msg_qtyalpblow  := v_msg_qtyalpblow||' '||ctrl_da_02||' '||v_msg_unit;
          obj_format        := json_object_t();
          obj_format.put('message_alert',v_msg_qtyalpblow);
          obj_row.put(to_char(v_num-1),obj_format);
        end if;

        if	ctrl_da_03 > 0 then --special
          v_num             := v_num + 1;
          v_msg_qtyspecail  := v_msg_qtyspecail||' '||ctrl_da_03||' '||v_msg_unit;
          v_special         := get_special_char();
          if v_special is not null then
            v_msg_qtyspecail := v_msg_qtyspecail||' ('||v_special||')';
          end if;
          obj_format        := json_object_t();
          obj_format.put('message_alert',v_msg_qtyspecail);
          obj_row.put(to_char(v_num-1),obj_format);
        end if;

        if  ctrl_da_04 > 0 then
          v_num             := v_num + 1;
          v_msg_qtynumdigit := v_msg_qtynumdigit||' '||ctrl_da_04||' '||v_msg_unit;
          obj_format        := json_object_t();
          obj_format.put('message_alert',v_msg_qtynumdigit);
          obj_row.put(to_char(v_num-1),obj_format);
        end if;
        obj_data.put('status','error_format');
        obj_data.put('message',param_msg_error);
        obj_data.put('fotmat_password',obj_row);

      else
        begin
          insert into tchangpass(coduser,dtechng,codpswd,rcupdid)
          values (upper(p_coduser),sysdate,p_codpswd_base64,p_coduser);
        end;

        begin
          update users
             set password  = p_codpswd,
             updated_at = sysdate
           where email  = p_coduser;
        end;

        begin
          update tusrprof
             set lupswdte  = sysdate,
                 flgchgpass = 'Y',
                 codpswd = pwdenc(p_codpswd_new,p_coduser,v_chken),
                 timepswd = 0
           where coduser  = p_coduser;
        end;

        commit;
        obj_data.put('status','success');
        obj_data.put('message',msg_error('HR2410',global_v_lang));
      end if;
    else
      obj_data.put('status','error');
      obj_data.put('message',param_msg_error);
    end if;
    json_str_output := obj_data.to_clob;
   exception when others then
    obj_data  := json_object_t();
    obj_data.put('status','error');
    obj_data.put('message',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
  end;
-----------------------------------------------------------------------------------------------
  procedure gen_label(json_str_output out clob) as
    obj_row                   json_object_t;
    obj_data                  json_object_t;
    v_rcnt                    number := 0;
    p_codtemp                 varchar2(100 char);
    v_flgdata                 boolean := false;
    v_msg_qtypassmax_101      varchar2(1000 char) := '';
    v_msg_qtypassmax_102      varchar2(1000 char) := '';
    v_msg_qtypassmax_103      varchar2(1000 char) := '';
    v_msg_qtypassmax_104      varchar2(1000 char) := '';
    v_msg_qtypassmax_105      varchar2(1000 char) := '';
    v_msg_unit_101            varchar2(1000 char) := '';
    v_msg_unit_102            varchar2(1000 char) := '';
    v_msg_unit_103            varchar2(1000 char) := '';
    v_msg_unit_104            varchar2(1000 char) := '';
    v_msg_unit_105            varchar2(1000 char) := '';
    v_msg_qtypassmin_101      varchar2(1000 char) := '';
    v_msg_qtypassmin_102      varchar2(1000 char) := '';
    v_msg_qtypassmin_103      varchar2(1000 char) := '';
    v_msg_qtypassmin_104      varchar2(1000 char) := '';
    v_msg_qtypassmin_105      varchar2(1000 char) := '';
    v_msg_qtyalpbup_101       varchar2(1000 char) := '';
    v_msg_qtyalpbup_102       varchar2(1000 char) := '';
    v_msg_qtyalpbup_103       varchar2(1000 char) := '';
    v_msg_qtyalpbup_104       varchar2(1000 char) := '';
    v_msg_qtyalpbup_105       varchar2(1000 char) := '';
    v_msg_qtyalpblow_101      varchar2(1000 char) := '';
    v_msg_qtyalpblow_102      varchar2(1000 char) := '';
    v_msg_qtyalpblow_103      varchar2(1000 char) := '';
    v_msg_qtyalpblow_104      varchar2(1000 char) := '';
    v_msg_qtyalpblow_105      varchar2(1000 char) := '';
    v_msg_qtynumdigit_101     varchar2(1000 char) := '';
    v_msg_qtynumdigit_102     varchar2(1000 char) := '';
    v_msg_qtynumdigit_103     varchar2(1000 char) := '';
    v_msg_qtynumdigit_104     varchar2(1000 char) := '';
    v_msg_qtynumdigit_105     varchar2(1000 char) := '';
    v_msg_qtyspecail_101      varchar2(1000 char) := '';
    v_msg_qtyspecail_102      varchar2(1000 char) := '';
    v_msg_qtyspecail_103      varchar2(1000 char) := '';
    v_msg_qtyspecail_104      varchar2(1000 char) := '';
    v_msg_qtyspecail_105      varchar2(1000 char) := '';
    v_msg_pass_101            varchar2(1000 char) := '';
    v_msg_pass_102            varchar2(1000 char) := '';
    v_msg_pass_103            varchar2(1000 char) := '';
    v_msg_pass_104            varchar2(1000 char) := '';
    v_msg_pass_105            varchar2(1000 char) := '';
    v_special                 varchar2(4000 char);

    cursor c1 is
      select codapp, numseq, desclabele, desclabelt, desclabel3, desclabel4, desclabel5
        from tapplscr
       where codapp = 'LOGIN'
      order by codapp;

    cursor c2 is
      select codlang, namlang, namabb
        from tlanguage
       order by namlang;

    cursor c3 is
      select  *
        from  tapplscr
       where  codapp = 'MSGLOGIN'
          and numseq in (10,20,30,40,50,60,70)
     order by numseq desc;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_flgdata := true;
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codapp', r1.codapp);
      obj_data.put('numseq', r1.numseq);
      obj_data.put('desclabele', r1.desclabele);
      obj_data.put('desclabelt', r1.desclabelt);
      obj_data.put('desclabel3', r1.desclabel3);
      obj_data.put('desclabel4', r1.desclabel4);
      obj_data.put('desclabel5', r1.desclabel5);
      for r2 in c2 loop
        if r2.codlang = '101' then
          p_codtemp := 'en';
        elsif r2.codlang = '102' then
          p_codtemp := 'th';
        else
          p_codtemp := r2.codlang;
        end if;
        obj_data.put('L' || r2.codlang, p_codtemp);
      end loop;
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    call_tsetpass;

    for r3 in c3 loop
      if r3.numseq = '70' then
          v_msg_unit_101  := r3.desclabele;
          v_msg_unit_102  := r3.desclabelt;
          v_msg_unit_103  := r3.desclabel3;
          v_msg_unit_104  := r3.desclabel4;
          v_msg_unit_105  := r3.desclabel5;
      end if;
      if r3.numseq = '10' then
        if p_qtypassmax is not null then
          v_msg_qtypassmax_101  := r3.desclabele||' '||p_qtypassmax||' '||v_msg_unit_101;
          v_msg_qtypassmax_102  := r3.desclabelt||' '||p_qtypassmax||' '||v_msg_unit_102;
          v_msg_qtypassmax_103  := r3.desclabel3||' '||p_qtypassmax||' '||v_msg_unit_103;
          v_msg_qtypassmax_104  := r3.desclabel4||' '||p_qtypassmax||' '||v_msg_unit_104;
          v_msg_qtypassmax_105  := r3.desclabel5||' '||p_qtypassmax||' '||v_msg_unit_105;
        end if;
      end if;
      if r3.numseq = '20' then
        if p_qtypassmin is not null then
          v_msg_qtypassmin_101  := r3.desclabele||' '||p_qtypassmin||' '||v_msg_unit_101;
          v_msg_qtypassmin_102  := r3.desclabelt||' '||p_qtypassmin||' '||v_msg_unit_102;
          v_msg_qtypassmin_103  := r3.desclabel3||' '||p_qtypassmin||' '||v_msg_unit_103;
          v_msg_qtypassmin_104  := r3.desclabel4||' '||p_qtypassmin||' '||v_msg_unit_104;
          v_msg_qtypassmin_105  := r3.desclabel5||' '||p_qtypassmin||' '||v_msg_unit_105;
        end if;
      end if;
     if r3.numseq = '30' then
        if ctrl_da_04 > 0 then
          v_msg_qtynumdigit_101  := r3.desclabele||' '||ctrl_da_04||' '||v_msg_unit_101;
          v_msg_qtynumdigit_102  := r3.desclabelt||' '||ctrl_da_04||' '||v_msg_unit_102;
          v_msg_qtynumdigit_103  := r3.desclabel3||' '||ctrl_da_04||' '||v_msg_unit_103;
          v_msg_qtynumdigit_104  := r3.desclabel4||' '||ctrl_da_04||' '||v_msg_unit_104;
          v_msg_qtynumdigit_105  := r3.desclabel5||' '||ctrl_da_04||' '||v_msg_unit_105;
        end if;
      end if;
     if r3.numseq = '40' then
        if ctrl_da_03 > 0 then
          v_msg_qtyspecail_101  := r3.desclabele||' '||ctrl_da_03||' '||v_msg_unit_101;
          v_msg_qtyspecail_102  := r3.desclabelt||' '||ctrl_da_03||' '||v_msg_unit_102;
          v_msg_qtyspecail_103  := r3.desclabel3||' '||ctrl_da_03||' '||v_msg_unit_103;
          v_msg_qtyspecail_104  := r3.desclabel4||' '||ctrl_da_03||' '||v_msg_unit_104;
          v_msg_qtyspecail_105  := r3.desclabel5||' '||ctrl_da_03||' '||v_msg_unit_105;

          v_special         := get_special_char();
          if v_special is not null then
            v_msg_qtyspecail_101 := v_msg_qtyspecail_101||' ('||v_special||')';
            v_msg_qtyspecail_102 := v_msg_qtyspecail_102||' ('||v_special||')';
            v_msg_qtyspecail_103 := v_msg_qtyspecail_103||' ('||v_special||')';
            v_msg_qtyspecail_104 := v_msg_qtyspecail_104||' ('||v_special||')';
            v_msg_qtyspecail_105 := v_msg_qtyspecail_105||' ('||v_special||')';
          end if;
        end if;
      end if;
      if r3.numseq = '50' then
        if ctrl_da_02 > 0 then
          v_msg_qtyalpblow_101  := r3.desclabele||' '||ctrl_da_02||' '||v_msg_unit_101;
          v_msg_qtyalpblow_102  := r3.desclabelt||' '||ctrl_da_02||' '||v_msg_unit_102;
          v_msg_qtyalpblow_103  := r3.desclabel3||' '||ctrl_da_02||' '||v_msg_unit_103;
          v_msg_qtyalpblow_104  := r3.desclabel4||' '||ctrl_da_02||' '||v_msg_unit_104;
          v_msg_qtyalpblow_105  := r3.desclabel5||' '||ctrl_da_02||' '||v_msg_unit_105;
        end if;
      end if;
      if r3.numseq = '60' then
        if ctrl_da_01 > 0 then
          v_msg_qtyalpbup_101  := r3.desclabele||' '||ctrl_da_01||' '||v_msg_unit_101;
          v_msg_qtyalpbup_102  := r3.desclabelt||' '||ctrl_da_01||' '||v_msg_unit_102;
          v_msg_qtyalpbup_103  := r3.desclabel3||' '||ctrl_da_01||' '||v_msg_unit_103;
          v_msg_qtyalpbup_104  := r3.desclabel4||' '||ctrl_da_01||' '||v_msg_unit_104;
          v_msg_qtyalpbup_105  := r3.desclabel5||' '||ctrl_da_01||' '||v_msg_unit_105;
        end if;
      end if;
    end loop;
    v_msg_pass_101 := v_msg_qtypassmax_101 || chr('35')|| v_msg_qtypassmin_101 || chr('35')|| v_msg_qtyalpbup_101
                     || chr('35')|| v_msg_qtyalpblow_101 || chr('35')|| v_msg_qtyspecail_101 || chr('35')|| v_msg_qtynumdigit_101;
    v_msg_pass_102 := v_msg_qtypassmax_102 || chr('35')|| v_msg_qtypassmin_102 || chr('35')|| v_msg_qtyalpbup_102
                     || chr('35')|| v_msg_qtyalpblow_102 || chr('35')|| v_msg_qtyspecail_102 || chr('35')|| v_msg_qtynumdigit_102;
    v_msg_pass_103 := v_msg_qtypassmax_103 || chr('35')|| v_msg_qtypassmin_103 || chr('35')|| v_msg_qtyalpbup_103
                     || chr('35')|| v_msg_qtyalpblow_103 || chr('35')|| v_msg_qtyspecail_103 || chr('35')|| v_msg_qtynumdigit_103;
    v_msg_pass_104 := v_msg_qtypassmax_104 || chr('35')|| v_msg_qtypassmin_104 || chr('35')|| v_msg_qtyalpbup_104
                     || chr('35')|| v_msg_qtyalpblow_104 || chr('35')|| v_msg_qtyspecail_104 || chr('35')|| v_msg_qtynumdigit_104;
    v_msg_pass_105 := v_msg_qtypassmax_105 || chr('35')|| v_msg_qtypassmin_105 || chr('35')|| v_msg_qtyalpbup_105
                     || chr('35')|| v_msg_qtyalpblow_105 || chr('35')|| v_msg_qtyspecail_105 || chr('35')|| v_msg_qtynumdigit_105;

    v_rcnt := v_rcnt+1;
    obj_data.put('coderror', '200');
    obj_data.put('codapp', 'MSGLOGIN');
    obj_data.put('numseq', '200');
    obj_data.put('desclabele', v_msg_pass_101);
    obj_data.put('desclabelt', v_msg_pass_102);
    obj_data.put('desclabel3', v_msg_pass_103);
    obj_data.put('desclabel4', v_msg_pass_104);
    obj_data.put('desclabel5', v_msg_pass_105);
     for r2 in c2 loop
      if r2.codlang = '101' then
        p_codtemp := 'en';
      elsif r2.codlang = '102' then
        p_codtemp := 'th';
      else
        p_codtemp := r2.codlang;
      end if;
      obj_data.put('L' || r2.codlang, p_codtemp);
    end loop;
    obj_row.put(to_char(v_rcnt-1), obj_data);

    if not v_flgdata then
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codapp', '');
      obj_data.put('numseq', '');
      obj_data.put('desclabele', '');
      obj_data.put('desclabelt', '');
      obj_data.put('desclabel3', '');
      obj_data.put('desclabel4', '');
      obj_data.put('desclabel5', '');
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,'102');
  end;

  procedure get_label(json_str_input in clob,json_str_output out clob) is
  begin
    if param_msg_error is null then
      gen_label(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,'102');
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,'102');
  end get_label;

  procedure gen_all_lang(json_str_output out clob) as
    obj_row   json_object_t;
    obj_data  json_object_t;
    v_rcnt    number := 0;
    v_codlang varchar2(100 char);
    v_flgdata boolean := false;
    v_folder  varchar2(100 char);

    cursor c1 is
      select codlang, namlang, namabb, namimage
        from tlanguage
       where codlang2 is not null
       order by codlang;

  begin
    obj_row  := json_object_t();
    begin
      select folder
        into v_folder
        from tfolderd
       where codapp = 'HRCO31E';
    exception when no_data_found then
      v_folder := null;
    end;
    for r1 in c1 loop
      v_flgdata := true;
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      if r1.codlang = '101' then
        v_codlang := 'en';
      elsif r1.codlang = '102' then
        v_codlang := 'th';
      else
        v_codlang := r1.codlang;
      end if;
      obj_data.put('codlang', v_codlang);
      obj_data.put('namlang', r1.namlang);
      obj_data.put('namabb', r1.namabb);
      obj_data.put('namimage', r1.namimage);
      obj_data.put('path_namimage', get_tsetup_value('PATHWORKPHP')||v_folder);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;
    if not v_flgdata then
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codlang', '');
      obj_data.put('namlang', '');
      obj_data.put('namabb', '');
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,'102');
  end;

  procedure get_all_lang(json_str_input in clob,json_str_output out clob) is
  begin
    if param_msg_error is null then
      gen_all_lang(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,'102');
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,'102');
  end get_all_lang;
  --
  procedure forgot_password(json_str_input in clob,json_str_output out clob) is
    json_obj        json_object_t;
    obj_data        json_object_t;
    p_coduser       varchar2(1000 char);
    p_email         varchar2(1000 char);
    p_idcardno      varchar2(1000 char);
    v_count         number;
    v_msg           long;
    v_new_pass      varchar2(1000 char);
    crlf            varchar2( 2 ):= chr( 13 ) || chr( 10 );
    v_chken         varchar2(4000 char);

    v_codempid      temploy1.codempid%type;
    v_numoffid      temploy2.numoffid%type;
    v_email         temploy1.email %type;
    p_flgapp        varchar2(10 char);

  begin
    v_chken       := hcm_secur.get_v_chken;
    json_obj      := json_object_t(json_str_input);
    p_coduser     := upper(hcm_util.get_string_t(json_obj,'p_coduser'));
    p_email       := hcm_util.get_string_t(json_obj,'p_email');
    p_idcardno    := hcm_util.get_string_t(json_obj,'p_idcardno');
    global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');
    p_flgapp      := hcm_util.get_string_t(json_obj,'p_flgapp'); -- 'Y' = mobile app | null = web
    call_tsetpass;

    -- check exists username and email
    if p_flgapp = 'Y' then -- mobile app
      begin
        select count(*)
          into v_count
          from temploy1
         where codempid = (select codempid from tusrprof where coduser = p_coduser)
           and lower(email) = lower(p_email);
      exception when others then
        v_count := 0;
      end;
    else -- web
      begin
        select count(*)
          into v_count
          from temploy1 emp1, temploy2 emp2
         where emp1.codempid = emp2.codempid
           and emp1.codempid = (select codempid from tusrprof where coduser = p_coduser)
           and lower(email) = lower(p_email)
           and lower(emp2.numoffid) = lower(p_idcardno);
      exception when others then
        v_count := 0;
      end;
    end if;
    --
    obj_data  := json_object_t();
    if v_count > 0 then
      obj_data.put('status','success');
      json_str_output := obj_data.to_clob;
      return;
    else
        begin
          select     codempid
            into     v_codempid
            from     tusrprof
           where     coduser = p_coduser;
        exception when no_data_found then
          obj_data.put('status','error');
          obj_data.put('message',replace(msg_error('HR3018',global_v_lang,'tusrprof'),'<br>',' ')); --HR3010
          json_str_output := obj_data.to_clob;
          return;
        end;

        if p_flgapp is null then -- web
          begin
            select     numoffid
              into     v_numoffid
              from     temploy2
             where     codempid = v_codempid;
            exception when no_data_found then
            obj_data.put('status','error');
            obj_data.put('message',replace(msg_error('PM0059',global_v_lang,'temploy2'),'<br>',' '));
            json_str_output := obj_data.to_clob;
            return;
          end;
        end if;

        begin
          select     email
            into     v_email
            from     temploy1
           where     codempid = v_codempid;
        exception when no_data_found then
          obj_data.put('status','error');
          obj_data.put('message',replace(msg_error('HR8864',global_v_lang,'temploy1'),'<br>',' '));
          json_str_output := obj_data.to_clob;
          return;
        end;

        if v_codempid is null then
            obj_data.put('status','error');
            obj_data.put('message',replace(msg_error('HR3018',global_v_lang),'<br>',' ')); -- HR3010
            json_str_output := obj_data.to_clob;
            return;
        end if;

        if v_email <> p_email then
            obj_data.put('status','error');
            obj_data.put('message',replace(msg_error('HR8864',global_v_lang),'<br>',' '));
            json_str_output := obj_data.to_clob;
            return;
        end if;

        if p_flgapp is null then -- web
          if v_numoffid <> p_idcardno then
              obj_data.put('status','error');
              obj_data.put('message',replace(msg_error('PM0059',global_v_lang),'<br>',' '));
              json_str_output := obj_data.to_clob;
              return;
          end if;
        end if;
    end if;
    json_str_output := obj_data.to_clob;
  exception when others then
    obj_data  := json_object_t();
    obj_data.put('status','error');
    obj_data.put('message',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    json_str_output := obj_data.to_clob;
  end;
 --------------------------------------------------------------------------
  procedure login_admin(json_str_input in clob,json_str_output out clob) is
    obj_data        json_object_t;
    json_obj        json_object_t;
    p_coduser       varchar2(100 char);
    p_codpswd       varchar2(100 char);
    p_codpswd2      varchar2(100 char);
    p_codpswd_hash  varchar2(100 char);
    p_codpswd2_hash varchar2(100 char);
    v_codpass       varchar2(10 char);
    v_codempid      varchar2(10 char);
    v_flgerror      varchar2(1 char);
    v_userdomain    tusrprof.userdomain%type;
    v_round         number := 1;
    v_coduser       tusrprof.coduser%type;
    v_codpswd       tusrprof.codpswd%type;
    v_coduserenc    varchar2(1000 char);
    v_codpswdenc    varchar2(1000 char);
    v_maxuser       users.id%type;
  begin
    json_obj        := json_object_t(json_str_input);
    global_v_lang   := hcm_util.get_string_t(json_obj,'p_lang');
    p_coduser       := upper(hcm_util.get_string_t(json_obj,'p_coduser'));
    p_codpswd       := hcm_util.get_string_t(json_obj,'p_codpswd');
    p_codpswd2      := base64_decode(check_pwd2);
    p_codpswd_hash  := hcm_util.get_string_t(json_obj,'p_codpswd_hash');
    p_codpswd2_hash := hcm_util.get_string_t(json_obj,'p_codpswd2_hash');

    if p_coduser in ('PPSADM','PPSIMP') then
      if p_codpswd = p_codpswd2 then

        v_codempid := get_tsetup_value('PPSIMPUSER');
        begin
          select codempid
            into v_codempid
            from temploy1
           where codempid = v_codempid
             and rownum = 1;
        exception when no_data_found then
          v_codempid := null;
        end;

        if v_codempid is null then
          begin
            select codempid
              into v_codempid
              from temploy1
             where staemp = '3'
               and rownum = 1;
          exception when no_data_found then
            v_codempid := null;
          end;
        end if;

        delete from users     where email   = p_coduser;
        delete from tusrprof  where coduser = p_coduser;
        delete from tusrproc  where coduser = p_coduser;
        delete from tusrcom   where coduser = p_coduser;
        delete from tusrcom  where coduser = p_coduser;

        -- users
        v_maxuser := 0;
        begin
            select max(id) into v_maxuser
             from users;
        exception when no_data_found then
            null;
        end;

        begin
          insert into users (id,name,email,password,is_client,created_at,updated_at,username,codempid)
          values(v_maxuser+1,p_coduser,p_coduser,p_codpswd2_hash,'1',sysdate,sysdate,p_coduser,v_codempid);
        exception when dup_val_on_index then
          null;
        end;

        -- tusrprof
        begin
          insert into tusrprof (coduser,codempid,typeauth,typeuser,flgact,flgtranl,flgchgpass,
                                numlvlst,numlvlen,numlvlsalst,numlvlsalen,codpswd,lupswdte,timepswd,dtecreate,usrcreate)
          values(p_coduser,v_codempid,'1','4','1','Y','Y',
                 pwdenc(0,p_coduser,v_chken),pwdenc(99,p_coduser,v_chken),pwdenc(0,p_coduser,v_chken),pwdenc(99,p_coduser,v_chken),pwdenc(p_codpswd2,p_coduser,v_chken),sysdate,0,sysdate,p_coduser);
        exception when dup_val_on_index then
          null;
        end;

        -- tusrproc
        begin
          if p_coduser = 'PPSIMP' then
            insert into tusrproc (coduser,codproc,rcupdid,flgauth) values(p_coduser,'1.RP',p_coduser,'2');
            insert into tusrproc (coduser,codproc,rcupdid,flgauth) values(p_coduser,'2.RC',p_coduser,'2');
            insert into tusrproc (coduser,codproc,rcupdid,flgauth) values(p_coduser,'3.PM',p_coduser,'2');
            insert into tusrproc (coduser,codproc,rcupdid,flgauth) values(p_coduser,'4.AL',p_coduser,'2');
            insert into tusrproc (coduser,codproc,rcupdid,flgauth) values(p_coduser,'5.BF',p_coduser,'2');
            insert into tusrproc (coduser,codproc,rcupdid,flgauth) values(p_coduser,'6.PY',p_coduser,'2');
            insert into tusrproc (coduser,codproc,rcupdid,flgauth) values(p_coduser,'7.AP',p_coduser,'2');
            insert into tusrproc (coduser,codproc,rcupdid,flgauth) values(p_coduser,'8.TR',p_coduser,'2');
            insert into tusrproc (coduser,codproc,rcupdid,flgauth) values(p_coduser,'9.ES',p_coduser,'2');
            insert into tusrproc (coduser,codproc,rcupdid,flgauth) values(p_coduser,'A.MS',p_coduser,'2');
          end if;
          insert into tusrproc (coduser,codproc,rcupdid,flgauth) values(p_coduser,'SC',p_coduser,'2');
          insert into tusrproc (coduser,codproc,rcupdid,flgauth) values(p_coduser,'CO',p_coduser,'2');
        exception when others then
          null;
        end;

        -- tusrcom
        begin
          insert into tusrcom (coduser,codcomp,dteupd) (select p_coduser,codcompy,sysdate from tcompny);
        exception when others then
          null;
        end;
      else
        param_msg_error := get_error_msg_php('HR3018', global_v_lang);
      end if;
      commit;
    else
      -- check user ad
      begin
        select userdomain,coduser,codpswd
          into v_userdomain,v_coduser,v_codpswd
          from tusrprof
         where userdomain is not null
           and userdomain = p_coduser
           and rownum = 1;
      exception when others then
        v_userdomain := null;
      end;

      if v_userdomain is not null then
        begin
            v_codpswdenc := pwdenc(p_codpswd,p_coduser,v_chken);
        exception when others then
            v_codpswdenc := null;
        end;
        if v_codpswdenc <> v_codpswd then  -- check password for coduser
            v_flgerror := check_user_domain(v_userdomain,p_codpswd);

            if v_flgerror = 'Y' and v_coduser is not null and v_codpswd is not null then -- login ad success
              v_coduserenc := v_coduser;
              v_codpswdenc := pwddec(v_codpswd,v_coduser,v_chken);
              v_round := to_number(floor(dbms_random.value(1,5)));
              for i in 1..v_round loop
                v_coduserenc := base64_encode(v_coduserenc);
                v_codpswdenc := base64_encode(v_codpswdenc);
              end loop;
              v_coduserenc := to_char(v_round)||v_coduserenc;
              v_codpswdenc := to_char(v_round)||v_codpswdenc;
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('flgad','Y');
              obj_data.put('coduser',v_coduserenc);
              obj_data.put('codpswd',v_codpswdenc);
              json_str_output := obj_data.to_clob;
              return;
            elsif v_flgerror = 'N' then -- login ad fail
              param_msg_error := get_error_msg_php('HR3018', global_v_lang);
            elsif v_flgerror = 'S' OR v_flgerror = 'T' then -- server fail
              param_msg_error := get_error_msg_php('HR3019', global_v_lang);
            end if;
        end if; -- if p_codpswddec <> v_codpswd then
      end if; -- if v_userdomain is not null then
    end if;

    -- check license expire
    if param_msg_error is null then
      if std_sc.chk_expire = false then
        param_msg_error := get_error_msg_php('HR3053', global_v_lang);
      end if;
    end if;

    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,'102');
  end;
  --
  procedure update_pdpa(json_str_input in clob,json_str_output out clob) is
    json_obj        json_object_t;
    v_coduser       tusrprof.coduser%type;
    v_codempid      tusrprof.codempid%type;
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_dteeffec      tempconst.dteeffec%type;
    v_numitem       tempconst.numitem%type;
    v_codcompy      tempconst.codcompy%type;
    v_flgconst      tempconst.flgconst%type;
    v_reason        tempconst.reason%type;
  begin
    json_obj        := json_object_t(json_str_input);
    v_coduser       := upper(hcm_util.get_string_t(json_obj,'p_coduser'));
    v_codempid      := upper(hcm_util.get_string_t(json_obj,'p_codempid'));
    global_v_lang   := hcm_util.get_string_t(json_obj,'p_lang');
    param_json      := hcm_util.get_json_t(json_obj,'json_input_str');

    -- delete before insert (keep only last submit)
    begin
      delete from tempconst
      where codempid = v_codempid;
    exception when others then
      null;
    end;

    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
      v_dteeffec      := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
      v_numitem       := hcm_util.get_string_t(param_json_row,'numitem');
      v_codcompy      := hcm_util.get_string_t(param_json_row,'codcompy');
      v_flgconst      := hcm_util.get_string_t(param_json_row,'flgconst');
      v_reason        := hcm_util.get_string_t(param_json_row,'reason');

      begin
        insert into tempconst (codempid,dteeffec,numitem,
                               dteconst,codcompy,flgconst,
                               reason,codcreate,coduser)
                        values(v_codempid,v_dteeffec,v_numitem,
                               trunc(sysdate),v_codcompy,v_flgconst,
                               v_reason,v_coduser,v_coduser);

      exception when others then
        null;
      end;
    end loop;

    begin
      update temploy1
         set flgpdpa  = 'Y',
             dtepdpa  = trunc(sysdate)
       where codempid = v_codempid;
    end;
    commit;

    param_msg_error := get_label_name('LOGIN', global_v_lang, '320')||'@#$%201';
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,'102');
  end;
  --
  function explode(p_delimiter varchar2, p_string long, p_limit number default 1000) return arr_1d as
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
  function check_ip_allow(p_ipaddr varchar2) return boolean is
    v_exists        boolean := false;
    v_ipintcheck    varchar2(100 char);
    cursor c1 is
      select ip
        from tipallow;
  begin
    for r1 in c1 loop
      v_ipintcheck := replace(r1.ip,'*','%');
      if p_ipaddr like v_ipintcheck then
        v_exists := true;
        exit;
      end if;
    end loop;
    return v_exists;
  end;
  --
  procedure get_check_otp(json_str_input in clob,json_str_output out clob) is
    json_obj        json_object_t;
    p_coduser       varchar2(100 char);
    p_codempid      varchar2(100 char);
    p_ipaddr        varchar2(100 char);
    obj_data        json_object_t;
    v_otpflglogin   varchar2(10 char);
    v_flgipallow    boolean;
    v_nummobile     temploy1.nummobile%type;
  begin
    json_obj        := json_object_t(json_str_input);
    p_coduser       := upper(hcm_util.get_string_t(json_obj,'p_coduser'));
    p_codempid      := upper(hcm_util.get_string_t(json_obj,'p_codempid'));
    p_ipaddr        := hcm_util.get_string_t(json_obj,'p_ipaddr');
    global_v_lang   := hcm_util.get_string_t(json_obj,'p_lang');

    v_otpflglogin := nvl(get_tsetup_value('OTPFLGLOGIN'),'N');
    call_tsetpass;
    if v_otpflglogin = 'Y' then
      v_flgipallow := check_ip_allow(p_ipaddr);
      if v_flgipallow then -- not require otp for login
        p_qtyotp := '0';
      end if;
    else
      p_qtyotp := '0';
    end if;

    obj_data   := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('otpDigits', p_qtyotp);
    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,'102');
  end;

  procedure login_sso(json_str_input in clob,json_str_output out clob) as
    json_obj            json_object_t;
    obj_data            json_object_t;
    v_email             varchar2(1000 char);
    v_runno             number;
    v_coduser           tusrprof.coduser%type;
    v_codempid          temploy1.codempid%type;
    v_lang              temploy1.maillang%type;
    v_redirect_url      varchar2(1000 char);

    cursor c_tusrprof is
        select a.codempid,decode(lower(a.maillang),'en','101','th','102',a.maillang) lang,b.coduser
          from temploy1 a,tusrprof b
         where a.codempid = b.codempid
           and a.email = v_email
           and b.flgact = '1'
        order by decode(b.typeuser,'4','A','1','B','3','C','2','D','Z'),b.coduser;
  begin
    json_obj    := json_object_t(json_str_input);
    v_email     := hcm_util.get_string_t(json_obj,'p_email');

    for r_tusrprof in c_tusrprof loop
        v_codempid := r_tusrprof.codempid;
        v_lang     := r_tusrprof.lang;
        v_coduser  := r_tusrprof.coduser;
        exit;
    end loop;

    if v_lang not in ('101','102','103','104','105') or v_lang is null then
      v_lang  := '102';
    end if;

    v_redirect_url := get_tsetup_value('PATHMOBILE');
    if v_coduser is not null then
        <<cal_loop>>
        loop
          v_runno := round(dbms_random.value(1,10000000000000));
          begin
--            insert into tmaillog(runno,coduser,codapp,codlang) values(v_runno,v_coduser,null,v_lang);
            insert into tmaillog(runno,coduser,codapp,codlang) values(v_runno,v_coduser,null,null); -- use lang from login screen
            exit cal_loop;
          exception when dup_val_on_index then null;
          end;
        end loop; -- cal_loop
        commit;

        v_redirect_url := replace(v_redirect_url,'<P_RUNNO>',to_char(v_runno));
    else
        v_redirect_url := replace(v_redirect_url,'/autologin/<P_RUNNO>','');
    end if;

    obj_data   := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('redirecturl', v_redirect_url);
    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,'102');
  end;

  procedure login_setting(json_str_input in clob,json_str_output out clob) as
    obj_data            json_object_t;
  begin
    obj_data   := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('loginsaml2', nvl(get_tsetup_value('LOGINSAML2'),'N'));
    obj_data.put('flgel', nvl(get_tsetup_value('FLGEL'),'Y'));
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,'102');
  end;

  procedure set_pin_code_user(json_str_input in clob,json_str_output out clob) as
       json_obj             json_object_t;
       p_coduserpin         varchar2(1000 char);
       p_coduser            varchar2(100 char);
  begin
        json_obj      := json_object_t(json_str_input);
        p_coduser     := upper(hcm_util.get_string_t(json_obj,'p_coduser'));
        p_coduserpin  := base64_decode(hcm_util.get_string_t(json_obj,'p_coduserpin'));
        global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');

        begin
            update tusrprof
               set coduserpin = pwdenc(p_coduserpin,p_coduser,v_chken)
             where coduser    = p_coduser;
        exception when others then
            null;
        end;

        json_obj   := json_object_t();
        json_obj.put('status','success');
        json_obj.put('message',msg_error('HR2401',global_v_lang));
        json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,'102');
  end;


   procedure login_pin(json_str_input in clob,json_str_output out clob) as
       json_obj             json_object_t;
       p_coduserpin         varchar2(1000 char);
       p_coduser            varchar2(100 char);
       v_coduserpin        varchar2(100 char);
       v_coduser            varchar2(100 char);
       v_coduserpindec   varchar2(100 char);
    begin
        json_obj      := json_object_t(json_str_input);
        p_coduser     := upper(hcm_util.get_string_t(json_obj,'p_coduser'));
        p_coduserpin  := base64_decode(hcm_util.get_string_t(json_obj,'p_coduserpin'));
        global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');

        begin
         select coduser,CODUSERPIN
         into v_coduser,v_coduserpin
         from tusrprof
         where coduser = p_coduser;
        exception when others then
          v_coduser := null;
        end;

        v_coduserpindec  := pwddec(v_coduserpin,p_coduser,v_chken);
        if v_coduserpindec = p_coduserpin then
            json_obj   := json_object_t();
            json_obj.put('status','success');

        else
            json_obj   := json_object_t();
            json_obj.put('status','not found');

        end if;
            json_str_output := json_obj.to_clob;

        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,'102');

     end;

end;

/

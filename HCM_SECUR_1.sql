--------------------------------------------------------
--  DDL for Package Body HCM_SECUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_SECUR" is
-- last update: 17/10/2017 10:10

  function get_v_chken return varchar2 is
  begin
    v_chken := check_emp(get_emp);
    return v_chken;
  end;
  --
  function hcmenc(v_data in varchar2) return varchar2 is
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
  END hcmenc;
  --
  function hcmdec
  (v_data in varchar2) return varchar2 is
  v_data01 varchar2(300 char);  v_data02 varchar2(300 char);  v_data03 varchar2(300 char);  v_data04 varchar2(300 char);  v_data05 varchar2(300 char);
  v_data06 varchar2(300 char);  v_data07 varchar2(300 char);  v_data08 varchar2(300 char);  v_data09 varchar2(300 char);  v_data10 varchar2(300 char);
  v_data11 varchar2(300 char);  v_data12 varchar2(300 char);  v_data13 varchar2(300 char);  v_data14 varchar2(300 char);  v_data15 varchar2(300 char);
  v_chk01 number; v_chk02 number; v_chk03 number; v_chk04 number; v_chk05 number;
  v_chk06 number; v_chk07 number; v_chk08 number; v_chk09 number; v_chk10 number;
  v_chk11 number; v_chk12 number; v_chk13 number; v_chk14 number; v_chk15 number;
  v_data_dec varchar2(200 char);
  BEGIN
    v_chk01 := substr(v_data,45,1);
    v_chk02 := substr(v_data,53,1);
    v_chk03 := substr(v_data,5,1);
    v_chk04 := substr(v_data,25,1);
    v_chk05 := substr(v_data,13,1);
    v_chk06 := substr(v_data,17,1);
    v_chk07 := substr(v_data,33,1);
    v_chk08 := substr(v_data,29,1);
    v_chk09 := substr(v_data,37,1);
    v_chk10 := substr(v_data,49,1);
    v_chk11 := substr(v_data,57,1);
    v_chk12 := substr(v_data,41,1);
    v_chk13 := substr(v_data,9,1);
    v_chk14 := substr(v_data,1,1);
    v_chk15 := substr(v_data,21,1);
    v_data01 := chr(substr(v_data,14,3)-(v_chk01*1));
    v_data02 := chr(substr(v_data,10,3)-(v_chk02*2));
    v_data03 := chr(substr(v_data,26,3)-(v_chk03*3));
    v_data04 := chr(substr(v_data,46,3)-(v_chk04*4));
    v_data05 := chr(substr(v_data,22,3)-(v_chk05*5));
    v_data06 := chr(substr(v_data, 6,3)-(v_chk06*6));
    v_data07 := chr(substr(v_data,30,3)-(v_chk07*7));
    v_data08 := chr(substr(v_data,42,3)-(v_chk08*8));
    v_data09 := chr(substr(v_data,54,3)-(v_chk09*9));
    v_data10 := chr(substr(v_data,58,3)-(v_chk10*10));
    v_data11 := chr(substr(v_data,38,3)-(v_chk11*11));
    v_data12 := chr(substr(v_data, 2,3)-(v_chk12*12));
    v_data13 := chr(substr(v_data,18,3)-(v_chk13*13));
    v_data14 := chr(substr(v_data,34,3)-(v_chk14*14));
    v_data15 := chr(substr(v_data,50,3)-(v_chk15*15));
    v_data_dec := v_data01||v_data02||v_data03||v_data04||v_data05||v_data06||v_data07||v_data08||v_data09||v_data10||v_data11||v_data12||v_data13||v_data14||v_data15;
    RETURN v_data_dec;
  exception when others then
    return DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
  END hcmdec;
  --
  function hcmenc_with_key(v_data in varchar2, v_key in varchar2) return varchar2 is
  v_data01 varchar2(1);  v_data02 varchar2(1);  v_data03 varchar2(1);  v_data04 varchar2(1);  v_data05 varchar2(1);
  v_data06 varchar2(1);  v_data07 varchar2(1);  v_data08 varchar2(1);  v_data09 varchar2(1);  v_data10 varchar2(1);
  v_data11 varchar2(1);  v_data12 varchar2(1);  v_data13 varchar2(1);  v_data14 varchar2(1);  v_data15 varchar2(1);
  v_chk01 number; v_chk02 number; v_chk03 number; v_chk04 number; v_chk05 number;
  v_chk06 number; v_chk07 number; v_chk08 number; v_chk09 number; v_chk10 number;
  v_chk11 number; v_chk12 number; v_chk13 number; v_chk14 number; v_chk15 number;
  v_data_enc varchar2(200);
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
    v_data_enc := v_key||
                  v_chk14||ltrim(to_char(nvl(ascii(v_data12),0)+(v_chk12*12),'000'))||
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
      return v_data_enc;
  exception when others then
    return DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
  end hcmenc_with_key;
  --
  FUNCTION hcmdec_with_key(v_datakey IN VARCHAR2, v_key in varchar2) RETURN VARCHAR2 IS
  v_data01 varchar2(3);  v_data02 varchar2(3);  v_data03 varchar2(3);  v_data04 varchar2(3);  v_data05 varchar2(3);
  v_data06 varchar2(3);  v_data07 varchar2(3);  v_data08 varchar2(3);  v_data09 varchar2(3);  v_data10 varchar2(3);
  v_data11 varchar2(3);  v_data12 varchar2(3);  v_data13 varchar2(3);  v_data14 varchar2(3);  v_data15 varchar2(3);
  v_chk01 number; v_chk02 number; v_chk03 number; v_chk04 number; v_chk05 number;
  v_chk06 number; v_chk07 number; v_chk08 number; v_chk09 number; v_chk10 number;
  v_chk11 number; v_chk12 number; v_chk13 number; v_chk14 number; v_chk15 number;
  v_data_dec varchar2(200);
  v_data varchar2(200 char);
  begin
    v_data := replace(v_datakey,v_key,'');
    v_chk01 := substr(v_data,45,1);
    v_chk02 := substr(v_data,53,1);
    v_chk03 := substr(v_data,5,1);
    v_chk04 := substr(v_data,25,1);
    v_chk05 := substr(v_data,13,1);
    v_chk06 := substr(v_data,17,1);
    v_chk07 := substr(v_data,33,1);
    v_chk08 := substr(v_data,29,1);
    v_chk09 := substr(v_data,37,1);
    v_chk10 := substr(v_data,49,1);
    v_chk11 := substr(v_data,57,1);
    v_chk12 := substr(v_data,41,1);
    v_chk13 := substr(v_data,9,1);
    v_chk14 := substr(v_data,1,1);
    v_chk15 := substr(v_data,21,1);
    v_data01 := chr(substr(v_data,14,3)-(v_chk01*1));
    v_data02 := chr(substr(v_data,10,3)-(v_chk02*2));
    v_data03 := chr(substr(v_data,26,3)-(v_chk03*3));
    v_data04 := chr(substr(v_data,46,3)-(v_chk04*4));
    v_data05 := chr(substr(v_data,22,3)-(v_chk05*5));
    v_data06 := chr(substr(v_data, 6,3)-(v_chk06*6));
    v_data07 := chr(substr(v_data,30,3)-(v_chk07*7));
    v_data08 := chr(substr(v_data,42,3)-(v_chk08*8));
    v_data09 := chr(substr(v_data,54,3)-(v_chk09*9));
    v_data10 := chr(substr(v_data,58,3)-(v_chk10*10));
    v_data11 := chr(substr(v_data,38,3)-(v_chk11*11));
    v_data12 := chr(substr(v_data, 2,3)-(v_chk12*12));
    v_data13 := chr(substr(v_data,18,3)-(v_chk13*13));
    v_data14 := chr(substr(v_data,34,3)-(v_chk14*14));
    v_data15 := chr(substr(v_data,50,3)-(v_chk15*15));
    v_data_dec := v_data01||v_data02||v_data03||v_data04||v_data05||v_data06||v_data07||v_data08||v_data09||v_data10||v_data11||v_data12||v_data13||v_data14||v_data15;
    return v_data_dec;
  exception when others then
    return DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
  end hcmdec_with_key;
  --
  procedure save_tlogin(json_str in clob, resp_json_str out clob) is
    json_obj        json;
    v_lrunning      number;
    v_coduser       tusrprof.coduser%type;
    v_loginid       varchar2(20 char);
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
    v_license_max   number := 10;
    v_timeout       number;
    bool_license    boolean := false;
    bool_active     boolean := false;
    bool_newuser    boolean := false;
  begin
    json_obj       := json(json_str);

    v_lrunning     := to_number(json_ext.get_string(json_obj,'p_lrunning')); --lrunning
    v_coduser      := upper(json_ext.get_string(json_obj,'p_coduser')); --coduser
    v_loginid      := json_ext.get_string(json_obj,'p_loginid'); --username
    v_ldtein       := sysdate;
    v_ldteout      := null;
    --v_lterminal    := json_ext.get_string(json_obj,'p_lterminal'); --hostname
    v_lipaddress   := substr(replace(json_ext.get_string(json_obj,'p_lipaddress'),':'),1,20); --ipaddress
    v_lcodrun      := json_ext.get_string(json_obj,'p_lcodrun');
    v_lcodsub      := json_ext.get_string(json_obj,'p_lcodsub');
    v_laccess      := 'HRMSONLINE';--json_ext.get_string(json_obj,'p_laccess');
    v_sid          := null;
    v_serial       := null;
    v_license_max  := get_module_license(v_lcodsub);
    v_timeout      := get_timeout;  --day

    if v_coduser is not null then
/*
      -- check timeout old begin
      -- check new/old user
      begin
        select lrunning into v_lrunning
          from tlogin
         where lrunning = v_lrunning;
      exception when no_data_found then
        bool_newuser := true;
      end;

      -- update and delete TIMEOUT user when null or v_lcodusb
      update tlogin set ldteout = sysdate,lcodrun = 'TIMEOUT'--,lcodsub = null
       where to_date(to_char(ldtein,'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss') <
             to_date(to_char(sysdate - v_timeout,'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss')
         and nvl(lcodsub,v_lcodsub) = v_lcodsub
         and laccess = v_laccess;
      delete
        from tlogin
       where to_date(to_char(ldtein,'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss') <
             to_date(to_char(sysdate - v_timeout,'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss')
         and nvl(lcodsub,v_lcodsub) = v_lcodsub
         and laccess = v_laccess;
      -- check timeout old end
 */

      -- check timeout new begin
      clear_session;
      begin
        select lcodrun into o_lcodrun
          from tlogin
         where lrunning = v_lrunning;
        if o_lcodrun = 'TIMEOUT' then
          delete
            from tlogin
           where lrunning = v_lrunning;
        end if;
      exception when no_data_found then
        bool_newuser := true;
      end;
      -- check timeout new end

      begin
        select lrunning into v_lrunning
          from tlogin
         where lrunning = v_lrunning;
        bool_active   := true;
      exception when no_data_found then
        if bool_newuser then
          bool_active := true;
        end if;
      end;

      if bool_active then
        --check license
        if v_lcodsub is not null then
          begin
            select count(lcodsub) into v_license_used
              from tlogin
             where lcodsub = v_lcodsub
               and lrunning <> v_lrunning;
          exception when no_data_found then
            v_license_used := 0;
          end;
        end if;

        if v_license_used < v_license_max then
          bool_license := true;
          if bool_newuser then
            v_lterminal    := substr(hcmenc(json_ext.get_string(json_obj,'p_codpswd')),1,30); --key for encode decode
            insert into tlogin (
              lrunning,     luserid,      loginid,    ldtein,
              lterminal,    lipaddress,   lcodrun,    lcodsub,
              laccess,      sid,          serial
            )
            values(
              v_lrunning,   v_coduser,    v_loginid,  v_ldtein,
              v_lterminal,  v_lipaddress, v_lcodrun,  v_lcodsub,
              v_laccess,    v_sid,        v_serial
            );
          else
            update tlogin set lcodrun = v_lcodrun,lcodsub = v_lcodsub,ldtein = sysdate where lrunning = v_lrunning;
          end if;
          update tusrprof set timepswd = 0, llogidte = sysdate where coduser = v_coduser;
        end if;

        if bool_license = false then
          insert into thislogin (
            lrunning, ldteacc, luserid, loginid,
            ldtein, ldteout, lterminal, lipaddress,
            lcodrun, lcodsub, laccess
          )
          values (
            v_lrunning, sysdate, v_coduser, v_loginid,
            v_ldtein, v_ldteout, v_lterminal, v_lipaddress,
            v_lcodrun, v_lcodsub, v_laccess
          );
        end if;
      end if; --bool_active
    end if;

    if bool_active then
      if bool_license then
        commit;
        if bool_newuser then
          resp_json_str := '{"result":"SUCCESS","key":"'||v_lterminal||'"}';
        else
          resp_json_str := '{"result":"SUCCESS"}';
        end if;
      else
        rollback;
        resp_json_str := '{"result":"LICENSE"}';
      end if;
    else
      commit;
      resp_json_str := '{"result":"TIMEOUT"}';
    end if;

  exception when others then
    rollback;
    resp_json_str := '{"result":"ERROR'||DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace||'"}';
  end save_tlogin;
  --
  procedure remove_tlogin(json_str in clob, resp_json_str out clob) is
    json_obj        json;
    v_lrunning      number;
    v_lcodrun       varchar2(30 char);
  begin
    json_obj       := json(json_str);
    v_lrunning     := to_number(json_ext.get_string(json_obj,'p_lrunning')); --lrunning
    v_lcodrun      := json_ext.get_string(json_obj,'p_lcodrun');

    update tlogin set ldteout = sysdate,lcodrun = v_lcodrun,lcodsub = null where lrunning = v_lrunning;
    delete from tlogin where lrunning = v_lrunning;
    commit;
    resp_json_str := '{"result":"SUCCESS"}';
  exception when others then
    rollback;
    resp_json_str := '{"result":"ERROR"}';
  end remove_tlogin;
  --
  function get_lrunning(json_str clob) return varchar2 is
    json_obj        json;
    v_lrunning      number;
  begin
    json_obj       := json(json_str);
    v_lrunning     := to_number(json_ext.get_string(json_obj,'p_lrunning')); --lrunning
    if v_lrunning is null or v_lrunning = '' then
      begin
        select nvl(max(lrunning)+1,1) into v_lrunning
        from  tlogin;
        exception when no_data_found then
          v_lrunning := 1;
      end;
    end if;

    return v_lrunning;
  end;
  --
  function get_module_license(p_module varchar) return number is
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
  --
  function get_timeout return number is
  begin
    --return 0.00005; --4 sec
    --return 0.0104; --15 min
    --return 0.0416; --1 hr
    return 1; --1 day
  end;
  --
  procedure get_global_secur(p_coduser in varchar2,global_v_zminlvl out number,global_v_zwrklvl out number,global_v_numlvlsalst out number,global_v_numlvlsalen out number) as
  begin
    v_chken := get_v_chken;
    begin
      select to_number(pwddec(numlvlst,coduser,v_chken)),
             to_number(pwddec(numlvlen,coduser,v_chken)),
             to_number(pwddec(numlvlsalst,coduser,v_chken)),
             to_number(pwddec(numlvlsalen,coduser,v_chken))
      into   global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen
      from   tusrprof
      where  coduser  = p_coduser;
    exception when no_data_found then
      global_v_zminlvl := null;
      global_v_zwrklvl := null;
      global_v_numlvlsalst := null;
      global_v_numlvlsalen := null;
    end;
  end;
  --
  function secur_codcomp(p_coduser in varchar2, p_lang in varchar2, p_codcomp in varchar2) return varchar2 is
    v_count number;
    v_secur boolean := null;
  begin
    begin
      select count(*) into v_count
      from   tcenter
      where  codcomp like p_codcomp||'%' ;
    exception when no_data_found then
      null;
    end;

    if v_count = 0 then
      return get_error_msg_php('HR2010', p_lang, 'tcenter');
    end if;
    v_secur := secur_main.secur7(p_codcomp, p_coduser);
    if not v_secur then
      return get_error_msg_php('HR3007', p_lang);
    end if;
    return null;
  end;
  --
  function secur_codempid(p_coduser in varchar2, p_lang in varchar2, p_codempid in varchar2, p_chk_resign in boolean default true) return varchar2 is
    v_count               number;
    v_flgsecu             boolean := false;
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst  number;
    global_v_numlvlsalen  number;
    v_zupdsal             varchar2(4000 char);
  begin
    if p_chk_resign then
--      begin
--        select count(*) into v_count
--          from temploy1
--         where codempid like p_codempid
--           and staemp in ('1','3');
--      exception when no_data_found then
--        begin
--          select count(*) into v_count
--            from temploy1
--           where codempid like p_codempid
--             and staemp in ('9');
--          return get_error_msg_php('HR2101', p_lang, 'temploy1');
--        exception when no_data_found then
--          null;
--        end;
--      end;
      -- update 2018-07-31 --
      begin
        select count(*) into v_count
          from temploy1
         where codempid like p_codempid
           and staemp in ('1','3');
      end;
      if v_count = 0 then
        begin
          select count(*) into v_count
            from temploy1
           where codempid like p_codempid
             and staemp in ('9');
          if v_count > 0 then
            return get_error_msg_php('HR2101', p_lang, 'temploy1');
          end if;
        end;
        -- update 2019-07-03 --
        begin
          select count(*) into v_count
            from temploy1
           where codempid like p_codempid
             and staemp in ('0');
          if v_count > 0 then
            return get_error_msg_php('HR2102', p_lang, 'temploy1');
          end if;
        end;

      end if;
      -- end update 2018-07-31 --
    else
      begin
        select count(*) into v_count
          from temploy1
         where codempid like p_codempid
           and staemp in ('1','3','9');
      exception when no_data_found then
        null;
      end;
    end if;
--    begin
--      select count(*) into v_count
--        from temploy1
--       where codempid like p_codempid
--         and staemp in ('0');
--      if v_count > 0 then
--        return get_error_msg_php('HR2102', p_lang, 'temploy1');
--      end if;
--    end;
    --
    if v_count = 0 then
      return get_error_msg_php('HR2010', p_lang, 'temploy1');
    END IF;

    get_global_secur(p_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    v_flgsecu := secur_main.secur2(p_codempid,p_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
    if not v_flgsecu  then
      return get_error_msg_php('HR3007', p_lang);
    END IF;
    return null;
  end;
  function get_coderror (msg_status in varchar2, param_msg_error in varchar2, p_lang in varchar2 default '101') return varchar2 as
    v_cod      varchar2(4000);
    v_desc     varchar2(4000);
    param_msg  varchar2(4000);
  begin
    if param_msg_error is null then
      begin
        select replace(regexp_substr(param_msg_error, '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%',''),
               replace(regexp_substr(param_msg_error,   '[@]+[#]+[$]+[%].*' , 1, 1),'@#$%','')
          into v_desc,v_cod
          from dual;
      end;
      return nvl(v_cod,'200');
    else
      if msg_status is null then
        begin
          select replace(regexp_substr(param_msg_error, '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%',''),
                 replace(regexp_substr(param_msg_error,   '[@]+[#]+[$]+[%].*' , 1, 1),'@#$%','')
            into v_desc,v_cod
            from dual;
        end;
        return nvl(v_cod,'200');
      elsif msg_status = 'response' then
        begin
          select regexp_substr(param_msg_error, '[^ ]+', 1, 1) into v_cod from dual;
        end;
        param_msg := get_error_msg_php(v_cod,p_lang);
        begin
          select replace(regexp_substr(param_msg, '[@]+[#]+[$]+[%].*', 1, 1),'@#$%','') into v_cod from dual;
        end;
        return v_cod;
      else
        return msg_status;
      end if;
    end if;
  end;
  function get_response (msg_status in varchar2, param_msg_error in varchar2, p_lang in varchar2 default '101') return varchar2 as
    v_cod      varchar2(4000);
    v_desc     varchar2(4000);
    param_msg  varchar2(4000);
  begin
    if param_msg_error is null then
      begin
        select replace(regexp_substr(param_msg_error, '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%',''),
               replace(regexp_substr(param_msg_error,   '[@]+[#]+[$]+[%].*' , 1, 1),'@#$%','') into v_desc,v_cod from dual;
      end;
      return v_desc;
    else
      if msg_status is null then
        begin
          select replace(regexp_substr(param_msg_error, '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%',''),
                 replace(regexp_substr(param_msg_error,   '[@]+[#]+[$]+[%].*' , 1, 1),'@#$%','') into v_desc,v_cod from dual;
        end;
        return v_desc;
      elsif msg_status = 'response' then
        return param_msg_error;
      else
        begin
          select replace(regexp_substr(param_msg_error, '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%','') into v_desc from dual;
        end;
        return v_desc;
      end if;
    end if;
  end;

  function secur_codcomp_cursor(p_coduser in varchar2, p_codcomp in varchar2) return varchar2 is
    v_msg_error varchar2(4000 char);
  begin
    v_msg_error := secur_codcomp(p_coduser, '102', p_codcomp);
    if v_msg_error is not null then
      return 'N';
    end if;
    return 'Y';
  end;

  function secur_codempid_cursor(p_coduser varchar2, p_numlvlst number, p_numlvlen number, p_codempid varchar2) return varchar2 is
     v_flgsecu  boolean := false;
     t_numlvl   temploy1.numlvl%type;
     t_codcomp  temploy1.codcomp%type;
     v_count    number   := 0;
     v_numlvlst     number    :=  0;
     v_numlvlen     number    :=  0;
  begin
    begin
     select numlvl,codcomp into t_numlvl,t_codcomp
       from temploy1
      where codempid = p_codempid;

     if t_numlvl is not null and t_codcomp is not null then
      if t_numlvl between  p_numlvlst and p_numlvlen then
        begin
          select count(codcomp) into v_count
          from  tusrcom
          where coduser = UPPER(p_coduser)
          and   t_codcomp  like  codcomp||'%'
          and   rownum   <= 1;
          if v_count <> 0 then
            v_flgsecu := TRUE;
          else
           v_flgsecu := FALSE;
          end if;
         exception when no_data_found then
          v_flgsecu := TRUE;
         end;
       else
        v_flgsecu := FALSE;
       end if;
      else
        v_flgsecu := FALSE;
      end if;
    exception when no_data_found then  v_flgsecu := TRUE;
    end;

    if not v_flgsecu  then
      return 'N';
    END IF;
    return 'Y';
  end;

  function secur2_cursor(p_coduser varchar2, p_numlvlst number, p_numlvlen number, p_codempid varchar2) return varchar2 is
     v_flgsecu      boolean := false;
     t_numlvl       temploy1.numlvl%type;
     t_codcomp      temploy1.codcomp%type;
     v_count        number   := 0;
     v_numlvlst     number    :=  0;
     v_numlvlen     number    :=  0;
  begin
    begin
     select numlvl,codcomp into t_numlvl,t_codcomp
       from temploy1
      where codempid = p_codempid;

     if t_numlvl is not null and t_codcomp is not null then
      if t_numlvl between  p_numlvlst and p_numlvlen then
        begin
          select count(codcomp) into v_count
          from  tusrcom
          where coduser = UPPER(p_coduser)
          and   t_codcomp  like  codcomp||'%'
          and   rownum   <= 1;
          if v_count <> 0 then
            v_flgsecu := TRUE;
          else
           v_flgsecu := FALSE;
          end if;
         exception when no_data_found then
          v_flgsecu := TRUE;
         end;
       else
        v_flgsecu := FALSE;
       end if;
      else
        v_flgsecu := FALSE;
      end if;
    exception when no_data_found then  v_flgsecu := TRUE;
    end;

    if not v_flgsecu  then
      return 'N';
    end if;
    return 'Y';
  end;

  function secur_main7(p_codcomp in varchar2,p_coduser in varchar2) return varchar2 is
    zflgsecu boolean;
  begin
    zflgsecu := secur_main.secur7(p_codcomp, p_coduser);
    if zflgsecu = true then
      return 'Y';
    else
      return 'N';
    end if;
  end;
end;

/

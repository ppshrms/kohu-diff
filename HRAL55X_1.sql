--------------------------------------------------------
--  DDL for Package Body HRAL55X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL55X" as
-- last update: 19/03/2018 11:05:00
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_codleave          := upper(hcm_util.get_string_t(json_obj, 'p_codleave'));
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DD/MM/YYYY');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_tmp_codleave     tleavecd.codleave%type;
  begin
     if p_codempid is not null then
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codleave is not null then
      begin
        select codleave
          into v_tmp_codleave
          from tleavecd
         where upper(codleave) = p_codleave;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tleavecd');
        return;
      end;
    end if;

    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end check_index;

  function display_hours (p_min number, p_null boolean := false) return varchar2 is
    v_hou_display     varchar2(10 char) := '0';
    v_min_display     varchar2(10 char) := '00';
  begin
    if nvl(p_min, 0) > 0 then
      v_hou_display        := trunc(p_min / 60);
      v_min_display        := lpad(mod(p_min, 60), 2, '0');
      return v_hou_display || ':' || v_min_display;
    else
      if p_null then
        return null;
      else
        return v_hou_display || ':' || v_min_display;
      end if;
    end if;
    exception when others then
      return p_min;
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_exist            varchar2(1 char) := 'N';
    v_set_date         varchar2(100 char);
    v_request_date     varchar2(100 char);
    v_real_date        varchar2(100 char);
    v_codcomp          varchar2(50 char);
    v_lvlst            number;
    v_lvlen            number;
    v_namcentlvl       varchar2(4000 char);
    v_namcent          varchar2(4000 char);
    v_comlevel          number;
    cursor c1 is
      select t1.codcomp, t1.codempid, t1.dtework, t1.codshift,
             t1.numlereq, t1.timstrt, t1.timend, t1.qtymin, t1.codleave
        from tleavetr t1, temploy1 t2
       where t1.codempid = t2.codempid
         and t2.codcomp like p_codcomp || '%'
         and t1.codempid = nvl(p_codempid, t1.codempid)
         and t1.dtework between p_dtestrt and p_dteend
         and codleave = nvl(p_codleave, codleave)
         and ((
              v_exist = '1')
           or (v_exist = '2'
          and t2.numlvl between global_v_zminlvl and global_v_zwrklvl
          and exists (select c.coduser
                        from tusrcom c
                       where c.coduser = global_v_coduser
                         and t2.codcomp like c.codcomp || '%')))
         order by t1.dtework, t1.codempid;
  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    v_flgdata              := 'N';
    v_exist                := '1';
    for r1 in c1 loop
      v_flgdata            := 'Y';
      exit;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang,'tleavetr');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;

    v_flgdata              := 'N';
    v_exist                := '2';
    for r1 in c1 loop
      v_flgdata            := 'Y';

      v_set_date       := '';
      v_request_date   := '';
      v_real_date      := '';

      begin
        select substr(nvl(timstrtw, '00'), 1, 2) || ':' || substr(nvl(timstrtw, '0000'), 3, 2)
               || '-' || substr(nvl(timendw, '00'), 1, 2) || ':' || substr(nvl(timendw, '0000'), 3, 2)
          into v_set_date
          from tattence
         where codempid = r1.codempid
           and dtework = r1.dtework;
      exception when no_data_found then
        v_set_date := '';
      end;

      begin
        select substr(nvl(timstrt, '00'), 1, 2) || ':' || substr(nvl(timstrt, '0000'), 3, 2)
               || '-' || substr(nvl(timend, '00'), 1, 2) || ':' || substr(nvl(timend, '0000'), 3, 2)
          into v_request_date
          from tlereqd
         where numlereq = r1.numlereq
           and dtework = r1.dtework
           and codleave = r1.codleave;
      exception when no_data_found then
        v_request_date := '';
      end;

      v_real_date := substr(r1.timstrt, 1, 2) || ':' || substr(r1.timstrt, 3, 2)
                     || '-'
                     || substr(r1.timend, 1, 2) || ':' || substr(r1.timend, 3, 2);

      obj_data         := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('image', get_emp_img(r1.codempid));
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('date', to_char(r1.dtework, 'DD/MM/YYYY'));
      obj_data.put('shift', r1.codshift);
      obj_data.put('schedtim', v_set_date);
      obj_data.put('request', v_request_date);
      obj_data.put('actual', v_real_date);
      obj_data.put('leavehm', display_hours(r1.qtymin));
      obj_data.put('codleave', r1.codleave);
      obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave, global_v_lang));

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt           := v_rcnt + 1;

    end loop;

    if v_flgdata = 'Y' then
			json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

end HRAL55X;

/

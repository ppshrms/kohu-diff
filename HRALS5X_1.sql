--------------------------------------------------------
--  DDL for Package Body HRALS5X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRALS5X" as
-- last update: 30/03/2018 16:30:00
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
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_yearstrt          := hcm_util.get_string_t(json_obj, 'p_yearstrt');
    p_monthstrt         := hcm_util.get_string_t(json_obj, 'p_monthstrt');
    p_yearend           := hcm_util.get_string_t(json_obj, 'p_yearend');
    p_monthend          := hcm_util.get_string_t(json_obj, 'p_monthend');
    p_codleave          := upper(hcm_util.get_string_t(json_obj, 'p_codleave'));

    p_dtestrt           := p_yearstrt || lpad(p_monthstrt, 2, '0');
    p_dteend            := p_yearend || lpad(p_monthend, 2, '0');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_yearstrt is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_monthstrt is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_yearend is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_monthend is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;
  end check_index;

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
    v_codcomp          varchar2(50 char);
    v_lvlst            number;
    v_lvlen            number;
    v_namcentlvl       varchar2(4000 char);
    v_namcent          varchar2(4000 char);

    v_codcompy         varchar2(40 char);

    -- index codcomp
    cursor c1 is
      select codleave
        from tleavcom a , tleavecd b
       where a.typleave = b.typleave
         and a.codcompy = nvl(v_codcompy,a.codcompy)
         and (
              v_exist = '1'
              or (v_exist = '2'
                  and (upper(codleave) not in (select x.split_values as res_data
                                                 from (with t as
                                                        (select p_codleave str
                                                           from dual
                                                          where p_codleave is not null
                                                        )
                                                      select regexp_substr (str, '[^,]+', 1, level) split_values
                                                        from t
                                                  connect by regexp_substr(str, '[^,]+', 1, level) is not null
                                                      ) x
                                              )
                           or p_codleave is null
                           )
                 )
              );

  begin
    obj_row              := json_object_t();
    v_rcnt               := 0;
    --
    v_codcomp            := p_codcomp;
    v_codcompy           := hcm_util.get_codcomp_level(v_codcomp, 1);
    --
    v_exist              := '1';
    for r1 in c1 loop
      v_flgdata          := 'Y';
      exit;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang,'tleavcom');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;

    v_exist              := '2';
    for r1 in c1 loop
      obj_data           := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codleave', r1.codleave);
      obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave, global_v_lang));

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt          := v_rcnt + 1;
    end loop;

    if v_flgdata = 'Y' then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception
  when no_data_found then
    json_str_output := obj_row.to_clob;
  when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  procedure get_index_choose (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index_choose(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index_choose;

  procedure gen_index_choose (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_exist            varchar2(1 char) := 'N';
    v_codcomp          varchar2(50 char);
    v_lvlst            number;
    v_lvlen            number;
    v_namcentlvl       varchar2(4000 char);
    v_namcent          varchar2(4000 char);

    v_codcompy         varchar2(40 char);

    -- index codcomp

    cursor c1 is
      select x.split_values as codleave
       from (with t as
              (select p_codleave str
                 from dual
                where p_codleave is not null
              )
            select regexp_substr (str, '[^,]+', 1, level) split_values, rownum rowin
              from t
        connect by regexp_substr(str, '[^,]+', 1, level) is not null
            ) x
       where x.split_values in (
                                select codleave
                                  from tleavcom a,tleavecd b
                                 where a.typleave = b.typleave
                                   and a.codcompy = v_codcompy
                                )
    order by x.rowin;

    cursor c2 is
      select x.split_values as codleave
       from (with t as
              (select p_codleave str
                 from dual
                where p_codleave is not null
              )
            select regexp_substr (str, '[^,]+', 1, level) split_values, rownum rowin
              from t
        connect by regexp_substr(str, '[^,]+', 1, level) is not null
            ) x
       where x.split_values in (
                                select codleave
                                  from tleavecd
                               )
    order by x.rowin;

  begin

    obj_row                := json_object_t();
    v_rcnt                 := 0;

    if p_codcomp is not null then
      v_codcomp            := p_codcomp;
      v_codcompy           := hcm_util.get_codcomp_level(v_codcomp, 1);

      for r1 in c1 loop

        obj_data           := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codleave', r1.codleave);
        obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave, global_v_lang));

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt          := v_rcnt + 1;
      end loop;

    else
      for r1 in c2 loop

        obj_data           := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codleave', r1.codleave);
        obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave, global_v_lang));

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt          := v_rcnt + 1;
      end loop;

    end if;
    v_flgdata           := 'Y';

    if v_flgdata = 'Y' then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception
  when no_data_found then
    json_str_output := obj_row.to_clob;
  when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);

    null;
  end gen_index_choose;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_exist            varchar2(1 char) := 'N';
    v_codcomp          varchar2(50 char);
    v_lvlst            number;
    v_lvlen            number;
    v_namcentlvl       varchar2(4000 char);
    v_namcent          varchar2(4000 char);

    cursor c1 is
      select a.codempid, a.codcomp, a.numlvl, a.codpos, a.dteempmt
        from temploy1 a
       where a.codcomp like p_codcomp || '%'
         and a.staemp in ('1', '3')
         and not exists (select b.codempid
                           from tleavetr b
                          where b.codempid = a.codempid
                            and to_char(b.dtework, 'YYYYMM') between p_dtestrt and p_dteend
                            and upper(b.codleave) not in (select x.split_values as res_data
                                                     from (with t as
                                                            (select p_codleave str
                                                               from dual
                                                              where p_codleave is not null
                                                            )
                                                          select regexp_substr (str, '[^,]+', 1, level) split_values
                                                            from t
                                                      connect by regexp_substr(str, '[^,]+', 1, level) is not null
                                                          ) x
                                                  )
                        )
         and (
              (v_exist = '1')
               or (v_exist = '2'
                   and a.numlvl between global_v_zminlvl and global_v_zwrklvl
                   and exists (select c.coduser
                                 from tusrcom c
                                where c.coduser = global_v_coduser
                                  and a.codcomp like c.codcomp || '%'
                               )
                  )
              )
    order by a.codcomp, a.codempid;

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

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('image', get_emp_img(r1.codempid));
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
      obj_data.put('codpos', r1.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
      obj_data.put('levelpos', r1.numlvl);
      obj_data.put('dteempmt', to_char(r1.dteempmt, 'DD/MM/YYYY'));

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt          := v_rcnt + 1;
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
  end gen_detail;

end hrals5x;

/

--------------------------------------------------------
--  DDL for Package Body HRAL5PX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL5PX" as
-- last update: 04/04/2018 16:15:00
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
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DD/MM/YYYY');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
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
    v_dtestle          date;
    v_dteenle          date;
    v_dtein            date;
    v_dteout           date;
    v_typwork          varchar2(10 char);
    v_timstrtw         varchar2(10 char);
    v_timendw          varchar2(10 char);
    v_timin            varchar2(10 char);
    v_timout           varchar2(10 char);
    v_desc_typwork     varchar2(1000 char);
    iotimnrml          varchar2(1000 char);
    iorealnrml         varchar2(1000 char);
    v_comlevel         number;
    v_desfld           varchar2(1000 char);
    cursor c1 is
      select a.rowid, a.dteupd, a.coduser, a.codempid, a.codleave, a.dteyear,
             a.desfld, a.desold, a.desnew, a.remark, a.codcomp
        from tloglvsm a, temploy1 b
       where a.codempid = b.codempid
         and a.codempid = nvl(p_codempid, a.codempid)
         and b.codcomp like p_codcomp || '%'
         and a.dteupd >= p_dtestrt
         and a.dteupd < p_dteend + 1
         and (
              (v_exist = '1')
               or (v_exist = '2'
                   and b.numlvl between global_v_zminlvl and global_v_zwrklvl
                   and exists (select c.coduser
                                 from tusrcom c
                                where c.coduser = global_v_coduser
                                  and b.codcomp like c.codcomp || '%'
                               )
                  )
              )
     order by a.dteupd, a.coduser, a.codempid, a.codleave, a.dteyear, a.numseq;

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
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang,'tloglvsm');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;

    v_flgdata              := 'N';
    v_exist                := '2';
    for r1 in c1 loop
      v_flgdata            := 'Y';

      v_desfld      := r1.desfld;
      if v_desfld = 'QTYPRIYR' then
        v_desfld := get_label_name('HRAL5LEC1', global_v_lang, '70');
      elsif v_desfld = 'QTYVACAT' then
        v_desfld := get_label_name('HRAL5LEC1',global_v_lang,'80');
      elsif v_desfld = 'QTYDAYLE' then
        v_desfld := get_label_name('HRAL5LEC1',global_v_lang,'100');
      elsif v_desfld = 'QTYLEPAY' then
        v_desfld := get_label_name('HRAL5LEC1',global_v_lang,'110');
      elsif v_desfld = 'QTYADJVAC' then
        v_desfld := get_label_name('HRAL5LEC1',global_v_lang,'130');
      elsif v_desfld = 'QTYTLEAV' then
        v_desfld := get_label_name('HRAL5LEC1',global_v_lang,'150');
      elsif v_desfld = 'DTELASTLE' then
        v_desfld := get_label_name('HRAL5LEC1',global_v_lang,'160');
      end if;

      obj_data         := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('image', get_emp_img(r1.codempid));
      obj_data.put('dteupd', to_char(r1.dteupd, 'DD/MM/YYYY'));
      obj_data.put('timupd', to_char(r1.dteupd, 'HH24:MI:SS'));
      obj_data.put('user', r1.coduser);
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('codleave', r1.codleave);
      obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave,global_v_lang));
      obj_data.put('dteyear', r1.dteyear + global_v_zyear);
      obj_data.put('detailupdte', v_desfld);
      obj_data.put('oldval', r1.desold);
      obj_data.put('newval', r1.desnew);
      obj_data.put('remark', r1.remark);

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

end HRAL5PX;

/

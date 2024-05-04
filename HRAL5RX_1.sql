--------------------------------------------------------
--  DDL for Package Body HRAL5RX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL5RX" as
-- last update: 04/04/2018 10:15:00
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
    p_flgcanc           := upper(hcm_util.get_string_t(json_obj, 'p_flgcanc'));
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

    if p_flgcanc is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
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
    status             varchar2(4000 char);
    statuscal          varchar2(4000 char);
    v_comlevel         number;
    cursor c1 is
      select b.codcomp, a.dtereq, a.codempid, a.numlereq,
             a.dtereqr, a.codleave, a.dtestrt, a.dteend,
             a.dteappr, a.codappr, a.flgcanc,
             b.numlvl, a.seqno
        from tleavecc a, temploy1 b
       where a.codempid = b.codempid
         and b.codcomp like p_codcomp || '%'
         and a.codempid = nvl(p_codempid, a.codempid)
         and (a.dtestrt between p_dtestrt and p_dteend
              or a.dteend between p_dtestrt and p_dteend
              or p_dtestrt between a.dtestrt and a.dteend
              or p_dteend between a.dtestrt and a.dteend
             )
         and (a.flgcanc = p_flgcanc or p_flgcanc = 'A')
         and ((v_exist = '1')
               or (v_exist = '2'
                   and b.numlvl between global_v_zminlvl and global_v_zwrklvl
                   and exists (select c.coduser
                                 from tusrcom c
                                where c.coduser = global_v_coduser
                                  and b.codcomp like c.codcomp || '%'
                               )
                   )
             )
    order by b.codcomp, a.dtereq, a.codempid;

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
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang,'tleavecc');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;

    v_flgdata              := 'N';
    v_exist                := '2';
    for r1 in c1 loop
      v_flgdata            := 'Y';

      if r1.flgcanc = 'Y' then
        status := get_label_name('HRAL5RX', global_v_lang, 10);
        statuscal := get_label_name('HRAL5RX', global_v_lang, 30);
      elsif r1.flgcanc = 'E' then
        status := get_label_name('HRAL5RX', global_v_lang, 10);
        statuscal := get_label_name('HRAL5RX', global_v_lang, 40);
      else
        status := get_label_name('HRAL5RX', global_v_lang, 20);
        statuscal := '';
      end if;

      obj_data         := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('image', get_emp_img(r1.codempid));
      obj_data.put('date', to_char(r1.dtereq, 'DD/MM/YYYY'));
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('noleave', r1.numlereq);
      obj_data.put('dteleave', to_char(r1.dtereqr, 'DD/MM/YYYY'));
      obj_data.put('codleave', r1.codleave);
      obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave, global_v_lang));
      obj_data.put('strleave', to_char(r1.dtestrt, 'DD/MM/YYYY'));
      obj_data.put('endleave', to_char(r1.dteend, 'DD/MM/YYYY'));
      obj_data.put('dteapprv', to_char(r1.dteend, 'DD/MM/YYYY'));
      obj_data.put('apprvby', get_temploy_name(r1.codappr, global_v_lang));
      obj_data.put('status', status);
      obj_data.put('statuscal', statuscal);
      obj_data.put('seqno', r1.seqno);

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

end HRAL5RX;

/

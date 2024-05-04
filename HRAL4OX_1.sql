--------------------------------------------------------
--  DDL for Package Body HRAL4OX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL4OX" as
-- last update: 06/03/2018 09:40
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
    p_codempid       := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_codcomp        := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_dtestrt        := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend         := to_date(hcm_util.get_string_t(json_obj,'p_dteend'), 'DD/MM/YYYY');

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

    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;
  end check_index;


  function char_time_to_format_time (p_tim varchar2) return varchar2 is
  begin
    if p_tim is not null then
      return substr(p_tim, 1, 2) || ':' || substr(p_tim, 3, 2);
    else
      return p_tim;
    end if;
  exception when others then
    return p_tim;
  end;

  function cal_hour_unlimited (p_min number, p_null boolean := false) return varchar2 is
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

  function cal_times_count (p_tim number) return varchar2 is
  begin
    if nvl(p_tim, 0) > 0 then
      return p_tim;
    else
      return '';
    end if;
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
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number;
    v_flgdata           varchar2(1 char) := 'N';
    v_flgsecur          varchar2(1 char) := 'N';
    v_data              varchar2(1 char);
    v_codcomp           varchar2(50 char);
    v_lvlst             number;
    v_lvlen             number;
    v_namcentlvl        varchar2(4000 char);
    v_namcent           varchar2(4000 char);
    v_check_secur       boolean;
    cursor c1 is
       select min(dtework) dtestrt, max(dtework) dteend, count(*) totaldte,
              row_number() over (order by min(dtework)) grp , codempid, codcomp, codpos
        from (
                select dtework, row_number() over (order by codempid,dtework) rn ,
                       dtework - row_number() over (order by codempid,dtework) grp_date ,codempid,codcomp , codpos
                 from (
                        select a.dtework,a.codempid, b.codcomp, b.codpos,
                               (row_number() over (order by a.codempid,dtework)-row_number() over (partition by a.codempid,dtework order by a.codempid,dtework)) as grp
                          from tattence a, temploy1 b
                         where  a.codempid = nvl(p_codempid,a.codempid)
                            and a.codempid = b.codempid(+)
                            and b.codcomp like nvl(p_codcomp || '%',b.codcomp)
                           and (dtework between p_dtestrt and p_dteend)
                           and (dtein is not null or dteout is not null)
                      ) t
               group by grp,dtework ,codempid, codcomp, codpos
              )
              having count(*) >= 7
              group  by grp_date, codempid, codcomp, codpos
              order  by codempid,min(dtework);
  begin
    obj_row               := json_object_t();
    v_rcnt                := 0;

    for r1 in c1 loop
      v_flgdata := 'Y';

      v_check_secur      := SECUR_MAIN.SECUR2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_check_secur then

         v_flgsecur := 'Y';
          obj_data     := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);
          obj_data.put('codcomp', r1.codcomp);
          obj_data.put('desc_codcomp', get_tcenter_name(hcm_util.get_codcomp_level(r1.codcomp, null), global_v_lang));
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('codpos', r1.codpos);
          obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
          obj_data.put('dtestrt', to_char(r1.dtestrt,'dd/mm/yyyy'));
          obj_data.put('dteend', to_char(r1.dteend, 'dd/mm/yyyy'));
          obj_data.put('totaldte', r1.totaldte);

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt       := v_rcnt + 1;

      end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tattence');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    else
      if v_flgsecur = 'N' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
				json_str_output := obj_row.to_clob;
      end if;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

end HRAL4OX;

/

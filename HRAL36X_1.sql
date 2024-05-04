--------------------------------------------------------
--  DDL for Package Body HRAL36X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL36X" as
-- last update: 23/02/2018 12:02

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
    p_codcomp     := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_codempid    := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_codcalen    := upper(hcm_util.get_string_t(json_obj, 'p_codcalen'));
    p_dtestrt     := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend      := to_date(hcm_util.get_string_t(json_obj,'p_dteend'), 'DD/MM/YYYY');
    p_flginput    := upper(hcm_util.get_string_t(json_obj, 'p_flginput'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_secur            boolean := true;
    v_codcalen         TCODWORK.CODCODEC%TYPE;
  begin
    if p_codempid is not null then
      p_codcomp := null;
      p_codcalen := null;
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codcomp is not null then
      p_codempid := null;
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codcalen is not null then
      p_codempid := null;
      begin
        select codcodec
          into v_codcalen
          from TCODWORK
         where codcodec = p_codcalen
           and rownum <= 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCODWORK');
      end;
    end if;

--    if p_codempid is null then
--      if p_codcomp is null then
--        param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'codcomp');
--        return;
--      end if;
--
--      if p_codcalen is null then
--        param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'codcalen');
--        return;
--      end if;
--    end if;

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

    if p_flginput is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
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

  procedure get_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data;

  procedure gen_data (json_str_output out clob) is
    v_flgdata              varchar2(1 char) := 'N';
    v_exist                varchar2(1 char) := 'N';
    obj_row                json_object_t;
    obj_data               json_object_t;
    v_rcnt                 number;
    v_codcomp              varchar2(50 char);
    v_lvlst                number;
    v_lvlen                number;
    v_namcentlvl           varchar2(4000 char);
    v_namcent              varchar2(4000 char);
    v_comlevel             number;
    cursor c1 is
      select b.codempid, b.codcomp, a.dtedate, a.timtime, a.codbadge, a.codrecod, a.flgtranal, b.numlvl, a.mchno, a.rowid,
      nvl(a.flginput, '1') flginput, a.dtetime
        from tatmfile a,temploy1 b
       where a.codempid = b.codempid
         and b.codempid = nvl(p_codempid,b.codempid)
         and b.codcomp like p_codcomp || '%'
         and b.codcalen = nvl(p_codcalen,b.codcalen)
         and trunc(a.dtedate) between p_dtestrt and p_dteend
--         and a.flginput = p_flginput
         and ((p_flginput = '3') or (nvl(a.flginput,'1') = p_flginput))
         and (
              (v_exist = '1')
               or (v_exist = '2'
                   and b.numlvl between global_v_zminlvl and global_v_zwrklvl
                   and exists (select c.coduser
                                 from tusrcom c
                                where c.coduser = global_v_coduser
                                  and b.codcomp like c.codcomp || '%')
                  )
             )
    order by /*b.codcomp,*/b.codempid,a.dtetime,a.codbadge;
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
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang,'tatmfile');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;

    v_flgdata              := 'N';
    v_exist                := '2';
    for r1 in c1 loop
      v_flgdata            := 'Y';
--      if v_codcomp is null or v_codcomp <> r1.codcomp then
--          for i in 1..10 loop
--              comp_label(r1.codcomp,v_codcomp,i,global_v_lang,v_namcentlvl,v_namcent,v_comlevel);
--              if v_namcent is not null then
--                  obj_data := json_object_t();
--                  obj_data.put('codempid',v_namcentlvl);
--                  obj_data.put('desc_codempid',v_namcent);
--                  obj_data.put('flgbrk',to_char(i));
--                  obj_data.put('coderror' ,'200');
--                  obj_row.put(to_char(v_rcnt),obj_data);
--                  v_rcnt := v_rcnt + 1;
--            end if;
--          end loop;
--          v_codcomp := r1.codcomp;
--      end if;
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
      obj_data.put('dtedate', to_char(r1.dtedate, 'DD/MM/YYYY'));
      obj_data.put('timtime', char_time_to_format_time(r1.timtime));
      obj_data.put('codbadge', r1.codbadge);
      obj_data.put('codrecod', r1.codrecod);
      obj_data.put('flgtranal', r1.flgtranal);
      obj_data.put('image', get_emp_img(r1.codempid));
      obj_data.put('mchno', r1.mchno);
      obj_data.put('flginput', get_tlistval_name('FLGINPUT',r1.flginput, global_v_lang));
      obj_data.put('rowid', r1.rowid);
      obj_data.put('dtetime', to_char(r1.dtetime, 'DD/MM/YYYY HH24:MI:SS'));

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt            := v_rcnt + 1;
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
  end gen_data;

end HRAL36X;

/

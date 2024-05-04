--------------------------------------------------------
--  DDL for Package Body HRALS3X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRALS3X" as
-- last update: 03/04/2018 10:40:00
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
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_codleave          := upper(hcm_util.get_string_t(json_obj, 'p_codleave'));
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DDMMYYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DDMMYYYY');
    
    p_codleave_array    := hcm_util.get_json_t(json_obj, 'p_codleave');

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

    if p_codempid is not null then
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;


    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;
  end check_index;

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

  function cal_times (p_tim number) return varchar2 is
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
        from tleavcom a,tleavecd b
       where a.typleave = b.typleave
         and a.codcompy = v_codcompy
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

    cursor c2 is
      select codleave
        from tleavecd
       where (
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
    obj_row                := json_object_t();
    v_rcnt                 := 0;

    if p_codempid is not null or p_codcomp is not null then
        if  p_codempid is null  then
         v_codcomp            := p_codcomp;
        else
            begin
              select codcomp
                into v_codcomp
                from temploy1
               where codempid = p_codempid;
            exception when no_data_found then
              v_codcomp := '';
            end;
        end if;

      v_codcompy           := hcm_util.get_codcomp_level(v_codcomp, 1);
      v_exist              := '1';
      for r1 in c1 loop
        v_flgdata          := 'Y';
        exit;
      end loop;

      if v_flgdata = 'N' then
        param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tleavcom');
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
    else
      v_exist              := '1';
      for r1 in c2 loop
        v_flgdata          := 'Y';
        exit;
      end loop;

      if v_flgdata = 'N' then
        param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tleavcom');
        json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
        return;
      end if;

      v_exist              := '2';
      for r1 in c2 loop

        obj_data           := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codleave', r1.codleave);
        obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave, global_v_lang));

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt          := v_rcnt + 1;
      end loop;

    end if;

    if v_flgdata = 'Y' then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception
  when no_data_found then
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
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
    obj_data            json_object_t;
    v_rcnt_codinc       number := 0;
    obj_codinc          json_object_t;
    
    cursor c_tinitregd is
      select a.numseq, a.codinc
        from tinitregd a, tinitregh b
       where a.codrep  = b.codrep
         and a.codapp  = b.codapp
         and a.codapp  = p_codapp
         and a.codrep  = 'TEMP'
         and b.typcode = 5
       order by a.numseq;
begin
    obj_data            := json_object_t();
    obj_codinc          := json_object_t();
      for r1 in c_tinitregd loop
        if r1.codinc is not null then
          v_rcnt_codinc   := v_rcnt_codinc + 1;
          obj_codinc.put('codleave', r1.codinc);
          obj_codinc.put('desc_codleave', get_tleavecd_name(r1.codinc, global_v_lang));
          obj_data.put(to_char(v_rcnt_codinc - 1), obj_codinc);
        end if;
      end loop;
--      obj_data.put('codleave', obj_codinc);
    json_str_output := obj_data.to_clob;
end gen_index_choose;

/*
  procedure gen_index_choose (json_str_output out clob) is
    obj_row            json;
    obj_data           json;
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
                                  from tleavcom
                                 where codcompy = v_codcompy
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
    obj_row                := json();
    v_rcnt                 := 0;

  if p_codempid is not null or p_codcomp is not null then
      if  p_codempid is null  then
         v_codcomp            := p_codcomp;
      else
        begin
          select codcomp
            into v_codcomp
            from temploy1
           where codempid = p_codempid;
        exception when no_data_found then
          v_codcomp := '';
        end;
      end if;
      v_codcompy := hcm_util.get_codcomp_level(v_codcomp, 1);

      for r1 in c1 loop
        obj_data           := json();
        obj_data.put('coderror', '200');
        obj_data.put('codleave', r1.codleave);
        obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave, global_v_lang));

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt          := v_rcnt + 1;
      end loop;
    else
      for r1 in c2 loop

        obj_data           := json();
        obj_data.put('coderror', '200');
        obj_data.put('codleave', r1.codleave);
        obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave, global_v_lang));

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt          := v_rcnt + 1;
      end loop;

    end if;
    v_flgdata           := 'Y';

    if v_flgdata = 'Y' then
      dbms_lob.createtemporary(json_str_output, true);
      obj_row.to_clob(json_str_output);
    else
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception
  when no_data_found then
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index_choose;
*/
  procedure save_index (json_str_input in clob, json_str_output out clob) is
    v_maxrcnt           number := 0;
    v_rcnt              number := 0;
    v_codleave          tinitregd.codinc%type;
  begin
    initial_value (json_str_input);
    begin
      insert
        into tinitregh (
          codapp, codrep, typcode,
          descode, descodt, descod3, descod4, descod5,
          codcreate
        )
      values (
        p_codapp, 'TEMP', 5,
        null, null, null, null, null,
        global_v_coduser
      );
    exception when dup_val_on_index then
      update tinitregh
          set typcode = 5,
              descode = null,
              descodt = null,
              descod3 = null,
              descod4 = null,
              descod5 = null,
              coduser = global_v_coduser
        where codapp = p_codapp
          and codrep = 'TEMP';
    end;
    if param_msg_error is null then
      v_maxrcnt        := p_codleave_array.get_size;

      for i in 0..v_maxrcnt - 1 loop
        v_rcnt          := i + 1;
        v_codleave        := hcm_util.get_string_t(p_codleave_array, to_char(i));
        begin
          insert
            into tinitregd (
              codapp, codrep, numseq, codinc,  codcreate
            )
          values (
            p_codapp,'TEMP', v_rcnt, v_codleave, global_v_coduser
          );
        exception when dup_val_on_index then
          update tinitregd
            set codinc = v_codleave,
                coduser = global_v_coduser
          where codapp = p_codapp
            and codrep = 'TEMP'
            and numseq = v_rcnt;
        end;
      end loop;
      delete from tinitregd
       where codapp = p_codapp
         and codrep = 'TEMP'
         and numseq > v_rcnt;

      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

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
    v_flgsecur         varchar2(1 char) := 'N';
    v_codcomp          varchar2(50 char);
    v_lvlst            number;
    v_lvlen            number;
    v_namcentlvl       varchar2(4000 char);
    v_namcent          varchar2(4000 char);

    v_codempid         varchar2(100 char);
    v_qtyhwork         number;
    v_qtyhwork2        number;
    v_qtyminot         number;
    v_qtylate          number;
    v_qtyearly         number;
    v_qtytabsent       number;
    v_qtytlate         number;
    v_qtytearly        number;
    v_dayabsent        number;
    v_qtynostam        number;

    v_qtyavgwk         number;
    v_prefix_codleave  varchar2(100 char) := 'hrleave';
    v_key_codleave     varchar2(100 char) := 'codleave';
    v_desc_codleave    varchar2(100 char) := 'desc_codleave';
    obj_codleave       json_object_t;
    v_real_codleave    number;
    v_data_codleave    varchar2(100 char);
    v_other_codleave   number;
    v_total_codleave   number;
    v_real_key         varchar2(100 char);

    v_row_map_key      json_object_t;
    v_row_map_value    json_object_t;
    v_tmp_rownum       varchar2(100 char);
    v_tmp_codleave     varchar2(100 char);

    v_codleave_count   number;

    v_token1           number;
    v_token2           varchar2(4000 char);
    v_check_secur       boolean;

    cursor c1 is
      select a.codempid, a.codcomp, a.numlvl
        from temploy1 a
       where a.codcomp like p_codcomp || '%'
         and a.codempid = nvl(p_codempid, a.codempid)
         and exists (select d.codempid
                       from tattence d
                      where d.codempid = a.codempid
                        and (d.dtework between p_dtestrt and p_dteend)
                     )
    order by a.codcomp, a.codempid;

    cursor c2 is
      select codleave, sum(qtyday) qtyday
        from tleavetr
       where codempid = v_codempid
         and (dtework between p_dtestrt and p_dteend)
    group by codleave;

    cursor c3 is
      select x.split_values as res_data, rownum
        from (with t as
               (select p_codleave str
                  from dual
                 where p_codleave is not null
               )
             select regexp_substr (str, '[^,]+', 1, level) split_values
               from t
         connect by regexp_substr(str, '[^,]+', 1, level) is not null
             ) x;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    v_codleave_count       := 0;
    for r3 in c3 loop
      v_codleave_count     := v_codleave_count + 1;
    end loop;

    for r1 in c1 loop
      v_flgdata            := 'Y';

      v_codempid           := r1.codempid;

      v_check_secur       := SECUR_MAIN.SECUR2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_check_secur then
        v_flgsecur        := 'Y';
        begin
          select qtyavgwk
           into v_qtyavgwk
           from tcontral
          where codcompy = hcm_util.get_codcomp_level(r1.codcomp, 1)
            and dteeffec = (select max(dteeffec)
                              from tcontral
                             where codcompy = hcm_util.get_codcomp_level(r1.codcomp, 1)
                               and dteeffec <= sysdate);
        exception when no_data_found then
          v_qtyavgwk := 0;
        end;
        --
        begin
          select sum(qtyhwork)
            into v_qtyhwork
            from tattence
           where codempid = v_codempid
             and (dtework between p_dtestrt and p_dteend)
             and typwork in ('W', 'L');
        exception when no_data_found then
          v_qtyhwork := 0;
        end;

        begin
          select sum(qtyminot)
            into v_qtyminot
            from tovrtime
           where codempid = v_codempid
             and (dtework between p_dtestrt and p_dteend);
        exception when no_data_found then
          v_qtyminot := 0;
        end;

        begin
        select sum(qtylate), sum(qtyearly), sum(qtytabs),
               sum(qtytlate), sum(qtytearly), sum(dayabsent), sum(qtynostam)
          into v_qtylate, v_qtyearly, v_qtytabsent, v_qtytlate,
               v_qtytearly, v_dayabsent, v_qtynostam
          from tlateabs
         where codempid = v_codempid
           and (dtework between p_dtestrt and p_dteend);
        exception when no_data_found then
          v_qtylate          := 0;
          v_qtyearly         := 0;
          v_qtytabsent       := 0;
          v_qtytlate         := 0;
          v_qtytearly        := 0;
          v_dayabsent        := 0;
          v_qtynostam        := 0;
        end;

        obj_codleave         := json_object_t();
        v_other_codleave     := 0;
        v_total_codleave     := 0;

        v_row_map_key        := json_object_t();
        v_row_map_value      := json_object_t();

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        v_qtyhwork2 := hcm_util.get_qtyavgwk(null,r1.codempid);
         hcm_util.cal_dhm_hm (0,0,v_qtyhwork,v_qtyhwork2,'1',v_token1,v_token1,v_token1,v_token2);
        obj_data.put('qtyhour', (v_token2));
        v_qtyhwork := hcm_util.get_qtyavgwk(null,r1.codempid);
        hcm_util.cal_dhm_hm (0,0,v_qtyminot,v_qtyhwork,'1',v_token1,v_token1,v_token1,v_token2);
        obj_data.put('qtyhourot', (v_token2));
        hcm_util.cal_dhm_hm (0,0,v_qtylate,v_qtyhwork,'1',v_token1,v_token1,v_token1,v_token2);
        obj_data.put('hrlate', (v_token2));
        hcm_util.cal_dhm_hm (0,0,v_qtyearly,v_qtyhwork,'1',v_token1,v_token1,v_token1,v_token2);
        obj_data.put('hreary', (v_token2));
        hcm_util.cal_dhm_hm (v_dayabsent,0,0,v_qtyhwork,'1',v_token1,v_token1,v_token1,v_token2);
        obj_data.put('hrabsen', v_token2);
        obj_data.put('tislate', cal_times(v_qtytlate));
        obj_data.put('tiseary', cal_times(v_qtytearly));
        obj_data.put('tisabsen', cal_times(v_qtytabsent));
        obj_data.put('forgcard', cal_times(v_qtynostam));
        for r3 in c3 loop
          v_tmp_rownum     := to_char(r3.rownum);
          v_tmp_codleave   := upper(r3.res_data);
          v_row_map_key.put(v_tmp_rownum, v_tmp_codleave);
          v_row_map_value.put(v_prefix_codleave||v_tmp_codleave, v_tmp_rownum);
          obj_data.put(v_prefix_codleave||v_tmp_rownum, '');
          obj_data.put(v_key_codleave||v_tmp_rownum, v_tmp_codleave);
          obj_data.put(v_desc_codleave||v_tmp_rownum, get_tleavecd_name(v_tmp_codleave, global_v_lang));
        end loop;

        for r2 in c2 loop
          if ','||p_codleave||',' like '%,'||r2.codleave||',%' then
            null;
          else
            v_other_codleave := v_other_codleave + nvl(r2.qtyday, 0);
          end if;
          v_total_codleave := v_total_codleave + nvl(r2.qtyday, 0);
          v_real_key := hcm_util.get_string_t(v_row_map_value, v_prefix_codleave||upper(r2.codleave));
          hcm_util.cal_dhm_hm (r2.qtyday,0,0,v_qtyhwork,'1',v_token1,v_token1,v_token1,v_token2);
          obj_data.put(v_prefix_codleave||v_real_key,v_token2);
        end loop;
        obj_data.put('hrleave_num', v_codleave_count);
        hcm_util.cal_dhm_hm (v_other_codleave,0,0,v_qtyhwork,'1',v_token1,v_token1,v_token1,v_token2);
        obj_data.put('otherhrleave', v_token2);
        hcm_util.cal_dhm_hm (v_total_codleave,0,0,v_qtyhwork,'1',v_token1,v_token1,v_token1,v_token2);
        obj_data.put('totalhrleave', v_token2);

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt          := v_rcnt + 1;
      end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecur = 'N' then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;

end HRALS3X;

/

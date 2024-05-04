--------------------------------------------------------
--  DDL for Package Body HRPY57X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY57X" as
-- last update: 17/02/2023 20:50
  function zero_number (v_number number) return varchar2 is
  begin
    if v_number = 1 then
      return '0';
    elsif v_number = 2 then
      return '00';
    elsif v_number = 3 then
      return '000';
    elsif v_number = 4 then
      return '0000';
    else
      return '';
    end if;
  end;

  function split_codcomp (v_codcomp varchar2) return varchar2 is
    v_show_codcomp varchar2(4000 char) := '';
    v_comlevel     tcenter.comlevel%type;
    v_codcom1      tcenter.codcom1%type;
    v_codcom2      tcenter.codcom2%type;
    v_codcom3      tcenter.codcom3%type;
    v_codcom4      tcenter.codcom4%type;
    v_codcom5      tcenter.codcom5%type;
    v_codcom6      tcenter.codcom6%type;
    v_codcom7      tcenter.codcom7%type;
    v_codcom8      tcenter.codcom8%type;
    v_codcom9      tcenter.codcom9%type;
    v_codcom10     tcenter.codcom10%type;
    v_count        number := 0;
  begin
    begin
      select count(*)
        into v_count
        from tsetcomp;
    exception when others then
      v_count := 0;
    end;
    select comlevel,
           codcom1,codcom2,codcom3,codcom4,codcom5,
           codcom6,codcom7,codcom8,codcom9,codcom10
      into v_comlevel,
           v_codcom1,v_codcom2,v_codcom3,v_codcom4,v_codcom5,
           v_codcom6,v_codcom7,v_codcom8,v_codcom9,v_codcom10
      from tcenter
     where codcomp = v_codcomp;
--    v_show_codcomp := v_codcom1 || '-' ||
--                      v_codcom2 || '-' ||
--                      v_codcom3 || '-' ||
--                      v_codcom4 || '-' ||
--                      v_codcom5 || '-' ||
--                      v_codcom6 || '-' ||
--                      v_codcom7 || '-' ||
--                      v_codcom8 || '-' ||
--                      v_codcom9 || '-' ||
--                      v_codcom10;
    v_show_codcomp := v_codcom1;
    if v_count >= 2 then
      if v_codcom2 is null then
        begin
          select zero_number(qtycode)
            into v_codcom2
            from tsetcomp
           where numseq = 2;
        exception when no_data_found then
          v_codcom2 := '';
        end;
      end if;
      v_show_codcomp := v_show_codcomp || '-' || v_codcom2;
    end if;
    if v_count >= 3 then
      if v_codcom3 is null then
        begin
          select zero_number(qtycode)
            into v_codcom3
            from tsetcomp
           where numseq = 3;
        exception when no_data_found then
          v_codcom3 := '';
        end;
      end if;
      v_show_codcomp := v_show_codcomp || '-' || v_codcom3;
    end if;
    if v_count >= 4 then
      if v_codcom4 is null then
        begin
          select zero_number(qtycode)
            into v_codcom4
            from tsetcomp
           where numseq = 4;
        exception when no_data_found then
          v_codcom4 := '';
        end;
      end if;
      v_show_codcomp := v_show_codcomp || '-' || v_codcom4;
    end if;
    if v_count >= 5 then
      if v_codcom5 is null then
        begin
          select zero_number(qtycode)
            into v_codcom5
            from tsetcomp
           where numseq = 5;
        exception when no_data_found then
          v_codcom5 := '';
        end;
      end if;
      v_show_codcomp := v_show_codcomp || '-' || v_codcom5;
    end if;
    if v_count >= 6 then
      if v_codcom6 is null then
        begin
          select zero_number(qtycode)
            into v_codcom6
            from tsetcomp
           where numseq = 6;
        exception when no_data_found then
          v_codcom6 := '';
        end;
      end if;
      v_show_codcomp := v_show_codcomp || '-' || v_codcom6;
    end if;
    if v_count >= 7 then
      if v_codcom7 is null then
        begin
          select zero_number(qtycode)
            into v_codcom7
            from tsetcomp
           where numseq = 7;
        exception when no_data_found then
          v_codcom7 := '';
        end;
      end if;
      v_show_codcomp := v_show_codcomp || '-' || v_codcom7;
    end if;
    if v_count >= 8 then
      if v_codcom8 is null then
        begin
          select zero_number(qtycode)
            into v_codcom8
            from tsetcomp
           where numseq = 8;
        exception when no_data_found then
          v_codcom8 := '';
        end;
      end if;
      v_show_codcomp := v_show_codcomp || '-' || v_codcom8;
    end if;
    if v_count >= 9 then
      if v_codcom9 is null then
        begin
          select zero_number(qtycode)
            into v_codcom9
            from tsetcomp
           where numseq = 9;
        exception when no_data_found then
          v_codcom9 := '';
        end;
      end if;
      v_show_codcomp := v_show_codcomp || '-' || v_codcom9;
    end if;
    if v_count >= 10 then
      if v_codcom10 is null then
        begin
          select zero_number(qtycode)
            into v_codcom10
            from tsetcomp
           where numseq = 10;
        exception when no_data_found then
          v_codcom10 := '';
        end;
      end if;
      v_show_codcomp := v_show_codcomp || '-' || v_codcom10;
    end if;
    return v_show_codcomp;
  exception when no_data_found then
    return v_codcomp;
  end;

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
    global_v_chken      := hcm_secur.get_v_chken;

    -- index params
    p_codcomp     := upper(hcm_util.get_string_t(json_obj, 'codcomp'));
    p_year        := to_number(hcm_util.get_string_t(json_obj, 'year'));
    p_month       := to_number(hcm_util.get_string_t(json_obj, 'month'));
    p_numperiod   := to_number(hcm_util.get_string_t(json_obj, 'numperiod'));
    p_flgcodcomp  := to_number(hcm_util.get_string_t(json_obj, 'flgcodcomp'));

    v_text_key    := 'otrate';

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'numperiod');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'year');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end check_index;
/*
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
*/

  procedure get_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data;

--  procedure gen_data (json_str_output out clob) is
----    v_flgdata              varchar2(1 char) := 'N';
----    v_exist                varchar2(1 char) := 'N';
----    obj_row                json;
----    obj_data               json;
----    v_rcnt                 number;
----    v_codcomp              varchar2(50 char);
----    v_lvlst                number;
----    v_lvlen                number;
----    v_namcentlvl           varchar2(4000 char);
----    v_namcent              varchar2(4000 char);
----    v_comlevel             number;
----    cursor c1 is
----      select b.codempid, b.codcomp, a.dtedate, a.timtime, a.codbadge, a.codrecod, a.flgtranal, b.numlvl, a.rowid
----        from tatmfile a,temploy1 b
----       where a.codempid = b.codempid
----         and b.codempid = nvl(p_codempid,b.codempid)
----         and b.codcomp like p_codcomp || '%'
----         and b.codcalen = nvl(p_codcalen,b.codcalen)
----         and trunc(a.dtedate) between p_dtestrt and p_dteend
----         and (
----              (v_exist = '1')
----               or (v_exist = '2'
----                   and b.numlvl between global_v_zminlvl and global_v_zwrklvl
----                   and exists (select c.coduser
----                                 from tusrcom c
----                                where c.coduser = global_v_coduser
----                                  and b.codcomp like c.codcomp || '%')
----                  )
----             )
----    order by b.codcomp,b.codempid,a.dtetime,a.codbadge;
--  begin
----    v_rcnt                 := 0;
----    v_flgdata              := 'N';
----    v_exist                := '1';
----    for r1 in c1 loop
----      v_flgdata            := 'Y';
----      exit;
----    end loop;
----
----    if v_flgdata = 'N' then
----      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tatmfile');
----      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
----      return;
----    end if;
----
----    v_flgdata              := 'N';
----    v_exist                := '2';
----    for r1 in c1 loop
----      v_flgdata            := 'Y';
----      if v_codcomp is null or v_codcomp <> r1.codcomp then
----          for i in 1..10 loop
----              comp_label(r1.codcomp,v_codcomp,i,global_v_lang,v_namcentlvl,v_namcent,v_comlevel);
----              if v_namcent is not null then
----                  obj_data := json();
----                  obj_data.put('codempid',v_namcentlvl);
----                  obj_data.put('desc_codempid',v_namcent);
----                  obj_data.put('flgbrk',to_char(i));
----                  obj_data.put('coderror' ,'200');
----                  obj_row.put(to_char(v_rcnt),obj_data);
----                  v_rcnt := v_rcnt + 1;
----            end if;
----          end loop;
----          v_codcomp := r1.codcomp;
----      end if;
----      obj_data          := json();
----      obj_data.put('coderror', '200');
----      obj_data.put('codcomp', r1.codcomp);
----      obj_data.put('codempid', r1.codempid);
----      obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
----      obj_data.put('dtedate', to_char(r1.dtedate, 'DD/MM/YYYY'));
----      obj_data.put('timtime', char_time_to_format_time(r1.timtime));
----      obj_data.put('codbadge', r1.codbadge);
----      obj_data.put('codrecod', r1.codrecod);
----      obj_data.put('flgtranal', r1.flgtranal);
----      obj_data.put('image', get_emp_img(r1.codempid));
----      obj_data.put('rowid', r1.rowid);
----
----      obj_row.put(to_char(v_rcnt), obj_data);
----      v_rcnt            := v_rcnt + 1;
----    end loop;
----
----    if v_flgdata = 'Y' then
----    else
----      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
----      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
----    end if;
--    null;
--  exception when others then
--    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
--    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
--  end gen_data;

  procedure gen_data (json_str_output out clob) is
    obj_rows             json_object_t := json_object_t();
    obj_data             json_object_t;
    v_count              number := 0;
    v_count_rate         number := 0;

    v_flg_exist          boolean := false;
    v_flg_secure         boolean := false;
    v_flg_permission     boolean := false;

    v_codcompy           varchar2(100 char);
    v_qtysmot            number := null;
    v_amtspot            number := null;

    v_rateot5           varchar2(100 char);
    v_rateot_min5       number := 0;
    v_ot5_all           number := 0;
    v_amtspot_min5      number :=0;
    v_all_qtysmot       number :=0;
    v_all_amtspot       number :=0;

    --<<User37 ST11 19/09/2020 Final Test Phase 1 V11 #2190
    v_chksecu           varchar2(1);
    v_codcomp           varchar2(100);
    v_codcompw          varchar2(100);
    -->>User37 ST11 19/09/2020 Final Test Phase 1 V11 #2189

    v_array             number := 0;
    v_chkarray          varchar2(1);
    v_codcompO          totsum.codcomp%type;-- := '!@#$';
    type rteotpay is table of number(3,2) index by binary_integer;
      a_rteotpay  rteotpay;

    cursor c1 is
      select decode(p_flgcodcomp,'1',a.codcomp,'2',b.codcompw) codcomp,
             b.rtesmot,sum(nvl(b.qtysmot,0)) as qtysmot,sum(nvl(stddec(b.amtspot,a.codempid,global_v_chken),0)) as amtspot
        from totsum a, totsumd b, temploy1 c
       where a.codempid  = b.codempid
         and a.numperiod = b.numperiod
         and a.dtemthpay = b.dtemthpay
         and a.dteyrepay = b.dteyrepay
         and a.codempid  = c.codempid
         and a.numperiod = p_numperiod
         and a.dtemthpay = p_month
         and a.dteyrepay = p_year
         and a.codcomp   like p_codcomp || '%'
         --<<User37 ST11 19/09/2020 Final Test Phase 1 V11 #2190
         and (v_chksecu = 'N' or (v_chksecu = 'Y' and c.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                                    and exists (select d.coduser
                                                                  from tusrcom d
                                                                 where d.coduser = global_v_coduser
                                                                   and c.codcomp like d.codcomp||'%')))
         and nvl(stddec(b.amtspot,a.codempid,global_v_chken),0) > 0
         -->>User37 ST11 19/09/2020 Final Test Phase 1 V11 #2189
    group by decode(p_flgcodcomp,'1',a.codcomp,'2',b.codcompw),b.rtesmot
    order by decode(p_flgcodcomp,'1',a.codcomp,'2',b.codcompw),b.rtesmot;

    cursor c2 is
      select distinct(rteotpay) rteotpay
        from totratep2
       where codcompy = nvl(v_codcompy,codcompy)
    order by rteotpay;

  begin
		for i in 1..4 loop
			a_rteotpay(i) := null;
		end loop;
    for r2 in c2 loop
      v_array := v_array + 1;
      a_rteotpay(v_array) := r2.rteotpay;
    end loop;
    --
    v_chksecu := 'N';--User37 ST11 19/09/2020 Final Test Phase 1 V11 #2190
    for r1 in c1 loop
      v_codcompy := hcm_util.get_codcomp_level(r1.codcomp,1);
      for r2 in c2 loop
        v_flg_exist := true;
        exit;
      end loop;
    end loop;
     if not v_flg_exist then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'totsum');
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
     end if;
    v_chksecu := 'Y';--User37 ST11 19/09/2020 Final Test Phase 1 V11 #2190
    obj_data := json_object_t();
    for r1 in c1 loop
      v_count_rate     := 0;
      v_flg_permission := true;
      v_codcompy := hcm_util.get_codcomp_level(r1.codcomp,1);
      if nvl(v_codcompO,r1.codcomp) <> r1.codcomp then
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
        obj_data := json_object_t();
        v_rateot_min5    := 0;
        v_amtspot_min5   := 0;
        v_all_qtysmot    := 0;
        v_all_amtspot    := 0;
      end if;
      v_codcompO := r1.codcomp;

      obj_data.put('codcomp'      ,r1.codcomp);
      obj_data.put('desc_codcomp' ,get_tcenter_name(r1.codcomp ,global_v_lang));
      obj_data.put('show_codcomp' ,split_codcomp(r1.codcomp));
      obj_data.put('codcompw'     ,r1.codcomp);
      obj_data.put('desc_codcompw',get_tcenter_name(r1.codcomp,global_v_lang));
      obj_data.put('show_codcompw',split_codcomp(r1.codcomp));

      obj_data.put('otkey', v_text_key);
      obj_data.put('otlen', v_rateot_length+1);
      --
      v_chkarray := 'N';
      v_all_qtysmot := v_all_qtysmot + r1.qtysmot;
      v_all_amtspot := v_all_amtspot + r1.amtspot;
      for i in 1..4 loop
        if a_rteotpay(i) = r1.rtesmot then
          v_chkarray := 'Y';
          --<<User37 Final Test Phase 1 V11 #2930 15/10/2020
          --obj_data.put('qtysmot' || to_char(i),hcm_util.convert_minute_to_hour(r1.qtysmot));
          obj_data.put('qtysmot' || to_char(i),hrpy57x.convert_minute_to_hour(r1.qtysmot));
          -->>User37 Final Test Phase 1 V11 #2930 15/10/2020
          obj_data.put('amtspot' || to_char(i),to_char(r1.amtspot,'fm999999999990.00'));
          exit;
        end if;
      end loop;

      if v_chkarray = 'N' then
        v_rateot_min5 := v_rateot_min5 + nvl(r1.qtysmot, 0);
        --<<User37 Final Test Phase 1 V11 #2930 15/10/2020
        --obj_data.put('qtysmot5',hcm_util.convert_minute_to_hour(v_rateot_min5));
        obj_data.put('qtysmot5',hrpy57x.convert_minute_to_hour(v_rateot_min5));
        -->>User37 Final Test Phase 1 V11 #2930 15/10/2020
        v_amtspot_min5 := v_amtspot_min5 + nvl(r1.amtspot, 0);
        obj_data.put('amtspot5',to_char(v_amtspot_min5,'fm999999999990.00'));
      end if;
      obj_data.put('otsize', to_char(v_count_rate));
      if v_all_qtysmot <> 0 then
         --<<User37 Final Test Phase 1 V11 #2930 15/10/2020
         --obj_data.put('all_qtysmot',hcm_util.convert_minute_to_hour(v_all_qtysmot));
         obj_data.put('all_qtysmot',hrpy57x.convert_minute_to_hour(v_all_qtysmot));
         -->>User37 Final Test Phase 1 V11 #2930 15/10/2020
      end if;
      if v_all_amtspot <> 0 then
         obj_data.put('all_amtspot',to_char(v_all_amtspot,'fm999999999990.00'));
      end if;
      obj_data.put('coderror','200');

    end loop;
    obj_rows.put(to_char(v_count),obj_data);
    if not v_flg_permission then
       param_msg_error := get_error_msg_php('HR3007',global_v_lang);
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;
    json_str_output := obj_rows.to_clob;

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;

  procedure check_codcomp is
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end check_codcomp;

  procedure get_rteotpay (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_codcomp;
    if param_msg_error is null then
      gen_rteotpay(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_rteotpay;

  procedure gen_rteotpay (json_str_output out clob) is
    obj_data           json_object_t;
    obj_row            json_object_t;
    v_codcomp          varchar2(50 char);
    v_codcompy         varchar2(50 char);
    v_max_ot_col       number := 0;
    obj_ot_col         json_object_t;
    v_count            number;
    v_other            varchar2(100 char);
    v_rateot5          varchar2(100 char);
    v_ot_col           varchar2(100 char);
    v_check_rat        varchar2(1 char);
  begin
    obj_data           := json_object_t();
    obj_row            := json_object_t();
    v_codcompy         := null;
    if p_codcomp is not null then
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp, 1);
    end if;
    obj_ot_col         := get_ot_col(v_codcompy);
    obj_data.put('otkey', v_text_key);
    obj_data.put('otlen', v_rateot_length+1);

    for i in 1..v_rateot_length loop
      v_check_rat := 'T';
      v_ot_col := hcm_util.get_string_t(obj_ot_col, to_char(i));
      if v_ot_col is not null then
        obj_data.put(v_text_key||i, hcm_util.get_string_t(obj_ot_col, to_char(i)));
      else
        obj_data.put(v_text_key||i, ' ');
      end if;
    end loop;

    v_count  := obj_ot_col.get_size;
    v_other  := get_label_name('HRAL49X2', global_v_lang, '200');

    v_rateot5 := null;
    if v_count > v_rateot_length then
      if v_count = v_rateot_length + 1 then
        v_rateot5 := hcm_util.get_string_t(obj_ot_col, to_char(v_rateot_length + 1));
      else
        v_rateot5 := v_other;
        end if;
    end if;
    
    -- add surachai | 17/02/2023  (กรณีที่ไม่ใช้ระบบ AL)
    if v_check_rat is null then
        obj_data.put('otrate1','1');
        obj_data.put('otrate2','1.5');
        obj_data.put('otrate3','2');
        obj_data.put('otrate4','3');
    end if;
    obj_data.put(v_text_key||to_char(v_rateot_length+1), nvl(v_rateot5, v_other));

    --
    obj_row.put(0, obj_data);
		json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_rteotpay;

  procedure get_currency (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_codcomp;
    if param_msg_error is null then
      gen_currency(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_currency;

  procedure gen_currency (json_str_output out clob) is
    json_obj            json_object_t    := json_object_t();
    v_codcompy          TCENTER.CODCOMPY%TYPE;
    v_codcurr           TCONTRPY.CODCURR%TYPE;
  begin
    if p_codcomp is null then
      json_obj.put('coderror', '200');
      json_obj.put('codcurr', '');
    else
      v_codcompy          := hcm_util.get_codcomp_level(p_codcomp, 1);
      begin
        select CODCURR
          into v_codcurr
          from TCONTRPY
         where codcompy = v_codcompy
           and dteeffec = (select max(dteeffec)
                             from TCONTRPY
                            where codcompy  = v_codcompy
                              and dteeffec <= trunc(sysdate));
        json_obj.put('coderror', '200');
        json_obj.put('codcurr', v_codcurr);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCONTRPY.CODCURR');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end;
    end if;
    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_currency;

  function get_ot_col (v_codcompy varchar2) return json_object_t is
    obj_ot_col         json_object_t;
    v_max_ot_col       number := 0;

    cursor max_ot_col is
      select distinct(rteotpay)
        from totratep2
       where codcompy = nvl(v_codcompy, codcompy)
    order by rteotpay;
  begin
    obj_ot_col := json_object_t();
    for row_ot in max_ot_col loop
      v_max_ot_col := v_max_ot_col + 1;
      obj_ot_col.put(to_char(v_max_ot_col), row_ot.rteotpay);
    end loop;
    return obj_ot_col;
  exception
  when others then
    return json_object_t();
  end;

  --<<User37 Final Test Phase 1 V11 #2930 14/10/2020
  function  convert_minute_to_hour(p_minute in number) return varchar2 is
    v_hour varchar2(10 char);
    v_min  varchar2(2 char);
  begin
    if p_minute is not null then
      v_hour := trunc(to_char(p_minute / 60));
      v_min := lpad(mod(p_minute , 60), 2, '0') ;
      return to_char(to_number(v_hour),'fm999,999,990') || ':' || v_min ;
   else
    return null;
   end if;
  end;
  -->>User37 Final Test Phase 1 V11 #2930 14/10/2020

end HRPY57X;

/

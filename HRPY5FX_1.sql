--------------------------------------------------------
--  DDL for Package Body HRPY5FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5FX" as

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_money_str  := to_number(hcm_util.get_string_t(obj_detail,'money_str'));
    p_money_end  := to_number(hcm_util.get_string_t(obj_detail,'money_end'));
    p_codcomp    := hcm_util.get_string_t(obj_detail,'codcomp');
    p_typpayroll := hcm_util.get_string_t(obj_detail,'typpayroll');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
  begin
    if p_money_str is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'money_str');
      return;
    end if;
    if p_money_end is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'money_end');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
    end if;
  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    obj_data                    json_object_t;
    obj_rows                    json_object_t := json_object_t();
    v_count                     number := 0;
    v_flg_exist                 boolean := false;
    v_flg_secure                boolean := false;
    v_flg_permission            boolean := false;

    cursor c1 is
      select a.codempid,a.codcomp,a.codpos,a.codjob,a.staemp,a.numlvl,
             nvl(stddec(b.amtincom1,a.codempid,global_v_chken),0) amtincom1
        from temploy1 a,temploy3 b
       where a.codcomp like p_codcomp || '%'
         and a.typpayroll = p_typpayroll
         and (a.staemp = '1' or a.staemp = '3')
         and nvl(stddec(b.amtincom1,a.codempid,global_v_chken),0) between p_money_str and p_money_end
         and a.codempid = b.codempid
    order by a.codcomp,a.codempid;
  begin
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    for r1 in c1 loop
      v_flg_secure := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        obj_data := json_object_t();
        obj_data.put('image'        ,get_emp_img(r1.codempid));
        obj_data.put('codempid'     ,r1.codempid);
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('codcomp'      ,r1.codcomp);
        obj_data.put('codpos'       ,r1.codpos);
        obj_data.put('desc_codpos'  ,get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('numlvl'       ,to_char(r1.numlvl));
        if r1.numlvl between global_v_numlvlsalst and global_v_numlvlsalen then
          obj_data.put('amt'          ,to_char(r1.amtincom1,'fm99999999999990.00'));
        end if;
        obj_data.put('coderror'     ,'200');
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      end if;
    end loop;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;


  procedure initial_value_breaklevel (json_str_input in clob) as
    obj_detail         json_object_t;
    v_breakLevelConfig json_object_t;
    v_indexHead        json_object_t;
    v_param_break      json_object_t;
    v_break            json_object_t;
    v_sum              json_object_t;
    v_breaklevel       json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;
    if hcm_util.get_string_t(obj_detail,'indexHead') is not null then
      v_indexHead   := json_object_t(hcm_util.get_string_t(obj_detail,'indexHead'));
      p_money_str   := to_number(hcm_util.get_string_t(v_indexHead,'money_str'));
      p_money_end   := to_number(hcm_util.get_string_t(v_indexHead,'money_end'));
      p_codcomp     := hcm_util.get_string_t(v_indexHead,'codcomp');
      p_typpayroll  := hcm_util.get_string_t(v_indexHead,'typpayroll');
    end if;
    if hcm_util.get_string_t(obj_detail,'breakLevelConfig') is not null then
      v_breakLevelConfig      := json_object_t(hcm_util.get_string_t(obj_detail,'breakLevelConfig'));
      v_param_break := hcm_util.get_json_t(v_breakLevelConfig,'param_break');
      v_break       := hcm_util.get_json_t(v_param_break     ,'break');
      v_sum         := hcm_util.get_json_t(v_param_break     ,'sum');
      v_breaklevel  := hcm_util.get_json_t(v_break           ,'breaklevel');
      p_level1      := hcm_util.get_string_t(v_breaklevel      ,'level1') = 'Y';
      p_level2      := hcm_util.get_string_t(v_breaklevel      ,'level2') = 'Y';
      p_level3      := hcm_util.get_string_t(v_breaklevel      ,'level3') = 'Y';
      p_level4      := hcm_util.get_string_t(v_breaklevel      ,'level4') = 'Y';
      p_level5      := hcm_util.get_string_t(v_breaklevel      ,'level5') = 'Y';
      p_level6      := hcm_util.get_string_t(v_breaklevel      ,'level6') = 'Y';
      p_level7      := hcm_util.get_string_t(v_breaklevel      ,'level7') = 'Y';
      p_level8      := hcm_util.get_string_t(v_breaklevel      ,'level8') = 'Y';
      p_level9      := hcm_util.get_string_t(v_breaklevel      ,'level9') = 'Y';
      p_level10     := hcm_util.get_string_t(v_breaklevel      ,'level10') = 'Y';
      p_leveltotal  := hcm_util.get_string_t(v_sum             ,'flgsum') = 'Y';
    end if;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure check_breaklevelcustom as
  begin
    check_index;
    if param_msg_error is not null then
      return;
    end if;
    if p_level1 is null or p_level2 is null or p_level3 is null or p_level4 is null or p_level5  is null or
       p_level6 is null or p_level7 is null or p_level8 is null or p_level9 is null or p_level10 is null or
       p_leveltotal is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'breaklevel');
      return;
    end if;
  end;
  procedure post_breaklevelcustom(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value_breaklevel(json_str_input);
    check_breaklevelcustom;
    if param_msg_error is null then
        breaklevelcustom_data(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  function check_codcomplevel_end(v_codcomp varchar2,v_level number) return boolean as
    v_comlevel tcenter.comlevel%type;
  begin
    if (v_level = 1 and p_level1) or (v_level = 2 and p_level2) or
       (v_level = 3 and p_level3) or (v_level = 4 and p_level4) or
       (v_level = 5 and p_level5) or (v_level = 6 and p_level6) or
       (v_level = 7 and p_level7) or (v_level = 8 and p_level8) or
       (v_level = 9 and p_level9) or (v_level = 10 and p_level10) then
      begin
        select comlevel
          into v_comlevel
          from tcenter
         where codcomp = v_codcomp;
        if v_comlevel >= v_level then
          return true;
        else
          return false;
        end if;
      exception when no_data_found then
        return false;
      end;
    else
      return false;
    end if;
  end;

  function check_codcomplevel(v_codcomp1 varchar2,v_codcomp2 varchar2,v_level number) return boolean as
    v_comlevel tcenter.comlevel%type;
  begin
    if (v_level = 1 and p_level1) or (v_level = 2 and p_level2) or
       (v_level = 3 and p_level3) or (v_level = 4 and p_level4) or
       (v_level = 5 and p_level5) or (v_level = 6 and p_level6) or
       (v_level = 7 and p_level7) or (v_level = 8 and p_level8) or
       (v_level = 9 and p_level9) or (v_level = 10 and p_level10) then
      if v_codcomp1 = v_codcomp2 and
          v_codcomp1 is not null then
        return false;
      else
        begin
          select comlevel
            into v_comlevel
            from tcenter
           where hcm_util.get_codcomp_level(codcomp,v_level) = v_codcomp2
             and rownum = 1
        order by codcomp;
          if v_comlevel < v_level then
            return false;
          else
            return true;
          end if;
        exception when no_data_found then
          return false;
        end;
      end if;
    else
      return false;
    end if;
  end;

  procedure breaklevelcustom_data(json_str_output out clob) as
    obj_data                    json_object_t;
    obj_rows                    json_object_t := json_object_t();
    v_count                     number := 0;
    v_count_break               number;
    v_sum_break                 number;
    v_flg_exist                 boolean := false;
    v_flg_secure                boolean := false;
    v_flg_permission            boolean := false;

    v_namcent                   varchar2(4000 char);
    v_codcomp                   tcenter.codcomp%type := null;
    v_label_sum                 varchar2(4000 char);
    v_label_people              varchar2(4000 char);
    cursor c1 is
      select a.codempid,a.codcomp,a.codpos,a.codjob,a.staemp,a.numlvl,
             nvl(stddec(b.amtincom1,a.codempid,global_v_chken),0) amtincom1
        from temploy1 a,temploy3 b
       where a.codcomp like p_codcomp || '%'
         and a.typpayroll = p_typpayroll
         and (a.staemp = '1' or a.staemp = '3')
         and nvl(stddec(b.amtincom1,a.codempid,global_v_chken),0) between p_money_str and p_money_end
         and a.codempid = b.codempid
    order by a.codcomp,a.codempid;
  begin
    if p_leveltotal then
      v_label_sum := get_label_name('HRPY5FXC1',global_v_lang,140);
      v_label_people := get_label_name('HRPY5FXC1',global_v_lang,150);
    end if;
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tsincexp');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    for r1 in c1 loop
      v_flg_secure := secur_main.secur2(r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        obj_data := json_object_t();
        if v_codcomp is not null and v_codcomp <> r1.codcomp and p_leveltotal then
          for i in 1..10 loop
            if check_codcomplevel(hcm_util.get_codcomp_level(r1.codcomp,11-i),hcm_util.get_codcomp_level(v_codcomp,11-i),11-i) then
              obj_data := json_object_t();
              begin
                select count(*),sum(nvl(stddec(b.amtincom1,a.codempid,global_v_chken),0))
                  into v_count_break,v_sum_break
                  from temploy1 a,temploy3 b
                 where a.codcomp like hcm_util.get_codcomp_level(v_codcomp,11-i) || '%'
                   and a.typpayroll = p_typpayroll
                   and (a.staemp = '1' or a.staemp = '3')
                   and nvl(stddec(b.amtincom1,a.codempid,global_v_chken),0) between p_money_str and p_money_end
                   and a.codempid = b.codempid
                   and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                    and exists (select c.coduser
                                                  from tusrcom c
                                                 where c.coduser = global_v_coduser
                                                   and a.codcomp like c.codcomp||'%');
              exception when no_data_found then
                v_count_break := 0;
                v_sum_break := 0;
              end;
--              begin
--                select decode (global_v_lang,'101',namcente,
--                                             '102',namcentt,
--                                             '103',namcent3,
--                                             '104',namcent4,
--                                             '105',namcent5)
--                  into v_namcent
--                  from tsetcomp
--                 where numseq = 11-i;
--              exception when no_data_found then
--                v_namcent := null;
--              end;
  --           codempid desc_codempid desc_codpos amt
              v_namcent   := replace(get_comp_label(v_codcomp,11-i,global_v_lang),'*',null);
              obj_data.put('codempid'     ,v_label_sum);
              obj_data.put('desc_codempid',v_namcent);
              obj_data.put('breaklvl'     ,to_char(11-i));
              obj_data.put('flgbreak'     ,'Y');
              obj_data.put('desc_codpos'  ,to_char(v_count_break,'fm99999999999990') || ' ' || v_label_people);
              obj_data.put('amt'          ,to_char(v_sum_break,'fm99999999999990.00'));
              obj_rows.put(to_char(v_count),obj_data);
              v_count := v_count + 1;
            end if;
          end loop;
        end if;
        if v_codcomp is null or v_codcomp <> r1.codcomp then
          for i in 1..10 loop
            if check_codcomplevel(hcm_util.get_codcomp_level(v_codcomp,i),hcm_util.get_codcomp_level(r1.codcomp,i),i) then
--              begin
--                select decode (global_v_lang,'101',namcente,
--                                             '102',namcentt,
--                                             '103',namcent3,
--                                             '104',namcent4,
--                                             '105',namcent5)
--                  into v_namcent
--                  from tsetcomp
--                 where numseq = i;
--              exception when no_data_found then
--                v_namcent := null;
--              end;
              v_namcent   := replace(get_comp_label(r1.codcomp,i,global_v_lang),'*',null);
              obj_data    := json_object_t();
              obj_data.put('codempid'     ,v_namcent);
              obj_data.put('desc_codempid',get_tcenter_name(hcm_util.get_codcomp_level(r1.codcomp,i),global_v_lang));
              obj_data.put('flgbreak'     ,'Y');
              obj_data.put('breaklvl'     ,to_char(i));
              obj_rows.put(to_char(v_count),obj_data);
              obj_data := json_object_t();
              v_count := v_count + 1;
            end if;
          end loop;
        end if;
        obj_data.put('image'        ,get_emp_img(r1.codempid));
        obj_data.put('codempid'     ,r1.codempid);
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('codcomp'      ,r1.codcomp);
        obj_data.put('codpos'       ,r1.codpos);
        obj_data.put('desc_codpos'  ,get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('numlvl'       ,to_char(r1.numlvl));
        if r1.numlvl between global_v_numlvlsalst and global_v_numlvlsalen then
          obj_data.put('amt'          ,to_char(r1.amtincom1,'fm99999999999990.00'));
        end if;
        obj_data.put('coderror'     ,'200');
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
        v_codcomp := r1.codcomp;
      end if;
    end loop;
    if v_count > 0 then
      if p_leveltotal then
        for i in 1..10 loop
          if check_codcomplevel_end(v_codcomp,11-i) then
            obj_data := json_object_t();
            begin
              select count(*),sum(nvl(stddec(b.amtincom1,a.codempid,global_v_chken),0))
                into v_count_break,v_sum_break
                from temploy1 a,temploy3 b
               where a.codcomp like hcm_util.get_codcomp_level(v_codcomp,11-i) || '%'
                 and a.typpayroll = p_typpayroll
                 and (a.staemp = '1' or a.staemp = '3')
                 and nvl(stddec(b.amtincom1,a.codempid,global_v_chken),0) between p_money_str and p_money_end
                 and a.codempid = b.codempid
                 and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                                  and exists (select c.coduser
                                                from tusrcom c
                                               where c.coduser = global_v_coduser
                                                 and a.codcomp like c.codcomp||'%');
            exception when no_data_found then
              v_count_break := 0;
              v_sum_break := 0;
            end;
--            begin
--              select decode (global_v_lang,'101',namcente,
--                                           '102',namcentt,
--                                           '103',namcent3,
--                                           '104',namcent4,
--                                           '105',namcent5)
--                into v_namcent
--                from tsetcomp
--               where numseq = 11-i;
--            exception when no_data_found then
--              v_namcent := null;
--            end;
--           codempid desc_codempid desc_codpos amt
            v_namcent   := replace(get_comp_label(v_codcomp,11-i,global_v_lang),'*',null);
            obj_data.put('codempid'     ,v_label_sum);
            obj_data.put('desc_codempid',v_namcent);
            obj_data.put('flgbreak'     ,'Y');
            obj_data.put('desc_codpos'  ,to_char(v_count_break,'fm99999999999990') || ' ' || v_label_people);
            obj_data.put('amt'          ,to_char(v_sum_break,'fm99999999999990.00'));
            obj_rows.put(to_char(v_count),obj_data);
            v_count := v_count + 1;
          end if;
        end loop;
      end if;
    end if;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end hrpy5fx;

/

--------------------------------------------------------
--  DDL for Package Body HRPYBAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYBAX" as
  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    p_codpfinf          := hcm_util.get_string_t(obj_detail,'codpfinf');
    p_dtestr            := to_date(hcm_util.get_string_t(obj_detail,'dtestr'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(obj_detail,'dteend'),'dd/mm/yyyy');
    if hcm_util.get_string_t(obj_detail,'breakLevelConfig') is not null then
      p_breakLevelConfig      := json_object_t(hcm_util.get_string_t(obj_detail,'breakLevelConfig'));
    end if;
    if hcm_util.get_string_t(obj_detail,'rows') is not null then
      p_rows      := json_object_t(hcm_util.get_string_t(obj_detail,'rows'));
    end if;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;
  procedure check_index as
  begin
    if p_codcomp is null and p_codpfinf is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp,codpfinf');
      return;
    end if;
    if p_dtestr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtestr');
      return;
    end if;
    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteend');
      return;
    end if;
    if p_codcomp is not null then
      p_codpfinf := null;
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_codpfinf is not null then
      begin
        select codcodec
          into p_codpfinf
          from tcodpfinf
         where codcodec = p_codpfinf;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodpfinf');
        return;
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
      obj_data             json_object_t;
      obj_rows             json_object_t := json_object_t();
      v_count              number := 0;
      v_ratecret           tpfmemrt.ratecret%type;
      v_ratecsbt           tpfmemrt.ratecsbt%type;
      v_flgdpvf            tpfmemrt.flgdpvf%type;
      v_dteeffec           date;
      v_codcompy           tcenter.codcompy%type;
      v_cond               varchar2(4000 char);
      v_stmt               varchar2(4000 char);
      v_flgfound           boolean;
      v_numseq             number;
      v_qtywork            number;
      v_workage_day        number;
      v_workage_month      number;
      v_workage_year       number;
      v_empage_day         number;
      v_empage_month       number;
      v_empage_year        number;
      v_day                number;
      v_month              number;
      v_year               number;
      v_accumulation_rate  number;
      v_contribution_rate  number;
      v_exist              varchar2(1 char) := '1';
      v_flg_secure         boolean := false;
      v_flg_exist          boolean := false;
      v_flg_permission     boolean := false;
    cursor c1 is
      select t1.codempid ,t1.dteempmt,t1.dteempdb,t2.dteeffec,
             t2.nummember,t2.flgemp,
             t1.codcomp,t1.codpos,t1.typemp,t1.codempmt,t1.typpayroll,t1.staemp,t1.numlvl,t1.jobgrade,
             t2.codpfinf
        from tpfmemb t2, temploy1 t1
       where t2.codempid = t1.codempid
         and t1.codcomp like nvl(p_codcomp || '%',t1.codcomp)
         and t2.codpfinf = nvl(p_codpfinf,codpfinf)
         and t2.dteeffec between p_dtestr and p_dteend
    order by decode(p_codcomp,null,t1.codempid,t1.codcomp),t1.codempid;

  begin

    for r1 in c1 loop
      v_flg_exist := true;
      v_flg_secure := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        get_service_year(r1.dteempmt,sysdate,'Y',v_workage_year,v_workage_month,v_workage_day);
        begin
          select ratecret   ,ratecsbt   ,dteeffec
            into v_ratecret ,v_ratecsbt ,v_dteeffec
            from tpfmemrt
           where codempid = r1.codempid
             and dteeffec = (select max(dteeffec)
                               from tpfmemrt
                              where codempid = r1.codempid
                                and dteeffec < trunc(sysdate));
            exception when no_data_found then
                v_ratecret := null;
                v_ratecsbt  := null;
            end;
            -- add rows
            v_flg_permission := true;
            obj_data := json_object_t();
            obj_data.put('image'        ,get_emp_img(r1.codempid));
            obj_data.put('codempid'     ,r1.codempid);
            obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
            obj_data.put('codcomp'      ,r1.codcomp);
            obj_data.put('desc_codcomp' ,get_tcenter_name(r1.codcomp,global_v_lang));
            obj_data.put('dtestrwrk'    ,to_char(r1.dteempmt,'dd/mm/yyyy'));
            obj_data.put('yrewrk'       ,to_char(v_workage_year));
            obj_data.put('mthwrk'       ,to_char(v_workage_month));
            obj_data.put('regisdte'     ,to_char(r1.dteeffec,'dd/mm/yyyy'));
            obj_data.put('nummember'    ,r1.nummember);
            obj_data.put('accurte'      ,to_char(v_ratecret,'fm9999999990.00'));
            obj_data.put('contrte'      ,to_char(v_ratecsbt,'fm9999999990.00'));
            obj_data.put('dteeffec'     ,to_char(v_dteeffec,'dd/mm/yyyy'));
            obj_data.put('memberstatus' ,get_tlistval_name('FLGEMP',r1.flgemp,global_v_lang));
            obj_data.put('codpfinf' ,r1.codpfinf);
            obj_data.put('desc_codpfinf' ,get_tcodec_name('TCODPFINF', r1 .codpfinf,global_v_lang));

            obj_data.put('coderror'     ,'200');
            obj_rows.put(to_char(v_count),obj_data);
            v_count := v_count + 1;
            end if;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'tpfmemb');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
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
    return;
  end gen_index;

  procedure check_breaklevelcustom as
  begin
    if p_breakLevelConfig is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'breakLevelConfig');
      return;
    end if;
    if p_rows is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'rows');
      return;
    end if;
  end;

  procedure post_breaklevelcustom(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
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

  function check_codcomplevel(v_level   number  ,v_comlevel number ,
                              v_level1  varchar2,v_level2  varchar2,
                              v_level3  varchar2,v_level4  varchar2,
                              v_level5  varchar2,v_level6  varchar2,
                              v_level7  varchar2,v_level8  varchar2,
                              v_level9  varchar2,v_level10 varchar2) return boolean as
  begin
    if (v_level = 1 and v_level1 = 'N') or
       (v_level = 2 and v_level2 = 'N') or
       (v_level = 3 and v_level3 = 'N') or
       (v_level = 4 and v_level4 = 'N') or
       (v_level = 5 and v_level5 = 'N') or
       (v_level = 6 and v_level6 = 'N') or
       (v_level = 7 and v_level7 = 'N') or
       (v_level = 8 and v_level8 = 'N') or
       (v_level = 9 and v_level9 = 'N') or
       (v_level = 10 and v_level10 = 'N') then
      return false;
    else
      if v_comlevel >= v_level and v_comlevel is not null then
        return true;
      else
        return false;
      end if;
    end if;
    return false;
  end;
  procedure clear_break (v_comlevel in number,
                         v_level1_c in out varchar2,v_level2_c in out varchar2,
                         v_level3_c in out varchar2,v_level4_c in out varchar2,
                         v_level5_c in out varchar2,v_level6_c in out varchar2,
                         v_level7_c in out varchar2,v_level8_c in out varchar2,
                         v_level9_c in out varchar2,v_level10_c in out varchar2) as
  begin
    if v_comlevel = 1 then
      v_level1_c := 0;
    end if;
    if v_comlevel = 2 then
      v_level2_c := 0;
    end if;
    if v_comlevel = 3 then
      v_level3_c := 0;
    end if;
    if v_comlevel = 4 then
      v_level4_c := 0;
    end if;
    if v_comlevel = 5 then
      v_level5_c := 0;
    end if;
    if v_comlevel = 6 then
      v_level6_c := 0;
    end if;
    if v_comlevel = 7 then
      v_level7_c := 0;
    end if;
    if v_comlevel = 8 then
      v_level8_c := 0;
    end if;
    if v_comlevel = 9 then
      v_level9_c := 0;
    end if;
    if v_comlevel = 10 then
      v_level10_c := 0;
    end if;
  end;

  procedure count_level (v_comlevel in number,
                         v_level1_c in out varchar2,v_level2_c in out varchar2,
                         v_level3_c in out varchar2,v_level4_c in out varchar2,
                         v_level5_c in out varchar2,v_level6_c in out varchar2,
                         v_level7_c in out varchar2,v_level8_c in out varchar2,
                         v_level9_c in out varchar2,v_level10_c in out varchar2) as
  begin
    if v_comlevel >= 1 then
      v_level1_c := v_level1_c + 1;
    end if;
    if v_comlevel >= 2 then
      v_level2_c := v_level2_c + 1;
    end if;
    if v_comlevel >= 3 then
      v_level3_c := v_level3_c + 1;
    end if;
    if v_comlevel >= 4 then
      v_level4_c := v_level4_c + 1;
    end if;
    if v_comlevel >= 5 then
      v_level5_c := v_level5_c + 1;
    end if;
    if v_comlevel >= 6 then
      v_level6_c := v_level6_c + 1;
    end if;
    if v_comlevel >= 7 then
      v_level7_c := v_level7_c + 1;
    end if;
    if v_comlevel >= 8 then
      v_level8_c := v_level8_c + 1;
    end if;
    if v_comlevel >= 9 then
      v_level9_c := v_level9_c + 1;
    end if;
    if v_comlevel >= 10 then
      v_level10_c := v_level10_c + 1;
    end if;
  end;

  function check_break (v_level   number  ,
                        v_level1  varchar2,v_level2  varchar2,
                        v_level3  varchar2,v_level4  varchar2,
                        v_level5  varchar2,v_level6  varchar2,
                        v_level7  varchar2,v_level8  varchar2,
                        v_level9  varchar2,v_level10 varchar2) return boolean as
  begin
    if (v_level = 1 and v_level1 = 'Y') or
       (v_level = 2 and v_level2 = 'Y') or
       (v_level = 3 and v_level3 = 'Y') or
       (v_level = 4 and v_level4 = 'Y') or
       (v_level = 5 and v_level5 = 'Y') or
       (v_level = 6 and v_level6 = 'Y') or
       (v_level = 7 and v_level7 = 'Y') or
       (v_level = 8 and v_level8 = 'Y') or
       (v_level = 9 and v_level9 = 'Y') or
       (v_level = 10 and v_level10 = 'Y') then
      return true;
    else
      return false;
    end if;
  end;

  function get_count (v_level in number,
                      v_level1_c in number,v_level2_c in number,
                      v_level3_c in number,v_level4_c in number,
                      v_level5_c in number,v_level6_c in number,
                      v_level7_c in number,v_level8_c in number,
                      v_level9_c in number,v_level10_c in number) return number as
  begin
    if v_level = 1 then
      return v_level1_c;
    elsif v_level = 2 then
      return v_level2_c;
    elsif v_level = 3 then
      return v_level3_c;
    elsif v_level = 4 then
      return v_level4_c;
    elsif v_level = 5 then
      return v_level5_c;
    elsif v_level = 6 then
      return v_level6_c;
    elsif v_level = 7 then
      return v_level7_c;
    elsif v_level = 8 then
      return v_level8_c;
    elsif v_level = 9 then
      return v_level9_c;
    elsif v_level = 10 then
      return v_level10_c;
    else
      return null;
    end if;
  end;

  procedure breaklevelcustom_data(json_str_output out clob) as
    v_param_break json_object_t;
    v_break       json_object_t;
    v_sum         json_object_t;
    v_breaklevel  json_object_t;
    v_level1      varchar2(10 char);
    v_level2      varchar2(10 char);
    v_level3      varchar2(10 char);
    v_level4      varchar2(10 char);
    v_level5      varchar2(10 char);
    v_level6      varchar2(10 char);
    v_level7      varchar2(10 char);
    v_level8      varchar2(10 char);
    v_level9      varchar2(10 char);
    v_level10     varchar2(10 char);

    v_level1_c    number := 0;
    v_level2_c    number := 0;
    v_level3_c    number := 0;
    v_level4_c    number := 0;
    v_level5_c    number := 0;
    v_level6_c    number := 0;
    v_level7_c    number := 0;
    v_level8_c    number := 0;
    v_level9_c    number := 0;
    v_level10_c   number := 0;

    v_flgsum      varchar2(10 char);
    v_rows        json_object_t;

    v_token       json_object_t;
    v_token2      json_object_t;
    v_count       number := 0;
    obj_data      json_object_t;
    obj_rows      json_object_t := json_object_t();

    v_namcent     tcompnyc.namcente%type;
    v_codcomp     tcenter.codcomp%type;
    v_codcomp2    tcenter.codcomp%type;
    v_codcomp_token tcenter.codcomp%type;

    v_comlevel    number;

    v_flg_codcomp varchar2(4000 char);

    v_is_last     boolean;

    v_label       varchar2(4000 char) := '';
    v_label2      varchar2(4000 char) := '';
    v_labelCodapp varchar2(1000 char);
    v_labelIndex  varchar2(1000 char);
  begin
    v_param_break := hcm_util.get_json_t(p_breakLevelConfig,'param_break');
    v_break       := hcm_util.get_json_t(v_param_break     ,'break');
    v_sum         := hcm_util.get_json_t(v_param_break     ,'sum');
    v_breaklevel  := hcm_util.get_json_t(v_break           ,'breaklevel');
    v_level1      := hcm_util.get_string_t(v_breaklevel      ,'level1');
    v_level2      := hcm_util.get_string_t(v_breaklevel      ,'level2');
    v_level3      := hcm_util.get_string_t(v_breaklevel      ,'level3');
    v_level4      := hcm_util.get_string_t(v_breaklevel      ,'level4');
    v_level5      := hcm_util.get_string_t(v_breaklevel      ,'level5');
    v_level6      := hcm_util.get_string_t(v_breaklevel      ,'level6');
    v_level7      := hcm_util.get_string_t(v_breaklevel      ,'level7');
    v_level8      := hcm_util.get_string_t(v_breaklevel      ,'level8');
    v_level9      := hcm_util.get_string_t(v_breaklevel      ,'level9');
    v_level10     := hcm_util.get_string_t(v_breaklevel      ,'level10');
    v_flgsum      := hcm_util.get_string_t(v_sum             ,'flgsum');
    if v_flgsum = 'Y' then
      v_labelCodapp := hcm_util.get_string_t(v_sum,'labelCodapp');
      v_labelIndex := hcm_util.get_string_t(v_sum,'labelIndex');
      begin
        select decode(global_v_lang,'101',DESCLABELE,
                                    '102',DESCLABELT,
                                    '103',DESCLABEL3,
                                    '104',DESCLABEL4,
                                    '105',DESCLABEL5)
          into v_label
          from tapplscr
         where codapp = v_labelCodapp
           and numseq = v_labelIndex;
      exception when no_data_found then
        v_label := null;
      end;
      v_labelCodapp := hcm_util.get_string_t(v_sum,'labelCodapp');
      begin
        select decode(global_v_lang,'101',DESCLABELE,
                                    '102',DESCLABELT,
                                    '103',DESCLABEL3,
                                    '104',DESCLABEL4,
                                    '105',DESCLABEL5)
          into v_label2
          from tapplscr
         where codapp = v_labelCodapp
           and numseq = 230;
      exception when no_data_found then
        v_label2 := null;
      end;
    end if;
    v_rows        := hcm_util.get_json_t(p_rows,'rows');
    for i in 0..v_rows.get_size-1 loop
      v_token     := hcm_util.get_json_t(v_rows,to_char(i));
      v_flg_codcomp   := hcm_util.get_string_t(v_token,'flg_codcomp');
      if v_flg_codcomp is null or v_flg_codcomp <> 'Y' then -- detect codcomp break
        v_codcomp   := hcm_util.get_string_t(v_token,'codcomp');
        begin
          select comlevel
            into v_comlevel
            from tcenter
           where codcomp = v_codcomp;
        exception when no_data_found then
          v_comlevel := null;
        end;
        for j in 1..10 loop
          if check_codcomplevel(j,v_comlevel,v_level1,v_level2,v_level3,v_level4,v_level5,
                                            v_level6,v_level7,v_level8,v_level9,v_level10) and
             (v_codcomp_token is null or hcm_util.get_codcomp_level(v_codcomp,j) <> hcm_util.get_codcomp_level(v_codcomp_token,j)) then
            obj_data := json_object_t();
--            begin
--              select decode (global_v_lang,'101',namcente,
--                                           '102',namcentt,
--                                           '103',namcent3,
--                                           '104',namcent4,
--                                           '105',namcent5)
--                into v_namcent
--                from tsetcomp
--               where numseq = j;
--            exception when no_data_found then
--              v_namcent := null;
--            end;
            v_namcent   := replace(get_comp_label(v_codcomp,j,global_v_lang),'*',null);
            obj_data.put('flg_codcomp'  ,'Y'); -- detect codcomp break
            obj_data.put('breaklvl'     ,to_char(j));
            obj_data.put('flgbreak'     ,'Y');
            obj_data.put('codempid'     ,v_namcent);
            obj_data.put('desc_codempid',get_tcenter_name(hcm_util.get_codcomp_level(v_codcomp,j),global_v_lang));
            obj_rows.put(to_char(v_count),obj_data);
            v_count := v_count + 1;
          end if;
        end loop;
        obj_rows.put(to_char(v_count),v_token);
        v_codcomp_token := v_codcomp;
        v_count := v_count + 1;

        if v_flgsum = 'Y' then -- total break
          v_is_last := true;
          for k in i+1..v_rows.get_size-1 loop -- find next codcomp that can break
            v_token2 := hcm_util.get_json_t(v_rows,to_char(k));
            v_flg_codcomp   := hcm_util.get_string_t(v_token2,'flg_codcomp');
            if v_flg_codcomp is null or v_flg_codcomp <> 'Y' then -- detect codcomp break
              v_codcomp2   := hcm_util.get_string_t(v_token2,'codcomp');
              count_level (v_comlevel,
                           v_level1_c,v_level2_c,
                           v_level3_c,v_level4_c,
                           v_level5_c,v_level6_c,
                           v_level7_c,v_level8_c,
                           v_level9_c,v_level10_c);
              for breaklevel in 0..9 loop
                if hcm_util.get_codcomp_level(v_codcomp,10 - breaklevel) <> hcm_util.get_codcomp_level(v_codcomp2,10 - breaklevel) and
                   check_break (10 - breaklevel,
                                v_level1,v_level2 ,
                                v_level3,v_level4 ,
                                v_level5,v_level6 ,
                                v_level7,v_level8 ,
                                v_level9,v_level10) then
                  obj_data := json_object_t();
--                  begin
--                    select decode (global_v_lang,'101',namcente,
--                                                 '102',namcentt,
--                                                 '103',namcent3,
--                                                 '104',namcent4,
--                                                 '105',namcent5)
--                      into v_namcent
--                      from tsetcomp
--                     where numseq = 10 - breaklevel;
--                  exception when no_data_found then
--                    v_namcent := null;
--                  end;
                  v_namcent   := replace(get_comp_label(v_codcomp,10 - breaklevel,global_v_lang),'*',null);
                  obj_data.put('flg_codcomp'  ,'Y'); -- detect codcomp break
                  obj_data.put('codempid'     ,v_label);
                  obj_data.put('flgbreak'     ,'Y');
                  obj_data.put('desc_codempid', v_namcent || ' ' ||
                                                to_char(get_count (10 - breaklevel,
                                                        v_level1_c,v_level2_c,
                                                        v_level3_c,v_level4_c,
                                                        v_level5_c,v_level6_c,
                                                        v_level7_c,v_level8_c,
                                                        v_level9_c,v_level10_c))
                                                || ' ' || v_label2 );
                  obj_rows.put(to_char(v_count),obj_data);
                  v_count := v_count + 1;
                  clear_break(10 - breaklevel,
                              v_level1_c,v_level2_c,
                              v_level3_c,v_level4_c,
                              v_level5_c,v_level6_c,
                              v_level7_c,v_level8_c,
                              v_level9_c,v_level10_c);
                end if;
              end loop;
              v_is_last := false;
              exit;
            end if;
          end loop;
          if v_is_last then -- already last rows (break)
            count_level (v_comlevel,
                         v_level1_c,v_level2_c,
                         v_level3_c,v_level4_c,
                         v_level5_c,v_level6_c,
                         v_level7_c,v_level8_c,
                         v_level9_c,v_level10_c);
            for breaklevel in 0..9 loop
              if check_break (10 - breaklevel,
                              v_level1,v_level2 ,
                              v_level3,v_level4 ,
                              v_level5,v_level6 ,
                              v_level7,v_level8 ,
                              v_level9,v_level10) and
                 v_comlevel >= 10 - breaklevel then
                obj_data := json_object_t();
--                begin
--                  select decode (global_v_lang,'101',namcente,
--                                               '102',namcentt,
--                                               '103',namcent3,
--                                               '104',namcent4,
--                                               '105',namcent5)
--                    into v_namcent
--                    from tsetcomp
--                   where numseq = 10 - breaklevel;
--                exception when no_data_found then
--                  v_namcent := null;
--                end;
                v_namcent   := replace(get_comp_label(v_codcomp,10 - breaklevel,global_v_lang),'*',null);
                obj_data.put('flg_codcomp'  ,'Y'); -- detect codcomp break
                obj_data.put('flgbreak'     ,'Y');
                obj_data.put('codempid'     ,v_label);
                obj_data.put('desc_codempid', v_namcent || ' ' ||
                                              to_char(get_count (10 - breaklevel,
                                                      v_level1_c,v_level2_c,
                                                      v_level3_c,v_level4_c,
                                                      v_level5_c,v_level6_c,
                                                      v_level7_c,v_level8_c,
                                                      v_level9_c,v_level10_c))
                                              || ' ' || v_label2 );
                obj_rows.put(to_char(v_count),obj_data);
                v_count := v_count + 1;
              end if;
            end loop;
          end if;
        end if;
      end if;
    end loop;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end hrpybax;

/

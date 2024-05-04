--------------------------------------------------------
--  DDL for Package Body HRPY5NX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5NX" as

  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_year              := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    p_codbrsoc          := hcm_util.get_string_t(json_obj,'p_codbrsoc');
    p_numbrlvl          := hcm_util.get_string_t(json_obj,'p_numbrlvl');

    json_param_break    := hcm_util.get_json_t(json_obj, 'param_break');
    json_param_json     := hcm_util.get_json_t(json_obj, 'param_json');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
    v_codbrsoc   tcodsoc.codbrsoc%type;
  begin
    begin
      select codbrsoc
        into v_codbrsoc
        from tcodsoc
       where codbrsoc = p_codbrsoc
         and rownum  <= 1;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODSOC');
      return;
    end;

    if p_numbrlvl is not null then
      begin
        select codbrsoc
          into v_codbrsoc
          from tcodsoc
         where codbrsoc = p_codbrsoc
           and numbrlvl = p_numbrlvl
           and rownum <= 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODSOC');
        return;
      end;
    end if;
--    --
--    if p_year is null then
--      p_stdate  := to_date(get_period_date(1,to_number(to_char(sysdate,'YYYY')),'S'),'dd/mm/yyyy');
--      p_endate  := to_date(get_period_date(to_number(to_char(sysdate,'MM')),to_number(to_char(sysdate,'YYYY')),'E'),'dd/mm/yyyy');
--      p_endate2 := p_endate;
--    else
--      p_stdate  := to_date(get_period_date(1 ,p_year,'S'),'dd/mm/yyyy');
--      p_endate  := to_date(get_period_date(12,p_year,'E'),'dd/mm/yyyy');
--      p_endate2 := to_date(get_period_date(12,p_year,'E'),'dd/mm/yyyy');
--    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    isInsertReport := true;
    if param_msg_error is null then
      p_codapp := 'HRPY5NX';
      clear_ttemprpt;
      gen_index(json_str_output);
      commit;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) is
    obj_data          json_object_t;
    obj_row           json_object_t;
    obj_data_child    json_object_t;
    obj_row_child     json_object_t;
    v_numbrlvl        tcodsoc.numbrlvl%type;
    v_codbrlc         tcodsoc.codbrlc%type;
    v_codcompy        temploy1.codcomp%type;
    v_numacsoc        tcompny.numacsoc%type;
    v_unitcal         tcontpmd.unitcal1%type;
    v_flgpass         boolean;
    v_data            varchar2(1 char) := 'N';
    v_fecth           varchar2(1 char) := 'N';
    v_secur           varchar2(1 char) := 'N';
    v_cnt             number  := 0;
    v_rcnt            number  := 0;
    v_rcnt2           number  := 0;
    v_codbrlc_desc    varchar2(2000 char);
    v_codcompy_desc   varchar2(2000 char);
    v_sumhur          number;
    v_sumday          number;
    v_summth          number;
    v_address	      varchar2(2000 char);
    v_flg_3007        boolean := false;

  cursor c_header is
    select a.codbrlc, a.numbrlvl, a.codcompy, b.numacsoc
      from tcodsoc a,tcompny b
     where a.codbrsoc = p_codbrsoc
       and a.numbrlvl = nvl(p_numbrlvl,a.numbrlvl)
       and a.codcompy = b.codcompy
    order by a.numbrlvl,a.codbrlc;

  cursor c_details (p_codbrlc varchar2, p_numbrlvl varchar2, p_codcompy varchar2) is
    select a.codempid,b.numoffid,c.numsaid,b.codnatnl,
           a.dteempdb,a.dteempmt,
           decode(global_v_lang,'101',b.adrrege,'102',b.adrregt,'103',b.adrreg3,'104',b.adrreg4,'105',b.adrreg5,b.adrrege) address,
           stddec(c.amtincom1,c.codempid,global_v_chken) amtincom1,
           stddec(c.amtincom2,c.codempid,global_v_chken) amtincom2,
           stddec(c.amtincom3,c.codempid,global_v_chken) amtincom3,
           stddec(c.amtincom4,c.codempid,global_v_chken) amtincom4,
           stddec(c.amtincom5,c.codempid,global_v_chken) amtincom5,
           stddec(c.amtincom6,c.codempid,global_v_chken) amtincom6,
           stddec(c.amtincom7,c.codempid,global_v_chken) amtincom7,
           stddec(c.amtincom8,c.codempid,global_v_chken) amtincom8,
           stddec(c.amtincom9,c.codempid,global_v_chken) amtincom9,
           stddec(c.amtincom10,c.codempid,global_v_chken) amtincom10,
           a.dteeffex, a.numlvl,a.codcomp,a.codempmt  ,b.codsubdistr,b.coddistr,b.codprovr
      from temploy1 a,temploy2 b,temploy3 c,tcodsoc d, ttaxmas e
     where d.numbrlvl = nvl(p_numbrlvl,d.numbrlvl)
       and d.codbrsoc = p_codbrsoc
       and d.codbrlc  = p_codbrlc
       and a.codcomp like p_codcompy||'%'
       and a.codbrlc  = d.codbrlc
       and hcm_util.get_codcomp_level(a.codcomp,1) = d.codcompy
       and a.codempid = b.codempid
       and a.codempid = c.codempid
       and a.codempid = e.codempid
       and e.dteyrepay = p_year - global_v_zyear
     order by a.codempid;
  begin

    obj_row   := json_object_t();
    open c_header;
    loop
      fetch c_header into v_codbrlc, v_numbrlvl, v_codcompy, v_numacsoc;
      exit when c_header%notfound;
      --
      v_flgpass := secur_main.secur7(v_codcompy,global_v_coduser);

      begin
        select count(*)
          into v_cnt
          from temploy1 a, tcodsoc b, ttaxmas c
         where b.numbrlvl  = v_numbrlvl
           and b.codbrsoc  = p_codbrsoc
           and b.codbrlc   = v_codbrlc
           and a.codcomp like v_codcompy||'%'
           and a.codbrlc = b.codbrlc
           and a.codempid = c.codempid
           and c.dteyrepay = p_year - global_v_zyear;
       exception when others then
           v_cnt := 0;
      end;
      if v_flgpass and v_cnt > 0 then
        v_codbrlc_desc  := get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang);
        v_codcompy_desc := get_tcompny_name(v_codcompy,global_v_lang);
      end if;
      --
      obj_row_child   := json_object_t();
      v_fecth         := 'N';
      v_rcnt          := 0;
      for r1 in c_details(v_codbrlc, v_numbrlvl, v_codcompy) loop
        v_data := 'Y';
        v_flgpass := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        if v_flgpass then
          v_secur   := 'Y';
          v_fecth   := 'Y';
          --
          v_address := null;
          v_address := r1.address;
          if r1.codsubdistr is not null then
            v_address := v_address||' '||get_label_name('HRPY5NXC1',global_v_lang,'210')||' '||
                         get_tsubdist_name(r1.codsubdistr,global_v_lang);
          end if;
          if r1.coddistr is not null then
            v_address := v_address||' '||get_label_name('HRPY5NXC1',global_v_lang,'220')||' '||
                         get_tcoddist_name(r1.coddistr,global_v_lang);
          end if;
          if r1.codprovr is not null then
            v_address := v_address||' '||get_label_name('HRPY5NXC1',global_v_lang,'230')||' '||
                         get_tcodec_name('tcodprov',r1.codprovr,global_v_lang);
          end if;
          --
          get_wage_income (hcm_util.get_codcomp_level(r1.codcomp,1),r1.codempmt,
                          to_number(r1.amtincom1),to_number(r1.amtincom2),
                          to_number(r1.amtincom3),to_number(r1.amtincom4),
                          to_number(r1.amtincom5),to_number(r1.amtincom6),
                          to_number(r1.amtincom7),to_number(r1.amtincom8),
                          to_number(r1.amtincom9),to_number(r1.amtincom10),
                          v_sumhur,v_sumday,v_summth);
          --
          begin
            select max(unitcal1)
              into v_unitcal
              from tcontpmd
             where codempmt = r1.codempmt
               and dteeffec <= sysdate;
          exception when no_data_found then
             v_unitcal := null;
          end;
          --
          obj_data_child    := json_object_t();
          v_rcnt            := v_rcnt + 1;
          --
          obj_data_child.put('coderror', '200');
          obj_data_child.put('image', get_emp_img(r1.codempid));
          obj_data_child.put('numseq', v_rcnt);
          obj_data_child.put('codcomp', r1.codcomp);
          obj_data_child.put('codempid', r1.codempid);
          obj_data_child.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
          obj_data_child.put('numoffid', r1.numoffid);
          obj_data_child.put('numsaid', r1.numsaid);
          obj_data_child.put('desc_codnatnl', get_tcodec_name('TCODNATN',r1.codnatnl,global_v_lang));
          obj_data_child.put('dteempdb', to_char(r1.dteempdb,'dd/mm/yyyy'));
          obj_data_child.put('address', v_address);
          obj_data_child.put('dteempmt', to_char(r1.dteempmt,'dd/mm/yyyy'));
          --
          if v_zupdsal = 'Y' then
            if v_unitcal = 'D' then
              obj_data_child.put('sumday', v_sumday);
            elsif v_unitcal = 'M' then
              obj_data_child.put('summth', v_summth);
            elsif v_unitcal <> 'D' and v_unitcal <> 'M' then
              obj_data_child.put('sumhur', v_sumhur);
            end if;
          end if;
          --
          obj_data_child.put('dteeffex', to_char(r1.dteeffex,'dd/mm/yyyy'));
          --
          obj_row_child.put(to_char(v_rcnt - 1), obj_data_child);
--        else
--          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
--          exit;
        end if;
      end loop;
--      if v_fecth = 'N' then
--          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
--          exit;
--      end if;
      --
      obj_data          := json_object_t();
      v_rcnt2           := v_rcnt2 + 1;
      --
      obj_data.put('coderror', '200');
      obj_data.put('codbrlc', v_codbrlc);
      obj_data.put('codbrlc_desc', v_codbrlc_desc);
      obj_data.put('numbrlvl', v_numbrlvl);
      obj_data.put('codcompy', v_codcompy);
      obj_data.put('codcompy_desc', v_codcompy_desc);
      obj_data.put('numacsoc', v_numacsoc);
      obj_data.put('codbrsoc', p_codbrsoc);
      obj_data.put('children', obj_row_child);
      if isInsertReport then
        if json_param_break.get_size > 0 then
          begin
            json_break_params := json_object_t();
            json_param_json.put('data', obj_row_child);
            json_break_params.put('codapp', 'HRPY5NX');
            json_break_params.put('p_coduser', global_v_coduser);
            json_break_params.put('p_codempid', global_v_codempid);
            json_break_params.put('p_lang', global_v_lang);
            json_break_params.put('json_input_str1', json_param_json);
            json_break_params.put('json_input_str2', json_param_break);
            json_str_output   := json_break_params.to_clob;
            json_break_output := json_object_t(hcm_breaklevel.get_breaklevel(json_str_output));
            obj_row_child     := hcm_util.get_json_t(json_break_output, 'param_json');
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            exit;
          end;
          obj_data.put('children', obj_row_child);
        end if;
      end if;

      if v_fecth = 'Y' then
        --report--
        if isInsertReport then
          insert_ttemprpt_data(obj_data);
        end if;
        obj_row.put(to_char(v_rcnt2 - 1), obj_data);
      end if;
    end loop;
 commit;
    close c_header;
    --
    if v_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
   	elsif v_secur = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    end if;
    --
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else

      json_str_output := obj_row.to_clob;
    end if;
  end gen_index;

  function getLevelCodcomp (v_codcomp varchar2) return number as
    v_level number;
  begin
    select comlevel
      into v_level
      from tcenter
     where codcomp = v_codcomp;
    return v_level;
  exception when no_data_found then
    return 0;
  end;

  function getTrueLevel (v_level varchar2) return number as
    v_truelevel number := 0;
  begin
    if p_breaklevel10 and v_level > 9 then
      return 10;
    end if;
    if p_breaklevel9 and v_level > 8 then
      return 9;
    end if;
    if p_breaklevel8 and v_level > 7 then
      return 8;
    end if;
    if p_breaklevel7 and v_level > 6 then
      return 7;
    end if;
    if p_breaklevel6 and v_level > 5 then
      return 6;
    end if;
    if p_breaklevel5 and v_level > 4 then
      return 5;
    end if;
    if p_breaklevel4 and v_level > 3 then
      return 4;
    end if;
    if p_breaklevel3 and v_level > 2 then
      return 3;
    end if;
    if p_breaklevel2 and v_level > 1 then
      return 2;
    end if;
    if p_breaklevel1 and v_level > 0 then
      return 1;
    end if;
    return v_truelevel;
  end;

  function isBreakLevel(v_codcomp1 varchar2,v_codcomp2 varchar2) return boolean as
    v_level1 number;
    v_level2 number;
  begin
    v_level1 := getTrueLevel(getLevelCodcomp(v_codcomp1));
    v_level2 := getTrueLevel(getLevelCodcomp(v_codcomp2));
    if hcm_util.get_codcomp_level(v_codcomp1,v_level1) <> hcm_util.get_codcomp_level(v_codcomp2,v_level2) or v_level1 > v_level2 then
      return true;
    else
      return false;
    end if;
  end;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

/*
  procedure initial_break (json_str_input in clob) as
    obj_initial        json_object_t := json_object_t(json_str_input);
    obj_breaklevel     json_object_t;
    v_flgsum           varchar2(1 char);
    v_level1           varchar2(1 char);
    v_level2           varchar2(1 char);
    v_level3           varchar2(1 char);
    v_level4           varchar2(1 char);
    v_level5           varchar2(1 char);
    v_level6           varchar2(1 char);
    v_level7           varchar2(1 char);
    v_level8           varchar2(1 char);
    v_level9           varchar2(1 char);
    v_level10          varchar2(1 char);
  begin
    global_chken        := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(obj_initial,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(obj_initial,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(obj_initial,'p_lang');

    obj_breaklevel := json_object_t(hcm_util.get_string_t(obj_initial,'breaklevel'));
    if obj_breaklevel is not null then
      v_level1   := hcm_util.get_string_t(obj_breaklevel,'level1');
      v_level2   := hcm_util.get_string_t(obj_breaklevel,'level2');
      v_level3   := hcm_util.get_string_t(obj_breaklevel,'level3');
      v_level4   := hcm_util.get_string_t(obj_breaklevel,'level4');
      v_level5   := hcm_util.get_string_t(obj_breaklevel,'level5');
      v_level6   := hcm_util.get_string_t(obj_breaklevel,'level6');
      v_level7   := hcm_util.get_string_t(obj_breaklevel,'level7');
      v_level8   := hcm_util.get_string_t(obj_breaklevel,'level8');
      v_level9   := hcm_util.get_string_t(obj_breaklevel,'level9');
      v_level10  := hcm_util.get_string_t(obj_breaklevel,'level10');
      if v_level1 is not null and v_level1 = 'Y' then
        p_breaklevel1 := true;
      end if;
      if v_level2 is not null and v_level2 = 'Y' then
        p_breaklevel2 := true;
      end if;
      if v_level3 is not null and v_level3 = 'Y' then
        p_breaklevel3 := true;
      end if;
      if v_level4 is not null and v_level4 = 'Y' then
        p_breaklevel4 := true;
      end if;
      if v_level5 is not null and v_level5 = 'Y' then
        p_breaklevel5 := true;
      end if;
      if v_level6 is not null and v_level6 = 'Y' then
        p_breaklevel6 := true;
      end if;
      if v_level7 is not null and v_level7 = 'Y' then
        p_breaklevel7 := true;
      end if;
      if v_level8 is not null and v_level8 = 'Y' then
        p_breaklevel8 := true;
      end if;
      if v_level9 is not null and v_level9 = 'Y' then
        p_breaklevel9 := true;
      end if;
      if v_level10 is not null and v_level10 = 'Y' then
        p_breaklevel10 := true;
      end if;
    end if;
    v_flgsum       := hcm_util.get_string_t(obj_initial,'flgsum');
    if v_flgsum is not null and v_flgsum = 'Y' then
      p_breaklevelAll := true;
    end if;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end;
*/

  function isAddSummary(v_codcomp1 varchar2,v_codcomp2 varchar2) return boolean as
    v_level1 number;
    v_level2 number;
  begin
    v_level1 := getTrueLevel(getLevelCodcomp(v_codcomp1));
    v_level2 := getTrueLevel(getLevelCodcomp(v_codcomp2));
    if hcm_util.get_codcomp_level(v_codcomp1,v_level1) <> hcm_util.get_codcomp_level(v_codcomp2,v_level2) or v_level1 > v_level2
      and v_level2 > 0 then
      return true;
    else
      return false;
    end if;
  end;


  procedure findDiff (v_codcomp1 in varchar2,v_codcomp2 in varchar2,v_start out number,v_end out number) as
    v_level number;
    v_st    number := 0;
    v_count number := 1;
  begin
    v_end   := getTrueLevel(getLevelCodcomp(v_codcomp1));
    v_level := getTrueLevel(getLevelCodcomp(v_codcomp2));
    if v_codcomp2 is not null then
      v_start := v_end;
      while v_level > 0 loop
        if hcm_util.get_codcomp_level(v_codcomp1,v_end) like hcm_util.get_codcomp_level(v_codcomp2,v_level) || '%' then
          return;
        end if;
        v_start := v_level;
        v_level := getTrueLevel(v_level - 1);
      end loop;
    else
      while v_st = 0 and v_count <= 10 loop
        v_st := getTrueLevel(v_count);
        v_count := v_count + 1;
      end loop;
      v_start := v_st;
    end if;
  end;


  procedure resetSummary(v_level number) as
  begin
    if v_level = 1 then null;
--      p_amtpay1 := 0;
--      p_qtymin1 := 0;
    elsif v_level = 2 then null;
--      p_amtpay2 := 0;
--      p_qtymin2 := 0;
    elsif v_level = 3 then null;
--      p_amtpay3 := 0;
--      p_qtymin3 := 0;
    elsif v_level = 4 then null;
--      p_amtpay4 := 0;
--      p_qtymin4 := 0;
    elsif v_level = 5 then null;
--      p_amtpay5 := 0;
--      p_qtymin5 := 0;
    elsif v_level = 6 then null;
--      p_amtpay6 := 0;
--      p_qtymin6 := 0;
    elsif v_level = 7 then null;
--      p_amtpay7 := 0;
--      p_qtymin7 := 0;
    elsif v_level = 8 then null;
--      p_amtpay8 := 0;
--      p_qtymin8 := 0;
    elsif v_level = 9 then null;
--      p_amtpay9 := 0;
--      p_qtymin9 := 0;
    elsif v_level = 10 then null;
--      p_amtpay10 := 0;
--      p_qtymin10 := 0;
    end if;
  end;

  procedure get_breaklevel (json_str_input in clob,json_str_output out clob) as
    obj_rows_old    json_object_t;
    obj_data_old    json_object_t;

    obj_rows        json_object_t := json_object_t();
    obj_data        json_object_t;
    v_count         number := 0;

    obj_token       json_object_t;

    v_codcomp1      tcenter.codcomp%type;
    v_codcomp2      tcenter.codcomp%type;
    v_codempid1     temploy1.codempid%type;
    v_codempid2     temploy1.codempid%type;
    v_start         number;
    v_end           number;

    v_level         number;
    v_namcent       tcompnyc.namcente%type;
    v_label         varchar2(4000 char);
    v_label2        varchar2(4000 char);

    v_flgbreak      varchar2(1 char);
  begin
    obj_rows_old := hcm_util.get_json_t(json_object_t(json_str_input),'rows');
    --initial_break(json_str_input);
    begin
      select decode (global_v_lang,'101',desclabele,
                                   '102',desclabelt,
                                   '103',desclabel3,
                                   '104',desclabel4,
                                   '105',desclabel5)
        into v_label
        from tapplscr
       where codapp = 'HRAL73X'
         and numseq = '40';
      v_label := v_label || ' ';
    exception when no_data_found then
      null;
    end;
    begin
      select decode (global_v_lang,'101',DESCLABELE,
                                   '102',DESCLABELT,
                                   '103',DESCLABEL3,
                                   '104',DESCLABEL4,
                                   '105',DESCLABEL5)
        into v_label2
        from tapplscr
       where codapp = 'HRAL73X'
         and numseq = '50';
    exception when no_data_found then
      v_namcent := null;
    end;
    for j in 0..obj_rows_old.get_size-1 loop
      obj_data_old  := hcm_util.get_json_t(obj_rows_old,to_char(j));
      v_flgbreak    := hcm_util.get_string_t(obj_data_old,'flgbreak');
      if v_flgbreak <> 'Y' or v_flgbreak is null then
        v_codcomp1 := hcm_util.get_string_t(obj_data_old,'codcomp'); -- current
        v_codcomp2 := hcm_util.get_string_t(obj_token   ,'codcomp'); -- before
        if p_breaklevelAll then
          v_codempid1 := hcm_util.get_string_t(obj_data_old,'codempid'); -- current
          v_codempid2 := hcm_util.get_string_t(obj_token   ,'codempid'); -- before
          if obj_token is not null and v_codempid1 <> v_codempid2 then
            obj_data := json_object_t();
            obj_data.put('flgbreak','Y');
            obj_data.put('coderror','200');
            obj_data.put('desc_codempid'     ,v_label || v_label2);
           -- obj_data.put('qtyhrs'       ,hcm_util.convert_minute_to_hour(p_qtyminCodempid));
          --  obj_data.put('amount'       ,to_char(nvl(p_amtpayCodempid,0),'fm999999999990.00'));
            obj_rows.put(to_char(v_count),obj_data);
            v_count := v_count + 1;
--            p_qtyminCodempid := 0;
--            p_amtpayCodempid := 0;
          end if;
          if obj_token is not null and isAddSummary(v_codcomp1,v_codcomp2) then -- if not start and add sum
            findDiff (v_codcomp1,v_codcomp2,v_start,v_end);
            for i in v_start..v_end loop
              v_level := v_end - i + v_start;
              if v_level = getTrueLevel(v_level) and v_level > 0 then
                obj_data := json_object_t();
                obj_data.put('flgbreak','Y');
                obj_data.put('coderror','200');
                v_namcent   := replace(get_comp_label(v_codcomp1,v_level,global_v_lang),'*',null);
                obj_data.put('desc_codempid'     ,v_label || v_namcent);
              --  obj_data.put('qtyhrs'       ,hcm_util.convert_minute_to_hour(getQtyminSum(v_level)));
            --    obj_data.put('amount'       ,to_char(nvl(getAmtpaySum(v_level),0),'fm999999999990.00'));
                obj_rows.put(to_char(v_count),obj_data);
                v_count := v_count + 1;
                resetSummary(v_level);
              end if;
            end loop;
          end if;
        end if;
        if obj_token is null or isBreakLevel(v_codcomp1,v_codcomp2) then -- if start or notsame breaklevel
          findDiff (v_codcomp1,v_codcomp2,v_start,v_end);
          for i in v_start..v_end loop
            if i = getTrueLevel(i) and i > 0 then
              obj_data := json_object_t();
              obj_data.put('flgbreak','Y');
              obj_data.put('coderror','200');
              v_namcent   := replace(get_comp_label(v_codcomp1,i,global_v_lang),'*',null);
              obj_data.put('codempid',v_namcent);
              obj_data.put('codcomp',hcm_util.get_codcomp_level(v_codcomp1,i));
              obj_data.put('desc_codempid',get_tcenter_name(hcm_util.get_codcomp_level(v_codcomp1,i),global_v_lang));
              obj_rows.put(to_char(v_count),obj_data);
              v_count := v_count + 1;
            end if;
          end loop;
        end if;
        -- add current
        obj_rows.put(to_char(v_count),obj_data_old);
       -- countSummary(obj_data_old);
        v_count   := v_count + 1;
        obj_token := obj_data_old;
      end if;
    end loop;

    if p_breaklevelAll then
      if obj_token is not null then -- if have more than 0 add sum
        obj_data := json_object_t();
        obj_data.put('flgbreak','Y');
        obj_data.put('coderror','200');
        obj_data.put('desc_codempid'    ,v_label || v_label2);
      --  obj_data.put('qtyhrs'       ,hcm_util.convert_minute_to_hour(p_qtyminCodempid));
      --  obj_data.put('amount'       ,to_char(nvl(p_amtpayCodempid,0),'fm999999999990.00'));
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      --  p_qtyminCodempid := 0;
        --p_amtpayCodempid := 0;

        v_codcomp2 := hcm_util.get_string_t(obj_token   ,'codcomp'); -- last
        v_level := getLevelCodcomp(v_codcomp2);
        for i in 0..v_level-1 loop
          if v_level-i = getTrueLevel(v_level-i) then
            obj_data := json_object_t();
            obj_data.put('flgbreak','Y');
            obj_data.put('coderror','200');
--            begin
--              select decode (global_v_lang,'101',namcente,
--                                           '102',namcentt,
--                                           '103',namcent3,
--                                           '104',namcent4,
--                                           '105',namcent5)
--                into v_namcent
--                from tsetcomp
--               where numseq = v_level-i;
--            exception when no_data_found then
--              v_namcent := null;
--            end;
            v_namcent   := replace(get_comp_label(v_codcomp2,v_level-i,global_v_lang),'*',null);
            obj_data.put('desc_codempid'     ,v_label || v_namcent);
         --   obj_data.put('qtyhrs'       ,hcm_util.convert_minute_to_hour(getQtyminSum(v_level-i)));
        --    obj_data.put('amount'       ,to_char(nvl(getAmtpaySum(v_level-i),0),'fm999999999990.00'));
            obj_rows.put(to_char(v_count),obj_data);
            v_count := v_count + 1;
--            resetSummary(i);
          end if;
        end loop;
      end if;
    end if;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_value(json_str_input);
    isInsertReport := true;

    if param_msg_error is null then
      p_codapp := 'HRPY5NX';
      clear_ttemprpt;
      gen_index(json_output);
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_report;

  function split_number_id (v_item number) return varchar2 as
  begin
    return substr(v_item,1,1)||'-'||
           substr(v_item,2,1)||substr(v_item,3,1)||substr(v_item,4,1)||substr(v_item,5,1)||'-'||
           substr(v_item,6,1)||substr(v_item,7,1)||substr(v_item,8,1)||substr(v_item,9,1)||substr(v_item,10,1)||'-'||
           substr(v_item,11,1)||substr(v_item,12,1)||'-'||
           substr(v_item,13,1);
  end split_number_id;

 function split_account_id (v_item varchar2) return varchar2 as
  begin
    return substr(v_item,1,2)||'-'||
           substr(v_item,3,7)||'-'||
           substr(v_item,10,1);
  end split_account_id;

  procedure insert_ttemprpt_data(obj_data in json_object_t) is
    json_data_rows      json_object_t;
    v_data_rows         json_object_t;
    v_numseq            number := 0;
    v_numseq2           number := 0;
    v_numseq_val        number;
    v_codbrlc             varchar2(1000 char);
    v_desc_codbrlc        varchar2(1000 char);
    v_codcompy            varchar2(1000 char);
    v_desc_codcompy       varchar2(1000 char);
    v_numacsoc            varchar2(1000 char);
    v_numbrlvl            varchar2(1000 char);
    v_codbrsoc            varchar2(1000 char);
    v_address           varchar2(4000 char);
    v_codcomp           varchar2(1000 char);
    v_codempid          varchar2(1000 char);
    v_desc_codempid     varchar2(1000 char);
    v_desc_codnatnl     varchar2(1000 char);
    v_dteeffex          varchar2(1000 char);
    v_dteempdb          varchar2(1000 char);
    v_dteempmt          varchar2(1000 char);
    v_image             varchar2(1000 char);
    v_numoffid          varchar2(1000 char);
    v_numsaid           varchar2(1000 char);
    v_sumday            varchar2(1000 char);
    v_sumhur            varchar2(1000 char);
    v_summth            varchar2(1000 char);
    v_codpos            varchar2(1000 char);
    v_codpos_desc       varchar2(1000 char) := '';
    v_numseq_temp       number := 0;
    v_flgbreak          varchar2(50);
  begin
    v_codbrlc         := hcm_util.get_string_t(obj_data, 'codbrlc');
    v_desc_codbrlc    := hcm_util.get_string_t(obj_data, 'codbrlc_desc');
    v_codcompy        := hcm_util.get_string_t(obj_data, 'codcompy');
    v_desc_codcompy   := hcm_util.get_string_t(obj_data, 'codcompy_desc');
    if hcm_util.get_string_t(obj_data, 'numacsoc') is not null then
      v_numacsoc        := split_account_id(hcm_util.get_string_t(obj_data, 'numacsoc'));
    end if;
    v_numbrlvl        := hcm_util.get_string_t(obj_data, 'numbrlvl');
    v_codbrsoc        := hcm_util.get_string_t(obj_data, 'codbrsoc');

    json_data_rows     := hcm_util.get_json_t(obj_data, 'children');
    v_numseq2 := 0;
    for i in 0..json_data_rows.get_size-1 loop

      v_data_rows      := hcm_util.get_json_t(json_data_rows, to_char(i));

      v_address           := hcm_util.get_string_t(v_data_rows, 'address');
      v_codcomp           := hcm_util.get_string_t(v_data_rows, 'codcomp');
      v_codempid          := hcm_util.get_string_t(v_data_rows, 'codempid');
      v_desc_codempid     := hcm_util.get_string_t(v_data_rows, 'desc_codempid');
      v_desc_codnatnl     := hcm_util.get_string_t(v_data_rows, 'desc_codnatnl');
      v_dteeffex          := hcm_util.get_string_t(v_data_rows, 'dteeffex');
      v_dteempdb          := hcm_util.get_string_t(v_data_rows, 'dteempdb');
      v_dteempmt          := hcm_util.get_string_t(v_data_rows, 'dteempmt');
      v_image             := hcm_util.get_string_t(v_data_rows, 'image');
      v_numoffid          := hcm_util.get_string_t(v_data_rows, 'numoffid');
      v_numsaid           := hcm_util.get_string_t(v_data_rows, 'numsaid');
      v_sumday            := hcm_util.get_string_t(v_data_rows, 'sumday');
      v_sumhur            := hcm_util.get_string_t(v_data_rows, 'sumhur');
      v_summth            := hcm_util.get_string_t(v_data_rows, 'summth');
      v_flgbreak          := hcm_util.get_string_t(v_data_rows, 'flgbreak');
      --

      begin
        select nvl(max(numseq), 0) into v_numseq
          from ttemprpt
         where codempid = global_v_codempid
           and codapp   = p_codapp;
      exception when no_data_found then null;
      end;

      begin
        select codpos into v_codpos
          from temploy1
         where codempid = v_codempid;
         v_codpos_desc := get_tpostn_name(v_codpos,global_v_lang);
      exception when no_data_found then
        v_codpos_desc := null;
      end;

      v_numseq     := v_numseq + 1;
      if nvl(v_flgbreak,'XX') != 'Y' then
        v_numseq2     := v_numseq2 + 1;
        v_numseq_val  := v_numseq2;
        if v_numoffid is not null then
          v_numoffid   := split_number_id(v_numoffid);
        end if;
      else
        v_numseq_val  := null;
      end if;
      --
      begin
        insert
          into ttemprpt( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7,
                         item8, item9, item10, item11, item12, item13, item14, item15,
                         item16, item17, item18, item19, item20, item21, item22, item23 )
        values ( global_v_codempid, p_codapp, v_numseq, v_codbrlc, v_desc_codbrlc, v_codcompy, v_desc_codcompy, v_numacsoc, v_numbrlvl, v_codbrsoc,
                 v_address,v_codcomp,v_codempid,v_desc_codempid,v_desc_codnatnl,
                 to_char(add_months(to_date(v_dteeffex,'dd/mm/yyyy'),543*12),'dd/mm/yyyy'),
                 to_char(add_months(to_date(v_dteempdb,'dd/mm/yyyy'),543*12),'dd/mm/yyyy'),
                 to_char(add_months(to_date(v_dteempmt,'dd/mm/yyyy'),543*12),'dd/mm/yyyy'),v_image,
                 v_numoffid ,v_numsaid,v_numseq_val,
                 v_sumday,v_sumhur,to_char(v_summth,'FM9,999,999,999.00'),v_codpos_desc);
      exception when others then null;
      end;
    end loop;
    v_numseq_temp := (20 - (v_numseq -(20 * FLOOR(v_numseq/20))));

    -- loop for empty row, fix 13 item for each page
    if v_numseq_temp <> 20 then
      for i in 1..v_numseq_temp loop
         v_numseq     := v_numseq + 1;
         begin
            insert
              into ttemprpt( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7,
                             item8, item9, item10, item11, item12, item13, item14, item15,
                             item16, item17, item18, item19, item20, item21, item22, item23 )
            values ( global_v_codempid, p_codapp, (v_numseq+1),
                     v_codbrlc,
                     v_desc_codbrlc,
                     v_codcompy,
                     v_desc_codcompy,
                     v_numacsoc,
                     v_numbrlvl,
                     v_codbrsoc,
                     '','','','','',
                     '',
                     '',
                    '','',
                     '' ,'','',
                     '','','','');
          exception when others then null;
          end;
        end loop;
      end if;
  end insert_ttemprpt_data;
end hrpy5nx;

/

--------------------------------------------------------
--  DDL for Package Body HRPY25X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY25X" as
-- last update: 17/02/2023 17:30
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
    p_numperiod         := hcm_util.get_string_t(json_obj, 'p_numperiod');
    p_dtemthpay         := hcm_util.get_string_t(json_obj, 'p_dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj,'p_dteyrepay');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  function get_ot_col (v_codcompy varchar2) return json_object_t is
    obj_ot_col         json_object_t;
    v_max_ot_col       number := 0;

    cursor max_ot_col is
      select distinct(rteotpay)
        from totratep2
       where codcompy = v_codcompy
         and dteeffec = (select max(b.dteeffec)
                           from totratep2 b
                          where b.codcompy = v_codcompy
                            and b.dteeffec <= sysdate)
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

  procedure check_ot_head is
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codempid is not null then
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end check_ot_head;

  procedure get_ot_head (json_str_input in clob, json_str_output out clob) is
    v_codcompy          TCENTER.CODCOMPY%TYPE;
  begin
    initial_value(json_str_input);
    check_ot_head;

    if param_msg_error is null then
      gen_ot_head(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_ot_head;

  procedure gen_ot_head (json_str_output out clob) is
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
    obj_data            := json_object_t();
    obj_row            := json_object_t();
    v_codcompy         := null;
    if p_codcomp is not null then
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp, 1);
    elsif p_codempid is not null then
      begin
        select get_comp_split(codcomp, 1) codcompy
          into v_codcompy
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        null;
      end;
    end if;
    obj_ot_col         := get_ot_col(v_codcompy);

    obj_data.put('otkey', v_text_key);
    obj_data.put('otlen', v_rateot_length+1); --obj_ot_col.get_size
    for i in 1..v_rateot_length loop
      v_ot_col := hcm_util.get_string_t(obj_ot_col, to_char(i));
      if v_ot_col is not null then
        v_check_rat := 'T';
        obj_data.put(v_text_key||i, hcm_util.get_string_t(obj_ot_col, to_char(i)));
      else
        obj_data.put(v_text_key||i, ' ');
      end if;
    end loop;
    v_count  := obj_ot_col.get_size;

--insert_ttemprpt('PY25X','PY25X',obj_ot_col.get_size,'head',null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
    v_other  := get_label_name('HRAL61XC1', global_v_lang, '310');
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
    obj_row.put(0, obj_data);
    json_str_output := obj_row.to_clob;
  end gen_ot_head;

  procedure check_index is
    v_typpayroll tcodtypy.codcodec%type;
    v_codempid   temploy1.codempid%type;
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_typpayroll is not null then
      begin
        select codcodec
          into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodtypy');
        return;
      end;
    end if;
    --
    if p_codempid is not null then
      begin
        select codempid into v_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
  end check_index;

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

  procedure gen_data(json_str_output out clob) is
    type t_otrate is table of totratep2.rteotpay%type;
    type t_sum_otrate is table of number;
    type t_sum_amtspot is table of number;
    v_otrate          t_otrate    := t_otrate();
    v_otrate_count    number      := 1;
    v_flgdata         varchar2(1 char) := 'N';
    v_flgsecur        varchar2(1 char) := 'N';
    v_check_secur     varchar2(1 char) := 'N';
    obj_row           json_object_t := json_object_t();
    obj_data          json_object_t;
    v_row             number  := 0;
    v_exist           boolean := false;
    v_sum_otrate      number := 0;--t_sum_otrate  := t_sum_otrate();
    v_sum_amtspot     number := 0;--t_sum_amtspot := t_sum_amtspot();
    v_codcomp         varchar2(4000 char);
    v_qtysmot         number;
    v_amtspot         number;
    v_qtysmot_oth     number;
    v_amtspot_oth     number;

    v_max_ot_col    number := 0;
    obj_ot_col      json_object_t;
    v_ot_min        number;
    v_rteotpay      number;
    v_rateot5       varchar2(100 char);
    v_rateot_min5   number;
    v_qtyot5        varchar2(100 char);
    v_qtyot_min5    number;
    v_rtesmot    number;
    v_secur3   	     boolean := true;
    v_check_rate    varchar(1 char);

    cursor c_rate is
      select distinct (rteotpay)
        from totratep2
       where codcompy = nvl(hcm_util.get_codcomp_level(v_codcomp,1), codcompy)
    order by rteotpay;

    cursor c1 is
      select distinct a.codcomp,a.codempid,a.amtothr,b.codcompw,a.qtysmot,a.amtottot,b.codsys,a.coduser,a.dteupd
--a.codempid,a.amtothr,b.codcompw,b.qtysmot,b.amtspot
--a.codcomp,a.codempid,a.dteyrepay,a.dtemthpay,a.numperiod,a.typpayroll,
--                      a.typemp,a.qtysmot,stddec(a.amtottot,a.codempid,v_chken) amtottot,
--                      a.amtothr,a.dteupd,a.coduser,b.qtysmot qtys,b.rtesmot,a.costcent,a.rowid
	  	       from totsum a,totsumd b,temploy1 c
					  where a.numperiod = b.numperiod
							and a.dtemthpay = b.dtemthpay
		 					and a.dteyrepay = b.dteyrepay
		 					and a.codempid  = b.codempid
		 					and a.codempid  = c.codempid
							and a.numperiod  = p_numperiod
							and a.dtemthpay  = p_dtemthpay
							and a.dteyrepay  = p_dteyrepay -- :global.v_zyear
							and a.codcomp like p_codcomp||'%'
--							and (a.typpayroll = p_typpayroll or a.codempid = p_codempid)
							and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
              and a.codempid = nvl(p_codempid,a.codempid)
              /*and c.numlvl between global_v_zminlvl and global_v_zwrklvl
              and 0 <> (select count(ts.codcomp)
                          from tusrcom ts
                         where ts.coduser = global_v_coduser
                           and c.codcomp like ts.codcomp||'%'
                           and rownum <= 1)*/ --18/09/2020
				order by a.codcomp,a.codempid;
  begin
    if p_codcomp is null and p_codempid is not null then
      begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = p_codempid;
         v_codcomp := hcm_util.get_codcomp_level(v_codcomp,1);
      exception when no_data_found then
        v_codcomp := null;
      end;
    elsif p_codcomp is not null then
      v_codcomp := hcm_util.get_codcomp_level(p_codcomp,1);
    end if;

    obj_ot_col        := get_ot_col(v_codcomp);

--    for r_rate in c_rate loop
--      v_otrate.extend();
--      v_otrate(v_otrate_count) := r_rate.rteotpay;
--      v_otrate_count := v_otrate_count + 1;
--    end loop;
    
    obj_row := json_object_t();

    for r1 in c1 loop
        v_exist := true;
        exit;
    end loop;
    if not v_exist then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'totsum');
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;

    for r1 in c1 loop
      v_secur3 := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,
      global_v_zminlvl,global_v_zwrklvl, --18/09/2020 ||global_v_numlvlsalst,global_v_numlvlsalen,
      v_zupdsal);
      if v_secur3 then
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcomp);
        --<<User37 Final Test Phase 1 V11 #2727 21/10/2020
        --obj_data.put('amtothr', stddec(r1.amtothr, r1.codempid, v_chken));
        if v_zupdsal = 'Y' then
            obj_data.put('amtothr', stddec(r1.amtothr, r1.codempid, v_chken));
        else
            obj_data.put('amtothr', '');
        end if;

--obj_data.put('amtothr', '888888'); --user39

        -->>User37 Final Test Phase 1 V11 #2727 21/10/2020

        obj_data.put('codcompw', get_tcenter_name(r1.codcompw,global_v_lang));
--        obj_data.put('otrate_count',to_char(v_otrate_count-1));
        obj_data.put('otkey', v_text_key);
        obj_data.put('otlen', v_rateot_length+1);

--        for i in 1..obj_ot_col.count loop
--          begin
--            select nvl(sum(qtyminot), 0)
--              into v_ot_min
--              from totpaydt
--             where codempid = v_codempid
--               and dtework  = v_dtework
--               and rteotpay = hcm_util.get_string(obj_ot_col, to_char(i));
--          exception when no_data_found then
--            v_ot_min      := 0;
--          end;
--         if i <= v_rateot_length then -- case < 5 rate
--            obj_data.put(v_text_key||i, cal_hour_unlimited(v_ot_min, true));
--            obj_data.put(v_text_key||'_min'||i, v_ot_min);
--          else  -- case >= 5 rate
--            v_rateot_min5 := v_rateot_min5 + nvl(v_ot_min, 0);
--            v_rateot5 := cal_hour_unlimited(v_rateot_min5, true);
--          end if;
--        end loop;

        --18/09/2020
        v_rateot_min5 := null;
        v_qtyot5 := null;

        for i in 1..obj_ot_col.get_size loop
            begin
              v_rtesmot := hcm_util.get_string_t(obj_ot_col, to_char(i));
              select sum(nvl(qtysmot,0)),sum(nvl(stddec(amtspot, r1.codempid, v_chken),0))
                into v_qtysmot,v_amtspot
                from totsumd
               where codempid  = r1.codempid
                 and codcompw  = r1.codcompw
                 and dteyrepay = p_dteyrepay
                 and dtemthpay = p_dtemthpay
                 and numperiod = p_numperiod
                 and rtesmot   = v_rtesmot
                 and codsys    = r1.codsys; --18/09/2020

            exception when others then
              v_qtysmot := 0;
              v_amtspot := 0;
            end;
                if i <= v_rateot_length then -- case < 5 rate
                    if v_qtysmot is not null and v_qtysmot != 0 then
                      obj_data.put('otrate'||to_char(i),hcm_util.convert_minute_to_hour(v_qtysmot));
                      v_sum_otrate := v_sum_otrate + v_qtysmot;
                    end if;
                    if v_amtspot is not null and v_amtspot >= 0 then
                      --<<User37 Final Test Phase 1 V11 #2727 19/10/2020
                      --obj_data.put('sum_otrate'||to_char(i),v_amtspot);
                      if v_zupdsal = 'Y' then
                        obj_data.put('sum_otrate'||to_char(i),v_amtspot);
                      else
                        obj_data.put('sum_otrate'||to_char(i),'');
                      end if;
                      -->>User37 Final Test Phase 1 V11 #2727 19/10/2020
                      v_sum_amtspot := nvl(v_sum_amtspot,0) + nvl(v_amtspot,0);  --#6895 || User39 || 14/10/2021  add NVL Function
                    end if;
                 else  -- case >= 5 rate
                    v_rateot_min5 := nvl(v_rateot_min5,0) + nvl(v_qtysmot,0);                  --#6895 || User39 || 14/10/2021  add NVL Function
                    v_rateot5     := hcm_util.convert_minute_to_hour(nvl(v_rateot_min5,0));    --#6895 || User39 || 14/10/2021  add NVL Function
                    v_qtyot5      := nvl(v_qtyot5,0) + nvl(v_amtspot, 0);                      --#6895 || User39 || 14/10/2021  add NVL Function
                    v_sum_amtspot := nvl(v_sum_amtspot,0) + nvl(v_amtspot,0);                  --#6895 || User39 || 14/10/2021  add NVL Function
                    v_sum_otrate  := nvl(v_sum_otrate,0) + nvl(v_qtysmot,0);                   --#6895 || User39 || 14/10/2021  add NVL Function
                 end if;
        end loop;
        --18/09/2020
        --find other o.t. rate
        begin
            select sum(nvl(qtysmot,0)),sum(nvl(stddec(amtspot, r1.codempid, v_chken),0))
              into v_qtysmot_oth,v_amtspot_oth
              from totsumd
             where codempid  = r1.codempid
               and codcompw  = r1.codcompw
               and dteyrepay = p_dteyrepay
               and dtemthpay = p_dtemthpay
               and numperiod = p_numperiod
               and rtesmot   not in (select distinct(rteotpay)
                                      from totratep2
                                     where codcompy = v_codcomp
                                       and dteeffec = (select max(b.dteeffec)
                                                         from totratep2 b
                                                        where b.codcompy = v_codcomp
                                                          and b.dteeffec <= sysdate))
               and codsys    = r1.codsys;

          exception when others then
            v_qtysmot_oth := 0;
            v_amtspot_oth := 0;
          end;
        if v_qtysmot_oth > 0 then
          v_rateot_min5 := nvl(v_rateot_min5,0) + nvl(v_qtysmot_oth,0); --#6895 || User39 || 14/10/2021  add NVL Function
          v_qtyot5 := nvl(v_qtyot5,0) + nvl(v_amtspot_oth,0);           --#6895 || User39 || 14/10/2021  add NVL Function
          --<<User37 Final Test Phase 1 V11 Error Program #2176 20/10/2020
          v_sum_amtspot := nvl(v_sum_amtspot,0) + nvl(v_amtspot_oth,0);
          v_sum_otrate := nvl(v_sum_otrate,0) + nvl(v_qtysmot_oth,0);
          -->>User37 Final Test Phase 1 V11 Error Program #2176 20/10/2020
--          obj_data.put('otrate5',hcm_util.convert_minute_to_hour(v_rateot_min5));
--          obj_data.put('sum_otrate5',v_qtyot5);
        end if;

        obj_data.put('otrate5',hcm_util.convert_minute_to_hour(v_rateot_min5));

        --<<User37 Final Test Phase 1 V11 #2727 19/10/2020
        --obj_data.put('sum_otrate5',v_qtyot5);
        if v_zupdsal = 'Y' then
            obj_data.put('sum_otrate5',v_qtyot5);
        else
            obj_data.put('sum_otrate5','');
        end if;

        -->>User37 Final Test Phase 1 V11 #2727 19/10/2020
--insert_ttemprpt('PY25X','PY25X',v_rateot_min5,v_qtyot5,r1.codempid||','||r1.codsys,obj_ot_col.get_size,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
        --18/09/2020
        /*
        obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
        obj_data.put(v_text_key||'_min'||to_char(v_rateot_length+1), v_rateot_min5);
        obj_data.put('sum_'||v_text_key||to_char(v_rateot_length+1), v_qtyot5);*/

--        for i in 1..(v_otrate_count-1) loop
--            begin
--              select sum(nvl(qtysmot,0)),sum(nvl(stddec(amtspot, r1.codempid, v_chken),0))
--                into v_qtysmot,v_amtspot
--                from totsumd
--               where codempid  = r1.codempid
--                 and codcompw  = r1.codcompw
--                 and dteyrepay = p_dteyrepay
--                 and dtemthpay = p_dtemthpay
--                 and numperiod = p_numperiod
--                 and rtesmot   = v_otrate(i);
--              if v_qtysmot is not null and v_qtysmot != 0 then
--                obj_data.put('otrate'||to_char(i),hcm_util.convert_minute_to_hour(v_qtysmot));
--                v_sum_otrate := v_sum_otrate + v_qtysmot;
--              end if;
--              if v_amtspot is not null and v_amtspot >= 0 then
--                obj_data.put('sum_otrate'||to_char(i),v_amtspot);
--                v_sum_amtspot := v_sum_amtspot + v_amtspot;
--              end if;
--            exception when others then null;
--            end;
--        end loop;

--        begin
--          select sum(nvl(qtysmot,0)),sum(nvl(stddec(amtspot, r1.codempid, v_chken),0))
--            into v_qtysmot,v_amtspot
--            from totsumd
--           where codempid  = r1.codempid
--             and dteyrepay = p_dteyrepay
--             and dtemthpay = p_dtemthpay
--             and numperiod = p_numperiod
--             and rtesmot not in (select distinct (rteotpay)
--                                   from totratep2
--                                  where codcompy = nvl(v_codcomp, codcompy));
--
--          if v_qtysmot is not null and v_qtysmot != 0 then
--            obj_data.put('other',hcm_util.convert_minute_to_hour(v_qtysmot));
--            v_sum_otrate := v_sum_otrate + v_qtysmot;
--          end if;
--          if v_amtspot is not null and v_amtspot >= 0 then
--            obj_data.put('sum_other',v_amtspot);
--            v_sum_amtspot := v_sum_amtspot + v_amtspot;
--          end if;
--        exception when others then null;
--        end;
        obj_data.put('qtyottot',hcm_util.convert_minute_to_hour(nvl(v_sum_otrate,0))); --#6895 || User39 || 14/10/2021  add NVL Function
        --<<User37 Final Test Phase 1 V11 #2727 19/10/2020
        --obj_data.put('amtottot',v_sum_amtspot);
        if v_zupdsal = 'Y' then
            obj_data.put('amtottot',v_sum_amtspot);
        else
            obj_data.put('amtottot','');
        end if;

        -->>User37 Final Test Phase 1 V11 #2727 19/10/2020
        obj_data.put('codsys',r1.codsys);
        obj_data.put('coduser',r1.coduser);
        obj_data.put('dteupd',to_char(r1.dteupd,'dd/mm/yyyy'));
        obj_row.put(to_char(v_row - 1), obj_data);
        v_sum_otrate := 0;
        v_sum_amtspot := 0;
      end if;
    end loop;

    if v_row = 0 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return;
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;


  procedure get_index_head(json_str_input in clob, json_str_output out clob) is
    obj_data        json_object_t := json_object_t();
    obj_row         json_object_t := json_object_t();
    v_index         number  := 0;
    v_codcomp       varchar2(4000 char);
    v_others_rate   varchar2(1) := 'N';
    cursor c1 is
      select distinct (rteotpay)
        from totratep2
       where codcompy = nvl(v_codcomp, codcompy)
    order by rteotpay;

  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      if p_codcomp is null and p_codempid is not null then
        begin
          select codcomp
            into v_codcomp
            from temploy1
           where codempid = p_codempid;
           v_codcomp := hcm_util.get_codcomp_level(v_codcomp,1);
        exception when no_data_found then
          v_codcomp := null;
        end;
      elsif p_codcomp is not null then
        v_codcomp := hcm_util.get_codcomp_level(p_codcomp,1);
      end if;

      for r1 in c1 loop
        obj_row.put('otrate' || to_char(v_index),to_char(r1.rteotpay));
        v_index := v_index + 1;
      end loop;
      begin
        select distinct 'Y'
          into v_others_rate
          from totsumd
         where codempid  = nvl(p_codempid,codempid)
           and dteyrepay = p_dteyrepay
           and dtemthpay = p_dtemthpay
           and numperiod = p_numperiod
           and codempid in (select codempid
                              from temploy1
                             where codcomp like p_codcomp||'%')
           and rtesmot not in (select rteotpay
                                 from totratep2
                                where codcompy = nvl(v_codcomp, codcompy));
      exception when no_data_found then
        v_others_rate := 'N';
      end;
      if v_others_rate = 'Y' then
        obj_row.put('otrate' || to_char(v_index),get_label_name('HRPY25XC1',global_v_lang,200));
        v_index := v_index + 1;
      end if;

      obj_data.put('coderror','200');
      obj_data.put('otrate',obj_row);
      obj_data.put('otrate_count',to_char(v_index));

      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index_head;

end HRPY25X;

/

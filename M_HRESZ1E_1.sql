--------------------------------------------------------
--  DDL for Package Body M_HRESZ1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRESZ1E" AS

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
    v_check_qtyworkall  varchar2(100 char);
  begin
    json_obj            := json_object_t(json_str);

    param_msg_error     := '';
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

--    p_codapp            := hcm_util.get_string_t(json_obj,'p_codapp');
--    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    param_json          := hcm_util.get_json_t(json_obj,'param_json');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_budget_month      := hcm_util.get_string_t(json_obj,'p_budget_month');
    p_budget_year       := hcm_util.get_string_t(json_obj,'p_budget_year');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    v_check_qtyworkall    := hcm_util.get_string_t(json_obj, 'p_qtyhworkall');
    if v_check_qtyworkall = 'undefined' then
      v_check_qtyworkall := '';
    end if;
    p_qtyhworkall       := hcm_util.convert_hour_to_minute(v_check_qtyworkall);

--    p_qtyhworkall       := hcm_util.get_string_t(json_obj,'p_qtyhworkall');
--    p_pctbudget         := TO_NUMBER(hcm_util.get_string_t(json_obj,'p_pctbudget'));
--    p_pctabslv          := TO_NUMBER(hcm_util.get_string_t(json_obj,'p_pctabslv'));
    p_pctbudget         := to_char(TO_NUMBER(replace(hcm_util.get_string_t(json_obj, 'p_pctbudget'),',','')), 'FM999,999,999,990.00');
    p_pctabslv          := to_char(TO_NUMBER(replace(hcm_util.get_string_t(json_obj, 'p_pctabslv'),',','')), 'FM999,999,999,990.00');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

--  procedure gen_data (json_str_output out clob) is
--    obj_data            json_object_t;
--    obj_row             json_object_t;
--    obj_result          json_object_t;
--    v_rcnt              number := 0;
--    current_day         varchar(20 char);
--    current_month       number;
--    current_year        number;
--    v_flg_disabled      boolean;
--    p_dtestrt           date;
--    p_dteend            date;
--    flgAdd              boolean;
--
--    v_date              varchar(20 char);
--    present_date        varchar(20 char);
--
----    cursor c1 is
----      select *
----        from tbudgetot
----       where codcomp like p_codcomp||'%'
----         and dtemonth = p_budget_month
----         and dteyear = p_budget_year
----    order by codcomp;
--
--    cursor c1 is
--      select a.* -- select data ตามค่าที่ส่งมา แต่ถ้าไม่เจอจะเอาค่าล่าสุด แต่ไม่มากกว่าค่าที่ส่งมาแทน
--        from tbudgetot a
--       where codcomp like p_codcomp||'%'
--         and dteyear||lpad(DTEMONTH, 2, 0) = (
--             select decode(
--             (select dteyear||lpad(DTEMONTH, 2, 0)
--                from tbudgetot
--               where dteyear = p_budget_year
--                 and dtemonth = p_budget_month
----                 and codcomp like p_codcomp||'%' --issue(4449#1466) 13/11/2023
--                 and codcomp = a.codcomp --issue(4449#1466) 13/11/2023
--             ), null, -- ถ้า query ชุดนี้ไม่เจอ จะไปเอา query ชุดข้่้างล่าง
--        (select max(dteyear||lpad(DTEMONTH, 2, 0))
--           from tbudgetot
--          where to_date(dteyear|| lpad(dtemonth, 2, 0), 'yyyymm') <= to_date(p_budget_year||lpad(p_budget_month, 2, 0), 'yyyymm')
----            and codcomp like p_codcomp||'%' --issue(4449#1466) 13/11/2023
--              and codcomp = a.codcomp
----              and to_date(dteyear|| lpad(dtemonth, 2, 0), 'yyyymm') <= to_date(present_date, 'yyyymm')
--        ),  -- ถ้าเอา query ชุดนี้ไม่เจอ จะไปเอาข้างล่าง
--        (select dteyear||lpad(DTEMONTH, 2, 0)
--           from tbudgetot
--          where dteyear = p_budget_year
--            and dtemonth = p_budget_month
----            and codcomp like p_codcomp||'%')) --issue(4449#1466) 13/11/2023
--            and codcomp = a.codcomp)) --issue(4449#1466) 13/11/2023
--        from dual
--        );
--
--    begin
--      obj_row := json_object_t();
--      obj_data := json_object_t();
--      obj_result := json_object_t();
--
--      current_day := to_char(sysdate, 'ddmm'); -- get วันที่ เดือน ปัจจุบัน
--      current_month := SUBSTR(current_day, 3); -- substr เพื่อเอาเดือนออกมา
--      current_year := to_number(to_char(sysdate,'yyyy')); -- get ปีปัจจุบัน
--
--
--      v_date := p_budget_year||lpad(p_budget_month, 2, 0);
--      present_date := current_year||lpad(current_month, 2, 0);
--
----      if (p_budget_year >= current_year) then
----        if (p_budget_month >= current_month) then
----          v_flg_disabled := true; --งวดปัจจุบันหรือมากกว่า
----        else
----          v_flg_disabled := false;  --งวดย้อนหลัง
----        end if;
----      else
----         v_flg_disabled := false;  -- งวดย้อนหลัง
----      end if;
--
--      if (v_date >= present_date) then
--        v_flg_disabled := true; --งวดปัจจุบันหรือมากกว่า
--      else
--        v_flg_disabled := false;  --งวดย้อนหลัง
--      end if;
--
--      p_dtestrt := TRUNC(SYSDATE, 'MM');
--      p_dteend := TRUNC(LAST_DAY(SYSDATE));
--
--      for r1 in c1 loop
--        if v_flg_disabled = true then
--          if (p_budget_year <= r1.DTEYEAR) then
--            if (p_budget_month > r1.DTEMONTH) then
--              flgAdd  := true;
--            else
--              flgAdd  := false;
--            end if;
--          else
--            flgAdd    := true;
--          end if;
--        else
--          flgAdd  := false;
--        end if;
--
--        v_rcnt      := v_rcnt+1;
--        obj_data    := json_object_t();
--
--        if v_flg_disabled = false then
--          if secur_main.secur7(r1.codcomp, global_v_coduser) = true then
--            obj_data.put('codcomp', hcm_util.get_codcomp_level(rpad(r1.codcomp,40,'0'),10));
--            -- "How to fix it when codcomp is stored in a shortened table but the status is cancelled.
--            -- (tcenter.flgate =2) causes the screen to not show data of codcomp.
--            -- Because lov reads Desc only in full. Make the submitted short form blank."
--            -- "วิธีแก้ไข เมื่อ codcomp เก็บใน Table แบบย่อ แต่มีสถานะเป็นยกเลิก
--            -- (tcenter.flgate =2) ทำให้ที่หน้าจอ จะไม่โชว์ data ของ codcomp
--            -- เนื่องจาก lov อ่านค่า Desc เฉพาะแบบเต็มเท่านั้น ทำให้แบบย่อที่ส่งมา เป็นค่าว่าง"
--
--            -- "Edit by sending the full codcomp value and specifying
--            -- fullDisp: false in column.js for abbreviated display"
--            -- "แก้ไขด้วยการส่งค่า codcomp แบบเต็มมา แล้วกำหนด
--            -- fullDisp: false ที่ column.js เพื่อให้แสดงแบบย่อ"
--            obj_data.put('pctbudget', r1.pctbudget);
--            obj_data.put('pctabslv', r1.pctabslv);
--            obj_data.put('qtymanpw', r1.qtymanpw);
--            --> issue(4449#1467) 10/11/2023
----            obj_data.put('qtyhwork', hcm_util.convert_minute_to_hour(r1.qtyhwork));
----            obj_data.put('qtybudget', hcm_util.convert_minute_to_hour(r1.qtybudget));
--            p_qtyhwork_hour := hcm_util.convert_minute_to_hour(r1.qtyhwork);
--            p_qtybudget_hour := hcm_util.convert_minute_to_hour(r1.qtybudget);
--            obj_data.put('qtyhwork', substr(p_qtyhwork_hour, 1, instr(p_qtyhwork_hour, ':') - 1));
--            obj_data.put('qtybudget', substr(p_qtybudget_hour, 1, instr(p_qtybudget_hour, ':') - 1));
--            --< issue(4449#1467) 10/11/2023
--            obj_data.put('flgAdd', flgAdd);
--            obj_data.put('coderror', '200');
--            obj_data.put('response', '');
--
--            obj_row.put(to_char(v_rcnt-1),obj_data);
--          end if;
--        else
--          if secur_main.secur7(r1.codcomp, global_v_coduser) = true then
--            obj_data.put('codcomp', hcm_util.get_codcomp_level(rpad(r1.codcomp,40,'0'),10));
--            -- "How to fix it when codcomp is stored in a shortened table but the status is cancelled.
--            -- (tcenter.flgate =2) causes the screen to not show data of codcomp.
--            -- Because lov reads Desc only in full. Make the submitted short form blank."
--            -- "วิธีแก้ไข เมื่อ codcomp เก็บใน Table แบบย่อ แต่มีสถานะเป็นยกเลิก
--            -- (tcenter.flgate =2) ทำให้ที่หน้าจอ จะไม่โชว์ data ของ codcomp
--            -- เนื่องจาก lov อ่านค่า Desc เฉพาะแบบเต็มเท่านั้น ทำให้แบบย่อที่ส่งมา เป็นค่าว่าง"
--
--            -- "Edit by sending the full codcomp value and specifying
--            -- fullDisp: false in column.js for abbreviated display"
--            -- "แก้ไขด้วยการส่งค่า codcomp แบบเต็มมา แล้วกำหนด
--            -- fullDisp: false ที่ column.js เพื่อให้แสดงแบบย่อ"
--            obj_data.put('pctbudget', r1.pctbudget);
--            obj_data.put('pctabslv', r1.pctabslv);
--
--            otbudget.get_manpw_budget(r1.codcomp, p_dtestrt, p_dteend, p_qtymanpw, p_qtyhworkall);
--            otbudget.get_ot_budget(p_qtyhworkall, r1.pctbudget, r1.pctabslv, p_qtyhwork, p_qtybudget);
--            obj_data.put('qtymanpw', p_qtymanpw);
--            obj_data.put('qtyhworkall', hcm_util.convert_minute_to_hour(p_qtyhworkall));
--            --> issue(4449#1467) 10/11/2023
----            obj_data.put('qtyhwork', hcm_util.convert_minute_to_hour(p_qtyhwork));
----            obj_data.put('qtybudget', hcm_util.convert_minute_to_hour(p_qtybudget));
--            p_qtyhwork_hour := hcm_util.convert_minute_to_hour(p_qtyhwork);
--            p_qtybudget_hour := hcm_util.convert_minute_to_hour(p_qtybudget);
--            obj_data.put('qtyhwork', substr(p_qtyhwork_hour, 1, instr(p_qtyhwork_hour, ':') - 1));
--            obj_data.put('qtybudget', substr(p_qtybudget_hour, 1, instr(p_qtybudget_hour, ':') - 1));
--            --< issue(4449#1467) 10/11/2023
--            obj_data.put('flgAdd', flgAdd);
--
--            obj_data.put('coderror', '200');
--            obj_data.put('response', '');
--
--            obj_row.put(to_char(v_rcnt-1),obj_data);
--          end if;
--        end if;
--      end loop;
--
----      if v_rcnt = 0 then
----         param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'TBUDGETOT');
----        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
----        return;
----      end if;
--
--      if param_msg_error is null then
--        json_str_output := obj_row.to_clob;
--      else
--        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--      end if;
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--  end;
    -- issue 4449#1728 14/03/2024
    procedure gen_data (json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    obj_result          json_object_t;
    v_rcnt              number := 0;
    current_day         varchar(20 char);
    current_month       number;
    current_year        number;
    v_flg_disabled      boolean;
    p_dtestrt           date;
    p_dteend            date;
    flgAdd              boolean;
    v_max_yearmonth     varchar2(1000 char);

    v_date              varchar(20 char);
    present_date        varchar(20 char);
    check_loop          boolean := false;

    cursor c1 is
      select *
        from tbudgetot
       where codcomp like p_codcomp||'%'
         and dtemonth = p_budget_month
         and dteyear = p_budget_year
    order by codcomp;

    cursor c2 is
      select *
        from tbudgetot
       where codcomp like p_codcomp||'%'
         and dteyear || lpad(dtemonth, 2, 0) = v_max_yearmonth
    order by codcomp;

    begin

      select max(dteyear || lpad(dtemonth, 2 , 0))
        into v_max_yearmonth
        from tbudgetot
       where codcomp like p_codcomp||'%'
         and dteyear || lpad(dtemonth, 2, 0) <= p_budget_year || lpad(p_budget_month, 2, 0);


      obj_row := json_object_t();
      obj_data := json_object_t();
      obj_result := json_object_t();

      current_day := to_char(sysdate, 'ddmm'); -- get วันที่ เดือน ปัจจุบัน
      current_month := SUBSTR(current_day, 3); -- substr เพื่อเอาเดือนออกมา
      current_year := to_number(to_char(sysdate,'yyyy')); -- get ปีปัจจุบัน


      v_date := p_budget_year||lpad(p_budget_month, 2, 0);
      present_date := current_year||lpad(current_month, 2, 0);

      if (v_date >= present_date) then
        v_flg_disabled := true; --งวดปัจจุบันหรือมากกว่า
      else
        v_flg_disabled := false;  --งวดย้อนหลัง
      end if;

      p_dtestrt := TRUNC(SYSDATE, 'MM');
      p_dteend := TRUNC(LAST_DAY(SYSDATE));

      for r1 in c1 loop
        check_loop := true;

        if v_flg_disabled = true then
          if (p_budget_year <= r1.DTEYEAR) then
            if (p_budget_month > r1.DTEMONTH) then
              flgAdd  := true;
            else
              flgAdd  := false;
            end if;
          else
            flgAdd    := true;
          end if;
        else
          flgAdd  := false;
        end if;

        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();

        if v_flg_disabled = false then
          if secur_main.secur7(r1.codcomp, global_v_coduser) = true then
            obj_data.put('codcomp', hcm_util.get_codcomp_level(rpad(r1.codcomp,40,'0'),10));
            obj_data.put('pctbudget', r1.pctbudget);
            obj_data.put('pctabslv', r1.pctabslv);
            obj_data.put('qtymanpw', r1.qtymanpw);
            p_qtyhwork_hour := hcm_util.convert_minute_to_hour(r1.qtyhwork);
            p_qtybudget_hour := hcm_util.convert_minute_to_hour(r1.qtybudget);
            obj_data.put('qtyhwork', substr(p_qtyhwork_hour, 1, instr(p_qtyhwork_hour, ':') - 1));
            obj_data.put('qtybudget', substr(p_qtybudget_hour, 1, instr(p_qtybudget_hour, ':') - 1));
            --< issue(4449#1467) 10/11/2023
            obj_data.put('flgAdd', flgAdd);
            obj_data.put('coderror', '200');
            obj_data.put('response', '');

            obj_row.put(to_char(v_rcnt-1),obj_data);
          end if;
        else
          if secur_main.secur7(r1.codcomp, global_v_coduser) = true then
            obj_data.put('codcomp', hcm_util.get_codcomp_level(rpad(r1.codcomp,40,'0'),10));
            obj_data.put('pctbudget', r1.pctbudget);
            obj_data.put('pctabslv', r1.pctabslv);

            otbudget.get_manpw_budget(r1.codcomp, p_dtestrt, p_dteend, p_qtymanpw, p_qtyhworkall);
            otbudget.get_ot_budget(p_qtyhworkall, r1.pctbudget, r1.pctabslv, p_qtyhwork, p_qtybudget);
            obj_data.put('qtymanpw', p_qtymanpw);
            obj_data.put('qtyhworkall', hcm_util.convert_minute_to_hour(p_qtyhworkall));
            p_qtyhwork_hour := hcm_util.convert_minute_to_hour(p_qtyhwork);
            p_qtybudget_hour := hcm_util.convert_minute_to_hour(p_qtybudget);
            obj_data.put('qtyhwork', substr(p_qtyhwork_hour, 1, instr(p_qtyhwork_hour, ':') - 1));
            obj_data.put('qtybudget', substr(p_qtybudget_hour, 1, instr(p_qtybudget_hour, ':') - 1));
            obj_data.put('flgAdd', flgAdd);

            obj_data.put('coderror', '200');
            obj_data.put('response', '');

            obj_row.put(to_char(v_rcnt-1),obj_data);
          end if;
        end if;
      end loop;

      if check_loop = false then
        for r2 in c2 loop

          if v_flg_disabled = true then
            if (p_budget_year <= r2.DTEYEAR) then
              if (p_budget_month > r2.DTEMONTH) then
                flgAdd  := true;
              else
                flgAdd  := false;
              end if;
            else
              flgAdd    := true;
            end if;
          else
            flgAdd  := false;
          end if;

          v_rcnt      := v_rcnt+1;
          obj_data    := json_object_t();

          if secur_main.secur7(r2.codcomp, global_v_coduser) = true then
            obj_data.put('codcomp', hcm_util.get_codcomp_level(rpad(r2.codcomp,40,'0'),10));
            obj_data.put('pctbudget', r2.pctbudget);
            obj_data.put('pctabslv', r2.pctabslv);

            otbudget.get_manpw_budget(r2.codcomp, p_dtestrt, p_dteend, p_qtymanpw, p_qtyhworkall);
            otbudget.get_ot_budget(p_qtyhworkall, r2.pctbudget, r2.pctabslv, p_qtyhwork, p_qtybudget);

            obj_data.put('qtymanpw', p_qtymanpw);
            obj_data.put('qtyhworkall', hcm_util.convert_minute_to_hour(p_qtyhworkall));

            p_qtyhwork_hour := hcm_util.convert_minute_to_hour(p_qtyhwork);
            p_qtybudget_hour := hcm_util.convert_minute_to_hour(p_qtybudget);
            obj_data.put('qtyhwork', substr(p_qtyhwork_hour, 1, instr(p_qtyhwork_hour, ':') - 1));
            obj_data.put('qtybudget', substr(p_qtybudget_hour, 1, instr(p_qtybudget_hour, ':') - 1));
            obj_data.put('flgAdd', flgAdd);

            obj_data.put('coderror', '200');
            obj_data.put('response', '');

            obj_row.put(to_char(v_rcnt-1),obj_data);
          end if;
        end loop;
      end if;

      if param_msg_error is null then
        json_str_output := obj_row.to_clob;
      else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  -- issue 4449#1728 14/03/2024

  procedure get_detail_data (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_man_pw_data (json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then

      p_dtestrt := TRUNC (SYSDATE, 'MM');
      p_dteend := TRUNC(LAST_DAY(SYSDATE));
      otbudget.get_manpw_budget(p_codcomp, p_dtestrt, p_dteend, p_qtymanpw, p_qtyhworkall);
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('response', '');
      obj_data.put('qtymanpw', nvl(p_qtymanpw, 0));
      --> issue(4449#1467) 10/11/2023
      p_qtyhwork_hour := hcm_util.convert_minute_to_hour(p_qtyhworkall);
      obj_data.put('qtyhwork', substr(p_qtyhwork_hour, 1, instr(p_qtyhwork_hour, ':') - 1));
--      obj_data.put('qtyhwork', hcm_util.convert_minute_to_hour(p_qtyhworkall));
      --< issue(4449#1467) 10/11/2023
      obj_data.put('qtyhworkall', p_qtyhworkall);
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_ot_budget_data (json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      otbudget.get_ot_budget(p_qtyhworkall, p_pctbudget, p_pctabslv, p_qtyhwork, p_qtybudget);
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('response', '');
      --> issue(4449#1467) 10/11/2023
--      obj_data.put('qtyhwork', hcm_util.convert_minute_to_hour(p_qtyhwork));
--      obj_data.put('qtybudget', hcm_util.convert_minute_to_hour(p_qtybudget));
      p_qtyhwork_hour := hcm_util.convert_minute_to_hour(p_qtyhwork);
      p_qtybudget_hour := hcm_util.convert_minute_to_hour(p_qtybudget);
      obj_data.put('qtyhwork', substr(p_qtyhwork_hour, 1, instr(p_qtyhwork_hour, ':') - 1));
      obj_data.put('qtybudget', substr(p_qtybudget_hour, 1, instr(p_qtybudget_hour, ':') - 1));
      --< issue(4449#1467) 10/11/2023
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_detail_data(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    save_data_table(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail_data;

  procedure save_data_table(json_str_output out clob) is
    obj_data           json_object_t;
    v_flgAdd           boolean;
    v_flgEdit          boolean;
    v_flgDelete        boolean;
    v_codcomp          tbudgetot.codcomp%type;
    v_pctbudget        tbudgetot.pctbudget%type;
    v_pctabslv         tbudgetot.pctabslv%type;
    v_qtymanpw         tbudgetot.qtymanpw%type;
    v_qtyhwork         tbudgetot.qtyhwork%type;
    v_qtybudget        tbudgetot.qtybudget%type;
    v_comlevel         tcenter.comlevel%type;

    v_first_day        date;
    v_last_day         date;
    v_qtyotESS         number := 0;
    v_qtyot_AL         number := 0;
    v_qtyot_AL2        number := 0;

    type validate_time IS TABLE OF varchar2(1000 char) INDEX BY BINARY_INTEGER;
    v_codcomp_check                validate_time;

    type type_flg IS TABLE OF boolean INDEX BY BINARY_INTEGER;
    v_flg_del_check                type_flg;

  begin
    for i in 0..param_json.get_size-1 loop
      obj_data         := hcm_util.get_json_t(param_json, to_char(i));
      v_flgAdd         := hcm_util.get_boolean_t(obj_data, 'flgAdd');
      v_flgEdit        := hcm_util.get_boolean_t(obj_data, 'flgEdit');
      v_flgDelete      := hcm_util.get_boolean_t(obj_data, 'flgDelete');

      v_codcomp              := hcm_util.get_string_t(obj_data, 'codcomp');
      v_codcomp_check(i)     := v_codcomp;
      v_flg_del_check(i)     := v_flgDelete;

--      v_pctbudget      := hcm_util.get_string_t(obj_data, 'pctbudget');
--      v_pctabslv       := hcm_util.get_string_t(obj_data, 'pctabslv');
      --> issue(4449#1468) 14/11/2023
--      v_pctbudget      := to_char(TO_NUMBER(replace(hcm_util.get_string_t(obj_data, 'pctbudget'),',','')), 'FM999,999,999,990.00');
      v_pctbudget      := TO_NUMBER(hcm_util.get_string_t(obj_data, 'pctbudget'));
      --< issue(4449#1468) 14/11/2023
      v_pctabslv       := to_char(TO_NUMBER(replace(hcm_util.get_string_t(obj_data, 'pctabslv'),',','')), 'FM999,999,999,990.00');
      v_qtymanpw       := hcm_util.get_string_t(obj_data, 'qtymanpw');
      --> issue(4449#1468) 14/11/2023
--      v_qtyhwork       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(obj_data, 'qtyhwork'));
--      v_qtybudget      := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(obj_data, 'qtybudget'));
      --< issue(4449#1468) 14/11/2023
      v_qtyhwork       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(obj_data, 'qtyhwork') || ':00');
      v_qtybudget      := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(obj_data, 'qtybudget') || ':00');


      if i <> 0 and v_flgDelete <> true then
        for j in 0..(i-1) loop
          if (v_codcomp_check(j) = v_codcomp) and v_flg_del_check(j) <> true then
            param_msg_error := get_error_msg_php('HR1503', global_v_lang);
          end if;
        end loop;
      end if;

      begin
        begin
          select comlevel
            into v_comlevel
            from tcenter
--           where codcomp = v_codcomp; issue4448#9976
           where codcomp like v_codcomp||'%'
             and rownum = 1
        order by codcomp;
        end;

        if v_comlevel < 3 and v_flgDelete <> true then
          param_msg_error := get_error_msg_php('ESZ001',global_v_lang);
        end if;

        if v_qtymanpw = 0 and v_flgDelete <> true then
          param_msg_error := get_error_msg_php('ESZ002',global_v_lang);
        end if;

        if (v_flgAdd = true and v_flgDelete <> true) or v_flgEdit = true then
          begin
            insert into tbudgetot (dteyear, dtemonth, codcomp, pctbudget, pctabslv, qtymanpw, qtyhwork, qtybudget, codcreate, coduser)
                 values (p_budget_year, p_budget_month, v_codcomp, v_pctbudget, v_pctabslv, v_qtymanpw, v_qtyhwork, v_qtybudget, global_v_coduser, global_v_coduser);
         exception when dup_val_on_index then
            update tbudgetot
               set pctbudget = v_pctbudget,
                   pctabslv  = v_pctabslv,
                   qtymanpw  = v_qtymanpw,
                   qtyhwork  = v_qtyhwork,
                   qtybudget = v_qtybudget,
                   coduser   = global_v_coduser
             where dteyear  = p_budget_year
               and dtemonth = p_budget_month
               and codcomp  = v_codcomp;
          end;
        end if;

        if v_flgDelete = true and v_flgAdd <> true then

          v_first_day := TO_DATE('01-' || p_budget_month || '-' || p_budget_year, 'DD-MM-YYYY');
          -- หาวันที่สุดท้ายของเดือนจากวันที่ 1
          v_last_day := last_day(v_first_day);

          begin
            select sum(nvl(b.qtyminot, a.qtyotreq))
              into v_qtyotESS
              from TTOTREQ a, TOVRTIME b
             where a.codcompbg = v_codcomp
               and a.dtestrt between v_first_day and v_last_day
               and a.staappr in ('P', 'A', 'Y')
               and a.numotreq = b.numotreq (+)
               and to_char(a.dtereq,'yyyymmdd')||lpad(a.numseq,3,'0') = (
                  select max(to_char(c.dtereq,'yyyymmdd')||lpad(c.numseq,3,'0'))
                    from TTOTREQ c
                   where a.codempid = c.codempid
                     and a.dtestrt = c.dtestrt
                   );
          exception when no_data_found then
            v_qtyotESS := 0;
          end;

          begin
            select nvl(sum(nvl(b.qtyminot, a.qtyotreq)), 0)
              into v_qtyot_AL
              from TOTREQD a, TOVRTIME b
             where otbudget.get_codcompbg(nvl(a.codcompw, a.codcomp), a.dtewkreq) = v_codcomp
               and a.dtewkreq between v_first_day and v_last_day
               and a.numotreq = b.numotreq (+)
               and a.codempid = b.codempid ( +)
               and a.dtewkreq = b.dtework ( +)
               and a.typot = b.typot ( +)
               and not exists (select c.numotreq
                                 from TTOTREQ c
                                where c.numotreq = a.numotreq)
                                  and a.numotreq = (Select max(c.numotreq)
                                                      from TOTREQD c
                                                     where a.codempid = c.codempid
                                                       and a.dtewkreq = c.dtewkreq
                                                       and a.typot = c.typot
            );
          exception when no_data_found then
            v_qtyot_AL := 0;
          end;

          begin
            select nvl(sum(qtyminot), 0)
              into v_qtyot_AL2
              from TOVRTIME
             where otbudget.get_codcompbg(nvl(codcompw, codcomp), dtework) = v_codcomp
               and dtework between v_first_day and v_last_day
               and numotreq is null;
          exception when no_data_found then
            v_qtyot_AL2 := 0;
          end;

          if nvl(v_qtyotESS,0) + nvl(v_qtyot_AL,0) + nvl(v_qtyot_AL2,0) > 0 then
            param_msg_error := get_error_msg_php('COZ005',global_v_lang);
          else
            begin
              delete tbudgetot
               where dteyear  = p_budget_year
                 and dtemonth = p_budget_month
                 and codcomp  = v_codcomp;
            end;
          end if;

        end if;
      end;
    end loop;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_data_table;

END M_HRESZ1E;

/

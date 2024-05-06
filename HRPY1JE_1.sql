--------------------------------------------------------
--  DDL for Package Body HRPY1JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY1JE" as
  procedure initial_value(json_str_input in clob) is
      json_obj json_object_t;
  begin
      json_obj          := json_object_t(json_str_input);
      global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
      global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
      global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

      p_codcomp       := hcm_util.get_string_t(json_obj,'codcomp');
      p_codempid      := hcm_util.get_string_t(json_obj,'codempid');

      hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
      v_temp varchar2(1 char);
  begin
      -- ฟิลด์ที่บังคับใส่ข้อมูล รหัสหน่วยงาน หรือ รหัสพนักงาน
      if p_codcomp is null and p_codempid is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
      -- รหัสหน่วยงาน
      if p_codcomp is not null then
          -- ตรวจสอบรหัสต้องมีอยู่ในตาราง TCENTER (HR2010 TCENTER)
          begin
              select 'X' into v_temp
              from tcenter
              where
                  codcomp like p_codcomp||'%' and
                  rownum = 1;
          exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
              return;
          end;
          -- ตรวจสอบ Secure (HR3007)
          param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
          if param_msg_error is not null then
              return;
          end if;
      end if;
      -- รหัสพนักงาน
      if p_codempid is not null then
          -- ตรวจสอบรหัสต้องมีอยู่ในตาราง TEMPLOY1 (HR2010 TEMPLOY1)
          begin
              select 'X' into v_temp
              from temploy1
              where codempid = p_codempid;
          exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
              return;
          end;

          -- ตรวจสอบ Secure เรียก secur_main.secur2 (HR3007)
          if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
              param_msg_error := get_error_msg_php('HR3007',global_v_lang);
              return;
          end if;
      end if;
  end;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
      obj_row   json_object_t;
      obj_data  json_object_t;
      v_row     number :=0;
      v_secur   boolean;

      cursor c1 is
        select distinct a.codempid,b.codcomp,b.codpos,numprdst,dtemthst,dteyearst,numprden,dtemthen,dteyearen
          from tcostemp a,temploy1 b
         where a.codempid = b.codempid and
               b.codcomp like nvl(p_codcomp,b.codcomp)||'%' and
               a.codempid = nvl(p_codempid,a.codempid)
         order by a.codempid,dteyearst,dtemthst,numprdst;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      obj_row := json_object_t();
      for i in c1 loop
        -- ตรวจสอบ Secure เรียก secur_main.secur2 (HR3007)
        v_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_secur = true then
          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('codempid',i.codempid);
          obj_data.put('image',get_emp_img(i.codempid));
          obj_data.put('namemp',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('codcomp',i.codcomp);
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
          obj_data.put('codpos',i.codpos);
          obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
          obj_data.put('numprdst',i.numprdst);
          obj_data.put('dtemthst',i.dtemthst);
          obj_data.put('desc_dtemthst',get_nammthful(i.dtemthst,global_v_lang));
          obj_data.put('dteyearst',i.dteyearst);
          obj_data.put('numprden',i.numprden);
          obj_data.put('dtemthen',i.dtemthen);
          obj_data.put('desc_dtemthen',get_nammthful(i.dtemthen,global_v_lang));
          obj_data.put('dteyearen',i.dteyearen);
          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      json_str_output := obj_row.to_clob;
      return;
    end if;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure check_get_detail(v_numprdst number,v_dtemthst number,v_dteyearst number) as
      v_temp varchar2(1 char);
      v_secur boolean;
  begin
      -- ฟิลด์ที่บังคับใส่ข้อมูล รหัสพนักงาน,งวด,เดือน,ปี
      if p_codempid is null or v_numprdst is null or v_dtemthst is null or v_dteyearst is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
      -- รหัสพนักงาน ตรวจสอบรหัสต้องมีอยู่ในตาราง TEMPLOY1 (HR2010 TEMPLOY1)
      begin
          select 'X' into v_temp
          from temploy1
          where codempid = p_codempid;
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
          return;
      end;
      -- ตรวจสอบ Secure เรียก secur_main.secur2 (HR3007)
      v_secur := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur = false then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          return;
      end if;
  end;
  --
  procedure get_detail(json_str_input in clob,json_str_output out clob) as
    json_obj json_object_t;
    v_codempid  varchar2(10 char);
    v_numprdst  number(2,0);
    v_dtemthst  number(2,0);
    v_dteyearst number(4,0);
    v_numprden  number(2,0);
    v_dtemthen  number(2,0);
    v_dteyearen number(4,0);
    v_flgEdit   varchar2(10 char);
    v_codcompy  varchar2(10 char);

    obj_result  json_object_t;
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_row       number :=0;

    cursor c1 is
        select * from tcostemp
        where codempid = v_codempid and
              numprdst   = v_numprdst and
              dtemthst   = v_dtemthst and
              dteyearst  = v_dteyearst and
              numprden   = v_numprden and
              dtemthen   = v_dtemthen and
              dteyearen  = v_dteyearen
        order by codpay;

    cursor c2 is
        select dteyearen,dtemthen,numprden from tcostemp
        where codempid = v_codempid
          and numprdst = v_numprdst
          and dtemthst = v_dtemthst
          and dteyearst = v_dteyearst;
  begin
      initial_value(json_str_input);
      json_obj          := json_object_t(json_str_input);
      v_codempid  := hcm_util.get_string_t(json_obj,'codempid');
      v_numprdst  := to_number(hcm_util.get_string_t(json_obj,'numprdst'));
      v_dtemthst  := to_number(hcm_util.get_string_t(json_obj,'dtemthst'));
      v_dteyearst := to_number(hcm_util.get_string_t(json_obj,'dteyearst'));
      v_numprden  := to_number(hcm_util.get_string_t(json_obj,'numprden'));
      v_dtemthen  := to_number(hcm_util.get_string_t(json_obj,'dtemthen'));
      v_dteyearen := to_number(hcm_util.get_string_t(json_obj,'dteyearen'));
      v_flgEdit   := to_number(hcm_util.get_string_t(json_obj,'flgEdit'));
      if v_numprden is null then
        for g in c2 loop
          v_numprden  := g.numprden;
          v_dtemthen  := g.dtemthen;
          v_dteyearen := g.dteyearen;
          exit;
        end loop;
      end if;
      if param_msg_error is null then
        begin
          select get_codcompy(codcomp) into v_codcompy
            from temploy1 
           where codempid = v_codempid;
        exception when no_data_found then
          v_codcompy := '';
        end;
        obj_data  := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid',v_codempid);
        obj_data.put('numprdst',v_numprdst);
        obj_data.put('dtemthst',v_dtemthst);
        obj_data.put('dteyearst',v_dteyearst);
        obj_data.put('numprden',v_numprden);
        obj_data.put('dtemthen',v_dtemthen);
        obj_data.put('dteyearen',v_dteyearen);
        obj_data.put('codcompy',v_codcompy);
        json_str_output := obj_data.to_clob;
      else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;
  --
  procedure get_detail_table(json_str_input in clob,json_str_output out clob) as
      json_obj json_object_t;
      v_codempid  varchar2(10 char);
      v_numprdst  number(2,0);
      v_dtemthst  number(2,0);
      v_dteyearst number(4,0);
      v_numprden  number(2,0);
      v_dtemthen  number(2,0);
      v_dteyearen number(4,0);
      v_flgEdit   varchar2(10 char);

      obj_result  json_object_t;
      obj_row     json_object_t;
      obj_data    json_object_t;
      v_row       number :=0;

    cursor c1 is
      select CODCOMP,CODPAY,COSTCENT,PCTCHG 
        from tcostemp
       where codempid = v_codempid 
         and numprdst = v_numprdst 
         and dtemthst = v_dtemthst 
         and dteyearst = v_dteyearst 
         and numprden = v_numprden 
         and dtemthen = v_dtemthen 
         and dteyearen = v_dteyearen
       order by codpay;

    cursor c2 is
        select dteyearen,dtemthen,numprden from tcostemp
        where codempid = v_codempid
          and numprdst = v_numprdst
          and dtemthst = v_dtemthst
          and dteyearst = v_dteyearst;
  begin
      initial_value(json_str_input);
      json_obj          := json_object_t(json_str_input);
      v_codempid  := hcm_util.get_string_t(json_obj,'codempid');
      v_numprdst  := to_number(hcm_util.get_string_t(json_obj,'numprdst'));
      v_dtemthst  := to_number(hcm_util.get_string_t(json_obj,'dtemthst'));
      v_dteyearst := to_number(hcm_util.get_string_t(json_obj,'dteyearst'));
      v_numprden  := to_number(hcm_util.get_string_t(json_obj,'numprden'));
      v_dtemthen  := to_number(hcm_util.get_string_t(json_obj,'dtemthen'));
      v_dteyearen := to_number(hcm_util.get_string_t(json_obj,'dteyearen'));

      if v_numprden is null then
          for g in c2 loop
              v_numprden  := g.numprden;
              v_dtemthen  := g.dtemthen;
              v_dteyearen := g.dteyearen;
              exit;
          end loop;
      end if;
      check_get_detail(v_numprdst,v_dtemthst,v_dteyearst);
      if param_msg_error is null then
          obj_row := json_object_t();
          for i in c1 loop
              v_row := v_row + 1;
              obj_data := json_object_t();
              obj_data.put('codpay',i.codpay);
              obj_data.put('codcomp',case when i.codcomp = '%' then '' else i.codcomp end );
              obj_data.put('costcent',i.costcent);
              obj_data.put('desc_costcent',get_tcoscent_name(i.costcent,global_v_lang));
              obj_data.put('pctchg',i.pctchg);
              obj_row.put(to_char(v_row-1),obj_data);
          end loop;
          json_str_output := obj_row.to_clob;
          return;
      end if;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_table;
  --
  procedure save_index(json_str_input in clob,json_str_output out clob) as
      json_obj    json_object_t;
      obj_data    json_object_t;
      v_codempid  varchar2(10 char);
      v_numprdst  number(2,0);
      v_dtemthst  number(2,0);
      v_dteyearst number(4,0);
      v_numprden  number(2,0);
      v_dtemthen  number(2,0);
      v_dteyearen number(4,0);
      v_flgEdit   varchar2(10 char);

  begin
      initial_value(json_str_input);
      json_obj        := json_object_t(json_str_input);
      param_json      := hcm_util.get_json_t(json_obj,'param_json');
      for i in 0..param_json.get_size-1 loop
          obj_data    := hcm_util.get_json_t(param_json,to_char(i));
          v_codempid  := hcm_util.get_string_t(obj_data,'codempid');
          v_numprdst  := to_number(hcm_util.get_string_t(obj_data,'numprdst'));
          v_dtemthst  := to_number(hcm_util.get_string_t(obj_data,'dtemthst'));
          v_dteyearst := to_number(hcm_util.get_string_t(obj_data,'dteyearst'));
          v_numprden  := to_number(hcm_util.get_string_t(obj_data,'numprden'));
          v_dtemthen  := to_number(hcm_util.get_string_t(obj_data,'dtemthen'));
          v_dteyearen := to_number(hcm_util.get_string_t(obj_data,'dteyearen'));

          delete from tcostemp
          where
              codempid = v_codempid and
              numprdst = v_numprdst and
              dtemthst = v_dtemthst and
              dteyearst = v_dteyearst;

      end loop;

      if param_msg_error is null then
          commit;
          param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      else
          rollback;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;

  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;
  --
  procedure validate_save_1(v_codempid varchar2, 
                            v_numprdst number,v_dtemthst number,v_dteyearst number,
                            v_numprden number,v_dtemthen number,v_dteyearen number,
                            obj_param json_object_t) as
      mix_str         number := 0;
      mix_end         number := 0;
      v_sumPct        number := 0;
      v_pctchg        number := 0;
      v_pct_del       number := 0;
      v_total_pctchg  number := 0;
      v_flgEdit       varchar2(10 char);
      v_flg           varchar2(10 char);
      obj_data        json_object_t;
  begin
      -- ฟิลด์ที่บังคับใส่ข้อมูล งวดที่สิ้นสุด,เดือนที่สิ้นสุด,ปีที่สิ้นสุด
      if v_numprden is null or v_dtemthen is null or v_dteyearen is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numprden');
          return;
      end if;
      -- งวด/เดือน/ปี สิ้นสุด ห้ามน้อยกว่า เริ่มต้น
      mix_str := v_dteyearst||lpad(v_dtemthst,2,0)||lpad(v_numprdst,2,0);
      mix_end := v_dteyearen||lpad(v_dtemthen,2,0)||lpad(v_numprden,2,0);
      if mix_end < mix_str then
          param_msg_error := get_error_msg_php('HR2022',global_v_lang);
          return;
      end if;
--      begin
--        select sum(pctchg) into v_total_pctchg
--          from tcostemp
--         where codempid = v_codempid 
--           and numprdst = v_numprdst 
--           and dtemthst = v_dtemthst 
--           and dteyearst = v_dteyearst 
--           and numprden = v_numprden 
--           and dtemthen = v_dtemthen 
--           and dteyearen = v_dteyearen;
--      exception when no_data_found then
--        v_total_pctchg :=  0;
--      end;
--      for i in 0..obj_param.get_size-1 loop
--        obj_data    := hcm_util.get_json_t(obj_param,to_char(i));
--        v_pctchg    := to_number(hcm_util.get_string_t(obj_data,'pctchg'));
--        v_flg       := hcm_util.get_string_t(obj_data,'flg');
--        if v_flg = 'add' or v_flg = 'edit' then
--          v_flgEdit := 'Y';
--          v_sumPct := v_sumPct + v_pctchg;
--        elsif v_flg = 'delete' then
--          v_pct_del := v_pct_del + v_pctchg;
--        end if;
--      end loop;
--      if v_sumPct != 100 and v_flgEdit = 'Y' then
--        param_msg_error := get_error_msg_php('PY0015',global_v_lang);
--      end if;
  end;
  --
  procedure validate_save_2(v_numprdst number,v_dtemthst number,v_dteyearst number,v_numprden number,v_dtemthen number,
                            v_dteyearen number,v_codpay varchar2,v_pctchg number,v_codcomp varchar2,
                            v_isMatchChg varchar2,v_codempid varchar2,v_flgEdit varchar2) as
      mix_str number := 0;
      mix_end number := 0;
      c_mix_str number := 0;
      c_mix_end number := 0;
      v_temp varchar2(1 char);
      v_count number := 0;
      v_check boolean := true;
      v_codcompy  tinexinfc.codcompy%type;

      cursor c1 is
          select * from tcostemp
          where
              codempid = v_codempid and
              codpay = v_codpay and
              dteyearst||lpad(dtemthst,2,0)||lpad(numprdst,2,0) <> v_dteyearst||lpad(v_dtemthst,2,0)||lpad(v_numprdst,2,0)
          order by codpay;
  begin
      -- ฟิลด์ที่บังคับใส่ข้อมูล รายได้,วิธีการ charge,% ที่ charge
--      if v_codpay is null or v_flgcharge is null or (v_flgcharge = '1' and v_pctchg is null) then
--          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--          return;
--      end if;
      -- ถ้าเลือกวิธีการ Charge = กาหนดขึ้นใหม่ ให้บังคับใส่ข้อมูล “Charge ที่หน่วยงาน” ด้วย (HR2045)
--      if v_flgcharge = '1' and v_codcomp is null then
--          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--          return;
--      end if;

      if v_flgEdit = 'add' or v_flgEdit = 'edit' or v_flgEdit is null then
          -- ในรหัสรายได้เดียวกัน เลือกได้แค่แบบใดแบบหนึ่งเท่านั้น แจ้งเตือน “PY0054 - ต่อหนึ่งรหัสรายได้ สามารถเลือกวิธีการ Charge ได้แบบใดแบบหนึ่งเท่านั้น”
--          if v_isMatchChg = 'N' then
--              param_msg_error := get_error_msg_php('PY0054',global_v_lang);
--  --                param_msg_error := 'PY0054 ต่อหนึ่งรหัสรายได้ สามารถเลือกวิธีการ Charge ได้แบบใดแบบหนึ่งเท่านั้น@#$%';
--              return;
--          end if;
          -- กรณีเลือกวิธีการ Charge = ตามวันที่ปฏิบัติงาน จะมีแค่ 1 รายการเท่านั้น (HR2005)
--          if v_isDupFlgChg2 = 'Y' then
--              param_msg_error := get_error_msg_php('HR2005',global_v_lang);
--              return;
--          end if;
          -- งวด/เดือน/ปี สิ้นสุด ห้ามน้อยกว่า เริ่มต้น
          mix_str := v_dteyearst||lpad(v_dtemthst,2,0)||lpad(v_numprdst,2,0);
          mix_end := v_dteyearen||lpad(v_dtemthen,2,0)||lpad(v_numprden,2,0);
          if mix_end < mix_str then
              param_msg_error := get_error_msg_php('HR2022',global_v_lang);
              return;
          end if;
          -- รหัสรายได้เดียวกัน จะต้องไม่คร่อมกับ งวด/เดือน/ปี ของรายการอื่น แจ้งเตือน (HR2507)
          for i in c1 loop
              c_mix_str := i.dteyearst||lpad(i.dtemthst,2,0)||lpad(i.numprdst,2,0);
              c_mix_end := i.dteyearen||lpad(i.dtemthen,2,0)||lpad(i.numprden,2,0);
              -- case 1
              if mix_str > c_mix_str and mix_end < c_mix_end then
                  v_check := false;
                  exit;
              end if;
              -- case 2
              if mix_end > c_mix_str and mix_end < c_mix_end then
                  v_check := false;
                  exit;
              end if;
              -- case 3
              if mix_str < c_mix_end and mix_end > c_mix_end then
                  v_check := false;
                  exit;
              end if;
              -- case 4
              if mix_str < c_mix_str and mix_end > c_mix_end then
                  v_check := false;
                  exit;
              end if;
              -- case 5
              if mix_str = c_mix_end or mix_end = c_mix_str then
                  v_check := false;
                  exit;
              end if;
          end loop;
          if v_check = false then
              param_msg_error := get_error_msg_php('HR2507',global_v_lang);
              return;
          end if;

          -- รหัสรายได้ จะต้องมีอยู่จริงในตาราง TINEXINF (HR2010)
          begin
              select 'X' into v_temp
              from tinexinf
              where codpay = v_codpay;
          exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TINEXINF');
              return;
          end;
          -- จะต้องใช้รหัสของบริษัทตนเองเท่านั้น ตรวจสอบจากตาราง TINEXINFC แจ้งเตือน “PY0044 - รหัสที่ระบุไม่สามารถใช้กับบริษัทนี้”
--          if v_flgcharge = '1' then
--              begin
--                  select get_codcompy(codcomp) into v_codcompy
--                  from temploy1
--                  where codempid = p_codempid;
--              exception when no_data_found then
--                  v_codcompy := null;
--              end;
--              begin
--                  select 'X' into v_temp
--                  from tinexinfc
--                  where
--                      codpay = v_codpay and
--                      codcompy = v_codcompy;
--              exception when no_data_found then
--                  param_msg_error := get_error_msg_php('PY0044',global_v_lang,v_codpay||' - '||get_tinexinf_name(v_codpay,global_v_lang));
--                  return;
--              end;
--          end if;
          -- รหัสหน่วยงาน จะต้องมีอยู่จริงในตาราง TCENTER (HR2010)
--          if v_flgcharge = '1' then
--              begin
--                  select 'X' into v_temp
--                  from tcenter
--                  where codcomp like v_codcomp||'%'
--                  fetch first 1 rows only;
--              exception when no_data_found then
--                  param_msg_error := get_error_msg_php('HR2010',global_v_lang,v_codcomp);
--                  return;
--              end;
--          end if;
          -- ตรวจสอบ Secure (HR3007)
          param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, v_codcomp);
          if param_msg_error is not null then
              return;
          end if;
          -- แต่ละรหัสรายได้ อัตรา % ที่ Charge จะต้องได้เท่ากับ 100 แจ้งเตือน PY0015
--          if nvl(v_sumPct,0) != 100 and (v_flgcharge = '1' or ( nvl(v_sumPct,0) > 0 and v_flgcharge = '2')) then
--              param_msg_error := get_error_msg_php('PY0015',global_v_lang);
--              return;
--          end if;
      end if; -- end v_flgEdit = 'Add','Edit'

      if v_flgEdit = 'add' then
          -- ตรวจสอบ การ Dup ของ PK : กรณีรหัสซ้า (HR2005 TCOSTEMP)
          begin
            select count(*) into v_count
            from tcostemp
            where codempid = v_codempid 
            and dteyearst = v_dteyearst 
            and dtemthst = v_dtemthst 
            and numprdst = v_numprdst 
            and codpay = v_codpay 
            and codcomp like v_codcomp||'%';
          exception when others then null;
          end;
          if v_count > 0 then
              param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TCOSTEMP');
              return;
          end if;
      end if; -- end v_flgEdit = 'Add'
  end;

  procedure save_detail(json_str_input in clob,json_str_output out clob) as
      json_obj    json_object_t;
      obj_data    json_object_t;
      obj_param   json_object_t;
      v_codempid  varchar2(10 char);
      v_numprdst  number(2,0);
      v_dtemthst  number(2,0);
      v_dteyearst number(4,0);
      v_numprden  number(2,0);
      v_dtemthen  number(2,0);
      v_dteyearen number(4,0);
      v_fldEditM  varchar2(10 char);

      v_codpay    varchar2(4 char);
      v_flgcharge varchar2(1 char);
      v_codcomp   varchar2(40 char);
      v_costcent  varchar2(25 char);
      v_pctchg    number(5,2);
      v_remark    varchar2(500 char);
      v_flgEdit   varchar2(10 char);
      v_isMatchChg      varchar2(1 char);
      v_sumPct          number(5,2) := 0;
      v_total_pctchg    number(5,2) := 0;
  begin
      initial_value(json_str_input);
      obj_param   :=  json_object_t(json_str_input);
      json_obj    := json_object_t(hcm_util.get_json_t(json_object_t(obj_param),'detail'));
      v_codempid  := hcm_util.get_string_t(json_obj,'codempid');
      v_numprdst  := to_number(hcm_util.get_string_t(json_obj,'numprdst'));
      v_dtemthst  := to_number(hcm_util.get_string_t(json_obj,'dtemthst'));
      v_dteyearst := to_number(hcm_util.get_string_t(json_obj,'dteyearst'));
      v_numprden  := to_number(hcm_util.get_string_t(json_obj,'numprden'));
      v_dtemthen  := to_number(hcm_util.get_string_t(json_obj,'dtemthen'));
      v_dteyearen := to_number(hcm_util.get_string_t(json_obj,'dteyearen'));
      v_fldEditM   := hcm_util.get_string_t(json_obj,'flgEdit');

      param_json      := hcm_util.get_json_t(obj_param,'param_json');
      validate_save_1(v_codempid,v_numprdst,v_dtemthst,v_dteyearst,v_numprden,v_dtemthen,v_dteyearen,param_json);

      if param_msg_error is null then
          for i in 0..param_json.get_size-1 loop
              obj_data    := hcm_util.get_json_t(param_json,to_char(i));
              v_codpay    := hcm_util.get_string_t(obj_data,'codpay');
              v_codcomp   := nvl(hcm_util.get_string_t(obj_data,'codcomp'),'%');
              v_costcent  := hcm_util.get_string_t(obj_data,'costcent');
              v_pctchg    := to_number(hcm_util.get_string_t(obj_data,'pctchg'));
              v_remark    := hcm_util.get_string_t(obj_data,'remark');
              v_flgEdit   := hcm_util.get_string_t(obj_data,'flg');
              v_isMatchChg    := hcm_util.get_string_t(obj_data,'isMatchChg');
--              if v_fldEditM = 'Edit' and v_flgEdit is null then
--                  v_flgEdit := 'Edit';
--              end if;
              -- validate save
              validate_save_2(v_numprdst,v_dtemthst,v_dteyearst,v_numprden,v_dtemthen,v_dteyearen,
                                  v_codpay,v_pctchg,v_codcomp,v_isMatchChg,v_codempid,v_flgEdit);
              if param_msg_error is not null then
                exit;
              end if;

              if v_flgEdit = 'add' then
                insert into tcostemp (codempid, numprdst, dtemthst, dteyearst, numprden, dtemthen, 
                                       dteyearen, codpay, flgcharge, codcomp, costcent, pctchg, remark, codcreate, coduser)
                     values (v_codempid, v_numprdst, v_dtemthst, v_dteyearst, v_numprden, v_dtemthen, 
                             v_dteyearen, v_codpay, v_flgcharge, v_codcomp, v_costcent, v_pctchg, v_remark, global_v_coduser, global_v_coduser);
              elsif v_flgEdit = 'edit' then
                  update tcostemp set
                      numprden  = v_numprden,
                      dtemthen  = v_dtemthen,
                      dteyearen = v_dteyearen,
                      pctchg    = v_pctchg,
                      remark    = v_remark,
                      coduser   = global_v_coduser
                  where
                      codempid = v_codempid and
                      numprdst = v_numprdst and
                      dtemthst = v_dtemthst and
                      dteyearst = v_dteyearst and
                      codpay = v_codpay and
                      codcomp like v_codcomp||'%';
              elsif v_flgEdit = 'delete' then
                  delete from tcostemp
                  where
                      codempid = v_codempid and
                      numprdst = v_numprdst and
                      dtemthst = v_dtemthst and
                      dteyearst = v_dteyearst and
                      codpay = v_codpay and
                      codcomp like v_codcomp||'%';
              end if;
          end loop;
          begin
            select count(sum(pctchg)) into v_total_pctchg
              from tcostemp
             where codempid = v_codempid
               and numprdst = v_numprdst
               and dtemthst = v_dtemthst
               and dteyearst = v_dteyearst
               and numprden = v_numprden
               and dtemthen = v_dtemthen
               and dteyearen = v_dteyearen
            group by codpay
            having sum(pctchg) <> 100;
          exception when no_data_found then
            v_total_pctchg :=  0;
          end;
--          if v_total_pctchg != 100 and param_msg_error is null then
          if v_total_pctchg > 0 and param_msg_error is null then
            param_msg_error := get_error_msg_php('PY0015',global_v_lang);
          end if;
          if param_msg_error is null then
              commit;
              param_msg_error := get_error_msg_php('HR2401',global_v_lang);
              json_str_output := get_response_message(null,param_msg_error,global_v_lang);
              return;
          else
              rollback;
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
          end if;
      end if;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  exception when others then
      rollback;
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;

  procedure get_name_costcent(json_str_input in clob,json_str_output out clob) as
      json_obj    json_object_t;
      obj_result  json_object_t;
      obj_data    json_object_t;
      v_codcomp   varchar2(40 char);
      v_costcent  varchar2(25 char);
  begin
      initial_value(json_str_input);
      json_obj    := json_object_t(json_str_input);
      v_codcomp  := hcm_util.get_string_t(json_obj,'codcomp');
      begin
          select costcent into v_costcent
          from tcenter
          where codcomp like v_codcomp||'%'
          order by codcomp
          fetch first 1 row only;
      exception when no_data_found then
          v_costcent := '';
      end;
      obj_result := json_object_t();
      obj_data := json_object_t();
      obj_data.put('costcent',v_costcent);
      obj_data.put('desc_costcent',get_tcoscent_name(v_costcent,global_v_lang));
      obj_result.put('0',obj_data);
      json_str_output := obj_result.to_clob;
      return;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_name_costcent;

end hrpy1je;

/

--------------------------------------------------------
--  DDL for Package Body HRPYC1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYC1E" as
  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcompy      := hcm_util.get_string_t(json_obj,'codcompy');
    p_typretmt      := hcm_util.get_string_t(json_obj,'typretmt');
    p_flgretire     := hcm_util.get_string_t(json_obj,'flgretire');
    p_dteeffec      := to_date(hcm_util.get_string_t(json_obj,'dteeffec'),'DD/MM/YYYY');

  end;

  procedure check_index as
    v_temp varchar2(1 char);
  begin
    -- ฟิลด์ที่บังคับใส่ข้อมูล รหัสบริษัท,ประเภทการพ้นสภาพ,วันที่มีผลบังคับใช้
    if p_codcompy is null or p_typretmt is null or p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    -- รหัสบริษัท
    if p_codcompy is not null then
      -- ตรวจสอบรหัสต้องมีอยู่ในตาราง TCOMPNY (HR2010 TCOMPNY)
      begin
        select 'X' into v_temp
        from tcompny
        where codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
        return;
      end;
      -- ตรวจสอบ Secure (HR3007)
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    -- ประเภทการพ้นสภาพ ตรวจสอบรหัสต้องมีอยู่ในตาราง TCODRETM (HR2010 TCODRETM)
    if p_typretmt is not null then
      begin
        select 'X' into v_temp
        from tcodretm
        where codcodec = p_typretmt;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODRETM');
        return;
      end;
    end if;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
      obj_row           json_object_t;
      obj_data          json_object_t;
      v_row             number :=0;
      v_count           number := 0;
      v_dteeffec        date;
      v_warning         varchar2(150 char) := '';
      v_maxdteeffec     date;
      v_flgAdd          boolean := false;

      cursor c1 is
          select codcompy, dteeffec, typretmt, numseq, qtyyrest, qtymthst,
                 qtydayst, qtyyreen, qtymthen, qtydayen, ratepay,
                 to_char(dteupd,'DD/MM/YYYY') dteupd, coduser
            from tretirmt
           where codcompy = p_codcompy 
             and typretmt = p_typretmt 
             and dteeffec = v_dteeffec
             and nvl(flgretire,p_flgretire) = p_flgretire
           order by numseq;
  begin
      initial_value(json_str_input);
      check_index;

      begin
        select count(*) into v_count
          from tretirmt
         where codcompy = p_codcompy 
           and typretmt = p_typretmt 
           and dteeffec = p_dteeffec
           and nvl(flgretire,p_flgretire) = p_flgretire;
      exception when others then null;
      end;

      if v_count = 0 then
        if p_dteeffec >= trunc(sysdate) then
            v_flgAdd := true;
        end if;
        select max(dteeffec) into v_maxdteeffec
          from tretirmt
         where codcompy = p_codcompy
           and typretmt = p_typretmt
           and dteeffec <= p_dteeffec
           and nvl(flgretire,p_flgretire) = p_flgretire;

        if v_maxdteeffec is null then
            select min(dteeffec) into v_maxdteeffec
              from tretirmt
             where codcompy = p_codcompy
               and typretmt = p_typretmt
               and dteeffec > p_dteeffec
               and nvl(flgretire,p_flgretire) = p_flgretire;

            v_dteeffec      := v_maxdteeffec;
        else
            v_dteeffec      := v_maxdteeffec;
        end if;    
      else
        v_dteeffec := p_dteeffec;
      end if;       

      if param_msg_error is null then
        obj_row := json_object_t();
        for i in c1 loop
          v_row := v_row +1;
          obj_data := json_object_t();
          obj_data.put('numseq',i.numseq);
          obj_data.put('qtyyrest',i.qtyyrest);
          obj_data.put('qtymthst',i.qtymthst);
          obj_data.put('qtydayst',i.qtydayst);
          obj_data.put('qtyyreen',i.qtyyreen);
          obj_data.put('qtymthen',i.qtymthen);
          obj_data.put('qtydayen',i.qtydayen);
          obj_data.put('ratepay',i.ratepay);
          obj_data.put('dteupd',i.dteupd);
          obj_data.put('coduser',i.coduser);
          obj_data.put('dteeffec',to_char(i.dteeffec,'DD/MM/YYYY'));
          obj_data.put('flgAdd',v_flgAdd);
          obj_row.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_row.to_clob;
        return;
      end if;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure validate_save(v_qtyyrest number,v_qtymthst number,v_qtydayst number,v_qtyyreen number,
                          v_qtymthen number,v_qtydayen number,v_ratepay number,v_flgEdit varchar2,
                          v_str_del_numseq varchar2,v_numseq number) as
      v_mix_st number   := 0;
      v_mix_en number   := 0;
      c_mix_str number  := 0;
      c_mix_end number  := 0;
      v_check boolean   := true;
      v_count number    := 0;
      cursor c1 is
         select * from tretirmt
          where to_number(lpad(qtyyrest,2,0)||lpad(qtymthst,2,0)||lpad(qtydayst,2,0)) <> v_mix_st 
            and to_number(lpad(qtyyreen,2,0)||lpad(qtymthen,2,0)||lpad(qtydayen,2,0)) <> v_mix_en 
--            and nvl(v_str_del_numseq,'{}') not like '%{'||numseq||'}%' 
            and codcompy = p_codcompy 
            and dteeffec = p_dteeffec 
            and typretmt = p_typretmt
            and nvl(flgretire,p_flgretire) = p_flgretire;
  begin
    -- ฟิลด์ที่บังคับใส่ข้อมูล ปี/เดือน/วัน ตั้งแต่ - สิ้นสุด,จำนวนเดือนที่จ่าย (HR2045)
    if
      v_qtyyrest is null or
      v_qtymthst is null or
      v_qtydayst is null or
      v_qtyyreen is null or
      v_qtymthen is null or
      v_qtydayen is null or
      v_ratepay is null
    then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    -- ปี/เดือน/วัน ใส่ 0 / 0 / 0 ก็ถือว่าไม่ได้ระบุ (HR2045)
    v_mix_st := lpad(v_qtyyrest,2,0)||lpad(v_qtymthst,2,0)||lpad(v_qtydayst,2,0);
    v_mix_en := lpad(v_qtyyreen,2,0)||lpad(v_qtymthen,2,0)||lpad(v_qtydayen,2,0);

    if v_mix_st = 0 or v_mix_en = 0 then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    -- ปี ใส่ได้ตั้งแต่ 0-99 (HR2020)
    if (v_qtyyrest NOT BETWEEN 0 AND 99) or (v_qtyyreen NOT BETWEEN 0 AND 99) then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        return;
    end if;
    -- เดือน ใส่ได้ตั้งแต่ 0-11 (HR2020)
    if (v_qtymthst NOT BETWEEN 0 AND 11) or (v_qtymthen NOT BETWEEN 0 AND 11) then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        return;
    end if;
    -- วัน ใส่ได้ตั้งแต่ 0-30 (HR2020)
    if (v_qtydayst NOT BETWEEN 0 AND 30) or (v_qtydayen NOT BETWEEN 0 AND 30) then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        return;
    end if;
    -- เริ่มต้น ห้ามมากกว่า สิ้นสุด (HR2022)
    if v_mix_st > v_mix_en then
        param_msg_error := get_error_msg_php('HR2022',global_v_lang);
        return;
    end if;
    -- ทุกช่วง ต้องไม่คร่อมกัน แจ้งเตือน (PY0012)
    for i in c1 loop
      c_mix_str := to_number(lpad(i.qtyyrest,2,0)||lpad(i.qtymthst,2,0)||lpad(i.qtydayst,2,0));
      c_mix_end := to_number(lpad(i.qtyyreen,2,0)||lpad(i.qtymthen,2,0)||lpad(i.qtydayen,2,0));
      -- case 1
      if v_mix_st > c_mix_str and v_mix_en < c_mix_end then
        v_check := false;
        exit;
      end if;
      -- case 2
      if v_mix_en > c_mix_str and v_mix_en < c_mix_end then
        v_check := false;
        exit;
      end if;
      -- case 3
      if v_mix_st < c_mix_end and v_mix_en > c_mix_end then
        v_check := false;
        exit;
      end if;
      -- case 4
      if v_mix_st < c_mix_str and v_mix_en > c_mix_end then
        v_check := false;
        exit;
      end if;
    end loop;
    if v_check = false then
      param_msg_error := get_error_msg_php('PY0012',global_v_lang);
      return;
    end if;
    -- จำนวนเดือนที่จ่าย ใส่ได้ตั้งแต่ 0-999.99
    if (v_ratepay NOT BETWEEN 0 AND 999.99) then
      param_msg_error := get_error_msg_php('HR2020',global_v_lang);
      return;
    end if;

    -- ตรวจสอบ การ Dup ของ PK : กรณีรหัสซ้า (HR2005 TRETIRMT)
    if v_flgEdit = 'add' then
      begin
        select count(*) into v_count
        from tretirmt
        where codcompy = p_codcompy 
            and dteeffec = p_dteeffec 
            and typretmt = p_typretmt 
            and numseq = v_numseq;
      exception when others then null;
      end;
      if v_count > 0 then
        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TRETIRMT');
        return;
      end if;
    end if;
  end;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
      json_obj    json_object_t;
      obj_data    json_object_t;
      param_obj   json_object_t;
      v_new_data  boolean := false;
      v_count     number  := 0;
      v_numseq    number;
      v_qtyyrest  number;
      v_qtymthst  number;
      v_qtydayst  number;
      v_qtyyreen  number;
      v_qtymthen  number;
      v_qtydayen  number;
      v_ratepay   number;
      v_flgEdit   varchar2(10 char);
      v_str_del_numseq    varchar2(250 char) := '';

      v_numseq_current number := 0;
      v_str_period  varchar2(6 char);
      v_end_period  varchar2(6 char);

      cursor c1 is
        select * 
          from tretirmt
         where codcompy = p_codcompy 
           and dteeffec = p_dteeffec  
           and typretmt = p_typretmt 
           and flgretire = p_flgretire
      order by numseq;

  begin
      initial_value(json_str_input);
      json_obj        := json_object_t(json_str_input);
      param_obj       := hcm_util.get_json_t(json_obj,'searchParams');
      p_codcompy      := hcm_util.get_string_t(param_obj,'codcompy');
      p_typretmt      := hcm_util.get_string_t(param_obj,'typretmt');
      p_flgretire     := hcm_util.get_string_t(param_obj,'flgretire');
      p_dteeffec      := to_date(hcm_util.get_string_t(param_obj,'dteeffec'),'dd/mm/yyyy');

      param_json     := hcm_util.get_json_t(json_obj,'param_json');
      for i in 0..param_json.get_size-1 loop
          obj_data        := hcm_util.get_json_t(param_json,to_char(i));
          v_numseq        := to_number(hcm_util.get_string_t(obj_data,'numseq'));
          v_qtyyrest      := to_number(hcm_util.get_string_t(obj_data,'qtyyrest'));
          v_qtymthst      := to_number(hcm_util.get_string_t(obj_data,'qtymthst'));
          v_qtydayst      := to_number(hcm_util.get_string_t(obj_data,'qtydayst'));
          v_qtyyreen      := to_number(hcm_util.get_string_t(obj_data,'qtyyreen'));
          v_qtymthen      := to_number(hcm_util.get_string_t(obj_data,'qtymthen'));
          v_qtydayen      := to_number(hcm_util.get_string_t(obj_data,'qtydayen'));
          v_ratepay       := to_number(hcm_util.get_string_t(obj_data,'ratepay'));
          v_flgEdit       := hcm_util.get_string_t(obj_data,'flg');
--          v_str_del_numseq    := hcm_util.get_string_t(obj_data,'str_del_numseq');
          if v_numseq is null then
            begin
              select nvl(max(numseq),0) + 1 into v_numseq
                from tretirmt
               where codcompy = p_codcompy 
                 and dteeffec = p_dteeffec 
                 and typretmt = p_typretmt;
            exception when no_data_found then
              v_numseq := 1;
            end;
          end if;
          if param_msg_error is not null then
              exit;
          end if;
          -- validate
          if (v_flgEdit != 'delete') then
              validate_save(v_qtyyrest ,v_qtymthst ,v_qtydayst ,v_qtyyreen ,
                  v_qtymthen ,v_qtydayen ,v_ratepay ,v_flgEdit ,v_str_del_numseq,v_numseq);
          end if;
          if v_flgEdit = 'add' then
            insert into tretirmt ( codcompy, dteeffec, typretmt, numseq, qtyyrest, qtymthst, qtydayst, 
                                   qtyyreen, qtymthen, qtydayen, ratepay, codcreate, coduser, flgretire)
                 values ( p_codcompy, p_dteeffec, p_typretmt, v_numseq, v_qtyyrest, v_qtymthst, v_qtydayst, 
                          v_qtyyreen, v_qtymthen, v_qtydayen, v_ratepay, global_v_coduser, global_v_coduser, p_flgretire);
          elsif v_flgEdit = 'edit' then
              update tretirmt set
                  qtyyrest = v_qtyyrest,
                  qtymthst = v_qtymthst,
                  qtydayst = v_qtydayst,
                  qtyyreen = v_qtyyreen,
                  qtymthen = v_qtymthen,
                  qtydayen = v_qtydayen,
                  ratepay  = v_ratepay,
                  coduser  = global_v_coduser
              where
                  codcompy = p_codcompy and
                  dteeffec = p_dteeffec and
                  typretmt = p_typretmt and
                  flgretire = p_flgretire and
                  numseq = v_numseq;
          elsif v_flgEdit = 'delete' then
              delete from tretirmt
              where
                  codcompy = p_codcompy and
                  dteeffec = p_dteeffec and
                  typretmt = p_typretmt and
                  flgretire = p_flgretire and
                  numseq = v_numseq;
          end if;
      end loop;

      for r1 in c1 loop
        v_numseq_current := v_numseq_current + 1;
        if v_numseq_current > 1 then
            if v_str_period between lpad(r1.qtyyrest,2,'0')||lpad(r1.qtymthst,2,'0')||lpad(r1.qtydayst,2,'0') and lpad(r1.qtyyreen,2,'0')||lpad(r1.qtymthen,2,'0')||lpad(r1.qtydayen,2,'0')
               or v_end_period between lpad(r1.qtyyrest,2,'0')||lpad(r1.qtymthst,2,'0')||lpad(r1.qtydayst,2,'0') and lpad(r1.qtyyreen,2,'0')||lpad(r1.qtymthen,2,'0')||lpad(r1.qtydayen,2,'0')
               or lpad(r1.qtyyrest,2,'0')||lpad(r1.qtymthst,2,'0')||lpad(r1.qtydayst,2,'0') between v_str_period and v_end_period
               or lpad(r1.qtyyreen,2,'0')||lpad(r1.qtymthen,2,'0')||lpad(r1.qtydayen,2,'0') between v_str_period and v_end_period
              then
                  param_msg_error := get_error_msg_php('PY0068',global_v_lang);
                  exit;
              end if;
        end if;
        v_str_period := lpad(r1.qtyyrest,2,'0')||lpad(r1.qtymthst,2,'0')||lpad(r1.qtydayst,2,'0');
        v_end_period := lpad(r1.qtyyreen,2,'0')||lpad(r1.qtymthen,2,'0')||lpad(r1.qtydayen,2,'0');
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
      rollback;
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure get_flg_status (json_str_input in clob, json_str_output out clob) is
    obj_data        json_object_t;
    isEdit          boolean := true;
    v_count         number := 0;
    v_dteeffec      tretirmt.dteeffec%type;
    v_maxdteeffec   date;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      begin
        select count(*) into v_count
          from tretirmt
         where codcompy = p_codcompy
           and typretmt = p_typretmt
           and dteeffec = p_dteeffec
           and nvl(flgretire,p_flgretire) = p_flgretire;
      exception when others then null;
      end;

      if v_count = 0 then
        select max(dteeffec) into v_maxdteeffec
          from tretirmt
         where codcompy = p_codcompy
           and typretmt = p_typretmt
           and dteeffec <= p_dteeffec
           and nvl(flgretire,p_flgretire) = p_flgretire;

        if v_maxdteeffec is null then
            select min(dteeffec) into v_maxdteeffec
              from tretirmt
             where codcompy = p_codcompy
               and typretmt = p_typretmt
               and dteeffec > p_dteeffec
               and nvl(flgretire,p_flgretire) = p_flgretire;

            if v_maxdteeffec is null then
                isedit              := true;
            else
                isedit              := false;
                p_dteeffec          := v_maxdteeffec;
            end if;
        else
            if p_dteeffec < trunc(sysdate) then
                p_dteeffec      := v_maxdteeffec;
                isedit          := false;
            else
                isedit          := true;
            end if;
        end if;        
      else
        if p_dteeffec < trunc(sysdate) then
          isedit := false;
        else
          isedit := true;
        end if;
      end if;

--      if v_count > 0 then
--        -- กรณีเจอข้อมูล
--        v_dteeffec := p_dteeffec;
--        if p_dteeffec < trunc(sysdate) then
--          isEdit  := false;
--        end if;
--      else
--        -- กรณีไม่เจอข้อมูล
--        begin
--          select count(*) into v_count
--            from tretirmt
--           where codcompy = p_codcompy 
--             and typretmt = p_typretmt
--             and nvl(flgretire,p_flgretire) = p_flgretire 
--             and dteeffec < p_dteeffec;
--        exception when others then null;
--        end;
--        if v_count > 0 then
--          -- กรณีเจอข้อมูล 2
--          begin
--            select max(dteeffec) into v_dteeffec
--              from tretirmt
--             where codcompy = p_codcompy 
--               and typretmt = p_typretmt
--               and nvl(flgretire,p_flgretire) = p_flgretire 
--               and dteeffec < p_dteeffec;
--          exception when others then null;
--          end;
--          if p_dteeffec < trunc(sysdate) then
--            isEdit      := false;
--            p_dteeffec  :=  v_dteeffec;
--          end if;
--        else
--            -- กรณีไม่เจอข้อมูล 2
--            null;
--        end if;
--      end if;

      obj_data  := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
      obj_data.put('isEdit', isEdit);
      if not isEdit then
        obj_data.put('response', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',''));
      end if;

      json_str_output := obj_data.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_flg_status;
  --
end HRPYC1E;

/

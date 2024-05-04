--------------------------------------------------------
--  DDL for Package Body HRCO2DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2DE" as

    -- Update 12/06/2020 15:35

    procedure initial_value(json_str_input in clob) is
        json_obj   json_object_t := json_object_t(json_str_input);
    begin
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomph      := hcm_util.get_string_t(json_obj,'p_codcomph');
        p_codposh       := hcm_util.get_string_t(json_obj,'p_codposh');
        p_codempidh     := hcm_util.get_string_t(json_obj,'p_codempidh');

        if p_codempidh is not null then
            p_codcomph  := null;
            p_codposh   := null;
        end if;
    end initial_value;

    procedure check_index as
        v_temp  varchar2(1 char);
    begin
        -- ให้ระบุหน่วยงาน , ตำแหน่ง หรือ รหัสพนักงาน Alert HR2045
        if p_codcomph is null and p_codempidh is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- รหัสหน่วยงาน ต้องมีข้อมูลในตาราง TCENTER
        if p_codcomph is not null then
            begin
                select 'X'
                  into v_temp
                  from tcenter
                 where codcomp like p_codcomph||'%'
                 and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                return;
            end;

            -- รหัสหน่วยงานให้ Check Security โดยใช้ secur_main.secur7 หากไม่มีสิทธิ์ดูข้อมูลให้ Alert HR3007
            if p_codcomph is not null then
                if secur_main.secur7(p_codcomph,global_v_coduser) = false then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    return;
                end if;
            end if;
        end if;
        -- รหัสตำแหน่ง ต้องมีข้อมูลในตาราง  TPOSTN
        if p_codposh is not null then
            begin
                select 'X'
                  into v_temp
                  from tpostn
                 where codpos = p_codposh;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
                return;
            end;
        end if;
        if p_codempidh is not null then
            -- รหัสพนักงาน ต้องมีข้อมูลในตาราง  TEMPLOY1
            begin
                select 'X'
                  into v_temp
                  from temploy1
                 where codempid = p_codempidh;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                return;
            end;

            -- รหัสพนักงานให้ Check Security โดยใช้ secur_main.secur2 หากไม่มีสิทธิ์ดูข้อมูลให้ Alert HR3007
            if p_codempidh is not null then
                if secur_main.secur2(p_codempidh,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    return;
                end if;
            end if;
        end if;
    end check_index;

    procedure gen_data(json_str_output out clob) as
      obj_rows    json_object_t;
      obj_data    json_object_t;
      v_row       number :=  0;
      cursor c_temphead is
          select replace(codempidh,'%','') codempidh,replace(codcomph,'%','') codcomph,replace(codposh,'%','') codposh,typdata
          from(
               select codempidh,codcomph,codposh,'1' typdata
              --  p_codcomph,p_codposh
              from temphead
              where codcomph like p_codcomph||'%'
              and codposh = nvl(p_codposh,codposh)
              and p_codempidh is null
              union
              select a.codempidh,a.codcomph,a.codposh,'2' typdata
              -- p_codempidh
              from temphead a,temploy1 b
              where a.codempidh = b.codempid
              and a.codempidh = nvl(p_codempidh,a.codempidh)
              and b.codcomp like p_codcomph||'%'
              and b.codpos = nvl(p_codposh,b.codpos)
          )
          order by codcomph,codposh,codempidh,typdata;
    begin
      obj_rows    := json_object_t();
      for i in c_temphead loop
        obj_data := json_object_t();
        --if p_codempidh is null then
          if i.typdata = '1' then
            obj_data.put('coderror','200');
            obj_data.put('image','');
            obj_data.put('codempidh','');
            obj_data.put('desc_codempidh','');
            obj_data.put('codcomph',i.codcomph);
            obj_data.put('desc_codcomph',get_tcenter_name(i.codcomph,global_v_lang));
            obj_data.put('codposh',i.codposh);
            obj_data.put('desc_codposh',get_tpostn_name(i.codposh,global_v_lang));
            obj_data.put('flgskip','Y');
            v_row := v_row + 1;
            obj_rows.put(to_char(v_row-1),obj_data);
          end if;
        --else
          if i.typdata = '2' then
            obj_data.put('coderror','200');
            obj_data.put('image',get_emp_img(i.codempidh));
            obj_data.put('codempidh',i.codempidh);
            obj_data.put('desc_codempidh',get_temploy_name(i.codempidh,global_v_lang));
            obj_data.put('codcomph','');
            obj_data.put('desc_codcomph','');
            obj_data.put('codposh','');
            obj_data.put('desc_codposh','');
            obj_data.put('flgskip','N');
            v_row := v_row + 1;
            obj_rows.put(to_char(v_row-1),obj_data);
          end if;
        --end if;
      end loop;
      json_str_output := obj_rows.to_clob;
    end gen_data;
    
    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
      initial_value(json_str_input);
      check_index;
      if param_msg_error is null then
        gen_data(json_str_output);
      else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure check_detail as
        v_temp  varchar2(1 char);
    begin
        -- ให้ระบุหน่วยงาน , ตำแหน่ง หรือ รหัสพนักงาน Alert HR2045
        if (p_codcomph is null or p_codposh is null) and p_codempidh is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- รหัสหน่วยงาน ต้องมีข้อมูลในตาราง TCENTER
        if p_codcomph is not null then
            begin
                select 'X'
                  into v_temp
                  from tcenter
                 where codcomp like p_codcomph||'%'
                 and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                return;
            end;

            -- รหัสหน่วยงานให้ Check Security โดยใช้ secur_main.secur7 หากไม่มีสิทธิ์ดูข้อมูลให้ Alert HR3007
            if p_codcomph is not null then
                if secur_main.secur7(p_codcomph,global_v_coduser) = false then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    return;
                end if;
            end if;
        end if;
        -- รหัสตำแหน่ง ต้องมีข้อมูลในตาราง  TPOSTN
        if p_codposh is not null then
            begin
                select 'X'
                  into v_temp
                  from tpostn
                 where codpos = p_codposh;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
                return;
            end;
        end if;
        if p_codempidh is not null then
            -- รหัสพนักงาน ต้องมีข้อมูลในตาราง  TEMPLOY1
            begin
                select 'X'
                  into v_temp
                  from temploy1
                 where codempid = p_codempidh;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                return;
            end;
            -- รหัสพนักงานที่ถูกกำหนดหัวหน้างานต้องมีสถานะไม่พ้นสภาพ HR2101
            begin
                select 'Y'
                  into v_temp
                  from temploy1
                 where codempid = p_codempidh
                   and staemp <> 9;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2101',global_v_lang);
                return;
            end;
            -- รหัสพนักงานให้ Check Security โดยใช้ secur_main.secur2 หากไม่มีสิทธิ์ดูข้อมูลให้ Alert HR3007
            if p_codempidh is not null then
                if secur_main.secur2(p_codempidh,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    return;
                end if;
            end if;
        end if;
    end check_detail;

    procedure gen_detail(json_str_output out clob) as
        obj_rows          json_object_t;
        obj_data          json_object_t;
        v_row             number :=  0;
        v_desc_codempid   varchar2(1000 char) := '';
        v_desc_codcomp    varchar2(1000 char) := '';
        v_desc_codpos      varchar2(1000 char) := '';
        v_flgskip         varchar2(2 char) := 'N';

        cursor c_data is
            select a.*,rowid
              from temphead a
             where codempidh = nvl(p_codempidh,codempidh)
               and codcomph like p_codcomph||'%'
               and codposh = nvl(p_codposh,codposh)
            order by numseq;
    begin
      obj_rows    := json_object_t();
      for i in c_data loop
        if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = true then
          v_row := v_row + 1;
          v_flgskip := 'N';
          if i.codempid is null then
            v_flgskip := 'Y';
          end if;

          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('numseq',i.numseq);
          obj_data.put('image',get_emp_img(i.codempid));
          obj_data.put('codempid',i.codempid);
          obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('codcomp',i.codcomp);
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
          obj_data.put('codpos',i.codpos);
          obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
          obj_data.put('flgskip',v_flgskip);
          obj_data.put('rowid',i.rowid);
          obj_rows.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      json_str_output := obj_rows.to_clob;
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_detail;
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    function validate_import(json_obj json_object_t, v_coderror out varchar, v_text out varchar2, v_error_fld out varchar2) return boolean as
        v_codempid      varchar2(1000);
        v_codcomp       varchar2(1000);
        v_codpos        varchar2(1000);
        v_numseq        varchar2(1000);
        v_codempidh     varchar2(1000);
        v_codcomph      varchar2(1000);
        v_codposh       varchar2(1000);
        v_table         varchar2(10 char) := 'temphead';
        v_temp          varchar2(1 char);
        v_isnumber      varchar2(1 char);
    begin
        v_codempid      := upper(hcm_util.get_string_t(json_obj,'codempid'));
        v_codcomp       := upper(hcm_util.get_string_t(json_obj,'codcomp'));
        v_codpos        := hcm_util.get_string_t(json_obj,'codpos');
        v_numseq        := hcm_util.get_string_t(json_obj,'numseq');
        v_codempidh     := upper(hcm_util.get_string_t(json_obj,'codempidh'));
        v_codcomph      := upper(hcm_util.get_string_t(json_obj,'codcomph'));
        v_codposh       := hcm_util.get_string_t(json_obj,'codposh');
        v_text          := v_codempid||'|'||v_codcomp||'|'||v_codpos||'|'||
                           v_numseq||'|'||v_codempidh||'|'||v_codcomph||'|'||
                           v_codposh;
        if v_codempid is not null then
            v_codcomp := null;
            v_codpos  := null;
        end if;
        if v_codempidh is not null then
            v_codcomph := null;
            v_codposh  := null;
        end if;
        -- ถ้า codempidh และ codcomph และ codposh ทั้งหมดเป็นค่าว่าง(ไม่มีข้อมูลผู้บังคับบัญชา)ให้ error hr2045
        if v_codempidh is null and v_codcomph is null and v_codposh is null then
            v_coderror  := 'HR2045';
            v_error_fld := 'temphead'||'('||'codempidh)';
            return false;
        end if;
        if v_codempid is null and v_codcomp is null and v_codpos is null then
            v_coderror  := 'HR2045';
            v_error_fld := 'temphead'||'('||'codempid)';
            return false;
        end if;
        -- ข้อมูลที่ต้องระบุหากไม่ระบุให้   alert hr2045
        if v_numseq is null then
            v_coderror  := 'HR2045';
            v_error_fld := '(numseq)';
            return false;
        end if;
        -- ต้องแจ้งเตือน HR2508 โปรดตรวจสอบ Format ของ File
        begin
            select decode(regexp_instr (v_numseq, '[^[:digit:]]'),0,'Y','N') into v_isnumber from dual;
        end;
        if v_isnumber = 'N' then
            v_coderror  := 'HR2508';
            v_error_fld := '(numseq)';
            return false;
        end if;
        -- ความยาวต้องไม่เกินตาม column ใน database ตาราง temphead
        if (length(v_codempid)>10) then
            v_coderror  := 'HR6591';
            v_error_fld := '(codempid)';
            return false;
        end if;
        if (length(v_codcomp)>40) then
            v_coderror  := 'HR6591';
            v_error_fld := '(codcomp)';
            return false;
        end if;
        if (length(v_codpos)>4) then
            v_coderror  := 'HR6591';
            v_error_fld := '(codpos)';
            return false;
        end if;

        if (length(v_codempidh)>10) then
            v_coderror  := 'HR6591';
            v_error_fld := '(codempidh)';
            return false;
        end if;
        if (length(v_codcomph)>40) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'codcomph)';
            return false;
        end if;
        if (length(v_codposh)>4) then
            v_coderror  := 'HR6591';
            v_error_fld := '(codposh)';
            return false;
        end if;
        if v_codempid is not null then
            -- ถ้าระบุ codempid ต้องมีข้อมูลในตาราง temploy1
            begin
                select 'X'
                  into v_temp
                  from temploy1
                 where codempid = v_codempid;
            exception when no_data_found then
                v_coderror  := 'HR2010';
                v_error_fld := 'temploy1'||'('||'codempid)';
                return false;
            end;
            -- ถ้าระบุ codempid ที่ staemp = 9 พ้นสภาพ ให้แสดง error hr2101
            begin
                select 'X'
                  into v_temp
                  from temploy1
                 where codempid = v_codempid
                   and staemp <> 9;
            exception when no_data_found then
                v_coderror  := 'HR2101';
                v_error_fld := '(codempid)';
                return false;
            end;
            -- รหัสพนักงานให้ Check Security โดยใช้ secur_main.secur2 หากไม่มีสิทธิ์ดูข้อมูลให้ Alert HR3007
            if secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                v_coderror  := 'HR3007';
                v_error_fld := 'temphead'||'('||'codempid)';
                return false;
            end if;
        end if;
        if v_codcomp is not null then
            -- ถ้าระบุ codcomp ต้องมีข้อมูลใน tcenter
            begin
                select 'X'
                  into v_temp
                  from tcenter
                 where codcomp like v_codcomp||'%'
                 and rownum = 1;
            exception when no_data_found then
                v_coderror  := 'HR2010';
                v_error_fld := 'tcenter'||'('||'codcomp)';
                return false;
            end;
            -- ถ้าระบุ codcomp และ codpos เป็นค่าว่าง ให้   error hr2045
            if v_codpos is null then
                v_coderror  := 'HR2045';
                v_error_fld := 'temphead'||'('||'codpos)';
                return false;
            end if;
            if secur_main.secur7(v_codcomp,global_v_coduser) = false then
                v_coderror  := 'HR3007';
                v_error_fld := 'temphead'||'('||'codcomp)';
                return false;
            end if;
        end if;
        if v_codpos is not null then
            -- ถ้าระบุ codpos ต้องมีข้อมูลใน tpostn
            begin
                select 'X'
                  into v_temp
                  from tpostn
                 where codpos like v_codpos;
            exception when no_data_found then
                v_coderror  := 'HR2010';
                v_error_fld := 'tpostn'||'('||'codpos)';
                return false;
            end;
        end if;
        -- ถ้า codempid และ codcomp และ codpos ทั้งหมดเป็นค่าว่าง(ไม่มีข้อมูลผู้ใต้บังคับบัญชา)ให้ error hr2045
        if v_codempid is null and v_codcomp is null and v_codpos is null then
            v_coderror  := 'HR2010';
            v_error_fld := 'temphead'||'('||'codempid)';
            return false;
        end if;

        if v_codempidh is not null then
            -- ถ้าระบุ codempidh ต้องมีข้อมูลในตาราง temploy1
            begin
                select 'X'
                  into v_temp
                  from temploy1
                 where codempid = v_codempidh;
            exception when no_data_found then
                v_coderror  := 'HR2010';
                v_error_fld := 'temploy1'||'('||'codempidh)';
                return false;
            end;
            -- ถ้าระบุ codempidh ที่ staemp = 9 พ้นสภาพ ให้แสดง error hr2101
            begin
                select 'X'
                  into v_temp
                  from temploy1
                 where codempid = v_codempidh
                   and staemp <> 9;
            exception when no_data_found then
                v_coderror  := 'HR2101';
                v_error_fld := '(codempidh)';
                return false;
            end;
            -- รหัสพนักงานให้ Check Security โดยใช้ secur_main.secur2 หากไม่มีสิทธิ์ดูข้อมูลให้ Alert HR3007
            if secur_main.secur2(v_codempidh,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                v_coderror  := 'HR3007';
                v_error_fld := 'temphead'||'('||'codempidh)';
                return false;
            end if;
            -- กรณีระบุหัวหน้างานเป็นพนักงาน และ กำหนดผู้ใต้บังคับบัญชาเป็นคนเดียวกับหัวหน้างาน
            if v_codempidh = v_codempid then
                v_coderror  := 'HR2020';
                v_error_fld := 'temphead'||'('||'codempidh,codempid)';
                return false;
            end if;
        end if;
        if v_codcomph is not null then
            -- ถ้าระบุ codcomph ต้องมีข้อมูลใน tcenter
            begin
                select 'X'
                  into v_temp
                  from tcenter
                 where codcomp like v_codcomph||'%'
                 and rownum = 1;
            exception when no_data_found then
                v_coderror  := 'HR2010';
                v_error_fld := 'tcenter'||'('||'codcomph)';
                return false;
            end;
            -- ถ้าระบุ codcomph และ codposh เป็นค่าว่าง ให้   error hr2045
            if v_codposh is null then
                v_coderror  := 'HR2045';
                v_error_fld := 'temphead'||'('||'codposh)';
                return false;
            end if;
            if secur_main.secur7(v_codcomph,global_v_coduser) = false then
                v_coderror  := 'HR3007';
                v_error_fld := 'temphead'||'('||'codcomph)';
                return false;
            end if;
            -- กรณีระบุหัวหน้างานเป็นหน่วยงาน และตำแหน่ง  และกำหนดผู้ใต้บังคับบัญชาเป็นหน่วยงานและตำแหน่งเดี่ยวกับหัวหน้างาน
            if (v_codcomph = v_codcomp) and (v_codposh = v_codpos) then
                v_coderror  := 'HR2020';
                v_error_fld := 'temphead'||'('||'codcomph,codcomp,codposh,codpos)';
                return false;
            end if;
        end if;
        if v_codposh is not null then
            -- ถ้าระบุ codposh ต้องมีข้อมูลใน tpostn
            begin
                select 'X'
                  into v_temp
                  from tpostn
                 where codpos like v_codposh;
            exception when no_data_found then
                v_coderror  := 'HR2010';
                v_error_fld := 'tpostn'||'('||'codposh)';
                return false;
            end;
        end if;

        return true;
    end validate_import;

    procedure save_data_temphead(data_obj json_object_t) as
        v_codempid      temphead.codempid%type;
        v_codcomp       temphead.codcomp%type;
        v_codpos        temphead.codpos%type;
        v_numseq        temphead.numseq%type;
        v_codempidh     temphead.codempidh%type;
        v_codcomph      temphead.codcomph%type;
        v_codposh       temphead.codposh%type;
        v_rowid         rowid;
        v_flgedit       varchar2(10 char);
    begin
        v_codempid      := upper(hcm_util.get_string_t(data_obj,'codempid'));
        v_codcomp       := upper(hcm_util.get_string_t(data_obj,'codcomp'));
        v_codpos        := hcm_util.get_string_t(data_obj,'codpos');
        v_numseq        := to_number(hcm_util.get_string_t(data_obj,'numseq'));
        v_codempidh     := upper(hcm_util.get_string_t(data_obj,'codempidh'));
        v_codcomph      := upper(hcm_util.get_string_t(data_obj,'codcomph'));
        v_codposh       := hcm_util.get_string_t(data_obj,'codposh');
        v_rowid         := hcm_util.get_string_t(data_obj,'rowid');
        v_flgedit       := hcm_util.get_string_t(data_obj,'flgedit');
        if v_codempid is not null then
            v_codcomp := null;
            v_codpos  := null;
        end if;
        if v_codempidh is not null then
            v_codcomph := '%';
            v_codposh  := '%';
        end if;
        if v_codcomph != '%' then
--            v_codcomph := nvl(rpad(v_codcomph,21,'0'),'%');
            v_codcomph := nvl(v_codcomph,'%');
        end if;
        if v_flgedit = 'Delete' then
            delete from temphead where rowid = v_rowid;
        else
            if v_flgedit = 'Add' then
                select nvl(max(numseq),0)+1
                  into v_numseq
                  from temphead
                 where codempidh = nvl(v_codempidh,'%')
                   and codcomph = v_codcomph
                   and codposh = nvl(v_codposh,'%');
            end if;
            begin
                insert into temphead(codempid,codcomp,codpos,numseq,codempidh
                            ,codcomph,codposh,dtecreate,codcreate,dteupd,coduser)
                     values (v_codempid,v_codcomp,v_codpos,v_numseq,nvl(v_codempidh,'%')
                            ,v_codcomph,nvl(v_codposh,'%'),sysdate,global_v_coduser,sysdate
                            ,global_v_coduser);
            exception when dup_val_on_index then
                    update temphead
                       set codempid = v_codempid,
                           codcomp = v_codcomp,
                           codpos = v_codpos,
                           coduser = global_v_coduser
                     where codempidh = nvl(v_codempidh,'%')
--                       and codcomph = rpad(v_codcomph,21,'0')
                       and codcomph = v_codcomph
                       and codposh = v_codposh
                       and numseq = v_numseq;
            end;
            begin
              merge into temploy1 t1
              using (select row_id, codcomph, codposh
                       from (select s1.rowid as row_id,s2.codcomph,s2.codposh,
                                       row_number() over (partition by s1.rowid
                                                          order by s1.rowid) as dist1
                                  from temphead s2, temploy1 s1
                                 where nvl(s2.codempidh,'%') = '%'
                                   and nvl(s2.codcomph,'%') <> '%'
                                   and s2.codempidh = nvl(v_codempidh,'%')
                                   and s2.codcomph = v_codcomph
                                   and s2.codposh = v_codposh
                                   and s2.numseq = v_numseq
                                   and ((s1.codcomp  = s2.codcomp and s1.codpos = s2.codpos)
                                         or
                                        (s1.codempid = s2.codempid)))
                          where dist1 = 1) t2
                 on (t1.rowid = t2.row_id)
              when matched then
              update set
                t1.codcompr  = t2.codcomph,
                t1.codposre  = t2.codposh;
            exception when others then
              null;
            end;
        end if;
    end save_data_temphead;

    procedure import_data_process(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        data_obj    json_object_t;
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_coderror  terrorm.errorno%type;
        v_rec_err   number := 0;
        v_rec_tran  number := 0;
        obj_result  json_object_t;
        v_text      varchar2(5000 char);
        v_error_fld varchar2(100 char);
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        obj_rows    := json_object_t();
        for i in 0..param_json.get_size-1 loop
            data_obj := hcm_util.get_json_t(param_json,to_char(i));
            data_obj.put('flgImport','import');
            if (validate_import(data_obj,v_coderror,v_text,v_error_fld)) = false then
                v_row := v_row+1;
                v_rec_err := v_rec_err+1;
                obj_data := json_object_t();
                obj_data.put('numseq',i + 1);
                obj_data.put('error_code',get_errorm_name(v_coderror,global_v_lang)||' '||v_error_fld);
                obj_data.put('text',v_text);
                obj_rows.put(to_char(v_row-1),obj_data);
            else
                v_rec_tran := v_rec_tran+1;
                save_data_temphead(data_obj);
            end if;
        end loop;
        commit;
        obj_result  := json_object_t();

        obj_data    := json_object_t();
        obj_data.put('rec_tran', v_rec_tran);
        obj_data.put('rec_err', v_rec_err);
        obj_data.put('response',replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
        obj_result.put('detail',obj_data);

        obj_data    := json_object_t();
        obj_data.put('rows',obj_rows);
        obj_result.put('table',obj_data);

        obj_rows    := json_object_t();
        obj_rows.put('datadisp',obj_result);

        json_str_output := obj_rows.to_clob;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end import_data_process;

    function validate_save_detail(data_obj json_object_t) return boolean as
        v_codempidh     temphead.codempidh%type;
        v_codempid      temphead.codempid%type;
        v_codcomp       temphead.codcomp%type;
        v_codpos        temphead.codpos%type;
        v_numseq        temphead.numseq%type;
        v_flgedit       varchar2(10 char);
        v_temp          varchar2(1 char);
        v_count         number := 0;
    begin
        v_codempidh     := upper(hcm_util.get_string_t(data_obj,'codempidh'));
        v_codempid      := upper(hcm_util.get_string_t(data_obj,'codempid'));
        v_codcomp       := upper(hcm_util.get_string_t(data_obj,'codcomp'));
        v_codpos        := hcm_util.get_string_t(data_obj,'codpos');
        v_numseq        := to_number(hcm_util.get_string_t(data_obj,'numseq'));
        v_flgedit       := hcm_util.get_string_t(data_obj,'flgedit');
        if v_codempid is not null then
            v_codcomp := null;
            v_codpos  := null;
        end if;
        -- ถ้า codempid และ codcomp และ codpos ทั้งหมดเป็นค่าว่าง(ไม่มีข้อมูลผู้ใต้บังคับบัญชา)ให้ error hr2045
        if v_codempid is null and v_codcomp is null and v_codpos is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return false;
        end if;
        if v_codempid is not null and v_flgedit <> 'Delete' then
            -- ถ้าระบุ codempid ต้องมีข้อมูลในตาราง temploy1
            begin
                select 'X'
                  into v_temp
                  from temploy1
                 where codempid = v_codempid;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
                return false;
            end;
            -- ถ้าระบุ codempid ที่ staemp = 9 พ้นสภาพ ให้แสดง error hr2101
            begin
                select 'X'
                  into v_temp
                  from temploy1
                 where codempid = v_codempid
                   and staemp <> 9;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2101',global_v_lang);
                return false;
            end;
            -- กรณีระบุหัวหน้างานเป็นพนักงาน และ กำหนดผู้ใต้บังคับบัญชาเป็นคนเดียวกับหัวหน้างาน
            if p_codempidh = v_codempid then
                param_msg_error := get_error_msg_php('HR2020',global_v_lang);
                return false;
            end if;
            if secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return false;
            end if;
        end if;
        if v_codcomp is not null and v_flgedit <> 'Delete' then
            -- ถ้าระบุ codcomp ต้องมีข้อมูลใน tcenter
            begin
                select 'X'
                  into v_temp
                  from tcenter
                 where codcomp like v_codcomp||'%'
                 and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
                return false;
            end;
            -- ถ้าระบุ codcomp และ codpos เป็นค่าว่าง ให้   error hr2045
            if v_codpos is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return false;
            end if;
            -- กรณีระบุหัวหน้างานเป็นหน่วยงาน และตำแหน่ง  และกำหนดผู้ใต้บังคับบัญชาเป็นหน่วยงานและตำแหน่งเดี่ยวกับหัวหน้างาน
            if (p_codcomph = v_codcomp) and (p_codposh = v_codpos) then
                param_msg_error := get_error_msg_php('HR2020',global_v_lang);
                return false;
            end if;
            -- รหัสหน่วยงานให้ Check Security โดยใช้ secur_main.secur7 หากไม่มีสิทธิ์ดูข้อมูลให้ Alert HR3007
            if v_codcomp is not null then
                if secur_main.secur7(v_codcomp,global_v_coduser) = false then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    return false;
                end if;
            end if;
        end if;
        if v_codpos is not null and v_flgedit <> 'Delete' then
            -- ถ้าระบุ codpos ต้องมีข้อมูลใน tpostn
            begin
                select 'X'
                  into v_temp
                  from tpostn
                 where codpos like v_codpos;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
                return false;
            end;
        end if;
        if v_flgedit = 'Add' then
            begin
                select count(*)
                  into v_count
                  from temphead
                 where codempidh = nvl(p_codempidh,'%')
                   and codcomph  = nvl(p_codcomph,'%')
                   and codposh   = nvl(p_codposh,'%')
                   and nvl(codempid,'%') = nvl(v_codempid,'%')
                   and nvl(codcomp,'%') = nvl(v_codcomp,'%')
                   and nvl(codpos,'%') = nvl(v_codpos,'%');
            exception when no_data_found then
                v_count := 0;
            end;
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'temphead');
                return false;
            end if;
        end if;
        return true;
    end validate_save_detail;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        data_obj    json_object_t;
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            json_obj    := json_object_t(json_str_input);
            param_json  := hcm_util.get_json_t(json_obj,'param_json');
            for i in 0..param_json.get_size-1 loop
                data_obj := hcm_util.get_json_t(param_json,to_char(i));
                if validate_save_detail(data_obj) = true then
                    data_obj.put('codcomph',p_codcomph);
                    data_obj.put('codposh',p_codposh);
                    data_obj.put('codempidh',p_codempidh);
--                    data_obj.put('flgedit','Add');
                    save_data_temphead(data_obj);
                else
                    rollback;
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    exit;
                end if;
            end loop;
        end if;
        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        data_obj    json_object_t;
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            data_obj := hcm_util.get_json_t(param_json,to_char(i));
            p_codcomph      := hcm_util.get_string_t(data_obj,'codcomph');
            p_codposh       := hcm_util.get_string_t(data_obj,'codposh');
            p_codempidh     := hcm_util.get_string_t(data_obj,'codempidh');
            if p_codempidh is not null then
                p_codcomph  := null;
                p_codposh   := null;
            end if;
            check_index;
            if param_msg_error is null then
                delete from temphead
                      where codempidh = nvl(p_codempidh,'%')
                        and codcomph = nvl(p_codcomph,'%')
                        and codposh = nvl(p_codposh,'%');
            else
                exit;
            end if;
        end loop;
        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

end HRCO2DE;

/

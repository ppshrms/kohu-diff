--------------------------------------------------------
--  DDL for Package Body HRPY1KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY1KE" as
    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        -- index param
        p_codcompy        := hcm_util.get_string_t(json_obj,'codcompy');

    end initial_value;

    procedure check_index is
        v_count_compny  number := 0;
    begin
        -- รหัสบริษัท ตรวจสอบรหัสต้องมีอยู่ในตาราง tcompny (hr2010 tcompny)
        begin
            select count(*) into v_count_compny
            from tcompny
            where codcompy = p_codcompy;
        exception when others then null;
        end;
        if v_count_compny < 1 then
             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
             return;
        end if;
        -- รหัสบริษัท ตรวจสอบ secure (hr3007)
        if p_codcompy is not null then
          param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
          if param_msg_error is not null then
            return;
          end if;
        end if;
    end check_index;

    function gen_coddeduct return json_object_t is
        obj_row     json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        cursor c1 is
            select * from tcodeductc
            where codcompy = p_codcompy;
    begin
        obj_row := json_object_t();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('coddeduct',i.coddeduct);
            obj_data.put('desc_coddeduct',get_tcodeduct_name(i.coddeduct,global_v_lang));
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;
        return obj_row;
    end;

    function gen_codpay return json_object_t is
        obj_row     json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        cursor c1 is
            select * from tinexinfc
            where codcompy = p_codcompy;
    begin
        obj_row := json_object_t();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('codpay',i.codpay);
            obj_data.put('desc_codpay',get_tinexinf_name(i.codpay,global_v_lang));
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;
        return obj_row;
    end;

    function gen_codacc return json_object_t is
        obj_row     json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        cursor c1 is
            select * from taccodbc
            where codcompy = p_codcompy;
    begin
        obj_row := json_object_t();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('codacc',i.codacc);
            obj_data.put('desc_codacc',get_taccodb_name('taccodb',i.codacc,global_v_lang));
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;
        return obj_row;
    end;

    procedure gen_data(json_str_output out clob) is
        obj_result json_object_t;
        obj_data  json_object_t;
    begin
        obj_result := json_object_t();
        obj_data := json_object_t();

        obj_data.put('coddeduct',gen_coddeduct());
        obj_data.put('codpay',gen_codpay());
        obj_data.put('codacc',gen_codacc());
        obj_result.put('0',obj_data);

        json_str_output := obj_result.to_clob;
    end;

    procedure get_index (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        check_index();
        if param_msg_error is null then
            gen_data(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;

    procedure gen_copy_list(json_str_output out clob) is
        obj_row         json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_check_secure  varchar2(400 char) := null;
        cursor c1 is
            select * from tcompny
            where codcompy != p_codcompy
            order by codcompy;
    begin
        obj_row := json_object_t();
        for i in c1 loop
            -- รหัสบริษัทที่ดึงขึ้นมาให้เลือกต้องเชค secure ด้วย
            v_check_secure := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, i.codcompy);
            if v_check_secure is null then
                v_row := v_row + 1;
                obj_data := json_object_t();
                obj_data.put('codcompy',i.codcompy);
                if global_v_lang = '101' then
                    obj_data.put('namcom',i.namcome);
                elsif global_v_lang = '102' then
                    obj_data.put('namcom',i.namcomt);
                elsif global_v_lang = '103' then
                    obj_data.put('namcom',i.namcom3);
                elsif global_v_lang = '104' then
                    obj_data.put('namcom',i.namcom4);
                elsif global_v_lang = '105' then
                    obj_data.put('namcom',i.namcom5);
                else
                    obj_data.put('namcom',i.namcome);
                end if;
                obj_row.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        json_str_output := obj_row.to_clob;
    end;

    procedure get_copy_list(json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        check_index();
        if param_msg_error is null then
            gen_copy_list(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;

    procedure check_save_tcodeductc(p_coddeduct varchar2,p_editflg varchar2) is
        v_count number := 0;
        v_count_dup number := 0;
    begin
        -- รหัสลดหย่อน จะต้องมีอยู่จริงในตาราง tcodeduct (hr2010)
        select count(*) into v_count from tcodeduct where coddeduct = p_coddeduct;
        if v_count < 1 then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodeduct');
            return;
        end if;
        -- ตรวจสอบการ dup ของ pk : กรณีรหัสซ้า (hr2005)
        select count(*) into v_count_dup from tcodeductc where codcompy = p_codcompy and coddeduct = p_coddeduct;
        if p_editflg = 'Add' then
            if v_count_dup > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tcodeductc');
                return;
            end if;
        end if;
    end;

    procedure check_save_tinexinfc(p_codpay varchar2,p_editflg varchar2) is
        v_count number := 0;
        v_count_dup number := 0;
    begin
        if p_editflg != 'Delete' then
            -- รหัสรายได้ จะต้องมีอยู่จริงในตาราง tinexinf (hr2010)
            begin
                select count(*) into v_count
                from tinexinf
                where codpay = p_codpay;
            exception when others then null;
            end;
            if v_count < 1 then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
                return;
            end if;
        end if;
        -- ตรวจสอบการ dup ของ pk : กรณีรหัสซ้า (hr2005)
        begin
            select count(*) into v_count_dup
            from tinexinfc
            where
                codcompy = p_codcompy and
                codpay = p_codpay;
        exception when others then null;
        end;
        if p_editflg = 'Add' then
            if v_count_dup > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tinexinfc');
                return;
            end if;
        end if;
    end;

    procedure check_save_taccodbc(p_codacc varchar2,p_editflg varchar2) is
        v_count number := 0;
        v_count_dup number := 0;
    begin
        -- รหัสบัญชี จะต้องมีอยู่จริงในตาราง taccodb (hr2010)
        begin
            select count(*) into v_count
            from taccodb
            where codacc = p_codacc;
        exception when others then null;
        end;
        if v_count < 1 then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TACCODB');
            return;
        end if;
        -- ตรวจสอบการ dup ของ pk : กรณีรหัสซ้า (hr2005)
        begin
            select count(*) into v_count_dup
            from taccodbc
            where
                codcompy = p_codcompy and
                codacc = p_codacc;
        exception when others then null;
        end;
        if p_editflg = 'Add' then
            if v_count_dup > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'taccodbc');
                return;
            end if;
        end if;
    end;

    procedure save_tcodeductc (param_json json_object_t) is
        obj_data    json_object_t;
        p_coddeduct varchar2(4 char);
        p_editflg   varchar2(10 char);
    begin
        if iscopy = 'Y' then
            delete from tcodeductc
            where codcompy = p_codcompy;
        end if;
        for i in 0..param_json.get_size-1 loop
            obj_data := hcm_util.get_json_t(param_json,to_char(i));
            p_coddeduct := hcm_util.get_string_t(obj_data,'coddeduct');
            p_editflg   := hcm_util.get_string_t(obj_data,'editflg');
            check_save_tcodeductc(p_coddeduct,p_editflg);
            if param_msg_error is not null then
                exit;
            else
                if p_editflg = 'Add' then
                    insert into tcodeductc (
                        codcompy,
                        coddeduct,
                        dtecreate,
                        codcreate,
                        coduser)
                    values (
                        p_codcompy,
                        p_coddeduct,
                        sysdate,
                        global_v_coduser,
                        global_v_coduser);
                elsif p_editflg = 'Delete' and iscopy != 'Y' then
                    delete from tcodeductc
                    where
                        codcompy = p_codcompy and
                        coddeduct = p_coddeduct;
                end if;
            end if;
        end loop;
        return;
    end;

    procedure save_tinexinfc (param_json json_object_t) is
        obj_data    json_object_t;
        p_codpay    varchar2(4 char);
        p_editflg   varchar2(10 char);
    begin
        if iscopy = 'Y' then
            delete from tinexinfc
            where codcompy = p_codcompy;
        end if;
        for i in 0..param_json.get_size-1 loop
            obj_data := hcm_util.get_json_t(param_json,to_char(i));
            p_codpay := hcm_util.get_string_t(obj_data,'codpay');
            p_editflg   := hcm_util.get_string_t(obj_data,'editflg');
            check_save_tinexinfc(p_codpay,p_editflg);
            if param_msg_error is not null then
                exit;
            else
                if p_editflg = 'Add' then
                    insert into tinexinfc (
                        codcompy,
                        codpay,
                        dtecreate,
                        codcreate,
                        coduser)
                    values (
                        p_codcompy,
                        p_codpay,
                        sysdate,
                        global_v_coduser,
                        global_v_coduser);
                elsif p_editflg = 'Delete' and iscopy != 'Y' then
                    delete from tinexinfc
                    where
                        codcompy = p_codcompy and
                        codpay = p_codpay;
                end if;
            end if;
        end loop;
    end;

    procedure save_taccodbc (param_json json_object_t) is
        obj_data    json_object_t;
        p_codacc    taccodbc.codacc%type;
        p_editflg   varchar2(10 char);
    begin
        if iscopy = 'Y' then
            delete from taccodbc
            where codcompy = p_codcompy;
        end if;
        for i in 0..param_json.get_size-1 loop
            obj_data := hcm_util.get_json_t(param_json,to_char(i));
            p_codacc := hcm_util.get_string_t(obj_data,'codacc');
            p_editflg   := hcm_util.get_string_t(obj_data,'editflg');
            check_save_taccodbc(p_codacc,p_editflg);
            if param_msg_error is not null then
                exit;
            else
                if p_editflg = 'Add' then
                    insert into taccodbc (
                    codcompy,
                    codacc,
                    dtecreate,
                    codcreate,
                    coduser)
                    values (
                    p_codcompy,
                    p_codacc,
                    sysdate,
                    global_v_coduser,
                    global_v_coduser);
                elsif p_editflg = 'Delete' and iscopy != 'Y' then
                    delete from taccodbc
                    where
                        codcompy = p_codcompy and
                        codacc = p_codacc;
                end if;
            end if;
        end loop;
    end;

    procedure save_data (json_str_input in clob,json_str_output out clob) is
        json_obj        json_object_t;
        param_coddeduct json_object_t;
        param_codpay    json_object_t;
        param_codacc    json_object_t;
    begin
        initial_value(json_str_input);
        check_index();
        if param_msg_error is null then
            json_obj        := json_object_t(json_str_input);
            param_coddeduct := hcm_util.get_json_t(json_obj,'coddeduct');
            param_codpay    := hcm_util.get_json_t(json_obj,'codpay');
            param_codacc    := hcm_util.get_json_t(json_obj,'codacc');
            iscopy          := hcm_util.get_string_t(json_obj,'iscopy');
            save_tcodeductc(param_coddeduct);
            if param_msg_error is not null then
                rollback;
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            end if;
            save_tinexinfc(param_codpay);
            if param_msg_error is not null then
                rollback;
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            end if;
            save_taccodbc(param_codacc);
            if param_msg_error is not null then
                rollback;
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            else
                commit;
                param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            end if;
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
--        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;

    procedure insert_report_temp(v_numseq number,v_item1 varchar2,v_item2 varchar2,v_item3 varchar2) is
    begin
        insert into ttemprpt (
            codempid,
            codapp,
            numseq,
            item1,
            item2,
            item3,
            item4)
        values (
            global_v_codempid,
            'HRPY1KE',
            v_numseq,
            v_item1,
            v_item2,
            v_item3,
            p_codcompy);
    end;

    procedure static_report (json_str_input in clob,json_str_output out clob) is
        v_numseq number := 0;
        cursor c1 is
            select coddeduct,get_tcodeduct_name(coddeduct,global_v_lang) deductname
            from tcodeductc
            where codcompy = p_codcompy;
        cursor c2 is
            select codpay,get_tinexinf_name(codpay,global_v_lang) codpayname
            from tinexinfc
            where codcompy = p_codcompy;
        cursor c3 is
            select codacc,get_taccodb_name('TACCODB',codacc,global_v_lang) codaccname
            from taccodbc
            where codcompy = p_codcompy;
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRPY1KE';
            for i in c1 loop
                v_numseq := v_numseq + 1;
                insert_report_temp(v_numseq,'CODDEDUCT',i.coddeduct,i.deductname);
            end loop;
            for o in c2 loop
                v_numseq := v_numseq + 1;
                insert_report_temp(v_numseq,'CODPAY',o.codpay,o.codpayname);
            end loop;
            for u in c3 loop
                v_numseq := v_numseq + 1;
                insert_report_temp(v_numseq,'CODACC',u.codacc,u.codaccname);
            end loop;
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;
  --
  procedure get_coddeduct_all(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
      select  coddeduct,decode(global_v_lang,'101',descname,
                                            '102',descnamt,
                                            '103',descnam3,
                                            '104',descnam4,
                                            '105',descnam5) desc_coddeduct
                                            
        from  tcodeduct
    order by  coddeduct;
  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('coddeduct',i.coddeduct);
      obj_data.put('desc_coddeduct',i.desc_coddeduct);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_coddeduct_all;
  --
  procedure get_codpay_all(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
      select  codpay,decode(global_v_lang,'101',descpaye,
                                          '102',descpayt,
                                          '103',descpay3,
                                          '104',descpay4,
                                          '105',descpay5) desc_codpay
        from  tinexinf
       where  typpay like '%'
    order by  codpay;
  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codpay',i.codpay);
      obj_data.put('desc_codpay',i.desc_codpay);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codpay_all;
  --
  procedure get_codaccdr_all(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
      select  codacc,decode(global_v_lang,'101',desacce,
                                          '102',desacct,
                                          '103',desacc3,
                                          '104',desacc4,
                                          '105',desacc5) desc_codacc
        from  taccodb
    order by  codacc;
  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codacc',i.codacc);
      obj_data.put('desc_codacc',i.desc_codacc);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codaccdr_all;
end HRPY1KE;

/

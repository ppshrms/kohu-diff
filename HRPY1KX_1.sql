--------------------------------------------------------
--  DDL for Package Body HRPY1KX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY1KX" as

    procedure initial_value(json_str_input in clob) is
        json_obj   json_object_t := json_object_t(json_str_input);
    begin
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomp       := hcm_util.get_string_t(json_obj,'p_codcomp');
        p_codempid      := upper(hcm_util.get_string_t(json_obj,'codempid'));
        p_numprdst      := to_number(hcm_util.get_string_t(json_obj,'p_numprdst'));
        p_dtemthst      := to_number(hcm_util.get_string_t(json_obj,'p_dtemthst'));
        p_dteyearst     := to_number(hcm_util.get_string_t(json_obj,'p_dteyearst'));
        p_numprden      := to_number(hcm_util.get_string_t(json_obj,'p_numprden'));
        p_dtemthen      := to_number(hcm_util.get_string_t(json_obj,'p_dtemthen'));
        p_dteyearen     := to_number(hcm_util.get_string_t(json_obj,'p_dteyearen'));
        p_flgdata       := hcm_util.get_string_t(json_obj,'p_flgdata');

        if p_codempid is not null then
            p_codcomp := null;
        end if;

        if p_flgdata not in ('1','2') then
            p_flgdata   := '1';
        end if;
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        -- บังคับการใส่ข้อมูล
        if p_codcomp is null and p_codempid is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if  p_numprdst is null and p_dtemthst is null and p_dteyearst is null and p_numprden is null and p_dtemthen is null and p_dteyearen is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- รหัสพนักงาน ต้องมีข้อมูลในตาราง TEMPLOY1 (HR2010)
        if p_codempid is not null then
            begin
                select 'X' into v_temp
                from temploy1
                where codempid = p_codempid;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                return;
            end;
        end if;

        -- รหัสหน่วยงาน ต้องมีข้อมูลในตาราง TCENTER (HR2010)
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp||'%' and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
            return;
        end;

        -- งวด / เดือน / ปี ตั้งแต่ ถ้า > งวด / เดือน / ปี ถึง แจ้งเตือน (Alert HR2029 เดือน/ปีสิ้นสุด ต้องมากกว่าหรือเท่ากับ เดือน/ปีเริ่มต้น)
        if p_dteyearst||lpad(p_dtemthst,2,0)||lpad(p_numprdst,2,0) > p_dteyearen||lpad(p_dtemthen,2,0)||lpad(p_numprden,2,0) then
            param_msg_error := get_error_msg_php('HR2029',global_v_lang);
            return;
        end if;

        -- รหัสพนักงานให้ Check Security โดยใช้ secur_main.secur2 หากไม่มีสิทธิ์ดูข้อมูลให้ Alert HR3007
        if p_codempid is not null then
            if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;

        -- รหัสหน่วยงานให้ Check Security โดยใช้ secur_main.secur7 หากไม่มีสิทธิ์ดูข้อมูลให้ Alert HR3007
        if p_codcomp is not null then
            if secur_main.secur7(p_codcomp,global_v_coduser) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;
    end check_index;

    procedure gen_data1(json_str_output out clob) as
        v_secur     boolean := false;
        v_codempid  tcostemp.codempid%type;
        obj_data    json_object_t;
        obj_rows    json_object_t;
        v_row       number := 0;
        v_found     varchar2(1 char) := 'N';

        cursor c_temploy is
          select codcomp,codempid,numlvl
            from temploy1
           where codcomp like p_codcomp||'%'
             and codempid = nvl(p_codempid,codempid)
        order by codcomp,codempid;

        cursor c_tcostemp is
         select codempid,dteyearst,dtemthst,numprdst,
                codpay,codcomp,costcent,flgcharge,
                dteyearen,dtemthen,numprden,pctchg,remark
           from tcostemp
          where codempid = v_codempid
           and ((dteyearst||lpad(dtemthst,2,0)||lpad(numprdst,2,0)
                between p_dteyearst||lpad(p_dtemthst,2,0)||lpad(p_numprdst,2,0)
                and p_dteyearen||lpad(p_dtemthen,2,0)||lpad(p_numprden,2,0))
             or (nvl(dteyearen,dteyearst) ||lpad(nvl(dtemthen,dtemthst) ,2,0)||lpad( nvl(numprden,numprdst),2,0)
                between p_dteyearst||lpad(p_dtemthst,2,0)||lpad(p_numprdst,2,0)
                and  p_dteyearen||lpad(p_dtemthen,2,0)||lpad(p_numprden,2,0)))
       order by codempid,dteyearst||lpad(p_dtemthst,2,0)||lpad(p_numprdst,2,0) desc , codpay,costcent;
    begin
        obj_rows := json_object_t();
        for e in c_temploy loop
            v_secur := secur_main.secur1(e.codcomp,e.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if v_secur then
                v_codempid := e.codempid;
                obj_data := json_object_t();
                obj_data.put('codempid',e.codempid);
                obj_data.put('namemp',get_temploy_name(e.codempid,global_v_lang));
                obj_data.put('image',get_emp_img(e.codempid));
                obj_data.put('codcomp',case when e.codcomp = '%' then '' else e.codcomp end);
                for r1 in c_tcostemp loop
                    v_found := 'Y';
                    if v_secur = true then
                        v_row := v_row + 1;
                        obj_data := json_object_t();
                        obj_data.put('codempid',e.codempid);
                        obj_data.put('namemp',get_temploy_name(e.codempid,global_v_lang));
                        obj_data.put('image',get_emp_img(e.codempid));
                        obj_data.put('numprdst',r1.numprdst);
                        obj_data.put('dtemthst',r1.dtemthst);
                        obj_data.put('desc_dtemthst',get_nammthful(r1.dtemthst,global_v_lang));
                        obj_data.put('dteyearst',r1.dteyearst);
                        obj_data.put('numprden',r1.numprden);
                        obj_data.put('dtemthen',r1.dtemthen);
                        obj_data.put('desc_dtemthen',get_nammthful(r1.dtemthen,global_v_lang));
                        obj_data.put('dteyearen',r1.dteyearen);
                        obj_data.put('codpay',r1.codpay);
                        obj_data.put('codpaydesc',get_tinexinf_name(r1.codpay,global_v_lang));
                        obj_data.put('flgcharge',get_tlistval_name('FLGCHARGE',r1.flgcharge,global_v_lang));
                        obj_data.put('centername',get_tcenter_name(r1.codcomp,global_v_lang));
                        obj_data.put('costcent',r1.costcent);
                        obj_data.put('pctchg',to_char(r1.pctchg,'fm999.00'));
                        obj_data.put('remark',r1.remark);
                        obj_data.put('codcomp',case when e.codcomp = '%' then '' else e.codcomp end);
                        obj_data.put('v_row',v_row);
                        obj_rows.put(to_char(v_row - 1),obj_data);
                    end if;
                end loop;
                if v_found != 'Y' then
                    v_row := v_row + 1;
                    obj_rows.put(to_char(v_row - 1),obj_data);
                end if;
                v_found := 'N';
            end if;
        end loop;
        -- กรณีไม่พบข้อมูล
        if obj_rows.get_size() = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TCOSTEMP');
            if v_found = 'Y' and v_secur = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            end if;
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;


        json_str_output := obj_rows.to_clob;
    end gen_data1;

    procedure gen_data2(json_str_output out clob) as
        v_secur     boolean := false;
        v_codempid  tcostemp.codempid%type;
        obj_data    json_object_t;
        obj_rows    json_object_t;
        v_row       number := 0;
        v_found     varchar2(1 char) := 'N';

        cursor c1 is
            select a.codcomp,b.codempid,b.numlvl,
                a.dteyearst,a.dtemthst,a.numprdst,
                a.codpay,costcent,flgcharge,
                a.dteyearen,a.dtemthen,a.numprden,
                a.pctchg,a.remark
            from tcostemp a,temploy1 b
             where a.codcomp like p_codcomp||'%'
            and b.codempid = nvl(p_codempid,b.codempid)
            and ((dteyearst||lpad(dtemthst,2,0)||lpad(numprdst,2,0)
                between p_dteyearst||lpad(p_dtemthst,2,0)||lpad(p_numprdst,2,0)
                and p_dteyearen||lpad(p_dtemthen,2,0)||lpad(p_numprden,2,0))
                or (nvl(dteyearen,dteyearst)||lpad(nvl(dtemthen,dtemthst),2,0)||lpad(nvl(numprden,numprdst),2,0)
                    between p_dteyearst||lpad(p_dtemthst,2,0)||lpad(p_numprdst,2,0)
                    and p_dteyearen||lpad(p_dtemthen,2,0)||lpad(p_numprden,2,0)))
            and a.codempid = b.codempid
            --order by b.codcomp,a.codempid,a.dteyearst||lpad(dtemthst,2,0)||lpad(numprdst,2,0) desc;
            order by b.codcomp,a.codempid,a.dteyearst||lpad(dtemthst,2,0)||lpad(numprdst,2,0) desc, a.codpay,costcent;
    begin
        obj_rows := json_object_t();
        for r1 in c1 loop
            v_found := 'Y';
            v_secur := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if v_secur = true then
                v_row := v_row + 1;
                obj_data := json_object_t();
                obj_data.put('codempid',r1.codempid);
                obj_data.put('namemp',get_temploy_name(r1.codempid,global_v_lang));
                obj_data.put('numprdst',r1.numprdst);
                obj_data.put('dtemthst',r1.dtemthst);
                obj_data.put('desc_dtemthst',get_nammthful(r1.dtemthst,global_v_lang));
                obj_data.put('dteyearst',r1.dteyearst);
                obj_data.put('numprden',r1.numprden);
                obj_data.put('dtemthen',r1.dtemthen);
                obj_data.put('desc_dtemthen',get_nammthful(r1.dtemthen,global_v_lang));
                obj_data.put('dteyearen',r1.dteyearen);
                obj_data.put('codpay',r1.codpay);
                obj_data.put('codpaydesc',get_tinexinf_name(r1.codpay,global_v_lang));
                obj_data.put('flgcharge',get_tlistval_name('FLGCHARGE',r1.flgcharge,global_v_lang));
                obj_data.put('centername',get_tcenter_name(r1.codcomp,global_v_lang));
                obj_data.put('costcent',r1.costcent);
                obj_data.put('pctchg',to_char(r1.pctchg,'fm999.00'));
                obj_data.put('remark',r1.remark);
                obj_data.put('codcomp',case when r1.codcomp = '%' then '' else r1.codcomp end);
                obj_data.put('image',get_emp_img(r1.codempid));
                obj_data.put('v_row',v_row);
                obj_rows.put(to_char(v_row - 1),obj_data);
            end if;
        end loop;
        -- กรณีไม่พบข้อมูล
        if obj_rows.get_size() = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TCOSTEMP');
            if v_found = 'Y' and v_secur = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            end if;
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;


        json_str_output := obj_rows.to_clob;
    end gen_data2;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            if p_flgdata = '1' then
                gen_data1(json_str_output);
            else
                gen_data2(json_str_output);
            end if;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

end HRPY1KX;

/

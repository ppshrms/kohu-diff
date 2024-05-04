--------------------------------------------------------
--  DDL for Package Body HRPY6GE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY6GE" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codempid      := hcm_util.get_string_t(json_obj,'codempid');
        p_dteyrepay     := to_number(hcm_util.get_string_t(json_obj,'dteyrepay'));
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
        v_secur boolean;
    begin
        -- บังคับใส่ข้อมูล รหัสพนักงาน , สาหรับปี
        if p_codempid is null or p_dteyrepay is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- รหัสพนักงาน ต้อง Exist ใน TEMPLOY1 (HR2010 TEMPLOY1)
        begin
            select 'X' into v_temp from temploy1 where codempid = p_codempid;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            return;
        end;
        -- Check Security รหัสพนักงาน (HR3007)
        if p_codempid is not null then
            if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;
    end check_index;

    function get_value_stddec(p_value varchar2,p_key1 varchar2) return varchar2 as
        v_value number;
        v_result varchar2(100 char);
    begin
        v_value  := stddec(p_value,p_key1,hcm_secur.get_v_chken);
        v_result := nvl(v_value,0);
        return v_result;
    end get_value_stddec;

    procedure gen_index(json_str_output out clob) as
        rec_temploy3   temploy3%rowtype;
        rec_tssmemb    tssmemb%rowtype;
        rec_tlastded   tlastded%rowtype;
        obj_rows    json_object_t;
        obj_result  json_object_t;
        obj_tab1 json_object_t;
        obj_tab2 json_object_t;
        obj_tab3 json_object_t;
        obj_tab4 json_object_t;
        obj_tab5 json_object_t;
        obj_data json_object_t;
        v_row       number := 0;
        v_amtdeduct tlastempd.amtdeduct%type;
        v_amtspded tlastempd.amtspded%type;
        v_flgedit   varchar2(10 char) := 'Edit';

        cursor c1 is
            select * from tdeductd
            where dteyreff = p_dteyrepay
                and codcompy = (select get_codcompy(codcomp)
                                from temploy1
                                where codempid = p_codempid)
                and typdeduct = 'E'
                and coddeduct <> 'E001'
            order by coddeduct;

        cursor c2 is
            select * from tdeductd
            where dteyreff = p_dteyrepay
                and codcompy = (select get_codcompy(codcomp)
                                from temploy1
                                where codempid = p_codempid)
                and typdeduct = 'D'
                and coddeduct not in ('D001','D002')
            order by coddeduct;

        cursor c3 is
            select * from tdeductd
            where dteyreff = p_dteyrepay
                and codcompy = (select get_codcompy(codcomp)
                                from temploy1
                                where codempid = p_codempid)
                and typdeduct = 'O'
            order by coddeduct;
    begin
        begin
            select * into rec_temploy3 from temploy3
            where codempid = p_codempid;
        exception when no_data_found then
            null;
        end;

        begin
            select * into rec_tssmemb from tssmemb
            where codempid = p_codempid;
        exception when no_data_found then
            null;
        end;

        begin
            select * into rec_tlastded from tlastded
            where codempid = p_codempid
            and dteyrepay = p_dteyrepay;
        exception when no_data_found then
            v_flgedit := 'Add';
        end;

        obj_tab1 := json_object_t();
        obj_tab1.put('numtaxid',rec_temploy3.numtaxid);
        obj_tab1.put('numsaid',rec_temploy3.numsaid);
        obj_tab1.put('frsmemb',to_char(rec_tssmemb.frsmemb,'dd/mm/yyyy'));
        obj_tab1.put('flgtax',rec_tlastded.flgtax);
        obj_tab1.put('typtax',rec_tlastded.typtax);
        obj_tab1.put('qtychldb',nvl(to_char(rec_tlastded.qtychldb),''));
        obj_tab1.put('qtychlda',nvl(to_char(rec_tlastded.qtychlda),''));
        obj_tab1.put('qtychldd',nvl(to_char(rec_tlastded.qtychldd),''));
        obj_tab1.put('qtychldi',nvl(to_char(rec_tlastded.qtychldi),''));
        obj_tab1.put('dteyrrelf',nvl(to_char(rec_tlastded.dteyrrelf),''));
        obj_tab1.put('dteyrrelt',nvl(to_char(rec_tlastded.dteyrrelt),''));
        obj_tab1.put('amtrelas',get_value_stddec(rec_tlastded.amtrelas,rec_tlastded.codempid));
        obj_tab1.put('amttaxrel',get_value_stddec(rec_tlastded.amttaxrel,rec_tlastded.codempid));
        obj_tab1.put('flgedit',v_flgedit);

        obj_tab2 := json_object_t();
        obj_tab2.put('amtincbf',get_value_stddec(rec_tlastded.amtincbf,rec_tlastded.codempid));
        obj_tab2.put('amtincsp',get_value_stddec(rec_tlastded.amtincsp,rec_tlastded.codempid));
        obj_tab2.put('amttaxbf',get_value_stddec(rec_tlastded.amttaxbf,rec_tlastded.codempid));
        obj_tab2.put('amttaxsp',get_value_stddec(rec_tlastded.amttaxsp,rec_tlastded.codempid));
        obj_tab2.put('amtpf',get_value_stddec(rec_tlastded.amtpf,rec_tlastded.codempid));
        obj_tab2.put('amtpfsp',get_value_stddec(rec_tlastded.amtpfsp,rec_tlastded.codempid));
        obj_tab2.put('amtsaid',get_value_stddec(rec_tlastded.amtsaid,rec_tlastded.codempid));
        obj_tab2.put('amtsasp',get_value_stddec(rec_tlastded.amtsasp,rec_tlastded.codempid));

        obj_tab3 := json_object_t();
        for r1 in c1 loop
            v_row := v_row + 1;
            begin
                select amtdeduct, amtspded
                into v_amtdeduct, v_amtspded
                from tlastempd
                where dteyrepay = p_dteyrepay
                    and codempid = p_codempid
                    and coddeduct = r1.coddeduct;
            exception when no_data_found then
                v_amtdeduct := '';
                v_amtspded  := '';
            end;
            obj_data := json_object_t();
            obj_data.put('coddeduct',r1.coddeduct);
            obj_data.put('desc_coddeduct',get_tcodeduct_name(r1.coddeduct,global_v_lang));
            obj_data.put('amtdeduct',get_value_stddec(v_amtdeduct,p_codempid));
            obj_data.put('amtspded',get_value_stddec(v_amtspded,p_codempid));
            obj_tab3.put(to_char(v_row - 1),obj_data);
        end loop;

        obj_tab4 := json_object_t();
        v_row := 0;
        for r2 in c2 loop
            v_row := v_row + 1;
            begin
                select amtdeduct, amtspded
                into v_amtdeduct, v_amtspded
                from tlastempd
                where dteyrepay = p_dteyrepay
                    and codempid = p_codempid
                    and coddeduct = r2.coddeduct;
            exception when no_data_found then
                v_amtdeduct := '';
                v_amtspded  := '';
            end;

            obj_data := json_object_t();
            obj_data.put('coddeduct',r2.coddeduct);
            obj_data.put('desc_coddeduct',get_tcodeduct_name(r2.coddeduct,global_v_lang));
            obj_data.put('amtdeduct',get_value_stddec(v_amtdeduct,p_codempid));
            obj_data.put('amtspded',get_value_stddec(v_amtspded,p_codempid));
--            if r2.coddeduct = 'D004' then
--                obj_data.put('amtdeduct',to_char((r2.amtdemax / 3) * rec_temploy3.qtychedu,'fm999,999,999.00'));
--                obj_data.put('amtspded',to_char((r2.amtdemax / 3) * rec_temploy3.qtychedu,'fm999,999,999.00'));
--            elsif r2.coddeduct = 'D005' then
--                obj_data.put('amtdeduct',to_char((r2.amtdemax / 3) * rec_temploy3.qtychned,'fm999,999,999.00'));
--                obj_data.put('amtspded',to_char((r2.amtdemax / 3) * rec_temploy3.qtychned,'fm999,999,999.00'));
--            else
--                obj_data.put('amtdeduct',get_value_stddec(v_amtdeduct,p_codempid));
--                obj_data.put('amtspded',get_value_stddec(v_amtspded,p_codempid));
--            end if;

            obj_tab4.put(to_char(v_row - 1),obj_data);
        end loop;

        obj_tab5 := json_object_t();
        v_row := 0;
        for r3 in c3 loop
            v_row := v_row + 1;
            begin
                select amtdeduct, amtspded
                into v_amtdeduct, v_amtspded
                from tlastempd
                where dteyrepay = p_dteyrepay
                    and codempid = p_codempid
                    and coddeduct = r3.coddeduct;
            exception when no_data_found then
                v_amtdeduct := '';
                v_amtspded  := '';
            end;

            obj_data := json_object_t();
            obj_data.put('coddeduct',r3.coddeduct);
            obj_data.put('desc_coddeduct',get_tcodeduct_name(r3.coddeduct,global_v_lang));
            obj_data.put('amtdeduct',get_value_stddec(v_amtdeduct,p_codempid));
            obj_data.put('amtspded',get_value_stddec(v_amtspded,p_codempid));
            obj_tab5.put(to_char(v_row - 1),obj_data);
        end loop;

        obj_result := json_object_t();
        obj_result.put('tab1',obj_tab1);
        obj_result.put('tab2',obj_tab2);
        obj_result.put('tab3',obj_tab3);
        obj_result.put('tab4',obj_tab4);
        obj_result.put('tab5',obj_tab5);
        obj_result.put('dteupd',to_char(rec_tlastded.dteupd,'dd/mm/yyyy'));
        obj_result.put('desc_coduser',rec_tlastded.coduser||' - '||get_temploy_name(get_codempid(rec_tlastded.coduser),global_v_lang));
        obj_result.put('codempid',get_codempid(rec_tlastded.coduser));

        obj_rows := json_object_t();
        obj_rows.put('0',obj_result);

        json_str_output := obj_rows.to_clob;
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure validate_save as
        v_tab1      json_object_t;
        v_flgtax    tlastded.flgtax%type;
        v_typtax    tlastded.typtax%type;
        v_amtrelas  tlastded.amtrelas%type;
        v_dteyrrelf tlastded.dteyrrelf%type;
        v_dteyrrelt tlastded.dteyrrelt%type;
        v_amttaxrel tlastded.amttaxrel%type;
    begin
        -- วิธีการหักภาษี  วิธีการยื่นภาษี   บังคับระบ HR2045
        v_tab1      := hcm_util.get_json_t(param_json,'tab1');
        v_flgtax    := hcm_util.get_string_t(v_tab1,'flgtax');
        v_typtax    := hcm_util.get_string_t(v_tab1,'typtax');
        v_dteyrrelf := to_number(hcm_util.get_string_t(v_tab1,'dteyrrelf'));
        v_dteyrrelt := to_number(hcm_util.get_string_t(v_tab1,'dteyrrelt'));
        v_amtrelas  := replace(hcm_util.get_string_t(v_tab1,'amtrelas'),',');
        v_amttaxrel := replace(hcm_util.get_string_t(v_tab1,'amttaxrel'),',');
        if v_flgtax is null or v_typtax is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- ถ้าระบุข้อมูลอสังหาริมทรัพย์  ปีที่เริ่มยกเว้น  หรือ ปีที่สิ้นสุด
        if v_dteyrrelf is not null or v_dteyrrelt is not null then
            -- บังคับระบุ มูลค่าอสังหาริมทรัพย,ภาษีที่ร ับการยกเว้น amtrelas,amttaxrel  ปีที่เริ่มยกเว้น  และ ปีที่สิ้นสุด  ต้องระบุให้ครบ
            if v_amtrelas is null or v_amttaxrel is null or v_dteyrrelf is null or v_dteyrrelt is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return;
            end if;
            -- ปีที่เริ่มยกเว้น  น้อยกว่า ปีที่สิ้นสุด
            if v_dteyrrelf > v_dteyrrelt then
                param_msg_error := get_error_msg_php('HR2027',global_v_lang);
                return;
            end if;
            -- มูลค่าอสังหาริมทรัพย์   ไม่เกิน 5,000,000 ถ้าเกิน ฟ้อง Error  ('HR2020')
            if (to_number(v_amtrelas) > 5000000) then
                param_msg_error := get_error_msg_php('HR2020',global_v_lang);
                return;
            end if;
        end if;
    end validate_save;

    procedure save_tab1(v_tab1 json_object_t) as
        v_flgedit   varchar2(10 char);
        v_flgtax    tlastded.flgtax%type;
        v_typtax    tlastded.typtax%type;
        v_dteyrrelf tlastded.dteyrrelf%type;
        v_dteyrrelt tlastded.dteyrrelt%type;
        v_amtrelas  tlastded.amtrelas%type;
        v_amttaxrel tlastded.amttaxrel%type;
        v_stamarry  tlastded.stamarry%type;

        v_qtychldb  tlastded.qtychldb%type;
        v_qtychlda  tlastded.qtychlda%type;
        v_qtychldd  tlastded.qtychldd%type;
        v_qtychldi  tlastded.qtychldi%type;
    begin
        v_flgedit   := hcm_util.get_string_t(v_tab1,'flgedit');
        v_flgtax    := hcm_util.get_string_t(v_tab1,'flgtax');
        v_typtax    := hcm_util.get_string_t(v_tab1,'typtax');
        v_dteyrrelf := to_number(hcm_util.get_string_t(v_tab1,'dteyrrelf'));
        v_dteyrrelt := to_number(hcm_util.get_string_t(v_tab1,'dteyrrelt'));
        v_amtrelas  := replace(hcm_util.get_string_t(v_tab1,'amtrelas'),',');
        v_amttaxrel := replace(hcm_util.get_string_t(v_tab1,'amttaxrel'),',');

        v_qtychldb  := to_number(hcm_util.get_string_t(v_tab1,'qtychldb'));
        v_qtychlda  := to_number(hcm_util.get_string_t(v_tab1,'qtychlda'));
        v_qtychldd  := to_number(hcm_util.get_string_t(v_tab1,'qtychldd'));
        v_qtychldi  := to_number(hcm_util.get_string_t(v_tab1,'qtychldi'));
        begin
            select stamarry
              into v_stamarry
              from temploy1
             where codempid = p_codempid;
        exception when no_data_found then
            v_stamarry := null;
        end;
        if v_flgedit = 'Add' then
            insert into tlastded (dteyrepay,codempid,flgtax,typtax,dteyrrelf
                        ,dteyrrelt,amtrelas,amttaxrel,coduser,codcomp,stamarry,
                        qtychldb,qtychlda,qtychldd,qtychldi,
                        codcreate,dtecreate)
            values (p_dteyrepay,p_codempid,v_flgtax,v_typtax,v_dteyrrelf,v_dteyrrelt
                    ,stdenc(v_amtrelas,p_codempid,hcm_secur.get_v_chken)
                    ,stdenc(v_amttaxrel,p_codempid,hcm_secur.get_v_chken)
                    ,global_v_coduser
                    ,(select codcomp from temploy1 where codempid = p_codempid)
                    ,v_stamarry,
                    v_qtychldb,v_qtychlda,v_qtychldd,v_qtychldi,
                    global_v_coduser,sysdate);
        elsif v_flgedit = 'Edit' then
            update tlastded set
                flgtax      = v_flgtax,
                typtax      = v_typtax,
                dteyrrelf   = v_dteyrrelf,
                dteyrrelt   = v_dteyrrelt,
                amtrelas    = stdenc(v_amtrelas,p_codempid,hcm_secur.get_v_chken),
                amttaxrel   = stdenc(v_amttaxrel,p_codempid,hcm_secur.get_v_chken),
                coduser     = global_v_coduser,
                dteupd = sysdate,
                stamarry    = v_stamarry,
                qtychldb = v_qtychldb,
                qtychlda = v_qtychlda,
                qtychldd = v_qtychldd,
                qtychldi = v_qtychldi
            where codempid = p_codempid
            and dteyrepay = p_dteyrepay;
        end if;
    end save_tab1;

    procedure save_tab2(v_tab2 json_object_t) as
        v_flgedit   varchar2(10 char);
        v_amtincbf  tlastded.amtincbf%type;
        v_amtincsp  tlastded.amtincsp%type;
        v_amttaxbf  tlastded.amttaxbf%type;
        v_amttaxsp  tlastded.amttaxsp%type;
        v_amtpf     tlastded.amtpf%type;
        v_amtpfsp   tlastded.amtpfsp%type;
        v_amtsaid   tlastded.amtsaid%type;
        v_amtsasp   tlastded.amtsasp%type;
    begin
        v_flgedit   := hcm_util.get_string_t(v_tab2,'flgedit');
        v_amtincbf  := hcm_util.get_string_t(v_tab2,'amtincbf');
        v_amtincsp  := hcm_util.get_string_t(v_tab2,'amtincsp');
        v_amttaxbf  := hcm_util.get_string_t(v_tab2,'amttaxbf');
        v_amttaxsp  := hcm_util.get_string_t(v_tab2,'amttaxsp');
        v_amtpf     := hcm_util.get_string_t(v_tab2,'amtpf');
        v_amtpfsp   := hcm_util.get_string_t(v_tab2,'amtpfsp');
        v_amtsaid   := hcm_util.get_string_t(v_tab2,'amtsaid');
        v_amtsasp   := hcm_util.get_string_t(v_tab2,'amtsasp');

        update tlastded set
            amtincbf  = stdenc(v_amtincbf,p_codempid,hcm_secur.get_v_chken),
            amtincsp  = stdenc(v_amtincsp,p_codempid,hcm_secur.get_v_chken),
            amttaxbf  = stdenc(v_amttaxbf,p_codempid,hcm_secur.get_v_chken),
            amttaxsp  = stdenc(v_amttaxsp,p_codempid,hcm_secur.get_v_chken),
            amtpf     = stdenc(v_amtpf,p_codempid,hcm_secur.get_v_chken),
            amtpfsp   = stdenc(v_amtpfsp,p_codempid,hcm_secur.get_v_chken),
            amtsaid   = stdenc(v_amtsaid,p_codempid,hcm_secur.get_v_chken),
            amtsasp   = stdenc(v_amtsasp,p_codempid,hcm_secur.get_v_chken),
            coduser   = global_v_coduser,
            dteupd = sysdate
        where codempid = p_codempid
        and dteyrepay = p_dteyrepay;
    end save_tab2;

    procedure save_tlastempd(v_tab2 json_object_t) as
        v_flgedit   varchar2(10 char);
        v_coddeduct tlastempd.coddeduct%type;
        v_amtdeduct tlastempd.amtdeduct%type;
        v_amtspded  tlastempd.amtspded%type;
        obj_json    json_object_t;
        v_temp      varchar2(1 char);
    begin
        for i in 0..v_tab2.get_size-1 loop
            obj_json := hcm_util.get_json_t(v_tab2,to_char(i));
            v_flgedit   := hcm_util.get_string_t(obj_json,'flgedit');
            v_coddeduct := upper(hcm_util.get_string_t(obj_json,'coddeduct'));
            v_amtdeduct := replace(hcm_util.get_string_t(obj_json,'amtdeduct'),',');
            v_amtspded  := replace(hcm_util.get_string_t(obj_json,'amtspded'),',');

            if v_flgedit = 'Add' then
                insert into tlastempd (dteyrepay,codempid,codcomp,coddeduct,amtdeduct,amtspded,
                                       codcreate,coduser,dtecreate,dteupd)
                values (p_dteyrepay,p_codempid,(select codcomp from temploy1 where codempid = p_codempid)
                        ,v_coddeduct
                        ,stdenc(v_amtdeduct,p_codempid,hcm_secur.get_v_chken)
                        ,stdenc(v_amtspded,p_codempid,hcm_secur.get_v_chken)
                        ,global_v_coduser,global_v_coduser,sysdate,sysdate);
            elsif v_flgedit = 'Edit' then
                begin
                    select 'X' into v_temp
                    from tlastempd
                    where dteyrepay = p_dteyrepay
                    and codempid = p_codempid
                    and coddeduct = v_coddeduct;

                    update tlastempd set
                        amtdeduct = stdenc(v_amtdeduct,p_codempid,hcm_secur.get_v_chken),
                        amtspded = stdenc(v_amtspded,p_codempid,hcm_secur.get_v_chken),
                        coduser = global_v_coduser,
                        dteupd = sysdate
                    where dteyrepay = p_dteyrepay
                    and codempid = p_codempid
                    and coddeduct = v_coddeduct;
                exception when no_data_found then
                    insert into tlastempd (dteyrepay,codempid,codcomp,coddeduct,amtdeduct,amtspded,codcreate,coduser,dtecreate,dteupd)
                    values (p_dteyrepay,p_codempid,(select codcomp from temploy1 where codempid = p_codempid)
                        ,v_coddeduct
                        ,stdenc(v_amtdeduct,p_codempid,hcm_secur.get_v_chken)
                        ,stdenc(v_amtspded,p_codempid,hcm_secur.get_v_chken)
                        ,global_v_coduser,global_v_coduser,
                        sysdate,sysdate);
                end;
            end if;
        end loop;
    end save_tlastempd;

    procedure save_data(json_str_output out clob) as
        v_tab1  json_object_t;
        v_tab2  json_object_t;
        v_tab3  json_object_t;
        v_tab4  json_object_t;
        v_tab5  json_object_t;
        v_flgedit   varchar2(10 char);
    begin
        -- กดปุ่ม Save  ข้อมูลลง TLASTDED  , TLASTEMPD
        v_tab1      := hcm_util.get_json_t(param_json,'tab1');
        v_tab2      := hcm_util.get_json_t(param_json,'tab2');
        v_tab3      := hcm_util.get_json_t(param_json,'tab3');
        v_tab4      := hcm_util.get_json_t(param_json,'tab4');
        v_tab5      := hcm_util.get_json_t(param_json,'tab5');

        save_tab1(v_tab1);
        save_tab2(v_tab2);
        save_tlastempd(v_tab3);
        save_tlastempd(v_tab4);
        save_tlastempd(v_tab5);

        if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            commit;
        else
            rollback;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_data;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
    begin
        initial_value(json_str_input);
        check_index;
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        validate_save;
        if param_msg_error is null then
            save_data(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

end HRPY6GE;

/

--------------------------------------------------------
--  DDL for Package Body HRPY1DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY1DE" as
    procedure initial_value(json_str_input in clob) as
        json_obj json_object_t;
    begin
        json_obj                := json_object_t(json_str_input);
        global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');
        global_v_empname        := hcm_service.get_empname(json_str_input);

        p_dteyrepay             := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
        p_codcompy              := hcm_util.get_string_t(json_obj,'p_codcompy');
        p_typpayroll            := hcm_util.get_string_t(json_obj,'p_typpayroll');
        p_qtynumpay             := to_number(hcm_util.get_string_t(json_obj,'p_qtynumpay'));
        p_dteyrepay_query       := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay_query'));
        p_codcompy_query        := hcm_util.get_string_t(json_obj,'p_codcompy_query');
        p_typpayroll_query      := hcm_util.get_string_t(json_obj,'p_typpayroll_query');
    end initial_value;

    function check_has_codcompy(p_codcompy varchar2) return boolean is
        v_count number := 0;
    begin
        begin
            select count(*)
              into v_count
              from tcompny
             where codcompy = p_codcompy;
        exception when others then null;
        end;
        if v_count < 1 then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
            return false;
        end if;
        return true;
    end;

    procedure validate_get_index(codcompy varchar2, typpayroll varchar2) as
        v_check_company     boolean;
        v_count_tcodtypy    number := 0;
        v_secure            varchar2(4000 char) := null;
    begin
        v_check_company := check_has_codcompy(codcompy);
        if v_check_company = false then
            return;
        end if;
        begin
            select count(*)
              into v_count_tcodtypy
              from tcodtypy
             where codcodec = typpayroll;
        exception when others then null;
        end;
        if v_count_tcodtypy < 1 then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang);
            return;
        end if;
        v_secure        := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,codcompy);
        if v_secure is not null then
            param_msg_error := v_secure;
            return;
        end if;
    end validate_get_index;
    function check_editable(p_codcompy varchar2,p_typpayroll varchar2,p_dteyrepay number,p_dtemthpay number,p_numperiod number,p_tab number) return boolean is
        v_count_flgcal      number;
        v_count_ttaxcur     number;
    begin
        if p_tab = 1 then
            select count(*)
              into v_count_flgcal
              from tdtepay
             where codcompy   = p_codcompy
               and typpayroll = p_typpayroll
               and dteyrepay  = p_dteyrepay
               and dtemthpay  = p_dtemthpay
               and numperiod  = p_numperiod
               and flgcal = 'Y';

            select count(*)
              into v_count_ttaxcur
              from ttaxcur
             where hcm_util.get_codcomp_level(codcomp,1) = p_codcompy
               and typpayroll = p_typpayroll
               and dteyrepay  = p_dteyrepay
               and dtemthpay  = p_dtemthpay
               and numperiod  = p_numperiod;

            if v_count_flgcal > 0 and v_count_ttaxcur > 0 then
                return false;
            end if;
        else
            null;
        end if;
        return true;
    end;

    function check_flgtrnbank(p_codcompy varchar2,p_typpayroll varchar2,p_dteyrepay number,p_dtemthpay number,p_numperiod number) return varchar2 is
        v_count_ttaxcur     number;
        v_flgtrnbank        varchar2(2 char);
    begin
        --<<nut 
        begin
          select nvl(flgtrnbank,'N')
            into v_flgtrnbank
            from ttaxcur
           where hcm_util.get_codcompy(codcomp) = p_codcompy
             and typpayroll = p_typpayroll
             and dteyrepay  = p_dteyrepay
             and dtemthpay  = p_dtemthpay
             and numperiod  = nvl(p_numperiod,numperiod)
             and flgtrnbank = 'Y'
             and rownum = 1;
        exception when no_data_found then
          v_flgtrnbank := 'N';
        end;
        return v_flgtrnbank;
        /*
        begin
          select nvl(flgtrnbank,'N')
            into v_flgtrnbank
            from ttaxcur
           where hcm_util.get_codcomp_level(codcomp,1) = p_codcompy
             and typpayroll = p_typpayroll
             and dteyrepay  = p_dteyrepay
             and dtemthpay  = p_dtemthpay
             and numperiod  = p_numperiod
             and rownum = 1;
        exception when no_data_found then
          v_flgtrnbank := 'N';
        end;
        return v_flgtrnbank;*/
        -->>Nut 
    end;

    procedure get_index_tab1(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        obj_data            json_object_t;
        obj_children        json_object_t;
        obj_row             json_object_t;
        obj_row_children    json_object_t;
        v_rcnt              number := 0;
        v_row1		        number := 0;
        v_count_found       number := 0;
        v_count_not_found   number := 0;
        v_where_year        number := 0;
        v_diff_year         number := 1;
        v_dtemthpay         tdtepay.dtemthpay%type;

        cursor c1 is
          select *
            from tdtepay
           where dteyrepay  = p_dteyrepay
             and codcompy   = p_codcompy
             and typpayroll = p_typpayroll
             and dtemthpay = v_dtemthpay
           order by dtemthpay, numperiod;

        cursor c3 is
          select *
            from tdtepay
           where dteyrepay  = v_where_year
             and codcompy   = p_codcompy
             and typpayroll = p_typpayroll
             and dtemthpay = v_dtemthpay
          order by dtemthpay, numperiod;
    begin
        initial_value(json_str_input);
        validate_get_index(p_codcompy,p_typpayroll);
        begin
          select count(*)
            into v_count_found
            from tdtepay
           where dteyrepay = p_dteyrepay
             and codcompy = p_codcompy
             and typpayroll = p_typpayroll;
        end;
        begin
          select count(*)
            into v_count_not_found
            from tdtepay
           where dteyrepay < p_dteyrepay
             and codcompy = p_codcompy
             and typpayroll = p_typpayroll;
        end;
        if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        obj_row             := json_object_t();
        obj_row_children    := json_object_t();
        for r_month in 1..12 loop
            obj_row_children := json_object_t();
            v_row1 := 0;
            v_dtemthpay := r_month;
            if v_count_found > 0 then   --กรณีเจอข้อมูล
                for r1 in c1 loop
                    v_row1      := v_row1 + 1;
                    if v_row1 <= p_qtynumpay then
                        obj_children    := json_object_t();
                        obj_children.put('numperiod',r1.numperiod);
                        obj_children.put('dtestrt',nvl(to_char(r1.dtestrt, 'dd/mm/yyyy'),''));
                        obj_children.put('dteend',nvl(to_char(r1.dteend, 'dd/mm/yyyy'),''));
                        obj_children.put('dtepaymt',nvl(to_char(r1.dtepaymt, 'dd/mm/yyyy'),''));
                        obj_children.put('dtewatch',nvl(to_char(r1.dtewatch, 'dd/mm/yyyy'),''));
                        obj_children.put('timwatch',nvl(r1.timwatch,''));
                        obj_children.put('flgcal',nvl(r1.flgcal,'N'));
                        obj_children.put('flgtrnbank',check_flgtrnbank(p_codcompy,p_typpayroll,p_dteyrepay,v_dtemthpay,r1.numperiod));
                        obj_row_children.put(to_char(v_row1-1),obj_children);
                    end if;
                end loop;

                if v_row1 < p_qtynumpay then
                    for i in (v_row1+1)..p_qtynumpay loop
                        v_row1 := v_row1 + 1;
                        obj_children := json_object_t();
                        obj_children.put('flgAdd',true);
                        obj_children.put('numperiod','');
                        obj_children.put('dtestrt','');
                        obj_children.put('dteend','');
                        obj_children.put('dtepaymt','');
                        obj_children.put('dtewatch','');
                        obj_children.put('timwatch','');
                        obj_children.put('flgcal','N');
                        obj_children.put('flgtrnbank','N');
                        obj_row_children.put(to_char(v_row1-1),obj_children);
                    end loop;
                end if;
            else   --กรณีไม่เจอข้อมูล
                if v_count_not_found > 0 then
                    begin
                        select max(dteyrepay)
                          into v_where_year
                          from tdtepay
                         where dteyrepay < p_dteyrepay
                           and codcompy = p_codcompy
                           and typpayroll = p_typpayroll
                      order by dteyrepay;
                    exception when others then null;
                    end;
                    v_diff_year := p_dteyrepay - v_where_year;
                    for c in c3 loop
                        v_row1 := v_row1 + 1;
                        if v_row1 <= p_qtynumpay then
                            obj_children := json_object_t();
                            obj_children.put('flgAdd',true);
                            obj_children.put('numperiod',c.numperiod);
                            obj_children.put('dtestrt',nvl(to_char(add_months(c.dtestrt,(12 * v_diff_year)), 'dd/mm/yyyy'),''));
                            obj_children.put('dteend',nvl(to_char(add_months(c.dteend,(12 * v_diff_year)), 'dd/mm/yyyy'),''));
                            obj_children.put('dtepaymt',nvl(to_char(add_months(c.dtepaymt,(12 * v_diff_year)), 'dd/mm/yyyy'),''));
                            obj_children.put('dtewatch',nvl(to_char(add_months(c.dteend,(12 * v_diff_year)), 'dd/mm/yyyy'),''));
                            obj_children.put('timwatch','0800');
                            obj_children.put('flgcal','N');
                            obj_children.put('flgtrnbank','N');
                            obj_row_children.put(to_char(v_row1-1),obj_children);
                        end if;
                    end loop;

                    if v_row1 < p_qtynumpay then
                        for i in (v_row1+1)..p_qtynumpay loop
                            v_row1 := v_row1 + 1;
                            obj_children := json_object_t();
                            obj_children.put('flgAdd',true);
                            obj_children.put('numperiod','');
                            obj_children.put('dtestrt','');
                            obj_children.put('dteend','');
                            obj_children.put('dtepaymt','');
                            obj_children.put('dtewatch','');
                            obj_children.put('timwatch','');
                            obj_children.put('flgcal','N');
                            obj_children.put('flgtrnbank','N');
                            obj_row_children.put(to_char(v_row1-1),obj_children);
                        end loop;
                    end if;
                else
                    for r_period in 1..p_qtynumpay loop
                        v_row1 := v_row1 + 1;
                        obj_children := json_object_t();
                        obj_children.put('flgAdd',true);
                        obj_children.put('numperiod','');
                        obj_children.put('dtestrt','');
                        obj_children.put('dteend','');
                        obj_children.put('dtepaymt','');
                        obj_children.put('dtewatch','');
                        obj_children.put('timwatch','');
                        obj_children.put('flgcal','N');
                        obj_children.put('flgtrnbank','N');
                        obj_row_children.put(to_char(v_row1-1),obj_children);
                    end loop;
                end if;
            end if;
            v_rcnt      := v_rcnt + 1;
            obj_data    := json_object_t();
            obj_data.put('dtemthpay',r_month);
            obj_data.put('children',obj_row_children);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index_tab1;

    procedure get_index_tab2(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        obj_data            json_object_t;
        obj_children        json_object_t;
        obj_row             json_object_t;
        obj_row_children    json_object_t;
        v_rcnt              number := 0;
        v_row1		        number := 0;
        v_dtemthpay         tdtepay.dtemthpay%type;

        cursor c_tdtepay2 is
          select *
            from tdtepay2
           where dteyrepay  = p_dteyrepay
             and codcompy   = p_codcompy
             and typpayroll = p_typpayroll
             and dtemthpay = v_dtemthpay
          order by dtemthpay, numperiod;
    begin
        initial_value(json_str_input);
        validate_get_index(p_codcompy,p_typpayroll);

        if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        obj_row             := json_object_t();
        obj_row_children    := json_object_t();

        for r_month in 1..12 loop
            obj_row_children := json_object_t();
            v_row1 := 0;
            v_dtemthpay := r_month;
            for r1 in c_tdtepay2 loop
                v_row1          := v_row1 + 1;
                obj_children    := json_object_t();
                obj_children.put('numperiod',r1.numperiod);
                obj_children.put('dtepaymt',nvl(to_char(r1.dtepaymt, 'dd/mm/yyyy'),''));
                obj_children.put('dtewatch',nvl(to_char(r1.dtewatch, 'dd/mm/yyyy'),''));
                obj_children.put('timwatch',nvl(r1.timwatch,''));
                obj_children.put('flgtrnbank',check_flgtrnbank(p_codcompy,p_typpayroll,p_dteyrepay,v_dtemthpay,r1.numperiod));
                obj_row_children.put(to_char(v_row1-1),obj_children);
            end loop;

            if v_row1 = 0 then
                v_row1          := v_row1 + 1;
                obj_children    := json_object_t();
                obj_children.put('flgAdd',true);
                obj_children.put('numperiod','');
                obj_children.put('dtepaymt','');
                obj_children.put('dtewatch','');
                obj_children.put('timwatch','');
                obj_children.put('flgtrnbank','N');
                obj_row_children.put(to_char(v_row1-1),obj_children);
            end if;

            v_rcnt      := v_rcnt + 1;
            obj_data    := json_object_t();
            obj_data.put('dtemthpay',r_month);
            obj_data.put('children',obj_row_children);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;

        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index_tab2;

    procedure get_copy_tab1(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        obj_data            json_object_t;
        obj_children        json_object_t;
        obj_row             json_object_t;
        obj_row_children    json_object_t;
        v_rcnt              number := 0;
        v_row1		        number := 0;
        v_count_found       number := 0;
        v_count_not_found   number := 0;
        v_where_year        number := 0;
        v_diff_year         number := 1;
        v_dtemthpay         tdtepay.dtemthpay%type;

        cursor c_tdtepay is
          select *
            from tdtepay
           where dteyrepay  = p_dteyrepay_query
             and codcompy   = p_codcompy_query
             and typpayroll = p_typpayroll_query
             and dtemthpay = v_dtemthpay
           order by dtemthpay, numperiod;

    begin
        initial_value(json_str_input);

        if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        v_diff_year := p_dteyrepay - p_dteyrepay_query;
        obj_row             := json_object_t();
        obj_row_children    := json_object_t();
        for r_month in 1..12 loop
            obj_row_children    := json_object_t();
            v_row1              := 0;
            v_dtemthpay         := r_month;
            for r1 in c_tdtepay loop
                v_row1      := v_row1 + 1;
                if v_row1 <= p_qtynumpay then
                    obj_children    := json_object_t();
                    obj_children.put('flgAdd',true);
                    obj_children.put('numperiod',r1.numperiod);
                    obj_children.put('dtestrt',nvl(to_char(add_months(r1.dtestrt,(12 * v_diff_year)), 'dd/mm/yyyy'),''));
                    obj_children.put('dteend',nvl(to_char(add_months(r1.dteend,(12 * v_diff_year)), 'dd/mm/yyyy'),''));
                    obj_children.put('dtepaymt',nvl(to_char(add_months(r1.dtepaymt,(12 * v_diff_year)), 'dd/mm/yyyy'),''));
                    --<<User37 #6155 19/03/2022  
                    obj_children.put('dtewatch',nvl(to_char(add_months(r1.dtewatch,(12 * v_diff_year)), 'dd/mm/yyyy'),''));
                    --obj_children.put('dtewatch',nvl(to_char(add_months(r1.dteend,(12 * v_diff_year)), 'dd/mm/yyyy'),''));
                    -->>User37 #6155 19/03/2022   
                    obj_children.put('timwatch',nvl(r1.timwatch,''));
                    obj_children.put('flgcal','N');
                    obj_children.put('flgtrnbank',check_flgtrnbank(p_codcompy,p_typpayroll,p_dteyrepay,v_dtemthpay,r1.numperiod));
                    obj_row_children.put(to_char(v_row1-1),obj_children);
                end if;
            end loop;

            if v_row1 < p_qtynumpay then
                for i in (v_row1+1)..p_qtynumpay loop
                    v_row1 := v_row1 + 1;
                    obj_children := json_object_t();
                    obj_children.put('numperiod','');
                    obj_children.put('flgAdd',true);
                    obj_children.put('dtestrt','');
                    obj_children.put('dteend','');
                    obj_children.put('dtepaymt','');
                    obj_children.put('dtewatch','');
                    obj_children.put('timwatch','');
                    obj_children.put('flgcal','N');
                    obj_children.put('flgtrnbank','N');
                    obj_row_children.put(to_char(v_row1-1),obj_children);
                end loop;
            end if;
            v_rcnt      := v_rcnt + 1;
            obj_data    := json_object_t();
            obj_data.put('dtemthpay',r_month);
            obj_data.put('children',obj_row_children);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_copy_tab1;

    procedure get_copy_tab2(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        obj_data            json_object_t;
        obj_children        json_object_t;
        obj_row             json_object_t;
        obj_row_children    json_object_t;
        v_rcnt              number := 0;
        v_row1		        number := 0;
        v_dtemthpay         tdtepay.dtemthpay%type;

        cursor c_tdtepay2 is
          select *
            from tdtepay2
           where dteyrepay  = p_dteyrepay_query
             and codcompy   = p_codcompy_query
             and typpayroll = p_typpayroll_query
             and dtemthpay = v_dtemthpay
          order by dtemthpay, numperiod;
    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);

        if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        obj_row             := json_object_t();
        obj_row_children    := json_object_t();

        for r_month in 1..12 loop
            obj_row_children := json_object_t();
            v_row1 := 0;
            v_dtemthpay := r_month;
            for r1 in c_tdtepay2 loop
                v_row1          := v_row1 + 1;
                obj_children    := json_object_t();
                 obj_children.put('flgAdd',true);
                obj_children.put('numperiod',r1.numperiod);
                obj_children.put('dtepaymt',nvl(to_char(r1.dtepaymt, 'dd/mm/yyyy'),''));
                obj_children.put('dtewatch',nvl(to_char(r1.dtewatch, 'dd/mm/yyyy'),''));
                obj_children.put('timwatch',nvl(r1.timwatch,''));
                obj_children.put('flgtrnbank',check_flgtrnbank(p_codcompy,p_typpayroll,p_dteyrepay,v_dtemthpay,r1.numperiod));
                obj_row_children.put(to_char(v_row1-1),obj_children);
            end loop;

            if v_row1 = 0 then
                v_row1          := v_row1 + 1;
                obj_children    := json_object_t();
                obj_children.put('flgAdd',true);
                obj_children.put('numperiod','');
                obj_children.put('dtepaymt','');
                obj_children.put('dtewatch','');
                obj_children.put('timwatch','');
                obj_children.put('flgtrnbank','N');
                obj_row_children.put(to_char(v_row1-1),obj_children);
            end if;

            v_rcnt      := v_rcnt + 1;
            obj_data    := json_object_t();
            obj_data.put('dtemthpay',r_month);
            obj_data.put('children',obj_row_children);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;

        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_copy_tab2;

    function check_duplicate(p_codcompy varchar2,p_typpayroll varchar2,p_dteyrepay number,p_dtemthpay number,p_numperiod number,p_tab number) return boolean is
        v_count number := 0;
        v_count_dup_table number := 0;
    begin
        if p_tab = 1 then
            select count(*)
              into v_count
              from tdtepay
             where codcompy = p_codcompy
               and typpayroll = p_typpayroll
               and dteyrepay = p_dteyrepay
               and dtemthpay = p_dtemthpay
               and numperiod = p_numperiod;

            if v_count > 0 then
                return false;
            end if;
        else
            select count(*)
              into v_count
              from tdtepay2
             where codcompy = p_codcompy
               and typpayroll = p_typpayroll
               and dteyrepay = p_dteyrepay
               and dtemthpay = p_dtemthpay
               and numperiod = p_numperiod;

            if v_count > 0 then
                return false;
            end if;
        end if;
        return true;
    end;

    procedure get_copy_list(json_str_input in clob, json_str_output out clob) as
        json_obj        json_object_t;
        obj_row         json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_secure        varchar2(4000 char) := null;
        cursor c1 is
            select distinct dteyrepay,codcompy,typpayroll
              from tdtepay
             where codcompy <> p_codcompy
                or dteyrepay <> p_dteyrepay
                or typpayroll <> p_typpayroll
          order by dteyrepay desc,codcompy,typpayroll;
    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        p_dteyrepay     := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
        p_codcompy      := hcm_util.get_string_t(json_obj,'p_codcompy');
        p_typpayroll    := hcm_util.get_string_t(json_obj,'p_typpayroll');
        obj_row         := json_object_t();
        for i in c1 loop
            v_secure := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,i.codcompy);
            if v_secure is null then
                v_row       := v_row + 1;
                obj_data    := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('codcompy',i.codcompy);
                obj_data.put('typpayroll',i.typpayroll);
                obj_data.put('dteyrepay',to_char(i.dteyrepay));
                obj_data.put('descod',get_tcodec_name('TCODTYPY', i.typpayroll, global_v_lang));
                obj_row.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        json_str_output := obj_row.to_clob;
        exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_copy_list;

    function change_year(target_date date,old_year number,new_year number) return varchar2 is
        str_date varchar2(100 char) := '';
    begin
        if target_date is null then
            return str_date;
        end if;
        str_date := to_char(target_date, 'dd/mm/yyyy');
        return substr(str_date, 1, length(str_date) - 4)||''||to_char(new_year);
    end;

    procedure copy_detail(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        obj_data            json_object_t;
        obj_tab1            json_object_t;
        obj_tab2            json_object_t;
        obj_row             json_object_t;
        p_copyto_codcomp    varchar2(4 char);
        p_copyto_year       number(4,0);
        v_row1		        number := 0;
        v_row2		        number := 0;

        cursor c1 is
            select *
              from tdtepay
             where dteyrepay = p_dteyrepay
               and codcompy = p_codcompy
               and typpayroll = p_typpayroll
          order by dtemthpay, numperiod;
    begin
        initial_value(json_str_input);
        json_obj            := json_object_t(json_str_input);
        p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'year'));
        p_codcompy          := hcm_util.get_string_t(json_obj,'codcomp');
        p_typpayroll        := hcm_util.get_string_t(json_obj,'codtypy');
        p_copyto_codcomp    := hcm_util.get_string_t(json_obj,'copyto_codcomp');
        p_copyto_year       := to_number(hcm_util.get_string_t(json_obj,'copyto_year'));

        obj_row    := json_object_t();
        obj_tab1   := json_object_t();
        obj_tab2   := json_object_t();
        -- tab 1
        for i in c1 loop
            v_row1 := v_row1 + 1;
            obj_data := json_object_t();
            obj_data.put('codcompy',p_copyto_codcomp);
            obj_data.put('typpayroll',i.typpayroll);
            obj_data.put('dteyrepay',to_char(p_dteyrepay));
            obj_data.put('dtemthpay',to_char(i.dtemthpay));
            obj_data.put('numperiod',i.numperiod);
            obj_data.put('qtynumpay',i.qtynumpay);
            obj_data.put('dtestrt',change_year(i.dtestrt,i.dteyrepay,p_copyto_year));
            obj_data.put('dteend',change_year(i.dteend,i.dteyrepay,p_copyto_year));
            obj_data.put('dtepaymt',change_year(i.dtepaymt,i.dteyrepay,p_copyto_year));
            obj_data.put('flgcal','');
            obj_data.put('qtypermth',to_char(i.qtypermth));
            obj_data.put('dtewatch',change_year(i.dtewatch,i.dteyrepay,p_copyto_year));
            if i.timwatch != '' then
                obj_data.put('timwatch',substr( i.timwatch, 1, 2 ) || ':' || substr( i.timwatch, 3 ));
            else
                obj_data.put('timwatch',i.timwatch);
            end if;
            obj_data.put('dtecreate',to_char(sysdate, 'dd/mm/yyyy'));
            obj_data.put('codcreate','');
            obj_data.put('dteupd','');
            obj_data.put('coduser','');
            obj_tab1.put(to_char(v_row1-1),obj_data);
        end loop;
        -- tab 2

        obj_row.put('coderror', '200');
        obj_row.put('tab1', obj_tab1);
        obj_row.put('tab2', obj_tab2);

        json_str_output := obj_row.to_clob;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end copy_detail;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        params_tab1         json_object_t;
        obj_month           json_object_t;
        params_children     json_object_t;
        obj_children        json_object_t;
        v_numperiod         tdtepay.numperiod%type;
        v_numperiod_old     tdtepay.numperiod%type;
        v_qtynumpay         tdtepay.qtynumpay%type  := 0;
        v_dtestrt           tdtepay.dtestrt%type;
        v_dteend            tdtepay.dteend%type;
        v_dtepaymt          tdtepay.dtepaymt%type;
        v_flgcal            tdtepay.flgcal%type;
        v_qtypermth         tdtepay.qtypermth%type;
        v_dtewatch          tdtepay.dtewatch%type;
        v_timwatch          tdtepay.timwatch%type;
        v_flgadd            varchar2(10 char);
        v_flgedit           varchar2(10 char);
        v_flgdelete         varchar2(10 char);
        params_tab2         json_object_t;
        iscopy              varchar2(1 char) := 'N';
        v_count_children    number  := 0;
        v_count_month       number := 0;
        v_count_dup         number;
        v_dtemthpay         tdtepay.dtemthpay%type;
        v_flg               varchar2(100);

        v_last_date         date;

        cursor c1 is
            select tdtepay.*
              from tdtepay
             where codcompy = p_codcompy
               and typpayroll = p_typpayroll
               and dteyrepay = p_dteyrepay
          order by dtemthpay, numperiod, dtestrt;
    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        isCopy          := hcm_util.get_string_t(json_obj, 'isCopy');
        param_json      := hcm_util.get_json_t(json_obj,'param_json');
        params_tab1     := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'tab1'),'table1');
        params_tab2     := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'tab2'),'table2');
        -- case copy
        if isCopy = 'Y' then
            delete
              from tdtepay
             where codcompy = p_codcompy
               and typpayroll = p_typpayroll
               and dteyrepay = p_dteyrepay;

            delete
              from tdtepay2
             where codcompy = p_codcompy
               and typpayroll = p_typpayroll
               and dteyrepay = p_dteyrepay;
        end if; -- case copy

        for i_t1 in 0..params_tab1.get_size-1 loop
            obj_month           := hcm_util.get_json_t(params_tab1,to_char(i_t1));
            params_children     := hcm_util.get_json_t(obj_month,'children');
            v_count_children    := params_children.get_size;
            v_dtemthpay         := hcm_util.get_string_t(obj_month,'dtemthpay');
            for t_c1 in 0..params_children.get_size-1 loop
                obj_children        := hcm_util.get_json_t(params_children,to_char(t_c1));
                v_flgadd            := hcm_util.get_string_t(obj_children,'flgAdd');
                v_flgedit           := hcm_util.get_string_t(obj_children,'flgEdit');
                v_flgdelete         := hcm_util.get_string_t(obj_children,'flgDelete');
                v_numperiod         := to_number(hcm_util.get_string_t(obj_children,'numperiod'));
                v_numperiod_old     := hcm_util.get_string_t(obj_children,'numperiodOld');
                v_dtestrt           := to_date(hcm_util.get_string_t(obj_children,'dtestrt'),'dd/mm/yyyy');
                v_dteend            := to_date(hcm_util.get_string_t(obj_children,'dteend'),'dd/mm/yyyy');
                v_dtepaymt          := to_date(hcm_util.get_string_t(obj_children,'dtepaymt'),'dd/mm/yyyy');
                v_flgcal            := hcm_util.get_string_t(obj_children,'flgcal');
                v_dtewatch          := to_date(hcm_util.get_string_t(obj_children,'dtewatch'),'dd/mm/yyyy');
                v_timwatch          := replace(hcm_util.get_string_t(obj_children,'timwatch'),':','');
                v_flg               := hcm_util.get_string_t(obj_children,'flg');

                if v_flg = 'add' then
                    -- ซ้ำในตาราง
                    if check_duplicate(p_codcompy,p_typpayroll,p_dteyrepay,v_dtemthpay,v_numperiod,1) = false then
                        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tdtepay');
                        exit;
                    end if;
                    -- ซ้ำกับตารางอื่น
                    if check_duplicate(p_codcompy,p_typpayroll,p_dteyrepay,v_dtemthpay,v_numperiod,2) = false then
                        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tdtepay2');
                        exit;
                    end if;

--                    if v_numperiod > p_qtynumpay then
--                        param_msg_error := 'งวดต้องอยู่ในช่วง 1 ถึง '|| p_qtynumpay;
--                        exit;
--                    end if;
                    begin
                        insert into tdtepay (codcompy,typpayroll,dteyrepay,dtemthpay,numperiod,qtynumpay
                                    ,dtestrt,dteend,dtepaymt,flgcal,qtypermth,dtewatch,timwatch,dtecreate
                                    ,codcreate,coduser,dteupd)
                             values (p_codcompy,p_typpayroll,p_dteyrepay,v_dtemthpay,v_numperiod
                                    ,v_qtynumpay,v_dtestrt,v_dteend,v_dtepaymt,v_flgcal,v_count_children
                                    ,v_dtewatch,v_timwatch,sysdate,global_v_coduser,global_v_coduser
                                    ,sysdate);
                    exception when dup_val_on_index then
                        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tdtepay');
                        exit;
                    end;
                elsif v_flg = 'edit' then
                    if check_editable(p_codcompy,p_typpayroll,p_dteyrepay,v_dtemthpay,v_numperiod,1) = false then
                        param_msg_error := get_error_msg_php('HR1501',global_v_lang);
                        exit;
                    end if;

                    update tdtepay
                       set qtynumpay  = v_qtynumpay,
                           dtestrt    = v_dtestrt,
                           dteend     = v_dteend,
                           dtepaymt   = v_dtepaymt,
                           qtypermth  = v_count_children,
                           dtewatch   = v_dtewatch,
                           timwatch   = v_timwatch,
                           dteupd     = sysdate,
                           coduser    = global_v_coduser
                     where codcompy   = p_codcompy
                       and typpayroll = p_typpayroll
                       and dteyrepay  = p_dteyrepay
                       and dtemthpay  = v_dtemthpay
                       and numperiod  = v_numperiod;
                elsif v_flg = 'delete' then
                    if check_editable(p_codcompy,p_typpayroll,p_dteyrepay,v_dtemthpay,v_numperiod,1) = false then
                        param_msg_error := get_error_msg_php('HR1501',global_v_lang);
                        exit;
                    end if;

                    delete from tdtepay
                     where codcompy   = p_codcompy
                       and typpayroll = p_typpayroll
                       and dteyrepay  = p_dteyrepay
                       and dtemthpay  = v_dtemthpay
                       and numperiod  = v_numperiod
                       and (flgcal is null or upper(flgcal) = 'N');
                end if;
            end loop;

            if param_msg_error is null then
                select count(*)
                  into v_qtypermth
                  from tdtepay
                 where codcompy   = p_codcompy
                   and typpayroll = p_typpayroll
                   and dteyrepay  = p_dteyrepay
                   and dtemthpay = v_dtemthpay;

                update tdtepay
                   set qtypermth  = v_qtypermth
                 where codcompy   = p_codcompy
                   and typpayroll = p_typpayroll
                   and dteyrepay  = p_dteyrepay
                   and dtemthpay = v_dtemthpay;

--                if p_qtynumpay <> v_qtypermth then
--                    param_msg_error := get_error_msg_php('PY0064',global_v_lang);
--                end if;
            end if;

            if param_msg_error is not null then
                exit;
            end if;
        end loop; --tab1

        if param_msg_error is null then
            select count(*)
              into v_qtynumpay
              from tdtepay
             where codcompy   = p_codcompy
               and typpayroll = p_typpayroll
               and dteyrepay  = p_dteyrepay;

            update tdtepay set
                   qtynumpay  = v_qtynumpay
             where codcompy   = p_codcompy
               and typpayroll = p_typpayroll
               and dteyrepay  = p_dteyrepay;

            select count( distinct dtemthpay)
              into v_count_month
              from tdtepay
             where codcompy   = p_codcompy
               and typpayroll = p_typpayroll
               and dteyrepay  = p_dteyrepay;

            if (p_qtynumpay*12) <> v_qtynumpay then
                param_msg_error := get_error_msg_php('PY0064',global_v_lang);
            end if;
            if v_count_month <> 12 then
                param_msg_error := get_error_msg_php('PY0063',global_v_lang);
            end if;
        end if;
        v_last_date := null;
        if param_msg_error is null then
            for r1 in c1 loop
                if v_last_date is not null then
                    if (v_last_date + 1) <> r1.dtestrt then
                        param_msg_error := get_error_msg_php('PY0065',global_v_lang);
                        exit;
                    end if;
                end if;
                v_last_date := r1.dteend;
            end loop;
        end if;

        -- tab2
        if param_msg_error is null then
            for i_t2 in 0..params_tab2.get_size-1 loop
                obj_month   := hcm_util.get_json_t(params_tab2,to_char(i_t2));
                params_children     := hcm_util.get_json_t(obj_month,'children');
                v_dtemthpay         := hcm_util.get_string_t(obj_month,'dtemthpay');
                for t_c2 in 0..params_children.get_size-1 loop
                    obj_children := hcm_util.get_json_t(params_children,to_char(t_c2));
                    v_flgadd     := hcm_util.get_string_t(obj_children,'flgAdd');
                    v_flgedit    := hcm_util.get_string_t(obj_children,'flgEdit');
                    v_flgdelete  := hcm_util.get_string_t(obj_children,'flgDelete');
                    v_numperiod  := to_number(hcm_util.get_string_t(obj_children,'numperiod'));
                    v_dtepaymt   := to_date(hcm_util.get_string_t(obj_children,'dtepaymt'),'dd/mm/yyyy');
                    v_dtewatch   := to_date(hcm_util.get_string_t(obj_children,'dtewatch'),'dd/mm/yyyy');
                    v_timwatch   := replace(hcm_util.get_string_t(obj_children,'timwatch'),':','');
                    v_numperiod_old     := hcm_util.get_string_t(obj_children,'numperiodOld');
----------------------------  09/11/2020-------------<<
                    v_flg               := hcm_util.get_string_t(obj_children,'flg');
                    if v_flg  = 'add' and v_numperiod is not null then
                        -- ซ้ำในตาราง
                        if check_duplicate(p_codcompy,p_typpayroll,p_dteyrepay,v_dtemthpay,v_numperiod,2) = false then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tdtepay2');
                            exit;
                        end if;
                        -- ซ้ำกับตารางอื่น
                        if check_duplicate(p_codcompy,p_typpayroll,p_dteyrepay,v_dtemthpay,v_numperiod,1) = false then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tdtepay');
                            exit;
                        end if;

                        begin
                            insert into tdtepay2 (codcompy,typpayroll,dteyrepay,dtemthpay,numperiod,dtepaymt
                                                 ,dtewatch,timwatch,dtecreate,codcreate,coduser)
                                 values (p_codcompy,p_typpayroll,p_dteyrepay,v_dtemthpay,v_numperiod
                                        ,v_dtepaymt,v_dtewatch,v_timwatch,sysdate,global_v_coduser,global_v_coduser);
                        exception when dup_val_on_index then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tdtepay2');
                            exit;
                        end;
                    elsif v_flg= 'edit'  and v_numperiod is not null then
                        update tdtepay2 set
                            dtepaymt   = v_dtepaymt,
                            dtewatch   = v_dtewatch,
                            timwatch   = v_timwatch,
                            dteupd     = sysdate,
                            coduser    = global_v_coduser
                        where
                            codcompy   = p_codcompy and
                            typpayroll = p_typpayroll and
                            dteyrepay  = p_dteyrepay and
                            dtemthpay  = v_dtemthpay and
                            numperiod  = v_numperiod;
                    elsif v_flg = 'delete' then
                        delete from tdtepay2
                        where
                            codcompy   = p_codcompy and
                            typpayroll = p_typpayroll and
                            dteyrepay  = p_dteyrepay and
                            dtemthpay  = v_dtemthpay and
                            numperiod  = v_numperiod;
                    end if;
----------------------------  09/11/2020------------->>
                end loop;
                if param_msg_error is not null then
                    exit;
                end if;
            end loop; -- tab2
        end if;

        if param_msg_error is null then
            commit;
            if v_flg = 'delete' then
                param_msg_error := get_error_msg_php('HR2425',global_v_lang);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            else
                param_msg_error := get_error_msg_php('HR2401',global_v_lang);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            end if;
        else
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

    procedure get_default_period(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        obj_data            json_object_t;
        v_where_year        number := 0;
        v_numperiod         number;
    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        obj_data        := json_object_t();

        begin
            select max(dteyrepay)
              into v_where_year
              from tdtepay
             where dteyrepay <= p_dteyrepay
               and codcompy = p_codcompy
               and typpayroll = p_typpayroll
            order by dteyrepay;
        exception when others then
            null;
        end;

        begin
          select round(qtynumpay/12)
            into v_numperiod
            from tdtepay
           where dteyrepay = v_where_year
             and codcompy = p_codcompy
             and typpayroll = p_typpayroll
             and rownum = 1;
        exception when others then
            v_numperiod := null;
        end;

        obj_data.put('qtynumpay',v_numperiod);
        obj_data.put('coderror','200');
        json_str_output := obj_data.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_default_period;
    
    procedure get_flggen(json_str_input in clob, json_str_output out clob) as
        obj_data    json_object_t;
        v_chk       varchar2(1 char) := 'N';
    begin
        initial_value(json_str_input);

        for i in 1..12 loop
            v_chk := check_flgtrnbank(p_codcompy,p_typpayroll,p_dteyrepay,i,null);--nut get_flgdisable(p_codcompy ,p_typpayroll ,p_dteyrepay ,i);
            if v_chk = 'Y' then
                exit;
            end if;
            begin
              select 'Y'
                into v_chk
                from tdtepay
               where dteyrepay  = p_dteyrepay
                 and codcompy   = p_codcompy
                 and typpayroll = p_typpayroll
                 and dtemthpay  = i
                 and flgcal     = 'Y'
                 and rownum     = 1;
            exception when no_data_found then
              v_chk := 'N';
            end;
            if v_chk = 'Y' then
                exit;
            end if;
        end loop;

        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('flgGen',v_chk);
        json_str_output := obj_data.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_flggen;
    
    procedure get_qtynumpay(json_str_input in clob, json_str_output out clob) as
        obj_data    json_object_t;
        v_chk       varchar2(1 char);
        v_qtynumpay number;
    begin
        initial_value(json_str_input);

        for i in 1..12 loop
            v_chk := check_flgtrnbank(p_codcompy,p_typpayroll,p_dteyrepay,i,null);--nut get_flgdisable(p_codcompy ,p_typpayroll ,p_dteyrepay ,i);
            if v_chk = 'Y' then
                exit;
            end if;
        end loop;
        
        if nvl(v_chk,'N') = 'Y' then
          begin
            select max(qtynumpay)/12
              into v_qtynumpay
              from tdtepay
             where dteyrepay  = p_dteyrepay
               and codcompy   = p_codcompy
               and typpayroll = p_typpayroll;
          exception when no_data_found then
            v_qtynumpay := p_qtynumpay;
          end;
        else
          v_qtynumpay := p_qtynumpay;
        end if;

        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('qtynumpay',v_qtynumpay);
        json_str_output := obj_data.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_qtynumpay;
    
    procedure get_copy_flggen(json_str_input in clob, json_str_output out clob) as
        obj_data    json_object_t;
        v_chk       varchar2(1 char);
    begin
        initial_value(json_str_input);
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('flgGen','Y');
        json_str_output := obj_data.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_copy_flggen;
    
    procedure get_copy_qtynumpay(json_str_input in clob, json_str_output out clob) as
        obj_data    json_object_t;
        v_chk       varchar2(1 char);
    begin
        initial_value(json_str_input);
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('qtynumpay',p_qtynumpay);
        json_str_output := obj_data.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_copy_qtynumpay;
end HRPY1DE;

/

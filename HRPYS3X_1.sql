--------------------------------------------------------
--  DDL for Package Body HRPYS3X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYS3X" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_year          := hcm_util.get_string_t(json_obj,'p_year');
        p_report        := hcm_util.get_string_t(json_obj,'p_report');
        json_codpay     := hcm_util.get_json_t(json_obj,'p_codpay');
        json_codgrbug   := hcm_util.get_json_t(json_obj,'p_codgrbug');
        json_month     := hcm_util.get_json_t(json_obj,'p_months');
    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
        v_secur boolean;
        v_codpay    tytdinc.codpay%type;
        v_codgrbug  tcodgrbug.codcodec%type;
    begin
        -- à¸šà¸±à¸‡à¸„à¸±à¸šà¹ƒà¸ªà¹ˆà¸‚à¹‰à¸­à¸¡à¸¹à¸¥ à¸£à¸«à¸±à¸ªà¸žà¸™à¸±à¸�à¸‡à¸²à¸™ , à¸ªà¸²à¸«à¸£à¸±à¸šà¸›à¸µ
        if (p_year is null) or (p_report is null) or (json_codpay.get_size = 0) or (json_codgrbug.get_size = 0) or (json_month.get_size = 0) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- à¸£à¸«à¸±à¸ªà¸£à¸²à¸¢à¹„à¸”à¹‰ à¸•à¸£à¸§à¸ˆà¸ªà¸­à¸šà¸£à¸«à¸±à¸ªà¸•à¹‰à¸­à¸‡à¸¡à¸µà¸­à¸¢à¸¹à¹ˆà¹ƒà¸™à¸•à¸²à¸£à¸²à¸‡ TINEXINF (HR2010 TINEXINF)
        for i in 0..json_codpay.get_size-1 loop
            v_codpay := hcm_util.get_string_t(json_codpay,to_char(i));
            begin
                select 'X' into v_temp from tinexinf where codpay = v_codpay;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TINEXINF');
                return;
            end;
        end loop;
        -- à¸£à¸«à¸±à¸ªà¸�à¸¥à¸¸à¹ˆà¸¡à¸‡à¸šà¸›à¸£à¸°à¸¡à¸²à¸“ à¸•à¸£à¸§à¸ˆà¸ªà¸­à¸šà¸£à¸«à¸±à¸ªà¸•à¹‰à¸­à¸‡à¸¡à¸µà¸­à¸¢à¸¹à¹ˆà¹ƒà¸™à¸•à¸²à¸£à¸²à¸‡ TCODGRBUG (HR2010 TCODGRBUG)
        for i in 0..json_codgrbug.get_size-1 loop
            v_codgrbug := hcm_util.get_string_t(json_codgrbug,to_char(i));
            begin
                select 'X' into v_temp from tcodgrbug where codcodec = v_codgrbug;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODGRBUG');
                return;
            end;
        end loop;
    end check_index;

    function get_amtpay(v_codpay varchar2,v_syscond varchar2,v_month varchar2) return number as
        v_stmt            VARCHAR2(10000 char);
        v_stmt_select     VARCHAR2(10000 char);
        v_where           VARCHAR2(1000 char) := '';
        v_cursor          number;
        v_dummy           number;
        v_data            varchar2(200 char);
        v_amtpay          number;
        v_row_count       number;
        v_stmt_report     varchar2(4000 char);
    begin
        if v_syscond is not null then
            v_where := ' where '||v_syscond;
        end if;
        if v_month = 'A' then
            v_stmt_select := 'select (';
            for i in 1..12 loop
                v_stmt_select := v_stmt_select||'nvl(sum(nvl(stddec(amtpay'||i||',a.codempid,hcm_secur.get_v_chken),0)),0) ';
                if i != 12 then
                    v_stmt_select := v_stmt_select||'+ ';
                end if;
            end loop;
            v_stmt_select := v_stmt_select||') amtpay,count(*) row_count ';
        else
            v_stmt_select := ' select
                        nvl(sum(nvl(stddec(amtpay'||v_month||',a.codempid,hcm_secur.get_v_chken),0)),0) amtpay,count(*) row_count ';
        end if;
        if p_report = '3' then
          v_stmt_report := ' where b.dteyrepay = '''||p_year||'''
                               and b.dtemthpay = '''||v_month||''' ';
        else
          v_stmt_report := ' where b.dteyrepay = '''||p_year||'''
                               and (('''||v_month||''' <> ''A''
                               and b.dtemthpay = '''||v_month||''' )
                                or ('''||v_month||''' = ''A''
                               and  b.dtemthpay = (select max(dtemthpay)
                                                     from ttaxcur c
                                                    where c.codempid  = b.codempid
                                                      and c.dteyrepay = '''||p_year||'''))) ';
        end if;
        v_stmt := v_stmt_select||'
                    from tytdinc a
                    where dteyrepay = '''||p_year||'''
                    and codpay = '''||v_codpay||'''
                    and a.codempid  in (select b.codempid
	 						                           from ttaxcur b '||v_stmt_report||'
	 						                            and b.numlvl between '||global_v_numlvlsalst||' and '||global_v_numlvlsalen||'
												 						      and 0 <> (select count(c.codcomp)
												                              from tusrcom c
																			               where c.coduser = '''||global_v_coduser||'''
																			                 and b.codcomp like c.codcomp||''%''
																			                 and rownum    <= 1 )
	 						                            and b.codempid in (select codempid from temploy1 '||v_where||'))
                    group by a.codpay
                    order by a.codpay';
        v_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
        dbms_sql.define_column(v_cursor,1,v_data,10000);
        dbms_sql.define_column(v_cursor,2,v_row_count);
        v_dummy  := dbms_sql.execute(v_cursor);
        while (dbms_sql.fetch_rows(v_cursor) > 0) loop
            dbms_sql.column_value(v_cursor,1,v_data);
            dbms_sql.column_value(v_cursor,2,v_row_count);
        end loop;
        v_amtpay := v_data;
        p_amtpay_count := p_amtpay_count + v_row_count;
        dbms_sql.close_cursor(v_cursor);--user37 #5039 Final Test Phase 1 V11 29/09/2021 
        if v_amtpay > 0 then
          return v_amtpay;
        else
          return null;
        end if;
    end get_amtpay;

    procedure create_graph_data(v_numseq number,v_name varchar2,v_value varchar2) as
        v_item4  varchar2(4 char);
        v_item8  ttemprpt.item8%type;
        v_item9  ttemprpt.item9%type;
        v_item31 ttemprpt.item31%type;
    begin
        v_item4 := to_char(lpad(v_numseq,2,0));
        v_item8 := get_label_name('HRPYS3X',global_v_lang,'80');
        v_item9 := get_label_name('HRPYS3X',global_v_lang,'80');
        v_item31 := get_label_name('HRPYS3X',global_v_lang,'100');
        insert into ttemprpt (codempid,codapp,numseq,item4,item5,item8,item9,item10,item31)
        values (global_v_codempid,'HRPYS3X',v_numseq,v_item4,v_name,v_item8,v_item9,v_value,v_item31);
    end create_graph_data;

    procedure gen_index(json_str_output out clob) as
        v_syscond   tcodgrbug.syscond%type;
        v_codgrbug  tcodgrbug.codcodec%type;
        v_month     varchar2(2 char);
        v_codpay    tytdinc.codpay%type;
        obj_data    json_object_t;
        obj_rows    json_object_t;
        obj_result  json_object_t;
        v_row       number := 0;
        v_amtpay    number := 0;
        v_header_1  varchar2(200 char);
        v_header_2  varchar2(200 char);
        v_header_3  varchar2(200 char);
        v_sum       number := 0;
        v_getamt    varchar2(1 char) := 'N';--User37 #5039 Final Test Phase 1 V11 25/02/2021
    begin
        delete from ttemprpt where codapp = 'HRPYS3X' and codempid = global_v_codempid;
        commit;
        if p_report = '1' then
            v_codpay := hcm_util.get_string_t(json_codpay,'0');
            v_month     := hcm_util.get_string_t(json_month,'0');
            v_header_2 := get_tlistval_name('MONTHALL',v_month,global_v_lang);
            v_header_3 := v_codpay||' - '||get_tinexinf_name(v_codpay,global_v_lang);
            obj_rows    := json_object_t();
            for i in 0..json_codgrbug.get_size-1 loop
                v_codgrbug  := hcm_util.get_string_t(json_codgrbug,to_char(i));
                begin
                    select syscond into v_syscond from tcodgrbug where codcodec = v_codgrbug;
                exception when no_data_found then
                    v_syscond := null;
                end;

                if v_syscond is not null then
                    v_row := v_row+1;
                    v_amtpay := nvl(get_amtpay(v_codpay,v_syscond,v_month),0);
                    obj_data := json_object_t();
                    obj_data.put('codcodec',v_codgrbug);
                    obj_data.put('desc_codcodec',get_tcodec_name('TCODGRBUG',v_codgrbug,global_v_lang));
                    obj_data.put('amtpay',v_amtpay);
                    obj_rows.put(to_char(v_row-1),obj_data);
                    v_sum := v_sum + to_number(hcm_util.get_string_t(obj_data,'amtpay'));
                    create_graph_data(v_row,get_tcodec_name('TCODGRBUG',v_codgrbug,global_v_lang),v_amtpay);
                    --<<User37 #5039 Final Test Phase 1 V11 25/02/2021
                    if v_amtpay > 0 then
                        v_getamt := 'Y';
                    end if;
                    -->>User37 #5039 Final Test Phase 1 V11 25/02/2021
                end if;
            end loop;
            create_graph_data(v_row+1,get_label_name('HRPYS3X',global_v_lang,290),to_char(v_sum));
        elsif p_report = '2' then   -- à¸�à¸£à¸“à¸µà¹€à¸¥à¸·à¸­à¸�à¸£à¸¹à¸›à¹�à¸šà¸šà¸£à¸²à¸¢à¸‡à¸²à¸™ à¸•à¸²à¸¡à¸£à¸«à¸±à¸ªà¸£à¸²à¸¢à¹„à¸”à¹‰/à¸ªà¹ˆà¸§à¸™à¸«à¸±à¸�
            v_codgrbug  := hcm_util.get_string_t(json_codgrbug,'0');
            v_month     := hcm_util.get_string_t(json_month,'0');
            v_header_2 := get_tlistval_name('MONTHALL',v_month,global_v_lang);
            v_header_3 := v_codgrbug||' - '||get_tcodec_name('TCODGRBUG',v_codgrbug,global_v_lang);
            begin
                select syscond into v_syscond from tcodgrbug where codcodec = v_codgrbug;
            exception when no_data_found then
                v_syscond := null;
            end;

            obj_rows    := json_object_t();
            for i in 0..json_codpay.get_size-1 loop
                v_codpay := hcm_util.get_string_t(json_codpay,to_char(i));
                if v_syscond is not null then
                    v_row := v_row+1;
                    v_amtpay := nvl(get_amtpay(v_codpay,v_syscond,v_month),0);
                    obj_data := json_object_t();
                    obj_data.put('codcodec',v_codpay);
                    obj_data.put('desc_codcodec',get_tinexinf_name(v_codpay,global_v_lang));
                    obj_data.put('amtpay',v_amtpay);
                    obj_rows.put(to_char(v_row-1),obj_data);
                    v_sum := v_sum + to_number(hcm_util.get_string_t(obj_data,'amtpay'));
                    create_graph_data(v_row,get_tinexinf_name(v_codpay,global_v_lang),v_amtpay);
                    --<<User37 #5039 Final Test Phase 1 V11 25/02/2021
                    if v_amtpay > 0 then
                        v_getamt := 'Y';
                    end if;
                    -->>User37 #5039 Final Test Phase 1 V11 25/02/2021
                end if;
            end loop;
            create_graph_data(v_row+1,get_label_name('HRPYS3X',global_v_lang,290),to_char(v_sum));
        elsif p_report = '3' then
            v_codpay := hcm_util.get_string_t(json_codpay,'0');
            v_codgrbug  := hcm_util.get_string_t(json_codgrbug,'0');
            v_header_2 := v_codgrbug||' - '||get_tcodec_name('TCODGRBUG',v_codgrbug,global_v_lang);
            v_header_3 := v_codpay||' - '||get_tinexinf_name(v_codpay,global_v_lang);
            begin
                select syscond into v_syscond from tcodgrbug where codcodec = v_codgrbug;
            exception when no_data_found then
                v_syscond := null;
            end;
            obj_rows    := json_object_t();
            for i in 0..json_month.get_size-1 loop
                v_month := hcm_util.get_string_t(json_month,to_char(i));
                if v_syscond is not null then
                    v_row := v_row+1;
                    v_amtpay := nvl(get_amtpay(v_codpay,v_syscond,v_month),0);
                    obj_data := json_object_t();
                    obj_data.put('codcodec',v_month);
                    obj_data.put('desc_codcodec',get_tlistval_name('MONTHALL',v_month,global_v_lang));
                    obj_data.put('amtpay',v_amtpay);
                    obj_rows.put(to_char(v_row-1),obj_data);
                    v_sum := v_sum + to_number(hcm_util.get_string_t(obj_data,'amtpay'));
                    create_graph_data(v_row,get_tlistval_name('MONTHALL',v_month,global_v_lang),v_amtpay);
                    --<<User37 #5039 Final Test Phase 1 V11 25/02/2021
                    if v_amtpay > 0 then
                        v_getamt := 'Y';
                    end if;
                    -->>User37 #5039 Final Test Phase 1 V11 25/02/2021
                end if;
            end loop;
            create_graph_data(v_row+1,get_label_name('HRPYS3X',global_v_lang,290),to_char(v_sum));
        end if;

        -- à¸�à¸£à¸“à¸µà¹„à¸¡à¹ˆà¸žà¸šà¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¹ƒà¸«à¹‰à¹�à¸ˆà¹‰à¸‡à¸‚à¹‰à¸­à¸„à¸§à¸²à¸¡à¹€à¸•à¸·à¸­à¸™ HR2055 (TYTDINC)
        if p_amtpay_count < 1 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYTDINC');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        elsif v_getamt = 'N' then--User37 #5039 Final Test Phase 1 V11 25/02/2021 elsif nvl(get_amtpay(v_codpay,v_syscond,v_month),0) = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYTDINC');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
        obj_data := json_object_t();
        obj_data.put('header_1',p_year);
        obj_data.put('header_2',v_header_2);
        obj_data.put('header_3',v_header_3);
        obj_data.put('rows',obj_rows);
        obj_result := json_object_t();
        obj_result.put('0',obj_data);
        json_str_output := obj_result.to_clob;
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

    procedure get_list_fields(json_str_input in clob, json_str_output out clob) as
        obj_rows json_object_t;
        obj_data json_object_t;
        v_row   number := 0;
        cursor c_codgrbug is
            select codcodec from tcodgrbug;

        cursor c_tinexinf is
            select codpay from tinexinf;
    begin
        initial_value(json_str_input);
        obj_rows := json_object_t();
        if p_report = '1' then
            for i in c_codgrbug loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('codcodec',i.codcodec);
            obj_data.put('desc_codcodec',get_tcodec_name('TCODGRBUG',i.codcodec,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
            end loop;
        elsif p_report = '2' then
            for i in c_tinexinf loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('codcodec',i.codpay);
            obj_data.put('desc_codcodec',get_tinexinf_name(i.codpay,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
            end loop;
        end if;
        json_str_output := obj_rows.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_list_fields;

end HRPYS3X;

/

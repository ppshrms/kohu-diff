--------------------------------------------------------
--  DDL for Package Body HRCO27X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO27X" as

    -- update 05/11/2562  10:30

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_subsystem       := hcm_util.get_string_t(json_obj,'subsystem');
        p_tname           := hcm_util.get_string_t(json_obj,'tname');

    end initial_value;

    procedure gen_data(json_str_output out clob) as
        obj_result  json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        cursor c1 is
            select
                t.* ,
                (
                    select count(*)
                    from user_tab_columns
                    where table_name = t.table_name
                ) as column_count
            from user_tab_comments t
            where
                (upper(substr(t.comments,1,2)) = upper(p_subsystem)
            or
                t.table_name = upper(p_tname))
                and t.table_name not like 'BIN%'
            order by table_name;
    begin
        obj_result := json_object_t();
        for r1 in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('tname', r1.table_name);
            obj_data.put('comments', r1.comments);
            obj_data.put('columns', r1.column_count);
            obj_result.put(to_char(v_row - 1),obj_data);
        end loop;
        json_str_output := obj_result.to_clob;
    end gen_data;

    procedure check_index as
        v_temp varchar2(1 char);
        v_count number := 0;
    begin
        -- ต้องระบุชื่อระบบ หรือ ชื่อ Table
        if p_subsystem is null and p_tname is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- กรณีที่ระบุ ทั้ง ระบบ และ ชื่อ Table ให้ระบบ Clear ค่า Table
        if p_subsystem is not null and p_tname is not null then
            p_tname := null;
        end if;

        -- ชื่อ Table ต้องมีข้อมูลอยู่ในตาราง USER_TAB_COMMENTS (Alert HR2010)
        if p_tname is not null then
            begin
                select 'X' into v_temp
                from user_tab_comments
                where table_name = upper(p_tname);
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'user_tab_comments');
                return;
            end;
        end if;

        -- ชื่อ ระบบ
        if p_subsystem is not null then
            begin
                select count(*) into v_count
                from user_tab_comments
                where upper(substr(comments,1,2)) = upper(p_subsystem);
            exception when others then
                v_count := 0;
            end;

            if v_count = 0 then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'user_tab_comments');
                return;
            end if;
        end if;
    end check_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
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
    end get_index;

    function get_data_format(v_precision number, v_scale number) return varchar2 as
        v_str varchar2(150 char) := '';
    begin
        for i in 1..(v_precision - v_scale) loop
            v_str := concat('9',v_str);
            if mod(i,3) = 0 then
                v_str := concat(',',v_str);
            end if;
        end loop;
       
        if v_str is not null and v_scale != 0 then
            v_str := concat(v_str,'.');
        end if;
        for d in 1..v_scale loop
            v_str := concat(v_str,'9');
        end loop;
        if substr(v_str,1,1) = ',' then
          v_str := substr(v_str,2,length(v_str));
        end if;
        return v_str;
    exception when others then
        return '';
    end get_data_format;

    function get_table_name(v_codtable varchar2) return varchar2 as
        ttabdesc_rec   ttabdesc%rowtype;
        v_comment       user_tab_comments.comments%type;
    begin
        begin
            select * into ttabdesc_rec
            from ttabdesc
            where codtable = upper(v_codtable)
            order by codtable;
        exception when no_data_found then
            begin
                select comments into v_comment
                from user_tab_comments
                where table_name = upper(v_codtable);
                return v_comment;
            exception when no_data_found then
                return ' ';
            end;
            
        end;
        if  global_v_lang = '101' then
            return ttabdesc_rec.destabe;
        elsif global_v_lang = '102' then
            return ttabdesc_rec.destabt;
        elsif global_v_lang = '103' then
            return ttabdesc_rec.destab3;
        elsif global_v_lang = '104' then
            return ttabdesc_rec.destab4;
        elsif global_v_lang = '105' then
            return ttabdesc_rec.destab5;
        else
            return '';
        end if;
    end get_table_name;

    procedure set_datatype_and_format(v_type in out varchar2,v_format in out varchar2,v_length number,v_precision number,v_scale number) as
    begin
        if v_type = 'VARCHAR2' then
                v_type   := 'CHARACTER';
                v_format := 'X('||to_char(v_length)||')';
        elsif v_type = 'NUMBER' then
            if nvl(v_precision,0) <> 0 and nvl(v_scale,0) <> 0 then
                v_type   := 'DECIMAL';
            elsif nvl(v_precision,0) <> 0 and nvl(v_scale,0) = 0 then
                v_type   := 'INTEGER';
            elsif nvl(v_precision,0) = 0 and nvl(v_scale,0) = 0 then
                v_type   := 'INTEGER';
            end if;
            v_format := get_data_format(v_precision,v_scale);
        elsif v_type = 'BOOLEAN' then
            v_type   := 'LOGICAL';
            v_format := 'YES/NO';
        elsif v_type = 'DATE' then
            v_type   := 'DATE';
            v_format := '99/99/9999';
        else
            v_type   := 'IMAGE';
            v_format := '';
        end if;
    end;

    procedure gen_table_data(param_json json_object_t,json_str_output out clob) as
        obj_index   json_object_t;
        obj_column  json_object_t;
        obj_data    json_object_t;
        obj_result  json_object_t;
        v_tname     varchar2(30 char);
        v_index     varchar2(30 char);
        v_index_fields  varchar2(250 char);
        index_row   number := 0;
        column_row  number := 0;
        result_row  number := 0;
        v_data_type varchar2(100 char);
        v_data_format varchar2(150 char);

        cursor c_index_name is
          select index_name,uniqueness
            from user_indexes
           where table_name = upper(v_tname)
             and index_type = 'NORMAL'
        order by decode(uniqueness,'1','2');

        cursor c_user_ind_columns is
            select column_name,column_position
            from user_ind_columns
            where
                upper(table_name) = upper(v_tname) and
                index_name = v_index
            order by column_position;

        cursor c_column is
            select
                a.table_name,
                a.column_id,
                a.column_name,
                a.data_type,
                a.char_length,
                a.data_precision,
                a.data_scale,
                b.comments
            from
                user_tab_columns a,
                user_col_comments b
            where
                a.column_name = b.column_name and
                a.table_name = b.table_name and
                a.table_name = upper(v_tname)
            order by a.column_id;
    begin
        obj_result := json_object_t();
        for i in 0..param_json.get_size-1 loop
            v_tname   := hcm_util.get_string_t(param_json,to_char(i));

            -- index
            obj_index := json_object_t();
            index_row  := 0;
            for r1 in c_index_name loop
                v_index  := r1.index_name;
                v_index_fields := '';
                for r2 in c_user_ind_columns loop
                    if v_index_fields is null then
                        v_index_fields := r2.column_name;
                    else
                        v_index_fields := v_index_fields||' '||r2.column_name;
                    end if;
                end loop;
                index_row := index_row + 1;
                obj_data := json_object_t();
                obj_data.put('name',r1.index_name);
                obj_data.put('fields',v_index_fields);
                obj_data.put('uniqueness',r1.uniqueness);
                obj_index.put(to_char(index_row - 1),obj_data);
            end loop;

            -- column
            obj_column := json_object_t();
            column_row := 0;
            for r3 in c_column loop
--                if r3.data_type = 'VARCHAR2' then
--                        v_data_type   := 'CHARACTER';
--                        v_data_format := 'X('||to_char(r3.data_length)||')';
--                elsif r3.data_type = 'NUMBER' then
--                    if nvl(r3.data_precision,0) <> 0 and nvl(r3.data_scale,0) <> 0 then
--                        v_data_type   := 'DECIMAL';
--                    elsif nvl(r3.data_precision,0) <> 0 and nvl(r3.data_scale,0) = 0 then
--                        v_data_type   := 'INTEGER';
--                    elsif nvl(r3.data_precision,0) = 0 and nvl(r3.data_scale,0) = 0 then
--                        v_data_type   := 'INTEGER';
--                    end if;
--                    v_data_format := get_data_format(r3.data_precision,r3.data_scale);
--                elsif r3.data_type = 'BOOLEAN' then
--                    v_data_type   := 'LOGICAL';
--                    v_data_format := 'YES/NO';
--                elsif r3.data_type = 'DATE' then
--                    v_data_type   := 'DATE';
--                    v_data_format := '99/99/9999';
--                else
--                    v_data_type   := 'IMAGE';
--                    v_data_format := '';
--                end if;
                v_data_type := r3.data_type;
                set_datatype_and_format(v_data_type,v_data_format,r3.char_length,r3.data_precision,r3.data_scale);

                column_row := column_row + 1;
                obj_data := json_object_t();
                obj_data.put('field',r3.column_name);
                obj_data.put('type',v_data_type);
                obj_data.put('format',v_data_format);
                obj_data.put('description',r3.comments);
                obj_column.put(to_char(column_row - 1),obj_data);
            end loop;

            result_row := result_row + 1;
            obj_data := json_object_t();
            obj_data.put('tname',v_tname);
            obj_data.put('tdesc',get_table_name(v_tname));
            obj_data.put('subsys',upper(substr(get_table_name(v_tname),1,2)));
            obj_data.put('index',obj_index);
            obj_data.put('columns',obj_column);
            obj_result.put(to_char(result_row - 1),obj_data);
        end loop;
            json_str_output := obj_result.to_clob;
    end gen_table_data;

    procedure validate_get_detail(param_json json_object_t) as
        v_tname     varchar2(30 char);
        v_temp      varchar2(1 char);
    begin
        -- ชื่อ Table ต้องมีข้อมูลอยู่ในตาราง USER_TAB_COMMENTS (Alert HR2010)
        for i in 0..param_json.get_size-1 loop
            v_tname   := hcm_util.get_string_t(param_json,to_char(i));
            begin
                select 'X' into v_temp
                from user_tab_comments
                where table_name = upper(v_tname);
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'user_tab_comments');
                return;
            end;
        end loop;
    end validate_get_detail;

    procedure get_table_detail(json_str_input in clob, json_str_output out clob) as
        json_obj json_object_t;
    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        param_json      := hcm_util.get_json_t(json_obj,'param_json');

        validate_get_detail(param_json);
        if param_msg_error is null then
            gen_table_data(param_json,json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_table_detail;

    procedure insert_ttemp_report(numseq number,v_type varchar2,item2 varchar2 default ' ',item3 varchar2 default ' ',item4 varchar2 default ' ',item5 varchar2 default ' ',item6 varchar2 default ' ') as
    begin
        insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6)
        values(global_v_codempid,'HRCO27X',numseq,v_type,item2,item3,item4,item5,item6);
    end insert_ttemp_report;

    procedure gen_temp_report_data(param_json json_object_t,json_str_output out clob) as
        v_tname     varchar2(30 char);
        v_tdesc varchar2(150 char);
        v_subsys varchar2(5 char);
        v_index     varchar2(30 char);
        v_index_fields  varchar2(250 char);
        v_numseq    number := 0;
        v_data_type varchar2(100 char);
        v_data_format varchar2(150 char);

        cursor c_index_name is
            select index_name,uniqueness
            from user_indexes
            where table_name = upper(v_tname)
            order by decode(uniqueness,'1','2');

        cursor c_user_ind_columns is
            select column_name,column_position
            from user_ind_columns
            where
                upper(table_name) = upper(v_tname) and
                index_name = v_index
            order by column_position;

        cursor c_column is
            select
                a.table_name,
                a.column_id,
                a.column_name,
                a.data_type,
                a.char_length,
                a.data_precision,
                a.data_scale,
                b.comments
            from
                user_tab_columns a,
                user_col_comments b
            where
                a.column_name = b.column_name and
                a.table_name = b.table_name and
                a.table_name = upper(v_tname)
            order by a.column_id;
    begin
        delete from ttemprpt
        where
            codempid = global_v_codempid and
            codapp = 'HRCO27X';

        for i in 0..param_json.get_size-1 loop
            v_tname   := hcm_util.get_string_t(param_json,to_char(i));
            v_tdesc   := get_table_name(v_tname);
            v_subsys  := upper(substr(v_tdesc,1,2));
            v_numseq  := v_numseq + 1;
            insert_ttemp_report(v_numseq,'HEADER',v_subsys,upper(v_tname),v_tdesc);
            for r1 in c_index_name loop
                v_index  := r1.index_name;
                v_index_fields := '';
                for r2 in c_user_ind_columns loop
                    if v_index_fields is null then
                        v_index_fields := r2.column_name;
                    else
                        v_index_fields := v_index_fields||' '||r2.column_name;
                    end if;

                end loop;
                v_numseq  := v_numseq + 1;
                insert_ttemp_report(v_numseq,'TINDEX',v_tname,v_index,v_index_fields,r1.uniqueness);
            end loop;

            for r3 in c_column loop
--                if r3.data_type = 'VARCHAR2' then
--                        v_data_type   := 'CHARACTER';
--                        v_data_format := 'X('||to_char(r3.data_length)||')';
--                elsif r3.data_type = 'NUMBER' then
--                    if nvl(r3.data_precision,0) <> 0 and nvl(r3.data_scale,0) <> 0 then
--                        v_data_type   := 'DECIMAL';
--                    elsif nvl(r3.data_precision,0) <> 0 and nvl(r3.data_scale,0) = 0 then
--                        v_data_type   := 'INTEGER';
--                    elsif nvl(r3.data_precision,0) = 0 and nvl(r3.data_scale,0) = 0 then
--                        v_data_type   := 'INTEGER';
--                    end if;
--                    v_data_format := get_data_format(r3.data_precision,r3.data_scale);
--                elsif r3.data_type = 'BOOLEAN' then
--                    v_data_type   := 'LOGICAL';
--                    v_data_format := 'YES/NO';
--                elsif r3.data_type = 'DATE' then
--                    v_data_type   := 'DATE';
--                    v_data_format := '99/99/9999';
--                else
--                    v_data_type   := 'IMAGE';
--                    v_data_format := '';
--                end if;
                v_data_type := r3.data_type;
                set_datatype_and_format(v_data_type,v_data_format,r3.char_length,r3.data_precision,r3.data_scale);
                v_numseq  := v_numseq + 1;
                insert_ttemp_report(v_numseq,'COLUMN',v_tname,r3.column_name,v_data_type,v_data_format,r3.comments);
            end loop;
        end loop;
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang,'ttemprpt');
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_temp_report_data;

    procedure static_report(json_str_input in clob, json_str_output out clob) as
        json_obj json_object_t;
    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        param_json      := hcm_util.get_json_t(json_obj,'param_json');
        validate_get_detail(param_json);
        if param_msg_error is null then
            gen_temp_report_data(param_json,json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end static_report;

end hrco27x;

/

--------------------------------------------------------
--  DDL for Package Body HRCO2KB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2KB" as

    -- Update 26/09/2019 16:10

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_tname     := upper(hcm_util.get_string_t(json_obj,'p_tname'));
        p_codsys    := upper(hcm_util.get_string_t(json_obj,'p_codsys'));

        if p_tname is not null then
            p_codsys := null;
        end if;
    end initial_value;

    procedure check_index as
        v_temp  varchar2(1 char);
    begin
        -- ต้องระบุรหัสชื่อตาราง หรือ ชื่อระบบงานย่อย
        if (p_tname is null) and (p_codsys is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- ชื่อตาราง ต้องมีข้อมูลในตาราง USER_TAB_COMMENTS หากไม่พบข้อมูลให้ Alert HR2010
        if p_tname is not null then
            begin
                select 'X' into v_temp
                from user_tab_comments
                where table_name = p_tname;
            exception when no_data_found then
                param_msg_error := p_tname||get_error_msg_php('HR2010',global_v_lang,'USER_TAB_COMMENTS');
                return;
            end;
        end if;
    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;

        cursor c1 is
            select table_name, comments,
            (select count(column_name) from user_col_comments where table_name = a.table_name) qty_col_struc,
            (select count(codcolmn) from tcoldesc where codtable = a.table_name) qty_col_desc
            from user_tab_comments a
            where a.table_name = nvl(p_tname,a.table_name)
            and upper(substr(a.comments,1,2)) = nvl(p_codsys,upper(substr(a.comments,1,2)))
            and not exists (select b.codtable from ttabdesc b where b.codtable = a.table_name)
            and  a.table_name like 'T%'
            -- ดึงข้อมูลที่ไม่มีใน TTABDESC
            union
            select codtable,get_ttabdesc_name(codtable,global_v_lang) comments,
            (select count(column_name) from user_col_comments where table_name = a.codtable) qty_col_struc,
            (select count(codcolmn) from tcoldesc where codtable = a.codtable) qty_col_desc
            from ttabdesc a
            where a.codtable = nvl(p_tname,a.codtable)
            and codsys = nvl(p_codsys,a.codsys)
            order by table_name;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('table_name',i.table_name);
            obj_data.put('comments',i.comments);
--            obj_data.put('comments',get_ttabdesc_name(i.table_name,global_v_lang));
            obj_data.put('qty_col_struc',i.qty_col_struc);
            obj_data.put('qty_col_desc',i.qty_col_desc);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_rows.to_clob;
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure create_querytool(json_str_output out clob) as
        v_codtable      ttabdesc.codtable%type;
        v_codsub        ttabdesc.codsys%type;
        v_comment       ttabdesc.destabe%type;
        v_codcolmn      user_tab_columns.column_name%type;
        v_column_id     user_tab_columns.column_id%type;
        v_data_type     user_tab_columns.data_type%type;
        v_funcdesc      treport2.funcdesc%type;

        cursor c_ttabdesc is
            select rowid,codtable
              from ttabdesc
             where codsys = nvl(p_codsys,codsys)
               and codtable = nvl(p_tname,codtable)
          order by codsys,codtable;

        cursor c_tabs is
            select *
              from user_tab_comments
             where nvl(substr(comments,1,2),'***') = nvl(p_codsys,nvl(substr(comments,1,2),'***'))
               and table_name = nvl(p_tname,table_name)
          order by table_name;

        cursor c_cols is
            select *
              from user_col_comments
             where table_name = v_codtable
          order by table_name,column_name;
    begin
        for r_ttabdesc in c_ttabdesc loop
            begin
                select table_name
                  into v_codtable
                  from user_tab_comments
                 where table_name = r_ttabdesc.codtable;
            exception when no_data_found then
                v_codtable := r_ttabdesc.codtable;
                delete tcoldesc where codtable = v_codtable;
                delete ttabdesc where rowid = r_ttabdesc.rowid;
            end;
        end loop;

        for r_tabs in c_tabs loop
            v_codsub := substr(ltrim(r_tabs.comments),1,2);
            begin
                select codtable into v_codtable
                  from ttabdesc
                 where codtable = r_tabs.table_name;
            exception when no_data_found then
                v_codtable := r_tabs.table_name;
                v_comment  := substr(r_tabs.comments,1,60);
                insert into ttabdesc(codsys,codtable,destabe,destabt,destab3,destab4,destab5,dteupd,coduser,dtecreate,codcreate)
                values(v_codsub,v_codtable,v_comment,v_comment,
                        v_comment,v_comment,v_comment,
                        to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),global_v_coduser,
                        to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),global_v_coduser);
            end;
            v_codtable := r_tabs.table_name;

            for r_cols in c_cols loop
                v_codcolmn := r_cols.column_name;
                v_comment  := substr(r_cols.comments,1,60);
                begin
                    select column_id,data_type
                      into v_column_id,v_data_type
                      from user_tab_columns
                     where table_name = v_codtable
                       and column_name = v_codcolmn;
                exception when no_data_found then
                    v_column_id := 0;
                    v_data_type := null;
                end;

                begin
                    select funcdesc
                      into v_funcdesc
                      from treport2
                     where namfld = v_codcolmn
                       and funcdesc is not null
                       and rownum <= 1;
                exception when no_data_found then
                    v_funcdesc := null;
                end;

                begin
                    select codtable
                      into v_codtable
                      from tcoldesc
                     where codtable = v_codtable
                       and codcolmn = v_codcolmn;

                    update tcoldesc
                       set column_id = v_column_id,
                           data_type = v_data_type,
                           funcdesc  = v_funcdesc,
                           dteupd  = sysdate
                     where codtable = v_codtable
                       and codcolmn  = v_codcolmn;
                exception when others then
                    insert into tcoldesc(codtable,column_id,codcolmn,descole,descolt,descol3,descol4,descol5,
                                        funcdesc,flgchksal,data_type,flgdisp,dteupd,coduser,dtecreate,codcreate)
                    values (v_codtable,v_column_id,v_codcolmn,v_comment,v_comment,
                            v_comment,v_comment,v_comment,v_funcdesc,'N',
                            v_data_type,'Y',sysdate,global_v_coduser,sysdate,global_v_coduser);
                end;

                delete tcoldesc
                 where codtable = v_codtable
                   and codcolmn not in (select column_name
                                          from user_col_comments
                                         where table_name = v_codtable);
            end loop;
        end loop;

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
    end create_querytool;

    procedure gen_querytool(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            create_querytool(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_querytool;

    procedure save_index_data(json_str_output out clob) as
        v_codtable ttabdesc.codtable%type;
        json_obj  json_object_t;
    begin
        for i in 0..param_json.get_size-1 loop
            json_obj        := hcm_util.get_json_t(param_json, to_char(i));
            v_codtable      := upper(hcm_util.get_string_t(json_obj, 'table_name'));
            delete ttabdesc where codtable = v_codtable;
            delete tcoldesc where codtable = v_codtable;
        end loop;
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
    end save_index_data;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        param_json      := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        if param_msg_error is null then
            save_index_data(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

    function get_data_format(v_precision number, v_scale number) return varchar2 as
        v_str varchar2(150 char) := '';
    begin
        for i in 1..(v_precision - v_scale) loop
            v_str := concat('9',v_str);
            if mod(i,3) = 0 and (v_precision - v_scale) > 3 then
                v_str := concat(',',v_str);
            end if;
        end loop;
        if v_str is not null and v_scale != 0 then
            v_str := concat(v_str,'.');
        end if;
        for d in 1..v_scale loop
            v_str := concat(v_str,'9');
        end loop;
        return v_str;
    exception when others then
        return '';
    end get_data_format;

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
        elsif v_type = 'CLOB' then
              v_type := 'CLOB';
              v_format := '';
        else
            v_type   := 'IMAGE';
            v_format := '';
        end if;
    end;

    procedure gen_detail(json_str_output out clob) as
        obj_result      json_object_t;
        obj_rows        json_object_t;
        obj_data        json_object_t;
        obj_detail      json_object_t;
        v_row           number := 0;
        v_data_type     varchar2(100 char);
        v_data_format   varchar2(150 char);
        rec_ttabdesc    ttabdesc%rowtype;
        v_col_count     number := 0;
        cursor c_tcoldesc is
            select a.codcolmn,a.flgchksal,a.flgdisp,
                   decode(global_v_lang,101,a.descole,102,a.descolt,103,a.descol3,104,a.descol4,105,a.descol5,a.descole) descol,
                   a.descole,a.descolt,a.descol3,a.descol4,a.descol5,a.collength,
                   b.data_type,b.char_length,b.data_scale,b.data_precision, a.funcdesc
              from tcoldesc a,user_tab_columns b
             where a.codtable = b.table_name
               and a.codcolmn = b.column_name
               and a.codtable = p_tname
          order by a.column_id;
    begin
        obj_rows := json_object_t();
        for i in c_tcoldesc loop
            v_data_type := i.data_type;
            set_datatype_and_format(v_data_type,v_data_format,i.char_length,i.data_precision,i.data_scale);
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('codcolmn',i.codcolmn);
            obj_data.put('datatype',v_data_type);
            obj_data.put('dataformat',v_data_format);
            obj_data.put('descol',i.descol);
            obj_data.put('descole',i.descole);
            obj_data.put('descolt',i.descolt);
            obj_data.put('descol3',i.descol3);
            obj_data.put('descol4',i.descol4);
            obj_data.put('descol5',i.descol5);
            obj_data.put('collength',i.collength);
            obj_data.put('flgchksal',i.flgchksal);
            obj_data.put('flgdisp',i.flgdisp);
            obj_data.put('funcdesc',i.funcdesc);

            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

        begin
            select * into rec_ttabdesc
              from ttabdesc
             where codtable = p_tname;
        exception when no_data_found then
            rec_ttabdesc := null;
        end;
        begin
            select count(*) into v_col_count
              from tcoldesc
             where codtable = p_tname;
        exception when no_data_found then
            v_col_count := null;
        end;
        obj_data    := json_object_t();
        obj_data.put('rows',obj_rows);

        obj_detail  := json_object_t();
        obj_detail.put('codsys',rec_ttabdesc.codsys);
        obj_detail.put('desc_codsys',get_tlistval_name('SUBSYSTEM',rec_ttabdesc.codsys,global_v_lang));
        obj_detail.put('codtable',rec_ttabdesc.codtable);
        obj_detail.put('qty_col_struc',v_col_count);

        if global_v_lang = '101' then
            obj_detail.put('destab',rec_ttabdesc.destabe);
        elsif global_v_lang = '102' then
            obj_detail.put('destab',rec_ttabdesc.destabt);
        elsif global_v_lang = '103' then
            obj_detail.put('destab',rec_ttabdesc.destab3);
        elsif global_v_lang = '104' then
            obj_detail.put('destab',rec_ttabdesc.destab4);
        elsif global_v_lang = '105' then
            obj_detail.put('destab',rec_ttabdesc.destab5);
        end if;

        obj_detail.put('destabe',rec_ttabdesc.destabe);
        obj_detail.put('destabt',rec_ttabdesc.destabt);
        obj_detail.put('destab3',rec_ttabdesc.destab3);
        obj_detail.put('destab4',rec_ttabdesc.destab4);
        obj_detail.put('destab5',rec_ttabdesc.destab5);

        obj_result := json_object_t();
        obj_result.put('coderror',200);
        obj_result.put('detail',obj_detail);
        obj_result.put('table',obj_rows);

        json_str_output := obj_result.to_clob;
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure save_detail_data(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        v_destabe   ttabdesc.destabe%type;
        v_destabt   ttabdesc.destabt%type;
        v_destab3   ttabdesc.destab3%type;
        v_destab4   ttabdesc.destab4%type;
        v_destab5   ttabdesc.destab5%type;
        v_flgedit   varchar2(10 char);
        obj_column  json_object_t;
        v_codcolmn  tcoldesc.codcolmn%type;
        v_descole   tcoldesc.descole%type;
        v_descolt   tcoldesc.descolt%type;
        v_descol3   tcoldesc.descol3%type;
        v_descol4   tcoldesc.descol4%type;
        v_descol5   tcoldesc.descol5%type;
        v_collength   tcoldesc.collength%type;
        v_flgchksal tcoldesc.flgchksal%type;
        v_flgdisp   tcoldesc.flgdisp%type;
        v_funcdesc  tcoldesc.funcdesc%type;
    	v_col_flgedit   boolean;
        v_temp_codcolmn tcoldesc.codcolmn%type;
        v_detail    json_object_t;
        v_table     json_object_t;
    begin
        json_obj        := json_object_t(json_str_input);
        param_json      := hcm_util.get_json_t(json_obj,'param_json');
        v_detail        := hcm_util.get_json_t(param_json,'detail');
        p_tname         := hcm_util.get_string_t(v_detail,'codtable');
        v_destabe       := hcm_util.get_string_t(v_detail,'destabe');
        v_destabt       := hcm_util.get_string_t(v_detail,'destabt');
        v_destab3       := hcm_util.get_string_t(v_detail,'destab3');
        v_destab4       := hcm_util.get_string_t(v_detail,'destab4');
        v_destab5       := hcm_util.get_string_t(v_detail,'destab5');

        update ttabdesc
           set destabe = v_destabe,
               destabt = v_destabt,
               destab3 = v_destab3,
               destab4 = v_destab4,
               destab5 = v_destab5,
               dteupd  = sysdate,
               coduser = global_v_coduser
         where codtable = p_tname;

        v_table      := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'table'),'rows');

        for i in 0..v_table.get_size-1 loop
            obj_column      := hcm_util.get_json_t(v_table,to_char(i));
            v_codcolmn      := upper(hcm_util.get_string_t(obj_column,'codcolmn'));
            v_descole       := hcm_util.get_string_t(obj_column,'descole');
            v_descolt       := hcm_util.get_string_t(obj_column,'descolt');
            v_descol3       := hcm_util.get_string_t(obj_column,'descol3');
            v_descol4       := hcm_util.get_string_t(obj_column,'descol4');
            v_descol5       := hcm_util.get_string_t(obj_column,'descol5');
            v_collength     := hcm_util.get_string_t(obj_column,'collength');
            v_flgchksal     := upper(hcm_util.get_string_t(obj_column,'flgchksal'));
            v_flgdisp       := upper(hcm_util.get_string_t(obj_column,'flgdisp'));
            v_col_flgedit   := hcm_util.get_boolean_t(obj_column,'flgEdit');
            v_funcdesc      := hcm_util.get_string_t(obj_column,'funcdesc');

            if v_col_flgedit = true then
                update tcoldesc
                set descole = v_descole,
                    descolt = v_descolt,
                    descol3 = v_descol3,
                    descol4 = v_descol4,
                    descol5 = v_descol5,
                    collength = v_collength,
                    flgchksal = v_flgchksal,
                    flgdisp = v_flgdisp,
                    funcdesc = v_funcdesc,
                    dteupd  = sysdate,
                    coduser = global_v_coduser
                where codtable = p_tname
                and codcolmn = v_codcolmn;
            end if;
        end loop;
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
    end save_detail_data;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            save_detail_data(json_str_input,json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

end HRCO2KB;

/

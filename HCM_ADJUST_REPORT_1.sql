--------------------------------------------------------
--  DDL for Package Body HCM_ADJUST_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_ADJUST_REPORT" AS
    procedure initial_value(json_str in clob) is
        json_obj        json_object_t;
    begin
        json_obj            := json_object_t(json_str);

        -- global
        v_chken             := hcm_secur.get_v_chken;
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        begin
            select codempid
            into global_v_codempid
            from tusrprof
            where coduser = global_v_coduser;
        exception when no_data_found then
            global_v_coduser := null;
        end;
    end;

    function GET_LOV(json_str_input in clob) return clob is
        json_obj        json_object_t;
        param_flg_secur varchar2(4000 char);
        param_where     varchar2(4000 char);

        obj_row         json_object_t;
        obj_data        json_object_t;
        json_str_output clob;
        v_row           number  := 0;
        v_where         varchar2(5000 char);
        v_stmt			varchar2(5000 char);
        v_data1			varchar2(5000 char);
        v_data2			varchar2(5000 char);
        v_data3			varchar2(5000 char);
        v_data4			varchar2(5000 char);
        v_data5			varchar2(5000 char);
        v_data6			varchar2(5000 char);
        v_data7			varchar2(5000 char);
        v_length        number;
    begin
        initial_value(json_str_input);

        json_obj    := json_object_t(json_str_input);
        param_flg_secur     := nvl(hcm_util.get_string_t(json_obj,'p_flg_secur'),'Y');
        param_where         := hcm_util.get_string_t(json_obj,'p_where');

        obj_row :=  json_object_t();

        if param_where is not null then
            v_where := ' and ' || param_where;
        end if;

        v_stmt := 'select codapp,codrep,namrepe,namrept,namrep3,namrep4,namrep5 from tadjrepm where codempid = ''' || global_v_codempid ||''' '|| v_where || ' order by codapp, codrep';

        begin
            select  char_length
                into  v_length
                from  user_tab_columns
                where  table_name  = upper('tadjrepm')
                and  column_name = upper('codrep');
        exception when others then
            v_length := 0;
        end;
        v_cursor  := dbms_sql.open_cursor;
        dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
        dbms_sql.define_column(v_cursor,1,v_data1,1000);
        dbms_sql.define_column(v_cursor,2,v_data2,1000);
        dbms_sql.define_column(v_cursor,3,v_data3,1000);
        dbms_sql.define_column(v_cursor,4,v_data4,1000);
        dbms_sql.define_column(v_cursor,5,v_data5,1000);
        dbms_sql.define_column(v_cursor,6,v_data6,1000);
        dbms_sql.define_column(v_cursor,7,v_data7,1000);

        v_dummy := dbms_sql.execute(v_cursor);
        while (dbms_sql.fetch_rows(v_cursor) > 0) loop
            dbms_sql.column_value(v_cursor,1,v_data1);
            dbms_sql.column_value(v_cursor,2,v_data2);
            dbms_sql.column_value(v_cursor,3,v_data3);
            dbms_sql.column_value(v_cursor,4,v_data4);
            dbms_sql.column_value(v_cursor,5,v_data5);
            dbms_sql.column_value(v_cursor,6,v_data6);
            dbms_sql.column_value(v_cursor,7,v_data7);

            v_row := v_row+1;
            obj_data :=  json_object_t();
            obj_data.put('codapp',v_data1);
            obj_data.put('codcodec',v_data2);
            obj_data.put('descode',v_data3);
            obj_data.put('descodt',v_data4);
            obj_data.put('descod3',v_data5);
            obj_data.put('descod4',v_data6);
            obj_data.put('descod5',v_data7);
            obj_data.put('filter',v_data1);
            obj_data.put('max',to_char(v_length));
            obj_row.put(to_char(v_row-1),obj_data);
        end loop; -- end while
        dbms_sql.close_cursor(v_cursor);

        json_str_output := obj_row.to_clob;
        return json_str_output;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
        return json_str_output;
    end;

    function GET_TABLES(json_str_input in clob) return clob is
        json_obj            json_object_t;
        p_codapp            varchar2(1000 char);

        v_codapp            varchar2(1000 char);
        v_tbname            varchar2(1500 char);
        v_table_row         number := 0;
        v_field_row         number := 0;

        v_response          json_object_t;
        v_tables            json_object_t;
        v_table             json_object_t;
        v_fields            json_object_t;
        v_field             json_object_t;

        v_namtable          varchar2(500 char);

        json_str_output     clob;

        cursor c_tadjrept is
            select distinct tbname, commttable
              from tadjrept
             where codapp = p_codapp;

        cursor c_tadjrep_field is
            select codcolmn field,
                   decode(global_v_lang, '101', descole,
                                         '102', descolt,
                                         '103', descol3,
                                         '104', descol4,
                                         '105', descol5, null) namfield,
                   funcdesc funct,
                   decode(funcdesc, null, 'N', 'Y') flgfunct,
                   flgchksal,
                   data_type
              from tcoldesc
             where codtable = v_tbname
             and   flgdisp = 'Y'
          order by column_id;
    begin
        initial_value(json_str_input);

        json_obj    := json_object_t(json_str_input);
        p_codapp    := hcm_util.get_string_t(json_obj,'p_codapp');

        v_tables :=  json_object_t();
        v_table_row := 0;
        for r_tadjrept in c_tadjrept loop
            v_table_row := v_table_row + 1;
            v_table :=  json_object_t();
            v_table.put('coderror', 200);
            v_table.put('desc_coderror', '');
            v_table.put('code', r_tadjrept.tbname);
            begin
                select comments into v_namtable
                  from user_tab_comments
                 where table_name = upper(r_tadjrept.commttable);
            exception when no_data_found then
                v_namtable := '';
            end;
            v_table.put('description', v_namtable);
            v_fields :=  json_object_t();
            v_field_row := 0;
            v_tbname := r_tadjrept.tbname;
            for r_tadjrep_field in c_tadjrep_field loop
                v_field_row := v_field_row + 1;
                v_field :=  json_object_t();
                v_field.put('code', r_tadjrep_field.field);
                v_field.put('description', r_tadjrep_field.namfield);
                v_field.put('funct', r_tadjrep_field.funct);
                if r_tadjrep_field.flgfunct = 'Y' then
                    v_field.put('flgfunct', true);
                else
                    v_field.put('flgfunct', false);
                end if;
                if r_tadjrep_field.flgchksal = 'Y' then
                    v_field.put('flgchksal', true);
                else
                    v_field.put('flgchksal', false);
                end if;
                if r_tadjrep_field.field in ('AGES','AGES_MONTH','AGE_LEVEL','AGE_POS','AMTBANK','CODPOSTC','CODPOSTR','HIGH','NUMLVL','QTYCHEDU','QTYCHNED','QTYDATRQ','QTYWORK','WEIGHT') then
                  v_field.put('data_type', 'INTEGER');
                else
                  v_field.put('data_type', r_tadjrep_field.data_type);
                end if;
                v_fields.put(to_char(v_field_row - 1), v_field);
            end loop;
            v_table.put('fields', v_fields);
            v_tables.put(to_char(v_table_row - 1), v_table);
        end loop;

        v_response :=  json_object_t();
        v_response := v_tables;

        json_str_output := v_response.to_clob;
        return json_str_output;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
        return json_str_output;
    end;

    function GET_CONFIGS(json_str_input in clob) return clob is
        json_obj                    json_object_t;
        p_codapp                    varchar2(10 char);
        p_codrep                    varchar2(10 char);

        v_codapp                    varchar2(10 char);
        v_codrep                    varchar2(10 char);
        v_namrep                    varchar2(500 char);
        v_namrepe                   varchar2(500 char);
        v_namrept                   varchar2(500 char);
        v_namrep3                   varchar2(500 char);
        v_namrep4                   varchar2(500 char);
        v_namrep5                   varchar2(500 char);

        v_selected_field_row        number := 0;
        v_configs                   json_object_t;
        v_selected_fields           json_object_t;
        v_selected_field            json_object_t;

        v_field                     varchar2(1500 char);
        v_formula_selected_field_row number := 0;
        v_formula_obj               json_object_t :=  json_object_t();
        v_formula_selected_fields   json_object_t :=  json_object_t();
        v_formula_selected_field    json_object_t :=  json_object_t();
        v_formula_tbname            varchar2(1500 char);
        v_formula_field             varchar2(1500 char);

        json_str_output     clob;

        cursor c_tadjreps is
            select tbname, codfld, namfld, flgformula, formula, descformula, flglabel, flgdefault, orderby, datatype
              from tadjreps
             where codapp = p_codapp
               and codrep = p_codrep
               and codempid = global_v_codempid
          order by numseq;

        cursor c_tadjrepf is
            select f.tbname, f.codfld, c.data_type, c.flgchksal,
                   decode(global_v_lang, '101', c.descole,
                                         '102', c.descolt,
                                         '103', c.descol3,
                                         '104', c.descol4,
                                         '105', c.descol5, null) namfield
              from tadjrepf f, tcoldesc c
             where f.codapp = p_codapp
               and f.codrep = p_codrep
               and f.codempid = global_v_codempid
               and f.formulafld = v_field
               and c.codtable = f.tbname
               and c.codcolmn = f.codfld
          order by numseq;
    begin
        initial_value(json_str_input);

        json_obj    := json_object_t(json_str_input);
        p_codapp    := hcm_util.get_string_t(json_obj,'p_codapp');
        p_codrep    := hcm_util.get_string_t(json_obj,'p_codrep');

        begin
            select codapp, codrep, decode(global_v_lang, '101', namrepe,
                                                         '102', namrept,
                                                         '103', namrep3,
                                                         '104', namrep4,
                                                         '105', namrep5, null) namrep,
                   namrepe, namrept, namrep3, namrep4, namrep5
              into v_codapp, v_codrep, v_namrep, v_namrepe, v_namrept, v_namrep3, v_namrep4, v_namrep5
              from tadjrepm
             where codapp = p_codapp
               and codrep = p_codrep
               and codempid = global_v_codempid;
        exception when no_data_found then
            v_codapp := null;
            v_codrep := null;
            v_namrep := null;
        end;

        v_selected_fields :=  json_object_t();
        v_selected_field_row := 0;
        for r_tadjreps in c_tadjreps loop
            v_selected_field_row := v_selected_field_row + 1;
            v_selected_field :=  json_object_t();
            v_selected_field.put('coderror', 200);
            v_selected_field.put('code', r_tadjreps.codfld);
            v_selected_field.put('description', r_tadjreps.namfld);
            v_selected_field.put('table', r_tadjreps.tbname);
            v_formula_obj := json_object_t();
            if r_tadjreps.flgformula = 'Y' then
                v_field := r_tadjreps.codfld;
                v_formula_obj.put('coderror', 200);
                v_formula_obj.put('code', r_tadjreps.formula);
                v_formula_obj.put('description', r_tadjreps.descformula);
                for r_tadjrepf in c_tadjrepf loop
                    v_formula_selected_field_row := v_formula_selected_field_row + 1;
                    v_formula_selected_field.put('table',r_tadjrepf.tbname);
                    v_formula_selected_field.put('code',r_tadjrepf.codfld);
                    v_formula_selected_field.put('data_type',r_tadjrepf.data_type);
                    v_formula_selected_field.put('flgchksal',r_tadjrepf.flgchksal);
                    v_formula_selected_field.put('description',r_tadjrepf.namfield);
                    v_formula_selected_fields.put(to_char(v_formula_selected_field_row - 1), v_formula_selected_field);
                end loop;
                v_formula_obj.put('selectedFields', v_formula_selected_fields);
            end if;
            v_selected_field.put('formula', v_formula_obj);
            if r_tadjreps.flglabel = 'Y' then
                v_selected_field.put('labelDisp', true);
            else
                v_selected_field.put('labelDisp', false);
            end if;
            if r_tadjreps.flgdefault = 'Y' then
                v_selected_field.put('default', true);
            else
                v_selected_field.put('default', false);
            end if;
            v_selected_field.put('orderby', r_tadjreps.orderby);
            v_selected_field.put('data_type', r_tadjreps.datatype);
            v_selected_fields.put(to_char(v_selected_field_row - 1), v_selected_field);
        end loop;
        v_configs :=  json_object_t();
        v_configs.put('coderror', 200);
        v_configs.put('desc_coderror', '');
        v_configs.put('descCodAdjRep', v_namrep);
        v_configs.put('descCodAdjRepe', v_namrepe);
        v_configs.put('descCodAdjRept', v_namrept);
        v_configs.put('descCodAdjRep3', v_namrep3);
        v_configs.put('descCodAdjRep4', v_namrep4);
        v_configs.put('descCodAdjRep5', v_namrep5);
        v_configs.put('selectedFields', v_selected_fields);

        json_str_output := v_configs.to_clob;
        return json_str_output;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
        return json_str_output;
    end;

    function SAVE_CONFIGS(json_str_input in clob) return clob is
        json_obj                    json_object_t;
        p_codapp                    varchar2(10 char);
        p_codrep                    varchar2(10 char);
        p_desc_codadjrep            varchar2(500 char);
        p_desc_codadjrepe           varchar2(500 char);
        p_desc_codadjrept           varchar2(500 char);
        p_desc_codadjrep3           varchar2(500 char);
        p_desc_codadjrep4           varchar2(500 char);
        p_desc_codadjrep5           varchar2(500 char);
        p_selected_fields           json_object_t :=  json_object_t();
        v_selected_field            json_object_t :=  json_object_t();
        v_numseq_main               number := 0;
        v_numseq_sub                number := 0;
        v_numseq_formula            number := 0;
        v_tbname                    varchar2(15 char);
        v_field                     tadjreps.codfld%type;
        v_namfield                  varchar2(500 char);
        v_formula                   varchar2(500 char);
        v_descformula               varchar2(500 char);
        v_formula_obj               json_object_t :=  json_object_t();
        v_formula_selected_fields   json_object_t :=  json_object_t();
        v_formula_selected_field    json_object_t :=  json_object_t();
        v_formula_tbname            varchar2(15 char);
        v_formula_field             varchar2(15 char);
        v_formula_data_type         varchar2(60 char);
        v_flgformula_bool           boolean;
        v_flgformula                varchar2(1 char);
        v_flglabel_disp_bool        boolean;
        v_flglabel                  varchar2(1 char);
        v_flgdefault_bool           boolean;
        v_flgdefault                varchar2(1 char);
        v_orderby                   varchar2(1 char);
        v_data_type                 varchar2(60 char);

        json_str_output     clob;
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        p_codapp    := hcm_util.get_string_t(json_obj,'codapp');
        p_codrep    := hcm_util.get_string_t(json_obj,'codrep');
        p_desc_codadjrep := hcm_util.get_string_t(json_obj,'descCodAdjRep');
        p_desc_codadjrepe := hcm_util.get_string_t(json_obj,'descCodAdjRepe');
        p_desc_codadjrept := hcm_util.get_string_t(json_obj,'descCodAdjRept');
        p_desc_codadjrep3 := hcm_util.get_string_t(json_obj,'descCodAdjRep3');
        p_desc_codadjrep4 := hcm_util.get_string_t(json_obj,'descCodAdjRep4');
        p_desc_codadjrep5 := hcm_util.get_string_t(json_obj,'descCodAdjRep5');
        p_selected_fields := hcm_util.get_json_t(json_obj,'selectedFields');

        begin
            begin
                select max(numseq) into v_numseq_main from tadjrepm where codapp = p_codapp;
            exception when no_data_found then
                v_numseq_main := 0;
            end;
            insert into tadjrepm
             (codapp, codrep, codempid, numseq, namrepe, namrept, namrep3, namrep4, namrep5)
            values
             (p_codapp, p_codrep, global_v_codempid, v_numseq_main + 1, p_desc_codadjrep, p_desc_codadjrep, p_desc_codadjrep, p_desc_codadjrep, p_desc_codadjrep);
        exception when dup_val_on_index then
            update tadjrepm
               set namrepe = p_desc_codadjrepe,
                   namrept = p_desc_codadjrept,
                   namrep3 = p_desc_codadjrep3,
                   namrep4 = p_desc_codadjrep4,
                   namrep5 = p_desc_codadjrep5
             where codapp = p_codapp
               and codrep = p_codrep
               and codempid = global_v_codempid;
        end;

        delete tadjreps where codapp = p_codapp and codrep = p_codrep and codempid = global_v_codempid;
        delete tadjrepf where codapp = p_codapp and codrep = p_codrep and codempid = global_v_codempid;
        v_numseq_sub  := 0;
        for i in 0..p_selected_fields.get_size-1 loop
            v_numseq_sub        := v_numseq_sub + 1;
            v_numseq_formula    := 0;
            v_selected_field    := hcm_util.get_json_t(p_selected_fields,to_char(i));
            v_tbname            := hcm_util.get_string_t(v_selected_field,'table');
            v_field             := hcm_util.get_string_t(v_selected_field,'code');
            v_namfield          := hcm_util.get_string_t(v_selected_field,'description');
            if v_tbname <> 'FORMULA' then
                v_flgformula_bool           := false;
                v_formula                   := '';
                v_descformula               := '';
                v_formula_selected_fields   := json_object_t();
            else
                v_flgformula_bool           := true;
                v_formula_obj               := hcm_util.get_json_t(v_selected_field,'formula');
                v_formula                   := hcm_util.get_string_t(v_formula_obj,'code');
                v_descformula               := hcm_util.get_string_t(v_formula_obj,'description');
                v_formula_selected_fields   := hcm_util.get_json_t(v_formula_obj,'selectedFields');
            end if;
            v_flglabel_disp_bool     := nvl(v_selected_field.get_Boolean('labelDisp'), false);
            if v_flgformula_bool = true then
                v_flgformula := 'Y';
                v_flglabel_disp_bool := false;
            else
                v_flgformula := 'N';
            end if;
            if v_flglabel_disp_bool = true then
                v_flglabel := 'Y';
            else
                v_flglabel := 'N';
            end if;
            v_flgdefault_bool   := nvl(v_selected_field.get_Boolean('default'), false);
            if v_flgdefault_bool = true then
                v_flgdefault := 'Y';
            else
                v_flgdefault := 'N';
            end if;
            v_orderby           := hcm_util.get_string_t(v_selected_field, 'orderby');
            v_data_type         := nvl(hcm_util.get_string_t(v_selected_field,'data_type'), 'VARCHAR2');

            begin
                insert into tadjreps
                 (codapp, codrep, codempid, numseq, tbname, codfld, namfld, flgformula, formula, descformula, flglabel, flgdefault, orderby, datatype, coduser)
                values
                 (p_codapp, p_codrep, global_v_codempid, v_numseq_sub, v_tbname, v_field, v_namfield, v_flgformula, v_formula, v_descformula, v_flglabel, v_flgdefault, v_orderby, v_data_type, global_v_coduser);

                if v_tbname = 'FORMULA' then
                    if v_formula_selected_fields.get_size > 0 then
                        for j in 0..v_formula_selected_fields.get_size-1 loop
                            v_numseq_formula          := v_numseq_formula + 1;
                            v_formula_selected_field  := hcm_util.get_json_t(v_formula_selected_fields,to_char(j));
                            v_formula_tbname          := hcm_util.get_string_t(v_formula_selected_field,'table');
                            v_formula_field           := hcm_util.get_string_t(v_formula_selected_field,'code');
                            v_formula_data_type       := hcm_util.get_string_t(v_formula_selected_field,'data_type');

                            insert into tadjrepf
                             (codapp, codrep, codempid, numseq, formulafld, tbname, codfld, codcreate, coduser)
                            values
                             (p_codapp, p_codrep, global_v_codempid, v_numseq_formula, v_field, v_formula_tbname, v_formula_field, global_v_coduser, global_v_coduser);
                        end loop;
                    end if;
                end if;
            end;
        end loop;

        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        commit;
        return json_str_output;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        rollback;
        return json_str_output;
    end;

    function DELETE_CONFIGS(json_str_input in clob) return clob is
        json_obj            json_object_t;
        p_codapp            varchar2(10 char);
        p_codrep            varchar2(10 char);

        json_str_output     clob;
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        p_codapp    := hcm_util.get_string_t(json_obj,'p_codapp');
        p_codrep    := hcm_util.get_string_t(json_obj,'p_codrep');

        delete tadjrepm where codapp = p_codapp and codrep = p_codrep and codempid = global_v_codempid;
        delete tadjreps where codapp = p_codapp and codrep = p_codrep and codempid = global_v_codempid;
        delete tadjrepf where codapp = p_codapp and codrep = p_codrep and codempid = global_v_codempid;

        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        commit;
        return json_str_output;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
        rollback;
        return json_str_output;
    end;

    -- function get_query_tables is private function used only for function GET_DATA.
    -- example result { "TEMPLOY1": { "CODSEX": "M", "TYPPAYROLL": "1001" }, "TATTENCE": { "DTEWORK": "16/11/2019" } }
    function get_query_tables (v_codapp in varchar2, v_data_row in json_object_t, v_selected_fields in json_object_t, v_tables_str in varchar2) return json_object_t is
        v_query_tables      json_object_t :=  json_object_t();
        v_query_fields      json_object_t :=  json_object_t();

        v_selected_field    json_object_t :=  json_object_t();

        v_tbname            varchar2(1500 char);
        v_field             varchar2(1000 char);

        v_table_count       number := nvl(regexp_count(v_tables_str, ','),0) + 1;
        v_table_str         varchar2(1500 char) := '';
        o_table_instr       number := 0;
        v_table_instr       number := 0;

        v_funct             varchar2(5000 char);
        v_flglabel_bool     boolean;
        v_flgchksal_bool    boolean;
        v_flgdefault_bool   boolean;
        v_flgformula_bool   boolean;
        v_data_type         varchar2(6000 char);

        v_tadjrep_relation_count number := 0;
        v_value_fieldsrh    varchar2(1000 char) := '';
        v_select            varchar2(30000 char) := '';
        v_select_conj       varchar2(1000 char) := '';
        v_where			    varchar2(30000 char) := '';
        v_where_conj        varchar2(1000 char) := '';
        v_stmt			    varchar2(32000 char) := '';
        v_field_obj         json_object_t :=  json_object_t();
        v_field_count       number := 0;

        v_codempid          varchar2(1000 char);
        v_codcompy          varchar2(1000 char);
        v_flgsecu           boolean;

        TYPE queryfield_array IS TABLE OF VARCHAR2(7000 char) INDEX BY BINARY_INTEGER;
        v_queryfields       queryfield_array;

        cursor c_tadjrep_relation is
            select codfld, codfldsrh, datatype
              from tadjrept
             where codapp = v_codapp
               and tbname = v_table_str;
    begin
        for i in 0..v_table_count - 1 loop
            v_table_instr := instr(v_tables_str, ',', v_table_instr + 1);
            if v_table_count > 1 then
                if i = 0 then
                    -- focus on first table 'temploy1,tattence,tcodec,tot' => 'temploy1'
                    v_table_str   := substr(v_tables_str, o_table_instr, v_table_instr - o_table_instr - 1);
                elsif i = v_table_count - 1 then
                    -- focus on last table 'temploy1,tattence,tcodec,tot' => 'tot'
                    v_table_str   := substr(v_tables_str, o_table_instr + 1);
                else
                    -- focus on middle table 'temploy1,tattence,tcodec,tot' => 'tattence' and 'tcodec'
                    v_table_str   := substr(v_tables_str, o_table_instr + 1, v_table_instr - o_table_instr - 1);
                end if;
            elsif v_table_count = 1 then
                v_table_str   := substr(v_tables_str, o_table_instr + 1);
            end if;
            o_table_instr := v_table_instr;

            v_tadjrep_relation_count    := 0;
            v_value_fieldsrh            := '';
            v_select                    := '';
            v_select_conj               := '';
            v_where                     := '';
            v_where_conj                := '';
            v_field_count               := 0;
            v_field_obj                 :=  json_object_t();

            -- count number of table field relation
            for r_tadjrep_relation in c_tadjrep_relation loop
                v_tadjrep_relation_count := v_tadjrep_relation_count + 1;
                exit;
            end loop;

            if v_tadjrep_relation_count > 0 then
                -- set v_where;
                for r_tadjrep_relation in c_tadjrep_relation loop
                    v_value_fieldsrh := hcm_util.get_string_t(v_data_row,lower(r_tadjrep_relation.codfldsrh));
                    if r_tadjrep_relation.datatype = 'DATE' then
                        --<< surachai | 17/11/2022 || #8662
                        -- v_value_fieldsrh := 'to_date(''' || v_value_fieldsrh || ''', ''dd/mm/yyyy'')'; -- bk
                        if length(v_value_fieldsrh) = 10 then
                            v_value_fieldsrh := 'to_date(''' || v_value_fieldsrh || ''', ''dd/mm/yyyy'')';
                        else
                            v_value_fieldsrh := 'to_date(''' || v_value_fieldsrh || ''', ''dd/mm/yyyy hh24:mi:ss'')';
                        end if;
                        -->>
                    elsif r_tadjrep_relation.datatype = 'DATETIME' then
                        v_value_fieldsrh := 'to_date(''' || v_value_fieldsrh || ''', ''dd/mm/yyyy hh24:mi:ss'')';
                    elsif r_tadjrep_relation.datatype = 'NUMBER' then
                        v_value_fieldsrh := 'to_number(''' || v_value_fieldsrh || ''')';
                    elsif r_tadjrep_relation.datatype = 'VARCHAR2' then
                        v_value_fieldsrh := '''' || v_value_fieldsrh || '''';
                    else
                        v_value_fieldsrh := '''' || v_value_fieldsrh || '''';
                    end if;
                    v_where := v_where || v_where_conj || r_tadjrep_relation.codfld || ' = ' || v_value_fieldsrh;
                    v_where_conj := ' and ';
                end loop;

                -- set v_select
                for j in 0..v_selected_fields.get_size-1 loop
                    v_selected_field    := hcm_util.get_json_t(v_selected_fields,to_char(j));
                    v_tbname            := hcm_util.get_string_t(v_selected_field,'table');
                    v_field             := hcm_util.get_string_t(v_selected_field,'code');
                    v_flgdefault_bool   := nvl(v_selected_field.get_Boolean('default'), false);
                    if v_tbname = 'FORMULA' then
                        v_flgformula_bool   := true;
                    else
                        v_flgformula_bool   := false;
                    end if;

                    if v_table_str = v_tbname and v_flgdefault_bool = false and v_flgformula_bool = false then
                        v_funct             := hcm_util.get_string_t(v_selected_field,'funct');
                        v_flglabel_bool     := nvl(v_selected_field.get_Boolean('labelDisp'), false);
                        v_flgchksal_bool    := nvl(v_selected_field.get_Boolean('flgchksal'), false);
                        v_data_type         := hcm_util.get_string_t(v_selected_field,'data_type');

                        v_field_count := v_field_count + 1;
                        if v_flgchksal_bool then
                            v_field_obj.put(to_char(v_field_count - 1), v_field);
                            v_codempid := hcm_util.get_string_t(v_data_row, 'codempid');
                            v_codcompy := hcm_util.get_string_t(v_data_row, 'codcompy');
                            --v_flgsecu := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                            /*
                               v_flgsecu := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                                if v_zupdsal = 'Y' then
                                    v_select := v_select || v_select_conj || 'stddec(' || v_field || ',''' || v_codempid || ''',' || v_chken || ')';
                                else
                                    v_select := v_select || v_select_conj || '-1';
                                end if;
                            */
                           --<<User37 #2290 Final Test Phase 1 V11 31/03/2021
                           /*if v_codempid is not null then
                            v_flgsecu := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                                if v_zupdsal = 'Y' then
                                    v_select := v_select || v_select_conj || 'stddec(' || v_field || ',''' || v_codempid || ''',' || v_chken || ')';
                                else
                                    v_select := v_select || v_select_conj || '-1';
                                end if;
                           end if;

                           if v_codcompy is not null then
                            v_flgsecu := secur_main.secur7(v_codcompy, global_v_coduser);
                                if v_flgsecu  then
                                    v_select := v_select || v_select_conj || 'stddec(' || v_field || ',''' || v_codcompy || ''',' || v_chken || ')';
                                else
                                    v_select := v_select || v_select_conj || '-1';
                                end if;
                           end if;*/
                           if v_codempid is not null then
                            v_flgsecu := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                                if v_zupdsal = 'Y' then
                                    v_select := v_select || v_select_conj || 'stddec(' || v_field || ',''' || v_codempid || ''',' || v_chken || ')';
                                else
                                    v_select := v_select || v_select_conj || '-1';
                                end if;
                           elsif v_codcompy is not null then
                            v_flgsecu := secur_main.secur7(v_codcompy, global_v_coduser);
                                if v_flgsecu  then
                                    v_select := v_select || v_select_conj || 'stddec(' || v_field || ',''' || v_codcompy || ''',' || v_chken || ')';
                                else
                                    v_select := v_select || v_select_conj || '-1';
                                end if;
                           else
                                v_select := v_select || v_select_conj || '''''';
                           end if;
                           -->>User37 #2290 Final Test Phase 1 V11 31/03/2021
                        else

                             if v_field like 'AMT%' then
                                   -----
                                      --<<User37 #2290 Final Test Phase 1 V11 31/03/2021
                                      /*if v_codempid is not null then
                                        v_flgsecu := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                                            if v_zupdsal = 'Y' then
                                                v_select := v_select || v_select_conj || 'stddec(' || v_field || ',''' || v_codempid || ''',' || v_chken || ')';
                                            else
                                                v_select := v_select || v_select_conj || '-1';
                                            end if;
                                       end if;

                                       if v_codcompy is not null then
                                        v_flgsecu := secur_main.secur7(v_codcompy, global_v_coduser);
                                            if v_flgsecu  then
                                                v_select := v_select || v_select_conj || 'stddec(' || v_field || ',''' || v_codcompy || ''',' || v_chken || ')';
                                            else
                                                v_select := v_select || v_select_conj || '-1';
                                            end if;
                                       end if;*/
                                       if v_codempid is not null then
                                        v_flgsecu := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                                            if v_zupdsal = 'Y' then
                                                v_select := v_select || v_select_conj || 'stddec(' || v_field || ',''' || v_codempid || ''',' || v_chken || ')';
                                            else
                                                v_select := v_select || v_select_conj || '-1';
                                            end if;
                                       elsif v_codcompy is not null then
                                        v_flgsecu := secur_main.secur7(v_codcompy, global_v_coduser);
                                            if v_flgsecu  then
                                                v_select := v_select || v_select_conj || 'stddec(' || v_field || ',''' || v_codcompy || ''',' || v_chken || ')';
                                            else
                                                v_select := v_select || v_select_conj || '-1';
                                            end if;
--                                       else
--                                            v_select := v_select || v_select_conj;-- || '''''';
                                       end if;
                                       -->>User37 #2290 Final Test Phase 1 V11 31/03/2021
                            end if;

                            if v_flglabel_bool then
                                v_field_obj.put(to_char(v_field_count - 1), 'L_' || v_field);
                                v_funct := replace(v_funct, 'P_CODE', v_field);
                                v_funct := replace(v_funct, 'P_LANG', global_v_lang);
                                v_select := v_select || v_select_conj || v_funct || ' as L_' || v_field;
                            else
                                v_field_obj.put(to_char(v_field_count - 1), v_field);
                                if upper(v_data_type) = 'DATE' then
                                    v_select := v_select || v_select_conj || 'to_char(' || v_field || ', ''dd/mm/yyyy'')';
                                elsif upper(v_data_type) = 'DATETIME' then
                                    v_select := v_select || v_select_conj || 'to_char(' || v_field || ', ''dd/mm/yyyy hh24:mi:ss'')';
                                elsif upper(v_data_type) = 'NUMBER' then
--                                    v_select := v_select || v_select_conj || 'to_char(' || v_field || ')';
                                    v_select := v_select  || v_select_conj || 'to_char(' || v_field || ')';

--                                   if  v_field like 'AMT%' then
--                                        v_select := v_select || v_select_conj || 'to_char(' || v_field || ', ''fm9,999,999,999,990.00'')';
--                                   else
--                                        v_select := v_select || v_select_conj || 'to_char(' || v_field || ', ''fm9,999,999,999,990'')';
--                                   end if;
                                elsif upper(v_data_type) = 'VARCHAR2' then
--                                    v_select := v_select || v_select_conj || v_field;
                                        if v_field like 'CODCOMP%' then
                                            v_select := v_select || v_select_conj ||'hcm_util.get_codcomp_level('||v_field||',null,''-'',''Y'')' ;
                                        else
                                            v_select := v_select || v_select_conj || v_field;
                                        end if;

                                else
                                    v_select := v_select || v_select_conj || v_field;
                                end if;
                            end if;
                        end if;
                        v_select_conj := ',';
                    end if;
                end loop;
                v_stmt := 'select ' || v_select || ' from ' || v_table_str || ' where ' || v_where;
            end if;


            if v_stmt is null or v_stmt = '' then
                v_query_fields :=  json_object_t();
            else
                v_cursor  := dbms_sql.open_cursor;

                dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);


                -- clean v_queryfields
                for j in 0..v_field_obj.get_size - 1 loop
                    v_queryfields(j) := '';
                    dbms_sql.define_column(v_cursor,j + 1,v_queryfields(j),7000);
                end loop;
                v_dummy := dbms_sql.execute(v_cursor);
                while (dbms_sql.fetch_rows(v_cursor) > 0) loop
                    for j in 0..v_field_obj.get_size - 1 loop
                        dbms_sql.column_value(v_cursor, j + 1,v_queryfields(j));
                        v_query_fields.put(hcm_util.get_string_t(v_field_obj,to_char(j)), v_queryfields(j));
                    end loop;
                end loop;
                dbms_sql.close_cursor(v_cursor);
            end if;
            v_query_tables.put(v_table_str, v_query_fields);
        end loop;
        return v_query_tables;
    end;

    -- function get_tables_str is private function used only for function GET_DATA.
    -- example result "TEMPLOY1,TATTENCE"
    function get_tables_str (v_selected_fields in json_object_t) return varchar2 is
        type v_table_array is table of varchar2(100 char) index by pls_integer;
        v_tables v_table_array := v_table_array();
        v_exist             boolean := false;
        v_index             number;
        v_tables_str        varchar2(5000 char) := '';
        v_concat            varchar2(1 char) := '';

        v_selected_field    json_object_t :=  json_object_t();
        v_tbname            varchar2(15 char);
    begin
        for i in 0..v_selected_fields.get_size-1 loop
            v_selected_field    := hcm_util.get_json_t(v_selected_fields,to_char(i));
            v_tbname            := hcm_util.get_string_t(v_selected_field,'table');

            v_exist := false;
            if v_tbname <> 'DEFAULT' then
              for i in 1..v_tables.count loop
                if v_tbname = v_tables(i) then
                  v_exist := true;
                  exit;
                end if;
              end loop;
              if v_exist = false then
                v_index := v_tables.count + 1;
                v_tables(v_index) := v_tbname;
                v_tables_str := v_tables_str || v_concat || v_tbname;
                v_concat := ',';
              end if;
            end if;
            --if v_tbname <> 'DEFAULT' and (instr(v_tables_str, v_tbname) = 0 or instr(v_tables_str, v_tbname) is null) then
            --    v_tables_str := v_tables_str || v_concat || v_tbname;
            --    v_concat := ',';
            --end if;
        end loop;

        return v_tables_str;
    end;

    /*
        create private temporary table have their fields from selected fields, Drop when commit
        ptt_create_table called by ptt_get_data only.
    */
    procedure ptt_create_table(l_ptt_table in varchar2, v_selected_fields in json_object_t) is
        v_selected_field        json_object_t :=  json_object_t();
        v_concat                varchar2(1 char) := '';
        v_tbname                varchar2(100 char);
        v_field                 varchar2(100 char);
        v_flgdefault_bool       boolean;
        v_flgformula_bool       boolean;
        v_data_type             varchar2(60 char);
        v_table_field           varchar2(500 char);

        l_field_datatype_sql    varchar2(500 char);
        l_create_sql            clob;
        l_create_fileds_sql     clob;

    begin
        v_concat := '';
        for x in 0..v_selected_fields.get_size-1 loop
            v_selected_field     := hcm_util.get_json_t(v_selected_fields,to_char(x));
            v_tbname             := hcm_util.get_string_t(v_selected_field,'table');
            v_field              := hcm_util.get_string_t(v_selected_field,'code');
            v_table_field        := hcm_util.get_string_t(v_selected_field,'tableField');
            v_flgdefault_bool    := nvl(v_selected_field.get_Boolean('default'), false);
            if v_tbname = 'FORMULA' then
                v_flgformula_bool := true;
            else
                v_flgformula_bool := false;
            end if;
            if v_flgformula_bool = false then
                v_data_type         := hcm_util.get_string_t(v_selected_field,'data_type');

                if upper(v_data_type) = 'DATE' then
                    l_field_datatype_sql := v_table_field || ' DATE';
                elsif upper(v_data_type) = 'DATETIME' then
                    l_field_datatype_sql := v_table_field || ' DATE';
                elsif upper(v_data_type) = 'NUMBER' then
                    l_field_datatype_sql := v_table_field || ' NUMBER';
                elsif upper(v_data_type) = 'VARCHAR2' then
                    l_field_datatype_sql := v_table_field || ' VARCHAR2(1000 char)';
                else
                    l_field_datatype_sql := v_table_field || ' VARCHAR2(1000 char)';
                end if;
                l_create_fileds_sql := l_create_fileds_sql || v_concat || l_field_datatype_sql;
                v_concat             := ',';
            end if;
        end loop;
     --  l_create_sql := 'CREATE PRIVATE TEMPORARY TABLE ' || l_ptt_table || ' (' || upper(l_create_fileds_sql) || ') ON COMMIT DROP DEFINITION';
      l_create_sql := 'CREATE PRIVATE TEMPORARY TABLE ' || l_ptt_table || ' (' || upper(l_create_fileds_sql) || ') ON COMMIT PRESERVE DEFINITION';
        begin
            EXECUTE IMMEDIATE l_create_sql;
            exception  when others then null;
        end;
    end;

    /*
        insert json_data_rows to created private temporary table
        ptt_insert_data called by ptt_get_data only.
    */
    procedure ptt_insert_data(l_ptt_table in varchar2, v_json_data_rows in json_object_t, v_selected_fields in json_object_t) is
        v_data_row              json_object_t :=  json_object_t();

        v_selected_field        json_object_t :=  json_object_t();
        v_concat                varchar2(1 char) := '';
        v_tbname                varchar2(100 char);
        v_field                 varchar2(100 char);
        v_table_field           varchar2(500 char);
        v_flgdefault_bool       boolean;
        v_flgformula_bool       boolean;
        v_data_type             varchar2(60 char);

        l_insert_data_value     varchar2(1000);
        l_insert_sql            clob;
        l_insert_data_sql       clob;
        l_insert_datas_sql      clob;
    begin
        for i in 0..v_json_data_rows.get_size-1 loop
            l_insert_datas_sql  := '';
            v_concat            := '';

            v_data_row      := hcm_util.get_json_t(v_json_data_rows,to_char(i));
            for x in 0..v_selected_fields.get_size-1 loop
                v_selected_field     := hcm_util.get_json_t(v_selected_fields,to_char(x));
                v_tbname             := hcm_util.get_string_t(v_selected_field,'table');
                v_field              := hcm_util.get_string_t(v_selected_field,'code');
                v_table_field        := hcm_util.get_string_t(v_selected_field,'tableField');
                v_flgdefault_bool    := nvl(v_selected_field.get_Boolean('default'), false);
                if v_tbname = 'FORMULA' then
                    v_flgformula_bool := true;
                else
                    v_flgformula_bool := false;
                end if;
                if v_flgformula_bool = false then
                    -- incase data has character "'", it have to replace that character to "''''"
                    -- example Armando D'Amore replace to Armando D''''Amore
                    l_insert_data_value  := replace(hcm_util.get_string_t(v_data_row,upper(v_table_field)), '''', '''''');
                    v_data_type         := hcm_util.get_string_t(v_selected_field,'data_type');
                    if upper(v_data_type) = 'DATE' then
                        l_insert_data_sql := 'to_date(''' || l_insert_data_value || ''', ''dd/mm/yyyy'')';
                    elsif upper(v_data_type) = 'DATETIME' then
                        l_insert_data_sql := 'to_date(''' || l_insert_data_value || ''', ''dd/mm/yyyy hh24:mi:ss'')';
                    elsif upper(v_data_type) = 'NUMBER' then
                        l_insert_data_sql := 'to_number(''' || l_insert_data_value || ''')';
                    elsif upper(v_data_type) = 'VARCHAR2' then
                        l_insert_data_sql := '''' || l_insert_data_value || '''';
                    else
                        l_insert_data_sql := '''' || l_insert_data_value || '''';
                    end if;
                    l_insert_datas_sql := l_insert_datas_sql || v_concat || l_insert_data_sql;
                    v_concat             := ',';
                end if;
            end loop;
    begin
            l_insert_sql := 'INSERT INTO ' || l_ptt_table || ' VALUES (' || l_insert_datas_sql || ')';
            EXECUTE IMMEDIATE l_insert_sql;
       exception when others then  null;
     end;
    end loop;
    end;

    /*
        generate new statement which have generated condition by v_selected_fields (select, from, order_by, group by)
        and then execute the statement to get data from private temporary table.
        example result: to_clob of object -> [{"key-1": "val-1-1", "key-2": "val-2-1"}, {"key-1": "val-1-2", "key-2": "val-2-2"}]
        ptt_query_data called by ptt_get_data only.
    */
    function ptt_query_data(l_ptt_table in varchar2, v_selected_fields in json_object_t) return clob is
        obj_row                     json_object_t;
        obj_data                    json_object_t;
        json_str_output             clob;
        v_row                       number  := 0;

        v_count_selected_field      number := 0;
        v_selected_field            json_object_t :=  json_object_t();
        v_concat                    varchar2(1 char) := '';
        v_tbname                    varchar2(100 char);
        v_field                     varchar2(100 char);
        v_table_field               varchar2(500 char);
        v_table_field_groupby       varchar2(500 char);
        v_table_field_key           varchar2(500 char);
        v_flgdefault_bool           boolean;
        v_flgadditional_field_bool  boolean;
        v_flgformula_bool           boolean;
        v_formula                   varchar2(500 char);
        v_formula_obj               json_object_t :=  json_object_t();
        v_formula_selected_fields   json_object_t :=  json_object_t();
        v_formula_selected_field    json_object_t :=  json_object_t();
        v_formula_tbname            varchar2(15 char);
        v_formula_field             varchar2(15 char);
        v_formula_data_type         varchar2(15 char);
        v_formula_table_field       varchar2(1000 char);
        v_data_type                 varchar2(60 char);

        v_find_selected_field       json_object_t :=  json_object_t();
        v_find_tbname               varchar2(100 char);
        v_find_field                varchar2(100 char);
        v_find_table_field_key      varchar2(500 char);
        v_find_label_disp_bool      boolean;

        v_concat_select             varchar2(1 char) := '';
        v_select                    clob := '';
        v_from                      varchar2(5000 char) := ' from ' || l_ptt_table;
        v_where                     varchar2(5000 char) := '';

        v_order_by_type             varchar2(1 char);
        v_concat_order_by           varchar2(1 char) := '';
        v_order_by                  clob := '';

        v_flg_group_by_bool         boolean := false;
        v_concat_group_by           varchar2(1 char) := '';
        v_group_by                  clob := '';
        v_stmt			            clob;

        TYPE v_array IS TABLE OF VARCHAR2(5000 char) INDEX BY BINARY_INTEGER;
        v_field_array                 v_array;
        v_data_array                  v_array;
    begin
        obj_row :=  json_object_t();

        /* find v_flg_group_by_bool */
        for x in 0..v_selected_fields.get_size-1 loop
            v_selected_field     := hcm_util.get_json_t(v_selected_fields,to_char(x));
            if hcm_util.get_string_t(v_selected_field,'table') = 'FORMULA' then
                v_formula_obj               := hcm_util.get_json_t(v_selected_field,'formula');
                v_formula                   := hcm_util.get_string_t(v_formula_obj,'code');
                if  instr(upper(v_formula), 'AVG(') > 0 or
                    instr(upper(v_formula), 'MAX(') > 0 or
                    instr(upper(v_formula), 'MIN(') > 0 or
                    instr(upper(v_formula), 'SUM(') > 0 or
                    instr(upper(v_formula), 'COUNT(') > 0 then
                    v_flg_group_by_bool := true;
                end if;
            end if;
        end loop;

        /* setup v_stmt */
        for x in 0..v_selected_fields.get_size-1 loop
            v_selected_field     := hcm_util.get_json_t(v_selected_fields,to_char(x));
            v_tbname             := hcm_util.get_string_t(v_selected_field,'table');
            v_field              := hcm_util.get_string_t(v_selected_field,'code');
            v_table_field_key    := hcm_util.get_string_t(v_selected_field,'tableField');
            v_order_by_type      := hcm_util.get_string_t(v_selected_field,'orderby');
            v_flgdefault_bool    := nvl(v_selected_field.get_Boolean('default'), false);
            v_flgadditional_field_bool    := nvl(v_selected_field.get_Boolean('flgadditional'), false);

            if v_tbname = 'FORMULA' then
                v_flgformula_bool    := true;
            else
                v_flgformula_bool    := false;
            end if;

            if v_flgadditional_field_bool = false then
                if v_flgformula_bool = true then
                    v_formula_obj               := hcm_util.get_json_t(v_selected_field,'formula');
                    v_formula                   := hcm_util.get_string_t(v_formula_obj,'code');
                    v_formula_selected_fields   := hcm_util.get_json_t(v_formula_obj,'selectedFields');
                    v_table_field               := v_formula;


                    if v_formula_selected_fields.get_size > 0 then
                        for j in 0..v_formula_selected_fields.get_size-1 loop

                            v_formula_selected_field  := hcm_util.get_json_t(v_formula_selected_fields,to_char(j));
                            v_formula_tbname          := hcm_util.get_string_t(v_formula_selected_field,'table');
                            v_formula_field           := hcm_util.get_string_t(v_formula_selected_field,'code');
                            v_formula_data_type       := hcm_util.get_string_t(v_formula_selected_field,'data_type');


                            v_find_table_field_key    := '';
                            for y in 0..v_selected_fields.get_size-1 loop
                                v_find_selected_field     := hcm_util.get_json_t(v_selected_fields,to_char(y));
                                v_find_tbname             := hcm_util.get_string_t(v_find_selected_field,'table');
                                v_find_field              := hcm_util.get_string_t(v_find_selected_field,'code');
                                v_find_label_disp_bool    := nvl(v_find_selected_field.get_Boolean('labelDisp'), false);
                                v_find_table_field_key    := hcm_util.get_string_t(v_find_selected_field,'tableField');

                                if v_find_tbname <> 'FORMULA' and upper(v_formula_tbname) = upper(v_find_tbname) and upper(v_formula_field) = upper(v_find_field) and v_find_label_disp_bool = false then
                                    exit;
                                end if;
                            end loop;
                            if upper(v_formula_data_type) = 'DATE' or upper(v_formula_data_type) = 'DATETIME' then
                                v_formula_table_field := 'hcm_util.get_date_buddhist_era(' || upper(v_find_table_field_key) || ')';
                            else
                                v_formula_table_field := upper(v_find_table_field_key);
                            end if;
                            v_table_field             := replace(upper(v_table_field), upper(v_formula_tbname) || '.' || upper(v_formula_field), v_formula_table_field);
                        end loop;
                    end if;
                    v_table_field               := v_table_field || ' as ' || v_field;
                else
                    v_table_field := v_table_field_key;
                    v_data_type         := hcm_util.get_string_t(v_selected_field,'data_type');
                    if upper(v_data_type) = 'DATE' then
                        v_table_field := 'to_char(' || v_table_field || ', ''dd/mm/yyyy'')';
                    elsif upper(v_data_type) = 'DATETIME' then
                        v_table_field := 'to_char(' || v_table_field || ',''dd/mm/yyyy hh24:mi:ss'')';
                    elsif upper(v_data_type) = 'NUMBER' then
                        v_table_field := 'to_char(' || v_table_field || ')';
                    end if;
                end if;

                /* setup v_select */
                v_count_selected_field :=  v_count_selected_field + 1;
                if v_concat_select is null then
                    v_select    := 'select ';
                end if;
                /* initial array value */
                v_field_array(x + 1) := upper(v_table_field_key);
                v_data_array(x + 1) := '';

                v_select := v_select || v_concat_select || v_table_field;
                v_concat_select := ',';

                /* setup v_order_by */
                if upper(v_order_by_type) = 'L' or upper(v_order_by_type) = 'H' then
                    if v_concat_order_by is null then
                        v_order_by := ' order by ';
                    end if;
                    if upper(v_order_by_type) = 'L' then
                        if v_flgformula_bool = true then
                            v_order_by  := v_order_by || v_concat_order_by || v_field || ' asc';
                        else
                            v_order_by  := v_order_by || v_concat_order_by || v_table_field || ' asc';
                        end if;
                    elsif upper(v_order_by_type) = 'H' then
                        if v_flgformula_bool = true then
                            v_order_by  := v_order_by || v_concat_order_by || v_field || ' desc';
                        else
                            v_order_by  := v_order_by || v_concat_order_by || v_table_field || ' desc';
                        end if;
                    end if;
                    v_concat_order_by := ',';
                end if;
            end if;

            /* setup v_group_by */
            if v_flg_group_by_bool = true then
                if v_flgformula_bool = false then
                    v_table_field_groupby := v_table_field_key;
                    if v_concat_group_by is null then
                        v_group_by  := ' group by ';
                    end if;
                    v_group_by := v_group_by || v_concat_group_by || v_table_field_groupby;
                    v_concat_group_by := ',';
                end if;
            else
                v_group_by  := '';
            end if;
        end loop;
        v_stmt      := upper(v_select || v_from || v_group_by || v_order_by);

    begin
        v_cursor  := dbms_sql.open_cursor;
        dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);

        for x in 1..v_count_selected_field loop
            dbms_sql.define_column(v_cursor,x,v_data_array(x),5000);
        end loop;

        v_dummy := dbms_sql.execute(v_cursor);
        while (dbms_sql.fetch_rows(v_cursor) > 0) loop
            v_row := v_row+1;
            obj_data :=  json_object_t();
            for x in 1..v_count_selected_field loop
                dbms_sql.column_value(v_cursor,x,v_data_array(x));
                obj_data.put(v_field_array(x),v_data_array(x));
            end loop;
            obj_data.put('coderror', 200);
            obj_row.put(to_char(v_row-1),obj_data);
        end loop; -- end while
        dbms_sql.close_cursor(v_cursor);
  exception when others  then
    param_msg_error := get_error_msg_php('HR2810',global_v_lang);
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end;
        json_str_output := obj_row.to_clob;
        return json_str_output;
    end;

    -- ptt_get_data called by GET_DATA only.
    function ptt_get_data(v_json_data_rows in json_object_t, v_selected_fields in json_object_t) return clob is
        l_ptt_table         varchar2(50 char) := 'ora$ptt_adjust_temp_table';
        json_str_output     clob;
    begin
        ptt_create_table(l_ptt_table, v_selected_fields);
        ptt_insert_data(l_ptt_table, v_json_data_rows, v_selected_fields);
        json_str_output := ptt_query_data(l_ptt_table, v_selected_fields);
        commit;
        return json_str_output;
    end;

    /*
        the result is same as its parameter (v_selected_fields) but add more selected fields calculate from formula object
    */
    function get_selected_fields_combine_with_formula(v_selected_fields in json_object_t) return json_object_t is
        v_additional_selected_field     json_object_t :=  json_object_t();
        v_additional_selected_fields    json_object_t :=  json_object_t();
        v_additional_row                number := 0;
        v_selected_field_row            number := 0;

        v_selected_field                json_object_t :=  json_object_t();

        v_selected_field_validate       json_object_t :=  json_object_t();
        v_tbname_validate               varchar2(15 char);
        v_field_validate                varchar2(15 char);
        v_label_disp_bool_validate      boolean;
        v_formula_table_field_valid     boolean;
        TYPE formula_table_field_array IS TABLE OF VARCHAR2(1000 char) INDEX BY BINARY_INTEGER;
        v_formula_table_fields          formula_table_field_array;

        v_formula_obj                   json_object_t :=  json_object_t();
        v_formula_selected_fields       json_object_t :=  json_object_t();
        v_formula_selected_field        json_object_t :=  json_object_t();
        v_formula_tbname                varchar2(15 char);
        v_formula_field                 varchar2(15 char);
        v_formula_tablefield            varchar2(20 char);
        v_formula_data_type             varchar2(60 char);
        v_formula_flgchksal_bool        boolean;

        v_new_selected_fields   json_object_t :=  json_object_t();
    begin
        v_new_selected_fields := v_selected_fields;
        v_selected_field_row  := v_new_selected_fields.get_size;

        for i in 0..v_selected_fields.get_size-1 loop
            v_selected_field     := hcm_util.get_json_t(v_selected_fields,to_char(i));
            if hcm_util.get_string_t(v_selected_field,'table') = 'FORMULA' then
                v_formula_obj               := hcm_util.get_json_t(v_selected_field,'formula');
                v_formula_selected_fields   := hcm_util.get_json_t(v_formula_obj,'selectedFields');
                if v_formula_selected_fields.get_size > 0 then
                    for j in 0..v_formula_selected_fields.get_size-1 loop
                        v_formula_table_field_valid := true;

                        v_formula_selected_field  := hcm_util.get_json_t(v_formula_selected_fields,to_char(j));
                        v_formula_tbname          := hcm_util.get_string_t(v_formula_selected_field,'table');
                        v_formula_field           := hcm_util.get_string_t(v_formula_selected_field,'code');
                        v_formula_data_type       := hcm_util.get_string_t(v_formula_selected_field,'data_type');
                        v_formula_flgchksal_bool  := nvl(v_formula_selected_field.get_Boolean('flgchksal'), false);

                        for k in 0..v_selected_fields.get_size-1 loop
                            v_selected_field_validate   := hcm_util.get_json_t(v_selected_fields,to_char(k));
                            v_tbname_validate           := hcm_util.get_string_t(v_selected_field_validate,'table');
                            v_field_validate            := hcm_util.get_string_t(v_selected_field_validate,'code');
                            v_label_disp_bool_validate  := nvl(v_selected_field_validate.get_Boolean('labelDisp'), false);
                            if v_tbname_validate <> 'FORMULA' then
                                if (upper(v_tbname_validate) || '_' || upper(v_field_validate)) = (upper(v_formula_tbname) || '_' || upper(v_formula_field)) and v_label_disp_bool_validate = false then
                                    v_formula_table_field_valid := false;
                                    exit;
                                end if;
                            end if;
                        end loop;

                        if v_formula_table_fields.count > 0 then
                            for k in 0..v_formula_table_fields.count-1 loop
                                if upper(v_formula_table_fields(k)) = upper(v_formula_tbname) || '_' || upper(v_formula_field) then
                                    v_formula_table_field_valid := false;
                                    exit;
                                end if;
                            end loop;
                        end if;

                        if v_formula_table_field_valid = true then
                            v_formula_table_fields(v_formula_table_fields.count) := v_formula_tbname || '_' || v_formula_field;

                            v_additional_row          := v_additional_row + 1;

                            v_additional_selected_field.put('table', v_formula_tbname);
                            v_additional_selected_field.put('code', v_formula_field);
                            v_additional_selected_field.put('tableField', 'A_' || v_formula_tbname || '_' || to_char(v_additional_row));
                            v_additional_selected_field.put('data_type', v_formula_data_type);
                            v_additional_selected_field.put('flgchksal', v_formula_flgchksal_bool);
                            v_additional_selected_field.put('labelDisp', false);
                            v_additional_selected_field.put('default', false);
                            v_additional_selected_field.put('orderby', '');
                            v_additional_selected_field.put('flgadditional', true);

                            v_additional_selected_fields.put(to_char(v_additional_row - 1), v_additional_selected_field);
                        end if;
                    end loop;
                end if;
            end if;
        end loop;

        for i in 0..v_additional_selected_fields.get_size-1 loop
            v_additional_selected_field  := hcm_util.get_json_t(v_additional_selected_fields,to_char(i));
            v_new_selected_fields.put(to_char(v_selected_field_row + i), v_additional_selected_field);
        end loop;

        return v_new_selected_fields;
    end;

    function GET_DATA(json_str_input in clob) return clob is
        json_obj            json_object_t;
        p_codapp            varchar2(10 char);
        p_data_rows         json_object_t :=  json_object_t();
        v_data_row          json_object_t :=  json_object_t();
        p_selected_fields   json_object_t :=  json_object_t();
        v_selected_fields   json_object_t :=  json_object_t();
        v_selected_field    json_object_t :=  json_object_t();

        v_tables_str        varchar2(5000 char);

        v_tbname            varchar2(15 char);
        v_field             varchar2(100 char);
        v_tablefield        varchar2(500 char);
        v_flglabel_bool     boolean;
        v_flgdefault_bool   boolean;
        v_flgbreak          varchar2(1 char);
        v_flgsum            varchar2(1 char);
        v_flgskip           varchar2(1 char);
        v_flg_formula_bool  boolean := false;
        v_flg_orderby_bool  boolean := false;

        v_stmt			    varchar2(20000 char);
        v_queryfield        varchar2(4000 char);

        v_query_tables      json_object_t :=  json_object_t();
        v_query_fields      json_object_t :=  json_object_t();

        json_data_rows      json_object_t;
        json_data_row       json_object_t;
        json_str_output     clob;
        v_xx clob;

    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        p_codapp    := hcm_util.get_string_t(json_obj,'codapp');
        p_data_rows := hcm_util.get_json_t(json_obj,'dataRows');
        v_xx := p_data_rows.to_clob;
        p_selected_fields := hcm_util.get_json_t(json_obj,'selectedFields');

        v_selected_fields := get_selected_fields_combine_with_formula(p_selected_fields);

        for x in 0..v_selected_fields.get_size-1 loop
            v_selected_field     := hcm_util.get_json_t(v_selected_fields,to_char(x));
            if v_flg_formula_bool = false then
                if hcm_util.get_string_t(v_selected_field,'table') = 'FORMULA' then
                    v_flg_formula_bool := true;
                end if;
            end if;
            if v_flg_orderby_bool = false then
                if hcm_util.get_string_t(v_selected_field,'orderby') = 'L' or hcm_util.get_string_t(v_selected_field,'orderby') = 'H' then
                    v_flg_orderby_bool := true;
                end if;
            end if;
            if v_flg_formula_bool = true and v_flg_orderby_bool = true then
                exit;
            end if;
        end loop;

        json_data_rows :=  json_object_t();

        -- use v_tables_str for only as parameter of get_query_tables function.

        v_tables_str    := get_tables_str(v_selected_fields);

        for i in 0..p_data_rows.get_size-1 loop
          json_data_row   :=  json_object_t();
          v_data_row      := hcm_util.get_json_t(p_data_rows,to_char(i));
          v_flgbreak := hcm_util.get_string_t(v_data_row,lower('flgbreak'));
          --<<user37 #5217 Final Test Phase 1 V11 02/03/2021
          if hcm_util.get_string_t(v_data_row,lower('flgskip')) = 'Y' or hcm_util.get_string_t(v_data_row,lower('flgskip')) = 'true' then
            v_flgsum := 'Y';
          else
            v_flgsum := 'N';
          end if;
          --v_flgsum := hcm_util.get_string_t(v_data_row,lower('flgsum'));
          -->>user37 #5217 Final Test Phase 1 V11 02/03/2021
          v_flgskip := hcm_util.get_string_t(v_data_row,lower('flgskip'));
          if v_flgbreak = 'Y' or v_flgsum = 'Y' or v_flgskip = 'Y' then
            for x in 0..v_selected_fields.get_size-1 loop
                v_selected_field    := hcm_util.get_json_t(v_selected_fields,to_char(x));
                v_tbname            := hcm_util.get_string_t(v_selected_field,'table');
                v_field             := hcm_util.get_string_t(v_selected_field,'code');
                v_tablefield        := hcm_util.get_string_t(v_selected_field,'tableField');
                v_flgdefault_bool   := nvl(v_selected_field.get_Boolean('default'), false);
                json_data_row.put(upper(v_tablefield), hcm_util.get_string_t(v_data_row,lower(v_field)));
            end loop;
            json_data_row.put('coderror', 200);
            json_data_rows.put(to_char(i), json_data_row);
         --  null;
          else
            if v_tables_str is not null then
              -- v_tables_str must have one table at least!!.
              v_query_tables := get_query_tables(p_codapp, v_data_row, v_selected_fields, v_tables_str);
            end if;
            json_data_row.put('coderror', 200);
            for j in 0..v_selected_fields.get_size-1 loop
                v_selected_field    := hcm_util.get_json_t(v_selected_fields,to_char(j));
                v_tbname            := hcm_util.get_string_t(v_selected_field,'table');
                v_field             := hcm_util.get_string_t(v_selected_field,'code');
                v_tablefield        := hcm_util.get_string_t(v_selected_field,'tableField');
                v_flglabel_bool     := nvl(v_selected_field.get_Boolean('labelDisp'), false);
                v_flgdefault_bool   := nvl(v_selected_field.get_Boolean('default'), false);
                if v_flgdefault_bool = true then
                    json_data_row.put(upper(v_tablefield), hcm_util.get_string_t(v_data_row,lower((v_field))));
                elsif v_flgdefault_bool = false then
                    v_query_fields := hcm_util.get_json_t(v_query_tables, v_tbname);
                    if v_flglabel_bool = false then
                        v_queryfield := hcm_util.get_string_t(v_query_fields, v_field);
                    else
                        v_queryfield := hcm_util.get_string_t(v_query_fields, 'L_' || v_field);
                    end if;
                    json_data_row.put(upper(v_tablefield), v_queryfield);
                end if;
            end loop;
            json_data_rows.put(to_char(i), json_data_row);
          end if;
        end loop;

        if v_flg_formula_bool = true or v_flg_orderby_bool = true then
            json_str_output := ptt_get_data(json_data_rows, v_selected_fields);
        else
            json_str_output := json_data_rows.to_clob;
        end if;

        return json_str_output;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
        commit;
        return json_str_output;
    end;

    function check_statement(json_str_input in clob) return clob is
        v_valid             boolean;
        v_stmt              varchar2(4000 char);
        json_obj            json_object_t;

        json_str_output     clob;
    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        v_stmt          := hcm_util.get_string_t(json_obj,'p_stmt');

        if v_stmt is null then
          param_msg_error := get_error_msg_php('HR2820', global_v_lang, 'function.formula');
          json_str_output := get_response_message('200', param_msg_error, global_v_lang);
          return json_str_output;
        end if;

        if param_msg_error is null then
            begin
                execute immediate 'select '||v_stmt||' from dual';
                v_valid := true;
            exception when others then
                v_valid := false;
            end;
            if not v_valid then
                param_msg_error := get_error_msg_php('HR2810',global_v_lang);
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return json_str_output;
            else
                param_msg_error := get_error_msg_php('HR2820',global_v_lang,'function.formula');
                json_str_output := get_response_message('200',param_msg_error,global_v_lang);
                return json_str_output;
            end if;
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return json_str_output;
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return json_str_output;
    end check_statement;
END HCM_ADJUST_REPORT;

/

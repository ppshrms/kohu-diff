--------------------------------------------------------
--  DDL for Package Body HRTR13X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR13X" AS
        procedure initial_value(json_str_input in clob) as
            json_obj    json;
        begin
            json_obj            := json(json_str_input);

            --global
            global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
            global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
            global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');

            -- index params
            p_codcours          := hcm_util.get_string(json_obj,'p_codcours');
            p_codrep            := hcm_util.get_string(json_obj, 'p_codrep');

            p_table_selected    := hcm_util.get_string(json_obj,'p_table_selected');

            hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

            if p_codrep is null then
                p_codrep := 'TEMP';
            end if;

        end initial_value;

        procedure get_codrep_detail (json_str_input in clob, json_str_output out clob) as
        begin
            initial_value(json_str_input);
            if param_msg_error is null then
              gen_codrep_detail(json_str_output);
            else
              json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            end if;

        exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        end get_codrep_detail;

        procedure gen_codrep_detail (json_str_output out clob) as
            obj_syncond         json;
            obj_row             json;
            v_count_trepdsph    number := 0;
            cursor c_trepdsph is
                select  decode(global_v_lang  , '101',NAMREPE,
                                                '102',NAMREPT,
                                                '103',NAMREP3,
                                                '104',NAMREP4,
                                                '105',NAMREP5,NAMREPT) namrep,
                        namrepe, namrept, namrep3, namrep4, namrep5, syncond,statement
                  from  trepdsph where codrep = p_codrep and codapp = p_codapp;

        begin
            for trep in c_trepdsph loop
                v_count_trepdsph := v_count_trepdsph + 1;
            end loop;

            obj_row     := json();
            obj_row.put('coderror', '200');
            obj_row.put('codrep', p_codrep);
            if v_count_trepdsph > 0 then
                for trep in c_trepdsph loop
                  obj_row.put('namrep', trep.namrep);
                  obj_row.put('namrepe', trep.namrepe);
                  obj_row.put('namrept', trep.namrept);
                  obj_row.put('namrep3', trep.namrep3);
                  obj_row.put('namrep4', trep.namrep4);
                  obj_row.put('namrep5', trep.namrep5);
                  obj_syncond   := json();
                  obj_syncond.put('code', trep.syncond);
                  obj_syncond.put('description', get_logical_name(p_codapp,trep.syncond,global_v_lang));
                  obj_syncond.put('statement', trep.statement);
                  obj_row.put('syncond', obj_syncond);
                  obj_row.put('flgexist', true);
                end loop;
            else
                  obj_row.put('namrep',  '');
                  obj_row.put('namrepe', '');
                  obj_row.put('namrept', '');
                  obj_row.put('namrep3', '');
                  obj_row.put('namrep4', '');
                  obj_row.put('namrep5', '');
                  --
                  obj_syncond   := json();
                  obj_syncond.put('code', '');
                  obj_syncond.put('description', '');
                  obj_syncond.put('statement', '');
                  --
                  obj_row.put('syncond', obj_syncond);
                obj_row.put('flgexist', false);
            end if;

            if p_codrep = 'TEMP' then
                obj_row.put('namrep',  '');
                obj_row.put('namrepe', '');
                obj_row.put('namrept', '');
                obj_row.put('namrep3', '');
                obj_row.put('namrep4', '');
                obj_row.put('namrep5', '');
            end if;

            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end gen_codrep_detail;

        procedure get_format_fields(json_str_input in clob, json_str_output out clob) as
        begin
            initial_value(json_str_input);
            if param_msg_error is null then
              gen_format_fields(json_str_output);
            else
              json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            end if;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end;

        procedure gen_format_fields(json_str_output out clob) is
            obj_row     json;
            obj_data    json;
            v_rcnt      number  := 0;
            v_count_c1  number  := 0;
            cursor c1 is
                select  t1.codcolmn,
                      t1.descolmn as desc_colmn,
                      t1.codtable
                from    trepdspd t1
                where   t1.codapp     = p_codapp
                and     t1.codrep     = p_codrep
                order by t1.numseq;
            cursor c2 is
                select  column_id codcolmn,
                      decode(global_v_lang,'101',descole,
                                           '102',descolt,
                                           '103',descol3,
                                           '104',descol4,
                                           '105',descol5) desc_colmn,
                      codtable
                from    tcoldesc
                where   codtable = 'TCOURSE' and column_id in (1,2,3,4,5,6)
                order by column_id;
        begin
            obj_row     := json();

            for r1 in c1 loop
                v_count_c1 := v_count_c1 + 1;
            end loop;

            if v_count_c1 > 0 then
                for r1 in c1 loop
                  obj_data    := json();
                  v_rcnt      := v_rcnt + 1;
                  obj_data.put('coderror','200');
                  obj_data.put('numseq', to_char(r1.codcolmn));
                  obj_data.put('desc_colmn', r1.desc_colmn);
                  obj_data.put('codtable', r1.codtable);
                  if  (r1.codcolmn = 1 and r1.codtable = 'TCOURSE') or
                      (r1.codcolmn = 2 and r1.codtable = 'TCOURSE' and global_v_lang = '101') or
                      (r1.codcolmn = 3 and r1.codtable = 'TCOURSE' and global_v_lang = '102') or
                      (r1.codcolmn = 4 and r1.codtable = 'TCOURSE' and global_v_lang = '103') or
                      (r1.codcolmn = 5 and r1.codtable = 'TCOURSE' and global_v_lang = '104') or
                      (r1.codcolmn = 6 and r1.codtable = 'TCOURSE' and global_v_lang = '105') then
                        obj_data.put('default', true);
                  else
                    obj_data.put('default', false);
                  end if;
                  obj_row.put(to_char(v_rcnt - 1), obj_data);
                end loop;
            else
                for r2 in c2 loop
                    if  (r2.codcolmn = 1) or (r2.codcolmn = 2 and global_v_lang = '101') or (r2.codcolmn = 3 and global_v_lang = '102') or
                        (r2.codcolmn = 4 and global_v_lang = '103') or (r2.codcolmn = 5 and global_v_lang = '104') or
                        (r2.codcolmn = 6 and global_v_lang = '105') then
                            obj_data    := json();
                            v_rcnt      := v_rcnt + 1;
                            obj_data.put('coderror','200');
                            obj_data.put('numseq', to_char(r2.codcolmn));
                            obj_data.put('desc_colmn', r2.desc_colmn);
                            obj_data.put('codtable', r2.codtable);
                            obj_data.put('default', true);
                            obj_row.put(to_char(v_rcnt - 1), obj_data);
                    end if;
                end loop;
            end if;
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end gen_format_fields;

        procedure get_list_fields(json_str_input in clob,json_str_output out clob) as
        begin
            initial_value(json_str_input);
            if param_msg_error is null then
              gen_list_fields(json_str_output);
            else
              json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            end if;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end;

        procedure gen_list_fields(json_str_output out clob) as
            obj_row     json;
            obj_data    json;
            v_rcnt      number  := 0;
            cursor c1 is
            select  column_id,
                  decode(global_v_lang,'101',descole,
                                       '102',descolt,
                                       '103',descol3,
                                       '104',descol4,
                                       '105',descol5) desc_colmn,
                  codtable
            from    tcoldesc
            where   codtable = p_table_selected
            order by column_id;
        begin
            obj_row     := json();
            for r1 in c1 loop
                obj_data    := json();
                v_rcnt      := v_rcnt + 1;
                obj_data.put('coderror','200');
                obj_data.put('numseq', r1.column_id);
                obj_data.put('desc_colmn', r1.desc_colmn);
                obj_data.put('codtable',r1.codtable);
                obj_row.put(to_char(v_rcnt - 1),obj_data);
            end loop;
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end gen_list_fields;

        procedure get_table(json_str_input in clob, json_str_output out clob) as
        begin
            initial_value(json_str_input);
            if param_msg_error is null then
                gen_table(json_str_input, json_str_output);
            else
               json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            end if;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
        end get_table;

        procedure gen_table (json_str_input in clob,json_str_output out clob) as
            v_stmt_main     clob;
            v_stmt_query    clob;
            v_stmt_replace  clob;
            v_subquery      clob  := ' ';

            v_select        varchar2(4000)  := ' select ';
            v_str_join      varchar2(4000)  := ' from ';
            v_where         varchar2(4000)  := ' where ';
            v_alias_column  varchar2(1000);
            v_outer_join    varchar2(1000);
            v_comma         varchar2(1);

            v_obj_detail_style          json;
            v_obj_detail_style_row      json;
            v_rcnt_style                number  := 0;

            v_cursor_main   number;
            v_cursor_query  number;
            v_rcnt          number  := 0;
            v_column_size   number  := 0;
            v_count_table   number  := 0;
            v_dummy         integer;

            json_str        json;
            json_columns    json;
            json_row        json;
            json_syncond    json;
            obj_row         json;
            obj_data        json;

            v_index_field   tcoldesc.column_id%type;
            v_table         tcoldesc.codtable%type;
            v_codcolmn      tcoldesc.codcolmn%type;
            v_numseq        tcoldesc.column_id%type;
            v_codsearch     trepdspd.codsearch%type;
            v_funcdesc      tcoldesc.funcdesc%type;
            v_flgchksal     tcoldesc.flgchksal%type;
            v_descole       tcoldesc.descole%type;
            v_descolt       tcoldesc.descolt%type;
            v_descol3       tcoldesc.descol3%type;
            v_descol4       tcoldesc.descol4%type;
            v_descol5       tcoldesc.descol5%type;

            v_codcours      tcourse.codcours%type;
            v_time          varchar2(500) := 'lpad(nvl(trunc(TCOURSE_temp.QTYTRHUR),0),2,''0'') || '':'' || rpad(nvl(((TCOURSE_temp.QTYTRHUR - trunc(TCOURSE_temp.QTYTRHUR))*60),0),2,''0'')';
            v_count         number;

            r_trepdsph      trepdsph%rowtype;

            type t_data is table of varchar2(1000) index by binary_integer;
            array_data_query  t_data;
            type t_table_name is table of varchar2(1000) index by binary_integer;
            array_table_name  t_table_name;
        begin
            obj_row              := json();
            v_obj_detail_style_row  := json();
            json_str             := json(json_str_input);
            r_trepdsph.codrep    := hcm_util.get_string(json_str, 'p_codrep');
            r_trepdsph.namrepe   := hcm_util.get_string(json_str, 'p_namrepe');
            r_trepdsph.namrept   := hcm_util.get_string(json_str, 'p_namrept');
            r_trepdsph.namrep3   := hcm_util.get_string(json_str, 'p_namrep3');
            r_trepdsph.namrep4   := hcm_util.get_string(json_str, 'p_namrep4');
            r_trepdsph.namrep5   := hcm_util.get_string(json_str, 'p_namrep5');
            json_syncond         := hcm_util.get_json(json_str,'p_syncond');
            r_trepdsph.syncond   := hcm_util.get_string(json_syncond, 'code');
            r_trepdsph.statement := hcm_util.get_string(json_syncond, 'statement');
            json_columns         := hcm_util.get_json(json_str, 'p_format_fields');

            if  r_trepdsph.codrep is null or r_trepdsph.codrep = 'TEMP' then
                r_trepdsph.codrep := 'TEMP';
                r_trepdsph.namrepe   := '';
                r_trepdsph.namrept   := '';
                r_trepdsph.namrep3   := '';
                r_trepdsph.namrep4   := '';
                r_trepdsph.namrep5   := '';
            end if;
            insert_trepdsph(r_trepdsph);

            v_column_size := json_columns.count;
            for i in 1..v_column_size loop
              array_data_query(i) := null;
            end loop;

            if r_trepdsph.syncond is not null then
                v_where := v_where||'('||r_trepdsph.syncond||')';
            else
                v_where := '';
            end if;

            v_stmt_main   := ' select tcourse.codcours '||
                             ' from tcourse '||
                             ' full outer join tcoursub '||
                             ' on tcourse.codcours = tcoursub.codcours '||
                             ' full outer join tcomptcr ' ||
                             ' on tcourse.codcours = tcomptcr.codcours '||v_where||
                             ' group by tcourse.codcours '||
                             ' order by tcourse.codcours';

            delete from trepdspd
            where   codapp = p_codapp
            and     codrep = p_codrep;

            for i in 1..v_column_size loop
                v_obj_detail_style      := json();
                v_rcnt_style            := v_rcnt_style + 1;
                json_row        := hcm_util.get_json(json_columns, to_char(i - 1));
                v_index_field   := hcm_util.get_string(json_row,'numseq');
                v_table         := hcm_util.get_string(json_row,'codtable');

                begin
                    select  column_id,codcolmn,funcdesc,flgchksal,
                            descole,descolt,descol3,descol4,descol5
                    into    v_numseq,v_codcolmn,v_funcdesc,v_flgchksal,
                            v_descole,v_descolt,v_descol3,v_descol4,v_descol5
                    from    tcoldesc
                    where   codtable    = v_table
                    and     column_id   = v_index_field;
                exception when no_data_found then
                    v_codcolmn    := null;
                    v_funcdesc    := null;
                    v_flgchksal   := null;
                end;

                v_obj_detail_style.put('key', 'column'||to_char(i));
                if v_codcolmn like 'DTE%' then
                    v_alias_column    := 'to_char('||v_codcolmn||',''dd/mm/yyyy'') as '||v_codcolmn;
                    v_obj_detail_style.put('style', 'date');
                elsif v_codcolmn like 'AMT%' then
                    v_obj_detail_style.put('style','number-right');
                    v_alias_column    := v_codcolmn;
                elsif v_codcolmn like 'TYP%' then
                    v_obj_detail_style.put('style','typ');
                    v_alias_column    := v_codcolmn;
                elsif v_codcolmn like 'FLG%' then
                    v_obj_detail_style.put('style','flg');
                    v_alias_column    := v_codcolmn;
                elsif v_codcolmn like 'COD%' then
                    v_obj_detail_style.put('style','code');
                    v_alias_column    := v_codcolmn;
                else
                    if v_codcolmn = 'SYNCOND' then
                        v_alias_column    := 'get_logical_desc(statement) as '||v_codcolmn;
                    else
                        v_alias_column    := v_codcolmn;
                    end if;
                    v_obj_detail_style.put('style',get_item_property(v_table,v_codcolmn));
                end if;

                v_obj_detail_style_row.put(to_char(v_rcnt_style - 1),v_obj_detail_style);
                gen_style_column(v_obj_detail_style_row, 'N');

                v_select  := v_select||v_comma||v_table||'_temp.'||v_codcolmn;

                --- vvv Create subquery vvv ---
                if instr(v_subquery,v_table) = 0 then
                    v_count_table     := v_count_table + 1;

                    v_subquery  := v_subquery||v_comma||v_table||'_temp '||' as '||' ( select rownum as rowno,'||v_alias_column||'<'||v_table||'> '||
                                                                                 '   from '||v_table||' '||
                                                                                 '   where codcours = ''<codcours>'' ) ';

                    array_table_name(v_count_table)  := v_table;
                else
                    v_subquery    := replace(v_subquery,'<'||v_table||'>',v_comma||v_alias_column||'<'||v_table||'>');
                end if;
                v_comma       := ',';
                insert into trepdspd(codapp,codrep,numseq,codtable,codcolmn,descolmn,
                                 codsearch,funcdesc,flgchksal,codcreate,coduser)
                         values (p_codapp,r_trepdsph.codrep,i,v_table,v_numseq,
                                 decode(global_v_lang,'101',v_descole
                                                     ,'102',v_descolt
                                                     ,'103',v_descol3
                                                     ,'104',v_descol4
                                                     ,'105',v_descol5),
                                 v_codsearch,v_funcdesc,v_flgchksal,global_v_coduser,global_v_coduser);
            end loop;
            commit;

            --- vvv Full Outer Join Subquery vvv ---
            for i in 1..array_table_name.count loop
                v_subquery    := replace(v_subquery,'<'||array_table_name(i)||'>','');
                v_outer_join  := nvl(v_outer_join, array_table_name(i)||'_temp');
                v_str_join    := v_str_join||v_outer_join;
                exit when i = array_table_name.count;
                v_outer_join  := ' full outer join '||array_table_name(i + 1)||'_temp'||' on '||array_table_name(i)||'_temp.rowno = '||array_table_name(i + 1)||'_temp.rowno ';
            end loop;

            --- vvv Intregate String vvv ---
            v_stmt_query    := ' with '||v_subquery||v_select||v_str_join;
            v_cursor_main   := dbms_sql.open_cursor;
            dbms_sql.parse(v_cursor_main,v_stmt_main,dbms_sql.native);
            dbms_sql.define_column(v_cursor_main,1,v_codcours,1000);
            v_dummy := dbms_sql.execute(v_cursor_main);

            v_cursor_query  := dbms_sql.open_cursor;
            v_count         := 0;
            while (dbms_sql.fetch_rows(v_cursor_main) > 0) loop
                v_count := v_count + 1;
                dbms_sql.column_value(v_cursor_main,1,v_codcours);

                v_stmt_replace  := replace(v_stmt_query,'<codcours>',v_codcours);
                v_stmt_replace  := replace(v_stmt_replace,'TCOURSE_temp.QTYTRHUR',v_time);
                dbms_sql.parse(v_cursor_query,v_stmt_replace,dbms_sql.native);
                for i in 1..v_column_size loop
                  dbms_sql.define_column(v_cursor_query,i,array_data_query(i),1000);
                end loop;
                v_dummy := dbms_sql.execute(v_cursor_query);

                while (dbms_sql.fetch_rows(v_cursor_query) > 0) loop
                  v_rcnt      := v_rcnt + 1;
                  obj_data    := json();
                  obj_data.put('coderror', '200');
                  obj_data.put('codcours', v_codcours);
                  obj_data.put('column_size', v_column_size);
                  for i in 1..v_column_size loop
                    dbms_sql.column_value(v_cursor_query,i,array_data_query(i));
                    obj_data.put('column'||to_char(i), array_data_query(i));
                  end loop;
                  obj_row.put(to_char(v_rcnt - 1), obj_data);
                end loop;
            end loop;
            if v_count > 0 then
                dbms_lob.createtemporary(json_str_output, true);
                obj_row.to_clob(json_str_output);
            else
                param_msg_error := get_error_msg_php('HR2055', global_v_lang);
                json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            end if;
        end gen_table;

        procedure gen_style_column (v_objrow in json, v_img varchar2) as
            v_count number;
            v_objdetail json;
            v_style_data trepapp2.style_data%type;
            v_style_column trepapp2.style_column%type;
        begin
             begin
                delete from trepapp2
                where codapp = 'HRTR13X';
             end;

                v_count := v_objrow.count;

                if (v_img = 'Y') then
                          insert into trepapp2 (codapp,keycolumn,style_column,
                          style_data,dtecreate,codcreate)
                          values ('HRTR13X','img',
                                  'text-align: center; vertical-align: middle; width: 50px;',
                                  'text-align: center;',sysdate,global_v_coduser);
                end if;

                for i in 1..v_count loop
                   v_objdetail := json(v_objrow.get(i));

                   if (hcm_util.get_string(v_objdetail,'style')= 'text') then
                        v_style_data    := 'text-align: left;';
                        v_style_column  := 'text-align: center; vertical-align: middle; width: 150px;';
                   elsif (hcm_util.get_string(v_objdetail,'style')= 'date') then
                        v_style_data    := 'text-align: center;';
                        v_style_column  := 'text-align: center; vertical-align: middle; width: 100px;';
                   elsif (hcm_util.get_string(v_objdetail,'style')= 'number-center') then
                        v_style_data    := 'text-align: center;';
                        v_style_column  := 'text-align: center; vertical-align: middle; width: 100px;';
                   elsif (hcm_util.get_string(v_objdetail,'style')= 'number-right') then
                        v_style_data    := 'text-align: right;';
                        v_style_column  := 'text-align: center; vertical-align: middle; width: 100px;';
                   else
                        v_style_data := 'text-align: center;';
                        v_style_column  := 'text-align: center; vertical-align: middle; width: 100px;';
                   end if;

                   begin
                      insert into trepapp2 (codapp,keycolumn,style_column,
                      style_data,dtecreate,codcreate)
                      values ('HRTR13X',hcm_util.get_string(v_objdetail,'key'),v_style_column,
                      v_style_data,sysdate,global_v_coduser);
                   end;
                end loop;

        end gen_style_column;

        function  get_item_property (p_table in VARCHAR2,p_field  in VARCHAR2)    return varchar2 is
            v_data_type   user_tab_columns.data_type%type;
        begin
            begin
              select  t.data_type as DATATYPE
              into    v_data_type
              from    user_tab_columns t
              where   t.TABLE_NAME    = p_table
              and     t.COLUMN_NAME   = p_field;
            exception when no_data_found then
              v_data_type   := 'TEXT';
            end;

            if v_data_type = 'NUMBER' then
                return 'number-center';
            else
                return 'text';
            end if;
        end get_item_property;

        procedure insert_trepdsph(p_r_trepdsph trepdsph%rowtype) is
        begin
            begin
              insert into trepdsph (codapp,codrep,
                                    namrepe,namrept,namrep3,namrep4,namrep5,
                                    syncond,codcreate,coduser,statement)
                     values  (p_codapp,p_r_trepdsph.codrep,
                              p_r_trepdsph.namrepe,p_r_trepdsph.namrept,p_r_trepdsph.namrep3,p_r_trepdsph.namrep4,p_r_trepdsph.namrep5,
                              p_r_trepdsph.syncond,global_v_coduser,global_v_coduser,p_r_trepdsph.statement);
            exception when dup_val_on_index then
              update  trepdsph
              set     namrepe     = p_r_trepdsph.namrepe,
                      namrept     = p_r_trepdsph.namrept,
                      namrep3     = p_r_trepdsph.namrep3,
                      namrep4     = p_r_trepdsph.namrep4,
                      namrep5     = p_r_trepdsph.namrep5,
                      syncond     = p_r_trepdsph.syncond,
                      statement   = p_r_trepdsph.statement,
                      coduser     = global_v_coduser
              where   codapp      = p_codapp
              and     codrep      = p_r_trepdsph.codrep;
            end;
        end insert_trepdsph;

        procedure delete_codrep (json_str_input in clob, json_str_output out clob) as
            json_str        json;
        begin
            initial_value(json_str_input);
            if param_msg_error is null then
                delete from trepdsph
                      where codapp = p_codapp
                        and codrep = p_codrep;

                delete from trepdspd
                      where codapp = p_codapp
                        and codrep = p_codrep;
            end if;

            if param_msg_error is null then
                param_msg_error := get_error_msg_php('HR2715', global_v_lang);
                json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            else
                json_str_output := get_response_message('400', param_msg_error, global_v_lang);
            end if;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
        end delete_codrep;

        procedure get_tab1_detail(json_str_input in clob, json_str_output out clob) as
        begin
          initial_value(json_str_input);
          if param_msg_error is null then
            gen_tab1_detail(json_str_output);
          end if;
          if param_msg_error is not null then
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
          end if;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end get_tab1_detail;

        procedure gen_tab1_detail(json_str_output out clob) as
            obj_row           json;
            v_namcours        varchar2(200 char);
            v_namcate         varchar2(1000 char);
            v_descours        varchar2(1000 char);
            v_typtrain        varchar2(1000 char);
            v_url1            varchar2(200 char);
            v_url2            varchar2(200 char);
            v_namdevp         varchar2(1000 char);
            v_descdevp        varchar2(200 char);
            v_naminst         varchar2(1000 char);
            v_namsubj         varchar2(1000 char);
            v_namconslt       varchar2(1000 char);
            v_flgcommt        varchar2(1 char);
            v_descommt        varchar2(1000 char);
            v_descommt2       varchar2(1000 char);
            v_syncond         varchar2(1000 char);
            v_statement       clob;
            v_qtytrhur        number(5,2);
            v_qtytrflw        number(3,0);
            v_qtytrday        number(5,2);
            v_filecommt       varchar2(60 char);

        begin

            begin
                select get_tcourse_name(codcours,global_v_lang) namcours,get_tlistval_name('TYPTRAIN', tcourse.typtrain,global_v_lang) namtyptrain,
                       tcourse.codcate||' '|| get_tcodec_name('TCODCATE', tcourse.codcate,global_v_lang) namcate,
                       descours,url1,url2,
                       tcourse.codsubj||' '|| get_tcodec_name('TSUBJECT', tcourse.codsubj,global_v_lang) namsubj,
                       get_tlistval_name('METTRAIN', tcourse.coddevp,global_v_lang) namdevp,
                       descdevp,
                       tcourse.codinst||' '|| get_tinstruc_name(tcourse.codinst,global_v_lang) naminst,
                       tcourse.codconslt||' '|| get_temploy_name(tcourse.codconslt,global_v_lang) namconslt,
                       flgcommt,descommt,descommt2,
                       get_logical_desc(tcourse.statement) namsyncond,
                       qtytrhur,qtytrday,qtytrflw,filecommt
                into v_namcours, v_typtrain, v_namcate,v_descours,v_url1,v_url2,v_namsubj,v_namdevp,v_descdevp,v_naminst,v_namconslt,
                     v_flgcommt,v_descommt,v_descommt2,v_syncond,v_qtytrhur,v_qtytrday,v_qtytrflw,v_filecommt
                from tcourse
                where codcours = p_codcours;
            exception when no_data_found then
                v_namcours       := null;
                v_namcate         := null;
                v_descours        := null;
                v_typtrain        := null;
                v_url1            := null;
                v_url2            := null;
                v_namdevp         := null;
                v_descdevp        := null;
                v_naminst         := null;
                v_namsubj         := null;
                v_namconslt       := null;
                v_flgcommt        := null;
                v_descommt        := null;
                v_descommt2       := null;
                v_syncond         := null;
                v_statement       := null;
                v_qtytrhur        := null;
                v_qtytrflw        := null;
                v_qtytrday        := null;
                v_filecommt       := null;
            end;

            obj_row := json();
            obj_row.put('codcours', p_codcours);
            obj_row.put('namcours', v_namcours);
            obj_row.put('typtrain', v_typtrain);
            obj_row.put('namcate', v_namcate);
            obj_row.put('descours', v_descours);
            obj_row.put('url1', v_url1);
            obj_row.put('url2', v_url2);
            obj_row.put('namsubj', v_namsubj);
            obj_row.put('namdevp', v_namdevp);
            obj_row.put('descdevp', v_descdevp);
            obj_row.put('naminst', v_naminst);
            obj_row.put('namconslt', v_namconslt);
            obj_row.put('flgcommt', get_tlistval_name('FLGCOMMT',v_flgcommt,global_v_lang));
            obj_row.put('descommt', v_descommt);
            obj_row.put('descommt2', v_descommt2);
            obj_row.put('syncond', v_syncond);
            --obj_row.put('qtytrhur', trunc(v_qtytrhur/60) || ':' || (v_qtytrhur - trunc(v_qtytrhur/60)*60)); --#8194 || 09/08/2022
            obj_row.put('qtytrhur', lpad(nvl(trunc(v_qtytrhur),0),2,'0') || ':' || rpad(nvl(((v_qtytrhur - trunc(v_qtytrhur))*60),0),2,'0'));            
            obj_row.put('qtytrday', v_qtytrday);
            obj_row.put('qtytrflw', v_qtytrflw);
            obj_row.put('filecommt', v_filecommt);

            obj_row.put('coderror', '200');

            if isInsertReport then
                insert_ttemprpt(obj_row);
            end if;
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end gen_tab1_detail;

        procedure get_tab2_detail(json_str_input in clob, json_str_output out clob) as
        begin
          initial_value(json_str_input);
          if param_msg_error is null then
            gen_tab2_detail(json_str_output);
          end if;
          if param_msg_error is not null then
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
          end if;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end get_tab2_detail;

        procedure gen_tab2_detail(json_str_output out clob) as
            obj_row           json;

            cursor c_tab2 is
                select descobjt, descbenefit, tcourse.codresp||' '|| get_temploy_name(tcourse.codresp,global_v_lang) namresp, filename,
                       qtyppc, amtbudg, desceval, desmeasure, get_tintview_name(codform, global_v_lang) namform,
                       get_tcenter_name(codcomptr,global_v_lang) namcomptr, flgelern, typcours
                from tcourse
                where codcours = p_codcours;
        begin
            obj_row := json();
            obj_row.put('coderror', '200');
            for i in c_tab2 loop
                obj_row.put('descobjt', i.descobjt);
                obj_row.put('descbenefit', i.descbenefit);
                obj_row.put('namresp', i.namresp);
                obj_row.put('filename', i.filename);
                obj_row.put('qtyppc', i.qtyppc);
                obj_row.put('amtbudg', i.amtbudg);
                obj_row.put('desceval', i.desceval);
                obj_row.put('desmeasure', i.desmeasure);
                obj_row.put('namform', i.namform);
                obj_row.put('namcomptr', i.namcomptr);
                obj_row.put('flgelern', get_tlistval_name('FLGELERN',i.flgelern,global_v_lang));
                obj_row.put('typcours', get_tlistval_name('TYPCOURSE',i.typcours,global_v_lang));
            end loop;
            if isInsertReport then
                insert_ttemprpt(obj_row);
            end if;
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end gen_tab2_detail;

        procedure get_tab3_detail(json_str_input in clob, json_str_output out clob) as
        begin
          initial_value(json_str_input);
          if param_msg_error is null then
            gen_tab3_detail(json_str_output);
          end if;
          if param_msg_error is not null then
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
          end if;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end get_tab3_detail;

        procedure gen_tab3_detail(json_str_output out clob) as
            obj_row           json;
            obj_data          json;
            v_row             number := 0;
            cursor c1 is
                select codsubj, codinst,get_tsubject_name(tcoursub.codsubj,global_v_lang) namsubj,
                qtytrhr , get_tinstruc_name(tcoursub.codinst,global_v_lang) naminst
                from tcoursub
                where codcours = p_codcours;
        begin
            obj_row := json();
                for i in c1 loop
                    v_row       := v_row + 1;
                    obj_data    := json();
                    obj_data.put('codsubj', i.codsubj);
                    obj_data.put('namsubj', i.namsubj);
                    obj_data.put('codinst', i.codinst);
                    obj_data.put('naminst', i.naminst);
                    obj_data.put('qtytrhr', trunc(i.qtytrhr/60) || ':' || (i.qtytrhr - trunc(i.qtytrhr/60)*60));
                    obj_data.put('coderror', '200');
                    obj_row.put(to_char(v_row-1),obj_data);
                end loop;
            if isInsertReport then
                insert_ttemprpt(obj_row);
            end if;
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end gen_tab3_detail;

        procedure initial_report(json_str in clob) is
            json_obj        json;
        begin
            json_obj            := json(json_str);
            global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
            global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
            global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

            json_codcours       := hcm_util.get_json(json_obj, 'p_codcours');

        end initial_report;

        procedure gen_report(json_str_input in clob,json_str_output out clob) is
            json_output       clob;
        begin
            initial_report(json_str_input);
            isInsertReport := true;
            if param_msg_error is null then
              clear_ttemprpt;
              for i in 0..json_codcours.count-1 loop
                p_codcours := hcm_util.get_string(json_codcours, to_char(i));
                p_codapp            := 'HRTR13X1';
                gen_tab1_detail(json_output);
                p_codapp            := 'HRTR13X2';
                gen_tab2_detail(json_output);
                p_codapp            := 'HRTR13X3';
                gen_tab3_detail(json_output);
              end loop;
            end if;

            if param_msg_error is null then
              param_msg_error := get_error_msg_php('HR2715',global_v_lang);
              commit;
            else
              rollback;
            end if;
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
        end gen_report;

        procedure clear_ttemprpt is
        begin
            begin
              delete
                from ttemprpt
               where codempid = global_v_codempid
                 and codapp IN ('HRTR13X1', 'HRTR13X2','HRTR13X3');
            exception when others then
              null;
            end;
        end clear_ttemprpt;

        procedure insert_ttemprpt(obj_data in json) is
            v_numseq            number := 0;
        begin
            if p_codapp = 'HRTR13X1' then
                begin
                  select nvl(max(numseq), 0)
                    into v_numseq
                    from ttemprpt
                   where codempid = global_v_codempid
                     and codapp   = p_codapp;
                exception when no_data_found then
                  null;
                end;
                v_numseq := v_numseq + 1;
                begin
                  insert
                    into ttemprpt
                       (
                         codempid, codapp, numseq,
                         item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12, item13, item14, item15 , item16 , item17 , item18 ,item19 , item20
                       )
                  values
                       (
                         global_v_codempid, p_codapp, v_numseq,
                         nvl(hcm_util.get_string(obj_data, 'codcours'), ''),
                         nvl(hcm_util.get_string(obj_data, 'namcours'), ''), nvl(hcm_util.get_string(obj_data, 'typtrain'), ''),
                         nvl(hcm_util.get_string(obj_data, 'namcate'), ''), nvl(hcm_util.get_string(obj_data, 'url1'), ''),
                         nvl(hcm_util.get_string(obj_data, 'descours'), ''), nvl(hcm_util.get_string(obj_data, 'url2'), ''),
                         nvl(hcm_util.get_string(obj_data, 'namsubj'), ''), nvl(hcm_util.get_string(obj_data, 'descommt2'), ''),
                         nvl(hcm_util.get_string(obj_data, 'namdevp'), ''), nvl(hcm_util.get_string(obj_data, 'syncond'), ''),
                         nvl(hcm_util.get_string(obj_data, 'descdevp'), ''), nvl(hcm_util.get_string(obj_data, 'qtytrhur'), ''),
                         nvl(hcm_util.get_string(obj_data, 'naminst'), ''), nvl(hcm_util.get_string(obj_data, 'qtytrday'), ''),
                         nvl(hcm_util.get_string(obj_data, 'namconslt'), ''), nvl(hcm_util.get_string(obj_data, 'qtytrflw'), ''),
                         nvl(hcm_util.get_string(obj_data, 'flgcommt'),''), nvl(hcm_util.get_string(obj_data, 'filecommt'), ''),
                         nvl(hcm_util.get_string(obj_data, 'descommt'), '')

                       );
                exception when others then
                  null;
                end;
            elsif p_codapp = 'HRTR13X2' then
                begin
                    update  ttemprpt
                    set     item21    = nvl(hcm_util.get_string(obj_data, 'descobjt'), ''),
                            item22    = nvl(hcm_util.get_string(obj_data, 'descbenefit'), ''),
                            item23    = nvl(hcm_util.get_string(obj_data, 'namresp'), ''),
                            item24    = nvl(hcm_util.get_string(obj_data, 'desceval'), ''),
                            item25    = nvl(hcm_util.get_string(obj_data, 'filename'), ''),
                            item26    = nvl(hcm_util.get_string(obj_data, 'desmeasure'), ''),
                            item27    = nvl(hcm_util.get_string(obj_data, 'qtyppc'), ''),
                            item28    = nvl(hcm_util.get_string(obj_data, 'namform'), ''),
                            item29    = nvl(hcm_util.get_string(obj_data, 'amtbudg'), ''),
                            item30    = nvl(hcm_util.get_string(obj_data, 'namcomptr'), ''),
                            item31    = nvl(hcm_util.get_string(obj_data, 'flgelern'), ''),
                            item32    = nvl(hcm_util.get_string(obj_data, 'typcours'), '')
                    where   codempid    = global_v_codempid
                    and     codapp      = 'HRTR13X1'
                    and     item1       = p_codcours;
                exception when others then
                    rollback;
                end;
            elsif p_codapp = 'HRTR13X3' then
                for i in 0..obj_data.count-1 loop
                    begin
                      select nvl(max(numseq), 0)
                        into v_numseq
                        from ttemprpt
                       where codempid = global_v_codempid
                         and codapp   = p_codapp;
                    exception when no_data_found then
                      null;
                    end;
                    v_numseq := v_numseq + 1;

                    begin
                      insert
                        into ttemprpt
                           (
                             codempid, codapp, numseq, item1, item2, item3, item4 , item5 ,item6, item7
                           )
                      values
                           (
                             global_v_codempid, p_codapp, v_numseq,
                             p_codcours,
                             nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codsubj'), ''),
                             nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'namsubj'), ''),
                             nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codinst'), ''),
                             nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'naminst'), ''),
                             nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'qtytrhr'), ''),
                             to_char(i+1)
                           );
                    exception when others then
                      null;
                    end;
                end loop;
            end if;
        end insert_ttemprpt;
END HRTR13X;

/

--------------------------------------------------------
--  DDL for Package Body HRTR24X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR24X" is
      procedure initial_value(json_str_input in clob) as
        json_obj          json;
      begin
        json_obj            := json(json_str_input);

        global_chken        := '';
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        p_codinst           := hcm_util.get_string(json_obj,'p_codinst');
        p_codrep            := hcm_util.get_string(json_obj,'p_codrep');
        p_table_selected    := hcm_util.get_string(json_obj,'p_table_selected');

        p_codempid          := get_codempid_bycodinst(p_codinst);
        p_stainst           := get_tinstruc_stainst(p_codinst);
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        if p_codrep is null then
                p_codrep := 'TEMP';
        end if;

      end initial_value;
      --
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
                  --
                  obj_syncond   := json();
                  obj_syncond.put('code', trep.syncond);
                  obj_syncond.put('description', get_logical_name(p_codapp,trep.syncond,global_v_lang));
                  obj_syncond.put('statement', trep.statement);
                  --
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
      --
      procedure get_codrep_detail(json_str_input in clob, json_str_output out clob) as obj_row json;
      begin
        initial_value(json_str_input);
        if param_msg_error is null then
          gen_codrep_detail(json_str_output);
        else
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
      end;
      --

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
      end;

      procedure gen_table(json_str_input in clob,json_str_output out clob) as
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
        v_n_codempid    number  := 0;
        v_dummy         integer;

        json_str        json_object_t;
        json_columns    json_object_t;
        json_row        json_object_t;
        json_syncond    json_object_t;
        obj_row         json_object_t;
        obj_data        json_object_t;

        v_index_field   treport.numseq%type;
        v_table         treport.codtable%type;
        v_codcolmn      treport.codcolmn%type;
        v_numseq        treport.numseq%type;
        v_codsearch     treport.codsearch%type;
        v_funcdesc      treport.funcdesc%type;
        v_flgchksal     treport.flgchksal%type;
        v_descole       treport.descole%type;
        v_descolt       treport.descolt%type;
        v_descol3       treport.descol3%type;
        v_descol4       treport.descol4%type;
        v_descol5       treport.descol5%type;

        v_codinst      tinstruc.codinst%type;

        r_trepdsph      trepdsph%rowtype;
        v_count         number;

        type t_data is table of varchar2(1000) index by binary_integer;
        array_data_query  t_data;
        type t_table_name is table of varchar2(1000) index by binary_integer;
        array_table_name  t_table_name;
      begin
        obj_row              := json_object_t();
        v_obj_detail_style_row  := json();
        json_str             := json_object_t(json_str_input);
        r_trepdsph.codrep    := hcm_util.get_string_t(json_str, 'p_codrep');
        r_trepdsph.namrepe   := hcm_util.get_string_t(json_str, 'p_namrepe');
        r_trepdsph.namrept   := hcm_util.get_string_t(json_str, 'p_namrept');
        r_trepdsph.namrep3   := hcm_util.get_string_t(json_str, 'p_namrep3');
        r_trepdsph.namrep4   := hcm_util.get_string_t(json_str, 'p_namrep4');
        r_trepdsph.namrep5   := hcm_util.get_string_t(json_str, 'p_namrep5');
        json_syncond         := hcm_util.get_json_t(json_str,'p_syncond');
        r_trepdsph.syncond   := hcm_util.get_string_t(json_syncond, 'code');
        r_trepdsph.statement := hcm_util.get_string_t(json_syncond, 'statement');
        json_columns         := hcm_util.get_json_t(json_str, 'p_format_fields');


        if  r_trepdsph.codrep is null or r_trepdsph.codrep = 'TEMP' then
            r_trepdsph.codrep := 'TEMP';
            r_trepdsph.namrepe   := '';
            r_trepdsph.namrept   := '';
            r_trepdsph.namrep3   := '';
            r_trepdsph.namrep4   := '';
            r_trepdsph.namrep5   := '';
        end if;
        insert_trepdsph(r_trepdsph);

        v_column_size := json_columns.get_size;
        for i in 1..v_column_size loop
          array_data_query(i) := null;
        end loop;
        if r_trepdsph.syncond is not null then
          v_where := v_where||'('||r_trepdsph.syncond||') ';
        else
          v_where := '';
        end if;
    --
        v_stmt_main   := ' select tinstruc.codinst '||
                         ' from tinstruc
                           left join tcrsinst on tinstruc.codinst = tcrsinst.codinst
                           left join tinstedu on tinstruc.codinst = tinstedu.codinst
                           left join tinstwex on tinstruc.codinst = tinstwex.codinst
                           '||v_where||'
                           group by tinstruc.codinst
                           order by tinstruc.codinst';
    --===================================================================================================
        delete from trepdspd
        where   codapp = 'HRTR24X'
        and     codrep = p_codrep;

        for i in 1..v_column_size loop
          v_obj_detail_style      := json();
          v_rcnt_style            := v_rcnt_style + 1;
          json_row        := hcm_util.get_json_t(json_columns, to_char(i - 1));
          v_index_field   := hcm_util.get_string_t(json_row,'numseq');
          v_table         := hcm_util.get_string_t(json_row,'codtable');

          begin
            select  column_id,codcolmn,funcdesc,flgchksal,
                    descole,descolt,descol3,descol4,descol5
            into    v_numseq,v_codcolmn,v_funcdesc,v_flgchksal,
                    v_descole,v_descolt,v_descol3,v_descol4,v_descol5
            from    tcoldesc
            where   codtable    = v_table
            and     column_id      = v_index_field;
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
          elsif v_codcolmn like 'COD%' then
            v_obj_detail_style.put('style','code');
            v_alias_column    := v_codcolmn;
          else
            if v_codcolmn = 'STAINST' then
                v_alias_column    := 'get_tlistval_name(''STAINST2'','||v_codcolmn||','||global_v_lang||') as '||v_codcolmn;
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
              if v_alias_column = 'CODINST' then
                v_subquery  := v_subquery||v_comma||v_table||'_temp '||' as '||' ( select codinst '||'<'||v_table||'> '||
                                                                             '   from '||v_table||' '||
                                                                             '   where codinst = ''<codinst>'' ) ';
              else
                  v_subquery  := v_subquery||v_comma||v_table||'_temp '||' as '||' ( select codinst ,'||v_alias_column||'<'||v_table||'> '||
                                                                                 '   from '||v_table||' '||
                                                                                 '   where codinst = ''<codinst>'' ) ';
              end if;

            array_table_name(v_count_table)  := v_table;
          else
              if v_alias_column <> 'CODINST' then
                  v_subquery    := replace(v_subquery,'<'||v_table||'>',v_comma||v_alias_column||'<'||v_table||'>');
              end if;
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
          v_outer_join  := ' full outer join '||array_table_name(i + 1)||'_temp'||' on nvl('||array_table_name(i + 1)||'_temp.codinst'||', '||array_table_name(1)||'_temp.codinst) = '||array_table_name(1)||'_temp.codinst ';
        end loop;

        --- vvv Intregate String vvv ---
        v_stmt_query    := ' with '||v_subquery||v_select||v_str_join;
    --=================================================================================================
        v_cursor_main   := dbms_sql.open_cursor;
        dbms_sql.parse(v_cursor_main,v_stmt_main,dbms_sql.native);
        dbms_sql.define_column(v_cursor_main,1,v_codinst,1000);
        v_dummy := dbms_sql.execute(v_cursor_main);

        v_cursor_query  := dbms_sql.open_cursor;
        v_count         := 0;
        while (dbms_sql.fetch_rows(v_cursor_main) > 0) loop
          v_count := v_count + 1;
          dbms_sql.column_value(v_cursor_main,1,v_codinst);
            v_stmt_replace  := replace(v_stmt_query,'<codinst>',v_codinst);
            dbms_sql.parse(v_cursor_query,v_stmt_replace,dbms_sql.native);
            for i in 1..v_column_size loop
              dbms_sql.define_column(v_cursor_query,i,array_data_query(i),1000);
            end loop;
            v_dummy := dbms_sql.execute(v_cursor_query);

            while (dbms_sql.fetch_rows(v_cursor_query) > 0) loop
              v_rcnt      := v_rcnt + 1;
              obj_data    := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('column_size', v_column_size);
              obj_data.put('codinst', v_codinst);
              for i in 1..v_column_size loop
                dbms_sql.column_value(v_cursor_query,i,array_data_query(i));
                obj_data.put('column'||to_char(i), array_data_query(i));
              end loop;
              obj_row.put(to_char(v_rcnt - 1), obj_data);
            end loop;
        end loop;
        if v_count > 0 then
            json_str_output   := obj_row.to_clob;
        else
            param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TINSTRUC');
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;
      end;
      --
      procedure get_table(json_str_input in clob, json_str_output out clob) as obj_row json;
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
      end;
      --
      procedure gen_style_column (v_objrow in json, v_img varchar2) as
        v_count number;
        v_objdetail json;
        v_style_data trepapp2.style_data%type;
        v_style_column trepapp2.style_column%type;
      begin
             begin
                delete from trepapp2
                where codapp = 'HRTR24X';
             end;

                v_count := v_objrow.count;

                if (v_img = 'Y') then
                          insert into trepapp2 (codapp,keycolumn,style_column,
                          style_data,dtecreate,codcreate)
                          values ('HRTR24X','img',
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
                      values ('HRTR24X',hcm_util.get_string(v_objdetail,'key'),v_style_column,
                      v_style_data,sysdate,global_v_coduser);
                   end;
                end loop;

      end gen_style_column;
      --
      procedure gen_list_fields(json_str_output out clob) as
        obj_row     json_object_t;
        obj_data    json_object_t;
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
        obj_row     := json_object_t();
        for r1 in c1 loop
          obj_data    := json_object_t();
          v_rcnt      := v_rcnt + 1;
          obj_data.put('coderror','200');
          obj_data.put('numseq',to_char(r1.column_id));
          obj_data.put('desc_colmn',r1.desc_colmn);
          obj_data.put('codtable',r1.codtable);
          obj_row.put(to_char(v_rcnt - 1),obj_data);
        end loop;
        json_str_output   := obj_row.to_clob;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end gen_list_fields;
      --
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
      --
            procedure gen_format_fields(json_str_output out clob) is
            obj_row     json_object_t;
            obj_data    json_object_t;
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
                where   codtable = 'TINSTRUC' and column_id in (1,13,14,15,16,17)
                order by column_id;
        begin
            obj_row     := json_object_t();

            for r1 in c1 loop
                v_count_c1 := v_count_c1 + 1;
            end loop;

            if v_count_c1 > 0 then
                for r1 in c1 loop
                  obj_data    := json_object_t();
                  v_rcnt      := v_rcnt + 1;
                  obj_data.put('coderror','200');
                  obj_data.put('numseq', to_char(r1.codcolmn));
                  obj_data.put('desc_colmn', r1.desc_colmn);
                  obj_data.put('codtable', r1.codtable);
                  if  (r1.codcolmn = 1 and r1.codtable = 'TINSTRUC') or
                      (r1.codcolmn = 13 and r1.codtable = 'TINSTRUC' and global_v_lang = '101') or
                      (r1.codcolmn = 14 and r1.codtable = 'TINSTRUC' and global_v_lang = '102') or
                      (r1.codcolmn = 15 and r1.codtable = 'TINSTRUC' and global_v_lang = '103') or
                      (r1.codcolmn = 16 and r1.codtable = 'TINSTRUC' and global_v_lang = '104') or
                      (r1.codcolmn = 17 and r1.codtable = 'TINSTRUC' and global_v_lang = '105') then
                        obj_data.put('default', true);
                  else
                    obj_data.put('default', false);
                  end if;
                  obj_row.put(to_char(v_rcnt - 1), obj_data);
                end loop;
            else
                for r2 in c2 loop
                    if  (r2.codcolmn = 1) or (r2.codcolmn = 13 and global_v_lang = '101') or (r2.codcolmn = 14 and global_v_lang = '102') or
                        (r2.codcolmn = 15 and global_v_lang = '103') or (r2.codcolmn = 16 and global_v_lang = '104') or
                        (r2.codcolmn = 17 and global_v_lang = '105') then
                            obj_data    := json_object_t();
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
            json_str_output   := obj_row.to_clob;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end gen_format_fields;
      --
      procedure get_format_fields(json_str_input in clob,json_str_output out clob) as
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
      --
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
            v_stainst         varchar2(1 char);
            v_codtitle        varchar2(4 char);
            v_namins          varchar2(60 char);
            v_adrcont         varchar2(200 char);
            v_codprovr        varchar2(4 char);
            v_coddistr        varchar2(4 char);
            v_codsubdistr     varchar2(4 char);
            v_desnoffii        varchar2(300 char);
            v_namepos         varchar2(100 char);
            v_numtelc         varchar(25 char);
            v_email           varchar2(50 char);
            v_lineid          varchar2(50 char);
            v_codunit         varchar2(1 char);
            v_amtinchg        number(9,2);
            v_desskill        varchar2(1000 char);
            v_desnote         varchar2(1000 char);
            v_filename        varchar2(60 char);
            v_dteupd          date;
            v_coduser         varchar2(50 char);
            v_namimage        varchar2(30 char);
            v_codempid        varchar2(10 char);
            v_codcomp         varchar2(40 char);
            v_codpos          varchar2(4 char);
            v_desnoffie       varchar2(300 char);
            v_namepose        varchar2(100 char);
        begin

            begin
                select tinstruc.stainst, tinstruc.codtitle, tinstruc.codinst, get_tinstruc_name(tinstruc.codinst,global_v_lang) namins, tinstruc.adrcont, tinstruc.codprovr,
                       tinstruc.coddistr, tinstruc.codsubdistr, tinstruc.desnoffi, tinstruc.namepos,
                       tinstruc.numtelc, tinstruc.email, tinstruc.lineid, tinstruc.codunit, tinstruc.amtinchg,
                       tinstruc.desskill, tinstruc.desnote, tinstruc.filename,tinstruc.namimage,tinstruc.codempid,
                       tinstruc.dteupd, tinstruc.coduser , temploy1.codcomp , temploy1.codpos
                  into v_stainst, v_codtitle, p_codinst, v_namins, v_adrcont, v_codprovr, v_coddistr, v_codsubdistr, v_desnoffii, v_namepos,
                       v_numtelc, v_email, v_lineid, v_codunit, v_amtinchg, v_desskill, v_desnote, v_filename,v_namimage,v_codempid,
                       v_dteupd, v_coduser , v_codcomp , v_codpos
                from tinstruc
                left join temploy1 on tinstruc.codempid = temploy1.codempid
                where codinst = p_codinst;
            exception when no_data_found then
                v_namins          := null;
                v_adrcont         := null;
                v_codprovr        := null;
                v_coddistr        := null;
                v_codsubdistr     := null;
                v_desnoffii        := null;
                v_namepos         := null;
                v_numtelc         := null;
                v_email           := null;
                v_lineid          := null;
                v_codunit         := '1';
                v_amtinchg        := null;
                v_desskill        := null;
                v_desnote         := null;
                v_filename        := null;
                v_namimage        := null;
                v_dteupd          := null;
                v_coduser         := null;
                v_codempid        := null;
                v_codcomp         := null;
                v_codpos          := null;
            end;

            obj_row := json();
            obj_row.put('codinst', p_codinst);
            obj_row.put('namins', v_namins);
            obj_row.put('stainst', v_stainst);
            if v_stainst = 'I' then
                obj_row.put('text_stainst', get_label_name('HRTR24XSEL', global_v_lang, '10'));
            elsif v_stainst = 'E' then
                obj_row.put('text_stainst', get_label_name('HRTR24XSEL', global_v_lang, '20'));
            end if;
            obj_row.put('adrcont', v_adrcont);
            obj_row.put('codprovr', get_tcodec_name('TCODPROV',v_codprovr,global_v_lang));
            obj_row.put('coddistr', get_tcoddist_name(v_coddistr,global_v_lang));
            obj_row.put('codsubdistr', get_tsubdist_name(v_codsubdistr,global_v_lang));
            obj_row.put('desnoffi', v_desnoffii);
            if v_stainst = 'I' then
                obj_row.put('namepos', get_tpostn_name(v_codpos,global_v_lang));
            else
                obj_row.put('namepos', v_namepos);
            end if;

            obj_row.put('numtelc', v_numtelc);
            obj_row.put('email', v_email);
            obj_row.put('lineid', v_lineid);
            obj_row.put('codunit', get_tlistval_name('NTYPCAL',v_codunit,global_v_lang));
            obj_row.put('amtinchg', to_char(nvl(v_amtinchg,''),'fm999,999,990.00'));
            obj_row.put('desskill', v_desskill);
            obj_row.put('desnote', v_desnote);
            obj_row.put('filename', v_filename);
            obj_row.put('namimage', v_namimage);
            obj_row.put('codempid', v_codempid||' - '||get_temploy_name(v_codempid,global_v_lang));
            obj_row.put('department', get_tcenter_name(v_codcomp,global_v_lang));
            obj_row.put('dteupd', v_dteupd);
            obj_row.put('coduser', v_coduser);
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
            obj_data          json;
            v_row             number := 0;
            cursor c1 is
                select codcours, codsubj, instgrd, dtetrlst
                from tcrsinst
                where codinst = p_codinst;
        begin
            obj_row := json();
            for i in c1 loop
                v_row       := v_row + 1;
                obj_data    := json();
                obj_data.put('codcours', i.codcours);
                obj_data.put('namcours', get_tcourse_name(i.codcours,global_v_lang));
                obj_data.put('codsubj', i.codsubj);
                obj_data.put('namsubj', get_tsubject_name(i.codsubj,global_v_lang));
                obj_data.put('instgrd', to_char(i.instgrd,'fm999,999,990.00'));
                obj_data.put('dtetrlst', to_char(i.dtetrlst,'dd/mm/yyyy'));
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
                select codedlv, codmajsb, codinst, codcount
                from teducatn
                where codempid = get_codempid_bycodinst(p_codinst)
                order by codedlv;
            cursor c2 is
                select numseq, codedlv, desmajsb, desinstit, codcnty, desnote
                from tinstedu
                where codinst = p_codinst
                order by codedlv;
        begin
            obj_row := json();

            if p_stainst = 'I' then
                for i in c1 loop
                    v_row       := v_row + 1;
                    obj_data    := json();
                    obj_data.put('desedlv', get_tcodec_name('TCODEDUC',i.codedlv,global_v_lang));
                    obj_data.put('desmajsb', get_tcodec_name('TCODMAJR',i.codmajsb,global_v_lang));
                    obj_data.put('desinstit', get_tcodec_name('TCODINST',i.codinst,global_v_lang));
                    obj_data.put('codcnty', get_tcodec_name('TCODCNTY',i.codcount,global_v_lang));
                    obj_data.put('desnote', '');
                    obj_data.put('coderror', '200');
                    obj_row.put(to_char(v_row-1),obj_data);
                end loop;
            elsif p_stainst = 'E' then
                for i in c2 loop
                    v_row       := v_row + 1;
                    obj_data    := json();
                    obj_data.put('numseq', i.numseq);
                    obj_data.put('desedlv', get_tcodec_name('TCODEDUC',i.codedlv,global_v_lang));
                    obj_data.put('desmajsb', i.desmajsb);
                    obj_data.put('desinstit', i.desinstit);
                    obj_data.put('codcnty', get_tcodec_name('TCODCNTY',i.codcnty,global_v_lang));
                    obj_data.put('desnote', i.desnote);
                    obj_data.put('coderror', '200');
                    obj_row.put(to_char(v_row-1),obj_data);
                end loop;
            end if;
            if isInsertReport then
                insert_ttemprpt(obj_row);
            end if;
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end gen_tab3_detail;

        procedure get_tab4_detail(json_str_input in clob, json_str_output out clob) as
        begin
          initial_value(json_str_input);
          if param_msg_error is null then
            gen_tab4_detail(json_str_output);
          end if;
          if param_msg_error is not null then
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
          end if;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end get_tab4_detail;

        procedure gen_tab4_detail(json_str_output out clob) as
            obj_row           json;
            obj_data          json;
            v_row             number := 0;
            cursor c1 is
                select desc_codcomp, desc_codpos, desc_codjob, dteempmt, dteeffex
                from (select  get_tcenter_name(codcomp, global_v_lang) desc_codcomp,
                              get_tpostn_name(codpos, global_v_lang) desc_codpos,
                              get_tjobcode_name(codjob, global_v_lang) desc_codjob,
                              dteefpos dteempmt, null dteeffex
                      from    temploy1
                      where   codempid = p_codempid
                      union
                      select  get_tcenter_name(codcomp, global_v_lang) desc_codcomp,
                              get_tpostn_name(codpos, global_v_lang) desc_codpos,
                              get_tjobcode_name(codjob, global_v_lang) desc_codjob,
                              dteefpos dteempmt, null dteeffex
                      from    ttmovemt
                      where   codempid = p_codempid
                      and     (codcomp <> codcompt or codpos <> codposnow or codjob <> codjobt)
                      and     staupd in ('C', 'U') and dteeffec <= trunc(sysdate)
                      union
                      select  desnoffi desc_codcomp, deslstpos desc_codpos, deslstjob1 desc_codjob, dtestart dteempmt, dteend dteeffex
                      from    tapplwex
                      where   codempid = p_codempid)
                order by dteempmt;
            cursor c2 is
                select numseq, desnoffi desc_codcomp, namepos desc_codpos, desjob desc_codjob, dtestart dteempmt, dteend dteeffex
                from tinstwex
                where codinst = p_codinst
                order by dteempmt;
        begin
            obj_row := json();

            if p_stainst = 'I' then
                for i in c1 loop
                    v_row       := v_row + 1;
                    obj_data    := json();
                    obj_data.put('desc_codcomp', i.desc_codcomp);
                    obj_data.put('desc_codpos', i.desc_codpos);
                    obj_data.put('desc_codjob', i.desc_codjob);
                    obj_data.put('dteempmt', to_char(i.dteempmt, 'dd/mm/yyyy'));
                    obj_data.put('dteeffex', to_char(i.dteeffex, 'dd/mm/yyyy'));
                    obj_data.put('coderror', '200');
                    obj_row.put(to_char(v_row-1),obj_data);
                end loop;
            elsif p_stainst = 'E' then
                for i in c2 loop
                    v_row       := v_row + 1;
                    obj_data    := json();
                    obj_data.put('numseq', i.numseq);
                    obj_data.put('desc_codcomp', i.desc_codcomp);
                    obj_data.put('desc_codpos', i.desc_codpos);
                    obj_data.put('desc_codjob', i.desc_codjob);
                    obj_data.put('dteempmt', to_char(i.dteempmt, 'dd/mm/yyyy'));
                    obj_data.put('dteeffex', to_char(i.dteeffex, 'dd/mm/yyyy'));
                    obj_data.put('coderror', '200');
                    obj_row.put(to_char(v_row-1),obj_data);
                end loop;
            end if;
            if isInsertReport then
                insert_ttemprpt(obj_row);
            end if;
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end gen_tab4_detail;
        function get_codempid_bycodinst(p_codinst VARCHAR2) return varchar2 is
            v_codempid      varchar2(10 char);
        begin
            begin
                select codempid
                into   v_codempid
                from   tinstruc
                where  codinst  = p_codinst;
            exception when no_data_found then
                v_codempid := null;
            end;
            return v_codempid;
        end get_codempid_bycodinst;

        function get_tinstruc_stainst(p_codinst VARCHAR2) return varchar2 is
            v_stainst      varchar2(1 char);
        begin
            begin
                select stainst
                into   v_stainst
                from   tinstruc
                where  codinst  = p_codinst;
            exception when no_data_found then
                v_stainst := null;
            end;
            return v_stainst;
        end get_tinstruc_stainst;

        procedure delete_codrep (json_str_input in clob, json_str_output out clob) as
            json_str        json_object_t;
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

        procedure initial_report(json_str in clob) is
            json_obj        json;
        begin
            json_obj            := json(json_str);
            global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
            global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
            global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

            json_codinst       := hcm_util.get_json(json_obj, 'p_codinst');

        end initial_report;

        procedure gen_report(json_str_input in clob,json_str_output out clob) is
            json_output       clob;
        begin
            initial_report(json_str_input);
            isInsertReport := true;
            if param_msg_error is null then
              clear_ttemprpt;
              for i in 0..json_codinst.count-1 loop
                p_codinst   := hcm_util.get_string(json_codinst, to_char(i));
                p_stainst   := get_tinstruc_stainst(p_codinst);
                p_codempid  := get_codempid_bycodinst(p_codinst);
                p_codapp            := 'HRTR24X1';
                gen_tab1_detail(json_output);
                p_codapp            := 'HRTR24X2';
                gen_tab2_detail(json_output);
                p_codapp            := 'HRTR24X3';
                gen_tab3_detail(json_output);
                p_codapp            := 'HRTR24X4';
                gen_tab4_detail(json_output);
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
                 and codapp IN ('HRTR24X1', 'HRTR24X2','HRTR24X3','HRTR24X4');
            exception when others then
              null;
            end;
        end clear_ttemprpt;

         procedure insert_ttemprpt(obj_data in json) is
            v_numseq            number := 0;
            v_naminst           varchar2(80 char);
        begin
            if p_codapp = 'HRTR24X1' then

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

                if hcm_util.get_string(obj_data, 'stainst') = 'I' then
                    v_naminst := hcm_util.get_string(obj_data, 'codempid');
                elsif hcm_util.get_string(obj_data, 'stainst') = 'E' then
                    v_naminst := hcm_util.get_string(obj_data, 'namins');
                end if;

                begin
                  insert
                    into ttemprpt
                       (
                         codempid, codapp, numseq,
                         item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12, item13, item14, item15 , item16 , item17 , item18, item19, item20
                       )
                  values
                       (
                         global_v_codempid, p_codapp, v_numseq,
                         p_codinst,
                         nvl(v_naminst, ''),
                         nvl(hcm_util.get_string(obj_data, 'stainst'), ''),
                         nvl(hcm_util.get_string(obj_data, 'namepos'), ''),
                         nvl(hcm_util.get_string(obj_data, 'department'), ''),
                         nvl(hcm_util.get_string(obj_data, 'adrcont'), ''), nvl(hcm_util.get_string(obj_data, 'lineid'), ''),
                         nvl(hcm_util.get_string(obj_data, 'codsubdistr'), ''), nvl(hcm_util.get_string(obj_data, 'codunit'), ''),
                         nvl(hcm_util.get_string(obj_data, 'coddistr'), ''), nvl(hcm_util.get_string(obj_data, 'amtinchg'), ''),
                         nvl(hcm_util.get_string(obj_data, 'codprovr'), ''), nvl(hcm_util.get_string(obj_data, 'desskill'), ''),
                         nvl(hcm_util.get_string(obj_data, 'desnoffi'), ''), nvl(hcm_util.get_string(obj_data, 'desnote'), ''),
                         nvl(hcm_util.get_string(obj_data, 'namepos'), ''), nvl(hcm_util.get_string(obj_data, 'filename'), ''),
                         nvl(hcm_util.get_string(obj_data, 'numtelc'), ''),
                         nvl(hcm_util.get_string(obj_data, 'email'),''),
                         nvl(hcm_util.get_string(obj_data, 'text_stainst'),'')
                       );
                exception when others then
                  null;
                end;
            elsif p_codapp = 'HRTR24X2' then
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
                             codempid, codapp, numseq,
                             item1, item2, item3, item4 , item5, item6, item7, item8
                           )
                      values
                           (
                             global_v_codempid, p_codapp, v_numseq,
                             p_codinst,
                             nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codcours'), ''),
                             nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'namcours'), ''),
                             nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codsubj'), ''),
                             nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'namsubj'), ''),
                             nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'instgrd'), ''),
                             replace(get_date_input(nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'dtetrlst'), '')),'//',''),
                             to_char(i+1)
                           );
                    exception when others then
                      null;
                    end;
                end loop;
            elsif p_codapp = 'HRTR24X3' then
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
                                 codempid, codapp, numseq, item1, item2, item3, item4 , item5, item6, item7
                               )
                          values
                               (
                                 global_v_codempid, p_codapp, v_numseq,
                                 p_codinst,
                                 nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'desedlv'), ''),
                                 nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'desmajsb'), ''),
                                 nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'desinstit'), ''),
                                 nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codcnty'), ''),
                                 nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'desnote'), ''),
                                 to_char(i+1)
                               );
                    exception when others then
                      null;
                    end;
                end loop;
             elsif p_codapp = 'HRTR24X4' then
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
                                 codempid, codapp, numseq, item1, item2, item3, item4 , item5 , item6, item7
                               )
                          values
                               (
                                 global_v_codempid, p_codapp, v_numseq,
                                 p_codinst,
                                 nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'desc_codcomp'), ''),
                                 nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'desc_codpos'), ''),
                                 nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'desc_codjob'), ''),
                                 replace(get_date_input(nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'dteempmt'), '')),'//',''),
                                 replace(get_date_input(nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'dteeffex'), '')),'//',''),
                                 to_char(i+1)
                                   );
                    exception when others then
                      null;
                    end;
                end loop;
            end if;

        end insert_ttemprpt;

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

END HRTR24X;


/

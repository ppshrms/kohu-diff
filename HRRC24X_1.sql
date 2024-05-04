--------------------------------------------------------
--  DDL for Package Body HRRC24X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC24X" is
-- last update: 24/11/2020 18:30
 procedure initial_value(json_str_input in clob) as
    json_obj          json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_chken        := '';
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codrep            := hcm_util.get_string_t(json_obj,'p_codrep');
    p_dtestrt           := hcm_util.get_string_t(json_obj,'p_dtestrt');
    p_dteend            := hcm_util.get_string_t(json_obj,'p_dteend');

    p_table_selected    := hcm_util.get_string_t(json_obj,'p_table_selected');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure gen_codrep_detail(json_str_output out clob) as
    obj_row         json_object_t;
    cursor c_trepdsph is
      select  codrep,
              decode(global_v_lang  , '101',namrepe,
                                      '102',namrept,
                                      '103',namrep3,
                                      '104',namrep4,
                                      '105',namrep5,namrept) namrep,
              namrepe,namrept,namrep3,namrep4,namrep5,
              syncond,statement
      from    trepdsph
      where   codrep  = p_codrep
      and     codapp  = 'HRRC24X';

  begin
    obj_row     := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codrep', p_codrep);
    for trep in c_trepdsph loop
      obj_row.put('code', trep.syncond);
      obj_row.put('description', get_logical_name('HRRC24X',trep.syncond,global_v_lang));
      obj_row.put('statement', trep.statement);
      obj_row.put('condition', p_codrep);
    end loop;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_codrep_detail(json_str_input in clob, json_str_output out clob) as
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
                            syncond,codcreate,coduser,statement)
             values  (p_codapp,p_r_trepdsph.codrep,
                      p_r_trepdsph.syncond,global_v_coduser,global_v_coduser,p_r_trepdsph.statement);
    exception when dup_val_on_index then
      update  trepdsph
      set     syncond     = p_r_trepdsph.syncond,
              statement   = p_r_trepdsph.statement,
              coduser     = global_v_coduser
      where   codapp      = p_codapp
      and     codrep      = p_r_trepdsph.codrep;
    end;
  end;
  --
  procedure gen_detail(json_str_input in clob,json_str_output out clob) as
    v_stmt_main     clob;
    v_stmt_query    clob;

    v_where         varchar2(4000)  := ' where ';
    v_alias_column  varchar2(1000);

    v_cursor_main   number;
    v_cursor_query  number;
    v_rcnt          number  := 0;
    v_rcnt_style    number  := 0;
    v_last_record   number  := 0;
    v_max_record    number  := 0;
    v_column_size   number  := 0;
    v_dummy         integer;
    v_zupdsal       varchar2(1);
    v_dtecalculate  varchar2(1000);
    v_data_exec     varchar2(2000);

    json_str        json_object_t;
    json_columns    json_object_t;
    json_row        json_object_t;
    json_syncond    json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_obj_detail_style        json_object_t;
    v_obj_detail_style_row    json_object_t;

    v_index_field   treport.numseq%type;
    v_table         treport.codtable%type;

    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_numlvl        varchar2(100);
    v_numappl       temploy1.numappl%type;

    r_trepdsph      trepdsph%rowtype;
    v_join          varchar2(4000 char) := 'tapplinf';
    type t_treport is table of treport%rowtype index by binary_integer;
      v_treport     t_treport;
    type t_column is table of varchar2(2000) index by binary_integer;
    type t_row is record(
      data_n    t_column,
      table_n   t_column
    );
    type t_table_data is table of t_row index by binary_integer;
      v_table_data   t_table_data;
    cursor c_report2 is
      select  distinct namtbl
      from    treport2
      where   codapp    = 'HRRC24X';
    cursor c_chk_sal is
      select distinct namtbl||'.'||rp2.namfld as colmn
        from treport2 rp2, tcoldesc cd
       where rp2.codapp   = 'HRRC24X'
         and rp2.namtbl   = cd.codtable
         and rp2.namfld   = cd.codcolmn
         and cd.flgchksal = 'Y';
  begin
    obj_row                 := json_object_t();
    v_obj_detail_style_row  := json_object_t();
    json_str             := json_object_t(json_str_input);
    r_trepdsph.codrep    := hcm_util.get_string_t(json_str, 'p_codrep');
    json_syncond         := hcm_util.get_json_t(json_str,'p_syncond');
    r_trepdsph.syncond   := hcm_util.get_string_t(json_syncond, 'code');
    r_trepdsph.statement := hcm_util.get_string_t(json_syncond, 'statement');
    json_columns         := hcm_util.get_json_t(json_str, 'p_format_fields');
    v_dtecalculate       := nvl(v_dtecalculate,to_char(sysdate,'dd/mm/yyyy'));
    if r_trepdsph.codrep is not null then
      insert_trepdsph(r_trepdsph);
    end if;
    numYearReport   := HCM_APPSETTINGS.get_additional_year();
    v_column_size := json_columns.get_size;
    ---------------------------------------------
    delete from trepdspd where   codapp = 'HRRC24X' and codrep = p_codrep ;
    ---------------------------------------------
    for i in 1..v_column_size loop
      v_obj_detail_style      := json_object_t();
      v_rcnt_style            := v_rcnt_style + 1;
      json_row                := hcm_util.get_json_t(json_columns, to_char(i - 1));
      v_index_field           := hcm_util.get_string_t(json_row,'numseq');
      v_table                 := hcm_util.get_string_t(json_row,'codtable');

      begin
        select  numseq,codcolmn,codsearch,funcdesc,flgchksal,
                descole,descolt,descol3,descol4,descol5,
                codtable
        into    v_treport(i).numseq,v_treport(i).codcolmn,v_treport(i).codsearch,v_treport(i).funcdesc,v_treport(i).flgchksal,
                v_treport(i).descole,v_treport(i).descolt,v_treport(i).descol3,v_treport(i).descol4,v_treport(i).descol5,
                v_treport(i).codtable
        from    treport
        where   codtable    = v_table
        and     numseq      = v_index_field;
      exception when no_data_found then
        v_treport(i).numseq      := null;
        v_treport(i).codcolmn    := null;
        v_treport(i).codsearch   := null;
        v_treport(i).funcdesc    := null;
        v_treport(i).flgchksal   := null;
        v_treport(i).descole     := null;
        v_treport(i).descolt     := null;
        v_treport(i).descol3     := null;
        v_treport(i).descol4     := null;
        v_treport(i).descol5     := null;
      end;

      if r_trepdsph.codrep is not null then
        insert into trepdspd(codapp,codrep,numseq,codtable,codcolmn,descolmn,
                             codsearch,funcdesc,flgchksal,
                             codcreate,coduser)
                     values ('HRRC24X',p_codrep,i,v_treport(i).codtable,v_treport(i).numseq,
                             decode(global_v_lang,'101',v_treport(i).descole
                                                 ,'102',v_treport(i).descolt
                                                 ,'103',v_treport(i).descol3
                                                 ,'104',v_treport(i).descol4
                                                 ,'105',v_treport(i).descol5),
                             v_treport(i).codsearch,v_treport(i).funcdesc,v_treport(i).flgchksal,
                             global_v_coduser,global_v_coduser);
      end if;
      v_obj_detail_style.put('key', v_treport(i).codcolmn);

      if v_treport(i).codcolmn like 'DTEEMP%' then
        v_obj_detail_style.put('style','date');
      elsif v_treport(i).codcolmn like 'DTE%' then
        v_obj_detail_style.put('style','date');
      elsif v_treport(i).funcdesc is not null and v_treport(i).funcdesc not like 'SUBSTR(CODCOMP%' then
        v_obj_detail_style.put('style','text');
      elsif v_treport(i).codcolmn like 'AMT%' then
        v_obj_detail_style.put('style','number-right');
      elsif v_treport(i).codcolmn like 'COD%' then
        v_obj_detail_style.put('style','code');
      else
        v_obj_detail_style.put('style',get_item_property(v_treport(i).codtable,v_treport(i).codcolmn));
      end if;
      v_obj_detail_style_row.put(to_char(v_rcnt_style - 1),v_obj_detail_style);
    end loop;
--===========================================================================================
    if r_trepdsph.syncond is not null then
      for r_treport2 in c_report2 loop
        if instr(r_trepdsph.syncond,r_treport2.namtbl) > 0 then
          if upper(r_treport2.namtbl) = 'TAPPLINF' then
            null;
          elsif upper(r_treport2.namtbl) in (/*'TAPPLINF',*/'TCMPTNCY','TAPPLREF','TAPPLWEX','TEDUCATN') then
            v_join  := v_join||' join '||r_treport2.namtbl||' on '||r_treport2.namtbl||'.numappl = temploy1.numappl ';
--          elsif upper(r_treport2.namtbl) <> 'TEMPLOY1' then
--            v_join  := v_join||' join '||r_treport2.namtbl||' on '||r_treport2.namtbl||'.codempid = temploy1.codempid ';
          end if;
        end if;
      end loop;
--      v_join  := v_join||' join tapplinf on tapplinf.numappl = temploy1.numappl ';
      v_where := v_where ||'dteappl between to_date(''' || p_dtestrt || ''',''dd/mm/yyyy'') and to_date(''' || p_dteend || ''',''dd/mm/yyyy'') and ' ||' ('||r_trepdsph.syncond||') ';
      for r_chk_sal in c_chk_sal loop
        if instr(r_trepdsph.syncond,r_chk_sal.colmn) > 0 then
          v_where   := replace(v_where,r_chk_sal.colmn,'stddec('||r_chk_sal.colmn||',tapplinf.codempid,'||global_v_chken||')');
        end if;
      end loop;
      if v_where like '%AGEEMP%' then
        v_where := replace(v_where,'TAPPLINF.AGEEMP','TRUNC( MONTHS_BETWEEN(SYSDATE,TAPPLINF.DTEEMPDB)/12)');
      end if;
--      if v_where like '%AGEEMPMT%' then
--        v_where := replace(v_where,'TEMPLOY1.AGEEMPMT','TRUNC( MONTHS_BETWEEN(NVL(TEMPLOY1.DTEEFFEX,SYSDATE),TEMPLOY1.DTEEMPMT))');
--      elsif v_where like '%AGEEMP%' then
--        v_where := replace(v_where,'TEMPLOY1.AGEEMP','TRUNC( MONTHS_BETWEEN(SYSDATE,TEMPLOY1.DTEEMPDB)/12)');
--      elsif v_where like '%AGELEVEL%' then
--        v_where := replace(v_where,'TEMPLOY1.AGELEVEL','TRUNC( MONTHS_BETWEEN(NVL(TEMPLOY1.DTEEFFEX,SYSDATE),TEMPLOY1.DTEEFLVL))');
--      elsif v_where like '%AGEPOS%' then
--        v_where := replace(v_where,'TEMPLOY1.AGEPOS','TRUNC( MONTHS_BETWEEN(NVL(TEMPLOY1.DTEEFFEX,SYSDATE),TEMPLOY1.DTEEFPOS))');
--      elsif v_where like '%AGEJOBGRADE%' then
--        v_where := replace(v_where,'TEMPLOY1.AGEJOBGRADE','TRUNC( MONTHS_BETWEEN(NVL(TEMPLOY1.DTEEFFEX,SYSDATE),TEMPLOY1.DTEEFSTEP))');
--      end if;

    end if;
    if r_trepdsph.syncond is null then
--       v_join  := v_join||' join tapplinf on tapplinf.numappl = temploy1.numappl ';
       v_where := v_where ||'dteappl between to_date(''' || p_dtestrt || ''',''dd/mm/yyyy'') and to_date(''' || p_dteend || ''',''dd/mm/yyyy'')';
--       v_where := v_where ||'nvl(dteappl,'||p_dtestrt||')'||' between to_date(''' || p_dtestrt || ''',''dd/mm/yyyy'') and to_date(''' || p_dteend || ''',''dd/mm/yyyy'')';
    end if;

--    v_stmt_main   := ' select temploy1.codempid,temploy1.codcomp,temploy1.numappl,temploy1.numlvl '||
--                     ' from '||v_join||v_where||
--                     ' order by temploy1.codcomp,temploy1.codempid,temploy1.numappl,temploy1.numlvl';
    v_stmt_main   := ' select null codempid,null codcomp,tapplinf.numappl,null numlvl '||
                     ' from '||v_join||v_where||
                     ' order by tapplinf.numappl';
--TAPPLINF
--TCMPTNCY
--TAPPLREF
--TAPPLWEX
--TEDUCATN
--
--TTRAINBF
--TAPPLCH
--TAPPLDOC
--TAPPLREF
    /*v_stmt_main := --'select count(tapplinf.numappl) '||
                   '  from tapplinf, tapplfm, teducatn, tapplref, tapplwex, tcmptncy '||
                   ' where  dteappl between to_date(''' || p_dtestrt || ''',''dd/mm/yyyy'') and to_date(''' || p_dteend || ''',''dd/mm/yyyy'')
                   '   and tapplinf.numappl = tapplfm.numappl(+) '||
                   '   and tapplinf.numappl = teducatn.numappl(+) '||
                   '   and tapplinf.numappl = tapplref.numappl(+) '||
                   '   and tapplinf.numappl = tapplwex.numappl(+) '||
                   '   and tapplinf.numappl = tcmptncy.numappl(+) '||v_syncond;*/
--===================================================================================================
    v_cursor_main   := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor_main,v_stmt_main,dbms_sql.native);
    dbms_sql.define_column(v_cursor_main,1,v_codempid,1000);
    dbms_sql.define_column(v_cursor_main,2,v_codcomp,1000);
    dbms_sql.define_column(v_cursor_main,3,v_numappl,1000);
    dbms_sql.define_column(v_cursor_main,4,v_numlvl,1000);
    v_dummy := dbms_sql.execute(v_cursor_main);

    v_cursor_query  := dbms_sql.open_cursor;
    while (dbms_sql.fetch_rows(v_cursor_main) > 0) loop
      dbms_sql.column_value(v_cursor_main,1,v_codempid);
      dbms_sql.column_value(v_cursor_main,2,v_codcomp);
      dbms_sql.column_value(v_cursor_main,3,v_numappl);
      dbms_sql.column_value(v_cursor_main,4,v_numlvl);

        for i in 1..v_column_size loop
          --- vvv Define Column vvv ---
          if v_treport(i).flgchksal = 'Y' then
            v_alias_column := 'decode('''||v_zupdsal||''',''Y'',to_char(stddec('||v_treport(i).codtable||'.'||v_treport(i).codcolmn||','''||v_codempid||''','''||global_v_chken||'''),''fm999,999,990.00'')) as '||v_treport(i).codcolmn;
          elsif v_treport(i).codsearch is not null then
            v_alias_column    := replace(v_treport(i).funcdesc,'P_CODE',v_treport(i).codtable||'.'||v_treport(i).codsearch)||' as '||v_treport(i).codcolmn;
            v_alias_column    := replace(v_alias_column,'P_LANG',global_v_lang);
          elsif v_treport(i).codcolmn like 'DTEEMP%' then
            v_alias_column    := 'get_age('||v_treport(i).codtable||'.'||v_treport(i).codcolmn||',to_date('''||v_dtecalculate||''',''dd/mm/yyyy'') as '||v_treport(i).codcolmn;

          elsif v_treport(i).codcolmn like 'DTE%' then
            v_alias_column    := 'to_char('||v_treport(i).codtable||'.'||v_treport(i).codcolmn||',''dd/mm/yyyy'') as '||v_treport(i).codcolmn;
          else
            v_alias_column    := v_treport(i).codtable||'.'||v_treport(i).codcolmn;
          end if;

          if  v_treport(i).codtable not in ('TAPPLINF','TAPPLDOC','TEDUCATN','TAPPLWEX','TTRAINBF','TAPPLOTH','TAPPLFM','TAPPLREL','TAPPLREF','TCMPTNCY','TLANGABI','TAPPLCH') then
            v_stmt_query  := ' select '||v_alias_column||
                             ' from '||v_treport(i).codtable||' '||
                             ' where codempid = '''||v_codempid||''' ';
          else
            v_stmt_query  := ' select '||v_alias_column||
                             ' from '||v_treport(i).codtable||' '||
                             ' where numappl = '''||v_numappl||''' ';
          end if;     
          dbms_sql.parse(v_cursor_query,v_stmt_query,dbms_sql.native);
          dbms_sql.define_column(v_cursor_query,1,v_data_exec,2000);
          v_dummy     := dbms_sql.execute(v_cursor_query);
          v_rcnt      := v_last_record;
          while (dbms_sql.fetch_rows(v_cursor_query) > 0) loop
            v_rcnt      := v_rcnt + 1;
            dbms_sql.column_value(v_cursor_query,1,v_data_exec);
            if v_treport(i).codcolmn like 'DTE%' then
              if v_data_exec is not null and global_v_lang is not null then
                begin
                  v_data_exec :=  to_char(add_months(to_date(v_data_exec,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy');
                exception when others then null;
                end;
              end if;
            end if;
            v_table_data(v_rcnt).data_n(i)  := v_data_exec;
            v_table_data(v_rcnt).table_n(i)  := v_treport(i).codtable;
          end loop;
          v_max_record  := greatest(v_max_record,v_rcnt);
        end loop;
        v_last_record := v_max_record;
    end loop;

    if v_rcnt = 0 then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPLINF');
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
         return;
    end if;

    for r_table_data in 1..v_table_data.count loop
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('column_size', v_column_size);
      for i in 1..v_column_size loop
        begin
          obj_data.put('column'||to_char(i), v_table_data(r_table_data).data_n(i));
        exception when no_data_found then
          begin
            if v_table_data(r_table_data - 1).table_n(i) = 'TEMPLOY1' then
              obj_data.put('column'||to_char(i), v_table_data(r_table_data - 1).data_n(i));
              v_table_data(r_table_data).data_n(i)    := v_table_data(r_table_data - 1).data_n(i);
              v_table_data(r_table_data).table_n(i)   := v_table_data(r_table_data - 1).table_n(i);
            else
              obj_data.put('column'||to_char(i), '');
              v_table_data(r_table_data).data_n(i)    := '';
              v_table_data(r_table_data).table_n(i)   := v_table_data(r_table_data - 1).table_n(i);
            end if;
          exception when no_data_found then
            null;
          end;
        end;
      end loop;
      obj_row.put(to_char(r_table_data - 1), obj_data);
    end loop;
    commit;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_input, json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end;
----------------------------------------------------------------------------------
procedure gen_list_fields(json_str_output out clob) as
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_rcnt      number  := 0;
    cursor c1 is
      select  numseq,
              decode(global_v_lang,'101',descole,
                                   '102',descolt,
                                   '103',descol3,
                                   '104',descol4,
                                   '105',descol5) desc_colmn,
              codtable
      from    treport
      where   codtable = p_table_selected
      order by numseq;
  begin
    obj_row        := json_object_t();
    for r1 in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('numseq',r1.numseq);
      obj_data.put('desc_colmn',r1.desc_colmn);
      obj_data.put('codtable',r1.codtable);
      obj_row.put(to_char(v_rcnt - 1),obj_data);
    end loop;
    json_str_output   := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_list_fields;
----------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------
  procedure gen_dropdown_list(json_str_output out clob) as
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_rcnt      number  := 0;
    cursor c1 is
      select * from tlistval
      where codapp = p_codapp
      and codlang = global_v_lang
      and numseq > 0 order by numseq;
  begin
    obj_row        := json_object_t();
    for r1 in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('namtable',r1.desc_label);
      obj_data.put('codtable',r1.list_value);
      obj_row.put(to_char(v_rcnt - 1),obj_data);
    end loop;
    json_str_output   := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_dropdown_list;
----------------------------------------------------------------------------------
  procedure get_dropdown_list(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_dropdown_list(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
----------------------------------------------------------------------------------
  procedure gen_format_fields(json_str_output out clob) is
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_rcnt      number  := 0;
    cursor c1 is
      select  t1.codcolmn,
              t1.descolmn as desc_colmn,
              t1.codtable
      from    trepdspd t1
      where   t1.codapp     = 'HRRC24X'
      and     t1.codrep     = p_codrep
      order by t1.numseq;
  begin
    obj_row     := json_object_t();
    for r1 in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('numseq',r1.codcolmn);
      obj_data.put('desc_colmn',r1.desc_colmn);
      obj_data.put('codtable',r1.codtable);
      obj_row.put(to_char(v_rcnt - 1),obj_data);
    end loop;
    json_str_output   := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
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
----------------------------------------------------------------------------------
  function  get_item_property (p_table in VARCHAR2,p_field  in VARCHAR2)    return varchar2 is
    v_data_type   user_tab_columns.data_type%type;
  begin
    begin
      select  t.data_type as datatype
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
----------------------------------------------------------------------------------

end HRRC24X;

/

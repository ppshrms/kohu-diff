--------------------------------------------------------
--  DDL for Package Body HRPMA1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMA1X" is
/* Cust-Modify: KOHU-HE2301 */
-- last update: 17/04/2024 09:51 
--ST11 redmine649/SEA-HR2201||03/02/2023||17:16
  procedure initial_value(json_str_input in clob) as
    json_obj          json_object_t;
    v_codleave        json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_chken        := '';
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_comgrp            := hcm_util.get_string_t(json_obj,'p_comgrp');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codrep            := hcm_util.get_string_t(json_obj,'p_codrep');
    p_staemp            := hcm_util.get_string_t(json_obj,'p_staemp');

    p_showimg           := hcm_util.get_string_t(json_obj,'p_showimg');

    p_table_selected    := hcm_util.get_string_t(json_obj,'p_table_selected');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure gen_codrep_detail(json_str_output out clob) as
    obj_row         json_object_t;
    obj_syncond     json_object_t;
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
      and     codapp  = 'HRPMA1X';

  begin
    obj_row     := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codrep', p_codrep);
    for trep in c_trepdsph loop
      obj_row.put('namrep', trep.namrep);
      obj_row.put('namrepe', trep.namrepe);
      obj_row.put('namrept', trep.namrept);
      obj_row.put('namrep3', trep.namrep3);
      obj_row.put('namrep4', trep.namrep4);
      obj_row.put('namrep5', trep.namrep5);
      --
      obj_syncond   := json_object_t();
      obj_syncond.put('code', trep.syncond);
      obj_syncond.put('description', get_logical_name('HRPMA1X',trep.syncond,global_v_lang));
      --obj_syncond.put('statement', trep.statement);

      if trep.syncond is not null then
        obj_syncond.put('statement', trep.statement);
      else
        obj_syncond.put('statement', '[]');
      end if;

      --
      obj_row.put('syncond', obj_syncond);
      obj_row.put('statement', trep.statement);
    end loop;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_codrep_detail(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
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
  --
  procedure gen_style_column (v_objrow in json_object_t, v_img varchar2) as
    v_count           number;
    v_objdetail       json_object_t;
    v_style_data      trepapp2.style_data%type;
    v_style_column    trepapp2.style_column%type;
    v_type_column     varchar2(100);
    v_column          varchar2(100);
  begin
    begin
      delete from trepapp2
      where codapp = 'HRPMA1X';
    end;

    v_count := v_objrow.get_size;

    if (v_img = 'Y') then
      insert into trepapp2 (codapp,keycolumn,style_column,
                            style_data,dtecreate,codcreate)
                    values ('HRPMA1X','image','text-align: center; width: 35px; height: 15px; vertical-align: middle;',
                            'text-align: center;',sysdate,global_v_coduser);
      insert into trepapp2 (codapp,keycolumn,style_column,
                            style_data,dtecreate,codcreate)
                    values ('HRPMA1X','logo_image','text-align: center; width: 35px; height: 15px; vertical-align: middle;',
                            '',sysdate,global_v_coduser);
    end if;
    for i in 1..v_count loop
      v_objdetail     := hcm_util.get_json_t(v_objrow, to_char(i - 1));
      v_type_column   := hcm_util.get_string_t(v_objdetail,'style');
      if (v_type_column = 'text') then
        v_style_data    := 'text-align: left;';
        v_style_column  := 'text-align: left; vertical-align: middle; width: 120px;';
      elsif (v_type_column = 'date') then
        v_style_data    := 'text-align: center;';
        v_style_column  := 'text-align: center; vertical-align: middle; width: 70px;';
      elsif (v_type_column = 'code') then
        v_style_data    := 'text-align: center;';
        v_style_column  := 'text-align: center; vertical-align: middle; width: 100px;';
      elsif (v_type_column = 'number-right') then
        v_style_data    := 'text-align: right;';
        v_style_column  := 'text-align: center; vertical-align: middle; width: 70px;';
      elsif (v_type_column = 'number-center') then
        v_style_data    := 'text-align: center;';
        v_style_column  := 'text-align: center; vertical-align: middle; width: 70px;';
      else
        v_style_data    := 'text-align: left;';
        v_style_column  := 'text-align: left; vertical-align: middle; width: 100px;';
      end if;

--      v_column  := lower(hcm_util.get_string_t(v_objdetail,'key'));
      v_column  := 'column'||to_char(i);
      begin
        insert into trepapp2 (codapp,keycolumn,style_column,
                              style_data,dtecreate,codcreate)
                      values ('hrpma1x',v_column,v_style_column,
                              v_style_data,sysdate,global_v_coduser);
      end;
    end loop;

  end gen_style_column;
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
    v_n_codempid    number  := 0;
    v_dummy         integer;
    flgpass         boolean;
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

    --<<User37 #7108 11/10/2021 
    v_chktempconst  varchar2(1) := 'N';
    v_dteeffec      varchar2(1000);
    v_numitem       varchar2(1000);
    v_dteconst      varchar2(1000);
    v_codcompy      varchar2(1000);
    -->>User37 #7108 11/10/2021 

    v_join          varchar2(4000 char) := 'temploy1';
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
      where   codapp    = 'HRPMA1X';
    cursor c_chk_sal is
      select distinct namtbl||'.'||rp2.namfld as colmn
        from treport2 rp2, tcoldesc cd
       where rp2.codapp   = 'HRPMA1X'
         and rp2.namtbl   = cd.codtable
         and rp2.namfld   = cd.codcolmn
         and cd.flgchksal = 'Y';

  begin
    obj_row                 := json_object_t();
    v_obj_detail_style_row  := json_object_t();
    json_str             := json_object_t(json_str_input);
    r_trepdsph.codrep    := hcm_util.get_string_t(json_str, 'p_codrep');
    r_trepdsph.namrepe   := hcm_util.get_string_t(json_str, 'p_namrepe');
    r_trepdsph.namrept   := hcm_util.get_string_t(json_str, 'p_namrept');
    r_trepdsph.namrep3   := hcm_util.get_string_t(json_str, 'p_namrep3');
    r_trepdsph.namrep4   := hcm_util.get_string_t(json_str, 'p_namrep4');
    r_trepdsph.namrep5   := hcm_util.get_string_t(json_str, 'p_namrep5');
    r_trepdsph.namrep5   := hcm_util.get_string_t(json_str, 'p_namrep5');
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
    delete from trepdspd
    where   codapp = 'HRPMA1X'
    and     codrep = p_codrep;

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
                     values ('HRPMA1X',p_codrep,i,v_treport(i).codtable,v_treport(i).numseq,
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
    end loop; --v_column_size
    gen_style_column(v_obj_detail_style_row,p_showimg);
--===========================================================================================
    if p_staemp <> '99' then
      v_where := v_where||' temploy1.staemp = '||''''||p_staemp||'''';
    elsif p_staemp is null then
      v_where := v_where||' temploy1.staemp like ''%''';
    else
      v_where := v_where||' temploy1.staemp in (''1'',''3'')';
    end if;

    if p_codcomp is not null then
      v_where := v_where||' and temploy1.codcomp like '''||p_codcomp||'%''';
    end if;

    if p_comgrp is not null then
      v_where := v_where||' and exists (select  1 '||
                                      ' from    tcenter '||
                                      ' where   temploy1.codcomp = tcenter.codcomp '||
                                     -- ' and rownum =1 '||
                                      ' and     tcenter.compgrp = '''||p_comgrp||''') ';
    end if;

    if r_trepdsph.syncond is not null then
      for r_treport2 in c_report2 loop
        if instr(r_trepdsph.syncond,r_treport2.namtbl) > 0 then
          if upper(r_treport2.namtbl) in ('TAPPLDOC','TEMPOTHR','TCMPTNCY','TAPPLWEX','TAPPLREF','TTRAINBF','TEDUCATN') then
            --v_join  := v_join||' join '||r_treport2.namtbl||' on '||r_treport2.namtbl||'.numappl = temploy1.numappl ';
             v_join  := v_join||' left join '||r_treport2.namtbl||' on '||r_treport2.namtbl||'.numappl = temploy1.numappl ';
          elsif upper(r_treport2.namtbl) <> 'TEMPLOY1' then
            --v_join  := v_join||' join '||r_treport2.namtbl||' on '||r_treport2.namtbl||'.codempid = temploy1.codempid ';
            v_join  := v_join||' left join '||r_treport2.namtbl||' on '||r_treport2.namtbl||'.codempid = temploy1.codempid ';
          end if;
          --<<User37 #7108 11/10/2021 
          if upper(r_treport2.namtbl) = 'TEMPCONST' then
            v_chktempconst := 'Y';
          end if;
          -->>User37 #7108 11/10/2021 
        end if;
      end loop;
      v_where := v_where||' and ('||r_trepdsph.syncond||') ';
      for r_chk_sal in c_chk_sal loop
        if instr(r_trepdsph.syncond,r_chk_sal.colmn) > 0 then
          v_where   := replace(v_where,r_chk_sal.colmn,'stddec('||r_chk_sal.colmn||',temploy1.codempid,'||global_v_chken||')');
        end if;
      end loop;

      if v_where like '%AGEEMPMT%' then
        v_where := replace(v_where,'TEMPLOY1.AGEEMPMT','TRUNC( MONTHS_BETWEEN(NVL(TEMPLOY1.DTEEFFEX,SYSDATE),TEMPLOY1.DTEEMPMT))');
      elsif v_where like '%AGEEMP%' then
        v_where := replace(v_where,'TEMPLOY1.AGEEMP','TRUNC( MONTHS_BETWEEN(SYSDATE,TEMPLOY1.DTEEMPDB)/12)');
      elsif v_where like '%AGELEVEL%' then
        v_where := replace(v_where,'TEMPLOY1.AGELEVEL','TRUNC( MONTHS_BETWEEN(NVL(TEMPLOY1.DTEEFFEX,SYSDATE),TEMPLOY1.DTEEFLVL))');
      elsif v_where like '%AGEPOS%' then
        v_where := replace(v_where,'TEMPLOY1.AGEPOS','TRUNC( MONTHS_BETWEEN(NVL(TEMPLOY1.DTEEFFEX,SYSDATE),TEMPLOY1.DTEEFPOS))');
      elsif v_where like '%AGEJOBGRADE%' then
        v_where := replace(v_where,'TEMPLOY1.AGEJOBGRADE','TRUNC( MONTHS_BETWEEN(NVL(TEMPLOY1.DTEEFFEX,SYSDATE),TEMPLOY1.DTEEFSTEP))');
      end if;
    end if;

    --<<User37 #7108 11/10/2021 
    if v_chktempconst = 'Y' then
      v_stmt_main   := ' select distinct temploy1.codempid,temploy1.codcomp,temploy1.numappl,temploy1.numlvl,tempconst.dteeffec, 
                                         tempconst.numitem, tempconst.dteconst, tempconst.codcompy '||
                       ' from '||v_join||v_where||
                       ' order by temploy1.codcomp,temploy1.codempid,temploy1.numappl,temploy1.numlvl';
    else
      v_stmt_main   := ' select distinct temploy1.codempid,temploy1.codcomp,temploy1.numappl,temploy1.numlvl '||
                       ' from '||v_join||v_where||
                       ' order by temploy1.codcomp,temploy1.codempid,temploy1.numappl,temploy1.numlvl';
    end if;
    /*v_stmt_main   := ' select distinct temploy1.codempid,temploy1.codcomp,temploy1.numappl,temploy1.numlvl '||
                     ' from '||v_join||v_where||
                     ' order by temploy1.codcomp,temploy1.codempid,temploy1.numappl,temploy1.numlvl';*/
    -->>User37 #7108 11/10/2021 
--===================================================================================================
    v_cursor_main   := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor_main,v_stmt_main,dbms_sql.native);
    dbms_sql.define_column(v_cursor_main,1,v_codempid,1000);
    dbms_sql.define_column(v_cursor_main,2,v_codcomp,1000);
    dbms_sql.define_column(v_cursor_main,3,v_numappl,1000);
    dbms_sql.define_column(v_cursor_main,4,v_numlvl,1000);
    --<<User37 #7108 11/10/2021 
    if v_chktempconst = 'Y' then
      dbms_sql.define_column(v_cursor_main,5,to_char(v_dteeffec,'dd/mm/yyyy'),1000);
      dbms_sql.define_column(v_cursor_main,6,v_numitem,1000);
      dbms_sql.define_column(v_cursor_main,7,to_char(v_dteconst,'dd/mm/yyyy'),1000);
      dbms_sql.define_column(v_cursor_main,8,v_codcompy,1000);
    end if;
    -->>User37 #7108 11/10/2021 
    v_dummy := dbms_sql.execute(v_cursor_main);

    v_cursor_query  := dbms_sql.open_cursor;
    while (dbms_sql.fetch_rows(v_cursor_main) > 0) loop
      dbms_sql.column_value(v_cursor_main,1,v_codempid);
      dbms_sql.column_value(v_cursor_main,2,v_codcomp);
      dbms_sql.column_value(v_cursor_main,3,v_numappl);
      dbms_sql.column_value(v_cursor_main,4,v_numlvl);
      --<<User37 #7108 11/10/2021 
      if v_chktempconst = 'Y' then
        dbms_sql.column_value(v_cursor_main,5,v_dteeffec);
        dbms_sql.column_value(v_cursor_main,6,v_numitem);
        dbms_sql.column_value(v_cursor_main,7,v_dteconst);
        dbms_sql.column_value(v_cursor_main,8,v_codcompy);
      end if;
    -->>User37 #7108 11/10/2021 

      flgpass     := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if flgpass then
        for i in 1..v_column_size loop
          --- vvv Define Column vvv ---
          if v_treport(i).flgchksal = 'Y' then
            v_alias_column := 'decode('''||v_zupdsal||''',''Y'',to_char(stddec('||v_treport(i).codtable||'.'||v_treport(i).codcolmn||','''||v_codempid||''','''||global_v_chken||'''),''fm999,999,990.00'')) as '||v_treport(i).codcolmn;
          elsif v_treport(i).codsearch is not null then
            v_alias_column    := replace(v_treport(i).funcdesc,'P_CODE',v_treport(i).codtable||'.'||v_treport(i).codsearch)||' as '||v_treport(i).codcolmn;
            v_alias_column    := replace(v_alias_column,'P_LANG',global_v_lang);
--            if v_treport(i).codtable = 'TEMPCONST' then
--              v_alias_column    := replace(v_alias_column,'P_CODCOMPY',v_treport(i).codtable||'.CODCOMPY');
--              v_alias_column    := replace(v_alias_column,'P_DTEEFFEC',v_treport(i).codtable||'.DTEEFFEC');
--            end if;
          elsif v_treport(i).codcolmn like 'DTEEMP%' then
            v_alias_column    := 'get_age('||v_treport(i).codtable||'.'||v_treport(i).codcolmn||',to_date('''||v_dtecalculate||''',''dd/mm/yyyy'') as '||v_treport(i).codcolmn;
    --        obj_data.put('leave'||c, get_age(v_qtyemp,sysdate));
          elsif v_treport(i).codcolmn like 'DTE%' then
            v_alias_column    := 'to_char('||v_treport(i).codtable||'.'||v_treport(i).codcolmn||',''dd/mm/yyyy'') as '||v_treport(i).codcolmn;
    --        v_obj_detail_style.put('style','date');
    --      else
    --        obj_data.put('leave'||c, v_qtyemp);
    --        v_obj_detail_style.put('style',get_item_property(p_table,S_CODCOLMN));
          else
            v_alias_column    := v_treport(i).codtable||'.'||v_treport(i).codcolmn;
            --- vvv Find position column codempid use for show image vvv ---
            if v_treport(i).codcolmn = 'CODEMPID' then
              if p_showimg = 'Y' then
                v_n_codempid  := i;
              end if;
            end if;
          end if;
          if  v_treport(i).codtable not in ('TAPPLDOC','TAPPLREF','TAPPLWEX','TCMPTNCY','TEDUCATN','TEMPOTHR','TTRAINBF') then
            v_stmt_query  := ' select '||v_alias_column||
                             ' from '||v_treport(i).codtable||' '||
                             ' where codempid = '''||v_codempid||''' ';
            --<User37 #7108 11/10/2021 
            if v_treport(i).codtable = 'TEMPCONST' and v_treport(i).codcolmn = 'DESOBJT' then
              if v_chktempconst = 'Y' then
                  v_stmt_query := 'select decode('||global_v_lang||',''101'',desobjte
                                                                    ,''102'',desobjtt
                                                                    ,''103'',desobjt3
                                                                    ,''104'',desobjt4
                                                                    ,''105'',desobjt5)
                              from tpdpaitem, tempconst
                             where tempconst.codcompy = '''||v_codcompy||'''
                               and tpdpaitem.codcompy = tempconst.codcompy(+)
                               and tpdpaitem.dteeffec = tempconst.dteeffec(+)
                               and tpdpaitem.numitem = tempconst.numitem(+)
                               and tempconst.codempid = '''||v_codempid||'''
                               and tempconst.numitem = '''||v_numitem||'''
                               and tempconst.dteconst = '''||v_dteconst||'''
                               and tempconst.dteeffec = '''||v_dteeffec||'''
                             order by tempconst.numitem';
              else
                  v_stmt_query := 'select decode('||global_v_lang||',''101'',desobjte
                                                                    ,''102'',desobjtt
                                                                    ,''103'',desobjt3
                                                                    ,''104'',desobjt4
                                                                    ,''105'',desobjt5)
                              from tpdpaitem a, tempconst b
                             where b.codcompy = '''||hcm_util.get_codcomp_level(v_codcomp,1)||'''
                               and a.codcompy = b.codcompy(+)
                               and a.dteeffec = b.dteeffec(+)
                               and a.numitem = b.numitem(+)
                               and b.codempid = '''||v_codempid||'''
                               and b.dteeffec <= trunc(sysdate)
                             order by b.numitem';
              end if;
            elsif v_treport(i).codtable = 'TEMPCONST' and v_treport(i).codcolmn = 'DESITEM' then
              if v_chktempconst = 'Y' then
                v_stmt_query := 'select decode('||global_v_lang||',''101'',desiteme
                                                                  ,''102'',desitemt
                                                                  ,''103'',desitem3
                                                                  ,''104'',desitem4
                                                                  ,''105'',desitem5)
                                   from tpdpaitem, tempconst
                                  where tempconst.codcompy = '''||v_codcompy||'''
                                    and tpdpaitem.codcompy = tempconst.codcompy(+)
                                    and tpdpaitem.dteeffec = tempconst.dteeffec(+)
                                    and tpdpaitem.numitem = tempconst.numitem(+)
                                    and tempconst.codempid = '''||v_codempid||'''
                                    and tempconst.numitem = '''||v_numitem||'''
                                    and tempconst.dteconst = '''||v_dteconst||'''
                                    and tempconst.dteeffec = '''||v_dteeffec||'''
                                 order by tempconst.numitem';
              else
                v_stmt_query := 'select decode('||global_v_lang||',''101'',desiteme
                                                                ,''102'',desitemt
                                                                ,''103'',desitem3
                                                                ,''104'',desitem4
                                                                ,''105'',desitem5)
                                   from tpdpaitem a, tempconst b
                                  where b.codcompy = '''||hcm_util.get_codcomp_level(v_codcomp,1)||'''
                                    and a.codcompy = b.codcompy(+)
                                    and a.dteeffec = b.dteeffec(+)
                                    and a.numitem = b.numitem(+)
                                    and b.codempid = '''||v_codempid||'''
                                    and b.dteeffec <= trunc(sysdate)
                                 order by b.numitem';
              end if;
            elsif v_treport(i).codtable = 'TEMPCONST' then
              if v_chktempconst = 'Y' then
                v_stmt_query  := ' select '||v_alias_column||
                             ' from tpdpaitem, tempconst
                             where tempconst.codcompy = '''||v_codcompy||'''
                               and tpdpaitem.codcompy = tempconst.codcompy(+)
                               and tpdpaitem.dteeffec = tempconst.dteeffec(+)
                               and tpdpaitem.numitem = tempconst.numitem(+)
                               and tempconst.codempid = '''||v_codempid||'''
                               and tempconst.numitem = '''||v_numitem||'''
                               and tempconst.dteconst = '''||v_dteconst||'''
                               and tempconst.dteeffec = '''||v_dteeffec||'''
                             order by tempconst.numitem';
              end if;
            end if;

            -->>User37 #7108 11/10/2021 
          else
            v_stmt_query  := ' select '||v_alias_column||
                             ' from '||v_treport(i).codtable||' '||
                             ' where numappl = '''||v_numappl||''' ';
          end if;

--in sert_temp2('PMA1X','AAA','C',i,v_stmt_query,null,null,null,null,null,null,null);
insert_temp2('YYY','YYY',1,v_stmt_query,null,null,null,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
          dbms_sql.parse(v_cursor_query,v_stmt_query,dbms_sql.native);
          dbms_sql.define_column(v_cursor_query,1,v_data_exec,2000);
          v_dummy     := dbms_sql.execute(v_cursor_query);
          v_rcnt      := v_last_record;
          while (dbms_sql.fetch_rows(v_cursor_query) > 0) loop
            v_rcnt      := v_rcnt + 1;
            dbms_sql.column_value(v_cursor_query,1,v_data_exec);
--            if v_treport(i).codcolmn like 'DTE%' and v_treport(i).codsearch is null then
            if v_treport(i).codcolmn like 'DTE%' then
              if v_data_exec is not null and global_v_lang = 102 then
                begin
--                  v_data_exec :=  to_char(add_months(to_date(v_data_exec,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy');
                  v_data_exec :=  to_char(to_date(v_data_exec,'dd/mm/yyyy'),'dd/mm/')||
                                  (to_char(to_date(v_data_exec,'dd/mm/yyyy'),'YYYY') + numYearReport);
                exception when others then null;
                end;
              end if;
            end if;
            v_table_data(v_rcnt).data_n(i)  := v_data_exec;
            v_table_data(v_rcnt).table_n(i)  := v_treport(i).codtable;

--<<SEA-HR2201-redmin679-------------------------------------------------------------------------------------------------------------------------------
              obj_data    := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('column_size', v_column_size);

              for x8 in 1..v_column_size loop
                begin
                  if v_n_codempid = x8 then
                    obj_data.put('image', nvl(get_emp_img(v_table_data(v_rcnt).data_n(x8)),v_table_data(v_rcnt).data_n(x8)));
                    obj_data.put('logo_image', '/'||get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||nvl(get_emp_img(v_table_data(v_rcnt).data_n(x8)),v_table_data(v_rcnt).data_n(x8)));
                  end if;
                  obj_data.put('column'||to_char(x8), v_table_data(v_rcnt).data_n(x8));
                exception when no_data_found then
                  begin
                    if v_table_data(v_rcnt - 1).table_n(x8) = 'TEMPLOY1' then
                      if v_n_codempid = x8 then
                        obj_data.put('image', nvl(get_emp_img(v_table_data(v_rcnt - 1).data_n(x8)),v_table_data(v_rcnt - 1).data_n(x8)));
                        obj_data.put('logo_image', '/'||get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||nvl(get_emp_img(v_table_data(v_rcnt - 1).data_n(x8)),v_table_data(v_rcnt - 1).data_n(x8)));
                      end if;
                      obj_data.put('column'||to_char(x8), v_table_data(v_rcnt - 1).data_n(x8));
                      v_table_data(v_rcnt).data_n(x8)    := v_table_data(v_rcnt - 1).data_n(x8);
                      v_table_data(v_rcnt).table_n(x8)   := v_table_data(v_rcnt - 1).table_n(x8);
                    else
                      if v_n_codempid = x8 then
                        obj_data.put('image', '');
                      end if;
                      obj_data.put('column'||to_char(x8), '');
                      v_table_data(v_rcnt).data_n(x8)    := '';
                      v_table_data(v_rcnt).table_n(x8)   := v_table_data(v_rcnt - 1).table_n(x8);
                    end if;
                  exception when no_data_found then
                    null;
                  end;
                end;
              end loop;  --for i in 1..v_column_size loop

              obj_row.put(to_char(v_rcnt - 1), obj_data);
--<<SEA-HR2201-redmin679----------------------------------------------------------------------------------------------

          end loop;

          v_max_record  := greatest(v_max_record,v_rcnt);
        end loop;
        v_last_record := v_max_record;
      end if;
--<<if  3      
--if v_rcnt = 3000 then exit; end if;
-->>if  3
    end loop;



/*backup SEA-HR2201 03/02/2023 
    for r_table_data in 1..v_table_data.count loop
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('column_size', v_column_size);

--in sert_temp2('PMA1X','AAA','D',r_table_data,v_column_size,null,null,null,null,null,null,null);

      for i in 1..v_column_size loop
        begin
          if v_n_codempid = i then
            obj_data.put('image', nvl(get_emp_img(v_table_data(r_table_data).data_n(i)),v_table_data(r_table_data).data_n(i)));
            obj_data.put('logo_image', '/'||get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||nvl(get_emp_img(v_table_data(r_table_data).data_n(i)),v_table_data(r_table_data).data_n(i)));
          end if;
          obj_data.put('column'||to_char(i), v_table_data(r_table_data).data_n(i));
        exception when no_data_found then
          begin
            if v_table_data(r_table_data - 1).table_n(i) = 'TEMPLOY1' then
              if v_n_codempid = i then
                obj_data.put('image', nvl(get_emp_img(v_table_data(r_table_data - 1).data_n(i)),v_table_data(r_table_data - 1).data_n(i)));
                obj_data.put('logo_image', '/'||get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||nvl(get_emp_img(v_table_data(r_table_data - 1).data_n(i)),v_table_data(r_table_data - 1).data_n(i)));
              end if;
              obj_data.put('column'||to_char(i), v_table_data(r_table_data - 1).data_n(i));
              v_table_data(r_table_data).data_n(i)    := v_table_data(r_table_data - 1).data_n(i);
              v_table_data(r_table_data).table_n(i)   := v_table_data(r_table_data - 1).table_n(i);
            else
              if v_n_codempid = i then
                obj_data.put('image', '');
              end if;
              obj_data.put('column'||to_char(i), '');
              v_table_data(r_table_data).data_n(i)    := '';
              v_table_data(r_table_data).table_n(i)   := v_table_data(r_table_data - 1).table_n(i);
            end if;
          exception when no_data_found then
            null;
          end;
        end;
      end loop;  --for i in 1..v_column_size loop

      obj_row.put(to_char(r_table_data - 1), obj_data);
    end loop;  --for r_table_data in 1..v_table_data.count loop
SEA-HR2201 03/02/2023 backup */

    commit;
    json_str_output   := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end;
  --
  procedure get_detail(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
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
  --
  procedure get_detail_head_desc(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail_head_desc(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_head_desc(json_str_output out clob) as
  json_obj    json_object_t;
  obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number:=0;
    v_char     varchar2(100);
    begin
      obj_row := json_object_t();
      obj_data := json_object_t();

      obj_data.put('compgrp',get_tcodec_name('TCOMPGRP',p_comgrp,global_v_lang));
      obj_data.put('staemp',get_tlistval_name('NAMSTATA1', p_staemp ,global_v_lang));
      obj_row.put('0',obj_data);
      obj_data := json_object_t();
      obj_data.put('compgrp',get_tcodec_name('TCOMPGRP',p_comgrp,global_v_lang));
      obj_data.put('staemp',v_char);
      obj_row.put('1',obj_data);
      json_str_output := obj_row.to_clob;
    exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
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
              codtable,codcolmn
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
      obj_data.put('codcolmn',r1.codcolmn);
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
    cursor c1 is
      select  t1.codcolmn,
              t1.descolmn as desc_colmn,
              t1.codtable,
              t2.codcolmn as colname
      from    trepdspd t1,treport t2
      where   t1.codapp     = 'HRPMA1X'
      and     t1.codrep     = p_codrep
      and     t1.codtable   = t2.codtable
      and     t1.codcolmn   = t2.numseq
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
      obj_data.put('codcolmn',r1.colname);
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
  --
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
-- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | issue kohu 4449: #1799
  procedure post_delete_codrep(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_delete_codrep(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end post_delete_codrep;
  procedure gen_delete_codrep(json_str_output out clob) is
  begin
    BEGIN
      delete trepdsph where codapp ='HRPMA1X' and codrep = p_codrep;
      delete trepdspd where codapp ='HRPMA1X' and codrep = p_codrep;
      commit;
      param_msg_error := get_error_msg_php('HR2425', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    exception when others then
      param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end;
  end gen_delete_codrep;
-- >> KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | issue kohu 4449: #1799
END HRPMA1X;

/

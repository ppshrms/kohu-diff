--------------------------------------------------------
--  DDL for Package Body HRRPS3X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRPS3X" is
-- last update: 07/08/2020 09:40

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
    logic			json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codwork     := hcm_util.get_string_t(json_obj,'p_codwork');
    b_index_splitrow    := hcm_util.get_string_t(json_obj,'p_splitrow');
    b_index_splitcol    := hcm_util.get_string_t(json_obj,'p_splitcol');
    
    p_logic1       := hcm_util.get_string_t(json_obj,'p_syncond1');
    p_logic2       := hcm_util.get_string_t(json_obj,'p_syncond2');
    p_logic3       := hcm_util.get_string_t(json_obj,'p_syncond3');
    p_description1  :=  hcm_util.get_string_t(json_obj,'p_description1');
    p_description2  :=  hcm_util.get_string_t(json_obj,'p_description2');
    p_description3  :=  hcm_util.get_string_t(json_obj,'p_description3');
--    p_logic1       := hcm_util.get_json_t(json_obj,'p_syncond1');
--    p_logic2       := hcm_util.get_json_t(json_obj,'p_syncond2');
--    p_logic3       := hcm_util.get_json_t(json_obj,'p_syncond3');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data(json_str_output out clob) is
    obj_data_parent_col        json_object_t;
    obj_data_child_col         json_object_t;
    obj_data                   json_object_t;
    
    obj_row_parent_col         json_object_t;
    obj_row_child_col          json_object_t;
    obj_row                    json_object_t;
    obj_row_data               json_object_t;
    
    obj_rowmain                json_object_t;
    
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_rcnt3         number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    flgpass     	boolean; 
    v_zupdsal   	varchar2(4);
    v_code1         varchar2(3000);      
    v_code2         varchar2(3000);    
    v_code3         varchar2(3000);  
    v_description1  varchar2(3000);  
    v_description2  varchar2(3000);  
    v_description3  varchar2(3000);  
    v_sub_col       varchar2(1) := 'N';
    v_num           number(10) := 0;
    
    v_statment      varchar2(4000); 
    v_where         varchar2(4000);
    v_cursor        number;
    v_codempid      varchar2(100);
    v_codcomp       varchar2(100);
    v_dummy         integer;
    v_splitcol      varchar2(1000);
    v_splitrow      varchar2(1000);
    v_desc          varchar2(1000); 
    v_fundesc       varchar2(1000);
    v_cursor2       number;
    v_cursor3       number;
    v_cntsub        number;
    v_row           number;
    
    type a_text is table of varchar2(1000) index by binary_integer;
    	a_splitcol			a_text;
        a_code              a_text;
       
  begin
    v_code1         :=  p_logic1;
    v_code2         :=  p_logic2;
    v_code3         :=  p_logic3;
    v_description1  :=  p_description1;
    v_description2  :=  p_description2;
    v_description3  :=  p_description3;
    for i in 1..3 loop
        a_code(i) := null;
    end loop;
    
	if v_code1 is not null then
        v_where := ' and ( '||v_code1;
        a_code(1) := v_code1;
    end if;
    if v_code2 is not null then
        v_where := v_where||' or '||v_code2;
        a_code(2) := v_code2;
    end if;
    if v_code3 is not null then
        v_where := v_where||' or '||v_code3;
        a_code(3) := v_code3;
    end if;
    if v_where is not null then
        v_where := v_where||' )';
    end if;

	if b_index_codcompy is not null and b_index_codwork is not null then
        v_statment := 'select codempid,codcomp'||
                      '  from v_hrrps3x where codcomp in ('||
                              'select b.codcompp
                                from thisorg a, thisorg2 b
                               where a.codcompy = b.codcompy
                                 and a.codlinef = b.codlinef
                                 and a.dteeffec = b.dteeffec
                                 and a.staorg   = ''A'''||
                                'and '||b_index_splitcol||' is not null 
                                 and '||b_index_splitrow||' is not null 
                                 and a.codcompy = '''||b_index_codcompy||''' 
                                 and a.codlinef = '''||b_index_codwork||''' 
                                 and a.dteeffec = (select max(c.dteeffec)
                                                     from thisorg c, thisorg2 d
                                                    where c.codcompy = d.codcompy
                                                      and c.codlinef = d.codlinef
                                                      and c.dteeffec = d.dteeffec
                                                      and c.staorg   = ''A''
                                                      and c.codcompy = '''||b_index_codcompy||''' 
                                                      and c.codlinef = '''||b_index_codwork||''') 
                                                    group by b.codcompp)' 
                              ||v_where||' '||
                          ' order by codempid ' ;
    else
        v_statment := 'select codempid,codcomp  
                         from v_hrrps3x where codcomp like '''||b_index_codcomp||'%'''||' and '||b_index_splitcol||' is not null and '||b_index_splitrow||' is not null '||v_where||' '||
			          ' order by codempid ' ;
    end if;
    v_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_statment,dbms_sql.native);
    dbms_sql.define_column(v_cursor,1,v_codempid,100);
    dbms_sql.define_column(v_cursor,2,v_codcomp,100);
    
    v_dummy := dbms_sql.execute(v_cursor);

    while dbms_sql.fetch_rows(v_cursor) > 0 loop
        dbms_sql.column_value(v_cursor,1,v_codempid);
        dbms_sql.column_value(v_cursor,2,v_codcomp);
        v_flgdata := 'Y';
        flgpass := secur_main.secur3(v_codcomp,v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
        end if;
    end loop;
    
    dbms_sql.close_cursor(v_cursor);
    
    if v_flgdata = 'Y' and v_flgsecu = 'Y' then

        --child
        v_rcnt := 0;
        obj_row_child_col := json_object_t();
        for i in 1..3 loop
            if i = 1 and v_code1 is not null then
                v_sub_col := 'Y';
                v_rcnt := v_rcnt+1;
                obj_data_child_col := json_object_t();
                obj_data_child_col.put('col'||i,v_description1);
                obj_row_child_col.put(to_char(v_rcnt-1),obj_data_child_col);
                v_cntsub:= 1;
            elsif i = 2 and v_code2 is not null then
                v_sub_col := 'Y';
                v_rcnt := v_rcnt+1;
                obj_data_child_col := json_object_t();
                obj_data_child_col.put('col'||i,v_description2);
                obj_row_child_col.put(to_char(v_rcnt-1),obj_data_child_col);
                v_cntsub:= 2;
            elsif i = 3 and v_code3 is not null then
                v_sub_col := 'Y';
                v_rcnt := v_rcnt+1;
                obj_data_child_col := json_object_t();
                obj_data_child_col.put('col'||i,v_description3);
                obj_row_child_col.put(to_char(v_rcnt-1),obj_data_child_col);
                v_cntsub:= 3;
            end if;
        end loop;
        
        if b_index_codcompy is not null and b_index_codwork is not null then
            v_statment := 'select '||b_index_splitcol||' splitcol'||
                          '  from v_hrrps3x where codcomp in ('||
                                  'select b.codcompp
                                    from thisorg a, thisorg2 b
                                   where a.codcompy = b.codcompy
                                     and a.codlinef = b.codlinef
                                     and a.dteeffec = b.dteeffec
                                     and a.staorg   = ''A'''||
                                     'and '||b_index_splitcol||' is not null 
                                     and '||b_index_splitrow||' is not null 
                                     and a.codcompy = '''||b_index_codcompy||''' 
                                     and a.codlinef = '''||b_index_codwork||''' 
                                     and a.dteeffec = (select max(c.dteeffec)
                                                         from thisorg c, thisorg2 d
                                                        where c.codcompy = d.codcompy
                                                          and c.codlinef = d.codlinef
                                                          and c.dteeffec = d.dteeffec
                                                          and c.staorg   = ''A''
                                                          and c.codcompy = '''||b_index_codcompy||''' 
                                                          and c.codlinef = '''||b_index_codwork||''') 
                                                          and exists (select x.codcomp from tusrcom x 
                                                                       where x.coduser = '''||global_v_coduser||'''
                                                                         and b.codcompp like x.codcomp||''%'')
                                                        group by b.codcompp)'
                                  ||v_where||' '||
                              ' group by '||b_index_splitcol||
                              ' order by '||b_index_splitcol ;
        else
            v_statment := 'select '||b_index_splitcol||' splitcol'||
                      '  from v_hrrps3x where codcomp like '''||b_index_codcomp||'%'''||
                          'and '||b_index_splitcol||' is not null 
                           and '||b_index_splitrow||' is not null 
                           and exists (select x.codcomp from tusrcom x 
                                        where x.coduser = '''||global_v_coduser||'''
                                          and v_hrrps3x.codcomp like x.codcomp||''%'')'
                          ||v_where||' '||
                          ' group by '||b_index_splitcol||
                          ' order by '||b_index_splitcol ;
        end if;
        v_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(v_cursor,v_statment,dbms_sql.native);
        dbms_sql.define_column(v_cursor,1,v_splitcol,100);
        v_dummy := dbms_sql.execute(v_cursor);
        v_rcnt := 0;
        v_rcnt2 := 0;
        obj_row_parent_col := json_object_t();
        v_cursor2 := dbms_sql.open_cursor;
        while dbms_sql.fetch_rows(v_cursor) > 0 loop
            dbms_sql.column_value(v_cursor,1,v_splitcol);
            
            --description fundesc from treport2
            begin
              select funcdesc
                into v_fundesc  
                from treport2
               where codapp = 'HRRPS3XR'
                 and namfld = b_index_splitcol;
            exception when no_data_found then
              v_fundesc := null;
            end;
            
            
            v_fundesc := replace(v_fundesc,'P_CODE',''''||v_splitcol||'''');
            v_fundesc := replace(v_fundesc,'P_LANG',''''||global_v_lang||'''');
            if v_fundesc is not null then
                v_fundesc := 'select '||v_fundesc||' from dual';
            else
                v_fundesc := 'select '''||v_splitcol||''' from dual';
            end if;
            dbms_sql.parse(v_cursor2,v_fundesc,dbms_sql.native);
            dbms_sql.define_column(v_cursor2,1,v_desc,1000);
            v_dummy := dbms_sql.execute(v_cursor2);
            while dbms_sql.fetch_rows(v_cursor2) > 0 loop
                dbms_sql.column_value(v_cursor2,1,v_desc);
            end loop;
            
            -- parent
            v_rcnt := v_rcnt+1;
            a_splitcol(v_rcnt) := v_splitcol;
            obj_data_parent_col := json_object_t();
            obj_data_parent_col.put('col'||v_rcnt,v_desc);
            obj_row_parent_col.put(to_char(v_rcnt-1),obj_data_parent_col);
        end loop;
        
        --mockDetailRows
        if b_index_codcompy is not null and b_index_codwork is not null then
            v_statment := 'select '||b_index_splitrow||' splitrow'||
                          '  from v_hrrps3x where codcomp in ('||
                                  'select b.codcompp
                                    from thisorg a, thisorg2 b
                                   where a.codcompy = b.codcompy
                                     and a.codlinef = b.codlinef
                                     and a.dteeffec = b.dteeffec
                                     and a.staorg   = ''A'''||
                                     'and '||b_index_splitcol||' is not null 
                                     and '||b_index_splitrow||' is not null 
                                     and a.codcompy = '''||b_index_codcompy||''' 
                                     and a.codlinef = '''||b_index_codwork||''' 
                                     and a.dteeffec = (select max(c.dteeffec)
                                                         from thisorg c, thisorg2 d
                                                        where c.codcompy = d.codcompy
                                                          and c.codlinef = d.codlinef
                                                          and c.dteeffec = d.dteeffec
                                                          and c.staorg   = ''A''
                                                          and c.codcompy = '''||b_index_codcompy||''' 
                                                          and c.codlinef = '''||b_index_codwork||''') 
                                                          and exists (select x.codcomp from tusrcom x 
                                                                       where x.coduser = '''||global_v_coduser||'''
                                                                         and b.codcompp like x.codcomp||''%'')
                                                        group by b.codcompp)'
                                  ||v_where||' '||
                              ' group by '||b_index_splitrow||
                              ' order by '||b_index_splitrow ;
        else
            v_statment := 'select '||b_index_splitrow||' splitrow'||
                      '  from v_hrrps3x where codcomp like '''||b_index_codcomp||'%'''||
                          'and '||b_index_splitcol||' is not null 
                           and '||b_index_splitrow||' is not null 
                           and exists (select x.codcomp from tusrcom x 
                                        where x.coduser = '''||global_v_coduser||'''
                                          and v_hrrps3x.codcomp like x.codcomp||''%'')'
                          ||v_where||' '||
                          ' group by '||b_index_splitrow||
                          ' order by '||b_index_splitrow ;
        end if;
        
        v_cursor3 := dbms_sql.open_cursor;
        dbms_sql.parse(v_cursor3,v_statment,dbms_sql.native);
        dbms_sql.define_column(v_cursor3,1,v_splitcol,100);
        v_dummy := dbms_sql.execute(v_cursor3);
        v_rcnt3 := 0;
        obj_row := json_object_t();
        while dbms_sql.fetch_rows(v_cursor3) > 0 loop
            v_rcnt3 := nvl(v_rcnt3,0)+1;
            dbms_sql.column_value(v_cursor3,1,v_splitrow);
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            
            --description fundesc from treport2
            begin
              select funcdesc
                into v_fundesc  
                from treport2
               where codapp = 'HRRPS3XR'
                 and namfld = b_index_splitrow;
            exception when no_data_found then
              v_fundesc := null;
            end;
            v_fundesc := replace(v_fundesc,'P_CODE',''''||v_splitrow||'''');
            v_fundesc := replace(v_fundesc,'P_LANG',''''||global_v_lang||'''');
            if v_fundesc is not null then
                v_fundesc := 'select '||v_fundesc||' from dual';
            else
                v_fundesc := 'select '''' from dual';
            end if;
            dbms_sql.parse(v_cursor2,v_fundesc,dbms_sql.native);
            dbms_sql.define_column(v_cursor2,1,v_desc,1000);
            v_dummy := dbms_sql.execute(v_cursor2);
            while dbms_sql.fetch_rows(v_cursor2) > 0 loop
                dbms_sql.column_value(v_cursor2,1,v_desc);
            end loop;
            
            obj_data.put('description', v_desc);
            v_row := 0;
            if nvl(v_cntsub,0) > 0 then 
                for i in 1..v_cntsub loop
                    for j in 1..v_rcnt loop
                        v_row := nvl(v_row,0)+1;
                        v_num := execute_sql('select count(codempid) 
                                                from v_hrrps3x 
                                                where '||b_index_splitrow||' = '''||v_splitrow||''' 
                                                  and '||b_index_splitcol||' = '''||a_splitcol(j)||'''
                                                  and '||a_code(i));
                        obj_data.put('data'||v_row, v_num);
                    end loop;
                end loop;
            else
                for i in 1..(v_rcnt) loop
                    v_row := nvl(v_row,0)+1;
                    v_num := execute_sql('select count(codempid) 
                                                from v_hrrps3x 
                                                where '||b_index_splitrow||' = '''||v_splitrow||''' 
                                                  and '||b_index_splitcol||' = '''||a_splitcol(i)||'''');
                    obj_data.put('data'||v_row, v_num);
                end loop;
            end if;
            obj_row.put(to_char(v_rcnt3-1),obj_data);
            obj_rowmain := json_object_t();
        end loop;
        
        dbms_sql.close_cursor(v_cursor);
        dbms_sql.close_cursor(v_cursor2);
        dbms_sql.close_cursor(v_cursor3);
        
        obj_row_data := json_object_t();
        obj_row_data.put('rows',obj_row);
        
        obj_rowmain.put('coderror', '200');
        obj_rowmain.put('indexHeadParentCol',obj_row_parent_col);
        obj_rowmain.put('indexHeadChildCol',obj_row_child_col);
        obj_rowmain.put('totalParent',obj_row_parent_col.get_size);
        obj_rowmain.put('totalChild',obj_row_child_col.get_size);
        obj_rowmain.put('table',obj_row_data);
        
    end if;--if v_flgdata = 'Y' and v_flgsecu = 'Y' then
    

    
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttmovemt');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_rowmain.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  
  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';
    
    cursor c1 is 
      select b.codcompp
        from thisorg a, thisorg2 b
       where a.codcompy = b.codcompy
         and a.codlinef = b.codlinef
         and a.dteeffec = b.dteeffec
         and a.staorg   = 'A'
         and a.codcompy = b_index_codcompy
         and a.codlinef = b_index_codwork
         and a.dteeffec = (select max(c.dteeffec)
                             from thisorg c, thisorg2 d
                            where c.codcompy = d.codcompy
                              and c.codlinef = d.codlinef
                              and c.dteeffec = d.dteeffec
                              and c.staorg   = 'A'
                              and c.codcompy = b_index_codcompy
                              and c.codlinef = b_index_codwork)
      group by b.codcompp;
  begin
    if  b_index_codcompy is not null and b_index_codwork is not null then
        for i in c1 loop
            v_data  := 'Y';
            v_flgSecur := secur_main.secur7(i.codcompp,global_v_coduser);
            if v_flgSecur then
                v_chkSecur  := 'Y';
            end if;
        end loop;
        if v_data = 'N' then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'thisorg2');
            return;
        elsif v_chkSecur = 'N' then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;
    
  end;
end;

/

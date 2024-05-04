--------------------------------------------------------
--  DDL for Package Body HRCOS2X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCOS2X" is
-- last update: 08/04/2020 17:35
 FUNCTION check_updsal  ( p_codempid in varchar2,p_numlvlst in number ,p_numlvlen in number)  RETURN  NUMBER IS
v_numlvl  number ;
BEGIN
  begin
   select  numlvl into  v_numlvl
   from    temploy1
   where   codempid = p_codempid ;
  exception when no_data_found then
    v_numlvl  := 0 ;
  end ;
  if   v_numlvl between p_numlvlst and p_numlvlen then
       return  1 ;
  else
       return 0 ;
  end if;
END;
----------------------------------------------------------------------------------
 procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid'));
    p_codcompy        := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_rep_id          := hcm_util.get_string_t(json_obj,'p_rep_id');
    p_rep_table       := hcm_util.get_string_t(json_obj,'p_rep_table');

    json_params         := hcm_util.get_json_t(json_obj, 'params');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    global_v_chken    := hcm_secur.get_v_chken ;
  end initial_value;
----------------------------------------------------------------------------------
  procedure get_tquery_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tquery_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tquery_index;
----------------------------------------------------------------------------------
  procedure gen_tquery_index (json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;

    cursor c_tquery is
       select  decode(global_v_lang, '101', t.rep_desce,
                                     '102', t.rep_desct,
                                     '103', t.rep_desc3,
                                     '104', t.rep_desc4,
                                     '105', t.rep_desc5,
                                      t.rep_desce) as rep_desc ,
               t.rep_id
       from    tquery t
       where t.rep_id in (select tq.rep_id from tqsecur tq where tq.userrep = global_v_coduser)
       order by t.rep_id;
  begin
    obj_row     := json_object_t();
    for r_tquery in c_tquery loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('rep_desc', r_tquery.rep_desc);
      obj_data.put('rep_id', r_tquery.rep_id);

      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;

    json_str_output := obj_row.to_clob;
  end gen_tquery_index;
----------------------------------------------------------------------------------
  procedure get_tqfield(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tqfield(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tqfield;
----------------------------------------------------------------------------------
  procedure gen_tqfield (json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;

    cursor c_tqfield is
       select  t.rep_id,t.rep_field,
               t.rep_field_key,
               case
                     when t.cal_name is null then get_tcoldesc_name(t.rep_table,t.rep_field,global_v_lang)
                     else t.cal_name
               end as cal_name,
               case
                   when t.rep_cal is not null then get_desc_function(t.rep_cal,p_rep_id)
                   else get_tlistval_name('FUNCQRY', t.rep_func, global_v_lang)
               end as rep_cal
       from    tqfield t
       where upper(t.rep_id) = upper(p_rep_id)
       order by t.num_seq ;

  begin
    obj_row     := json_object_t();
    for r_tqfield in c_tqfield loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('rep_id', r_tqfield.rep_id);
      obj_data.put('rep_field', r_tqfield.rep_field);
      obj_data.put('cal_name', r_tqfield.cal_name);
      obj_data.put('rep_cal', r_tqfield.rep_cal);
      obj_data.put('rep_field_key', r_tqfield.rep_field_key);

      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;

    json_str_output := obj_row.to_clob;
  end gen_tqfield;
----------------------------------------------------------------------------------
procedure get_tquery (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tquery(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tquery;

----------------------------------------------------------------------------------

  procedure gen_tquery (json_str_output out clob) is
    obj_data        json_object_t;
    v_cnt_secur     number;
    v_flgdist       tquery.flgdist%type;
    v_rep_where     tquery.rep_where%type;
    v_rep_special   tquery.rep_special%type;
    v_statement     tquery.statement%type;
    ----------------------------------
  begin

    begin

      select t.flgdist, t.rep_where, t.rep_special, t.statement
      into   v_flgdist, v_rep_where, v_rep_special, v_statement
      from   tquery t
      where  upper(t.rep_id) = upper(p_rep_id) ;

    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang);
      json_str_output := get_response_message('400','gen_report_header' || param_msg_error,global_v_lang);
      return;
    end;
    ------------------------------------------------------------
    select count('x')
    into   v_cnt_secur
    from   tqsecur t
    where  t.rep_id = p_rep_id and t.userrep = global_v_coduser ;
    ----------------------------------------------
    if v_cnt_secur = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang) ;
      json_str_output   := get_response_message('400',param_msg_error, global_v_lang);
      return ;
    end if ;
    ----------------------------------------------

    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('rep_id', p_rep_id);
    obj_data.put('flgdist', v_flgdist);
    obj_data.put('rep_where', v_rep_where);
    obj_data.put('rep_special', v_rep_special);
    obj_data.put('statement', v_statement);
    obj_data.put('description', get_logical_desc(v_statement));
    ------------------------------------

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_tquery;
----------------------------------------------------------------------------------
procedure get_tqsort_index(json_str_input in clob, json_str_output out clob) as
begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tqsort_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_tqsort_index;
----------------------------------------------------------------------------------
procedure gen_tqsort_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt		  number := 0;
    cursor c_tqsort is
      select t.rep_id, t.num_seq, t.rep_field, t.flgorder, t.flggroup, t.numseq , t.rep_field_key ,
             t2.rep_table
      from   tqsort t 
      left join tqfield t2 
      on t.rep_field_key = t2.rep_field_key 
      and t.rep_field = t2.rep_field
      where  t.rep_id = p_rep_id
      order by t.num_seq ;
begin
    obj_row     := json_object_t();
    for r_tqsort in c_tqsort loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('rep_id', r_tqsort.rep_id);

      obj_data.put('rep_id', r_tqsort.rep_id);
      obj_data.put('num_seq', r_tqsort.num_seq);
      obj_data.put('rep_field', r_tqsort.rep_field);
      obj_data.put('flgorder', r_tqsort.flgorder);
      obj_data.put('flggroup', r_tqsort.flggroup);
      obj_data.put('numseq', r_tqsort.numseq);
      obj_data.put('rep_field_key', r_tqsort.rep_field_key);
      obj_data.put('description', get_tcoldesc_name (r_tqsort.rep_table ,r_tqsort.rep_field ,global_v_lang ) );


      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
end gen_tqsort_index;
--------------------------------------------------------------------------
function get_desc_function(p_rep_cal in varchar2,p_rep_id in varchar2) return varchar2 IS
v_desc    varchar2(4000) ;
v_code    varchar2(7):= 'P_CODE1' ;

  cursor c1 is
   select codtable||'_'||codcolmn colmn,get_tcoldesc_name(codtable,codcolmn,global_v_lang) des
   from   tcoldesc
   where  codtable in (select rep_table
                       from tqtable
                       where rep_id = p_rep_id)
   order by codtable,column_id;

BEGIN
 v_desc := p_rep_cal ;
  for i in  c1 loop
    v_desc := replace(v_desc,'STDDEC('||i.colmn||','||v_code||',''P_CODE2'') ',i.colmn);
     v_desc := replace(v_desc,i.colmn,i.des);
  end loop ;

  return  v_desc ;
END;
--------------------------------------------------------------------------
procedure gen_header_report (json_str_input in clob, json_str_output out clob) as
  type array_t is varray(80) of varchar2(200);
  arr_column_name          array_t ;
  -------------------------------------------
  obj_row     json_object_t;
  obj_data    json_object_t;
  v_rep_id    varchar2(100 char);
  i           number ;
  v_concat                 varchar2(10 char);

  cursor c_tqfield(v_rep_id in varchar2) is
     select * from tqfield t where t.rep_id = v_rep_id order by t.num_seq ;
begin
    -------------------------------------------
    initial_value(json_str_input);
    -------------------------------------------
    v_rep_id := p_rep_id ;
    i := 1 ;
    arr_column_name := array_t() ;
    obj_row := json_object_t();

    for r_tqfield in c_tqfield(v_rep_id)
    loop
      arr_column_name.extend ;
      arr_column_name(i) := r_tqfield.rep_table || '_' || r_tqfield.rep_field || '_' || TO_CHAR(i)  ;
      obj_data    := json_object_t();
      obj_data.put('colspan', 1);
      obj_data.put('headerRow', 1);
      obj_data.put('key', arr_column_name(i));
      ---------------------------------------------
      if (r_tqfield.cal_name is  null) then
         obj_data.put('name', get_tcoldesc_name (r_tqfield.rep_table ,r_tqfield.rep_field ,global_v_lang ));
      else
         obj_data.put('name', r_tqfield.cal_name);
      end if;
      ---------------------------------------------
      obj_data.put('rowspan', 1);
      obj_data.put('coderror', '200');
      obj_row.put(to_char(i-1),obj_data);
      i := i + 1 ;
      v_concat := ', ' ;
    end loop ;
   -----------------------------------------------------
   json_str_output := obj_row.to_clob;
   -----------------------------------------------------
exception when others then
    param_msg_error := get_error_msg_php('HR2020', global_v_lang);
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
end gen_header_report ;
---------------------------------------------------------------
procedure gen_report (json_str_input in clob, json_str_output out clob) as

begin
    -------------------------------------------
    initial_value(json_str_input);
    -------------------------------------------
    if param_msg_error is null then
      gen_report_rec(json_str_output);
      if param_msg_error is not null then
        json_str_output := get_response_message('400', param_msg_error,global_v_lang);
       end if ;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error := get_error_msg_php('HR2020', global_v_lang);
    json_str_output := get_response_message('400', SQLERRM  || ':' || param_msg_error,global_v_lang);
end gen_report ;
---------------------------------------------------------------
---------------------------------------------------------------
procedure gen_report_rec (json_str_output out clob) as
  type array_t is varray(80) of varchar2(200);
  -------------------------------------------
  i                        int ;
  arr_column_name          array_t ;
  v_field_statement        varchar2(4000 char) ;
  v_where_statement        varchar2(4000 char) ;
  v_sort_statement         varchar2(4000 char) ;
  v_group_statement        varchar2(4000 char) ;
  v_distinct_statement     varchar2(100 char) ;
  v_secure_statement       varchar2(4000 char) ;
  v_rep_where              varchar2(4000 char) ;
  v_rep_special            varchar2(4000 char) ;
  v_codview                varchar2(200 char) ;
  v_statement              varchar2(4000 char);
  v_concat                 varchar2(10 char) ;
  v_concat_group           varchar2(10 char) ;
  v_flgdist                varchar2(10 char) ;
  l_cursor                 PLS_INTEGER := DBMS_SQL.open_cursor;
  L_DESCTBL                DBMS_SQL.DESC_TAB2;
  IGNORE                   NUMBER;
  PWFIELD_COUNT            NUMBER DEFAULT 0;
  Z_NUMBER                 NUMBER;
  Z_DATE                   DATE;
  Z_CLOB                   CLOB  ;
  obj_column_header_data   json_object_t;
  obj_row                  json_object_t;
  obj_data                 json_object_t;
  v_rcnt                   number := 0;
  v_rep_sec_table          varchar2(100 char);
  v_cnt_secur              number ;
  json_tquery_obj          json_object_t;
  obj_rep_where            json_object_t;
  json_tqsort_obj          json_object_t;
  json_row                 json_object_t;
  v_flgorder               tqsort.flgorder%type;
  v_flggroup               tqsort.flggroup%type;
  v_rep_field_key          tqsort.rep_field_key%type;
  v_rep_table              tqfield.rep_table%type;
  v_rep_field              tqfield.rep_field%type;
  v_cnt_1                  number ;
  v_cnt_2                  number ;
  v_cnt_3                  number ;
  v_temp                   varchar2(20) ;
  cursor c_tqfield is
         select * from tqfield t where t.rep_id = p_rep_id order by t.num_seq ;
begin
    p_rep_id := hcm_util.get_string_t(json_params,'p_rep_id');
    ------------------------------------------------------------
    select count('x')
    into   v_cnt_secur
    from   tqsecur t
    where  t.rep_id = p_rep_id and t.userrep = global_v_coduser ;
    ----------------------------------------------
    if v_cnt_secur = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang) ;
      json_str_output   := get_response_message('400',param_msg_error, global_v_lang);
      return ;
    end if ;
    ----------------------------------------------
    v_codview := 'V_TQ' || p_rep_id ;
    arr_column_name := array_t() ;
    v_sort_statement   := '' ;
    v_group_statement  := '' ;
    v_where_statement  := '' ;
    i := 1 ;
    obj_column_header_data := json_object_t() ;
    -------------------------------------------
    begin
        select tq.rep_table
        into   v_rep_sec_table
        from   tqtable tq
        where  tq.rep_id = p_rep_id and tq.sec_comp = 'Y' and rownum = 1 ;
    exception when NO_DATA_FOUND then
          v_rep_sec_table := '' ;
    end ;
    -------------------------------------------
    v_secure_statement := '' ;
    -------------------------------------------
    if v_rep_sec_table is not null then
        select SUM(decode(t.codcolmn,'CODCOMP',1,0)) , SUM(decode(t.codcolmn,'NUMLVL',1,0)) , SUM(decode(t.codcolmn,'CODEMPID',1,0))
        into   v_cnt_1 , v_cnt_2 , v_cnt_3
        from   tcoldesc t where t.codtable = UPPER(v_rep_sec_table) ;
        -----------------------------------------
        if ( (v_cnt_1 > 0) AND (v_cnt_2 > 0) )  then
           v_secure_statement := ' and nvl(' || v_rep_sec_table || '_numlvl , ( select t4.numlvl from temploy1 t4 where t4.codempid = ''' || global_v_codempid || ''' )) between ' || global_v_zminlvl || ' and ' || global_v_zwrklvl ||
                                 ' and ( select count(''x'') from tusrcom t2 where t2.coduser = ''' || global_v_coduser || ''' and  ' ||  v_rep_sec_table || '_codcomp like t2.codcomp || ''%'' ) <> 0  ' ;
        elsif (v_cnt_3 > 0) then
           v_codview := v_codview || ',temploy1' ;
           v_where_statement :=  v_rep_sec_table || '_CODEMPID = temploy1.codempid and ' || v_where_statement ;
           v_secure_statement := ' and nvl( temploy1.numlvl , ( select t4.numlvl from temploy1 t4 where t4.codempid = ''' || global_v_codempid || ''' )) between ' || global_v_zminlvl || ' and ' || global_v_zwrklvl ||
                                 ' and ( select count(''x'') from tusrcom t2 where t2.coduser = ''' || global_v_coduser || ''' and nvl(' ||  v_rep_sec_table || '_codcomp,temploy1.codcomp) like  t2.codcomp || ''%'' ) <> 0  ' ;
        elsif (v_cnt_1 > 0) then
           v_secure_statement := ' and ( select count(''x'') from tusrcom t2 where t2.coduser = ''' || global_v_coduser || ''' and ' ||  v_rep_sec_table || '_codcomp like t2.codcomp || ''%'' ) <> 0  ' ;
        end if ;
        -----------------------------------------
    end  if ;
    -------------------------------------------
    for r_tqfield in c_tqfield
    loop
      arr_column_name.extend ;
      arr_column_name(i) := r_tqfield.rep_table || '_' || r_tqfield.rep_field || '_' || TO_CHAR(i)  ;
      if (r_tqfield.cal_name is  null) then
         if r_tqfield.flgchksal = 'Y' then
           v_field_statement := v_field_statement || v_concat ||
                 'decode(HRCOS1X.check_updsal('|| r_tqfield.rep_table || '_CODEMPID , ''' ||  global_v_numlvlsalst || ''' , ''' || global_v_numlvlsalen || ''' ),1,' ||
                 'to_char(stddec(' || r_tqfield.rep_table || '_' || r_tqfield.rep_field || ',' || r_tqfield.rep_table || '_CODEMPID , '''|| global_v_chken ||'''),' ||
                 '''fm999,999,990.00''),null) as ' || arr_column_name(i) ;
         else
           v_field_statement  := v_field_statement || v_concat || r_tqfield.rep_table || '_' || r_tqfield.rep_field || ' as ' || arr_column_name(i) ;
         end if ;
      else
         v_field_statement  := v_field_statement || v_concat || REPLACE(r_tqfield.rep_cal, '.' , '_') || ' as ' || arr_column_name(i) ;
      end if ;
      obj_column_header_data.put(to_char(i-1  ),arr_column_name(i));
      i := i + 1 ;
      v_concat := ', ' ;
    end loop ;
    -------------------------------------------
    json_tquery_obj     := hcm_util.get_json_t(json_params, 'tquery');
    obj_rep_where       := hcm_util.get_json_t(json_tquery_obj, 'rep_where');
    v_rep_where         := hcm_util.get_string_t(obj_rep_where, 'code');
    v_rep_special       := hcm_util.get_string_t(json_tquery_obj, 'rep_special');
    v_flgdist           := hcm_util.get_string_t(json_tquery_obj, 'flgdist');
    -------------------------------------------
    if v_flgdist = 'Y' then
      v_distinct_statement := ' distinct ' ;
    else
      v_distinct_statement := '' ;
    end if ;
    -------------------------------------------
    if v_rep_where is not null then
      v_where_statement := v_where_statement || v_rep_where ;
    else
      v_where_statement := v_where_statement || ' 1=1 ' ;
    end if ;
    if v_rep_special is not null then
      v_where_statement := v_where_statement || ' and ' || v_rep_special ;
    else
      v_where_statement := v_where_statement || ' and ' || ' 1=1 ' ;
    end if ;
    ------------------------------------------
    v_concat           := '' ;
    v_concat_group     := '' ;
    -------------------------------------------
    json_tqsort_obj  := hcm_util.get_json_t(json_params, 'tqsort');
    for i in 0..json_tqsort_obj.get_size - 1 loop
        json_row         := hcm_util.get_json_t(json_tqsort_obj, to_char(i));
        v_flgorder       := hcm_util.get_string_t(json_row, 'flgorder');
        v_flggroup       := hcm_util.get_string_t(json_row, 'flggroup');
        v_rep_field_key  := hcm_util.get_string_t(json_row, 'rep_field_key');
        --------------------------------------------
        select t1.rep_table , t1.rep_field
        into   v_rep_table , v_rep_field
        from   tqfield t1
        where  t1.rep_field_key = v_rep_field_key ;
        --------------------------------------------
        if v_flggroup = 'Y' then
           v_group_statement := v_group_statement || v_concat_group || v_rep_table || '_' || v_rep_field ;
           v_concat_group := ', ' ;
        else
           v_sort_statement := v_sort_statement || v_concat || v_rep_table || '_' || v_rep_field || ' ' || v_flgorder ;
           v_concat := ', ' ;
        end if ;
    end loop ;
    -------------------------------------------
    if LENGTH(v_sort_statement) != 0 then
      v_sort_statement := ' order by ' || v_sort_statement ;
    end if ;
    if LENGTH(v_group_statement) != 0 then
      v_group_statement := ' group by ' || v_group_statement ;
    end if ;

    begin
        -------------------------------------------
        v_statement := 'select ' || v_distinct_statement || ' * from ( select  ' || v_field_statement || ' from ' || v_codview || ' where ' || v_where_statement || ' '  ||  v_secure_statement || ' ' || v_sort_statement || ' ' || v_group_statement || ' )' ;
        -----------------------------------------------------
        obj_row     := json_object_t();
        -----------------------------------------------------
        DBMS_SQL.parse (l_cursor,v_statement,DBMS_SQL.native);
        DBMS_SQL.DESCRIBE_COLUMNS2(l_cursor, PWFIELD_COUNT, L_DESCTBL);
        FOR I IN 1 .. PWFIELD_COUNT LOOP
           IF L_DESCTBL(I).COL_TYPE = 1 THEN
              DBMS_SQL.DEFINE_COLUMN(l_cursor, I, Z_CLOB);
           ELSIF L_DESCTBL(I).COL_TYPE = 2 THEN
              DBMS_SQL.DEFINE_COLUMN(l_cursor, I, Z_NUMBER);
           ELSIF L_DESCTBL(I).COL_TYPE = 12 THEN
              DBMS_SQL.DEFINE_COLUMN(l_cursor, I, Z_DATE);
           END IF ;
       END LOOP;
       IGNORE := DBMS_SQL.EXECUTE(l_cursor);
       LOOP
          IF DBMS_SQL.FETCH_ROWS(l_cursor) > 0 THEN
                 --------------------------------------
                 v_rcnt      := v_rcnt+1;
                 obj_data    := json_object_t();
                 --------------------------------------
                 FOR I IN 1 .. PWFIELD_COUNT LOOP
                    IF L_DESCTBL(I).COL_TYPE = 2 THEN
                       DBMS_SQL.COLUMN_VALUE(l_cursor, I, Z_NUMBER);
                       obj_data.put( arr_column_name(I) , Z_NUMBER);
                    ELSIF L_DESCTBL(I).COL_TYPE = 12 THEN
                       DBMS_SQL.COLUMN_VALUE(l_cursor, I, Z_DATE);
                       v_temp := to_char(Z_DATE,'dd/mm/yyyy hh24:mi:ss') ;
                       if SUBSTR(v_temp, -8) = '00:00:00' then
                         v_temp := REPLACE(v_temp, ' 00:00:00', '');
                       end if ;
                       obj_data.put( arr_column_name(I) ,v_temp );
                    ELSE
                       DBMS_SQL.COLUMN_VALUE(l_cursor, I, Z_CLOB);
                       obj_data.put( arr_column_name(I) , Z_CLOB);
                    END IF ;
                 END LOOP;
                 obj_data.put('coderror', '200');
                 obj_data.put('rowID', v_rcnt);
                 obj_data.put('column' , obj_column_header_data);
                 obj_row.put(to_char(v_rcnt-1),obj_data);
          ELSE
             EXIT;
          END IF;
       END LOOP;
   exception when others then
      param_msg_error := get_error_msg_php('HR2810', global_v_lang);
      return ;
   end ;
   -----------------------------------------------------
   json_str_output := obj_row.to_clob;
   -----------------------------------------------------
end gen_report_rec ;
---------------------------------------------------------------
procedure check_report_secur (json_str_input in clob, json_str_output out clob) as
   obj_data        json ;
   v_cnt_secur    number ;
   v_rep_id       varchar2 (100 char) ;
begin
    -------------------------------------------
    initial_value(json_str_input);
    -------------------------------------------
    begin
      select t.rep_id
      into   v_rep_id
      from   tquery t
      where  upper(t.rep_id) = upper(p_rep_id) ;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang);
      json_str_output := get_response_message('400', param_msg_error,global_v_lang);
      return;
    end;
    ------------------------------------------------------------
    select count('x')
    into   v_cnt_secur
    from   tqsecur t
    where  t.rep_id = p_rep_id and t.userrep = global_v_coduser ;
    ----------------------------------------------
    if v_cnt_secur = 0 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang) ;
      json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
      return ;
    end if ;
    ----------------------------------------------
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('rep_id', p_rep_id);
    ------------------------------------
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
exception when others then
    param_msg_error := get_error_msg_php('HR2020', global_v_lang);
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
end check_report_secur ;

end HRCOS2X;

/

--------------------------------------------------------
--  DDL for Package Body HRCOS1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCOS1X" is
-- last update: 23/04/2020 15:25
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
---------------------------------------------------------------
procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
begin
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
    p_rep_id          := hcm_util.get_string_t(json_obj,'p_rep_id');
    p_codcompy        := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_rep_table       := hcm_util.get_string_t(json_obj,'p_rep_table');
    p_table_name      := hcm_util.get_string_t(json_obj,'p_table_name');

    json_params       := hcm_util.get_json_t(json_obj, 'params');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    global_v_chken    := hcm_secur.get_v_chken ;
end initial_value;
---------------------------------------------------------------
procedure create_treportq (v_rep_id in varchar2) is
    v_codapp         varchar2(200 char) ;
    v_codview        varchar2(200 char) ;
    i                number ;
    j                number ;
    k                number ;
    v_field_search   varchar2(200);
    cursor c_tqtable is
       select * from tqtable t where t.rep_id = v_rep_id ;
    cursor c_tcoldesc(v_rep_table in varchar2) is
       select * from tcoldesc t2 where t2.codtable = v_rep_table order by t2.column_id ;
begin
    i := 0 ;
    k := 0 ;
    v_codapp := 'QY' || v_rep_id ;
    v_codview := 'V_TQ' || v_rep_id ;
    ----------------------------------------------
    delete from treportq where codapp = v_codapp ;
    ----------------------------------------------
    for r_tqtable in c_tqtable
    loop
        i := i + 1 ;
        k := k + 1 ;
        ------------------------------------------
        insert into treportq
          (codapp, numseq, namfld, nambrowe, nambrowt, nambrow3, nambrow4, nambrow5, flgdisp, tblsrh )
        values
          (v_codapp, k /*i*/ , null,
           substr(get_ttabdesc_name(r_tqtable.rep_table,101),4,40) ,
           substr(get_ttabdesc_name(r_tqtable.rep_table,102),4,40) ,
           substr(get_ttabdesc_name(r_tqtable.rep_table,103),4,40) ,
           substr(get_ttabdesc_name(r_tqtable.rep_table,104),4,40) ,
           substr(get_ttabdesc_name(r_tqtable.rep_table,105),4,40) ,
           'Y', r_tqtable.rep_table);
        ------------------------------------------
        j := 0 ;
        for r_tcoldesc in c_tcoldesc( r_tqtable.rep_table)
        loop
            j := j + 1 ;
            k := k + 1 ;
            -----------------------------------------------
            v_field_search    := null;
            if r_tcoldesc.codcolmn = 'CODAPPR' then
              v_field_search    := 'CODEMPID';
            elsif r_tcoldesc.funcdesc is not null then
              v_field_search    := r_tcoldesc.codcolmn;
            end if;

            insert into treportq
              (codapp, numseq, namfld, nambrowe, nambrowt, nambrow3, nambrow4, nambrow5, flgdisp, namtbl, tblsrh, fldsrh, funcdesc, datatype)
            values
              (v_codapp, k /*j*/, r_tcoldesc.codtable || '_' || r_tcoldesc.codcolmn,
               substr(r_tcoldesc.descole,1,40),
               substr(r_tcoldesc.descolt,1,40),
               substr(r_tcoldesc.descol3,1,40),
               substr(r_tcoldesc.descol4,1,40),
               substr(r_tcoldesc.descol5,1,40),
               'Y', v_codview, r_tcoldesc.codtable, v_field_search, r_tcoldesc.funcdesc, r_tcoldesc.data_type);
            -----------------------------------------------
        end loop ;
    end loop ;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end create_treportq ;
---------------------------------------------------------------
procedure save_step_1 (json_str_input in clob, json_str_output out clob) is
    json_tquery_obj     json_object_t;
    json_tqtable_obj    json_object_t;
    v_cnt_table         number ;
    v_cnt_1             number ;
    v_cnt_2             number ;
    v_cnt_3             number ;
    v_flg              varchar2(5) ;
begin
    initial_value (json_str_input);
    if param_msg_error is null then
      ------------------------------------------------------------
       p_rep_id         := hcm_util.get_string_t(json_params,'p_rep_id');
      ------------------------------------------------------------
       json_tquery_obj  := hcm_util.get_json_t(json_params, 'tquery');
       save_tquery_detail (json_tquery_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
       json_tqtable_obj  := hcm_util.get_json_t(json_params, 'tqtable');
       save_tqtable_index (json_tqtable_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
           select count('x')
           into   v_cnt_table
           from   tqtable
           where  rep_id = p_rep_id ;
          ----------------------------------------------
           if v_cnt_table = 0 then
             rollback ;
             param_msg_error := get_error_msg_php('HR2045',global_v_lang) ;
             json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
             return ;
           end if ;
          ------------------------------------------------------------
           select SUM(decode(t.codcolmn,'CODCOMP',1,0)) , SUM(decode(t.codcolmn,'NUMLVL',1,0)) , SUM(decode(t.codcolmn,'CODEMPID',1,0))
           into   v_cnt_1 , v_cnt_2 , v_cnt_3
           from   tcoldesc t where t.codtable in (select UPPER(tt.rep_table) from tqtable tt where tt.rep_id = p_rep_id ) ;
           -----------------------------------------
           if ( (v_cnt_1 > 0) OR (v_cnt_3 > 0) )  then
             v_flg := 'Y' ;
           else
             v_flg := 'N' ;
           end if ;
           -----------------------------------------
           if v_flg = 'Y' then
               select count('x')
               into   v_cnt_table
               from   tqtable t
               where  t.rep_id = p_rep_id and t.sec_comp = 'Y' ;
              ----------------------------------------------
               if v_cnt_table = 0 then
                 rollback ;
                 param_msg_error := get_error_msg_php('HR3090',global_v_lang) ;
                 json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
                 return ;
               end if ;
           end if ;
      ------------------------------------------------------------
       create_treportq (p_rep_id) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
       create_view (p_rep_id) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error , global_v_lang) ;
          return ;
       end if;
      ------------------------------------------------------------
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
exception when others then
    rollback ;
    param_msg_error   := get_error_msg_php('HR2020', global_v_lang);
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
end save_step_1;
---------------------------------------------------------------
procedure save_step_2 (json_str_input in clob, json_str_output out clob) is
    json_tquery_obj     json_object_t;
    json_tqwhere_obj    json_object_t;
    v_cnt_table         number ;
    v_cnt_where         number ;
begin
    initial_value (json_str_input);
    if param_msg_error is null then
      ------------------------------------------------------------
       p_rep_id         := hcm_util.get_string_t(json_params,'p_rep_id');
      ------------------------------------------------------------
       json_tquery_obj  := hcm_util.get_json_t(json_params, 'tquery');
       save_tquery_detail (json_tquery_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
       json_tqwhere_obj  := hcm_util.get_json_t(json_params, 'tqwhere');
       save_tqwhere_index (json_tqwhere_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
      select count('x')
      into   v_cnt_table
      from   tqtable
      where  rep_id = p_rep_id ;
      ----------------------------------------------
      if v_cnt_table > 1 then
         ------------------------------------------
         select count('x')
         into   v_cnt_where
         from   tqwhere
         where  rep_id = p_rep_id ;
         ------------------------------------------
         if v_cnt_where = 0 then
           rollback ;
           param_msg_error := get_error_msg_php('HR2045',global_v_lang) ;
           json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
           return ;
         end if ;
         ------------------------------------------
      end if ;
      ----------------------------------------------
       create_view (p_rep_id) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
exception when others then
    rollback ;
    param_msg_error   := get_error_msg_php('HR2020', global_v_lang);
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
end save_step_2 ;
---------------------------------------------------------------
procedure save_step_3 (json_str_input in clob, json_str_output out clob) is
    json_tqfield_obj    json_object_t;
    json_tqsort_obj     json_object_t;
    json_tquery_obj     json_object_t;
begin
    initial_value (json_str_input);
    if param_msg_error is null then
      ------------------------------------------------------------
       p_rep_id         := hcm_util.get_string_t(json_params,'p_rep_id');
      ------------------------------------------------------------
       json_tquery_obj  := hcm_util.get_json_t(json_params, 'tquery');
       save_tquery_detail (json_tquery_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
       json_tqfield_obj  := hcm_util.get_json_t(json_params, 'tqfield');
       save_tqfield_index (json_tqfield_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
       json_tqsort_obj  := hcm_util.get_json_t(json_params, 'tqsort');
       save_tqsort_index (json_tqsort_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if; 
      ------------------------------------------------------------
       create_view (p_rep_id) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
      check_view (p_rep_id) ;
      if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if; 
      ------------------------------------------------------------
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
exception when others then
    rollback ;
    param_msg_error := get_error_msg_php('HR2020', global_v_lang);
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
end save_step_3;
---------------------------------------------------------------
procedure save_step_4 (json_str_input in clob, json_str_output out clob) is
    json_tquery_obj     json_object_t;
    json_tqsecur_obj    json_object_t;
    v_cnt_secur         number ;
begin
    initial_value (json_str_input);
    if param_msg_error is null then
      ------------------------------------------------------------
       p_rep_id         := hcm_util.get_string_t(json_params,'p_rep_id');
      ------------------------------------------------------------
       json_tquery_obj  := hcm_util.get_json_t(json_params, 'tquery');
       save_tquery_detail (json_tquery_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
       json_tqsecur_obj  := hcm_util.get_json_t(json_params, 'tqsecur');
       save_tqsecur_index (json_tqsecur_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
      select count('x')
      into   v_cnt_secur
      from   tqsecur
      where  rep_id = p_rep_id ;
      ----------------------------------------------
      if v_cnt_secur = 0 then
        rollback ;
        param_msg_error := get_error_msg_php('HR2045',global_v_lang) ;
        json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
        return ;
      end if ;
      ----------------------------------------------
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
exception when others then
    rollback ;
    param_msg_error   := get_error_msg_php('HR2020', global_v_lang);
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
end save_step_4 ;
---------------------------------------------------------------
procedure delete_all_detail (json_str_input in clob, json_str_output out clob) is
    v_codapp         varchar2(200 char) ;
    v_codview        varchar2(200 char) ;
begin
    initial_value (json_str_input);
    v_codapp := 'QY' || p_rep_id ;
    v_codview := 'V_TQ' || p_rep_id ;
    if param_msg_error is null then
      delete from tqsecur t1 where t1.rep_id = p_rep_id ;
      delete from tqsort  t1 where t1.rep_id = p_rep_id ;
      delete from tqfield t1 where t1.rep_id = p_rep_id ;
      delete from tqwhere t1 where t1.rep_id = p_rep_id ;
      delete from tqtable t1 where t1.rep_id = p_rep_id ;
      delete from tquery  t1 where t1.rep_id = p_rep_id ;
      delete from treportq where codapp = v_codapp ;
      commit;
      EXECUTE IMMEDIATE 'drop view ' || v_codview  ;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
exception when others then
    rollback ;
    param_msg_error   := get_error_msg_php('HR2020', global_v_lang);
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
end delete_all_detail;
---------------------------------------------------------------
procedure save_all_detail (json_str_input in clob, json_str_output out clob) is
    json_tqtable_obj    json_object_t;
    json_tqwhere_obj    json_object_t;
    json_tqfield_obj    json_object_t;
    json_tqsort_obj     json_object_t;
    json_tqsecur_obj    json_object_t;
    json_tquery_obj     json_object_t;
begin
    initial_value (json_str_input);
    if param_msg_error is null then
      ------------------------------------------------------------
       json_tquery_obj  := hcm_util.get_json_t(json_params, 'tquery');
       save_tquery_detail (json_tquery_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       p_rep_id := hcm_util.get_string_t(json_tquery_obj, 'rep_id');
      ------------------------------------------------------------
       json_tqtable_obj  := hcm_util.get_json_t(json_params, 'tqtable');
       save_tqtable_index (json_tqtable_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
       json_tqwhere_obj  := hcm_util.get_json_t(json_params, 'tqwhere');
       save_tqwhere_index (json_tqwhere_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
       json_tqfield_obj  := hcm_util.get_json_t(json_params, 'tqfield');
       save_tqfield_index (json_tqfield_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
       json_tqsort_obj  := hcm_util.get_json_t(json_params, 'tqsort');
       save_tqsort_index (json_tqsort_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
       json_tqsecur_obj  := hcm_util.get_json_t(json_params, 'tqsecur');
       save_tqsecur_index (json_tqsecur_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
      ------------------------------------------------------------
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
exception when others then
    rollback ;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
end save_all_detail;
---------------------------------------------------------------
procedure gen_header_report (json_str_input in clob, json_str_output out clob) as

begin
    -------------------------------------------
    initial_value(json_str_input);
    -------------------------------------------
    if param_msg_error is null then
      header_report(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error :=  get_error_msg_php('HR2020', global_v_lang);
    json_str_output := get_response_message('400','gen_report_header dd ' ||  param_msg_error,global_v_lang);
end gen_header_report ;
---------------------------------------------------------------
procedure header_report (json_str_output out clob) as
  type array_t is varray(80) of varchar2(200);
  arr_column_name          array_t ;
  obj_row     json_object_t;
  obj_data  json_object_t;
  i           number ;
  cursor c_tqfield is
    select * from tqfield t where t.rep_id = p_rep_id order by t.num_seq ;
begin
    -------------------------------------------
    i := 1 ;
    arr_column_name := array_t() ;
    obj_row := json_object_t();

    for r_tqfield in c_tqfield
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
    end loop ;
   -----------------------------------------------------
   json_str_output  := obj_row.to_clob;
   -----------------------------------------------------
end header_report ;
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
    param_msg_error := get_error_msg_php('HR2020', global_v_lang);  --
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
end gen_report ;
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
  v_secure_statement        varchar2(4000 char) ;
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
  v_rep_id                 varchar2(100 char);
  v_rep_sec_table          varchar2(100 char);
  v_cnt_secur              number ;
  v_cnt_1                  number ;
  v_cnt_2                  number ;
  v_cnt_3                  number ;
  v_temp                   varchar2(20) ;
  cursor c_tqfield is
    select * from tqfield t where t.rep_id = p_rep_id order by t.num_seq ;

  cursor c_tqsort is
    select t1.rep_table , t1.rep_field , t.flgorder , t.flggroup from tqsort t , tqfield t1 where t.rep_field_key = t1.rep_field_key and t1.rep_id = v_rep_id  order by t.num_seq ;
begin
    v_rep_id := p_rep_id ;
    ------------------------------------------------------------
    select count('x')
    into   v_cnt_secur
    from   tqsecur
    where  rep_id = p_rep_id ;
    ----------------------------------------------
    if v_cnt_secur = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang) ;
      json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
      return ;
    end if ;
    ----------------------------------------------
    v_codview := 'V_TQ' || v_rep_id ;
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
      where  tq.rep_id = v_rep_id and tq.sec_comp = 'Y' and rownum = 1 ;
    exception when NO_DATA_FOUND then
      v_rep_sec_table := '' ;
    end ;
    -------------------------------------------
    v_concat := '' ;
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
    select t.rep_where , t.rep_special
    into   v_rep_where , v_rep_special
    from   tquery t
    where  t.rep_id = v_rep_id ;
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
    for r_tqsort in c_tqsort
    loop
      if r_tqsort.flggroup = 'Y' then
         v_group_statement := v_group_statement || v_concat_group || r_tqsort.rep_table || '_' || r_tqsort.rep_field ;
         v_concat_group    := ', ' ;
      else
         v_sort_statement  := v_sort_statement || v_concat || r_tqsort.rep_table || '_' || r_tqsort.rep_field || ' ' || r_tqsort.flgorder ;
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
    -------------------------------------------
    select t.flgdist
    into   v_flgdist
    from   tquery t
    where  t.rep_id = v_rep_id ;
    -------------------------------------------
    if v_flgdist = 'Y' then
      v_distinct_statement := ' distinct ' ;
    else
      v_distinct_statement := '' ;
    end if ;
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
    v_statement := 'select ' || v_distinct_statement || ' * from ( select  ' || v_field_statement || ' from ' || v_codview || ' where ' || v_where_statement || v_secure_statement ||
                                                                   v_sort_statement || ' ' || v_group_statement || ' )' ;
     --param_msg_error := v_statement ;
     --return ;
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
   -----------------------------------------------------
   json_str_output  := obj_row.to_clob;
   -----------------------------------------------------
end gen_report_rec ;
---------------------------------------------------------------
procedure create_view (v_rep_id in varchar2) is
  v_statement       clob  ; --  dbms_sql.varchar2a; --varchar2(4000 char);
  v_concat            varchar2(10 char);
  cursor c_tqtable is
         select * from tqtable t2 where t2.rep_id = v_rep_id order by t2.num_seq ;
  cursor c_tqwhere is
         select * from tqwhere t3 where t3.rep_id = v_rep_id order by t3.num_seq ;
  cursor c_tqtable_2 is
         select * from tqtable t where t.rep_id = v_rep_id ;
  cursor c_tcoldesc(v_rep_table in varchar2) is
         select t2.* 
           from user_tab_cols t1,tcoldesc t2 
          where t1.table_name   = t2.codtable
            and t1.column_name  = t2.codcolmn
            and t2.codtable     = v_rep_table
          order by t2.column_id ;
begin
  v_statement := 'CREATE OR REPLACE VIEW V_TQ' || v_rep_id || ' AS SELECT ' ;
  v_concat    := '';
    ----------------------------------------------
  for r_tqtable in c_tqtable_2
  loop
      for r_tcoldesc in c_tcoldesc(r_tqtable.rep_table)
      loop
        v_statement := v_statement ||  v_concat || r_tcoldesc.codtable || '.' || r_tcoldesc.codcolmn || ' as ' || r_tcoldesc.codtable || '_' || r_tcoldesc.codcolmn ;
        v_concat    := ',';
      end loop;
  end loop;
  v_statement := v_statement || ' FROM ' ;
  v_concat    := '';
  FOR r_tqtable IN c_tqtable
  LOOP
    v_statement := v_statement ||  v_concat || r_tqtable.rep_table ;
    v_concat    := ',';
  END LOOP;
  v_concat      := ' WHERE ';
  FOR r_tqwhere IN c_tqwhere
  LOOP
    v_statement := v_statement ||  v_concat || r_tqwhere.table_where1 || '.' || r_tqwhere.field_where1 || ' = ' || r_tqwhere.table_where2 || '.' || r_tqwhere.field_where2 ;
    if r_tqwhere.flgjoin = 'Y' then
      v_statement := v_statement || '(+)' ;
    end if ;
    v_concat    := ' AND ';
  END LOOP;
  v_statement   := v_statement || ' ';
  EXECUTE IMMEDIATE v_statement ;
exception when others then
    param_msg_error := get_error_msg_php('HR2055', global_v_lang) ;
end create_view ;
---------------------------------------------------------------

procedure check_view (v_rep_id in varchar2) is
  type array_t is varray(80) of varchar2(200);
  i                        int ;
  arr_column_name          array_t ;
  v_field_statement        varchar2(4000 char) ;
  v_where_statement        varchar2(4000 char) ;
  v_sort_statement         varchar2(4000 char) ;
  v_group_statement        varchar2(4000 char) ;
  v_rep_where              varchar2(4000 char) ;
  v_rep_special            varchar2(4000 char) ;
  v_codview                varchar2(200 char) ;
  v_statement       clob  ;   
  v_concat                 varchar2(10 char) ;
  v_concat_group           varchar2(10 char) ;
  cursor c_tqfield is
    select * from tqfield t where t.rep_id = p_rep_id order by t.num_seq ;  
  cursor c_tqsort is
    select t1.rep_table , t1.rep_field , t.flgorder , t.flggroup from tqsort t , tqfield t1 where t.rep_field_key = t1.rep_field_key and t1.rep_id = v_rep_id  order by t.num_seq ;
begin

    v_codview := 'V_TQ' || v_rep_id ;    
    arr_column_name := array_t() ;
    v_concat := '' ;   
    i := 1 ;
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
      i := i + 1 ;
      v_concat := ', ' ;
    end loop ;
    -------------------------------------------        
    v_where_statement  := '' ;
    -------------------------------------------    
    select t.rep_where , t.rep_special
    into   v_rep_where , v_rep_special
    from   tquery t
    where  t.rep_id = v_rep_id ;
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
    -------------------------------------------    
    v_concat           := '' ;
    v_concat_group     := '' ;
    -------------------------------------------
    for r_tqsort in c_tqsort
    loop
      if r_tqsort.flggroup = 'Y' then
         v_group_statement := v_group_statement || v_concat_group || r_tqsort.rep_table || '_' || r_tqsort.rep_field ;
         v_concat_group    := ', ' ;
      else
         v_sort_statement  := v_sort_statement || v_concat || r_tqsort.rep_table || '_' || r_tqsort.rep_field || ' ' || r_tqsort.flgorder ;
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
    -------------------------------------------   
    v_statement := 'select count(''x'') from ( select  ' || v_field_statement || ' from ' || v_codview || ' where ' || v_where_statement || 
                                                                   v_sort_statement || ' ' || v_group_statement || ' )' ;
     --    param_msg_error := v_statement ;
     -- return ;
    EXECUTE IMMEDIATE v_statement ;
    -----------------------------------------------------
exception when others then
    param_msg_error := get_error_msg_php('HR2810', global_v_lang) ;
end check_view ;  

procedure save_tquery_detail (json_tquery_obj in json_object_t  , param_msg_error out varchar2) is
    v_flg               varchar2(100 char);
    v_rep_id            tquery.rep_id%type;
    v_rep_desc          tquery.rep_desce%type;
    v_rep_desce         tquery.rep_desce%type;
    v_rep_desct         tquery.rep_desct%type;
    v_rep_desc3         tquery.rep_desc3%type;
    v_rep_desc4         tquery.rep_desc4%type;
    v_rep_desc5         tquery.rep_desc5%type;
    v_rep_where         tquery.rep_where%type;
    v_rep_special       tquery.rep_special%type;
    v_statement         tquery.statement%type;
    v_flgdist           tquery.flgdist%type;
    obj_rep_where       json_object_t;
begin
    v_flg               := hcm_util.get_string_t(json_tquery_obj, 'flg');
    v_rep_id            := hcm_util.get_string_t(json_tquery_obj, 'rep_id');
    v_rep_desc          := hcm_util.get_string_t(json_tquery_obj, 'rep_desc');
    v_rep_desce         := hcm_util.get_string_t(json_tquery_obj, 'rep_desce');
    v_rep_desct         := hcm_util.get_string_t(json_tquery_obj, 'rep_desct');
    v_rep_desc3         := hcm_util.get_string_t(json_tquery_obj, 'rep_desc3');
    v_rep_desc4         := hcm_util.get_string_t(json_tquery_obj, 'rep_desc4');
    v_rep_desc5         := hcm_util.get_string_t(json_tquery_obj, 'rep_desc5');
    v_rep_special       := hcm_util.get_string_t(json_tquery_obj, 'rep_special');
    obj_rep_where       := hcm_util.get_json_t(json_tquery_obj, 'rep_where');
    v_rep_where         := hcm_util.get_string_t(obj_rep_where, 'code');
    v_statement         := hcm_util.get_string_t(obj_rep_where, 'statement');
    v_flgdist           := hcm_util.get_string_t(json_tquery_obj, 'flgdist');

    if global_v_lang = '101' then
      v_rep_desce := v_rep_desc;
    elsif global_v_lang = '102' then
      v_rep_desct := v_rep_desc;
    elsif global_v_lang = '103' then
      v_rep_desc3 := v_rep_desc;
    elsif global_v_lang = '104' then
      v_rep_desc4 := v_rep_desc;
    elsif global_v_lang = '105' then
      v_rep_desc5 := v_rep_desc;
    end if;

    if v_flg = 'delete' then
        delete from tquery t where t.rep_id = v_rep_id ;
    else
        update tquery
        set    rep_desce = v_rep_desce,
               rep_desct = v_rep_desct,
               rep_desc3 = v_rep_desc3,
               rep_desc4 = v_rep_desc4,
               rep_desc5 = v_rep_desc5,
               dteupd = sysdate,
               coduser = global_v_coduser ,
               rep_where = v_rep_where  ,
               rep_special = v_rep_special ,
               statement = v_statement,
               flgdist = v_flgdist
        where  rep_id = v_rep_id;
    end if;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tquery_detail ;
---------------------------------------------------------------
procedure save_tqtable_index (json_tqtable_obj in json_object_t  , param_msg_error out varchar2) is
    json_tqtable_obj_rows    json_object_t;
    json_row            json_object_t;
    v_flg               varchar2(100 char);
    v_rep_id            tqtable.rep_id%type;
    v_rep_table         tqtable.rep_table%type;
    v_sec_comp          tqtable.sec_comp%type;
    next_num_seq        number ;
begin
    json_tqtable_obj_rows := json_tqtable_obj ;
    -------------------------------------------
    select nvl(max(t.num_seq) ,0) + 1
    into   next_num_seq
    from   tqtable t
    where  t.rep_id = v_rep_id ;
    ------------------------------------------
    for i in 0..json_tqtable_obj_rows.get_size - 1 loop
      json_row          := hcm_util.get_json_t(json_tqtable_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string_t(json_row, 'flg');

      if p_rep_id is not null then
        v_rep_id := p_rep_id ;
      else
        v_rep_id := hcm_util.get_string_t(json_row, 'rep_id') ;
      end if;
      v_rep_table         := hcm_util.get_string_t(json_row, 'rep_table');
      v_sec_comp          := hcm_util.get_string_t(json_row, 'sec_comp');
      if v_flg = 'delete' then
          delete from tqtable t where t.rep_id = v_rep_id and t.rep_table = v_rep_table ;
      else
         begin
              insert into tqtable
                (rep_id, rep_table, sec_comp, num_seq , dteupd, coduser )
              values
                (v_rep_id, v_rep_table, nvl(v_sec_comp,'N') , next_num_seq , sysdate, global_v_coduser );
              next_num_seq := next_num_seq + 1 ;
         exception when DUP_VAL_ON_INDEX then
              update tqtable
                 set sec_comp = v_sec_comp,
                     dteupd = sysdate,
                     coduser = global_v_coduser
               where rep_id = v_rep_id
                 and rep_table = v_rep_table;
         end;
      end if;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tqtable_index ;
---------------------------------------------------------------
procedure save_tqwhere_index (json_tqwhere_obj in json_object_t , param_msg_error out varchar2) is
    json_row            json_object_t;
    json_tqwhere_obj_rows json_object_t;
    v_flg               varchar2(100 char);
    v_rep_id            tqwhere.rep_id%type;
    v_table_field_where1 varchar2(1000 char) ;
    v_table_field_where2 varchar2(1000 char) ;
    v_table_where1      tqwhere.table_where1%type;
    v_field_where1      tqwhere.field_where1%type;
    v_table_where2      tqwhere.table_where2%type;
    v_field_where2      tqwhere.field_where2%type;
    v_flgjoin           tqwhere.flgjoin%type;
begin
    json_tqwhere_obj_rows :=  json_tqwhere_obj ;
    for i in 0..json_tqwhere_obj_rows.get_size - 1 loop
      json_row          := hcm_util.get_json_t(json_tqwhere_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string_t(json_row, 'flg');
      if p_rep_id is not null then
        v_rep_id := p_rep_id ;
      else
        v_rep_id := hcm_util.get_string_t(json_row, 'rep_id');
      end if;


      v_table_field_where1 := hcm_util.get_string_t(json_row, 'table_field_where1');
      v_table_field_where2 := hcm_util.get_string_t(json_row, 'table_field_where2');
      v_table_where1    := SUBSTR(v_table_field_where1, 0, instr (v_table_field_where1, '.', -1) -1 ) ;
      v_field_where1    := SUBSTR(v_table_field_where1, instr (v_table_field_where1, '.', -1) + 1 , length(v_table_field_where1)) ;
      v_table_where2    := SUBSTR(v_table_field_where2, 0, instr (v_table_field_where2, '.', -1) -1 ) ;
      v_field_where2    := SUBSTR(v_table_field_where2, instr (v_table_field_where2, '.', -1) + 1 , length(v_table_field_where2)) ;
      v_flgjoin         := hcm_util.get_string_t(json_row, 'flgjoin');

      if v_flg = 'delete' then
          delete tqwhere
          where  rep_id = v_rep_id
                 and table_where1 = v_table_where1
                 and field_where1 = v_field_where1
                 and table_where2 = v_table_where2
                 and field_where2 = v_field_where2 ;
      else
         begin
              insert into tqwhere
                  (rep_id, table_where1, field_where1, table_where2, field_where2, flgjoin, dtecreate, codcreate, dteupd, coduser)
              values
                  (v_rep_id, v_table_where1, v_field_where1, v_table_where2, v_field_where2, nvl(v_flgjoin,'N') , sysdate, global_v_coduser, sysdate, global_v_coduser);

         exception when DUP_VAL_ON_INDEX then
              update tqwhere
              set    flgjoin = v_flgjoin,
                     dteupd = sysdate,
                     coduser = global_v_coduser
              where  rep_id = v_rep_id
                     and table_where1 = v_table_where1
                     and field_where1 = v_field_where1
                     and table_where2 = v_table_where2
                     and field_where2 = v_field_where2;
         end;
      end if;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tqwhere_index ;
---------------------------------------------------------------
procedure save_tqfield_index (json_tqfield_obj in json_object_t , param_msg_error out varchar2) is
    json_row            json_object_t;
    json_tqfield_obj_rows json_object_t;
    v_flg               varchar2(100 char);
    v_rep_id            tqfield.rep_id%type;
    v_rep_table         tqfield.rep_table%type;
    v_rep_field         tqfield.rep_field%type;
    v_num_seq           tqfield.num_seq%type;
    v_rep_func          tqfield.rep_func%type;
    v_cal_name          tqfield.cal_name%type;
    v_rep_cal           tqfield.rep_cal%type;
    v_flgdisp           tqfield.flgdisp%type;
    v_data_type         tqfield.data_type%type;
    v_data_scale        tqfield.data_scale%type;
    v_flgchksal         tqfield.flgchksal%type;
    v_rep_fiesal        tqfield.rep_fiesal%type;
    v_rep_field_key     tqfield.rep_field_key%type;
begin
    --------------------------------------------------
    delete tqfield
    where  rep_id = p_rep_id ;
    --------------------------------------------------
    json_tqfield_obj_rows := hcm_util.get_json_t(json_tqfield_obj,'rows');
    for i in 0..json_tqfield_obj_rows.get_size - 1 loop
      json_row          := hcm_util.get_json_t(json_tqfield_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string_t(json_row, 'flg');
      if p_rep_id is not null then
        v_rep_id := p_rep_id ;
      else
        v_rep_id := hcm_util.get_string_t(json_row, 'rep_id');
      end if;
      v_rep_table       := hcm_util.get_string_t(json_row, 'rep_table');
      v_rep_field       := hcm_util.get_string_t(json_row, 'rep_field');
      v_num_seq         := hcm_util.get_string_t(json_row, 'num_seq');
      v_rep_func        := hcm_util.get_string_t(json_row, 'rep_func');
      v_cal_name        := hcm_util.get_string_t(json_row, 'cal_name');
      v_rep_cal         := hcm_util.get_string_t(json_row, 'rep_cal');
      v_flgdisp         := hcm_util.get_string_t(json_row, 'flgdisp');
      v_data_type       := hcm_util.get_string_t(json_row, 'data_type');
      v_data_scale      := hcm_util.get_string_t(json_row, 'data_scale');
      ------------------------------------------
      begin
        select st1.flgchksal
        into   v_flgchksal
        from   tcoldesc st1
        where  st1.codtable = v_rep_table and st1.codcolmn = v_rep_field ;
      exception when no_data_found then
        v_flgchksal := '' ; --v_flgchksal       := hcm_util.get_string_t(json_row, 'flgchksal');
      end ;
      ------------------------------------------
      v_rep_fiesal      := hcm_util.get_string_t(json_row, 'rep_fiesal');
      v_rep_field_key   := hcm_util.get_string_t(json_row, 'rep_field_key');
      ------------------------------------------
      insert into tqfield
        (rep_id, rep_table, rep_field, num_seq, rep_func, cal_name, rep_cal, flgdisp, data_type,
         data_scale, flgchksal, dteupd, coduser, rep_fiesal,rep_field_key)
      values
        (v_rep_id, v_rep_table, v_rep_field, v_num_seq, v_rep_func, v_cal_name, v_rep_cal, v_flgdisp, v_data_type,
         v_data_scale, v_flgchksal, sysdate, global_v_coduser, v_rep_fiesal,v_rep_field_key);
      ------------------------------------------
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tqfield_index ;
---------------------------------------------------------------
procedure save_tqsort_index (json_tqsort_obj in json_object_t , param_msg_error out varchar2) is
    json_row            json_object_t;
    json_tqsort_obj_rows json_object_t;
    v_flg               varchar2(100 char);
    v_rep_id            tqsort.rep_id%type;
    v_num_seq           tqsort.num_seq%type;
    v_rep_field         tqsort.rep_field%type;
    v_flgorder          tqsort.flgorder%type;
    v_flggroup          tqsort.flggroup%type;
    v_numseq            tqsort.numseq%type;
    v_rep_field_key     tqsort.rep_field_key%type;
begin
    json_tqsort_obj_rows := json_tqsort_obj ;
    for i in 0..json_tqsort_obj_rows.get_size - 1 loop
      json_row          := hcm_util.get_json_t(json_tqsort_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string_t(json_row, 'flg');
      if p_rep_id is not null then
        v_rep_id := p_rep_id ;
      else
        v_rep_id := hcm_util.get_string_t(json_row, 'rep_id');
      end if;
      v_num_seq       := hcm_util.get_string_t(json_row, 'num_seq');
      v_rep_field       := hcm_util.get_string_t(json_row, 'rep_field');
      v_flgorder       := hcm_util.get_string_t(json_row, 'flgorder');
      v_flggroup       := hcm_util.get_string_t(json_row, 'flggroup');
      v_numseq         := hcm_util.get_string_t(json_row, 'numseq');
      v_rep_field_key  := hcm_util.get_string_t(json_row, 'rep_field_key');
      if v_flg = 'delete' then
          delete tqsort
           where rep_id = v_rep_id
             and num_seq = v_num_seq;
      elsif v_flg = 'add' then
          select nvl(max(num_seq),0)+1
          into   v_numseq
          from   tqsort
          where  rep_id = v_rep_id ;
          --------------------------------------
          insert into tqsort
            (rep_id, num_seq, rep_field, flgorder, flggroup, numseq, dteupd, coduser,rep_field_key)
          values
            (v_rep_id, v_numseq , v_rep_field, v_flgorder, nvl(v_flggroup,'N'), v_numseq, sysdate, global_v_coduser,v_rep_field_key);
      else
          update tqsort
             set rep_id = v_rep_id,
                 num_seq = v_num_seq,
                 rep_field = v_rep_field,
                 flgorder = v_flgorder,
                 flggroup = v_flggroup,
                 numseq = v_numseq,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where rep_id = v_rep_id
             and num_seq = v_num_seq;
      end if;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tqsort_index ;
---------------------------------------------------------------
procedure save_tqsecur_index (json_tqsecur_obj in json_object_t , param_msg_error out varchar2) is
    json_row            json_object_t;
    json_tqsecur_obj_rows json_object_t;
    v_flg               varchar2(100 char);
    v_rep_id            tqsecur.rep_id%type;
    v_userrep           tqsecur.userrep%type;
begin
    json_tqsecur_obj_rows := json_tqsecur_obj ;
    for i in 0..json_tqsecur_obj_rows.get_size - 1 loop
      json_row          := hcm_util.get_json_t(json_tqsecur_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string_t(json_row, 'flg');
      if p_rep_id is not null then
        v_rep_id := p_rep_id ;
      else
        v_rep_id := hcm_util.get_string_t(json_row, 'rep_id');
      end if;
      v_userrep       := hcm_util.get_string_t(json_row, 'userrep');
      if v_flg = 'delete' then
         delete tqsecur
         where rep_id = v_rep_id
               and userrep = v_userrep;
      else
         begin
              insert into tqsecur
                (rep_id, userrep, dtecreate , codcreate ,  dteupd , coduser )
              values
                (v_rep_id, v_userrep, sysdate , global_v_coduser , sysdate ,global_v_coduser);
         exception when DUP_VAL_ON_INDEX then
              update tqsecur
              set    rep_id = v_rep_id,
                     userrep = v_userrep,
                     dteupd = sysdate,
                     coduser =  global_v_coduser
              where  rep_id = v_rep_id
                     and userrep = v_userrep;
         end;
      end if;
    end loop;
    ----------------------------------------------
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tqsecur_index ;
---------------------------------------------------------------
procedure search_n_create_tquery (json_str_input in clob, json_str_output out clob) is
    obj_data               json_object_t;
    v_rep_desc           tquery.rep_desce%type;
    v_rep_desce          tquery.rep_desce%type;
    v_rep_desct          tquery.rep_desct%type;
    v_rep_desc3          tquery.rep_desc3%type;
    v_rep_desc4          tquery.rep_desc4%type;
    v_rep_desc5          tquery.rep_desc5%type;
    v_rep_id             tquery.rep_id%type;
    v_rep_where          tquery.rep_where%type;
    v_rep_special        tquery.rep_special%type;
    v_statement          tquery.statement%type;
    v_flgdist            tquery.flgdist%type;
begin
    initial_value(json_str_input);
    -------------------------------------------------------
    begin
          select t.rep_id ,
                 decode(global_v_lang,  '101', rep_desce,
                                        '102', rep_desct,
                                        '103', rep_desc3,
                                        '104', rep_desc4,
                                        '105', rep_desc5,
                                        rep_desce) as rep_desc ,
                 t.rep_desce , t.rep_desct , t.rep_desc3 , t.rep_desc4 , t.rep_desc5 ,
                 t.rep_where  , t.rep_special , t.statement , t.flgdist
          into   v_rep_id , v_rep_desc , v_rep_desce , v_rep_desct , v_rep_desc3 , v_rep_desc4 , v_rep_desc5 ,
                 v_rep_where  , v_rep_special , v_statement , v_flgdist
          from   tquery t
          where  t.rep_id = p_rep_id ;
    exception when NO_DATA_FOUND then
          insert into tquery (rep_id , dteupd , coduser )
          values (p_rep_id , sysdate , global_v_coduser) ;
          commit;
    end ;

    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('rep_id', p_rep_id);
    obj_data.put('rep_desc', v_rep_desc);
    obj_data.put('rep_desce', v_rep_desce);
    obj_data.put('rep_desct', v_rep_desct);
    obj_data.put('rep_desc3', v_rep_desc3);
    obj_data.put('rep_desc4', v_rep_desc4);
    obj_data.put('rep_desc5', v_rep_desc5);
    obj_data.put('rep_where', v_rep_where);
    obj_data.put('rep_special', v_rep_special);
    obj_data.put('statement', v_statement);
    obj_data.put('description', get_logical_desc(v_statement));
    obj_data.put('flgdist', v_flgdist);

    json_str_output := obj_data.to_clob;

exception when others then
    rollback;
    param_msg_error   :=  dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',p_rep_id||' '||global_v_lang||''||v_rep_desc||''|| param_msg_error, global_v_lang);
end search_n_create_tquery;
---------------------------------------------------------------
procedure get_tqtable_index(json_str_input in clob, json_str_output out clob) as
begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tqtable_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_tqtable_index;
---------------------------------------------------------------
procedure gen_tqtable_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;
    v_cnt       number ;
    cursor c_tqtable is
      select t.rep_id , t.rep_table , t.num_seq , t.sec_comp , t2.comments
      from tqtable t left join user_tab_comments t2 on t.rep_table = t2.TABLE_NAME
      where t.rep_id = p_rep_id
      order by t.num_seq;
begin
    obj_row     := json_object_t();
    for r_tqtable in c_tqtable loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('rep_table', r_tqtable.rep_table);
      obj_data.put('num_seq', r_tqtable.num_seq);
      obj_data.put('sec_comp', r_tqtable.sec_comp);
      obj_data.put('sec_comp_', r_tqtable.sec_comp);
      obj_data.put('rep_id', r_tqtable.rep_id);
      obj_data.put('typmatch', r_tqtable.rep_table);
      obj_data.put('nammatch', r_tqtable.rep_table || ' ' || r_tqtable.comments);
      ---------------------------------------
      select count('x')
      into   v_cnt
      from   sys.USER_TAB_COLS t
      where  t.table_name = upper(r_tqtable.rep_table) and
             t.column_name like '%CODEMPID%' and
             t.char_length = 10 and
             rownum = 1;
      ---------------------------------------
      if v_cnt = 0 then
        obj_data.put('sec_flg', 'N');
      else
        obj_data.put('sec_flg', 'Y');
      end if ;
      ---------------------------------------
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
end gen_tqtable_index;
----------------------------------------------------------------------------------
procedure get_column_table(json_str_input in clob, json_str_output out clob) as
begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_column_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_column_table;
---------------------------------------------------------------
procedure gen_column_table(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;
    cursor c_tab_columns is
        select t1.TABLE_NAME , t1.COLUMN_NAME ,
               get_tcoldesc_name (t1.TABLE_NAME  ,t1.COLUMN_NAME ,global_v_lang ) as COMMENTS
        from   user_tab_columns t1
        left join user_col_comments t2 on t1.TABLE_NAME = t2.TABLE_NAME and t1.COLUMN_NAME = t2.COLUMN_NAME
        where  t1.TABLE_NAME = p_rep_table order by t1.COLUMN_ID ;
begin
    obj_row     := json_object_t();
    for r_tab_columns in c_tab_columns loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('table_name', r_tab_columns.table_name);
      obj_data.put('column_name', r_tab_columns.column_name);
      obj_data.put('comments', r_tab_columns.comments);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
end gen_column_table;
---------------------------------------------------------------
procedure get_tqwhere_index(json_str_input in clob, json_str_output out clob) as
begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tqwhere_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_tqwhere_index;
---------------------------------------------------------------
procedure gen_tqwhere_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;
    cursor c_tqwhere is
      select t.rep_id , t.table_where1 , t.field_where1 , t.table_where2 , t.field_where2 , t.flgjoin
      from   tqwhere t
      where  t.rep_id = p_rep_id ;
begin
    obj_row     := json_object_t();
    for r_tqwhere in c_tqwhere loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('rep_id', r_tqwhere.rep_id);
      obj_data.put('table_where1', r_tqwhere.table_where1);
      obj_data.put('field_where1', r_tqwhere.field_where1);
      obj_data.put('table_field_where1',r_tqwhere.table_where1 || '.' || r_tqwhere.field_where1);
      obj_data.put('table_where2', r_tqwhere.table_where2);
      obj_data.put('field_where2', r_tqwhere.field_where2);
      obj_data.put('table_field_where2',r_tqwhere.table_where2 || '.' || r_tqwhere.field_where2);
      obj_data.put('flgjoin', r_tqwhere.flgjoin);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
end gen_tqwhere_index;
----------------------------------------------------------------------------------
procedure get_tqfield_index(json_str_input in clob, json_str_output out clob) as
begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tqfield_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_tqfield_index;
---------------------------------------------------------------
procedure gen_tqfield_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;
    cursor c_tqfield is
      select  rep_id, rep_table, rep_field, num_seq, rep_func, cal_name, rep_cal,
              flgdisp, data_type, data_scale, flgchksal, rep_fiesal ,rep_field_key
      from    tqfield
      where   rep_id = p_rep_id
      order by num_seq ;
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
      obj_data.put('rep_table', r_tqfield.rep_table);
      obj_data.put('rep_field', r_tqfield.rep_field);
      obj_data.put('num_seq', r_tqfield.num_seq);
      obj_data.put('rep_func', r_tqfield.rep_func);
      obj_data.put('cal_name', r_tqfield.cal_name);
      obj_data.put('rep_cal', r_tqfield.rep_cal);
      obj_data.put('flgdisp', r_tqfield.flgdisp);
      obj_data.put('data_type', r_tqfield.data_type);
      obj_data.put('data_scale', r_tqfield.data_scale);
      obj_data.put('flgchksal', r_tqfield.flgchksal);
      obj_data.put('rep_fiesal', r_tqfield.rep_fiesal);
      obj_data.put('rep_field_key', r_tqfield.rep_field_key);
      obj_data.put('description', get_tcoldesc_name (r_tqfield.rep_table ,r_tqfield.rep_field ,global_v_lang ) );

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
end gen_tqfield_index;
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
---------------------------------------------------------------
procedure gen_tqsort_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;
    cursor c_tqsort is
      select t1.rep_id, t1.num_seq, t1.rep_field, t1.flgorder, t1.flggroup, t1.numseq ,t1.rep_field_key ,
             t2.rep_table
      from   tqsort t1 left join tqfield t2 on t1.rep_field_key = t2.rep_field_key and t1.rep_field = t2.rep_field
      where  t1.rep_id = p_rep_id
      order by t1.num_seq;
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
----------------------------------------------------------------------------------
procedure get_tqsecur_index(json_str_input in clob, json_str_output out clob) as
begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tqsecur_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_tqsecur_index;
---------------------------------------------------------------
procedure gen_tqsecur_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;
    cursor c_tqsecur is
      select rep_id, userrep
      from   tqsecur
      where  rep_id = p_rep_id ;
begin
    obj_row       := json_object_t();
    for r_tqsecur in c_tqsecur loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('rep_id', r_tqsecur.rep_id);
      obj_data.put('userrep', r_tqsecur.userrep);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
end gen_tqsecur_index;
----------------------------------------------------------------------------------
procedure get_user_indexes_index(json_str_input in clob, json_str_output out clob) as
begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_user_indexes_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_user_indexes_index;
---------------------------------------------------------------
procedure gen_user_indexes_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;
    cursor c_user_indexes is
      select t.INDEX_NAME ,
             st1.list_column_name ,
             t.UNIQUENESS
      from   user_indexes t
             left join ( SELECT st1.table_name , st1.index_name , LISTAGG(st1.COLUMN_NAME, ',') WITHIN GROUP (ORDER BY st1.COLUMN_POSITION) AS list_column_name
                         FROM user_ind_columns st1
                         GROUP BY st1.TABLE_NAME , st1.INDEX_NAME ) st1 on upper(st1.TABLE_NAME) = upper(t.TABLE_NAME) and st1.INDEX_NAME = t.INDEX_NAME
      where  t.TABLE_NAME = p_table_name
      order by decode(t.UNIQUENESS,'1','2') ;
begin
    obj_row     := json_object_t();
    for r_user_indexes in c_user_indexes loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('index_name', r_user_indexes.index_name);
      obj_data.put('list_column_name', r_user_indexes.list_column_name);
      obj_data.put('uniqueness', r_user_indexes.uniqueness);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
end gen_user_indexes_index;
---------------------------------------------------------------
procedure get_user_tab_columns_index(json_str_input in clob, json_str_output out clob) as
begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_user_tab_columns_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_user_tab_columns_index;
---------------------------------------------------------------
procedure gen_user_tab_columns_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;
    cursor c_user_tab_columns is

      select t1.COLUMN_NAME ,
             t1.DATA_TYPE ,
             ( CASE
                  WHEN t1.DATA_TYPE = 'VARCHAR2' THEN  'X(' || to_char(t1.CHAR_LENGTH) || ')'
                  WHEN t1.DATA_TYPE = 'CHAR'     THEN  'X(' || to_char(t1.CHAR_LENGTH) || ')'
                  WHEN t1.DATA_TYPE = 'DATE'     THEN  '99/99/9999'
                  WHEN t1.DATA_TYPE = 'BOOLEAN'  THEN  'YES/NO'
                  WHEN t1.DATA_TYPE = 'NUMBER' AND (nvl(t1.DATA_PRECISION,0) <> 0) AND (nvl(t1.DATA_SCALE,0) <> 0 ) THEN
                                        TO_CHAR(LPAD ('9', t1.DATA_PRECISION, 9),'999,999,999,999,999,999,999,999') || '.' || LPAD ('9', t1.DATA_SCALE, 9)
                  WHEN t1.DATA_TYPE = 'NUMBER' AND (nvl(t1.DATA_PRECISION,0) <> 0) THEN
                                        TO_CHAR(LPAD ('9', t1.DATA_PRECISION, 9),'999,999,999,999,999,999,999,999')
                  ELSE ''

             END ) format ,
             get_tcoldesc_name (t1.TABLE_NAME  ,t1.COLUMN_NAME ,global_v_lang ) as COMMENTS
      from   user_tab_columns t1 , user_col_comments t2
      where  t1.COLUMN_NAME = t2.COLUMN_NAME
             and t1.TABLE_NAME = t2.TABLE_NAME
             and t1.TABLE_NAME = p_table_name
      order by t1.COLUMN_ID ;
begin
    obj_row     := json_object_t();
    for r_user_tab_columns in c_user_tab_columns loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('column_name', r_user_tab_columns.column_name);
      obj_data.put('data_type', r_user_tab_columns.data_type);
      obj_data.put('format', r_user_tab_columns.format);
      obj_data.put('comments', r_user_tab_columns.comments);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
end gen_user_tab_columns_index;
---------------------------------------------------------------
  procedure check_secure (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_check_secure(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end check_secure;

----------------------------------------------------------------------------------
  procedure gen_check_secure (json_str_output out clob) is
    obj_data        json_object_t;
    v_flg           varchar2(1 char);
    v_cnt_1           number ;
    v_cnt_2           number ;
    v_cnt_3           number ;
    ----------------------------------
  begin
     -----------------------------------------
     select SUM(decode(t.codcolmn,'CODCOMP',1,0)) , SUM(decode(t.codcolmn,'NUMLVL',1,0)) , SUM(decode(t.codcolmn,'CODEMPID',1,0))
     into   v_cnt_1 , v_cnt_2 , v_cnt_3
     from   tcoldesc t where t.codtable = UPPER(p_rep_table) ;
     -----------------------------------------
     if ( (v_cnt_1 > 0) OR (v_cnt_3 > 0) )  then
       v_flg := 'Y' ;
     else
       v_flg := 'N' ;
     end if ;
     -----------------------------------------
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('rep_table', p_rep_table);

      obj_data.put('flg', v_flg);
     ------------------------------------
     json_str_output    := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_check_secure;

end HRCOS1X;

/

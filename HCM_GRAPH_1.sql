--------------------------------------------------------
--  DDL for Package Body HCM_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_GRAPH" IS

  procedure get_hcm_graph_params(json_str_input in clob, json_str_output out clob) as
    json_obj      json_object_t;
    v_codempid    ttemprpt.codempid%type;
    v_codapp      ttemprpt.codapp%type;

    obj_data      json_object_t;
    obj_row       json_object_t;
    obj_item1     json_object_t;
    obj_item2     json_object_t;
    obj_item3     json_object_t;
    obj_row_item1 json_object_t;
    obj_row_item2 json_object_t;
    obj_row_item3 json_object_t;
    v_row_item1   number := 0;
    v_row_item2   number := 0;
    v_row_item3   number := 0;
    v_item1       varchar2(600 char);
    v_item2       varchar2(600 char);
    v_labelx      varchar2(600 char);
    v_labely      varchar2(600 char);

  cursor c_1 is
    select distinct(item1), item6, item9, item14
    from ttemprpt
    where codempid = v_codempid and codapp = v_codapp
    order by item14, item1;

  cursor c_2 is
    select distinct(item2), item12
     from ttemprpt
    where codempid = v_codempid
      and codapp = v_codapp
      and nvl(item1, '#@!$') = nvl(v_item1, '#@!$')
      and item2 is not null
    order by item12;

  cursor c_3 is
    select distinct(item3) ,item13
     from ttemprpt
    where codempid = v_codempid
      and codapp = v_codapp
      and item1 = v_item1
      and item2 = v_item2
      and item3 is not null
    order by item13;

    cursor c_4 is
    select item11
     from ttemprpt
    where codempid = v_codempid
      and codapp = v_codapp
    order by item11;


  begin
    json_obj := json_object_t(json_str_input);
    v_codempid := hcm_util.get_string_t(json_obj, 'p_codempid');
    v_codapp := hcm_util.get_string_t(json_obj, 'p_codapp');

    obj_row := json_object_t();
    obj_data := json_object_t();

    obj_item1 := json_object_t();
    obj_item2 := json_object_t();
    obj_item3 := json_object_t();
    obj_row_item1 := json_object_t();
    v_row_item1 := 0;
    for r_1 in c_1 loop
      v_row_item1 := v_row_item1 + 1;
      v_item1 := r_1.item1;
      v_row_item2 := 0;
      obj_row_item2 := json_object_t();
      for r_2 in c_2 loop
        v_row_item2 := v_row_item2 + 1;
        obj_item2.put('data', r_2.item2);
        v_item2 := r_2.item2;
        v_row_item3 := 0;
        obj_row_item3 := json_object_t();
        for r_3 in c_3 loop
          v_row_item3 := v_row_item3 + 1;
          obj_item3.put('data', r_3.item3);
          obj_row_item3.put(to_char(v_row_item3 - 1), obj_item3);
        end loop;
        obj_item2.put('item3', obj_row_item3);
        obj_row_item2.put(to_char(v_row_item2 - 1), obj_item2);
      end loop;
      obj_item1.put('labelx', r_1.item6);
      obj_item1.put('labely', r_1.item9);
      obj_item1.put('data', r_1.item1);
      obj_item1.put('item2', obj_row_item2);
      obj_row_item1.put(to_char(v_row_item1 - 1), obj_item1);
    end loop;
    obj_data.put('item1', obj_row_item1);
    obj_data.put('coderror', '200');

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_hcm_graph_params;

  procedure get_hcm_graph(json_str_input in clob, json_str_output out clob) is
    v_codapp      varchar2(10 char);
    v_codempid    varchar2(10 char);

    type arr_string is table of varchar2(1000 char) index by binary_integer;
      arr_filter_key  arr_string;
      arr_filter_val  arr_string;
    v_filter_index number := 0;
    v_x_key       varchar2(4000 char);
    v_x_val       varchar2(4000 char);

    v_y_key       varchar2(4000 char);
    v_y_val       varchar2(4000 char);

    v_statement   varchar2(4000 char);
    v_select      varchar2(4000 char);
    v_where       varchar2(4000 char) := '';

    dataRows      SYS_REFCURSOR;

    json_obj                json_object_t;
    json_obj_param_json     json_object_t;
    json_obj_filters        json_object_t;
    json_obj_filter         json_object_t;

    v_row         number := 0;
    obj_row       json_object_t;
    obj_data      json_object_t;

    v_key         varchar(600 char);
    v_val         varchar(600 char);
  BEGIN
    json_obj := json_object_t(json_str_input);
    json_obj_param_json  := hcm_util.get_json_t(json_obj, 'param_json');
    v_codempid := hcm_util.get_string_t(json_obj, 'p_codempid'); -- 53100
    json_obj_filters  := hcm_util.get_json_t(json_obj_param_json, 'filter');
    v_x_key := hcm_util.get_string_t(json_obj_param_json, 'x_key'); -- item4
    v_y_key := hcm_util.get_string_t(json_obj_param_json, 'y_key'); -- item5
    v_codapp := hcm_util.get_string_t(json_obj_param_json, 'codapp'); -- HRAL3EX

    obj_row  := json_object_t();

    for i in 0..json_obj_filters.get_size-1 loop
      json_obj_filter := hcm_util.get_json_t(json_obj_filters, to_char(i));
      v_key := hcm_util.get_string_t(json_obj_filter, 'key');
      v_val := hcm_util.get_string_t(json_obj_filter, 'val');
      if nvl(v_val, '#@!$') <> '#@!$' then
        arr_filter_key(v_filter_index) := v_key;
        arr_filter_val(v_filter_index) := v_val;
        v_filter_index := v_filter_index + 1;
      end if;
    end loop;

    for i in 0..arr_filter_key.count - 1 loop
      v_where := v_where || arr_filter_key(i) || ' = ''' || arr_filter_val(i) || ''' and ';
    end loop;

    v_statement := 'select item5, item10 ' ||
                   'from ttemprpt ' ||
                   'where ' || v_where || 'codapp = ''' || v_codapp || ''' and codempid = ''' || v_codempid || '''';

    open dataRows for v_statement;
    loop
      fetch dataRows into v_x_val, v_y_val;
      exit when dataRows%notfound;
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', 200);
      obj_data.put('x_val', v_x_val);
      obj_data.put('y_val', v_y_val);
      obj_row.put(to_char(v_row - 1), obj_data);
    end loop;
    close dataRows;

    json_str_output := obj_row.to_clob;
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
  END get_hcm_graph;

  procedure get_hcm_graph_multi_chart(json_str_input in clob, json_str_output out clob) is
    v_codapp      varchar2(10 char);
    v_codempid    varchar2(10 char);

    type arr_string is table of varchar2(1000 char) index by binary_integer;
      arr_filter_key  arr_string;
      arr_filter_val  arr_string;
    v_filter_index number := 0;

    v_x_val       varchar2(4000 char);
    v_y_val       varchar2(4000 char);

    v_statement_obj_row_xval  varchar2(4000 char);
    --<<Nut
    v_statement_obj_row_xval2 varchar2(4000 char);
    v_chkdata                 varchar2(1 char);
    v_statement_data2         varchar2(4000 char);
    -->>Nut
    v_statement_obj_row_yval  varchar2(4000 char);
    v_statement_data          varchar2(4000 char);
    v_where       varchar2(4000 char) := '';

    json_obj              json_object_t;
    json_obj_param_json   json_object_t;
    json_obj_filters      json_object_t;
    json_obj_filter       json_object_t;

    v_key         varchar(600 char);
    v_val         varchar(600 char);

    cursor_obj_row_xval     SYS_REFCURSOR;
    cursor_data             sys_refcursor;
    cursor_obj_row_yval     SYS_REFCURSOR;

    v_item4       varchar2(1000 char);
    v_item7       varchar2(1000 char);
    v_item8       varchar2(1000 char);
    v_numseq      varchar2(1000 char);
    v_item10      varchar2(1000 char);
    v_item31      ttemprpt.item31%type;

    v_row_xval    number := 0;
    v_row_yval    number := 0;
    v_row_data    number := 0;
    obj_data      json_object_t;
    obj_row_xval  json_object_t;
    obj_row_yval  json_object_t;
    obj_row_data  json_object_t;
    obj_data_yval json_object_t;
  begin
    json_obj := json_object_t(json_str_input);
    json_obj_param_json  := hcm_util.get_json_t(json_obj, 'param_json');
    v_codempid := hcm_util.get_string_t(json_obj, 'p_codempid'); -- 53100
    json_obj_filters  := hcm_util.get_json_t(json_obj_param_json, 'filter');
    v_codapp := hcm_util.get_string_t(json_obj_param_json, 'codapp'); -- HRAL3EX
    begin
     select item31 into v_item31
      from ttemprpt
      where codempid = v_codempid
      and codapp = v_codapp
      group by item31 ;
       exception when no_data_found then
       v_item31    := null;
    end;

    for i in 0..json_obj_filters.get_size-1 loop
      json_obj_filter := hcm_util.get_json_t(json_obj_filters, to_char(i));
      v_key := hcm_util.get_string_t(json_obj_filter, 'key');
      v_val := hcm_util.get_string_t(json_obj_filter, 'val');
      if nvl(v_val, '#@!$') <> '#@!$' then
        arr_filter_key(v_filter_index) := v_key;
        arr_filter_val(v_filter_index) := v_val;
        v_filter_index := v_filter_index + 1;
      end if;
    end loop;

    for i in 0..arr_filter_key.count - 1 loop
      v_where := v_where || arr_filter_key(i) || ' = ''' || arr_filter_val(i) || ''' and ';
    end loop;

    obj_data := json_object_t();
    obj_row_xval := json_object_t();

--    --<<User37 #7505 1. RP Module 17/01/2022
--    v_statement_obj_row_xval := 'select distinct to_number(item4) item4, item5 from (select to_number(item4) item4, item5 from ttemprpt ' ||
--                   'where ' || v_where || 'codapp = ''' || v_codapp || ''' and codempid = ''' || v_codempid || ''') order by to_number(item4)';
--    v_statement_obj_row_xval := 'select distinct item4, item5 from (select item4, item5 from ttemprpt ' ||
--                   'where ' || v_where || 'codapp = ''' || v_codapp || ''' and codempid = ''' || v_codempid || ''') order by item4';
--    -->>User37 #7505 1. RP Module 17/01/2022

    --<<User37 #7505 1. RP Module 19/01/2022 เพราะกระทบกราฟที่เป็นปีไม่สามารถเรียงได้ #7495
    /*open cursor_obj_row_xval for v_statement_obj_row_xval;
    loop
      fetch cursor_obj_row_xval into v_item4, v_x_val;

      exit when cursor_obj_row_xval%notfound;
      v_row_xval := v_row_xval + 1;
      obj_row_xval.put(to_char(v_row_xval - 1), v_x_val);
    end loop;
    close cursor_obj_row_xval;*/
    v_statement_obj_row_xval := 'select distinct to_number(item4) item4, item5 from (select to_number(item4) item4, item5 from ttemprpt ' ||
                   'where ' || v_where || 'codapp = ''' || v_codapp || ''' and codempid = ''' || v_codempid || ''') order by to_number(item4)';
    v_statement_obj_row_xval2 := 'select distinct item4, item5 from (select item4, item5 from ttemprpt ' ||
                   'where ' || v_where || 'codapp = ''' || v_codapp || ''' and codempid = ''' || v_codempid || ''') order by item4';

    v_chkdata := 'Y';
    begin
      open cursor_obj_row_xval for v_statement_obj_row_xval;
      loop
        fetch cursor_obj_row_xval into v_item4, v_x_val;

        exit when cursor_obj_row_xval%notfound;
        v_row_xval := v_row_xval + 1;
        obj_row_xval.put(to_char(v_row_xval - 1), v_x_val);
      end loop;
      close cursor_obj_row_xval;
    exception when others then
      v_chkdata := 'N';
    end;

    if v_chkdata = 'N' then
      open cursor_obj_row_xval for v_statement_obj_row_xval2;
      loop
        fetch cursor_obj_row_xval into v_item4, v_x_val;

        exit when cursor_obj_row_xval%notfound;
        v_row_xval := v_row_xval + 1;
        obj_row_xval.put(to_char(v_row_xval - 1), v_x_val);
      end loop;
      close cursor_obj_row_xval;
    end if;
    -->>User37 #7505 1. RP Module 19/01/2022 เพราะกระทบกราฟที่เป็นปีไม่สามารถเรียงได้ #7495

    obj_row_yval := json_object_t();
    v_statement_obj_row_yval := 'select distinct item7, item8 from (select item7, item8 from ttemprpt ' ||
                   'where ' || v_where || 'codapp = ''' || v_codapp || ''' and codempid = ''' || v_codempid || ''') order by item7';
    open cursor_obj_row_yval for v_statement_obj_row_yval;
    loop
      fetch cursor_obj_row_yval into v_item7, v_item8 ;
      exit when cursor_obj_row_yval%notfound;
      v_row_yval := v_row_yval + 1;
      obj_data_yval := json_object_t();
      obj_row_data  := json_object_t();
      v_row_data := 0;
      v_statement_data := 'select item10 from ttemprpt ' ||
                     'where ' || v_where || 'item8 = ''' || v_item8 || ''' and codapp = ''' || v_codapp || ''' and codempid = ''' || v_codempid || '''';

      --<<User37 #7505 1. RP Module 19/01/2022 เพราะกระทบกราฟที่เป็นปีไม่สามารถเรียงได้ #7495
      /*v_statement_data := v_statement_data || 'order by item4, item7';--User37 #7505 1. RP Module 17/01/2022 v_statement_data := v_statement_data || 'order by to_number(item4), item7';
      open cursor_data for v_statement_data;
      loop
        fetch cursor_data into v_item10;
        exit when cursor_data%notfound;
        v_row_data := v_row_data + 1;
        obj_row_data.put(to_char(v_row_data - 1), v_item10);
      end loop;
      close cursor_data;*/
      v_statement_data2 := v_statement_data || 'order by item4, item7';
      if v_codapp in ('HRBFS4X') then  -- #8760 5. BF HRBFS4X order data false
          v_statement_data  := v_statement_data || ' order by numseq, to_number(item4), item7';
      else
          v_statement_data  := v_statement_data || ' order by to_number(item4), item7';
      end if;
      v_chkdata := 'Y';
      begin
        open cursor_data for v_statement_data;
        loop
          fetch cursor_data into v_item10;
          exit when cursor_data%notfound;
          v_row_data := v_row_data + 1;
          obj_row_data.put(to_char(v_row_data - 1), v_item10);
        end loop;
        close cursor_data;
      exception when others then
        v_chkdata := 'N';
      end;
      if v_chkdata = 'N' then
        open cursor_data for v_statement_data2;
        loop
          fetch cursor_data into v_item10;
          exit when cursor_data%notfound;
          v_row_data := v_row_data + 1;
          obj_row_data.put(to_char(v_row_data - 1), v_item10);
        end loop;
        close cursor_data;
      end if;
      -->>User37 #7505 1. RP Module 19/01/2022 เพราะกระทบกราฟที่เป็นปีไม่สามารถเรียงได้ #7495
      obj_data_yval.put('label', v_item8);
      obj_data_yval.put('data', obj_row_data);
      obj_row_yval.put(to_char(v_row_yval - 1), obj_data_yval);
    end loop;
    close cursor_obj_row_yval;

    obj_data.put('coderror', '200');
    obj_data.put('header_label', v_item31);
    obj_data.put('x_val', obj_row_xval);
    obj_data.put('y_val', obj_row_yval);

    json_str_output := obj_data.to_clob;
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    obj_data.put('desc_coderror',dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    json_str_output := obj_data.to_clob;
  end get_hcm_graph_multi_chart;

end hcm_graph;

/

--------------------------------------------------------
--  DDL for Package Body HRCO41D
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO41D" is
-- last update: 19/03/2021 20:15 Error Program #5081

 procedure initial_value(json_str in clob) is
    json_obj   json := json(json_str);
  begin
    global_v_coduser  := json_ext.get_string(json_obj,'p_coduser');
    global_v_codempid := json_ext.get_string(json_obj,'p_codempid');
    global_v_lang     := json_ext.get_string(json_obj,'p_lang');

    p_codempid          := upper(hcm_util.get_string(json_obj, 'p_codempid'));
    p_codcompy        := json_ext.get_string(json_obj,'p_codcompy');
    p_codcomp         := json_ext.get_string(json_obj,'p_codcomp');

    p_codsys         := json_ext.get_string(json_obj,'p_codsys');
    json_params         := hcm_util.get_json(json_obj, 'params');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
----------------------------------------------------------------------------------
  procedure get_tcontdel_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tcontdel_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tcontdel_index;
----------------------------------------------------------------------------------
  procedure gen_tcontdel_index (json_str_output out clob) is
    obj_data            json;
    obj_row             json;
    v_rcnt              number := 0;
    v_dtedel            varchar2(100 char);
    v_mm_dtedel         number;
    v_yyyy_dtedel       number;
    --v_stmt              varchar2(4000 char);
    v_where_con         varchar2(4000 char);
    --v_cnt               number;
    v_sum_del_cnt       number;
    cursor c_tcontdel is
       select  decode(global_v_lang, '101', st1.descripte,
                                     '102', st1.descriptt,
                                     '103', st1.descript3,
                                     '104', st1.descript4,
                                     '105', st1.descript5,
                                      st1.descripte) as codsys_descript ,
               st1.descripte as codsys_descripte ,st1.descriptt as codsys_descriptt ,
               st1.descript3 as codsys_descript3 , st1.descript4 as codsys_descript4 ,st1.descript5 as codsys_descript5 ,
               t.codsys,
               to_number(to_char( last_day(add_months(sysdate,(( t.qtymonth +1) * -1))),'mm')) as mm_dtedel ,
               to_number(to_char( last_day(add_months(sysdate,(( t.qtymonth +1) * -1))),'yyyy')) as yyyy_dtedel ,
               t.codcompy ,
               t.numseq ,
               ( select st1.item3
                 from   ttemprpt st1
                 where  st1.codempid = global_v_codempid and
                        st1.codapp = 'HRCO41D_DT' and
                        st1.item1 = t.codsys and
                        st1.item2 = t.numseq and
                        rownum = 1 ) as total_del
       from    tcontdel t left join tdelmain st1 on st1.codsys = t.codsys and st1.numseq = t.numseq
       where   t.codsys = p_codsys and t.codcompy = p_codcompy  ;

    cursor c_tdeltabh (v_codsys in varchar2, v_numseq in varchar2) is
       select t2.codtable , t2.deswhere
       from   tdeltabh t2
       where  t2.codsys = v_codsys and t2.numseq = v_numseq ;

  begin
    obj_row     := json();
    for r_tcontdel in c_tcontdel loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('codsys', r_tcontdel.codsys);
      obj_data.put('codsys_descript', r_tcontdel.codsys_descript);
      obj_data.put('codsys_descripte', r_tcontdel.codsys_descripte);
      obj_data.put('codsys_descriptt', r_tcontdel.codsys_descriptt);
      obj_data.put('codsys_descript3', r_tcontdel.codsys_descript3);
      obj_data.put('codsys_descript4', r_tcontdel.codsys_descript4);
      obj_data.put('codsys_descript5', r_tcontdel.codsys_descript5);
      obj_data.put('mm_dtedel', r_tcontdel.mm_dtedel);
      obj_data.put('yyyy_dtedel', r_tcontdel.yyyy_dtedel);
      obj_data.put('codcompy', r_tcontdel.codcompy);
      obj_data.put('numseq', r_tcontdel.numseq);
      ------------------------------------------------------------
      v_sum_del_cnt := 0 ;
      for r_tdeltabh in  c_tdeltabh (r_tcontdel.codsys ,r_tcontdel.numseq)
      loop
          -------------------------------------------------
          select to_char( last_day(add_months(sysdate,(( t.qtymonth +1) * -1))) ,'dd/mm/yyyy') as dtedel ,
                 to_number(to_char( last_day(add_months(sysdate,(( t.qtymonth +1) * -1))),'mm')) as mm_dtedel ,
                 to_number(to_char( last_day(add_months(sysdate,(( t.qtymonth +1) * -1))),'yyyy')) as yyyy_dtedel
          into   v_dtedel ,
                 v_mm_dtedel ,
                 v_yyyy_dtedel
          from   tcontdel t
          where  t.codcompy = r_tcontdel.codcompy and t.codsys = r_tcontdel.codsys and rownum = 1;
          -------------------------------------------------
          v_where_con := r_tdeltabh.deswhere ;
          v_where_con := replace(v_where_con,'#CODCOMPY',''''|| r_tcontdel.codcompy || '''') ;
          v_where_con := replace(v_where_con,'#CODCOMP' ,''''|| p_codcomp|| '%' || '''') ;
          v_where_con := replace(v_where_con,'#YEAR',''''|| v_yyyy_dtedel || '''') ;
          v_where_con := replace(v_where_con,'#DATE', 'to_date('''|| v_dtedel || ''',''dd/mm/yyyy'')') ;
          --begin
          --   v_stmt := 'select count(''x'') from ' || r_tdeltabh.codtable || ' where ' || v_where_con  ;
          --   EXECUTE IMMEDIATE v_stmt into v_cnt ;
          --exception when others then
          --   v_cnt := 0 ;
          --end ;
          --v_sum_del_cnt := v_sum_del_cnt + v_cnt ;
          -------------------------------------------------
     end loop ;
     ------------------------------------------------------------
     obj_data.put('total_del_row', r_tcontdel.total_del ); --v_sum_del_cnt
     obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    ----------------------------------------
    delete from ttemprpt where codempid = global_v_codempid and upper(codapp) like upper('HRCO41D_DT') || '%';
    ----------------------------------------
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_tcontdel_index;
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
  procedure condel_tdeltblh_index (json_str_input in clob, json_str_output out clob) is
    json_row            json;
    i        number;
    v_flg               varchar2(100 char);
    v_where_con         varchar2(4000 char);
    v_select_con        varchar2(4000 char);
    v_stmt              varchar2(4000 char);
    v_codsys            tdeltabh.codsys%type;
    v_numseq            tdeltabh.numseq%type;
    v_codcompy          tcontdel.codcompy%type;
    v_dtedel            varchar2(100 char);
    v_mm_dtedel         number;
    v_yyyy_dtedel       number;
    v_temp_del_count    number;
    v_sum_del_count     number;
    v_del_numseq        number;
    v_rpt_codapp        varchar2(255 char);
    cursor c_tdeltabh is
       SELECT codsys , numseq , codtable , deswhere
       from   tdeltabh
       where  codsys = v_codsys and
              numseq = v_numseq
       order by numseq ;
  begin

    initial_value (json_str_input);

    if param_msg_error is null then
      -----------------------------------------------
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
        if param_msg_error is not null then
          json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
          return;
        end if;
      -----------------------------------------------
      v_del_numseq := 0;
      for i in 0..json_params.count - 1 loop
        json_row          := hcm_util.get_json(json_params, to_char(i));
        v_flg             := hcm_util.get_string(json_row, 'flg');
        v_codsys          := hcm_util.get_string(json_row, 'codsys');
        v_codcompy         := hcm_util.get_string(json_row, 'codcompy');
        v_numseq         := hcm_util.get_string(json_row, 'numseq');
        ------------------------------------------------------------------------
        if v_flg = 'delete' then
           v_sum_del_count := 0 ;
           for r_tdeltabh in c_tdeltabh
           LOOP
               ------------------------------------------------------------------------
               select to_char( last_day(add_months(sysdate,(( t.qtymonth +1) * -1))) ,'dd/mm/yyyy') as dtedel ,
                      to_number(to_char( last_day(add_months(sysdate,(( t.qtymonth +1) * -1))),'mm')) as mm_dtedel ,
                      to_number(to_char( last_day(add_months(sysdate,(( t.qtymonth +1) * -1))),'yyyy')) as yyyy_dtedel
               into   v_dtedel ,
                      v_mm_dtedel ,
                      v_yyyy_dtedel
               from   tcontdel t
             where  t.codcompy = v_codcompy and t.codsys = v_codsys --and rownum = 1;
--<<redmine5081
                 and  t.numseq    = v_numseq;
-->>redmine5081
               ------------------------------------------------------------------------
               v_where_con :=  r_tdeltabh.deswhere ;
               v_where_con := replace(v_where_con,'#CODCOMPY',''''|| v_codcompy || '''') ;
               v_where_con := replace(v_where_con,'#CODCOMP',''''|| p_codcomp|| '%'  || '''') ;
               v_where_con := replace(v_where_con,'#YEAR',''''|| v_yyyy_dtedel || '''') ;
               v_where_con := replace(v_where_con,'#DATE', 'to_date('''|| v_dtedel || ''',''dd/mm/yyyy'')') ;
               ------------------------------------------------------------------------
               if r_tdeltabh.codtable in ('TEMPLOY1','TLEAVETR','TLEAVSUM','TOBFINF','TOBFSUM') then
                 begin
                     ------------------------------------------------------------------------
                     select LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY column_name)
                     into   v_select_con
                     from   user_tab_columns
                     where  table_name = r_tdeltabh.codtable and COLUMN_NAME != 'CODCREATE'
                     order by column_Id ;
                     ------------------------------------------------------------------------
                     v_stmt := 'insert into ' || r_tdeltabh.codtable || '_BCKUP (' || v_select_con || ' , DTEDEL , CODCREATE ) select ' || v_select_con || ' , SYSDATE , ''' || global_v_coduser || ''' from ' || r_tdeltabh.codtable || ' where ' || v_where_con  ;
                     EXECUTE IMMEDIATE v_stmt ;
                 exception when others then
                     rollback;
                     param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                     json_str_output := get_response_message('400', param_msg_error, global_v_lang);
                     return;
                 end;
               end if ;
               ------------------------------------------------------------------------
               begin
                   v_stmt := 'select count(''x'') from ' || r_tdeltabh.codtable || ' where ' || v_where_con  ;

                   EXECUTE IMMEDIATE v_stmt INTO v_temp_del_count ;

--Error Program5317
--inser t_temp2('BALL','HRCO41D',r_tdeltabh.codsys ,r_tdeltabh.codtable,v_stmt, 'x='||v_temp_del_count , null ,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
--Error Program5317

                   v_sum_del_count := v_sum_del_count + v_temp_del_count ;
                   v_stmt := 'delete from ' || r_tdeltabh.codtable || ' where ' || v_where_con  ;
--Error Program5317
--insert _temp2('BALL','HRCO41D',r_tdeltabh.codsys ,r_tdeltabh.codtable,v_stmt, null , null ,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
--Error Program5317

                   EXECUTE IMMEDIATE v_stmt ;

               exception when others then
                  rollback;
                  param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                  json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
                  return;
               end;
               ------------------------------------------------------------------------
           end loop;
           ------------------------------------------------------------------------
           v_del_numseq := v_del_numseq + 1 ;
           v_rpt_codapp := 'HRCO41D_DT' ;
           insert into ttemprpt ( codempid, codapp, numseq,
                                  item1, item2, item3 )
           values ( global_v_codempid, v_rpt_codapp, v_del_numseq,
                    v_codsys, v_numseq, v_sum_del_count );
           ------------------------------------------------------------------------
        end if ;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end condel_tdeltblh_index;

end HRCO41D;

/

--------------------------------------------------------
--  DDL for Package Body HRCO2PE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2PE" is
-- last update: 09/02/2021 14:01 #2331

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_codapp          := (hcm_util.get_string_t(json_obj, 'p_codapp'));
    p_numseq          := (hcm_util.get_string_t(json_obj, 'p_numseq')); --:= json_ext.get_string(json_obj,'p_numseq');
    -- save index
    json_params         := hcm_util.get_json_t(json_obj, 'params');

  end initial_value;
----------------------------------------------------------------------------------
  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
----------------------------------------------------------------------------------
  procedure gen_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    obj_result  json_object_t;
    v_rcnt      number := 0;

    cursor c_tfwmailh is
            SELECT t.codapp ,
                   t.codform ,
                   (select count(*) from TFWMAILC where codapp = t.codapp) as approvno
            FROM   tfwmailh t
            ORDER BY t.CODAPP ;
  begin
    obj_row     := json_object_t();
    obj_result  := json_object_t();
    for r_tfwmailh in c_tfwmailh loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('codapp', p_codapp);

        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('rcnt', v_rcnt);

        obj_data.put('codapp', r_tfwmailh.codapp);
        obj_data.put('codapp_desc', get_tappprof_name(r_tfwmailh.codapp,1,global_v_lang) );
        obj_data.put('codform', r_tfwmailh.codform);
        obj_data.put('approvno', r_tfwmailh.approvno);

        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_index;
----------------------------------------------------------------------------------
  procedure get_detail(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;
----------------------------------------------------------------------------------
  procedure gen_detail (json_str_output out clob) is
    obj_data                json_object_t;
    obj_main                json_object_t;
    obj_detail              json_object_t;
    obj_table               json_object_t;
    v_codform               tfwmailh.codform%type;
    v_codappap              tfwmailh.codappap%type;
    v_typform               tappprof.typform%type;
    v_codformno             tfwmailh.codformno%type;
    v_row                   number := 0;
    
    cursor c_tfwmailc is
        SELECT t.codapp, t.numseq, t.syncond,
               get_logical_desc(t.statement) as syncond_name ,
               t.statement,
               (select count(*) 
                  from tfwmaild st1 
                 where st1.codapp = t.codapp 
                   and st1.numseq = t.numseq ) as cnt_maild
          FROM tfwmailc t
         WHERE t.codapp = p_codapp
      ORDER BY t.codapp, t.numseq ;    
    
  begin
    begin
      select t.codform , t.codappap, codformno
        into v_codform , v_codappap,v_codformno
        from tfwmailh t
       where t.codapp = p_codapp ;
    exception when others then
        v_codform       := null;
        v_codappap      := null;
        v_codformno     := null;
    end;
    
    begin
        select typform
          into v_typform
          from tappprof
         where codapp = p_codapp;
    exception when others then
        v_typform := null;
    end;
    
    obj_detail          := json_object_t();
    obj_detail.put('codapp', p_codapp);
    obj_detail.put('codform', v_codform);
    obj_detail.put('codappap', v_codappap);
    obj_detail.put('codformno', v_codformno);
    obj_detail.put('typform', v_typform);
    
    obj_table           := json_object_t();
    for r_tfwmailc in c_tfwmailc loop
        v_row           := v_row + 1;
        obj_data        := json_object_t();
        obj_data.put('codapp', p_codapp);
        obj_data.put('numseq', to_char(r_tfwmailc.numseq));
        obj_data.put('codapp', r_tfwmailc.codapp);
        obj_data.put('syncond_name', r_tfwmailc.syncond_name);
        obj_data.put('cnt_maild', r_tfwmailc.cnt_maild);
        obj_table.put(to_char(v_row-1),obj_data);
    end loop;
    
    obj_main            := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('detail', obj_detail);
    obj_main.put('table', obj_table);
    
    json_str_output := obj_main.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;
----------------------------------------------------------------------------------
  procedure get_detail2(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail2(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail2;
----------------------------------------------------------------------------------
  procedure gen_detail2 (json_str_output out clob) is
    obj_data                json_object_t;
    obj_main                json_object_t;
    obj_detail              json_object_t;
    obj_table               json_object_t;
    obj_child               json_object_t;
    obj_child_data          json_object_t;
    obj_syncond             json_object_t;
    v_codform               tfwmailh.codform%type;
    v_codappap              tfwmailh.codappap%type;
    v_typform               tappprof.typform%type;
    v_codformno             tfwmailh.codformno%type;
    v_row                   number := 0;
    v_seqno                 number;
    v_child_data            number;
    
    cursor c_tfwmailc is
        SELECT t.codapp, t.numseq, t.syncond,
               get_logical_desc(t.statement) as syncond_name ,
               t.statement
          FROM tfwmailc t
         WHERE t.codapp = p_codapp
           and t.numseq = p_numseq;    

    cursor c_tfwmaild is
        select t.codapp, t.numseq, t.seqno
          from tfwmaild t
         where t.codapp = p_codapp
           and t.numseq = p_numseq ;

    cursor c_tfwmaile is
        select e.numseq,e.seqno,e.approvno,e.flgappr,
               e.codcompap,e.codposap,e.codempap
          from tfwmaile e
         where e.codapp = p_codapp
           and e.numseq = p_numseq
           and e.seqno = v_seqno;
  begin
    obj_detail          := json_object_t();
    obj_detail.put('codapp', p_codapp);
    obj_detail.put('numseq', p_numseq);
    for r_tfwmailc in c_tfwmailc loop
        obj_syncond     := json_object_t();
        obj_syncond.put('code', r_tfwmailc.syncond);
        obj_syncond.put('description', r_tfwmailc.syncond_name);
        obj_syncond.put('statement', r_tfwmailc.statement);
        obj_detail.put('syncond', obj_syncond);
    end loop;
    
    obj_table           := json_object_t();
    v_row   := 0;
    for r_tfwmaild in c_tfwmaild loop
        v_row       := v_row + 1;
        obj_data     := json_object_t();
        obj_data.put('coderror', 200);
        obj_data.put('codapp', p_codapp);
        obj_data.put('numseq', r_tfwmaild.numseq);
        obj_data.put('rcnt', 1);
        obj_data.put('seqno', r_tfwmaild.seqno);
        v_seqno := r_tfwmaild.seqno;
        obj_child       := json_object_t();
        v_child_data    := 0;
        for r_tfwmaile in c_tfwmaile loop
            v_child_data        := v_child_data + 1;
            obj_child_data      := json_object_t();
            obj_child_data.put('approvno', r_tfwmaile.approvno);
            obj_child_data.put('codcompap', r_tfwmaile.codcompap);
            obj_child_data.put('codempap', r_tfwmaile.codempap);
            obj_child_data.put('codposap', r_tfwmaile.codposap);
            obj_child_data.put('flgappr', r_tfwmaile.flgappr);
            obj_child.put(to_char(v_child_data - 1), obj_child_data);
        end loop;
        obj_data.put('children', obj_child);
        obj_table.put(to_char(v_row - 1), obj_data);
    end loop;
    
    obj_main            := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('detail', obj_detail);
    obj_main.put('table', obj_table);
    
    json_str_output := obj_main.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail2;
----------------------------------------------------------------------------------


  procedure save_tfwmailh (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    sql_stmt            varchar2(2000 char);
    v_count             number ;
    v_flg               varchar2(50 char);
    v_codapp            tfwmailh.codapp%type;
    v_codform           tfwmailh.codform%type;
    v_codappap          tfwmailh.codappap%type;
    v_codformno         tfwmailh.codformno%type;

    v_detl_tbl          varchar2(50) ;
    v_detl_column       varchar2(50) ;

  begin  
    initial_value (json_str_input);
    if param_msg_error is null then
       -----------------------------------
       v_codapp        := hcm_util.get_string_t(json_params, 'codapp');
       v_codform       := hcm_util.get_string_t(json_params, 'codform');
       v_codappap      := hcm_util.get_string_t(json_params, 'codappap');
       v_codformno     := hcm_util.get_string_t(json_params, 'codformno');

       -----------------------------------

       begin
          ----------------------------------------------
          insert into tfwmailh
            (codapp, codform, codappap, dteupd, coduser, codcreate)
          values
            (v_codapp, v_codform, v_codappap, sysdate, global_v_coduser, global_v_coduser);
          ----------------------------------------------
       exception
         when DUP_VAL_ON_INDEX then
              -----------------------------------------
              update tfwmailh
              set    codform  = v_codform,
                     codappap = v_codappap,
                     dteupd   = sysdate,
                     coduser  = global_v_coduser
              where  codapp = v_codapp;
              -----------------------------------------
         when others then
               param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
               json_str_output   := get_response_message(400, param_msg_error , global_v_lang);
               rollback ;
               return ;
       end;
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
    param_msg_error   :=  dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_tfwmailh;
----------------------------------------------------------------------------------
  procedure save_index_tfwmailh (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    sql_stmt            varchar2(2000 char);
    v_count             number ;
    v_flg               varchar2(50 char);
    v_codapp          tfwmailh.codapp%type;

  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        v_codapp        := hcm_util.get_string_t(json_row, 'codapp');
        if v_flg = 'delete' then
           begin
                delete from tfwmailh where codapp = v_codapp;
                delete from tfwmaile where codapp = v_codapp;
                delete from tfwmaild where codapp = v_codapp;
                delete from tfwmailc where codapp = v_codapp;
           exception when others then
             param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
           end;
        end if;
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
    param_msg_error   :=  dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_index_tfwmailh;
----------------------------------------------------------------------------------
  procedure get_detail_table(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_table;
----------------------------------------------------------------------------------
 procedure gen_detail_table(json_str_output out clob) is
    obj_data      json_object_t;
    obj_row       json_object_t;
    obj_result    json_object_t;
    obj_syncond   json_object_t;
    obj_dataP     json_object_t;
    obj_rowP      json_object_t;
    obj_tableP    json_object_t;
    obj_dataC     json_object_t;
    obj_rowC      json_object_t;
    obj_tableC    json_object_t;
    v_rcnt      number := 0;
    v_rcnt2      number := 0;
    v_rcnt3      number := 0;

    v_numseq    varchar2(100 char);
    v_seqno     varchar2(100 char);

    cursor c_tfwmailc is
            SELECT t.codapp, t.numseq, t.syncond,
                         get_logical_desc(t.statement) as syncond_name ,
                         t.statement,
                         (select count(*) from tfwmaild st1 where st1.codapp = t.codapp and st1.numseq = t.numseq ) as cnt_maild
            FROM   tfwmailc t
            WHERE  t.codapp = p_codapp
            ORDER BY t.codapp ,t.numseq ;

    cursor p_tfwmaild is
            select t.codapp  , t.numseq , t.seqno
            from tfwmaild t
            where t.codapp = p_codapp
            and   t.numseq = v_numseq ;

    cursor c_tfwmaile is
      select e.numseq,e.seqno,e.approvno,e.flgappr,e.codcompap,e.codposap,e.codempap
        from tfwmaile e
       where e.codapp = p_codapp
         and e.numseq = v_numseq
         and e.seqno = v_seqno;

  begin
    obj_row     := json_object_t();
    obj_result  := json_object_t();
    for r_tfwmailc in c_tfwmailc loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_syncond := json_object_t();
        obj_data.put('coderror', '200');

        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('rcnt', v_rcnt);

        obj_data.put('codapp', r_tfwmailc.codapp);
        obj_data.put('numseq', to_char(r_tfwmailc.numseq));
        obj_syncond.put('code', r_tfwmailc.syncond);
        obj_syncond.put('statement', r_tfwmailc.statement);
        obj_syncond.put('description', r_tfwmailc.syncond_name);
        obj_data.put('syncond', obj_syncond);
        obj_data.put('syncond_name', r_tfwmailc.syncond_name);
        obj_data.put('cnt_maild', r_tfwmailc.cnt_maild);
        -- data parent
        obj_rowP      := json_object_t();
        obj_tableP    := json_object_t();
        v_rcnt2       := 0;
        v_numseq := r_tfwmailc.numseq;
        for r_tfwmaild in p_tfwmaild loop
          obj_dataP    := json_object_t();
          obj_dataP.put('coderror', '200');

          v_numseq := r_tfwmaild.numseq;
          v_seqno := r_tfwmaild.seqno;
          obj_dataP.put('rcnt', v_rcnt);
          obj_dataP.put('codapp', p_codapp);
          obj_dataP.put('numseq', v_numseq);
          obj_dataP.put('seqno', v_seqno);

          obj_rowC      := json_object_t();
          obj_tableC    := json_object_t();
          v_rcnt3       := 0;
          for r_tfwmaile in c_tfwmaile loop
            obj_dataC    := json_object_t();
            obj_dataC.put('approvno', r_tfwmaile.approvno);
            obj_dataC.put('flgappr', r_tfwmaile.flgappr);
            obj_dataC.put('codcompap', nvl(r_tfwmaile.codcompap,''));
            obj_dataC.put('codposap', nvl(r_tfwmaile.codposap,''));
            obj_dataC.put('codempap', nvl(r_tfwmaile.codempap,''));
            obj_rowC.put(to_char(v_rcnt3),obj_dataC);
            v_rcnt3      := v_rcnt3+1;
          end loop;
          obj_dataP.put('children', obj_rowC);
          obj_rowP.put(to_char(v_rcnt2),obj_dataP);
          v_rcnt2      := v_rcnt2+1;
        end loop;

        obj_tableP.put('rows', obj_rowP);
        obj_data.put('table', obj_tableP);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_detail_table;
----------------------------------------------------------------------------------
  procedure save_index_tfwmailc (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    sql_stmt            varchar2(2000 char);
    v_count             number ;
    v_flg               varchar2(50 char);
    v_codapp          tfwmailc.codapp%type;
    v_numseq          tfwmailc.numseq%type;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        v_codapp        := hcm_util.get_string_t(json_row, 'codapp');
        v_numseq        := hcm_util.get_string_t(json_row, 'numseq');
        if v_flg = 'delete' then
           begin
             delete from tfwmailc t where t.codapp = v_codapp and t.numseq = v_numseq ;
           exception when others then
             param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
           end;
        end if;
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
    param_msg_error   :=  dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_index_tfwmailc;
----------------------------------------------------------------------------------
  procedure save_tfwmailc (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    sql_stmt            varchar2(2000 char);
    v_count             number ;
    v_flg               varchar2(50 char);
    v_codapp            tfwmailc.codapp%type;
    v_numseq            tfwmailc.numseq%type;
    v_syncond           tfwmailc.syncond%type;
    v_statement         tfwmailc.statement%type;
    obj_syncond         json_object_t;

  begin 
    initial_value (json_str_input);
    if param_msg_error is null then
       -----------------------------------
       v_codapp        := hcm_util.get_string_t(json_params, 'codapp');
       v_numseq      := hcm_util.get_string_t(json_params, 'numseq');
       obj_syncond       := hcm_util.get_json_t(json_params, 'syncond');
       v_syncond         := hcm_util.get_string_t(obj_syncond, 'code');
       v_statement       := hcm_util.get_string_t(obj_syncond, 'statement');
       -----------------------------------
       begin
          ----------------------------------------------
          insert into tfwmailc
            (codapp, numseq, syncond, statement, dtecreate, codcreate, dteupd, coduser)
          values
            (v_codapp, v_numseq, v_syncond, v_statement, sysdate, global_v_coduser, sysdate, global_v_coduser);
          ----------------------------------------------
       exception
         when DUP_VAL_ON_INDEX then
              -----------------------------------------
              update tfwmailc
              set  syncond = v_syncond,
                   statement = v_statement,
                   dteupd = sysdate,
                   coduser = global_v_coduser
               where codapp = v_codapp
                     and numseq = v_numseq;
              -----------------------------------------
         when others then
               param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
               json_str_output   := get_response_message(400, param_msg_error , global_v_lang);
               rollback ;
               return ;
       end;
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
    param_msg_error   :=  dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_tfwmailc;
----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
--  procedure get_tfwmailc_detail (json_str_input in clob, json_str_output out clob) is
--  begin
--    initial_value(json_str_input);
--    if param_msg_error is null then
--      gen_tfwmailc_detail(json_str_output);
--    end if;
--
--    if param_msg_error is not null then
--      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
--    end if;
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
--  end get_tfwmailc_detail;
----------------------------------------------------------------------------------
--  procedure gen_tfwmailc_detail (json_str_output out clob) is
--    obj_data               json_object_t;
--    v_syncond             tfwmailc.syncond%type;
----    v_statement           tfwmailc.statement%type;
--    v_syncond_name        varchar2(500);
--  begin
--    begin
--      SELECT t.syncond,
--             get_logical_name('HRCO2PE',t.syncond,global_v_lang) as syncond_name
--      INTO   v_syncond, v_syncond_name
--      FROM   tfwmailc t
--      WHERE  t.codapp = p_codapp and t.numseq = p_numseq
--      ORDER BY t.codapp ;
--    end;
--    obj_data          := json_object_t();
--    obj_data.put('coderror', '200');
--    obj_data.put('codapp', p_codapp);
--    obj_data.put('numseq', p_numseq);
--    obj_data.put('syncond', v_syncond);
----    obj_data.put('desc_syncond', get_logical_desc(v_statement));
----    obj_data.put('statement', v_statement);
--    obj_data.put('syncond_name', v_syncond_name);
--    json_str_output := obj_data.to_clob;
--  exception when others then
--    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
--    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
--  end gen_tfwmailc_detail;
----------------------------------------------------------------------------------


--  procedure get_index_tfwmaild(json_str_input in clob, json_str_output out clob) as
--  begin
--    initial_value(json_str_input);
--    if param_msg_error is null then
--      gen_index_tfwmaild(json_str_output);
--    else
--      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--    end if;
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--  end get_index_tfwmaild;
----------------------------------------------------------------------------------
-- procedure gen_index_tfwmaild(json_str_output out clob) is
--    obj_data    json_object_t;
--    obj_data2   json_object_t;
--    obj_row     json_object_t;
--    obj_row2    json_object_t;
--    obj_result  json_object_t;
--    v_rcnt      number := 0;
--    v_numseq        tfwmaild.numseq%type;
--    v_seqno         tfwmaild.seqno%type;
--    v_codapp        tfwmaild.codapp%type;
--    cursor p_tfwmaild is
--            select t.codapp  , t.numseq , t.seqno
--            from tfwmaild t
--            where t.codapp = p_codapp
--            and   t.numseq = p_numseq ;
--
--    cursor c_tfwmaile is
--      select e.numseq,e.seqno,e.approvno,e.flgappr,e.codcompap,e.codposap,e.codempap
--        from tfwmaile e
--       where e.codapp = v_codapp
--         and e.numseq = v_numseq
--         and e.seqno = v_seqno;
--  begin
--    obj_row     := json_object_t();
--    obj_row2     := json_object_t();
--    obj_result  := json_object_t();
--    for r_tfwmaild in p_tfwmaild loop
--        v_rcnt      := v_rcnt+1;
--        obj_data    := json_object_t();
--        obj_data2   := json_object_t();
--
--        obj_data.put('coderror', '200');
--
--        v_numseq := r_tfwmaild.numseq;
--        v_seqno := r_tfwmaild.numseq;
--        v_codapp := r_tfwmaild.codapp;
--
--        obj_data.put('desc_coderror', ' ');
--        obj_data.put('httpcode', '');
--        obj_data.put('flg', '');
--        obj_data.put('rcnt', v_rcnt);
--        obj_data.put('codapp', v_codapp);
--        obj_data.put('numseq', v_numseq);
--        obj_data.put('seqno', v_seqno);
--        for r_tfwmaile in c_tfwmaile loop
--          obj_data2.put('numseq', r_tfwmaile.numseq);
--          obj_data2.put('seqno', r_tfwmaile.seqno);
--          obj_data2.put('approvno', r_tfwmaile.approvno);
--          obj_data2.put('flgappr', r_tfwmaile.flgappr);
--          obj_data2.put('codcompap', nvl(r_tfwmaile.codcompap,''));
--          obj_data2.put('codposap',  nvl(r_tfwmaile.codposap,''));
--          obj_data2.put('codempap',  nvl(r_tfwmaile.codempap,''));
--          obj_row2.put(to_char(v_rcnt-1),obj_data2);
--        end loop;
--        obj_data.put('children', obj_row2);
--        obj_row.put(to_char(v_rcnt-1),obj_data);
--
--    end loop;
--
--    json_str_output := obj_row.to_clob;
--  end gen_index_tfwmaild;
----------------------------------------------------------------------------------
procedure save_index_tfwmaild (json_str_input in clob, json_str_output out clob) is
    json_row               json_object_t;
    v_flg                  varchar2(100 char);
    v_codapp               tfwmaild.codapp%type;
    v_numseq              tfwmaild.numseq%type;

    v_seqno                tfwmaild.seqno%type;

    v_vald_cnt_flgappr_type_1 number ; -- หัวหน้างาน
    v_vald_cnt_flgappr_type_2 number ; --หัวหน้าตามโครงสร้างงาน
  begin  
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        v_codapp          := upper(hcm_util.get_string_t(json_row, 'codapp')); --:= hcm_util.get_string_t(json_params, 'codapp');
        v_numseq          := upper(hcm_util.get_string_t(json_row, 'numseq')); --p_numseq ;
        v_seqno           := upper(hcm_util.get_string_t(json_row, 'seqno'));
        if param_msg_error is not null then
          exit;
        end if;
        if v_flg = 'delete' then
          begin
            Delete
              From tfwmaild
             where codapp = v_codapp
               and numseq   = v_numseq
               and seqno  = v_seqno;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end;
        elsif v_flg = 'add' then
            begin
              v_codapp := p_codapp ;
              v_numseq := p_numseq ;
              insert into tfwmaild
                (codapp,  numseq, seqno, dteupd, coduser, codcreate)
              values
                (v_codapp,  v_numseq, v_seqno, sysdate, global_v_coduser, global_v_coduser);
           exception when DUP_VAL_ON_INDEX then
               param_msg_error := get_error_msg_php('HR1450', global_v_lang);
               json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
               rollback ;
               return ;
               when others then
               param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
               json_str_output   := get_response_message(400, param_msg_error , global_v_lang);
               rollback ;
               return ;
           end;
        else
           begin
             update tfwmaild
             set    codapp      = v_codapp,
                    numseq      = v_numseq,
                    seqno       = v_seqno,
                    dteupd      = sysdate,
                    coduser     = global_v_coduser
             where codapp       = v_codapp
                   and numseq   = v_numseq
                   and seqno    = v_seqno;
           exception when DUP_VAL_ON_INDEX then
               param_msg_error := get_error_msg_php('HR1450', global_v_lang);
               json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
               rollback ;
               return ;
               when others then
               param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
               json_str_output   := get_response_message(400, param_msg_error , global_v_lang);
               rollback ;
               return ;
           end;
        end if;
      end loop;
    end if;
    ----------------------------------------------------
--    select sum(decode(t.flgappr,'1',1,0)) , sum(decode(t.flgappr,'2',1,0))
--    into   v_vald_cnt_flgappr_type_1 , v_vald_cnt_flgappr_type_2
--    from   tfwmaild t
--    where  t.codapp = v_codapp and t.numseq = v_numseq;
    select sum(decode(t.flgappr,'1',1,0)) , sum(decode(t.flgappr,'2',1,0))
    into   v_vald_cnt_flgappr_type_1 , v_vald_cnt_flgappr_type_2
    from   tfwmaile t
    where  t.codapp = v_codapp and t.numseq = v_numseq;
    ----------------------------------------------------
    if v_vald_cnt_flgappr_type_1 > 1 or v_vald_cnt_flgappr_type_2 > 1 then
      rollback;
      param_msg_error := get_error_msg_php('HR2005', global_v_lang) ;
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if ;
    ----------------------------------------------------
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
  end save_index_tfwmaild;
-- current procedure
  procedure initial_detail(param_json_detail json_object_t) is
  begin
    p_codapp        := hcm_util.get_string_t(param_json_detail,'codapp');
    p_codappap      := hcm_util.get_string_t(param_json_detail,'codappap');
    p_codform       := hcm_util.get_string_t(param_json_detail,'codform');
    p_codformno     := hcm_util.get_string_t(param_json_detail,'codformno');
  end; -- end initial_tab_detail
  
  procedure save_detail (json_str_input in clob, json_str_output out clob) is
    v_flg                   varchar2(100 char);
    v_codapp                tfwmailc.codapp%type;
    v_numseq                tfwmailc.numseq%type;

    obj_syncond             json_object_t;

    param_json_detail       json_object_t;
    param_json_table        json_object_t;
    param_json_row          json_object_t;
  begin 
    initial_value(json_str_input);
    param_json_detail           := hcm_util.get_json_t(json_object_t(json_str_input),'detail');
    initial_detail(param_json_detail);

    if p_codform = p_codformno then 
        param_msg_error   := get_error_msg_php('CO0041', global_v_lang) ;
        json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
        return;
    end if;

    if param_msg_error is null then
      begin
        ----------------------------------------------
        insert into tfwmailh (codapp, codform, codappap, codformno, 
                              dteupd, coduser, codcreate, dtecreate)
        values (p_codapp, p_codform, p_codappap,p_codformno, 
                sysdate, global_v_coduser, global_v_coduser, sysdate);
        ----------------------------------------------
      exception when DUP_VAL_ON_INDEX then
        -----------------------------------------
        update tfwmailh
           set codform = p_codform,
               codappap = p_codappap,
               codformno = p_codformno,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codapp = p_codapp;
        -----------------------------------------
      when others then
        param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output     := get_response_message(400, param_msg_error , global_v_lang);
        rollback ;
        return ;
      end;
      -- Row
      param_json_table  := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');

      for i in 0..param_json_table.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json_table,to_char(i));
        v_flg           := hcm_util.get_string_t(param_json_row, 'flg');
        v_codapp        := hcm_util.get_string_t(param_json_row, 'codapp');
        v_numseq        := hcm_util.get_string_t(param_json_row, 'numseq');
        
        if v_flg = 'delete' then
          delete from tfwmaile where codapp = v_codapp and numseq = v_numseq;
          delete from tfwmaild where codapp = v_codapp and numseq = v_numseq;
          delete from tfwmailc where codapp = v_codapp and numseq = v_numseq;
        end if;
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
  end save_detail;

  procedure save_detail2 (json_str_input in clob, json_str_output out clob) is
    v_flg               varchar2(100 char);
    v_codapp            tfwmailc.codapp%type;
    v_numseq            tfwmailc.numseq%type;
    v_syncond           tfwmailc.syncond%type;
    v_statement         tfwmailc.statement%type;
    v_seqno             tfwmaild.seqno%type;
    json_obj            json_object_t;

    v_approvno		    varchar2(500 char);
    v_flgappr		    varchar2(500 char);
    v_codcompap		    varchar2(500 char);
    v_codposap		    varchar2(500 char);
    v_codempap		    varchar2(500 char);
    v_flgP              varchar2(100 char);
    v_flgC              varchar2(100 char);
    v_flgP_add          boolean;
    v_flgP_edit         boolean;
    v_flgP_delete       boolean;
    v_flgC_add          boolean;
    v_flgC_edit         boolean;
    v_flgC_delete       boolean;
    obj_syncond         json_object_t;
    v_vald_cnt_flgappr_type_1 number ; -- หัวหน้างาน
    v_vald_cnt_flgappr_type_2 number ; --หัวหน้าตามโครงสร้างงาน

    param_json_detail       json_object_t;
    param_json_detail2      json_object_t;
    param_json_table        json_object_t;
    param_json_table2       json_object_t;
    param_json_row          json_object_t;
    param_json_parent       json_object_t;
    param_json_children     json_object_t;
    param_row_p             json_object_t;
    param_row_c             json_object_t;
    
    v_flgDelete             boolean;
    v_detail_numseq         tfwmailc.numseq%type;
    v_tfwmailc              tfwmailc%rowtype;
    v_tfwmaild              tfwmaild%rowtype;
    v_tfwmaile              tfwmaile%rowtype;
    v_flg_d                 varchar2(20);
    v_flg_e                 varchar2(20);
    obj_child               json_object_t;
    obj_child_row           json_object_t;
  begin 
    initial_value(json_str_input);
    json_obj                    := json_object_t(json_str_input);
    param_json_detail           := hcm_util.get_json_t(json_obj,'detail');
    param_json_table            := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'table'),'rows');
    param_json_detail2          := hcm_util.get_json_t(json_obj,'detail2');
    param_json_table2           := hcm_util.get_json_t(json_obj,'table2');
    
    -- initial tfwmailc
    v_tfwmailc.codapp           := hcm_util.get_string_t(param_json_detail2,'codapp');
    v_tfwmailc.numseq           := hcm_util.get_string_t(param_json_detail2,'numseq');
    v_tfwmailc.syncond          := hcm_util.get_string_t(hcm_util.get_json_t(param_json_detail2,'syncond'),'code');
    v_tfwmailc.statement        := hcm_util.get_string_t(hcm_util.get_json_t(param_json_detail2,'syncond'),'statement');

    
    initial_detail(param_json_detail);

    if p_codform = p_codformno then 
        param_msg_error   := get_error_msg_php('CO0041', global_v_lang) ;
        json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
        return;
    end if;

    if param_msg_error is null then
      begin
        ----------------------------------------------
        insert into tfwmailh (codapp, codform, codappap, codformno, 
                              dteupd, coduser, codcreate, dtecreate)
        values (p_codapp, p_codform, p_codappap,p_codformno, 
                sysdate, global_v_coduser, global_v_coduser, sysdate);
        ----------------------------------------------
      exception when DUP_VAL_ON_INDEX then
        -----------------------------------------
        update tfwmailh
           set codform = p_codform,
               codappap = p_codappap,
               codformno = p_codformno,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codapp = p_codapp;
        -----------------------------------------
      when others then
        param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output     := get_response_message(400, param_msg_error , global_v_lang);
        rollback ;
        return ;
      end;
      -- Row

      for i in 0..param_json_table.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json_table,to_char(i));
        v_flgDelete     := hcm_util.get_boolean_t(param_json_row, 'flgDelete');
        v_codapp        := hcm_util.get_string_t(param_json_row, 'codapp');
        v_numseq        := hcm_util.get_string_t(param_json_row, 'numseq');
        
        if v_flgDelete and v_numseq <> v_tfwmailc.numseq then
          delete from tfwmailc where codapp = v_codapp and numseq = v_numseq;
          delete from tfwmaild where codapp = v_codapp and numseq = v_numseq;
          delete from tfwmaile where codapp = v_codapp and numseq = v_numseq;
        end if;
        
        /*obj_syncond     := hcm_util.get_json_t(param_json_row,'syncond');
        v_syncond       := hcm_util.get_string_t(obj_syncond, 'code');
        v_statement     := hcm_util.get_string_t(obj_syncond, 'statement');*/
        /*if v_flg = 'add' or v_flg = 'edit' then
          begin
            ----------------------------------------------
            insert into tfwmailc
              (codapp, numseq, syncond, statement, dtecreate, codcreate, dteupd, coduser)
            values
              (v_codapp, v_numseq, v_syncond, v_statement,sysdate, global_v_coduser, sysdate, global_v_coduser);
            ----------------------------------------------
          exception
             when DUP_VAL_ON_INDEX then
                  -----------------------------------------
                  update tfwmailc
                  set    syncond = v_syncond,
                         statement = v_statement,
                         dteupd = sysdate,
                         coduser = global_v_coduser
                   where codapp = v_codapp
                         and numseq = v_numseq;
                  -----------------------------------------
             when others then
                   param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                   json_str_output   := get_response_message(400, param_msg_error , global_v_lang);
                   rollback ;
                   return ;
          end;
        els*/if v_flg = 'delete' then
          delete from tfwmaile where codapp = v_codapp and numseq = v_numseq;
          delete from tfwmaild where codapp = v_codapp and numseq = v_numseq;
          delete from tfwmailc where codapp = v_codapp and numseq = v_numseq;
        end if;

        -- parent and children table
        /*param_json_parent  := hcm_util.get_json_t(hcm_util.get_json_t(param_json_row,'table'),'rows');
        for i in 0..param_json_parent.get_size-1 loop
          param_row_p   := hcm_util.get_json_t(param_json_parent,to_char(i));
          v_seqno       := hcm_util.get_string_t(param_row_p, 'seqno');
          v_flgP        := hcm_util.get_string_t(param_row_p, 'flg');
          v_flgP_add       := nvl(hcm_util.get_boolean_t(param_row_p, 'flgAdd'),false);
          v_flgP_edit      := nvl(hcm_util.get_boolean_t(param_row_p, 'flgEdit'),false);
          v_flgP_delete    := nvl(hcm_util.get_boolean_t(param_row_p, 'flgDelete'),false);
          if ( v_flgP_add = true and v_flgP_delete = false ) or v_flgP = 'add' then
            begin
              insert into tfwmaild
                (codapp,  numseq, seqno, dteupd, coduser, codcreate)
              values
                (v_codapp,  v_numseq, v_seqno, sysdate, global_v_coduser, global_v_coduser);
            exception when DUP_VAL_ON_INDEX then
              param_msg_error := get_error_msg_php('HR1450', global_v_lang);
              json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
              rollback ;
              return ;
            when others then
              param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
              json_str_output   := get_response_message(400, param_msg_error , global_v_lang);
              rollback ;
              return ;
            end;
          elsif v_flgP_delete = true and v_flgP_add = false then
            delete from tfwmaile t where t.codapp = v_codapp and t.numseq = v_numseq and t.seqno = v_seqno;
            delete from tfwmaild t where t.codapp = v_codapp and t.numseq = v_numseq and t.seqno = v_seqno;
          end if;
          param_json_children  := hcm_util.get_json_t(param_row_p,'children');
          for i in 0..param_json_children.get_size-1 loop
            param_row_c       := hcm_util.get_json_t(param_json_children,to_char(i));
            v_approvno        := hcm_util.get_string_t(param_row_c, 'approvno');
            v_flgappr         := hcm_util.get_string_t(param_row_c, 'flgappr');
            v_codcompap       := hcm_util.get_string_t(param_row_c, 'codcompap');
            v_codposap        := hcm_util.get_string_t(param_row_c, 'codposap');
            v_codempap        := hcm_util.get_string_t(param_row_c, 'codempap');
            v_flgC            := hcm_util.get_string_t(param_row_c, 'flg');
            v_flgC_add        := hcm_util.get_boolean_t(param_row_c, 'flgAdd');
            v_flgC_edit       := hcm_util.get_boolean_t(param_row_c, 'flgEdit');
            v_flgC_delete     := hcm_util.get_boolean_t(param_row_c, 'flgDelete');

            v_codcompap := hcm_util.get_codcomp_level(v_codcompap,null,'','Y'); 
            if ( v_flgC_add = true and v_flgC_delete = false ) or v_flgC = 'add' then
              begin
                insert into tfwmaile
                  (codapp,  numseq, seqno, approvno, flgappr, codcompap, codposap, codempap, dteupd, coduser, codcreate)
                values
                  (v_codapp, v_numseq, v_seqno, v_approvno, v_flgappr, v_codcompap, v_codposap, v_codempap, sysdate, global_v_coduser, global_v_coduser);
              exception when DUP_VAL_ON_INDEX then
                param_msg_error := get_error_msg_php('HR1450', global_v_lang);
                json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
                rollback ;
                return ;
              when others then
                param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                json_str_output   := get_response_message(400, param_msg_error , global_v_lang);
                rollback ;
                return ;
              end;
            elsif v_flgC_edit then
              update tfwmaile
              set  flgappr    = v_flgappr,
                   codcompap  = v_codcompap,
                   codposap   = v_codposap,
                   codempap   = v_codempap,
                   dteupd     = sysdate,
                   coduser    = global_v_coduser
              where codapp     = v_codapp
              and numseq = v_numseq
              and seqno = v_seqno
              and approvno = v_approvno;
            elsif v_flgC_add = false and v_flgC_delete = true then
              delete from tfwmaile t where t.codapp = v_codapp and t.numseq = v_numseq and t.seqno = v_seqno and t.approvno = v_approvno;
            end if;
          end loop;
        end loop;*/
      end loop;
      
      begin
        insert into tfwmailc(codapp,numseq,syncond,statement,dtecreate,codcreate,dteupd,coduser)
        values (v_tfwmailc.codapp,v_tfwmailc.numseq,v_tfwmailc.syncond,v_tfwmailc.statement,
                sysdate,global_v_coduser,sysdate,global_v_coduser);
      exception when dup_val_on_index then
        update tfwmailc
           set syncond = v_tfwmailc.syncond,
               statement = v_tfwmailc.statement,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codapp = v_tfwmailc.codapp
           and numseq = v_tfwmailc.numseq;
      when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message(400, param_msg_error , global_v_lang);
        rollback ;
        return ;
      end;  
      
      for i in 0..param_json_table2.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(param_json_table2,to_char(i));
        v_flg_d             := hcm_util.get_string_t(param_json_row,'flg');
        obj_child           := hcm_util.get_json_t(param_json_row,'children');
        v_tfwmaild.codapp   := v_tfwmailc.codapp;
        v_tfwmaild.numseq   := v_tfwmailc.numseq;
        v_tfwmaild.seqno    := hcm_util.get_string_t(param_json_row,'seqno');
        
        if v_flg_d = 'delete' then
            delete from tfwmaild where codapp = v_tfwmaild.codapp and numseq = v_tfwmaild.numseq;
            delete from tfwmaile where codapp = v_tfwmaild.codapp and numseq = v_tfwmaild.numseq;
        elsif v_flg_d = 'add' then
            insert into tfwmaild (codapp,numseq,seqno,
                                  dtecreate,codcreate,dteupd,coduser)
            values (v_tfwmaild.codapp,v_tfwmaild.numseq,v_tfwmaild.seqno,
                    sysdate,global_v_coduser,sysdate,global_v_coduser);
        end if;
        
        for j in 0..obj_child.get_size-1 loop
            obj_child_row           := hcm_util.get_json_t(obj_child,to_char(j));
            v_flg_e                 := hcm_util.get_string_t(obj_child_row,'flg');
            v_tfwmaile.codapp       := v_tfwmailc.codapp;
            v_tfwmaile.numseq       := v_tfwmailc.numseq;
            v_tfwmaile.seqno        := v_tfwmaild.seqno;
            v_tfwmaile.approvno     := hcm_util.get_string_t(obj_child_row,'approvno');
            v_tfwmaile.flgappr      := hcm_util.get_string_t(obj_child_row,'flgappr');
            v_tfwmaile.codcompap    := hcm_util.get_string_t(obj_child_row,'codcompap');
            v_tfwmaile.codposap     := hcm_util.get_string_t(obj_child_row,'codposap');
            v_tfwmaile.codempap     := hcm_util.get_string_t(obj_child_row,'codempap');
            
            if v_flg_e = 'add' then
                insert into tfwmaile(codapp,numseq,seqno,approvno,
                             flgappr,codcompap,codposap,codempap,
                             dtecreate,codcreate,dteupd,coduser)
                values (v_tfwmaile.codapp,v_tfwmaile.numseq,v_tfwmaile.seqno,v_tfwmaile.approvno,
                             v_tfwmaile.flgappr,v_tfwmaile.codcompap,v_tfwmaile.codposap,v_tfwmaile.codempap,
                             sysdate,global_v_coduser,sysdate,global_v_coduser);
            elsif v_flg_e = 'edit' then
                update tfwmaile
                   set flgappr = v_tfwmaile.flgappr,
                       codcompap = v_tfwmaile.codcompap,
                       codposap = v_tfwmaile.codposap,
                       codempap = v_tfwmaile.codempap,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codapp = v_tfwmaile.codapp
                   and numseq = v_tfwmaile.numseq
                   and seqno = v_tfwmaile.seqno
                   and approvno = v_tfwmaile.approvno;
            elsif v_flg_e = 'delete' then
                delete tfwmaile
                 where codapp = v_tfwmaile.codapp
                   and numseq = v_tfwmaile.numseq
                   and seqno = v_tfwmaile.seqno
                   and approvno = v_tfwmaile.approvno;
            end if;
        end loop;
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
  end save_detail2;

  procedure get_list_flgappr (json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_typform       tappprof.typform%type;

    cursor c_1 is
        select list_value, desc_label
          from tlistval
         where codapp = 'TYPEFLOW'
           and list_value in ('D','E')
           and list_value is not null
           and codlang = global_v_lang
      order by numseq ;

    cursor c_2 is
        select list_value, desc_label
          from tlistval
         where codapp = 'TYPEFLOW'
           and codlang = global_v_lang
           and list_value is not null
      order by numseq ;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    begin
        select typform
          into v_typform
          from tappprof
          where codapp = p_codapp;
    exception when others then
        v_typform := 'I';
    end;
    if v_typform is null then
        v_typform := 'I';
    end if;
    if v_typform = 'I' then
        for r1 in c_1 loop
          v_rcnt        := v_rcnt+1;
          obj_data      := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('flgappr', r1.list_value);
          obj_data.put('desc_flgappr', r1.desc_label);
          obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
    else
        for r1 in c_2 loop
          v_rcnt        := v_rcnt+1;
          obj_data      := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('flgappr', r1.list_value);
          obj_data.put('desc_flgappr', r1.desc_label);
          obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end HRCO2PE;

/

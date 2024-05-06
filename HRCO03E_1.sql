--------------------------------------------------------
--  DDL for Package Body HRCO03E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO03E" is
-- last update: 25/02/2020 19:00
  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcompy        := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    p_codproc           := upper(hcm_util.get_string_t(json_obj, 'p_codproc'));

    p_numseq          := hcm_util.get_string_t(json_obj,'p_numseq');
    p_qtycode          := hcm_util.get_string_t(json_obj,'p_qtycode');
    -- save index
    json_params         := hcm_util.get_json_t(json_obj, 'params');

  end initial_value;
----------------------------------------------------------------------------------
  procedure get_flgdisable (json_str_input in clob, json_str_output out clob) is
    obj_data                json_object_t;
    v_flgdisable            boolean;
    v_counttcenter          number;
  begin
    v_flgdisable := false;
    initial_value(json_str_input);
    if param_msg_error is null then
        obj_data          := json_object_t();

        select count(*)
          into v_counttcenter
          from tcenter
         where rownum = 1;

        if v_counttcenter > 0 then
            v_flgdisable := true;
        end if;
        obj_data.put('coderror', '200');
        obj_data.put('flgdisable', v_flgdisable);

        json_str_output := obj_data.to_clob;
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_flgdisable;
----------------------------------------------------------------------------------
  procedure get_detail (json_str_input in clob, json_str_output out clob) is
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
    obj_data               json_object_t;
    v_numseq               tsetcomp.numseq%type;
--    v_namcent              tsetcomp.namcente%type;
--    v_namcente             tsetcomp.namcente%type;
--    v_namcentt             tsetcomp.namcentt%type;
--    v_namcent3             tsetcomp.namcent3%type;
--    v_namcent4             tsetcomp.namcent4%type;
--    v_namcent5             tsetcomp.namcent5%type;
    v_qtycode              tsetcomp.qtycode%type;
--    v_typcode              tsetcomp.typcode%type;
  begin
    begin
      SELECT t.numseq ,
--             decode(global_v_lang, '101', t.namcente,
--                                              '102', t.namcentt,
--                                              '103', t.namcent3,
--                                              '104', t.namcent4,
--                                              '105', t.namcent5,
--                                              t.namcente) as namcent ,
--             t.namcente , t.namcentt , t.namcent3, t.namcent4 , t.namcent5 ,
             t.qtycode --, t.typcode
      INTO   v_numseq ,
--             v_namcent , v_namcente , v_namcentt , v_namcent3 ,
--             v_namcent4 , v_namcent5 ,
             v_qtycode-- , v_typcode
      FROM   tsetcomp t
      WHERE  t.numseq = p_numseq ;
    exception when no_data_found then
      null;
    end;

    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codapp', p_codapp);
    obj_data.put('numseq', v_numseq);
--    obj_data.put('namcent', v_namcent);
--    obj_data.put('namcente', v_namcente);
--    obj_data.put('namcentt', v_namcentt);
--    obj_data.put('namcent3', v_namcent3);
--    obj_data.put('namcent4', v_namcent4);
--    obj_data.put('namcent5', v_namcent5);
    obj_data.put('qtycode', v_qtycode);
--    obj_data.put('typcode', v_typcode);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;
----------------------------------------------------------------------------------
  procedure get_detail_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_index;
----------------------------------------------------------------------------------
  procedure gen_detail_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    obj_result  json_object_t;
   -- json_row    json;
    v_detl_tbl  varchar2(50) ;
    v_statement varchar2(2000) ;
    v_temp      varchar2 (4000) ;
    v_rcnt      number := 0;
    TYPE EmpCurTyp IS REF CURSOR;
    c_tcodcom   EmpCurTyp;
    type rectype is record
        ( CODCODEC varchar2(4) ,
          CODCODEC_OLD varchar2(4) ,
          DESCODE varchar2(150) ,
          DESCODT varchar2(150) ,
          DESCOD3 varchar2(150) ,
          DESCOD4 varchar2(150) ,
          DESCOD5 varchar2(150) ,
          FLGCORR varchar2(1) ,
          FLGACT varchar2(1) ,
          CODUSER varchar2(50) ,
          DTEUPD  varchar2(50) ,
          DESCOD varchar2(150) );
    r_tcodcom rectype;
begin
    obj_row     := json_object_t();
    obj_result  := json_object_t();
  --  json_row    := hcm_util.get_json(json_params, to_char(0));

    CASE p_numseq
       WHEN '2' THEN v_detl_tbl := 'TCODCOM2' ;
       WHEN '3' THEN v_detl_tbl := 'TCODCOM3' ;
       WHEN '4' THEN v_detl_tbl := 'TCODCOM4' ;
       WHEN '5' THEN v_detl_tbl := 'TCODCOM5' ;
       WHEN '6' THEN v_detl_tbl := 'TCODCOM6' ;
       WHEN '7' THEN v_detl_tbl := 'TCODCOM7' ;
       WHEN '8' THEN v_detl_tbl := 'TCODCOM8' ;
       WHEN '9' THEN v_detl_tbl := 'TCODCOM9' ;
       WHEN '10' THEN v_detl_tbl := 'TCODCOM10' ;
       ELSE v_detl_tbl := 'TCODCOM2' ;
    END CASE ;

    v_statement := 'SELECT CODCODEC , CODCODEC as CODCODEC_OLD , DESCODE , DESCODT , DESCOD3 , DESCOD4 , DESCOD5 , FLGCORR , FLGACT , CODUSER , to_char(sysdate, ''dd/mm/yyyy'') as DTEUPD , decode(''' || global_v_lang || ''', ''101'', DESCODE, ''102'', DESCODT, ''103'', DESCOD3, ''104'', DESCOD4, ''105'', DESCOD5,  DESCODE) as DESCOD FROM ' || v_detl_tbl ;

    OPEN c_tcodcom FOR  v_statement ;
    loop
        fetch c_tcodcom into r_tcodcom ;
        exit when c_tcodcom%notfound;
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('codapp', p_codapp);

        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('rcnt', v_rcnt);

        obj_data.put('numseq', p_numseq);
        obj_data.put('codcodec', r_tcodcom.CODCODEC);
        obj_data.put('codcodec_old', r_tcodcom.CODCODEC_OLD);
        obj_data.put('descod', r_tcodcom.DESCOD);
        obj_data.put('descode', r_tcodcom.DESCODE);
        obj_data.put('descodt', r_tcodcom.DESCODT);
        obj_data.put('descod3', r_tcodcom.DESCOD3);
        obj_data.put('descod4', r_tcodcom.DESCOD4);
        obj_data.put('descod5', r_tcodcom.DESCOD5);
        obj_data.put('flgcorr', r_tcodcom.FLGCORR);
        obj_data.put('flgact', r_tcodcom.FLGACT);
        obj_data.put('coduser', r_tcodcom.CODUSER);
       -- v_temp := to_char(r_tcodcom.DTEUPD, 'dd/mm/yyyy') ;
       v_temp := r_tcodcom.DTEUPD ;
        obj_data.put('dteupd',v_temp  );

        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    close c_tcodcom ;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail_index;
----------------------------------------------------------------------------------
  procedure save_detail_index (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    sql_stmt            varchar2(2000 char);
    v_count             number ;
    v_flg               varchar2(50 char);
--    v_codcodec          tcodcom2.codcodec%type;
--    v_codcodec_old      tcodcom2.codcodec%type;
--    v_descod            tcodcom2.descode%type;
--    v_descode           tcodcom2.descode%type;
--    v_descodt           tcodcom2.descodt%type;
--    v_descod3           tcodcom2.descod3%type;
--    v_descod4           tcodcom2.descod4%type;
--    v_descod5           tcodcom2.descod5%type;
--    v_flgcorr           tcodcom2.flgcorr%type;
--    v_flgact            tcodcom2.flgact%type;
--    v_coduser           tcodcom2.coduser%type;
--    v_dteupd            tcodcom2.dteupd%type;

    v_detl_tbl          varchar2(50) ;
    v_detl_column       varchar2(50) ;
  begin
    initial_value (json_str_input);
--    if param_msg_error is null then
--      -----------------------------------
--      CASE p_numseq
--           WHEN '2' THEN v_detl_tbl := 'TCODCOM2' ; v_detl_column := 'codcom2' ;
--           WHEN '3' THEN v_detl_tbl := 'TCODCOM3' ; v_detl_column := 'codcom3' ;
--           WHEN '4' THEN v_detl_tbl := 'TCODCOM4' ; v_detl_column := 'codcom4' ;
--           WHEN '5' THEN v_detl_tbl := 'TCODCOM5' ; v_detl_column := 'codcom5' ;
--           WHEN '6' THEN v_detl_tbl := 'TCODCOM6' ; v_detl_column := 'codcom6' ;
--           WHEN '7' THEN v_detl_tbl := 'TCODCOM7' ; v_detl_column := 'codcom7' ;
--           WHEN '8' THEN v_detl_tbl := 'TCODCOM8' ; v_detl_column := 'codcom8' ;
--           WHEN '9' THEN v_detl_tbl := 'TCODCOM9' ; v_detl_column := 'codcom9' ;
--           WHEN '10' THEN v_detl_tbl := 'TCODCOM10' ; v_detl_column := 'codcom10' ;
--           ELSE v_detl_tbl := 'TCODCOM2' ; v_detl_column := 'codcom2' ;
--      END CASE ;
--      -----------------------------------
--      for i in 0..json_params.count - 1 loop
--        json_row          := hcm_util.get_json(json_params, to_char(i));
--
--        --p_numseq
--        v_flg             := hcm_util.get_string(json_row, 'flg');
--        v_codcodec        := hcm_util.get_string(json_row, 'codcodec');
--        v_codcodec_old     := hcm_util.get_string(json_row, 'codcodec_old');
--        v_descod         := hcm_util.get_string(json_row, 'descod');
--        v_descode         := hcm_util.get_string(json_row, 'descode');
--        v_descodt         := hcm_util.get_string(json_row, 'descodt');
--        v_descod3         := hcm_util.get_string(json_row, 'descod3');
--        v_descod4         := hcm_util.get_string(json_row, 'descod4');
--        v_descod5         := hcm_util.get_string(json_row, 'descod5');
--        v_flgcorr         := hcm_util.get_string(json_row, 'flgcorr');
--        v_flgact          := hcm_util.get_string(json_row, 'flgact');
--        v_coduser         := hcm_util.get_string(json_row, 'coduser');
--        v_dteupd          := hcm_util.get_string(json_row, 'dteupd');
--
--        if global_v_lang = '101' then
--          v_descode := v_descod;
--        elsif global_v_lang = '102' then
--          v_descodt := v_descod;
--        elsif global_v_lang = '103' then
--          v_descod3 := v_descod;
--        elsif global_v_lang = '104' then
--          v_descod4 := v_descod;
--        elsif global_v_lang = '105' then
--          v_descod5 := v_descod;
--        end if;
--
--        sql_stmt := 'select count(''X'') from tcenter where ' || v_detl_column || ' = ''' || v_codcodec || '''' ;
--        EXECUTE IMMEDIATE sql_stmt INTO v_count ;
--        if v_count > 0 then
--          param_msg_error := get_error_msg_php('HR1450', global_v_lang);
--          json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
--          rollback ;
--          return ;
--        end if;
--
--        if v_flg = 'delete' then
--           begin
--             sql_stmt := 'delete ' || v_detl_tbl ||  ' where codcodec = ''' || v_codcodec_old || '''' ;
--             EXECUTE IMMEDIATE sql_stmt ;
--           exception when others then
--             param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--           end;
--        elsif v_flg = 'add' then
--           if length(v_codcodec) != p_qtycode then
--              param_msg_error := get_error_msg_php('CO0027', global_v_lang);
--              json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
--              rollback ;
--              return ;
--            end if;
--           begin
--             sql_stmt := 'insert into ' || v_detl_tbl || ' (CODCODEC , DESCODE , DESCODT , DESCOD3 , DESCOD4 , DESCOD5 , FLGCORR , FLGACT , DTECREATE , CODCREATE , CODUSER , DTEUPD  )  values (:1 , :2 , :3 , :4 , :5 , :6 , :7 , :8 , :9 , :10 ,:11 , :12)' ;
--             EXECUTE IMMEDIATE sql_stmt
--             USING    v_codcodec , v_descode , v_descodt , v_descod3 , v_descod4 , v_descod5 , v_flgcorr , v_flgact , sysdate , global_v_coduser , global_v_coduser , sysdate  ;
--           exception when DUP_VAL_ON_INDEX then
--               param_msg_error := get_error_msg_php('HR1450', global_v_lang);
--               json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
--               rollback ;
--               return ;
--                      when others then
--               param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--               json_str_output   := get_response_message(400, param_msg_error , global_v_lang);
--               rollback ;
--               return ;
--           end;
--        else
--           if length(v_codcodec) != p_qtycode then
--              param_msg_error := get_error_msg_php('CO0027', global_v_lang);
--              json_str_output := get_response_message(400, param_msg_error, global_v_lang);
--              rollback ;
--              return ;
--            end if;
--           begin
--             sql_stmt := 'update ' || v_detl_tbl ||  ' set DESCODE = :1 , DESCODT = :2 , DESCOD3 = :3 , DESCOD4 = :4 , DESCOD5 = :5  , FLGCORR = :6 , FLGACT = :7 , CODUSER = :8 , DTEUPD = :9 , CODCODEC = :10 where CODCODEC = :11 ' ;
--             EXECUTE IMMEDIATE sql_stmt
--             USING v_descode , v_descodt , v_descod3 , v_descod4 , v_descod5 , v_flgcorr , v_flgact , global_v_coduser , sysdate , v_codcodec , v_codcodec_old  ;
--           exception when DUP_VAL_ON_INDEX then
--               param_msg_error := get_error_msg_php('HR1450', global_v_lang);
--               json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
--               rollback ;
--               return ;
--               when others then
--               param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--               json_str_output   := get_response_message(400, param_msg_error , global_v_lang);
--               rollback ;
--               return ;
--           end;
--        end if;
--      end loop;
--    end if;
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
  end save_detail_index;
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
  procedure save_tsetcomp (json_str_input in clob, json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    obj_result  json_object_t;
    v_numseq            tsetcomp.numseq%type;
--    v_namcent           tsetcomp.namcente%type;
--    v_namcente          tsetcomp.namcente%type;
--    v_namcentt          tsetcomp.namcentt%type;
--    v_namcent3          tsetcomp.namcent3%type;
--    v_namcent4          tsetcomp.namcent4%type;
--    v_namcent5          tsetcomp.namcent5%type;
    v_qtycode           tsetcomp.qtycode%type;
--    v_typcode           tsetcomp.typcode%type;
  begin
      initial_value(json_str_input);

      v_numseq     := hcm_util.get_string_t(json_params, 'numseq');
--      v_namcent    := hcm_util.get_string(json_params, 'namcent');
--      v_namcente   := hcm_util.get_string(json_params, 'namcente');
--      v_namcentt   := hcm_util.get_string(json_params, 'namcentt');
--      v_namcent3   := hcm_util.get_string(json_params, 'namcent3');
--      v_namcent4   := hcm_util.get_string(json_params, 'namcent4');
--      v_namcent5   := hcm_util.get_string(json_params, 'namcent5');
      v_qtycode    := hcm_util.get_string_t(json_params, 'qtycode');
--      v_typcode    := hcm_util.get_string(json_params, 'typcode');

--      if global_v_lang = '101' then
--        v_namcente := v_namcent;
--      elsif global_v_lang = '102' then
--        v_namcentt := v_namcent;
--      elsif global_v_lang = '103' then
--        v_namcent3 := v_namcent;
--      elsif global_v_lang = '104' then
--        v_namcent4 := v_namcent;
--      elsif global_v_lang = '105' then
--        v_namcent5 := v_namcent;
--      end if;

      begin
            insert into tsetcomp
                   (numseq,
--                   namcente, namcentt, namcent3, namcent4, namcent5,
                   qtycode, /*typcode,*/ dtecreate, codcreate, dteupd, coduser)
            values
                   (v_numseq,
--                   v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5,
                   v_qtycode, /*v_typcode,*/ sysdate, global_v_coduser, sysdate, global_v_coduser);
      exception when DUP_VAL_ON_INDEX then
            update tsetcomp set
--                                namcente   = v_namcente,
--                                namcentt   = v_namcentt,
--                                namcent3   = v_namcent3,
--                                namcent4   = v_namcent4,
--                                namcent5   = v_namcent5,
                                qtycode    = v_qtycode,
--                                typcode    = v_typcode,
                                dteupd     = sysdate,
                                coduser    = global_v_coduser
            where numseq  = v_numseq ;
      end;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
        commit;
      else
        rollback;
      end if;
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  end save_tsetcomp;
----------------------------------------------------------------------------------
  procedure gen_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    obj_result  json_object_t;
    v_rcnt      number := 0;
    cursor c_tsetcomp is
            SELECT t.numseq  ,
                   t.qtycode /*,
                   t.typcode*/
            FROM   tsetcomp t
            ORDER BY t.numseq ;
  begin
    obj_row     := json_object_t();
    obj_result  := json_object_t();
    for r_tsetcomp in c_tsetcomp loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('codapp', p_codapp);

        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('rcnt', v_rcnt);

        obj_data.put('numseq', r_tsetcomp.numseq);
        obj_data.put('qtycode', r_tsetcomp.qtycode);
--        obj_data.put('typcode', r_tsetcomp.typcode);
        obj_data.put('disabled_numseq', true);

        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_rcnt = 0 then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('codapp', p_codapp);

        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('rcnt', v_rcnt);

        obj_data.put('numseq', 1);
        obj_data.put('qtycode', '');
        obj_data.put('typcode', '');
        obj_data.put('disabled_numseq', true);

        obj_row.put(to_char(v_rcnt-1),obj_data);
    end if;
    json_str_output := obj_row.to_clob;
  end gen_index;
----------------------------------------------------------------------------------
  procedure save_index (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    v_flg               varchar2(100 char);
    v_timstrt           varchar2(5 char);
    v_timend            varchar2(5 char);
    v_numseq            tsetcomp.numseq%type;
    v_numseqOld         tsetcomp.numseq%type;
    v_qtycode           tsetcomp.qtycode%type;
    v_qtycodeOld        tsetcomp.qtycode%type;
--    v_typcode           tsetcomp.typcode%type;
    v_detl_tbl          varchar2(50) ;
    v_detl_column       varchar2(50) ;
    v_count             number ;
    v_maxnumseq         number;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        v_numseq          := hcm_util.get_string_t(json_row, 'numseq');
        v_numseqOld       := hcm_util.get_string_t(json_row, 'numseqOld');
        v_qtycode         := hcm_util.get_string_t(json_row, 'qtycode');
        v_qtycodeOld      := hcm_util.get_string_t(json_row, 'qtycodeOld');
        if v_flg = 'delete' then
           begin
                select count(*)
                  into v_count
                  from tcompnyd
                 where comlevel = v_numseqOld;

                 if v_count > 0 then
                   param_msg_error := get_error_msg_php('HR1450', global_v_lang);
                   exit;
                 else
                     delete from tsetcomp
                     where numseq = v_numseqOld;
                 end if;


           end;
        elsif v_flg = 'edit' then
            if v_qtycode <> v_qtycodeOld then
                select count(*)
                  into v_count
                  from tcompnyd
                 where comlevel = v_numseqOld;

                 if v_count > 0 then
                   param_msg_error := get_error_msg_php('CO0037', global_v_lang);
                   exit;
                 end if;
            end if;

            begin
                insert into tsetcomp
                       (numseq, qtycode, dtecreate, codcreate, dteupd, coduser)
                values
                       (v_numseqOld, v_qtycode, sysdate, global_v_coduser, sysdate, global_v_coduser);
            exception when DUP_VAL_ON_INDEX then
                update tsetcomp 
                   set qtycode    = v_qtycode,
    --                 typcode    = v_typcode,
                       dteupd     = sysdate,
                       coduser    = global_v_coduser
                 where numseq  = v_numseqOld ;
            end;

        else
--           delete from tsetcomp
--           where numseq = v_numseq;
           begin
                insert into tsetcomp
                       (numseq, qtycode, dtecreate, codcreate, dteupd, coduser)
                values
                       (v_numseq, v_qtycode, sysdate, global_v_coduser, sysdate, global_v_coduser);
           exception when DUP_VAL_ON_INDEX then
                update tsetcomp
                   set qtycode = v_qtycode,
--                       typcode = v_typcode,
                       dteupd = sysdate,
                       coduser = global_v_coduser,
                       numseq = v_numseq
                 where numseq  = v_numseqOld ;
           end;
        end if;
      end loop;

      select count (numseq) ,nvl(max(numseq),0)
        into v_count , v_maxnumseq
        from tsetcomp;
      if v_maxnumseq > 10 then --if v_maxnumseq <> v_count then -- #8024 || 13/07/2022
        param_msg_error := get_error_msg_php('CO0034', global_v_lang);
      else
        null;
      end if;

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
  end save_index;

end HRCO03E;

/

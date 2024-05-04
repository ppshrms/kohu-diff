--------------------------------------------------------
--  DDL for Package Body HRCO04E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO04E" is
-- last update: 04/02/2020 10:30
procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');

    p_codempid              := upper(hcm_util.get_string_t(json_obj, 'p_codempid'));
    p_codcompy              := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codcomp               := hcm_util.get_string_t(json_obj,'p_codcomp');
    pp_dteeffec             := hcm_util.get_string_t(json_obj,'p_dteeffec');
    p_dteeffec              := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'ddmmyyyy');
    json_params             := hcm_util.get_json_t(json_obj, 'params');
    json_params_formlevel   := hcm_util.get_json_t(json_obj, 'param_json');
    p_flgtype               := hcm_util.get_string_t(json_obj,'p_type');
    p_comlevel              := hcm_util.get_string_t(json_obj,'p_comlevel');
    p_parent_comlevel       := (hcm_util.get_string_t(json_obj,'p_parent_comlevel'));
    
    p_flgact                := nvl(hcm_util.get_string_t(json_obj,'p_flgact'),'A');
    
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_save_codcomp is
    v_dtecurrent date := trunc(sysdate);
  begin
    null;
  end check_save_codcomp;
  procedure check_codcomp is
    v_code  varchar2(4000);
  begin
    begin
      select  codcompy
      into    v_code
      from    tcompny
      where   codcompy = p_codcompy;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCOMPNY');
    end;
  end check_codcomp;

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

  procedure gen_index(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt		    number := 0;
    v_flgsecu       boolean ;
    v_levelCount    number;
    cursor c_tcompny is
      select  t1.namimgcom as namimgcom,
              t1.codcompy as codcompy,
              get_tcompny_name(t1.codcompy, global_v_lang) as desc_codcompy,
              t1.dteupd as dteupd,
              t1.coduser as coduser,
              t1.comimage as comimage
      from    tcompny t1
      order by t1.codcompy;
  begin
    obj_row         := json_object_t();
    obj_result      := json_object_t();
    for r_tcompny in c_tcompny loop
      v_flgsecu := secur_main.secur7(r_tcompny.codcompy, global_v_coduser);
      if  v_flgsecu then

        select count(*)
          into v_levelCount
          from tcompnyc
         where codcompy = r_tcompny.codcompy;

        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('rcnt', v_rcnt);
        obj_data.put('compy_image', r_tcompny.namimgcom);
        obj_data.put('codcompy', r_tcompny.codcompy);
        obj_data.put('desc_codcompy', r_tcompny.desc_codcompy);
        obj_data.put('comimage', r_tcompny.comimage);
        obj_data.put('path_image', '/file_uploads/'||get_tfolderd('HRCO01E1')||'/');
        obj_data.put('count_level', v_levelCount);

        obj_row.put(to_char(v_rcnt-1),obj_data);
     end if ;
    end loop;

    if v_rcnt = 0 then
       param_msg_error := get_error_msg_php('HR3007',global_v_lang);
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;

    json_str_output := obj_row.to_clob;
  end gen_index;
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
  procedure gen_detail_index (json_str_output out clob) is
    obj_row                 json_object_t;
    obj_data                json_object_t;
    v_rcnt                  number;
    v_flgsecu               boolean := false;
    v_dteeffec              date;
    v_flgChkDisable         varchar2(1);
    v_temp_cnt_1            number;
    v_temp_cnt_2            number;

    cursor c_tcenter is
            select  mt1.* , get_tlistval_name('STATCENTER',  mt1.flgact, global_v_lang) flgact_desc,
                    decode(global_v_lang, '101', mt1.namcente,
                                         '102', mt1.namcentt,
                                         '103', mt1.namcent3,
                                         '104', mt1.namcent4,
                                         '105', mt1.namcent5,
                                          mt1.namcente) as namcent ,
                    decode(global_v_lang, '101', mt1.naminite,
                                         '102', mt1.naminitt,
                                         '103', mt1.naminit3,
                                         '104', mt1.naminit4,
                                         '105', mt1.naminit5,
                                          mt1.naminite) as naminit
            from (/*( select  ( t1.codcom1 || nvl2(t1.codcom2,'-'||t1.codcom2,'') || nvl2(t1.codcom3,'-'||t1.codcom3,'') || nvl2(t1.codcom4,'-'||t1.codcom4,'') || nvl2(t1.codcom5,'-'||t1.codcom5,'') ||
                              nvl2(t1.codcom6,'-'||t1.codcom6,'') || nvl2(t1.codcom7,'-'||t1.codcom7,'') || nvl2(t1.codcom8,'-'||t1.codcom8,'') || nvl2(t1.codcom9,'-'||t1.codcom9,'') || nvl2(t1.codcom10,'-'||t1.codcom10,'') ) as codcomp_show ,
                           t1.codcomp , t1.namcente , t1.namcentt , t1.namcent3 , t1.namcent4 , t1.namcent5 , t1.flgact ,
                           t1.codcom1 , t1.codcom2 , t1.codcom3 , t1.codcom4 , t1.codcom5 , t1.codcom6 , t1.codcom7 ,
                           t1.codcom8 , t1.codcom9 , t1.codcom10 , t1.codcompy , t1.naminite , t1.naminitt , t1.naminit3 ,
                           t1.naminit4 , t1.naminit5 , t1.dteupd , t1.flgcal , 'log' as c_type , dteeffec as dteeffec, t1.costcent
                    from   tcenterlog t1
                    where  t1.codcompy = p_codcompy
                           and not exists ( select b.codcomp from tcenter b where b.codcomp = t1.codcomp )
                           and t1.dteeffec = (select max(st2.dteeffec) from tcenterlog st2 where st2.codcompy = p_codcompy ))
                  union*/
                  ( select ( t2.codcom1 || nvl2(t2.codcom2,'-'||t2.codcom2,'') || nvl2(t2.codcom3,'-'||t2.codcom3,'') || nvl2(t2.codcom4,'-'||t2.codcom4,'') || nvl2(t2.codcom5,'-'||t2.codcom5,'') ||
                             nvl2(t2.codcom6,'-'||t2.codcom6,'') || nvl2(t2.codcom7,'-'||t2.codcom7,'') || nvl2(t2.codcom8,'-'||t2.codcom8,'') || nvl2(t2.codcom9,'-'||t2.codcom9,'') || nvl2(t2.codcom10,'-'||t2.codcom10,'') ) as codcomp_show ,
                           t2.codcomp , t2.namcente , t2.namcentt , t2.namcent3 , t2.namcent4 , t2.namcent5 , t2.flgact ,
                           t2.codcom1 , t2.codcom2 , t2.codcom3 , t2.codcom4 , t2.codcom5 , t2.codcom6 , t2.codcom7 ,
                           t2.codcom8 , t2.codcom9 , t2.codcom10 , t2.codcompy , t2.naminite , t2.naminitt , t2.naminit3 ,
                           t2.naminit4 , t2.naminit5 , t2.dteupd , 'Y' as flgcal , 'center' as c_type , null as dteeffec, comlevel,
                           t2.costcent
                    from   tcenter t2
                    where  t2.codcompy = p_codcompy
                      and  (decode(t2.flgact,'3','1',t2.flgact) = p_flgact or p_flgact = '3'))) mt1
            order by mt1.codcomp ;

  begin
    obj_row             := json_object_t();
    v_rcnt              := 0;

    for c1 in c_tcenter loop
        obj_data          := json_object_t();
        v_rcnt            := v_rcnt + 1;

        begin
            select max(dteeffec)
              into v_dteeffec
              from tcenterlog
             where codcomp = c1.codcomp;
        exception when others then
            v_dteeffec := trunc(sysdate);
        end;

        obj_data.put('coderror', '200');
        obj_data.put('codcomp', c1.codcomp);
        obj_data.put('codcomp_show', c1.codcomp_show);
        obj_data.put('namcent', c1.namcent);
        obj_data.put('namcente', c1.namcente);
        obj_data.put('namcentt', c1.namcentt);
        obj_data.put('namcent3', c1.namcent3);
        obj_data.put('namcent4', c1.namcent4);
        obj_data.put('namcent5', c1.namcent5);
        obj_data.put('flgact', c1.flgact);
        obj_data.put('flgact_desc', c1.flgact_desc);
        obj_data.put('codcom1', c1.codcom1);
        obj_data.put('codcom2', c1.codcom2);
        obj_data.put('codcom3', c1.codcom3);
        obj_data.put('codcom4', c1.codcom4);
        obj_data.put('codcom6', c1.codcom6);
        obj_data.put('codcom7', c1.codcom7);
        obj_data.put('codcom8', c1.codcom8);
        obj_data.put('codcom9', c1.codcom9);
        obj_data.put('codcom10', c1.codcom10);
        obj_data.put('codcompy', c1.codcompy);
        obj_data.put('comlevel', c1.comlevel);
        obj_data.put('naminit', c1.naminit);
        obj_data.put('naminite', c1.naminite);
        obj_data.put('naminitt', c1.naminitt);
        obj_data.put('naminit3', c1.naminit3);
        obj_data.put('naminit4', c1.naminit4);
        obj_data.put('naminit5', c1.naminit5);
        obj_data.put('dteupd', c1.dteupd);
        obj_data.put('flgcal', c1.flgcal);
        obj_data.put('c_type', c1.c_type);
        obj_data.put('dteeffec', to_char(nvl(v_dteeffec,trunc(sysdate)), 'dd/mm/yyyy'));
        obj_data.put('costcent', c1.costcent);

          select (select count('x') from temploy1 st1 where st1.codcomp = c1.codcomp) ,
                 (select count('x') from ttmovemt st2 where st2.codcomp = c1.codcomp)
          into v_temp_cnt_1 , v_temp_cnt_2
          from dual ;
          ----------------------------------------
          if (v_temp_cnt_1 > 0) or (v_temp_cnt_2 > 0) then
               v_flgChkDisable := 'Y';
          else
            v_flgChkDisable := 'N';
          end if ;   
          
        obj_data.put('flgChkDisable', v_flgChkDisable);
        obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail_index;
----------------------------------------------------------------------------------
  procedure save_detail_index (json_str_input in clob, json_str_output out clob) is
    v_flgsecu           boolean := false;
    json_row            json_object_t;
    v_temp_cnt_1        number;
    v_temp_cnt_2        number;
    v_flg               varchar2(100 char);
    v_c_type            varchar2(20 char);
    v_codcomp           tcenterlog.codcomp%type;
    v_dteeffec          tcenterlog.dteeffec%type;
    v_comlevel          tcenter.comlevel%type;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
        -----------------------------------------------
        v_flgsecu := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
          if not v_flgsecu  then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
            return;
          end if;
        -----------------------------------------------
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        v_c_type          := hcm_util.get_string_t(json_row, 'c_type');
        v_codcomp         := hcm_util.get_string_t(json_row, 'codcomp');
        v_dteeffec        := to_date(trim(hcm_util.get_string_t(json_row,'dteeffec')),'dd/mm/yyyy');

        if v_flg = 'delete' then
          select (select count('x') from temploy1 st1 where st1.codcomp = v_codcomp) ,
                 (select count('x') from ttmovemt st2 where st2.codcomp = v_codcomp)
          into v_temp_cnt_1 , v_temp_cnt_2
          from dual ;
          ----------------------------------------
          if (v_temp_cnt_1 > 0) or (v_temp_cnt_2 > 0) then
               param_msg_error := get_error_msg_php('CO0030', global_v_lang);
               json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
               return ;
          end if ;
          ----------------------------------------
          if v_c_type = 'log' then
            delete from tcenterlog t where t.codcomp = v_codcomp and t.dteeffec = v_dteeffec ;
          else
            select comlevel
            into v_comlevel
            from tcenter where codcomp = v_codcomp;

            delete from tcenter t1 where t1.codcomp = v_codcomp ;
          end if ;

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
  end save_detail_index;
----------------------------------------------------------------------------------
procedure save_detail_tcenter (json_str_input in clob, json_str_output out clob) is
    v_flgsecu           boolean := false;
    json_row            json_object_t;
    sql_stmt            varchar2(2000 char);
    v_count             number ;
    v_flg               varchar2(50 char);
    v_dteeffec          tcenterlog.dteeffec%type;
    v_codcomp           tcenter.codcomp%type;
    v_namcent           tcenter.namcente%type;
    v_namcente          tcenter.namcente%type;
    v_namcentt          tcenter.namcentt%type;
    v_namcent3          tcenter.namcent3%type;
    v_namcent4          tcenter.namcent4%type;
    v_namcent5          tcenter.namcent5%type;
    v_codcom            varchar2(2000 char);
    v_codcom1           tcenter.codcom1%type;
    v_codcom2           tcenter.codcom2%type;
    v_codcom3           tcenter.codcom3%type;
    v_codcom4           tcenter.codcom4%type;
    v_codcom5           tcenter.codcom5%type;
    v_codcom6           tcenter.codcom6%type;
    v_codcom7           tcenter.codcom7%type;
    v_codcom8           tcenter.codcom8%type;
    v_codcom9           tcenter.codcom9%type;
    v_codcom10          tcenter.codcom10%type;
    v_naminit           tcenter.naminite%type;
    v_naminite          tcenter.naminite%type;
    v_naminitt          tcenter.naminitt%type;
    v_naminit3          tcenter.naminit3%type;
    v_naminit4          tcenter.naminit4%type;
    v_naminit5          tcenter.naminit5%type;
    v_flgact            tcenter.flgact%type;
    v_costcent          tcenter.costcent%type;
    v_compgrp           tcenter.compgrp%type;
    v_codposr           tcenter.codposr%type;
    v_codappr           tcenterlog.codappr%type;
    v_dteappr           tcenterlog.dteappr%type;
    v_namcentoe         tcenterlog.namcentoe%type;
    v_namcentot         tcenterlog.namcentot%type;
    v_namcento3         tcenterlog.namcento3%type;
    v_namcento4         tcenterlog.namcento4%type;
    v_namcento5         tcenterlog.namcento5%type;
    v_naminitoe         tcenterlog.naminitoe%type;
    v_naminitot         tcenterlog.naminitot%type;
    v_naminito3         tcenterlog.naminito3%type;
    v_naminito4         tcenterlog.naminito4%type;
    v_naminito5         tcenterlog.naminito5%type;
    v_flgacto           tcenterlog.flgacto%type;
    v_costcento         tcenterlog.costcento%type;
    v_compgrpo          tcenterlog.compgrpo%type;
    v_codposro          tcenterlog.codposro%type;
    v_flgcal            tcenterlog.flgcal%type;

    v_codcompy          tcenter.codcompy%type;
    v_comlevel          tcenter.comlevel%type;
    v_detl_tbl          varchar2(50) ;
    v_detl_column       varchar2(50) ;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      -----------------------------------
        v_flg             := hcm_util.get_string_t(json_params, 'flg');
        v_dteeffec        := to_date(trim(hcm_util.get_string_t(json_params, 'dteeffec')),'dd/mm/yyyy');
        v_codcomp         := get_compful (hcm_util.get_string_t(json_params, 'codcomp'));
        v_namcent         := hcm_util.get_string_t(json_params, 'namcent');
        v_namcente        := hcm_util.get_string_t(json_params, 'namcente');
        v_namcentt        := hcm_util.get_string_t(json_params, 'namcentt');
        v_namcent3        := hcm_util.get_string_t(json_params, 'namcent3');
        v_namcent4        := hcm_util.get_string_t(json_params, 'namcent4');
        v_namcent5        := hcm_util.get_string_t(json_params, 'namcent5');
        v_codcom          := hcm_util.get_string_t(json_params, 'codcom');

        v_naminit         := hcm_util.get_string_t(json_params, 'naminit');
        v_naminite        := hcm_util.get_string_t(json_params, 'naminite');
        v_naminitt        := hcm_util.get_string_t(json_params, 'naminitt');
        v_naminit3        := hcm_util.get_string_t(json_params, 'naminit3');
        v_naminit4        := hcm_util.get_string_t(json_params, 'naminit4');
        v_naminit5        := hcm_util.get_string_t(json_params, 'naminit5');
        v_flgact          := hcm_util.get_string_t(json_params, 'flgact');
        v_costcent        := hcm_util.get_string_t(json_params, 'costcent');
        v_compgrp         := hcm_util.get_string_t(json_params, 'compgrp');
        v_codposr         := hcm_util.get_string_t(json_params, 'codposr');
        v_codappr         := hcm_util.get_string_t(json_params, 'codappr');
        v_dteappr         := to_date(trim(hcm_util.get_string_t(json_params, 'dteappr')),'dd/mm/yyyy');
        v_codcompy        := hcm_util.get_string_t(json_params, 'codcompy');
        v_comlevel        := hcm_util.get_string_t(json_params, 'comlevel');

        -----------------------------------------------
        v_flgsecu := secur_main.secur2(v_codappr, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
          if not v_flgsecu  then
            param_msg_error   := get_error_msg_php('HR3007', global_v_lang);
            json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
            return;
          end if;
        -----------------------------------------------
--        FOR codcom IN ( SELECT REGEXP_SUBSTR (v_codcom,'[^-]+',1,LEVEL) txt ,
--                            level lev
--                     FROM   DUAL
--                     CONNECT BY REGEXP_SUBSTR (v_codcom, '[^-]+',1, LEVEL) IS NOT NULL )
--        LOOP
--           CASE codcom.lev
--              when 1 then v_codcom1 := codcom.txt ;
--              when 2 then v_codcom2 := codcom.txt ;
--              when 3 then v_codcom3 := codcom.txt ;
--              when 4 then v_codcom4 := codcom.txt ;
--              when 5 then v_codcom5 := codcom.txt ;
--              when 6 then v_codcom6 := codcom.txt ;
--              when 7 then v_codcom7 := codcom.txt ;
--              when 8 then v_codcom8 := codcom.txt ;
--              when 9 then v_codcom9 := codcom.txt ;
--              when 10 then v_codcom10 := codcom.txt ;
--           END CASE;
--        END LOOP ;
        v_codcom1 := get_comp_split (v_codcomp,1);
        v_codcom2 := get_comp_split (v_codcomp,2);
        v_codcom3 := get_comp_split (v_codcomp,3);
        v_codcom4 := get_comp_split (v_codcomp,4);
        v_codcom5 := get_comp_split (v_codcomp,5);
        v_codcom6 := get_comp_split (v_codcomp,6);
        v_codcom7 := get_comp_split (v_codcomp,7);
        v_codcom8 := get_comp_split (v_codcomp,8);
        v_codcom9 := get_comp_split (v_codcomp,9);
        v_codcom10 := get_comp_split (v_codcomp,10);
        -----------------------------------------------
        if global_v_lang = '101' then
          v_namcente := v_namcent;
          v_naminite := v_naminit;
        elsif global_v_lang = '102' then
          v_namcentt := v_namcent;
          v_naminitt := v_naminit;
        elsif global_v_lang = '103' then
          v_namcent3 := v_namcent;
          v_naminit3 := v_naminit;
        elsif global_v_lang = '104' then
          v_namcent4 := v_namcent;
          v_naminit4 := v_naminit;
        elsif global_v_lang = '105' then
          v_namcent5 := v_namcent;
          v_naminit5 := v_naminit;
        end if;

        if v_flg = 'delete' then
           begin
             delete tcenter
             where codcomp = v_codcomp;
           exception when others then
             param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
           end;
        else
          -------------------------------------------------
          /*User37 #3830 Final Test Phase 1 V11 05/03/2021 if v_dteeffec < trunc(sysdate) then
            param_msg_error := get_error_msg_php('HR1501', global_v_lang);
            json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
            return;
          end if;*/
          -------------------------------------------------
--          select count('x')
--          into   v_count
--          from   tcenterlog t1
--          where  t1.codcomp = v_codcomp and t1.dteeffec = v_dteeffec and t1.flgcal = 'Y' ;
--          -------------------------------------------------
--          if v_count > 0 then
--            param_msg_error := get_error_msg_php('HR8836', global_v_lang);
--            json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
--            return;
--          end if ;
          -------------------------------------------------
          --<< wanlapa #683 09/02/2023
          if v_dteeffec <= trunc(sysdate) then
          -->> wanlapa #683 09/02/2023
--          if v_dteeffec = trunc(sysdate) then
            begin
              insert into tcenter
                 (codcomp, namcente, namcentt, namcent3, namcent4, namcent5,
                  codcom1, codcom2, codcom3, codcom4, codcom5, codcom6, codcom7, codcom8, codcom9, codcom10,
                  naminite, naminitt, naminit3, naminit4, naminit5,
                  flgact , costcent, compgrp, codposr, dtecreate, codcreate, dteupd, coduser ,codcompy, comlevel )
              values
                 (v_codcomp, v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5,
                  v_codcom1, v_codcom2, v_codcom3, v_codcom4, v_codcom5, v_codcom6, v_codcom7, v_codcom8, v_codcom9, v_codcom10,
                  v_naminite, v_naminitt, v_naminit3, v_naminit4, v_naminit5,
                  decode(v_flgact,3,1,v_flgact),  v_costcent, v_compgrp, v_codposr, sysdate, global_v_coduser, sysdate, global_v_coduser, v_codcompy, v_comlevel);
            exception
              when DUP_VAL_ON_INDEX then
                update tcenter
                set    namcente = v_namcente,namcentt = v_namcentt,namcent3 = v_namcent3,namcent4 = v_namcent4,namcent5 = v_namcent5,
                       codcom1 = v_codcom1,codcom2 = v_codcom2,codcom3 = v_codcom3,codcom4 = v_codcom4,codcom5 = v_codcom5,codcom6 = v_codcom6,codcom7 = v_codcom7,codcom8 = v_codcom8,codcom9 = v_codcom9,codcom10 = v_codcom10,
                       naminite = v_naminite,naminitt = v_naminitt,naminit3 = v_naminit3,naminit4 = v_naminit4,naminit5 = v_naminit5,
                       flgact = decode(v_flgact,3,1,v_flgact),costcent = v_costcent,compgrp = v_compgrp,codposr = v_codposr,
                       dteupd = sysdate,coduser = global_v_coduser,
                       codcompy = v_codcompy,comlevel = v_comlevel
                where  codcomp = v_codcomp;
              when others then
               param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
               json_str_output   := get_response_message(400, param_msg_error , global_v_lang);
               rollback ;
               return ;
            end ;
          end if ;
            v_flgcal := 'N' ;
            -----------------------------------------------------
            begin
                select t.flgact , t.costcent , t.compgrp , t.codposr ,
                       t.namcente , t.namcentt , t.namcent3 , t.namcent4 , t.namcent5 ,
                       t.naminite , t.naminitt , t.naminit3 , t.naminit4 , t.naminit5
                into   v_flgacto , v_costcento , v_compgrpo , v_codposro ,
                       v_namcentoe , v_namcentot , v_namcento3 , v_namcento4 , v_namcento5 ,
                       v_naminitoe , v_naminitot , v_naminito3 , v_naminito4 , v_naminito5
                from ( select *
                       from   tcenterlog
                       where  codcomp = v_codcomp
                              and dteeffec < v_dteeffec
                       order by v_dteeffec desc ) t
                where rownum = 1 ;
            exception when NO_DATA_FOUND then
                v_flgacto := '' ;
                v_costcento := '' ;
                v_compgrpo := '' ;
                v_codposro := '' ;
                v_namcentoe := '' ;
                v_namcentot := '' ;
                v_namcento3 := '' ;
                v_namcento4 := '' ;
                v_namcento5 := '' ;
                v_naminitoe := '' ;
                v_naminitot := '' ;
                v_naminito3 := '' ;
                v_naminito4 := '' ;
                v_naminito5 := '' ;
            end ;
            -----------------------------------------------------
            begin
              insert into tcenterlog
                (codcomp, dteeffec, namcente, namcentt, namcent3, namcent4, namcent5,
                 codcom1, codcom2, codcom3, codcom4, codcom5, codcom6, codcom7, codcom8, codcom9, codcom10,
                 namcentoe, namcentot, namcento3, namcento4, namcento5,
                 naminite, naminitt, naminit3, naminit4, naminit5,
                 naminitoe, naminitot, naminito3, naminito4, naminito5,
                 flgact, flgacto, costcent, compgrp, codposr, codappr, dteappr, costcento, compgrpo, codposro, flgcal,
                 dtecreate, codcreate, dteupd, coduser, codcompy, comlevel)
              values
                (v_codcomp, v_dteeffec, v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5,
                 v_codcom1, v_codcom2, v_codcom3, v_codcom4, v_codcom5, v_codcom6, v_codcom7, v_codcom8, v_codcom9, v_codcom10,
                 v_namcentoe, v_namcentot, v_namcento3, v_namcento4, v_namcento5,
                 v_naminite, v_naminitt, v_naminit3, v_naminit4, v_naminit5,
                 v_naminitoe, v_naminitot, v_naminito3, v_naminito4, v_naminito5,
                 v_flgact, v_flgacto, v_costcent, v_compgrp, v_codposr, v_codappr, v_dteappr, v_costcento, v_compgrpo, v_codposro, v_flgcal,
                 sysdate, global_v_coduser, sysdate, global_v_coduser, v_codcompy, v_comlevel);
            exception
              when DUP_VAL_ON_INDEX then
                  update tcenterlog
                     set namcente = v_namcente,namcentt = v_namcentt,namcent3 = v_namcent3,namcent4 = v_namcent4,namcent5 = v_namcent5,
                         codcom1 = v_codcom1,codcom2 = v_codcom2,codcom3 = v_codcom3,codcom4 = v_codcom4,codcom5 = v_codcom5,codcom6 = v_codcom6,codcom7 = v_codcom7,codcom8 = v_codcom8,codcom9 = v_codcom9,codcom10 = v_codcom10,
                         naminite = v_naminite,naminitt = v_naminitt,naminit3 = v_naminit3,naminit4 = v_naminit4,naminit5 = v_naminit5,
                         flgact = v_flgact,flgacto = v_flgacto,
                         costcent = v_costcent,compgrp = v_compgrp,codposr = v_codposr,codappr = v_codappr,dteappr = v_dteappr,
                         flgcal = v_flgcal,
                         dteupd = sysdate ,coduser = global_v_coduser  , codcompy = v_codcompy,comlevel = v_comlevel
                   where codcomp = v_codcomp
                         and dteeffec = v_dteeffec;
              when others then
               param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
               json_str_output   := get_response_message(400, param_msg_error , global_v_lang);
               rollback ;
               return ;
            end ;
          end if ;

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
  end save_detail_tcenter;
----------------------------------------------------------------------------------
  procedure get_detail_tcenter (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tcenter(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail_tcenter;
----------------------------------------------------------------------------------
  procedure gen_detail_tcenter(json_str_output out clob) is
    obj_data            json_object_t;
    v_count             number;
    v_codcomp           tcenter.codcomp%type;
    v_namcent           tcenter.namcente%type;
    v_namcente          tcenter.namcente%type;
    v_namcentt          tcenter.namcentt%type;
    v_namcent3          tcenter.namcent3%type;
    v_namcent4          tcenter.namcent4%type;
    v_namcent5          tcenter.namcent5%type;

    v_namcento          tcenterlog.namcentoe%type;
    v_namcentoe         tcenterlog.namcentoe%type;
    v_namcentot         tcenterlog.namcentot%type;
    v_namcento3         tcenterlog.namcento3%type;
    v_namcento4         tcenterlog.namcento4%type;
    v_namcento5         tcenterlog.namcento5%type;

    v_codcom1           tcenter.codcom1%type;
    v_codcom2           tcenter.codcom2%type;
    v_codcom3           tcenter.codcom3%type;
    v_codcom4           tcenter.codcom4%type;
    v_codcom5           tcenter.codcom5%type;
    v_codcom6           tcenter.codcom6%type;
    v_codcom7           tcenter.codcom7%type;
    v_codcom8           tcenter.codcom8%type;
    v_codcom9           tcenter.codcom9%type;
    v_codcom10          tcenter.codcom10%type;
    v_codcompy          tcenter.codcompy%type;
    v_comlevel          tcenter.comlevel%type;
    v_comlevel_parent   tcenter.comlevel%type;
    v_comparent         tcenter.comparent%type;
    v_naminit           tcenter.naminite%type;

    v_naminite          tcenter.naminite%type;
    v_naminitt          tcenter.naminitt%type;
    v_naminit3          tcenter.naminit3%type;
    v_naminit4          tcenter.naminit4%type;
    v_naminit5          tcenter.naminit5%type;

    v_naminito          tcenterlog.naminitoe%type;
    v_naminitoe          tcenterlog.naminitoe%type;
    v_naminitot          tcenterlog.naminitot%type;
    v_naminito3          tcenterlog.naminito3%type;
    v_naminito4          tcenterlog.naminito4%type;
    v_naminito5          tcenterlog.naminito5%type;

    v_flgact            tcenter.flgact%type;
    v_codproft          tcenter.codproft%type;
    v_costcent          tcenter.costcent%type;
    v_compgrp           tcenter.compgrp%type;
    v_codposr           tcenter.codposr%type;
    v_codemprp          tcenter.codemprp%type;

    v_codappr           tcenterlog.codappr%type;
    v_dteappr           tcenterlog.dteappr%type;

    v_dteupd            tcenterlog.dteupd%type;
    v_coduser           tcenterlog.coduser%type;

    v_message_error     varchar2(2000) ;
    v_error_code        varchar2(20) ;
    v_max_dteeffec      date;
    v_flgdisable        boolean;
    v_count_parent      number;
  begin
--      p_codcomp     := 'TJSABCDEFGHIJKLMNOPQR';
--      p_dteeffec    := sysdate;
--      p_comlevel    := 0;
--      p_codcompy    := 'TJS';
      
      p_codcomp := get_compful (p_codcomp);
      v_flgdisable := false;
      -------------------------------------------------
      if p_dteeffec < trunc(sysdate) then
        begin
            select max(dteeffec)
              into v_max_dteeffec
              from tcenterlog
             where codcomp = p_codcomp
               and dteeffec <= p_dteeffec;
        exception when others then
            v_max_dteeffec := null;
        end;
        if v_max_dteeffec is not null then
            v_message_error := replace(regexp_substr(get_error_msg_php('HR1501', global_v_lang), '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%','') ;
            v_error_code    := 'HR1501';
            v_flgdisable    := true;
            p_dteeffec      := v_max_dteeffec;
        end if;
        --<<User37 #3830 Final Test Phase 1 V11 05/03/2021
        /*begin
            select max(dteeffec)
              into v_max_dteeffec
              from tcenterlog
             where codcomp = p_codcomp;
        exception when others then
            v_max_dteeffec := null;
        end;
        if v_max_dteeffec is not null then
            if v_max_dteeffec < p_dteeffec then
                v_message_error := replace(regexp_substr(get_error_msg_php('HR1501', global_v_lang), '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%','') ;
                v_error_code    := 'HR1501';
                v_flgdisable    := true;
                p_dteeffec      := v_max_dteeffec;
            end if;
        end if;*/
        -->>User37 #3830 Final Test Phase 1 V11 05/03/2021
      end if;

      -------------------------------------------------
      if v_error_code is null then
          select count('x')
            into v_count
            from tcenterlog t1
           where t1.codcomp = p_codcomp
--             and t1.dteeffec <= trunc(sysdate)
             and t1.dteeffec < trunc(sysdate)
             and t1.flgcal = 'N' ;
           -------------------------------------------------
          if v_count > 0 then
            v_message_error := replace(regexp_substr(get_error_msg_php('HR8835', global_v_lang), '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%','') ;
            v_error_code    := 'HR8835';
            v_flgdisable    := true;
          end if ;
      end if;
      -------------------------------------------------
      if v_error_code is null then
          select count('x')
            into v_count
            from tcenterlog t1
           where t1.codcomp = p_codcomp
             and t1.dteeffec = p_dteeffec
             and t1.flgcal = 'Y' ;
           -------------------------------------------------
          if v_count > 0 and p_dteeffec <> trunc(sysdate) then
            v_message_error := replace(regexp_substr(get_error_msg_php('HR8836', global_v_lang), '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%','') ;
            v_error_code    := 'HR8836';
            v_flgdisable    := true;
          end if ;
      end if;
      -------------------------------------------------
      begin
        select t1.codcomp,
               nvl( decode(global_v_lang, '101', t1.namcente,
                                          '102', t1.namcentt,
                                          '103', t1.namcent3,
                                          '104', t1.namcent4,
                                          '105', t1.namcent5,
                                          t1.namcente) ,
                    decode(global_v_lang, '101', t2.namcente,
                                          '102', t2.namcentt,
                                          '103', t2.namcent3,
                                          '104', t2.namcent4,
                                          '105', t2.namcent5,
                                          t2.namcente) ) as namcent ,
               t1.namcente, t1.namcentt, t1.namcent3, t1.namcent4, t1.namcent5,
               t1.codcom1, t1.codcom2, t1.codcom3, t1.codcom4, t1.codcom5, t1.codcom6, t1.codcom7, t1.codcom8, t1.codcom9, t1.codcom10,
               t1.codcompy, t1.comlevel,
               nvl( decode(global_v_lang, '101', t1.naminite,
                                          '102', t1.naminitt,
                                          '103', t1.naminit3,
                                          '104', t1.naminit4,
                                          '105', t1.naminit5,
                                          t1.naminite) ,
                    decode(global_v_lang, '101', t2.naminite,
                                          '102', t2.naminitt,
                                          '103', t2.naminit3,
                                          '104', t2.naminit4,
                                          '105', t2.naminit5,
                                          t2.naminite) )  as naminit ,
               t1.naminite, t1.naminitt, t1.naminit3, t1.naminit4, t1.naminit5,
               t1.flgact, t1.codproft, t1.costcent, t1.compgrp, t1.codposr,
               nvl( decode(global_v_lang, '101', t1.namcentoe,
                                          '102', t1.namcentot,
                                          '103', t1.namcento3,
                                          '104', t1.namcento4,
                                          '105', t1.namcento5,
                                          t1.namcentoe) ,
                    decode(global_v_lang, '101', t2.namcente,
                                          '102', t2.namcentt,
                                          '103', t2.namcent3,
                                          '104', t2.namcent4,
                                          '105', t2.namcent5,
                                          t2.namcente) ) as namcento ,
               t1.namcentoe , t1.namcentot , t1.namcento3 , t1.namcento4 , t1.namcento5 ,
               nvl( decode(global_v_lang, '101', t1.naminitoe,
                                          '102', t1.naminitot,
                                          '103', t1.naminito3,
                                          '104', t1.naminito4,
                                          '105', t1.naminito5,
                                          t1.naminitoe) ,
                    decode(global_v_lang, '101', t2.naminite,
                                          '102', t2.naminitt,
                                          '103', t2.naminit3,
                                          '104', t2.naminit4,
                                          '105', t2.naminit5,
                                          t2.naminite) ) as naminito ,
               t1.naminitoe , t1.naminitot , t1.naminito3 , t1.naminito4 , t1.naminito5 ,
               t1.codappr , t1.dteappr , t1.dteupd , t1.coduser,t2.codemprp
          into v_codcomp,
               v_namcent, v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5,
               v_codcom1, v_codcom2, v_codcom3, v_codcom4, v_codcom5, v_codcom6, v_codcom7, v_codcom8, v_codcom9, v_codcom10,
               v_codcompy, v_comlevel,
               v_naminit, v_naminite, v_naminitt, v_naminit3, v_naminit4, v_naminit5,
               v_flgact, v_codproft, v_costcent, v_compgrp, v_codposr ,
               v_namcento , v_namcentoe , v_namcentot , v_namcento3 , v_namcento4 , v_namcento5 ,
               v_naminito , v_naminitoe , v_naminitot , v_naminito3 , v_naminito4, v_naminito5 ,
               v_codappr , v_dteappr , v_dteupd , v_coduser, v_codemprp
          from tcenterlog t1
     left join tcenter t2 on t1.codcomp = t2.codcomp
         where t1.codcomp = p_codcomp
           and t1.dteeffec = p_dteeffec and t1.dteeffec > trunc(sysdate);
          -----------------------------------
      exception when NO_DATA_FOUND THEN
        begin
            select codcomp,
                   decode(global_v_lang,  '101', namcente,
                                          '102', namcentt,
                                          '103', namcent3,
                                          '104', namcent4,
                                          '105', namcent5,
                                          namcente) as namcent ,
                   namcente, namcentt, namcent3, namcent4, namcent5,
                   codcom1, codcom2, codcom3, codcom4, codcom5, codcom6, codcom7, codcom8, codcom9, codcom10,
                   codcompy, comlevel,
                   decode(global_v_lang,  '101', naminite,
                                          '102', naminitt,
                                          '103', naminit3,
                                          '104', naminit4,
                                          '105', naminit5,
                                          naminite) as naminit ,
                   naminite, naminitt, naminit3, naminit4, naminit5,
                   flgact, codproft, costcent, compgrp, codposr,
                   decode(global_v_lang,  '101', namcente,
                                          '102', namcentt,
                                          '103', namcent3,
                                          '104', namcent4,
                                          '105', namcent5,
                                          namcente) as namcento ,
                   namcente as namcentoe , namcentt as namcentot ,  namcent3 as namcento3 ,  namcent4 as namcento4 ,  namcent5 as namcento5 ,
                   decode(global_v_lang,  '101', naminite,
                                          '102', naminitt,
                                          '103', naminit3,
                                          '104', naminit4,
                                          '105', naminit5,
                                          naminite) as naminito ,
                   naminite as naminitoe , naminitt as naminitot , naminit3 as naminito3 , naminit4 as naminito4 , naminit5 as naminito5 ,
                   '' as codappr , '' as dteappr , dteupd , coduser, codemprp
              into v_codcomp,
                   v_namcent, v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5,
                   v_codcom1, v_codcom2, v_codcom3, v_codcom4, v_codcom5, v_codcom6, v_codcom7, v_codcom8, v_codcom9, v_codcom10,
                   v_codcompy, v_comlevel,
                   v_naminit, v_naminite, v_naminitt, v_naminit3, v_naminit4, v_naminit5,
                   v_flgact, v_codproft, v_costcent, v_compgrp, v_codposr,
                   v_namcento , v_namcentoe , v_namcentot , v_namcento3 , v_namcento4 , v_namcento5 ,
                   v_naminito , v_naminitoe , v_naminitot , v_naminito3 , v_naminito4, v_naminito5 ,
                   v_codappr , v_dteappr , v_dteupd , v_coduser, v_codemprp
              from tcenter
             where codcomp = p_codcomp;
         exception when NO_DATA_FOUND THEN
            v_codcompy  := get_comp_split (p_codcomp,1);
            v_codcom1   := get_comp_split (p_codcomp,1);
            v_codcom2   := get_comp_split (p_codcomp,2);
            v_codcom3   := get_comp_split (p_codcomp,3);
            v_codcom4   := get_comp_split (p_codcomp,4);
            v_codcom5   := get_comp_split (p_codcomp,5);
            v_codcom6   := get_comp_split (p_codcomp,6);
            v_codcom7   := get_comp_split (p_codcomp,7);
            v_codcom8   := get_comp_split (p_codcomp,8);
            v_codcom9   := get_comp_split (p_codcomp,9);
            v_codcom10  := get_comp_split (p_codcomp,10);
            if p_comlevel > 0 then
                v_comlevel := p_comlevel;
            else
                if lpad(nvl(v_codcom10,'0'),4,'0') != '0000' then
                    v_comlevel := 10;
                elsif lpad(nvl(v_codcom9,'0'),4,'0') != '0000' then
                    v_comlevel := 9;
                elsif lpad(nvl(v_codcom8,'0'),4,'0') != '0000' then
                    v_comlevel := 8;
                elsif lpad(nvl(v_codcom7,'0'),4,'0') != '0000' then
                    v_comlevel := 7;
                elsif lpad(nvl(v_codcom6,'0'),4,'0') != '0000' then
                    v_comlevel := 6;
                elsif lpad(nvl(v_codcom5,'0'),4,'0') != '0000' then
                    v_comlevel := 5;
                elsif lpad(nvl(v_codcom4,'0'),4,'0') != '0000' then
                    v_comlevel := 4;
                elsif lpad(nvl(v_codcom3,'0'),4,'0') != '0000' then
                    v_comlevel := 3;
                elsif lpad(nvl(v_codcom2,'0'),4,'0') != '0000' then
                    v_comlevel := 2;
                end if;    
            end if;
            
            v_comparent := get_codcomp_parent (p_codcomp,v_comlevel);
            
            begin
                select count(*)
                  into v_count_parent
                  from tcenter
                 where codcomp = v_comparent;
            exception when others then
                v_count_parent := 0;
            end;
            
            if v_count_parent = 0 then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;
            
            begin
                select compgrp
                  into v_compgrp
                  from tcompny
                 where codcompy = v_codcompy;
            exception when others then
                v_compgrp := null;
            end;
            
            begin
                select decode(global_v_lang,  '101', namcompe,
                                              '102', namcompt,
                                              '103', namcomp3,
                                              '104', namcomp4,
                                              '105', namcomp5,
                                              namcompe),
                       namcompe, namcompt, namcomp3, namcomp4, namcomp5
                  into v_namcent, v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5
                  from tcompnyd
                 where codcompy = v_codcompy
                   and codcomp = get_comp_split (p_codcomp,v_comlevel)
                   and comlevel = v_comlevel;
            exception when no_data_found then
                v_namcent   := null;
                v_namcente  := null;
                v_namcentt  := null;
                v_namcent3  := null;
                v_namcent4  := null;
                v_namcent5  := null;
            end;
         end;
      end;

    if v_message_error is null then
       obj_data          := json_object_t();
       obj_data.put('coderror', '200');
    else
       obj_data := json_object_t(get_response_message('200',v_message_error,global_v_lang));
       obj_data.put('desc_response', v_message_error);
       obj_data.put('desc_coderror', v_error_code);
    end if ;
    obj_data.put('codcomp', p_codcomp);
    obj_data.put('dteeffec', to_char(p_dteeffec, 'dd/mm/yyyy'));
    obj_data.put('namcent', v_namcent);
    obj_data.put('namcente', v_namcente);
    obj_data.put('namcentt', v_namcentt);
    obj_data.put('namcent3', v_namcent3);
    obj_data.put('namcent4', v_namcent4);
    obj_data.put('namcent5', v_namcent5);
    obj_data.put('codcom1', v_codcom1);
    obj_data.put('codcom2', v_codcom2);
    obj_data.put('codcom3', v_codcom3);
    obj_data.put('codcom4', v_codcom4);
    obj_data.put('codcom5', v_codcom5);
    obj_data.put('codcom6', v_codcom6);
    obj_data.put('codcom7', v_codcom7);
    obj_data.put('codcom8', v_codcom8);
    obj_data.put('codcom9', v_codcom9);
    obj_data.put('codcom10', v_codcom10);
    obj_data.put('codcompy', v_codcompy);
    obj_data.put('comlevel', v_comlevel);
    obj_data.put('comparent', v_comparent);
    obj_data.put('comlevel', v_comlevel);
    obj_data.put('naminit', v_naminit);
    obj_data.put('naminite', v_naminite);
    obj_data.put('naminitt', v_naminitt);
    obj_data.put('naminit3', v_naminit3);
    obj_data.put('naminit4', v_naminit4);
    obj_data.put('naminit5', v_naminit5);
    obj_data.put('flgact', v_flgact);
    obj_data.put('codproft', v_codproft);
    obj_data.put('costcent', v_costcent);
    obj_data.put('compgrp', v_compgrp);
    obj_data.put('codposr', v_codposr);
    obj_data.put('namcento', v_namcento);
    obj_data.put('namcentoe', v_namcentoe);
    obj_data.put('namcentot', v_namcentot);
    obj_data.put('namcento3', v_namcento3);
    obj_data.put('namcento4', v_namcento4);
    obj_data.put('namcento5', v_namcento5);
    obj_data.put('naminito', v_naminito);
    obj_data.put('naminitoe', v_naminitoe);
    obj_data.put('naminitot', v_naminitot);
    obj_data.put('naminito3', v_naminito3);
    obj_data.put('naminito4', v_naminito4);
    obj_data.put('naminito5', v_naminito5);
    obj_data.put('codappr', nvl(v_codappr,global_v_codempid));
    obj_data.put('dteappr', to_char(nvl(v_dteappr,sysdate), 'dd/mm/yyyy'));
    obj_data.put('dteupd', to_char(v_dteupd, 'dd/mm/yyyy'));
    obj_data.put('coduser', v_coduser);
    obj_data.put('codempid', get_codempid(v_coduser));
    obj_data.put('flgdisable', v_flgdisable);
    obj_data.put('temploy_name', get_codempid(v_coduser)|| ' - ' ||get_temploy_name(get_codempid(v_coduser), global_v_lang));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail_tcenter;
----------------------------------------------------------------------------------
  procedure get_dteeffec_by_codcomp (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    obj_data            json_object_t;
    v_dteeffec          tcenterlog.dteeffec%type;
    v_codcomp_show      varchar2(100 char);
    v_count             number;
    v_message_error     varchar2(2000) ;
    v_error_code        varchar2(20) ;
    v_codcomp           tcenter.codcomp%type;
    v_namcent           tcenter.namcente%type;
    v_namcente          tcenter.namcente%type;
    v_namcentt          tcenter.namcentt%type;
    v_namcent3          tcenter.namcent3%type;
    v_namcent4          tcenter.namcent4%type;
    v_namcent5          tcenter.namcent5%type;

    v_namcento         tcenterlog.namcentoe%type;
    v_namcentoe         tcenterlog.namcentoe%type;
    v_namcentot         tcenterlog.namcentot%type;
    v_namcento3         tcenterlog.namcento3%type;
    v_namcento4         tcenterlog.namcento4%type;
    v_namcento5         tcenterlog.namcento5%type;

    v_codcom1           tcenter.codcom1%type;
    v_codcom2           tcenter.codcom2%type;
    v_codcom3           tcenter.codcom3%type;
    v_codcom4           tcenter.codcom4%type;
    v_codcom5           tcenter.codcom5%type;
    v_codcom6           tcenter.codcom6%type;
    v_codcom7           tcenter.codcom7%type;
    v_codcom8           tcenter.codcom8%type;
    v_codcom9           tcenter.codcom9%type;
    v_codcom10          tcenter.codcom10%type;
    v_codcompy          tcenter.codcompy%type;
    v_comlevel          tcenter.comlevel%type;
    v_comparent         tcenter.comparent%type;
    v_naminit           tcenter.naminite%type;

    v_naminite          tcenter.naminite%type;
    v_naminitt          tcenter.naminitt%type;
    v_naminit3          tcenter.naminit3%type;
    v_naminit4          tcenter.naminit4%type;
    v_naminit5          tcenter.naminit5%type;

    v_naminito          tcenterlog.naminitoe%type;
    v_naminitoe          tcenterlog.naminitoe%type;
    v_naminitot          tcenterlog.naminitot%type;
    v_naminito3          tcenterlog.naminito3%type;
    v_naminito4          tcenterlog.naminito4%type;
    v_naminito5          tcenterlog.naminito5%type;

    v_flgact            tcenter.flgact%type;
    v_codproft          tcenter.codproft%type;
    v_costcent          tcenter.costcent%type;
    v_compgrp           tcenter.compgrp%type;
    v_codposr           tcenter.codposr%type;

    v_codappr            tcenterlog.codappr%type;
    v_dteappr            tcenterlog.dteappr%type;

    v_dteupd             tcenterlog.dteupd%type;
    v_coduser            tcenterlog.coduser%type;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      ---------------------------------------
       v_dteeffec := '' ;
       begin
           select ( t1.codcom1 || nvl2(t1.codcom2,'-'||t1.codcom2,'') || nvl2(t1.codcom3,'-'||t1.codcom3,'') || nvl2(t1.codcom4,'-'||t1.codcom4,'') || nvl2(t1.codcom5,'-'||t1.codcom5,'') ||
                    nvl2(t1.codcom6,'-'||t1.codcom6,'') || nvl2(t1.codcom7,'-'||t1.codcom7,'') || nvl2(t1.codcom8,'-'||t1.codcom8,'') || nvl2(t1.codcom9,'-'||t1.codcom9,'') || nvl2(t1.codcom10,'-'||t1.codcom10,'') ) as codcomp_show ,
                   t1.dteeffec,t1.codcomp
           into   v_codcomp_show,v_dteeffec,v_codcomp
           from tcenterlog t1 ,
                 ( select t1.codcomp ,max( t1.dteeffec) dteeffec
                   from   tcenterlog t1
                   group by t1.codcomp ) t2
           where t1.codcomp = t2.codcomp and t1.dteeffec = t2.dteeffec and t1.codcomp = p_codcomp ;
       exception when NO_DATA_FOUND then
          ---------------------------------------
          select ( t1.codcom1 || nvl2(t1.codcom2,'-'||t1.codcom2,'') || nvl2(t1.codcom3,'-'||t1.codcom3,'') || nvl2(t1.codcom4,'-'||t1.codcom4,'') || nvl2(t1.codcom5,'-'||t1.codcom5,'') ||
                              nvl2(t1.codcom6,'-'||t1.codcom6,'') || nvl2(t1.codcom7,'-'||t1.codcom7,'') || nvl2(t1.codcom8,'-'||t1.codcom8,'') || nvl2(t1.codcom9,'-'||t1.codcom9,'') || nvl2(t1.codcom10,'-'||t1.codcom10,'') ) as codcomp_show ,
                 trunc(t1.dteupd),codcomp
          into   v_codcomp_show,v_dteeffec,v_codcomp
          from   tcenter t1
          where  t1.codcomp = p_codcomp ;

          v_dteeffec := to_date(trim(to_char(sysdate,'dd/mm/yyyy')),'dd/mm/yyyy');
          ---------------------------------------
       end ;
       ---------------------------------------
       if v_dteeffec is null then
        v_dteeffec := to_date(trim(to_char(sysdate,'dd/mm/yyyy')),'dd/mm/yyyy');
       end if;
             -------------------------------------------------
      --<<User37 #3830 Final Test Phase 1 V11 05/03/2021
      /*if v_dteeffec < trunc(sysdate) then
        v_message_error := replace(regexp_substr(get_error_msg_php('HR1501', global_v_lang), '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%','') ;
        v_error_code := 'HR1501';
      end if;*/
      -->>User37 #3830 Final Test Phase 1 V11 05/03/2021
      -------------------------------------------------
      select count('x')
      into   v_count
      from   tcenterlog t1
      where  t1.codcomp = p_codcomp and t1.dteeffec = v_dteeffec
             and t1.dteeffec < trunc(sysdate) and t1.flgcal = 'Y' ;
      -------------------------------------------------
      if v_count > 0 then
        v_message_error := replace(regexp_substr(get_error_msg_php('HR8836', global_v_lang), '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%','') ;
        v_error_code := 'HR8836';
      end if ;
      -------------------------------------------------
      select count('x')
      into   v_count
      from   tcenterlog t1
      where  t1.codcomp = p_codcomp and t1.dteeffec = v_dteeffec
             and t1.dteeffec >= trunc(sysdate) and t1.flgcal = 'N' ;
       -------------------------------------------------
      if v_count > 0 then
        v_message_error := '01-'||replace(regexp_substr(get_error_msg_php('HR8835', global_v_lang), '.*[@]+[#]+[$]+[%]|.*', 1, 1),'@#$%','') ;
        v_error_code := 'HR8835';
      end if ;
      begin
        select t1.codcomp,
               nvl( decode(global_v_lang, '101', t1.namcente,
                                          '102', t1.namcentt,
                                          '103', t1.namcent3,
                                          '104', t1.namcent4,
                                          '105', t1.namcent5,
                                          t1.namcente) ,
                    decode(global_v_lang, '101', t2.namcente,
                                          '102', t2.namcentt,
                                          '103', t2.namcent3,
                                          '104', t2.namcent4,
                                          '105', t2.namcent5,
                                          t2.namcente) ) as namcent ,
               t1.namcente, t1.namcentt, t1.namcent3, t1.namcent4, t1.namcent5,
               t1.codcom1, t1.codcom2, t1.codcom3, t1.codcom4, t1.codcom5, t1.codcom6, t1.codcom7, t1.codcom8, t1.codcom9, t1.codcom10,
               t1.codcompy, t1.comlevel,
               nvl( decode(global_v_lang, '101', t1.naminite,
                                          '102', t1.naminitt,
                                          '103', t1.naminit3,
                                          '104', t1.naminit4,
                                          '105', t1.naminit5,
                                          t1.naminite) ,
                    decode(global_v_lang, '101', t2.naminite,
                                          '102', t2.naminitt,
                                          '103', t2.naminit3,
                                          '104', t2.naminit4,
                                          '105', t2.naminit5,
                                          t2.naminite) )  as naminit ,
               t1.naminite, t1.naminitt, t1.naminit3, t1.naminit4, t1.naminit5,
               t1.flgact, t1.codproft, t1.costcent, t1.compgrp, t1.codposr,
               nvl( decode(global_v_lang, '101', t1.namcentoe,
                                          '102', t1.namcentot,
                                          '103', t1.namcento3,
                                          '104', t1.namcento4,
                                          '105', t1.namcento5,
                                          t1.namcentoe) ,
                    decode(global_v_lang, '101', t2.namcente,
                                          '102', t2.namcentt,
                                          '103', t2.namcent3,
                                          '104', t2.namcent4,
                                          '105', t2.namcent5,
                                          t2.namcente) ) as namcento ,
               t1.namcentoe , t1.namcentot , t1.namcento3 , t1.namcento4 , t1.namcento5 ,
               nvl( decode(global_v_lang, '101', t1.naminitoe,
                                          '102', t1.naminitot,
                                          '103', t1.naminito3,
                                          '104', t1.naminito4,
                                          '105', t1.naminito5,
                                          t1.naminitoe) ,
                    decode(global_v_lang, '101', t2.naminite,
                                          '102', t2.naminitt,
                                          '103', t2.naminit3,
                                          '104', t2.naminit4,
                                          '105', t2.naminit5,
                                          t2.naminite) ) as naminito ,
               t1.naminitoe , t1.naminitot , t1.naminito3 , t1.naminito4 , t1.naminito5 ,
               t1.codappr , t1.dteappr , t1.dteupd , t1.coduser
          into v_codcomp,
               v_namcent, v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5,
               v_codcom1, v_codcom2, v_codcom3, v_codcom4, v_codcom5, v_codcom6, v_codcom7, v_codcom8, v_codcom9, v_codcom10,
               v_codcompy, v_comlevel,
               v_naminit, v_naminite, v_naminitt, v_naminit3, v_naminit4, v_naminit5,
               v_flgact, v_codproft, v_costcent, v_compgrp, v_codposr ,
               v_namcento , v_namcentoe , v_namcentot , v_namcento3 , v_namcento4 , v_namcento5 ,
               v_naminito , v_naminitoe , v_naminitot , v_naminito3 , v_naminito4, v_naminito5 ,
               v_codappr , v_dteappr , v_dteupd , v_coduser
          from tcenterlog t1 left join tcenter t2 on t1.codcomp = t2.codcomp
          where t1.codcomp = p_codcomp
                and t1.dteeffec = v_dteeffec ;
          -----------------------------------
      exception
        when NO_DATA_FOUND THEN
            select codcomp,
                   decode(global_v_lang,  '101', namcente,
                                          '102', namcentt,
                                          '103', namcent3,
                                          '104', namcent4,
                                          '105', namcent5,
                                          namcente) as namcent ,
                   namcente, namcentt, namcent3, namcent4, namcent5,
                   codcom1, codcom2, codcom3, codcom4, codcom5, codcom6, codcom7, codcom8, codcom9, codcom10,
                   codcompy, comlevel,
                   decode(global_v_lang,  '101', naminite,
                                          '102', naminitt,
                                          '103', naminit3,
                                          '104', naminit4,
                                          '105', naminit5,
                                          naminite) as naminit ,
                   naminite, naminitt, naminit3, naminit4, naminit5,
                   flgact, codproft, costcent, compgrp, codposr,
                   decode(global_v_lang,  '101', namcente,
                                          '102', namcentt,
                                          '103', namcent3,
                                          '104', namcent4,
                                          '105', namcent5,
                                          namcente) as namcento ,
                   namcente as namcentoe , namcentt as namcentot ,  namcent3 as namcento3 ,  namcent4 as namcento4 ,  namcent5 as namcento5 ,
                   decode(global_v_lang,  '101', naminite,
                                          '102', naminitt,
                                          '103', naminit3,
                                          '104', naminit4,
                                          '105', naminit5,
                                          naminite) as naminito ,
                   naminite as naminitoe , naminitt as naminitot , naminit3 as naminito3 , naminit4 as naminito4 , naminit5 as naminito5 ,
                   '' as codappr , '' as dteappr , dteupd , coduser
              into v_codcomp,
                   v_namcent, v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5,
                   v_codcom1, v_codcom2, v_codcom3, v_codcom4, v_codcom5, v_codcom6, v_codcom7, v_codcom8, v_codcom9, v_codcom10,
                   v_codcompy, v_comlevel,
                   v_naminit, v_naminite, v_naminitt, v_naminit3, v_naminit4, v_naminit5,
                   v_flgact, v_codproft, v_costcent, v_compgrp, v_codposr,
                   v_namcento , v_namcentoe , v_namcentot , v_namcento3 , v_namcento4 , v_namcento5 ,
                   v_naminito , v_naminitoe , v_naminitot , v_naminito3 , v_naminito4, v_naminito5 ,
                   v_codappr , v_dteappr , v_dteupd , v_coduser
              from tcenter
              where codcomp = p_codcomp;
      end;

      if v_message_error is null then
         obj_data          := json_object_t();
         obj_data.put('coderror', '200');
      else
         obj_data := json_object_t(get_response_message('200',v_message_error,global_v_lang));
         obj_data.put('desc_response', v_message_error);
         obj_data.put('desc_coderror', v_error_code);
      end if ;
      obj_data.put('dteeffec', to_char(v_dteeffec, 'dd/mm/yyyy'));
      obj_data.put('codcomp_show', v_codcomp_show);
      obj_data.put('codcomp', v_codcomp);
      obj_data.put('namcent', v_namcent);
      obj_data.put('namcente', v_namcente);
      obj_data.put('namcentt', v_namcentt);
      obj_data.put('namcent3', v_namcent3);
      obj_data.put('namcent4', v_namcent4);
      obj_data.put('namcent5', v_namcent5);
      obj_data.put('codcom1', v_codcom1);
      obj_data.put('codcom2', v_codcom2);
      obj_data.put('codcom3', v_codcom3);
      obj_data.put('codcom4', v_codcom4);
      obj_data.put('codcom5', v_codcom5);
      obj_data.put('codcom6', v_codcom6);
      obj_data.put('codcom7', v_codcom7);
      obj_data.put('codcom8', v_codcom8);
      obj_data.put('codcom9', v_codcom9);
      obj_data.put('codcom10', v_codcom10);
      obj_data.put('codcompy', v_codcompy);
      obj_data.put('comlevel', v_comlevel);
      obj_data.put('comparent', v_comparent);
      obj_data.put('comlevel', v_comlevel);
      obj_data.put('naminit', v_naminit);
      obj_data.put('naminite', v_naminite);
      obj_data.put('naminitt', v_naminitt);
      obj_data.put('naminit3', v_naminit3);
      obj_data.put('naminit4', v_naminit4);
      obj_data.put('naminit5', v_naminit5);
      obj_data.put('flgact', v_flgact);
      obj_data.put('codproft', v_codproft);
      obj_data.put('costcent', v_costcent);
      obj_data.put('compgrp', v_compgrp);
      obj_data.put('codposr', v_codposr);
      obj_data.put('namcento', v_namcento);
      obj_data.put('namcentoe', v_namcentoe);
      obj_data.put('namcentot', v_namcentot);
      obj_data.put('namcento3', v_namcento3);
      obj_data.put('namcento4', v_namcento4);
      obj_data.put('namcento5', v_namcento5);
      obj_data.put('naminito', v_naminito);
      obj_data.put('naminitoe', v_naminitoe);
      obj_data.put('naminitot', v_naminitot);
      obj_data.put('naminito3', v_naminito3);
      obj_data.put('naminito4', v_naminito4);
      obj_data.put('naminito5', v_naminito5);
      obj_data.put('codappr', v_codappr);
      obj_data.put('dteappr', to_char(v_dteappr, 'dd/mm/yyyy'));
      obj_data.put('dteupd', to_char(v_dteupd, 'dd/mm/yyyy'));
      obj_data.put('coduser', v_coduser);
      obj_data.put('codempid', get_codempid(v_coduser));
      obj_data.put('temploy_name', get_codempid(v_coduser)|| ' - ' ||get_temploy_name(get_codempid(v_coduser), global_v_lang));
      json_str_output := obj_data.to_clob;
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_dteeffec_by_codcomp;
-----------------------------------------------------------------------------------------
--  procedure start_process(json_str_input in clob, json_str_output out clob) as
--  begin
--    initial_value(json_str_input);
--    if param_msg_error is null then
--      gen_process(json_str_output);
--    else
--      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--    end if;
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--  end start_process;
  -----------------------------------------------------------------------------------------

--  procedure start_process_auto as
--    json_str_output clob;
--  begin
--      gen_process(json_str_output);
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--  end start_process_auto;
---------------------------------------------------------------------------------------------
--  procedure gen_process(json_str_output out clob) is
--    obj_data    json_object_t;
--    v_flgact number;
--
--    cursor c_tcenterlog is
--      select tcenterlog.*,rowid
--      from   tcenterlog
--      where  dteeffec <= trunc(sysdate)
--      and    nvl(flgcal,'N') = 'N'
--      order by  codcomp,dteeffec;
--  begin
--    obj_data          := json_object_t();
--    for r1 in c_tcenterlog loop
--      if r1.flgact in (1,3) then
--        v_flgact := 1;
--      else
--        v_flgact := 2;
--      end if;
--
--      begin
--        insert into tcenter(codcomp,namcente,namcentt,namcent3,namcent4,namcent5,
--                            codcom1,codcom2,codcom3,codcom4,codcom5,
--                            codcom6,codcom7,codcom8,codcom9,codcom10,
--                            codcompy,comlevel,
--                            naminite,naminitt,naminit3,naminit4,naminit5,
--                            flgact,codproft,costcent,compgrp,codposr,coduser,codcreate)
--                      values (r1.codcomp,r1.namcente,r1.namcentt,r1.namcent3,r1.namcent4,r1.namcent5,
--                            r1.codcom1,r1.codcom2,r1.codcom3,r1.codcom4,r1.codcom5,
--                            r1.codcom6,r1.codcom7,r1.codcom8,r1.codcom9,r1.codcom10,
--                            r1.codcompy,r1.comlevel,
--                            r1.naminite,r1.naminitt,r1.naminit3,r1.naminit4,r1.naminit5,
--                            r1.flgact,r1.codproft,r1.costcent,r1.compgrp,r1.codposr,r1.coduser,r1.codcreate);
--        exception when dup_val_on_index then
--          update tcenter
--          set     flgact = v_flgact,
--                  codcomp = r1.codcomp,
--                  namcente = r1.namcente,
--                  namcentt = r1.namcentt,
--                  namcent3 = r1.namcent3,
--                  namcent4 = r1.namcent4,
--                  namcent5 = r1.namcent5,
--                  codcom1 = r1.codcom1,
--                  codcom2 = r1.codcom2,
--                  codcom3 = r1.codcom3,
--                  codcom4 = r1.codcom4,
--                  codcom5 = r1.codcom5,
--                  codcom6 = r1.codcom6,
--                  codcom7 = r1.codcom7,
--                  codcom8 = r1.codcom8,
--                  codcom9 = r1.codcom9,
--                  codcom10 = r1.codcom10,
--                  codcompy = r1.codcompy,
--                  comlevel = r1.comlevel,
--                  naminit3 = r1.naminit3,
--                  naminit4 = r1.naminit4,
--                  naminit5 = r1.naminit5,
--                  naminite = r1.naminite,
--                  naminitt = r1.naminitt,
--                  codproft = r1.codproft,
--                  costcent = r1.costcent,
--                  compgrp = r1.compgrp,
--                  codposr = r1.codposr,
--                  dteupd = sysdate,
--                  coduser = r1.coduser
--          where   codcomp = r1.codcomp;
--      end;
--
--      update tcenterlog
--         set flgcal  = 'Y',
--             dteupd  = trunc(sysdate)
--       where codcomp = r1.codcomp
--         and dteeffec = r1.dteeffec;
--    end loop;
--
--    param_msg_error := get_error_msg_php('HR2715', global_v_lang);
--    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
--    return;
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--  end gen_process;
  --
  procedure get_default_tcenter(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_default_tcenter(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_default_tcenter;

  procedure gen_default_tcenter(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt		    number := 0;
    v_flgsecu       boolean ;
    v_levelCount    number;

    v_flgact        tcenter.flgact%type;
    v_codposr       tcenter.codposr%type;
    v_costcent      tcenter.costcent%type;
    v_namcent       tcenter.namcente%type;
    v_namcentt       tcenter.namcentt%type;
    v_namcente       tcenter.namcente%type;
    v_namcent3       tcenter.namcent3%type;
    v_namcent4       tcenter.namcent4%type;
    v_namcent5       tcenter.namcent5%type;
    v_codcomp1      tcenter.codcomp%type;
    v_count_codcomp2 number :=0;
    v_dteeffec      date;
    v_level1        varchar2(100 char) := '';
    v_level1_dis    varchar2(100 char) := '';
    v_temp_cnt_1            number;
    v_temp_cnt_2            number;
    v_flgChkDisable         varchar2(1);
    cursor c_tsetdep is
        select substr(codcomp,1, (select sum(qtycode) from tsetcomp where numseq <= p_comlevel-1)) as codcomp1,
               decode(global_v_lang, '101', namcente,
                                     '102', namcentt,
                                     '103', namcent3,
                                     '104', namcent4,
                                     '105', namcent5,
                                     namcente) as namcent
          from tcenter
         where codcompy =  p_codcompy
           and comlevel = (p_comlevel - 1)
      order by codcomp;

    cursor c_tcompnyd is
        select codcomp,
               decode(global_v_lang, '101', namcompe,
                                     '102', namcompt,
                                     '103', namcomp3,
                                     '104', namcomp4,
                                     '105', namcomp5,
                                      namcompe) as namcomp,
               namcompe, namcompt, namcomp3, namcomp4, namcomp5
          from tcompnyd
         where codcompy = p_codcompy
           and comlevel = p_comlevel
      order by codcomp;

    cursor c_tcenter is
        select decode(global_v_lang, '101', namcente,
                                     '102', namcentt,
                                     '103', namcent3,
                                     '104', namcent4,
                                     '105', namcent5,
                                     namcente) as namcent,
                                     flgact,codposr,costcent,
               decode(p_comlevel, '2', codcom2,
                                  '3', codcom3,
                                  '4', codcom4,
                                  '5', codcom5,
                                  '6', codcom6,
                                  '7', codcom7,
                                  '8', codcom8,
                                  '9', codcom9,
                                  '10', codcom10,
                                  codcom1) codcomp,
               namcente, namcentt, namcent3, namcent4, namcent5
          from tcenter
         where codcompy = p_codcompy
           and comlevel = p_comlevel
           and codcomp like v_codcomp1||'%'
      order by codcomp;
  begin
    obj_row         := json_object_t();
    obj_result      := json_object_t();
    v_level1 := 'xx';
    v_level1_dis := 'xx';
    for r_tsetdep in c_tsetdep loop
        v_count_codcomp2 := 0;
        v_codcomp1  := r_tsetdep.codcomp1;

        if p_flgtype = '1' then
            for r_tcompnyd in c_tcompnyd loop
                if hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1),'-') != v_level1_dis then
                    v_level1 := hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1),'-');
                else
                    v_level1 := '';
                end if;
                v_level1_dis := hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1),'-');
                begin
                    select decode(global_v_lang, '101', namcente,
                                         '102', namcentt,
                                         '103', namcent3,
                                         '104', namcent4,
                                         '105', namcent5,
                                          namcente) as namcent,
                           flgact, codposr, costcent,
                           namcente, namcentt, namcent3, namcent4, namcent5
                      into v_namcent, v_flgact, v_codposr, v_costcent ,
                           v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5
                      from tcenter
                     where codcomp = get_compful (r_tsetdep.codcomp1||r_tcompnyd.codcomp);
                exception when no_data_found then
                    v_namcent := r_tcompnyd.namcomp;
                    v_namcente := r_tcompnyd.namcompe;
                    v_namcentt := r_tcompnyd.namcompt;
                    v_namcent3 := r_tcompnyd.namcomp3;
                    v_namcent4 := r_tcompnyd.namcomp4;
                    v_namcent5 := r_tcompnyd.namcomp5;
                    v_flgact    := '';
                    v_codposr   := '';
                    v_costcent  := '';
                end;

                begin
                    select max(dteeffec)
                      into v_dteeffec
                      from tcenterlog
                     where codcomp = hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1))||r_tcompnyd.codcomp;
                exception when others then
                    v_dteeffec := trunc(sysdate);
                end;

                v_rcnt      := v_rcnt+1;
                v_count_codcomp2 := v_count_codcomp2 +1;
                obj_data    := json_object_t();

                obj_data.put('coderror', '200');
                obj_data.put('comlevel',p_comlevel);
                obj_data.put('under_level',(p_comlevel - 1));
                obj_data.put('codcomp_show',hcm_util.get_codcomp_level (v_codcomp1||r_tcompnyd.codcomp,p_comlevel,'-'));
                obj_data.put('codcomp',hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1)));
                obj_data.put('level1',v_level1);
                obj_data.put('level1_hide',hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1),'-'));
                obj_data.put('level2',r_tcompnyd.codcomp);
                obj_data.put('desc_codcomp',v_namcent);
                obj_data.put('desc_flgact',get_tlistval_name('STATCENTER', v_flgact, global_v_lang));
                obj_data.put('flgact',v_flgact);
                obj_data.put('codposr',v_codposr);
                obj_data.put('costcent',v_costcent);
                obj_data.put('dteeffec', to_char(nvl(v_dteeffec,trunc(sysdate)), 'dd/mm/yyyy'));
                obj_data.put('namcente',v_namcente);
                obj_data.put('namcentt',v_namcentt);
                obj_data.put('namcent3',v_namcent3);
                obj_data.put('namcent4',v_namcent4);
                obj_data.put('namcent5',v_namcent5);
                
                
                select (select count('x') from temploy1 st1 where st1.codcomp = get_compful(hcm_util.get_codcomp_level (v_codcomp1||r_tcompnyd.codcomp,p_comlevel))) ,
                     (select count('x') from ttmovemt st2 where st2.codcomp = get_compful(hcm_util.get_codcomp_level (v_codcomp1||r_tcompnyd.codcomp,p_comlevel)))
                into v_temp_cnt_1 , v_temp_cnt_2
                from dual ;
                ----------------------------------------
                if (v_temp_cnt_1 > 0) or (v_temp_cnt_2 > 0) then
                     v_flgChkDisable := 'Y';
                else
                  v_flgChkDisable := 'N';
                end if ;   
                obj_data.put('flgChkDisable',v_flgChkDisable);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end loop;
        else
            for r_tcenter in c_tcenter loop
                if hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1),'-') != v_level1_dis then
                    v_level1 := hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1),'-');
                else
                    v_level1 := '';
                end if;
                v_level1_dis := hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1),'-');

                begin
                    select max(dteeffec)
                      into v_dteeffec
                      from tcenterlog
                     where codcomp = hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1))||r_tcenter.codcomp;
                exception when others then
                    v_dteeffec := trunc(sysdate);
                end;

                v_rcnt      := v_rcnt+1;
                v_count_codcomp2 := v_count_codcomp2 +1;
                obj_data    := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('comlevel',p_comlevel);
                obj_data.put('under_level',(p_comlevel - 1));
                obj_data.put('codcomp_show',hcm_util.get_codcomp_level (v_codcomp1||r_tcenter.codcomp,p_comlevel,'-'));
                obj_data.put('codcomp',hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1)));
                obj_data.put('level1',v_level1);
                obj_data.put('level1_hide',hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1),'-'));
                obj_data.put('level2',r_tcenter.codcomp);
                obj_data.put('desc_codcomp',r_tcenter.namcent);
                obj_data.put('desc_flgact',get_tlistval_name('STATCENTER', r_tcenter.flgact, global_v_lang));
                obj_data.put('flgact',r_tcenter.flgact);
                obj_data.put('codposr',r_tcenter.codposr);
                obj_data.put('costcent',r_tcenter.costcent);
                obj_data.put('dteeffec', to_char(nvl(v_dteeffec,trunc(sysdate)), 'dd/mm/yyyy'));
                obj_data.put('namcente',r_tcenter.namcente);
                obj_data.put('namcentt',r_tcenter.namcentt);
                obj_data.put('namcent3',r_tcenter.namcent3);
                obj_data.put('namcent4',r_tcenter.namcent4);
                obj_data.put('namcent5',r_tcenter.namcent5);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end loop;
        end if;

        if v_count_codcomp2 = 0 then
            if hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1),'-') != v_level1_dis then
                v_level1 := hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1),'-');
            else
                v_level1 := '';
            end if;
            v_level1_dis := hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1),'-');

            v_rcnt      := v_rcnt+1;
            obj_data    := json_object_t();
            v_codcomp1  := r_tsetdep.codcomp1;
            obj_data.put('coderror', '200');
            obj_data.put('comlevel',p_comlevel);
            obj_data.put('under_level',(p_comlevel - 1));
            obj_data.put('codcomp',hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1)));
            obj_data.put('level1',v_level1);
            obj_data.put('level1_hide',hcm_util.get_codcomp_level (r_tsetdep.codcomp1,(p_comlevel - 1),'-'));
            obj_data.put('level2','');
            obj_data.put('desc_codcomp',r_tsetdep.namcent);
            obj_data.put('desc_flgact','');
            obj_data.put('flgact','');
            obj_data.put('codposr','');
            obj_data.put('costcent','');
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_rcnt = 0 then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tcenter');
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;

    json_str_output := obj_row.to_clob;
  end gen_default_tcenter;
-----------------------
  procedure get_tcenter_popup(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if p_parent_comlevel >= p_comlevel then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
    end if;
    if param_msg_error is null then
      gen_tcenter_popup(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tcenter_popup;

  procedure gen_tcenter_popup(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    obj_result          json_object_t;
    v_rcnt		        number := 0;
    v_flgsecu           boolean ;
    v_levelCount        number;
    p_flgtype           varchar2(10) := '1';


    v_flgact            tcenter.flgact%type;
    v_codposr           tcenter.codposr%type;
    v_costcent          tcenter.costcent%type;
    v_namcent           tcenter.namcente%type;
    v_codcomp1          tcenter.codcomp%type;
    v_parent_codcomp    tcenter.codcomp%type;
    v_dteeffec          date;

    cursor c_tcompnyd is
        select codcomp,
               decode(global_v_lang, '101', namcompe,
                                     '102', namcompt,
                                     '103', namcomp3,
                                     '104', namcomp4,
                                     '105', namcomp5,
                                      namcompe) as namcomp
          from tcompnyd
         where codcompy = p_codcompy
           and comlevel = p_comlevel
      order by codcomp;


  begin
    obj_row         := json_object_t();
    obj_result      := json_object_t();
--    p_codcomp :='ABC';
--    p_parent_comlevel := 1;
    for r_tcompnyd in c_tcompnyd loop
        begin
            select max(dteeffec)
              into v_dteeffec
              from tcenterlog
             where codcomp = p_codcomp||r_tcompnyd.codcomp;
        exception when others then
            v_dteeffec := trunc(sysdate);
        end;

        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        v_codcomp1 := hcm_util.get_codcomp_level (get_compful (p_codcomp),(p_comlevel - 1));
        obj_data.put('coderror', '200');
        obj_data.put('codcomp_show',hcm_util.get_codcomp_level (v_codcomp1||r_tcompnyd.codcomp,p_comlevel,'-'));
        obj_data.put('codcomp',p_codcomp);
        obj_data.put('level1',hcm_util.get_codcomp_level (v_codcomp1,(p_comlevel - 1),'-'));
        obj_data.put('level2',r_tcompnyd.codcomp);
        obj_data.put('comlevel',p_comlevel);
        obj_data.put('under_level',p_parent_comlevel);
        obj_data.put('desc_codcomp',r_tcompnyd.namcomp);
        obj_data.put('desc_flgact','');
        obj_data.put('flgact','');
        obj_data.put('codposr','');
        obj_data.put('costcent','');
        obj_data.put('dteeffec', to_char(nvl(v_dteeffec,trunc(sysdate)), 'dd/mm/yyyy'));
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_tcenter_popup;

  procedure get_comlevel_name(json_str_input in clob, json_str_output out clob) as
    obj_data            json_object_t;
    v_namcent          tcompnyc.namcente%type;
    v_colnam1           varchar2(150);
    v_colnam2           varchar2(150);
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        begin
            select decode(global_v_lang, '101', namcente,
                                         '102', namcentt,
                                         '103', namcent3,
                                         '104', namcent4,
                                         '105', namcent5,
                                          namcente)
              into v_namcent
              from tcompnyc
             where comlevel = p_comlevel
               and codcompy = p_codcompy ;
        exception when others then
            v_namcent := null;
        end;

      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('level_name', v_namcent);
      obj_data.put('level1',(p_comlevel-1));
      obj_data.put('level2', p_comlevel);
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_comlevel_name;

  procedure get_comlevel_detail(json_str_input in clob, json_str_output out clob) as
    obj_data            json_object_t;
    v_namcent           tcompnyc.namcente%type;
    v_colnam1           tcompnyc.namcente%type;
    v_colnam2           tcompnyc.namcente%type;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
        begin
            select decode(global_v_lang, '101', namcente,
                                         '102', namcentt,
                                         '103', namcent3,
                                         '104', namcent4,
                                         '105', namcent5,
                                          namcente)
              into v_colnam1
              from tcompnyc
             where comlevel = (p_comlevel-1)
               and codcompy = p_codcompy ;
        exception when others then
            v_colnam1 := null;
        end;
        begin
            select decode(global_v_lang, '101', namcente,
                                         '102', namcentt,
                                         '103', namcent3,
                                         '104', namcent4,
                                         '105', namcent5,
                                          namcente)
              into v_colnam2
              from tcompnyc
             where comlevel = p_comlevel
               and codcompy = p_codcompy ;
        exception when others then
            v_colnam2 := null;
        end;
      if (p_comlevel - 1) = 1 then
        v_colnam1 := get_label_name('HRCO04E3',global_v_lang,160);
      end if;
      obj_data.put('level1',nvl(v_colnam1,get_label_name('HRCO04E4',global_v_lang,230) ||' '|| to_char(p_comlevel-1)));
      obj_data.put('level2',nvl(v_colnam2,get_label_name('HRCO04E4',global_v_lang,230) ||' '|| to_char( p_comlevel)));
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_comlevel_detail;

  procedure get_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_error         varchar2(1000 char);
    v_flgsecu       boolean := false;
    v_rec_tran      number;
    v_rec_err       number;
    v_numseq        varchar2(1000 char);
    v_rcnt          number  := 0;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      format_text_json(json_str_input, v_rec_tran, v_rec_err);
    end if;
    --
    obj_row    := json_object_t();
    obj_result := json_object_t();
    if param_msg_error is null then
        commit;
        obj_row.put('coderror', '200');
        obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
    else
        rollback;
        obj_row.put('coderror', '400');
        obj_row.put('response', replace(param_msg_error,'@#$%400',null));
    end if;
    obj_row.put('rec_tran', v_rec_tran);
    obj_row.put('rec_err', v_rec_err);
    --
    if p_numseq.exists(p_numseq.first) then
      for i in p_numseq.first .. p_numseq.last
      loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('text', p_text(i));
        obj_data.put('error_code', p_error_code(i));
        obj_data.put('numseq', p_numseq(i));
        obj_result.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    obj_row.put('datadisp', obj_result);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json          json_object_t;
    param_data          json_object_t;
    param_column        json_object_t;
    param_column_row    json_object_t;
    param_json_row      json_object_t;
    json_obj_list       json_list;
    --
    data_file           varchar2(6000);
    v_column            number := 7;
    v_error             boolean;
    v_err_code          varchar2(1000);
    v_err_filed         varchar2(1000);
    v_err_table         varchar2(20);
    i                   number;
    j                   number;
    k                   number;
    v_numseq            number := 0;

    v_code              varchar2(100);
    v_flgsecu           boolean;
    v_cnt               number := 0;
    v_dteleave          date;
    v_coderr            varchar2(4000 char);
    v_num               number := 0;

    type text is table of varchar2(4000) index by binary_integer;
    v_text              text;
    v_filed             text;
    v_codcomp_a         text;
    v_chk_compskil      TCOMPSKIL.CODTENCY%TYPE;
    v_chk_exist         number :=0;
    v_chk_codtency      varchar2(100);
    v_chk_dup_codskil   varchar2(100);
    v_chk_codskil       varchar2(100);
    v_chk_codjobgrp     varchar2(100);
    v_chk_jobgrp        varchar2(100);

    v_jobgroup          varchar2(4);
    v_namjobgrpe        varchar2(150);
    v_namjobgrpt        varchar2(150);
    v_namjobgrp3        varchar2(150);
    v_namjobgrp4        varchar2(150);
    v_namjobgrp5        varchar2(150);
    v_codtency          varchar2(4);
    v_codskill          varchar2(4);

    v_dteeffec          tcenterlog.dteeffec%type;
    v_exist_level       number;
    v_qtycode           number;
    v_comparent         tcenter.comparent%type;
    v_max_comlevel      number;
    v_codcomp           tcenterlog.codcomp%type;

    v_namcent           tcenter.namcente%type;
    v_namcente          tcenter.namcente%type;
    v_namcentt          tcenter.namcentt%type;
    v_namcent3          tcenter.namcent3%type;
    v_namcent4          tcenter.namcent4%type;
    v_namcent5          tcenter.namcent5%type;
    v_codcom            varchar2(2000 char);
    v_codcom1           tcenter.codcom1%type;
    v_codcom2           tcenter.codcom2%type;
    v_codcom3           tcenter.codcom3%type;
    v_codcom4           tcenter.codcom4%type;
    v_codcom5           tcenter.codcom5%type;
    v_codcom6           tcenter.codcom6%type;
    v_codcom7           tcenter.codcom7%type;
    v_codcom8           tcenter.codcom8%type;
    v_codcom9           tcenter.codcom9%type;
    v_codcom10          tcenter.codcom10%type;
    v_naminit           tcenter.naminite%type;
    v_naminite          tcenter.naminite%type;
    v_naminitt          tcenter.naminitt%type;
    v_naminit3          tcenter.naminit3%type;
    v_naminit4          tcenter.naminit4%type;
    v_naminit5          tcenter.naminit5%type;
    v_flgact            tcenter.flgact%type;
    v_costcent          tcenter.costcent%type;
    v_compgrp           tcenter.compgrp%type;
    v_codposr           tcenter.codposr%type;
    v_codappr           tcenterlog.codappr%type;
    v_dteappr           tcenterlog.dteappr%type;
    v_comlevel          tcenter.comlevel%type;
    v_codcompy          tcenter.codcompy%type;
    v_flgcal            tcenterlog.flgcal%type;
    v_namcentoe         tcenterlog.namcentoe%type;
    v_namcentot         tcenterlog.namcentot%type;
    v_namcento3         tcenterlog.namcento3%type;
    v_namcento4         tcenterlog.namcento4%type;
    v_namcento5         tcenterlog.namcento5%type;
    v_naminitoe         tcenterlog.naminitoe%type;
    v_naminitot         tcenterlog.naminitot%type;
    v_naminito3         tcenterlog.naminito3%type;
    v_naminito4         tcenterlog.naminito4%type;
    v_naminito5         tcenterlog.naminito5%type;
    v_flgacto           tcenterlog.flgacto%type;
    v_costcento         tcenterlog.costcento%type;
    v_compgrpo          tcenterlog.compgrpo%type;
    v_codposro          tcenterlog.codposro%type;
  begin
    v_rec_tran  := 0;
    v_rec_error := 0;
    --
    select max(numseq)
      into v_max_comlevel
      from tsetcomp;

    for i in 1..v_column loop
      v_filed(i) := null;
    end loop;
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
        -- get text columns from json
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_filed(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;

    for r1 in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data, to_char(r1));
      begin
        v_err_code  := null;
        v_err_filed := null;
        v_err_table := null;
        v_numseq    := v_numseq;
        v_error 	  := false;

        <<cal_loop>> loop
          v_text(1)   := hcm_util.get_string_t(param_json_row,'codcom1');
          v_text(2)   := hcm_util.get_string_t(param_json_row,'codcom2');
          v_text(3)   := hcm_util.get_string_t(param_json_row,'codcom3');
          v_text(4)   := hcm_util.get_string_t(param_json_row,'codcom4');
          v_text(5)   := hcm_util.get_string_t(param_json_row,'codcom5');
          v_text(6)   := hcm_util.get_string_t(param_json_row,'codcom6');
          v_text(7)   := hcm_util.get_string_t(param_json_row,'codcom7');
          v_text(8)   := hcm_util.get_string_t(param_json_row,'codcom8');
          v_text(9)   := hcm_util.get_string_t(param_json_row,'codcom9');
          v_text(10)   := hcm_util.get_string_t(param_json_row,'codcom10');
          v_text(11)   := hcm_util.get_string_t(param_json_row,'dteeffec');
          v_text(12)   := hcm_util.get_string_t(param_json_row,'comlevel');
          v_text(13)   := hcm_util.get_string_t(param_json_row,'comparent');
          v_text(14)   := hcm_util.get_string_t(param_json_row,'namcente');
          v_text(15)   := hcm_util.get_string_t(param_json_row,'namcentt');
          v_text(16)   := hcm_util.get_string_t(param_json_row,'namcent3');
          v_text(17)   := hcm_util.get_string_t(param_json_row,'namcent4');
          v_text(18)   := hcm_util.get_string_t(param_json_row,'namcent5');
          v_text(19)   := hcm_util.get_string_t(param_json_row,'naminite');
          v_text(20)   := hcm_util.get_string_t(param_json_row,'naminitt');
          v_text(21)   := hcm_util.get_string_t(param_json_row,'naminit3');
          v_text(22)   := hcm_util.get_string_t(param_json_row,'naminit4');
          v_text(23)   := hcm_util.get_string_t(param_json_row,'naminit5');
          v_text(24)   := hcm_util.get_string_t(param_json_row,'flgact');
          v_text(25)   := hcm_util.get_string_t(param_json_row,'coscent');
          v_text(26)   := hcm_util.get_string_t(param_json_row,'codposr');

          data_file := null;
          for i in 1..26 loop
              data_file :=  v_text(1)||', '||v_text(2)||', '||v_text(3)||', '||v_text(4)||', '||v_text(5)||', '||v_text(6)||', '||v_text(7)||', '||v_text(8)||', '||v_text(9)||', '||v_text(10)||', '||
                            v_text(11)||', '||v_text(12)||', '||v_text(13)||', '||v_text(14)||', '||v_text(15)||', '||v_text(16)||', '||v_text(17)||', '||v_text(18)||', '||v_text(19)||', '||v_text(20)||', '||
                            v_text(21)||', '||v_text(22)||', '||v_text(23)||', '||v_text(24)||', '||v_text(25)||', '||v_text(26);

              if v_text(i) is null then
                if i = 1 then --codcompy
                    v_error	 	  := true;
                    v_err_code  := 'HR2045';
                    v_err_filed := v_filed(i);
                    v_err_table := 'TCENTERLOG';
                    exit cal_loop;
                elsif i in (2,3,4,5,6,7,8,9,10) then -- codcom2-10
                    select count(*)
                      into v_exist_level
                      from tcompnyc
                     where codcompy = v_filed(1)
                       and comlevel = i;
                    if v_exist_level > 0 then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_filed := v_filed(i);
                        v_err_table := 'TCENTERLOG';
                        exit cal_loop;
                    end if;
                elsif i in (11,12,14,15,24,25) then
                    v_error	 	  := true;
                    v_err_code  := 'HR2045';
                    v_err_filed := v_filed(i);
                    v_err_table := 'TCENTERLOG';
                    exit cal_loop;
                end if;
              end if;
          end loop;
          -- 11.dteeffec
           i := 11;
           if hcm_validate.check_date(v_text(i)) then
             v_error     := true;
             v_err_code  := 'HR2815';
             v_err_filed := v_filed(i);
              exit cal_loop;
           end if;
           v_dteeffec := to_date(v_text(i),'dd/mm/yyyy');
          v_codcomp_a(1) := v_text(1);

           --<<#5204 User37 Final Test Phase 1 V11 02/04/2021
           -- 12.comlevel
           i := 12;
           if hcm_validate.check_number(v_text(i)) then
               v_error     := true;
               v_err_code  := 'HR2816';
               v_err_filed := v_filed(i);
               exit cal_loop;
           end if;
           v_comlevel := v_text(12);
           -->>5204 User37 Final Test Phase 1 V11 02/04/2021

          for i in 2..10 loop
              begin
              select qtycode
                into v_qtycode
                from tsetcomp
               where numseq = i;
              exception when others then
                v_qtycode := null;
              end;
              if v_qtycode is not null and length(v_text(i)) > v_qtycode then
                v_error	 	  := true;
                v_err_code  := 'HR6591';
                v_err_filed := v_filed(i);
                exit cal_loop;
              end if;
              v_codcomp_a(i) := LPAD(v_text(i), v_qtycode, '0');
              if (v_codcomp_a(i) != LPAD('', v_qtycode, '0') and v_qtycode is not null and i <> v_text(12)) or (i = v_text(12)) then
                  begin
                      select count(*)
                        into v_exist_level
                        from tcompnyd
                       where codcompy = v_text(1)
                         and codcomp = v_codcomp_a(i)
                         and comlevel = i ;
                  exception when others then
                      v_exist_level := 0;
                  end;
                  if v_exist_level = 0 then
                    v_error	 	  := true;
                    v_err_code  := 'HR2010';
                    v_err_filed := v_filed(i);
                    v_err_table := 'TCOMPNYD';
                    exit cal_loop;
                  end if;
               end if;


          end loop;
         -- 13.comparent
           i := 13;
           if length(v_text(i)) > 40 then
             v_error     := true;
             v_err_code  := 'HR6591';
             v_err_filed := v_filed(i);
              exit cal_loop;
           end if;
           v_comparent := upper(v_text(i));
        -- 14-18.namcent
          for i in 14..18 loop
           if length(v_text(i)) > 150 then
             v_error     := true;
             v_err_code  := 'HR6591';
             v_err_filed := v_filed(i);
              exit cal_loop;
           end if;
          end loop;
        -- 19-23.naminit
          for i in 19..23 loop
           if length(v_text(i)) > 50 then
             v_error     := true;
             v_err_code  := 'HR6591';
             v_err_filed := v_filed(i);
              exit cal_loop;
           end if;
          end loop;
         -- 24.flgact
           i := 24;
           if length(v_text(i)) > 1 then
             v_error     := true;
             v_err_code  := 'HR6591';
             v_err_filed := v_filed(i);
              exit cal_loop;
           end if;
         -- 25.costcent
           i := 25;
           if length(v_text(i)) > 25 then
             v_error     := true;
             v_err_code  := 'HR6591';
             v_err_filed := v_filed(i);
              exit cal_loop;
           end if;
         -- 26.codposr
           i := 26;
           if length(v_text(i)) > 4 then
             v_error     := true;
             v_err_code  := 'HR6591';
             v_err_filed := v_filed(i);
              exit cal_loop;
           end if;
        -- 12.comlevel
           /* #5204 User37 Final Test Phase 1 V11 02/04/2021  i := 12;
           if not hcm_validate.check_number(v_text(i)) then
               v_error     := true;
               v_err_code  := 'HR2816';
               v_err_filed := v_filed(i);
               exit cal_loop;
           end if;
           v_comlevel := v_text(12);*/
          for i in 2..10 loop
              begin
                  select count(*)
                    into v_exist_level
                    from tsetcomp
                   where numseq = i;
              exception when others then
                  v_exist_level := 0;
              end;
              if v_exist_level = 0 and i <= v_comlevel then
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_filed := v_filed(i);
                v_err_table := 'TSETCOMP';
                exit cal_loop;
              end if;

              if i > v_comlevel then
                v_codcomp_a(i) := null;
              end if;
          end loop;


        -- 24.flgact
           i := 24;
           if v_text(i) not in ('1','2','3') then
               v_error     := true;
               v_err_code  := 'HR2020';
               v_err_filed := v_filed(i);
               exit cal_loop;
           end if;
        -- 25.costcent
           i := 25;
           select count(*)
             into v_chk_exist
             from tcoscent
            where costcent = UPPER(v_text(i));
           if v_chk_exist = 0 then
               v_error     := true;
               v_err_code  := 'HR2010';
               v_err_table := 'TCOSCENT';
               v_err_filed := v_filed(i);
               exit cal_loop;
           end if;
        -- 26.codposr
           i := 26;
           select count(*)
             into v_chk_exist
             from tpostn
            where codpos = UPPER(v_text(i));
           if v_chk_exist = 0 then
               v_error     := true;
               v_err_code  := 'HR2010';
               v_err_table := 'TPOSTN';
               v_err_filed := v_filed(i);
               exit cal_loop;
           end if;
        -- 13.comparent
           i := 13;
           if v_text(i) is not null then
               select count(*)
                 into v_chk_exist
                 from tcenter
                where codcomp = UPPER(v_text(i));
                if v_chk_exist = 0 then
                    v_error     := true;
                    v_err_code  := 'HR2010';
                    v_err_table := 'TCENTER';
                    v_err_filed := v_filed(i);
                    exit cal_loop;
                end if;
           end if;
            for i in 1..10 loop
                v_codcomp := nvl(v_codcomp,'')||v_codcomp_a(i);
            end loop;
            v_codcomp := get_compful(v_codcomp);

        -- 11.dteeffec
           i := 11;
           if v_dteeffec is not null then
             if v_dteeffec < trunc(sysdate) then
               select count(*)
                 into v_chk_exist
                 from tcenterlog
                where codcomp = v_codcomp
                  and dteeffec <= trunc(sysdate)
                  and dteeffec > v_dteeffec;
                if v_chk_exist > 0 then
                    v_error     := true;
                    v_err_code  := 'HR1501';
                    v_err_filed := v_filed(i);
                    exit cal_loop;
                end if;
             end if;
           end if;
           select count(*)
             into v_chk_exist
             from tcenterlog
            where codcomp = v_codcomp
              and dteeffec = v_dteeffec
              and flgcal = 'Y';
            if v_chk_exist > 0 then
                v_error     := true;
                v_err_code  := 'HR8836';
                exit cal_loop;
            end if;
          exit cal_loop;
        end loop;

        if not v_error then
            v_rec_tran := v_rec_tran + 1;
            v_codcomp := v_codcomp;
            v_dteeffec := v_dteeffec;
            v_namcente := v_text(14);
            v_namcentt := v_text(15);
            v_namcent3 := v_text(16);
            v_namcent4 := v_text(17);
            v_namcent5 := v_text(18);
            v_codcom1 := v_codcomp_a(1);
            v_codcom2 := get_comp_split (v_codcomp,2);
            v_codcom3 := get_comp_split (v_codcomp,3);
            v_codcom4 := get_comp_split (v_codcomp,4);
            v_codcom5 := get_comp_split (v_codcomp,5);
            v_codcom6 := get_comp_split (v_codcomp,6);
            v_codcom7 := get_comp_split (v_codcomp,7);
            v_codcom8 := get_comp_split (v_codcomp,8);
            v_codcom9 := get_comp_split (v_codcomp,9);
            v_codcom10 := get_comp_split (v_codcomp,10);
            v_naminite := v_text(19);
            v_naminitt := v_text(20);
            v_naminit3 := v_text(21);
            v_naminit4 := v_text(22);
            v_naminit5 := v_text(23);
            v_flgact := v_text(24);
            v_costcent := v_text(25);
            v_codposr := v_text(26);
            v_codappr := global_v_codempid;
            v_dteappr := trunc(sysdate);
            v_flgcal := 'N';
            v_codcompy := v_codcomp_a(1);
            v_comlevel := v_text(12);

            begin
                select compgrp
                  into v_compgrp
                  from tcompny
                 where codcompy = v_codcompy;
            exception when others then
                v_compgrp := null;
            end;

            begin
                select t.flgact , t.costcent , t.compgrp , t.codposr ,
                       t.namcente , t.namcentt , t.namcent3 , t.namcent4 , t.namcent5 ,
                       t.naminite , t.naminitt , t.naminit3 , t.naminit4 , t.naminit5
                into   v_flgacto , v_costcento , v_compgrpo , v_codposro ,
                       v_namcentoe , v_namcentot , v_namcento3 , v_namcento4 , v_namcento5 ,
                       v_naminitoe , v_naminitot , v_naminito3 , v_naminito4 , v_naminito5
                from ( select *
                       from   tcenter
                       where  codcomp = v_codcomp
--                              and dteeffec < v_dteeffec
                       /*order by v_dteeffec desc*/ ) t
                where rownum = 1 ;
            exception when NO_DATA_FOUND then
                v_flgacto := '' ;
                v_costcento := '' ;
                v_compgrpo := '' ;
                v_codposro := '' ;
                v_namcentoe := '' ;
                v_namcentot := '' ;
                v_namcento3 := '' ;
                v_namcento4 := '' ;
                v_namcento5 := '' ;
                v_naminitoe := '' ;
                v_naminitot := '' ;
                v_naminito3 := '' ;
                v_naminito4 := '' ;
                v_naminito5 := '' ;
            end ;
            begin
              insert into tcenterlog
                (codcomp, dteeffec, namcente, namcentt, namcent3, namcent4, namcent5,
                 codcom1, codcom2, codcom3, codcom4, codcom5, codcom6, codcom7, codcom8, codcom9, codcom10,
                 namcentoe, namcentot, namcento3, namcento4, namcento5,
                 naminite, naminitt, naminit3, naminit4, naminit5,
                 naminitoe, naminitot, naminito3, naminito4, naminito5,
                 flgact, flgacto, costcent, compgrp, codposr, codappr, dteappr, costcento, compgrpo, codposro, flgcal,
                 dtecreate, codcreate, dteupd, coduser, codcompy, comlevel)
              values
                (v_codcomp, v_dteeffec, v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5,
                 v_codcom1, v_codcom2, v_codcom3, v_codcom4, v_codcom5, v_codcom6, v_codcom7, v_codcom8, v_codcom9, v_codcom10,
                 v_namcentoe, v_namcentot, v_namcento3, v_namcento4, v_namcento5,
                 v_naminite, v_naminitt, v_naminit3, v_naminit4, v_naminit5,
                 v_naminitoe, v_naminitot, v_naminito3, v_naminito4, v_naminito5,
                 v_flgact, v_flgacto, v_costcent, v_compgrp, v_codposr, v_codappr, v_dteappr, v_costcento, v_compgrpo, v_codposro, v_flgcal,
                 sysdate, global_v_coduser, sysdate, global_v_coduser, v_codcompy, v_comlevel);
            exception
              when DUP_VAL_ON_INDEX then
                  update tcenterlog
                     set namcente = v_namcente,namcentt = v_namcentt,namcent3 = v_namcent3,namcent4 = v_namcent4,namcent5 = v_namcent5,
                         codcom1 = v_codcom1,codcom2 = v_codcom2,codcom3 = v_codcom3,codcom4 = v_codcom4,codcom5 = v_codcom5,codcom6 = v_codcom6,codcom7 = v_codcom7,codcom8 = v_codcom8,codcom9 = v_codcom9,codcom10 = v_codcom10,
                         naminite = v_naminite,naminitt = v_naminitt,naminit3 = v_naminit3,naminit4 = v_naminit4,naminit5 = v_naminit5,
                         flgact = v_flgact,flgacto = v_flgacto,
                         costcent = v_costcent,compgrp = v_compgrp,codposr = v_codposr,codappr = v_codappr,dteappr = v_dteappr,
                         flgcal = v_flgcal,
                         dteupd = sysdate ,coduser = global_v_coduser  , codcompy = v_codcompy,comlevel = v_comlevel
                   where codcomp = v_codcomp
                         and dteeffec = v_dteeffec;
              when others then
               param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
               rollback ;
               return ;
            end ;
            if v_dteeffec <= trunc(sysdate) then
                begin
                  insert into tcenter
                     (codcomp, namcente, namcentt, namcent3, namcent4, namcent5,
                      codcom1, codcom2, codcom3, codcom4, codcom5, codcom6, codcom7, codcom8, codcom9, codcom10,
                      naminite, naminitt, naminit3, naminit4, naminit5,
                      flgact , costcent, compgrp, codposr, dtecreate, codcreate, dteupd, coduser ,codcompy, comlevel )
                  values
                     (v_codcomp, v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5,
                      v_codcom1, v_codcom2, v_codcom3, v_codcom4, v_codcom5, v_codcom6, v_codcom7, v_codcom8, v_codcom9, v_codcom10,
                      v_naminite, v_naminitt, v_naminit3, v_naminit4, v_naminit5,
                      v_flgact,  v_costcent, v_compgrp, v_codposr, sysdate, global_v_coduser, sysdate, global_v_coduser, v_codcompy, v_comlevel);
                exception
                  when DUP_VAL_ON_INDEX then
                    update tcenter
                    set    namcente = v_namcente,namcentt = v_namcentt,namcent3 = v_namcent3,namcent4 = v_namcent4,namcent5 = v_namcent5,
                           codcom1 = v_codcom1,codcom2 = v_codcom2,codcom3 = v_codcom3,codcom4 = v_codcom4,codcom5 = v_codcom5,codcom6 = v_codcom6,codcom7 = v_codcom7,codcom8 = v_codcom8,codcom9 = v_codcom9,codcom10 = v_codcom10,
                           naminite = v_naminite,naminitt = v_naminitt,naminit3 = v_naminit3,naminit4 = v_naminit4,naminit5 = v_naminit5,
                           flgact = v_flgact,costcent = v_costcent,compgrp = v_compgrp,codposr = v_codposr,
                           dteupd = sysdate,coduser = global_v_coduser,
                           codcompy = v_codcompy,comlevel = v_comlevel
                    where  codcomp = v_codcomp;
                  when others then
                   param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                   rollback ;
                   return ;
                end ;

                update tcenterlog
                   set flgcal = 'Y'
                 where codcomp = v_codcomp
                   and dteeffec = v_dteeffec;
            end if;

        else  --if error
          v_rec_error      := v_rec_error + 1;
          v_cnt            := v_cnt+1;
          -- puch value in array
          p_text(v_cnt)       := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||'['||v_err_filed||']';
          p_numseq(v_cnt)     := r1+1;
        end if;
      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;

  procedure get_dropdowns(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_dropdowns(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_dropdowns;

  procedure gen_dropdowns(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt		    number := 0;
    v_flgsecu       boolean ;
    v_levelCount    number;
    cursor c_tcompnyc is
      select  comlevel
      from    tcompnyc
      where    codcompy = p_codcompy
      and comlevel <> 1
      order by codcompy;

    cursor c_tcompnyc2 is
      select  comlevel
      from    tcompnyc
      where    codcompy = p_codcompy
      order by codcompy;
  begin
    obj_row         := json_object_t();
    obj_result      := json_object_t();
    obj_data    := json_object_t();
    for r_tcompnyc in c_tcompnyc loop
        obj_data.put(to_char(r_tcompnyc.comlevel),to_char(r_tcompnyc.comlevel));
    end loop;
    obj_row.put('en', obj_data);
    obj_row.put('th', obj_data);
    obj_row.put('103', obj_data);
    obj_row.put('104', obj_data);
    obj_row.put('105', obj_data);
    obj_result.put('coderror', '200');
    obj_result.put('level',obj_row);

    obj_data    := json_object_t();
    obj_data.put(to_char(1),to_char(1));
    for r_tcompnyc2 in c_tcompnyc2 loop
        obj_data.put(to_char(r_tcompnyc2.comlevel),to_char(r_tcompnyc2.comlevel));
    end loop;
    obj_row.put('en', obj_data);
    obj_row.put('th', obj_data);
    obj_row.put('103', obj_data);
    obj_row.put('104', obj_data);
    obj_row.put('105', obj_data);
    obj_result.put('underlevel',obj_row);

    json_str_output := obj_result.to_clob;
  end gen_dropdowns;

procedure save_formlevel (json_str_input in clob, json_str_output out clob) is
    v_flgsecu           boolean := false;
    json_row            json_object_t;
    sql_stmt            varchar2(2000 char);
    v_count             number ;
    v_flg               varchar2(50 char);
    v_dteeffec          tcenterlog.dteeffec%type;
    v_codcomp           tcenter.codcomp%type;
    v_namcent           tcenter.namcente%type;
    v_namcente          tcenter.namcente%type;
    v_namcentt          tcenter.namcentt%type;
    v_namcent3          tcenter.namcent3%type;
    v_namcent4          tcenter.namcent4%type;
    v_namcent5          tcenter.namcent5%type;
    v_codcom            varchar2(2000 char);
    v_codcom1           tcenter.codcom1%type;
    v_codcom2           tcenter.codcom2%type;
    v_codcom3           tcenter.codcom3%type;
    v_codcom4           tcenter.codcom4%type;
    v_codcom5           tcenter.codcom5%type;
    v_codcom6           tcenter.codcom6%type;
    v_codcom7           tcenter.codcom7%type;
    v_codcom8           tcenter.codcom8%type;
    v_codcom9           tcenter.codcom9%type;
    v_codcom10          tcenter.codcom10%type;
    v_naminit           tcenter.naminite%type;
    v_naminite          tcenter.naminite%type;
    v_naminitt          tcenter.naminitt%type;
    v_naminit3          tcenter.naminit3%type;
    v_naminit4          tcenter.naminit4%type;
    v_naminit5          tcenter.naminit5%type;
    v_flgact            tcenter.flgact%type;
    v_costcent          tcenter.costcent%type;
    v_compgrp           tcenter.compgrp%type;
    v_codposr           tcenter.codposr%type;
    v_codappr           tcenterlog.codappr%type;
    v_dteappr           tcenterlog.dteappr%type;
    v_namcentoe         tcenterlog.namcentoe%type;
    v_namcentot         tcenterlog.namcentot%type;
    v_namcento3         tcenterlog.namcento3%type;
    v_namcento4         tcenterlog.namcento4%type;
    v_namcento5         tcenterlog.namcento5%type;
    v_naminitoe         tcenterlog.naminitoe%type;
    v_naminitot         tcenterlog.naminitot%type;
    v_naminito3         tcenterlog.naminito3%type;
    v_naminito4         tcenterlog.naminito4%type;
    v_naminito5         tcenterlog.naminito5%type;
    v_flgacto           tcenterlog.flgacto%type;
    v_costcento         tcenterlog.costcento%type;
    v_compgrpo          tcenterlog.compgrpo%type;
    v_codposro          tcenterlog.codposro%type;
    v_flgcal            tcenterlog.flgcal%type;

    v_codcompy          tcenter.codcompy%type;
    v_comlevel          tcenter.comlevel%type;
    v_detl_tbl          varchar2(50) ;
    v_detl_column       varchar2(50) ;
    v_comparent         tcenter.comparent%type;
    v_codemprp          tcenter.codemprp%type;
    param_json_row      json_object_t;
    v_chk_exist         number;
    v_flgDelete         boolean;

    json_table      json_object_t;
  begin
    initial_value (json_str_input);
--    json_table json_ext.get_string(json_obj,'p_type');
    json_table := hcm_util.get_json_t(json_params_formlevel,'table');
    json_table := hcm_util.get_json_t(json_table,'rows');
    for i in 0..json_table.get_size - 1 loop
        param_json_row  := hcm_util.get_json_t(json_table, to_char(i));
        v_comlevel      := p_comlevel;
        v_comparent     := get_compful (hcm_util.get_string_t(param_json_row, 'codcomp'));
        v_codcomp       := get_compful (hcm_util.get_codcomp_level (v_comparent,p_comlevel-1)||hcm_util.get_string_t(param_json_row, 'level2'));
        v_codcom1       := get_comp_split (v_codcomp,1);
        v_codcom2       := get_comp_split (v_codcomp,2);
        v_codcom3       := get_comp_split (v_codcomp,3);
        v_codcom4       := get_comp_split (v_codcomp,4);
        v_codcom5       := get_comp_split (v_codcomp,5);
        v_codcom6       := get_comp_split (v_codcomp,6);
        v_codcom7       := get_comp_split (v_codcomp,7);
        v_codcom8       := get_comp_split (v_codcomp,8);
        v_codcom9       := get_comp_split (v_codcomp,9);
        v_codcom10      := get_comp_split (v_codcomp,10);
        v_codcompy      := v_codcom1;
        v_namcent       := hcm_util.get_string_t(param_json_row, 'desc_codcomp');
        v_namcente      := hcm_util.get_string_t(param_json_row, 'namcente');
        v_namcentt      := hcm_util.get_string_t(param_json_row, 'namcentt');
        v_namcent3      := hcm_util.get_string_t(param_json_row, 'namcent3');
        v_namcent4      := hcm_util.get_string_t(param_json_row, 'namcent4');
        v_namcent5      := hcm_util.get_string_t(param_json_row, 'namcent5');

        if global_v_lang = '101' then
            v_namcente := v_namcent;
        elsif global_v_lang = '102' then
            v_namcentt := v_namcent;
        elsif global_v_lang = '103' then
            v_namcent3 := v_namcent;
        elsif global_v_lang = '104' then
            v_namcent4 := v_namcent;
        elsif global_v_lang = '105' then
            v_namcent5 := v_namcent;
        end if;
        v_flgact        := nvl(hcm_util.get_string_t(param_json_row, 'flgact'),'1');
        v_codposr       := hcm_util.get_string_t(param_json_row, 'codposr');
        v_costcent      := hcm_util.get_string_t(param_json_row, 'costcent');
        v_naminit       := '';
        v_flgcal        := 'Y';
        p_parent_comlevel := hcm_util.get_string_t(param_json_row, 'under_level');
        begin
            select compgrp
              into v_compgrp
              from tcompny
             where codcompy = v_codcompy;
        exception when no_data_found then
            v_compgrp:= null;
        end;
        v_codemprp  := '';
        v_dteeffec  := trunc(sysdate);
        v_codappr   := global_v_codempid;
        v_dteappr   := trunc(sysdate);
        v_flgDelete := hcm_util.get_boolean_t(param_json_row, 'flgDelete');

        if v_flgDelete then
            select count(codempid)
              into v_chk_exist
              from temploy1
             where codcomp = v_codcomp;

             if v_chk_exist = 0 then
                select count(codempid)
                  into v_chk_exist
                  from ttmovemt
                 where codcomp = v_codcomp;
                if v_chk_exist > 0 then
                    param_msg_error := get_error_msg_php('CO0030', global_v_lang);
                    exit ;
                end if;
             else
                param_msg_error := get_error_msg_php('CO0030', global_v_lang);
                exit ;
             end if;

             delete from tcenter
                   where codcomp = v_codcomp;
        else

            begin
              insert into tcenter
                 (codcomp, namcente, namcentt, namcent3, namcent4, namcent5,
                  codcom1, codcom2, codcom3, codcom4, codcom5, codcom6, codcom7, codcom8, codcom9, codcom10,
                  naminite, naminitt, naminit3, naminit4, naminit5,
                  flgact , costcent, compgrp, codposr, dtecreate, codcreate, dteupd, coduser ,codcompy, comlevel )
              values
                 (v_codcomp, v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5,
                  v_codcom1, v_codcom2, v_codcom3, v_codcom4, v_codcom5, v_codcom6, v_codcom7, v_codcom8, v_codcom9, v_codcom10,
                  v_naminite, v_naminitt, v_naminit3, v_naminit4, v_naminit5,
                  v_flgact,  v_costcent, v_compgrp, v_codposr, sysdate, global_v_coduser, sysdate, global_v_coduser, v_codcompy, v_comlevel);
            exception
              when DUP_VAL_ON_INDEX then
                null;
    --            update tcenter
    --            set    namcente = v_namcente,namcentt = v_namcentt,namcent3 = v_namcent3,namcent4 = v_namcent4,namcent5 = v_namcent5,
    --                   codcom1 = v_codcom1,codcom2 = v_codcom2,codcom3 = v_codcom3,codcom4 = v_codcom4,codcom5 = v_codcom5,codcom6 = v_codcom6,codcom7 = v_codcom7,codcom8 = v_codcom8,codcom9 = v_codcom9,codcom10 = v_codcom10,
    --                   naminite = v_naminite,naminitt = v_naminitt,naminit3 = v_naminit3,naminit4 = v_naminit4,naminit5 = v_naminit5,
    --                   flgact = v_flgact,costcent = v_costcent,compgrp = v_compgrp,codposr = v_codposr,
    --                   dteupd = sysdate,coduser = global_v_coduser,
    --                   codcompy = v_codcompy, comlevel = v_comlevel
    --            where  codcomp = v_codcomp;
              when others then
               param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
               exit ;
               return ;
            end ;

            begin
              insert into tcenterlog
                (codcomp, dteeffec, namcente, namcentt, namcent3, namcent4, namcent5,
                 codcom1, codcom2, codcom3, codcom4, codcom5, codcom6, codcom7, codcom8, codcom9, codcom10,
                 naminite, naminitt, naminit3, naminit4, naminit5,
                 flgact,  costcent, compgrp, codposr, codappr, dteappr,  flgcal,
                 dtecreate, codcreate, dteupd, coduser, codcompy, comlevel)
              values
                (v_codcomp, v_dteeffec, v_namcente, v_namcentt, v_namcent3, v_namcent4, v_namcent5,
                 v_codcom1, v_codcom2, v_codcom3, v_codcom4, v_codcom5, v_codcom6, v_codcom7, v_codcom8, v_codcom9, v_codcom10,
                 v_naminite, v_naminitt, v_naminit3, v_naminit4, v_naminit5,
                 v_flgact, v_costcent, v_compgrp, v_codposr, v_codappr, v_dteappr, v_flgcal,
                 sysdate, global_v_coduser, sysdate, global_v_coduser, v_codcompy, v_comlevel);
            exception
              when DUP_VAL_ON_INDEX then
                null;
    --              update tcenterlog
    --                 set namcente = v_namcente,namcentt = v_namcentt,namcent3 = v_namcent3,namcent4 = v_namcent4,namcent5 = v_namcent5,
    --                     codcom1 = v_codcom1,codcom2 = v_codcom2,codcom3 = v_codcom3,codcom4 = v_codcom4,codcom5 = v_codcom5,codcom6 = v_codcom6,codcom7 = v_codcom7,codcom8 = v_codcom8,codcom9 = v_codcom9,codcom10 = v_codcom10,
    --                     naminite = v_naminite,naminitt = v_naminitt,naminit3 = v_naminit3,naminit4 = v_naminit4,naminit5 = v_naminit5,
    --                     flgact = v_flgact,flgacto = v_flgacto,
    --                     costcent = v_costcent,compgrp = v_compgrp,codposr = v_codposr,codappr = v_codappr,dteappr = v_dteappr,
    --                     flgcal = v_flgcal,
    --                     dteupd = sysdate ,coduser = global_v_coduser  , codcompy = v_codcompy,comlevel = v_comlevel
    --               where codcomp = v_codcomp
    --                     and dteeffec = v_dteeffec;
              when others then
               param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
               rollback ;
               exit ;
            end ;
        end if;
    end loop;
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
  end save_formlevel;
  
    function get_codcomp_parent (p_codcomp varchar2,p_comlevel number) return varchar2 is
        v_codcompy varchar2(10 char);
        v_codcom1           tcenter.codcom1%type;
        v_codcom2           tcenter.codcom2%type;
        v_codcom3           tcenter.codcom3%type;
        v_codcom4           tcenter.codcom4%type;
        v_codcom5           tcenter.codcom5%type;
        v_codcom6           tcenter.codcom6%type;
        v_codcom7           tcenter.codcom7%type;
        v_codcom8           tcenter.codcom8%type;
        v_codcom9           tcenter.codcom9%type;
        v_codcom10          tcenter.codcom10%type;
    begin
        v_codcompy  := get_comp_split (p_codcomp,1);
        v_codcom1   := get_comp_split (p_codcomp,1);
        v_codcom2   := get_comp_split (p_codcomp,2);
        v_codcom3   := get_comp_split (p_codcomp,3);
        v_codcom4   := get_comp_split (p_codcomp,4);
        v_codcom5   := get_comp_split (p_codcomp,5);
        v_codcom6   := get_comp_split (p_codcomp,6);
        v_codcom7   := get_comp_split (p_codcomp,7);
        v_codcom8   := get_comp_split (p_codcomp,8);
        v_codcom9   := get_comp_split (p_codcomp,9);
        v_codcom10  := get_comp_split (p_codcomp,10);
        
        if p_comlevel = 10 then
            if lpad(nvl(v_codcom9,'0'),4,'0') != '0000' then
                return get_compful(hcm_util.get_codcomp_level(p_codcomp, 9));
            end if;
        end if;
        
        if p_comlevel >= 9 then
            if lpad(nvl(v_codcom8,'0'),4,'0') != '0000' then
                return get_compful(hcm_util.get_codcomp_level(p_codcomp, 8));
            end if;
        end if;
        
        if p_comlevel >= 8 then
            if lpad(nvl(v_codcom7,'0'),4,'0') != '0000' then
                return get_compful(hcm_util.get_codcomp_level(p_codcomp, 7));
            end if;
        end if;
        
        if p_comlevel >= 7 then
            if lpad(nvl(v_codcom6,'0'),4,'0') != '0000' then
                return get_compful(hcm_util.get_codcomp_level(p_codcomp, 6));
            end if;
        end if;
        
        if p_comlevel >= 6 then
            if lpad(nvl(v_codcom5,'0'),4,'0') != '0000' then
                return get_compful(hcm_util.get_codcomp_level(p_codcomp, 5));
            end if;
        end if;
        
        if p_comlevel >= 5 then
            if lpad(nvl(v_codcom4,'0'),4,'0') != '0000' then
                return get_compful(hcm_util.get_codcomp_level(p_codcomp, 4));
            end if;
        end if;
        
        if p_comlevel >= 4 then
            if lpad(nvl(v_codcom3,'0'),4,'0') != '0000' then
                return get_compful(hcm_util.get_codcomp_level(p_codcomp, 3));
            end if;
        end if;
        
        if p_comlevel >= 3 then
            if lpad(nvl(v_codcom2,'0'),4,'0') != '0000' then
                return get_compful(hcm_util.get_codcomp_level(p_codcomp, 2));
            end if;
        end if;
        
        if p_comlevel >= 2 then
            if lpad(nvl(v_codcom1,'0'),4,'0') != '0000' then
                return get_compful(hcm_util.get_codcomp_level(p_codcomp, 1));
            end if;
        end if;
        
        return get_compful(hcm_util.get_codcomp_level(p_codcomp, 1));
    end;  
end HRCO04E;

/

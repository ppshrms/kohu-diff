--------------------------------------------------------
--  DDL for Package Body HRCO39E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO39E" is
-- last update: 11/03/2020 15:00
  procedure initial_value(json_str in clob) is
    json_obj   json := json(json_str);
  begin
    global_v_coduser  := json_ext.get_string(json_obj,'p_coduser');
    global_v_codempid := json_ext.get_string(json_obj,'p_codempid');
    global_v_lang     := json_ext.get_string(json_obj,'p_lang');

    --p_codcompy        := json_ext.get_string(json_obj,'p_codcompy');
    p_codapp            := upper(hcm_util.get_string(json_obj, 'p_codapp'));
    p_codproc           := upper(hcm_util.get_string(json_obj, 'p_codproc'));

    p_codapp_rep        := hcm_util.get_string(json_obj,'p_codapp_rep');
    p_codempid          := hcm_util.get_string(json_obj,'p_codempid');
   -- p_numseq          := hcm_util.get_string(json_obj,'p_numseq');
    -- save index
    json_params         := hcm_util.get_json(json_obj, 'params');

  end initial_value;
----------------------------------------------------------------------------------
  procedure get_trepapp_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_trepapp_detail(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_trepapp_detail;
----------------------------------------------------------------------------------
  procedure gen_trepapp_detail (json_str_output out clob) is
    obj_data               json;
    v_namprint             trepapp.namprinte%type;
    v_namprinte            trepapp.namprinte%type;
    v_namprintt            trepapp.namprintt%type;
    v_namprint3            trepapp.namprint3%type;
    v_namprint4            trepapp.namprint4%type;
    v_namprint5            trepapp.namprint5%type;
    v_nampage              trepapp.nampagee%type;
    v_nampagee             trepapp.nampagee%type;
    v_nampaget             trepapp.nampaget%type;
    v_nampage3             trepapp.nampage3%type;
    v_nampage4             trepapp.nampage4%type;
    v_nampage5             trepapp.nampage5%type;
    v_flgfoot1             trepapp.flgfoot1%type;
    v_footer1              trepapp.footer1e%type;
    v_footer1e             trepapp.footer1e%type;
    v_footer1t             trepapp.footer1t%type;
    v_footer13             trepapp.footer13%type;
    v_footer14             trepapp.footer14%type;
    v_footer15             trepapp.footer15%type;
    v_flgfoot2             trepapp.flgfoot2%type;
    v_footer2              trepapp.footer2e%type;
    v_footer2e             trepapp.footer2e%type;
    v_footer2t             trepapp.footer2t%type;
    v_footer23             trepapp.footer23%type;
    v_footer24             trepapp.footer24%type;
    v_footer25             trepapp.footer25%type;
    v_flgfoot3             trepapp.flgfoot3%type;
    v_footer3              trepapp.footer3e%type;
    v_footer3e             trepapp.footer3e%type;
    v_footer3t             trepapp.footer3t%type;
    v_footer33             trepapp.footer33%type;
    v_footer34             trepapp.footer34%type;
    v_footer35             trepapp.footer35%type;
    v_flgdeflt             trepapp.flgdeflt%type;
  begin
    begin
      select decode(global_v_lang,  '101', t.namprinte,
                                    '102', t.namprintt,
                                    '103', t.namprint3,
                                    '104', t.namprint4,
                                    '105', t.namprint5,
                                    t.namprinte) as namprint ,
             t.namprinte, t.namprintt, t.namprint3, t.namprint4, t.namprint5,
             decode(global_v_lang,  '101', t.nampagee,
                                    '102', t.nampaget,
                                    '103', t.nampage3,
                                    '104', t.nampage4,
                                    '105', t.nampage5,
                                    t.nampagee) as nampage ,
             t.nampagee, t.nampaget, t.nampage3, t.nampage4, t.nampage5,
             t.flgfoot1,
             decode(global_v_lang,  '101', t.footer1e,
                                    '102', t.footer1t,
                                    '103', t.footer13,
                                    '104', t.footer14,
                                    '105', t.footer15,
                                    t.footer1e) as footer1 ,
             t.footer1e, t.footer1t, t.footer13, t.footer14, t.footer15,
             t.flgfoot2,
             decode(global_v_lang,  '101', t.footer2e,
                                    '102', t.footer2t,
                                    '103', t.footer23,
                                    '104', t.footer24,
                                    '105', t.footer25,
                                    t.footer2e) as footer2 ,
             t.footer2e, t.footer2t, t.footer23, t.footer24, t.footer25,
             t.flgfoot3,
             decode(global_v_lang,  '101', t.footer3e,
                                    '102', t.footer3t,
                                    '103', t.footer33,
                                    '104', t.footer34,
                                    '105', t.footer35,
                                    t.footer3e) as footer3 ,
             t.footer3e, t.footer3t, t.footer33, t.footer34, t.footer35, t.flgdeflt
      into   v_namprint, v_namprinte, v_namprintt, v_namprint3, v_namprint4, v_namprint5,
             v_nampage,  v_nampagee,  v_nampaget,  v_nampage3,  v_nampage4,  v_nampage5,
             v_flgfoot1, v_footer1,   v_footer1e,  v_footer1t,  v_footer13,  v_footer14, v_footer15,
             v_flgfoot2, v_footer2,   v_footer2e,  v_footer2t,  v_footer23,  v_footer24, v_footer25,
             v_flgfoot3, v_footer3,   v_footer3e,  v_footer3t,  v_footer33,  v_footer34, v_footer35,
             v_flgdeflt
      from   trepapp t
      where  t.codapp = p_codapp_rep ;
    exception when no_data_found then
      select decode(global_v_lang,  '101', t.namprinte,
                                    '102', t.namprintt,
                                    '103', t.namprint3,
                                    '104', t.namprint4,
                                    '105', t.namprint5,
                                    t.namprinte) as namprint ,
             t.namprinte, t.namprintt, t.namprint3, t.namprint4, t.namprint5,
             decode(global_v_lang,  '101', t.nampagee,
                                    '102', t.nampaget,
                                    '103', t.nampage3,
                                    '104', t.nampage4,
                                    '105', t.nampage5,
                                    t.nampagee) as nampage ,
             t.nampagee, t.nampaget, t.nampage3, t.nampage4, t.nampage5,
             t.flgfoot1,
             decode(global_v_lang,  '101', t.footer1e,
                                    '102', t.footer1t,
                                    '103', t.footer13,
                                    '104', t.footer14,
                                    '105', t.footer15,
                                    t.footer1e) as footer1 ,
             t.footer1e, t.footer1t, t.footer13, t.footer14, t.footer15,
             t.flgfoot2,
             decode(global_v_lang,  '101', t.footer2e,
                                    '102', t.footer2t,
                                    '103', t.footer23,
                                    '104', t.footer24,
                                    '105', t.footer25,
                                    t.footer2e) as footer2 ,
             t.footer2e, t.footer2t, t.footer23, t.footer24, t.footer25,
             t.flgfoot3,
             decode(global_v_lang,  '101', t.footer3e,
                                    '102', t.footer3t,
                                    '103', t.footer33,
                                    '104', t.footer34,
                                    '105', t.footer35,
                                    t.footer3e) as footer3 ,
             t.footer3e, t.footer3t, t.footer33, t.footer34, t.footer35, t.flgdeflt
      into   v_namprint, v_namprinte, v_namprintt, v_namprint3, v_namprint4, v_namprint5,
             v_nampage,  v_nampagee,  v_nampaget,  v_nampage3,  v_nampage4,  v_nampage5,
             v_flgfoot1, v_footer1,   v_footer1e,  v_footer1t,  v_footer13,  v_footer14, v_footer15,
             v_flgfoot2, v_footer2,   v_footer2e,  v_footer2t,  v_footer23,  v_footer24, v_footer25,
             v_flgfoot3, v_footer3,   v_footer3e,  v_footer3t,  v_footer33,  v_footer34, v_footer35,
             v_flgdeflt
      from   trepapp t
      where  t.codapp = 'STD' ;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('codapp', p_codapp_rep);
    obj_data.put('namprint', v_namprint);
    obj_data.put('namprinte', v_namprinte);
    obj_data.put('namprintt', v_namprintt);
    obj_data.put('namprint3', v_namprint3);
    obj_data.put('namprint4', v_namprint4);
    obj_data.put('namprint5', v_namprint5);
    obj_data.put('nampage', v_nampage);
    obj_data.put('nampagee', v_nampagee);
    obj_data.put('nampaget', v_nampaget);
    obj_data.put('nampage3', v_nampage3);
    obj_data.put('nampage4', v_nampage4);
    obj_data.put('nampage5', v_nampage5);
    obj_data.put('flgfoot1', v_flgfoot1);
    obj_data.put('footer1', v_footer1);
    obj_data.put('footer1e', v_footer1e);
    obj_data.put('footer1t', v_footer1t);
    obj_data.put('footer13', v_footer13);
    obj_data.put('footer14', v_footer14);
    obj_data.put('footer15', v_footer15);
    obj_data.put('flgfoot2', v_flgfoot2);
    obj_data.put('footer2', v_footer2);
    obj_data.put('footer2e', v_footer2e);
    obj_data.put('footer2t', v_footer2t);
    obj_data.put('footer23', v_footer23);
    obj_data.put('footer24', v_footer24);
    obj_data.put('footer25', v_footer25);
    obj_data.put('flgfoot3', v_flgfoot3);
    obj_data.put('footer3', v_footer3);
    obj_data.put('footer3e', v_footer3e);
    obj_data.put('footer3t', v_footer3t);
    obj_data.put('footer33', v_footer33);
    obj_data.put('footer34', v_footer34);
    obj_data.put('footer35', v_footer35);
    obj_data.put('flgdeflt', v_flgdeflt);
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_trepapp_detail;
----------------------------------------------------------------------------------
  procedure save_trepapp (json_str_input in clob, json_str_output out clob) is
    --json_row            json;
    --sql_stmt            varchar2(2000 char);
    v_count             number ;
    v_flg               varchar2(50 char);
    v_namprint             trepapp.namprinte%type;
    v_namprinte            trepapp.namprinte%type;
    v_namprintt            trepapp.namprintt%type;
    v_namprint3            trepapp.namprint3%type;
    v_namprint4            trepapp.namprint4%type;
    v_namprint5            trepapp.namprint5%type;
    v_nampage              trepapp.nampagee%type;
    v_nampagee             trepapp.nampagee%type;
    v_nampaget             trepapp.nampaget%type;
    v_nampage3             trepapp.nampage3%type;
    v_nampage4             trepapp.nampage4%type;
    v_nampage5             trepapp.nampage5%type;
    v_flgfoot1             trepapp.flgfoot1%type;
    v_footer1              trepapp.footer1e%type;
    v_footer1e             trepapp.footer1e%type;
    v_footer1t             trepapp.footer1t%type;
    v_footer13             trepapp.footer13%type;
    v_footer14             trepapp.footer14%type;
    v_footer15             trepapp.footer15%type;
    v_flgfoot2             trepapp.flgfoot2%type;
    v_footer2              trepapp.footer2e%type;
    v_footer2e             trepapp.footer2e%type;
    v_footer2t             trepapp.footer2t%type;
    v_footer23             trepapp.footer23%type;
    v_footer24             trepapp.footer24%type;
    v_footer25             trepapp.footer25%type;
    v_flgfoot3             trepapp.flgfoot3%type;
    v_footer3              trepapp.footer3e%type;
    v_footer3e             trepapp.footer3e%type;
    v_footer3t             trepapp.footer3t%type;
    v_footer33             trepapp.footer33%type;
    v_footer34             trepapp.footer34%type;
    v_footer35             trepapp.footer35%type;
    v_flgdeflt             trepapp.flgdeflt%type;
    v_margintop            trepapp.margintop%type;
    v_marginright          trepapp.marginright%type;
    v_marginbott           trepapp.marginbott%type;
    v_marginleft           trepapp.marginleft%type;
    v_widlogo              trepapp.widlogo%type;
    v_heighlogo            trepapp.heighlogo%type;
    v_hdcolor              trepapp.hdcolor%type;
    v_bgcolor1             trepapp.bgcolor1%type;
    v_bgcolor2             trepapp.bgcolor2%type;
    v_bgcolor3             trepapp.bgcolor3%type;
    v_bgcolor4             trepapp.bgcolor4%type;
    v_bgcolor5             trepapp.bgcolor5%type;
    v_bgcolor6             trepapp.bgcolor6%type;
    v_bgcolor7             trepapp.bgcolor7%type;
    v_rowcolor1            trepapp.rowcolor1%type;
    v_rowcolor2            trepapp.rowcolor2%type;
    v_flgimgemp            trepapp.flgimgemp%type;
    v_alignft1             trepapp.alignft1%type;
    v_alignft2             trepapp.alignft2%type;
    v_alignft3             trepapp.alignft3%type;
    v_footerdisp           trepapp.footerdisp%type;

    --v_detl_tbl          varchar2(50) ;
    --v_detl_column       varchar2(50) ;

  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      -----------------------------------
        v_flg             := hcm_util.get_string(json_params, 'flg');
        v_namprint        := hcm_util.get_string(json_params, 'namprint');
        v_namprinte       := hcm_util.get_string(json_params, 'namprinte');
        v_namprintt       := hcm_util.get_string(json_params, 'namprintt');
        v_namprint3       := hcm_util.get_string(json_params, 'namprint3');
        v_namprint4       := hcm_util.get_string(json_params, 'namprint4');
        v_namprint5       := hcm_util.get_string(json_params, 'namprint5');
        v_nampage         := hcm_util.get_string(json_params, 'nampage');
        v_nampagee        := hcm_util.get_string(json_params, 'nampagee');
        v_nampaget        := hcm_util.get_string(json_params, 'nampaget');
        v_nampage3        := hcm_util.get_string(json_params, 'nampage3');
        v_nampage4        := hcm_util.get_string(json_params, 'nampage4');
        v_nampage5        := hcm_util.get_string(json_params, 'nampage5');
        v_flgfoot1        := hcm_util.get_string(json_params, 'flgfoot1');
        v_footer1         := hcm_util.get_string(json_params, 'footer1');
        v_footer1e        := hcm_util.get_string(json_params, 'footer1e');
        v_footer1t        := hcm_util.get_string(json_params, 'footer1t');
        v_footer13        := hcm_util.get_string(json_params, 'footer13');
        v_footer14        := hcm_util.get_string(json_params, 'footer14');
        v_footer15        := hcm_util.get_string(json_params, 'footer15');
        v_flgfoot2        := hcm_util.get_string(json_params, 'flgfoot2');
        v_footer2         := hcm_util.get_string(json_params, 'footer2');
        v_footer2e        := hcm_util.get_string(json_params, 'footer2e');
        v_footer2t        := hcm_util.get_string(json_params, 'footer2t');
        v_footer23        := hcm_util.get_string(json_params, 'footer23');
        v_footer24        := hcm_util.get_string(json_params, 'footer24');
        v_footer25        := hcm_util.get_string(json_params, 'footer25');
        v_flgfoot3        := hcm_util.get_string(json_params, 'flgfoot3');
        v_footer3         := hcm_util.get_string(json_params, 'footer3');
        v_footer3e        := hcm_util.get_string(json_params, 'footer3e');
        v_footer3t        := hcm_util.get_string(json_params, 'footer3t');
        v_footer33        := hcm_util.get_string(json_params, 'footer33');
        v_footer34        := hcm_util.get_string(json_params, 'footer34');
        v_footer35        := hcm_util.get_string(json_params, 'footer35');
        v_flgdeflt        := hcm_util.get_string(json_params, 'flgdeflt');
        v_margintop       := '10';
        v_marginright     := '10';
        v_marginbott      := '10';
        v_marginleft      := '10';
        v_widlogo         := '30';
        v_heighlogo       := '30';
        v_hdcolor         := '#3887c9';
        v_bgcolor1        := '#6ee82f';
        v_bgcolor2        := '#1e7ee2';
        v_bgcolor3        := '#1ee2be';
        v_bgcolor4        := '#1eace2';
        v_bgcolor5        := '#1e75e2';
        v_bgcolor6        := '#1e48e2';
        v_bgcolor7        := '#4e6cda';
        v_rowcolor1       := '#ffffff';
        v_rowcolor2       := '#f1f1f1';
        v_flgimgemp       := 'Y';
        v_alignft1        := 'L';
        v_alignft2        := 'L';
        v_alignft3        := 'R';
        v_footerdisp      := 'allpage';


        if global_v_lang = '101' then
          v_namprinte := v_namprint;
          v_nampagee := v_nampage;
          v_footer1e := v_footer1;
          v_footer2e := v_footer2;
          v_footer3e := v_footer3;
        elsif global_v_lang = '102' then
          v_namprintt := v_namprint;
          v_nampaget := v_nampage;
          v_footer1t := v_footer1;
          v_footer2t := v_footer2;
          v_footer3t := v_footer3;
        elsif global_v_lang = '103' then
          v_namprint3 := v_namprint;
          v_nampage3 := v_nampage;
          v_footer13 := v_footer1;
          v_footer23 := v_footer2;
          v_footer33 := v_footer3;
        elsif global_v_lang = '104' then
          v_namprint4 := v_namprint;
          v_nampage4 := v_nampage;
          v_footer14 := v_footer1;
          v_footer24 := v_footer2;
          v_footer34 := v_footer3;
        elsif global_v_lang = '105' then
          v_namprint5 := v_namprint;
          v_nampage5 := v_nampage;
          v_footer15 := v_footer1;
          v_footer25 := v_footer2;
          v_footer35 := v_footer3;
        end if;

        if v_flg = 'delete' then
           begin
             delete trepapp
             where codapp = p_codapp_rep;
             delete trepappm
             where codapp = p_codapp_rep;
           exception when others then
             param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
           end;
        else
           if p_codapp_rep != 'STD' then
             ---------------------------------
              select count('x')
              into   v_count
              from    tappprof t1
              where   t1.codapp = p_codapp_rep ;
             ---------------------------------
             if v_count = 0 then
                    param_msg_error := get_error_msg_php('HR2010', global_v_lang);
                    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
                    return;
                 end if ;
                 ---------------------------------

           end if ;

           begin
              insert into trepapp
                (codapp, namprinte, namprintt, namprint3, namprint4, namprint5, nampagee, nampaget, nampage3, nampage4, nampage5, flgfoot1, footer1e, footer1t, footer13, footer14, footer15, flgfoot2, footer2e, footer2t, footer23, footer24, footer25, flgfoot3, footer3e, footer3t, footer33, footer34, footer35, flgdeflt, margintop, marginright, marginbott, marginleft, widlogo, heighlogo, hdcolor, bgcolor1, bgcolor2, bgcolor3, bgcolor4, bgcolor5, bgcolor6, bgcolor7, rowcolor1, rowcolor2, flgimgemp, alignft1, alignft2, alignft3, footerdisp, dtecreate, codcreate, dteupd, coduser)
              values
                (p_codapp_rep, v_namprinte, v_namprintt, v_namprint3, v_namprint4, v_namprint5, v_nampagee, v_nampaget, v_nampage3, v_nampage4, v_nampage5, v_flgfoot1, v_footer1e, v_footer1t, v_footer13, v_footer14, v_footer15, v_flgfoot2, v_footer2e, v_footer2t, v_footer23, v_footer24, v_footer25, v_flgfoot3, v_footer3e, v_footer3t, v_footer33, v_footer34, v_footer35, v_flgdeflt, v_margintop, v_marginright, v_marginbott, v_marginleft, v_widlogo, v_heighlogo, v_hdcolor, v_bgcolor1, v_bgcolor2, v_bgcolor3, v_bgcolor4, v_bgcolor5, v_bgcolor6, v_bgcolor7, v_rowcolor1, v_rowcolor2, v_flgimgemp, v_alignft1, v_alignft2, v_alignft3, v_footerdisp, sysdate, global_v_coduser, sysdate, global_v_coduser);
           exception
             when DUP_VAL_ON_INDEX then
               update trepapp
                 set namprinte = v_namprinte,
                     namprintt = v_namprintt,
                     namprint3 = v_namprint3,
                     namprint4 = v_namprint4,
                     namprint5 = v_namprint5,
                     nampagee = v_nampagee,
                     nampaget = v_nampaget,
                     nampage3 = v_nampage3,
                     nampage4 = v_nampage4,
                     nampage5 = v_nampage5,
                     flgfoot1 = v_flgfoot1,
                     footer1e = v_footer1e,
                     footer1t = v_footer1t,
                     footer13 = v_footer13,
                     footer14 = v_footer14,
                     footer15 = v_footer15,
                     flgfoot2 = v_flgfoot2,
                     footer2e = v_footer2e,
                     footer2t = v_footer2t,
                     footer23 = v_footer23,
                     footer24 = v_footer24,
                     footer25 = v_footer25,
                     flgfoot3 = v_flgfoot3,
                     footer3e = v_footer3e,
                     footer3t = v_footer3t,
                     footer33 = v_footer33,
                     footer34 = v_footer34,
                     footer35 = v_footer35,
                     flgdeflt = v_flgdeflt,
                     dteupd = sysdate,
                     coduser = global_v_coduser
               where codapp = p_codapp_rep;
             when others then
               param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
               json_str_output   := get_response_message(400, param_msg_error , global_v_lang);
               rollback ;
               return ;
           end;
        end if;
    end if;
    if param_msg_error is null then
      commit;
      if v_flg = 'delete' then
         param_msg_error := get_error_msg_php('HR2425', global_v_lang);
      else
         param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      end if;
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   :=  dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end save_trepapp;
----------------------------------------------------------------------------------
  procedure get_index_trepappm (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_trepappm (json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index_trepappm;
----------------------------------------------------------------------------------
  procedure gen_index_trepappm(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    --obj_result  json;
    v_rcnt		  number := 0;
    cursor c_trepappm is
            select  codapp, numseq, codempid, email
            from    trepappm
            where   codapp = p_codapp_rep
            order by numseq;
  begin

    obj_row     := json();
    --obj_result  := json();

    for r_trepappm in c_trepappm loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('codapp', r_trepappm.codapp);
      obj_data.put('numseq', r_trepappm.numseq);
      obj_data.put('codempid', r_trepappm.codempid);
      obj_data.put('email', r_trepappm.email);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_index_trepappm;
----------------------------------------------------------------------------------
  procedure save_index_trepappm (json_str_input in clob, json_str_output out clob) is
    json_row               json;
    v_flg                  varchar2(100 char);
    v_codapp               trepappm.codapp%type;
    v_codempid             trepappm.codempid%type;
    v_numseq               trepappm.numseq%type;
    v_email                trepappm.email%type;

  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.count - 1 loop
        json_row          := hcm_util.get_json(json_params, to_char(i));
        v_flg             := hcm_util.get_string(json_row, 'flg');
        v_codapp          := hcm_util.get_string(json_row, 'codapp');
        v_codempid        := hcm_util.get_string(json_row, 'codempid');
        v_numseq          := hcm_util.get_string(json_row, 'numseq');
        v_email           := hcm_util.get_string(json_row, 'email');

        if param_msg_error is not null then
          exit;
        end if;
        if v_flg = 'delete' then
          begin
            delete from trepappm where codapp = v_codapp and numseq = v_numseq ; --and codempid  = v_codempid;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end;
        elsif v_flg = 'add' then
           begin
              -----------------------------
              select nvl(max(numseq),0) into v_numseq from trepappm where codapp = p_codapp_rep ;
              v_numseq := v_numseq + 1 ;
              -----------------------------
              insert into trepappm
                (codapp, numseq, codempid, email, dtecreate, codcreate, dteupd, coduser)
              values
                (p_codapp_rep, v_numseq, v_codempid, v_email,sysdate, global_v_coduser, sysdate, global_v_coduser);
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
               update trepappm
                 set numseq = v_numseq,
                     codempid = v_codempid,
                     email = v_email,
                     dteupd = sysdate,
                     coduser = global_v_coduser
               where codapp = p_codapp_rep
                 and numseq = v_numseq;
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
  end save_index_trepappm;
----------------------------------------------------------------------------------
  procedure get_email_by_codempid (json_str_input in clob, json_str_output out clob) is
    --json_row               json;
    obj_data    json;
    v_email                temploy1.email%type;
  begin
    initial_value (json_str_input);
    v_email := '' ;
    if param_msg_error is null then
        select email
        into   v_email
        from temploy1
        where codempid = p_codempid ;
    end if;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('email', v_email);
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_email_by_codempid;

end HRCO39E;

/

--------------------------------------------------------
--  DDL for Package Body HRRC3CX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC3CX" AS

  procedure initial_current_user_value(json_str_input in clob) as
   json_obj json_object_t;
  begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

  end initial_current_user_value;

  procedure initial_params(data_obj json_object_t) as
  begin
        p_codcomp       := hcm_util.get_string_t(data_obj, 'p_codcomp');
        p_codpos        := hcm_util.get_string_t(data_obj, 'p_codpos');
        p_dteapplst     := to_date(hcm_util.get_string_t(data_obj, 'p_dteapplst') ,'dd/mm/yyyy');
        p_dteapplen     := to_date(hcm_util.get_string_t(data_obj, 'p_dteapplen') ,'dd/mm/yyyy');
        p_numappl       := hcm_util.get_string_t(data_obj, 'p_numappl');

  end initial_params;

  function check_index return boolean as
    v_temp      varchar(1 char);
  begin
    if p_codcomp is not null then
--  check codcomp
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp || '%'
              and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
            return false;
        end;

--  check secur7
        if secur_main.secur7(p_codcomp, global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return false;
        end if;
    end if;

    if p_codpos is not null then
--  check position
        begin
            select 'X' into v_temp
            from tpostn
            where codpos = p_codpos;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TPOSTN');
            return false;
        end;
    end if;

    if p_dteapplen < p_dteapplst then
        param_msg_error := get_error_msg_php('HR2021', global_v_lang);
        return false;
    end if;

    return true;

  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;

    cursor c1 is
      select numappl, dteappl, numreql, codposl, dtefoll,codtitle,
             decode(global_v_lang,'101',namfirste || ' ' || namlaste,
                                  '102',namfirstt || ' ' || namlastt,
                                  '103',namfirst3 || ' ' || namlast3,
                                  '104',namfirst4 || ' ' || namlast4,
                                  '105',namfirst5 || ' ' || namlast5) namfirst ,
             statappl, codempid
        from tapplinf
       where codcomp  like p_codcomp || '%'
         and codpos1  = nvl(p_codpos, codpos1)
         and dteappl  between nvl(p_dteapplst,dteappl) and nvl(p_dteapplen,dteappl) 
         and numappl  = nvl(p_numappl, numappl)
    order by numappl;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200'); --<<user25 Date:14/10/2021 #4252
        obj_data.put('image', get_emp_img(i.numappl));
        obj_data.put('numapp',i.numappl);
        obj_data.put('codempid', i.codempid);
--        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('desc_codempid', get_tlistval_name('CODTITLE', i.codtitle, global_v_lang) || i.namfirst);
        obj_data.put('codposl',i.codposl);
        obj_data.put('desc_codposa', get_tpostn_name(i.codposl, global_v_lang));
        obj_data.put('status', get_tlistval_name('STATAPPL', i.statappl, global_v_lang));
        obj_data.put('numreq',i.numreql);
        obj_data.put('desc_codpos',get_tpostn_name(i.codposl, global_v_lang));
        obj_data.put('date', to_char(i.dtefoll, 'dd/mm/yyyy'));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    if  v_row = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPLINF');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    else
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end if;

  end gen_index;

  procedure gen_drilldown(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;

    cursor c1 is
        select a.dteappoi, a.typappty, a.qtyfscore, a.qtyscoreavg, a.codasapl,
               b.dteappr, b.codappr
        from tappoinf a, tapphinv b
        where a.numappl = b.numappl
          and a.numreqrq = b.numreqrq
          and a.codposrq = b.codposrq
          and a.numappl = p_numappl
        order by a.dteappoi;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('dteappiont', to_char(i.dteappoi, 'dd/mm/yyyy'));
        obj_data.put('typtest', get_tlistval_name('TYPAPPTY', i.typappty, global_v_lang));
        obj_data.put('fullscore', i.qtyfscore);
        obj_data.put('score', i.qtyscoreavg);
        obj_data.put('result', get_tlistval_name('CODASAPL', i.codasapl, global_v_lang));
        obj_data.put('dteassess', to_char(i.dteappr, 'dd/mm/yyyy'));
        obj_data.put('assessby', get_temploy_name(i.codappr, global_v_lang));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_drilldown;

  procedure gen_drilldown_status(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;

    cursor c1 is
        select dtefoll, statappl, codrej, remark, dteupd,
               coduser
        from tappfoll
        where numappl = p_numappl
        order by dtefoll;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('date', to_char(i.dtefoll, 'dd/mm/yyyy'));
        obj_data.put('status', get_tlistval_name('STATAPPL', i.statappl, global_v_lang));
        obj_data.put('result', i.codrej);
        obj_data.put('detail', get_tcodec_name('TCODREJE', i.codrej, global_v_lang));
        obj_data.put('remark', i.remark);
        obj_data.put('updateby', i.coduser);
        obj_data.put('dteupdate', to_char(i.dteupd, 'dd/mm/yyyy'));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_drilldown_status;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    if check_index then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index;

  procedure get_drilldown(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_drilldown(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_drilldown;

  procedure get_drilldown_status(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_drilldown_status(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_drilldown_status;

END HRRC3CX;

/

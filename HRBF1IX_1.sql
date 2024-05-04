--------------------------------------------------------
--  DDL for Package Body HRBF1IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1IX" AS

  procedure initial_value(json_str_input in clob) as
   json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcompgrp      := hcm_util.get_string(json_obj,'p_codcompgrp');
        p_codcomp         := hcm_util.get_string(json_obj,'p_codcomp');
        p_levelcomp       := hcm_util.get_string(json_obj,'p_levelcomp');
        p_mthst           := to_number(hcm_util.get_string(json_obj,'p_mthst'));
        p_dteyearst       := to_number(hcm_util.get_string(json_obj,'p_dteyearst'));
        p_mthen           := to_number(hcm_util.get_string(json_obj,'p_mthen'));
        p_dteyearen       := to_number(hcm_util.get_string(json_obj,'p_dteyearen'));


  end initial_value;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
   if p_mthst is null or p_dteyearst is null or p_mthen is null or p_dteyearen is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
   end if;

   if p_codcompgrp is not null then
        begin
            select 'X' into v_temp
            from tcompgrp
            where codcodec = p_codcompgrp;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompgrp');
            return;
        end;
    end if;
--
--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
    end;

--  check secure7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

    if to_date(get_period_date(p_mthst,p_dteyearst,'S'),'dd/mm/yyyy') > to_date(get_period_date(p_mthen,p_dteyearen,'S'),'dd/mm/yyyy') then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_data        json;
    obj_rows        json;
    v_row           number := 0;
    v_chk_secur     boolean := false;
    cursor c1 is
        --<<User37 #3325 5. BF Module 09/04/2021  
        select  hcm_util.get_codcomp_level(b.codcomp,p_levelcomp) codcomp,typamt,sum(decode(a.codrel,'E',amtalw,0)) qtyamtemp,
                sum(decode(a.codrel,'E',0,amtalw)) qtyamtfml,sum(amtalw) amtalw
        from tclnsinf a, tcenter b
        where a.codcomp = b.codcomp
          and b.compgrp = nvl(p_codcompgrp,b.compgrp)
          and a.codcomp like p_codcomp||'%'
          and dtereq between to_date(get_period_date(p_mthst,p_dteyearst,'S'),'dd/mm/yyyy')
          and to_date(get_period_date(p_mthen,p_dteyearen,''),'dd/mm/yyyy')
        group by hcm_util.get_codcomp_level(b.codcomp,p_levelcomp),typamt
        order by hcm_util.get_codcomp_level(b.codcomp,p_levelcomp),typamt;

        /*select  substr(b.codcomp,1,(b.compgrp * (nvl(p_levelcomp,1)*4))) codcomp,typamt,sum(decode(a.codrel,'E',amtalw,0)) qtyamtemp,
                sum(decode(a.codrel,'E',0,amtalw)) qtyamtfml,sum(amtalw) amtalw
        from tclnsinf a, tcenter b
        where a.codcomp = b.codcomp
          and b.compgrp = nvl(p_codcompgrp,b.compgrp)
          and a.codcomp like nvl(p_codcomp||'%',a.codcomp)
          and dtereq between to_date(get_period_date(p_mthst,p_dteyearst,'S'),'dd/mm/yyyy')
          and to_date(get_period_date(p_mthen,p_dteyearen,''),'dd/mm/yyyy')
        group by substr(b.codcomp,1,(b.compgrp*(nvl(p_levelcomp,1)*4))),typamt
        order by substr(b.codcomp,1,(b.compgrp*(nvl(p_levelcomp,1)*4))),typamt;*/
        -->>User37 #3325 5. BF Module 09/04/2021   

  begin
    obj_rows := json();
    for i in c1 loop
--        if p_levelcomp is not null and p_codcompgrp is not null then
--            i.codcomp := substr(i.codcomp,1,p_codcompgrp * p_levelcomp);
--        end if;
        v_chk_secur := secur_main.secur7(i.codcomp,global_v_coduser);
        if v_chk_secur then
            v_row := v_row + 1;
            obj_data := json();
        --<< user25 Date: 25/08/2021 5. BF Module #6758
            obj_data.put('codcomp',hcm_util.get_codcomp_level(i.codcomp,null,'-','Y'));
            --obj_data.put('codcomp',i.codcomp);--User37 #3325 5. BF Module 09/04/2021 hcm_util.get_codcomp_level(i.codcomp,p_codcompgrp*(nvl(p_levelcomp,1)*4),'','Y'));
        -->> user25 Date: 25/08/2021 5. BF Module #6758
            obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('typamt',i.typamt);
            obj_data.put('typamt_name',get_tlistval_name('TYPAMT',i.typamt,global_v_lang));
            obj_data.put('qtyamtemp',i.qtyamtemp);
            obj_data.put('qtyamtfml',i.qtyamtfml);
            obj_data.put('amtalw',i.amtalw);
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    if obj_rows.count() = 0  then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tclnsinf');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index;

  procedure get_dropdown (json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_json_input    json_object_t;
    v_rcnt          number := 0;
    v_codcomp       tcenter.codcomp%type;

    cursor c_tsetcomp is
      select numseq
        from tsetcomp
        where nvl(qtycode,0) > 0
      order by numseq;
  begin
    initial_value(json_str_input);
    v_json_input    := json_object_t(json_str_input);
    v_codcomp       := hcm_util.get_string_t(v_json_input,'p_codcomp');
    obj_row := json_object_t();
    for r1 in c_tsetcomp loop
      v_rcnt      := v_rcnt+1;
      obj_data     := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('comlevel', r1.numseq);
      if r1.numseq = 1 then
        obj_data.put('namecomlevel', get_label_name('SCRLABEL',global_v_lang,2250));
      else
        obj_data.put('namecomlevel', get_comp_label(v_codcomp,r1.numseq,global_v_lang));
      end if;

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

END HRBF1IX;

/

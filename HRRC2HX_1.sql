--------------------------------------------------------
--  DDL for Package Body HRRC2HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC2HX" is
-- last update: 10/03/2021 19:50
 procedure initial_value (json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
    global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');

    p_codcomp           := (hcm_util.get_string(json_obj, 'p_codcomp'));
    p_dtestrt           := (hcm_util.get_string(json_obj, 'p_dtestrt'));
    p_dteend            := (hcm_util.get_string(json_obj, 'p_dteend'));
    p_codcomp_record    := (hcm_util.get_string(json_obj, 'p_codcomp_record'));
    p_codpos_record     := (hcm_util.get_string(json_obj, 'p_codpos_record'));
    p_numlvl_record     := (hcm_util.get_string(json_obj, 'p_numlvl_record'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  ----------------------------------------------------------------------------------
  procedure check_index is
    v_flgsecu2        boolean := false;
  begin
    if p_codcomp is not null then
      v_flgsecu2 := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_flgsecu2 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang, 'codcomp');
        return;
      end if;
    end if;
  end check_index;
  ----------------------------------------------------------------------------------
  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
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
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    v_flgsecur  varchar2(1 char) := 'N';
    v_secur     boolean;
    v_zupdsal   varchar2(20 char);

    cursor c1 is
      select t.codpos,t.numlvl, t.codcomp, count(*) as qtyemp
        from temploy1 t
       where t.codcomp  like p_codcomp||'%'
         and t.dteempmt between  to_date(p_dtestrt,'dd/mm/yyyy') and  to_date(p_dteend,'dd/mm/yyyy')
     group by t.codpos,t.numlvl,t.codcomp
     order by t.codpos,t.numlvl,t.codcomp;
  begin
    obj_row     := json();
    for r1 in c1 loop
      v_rcnt   := v_rcnt+1;
      v_secur  := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur then
        v_flgsecur  := 'Y';
        obj_data    := json();        
        obj_data.put('coderror', '200');        
        obj_data.put('codpos', r1.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
        obj_data.put('level', r1.numlvl);
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
        obj_data.put('qtyemp', r1.qtyemp);        
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    elsif v_flgsecur = 'N' then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_index;
----------------------------------------------------------------------------------
procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;
----------------------------------------------------------------------------------
  procedure gen_detail(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    v_permis    boolean := false;
    flgpass     boolean := true;

    cursor c1 is
            select  t.codempid, t.dteempmt, t.staemp, t.codcomp
            from temploy1 t
            where t.codcomp = p_codcomp_record
            and t.codpos = nvl(p_codpos_record ,t.codpos)
            and t.numlvl = p_numlvl_record
            and t.dteempmt between  to_date(p_dtestrt,'dd/mm/yyyy') and  to_date(p_dteend,'dd/mm/yyyy')
            order by t.codempid ;
  begin
    obj_row     := json();
    for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
           if flgpass then
              v_permis := true;
              v_rcnt      := v_rcnt+1;
              obj_data    := json();

              obj_data.put('coderror', '200');

              obj_data.put('codimage', get_emp_img (r1.codempid));
              obj_data.put('codempid', r1.codempid);
              obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
              obj_data.put('dteempmt', to_char(r1.dteempmt, 'dd/mm/yyyy'));
              obj_data.put('desc_staemp', get_tlistval_name('NAMSTATA', r1.staemp, global_v_lang));

              obj_row.put(to_char(v_rcnt-1),obj_data);
           end if;
    end loop;
    if v_rcnt = 0 then
       param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;
    if v_permis then
      -- 200 OK
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
      else
        -- error permisssion denied HR3007
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;

  end gen_detail;
----------------------------------------------------------------------------------

end HRRC2HX;

/

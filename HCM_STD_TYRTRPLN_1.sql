--------------------------------------------------------
--  DDL for Package Body HCM_STD_TYRTRPLN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_STD_TYRTRPLN" is
  procedure initial_value(json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    --global
    global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

    p_dteyear           := hcm_util.get_string(json_obj,'dteyear');
    p_codcompy          := hcm_util.get_string(json_obj,'codcompy');
    p_codcours          := hcm_util.get_string(json_obj,'codcours');
  end; -- end initial_value
  --
  procedure get_std_tyrtrpln_data(json_str_input in clob, json_str_output out clob) is
    obj_row     json;
    cursor c1 is
      select statement,qtynumcl,qtyptbdg,amtclbdg,amtpbdg,amttot,
             codhotel,codinsts,codtparg,plancond,dteyear,codcours
        from tyrtrpln
       where dteyear    = p_dteyear
         and codcompy	= p_codcompy
         and codcours   = p_codcours; --ค่า p_ ทั้งหมด ได้จากรายการที่เลือก
  begin
    initial_value(json_str_input);
    obj_row     := json();
    obj_row.put('coderror','200');
    for i in c1 loop
        obj_row.put('statement',get_logical_desc(i.statement));
        obj_row.put('qtynumcl',i.qtynumcl);
        obj_row.put('qtyptbdg',i.qtyptbdg);
        obj_row.put('amtclbdg',to_char(i.amtclbdg,'999,999,999,990.00'));
        obj_row.put('amtpbdg',to_char(i.amtpbdg,'999,999,999,990.00'));
        obj_row.put('amttot',to_char(i.amttot,'999,999,999,990.00'));
        obj_row.put('codhotel',i.codhotel||' - '||get_thotelif_name(i.codhotel,global_v_lang));
        obj_row.put('codinsts',i.codinsts||' - '||get_tinstitu_name(i.codinsts,global_v_lang));
        obj_row.put('codtparg',get_tlistval_name('CODTPARG',i.codtparg,global_v_lang));
        obj_row.put('plancond',get_tlistval_name('STACOURS',i.plancond,global_v_lang));
        obj_row.put('dteyear',i.dteyear);
        obj_row.put('codcours',i.codcours);
        obj_row.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end gen_last_id_data
  --
end;

/

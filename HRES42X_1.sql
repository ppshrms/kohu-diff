--------------------------------------------------------
--  DDL for Package Body HRES42X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES42X" is
-- last update: 26/07/2016 13:16

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
    p_dteyear           := hcm_util.get_string_t(json_obj,'p_dteyear');
  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_codcompy      tcompny.codcompy%type;
    v_codcate       tcourse.codcate%type;
    v_codhotel      tyrtrsch.codhotel%type;

	cursor c_tpotentp is
		select *
          from tpotentp 
         where dteyear = p_dteyear
           and codempid = global_v_codempid
      order by codcours;
  begin

    select hcm_util.get_codcomp_level(codcomp,1)
      into v_codcompy
      from temploy1
     where codempid = global_v_codempid;

    v_rcnt  := 0;
    obj_row := json_object_t();
    for r1 in c_tpotentp loop
        begin
            select codcate
              into v_codcate
              from tcourse
             where codcours = r1.codcours;
        exception when no_data_found then
            v_codcate := null;
        end;   

        begin
            select codhotel
              into v_codhotel
              from tyrtrsch
             where codcours = r1.codcours
               and dteyear = r1.dteyear
               and codcompy = r1.codcompy
               and numclseq = r1.numclseq;
        exception when no_data_found then
            v_codhotel := null;
        end;   

        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcours', r1.codcours);
        obj_data.put('desc_codcours', get_tcourse_name(r1.codcours, global_v_lang));
        obj_data.put('codcatexm',v_codcate);
        obj_data.put('desc_codcatexm',  get_tcodec_name('TCODCATE',v_codcate, global_v_lang));
        obj_data.put('numclseq', r1.numclseq);
        obj_data.put('codtparg', get_tlistval_name('CODTPARG', r1.codtparg ,global_v_lang));
        obj_data.put('dtetrst', hcm_util.get_date_buddhist_era(r1.dtetrst)||'-'|| hcm_util.get_date_buddhist_era(r1.dtetren) );
        obj_data.put('flgatend', get_tlistval_name('FLGATEND', r1.flgatend ,global_v_lang));
        obj_data.put('place', get_thotelif_name(v_codhotel,global_v_lang));
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    obj_detail   := json_object_t();
    obj_detail.put('coderror', '200');
    obj_detail.put('codempid', global_v_codempid);
    obj_detail.put('desc_codempid', get_temploy_name(global_v_codempid,global_v_lang));

    obj_main   := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('detail', obj_detail);
    obj_main.put('table', obj_row);

    if v_rcnt > 0 then
        json_str_output := obj_main.to_clob;
    else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TPOTENTP');
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  end;
  --
end;

/

--------------------------------------------------------
--  DDL for Package Body HRES47X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES47X" is
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

    p_dtecreatest         := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtecreatest')),'dd/mm/yyyy');
    p_dtecreateen         := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtecreateen')),'dd/mm/yyyy');
    p_codcours       := hcm_util.get_string_t(json_obj,'p_codcours');


  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_path_filename  varchar2(1000 char);

  cursor c1 is
		select itemno,dteyear,codcompy,codcours,numclseq,codempid,
           codtparg,codknowl,subject,details,attfile,url,itemtype,dtecreate
          from tknowleg 
         where nvl(codcours,'!@#') = nvl(p_codcours,nvl(codcours,'!@#'))
           And  trunc(dtecreate) between  p_dtecreatest and p_dtecreateen
      order by codcours ,itemno ;
  begin

    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c1 loop

        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcours', r1.codcours);
        obj_data.put('desc_codcours', get_tcourse_name(r1.codcours,global_v_lang));
        obj_data.put('itemno', v_rcnt);
        obj_data.put('subject', r1.subject);
        obj_data.put('details', r1.details);
        obj_data.put('attfile', r1.attfile);
        v_path_filename := '';
        if r1.attfile is not null then
          v_path_filename := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRTR63E')||'/'||r1.attfile;
        end if;

        obj_data.put('path_filename', v_path_filename);
        obj_data.put('url', r1.url);
        obj_data.put('path_link', r1.url);
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtecreate', to_char(r1.dtecreate,'dd/mm/yyyy'));
        obj_row.put(to_char(v_rcnt-1), obj_data);

    end loop;


    json_str_output := obj_row.to_clob;
  end;
  --
end;

/

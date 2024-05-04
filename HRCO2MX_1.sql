--------------------------------------------------------
--  DDL for Package Body HRCO2MX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2MX" as

  procedure initial_value(json_str_input in clob) is
    json_obj json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
  
    p_routeno         := upper(hcm_util.get_string_t(json_obj,'routeno'));
  end initial_value;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_result  json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    v_seqno     twkflph.seqno%type;
    cursor c_twkflph is
      -- select a.codapp,a.routeno,a.seqno as seqno,a.syncond,to_char(a.statement) as statement,'' as codempid,'' as codcomp,'' as codpos,'1' tpyrep
      select a.codapp,a.routeno,a.seqno as seqno,a.syncond, get_logical_desc(a.statement) as statement,'' as codempid,'' as codcomp,'' as codpos,'1' tpyrep
        from twkflph a
      union
      select b.codapp,b.routeno,0,'' as seqno,null as statement, b.codempid as codempid,b.codcomp as codcomp,b.codpos as codpos,decode(b.codempid,'%','3','2') tpyrep
        from temproute b
       order by codapp, routeno, tpyrep;

  begin
    initial_value(json_str_input);
    obj_result := json_object_t();
    for r1 in c_twkflph loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('codapp',r1.codapp);
      obj_data.put('namapp',get_tappprof_name(r1.codapp,1,global_v_lang));

      if r1.tpyrep = '1' then
        v_seqno := r1.seqno;
        obj_data.put('tpyrep',get_label_name('HRCO2MX1',global_v_lang,70));
        --> Peerasak || 23022023 || IPO#785@449
        -- obj_data.put('syncond',get_logical_desc(r1.statement));
        obj_data.put('syncond',r1.statement);
        --> Peerasak || 23022023 || IPO#785@449
      elsif r1.tpyrep = '2' then
        obj_data.put('tpyrep',get_label_name('HRCO2MX1',global_v_lang,80));
        obj_data.put('syncond',r1.codempid ||' - '||get_temploy_name(r1.codempid, global_v_lang));
      elsif r1.tpyrep = '3' then
        obj_data.put('tpyrep',get_label_name('HRCO2MX1',global_v_lang,90));
        obj_data.put('syncond',r1.codcomp ||'-'||get_tcenter_name(r1.codcomp, global_v_lang)|| ' ' ||r1.codpos ||'-'||get_tpostn_name(r1.codpos, global_v_lang));
      end if;
      obj_data.put('seqno', v_seqno);
      obj_data.put('routeno',r1.routeno);
      obj_data.put('desc_routeno',r1.routeno || ' - ' || get_twkflowh_name(r1.routeno, global_v_lang));
      obj_result.put(to_char(v_row - 1),obj_data);
    end loop;
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
  
  procedure get_route_detail(json_str_input in clob, json_str_output out clob) as
    obj_result  json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    cursor c_twkflowd is
        select routeno,numseq,codcompa,codposa,codempa,typeapp
        from twkflowd
        where routeno = p_routeno
        order by routeno,numseq;
  begin
    initial_value(json_str_input);
    obj_result := json_object_t();
  
    for r1 in c_twkflowd loop
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('namroute',r1.routeno||' - '||get_twkflowh_name(r1.routeno,global_v_lang));
        obj_data.put('typeapp',get_tlistval_name('TYPEAPP',r1.typeapp,global_v_lang));
        obj_data.put('codposa',r1.codposa); --รหัสตำแหน่ง
        obj_data.put('namposa', get_tpostn_name(r1.codposa,global_v_lang));
        obj_data.put('namcompa', get_tcenter_name(r1.codcompa,global_v_lang));
        obj_data.put('codempid', r1.codempa);
        obj_data.put('image', get_emp_img(r1.codempa));
        obj_data.put('namempa', get_temploy_name(r1.codempa,global_v_lang));
        obj_result.put(to_char(v_row - 1),obj_data);
    end loop;
  
     -- กรณีไม่พบข้อมูล
    if obj_result.get_size() = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'twkflowd');
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_route_detail;

end hrco2mx;

/

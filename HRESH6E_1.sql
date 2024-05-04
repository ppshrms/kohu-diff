--------------------------------------------------------
--  DDL for Package Body HRESH6E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRESH6E" is
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

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dteyreap          := hcm_util.get_string_t(json_obj,'p_dteyreap');
    p_numtime           := hcm_util.get_string_t(json_obj,'p_numtime');
    param_json          := hcm_util.get_json_t(json_obj,'param_json');
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
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;

    v_qtytrhur      tcourse.qtytrhur%type;
    v_coddevp       tcourse.coddevp%type;
    v_objective     tobjemp.objective%type;
	cursor c_tkpiemp is
		select *
          from tkpiemp 
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codempid = global_v_codempid
      order by decode(typkpi,'D',1,'J',2,'I',3,9),codkpi;
  begin

    select codpos, codcomp
      into v_codpos, v_codcomp
      from temploy1
     where codempid = global_v_codempid;

    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c_tkpiemp loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('typkpi', r1.typkpi);
        obj_data.put('desc_typkpi', get_tlistval_name('TYPKPI',r1.typkpi,global_v_lang));
        obj_data.put('codkpino', r1.codkpi);
        obj_data.put('kpides', r1.kpides);
        obj_data.put('target', r1.target);
        obj_data.put('mtrfinish', r1.mtrfinish);
        obj_data.put('pctwgt', r1.pctwgt);
        obj_data.put('targtstr', to_char(r1.targtstr,'dd/mm/yyyy'));
        obj_data.put('targtend', to_char(r1.targtend,'dd/mm/yyyy'));
        obj_data.put('seqno', to_char(v_rcnt-1)); 
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    begin
        select objective
          into v_objective
          from tobjemp
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codempid = global_v_codempid;
    exception when no_data_found then
        v_objective := null;
    end;
    obj_detail   := json_object_t();
    obj_detail.put('coderror', '200');
    obj_detail.put('codempid', global_v_codempid);
    obj_detail.put('desc_codempid', get_temploy_name(global_v_codempid,global_v_lang));
    obj_detail.put('codcomp', v_codcomp);
    obj_detail.put('desc_codcomp', get_tcenter_name(v_codcomp,global_v_lang));
    obj_detail.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
    obj_detail.put('objective', v_objective);

    obj_main   := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('headData', obj_detail);
    obj_main.put('table', obj_row);

    json_str_output := obj_main.to_clob;
  end;
  --
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    param_json_row  json_object_t;
    obj_child_row   json_object_t;
    obj_child       json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_rcnt_child    number := 0;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;

    v_qtytrhur      tcourse.qtytrhur%type;
    v_coddevp       tcourse.coddevp%type;
    v_objective     tobjemp.objective%type;

    v_codkpi        tkpiemp.codkpi%type;

	cursor c_tkpiemppl is
		select *
          from tkpiemppl 
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codempid = p_codempid_query
           and codkpi = v_codkpi
      order by planno;
  begin

    v_rcnt  := 0;
    obj_row := json_object_t();
    if param_json.get_size > 0 then
        for i in 0..param_json.get_size-1 loop
            v_rcnt              := v_rcnt +1;
            obj_data            := hcm_util.get_json_t(param_json,to_char(i));
            v_codkpi            := hcm_util.get_string_t(obj_data,'codkpino');
            obj_data.put('coderror', '200');
            obj_child_row   := json_object_t();
            v_rcnt_child    := 0;
            for r1 in c_tkpiemppl loop
                v_rcnt_child := v_rcnt_child + 1 ;
                obj_child := json_object_t();
                obj_child.put('coderror', '200');
                obj_child.put('planno', r1.planno);
                obj_child.put('plandes', r1.plandes);
                obj_child.put('workdesc', r1.workdesc);
                obj_child.put('dtewstr', to_char(r1.dtewstr,'dd/mm/yyyy'));
                obj_child.put('dtewend', to_char(r1.dtewend,'dd/mm/yyyy'));
                obj_child.put('targtstr', to_char(r1.targtstr,'dd/mm/yyyy'));
                obj_child.put('targtend', to_char(r1.targtend,'dd/mm/yyyy')); 
                obj_child_row.put(to_char(v_rcnt_child-1), obj_child);
            end loop;
            obj_data.put('tkpiemppl', obj_child_row);

            obj_row.put(to_char(v_rcnt-1), obj_data);
        end loop;
    end if;    

    json_str_output := obj_row.to_clob;
  end;  

--
  procedure save_detail(json_str_input in clob,json_str_output out clob) as
    param_json_row          json_object_t;
    param_json_child        json_object_t;
    param_json_row_child    json_object_t;
    v_flg                   varchar2(100 char);
    v_codexam               ttestemp.codexam%type;

    v_codkpi                tkpiemppl.codkpi%type;
    v_planno                tkpiemppl.planno%type;
    v_dtewstr               tkpiemppl.dtewstr%type;
    v_dtewend               tkpiemppl.dtewend%type;
    v_workdesc              tkpiemppl.workdesc%type;
  begin
    if param_json.get_size > 0 then
      for i in 0..param_json.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_codkpi            := hcm_util.get_string_t(param_json_row,'codkpino');
        param_json_child    := hcm_util.get_json_t(hcm_util.get_json_t(param_json_row,'tkpiemppl'),'rows');

        if param_json_child.get_size > 0 then
            for j in 0..param_json_child.get_size-1 loop
                param_json_row_child    := hcm_util.get_json_t(param_json_child,to_char(j));
                v_planno                := hcm_util.get_string_t(param_json_row_child,'planno');
                v_dtewstr               := to_date(hcm_util.get_string_t(param_json_row_child,'dtewstr'),'dd/mm/yyyy');
                v_dtewend               := to_date(hcm_util.get_string_t(param_json_row_child,'dtewend'),'dd/mm/yyyy');
                v_workdesc              := hcm_util.get_string_t(param_json_row_child,'workdesc');

                if v_dtewstr is not null and v_dtewend is not null and v_workdesc is not null then
                    update tkpiemppl
                       set dtewstr = v_dtewstr,
                           dtewend = v_dtewend,
                           workdesc = v_workdesc
                     where dteyreap = p_dteyreap
                       and numtime = p_numtime
                       and codempid = p_codempid_query
                       and codkpi = v_codkpi;
                end if;
            end loop;
        end if;    
      end loop;
    end if;

    commit;
--    insert into s values('HRESH6E'||get_error_msg_php('HR2401',global_v_lang));
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end save_detail;
  --
  procedure post_save_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_detail(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;  


end;

/

--------------------------------------------------------
--  DDL for Package Body HRES79E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES79E" is
-- last update: 22/02/2022 14:00

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
    b_index_dtereq_st   := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_st'),'dd/mm/yyyy');
    b_index_dtereq_en   := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_en'),'dd/mm/yyyy');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    p_dtetest           := to_date(hcm_util.get_string_t(json_obj,'p_dtetest'),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_typetest          := hcm_util.get_string_t(json_obj,'p_typetest');
    p_result            := hcm_util.get_string_t(json_obj,'p_result');
    p_remark            := hcm_util.get_string_t(json_obj,'p_remark');
    p_filename          := hcm_util.get_string_t(json_obj,'p_filename');    
    p_param_json        := hcm_util.get_json_t(json_obj,'json_input_str');
  end initial_value;

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
    v_rcnt          number := 0; 
    v_result        varchar2(1000 char);
	cursor c1 is
		select codempid,dtereq,numseq,dtetest,typetest,result,remark,filename             
          from tatkpcr 
         where codempid = global_v_codempid
           and dtetest between b_index_dtereq_st and b_index_dtereq_en           
      order by dtereq,numseq desc;
      
  begin
    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c1 loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', r1.numseq);
        obj_data.put('codempid', r1.codempid);
        obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('dtetest', to_char(r1.dtetest,'dd/mm/yyyy'));
        obj_data.put('typetest', get_tlistval_name('TYPETEST',r1.typetest,global_v_lang));
        if r1.result = 'Y' then
            v_result := get_label_name('HRES79EC2',global_v_lang,'90');
        else
            v_result := get_label_name('HRES79EC2',global_v_lang,'80');
        end if;
        obj_data.put('result', v_result);
        obj_data.put('remark', r1.remark);
        obj_data.put('filename', r1.filename);        
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end;
  
  
  procedure get_detail_create(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_create(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_detail_create (json_str_output out clob) is
    obj_detail      json_object_t;
    v_numseq        number := 0;
    max_numseq      number;
  begin
    obj_detail      := json_object_t();

    begin
        select max(numseq)
          into max_numseq
          from tatkpcr
         where codempid = global_v_codempid
           and to_char(dtereq,'dd/mm/yyyy') = to_char(sysdate,'dd/mm/yyyy');
    exception when others then 
        max_numseq := 0;
    end;
    max_numseq := nvl(max_numseq,0) + 1;
    
    obj_detail.put('coderror', '200');
    obj_detail.put('codempid', global_v_codempid);
    obj_detail.put('dtereq', to_char(sysdate,'dd/mm/yyyy'));
    obj_detail.put('numseq', max_numseq);
    obj_detail.put('dtetest', to_char(sysdate,'dd/mm/yyyy'));
    obj_detail.put('result', '');
    obj_detail.put('remark', '');
    obj_detail.put('filename', '');
    
    json_str_output := obj_detail.to_clob;
  end;

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
    obj_detail      json_object_t;

    cursor c1 is
        select codempid,dtereq,dtetest,numseq,typetest,result,remark,filename
          from tatkpcr
         where codempid = global_v_codempid
           and dtereq = p_dtereq     
           and numseq = p_numseq;
    
  begin
    obj_detail  := json_object_t();
    for r1 in c1 loop  
        obj_detail.put('coderror', '200');
        obj_detail.put('numseq', r1.numseq);
        obj_detail.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_detail.put('codempid', r1.codempid);
        obj_detail.put('dtetest', to_char(r1.dtetest,'dd/mm/yyyy'));
        obj_detail.put('typetest', r1.typetest);
        obj_detail.put('result', r1.result);
        obj_detail.put('remark', r1.remark);
        obj_detail.put('filename', r1.filename);  
    end loop;

    json_str_output := obj_detail.to_clob;
    
  end;
  
  procedure post_save(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    
    if param_msg_error is null then
      save_tatkpcr(json_str_input ,json_str_output);
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
 
  procedure save_tatkpcr(json_str_input in clob,json_str_output out clob) as
  begin
    begin
        insert into tatkpcr (codempid,dtereq,numseq,dtetest,typetest,result,remark,filename,codcreate,coduser)
        values ( global_v_codempid,p_dtereq,p_numseq,p_dtetest,p_typetest,p_result,p_remark,p_filename,
                 global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
        update tatkpcr
           set dtetest  = p_dtetest,
               typetest = p_typetest,
               result   = p_result,
               remark   = p_remark,
               filename = p_filename,    
               coduser  = global_v_coduser
         where codempid = global_v_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end save_tatkpcr;

  procedure post_delete(json_str_input in clob, json_str_output out clob) as
    param_json_row  json_object_t;    
    v_numseq        number;
    v_dtereq        date;
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            for i in 0..p_param_json.get_size-1 loop
                param_json_row  := hcm_util.get_json_t(p_param_json, to_char(i));
                v_dtereq        := to_date(hcm_util.get_string_t(param_json_row,'dtereq'),'dd/mm/yyyy');
                v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
                if param_msg_error is null then                    
                    begin
                        delete from tatkpcr
                         where codempid = global_v_codempid
                           and dtereq  = v_dtereq
                           and numseq  = v_numseq;                        
                    exception when others then
                        null;
                    end;
                end if;
            end loop;
        end if;

        if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2425',global_v_lang);
            commit;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end post_delete;
end;

/

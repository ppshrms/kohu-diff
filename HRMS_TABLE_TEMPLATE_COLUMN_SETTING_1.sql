--------------------------------------------------------
--  DDL for Package Body HRMS_TABLE_TEMPLATE_COLUMN_SETTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS_TABLE_TEMPLATE_COLUMN_SETTING" AS
    procedure initial_value(json_str in clob) is
        json_obj        json_object_t;
    begin
        json_obj            := json_object_t(json_str);

        -- global
        v_chken             := hcm_secur.get_v_chken;
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

        -- surachai 28/11/2023
        p_codapp            := hcm_util.get_string_t(json_obj, 'p_codapp');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        begin
            select codempid
            into global_v_codempid
            from tusrprof
            where coduser = global_v_coduser;
        exception when no_data_found then
            global_v_coduser := null;
        end;
    end;


    -- << surachai 28/11/2023(4448 #9698)
   procedure get_column_sort(json_str_input in clob, json_str_output out clob) as
    json_obj      json_object_t;
    v_row         number := 0;
    obj_row       json_object_t;
    obj_data      json_object_t;

    cursor c_colsort is
      select numseq, namfield, flguse
        from tusrscrn 
       where codapp  = p_codapp
         and coduser = global_v_coduser
	order by numseq ;       

  begin
    initial_value(json_str_input);

    -- default value --
    obj_row   := json_object_t();
    v_row     := 0;
    -- get data    
    for r in c_colsort loop
      v_row := v_row+1;       
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numseq',r.numseq);
      obj_data.put('namfield',r.namfield);
      obj_data.put('flguse',r.flguse);      

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;    

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_column_sort(json_str_input in clob, json_str_output out clob) as
    json_obj              json_object_t;
    json_obj2             json_object_t;
    v_rowcount            number:= 0;
    v_codapp              varchar2(20 char);
    v_numseq              number;
    v_namfield            varchar2(50 char);
    v_flguse			  varchar2(1 char);

  begin
    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input).get_object('param_json');
    v_rowcount := json_obj.get_size;

    delete from tusrscrn 
          where codapp  = p_codapp
            and coduser = global_v_coduser;

    for i in 0..json_obj.get_size-1 loop
      json_obj2   := json_object_t(json_obj.get(to_char(i)));
      -- v_codapp   := hcm_util.get_string_t(json_obj2, 'codapp');	  
      v_numseq    := to_number(hcm_util.get_string_t(json_obj2, 'numseq'));
      v_namfield  := hcm_util.get_string_t(json_obj2, 'namfield');	 
      v_flguse 		:= hcm_util.get_string_t(json_obj2, 'flguse');	 

      insert into tusrscrn(codapp, coduser, numseq, namfield, flguse, dtecreate, codcreate, dteupd)
           values(p_codapp, global_v_coduser, v_numseq, v_namfield, v_flguse, trunc(sysdate), global_v_coduser, trunc(sysdate));
    end loop;
    commit;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end ;
  -- >> surachai 28/11/2023(4448 #9698)

  procedure reset_column_sort(json_str_input in clob, json_str_output out clob) as
    json_obj              json_object_t;
    json_obj2             json_object_t;
    v_rowcount            number:= 0;
    v_codapp              varchar2(20 char);

  begin
    initial_value(json_str_input);

    delete from tusrscrn 
          where codapp  = p_codapp
            and coduser = global_v_coduser;
    commit;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end ;

END HRMS_TABLE_TEMPLATE_COLUMN_SETTING;

/

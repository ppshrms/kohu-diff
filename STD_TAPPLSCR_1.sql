--------------------------------------------------------
--  DDL for Package Body STD_TAPPLSCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_TAPPLSCR" as
   procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codapp            := upper(hcm_util.get_string_t(json_obj,'p_codapp'));
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  procedure gen_tapplscr_info(json_str_output out clob)as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number;
    cursor c1 is
      select codapp,numseq,desclabele,desclabelt,desclabel3,desclabel4,desclabel5 
        from tapplscr 
       where codapp like p_codapp||'%';
  begin
    obj_row := json_object_t();
    v_rcnt := 0;
    for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codapp',r1.codapp);
      obj_data.put('numseq',r1.numseq);
      obj_data.put('desclabel1',r1.desclabele);
      obj_data.put('desclabel2',r1.desclabelt);
      obj_data.put('desclabel3',r1.desclabel3);
      obj_data.put('desclabel4',r1.desclabel4);
      obj_data.put('desclabel5',r1.desclabel5);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt := v_rcnt + 1;
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tapplscr_info;

  procedure get_tapplscr_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_tapplscr_info(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_header_info(json_str_output out clob)as
    obj_data    json_object_t;
    obj_row     json_object_t;
    data_row    json_object_t;
    v_rcnt      number;
    v_desclabel tcodlang.descode%type;

    cursor c_tlanguage is
      select codlang2
        from tlanguage
       where codlang2 is not null
    order by codlang;
  begin
    obj_row   := json_object_t();
    data_row  := json_object_t();
    v_rcnt := 0;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('desc_codapp', p_codapp||' - ' ||get_tprocapp_name(p_codapp,global_v_lang));
   -- obj_data.put('desc_codapp', p_codapp||' - ' ||get_tappprof_name(p_codapp,1,global_v_lang));

    for r1 in c_tlanguage loop
      begin
        select decode(global_v_lang, '101', descode,
                                     '102', descodt,
                                     '103', descod3,
                                     '104', descod4,
                                     '105', descod5) desclabel
          into v_desclabel
          from tcodlang
          where codcodec = r1.codlang2;
      exception when no_data_found then
        v_desclabel := '';
      end;
      data_row.put('desclabel'||(v_rcnt+1),v_desclabel);
      v_rcnt := v_rcnt + 1;
    end loop;
    obj_data.put('language',data_row);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_header_info;

  procedure get_header_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_header_info(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tapplscr(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;

    v_codapp        tapplscr.codapp%type;            
    v_numseq        tapplscr.numseq%type;            
    v_desclabele    tapplscr.desclabele%type;            
    v_desclabelt    tapplscr.desclabelt%type;            
    v_desclabel3    tapplscr.desclabel3%type;            
    v_desclabel4    tapplscr.desclabel4%type;            
    v_desclabel5    tapplscr.desclabel5%type;            
    v_flg           varchar2(10 char);           
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then

      for i in 0..param_json.get_size-1 loop
        param_json_row  := json_object_t(param_json.get(to_char(i)));

        v_codapp      := hcm_util.get_string_t(param_json_row,'codapp');
        v_numseq      := hcm_util.get_string_t(param_json_row,'numseq');
        v_desclabele  := hcm_util.get_string_t(param_json_row,'desclabel1');
        v_desclabelt  := hcm_util.get_string_t(param_json_row,'desclabel2');
        v_desclabel3  := hcm_util.get_string_t(param_json_row,'desclabel3');
        v_desclabel4  := hcm_util.get_string_t(param_json_row,'desclabel4');
        v_desclabel5  := hcm_util.get_string_t(param_json_row,'desclabel5');
        v_flg         := hcm_util.get_string_t(param_json_row,'flg');

        if(v_flg = 'edit') then
          begin
           update tapplscr
              set desclabele = v_desclabele,
                  desclabelt = v_desclabelt,
                  desclabel3 = v_desclabel3,
                  desclabel4 = v_desclabel4,
                  desclabel5 = v_desclabel5,
                  dteupd     = sysdate,
                  coduser    = global_v_coduser,
                  typscr     = 'Y'
              where numseq = v_numseq
              and codapp = v_codapp;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            rollback;
          end;
        end if;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        json_str_output := param_msg_error;
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end std_tapplscr;

/

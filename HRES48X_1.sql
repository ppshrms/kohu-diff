--------------------------------------------------------
--  DDL for Package Body HRES48X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES48X" is
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
    v_score         tcmptncy.grade%type;
    v_gapcom        number;
    v_idx           number := 0;
	cursor c_tjobposskil is
		select *
          from tjobposskil 
         where codpos = v_codpos
           and codcomp = v_codcomp
      order by codtency,codskill;
  begin
     begin
        delete ttemprpt
         where codapp = 'HRES48X'
           and codempid = global_v_codempid;
    end; 
    select codpos, codcomp
      into v_codpos, v_codcomp
      from temploy1
     where codempid = global_v_codempid;

    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c_tjobposskil loop
        begin
            select grade 
              into v_score
              from tcmptncy
             where codempid = global_v_codempid
               and codtency = r1.codskill;
        exception when no_data_found then
            v_score := 0;
        end;
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codtency', get_tcomptnc_name(  r1.codtency, global_v_lang ));
        obj_data.put('codskill', r1.codskill);
        obj_data.put('desc_codskill', get_tcodec_name('TCODSKIL',r1.codskill,global_v_lang));
        obj_data.put('grade', r1.grade);
        obj_data.put('score', v_score);
        obj_data.put('gapcom', -greatest(0,r1.grade - v_score));
        obj_row.put(to_char(v_rcnt-1), obj_data);

      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq, item2, item4,item5, item8,item9, item10, item12, item31)
      values (global_v_codempid, 'HRES48X',v_idx,
              get_tcomptnc_name(r1.codtency, global_v_lang),
              r1.codskill, get_tcodec_name ('TCODSKIL', r1.codskill,global_v_lang),
              get_label_name('HRES48X',global_v_lang,70),get_label_name('HRES48X',global_v_lang,110),
              nvl(r1.grade,0),
              r1.codtency,
              get_label_name('HRES48X',global_v_lang,100));             

      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq, item2, item4,item5, item8,item9, item10, item12 ,item31)
      values (global_v_codempid, 'HRES48X',v_idx,
              get_tcomptnc_name(r1.codtency, global_v_lang),
              r1.codskill, get_tcodec_name ('TCODSKIL', r1.codskill,global_v_lang),
              get_label_name('HRES48X',global_v_lang,80),get_label_name('HRES48X',global_v_lang,110),
              v_score,
              r1.codtency,
              get_label_name('HRES48X',global_v_lang,100));            

    end loop;

    obj_detail   := json_object_t();
    obj_detail.put('coderror', '200');
    obj_detail.put('codempid', global_v_codempid);
    obj_detail.put('desc_codempid', get_temploy_name(global_v_codempid,global_v_lang));
    obj_detail.put('des_codcomp', get_tcenter_name(v_codcomp,global_v_lang));
    obj_detail.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));

    obj_main   := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('detail', obj_detail);
    obj_main.put('table', obj_row);

    json_str_output := obj_main.to_clob;
  end;
  --
end;

/

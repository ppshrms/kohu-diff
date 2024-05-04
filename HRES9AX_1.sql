--------------------------------------------------------
--  DDL for Package Body HRES9AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES9AX" is
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
    v_codcomp2      temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_score         tcmptncy.grade%type;
    v_gapcom        number;
    v_idx           number := 0;
    v_year          number;
    v_month         number;
    v_day           number;
    v_agemth        number;
    v_dteefpos      temploy1.dteefpos%type;

    v_qtytrhur      tcourse.qtytrhur%type;
    v_coddevp       tcourse.coddevp%type;
    v_hr            varchar(10 char);--User37 #4679 4.ES.MS Module 09/04/2021 
	cursor c_codcomp is
		select distinct codcomp
          from tbasictp
         where v_codcomp like codcomp||'%'
           and codpos = v_codpos
           --<<User37 #4677 8. ES.MS Module (P2) 18/02/2021
           --and typemp = 'M'
           and qtyposst >= v_agemth
           and codcours not in (select codcours
                                  from thistrnn
                                 where codempid = global_v_codempid)
           -->>User37 #4677 8. ES.MS Module (P2) 18/02/2021
      order by codcomp;

	cursor c_tbasictp is
		select codcate,codcours,qtyposst--User37 #4677 4.ES.MS Module 08/04/2021 *
          from tbasictp
         where codcomp = v_codcomp2
           and codpos = v_codpos
           --<<User37 #4677 8. ES.MS Module (P2) 18/02/2021
           --and typemp = 'M'
           and qtyposst >= v_agemth
           and codcours not in (select codcours
                                  from thistrnn
                                 where codempid = global_v_codempid)
           -->>User37 #4677 8. ES.MS Module (P2) 18/02/2021
      group by codcate,codcours,qtyposst--User37 #4677 4.ES.MS Module 08/04/2021 
      order by codcate,codcours;
  begin

    select codpos, codcomp, dteefpos
      into v_codpos, v_codcomp, v_dteefpos
      from temploy1
     where codempid = global_v_codempid;

    --<<User37 #4677 8. ES.MS Module (P2) 18/02/2021
    get_service_year( v_dteefpos,TRUNC(sysdate),'Y',v_year,v_month,v_day);
	v_agemth  := (v_year * 12) + v_month;
    -->>User37 #4677 8. ES.MS Module (P2) 18/02/2021

    for r1 in c_codcomp loop
        v_codcomp2 := r1.codcomp;
        exit;
    end loop;

    v_rcnt := 0;
    obj_row := json_object_t();

    for r1 in c_tbasictp loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcatexm', r1.codcate);
        obj_data.put('desc_codcatexm', get_tcodec_name('TCODCATE',r1.codcate, global_v_lang));
        obj_data.put('codcours', r1.codcours);
        obj_data.put('desc_codcours', get_tcourse_name(r1.codcours, global_v_lang));
        begin
            select qtytrhur, coddevp
              into v_qtytrhur, v_coddevp
              from tcourse
             where codcours = r1.codcours;
        exception when others  then
            v_qtytrhur  := null;
            v_coddevp   := null;
        end ;
        --<<User37 #4679 4.ES.MS Module 09/04/2021  
        --obj_data.put('qtytrhur', hcm_util.convert_minute_to_hour(v_qtytrhur*60));
        v_hr := replace(v_qtytrhur, '.', ':');
        if instr(v_hr, ':') = 0 then
            obj_data.put('qtytrhur',rpad(v_hr||':',length(v_hr||':')+2,'0'));
        else
            if length(substr(v_hr, instr(v_hr, ':') + 1)) = 2 then
                obj_data.put('qtytrhur',v_hr);
            else
                obj_data.put('qtytrhur',rpad(v_hr,length(v_hr)+1,'0'));
            end if;
        end if;
        -->>User37 #4679 4.ES.MS Module 09/04/2021  
        obj_data.put('mettrain', get_tlistval_name('METTRAIN',v_coddevp, global_v_lang));
        obj_data.put('qtyposst', r1.qtyposst);
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    obj_detail   := json_object_t();
    obj_detail.put('coderror', '200');
    obj_detail.put('codempid', global_v_codempid);
    obj_detail.put('desc_codempid', get_temploy_name(global_v_codempid,global_v_lang));
    obj_detail.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
    obj_detail.put('dteefpos', v_agemth);

    obj_main   := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('detail', obj_detail);
    obj_main.put('table', obj_row);

    json_str_output := obj_main.to_clob;
  end;
  --
end;

/

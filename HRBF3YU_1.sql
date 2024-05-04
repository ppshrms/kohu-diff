--------------------------------------------------------
--  DDL for Package Body HRBF3YU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF3YU" is
-- last update: 31/08/2020 18:16

  procedure initial_value(json_str in clob) is
    json_obj                json_object_t;
  begin
    v_chken                 := hcm_secur.get_v_chken;
    json_obj                := json_object_t(json_str);
    --global
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');

    --block b_index--
    p_codcomp               := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_numisr                := hcm_util.get_string_t(json_obj,'p_numisr');
    p_month                 := to_number(hcm_util.get_string_t(json_obj,'p_month'));
    p_year                  := to_number(hcm_util.get_string_t(json_obj,'p_year'));

--    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen); -- surachai bk 08/12/2022 | #8711

  end initial_value;
  --
  procedure get_process(json_str_input in clob, json_str_output out clob) as
    o_numrec1		    number;
    o_numrec2           number;
    o_numrec3           number;
    obj_data        json_object_t;
    v_numisr        tisrinf.numisr%type;
    v_codcom        tcenter.codcomp%type;
  begin
    initial_value(json_str_input);
    -- surachai add 08/12/2022 | #8711
    -- ต้องมีข้อมูลอยู่ในตาราง TCENTER 
    begin
        select codcomp
        into v_codcom
        from tcenter
        where codcomp = hcm_util.get_codcomp_level(p_codcomp,null,null,'Y');
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
    end;
    if param_msg_error is null then
        -- ตรวจสอบสิทธิการเรียกดูข้อมูล 
        if secur_main.secur7(p_codcomp,global_v_coduser) = false then 
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;
        if param_msg_error is null then
            --	ต้องมีข้อมูลอยู่ในตาราง TISRINF
            begin 
                select numisr 
                into v_numisr
                from tisrinf 
                where numisr = p_numisr;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TISRINF');
            end;
            --	ต้องเป็นหน่วยงานที่มีสิทธิใช้กรมธรรม์ตามที่ระบุได้
            if param_msg_error is null then
                begin 
                    select numisr 
                    into v_numisr
                    from tisrinf 
                    where numisr = p_numisr
                        and codcompy = p_codcomp;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TISRINF');    
                end;
            end if;
        end if;
    end if;
    
    if param_msg_error is null then    
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
        hrbf3yu_batch.start_process(p_codcomp,
                                      p_numisr ,
                                      p_month,
                                      p_year,
                                      global_v_coduser,
                                      global_v_lang,
                                      o_numrec1,
                                      o_numrec2	,
                                      o_numrec3);

        obj_data.put('codcomp', p_codcomp);
        obj_data.put('numisr', p_numisr);
        obj_data.put('month', p_month);
        obj_data.put('year', p_year);
        obj_data.put('peoplein', to_char(nvl(o_numrec1,0),''));
        obj_data.put('peopleout', to_char(nvl(o_numrec2,0),''));
        obj_data.put('peoplemove', to_char(nvl(o_numrec3,0),''));
--        obj_data.put('peoplein', to_char(nvl(o_numrec1,0), 'fm999,999,990.00'));
--        obj_data.put('peopleout', to_char(nvl(o_numrec2,0), 'fm999,999,990.00'));
--        obj_data.put('peoplemove', to_char(nvl(o_numrec3,0), 'fm999,999,990.00'));
        json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('error',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
end;

/

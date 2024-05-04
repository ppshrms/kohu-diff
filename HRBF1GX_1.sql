--------------------------------------------------------
--  DDL for Package Body HRBF1GX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1GX" AS

  procedure initial_value(json_str_input in clob) AS
  json_obj    json;
        begin
            json_obj            := json(json_str_input);

            --global
            global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
            global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
            global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');

            -- index params
            p_codempid          := hcm_util.get_string(json_obj, 'p_codempid');
            p_monreqst          := hcm_util.get_string(json_obj, 'p_month1');
            p_yeareqst          := hcm_util.get_string(json_obj, 'p_year1');
            p_monreqen          := hcm_util.get_string(json_obj, 'p_month2');
            p_yeareqen          := hcm_util.get_string(json_obj, 'p_year2');

            hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  END initial_value;

  procedure get_index_medical (json_str_input in clob, json_str_output out clob) AS
  begin
            initial_value(json_str_input);
            if param_msg_error is null then
                gen_index_medical(json_str_output);
            else
                json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            end if;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  END get_index_medical;

  procedure gen_index_medical (json_str_output out clob) AS
            obj_data            json;
            obj_row             json := json();
            v_rcnt              number := 0;
            v_check_codempid    number := 0;
            v_flg_secur         boolean := false;
            v_flg_secur2        boolean := false;
            v_flg_exist         boolean := false;
            v_stdate            date;
            v_endate            date;

            cursor c1 is
                select numvcher,codempid,dtereq,typamt,amtexp,coddc,codcln,dtecrest,dtecreen,qtydcare
                  from tclnsinf
                 where codempid = p_codempid
                   and dtereq between v_stdate and v_endate
              order by dtereq;

      begin

            v_stdate := to_date('01/'||p_monreqst||'/'||to_char(p_yeareqst), 'dd/mm/yyyy');
            v_endate := last_day(to_date('01/'||p_monreqen||'/'||to_char(p_yeareqen), 'dd/mm/yyyy'));

            select count(codempid) into v_check_codempid
            from temploy1
            where codempid = p_codempid;

            if v_check_codempid = 0 then
                 param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
            end if;

            if p_codempid is not null then
                  v_flg_secur := secur_main.secur2(p_codempid,global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                  if not v_flg_secur then
                      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                      return;
                  end if;
              end if;

            if to_number(p_yeareqst) > to_number(p_yeareqen) then
                    param_msg_error := get_error_msg_php('HR2021',global_v_lang);
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    return;
            end if;

            if to_number(p_monreqst) > to_number(p_monreqen) then
                    param_msg_error := get_error_msg_php('HR2021',global_v_lang);
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    return;
            end if;

            for r1 in c1 loop
                v_flg_exist := true;
                exit;
            end loop;
            if not v_flg_exist then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TCLNSINF');
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    return;
            end if;

            for r1 in c1 loop
                obj_data := json();
                v_rcnt := v_rcnt + 1;
                v_flg_secur2 := secur_main.secur2(r1.codempid,global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                if  v_flg_secur2 then
                    obj_data.put('numvcher',r1.numvcher);
                    obj_data.put('codempid',r1.codempid);
                    obj_data.put('dtereq',to_char(r1.dtereq,'DD/MM/YYYY'));
                    obj_data.put('typpatient',get_tlistval_name('TYPAMT',r1.typamt,global_v_lang));
                    obj_data.put('temp01',r1.amtexp);
                    obj_data.put('item04',get_tdcinf_name(r1.coddc,global_v_lang));
                    obj_data.put('item05',get_tclninf_name(r1.codcln,global_v_lang));
                    obj_data.put('date02',to_char(r1.dtecrest,'DD/MM/YYYY'));
                    obj_data.put('date03',to_char(r1.dtecreen,'DD/MM/YYYY'));
                    obj_data.put('temp02',r1.qtydcare);
                    obj_row.put(to_char(v_rcnt-1),obj_data);
                end if;
            end loop;
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index_medical;

END HRBF1GX;


/

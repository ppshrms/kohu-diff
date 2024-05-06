--------------------------------------------------------
--  DDL for Package Body HRBF5RX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF5RX" AS

      procedure initial_value(json_str_input in clob) as
            json_obj    json;
        begin
            json_obj            := json(json_str_input);

            --global
            global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
            global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
            global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');

            -- index params
            p_codcompy          := hcm_util.get_string(json_obj, 'p_codcompy');
            p_dtelonst          := hcm_util.get_string(json_obj, 'p_dtelonst');
            p_dtelonen          := hcm_util.get_string(json_obj, 'p_dtelonen');
            p_typrep            := hcm_util.get_string(json_obj, 'p_typrep');
            hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        end initial_value;

      procedure get_index_loan (json_str_input in clob, json_str_output out clob) AS
        begin
            initial_value(json_str_input);
            if param_msg_error is null then
                gen_index_loan(json_str_output);
            else
                json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            end if;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      END get_index_loan;

      procedure gen_index_loan (json_str_output out clob) AS
            obj_data      json;
            obj_row       json := json();
            v_rcnt        number := 0;
            v_check_codcompy  number := 0;
            v_sum_emp         number := 0;
            v_sum_lon         number := 0;
            v_flg_secure      boolean := false;
            v_flg_exist       boolean := false;
            v_flg_permission     boolean := false;
            v_codcomp     tloaninf.codcomp%type;
            v_codlon      tloaninf.codlon%type;
            v_codempid    tloaninf.codempid%type;

              cursor c1 is
                  select distinct codlon
                    from tloaninf a
                   where codcomp like p_codcompy||'%'
                     and to_number(to_char(DTELONST,'yyyy')) between to_number(p_dtelonst) and to_number(p_dtelonen)
                     and exists (select codcomp from tusrcom b
                   where b.coduser = global_v_coduser and a.codcomp like b.codcomp||'%')
                order by codlon;

              cursor c1_1 is
                  select codlon,codcomp,count(distinct codempid) sum_emp,sum(nvl(amtlon,0)) sum_lon
                    from tloaninf a
                   where codlon = v_codlon
                     and codcomp like p_codcompy||'%'
                     and to_number(to_char(DTELONST,'yyyy')) between to_number(p_dtelonst) and to_number(p_dtelonen)
                     and exists (select codcomp from tusrcom b
                   where b.coduser = global_v_coduser and a.codcomp like b.codcomp||'%')
                group by codlon,codcomp
                order by codlon,codcomp;


            cursor c2 is
                select distinct codcomp
                  from tloaninf a
                 where codcomp like p_codcompy||'%'
                   and to_number(to_char(DTELONST,'yyyy')) between to_number(p_dtelonst) and to_number(p_dtelonen)
                   and exists (select codcomp from tusrcom b
                   where b.coduser = global_v_coduser and a.codcomp like b.codcomp||'%')
              order by codcomp;

              cursor c2_1 is
                select codlon,codcomp,count(distinct codempid) sum_emp,sum(nvl(amtlon,0)) sum_lon
                  from tloaninf a
                  where codcomp = v_codcomp
                   and to_number(to_char(DTELONST,'yyyy')) between to_number(p_dtelonst) and to_number(p_dtelonen)
                   and exists (select codcomp from tusrcom b
                   where b.coduser = global_v_coduser and a.codcomp like b.codcomp||'%')
              group by codcomp,codlon
              order by codcomp,codlon;
      BEGIN

            select count(codcompy) into v_check_codcompy
              from tcompny
              where codcompy = p_codcompy;

              if v_check_codcompy = 0 then
                 param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
              end if;

              if to_number(p_dtelonst) > to_number(p_dtelonen) then
                 param_msg_error := get_error_msg_php('HR2027',global_v_lang);
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
              end if;

              if p_typrep = '1' then
                   for r1 in c1 loop
                        v_flg_exist := true;
                        exit;
                   end loop;
              else
                   for r2 in c2 loop
                        v_flg_exist := true;
                        exit;
                   end loop;
              end if;

              if not v_flg_exist then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TLOANINF');
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    return;
              end if;
                --  secur_main.secur7
              if p_codcompy is not null then
                  v_flg_secure := secur_main.secur7(p_codcompy, global_v_coduser);
                  if not v_flg_secure then
                      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                      return;
                  end if;
              end if;

              if p_typrep = '1' then
                  for r1 in c1 loop
                      v_codlon := r1.codlon;
                      for r1_1 in c1_1 loop
                            v_flg_secure := secur_main.secur7(r1_1.codcomp,global_v_coduser);
                            if v_flg_secure then
                                obj_data := json();
                                v_rcnt := v_rcnt + 1;
                                v_flg_permission := true;
                                v_sum_emp := v_sum_emp + r1_1.sum_emp;
                                v_sum_lon := v_sum_lon + r1_1.sum_lon;
                                obj_data.put('typloan',get_ttyplone_name(r1_1.codlon, global_v_lang));
                                obj_data.put('namcomp', get_tcenter_name(r1_1.codcomp, global_v_lang));
                                obj_data.put('qtyemp', r1_1.sum_emp);
                                obj_data.put('loan', r1_1.sum_lon);
                                obj_row.put(to_char(v_rcnt-1),obj_data);
                            end if;
                      end loop;
                      obj_data := json();
                      v_rcnt := v_rcnt + 1;
                      obj_data.put('typloan','');
                      obj_data.put('namcomp', get_label_name('HRBF5RXC2', global_v_lang, '50'));
                      obj_data.put('qtyemp', v_sum_emp);
                      obj_data.put('loan', v_sum_lon);
                      obj_row.put(to_char(v_rcnt-1),obj_data);
                      v_sum_emp := 0;
                      v_sum_lon := 0;
                  end loop;
              else
                  for r2 in c2 loop
                      v_codcomp := r2.codcomp;
                      for r2_1 in c2_1 loop
                            v_flg_secure := secur_main.secur7(r2_1.codcomp,global_v_coduser);
                            if v_flg_secure then
                                obj_data := json();
                                v_rcnt := v_rcnt + 1;
                                v_flg_permission := true;
                                v_sum_emp := v_sum_emp + r2_1.sum_emp;
                                v_sum_lon := v_sum_lon + r2_1.sum_lon;
                                obj_data.put('namcomp', get_tcenter_name(r2_1.codcomp, global_v_lang));
                                obj_data.put('typloan',get_ttyplone_name(r2_1.codlon, global_v_lang));
                                obj_data.put('qtyemp', r2_1.sum_emp);
                                obj_data.put('loan', r2_1.sum_lon);
                                obj_row.put(to_char(v_rcnt-1),obj_data);
                            end if;
                      end loop;
                      obj_data := json();
                      v_rcnt := v_rcnt + 1;
                      obj_data.put('namcomp', '');
                      obj_data.put('typloan', get_label_name('HRBF5RXC2', global_v_lang, '50'));
                      obj_data.put('qtyemp', v_sum_emp);
                      obj_data.put('loan', v_sum_lon);
                      obj_row.put(to_char(v_rcnt-1),obj_data);
                      v_sum_emp := 0;
                      v_sum_lon := 0;
                  end loop;
              end if;
              if not v_flg_permission and v_flg_exist then
                    param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    return;
                end if;
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      END gen_index_loan;

END HRBF5RX;

/

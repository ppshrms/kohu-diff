--------------------------------------------------------
--  DDL for Package Body HRCO24E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO24E" AS

  procedure initial_value (json_str in clob) AS
 json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  END initial_value;
--
  procedure check_index AS
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codpos is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpos');
      return;
    end if;
    if p_nampos is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'nampos');
      return;
    end if;
  END check_index;
--
  procedure get_index (json_str_input in clob, json_str_output out clob) AS
 begin
    gen_index(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  END get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_status           varchar2(100 char);
    cursor cl is
      select t1.CODPOS CODPOS, t1.NAMPOSE NAMPOSE,t1.NAMPOST NAMPOST,t1.NAMPOS3 NAMPOS3,t1.NAMPOS4 NAMPOS4,t1.NAMPOS5 NAMPOS5, t1.NAMABBE NAMABBE, t1.NAMABBT NAMABBT, t1.NAMABB3 NAMABB3, t1.NAMABB4 NAMABB4, t1.NAMABB5 NAMABB5,decode(global_v_lang,'101',t1.NAMABBE,
                                                        '102',t1.NAMABBT,
                                                        '103',t1.NAMABB3,
                                                        '104',t1.NAMABB4,
                                                        '105',t1.NAMABB5,null) NAMABB
        from TPOSTN t1
    order by t1.CODPOS;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;

    for r1 in cl loop
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('nampos', get_tpostn_name(r1.codpos,global_v_lang));
      obj_data.put('nampose', r1.NAMPOSE);
      obj_data.put('nampost', r1.NAMPOST);
      obj_data.put('nampos3', r1.NAMPOS3);
      obj_data.put('nampos4', r1.NAMPOS4);
      obj_data.put('nampos5', r1.NAMPOS5);
      obj_data.put('namabb', r1.NAMABB);
      obj_data.put('namabbe', r1.NAMABBE);
      obj_data.put('namabbt', r1.NAMABBT);
      obj_data.put('namabb3', r1.NAMABB3);
      obj_data.put('namabb4', r1.NAMABB4);
      obj_data.put('namabb5', r1.NAMABB5);
      obj_data.put('codpos', r1.codpos);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt               := v_rcnt + 1;
    end loop;

    json_str_output := obj_row.to_clob;
  END gen_index;

--  procedure post_delete (json_str_input in clob, json_str_output out clob) AS
--   begin
--    initial_value(json_str_input);
----    check_delete(json_str_input);
--    if param_msg_error is null then
--      delete_data(json_str_input, json_str_output);
--    else
--      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
--    end if;
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
--  END post_delete;
--
--  procedure delete_data (json_str_input in clob, json_str_output out clob) AS
--  json_str        json;
--    param_json       json;
--    param_json_row   json;
--    v_codpos       varchar2(8 char);
--  begin
--    json_str               := json(json_str_input);
--    param_json             := json(hcm_util.get_string(json_str, 'param_json'));
--    for i in 0..param_json.count-1 loop
--      param_json_row       := json(param_json.get(to_char(i)));
--      v_codpos           := hcm_util.get_string(param_json_row, 'codpos');
--
--      begin
--        delete tpostn
--         where codpos = v_codpos;
--        param_msg_error := get_error_msg_php('HR2425', global_v_lang);
--        commit;
--      exception
--        when others then null;
--      end;
--
--    end loop;
--    commit;
--    param_msg_error := get_error_msg_php('HR2425', global_v_lang);
--    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
--  END delete_data;

  procedure save_tpostn (json_str_input in clob, json_str_output out clob) AS
    json_obj            json_object_t;
    json_assign         json_object_t;
    json_pathfile       json_object_t;
    v_json              json_object_t;
    v_total_assign      number := 0;
  begin
    initial_value(json_str_input);
    save_data_main(json_str_input, json_str_output);
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error||''||p_codpos||'0', global_v_lang);
  END save_tpostn;

  procedure save_data_main (json_str_input in clob, json_str_output out clob) AS
    json_str        json_object_t;
    param_json       json_object_t;
    param_json_row   json_object_t;
    v_codpos                TPOSTN.codpos%type;
    v_nampose               TPOSTN.nampose%type;
    v_nampost               TPOSTN.nampost%type;
    v_nampos3               TPOSTN.nampos3%type;
    v_nampos4               TPOSTN.nampos4%type;
    v_nampos5               TPOSTN.nampos5%type;
    v_namabbe               TPOSTN.namabbe%type;
    v_namabbt               TPOSTN.namabbt%type;
    v_namabb3               TPOSTN.namabb3%type;
    v_namabb4               TPOSTN.namabb4%type;
    v_namabb5               TPOSTN.namabb5%type;
    v_namposoe              TPOSTN.nampose%type;
    v_namposot              TPOSTN.nampost%type;
    v_namposo3              TPOSTN.nampos3%type;
    v_namposo4              TPOSTN.nampos4%type;
    v_namposo5              TPOSTN.nampos5%type;
    v_namabboe              TPOSTN.namabbe%type;
    v_namabbot              TPOSTN.namabbt%type;
    v_namabbo3              TPOSTN.namabb3%type;
    v_namabbo4              TPOSTN.namabb4%type;
    v_namabbo5              TPOSTN.namabb5%type;
    v_flg                   varchar2(50 char);
    v_total                 number;
    v_count1                number;
    v_count2                number;
    v_count3                number;--User37 #5267 Final Test Phase 1 V11 30/03/2021   
  begin

    json_str               := json_object_t(json_str_input);
    param_json             := hcm_util.get_json_t(json_str, 'param_json');
    for i in 0..param_json.get_size-1 loop
      param_json_row       := hcm_util.get_json_t(param_json,to_char(i));
      p_flg               := hcm_util.get_string_t(param_json_row, 'flg');
      p_codpos            := hcm_util.get_string_t(param_json_row, 'codpos');
      p_nampos            := hcm_util.get_string_t(param_json_row, 'nampos');
      p_nampose           := hcm_util.get_string_t(param_json_row, 'nampose');
      p_nampost           := hcm_util.get_string_t(param_json_row, 'nampost');
      p_nampos3           := hcm_util.get_string_t(param_json_row, 'nampos3');
      p_nampos4           := hcm_util.get_string_t(param_json_row, 'nampos4');
      p_nampos5           := hcm_util.get_string_t(param_json_row, 'nampos5');
      p_namabbe           := hcm_util.get_string_t(param_json_row, 'namabbe');
      p_namabbt           := hcm_util.get_string_t(param_json_row, 'namabbt');
      p_namabb3           := hcm_util.get_string_t(param_json_row, 'namabb3');
      p_namabb4           := hcm_util.get_string_t(param_json_row, 'namabb4');
      p_namabb5           := hcm_util.get_string_t(param_json_row, 'namabb5');

      p_codposOld           := hcm_util.get_string_t(param_json_row, 'codposOld');
      p_namposOld           := hcm_util.get_string_t(param_json_row, 'namposOld');
      p_namposeOld          := hcm_util.get_string_t(param_json_row, 'namposeOld');
      p_nampostOld          := hcm_util.get_string_t(param_json_row, 'nampostOld');
      p_nampos3Old          := hcm_util.get_string_t(param_json_row, 'nampos3Old');
      p_nampos4Old          := hcm_util.get_string_t(param_json_row, 'nampos4Old');
      p_nampos5Old          := hcm_util.get_string_t(param_json_row, 'nampos5Old');
      p_namabbOld           := hcm_util.get_string_t(param_json_row, 'namabbOld');
      p_namabbeOld          := hcm_util.get_string_t(param_json_row, 'namabbeOld');
      p_namabbtOld          := hcm_util.get_string_t(param_json_row, 'namabbtOld');
      p_namabb3Old          := hcm_util.get_string_t(param_json_row, 'namabb3Old');
      p_namabb4Old          := hcm_util.get_string_t(param_json_row, 'namabb4Old');
      p_namabb5Old          := hcm_util.get_string_t(param_json_row, 'namabb5Old');

      if p_flg like 'add' then
          check_index;
          if param_msg_error is null then
            begin
               select codpos
               into v_codpos
               from TPOSTN
               where codpos = p_codpos;
               exception when no_data_found then
                 v_codpos := '';
            end;
            if v_codpos is null then

                insert into TPOSTN (codpos,nampose,nampost,nampos3,nampos4,nampos5,
                                    namabbe,namabbt,namabb3,namabb4,namabb5,
                                    codcreate,dtecreate,coduser, dteupd)
                values (p_codpos, p_nampose, p_nampost, p_nampos3,p_nampos4,p_nampos5,
                        p_namabbe, p_namabbt,p_namabb3, p_namabb4, p_namabb5,
                        global_v_coduser,trunc(sysdate),global_v_coduser,trunc(sysdate));

            insert into TPOSTNLOG (codpos, dtechg, nampose, nampost, nampos3,nampos4, nampos5,
                                    namabbe, namabbt,namabb3, namabb4, namabb5,
                                    namposoe, namposot, namposo3,namposo4, namposo5,
                                    namabboe, namabbot,namabbo3, namabbo4, namabbo5,
                                    codcreate,dtecreate,coduser, dteupd)
                            values (p_codpos, sysdate, p_nampose, p_nampost, p_nampos3,p_nampos4,p_nampos5,
                                    p_namabbe, p_namabbt,p_namabb3, p_namabb4, p_namabb5,
                                    '','','','','',
                                    '','','','','',
                                    global_v_coduser,trunc(sysdate),global_v_coduser,trunc(sysdate));

            else
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TPOSTN');
                json_str_output := get_response_message(null, param_msg_error, global_v_lang);
                return;
            end if;
          else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
          end if;
      elsif p_flg like 'edit' then
        begin
          -- update tpostn
          update TPOSTN
          set  nampose = p_nampose,
               nampost = p_nampost,
               nampos3 = p_nampos3,
               nampos4 = p_nampos4,
               nampos5 = p_nampos5,
               namabbe = p_namabbe,
               namabbt = p_namabbt,
               namabb3 = p_namabb3,
               namabb4 = p_namabb4,
               namabb5 = p_namabb5,
               coduser = global_v_coduser
          where codpos = p_codpos;

          --insert log
            insert into TPOSTNLOG (codpos, dtechg, nampose, nampost, nampos3,nampos4, nampos5,
                                    namabbe, namabbt,namabb3, namabb4, namabb5,
                                    namposoe, namposot, namposo3,namposo4, namposo5,
                                    namabboe, namabbot,namabbo3, namabbo4, namabbo5,
                                    codcreate,dtecreate,coduser, dteupd)
                            values (p_codpos, sysdate, p_nampose, p_nampost, p_nampos3,p_nampos4,p_nampos5,
                                    p_namabbe, p_namabbt,p_namabb3, p_namabb4, p_namabb5,
                                    p_namposeOld,p_nampostOld,p_nampos3Old,p_nampos4Old,p_nampos5Old,
                                    p_namabbeOld,p_namabbtOld,p_namabb3Old,p_namabb4Old,p_namabb5Old,
                                    global_v_coduser,trunc(sysdate),global_v_coduser,trunc(sysdate));
        end;
      elsif p_flg like 'delete' then
        begin
             select count(*)
             into v_count1
             from tapplinf
             where p_codpos in (codposc,codposl);
        exception when others then
            v_count1 := 0;
        end;
        begin
             select count(*)
             into v_count2
             from temploy1
             where codpos = p_codpos;
        exception when others then
            v_count2 := 0;
        end;

        --<<User37 #5267 Final Test Phase 1 V11 30/03/2021   
        begin
             select count(*)
             into v_count3
             from thismove
             where codpos = p_codpos;
        exception when others then
            v_count3 := 0;
        end;

        if v_count1 + v_count2 + v_count3 > 0 then
        --if v_count1 + v_count2 > 0 then
        -->>User37 #5267 Final Test Phase 1 V11 30/03/2021  
            param_msg_error := get_error_msg_php('HR1450',global_v_lang);
            exit;
        else
             delete TPOSTN
             where codpos = p_codpos;
             commit;
        end if;

      end if;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  END save_data_main;
END HRCO24E;

/

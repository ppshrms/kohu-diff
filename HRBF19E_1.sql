--------------------------------------------------------
--  DDL for Package Body HRBF19E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF19E" as

  procedure initial_value(json_str_input in clob) as
    json_obj    json;
  begin
    json_obj             := json(json_str_input);

    --global
    global_v_coduser     := hcm_util.get_string(json_obj, 'p_coduser');
    global_v_lang        := hcm_util.get_string(json_obj, 'p_lang');
    global_v_codempid    := hcm_util.get_string(json_obj, 'p_codempid');

    json_params          := hcm_util.get_json(json_obj, 'json_input_str');

    p_codcompy           := hcm_util.get_string(json_obj, 'p_codcompy');
    p_numseq             := hcm_util.get_string(json_obj, 'p_numseq');
  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) as
    obj_row              json    := json();
    obj_data             json;
    v_rcnt               number  := 1;
    v_count_tcompny      number;
    v_flg_secure         boolean := false;

    cursor c1 is
        select numseq, syncond, statement
          from tlmedexh
         where codcompy = p_codcompy
         order by numseq;
  begin
    --check codcomp exist in tcompny
    begin
        select count(codcompy)
          into v_count_tcompny
          from tcompny
         where codcompy = p_codcompy
           and rownum = 1;
    end;
    if v_count_tcompny = 0 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    --secur_main.secur7
    v_flg_secure := secur_main.secur7(p_codcompy, global_v_coduser);
    if not v_flg_secure then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    for r1 in c1 loop
        obj_data := json();
        obj_data.put('numseq', r1.numseq);
--        obj_data.put('desc_syncond', get_logical_name(p_codapp, r1.syncond, global_v_lang));
        obj_data.put('desc_syncond', get_logical_desc( r1.statement));
        obj_row.put(to_char(v_rcnt-1),obj_data);
        v_rcnt := v_rcnt + 1;
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
     param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
     json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  procedure get_detail (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) as
    obj_row              json    := json();
    obj_syncond          json    := json();
    v_rcnt               number  := 1;
    v_syncond            tlmedexh.syncond%type;
    v_flgprorate         tlmedexh.flgprorate%type;
    v_statement          tlmedexh.statement%type;

  begin
    begin
        select syncond, flgprorate, statement
          into v_syncond, v_flgprorate, v_statement
          from tlmedexh
         where codcompy = p_codcompy
           and numseq = p_numseq;
      exception when no_data_found then
         v_syncond    := null;
         v_flgprorate := 'Y';--User37 TDK-SS2101 Issue #6691 18/08/2021 null;
         v_statement  := null;
    end;
    obj_syncond.put('code', v_syncond);
--    obj_syncond.put('description', get_logical_name(p_codapp, v_syncond, global_v_lang));
    obj_syncond.put('description', get_logical_desc(v_statement));
    obj_syncond.put('statement', v_statement);
    obj_row.put('numseq', p_numseq);
    obj_row.put('codcompy', p_codcompy);
    obj_row.put('flgprorate', v_flgprorate);
    obj_row.put('syncond', obj_syncond);
    obj_row.put('coderror', '200');

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
     param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
     json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;

  procedure get_table (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_table(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_table;

  procedure gen_table (json_str_output out clob) as
    obj_table            json    := json();
    obj_row              json    := json();
    obj_data             json;
    v_rcnt               number  := 1;
    v_total              number  := 0;

    cursor c1 is
        select typamt, typrel, amtwidrwy, qtywidrwy, amtwidrwt
          from tlmedexp
         where codcompy = p_codcompy
           and numseq = p_numseq;
  begin
    for r1 in c1 loop
        v_total := v_total + 1;
    end loop;
    for r1 in c1 loop
        obj_data := json();
        obj_data.put('typamt', r1.typamt);
        obj_data.put('typrel', r1.typrel);
        obj_data.put('amtwidrwy', r1.amtwidrwy);
        obj_data.put('qtywidrwy', r1.qtywidrwy);
        obj_data.put('amtwidrwt', r1.amtwidrwt);
        obj_row.put(to_char(v_rcnt-1),obj_data);
        v_rcnt := v_rcnt + 1;
    end loop;
    obj_table.put('total', v_total);
    obj_table.put('rows', obj_row);
    obj_table.put('coderror', '200');
    dbms_lob.createtemporary(json_str_output, true);
    obj_table.to_clob(json_str_output);
  exception when others then
     param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
     json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_table;

  procedure delete_index(json_str_input in clob, json_str_output out clob) as
    v_json_row         json;
    v_codcompy         tlmedexh.codcompy%type;
    v_numseq           tlmedexh.numseq%type;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        for i in 0..json_params.count-1 loop
           v_json_row     := hcm_util.get_json(json_params, to_char(i));
           v_codcompy     := hcm_util.get_string(v_json_row,'codcompy');
           v_numseq       := hcm_util.get_string(v_json_row,'numseq');
           begin
             delete from tlmedexh
              where codcompy = v_codcompy
                and numseq = v_numseq;
           exception when others then
                rollback;
           end;
           begin
             delete from tlmedexp
              where codcompy = v_codcompy
                and numseq = v_numseq;
           exception when others then
                rollback;
           end;
        end loop;
    end if;
    if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        commit;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);

  exception when others then
     param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
     json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end delete_index;

  procedure save_data(json_str_input in clob, json_str_output out clob) as
    v_syncond          tlmedexh.syncond%type;
    v_statement        tlmedexh.statement%type;
    v_flgprorate       tlmedexh.syncond%type;
    v_codcompy         tlmedexp.codcompy%type;
    v_numseq           tlmedexp.numseq%type;
    v_typamt           tlmedexp.typamt%type;
    v_typrel           tlmedexp.typrel%type;
    v_typamtold        tlmedexp.typamt%type;
    v_typrelold        tlmedexp.typrel%type;
    v_amtwidrwy        tlmedexp.amtwidrwy%type;
    v_qtywidrwy        tlmedexp.qtywidrwy%type;
    v_amtwidrwt        tlmedexp.amtwidrwt%type;
    v_flg              varchar2(6 char);
    v_param_json       json;
    v_row              json;
  begin
    initial_value(json_str_input);
    v_codcompy   := hcm_util.get_string(json_params,'codcompy');
    v_numseq     := hcm_util.get_string(json_params,'numseq');
    v_syncond    := hcm_util.get_string(hcm_util.get_json(json_params, 'syncond'), 'code');
    v_statement  := hcm_util.get_string(hcm_util.get_json(json_params, 'syncond'), 'statement');
    v_flgprorate := hcm_util.get_string(json_params,'flgprorate');
    v_param_json := hcm_util.get_json(json_params,'param_json');
    begin
      insert into tlmedexh(codcompy,numseq,syncond,flgprorate,statement,dtecreate,coduser)
           values (v_codcompy,v_numseq,v_syncond,v_flgprorate,v_statement,trunc(sysdate),global_v_coduser);
      exception when dup_val_on_index then
        begin
            update tlmedexh
               set syncond    = v_syncond,
                   flgprorate = v_flgprorate,
                   statement  = v_statement,
                   dteupd     = trunc(sysdate),
                   coduser    = global_v_coduser
             where codcompy   = v_codcompy
               and numseq     = v_numseq;
            exception when others then
              rollback;
        end;
    end;
    if param_msg_error is null then
        for i in 0..v_param_json.count-1 loop
            v_row       := hcm_util.get_json(v_param_json, to_char(i));
            v_flg       := hcm_util.get_string(v_row,'flg');
            v_typamt    := hcm_util.get_string(v_row,'typamt');
            v_typrel    := hcm_util.get_string(v_row,'typrel');
            v_typamtold := hcm_util.get_string(v_row,'typamtOld');
            v_typrelold := hcm_util.get_string(v_row,'typrelOld');
            v_amtwidrwy := hcm_util.get_string(v_row,'amtwidrwy');
            v_qtywidrwy := hcm_util.get_string(v_row,'qtywidrwy');
            v_amtwidrwt := hcm_util.get_string(v_row,'amtwidrwt');

            if v_flg = 'delete' then
               begin
                 delete from tlmedexp
                  where codcompy = v_codcompy
                    and numseq = v_numseq
                    and typamt = v_typamt
                    and typrel = v_typrel;
                 exception when others then
                   rollback;
               end;
            elsif v_flg = 'edit' then
               begin
                 update tlmedexp
                    set typamt    = v_typamt,
                        typrel    = v_typrel,
                        amtwidrwy = v_amtwidrwy,
                        qtywidrwy = v_qtywidrwy,
                        amtwidrwt = v_amtwidrwt,
                        dteupd    = trunc(sysdate),
                        coduser   = global_v_coduser
                  where codcompy  = v_codcompy
                    and numseq = v_numseq
                    and typamt = v_typamtold
                    and typrel = v_typrelold;
               exception when others then
                    rollback;
               end;
            elsif v_flg = 'add' then
               begin
                  insert into tlmedexp(codcompy,numseq,typamt,typrel,amtwidrwy,qtywidrwy,amtwidrwt,dtecreate,coduser)
                       values (v_codcompy,v_numseq,v_typamt,v_typrel,v_amtwidrwy,v_qtywidrwy,v_amtwidrwt,trunc(sysdate),global_v_coduser);
                  exception when dup_val_on_index then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang);
               end;
            end if;
        end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;

  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_data;

end HRBF19E;

/

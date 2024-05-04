--------------------------------------------------------
--  DDL for Package Body HRBFA7B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBFA7B" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_dteyear           := to_number(hcm_util.get_number_t(json_obj, 'p_dteyear'));
    p_amtheal           := hcm_util.get_string_t(json_obj, 'p_amtheal');
    p_codprgheal        := hcm_util.get_string_t(json_obj, 'p_codprgheal');
    p_codcln            := hcm_util.get_string_t(json_obj, 'p_codcln');
    p_fileData          := hcm_util.get_json_t(json_obj, 'p_fileData');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  function check_max_length_column (v_table varchar2, v_column varchar2, v_data varchar2, v_colunm_error varchar2 default null) return varchar2 is
    v_length        user_tab_columns.char_length%type;
    v_obj           json_object_t;
    v_msg           varchar2(1000 char);
    v_result        varchar2(1000 char);
  begin
    begin
      select char_length
        into v_length
        from user_tab_columns
       where table_name  = upper(v_table)
         and column_name = upper(v_column);
    exception when others then
        v_length := 0;
    end;
    if v_length < length(v_data) then
      v_msg     := get_error_msg_php('HR2060', global_v_lang, v_table, null, false);
      v_obj     := json_object_t(get_response_message(null, v_msg, global_v_lang));
      v_result  := hcm_util.get_string_t(v_obj, 'response') || ' (' || upper(nvl(v_colunm_error, v_column)) || ') (MAX ' || v_length || ' CHAR)';
    end if;
    return v_result;
  end check_max_length_column;

  function check_codempid (v_codempid temploy1.codempid%type, v_codprgheal thealinf1.codprgheal%type) return varchar2 is
    v_msg           varchar2(1000 char);
    v_result        varchar2(1000 char);
    v_staemp        temploy1.staemp%type;
    v_numlvl        temploy1.numlvl%type;
    v_obj           json_object_t;
    v_secur         boolean := false;
    v_zupdsal       varchar2(10 char);
    b_codprgheal    thealinf1.codprgheal%type;
  begin
    if v_codempid is null then
      v_msg := get_error_msg_php('HR2045', global_v_lang);
    else
      begin
        select staemp, codcomp, numlvl
          into v_staemp, p_codcomp, v_numlvl
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        v_msg := get_error_msg_php('HR2010', global_v_lang, 'temploy1', null, false);
      end;
    end if;
    if v_msg is null then
      begin
        select codprgheal
          into b_codprgheal
          from thealinf1
         where codempid   = v_codempid
           and dteyear    = p_dteyear
           and codprgheal = v_codprgheal;
      exception when no_data_found then
        v_msg := get_error_msg_php('HR2010', global_v_lang, 'thealinf1', null, false);
      end;
    end if;
    if v_msg is null then
      v_secur := secur_main.secur1(p_codcomp, v_numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if not v_secur then
        v_msg := get_error_msg_php('HR3007', global_v_lang);
      end if;
    end if;
    if v_msg is not null then
      v_obj     := json_object_t(get_response_message(null, v_msg, global_v_lang));
      v_result  := hcm_util.get_string_t(v_obj, 'response') || ' (CODEMPID)';
    end if;
    return v_result;
  end check_codempid;

  function check_codprgheal (v_codprgheal thealcde.codprgheal%type) return varchar2 is
    v_msg           varchar2(1000 char);
    v_result        varchar2(1000 char);
    b_codprgheal    thealcde.codprgheal%type;
    v_obj           json_object_t;
  begin
    if v_codprgheal is null then
      v_msg := get_error_msg_php('HR2045', global_v_lang);
    else
      begin
        select codprgheal
          into b_codprgheal
          from thealcde
         where codprgheal = v_codprgheal;
      exception when no_data_found then
        v_msg := get_error_msg_php('HR2010', global_v_lang, 'thealcde', null, false);
      end;
    end if;
    if v_msg is not null then
      v_obj     := json_object_t(get_response_message(null, v_msg, global_v_lang));
      v_result  := hcm_util.get_string_t(v_obj, 'response') || ' (CODPRGHEAL)';
    end if;
    if v_msg is null then
      if v_codprgheal <> p_codprgheal then
        v_msg    := get_error_msg_php('BF0059', global_v_lang);
        v_result := replace(v_msg, '@#$%400');
      end if;
    end if;
    return v_result;
  end check_codprgheal;

  function check_codheal (v_codheal tcodheal.codcodec%type) return varchar2 is
    v_msg           varchar2(1000 char);
    v_result        varchar2(1000 char);
    b_codcodec      tcodheal.codcodec%type;
    v_obj           json_object_t;
  begin
    if v_codheal is null then
      v_msg := get_error_msg_php('HR2045', global_v_lang);
    else
      begin
        select codcodec
          into b_codcodec
          from tcodheal
         where codcodec = v_codheal;
      exception when no_data_found then
        v_msg := get_error_msg_php('HR2010', global_v_lang, 'tcodheal', null, false);
      end;
    end if;
    if v_msg is not null then
      v_obj     := json_object_t(get_response_message(null, v_msg, global_v_lang));
      v_result  := hcm_util.get_string_t(v_obj, 'response') || ' (CODHEAL)';
    end if;
    return v_result;
  end check_codheal;

  procedure check_process is
    v_codcln            tclninf.codcln%type;
    v_codprgheal        thealcde.codprgheal%type;
  begin
    if p_codcln is not null then
      begin
        select codcln
          into v_codcln
          from tclninf
         where codcln = p_codcln;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tclninf');
        return;
      end;
    end if;
    if p_codprgheal is not null then
      begin
        select codprgheal
          into v_codprgheal
          from thealcde
         where codprgheal = p_codprgheal;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'thealcde');
        return;
      end;
    end if;
  end check_process;

  procedure data_process (json_str_input in clob, json_str_output out clob) AS
    v_filename          varchar2(300 char);
    obj_columns         json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    obj_detail          json_object_t;
    obj_table           json_object_t;
    obj_rows            json_object_t;
    obj_tmp             json_object_t;
    v_codempid          thealinf1.codempid%type;
    v_codprgheal        thealinf1.codprgheal%type;
    v_codheal           thealinf2.codheal%type;
    v_descheck_char     clob;
    v_descheck          thealinf2.descheck%type;
    v_desheal_char      clob;
    v_desheal           thealinf2.descheal%type;
    v_chkresul_char     clob;
    v_chkresul          thealinf2.chkresult%type;
    v_amtheal_char      clob;
    v_amtheal           thealinf1.amtheal%type;
    v_dteheal_char      clob;
    v_dteheal           thealinf1.dteheal%type;
    v_dtefollow_char    clob;
    v_dtefollow         thealinf1.dtefollow%type;
    v_msg               clob;
    v_msg_check         varchar2(1000 char);
    v_num_success       number := 0;
    v_check_bool        boolean;
    --<<User37 #6807 06/09/2021
    v_num               number := 0;
    v_error             varchar2(1000 char) := 'N';
    -->>User37 #6807 06/09/2021

    cursor c1 is
      select dteyear, codcomp, codprgheal, codcln, dteheal, avg(amtheal) amtheal
        from thealinf1
       where dteyear    = p_dteyear
         and codcomp    = p_codcomp
         and codprgheal = v_codprgheal
         and codcln     = p_codcln
         and dteheal    = v_dteheal
       group by dteyear, codcomp, codprgheal, codcln, dteheal;
  begin
    initial_value(json_str_input);
    obj_result          := json_object_t();
    obj_detail          := json_object_t();
    obj_table           := json_object_t();
    obj_rows            := json_object_t();
    v_filename          := hcm_util.get_string_t(p_fileData, 'fileName');
    obj_columns         := hcm_util.get_json_t(p_fileData, 'columns');
    obj_data            := hcm_util.get_json_t(p_fileData, 'dataRows');
    --<<User37 #6807 06/09/2021
    if v_filename is null or p_dteyear is null or p_codprgheal is null or p_codcln is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    end if;
    -->>User37 #6807 06/09/2021
    for i in 0 .. obj_data.get_size - 1 loop
      if param_msg_error is null then
        v_check_bool      := true;
        v_msg_check       := null;
        obj_rows          := hcm_util.get_json_t(obj_data, to_char(i));
        begin
          v_codempid        := upper(hcm_util.get_string_t(obj_rows, 'codempid'));
        exception when others then
          obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('PM0070', global_v_lang), global_v_lang));
          v_msg_check       := hcm_util.get_string_t(obj_tmp, 'response') || ' (CODEMPID)';
        end;
        if v_check_bool then
          if v_msg_check is not null then
            v_msg             := v_msg_check;
            v_check_bool      := false;
          end if;
        end if;
        begin
          v_codprgheal      := upper(hcm_util.get_string_t(obj_rows, 'codprgheal'));
        exception when others then
          obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR2060', global_v_lang), global_v_lang));
          v_msg_check       := hcm_util.get_string_t(obj_tmp, 'response') || ' (CODPRGHEAL)';
        end;
        if v_check_bool then
          if v_msg_check is not null then
            v_msg             := v_msg_check;
            v_check_bool      := false;
          end if;
        end if;
        begin
          v_codheal         := upper(hcm_util.get_string_t(obj_rows, 'codheal'));
        exception when others then
          obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR2060', global_v_lang), global_v_lang));
          v_msg_check       := hcm_util.get_string_t(obj_tmp, 'response') || ' (CODHEAL)';
        end;
        if v_check_bool then
          if v_msg_check is not null then
            v_msg             := v_msg_check;
            v_check_bool      := false;
          end if;
        end if;
        v_descheck_char   := hcm_util.get_string_t(obj_rows, 'descheck');
        v_desheal_char    := hcm_util.get_string_t(obj_rows, 'desheal');
        v_chkresul_char   := hcm_util.get_string_t(obj_rows, 'chkresul');
        v_amtheal_char    := hcm_util.get_string_t(obj_rows, 'amtheal');
        v_dteheal_char    := hcm_util.get_string_t(obj_rows, 'dteheal');
        v_dtefollow_char  := hcm_util.get_string_t(obj_rows, 'dtefollow');
        if v_check_bool then
          v_msg             := null;
          v_msg_check       := check_codprgheal(v_codprgheal);
          if v_msg_check is not null then
            v_msg             := v_msg_check;
            v_check_bool      := false;
          end if;
        end if;
        v_msg_check       := check_codempid(v_codempid, v_codprgheal);
        if v_check_bool then
          if v_msg_check is not null then
            v_msg             := v_msg_check;
            v_check_bool      := false;
          end if;
        end if;
        if v_check_bool then
          v_msg             := null;
          v_msg_check       := check_codheal(v_codheal);
          if v_msg_check is not null then
            v_msg             := v_msg_check;
            v_check_bool      := false;
          end if;
        end if;
        if v_check_bool then
          v_msg             := null;
          v_msg_check       := check_max_length_column('thealinf2', 'descheck', v_descheck_char);
          if v_msg_check is not null then
            v_msg             := v_msg_check;
            v_check_bool      := false;
          else
            v_descheck        := v_descheck_char;
          end if;
        end if;
        if v_check_bool then
          v_msg             := null;
          v_msg_check       := check_max_length_column('thealinf2', 'descheal', v_desheal_char, 'desheal');
          if v_msg_check is not null then
            v_msg             := v_msg_check;
            v_check_bool      := false;
          else
            v_desheal         := v_desheal_char;
          end if;
        end if;
        if v_check_bool then
          v_msg             := null;
          v_msg_check       := null;
          v_chkresul        := 0;
          begin
            v_chkresul        := to_number(v_chkresul_char);
            if v_chkresul not in (0, 1) then
              obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR2057', global_v_lang), global_v_lang));
              v_msg_check       := hcm_util.get_string_t(obj_tmp, 'response') || ' 0,1' || ' (CHKRESUL)';
            end if;
          exception when others then
            obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR2020', global_v_lang), global_v_lang));
            v_msg_check       := hcm_util.get_string_t(obj_tmp, 'response') || ' (CHKRESUL)';
          end;
          if v_msg_check is not null then
            v_msg             := v_msg_check;
            v_check_bool      := false;
          end if;
        end if;
        if v_check_bool then
          v_msg             := null;
          v_msg_check       := null;
          v_amtheal         := 0;
          begin
            v_amtheal         := to_number(replace(v_amtheal_char, ',', null));
          exception when others then
            obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR2816', global_v_lang), global_v_lang));
            v_msg_check       := hcm_util.get_string_t(obj_tmp, 'response') || ' (AMTHEAL)';
          end;
          if v_msg_check is not null then
            v_msg             := v_msg_check;
            v_check_bool      := false;
          end if;
        end if;
        if v_check_bool then
          v_msg             := null;
          v_msg_check       := null;
          v_dteheal         := null;
          begin
            if v_dteheal_char is not null then
              v_dteheal         := to_date(v_dteheal_char, 'DD/MM/YYYY');
            else
              obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR2045', global_v_lang), global_v_lang));
              v_msg_check       := hcm_util.get_string_t(obj_tmp, 'response') || ' (DTEHEAL)';
            end if;
          exception when others then
            obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR2025', global_v_lang), global_v_lang));
            v_msg_check       := hcm_util.get_string_t(obj_tmp, 'response') || ' (DTEHEAL)';
          end;
          if v_msg_check is not null then
            v_msg             := v_msg_check;
            v_check_bool      := false;
          end if;
        end if;
        if v_check_bool then
          v_msg             := null;
          v_msg_check       := null;
          v_dtefollow       := null;
          begin
            if v_dtefollow_char is not null then
              v_dtefollow       := to_date(v_dtefollow_char, 'DD/MM/YYYY');
            end if;
          exception when others then
            obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR2025', global_v_lang), global_v_lang));
            v_msg_check       := hcm_util.get_string_t(obj_tmp, 'response') || ' (DTEFOLLOW)';
          end;
          if v_msg_check is not null then
            v_msg             := v_msg_check;
            v_check_bool      := false;
          end if;
        end if;
        if v_check_bool then
          v_msg             := null;
          v_amtheal         := nvl(v_amtheal, p_amtheal);
          begin
            insert into thealinf1
                        (codempid, dteyear, codprgheal,
                         codcln, dteheal, codcomp, namdoc,
                         numcert, namdoc2, numcert2, descheal,
                         dtefollow, amtheal, dtecreate, codcreate, coduser, codcomphf)
                 values (v_codempid, p_dteyear, v_codprgheal,
                         p_codcln, v_dteheal, p_codcomp, null,
                         null, null, null, v_desheal,
                         v_dtefollow, v_amtheal, sysdate, global_v_coduser, 'CONVERT', p_codcomp);
          exception when dup_val_on_index then
            update thealinf1
               set codcln     = p_codcln,
                   dteheal    = v_dteheal,
                   codcomp    = p_codcomp,
                   dtefollow  = v_dtefollow,
                   amtheal    = v_amtheal,
                   coduser    = 'CONVERT',
                   dteupd     = sysdate,
                   codcomphf  = p_codcomp
             where codempid   = v_codempid
               and dteyear    = p_dteyear
               and codprgheal = v_codprgheal;
          end;
          if v_check_bool then
            begin
              insert into thealinf2
                          (codempid, dteyear, codprgheal,
                          codheal, descheck, chkresult, descheal,
                          dtecreate, codcreate, coduser)
                  values (v_codempid, p_dteyear, v_codprgheal,
                          v_codheal, v_descheck, v_chkresul, v_desheal,
                          sysdate, global_v_coduser, 'CONVERT');
            exception when dup_val_on_index then
              update thealinf2
                 set descheck   = v_descheck,
                     chkresult  = v_chkresul,
                     descheal   = v_desheal,
                     coduser    = 'CONVERT',
                     dteupd     = sysdate
               where codempid   = v_codempid
                 and dteyear    = p_dteyear
                 and codprgheal = v_codprgheal
                 and codheal    = v_codheal;
            end;
            if v_check_bool then
              for j in c1 loop
                begin
                  insert into thealinf
                              (dteyear, codcomp, codprgheal,
                              codcln, dteheal, amtheal,
                              namdoc, numcert, namdoc2, numcert2,
                              dtecreate, codcreate, coduser)
                      values (p_dteyear, p_codcomp, v_codprgheal,
                              p_codcln, v_dteheal, j.amtheal,
                              null, null, null, null,
                              sysdate, global_v_coduser, 'CONVERT');
                exception when dup_val_on_index then
                  null;
                end;
              end loop;
              v_num_success     := v_num_success + 1;
            end if;
          end if;
          if v_msg is null then
            v_msg             := get_error_msg_php('HR2401', global_v_lang);
          --<<User37 #6807 06/09/2021
          else
            v_error           := 'Y';
          -->>User37 #6807 06/09/2021
          end if;
          v_msg             := hcm_util.get_string_t(json_object_t(get_response_message(null, v_msg, global_v_lang)), 'response');
        else
          v_error           := 'Y';
        end if;

        --<<User37 #6807 06/09/2021
        if v_error = 'Y' then
          v_num := nvl(v_num,0) +1;
          obj_detail      := json_object_t();
          obj_detail.put('coderror', '200');
          obj_detail.put('codempid', v_codempid);
          obj_detail.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
          obj_detail.put('desc_error', v_msg);
          obj_detail.put('row_error', i + 2);

          obj_table.put(v_num-1, obj_detail);
        end if;
        v_error := 'N';
        /*obj_detail      := json_object_t();
        obj_detail.put('coderror', '200');
        obj_detail.put('codempid', v_codempid);
        obj_detail.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
        obj_detail.put('desc_error', v_msg);

        obj_table.put(i, obj_detail);*/
        -->>User37 #6807 06/09/2021
      end if;
    end loop;
    if param_msg_error is null then
      param_msg_error   := get_error_msg_php('HR2715', global_v_lang);
      obj_result        := json_object_t(get_response_message(null, param_msg_error, global_v_lang));
      obj_result.put('rec_tran', v_num_success);
      obj_result.put('rec_err', (obj_data.get_size - v_num_success));
      obj_result.put('table', obj_table);
      commit;
      json_str_output := obj_result.to_clob;
    else
      rollback;
      --json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      --obj_result        := json_object_t(get_response_message('400', param_msg_error, global_v_lang));
    end if;
    --User37 #6807 06/09/2021 json_str_output := obj_result.to_clob;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end data_process;
end HRBFA7B;

/

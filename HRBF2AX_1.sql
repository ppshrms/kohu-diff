--------------------------------------------------------
--  DDL for Package Body HRBF2AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF2AX" as

  procedure initial_value(json_str_input in clob) as
    json_obj    json;
  begin
    json_obj            := json(json_str_input);

    -- global
    global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
    global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');

    p_dteyear           := hcm_util.get_string(json_obj, 'p_dteyear');
    p_codcomp           := hcm_util.get_string(json_obj, 'p_codcomp');
    p_codempid          := hcm_util.get_string(json_obj, 'p_codempid');
    p_dtestrt           := hcm_util.get_string(json_obj, 'p_dtestrt');
    p_dteend            := hcm_util.get_string(json_obj, 'p_dteend');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_header(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_header(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_header;

  procedure gen_header(json_str_output out clob) as
      obj_row           json := json ();
      v_daybfst         varchar2(2 char);
      v_mthbfst         varchar2(2 char);
      v_daybfen         varchar2(2 char);
      v_mthbfen         varchar2(2 char);
      v_format_date     varchar2(10 char) := 'dd/mm/yyyy';
      v_codcomp         temploy1.codcomp%type;
      v_dteyear         varchar2(4 char);
  begin
      if p_codempid is not null then
        begin
            select codcomp
              into v_codcomp
              from temploy1
             where codempid = p_codempid;
        end;
      else
        v_codcomp := p_codcomp;
      end if;
      begin
        select  daybfst, mthbfst, daybfen, mthbfen
          into 	v_daybfst, v_mthbfst, v_daybfen, v_mthbfen
          from 	tcontrbf
         where 	codcompy = get_codcompy(get_compful(v_codcomp))
           and 	dteeffec = (select max(dteeffec)
                              from tcontrbf
                             where codcompy = get_codcompy(get_compful(v_codcomp))
                               and dteeffec <= to_date(to_char(sysdate,v_format_date),v_format_date)
                            );
      exception when no_data_found then
            v_daybfst := null;
            v_mthbfst := null;
            v_daybfen := null;
            v_mthbfen := null;
      end;
      if to_number(v_mthbfen) < to_number(v_mthbfst) then
        v_dteyear := to_number(p_dteyear) + 1;
      else
        v_dteyear := p_dteyear;
      end if;

      if not (v_daybfst is null or v_mthbfst is null or v_daybfen is null or  v_mthbfen is null) then
          obj_row.put('dtebfst', lpad(v_daybfst,2,'0')||'/'||lpad(v_mthbfst,2,'0')||'/'||p_dteyear);
          obj_row.put('dtebfen', lpad(v_daybfen,2,'0')||'/'||lpad(v_mthbfen,2,'0')||'/'||v_dteyear);
      end if;
      obj_row.put('coderror', '200');
      dbms_lob.createtemporary(json_str_output, true);
      obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_header;

  procedure get_table(json_str_input in clob, json_str_output out clob) as
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

  procedure gen_table(json_str_output out clob) as
    obj_row              json    := json();
    obj_data             json;
    v_format_date        varchar2(10 char) := 'dd/mm/yyyy';
    v_rcnt               number  := 1;
    v_count_tcenter      number;
    v_count_temploy1     number;
    v_flg_exist          boolean := false;
    v_flg_secure         boolean := false;
    v_flg_permission     boolean := false;
    v_codempid           taccmlog.codempid%type;
    v_dteedit            taccmlog.dteedit%type;
    v_fldedit            taccmlog.fldedit%type;
    v_desold             taccmlog.desold%type;
    v_desnew             taccmlog.desnew%type;
    v_namimage           tempimge.namimage%type;

    cursor c1 is
        select b.codempid, dteedit, fldedit, desold, desnew, b.coduser, dteyre, dtemonth, typamt, typrelate
          from temploy1 a, taccmlog b
         where a.codempid = b.codempid
           and trunc(dteedit) between to_date(p_dtestrt, v_format_date) and to_date(p_dteend, v_format_date)
           and dteyre = p_dteyear
           and ( (p_codempid is null and codcomp like p_codcomp||'%') or
                 (p_codcomp  is null and b.codempid = p_codempid) )
      order by b.codempid, dteedit;

  begin
    -- validate date input
    if to_date(p_dteend, v_format_date) < to_date(p_dtestrt, v_format_date) then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    if p_codcomp is not null then
        -- check codcomp exist in tcenter
        begin
            select count(codcomp)
              into v_count_tcenter
              from tcenter
             where codcomp like p_codcomp||'%'
               and rownum = 1;
        end;
        if v_count_tcenter = 0 then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
    elsif p_codempid is not null then
        -- check codempid exist in temploy1
        begin
            select count(codempid)
              into v_count_temploy1
              from temploy1
             where codempid = p_codempid;
        end;
        if v_count_temploy1 = 0 then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
    end if;

    -- check exist by search condition
    for r1 in c1 loop
        v_flg_exist := true;
        exit;
    end loop;

    if not v_flg_exist then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TACCMLOG');
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;

    if p_codcomp is not null then
       -- secur_main.secur7
       v_flg_secure := secur_main.secur7(p_codcomp, global_v_coduser);
       if not v_flg_secure then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
          return;
       end if;
    end if;

    for r1 in c1 loop
       -- secur_main.secur2
       v_flg_secure := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
       if v_flg_secure then
          v_flg_permission := true;
          begin
             select  namimage
               into  v_namimage
               from  tempimge
              where  codempid = r1.codempid;
            exception when no_data_found then
                v_namimage := r1.codempid;
          end;
          obj_data := json();
          obj_data.put('namimge', v_namimage);
          obj_data.put('codempid', r1.codempid);
          obj_data.put('namemp', get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('dteedit', to_char(r1.dteedit, v_format_date));
          obj_data.put('dtaupd', get_tcoldesc_name('TACCMEXP', r1.fldedit, global_v_lang));
          if r1.fldedit = 'DTEYRE' then
             obj_data.put('old', r1.desold + hcm_appsettings.get_additional_year);
             obj_data.put('new', r1.desnew + hcm_appsettings.get_additional_year);
          elsif r1.fldedit = 'DTEMONTH' then
             obj_data.put('old', get_tlistval_name('NAMMTHFUL', r1.desold, global_v_lang));
             obj_data.put('new', get_tlistval_name('NAMMTHFUL', r1.desnew, global_v_lang));
          elsif r1.fldedit = 'TYPAMT' then
             obj_data.put('old', get_tlistval_name('TYPAMT', r1.desold, global_v_lang));
             obj_data.put('new', get_tlistval_name('TYPAMT', r1.desnew, global_v_lang));
          elsif r1.fldedit = 'TYPRELATE' then
             obj_data.put('old', get_tlistval_name('TTYPRELATE', r1.desold, global_v_lang));
             obj_data.put('new', get_tlistval_name('TTYPRELATE', r1.desnew, global_v_lang));
          elsif r1.fldedit = 'AMTSUMIN' or r1.fldedit = 'AMTWIDRWT' then
             obj_data.put('old', to_char(r1.desold, 'fm9,999,999,990.00'));
             obj_data.put('new', to_char(r1.desnew, 'fm9,999,999,990.00'));
          elsif r1.fldedit = 'DTEULAST' then
             obj_data.put('old', get_display_date(substr(r1.desold, 1, 10), 1));
             obj_data.put('new', get_display_date(substr(r1.desnew, 1, 10), 1));
          else
             obj_data.put('old', r1.desold);
             obj_data.put('new', r1.desnew);
          end if;
          obj_data.put('coduser', r1.coduser);
          obj_row.put(to_char(v_rcnt-1),obj_data);
          v_rcnt := v_rcnt + 1;
          end if;
    end loop;

    if not v_flg_permission and v_flg_exist then
       param_msg_error := get_error_msg_php('HR3007',global_v_lang);
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
     param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
     json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_table;

end HRBF2AX;


/

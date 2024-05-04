--------------------------------------------------------
--  DDL for Package Body HRBF5MX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF5MX" AS

  procedure initial_value(json_str_input in clob) as
   json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomp         := hcm_util.get_string(json_obj,'p_codcomp');
        p_codlon          := hcm_util.get_string(json_obj,'p_codlon');

  end initial_value;

  procedure check_index as
    v_temp     varchar(1 char);
  begin
    if p_codcomp is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
    end;

--  check secur7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

    if p_codlon is not null then
        begin
            select 'X' into v_temp
            from ttyploan
            where codlon = p_codlon;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttyploan');
            return;
        end;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_data        json;
    obj_rows        json;
    v_row           number := 0;
    v_chk_secur     boolean := false;
    v_count         number := 0;
    v_row_secur     number := 0;
    v_total_amtlon      tloaninf.amtlon%type := 0;
    v_total_amtnpfin    tloaninf.amtnpfin%type := 0;
    v_total_amtintovr   tloaninf.amtintovr%type := 0;
    v_total_sum_amtlon      tloaninf.amtlon%type := 0;
    v_total_sum_amtnpfin    tloaninf.amtnpfin%type := 0;
    v_total_sum_amtintovr   tloaninf.amtintovr%type := 0;
    v_codlon            tloaninf.codlon%type;

    cursor cb is
        select distinct codlon,get_ttyplone_name(codlon,102) as codlon_desc
          from tloaninf
         where codcomp like p_codcomp || '%'
           and codlon = nvl(p_codlon,codlon)
           and (nvl(amtnpfin,0) > 0 or nvl(amtintovr,0) > 0)
      order by codlon;

    cursor c1 is
        select numcont,codempid,codcomp,codlon,dtelonst,amtlon,amtnpfin,amtintovr
        from tloaninf
        where codcomp like p_codcomp || '%'
          and codlon = v_codlon
          and (nvl(amtnpfin,0) > 0 or nvl(amtintovr,0) > 0)
        order by codlon,numcont,codempid;
  begin

    obj_rows := json();
    for ib in cb loop
        v_codlon := ib.codlon;
        if p_codlon is null then
            v_row := v_row + 1;
            obj_data  := json();
            obj_data.put('image','');
            obj_data.put('codempid',ib.codlon_desc);
            obj_data.put('emp_name','');
            obj_data.put('numcont','');
            obj_data.put('dtelonst','');
            obj_data.put('amtlon','');
            obj_data.put('amtnpfin','');
            obj_data.put('amtintovr','');
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
        for i in c1 loop
            v_count := v_count+1;
            v_chk_secur := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if v_chk_secur then
                v_row := v_row + 1;
                v_row_secur := v_row_secur+1;
                obj_data  := json();
                obj_data.put('image',i.codempid);
                obj_data.put('codempid',get_emp_img(i.codempid));
                obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('numcont',i.numcont);
                obj_data.put('dtelonst',to_char(i.dtelonst,'dd/mm/yyyy'));
                obj_data.put('amtlon',i.amtlon);
                obj_data.put('amtnpfin',i.amtnpfin);
                obj_data.put('amtintovr',i.amtintovr);
                obj_rows.put(to_char(v_row-1),obj_data);
                v_total_amtlon   :=  v_total_amtlon + i.amtlon;
                v_total_amtnpfin := v_total_amtnpfin + i.amtnpfin;
                v_total_amtintovr  := v_total_amtintovr + i.amtintovr;
            end if;
        end loop;

        v_row := v_row + 1;
        obj_data  := json();
        obj_data.put('image','');
        obj_data.put('codempid','');
        obj_data.put('emp_name','');
        obj_data.put('numcont','');
        obj_data.put('dtelonst',get_label_name('HRBF5MX',global_v_lang,120));
        obj_data.put('amtlon',v_total_amtlon);
        obj_data.put('amtnpfin',v_total_amtnpfin);
        obj_data.put('amtintovr',v_total_amtintovr);
        obj_rows.put(to_char(v_row-1),obj_data);

        v_total_sum_amtlon := v_total_sum_amtlon + v_total_amtlon;
        v_total_sum_amtnpfin := v_total_sum_amtnpfin + v_total_amtnpfin;
        v_total_sum_amtintovr := v_total_sum_amtintovr + v_total_amtintovr;

        v_total_amtlon :=  0;
        v_total_amtnpfin := 0;
        v_total_amtintovr := 0;
    end loop;
    if p_codlon is null then
        v_row := v_row + 1;
        obj_data  := json();
        obj_data.put('image','');
        obj_data.put('codempid','');
        obj_data.put('emp_name','');
        obj_data.put('numcont','');
        obj_data.put('dtelonst',get_label_name('HRBF5MX',global_v_lang,130));
        obj_data.put('amtlon',v_total_sum_amtlon);
        obj_data.put('amtnpfin',v_total_sum_amtnpfin);
        obj_data.put('amtintovr',v_total_sum_amtintovr);
        obj_rows.put(to_char(v_row-1),obj_data);
    end if;

    if  v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tloaninf');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if v_count != 0 and v_row_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    else
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end if;
  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index;

END HRBF5MX;

/

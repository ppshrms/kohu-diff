--------------------------------------------------------
--  DDL for Package Body HRAL4HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL4HX" as

  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj        := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
  if param_msg_error is null then
    gen_index(json_str_output);
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure check_index as
  begin
    if p_dtestr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_dteend is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_dtestr > p_dteend then
        param_msg_error := get_error_msg_php('HR2032',global_v_lang);
        return;
    end if;
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
    json_obj json_object_t;
    json_row json_object_t;
    v_codempid      varchar2(4000 char);
    v_r_codempid    varchar2(4000 char);
    v_codcomp       varchar2(4000 char);
    v_r_codcomp     varchar2(4000 char);
    v_lvlst         number;
    v_lvlen         number;
    v_namcentlvl    varchar2(4000 char);
    v_namcent       varchar2(4000 char);
    v_count         number := 0;
    v_codpos        varchar2(4000 char);
    v_qtyo          number:=0;
    v_s_qtyo        number:=0;
    v_flg_data      varchar2(100 char) := 'N';
    v_secur3        varchar2(4000 char);
    v_zupdsal       varchar2(4000 char);
    v_comlevel      tcenter.comlevel%type;
    cursor c1 is
        select  codcomp,codempid,dtework,sum(qtyleave) qtyo
        from    tovrtime
        where   dtework between p_dtestr and p_dteend
        and     codcomp like p_codcomp||'%'
        and     qtyleave > 0
        group by codempid,dtework,codcomp
        order by codcomp,codempid,dtework;
  begin
    for r1 in c1 loop
        v_flg_data := 'Y';
        exit;
    end loop;
    if v_flg_data like 'N' then
        -- no data found
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tovrtime');
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        return;
    end if;
    v_flg_data := 'N';
    json_obj := json_object_t();
    for r1 in c1 loop
        if secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,
                                        global_v_zwrklvl,v_zupdsal) then
            v_flg_data := 'Y';
            v_codempid := r1.codempid;
            v_codcomp  := r1.codcomp;
            if v_r_codempid is null then
                v_r_codempid := v_codempid;
            end if;
            if  (v_codempid <> v_r_codempid)
            or  (v_codcomp <> v_r_codcomp and v_r_codcomp is not null)
            then
                json_row := json_object_t();
                json_row.put('flgskip', 'Y');
                json_row.put('desc_codpos'   ,get_label_name('HRAL4HX',global_v_lang,'110'));
                json_row.put('qtyo'     ,hcm_util.convert_minute_to_hour(v_qtyo));
                v_qtyo := 0;
                json_row.put('coderror' , '200');
                json_obj.put(to_char(v_count),json_row);
                v_count := v_count + 1;
                v_r_codempid := v_codempid;
            end if;

            json_row := json_object_t();
            v_qtyo := v_qtyo + r1.qtyo;
            v_s_qtyo := v_s_qtyo + r1.qtyo;
            json_row.put('image',get_emp_img(r1.codempid));
            json_row.put('codempid',r1.codempid);
            json_row.put('codcomp',r1.codcomp);
            json_row.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            begin
                select  codpos
                into    v_codpos
                from    temploy1
                where   codempid = r1.codempid;
                json_row.put('codpos'        ,v_codpos);
                json_row.put('desc_codpos'   ,get_tpostn_name(v_codpos,global_v_lang));
            exception when others then
                null;
            end;
            json_row.put('dtework'       ,to_char(r1.dtework,'dd/mm/yyyy'));
            json_row.put('qtyo'     ,hcm_util.convert_minute_to_hour(r1.qtyo));
            json_row.put('coderror'      , '200');
            json_obj.put(to_char(v_count),json_row);
            v_count := v_count + 1;
        end if;
    end loop;
    if v_flg_data like 'N' then
        -- no data found
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        return;
    end if;
    json_row := json_object_t();
    json_row.put('flgskip', 'Y');
    json_row.put('desc_codpos'   ,get_label_name('HRAL4HX',global_v_lang,'110'));
    json_row.put('qtyo'     ,hcm_util.convert_minute_to_hour(v_qtyo));
    v_qtyo := 0;
    json_row.put('coderror' , '200');
    json_obj.put(to_char(v_count),json_row);
    v_count := v_count + 1;
    json_row := json_object_t();
    json_row.put('flgskip', 'Y');
    json_row.put('desc_codpos'   ,get_label_name('HRAL4HX',global_v_lang,'120'));
    json_row.put('qtyo'     ,hcm_util.convert_minute_to_hour(v_s_qtyo));
    v_qtyo := 0;
    json_row.put('coderror' , '200');
    json_obj.put(to_char(v_count),json_row);
		json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

end HRAL4HX;

/

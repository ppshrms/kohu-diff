--------------------------------------------------------
--  DDL for Package Body HRAP27X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP27X" is
-- last update: 25/08/2020 20:48

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index

    b_index_dteyear     := to_number(hcm_util.get_string_t(json_obj,'p_dteyear'));
    b_index_numtime     := to_number(hcm_util.get_string_t(json_obj,'p_numtime'));
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codincom    := hcm_util.get_string_t(json_obj,'p_codincom');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index(json_str_output);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	boolean; 
    v_zupdsal   	varchar2(4);
    v_chk           number;
    v_amtincod      number;
    v_amtadj        number;
    v_amtincnw      number;
    v_percent       number;

    cursor c1 is
        select b.codcomp,b.codempid,b.numlvl,b.amtincod,b.amtadj,b.amtincnw,
               b.dteyreap,b.numtime,b.codcomadj,b.codincom
          from ttemadj1 a, ttemadj2 b
         where a.dteyreap = b.dteyreap
           and a.numtime = b.numtime
           and a.codcomadj = b.codcomadj
           and a.codincom = b.codincom
           and a.dteyreap = b_index_dteyear
           and a.numtime = b_index_numtime
           and a.codincom = b_index_codincom
           and a.codcomadj like b_index_codcomp||'%'
        order by b.codcomp,b.codempid;
  begin
    obj_row := json_object_t();


    for i in c1 loop
        v_flgdata := 'Y';

        flgpass := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('number',v_rcnt);
            obj_data.put('image', get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            if v_zupdsal = 'Y' then 
                v_amtincod  := stddec(i.amtincod,i.codempid,v_chken);
                v_amtadj    := stddec(i.amtadj,i.codempid,v_chken);
                v_amtincnw  := stddec(i.amtincnw,i.codempid,v_chken);
                if v_amtincod = 0 then
                    v_amtincod  := null;
                end if;
                if v_amtadj = 0 then
                    v_amtadj  := null;
                end if;
                v_percent   := (v_amtadj/v_amtincod)*100;
                obj_data.put('amtincod',nvl(v_amtincod,0));
                obj_data.put('amt_percent',to_char(nvl(v_percent,0),'fm999,999,990.00'));
                obj_data.put('amtadj',nvl(v_amtadj,0));
                obj_data.put('amtincnw',nvl(v_amtincnw,0));
            else
                obj_data.put('amtincod','');
                obj_data.put('amt_percent','');
                obj_data.put('amtadj','');
                obj_data.put('amtincnw','');
            end if;
            obj_data.put('dteyreap',i.dteyreap);
            obj_data.put('numtime',i.numtime);
            obj_data.put('codcomadj',i.codcomadj);
            obj_data.put('codincom',i.codincom);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttemadj2');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --
  procedure check_index(json_str_output out clob) is
    v_chk           varchar2(1);
    v_codincom1     tcontpms.codincom1%type;
    v_codincom2     tcontpms.codincom2%type;
    v_codincom3     tcontpms.codincom3%type;
    v_codincom4     tcontpms.codincom4%type;
    v_codincom5     tcontpms.codincom5%type;
    v_codincom6     tcontpms.codincom6%type;
    v_codincom7     tcontpms.codincom7%type;
    v_codincom8     tcontpms.codincom8%type;
    v_codincom9     tcontpms.codincom9%type;
    v_codincom10    tcontpms.codincom10%type;
  begin
    begin
        select 'Y'
          into v_chk
          from tinexinf
         where codpay = b_index_codincom
           and typpay = 1;
    exception when no_data_found then 
        v_chk := 'N';
    end;
    if v_chk = 'N' then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tinexinf');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
    if b_index_codcomp is not null and v_chk = 'Y' then
        --PY0040
        begin
            select 'Y'
              into v_chk
              from tinexinfc
             where codcompy = hcm_util.get_codcomp_level(b_index_codcomp,1) 
               and codpay = b_index_codincom
               and rownum = 1;
        exception when no_data_found then
            v_chk := 'N';
        end;
        if v_chk = 'N' then
          param_msg_error := get_error_msg_php('PY0044', global_v_lang, 'tinexinfc');
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;
        --HR2010
        if v_chk = 'Y' then
            begin
                select codincom1,codincom2,codincom3,codincom4,codincom5,
                       codincom6,codincom7,codincom8,codincom9,codincom10
                  into v_codincom1,v_codincom2,v_codincom3,v_codincom4,v_codincom5,
                       v_codincom6,v_codincom7,v_codincom8,v_codincom9,v_codincom10
                  from tcontpms
                 where codcompy = hcm_util.get_codcomp_level(b_index_codcomp,1) 
                   and trunc(dteeffec) = (select trunc(max(dteeffec))
                                            from tcontpms
                                           where codcompy = hcm_util.get_codcomp_level(b_index_codcomp,1) 
                                             and trunc(dteeffec) <= trunc(sysdate));
            exception when no_data_found then
                null;
            end;
            if b_index_codincom = v_codincom1 or 
               b_index_codincom = v_codincom2 or 
               b_index_codincom = v_codincom3 or 
               b_index_codincom = v_codincom4 or 
               b_index_codincom = v_codincom5 or 
               b_index_codincom = v_codincom6 or 
               b_index_codincom = v_codincom7 or 
               b_index_codincom = v_codincom8 or 
               b_index_codincom = v_codincom9 or 
               b_index_codincom = v_codincom10 then
              null;
            else
              param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcontpms');
              json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            end if;
        end if;
    end if;
  end;
  --
end;

/

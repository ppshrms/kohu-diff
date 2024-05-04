--------------------------------------------------------
--  DDL for Package Body HRTR6GX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR6GX" is
-- last update: 09/02/2021 19:25
 procedure initial_value (json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
    global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');

    -- save index
    p_codcomp        := (hcm_util.get_string(json_obj, 'p_codcomp'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  ----------------------------------------------------------------------------------
  procedure check_index is
    v_flgsecu2        boolean := false;
  begin
    if p_codcomp is not null then
      v_flgsecu2 := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_flgsecu2 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang, 'codcomp');
        return;
      end if;
    end if;
  end check_index;
  ----------------------------------------------------------------------------------
  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
----------------------------------------------------------------------------------
  procedure gen_index(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    v_permis           boolean := false;
    flgpass            boolean := false;
    v_flg_exist        boolean := false;

    cursor c1 is
            select  c.codimage, a.codempid, a.codcours, a.dtetrst, a.dtecomexp, a.descommt, a.descommtn, b.codcomp,
                    a.dteyear, a.numclseq --User37 #3275 4. TR Module 26/04/2021 
            from thistrnn a, temploy1 b, tempimge c
            where a.codcomp like nvl(p_codcomp||'%',a.codcomp)
            and a.codempid = b.codempid
            and c.codempid = a.codempid
            and a.flgcommt = 'Y'
            and a.dtecomexp >= trunc(sysdate)
            order by b.codempid, a.codcours, a.dtetrst;
  begin
    obj_row     := json();
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;

    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'thistrnn');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    for r1 in c1 loop
        flgpass	:= secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
           if flgpass then
              v_permis := true;
              v_rcnt      := v_rcnt+1;
              obj_data    := json();

              obj_data.put('coderror', '200');

              obj_data.put('codimage', get_emp_img (r1.codempid));
              obj_data.put('codempid', r1.codempid);
              obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
              obj_data.put('codcours', r1.codcours);
              obj_data.put('desc_codcours', get_tcourse_name(r1.codcours, global_v_lang));
              obj_data.put('descommt', r1.descommt);
              obj_data.put('descommtn', r1.descommtn);
              obj_data.put('dtetrst', to_char(r1.dtetrst, 'dd/mm/yyyy'));
              obj_data.put('dtecomexp', to_char(r1.dtecomexp, 'dd/mm/yyyy'));
              --<<User37 #3275 4. TR Module 26/04/2021 
              obj_data.put('dteyear', r1.dteyear);
              obj_data.put('numclseq', r1.numclseq);
              -->>User37 #3275 4. TR Module 26/04/2021 

              obj_row.put(to_char(v_rcnt-1),obj_data);
           end if;
    end loop;

    if not v_permis then
       param_msg_error := get_error_msg_php('HR3007',global_v_lang);
       json_str_output := get_response_message('403',param_msg_error,global_v_lang);
       return;
    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_index;
----------------------------------------------------------------------------------

end HRTR6GX;

/

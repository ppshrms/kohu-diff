--------------------------------------------------------
--  DDL for Package Body HRRC72X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC72X" is
-- last update: 20/01/2021 22:10
 procedure initial_value (json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
    global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');
    v_chken             := hcm_secur.get_v_chken;

    p_codcomp        := (hcm_util.get_string(json_obj, 'p_codcomp'));
    p_dtestrt        := (hcm_util.get_string(json_obj, 'p_dtestrt'));
    p_dteend         := (hcm_util.get_string(json_obj, 'p_dteend'));
    p_numappl        := (hcm_util.get_string(json_obj, 'p_numappl'));
    p_codempid       := (hcm_util.get_string(json_obj, 'p_codempid_query'));

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
    obj_data           json;
    obj_row            json;
    v_rcnt             number := 0;
    v_permis           boolean := false;
    flgpass            boolean := false;
    v_flg_exist        boolean := false;

    cursor c1 is
            select  t.codempid, t.numappl, t.dteempmt, t.codpos, t.codcomp, (t.numappl) v_numappl
            from temploy1 t
            where t.codcomp like nvl(p_codcomp||'%',t.codcomp)
            and t.dteempmt between  to_date(p_dtestrt,'dd/mm/yyyy') and  to_date(p_dteend,'dd/mm/yyyy')
            and t.staemp in ('0','1')
            order by t.dteempmt  , t.numappl ;
  begin
    obj_row     := json();

    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;

    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
           if flgpass then
              v_permis := true;
              v_rcnt      := v_rcnt+1;
              obj_data    := json();

              obj_data.put('coderror', '200');

              obj_data.put('dtestrt', to_char(r1.dteempmt, 'dd/mm/yyyy'));
              obj_data.put('numreg', r1.v_numappl);
              obj_data.put('codnumreg', r1.numappl);
              obj_data.put('image', get_emp_img (r1.codempid));
              obj_data.put('codempid', r1.codempid);
              obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
              obj_data.put('position', get_tpostn_name(r1.codpos, global_v_lang));

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
procedure get_tapplcfm_table(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tapplcfm_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tapplcfm_table;
----------------------------------------------------------------------------------
  procedure gen_tapplcfm_table(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;

    cursor c1 is
            select * from tapplcfm
            unpivot (
             (codincome_value, unitcal_value, amtincom_value) for codincome
            in (
             (codincom1,unitcal1,amtincom1) as '1',(codincom2,unitcal2,amtincom2) as '2', (codincom3,unitcal3,amtincom3) as '3',
             (codincom4,unitcal4,amtincom4) as '4',(codincom5,unitcal5,amtincom5) as '5', (codincom6,unitcal6,amtincom6) as '6',
             (codincom7,unitcal7,amtincom7) as '7',(codincom8,unitcal8,amtincom8) as '8', (codincom9,unitcal9,amtincom9) as '9',
             (codincom10,unitcal10,amtincom10) as '10'
              )
            )
            where  numappl  = p_numappl ;
  begin
    obj_row     := json();
    for r1 in c1 loop
              v_rcnt      := v_rcnt+1;
              obj_data    := json();
              obj_data.put('coderror', '200');
              obj_data.put('codincom', r1.codincome_value ||' - '|| get_tinexinf_name (r1.codincome_value, global_v_lang));
              obj_data.put('unit', get_tlistval_name('NAMEUNIT', r1.unitcal_value, global_v_lang));
              obj_data.put('qtymoney', stddec(r1.amtincom_value, p_codempid, v_chken));
              obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_tapplcfm_table;
----------------------------------------------------------------------------------
procedure get_tapplcfm_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       gen_tapplcfm_detail(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tapplcfm_detail;
----------------------------------------------------------------------------------
procedure gen_tapplcfm_detail (json_str_output out clob) is
    obj_data               json;
    v_codcurr              tapplcfm.codcurr%type     := '';
    v_amtsalpro            tapplcfm.amtsalpro%type   := '';

  begin
    begin
      select a.codcurr,  a.amtsalpro
      into   v_codcurr,  v_amtsalpro
      from   tapplcfm a , temploy1 b , temploy3 c
      where  a.numappl = p_numappl
      and   a.numappl  = b.numappl
      and   b.codempid = c.codempid
      and   a.numreqc  = b.numreqst
      and   a.codposc  = b.codpos ;

    exception when no_data_found then
          null;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('codcurr', v_codcurr);
    obj_data.put('desc_codcurr', v_codcurr || ' - ' || get_tcodec_name ('TCODCURR', v_codcurr, global_v_lang));
    obj_data.put('amtsalpro', to_char(stddec(v_amtsalpro, p_codempid, v_chken ),'fm999,999,990.00'));
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_tapplcfm_detail;
----------------------------------------------------------------------------------
procedure get_welfare(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_welfare(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_welfare;
----------------------------------------------------------------------------------
  procedure gen_welfare(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;

    cursor c1 is
            select a.welfare from tapplcfm a , temploy1 b , temploy3 c
            where  a.numappl = p_numappl
            and   a.numappl  = b.numappl
            and   b.codempid = c.codempid
            and   a.numreqc  = b.numreqst
            and   a.codposc  = b.codpos ;
  begin
    obj_row     := json();
    for r1 in c1 loop
              v_rcnt      := v_rcnt+1;
              obj_data    := json();
              obj_data.put('coderror', '200');
              obj_data.put('welfare', r1.welfare);
              obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_welfare;
----------------------------------------------------------------------------------

end HRRC72X;

/

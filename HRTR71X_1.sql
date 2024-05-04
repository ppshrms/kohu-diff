--------------------------------------------------------
--  DDL for Package Body HRTR71X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR71X" AS
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

    p_codcompy          := hcm_util.get_string_t(json_obj, 'p_codcompy');
    p_dteyearst         := to_number(hcm_util.get_number_t(json_obj, 'p_dteyearst'));
    p_dteyearen         := to_number(hcm_util.get_number_t(json_obj, 'p_dteyearen'));
    p_codcours          := hcm_util.get_string_t(json_obj, 'p_codcours');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  function convert_numhour_to_minute (v_number number) return varchar2 is
  begin
    return (trunc(v_number) * 60) +  (mod(v_number, 1) * 100);
  end convert_numhour_to_minute;

  procedure check_index is
    v_codcompy        tcompny.codcompy%type;
    v_codcours        tcourse.codcours%type;
  begin
    if p_codcompy is not null then
      begin
        select codcompy
          into v_codcompy
          from tcompny
         where codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcompny');
        return;
      end;
      if not secur_main.secur7(p_codcompy, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_codcours is not null then
      begin
        select codcours
          into v_codcours
          from tcourse
         where codcours = p_codcours;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcourse');
        return;
      end;
    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  function get_count_passing (v_dteyear varchar2, v_codcours varchar2, v_numclseq varchar2) return number is
    v_count       number := 0;
  begin
    begin
      select count(codempid)
        into v_count
        from thistrnn
       where dteyear  = v_dteyear
         and codcomp  like p_codcompy || '%'
         and codcours = v_codcours
         and numclseq = v_numclseq
         and flgtrevl = 'P';
    exception when no_data_found then
      null;
    end;
    return v_count;
  end get_count_passing;

  procedure get_thisinst (v_dteyear varchar2, v_codcours varchar2, v_numclseq varchar2, v_codinst out varchar2, v_qtyscore out number) as
  begin
    begin
      select t1.codinst, t1.qtyscore
        into v_codinst, v_qtyscore
        from thisinst t1, tyrtrsch t2
       where t1.dteyear = v_dteyear
         and t1.dteyear = t2.dteyear
         and t2.codcompy = p_codcompy
         and t1.codcours = v_codcours
         and t1.codcours = t2.codcours
         and t1.numclseq = v_numclseq
         and t1.numclseq = t2.numclseq
         and rownum   = 1;
    exception when no_data_found then
      v_codinst         := '';
      v_qtyscore        := 0;
    end;
  end get_thisinst;

  function get_amtclbdg (v_dteyear varchar2, v_codcours varchar2, v_numclseq varchar2) return number is
    v_amtclbdg        number;
  begin
    begin
      select amtclbdg
        into v_amtclbdg
        from tyrtrsch
       where dteyear = v_dteyear
         and codcompy = p_codcompy
         and codcours = v_codcours
         and numclseq = v_numclseq;
    exception when no_data_found then
      null;
    end;
    return v_amtclbdg;
  end get_amtclbdg;

  procedure gen_index (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;
    v_codinst          thisinst.codinst%type;
    v_qtyscore         thisinst.qtyscore%type;

    cursor c1 is
      select dteyear, dtemonth, codcours, numclseq, dtetrst, dtetren, codhotel, codinsts, codresp, qtytrmin, qtyppc, amttotexp, avgscore
        from thisclss
       where codcompy = p_codcompy
         and codcours = nvl(p_codcours, codcours)
         and dteyear  between p_dteyearst and p_dteyearen
       order by dteyear, to_number(dtemonth), 
                codcours, ----
                numclseq;

  begin
    obj_row       := json_object_t();

    for i in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      get_thisinst(i.dteyear, i.codcours, i.numclseq, v_codinst, v_qtyscore);
      obj_data.put('coderror', '200');
      obj_data.put('codcompy', p_codcompy);
--      obj_data.put('codcours', i.codcours);
      obj_data.put('dteyear', i.dteyear);
      obj_data.put('dtemonth', get_tlistval_name('MONTH', i.dtemonth, global_v_lang));
      obj_data.put('codcours', i.codcours); ----
      obj_data.put('desc_codcours', get_tcourse_name(i.codcours, global_v_lang)); ----
      obj_data.put('numclseq', i.numclseq);
      obj_data.put('dtetrst', to_char(i.dtetrst, 'dd/mm/yyyy'));
      obj_data.put('dtetren', to_char(i.dtetren, 'dd/mm/yyyy'));
      obj_data.put('desc_codhotel', get_thotelif_name(i.codhotel, global_v_lang));
      obj_data.put('desc_codinsts', get_tinstitu_name(i.codinsts, global_v_lang));
      obj_data.put('desc_codinst', get_tinstruc_name(v_codinst, global_v_lang));
--      obj_data.put('qtytrmin', convert_numhour_to_minute(i.qtytrmin));
      obj_data.put('qtytrmin', to_char(i.qtytrmin));
      obj_data.put('qtyppc', i.qtyppc);
      obj_data.put('amttotexp', i.amttotexp);
      obj_data.put('amtclbdg', get_amtclbdg(i.dteyear, i.codcours, i.numclseq));
      obj_data.put('avgscore', i.avgscore);
      obj_data.put('qtyscore', v_qtyscore);
      obj_data.put('passing', get_count_passing(i.dteyear, i.codcours, i.numclseq));

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if obj_row.get_size > 0 then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'thisclss');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;
end HRTR71X;

/

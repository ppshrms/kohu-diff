--------------------------------------------------------
--  DDL for Package Body HRTR7LX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR7LX" AS
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

    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj, 'p_codpos');
    p_dteyear1          := to_number(hcm_util.get_number_t(json_obj, 'p_dteyear1'));
    p_dteyear2          := to_number(hcm_util.get_number_t(json_obj, 'p_dteyear2'));
    p_dteyear3          := to_number(hcm_util.get_number_t(json_obj, 'p_dteyear3'));

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  function convert_numhour_to_minute (v_number number) return varchar2 is
  begin
    return (trunc(v_number) * 60) +  (mod(v_number, 1) * 100);
  end convert_numhour_to_minute;

  procedure check_index is
    v_codcomp          temploy1.codcomp%type;
    v_codpos           tpostn.codpos%type;
    v_staemp           temploy1.staemp%type;
    v_zupdsal          varchar2(100 char);
  begin
    if p_codcomp is not null then
      begin
        select codcompy
          into v_codcomp
          from tcenter
         where codcomp = hcm_util.get_codcomp_level(p_codcomp, null, null, 'Y');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_codpos is not null then
      begin
        select codpos
          into v_codpos
          from tpostn
         where codpos = p_codpos;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tpostn');
        return;
      end;
    end if;
    if p_codempid is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is not null then
        if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
      end if;
    end if;
  end check_index;

  function get_avgscore (v_codempid temploy1.codempid%type) return number is
    v_qtycmp3         tappemp.qtycmp3%type := 0;
  begin
    begin
      select qtycmp3
        into v_qtycmp3
        from tappemp a
       where codempid = v_codempid
         and dteyreap <= to_number(to_char(sysdate, 'YYYY'))
         and numtime  = (select max(numtime)
                           from tappemp b
                          where codempid = a.codempid
                            and dteyreap = a.dteyreap)
       order by dteyreap desc, numtime desc
       fetch first row only;
    exception when no_data_found then
      null;
    end;
    return nvl(v_qtycmp3, 0);
  end get_avgscore;

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

  procedure gen_index (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;
    v_zupdsal          varchar2(100 char);
    v_data_found       boolean := false;

    cursor c1 is
      select codempid, codcomp, codpos
        from tidpplan a
       where codempid = nvl(p_codempid, codempid)
         and codcomp  like p_codcomp || '%'
         and codpos   = nvl(p_codpos, codpos)
         and dteyear  in (p_dteyear1, nvl(p_dteyear2, p_dteyear1), nvl(p_dteyear3, p_dteyear1))
       group by codempid, codcomp, codpos
       order by codempid, codcomp, codpos;

  begin
    obj_row       := json_object_t();

    for i in c1 loop
      v_data_found := true;
      if secur_main.secur2(i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('codcomp', i.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
        obj_data.put('codpos', i.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
        obj_data.put('avgscore', get_avgscore(i.codempid));
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if obj_row.get_size > 0 then
      json_str_output := obj_row.to_clob;
    else
      if v_data_found then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tidpplan');
      end if;
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;

  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
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

  procedure gen_detail (json_str_output out clob) AS
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_data_found        boolean := false;
    v_zupdsal           varchar2(100 char);
    v_flgeval           ttrimph.flgeval%type := 'U';

    cursor c1 is
      select codempid, codcomp, codpos, codtparg, dteyear, codcours, numclseq, dtetrst, dtetren, qtytrmin, amtcost, codinsts, codinst, codhotel, flgtrevl
        from thistrnn
       where dteyear  in (p_dteyear1, nvl(p_dteyear2, p_dteyear1), nvl(p_dteyear3, p_dteyear1))
         and codempid = p_codempid
       order by codcomp, codempid, codtparg, dteyear, codcours, numclseq;
  begin
    obj_row       := json_object_t();
    for i in c1 loop
      v_data_found  := true;
      if secur_main.secur2(i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        begin
          select flgeval
            into v_flgeval
            from ttrimph
          where dteyear  = i.dteyear
            and codcours = i.codcours
            and numclseq = i.numclseq
            and codempid = i.codempid;
        exception when no_data_found then
          v_flgeval := 'U';
        end;
        v_rcnt        := v_rcnt+1;
        obj_data      := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('codcomp', i.codcomp);
        obj_data.put('codpos', i.codpos);
        obj_data.put('codtparg', to_char(i.codtparg));
        obj_data.put('desc_codtparg', get_tlistval_name('TCODTPARG', i.codtparg, global_v_lang));
        obj_data.put('dteyear', to_char(i.dteyear));
        obj_data.put('codcours', i.codcours);
        obj_data.put('desc_codcours', get_tcourse_name(i.codcours, global_v_lang));
        obj_data.put('numclseq', i.numclseq);
        obj_data.put('dtetrst', to_char(i.dtetrst, 'dd/mm/yyyy'));
        obj_data.put('dtetren', to_char(i.dtetren, 'dd/mm/yyyy'));
        obj_data.put('qtytrmin', convert_numhour_to_minute(i.qtytrmin));
        obj_data.put('amtcost', nvl(i.amtcost, 0));
        obj_data.put('codinsts', i.codinsts);
        obj_data.put('desc_codinsts', get_tinstitu_name(i.codinsts, global_v_lang));
        obj_data.put('codinst', i.codinst);
        obj_data.put('desc_codinst', get_tinstruc_name(i.codinst, global_v_lang));
        obj_data.put('codhotel', i.codhotel);
        obj_data.put('desc_codhotel', get_thotelif_name(i.codhotel, global_v_lang));
        obj_data.put('flgtrevl', v_flgeval);
        obj_data.put('desc_flgtrevl', get_tlistval_name('FLGEVAL', v_flgeval, global_v_lang));
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if obj_row.get_size > 0 then
      json_str_output := obj_row.to_clob;
    else
      if v_data_found then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'thistrnn');
      end if;
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_detail;

  procedure get_detail_avglst (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_avglst(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail_avglst;

  function get_grdemp (v_codtency tidpcptc.codtency%type, v_codskill tidpcptc.codskill%type, v_dteyear tidpcptc.dteyear%type) return number is
    v_grdemp        tidpcptc.grdemp%type := 0;
  begin
    begin
      select grdemp
        into v_grdemp
        from tidpcptc a
       where codempid = p_codempid
         and dteyear  = v_dteyear
         and codtency = v_codtency
         and codskill = v_codskill;
    exception when no_data_found then
      null;
    end;
    return v_grdemp;
  end get_grdemp;

  procedure gen_detail_avglst (json_str_output out clob) AS
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1_group is
      select codtency, codskill, grade
        from tidpcptc
       where codempid = p_codempid
       group by codtency, codskill, grade
       order by codtency, codskill;

  begin
    obj_row       := json_object_t();
    for i in c1_group loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codtency', i.codtency);
      obj_data.put('desc_codtency', get_tcomptnc_name(i.codtency, global_v_lang));
      obj_data.put('codskill', i.codskill);
      obj_data.put('desc_codskill', get_tcodec_name('TCODSKIL', i.codskill, global_v_lang));
      obj_data.put('grade', i.grade);
      obj_data.put('grdemp1', get_grdemp(i.codtency, i.codskill, p_dteyear1));
      obj_data.put('grdemp2', get_grdemp(i.codtency, i.codskill, p_dteyear2));
      obj_data.put('grdemp3', get_grdemp(i.codtency, i.codskill, p_dteyear3));
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if obj_row.get_size > 0 then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tidpcptc');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_detail_avglst;
end HRTR7LX;

/

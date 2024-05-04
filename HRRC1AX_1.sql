--------------------------------------------------------
--  DDL for Package Body HRRC1AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC1AX" AS

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dtereqst    := to_date(hcm_util.get_string_t(json_obj,'p_dtereqst'),'dd/mm/yyyy');
    b_index_dtereqen    := to_date(hcm_util.get_string_t(json_obj,'p_dtereqen'),'dd/mm/yyyy');
    b_index_codemprc    := hcm_util.get_string_t(json_obj,'p_codemprc');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is

  begin
    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    else
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if b_index_dtereqst is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if b_index_dtereqen is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if b_index_dtereqen < b_index_dtereqst then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

    if b_index_codemprc is not null then
      begin
        select codempid into b_index_codemprc
          from temploy1
         where codempid = b_index_codemprc
           and staemp   in ('1','3');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'temploy1');
        return;
      end;
      if not secur_main.secur2(b_index_codemprc,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_secur         boolean;

    cursor c_treqest is
      select a.codemprc,a.numreqst,a.codcomp,b.codpos,b.dteopen,b.qtyreq ,a.stareq,b.qtyact,a.dtereq
        from treqest1 a, treqest2 b
       where a.numreqst = b.numreqst
         and a.codcomp  like b_index_codcomp||'%'
         and b.codemprc = nvl(b_index_codemprc,b.codemprc)
         and a.dtereq   between b_index_dtereqst and b_index_dtereqen
      order by a.codemprc,a.numreqst,a.codcomp,b.codpos;

  begin
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    obj_result := json_object_t();
    for i in c_treqest loop
        v_flgdata   := 'Y';
        v_secur     := secur_main.secur2(i.codemprc,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_secur then
            v_flgsecur  := 'Y';
            v_rcnt      := v_rcnt+1;
            obj_data    := json_object_t();

            obj_data.put('coderror', '200');
            obj_data.put('codemprc', i.codemprc);
            obj_data.put('desc_codemprc', get_temploy_name(i.codemprc,global_v_lang) );
            -- adj --<< user25 Date: 15/101/2021 #5115
            obj_data.put('numreqst', i.numreqst);
            obj_data.put('codpos', i.codpos);
            obj_data.put('codcomp', i.codcomp);
            -->> user25 Date: 15/101/2021 #5115
            obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp,global_v_lang) );
            obj_data.put('desc_codpos', get_tpostn_name(i.codpos,global_v_lang) );
--            obj_data.put('dtereq', to_char(i.dtereq,'dd/mm/yyyy')); --<< user25 Date:18/10/2021 #4206
--            obj_data.put('dtereq', hcm_util.get_date_buddhist_era(i.dtereq));--<< user25 Date:18/10/2021 #4206
            obj_data.put('dtereq', to_char(i.dteopen,'dd/mm/yyyy')); -- dateopen --<< user56
            obj_data.put('qtyreq', i.qtyreq);
            obj_data.put('desc_stareq', get_tlistval_name('TSTAREQ',i.stareq,global_v_lang));
            obj_data.put('qtyact', i.qtyact);
            obj_data.put('qtybal', nvl(i.qtyreq,0) - nvl(i.qtyact,0));

            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_flgdata = 'N' then
        param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'treqest1');
        json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecur = 'N' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
        json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

END HRRC1AX;

/

--------------------------------------------------------
--  DDL for Package Body HRRC2GX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC2GX" AS

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_mthpost     := hcm_util.get_string_t(json_obj,'p_mthpost');
    b_index_yrepost     := hcm_util.get_string_t(json_obj,'p_yrepost');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
  begin
    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end If;

    if b_index_mthpost is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if b_index_yrepost is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
  end;

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
  end;

  procedure gen_index (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_secur         boolean;
    v_qtyreq        number := 0;
    v_qtyact        number := 0;
    v_qtyapp        number := 0;

    cursor c_tjobpost is
      select numreqst,codpos,codjobpost,dtepost,codcomp,dteclose,welfare,flgtrans,amtpay,remark
        from tjobpost
       where codcomp  like b_index_codcomp||'%'
         and  to_char(dtepost,'mmyyyy') = lpad(b_index_mthpost,2,0)||b_index_yrepost
      order by codjobpost,codcomp,numreqst,codpos;

  begin
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    obj_result := json_object_t();

    for i in c_tjobpost loop
        v_flgdata   := 'Y';
        v_secur     := secur_main.secur7(i.codcomp, global_v_coduser);
        if v_secur then
            v_flgsecur  := 'Y';
            v_rcnt      := v_rcnt+1;
            obj_data    := json_object_t();

            obj_data.put('coderror', '200');
            obj_data.put('codjobpost', i.codjobpost );
            obj_data.put('desc_codjobpost', get_tcodec_name('TCODJOBPOST',i.codjobpost,global_v_lang) );
            obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp,global_v_lang) );
            obj_data.put('numreqst', i.numreqst);
            obj_data.put('dtepost', to_char(i.dtepost,'dd/mm/yyyy'));
            obj_data.put('codpos', i.codpos );
            obj_data.put('desc_codpos', get_tpostn_name(i.codpos,global_v_lang) );
            obj_data.put('amtpay', to_char(i.amtpay,'fm9,999,999,999.00'));

            begin
                select qtyreq,qtyact into v_qtyreq,v_qtyact
                 from treqest2
                where numreqst = i.numreqst
                  and codpos   = i.codpos;
            exception when no_data_found then
                v_qtyreq := null;
                v_qtyact := null;
            end;
            obj_data.put('qtyreq', nvl(v_qtyreq,0));
            obj_data.put('qtyact', nvl(v_qtyact,0));

            begin
                select count(*) into v_qtyapp
                 from tapplinf
                where numreqc = i.numreqst
                  and codposc = i.codpos;
            exception when no_data_found then
                v_qtyapp := null;
            end;
            obj_data.put('qtyapp', v_qtyapp);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_flgdata = 'N' then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tjobpost');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecur = 'N' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
        json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
END HRRC2GX;

/

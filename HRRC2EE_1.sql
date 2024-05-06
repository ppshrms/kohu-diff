--------------------------------------------------------
--  DDL for Package Body HRRC2EE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC2EE" AS

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

    b_index_dtepost     := to_date(hcm_util.get_string_t(json_obj,'p_dtepost'),'dd/mm/yyyy');
    p_codjobpost        := hcm_util.get_string_t(json_obj,'p_codjobpost');

--<<  #7262 || USER39 || 27/11/2021    
    if b_index_dtepost is not null then
        b_index_mthpost := null;
        b_index_yrepost := null;
    end if;
-->>  #7262 || USER39 || 27/11/2021     

    p_codcomp           := hcm_util.get_string_t(json_obj,'codcomp');
    p_dtepost           := to_date(hcm_util.get_string_t(json_obj,'dtepost'),'dd/mm/yyyy');

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

--<<  #7262 || USER39 || 27/11/2021    
    if  b_index_dtepost is not null then    
            b_index_mthpost := null;
            b_index_yrepost := null;    
    elsif b_index_dtepost is null then   
            if b_index_mthpost is not null or b_index_yrepost is not null then
                if b_index_mthpost is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    return;
                end if;
                if b_index_yrepost is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    return;
                end if;
            else
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return;
            end if;
    end if;
-->>  #7262 || USER39 || 27/11/2021 

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
    v_desc_stacard  varchar2(1000 char);
    v_stacard       varchar2(1000 char);
    v_flgdata       varchar2(1 char) := 'N';

    cursor c_tjobposte is
      select codjobpost,dtepost,codcomp,dtepay,amtpay,qtypos,remark
        from tjobposte
       where codcomp  like b_index_codcomp||'%'
         and ((b_index_mthpost is not null and to_char(dtepost,'mmyyyy') = lpad(b_index_mthpost,2,0)||b_index_yrepost)
             or (b_index_mthpost is null and dtepost = nvl(b_index_dtepost,dtepost) ) )
      order by dtepost;

  begin
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    for i in c_tjobposte loop
      v_flgdata   := 'Y';
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('dtepost', to_char(i.dtepost,'dd/mm/yyyy'));
      obj_data.put('codjobpost', i.codjobpost);
      obj_data.put('desc_codjobpost', get_tcodec_name('TCODJOBPOST',i.codjobpost,global_v_lang) );
      obj_data.put('dtepay', to_char(i.dtepay,'dd/mm/yyyy'));
      obj_data.put('remark', i.remark);
      obj_data.put('amtpay', to_char(i.amtpay,'fm9,999,999.00'));
      obj_data.put('qtypos', i.qtypos);
      obj_data.put('codcomp', i.codcomp);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_flgdata = 'N' then
        param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tjobposte');
        json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    else
        json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_reqjob(json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row		      number := 0;
    v_amtpay      number := 0;

    cursor c_tjobpost is
      select numreqst,codpos,codjobpost,dtepost,codcomp,dteclose,welfare,flgtrans,amtpay,remark
        from tjobpost
       where codcomp  like b_index_codcomp||'%'
         and dtepost  = b_index_dtepost
         and codjobpost = p_codjobpost
      order by dtepost,codcomp,numreqst;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for i in c_tjobpost loop
        v_row      := v_row + 1;
        obj_data := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('dtepost', to_char(i.dtepost,'dd/mm/yyyy'));
        obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp,global_v_lang) );
        obj_data.put('numreqst', i.numreqst);
        obj_data.put('desc_codpos', get_tpostn_name(i.codpos,global_v_lang) );
        if nvl(i.amtpay,0) <> 0 then
            obj_data.put('amtpay', i.amtpay);
        else
            begin
                select (amtpay / greatest(qtypos,0,1)) into v_amtpay
                  from tjobposte
                 where codjobpost = i.codjobpost
                   and dtepost    = i.dtepost
                   and codcomp    = i.codcomp;--#7761 Phase2 || 18/03/2022 || USER39
            exception when no_data_found then
                null;
            end;
            obj_data.put('amtpay', v_amtpay);
        end if;

        obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_reqjob;

  procedure post_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_index(json_str_input,json_str_output);
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    param_json_row  json_object_t;
    param_json      json_object_t;
    v_amtpay        number;
  begin
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
        p_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
        p_codjobpost    := hcm_util.get_string_t(param_json_row,'codjobpost');
        p_dtepost       := to_date(hcm_util.get_string_t(param_json_row,'postdte'),'dd/mm/yyyy');
        p_dtepay        := to_date(hcm_util.get_string_t(param_json_row,'paydte'),'dd/mm/yyyy');
        p_remark        := hcm_util.get_string_t(param_json_row,'desc_cost');
        p_amtpay        := to_number(replace(hcm_util.get_string_t(param_json_row,'amtmoney'),',',''));
        p_qtypos        := to_number(hcm_util.get_string_t(param_json_row,'amtposition'));
        check_insupd;
        if param_msg_error is null then
            v_amtpay := p_amtpay;
            if p_qtypos <> 0 then
                v_amtpay := (p_amtpay / p_qtypos);
            end if;
            update tjobposte set dtepay = p_dtepay,
                                 remark = p_remark,
                                 amtpay = p_amtpay,
                                 coduser = global_v_coduser
             where codjobpost = p_codjobpost
               and dtepost    = p_dtepost
               and codcomp    = p_codcomp;

            update tjobpost set amtpay = v_amtpay, coduser = global_v_coduser
             where codjobpost = p_codjobpost
               and dtepost    = p_dtepost
               and codcomp    = p_codcomp;
        else
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            rollback;
            return;
        end if;
    end loop;
    commit;
  end save_index;

  procedure check_insupd is
    v_count     number := 0;
    v_codempid  temploy1.codempid%type;
    v_dtemax    date   := to_date('01/01/9999','dd/mm/yyyy');
  begin
    if p_dtepay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

--    if p_remark is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--      return;
--    end if;

    if p_amtpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_dtepay < p_dtepost then
      param_msg_error := get_error_msg_php('HR2025',global_v_lang);
      return;
    end if;

  end;

END HRRC2EE;

/

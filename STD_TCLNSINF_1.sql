--------------------------------------------------------
--  DDL for Package Body STD_TCLNSINF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_TCLNSINF" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codempid          := hcm_util.get_string_t(json_obj,'psearch_codempid');
    p_numvcher          := hcm_util.get_string_t(json_obj,'psearch_numvcher');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  procedure vadidate_variable(json_str_input in clob) as
    json_obj  json_object_t;
  begin
    if p_numvcher is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return ;
  end ;
  procedure gen_tclnsinf_detail(json_str_output out clob)as
    obj_data        json_object_t;
    statuscode      varchar2(1 char);
    tclnsinf_rec    tclnsinf%ROWTYPE;

  begin
    begin
      select * 
      into tclnsinf_rec
        from tclnsinf
       where numvcher = p_numvcher;
    end;
    obj_data := json_object_t();

    obj_data.put('coderror', '200');
    obj_data.put('response','');
    obj_data.put('codempid',tclnsinf_rec.codempid);
    obj_data.put('desc_codempid',get_temploy_name(tclnsinf_rec.codempid,global_v_lang));
    obj_data.put('codcomp',tclnsinf_rec.codcomp);
    obj_data.put('desc_codcomp', get_tcenter_name(tclnsinf_rec.codcomp,global_v_lang));
    obj_data.put('codpos', tclnsinf_rec.codpos);
    obj_data.put('desc_codpos', get_tpostn_name(tclnsinf_rec.codpos,global_v_lang));
    obj_data.put('dtereq', to_char(tclnsinf_rec.dtereq,'dd/mm/yyyy'));
    obj_data.put('numvcher', tclnsinf_rec.numvcher);
    obj_data.put('codrel', get_tlistval_name(upper('ttyprelate'),tclnsinf_rec.codrel,global_v_lang));
    obj_data.put('namsick', tclnsinf_rec.namsick);
    obj_data.put('codcln', tclnsinf_rec.codcln);
    obj_data.put('desc_codcln', get_tclninf_name(tclnsinf_rec.codcln,global_v_lang));
    obj_data.put('coddc', tclnsinf_rec.coddc);
    obj_data.put('desc_coddc', get_tcodec_name('TDCINF',tclnsinf_rec.coddc,global_v_lang));
    obj_data.put('typpatient', get_tlistval_name('TYPPATIENT',tclnsinf_rec.typpatient,global_v_lang));
    obj_data.put('typamt', get_tlistval_name('TYPAMT',tclnsinf_rec.typamt,global_v_lang));
    obj_data.put('dtecrest', to_char(tclnsinf_rec.dtecrest,'dd/mm/yyyy'));
    obj_data.put('dtecreen', to_char(tclnsinf_rec.dtecreen,'dd/mm/yyyy'));
    obj_data.put('dtebill', to_char(tclnsinf_rec.dtebill,'dd/mm/yyyy'));
    obj_data.put('qtydcare', tclnsinf_rec.qtydcare);
    obj_data.put('flgdocmt',get_tlistval_name('TFLGDOCMT', tclnsinf_rec.flgdocmt, global_v_lang));
    obj_data.put('numdocmt', tclnsinf_rec.numdocmt);
    obj_data.put('amtavai', to_char(tclnsinf_rec.amtavai,'fm9,999,990.00'));
    obj_data.put('amtexp', to_char(tclnsinf_rec.amtexp,'fm9,999,990.00'));
    obj_data.put('amtalw', to_char(tclnsinf_rec.amtalw,'fm9,999,990.00'));
    obj_data.put('amtovrpay', to_char(tclnsinf_rec.amtovrpay,'fm9,999,990.00'));
    obj_data.put('amtemp', to_char(tclnsinf_rec.amtemp,'fm9,999,990.00'));
    obj_data.put('amtpaid', to_char(tclnsinf_rec.amtpaid,'fm9,999,990.00'));
    obj_data.put('dtepaid', to_char(tclnsinf_rec.dtepaid,'dd/mm/yyyy'));
    obj_data.put('amtappr', to_char(tclnsinf_rec.amtappr,'fm9,999,990.00'));
    obj_data.put('dteappr', to_char(tclnsinf_rec.dteappr,'dd/mm/yyyy'));
    obj_data.put('codappr', tclnsinf_rec.codappr);
    obj_data.put('desc_codappr', get_temploy_name(tclnsinf_rec.codappr,global_v_lang));
    obj_data.put('typpay', get_tlistval_name('TYPPAYBF',tclnsinf_rec.typpay,global_v_lang));
    obj_data.put('dtecash', to_char(tclnsinf_rec.dtecash,'dd/mm/yyyy'));

--
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end ;

  procedure get_tclnsinf_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    vadidate_variable(json_str_input);
    gen_tclnsinf_detail(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_tclnsinf_table(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    statuscode      varchar2(1 char);
    v_filepath      varchar2(100 char);
    tclnsinf_rec    tclnsinf%ROWTYPE;
    v_rcnt          number := 0;
    cursor c1 is
      select *
        from tclnsinff
       where numvcher = p_numvcher;
  begin
      obj_row := json_object_t();
      begin
        select folder
          into v_filepath
          from tfolderd
         where codapp = 'HRBF16E';
      exception when no_data_found then
        v_filepath := null;
      end;
      for r1 in c1 loop
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('response','');
          obj_data.put('numvcher',r1.numvcher);
          obj_data.put('numseq',r1.numseq);
          obj_data.put('attachname',r1.filename);
          obj_data.put('path_filename',get_tsetup_value('PATHDOC')||v_filepath||'/'||r1.filename);
          obj_data.put('filename',r1.descfile);

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt := v_rcnt + 1;
      end loop;

      json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end ;

  procedure get_tclnsinf_table(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    vadidate_variable(json_str_input);
    gen_tclnsinf_table(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end std_tclnsinf;

/

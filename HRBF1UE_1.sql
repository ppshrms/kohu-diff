--------------------------------------------------------
--  DDL for Package Body HRBF1UE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1UE" as
  	--date        : 28/01/2021 15:01  redmine#4176

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    p_numvcher          := hcm_util.get_string_t(json_obj,'p_numvcher');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  function explode(p_delimiter varchar2, p_string long, p_limit number default 1000) return arr_1d as
    v_str1        varchar2(4000 char);
    v_comma_pos   number := 0;
    v_start_pos   number := 1;
    v_loop_count  number := 0;

    arr_result    arr_1d;

  begin
    arr_result(1) := null;
    loop
      v_loop_count := v_loop_count + 1;
      if v_loop_count-1 = p_limit then
        exit;
      end if;
      v_comma_pos := to_number(nvl(instr(p_string,p_delimiter,v_start_pos),0));
      v_str1 := substr(p_string,v_start_pos,(v_comma_pos - v_start_pos));
      arr_result(v_loop_count) := v_str1;

      if v_comma_pos = 0 then
        v_str1 := substr(p_string,v_start_pos);
        arr_result(v_loop_count) := v_str1;
        exit;
      end if;
      v_start_pos := v_comma_pos + length(p_delimiter);
    end loop;
    return arr_result;
  end explode;

  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    else
      begin
        select codcomp into v_codcomp
        from tcenter
        where codcomp = get_compful(p_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_approvno      number := 0;
    v_crrntApprno   number := 0;
    v_flgAppr       boolean;
    v_flgExist      boolean := false;
    p_check         varchar2(10 char);

    v_amount        number := 0;
    cursor c1 is
      select codempid,dtereq,numvcher,amtalw,amtovrpay,amtpaid,amtemp,staappov,dteappov,approvno,
             dteappr,amtexp
        from tclnsinf
       where codcomp like p_codcomp||'%'
         and dtereq between p_dtestrt and p_dteend
         and amtovrpay > 0
         and staappov in ('P','A')
       order by codempid,dtereq,numvcher;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c1 loop
      v_flgExist := true;
      v_crrntApprno := nvl(r1.approvno,0) + 1;
      v_flgAppr := chk_flowmail.check_approve('HRBF16E',r1.codempid,v_crrntApprno,global_v_codempid,'','',p_check);
      if v_flgAppr then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('numvcher', r1.numvcher);
        obj_data.put('amtalw', r1.amtalw);
        obj_data.put('amtexp', r1.amtexp);
        obj_data.put('amtovrpay', r1.amtovrpay);
        obj_data.put('amtpaid', r1.amtpaid);
        obj_data.put('amtemp', r1.amtemp);
        obj_data.put('staappov', get_tlistval_name('STAAPPR',r1.staappov,global_v_lang));
        obj_data.put('codstaappov', r1.staappov);
        obj_data.put('dteappov', to_char(r1.dteappr,'dd/mm/yyyy'));
        begin
          select count(*) into v_approvno
            from taprepay
           where numvcher = r1.numvcher;
        end;
        obj_data.put('approvno', v_approvno);
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_flgExist then
      if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3008',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TCLNSINF');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
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

  procedure gen_detail_approve(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_approvno      number := 0;
    v_crrntApprno   number := 0;
    v_flgExist      number := 0;
    v_flgAppr       boolean;
    v_flgDisable    boolean := false;
    p_check         varchar2(10 char);
    v_codempid      tclnsinf.codempid%type;
    v_amtavai       tclnsinf.amtavai%type;
    v_amtexp        tclnsinf.amtexp%type;
    v_amtalw        tclnsinf.amtalw%type;
    v_amtovrpay     tclnsinf.amtovrpay%type;
    v_amtemp        tclnsinf.amtemp%type;
    v_amtpaid       tclnsinf.amtpaid%type;
    v_amtappr       tclnsinf.amtappr%type;
    v_amtrepaym     tclnsinf.amtrepaym%type;
    v_flgdocmt      tclnsinf.flgdocmt%type;
    v_typpay        tclnsinf.typpay%type;
    v_numperiod     tclnsinf.numperiod%type;
    v_dtemthpay     tclnsinf.dtemthpay%type;
    v_dteyrepay     tclnsinf.dteyrepay%type;
    v_dtecash       tclnsinf.dtecash%type;
    v_typamt        tclnsinf.typamt%type;
    v_codrel        tclnsinf.codrel%type;
    v_dtepay        date;

    v_amtoutstd     trepay.amtoutstd%type;
    v_amtrepaym2     trepay.amtrepaym%type;
    v_qtypaid       trepay.qtypaid%type;
    v_qtyrepaym     trepay.qtyrepaym%type;
    v_dtelstpay     trepay.dtelstpay%type;

    v_prdlstpay     number;
    v_mthlstpay     number;
    v_yrelstpay     varchar2(100 char);
    v_lastpay       varchar2(100 char);
    v_staappr       taprepay.staappr%type;
    v_remark        taprepay.remark%type;
    v_dtepaid       tclnsinf.dtepaid%type;
    v_last_numseq   number := 0;

    v_taprepay_last taprepay%rowtype;

    arr_result      arr_1d;
    cursor c1 is
      select *
        from taprepay
       where numvcher = p_numvcher
       order by numseq;
  begin
    begin
      select codempid,nvl(amtavai,0), nvl(amtexp,0), nvl(amtalw,0), nvl(amtovrpay,0), nvl(amtemp,0),
             nvl(amtpaid,0), amtappr, nvl(amtrepaym,0), nvl(flgdocmt,0),dtecash,
             nvl(approvno,0) + 1 as approvno,
             typpay,typamt,codrel,dtepaid,
             numperiod,dtemthpay,dteyrepay
        into v_codempid,v_amtavai,v_amtexp,v_amtalw,v_amtovrpay,v_amtemp,
             v_amtpaid,v_amtappr,v_amtrepaym,v_flgdocmt,v_dtecash,
             v_approvno,v_typpay,v_typamt,v_codrel,v_dtepaid,
             v_numperiod,v_dtemthpay,v_dteyrepay
        from tclnsinf
       where numvcher = p_numvcher;
    exception when no_data_found then
      null;
    end;

    if v_amtpaid > 0 then
      begin
        select amtoutstd,amtrepaym,qtypaid,qtyrepaym,dtelstpay
          into v_amtoutstd,v_amtrepaym2,v_qtypaid,v_qtyrepaym,v_dtelstpay
          from trepay
         where codempid = v_codempid;
      exception when no_data_found then
        v_amtoutstd := 0;
        v_amtrepaym2 := 0;
        v_qtypaid := 0;
      end;
    end if;

    if v_dtelstpay is not null then
--      arr_result := explode('/', v_dtelstpay, 3);
      v_prdlstpay := substr(v_dtelstpay,7,1);
      v_mthlstpay := substr(v_dtelstpay,5,2);
      v_yrelstpay := substr(v_dtelstpay,1,4);
      v_lastpay := v_prdlstpay ||' '|| get_tlistval_name('NAMMTHFUL',v_mthlstpay,global_v_lang) || ' ' || hcm_util.get_year_buddhist_era(v_yrelstpay);
    else
      v_lastpay := '';
    end if;

    v_crrntApprno   := v_approvno;
    v_flgAppr       := chk_flowmail.check_approve('HRBF16E',v_codempid,v_crrntApprno,global_v_codempid,'','',p_check);

    obj_row := json_object_t();

    for r1 in c1 loop
      v_last_numseq := r1.numseq;
      v_rcnt      := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('approvno', r1.numseq);
      obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
      obj_data.put('codappr', r1.codappr);
      obj_data.put('codempid', r1.codempid);
      obj_data.put('amtavai', v_amtavai);
      obj_data.put('amtexp', r1.amtexp);
      obj_data.put('amtalw', v_amtalw);
      obj_data.put('amtovrpay', r1.amtovrpay);
      obj_data.put('amtemp', v_amtemp);
      obj_data.put('amtpaid', v_amtpaid);
      obj_data.put('amtappr', r1.amtappr);
      obj_data.put('amtrepaym', r1.amtrepaym);
      obj_data.put('flgdocmt', v_flgdocmt);
      obj_data.put('typamt', v_typamt);
      obj_data.put('codrel', v_codrel);
      obj_data.put('flgDisable', true);
      if v_amtpaid > 0 then
        begin
          select dtelstpay
            into v_dtelstpay
            from trepay
           where codempid = v_codempid;
        exception when no_data_found then null;
        end;
      end if;
      obj_data.put('typpay', r1.typpay);
      obj_data.put('numperiod', r1.numprdpy);
      obj_data.put('dtemthpay', r1.dtemthpy);
      obj_data.put('dteyrepay', r1.dteyrpy);
      obj_data.put('dtepay', to_char(r1.dtepay, 'dd/mm/yyyy'));

      if v_dtelstpay is not null then
        v_prdlstpay := substr(v_dtelstpay,7,1);
        v_mthlstpay := substr(v_dtelstpay,5,2);
        v_yrelstpay := substr(v_dtelstpay,1,4);
        v_lastpay := v_prdlstpay ||' '|| get_tlistval_name('NAMMTHFUL',v_mthlstpay,global_v_lang) || ' ' || hcm_util.get_year_buddhist_era(v_yrelstpay);
      else
        v_lastpay := '';
      end if;
      obj_data.put('dtelstpay', v_lastpay);
      obj_data.put('prdlstpay', r1.numperiod);
      obj_data.put('mthlstpay', r1.dtemthpay);
      obj_data.put('yrelstpay', r1.dteyrepay);
      obj_data.put('amtoutstdo', r1.amtoutstdo);
      obj_data.put('amtoutstdn', r1.amtoutstd);
      obj_data.put('qtypayo', r1.qtyrepaymo);
      obj_data.put('qtypayn', r1.qtyrepaym);
      obj_data.put('amtrepaymo', r1.amtrepaymo);
      obj_data.put('amtrepaymn', r1.amtrepaym);
      obj_data.put('temp1', '');
      obj_data.put('temp2', '');

      obj_data.put('staappr', r1.staappr);
      obj_data.put('remarkap', r1.remark);
      obj_data.put('dtepaid', to_char(v_dtepaid,'dd/mm/yyyy'));

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_last_numseq < v_crrntApprno then
        v_rcnt      := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('approvno', v_crrntApprno);
        obj_data.put('dteappr', to_char(trunc(sysdate),'dd/mm/yyyy'));
        obj_data.put('codappr', global_v_codempid);
        obj_data.put('codempid', v_codempid);
        obj_data.put('amtavai', v_amtavai);
        obj_data.put('amtexp', v_amtexp);
        obj_data.put('amtalw', v_amtalw);
        obj_data.put('amtovrpay', v_amtovrpay);
        obj_data.put('amtemp', v_amtemp);
        obj_data.put('amtpaid', v_amtpaid);
        obj_data.put('flgdocmt', v_flgdocmt);
        obj_data.put('typamt', v_typamt);
        obj_data.put('amtrepaym', v_amtrepaym);
        obj_data.put('codrel', v_codrel);
        obj_data.put('flgDisable', false);
        obj_data.put('temp1', '');
        obj_data.put('temp2', '');
        obj_data.put('staappr', '');
        obj_data.put('remarkap', '');
        obj_data.put('dtepaid', to_char(v_dtepaid,'dd/mm/yyyy'));

        if v_last_numseq = 0 then
            if v_amtemp > 0 then
                if v_typpay = 1 then
                  if v_numperiod is not null and v_dtemthpay is not null and v_dteyrepay is not null then
                    v_dtepay := to_date(lpad(v_numperiod,2,'0')||'/'||lpad(v_dtemthpay,2,'0')||'/'||v_dteyrepay,'dd/mm/yyyy');
                  end if;
                end if;
            end if;

            if v_amtappr is null then
                if v_flgdocmt = 'Y' then
                    obj_data.put('amtappr', v_amtovrpay);
                else
                    obj_data.put('amtappr', v_amtalw);
                end if;
            else
                obj_data.put('amtappr', v_amtappr);
            end if;
            obj_data.put('typpay', v_typpay);
            obj_data.put('numperiod', v_numperiod);
            obj_data.put('dtemthpay', v_dtemthpay);
            obj_data.put('dteyrepay', v_dteyrepay);
            obj_data.put('dtepay', to_char(v_dtecash, 'dd/mm/yyyy'));
            obj_data.put('amtoutstdo', v_amtoutstd);
            obj_data.put('amtoutstdn', (nvl(v_amtoutstd,0) + v_amtpaid));
            obj_data.put('qtypayo', to_char(v_qtyrepaym - nvl(v_qtypaid,0)));
            obj_data.put('qtypayn', to_char(v_qtyrepaym - nvl(v_qtypaid,0)));
            obj_data.put('amtrepaymo', nvl(v_amtrepaym2,0));
            --<< user25 Date : 08/09/2021 5. BF Module #6863
            --obj_data.put('amtrepaymn', (nvl(v_amtoutstd,0) + v_amtpaid)   /    (v_qtyrepaym - nvl(v_qtypaid,0)));
            if  (v_qtyrepaym - nvl(v_qtypaid,0)) = 0 then
                obj_data.put('amtrepaymn',0);
            else
                obj_data.put('amtrepaymn',(nvl(v_amtoutstd,0) + v_amtpaid)/(v_qtyrepaym - nvl(v_qtypaid,0)));
           end if;
            -->> user25 Date : 08/09/2021 5. BF Module #6863
            obj_data.put('prdlstpay', v_prdlstpay);
            obj_data.put('mthlstpay', v_mthlstpay);
            obj_data.put('yrelstpay', v_yrelstpay);
            obj_data.put('dtelstpay', v_lastpay);
        else
            begin
                select *
                  into v_taprepay_last
                  from taprepay
                 where numvcher = p_numvcher
                   and numseq = (select max(numseq)
                                   from taprepay
                                  where numvcher = p_numvcher);
            exception when others then
                v_taprepay_last := null;
            end;

            obj_data.put('amtappr', v_taprepay_last.amtappr);
            obj_data.put('typpay', v_taprepay_last.typpay);
            obj_data.put('numperiod', v_taprepay_last.numprdpy);
            obj_data.put('dtemthpay', v_taprepay_last.dtemthpy);
            obj_data.put('dteyrepay', v_taprepay_last.dteyrpy);
            obj_data.put('dtepay', to_char(v_taprepay_last.dtepay, 'dd/mm/yyyy'));
            obj_data.put('amtoutstdo', v_taprepay_last.amtoutstd);
            obj_data.put('amtoutstdn', v_taprepay_last.amtoutstd);
            obj_data.put('qtypayo', to_char(v_taprepay_last.qtyrepaymo));
            obj_data.put('qtypayn', to_char(v_taprepay_last.qtyrepaym));
            obj_data.put('amtrepaymo', v_taprepay_last.amtrepaymo);
            obj_data.put('amtrepaymn', v_taprepay_last.amtrepaym);
            obj_data.put('prdlstpay', v_taprepay_last.numperiod);
            obj_data.put('mthlstpay', v_taprepay_last.dtemthpay);
            obj_data.put('yrelstpay', v_taprepay_last.Dteyrepay);
            obj_data.put('dtelstpay', v_lastpay);
        end if;

        obj_row.put(to_char(v_rcnt-1),obj_data);
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_approve(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_detail_approve(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_approve(json_str in clob) is
    v_codcomp       tcenter.codcomp%type;
    v_staemp        temploy1.staemp%type;
    v_flgSecur      boolean;
    json_obj        json_object_t;
    obj_data        json_object_t;
    p_check         varchar2(100 char);
    v_codempid      tclnsinf.codempid%type;
    v_approvno      tclnsinf.approvno%type;
    v_dteappr       tclnsinf.dteappr%type;
    v_codappr       tclnsinf.codappr%type;
    v_amtavai       tclnsinf.amtavai%type;
    v_amtexp        tclnsinf.amtexp%type;
    v_amtalw        tclnsinf.amtalw%type;
    v_amtovrpay     tclnsinf.amtovrpay%type;
    v_amtemp        tclnsinf.amtemp%type;
    v_amtpaid       tclnsinf.amtpaid%type;
    v_amtappr       tclnsinf.amtappr%type;
    v_amtrepaym     tclnsinf.amtrepaym%type;
    v_flgdocmt      tclnsinf.flgdocmt%type;
    v_typpay        tclnsinf.typpay%type;
    v_dtecash       tclnsinf.dtecash%type;
    v_numperiod     tclnsinf.numperiod%type;
    v_dtemthpay     tclnsinf.dtemthpay%type;
    v_dteyrepay     tclnsinf.dteyrepay%type;
    v_dtepay        taprepay.dtepay%type;
    v_dtelstpay     varchar2(100 char);
    v_amtoutstdo    trepay.amtoutstd%type;
    v_staappr       tclnsinf.staappov%type;
    v_prdlstpay     tclnsinf.numperiod%type;
    v_mthlstpay     tclnsinf.dtemthpay%type;
    v_yrelstpay     tclnsinf.dteyrepay%type;
  begin
    json_obj      := json_object_t(json_str);
    obj_data      := hcm_util.get_json_t(json_obj,'params');
    v_codempid    := hcm_util.get_string_t(json_obj,'codempid');
    v_approvno    := hcm_util.get_string_t(obj_data,'approvno');
    v_dteappr     := to_date(hcm_util.get_string_t(obj_data,'dteappr'),'dd/mm/yyyy');
    v_codappr     := hcm_util.get_string_t(obj_data,'codappr');
    v_typpay      := hcm_util.get_string_t(obj_data,'typpay');
    v_dtepay      := to_date(hcm_util.get_string_t(obj_data,'dtepay'),'dd/mm/yyyy');
    v_amtemp      := to_number(replace(hcm_util.get_string_t(obj_data,'amtemp'),',',''));
    v_amtpaid     := to_number(replace(hcm_util.get_string_t(obj_data,'amtpaid'),',',''));

    v_numperiod   := hcm_util.get_string_t(obj_data,'numperiod');
    v_dtemthpay   := hcm_util.get_string_t(obj_data,'dtemthpay');
    v_dteyrepay   := hcm_util.get_string_t(obj_data,'dteyrepay');

    v_prdlstpay   := hcm_util.get_string_t(obj_data,'prdlstpay');
    v_mthlstpay   := hcm_util.get_string_t(obj_data,'mthlstpay');
    v_yrelstpay   := hcm_util.get_string_t(obj_data,'yrelstpay');
    v_staappr     := hcm_util.get_string_t(obj_data,'staappr');
    v_staappr     := hcm_util.get_string_t(obj_data,'staappr');

    if v_approvno is null or v_dteappr is null or v_codappr is null or
       v_typpay is null
    then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if v_typpay = '1' then
      if v_dtepay is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
    elsif v_typpay = '2' then
      if v_numperiod is null or v_dtemthpay is null or v_dteyrepay is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;

    end if;
--    if v_amtpaid is not null and v_amtpaid > 0 then
    if v_amtpaid > 0 then
      if v_prdlstpay is null or v_mthlstpay is null or v_yrelstpay is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
    end if;
    if v_staappr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if v_codappr is not null then
      begin
        select staemp,codcomp into v_staemp,v_codcomp
        from temploy1
        where codempid = v_codappr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
      v_flgSecur := chk_flowmail.check_approve('HRBF16E',v_codempid,v_approvno,v_codappr,'','',p_check);
      if not v_flgSecur then
        param_msg_error := get_error_msg_php('HR3008',global_v_lang);
        return;
      end if;
      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      end if;
      if v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      end if;
    end if;
  end;
  --
  procedure send_mail (v_codempid in varchar2, v_numvcher in varchar2, p_check in varchar2, v_error_sendmail out varchar2) is
		v_number_mail		  number := 0;
		json_obj		      json_object_t;
		param_object		  json_object_t;
		param_json_row		json_object_t;
		p_typemail		    varchar2(500);
        p_codapp          varchar2(500 char);
        p_lang            varchar2(500 char);
        o_msg_to          clob;
        p_template_to     clob;
        p_func_appr       varchar2(500 char);
		v_rowid           ROWID;
        v_codform         tfwmailh.codform%type;
		v_error			      terrorm.errorno%TYPE;
		obj_respone		    json_object_t;
		obj_respone_data  VARCHAR(500 char);
		obj_sum			      json_object_t;
        v_approvno        ttmovemt.approvno%type;
        templabel  VARCHAR(500 char);
	begin
      p_codapp := 'HRBF16E';

      begin
        select rowid, nvl(approvno,0) + 1 as approvno
          into v_rowid,v_approvno
          from tclnsinf
         where numvcher = v_numvcher;
      exception when no_data_found then
          v_approvno := 1;
      end;

      v_error := chk_flowmail.send_mail_for_approve(p_codapp, v_codempid, global_v_codempid, global_v_coduser, null, 'HRBF1UE1', 170, 'U', 'P', v_approvno, null, null,'TCLNSINF',v_rowid, '1', null);
      v_error_sendmail     := get_error_msg_php('HR' || v_error, global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
	end send_mail;

  procedure process_approve(json_str_input in clob, json_str_output out clob) as
    json_obj      json_object_t;
    obj_data      json_object_t;

    v_codempid          tclnsinf.codempid%type;
    v_numvcher          tclnsinf.numvcher%type;
    v_dtereq            tclnsinf.dtereq%type;
    v_approvno          tclnsinf.approvno%type;
    v_dteappr           tclnsinf.dteappr%type;
    v_codappr           tclnsinf.codappr%type;
    v_amtavai           tclnsinf.amtavai%type;
    v_amtexp            tclnsinf.amtexp%type;
    v_amtalw            tclnsinf.amtalw%type;
    v_amtovrpay         tclnsinf.amtovrpay%type;
    v_amtemp            tclnsinf.amtemp%type;
    v_amtpaid           tclnsinf.amtpaid%type;
    v_amtappr           tclnsinf.amtappr%type;
    v_amtrepaym         tclnsinf.amtrepaym%type;
    v_flgdocmt          tclnsinf.flgdocmt%type;
    v_typpay            tclnsinf.typpay%type;
    v_dtecash           tclnsinf.dtecash%type;
    v_numperiod         tclnsinf.numperiod%type;
    v_dtemthpay         tclnsinf.dtemthpay%type;
    v_dteyrepay         tclnsinf.dteyrepay%type;
    v_dtepay            taprepay.dtepay%type;
    v_dtelstpay         trepay.dtelstpay%type;
    v_amtoutstdo        trepay.amtoutstd%type;
    v_amtoutstdn        trepay.amtoutstd%type;
    v_qtypayo           tclnsinf.qtyrepaym%type;
    v_qtypayn           tclnsinf.qtyrepaym%type;
    v_amtrepaymo        taprepay.amtrepaym%type;
    v_amtrepaymn        taprepay.amtrepaym%type;
    v_staappr           tclnsinf.staappov%type;
    v_remarkap          tclnsinf.remarkap%type;
    v_prdlstpay         tclnsinf.numperiod%type;
    v_mthlstpay         tclnsinf.dtemthpay%type;
    v_yrelstpay         tclnsinf.dteyrepay%type;
    v_amttpay           trepay.amttpay%type;
    v_temp1             varchar2(100 char);
    v_temp2             varchar2(100 char);
    v_flgAppr           boolean;
    p_check             varchar2(10 char);
    v_error_sendmail    varchar2(4000 char);

    --sendmail
	v_codform		    tfwmailh.codform%type;
    v_msg_to            clob;
	v_templete_to       clob;
    v_func_appr         tfwmailh.codappap%type;
    v_rowid             rowid;
    v_error			    terrorm.errorno%type;
	v_error_cc          varchar2(4000 char);
    --<<User37 #5723 5. BF Module 17/04/2021
    v_cnt               number;
    v_codcompy          temploy1.codcomp%type;
    v_typpayroll        temploy1.typpayroll%type;
    -->>User37 #5723 5. BF Module 17/04/2021

  begin
    initial_value(json_str_input);
    check_approve(json_str_input);

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;

    json_obj        := json_object_t(json_str_input);
    obj_data        := hcm_util.get_json_t(json_obj,'params');
    v_codempid      := hcm_util.get_string_t(json_obj,'codempid');
    v_numvcher      := hcm_util.get_string_t(json_obj,'numvcher');
    v_dtereq        := hcm_util.get_string_t(json_obj,'dtereq');
    v_approvno      := to_number(hcm_util.get_string_t(obj_data,'approvno'));
    v_dteappr       := to_date(hcm_util.get_string_t(obj_data,'dteappr'),'dd/mm/yyyy');
    v_codappr       := hcm_util.get_string_t(obj_data,'codappr');
    v_amtavai       := to_number(replace(hcm_util.get_string_t(obj_data,'amtavai'),',',''));
    v_amtexp        := to_number(replace(hcm_util.get_string_t(obj_data,'amtexp'),',',''));
    v_amtalw        := to_number(replace(hcm_util.get_string_t(obj_data,'amtalw'),',',''));
    v_amtovrpay     := to_number(replace(hcm_util.get_string_t(obj_data,'amtovrpay'),',',''));
    v_amtemp        := to_number(replace(hcm_util.get_string_t(obj_data,'amtemp'),',',''));
    v_amtpaid       := to_number(replace(hcm_util.get_string_t(obj_data,'amtpaid'),',',''));
    v_amtappr       := to_number(replace(hcm_util.get_string_t(obj_data,'amtappr'),',',''));
    v_amtrepaym     := to_number(replace(hcm_util.get_string_t(obj_data,'amtrepaym'),',',''));
    v_flgdocmt      := hcm_util.get_string_t(obj_data,'flgdocmt');
    v_typpay        := hcm_util.get_string_t(obj_data,'typpay');
    v_numperiod     := to_number(hcm_util.get_string_t(obj_data,'numperiod'));
    v_dtemthpay     := to_number(hcm_util.get_string_t(obj_data,'dtemthpay'));
    v_dteyrepay     := to_number(hcm_util.get_string_t(obj_data,'dteyrepay'));
    v_dtepay        := to_date(hcm_util.get_string_t(obj_data,'dtepay'),'dd/mm/yyyy');
    v_dtecash       := v_dtepay;
--    v_dtelstpay     := to_date(hcm_util.get_string_t(obj_data,'dtelstpay'),'dd/mm/yyyy');
    v_amtoutstdo    := to_number(replace(hcm_util.get_string_t(obj_data,'amtoutstdo'),',',''));
    v_amtoutstdn    := to_number(replace(hcm_util.get_string_t(obj_data,'amtoutstdn'),',',''));
    v_qtypayo       := to_number(hcm_util.get_string_t(obj_data,'qtypayo'));
    v_qtypayn       := to_number(hcm_util.get_string_t(obj_data,'qtypayn'));
    v_amtrepaymo    := to_number(replace(hcm_util.get_string_t(obj_data,'amtrepaymo'),',',''));
    v_amtrepaymn    := to_number(replace(hcm_util.get_string_t(obj_data,'amtrepaymn'),',',''));
    v_staappr       := hcm_util.get_string_t(obj_data,'staappr');
    v_remarkap      := hcm_util.get_string_t(obj_data,'remarkap');
    v_prdlstpay     := to_number(hcm_util.get_string_t(obj_data,'prdlstpay'));
    v_mthlstpay     := to_number(hcm_util.get_string_t(obj_data,'mthlstpay'));
    v_yrelstpay     := to_number(hcm_util.get_string_t(obj_data,'yrelstpay'));
    v_temp1         := hcm_util.get_string_t(obj_data,'temp1');
    v_temp2         := hcm_util.get_string_t(obj_data,'temp2');


    --<<User37 #5723 5. BF Module 17/04/2021
    if v_numperiod is not null and v_dtemthpay is not null and v_dteyrepay is not null then
        begin
            select get_codcompy(codcomp),typpayroll
              into v_codcompy,v_typpayroll
              from temploy1
             where codempid = v_codempid;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end;
        begin
            select count(*)
              into v_cnt
              from tdtepay
             where codcompy = v_codcompy
               and typpayroll = v_typpayroll
               and dteyrepay = v_dteyrepay
               and dtemthpay = v_dtemthpay
               and numperiod = v_numperiod;
        end;
        if v_cnt = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TDTEPAY');
        else
            if v_prdlstpay is not null and v_mthlstpay is not null and v_yrelstpay is not null then
                begin
                    select count(*)
                      into v_cnt
                      from tdtepay
                     where codcompy = v_codcompy
                       and typpayroll = v_typpayroll
                       and dteyrepay = v_yrelstpay
                       and dtemthpay = v_mthlstpay
                       and numperiod = v_prdlstpay;
                end;
                if v_cnt = 0 then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TDTEPAY');
                end if;
            end if;
        end if;
        if param_msg_error is not null then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
        end if;
    end if;
    -->>User37 #5723 5. BF Module 17/04/2021
--
--    if v_staappr = 'A' then
--      v_remark := v_approve;
--    elsif v_staappr = 'N' then
--      v_remark := v_notapprove;
--    end if;
--    v_remark  := replace(v_remark,'.',chr(13));
--    v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');
--

    v_flgAppr   := chk_flowmail.check_approve('HRBF16E',v_codempid,v_approvno,global_v_codempid,'','',p_check);
    begin
      insert into taprepay(numseq,numvcher,codempid,dteappr,codappr,amtappr,amtoutstd,qtyrepaym,
                           amtrepaym,amtoutstdo,qtyrepaymo,amtrepaymo,dteyrepay,dtemthpay,numperiod,
                           staappr,remark,amtexp,amtovrpay,typpay,dteyrpy,dtemthpy,numprdpy,dtepay,
                           dtecreate,codcreate,coduser)
           values(v_approvno,v_numvcher,v_codempid,v_dteappr,v_codappr,v_amtappr,v_amtoutstdn,v_qtypayn,
                  v_amtrepaymn,v_amtoutstdo,v_qtypayo,v_amtrepaymo,v_yrelstpay,v_mthlstpay,v_prdlstpay,
                  v_staappr,v_remarkap,v_amtexp,v_amtovrpay,v_typpay,v_dteyrepay,v_dtemthpay,v_numperiod,v_dtepay,
                  trunc(sysdate),global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then null;
    end;
    select rowid
      into v_rowid
      from tclnsinf
     where numvcher = v_numvcher;

    if v_staappr = 'N' then
      begin
        update tclnsinf
           set staappov = 'N',
                  flgupd    = 'Y',
               codappov   = v_codappr,
               dteappov  = v_dteappr,
               remarkap = v_remarkap,
               codappr = v_codappr,
               dteappr = v_dteappr,
               approvno = v_approvno
         where numvcher = v_numvcher;
      exception when others then
        null;
      end;
      begin
        v_error := chk_flowmail.send_mail_reply('HRBF1UE',v_codempid,null,v_codappr, global_v_coduser, NULL, 'HRBF1UE1', 170, 'U', v_staappr, v_approvno, null, null, 'TCLNSINF', v_rowid, null, null);
      exception when others then
        param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
      end;
    elsif v_staappr = 'Y' then
        if p_check = 'N' then
            begin
              update tclnsinf
                 set staappov = 'A',
                       flgupd    = 'Y',
--<<user14 redmine#4176
                     codappr = v_codappr,dteappr = v_dteappr,
--                     codappov   = v_codappr, dteappov  = v_dteappr,
-->>user14 redmine#4176
                     remarkap = v_remarkap,
                     approvno = v_approvno
               where numvcher = v_numvcher;
            exception when others then
                null;
            end;
-- 2022/11/30 adisak move to top for support when reject
--            select rowid
--              into v_rowid
--              from tclnsinf
--             where numvcher = v_numvcher;
            begin
                -- tag this block
                v_error := chk_flowmail.send_mail_for_approve('HRBF16E', v_codempid, global_v_codempid, global_v_coduser, null, 'HRBF1UE1', 170, 'U', v_staappr, v_approvno + 1, null, null,'TCLNSINF',v_rowid, '1', null);
            exception when others then
                param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
            end;
            IF v_error in ('2046','2402') THEN
                param_msg_error_mail := get_error_msg_php('HR2402', global_v_lang);
            ELSE
                param_msg_error_mail := get_error_msg_php('HR2403', global_v_lang);
            END IF;
        elsif p_check = 'Y' then
          begin
            update tclnsinf
               set staappov = 'Y',
                    flgupd    = 'Y',
                   codappov = v_codappr,dteappov = v_dteappr,
--<<user14 redmine#4176
                   codappr   = nvl(codappr,v_codappr),
                   dteappr = nvl(dteappr,v_dteappr),
--<<user14 redmine#4176
                   remarkap = v_remarkap,
                   dtecash = v_dtecash,
                   dteyrepay = v_dteyrepay,
                   dtemthpay = v_dtemthpay,
                   numperiod = v_numperiod,
                   qtyrepaym = v_qtypayn,
                   amtrepaym = v_amtrepaymn,
                   periodpayst = v_yrelstpay||'/'||v_mthlstpay||'/'||v_prdlstpay,
                   amtappr = v_amtappr,
                   approvno = v_approvno
             where numvcher = v_numvcher;
          exception when others then
              null;
          end;
          if v_amtemp is null or v_amtemp = 0 then
            begin
              select amttpay into v_amttpay
                from trepay
               where codempid = v_codempid;
            exception when no_data_found then
              v_amttpay := 0;
            end;
            --<<User37 #6856 07/09/2021
            begin
              insert into trepay(codempid,codappr,dteappr,amttpay,amtoutstd,qtyrepaym,amtrepaym,
                                       dtestrpm,remark,
                                       codcreate,coduser,flgclose,flgtranpy)
                   values(v_codempid,v_codappr,v_dteappr,v_amttpay + v_amtpaid,v_amtoutstdn,v_qtypayn,v_amtrepaymn,
                                       v_yrelstpay||lpad(v_mthlstpay,2,0)||v_prdlstpay,v_remarkap,
                                       global_v_coduser,global_v_coduser,'N','N');
            exception when dup_val_on_index then null;
              update trepay
                 set codappr = v_codappr,
                     dteappr = v_dteappr,
                     amttpay = v_amttpay + v_amtpaid,
                     amtoutstd = v_amtoutstdn,
                     qtyrepaym = v_qtypayn,
                     amtrepaym = v_amtrepaymn,
                     dtestrpm = v_yrelstpay||lpad(v_mthlstpay,2,0)||v_prdlstpay,
                     remark = v_remarkap
               where codempid = v_codempid;
            end;
            /*begin
              insert into trepay(codempid,codappr,dteappr,amttpay,amtoutstd,qtyrepaym,amtrepaym,
                                       dtestrpm,remark,
                                       codcreate,coduser,flgclose,flgtranpy)
                   values(v_codempid,v_codappr,v_dteappr,v_amttpay + v_amtpaid,v_amtoutstdn,v_qtypayn,v_amtrepaymn,
                                       v_yrelstpay||'/'||v_mthlstpay||'/'||v_prdlstpay,v_remarkap,
                                       global_v_coduser,global_v_coduser,'N','N');
            exception when dup_val_on_index then null;
              update trepay
                 set codappr = v_codappr,
                     dteappr = v_dteappr,
                     amttpay = v_amttpay + v_amtpaid,
                     amtoutstd = v_amtoutstdn,
                     qtyrepaym = v_qtypayn,
                     amtrepaym = v_amtrepaymn,
                     dtestrpm = v_yrelstpay||'/'||v_mthlstpay||'/'||v_prdlstpay,
                     remark = v_remarkap
               where codempid = v_codempid;
            end;*/
            -->>User37 #6856 07/09/2021
          end if;
        end if;
    end if;

    select rowid
      into v_rowid
      from tclnsinf
     where numvcher = v_numvcher;

    begin
        v_error_cc := chk_flowmail.send_mail_reply('HRBF1UE', v_codempid, null , global_v_codempid, global_v_coduser, null, 'HRBF1UE1', 180, 'U', v_staappr, v_approvno, null, null, 'TCLNSINF', v_rowid, '1', null);
    exception when others then
        param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
    end;

    if param_msg_error_mail is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        commit;
    else
        json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
        commit;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

end hrbf1ue;

/

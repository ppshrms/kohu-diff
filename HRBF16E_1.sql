--------------------------------------------------------
--  DDL for Package Body HRBF16E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF16E" AS
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
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');

    p_numvcher          := hcm_util.get_string_t(json_obj,'p_numvcher');
    p_codrel            := hcm_util.get_string_t(json_obj,'p_codrel');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    p_dtecrest          := to_date(hcm_util.get_string_t(json_obj,'p_dtecrest'),'dd/mm/yyyy');
    p_typamt            := hcm_util.get_string_t(json_obj,'p_typamt');
    p_typrel            := hcm_util.get_string_t(json_obj,'p_typrel');
    p_amtexp            := nvl(hcm_util.get_string_t(json_obj,'p_amtexp'),0);

    --<<wanlapa #6678 16/01/2023
    p_amtpaid           := nvl(hcm_util.get_string_t(json_obj,'p_amtpaid'),0);
    p_flag           := nvl(hcm_util.get_number_t(json_obj,'p_flag'),0);
    -->>wanlapa #6678 16/01/2023

    p_flgdocmt          := nvl(hcm_util.get_string_t(json_obj,'p_flgdocmt'),0);--User37 #6678 24/08/2021

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
  begin
    if p_codcomp is not null then
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
    p_check         varchar2(10 char);
    v_flgupd        varchar2(1 char);
    v_amount        number := 0;
    v_namsick       varchar2(1000 char);
    cursor c1 is
      select codempid,dtereq,numvcher,dteappr,namsick,codrel,typpatient,amtexp,codappr,numpaymt,flgupd,numinvoice, flgtranpy
        from tclnsinf
       where codcomp like p_codcomp||'%'
         and codempid = nvl(p_codempid,codempid)
         and dtereq between p_dtestrt and p_dteend
       order by dtereq desc;
  begin

    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
      obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
      obj_data.put('numvcher', r1.numvcher);
      if r1.codrel = 'E' then
        v_namsick := get_temploy_name(r1.codempid,global_v_lang);
      else
        v_namsick := r1.namsick;
      end if;

      obj_data.put('namsick', v_namsick);
      obj_data.put('codrel', r1.codrel);
      obj_data.put('desc_codrel', get_tlistval_name('TTYPRELATE',r1.codrel,global_v_lang));
      obj_data.put('typpatient', get_tlistval_name('TYPPATIENT',r1.typpatient,global_v_lang));
      obj_data.put('amtexp', r1.amtexp);
      obj_data.put('numpaymt', r1.numpaymt);
      obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
      obj_data.put('codappr', r1.codappr);
      obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
      --obj_data.put('flgupd', nvl(r1.flgupd,'N'));
      if (nvl(r1.flgupd,'N') =  'Y' or nvl(r1.flgtranpy,'N') = 'Y') then
        v_flgupd := 'Y';
     else
        v_flgupd := 'N';
     end if;
      obj_data.put('flgupd', v_flgupd);
      obj_data.put('numinvoice', r1.numinvoice);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    -- return
    json_str_output := obj_row.to_clob;
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

  procedure gen_detail(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    p_check         varchar2(10 char);
    v_flgexist      varchar2(2 char);
    v_amount        number := 0;

    tclnsinf_rec    tclnsinf%rowtype;
    v_codempid      tclnsinf.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_dtereq        varchar2(100 char);
    v_codrel        tclnsinf.codrel%type;
    v_namsick       tclnsinf.namsick%type;
    v_flgdocmt      tclnsinf.flgdocmt%type;
    v_typpay        tclnsinf.typpay%type;
  begin
    begin
      select * into tclnsinf_rec
      from tclnsinf
      where numvcher = p_numvcher
      and codempid = p_codempid;
      v_flgexist := 'Y';
    exception when no_data_found then
      tclnsinf_rec := null;
      v_flgexist := 'N';
    end;

    if v_flgexist = 'Y' then
      v_codempid  := tclnsinf_rec.codempid;
      v_codcomp   := tclnsinf_rec.codcomp;
      v_codpos    := tclnsinf_rec.codpos;
      v_dtereq    := to_char(tclnsinf_rec.dtereq,'dd/mm/yyyy');
      v_codrel    := tclnsinf_rec.codrel;
      v_namsick   := tclnsinf_rec.namsick;
      v_flgdocmt  := tclnsinf_rec.flgdocmt;
      v_typpay    := tclnsinf_rec.typpay;
    else
      begin
        select codcomp,codpos into v_codcomp,v_codpos
        from temploy1
        where codempid = p_codempid;
      end;
      v_codempid  := p_codempid;
      v_dtereq    := to_char(sysdate,'dd/mm/yyyy');
      v_codrel    := 'E';
      v_namsick   := p_codempid;
      v_flgdocmt  := 'N';
      v_typpay    := '1';
    end if;

    obj_data := json_object_t();
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', v_codempid);
    obj_data.put('codcomp', v_codcomp);
    obj_data.put('codpos', v_codpos);
    obj_data.put('numvcher', tclnsinf_rec.numvcher);
    obj_data.put('dtereq', v_dtereq);
    obj_data.put('codrel', v_codrel);
    obj_data.put('codcln', tclnsinf_rec.codcln);
    obj_data.put('coddc', tclnsinf_rec.coddc);
    obj_data.put('typpatient', tclnsinf_rec.typpatient);
    obj_data.put('typamt', tclnsinf_rec.typamt);
    obj_data.put('dtecrest', to_char(tclnsinf_rec.dtecrest,'dd/mm/yyyy'));
    obj_data.put('dtecreen', to_char(tclnsinf_rec.dtecreen,'dd/mm/yyyy'));
    obj_data.put('dtebill', to_char(tclnsinf_rec.dtebill,'dd/mm/yyyy'));
    obj_data.put('qtydcare', tclnsinf_rec.qtydcare);
    obj_data.put('flgdocmt', v_flgdocmt);
    obj_data.put('numdocmt', tclnsinf_rec.numdocmt);
--    obj_data.put('amount', tclnsinf_rec.amount);
--    obj_data.put('amtacc', tclnsinf_rec.amtacc);
    obj_data.put('amtalw', tclnsinf_rec.amtalw);
    obj_data.put('amtexp', tclnsinf_rec.amtexp);

    --> Peerasak || #9115 || 15032023
    obj_data.put('amtavai', nvl(tclnsinf_rec.amtavai, 0));
    --> Peerasak || #9115 || 15032023
    obj_data.put('amtovrpay', tclnsinf_rec.amtovrpay);
    obj_data.put('amtemp', tclnsinf_rec.amtemp);
    obj_data.put('amtpaid', tclnsinf_rec.amtpaid);
    obj_data.put('dtepaid', to_char(tclnsinf_rec.dtepaid,'dd/mm/yyyy'));
    obj_data.put('dteappr', to_char(tclnsinf_rec.dteappr,'dd/mm/yyyy'));
    obj_data.put('codappr', tclnsinf_rec.codappr);
    obj_data.put('staappov', tclnsinf_rec.staappov);
    obj_data.put('typpay', v_typpay);
    obj_data.put('dtecash', to_char(tclnsinf_rec.dtecash,'dd/mm/yyyy'));
    obj_data.put('numpaymt', tclnsinf_rec.numpaymt);
    obj_data.put('numperiod', tclnsinf_rec.numperiod);
    obj_data.put('numinvoice', tclnsinf_rec.numinvoice);
    obj_data.put('dtemthpay', tclnsinf_rec.dtemthpay);
    obj_data.put('dterepay', tclnsinf_rec.dteyrepay);
    obj_data.put('flgupd', tclnsinf_rec.flgupd);

    if v_codrel = 'E' then
      if v_flgexist = 'Y' then
        obj_data.put('namsick', get_temploy_name(tclnsinf_rec.codempid,global_v_lang));
      else
        obj_data.put('namsick', get_temploy_name(v_namsick,global_v_lang));
--        obj_data.put('namsick', v_namsick);
      end if;
    else
      obj_data.put('namsick', v_namsick);
--      obj_data.put('namsick', get_temploy_name(v_namsick,global_v_lang));
    end if;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_table(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    p_check         varchar2(10 char);

    v_amount        number := 0;
    cursor c1 is
      select descfile,filename,numseq
        from tclnsinff
       where numvcher = p_numvcher
       order by numseq;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('numseq', r1.numseq);
      obj_data.put('filename', r1.filename);
      obj_data.put('descfile', r1.descfile);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_table(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_relation(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    p_check         varchar2(10 char);
    v_amount        number := 0;
    v_namsick       tclnsinf.namsick%type;

  begin

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    if p_codrel = 'E' then--employee
      obj_data.put('namsick', p_codempid);
      -----------------------------------------------------
    elsif p_codrel = 'S' then
      begin
        select decode(global_v_lang,'101',namspe
                           ,'102',namspt
                           ,'103',namsp3
                           ,'104',namsp4
                           ,'105',namsp5) as namsp
          into v_namsick
          from tspouse
         where codempid = p_codempid;
      exception when no_data_found then
        v_namsick := '';
      end;
      obj_data.put('namsick', v_namsick);
      -------------------------------------------------------
    elsif p_codrel = 'F' then--father
      begin
        select decode(global_v_lang,'101',namfathe
                                   ,'102',namfatht
                                   ,'103',namfath3
                                   ,'104',namfath4
                                   ,'105',namfath5) as namfath
          into v_namsick
          from tfamily
         where codempid = p_codempid;
      exception when no_data_found then
        v_namsick := '';
      end;
      obj_data.put('namsick', v_namsick);
      ------------------------------------------------------------
    elsif p_codrel = 'M' then--mother
      begin
        select decode(global_v_lang,'101',nammothe
                                   ,'102',nammotht
                                   ,'103',nammoth3
                                   ,'104',nammoth4
                                   ,'105',nammoth5) as nammoth
          into v_namsick
          from tfamily
         where codempid = p_codempid;
      exception when no_data_found then
        v_namsick := '';
      end;
      obj_data.put('namsick', v_namsick);
    ---------------------------------------------------------------
    elsif p_codrel = 'C' then-- children
       begin
        select decode(global_v_lang,'101',namche
                                   ,'102',namcht
                                   ,'103',namch3
                                   ,'104',namch4
                                   ,'105',namch5) as namch
          into v_namsick
          from tchildrn
         where codempid = p_codempid;
      exception when no_data_found  then v_namsick := '';
                when too_many_rows  then v_namsick := '';
      end;
      obj_data.put('namsick', v_namsick);
    ------------------------------------------------------------
    else
      obj_data.put('namsick', '');
    end if;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_relation(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_relation(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_credit(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    p_check         varchar2(10 char);
    v_amount        number := 0;

    v_namsick       tclnsinf.namsick%type;
    v_amtwidrwy     number;
    v_qtywidrwy     number;
    v_amtwidrwt     number;
    v_amtacc        number;
    v_amtacc_typ    number;
    v_qtyacc        number;
    v_qtyacc_typ    number;
    v_amtbal        number;

    v_amtavai       number;
    v_amtalw        number;
    v_amtovrpay     number;
  begin

    if p_dtecrest is not null then --User37 #5645 5. BF Module 07/05/2021
    std_bf.get_medlimit(p_codempid, p_dtereq, p_dtecrest, p_numvcher, p_typamt, p_typrel,
                        v_amtwidrwy, v_qtywidrwy, v_amtwidrwt, v_amtacc, v_amtacc_typ, v_qtyacc, v_qtyacc_typ, v_amtbal);
    end if;
    -- วงเงินคงเหลือ remain amount
    v_amtavai := v_amtbal;
    -- จำนวนเงินที่เบิกได้  withdraw amount
    v_amtalw := 0;
    if v_amtbal >= p_amtexp then
      v_amtalw := p_amtexp;
    else
      v_amtalw := v_amtbal;
    end if;
    if v_amtalw > v_amtwidrwt then
      v_amtalw := v_amtwidrwt;
    end if;
    -- เกินวงเงิน over amount
    v_amtovrpay := p_amtexp - v_amtbal;
    if v_amtovrpay < 0 then
      v_amtovrpay := 0;
    end if;

    --
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('amtavai', v_amtavai);
    obj_data.put('amtalw', v_amtalw);
    obj_data.put('amtovrpay', v_amtovrpay);

    --<<User37 #6678 24/08/2021
--    if p_flgdocmt = 'Y' then
--      obj_data.put('amtpaid', v_amtovrpay);
--    else
--      obj_data.put('amtpaid', '');
--    end if;
    -->>User37 #6678 24/08/2021

    --<<wanlapa #6678 16/01/2023
    if p_flgdocmt = 'Y' then
      obj_data.put('amtpaid', v_amtovrpay);
    else
      obj_data.put('amtpaid', '');
    end if;
    if p_flag = 1 then
        obj_data.put('amtpaid', p_amtpaid);
    end if;
    -->>wanlapa #6678 16/01/202

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_credit(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_credit(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  PROCEDURE gen_numvcher (p_codcomp      in varchar2,
                          p_lang         in varchar2,
                          v_numvcher in out varchar2 ) IS --user37 #6841 07/09/2021
   v_count      number      :=0;
   v_seq        number      :=0;
   v_year       number(4)   := to_number(to_char(sysdate,'yyyy'));
   v_buddha     number(4)   := 543;
   v_codcompy   varchar2(4) := hcm_util.get_codcomp_level(p_codcomp,1);
   v_zyear      number;

  begin
        v_zyear   := pdk.check_year(p_lang);

        if v_year > 2500 then
            v_year := substr(v_year,3,2);--2564
        else
            v_year := substr((v_year + v_buddha),3,2); --2021
        end if;
         --------------
        begin
          select count(*)----0010/63/0000005
            into v_seq
            from tclnsinf
           where substr(numvcher,1,instr(numvcher,'/',1,1)-1) = v_codcompy
             and to_number(substr(numvcher,instr(numvcher,'/',1,1)+1,2)) = to_number(v_year);
        end;
        loop
           v_seq      := v_seq+1;
           v_numvcher := v_codcompy||'/'||v_year||'/'||lpad(v_seq,7,0);--0010/63/0000005

          begin
            select count(*)
            into v_count
            from tclnsinf
            where numvcher = v_numvcher;
          end;
          if v_count = 0 then
            exit;
          end if;
        end loop;
  END;
  --
  procedure save_detail (json_str_input in clob, json_str_output out clob) as
    param_json          json_object_t;
    param_json_row      json_object_t;
    data_row            json_object_t;
    obj_data            json_object_t;
    v_codempid		tclnsinf.codempid%type;
    v_codcomp		tclnsinf.codcomp%type;
    v_codpos		tclnsinf.codpos%type;
    v_numvcher		tclnsinf.numvcher%type;
    v_dtereq		tclnsinf.dtereq%type;
    v_codrel		tclnsinf.codrel%type;
    v_namsick		tclnsinf.namsick%type;
    v_codcln		tclnsinf.codcln%type;
    v_coddc			tclnsinf.coddc%type;
    v_typpatient	tclnsinf.typpatient%type;
    v_typamt		tclnsinf.typamt%type;
    v_dtecrest		tclnsinf.dtecrest%type;
    v_dtecreen		tclnsinf.dtecreen%type;
    v_dtebill		tclnsinf.dtebill%type;
    v_qtydcare		tclnsinf.qtydcare%type;
    v_flgdocmt		tclnsinf.flgdocmt%type;
--    v_numpaymt		tclnsinf.numpaymt%type;
    v_amtalw		tclnsinf.amtalw%type;
    v_amtexp		tclnsinf.amtexp%type;
    v_amtavai		tclnsinf.amtavai%type;
    v_amtovrpay		tclnsinf.amtovrpay%type;
    v_amtemp		tclnsinf.amtemp%type;
    v_amtpaid		tclnsinf.amtpaid%type;
    v_dteappr		tclnsinf.dteappr%type;
    v_codappr		tclnsinf.codappr%type;
    v_staappov		tclnsinf.staappov%type;
    v_typpay		tclnsinf.typpay%type;
    v_dtecash		tclnsinf.dtecash%type;
    v_numpaymt		tclnsinf.numpaymt%type;
    v_numperiod		tclnsinf.numperiod%type;
    v_dtemthpay		tclnsinf.dtemthpay%type;
    v_dteyrepay		tclnsinf.dteyrepay%type;
    v_flgupd		tclnsinf.flgupd%type;
    v_dtepaid		tclnsinf.dtepaid%type;

    v_flg       varchar2(10 char);
    v_numseq    tclnsinff.numseq%type;
    v_filename  tclnsinff.filename%type;
    v_descfile  tclnsinff.descfile%type;
    v_numdocmt  tclnsinf.numdocmt%type;
    v_numinvoice  tclnsinf.numinvoice%type;
    v_running     number := 0;
    v_response    varchar2(4000 char);
    v_typpayroll    temploy1.typpayroll%type;
    v_comp_emp      temploy1.codcomp%type;

  begin
    initial_value(json_str_input);
    check_save(json_str_input);
--
    if param_msg_error is null then

      param_json      := hcm_util.get_json_t(json_object_t(json_str_input),'detail');
      param_json_row  := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');

      v_codempid      := hcm_util.get_string_t(param_json,'codempid');
      v_codcomp       := hcm_util.get_string_t(param_json,'codcomp');
      v_codpos        := hcm_util.get_string_t(param_json,'codpos');
      v_numvcher      := hcm_util.get_string_t(param_json,'numvcher');
      v_dtereq        := to_date(hcm_util.get_string_t(param_json,'dtereq'),'dd/mm/yyyy');
      v_codrel        := hcm_util.get_string_t(param_json,'codrel');
      v_namsick       := hcm_util.get_string_t(param_json,'namsick');
      v_codcln        := hcm_util.get_string_t(param_json,'codcln');
      v_coddc         := hcm_util.get_string_t(param_json,'coddc');
      v_typpatient    := hcm_util.get_string_t(param_json,'typpatient');
      v_typamt        := hcm_util.get_string_t(param_json,'typamt');
      v_dtecrest      := to_date(hcm_util.get_string_t(param_json,'dtecrest'),'dd/mm/yyyy');
      v_dtecreen      := to_date(hcm_util.get_string_t(param_json,'dtecreen'),'dd/mm/yyyy');
      v_dtebill       := to_date(hcm_util.get_string_t(param_json,'dtebill'),'dd/mm/yyyy');
      v_qtydcare      := hcm_util.get_string_t(param_json,'qtydcare');
      v_flgdocmt      := hcm_util.get_string_t(param_json,'flgdocmt');

      v_amtalw        := hcm_util.get_string_t(param_json,'amtalw');
      v_amtexp        := hcm_util.get_string_t(param_json,'amtexp');
      v_amtavai       := hcm_util.get_string_t(param_json,'amtavai');
      v_amtovrpay     := hcm_util.get_string_t(param_json,'amtovrpay');
      v_amtemp        := hcm_util.get_string_t(param_json,'amtemp');
      v_amtpaid       := hcm_util.get_string_t(param_json,'amtpaid');
      v_dteappr       := to_date(hcm_util.get_string_t(param_json,'dteappr'),'dd/mm/yyyy');
      v_codappr       := hcm_util.get_string_t(param_json,'codappr');
      v_staappov      := hcm_util.get_string_t(param_json,'staappov');
      v_typpay        := hcm_util.get_string_t(param_json,'typpay');
      v_dtecash       := to_date(hcm_util.get_string_t(param_json,'dtecash'),'dd/mm/yyyy');
      v_numpaymt      := hcm_util.get_string_t(param_json,'numpaymt');
      v_numperiod     := hcm_util.get_string_t(param_json,'numperiod');
      v_dtemthpay     := hcm_util.get_string_t(param_json,'dtemthpay');
      v_dteyrepay     := hcm_util.get_string_t(param_json,'dterepay');
      v_dtepaid       := to_date(hcm_util.get_string_t(param_json,'dtepaid'),'dd/mm/yyyy');
      v_flgupd        := hcm_util.get_string_t(param_json,'flgupd');
      v_numdocmt      := hcm_util.get_string_t(param_json,'numdocmt');
      v_numinvoice    := hcm_util.get_string_t(param_json,'numinvoice');


      if v_numvcher is null then
        gen_numvcher(v_codcomp,global_v_lang,v_numvcher);--user37 #6841 07/09/2021 v_numvcher := gen_numvcher(v_codcomp);
      end if;

      begin
          select typpayroll,codcomp
            into v_typpayroll, v_comp_emp
            from temploy1
           where codempid = v_codempid;
           exception when no_data_found then
            v_typpayroll := null;
            v_comp_emp   := null;
      end;

     begin
      insert into tclnsinf ( numvcher , codempid , codcomp , codpos , dtereq , namsick , codrel , codcln,
                             coddc , typpatient , typamt , dtecrest , dtecreen , qtydcare , dtebill , flgdocmt , amtexp,
                             amtalw , amtovrpay , amtavai , amtemp , amtpaid , dteappr , codappr , typpay , dtecash,
                             dteyrepay , dtemthpay , numperiod , flgupd , numpaymt, typpayroll,flgtranpy,numdocmt,
                             staappov , dtepaid, dtecreate , codcreate , coduser, numinvoice )
          values (v_numvcher, v_codempid, v_comp_emp, v_codpos, v_dtereq, v_namsick, v_codrel, v_codcln,
                            v_coddc, v_typpatient, v_typamt, v_dtecrest, v_dtecreen, v_qtydcare, v_dtebill, v_flgdocmt, v_amtexp,
                            v_amtalw, v_amtovrpay, v_amtavai, v_amtemp, v_amtpaid, v_dteappr, v_codappr, v_typpay, v_dtecash,
                            v_dteyrepay, v_dtemthpay, v_numperiod, 'N', v_numpaymt , v_typpayroll, 'N',v_numdocmt,
                            v_staappov, v_dtepaid, sysdate, global_v_coduser, global_v_coduser, v_numinvoice );

        exception  when dup_val_on_index then
          update  tclnsinf
             set  codempid = v_codempid,
                  codcomp = v_comp_emp,
                  codpos = v_codpos,
                  dtereq = v_dtereq,
                  namsick = v_namsick,
                  codrel = v_codrel,
                  codcln = v_codcln,
                  coddc = v_coddc,
                  typpatient = v_typpatient,
                  typamt = v_typamt,
                  dtecrest = v_dtecrest,
                  dtecreen = v_dtecreen,
                  qtydcare = v_qtydcare,
                  dtebill = v_dtebill,
                  flgdocmt = v_flgdocmt,
                  amtexp = v_amtexp,
                  amtalw = v_amtalw,
                  amtovrpay = v_amtovrpay,
                  amtavai = v_amtavai,
                  amtemp = v_amtemp,
                  amtpaid = v_amtpaid,
                  dteappr = v_dteappr,
                  codappr = v_codappr,
                  typpay = v_typpay,
                  dtecash = v_dtecash,
                  dteyrepay = v_dteyrepay,
                  dtemthpay = v_dtemthpay,
                  numperiod = v_numperiod,
                  flgupd = v_flgupd,
                  numpaymt = v_numpaymt,
                  typpayroll = v_typpayroll,
                  numdocmt = v_numdocmt,
                  staappov = v_staappov,
                  dtepaid = v_dtepaid,
                  dteupd = sysdate,
                  coduser = global_v_coduser,
                  numinvoice = v_numinvoice
            where numvcher = v_numvcher;
    end;

    begin
           if v_numdocmt is not null then
                  update  tclndoc
                     set  stadocmt = 'Y',
                          dteupd   = sysdate,
                          coduser  = global_v_coduser
                    where numdocmt = v_numdocmt;
            end if;
          exception when others then    null;
    end;

      for i in 0..param_json_row.get_size-1 loop
        data_row  := hcm_util.get_json_t(param_json_row,to_char(i));
        v_flg     		  := hcm_util.get_string_t(data_row, 'flg');
        v_filename		  := hcm_util.get_string_t(data_row, 'filename');
        v_descfile		  := hcm_util.get_string_t(data_row, 'descfile');
        v_numseq		    := hcm_util.get_string_t(data_row, 'numseq');

        if v_flg = 'add' then
          begin
            select nvl(max(numseq),0)+1 into v_numseq
            from tclnsinff
            where numvcher = v_numvcher;
          exception when no_data_found then
            v_numseq := 1;
          end;
          insert into tclnsinff (numvcher, numseq, filename, descfile, dtecreate, codcreate, coduser)
          values (v_numvcher, v_numseq, v_filename, v_descfile, sysdate, global_v_coduser, global_v_coduser);
        elsif v_flg = 'delete' then
          delete tclnsinff where numvcher = v_numvcher  and numseq = v_numseq;
        end if;
      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
      obj_data.put('numvcher', v_numvcher);

      json_str_output := obj_data.to_clob;
      commit;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
    end if;
--    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  procedure check_save (json_str in clob)is
    json_obj            json_object_t;
    obj_detail          json_object_t;
    v_codempid          tclnsinf.codempid%type;
    v_dtecrest          tclnsinf.dtecrest%type;
    v_dtereq            tclnsinf.dtereq%type;
    v_numvcher          tclnsinf.numvcher%type;
    v_typamt            tclnsinf.typamt%type;
    v_codrel            tclnsinf.codrel%type;
    v_staemp            temploy1.staemp%type;
    v_dteeffex          temploy1.dteeffex%type;

    v_amtwidrwy     number;
    v_qtywidrwy     number;
    v_amtwidrwt     number;
    v_amtacc        number;
    v_amtacc_typ    number;
    v_qtyacc        number;
    v_qtyacc_typ    number;
    v_amtbal        number;
    v_amtexp        number;
    --<<User37 TDK #6709 19/08/2021
    v_stalife       varchar2(1 char);--User37 TDK #6709 19/08/2021
    v_namsick		tclnsinf.namsick%type;
    -->>User37 TDK #6709 19/08/2021

    v_amtwidrwy1    number :=0;
    v_qtywidrwy1    number :=0;
    v_amtwidrwt1    number :=0;
    v_amtwidrwy2    number :=0;
    v_qtywidrwy2    number :=0;
    v_amtwidrwt2    number :=0;
    v_typamt_a      varchar2(10);
    v_typrel_a      varchar2(10);

  begin
    json_obj    := json_object_t(json_str);
    obj_detail  := hcm_util.get_json_t(json_obj,'detail');
    v_codempid  :=  hcm_util.get_string_t(obj_detail,'codempid');
    v_numvcher  :=  hcm_util.get_string_t(obj_detail,'numvcher');
    v_typamt    :=  hcm_util.get_string_t(obj_detail,'typamt');
    v_codrel    :=  hcm_util.get_string_t(obj_detail,'codrel');
    v_amtexp    :=  hcm_util.get_string_t(obj_detail,'amtexp');


    v_dtecrest  :=  to_date(hcm_util.get_string_t(obj_detail,'dtecrest'),'dd/mm/yyyy');
    v_dtereq    :=  to_date(hcm_util.get_string_t(obj_detail,'dtereq'),'dd/mm/yyyy');
    begin
      select staemp,dteeffex into v_staemp,v_dteeffex
      from temploy1
      where codempid = v_codempid;
    exception when no_data_found then
      v_staemp := null;
    end;

    if v_staemp = 0 then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
    end if;

    if v_staemp = 9 then
      if v_dtecrest >= v_dteeffex then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      end if;
    end if;

--<< user22 : 26/01/2023 || https://hrmsd.peopleplus.co.th:4449/redmine/issues/658 
    std_bf.get_condtypamt(v_codempid,v_dtereq,v_dtecrest,v_numvcher,v_typamt,v_codrel,
                          v_amtwidrwy1,v_qtywidrwy1,v_amtwidrwt1,v_typamt_a,v_typrel_a,
                          v_amtwidrwy2,v_qtywidrwy2,v_amtwidrwt2);
    if nvl(v_amtwidrwy1,0) = 0 and nvl(v_amtwidrwy2,0) = 0 then
      param_msg_error := get_error_msg_php('HR6541',global_v_lang);
      return;
    end if;
-->> user22 : 26/01/2023 || https://hrmsd.peopleplus.co.th:4449/redmine/issues/658  


    std_bf.get_medlimit(v_codempid, v_dtereq, v_dtecrest, v_numvcher, v_typamt, v_codrel,
                        v_amtwidrwy, v_qtywidrwy, v_amtwidrwt, v_amtacc, v_amtacc_typ, v_qtyacc, v_qtyacc_typ, v_amtbal);
    if nvl(v_qtyacc_typ,0) > 0 or nvl(v_qtywidrwy,0) > 0 or  nvl(v_qtyacc,0) > 0 then
      if nvl(v_qtyacc_typ,0) >= nvl(v_qtywidrwy,0) then
        param_msg_error := get_error_msg_php('HR6543',global_v_lang);
        return;
      end if;

      if nvl(v_qtyacc,0) >= nvl(v_qtywidrwy,0) then
        param_msg_error := get_error_msg_php('HR6544',global_v_lang);
        return;
      end if;
    end if;
    --<<User37 TDK #6709 19/08/2021
    v_namsick       := hcm_util.get_string_t(obj_detail,'namsick');
    v_stalife := check_stalife(v_codempid , v_codrel, v_namsick, global_v_lang);
    if v_stalife = 'N' then
      param_msg_error := get_error_msg_php('HR0009',global_v_lang);
      return;
    end if;
    -->>User37 TDK #6709 19/08/2021

  exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end;

  procedure send_mail (json_str_input in clob, json_str_output out clob) is
		v_number_mail		    number := 0;
		json_obj		        json_object_t;
		param_object		    json_object_t;
		param_json_row		    json_object_t;
		p_typemail		        varchar2(500);
        v_codempid		        temploy1.codempid%type;
        v_codcomp               temploy1.codcomp%type;
        p_codapp                varchar2(500 char);
        p_lang                  varchar2(500 char);
        o_msg_to                clob;
        p_template_to           clob;
        p_func_appr             varchar2(500 char);
		v_rowid                 ROWID;
        v_codform               tfwmailh.codform%type;
		v_error			        terrorm.errorno%TYPE;
		obj_respone		        json_object_t;
		obj_respone_data        VARCHAR(500 char);
		obj_sum			        json_object_t;
        v_approvno              tclnsinf.approvno%type;
	begin
		initial_value(json_str_input);
        p_codapp      := 'HRBF16E';

        begin
          select rowid, nvl(approvno,0) + 1 as approvno
            into v_rowid,v_approvno
            from tclnsinf
           where numvcher = p_numvcher
             and codempid = p_codempid;
        exception when no_data_found then
            v_approvno := 1;
        end;

        v_error := chk_flowmail.send_mail_for_approve('HRBF16E', p_codempid, global_v_codempid, global_v_coduser, null, 'HRBF16E2', 470, 'E', 'P', v_approvno, null, null,'TCLNSINF',v_rowid, '1', null);

        if v_error is not null then
          param_msg_error     := get_error_msg_php('HR' || v_error, global_v_lang);
          json_str_output     := get_response_message(NULL, param_msg_error, global_v_lang);
        else
          param_msg_error := get_error_msg_php('HR7522', global_v_lang);
          json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        end if;

	exception when others then
        param_msg_error := get_error_msg_php('HR7522', global_v_lang);
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end send_mail;
  procedure save_index (json_str_input in clob, json_str_output out clob) as
    param_json          json_object_t;
    param_json_row      json_object_t;
    param_index         json_object_t;

    v_flg	            varchar2(1000 char);
    v_flgupd	        varchar2(1000 char);
    v_numvcher	        varchar2(1000 char);
  begin
    initial_value(json_str_input);
    param_json  := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');

    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

      v_flg         := hcm_util.get_string_t(param_json_row,'flg');
      v_numvcher		:= hcm_util.get_string_t(param_json_row,'numvcher');
      v_flgupd		  := nvl(hcm_util.get_string_t(param_json_row,'flgupd'),'N');
      if v_flg = 'delete' then
        if v_flgupd <> 'Y' then
          delete tclnsinf where numvcher = v_numvcher;
          delete tclnsinff where numvcher = v_numvcher;
        end if;
      end if;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;

END HRBF16E;

/

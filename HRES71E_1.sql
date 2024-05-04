--------------------------------------------------------
--  DDL for Package Body HRES71E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES71E" as
--Error ST11/user14||14/02/2023||STT-SS-2101||redmine754
  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_staappr            := hcm_util.get_string_t(json_obj,'p_staappr');

    p_numvcher          := hcm_util.get_string_t(json_obj,'p_numvcher');
    p_codrel            := hcm_util.get_string_t(json_obj,'p_codrel');
    p_dtecrest          := to_date(hcm_util.get_string_t(json_obj,'p_dtecrest'),'dd/mm/yyyy');
    p_typamt            := hcm_util.get_string_t(json_obj,'p_typamt');
    p_typrel            := hcm_util.get_string_t(json_obj,'p_typrel');
    p_amtexp            := nvl(hcm_util.get_string_t(json_obj,'p_amtexp'),0);

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
  begin
    if p_dtestrt is not null and p_dteend is not null then
      if p_dtestrt > p_dteend then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    p_check         varchar2(10 char);

    v_amount        number := 0;
    cursor c1 is
      select *
        from tmedreq
       where codempid = p_codempid
         and dtereq between nvl(p_dtestrt,dtereq) and nvl(p_dteend,dtereq)
       order by dtereq desc,numseq desc;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('numseq', r1.numseq );
      obj_data.put('codempid', r1.codempid );
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
      obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy') );
      obj_data.put('numvcher', r1.numvcher );
      obj_data.put('namsick', r1.namsick );
      obj_data.put('codrel', r1.codrel );
      obj_data.put('desc_codrel', get_tlistval_name('TTYPRELATE',r1.codrel,global_v_lang) );
      obj_data.put('typpatient', get_tlistval_name('TYPPATIENT',r1.typpatient,global_v_lang) );
      obj_data.put('amtexp', r1.amtexp );
      obj_data.put('numdocmt', r1.numdocmt );
      obj_data.put('seqno', r1.numseq );
      obj_data.put('currency', '');
      obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy') );
      obj_data.put('staappr', r1.staappr);
      obj_data.put('status', get_tlistval_name('ESSTAREQ',trim(r1.staappr),global_v_lang));
      obj_data.put('remark', r1.remarkap );
      obj_data.put('codappr', r1.codappr || ' ' ||get_temploy_name(r1.codappr,global_v_lang) );
      obj_data.put('next_codappr', chk_workflow.get_next_approve('HRES71E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,nvl(trim(r1.approvno),'0'),global_v_lang) );

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

    tmedreq_rec     tmedreq%rowtype;
    v_codempid      tmedreq.codempid%type;
    v_numseq        tmedreq.numseq%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_dtereq        varchar2(100 char);
    v_codrel        tmedreq.codrel%type;
    v_namsick       tmedreq.namsick%type;
    v_flgdocmt      tmedreq.flgdocmt%type;
    v_typpay        tmedreq.typpay%type;
    v_dtecrest      tmedreq.dtecrest%type;
    v_dtecreen      tmedreq.dtecreen%type;
    v_dtebill       tmedreq.dtebill%type;
  begin
    if p_numseq is null then
      begin
        select nvl(max(numseq),0) + 1 into p_numseq
          from tmedreq
         where codempid = p_codempid
           and dtereq = p_dtereq;
      exception when no_data_found then
        p_numseq := 1;
      end;
    end if;
    begin
      select * into tmedreq_rec
        from tmedreq
       where codempid = p_codempid
         and dtereq = p_dtereq
         and numseq = p_numseq;
      v_flgexist := 'Y';
    exception when no_data_found then
      tmedreq_rec := null;
      v_flgexist := 'N';
    end;
    if v_flgexist = 'Y' then      begin
      select codpos into v_codpos
        from temploy1
        where codempid = p_codempid;
      end;
      v_codempid  := tmedreq_rec.codempid;
      v_codcomp   := tmedreq_rec.codcomp;
      v_codpos    := v_codpos;
      v_dtereq    := to_char(tmedreq_rec.dtereq,'dd/mm/yyyy');
      v_codrel    := tmedreq_rec.codrel;
      v_namsick   := tmedreq_rec.namsick;
      v_flgdocmt  := tmedreq_rec.flgdocmt;
      v_typpay    := tmedreq_rec.typpay;
      v_dtecrest  := tmedreq_rec.dtecrest;
      v_dtecreen  := tmedreq_rec.dtecreen;
      v_dtebill   := tmedreq_rec.dtebill;
      v_numseq   := tmedreq_rec.numseq;
    else
      begin
        select codcomp,codpos into v_codcomp,v_codpos
        from temploy1
        where codempid = p_codempid;
      end;
      v_codempid  := p_codempid;
      v_dtereq    := to_char(p_dtereq,'dd/mm/yyyy');
      v_numseq    := p_numseq;
      v_codrel    := 'E';
      v_namsick   := p_codempid;
      v_flgdocmt  := 'N';

--<<user14||14/02/2023||STT-SS-2101||redmine754
      --v_typpay    := '1';
      v_typpay    := '2';  --default PY
-->>user14||14/02/2023||STT-SS-2101||redmine754

      v_dtecrest  := trunc(sysdate);
      v_dtecreen  := trunc(sysdate);
      v_dtebill   := trunc(sysdate);
    end if;

    obj_data := json_object_t();
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', v_codempid);
    obj_data.put('desc_codempid', get_temploy_name(v_codempid,global_v_lang));--User37 TDK #6716 19/08/2021
    obj_data.put('dtereq', v_dtereq);
    obj_data.put('numseq', v_numseq);
    obj_data.put('codcomp', v_codcomp);
    obj_data.put('codpos', v_codpos);
    obj_data.put('numvcher', tmedreq_rec.numvcher);
    obj_data.put('codrel', v_codrel);
    obj_data.put('codcln', tmedreq_rec.codcln);
    obj_data.put('coddc', tmedreq_rec.coddc);
    obj_data.put('typpatient', tmedreq_rec.typpatient);
    obj_data.put('typamt', tmedreq_rec.typamt);
    obj_data.put('dtecrest', to_char(v_dtecrest,'dd/mm/yyyy'));
    obj_data.put('dtecreen', to_char(v_dtecreen,'dd/mm/yyyy'));
    obj_data.put('dtebill', to_char(v_dtebill,'dd/mm/yyyy'));
    obj_data.put('qtydcare', tmedreq_rec.qtydcare);
    obj_data.put('flgdocmt', v_flgdocmt);
    obj_data.put('numdocmt', tmedreq_rec.numdocmt );
    obj_data.put('amtalw', nvl(tmedreq_rec.amtalw,0));
    obj_data.put('amtexp', nvl(tmedreq_rec.amtexp,0) );
    obj_data.put('amtavai', nvl(tmedreq_rec.amtavai,0) );
    obj_data.put('amtovrpay', nvl(tmedreq_rec.amtovrpay,0) );
    obj_data.put('amtemp', nvl(tmedreq_rec.amtemp,0) );
    obj_data.put('amtpaid', nvl(tmedreq_rec.amtpaid,0) );
    obj_data.put('dtepaid', to_char(tmedreq_rec.dtepaid,'dd/mm/yyyy') );
    obj_data.put('dteappr', to_char(tmedreq_rec.dteappr,'dd/mm/yyyy') );
    obj_data.put('codappr', tmedreq_rec.codappr );
    obj_data.put('typpay', v_typpay );
    obj_data.put('staappr', tmedreq_rec.staappr );

    if v_codrel = 'E' then
      if v_flgexist = 'Y' then
--        obj_data.put('namsick', tmedreq_rec.codempid);
        obj_data.put('namsick', get_temploy_name(tmedreq_rec.codempid,global_v_lang));
      else
--        obj_data.put('namsick', v_namsick);
        obj_data.put('namsick', get_temploy_name(v_namsick,global_v_lang));
      end if;
    else
--      obj_data.put('namsick', tmedreq_rec.namsick);
      obj_data.put('namsick', v_namsick);
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
      select seqno, filename, descfile
        from tmedreqf
       where codempid = p_codempid
         and dtereq = p_dtereq
         and numseq = p_numseq
       order by seqno;
  begin
    if p_numseq is null then
      begin
        select nvl(max(numseq),0) + 1 into p_numseq
          from tmedreq
         where codempid = p_codempid
           and dtereq = p_dtereq;
      exception when no_data_found then
        p_numseq := 1;
      end;
    end if;
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('numseq', r1.seqno);
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

    v_namsick       tmedreq.namsick%type;

  begin

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    if p_codrel = 'E' then
      obj_data.put('namsick', p_codempid);
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
    elsif p_codrel = 'F' then
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
    elsif p_codrel = 'M' then
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

    v_namsick       tmedreq.namsick%type;
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
    v2_typrel       varchar2(1000);

  begin
    --#4795 || 3/5/2022
    if p_typrel = 'M' then v2_typrel := 'F';
    else  v2_typrel := p_typrel;
    end if;
    --#4795 || 3/5/2022
    std_bf.get_medlimit(p_codempid, p_dtereq, p_dtecrest, p_numvcher, p_typamt, v2_typrel,
                        v_amtwidrwy, v_qtywidrwy, v_amtwidrwt, v_amtacc, v_amtacc_typ, v_qtyacc, v_qtyacc_typ, v_amtbal);
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
  procedure insert_next_step is
    v_codapp     varchar2(10) := 'HRES71E';
    v_count      number := 0;
    v_approvno   number := 0;
    v_codempid_next  temploy1.codempid%type;
    v_codempap   temploy1.codempid%type;
    v_codcompap  tcenter.codcomp%type;
    v_codposap   varchar2(4 char);
    v_remark     varchar2(200 char) := substr(get_label_name('HRESZXEC1',global_v_lang,99),1,200);
    v_routeno    varchar2(100 char);

    v_ok        boolean;

    v_flgfwbwlim  varchar2(1);
    v_qtyminle    number;
    v_qtydlefw    number;
    v_qtydlebw    number;

    v_dtefw       date;
    v_dteaw       date;
    v_typleave	  varchar2(4 char);
    v_table			  varchar2(50 char);
    v_error			  varchar2(50 char);
  begin
    v_approvno       := 0 ;
    v_codempap       := p_codempid ;
    tmedreq_staappr  := 'P';
    chk_workflow.find_next_approve(v_codapp,v_routeno,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,p_codempid,'');

    if v_routeno is null then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'twkflph');
      return;
    end if;
    --
    chk_workflow.find_approval(v_codapp,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,v_table,v_error);
    if v_error is not null then
      param_msg_error := get_error_msg_php(v_error,global_v_lang,v_table);
      return;
    end if;
     --Loop Check Next step
    loop
      v_codempid_next := chk_workflow.check_next_step(v_codapp,v_routeno,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,p_codempid);
      if  v_codempid_next is not null then
        v_approvno         := v_approvno + 1 ;
        tmedreq_codappr    := v_codempid_next ;
        tmedreq_staappr    := 'A' ;
        tmedreq_dteappr    := trunc(sysdate);
        tmedreq_remarkap   := v_remark;
        tmedreq_approvno   := v_approvno ;
        begin
            select  count(*) into v_count
             from   tapmedrq
             where  codempid = p_codempid
             and    dtereq   = p_dtereq
             and    numseq   = p_numseq
             and    approvno = v_approvno;
        exception when no_data_found then  v_count := 0;
        end;

        if v_count = 0 then
          insert into tapmedrq (codempid, dtereq, numseq, approvno,  amtalw, typpay,
                                codappr, dteappr, staappr, remark, dteapph,
                                dtecreate, codcreate, coduser)
              values (p_codempid, p_dtereq, p_numseq, v_approvno, p_amtalw, p_typpay,
                      v_codempid_next, trunc(sysdate), 'A', v_remark, sysdate,
                      sysdate, global_v_coduser, global_v_coduser);
        else
          update tapmedrq
             set codappr = v_codempid_next,
                 dteappr   = trunc(sysdate),
                 staappr   = 'A',
                 remark    = v_remark ,
                 coduser   = global_v_coduser,
                 dteapph   = sysdate
           where codempid = p_codempid
             and dtereq   = p_dtereq
             and numseq   = p_numseq
             and approvno = v_approvno;
        end if;
        chk_workflow.find_next_approve(v_codapp,v_routeno,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,p_codempid,'');--user22 : 02/08/2016 : HRMS590307 || chk_workflow.find_next_approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_seqno,v_approvno,b_index_codempid);
      else
        exit ;
      end if;
    end loop ;

    tmedreq_approvno     := v_approvno ;
    tmedreq_routeno      := v_routeno ;
  end;
  --
  procedure save_tmedreq is
    v_count             number := 0;
    data_row            json_object_t;
    v_flg     	        varchar2(10 char);
    v_filename		    tmedreqf.filename%type;
    v_descfile		    tmedreqf.descfile%type;
    v_seqno		        tmedreqf.seqno%type;
    v_amtwidrwy		    tlmedexp.amtwidrwy%type;
    v_qtywidrwy		    tlmedexp.qtywidrwy%type;
    v_daybfst           tcontrbf.daybfst%type;
    v_mthbfst           tcontrbf.mthbfst%type;
    v_dtebfst           date;
    v_dtebfen           date;
    v_dtecancel         date;

  begin
    begin
      select count(*) into v_count
        from tmedreq
       where codempid = p_codempid
         and dtereq = p_dtereq
         and numseq = p_numseq;
    end;

    begin
      select typpayroll into p_typpayroll
        from temploy1
       where codempid = p_codempid;
    end;
----
/*
  begin
      select daybfst,mthbfst
        into v_daybfst, v_mthbfst
        from tcontrbf
       where codcompy   = hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec   = (select max(dteeffec)
                             from tcontrbf
                            where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                              and dteeffec <= sysdate);
    exception when no_data_found then
      v_daybfst := 1; v_mthbfst := 1;
    end;


    v_dtebfst   := to_date(v_daybfst||'/'||v_mthbfst||'/'||b_index_dteyear,'dd/mm/yyyy');
    v_dtebfen   := add_months(v_dtebfst,12) - 1;

     begin
     select amtwidrwy, qtywidrwy
       into v_amtwidrwy, v_qtywidrwy
       from tlmedexp
      where codcompy    = hcm_util.get_codcomp_level(p_codcomp,1)--'0004'
        and typamt      = p_typamt--'1'
        and typrel      = p_codrel;--'C';
        exception when no_data_found then
            v_amtwidrwy := 0;
            v_qtywidrwy := 0;
    end;
  */
    if v_count = 0 then
      begin
      insert into tmedreq ( codempid, dtereq, numseq, numvcher, codcomp, codpos, typpayroll,
                            codrel, namsick, codcln, coddc, typpatient, typamt, dtecrest, dtecreen,
                            dtebill, qtydcare, flgdocmt, numdocmt,
                            amtavai, amtexp, amtalw, amtovrpay, amtemp, amtpaid,
                            dtepaid, typpay, routeno, approvno, staappr, remarkap,
                            flgsend, flgagency,
                            dtecreate, codcreate, coduser )
          values (p_codempid, p_dtereq, p_numseq, p_numvcher, p_codcomp, p_codpos, p_typpayroll,
                  p_codrel, p_namsick, p_codcln, p_coddc, p_typpatient, p_typamt, p_dtecrest, p_dtecreen,
                  p_dtebill, p_qtydcare, p_flgdocmt, p_numdocmt,
                  p_amtavai, p_amtexp, p_amtalw, p_amtovrpay, p_amtemp, p_amtpaid,
                  p_dtepaid, p_typpay, tmedreq_routeno, tmedreq_approvno, tmedreq_staappr, tmedreq_remarkap,
                  'N', 'N',
                  trunc(sysdate), global_v_coduser, global_v_coduser );
        exception when others then
          param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        end;
    else
      begin
          if nvl(tmedreq_staappr,'P') <> 'C' then
             v_dtecancel := null;
          end if;

        update tmedreq
          set numvcher  = p_numvcher,
              codcomp = p_codcomp,
              codpos  = p_codpos,
              typpayroll  = p_typpayroll,
              codrel  = p_codrel,
              namsick = p_namsick,
              codcln  = p_codcln,
              coddc = p_coddc,
              typpatient  = p_typpatient,
              typamt  = p_typamt,
              dtecrest  = p_dtecrest,
              dtecreen  = p_dtecreen,
              dtebill = p_dtebill,
              qtydcare  = p_qtydcare,
              flgdocmt  = p_flgdocmt,
              numdocmt  = p_numdocmt,
              amtavai = p_amtavai,
              amtexp  = p_amtexp,
              amtalw  = p_amtalw,
              amtovrpay = p_amtovrpay,
              amtemp  = p_amtemp,
              amtpaid = p_amtpaid,
              dtepaid = p_dtepaid,
              typpay  = p_typpay,
              routeno = tmedreq_routeno,
              approvno  = tmedreq_approvno,
              staappr = tmedreq_staappr,
              remarkap  = tmedreq_remarkap,
              dtecancel = v_dtecancel,
              flgsend = 'N',
              flgagency = 'N',
              dteupd  = sysdate,
              coduser = global_v_coduser
        where codempid = p_codempid
          and dtereq = p_dtereq
          and numseq = p_numseq;
      end;
    end if;


      for i in 0..param_json_row.get_size-1 loop
        data_row  := hcm_util.get_json_t(param_json_row,to_char(i));
        v_flg     		  := hcm_util.get_string_t(data_row, 'flg');
        v_filename		  := hcm_util.get_string_t(data_row, 'filename');
        v_descfile		  := hcm_util.get_string_t(data_row, 'descfile');
        v_seqno		      := hcm_util.get_string_t(data_row, 'numseq');

        if v_flg = 'add' then
          begin
            select nvl(max(seqno),0)+1 into v_seqno
            from tmedreqf
            where codempid = p_codempid
             and dtereq = p_dtereq
              and numseq = p_numseq;
          exception when no_data_found then
            v_seqno := 1;
          end;

          begin
            insert into tmedreqf (codempid, dtereq, numseq, seqno, filename, descfile, dtecreate, codcreate, coduser)
            values (p_codempid, p_dtereq, p_numseq, v_seqno, v_filename, v_descfile, sysdate, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then null;
          end;

        elsif v_flg = 'delete' then
          delete tmedreqf
           where codempid = p_codempid
             and dtereq = p_dtereq
             and numseq = p_numseq
             and seqno = v_seqno;
        end if;

      end loop;
  end;
  --
  procedure initial_save (json_str in clob)is
    json_obj            json_object_t;
    obj_detail          json_object_t;
  begin
    json_obj      := json_object_t(json_str);
    obj_detail    := hcm_util.get_json_t(json_obj,'detail');
    param_json_row    := hcm_util.get_json_t(json_obj,'param_json');
    p_codempid    :=  hcm_util.get_string_t(obj_detail,'codempid');
    p_codcomp     :=  hcm_util.get_string_t(obj_detail,'codcomp');
    if p_codcomp is null then
      begin
        select codcomp
        into p_codcomp
        from temploy1
        where codempid = p_codempid;
      exception when no_data_found then
        p_codcomp := '';
      end;
    end if;
    p_codpos      :=  hcm_util.get_string_t(obj_detail,'codpos');
    p_numvcher    :=  hcm_util.get_string_t(obj_detail,'numvcher');
    p_dtereq      :=  to_date(hcm_util.get_string_t(obj_detail,'dtereq'),'dd/mm/yyyy');
    p_numseq      :=  hcm_util.get_string_t(obj_detail,'numseq');
    p_codrel      :=  hcm_util.get_string_t(obj_detail,'codrel');
    p_namsick     :=  hcm_util.get_string_t(obj_detail,'namsick');
    p_codcln      :=  hcm_util.get_string_t(obj_detail,'codcln');
    p_coddc       :=  hcm_util.get_string_t(obj_detail,'coddc');
    p_typpatient  :=  hcm_util.get_string_t(obj_detail,'typpatient');
    p_typamt      :=  hcm_util.get_string_t(obj_detail,'typamt');
    p_dtecrest    :=  to_date(hcm_util.get_string_t(obj_detail,'dtecrest'),'dd/mm/yyyy');
    p_dtecreen    :=  to_date(hcm_util.get_string_t(obj_detail,'dtecreen'),'dd/mm/yyyy');
    p_dtebill     :=  to_date(hcm_util.get_string_t(obj_detail,'dtebill'),'dd/mm/yyyy');
    p_qtydcare    :=  hcm_util.get_string_t(obj_detail,'qtydcare');
    p_flgdocmt    :=  hcm_util.get_string_t(obj_detail,'flgdocmt');
    p_numdocmt    :=  hcm_util.get_string_t(obj_detail,'numdocmt');
    p_amtalw      :=  hcm_util.get_string_t(obj_detail,'amtalw');
    p_amtexp      :=  hcm_util.get_string_t(obj_detail,'amtexp');
    p_amtavai     :=  hcm_util.get_string_t(obj_detail,'amtavai');
    p_amtovrpay   :=  hcm_util.get_string_t(obj_detail,'amtovrpay');
    p_amtemp      :=  hcm_util.get_string_t(obj_detail,'amtemp');
    p_amtpaid     :=  hcm_util.get_string_t(obj_detail,'amtpaid');
    p_dtepaid     :=  to_date(hcm_util.get_string_t(obj_detail,'dtepaid'),'dd/mm/yyyy');
    p_dteappr     :=  to_date(hcm_util.get_string_t(obj_detail,'dteappr'),'dd/mm/yyyy');
    p_codappr     :=  hcm_util.get_string_t(obj_detail,'codappr');
    p_staappr     :=  hcm_util.get_string_t(obj_detail,'staappr');
    p_typpay      :=  hcm_util.get_string_t(obj_detail,'typpay');
  exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end;
  procedure save_data (json_str_input in clob, json_str_output out clob) as
    obj_data            json_object_t;
    v_response    varchar2(4000 char);
  begin
    initial_value(json_str_input);
    initial_save(json_str_input);
    check_save(json_str_input);
--
    if param_msg_error is null then
      insert_next_step;
      if param_msg_error is null then
        save_tmedreq;
        commit;
      end if;
      --Generate Auto  รหัสบริษัท + ปี + Running  ตัวอย่าง   0001/63/0000001
--      begin
--        select count(*) + 1 into v_running
--          from tmedreq
--         where codcomp like v_codcomp||'%'
--           and to_char(dtereq,'yyyy') = to_char(sysdate,'yyyy');
--      end;
--      if v_numvcher is null then
--        v_numvcher := hcm_util.get_codcomp_level(v_codcomp, 1)||to_char(sysdate,'yy')||lpad(v_running,7,'0');
--      end if;
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
      obj_data.put('numvcher', p_numvcher);

      json_str_output := obj_data.to_clob;
      commit;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  procedure check_save (json_str in clob)is
    json_obj            json_object_t;
    obj_detail          json_object_t;
    v_codempid          tmedreq.codempid%type;
    v_dtereq            tmedreq.dtereq%type;
    v_numseq            tmedreq.numseq%type;
    v_codcln            tmedreq.codcln%type;
    v_coddc             tmedreq.coddc%type;
    v_typpatient        tmedreq.typpatient%type;
    v_typamt            tmedreq.typamt%type;
    v_dtecrest          tmedreq.dtecrest%type;
    v_dtecreen          tmedreq.dtecreen%type;
    v_dtebill           tmedreq.dtebill%type;
    v_flgdocmt          tmedreq.flgdocmt%type;
    v_amtexp            tmedreq.amtexp%type;
--    v_dtecrest          tmedreq.dtecrest%type;
    v_numvcher          tmedreq.numvcher%type;
--    v_typamt            tmedreq.typamt%type;
    v_codrel            tmedreq.codrel%type;
    v_staemp            temploy1.staemp%type;
    v_dteeffex          temploy1.dteeffex%type;
    v_numdocmt          tmedreq.numdocmt%type;

    v_amtwidrwy     number :=0;
    v_qtywidrwy     number :=0;
    v_amtwidrwt     number :=0;
    v_amtacc        number :=0;
    v_amtacc_typ    number :=0;
    v_qtyacc        number :=0;
    v_qtyacc_typ    number :=0;
    v_amtbal        number :=0;
    v_chk           number :=0;
    v_chk_doc       number :=0;
    v_qtyacc_typ_req number :=0;
    v_qtyacc_typ_req_all number :=0;
    v_qtyacc_req number :=0;

---
    v_codpos      temploy1.codpos%type;
    v_jobgrade    temploy1.jobgrade%type;
    v_codcomp     temploy1.codcomp%type;
    v_typemp      temploy1.typemp%type;
    v_numlvl      temploy1.numlvl%type;
    v_codempmt    temploy1.codempmt%type;
    v_dteempmt    temploy1.dteempmt%type;
    v_daybfst     tcontrbf.daybfst%type;
    v_mthbfst     tcontrbf.mthbfst%type;
    v_daybfen     tcontrbf.daybfen%type;
    v_mthbfen     tcontrbf.mthbfen%type;
    v_year        number :=0;
    v_dtestr      date;
    v_dteend      date;

    v_cnt1        number :=0;
    v_cnt2        number :=0;
    v_cnt3        number :=0;
    v_amtwidrwy1  number :=0;
    v_amtwidrwy2  number :=0;
    v_amtwidrwy3  number :=0;
    v_amtwidrwt1  number :=0;
    v_amtwidrwt2  number :=0;
    v_amtwidrwt3  number :=0;
    v_qtywidrwy1  number :=0;
    v_qtywidrwy2  number :=0;
    v_qtywidrwy3  number :=0;
    v_count       number :=0;
    v_flg_add     number :=0;
    v_stalife    varchar2(1 char);--User37 TDK #6709 19/08/2021

    v_typamt_a     varchar2(10);
    v_typrel_a       varchar2(10);

-----
  begin
    json_obj      := json_object_t(json_str);
    obj_detail    := hcm_util.get_json_t(json_obj,'detail');
    v_codempid    :=  hcm_util.get_string_t(obj_detail,'codempid');
    v_dtereq      :=  to_date(hcm_util.get_string_t(obj_detail,'dtereq'),'dd/mm/yyyy');
    v_numseq      :=  hcm_util.get_string_t(obj_detail,'numseq');
    v_codcln      :=  hcm_util.get_string_t(obj_detail,'codcln');
    v_coddc       :=  hcm_util.get_string_t(obj_detail,'coddc');
    v_typpatient  :=  hcm_util.get_string_t(obj_detail,'typpatient');
    v_typamt      :=  hcm_util.get_string_t(obj_detail,'typamt');
    v_dtecrest    :=  to_date(hcm_util.get_string_t(obj_detail,'dtecrest'),'dd/mm/yyyy');
    v_dtecreen    :=  to_date(hcm_util.get_string_t(obj_detail,'dtecreen'),'dd/mm/yyyy');
    v_dtebill     :=  to_date(hcm_util.get_string_t(obj_detail,'dtebill'),'dd/mm/yyyy');
    v_flgdocmt    :=  hcm_util.get_string_t(obj_detail,'flgdocmt');
    v_amtexp      :=  hcm_util.get_string_t(obj_detail,'amtexp');
    v_typamt      :=  hcm_util.get_string_t(obj_detail,'typamt');
    v_codrel      :=  hcm_util.get_string_t(obj_detail,'codrel');
    v_numvcher    :=  hcm_util.get_string_t(obj_detail,'numvcher');
    v_numdocmt    :=  hcm_util.get_string_t(obj_detail,'numdocmt');

    if v_codcln is null or v_coddc is null or v_typpatient is null or
       v_typamt is null or v_dtecrest is null or v_dtecreen is null or
       v_dtebill is null or v_flgdocmt is null or v_amtexp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    begin
      select staemp,dteeffex into v_staemp,v_dteeffex
      from temploy1
      where codempid = v_codempid;
    exception when no_data_found then
      v_staemp := null;
    end;
    if v_staemp = 9 then
      if v_dtecrest >= v_dteeffex then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      end if;
    end if;
    std_bf.get_medlimit(v_codempid, v_dtereq, v_dtecrest, v_numvcher, v_typamt, v_codrel,
                                   v_amtwidrwy, v_qtywidrwy, v_amtwidrwt, v_amtacc, v_amtacc_typ, v_qtyacc, v_qtyacc_typ, v_amtbal);

    begin
      select count(*)
        into v_count
        from tmedreq
       where codempid = v_codempid
         and dtereq   = v_dtereq
         and numseq   = v_numseq
         and staappr in ('P','A')
        and typamt    = v_typamt
        and codrel    = v_codrel;
    end;

    if v_count > 0 then
       v_flg_add := 0; --รายการใหม่
    else
       v_flg_add := 1; --รายการเดิม
    end if;

   begin
      select codpos,jobgrade,codcomp,typemp,numlvl,staemp,codempmt,dteempmt
        into v_codpos,v_jobgrade,v_codcomp,v_typemp,v_numlvl,v_staemp,v_codempmt,v_dteempmt
        from temploy1
       where codempid  = v_codempid;
    exception when no_data_found then return;
    end;
    begin
      select daybfst, mthbfst, daybfen, mthbfen
        into v_daybfst, v_mthbfst, v_daybfen, v_mthbfen
        from tcontrbf
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontrbf
                          where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                            and dteeffec <= sysdate);
    exception when no_data_found then return;
    end;

    if v_daybfst is null or v_mthbfst is null or v_daybfen is null or v_mthbfen is null then
      return;
    end if;

    if v_mthbfst >  v_mthbfen  then
      v_year := to_char(sysdate,'yyyy')-1;
      v_dtestr := to_date(v_daybfst||'/'||v_mthbfst||'/'||v_year,'dd/mm/yyyy');
      v_dteend := to_date(v_daybfen||'/'||v_mthbfen||'/'||to_char(sysdate,'yyyy'),'dd/mm/yyyy');
    else
      v_year := to_char(sysdate,'yyyy');
      v_dtestr := to_date(v_daybfst||'/'||v_mthbfst||'/'||v_year,'dd/mm/yyyy');
      v_dteend := to_date(v_daybfen||'/'||v_mthbfen||'/'||to_char(sysdate,'yyyy'),'dd/mm/yyyy');
    end if;
       begin
        select count(*)
        into v_qtyacc_typ_req
        from tmedreq
       where codempid = v_codempid
        -- and trunc(dtereq) = trunc(sysdate)
        and trunc(dtereq) between v_dtestr and v_dteend
        and staappr in ('P','A')
        and typamt    = v_typamt
        and codrel    = v_codrel;
      exception when no_data_found then
        v_qtyacc_typ_req := 0;
      end;

/*
       begin
          select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
            into v_cnt1,v_amtwidrwy1,v_amtwidrwt1,v_qtywidrwy1
            from tlmedexp
           where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
             --and numseq   = r1.numseq
             and typamt   = v_typamt
             and typrel   = decode(v_codrel,'M','F',v_codrel);
        end;
*/
--<<Error ST11/STT-SS-2201/redmine9079
    std_bf.get_condtypamt(v_codempid,v_dtereq,v_dtecrest,v_numvcher,v_typamt,v_codrel,
                          v_amtwidrwy1,v_qtywidrwy1,v_amtwidrwt1,v_typamt_a,v_typrel_a,
                          v_amtwidrwy2,v_qtywidrwy2,v_amtwidrwt2);
-->>Error ST11/STT-SS-2201/redmine9079

--<< user22 : 26/01/2023 || https://hrmsd.peopleplus.co.th:4449/redmine/issues/548
    if nvl(v_amtwidrwy1,0) = 0 and nvl(v_amtwidrwy2,0) = 0 then
      param_msg_error := get_error_msg_php('HR6541',global_v_lang);
      return;
    end if;
-->> user22 : 26/01/2023 || https://hrmsd.peopleplus.co.th:4449/redmine/issues/548

    v_qtyacc_typ := v_qtyacc_typ + v_qtyacc_typ_req + v_flg_add      ;
    if nvl(v_qtywidrwy1,0) <> 0 then
         if nvl(v_qtyacc_typ,0) > nvl(v_qtywidrwy1,0) then
        --if nvl(v_qtyacc_typ,0) > nvl(v_qtywidrwy,0) then
          --param_msg_error := get_error_msg_php('HR6543'||'==='||v_qtywidrwy1,global_v_lang);
          param_msg_error := get_error_msg_php('HR6543',global_v_lang);
          return;
        end if;
    end if;
    begin
        select count(*)
        into v_qtyacc_typ_req_all
        from tmedreq
       where codempid = v_codempid
      --   and trunc(dtereq) = trunc(sysdate)
        and trunc(dtereq) between v_dtestr and v_dteend
        and staappr in ('P','A')
        and codrel    = v_codrel;
      exception when no_data_found then
        v_qtyacc_typ_req_all := 0;
    end;

    if nvl(v_qtywidrwy2,0) <> 0 then
         if (nvl(v_qtyacc,0)+ nvl(v_qtyacc_typ_req_all,0))+ v_flg_add  > nvl(v_qtywidrwy2,0) then
         -- if (nvl(v_qtyacc,0)+ nvl(v_qtyacc_typ_req_all,0))+ v_flg_add  > nvl(v_qtywidrwy,0) then
              param_msg_error := get_error_msg_php('HR6544',global_v_lang);
          return;
        end if;
    end if;
  -----

    begin
      select  count(*)
      into v_chk_doc
      from tclndoc
      where numdocmt = v_numdocmt
      and nvl(stadocmt,'N') = 'Y';
    end;

    if v_chk_doc > 0 then
      param_msg_error := get_error_msg_php('BF0072',global_v_lang);
      return;
    end if;

  --<<User37 TDK #6709 19/08/2021
    v_stalife := check_stalife(v_codempid , v_codrel, p_namsick, global_v_lang);
    if v_stalife = 'N' then
      param_msg_error := get_error_msg_php('HR0009',global_v_lang);
      return;
    end if;
  -->>User37 TDK #6709 19/08/2021

    begin
        select count(*)
          into v_chk
          from tclnsinf
         where flgdocmt = 'Y';
    end;
  exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end;

  procedure send_mail (json_str_input in clob, json_str_output out clob) is
		v_number_mail		  number := 0;
		json_obj		      json_object_t;
		param_object		  json_object_t;
		param_json_row		json_object_t;
		p_typemail		    varchar2(500);
        v_codempid		    temploy1.codempid%type;
        v_codcomp         temploy1.codcomp%type;
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
        v_approvno        tmedreq.approvno%type;
	begin
		initial_value(json_str_input);
        p_codapp      := 'HRBF16E';

        begin
          select rowid, nvl(approvno,0) + 1 as approvno
            into v_rowid,v_approvno
            from tmedreq
           where numvcher = p_numvcher
             and codempid = p_codempid;
        exception when no_data_found then
            v_approvno := 1;
        end;

        v_error := chk_flowmail.send_mail_for_approve('HRBF16E', p_codempid, global_v_codempid, global_v_coduser, null, 'HRBF16E2', 450, 'E', 'P', v_approvno, null, null,'TMEDREQ',v_rowid, '1', null);

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

  procedure cancel_data (json_str_input in clob, json_str_output out clob) as
    param_json          json_object_t;
    param_json_row      json_object_t;
    param_index         json_object_t;

    v_flg	            varchar2(1000 char);
    v_flgupd	        varchar2(1000 char);
    v_numvcher	        varchar2(1000 char);
    v_staappr           varchar2(1 char);

  begin
    initial_value(json_str_input);

    begin
      select staappr into v_staappr
        from tmedreq
       where codempid = p_codempid
         and dtereq   = p_dtereq
         and numseq   = p_numseq;
    exception when no_data_found then
      v_staappr := 'P';
    end;    

    if v_staappr in ('A','Y','N') then
        param_msg_error := get_error_msg_php('HR1490',global_v_lang);
        return;    
    end if;

    begin
      update tmedreq
         set staappr = 'C',
             dtecancel = trunc(sysdate),
             coduser = global_v_coduser
       where codempid = p_codempid
         and dtereq = p_dtereq
         and numseq = p_numseq;
    exception when no_data_found then
      null;
    end;
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
end hres71e;

/

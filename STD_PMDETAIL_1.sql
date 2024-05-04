--------------------------------------------------------
--  DDL for Package Body STD_PMDETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_PMDETAIL" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codapp            := hcm_util.get_string_t(json_obj,'psearch_codapp');
    numYearReport       := HCM_APPSETTINGS.get_additional_year();

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure vadidate_variable_get_emp_info(json_str_input in clob) as
    json_obj  json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    p_codempid          := hcm_util.get_string_t(json_obj,'psearch_codempid');
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return ;
  end vadidate_variable_get_emp_info;
  procedure gen_emp_info(json_str_output out clob)as
    obj_data        json_object_t;
    statuscode      varchar2(1 char);

    cursor c_temploy1 is
      select get_temploy_name(codempid,global_v_lang) temployname, codempid, codcomp,
             get_tcenter_name(codcomp,global_v_lang) tcentername, get_tpostn_name(codpos,global_v_lang) tpostnname,
             dteempmt, dteeffex, staemp, dteretire
        from temploy1
       where codempid = p_codempid;

    temploy1_rec            c_temploy1%ROWTYPE;
    p_ttrehire_dtereemp     TTREHIRE.dtereemp%TYPE;
    p_ttrehire_codpos       TTREHIRE.codpos%TYPE;
    p_ttrehire_codbrlc      TTREHIRE.codbrlc%TYPE;
    v_dteretire             ttexempt.dteeffec%type;

    v_temployname       varchar2(1000 char);
    v_codempid          temploy1.codempid%type;
    v_codcomp           temploy1.codcomp%type;
    v_tcentername       varchar2(1000 char);
    v_tpostnname        varchar2(1000 char);
    v_dteempmt          temploy1.dteempmt%type;
    v_dteeffex          temploy1.dteeffex%type;
    v_status            varchar2(1000 char);
    v_image             varchar2(1000 char);
    v_flgimg            varchar2(2 char) := 'N';
  begin
    begin
      select max(dteeffec) into v_dteretire
        from ttexempt
       where codempid   =   p_codempid
         and dteeffec   <=  sysdate ;
    exception when no_data_found then
      v_dteretire := null;
    end;

    statuscode := '';

    begin
     select nvl(max(numseq),0)
       into v_numseq
       from ttemprpt
      where codempid = global_v_codempid
        and codapp = upper(p_codapp);
    exception when no_data_found then
      v_numseq := 0;
    end;
    if v_numseq is null then
      v_numseq := 0;
    end if;

    OPEN c_temploy1;
    FETCH c_temploy1 INTO temploy1_rec;
    obj_data := json_object_t();

    obj_data.put('coderror', '200');
    obj_data.put('response','');
    obj_data.put('temployname', temploy1_rec.temployname);
    obj_data.put('codempid',temploy1_rec.codempid);
    obj_data.put('codcomp',temploy1_rec.codcomp);
    obj_data.put('tcentername', temploy1_rec.tcentername);
    obj_data.put('tpostnname', temploy1_rec.tpostnname);
    obj_data.put('dteempmt', to_char(temploy1_rec.dteempmt, 'dd/mm/yyyy') );
    obj_data.put('dteeffex', to_char(temploy1_rec.dteeffex, 'dd/mm/yyyy') );
    obj_data.put('status', get_tlistval_name('FSTAEMP', temploy1_rec.staemp,global_v_lang));

    v_temployname     := temploy1_rec.temployname;
    v_codempid        := temploy1_rec.codempid;
    v_codcomp         := temploy1_rec.codcomp;
    v_tcentername     := temploy1_rec.tcentername;
    v_tpostnname      := temploy1_rec.tpostnname;
    v_dteempmt        := temploy1_rec.dteempmt;
    v_dteeffex        := to_char(temploy1_rec.dteeffex, 'dd/mm/yyyy');
    v_status          := get_tlistval_name('FSTAEMP', temploy1_rec.staemp,global_v_lang);
    if (v_dteretire is null) then
      obj_data.put('dteretire','');
    else
      obj_data.put('dteretire',to_char(v_dteretire, 'dd/mm/yyyy'));
    end if;
    close c_temploy1;

    begin
      select dtereemp,codpos,codbrlc
        into p_ttrehire_dtereemp,p_ttrehire_codpos,p_ttrehire_codbrlc
        from ttrehire
       where dtereemp = (select max(dtereemp)
                           from ttrehire
                          where codempid = p_codempid)
         and codempid = p_codempid;

      obj_data.put('ttrehiredtereemp',to_char(p_ttrehire_dtereemp,'dd/mm/yyyy'));
      obj_data.put('ttrehirecodpos', get_tpostn_name(p_ttrehire_codpos,global_v_lang));
    exception when no_data_found then
      obj_data.put('ttrehiredtereemp','');
      obj_data.put('ttrehirecodpos','');
    end;

     begin
      select '/'||get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E1')||'/'||namimage
        into v_image
       from tempimge
       where codempid = p_codempid;
       v_flgimg := 'Y';
    exception when no_data_found then
      v_image := '';
      v_flgimg := 'N';
    end;
    if p_codapp is not null then
      v_numseq := v_numseq + 1;
      INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                            ITEM5,ITEM6,ITEM7,ITEM8, ITEM9,ITEM10,ITEM11,ITEM12,ITEM13,ITEM14)
                          VALUES (global_v_codempid, upper(p_codapp),v_numseq,'HEAD',v_codempid,
                                  v_temployname, v_tcentername, v_tpostnname,
                                  to_char(add_months(to_date(to_char(p_ttrehire_dtereemp,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                                  to_char(add_months(to_date(to_char(v_dteempmt,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                                  to_char(add_months(to_date(to_char(v_dteretire,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                                  v_status,
                                  get_tcodloca_name(p_ttrehire_codbrlc,global_v_lang), v_image, v_flgimg);
    end if;
    json_str_output := obj_data.to_clob;
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_data.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_emp_info;
  procedure get_emp_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    vadidate_variable_get_emp_info(json_str_input);
    v_item1 := 'HEAD';
    clear_ttemprpt;   --item1 HEAD
    gen_emp_info(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_approve_remain(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    v_item1 := 'TAB1';
    clear_ttemprpt;  -- item1  TAB1
    vadidate_gen_approve_remain(json_str_input);
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
     gen_approve_remain(json_str_output);
     if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
     end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_approve_remain;
  procedure vadidate_gen_approve_remain(json_str_input in clob) as
  jsonObj json_object_t := json_object_t(json_str_input);
  begin
  p_codempid :=  hcm_util.get_string_t(jsonObj,'psearch_codempid');
  if (p_codempid = ' ' or p_codempid is null) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
    return;
  end if;
  end vadidate_gen_approve_remain;
  procedure gen_approve_remain(json_str_output out clob)as
      obj_data        json_object_t;
      obj_row         json_object_t;
      v_rcnt             number;
      cursor c_tloaninf is
         select 'HRES71E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from tmedreq a,twkflowh b
              where a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES71E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES71E')))
              union all
              --- HRES74E
              select 'HRES74E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from tobfreq a,twkflowh b
              where a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES74E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES74E')))
              union all
              --- HRES77E
              select 'HRES77E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from tloanreq a,twkflowh b
              where a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES77E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES77E')))
              union all
              --- HRES32E
              select 'HRES32E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from tempch a,twkflowh b
              where a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES32E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES32E')))
              --- HRES36E
              union all
              select 'HRES36E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from trefreq a,twkflowh b
              where a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES36E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES36E')))
              --- HRES62E
              union all
              select 'HRES62E' codapp,a.codempid, a.dtereq, a.SEQNO numseq, a.staappr, a.remarkap remark
              from tleaverq a,twkflowh b
              where a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES62E',codempid,dtereq,a.SEQNO,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES62E')))
              --- 'HRES6AE'
              union all
              select 'HRES6AE' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from ttimereq a,twkflowh b
              where  a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES6AE',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES6AE')))
              --- 'HRES34E'
              union all
              select 'HRES34E' codapp,  a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from tmovereq a,twkflowh b
              where  a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES34E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES34E')))
              ---- HRES6DE
              union all
              select 'HRES6DE' codapp, a.codempid, a.dtereq, a.SEQNO numseq, a.staappr, a.remarkap remark
              from tworkreq a,twkflowh b
              where  a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES6DE',codempid,dtereq,SEQNO,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES6DE')))
              ---- 'HRES6IE'
              union all
              select 'HRES6IE' codapp, a.codempid, a.dtereq, a.SEQNO numseq, a.staappr, a.remarkap remark
              from tworkreq a,twkflowh b
              where  a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES6IE',codempid,dtereq,SEQNO,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES6IE')))
              --- 'HRES6KE'
              union all
              select 'HRES6KE' codapp, a.codempid, a.dtereq, a.SEQNO numseq, a.staappr, a.remarkap remark
              from tworkreq a,twkflowh b
              where  a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES6KE',codempid,dtereq,SEQNO,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES6KE')))
              --- 'HRES81E'
              union all
              select 'HRES81E' codapp, a.codempid, a.dtereq, a.SEQNO numseq, a.staappr, a.remarkap remark
              from tworkreq a,twkflowh b
              where  a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES81E',codempid,dtereq,SEQNO,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES81E')))
              union all
              --- 'HRES86E'
              select 'HRES86E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from tresreq a,twkflowh b
              where  a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES86E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES86E')))
              union all
              --- 'HRES88E'
              select 'HRES88E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from tjobreq a,twkflowh b
               where  a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES88E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES88E')))
              union all
              --- 'HRESS2E'
              select 'HRESS2E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from tjobreq a,twkflowh b
               where  a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRESS2E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRESS2E')))
              union all
              -- HRES3BE
              select 'HRES3BE' codapp, a.codempid, a.dtecompl dtereq,null numseq, a.stacompl staappr, null remark
              from tcompln a,twkflowh b
              where a.routeno = b.routeno
              and a.stacompl in ('N','D')
              and 'Y' = chk_workflow.check_privilege('HRES3BE',a.codempid,a.dtecompl,a.numcomp,1,p_codempid)
              union all
              -- HRESS4E
              select 'HRESS4E' codapp,  a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from tircreq a,twkflowh b
              where  a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRESS4E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRESS4E')))
              union all
              --- HRES6ME
              select 'HRES6ME' codapp, a.codempid, a.dtereq, a.SEQNO numseq, a.staappr, a.remarkap remark
              from tleavecc a,twkflowh b
              where a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES6ME',codempid,dtereq,SEQNO,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES6ME')))
              union all
              --- HRES95E
              select 'HRES95E' codapp,a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from treplacerq a,twkflowh b
              where  a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES6ME',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES6ME')))
              --- 'HRES91E'
              union all
              select 'HRES91E' codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
              from ttrncerq a,twkflowh b
              where a.routeno = b.routeno
              and staappr in ('P','A')
              and ('Y' = chk_workflow.check_privilege('HRES91E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),p_codempid)
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
              from twkflowde c
              where c.routeno  = a.routeno
              and c.codempid = p_codempid)
              and (((sysdate - nvl(dteapph,dteinput))*1440)/60) >= (select  hrtotal  from twkflpf where codapp ='HRES91E')));

    begin

      obj_row := json_object_t();
      v_rcnt := 0;
      begin
       select max(numseq)
         into v_numseq
         from ttemprpt
        where codempid = global_v_codempid
          and codapp = upper(p_codapp);
      exception when no_data_found then
        v_numseq := 1;
      end;
      if v_numseq is null then
        v_numseq := 1;
      end if;
      for r1 in c_tloaninf loop
           -- codapp, a.codempid, a.dtereq, a.numseq, a.staappr, a.remarkap remark
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('response','');
          obj_data.put('codapp',r1.codapp);
          obj_data.put('image',get_emp_img(r1.codempid));
          obj_data.put('codapp_desc',get_tappprof_name(r1.codapp,1,global_v_lang));
          obj_data.put('codempid',r1.codempid);
          obj_data.put('codempname',get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('dtereq',to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('numseq',r1.numseq);
          obj_data.put('staappr',r1.staappr);
          obj_data.put('staappr_desc',GET_TLISTVAL_NAME('STAAPPR',r1.staappr,global_v_lang));
          obj_data.put('remark',r1.remark);

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt := v_rcnt + 1;
          if p_codapp is not null then
            v_numseq := v_numseq + 1;
            --Report insert TTEMPRPT
            insert into ttemprpt(CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                                 ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,ITEM12)
                 values (global_v_codempid, upper(p_codapp),v_numseq,'TAB1',p_codempid,
                         get_tappprof_name(r1.codapp,'1',global_v_lang),
                         r1.codempid,
                         get_temploy_name(r1.codempid,global_v_lang),
                         get_emp_img(r1.codempid),
                         to_char(add_months(to_date(to_char(r1.dtereq,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                         r1.numseq,
                         get_tlistval_name('STAAPPR',r1.staappr,global_v_lang),
                         r1.remark);
          end if;
      end loop;
      if v_rcnt = 0 then
        --update check has data
        begin
          update ttemprpt
             set item15 = 'N'
           where codempid = global_v_codempid
             and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
        end;
      else
        begin
          update ttemprpt
             set item15 = 'Y'
           where codempid = global_v_codempid
             and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
        end;
      end if;
--      dbms_lob.createtemporary(json_str_output, true);
--      obj_row.to_clob(json_str_output);
      json_str_output := obj_row.to_clob;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_approve_remain;

  procedure get_tloaninf_info(json_str_input in clob, json_str_output out clob) as
  begin
      initial_value(json_str_input);
      validate_tloaninf_info(json_str_input);
      v_item1 := 'TAB2';
      clear_ttemprpt; -- item1 TAB2
      if (param_msg_error <> ' ' or param_msg_error is not null) then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      else
          gen_tloaninf_info(json_str_output);
          if (param_msg_error <> ' ' or param_msg_error is not null) then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          end if;
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tloaninf_info;
  procedure validate_tloaninf_info(json_str_input in clob) as
  jsonObj json_object_t := json_object_t(json_str_input);
  begin
      p_codempid :=  hcm_util.get_string_t(jsonObj,'psearch_codempid');
      if (p_codempid = ' ' or p_codempid is null) then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
      end if;
  end validate_tloaninf_info;

  procedure gen_tloaninf_info( json_str_output out clob) as
    cursor c_tloaninf is
      select dtelonst,numcont,get_ttyploan_name(codlon,global_v_lang) codlon,
             amtlon,nvl(amtnpfin,0)+nvl(amtintovr,0) balance,numlon,
             qtyperiod,qtyperip
        from tloaninf
       where amtnpfin <> 0
         and staappr = 'Y'
         and STALON <> 'C'
         and codempid = p_codempid;

     objRowJson json_object_t;
     objColJson json_object_t;
     countRow number  := 0;
  begin
    objRowJson := json_object_t();
    begin
     select max(numseq)
       into v_numseq
       from ttemprpt
      where codempid = global_v_codempid
        and codapp = upper(p_codapp);
    exception when no_data_found then
      v_numseq := 1;
    end;
    if v_numseq is null then
      v_numseq := 1;
    end if;
    for r1 in c_tloaninf loop
      objColJson := json_object_t();
      objColJson.put('coderror', '200');
      objColJson.put('response','');
      objColJson.put('dtelonst', to_char(r1.dtelonst, 'dd/mm/yyyy'));
      objColJson.put('numcont', r1.numcont);
      objColJson.put('codlon', r1.codlon);
      objColJson.put('amtlon',r1.amtlon);
      objColJson.put('balance',r1.balance);
      objColJson.put('numlon',r1.numlon);
      objColJson.put('qtyperiod',r1.qtyperiod);
      objColJson.put('qtyperip',r1.qtyperip);

      objRowJson.put(to_char(countRow), objColJson);
      countRow := countRow + 1;
      if p_codapp is not null then
        v_numseq := v_numseq + 1;
        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                              ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,ITEM12)
             VALUES (global_v_codempid, upper(p_codapp),v_numseq,'TAB2',p_codempid,
                     to_char(add_months(to_date(to_char(r1.dtelonst,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                     r1.numcont, r1.codlon, r1.amtlon, r1.balance, r1.numlon, r1.qtyperiod, r1.qtyperip);
      end if;
    end loop;
    if countRow = 0 then
        --update check has data
        begin
          update ttemprpt
             set item16 = 'N'
           where codempid = global_v_codempid
             and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
        end;
      else
        begin
          update ttemprpt
             set item16 = 'Y'
           where codempid = global_v_codempid
             and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
        end;
    end if;
    json_str_output := objRowJson.to_clob;
--    dbms_lob.createtemporary(json_str_output, true);
--    objRowJson.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tloaninf_info;

  procedure get_trepay_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_trepay_info(json_str_input);
    v_item1 := 'TAB3';
    clear_ttemprpt; -- item1 TAB3
     if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
       gen_trepay_info(json_str_output);
        if (param_msg_error <> ' ' or param_msg_error is not null) then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_trepay_info;
  procedure validate_trepay_info(json_str_input in clob) as
  jsonObj json_object_t := json_object_t(json_str_input);
  begin
    p_codempid :=  hcm_util.get_string_t(jsonObj,'psearch_codempid');
        if (p_codempid = ' ' or p_codempid is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
        end if;
  end validate_trepay_info;
  procedure gen_trepay_info(json_str_output out clob)as
    obj_data        json_object_t;
    v_dtestrpm      varchar2(100 char);
    v_tmp_dtestrpm      varchar2(100 char);
    v_dtelstpay     varchar2(100 char);
    v_tmp_dtelstpay     varchar2(100 char);
    cursor c_trepay is
        select qtyrepaym,
        amtrepaym,
        dtestrpm as dtestrpm,
        dtelstpay as dtelstpay,
        amtoutstd,
        amtoutstd - amttotpay balance,
        qtypaid
        from trepay
        where codempid = p_codempid
        and dteappr = (
            select max(dteappr)
              from trepay
             where codempid = p_codempid
               and dteappr <= trunc(sysdate)
        );
      isHasData boolean := false;
  begin
    begin
     select max(numseq)
       into v_numseq
       from ttemprpt
      where codempid = global_v_codempid
        and codapp = upper(p_codapp);
    exception when no_data_found then
      v_numseq := 1;
    end;
    if v_numseq is null then
      v_numseq := 1;
    end if;
    obj_data := json_object_t();
    for r1 in c_trepay loop
      v_tmp_dtestrpm := replace(r1.dtestrpm,'/','');
      v_tmp_dtelstpay := replace(r1.dtelstpay,'/','');
      v_dtestrpm := '';
      v_dtelstpay := '';
      if v_tmp_dtestrpm is not null then
        v_dtestrpm  := substr(v_tmp_dtestrpm,7,2)||'/'||substr(v_tmp_dtestrpm,5,2)||'/'||substr(v_tmp_dtestrpm,1,4);
      end if;
      if v_tmp_dtelstpay is not null then
        v_dtelstpay  := substr(v_tmp_dtelstpay,7,2)||'/'||substr(v_tmp_dtelstpay,5,2)||'/'||substr(v_tmp_dtelstpay,1,4);
      end if;
      obj_data.put('coderror', '200');
      obj_data.put('qtyrepaym', r1.qtyrepaym);
      obj_data.put('amtrepaym', to_char(r1.amtrepaym,'999,999,990.00'));
      obj_data.put('dtestrpm', v_dtestrpm);
      obj_data.put('dtelstpay',v_dtelstpay);
      obj_data.put('amtoutstd',to_char(r1.amtoutstd,'999,999,990.00'));
      obj_data.put('balance',to_char(r1.balance,'999,999,990.00'));
      obj_data.put('qtypaid',r1.qtypaid);
      isHasData := true;

      if p_codapp is not null then
        v_numseq := v_numseq + 1;
        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11)
             VALUES (global_v_codempid, upper(p_codapp),v_numseq,'TAB3',p_codempid,
                    r1.qtyrepaym, r1.amtrepaym, r1.qtypaid, r1.amtoutstd, 
                    hcm_util.get_date_buddhist_era(to_date(v_dtestrpm,'dd/mm/yyyy')), 
                    r1.balance, 
                    hcm_util.get_date_buddhist_era(to_date(v_dtelstpay,'dd/mm/yyyy')));
      end if;
    end loop;

    if (not isHasData) then
        obj_data.put('coderror', '200');
        obj_data.put('qtyrepaym', '');
        obj_data.put('amtrepaym', '');
        obj_data.put('dtestrpm','');
        obj_data.put('amtoutstd','');
        obj_data.put('balance','');
        obj_data.put('qtypaid','');
        obj_data.put('dtelstpay','');

      --update check has data
      begin
        update ttemprpt
           set item17 = 'N'
         where codempid = global_v_codempid
           and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
      end;
    else
      begin
        update ttemprpt
           set item17 = 'Y'
         where codempid = global_v_codempid
           and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
      end;
    end if;
    json_str_output := obj_data.to_clob;
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_data.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_trepay_info;

  procedure get_tfunddet_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_tfunddet_info(json_str_input);
    v_item1 := 'TAB4';
    clear_ttemprpt; -- item1 TAB4
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      gen_tfunddet_info(json_str_output);
      if (param_msg_error <> ' ' or param_msg_error is not null) then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end  get_tfunddet_info;
  procedure validate_tfunddet_info(json_str_input in clob) as
    jsonObj json_object_t;
    v_dteeffexStr VARCHAR2(10 CHAR);
  begin
    jsonObj       := json_object_t(json_str_input);
    p_codempid    := hcm_util.get_string_t(jsonObj,'psearch_codempid');
    v_dteeffexStr := hcm_util.get_string_t(jsonObj,'psearch_dteeffex');

    if (p_codempid = ' ' or p_codempid is null) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    begin
      v_dteeffex := (to_date(trim(v_dteeffexStr), 'dd/mm/yyyy')) -1 ;
    exception  when others then
      v_dteeffex := sysdate;
    end;
  end validate_tfunddet_info;
  procedure gen_tfunddet_info( json_str_output out clob) as
   objRowJson json_object_t;
   objColJson json_object_t;
   countRow number := 0 ;
   cursor c_fundtrnn is
     select codcours,get_tcourse_name(codcours,global_v_lang) namcourse,flgcommt,descommt,dtecntr,
            qtytrpln,dtetrst
        from thistrnn
       where codempid  = p_codempid
         and flgcommt  = 'Y'
       order by dtecntr,codcours,dteyear,numclseq;
  begin
    begin
     select max(numseq)
       into v_numseq
       from ttemprpt
      where codempid = global_v_codempid
        and codapp = upper(p_codapp);
    exception when no_data_found then
      v_numseq := 1;
    end;
    if v_numseq is null then
      v_numseq := 1;
    end if;
    objRowJson := json_object_t();
    for r1 in c_fundtrnn loop
      objColJson := json_object_t();
      objColJson.put('coderror', '200');
      objColJson.put('response','');

      objColJson.put('codcours', r1.codcours);
      objColJson.put('namcourse', r1.namcourse);
      objColJson.put('descommt', r1.descommt);
      objColJson.put('dtecntr', to_char(r1.dtecntr,'dd/mm/yyyy'));
      objColJson.put('period', r1.qtytrpln);
      objColJson.put('dtereq', to_char(r1.dtetrst,'dd/mm/yyyy'));

      objRowJson.put(to_char(countRow), objColJson);
      countRow := countRow + 1;
      if p_codapp is not null then
        v_numseq := v_numseq + 1;
        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10)
        VALUES (global_v_codempid,upper(p_codapp),v_numseq,'TAB4',p_codempid,
                r1.codcours,r1.namcourse,r1.descommt,r1.qtytrpln,
                to_char(add_months(to_date(to_char(r1.dtetrst,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                to_char(add_months(to_date(to_char(r1.dtecntr,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'));
      end if;
    end loop;
    if countRow = 0 then
      --update check has data
      begin
        update ttemprpt
           set item18 = 'N'
         where codempid = global_v_codempid
           and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
      end;
    else
      begin
        update ttemprpt
           set item18 = 'Y'
         where codempid = global_v_codempid
           and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
      end;
    end if;
    json_str_output := objRowJson.to_clob;
--    dbms_lob.createtemporary(json_str_output, true);
--    objRowJson.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tfunddet_info;

  procedure get_tcolltrl_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_tcolltrl_info(json_str_input);
    v_item1 := 'TAB10';
    clear_ttemprpt; --item1 TAB10
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      gen_tcolltrl_info(json_str_output);
      if (param_msg_error <> ' ' or param_msg_error is not null) then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tcolltrl_info;
  procedure validate_tcolltrl_info (json_str_input in clob)as
    jsonObj json_object_t;
  begin
    jsonObj := json_object_t(json_str_input);
    p_codempid :=    hcm_util.get_string_t(jsonObj,'psearch_codempid');

    if (p_codempid = ' ' or p_codempid is null) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end validate_tcolltrl_info;

  procedure gen_tcolltrl_info(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number;
    v_folder        varchar2(1000 char);
    cursor c_tcolltrl is
      select --<<user37 #2035 Final Test Phase 1 V11 28/01/2021
             /*numcolla,typcolla codtypcol,get_tcodec_name('TCODCOLA',typcolla,global_v_lang) desc_typcolla,descoll,numdocum,
             dtecolla,dtestrt,dteend,dteeffec,dtertdoc,filename,
             qtyperiod,nvl(amtcolla,0) amtcolla,nvl(amtdedcol,0) amtdedcol,nvl(amtded,0) amtded,
             nvl(amtcolla,0) - nvl(amtdedcol,0) amtbalance,staded,flgded,status*/
             numcolla,typcolla codtypcol,get_tcodec_name('TCODCOLA',typcolla,global_v_lang) desc_typcolla,descoll,numdocum,
             dtecolla,dtestrt,dteend,dteeffec,dtertdoc,filename,
             qtyperiod,
             nvl(stddec(amtcolla,p_codempid,v_chken),0) amtcolla,
             nvl(stddec(amtdedcol,p_codempid,v_chken),0) amtdedcol,
             nvl(stddec(amtded,p_codempid,v_chken),0) amtded,
             nvl(stddec(amtcolla,p_codempid,v_chken),0) - nvl(stddec(amtdedcol,p_codempid,v_chken),0) amtbalance,
             staded,flgded,status
             -->>user37 #2035 Final Test Phase 1 V11 28/01/2021
        from tcolltrl
       where codempid = p_codempid
         and staded not in ('N','C')
       order by dtecolla;
  begin

    obj_row := json_object_t();
    v_rcnt := 0;
    begin
      select get_tsetup_value('PATHDOC')||folder
        into v_folder
        from tfolderd
       where codapp = 'HRPMC2E';
    exception when no_data_found then
       v_folder := '';
    end;
    begin
     select max(numseq)
       into v_numseq
       from ttemprpt
      where codempid = global_v_codempid
        and codapp = upper(p_codapp);
    exception when no_data_found then
      v_numseq := 1;
    end;
    if v_numseq is null then
      v_numseq := 1;
    end if;
    for r1 in c_tcolltrl loop
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numcolla', r1.numcolla);
        obj_data.put('codtypcol', r1.codtypcol);
        obj_data.put('typcolla', r1.desc_typcolla);
        obj_data.put('descoll', r1.descoll);
        obj_data.put('numdocum',r1.numdocum);
        obj_data.put('dtecolla',to_char(r1.dtecolla, 'dd/mm/yyyy'));
        obj_data.put('dtestrt',to_char(r1.dtestrt,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(r1.dteend,'dd/mm/yyyy'));
        obj_data.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
        obj_data.put('dtertdoc',to_char(r1.dtertdoc,'dd/mm/yyyy'));
        obj_data.put('path_filename',v_folder||'/'||r1.filename);
        obj_data.put('filename',r1.filename);
        obj_data.put('qtyperiod',r1.qtyperiod);
        obj_data.put('amtded',to_char(r1.amtded,'999,999,990.00'));
        obj_data.put('amtcolla',to_char(r1.amtcolla,'999,999,990.00'));
        obj_data.put('amtdedcol',to_char(r1.amtdedcol,'999,999,990.00'));
        obj_data.put('amtbalance',to_char(r1.amtbalance,'999,999,990.00'));
        if r1.status = 'A' then
          obj_data.put('status',get_label_name('HRRC21E4P2',global_v_lang,130));
        else
          obj_data.put('status',get_label_name('HRRC21E4P2',global_v_lang,140));
        end if;
        if r1.staded = 'Y' then
          obj_data.put('staded','Yes');
        else
          obj_data.put('staded','No');
        end if;
        if r1.flgded = 'Y' then
          obj_data.put('flgded','Yes');
        else
          obj_data.put('flgded','No');
        end if;
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt := v_rcnt + 1;
        if p_codapp is not null then
        --Report insert TTEMPRPT
          v_numseq := v_numseq + 1;
          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                                ITEM1,ITEM2,ITEM5,ITEM6,
                                ITEM7,ITEM8,
                                ITEM9,
                                ITEM10,
                                ITEM11,
                                ITEM12, ITEM13)
               VALUES (global_v_codempid,upper(p_codapp),v_numseq,
                       'TAB10',p_codempid, r1.numcolla, r1.desc_typcolla,
                       r1.descoll, r1.numdocum,
                       to_char(r1.amtcolla,'999,999,990.00'),
                       to_char(add_months(to_date(to_char(r1.dtecolla,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                       to_char(add_months(to_date(to_char(r1.dtestrt,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                       to_char(r1.amtdedcol,'999,999,990.00'), to_char(r1.amtbalance,'999,999,990.00'));
        end if;
    end loop;
    if v_rcnt = 0 then
      --update check has data
      begin
        update ttemprpt
           set item24 = 'N'
         where codempid = global_v_codempid
           and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
      end;
    else
      begin
        update ttemprpt
           set item24 = 'Y'
         where codempid = global_v_codempid
           and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
      end;
    end if;
    json_str_output := obj_row.to_clob;
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tcolltrl_info;

  procedure get_tassets_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_tassets_info(json_str_input);
    v_item1 := 'TAB5';
    clear_ttemprpt; --item1 TAB5
    if (param_msg_error <> ' ' or param_msg_error is not null) then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
       gen_tassets_info(json_str_output);
       if (param_msg_error <> ' ' or param_msg_error is not null) then
         json_str_output := get_response_message(null,param_msg_error,global_v_lang);
       end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tassets_info;
  procedure validate_tassets_info(json_str_input in clob) as
    jsonObj json_object_t ;
  begin
    jsonObj := json_object_t(json_str_input);
    p_codempid :=    hcm_util.get_string_t(jsonObj,'psearch_codempid');
    if (p_codempid = ' ' or p_codempid is null) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end validate_tassets_info;
  procedure gen_tassets_info(json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt             number;
    cursor c_tassets is
        select t1.codasset,get_taseinf_name(t1.codasset,global_v_lang) assetname,t1.dtercass, t1.remark
        from tassets t1,tasetinf t2
        where t1.codasset = t2.codasset
        and t1.codempid = p_codempid
         and t1.dtertass is null
        order by t1.codasset,t1.dtercass;
    begin
      begin
       select max(numseq)
         into v_numseq
         from ttemprpt
        where codempid = global_v_codempid
          and codapp = upper(p_codapp);
      exception when no_data_found then
        v_numseq := 1;
      end;
      if v_numseq is null then
        v_numseq := 1;
      end if;
      obj_row := json_object_t();
      v_rcnt := 0;
      for r1 in c_tassets loop
          obj_data := json_object_t();
          obj_data.put('coderror', '200');

          obj_data.put('codasset', r1.codasset);
          obj_data.put('assetname', r1.assetname);
          obj_data.put('dtercass', to_char(r1.dtercass, 'dd/mm/yyyy'));
          obj_data.put('remark',r1.remark);

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt := v_rcnt + 1;
          if p_codapp is not null then
            --Report insert TTEMPRPT
            v_numseq := v_numseq + 1;
            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM5,ITEM6,ITEM7,ITEM8)
                VALUES (global_v_codempid, upper(p_codapp),v_numseq,'TAB5',p_codempid,
                        r1.codasset,r1.assetname,
                        to_char(add_months(to_date(to_char(r1.dtercass,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                        r1.remark);
          end if;
      end loop;
      if v_rcnt = 0 then
        --update check has data
        begin
          update ttemprpt
             set item19 = 'N'
           where codempid = global_v_codempid
             and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
        end;
      else
        begin
          update ttemprpt
             set item19 = 'Y'
           where codempid = global_v_codempid
             and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
        end;
      end if;
    json_str_output := obj_row.to_clob;
--      dbms_lob.createtemporary(json_str_output, true);
--      obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tassets_info;

  procedure get_tempinc_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_tempinc_info(json_str_input);
    v_item1 := 'TAB7';
    clear_ttemprpt; --item1 TAB7
    if (param_msg_error <> ' ' or param_msg_error is not null) then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
       gen_tempinc_info(json_str_output);
       if (param_msg_error <> ' ' or param_msg_error is not null) then
         json_str_output := get_response_message(null,param_msg_error,global_v_lang);
       end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tempinc_info;
  procedure validate_tempinc_info(json_str_input in clob)as
    objJson  json_object_t ;
  begin
    objJson := json_object_t(json_str_input);
    p_codempid :=    hcm_util.get_string_t(objJson,'psearch_codempid');
    if (p_codempid = ' ' or p_codempid is null) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end validate_tempinc_info;
  procedure gen_tempinc_info(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number;
    v_formula       varchar2(500 char);
    cursor c_tempinc is
      select codpay, get_tinexinf_name(codpay,global_v_lang) codpayname,
             periodpay, amtfix, dtestrt, dteend, dtecancl,
             stddec(amtfix,p_codempid,v_chken) amount
        from tempinc
       where nvl(dtecancl,nvl(dteend,trunc(sysdate))) is null 
             or ( nvl(dtecancl,nvl(dteend,trunc(sysdate))) >= trunc(sysdate))
         and codempid = p_codempid;
  begin
    begin
     select max(numseq)
       into v_numseq
       from ttemprpt
      where codempid = global_v_codempid
        and codapp = upper(p_codapp);
    exception when no_data_found then
      v_numseq := 1;
    end;
    if v_numseq is null then
      v_numseq := 1;
    end if;
    obj_row := json_object_t();
    v_rcnt := 0;
    for r1 in c_tempinc loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');

      begin
          select formula into v_formula from tformula
          where codpay = r1.codpay
          and dteeffec = (
              select max(dteeffec)
              from tformula
              where codpay = r1.codpay
              and dteeffec <= trunc(sysdate)
          );
          exception when no_data_found then
              v_formula	:= null;
      end;

      obj_data.put('codpay', r1.codpay);
      obj_data.put('codpayname', r1.codpayname);
      obj_data.put('periodpay', r1.periodpay);
      obj_data.put('formula',v_formula);
      obj_data.put('formulaname',get_formula_name(v_formula,global_v_lang));
      obj_data.put('amount', r1.amount);
      obj_data.put('dtestrt',to_char(r1.dtestrt, 'dd/mm/yyyy'));
      obj_data.put('dteend',to_char(r1.dteend, 'dd/mm/yyyy'));
      obj_data.put('dtecancl',to_char(r1.dtecancl,'dd/mm/yyyy'));
      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt := v_rcnt + 1;
      if p_codapp is not null then
        --Report insert TTEMPRPT
        v_numseq := v_numseq + 1;
        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                            ITEM1,ITEM2,ITEM5,ITEM6,
                            ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,ITEM12)
           VALUES (global_v_codempid,upper(p_codapp),v_numseq,
                  'TAB7',p_codempid,r1.codpay,r1.codpayname,r1.periodpay,r1.amount,get_formula_name(v_formula,global_v_lang),
                  to_char(add_months(to_date(to_char(r1.dtestrt,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                  to_char(add_months(to_date(to_char(r1.dteend,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                  to_char(add_months(to_date(to_char(r1.dtecancl,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'));
      end if;
    end loop;
    if v_rcnt = 0 then
      --update check has data
      begin
        update ttemprpt
           set item21 = 'N'
         where codempid = global_v_codempid
           and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
      end;
    else
      begin
        update ttemprpt
           set item21 = 'Y'
         where codempid = global_v_codempid
           and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
      end;
    end if;
    json_str_output := obj_row.to_clob;
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tempinc_info;

  procedure get_tothinc_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_tothinc_info(json_str_input);
    v_item1 := 'TAB8';
    clear_ttemprpt; -- item1 TAB8
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      gen_tothinc_info(json_str_output);
      if (param_msg_error <> ' ' or param_msg_error is not null) then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tothinc_info;
  procedure validate_tothinc_info(json_str_input in clob) as
    jsonObj json_object_t ;
  begin
    jsonObj     := json_object_t(json_str_input);
    p_codempid  := hcm_util.get_string_t(jsonObj,'psearch_codempid');
    if (p_codempid = ' ' or p_codempid is null) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    begin
     select dteyrepay, dtemthpay, numperiod
       into v_dteyrepay,v_dtemthpay,v_numperiod
       from ttaxcur
      where codempid = p_codempid
        and dteyrepay||dtemthpay||numperiod =(
            select max(dteyrepay||dtemthpay||numperiod)
            from ttaxcur
            where codempid = p_codempid);
    exception when no_data_found then
      v_dteyrepay := null;
      v_dtemthpay := null;
      v_numperiod := null;
    end ;
  end validate_tothinc_info;
  procedure gen_tothinc_info(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number;
    v_amtpay_number number;

    cursor c_tothinc is
      select codpay,codempid,
             get_tinexinf_name(codpay,global_v_lang) codpayname,
             amtpay,
             codsys,
             numperiod||'/'||get_tlistval_name('NAMMTHFUL',dtemthpay,global_v_lang)||'/'||dteyrepay period,
             numperiod||'/'||get_tlistval_name('NAMMTHFUL',dtemthpay,global_v_lang)||'/'||(dteyrepay + hcm_appsettings.get_additional_year) dteperiod
        from tothinc
       --<<User37 #1995 Final Test Phase 1 V11 02/02/2021
       where not exists ( select *
                      from tsincexp
                      where tothinc.codempid	= tsincexp.codempid
                      and tothinc.dteyrepay = tsincexp.dteyrepay
                      and tothinc.dtemthpay = tsincexp.dtemthpay
                      and tothinc.numperiod = tsincexp.numperiod
                      and tothinc.codpay = tsincexp.codpay )
        and codempid  = p_codempid;
       /*where exists ( select *
                      from tsincexp
                      where tothinc.codempid	= tsincexp.codempid
                      and tothinc.dteyrepay = tsincexp.dteyrepay
                      and tothinc.dtemthpay = tsincexp.dtemthpay
                      and tothinc.numperiod = tsincexp.numperiod
                      and tothinc.codpay = tsincexp.codpay )
        and codempid  = p_codempid
        and dteyrepay = v_dteyrepay
        and dtemthpay = v_dtemthpay
        and numperiod = v_numperiod;*/
        -->>User37 #1995 Final Test Phase 1 V11 02/02/2021
  begin
    begin
     select max(numseq)
       into v_numseq
       from ttemprpt
      where codempid = global_v_codempid
        and codapp = upper(p_codapp);
    exception when no_data_found then
      v_numseq := 1;
    end;
    if v_numseq is null then
      v_numseq := 1;
    end if;
    obj_row := json_object_t();
    v_rcnt := 0;
    for r1 in c_tothinc loop
      v_amtpay_number := stddec(r1.amtpay,r1.codempid,v_chken);

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codpay', r1.codpay);
      obj_data.put('codpayname', r1.codpayname);
      obj_data.put('period', r1.period);
      obj_data.put('amtpay',v_amtpay_number);
      obj_data.put('codsys',r1.codsys);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt := v_rcnt + 1;
      if p_codapp is not null then
        --Report insert TTEMPRPT
        v_numseq := v_numseq + 1;
        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                              ITEM1,ITEM2,ITEM5,ITEM6,
                              ITEM7,ITEM8,
                              ITEM9)
             VALUES (global_v_codempid,upper(p_codapp),v_numseq,
                     'TAB8',p_codempid, r1.codpay, r1.codpayname,
                     TRIM(to_char(v_amtpay_number,'999,999,990.00')), r1.codsys,
                     r1.dteperiod);
      end if;
    end loop;
    if v_rcnt = 0 then
      --update check has data
      begin
        update ttemprpt
           set item22 = 'N'
         where codempid = global_v_codempid
           and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
      end;
    else
      begin
        update ttemprpt
           set item22 = 'Y'
         where codempid = global_v_codempid
           and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
      end;
    end if;
    json_str_output := obj_row.to_clob;
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tothinc_info;

  procedure get_tresintw_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_tresintw_info(json_str_input);

    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      gen_tresintw_info(json_str_output);
      if (param_msg_error <> ' ' or param_msg_error is not null) then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tresintw_info;
  procedure validate_tresintw_info (json_str_input in clob) as
  jsonObj json_object_t ;
  begin
    jsonObj := json_object_t(json_str_input);
    p_codempid :=    hcm_util.get_string_t(jsonObj,'psearch_codempid');
     if (p_codempid = ' ' or p_codempid is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
    end if;
  end validate_tresintw_info;
  procedure gen_tresintw_info(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number;
    cursor c_tresintw is
        select a.dtereq,a.numseq,a.numqes,a.details,a.response ans,a.typeques,b.intwno
        from tresintw a, tresreq b
        where a.codempid = b.codempid
        and a.dtereq   = b.dtereq
        and a.numseq   = b.numseq
        and a.codempid = p_codempid
        and b.staappr  = 'Y';

    begin

    obj_row := json_object_t();
    v_rcnt := 0;
    for r1 in c_tresintw loop
        obj_data := json_object_t();
        obj_data.put('coderror', '200');

        obj_data.put('intwno', r1.intwno);
        obj_data.put('numqes', r1.numqes);
        obj_data.put('details', r1.details);
        obj_data.put('ans',r1.ans);
        obj_data.put('typeques',r1.typeques);

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt := v_rcnt + 1;
    end loop;
    json_str_output := obj_row.to_clob;
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tresintw_info;

  procedure get_texintw (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
--    check_detail;
    validate_tresintw_info(json_str_input);
    if param_msg_error is null then
      gen_texintw(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_texintw;
  procedure gen_texintw (json_str_output out clob) AS
    obj_rowd            json_object_t;
    obj_data            json_object_t;
    obj_row             json_object_t;
    obj_datad           json_object_t;
    obj_rowc            json_object_t;
    obj_datac           json_object_t;
    v_rcnt              number := 0;
    v_rcntd             number := 0;
    v_rcntc             number := 0;
    v_numcate           texintwd.numcate%type;
    v_numseq            texintwd.numseq%type;
    v_numans            texintwc.numans%type;
    v_dtereq            tresreq.dtereq%type;

    cursor c1_texintwh is
      select intwno
        from texintwh
       where (SELECT CODPOS FROM temploy1 where codempid = p_codempid) between codposst and codposen
       order by intwno;

    cursor c1 is
      select numcate
        from texintwd
       where intwno = p_intwno
       group by numcate
       order by numcate;

    cursor c2 is
      select t1.numcate, t1.numseq,
             decode(global_v_lang, '101', t1.detailse,
                                   '102', t1.detailst,
                                   '103', t1.details3,
                                   '104', t1.details4,
                                   '105', t1.details5) details,
             t1.detailse, t1.detailst, t1.details3, t1.details4, t1.details5, t2.typeques
        from texintwd t1, texintws t2
       where t1.intwno     = p_intwno
         and t1.numcate = v_numcate
         and t1.intwno  = t2.intwno
         and t1.numcate = t2.numcate
       order by numcate, numseq;

    cursor c3 is
      select numans, decode(global_v_lang, '101', detailse,
                                                            '102', detailst,
                                                            '103', details3,
                                                            '104', details4,
                                                            '105', details5) details,
             detailse, detailst, details3, details4, details5
        from texintwc
       where intwno  = p_intwno
         and numcate = v_numcate
         and numseq  = v_numseq
       order by numans;

  begin
    obj_row                 := json_object_t();
    v_rcnt                  := 0;
    if p_numseq is null then
      begin
        select dtereq, numseq
          into v_dtereq, v_numseq
          from tresreq
         where codempid = p_codempid
           and staappr = 'Y'
           and rownum = 1;
      exception when no_data_found then
        null;
      end;
    end if;
    if v_dtereq is not null then
      p_dtereq        := v_dtereq;
      p_numseq        := v_numseq;
    end if;
    if p_intwno is null then
      for r1 in c1_texintwh loop
        p_intwno := r1.intwno;
        exit;
      end loop;
    end if;
    for r1 in c1 loop
      v_numcate               := r1.numcate;
      obj_rowd                := json_object_t();
      v_rcnt                  := v_rcnt + 1;
      v_rcntd                 := 0;
      for r2 in c2 loop
        v_rcntd                 := v_rcntd + 1;
        obj_datad               := json_object_t();
        v_numseq                := r2.numseq;
        obj_datad.put('coderror', '200');
        obj_datad.put('numcate', to_char(r2.numcate));
        obj_datad.put('numseq', to_char(r2.numseq));
        obj_datad.put('details', r2.details);
        obj_datad.put('detailse', r2.detailse);
        obj_datad.put('detailst', r2.detailst);
        obj_datad.put('details3', r2.details3);
        obj_datad.put('details4', r2.details4);
        obj_datad.put('details5', r2.details5);
        obj_datad.put('typeques', to_char(r2.typeques));
        obj_datad.put('result', get_resintw(v_numcate, v_numseq));

        obj_rowc              := json_object_t();
        v_rcntc               := 0;
        for r3 in c3 loop
          obj_datac             := json_object_t();
          v_rcntc               := v_rcntc + 1;
          obj_datac.put('coderror', '200');
          obj_datac.put('numans', to_char(r3.numans));
          obj_datac.put('details', r3.details);
          obj_datac.put('detailse', r3.detailse);
          obj_datac.put('detailst', r3.detailst);
          obj_datac.put('details3', r3.details3);
          obj_datac.put('details4', r3.details4);
          obj_datac.put('details5', r3.details5);

          obj_rowc.put(to_char(v_rcntc - 1), obj_datac);
        end loop;
        obj_datad.put('children', obj_rowc);

        obj_rowd.put(to_char(v_rcntd - 1), obj_datad);
      end loop;
      obj_data                := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('namcate', to_char(v_numcate) || '. ' || get_exintws(p_intwno, v_numcate));
      obj_data.put('texintw', obj_rowd);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_texintw;

  function get_formula_name(v_formula in varchar2,v_lang in varchar2) return varchar2 is
    cursor c1 is
      select codpay
        from tinexinf
       order by codpay;
    v_formulaname clob;
  begin
    v_formulaname := v_formula ;
    for i in c1 loop
      v_formulaname     := replace(v_formulaname,'&'||i.codpay,get_tinexinf_name(i.codpay,v_lang));
    end loop;
    return v_formulaname;
  end get_formula_name;
  function get_resintw (v_numcate texintwd.numcate%type, v_numseq texintwd.numseq%type) return varchar2 is
    v_response          tresintw.response%type;
  begin
    begin
      select response
        into v_response
        from tresintw
       where codempid = p_codempid
         and dtereq   = p_dtereq
         and numseq   = p_numseq
         and numcate  = v_numcate
         and numqes   = v_numseq;
    exception when no_data_found then
      null;
    end;
    return v_response;
  end;
  function get_exintws (v_intwno texintws.intwno%type, v_numcate texintws.numcate%type) return varchar2 is
    v_namcate           texintws.namcatee%type;
  begin
    begin
      select decode(global_v_lang, '101', namcatee,
                                   '102', namcatet,
                                   '103', namcate3,
                                   '104', namcate4,
                                   '105', namcate5,
                                   namcatee)
        into v_namcate
        from texintws
       where intwno  = v_intwno
         and numcate = v_numcate;
    exception when no_data_found then
      null;
    end;
    return v_namcate;
  end;

  procedure get_exintw_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
--    check_detail;
    validate_tresintw_info(json_str_input);
    if param_msg_error is null then
      gen_exintw_detail(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_exintw_detail;
  procedure gen_exintw_detail (json_str_output out clob) AS
    obj_data           json_object_t;
    v_dtereq           tresreq.dtereq%type;
    v_numseq           tresreq.numseq%type;
    v_dteeffec         tresreq.dteeffec%type;
    v_codexemp         tresreq.codexemp%type;
    v_staappr          tresreq.staappr%type;
    v_desnote          tresreq.desnote%type;
    v_codempid         tresreq.codempid%type;
    v_intwno           tresreq.intwno%type;
    v_response         varchar2(4000 char);
    v_codpos           temploy1.codpos%type;
    cursor c1_texintwh is
      select intwno
        from texintwh
       where v_codpos between codposst and codposen
       order by intwno;
  begin
    v_codempid := p_codempid;

      begin
        SELECT CODPOS
          INTO v_codpos
          FROM temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        null;
      end;

      begin
        select dtereq, numseq
          into v_dtereq, v_numseq
          from tresreq
         where codempid = v_codempid
           and staappr = 'Y'
           and rownum = 1;
      exception when no_data_found then
        null;
      end;
    if v_dtereq is not null then
      obj_data        := json_object_t(get_response_message(null, get_error_msg_php('ES0027', global_v_lang), global_v_lang));
      v_response      := hcm_util.get_string_t(obj_data, 'response');
      p_dtereq        := v_dtereq;
      p_numseq        := v_numseq;
    elsif p_numseq is null then
      begin
        select nvl(max(numseq), 0) numseq
          into v_numseq
          from tresreq
         where codempid = v_codempid
           and dtereq   = p_dtereq;
        p_numseq := v_numseq + 1;
      exception when others then
        null;
      end;
    end if;
    begin
      select dteeffec,
             codexemp,
             staappr,
             desnote,
             intwno
        into v_dteeffec,
             v_codexemp,
             v_staappr,
             v_desnote,
             v_intwno
      from tresreq
      where codempid = v_codempid
        and dtereq   = p_dtereq
        and numseq   = p_numseq;
    exception when no_data_found then
      null;
    end;
    if v_intwno is null then
      for r1 in c1_texintwh loop
        v_intwno := r1.intwno;
        exit;
      end loop;
    end if;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('response', v_response);
    obj_data.put('dtereq', to_char(p_dtereq, 'dd/mm/yyyy'));
    obj_data.put('numseq', p_numseq);
    obj_data.put('dteeffec', to_char(nvl(v_dteeffec, trunc(sysdate)), 'dd/mm/yyyy'));
    obj_data.put('codexemp', v_codexemp);
    obj_data.put('staappr', v_staappr);
    obj_data.put('desnote', v_desnote);
    obj_data.put('codempid', v_codempid);
    obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
    obj_data.put('intwno', v_intwno);
    obj_data.put('codpos', v_codpos);
    obj_data.put('desc_codpos', v_codpos || ' - ' || get_tpostn_name(v_codpos, global_v_lang));

    json_str_output := obj_data.to_clob;
  end gen_exintw_detail;

  procedure get_tleavsum_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_tleavsum_info(json_str_input);
    v_item1 := 'TAB6';
    clear_ttemprpt; --item1 TAB6
    if (param_msg_error <> ' ' or param_msg_error is not null) then
        json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    else
      gen_tleavsum_info(json_str_output);
      if (param_msg_error <> ' ' or param_msg_error is not null) then
        json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tleavsum_info;
  procedure validate_tleavsum_info (json_str_input in clob) as
      objJson json_object_t;
  begin
    objJson := json_object_t(json_str_input);
    p_codempid :=    hcm_util.get_string_t(objJson,'psearch_codempid');
    p_codcomp :=     hcm_util.get_string_t(objJson,'psearch_codcomp');
    if (p_codempid = ' ' or p_codempid is null) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if (p_codcomp = ' ' or p_codcomp is null ) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'psearch_codcomp');
      return;
    end if;
  end validate_tleavsum_info;

  procedure gen_tleavsum_info(json_str_output out clob)as
    obj_row			    json_object_t;

    v_rcnt			    number := 0;
    v_qtyavqwk		  number;
    v_codleavev		  varchar2(500 char);
    v_typleavev		  varchar2(500 char);

    v_qtyvacatv		  number;
    v_qtydaylev		  number;
    v_balancev		  number;
    v_flgdlemxv		  varchar2(500 char);
    v_qtyreqv		    number;

    o_qtyvacatv_d		  number;
    o_qtyvacatv_h		  number;
    o_qtyvacatv_m		  number;
    o_qtyvacatv_dhm		varchar2(500 char);
    o_qtydaylev_d		  number;
    o_qtydaylev_h		  number;
    o_qtydaylev_m		  number;
    o_qtydaylev_dhm		varchar2(500 char);

    o_balancev_d		  number;
    o_balancev_h		  number;
    o_balancev_m		  number;
    o_balancev_dhm		varchar2(500 char);
    o_qtyreqv_d		    number;
    o_qtyreqv_h		    number;
    o_qtyreqv_m		    number;
    o_qtyreqv_dhm		  varchar2(500 char);

    v_codcomp		  varchar2(500 char);
    v_yrecyclev		number;
    v_dtecycstv		date;
    v_dtecycenv		date;

    v_codleavec		tleavecd.codleave%type;
    v_typleavec		tleavecd.typleave%type;
    v_qtyvacatc		number;
    v_qtydaylec		number;
    v_balancec		number;
    v_yrecyclec		number;
    v_dtecycstc		date;
    v_dtecycenc		date;

    v_flgdlemxc		  varchar2(500 char);
    v_qtyreqc		    number;
    o_qtyvacatc_d		number;
    o_qtyvacatc_h		number;
    o_qtyvacatc_m		number;
    o_qtyvacatc_dhm	varchar2(500 char);

    o_qtydaylec_d		  number;
    o_qtydaylec_h		  number;
    o_qtydaylec_m		  number;
    o_qtydaylec_dhm		varchar2(500 char);
    o_balancec_d		  number;
    o_balancec_h		  number;
    o_balancec_m		  number;
    o_balancec_dhm		varchar2(500 char);

    o_qtyreqc_d		  number;
    o_qtyreqc_h		  number;
    o_qtyreqc_m		  number;
    o_qtyreqc_dhm		varchar2(500 char);

    v_count_ttemprpt	varchar2(500 char);

    v_desc_codleavev	tleavecd.namleavcde%type;
    v_desc_codleavec	tleavecd.namleavcde%type;
  begin
    begin
     select max(numseq)
       into v_numseq
       from ttemprpt
      where codempid = global_v_codempid
        and codapp = upper(p_codapp);
    exception when no_data_found then
      v_numseq := 1;
    end;
    if v_numseq is null then
      v_numseq := 1;
    end if;
    begin
      select codleave,typleave,
             decode(global_v_lang, '101', namleavcde,
                                   '102', namleavcdt,
                                   '103', namleavcd3,
                                   '104', namleavcd4,
                                   '105', namleavcd5) namleavcd
      into v_codleavev,v_typleavev, v_desc_codleavev
      from tleavecd
      where staleave = 'V';
    exception when no_data_found then
      v_codleavev := null;
    end;
        std_al.cycle_leave(hcm_util.get_codcomp_level(p_codcomp,'1'),p_codempid,v_codleavev,sysdate,v_yrecyclev,v_dtecycstv,v_dtecycenv);

    begin
      select qtyvacat,qtydayle,nvl(QTYVACAT,0)-nvl(QTYDAYLE,0)
      into v_qtyvacatv,v_qtydaylev,v_balancev
      from tleavsum
      where codleave = v_codleavev
      and dteyear = v_yrecyclev
      and codempid = p_codempid;
    exception when no_data_found then
      null;
    end;

    begin
      select flgdlemx
      into v_flgdlemxv
      from tleavety
      where typleave = v_typleavev;
    exception when no_data_found then
      null;
    end;

    if v_flgdlemxv = 'Y' then
      v_qtyreqv := 0;
    else
      begin
        select nvl(sum(qtyday),0)
        into v_qtyreqv
        from tlereqd
        where codempid = p_codempid
        and dtework between v_dtecycstv and v_dtecycenv
        and codleave = v_codleavev
        and dayeupd is null;
      exception when no_data_found then
        null;
      end;
    end if;


  ---------- OT ----------

    begin
      select codleave,typleave,
             decode(global_v_lang, '101', namleavcde,
                                   '102', namleavcdt,
                                   '103', namleavcd3,
                                   '104', namleavcd4,
                                   '105', namleavcd5) namleavcd
      into v_codleavec,v_typleavec, v_desc_codleavec
      from tleavecd
      where staleave ='C';
    exception when no_data_found then
      v_codleavec := null;
    end;

      std_al.cycle_leave(hcm_util.get_codcomp_level(p_codcomp,1),p_codempid,v_codleavec,sysdate,v_yrecyclec,v_dtecycstc,v_dtecycenc);

    begin
      select qtydleot,qtydayle,nvl(qtydleot,0)-nvl(qtydayle,0)
      into v_qtyvacatc,v_qtydaylec,v_balancec
      from tleavsum
      where codleave = v_codleavec
      and dteyear = v_yrecyclec
      and codempid = p_codempid;
    exception when no_data_found then
      null;
    end;

      begin
      select flgdlemx
      into v_flgdlemxc
      from tleavety
      where typleave = v_typleavec;
    exception when no_data_found then
      null;
    end;

    if v_flgdlemxc = 'Y' then
      v_qtyreqc := 0;
    else
      begin
        select nvl(sum(qtyday),0)
        into v_qtyreqc
        from tlereqd
        where codempid = p_codempid
        and dtework between v_dtecycstc and  v_dtecycenc
        and codleave = v_codleavec
        and dayeupd is null;
      exception when no_data_found then
        v_qtyreqc := 0;
      end;
    end if;

      v_qtyavqwk := HCM_UTIL.get_qtyavgwk(null,p_codempid);

      --- Vacation
      hcm_util.cal_dhm_hm (v_qtyvacatv, 0,0, v_qtyavqwk,'1' ,o_qtyvacatv_d,o_qtyvacatv_h,o_qtyvacatv_m,o_qtyvacatv_dhm) ;
      hcm_util.cal_dhm_hm (v_qtydaylev, 0,0, v_qtyavqwk,'1' ,o_qtydaylev_d,o_qtydaylev_h,o_qtydaylev_m,o_qtydaylev_dhm) ;
      hcm_util.cal_dhm_hm (v_balancev, 0,0, v_qtyavqwk ,'1' ,o_balancev_d,o_balancev_h,o_balancev_m,o_balancev_dhm) ;
      hcm_util.cal_dhm_hm (v_qtyreqv, 0,0, v_qtyavqwk ,'1' ,o_qtyreqv_d,o_qtyreqv_h,o_qtyreqv_m,o_qtyreqv_dhm) ;

      --- OT
      hcm_util.cal_dhm_hm (v_qtyvacatc, 0,0, v_qtyavqwk,'1' ,o_qtyvacatc_d,o_qtyvacatc_h,o_qtyvacatc_m,o_qtyvacatc_dhm) ;
      hcm_util.cal_dhm_hm (v_qtydaylec, 0,0, v_qtyavqwk,'1' ,o_qtydaylec_d,o_qtydaylec_h,o_qtydaylec_m,o_qtydaylec_dhm) ;
      hcm_util.cal_dhm_hm (v_balancec, 0,0, v_qtyavqwk ,'1' ,o_balancec_d,o_balancec_h,o_balancec_m,o_balancec_dhm) ;
      hcm_util.cal_dhm_hm (v_qtyreqc, 0,0, v_qtyavqwk ,'1' ,o_qtyreqc_d,o_qtyreqc_h,o_qtyreqc_m,o_qtyreqc_dhm) ;

      obj_row := json_object_t();

      obj_row.put('o_qtyvacat_day_vacation', o_qtyvacatv_d);
      obj_row.put('o_qtyvacat_hr_vacation', o_qtyvacatv_h);
      obj_row.put('o_qtyvacat_min_vacation', o_qtyvacatv_m);
      obj_row.put('o_qtyvacat_dhm_vacation',o_qtyvacatv_dhm);

      obj_row.put('o_qtydayle_day_vacation', o_qtydaylev_d);
      obj_row.put('o_qtydayle_hr_vacation', o_qtydaylev_h);
      obj_row.put('o_qtydayle_min_vacation', o_qtydaylev_m);
      obj_row.put('o_qtydayle_dhm_vacation',o_qtydaylev_dhm);

      obj_row.put('o_balance_day_vacation', o_balancev_d);
      obj_row.put('o_balance_hr_vacation', o_balancev_h);
      obj_row.put('o_balance_min_vacation', o_balancev_m);
      obj_row.put('o_balance_dhm_vacation',o_balancev_dhm);

      obj_row.put('o_qtyreqv_day_vacation', o_qtyreqv_d);
      obj_row.put('o_qtyreqv_hr_vacation', o_qtyreqv_h);
      obj_row.put('o_qtyreqv_min_vacation', o_qtyreqv_m);
      obj_row.put('o_qtyreqv_dhm_vacation',o_qtyreqv_dhm);

      --- OT

      obj_row.put('o_qtyvacat_day_ot', o_qtyvacatc_d);
      obj_row.put('o_qtyvacat_hr_ot', o_qtyvacatc_h);
      obj_row.put('o_qtyvacat_min_ot', o_qtyvacatc_m);
      obj_row.put('o_qtyvacat_dhm_ot',o_qtyvacatc_dhm);

      obj_row.put('o_qtydayle_day_ot', o_qtydaylec_d);
      obj_row.put('o_qtydayle_hr_ot', o_qtydaylec_h);
      obj_row.put('o_qtydayle_min_ot', o_qtydaylec_m);
      obj_row.put('o_qtydayle_dhm_ot',o_qtydaylec_dhm);

      obj_row.put('o_balance_day_ot', o_balancec_d);
      obj_row.put('o_balance_hr_ot', o_balancec_h);
      obj_row.put('o_balance_min_ot', o_balancec_m);
      obj_row.put('o_balance_dhm_ot',o_balancec_dhm);

      obj_row.put('o_qtyreqc_day_ot', o_qtyreqc_d);
      obj_row.put('o_qtyreqc_hr_ot', o_qtyreqc_h);
      obj_row.put('o_qtyreqc_min_ot', o_qtyreqc_m);
      obj_row.put('o_qtyreqc_dhm_ot',o_qtyreqc_dhm);

      obj_row.put('desc_codleavev',v_codleavev || ' - ' ||v_desc_codleavev);
      obj_row.put('desc_codleavec',v_codleavec || ' - ' ||v_desc_codleavec);

      obj_row.put('coderror', '200');
      obj_row.put('response', '');

      if p_codapp is not null then
        --Report insert TTEMPRPT
        v_numseq := v_numseq + 1;
        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,
                ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,ITEM12
                ,ITEM13,ITEM14,ITEM15,ITEM16,ITEM17,ITEM18,ITEM19
                ,ITEM20,ITEM21,ITEM22,ITEM23,ITEM24,ITEM25,ITEM26
                ,ITEM27,ITEM28,ITEM29,ITEM30,ITEM31,ITEM32,ITEM33
                ,ITEM34,ITEM35,ITEM36,ITEM37,ITEM38)
        VALUES (global_v_codempid, upper(p_codapp),v_numseq,'TAB6',p_codempid,
                o_qtyvacatv_d,
                o_qtyvacatv_h,
                o_qtyvacatv_m,
                o_qtyvacatv_dhm,
                o_qtydaylev_d,
                o_qtydaylev_h,
                o_qtydaylev_m,
                o_qtydaylev_dhm,
                o_balancev_d,
                o_balancev_h,
                o_balancev_m,
                o_balancev_dhm,
                o_qtyreqv_d,
                o_qtyreqv_h,
                o_qtyreqv_m,
                o_qtyreqv_dhm,
                o_qtyvacatc_d,--OT
                o_qtyvacatc_h,
                o_qtyvacatc_m,
                o_qtyvacatc_dhm,
                o_qtydaylec_d,
                o_qtydaylec_h,
                o_qtydaylec_m,
                o_qtydaylec_dhm,
                o_balancec_d,
                o_balancec_h,
                o_balancec_m,
                o_balancec_dhm,
                o_qtyreqc_d,
                o_qtyreqc_h,
                o_qtyreqc_m,
                o_qtyreqc_dhm,
                v_codleavev || ' - ' ||v_desc_codleavev,
                v_codleavec || ' - ' ||v_desc_codleavec);

        begin
          update ttemprpt
             set item20 = 'Y'
           where codempid = global_v_codempid
             and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
        end;
    end if;
    json_str_output := obj_row.to_clob;
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);

  end gen_tleavsum_info;

  procedure get_tguarntr_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_tguarntr_info(json_str_input);
    v_item1 := 'TAB9';
    clear_ttemprpt; --item1 TAB9
    if (param_msg_error <> ' ' or param_msg_error is not null) then
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    else
      gen_tguarntr_info(json_str_output);
      if (param_msg_error <> ' ' or param_msg_error is not null) then
        json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tguarntr_info;
  procedure validate_tguarntr_info (json_str_input in clob) as
    objJson json_object_t;
  begin
    objJson     := json_object_t(json_str_input);
    p_codempid  := hcm_util.get_string_t(objJson,'psearch_codempid');
    p_codcomp   := hcm_util.get_string_t(objJson,'psearch_codcomp');

    if (p_codempid = ' ' or p_codempid is null) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end validate_tguarntr_info;
 procedure gen_tguarntr_info(json_str_output out clob)as
  obj_row			      json_object_t;
  obj_data			    json_object_t;
  v_rcnt			      number := 0;
  v_count_ttemprpt	varchar2(500 char);
  v_staemp	        varchar2(500 char);
  cursor c1_tguarntr is
    select numseq,codempgrt,dtegucon,
           stddec(amtguarntr,codempgrt,v_chken) amtguarntr,
           desrelat,desnote,dteguabd,
           dteguret,adrcont,codpost,numtele,numteleo,numfax,codident,
           numoffid,dteidexp,codoccup,despos,adroffi,codposto,
           stddec(amtmthin,codempgrt,v_chken) amtmthin,
           decode(global_v_lang, '101', namguare,
                                 '102', namguart,
                                 '103', namguar3,
                                 '104', namguar4,
                                 '105', namguar5) namguar
      from tguarntr
     where codempid = p_codempid
     order by numseq;
  begin
    begin
     select max(numseq)
       into v_numseq
       from ttemprpt
      where codempid = global_v_codempid
        and codapp = upper(p_codapp);
    exception when no_data_found then
      v_numseq := 1;
    end;
    if v_numseq is null then
      v_numseq := 1;
    end if;
    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c1_tguarntr loop
      begin
        select get_tlistval_name('STAEMP',staemp,global_v_lang)
          into v_staemp
          from temploy1
         where codempid = r1.codempgrt;
      exception when no_data_found then
        v_staemp := '';
      end;
      obj_data := json_object_t();
      obj_data.put('numseq', r1.numseq);
      obj_data.put('codempgrt', r1.codempgrt);
      obj_data.put('namguar', r1.namguar);
      obj_data.put('dtegucon', to_char(r1.dtegucon,'dd/mm/yyyy'));
      obj_data.put('amtguarntr', to_char(r1.amtguarntr,'999,999,990.00'));
      obj_data.put('desrelat', r1.desrelat);
      obj_data.put('desnote', r1.desnote);
      obj_data.put('status', v_staemp);
      obj_data.put('dteguret', to_char(r1.dteguret,'dd/mm/yyyy'));
      obj_data.put('adrcont', r1.adrcont);
      obj_data.put('codpost', r1.codpost);
      obj_data.put('numtele', r1.numtele);
      obj_data.put('numteleo', r1.numteleo);
      obj_data.put('numfax', r1.numfax);
      obj_data.put('codident', get_tlistval_name('CODIDENT',r1.codident,global_v_lang));
      obj_data.put('numoffid', r1.numoffid);
      obj_data.put('dteidexp', to_char(r1.dteidexp,'dd/mm/yyyy'));
      obj_data.put('dteguabd', to_char(r1.dteguabd,'dd/mm/yyyy'));
      obj_data.put('codoccup', get_tcodec_name('TCODOCCU',r1.codoccup,global_v_lang));
      obj_data.put('despos', r1.despos);
      obj_data.put('amtmthin', to_char(r1.amtmthin,'999,999,990.00'));
      obj_data.put('adroffi', r1.adroffi);
      obj_data.put('codposto', r1.codposto);
      obj_data.put('coderror', '200');
      obj_data.put('response', '');
      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt := v_rcnt + 1;
      if p_codapp is not null then
        --Report insert TTEMPRPT
        v_numseq := v_numseq + 1;
        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                              ITEM1,ITEM2,ITEM5,ITEM6,
                              ITEM7,
                              ITEM8,
                              ITEM9,ITEM10,ITEM11,ITEM12)
             VALUES (global_v_codempid,upper(p_codapp),v_numseq,
                     'TAB9',p_codempid, r1.numseq, r1.codempgrt,
                     r1.namguar,
                     to_char(add_months(to_date(to_char(r1.dtegucon,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),
                     to_char(r1.amtguarntr,'999,999,990.00'), r1.desrelat, v_staemp, r1.desnote);
      end if;
    end loop;
    if v_rcnt = 0 then
      --update check has data
      begin
        update ttemprpt
           set item23 = 'N'
         where codempid = global_v_codempid
           and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
      end;
    else
      begin
        update ttemprpt
           set item23 = 'Y'
         where codempid = global_v_codempid
           and codapp = upper(p_codapp)
               and item1 = 'HEAD'
               and item2 = p_codempid;
      end;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tguarntr_info;
  procedure clear_ttemprpt is
	begin
		begin
			delete
			  from ttemprpt
			 where codempid = global_v_codempid
			   and codapp = upper(p_codapp)
               and item1 = v_item1
               and item2 = p_codempid;
		exception when others then
			null;
		end;
	end clear_ttemprpt;
end std_pmdetail;

/

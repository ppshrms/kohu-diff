--------------------------------------------------------
--  DDL for Package Body HRES39X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES39X" as
    procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

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

    procedure clear_ttemprpt is
    begin
        begin
            delete
            from  ttemprpt
            where codempid = global_v_codempid
            and   codapp   = p_codapp;
        exception when others then
    null;
    end;
    end clear_ttemprpt;

    procedure get_ttemprpt_numseq is
    begin
        begin
            select max(numseq)
              into v_numseq
              from  ttemprpt
             where codempid = global_v_codempid
               and   codapp   = p_codapp;
        exception when others then
            v_numseq := 0;
        end;
        v_numseq := nvl(v_numseq,0) + 1;
    end get_ttemprpt_numseq;

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
    p_thismove_dteeffec     thismove.dteeffec%TYPE;
    p_thismove_codcomp       thismove.codcomp%TYPE;
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
    v_image             tempimge.namimage%type;
    v_flgimg            varchar2(2 char) := 'N';
  begin
    clear_ttemprpt;
    begin
      select max(dteeffec) into v_dteretire
        from ttexempt
       where codempid   =   p_codempid
         and dteeffec   <=  sysdate ;
    exception when no_data_found then
      v_dteretire := null;
    end;

    statuscode := '';

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
      select dteeffec,codcomp
        into p_thismove_dteeffec,p_thismove_codcomp
        from thismove
       where dteeffec = (select max(dteeffec)
                           from thismove
                          where codempid = p_codempid)
         and numseq =  (select max(numseq)
                          from thismove
                         where codempid = p_codempid
                           and dteeffec = (select max(dteeffec)
                                             from thismove
                                            where codempid = p_codempid))
         and codempid = p_codempid;

      obj_data.put('ttrehiredtereemp',to_char(p_thismove_dteeffec,'dd/mm/yyyy'));
      obj_data.put('ttrehirecodcomp', get_tcenter_name(p_thismove_codcomp,global_v_lang));
      obj_data.put('codcomp', p_thismove_codcomp);
    exception when no_data_found then
      obj_data.put('ttrehiredtereemp','');
      obj_data.put('ttrehirecodcomp','');
      obj_data.put('codcomp', '');
    end;
    get_ttemprpt_numseq;
    insert into ttemprpt (codempid,codapp,numseq,item1,item2,
                          item3,item4,item5,
                          item6,item7,item8)
    values (global_v_codempid,p_codapp,v_numseq,'DETAIL',p_codempid,
            temploy1_rec.tcentername,temploy1_rec.tpostnname,hcm_util.get_date_buddhist_era(temploy1_rec.dteempmt),
            hcm_util.get_date_buddhist_era(p_thismove_dteeffec),get_tcenter_name(p_thismove_codcomp,global_v_lang),get_tlistval_name('FSTAEMP', temploy1_rec.staemp,global_v_lang));


    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_emp_info;
  procedure get_emp_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    vadidate_variable_get_emp_info(json_str_input);
    gen_emp_info(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_tloaninf_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_tloaninf_info(json_str_input);
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
    jsonObj   json_object_t := json_object_t(json_str_input);
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

    get_ttemprpt_numseq;
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

      insert into ttemprpt (codempid,codapp,numseq,item1,item2,
                              item3,item4,item5,
                              item6,item7,item8,
                              item9,item10,item11)
      values (global_v_codempid,p_codapp,v_numseq,'TABLE1',p_codempid,
              countRow,hcm_util.get_date_buddhist_era(r1.dtelonst),r1.numcont,
              r1.codlon,to_char(r1.amtlon,'fm999,999,999,999,990.00'),to_char(r1.balance,'fm999,999,999,999,990.00'),
              r1.numlon,r1.qtyperiod,r1.qtyperip); 
      v_numseq := v_numseq + 1 ;        
    end loop;
    json_str_output := objRowJson.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tloaninf_info;

  procedure get_trepay_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_trepay_info(json_str_input);
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
    cursor c_trepay is
      select qtyrepaym, amtrepaym, 
             to_date(decode(dtestrpm, null, null,lpad(substr(dtestrpm,7,5),2,'0')||'/'||substr(dtestrpm,5,2)||'/'||substr(dtestrpm,1,4)),'dd/mm/yyyy') dtestrpm,
             amtoutstd, amtoutstd - amttotpay balance, qtypaid,
             to_date(decode(dtelstpay, null, null,lpad(substr(dtelstpay,7,5),2,'0')||'/'||substr(dtelstpay,5,2)||'/'||substr(dtelstpay,1,4) ),'dd/mm/yyyy')  dtelstpay
        from trepay
       where codempid = p_codempid
         and dteappr = ( select max(dteappr)
                           from trepay
                          where codempid = p_codempid
                            and dteappr <= sysdate );
      isHasData boolean := false;
  begin

    obj_data := json_object_t();
    for r1 in c_trepay loop
      obj_data.put('coderror', '200');
      obj_data.put('qtyrepaym', r1.qtyrepaym);
      obj_data.put('amtrepaym', to_char(r1.amtrepaym,'fm999,999,990.00'));
      obj_data.put('dtestrpm', to_char(r1.dtestrpm,'dd/mm/yyyy'));
      obj_data.put('amtoutstd',to_char(r1.amtoutstd,'fm999,999,990.00'));
      obj_data.put('balance',to_char(r1.balance,'fm999,999,990.00'));
      obj_data.put('qtypaid',r1.qtypaid);
      obj_data.put('dtelstpay',to_char(r1.dtelstpay,'dd/mm/yyyy'));
      isHasData := true;

      update ttemprpt
         set item9 = r1.qtyrepaym,
             item10 = r1.qtypaid,
             item11 = hcm_util.get_date_buddhist_era(r1.dtestrpm),
             item12 = hcm_util.get_date_buddhist_era(r1.dtelstpay),
             item13 = to_char(r1.amtrepaym,'fm999,999,990.00'),
             item14 = to_char(r1.balance,'fm999,999,990.00'),
             item15 = to_char(r1.amtoutstd,'fm999,999,990.00')
       where codempid = global_v_codempid
         and codapp = p_codapp
         and item1 = 'DETAIL';      
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

      update ttemprpt
         set item9 = '',
             item10 = '',
             item11 = '',
             item12 = '',
             item13 = '',
             item14 = '',
             item15 = ''
       where codempid = global_v_codempid
         and codapp = p_codapp
         and item1 = 'DETAIL';    
    end if;
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_trepay_info;

  procedure get_tfunddet_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_tfunddet_info(json_str_input);
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
       order by dtecntr;
  begin
    get_ttemprpt_numseq;
    objRowJson := json_object_t();
    for r1 in c_fundtrnn loop
      objColJson := json_object_t();
      objColJson.put('coderror', '200');
      objColJson.put('response','');
      objColJson.put('codcours', r1.codcours);
      objColJson.put('desc_codcours', r1.namcourse);
      objColJson.put('descommt', r1.descommt);			
      objColJson.put('dtecntr', to_char(r1.dtecntr,'dd/mm/yyyy'));
      objColJson.put('period', r1.qtytrpln);
      objColJson.put('dtereq', to_char(r1.dtetrst,'dd/mm/yyyy'));

      objRowJson.put(to_char(countRow), objColJson);
      countRow := countRow + 1;

      insert into ttemprpt (codempid,codapp,numseq,item1,item2,
                              item3,item4,item5,
                              item6,item7,item8,
                              item9)
      values (global_v_codempid,p_codapp,v_numseq,'TABLE2',p_codempid,
              countRow,r1.codcours,r1.namcourse,
              r1.descommt,r1.qtytrpln,hcm_util.get_date_buddhist_era(r1.dtetrst),
              hcm_util.get_date_buddhist_era(r1.dtecntr)); 
      v_numseq := v_numseq + 1 ;
    end loop;
    json_str_output := objRowJson.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tfunddet_info;
    procedure get_tassets_info(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    validate_tassets_info(json_str_input);
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
        order by t1.codasset,t1.dtercass;
    begin
      get_ttemprpt_numseq;
      obj_row := json_object_t();
      v_rcnt := 0;
      for r1 in c_tassets loop
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codasset', r1.codasset);
          obj_data.put('desasse', r1.assetname);
          obj_data.put('dterec', to_char(r1.dtercass, 'dd/mm/yyyy'));
          obj_data.put('remark',r1.remark);

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt := v_rcnt + 1;
          insert into ttemprpt (codempid,codapp,numseq,item1,item2,
                              item3,item4,item5,
                              item6,item7)
          values (global_v_codempid,p_codapp,v_numseq,'TABLE3',p_codempid,
                  v_rcnt,r1.codasset,r1.assetname,
                  hcm_util.get_date_buddhist_era(r1.dtercass),r1.remark); 
          v_numseq := v_numseq + 1 ;    
      end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tassets_info;

end hres39x;

/

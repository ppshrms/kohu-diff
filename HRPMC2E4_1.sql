--------------------------------------------------------
--  DDL for Package Body HRPMC2E4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMC2E4" is
-- last update: 07/8/2018 11:40
  function get_numappl(p_codempid varchar2) return varchar2 is
    v_numappl   temploy1.numappl%type;
  begin
    begin
      select  nvl(numappl,codempid)
      into    v_numappl
      from    temploy1
      where   codempid = p_codempid;
    exception when no_data_found then
      v_numappl := p_codempid;
    end;
    return v_numappl;
  end; -- end get_numappl
  --
  procedure initial_value(json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    --global
    global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
    param_flgwarn       := hcm_util.get_string(json_obj,'flgwarning');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_codempid_query    := hcm_util.get_string(json_obj,'p_codempid_query');

    begin
      select  codcomp
      into    work_codcomp
      from    temploy1
      where   codempid    = p_codempid_query;
    exception when no_data_found then
      null;
    end;
  end; -- end initial_value
  --
  procedure initial_tab_guarantor(json_guarantor json) is
    json_guarantor_row    json;
  begin
    for i in 0..json_guarantor.count-1 loop
      json_guarantor_row                    := hcm_util.get_json(json_guarantor,to_char(i));
      p_flg_del_gua(i+1)                    := hcm_util.get_string(json_guarantor_row,'flg');
      guarantor_tab(i+1).codempgrt          := hcm_util.get_string(json_guarantor_row,'codempgrt');
      guarantor_tab(i+1).numseq             := hcm_util.get_string(json_guarantor_row,'numseq');
      guarantor_tab(i+1).dtegucon           := to_date(hcm_util.get_string(json_guarantor_row,'dtegucon'),'dd/mm/yyyy');
      guarantor_tab(i+1).codtitle           := hcm_util.get_string(json_guarantor_row,'codtitle');
      guarantor_tab(i+1).namfirste          := hcm_util.get_string(json_guarantor_row,'namfirste');
      guarantor_tab(i+1).namfirstt          := hcm_util.get_string(json_guarantor_row,'namfirstt');
      guarantor_tab(i+1).namfirst3          := hcm_util.get_string(json_guarantor_row,'namfirst3');
      guarantor_tab(i+1).namfirst4          := hcm_util.get_string(json_guarantor_row,'namfirst4');
      guarantor_tab(i+1).namfirst5          := hcm_util.get_string(json_guarantor_row,'namfirst5');
      guarantor_tab(i+1).namlaste           := hcm_util.get_string(json_guarantor_row,'namlaste');
      guarantor_tab(i+1).namlastt           := hcm_util.get_string(json_guarantor_row,'namlastt');
      guarantor_tab(i+1).namlast3           := hcm_util.get_string(json_guarantor_row,'namlast3');
      guarantor_tab(i+1).namlast4           := hcm_util.get_string(json_guarantor_row,'namlast4');
      guarantor_tab(i+1).namlast5           := hcm_util.get_string(json_guarantor_row,'namlast5');
      guarantor_tab(i+1).dteguabd           := to_date(hcm_util.get_string(json_guarantor_row,'dteguabd'),'dd/mm/yyyy');
      guarantor_tab(i+1).dteguret           := to_date(hcm_util.get_string(json_guarantor_row,'dteguret'),'dd/mm/yyyy');
      guarantor_tab(i+1).codident           := hcm_util.get_string(json_guarantor_row,'codident');
      guarantor_tab(i+1).numoffid           := hcm_util.get_string(json_guarantor_row,'numoffid');
      guarantor_tab(i+1).dteidexp           := to_date(hcm_util.get_string(json_guarantor_row,'dteidexp'),'dd/mm/yyyy');
      guarantor_tab(i+1).adrcont            := hcm_util.get_string(json_guarantor_row,'adrcont');
      guarantor_tab(i+1).codpost            := hcm_util.get_string(json_guarantor_row,'codpost');
      guarantor_tab(i+1).numtele            := hcm_util.get_string(json_guarantor_row,'numtele');
      guarantor_tab(i+1).codoccup           := hcm_util.get_string(json_guarantor_row,'codoccup');
      guarantor_tab(i+1).despos             := hcm_util.get_string(json_guarantor_row,'despos');
      guarantor_tab(i+1).amtmthin           := stdenc(nvl(hcm_util.get_string(json_guarantor_row,'amtmthin'),0),p_codempid_query,global_v_chken);
      guarantor_tab(i+1).adroffi            := hcm_util.get_string(json_guarantor_row,'adroffi');
      guarantor_tab(i+1).codposto           := hcm_util.get_string(json_guarantor_row,'codposto');
      guarantor_tab(i+1).numteleo           := hcm_util.get_string(json_guarantor_row,'numteleo');
      guarantor_tab(i+1).desnote            := hcm_util.get_string(json_guarantor_row,'desnote');
      guarantor_tab(i+1).desrelat           := hcm_util.get_string(json_guarantor_row,'desrelat');
      guarantor_tab(i+1).email              := hcm_util.get_string(json_guarantor_row,'email');
      guarantor_tab(i+1).numfax             := hcm_util.get_string(json_guarantor_row,'numfax');
      guarantor_tab(i+1).amtguarntr         := stdenc(hcm_util.get_string(json_guarantor_row,'amtguarntr'),p_codempid_query,global_v_chken);
    end loop;
  end; -- end initial_tab_guarantor
  --
  procedure initial_tab_collateral(json_collateral json) is
    json_collateral_row    json;
  begin
    for i in 0..json_collateral.count-1 loop
      json_collateral_row                    := hcm_util.get_json(json_collateral,to_char(i));
      p_flg_del_coll(i+1)                    := hcm_util.get_string(json_collateral_row,'flg');
      collateral_tab(i+1).numcolla           := hcm_util.get_string(json_collateral_row,'numcolla');
      collateral_tab(i+1).numdocum           := hcm_util.get_string(json_collateral_row,'numdocum');
      collateral_tab(i+1).typcolla           := hcm_util.get_string(json_collateral_row,'typcolla');
      collateral_tab(i+1).amtcolla           := stdenc(replace(hcm_util.get_string(json_collateral_row,'amtcolla'),',',''),p_codempid_query,global_v_chken);
      collateral_tab(i+1).descoll            := hcm_util.get_string(json_collateral_row,'descoll');
      collateral_tab(i+1).dtecolla           := to_date(hcm_util.get_string(json_collateral_row,'dtecolla'),'dd/mm/yyyy');
      collateral_tab(i+1).dtertdoc           := to_date(hcm_util.get_string(json_collateral_row,'dtertdoc'),'dd/mm/yyyy');
      collateral_tab(i+1).dteeffec           := to_date(hcm_util.get_string(json_collateral_row,'dteeffec'),'dd/mm/yyyy');
      collateral_tab(i+1).filename           := hcm_util.get_string(json_collateral_row,'filename');
      collateral_tab(i+1).status             := hcm_util.get_string(json_collateral_row,'status');
      collateral_tab(i+1).flgded             := hcm_util.get_string(json_collateral_row,'flgded');
      collateral_tab(i+1).qtyperiod          := hcm_util.get_string(json_collateral_row,'qtyperiod');
      collateral_tab(i+1).amtdedcol          := stdenc(replace(hcm_util.get_string(json_collateral_row,'amtdedcol'),',',''),p_codempid_query,global_v_chken);
      collateral_tab(i+1).dtestrt            := to_date(hcm_util.get_string(json_collateral_row,'dtestrt'),'dd/mm/yyyy');
      collateral_tab(i+1).dteend             := to_date(hcm_util.get_string(json_collateral_row,'dteend'),'dd/mm/yyyy');
      collateral_tab(i+1).amtded             := stdenc(replace(hcm_util.get_string(json_collateral_row,'amtded'),',',''),p_codempid_query,global_v_chken);
    end loop;
  end; -- end initial_tab_collateral
  --
  procedure initial_tab_reference(json_reference json) is
    json_reference_row    json;
  begin
    for i in 0..json_reference.count-1 loop
      json_reference_row                 := hcm_util.get_json(json_reference,to_char(i));
      p_flg_del_ref(i+1)                 := hcm_util.get_string(json_reference_row,'flg');
      reference_tab(i+1).numseq          := hcm_util.get_string(json_reference_row,'numseq');
      reference_tab(i+1).codempref       := hcm_util.get_string(json_reference_row,'codempref');
      reference_tab(i+1).codtitle        := hcm_util.get_string(json_reference_row,'codtitle');
      reference_tab(i+1).namfirste       := hcm_util.get_string(json_reference_row,'namfirste');
      reference_tab(i+1).namfirstt       := hcm_util.get_string(json_reference_row,'namfirstt');
      reference_tab(i+1).namfirst3       := hcm_util.get_string(json_reference_row,'namfirst3');
      reference_tab(i+1).namfirst4       := hcm_util.get_string(json_reference_row,'namfirst4');
      reference_tab(i+1).namfirst5       := hcm_util.get_string(json_reference_row,'namfirst5');
      reference_tab(i+1).namlaste        := hcm_util.get_string(json_reference_row,'namlaste');
      reference_tab(i+1).namlastt        := hcm_util.get_string(json_reference_row,'namlastt');
      reference_tab(i+1).namlast3        := hcm_util.get_string(json_reference_row,'namlast3');
      reference_tab(i+1).namlast4        := hcm_util.get_string(json_reference_row,'namlast4');
      reference_tab(i+1).namlast5        := hcm_util.get_string(json_reference_row,'namlast5');
      reference_tab(i+1).flgref          := hcm_util.get_string(json_reference_row,'flgref');
      reference_tab(i+1).despos          := hcm_util.get_string(json_reference_row,'despos');
      reference_tab(i+1).adrcont1        := hcm_util.get_string(json_reference_row,'adrcont1');
      reference_tab(i+1).desnoffi        := hcm_util.get_string(json_reference_row,'desnoffi');
      reference_tab(i+1).numtele         := hcm_util.get_string(json_reference_row,'numtele');
      reference_tab(i+1).email           := hcm_util.get_string(json_reference_row,'email');
      reference_tab(i+1).codoccup        := hcm_util.get_string(json_reference_row,'codoccup');
      reference_tab(i+1).remark          := hcm_util.get_string(json_reference_row,'remark');

    end loop;
  end; -- end initial_tab_reference
  --
  function check_emp_status return varchar2 is
    v_status    varchar2(100);
  begin
    begin
      select  'UPDATE'
      into    v_status
      from    temploy1
      where   codempid = p_codempid_query;
    exception when no_data_found then
      v_status  := 'INSERT';
    end;
    return v_status;
  end;
  --
  function check_codempid(p_codempid_rel varchar2) return varchar2 is
    v_code          varchar2(100);
  begin
    if p_codempid_rel is not null then
      begin
        select  codempid
        into    v_code
        from    temploy1
        where   codempid  = p_codempid_rel;
      exception when no_data_found then
        v_code  := '';
      end;
    end if;
    return v_code;
  end; -- end check_codempid
  --
  function get_desciption (p_table in varchar2,p_field in varchar2,p_code in varchar2) return varchar2 is
    v_desc     varchar2(500):= p_code;
    v_stament  varchar2(500);
    v_funcdesc varchar2(500);
    v_data_type varchar2(500);
  begin
    if p_code is null then
      return v_desc ;
    end if;

    begin
      select  funcdesc,data_type
      into    v_funcdesc,v_data_type
      from    tcoldesc
      where   codtable  = p_table
      and     codcolmn  = p_field
      and     rownum    = 1 ;
    exception when no_data_found then
       v_funcdesc := null;
    end ;

    if v_funcdesc is not null   then
      v_stament   := 'select '||v_funcdesc||'from dual' ;
      v_stament   := replace(v_stament,'P_CODE',''''||p_code||'''') ;
      v_stament   := replace(v_stament,'P_LANG',global_v_lang) ;
      return execute_desc (v_stament) ;
    else
      if v_data_type = 'DATE' then
        return hcm_util.get_date_buddhist_era(to_date(v_desc,'dd/mm/yyyy'));
      elsif p_field in ('STAYEAR','DTEGYEAR') then
        return v_desc + global_v_zyear;
      else
        return v_desc ;
      end if;
    end if;
  end; -- end get_desciption
  --
  procedure upd_log1
    (p_codtable	in varchar2,
     p_numpage 	in varchar2,
     p_fldedit 	in varchar2,
     p_typdata 	in varchar2,
     p_desold 	in varchar2,
     p_desnew 	in varchar2,
     p_flgenc 	in varchar2,
     p_upd	    in out boolean) is

     v_exist		 boolean := false;
     v_datenew 	 date;
     v_dateold 	 date;
     v_desnew 	 varchar2(500 char) ;
     v_desold 	 varchar2(500 char) ;

    cursor c_ttemlog1 is
      select rowid
      from   ttemlog1
      where  codempid = p_codempid_query
      and		 dteedit	= sysdate
      and		 numpage	= p_numpage
      and    fldedit  = upper(p_fldedit);
  begin
    if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
       v_desnew := p_desnew ;
       v_desold := p_desold ;
       if  p_typdata = 'D' then
           if  p_desnew is not null and global_v_zyear = 543 then
               v_datenew := add_months(to_date(v_desnew,'dd/mm/yyyy'),-(543*12));
               v_desnew  := to_char(v_datenew,'dd/mm/yyyy') ;
           end if;
           if  p_desold is not null and global_v_zyear = 543 then
               v_dateold := add_months(to_date(v_desold,'dd/mm/yyyy'),-(543*12));
               v_desold  := to_char(v_dateold,'dd/mm/yyyy') ;
           end if;
       end if;
--      if :parameter.codapp in ('PMC2','RECRUIT') then sssssssssssssssssssssssssssssss
        p_upd := true;
        for r_ttemlog1 in c_ttemlog1 loop
          v_exist := true;
          update ttemlog1
          set    codcomp 	= work_codcomp,
                 desold 	= v_desold,
                 desnew 	= v_desnew,
                 flgenc 	= p_flgenc,
                 codtable = upper(p_codtable),
                 dteupd 	= trunc(sysdate),
                 coduser 	= global_v_coduser
          where  rowid = r_ttemlog1.rowid;
        end loop;
        if not v_exist then
          insert into  ttemlog1
            (codempid,dteedit,numpage,fldedit,codcomp,
             desold,desnew,flgenc,codtable,dteupd,coduser)
          values
            (p_codempid_query,sysdate,p_numpage,upper(p_fldedit),work_codcomp,
             v_desold,v_desnew,p_flgenc,upper(p_codtable),trunc(sysdate),global_v_coduser);
        end if;
    end if;
  end; -- end upd_log1
  --
  procedure upd_log2
    (p_codtable	in varchar2,
     p_numpage 	in varchar2,
     p_numseq		in number,
     p_fldedit 	in varchar2,
     p_typkey 	in varchar2,
     p_fldkey 	in varchar2,
     p_codseq 	in varchar2,
     p_dteseq 	in date,
     p_typdata 	in varchar2,
     p_desold 	in varchar2,
     p_desnew 	in varchar2,
     p_flgenc 	in varchar2,
     p_upd	in out boolean,
     p_flgdata  in varchar2 default 'U') is
    v_exist		boolean := false;
     v_datenew 	 date;
     v_dateold 	 date;
     v_desnew 	 varchar2(500 char) ;
     v_desold 	 varchar2(500 char) ;

  cursor c_ttemlog2 is
    select rowid
    from   ttemlog2
    where  codempid = p_codempid_query
    and		 dteedit	= sysdate
    and		 numpage	= p_numpage
    and		 numseq 	= p_numseq
    and    fldedit  = upper(p_fldedit);
  begin
    if check_emp_status = 'INSERT' then--and:parameter.codapp <> 'REHIRE'
      p_upd := true;--Modify 10/07/2551
      return;
    end if;
    if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
       v_desnew := p_desnew ;
       v_desold := p_desold ;
       if  p_typdata = 'D' then
           if  p_desnew is not null and global_v_zyear = 543 then
               v_datenew := add_months(to_date(v_desnew,'dd/mm/yyyy'),-(543*12));
               v_desnew  := to_char(v_datenew,'dd/mm/yyyy') ;
           end if;
           if  p_desold is not null and global_v_zyear = 543 then
               v_dateold := add_months(to_date(v_desold,'dd/mm/yyyy'),-(543*12));
               v_desold  := to_char(v_dateold,'dd/mm/yyyy') ;
           end if;
       end if;

--      if :parameter.codapp in('PMC2','RECRUIT') then
        p_upd := true;
        for r_ttemlog2 in c_ttemlog2 loop
          v_exist := true;
          update ttemlog2
          set    typkey = p_typkey,
                 fldkey = upper(p_fldkey),
                 codseq = p_codseq,
                 dteseq = p_dteseq,
                 codcomp = work_codcomp,
                 desold = v_desold,
                 desnew = v_desnew,
                 flgenc = p_flgenc,
                 codtable = upper(p_codtable),
                 flgdata = p_flgdata,
                 coduser = global_v_coduser
          where  rowid = r_ttemlog2.rowid;
        end loop;
        if not v_exist then
          insert into  ttemlog2
            (codempid,dteedit,numpage,numseq,fldedit,codcomp,
             typkey,fldkey,codseq,dteseq,
             desold,desnew,flgenc,codtable,codcreate,coduser,
             flgdata)
          values
            (p_codempid_query,sysdate,p_numpage,p_numseq,upper(p_fldedit),work_codcomp,
             p_typkey,p_fldkey,p_codseq,p_dteseq,
             v_desold,v_desnew,p_flgenc,upper(p_codtable),global_v_coduser,global_v_coduser,
             p_flgdata);
        end if;
--      end if;
    end if;
  end; -- end upd_log2
  --
  procedure upd_log3
    (p_codtable	  in varchar2,
     p_numpage 	  in varchar2,
     p_typdeduct 	in varchar2,
     p_coddeduct 	in varchar2,
     p_desold 	  in varchar2,
     p_desnew 	  in varchar2,
     p_upd	      in out boolean) is

    v_exist		boolean := false;

  cursor c_ttemlog3 is
    select rowid
    from   ttemlog3
    where  codempid  = p_codempid_query
    and		 dteedit	 = sysdate
    and		 numpage	 = p_numpage
    and    typdeduct = p_typdeduct
    and    coddeduct = p_coddeduct;
  begin
    if check_emp_status = 'INSERT' then
      p_upd := true; --Modify 10/07/2551
      return;
    end if;
    if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
--      if :parameter.codapp in('PMC2','RECRUIT') then
        p_upd := true;
        for r_ttemlog3 in c_ttemlog3 loop
          v_exist := true;
          update ttemlog3
          set    codcomp = work_codcomp,
                 desold = p_desold,
                 desnew = p_desnew,
                 codtable = upper(p_codtable),
                 codcreate = global_v_coduser,
                 coduser = global_v_coduser
          where  rowid = r_ttemlog3.rowid;
        end loop;
        if not v_exist then
          insert into  ttemlog3
            (codempid,dteedit,numpage,typdeduct,coddeduct,
             codcomp,desold,desnew,codtable,codcreate,coduser)
          values
            (p_codempid_query,sysdate,p_numpage,p_typdeduct,p_coddeduct,
             work_codcomp,p_desold,p_desnew,upper(p_codtable),global_v_coduser,global_v_coduser);
        end if;
--      end if;
    end if;
  end; -- end upd_log3
  --
  procedure save_guarantor is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_numseq      number;

    cursor c_tguarntr is
      select  codempid,codempgrt,
              numseq,dtegucon,codtitle,
              namguare,namguart,namguar3,namguar4,namguar5,
              namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
              namlaste,namlastt,namlast3,namlast4,namlast5,
              dteguabd,dteguret,codident,numoffid,dteidexp,
              adrcont,codpost,numtele,codoccup,despos,
              amtmthin,adroffi,codposto,numteleo,
              desnote,
              desrelat,email,numfax,amtguarntr,
              rowid
      from    tguarntr
      where   codempid  = p_codempid_query
      and     numseq    = v_numseq
      order by numseq;

    v_namguare        tguarntr.namguare%type;
    v_namguart        tguarntr.namguare%type;
    v_namguar3        tguarntr.namguare%type;
    v_namguar4        tguarntr.namguare%type;
    v_namguar5        tguarntr.namguare%type;
  begin
    v_numseq    := 0;
    for n in 1..guarantor_tab.count loop
      v_numseq    := guarantor_tab(n).numseq;
      guarantor_tab(n).codempgrt    := check_codempid(guarantor_tab(n).codempgrt);
      if p_flg_del_gua(n) = 'delete' then
--        for i in c_tguarntr loop
--          upd_log2('tguarntr','41',v_numseq,'codempgrt','N','numseq',null,null,'C',i.codempgrt,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'dtegucon','N','numseq',null,null,'D',to_char(i.dtegucon,'dd/mm/yyyy'),null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namguare','N','numseq',null,null,'C',i.namguare,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namguart','N','numseq',null,null,'C',i.namguart,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namguar3','N','numseq',null,null,'C',i.namguar3,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namguar4','N','numseq',null,null,'C',i.namguar4,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namguar5','N','numseq',null,null,'C',i.namguar5,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namfirste','N','numseq',null,null,'C',i.namfirste,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namfirstt','N','numseq',null,null,'C',i.namfirstt,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namfirst3','N','numseq',null,null,'C',i.namfirst3,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namfirst4','N','numseq',null,null,'C',i.namfirst4,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namfirst5','N','numseq',null,null,'C',i.namfirst5,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namlaste','N','numseq',null,null,'C',i.namlaste,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namlastt','N','numseq',null,null,'C',i.namlastt,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namlast3','N','numseq',null,null,'C',i.namlast3,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namlast4','N','numseq',null,null,'C',i.namlast4,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'namlast5','N','numseq',null,null,'C',i.namlast5,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'dteguabd','N','numseq',null,null,'D',to_char(i.dteguabd,'dd/mm/yyyy'),null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'dteguret','N','numseq',null,null,'D',to_char(i.dteguret,'dd/mm/yyyy'),null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'codident','N','numseq',null,null,'C',i.codident,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'numoffid','N','numseq',null,null,'C',i.numoffid,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'dteidexp','N','numseq',null,null,'D',to_char(i.dteidexp,'dd/mm/yyyy'),null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'adrcont','N','numseq',null,null,'C',i.adrcont,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'codpost','N','numseq',null,null,'N',i.codpost,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'numtele','N','numseq',null,null,'C',i.numtele,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'codoccup','N','numseq',null,null,'C',i.codoccup,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'despos','N','numseq',null,null,'C',i.despos,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'amtmthin','N','numseq',null,null,'C',i.amtmthin,null,'Y',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'adroffi','N','numseq',null,null,'C',i.adroffi,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'codposto','N','numseq',null,null,'N',i.codposto,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'numteleo','N','numseq',null,null,'C',i.numteleo,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'desnote','N','numseq',null,null,'C',i.desnote,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'desrelat','N','numseq',null,null,'C',i.desrelat,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'email','N','numseq',null,null,'C',i.email,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'numfax','N','numseq',null,null,'C',i.numfax,null,'N',v_upd,'D');
--          upd_log2('tguarntr','41',v_numseq,'amtguarntr','N','numseq',null,null,'C',i.amtguarntr,null,'Y',v_upd,'D');
--        end loop;

        delete from tguarntr
        where   codempid    = p_codempid_query
        and     numseq      = v_numseq;
      else
        if guarantor_tab(n).numseq > 0 then
          v_exist     := false;
          v_upd       := false;

          v_namguare	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',guarantor_tab(n).codtitle,'101')))||
                             ltrim(rtrim(guarantor_tab(n).namfirste))||' '||ltrim(rtrim(guarantor_tab(n).namlaste)),1,100);
          v_namguart	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',guarantor_tab(n).codtitle,'102')))||
                             ltrim(rtrim(guarantor_tab(n).namfirstt))||' '||ltrim(rtrim(guarantor_tab(n).namlastt)),1,100);
          v_namguar3	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',guarantor_tab(n).codtitle,'103')))||
                             ltrim(rtrim(guarantor_tab(n).namfirst3))||' '||ltrim(rtrim(guarantor_tab(n).namlast3)),1,100);
          v_namguar4	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',guarantor_tab(n).codtitle,'104')))||
                             ltrim(rtrim(guarantor_tab(n).namfirst4))||' '||ltrim(rtrim(guarantor_tab(n).namlast4)),1,100);
          v_namguar5	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',guarantor_tab(n).codtitle,'105')))||
                             ltrim(rtrim(guarantor_tab(n).namfirst5))||' '||ltrim(rtrim(guarantor_tab(n).namlast5)),1,100);

          for i in c_tguarntr loop
            v_exist := true;
            upd_log2('tguarntr','41',v_numseq,'codempgrt','N','numseq',null,null,'C',i.codempgrt,guarantor_tab(n).codempgrt,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'dtegucon','N','numseq',null,null,'D',to_char(i.dtegucon,'dd/mm/yyyy'),to_char(guarantor_tab(n).dtegucon,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namguare','N','numseq',null,null,'C',i.namguare,v_namguare,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namguart','N','numseq',null,null,'C',i.namguart,v_namguart,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namguar3','N','numseq',null,null,'C',i.namguar3,v_namguar3,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namguar4','N','numseq',null,null,'C',i.namguar4,v_namguar4,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namguar5','N','numseq',null,null,'C',i.namguar5,v_namguar5,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namfirste','N','numseq',null,null,'C',i.namfirste,guarantor_tab(n).namfirste,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namfirstt','N','numseq',null,null,'C',i.namfirstt,guarantor_tab(n).namfirstt,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namfirst3','N','numseq',null,null,'C',i.namfirst3,guarantor_tab(n).namfirst3,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namfirst4','N','numseq',null,null,'C',i.namfirst4,guarantor_tab(n).namfirst4,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namfirst5','N','numseq',null,null,'C',i.namfirst5,guarantor_tab(n).namfirst5,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namlaste','N','numseq',null,null,'C',i.namlaste,guarantor_tab(n).namlaste,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namlastt','N','numseq',null,null,'C',i.namlastt,guarantor_tab(n).namlastt,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namlast3','N','numseq',null,null,'C',i.namlast3,guarantor_tab(n).namlast3,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namlast4','N','numseq',null,null,'C',i.namlast4,guarantor_tab(n).namlast4,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'namlast5','N','numseq',null,null,'C',i.namlast5,guarantor_tab(n).namlast5,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'dteguabd','N','numseq',null,null,'D',to_char(i.dteguabd,'dd/mm/yyyy'),to_char(guarantor_tab(n).dteguabd,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'dteguret','N','numseq',null,null,'D',to_char(i.dteguret,'dd/mm/yyyy'),to_char(guarantor_tab(n).dteguret,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'codident','N','numseq',null,null,'C',i.codident,guarantor_tab(n).codident,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'numoffid','N','numseq',null,null,'C',i.numoffid,guarantor_tab(n).numoffid,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'dteidexp','N','numseq',null,null,'D',to_char(i.dteidexp,'dd/mm/yyyy'),to_char(guarantor_tab(n).dteidexp,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'adrcont','N','numseq',null,null,'C',i.adrcont,guarantor_tab(n).adrcont,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'codpost','N','numseq',null,null,'N',i.codpost,guarantor_tab(n).codpost,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'numtele','N','numseq',null,null,'C',i.numtele,guarantor_tab(n).numtele,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'codoccup','N','numseq',null,null,'C',i.codoccup,guarantor_tab(n).codoccup,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'despos','N','numseq',null,null,'C',i.despos,guarantor_tab(n).despos,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'amtmthin','N','numseq',null,null,'C',i.amtmthin,guarantor_tab(n).amtmthin,'Y',v_upd);
            upd_log2('tguarntr','41',v_numseq,'adroffi','N','numseq',null,null,'C',i.adroffi,guarantor_tab(n).adroffi,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'codposto','N','numseq',null,null,'N',i.codposto,guarantor_tab(n).codposto,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'numteleo','N','numseq',null,null,'C',i.numteleo,guarantor_tab(n).numteleo,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'desnote','N','numseq',null,null,'C',i.desnote,guarantor_tab(n).desnote,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'desrelat','N','numseq',null,null,'C',i.desrelat,guarantor_tab(n).desrelat,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'email','N','numseq',null,null,'C',i.email,guarantor_tab(n).email,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'numfax','N','numseq',null,null,'C',i.numfax,guarantor_tab(n).numfax,'N',v_upd);
            upd_log2('tguarntr','41',v_numseq,'amtguarntr','N','numseq',null,null,'C',i.amtguarntr,guarantor_tab(n).amtguarntr,'Y',v_upd);
            if v_upd then
              update tguarntr
                 set codempgrt      = guarantor_tab(n).codempgrt,
                     dtegucon       = guarantor_tab(n).dtegucon,
                     codtitle       = guarantor_tab(n).codtitle,
                     namguare       = v_namguare,
                     namguart       = v_namguart,
                     namguar3       = v_namguar3,
                     namguar4       = v_namguar4,
                     namguar5       = v_namguar5,
                     namfirste      = guarantor_tab(n).namfirste,
                     namfirstt      = guarantor_tab(n).namfirstt,
                     namfirst3      = guarantor_tab(n).namfirst3,
                     namfirst4      = guarantor_tab(n).namfirst4,
                     namfirst5      = guarantor_tab(n).namfirst5,
                     namlaste       = guarantor_tab(n).namlaste,
                     namlastt       = guarantor_tab(n).namlastt,
                     namlast3       = guarantor_tab(n).namlast3,
                     namlast4       = guarantor_tab(n).namlast4,
                     namlast5       = guarantor_tab(n).namlast5,
                     dteguabd       = guarantor_tab(n).dteguabd,
                     dteguret       = guarantor_tab(n).dteguret,
                     codident       = guarantor_tab(n).codident,
                     numoffid       = guarantor_tab(n).numoffid,
                     dteidexp       = guarantor_tab(n).dteidexp,
                     adrcont        = guarantor_tab(n).adrcont,
                     codpost        = guarantor_tab(n).codpost,
                     numtele        = guarantor_tab(n).numtele,
                     codoccup       = guarantor_tab(n).codoccup,
                     despos         = guarantor_tab(n).despos,
                     amtmthin       = guarantor_tab(n).amtmthin,
                     adroffi        = guarantor_tab(n).adroffi,
                     codposto       = guarantor_tab(n).codposto,
                     numteleo       = guarantor_tab(n).numteleo,
                     desnote        = guarantor_tab(n).desnote,
                     desrelat       = guarantor_tab(n).desrelat,
                     email          = guarantor_tab(n).email,
                     numfax         = guarantor_tab(n).numfax,
                     amtguarntr     = guarantor_tab(n).amtguarntr,
                     coduser        = global_v_coduser
               where rowid = i.rowid;
            end if;
          end loop;

          if not v_exist then
            upd_log2('tguarntr','41',v_numseq,'codempgrt','N','numseq',null,null,'C',null,guarantor_tab(n).codempgrt,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'dtegucon','N','numseq',null,null,'D',null,to_char(guarantor_tab(n).dtegucon,'dd/mm/yyyy'),'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'codtitle','N','numseq',null,null,'C',null,guarantor_tab(n).codtitle,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namguare','N','numseq',null,null,'C',null,v_namguare,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namguart','N','numseq',null,null,'C',null,v_namguart,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namguar3','N','numseq',null,null,'C',null,v_namguar3,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namguar4','N','numseq',null,null,'C',null,v_namguar4,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namguar5','N','numseq',null,null,'C',null,v_namguar5,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namfirste','N','numseq',null,null,'C',null,guarantor_tab(n).namfirste,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namfirstt','N','numseq',null,null,'C',null,guarantor_tab(n).namfirstt,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namfirst3','N','numseq',null,null,'C',null,guarantor_tab(n).namfirst3,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namfirst4','N','numseq',null,null,'C',null,guarantor_tab(n).namfirst4,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namfirst5','N','numseq',null,null,'C',null,guarantor_tab(n).namfirst5,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namlaste','N','numseq',null,null,'C',null,guarantor_tab(n).namlaste,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namlastt','N','numseq',null,null,'C',null,guarantor_tab(n).namlastt,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namlast3','N','numseq',null,null,'C',null,guarantor_tab(n).namlast3,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namlast4','N','numseq',null,null,'C',null,guarantor_tab(n).namlast4,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'namlast5','N','numseq',null,null,'C',null,guarantor_tab(n).namlast5,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'dteguabd','N','numseq',null,null,'D',null,to_char(guarantor_tab(n).dteguabd,'dd/mm/yyyy'),'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'dteguret','N','numseq',null,null,'D',null,to_char(guarantor_tab(n).dteguret,'dd/mm/yyyy'),'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'codident','N','numseq',null,null,'C',null,guarantor_tab(n).codident,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'numoffid','N','numseq',null,null,'C',null,guarantor_tab(n).numoffid,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'dteidexp','N','numseq',null,null,'D',null,to_char(guarantor_tab(n).dteidexp,'dd/mm/yyyy'),'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'adrcont','N','numseq',null,null,'C',null,guarantor_tab(n).adrcont,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'codpost','N','numseq',null,null,'N',null,guarantor_tab(n).codpost,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'numtele','N','numseq',null,null,'C',null,guarantor_tab(n).numtele,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'codoccup','N','numseq',null,null,'C',null,guarantor_tab(n).codoccup,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'despos','N','numseq',null,null,'C',null,guarantor_tab(n).despos,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'amtmthin','N','numseq',null,null,'C',null,guarantor_tab(n).amtmthin,'Y',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'adroffi','N','numseq',null,null,'C',null,guarantor_tab(n).adroffi,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'codposto','N','numseq',null,null,'N',null,guarantor_tab(n).codposto,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'numteleo','N','numseq',null,null,'C',null,guarantor_tab(n).numteleo,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'desnote','N','numseq',null,null,'C',null,guarantor_tab(n).desnote,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'desrelat','N','numseq',null,null,'C',null,guarantor_tab(n).desrelat,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'email','N','numseq',null,null,'C',null,guarantor_tab(n).email,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'numfax','N','numseq',null,null,'C',null,guarantor_tab(n).numfax,'N',v_upd,'I');
            upd_log2('tguarntr','41',v_numseq,'amtguarntr','N','numseq',null,null,'C',null,guarantor_tab(n).amtguarntr,'y',v_upd,'I');

            if v_upd then
              insert into tguarntr
                ( codempid,codempgrt,
                  numseq,dtegucon,codtitle,
                  namguare,namguart,namguar3,namguar4,namguar5,
                  namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                  namlaste,namlastt,namlast3,namlast4,namlast5,
                  dteguabd,dteguret,codident,numoffid,dteidexp,
                  adrcont,codpost,numtele,codoccup,despos,
                  amtmthin,adroffi,codposto,
                  numteleo,
                  desnote,
                  desrelat,email,numfax,
                  amtguarntr,
                  codcreate,coduser)
              values
                ( p_codempid_query,guarantor_tab(n).codempgrt,
                  guarantor_tab(n).numseq,guarantor_tab(n).dtegucon,guarantor_tab(n).codtitle,
                  v_namguare,v_namguart,v_namguar3,v_namguar4,v_namguar5,
                  guarantor_tab(n).namfirste,guarantor_tab(n).namfirstt,guarantor_tab(n).namfirst3,guarantor_tab(n).namfirst4,guarantor_tab(n).namfirst5,
                  guarantor_tab(n).namlaste,guarantor_tab(n).namlastt,guarantor_tab(n).namlast3,guarantor_tab(n).namlast4,guarantor_tab(n).namlast5,
                  guarantor_tab(n).dteguabd,guarantor_tab(n).dteguret,guarantor_tab(n).codident,guarantor_tab(n).numoffid,guarantor_tab(n).dteidexp,
                  guarantor_tab(n).adrcont,guarantor_tab(n).codpost,guarantor_tab(n).numtele,guarantor_tab(n).codoccup,guarantor_tab(n).despos,
                  guarantor_tab(n).amtmthin,guarantor_tab(n).adroffi,guarantor_tab(n).codposto,
                  guarantor_tab(n).numteleo,
                  guarantor_tab(n).desnote,
                  guarantor_tab(n).desrelat,guarantor_tab(n).email,guarantor_tab(n).numfax,
                  guarantor_tab(n).amtguarntr,
                  global_v_coduser,global_v_coduser);
            end if;
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_guarantor
  --
  procedure save_collateral is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_numseq      number;
    v_numcolla    tcolltrl.numcolla%type;
    v_numrefdoc   tappldoc.numrefdoc%type;

    cursor c_tcolltrl is
      select  codempid,numcolla,numdocum,typcolla,amtcolla,
              descoll,dtecolla,dtertdoc,dteeffec,filename,
              status,flgded,qtyperiod,amtdedcol,dtestrt,
              dteend,amtded,numrefdoc,rowid
      from	  tcolltrl
      where	  codempid  = p_codempid_query
      and		  numcolla  = v_numcolla;

  begin
    v_numseq      := 0;

    for n in 1..collateral_tab.count loop
      v_numseq      := v_numseq + 1;
      v_numcolla    := collateral_tab(n).numcolla;
      v_numrefdoc   := null;
      if p_flg_del_coll(n) = 'delete' then
--        for i in c_tcolltrl loop
--          upd_log2('tcolltrl','42',v_numseq,'numdocum','C','numcolla',collateral_tab(n).numcolla,null,'C',i.numdocum,null,'N',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'typcolla','C','numcolla',collateral_tab(n).numcolla,null,'C',i.typcolla,null,'N',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'amtcolla','C','numcolla',collateral_tab(n).numcolla,null,'N',i.amtcolla,null,'Y',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'descoll','C','numcolla',collateral_tab(n).numcolla,null,'C',i.descoll,null,'N',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'dtecolla','C','numcolla',collateral_tab(n).numcolla,null,'D',to_char(i.dtecolla,'dd/mm/yyyy'),null,'N',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'dtertdoc','C','numcolla',collateral_tab(n).numcolla,null,'D',to_char(i.dtertdoc,'dd/mm/yyyy'),null,'N',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'dteeffec','C','numcolla',collateral_tab(n).numcolla,null,'D',to_char(i.dteeffec,'dd/mm/yyyy'),null,'N',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'filename','C','numcolla',collateral_tab(n).numcolla,null,'C',i.filename,null,'N',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'status','C','numcolla',collateral_tab(n).numcolla,null,'C',i.status,null,'N',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'flgded','C','numcolla',collateral_tab(n).numcolla,null,'C',i.flgded,null,'N',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'qtyperiod','C','numcolla',collateral_tab(n).numcolla,null,'C',i.qtyperiod,null,'N',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'amtdedcol','C','numcolla',collateral_tab(n).numcolla,null,'N',i.amtdedcol,null,'Y',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'dtestrt','C','numcolla',collateral_tab(n).numcolla,null,'D',to_char(i.dtestrt,'dd/mm/yyyy'),null,'N',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'dteend','C','numcolla',collateral_tab(n).numcolla,null,'D',to_char(i.dteend,'dd/mm/yyyy'),null,'N',v_upd,'D');
--          upd_log2('tcolltrl','42',v_numseq,'amtded','C','numcolla',collateral_tab(n).numcolla,null,'N',i.amtded,null,'Y',v_upd,'D');
--        end loop;

        for i in c_tcolltrl loop
          v_numrefdoc   := i.numrefdoc;
          exit;
        end loop;
        hrpmc2e.update_filedoc( p_codempid_query,
                                '',
                                GET_LABEL_NAME('HRPMC2E4T2',global_v_lang,10),
                                '0006',--- type doc collateral
                                global_v_coduser,
                                v_numrefdoc);
        delete from tcolltrl
        where   codempid    = p_codempid_query
        and     numcolla    = v_numcolla;
      else
        if collateral_tab(n).numcolla is not null then
          v_exist       := false;
          v_upd         := false;
          for i in c_tcolltrl loop
            v_exist       := true;
            v_numrefdoc   := i.numrefdoc;
            upd_log2('tcolltrl','42',v_numseq,'numdocum','C','numcolla',collateral_tab(n).numcolla,null,'C',i.numdocum,collateral_tab(n).numdocum,'N',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'typcolla','C','numcolla',collateral_tab(n).numcolla,null,'C',i.typcolla,collateral_tab(n).typcolla,'N',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'amtcolla','C','numcolla',collateral_tab(n).numcolla,null,'N',i.amtcolla,collateral_tab(n).amtcolla,'Y',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'descoll','C','numcolla',collateral_tab(n).numcolla,null,'C',i.descoll,collateral_tab(n).descoll,'N',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'dtecolla','C','numcolla',collateral_tab(n).numcolla,null,'D',to_char(i.dtecolla,'dd/mm/yyyy'),to_char(collateral_tab(n).dtecolla,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'dtertdoc','C','numcolla',collateral_tab(n).numcolla,null,'D',to_char(i.dtertdoc,'dd/mm/yyyy'),to_char(collateral_tab(n).dtertdoc,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'dteeffec','C','numcolla',collateral_tab(n).numcolla,null,'D',to_char(i.dteeffec,'dd/mm/yyyy'),to_char(collateral_tab(n).dteeffec,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'filename','C','numcolla',collateral_tab(n).numcolla,null,'C',i.filename,collateral_tab(n).filename,'N',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'status','C','numcolla',collateral_tab(n).numcolla,null,'C',i.status,collateral_tab(n).status,'N',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'flgded','C','numcolla',collateral_tab(n).numcolla,null,'C',i.flgded,collateral_tab(n).flgded,'N',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'qtyperiod','C','numcolla',collateral_tab(n).numcolla,null,'C',i.qtyperiod,collateral_tab(n).qtyperiod,'N',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'amtdedcol','C','numcolla',collateral_tab(n).numcolla,null,'N',i.amtdedcol,collateral_tab(n).amtdedcol,'Y',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'dtestrt','C','numcolla',collateral_tab(n).numcolla,null,'D',to_char(i.dtestrt,'dd/mm/yyyy'),to_char(collateral_tab(n).dtestrt,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'dteend','C','numcolla',collateral_tab(n).numcolla,null,'D',to_char(i.dteend,'dd/mm/yyyy'),to_char(collateral_tab(n).dteend,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tcolltrl','42',v_numseq,'amtded','C','numcolla',collateral_tab(n).numcolla,null,'N',i.amtded,collateral_tab(n).amtded,'Y',v_upd);
            --- update tappldoc ---
            if nvl(i.filename,'#$@') <> nvl(collateral_tab(n).filename,'#$@') then
              hrpmc2e.update_filedoc( p_codempid_query,
                                      collateral_tab(n).filename,
                                      GET_LABEL_NAME('HRPMC2E4T2',global_v_lang,10),
                                      '0006',--- type doc collateral
                                      global_v_coduser,
                                      v_numrefdoc);
            end if;
            -----------------------
            if v_upd then
              update tcolltrl
                 set numdocum        = collateral_tab(n).numdocum,
                     typcolla        = collateral_tab(n).typcolla,
                     amtcolla        = collateral_tab(n).amtcolla,
                     descoll         = collateral_tab(n).descoll,
                     dtecolla        = collateral_tab(n).dtecolla,
                     dtertdoc        = collateral_tab(n).dtertdoc,
                     dteeffec        = collateral_tab(n).dteeffec,
                     filename        = collateral_tab(n).filename,
                     status          = collateral_tab(n).status,
                     flgded          = collateral_tab(n).flgded,
                     qtyperiod       = collateral_tab(n).qtyperiod,
                     amtdedcol       = collateral_tab(n).amtdedcol,
                     dtestrt         = collateral_tab(n).dtestrt,
                     dteend          = collateral_tab(n).dteend,
                     amtded          = collateral_tab(n).amtded,
                     coduser         = global_v_coduser
               where rowid = i.rowid;
            end if;
          end loop;

          if not v_exist then
            upd_log2('tcolltrl','42',v_numseq,'numdocum','C','numcolla',collateral_tab(n).numcolla,null,'C',null,collateral_tab(n).numdocum,'N',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'typcolla','C','numcolla',collateral_tab(n).numcolla,null,'C',null,collateral_tab(n).typcolla,'N',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'amtcolla','C','numcolla',collateral_tab(n).numcolla,null,'N',null,collateral_tab(n).amtcolla,'Y',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'descoll','C','numcolla',collateral_tab(n).numcolla,null,'C',null,collateral_tab(n).descoll,'N',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'dtecolla','C','numcolla',collateral_tab(n).numcolla,null,'D',null,to_char(collateral_tab(n).dtecolla,'dd/mm/yyyy'),'N',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'dtertdoc','C','numcolla',collateral_tab(n).numcolla,null,'D',null,to_char(collateral_tab(n).dtertdoc,'dd/mm/yyyy'),'N',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'dteeffec','C','numcolla',collateral_tab(n).numcolla,null,'D',null,to_char(collateral_tab(n).dteeffec,'dd/mm/yyyy'),'N',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'filename','C','numcolla',collateral_tab(n).numcolla,null,'C',null,collateral_tab(n).filename,'N',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'status','C','numcolla',collateral_tab(n).numcolla,null,'C',null,collateral_tab(n).status,'N',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'flgded','C','numcolla',collateral_tab(n).numcolla,null,'C',null,collateral_tab(n).flgded,'N',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'qtyperiod','C','numcolla',collateral_tab(n).numcolla,null,'C',null,collateral_tab(n).qtyperiod,'N',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'amtdedcol','C','numcolla',collateral_tab(n).numcolla,null,'N',null,collateral_tab(n).amtdedcol,'Y',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'dtestrt','C','numcolla',collateral_tab(n).numcolla,null,'D',null,to_char(collateral_tab(n).dtestrt,'dd/mm/yyyy'),'N',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'dteend','C','numcolla',collateral_tab(n).numcolla,null,'D',null,to_char(collateral_tab(n).dteend,'dd/mm/yyyy'),'N',v_upd,'I');
            upd_log2('tcolltrl','42',v_numseq,'amtded','C','numcolla',collateral_tab(n).numcolla,null,'N',null,collateral_tab(n).amtded,'Y',v_upd,'I');

            if v_upd then
              --- insert tappldoc ---
              hrpmc2e.update_filedoc( p_codempid_query,
                                      collateral_tab(n).filename,
                                      GET_LABEL_NAME('HRPMC2E4T2',global_v_lang,10),
                                      '0006',--- type doc collateral
                                      global_v_coduser,
                                      v_numrefdoc);
              -----------------------
              insert into tcolltrl
                (codempid,numcolla,numdocum,
                 typcolla,amtcolla,descoll,dtecolla,dtertdoc,
                 dteeffec,filename,status,flgded,qtyperiod,
                 amtdedcol,dtestrt,dteend,amtded,
                 codcreate,coduser)
              values
                (p_codempid_query,v_numcolla,collateral_tab(n).numdocum,
                 collateral_tab(n).typcolla,collateral_tab(n).amtcolla,collateral_tab(n).descoll,collateral_tab(n).dtecolla,collateral_tab(n).dtertdoc,
                 collateral_tab(n).dteeffec,collateral_tab(n).filename,collateral_tab(n).status,collateral_tab(n).flgded,collateral_tab(n).qtyperiod,
                 collateral_tab(n).amtdedcol,collateral_tab(n).dtestrt,collateral_tab(n).dteend,collateral_tab(n).amtded,
                 global_v_coduser,global_v_coduser);
            end if;
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_collateral
  --
  procedure save_reference is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_numseq      number;
    v_numappl     varchar2(100 char);

    cursor c_tapplref is
      select  numappl,numseq,codempid,codempref,codtitle,
              namrefe,namreft,namref3,namref4,namref5,
              namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
              namlaste,namlastt,namlast3,namlast4,namlast5,
              flgref,despos,adrcont1,desnoffi,numtele,
              email,codoccup,remark,rowid
      from	  tapplref
      where	  numappl = v_numappl
      and		  numseq  = v_numseq;

    v_namrefe        tapplref.namrefe%type;
    v_namreft        tapplref.namrefe%type;
    v_namref3        tapplref.namrefe%type;
    v_namref4        tapplref.namrefe%type;
    v_namref5        tapplref.namrefe%type;
  begin
    v_numseq    := 0;
    v_numappl   := get_numappl(p_codempid_query);

    for n in 1..reference_tab.count loop
--      reference_tab(n).codempref    := check_codempid(reference_tab(n).codempref);
      v_numseq                      := reference_tab(n).numseq;
      if p_flg_del_ref(n) = 'delete' then
--        for i in c_tapplref loop
--          upd_log2('tapplref','43',v_numseq,'codempref','N','numseq',null,null,'C',i.codempref,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'codtitle','N','numseq',null,null,'C',i.codtitle,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namrefe','N','numseq',null,null,'C',i.namrefe,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namreft','N','numseq',null,null,'C',i.namreft,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namref3','N','numseq',null,null,'C',i.namref3,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namref4','N','numseq',null,null,'C',i.namref4,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namref5','N','numseq',null,null,'C',i.namref5,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namfirste','N','numseq',null,null,'C',i.namfirste,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namfirstt','N','numseq',null,null,'C',i.namfirstt,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namfirst3','N','numseq',null,null,'C',i.namfirst3,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namfirst4','N','numseq',null,null,'C',i.namfirst4,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namfirst5','N','numseq',null,null,'C',i.namfirst5,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namlaste','N','numseq',null,null,'C',i.namlaste,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namlastt','N','numseq',null,null,'C',i.namlastt,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namlast3','N','numseq',null,null,'C',i.namlast3,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namlast4','N','numseq',null,null,'C',i.namlast4,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'namlast5','N','numseq',null,null,'C',i.namlast5,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'flgref','N','numseq',null,null,'C',i.flgref,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'despos','N','numseq',null,null,'C',i.despos,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'adrcont1','N','numseq',null,null,'C',i.adrcont1,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'desnoffi','N','numseq',null,null,'C',i.desnoffi,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'numtele','N','numseq',null,null,'C',i.numtele,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'email','N','numseq',null,null,'C',i.email,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'codoccup','N','numseq',null,null,'C',i.codoccup,null,'N',v_upd,'D');
--          upd_log2('tapplref','43',v_numseq,'remark','N','numseq',null,null,'C',i.remark,null,'N',v_upd,'D');
--        end loop;

        delete from tapplref
        where   numappl     = v_numappl
        and     numseq      = v_numseq;
      else
        if reference_tab(n).numseq > 0 then
          v_exist       := false;
          v_upd         := false;

          v_namrefe	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',reference_tab(n).codtitle,'101')))||
                             ltrim(rtrim(reference_tab(n).namfirste))||' '||ltrim(rtrim(reference_tab(n).namlaste)),1,100);
          v_namreft	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',reference_tab(n).codtitle,'102')))||
                             ltrim(rtrim(reference_tab(n).namfirstt))||' '||ltrim(rtrim(reference_tab(n).namlastt)),1,100);
          v_namref3	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',reference_tab(n).codtitle,'103')))||
                             ltrim(rtrim(reference_tab(n).namfirst3))||' '||ltrim(rtrim(reference_tab(n).namlast3)),1,100);
          v_namref4	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',reference_tab(n).codtitle,'104')))||
                             ltrim(rtrim(reference_tab(n).namfirst4))||' '||ltrim(rtrim(reference_tab(n).namlast4)),1,100);
          v_namref5	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',reference_tab(n).codtitle,'105')))||
                             ltrim(rtrim(reference_tab(n).namfirst5))||' '||ltrim(rtrim(reference_tab(n).namlast5)),1,100);

          for i in c_tapplref loop
            v_exist := true;
            upd_log2('tapplref','43',v_numseq,'codempref','N','numseq',null,null,'C',i.codempref,reference_tab(n).codempref,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'codtitle','N','numseq',null,null,'C',i.codtitle,reference_tab(n).codtitle,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namrefe','N','numseq',null,null,'C',i.namrefe,v_namrefe,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namreft','N','numseq',null,null,'C',i.namreft,v_namreft,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namref3','N','numseq',null,null,'C',i.namref3,v_namref3,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namref4','N','numseq',null,null,'C',i.namref4,v_namref4,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namref5','N','numseq',null,null,'C',i.namref5,v_namref5,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namfirste','N','numseq',null,null,'C',i.namfirste,reference_tab(n).namfirste,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namfirstt','N','numseq',null,null,'C',i.namfirstt,reference_tab(n).namfirstt,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namfirst3','N','numseq',null,null,'C',i.namfirst3,reference_tab(n).namfirst3,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namfirst4','N','numseq',null,null,'C',i.namfirst4,reference_tab(n).namfirst4,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namfirst5','N','numseq',null,null,'C',i.namfirst5,reference_tab(n).namfirst5,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namlaste','N','numseq',null,null,'C',i.namlaste,reference_tab(n).namlaste,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namlastt','N','numseq',null,null,'C',i.namlastt,reference_tab(n).namlastt,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namlast3','N','numseq',null,null,'C',i.namlast3,reference_tab(n).namlast3,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namlast4','N','numseq',null,null,'C',i.namlast4,reference_tab(n).namlast4,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'namlast5','N','numseq',null,null,'C',i.namlast5,reference_tab(n).namlast5,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'flgref','N','numseq',null,null,'C',i.flgref,reference_tab(n).flgref,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'despos','N','numseq',null,null,'C',i.despos,reference_tab(n).despos,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'adrcont1','N','numseq',null,null,'C',i.adrcont1,reference_tab(n).adrcont1,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'desnoffi','N','numseq',null,null,'C',i.desnoffi,reference_tab(n).desnoffi,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'numtele','N','numseq',null,null,'C',i.numtele,reference_tab(n).numtele,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'email','N','numseq',null,null,'C',i.email,reference_tab(n).email,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'codoccup','N','numseq',null,null,'C',i.codoccup,reference_tab(n).codoccup,'N',v_upd);
            upd_log2('tapplref','43',v_numseq,'remark','N','numseq',null,null,'C',i.remark,reference_tab(n).remark,'N',v_upd);
            if v_upd then
              update  tapplref
              set     codtitle      = reference_tab(n).codtitle,
                      codempref     = reference_tab(n).codempref,
                      namrefe       = v_namrefe,
                      namreft       = v_namreft,
                      namref3       = v_namref3,
                      namref4       = v_namref4,
                      namref5       = v_namref5,
                      namfirste     = reference_tab(n).namfirste,
                      namfirstt     = reference_tab(n).namfirstt,
                      namfirst3     = reference_tab(n).namfirst3,
                      namfirst4     = reference_tab(n).namfirst4,
                      namfirst5     = reference_tab(n).namfirst5,
                      namlaste      = reference_tab(n).namlaste,
                      namlastt      = reference_tab(n).namlastt,
                      namlast3      = reference_tab(n).namlast3,
                      namlast4      = reference_tab(n).namlast4,
                      namlast5      = reference_tab(n).namlast5,
                      flgref        = reference_tab(n).flgref,
                      despos        = reference_tab(n).despos,
                      adrcont1      = reference_tab(n).adrcont1,
                      desnoffi      = reference_tab(n).desnoffi,
                      numtele       = reference_tab(n).numtele,
                      email         = reference_tab(n).email,
                      codoccup      = reference_tab(n).codoccup,
                      remark        = reference_tab(n).remark,
                      coduser       = global_v_coduser
              where   rowid   = i.rowid;
            end if;
          end loop;
          if not v_exist then
            upd_log2('tapplref','43',v_numseq,'codempref','N','numseq',null,null,'C',null,reference_tab(n).codempref,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'codtitle','N','numseq',null,null,'C',null,reference_tab(n).codtitle,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namrefe','N','numseq',null,null,'C',null,v_namrefe,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namreft','N','numseq',null,null,'C',null,v_namreft,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namref3','N','numseq',null,null,'C',null,v_namref3,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namref4','N','numseq',null,null,'C',null,v_namref4,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namref5','N','numseq',null,null,'C',null,v_namref5,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namfirste','N','numseq',null,null,'C',null,reference_tab(n).namfirste,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namfirstt','N','numseq',null,null,'C',null,reference_tab(n).namfirstt,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namfirst3','N','numseq',null,null,'C',null,reference_tab(n).namfirst3,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namfirst4','N','numseq',null,null,'C',null,reference_tab(n).namfirst4,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namfirst5','N','numseq',null,null,'C',null,reference_tab(n).namfirst5,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namlaste','N','numseq',null,null,'C',null,reference_tab(n).namlaste,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namlastt','N','numseq',null,null,'C',null,reference_tab(n).namlastt,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namlast3','N','numseq',null,null,'C',null,reference_tab(n).namlast3,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namlast4','N','numseq',null,null,'C',null,reference_tab(n).namlast4,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'namlast5','N','numseq',null,null,'C',null,reference_tab(n).namlast5,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'flgref','N','numseq',null,null,'C',null,reference_tab(n).flgref,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'despos','N','numseq',null,null,'C',null,reference_tab(n).despos,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'adrcont1','N','numseq',null,null,'C',null,reference_tab(n).adrcont1,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'desnoffi','N','numseq',null,null,'C',null,reference_tab(n).desnoffi,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'numtele','N','numseq',null,null,'C',null,reference_tab(n).numtele,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'email','N','numseq',null,null,'C',null,reference_tab(n).email,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'codoccup','N','numseq',null,null,'C',null,reference_tab(n).codoccup,'N',v_upd,'I');
            upd_log2('tapplref','43',v_numseq,'remark','N','numseq',null,null,'C',null,reference_tab(n).remark,'N',v_upd,'I');
            if v_upd then
              insert into tapplref( numappl,numseq,codempid,codempref,codtitle,
                                    namrefe,namreft,namref3,namref4,namref5,
                                    namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                                    namlaste,namlastt,namlast3,namlast4,namlast5,
                                    flgref,despos,adrcont1,desnoffi,numtele,
                                    email,codoccup,remark,codcreate,coduser)

                           values ( v_numappl,v_numseq,p_codempid_query,reference_tab(n).codempref,reference_tab(n).codtitle,
                                    v_namrefe,v_namreft,v_namref3,v_namref4,v_namref5,
                                    reference_tab(n).namfirste,reference_tab(n).namfirstt,reference_tab(n).namfirst3,reference_tab(n).namfirst4,reference_tab(n).namfirst5,
                                    reference_tab(n).namlaste,reference_tab(n).namlastt,reference_tab(n).namlast3,reference_tab(n).namlast4,reference_tab(n).namlast5,
                                    reference_tab(n).flgref,reference_tab(n).despos,reference_tab(n).adrcont1,reference_tab(n).desnoffi,reference_tab(n).numtele,
                                    reference_tab(n).email,reference_tab(n).codoccup,reference_tab(n).remark,global_v_coduser,global_v_coduser);
            end if;
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_reference
  --
  procedure check_tab_guarantor(json_str_input in clob) is
    v_str_json      json;
    v_code          varchar2(100);
    v_codoccup      tguarntr.codoccup%type;
  begin
    v_str_json      := json(json_str_input);
    v_codoccup      := hcm_util.get_string(v_str_json,'codoccup');
    if v_codoccup is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodoccu
        where   codcodec = v_codoccup;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODOCCU');
        return;
      end;
    end if;
  end; -- end check_tab_guarantor
  --
  procedure check_tab_collateral(json_str_input in clob) is
    v_str_json      json;
    v_code          varchar2(100);

    v_numcolla      tcolltrl.numcolla%type;
    v_typcolla      tcolltrl.typcolla%type;
    v_qtyperiod     tcolltrl.qtyperiod%type;
  begin
    v_str_json      := json(json_str_input);
    v_typcolla      := hcm_util.get_string(v_str_json,'typcolla');
    v_numcolla      := hcm_util.get_string(v_str_json,'numcolla');
    v_qtyperiod     := hcm_util.get_string(v_str_json,'qtyperiod');
    if v_typcolla is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodcola
        where   codcodec = v_typcolla;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCOLA');
        return;
      end;
    end if;
    --
    begin
      select  distinct 'Y'
      into    v_code
      from    tcolltrl
      where   codempid          = p_codempid_query
      and     numcolla          = v_numcolla
      and     nvl(qtytranpy,0)  > nvl(v_qtyperiod,0);
      param_msg_error := get_error_msg_php('PM0095',global_v_lang);
      return;
    exception when no_data_found then
      null;
    end;
  end; -- end check_tab_collateral
  --
  procedure check_tab_reference(json_str_input in clob) is
    v_str_json      json;
    v_code          varchar2(100);
    v_codoccup       tapplref.codoccup%type;
    v_codempref      tapplref.codempref%type;
    v_codempidQuery  tapplref.codempref%type;
  begin
    v_str_json          := json(json_str_input);
    v_codoccup          := hcm_util.get_string(v_str_json,'codoccup');
    v_codempref         := hcm_util.get_string(v_str_json,'codempref');
    v_codempidQuery     := hcm_util.get_string(v_str_json,'codempidQuery');

    if v_codoccup is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodoccu
        where   codcodec = v_codoccup;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODOCCU');
        return;
      end;
    end if;

    if v_codempref = v_codempidQuery then
        param_msg_error := get_error_msg_php('PM0143',global_v_lang);
        return;
    end if;
  end; -- end check_tab_reference
  --
  procedure get_guarantor_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_guarantor_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_guarantor_table
  --
  procedure gen_guarantor_table(json_str_output out clob) is
    obj_row           json;
    obj_data          json;
    v_rcnt            number := 0;

    cursor c_tguarntr is
      select  codempid,
              codempgrt,
              numseq,dtegucon,codtitle,
              decode(global_v_lang,'101',namguare
                                  ,'102',namguart
                                  ,'103',namguar3
                                  ,'104',namguar4
                                  ,'105',namguar5) as namguar,
              decode(global_v_lang,'101',namfirste
                                  ,'102',namfirstt
                                  ,'103',namfirst3
                                  ,'104',namfirst4
                                  ,'105',namfirst5) as namfirst,
              namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
              decode(global_v_lang,'101',namlaste
                                  ,'102',namlastt
                                  ,'103',namlast3
                                  ,'104',namlast4
                                  ,'105',namlast5) as namlast,
              namlaste,namlastt,namlast3,namlast4,namlast5,
              dteguabd,dteguret,codident,numoffid,dteidexp,
              adrcont,codpost,numtele,codoccup,despos,
              amtmthin,adroffi,codposto,
              numteleo,
              desnote,
              desrelat,email,numfax,amtguarntr
      from    tguarntr
      where   codempid = p_codempid_query
      order by numseq;
  begin
    obj_row    := json();
    for i in c_tguarntr loop

      obj_data    := json();
      v_rcnt      := v_rcnt + 1;

      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('codempgrt',i.codempgrt);
      obj_data.put('numseq',i.numseq);
      obj_data.put('dtegucon',to_char(i.dtegucon,'dd/mm/yyyy'));
      obj_data.put('codtitle',i.codtitle);
      obj_data.put('namguar',i.namguar);
      obj_data.put('namfirst',i.namfirst);
      obj_data.put('namfirste',i.namfirste);
      obj_data.put('namfirstt',i.namfirstt);
      obj_data.put('namfirst3',i.namfirst3);
      obj_data.put('namfirst4',i.namfirst4);
      obj_data.put('namfirst5',i.namfirst5);
      obj_data.put('namlast',i.namlast);
      obj_data.put('namlaste',i.namlaste);
      obj_data.put('namlastt',i.namlastt);
      obj_data.put('namlast3',i.namlast3);
      obj_data.put('namlast4',i.namlast4);
      obj_data.put('namlast5',i.namlast5);
      obj_data.put('dteguabd',to_char(i.dteguabd,'dd/mm/yyyy'));
      obj_data.put('dteguret',to_char(i.dteguret,'dd/mm/yyyy'));
      obj_data.put('codident',i.codident);
      obj_data.put('numoffid',i.numoffid);
      obj_data.put('dteidexp',to_char(i.dteidexp,'dd/mm/yyyy'));
      obj_data.put('adrcont',i.adrcont);
      obj_data.put('codpost',to_char(i.codpost));
      obj_data.put('numtele',i.numtele);
      obj_data.put('codoccup',i.codoccup);
      obj_data.put('despos',i.despos);
      obj_data.put('amtmthin',stddec(i.amtmthin,i.codempid,global_v_chken));
      obj_data.put('adroffi',i.adroffi);
      obj_data.put('codposto',to_char(i.codposto));
      obj_data.put('numteleo',i.numteleo);
      obj_data.put('desnote',i.desnote);
      obj_data.put('desrelat',i.desrelat);
      obj_data.put('email',i.email);
      obj_data.put('numfax',i.numfax);
      obj_data.put('amtguarntr',stddec(i.amtguarntr,i.codempid,global_v_chken));
      obj_row.put(v_rcnt - 1, obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- end gen_guarantor_table
  --
  procedure get_sta_submit_grt(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_tab_guarantor(json_str_input);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_sta_submit_grt
  --
  procedure get_collateral_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_collateral_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_collateral_table
  --
  procedure gen_collateral_table(json_str_output out clob) is
    obj_row           json;
    obj_data          json;
    v_rcnt            number := 0;

    cursor c_tcolltrl is
      select  codempid,numcolla,numdocum,typcolla,amtcolla,
              descoll,dtecolla,dtertdoc,dteeffec,filename,
              status,flgded,qtyperiod,amtdedcol,dtestrt,
              dteend,amtded,staded
      from    tcolltrl
      where   codempid = p_codempid_query
      order by numcolla;
  begin
    obj_row    := json();
    for i in c_tcolltrl loop

      obj_data    := json();
      v_rcnt      := v_rcnt + 1;

      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('numcolla',i.numcolla);
      obj_data.put('numdocum',i.numdocum);
      obj_data.put('typcolla',i.typcolla);
      obj_data.put('desc_typcolla',get_tcodec_name('TCODCOLA',i.typcolla,global_v_lang));
      obj_data.put('amtcolla',to_char(stddec(i.amtcolla,i.codempid,global_v_chken),'fm999,999,999,999,990.00'));
      obj_data.put('descoll',i.descoll);
      obj_data.put('dtecolla',to_char(i.dtecolla,'dd/mm/yyyy'));
      obj_data.put('dtertdoc',to_char(i.dtertdoc,'dd/mm/yyyy'));
      obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_data.put('filename',i.filename);
      obj_data.put('status',i.status);
      obj_data.put('flgded',i.flgded);
      obj_data.put('qtyperiod',i.qtyperiod);
      obj_data.put('amtdedcol',stddec(i.amtdedcol,i.codempid,global_v_chken));
      obj_data.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
      obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
      obj_data.put('amtded',stddec(i.amtded,i.codempid,global_v_chken));
      obj_data.put('staded',i.staded);
      obj_row.put(v_rcnt - 1, obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- end gen_collateral_table
  --
  procedure get_sta_submit_col(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_tab_collateral(json_str_input);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_sta_submit_col
  --
  procedure get_reference_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_reference_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_reference_table
  --
  procedure gen_reference_table(json_str_output out clob) is
    obj_row           json;
    obj_data          json;
    v_rcnt            number := 0;

    v_index_numappl   varchar2(100 char);
    cursor c_tapplref is
      select  numappl,numseq,codempid,codempref,codtitle,
              decode(global_v_lang,'101',namfirste
                                  ,'102',namfirstt
                                  ,'103',namfirst3
                                  ,'104',namfirst4
                                  ,'105',namfirst5) as namfirst,
              namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
              decode(global_v_lang,'101',namlaste
                                  ,'102',namlastt
                                  ,'103',namlast3
                                  ,'104',namlast4
                                  ,'105',namlast5) as namlast,
              namlaste,namlastt,namlast3,namlast4,namlast5,
              decode(global_v_lang,'101',namrefe
                                  ,'102',namreft
                                  ,'103',namref3
                                  ,'104',namref4
                                  ,'105',namref5) as namref,
              flgref,despos,adrcont1,desnoffi,numtele,
              email,codoccup,remark,dteupd,coduser
      from    tapplref
      where   numappl    = v_index_numappl
      order by numseq;
  begin
    obj_row           := json();
    v_index_numappl   := get_numappl(p_codempid_query);

    for i in c_tapplref loop

      obj_data    := json();
      v_rcnt      := v_rcnt + 1;

      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('numappl',i.numappl);
      obj_data.put('numseq',i.numseq);
      obj_data.put('codempref',i.codempref);
      obj_data.put('codtitle',i.codtitle);
      obj_data.put('namfirst',i.namfirst);
      obj_data.put('namfirste',i.namfirste);
      obj_data.put('namfirstt',i.namfirstt);
      obj_data.put('namfirst3',i.namfirst3);
      obj_data.put('namfirst4',i.namfirst4);
      obj_data.put('namfirst5',i.namfirst5);
      obj_data.put('namlast',i.namlast);
      obj_data.put('namlaste',i.namlaste);
      obj_data.put('namlastt',i.namlastt);
      obj_data.put('namlast3',i.namlast3);
      obj_data.put('namlast4',i.namlast4);
      obj_data.put('namlast5',i.namlast5);
      obj_data.put('namref',i.namref);
      obj_data.put('flgref',i.flgref);
      obj_data.put('desc_flgref',get_tlistval_name('FLGREF',i.flgref,global_v_lang));
      obj_data.put('despos',i.despos);
      obj_data.put('adrcont1',i.adrcont1);
      obj_data.put('desnoffi',i.desnoffi);
      obj_data.put('numtele',i.numtele);
      obj_data.put('email',i.email);
      obj_data.put('codoccup',i.codoccup);
      obj_data.put('remark',i.remark);
      obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
      obj_data.put('coduser',i.coduser);
      obj_row.put(v_rcnt - 1, obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- end gen_reference_table
  --
  procedure get_sta_submit_ref(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_tab_reference(json_str_input);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_sta_submit_col
  --
  procedure get_coll_period_popup(json_str_input in clob, json_str_output out clob) is
    v_json        json_object_t := json_object_t(json_str_input);
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number  := 0;
    v_codempid    temploy1.codempid%type;
    v_numcolla    tcolltrl.numcolla%type;
    cursor c1 is
      select  lpad(numperiod,2,'0')||'/'||lpad(dtemthpay,2,'0')||'/'||hcm_util.get_year_buddhist_era(dteyrepay) as dteperiod,
              stddec(amtpay,codempid,global_v_chken) as amtpay
      from    ttguartee
      where   codempid    = v_codempid
      and     numcolla    = v_numcolla
      order by numperiod,dtemthpay,dteyrepay;
  begin
    initial_value(json_str_input);
    v_codempid    := hcm_util.get_string_t(v_json,'p_codempid_query');
    v_numcolla    := hcm_util.get_string_t(v_json,'p_numcolla');
    obj_row       := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('numperiod',to_char(v_rcnt));
      obj_data.put('dteperiod',i.dteperiod);
      obj_data.put('amtpay',to_char(i.amtpay,'fm999,999,999,999,990.00'));
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output   := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_emp_detail(json_str_input in clob, json_str_output out clob) is
    obj_row             json;
    v_codtitle          temploy1.codtitle%type;
    v_namfirst          temploy1.namfirste%type;
    v_namfirste         temploy1.namfirste%type;
    v_namfirstt         temploy1.namfirstt%type;
    v_namfirst3         temploy1.namfirst3%type;
    v_namfirst4         temploy1.namfirst4%type;
    v_namfirst5         temploy1.namfirst5%type;
    v_namlast           temploy1.namlaste%type;
    v_namlaste          temploy1.namlaste%type;
    v_namlastt          temploy1.namlastt%type;
    v_namlast3          temploy1.namlast3%type;
    v_namlast4          temploy1.namlast4%type;
    v_namlast5          temploy1.namlast5%type;
    v_dteempdb          temploy1.dteempdb%type;
    v_numtelec          temploy2.numtelec%type;
    v_adrcont           varchar2(1000);
    v_codpostc          temploy2.codpostc%type;
    v_email             temploy1.email%type;
    v_codpos            tpostn.codpos%type;
    v_desc_codcompy     varchar2(500);
    v_dteretire         date;
    v_numoffid          temploy2.numoffid%type;
  begin
    initial_value(json_str_input);
    begin
      select  codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
              decode(global_v_lang,'101',namfirste
                                  ,'102',namfirstt
                                  ,'103',namfirst3
                                  ,'104',namfirst4
                                  ,'105',namfirst5) as namfirst,
              namlaste,namlastt,namlast3,namlast4,namlast5,
              decode(global_v_lang,'101',namlaste
                                  ,'102',namlastt
                                  ,'103',namlast3
                                  ,'104',namlast4
                                  ,'105',namlast5) as namlast,
              dteempdb,numtelec,
              decode(global_v_lang,'101',adrconte
                                  ,'102',adrcontt
                                  ,'103',adrcont3
                                  ,'104',adrcont4
                                  ,'105',adrcont5)||' '||
                                  get_label_name('HRPMC2EA1S',global_v_lang,'170')||' '||
                                  get_tsubdist_name(emp2.codsubdistc,global_v_lang)||' '||get_label_name('HRPMC2EA1S',global_v_lang,'180')||' '||
                                  get_tcoddist_name(emp2.coddistc,global_v_lang)||' '||get_label_name('HRPMC2EA1S',global_v_lang,'190')||' '||
                                  get_tcodec_name('TCODPROV',emp2.codprovc,global_v_lang)||' '||emp2.codpostc as adrcont,
              emp2.codpostc,emp1.email,
              emp1.codpos,get_tcompny_name(hcm_util.get_codcomp_level(emp1.codcomp,1,''),'102') as desc_codcopmy,
              emp1.dteretire,emp2.numoffid
      into    v_codtitle,v_namfirste,v_namfirstt,v_namfirst3,v_namfirst4,v_namfirst5,v_namfirst,
              v_namlaste,v_namlastt,v_namlast3,v_namlast4,v_namlast5,v_namlast,
              v_dteempdb,v_numtelec,
              v_adrcont,
              v_codpostc,v_email,
              v_codpos,v_desc_codcompy,
              v_dteretire,v_numoffid
      from    temploy1 emp1
              left join tcompny cpn on (get_codcompy(emp1.codcomp) = cpn.codcompy)
              left join temploy2 emp2 on (emp1.codempid = emp2.codempid)
              left join tfamily fam on (emp1.codempid = fam.codempid)
      where   emp1.codempid = p_codempid_query;
    exception when no_data_found then
      null;
    end;
    obj_row   := json();
    obj_row.put('coderror','200');
    obj_row.put('codtitle',v_codtitle);
    obj_row.put('namfirst',v_namfirst);
    obj_row.put('namfirste',v_namfirste);
    obj_row.put('namfirstt',v_namfirstt);
    obj_row.put('namfirst3',v_namfirst3);
    obj_row.put('namfirst4',v_namfirst4);
    obj_row.put('namfirst5',v_namfirst5);
    obj_row.put('namlast',v_namlast);
    obj_row.put('namlaste',v_namlaste);
    obj_row.put('namlastt',v_namlastt);
    obj_row.put('namlast3',v_namlast3);
    obj_row.put('namlast4',v_namlast4);
    obj_row.put('namlast5',v_namlast5);
    obj_row.put('dteempdb',to_char(v_dteempdb,'dd/mm/yyyy'));
    obj_row.put('numtelec',v_numtelec);
    obj_row.put('adrcont',substr(v_adrcont,1,100));
    obj_row.put('codpostc',v_codpostc);
    obj_row.put('email',v_email);
    obj_row.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
    obj_row.put('desc_codcompy',v_desc_codcompy);
    obj_row.put('dteretire',to_char(v_dteretire,'dd/mm/yyyy'));
    obj_row.put('numoffid',v_numoffid);

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- get_emp_detail
  --
  procedure get_popup_change_guarantee(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_popup_change_guarantee(json_str_input,json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_popup_change_guarantee
  --
  procedure gen_popup_change_guarantee(json_str_input in clob, json_str_output out clob) is
    obj_row       json;
    obj_data      json;
    json_obj      json;
    v_rcnt        number  := 0;
    v_numpage     varchar2(100);
    v_dteempmt    date;

    cursor c1 is
      select  '1' typedit,codempid,dteedit,numpage,fldedit,null as typkey,null as fldkey,
              desold,desnew,flgenc,codtable,coduser,null codedit,
              '' as flgdata
      from    ttemlog1
      where   codempid    = p_codempid_query
      and     numpage     = v_numpage

      union

      select  '2' typedit,codempid,dteedit,numpage,fldedit,typkey,fldkey,
              desold,desnew,flgenc,codtable,coduser,
              decode(typkey,'N',to_char(numseq),
                            'C',codseq,
                            'D',to_char(dteseq,'dd/mm/yyyy'),null) as codedit,
              flgdata
      from    ttemlog2
      where   codempid    = p_codempid_query
      and     numpage     = v_numpage

      union

      select  '3' typedit,codempid,dteedit,numpage,typdeduct as fldedit,null as typkey,null as fldkey,
              desold,desnew,'Y' flgenc,codtable,coduser,coddeduct codedit,
              '' as flgdata
      from    ttemlog3
      where   codempid = p_codempid_query
      and     numpage = v_numpage
      order by dteedit desc,codedit;
  begin
    json_obj        := json(json_str_input);
    v_numpage       := hcm_util.get_string(json_obj,'numpage');
    obj_row         := json();

    begin
      select  dteempmt into v_dteempmt
      from    temploy1
      where   codempid  = p_codempid_query;
		exception when no_data_found then
			v_dteempmt  := null;
		end;

    for i in c1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json();
      obj_data.put('coderror','200');
      obj_data.put('typedit',i.typedit);
      obj_data.put('codempid',i.codempid);
      obj_data.put('dteedit',to_char(i.dteedit,'dd/mm/yyyy hh24:mi:ss'));
      obj_data.put('numpage',i.numpage);
      obj_data.put('fldedit',i.fldedit);
      if i.typedit = '3' then
        obj_data.put('data1',get_tlistval_name('TYPEDEDUCT',i.fldedit,global_v_lang));
        obj_data.put('data2',get_tcodeduct_name(i.codedit,global_v_lang));
      else
        if i.fldedit = 'DTEDUEPR' then
          obj_data.put('data1','ctrl_label4.di_v150');
        else
          obj_data.put('data1',get_tcoldesc_name(i.codtable,i.fldedit,global_v_lang));
        end if;
        obj_data.put('data2',i.codedit);
      end if;
      obj_data.put('typkey',i.typkey);
      obj_data.put('fldkey',i.fldkey);
      if i.flgenc = 'Y' then
        if i.desold is not null then
          obj_data.put('desold',to_char(stddec(i.desold,p_codempid_query,global_v_chken),'fm999,999,999,999,990.00'));
        end if;
        if i.desnew is not null then
          obj_data.put('desnew',to_char(stddec(i.desnew,p_codempid_query,global_v_chken),'fm999,999,999,999,990.00'));
        end if;
      else
        if i.fldedit = 'DTEDUEPR' then
          if i.desold is not null then
            obj_data.put('desold',(add_months(to_date(i.desold,'dd/mm/yyyy'),global_v_zyear*12) - v_dteempmt) +1);
          end if;
          if i.desnew is not null then
            obj_data.put('desnew',(add_months(to_date(i.desnew,'dd/mm/yyyy'),global_v_zyear*12) - v_dteempmt) +1);
          end if;
        else
          obj_data.put('desold',get_desciption (i.codtable,i.fldedit,i.desold));
          obj_data.put('desnew',get_desciption (i.codtable,i.fldedit,i.desnew));
        end if;
      end if;
      obj_data.put('flgenc',i.flgenc);
      obj_data.put('codtable',i.codtable);
      obj_data.put('coduser',i.coduser);
      obj_data.put('codedit',i.codedit);
      obj_data.put('exphighli',get_tsetup_value('SET_HIGHLIGHT'));
      obj_data.put('flgdata',i.flgdata);
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- gen_popup_change_guarantee
  --
  procedure save_guarantee(json_str_input in clob, json_str_output out clob) is
    param_json                      json;
    param_json_guarantor            json;
    param_json_collateral             json;
    param_json_reference             json;
  begin
    initial_value(json_str_input);
    param_json                  := json(hcm_util.get_string(json(json_str_input),'json_input_str'));
    param_json_guarantor        := hcm_util.get_json(hcm_util.get_json(param_json,'guarantor'),'rows');
    param_json_collateral       := hcm_util.get_json(hcm_util.get_json(param_json,'collateral'),'rows');
    param_json_reference        := hcm_util.get_json(hcm_util.get_json(param_json,'reference'),'rows');

    initial_tab_guarantor(param_json_guarantor);
    initial_tab_collateral(param_json_collateral);
    initial_tab_reference(param_json_reference);

    if param_msg_error is null then
      save_guarantor;
      save_collateral;
      save_reference;

      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- save_guarantee
  --
end;

/

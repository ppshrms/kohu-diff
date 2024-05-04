--------------------------------------------------------
--  DDL for Package Body HRPMC2E2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMC2E2" is
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
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    param_flgwarn       := hcm_util.get_string_t(json_obj,'flgwarning');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');

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
/*ST11650001
  procedure initial_tab_education(json_education json) is
    json_education_row    json;
    v_numappl             temploy1.numappl%type;
  begin
    v_numappl   := get_numappl(p_codempid_query);
    for i in 0..json_education.count-1 loop
      json_education_row                   := hcm_util.get_json(json_education,to_char(i));
      p_flg_del_edu(i+1)                   := hcm_util.get_string(json_education_row,'flgrow');
      education_tab(i+1).codempid          := hcm_util.get_string(json_education_row,'codempid');
      education_tab(i+1).numappl           := hcm_util.get_string(json_education_row,'numappl');
      education_tab(i+1).numseq            := hcm_util.get_string(json_education_row,'numseq');
      education_tab(i+1).codedlv           := hcm_util.get_string(json_education_row,'codedlv');
      education_tab(i+1).coddglv           := hcm_util.get_string(json_education_row,'coddglv');
      education_tab(i+1).codmajsb          := hcm_util.get_string(json_education_row,'codmajsb');
      education_tab(i+1).codminsb          := hcm_util.get_string(json_education_row,'codminsb');
      education_tab(i+1).codinst           := hcm_util.get_string(json_education_row,'codinst');
      education_tab(i+1).codcount          := hcm_util.get_string(json_education_row,'codcount');
      education_tab(i+1).numgpa            := hcm_util.get_string(json_education_row,'numgpa');
      education_tab(i+1).stayear           := hcm_util.get_string(json_education_row,'stayear');
      education_tab(i+1).dtegyear          := hcm_util.get_string(json_education_row,'dtegyear');
      education_tab(i+1).flgeduc           := hcm_util.get_string(json_education_row,'flgeduc');
    end loop;
  end; -- end initial_tab_education
ST11650001*/
  --
--ST11650001
  procedure initial_tab_education(json_education json_object_t) is
    json_education_row    json_object_t;
    v_numappl             temploy1.numappl%type;
  begin
    v_numappl   := get_numappl(p_codempid_query);
    for i in 0..json_education.get_size-1 loop
      json_education_row                   := hcm_util.get_json_t(json_education,to_char(i));
      p_flg_del_edu(i+1)                   := hcm_util.get_string_t(json_education_row,'flgrow');
      education_tab(i+1).codempid          := hcm_util.get_string_t(json_education_row,'codempid');
      education_tab(i+1).numappl           := hcm_util.get_string_t(json_education_row,'numappl');
      education_tab(i+1).numseq            := hcm_util.get_string_t(json_education_row,'numseq');
      education_tab(i+1).codedlv           := hcm_util.get_string_t(json_education_row,'codedlv');
      education_tab(i+1).coddglv           := hcm_util.get_string_t(json_education_row,'coddglv');
      education_tab(i+1).codmajsb          := hcm_util.get_string_t(json_education_row,'codmajsb');
      education_tab(i+1).codminsb          := hcm_util.get_string_t(json_education_row,'codminsb');
      education_tab(i+1).codinst           := hcm_util.get_string_t(json_education_row,'codinst');
      education_tab(i+1).codcount          := hcm_util.get_string_t(json_education_row,'codcount');
      education_tab(i+1).numgpa            := hcm_util.get_string_t(json_education_row,'numgpa');
      education_tab(i+1).stayear           := hcm_util.get_string_t(json_education_row,'stayear');
      education_tab(i+1).dtegyear          := hcm_util.get_string_t(json_education_row,'dtegyear');
      education_tab(i+1).flgeduc           := hcm_util.get_string_t(json_education_row,'flgeduc');
--      education_tab(i+1).flgmax            := hcm_util.get_string_t(json_education_row,'flgmax');
    end loop;
  end; -- end initial_tab_education
--ST11650001
  --
/*ST11650001
  procedure initial_tab_work_exp(json_work_exp json) is
    json_work_exp_row    json;
    v_numappl            temploy1.numappl%type;
  begin
    v_numappl   := get_numappl(p_codempid_query);
    for i in 0..json_work_exp.count-1 loop
      json_work_exp_row                   := hcm_util.get_json(json_work_exp,to_char(i));
      p_flg_del_work(i+1)                 := hcm_util.get_string(json_work_exp_row,'flgrow');
      work_exp_tab(i+1).numappl           := hcm_util.get_string(json_work_exp_row,'numappl');
      work_exp_tab(i+1).codempid          := hcm_util.get_string(json_work_exp_row,'codempid');
      work_exp_tab(i+1).numseq            := hcm_util.get_string(json_work_exp_row,'numseq');
      work_exp_tab(i+1).desnoffi          := hcm_util.get_string(json_work_exp_row,'desnoffi');
      work_exp_tab(i+1).deslstjob1        := hcm_util.get_string(json_work_exp_row,'deslstjob1');
      work_exp_tab(i+1).deslstpos         := hcm_util.get_string(json_work_exp_row,'deslstpos');
      work_exp_tab(i+1).desoffi1          := hcm_util.get_string(json_work_exp_row,'desoffi1');
      work_exp_tab(i+1).numteleo          := hcm_util.get_string(json_work_exp_row,'numteleo');
      work_exp_tab(i+1).namboss           := hcm_util.get_string(json_work_exp_row,'namboss');
      work_exp_tab(i+1).desres            := hcm_util.get_string(json_work_exp_row,'desres');
--      work_exp_tab(i+1).amtincom          := hcm_util.get_string(json_work_exp_row,'amtincom');
      p_amtincome(i+1)                    := to_number(hcm_util.get_string(json_work_exp_row,'amtincom'));
      work_exp_tab(i+1).dtestart          := to_date(hcm_util.get_string(json_work_exp_row,'dtestart'),'dd/mm/yyyy');
      work_exp_tab(i+1).dteend            := to_date(hcm_util.get_string(json_work_exp_row,'dteend'),'dd/mm/yyyy');
      work_exp_tab(i+1).remark            := hcm_util.get_string(json_work_exp_row,'remark');
      work_exp_tab(i+1).dteupd            := hcm_util.get_string(json_work_exp_row,'dteupd');
      work_exp_tab(i+1).coduser           := hcm_util.get_string(json_work_exp_row,'coduser');
      work_exp_tab(i+1).desjob            := hcm_util.get_string(json_work_exp_row,'desjob');
      work_exp_tab(i+1).desrisk           := hcm_util.get_string(json_work_exp_row,'desrisk');
      work_exp_tab(i+1).desprotc          := hcm_util.get_string(json_work_exp_row,'desprotc');
    end loop;
  end; -- end initial_tab_work_exp
ST11650001*/
--ST11650001
  procedure initial_tab_work_exp(json_work_exp json_object_t) is
    json_work_exp_row    json_object_t;
    v_numappl            temploy1.numappl%type;
  begin
    v_numappl   := get_numappl(p_codempid_query);
    for i in 0..json_work_exp.get_size-1 loop
      json_work_exp_row                   := hcm_util.get_json_t(json_work_exp,to_char(i));
      p_flg_del_work(i+1)                 := hcm_util.get_string_t(json_work_exp_row,'flgrow');
      work_exp_tab(i+1).numappl           := hcm_util.get_string_t(json_work_exp_row,'numappl');
      work_exp_tab(i+1).codempid          := hcm_util.get_string_t(json_work_exp_row,'codempid');
      work_exp_tab(i+1).numseq            := hcm_util.get_string_t(json_work_exp_row,'numseq');
      work_exp_tab(i+1).desnoffi          := hcm_util.get_string_t(json_work_exp_row,'desnoffi');
      work_exp_tab(i+1).deslstjob1        := hcm_util.get_string_t(json_work_exp_row,'deslstjob1');
      work_exp_tab(i+1).deslstpos         := hcm_util.get_string_t(json_work_exp_row,'deslstpos');
      work_exp_tab(i+1).desoffi1          := hcm_util.get_string_t(json_work_exp_row,'desoffi1');
      work_exp_tab(i+1).numteleo          := hcm_util.get_string_t(json_work_exp_row,'numteleo');
      work_exp_tab(i+1).namboss           := hcm_util.get_string_t(json_work_exp_row,'namboss');
      work_exp_tab(i+1).desres            := hcm_util.get_string_t(json_work_exp_row,'desres');
--      work_exp_tab(i+1).amtincom          := hcm_util.get_string_t(json_work_exp_row,'amtincom');
      p_amtincome(i+1)                    := to_number(hcm_util.get_string_t(json_work_exp_row,'amtincom'));
      work_exp_tab(i+1).dtestart          := to_date(hcm_util.get_string_t(json_work_exp_row,'dtestart'),'dd/mm/yyyy');
      work_exp_tab(i+1).dteend            := to_date(hcm_util.get_string_t(json_work_exp_row,'dteend'),'dd/mm/yyyy');
      work_exp_tab(i+1).remark            := hcm_util.get_string_t(json_work_exp_row,'remark');
      work_exp_tab(i+1).dteupd            := hcm_util.get_string_t(json_work_exp_row,'dteupd');
      work_exp_tab(i+1).coduser           := hcm_util.get_string_t(json_work_exp_row,'coduser');
      work_exp_tab(i+1).desjob            := hcm_util.get_string_t(json_work_exp_row,'desjob');
      work_exp_tab(i+1).desrisk           := hcm_util.get_string_t(json_work_exp_row,'desrisk');
      work_exp_tab(i+1).desprotc          := hcm_util.get_string_t(json_work_exp_row,'desprotc');
    end loop;
  end; -- end initial_tab_work_exp
  --
--ST11650001
/*ST11650001
  procedure initial_tab_training(json_training json) is
    json_training_row    json;
    v_numappl             temploy1.numappl%type;
  begin
    v_numappl   := get_numappl(p_codempid_query);
    for i in 0..json_training.count-1 loop
      json_training_row                   := hcm_util.get_json(json_training,to_char(i));
      p_flg_del_trn(i+1)                  := hcm_util.get_string(json_training_row,'flgrow');
      training_tab(i+1).codempid          := hcm_util.get_string(json_training_row,'codempid');
      training_tab(i+1).numappl           := hcm_util.get_string(json_training_row,'numappl');
      training_tab(i+1).numseq            := hcm_util.get_string(json_training_row,'numseq');
      training_tab(i+1).destrain          := hcm_util.get_string(json_training_row,'destrain');
      training_tab(i+1).dtetren           := to_date(hcm_util.get_string(json_training_row,'dtetren'),'dd/mm/yyyy');
      training_tab(i+1).desplace          := hcm_util.get_string(json_training_row,'desplace');
      training_tab(i+1).desinstu          := hcm_util.get_string(json_training_row,'desinstu');
      training_tab(i+1).dtetrain          := to_date(hcm_util.get_string(json_training_row,'dtetrain'),'dd/mm/yyyy');
      training_tab(i+1).filedoc           := hcm_util.get_string(json_training_row,'filedoc');
    end loop;
  end; -- end initial_tab_training
ST11650001*/
--ST11650001
  procedure initial_tab_training(json_training json_object_t) is
    json_training_row    json_object_t;
    v_numappl            temploy1.numappl%type;
  begin
    v_numappl   := get_numappl(p_codempid_query);
    for i in 0..json_training.get_size-1 loop
      json_training_row                   := hcm_util.get_json_t(json_training,to_char(i));
      p_flg_del_trn(i+1)                  := hcm_util.get_string_t(json_training_row,'flgrow');
      training_tab(i+1).codempid          := hcm_util.get_string_t(json_training_row,'codempid');
      training_tab(i+1).numappl           := hcm_util.get_string_t(json_training_row,'numappl');
      training_tab(i+1).numseq            := hcm_util.get_string_t(json_training_row,'numseq');
      training_tab(i+1).destrain          := hcm_util.get_string_t(json_training_row,'destrain');
      training_tab(i+1).dtetren           := to_date(hcm_util.get_string_t(json_training_row,'dtetren'),'dd/mm/yyyy');
      training_tab(i+1).desplace          := hcm_util.get_string_t(json_training_row,'desplace');
      training_tab(i+1).desinstu          := hcm_util.get_string_t(json_training_row,'desinstu');
      training_tab(i+1).dtetrain          := to_date(hcm_util.get_string_t(json_training_row,'dtetrain'),'dd/mm/yyyy');
      training_tab(i+1).filedoc           := hcm_util.get_string_t(json_training_row,'filedoc');
    end loop;
  end; -- end initial_tab_training
--ST11650001
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
        if global_v_zyear = 543   then
          return to_char(add_months(to_date(v_desc,'dd/mm/yyyy'),543*12),'dd/mm/yyyy')	   ;
        else
          return to_char(to_date(v_desc,'dd/mm/yyyy'),'dd/mm/yyyy')	   ;
        end if;
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
                 coduser = global_v_coduser,
                 codcreate = global_v_coduser
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
  procedure save_education is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_numseq      number;
    v_numappl     varchar2(100 char);

    cursor c_teducatn is
      select numappl,numseq,codempid,codedlv,coddglv,codmajsb,
             codminsb,codinst,codcount,numgpa,stayear,dtegyear,flgeduc,
             rowid
      from	 teducatn
      where	 numappl    = v_numappl
      and		 numseq     = v_numseq;
  begin

    v_numseq    := 0;
    v_numappl   := get_numappl(p_codempid_query);

    for n in 1..education_tab.count loop
      v_numseq    := education_tab(n).numseq;
      if p_flg_del_edu(n) = 'delete' then
        delete from teducatn
        where   numappl     = v_numappl
        and     numseq      = v_numseq;
      else
        if education_tab(n).numseq > 0 then
          v_exist     := false;
          v_upd       := false;
          for i in c_teducatn loop
            v_exist := true;
            upd_log2('teducatn','21',v_numseq,'codedlv','N','numseq',null,null,'C',i.codedlv,education_tab(n).codedlv,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'coddglv','N','numseq',null,null,'C',i.coddglv,education_tab(n).coddglv,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'codmajsb','N','numseq',null,null,'C',i.codmajsb,education_tab(n).codmajsb,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'codminsb','N','numseq',null,null,'C',i.codminsb,education_tab(n).codminsb,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'codinst','N','numseq',null,null,'C',i.codinst,education_tab(n).codinst,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'codcount','N','numseq',null,null,'C',i.codcount,education_tab(n).codcount,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'numgpa','N','numseq',null,null,'N',i.numgpa,education_tab(n).numgpa,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'stayear','N','numseq',null,null,'N',i.stayear,(education_tab(n).stayear - global_v_zyear),'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'dtegyear','N','numseq',null,null,'N',i.dtegyear,(education_tab(n).dtegyear - global_v_zyear),'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'flgeduc','N','numseq',null,null,'C',i.flgeduc,education_tab(n).flgeduc,'N',v_upd);

            if v_upd then

              update teducatn
                set	codedlv  = education_tab(n).codedlv,
                    coddglv  = education_tab(n).coddglv,
                    codmajsb = education_tab(n).codmajsb,
                    codminsb = education_tab(n).codminsb,
                    codinst  = education_tab(n).codinst,
                    codcount = education_tab(n).codcount,
                    numgpa   = education_tab(n).numgpa,
                    stayear  = education_tab(n).stayear- global_v_zyear,
                    dtegyear = education_tab(n).dtegyear- global_v_zyear,
                    flgeduc  = education_tab(n).flgeduc,
                    coduser  = global_v_coduser
                where rowid = i.rowid;

              if education_tab(n).flgeduc = '1' then
                update temploy1
                set codedlv  = education_tab(n).codedlv,
                    codmajsb = education_tab(n).codmajsb
                where codempid = p_codempid_query;
              end if;

            end if;
          end loop;

          if not v_exist then
            upd_log2('teducatn','21',v_numseq,'codedlv','N','numseq',null,null,'C',null,education_tab(n).codedlv,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'coddglv','N','numseq',null,null,'C',null,education_tab(n).coddglv,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'codmajsb','N','numseq',null,null,'C',null,education_tab(n).codmajsb,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'codminsb','N','numseq',null,null,'C',null,education_tab(n).codminsb,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'codinst','N','numseq',null,null,'C',null,education_tab(n).codinst,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'codcount','N','numseq',null,null,'C',null,education_tab(n).codcount,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'numgpa','N','numseq',null,null,'N',null,education_tab(n).numgpa,'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'stayear','N','numseq',null,null,'N',null,(education_tab(n).stayear - global_v_zyear),'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'dtegyear','N','numseq',null,null,'N',null,(education_tab(n).dtegyear - global_v_zyear),'N',v_upd);
            upd_log2('teducatn','21',v_numseq,'flgeduc','N','numseq',null,null,'C',null,education_tab(n).flgeduc,'N',v_upd);
            if v_upd then
              insert into teducatn
                (codempid,numappl,numseq,
                 codedlv,coddglv,codmajsb,codminsb,codinst,
                 codcount,numgpa,stayear,dtegyear,flgeduc,
                 codcreate,coduser)
              values
                (p_codempid_query,v_numappl,v_numseq,
                 education_tab(n).codedlv,education_tab(n).coddglv,education_tab(n).codmajsb,education_tab(n).codminsb,education_tab(n).codinst,
                 education_tab(n).codcount,education_tab(n).numgpa,education_tab(n).stayear- global_v_zyear,education_tab(n).dtegyear- global_v_zyear,education_tab(n).flgeduc,
                 global_v_coduser,global_v_coduser);

              if education_tab(n).flgeduc = '1' then
                update  temploy1
                set     codedlv     = education_tab(n).codedlv,
                        codmajsb    = education_tab(n).codmajsb
                where codempid = p_codempid_query;
              end if;
            end if;
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_education
  --
  procedure save_work_exp is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_numseq      number;
    v_numappl     varchar2(100 char);
    v_amtincom    varchar2(20 char);
    cursor c_tapplwex is
      select  numappl,numseq,codempid,desnoffi,deslstjob1,deslstpos,
              desoffi1,numteleo,namboss,desres,amtincom,dtestart,
              dteend,codtypwrk,desjob,desrisk,desprotc,
              remark,rowid
      from	  tapplwex
      where	  numappl = v_numappl
      and		  numseq  = v_numseq;

  begin
    v_numseq    := 0;
    v_numappl   := get_numappl(p_codempid_query);

    for n in 1..work_exp_tab.count loop
      v_numseq      := work_exp_tab(n).numseq;
      if p_flg_del_work(n) = 'delete' then
        delete from tapplwex
        where   numappl     = v_numappl
        and     numseq      = v_numseq;
      else
        if work_exp_tab(n).numseq > 0 then
          v_amtincom    := stdenc(nvl(p_amtincome(n),0),p_codempid_query,global_v_chken);
          v_exist       := false;
          v_upd         := false;
          for i in c_tapplwex loop
            v_exist := true;
            upd_log2('tapplwex','22',v_numseq,'desnoffi','N','numseq',null,null,'C',i.desnoffi,work_exp_tab(n).desnoffi,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'deslstjob1','N','numseq',null,null,'C',i.deslstjob1,work_exp_tab(n).deslstjob1,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'deslstpos','N','numseq',null,null,'C',i.deslstpos,work_exp_tab(n).deslstpos,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'desoffi1','N','numseq',null,null,'C',i.desoffi1,work_exp_tab(n).desoffi1,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'numteleo','N','numseq',null,null,'C',i.numteleo,work_exp_tab(n).numteleo,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'namboss','N','numseq',null,null,'C',i.namboss,work_exp_tab(n).namboss,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'desres','N','numseq',null,null,'C',i.desres,work_exp_tab(n).desres,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'amtincom','N','numseq',null,null,'C',i.amtincom,v_amtincom,'Y',v_upd);
            upd_log2('tapplwex','22',v_numseq,'dtestart','N','numseq',null,null,'D',to_char(i.dtestart,'dd/mm/yyyy'),to_char(work_exp_tab(n).dtestart,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'dteend','N','numseq',null,null,'D',to_char(i.dteend,'dd/mm/yyyy'),to_char(work_exp_tab(n).dteend,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'remark','N','numseq',null,null,'C',i.remark,work_exp_tab(n).remark,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'desjob','N','numseq',null,null,'C',i.desjob,work_exp_tab(n).desjob,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'desrisk','N','numseq',null,null,'C',i.desrisk,work_exp_tab(n).desrisk,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'desprotc','N','numseq',null,null,'C',i.desprotc,work_exp_tab(n).desprotc,'N',v_upd);

            if v_upd then
              update tapplwex
                set	desnoffi 		= work_exp_tab(n).desnoffi,
                    deslstjob1 	= work_exp_tab(n).deslstjob1,
                    deslstpos 	= work_exp_tab(n).deslstpos,
                    desoffi1 		= work_exp_tab(n).desoffi1,
                    numteleo 		= work_exp_tab(n).numteleo,
                    namboss 		= work_exp_tab(n).namboss,
                    desres 			= work_exp_tab(n).desres,
                    amtincom 		= v_amtincom,
                    dtestart 		= work_exp_tab(n).dtestart,
                    dteend 			= work_exp_tab(n).dteend,
                    remark 			= work_exp_tab(n).remark,
                    coduser 		= global_v_coduser,
                    desjob      = work_exp_tab(n).desjob,
                    desrisk   	= work_exp_tab(n).desrisk,
                    desprotc		= work_exp_tab(n).desprotc
                where rowid = i.rowid;
            end if;
          end loop;

          if not v_exist then
            upd_log2('tapplwex','22',v_numseq,'desnoffi','N','numseq',null,null,'C',null,work_exp_tab(n).desnoffi,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'deslstjob1','N','numseq',null,null,'C',null,work_exp_tab(n).deslstjob1,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'deslstpos','N','numseq',null,null,'C',null,work_exp_tab(n).deslstpos,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'desoffi1','N','numseq',null,null,'C',null,work_exp_tab(n).desoffi1,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'numteleo','N','numseq',null,null,'C',null,work_exp_tab(n).numteleo,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'namboss','N','numseq',null,null,'C',null,work_exp_tab(n).namboss,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'desres','N','numseq',null,null,'C',null,work_exp_tab(n).desres,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'amtincom','N','numseq',null,null,'C',null,v_amtincom,'Y',v_upd);
            upd_log2('tapplwex','22',v_numseq,'dtestart','N','numseq',null,null,'D',null,to_char(work_exp_tab(n).dtestart,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'dteend','N','numseq',null,null,'D',null,to_char(work_exp_tab(n).dteend,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'remark','N','numseq',null,null,'C',null,work_exp_tab(n).remark,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'desjob','N','numseq',null,null,'C',null,work_exp_tab(n).desjob,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'desrisk','N','numseq',null,null,'C',null,work_exp_tab(n).desrisk,'N',v_upd);
            upd_log2('tapplwex','22',v_numseq,'desprotc','N','numseq',null,null,'C',null,work_exp_tab(n).desprotc,'N',v_upd);

            if v_upd then
              insert into tapplwex
                (codempid,numappl,numseq,
                 desnoffi,deslstjob1,deslstpos,desoffi1,
                 numteleo,namboss,desres,amtincom,
                 dtestart,dteend,remark,
                 codcreate,coduser,
                 desjob,desrisk,desprotc)
              values
                (p_codempid_query,v_numappl,v_numseq,
                 work_exp_tab(n).desnoffi,work_exp_tab(n).deslstjob1,work_exp_tab(n).deslstpos,work_exp_tab(n).desoffi1,
                 work_exp_tab(n).numteleo,work_exp_tab(n).namboss,work_exp_tab(n).desres,v_amtincom,
                 work_exp_tab(n).dtestart,work_exp_tab(n).dteend,work_exp_tab(n).remark,
                 global_v_coduser,global_v_coduser,
                 work_exp_tab(n).desjob,work_exp_tab(n).desrisk,work_exp_tab(n).desprotc);
            end if;
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_work_exp
  --
  procedure save_training is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_numseq      number;
    v_numappl     varchar2(100 char);
    v_amtincom    varchar2(20 char);
    cursor c_ttrainbf is
      select  numappl,numseq,codempid,destrain,
              dtetrain,dtetren,desplace,desinstu,
              numrefdoc,filedoc,rowid
      from	  ttrainbf
      where	  numappl = v_numappl
      and		  numseq  = v_numseq;
    v_numrefdoc   tappldoc.numrefdoc%type;
  begin
    v_numseq    := 0;
    v_numappl   := get_numappl(p_codempid_query);

    for n in 1..training_tab.count loop
      v_numseq  := training_tab(n).numseq;
      v_numrefdoc   := null;
      if p_flg_del_trn(n) = 'delete' then
        for i in c_ttrainbf loop
          v_numrefdoc   := i.numrefdoc;
          exit;
        end loop;
        hrpmc2e.update_filedoc( p_codempid_query,
                                '',
                                GET_LABEL_NAME('HRPMC2E2T3',global_v_lang,10),
                                '0001',
                                global_v_coduser,
                                v_numrefdoc);
        delete from tappldoc
        where   numappl   = v_numappl
        and     numrefdoc = ( select  numrefdoc
                              from    ttrainbf
                              where   numappl     = v_numappl
                              and     numseq      = v_numseq);

        delete from ttrainbf
        where   numappl     = v_numappl
        and     numseq      = v_numseq;

      else
        if training_tab(n).numseq > 0 then
          v_exist       := false;
          v_upd         := false;
          for i in c_ttrainbf loop
            v_exist       := true;
            v_numrefdoc   := i.numrefdoc;
            upd_log2('ttrainbf','23',v_numseq,'filedoc','N','numseq',null,null,'C',i.filedoc,training_tab(n).filedoc,'N',v_upd);
            upd_log2('ttrainbf','23',v_numseq,'destrain','N','numseq',null,null,'C',i.destrain,training_tab(n).destrain,'N',v_upd);
            upd_log2('ttrainbf','23',v_numseq,'dtetrain','N','numseq',null,null,'D',to_char(i.dtetrain,'dd/mm/yyyy'),to_char(training_tab(n).dtetrain,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('ttrainbf','23',v_numseq,'dtetren','N','numseq',null,null,'D',to_char(i.dtetren,'dd/mm/yyyy'),to_char(training_tab(n).dtetren,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('ttrainbf','23',v_numseq,'desplace','N','numseq',null,null,'C',i.desplace,training_tab(n).desplace,'N',v_upd);
            upd_log2('ttrainbf','23',v_numseq,'desinstu','N','numseq',null,null,'C',i.desinstu,training_tab(n).desinstu,'N',v_upd);
            if nvl(i.filedoc,'#$@') <> nvl(training_tab(n).filedoc,'#$@') then
              hrpmc2e.update_filedoc( p_codempid_query,
                                      training_tab(n).filedoc,
                                      GET_LABEL_NAME('HRPMC2E2T3',global_v_lang,10),
                                      '0001',
                                      global_v_coduser,
                                      v_numrefdoc);
            end if;
            if v_upd then
              update ttrainbf
                set	destrain = training_tab(n).destrain,
                    dtetrain = training_tab(n).dtetrain,
                    dtetren = training_tab(n).dtetren,
                    desplace = training_tab(n).desplace,
                    desinstu = training_tab(n).desinstu,
                    filedoc = training_tab(n).filedoc,
                    numrefdoc = v_numrefdoc,
                    coduser = global_v_coduser
                where rowid = i.rowid;
            end if;
          end loop;
          if not v_exist then
            upd_log2('ttrainbf','23',v_numseq,'filedoc','N','numseq',null,null,'C',null,training_tab(n).filedoc,'N',v_upd);
            upd_log2('ttrainbf','23',v_numseq,'destrain','N','numseq',null,null,'C',null,training_tab(n).destrain,'N',v_upd);
            upd_log2('ttrainbf','23',v_numseq,'dtetrain','N','numseq',null,null,'D',null,to_char(training_tab(n).dtetrain,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('ttrainbf','23',v_numseq,'dtetren','N','numseq',null,null,'D',null,to_char(training_tab(n).dtetren,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('ttrainbf','23',v_numseq,'desplace','N','numseq',null,null,'C',null,training_tab(n).desplace,'N',v_upd);
            upd_log2('ttrainbf','23',v_numseq,'desinstu','N','numseq',null,null,'C',null,training_tab(n).desinstu,'N',v_upd);
            if v_upd then
              ---- insert fildoc ----
              hrpmc2e.update_filedoc( p_codempid_query,
                                      training_tab(n).filedoc,
                                      GET_LABEL_NAME('HRPMC2E2T3',global_v_lang,10),
                                      '0001',
                                      global_v_coduser,
                                      v_numrefdoc);
              ------------------------
              insert into ttrainbf
                (codempid,numappl,numseq,
                 destrain,dtetrain,dtetren,desplace,desinstu,
                 codcreate,coduser,numrefdoc,filedoc)
              values
                (p_codempid_query,v_numappl,v_numseq,
                 training_tab(n).destrain,training_tab(n).dtetrain,training_tab(n).dtetren,training_tab(n).desplace,training_tab(n).desinstu,
                 global_v_coduser,global_v_coduser,v_numrefdoc,training_tab(n).filedoc);
            end if;
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_training
  --
  procedure check_submit_edu(json_str_input in clob) is
    v_str_json      json_object_t;
    v_code          varchar2(100);
    v_codedlv       teducatn.codedlv%type;
    v_coddglv       teducatn.coddglv%type;
    v_codmajsb      teducatn.codmajsb%type;
    v_codminsb      teducatn.codminsb%type;
    v_codinst       teducatn.codinst%type;
    v_codcount      teducatn.codcount%type;
  begin
    v_str_json      := json_object_t(json_str_input);
    v_codedlv       := hcm_util.get_string_t(v_str_json,'codedlv');
    v_coddglv       := hcm_util.get_string_t(v_str_json,'coddglv');
    v_codmajsb      := hcm_util.get_string_t(v_str_json,'codmajsb');
    v_codminsb      := hcm_util.get_string_t(v_str_json,'codminsb');
    v_codinst       := hcm_util.get_string_t(v_str_json,'codinst');
    v_codcount      := hcm_util.get_string_t(v_str_json,'codcount');

    begin
      select  codcodec
      into    v_code
      from    tcodeduc
      where   codcodec = v_codedlv;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEDUC');
      return;
    end;

    begin
      select  codcodec
      into    v_code
      from    tcoddgee
      where   codcodec = v_coddglv;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODDGEE');
      return;
    end;

    if v_codmajsb is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodmajr
        where   codcodec = v_codmajsb;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODMAJR');
        return;
      end;
    end if;

    if v_codminsb is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodsubj
        where   codcodec = v_codminsb;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODSUBJ');
        return;
      end;
    end if;

    if v_codinst is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodinst
        where   codcodec = v_codinst;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODINST');
        return;
      end;
    end if;

    if v_codcount is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodcnty
        where   codcodec = v_codcount;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCNTY');
        return;
      end;
    end if;
  end;
  --
  procedure get_education_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_education_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_education_table
  --
  procedure gen_education_table(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;

    v_index_numappl   varchar2(100 char);

    cursor c_teducatn is
      select  codempid,numappl,numseq,codedlv,coddglv,
              codmajsb,codminsb,codinst,codcount,numgpa,
              stayear,dtegyear,flgeduc,dteupd,coduser
      from    teducatn
      where   numappl = v_index_numappl
      order by numseq;
  begin
    obj_row    := json_object_t();

    v_index_numappl   := get_numappl(p_codempid_query);
    if check_emp_status = 'UPDATE' then
      for i in c_teducatn loop
        obj_data    := json_object_t();
        v_rcnt      := v_rcnt + 1;
        obj_data.put('coderror','200');
        obj_data.put('codempid',i.codempid);
        obj_data.put('numappl',i.numappl);
        obj_data.put('numseq',i.numseq);
        obj_data.put('codedlv',i.codedlv);
        obj_data.put('desc_codedlv',get_tcodec_name('TCODEDUC',i.codedlv,global_v_lang));
        obj_data.put('coddglv',i.coddglv);
        obj_data.put('desc_coddglv',get_tcodec_name('TCODDGEE',i.coddglv,global_v_lang));
        obj_data.put('codmajsb',i.codmajsb);
        obj_data.put('desc_codmajsb',get_tcodec_name('TCODMAJR',i.codmajsb,global_v_lang));
        obj_data.put('codminsb',i.codminsb);
        obj_data.put('desc_codminsb',get_tcodec_name('TCODSUBJ',i.codminsb,global_v_lang));
        obj_data.put('codinst',i.codinst);
        obj_data.put('desc_codinst',get_tcodec_name('TCODINST',i.codinst,global_v_lang));
        obj_data.put('codcount',i.codcount);
        obj_data.put('desc_codcount',get_tcodec_name('TCODCNTY',i.codcount,global_v_lang));
        obj_data.put('numgpa',i.numgpa);
        obj_data.put('stayear',i.stayear);
        obj_data.put('dtegyear',i.dtegyear);
        obj_data.put('flgeduc',i.flgeduc);
        obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
        obj_data.put('coduser',i.coduser);
        obj_row.put(v_rcnt - 1, obj_data);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end; -- end gen_education_table
  --
  procedure get_work_exp_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_work_exp_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_work_exp_table
  --
  procedure gen_work_exp_table(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;

    v_index_numappl   varchar2(100 char);
    cursor c_tapplwex is
      select  numappl,codempid,numseq,desnoffi,deslstjob1,deslstpos,
              desoffi1,numteleo,namboss,desres,amtincom,
              dtestart,dteend,remark,dteupd,coduser,
              desjob,desrisk,desprotc
      from    tapplwex
      where   numappl = v_index_numappl
      order by numseq;
  begin
    obj_row    := json_object_t();

    v_index_numappl   := get_numappl(p_codempid_query);

    if check_emp_status = 'UPDATE' then
      for i in c_tapplwex loop
        obj_data    := json_object_t();
        v_rcnt      := v_rcnt + 1;
        obj_data.put('coderror','200');
        obj_data.put('numappl',i.numappl);
        obj_data.put('codempid',i.codempid);
        obj_data.put('numseq',i.numseq);
        obj_data.put('desnoffi',i.desnoffi);
        obj_data.put('deslstjob1',i.deslstjob1);
        obj_data.put('deslstpos',i.deslstpos);
        obj_data.put('desoffi1',i.desoffi1);
        obj_data.put('numteleo',i.numteleo);
        obj_data.put('namboss',i.namboss);
        obj_data.put('desres',i.desres);
        obj_data.put('amtincom',stddec(i.amtincom,p_codempid_query,global_v_chken));
        obj_data.put('dtestart',to_char(i.dtestart,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
        obj_data.put('remark',i.remark);
        obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
        obj_data.put('coduser',i.coduser);
        obj_data.put('desjob',i.desjob);
        obj_data.put('desrisk',i.desrisk);
        obj_data.put('desprotc',i.desprotc);
        obj_row.put(v_rcnt - 1, obj_data);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end; -- end gen_work_exp_table
  --
  procedure get_training_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_training_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_training_table
  --
  procedure gen_training_table(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;

    v_index_numappl   varchar2(100 char);
    cursor c_ttrainbf is
      select  codempid,numappl,numseq,destrain,dtetren,
              desplace,desinstu,dtetrain,dteupd,coduser,
              filedoc
      from    ttrainbf
      where   numappl   = v_index_numappl
      order by numseq;
  begin
    obj_row    := json_object_t();

    v_index_numappl   := get_numappl(p_codempid_query);

    if check_emp_status = 'UPDATE' then
      for i in c_ttrainbf loop
        obj_data    := json_object_t();
        v_rcnt      := v_rcnt + 1;
        obj_data.put('coderror','200');
        obj_data.put('codempid',i.codempid);
        obj_data.put('numappl',i.numappl);
        obj_data.put('numseq',i.numseq);
        obj_data.put('destrain',i.destrain);
        obj_data.put('dtetren',to_char(i.dtetren,'dd/mm/yyyy'));
        obj_data.put('desplace',i.desplace);
        obj_data.put('desinstu',i.desinstu);
        obj_data.put('dtetrain',to_char(i.dtetrain,'dd/mm/yyyy'));
        obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
        obj_data.put('coduser',i.coduser);
        obj_data.put('filedoc',i.filedoc);
        obj_row.put(v_rcnt - 1, obj_data);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end; -- end gen_training_table
  --
  procedure get_internal_training_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_internal_training_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_internal_training
  --
  function get_format_hour(p_hour varchar2) return varchar2 is
    v_return    varchar2(100);
  begin
    if instr(p_hour,'.') > 0 then
      v_return    := substr(p_hour,1,instr(p_hour,'.') - 1)||':'||rpad(substr(p_hour,instr(p_hour,'.') + 1),2,'0');
    else
      v_return    := p_hour||':'||'00';
    end if;
    return v_return;
  end;
  --
  procedure gen_internal_training_table(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;

    v_index_numappl   varchar2(100 char);
    cursor c_thistrnn is
      select  distinct codempid,codcours,codtparg,dtetrst,dtetren,amtcost,qtytrmin
      from    thistrnn
      where   codempid  = p_codempid_query
      order by dtetrst;
  begin
    obj_row    := json_object_t();

    for i in c_thistrnn loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('codcours',i.codcours);
      obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
      obj_data.put('codtparg',i.codtparg);
      obj_data.put('codtparg',get_tlistval_name('TCODTPARG',i.codtparg,global_v_lang));
      obj_data.put('dtetrst',to_char(i.dtetrst,'dd/mm/yyyy'));
      obj_data.put('dtetren',to_char(i.dtetren,'dd/mm/yyyy'));
      obj_data.put('amttrexp',to_char(i.amtcost,'999,999,999,990.00'));
      obj_data.put('qtytrhur',get_format_hour(i.qtytrmin));
      obj_row.put(v_rcnt - 1, obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end; -- gen_internal_training_table
  --
  procedure get_popup_change_edu_work(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_popup_change_edu_work(json_str_input,json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end gen_education_table
  --
  procedure gen_popup_change_edu_work(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;
    json_obj      json_object_t;
    v_rcnt        number  := 0;
    v_numpage     varchar2(100);
    v_dteempmt    date;

    cursor c1 is
      select  '1' typedit,codempid,dteedit,numpage,fldedit,null as typkey,null as fldkey,
              desold,desnew,flgenc,codtable,coduser,null codedit
      from    ttemlog1
      where   codempid    = p_codempid_query
      and     numpage     = v_numpage

      union

      select  '2' typedit,codempid,dteedit,numpage,fldedit,typkey,fldkey,
              desold,desnew,flgenc,codtable,coduser,
              decode(typkey,'N',to_char(numseq),
                            'C',codseq,
                            'D',to_char(dteseq,'dd/mm/yyyy'),null) as codedit
      from    ttemlog2
      where   codempid    = p_codempid_query
      and     numpage     = v_numpage

      union

      select  '3' typedit,codempid,dteedit,numpage,typdeduct as fldedit,null as typkey,null as fldkey,
              desold,desnew,'Y' flgenc,codtable,coduser,coddeduct codedit
      from    ttemlog3
      where   codempid = p_codempid_query
      and     numpage = v_numpage
      order by dteedit desc,codedit;
  begin
    json_obj        := json_object_t(json_str_input);
    v_numpage       := hcm_util.get_string_t(json_obj,'numpage');
    obj_row         := json_object_t();

    begin
      select  dteempmt into v_dteempmt
      from    temploy1
      where   codempid  = p_codempid_query;
		exception when no_data_found then
			v_dteempmt  := null;
		end;

    for i in c1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
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
        obj_data.put('desold',to_char(stddec(i.desold,p_codempid_query,global_v_chken),'999,999,990.00'));
        obj_data.put('desnew',to_char(stddec(i.desnew,p_codempid_query,global_v_chken),'999,999,990.00'));
      else
        if i.fldedit = 'DTEDUEPR' then
          if i.desold is not null then
            obj_data.put('desold',(add_months(to_date(i.desold,'dd/mm/yyyy'),global_v_zyear*12) - v_dteempmt) +1);
          end if;
          if i.desnew is not null then
            obj_data.put('desnew',(add_months(to_date(i.desnew,'dd/mm/yyyy'),global_v_zyear*12) - v_dteempmt) +1);
          end if;
        elsif i.fldedit in ('STAYEAR','DTEGYEAR') then
          obj_data.put('desold',hcm_util.get_year_buddhist_era(to_date(i.desold,'yyyy')));
          obj_data.put('desnew',hcm_util.get_year_buddhist_era(to_date(i.desnew,'yyyy')));
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
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end; -- gen_popup_change_edu_work
  --
  procedure get_sta_submit_edu(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_submit_edu(json_str_input);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_sta_submit_edu
  --
/* ST11650001
  procedure save_edu_work(json_str_input in clob, json_str_output out clob) is
    param_json                      json;
    param_json_education            json;
    param_json_work_exp             json;
    param_json_training             json;
  begin
    initial_value(json_str_input);
    param_json                  := json(hcm_util.get_string(json(json_str_input),'json_input_str'));
    param_json_education        := hcm_util.get_json(hcm_util.get_json(param_json,'education'),'rows');
    param_json_work_exp         := hcm_util.get_json(hcm_util.get_json(param_json,'work_exp'),'rows');
    param_json_training         := hcm_util.get_json(hcm_util.get_json(param_json,'training'),'rows');

    initial_tab_education(param_json_education);
    initial_tab_work_exp(param_json_work_exp);
    initial_tab_training(param_json_training);

    if param_msg_error is null then
      save_education;
      save_work_exp;
      save_training;

      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- save_edu_work
ST11650001 */
--ST11650001
  procedure save_edu_work(json_str_input in clob, json_str_output out clob) is
    param_json                      json_object_t;
    param_json_education            json_object_t;
    param_json_work_exp             json_object_t;
    param_json_training             json_object_t;
  begin
    initial_value(json_str_input);
    --ST11650001    param_json                  := json(hcm_util.get_string(json(json_str_input),'json_input_str'));
    param_json                  := json_object_t(hcm_util.get_clob_t(json_object_t(json_str_input),'json_input_str'));
    --ST11650001
    param_json_education        := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'education'),'rows');
    param_json_work_exp         := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'work_exp'),'rows');
    param_json_training         := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'training'),'rows');
    initial_tab_education(param_json_education);
    initial_tab_work_exp(param_json_work_exp);
    initial_tab_training(param_json_training);

    if param_msg_error is null then
      save_education;
      save_work_exp;
      save_training;

      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- save_edu_work
--ST11650001
  --
end;

/

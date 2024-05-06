--------------------------------------------------------
--  DDL for Package Body HRPMC2E5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMC2E5" is
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
  procedure initial_tab_competency(json_competency json) is
    json_competency_row    json;
  begin
    for i in 0..json_competency.count-1 loop
      json_competency_row                  := hcm_util.get_json(json_competency,to_char(i));
      p_flg_del_cmp(i+1)                   := hcm_util.get_string(json_competency_row,'flg');
      competency_tab(i+1).codtency         := hcm_util.get_string(json_competency_row,'codtency');
--      competency_tab(i+1).codskill         := hcm_util.get_string(json_competency_row,'codskill');
      competency_tab(i+1).grade            := hcm_util.get_string(json_competency_row,'grade');
    end loop;
  end; -- end initial_tab_competency
  --
  procedure initial_tab_langabi(json_langabi json) is
    json_langabi_row    json;
  begin
    for i in 0..json_langabi.count-1 loop
      json_langabi_row                := hcm_util.get_json(json_langabi,to_char(i));
      p_flg_del_lng(i+1)              := hcm_util.get_string(json_langabi_row,'flg');
      langabi_tab(i+1).codlang        := hcm_util.get_string(json_langabi_row,'codlang');
      langabi_tab(i+1).flglist        := hcm_util.get_string(json_langabi_row,'flglist');
      langabi_tab(i+1).flgspeak       := hcm_util.get_string(json_langabi_row,'flgspeak');
      langabi_tab(i+1).flgread        := hcm_util.get_string(json_langabi_row,'flgread');
      langabi_tab(i+1).flgwrite       := hcm_util.get_string(json_langabi_row,'flgwrite');
    end loop;
  end; -- end initial_tab_langabi
  --
  procedure initial_tab_hisreward(json_hisreward json) is
    json_hisreward_row    json;
  begin
    for i in 0..json_hisreward.count-1 loop
      json_hisreward_row                 := hcm_util.get_json(json_hisreward,to_char(i));
      p_flg_del_rew(i+1)                 := hcm_util.get_string(json_hisreward_row,'flg');
      hisreward_tab(i+1).dteinput        := to_date(hcm_util.get_string(json_hisreward_row,'dteinput'),'dd/mm/yyyy');
      hisreward_tab(i+1).typrewd         := hcm_util.get_string(json_hisreward_row,'typrewd');
      hisreward_tab(i+1).desrewd1        := hcm_util.get_string(json_hisreward_row,'desrewd1');
      hisreward_tab(i+1).numhmref        := hcm_util.get_string(json_hisreward_row,'numhmref');
      hisreward_tab(i+1).filename        := hcm_util.get_string(json_hisreward_row,'filename');
    end loop;
  end; -- end initial_tab_hisreward
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
     p_upd	in out boolean) is
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
                 coduser = global_v_coduser,
                 codcreate = global_v_coduser
          where  rowid = r_ttemlog2.rowid;
        end loop;
        if not v_exist then
          insert into  ttemlog2
            (codempid,dteedit,numpage,numseq,fldedit,codcomp,
             typkey,fldkey,codseq,dteseq,
             desold,desnew,flgenc,codtable,codcreate,coduser)
          values
            (p_codempid_query,sysdate,p_numpage,p_numseq,upper(p_fldedit),work_codcomp,
             p_typkey,p_fldkey,p_codseq,p_dteseq,
             v_desold,v_desnew,p_flgenc,upper(p_codtable),global_v_coduser,global_v_coduser);
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
  procedure save_competency is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_numseq      number;
    v_numappl     varchar2(100 char);
    v_codtency    tcmptncy.codtency%type;

    cursor c_tcmptncy is
      select  numappl,codempid,codtency,grade,rowid
      from    tcmptncy
      where   numappl     = v_numappl
      and     codtency    = v_codtency;
  begin
    v_numseq      := 0;
    v_numappl     := get_numappl(p_codempid_query);
    for n in 1..competency_tab.count loop
      v_numseq      := v_numseq + 1;
      v_codtency    := competency_tab(n).codtency;
      if p_flg_del_cmp(n) = 'delete' then
        delete from tcmptncy
        where   numappl     = v_numappl
        and     codtency    = v_codtency;
      else
        if v_codtency is not null then
          v_exist       := false;
          v_upd         := false;
          for i in c_tcmptncy loop
            v_exist := true;
            upd_log2('tcmptncy','51',v_numseq,'codtency','C','codtency',competency_tab(n).codtency,null,'C',i.codtency,competency_tab(n).codtency,'N',v_upd);
            upd_log2('tcmptncy','51',v_numseq,'grade','C','codtency',competency_tab(n).codtency,null,'C',i.grade,competency_tab(n).grade,'N',v_upd);
            if v_upd then
              update tcmptncy
                 set codtency       = competency_tab(n).codtency,
                     grade          = competency_tab(n).grade,
                     coduser        = global_v_coduser
               where rowid = i.rowid;
            end if;
          end loop;

          if not v_exist then
              upd_log2('tcmptncy','51',v_numseq,'codtency','C','codtency',competency_tab(n).codtency,null,'C',null,competency_tab(n).codtency,'N',v_upd);
              upd_log2('tcmptncy','51',v_numseq,'grade','C','codtency',competency_tab(n).codtency,null,'C',null,competency_tab(n).grade,'N',v_upd);

            if v_upd then
              begin
                insert into tcmptncy
                  ( numappl,codempid,codtency,grade,
                    codcreate,coduser)
                values
                  ( v_numappl,p_codempid_query,competency_tab(n).codtency,competency_tab(n).grade,
                    global_v_coduser,global_v_coduser);
              exception when dup_val_on_index then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang);
                return;
              end;
            end if;
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_competency
  --
  procedure save_langabi is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_numseq      number;
    v_numappl     varchar2(100 char);
    v_codlang     tlangabi.codlang%type;

    cursor c_tlangabi is
      select  codlang,flglist,flgspeak,flgread,flgwrite,rowid
      from	  tlangabi
      where	  numappl     = v_numappl
      and		  codlang     = v_codlang;

  begin
    v_numseq      := 0;
    v_numappl     := get_numappl(p_codempid_query);
    for n in 1..langabi_tab.count loop
      v_numseq      := v_numseq + 1;
      v_codlang     := langabi_tab(n).codlang;
      if p_flg_del_lng(n) = 'delete' then
        delete from tlangabi
        where	  numappl     = v_numappl
        and		  codlang     = v_codlang;
      else
        if langabi_tab(n).codlang is not null then
          v_exist       := false;
          v_upd         := false;
          for i in c_tlangabi loop
            v_exist       := true;
            upd_log2('tlangabi','52',v_numseq,'codlang','C','codlang',langabi_tab(n).codlang,null,'C',i.codlang,langabi_tab(n).codlang,'N',v_upd);
            upd_log2('tlangabi','52',v_numseq,'flglist','C','codlang',langabi_tab(n).codlang,null,'C',i.flglist,langabi_tab(n).flglist,'N',v_upd);
            upd_log2('tlangabi','52',v_numseq,'flgspeak','C','codlang',langabi_tab(n).codlang,null,'C',i.flgspeak,langabi_tab(n).flgspeak,'N',v_upd);
            upd_log2('tlangabi','52',v_numseq,'flgread','C','codlang',langabi_tab(n).codlang,null,'C',i.flgread,langabi_tab(n).flgread,'N',v_upd);
            upd_log2('tlangabi','52',v_numseq,'flgwrite','C','codlang',langabi_tab(n).codlang,null,'C',i.flgwrite,langabi_tab(n).flgwrite,'N',v_upd);
            if v_upd then
              update tlangabi
                 set codlang         = langabi_tab(n).codlang,
                     flglist         = langabi_tab(n).flglist,
                     flgspeak        = langabi_tab(n).flgspeak,
                     flgread         = langabi_tab(n).flgread,
                     flgwrite        = langabi_tab(n).flgwrite,
                     coduser         = global_v_coduser
               where rowid = i.rowid;
            end if;
          end loop;

          if not v_exist then
            upd_log2('tlangabi','52',v_numseq,'codlang','C','codlang',langabi_tab(n).codlang,null,'C',null,langabi_tab(n).codlang,'N',v_upd);
            upd_log2('tlangabi','52',v_numseq,'flglist','C','codlang',langabi_tab(n).codlang,null,'C',null,langabi_tab(n).flglist,'N',v_upd);
            upd_log2('tlangabi','52',v_numseq,'flgspeak','C','codlang',langabi_tab(n).codlang,null,'C',null,langabi_tab(n).flgspeak,'N',v_upd);
            upd_log2('tlangabi','52',v_numseq,'flgread','C','codlang',langabi_tab(n).codlang,null,'C',null,langabi_tab(n).flgread,'N',v_upd);
            upd_log2('tlangabi','52',v_numseq,'flgwrite','C','codlang',langabi_tab(n).codlang,null,'C',null,langabi_tab(n).flgwrite,'N',v_upd);

            if v_upd then
              insert into tlangabi
                (numappl,codempid,codlang,
                 flglist,flgspeak,flgread,flgwrite,
                 codcreate,coduser)
              values
                (v_numappl,p_codempid_query,langabi_tab(n).codlang,
                 langabi_tab(n).flglist,langabi_tab(n).flgspeak,langabi_tab(n).flgread,langabi_tab(n).flgwrite,
                 global_v_coduser,global_v_coduser);
            end if;
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_langabi
  --
  procedure save_hisreward is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_numseq      number;
    v_dteinput    date;
    v_numrefdoc   tappldoc.numrefdoc%type;

    cursor c_thisrewd is
      select  dteinput,typrewd,desrewd1,numhmref,
              filename,numrefdoc,rowid
      from	  thisrewd
      where	  codempid    = p_codempid_query
      and		  dteinput    = v_dteinput;
  begin
    v_numseq    := 0;

    for n in 1..hisreward_tab.count loop
      v_dteinput    := hisreward_tab(n).dteinput;
      v_numseq      := v_numseq + 1;
      v_numrefdoc   := null;
      if p_flg_del_rew(n) = 'delete' then
        for i in c_thisrewd loop
          v_numrefdoc := i.numrefdoc;
          exit;
        end loop;
        hrpmc2e.update_filedoc( p_codempid_query,
                                '',
                                GET_LABEL_NAME('HRPMC2E5T3',global_v_lang,10),
                                '0007',
                                global_v_coduser,
                                v_numrefdoc);
        delete from thisrewd
        where   codempid      = p_codempid_query
        and     dteinput      = v_dteinput;
      else
        if v_dteinput is not null then
          v_exist       := false;
          v_upd         := false;
          for i in c_thisrewd loop
            v_exist       := true;
            v_numrefdoc   := i.numrefdoc;
            upd_log2('thisrewd','53',v_numseq,'dteinput','D','dteinput',null,v_dteinput,'D',to_char(i.dteinput,'dd/mm/yyyy'),to_char(hisreward_tab(n).dteinput,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('thisrewd','53',v_numseq,'typrewd','D','dteinput',null,v_dteinput,'C',i.typrewd,hisreward_tab(n).typrewd,'N',v_upd);
            upd_log2('thisrewd','53',v_numseq,'desrewd1','D','dteinput',null,v_dteinput,'C',i.desrewd1,hisreward_tab(n).desrewd1,'N',v_upd);
            upd_log2('thisrewd','53',v_numseq,'numhmref','D','dteinput',null,v_dteinput,'C',i.numhmref,hisreward_tab(n).numhmref,'N',v_upd);
            upd_log2('thisrewd','53',v_numseq,'filename','D','dteinput',null,v_dteinput,'C',i.filename,hisreward_tab(n).filename,'N',v_upd);
            ---- update filedoc ----
            if nvl(i.filename,'#$@') <> nvl(hisreward_tab(n).filename,'#$@') then
              hrpmc2e.update_filedoc( p_codempid_query,
                                      hisreward_tab(n).filename,
                                      GET_LABEL_NAME('HRPMC2E5T3',global_v_lang,10),
                                      '0007',
                                      global_v_coduser,
                                      v_numrefdoc);
            end if;
            ------------------------
            if v_upd then
              update  thisrewd
              set     dteinput      = hisreward_tab(n).dteinput,
                      typrewd       = hisreward_tab(n).typrewd,
                      desrewd1      = hisreward_tab(n).desrewd1,
                      numhmref      = hisreward_tab(n).numhmref,
                      filename      = hisreward_tab(n).filename,
                      numrefdoc     = v_numrefdoc,
                      coduser       = global_v_coduser
              where   rowid         = i.rowid;
            end if;
          end loop;
          if not v_exist then
            upd_log2('thisrewd','53',v_numseq,'dteinput','D','dteinput',null,v_dteinput,'D',null,to_char(hisreward_tab(n).dteinput,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('thisrewd','53',v_numseq,'typrewd','D','dteinput',null,v_dteinput,'C',null,hisreward_tab(n).typrewd,'N',v_upd);
            upd_log2('thisrewd','53',v_numseq,'desrewd1','D','dteinput',null,v_dteinput,'C',null,hisreward_tab(n).desrewd1,'N',v_upd);
            upd_log2('thisrewd','53',v_numseq,'numhmref','D','dteinput',null,v_dteinput,'C',null,hisreward_tab(n).numhmref,'N',v_upd);
            upd_log2('thisrewd','53',v_numseq,'filename','D','dteinput',null,v_dteinput,'C',null,hisreward_tab(n).filename,'N',v_upd);
            ---- insert filedoc ----
            hrpmc2e.update_filedoc( p_codempid_query,
                                    hisreward_tab(n).filename,
                                    GET_LABEL_NAME('HRPMC2E5T3',global_v_lang,10),
                                    '0007',
                                    global_v_coduser,
                                    v_numrefdoc);
            ------------------------
            if v_upd then
              insert into thisrewd( codempid,dteinput,
                                    typrewd,desrewd1,numhmref,filename,
                                    numrefdoc,codcreate,coduser)

                           values ( p_codempid_query,v_dteinput,
                                    hisreward_tab(n).typrewd,hisreward_tab(n).desrewd1,hisreward_tab(n).numhmref,hisreward_tab(n).filename,
                                    v_numrefdoc,global_v_coduser,global_v_coduser);
            end if;
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_hisreward
  --
  procedure check_tab_competency is
    v_code          varchar2(100);
  begin
    for n in 1..competency_tab.count loop
      begin
        select  codcodec
        into    v_code
        from    tcodskil
        where   codcodec  = competency_tab(n).codtency;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODSKIL');
        return;
      end;

      begin
        select codskill
          into v_code
          from tskilscor
         where codskill  = competency_tab(n).codtency
           and grade     = competency_tab(n).grade;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TSKILSCOR');
        return;
      end;
    end loop;
  end; -- end check_tab_competency
  --
  procedure check_tab_langabi is
    v_code          varchar2(100);
  begin
    for n in 1..langabi_tab.count loop
      begin
        select  codcodec
        into    v_code
        from    tcodlang
        where   codcodec  = langabi_tab(n).codlang;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODLANG');
        return;
      end;
    end loop;
  end; -- end check_tab_langabi
  --
  procedure check_tab_hisreward(json_str_input in clob) is
    v_str_json      json;
    v_code          varchar2(100);
    v_typrewd       thisrewd.typrewd%type;
  begin
    v_str_json      := json(json_str_input);
    v_typrewd       := hcm_util.get_string(v_str_json,'typrewd');
    begin
      select  codcodec
      into    v_code
      from    tcodrewd
      where   codcodec = v_typrewd;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODREWD');
      return;
    end;
  end; -- end check_tab_hisreward
  --
  procedure get_competency_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_competency_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_competency_table
  --
  procedure gen_competency_table(json_str_output out clob) is
    obj_row           json;
    obj_data          json;
    v_rcnt            number := 0;
    v_index_numappl   varchar2(100 char);
    v_desc_typtency   tcomptnc.namtncye%type;

    cursor c_tcmptncy is
      select  emp.numappl,jd.codtency as typtency,jd.codskill,cpt.grade,'JD' as typjd
      from    temploy1 emp, tjobposskil jd, tcmptncy cpt
      where   emp.codempid    = p_codempid_query
      and     emp.codcomp     = jd.codcomp
      and     emp.codpos      = jd.codpos
      and     emp.numappl     = cpt.numappl(+)
      and     jd.codskill     = cpt.codtency(+)
      union all
      select  emp.numappl,nvl(skl.codtency,'N/A') as typtency,cpt.codtency,cpt.grade,'NA' as typjd
      from    temploy1 emp, tcmptncy cpt, tcompskil skl
      where   emp.codempid    = p_codempid_query
      and     emp.numappl     = cpt.numappl
      and     cpt.codtency    = skl.codskill(+)
      and     not exists (select  1
                          from    tjobposskil jd
                          where   jd.codpos     = emp.codpos
                          and     jd.codcomp    = emp.codcomp
                          and     jd.codskill   = cpt.codtency)
      order by typjd,typtency;
  begin
    obj_row           := json();

    for i in c_tcmptncy loop
      obj_data    := json();
      v_rcnt      := v_rcnt + 1;

      obj_data.put('coderror','200');
      obj_data.put('numappl',i.numappl);
      obj_data.put('typtency',i.typtency);
      if i.typtency is null then
        v_desc_typtency   := null;
      elsif i.typtency = 'N/A' then
        v_desc_typtency   := i.typtency;
      else
        v_desc_typtency   := get_tcomptnc_name(i.typtency,global_v_lang);
      end if;
      obj_data.put('desc_typtency',v_desc_typtency);
      obj_data.put('codtency',i.codskill);
      obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',i.codskill,global_v_lang));
      obj_data.put('grade',i.grade);
      obj_data.put('typjd',i.typjd);
      obj_row.put(v_rcnt - 1, obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- end gen_competency_table
  --
  procedure get_langabi_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_langabi_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_langabi_table
  --
  procedure gen_langabi_table(json_str_output out clob) is
    obj_row           json;
    obj_data          json;
    v_rcnt            number := 0;
    v_index_numappl   varchar2(100 char);

    cursor c_tlangabi is
      select  numappl,codlang,codempid,
              flglist,flgspeak,flgread,flgwrite
      from    tlangabi
      where   numappl   = v_index_numappl
      order by codlang;
  begin
    v_index_numappl   := get_numappl(p_codempid_query);
    obj_row    := json();
    for i in c_tlangabi loop

      obj_data    := json();
      v_rcnt      := v_rcnt + 1;

      obj_data.put('coderror','200');
      obj_data.put('numappl',i.numappl);
      obj_data.put('codlang',i.codlang);
      obj_data.put('desc_codlang',get_tcodec_name('TCODLANG',i.codlang,global_v_lang));
      obj_data.put('flglist',i.flglist);
      obj_data.put('desc_flglist',get_tlistval_name('FLGLANG',i.flglist,global_v_lang));
      obj_data.put('flgspeak',i.flgspeak);
      obj_data.put('desc_flgspeak',get_tlistval_name('FLGLANG',i.flgspeak,global_v_lang));
      obj_data.put('flgread',i.flgread);
      obj_data.put('desc_flgread',get_tlistval_name('FLGLANG',i.flgread,global_v_lang));
      obj_data.put('flgwrite',i.flgwrite);
      obj_data.put('desc_flgwrite',get_tlistval_name('FLGLANG',i.flgwrite,global_v_lang));
      obj_row.put(v_rcnt - 1, obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- end gen_langabi_table
  --
  procedure get_hisreward_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_hisreward_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_hisreward_table
  --
  procedure gen_hisreward_table(json_str_output out clob) is
    obj_row           json;
    obj_data          json;
    v_rcnt            number := 0;

    cursor c_thisrewd is
      select  codempid,dteinput,typrewd,desrewd1,
              numhmref,dteupd,coduser,filename
      from    thisrewd
      where   codempid    = p_codempid_query
      order by dteinput;
  begin
    obj_row           := json();

    for i in c_thisrewd loop

      obj_data    := json();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('dteinput',to_char(i.dteinput,'dd/mm/yyyy'));
      obj_data.put('typrewd',i.typrewd);
      obj_data.put('desc_typrewd',get_tcodec_name('TCODREWD',i.typrewd,global_v_lang));
      obj_data.put('desrewd1',i.desrewd1);
      obj_data.put('numhmref',i.numhmref);
      obj_data.put('filename',i.filename);
      obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
      obj_data.put('coduser',i.coduser);
      obj_row.put(v_rcnt - 1, obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- end gen_hisreward_table
  --
  procedure get_sta_submit_reward(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_tab_hisreward(json_str_input);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_sta_submit_col
  --
  procedure get_popup_change_talent(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_popup_change_talent(json_str_input,json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_popup_change_talent
  --
  procedure gen_popup_change_talent(json_str_input in clob, json_str_output out clob) is
    obj_row       json;
    obj_data      json;
    json_obj      json;
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
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- gen_popup_change_talent
  --
  procedure save_talent(json_str_input in clob, json_str_output out clob) is
    param_json                      json;
    param_json_competency            json;
    param_json_langabi             json;
    param_json_hisreward             json;
  begin
    initial_value(json_str_input);
    param_json                  := json(hcm_util.get_string(json(json_str_input),'json_input_str'));
    param_json_competency       := hcm_util.get_json(hcm_util.get_json(param_json,'competency'),'rows');
    param_json_langabi          := hcm_util.get_json(hcm_util.get_json(param_json,'lang_abi'),'rows');
    param_json_hisreward        := hcm_util.get_json(hcm_util.get_json(param_json,'his_reward'),'rows');

    initial_tab_competency(param_json_competency);
    initial_tab_langabi(param_json_langabi);
    initial_tab_hisreward(param_json_hisreward);

    check_tab_competency;
    if param_msg_error is null then
      check_tab_langabi;
      if param_msg_error is null then
        save_competency;
        save_langabi;
        save_hisreward;
      end if;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- save_talent
  --
end;

/

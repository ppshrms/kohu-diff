--------------------------------------------------------
--  DDL for Package Body HRES32E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES32E" is
-- last update: 20/02/2018 10:01

  procedure clear_numseq is
  begin
    b_index_numseq := null;
  end;

  procedure upd_log1(p_numseq 	in number,
                   p_codtable	in varchar2,
                   p_numpage 	in varchar2,
                   p_fldedit 	in varchar2,
                   p_typdata 	in varchar2,
                   p_desold 	in varchar2,
                   p_desnew 	in varchar2,
                   p_flgenc 	in varchar2,
                   p_upd	    in out boolean) is

     v_exist		boolean := false;
     v_count	    number := 0;
     v_yearnew      number;
     v_yearold      number;
     v_datenew 	    varchar2(500 char);
     v_dateold 	    varchar2(500 char);
     v_desnew 	    varchar2(500 char);
     v_desold 	    varchar2(500 char);

    cursor c_temeslog1 is
      select rowid
        from temeslog1
       where codempid = b_index_codempid
         and dtereq  	= b_index_dtereq
         and numseq   = p_numseq
         and numpage	= p_numpage
         and fldedit  = upper(p_fldedit);

  begin
    if p_numseq <> 0 then
      if (p_desold is null and p_desnew is not null) or
         (p_desold is not null and p_desnew is null) or
         (p_desold <> p_desnew) then
         v_desnew := p_desnew;
         v_desold := p_desold;

         if  p_typdata = 'D' then
           if  p_desnew is not null then
               v_yearnew := to_number(to_char(to_date(v_desnew,'dd/mm/yyyy'),'yyyy'));
               v_datenew := to_char(to_date(v_desnew,'dd/mm/yyyy'),'dd/mm');
               v_desnew  := v_datenew||'/'||v_yearnew;
           end if;

           if  p_desold is not null then
               v_yearold := to_number(to_char(to_date(v_desold,'dd/mm/yyyy'),'yyyy'));
               v_dateold := to_char(to_date(v_desold,'dd/mm/yyyy'),'dd/mm');
               v_desold  := v_dateold||'/'||v_yearold;
           end if;
         end if;

          p_upd := true;
          for r_temeslog1 in c_temeslog1 loop
            v_exist := true;
            update temeslog1
            set    codcomp 	= b_index_codcomp,
                   desold 	= v_desold,
                   desnew 	= v_desnew,
                   flgenc 	= p_flgenc,
                   coduser 	= global_v_coduser
            where  rowid = r_temeslog1.rowid;
          end loop;

          if not v_exist then
            insert into temeslog1 (codempid,dtereq,numseq,
                                   numpage,fldedit,codcomp,
                                   desold,desnew,flgenc,coduser)
                 values
                                 (b_index_codempid,b_index_dtereq,p_numseq,
                                  p_numpage,upper(p_fldedit),b_index_codcomp,
                                  v_desold,v_desnew,p_flgenc,global_v_coduser);
          end if;
      else
        delete  from temeslog1
        where   codempid  = b_index_codempid
        and     dtereq  	= b_index_dtereq
        and     numseq    = p_numseq
        and     numpage	  = p_numpage
        and     fldedit   = upper(p_fldedit);
      end if;
    end if;
  end;
  --
  procedure upd_log2(p_numseq		in number,
                     p_codtable	in varchar2,
                     p_numpage 	in varchar2,
                     p_seqno		in number,
                     p_fldedit 	in varchar2,
                     p_typkey 	in varchar2,
                     p_fldkey 	in varchar2,
                     p_codseq 	in varchar2,
                     p_dteseq 	in date,
                     p_typdata 	in varchar2,
                     p_desold 	in varchar2,
                     p_desnew 	in varchar2,
                     p_flgenc 	in varchar2,
                     p_upd	    in out boolean,
                     p_status		in varchar2 default 'E') is --user36 JAS590255 22/04/2016

     v_exist		boolean := false;
     v_yearnew      number;
     v_yearold      number;
     v_datenew 	    varchar2(500 char) ;
     v_dateold 	    varchar2(500 char) ;
     v_desnew 	    varchar2(500 char) ;
     v_desold 	    varchar2(500 char) ;
     v_count		number;

    cursor c_temeslog2 is
      select rowid
        from temeslog2
       where codempid = b_index_codempid
         and dtereq 	= b_index_dtereq
         and numseq 	= p_numseq
         and numpage	= p_numpage
         and seqno  	= p_seqno
         and fldedit  = upper(p_fldedit);

  begin
    if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
       v_desnew := p_desnew ;
       v_desold := p_desold ;
       if  p_typdata = 'D' then
         if  p_desnew is not null  then
             v_yearnew := to_number(to_char(to_date(v_desnew,'dd/mm/yyyy'),'yyyy'));
             v_datenew := to_char(to_date(v_desnew,'dd/mm/yyyy'),'dd/mm') ;
             v_desnew  := v_datenew||'/'||v_yearnew;
         end if;
         if  p_desold is not null then
             v_yearold := to_number(to_char(to_date(v_desold,'dd/mm/yyyy'),'yyyy'));
             v_dateold := to_char(to_date(v_desold,'dd/mm/yyyy'),'dd/mm') ;
             v_desold  := v_dateold||'/'||v_yearold;
         end if;
       end if;
        p_upd := true;
        for r_temeslog1 in c_temeslog2 loop
          v_exist := true;
          update temeslog2
          set    typkey 	= p_typkey,
                 fldkey 	= upper(p_fldkey),
                 codseq 	= p_codseq,
                 dteseq 	= trunc(p_dteseq),
                 codcomp 	= b_index_codcomp,
                 desold 	= v_desold,
                 desnew 	= v_desnew,
                 flgenc 	= p_flgenc,
                 coduser 	= global_v_coduser,
                 status		= p_status --user36 JAS590255 20/04/2016
          where  rowid    = r_temeslog1.rowid;
        end loop;
        if not v_exist then
          insert into temeslog2
          (codempid,dtereq,numseq,
           numpage,seqno,fldedit,
           codcomp,typkey,fldkey,
           codseq,dteseq,desold,
           desnew,flgenc,
           coduser,
           status) --user36 JAS590255 20/04/2016
            values
            ( b_index_codempid,b_index_dtereq,p_numseq,
            p_numpage,p_seqno,upper(p_fldedit),
            b_index_codcomp,p_typkey,p_fldkey,
            p_codseq,p_dteseq,v_desold,
            v_desnew,p_flgenc,
            global_v_coduser,
            p_status); --user36 JAS590255 20/04/2016
        end if;
    else
      delete from temeslog2
       where codempid = b_index_codempid
         and dtereq 	= b_index_dtereq
         and numseq 	= p_numseq
         and numpage	= p_numpage
         and seqno  	= p_seqno
         and fldedit  = upper(p_fldedit);
    end if;
  end;
  --
  procedure upd_log3(p_numseq   in number,
                   p_codtable	  in varchar2,
									 p_numpage 	  in varchar2,
									 p_typdeduct 	in varchar2,
									 p_coddeduct 	in varchar2,
									 p_desold 	  in varchar2,
									 p_desnew 	  in varchar2,
									 p_upd	      in out boolean) is

    v_exist		boolean := false;
    v_count	  number := 0;

    cursor c_temeslog3 is
      select rowid
        from temeslog3
       where codempid  = b_index_codempid
         and dtereq  	 = b_index_dtereq
         and numseq  	 = p_numseq
         and numpage   = p_numpage
         and typdeduct = p_typdeduct
         and coddeduct = p_coddeduct;
  begin
      if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
        p_upd := true;

        for r_temeslog3 in c_temeslog3 loop
          v_exist := true;
          update temeslog3
          set    codcomp  = b_index_codcomp,
                 desold   = p_desold,
                 desnew   = p_desnew,
                 coduser  = global_v_coduser
          where  rowid = r_temeslog3.rowid;
        end loop;
        if not v_exist then
        insert into  temeslog3
														(codempid,dtereq,numpage,
														 numseq,typdeduct,coddeduct,
														 codcomp,desold,desnew,
														 coduser)
				values
														(b_index_codempid,b_index_dtereq,p_numpage,
														 p_numseq,p_typdeduct,p_coddeduct,
														 b_index_codcomp,p_desold,p_desnew,
														 global_v_coduser);
        END IF;
    else
      delete from temeslog3
       where codempid  = b_index_codempid
         and dtereq  	 = b_index_dtereq
         and numseq  	 = p_numseq
         and numpage   = p_numpage
         and typdeduct = p_typdeduct
         and coddeduct = p_coddeduct;
    end if;
  end;
  --
  procedure upd_log2_del(p_numseq		in number, --user36 JAS590255 20/04/2016
                         p_numpage 	in varchar2,
                         p_seqno		in number,
                         p_fldedit 	in varchar2,
                         p_typkey 	in varchar2,
                         p_fldkey 	in varchar2,
                         p_codseq 	in varchar2,
                         p_dteseq 	in date,
                         p_typdata 	in varchar2,
                         p_desold 	in varchar2,
                         p_desnew 	in varchar2,
                         p_upd	    in out boolean) is

     v_exist	 boolean := false;
     v_yearnew   number;
     v_yearold   number;
     v_datenew 	 varchar2(500 char) ;
     v_dateold 	 varchar2(500 char) ;
     v_desnew 	 varchar2(500 char) ;
     v_desold 	 varchar2(500 char) ;

    cursor c_temeslog2 is
      select rowid
        from temeslog2
       where codempid = b_index_codempid
         and dtereq 	= b_index_dtereq
         and numseq 	= p_numseq
         and numpage	= p_numpage
         and seqno  	= p_seqno
         and fldedit  = upper(p_fldedit);

  begin

    v_desnew := p_desnew;
    v_desold := p_desold;

    p_upd := true;
    for r_temeslog2 in c_temeslog2 loop
      v_exist := true;
      update temeslog2
      set    typkey 	= p_typkey,
             fldkey 	= upper(p_fldkey),
             codseq 	= p_codseq,
             dteseq 	= p_dteseq,
             codcomp 	= b_index_codcomp,
             desold 	= v_desold,
             desnew 	= v_desnew,
             flgenc 	= 'N',
             coduser 	= global_v_coduser,
             status		= 'D'
      where  rowid = r_temeslog2.rowid;
    end loop;
    if not v_exist then
      insert into temeslog2
                  (codempid,dtereq,numseq,
                   numpage,seqno,fldedit,
                   codcomp,typkey,fldkey,
                   codseq,dteseq,desold,
                   desnew,flgenc,
                   coduser,
                   status)
          values
                  (b_index_codempid,b_index_dtereq,p_numseq,
                   p_numpage,p_seqno,upper(p_fldedit),
                   b_index_codcomp,p_typkey,p_fldkey,
                   p_codseq,p_dteseq,v_desold,
                   v_desnew,'N',
                   global_v_coduser,
                   'D');
    end if;
  end;
  --
  function get_resp_json_str return clob is
    json_obj              json_object_t;
  begin
    json_obj            :=  json_object_t();
    if param_msg_error is null then
      param_msg_error := '(SUCCESS)';
    else
      param_msg_error := '(ERROR)'||param_msg_error;
    end if;
    json_obj.put('response',param_msg_error);
    return json_obj.to_clob;
  end get_resp_json_str;
  --
--  function msg_error(v_table in varchar2,v_err in varchar2,v_item in varchar2) return varchar2 is
--    v_msg_error varchar2(4000 char);
--    v_codapp    varchar2(10 char) := 'HRES32E';
--    v_numseq    number;
--  begin
--    v_msg_error := web_service_essonline.error_approve(v_table,v_err,global_v_lang);
--      if v_numseq is not null then
--        v_msg_error := v_msg_error||' ('||get_label_name(v_codapp,global_v_lang,v_numseq)||')';
--      end if;
--    return v_msg_error;
--  end msg_error;
  --
  procedure insert_next_step(p_type in varchar2,p_numseq in number) is
    v_codapp   				varchar2(10 char) := null;
    v_count    				number := 0;
    v_codempid_next  	    varchar2(100 char);
    v_codappr               varchar2(100 char);
    v_codempap   			varchar2(100 char);
    v_codcompap  			tcenter.codcomp%type;
    v_codposap   			varchar2(4 char);
    v_approv     			varchar2(10 char);
    v_desc       			varchar2(200 char) := substr(get_label_name('HCM_APPRFLW',global_v_lang,10),1,200);
    v_routeno    			varchar2(15 char);
    --p_numseq          number := b_index_numseq;
    v_table					varchar2(50 char);
    v_error			 	    varchar2(50 char);
  begin
    hres32e_approvno   :=  0 ;
    v_codempap         := b_index_codempid;
    chk_workflow.find_next_approve('HRES32E',v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),p_numseq,hres32e_approvno,b_index_codempid);
--    v_codempid_next := chk_workflow.chk_nextstep('HRES32E',v_routeno,hres32e_approvno,v_codempap,v_codcompap,v_codposap);
    if p_type = 1 then
      v_codapp := 'HRES32E1';
    elsif p_type = 2 then  ---- tab2 data
      v_codapp := 'HRES32E2';
    elsif p_type = 3 then  ---- education
      v_codapp := 'HRES32E3';
    elsif p_type = 4 then  ---- children
      v_codapp := 'HRES32E4';
    elsif p_type = 5 then  ---- honour's
      v_codapp := 'HRES32E5';
    elsif p_type = 6 then  ---- trainning
      v_codapp := 'HRES32E6';
    elsif p_type = 7 then  ---- others data
      v_codapp := 'HRES32E7';
    end if;
    --
    if v_routeno is null then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'twkflph');
      return;
    end if;
    --
    chk_workflow.find_approval('HRES32E',b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),p_numseq,hres32e_approvno,v_table,v_error);
    if v_error is not null then
      param_msg_error := get_error_msg_php(v_error,global_v_lang,v_table);
      return;
    end if;
    --
    loop
      v_codempid_next := chk_workflow.check_next_step2('HRES32E',v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),p_numseq,v_codapp,null,hres32e_approvno,v_codempap);
      -- user22 : 18/07/2016 : JAS590287 || v_codempid_next := chk_workflow.chk_nextstep('HRES32E',v_routeno,:parameter.v_approvno,v_codempap,v_codcompap,v_codposap);
      if v_codempid_next is not null then
        hres32e_approvno := hres32e_approvno + 1 ;
        v_codappr        :=  v_codempid_next ;

        begin
          select count(*) into v_count
            from tapempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and typreq   = v_codapp
             and numseq   = p_numseq
             and approvno = hres32e_approvno;
        exception when no_data_found then
          v_count := 0;
        end;

        if v_count = 0 then
              insert into tapempch (codempid,dtereq,typreq,
                                    numseq,approvno,codappr,
                                    dteappr,staappr,remark,
                                    coduser)
                     values        (b_index_codempid,b_index_dtereq,v_codapp,
                                    p_numseq,hres32e_approvno,v_codempid_next,
                                    to_date(sysdate,'DD/MM/YYYY HH24:MI:SS'),'A',v_desc,
                                    global_v_coduser);
        else
          update tapempch
                  set codappr = v_codempid_next,
                      dteappr = trunc(sysdate),
                      staappr = 'A',
                      remark  = v_desc,
                      coduser = global_v_coduser
          where codempid = b_index_codempid
            and dtereq   = b_index_dtereq
            and typreq   = v_codapp
            and numseq   = p_numseq
            and approvno = hres32e_approvno;
        end if;
      else
        exit;
      end if;
      chk_workflow.find_next_approve('HRES32E',v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),p_numseq,hres32e_approvno,b_index_codempid);
    end loop;

    if p_type = 1 then
      tab1_routeno   	:= v_routeno ;
      tab1_codempap  	:= v_codempap ;
      tab1_codcompap 	:= v_codcompap ;
      tab1_codposap  	:= v_codposap ;
    elsif p_type = 2 then
      tab2_routeno   	:= v_routeno ;
      tab2_codempap  	:= v_codempap ;
      tab2_codcompap 	:= v_codcompap ;
      tab2_codposap  	:= v_codposap ;
    elsif p_type = 3 then
      tab3_routeno   := v_routeno ;
      tab3_codempap  := v_codempap ;
      tab3_codcompap := v_codcompap ;
      tab3_codposap  := v_codposap ;

      tab31_routeno    := v_routeno ;
      tab31_codempap   := v_codempap ;
      tab31_codcompap  := v_codcompap ;
      tab31_codposap   := v_codposap ;
    elsif p_type = 4 then
      tab4_routeno   := v_routeno ;
      tab4_codempap  := v_codempap ;
      tab4_codcompap := v_codcompap ;
      tab4_codposap  := v_codposap ;
    elsif p_type = 5 then
      tab5_routeno   := v_routeno ;
      tab5_codempap  := v_codempap ;
      tab5_codcompap := v_codcompap ;
      tab5_codposap  := v_codposap ;
    elsif p_type = 6 then
      tab6_routeno   := v_routeno ;
      tab6_codempap  := v_codempap ;
      tab6_codcompap := v_codcompap ;
      tab6_codposap  := v_codposap ;
      tab61_routeno  := v_routeno ;
      tab61_codempap := v_codempap ;
      tab61_codcompap:= v_codcompap ;
      tab61_codposap := v_codposap ;
    elsif p_type = 7 then
      others_data_routeno     := v_routeno ;
      others_data_codempap    := v_codempap ;
      others_data_codcompap   := v_codcompap ;
      others_data_codposap    := v_codposap ;
    end if;

  --<< user22 :18/07/2016 : JAS590287 ||
	tab1_staappr   := 'P';
 	tab2_staappr   := 'P';
 	tab3_staappr   := 'P';
 	tab31_staappr  := 'P';
 	tab4_staappr   := 'P';
 	tab5_staappr   := 'P';
 	tab6_staappr   := 'P';
 	tab61_staappr  := 'P';
 	others_data_staappr  := 'P';
-->> user22 :18/07/2016 : JAS590287 ||

   if hres32e_approvno > 0 then
     if p_type = 1 then -- Name
      tab1_staappr   := 'A' ;
      tab1_approvno  := hres32e_approvno ;
      tab1_codappr   := v_codappr ;
      tab1_dteappr   := trunc(sysdate) ;
      tab1_remarkap  := v_desc ;
     elsif p_type = 2 then  ---- tab2
      tab2_staappr   := 'A' ;
      tab2_approvno  := hres32e_approvno ;
      tab2_codappr   := v_codappr ;
      tab2_dteappr   := trunc(sysdate) ;
      tab2_remarkap  := v_desc ;
     elsif p_type = 3 then  ---- Education
      tab3_staappr   := 'A' ;
      tab3_approvno  := hres32e_approvno ;
      tab3_codappr   := v_codappr ;
      tab3_dteappr   := trunc(sysdate) ;
      tab3_remarkap  := v_desc ;

      tab31_staappr   := 'A' ;
      tab31_approvno  := hres32e_approvno ;
      tab31_codappr   := v_codappr ;
      tab31_dteappr   := trunc(sysdate) ;
      tab31_remarkap  := v_desc ;
     elsif p_type = 4 then  ---- Children
      tab4_staappr   := 'A' ;
      tab4_approvno  := hres32e_approvno ;
      tab4_codappr   := v_codappr ;
      tab4_dteappr   := trunc(sysdate) ;
      tab4_remarkap  := v_desc ;
     elsif p_type = 5 then  ---- Honour
      tab5_staappr   := 'A' ;
      tab5_approvno  := hres32e_approvno ;
      tab5_codappr   := v_codappr ;
      tab5_dteappr   := trunc(sysdate) ;
      tab5_remarkap  := v_desc ;
     elsif p_type = 6 then
      tab6_staappr   := 'A' ;
      tab6_approvno  := hres32e_approvno ;
      tab6_codappr   := v_codappr ;
      tab6_dteappr   := trunc(sysdate) ;
      tab6_remarkap  := v_desc ;

      tab61_staappr   := 'A' ;
      tab61_approvno  := hres32e_approvno ;
      tab61_codappr   := v_codappr ;
      tab61_dteappr   := trunc(sysdate) ;
      tab61_remarkap  := v_desc ;
     elsif p_type = 7 then
      others_data_staappr   := 'A' ;
      others_data_approvno  := hres32e_approvno ;
      others_data_codappr   := v_codappr ;
      others_data_dteappr   := trunc(sysdate) ;
      others_data_remarkap  := v_desc ;
     end if;
   end if;
  end;

  --get_staappr
  function get_staappr(json_str in clob) return varchar2 is
    v_staappr  varchar2(100 char);
  begin
    initial_value(json_str);
    begin
       select staappr
         into	v_staappr
         from	tempch
        where	codempid = b_index_codempid
          and dtereq   = b_index_dtereq
          and numseq   = b_index_numseq
          and typchg   = b_index_typchg; -- = p_tab
        exception when others then null;
    end;

    return v_staappr;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_staappr;
  --

  function hres32e_index(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return gen_index_data;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_index;

  --hres32e_detail1_tab1
  function hres32e_detail_tab1(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_tnamech;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_detail_tab1;

  --hres32e_detail1_tab2
  function hres32e_detail_tab2(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_address;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_detail_tab2;

  --hres32e_detail1_tab3
  function hres32e_detail_tab3(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_tfamily;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_detail_tab3;

  --hres32e_detail_tab4
  function hres32e_detail_tab4(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_document;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_detail_tab4;

  --hres32e_detail_tab5
  function hres32e_detail_tab5(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_trewdreq;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_detail_tab5;

  --hres32e_detail_tab6
  function hres32e_detail_tab6(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_education;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_detail_tab6;

  --hres32e_detail_tab7
  function hres32e_detail_tab7(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_childen;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_detail_tab7;

  --hres32e_detail_tab8_e
  function hres32e_detail_tab8_1(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_tdeductd_e;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_detail_tab8_1;

  --hres32e_detail_tab8
  function hres32e_detail_tab8_2(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_tdeductd_d;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_detail_tab8_2;

  --hres32e_detail_tab8_3
  function hres32e_detail_tab8_3(json_str in clob) return clob as
  begin
    initial_value(json_str);
    return get_tdeductd_o;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_detail_tab8_3;
  --
  --hres32e_detail_tab9
  function hres32e_detail_tab9(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_tempch;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_detail_tab9;
  --
  --hres32e_detail_tab10
  function hres32e_detail_tab10(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_ttrainbf;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end hres32e_detail_tab10;
  --hres32e_tab2_relatives
  function hres32e_tab2_relatives(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_relatives;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end;
  --  --hres32e_tab3_work_exp
  function hres32e_tab3_work_exp(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_work_exp;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
    --hres32e_tab2_relatives
  function hres32e_tab5_competency(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_competency;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end;
    --hres32e_tab2_relatives
  function hres32e_tab5_lang_abi(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_lang_abi;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end;
    --hres32e_tab2_relatives
  function hres32e_tab5_his_reward(json_str in clob) return clob as
  begin
    clear_numseq;
    initial_value(json_str);
    return get_his_reward;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t := json_object_t(json_str);

  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
    p_limit             := hcm_util.get_string_t(json_obj,'p_limit');
    p_start             := hcm_util.get_string_t(json_obj,'p_start');
    p_end               := hcm_util.get_string_t(json_obj,'p_end');
    --b-index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    if b_index_codempid is null then
       b_index_codempid := global_v_codempid;
    end if;
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
--    b_index_dtereq_st   := hcm_util.get_string(json_obj,'p_dtereq_st');
--    b_index_dtereq_en   := hcm_util.get_string(json_obj,'p_dtereq_en');
    b_index_dtereq_st   := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_st'),'dd/mm/yyyy');
    b_index_dtereq_en   := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_en'),'dd/mm/yyyy');
    --
    b_index_dtereq      := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    b_index_v_dtereq    := to_date(hcm_util.get_string_t(json_obj,'v_dtereq'),'dd/mm/yyyy');
    b_index_numseq      := nvl(hcm_util.get_string_t(json_obj,'p_numseq'),b_index_numseq);
    b_index_typchg      := hcm_util.get_string_t(json_obj,'p_typchg');
    --edit
    v_typecod           := hcm_util.get_string_t(json_obj,'p_typecod');
    tab1_staappr        := hcm_util.get_string_t(json_obj,'p_staappr1');
    tab2_staappr        := hcm_util.get_string_t(json_obj,'p_staappr2');
    tab3_staappr        := hcm_util.get_string_t(json_obj,'p_staappr3');
    tab4_staappr        := hcm_util.get_string_t(json_obj,'p_staappr4');
    tab5_staappr        := hcm_util.get_string_t(json_obj,'p_staappr5');
    tab6_staappr        := hcm_util.get_string_t(json_obj,'p_staappr6');
    --routeno
    hres32e_approvno    := null;
    p_type              := hcm_util.get_string_t(json_obj,'p_type'); -- = p_tab1-6
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_tabno             := hcm_util.get_string_t(json_obj,'p_tabno');

    --tab1
    tab1_n_codtitle     := hcm_util.get_string_t(json_obj,'n_codtitle');
    tab1_n_name         := hcm_util.get_string_t(json_obj,'n_name');
    tab1_n_last         := hcm_util.get_string_t(json_obj,'n_last');
    --<< user28 || 12/03/2019 || redmind #6317
    tab1_n_namee         := hcm_util.get_string_t(json_obj,'n_namee');
    tab1_n_namet         := hcm_util.get_string_t(json_obj,'n_namet');
    tab1_n_name3         := hcm_util.get_string_t(json_obj,'n_name3');
    tab1_n_name4         := hcm_util.get_string_t(json_obj,'n_name4');
    tab1_n_name5         := hcm_util.get_string_t(json_obj,'n_name5');
    tab1_n_laste         := hcm_util.get_string_t(json_obj,'n_laste');
    tab1_n_lastt         := hcm_util.get_string_t(json_obj,'n_lastt');
    tab1_n_last3         := hcm_util.get_string_t(json_obj,'n_last3');
    tab1_n_last4         := hcm_util.get_string_t(json_obj,'n_last4');
    tab1_n_last5         := hcm_util.get_string_t(json_obj,'n_last5');
    tab1_n_nicke         := hcm_util.get_string_t(json_obj,'n_nicke');
    tab1_n_nickt         := hcm_util.get_string_t(json_obj,'n_nickt');
    tab1_n_nick3         := hcm_util.get_string_t(json_obj,'n_nick3');
    tab1_n_nick4         := hcm_util.get_string_t(json_obj,'n_nick4');
    tab1_n_nick5         := hcm_util.get_string_t(json_obj,'n_nick5');
    -->> user28 || 12/03/2019 || redmind #6317
    tab1_desnote        := hcm_util.get_string_t(json_obj,'desnote');
    --tab2_1
    tab2_adrreg         := hcm_util.get_string_t(json_obj,'n_adrreg');
    tab2_adrrege        := hcm_util.get_string_t(json_obj,'n_adrrege');
    tab2_adrregt        := hcm_util.get_string_t(json_obj,'n_adrregt');
    tab2_adrreg3        := hcm_util.get_string_t(json_obj,'n_adrreg3');
    tab2_adrreg4        := hcm_util.get_string_t(json_obj,'n_adrreg4');
    tab2_adrreg5        := hcm_util.get_string_t(json_obj,'n_adrreg5');
    tab2_codcntyr       := hcm_util.get_string_t(json_obj,'n_codcntyr');
    tab2_codprovr       := hcm_util.get_string_t(json_obj,'n_codprovr');
    tab2_coddistr       := hcm_util.get_string_t(json_obj,'n_coddistr');
    tab2_codsubdistr    := hcm_util.get_string_t(json_obj,'n_codsubdistr');
    tab2_codpostr       := hcm_util.get_string_t(json_obj,'n_codpostr');
    tab2_email_emp      := hcm_util.get_string_t(json_obj,'n_email_emp');
    tab2_lineid         := hcm_util.get_string_t(json_obj,'n_lineid');
    tab2_nummobile      := hcm_util.get_string_t(json_obj,'n_nummobile');
    tab2_adrcont        := hcm_util.get_string_t(json_obj,'n_adrcont');
    tab2_adrconte       := hcm_util.get_string_t(json_obj,'n_adrconte');
    tab2_adrcontt       := hcm_util.get_string_t(json_obj,'n_adrcontt');
    tab2_adrcont3       := hcm_util.get_string_t(json_obj,'n_adrcont3');
    tab2_adrcont4       := hcm_util.get_string_t(json_obj,'n_adrcont4');
    tab2_adrcont5       := hcm_util.get_string_t(json_obj,'n_adrcont5');
    tab2_codcntyc       := hcm_util.get_string_t(json_obj,'n_codcntyc');
    tab2_codprovc       := hcm_util.get_string_t(json_obj,'n_codprovc');
    tab2_coddistc       := hcm_util.get_string_t(json_obj,'n_coddistc');
    tab2_codsubdistc    := hcm_util.get_string_t(json_obj,'n_codsubdistc');
    tab2_codpostc       := hcm_util.get_string_t(json_obj,'n_codpostc');
    tab2_numtelec       := hcm_util.get_string_t(json_obj,'n_numtelec');
    --tab2_2
    tab2_numoffid       := hcm_util.get_string_t(json_obj,'n_numoffid');
    tab2_dteoffid       := to_date(hcm_util.get_string_t(json_obj,'n_dteoffid'),'dd/mm/yyyy');
    tab2_adrissue       := hcm_util.get_string_t(json_obj,'n_adrissue');
    tab2_codprovi       := hcm_util.get_string_t(json_obj,'n_codprovi');
    tab2_numpasid       := hcm_util.get_string_t(json_obj,'n_numpasid');
    tab2_dtepasid       := to_date(hcm_util.get_string_t(json_obj,'n_dtepasid'),'dd/mm/yyyy');
    tab2_numprmid       := hcm_util.get_string_t(json_obj,'n_numprmid');
    tab2_dteprmst       := to_date(hcm_util.get_string_t(json_obj,'n_dteprmst'),'dd/mm/yyyy');
    tab2_dteprmen       := to_date(hcm_util.get_string_t(json_obj,'n_dteprmen'),'dd/mm/yyyy');
    tab2_numlicid       := hcm_util.get_string_t(json_obj,'n_numlicid');
    tab2_dtelicid       := to_date(hcm_util.get_string_t(json_obj,'n_dtelicid'),'dd/mm/yyyy');
    tab2_stamarry       := hcm_util.get_string_t(json_obj,'n_stamarry');
    tab2_stamilit       := hcm_util.get_string_t(json_obj,'n_stamilit');
    tab2_numvisa        := hcm_util.get_string_t(json_obj,'n_numvisa');
    tab2_dtevisaexp     := to_date(hcm_util.get_string_t(json_obj,'n_dtevisaexp'),'dd/mm/yyyy');
    tab2_codclnsc       := hcm_util.get_string_t(json_obj,'n_codclnsc');
    tab2_dteretire      := to_date(hcm_util.get_string_t(json_obj,'n_dteretire'),'dd/mm/yyyy');

    --tab_travel
    tab2_typtrav        := hcm_util.get_string_t(json_obj,'n_typtrav');
    tab2_qtylength      := hcm_util.get_string_t(json_obj,'n_qtylength');
    tab2_carlicen       := hcm_util.get_string_t(json_obj,'n_carlicen');
    tab2_typfuel        := hcm_util.get_string_t(json_obj,'n_typfuel');
    tab2_codbusno       := hcm_util.get_string_t(json_obj,'n_codbusno');
    tab2_codbusrt       := hcm_util.get_string_t(json_obj,'n_codbusrt');

    --tab2_family
    tab2_codempfa       := hcm_util.get_string_t(json_obj,'n_codempfa');
    tab2_codfnatn       := hcm_util.get_string_t(json_obj,'n_codfnatn');
    tab2_codfrelg       := hcm_util.get_string_t(json_obj,'n_codfrelg');
    tab2_codfoccu       := hcm_util.get_string_t(json_obj,'n_codfoccu');
    tab2_numofidf       := hcm_util.get_string_t(json_obj,'n_numofidf');
    tab2_codempmo       := hcm_util.get_string_t(json_obj,'n_codempmo');
    tab2_codmnatn       := hcm_util.get_string_t(json_obj,'n_codmnatn');
    tab2_codmrelg       := hcm_util.get_string_t(json_obj,'n_codmrelg');
    tab2_codmoccu       := hcm_util.get_string_t(json_obj,'n_codmoccu');
    tab2_numofidm       := hcm_util.get_string_t(json_obj,'n_numofidm');
    tab2_adrcont1       := hcm_util.get_string_t(json_obj,'n_adrcont1');
    tab2_codpost        := hcm_util.get_string_t(json_obj,'n_codpost');
    tab2_numtele        := hcm_util.get_string_t(json_obj,'n_numtele');
    tab2_numfax         := hcm_util.get_string_t(json_obj,'n_numfax');
    tab2_email          := hcm_util.get_string_t(json_obj,'n_email');
    tab2_desrelat       := hcm_util.get_string_t(json_obj,'n_desrelat');
    tab2_codtitlf       := hcm_util.get_string_t(json_obj,'n_codtitlf');
    tab2_namfstfe       := hcm_util.get_string_t(json_obj,'n_namfstfe');
    tab2_namfstft       := hcm_util.get_string_t(json_obj,'n_namfstft');
    tab2_namfstf3       := hcm_util.get_string_t(json_obj,'n_namfstf3');
    tab2_namfstf4       := hcm_util.get_string_t(json_obj,'n_namfstf4');
    tab2_namfstf5       := hcm_util.get_string_t(json_obj,'n_namfstf5');
    tab2_namlstfe       := hcm_util.get_string_t(json_obj,'n_namlstfe');
    tab2_namlstft       := hcm_util.get_string_t(json_obj,'n_namlstft');
    tab2_namlstf3       := hcm_util.get_string_t(json_obj,'n_namlstf3');
    tab2_namlstf4       := hcm_util.get_string_t(json_obj,'n_namlstf4');
    tab2_namlstf5       := hcm_util.get_string_t(json_obj,'n_namlstf5');
    tab2_codtitlm       := hcm_util.get_string_t(json_obj,'n_codtitlm');
    tab2_namfstme       := hcm_util.get_string_t(json_obj,'n_namfstme');
    tab2_namfstmt       := hcm_util.get_string_t(json_obj,'n_namfstmt');
    tab2_namfstm3       := hcm_util.get_string_t(json_obj,'n_namfstm3');
    tab2_namfstm4       := hcm_util.get_string_t(json_obj,'n_namfstm4');
    tab2_namfstm5       := hcm_util.get_string_t(json_obj,'n_namfstm5');
    tab2_namlstme       := hcm_util.get_string_t(json_obj,'n_namlstme');
    tab2_namlstmt       := hcm_util.get_string_t(json_obj,'n_namlstmt');
    tab2_namlstm3       := hcm_util.get_string_t(json_obj,'n_namlstm3');
    tab2_namlstm4       := hcm_util.get_string_t(json_obj,'n_namlstm4');
    tab2_namlstm5       := hcm_util.get_string_t(json_obj,'n_namlstm5');
    tab2_codtitlc       := hcm_util.get_string_t(json_obj,'n_codtitlc');
    tab2_namfstce       := hcm_util.get_string_t(json_obj,'n_namfstce');
    tab2_namfstct       := hcm_util.get_string_t(json_obj,'n_namfstct');
    tab2_namfstc3       := hcm_util.get_string_t(json_obj,'n_namfstc3');
    tab2_namfstc4       := hcm_util.get_string_t(json_obj,'n_namfstc4');
    tab2_namfstc5       := hcm_util.get_string_t(json_obj,'n_namfstc5');
    tab2_namlstce       := hcm_util.get_string_t(json_obj,'n_namlstce');
    tab2_namlstct       := hcm_util.get_string_t(json_obj,'n_namlstct');
    tab2_namlstc3       := hcm_util.get_string_t(json_obj,'n_namlstc3');
    tab2_namlstc4       := hcm_util.get_string_t(json_obj,'n_namlstc4');
    tab2_namlstc5       := hcm_util.get_string_t(json_obj,'n_namlstc5');
    tab2_dtebdfa        := to_date(hcm_util.get_string_t(json_obj,'n_dtebdfa'),'dd/mm/yyyy');
    tab2_staliff        := hcm_util.get_string_t(json_obj,'n_staliff');
    tab2_dtedeathf      := to_date(hcm_util.get_string_t(json_obj,'n_dtedeathf'),'dd/mm/yyyy');
    tab2_filenamf       := hcm_util.get_string_t(json_obj,'n_filenamf');
    tab2_dtebdmo        := to_date(hcm_util.get_string_t(json_obj,'n_dtebdmo'),'dd/mm/yyyy');
    tab2_stalifm        := hcm_util.get_string_t(json_obj,'n_stalifm');
    tab2_dtedeathm      := to_date(hcm_util.get_string_t(json_obj,'n_dtedeathm'),'dd/mm/yyyy');
    tab2_filenamm       := hcm_util.get_string_t(json_obj,'n_filenamm');

    --tab2_bank
    tab2_codbank            := hcm_util.get_string_t(json_obj,'n_codbank');
    tab2_numbank            := hcm_util.get_string_t(json_obj,'n_numbank');
    tab2_numbrnch           := hcm_util.get_string_t(json_obj,'n_numbrnch');
    tab2_amtbank            := hcm_util.get_string_t(json_obj,'n_amtbank');
    tab2_amttranb           := hcm_util.get_string_t(json_obj,'n_amttranb');
    tab2_codbank2           := hcm_util.get_string_t(json_obj,'n_codbank2');
    tab2_numbank2           := hcm_util.get_string_t(json_obj,'n_numbank2');
    tab2_numbrnch2          := hcm_util.get_string_t(json_obj,'n_numbrnch2');

    --tab2_spouse
--    tab2_namspous 	    := hcm_util.get_string(json_obj,'n_namspous');
--    tab2_numoffid   	  := hcm_util.get_string(json_obj,'n_numoffid');
--    tab2_dtespbd    	  := to_date(hcm_util.get_string(json_obj,'n_dtespbd'),'dd/mm/yyyy');
--    tab2_codspocc   	  := hcm_util.get_string(json_obj,'n_codspocc');
--    tab2_desnoffi   	  := hcm_util.get_string(json_obj,'n_desnoffi');
--    tab2_dtemarry   	  := to_date(hcm_util.get_string(json_obj,'n_dtemarry'),'dd/mm/yyyy');
--    tab2_desplreg   	  := hcm_util.get_string(json_obj,'n_desplreg');
--    tab2_codsppro   	  := hcm_util.get_string(json_obj,'n_codsppro');
--    tab2_codspcty   	  := hcm_util.get_string(json_obj,'n_codspcty');
--    tab2_desnote 	      := hcm_util.get_string(json_obj,'n_desnote');

      tab2_codtitle     := hcm_util.get_string_t(json_obj,'n_codtitle');
      tab2_namfirste    := hcm_util.get_string_t(json_obj,'n_namfirste');
      tab2_namfirstt    := hcm_util.get_string_t(json_obj,'n_namfirstt');
      tab2_namfirst3    := hcm_util.get_string_t(json_obj,'n_namfirst3');
      tab2_namfirst4    := hcm_util.get_string_t(json_obj,'n_namfirst4');
      tab2_namfirst5    := hcm_util.get_string_t(json_obj,'n_namfirst5');
      tab2_namlaste     := hcm_util.get_string_t(json_obj,'n_namlaste');
      tab2_namlastt     := hcm_util.get_string_t(json_obj,'n_namlastt');
      tab2_namlast3     := hcm_util.get_string_t(json_obj,'n_namlast3');
      tab2_namlast4     := hcm_util.get_string_t(json_obj,'n_namlast4');
      tab2_namlast5     := hcm_util.get_string_t(json_obj,'n_namlast5');
      tab2_numspid      := hcm_util.get_string_t(json_obj,'n_numspid');
      tab2_dtespbd      := to_date(hcm_util.get_string_t(json_obj,'n_dtespbd'),'dd/mm/yyyy');
      tab2_codspocc     := hcm_util.get_string_t(json_obj,'n_codspocc');
      tab2_desnoffi     := hcm_util.get_string_t(json_obj,'n_desnoffi');
      tab2_dtemarry     := to_date(hcm_util.get_string_t(json_obj,'n_dtemarry'),'dd/mm/yyyy');
      tab2_desplreg     := hcm_util.get_string_t(json_obj,'n_desplreg');
      tab2_codsppro     := hcm_util.get_string_t(json_obj,'n_codsppro');
      tab2_codspcty     := hcm_util.get_string_t(json_obj,'n_codspcty');
      tab2_desnote      := hcm_util.get_string_t(json_obj,'n_desnote');
      tab2_codempidsp   := hcm_util.get_string_t(json_obj,'n_codempidsp');
      tab2_stalife      := hcm_util.get_string_t(json_obj,'n_stalife');
      tab2_dtedthsp     := to_date(hcm_util.get_string_t(json_obj,'n_dtedthsp'),'dd/mm/yyyy');
      tab2_staincom     := hcm_util.get_string_t(json_obj,'n_staincom');
      tab2_numfasp      := hcm_util.get_string_t(json_obj,'n_numfasp');
      tab2_nummosp      := hcm_util.get_string_t(json_obj,'n_nummosp');
      tab2_filename     := hcm_util.get_string_t(json_obj,'n_filename');

    --tab2_6
    tab222_qtychedu     := hcm_util.get_string_t(json_obj,'p_qtychedu');
    tab222_qtychned     := hcm_util.get_string_t(json_obj,'p_qtychned');
    --tab5
    tab5_typrewd        := hcm_util.get_string_t(json_obj,'n_codrewd');
    tab5_numhmref       := hcm_util.get_string_t(json_obj,'n_numhmref');
    tab5_desrewd1       := hcm_util.get_string_t(json_obj,'n_desrewd1');
    --delete
    v_seqno             := hcm_util.get_string_t(json_obj,'p_seqno');
    tab3_numseq         := hcm_util.get_string_t(json_obj,'tab3_numseq');
    tab4_numseq         := hcm_util.get_string_t(json_obj,'tab4_numseq');
    tab6_numseq         := hcm_util.get_string_t(json_obj,'tab6_numseq');

    if b_index_numseq is null then
      b_index_numseq := get_numseq;
    end if;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  --get_numseq
  function get_numseq return varchar2 is
    new_numseq  varchar2(100 char) := 1;
  begin
    begin
       select nvl(max(numseq),0) + 1 into	new_numseq
         from	tempch
        where	codempid = b_index_codempid
          and dtereq   = b_index_dtereq;
    exception when others then
       null;
    end;

    return to_char(new_numseq);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_numseq;
  --
  procedure initial_value_tab2_6(json_str in clob, p_flg in varchar2) is
    json_obj        json_object_t := json_object_t(json_str);
    box_item_no26   varchar2(100 char) := p_flg;
  begin
--    tab26_box_items      := json(hcm_util.get_string(json_obj,'p_box_items'));
--    tab26_box_items1     := hcm_util.get_json(tab26_box_items,'tab2_6_1');
--    tab26_box_items2     := hcm_util.get_json(tab26_box_items,'tab2_6_2');
--    tab26_box_items3     := hcm_util.get_json(tab26_box_items,'tab2_6_3');
      if box_item_no26 = 1 then
        tab261_coddeduct        := hcm_util.get_string_t(json_obj,'coddeduct');
        tab261_amtdeduct        := hcm_util.get_string_t(json_obj,'amtdeduct');
        tab261_amtdeduct_spous  := hcm_util.get_string_t(json_obj,'amtdeduct_spous');
      elsif box_item_no26 = 2 then
        tab262_coddeduct        := hcm_util.get_string_t(json_obj,'coddeduct');
        tab262_amtdeduct        := hcm_util.get_string_t(json_obj,'amtdeduct');
        tab262_amtdeduct_spous  := hcm_util.get_string_t(json_obj,'amtdeduct_spous');
      else
        tab263_coddeduct        := hcm_util.get_string_t(json_obj,'coddeduct');
        tab263_amtdeduct        := hcm_util.get_string_t(json_obj,'amtdeduct');
        tab263_amtdeduct_spous  := hcm_util.get_string_t(json_obj,'amtdeduct_spous');
      end if;

  end;
  --
  procedure initial_value_tab2_7(json_str in clob) is
    json_obj        json_object_t := json_object_t(json_str);
  begin
    --tab27_box_items     := json(hcm_util.get_string_t(json_obj,'p_box_items2_7'));
    tab27_numseq   := to_number(hcm_util.get_string_t(json_obj,'numseq'));
    tab27_typdoc   := hcm_util.get_string_t(json_obj,'typdoc');
    tab27_namdoc   := hcm_util.get_string_t(json_obj,'namdoc');
    tab27_dterecv  := to_date(hcm_util.get_string_t(json_obj,'dterecv'),'dd/mm/yyyy');
    tab27_dtedocen := to_date(hcm_util.get_string_t(json_obj,'dtedocen'),'dd/mm/yyyy');
    tab27_numdoc   := hcm_util.get_string_t(json_obj,'numdoc');
    tab27_filedoc  := hcm_util.get_string_t(json_obj,'filedoc');
    tab27_desnote  := hcm_util.get_string_t(json_obj,'desnote');
    tab27_flgresume  := hcm_util.get_string_t(json_obj,'flgresume');

  end;
  --
  procedure initial_value_tab3(json_str in clob) is
    json_obj        json_object_t := json_object_t(json_str);
  begin
   -- tab31_box_items     := json(hcm_util.get_string(json_obj,'p_box_items3'));
    tab31_numseq        :=  to_number(hcm_util.get_string_t(json_obj,'numseq'));
    tab31_codedlv       :=  hcm_util.get_string_t(json_obj,'codedlv');
    tab31_coddglv       :=  hcm_util.get_string_t(json_obj,'coddglv');
    tab31_codmajsb      :=  hcm_util.get_string_t(json_obj,'codmajsb');
    tab31_codminsb      :=  hcm_util.get_string_t(json_obj,'codminsb');
    tab31_codinst       :=  hcm_util.get_string_t(json_obj,'codinst');
    tab31_codcount      :=  hcm_util.get_string_t(json_obj,'codcount');
    tab31_numgpa        :=  to_number(hcm_util.get_string_t(json_obj,'numgpa'));
    tab31_stayear       :=  to_number(hcm_util.get_string_t(json_obj,'stayear'));
    tab31_dtegyear      :=  to_number(hcm_util.get_string_t(json_obj,'dtegyear'));
    tab31_flgeduc       :=  hcm_util.get_string_t(json_obj,'flgeduc');

  end;
  --
  procedure initial_value_tab4(json_str in clob) is
    json_obj        json_object_t := json_object_t(json_str);
  begin
    --tab4_box_items     := json(hcm_util.get_string(json_obj,'p_box_items4'));
    tab4_numseq	    :=  to_number(hcm_util.get_string_t(json_obj,'numseq'));
    tab4_namche		  :=  hcm_util.get_string_t(json_obj,'namche');
    tab4_namcht		  :=  hcm_util.get_string_t(json_obj,'namcht');
    tab4_namch3		  :=  hcm_util.get_string_t(json_obj,'namch3');
    tab4_namch4		  :=  hcm_util.get_string_t(json_obj,'namch4');
    tab4_namch5		  :=  hcm_util.get_string_t(json_obj,'namch5');
    tab4_dtechbd		:=  to_date(hcm_util.get_string_t(json_obj,'dtechbd'),'dd/mm/yyyy');
    tab4_codsex 		:=  hcm_util.get_string_t(json_obj,'namsex');
    tab4_codedlv		:=  hcm_util.get_string_t(json_obj,'codedlv');
    tab4_numoffid   :=  hcm_util.get_string_t(json_obj,'numoffid');
    tab4_flgedlv    :=  hcm_util.get_string_t(json_obj,'flgedlv');
    tab4_flgdeduct  :=  hcm_util.get_string_t(json_obj,'flgdeduct');
  end;
  --
  procedure initial_value_tab6(json_str in clob) is
    json_obj        json_object_t := json_object_t(json_str);
  begin
--    tab6_box_items     := json(hcm_util.get_string(json_obj,'p_box_items6'));
    tab61_numseq    :=  hcm_util.get_string_t(json_obj,'numseq');
    tab61_dtetrain  :=  to_date(hcm_util.get_string_t(json_obj,'dtetrain'),'dd/mm/yyyy');
    tab61_destrain  :=  hcm_util.get_string_t(json_obj,'destrain');
    tab61_dtetren   :=  to_date(hcm_util.get_string_t(json_obj,'dtetren'),'dd/mm/yyyy');
    tab61_desplace  :=  hcm_util.get_string_t(json_obj,'desplace');
    tab61_desinstu  :=  hcm_util.get_string_t(json_obj,'desinstu');
    tab61_filedoc   :=  hcm_util.get_string_t(json_obj,'filedoc');
  end;
  --

  procedure hres32e_check_index is
  v_count       number := 0;
  v_code        varchar2(100 char);
  begin

   if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_codempid is not null and b_index_codempid <> global_v_codempid  then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codempid);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_dtereq_st is not null and b_index_dtereq_en is not null then
      if b_index_dtereq_st > b_index_dtereq_en then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
      end if;
    end if;
  end hres32e_check_index;

  --
  procedure check_index is
    v_count       number := 0;
    v_code        varchar2(100 char);
  begin
    if b_index_dtereq is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
	  end if;

    if tab2_codsubdistr is not null then
      begin
        select codsubdist into v_code
        from	 tsubdist
        where	 codprov = tab2_codprovr
        and		 coddist = tab2_coddistr
        and		 codsubdist = tab2_codsubdistr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;

    if tab2_coddistr is not null then
      begin
        select coddist into v_code
        from	 tcoddist
        where	 codprov = tab2_codprovr
        and		 coddist = tab2_coddistr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end;
    end if;

    if tab2_codprovr is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec = tab2_codprovr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;

    if tab2_codcntyr is not null then
      begin
        select codcodec into v_code
        from	 tcodcnty
        where	 codcodec = tab2_codcntyr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;

    if tab2_codsubdistc is not null then
      begin
        select codsubdist into v_code
        from	 tsubdist
        where	 codprov = tab2_codprovc
        and		 coddist = tab2_coddistc
        and		 codsubdist = tab2_codsubdistc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;

    if tab2_coddistc is not null then
      begin
        select coddist into v_code
        from	 tcoddist
        where	 codprov = tab2_codprovc
        and		 coddist = tab2_coddistc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;

    if tab2_codprovc is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec = tab2_codprovc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;

    if tab2_codcntyc is not null then
      begin
        select codcodec into v_code
        from	 tcodcnty
        where	 codcodec = tab2_codcntyc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;

    --check_index_tab2_6
    if nvl(tab222_qtychedu,0) + nvl(tab222_qtychned,0) > 3 then
      param_msg_error := get_error_msg_php('PM0055',global_v_lang);
      return;
    end if;

    begin
       select codcomp  into b_index_codcomp
         from temploy1
        where codempid = b_index_codempid;
    exception when no_data_found then
      b_index_codcomp  :=   null;
    end;

    begin
      select folder
        into ctrl_folder
        from tfolderd
       where codapp = 'HRES32E';
    exception when no_data_found then
      null;
    end;
  end;
 --
  procedure check_event(json_str clob,event_flg out varchar2) as
   json_obj        json_object_t := json_object_t(json_str);
  begin
   event_flg := hcm_util.get_string_t(json_obj,'flg');
  end;

  function gen_index_data return clob as
    obj_row     json_object_t;
    obj_data    json_object_t;
    json_str_output  clob;
    v_codapp	varchar2(15 char) := 'HRMS32E';
    v_num       number := 0;
    v_where     varchar2(500 char);
    v_rcnt      number := 0;
    flg_secur   boolean ;
    v_zupdsal   varchar2(1 char);
    v_concat    varchar2(1 char);

    v_dte  		date := sysdate + 100;
    v_dtype 	varchar2(1 char) := '@';

    type typ_ is table of varchar2(250 char) index by binary_integer;
    v_type    typ_;

  --Cursor
    cursor c1 is
      select a.codempid,a.dtereq,a.typchg typ,a.numseq,
             a.staappr,a.codappr,a.remarkap,a.codinput,
             a.dteinput,a.dtecancel,a.approvno
        from tempch a, temploy1 b
       where a.codempid = b.codempid(+)
         and a.codempid like nvl(b_index_codempid,a.codempid)
         and a.codcomp like b_index_codcomp||'%'
         and a.dtereq between nvl(b_index_dtereq_st,a.dtereq) and nvl(b_index_dtereq_en,a.dtereq)
         and (a.codempid = global_v_codempid or
             (a.codempid <> global_v_codempid
               and b.numlvl between global_v_zminlvl and global_v_zwrklvl
               and 0 <> (select count(ts.codcomp)
                           from tusrcom ts
                          where ts.coduser = global_v_coduser
                            and b.codcomp like ts.codcomp||'%'
                            and rownum    <= 1 )))
    order by a.dtereq desc,typ,a.numseq;

  begin
    hres32e_check_index;
    if param_msg_error is null then
      obj_row  := json_object_t();

      v_type(1)  := get_label_name('HRES32EC1',global_v_lang,60);
      v_type(2)  := get_label_name('HRES32EC1',global_v_lang,70);
      v_type(3)  := get_label_name('HRES32EC1',global_v_lang,80);
      v_type(4)  := get_label_name('HRES32EC1',global_v_lang,90);
      v_type(5)  := get_label_name('HRES32EC1',global_v_lang,100);
      v_type(6)  := get_label_name('HRES32EC1',global_v_lang,110);
      v_type(7)  := get_label_name('HRES32ET7',global_v_lang,10);
      for i in c1 loop
        v_num := v_num + 1;

--        if v_dte <> i.dtereq then
--          :data.dtereq := i.dtereq;
--          v_dte        := i.dtereq;
--        end if;

        if v_dtype <> i.typ then
          index_desc_type := v_type(i.typ);
          v_dtype         := i.typ;
        end if;
          index_codempid      := global_v_codempid;
          index_desc_codempid := get_temploy_name(global_v_codempid,global_v_lang);
          index_codempid_query := i.codempid;
          index_desc_codempid_query := get_temploy_name(i.codempid,global_v_lang);
          index_dtereq        := i.dtereq;
          index_type          := i.typ;
          index_numseq        := i.numseq;
          index_status        := get_tlistval_name('ESSTAREQ', i.staappr,global_v_lang);
          index_remarkap      := replace(i.remarkap,chr(13)||chr(10),' ');
          index_codappr       := i.codappr ||' '||get_temploy_name(i.codappr,global_v_lang);
          index_next_appr     := chk_workflow.get_next_approve('HRES32E',i.codempid,to_char(i.dtereq,'dd/mm/yyyy'),i.numseq,i.approvno,global_v_lang);
          index_staappr       := i.staappr;
          index_codinput      := i.codinput;
          index_dteinput      := i.dteinput;
          index_dtecancel     := i.dtecancel;
          index_codapp        := v_codapp;

          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', ' ');
          obj_data.put('flg', ' ');
          -- display data
          obj_data.put('total',to_char(v_rcnt));
          obj_data.put('rcnt',to_char(v_num));
          obj_data.put('codempid',nvl(index_codempid,' '));
          obj_data.put('desc_codempid',nvl(index_desc_codempid,' '));
          obj_data.put('codempid_query',nvl(index_codempid_query,' '));
          obj_data.put('desc_codempid_query',nvl(index_desc_codempid_query,' '));
          obj_data.put('dtereq',nvl(to_char(index_dtereq,'dd/mm/yyyy'),' '));
          obj_data.put('typchg',nvl(index_type,' '));
          obj_data.put('desc_typchg',nvl(index_desc_type,' '));
          obj_data.put('numseq',nvl(to_char(index_numseq),' '));
          obj_data.put('status',nvl(index_status,' '));
          obj_data.put('remarkap',nvl(index_remarkap,' '));
          obj_data.put('codappr',nvl(index_codappr,' '));
          obj_data.put('next_appr',nvl(index_next_appr,' '));
          obj_data.put('staappr',nvl(index_staappr,' '));
          obj_data.put('codinput',nvl(index_codinput,' '));
          obj_data.put('dteinput',nvl(to_char(index_dteinput,'dd/mm/yyyy'),' '));
          obj_data.put('dtecancel',nvl(to_char(index_dtecancel,'dd/mm/yyyy'),' '));
          obj_data.put('codapp',nvl(index_codapp,' '));
          obj_row.put(to_char(v_num-1),obj_data);
      end loop;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return json_str_output;
    end if;
    json_str_output := obj_row.to_clob;

    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end;

  --  hres32e_detail_tab1
  function get_tnamech return clob is
    obj_row               json_object_t;
    json_str_output       clob;
    v_rcnt                number := 0;
    v_num                 number := 0;
    v_concat              varchar2(1 char);
    tab1_n_codtitle_flg   varchar2(20 char)   := 'N';
    tab1_n_name_flg       varchar2(20 char)   := 'N';
    tab1_n_last_flg       varchar2(20 char)   := 'N';
    tab1_n_nick_flg       varchar2(20 char)   := 'N';
    global_v_codapp       varchar2(4000 char) := 'HRES32E_DETAIL_TAB1';
    v_name                temploy1.namfirste%type;
    v_last                temploy1.namlaste%type;
    v_nick                temploy1.nickname%type;
  -- Cursor
  cursor c_temploy1 is
    select codtitle,namfirste,namfirstt,namfirst3,namfirst4,
           namfirst5,namlaste,namlastt,namlast3,namlast4,namlast5,
           nickname,nicknamt,nicknam3,nicknam4,nicknam5
      from temploy1
     where codempid = b_index_codempid;

  cursor c_temeslog1 is
    select fldedit,desnew
      from temeslog1
     where codempid = b_index_codempid
       and dtereq   = b_index_dtereq
       and numseq   = b_index_numseq
       and numpage  = 11;
    --
    begin
      for i in c_temploy1 loop
        tab1_codtitle     := i.codtitle;
        tab1_namfirste    := i.namfirste;
        tab1_namfirstt    := i.namfirstt;
        tab1_namfirst3    := i.namfirst3;
        tab1_namfirst4    := i.namfirst4;
        tab1_namfirst5    := i.namfirst5;
        tab1_namlaste     := i.namlaste;
        tab1_namlastt     := i.namlastt;
        tab1_namlast3     := i.namlast3;
        tab1_namlast4     := i.namlast4;
        tab1_namlast5     := i.namlast5;
        tab1_nickname     := i.nickname;
        tab1_nicknamt     := i.nicknamt;
        tab1_nicknam3     := i.nicknam3;
        tab1_nicknam4     := i.nicknam4;
        tab1_nicknam5     := i.nicknam5;
      end loop;

      begin
        select desnote,staappr,dteinput,dtecancel
          into tab1_desnote,tab1_staappr,tab1_dteinput,tab1_dtecancel
          from tempch
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numseq   = b_index_numseq
           and typchg   = 1;
      exception when no_data_found then
        tab1_staappr := 'P';
        tab1_desnote := null;
      end;

      tab1_p_codtitle := tab1_codtitle;
      if global_v_lang = '101' then
        tab1_p_name  := tab1_namfirste;
        tab1_p_last  := tab1_namlaste;
        tab1_p_nick  := tab1_nickname;
        v_name       := tab1_namfirste;
        v_last       := tab1_namlaste;
        v_nick       := tab1_nickname;
      elsif global_v_lang = '102' then
        tab1_p_name  := tab1_namfirstt;
        tab1_p_last  := tab1_namlastt;
        tab1_p_nick  := tab1_nicknamt;
        v_name       := tab1_namfirstt;
        v_last       := tab1_namlastt;
        v_nick       := tab1_nicknamt;
      elsif global_v_lang = '103' then
        tab1_p_name  := tab1_namfirst3;
        tab1_p_last  := tab1_namlast3;
        tab1_p_nick  := tab1_nicknam3;
        v_name       := tab1_namfirst3;
        v_last       := tab1_namlast3;
        v_nick       := tab1_nicknam3;
      elsif global_v_lang = '104' then
        tab1_p_name  := tab1_namfirst4;
        tab1_p_last  := tab1_namlast4;
        tab1_p_nick  := tab1_nicknam4;
        v_name       := tab1_namfirst4;
        v_last       := tab1_namlast4;
        v_nick       := tab1_nicknam4;
      elsif global_v_lang = '105' then
        tab1_p_name  := tab1_namfirst5;
        tab1_p_last  := tab1_namlast5;
        tab1_p_nick  := tab1_nicknam5;
        v_name       := tab1_namfirst5;
        v_last       := tab1_namlast5;
        v_nick       := tab1_nicknam5;
      end if;
      --
      for i in c_temeslog1 loop
        if i.fldedit = 'CODTITLE' then
          tab1_n_codtitle := i.desnew ;
          tab1_n_codtitle_flg := 'Y';
--<< user28 || 12/03/2019 || redmind #6317
        elsif i.fldedit = 'NAMFIRSTE' then
          tab1_n_namee     := i.desnew ;
          tab1_n_name      := i.desnew ;
          tab1_n_name_flg := 'Y';
        elsif i.fldedit = 'NAMFIRSTT' then
          tab1_n_namet     := i.desnew ;
          tab1_n_name      := i.desnew ;
          tab1_n_name_flg := 'Y';
-->> user28 || 12/03/2019 || redmind #6317
        elsif i.fldedit = 'NAMFIRST3' then
          tab1_n_name3     := i.desnew ;
          tab1_n_name      := i.desnew ;
          tab1_n_name_flg := 'Y';
        elsif i.fldedit = 'NAMFIRST4' then
          tab1_n_name4     := i.desnew ;
          tab1_n_name      := i.desnew ;
          tab1_n_name_flg := 'Y';
        elsif i.fldedit = 'NAMFIRST5' then
          tab1_n_name5     := i.desnew ;
          tab1_n_name      := i.desnew ;
          tab1_n_name_flg := 'Y';
        elsif i.fldedit = 'NAMLASTE' then
          tab1_n_laste     := i.desnew ;
          tab1_n_last      := i.desnew ;
          tab1_n_last_flg := 'Y';
        elsif i.fldedit = 'NAMLASTT' then
          tab1_n_lastt     := i.desnew ;
          tab1_n_last      := i.desnew ;
          tab1_n_last_flg := 'Y';
        elsif i.fldedit = 'NAMLAST3' then
          tab1_n_last3     := i.desnew ;
          tab1_n_last      := i.desnew ;
          tab1_n_last_flg := 'Y';
        elsif i.fldedit = 'NAMLAST4' then
          tab1_n_last4     := i.desnew ;
          tab1_n_last      := i.desnew ;
          tab1_n_last_flg := 'Y';
        elsif i.fldedit = 'NAMLAST5' then
          tab1_n_last5     := i.desnew ;
          tab1_n_last      := i.desnew ;
          tab1_n_last_flg := 'Y';
        elsif i.fldedit = 'NICKNAME' then
          tab1_n_nicke     := i.desnew ;
          tab1_n_nick      := i.desnew ;
          tab1_n_nick_flg  := i.desnew ;
        elsif i.fldedit = 'NICKNAMT' then
          tab1_n_nickt     := i.desnew ;
          tab1_n_nick      := i.desnew ;
          tab1_n_nick_flg  := i.desnew ;
        elsif i.fldedit = 'NICKNAM3' then
          tab1_n_nick3     := i.desnew ;
          tab1_n_nick      := i.desnew ;
          tab1_n_nick_flg  := i.desnew ;
        elsif i.fldedit = 'NICKNAM4' then
          tab1_n_nick4     := i.desnew ;
          tab1_n_nick      := i.desnew ;
          tab1_n_nick_flg  := i.desnew ;
        elsif i.fldedit = 'NICKNAM5' then
          tab1_n_nick5     := i.desnew ;
          tab1_n_nick      := i.desnew ;
          tab1_n_nick_flg  := i.desnew ;
        end if;
      end loop;

      obj_row := json_object_t();
      obj_row.put('coderror','200');
      obj_row.put('desc_coderror','');
      obj_row.put('httpcode','');
      obj_row.put('flg','');
      obj_row.put('codtitle',tab1_codtitle);
      obj_row.put('desc_codtitle',get_tlistval_name('CODTITLE',tab1_codtitle,global_v_lang));
--      obj_row.put('n_codtitle',tab1_n_codtitle);
      obj_row.put('n_codtitle',tab1_p_codtitle);
      --<< user28 || 12/03/2019 || redmind #6317
      obj_row.put('name',v_name);
      obj_row.put('namee',tab1_namfirste);
      obj_row.put('namet',tab1_namfirstt);
      obj_row.put('name3',tab1_namfirst3);
      obj_row.put('name4',tab1_namfirst4);
      obj_row.put('name5',tab1_namfirst5);
      obj_row.put('last',v_last);
      obj_row.put('laste',tab1_namlaste);
      obj_row.put('lastt',tab1_namlastt);
      obj_row.put('last3',tab1_namlast3);
      obj_row.put('last4',tab1_namlast4);
      obj_row.put('last5',tab1_namlast5);
      obj_row.put('nick',v_nick);
      obj_row.put('nicke',tab1_nickname);
      obj_row.put('nickt',tab1_nicknamt);
      obj_row.put('nick3',tab1_nicknam3);
      obj_row.put('nick4',tab1_nicknam4);
      obj_row.put('nick5',tab1_nicknam5);
      obj_row.put('n_name',tab1_n_name);
      obj_row.put('n_namee',tab1_n_namee);
      obj_row.put('n_namet',tab1_n_namet);
      obj_row.put('n_name3',tab1_n_name3);
      obj_row.put('n_name4',tab1_n_name4);
      obj_row.put('n_name5',tab1_n_name5);
      obj_row.put('n_last',tab1_n_last);
      obj_row.put('n_laste',tab1_n_laste);
      obj_row.put('n_lastt',tab1_n_lastt);
      obj_row.put('n_last3',tab1_n_last3);
      obj_row.put('n_last4',tab1_n_last4);
      obj_row.put('n_last5',tab1_n_last5);
      obj_row.put('n_nick',tab1_n_nick);
      obj_row.put('n_nicke',tab1_n_nicke);
      obj_row.put('n_nickt',tab1_n_nickt);
      obj_row.put('n_nick3',tab1_n_nick3);
      obj_row.put('n_nick4',tab1_n_nick4);
      obj_row.put('n_nick5',tab1_n_nick5);
      -->> user28 || 12/03/2019 || redmind #6317
      obj_row.put('desnote',tab1_desnote);
      obj_row.put('n_codtitle_flg',tab1_n_codtitle_flg);
      obj_row.put('n_name_flg',tab1_n_name_flg);
      obj_row.put('n_last_flg',tab1_n_last_flg);

      json_str_output := obj_row.to_clob;
      return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_tnamech;

  --  hres32e_detail_tab2
  function get_address return clob as
    obj_row                 json_object_t;
    json_str_output         clob;
    v_rcnt                  number := 0;
    v_num                   number := 0;
    v_concat                varchar2(1 char);
    --
    tab2_stamilit_flg       varchar2(10 char) := 'N';
    tab2_adrrege_flg        varchar2(10 char) := 'N';
    tab2_adrregt_flg        varchar2(10 char) := 'N';
    tab2_adrreg3_flg        varchar2(10 char) := 'N';
    tab2_adrreg4_flg        varchar2(10 char) := 'N';
    tab2_adrreg5_flg        varchar2(10 char) := 'N';
    tab2_codsubdistr_flg    varchar2(10 char) := 'N';
    tab2_coddistr_flg       varchar2(10 char) := 'N';
    tab2_codprovr_flg       varchar2(10 char) := 'N';
    tab2_codcntyr_flg       varchar2(10 char) := 'N';
    tab2_codpostr_flg       varchar2(10 char) := 'N';
    tab2_adrconte_flg       varchar2(10 char) := 'N';
    tab2_adrcontt_flg       varchar2(10 char) := 'N';
    tab2_adrcont3_flg       varchar2(10 char) := 'N';
    tab2_adrcont4_flg       varchar2(10 char) := 'N';
    tab2_adrcont5_flg       varchar2(10 char) := 'N';
    tab2_codsubdistc_flg    varchar2(10 char) := 'N';
    tab2_coddistc_flg       varchar2(10 char) := 'N';
    tab2_codprovc_flg       varchar2(10 char) := 'N';
    tab2_codcntyc_flg       varchar2(10 char) := 'N';
    tab2_codpostc_flg       varchar2(10 char) := 'N';
    tab2_numtelec_flg       varchar2(10 char) := 'N';
    tab2_numoffid_flg       varchar2(10 char) := 'N';
    tab2_adrissue_flg       varchar2(10 char) := 'N';
    tab2_codprovi_flg       varchar2(10 char) := 'N';
    tab2_dteoffid_flg       varchar2(10 char) := 'N';
    tab2_numlicid_flg       varchar2(10 char) := 'N';
    tab2_dtelicid_flg       varchar2(10 char) := 'N';
    tab2_numpasid_flg       varchar2(10 char) := 'N';
    tab2_dtepasid_flg       varchar2(10 char) := 'N';
    tab2_numprmid_flg       varchar2(10 char) := 'N';
    tab2_dteprmst_flg       varchar2(10 char) := 'N';
    tab2_dteprmen_flg       varchar2(10 char) := 'N';
    tab2_stamarry_flg       varchar2(10 char) := 'N';
    tab2_email_emp_flg      varchar2(10 char) := 'N';
    tab2_nummobile_flg      varchar2(10 char) := 'N';
    tab2_lineid_flg         varchar2(10 char) := 'N';
    tab2_numvisa_flg        varchar2(10 char) := 'N';
    tab2_dtevisaexp_flg     varchar2(10 char) := 'N';
    tab2_codclnsc_flg       varchar2(10 char) := 'N';
    tab2_dteretire_flg      varchar2(10 char) := 'N';
    tab2_codbank_flg        varchar2(10 char) := 'N';
    tab2_numbank_flg        varchar2(10 char) := 'N';
    tab2_numbrnch_flg       varchar2(10 char) := 'N';
    tab2_codbank2_flg       varchar2(10 char) := 'N';
    tab2_numbank2_flg       varchar2(10 char) := 'N';
    tab2_numbrnch2_flg      varchar2(10 char) := 'N';
    tab2_amtbank_flg        varchar2(10 char) := 'N';
    tab2_amttranb_flg       varchar2(10 char) := 'N';
    tab2_qtychedu_flg       varchar2(10 char) := 'N';
    tab2_qtychned_flg       varchar2(10 char) := 'N';
    tab2_namspe_flg         varchar2(10 char) := 'N';
    tab2_namspt_flg         varchar2(10 char) := 'N';
    tab2_namsp3_flg         varchar2(10 char) := 'N';
    tab2_namsp4_flg         varchar2(10 char) := 'N';
    tab2_namsp5_flg         varchar2(10 char) := 'N';
    tab2_numspid_flg        varchar2(10 char) := 'N';
    tab2_dtespbd_flg        varchar2(10 char) := 'N';
    tab2_codspocc_flg       varchar2(10 char) := 'N';
    tab2_desnoffi_flg       varchar2(10 char) := 'N';
    tab2_dtemarry_flg       varchar2(10 char) := 'N';
    tab2_desplreg_flg       varchar2(10 char) := 'N';
    tab2_codsppro_flg       varchar2(10 char) := 'N';
    tab2_codspcty_flg       varchar2(10 char) := 'N';
    tab2_desnote_flg        varchar2(10 char) := 'N';
    tab2_codtitle_flg       varchar2(10 char) := 'N';
    tab2_namfirste_flg      varchar2(10 char) := 'N';
    tab2_namfirstt_flg      varchar2(10 char) := 'N';
    tab2_namfirst3_flg      varchar2(10 char) := 'N';
    tab2_namfirst4_flg      varchar2(10 char) := 'N';
    tab2_namfirst5_flg      varchar2(10 char) := 'N';
    tab2_namlaste_flg       varchar2(10 char) := 'N';
    tab2_namlastt_flg       varchar2(10 char) := 'N';
    tab2_namlast3_flg       varchar2(10 char) := 'N';
    tab2_namlast4_flg       varchar2(10 char) := 'N';
    tab2_namlast5_flg       varchar2(10 char) := 'N';
    tab2_codempidsp_flg     varchar2(10 char)   := 'N';
    tab2_stalife_flg        varchar2(10 char)   := 'N';
    tab2_dtedthsp_flg       varchar2(10 char)   := 'N';
    tab2_staincom_flg       varchar2(10 char)   := 'N';
    tab2_numfasp_flg        varchar2(10 char)   := 'N';
    tab2_nummosp_flg        varchar2(10 char)   := 'N';
    tab2_filename_flg       varchar2(10 char)   := 'N';
    tab2_typtrav_flg        varchar2(10 char)   := 'N';
    tab2_qtylength_flg      varchar2(10 char)   := 'N';
    tab2_carlicen_flg       varchar2(10 char)   := 'N';
    tab2_typfuel_flg        varchar2(10 char)   := 'N';
    tab2_codbusno_flg       varchar2(10 char)   := 'N';
    tab2_codbusrt_flg       varchar2(10 char)   := 'N';
    --Cursor
    cursor c_temeslog1 is
    select *
      from temeslog1
     where codempid = b_index_codempid
       and dtereq   = b_index_dtereq
       and numseq   = b_index_numseq
       and numpage  like '2%';

  begin
    begin
      select stamilit,adrrege,adrregt,adrreg3,adrreg4,
             adrreg5,codsubdistr,coddistr,codprovr,codcntyr,
             codpostr,adrconte,adrcontt,adrcont3,adrcont4,
             adrcont5,codsubdistc,coddistc,codprovc,codcntyc,
             codpostc,numtelec,numoffid,adrissue,codprovi,
             dteoffid,numlicid,dtelicid,numpasid,dtepasid,
             numprmid,dteprmst,dteprmen,b.stamarry,b.email,
             b.nummobile,b.lineid,a.numvisa,a.codclnsc,b.dteretire,
             b.typtrav,b.carlicen,b.typfuel,b.qtylength,b.codbusno,b.codbusrt
      into   tab2_stamilit,tab2_adrrege,tab2_adrregt,tab2_adrreg3,tab2_adrreg4,
             tab2_adrreg5,tab2_codsubdistr,tab2_coddistr,tab2_codprovr,tab2_codcntyr,
             tab2_codpostr,tab2_adrconte,tab2_adrcontt,tab2_adrcont3,tab2_adrcont4,
             tab2_adrcont5,tab2_codsubdistc,tab2_coddistc,tab2_codprovc,tab2_codcntyc,
             tab2_codpostc,tab2_numtelec,tab2_numoffid,tab2_adrissue,tab2_codprovi,
             tab2_dteoffid,tab2_numlicid,tab2_dtelicid,tab2_numpasid,tab2_dtepasid,
             tab2_numprmid,tab2_dteprmst,tab2_dteprmen,tab2_stamarry,tab2_email_emp,
             tab2_nummobile,tab2_lineid,tab2_numvisa,tab2_codclnsc,tab2_dteretire,
             tab2_typtrav,tab2_carlicen,tab2_typfuel,tab2_qtylength,tab2_codbusno,tab2_codbusrt
        from temploy2 a,temploy1 b
       where b.codempid = b_index_codempid
         and a.codempid (+)= b.codempid;
      exception when no_data_found then
        tab2_stamilit	:= null;    tab2_adrrege	:= null;      tab2_adrregt	:= null;
        tab2_adrreg3	:= null;    tab2_adrreg4	:= null;      tab2_adrreg5	:= null;
        tab2_codsubdistr := null; tab2_coddistr	:= null;      tab2_codprovr	:= null;
        tab2_codcntyr	:= null;    tab2_codpostr	:= null;      tab2_adrconte	:= null;
        tab2_adrcontt	:= null;    tab2_adrcont3	:= null;      tab2_adrcont4	:= null;
        tab2_adrcont5	:= null;    tab2_codsubdistc	:= null;  tab2_coddistc	:= null;
        tab2_codprovc	:= null;    tab2_codcntyc	:= null;      tab2_codpostc	:= null;
        tab2_numtelec	:= null;    tab2_numoffid	:= null;      tab2_adrissue	:= null;
        tab2_codprovi	:= null;    tab2_dteoffid	:= null;      tab2_numlicid	:= null;
        tab2_dtelicid	:= null;    tab2_numpasid	:= null;      tab2_dtepasid	:= null;
        tab2_numprmid	:= null;    tab2_dteprmst	:= null;      tab2_dteprmen	:= null;
        tab2_stamarry	:= null;    tab2_email_emp:= null;      tab2_nummobile := null;
        tab2_lineid   := null;    tab2_numvisa  := null;      tab2_codclnsc := null;
        tab2_dteretire  := null;  tab2_typtrav  := null;      tab2_qtylength := null;
        tab2_carlicen := null;    tab2_typfuel  := null;      tab2_codbusno  := null;
        tab2_codbusrt := null;
      end;

      begin
        select codbank,numbank,codbank2,numbank2,amtbank,
               qtychedu,qtychned,stddec(amttranb,b_index_codempid,v_chken),numbrnch,numbrnch2
        into   tab2_codbank,tab2_numbank,tab2_codbank2,tab2_numbank2,tab2_amtbank,
               tab2_qtychedu,tab2_qtychned,tab2_amttranb,tab2_numbrnch,tab2_numbrnch2
        from   temploy3
        where  codempid  = b_index_codempid ;
      exception when no_data_found then
        null;
      end;

      begin
         select
--                namspous,numoffid,dtespbd,codspocc,replace(desnoffi, CHR(10), ' '),
--                dtemarry,desplreg,codsppro,codspcty,desnote,codtitle,namfirst,namlast,
                codempidsp,namimgsp,codtitle,
                namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                namlaste,namlastt,namlast3,namlast4,namlast5,
                namspe,namspt,namsp3,namsp4,namsp5,
                numoffid,numtaxid,codspocc,dtespbd,stalife,staincom,
                dtedthsp,desnoffi,numfasp,nummosp,dtemarry,
                codsppro,codspcty,desplreg,desnote,filename,numrefdoc
--         into   tab2_namspous,tab2_numspid,tab2_dtespbd,tab2_codspocc,tab2_desnoffi,
--                tab2_dtemarry,tab2_desplreg,tab2_codsppro,tab2_codspcty,tab2_desnote,
--                tab2_codtitle,tab2_namfirst,tab2_namlast
         into   tab2_codempidsp,tab2_namimgsp,tab2_codtitle,
                tab2_namfirste,tab2_namfirstt,tab2_namfirst3,tab2_namfirst4,tab2_namfirst5,
                tab2_namlaste,tab2_namlastt,tab2_namlast3,tab2_namlast4,tab2_namlast5,
                tab2_namspe,tab2_namspt,tab2_namsp3,tab2_namsp4,tab2_namsp5,
                tab2_numspid,--User37 #1923 Final Test Phase 1 V11 24/03/2021 tab2_numoffid,
                tab2_numtaxid,tab2_codspocc,tab2_dtespbd,tab2_stalife,tab2_staincom,
                tab2_dtedthsp,tab2_desnoffi,tab2_numfasp,tab2_nummosp,tab2_dtemarry,
                tab2_codsppro,tab2_codspcty,tab2_desplreg,tab2_desnote,tab2_filename,tab2_numrefdoc
         from   tspouse
         where  codempid  = b_index_codempid ;
      exception when no_data_found then
          null;
      END ;
      --
      for i in c_temeslog1 loop
        if i.fldedit = 'STAMILIT' then
          tab2_stamilit := i.desnew;
          tab2_stamilit_flg := 'Y';
        elsif i.fldedit = 'ADRREGE' then
          tab2_adrrege  := i.desnew;
          tab2_adrrege_flg := 'Y';
        elsif i.fldedit = 'ADRREGT' then
          tab2_adrregt  := i.desnew;
          tab2_adrregt_flg := 'Y';
        elsif i.fldedit = 'ADRREG3' then
          tab2_adrreg3  := i.desnew;
          tab2_adrreg3_flg := 'Y';
        elsif i.fldedit = 'ADRREG4' then
          tab2_adrreg4  := i.desnew;
          tab2_adrreg4_flg := 'Y';
        elsif i.fldedit = 'ADRREG5' then
          tab2_adrreg5  := i.desnew;
          tab2_adrreg5_flg := 'Y';
        elsif i.fldedit = 'CODSUBDISTR' then
          tab2_codsubdistr  := i.desnew;
          tab2_codsubdistr_flg := 'Y';
        elsif i.fldedit = 'CODDISTR' then
          tab2_coddistr  := i.desnew;
          tab2_coddistr_flg := 'Y';
        elsif i.fldedit = 'CODPROVR' then
          tab2_codprovr  := i.desnew;
          tab2_codprovr_flg := 'Y';
        elsif i.fldedit = 'CODCNTYR' then
          tab2_codcntyr  := i.desnew;
          tab2_codcntyr_flg := 'Y';
        elsif i.fldedit = 'CODPOSTR' then
          tab2_codpostr  := i.desnew;
          tab2_codpostr_flg := 'Y';
        elsif i.fldedit = 'ADRCONTE' then
          tab2_adrconte  := i.desnew;
          tab2_adrconte_flg := 'Y';
        elsif i.fldedit = 'ADRCONTT' then
          tab2_adrcontt  := i.desnew;
          tab2_adrcontt_flg := 'Y';
        elsif i.fldedit = 'ADRCONT3' then
          tab2_adrcont3  := i.desnew;
          tab2_adrcont3_flg := 'Y';
        elsif i.fldedit = 'ADRCONT4' then
          tab2_adrcont4  := i.desnew;
          tab2_adrcont4_flg := 'Y';
        elsif i.fldedit = 'ADRCONT5' then
          tab2_adrcont5  := i.desnew;
          tab2_adrcont5_flg := 'Y';
        elsif i.fldedit = 'CODSUBDISTC' then
          tab2_codsubdistc  := i.desnew;
          tab2_codsubdistc_flg := 'Y';
        elsif i.fldedit = 'CODDISTC' then
          tab2_coddistc  := i.desnew;
          tab2_coddistc_flg := 'Y';
        elsif i.fldedit = 'CODPROVC' then
          tab2_codprovc  := i.desnew;
          tab2_codprovc_flg := 'Y';
        elsif i.fldedit = 'CODCNTYC' then
          tab2_codcntyc  := i.desnew;
          tab2_codcntyc_flg := 'Y';
        elsif i.fldedit = 'CODPOSTC' then
          tab2_codpostc  := i.desnew;
          tab2_codpostc_flg := 'Y';
        elsif i.fldedit = 'NUMTELEC' then
          tab2_numtelec  := i.desnew;
          tab2_numtelec_flg := 'Y';
        elsif i.fldedit = 'NUMOFFID' then
          tab2_numoffid  := i.desnew;
          tab2_numoffid_flg := 'Y';
        elsif i.fldedit = 'ADRISSUE' then
          tab2_adrissue  := i.desnew;
          tab2_adrissue_flg := 'Y';
        elsif i.fldedit = 'CODPROVI' then
          tab2_codprovi  := i.desnew;
          tab2_codprovi_flg := 'Y';
        elsif i.fldedit = 'DTEOFFID' then
          tab2_dteoffid  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dteoffid_flg := 'Y';
        elsif i.fldedit = 'NUMLICID' then
          tab2_numlicid  := i.desnew;
          tab2_numlicid_flg := 'Y';
        elsif i.fldedit = 'DTELICID' then
          tab2_dtelicid  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dtelicid_flg := 'Y';
        elsif i.fldedit = 'NUMPASID' then
          tab2_numpasid  := i.desnew;
          tab2_numpasid_flg := 'Y';
        elsif i.fldedit = 'DTEPASID' then
          tab2_dtepasid  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dtepasid_flg := 'Y';
        elsif i.fldedit = 'NUMPRMID' then
          tab2_numprmid  := i.desnew;
          tab2_numprmid_flg := 'Y';
        elsif i.fldedit = 'DTEPRMST' then
          tab2_dteprmst  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dteprmst_flg := 'Y';
        elsif i.fldedit = 'DTEPRMEN' then
          tab2_dteprmen  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dteprmen_flg := 'Y';
        elsif i.fldedit = 'STAMARRY' then
          tab2_stamarry  := i.desnew;
          tab2_stamarry_flg := 'Y';
        elsif i.fldedit = 'EMAIL_EMP' then
          tab2_email_emp  := i.desnew;
          tab2_email_emp_flg := 'Y';
        elsif i.fldedit = 'NUMMOBILE' then
          tab2_nummobile  := i.desnew;
          tab2_nummobile_flg := 'Y';
        elsif i.fldedit = 'LINEID' then
          tab2_lineid  := i.desnew;
          tab2_lineid_flg := 'Y';
        elsif i.fldedit = 'NUMVISA' then
          tab2_numvisa  := i.desnew;
          tab2_numvisa_flg := 'Y';
        elsif i.fldedit = 'DTEVISAEXP' then
          tab2_dtevisaexp  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dtevisaexp_flg := 'Y';
        elsif i.fldedit = 'CODCLNSC' then
          tab2_codclnsc  := i.desnew;
          tab2_codclnsc_flg := 'Y';
        elsif i.fldedit = 'DTERETIRE' then
          tab2_dteretire  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dteretire_flg := 'Y';
        elsif i.fldedit = 'CODBANK' then
          tab2_codbank  := i.desnew;
          tab2_codbank_flg := 'Y';
        elsif i.fldedit = 'NUMBANK' then
          tab2_numbank  := i.desnew;
          tab2_numbank_flg := 'Y';
        elsif i.fldedit = 'NUMBRNCH' then
          tab2_numbrnch  := i.desnew;
          tab2_numbrnch_flg := 'Y';
        elsif i.fldedit = 'CODBANK2' then
          tab2_codbank2  := i.desnew;
          tab2_codbank2_flg := 'Y';
        elsif i.fldedit = 'NUMBANK2' then
          tab2_numbank2  := i.desnew;
          tab2_numbank2_flg := 'Y';
        elsif i.fldedit = 'NUMBRNCH2' then
          tab2_numbrnch2  := i.desnew;
          tab2_numbrnch2_flg := 'Y';
        elsif i.fldedit = 'AMTBANK' then
          tab2_amtbank  := i.desnew;
          tab2_amtbank_flg := 'Y';
        elsif i.fldedit = 'AMTTRANB' then
          tab2_amttranb  := stddec(i.desnew,b_index_codempid,v_chken);
          tab2_amttranb_flg := 'Y';
        elsif i.fldedit = 'QTYCHEDU' then
          tab2_qtychedu  := i.desnew;
          tab2_qtychedu_flg := 'Y';
        elsif i.fldedit = 'QTYCHNED' then
          tab2_qtychned  := i.desnew;
          tab2_qtychned_flg := 'Y';
        elsif i.fldedit = 'NAMSPE' then
          tab2_namspe  := i.desnew;
          tab2_namspe_flg := 'Y';
        elsif i.fldedit = 'NAMSPT' then
          tab2_namspt  := i.desnew;
          tab2_namspt_flg := 'Y';
        elsif i.fldedit = 'NAMSP3' then
          tab2_namsp3  := i.desnew;
          tab2_namsp3_flg := 'Y';
        elsif i.fldedit = 'NAMSP4' then
          tab2_namsp4  := i.desnew;
          tab2_namsp4_flg := 'Y';
        elsif i.fldedit = 'NAMSP5' then
          tab2_namsp5  := i.desnew;
          tab2_namsp5_flg := 'Y';
        elsif i.fldedit = 'NUMSPID' then
          tab2_numspid  := i.desnew;
          tab2_numspid_flg := 'Y';
        elsif i.fldedit = 'DTESPBD' then
          tab2_dtespbd  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dtespbd_flg := 'Y';
        elsif i.fldedit = 'CODSPOCC' then
          tab2_codspocc  := i.desnew;
          tab2_codspocc_flg := 'Y';
        elsif i.fldedit = 'DESNOFFI' then
          tab2_desnoffi  := i.desnew;
          tab2_desnoffi_flg := 'Y';
        elsif i.fldedit = 'DTEMARRY' then
          tab2_dtemarry  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dtemarry_flg := 'Y';
        elsif i.fldedit = 'DESPLREG' then
          tab2_desplreg  := i.desnew;
          tab2_desplreg_flg := 'Y';
        elsif i.fldedit = 'CODSPPRO' then
          tab2_codsppro  := i.desnew;
          tab2_codsppro_flg := 'Y';
        elsif i.fldedit = 'CODSPCTY' then
          tab2_codspcty  := i.desnew;
          tab2_codspcty_flg := 'Y';
        elsif i.fldedit = 'DESNOTE' then
          tab2_desnote  := i.desnew;
          tab2_desnote_flg := 'Y';
        elsif i.fldedit = 'FILENAME' then
          tab2_filename     := i.desnew;
          tab2_filename_flg := 'Y';
        elsif i.fldedit = 'CODTITLE' then
          tab2_codtitle   := i.desnew;
          tab2_codtitle_flg := 'Y';
        elsif i.fldedit = 'NAMFIRSTE' then
          tab2_namfirste  := i.desnew;
          tab2_namfirste_flg := 'Y';
        elsif i.fldedit = 'NAMFIRSTT' then
          tab2_namfirstt  := i.desnew;
          tab2_namfirstt_flg := 'Y';
        elsif i.fldedit = 'NAMFIRST3' then
          tab2_namfirst3  := i.desnew;
          tab2_namfirst3_flg := 'Y';
        elsif i.fldedit = 'NAMFIRST4' then
          tab2_namfirst4  := i.desnew;
          tab2_namfirst4_flg := 'Y';
        elsif i.fldedit = 'NAMFIRST5' then
          tab2_namfirst5  := i.desnew;
          tab2_namfirst5_flg := 'Y';
        elsif i.fldedit = 'NAMLASTE' then
          tab2_namlaste  := i.desnew;
          tab2_namlaste_flg := 'Y';
        elsif i.fldedit = 'NAMLASTT' then
          tab2_namlastt  := i.desnew;
          tab2_namlastt_flg := 'Y';
        elsif i.fldedit = 'NAMLAST3' then
          tab2_namlast3  := i.desnew;
          tab2_namlast3_flg := 'Y';
        elsif i.fldedit = 'NAMLAST4' then
          tab2_namlast4  := i.desnew;
          tab2_namlast4_flg := 'Y';
        elsif i.fldedit = 'NAMLAST5' then
          tab2_namlast5  := i.desnew;
          tab2_namlast5_flg := 'Y';
        elsif i.fldedit = 'CODEMPIDSP' then
          tab2_codempidsp  := i.desnew;
          tab2_codempidsp_flg := 'Y';
        elsif i.fldedit = 'STALIFE' then
          tab2_stalife  := i.desnew;
          tab2_stalife_flg := 'Y';
        elsif i.fldedit = 'DTEDTHSP' then
          tab2_dtedthsp     := i.desnew;
          tab2_dtedthsp_flg := 'Y';
        elsif i.fldedit = 'STAINCOM' then
          tab2_staincom  := i.desnew;
          tab2_staincom_flg := 'Y';
        elsif i.fldedit = 'NUMFASP' then
          tab2_numfasp  := i.desnew;
          tab2_numfasp_flg := 'Y';
        elsif i.fldedit = 'NUMMOSP' then
          tab2_nummosp  := i.desnew;
          tab2_nummosp_flg := 'Y';
        elsif i.fldedit = 'TYPTRAV' then
          tab2_typtrav  := i.desnew;
          tab2_typtrav_flg := 'Y';
        elsif i.fldedit = 'QTYLENGTH' then
          tab2_qtylength  := i.desnew;
          tab2_qtylength_flg := 'Y';
        elsif i.fldedit = 'CARLICEN' then
          tab2_carlicen  := i.desnew;
          tab2_carlicen_flg := 'Y';
        elsif i.fldedit = 'TYPFUEL' then
          tab2_typfuel  := i.desnew;
          tab2_typfuel_flg := 'Y';
        elsif i.fldedit = 'CODBUSNO' then
          tab2_codbusno  := i.desnew;
          tab2_codbusno_flg := 'Y';
        elsif i.fldedit = 'CODBUSRT' then
          tab2_codbusrt  := i.desnew;
          tab2_codbusrt_flg := 'Y';
        END IF;
      end loop;
      --
      begin
        select decode(global_v_lang ,'101',tab2_adrrege
                                    ,'102',tab2_adrregt
                                    ,'103',tab2_adrreg3
                                    ,'104',tab2_adrreg4
                                    ,'105',tab2_adrreg5,tab2_adrrege)
        into   tab2_adrreg
        from   dual ;
      end;

      begin
        select decode(global_v_lang ,'101',tab2_adrconte
                                     ,'102',tab2_adrcontt
                                     ,'103',tab2_adrcont3
                                     ,'104',tab2_adrcont4
                                     ,'105',tab2_adrcont5,tab2_adrconte)
        into   tab2_adrcont
        from   dual ;
      end ;
      if global_v_lang = '101' then
        tab2_namfirst   := tab2_namfirste;
        tab2_namlast    := tab2_namlaste;
      elsif global_v_lang = '102' then
        tab2_namfirst   := tab2_namfirstt;
        tab2_namlast    := tab2_namlastt;
      elsif global_v_lang = '103' then
        tab2_namfirst   := tab2_namfirst3;
        tab2_namlast    := tab2_namlast3;
      elsif global_v_lang = '104' then
        tab2_namfirst   := tab2_namfirst4;
        tab2_namlast    := tab2_namlast4;
      elsif global_v_lang = '105' then
        tab2_namfirst   := tab2_namfirst5;
        tab2_namlast    := tab2_namlast5;
      end if;
      --
      tab2_dessubdistr  	  := get_tsubdist_name(tab2_codsubdistr,global_v_lang) ;
      tab2_desdistr  		    := get_tcoddist_name(tab2_coddistr,global_v_lang) ;
      tab2_desprovr  	 	    := get_tcodec_name('TCODPROV',tab2_codprovr,global_v_lang);
      tab2_descntyr 	 	 	  := get_tcodec_name('TCODCNTY',tab2_codcntyr,global_v_lang);
      tab2_dessubdistc      := get_tsubdist_name(tab2_codsubdistc,global_v_lang) ;
      tab2_desdistc  	      := get_tcoddist_name(tab2_coddistc,global_v_lang) ;
      tab2_desprovc  	 	    := get_tcodec_name('TCODPROV',tab2_codprovc,global_v_lang);
      tab2_descntyc 	 	 	  := get_tcodec_name('TCODCNTY',tab2_codcntyc,global_v_lang);
      tab2_desprovi  		    := get_tcodec_name('TCODPROV',tab2_codprovi,global_v_lang);
      tab2_desc_codbank     := get_tcodec_name('TCODBANK',tab2_codbank,global_v_lang);
      tab2_desc_codbank2    := get_tcodec_name('TCODBANK',tab2_codbank2,global_v_lang);
      tab2_desc_codspocc    := get_tcodec_name('TCODOCCU',tab2_codspocc,global_v_lang);
      TAB2_DESC_CODSPPRO    := GET_TCODEC_NAME('TCODPROV',TAB2_CODSPPRO,GLOBAL_V_LANG);
      tab2_desc_codspcty    := get_tcodec_name('TCODCNTY',tab2_codspcty,global_v_lang);
      -- add data
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('desc_coderror', ' ');
      obj_row.put('httpcode', ' ');
      obj_row.put('flg', ' ');
      --display data
      obj_row.put('stamilit',tab2_stamilit);
      obj_row.put('adrreg',tab2_adrreg);
      obj_row.put('adrrege',tab2_adrrege);
      obj_row.put('adrregt',tab2_adrregt);
      obj_row.put('adrreg3',tab2_adrreg3);
      obj_row.put('adrreg4',tab2_adrreg4);
      obj_row.put('adrreg5',tab2_adrreg5);
      obj_row.put('codsubdistr',tab2_codsubdistr);
      obj_row.put('coddistr',tab2_coddistr);
      obj_row.put('codprovr',tab2_codprovr);
      obj_row.put('codcntyr',tab2_codcntyr);
      obj_row.put('codpostr',tab2_codpostr);
      obj_row.put('adrcont',tab2_adrcont);
      obj_row.put('adrconte',tab2_adrconte);
      obj_row.put('adrcontt',tab2_adrcontt);
      obj_row.put('adrcont3',tab2_adrcont3);
      obj_row.put('adrcont4',tab2_adrcont4);
      obj_row.put('adrcont5',tab2_adrcont5);
      obj_row.put('codsubdistc',tab2_codsubdistc);
      obj_row.put('coddistc',tab2_coddistc);
      obj_row.put('codprovc',tab2_codprovc);
      obj_row.put('codcntyc',tab2_codcntyc);
      obj_row.put('codpostc',tab2_codpostc);
      obj_row.put('numtelec',tab2_numtelec);
      --detail2 tab2
      obj_row.put('numoffid',tab2_numoffid);
      obj_row.put('adrissue',tab2_adrissue);
      obj_row.put('codprovi',tab2_codprovi);
      obj_row.put('dteoffid',to_char(tab2_dteoffid,'dd/mm/yyyy'));
      obj_row.put('numlicid',tab2_numlicid);
      obj_row.put('dtelicid',to_char(tab2_dtelicid,'dd/mm/yyyy'));
      obj_row.put('numpasid',tab2_numpasid);
      obj_row.put('dtepasid',to_char(tab2_dtepasid,'dd/mm/yyyy'));
      obj_row.put('numprmid',tab2_numprmid);
      obj_row.put('dteprmst',to_char(tab2_dteprmst,'dd/mm/yyyy'));
      obj_row.put('dteprmen',to_char(tab2_dteprmen,'dd/mm/yyyy'));
      obj_row.put('stamarry',tab2_stamarry);
      obj_row.put('email_emp',tab2_email_emp);
      obj_row.put('nummobile',tab2_nummobile);
      obj_row.put('lineid',tab2_lineid);
      obj_row.put('numvisa',tab2_numvisa);
      obj_row.put('dtevisaexp',to_char(tab2_dtevisaexp,'dd/mm/yyyy'));
      obj_row.put('codclnsc',tab2_codclnsc);
      obj_row.put('dteretire',to_char(tab2_dteretire,'dd/mm/yyyy'));

      obj_row.put('codbank',tab2_codbank);
      obj_row.put('numbank',tab2_numbank);
      obj_row.put('numbrnch',tab2_numbrnch);
      obj_row.put('codbank2',tab2_codbank2);
      obj_row.put('numbank2',tab2_numbank2);
      obj_row.put('numbrnch2',tab2_numbrnch2);
      obj_row.put('amtbank',tab2_amtbank);
      obj_row.put('amttranb',tab2_amttranb);

      obj_row.put('qtychedu',tab2_qtychedu);
      obj_row.put('qtychned',tab2_qtychned);
      obj_row.put('namspe',tab2_namspe);
      obj_row.put('namspt',tab2_namspt);
      obj_row.put('namsp3',tab2_namsp3);
      obj_row.put('namsp4',tab2_namsp4);
      obj_row.put('namsp5',tab2_namsp5);
      obj_row.put('codtitle',tab2_codtitle);
      obj_row.put('namfirst',tab2_namfirst);
      obj_row.put('namfirste',tab2_namfirste);
      obj_row.put('namfirstt',tab2_namfirstt);
      obj_row.put('namfirst3',tab2_namfirst3);
      obj_row.put('namfirst4',tab2_namfirst4);
      obj_row.put('namfirst5',tab2_namfirst5);
      obj_row.put('namlast',tab2_namlast);
      obj_row.put('namlaste',tab2_namlaste);
      obj_row.put('namlastt',tab2_namlastt);
      obj_row.put('namlast3',tab2_namlast3);
      obj_row.put('namlast4',tab2_namlast4);
      obj_row.put('namlast5',tab2_namlast5);
      obj_row.put('codempidsp',tab2_codempidsp);
      obj_row.put('stalife',tab2_stalife);
      obj_row.put('dtedthsp',to_char(tab2_dtedthsp,'dd/mm/yyyy'));
      obj_row.put('staincom',tab2_staincom);
      obj_row.put('numfasp',tab2_numfasp);
      obj_row.put('nummosp',tab2_nummosp);
      obj_row.put('filename',tab2_filename);
      obj_row.put('numspid',tab2_numspid);
      obj_row.put('dtespbd',to_char(tab2_dtespbd,'dd/mm/yyyy'));
      obj_row.put('codspocc',tab2_codspocc);
      obj_row.put('desnoffi',tab2_desnoffi);
      obj_row.put('dtemarry',to_char(tab2_dtemarry,'dd/mm/yyyy'));
      obj_row.put('desplreg',tab2_desplreg);
      obj_row.put('codsppro',tab2_codsppro);
      obj_row.put('codspcty',tab2_codspcty);

      obj_row.put('desnote',tab2_desnote);
      obj_row.put('dessubdistr',tab2_dessubdistr);
      obj_row.put('desdistr',tab2_desdistr);
      obj_row.put('desprovr',tab2_desprovr);
      obj_row.put('descntyr',tab2_descntyr);
      obj_row.put('dessubdistc',tab2_dessubdistc);
      obj_row.put('desdistc',tab2_desdistc);
      obj_row.put('desprovc',tab2_desprovc);
      obj_row.put('descntyc',tab2_descntyc);
      obj_row.put('desprovi',tab2_desprovi);
      obj_row.put('desc_codbank',tab2_desc_codbank);
      obj_row.put('desc_codbank2',tab2_desc_codbank2);
      obj_row.put('desc_codspocc',tab2_desc_codspocc);
      obj_row.put('desc_codsppro',tab2_desc_codsppro);
      obj_row.put('desc_codspcty',tab2_desc_codspcty);
      obj_row.put('stamilit_flg',tab2_stamilit_flg);
      obj_row.put('adrrege_flg',tab2_adrrege_flg);
      obj_row.put('adrregt_flg',tab2_adrregt_flg);
      obj_row.put('adrreg3_flg',tab2_adrreg3_flg);
      obj_row.put('adrreg4_flg',tab2_adrreg4_flg);
      obj_row.put('adrreg5_flg',tab2_adrreg5_flg);
      obj_row.put('codsubdistr_flg',tab2_codsubdistr_flg);
      obj_row.put('coddistr_flg',tab2_coddistr_flg);
      obj_row.put('codprovr_flg',tab2_codprovr_flg);
      obj_row.put('codcntyr_flg',tab2_codcntyr_flg);
      obj_row.put('codpostr_flg',tab2_codpostr_flg);
      obj_row.put('adrconte_flg',tab2_adrconte_flg);
      obj_row.put('adrcontt_flg',tab2_adrcontt_flg);
      obj_row.put('adrcont3_flg',tab2_adrcont3_flg);
      obj_row.put('adrcont4_flg',tab2_adrcont4_flg);
      obj_row.put('adrcont5_flg',tab2_adrcont5_flg);
      obj_row.put('codsubdistc_flg',tab2_codsubdistc_flg);
      obj_row.put('coddistc_flg',tab2_coddistc_flg);
      obj_row.put('codprovc_flg',tab2_codprovc_flg);
      obj_row.put('codcntyc_flg',tab2_codcntyc_flg);
      obj_row.put('codpostc_flg',tab2_codpostc_flg);
      obj_row.put('numtelec_flg',tab2_numtelec_flg);
      obj_row.put('numoffid_flg',tab2_numoffid_flg);
      obj_row.put('adrissue_flg',tab2_adrissue_flg);
      obj_row.put('codprovi_flg',tab2_codprovi_flg);
      obj_row.put('dteoffid_flg',tab2_dteoffid_flg);
      obj_row.put('numlicid_flg',tab2_numlicid_flg);
      obj_row.put('dtelicid_flg',tab2_dtelicid_flg);
      obj_row.put('numpasid_flg',tab2_numpasid_flg);
      obj_row.put('dtepasid_flg',tab2_dtepasid_flg);
      obj_row.put('numprmid_flg',tab2_numprmid_flg);
      obj_row.put('dteprmst_flg',tab2_dteprmst_flg);
      obj_row.put('dteprmen_flg',tab2_dteprmen_flg);
      obj_row.put('stamarry_flg',tab2_stamarry_flg);
      obj_row.put('email_emp_flg',tab2_email_emp_flg);
      obj_row.put('nummobile_flg',tab2_nummobile_flg);
      obj_row.put('lineid_flg',tab2_lineid_flg);
      obj_row.put('numvisa_flg',tab2_numvisa_flg);
      obj_row.put('codclnsc_flg',tab2_codclnsc_flg);
      obj_row.put('dteretire_flg',tab2_dteretire_flg);
      obj_row.put('codbank_flg',tab2_codbank_flg);
      obj_row.put('numbank_flg',tab2_numbank_flg);
      obj_row.put('numbrnch_flg',tab2_numbrnch_flg);
      obj_row.put('codbank2_flg',tab2_codbank2_flg);
      obj_row.put('numbank2_flg',tab2_numbank2_flg);
      obj_row.put('numbrnch2_flg',tab2_numbrnch2_flg);
      obj_row.put('amtbank_flg',tab2_amtbank_flg);
      obj_row.put('amttranb_flg',tab2_amttranb_flg);
      obj_row.put('qtychedu_flg',tab2_qtychedu_flg);
      obj_row.put('qtychned_flg',tab2_qtychned_flg);
      obj_row.put('namspe_flg',tab2_namspe_flg);
      obj_row.put('namspt_flg',tab2_namspt_flg);
      obj_row.put('namsp3_flg',tab2_namsp3_flg);
      obj_row.put('namsp4_flg',tab2_namsp4_flg);
      obj_row.put('namsp5_flg',tab2_namsp5_flg);
      obj_row.put('codempidsp_flg',tab2_codempidsp_flg);
      obj_row.put('stalife_flg',tab2_stalife_flg);
      obj_row.put('dtedthsp_flg',tab2_dtedthsp_flg);
      obj_row.put('staincom_flg',tab2_staincom_flg);
      obj_row.put('numfasp_flg',tab2_numfasp_flg);
      obj_row.put('nummosp_flg',tab2_nummosp_flg);
      obj_row.put('filename_flg',tab2_filename_flg);
      obj_row.put('numspid_flg',tab2_numspid_flg);
      obj_row.put('dtespbd_flg',tab2_dtespbd_flg);
      obj_row.put('codspocc_flg',tab2_codspocc_flg);
      obj_row.put('desnoffi_flg',tab2_desnoffi_flg);
      obj_row.put('dtemarry_flg',tab2_dtemarry_flg);
      obj_row.put('desplreg_flg',tab2_desplreg_flg);
      obj_row.put('codsppro_flg',tab2_codsppro_flg);
      obj_row.put('codspcty_flg',tab2_codspcty_flg);
      obj_row.put('desnote_flg',tab2_desnote_flg);
      obj_row.put('typtrav',tab2_typtrav);
      obj_row.put('qtylength',tab2_qtylength);
      obj_row.put('carlicen',tab2_carlicen);
      obj_row.put('typfuel',tab2_typfuel);
      obj_row.put('codbusno',tab2_codbusno);
      obj_row.put('codbusrt',tab2_codbusrt);
      obj_row.put('typtrav_flg',tab2_typtrav_flg);
      obj_row.put('qtylength_flg',tab2_qtylength_flg);
      obj_row.put('carlicen_flg',tab2_carlicen_flg);
      obj_row.put('typfuel_flg',tab2_typfuel_flg);
      obj_row.put('codbusno_flg',tab2_codbusno_flg);
      obj_row.put('codbusrt_flg',tab2_codbusrt_flg);
      --
      json_str_output := obj_row.to_clob;
      return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_address;

  --  hres32e_detail_tab3
  function get_tfamily return clob as
    obj_row             json_object_t;
    json_str_output     clob;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB3';
    tab3_codempfa       tfamily.codempfa%type;
    tab3_codtitlf       tfamily.codtitlf%type;
    tab3_namfstf        tfamily.namfstfe%type;
    tab3_namfstfe       tfamily.namfstfe%type;
    tab3_namfstft       tfamily.namfstft%type;
    tab3_namfstf3       tfamily.namfstf3%type;
    tab3_namfstf4       tfamily.namfstf4%type;
    tab3_namfstf5       tfamily.namfstf5%type;
    tab3_namlstf        tfamily.namlstfe%type;
    tab3_namlstfe       tfamily.namlstfe%type;
    tab3_namlstft       tfamily.namlstft%type;
    tab3_namlstf3       tfamily.namlstf3%type;
    tab3_namlstf4       tfamily.namlstf4%type;
    tab3_namlstf5       tfamily.namlstf5%type;
    tab3_namfath        tfamily.namfathe%type;
    tab3_namfathe       tfamily.namfathe%type;
    tab3_namfatht       tfamily.namfatht%type;
    tab3_namfath3       tfamily.namfath3%type;
    tab3_namfath4       tfamily.namfath4%type;
    tab3_namfath5       tfamily.namfath5%type;
    tab3_numofidf       tfamily.numofidf%type;
    tab3_dtebdfa        tfamily.dtebdfa%type;
    tab3_codfnatn       tfamily.codfnatn%type;
    tab3_codfrelg       tfamily.codfrelg%type;
    tab3_codfoccu       tfamily.codfoccu%type;
    tab3_staliff        tfamily.staliff%type;
    tab3_dtedeathf      tfamily.dtedeathf%type;
    tab3_filenamf       tfamily.filenamf%type;
    tab3_numrefdocf     tfamily.numrefdocf%type;
    tab3_codempmo       tfamily.codempmo%type;
    tab3_codtitlm       tfamily.codtitlm%type;
    tab3_namfstm        tfamily.namfstme%type;
    tab3_namfstme       tfamily.namfstme%type;
    tab3_namfstmt       tfamily.namfstmt%type;
    tab3_namfstm3       tfamily.namfstm3%type;
    tab3_namfstm4       tfamily.namfstm4%type;
    tab3_namfstm5       tfamily.namfstm5%type;
    tab3_namlstm        tfamily.namlstme%type;
    tab3_namlstme       tfamily.namlstme%type;
    tab3_namlstmt       tfamily.namlstmt%type;
    tab3_namlstm3       tfamily.namlstm3%type;
    tab3_namlstm4       tfamily.namlstm4%type;
    tab3_namlstm5       tfamily.namlstm5%type;
    tab3_nammoth        tfamily.nammothe%type;
    tab3_nammothe       tfamily.nammothe%type;
    tab3_nammotht       tfamily.nammotht%type;
    tab3_nammoth3       tfamily.nammoth3%type;
    tab3_nammoth4       tfamily.nammoth4%type;
    tab3_nammoth5       tfamily.nammoth5%type;
    tab3_numofidm       tfamily.numofidm%type;
    tab3_dtebdmo        tfamily.dtebdmo%type;
    tab3_codmnatn       tfamily.codmnatn%type;
    tab3_codmrelg       tfamily.codmrelg%type;
    tab3_codmoccu       tfamily.codmoccu%type;
    tab3_stalifm        tfamily.stalifm%type;
    tab3_dtedeathm      tfamily.dtedeathm%type;
    tab3_filenamm       tfamily.filenamm%type;
    tab3_numrefdocm     tfamily.numrefdocm%type;
    tab3_codtitlc       tfamily.codtitlc%type;
    tab3_namfstc        tfamily.namfstce%type;
    tab3_namfstce       tfamily.namfstce%type;
    tab3_namfstct       tfamily.namfstct%type;
    tab3_namfstc3       tfamily.namfstc3%type;
    tab3_namfstc4       tfamily.namfstc4%type;
    tab3_namfstc5       tfamily.namfstc5%type;
    tab3_namlstc        tfamily.namlstce%type;
    tab3_namlstce       tfamily.namlstce%type;
    tab3_namlstct       tfamily.namlstct%type;
    tab3_namlstc3       tfamily.namlstc3%type;
    tab3_namlstc4       tfamily.namlstc4%type;
    tab3_namlstc5       tfamily.namlstc5%type;
    tab3_namcont        tfamily.namconte%type;
    tab3_namconte       tfamily.namconte%type;
    tab3_namcontt       tfamily.namcontt%type;
    tab3_namcont3       tfamily.namcont3%type;
    tab3_namcont4       tfamily.namcont4%type;
    tab3_namcont5       tfamily.namcont5%type;
    tab3_adrcont1       tfamily.adrcont1%type;
    tab3_codpost        tfamily.codpost%type;
    tab3_numtele        tfamily.numtele%type;
    tab3_numfax         tfamily.numfax%type;
    tab3_email          tfamily.email%type;
    tab3_desrelat       tfamily.desrelat%type;
    tab3_desc_codfnatn  varchar2(4000 char);
    tab3_desc_codfrelg  varchar2(4000 char);
    tab3_desc_codfoccu  varchar2(4000 char);
    tab3_desc_codmnatn  varchar2(4000 char);
    tab3_desc_codmrelg  varchar2(4000 char);
    tab3_desc_codmoccu  varchar2(4000 char);
    tab3_namfath_flg    varchar2(10 char) := 'N';
    tab3_namfathe_flg   varchar2(10 char) := 'N';
    tab3_namfatht_flg   varchar2(10 char) := 'N';
    tab3_namfath3_flg   varchar2(10 char) := 'N';
    tab3_namfath4_flg   varchar2(10 char) := 'N';
    tab3_namfath5_flg   varchar2(10 char) := 'N';
    tab3_codfnatn_flg   varchar2(10 char) := 'N';
    tab3_codfrelg_flg   varchar2(10 char) := 'N';
    tab3_codfoccu_flg   varchar2(10 char) := 'N';
    tab3_numofidf_flg   varchar2(10 char) := 'N';
    tab3_nammoth_flg    varchar2(10 char) := 'N';
    tab3_nammothe_flg   varchar2(10 char) := 'N';
    tab3_nammotht_flg   varchar2(10 char) := 'N';
    tab3_nammoth3_flg   varchar2(10 char) := 'N';
    tab3_nammoth4_flg   varchar2(10 char) := 'N';
    tab3_nammoth5_flg   varchar2(10 char) := 'N';
    tab3_codmrelg_flg   varchar2(10 char) := 'N';
    tab3_codmnatn_flg   varchar2(10 char) := 'N';
    tab3_codmoccu_flg   varchar2(10 char) := 'N';
    tab3_numofidm_flg   varchar2(10 char) := 'N';
    tab3_namcont_flg    varchar2(10 char) := 'N';
    tab3_namconte_flg   varchar2(10 char) := 'N';
    tab3_namcontt_flg   varchar2(10 char) := 'N';
    tab3_namcont3_flg   varchar2(10 char) := 'N';
    tab3_namcont4_flg   varchar2(10 char) := 'N';
    tab3_namcont5_flg   varchar2(10 char) := 'N';
    tab3_adrcont1_flg   varchar2(10 char) := 'N';
    tab3_codpost_flg    varchar2(10 char) := 'N';
    tab3_numtele_flg    varchar2(10 char) := 'N';
    tab3_numfax_flg     varchar2(10 char) := 'N';
    tab3_email_flg      varchar2(10 char) := 'N';
    tab3_desrelat_flg   varchar2(10 char) := 'N';
    --new column
    tab3_codtitlf_flg    varchar2(10 char) := 'N';
    tab3_namfstfe_flg    varchar2(10 char) := 'N';
    tab3_namfstft_flg    varchar2(10 char) := 'N';
    tab3_namfstf3_flg    varchar2(10 char) := 'N';
    tab3_namfstf4_flg    varchar2(10 char) := 'N';
    tab3_namfstf5_flg    varchar2(10 char) := 'N';
    tab3_namlstfe_flg    varchar2(10 char) := 'N';
    tab3_namlstft_flg    varchar2(10 char) := 'N';
    tab3_namlstf3_flg    varchar2(10 char) := 'N';
    tab3_namlstf4_flg    varchar2(10 char) := 'N';
    tab3_namlstf5_flg    varchar2(10 char) := 'N';
    tab3_codtitlm_flg    varchar2(10 char) := 'N';
    tab3_namfstme_flg    varchar2(10 char) := 'N';
    tab3_namfstmt_flg    varchar2(10 char) := 'N';
    tab3_namfstm3_flg    varchar2(10 char) := 'N';
    tab3_namfstm4_flg    varchar2(10 char) := 'N';
    tab3_namfstm5_flg    varchar2(10 char) := 'N';
    tab3_namlstme_flg    varchar2(10 char) := 'N';
    tab3_namlstmt_flg    varchar2(10 char) := 'N';
    tab3_namlstm3_flg    varchar2(10 char) := 'N';
    tab3_namlstm4_flg    varchar2(10 char) := 'N';
    tab3_namlstm5_flg    varchar2(10 char) := 'N';
    tab3_codtitlc_flg    varchar2(10 char) := 'N';
    tab3_namfstce_flg    varchar2(10 char) := 'N';
    tab3_namfstct_flg    varchar2(10 char) := 'N';
    tab3_namfstc3_flg    varchar2(10 char) := 'N';
    tab3_namfstc4_flg    varchar2(10 char) := 'N';
    tab3_namfstc5_flg    varchar2(10 char) := 'N';
    tab3_namlstce_flg    varchar2(10 char) := 'N';
    tab3_namlstct_flg    varchar2(10 char) := 'N';
    tab3_namlstc3_flg    varchar2(10 char) := 'N';
    tab3_namlstc4_flg    varchar2(10 char) := 'N';
    tab3_namlstc5_flg    varchar2(10 char) := 'N';
    tab3_codempfa_flg    varchar2(10 char) := 'N';
    tab3_codempmo_flg    varchar2(10 char) := 'N';

    tab3_dtebdfa_flg     varchar2(10 char) := 'N';
    tab3_staliff_flg     varchar2(10 char) := 'N';
    tab3_dtedeathf_flg   varchar2(10 char) := 'N';
    tab3_filenamf_flg    varchar2(10 char) := 'N';
    tab3_dtebdmo_flg     varchar2(10 char) := 'N';
    tab3_stalifm_flg     varchar2(10 char) := 'N';
    tab3_dtedeathm_flg   varchar2(10 char) := 'N';
    tab3_filenamm_flg    varchar2(10 char) := 'N';
    --Cursor
    cursor c_temeslog1 is
    select *
      from temeslog1
     where codempid = b_index_codempid
       and dtereq   = b_index_dtereq
       and numseq   = b_index_numseq
       and numpage  = 25;
    begin
      begin
        select /*namfathr,codfnatn,codfrelg,
               codfoccu,numofidf,nammothr,
               codmnatn,codmrelg,codmoccu,
               numofidm,namcont,adrcont1,
               codpost,numtele,numfax,
               email,desrelat*/
                codempfa,codtitlf,
                namfstfe,namfstft,namfstf3,namfstf4,namfstf5,
                namlstfe,namlstft,namlstf3,namlstf4,namlstf5,
                namfathe,namfatht,namfath3,namfath4,namfath5,
                numofidf,dtebdfa,codfnatn,codfrelg,codfoccu,
                staliff,dtedeathf,filenamf,numrefdocf,
                codempmo,codtitlm,
                namfstme,namfstmt,namfstm3,namfstm4,namfstm5,
                namlstme,namlstmt,namlstm3,namlstm4,namlstm5,
                nammothe,nammotht,nammoth3,nammoth4,nammoth5,
                numofidm,dtebdmo,codmnatn,codmrelg,codmoccu,
                stalifm,dtedeathm,filenamm,numrefdocm,
                codtitlc,
                namfstce,namfstct,namfstc3,namfstc4,namfstc5,
                namlstce,namlstct,namlstc3,namlstc4,namlstc5,
                namconte,namcontt,namcont3,namcont4,namcont5,
                adrcont1,codpost,numtele,numfax,email,desrelat
          into /*tab3_namfathr,tab3_codfnatn,tab3_codfrelg,
               tab3_codfoccu,tab3_numofidf,tab3_nammothr,
               tab3_codmnatn,tab3_codmrelg,tab3_codmoccu,
               tab3_numofidm,tab3_namcont,tab3_adrcont1,
               tab3_codpost,tab3_numtele,tab3_numfax,
               tab3_email,tab3_desrelat*/
                tab3_codempfa,tab3_codtitlf,
                tab3_namfstfe,tab3_namfstft,tab3_namfstf3,tab3_namfstf4,tab3_namfstf5,
                tab3_namlstfe,tab3_namlstft,tab3_namlstf3,tab3_namlstf4,tab3_namlstf5,
                tab3_namfathe,tab3_namfatht,tab3_namfath3,tab3_namfath4,tab3_namfath5,
                tab3_numofidf,tab3_dtebdfa,tab3_codfnatn,tab3_codfrelg,tab3_codfoccu,
                tab3_staliff,tab3_dtedeathf,tab3_filenamf,tab3_numrefdocf,
                tab3_codempmo,tab3_codtitlm,
                tab3_namfstme,tab3_namfstmt,tab3_namfstm3,tab3_namfstm4,tab3_namfstm5,
                tab3_namlstme,tab3_namlstmt,tab3_namlstm3,tab3_namlstm4,tab3_namlstm5,
                tab3_nammothe,tab3_nammotht,tab3_nammoth3,tab3_nammoth4,tab3_nammoth5,
                tab3_numofidm,tab3_dtebdmo,tab3_codmnatn,tab3_codmrelg,tab3_codmoccu,
                tab3_stalifm,tab3_dtedeathm,tab3_filenamm,tab3_numrefdocm,
                tab3_codtitlc,
                tab3_namfstce,tab3_namfstct,tab3_namfstc3,tab3_namfstc4,tab3_namfstc5,
                tab3_namlstce,tab3_namlstct,tab3_namlstc3,tab3_namlstc4,tab3_namlstc5,
                tab3_namconte,tab3_namcontt,tab3_namcont3,tab3_namcont4,tab3_namcont5,
                tab3_adrcont1,tab3_codpost,tab3_numtele,tab3_numfax,tab3_email,tab3_desrelat
          from tfamily
         where codempid  = b_index_codempid ;
      exception when no_data_found then
        -- *father*                           *mother*                            *contact*
        tab3_codempfa       := null;        tab3_codempmo       := null;        tab3_codtitlc       := null;
        tab3_codtitlf       := null;        tab3_codtitlm       := null;        tab3_namfstce       := null;
        tab3_namfstfe       := null;        tab3_namfstme       := null;        tab3_namfstct       := null;
        tab3_namfstft       := null;        tab3_namfstmt       := null;        tab3_namfstc3       := null;
        tab3_namfstf3       := null;        tab3_namfstm3       := null;        tab3_namfstc4       := null;
        tab3_namfstf4       := null;        tab3_namfstm4       := null;        tab3_namfstc5       := null;
        tab3_namfstf5       := null;        tab3_namfstm5       := null;        tab3_namlstce       := null;
        tab3_namlstfe       := null;        tab3_namlstme       := null;        tab3_namlstct       := null;
        tab3_namlstft       := null;        tab3_namlstmt       := null;        tab3_namlstc3       := null;
        tab3_namlstf3       := null;        tab3_namlstm3       := null;        tab3_namlstc4       := null;
        tab3_namlstf4       := null;        tab3_namlstm4       := null;        tab3_namlstc5       := null;
        tab3_namlstf5       := null;        tab3_namlstm5       := null;        tab3_namconte       := null;
        tab3_namfathe       := null;        tab3_nammothe       := null;        tab3_namcontt       := null;
        tab3_namfatht       := null;        tab3_nammotht       := null;        tab3_namcont3       := null;
        tab3_namfath3       := null;        tab3_nammoth3       := null;        tab3_namcont4       := null;
        tab3_namfath4       := null;        tab3_nammoth4       := null;        tab3_namcont5       := null;
        tab3_namfath5       := null;        tab3_nammoth5       := null;        tab3_adrcont1       := null;
        tab3_numofidf       := null;        tab3_numofidm       := null;        tab3_codpost        := null;
        tab3_dtebdfa        := null;        tab3_dtebdmo        := null;        tab3_numtele        := null;
        tab3_codfnatn       := null;        tab3_codmnatn       := null;        tab3_numfax         := null;
        tab3_codfrelg       := null;        tab3_codmrelg       := null;        tab3_email          := null;
        tab3_codfoccu       := null;        tab3_codmoccu       := null;        tab3_desrelat       := null;
        tab3_staliff        := null;        tab3_stalifm        := null;
        tab3_dtedeathf      := null;        tab3_dtedeathm      := null;
        tab3_filenamf       := null;        tab3_filenamm       := null;
        tab3_numrefdocf     := null;        tab3_numrefdocm     := null;
      end ;
      --
      for i in c_temeslog1 loop
        if i.fldedit = 'NAMFATHE' then
          tab3_namfathe := i.desnew;
          tab3_namfathe_flg := 'Y';
        elsif i.fldedit = 'NAMFATHT' then
          tab3_namfatht := i.desnew;
          tab3_namfatht_flg := 'Y';
        elsif i.fldedit = 'NAMFATH3' then
          tab3_namfath3 := i.desnew;
          tab3_namfath3_flg := 'Y';
        elsif i.fldedit = 'NAMFATH4' then
          tab3_namfath4 := i.desnew;
          tab3_namfath4_flg := 'Y';
        elsif i.fldedit = 'NAMFATH5' then
          tab3_namfath5 := i.desnew;
          tab3_namfath5_flg := 'Y';
        elsif i.fldedit = 'CODFNATN' then
          tab3_codfnatn  := i.desnew;
          tab3_codfnatn_flg := 'Y';
        elsif i.fldedit = 'CODFRELG' then
          tab3_codfrelg  := i.desnew;
          tab3_codfrelg_flg := 'Y';
        elsif i.fldedit = 'CODFOCCU' then
          tab3_codfoccu  := i.desnew;
          tab3_codfoccu_flg := 'Y';
        elsif i.fldedit = 'NUMOFIDF' then
          tab3_numofidf  := i.desnew;
          tab3_numofidf_flg := 'Y';
        elsif i.fldedit = 'NAMMOTHE' then
          tab3_nammothe  := i.desnew;
          tab3_nammothe_flg := 'Y';
        elsif i.fldedit = 'NAMMOTHT' then
          tab3_nammotht  := i.desnew;
          tab3_nammotht_flg := 'Y';
        elsif i.fldedit = 'NAMMOTH3' then
          tab3_nammoth3  := i.desnew;
          tab3_nammoth3_flg := 'Y';
        elsif i.fldedit = 'NAMMOTH4' then
          tab3_nammoth4  := i.desnew;
          tab3_nammoth4_flg := 'Y';
        elsif i.fldedit = 'NAMMOTH5' then
          tab3_nammoth5  := i.desnew;
          tab3_nammoth5_flg := 'Y';
        elsif i.fldedit = 'CODMNATN' then
          tab3_codmnatn  := i.desnew;
          tab3_codmnatn_flg := 'Y';
        elsif i.fldedit = 'CODMRELG' then
          tab3_codmrelg  := i.desnew;
          tab3_codmrelg_flg := 'Y';
        elsif i.fldedit = 'CODMOCCU' then
          tab3_codmoccu  := i.desnew;
          tab3_codmoccu_flg := 'Y';
        elsif i.fldedit = 'NUMOFIDM' then
          tab3_numofidm  := i.desnew;
          tab3_numofidm_flg := 'Y';
        elsif i.fldedit = 'NAMCONTE' then
          tab3_namconte  := i.desnew;
          tab3_namconte_flg := 'Y';
        elsif i.fldedit = 'NAMCONTT' then
          tab3_namcontt  := i.desnew;
          tab3_namcontt_flg := 'Y';
        elsif i.fldedit = 'NAMCONT3' then
          tab3_namcont3  := i.desnew;
          tab3_namcont3_flg := 'Y';
        elsif i.fldedit = 'NAMCONT4' then
          tab3_namcont4  := i.desnew;
          tab3_namcont4_flg := 'Y';
        elsif i.fldedit = 'NAMCONT5' then
          tab3_namcont5  := i.desnew;
          tab3_namcont5_flg := 'Y';
        elsif i.fldedit = 'ADRCONT1' then
          tab3_adrcont1  := i.desnew;
          tab3_adrcont1_flg := 'Y';
        elsif i.fldedit = 'CODPOST' then
          tab3_codpost  := i.desnew;
          tab3_codpost_flg := 'Y';
        elsif i.fldedit = 'NUMTELE' then
          tab3_numtele  := i.desnew;
          tab3_numtele_flg := 'Y';
        elsif i.fldedit = 'NUMFAX' then
          tab3_numfax  := i.desnew;
          tab3_numfax_flg := 'Y';
        elsif i.fldedit = 'EMAIL' then
          tab3_email  := i.desnew;
          tab3_email_flg := 'Y';
        elsif i.fldedit = 'DESRELAT' then
          tab3_desrelat  := i.desnew;
          tab3_desrelat_flg := 'Y';
        ---- new
        elsif i.fldedit = 'CODTITLF' then
          tab3_codtitlf  := i.desnew;
          tab3_codtitlf_flg := 'Y';
        elsif i.fldedit = 'NAMFSTFE' then
          tab3_namfstfe  := i.desnew;
          tab3_namfstfe_flg := 'Y';
        elsif i.fldedit = 'NAMFSTFT' then
          tab3_namfstft  := i.desnew;
          tab3_namfstft_flg := 'Y';
        elsif i.fldedit = 'NAMFSTF3' then
          tab3_namfstf3  := i.desnew;
          tab3_namfstf3_flg := 'Y';
        elsif i.fldedit = 'NAMFSTF4' then
          tab3_namfstf4  := i.desnew;
          tab3_namfstf4_flg := 'Y';
        elsif i.fldedit = 'NAMFSTF5' then
          tab3_namfstf5  := i.desnew;
          tab3_namfstf5_flg := 'Y';
        elsif i.fldedit = 'NAMLSTFE' then
          tab3_namlstfe  := i.desnew;
          tab3_namlstfe_flg := 'Y';
        elsif i.fldedit = 'NAMLSTFT' then
          tab3_namlstft  := i.desnew;
          tab3_namlstft_flg := 'Y';
        elsif i.fldedit = 'NAMLSTF3' then
          tab3_namlstf3  := i.desnew;
          tab3_namlstf3_flg := 'Y';
        elsif i.fldedit = 'NAMLSTF4' then
          tab3_namlstf4  := i.desnew;
          tab3_namlstf4_flg := 'Y';
        elsif i.fldedit = 'NAMLSTF5' then
          tab3_namlstf5  := i.desnew;
          tab3_namlstf5_flg := 'Y';
        elsif i.fldedit = 'CODTITLM' then
          tab3_codtitlm  := i.desnew;
          tab3_codtitlm_flg := 'Y';
        elsif i.fldedit = 'NAMFSTME' then
          tab3_namfstme  := i.desnew;
          tab3_namfstme_flg := 'Y';
        elsif i.fldedit = 'NAMFSTMT' then
          tab3_namfstmt  := i.desnew;
          tab3_namfstmt_flg := 'Y';
        elsif i.fldedit = 'NAMFSTM3' then
          tab3_namfstm3  := i.desnew;
          tab3_namfstm3_flg := 'Y';
        elsif i.fldedit = 'NAMFSTM4' then
          tab3_namfstm4  := i.desnew;
          tab3_namfstm4_flg := 'Y';
        elsif i.fldedit = 'NAMFSTM5' then
          tab3_namfstm5  := i.desnew;
          tab3_namfstm5_flg := 'Y';
        elsif i.fldedit = 'NAMLSTME' then
          tab3_namlstme  := i.desnew;
          tab3_namlstme_flg := 'Y';
        elsif i.fldedit = 'NAMLSTMT' then
          tab3_namlstmt  := i.desnew;
          tab3_namlstmt_flg := 'Y';
        elsif i.fldedit = 'NAMLSTM3' then
          tab3_namlstm3  := i.desnew;
          tab3_namlstm3_flg := 'Y';
        elsif i.fldedit = 'NAMLSTM4' then
          tab3_namlstm4  := i.desnew;
          tab3_namlstm4_flg := 'Y';
        elsif i.fldedit = 'NAMLSTM5' then
          tab3_namlstm5  := i.desnew;
          tab3_namlstm5_flg := 'Y';
        elsif i.fldedit = 'CODTITLC' then
          tab3_codtitlc  := i.desnew;
          tab3_codtitlc_flg := 'Y';
        elsif i.fldedit = 'NAMFSTCE' then
          tab3_namfstce  := i.desnew;
          tab3_namfstce_flg := 'Y';
        elsif i.fldedit = 'NAMFSTCT' then
          tab3_namfstct  := i.desnew;
          tab3_namfstct_flg := 'Y';
        elsif i.fldedit = 'NAMFSTC3' then
          tab3_namfstc3  := i.desnew;
          tab3_namfstc3_flg := 'Y';
        elsif i.fldedit = 'NAMFSTC4' then
          tab3_namfstc4  := i.desnew;
          tab3_namfstc4_flg := 'Y';
        elsif i.fldedit = 'NAMFSTC5' then
          tab3_namfstc5  := i.desnew;
          tab3_namfstc5_flg := 'Y';
        elsif i.fldedit = 'NAMLSTCE' then
          tab3_namlstce  := i.desnew;
          tab3_namlstce_flg := 'Y';
        elsif i.fldedit = 'NAMLSTCT' then
          tab3_namlstct  := i.desnew;
          tab3_namlstct_flg := 'Y';
        elsif i.fldedit = 'NAMLSTC3' then
          tab3_namlstc3  := i.desnew;
          tab3_namlstc3_flg := 'Y';
        elsif i.fldedit = 'NAMLSTC4' then
          tab3_namlstc4  := i.desnew;
          tab3_namlstc4_flg := 'Y';
        elsif i.fldedit = 'NAMLSTC5' then
          tab3_namlstc5  := i.desnew;
          tab3_namlstc5_flg := 'Y';
        elsif i.fldedit = 'CODEMPFA' then
          tab3_codempfa  := i.desnew;
          tab3_codempfa_flg := 'Y';
        elsif i.fldedit = 'CODEMPMO' then
          tab3_codempmo  := i.desnew;
          tab3_codempmo_flg := 'Y';
        elsif i.fldedit = 'DTEBDFA' then
          tab3_dtebdfa  := to_date(i.desnew,'dd/mm/yyyy') ;
          tab3_dtebdfa_flg := 'Y';
        elsif i.fldedit = 'STALIFF' then
          tab3_staliff  := i.desnew;
          tab3_staliff_flg := 'Y';
        elsif i.fldedit = 'DTEDEATHF' then
          tab3_dtedeathf  := to_date(i.desnew,'dd/mm/yyyy');
          tab3_dtedeathf_flg := 'Y';
        elsif i.fldedit = 'FILENAMF' then
          tab3_filenamf  := i.desnew;
          tab3_filenamf_flg := 'Y';
        elsif i.fldedit = 'DTEBDMO' then
          tab3_dtebdmo  := to_date(i.desnew,'dd/mm/yyyy');
          tab3_dtebdmo_flg := 'Y';
        elsif i.fldedit = 'STALIFM' then
          tab3_stalifm  := i.desnew;
          tab3_stalifm_flg := 'Y';
        elsif i.fldedit = 'DTEDEATHM' then
          tab3_dtedeathm  := to_date(i.desnew,'dd/mm/yyyy');
          tab3_dtedeathm_flg := 'Y';
        elsif i.fldedit = 'FILENAMM' then
          tab3_filenamm  := i.desnew;
          tab3_filenamm_flg := 'Y';
        end if;
      end loop;
      --
      if global_v_lang = '101' then
        tab3_namfath    := tab3_namfathe;
        tab3_nammoth    := tab3_nammothe;
        tab3_namcont    := tab3_namconte;
        tab3_namfstf    := tab3_namfstfe;
        tab3_namlstf    := tab3_namfstfe;
        tab3_namfstm    := tab3_namfstme;
        tab3_namlstm    := tab3_namfstme;
        tab3_namfstc    := tab3_namfstce;
        tab3_namlstc    := tab3_namfstce;
      elsif global_v_lang = '102' then
        tab3_namfath    := tab3_namfatht;
        tab3_nammoth    := tab3_nammotht;
        tab3_namcont    := tab3_namcontt;
        tab3_namfstf    := tab3_namfstft;
        tab3_namlstf    := tab3_namlstft;
        tab3_namfstm    := tab3_namfstmt;
        tab3_namlstm    := tab3_namlstmt;
        tab3_namfstc    := tab3_namfstct;
        tab3_namlstc    := tab3_namlstct;
      elsif global_v_lang = '103' then
        tab3_namfath    := tab3_namfath3;
        tab3_nammoth    := tab3_nammoth3;
        tab3_namcont    := tab3_namcont3;
        tab3_namfstf    := tab3_namfstf3;
        tab3_namlstf    := tab3_namlstf3;
        tab3_namfstm    := tab3_namfstm3;
        tab3_namlstm    := tab3_namlstm3;
        tab3_namfstc    := tab3_namfstc3;
        tab3_namlstc    := tab3_namlstc3;
      elsif global_v_lang = '104' then
        tab3_namfath    := tab3_namfath4;
        tab3_nammoth    := tab3_nammoth4;
        tab3_namcont    := tab3_namcont4;
        tab3_namfstf    := tab3_namfstf4;
        tab3_namlstf    := tab3_namlstf4;
        tab3_namfstm    := tab3_namfstm4;
        tab3_namlstm    := tab3_namlstm4;
        tab3_namfstc    := tab3_namfstc4;
        tab3_namlstc    := tab3_namlstc4;
      elsif global_v_lang = '105' then
        tab3_namfath    := tab3_namfath5;
        tab3_nammoth    := tab3_nammoth5;
        tab3_namcont    := tab3_namcont5;
        tab3_namfstf    := tab3_namfstf5;
        tab3_namlstf    := tab3_namlstf5;
        tab3_namfstm    := tab3_namfstm5;
        tab3_namlstm    := tab3_namlstm5;
        tab3_namfstc    := tab3_namfstc5;
        tab3_namlstc    := tab3_namlstc5;
      end if;
      tab3_desc_codfnatn  := get_tcodec_name('TCODNATN',tab3_codfnatn,global_v_lang);
      tab3_desc_codfrelg  := get_tcodec_name('TCODRELI',tab3_codfrelg,global_v_lang);
      tab3_desc_codfoccu  := get_tcodec_name('TCODOCCU',tab3_codfoccu,global_v_lang);
      tab3_desc_codmnatn  := get_tcodec_name('TCODNATN',tab3_codmnatn,global_v_lang);
      tab3_desc_codmrelg  := get_tcodec_name('TCODRELI',tab3_codmrelg,global_v_lang);
      tab3_desc_codmoccu  := get_tcodec_name('TCODOCCU',tab3_codmoccu,global_v_lang);
        -- add data
        obj_row := json_object_t();
        obj_row.put('coderror', '200');
        obj_row.put('desc_coderror', ' ');
        obj_row.put('httpcode', ' ');
        obj_row.put('flg', ' ');
        -- display data
        obj_row.put('namfath',tab3_namfath);
        obj_row.put('namfathe',tab3_namfathe);
        obj_row.put('namfatht',tab3_namfatht);
        obj_row.put('namfath3',tab3_namfath3);
        obj_row.put('namfath4',tab3_namfath4);
        obj_row.put('namfath5',tab3_namfath5);
        obj_row.put('codfnatn',tab3_codfnatn);
        obj_row.put('codfrelg',tab3_codfrelg);
        obj_row.put('codfoccu',tab3_codfoccu);
        obj_row.put('numofidf',tab3_numofidf);
        obj_row.put('nammoth',tab3_nammoth);
        obj_row.put('nammothe',tab3_nammothe);
        obj_row.put('nammotht',tab3_nammotht);
        obj_row.put('nammoth3',tab3_nammoth3);
        obj_row.put('nammoth4',tab3_nammoth4);
        obj_row.put('nammoth5',tab3_nammoth5);
        obj_row.put('codmnatn',tab3_codmnatn);
        obj_row.put('codmrelg',tab3_codmrelg);
        obj_row.put('codmoccu',tab3_codmoccu);
        obj_row.put('numofidm',tab3_numofidm);
        obj_row.put('namcont',tab3_namcont);
        obj_row.put('namconte',tab3_namconte);
        obj_row.put('namcontt',tab3_namcontt);
        obj_row.put('namcont3',tab3_namcont3);
        obj_row.put('namcont4',tab3_namcont4);
        obj_row.put('namcont5',tab3_namcont5);
        obj_row.put('adrcont1',tab3_adrcont1);
        obj_row.put('codpost',tab3_codpost);
        obj_row.put('numtele',tab3_numtele);
        obj_row.put('numfax',tab3_numfax);
        obj_row.put('email',tab3_email);
        obj_row.put('desrelat',tab3_desrelat);
        obj_row.put('desc_codfnatn',tab3_desc_codfnatn);
        obj_row.put('desc_codfrelg',tab3_desc_codfrelg);
        obj_row.put('desc_codfoccu',tab3_desc_codfoccu);
        obj_row.put('desc_codmnatn',tab3_desc_codmnatn);
        obj_row.put('desc_codmrelg',tab3_desc_codmrelg);
        obj_row.put('desc_codmoccu',tab3_desc_codmoccu);
        obj_row.put('namfathe_flg',tab3_namfathe_flg);
        obj_row.put('namfatht_flg',tab3_namfatht_flg);
        obj_row.put('namfath3_flg',tab3_namfath3_flg);
        obj_row.put('namfath4_flg',tab3_namfath4_flg);
        obj_row.put('namfath5_flg',tab3_namfath5_flg);
        obj_row.put('codfnatn_flg',tab3_codfnatn_flg);
        obj_row.put('codfrelg_flg',tab3_codfrelg_flg);
        obj_row.put('codfoccu_flg',tab3_codfoccu_flg);
        obj_row.put('numofidf_flg',tab3_numofidf_flg);
        obj_row.put('nammothe_flg',tab3_nammothe_flg);
        obj_row.put('nammotht_flg',tab3_nammotht_flg);
        obj_row.put('nammoth3_flg',tab3_nammoth3_flg);
        obj_row.put('nammoth4_flg',tab3_nammoth4_flg);
        obj_row.put('nammoth5_flg',tab3_nammoth5_flg);
        obj_row.put('codmnatn_flg',tab3_codmnatn_flg);
        obj_row.put('codmrelg_flg',tab3_codmrelg_flg);
        obj_row.put('codmoccu_flg',tab3_codmoccu_flg);
        obj_row.put('numofidm_flg',tab3_numofidm_flg);
        obj_row.put('namconte_flg',tab3_namconte_flg);
        obj_row.put('namcontt_flg',tab3_namcontt_flg);
        obj_row.put('namcont3_flg',tab3_namcont3_flg);
        obj_row.put('namcont4_flg',tab3_namcont4_flg);
        obj_row.put('namcont5_flg',tab3_namcont5_flg);
        obj_row.put('adrcont1_flg',tab3_adrcont1_flg);
        obj_row.put('codpost_flg',tab3_codpost_flg);
        obj_row.put('numtele_flg',tab3_numtele_flg);
        obj_row.put('numfax_flg',tab3_numfax_flg);
        obj_row.put('email_flg',tab3_email_flg);
        obj_row.put('desrelat_flg',tab3_desrelat_flg);
        -----new
        obj_row.put('codempfa',tab3_codempfa);
        obj_row.put('codtitlf',tab3_codtitlf);
        obj_row.put('namfstf',tab3_namfstf);
        obj_row.put('namfstfe',tab3_namfstfe);
        obj_row.put('namfstft',tab3_namfstft);
        obj_row.put('namfstf3',tab3_namfstf3);
        obj_row.put('namfstf4',tab3_namfstf4);
        obj_row.put('namfstf5',tab3_namfstf5);
        obj_row.put('namlstf',tab3_namlstf);
        obj_row.put('namlstfe',tab3_namlstfe);
        obj_row.put('namlstft',tab3_namlstft);
        obj_row.put('namlstf3',tab3_namlstf3);
        obj_row.put('namlstf4',tab3_namlstf4);
        obj_row.put('namlstf5',tab3_namlstf5);
        obj_row.put('codempmo',tab3_codempmo);
        obj_row.put('codtitlm',tab3_codtitlm);
        obj_row.put('namfstm',tab3_namfstm);
        obj_row.put('namfstme',tab3_namfstme);
        obj_row.put('namfstmt',tab3_namfstmt);
        obj_row.put('namfstm3',tab3_namfstm3);
        obj_row.put('namfstm4',tab3_namfstm4);
        obj_row.put('namfstm5',tab3_namfstm5);
        obj_row.put('namlstm',tab3_namlstm);
        obj_row.put('namlstme',tab3_namlstme);
        obj_row.put('namlstmt',tab3_namlstmt);
        obj_row.put('namlstm3',tab3_namlstm3);
        obj_row.put('namlstm4',tab3_namlstm4);
        obj_row.put('namlstm5',tab3_namlstm5);
        obj_row.put('namfstc',tab3_namfstc);
        obj_row.put('namfstce',tab3_namfstce);
        obj_row.put('namfstct',tab3_namfstct);
        obj_row.put('namfstc3',tab3_namfstc3);
        obj_row.put('namfstc4',tab3_namfstc4);
        obj_row.put('namfstc5',tab3_namfstc5);
        obj_row.put('codtitlc',tab3_codtitlc);
        obj_row.put('namlstc',tab3_namlstc);
        obj_row.put('namlstce',tab3_namlstce);
        obj_row.put('namlstct',tab3_namlstct);
        obj_row.put('namlstc3',tab3_namlstc3);
        obj_row.put('namlstc4',tab3_namlstc4);
        obj_row.put('namlstc5',tab3_namlstc5);
        obj_row.put('codempfa_flg',tab3_codempfa_flg);
        obj_row.put('codtitlf_flg',tab3_codtitlf_flg);
        obj_row.put('namfstfe_flg',tab3_namfstfe_flg);
        obj_row.put('namfstft_flg',tab3_namfstft_flg);
        obj_row.put('namfstf3_flg',tab3_namfstf3_flg);
        obj_row.put('namfstf4_flg',tab3_namfstf4_flg);
        obj_row.put('namfstf5_flg',tab3_namfstf5_flg);
        obj_row.put('namlstfe_flg',tab3_namlstfe_flg);
        obj_row.put('namlstft_flg',tab3_namlstft_flg);
        obj_row.put('namlstf3_flg',tab3_namlstf3_flg);
        obj_row.put('namlstf4_flg',tab3_namlstf4_flg);
        obj_row.put('namlstf5_flg',tab3_namlstf5_flg);
        obj_row.put('codempmo_flg',tab3_codempmo_flg);
        obj_row.put('codtitlm_flg',tab3_codtitlm_flg);
        obj_row.put('namfstme_flg',tab3_namfstme_flg);
        obj_row.put('namfstmt_flg',tab3_namfstmt_flg);
        obj_row.put('namfstm3_flg',tab3_namfstm3_flg);
        obj_row.put('namfstm4_flg',tab3_namfstm4_flg);
        obj_row.put('namfstm5_flg',tab3_namfstm5_flg);
        obj_row.put('namlstme_flg',tab3_namlstme_flg);
        obj_row.put('namlstmt_flg',tab3_namlstmt_flg);
        obj_row.put('namlstm3_flg',tab3_namlstm3_flg);
        obj_row.put('namlstm4_flg',tab3_namlstm4_flg);
        obj_row.put('namlstm5_flg',tab3_namlstm5_flg);
        obj_row.put('codtitlc_flg',tab3_codtitlc_flg);
        obj_row.put('namfstce_flg',tab3_namfstce_flg);
        obj_row.put('namfstct_flg',tab3_namfstct_flg);
        obj_row.put('namfstc3_flg',tab3_namfstc3_flg);
        obj_row.put('namfstc4_flg',tab3_namfstc4_flg);
        obj_row.put('namfstc5_flg',tab3_namfstc5_flg);
        obj_row.put('namlstce_flg',tab3_namlstce_flg);
        obj_row.put('namlstct_flg',tab3_namlstct_flg);
        obj_row.put('namlstc3_flg',tab3_namlstc3_flg);
        obj_row.put('namlstc4_flg',tab3_namlstc4_flg);
        obj_row.put('namlstc5_flg',tab3_namlstc5_flg);

        obj_row.put('dtebdfa',to_char(tab3_dtebdfa,'dd/mm/yyyy'));
        obj_row.put('staliff',tab3_staliff);
        obj_row.put('dtedeathf',to_char(tab3_dtedeathf,'dd/mm/yyyy'));
        obj_row.put('filenamf',tab3_filenamf);
        obj_row.put('dtebdmo',to_char(tab3_dtebdmo,'dd/mm/yyyy'));
        obj_row.put('stalifm',tab3_stalifm);
        obj_row.put('dtedeathm',to_char(tab3_dtedeathm,'dd/mm/yyyy'));
        obj_row.put('filenamm',tab3_filenamm);
        obj_row.put('dtebdfa_flg',tab3_dtebdfa_flg);
        obj_row.put('staliff_flg',tab3_staliff_flg);
        obj_row.put('dtedeathf_flg',tab3_dtedeathf_flg);
        obj_row.put('filenamf_flg',tab3_filenamf_flg);
        obj_row.put('dtebdmo_flg',tab3_dtebdmo_flg);
        obj_row.put('stalifm_flg',tab3_stalifm_flg);
        obj_row.put('dtedeathm_flg',tab3_dtedeathm_flg);
        obj_row.put('filenamm_flg',tab3_filenamm_flg);

        json_str_output := obj_row.to_clob;
        return json_str_output;

    exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_tfamily;

  --  hres32e_detail_tab4
  function get_document return clob as
    obj_row             json_object_t;
    obj_data            json_object_t;
    json_str_output     clob;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB4';
    v_numappl           varchar2(4000 char);
    v_codcomp           varchar2(4000 char);
    tab4_numseq         varchar2(4000 char);
    tab4_typdoc         varchar2(4000 char);
    tab4_namtydoc       varchar2(4000 char);
    tab4_namdoc         varchar2(4000 char);
    tab4_dterecv        varchar2(4000 char);
    tab4_dtedocen       varchar2(4000 char);
    tab4_numdoc         varchar2(4000 char);
    tab4_filedoc        varchar2(4000 char);
    tab4_desnote        varchar2(4000 char);
    tab4_status         varchar2(4000 char);
    tab4_flgresume      tappldoc.flgresume%type;
    tab4_coduser        tappldoc.coduser%type;
    tab4_dteupd         date;
    v_numseq            varchar2(4000 char);
    v_year              varchar2(4000 char);
    v_date              varchar2(4000 char);
    v_des               varchar2(4000 char);
    tab4_staappr        varchar2(4000 char);
    tab4_dteinput       varchar2(4000 char);
    tab4_dtecancel      varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;

    --Cursor
    cursor c_tappldoc is
      select numappl,numseq,codempid,namdoc,filedoc,dterecv,dteupd,coduser,typdoc,
      dtedocen,numdoc,desnote,flgresume
        from tappldoc
       where numappl = v_numappl
    order by numseq;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 29
         and seqno    = v_numseq;

    cursor c1 is
      select distinct(seqno) as seqno
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 29
         and seqno    not in (select numseq
                                from tappldoc
                               where numappl = v_numappl)
      order by seqno;

    cursor c2(p_doc_seqno number) is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 29
         and seqno    = p_doc_seqno
      order by seqno;
    --
    begin
      obj_row  := json_object_t();
      begin
        select numappl,codcomp
          into v_numappl,v_codcomp
          from temploy1
         where codempid = b_index_codempid;
      exception when no_data_found then
        v_numappl  := null;
        v_codcomp  := null;
      end;

      if v_numappl is not null then
        begin
          select count(*) into v_rcnt from(
            select numseq
              from tappldoc
             where numappl = v_numappl
          union
            select distinct(seqno)
              from temeslog2
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and numpage  = 29
               and seqno    not in (select numseq
                                      from tappldoc
                                     where numappl = v_numappl));
        end;

        if v_rcnt > 0 then
          for r1 in c_tappldoc loop
            tab4_numseq   := r1.numseq;
            tab4_typdoc   := r1.typdoc;
            tab4_namtydoc := get_tcodec_name('TCODTYDOC',r1.typdoc,global_v_lang);
            tab4_namdoc   := r1.namdoc;
            tab4_dterecv  := to_char(r1.dterecv,'dd/mm/yyyy');
            tab4_dtedocen := to_char(r1.dtedocen,'dd/mm/yyyy');
            tab4_numdoc   := r1.numdoc;
            tab4_filedoc  := r1.filedoc;
            tab4_desnote  := r1.desnote;
            tab4_flgresume  := r1.flgresume;
            tab4_dteupd     := r1.dteupd;
            tab4_coduser    := r1.coduser;
            v_numseq := r1.numseq;
            v_num := v_num + 1;
            obj_data := json_object_t();

            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', ' ');
            obj_data.put('flg', ' ');
            -- display data
            obj_data.put('total',   v_rcnt);
            obj_data.put('rcnt',    v_num);
            obj_data.put('numseq',tab4_numseq);
            obj_data.put('typdoc',tab4_typdoc);
            obj_data.put('namtydoc',tab4_namtydoc);
            obj_data.put('namdoc',tab4_namdoc);
            obj_data.put('dterecv',tab4_dterecv);
            obj_data.put('dtedocen',tab4_dtedocen);
            obj_data.put('numdoc',tab4_numdoc);
            obj_data.put('filedoc',tab4_filedoc);
            obj_data.put('desnote',tab4_desnote);
            obj_data.put('flgresume',tab4_flgresume);
            obj_data.put('dteupd',to_char(tab4_dteupd,'dd/mm/yyyy'));
            obj_data.put('coduser',tab4_coduser);
            tab4_status := null;
            for i in c_temeslog2 loop
              tab4_status := i.status;
              if substr(i.fldedit,1,3) = 'DTE' then
                v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
                v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
                v_des  := v_date||'/'||v_year;
                obj_data.put(lower(i.fldedit),v_des); --user35 || 19/09/2017
              else
                obj_data.put(lower(i.fldedit),i.desnew); --user35 || 19/09/2017
                if i.fldedit = 'TYPDOC' then
                  obj_data.put('namtydoc',get_tcodec_name('TCODTYDOC',tab4_typdoc,global_v_lang)); --user35 || 19/09/2017
                end if;
              end if;
              begin
                select staappr into tab4_staappr
                  from tempch
                 where codempid = b_index_codempid
                   and dtereq   = b_index_dtereq
                   and numseq   = b_index_numseq
                   and typchg   = 2;
              exception when no_data_found then
                tab4_staappr := 'P';
              end;
            end loop;
            obj_data.put('desc_status',get_tlistval_name('STACHG',nvl(tab4_status,'N'),global_v_lang));
            obj_row.put(to_char(v_numseq-1),obj_data);
          end loop;

          v_num := nvl(v_numseq,0);
          for x in c1 loop
            v_num := v_num + 1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', ' ');
            obj_data.put('flg', ' ');
            obj_data.put('total',   v_rcnt);
            obj_data.put('rcnt',    v_num);
            for i in c2(x.seqno) loop
              tab4_numseq   := i.seqno;
              obj_data.put('desc_status',get_tlistval_name('STACHG',i.status,global_v_lang));
              if substr(i.fldedit,1,3) = 'DTE' then
                v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
                v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
                v_des  := v_date||'/'||v_year;
                obj_data.put(lower(i.fldedit),v_des);  --user35 || 19/09/2017
              else
                obj_data.put(lower(i.fldedit),i.desnew);  --user35 || 19/09/2017
                if i.fldedit = 'TYPDOC' then
                  obj_data.put('new_namtydoc',get_tcodec_name('TCODTYDOC',tab4_typdoc,global_v_lang));  --user35 || 19/09/2017
                end if;
              end if;
            end loop;
            begin
              select staappr into tab4_staappr
                from tempch
               where codempid = b_index_codempid
                 and dtereq   = b_index_dtereq
                 and numseq   = b_index_numseq
                 and typchg   = 2;
            exception when no_data_found then
              tab4_staappr := 'A';
            end;
            obj_data.put('no',v_num);
            obj_data.put('numseq',tab4_numseq);
            obj_data.put('v_staappr',tab4_staappr);
            obj_row.put(to_char(v_num-1),obj_data);
          end loop;
        end if;
      end if;

      json_str_output := obj_row.to_clob;
      return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_document;

  --  hres32e_detail_tab5
  function get_trewdreq return clob as
    obj_row             json_object_t;
    json_str_output     clob;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);

    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB5';

    tab5_numseq         varchar2(4000 char);
    tab5_typrewd        varchar2(4000 char);
    tab5_desrewd1       varchar2(4000 char);
    tab5_numhmref       varchar2(4000 char);
    tab5_typrewd_flg 	varchar2(10 char) := 'N';
    tab5_desrewd1_flg 	varchar2(10 char) := 'N';
    tab5_numhmref_flg 	varchar2(10 char) := 'N';

    --Cursor
    cursor c1 is
		select codempid,dtereq
	  	from tempch
		 where codempid = b_index_codempid
		   and dtereq   = b_index_dtereq
		   and numseq   = b_index_numseq
		   and typchg   = 5;

    cursor c_temeslog1 is
    select *
      from temeslog1
     where codempid = b_index_codempid
       and dtereq  	= b_index_dtereq
       and numseq   = b_index_numseq
       and numpage	= 5;
    --
    begin
      for i in c1 loop
        begin
            select desnew
              into tab5_typrewd
              from temeslog1
             where codempid = i.codempid
               and dtereq   = i.dtereq
               and numseq   = b_index_numseq
               and numpage  = 5
               and fldedit  = 'TYPREWD';
            tab5_desc_typrewd := get_tcodec_name('TCODREWD',tab5_typrewd,global_v_lang);
        exception when no_data_found then
            tab5_typrewd        := null;
            tab5_desc_typrewd   := null;
        END;

        begin
            select desnew
              into tab5_desrewd1
              from temeslog1
             where codempid = i.codempid
               and dtereq   = i.dtereq
               and numseq   = b_index_numseq
               and numpage  = 5
               and fldedit  = 'DESREWD1';
        exception when no_data_found then
            tab5_desrewd1  := null;
        end;

        begin
            select desnew
              into tab5_numhmref
              from temeslog1
             where codempid = i.codempid
               and dtereq   = i.dtereq
               and numseq   = b_index_numseq
               and numpage  = 5
               and fldedit  = 'NUMHMREF';
        exception when no_data_found then
            tab5_numhmref  := null;
        end;
      end loop;
      --
      for i in c_temeslog1 loop
        if i.fldedit = 'TYPREWD' then
          tab5_typrewd := i.desnew;
          tab5_typrewd_flg := 'Y';
        elsif i.fldedit = 'DESREWD1' then
          tab5_desrewd1  := i.desnew;
          tab5_desrewd1_flg := 'Y';
        elsif i.fldedit = 'NUMHMREF' then
          tab5_numhmref  := i.desnew;
          tab5_numhmref_flg := 'Y';
        end if;
      end loop;
        -- add data
        v_num := v_num + 1;

        obj_row := json_object_t();

        obj_row.put('coderror', '200');
        obj_row.put('desc_coderror', ' ');
        obj_row.put('httpcode', ' ');
        obj_row.put('flg', ' ');
        -- display data
        obj_row.put('typrewd',tab5_typrewd);
        obj_row.put('desrewd1',tab5_desrewd1);
        obj_row.put('numhmref',tab5_numhmref);
        obj_row.put('typrewd_flg',tab5_typrewd_flg);
        obj_row.put('desrewd1_flg',tab5_desrewd1_flg);
        obj_row.put('numhmref_flg',tab5_numhmref_flg);

        json_str_output :=  obj_row.to_clob;
        return json_str_output;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_trewdreq;

  --  hres32e_detail_tab6
  function get_education return clob as
    obj_row             json_object_t;
    obj_data            json_object_t;
    json_str_output     clob;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_numappl           varchar2(100 char);
    v_codcomp           varchar2(100 char);
    v_numseq            varchar2(100 char);
    v_date              varchar2(100 char);
    v_year              varchar2(100 char);
    v_des               varchar2(100 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB6';
    tab6_numseq         varchar2(4000 char);
    tab6_codedlv        varchar2(4000 char);
    tab6_codinst        varchar2(4000 char);
    tab6_coddglv        varchar2(4000 char);
    tab6_codmajsb       varchar2(4000 char);
    tab6_codminsb       varchar2(4000 char);
    tab6_numgpa         varchar2(4000 char);
    tab6_dtegyear       varchar2(4000 char);
    tab6_stayear        varchar2(4000 char);
    tab6_flgeduc        varchar2(4000 char);
    tab6_codcount       varchar2(4000 char);
    tab6_staappr        varchar2(4000 char);
    tab6_codcomp        varchar2(4000 char);
    tab6_codempid       varchar2(4000 char);
    tab6_desc_codedlv 	varchar2(4000 char);
    tab6_desc_coddglv   varchar2(4000 char);
    tab6_desc_codmajsb  varchar2(4000 char);
    tab6_desc_codminsb  varchar2(4000 char);
    tab6_desc_codinst   varchar2(4000 char);
    tab6_desc_codcount  varchar2(4000 char);
    tab6_flgupdat 		varchar2(4000 char);
    tab6_dteinput       varchar2(4000 char);
    tab6_dtecancel      varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;
    tab6_new_flg        varchar2(4000 char);

    --Cursor
    cursor c1 is
      select numappl,numseq,codempid,codedlv,coddglv,
             codmajsb,codminsb,codinst,codcount,
             numgpa,stayear,dtegyear,flgeduc
        from teducatn
       where numappl = v_numappl
      order by 1;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 31
         and seqno    = v_numseq;

    cursor c2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 31
         and seqno   not in (select numseq from teducatn
                              where numappl = v_numappl)
      order by seqno;

  begin
    obj_row  := json_object_t();
    begin
      select numappl,codcomp
      into v_numappl,v_codcomp
      from   temploy1
      where  codempid = b_index_codempid	;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    if v_numappl is not null then
      begin
        select count(*) into v_rcnt from(
          select numseq
          from teducatn
         where numappl = v_numappl
        union
        select distinct(seqno)
          from temeslog2
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numseq   = b_index_numseq
           and numpage  = 31
           and seqno   not in (select numseq from teducatn
                               where numappl = v_numappl));
      end;

      if v_rcnt > 0 then
        for i in c1 loop
          tab6_numseq         := i.numseq ;
          tab6_codedlv        := i.codedlv;
          tab6_codinst        := i.codinst;
          tab6_coddglv        := i.coddglv ;
          tab6_codmajsb       := i.codmajsb;
          tab6_codminsb       := i.codminsb;
          tab6_numgpa         := i.numgpa;
          tab6_dtegyear       := i.dtegyear;
          tab6_stayear        := i.stayear;
          tab6_flgeduc        := i.flgeduc;
          tab6_codcount       := i.codcount;
          tab6_staappr        := 'P';
          tab6_codcomp        := v_codcomp;
          tab6_codempid       := b_index_codempid;
          tab6_desc_codedlv   := get_tcodec_name('TCODEDUC',tab6_codedlv,global_v_lang);
          tab6_desc_coddglv   := get_tcodec_name('TCODDGEE',tab6_coddglv,global_v_lang);
          tab6_desc_codmajsb  := get_tcodec_name('TCODMAJR',tab6_codmajsb,global_v_lang);
          tab6_desc_codminsb  := get_tcodec_name('TCODSUBJ',tab6_codminsb,global_v_lang);
          tab6_desc_codinst   := get_tcodec_name('TCODINST',tab6_codinst,global_v_lang);
          tab6_desc_codcount  := get_tcodec_name('TCODCNTY',tab6_codcount,global_v_lang);
          tab6_flgupdat 		  := 'N' ;
          tab6_status         := 'N';
          tab6_desc_status    := get_tlistval_name('STACHG',tab6_status,global_v_lang);

          v_numseq := i.numseq ;
          v_num := v_num + 1;
          -- add data
          tab6_new_flg := 'N';
          obj_data := json_object_t();

          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', ' ');
          obj_data.put('flg', ' ');
          -- display data
          obj_data.put('total',   v_rcnt);
          obj_data.put('rcnt',    v_num);
          obj_data.put('numseq',tab6_numseq);
          obj_data.put('codedlv',tab6_codedlv);
          obj_data.put('codinst',tab6_codinst);
          obj_data.put('coddglv',tab6_coddglv);
          obj_data.put('codmajsb',tab6_codmajsb);
          obj_data.put('codminsb',tab6_codminsb);
          obj_data.put('numgpa',tab6_numgpa);
          obj_data.put('dtegyear',tab6_dtegyear);
          obj_data.put('stayear',tab6_stayear);
          obj_data.put('flgeduc',tab6_flgeduc);
          obj_data.put('codcount',tab6_codcount);
          obj_data.put('staappr',tab6_staappr);
          obj_data.put('codcomp',tab6_codcomp);
          obj_data.put('codempid',tab6_codempid);
          obj_data.put('desc_codedlv',tab6_desc_codedlv);
          obj_data.put('desc_coddglv',tab6_desc_coddglv);
          obj_data.put('desc_codmajsb',tab6_desc_codmajsb);
          obj_data.put('desc_codminsb',tab6_desc_codminsb);
          obj_data.put('desc_codinst',tab6_desc_codinst);
          obj_data.put('desc_codcount',tab6_desc_codcount);
          obj_data.put('flgupdat',tab6_flgupdat);
          obj_data.put('new_flg',tab6_new_flg);

          for j in c_temeslog2 loop
            if substr(j.fldedit,1,3) = 'DTE' and j.fldedit <> 'DTEGYEAR' then
              v_year := to_number(to_char(to_date(j.desnew,'dd/mm/yyyy'),'yyyy'));
              v_date := to_char(to_date(j.desnew,'dd/mm/yyyy'),'dd/mm') ;
              v_des  := v_date||'/'||v_year;
              obj_data.put(lower(j.fldedit),v_des); --user35 || 19/09/2017
            else
              obj_data.put(lower(j.fldedit),j.desnew);
              if j.fldedit = 'CODEDLV' then
                obj_data.put('desc_codedlv',get_tcodec_name('TCODEDUC',j.desnew,global_v_lang));
              elsif j.fldedit = 'CODDGLV' then
                obj_data.put('desc_coddglv',get_tcodec_name('TCODDGEE',j.desnew,global_v_lang));
              elsif j.fldedit = 'CODMAJSB' then
                obj_data.put('desc_codmajsb',get_tcodec_name('TCODMAJR',j.desnew,global_v_lang));
              elsif j.fldedit = 'CODMINSB' then
                obj_data.put('desc_codminsb',get_tcodec_name('TCODSUBJ',j.desnew,global_v_lang));
              elsif j.fldedit = 'CODINST' then
                obj_data.put('desc_codinst',get_tcodec_name('TCODINST',j.desnew,global_v_lang));
              elsif j.fldedit = 'CODCOUNT' then
                obj_data.put('desc_codcount',get_tcodec_name('TCODCNTY',j.desnew,global_v_lang));
              end if;
            end if;
            --<<user36 JAS590255 20/04/2016
            tab6_status	  	 := j.status;
            tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);
            -->>user36 JAS590255 20/04/2016
            begin
              select staappr into tab6_staappr
                from tempch
               where codempid = b_index_codempid
                 and dtereq   = b_index_dtereq
                 and numseq   = b_index_numseq
                 and typchg   = 3;
            exception when no_data_found then
              tab6_staappr := 'P';
            end;
          end loop;

          obj_data.put('status',tab6_status);
          obj_data.put('desc_status',tab6_desc_status);

          obj_row.put(to_char(v_num-1),obj_data);
        end loop;
        --
        for i in c2 loop
          --v_new_exist := true;
          if nvl(v_numseq,i.seqno) <> i.seqno or v_num = 0 then
            -- add row
            v_num := v_num +1;
            obj_data := json_object_t();

            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', ' ');
            obj_data.put('flg', ' ');
            -- display data
            obj_data.put('total',   v_rcnt);
            obj_data.put('rcnt',    v_num);
--            obj_data.put('numseq',tab6_numseq); weerayut 20/12/2017
            obj_data.put('numseq',i.seqno);
            obj_data.put('staappr',tab6_staappr);
            obj_data.put('flgupdat',tab6_flgupdat);
            obj_data.put('new_flg',tab6_new_flg);
          end if;
          --add data
          tab6_numseq := i.seqno;
          v_numseq    := i.seqno;
          tab6_status	  	 := i.status;
          tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

          tab6_new_flg := 'Y';
          if substr(i.fldedit,1,3) = 'DTE' and i.fldedit <> 'DTEGYEAR' then
            v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
            v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
            v_des  := v_date||'/'||v_year;
            obj_data.put(lower(i.fldedit),v_des); --user35 || 19/09/2017
          else
            obj_data.put(lower(i.fldedit),i.desnew); --user35 || 19/09/2017
            if i.fldedit = 'CODEDLV' then
              obj_data.put('desc_codedlv',get_tcodec_name('TCODEDUC',i.desnew,global_v_lang));
            elsif i.fldedit = 'CODDGLV' then
              obj_data.put('desc_coddglv',get_tcodec_name('TCODDGEE',i.desnew,global_v_lang));
            elsif i.fldedit = 'CODMAJSB' then
              obj_data.put('desc_codmajsb',get_tcodec_name('TCODMAJR',i.desnew,global_v_lang));
            elsif i.fldedit = 'CODMINSB' then
              obj_data.put('desc_codminsb',get_tcodec_name('TCODSUBJ',i.desnew,global_v_lang));
            elsif i.fldedit = 'CODINST' then
              obj_data.put('desc_codinst',get_tcodec_name('TCODINST',i.desnew,global_v_lang));
            elsif i.fldedit = 'CODCOUNT' then
              obj_data.put('desc_codcount',get_tcodec_name('TCODCNTY',i.desnew,global_v_lang));
            end if;
          end if;

          begin
            select staappr into tab6_staappr
              from tempch
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 3;
          exception when no_data_found then
            tab6_staappr := 'P';
          end;
          obj_data.put('status',i.status);
          obj_data.put('desc_status',tab6_desc_status);

          obj_row.put(to_char(v_num-1),obj_data);
        end loop;

--        if v_new_exist then
--          --add last row
--          obj_row.put('coderror', '200');
--          obj_row.put('desc_coderror', ' ');
--          obj_row.put('httpcode', ' ');
--          obj_row.put('flg', ' ');
--          obj_row.put('total',   v_rcnt);
--          obj_row.put('rcnt',    v_num);
--          obj_row.put('numseq',tab6_numseq);
--          obj_row.put('staappr',tab6_staappr);
--          obj_row.put('new_flg',tab6_new_flg);
--        end if;
      end if; --v_rcnt
    end if;	--v_numappl
    json_str_output := obj_row.to_clob;
    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_education;
  --  hres32e_tab3_work_exp
  function get_work_exp return clob as
    obj_row             json_object_t;
    obj_data            json_object_t;
    json_str_output     clob;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_numappl           varchar2(100 char);
    v_codcomp           varchar2(100 char);
    v_numseq            varchar2(100 char);
    v_date              varchar2(100 char);
    v_year              varchar2(100 char);
    v_des               varchar2(100 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB6';
    tab_work_exp_numappl           tapplwex.numappl%type;
    tab_work_exp_numseq            tapplwex.numseq%type;
    tab_work_exp_codempid          tapplwex.codempid%type;
    tab_work_exp_desnoffi          tapplwex.desnoffi%type;
    tab_work_exp_deslstjob1        tapplwex.deslstjob1%type;
    tab_work_exp_deslstpos         tapplwex.deslstpos%type;
    tab_work_exp_desoffi1          tapplwex.desoffi1%type;
    tab_work_exp_numteleo          tapplwex.numteleo%type;
    tab_work_exp_namboss           tapplwex.namboss%type;
    tab_work_exp_desres            tapplwex.desres%type;
    tab_work_exp_amtincom          tapplwex.amtincom%type;
    tab_work_exp_dtestart          tapplwex.dtestart%type;
    tab_work_exp_dteend            tapplwex.dteend%type;
    tab_work_exp_codtypwrk         tapplwex.codtypwrk%type;
    tab_work_exp_desjob            tapplwex.desjob%type;
    tab_work_exp_desrisk           tapplwex.desrisk%type;
    tab_work_exp_desprotc          tapplwex.desprotc%type;
    tab_work_exp_remark            tapplwex.remark%type;
    tab_work_exp_desc_codtypwrk    varchar2(4000 char);
    tab6_flgupdat 		           varchar2(4000 char);
    tab6_dteinput                  varchar2(4000 char);
    tab6_dtecancel                 varchar2(4000 char);
    v_first                        boolean := true;
    v_new_exist                    boolean := false;
    tab6_new_flg                   varchar2(4000 char);

    --Cursor
    cursor c1 is
      select numappl,numseq,codempid,desnoffi,deslstjob1,
             deslstpos,desoffi1,numteleo,namboss,desres,
             amtincom,dtestart,dteend,codtypwrk,desjob,
             desrisk,desprotc,remark,dteupd,coduser
        from tapplwex
       where numappl = v_numappl
      order by 1;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 32
         and seqno    = v_numseq;

    cursor c2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 32
         and seqno   not in (select numseq from tapplwex
                              where numappl = v_numappl)
      order by seqno;

  begin
    obj_row  := json_object_t();
    begin
      select numappl,codcomp
      into v_numappl,v_codcomp
      from   temploy1
      where  codempid = b_index_codempid	;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    if v_numappl is not null then
      for i in c1 loop
        tab_work_exp_numappl           := i.numappl;
        tab_work_exp_numseq            := i.numseq;
        tab_work_exp_codempid          := i.codempid;
        tab_work_exp_desnoffi          := i.desnoffi;
        tab_work_exp_deslstjob1        := i.deslstjob1;
        tab_work_exp_deslstpos         := i.deslstpos;
        tab_work_exp_desoffi1          := i.desoffi1;
        tab_work_exp_numteleo          := i.numteleo;
        tab_work_exp_namboss           := i.namboss;
        tab_work_exp_desres            := i.desres;
        tab_work_exp_amtincom          := i.amtincom;
        tab_work_exp_dtestart          := i.dtestart;
        tab_work_exp_dteend            := i.dteend;
        tab_work_exp_codtypwrk         := i.codtypwrk;
        tab_work_exp_desjob            := i.desjob;
        tab_work_exp_desrisk           := i.desrisk;
        tab_work_exp_desprotc          := i.desprotc;
        tab_work_exp_remark            := i.remark;
        tab_work_exp_desc_codtypwrk    := get_tcodec_name('TCODTYPWRK',tab_work_exp_codtypwrk,global_v_lang);
        tab6_staappr                   := 'P';
--        tab6_codcomp                   := v_codcomp;
--        tab6_codempid                  := b_index_codempid;
        tab6_flgupdat 		             := 'N' ;
        tab6_status                    := 'N';
        tab6_desc_status               := get_tlistval_name('STACHG',tab6_status,global_v_lang);

        v_numseq := i.numseq ;
        v_num := v_num + 1;
        -- add data
        tab6_new_flg := 'N';
        obj_data := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('numappl',tab_work_exp_numappl);
        obj_data.put('numseq',tab_work_exp_numseq);
        obj_data.put('codempid',tab_work_exp_codempid);
        obj_data.put('desnoffi',tab_work_exp_desnoffi);
        obj_data.put('deslstjob1',tab_work_exp_deslstjob1);
        obj_data.put('deslstpos',tab_work_exp_deslstpos);
        obj_data.put('desoffi1',tab_work_exp_desoffi1);
        obj_data.put('numteleo',tab_work_exp_numteleo);
        obj_data.put('namboss',tab_work_exp_namboss);
        obj_data.put('desres',tab_work_exp_desres);
        obj_data.put('amtincom',tab_work_exp_amtincom);
        obj_data.put('dtestart',to_char(tab_work_exp_dtestart,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(tab_work_exp_dteend,'dd/mm/yyyy'));
        obj_data.put('codtypwrk',tab_work_exp_codtypwrk);
        obj_data.put('desjob',tab_work_exp_desjob);
        obj_data.put('desrisk',tab_work_exp_desrisk);
        obj_data.put('desprotc',tab_work_exp_desprotc);
        obj_data.put('remark',tab_work_exp_remark);
        obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
        obj_data.put('coduser',i.coduser);
        obj_data.put('desc_codtypwrk',tab_work_exp_desc_codtypwrk);
        obj_data.put('flgupdat',tab6_flgupdat);
        obj_data.put('new_flg',tab6_new_flg);

        for j in c_temeslog2 loop
          if substr(j.fldedit,1,3) = 'DTE' and j.fldedit <> 'DTEGYEAR' then
            v_year := to_number(to_char(to_date(j.desnew,'dd/mm/yyyy'),'yyyy'));
            v_date := to_char(to_date(j.desnew,'dd/mm/yyyy'),'dd/mm') ;
            v_des  := v_date||'/'||v_year;
            obj_data.put(lower(j.fldedit),v_des); --user35 || 19/09/2017
          else
            obj_data.put(lower(j.fldedit),j.desnew);
            obj_data.put('desc_codtypwrk',get_tcodec_name('TCODTYPWRK',tab_work_exp_codtypwrk,global_v_lang));
          end if;
          --<<user36 JAS590255 20/04/2016
          tab6_status	  	 := j.status;
          tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);
          -->>user36 JAS590255 20/04/2016
          begin
            select staappr into tab6_staappr
              from tempch
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 3;
          exception when no_data_found then
            tab6_staappr := 'P';
          end;
        end loop;

        obj_data.put('status',tab6_status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;
      --
      for i in c2 loop
        --v_new_exist := true;
        if nvl(v_numseq,i.seqno) <> i.seqno or v_num = 0 then
          -- add row
          v_num := v_num +1;
          obj_data := json_object_t();

          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', ' ');
          obj_data.put('flg', ' ');
          -- display data
          obj_data.put('total',   v_rcnt);
          obj_data.put('rcnt',    v_num);
--            obj_data.put('numseq',tab6_numseq); weerayut 20/12/2017
          obj_data.put('numseq',i.seqno);
          obj_data.put('staappr',tab6_staappr);
          obj_data.put('flgupdat',tab6_flgupdat);
          obj_data.put('new_flg',tab6_new_flg);
        end if;
        --add data
        tab6_numseq := i.seqno;
        v_numseq    := i.seqno;
        tab6_status	  	 := i.status;
        tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

        tab6_new_flg := 'Y';
        if substr(i.fldedit,1,3) = 'DTE' and i.fldedit <> 'DTEGYEAR' then
          v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
          v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
          v_des  := v_date||'/'||v_year;
          obj_data.put(lower(i.fldedit),v_des); --user35 || 19/09/2017
        else
            obj_data.put(lower(i.fldedit),i.desnew); --user35 || 19/09/2017
            obj_data.put('desc_codtypwrk',get_tcodec_name('TCODTYPWRK',tab_work_exp_codtypwrk,global_v_lang));
        end if;

        begin
          select staappr into tab6_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 3;
        exception when no_data_found then
          tab6_staappr := 'P';
        end;
        obj_data.put('status',i.status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;
    end if;	--v_numappl
    json_str_output := obj_row.to_clob;
    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_work_exp;
  --  hres32e_tab5_competency
  function get_competency return clob as
    obj_row             json_object_t;
    obj_data            json_object_t;
    json_str_output     clob;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_numappl           varchar2(100 char);
    v_codcomp           varchar2(100 char);
    v_codtency          tcmptncy.codtency%type;
    v_date              varchar2(100 char);
    v_year              varchar2(100 char);
    v_des               varchar2(100 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL5_TAB1';
    v_desc_typtency     tcomptnc.namtncye%type;
    v_numseq            number  := 0;
    tab6_flgupdat 		varchar2(4000 char);
    tab6_dteinput       varchar2(4000 char);
    tab6_dtecancel      varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;
    tab6_new_flg        varchar2(4000 char);
    v_typtency          tcompskil.codtency%type;

    --Cursor
    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 51
         and codseq   = v_codtency;

    cursor c2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 51
         and codseq   not in (select  jd.codskill
                              from    temploy1 emp, tjobposskil jd, tcmptncy cpt
                              where   emp.codempid    = b_index_codempid
                              and     emp.codcomp     = jd.codcomp
                              and     emp.codpos      = jd.codpos
                              and     emp.numappl     = cpt.numappl(+)
                              and     jd.codskill     = cpt.codtency(+)
                              union all
                              select  cpt.codtency as codskill
                              from    temploy1 emp, tcmptncy cpt, tcompskil skl
                              where   emp.codempid    = b_index_codempid
                              and     emp.numappl     = cpt.numappl
                              and     cpt.codtency    = skl.codskill(+)
                              and     not exists (select  1
                                                  from    tjobposskil jd
                                                  where   jd.codpos     = emp.codpos
                                                  and     jd.codcomp    = emp.codcomp
                                                  and     jd.codskill   = cpt.codtency
                                                  and     jd.codtency   = skl.codtency))
      order by seqno;

    cursor c_tcmptncy is
      select  emp.numappl,jd.codtency as typtency,jd.codskill,cpt.grade,'JD' as typjd
      from    temploy1 emp, tjobposskil jd, tcmptncy cpt
      where   emp.codempid    = b_index_codempid
      and     emp.codcomp     = jd.codcomp
      and     emp.codpos      = jd.codpos
      and     emp.numappl     = cpt.numappl(+)
      and     jd.codskill     = cpt.codtency(+)
      union all
      select  emp.numappl,nvl(skl.codtency,'N/A') as typtency,cpt.codtency as codskill,cpt.grade,'NA' as typjd
      from    temploy1 emp, tcmptncy cpt, tcompskil skl
      where   emp.codempid    = b_index_codempid
      and     emp.numappl     = cpt.numappl
      and     cpt.codtency    = skl.codskill(+)
      and     not exists (select  1
                          from    tjobposskil jd
                          where   jd.codpos     = emp.codpos
                          and     jd.codcomp    = emp.codcomp
                          and     jd.codskill   = cpt.codtency
                          and     jd.codtency   = skl.codtency)
      order by typjd,typtency;
  begin
    obj_row  := json_object_t();
    begin
      select numappl,codcomp
        into v_numappl,v_codcomp
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    if v_numappl is not null then
      for i in c_tcmptncy loop
        v_num       := v_num + 1;
        obj_data    := json_object_t();

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
        --
        v_codtency    := i.codskill;
        for j in c_temeslog2 loop
--          if j.fldedit = 'CODTENCY' then
--            v_desc_typtency := null;
--            if j.desnew is null then
--              v_desc_typtency   := null;
--            elsif j.desnew = 'N/A' then
--              v_desc_typtency   := j.desnew;
--            else
--              v_desc_typtency   := get_tcomptnc_name(j.desnew,global_v_lang);
--            end if;
--            obj_data.put('new_desc_typtency',v_desc_typtency);
          if j.fldedit = 'CODTENCY' then
            obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',j.desnew,global_v_lang));
          else
            obj_data.put(lower(j.fldedit),j.desnew);
          end if;

          tab6_status	  	 := j.status;
          tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

          begin
            select staappr into tab6_staappr
              from tempch
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 3;
          exception when no_data_found then
            tab6_staappr := 'P';
          end;
        end loop;
        obj_data.put('status',tab6_status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;

      for i in c2 loop
        tab6_status := i.seqno;
        if nvl(v_numseq,i.seqno) <> i.seqno or v_num = 0 then
            -- add row
            v_num := v_num +1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('flg', ' ');
            obj_data.put('httpcode', ' ');
            -- display data
            obj_data.put('rcnt',    v_num);
            obj_data.put('numseq',tab6_status);
            obj_data.put('flgupdat',tab6_flgupdat);
            obj_data.put('new_flg',tab6_new_flg);
            begin
              select  codtency
              into    v_typtency
              from    tcompskil
              where   codskill  = i.codseq
              and     rownum    = 1;
            exception when no_data_found then
              v_typtency  := 'N/A';
            end;
            obj_data.put('typtency',v_typtency);
            if v_typtency = 'N/A' then
              v_desc_typtency   := v_typtency;
            else
              v_desc_typtency   := get_tcomptnc_name(v_typtency,global_v_lang);
            end if;
            obj_data.put('desc_typtency',v_desc_typtency);
            obj_data.put('codtency',i.codseq);
            obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',i.codseq,global_v_lang));
        end if;
        --add data
        v_numseq := i.seqno;
        tab6_status	  	 := i.status;
        tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

        tab6_new_flg := 'Y';
        if substr(i.fldedit,1,3) = 'DTE' then
          v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
          v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
          v_des  := v_date||'/'||v_year;
          obj_data.put(lower(i.fldedit),v_des);  --user35 || 19/09/2017
        else
--          if i.fldedit = 'TYPTENCY' then
--            v_desc_typtency := null;
--            if i.desnew is null then
--              v_desc_typtency   := null;
--            elsif i.desnew = 'N/A' then
--              v_desc_typtency   := i.desnew;
--            else
--              v_desc_typtency   := get_tcomptnc_name(i.desnew,global_v_lang);
--            end if;
--            obj_data.put('new_desc_typtency',v_desc_typtency);
          if i.fldedit = 'CODTENCY' then
            obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',i.desnew,global_v_lang));
          else
            obj_data.put(lower(i.fldedit),i.desnew);
          end if;
        end if;

        begin
          select staappr into tab6_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 4;
        exception when no_data_found then
          tab6_staappr := 'P';
        end;
        obj_data.put('status',i.status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;
    end if; --if v_numappl
    json_str_output := obj_row.to_clob;
    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_competency;
    --  hres32e_tab5_lang_abi
  function get_lang_abi return clob as
    obj_row             json_object_t;
    obj_data            json_object_t;
    json_str_output     clob;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_numappl           varchar2(100 char);
    v_codcomp           varchar2(100 char);
    v_codlang           tlangabi.codlang%type;
    v_date              varchar2(100 char);
    v_year              varchar2(100 char);
    v_des               varchar2(100 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL5_TAB1';
    v_numseq            number  := 0;
    tab6_flgupdat 		varchar2(4000 char);
    tab6_dteinput       varchar2(4000 char);
    tab6_dtecancel      varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;
    tab6_new_flg        varchar2(4000 char);

    --Cursor
    cursor c_tlangabi is
      select  numappl,codlang,codempid,
              flglist,flgspeak,flgread,flgwrite
      from    tlangabi
      where   numappl   = v_numappl
      order by codlang;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 52
--         and fldkey   = 'CODLANG'
         and codseq   = v_codlang;

    cursor c2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 52
--         and fldkey   = 'CODLANG'
         and codseq   not in (select codlang from tlangabi
                              where numappl = v_numappl)
      order by seqno;
  begin
    obj_row  := json_object_t();
    begin
      select numappl,codcomp
        into v_numappl,v_codcomp
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    if v_numappl is not null then
      for i in c_tlangabi loop
        v_num       := v_num + 1;
        obj_data    := json_object_t();

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
        --
        v_codlang    := i.codlang;
        for j in c_temeslog2 loop
          if j.fldedit = 'CODLANG' then
            obj_data.put('desc_codlang',get_tcodec_name('TCODLANG',j.desnew,global_v_lang));
          elsif j.fldedit = 'FLGLIST' then
            obj_data.put('desc_flglist',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
          elsif j.fldedit = 'FLGSPEAK' then
            obj_data.put('desc_flgspeak',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
          elsif j.fldedit = 'FLGREAD' then
            obj_data.put('desc_flgread',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
          elsif j.fldedit = 'FLGWRITE' then
            obj_data.put('desc_flgwrite',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
          end if;
          obj_data.put(lower(j.fldedit),j.desnew);
          tab6_status	  	 := j.status;
          tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

          begin
            select staappr into tab6_staappr
              from tempch
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 3;
          exception when no_data_found then
            tab6_staappr := 'P';
          end;
        end loop;
        obj_data.put('status',tab6_status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;

      for j in c2 loop
        tab6_status := j.seqno;
        if nvl(v_numseq,j.seqno) <> j.seqno or v_num = 0 then
            -- add row
            v_num := v_num +1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('flg', ' ');
            obj_data.put('httpcode', ' ');
            -- display data
            obj_data.put('rcnt',    v_num);
            obj_data.put('numseq',tab6_status);
            obj_data.put('flgupdat',tab6_flgupdat);
            obj_data.put('new_flg',tab6_new_flg);
            obj_data.put('codlang',j.codseq);
        end if;
        --add data
        v_numseq := j.seqno;
        tab6_status	  	 := j.status;
        tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

        tab6_new_flg := 'Y';
        if j.fldedit = 'codlang' then
          obj_data.put('desc_codlang',get_tcodec_name('TCODLANG',j.desnew,global_v_lang));
        elsif j.fldedit = 'FLGLIST' then
          obj_data.put('desc_flglist',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
        elsif j.fldedit = 'FLGSPEAK' then
          obj_data.put('desc_flgspeak',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
        elsif j.fldedit = 'FLGREAD' then
          obj_data.put('desc_flgread',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
        elsif j.fldedit = 'FLGWRITE' then
          obj_data.put('desc_flgwrite',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
        end if;
        obj_data.put(lower(j.fldedit),j.desnew);
        begin
          select staappr into tab6_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 4;
        exception when no_data_found then
          tab6_staappr := 'P';
        end;
        obj_data.put('status',j.status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;
    end if; --if v_numappl
    json_str_output := obj_row.to_clob;
    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_lang_abi;
    --  hres32e_tab5_lang_abi
  function get_his_reward return clob as
    obj_row             json_object_t;
    obj_data            json_object_t;
    json_str_output     clob;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_numappl           varchar2(100 char);
    v_codcomp           varchar2(100 char);
    v_dteinput          thisrewd.dteinput%type;
    v_date              varchar2(100 char);
    v_year              varchar2(100 char);
    v_des               varchar2(100 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL5_TAB3';
    v_numseq            number  := 0;
    tab6_flgupdat 		varchar2(4000 char);
    tab6_dteinput       varchar2(4000 char);
    tab6_dtecancel      varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;
    tab6_new_flg        varchar2(4000 char);

    --Cursor
    cursor c_thisrewd is
      select  codempid,dteinput,typrewd,desrewd1,
              numhmref,dteupd,coduser,filename
      from    thisrewd
      where   codempid    = b_index_codempid
      order by dteinput;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 53
         and dteseq   = v_dteinput;

    cursor c2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 53
         and dteseq   not in (select dteinput from thisrewd
                              where codempid = b_index_codempid)
      order by seqno;
  begin
    obj_row  := json_object_t();
    begin
      select numappl,codcomp
        into v_numappl,v_codcomp
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    if v_numappl is not null then
      for i in c_thisrewd loop
        v_num       := v_num + 1;
        obj_data    := json_object_t();

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
        --
        v_dteinput    := i.dteinput;
        for j in c_temeslog2 loop
          if j.fldedit = 'TYPREWD' then
            obj_data.put('desc_typrewd',get_tcodec_name('TCODREWD',j.desnew,global_v_lang));
          end if;
          obj_data.put(lower(j.fldedit),j.desnew);
          tab6_status	  	 := j.status;
          tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

          begin
            select staappr into tab6_staappr
              from tempch
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 5;
          exception when no_data_found then
            tab6_staappr := 'P';
          end;
        end loop;
        obj_data.put('status',tab6_status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;

      for j in c2 loop
        tab6_status := j.seqno;
        if nvl(v_numseq,j.seqno) <> j.seqno or v_num = 0 then
            -- add row
            v_num := v_num +1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('flg', ' ');
            obj_data.put('httpcode', ' ');
            -- display data
            obj_data.put('rcnt',v_num);
            obj_data.put('numseq',tab6_status);
            obj_data.put('flgupdat',tab6_flgupdat);
            obj_data.put('new_flg',tab6_new_flg);
            obj_data.put('dteinput',to_char(j.dteseq,'dd/mm/yyyy'));
        end if;
        --add data
        v_numseq := j.seqno;
        tab6_status	  	 := j.status;
        tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

        tab6_new_flg := 'Y';
        if j.fldedit = 'TYPREWD' then
          obj_data.put('desc_typrewd',get_tcodec_name('TCODREWD',j.desnew,global_v_lang));
        end if;
        obj_data.put(lower(j.fldedit),j.desnew);

        begin
          select staappr into tab6_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 4;
        exception when no_data_found then
          tab6_staappr := 'P';
        end;
        obj_data.put('status',j.status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;
    end if; --if v_numappl
    json_str_output := obj_row.to_clob;
    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_his_reward;
  --
  function get_childen return clob as
    obj_row             json_object_t;
    obj_data            json_object_t;
    json_str_output     clob;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB7';
    v_numappl           varchar2(4000 char);
    v_codcomp           varchar2(4000 char);
    v_numseq            varchar2(100 char);
    tab7_numseq         tchildrn.numseq%type;
    tab7_codtitle       tchildrn.codtitle%type;
    tab7_namfirst       tchildrn.namfirste%type;
    tab7_namfirste      tchildrn.namfirste%type;
    tab7_namfirstt      tchildrn.namfirstt%type;
    tab7_namfirst3      tchildrn.namfirst3%type;
    tab7_namfirst4      tchildrn.namfirst4%type;
    tab7_namfirst5      tchildrn.namfirst5%type;
    tab7_namlast        tchildrn.namlaste%type;
    tab7_namlaste       tchildrn.namlaste%type;
    tab7_namlastt       tchildrn.namlastt%type;
    tab7_namlast3       tchildrn.namlast3%type;
    tab7_namlast4       tchildrn.namlast4%type;
    tab7_namlast5       tchildrn.namlast5%type;
    tab7_namch          tchildrn.namche%type;
    tab7_namche         tchildrn.namche%type;
    tab7_namcht         tchildrn.namcht%type;
    tab7_namch3         tchildrn.namch3%type;
    tab7_namch4         tchildrn.namch4%type;
    tab7_namch5         tchildrn.namch5%type;
    tab7_numoffid       tchildrn.numoffid%type;
    tab7_dtechbd        tchildrn.dtechbd%type;
    tab7_codsex         tchildrn.codsex%type;
    tab7_codedlv        tchildrn.codedlv%type;
    tab7_stachld        tchildrn.stachld%type;
    tab7_stalife        tchildrn.stalife%type;
    tab7_dtedthch       tchildrn.dtedthch%type;
    tab7_flginc         tchildrn.flginc%type;
    tab7_flgedlv        tchildrn.flgedlv%type;
    tab7_flgdeduct      tchildrn.flgdeduct%type;
    tab7_stabf          tchildrn.stabf%type;
    tab7_filename       tchildrn.filename%type;
    tab7_desc_codtitle  varchar2(500 char);
    tab7_desc_codsex    varchar2(500 char);
    v_desflgedlv        varchar2(500 char);
    v_desflgded         varchar2(500 char);
    tab7_flgupdat       varchar2(4000 char);
    tab7_staappr        varchar2(4000 char);
    tab7_status 	 	varchar2(4000 char);
    tab7_desc_status    varchar2(4000 char);
    tab7_new_flg        varchar2(4000 char);
    v_year              varchar2(4000 char);
    v_date              varchar2(4000 char);
    v_des               varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;
    v_label_edu_y       varchar2(500) := get_label_name('HRES32EP4',global_v_lang,190);
    v_label_edu_n       varchar2(500) := get_label_name('HRES32EP4',global_v_lang,200);
    v_label_ded_y       varchar2(500) := get_label_name('HRES32EP4',global_v_lang,220);
    v_label_ded_n       varchar2(500) := get_label_name('HRES32EP4',global_v_lang,230);
    --Cursor
    cursor c1 is
      select --numseq,dtechbd,namchild,codsex,codedlv,numoffid,flgedlv,flgdeduct
             numseq,codtitle,
             namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
             namlaste,namlastt,namlast3,namlast4,namlast5,
             namche,namcht,namch3,namch4,namch5,
             numoffid,dtechbd,codsex,codedlv,stachld,
             stalife,dtedthch,flginc,flgedlv,flgdeduct,
             stabf,filename,numrefdoc
        from tchildrn
       where codempid = b_index_codempid
      order by numseq  ;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 41
         and seqno    = v_numseq;

    cursor c_2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 41
         and seqno   not in (select numseq from tchildrn
                                          where codempid = b_index_codempid)
      order by seqno;
    ---
    begin
      --
      begin
        select count(*) into v_rcnt from(
          select numseq
            from tchildrn
       where codempid = b_index_codempid
        union
          select distinct(seqno)
            from temeslog2
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and numpage  = 41
             and seqno   not in (select numseq from tchildrn
                                              where codempid = b_index_codempid));
      end;
      --
    obj_row  := json_object_t();
    if v_rcnt > 0 then
      --
      for i in c1 loop
        tab7_numseq          := i.numseq;
        tab7_codtitle        := i.codtitle;
        tab7_namfirste       := i.namfirste;
        tab7_namfirstt       := i.namfirstt;
        tab7_namfirst3       := i.namfirst3;
        tab7_namfirst4       := i.namfirst4;
        tab7_namfirst5       := i.namfirst5;
        tab7_namlaste        := i.namlaste;
        tab7_namlastt        := i.namlastt;
        tab7_namlast3        := i.namlast3;
        tab7_namlast4        := i.namlast4;
        tab7_namlast5        := i.namlast5;
        tab7_namche          := i.namche;
        tab7_namcht          := i.namcht;
        tab7_namch3          := i.namch3;
        tab7_namch4          := i.namch4;
        tab7_namch5          := i.namch5;
        tab7_numoffid        := i.numoffid;
        tab7_dtechbd         := i.dtechbd;
        tab7_codsex          := i.codsex;
        tab7_codedlv         := i.codedlv;
        tab7_stachld         := i.stachld;
        tab7_stalife         := i.stalife;
        tab7_dtedthch        := i.dtedthch;
        tab7_flginc          := i.flginc;
        tab7_flgedlv         := i.flgedlv;
        tab7_flgdeduct       := i.flgdeduct;
        tab7_stabf           := i.stabf;
        tab7_filename        := i.filename;

        tab7_desc_codtitle   := get_tlistval_name('CODTITLE',i.codtitle,global_v_lang);
        tab7_desc_codsex     := get_tlistval_name('NAMSEX',i.codsex,global_v_lang);

        if i.flgedlv = 'N' then
          v_desflgedlv  := v_label_edu_n;
        else
          v_desflgedlv  := v_label_edu_y;
        end if;
        if i.flgdeduct = 'N' then
          v_desflgded  := v_label_ded_y;
        else
          v_desflgded  := v_label_ded_y;
        end if;

        if global_v_lang = '101' then
          tab7_namfirst   := tab7_namfirste;
          tab7_namlast    := tab7_namlaste;
          tab7_namch      := tab7_namche;
        elsif global_v_lang = '102' then
          tab7_namfirst   := tab7_namfirstt;
          tab7_namlast    := tab7_namlastt;
          tab7_namch      := tab7_namcht;
        elsif global_v_lang = '103' then
          tab7_namfirst   := tab7_namfirst3;
          tab7_namlast    := tab7_namlast3;
          tab7_namch      := tab7_namch3;
        elsif global_v_lang = '104' then
          tab7_namfirst   := tab7_namfirst4;
          tab7_namlast    := tab7_namlast4;
          tab7_namch      := tab7_namch4;
        elsif global_v_lang = '105' then
          tab7_namfirst   := tab7_namfirst5;
          tab7_namlast    := tab7_namlast5;
          tab7_namch      := tab7_namch5;
        end if;

        tab7_status       := 'N';
        tab7_desc_status  := get_tlistval_name('STACHG',tab7_status,global_v_lang);
        v_numseq := i.numseq ;
        v_num := v_num + 1;
        -- add data
        tab7_new_flg := 'N';
        obj_data := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('numseq',tab7_numseq);
        obj_data.put('codtitle',tab7_codtitle);
        obj_data.put('namfirst',tab7_namfirst);
        obj_data.put('namfirste',tab7_namfirste);
        obj_data.put('namfirstt',tab7_namfirstt);
        obj_data.put('namfirst3',tab7_namfirst3);
        obj_data.put('namfirst4',tab7_namfirst4);
        obj_data.put('namfirst5',tab7_namfirst5);
        obj_data.put('namlast',tab7_namlast);
        obj_data.put('namlaste',tab7_namlaste);
        obj_data.put('namlastt',tab7_namlastt);
        obj_data.put('namlast3',tab7_namlast3);
        obj_data.put('namlast4',tab7_namlast4);
        obj_data.put('namlast5',tab7_namlast5);
        obj_data.put('namchild',tab7_namch);
        obj_data.put('namche',tab7_namche);
        obj_data.put('namcht',tab7_namcht);
        obj_data.put('namch3',tab7_namch3);
        obj_data.put('namch4',tab7_namch4);
        obj_data.put('namch5',tab7_namch5);
        obj_data.put('numoffid',tab7_numoffid);
        obj_data.put('dtechbd',to_char(tab7_dtechbd,'dd/mm/yyyy'));
        obj_data.put('codsex',tab7_codsex);
        obj_data.put('codedlv',tab7_codedlv);
        obj_data.put('stachld',tab7_stachld);
        obj_data.put('stalife',tab7_stalife);
        obj_data.put('dtedthch',to_char(tab7_dtedthch,'dd/mm/yyyy'));
        obj_data.put('flginc',tab7_flginc);
        obj_data.put('flgedlv',tab7_flgedlv);
        obj_data.put('flgdeduct',tab7_flgdeduct);
        obj_data.put('stabf',tab7_stabf);
        obj_data.put('filename',tab7_filename);
        obj_data.put('desc_codtitle',tab7_desc_codtitle);
        obj_data.put('desc_codsex',tab7_desc_codsex);
        obj_data.put('desc_flgedlv',v_desflgedlv);
        obj_data.put('desc_flgdeduct',v_desflgded);
        obj_data.put('flgupdat',tab7_flgupdat);
        obj_data.put('staappr',tab7_staappr);
        obj_data.put('new_flg',tab7_new_flg);

        for j in c_temeslog2 loop
          if substr(j.fldedit,1,3) = 'DTE' then
            v_year := to_number(to_char(to_date(j.desnew,'dd/mm/yyyy'),'yyyy'));
            v_date := to_char(to_date(j.desnew,'dd/mm/yyyy'),'dd/mm') ;
            v_des  := v_date||'/'||v_year;
            obj_data.put(lower(j.fldedit),v_des);  --user35 || 19/09/2017
          else
            if lower(j.fldedit) = 'codsex' then
              obj_data.put('desc_codsex',get_tlistval_name('NAMSEX',j.desnew,global_v_lang));
            elsif lower(j.fldedit) = 'codedlv' then
              obj_data.put('desc_codedlv',get_tcodec_name('TCODEDUC',j.desnew,global_v_lang));
            elsif lower(j.fldedit) = 'codtitle' then
              obj_data.put('desc_codtitle',get_tlistval_name('CODTITLE',j.desnew,global_v_lang));
            elsif lower(j.fldedit) = 'flgedlv' then
              v_desflgedlv  := '';
              if j.desnew = 'N' then
                v_desflgedlv  := v_label_edu_n;
              else
                v_desflgedlv  := v_label_edu_y;
              end if;
              obj_data.put('desc_flgedlv',v_desflgedlv);
            elsif lower(j.fldedit) = 'flgdeduct' then
              v_desflgded   := '';
              if j.desnew = 'N' then
                v_desflgded  := v_label_ded_n;
              else
                v_desflgded  := v_label_ded_y;
              end if;
              obj_data.put('desc_flgdeduct',v_desflgded);
            end if;
            if global_v_lang = '101' and j.fldedit = 'NAMCHE' then
              obj_data.put('namchild',j.desnew);
            elsif global_v_lang = '102' and j.fldedit = 'NAMCHT'  then
              obj_data.put('namchild',j.desnew);
            elsif global_v_lang = '103' and j.fldedit = 'NAMCH3'  then
              obj_data.put('namchild',j.desnew);
            elsif global_v_lang = '104' and j.fldedit = 'NAMCH4'  then
              obj_data.put('namchild',j.desnew);
            elsif global_v_lang = '105' and j.fldedit = 'NAMCH5'  then
              obj_data.put('namchild',j.desnew);
            end if;
            obj_data.put(lower(j.fldedit),j.desnew);
          end if;

          tab7_status	  	 := j.status;
          tab7_desc_status := get_tlistval_name('STACHG',tab7_status,global_v_lang);

          begin
            select staappr into tab7_staappr
              from tempch
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 4;
          exception when no_data_found then
            tab7_staappr := 'P';
          end;
        end loop;
        obj_data.put('status',tab7_status);
        obj_data.put('desc_status',tab7_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;

      for i in c_2 loop
--        v_new_exist := true;
        tab7_numseq := i.seqno;
        if nvl(v_numseq,i.seqno) <> i.seqno or v_num = 0 then
            -- add row
            v_num := v_num +1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('flg', ' ');
            obj_data.put('httpcode', ' ');
            -- display data
            obj_data.put('rcnt',    v_num);
            obj_data.put('numseq',tab7_numseq);
            obj_data.put('flgupdat',tab7_flgupdat);
            obj_data.put('new_flg',tab7_new_flg);
        end if;
        --add data
        v_numseq := i.seqno;
        tab7_status	  	 := i.status;
        tab7_desc_status := get_tlistval_name('STACHG',tab7_status,global_v_lang);

        tab7_new_flg := 'Y';
        if substr(i.fldedit,1,3) = 'DTE' then
          v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
          v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
          v_des  := v_date||'/'||v_year;
          obj_data.put(lower(i.fldedit),v_des);  --user35 || 19/09/2017
        else
          if lower(i.fldedit) = 'codsex' then
            obj_data.put('desc_codsex',get_tlistval_name('NAMSEX',i.desnew,global_v_lang));
          elsif lower(i.fldedit) = 'codedlv' then
            obj_data.put('desc_codedlv',get_tcodec_name('TCODEDUC',i.desnew,global_v_lang));
          elsif lower(i.fldedit) = 'codtitle' then
            obj_data.put('desc_codtitle',get_tlistval_name('CODTITLE',i.desnew,global_v_lang));
          elsif lower(i.fldedit) = 'flgedlv' then
            v_desflgedlv  := '';
            if i.desnew = 'N' then
              v_desflgedlv  := v_label_edu_n;
            else
              v_desflgedlv  := v_label_edu_y;
            end if;
            obj_data.put('desc_flgedlv',v_desflgedlv);
          elsif lower(i.fldedit) = 'flgdeduct' then
            v_desflgded   := '';
            if i.desnew = 'N' then
              v_desflgded  := v_label_ded_n;
            else
              v_desflgded  := v_label_ded_y;
            end if;
            obj_data.put('desc_flgdeduct',v_desflgded);
          end if;

          if global_v_lang = '101' and i.fldedit = 'NAMFIRSTE' then
            obj_data.put('namfirst',i.desnew);
          elsif global_v_lang = '102' and i.fldedit = 'NAMFIRSTT'  then
            obj_data.put('namfirst',i.desnew);
          elsif global_v_lang = '103' and i.fldedit = 'NAMFIRST3'  then
            obj_data.put('namfirst',i.desnew);
          elsif global_v_lang = '104' and i.fldedit = 'NAMFIRST4'  then
            obj_data.put('namfirst',i.desnew);
          elsif global_v_lang = '105' and i.fldedit = 'NAMFIRST5'  then
            obj_data.put('namfirst',i.desnew);
          end if;

          if global_v_lang = '101' and i.fldedit = 'NAMLASTE' then
            obj_data.put('namlast',i.desnew);
          elsif global_v_lang = '102' and i.fldedit = 'NAMLASTT'  then
            obj_data.put('namlast',i.desnew);
          elsif global_v_lang = '103' and i.fldedit = 'NAMLAST3'  then
            obj_data.put('namlast',i.desnew);
          elsif global_v_lang = '104' and i.fldedit = 'NAMLAST4'  then
            obj_data.put('namlast',i.desnew);
          elsif global_v_lang = '105' and i.fldedit = 'NAMLAST5'  then
            obj_data.put('namlast',i.desnew);
          end if;

          if global_v_lang = '101' and i.fldedit = 'NAMCHE' then
            obj_data.put('namchild',i.desnew);
          elsif global_v_lang = '102' and i.fldedit = 'NAMCHT'  then
            obj_data.put('namchild',i.desnew);
          elsif global_v_lang = '103' and i.fldedit = 'NAMCH3'  then
            obj_data.put('namchild',i.desnew);
          elsif global_v_lang = '104' and i.fldedit = 'NAMCH4'  then
            obj_data.put('namchild',i.desnew);
          elsif global_v_lang = '105' and i.fldedit = 'NAMCH5'  then
            obj_data.put('namchild',i.desnew);
          end if;

          obj_data.put(lower(i.fldedit),i.desnew);
        end if;

        begin
          select staappr into tab7_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 4;
        exception when no_data_found then
          tab7_staappr := 'P';
        end;
        obj_data.put('status',i.status);
        obj_data.put('desc_status',tab7_desc_status);

          obj_row.put(to_char(v_num-1),obj_data);
      end loop;

--      if v_new_exist then
--        --add last row
--        obj_row.put('coderror', '200');
--        obj_row.put('desc_coderror', ' ');
--        obj_row.put('httpcode', ' ');
--        obj_row.put('flg', ' ');
--        obj_row.put('rcnt',    v_num);
--        obj_row.put('numseq',tab7_numseq);
--        obj_row.put('flgupdat',tab7_flgupdat);
--        obj_row.put('namsex','M');
--
--      end if;
    end if; -- v_rcnt
    json_str_output := obj_row.to_clob;
    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_childen;

  --  hres32e_detail_tab8_e
  function get_tdeductd_e return clob as
    obj_row             json_object_t;
    obj_data            json_object_t;
    json_str_output     clob;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB8_1';
    v_numappl           varchar2(4000 char);
    v_codcomp           varchar2(4000 char);
    v_numseq            varchar2(100 char);
    v_amtdeduct		    varchar2(20 char);
    v_amtspded          varchar2(20 char);
    v_coddeduct		    varchar2(20 char);
    tab8_coddeduct      varchar2(4000 char);
    tab8_desdeduct      varchar2(4000 char);
    tab8_v_amtdeduct    varchar2(4000 char);
    tab8_v_amtdeduct_spous varchar2(4000 char);
    tab8_amtdeduct      varchar2(4000 char);
    tab8_typdeduct      varchar2(4000 char);
    tab8_qtychned       varchar2(4000 char);
    tab8_qtychedu       varchar2(4000 char);
    v_year              varchar2(4000 char);
    v_date              varchar2(4000 char);
    v_des               varchar2(4000 char);
    flg_new_e           varchar2(4000 char);

    --Cursor
   	cursor c_e is
      select coddeduct,typdeduct
        from tdeductd
       where dteyreff  = (select max(dteyreff)
                            from tdeductd
                           where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                             and codcompy = get_codcompy(b_index_codcomp))
         and typdeduct = 'E'
         and codcompy = get_codcompy(b_index_codcomp)
         AND coddeduct NOT IN ('E001');
      --
      cursor c_temeslog3 is
      select *
        from temeslog3
       where codempid  = b_index_codempid
         and dtereq  	 = b_index_dtereq
         and numseq  	 = b_index_numseq
         and codcomp   = b_index_codcomp
         and numpage   in (281,881)
         AND typdeduct = 'E'
         AND coddeduct NOT IN ('E001');
    --
    begin
      begin
         select codcomp  into b_index_codcomp
           from temploy1
          where codempid = b_index_codempid;
      exception when no_data_found then
        b_index_codcomp  :=   null;
      end;
      begin
        select count(*) into v_rcnt from(
          select coddeduct
            from tdeductd
           where dteyreff  = (select max(dteyreff)
                                from tdeductd
                               where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                                 and codcompy = get_codcompy(b_index_codcomp))
             and typdeduct = 'E'
             and coddeduct not in ('E001')
             and codcompy = get_codcompy(b_index_codcomp));
      end;
      obj_row  := json_object_t();
      if v_rcnt > 0 then
        --
        for i in c_e loop
          begin
            select amtdeduct into v_amtdeduct
              from tempdech
             where codempid  = b_index_codempid
               and dtereq    = b_index_dtereq
               and coddeduct = i.coddeduct
               and typdeduct = 'E';
          exception when no_data_found then
            v_amtdeduct := 	null;
          end;

          if v_amtdeduct is null then
            begin
              select amtdeduct into v_amtdeduct
                from tempded
               where codempid  = b_index_codempid
                 and coddeduct = i.coddeduct;
            exception when no_data_found then
              v_amtdeduct := 	null;
            end;
          end if;
          -- for amtdeduct_spous
          begin
            select amtspded into v_amtspded
              from tempdech
             where codempid  = b_index_codempid
               and dtereq    = b_index_dtereq
               and coddeduct = i.coddeduct
               and typdeduct = 'E';
          exception when no_data_found then
            v_amtspded := null;
          end;
          if v_amtspded is null then
            begin
              select amtspded into v_amtspded
                from tempded
               where codempid  = b_index_codempid
                 and coddeduct = i.coddeduct;
            exception when no_data_found then
              v_amtspded := null;
            end;
          end if;
          --------------------
          if i.coddeduct is not null then
            tab8_coddeduct   := i.coddeduct;
            tab8_desdeduct   := get_tcodeduct_name(i.coddeduct,global_v_lang);
            tab8_v_amtdeduct := stddec(v_amtdeduct,b_index_codempid,v_chken);
            tab8_v_amtdeduct_spous := stddec(v_amtspded,b_index_codempid,v_chken);
            tab8_amtdeduct   := v_amtdeduct;
            tab8_typdeduct   := i.typdeduct;
            flg_new_e   := 'N';
            --
            for j in c_temeslog3 loop
              v_coddeduct := j.coddeduct;
              if tab8_coddeduct = v_coddeduct then
                if j.numpage = 281 then
                  tab8_v_amtdeduct := stddec(j.desnew,b_index_codempid,v_chken);
                elsif j.numpage = 881 then
                  tab8_v_amtdeduct_spous := stddec(j.desnew,b_index_codempid,v_chken);
                end if;
                flg_new_e   := 'Y';
              end if;
            end loop;
            --
            v_num := v_num + 1;
            -- add data
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('flg', ' ');
            obj_data.put('httpcode', ' ');
            -- display data
            obj_data.put('total',v_rcnt);
            obj_data.put('rcnt' ,v_num);
            obj_data.put('coddeduct',tab8_coddeduct);
            obj_data.put('desdeduct',tab8_desdeduct);
--            obj_data.put('v_amtdeduct',tab8_v_amtdeduct);
            obj_data.put('amtdeduct',tab8_v_amtdeduct);
            obj_data.put('amtdeduct_spous',tab8_v_amtdeduct_spous);
            obj_data.put('typdeduct',tab8_typdeduct);
            obj_data.put('qtychedu',nvl(tab8_qtychedu,0));
            obj_data.put('qtychned',nvl(tab8_qtychned,0));
            obj_data.put('flg_new_e',nvl(flg_new_e,0));

            obj_row.put(to_char(v_num-1),obj_data);
          end if;
        end loop;
        --
      end if; --v_rcnt

      json_str_output := obj_row.to_clob;
      return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_tdeductd_e;

  --  hres32e_detail_tab8_2
  function get_tdeductd_d return clob as
  obj_row             json_object_t;
  obj_data            json_object_t;
  json_str_output     clob;
  v_rcnt              number := 0;
  v_num               number := 0;
  v_concat            varchar2(1 char);
  --
  global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB8_2';
  --
  v_numappl           varchar2(4000 char);
  v_codcomp           varchar2(4000 char);
  v_numseq            varchar2(100 char);
  v_amtdeduct		  varchar2(20 char);
  v_amtspded          varchar2(20 char);
  v_coddeduct		  varchar2(20 char);
  tab8_coddeduct      varchar2(4000 char);
  tab8_desdeduct      varchar2(4000 char);
  tab8_v_amtdeduct    varchar2(4000 char);
  tab8_v_amtdeduct_spous varchar2(4000 char);
  tab8_amtdeduct      varchar2(4000 char);
  tab8_typdeduct      varchar2(4000 char);
  tab8_qtychned       varchar2(4000 char);
  tab8_qtychedu       varchar2(4000 char);
  v_year              varchar2(4000 char);
  v_date              varchar2(4000 char);
  v_des               varchar2(4000 char);
  flg_new_d           varchar2(4000 char);
  tab8_qtychned_flg   varchar2(20):= 'N';
  tab8_qtychedu_flg   varchar2(20):= 'N';

    --Cursor
    cursor c_d is
      select coddeduct,typdeduct
        from tdeductd
       where dteyreff  = (select max(dteyreff)
                            from tdeductd
                           where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                             and codcompy = get_codcompy(b_index_codcomp))
         and typdeduct = 'D'
         and codcompy = get_codcompy(b_index_codcomp)
         and coddeduct not in ('D001','D002');

      cursor c_temeslog3 is
      select *
        from temeslog3
       where codempid  = b_index_codempid
         and dtereq  	 = b_index_dtereq
         and numseq  	 = b_index_numseq
         and numpage   in (282,882)
         and codcomp   = b_index_codcomp
         and typdeduct = 'D'
         and coddeduct not in ('D001','D002');

      cursor c_temeslog1 is
      select fldedit,desnew
        from temeslog1
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and codcomp  = b_index_codcomp
         and numpage  in (2,222);

    begin
      begin
         select codcomp  into b_index_codcomp
           from temploy1
          where codempid = b_index_codempid;
      exception when no_data_found then
        b_index_codcomp  :=   null;
      end;
      begin
        select count(*)
          into v_rcnt
          from( select coddeduct
                  from tdeductd
                 where dteyreff  = ( select max(dteyreff)
                                       from tdeductd
                                      where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                                        and codcompy = get_codcompy(b_index_codcomp))
               and typdeduct = 'D'
               and coddeduct not in ('D001','D002')
               and codcompy = get_codcompy(b_index_codcomp));
      end;
      obj_row  := json_object_t();
      if v_rcnt > 0 then
       begin
          select qtychedu,qtychned
          into   tab8_qtychedu,tab8_qtychned
          from   temploy3
          where  codempid  = b_index_codempid ;
       exception when no_data_found then
          tab8_qtychedu := 0 ;
          tab8_qtychned := 0 ;
       end ;
      begin
         select codcomp  into b_index_codcomp
           from temploy1
          where codempid = b_index_codempid;
      exception when no_data_found then
        b_index_codcomp  :=   null;
      end;

      for i in c_d loop
        begin
          select amtdeduct into v_amtdeduct
            from tempdech
           where codempid  = b_index_codempid
             and dtereq    = b_index_dtereq
             and coddeduct = i.coddeduct
             and typdeduct = 'D';
        exception when no_data_found then
          v_amtdeduct := 	null;
        end;
        if v_amtdeduct is null then
          begin
            select amtdeduct into v_amtdeduct
              from tempded
             where codempid  = b_index_codempid
               and coddeduct = i.coddeduct;
          exception when no_data_found then
            v_amtdeduct := 	null;
          end;
        end if;
        -- for amtdeduct_spous
        begin
          select amtspded into v_amtspded
            from tempdech
           where codempid  = b_index_codempid
             and dtereq    = b_index_dtereq
             and coddeduct = i.coddeduct
             and typdeduct = 'D';
        exception when no_data_found then
          v_amtspded := null;
        end;
        if v_amtspded is null then
          begin
            select amtspded into v_amtspded
              from tempded
             where codempid  = b_index_codempid
               and coddeduct = i.coddeduct;
          exception when no_data_found then
            v_amtspded := null;
          end;
        end if;
        --------------------
        if i.coddeduct is not null then
          tab8_coddeduct   := i.coddeduct;
          tab8_desdeduct   := get_tcodeduct_name(i.coddeduct,global_v_lang);
          tab8_v_amtdeduct := stddec(v_amtdeduct,b_index_codempid,v_chken);
          tab8_v_amtdeduct_spous := stddec(v_amtspded,b_index_codempid,v_chken);
          tab8_amtdeduct   := v_amtdeduct;
          tab8_typdeduct   := i.typdeduct;
          flg_new_d   := 'N';

          for j in c_temeslog3 loop
            v_coddeduct := j.coddeduct;
            if tab8_coddeduct = v_coddeduct then
              if j.numpage = 282 then
                tab8_v_amtdeduct := stddec(j.desnew,b_index_codempid,v_chken);
              elsif j.numpage = 882 then
                tab8_v_amtdeduct_spous := stddec(j.desnew,b_index_codempid,v_chken);
              end if;
              flg_new_d   := 'Y';
            end if;
          end loop;

          for k in c_temeslog1 loop
            if k.fldedit = 'QTYCHNED' then
            tab8_qtychned := k.desnew;
            tab8_qtychned_flg := 'Y';
            elsif k.fldedit = 'QTYCHEDU' then
            tab8_qtychedu := k.desnew;
            tab8_qtychedu_flg := 'Y';
            end if;
          end loop;
          v_num := v_num + 1;
          -- add data
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', ' ');
          obj_data.put('flg', ' ');
          -- display data
          obj_data.put('total',   v_rcnt);
          obj_data.put('rcnt',    v_num);
          obj_data.put('coddeduct',tab8_coddeduct);
          obj_data.put('desdeduct',tab8_desdeduct);
--          obj_data.put('v_amtdeduct',tab8_v_amtdeduct);
          obj_data.put('amtdeduct',tab8_v_amtdeduct);
          obj_data.put('amtdeduct_spous',tab8_v_amtdeduct_spous);
          obj_data.put('typdeduct',tab8_typdeduct);
          obj_data.put('qtychedu',nvl(tab8_qtychedu,0));
          obj_data.put('qtychned',nvl(tab8_qtychned,0));
          obj_data.put('flg_new_d',nvl(flg_new_d,0));
          obj_data.put('qtychned_flg',nvl(tab8_qtychned_flg,0));
          obj_data.put('qtychedu_flg',nvl(tab8_qtychedu_flg,0));

          obj_row.put(to_char(v_num-1),obj_data);
        end if;
      end loop;
      --
      end if; --v_rcnt
      json_str_output := obj_row.to_clob;
      return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_tdeductd_d;

  --  hres32e_detail_tab8_3
  function get_tdeductd_o return clob as
    obj_row             json_object_t;
    obj_data            json_object_t;
    json_str_output     clob;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_coddeduct		    varchar2(20 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB8_3';
    v_numappl           varchar2(4000 char);
    v_codcomp           varchar2(4000 char);
    v_numseq            varchar2(100 char);
    v_amtdeduct		    varchar2(20 char);
    v_amtspded          varchar2(20 char);
    tab8_coddeduct      varchar2(4000 char);
    tab8_desdeduct      varchar2(4000 char);
    tab8_v_amtdeduct    varchar2(4000 char);
    tab8_v_amtdeduct_spous varchar2(4000 char);
    tab8_amtdeduct      varchar2(4000 char);
    tab8_typdeduct      varchar2(4000 char);
    tab8_qtychned       varchar2(4000 char);
    tab8_qtychedu       varchar2(4000 char);
    v_year              varchar2(4000 char);
    v_date              varchar2(4000 char);
    v_des               varchar2(4000 char);
    flg_new_o           varchar2(4000 char);

    --Cursor
    cursor c_o is
      select coddeduct,typdeduct
        from tdeductd
       where dteyreff  = (select max(dteyreff)
                            from tdeductd
                           where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                             and codcompy = get_codcompy(b_index_codcomp))
         and codcompy = get_codcompy(b_index_codcomp)
         and typdeduct = 'O';

      cursor c_temeslog3 is
      select *
        from temeslog3
       where codempid  = b_index_codempid
         and dtereq  	 = b_index_dtereq
         and numseq  	 = b_index_numseq
         and codcomp  = b_index_codcomp
         and numpage   in (283,883)
         and typdeduct = 'O';

    begin
      --
      begin
         select codcomp  into b_index_codcomp
           from temploy1
          where codempid = b_index_codempid;
      exception when no_data_found then
        b_index_codcomp  :=   null;
      end;
      begin
        select count(*)
          into v_rcnt
          from ( select coddeduct
                  from tdeductd
                 where dteyreff  = (  select max(dteyreff)
                                      from tdeductd
                                      where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                                      and codcompy = get_codcompy(b_index_codcomp))
          and codcompy = get_codcompy(b_index_codcomp)
          and typdeduct = 'O');
      end;
      obj_row := json_object_t();
      if v_rcnt > 0 then
        --
        for i in c_o loop
        begin
          select amtdeduct into v_amtdeduct
            from tempdech
           where codempid  = b_index_codempid
             and dtereq    = b_index_dtereq
             and coddeduct = i.coddeduct
             and typdeduct = 'O';
            exception when no_data_found then
              v_amtdeduct := 	null;
          end;
          if v_amtdeduct is null then
            begin
              select amtdeduct into v_amtdeduct
                from tempded
               where codempid  = b_index_codempid
                 and coddeduct = i.coddeduct;
            exception when no_data_found then
              v_amtdeduct := 	null;
            end;
          end if;
          -- for amtdeduct_spous
          begin
            select amtspded into v_amtspded
              from tempdech
             where codempid  = b_index_codempid
               and dtereq    = b_index_dtereq
               and coddeduct = i.coddeduct
               and typdeduct = 'O';
          exception when no_data_found then
            v_amtspded := null;
          end;
          if v_amtspded is null then
            begin
              select amtspded into v_amtspded
                from tempded
               where codempid  = b_index_codempid
                 and coddeduct = i.coddeduct;
            exception when no_data_found then
              v_amtspded := null;
            end;
          end if;
          --------------------
          if i.coddeduct is not null then
            tab8_coddeduct   := i.coddeduct;
            tab8_desdeduct   := get_tcodeduct_name(i.coddeduct,global_v_lang);
            tab8_v_amtdeduct := stddec(v_amtdeduct,b_index_codempid,v_chken);
            tab8_v_amtdeduct_spous := stddec(v_amtspded,b_index_codempid,v_chken);
            tab8_amtdeduct   := v_amtdeduct;
            tab8_typdeduct   := i.typdeduct;
            flg_new_o   := 'N';

            for j in c_temeslog3 loop
              v_coddeduct := j.coddeduct;
              if tab8_coddeduct = v_coddeduct then
                if j.numpage = 283 then
                  tab8_v_amtdeduct := stddec(j.desnew,b_index_codempid,v_chken);
                elsif j.numpage = 883 then
                  tab8_v_amtdeduct_spous := stddec(j.desnew,b_index_codempid,v_chken);
                end if;
                flg_new_o   := 'Y';
              end if;
            end loop;
            v_num := v_num + 1;
            -- add data
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', ' ');
            obj_data.put('flg', ' ');
            -- display data
            obj_data.put('total',   v_rcnt);
            obj_data.put('rcnt',    v_num);
            obj_data.put('coddeduct',tab8_coddeduct);
            obj_data.put('desdeduct',tab8_desdeduct);
--            obj_data.put('v_amtdeduct',tab8_v_amtdeduct);
            obj_data.put('amtdeduct',tab8_v_amtdeduct);
            obj_data.put('amtdeduct_spous',tab8_v_amtdeduct_spous);
            obj_data.put('typdeduct',tab8_typdeduct);
            obj_data.put('qtychedu',nvl(tab8_qtychedu,0));
            obj_data.put('qtychned',nvl(tab8_qtychned,0));
            obj_data.put('flg_new_o',nvl(flg_new_o,0));

            obj_row.put(to_char(v_num-1),obj_data);
          end if;
        end loop;
      end if; --v_rcnt
      json_str_output := obj_row.to_clob;
      return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_tdeductd_o;

  --  hres32e_detail_tab9
  function get_tempch return varchar2 is
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB9';
    v_numappl           varchar2(4000 char);
    v_codcomp           varchar2(4000 char);
    v_numseq            varchar2(100 char);
    v_year              varchar2(4000 char);
    v_date              varchar2(4000 char);
    v_des               varchar2(4000 char);
    tab9_dessubdistr  	varchar2(4000 char);
    tab9_desdistr  		varchar2(4000 char);
    tab9_desprovr  	 	varchar2(4000 char);
    tab9_descntyr 	 	varchar2(4000 char);
    tab9_dessubdistc    varchar2(4000 char);
    tab9_desdistc  	    varchar2(4000 char);
    tab9_desprovc  	 	varchar2(4000 char);
    tab9_descntyc 	 	varchar2(4000 char);
    tab9_desprovi  		varchar2(4000 char);
    tab9_desc_codfnatn  varchar2(4000 char);
    tab9_desc_codfrelg  varchar2(4000 char);
    tab9_desc_codfoccu  varchar2(4000 char);
    tab9_desc_codmnatn  varchar2(4000 char);
    tab9_desc_codmrelg  varchar2(4000 char);
    tab9_desc_codmoccu  varchar2(4000 char);
    tab9_desc_codspocc  varchar2(4000 char);
    tab9_desc_codsppro  varchar2(4000 char);
    tab9_desc_codspcty  varchar2(4000 char);
    tab9_desc_codbank 	varchar2(4000 char);
    tab9_desc_codbank2	varchar2(4000 char);
    tab9_codsubdistr    varchar2(4000 char);
    tab9_coddistr       varchar2(4000 char);
    tab9_codprovr       varchar2(4000 char);
    tab9_codcntyr       varchar2(4000 char);
    tab9_codsubdistc    varchar2(4000 char);
    tab9_coddistc       varchar2(4000 char);
    tab9_codprovc       varchar2(4000 char);
    tab9_codcntyc       varchar2(4000 char);
    tab9_codprovi       varchar2(4000 char);
    tab9_codfnatn       varchar2(4000 char);
    tab9_codfrelg       varchar2(4000 char);
    tab9_codfoccu       varchar2(4000 char);
    tab9_codmnatn       varchar2(4000 char);
    tab9_codmrelg       varchar2(4000 char);
    tab9_codmoccu       varchar2(4000 char);
    tab9_codspocc       varchar2(4000 char);
    tab9_codsppro       varchar2(4000 char);
    tab9_codspcty       varchar2(4000 char);
    tab9_codbank        varchar2(4000 char);
    tab9_codbank2       varchar2(4000 char);
    tab9_adrreg         varchar2(4000 char);
    tab9_staappr        varchar2(4000 char);
    tab9_adrrege        varchar2(4000 char);
    tab9_adrcont        varchar2(4000 char);
    tab9_adrconte       varchar2(4000 char);
    tab9_adrregt        varchar2(4000 char);
    tab9_adrcontt       varchar2(4000 char);
    tab9_adrreg3        varchar2(4000 char);
    tab9_adrcont3       varchar2(4000 char);
    tab9_adrreg4        varchar2(4000 char);
    tab9_adrcont4       varchar2(4000 char);
    tab9_adrreg5        varchar2(4000 char);
    tab9_adrcont5       varchar2(4000 char);

    --Cursor
    cursor c_temeslog1 is
      select fldedit,desnew,numpage
        from temeslog1
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  in (2,222);

    cursor c_temeslog3 is
      select numpage,coddeduct,desnew
        from temeslog3
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq;

    begin
      v_file_name := global_v_codapp||'.txt';
      v_file := utl_file.fopen ('UTL_DIR', v_file_name, 'w');

      begin
        select count(*) into v_rcnt from(
          select numseq
            from temeslog1
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and numpage  in (2,222)
        union
          select distinct(numseq)
            from temeslog3
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq);
      end;
      --
      v_rcnt := 1;
      if v_rcnt > 0 then
        json_long := '{"status":"success","data":{"total":"'||v_rcnt||'","rows":[';
        utl_file.putf(v_file,json_long);
        utl_file.new_line(v_file);
        v_concat := '';
        --
        for i in c_temeslog1 loop
          if substr(i.fldedit,1,3) = 'DTE' then
            v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
            v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
            v_des  := v_date||'/'||v_year;
            tab_fldedit(i.fldedit) := v_des;
          end if;
        end loop;
        --
        tab9_dessubdistr  	  := get_tsubdist_name(tab9_codsubdistr,global_v_lang) ;
        tab9_desdistr  		    := get_tcoddist_name(tab9_coddistr,global_v_lang) ;
        tab9_desprovr  	 	    := get_tcodec_name('TCODPROV',tab9_codprovr,global_v_lang);
        tab9_descntyr 	 	 	  := get_tcodec_name('TCODCNTY',tab9_codcntyr,global_v_lang);
        tab9_dessubdistc      := get_tsubdist_name(tab9_codsubdistc,global_v_lang) ;
        tab9_desdistc  	      := get_tcoddist_name(tab9_coddistc,global_v_lang) ;
        tab9_desprovc  	 	    := get_tcodec_name('TCODPROV',tab9_codprovc,global_v_lang);
        tab9_descntyc 	 	 	  := get_tcodec_name('TCODCNTY',tab9_codcntyc,global_v_lang);
        tab9_desprovi  		    := get_tcodec_name('TCODPROV',tab9_codprovi,global_v_lang);

        tab9_desc_codfnatn    := get_tcodec_name('TCODNATN',tab9_codfnatn,global_v_lang);
        tab9_desc_codfrelg    := get_tcodec_name('TCODRELI',tab9_codfrelg,global_v_lang);
        tab9_desc_codfoccu    := get_tcodec_name('TCODOCCU',tab9_codfoccu,global_v_lang);
        tab9_desc_codmnatn    := get_tcodec_name('TCODNATN',tab9_codmnatn,global_v_lang);
        tab9_desc_codmrelg    := get_tcodec_name('TCODRELI',tab9_codmrelg,global_v_lang);
        tab9_desc_codmoccu    := get_tcodec_name('TCODOCCU',tab9_codmoccu,global_v_lang);

        tab9_desc_codspocc    := get_tcodec_name('TCODOCCU',tab9_codspocc,global_v_lang);
        tab9_desc_codsppro    := get_tcodec_name('TCODPROV',tab9_codsppro,global_v_lang);
        tab9_desc_codspcty    := get_tcodec_name('TCODCNTY',tab9_codspcty,global_v_lang);

        tab9_desc_codbank 	  := get_tcodec_name('TCODBANK',tab9_codbank,global_v_lang);
        tab9_desc_codbank2	  := get_tcodec_name('TCODBANK',tab9_codbank2,global_v_lang);

        for i in c_temeslog3 loop
          v_num := v_num + 1;
          -- add data
          obj_row := json_object_t();
          obj_row.put('coderror', '200');
          obj_row.put('desc_coderror', ' ');
          obj_row.put('flg', ' ');
          obj_row.put('httpcode', ' ');
          -- display data
          obj_row.put('no',    v_num);
          obj_row.put('dessubdistr',tab9_dessubdistr);
          obj_row.put('desdistr',tab9_desdistr);
          obj_row.put('desprovr',tab9_desprovr);
          obj_row.put('descntyr',tab9_descntyr);
          obj_row.put('dessubdistc',tab9_dessubdistc);
          obj_row.put('desdistc',tab9_desdistc);
          obj_row.put('desprovc',tab9_desprovc);
          obj_row.put('descntyc',tab9_descntyc);
          obj_row.put('desprovi',tab9_desprovi);
          obj_row.put('desprovi',tab9_desc_codfnatn);
          obj_row.put('desprovi',tab9_desc_codfrelg);
          obj_row.put('desprovi',tab9_desc_codfoccu);
          obj_row.put('desprovi',tab9_desc_codmnatn);
          obj_row.put('desprovi',tab9_desc_codmrelg);
          obj_row.put('desprovi',tab9_desc_codmoccu);
          obj_row.put('desprovi',tab9_desc_codspocc);
          obj_row.put('desprovi',tab9_desc_codsppro);
          obj_row.put('desprovi',tab9_desc_codspcty);
          obj_row.put('desprovi',tab9_desc_codbank);
          obj_row.put('desprovi',tab9_desc_codbank2);

          json_long := obj_row.to_clob;
          utl_file.putf(v_file, v_concat||json_long);
          v_concat := ',';
        end loop;

        begin
          select staappr into tab9_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 2;
        exception when no_data_found then
          tab9_staappr := 'P';
        end;

        if global_v_lang = '101' then
           tab9_adrreg  := tab9_adrrege ;
           tab9_adrcont := tab9_adrconte ;
        elsif global_v_lang = '102' then
           tab9_adrreg  := tab9_adrregt ;
           tab9_adrcont := tab9_adrcontt ;
        elsif global_v_lang = '103' then
          tab9_adrreg  := tab9_adrreg3 ;
          tab9_adrcont := tab9_adrcont3 ;
        elsif global_v_lang = '104' then
          tab9_adrreg  := tab9_adrreg4 ;
          tab9_adrcont := tab9_adrcont4 ;
        elsif global_v_lang = '105' then
          tab9_adrreg  := tab9_adrreg5 ;
          tab9_adrcont := tab9_adrcont5 ;
        end if;
        json_long := ']}}';
        utl_file.putf(v_file,json_long);
        utl_file.fclose(v_file);
      end if; --v_rcnt
      return v_file_name;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_tempch;

  --  hres32e_detail_tab10
  function get_ttrainbf return clob as
    obj_row               json_object_t;
    obj_data              json_object_t;
    json_str_output       clob;
    v_rcnt                number := 0;
    v_num                 number := 0;
    v_concat              varchar2(1 char);
    global_v_codapp       varchar2(4000 char) := 'HRES32E_DETAIL_TAB10';
    v_numappl             varchar2(4000 char);
    v_codcomp             varchar2(4000 char);
    v_numseq              varchar2(100 char);
    v_year                varchar2(4000 char);
    v_date                varchar2(4000 char);
    v_des                 varchar2(4000 char);
    tab10_numseq          varchar2(4000 char);
    tab10_destrain        varchar2(4000 char);
    tab10_desc_destrain   varchar2(4000 char);
    tab10_dtetr		      varchar2(4000 char);
    tab10_dtetrain        varchar2(4000 char);
    tab10_dtetren         varchar2(4000 char);
    tab10_desplace        varchar2(4000 char);
    tab10_desinstu        varchar2(4000 char);
    tab10_filedoc         varchar2(4000 char);
    tab10_flgupdat        varchar2(4000 char);
    tab10_status          varchar2(4000 char);
    tab10_desc_status     varchar2(4000 char);
    tab10_staappr         varchar2(4000 char);
    v_first               boolean := true;
    v_new_exist           boolean := false;

    --Cursor
    cursor c1 is
      select numappl,numseq,codempid,destrain,dtetrain,
             dtetren,desplace,desinstu,filedoc
        from ttrainbf
       where numappl = v_numappl
      order by numseq ;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 61
         and seqno    = v_numseq;

    cursor c2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 61
         and seqno   not in ( select numseq from ttrainbf
                                            where numappl = v_numappl)
      order by seqno;
    ---
    begin
      obj_row := json_object_t();
      begin
        select numappl,codcomp
        into v_numappl,v_codcomp
        from   temploy1
        where  codempid = b_index_codempid;
      exception when no_data_found then
        v_numappl  := null;
        v_codcomp  := null;
      end;

      if v_numappl is not null then
        begin
          select count(*) into v_rcnt from(
            select numseq
              from ttrainbf
             where numappl = v_numappl
          union
            select distinct(seqno)
              from temeslog2
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and numpage  = 61
               and seqno   not in (select numseq
                                    from ttrainbf
                                    where numappl = v_numappl));
        end;
      obj_row := json_object_t();
--      if v_rcnt > 0 then -- USER32 OSS0001 27/02/2020
        --
          for i in c1 loop
            tab10_numseq   := i.numseq ;
            tab10_destrain := i.destrain;
            tab10_desc_destrain := replace(i.destrain,chr(10),' ');
            tab10_dtetr		 := to_char(i.dtetrain,'dd/mm/yyyy')||' - '||to_char(i.dtetren,'dd/mm/yyyy');
            tab10_dtetrain := to_char(i.dtetrain,'dd/mm/yyyy');
            tab10_dtetren  := to_char(i.dtetren,'dd/mm/yyyy') ;
            tab10_desplace := i.desplace ;
            tab10_desinstu := i.desinstu  ;
            tab10_filedoc  := i.filedoc  ;
            tab10_flgupdat := 'N' ;
            tab10_status := 'N' ;
            tab10_desc_status := get_tlistval_name('STACHG',tab10_status,global_v_lang);

            v_numseq := i.numseq ;
            v_num := v_num + 1;
            -- add data
            obj_data := json_object_t();

            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', ' ');
            obj_data.put('flg', ' ');
            -- display data
            obj_data.put('total',   v_rcnt);
            obj_data.put('rcnt',    v_num);
            obj_data.put('numseq',tab10_numseq);
            obj_data.put('destrain',tab10_destrain);
            obj_data.put('desc_destrain',tab10_desc_destrain);
            obj_data.put('dtetr',tab10_dtetr);
            obj_data.put('dtetrain',tab10_dtetrain);
            obj_data.put('dtetren',tab10_dtetren);
            obj_data.put('desplace',tab10_desplace);
            obj_data.put('desinstu',tab10_desinstu);
            obj_data.put('filedoc',tab10_filedoc);
            obj_data.put('flgupdat',tab10_flgupdat);
            obj_data.put('status',tab10_status);
            obj_data.put('desc_status',tab10_desc_status);

            for j in c_temeslog2 loop
              if substr(j.fldedit,1,3) = 'DTE' then
                v_year := to_number(to_char(to_date(j.desnew,'dd/mm/yyyy'),'yyyy'));
                v_date := to_char(to_date(j.desnew,'dd/mm/yyyy'),'dd/mm');
                v_des  := v_date||'/'||v_year;
                obj_data.put(lower(j.fldedit),j.desnew);
              else
                obj_data.put(lower(j.fldedit),j.desnew);
                obj_data.put('desc_destrain',replace(tab10_destrain,chr(10),' '));
                obj_data.put('dtetrain',tab10_dtetrain);
                obj_data.put('dtetren',tab10_dtetren);
              end if;

              --<<user36 JAS590255 20/04/2016
              obj_data.put('status',j.status);
              obj_data.put('desc_status',get_tlistval_name('STACHG',j.status,global_v_lang));
              -->>user36 JAS590255 20/04/2016
            end loop;

            begin
              select staappr into tab10_staappr
                from tempch
               where codempid = b_index_codempid
                 and dtereq   = b_index_dtereq
                 and numseq   = b_index_numseq
                 and typchg   = 6;
            exception when no_data_found then
                tab10_staappr := 'P';
            end;

            obj_row.put(to_char(v_num-1),obj_data);
          end loop;
          --
          v_numseq  := null;
          obj_data  := json_object_t();
          for i in c2 loop
            v_new_exist := true;
            if nvl(v_numseq,i.seqno) <> i.seqno then
              v_num := v_num + 1;
              obj_data.put('coderror', '200');
              obj_data.put('desc_coderror', ' ');
              obj_data.put('flg', ' ');
              obj_data.put('httpcode', ' ');
              -- display data
              obj_data.put('rcnt',    v_num);
              obj_data.put('numseq',tab10_numseq);
              obj_data.put('flgupdat',tab10_flgupdat);
              obj_data.put('status',tab10_status);
              obj_data.put('desc_status',tab10_desc_status);
              obj_row.put(to_char(v_num-1),obj_data);
              obj_data := json_object_t();
            end if;
            --add data
            tab10_numseq  := i.seqno;
            v_numseq      := i.seqno;
            tab10_status      := i.status;
            tab10_desc_status := get_tlistval_name('STACHG',tab10_status,global_v_lang);
            if substr(i.fldedit,1,3) = 'DTE' then
              v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
              v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
              v_des  := v_date||'/'||v_year;
               obj_data.put(lower(i.fldedit),i.desnew);
            else
              obj_data.put(lower(i.fldedit),i.desnew);
            end if;

            begin
              select staappr into tab10_staappr
                from tempch
               where codempid = b_index_codempid
                 and dtereq   = b_index_dtereq
                 and numseq   = b_index_numseq
                 and typchg   = 6;
            exception when no_data_found then
                tab10_staappr := 'P';
            end;
          end loop;

          if v_new_exist then
            --add last row
            v_num := v_num + 1;
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', ' ');
            obj_data.put('flg', ' ');
            -- display data
            obj_data.put('rcnt',    v_num);
            obj_data.put('numseq',tab10_numseq);
            obj_data.put('flgupdat',tab10_flgupdat);
            obj_data.put('status',tab10_status);
            obj_data.put('desc_status',tab10_desc_status);
            obj_row.put(to_char(v_num-1),obj_data);
          end if;

--      end if; --v_rcnt
    end if;
    json_str_output := obj_row.to_clob;
    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_ttrainbf;
   --  hres32e_tab2_relatives
  function get_relatives return clob as
    obj_row             json_object_t;
    obj_data            json_object_t;
    json_str_output     clob;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_TAB2_RELATIVES';
    v_codcomp           varchar2(4000 char);
    v_numseq            varchar2(4000 char);
    v_year              varchar2(4000 char);
    v_date              varchar2(4000 char);
    v_des               varchar2(4000 char);
    tab4_staappr        varchar2(4000 char);
    tab4_dteinput       varchar2(4000 char);
    tab4_dtecancel      varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;

    --Cursor
    cursor c_trelatives is
      select numseq,codemprl,namrele,namrelt,namrel3,namrel4,namrel5,numtelec,adrcomt,
             decode(global_v_lang,'101',namrele
                                 ,'102',namrelt
                                 ,'103',namrel3
                                 ,'104',namrel4
                                 ,'105',namrel5) as namrel
        from trelatives
       where codempid = b_index_codempid
    order by numseq;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 26
         and seqno    = v_numseq;

    cursor c1 is
      select distinct(seqno) as seqno
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 26
         and seqno    not in (select numseq
                                from trelatives
                               where codempid = b_index_codempid)
      order by seqno;

    cursor c2(p_doc_seqno number) is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 26
         and seqno    = p_doc_seqno
      order by seqno;
    --
  begin
    obj_row  := json_object_t();

    for r1 in c_trelatives loop
      tab2_relatives_numseq        := r1.numseq;
      tab2_relatives_codemprl      := r1.codemprl;
      tab2_relatives_namrele       := r1.namrele;
      tab2_relatives_namrelt       := r1.namrelt;
      tab2_relatives_namrel3       := r1.namrel3;
      tab2_relatives_namrel4       := r1.namrel4;
      tab2_relatives_namrel5       := r1.namrel5;
      tab2_relatives_numtelec      := r1.numtelec;
      tab2_relatives_adrcomt       := r1.adrcomt;
      v_num := v_num + 1;
      obj_data := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('numseq',tab2_relatives_numseq);
      obj_data.put('codemprl',tab2_relatives_codemprl);
      obj_data.put('namrel',r1.namrel);
      obj_data.put('namrele',tab2_relatives_namrele);
      obj_data.put('namrelt',tab2_relatives_namrelt);
      obj_data.put('namrel3',tab2_relatives_namrel3);
      obj_data.put('namrel4',tab2_relatives_namrel4);
      obj_data.put('namrel5',tab2_relatives_namrel5);
      obj_data.put('numtelec',tab2_relatives_numtelec);
      obj_data.put('adrcomt',tab2_relatives_adrcomt);
      tab4_status := null;

      v_numseq := r1.numseq;
      for i in c_temeslog2 loop
        tab4_status := i.status;
        if substr(i.fldedit,1,3) = 'DTE' then
          v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
          v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
          v_des  := v_date||'/'||v_year;
          obj_data.put(lower(i.fldedit),v_des); --user35 || 19/09/2017
        else
          obj_data.put(lower(i.fldedit),i.desnew); --user35 || 19/09/2017
          if global_v_lang = '101' and i.fldedit = 'NAMRELE' then
            obj_data.put('namrel',i.desnew);
          elsif global_v_lang = '102' and i.fldedit = 'NAMRELT'  then
            obj_data.put('namrel',i.desnew);
          elsif global_v_lang = '103' and i.fldedit = 'NAMREL3'  then
            obj_data.put('namrel',i.desnew);
          elsif global_v_lang = '104' and i.fldedit = 'NAMREL4'  then
            obj_data.put('namrel',i.desnew);
          elsif global_v_lang = '105' and i.fldedit = 'NAMREL5'  then
            obj_data.put('namrel',i.desnew);
          end if;
        end if;
        begin
          select staappr into tab4_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 2;
        exception when no_data_found then
          tab4_staappr := 'P';
        end;
      end loop;
      obj_data.put('desc_status',get_tlistval_name('STACHG',nvl(tab4_status,'N'),global_v_lang));
      obj_row.put(to_char(v_num-1),obj_data);
    end loop;

    v_num := nvl(v_num,0);
    for x in c1 loop
      v_num := v_num + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', ' ');
      obj_data.put('flg', ' ');
      obj_data.put('total',   v_rcnt);
      obj_data.put('rcnt',    v_num);
      for i in c2(x.seqno) loop
        tab4_numseq   := i.seqno;
        obj_data.put('desc_status',get_tlistval_name('STACHG',i.status,global_v_lang));
        if substr(i.fldedit,1,3) = 'DTE' then
          v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
          v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
          v_des  := v_date||'/'||v_year;
          obj_data.put(lower(i.fldedit),v_des);  --user35 || 19/09/2017
        else
          obj_data.put(lower(i.fldedit),i.desnew);  --user35 || 19/09/2017
          if global_v_lang = '101' and i.fldedit = 'NAMRELE' then
            obj_data.put('namrel',i.desnew);
          elsif global_v_lang = '102' and i.fldedit = 'NAMRELT'  then
            obj_data.put('namrel',i.desnew);
          elsif global_v_lang = '103' and i.fldedit = 'NAMREL3'  then
            obj_data.put('namrel',i.desnew);
          elsif global_v_lang = '104' and i.fldedit = 'NAMREL4'  then
            obj_data.put('namrel',i.desnew);
          elsif global_v_lang = '105' and i.fldedit = 'NAMREL5'  then
            obj_data.put('namrel',i.desnew);
          end if;
        end if;
      end loop;
      begin
        select staappr into tab4_staappr
          from tempch
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numseq   = b_index_numseq
           and typchg   = 2;
      exception when no_data_found then
        tab4_staappr := 'A';
      end;
      obj_data.put('no',v_num);
      obj_data.put('numseq',tab4_numseq);
      obj_data.put('v_staappr',tab4_staappr);
      obj_row.put(to_char(v_num-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end get_relatives;
  --
 procedure upd_tempded (p_block in varchar2, p_typdeduct in varchar2, p_coddeduct in varchar2, p_amtdeduct in varchar2) is
	v_exist			boolean;
	v_upd			boolean;
	v_dteyrepay		number;
	v_coddeduct 	tempded.coddeduct%type;
	v_amtdedold     varchar2(20 char);
	v_amtdeduct 	varchar2(20 char);
	v_count         number := 0;
  v_codcompy    tcompny.codcompy%type;

	cursor c_tempded is
		select t2.amtdeduct,t2.amtspded
		  from tdeductd t1
      left join tempded t2
        on t1.coddeduct = t2.coddeduct
       and t2.codempid  = b_index_codempid
		 where t1.codcompy  = v_codcompy
       and t1.dteyreff  = (select max(dteyreff)
                             from tdeductd
                            where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                              and codcompy = v_codcompy)
       and t1.coddeduct = v_coddeduct
       and t1.typdeduct = p_typdeduct;

  begin
  v_coddeduct := p_coddeduct;
  v_amtdeduct := stdenc(p_amtdeduct,b_index_codempid,v_chken);
  v_exist     := false;
  v_upd       := false;
  begin
    select hcm_util.get_codcomp_level(codcomp,1)
      into v_codcompy
      from temploy1
     where codempid = b_index_codempid;
  exception when no_data_found then
    null;
  end;
    for i in c_tempded loop
      v_exist := true;
      v_upd   := false;
--      upd_log3(b_index_numseq,'tempch',substr(p_block,4,2),p_typdeduct,v_coddeduct,i.amtdeduct,v_amtdeduct,v_upd);
--      v_amtdeduct := i.amtdeduct;
      if p_block like 'tab2%' then
        upd_log3(b_index_numseq,'tempch',substr(p_block,4,3),p_typdeduct,v_coddeduct,i.amtdeduct,v_amtdeduct,v_upd);
        v_amtdeduct := i.amtdeduct;
      else --p_block like 'tab8%'
        upd_log3(b_index_numseq,'tempch',substr(p_block,4,3),p_typdeduct,v_coddeduct,i.amtspded,v_amtdeduct,v_upd);
        v_amtdeduct := i.amtspded;
      end if;
      --
      if v_upd then
        begin
          select count(*) into v_count
            from tempch
           where codempid  = b_index_codempid
             and dtereq    = b_index_dtereq
             and numseq    = b_index_numseq
             and typchg    = 2;
        exception when no_data_found then
          v_count := 0;
        end;
        --
        if v_count <> 0 then
          update tempch
             set approvno  = tab2_approvno,
                 staappr   = 'P',
                 codappr   = tab2_codappr,
                 remarkap  = tab2_remarkap,
                 dteappr   = tab2_dteappr,
                 routeno   = tab2_routeno,
                 codinput  = global_v_codempid,
                 dtecancel = tab2_dtecancel,
                 coduser	 = global_v_coduser
           where codempid  = b_index_codempid
             and dtereq    = b_index_dtereq
             and numseq    = b_index_numseq
             and typchg    = 2;
        else
          insert into tempch ( codempid,dtereq,typchg,
                               numseq,codcomp,dteinput,
                               approvno,staappr,codappr,
                               remarkap,dteappr,routeno,
                               codinput,
                               dtecancel,coduser)
                      values ( b_index_codempid,b_index_dtereq,2,
                               b_index_numseq,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                               tab2_approvno,'P',tab2_codappr,
                               tab2_remarkap,tab2_dteappr,tab2_routeno,
                               global_v_codempid,
                               tab2_dtecancel,global_v_coduser);
        end if;
      end if;
    end loop;
    if not v_exist then
       upd_log3(b_index_numseq,'tempch',substr(p_block,4,3),p_typdeduct,v_coddeduct,null,v_amtdeduct,v_upd);
    end if;
  end;
  --
 procedure chk_json_tab2_6(json_obj json_object_t, p_numtb number,json_obj_tb out json_object_t,v_rowcount_tb out number) as
 begin
    if nvl(p_numtb,0) = 1 then
      json_obj_tb := hcm_util.get_json_t(json_obj,to_char('table1'));
      v_rowcount_tb := json_obj_tb.get_size;
    elsif nvl(p_numtb,0) = 2 then
      json_obj_tb := hcm_util.get_json_t(json_obj,to_char('table2'));
      v_rowcount_tb := json_obj_tb.get_size;
    elsif nvl(p_numtb,0) = 3 then
      json_obj_tb := hcm_util.get_json_t(json_obj,to_char('table3'));
      v_rowcount_tb := json_obj_tb.get_size;
  end if;
 end;

  procedure call_save_tab2(p_ritem varchar2,p_tabno number) is
    v_aler 				    boolean;
    v_upd  				    boolean;
    v_exist				    boolean;
    v_stamarry 		        varchar2(1 char);
    v_count                 number := 0;
    v_qtychedu		        number;
    v_qtychned		        number;
    v_codbank 	            varchar2(4 char);
    v_numbank 		        varchar2(15 char);
    v_amtbank 		        number;
    v_codbank2 		        varchar2(4 char);
    v_numbank2		        varchar2(15 char);
    v_numbrnch              temploy3.numbrnch%type;
    v_numbrnch2             temploy3.numbrnch%type;
    v_amttranb              temploy3.amttranb%type;
    v_numseq    	        number;
    v_numappl               varchar(20 char);
    tab2_6_1_coddeduct      varchar2(100 char);
    tab2_6_2_coddeduct      varchar2(100 char);
    tab2_6_3_coddeduct      varchar2(100 char);
    tab2_6_1_amtdeduct      varchar2(100 char);
    tab2_6_2_amtdeduct      varchar2(100 char);
    tab2_6_3_amtdeduct      varchar2(100 char);

    cursor c_temploy1 is
      select a.email,a.lineid,a.nummobile,a.stamarry,
             a.stamilit,a.dteretire,a.rowid
        from temploy1 a
       where a.codempid = b_index_codempid;

    cursor c_temploy2 is
      select a.*,a.rowid
        from temploy2 a
       where a.codempid = b_index_codempid;

    cursor c_tfamily is
      select /*codempid,namfathr,codfnatn,codfrelg,codfoccu,
             numofidf,nammothr,codmnatn,codmrelg,codmoccu,
             numofidm,namcont,adrcont1,codpost,numtele,
             numfax,email,desrelat,dteupd,coduser,*/
             codempfa,codtitlf,
             namfstfe,namfstft,namfstf3,namfstf4,namfstf5,
             namlstfe,namlstft,namlstf3,namlstf4,namlstf5,
             namfathe,namfatht,namfath3,namfath4,namfath5,
             numofidf,dtebdfa,codfnatn,codfrelg,codfoccu,
             staliff,dtedeathf,filenamf,numrefdocf,
             codempmo,codtitlm,
             namfstme,namfstmt,namfstm3,namfstm4,namfstm5,
             namlstme,namlstmt,namlstm3,namlstm4,namlstm5,
             nammothe,nammotht,nammoth3,nammoth4,nammoth5,
             numofidm,dtebdmo,codmnatn,codmrelg,codmoccu,
             stalifm,dtedeathm,filenamm,numrefdocm,
             codtitlc,
             namfstce,namfstct,namfstc3,namfstc4,namfstc5,
             namlstce,namlstct,namlstc3,namlstc4,namlstc5,
             namconte,namcontt,namcont3,namcont4,namcont5,
             adrcont1,codpost,numtele,numfax,email,desrelat,
             rowid
        from tfamily
       where codempid = b_index_codempid;

    cursor c_tspouse is
      select /*codempid,namspous,codtitle,namfirst,namlast,numoffid,numtaxid,codspocc,
             dtespbd,desnoffi,numfasp,nummosp,dtemarry,
             codsppro,codspcty,desplreg,desnote,dteupd,
             coduser,*/
                 codempidsp,namimgsp,codtitle,
                 namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                 namlaste,namlastt,namlast3,namlast4,namlast5,
                 namspe,namspt,namsp3,namsp4,namsp5,
                 numoffid,numtaxid,codspocc,dtespbd,stalife,staincom,
                 dtedthsp,desnoffi,numfasp,nummosp,dtemarry,
                 codsppro,codspcty,desplreg,desnote,filename,numrefdoc,
                 rowid
        from tspouse
       where codempid = b_index_codempid;

    cursor c_tappldoc is
      select numappl,numseq,codempid,namdoc,filedoc,dterecv,
             dteupd,coduser,typdoc,dtedocen,numdoc,desnote,flgresume
        from tappldoc
--       where codempid = b_index_codempid
       where numappl  = v_numappl
         and numseq   = v_numseq;

  begin
    --select language : tab2_adrreg
    if global_v_lang = '101' then
      tab2_adrrege := tab2_adrreg;
    elsif global_v_lang = '102' then
      tab2_adrregt := tab2_adrreg;
    elsif global_v_lang = '103' then
      tab2_adrreg3 := tab2_adrreg;
    elsif global_v_lang = '104' then
      tab2_adrreg4 := tab2_adrreg;
    elsif global_v_lang = '105' then
      tab2_adrreg5 := tab2_adrreg;
    end if;

     --select language : tab2_adrcont
    if global_v_lang = '101' then
      tab2_adrconte := tab2_adrcont;
    elsif global_v_lang = '102' then
      tab2_adrcontt := tab2_adrcont;
    elsif global_v_lang = '103' then
      tab2_adrcont3 := tab2_adrcont;
    elsif global_v_lang = '104' then
      tab2_adrcont4 := tab2_adrcont;
    elsif global_v_lang = '105' then
      tab2_adrcont5 := tab2_adrcont;
    end if;

    v_exist := false;
    v_upd   := false;

    if p_tabno = 7 then -- HRES32EC3 page7
      tab2_dteinput  := tab27_dteinput;
      tab2_dtecancel := tab27_dtecancel;
    end if;

    if nvl(tab2_staappr,'P') = 'C' then
      tab2_dtecancel := sysdate;
    end if;
    if p_tabno = 6 then -- HRES32EC3 page6
        if global_v_flg = 1 then
            upd_tempded('tab281','E',tab261_coddeduct,tab261_amtdeduct);
            upd_tempded('tab881','E',tab261_coddeduct,tab261_amtdeduct_spous);
        elsif global_v_flg = 2 then
            upd_tempded('tab282','D',tab262_coddeduct,tab262_amtdeduct);
            upd_tempded('tab882','D',tab262_coddeduct,tab262_amtdeduct_spous);
        else
            upd_tempded('tab283','O',tab263_coddeduct,tab263_amtdeduct);
            upd_tempded('tab883','O',tab263_coddeduct,tab263_amtdeduct_spous);
        end if;
    end if;	--if p_tabno = 6
    parameter_err := null;
    if p_tabno = 1 then -- HRES32EC3 page1
      for i in c_temploy1 loop
        upd_log1(b_index_numseq,'tempch','21','email_emp','C',i.email,tab2_email_emp,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','lineid','C',i.lineid,tab2_lineid,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','nummobile','C',i.nummobile,tab2_nummobile,'N',v_upd);
      end loop;
    end if;

    if p_tabno = 2 then -- HRES32EC3 page1
      for i in c_temploy1 loop
        upd_log1(b_index_numseq, 'tempch','22','stamarry','C',i.stamarry,tab2_stamarry,'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','stamilit','C',i.stamilit,tab2_stamilit,'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','dteretire','D',to_char(i.dteretire,'dd/mm/yyyy'),to_char(tab2_dteretire,'dd/mm/yyyy'),'N',v_upd);
      end loop;
    end if;

    for i in c_temploy2 loop
      begin
        select stamarry into v_stamarry
          from temploy1
         where codempid = i.codempid;
      exception when no_data_found then
        v_stamarry := null;
      end ;
      begin
        select qtychedu,qtychned,codbank,
               numbank,amtbank,codbank2,numbank2,
               numbrnch,numbrnch2,amttranb
          into v_qtychedu,v_qtychned,v_codbank,
               v_numbank,v_amtbank,v_codbank2,v_numbank2,
               v_numbrnch,v_numbrnch2,v_amttranb
          from temploy3
         where codempid = i.codempid;
      exception when no_data_found then
        v_stamarry := null;
      end ;

      if p_tabno = 1 then -- HRES32EC3 page1
        upd_log1(b_index_numseq,'tempch','21','adrrege','C',i.adrrege,tab2_adrrege,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','adrregt','C',i.adrregt,tab2_adrregt,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','adrreg3','C',i.adrreg3,tab2_adrreg3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','adrreg4','C',i.adrreg4,tab2_adrreg4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','adrreg5','C',i.adrreg5,tab2_adrreg5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','codsubdistr','C',i.codsubdistr,tab2_codsubdistr,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','coddistr','C',i.coddistr,tab2_coddistr,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','codprovr','C',i.codprovr,tab2_codprovr,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','codcntyr','C',i.codcntyr,tab2_codcntyr,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','codpostr','N',i.codpostr,tab2_codpostr,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','adrconte','C',i.adrconte,tab2_adrconte,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','adrcontt','C',i.adrcontt,tab2_adrcontt,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','adrcont3','C',i.adrcont3,tab2_adrcont3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','adrcont4','C',i.adrcont4,tab2_adrcont4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','adrcont5','C',i.adrcont5,tab2_adrcont5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','codsubdistc','C',i.codsubdistc,tab2_codsubdistc,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','coddistc','C',i.coddistc,tab2_coddistc,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','codprovc','C',i.codprovc,tab2_codprovc,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','codcntyc','C',i.codcntyc,tab2_codcntyc,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','codpostc','N',i.codpostc,tab2_codpostc,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','21','numtelec','C',i.numtelec,tab2_numtelec,'N',v_upd);

      elsif p_tabno = 2 then -- HRES32EC3 page2
        upd_log1(b_index_numseq, 'tempch','22','numoffid','C',i.numoffid,tab2_numoffid,'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','dteoffid','D',to_char(i.dteoffid,'dd/mm/yyyy'),to_char(tab2_dteoffid,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','adrissue','C',i.adrissue,tab2_adrissue,'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','codprovi','C',i.codprovi,tab2_codprovi,'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','numpasid','C',i.numpasid,tab2_numpasid,'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','dtepasid','D',to_char(i.dtepasid,'dd/mm/yyyy'),to_char(tab2_dtepasid,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','numprmid','C',i.numprmid,tab2_numprmid,'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','dteprmst','D',to_char(i.dteprmst,'dd/mm/yyyy'),to_char(tab2_dteprmst,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','dteprmen','D',to_char(i.dteprmen,'dd/mm/yyyy'),to_char(tab2_dteprmen,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','numlicid','C',i.numlicid,tab2_numlicid,'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','dtelicid','D',to_char(i.dtelicid,'dd/mm/yyyy'),to_char(tab2_dtelicid,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','numvisa','C',i.numvisa,tab2_numvisa,'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','dtevisaexp','D',to_char(i.dtevisaexp,'dd/mm/yyyy'),to_char(tab2_dtevisaexp,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq, 'tempch','22','codclnsc','C',i.codclnsc,tab2_codclnsc,'N',v_upd);
--        upd_log1(b_index_numseq,'tempch','2','stamilit','C',i.stamilit,tab2_stamilit,'N',v_upd);

--      elsif p_tabno = 6 then -- HRES32EC3 page6
--        upd_log1(b_index_numseq,'tempch','222','qtychedu','C',v_qtychedu,tab222_qtychedu,'N',v_upd);
--        upd_log1(b_index_numseq,'tempch','222','qtychned','C',v_qtychned,tab222_qtychned,'N',v_upd);

      elsif p_tabno = 4 then -- HRES32EC3 page4
        upd_log1(b_index_numseq,'tempch','27','codbank','C',v_codbank,tab2_codbank,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','27','numbank','C',v_numbank,tab2_numbank,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','27','numbrnch','C',v_numbrnch,tab2_numbrnch,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','27','amtbank','N',v_amtbank,tab2_amtbank,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','27','amttranb','N',v_amttranb,stdenc(tab2_amttranb,b_index_codempid,v_chken),'Y',v_upd);
--        stdenc(tab2_amttranb,b_index_codempid,v_chken);
        upd_log1(b_index_numseq,'tempch','27','codbank2','C',v_codbank2,tab2_codbank2,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','27','numbank2','C',v_numbank2,tab2_numbank2,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','27','numbrnch2','C',v_numbrnch2,tab2_numbrnch2,'N',v_upd);
      end if; --if p_tabno = 1
    end loop;

    if p_tabno = 3 then -- HRES32EC3 page3
      v_exist := false;
      for i in c_tfamily loop
        v_exist := true;
        if tab2_codtitlf is not null or tab2_namfstfe is not null or tab2_namlstfe is not null then
          upd_log1(b_index_numseq,'tempch','25','namfathe','C',i.namfathe,get_tlistval_name('CODTITLE',tab2_codtitlf,'101')||tab2_namfstfe||' '||tab2_namlstfe,'N',v_upd);
        end if;
        if tab2_codtitlf is not null or tab2_namfstft is not null or tab2_namlstft is not null then
          upd_log1(b_index_numseq,'tempch','25','namfatht','C',i.namfatht,get_tlistval_name('CODTITLE',tab2_codtitlf,'102')||tab2_namfstft||' '||tab2_namlstft,'N',v_upd);
        end if;
        if tab2_codtitlf is not null or tab2_namfstf3 is not null or tab2_namlstf3 is not null then
          upd_log1(b_index_numseq,'tempch','25','namfath3','C',i.namfath3,get_tlistval_name('CODTITLE',tab2_codtitlf,'103')||tab2_namfstf3||' '||tab2_namlstf3,'N',v_upd);
        end if;
        if tab2_codtitlf is not null or tab2_namfstf4 is not null or tab2_namlstf4 is not null then
          upd_log1(b_index_numseq,'tempch','25','namfath4','C',i.namfath4,get_tlistval_name('CODTITLE',tab2_codtitlf,'104')||tab2_namfstf4||' '||tab2_namlstf4,'N',v_upd);
        end if;
        if tab2_codtitlf is not null or tab2_namfstf5 is not null or tab2_namlstf5 is not null then
          upd_log1(b_index_numseq,'tempch','25','namfath5','C',i.namfath5,get_tlistval_name('CODTITLE',tab2_codtitlf,'105')||tab2_namfstf5||' '||tab2_namlstf5,'N',v_upd);
        end if;
        upd_log1(b_index_numseq,'tempch','25','codempfa','C',i.codempfa,tab2_codempfa,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codfnatn','C',i.codfnatn,tab2_codfnatn,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codfrelg','C',i.codfrelg,tab2_codfrelg,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codfoccu','C',i.codfoccu,tab2_codfoccu,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','numofidf','C',i.numofidf,tab2_numofidf,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codempmo','C',i.codempmo,tab2_codempmo,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codmnatn','C',i.codmnatn,tab2_codmnatn,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codmrelg','C',i.codmrelg,tab2_codmrelg,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codmoccu','C',i.codmoccu,tab2_codmoccu,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','numofidm','C',i.numofidm,tab2_numofidm,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','adrcont1','C',i.adrcont1,tab2_adrcont1,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codpost','C',i.codpost,tab2_codpost,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','numtele','C',i.numtele,tab2_numtele,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','numfax','C',i.numfax,tab2_numfax,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','email','C',i.email,tab2_email,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','desrelat','C',i.desrelat,tab2_desrelat,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codtitlf','C',i.codtitlf,tab2_codtitlf,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstfe','C',i.namfstfe,tab2_namfstfe,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstft','C',i.namfstft,tab2_namfstft,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstf3','C',i.namfstf3,tab2_namfstf3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstf4','C',i.namfstf4,tab2_namfstf4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstf5','C',i.namfstf5,tab2_namfstf5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstfe','C',i.namlstfe,tab2_namlstfe,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstft','C',i.namlstft,tab2_namlstft,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstf3','C',i.namlstf3,tab2_namlstf3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstf4','C',i.namlstf4,tab2_namlstf4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstf5','C',i.namlstf5,tab2_namlstf5,'N',v_upd);

        if tab2_codtitlm is not null or tab2_namfstme is not null or tab2_namlstme is not null then
          upd_log1(b_index_numseq,'tempch','25','nammothe','C',i.namfathe,get_tlistval_name('CODTITLE',tab2_codtitlm,'101')||tab2_namfstme||' '||tab2_namlstme,'N',v_upd);
        end if;
        if tab2_codtitlm is not null or tab2_namfstmt is not null or tab2_namlstmt is not null then
          upd_log1(b_index_numseq,'tempch','25','nammotht','C',i.namfatht,get_tlistval_name('CODTITLE',tab2_codtitlm,'102')||tab2_namfstmt||' '||tab2_namlstmt,'N',v_upd);
        end if;
        if tab2_codtitlm is not null or tab2_namfstm3 is not null or tab2_namlstm3 is not null then
          upd_log1(b_index_numseq,'tempch','25','nammoth3','C',i.namfath3,get_tlistval_name('CODTITLE',tab2_codtitlm,'103')||tab2_namfstm3||' '||tab2_namlstm3,'N',v_upd);
        end if;
        if tab2_codtitlm is not null or tab2_namfstm4 is not null or tab2_namlstm4 is not null then
          upd_log1(b_index_numseq,'tempch','25','nammoth4','C',i.namfath4,get_tlistval_name('CODTITLE',tab2_codtitlm,'104')||tab2_namfstm4||' '||tab2_namlstm4,'N',v_upd);
        end if;
        if tab2_codtitlm is not null or tab2_namfstm5 is not null or tab2_namlstm5 is not null then
          upd_log1(b_index_numseq,'tempch','25','nammoth5','C',i.namfath5,get_tlistval_name('CODTITLE',tab2_codtitlm,'105')||tab2_namfstm5||' '||tab2_namlstm5,'N',v_upd);
        end if;
        upd_log1(b_index_numseq,'tempch','25','codtitlm','C',i.codtitlm,tab2_codtitlm,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstme','C',i.namfstme,tab2_namfstme,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstmt','C',i.namfstmt,tab2_namfstmt,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstm3','C',i.namfstm3,tab2_namfstm3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstm4','C',i.namfstm4,tab2_namfstm4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstm5','C',i.namfstm5,tab2_namfstm5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstme','C',i.namlstme,tab2_namlstme,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstmt','C',i.namlstmt,tab2_namlstmt,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstm3','C',i.namlstm3,tab2_namlstm3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstm4','C',i.namlstm4,tab2_namlstm4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstm5','C',i.namlstm5,tab2_namlstm5,'N',v_upd);
        if tab2_codtitlc is not null or tab2_namfstce is not null or tab2_namlstce is not null then
          upd_log1(b_index_numseq,'tempch','25','namconte','C',i.namfathe,get_tlistval_name('CODTITLE',tab2_codtitlc,'101')||tab2_namfstce||' '||tab2_namlstce,'N',v_upd);
        end if;
        if tab2_codtitlc is not null or tab2_namfstct is not null or tab2_namlstct is not null then
          upd_log1(b_index_numseq,'tempch','25','namcontt','C',i.namfatht,get_tlistval_name('CODTITLE',tab2_codtitlc,'102')||tab2_namfstct||' '||tab2_namlstct,'N',v_upd);
        end if;
        if tab2_codtitlc is not null or tab2_namfstc3 is not null or tab2_namlstc3 is not null then
          upd_log1(b_index_numseq,'tempch','25','namcont3','C',i.namfath3,get_tlistval_name('CODTITLE',tab2_codtitlc,'103')||tab2_namfstc3||' '||tab2_namlstc3,'N',v_upd);
        end if;
        if tab2_codtitlc is not null or tab2_namfstc4 is not null or tab2_namlstc4 is not null then
          upd_log1(b_index_numseq,'tempch','25','namcont4','C',i.namfath4,get_tlistval_name('CODTITLE',tab2_codtitlc,'104')||tab2_namfstc4||' '||tab2_namlstc4,'N',v_upd);
        end if;
        if tab2_codtitlc is not null or tab2_namfstc5 is not null or tab2_namlstc5 is not null then
          upd_log1(b_index_numseq,'tempch','25','namcont5','C',i.namfath5,get_tlistval_name('CODTITLE',tab2_codtitlc,'105')||tab2_namfstc5||' '||tab2_namlstc5,'N',v_upd);
        end if;
        upd_log1(b_index_numseq,'tempch','25','codtitlc','C',i.codtitlc,tab2_codtitlc,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstce','C',i.namfstce,tab2_namfstce,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstct','C',i.namfstct,tab2_namfstct,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstc3','C',i.namfstc3,tab2_namfstc3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstc4','C',i.namfstc4,tab2_namfstc4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstc5','C',i.namfstc5,tab2_namfstc5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstce','C',i.namlstce,tab2_namlstce,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstct','C',i.namlstct,tab2_namlstct,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstc3','C',i.namlstc3,tab2_namlstc3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstc4','C',i.namlstc4,tab2_namlstc4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstc5','C',i.namlstc5,tab2_namlstc5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','dtebdfa','D',to_char(i.dtebdfa,'dd/mm/yyyy'),to_char(tab2_dtebdfa,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','staliff','C',i.staliff,tab2_staliff,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','dtedeathf','D',to_char(i.dtedeathf,'dd/mm/yyyy'),to_char(tab2_dtedeathf,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','filenamf','C',i.filenamf,tab2_filenamf,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','dtebdmo','D',to_char(i.dtebdmo,'dd/mm/yyyy'),to_char(tab2_dtebdmo,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','stalifm','C',i.stalifm,tab2_stalifm,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','dtedeathm','D',to_char(i.dtedeathm,'dd/mm/yyyy'),to_char(tab2_dtedeathm,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','filenamm','C',i.filenamm,tab2_filenamm,'N',v_upd);
      end loop;
      if not v_exist then
        if tab2_codtitlf is not null or tab2_namfstfe is not null or tab2_namlstfe is not null then
          upd_log1(b_index_numseq,'tempch','25','namfathe','C',null,get_tlistval_name('CODTITLE',tab2_codtitlf,'101')||tab2_namfstfe||' '||tab2_namlstfe,'N',v_upd);
        end if;
        if tab2_codtitlf is not null or tab2_namfstft is not null or tab2_namlstft is not null then
          upd_log1(b_index_numseq,'tempch','25','namfatht','C',null,get_tlistval_name('CODTITLE',tab2_codtitlf,'102')||tab2_namfstft||' '||tab2_namlstft,'N',v_upd);
        end if;
        if tab2_codtitlf is not null or tab2_namfstf3 is not null or tab2_namlstf3 is not null then
          upd_log1(b_index_numseq,'tempch','25','namfath3','C',null,get_tlistval_name('CODTITLE',tab2_codtitlf,'103')||tab2_namfstf3||' '||tab2_namlstf3,'N',v_upd);
        end if;
        if tab2_codtitlf is not null or tab2_namfstf4 is not null or tab2_namlstf4 is not null then
          upd_log1(b_index_numseq,'tempch','25','namfath4','C',null,get_tlistval_name('CODTITLE',tab2_codtitlf,'104')||tab2_namfstf4||' '||tab2_namlstf4,'N',v_upd);
        end if;
        if tab2_codtitlf is not null or tab2_namfstf5 is not null or tab2_namlstf5 is not null then
          upd_log1(b_index_numseq,'tempch','25','namfath5','C',null,get_tlistval_name('CODTITLE',tab2_codtitlf,'105')||tab2_namfstf5||' '||tab2_namlstf5,'N',v_upd);
        end if;
        upd_log1(b_index_numseq,'tempch','25','codempfa','C',null,tab2_codempfa,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codfnatn','C',null,tab2_codfnatn,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codfrelg','C',null,tab2_codfrelg,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codfoccu','C',null,tab2_codfoccu,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','numofidf','C',null,tab2_numofidf,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codempmo','C',null,tab2_codempmo,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codmnatn','C',null,tab2_codmnatn,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codmrelg','C',null,tab2_codmrelg,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codmoccu','C',null,tab2_codmoccu,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','numofidm','C',null,tab2_numofidm,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','adrcont1','C',null,tab2_adrcont1,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codpost','C',null,tab2_codpost,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','numtele','C',null,tab2_numtele,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','numfax','C',null,tab2_numfax,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','email','C',null,tab2_email,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','desrelat','C',null,tab2_desrelat,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','codtitlf','C',null,tab2_codtitlf,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstfe','C',null,tab2_namfstfe,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstft','C',null,tab2_namfstft,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstf3','C',null,tab2_namfstf3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstf4','C',null,tab2_namfstf4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstf5','C',null,tab2_namfstf5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstfe','C',null,tab2_namlstfe,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstft','C',null,tab2_namlstft,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstf3','C',null,tab2_namlstf3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstf4','C',null,tab2_namlstf4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstf5','C',null,tab2_namlstf5,'N',v_upd);
        if tab2_codtitlm is not null or tab2_namfstme is not null or tab2_namlstme is not null then
          upd_log1(b_index_numseq,'tempch','25','nammothe','C',null,get_tlistval_name('CODTITLE',tab2_codtitlm,'101')||tab2_namfstme||' '||tab2_namlstme,'N',v_upd);
        end if;
        if tab2_codtitlm is not null or tab2_namfstmt is not null or tab2_namlstmt is not null then
          upd_log1(b_index_numseq,'tempch','25','nammotht','C',null,get_tlistval_name('CODTITLE',tab2_codtitlm,'102')||tab2_namfstmt||' '||tab2_namlstmt,'N',v_upd);
        end if;
        if tab2_codtitlm is not null or tab2_namfstm3 is not null or tab2_namlstm3 is not null then
          upd_log1(b_index_numseq,'tempch','25','nammoth3','C',null,get_tlistval_name('CODTITLE',tab2_codtitlm,'103')||tab2_namfstm3||' '||tab2_namlstm3,'N',v_upd);
        end if;
        if tab2_codtitlm is not null or tab2_namfstm4 is not null or tab2_namlstm4 is not null then
          upd_log1(b_index_numseq,'tempch','25','nammoth4','C',null,get_tlistval_name('CODTITLE',tab2_codtitlm,'104')||tab2_namfstm4||' '||tab2_namlstm4,'N',v_upd);
        end if;
        if tab2_codtitlm is not null or tab2_namfstm5 is not null or tab2_namlstm5 is not null then
          upd_log1(b_index_numseq,'tempch','25','nammoth5','C',null,get_tlistval_name('CODTITLE',tab2_codtitlm,'105')||tab2_namfstm5||' '||tab2_namlstm5,'N',v_upd);
        end if;
        upd_log1(b_index_numseq,'tempch','25','codtitlm','C',null,tab2_codtitlm,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstme','C',null,tab2_namfstme,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstmt','C',null,tab2_namfstmt,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstm3','C',null,tab2_namfstm3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstm4','C',null,tab2_namfstm4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstm5','C',null,tab2_namfstm5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstme','C',null,tab2_namlstme,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstmt','C',null,tab2_namlstmt,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstm3','C',null,tab2_namlstm3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstm4','C',null,tab2_namlstm4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstm5','C',null,tab2_namlstm5,'N',v_upd);
        if tab2_codtitlc is not null or tab2_namfstce is not null or tab2_namlstce is not null then
          upd_log1(b_index_numseq,'tempch','25','namconte','C',null,get_tlistval_name('CODTITLE',tab2_codtitlc,'101')||tab2_namfstce||' '||tab2_namlstce,'N',v_upd);
        end if;
        if tab2_codtitlc is not null or tab2_namfstct is not null or tab2_namlstct is not null then
          upd_log1(b_index_numseq,'tempch','25','namcontt','C',null,get_tlistval_name('CODTITLE',tab2_codtitlc,'102')||tab2_namfstct||' '||tab2_namlstct,'N',v_upd);
        end if;
        if tab2_codtitlc is not null or tab2_namfstc3 is not null or tab2_namlstc3 is not null then
          upd_log1(b_index_numseq,'tempch','25','namcont3','C',null,get_tlistval_name('CODTITLE',tab2_codtitlc,'103')||tab2_namfstc3||' '||tab2_namlstc3,'N',v_upd);
        end if;
        if tab2_codtitlc is not null or tab2_namfstc4 is not null or tab2_namlstc4 is not null then
          upd_log1(b_index_numseq,'tempch','25','namcont4','C',null,get_tlistval_name('CODTITLE',tab2_codtitlc,'104')||tab2_namfstc4||' '||tab2_namlstc4,'N',v_upd);
        end if;
        if tab2_codtitlc is not null or tab2_namfstc5 is not null or tab2_namlstc5 is not null then
          upd_log1(b_index_numseq,'tempch','25','namcont5','C',null,get_tlistval_name('CODTITLE',tab2_codtitlc,'105')||tab2_namfstc5||' '||tab2_namlstc5,'N',v_upd);
        end if;
        upd_log1(b_index_numseq,'tempch','25','codtitlc','C',null,tab2_codtitlc,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstce','C',null,tab2_namfstce,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstct','C',null,tab2_namfstct,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstc3','C',null,tab2_namfstc3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstc4','C',null,tab2_namfstc4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namfstc5','C',null,tab2_namfstc5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstce','C',null,tab2_namlstce,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstct','C',null,tab2_namlstct,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstc3','C',null,tab2_namlstc3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstc4','C',null,tab2_namlstc4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','namlstc5','C',null,tab2_namlstc5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','dtebdfa','D',null,to_char(tab2_dtebdfa,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','staliff','C',null,tab2_staliff,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','dtedeathf','D',null,to_char(tab2_dtedeathf,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','filenamf','C',null,tab2_filenamf,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','dtebdmo','D',null,to_char(tab2_dtebdmo,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','stalifm','C',null,tab2_stalifm,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','dtedeathm','D',null,to_char(tab2_dtedeathm,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','25','filenamm','C',null,tab2_filenamm,'N',v_upd);
      end if;
    end if; --if p_tabno = 3

    if p_tabno = 5 then -- HRES32EC3 page5
      v_exist := false;
      for i in c_tspouse loop
        v_exist := true;

        --USER19 19/10/2017
        --upd_log1(b_index_numseq,'tempch','2','namspous','C',i.namspous,tab2_namspous,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namspe','C',i.namspe,get_tlistval_name('CODTITLE',tab2_codtitle,global_v_lang)||tab2_namfirste||' '||tab2_namlaste,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namspt','C',i.namspt,get_tlistval_name('CODTITLE',tab2_codtitle,global_v_lang)||tab2_namfirstt||' '||tab2_namlastt,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namsp3','C',i.namsp3,get_tlistval_name('CODTITLE',tab2_codtitle,global_v_lang)||tab2_namfirst3||' '||tab2_namlast3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namsp4','C',i.namsp4,get_tlistval_name('CODTITLE',tab2_codtitle,global_v_lang)||tab2_namfirst4||' '||tab2_namlast4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namsp5','C',i.namsp5,get_tlistval_name('CODTITLE',tab2_codtitle,global_v_lang)||tab2_namfirst5||' '||tab2_namlast5,'N',v_upd);
        --USER19 19/10/2017
        upd_log1(b_index_numseq,'tempch','24','codtitle','C',i.codtitle,tab2_codtitle,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namfirste','C',i.namfirste,tab2_namfirste,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namfirstt','C',i.namfirstt,tab2_namfirstt,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namfirst3','C',i.namfirst3,tab2_namfirst3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namfirst4','C',i.namfirst4,tab2_namfirst4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namfirst5','C',i.namfirst5,tab2_namfirst5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namlaste','C',i.namlaste,tab2_namlaste,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namlastt','C',i.namlastt,tab2_namlastt,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namlast3','C',i.namlast3,tab2_namlast3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namlast4','C',i.namlast4,tab2_namlast4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namlast5','C',i.namlast5,tab2_namlast5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','numspid','C',i.numoffid,tab2_numspid,'N',v_upd);--User37 #1923 Final Test Phase 1 V11 19/03/2021 upd_log1(b_index_numseq,'tempch','24','numspid','C',i.numspid,tab2_numspid,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','dtespbd','D',to_char(i.dtespbd,'dd/mm/yyyy'),to_char(tab2_dtespbd,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','codspocc','C',i.codspocc,tab2_codspocc,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','desnoffi','C',i.desnoffi,tab2_desnoffi,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','dtemarry','D',to_char(i.dtemarry,'dd/mm/yyyy'),to_char(tab2_dtemarry,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','desplreg','C',i.desplreg,tab2_desplreg,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','codsppro','C',i.codsppro,tab2_codsppro,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','codspcty','C',i.codspcty,tab2_codspcty,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','desnote','C',i.desnote,tab2_desnote,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','codempidsp','C',i.codempidsp,tab2_codempidsp,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','stalife','C',i.stalife,tab2_stalife,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','dtedthsp','D',to_char(i.dtedthsp,'dd/mm/yyyy'),to_char(tab2_dtedthsp,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','staincom','C',i.staincom,tab2_staincom,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','numfasp','C',i.numfasp,tab2_numfasp,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','nummosp','C',i.nummosp,tab2_nummosp,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','filename','C',i.filename,tab2_filename,'N',v_upd);
      end loop;

      if not v_exist then
--        upd_log1(b_index_numseq,'tempch','2','namspous','C',null,tab2_namspous,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namspe','C',null,get_tlistval_name('CODTITLE',tab2_codtitle,'101')||tab2_namfirste||' '||tab2_namlaste,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namspt','C',null,get_tlistval_name('CODTITLE',tab2_codtitle,'102')||tab2_namfirstt||' '||tab2_namlastt,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namsp3','C',null,get_tlistval_name('CODTITLE',tab2_codtitle,'103')||tab2_namfirst3||' '||tab2_namlast3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namsp4','C',null,get_tlistval_name('CODTITLE',tab2_codtitle,'104')||tab2_namfirst4||' '||tab2_namlast4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namsp5','C',null,get_tlistval_name('CODTITLE',tab2_codtitle,'105')||tab2_namfirst5||' '||tab2_namlast5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','codtitle','C',null,tab2_codtitle,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namfirste','C',null,tab2_namfirste,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namfirstt','C',null,tab2_namfirstt,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namfirst3','C',null,tab2_namfirst3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namfirst4','C',null,tab2_namfirst4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namfirst5','C',null,tab2_namfirst5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namlaste','C',null,tab2_namlaste,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namlastt','C',null,tab2_namlastt,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namlast3','C',null,tab2_namlast3,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namlast4','C',null,tab2_namlast4,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','namlast5','C',null,tab2_namlast5,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','numspid','C',null,tab2_numspid,'N',v_upd);--User37 #1923 Final Test Phase 1 V11 19/03/2021 upd_log1(b_index_numseq,'tempch','24','numspid','C',null,tab2_numspid,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','dtespbd','D',null,to_char(tab2_dtespbd,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','codspocc','C',null,tab2_codspocc,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','desnoffi','C',null,tab2_desnoffi,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','dtemarry','D',null,to_char(tab2_dtemarry,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','desplreg','C',null,tab2_desplreg,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','codsppro','C',null,tab2_codsppro,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','codspcty','C',null,tab2_codspcty,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','desnote','C',null,tab2_desnote,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','codempidsp','C',null,tab2_codempidsp,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','stalife','C',null,tab2_stalife,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','dtedthsp','D',null,to_char(tab2_dtedthsp,'dd/mm/yyyy'),'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','staincom','C',null,tab2_staincom,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','numfasp','C',null,tab2_numfasp,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','nummosp','C',null,tab2_nummosp,'N',v_upd);
        upd_log1(b_index_numseq,'tempch','24','filename','C',null,tab2_filename,'N',v_upd);
      end if;
    end if; --if p_tabno = 5

    if p_tabno = 7 then -- HRES32EC3 page7
      begin
        select numappl
          into v_numappl
          from temploy1
         where codempid = b_index_codempid;
      exception when no_data_found then
        v_numappl  := null;
      end;
        if tab27_numseq is null then
          begin
            select nvl(max(numseq),0) + 1
            into tab27_numseq
            from(
              select numseq
                from tappldoc
               where numappl = v_numappl
              union
              select distinct(seqno) as numseq
                from temeslog2
               where codempid = b_index_codempid
                 and dtereq   = b_index_dtereq
                 and numseq   = b_index_numseq
                 and numpage  = 29
                 and seqno    not in (select numseq
                                        from tappldoc
                                       where numappl = v_numappl));
          exception when others then
            tab27_numseq  := null;
          end;
        end if;

        if tab27_numseq is not null then
          if tab27_typdoc is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
          elsif tab27_namdoc is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
          elsif tab27_dterecv is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
          elsif tab27_filedoc is not null and length(tab27_filedoc) > 30 then
            param_msg_error := get_error_msg_php('HR2061',global_v_lang);
          return;
          end if;

          v_exist  := false;
          v_numseq := tab27_numseq;
          for i in c_tappldoc loop
            v_exist := true;
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'typdoc','N','numseq',null,null,'C',i.typdoc,tab27_typdoc,'N',v_upd);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'namdoc','N','numseq',null,null,'C',i.namdoc,tab27_namdoc,'N',v_upd);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'dterecv','N','numseq',null,null,'D',to_char(i.dterecv,'dd/mm/yyyy'),to_char(tab27_dterecv,'dd/mm/yyyy'),'N',v_upd);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'dtedocen','N','numseq',null,null,'D',to_char(i.dtedocen,'dd/mm/yyyy'),to_char(tab27_dtedocen,'dd/mm/yyyy'),'N',v_upd);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'numdoc','N','numseq',null,null,'C',i.numdoc,tab27_numdoc,'N',v_upd);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'filedoc','N','numseq',null,null,'C',i.filedoc,tab27_filedoc,'N',v_upd);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'desnote','N','numseq',null,null,'C',i.desnote,tab27_desnote,'N',v_upd);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'flgresume','N','numseq',null,null,'C',i.flgresume,tab27_flgresume,'N',v_upd);
          end loop;

          if not v_exist then
            if v_numseq is null then
              v_numseq := gen_numseq_tab27;
            end if;
            tab27_status := 'A'; --user36 JAS590255 20/04/2016
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'typdoc','N','numseq',null,null,'C',null,tab27_typdoc,'N',v_upd,tab27_status);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'namdoc','N','numseq',null,null,'C',null,tab27_namdoc,'N',v_upd,tab27_status);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'dterecv','N','numseq',null,null,'D',null,to_char(tab27_dterecv,'dd/mm/yyyy'),'N',v_upd,tab27_status);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'dtedocen','N','numseq',null,null,'D',null,to_char(tab27_dtedocen,'dd/mm/yyyy'),'N',v_upd,tab27_status);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'numdoc','N','numseq',null,null,'C',null,tab27_numdoc,'N',v_upd,tab27_status);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'filedoc','N','numseq',null,null,'C',null,tab27_filedoc,'N',v_upd,tab27_status);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'desnote','N','numseq',null,null,'C',null,tab27_desnote,'N',v_upd,tab27_status);
            upd_log2(b_index_numseq,'tempch','29',v_numseq,'flgresume','N','numseq',null,null,'C',null,tab27_flgresume,'N',v_upd);
          end if;
        else
          ess_del_tab2_7(box_item_no);
        end if;
    end if; --if p_tabno = 7
    if v_upd then
      begin
        select count(*) into v_count
          from tempch
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 2;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        insert into tempch
        (codempid,dtereq,numseq,
         typchg,codcomp,dteinput,
         approvno,staappr,codappr,
         remarkap,dteappr,routeno,
         codinput,dtecancel,coduser)
        values
        (b_index_codempid,b_index_dtereq,b_index_numseq,
         2,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
         tab2_approvno,'P',tab2_codappr,
         tab2_remarkap,tab2_dteappr,tab2_routeno,
         global_v_codempid,tab2_dtecancel,global_v_coduser);
      else
        update tempch
           set approvno  = tab2_approvno,
               staappr   = 'P',
               codappr   = tab2_codappr,
               remarkap  = tab2_remarkap,
               dteappr   = tab2_dteappr,
               routeno   = tab2_routeno,
               codinput  = global_v_codempid,
               dtecancel = tab2_dtecancel,
               coduser	 = global_v_coduser
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 2;
      end if;
    end if;
    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
  end;
  --
  procedure save_tab1 is
  v_upd  				boolean;
  v_exist				boolean;

  --Cursor
  cursor c_temploy1 is
		select codtitle,namfirste,namfirstt,namfirst3,namfirst4,
		       namfirst5,namlaste,namlastt,namlast3,namlast4,
		       namlast5,nickname,nicknamt,nicknam3,nicknam4,nicknam5,rowid
		from	 temploy1
		where	 codempid = b_index_codempid;

	cursor c_tnamech is
		select rowid
		  from tempch
		 where codempid = b_index_codempid
		   and dtereq   = b_index_dtereq
		   and numseq   = b_index_numseq
		   and typchg   = 1;

  begin
    v_exist := false;
    v_upd   := false;
   --<< user28 || 12/03/2019 || redmind #6317
    if (nvl(tab1_codtitle,' ') <> tab1_n_codtitle) or
       (nvl(tab1_namfirste,' ')<> tab1_n_namee) or
       (nvl(tab1_namlaste,' ') <> tab1_n_laste) then
        tab1_codtitle  := tab1_n_codtitle;
        tab1_namfirste := tab1_n_namee;
        tab1_namlaste  := tab1_n_laste;
    end if;
    if (nvl(tab1_codtitle,' ') <> tab1_n_codtitle) or
       (nvl(tab1_namfirstt,' ')<> tab1_n_namet) or
       (nvl(tab1_namlastt,' ') <> tab1_n_lastt) then
        tab1_codtitle  := tab1_n_codtitle;
        tab1_namfirstt := tab1_n_namet;
        tab1_namlastt  := tab1_n_lastt;
    end if;
    if (nvl(tab1_namfirst3,' ') <> tab1_n_name3) then
      tab1_namfirst3  := tab1_n_name3;
    end if;
    if (nvl(tab1_namfirst4,' ') <> tab1_n_name4) then
      tab1_namfirst4  := tab1_n_name4;
    end if;
    if (nvl(tab1_namfirst5,' ') <> tab1_n_name5) then
      tab1_namfirst5  := tab1_n_name5;
    end if;
    if (nvl(tab1_namlast3,' ') <> tab1_n_last3) then
      tab1_namlast3  := tab1_n_last3;
    end if;
    if (nvl(tab1_namlast4,' ') <> tab1_n_last4) then
      tab1_namlast4  := tab1_n_last4;
    end if;
    if (nvl(tab1_namlast5,' ') <> tab1_n_last5) then
      tab1_namlast5  := tab1_n_last5;
    end if;
    if (nvl(tab1_nickname,' ') <> tab1_n_nicke) then
      tab1_nickname  := tab1_n_nicke;
    end if;
    if (nvl(tab1_nicknamt,' ') <> tab1_n_nickt) then
      tab1_nicknamt  := tab1_n_nickt;
    end if;
    if (nvl(tab1_nicknam3,' ') <> tab1_n_nick3) then
      tab1_nicknam3  := tab1_n_nick3;
    end if;
    if (nvl(tab1_nicknam4,' ') <> tab1_n_nick4) then
      tab1_nicknam4  := tab1_n_nick4;
    end if;
    if (nvl(tab1_nicknam5,' ') <> tab1_n_nick5) then
      tab1_nicknam5  := tab1_n_nick5;
    end if;
    -->> user28 || 12/03/2019 || redmind #6317
    for i in c_temploy1 loop
      if tab1_codtitle is not null then
        upd_log1(b_index_numseq,'tnamech','11','codtitle','C',i.codtitle,tab1_codtitle,'N',v_upd);
      end if;
      if tab1_namfirste is not null then
        upd_log1(b_index_numseq,'tnamech','11','namfirste','C',i.namfirste,tab1_namfirste,'N',v_upd);
      end if;
      if tab1_namfirstt is not null then
        upd_log1(b_index_numseq,'tnamech','11','namfirstt','C',i.namfirstt,tab1_namfirstt,'N',v_upd);
      end if;
      if tab1_namfirst3 is not null then
        upd_log1(b_index_numseq,'tnamech','11','namfirst3','C',i.namfirst3,tab1_namfirst3,'N',v_upd);
      end if;
      if tab1_namfirst4 is not null then
        upd_log1(b_index_numseq,'tnamech','11','namfirst4','C',i.namfirst4,tab1_namfirst4,'N',v_upd);
      end if;
      if tab1_namfirst5 is not null then
        upd_log1(b_index_numseq,'tnamech','11','namfirst5','C',i.namfirst5,tab1_namfirst5,'N',v_upd);
      end if;
      if tab1_namlaste is not null then
        upd_log1(b_index_numseq,'tnamech','11','namlaste','C',i.namlaste,tab1_namlaste,'N',v_upd);
      end if;
      if tab1_namlastt is not null then
        upd_log1(b_index_numseq,'tnamech','11','namlastt','C',i.namlastt,tab1_namlastt,'N',v_upd);
      end if;
      if tab1_namlast3 is not null then
        upd_log1(b_index_numseq,'tnamech','11','namlast3','C',i.namlast3,tab1_namlast3,'N',v_upd);
      end if;
      if tab1_namlast4 is not null then
        upd_log1(b_index_numseq,'tnamech','11','namlast4','C',i.namlast4,tab1_namlast4,'N',v_upd);
      end if;
      if tab1_namlast5 is not null then
        upd_log1(b_index_numseq,'tnamech','11','namlast5','C',i.namlast5,tab1_namlast5,'N',v_upd);
      end if;
      if tab1_nickname is not null then
        upd_log1(b_index_numseq,'tnamech','11','nickname','C',i.nickname,tab1_nickname,'N',v_upd);
      end if;
      if tab1_nicknamt is not null then
        upd_log1(b_index_numseq,'tnamech','11','nicknamt','C',i.nicknamt,tab1_nicknamt,'N',v_upd);
      end if;
      if tab1_nicknam3 is not null then
        upd_log1(b_index_numseq,'tnamech','11','nicknam3','C',i.nicknam3,tab1_nicknam3,'N',v_upd);
      end if;
      if tab1_nicknam4 is not null then
        upd_log1(b_index_numseq,'tnamech','11','nicknam4','C',i.nicknam4,tab1_nicknam4,'N',v_upd);
      end if;
      if tab1_nicknam5 is not null then
        upd_log1(b_index_numseq,'tnamech','11','nicknam5','C',i.nicknam5,tab1_nicknam5,'N',v_upd);
      end if;

     if nvl(tab1_staappr,'P') = 'C' then
       tab1_dtecancel  := sysdate;
     end if;

        for j in c_tnamech loop
          v_exist := true;

          update tempch
             set desnote   = tab1_desnote,
                 approvno  = tab1_approvno,
                 staappr   = 'P',
                 codappr   = tab1_codappr,
                 remarkap  = tab1_remarkap,
                 dteappr   = tab1_dteappr,
                 routeno   = tab1_routeno,
                 codinput  = global_v_codempid,
                 dtecancel = tab1_dtecancel,
                 coduser	 = global_v_coduser
           where rowid  = j.rowid;
        end loop;

        if not v_exist then
          insert into tempch ( codempid,dtereq,numseq,
                               typchg,desnote,dteinput,
                               codcomp,approvno,staappr,
                               codappr,remarkap,dteappr,
                               routeno,codinput,dtecancel,
                               coduser)
                      values ( b_index_codempid,b_index_dtereq,b_index_numseq,
                               1,tab1_desnote,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                               b_index_codcomp,tab1_approvno,'P',
                               tab1_codappr,tab1_remarkap,tab1_dteappr,
                               tab1_routeno,global_v_codempid,tab1_dtecancel,
                               global_v_coduser);
        end if;
      end loop;
    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
  end save_tab1;
  --
  procedure save_tab2_1 is
  v_code	varchar2(10 char);
  begin
    check_index;
    call_save_tab2(tab2_adrreg,1);
  end save_tab2_1;
  --
  procedure save_tab2_2 is
  v_code	varchar2(10 char);
  begin
    if tab2_codprovi is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec = tab2_codprovi;
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;
    --<<User37 #1923 Final Test Phase 1 V11 24/03/2021
    /*if tab2_dteprmst is not null and tab2_dteprmen is not null then
      if tab2_dteprmst >= tab2_dteprmen then
          param_msg_error := get_error_msg_php('ES0015',global_v_lang);
        return;
      end if;
    end if;*/
    -->>User37 #1923 Final Test Phase 1 V11 24/03/2021
    call_save_tab2(tab2_numoffid,2);
  end save_tab2_2;
  --
  procedure save_tab_travel is
    v_upd  				  boolean;
    v_count         number  := 0;
    cursor c_temploy1 is
      select typtrav,qtylength,carlicen,typfuel,codbusno,codbusrt
        from temploy1 a
       where a.codempid = b_index_codempid;

  begin
    v_upd   := false;

    parameter_err := null;

    if nvl(tab2_staappr,'P') = 'C' then
      tab2_dtecancel := sysdate;
    end if;

    for i in c_temploy1 loop
      upd_log1(b_index_numseq,'tempch','23','typtrav','C',i.typtrav,tab2_typtrav,'N',v_upd);
      upd_log1(b_index_numseq,'tempch','23','qtylength','C',i.qtylength,tab2_qtylength,'N',v_upd);
      upd_log1(b_index_numseq,'tempch','23','carlicen','C',i.carlicen,tab2_carlicen,'N',v_upd);
      upd_log1(b_index_numseq,'tempch','23','typfuel','C',i.typfuel,tab2_typfuel,'N',v_upd);
      upd_log1(b_index_numseq,'tempch','23','codbusno','C',i.codbusno,tab2_codbusno,'N',v_upd);
      upd_log1(b_index_numseq,'tempch','23','codbusrt','C',i.codbusrt,tab2_codbusrt,'N',v_upd);
    end loop;

    if v_upd then
      begin
        select count(*) into v_count
          from tempch
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 2;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        insert into tempch
        (codempid,dtereq,numseq,
         typchg,codcomp,dteinput,
         approvno,staappr,codappr,
         remarkap,dteappr,routeno,
         codinput,dtecancel,coduser)
        values
        (b_index_codempid,b_index_dtereq,b_index_numseq,
         2,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
         tab2_approvno,'P',tab2_codappr,
         tab2_remarkap,tab2_dteappr,tab2_routeno,
         global_v_codempid,tab2_dtecancel,global_v_coduser);
      else
        update tempch
           set approvno  = tab2_approvno,
               staappr   = 'P',
               codappr   = tab2_codappr,
               remarkap  = tab2_remarkap,
               dteappr   = tab2_dteappr,
               routeno   = tab2_routeno,
               codinput  = global_v_codempid,
               dtecancel = tab2_dtecancel,
               coduser	 = global_v_coduser
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 2;
      end if;
    end if;
    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
  end;
  --
  procedure save_tab2_3 is
  v_code	varchar2(10 char);
  begin
    if tab2_codfnatn is not null then
      begin
        select codcodec into v_code
        from	 tcodnatn
        where	 codcodec = tab2_codfnatn;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;
    if tab2_codfrelg is not null then
      begin
        select codcodec into v_code
        from	 tcodreli
        where	 codcodec = tab2_codfrelg;
      exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;
    if tab2_codfoccu is not null then
      begin
        select codcodec into v_code
        from	 tcodoccu
        where	 codcodec = tab2_codfoccu;
      exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;
    if tab2_codmnatn is not null then
      begin
        select codcodec into v_code
        from	 tcodnatn
        where	 codcodec = tab2_codmnatn;
      exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;
    if tab2_codmrelg is not null then
      begin
        select codcodec into v_code
        from	 tcodreli
        where	 codcodec = tab2_codmrelg;
      exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;
    if tab2_codmoccu is not null then
      begin
        select codcodec into v_code
        from	 tcodoccu
        where	 codcodec = tab2_codmoccu;
      exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;

    call_save_tab2(tab2_namfatht,3);
  end save_tab2_3;
  --
  procedure save_tab2_4 is
  v_code varchar2(30 char);
  begin
    tab2_desc_codbank := get_tcodec_name('TCODBANK',tab2_codbank,global_v_lang);
    tab2_desc_codbank2 := get_tcodec_name('TCODBANK',tab2_codbank2,global_v_lang);
    if tab2_codbank is not null or tab2_numbank is not null or nvl(tab2_amtbank,0) > 0 or
      tab2_codbank2 is not null or tab2_numbank2 is not null then
      if tab2_codbank is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      elsif tab2_numbank is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      elsif nvl(tab2_amtbank,0) = 0 then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
    end if;
    if nvl(tab2_amtbank,0) > 0 and nvl(tab2_amtbank,0) < 100 then
      if tab2_codbank2 is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      elsif tab2_numbank2 is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
    else
      tab2_codbank2 := null;
      tab2_desc_codbank2 := null;
      tab2_numbank2 := null;
    end if;

    if tab2_codbank is not null then
      begin
        select codcodec into v_code
        from	 tcodbank
        where	 codcodec = tab2_codbank;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;
    if tab2_codbank2 is not null then
      begin
        select codcodec into v_code
        from	 tcodbank
        where	 codcodec = tab2_codbank2;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;
    if tab2_codbank = tab2_codbank2 and
       tab2_numbank = tab2_numbank2 then
        param_msg_error := get_error_msg_php('PM0024',global_v_lang);
        return;
    end if;

    call_save_tab2(tab2_codbank,4);
  end save_tab2_4;
  --
  procedure save_tab2_5 is
	v_code varchar2(30 char);
  begin
    if tab2_codspocc is not null then
      begin
        select codcodec into v_code
        from	 tcodoccu
        where	 codcodec = tab2_codspocc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;
    if tab2_codsppro is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec = tab2_codsppro;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;
    if tab2_codspcty is not null then
      begin
        select codcodec into v_code
        from	 tcodcnty
        where	 codcodec = tab2_codspcty;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;
    end if;
    if tab2_dtemarry <= tab2_dtespbd then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        return;
    end if;

    call_save_tab2(tab2_namspt,5);
  end save_tab2_5;
  --
  procedure save_tab2_6 is
	v_code varchar2(30 char);
  begin
    call_save_tab2(tab21_amtdeduct,6);
  end save_tab2_6;
  --
  procedure save_tab2_7 is
	v_code varchar2(30 char);
  begin
    call_save_tab2(tab27_numseq,7);
  end save_tab2_7;
  --
  procedure save_tab_relatives is
    v_upd  				  boolean;
    v_count         number  := 0;
    v_exist         boolean := false;
    v_numseq        number  := 0;
    cursor c_trelatives is
      select numseq,codemprl,namrele,namrelt,namrel3,namrel4,namrel5,numtelec,adrcomt
        from trelatives a
       where a.codempid = b_index_codempid
         and numseq     = v_numseq;

  begin
    if tab2_relatives_numseq is null then
      begin
        select nvl(max(numseq),0) + 1
        into tab2_relatives_numseq
        from(
          select numseq
            from trelatives
           where codempid = b_index_codempid
          union
          select distinct(seqno) as numseq
            from temeslog2
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and numpage  = 26
             and seqno    not in (select numseq
                                    from trelatives
                                   where codempid = b_index_codempid));
      exception when others then
        tab2_relatives_numseq  := null;
      end;
    end if;

    v_upd   := false;
    if tab2_relatives_numseq is not null then

      v_exist  := false;
      v_numseq := tab2_relatives_numseq;

      for i in c_trelatives loop
        v_exist := true;
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'codemprl','N','numseq',null,null,'C',i.codemprl,tab2_relatives_codemprl,'N',v_upd);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'namrele','N','numseq',null,null,'C',i.namrele,tab2_relatives_namrele,'N',v_upd);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'namrelt','N','numseq',null,null,'C',i.namrelt,tab2_relatives_namrelt,'N',v_upd);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'namrel3','N','numseq',null,null,'C',i.namrel3,tab2_relatives_namrel3,'N',v_upd);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'namrel4','N','numseq',null,null,'C',i.namrel4,tab2_relatives_namrel4,'N',v_upd);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'namrel5','N','numseq',null,null,'C',i.namrel5,tab2_relatives_namrel5,'N',v_upd);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'numtelec','N','numseq',null,null,'C',i.numtelec,tab2_relatives_numtelec,'N',v_upd);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'adrcomt','N','numseq',null,null,'C',i.adrcomt,tab2_relatives_adrcomt,'N',v_upd);
      end loop;

      if not v_exist then
        if v_numseq is null then
          v_numseq := tab2_relatives_numseq;
        end if;
        tab27_status := 'A'; --user36 JAS590255 20/04/2016
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'codemprl','N','numseq',null,null,'C',null,tab2_relatives_codemprl,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'namrele','N','numseq',null,null,'C',null,tab2_relatives_namrele,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'namrelt','N','numseq',null,null,'C',null,tab2_relatives_namrelt,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'namrel3','N','numseq',null,null,'C',null,tab2_relatives_namrel3,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'namrel4','N','numseq',null,null,'C',null,tab2_relatives_namrel4,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'namrel5','N','numseq',null,null,'C',null,tab2_relatives_namrel5,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'numtelec','N','numseq',null,null,'C',null,tab2_relatives_numtelec,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tempch','26',v_numseq,'adrcomt','N','numseq',null,null,'C',null,tab2_relatives_adrcomt,'N',v_upd,tab27_status);
      end if;
    else
      ess_del_tab2_7(box_item_no);
    end if;
    parameter_err := null;

    if nvl(tab2_staappr,'P') = 'C' then
      tab2_dtecancel := sysdate;
    end if;

    if v_upd then
      begin
        select count(*) into v_count
          from tempch
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 2;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        insert into tempch
        (codempid,dtereq,numseq,
         typchg,codcomp,dteinput,
         approvno,staappr,codappr,
         remarkap,dteappr,routeno,
         codinput,dtecancel,coduser)
        values
        (b_index_codempid,b_index_dtereq,b_index_numseq,
         2,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
         tab2_approvno,'P',tab2_codappr,
         tab2_remarkap,tab2_dteappr,tab2_routeno,
         global_v_codempid,tab2_dtecancel,global_v_coduser);
      else
        update tempch
           set approvno  = tab2_approvno,
               staappr   = 'P',
               codappr   = tab2_codappr,
               remarkap  = tab2_remarkap,
               dteappr   = tab2_dteappr,
               routeno   = tab2_routeno,
               codinput  = global_v_codempid,
               dtecancel = tab2_dtecancel,
               coduser	 = global_v_coduser
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 2;
      end if;
    end if;
  end;
  --
  procedure save_tab_work_exp is
    v_upd  				  boolean;
    v_count         number  := 0;
    v_exist         boolean := false;
    v_numseq        number  := 0;
    v_numappl       temploy1.numappl%type;
    v_codcomp       temploy1.codcomp%type;
    cursor c_tapplwex is
      select numseq,codempid,desnoffi,deslstjob1,deslstpos,
             desoffi1,numteleo,namboss,desres,amtincom,
             dtestart,dteend,codtypwrk,desjob,desrisk,desprotc,remark
        from tapplwex a
       where a.numappl  = v_numappl
         and numseq     = v_numseq;

  begin
    begin
      select numappl,codcomp
        into v_numappl,v_codcomp
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    v_upd   := false;
    if tab_work_exp_numseq is not null then

      v_exist  := false;
      v_numseq := tab_work_exp_numseq;

      for i in c_tapplwex loop
        v_exist := true;
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'desnoffi','N','numseq',null,null,'C',i.desnoffi,tab_work_exp_desnoffi,'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'deslstjob1','N','numseq',null,null,'C',i.deslstjob1,tab_work_exp_deslstjob1,'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'deslstpos','N','numseq',null,null,'C',i.deslstpos,tab_work_exp_deslstpos,'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'desoffi1','N','numseq',null,null,'C',i.desoffi1,tab_work_exp_desoffi1,'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'numteleo','N','numseq',null,null,'C',i.numteleo,tab_work_exp_numteleo,'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'namboss','N','numseq',null,null,'C',i.namboss,tab_work_exp_namboss,'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'desres','N','numseq',null,null,'C',i.desres,tab_work_exp_desres,'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'amtincom','N','numseq',null,null,'C',i.amtincom,tab_work_exp_amtincom,'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'dtestart','N','numseq',null,null,'D',to_char(i.dtestart,'dd/mm/yyyy'),to_char(tab_work_exp_dtestart,'dd/mm/yyyy'),'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'dteend','N','numseq',null,null,'D',to_char(i.dteend,'dd/mm/yyyy'),to_char(tab_work_exp_dteend,'dd/mm/yyyy'),'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'remark','N','numseq',null,null,'C',i.remark,tab_work_exp_remark,'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'desjob','N','numseq',null,null,'C',i.desjob,tab_work_exp_desjob,'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'desrisk','N','numseq',null,null,'C',i.desrisk,tab_work_exp_desrisk,'N',v_upd);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'desprotc','N','numseq',null,null,'C',i.desprotc,tab_work_exp_desprotc,'N',v_upd);
      end loop;

      if not v_exist then
        if v_numseq is null then
          v_numseq := tab_work_exp_numseq;
        end if;
        tab27_status := 'A'; --user36 JAS590255 20/04/2016
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'desnoffi','N','numseq',null,null,'C',null,tab_work_exp_desnoffi,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'deslstjob1','N','numseq',null,null,'C',null,tab_work_exp_deslstjob1,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'deslstpos','N','numseq',null,null,'C',null,tab_work_exp_deslstpos,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'desoffi1','N','numseq',null,null,'C',null,tab_work_exp_desoffi1,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'numteleo','N','numseq',null,null,'C',null,tab_work_exp_numteleo,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'namboss','N','numseq',null,null,'C',null,tab_work_exp_namboss,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'desres','N','numseq',null,null,'C',null,tab_work_exp_desres,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'amtincom','N','numseq',null,null,'C',null,tab_work_exp_amtincom,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'dtestart','N','numseq',null,null,'D',null,to_char(tab_work_exp_dtestart,'dd/mm/yyyy'),'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'dteend','N','numseq',null,null,'D',null,to_char(tab_work_exp_dteend,'dd/mm/yyyy'),'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'remark','N','numseq',null,null,'C',null,tab_work_exp_remark,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'desjob','N','numseq',null,null,'C',null,tab_work_exp_desjob,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'desrisk','N','numseq',null,null,'C',null,tab_work_exp_desrisk,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tapplwexch','32',v_numseq,'desprotc','N','numseq',null,null,'C',null,tab_work_exp_desprotc,'N',v_upd,tab27_status);
      end if;
    else
      ess_del_tab2_7(box_item_no);
    end if;
    parameter_err := null;

    if nvl(tab3_staappr,'P') = 'C' then
      tab3_dtecancel := sysdate;
    end if;

    if v_upd then
      begin
        select count(*) into v_count
          from tempch
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 3;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        insert into tempch
        (codempid,dtereq,numseq,
         typchg,codcomp,dteinput,
         approvno,staappr,codappr,
         remarkap,dteappr,routeno,
         codinput,dtecancel,coduser)
        values
        (b_index_codempid,b_index_dtereq,b_index_numseq,
         3,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
         tab3_approvno,'P',tab3_codappr,
         tab3_remarkap,tab3_dteappr,tab3_routeno,
         global_v_codempid,tab3_dtecancel,global_v_coduser);
      else
        update tempch
           set approvno  = tab3_approvno,
               staappr   = 'P',
               codappr   = tab3_codappr,
               remarkap  = tab3_remarkap,
               dteappr   = tab3_dteappr,
               routeno   = tab3_routeno,
               codinput  = global_v_codempid,
               dtecancel = tab3_dtecancel,
               coduser	 = global_v_coduser
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 3;
      end if;
    end if;
  end;
  --
  procedure save_tab_competency is
    v_upd  				  boolean;
    v_count         number  := 0;
    v_exist         boolean := false;
    v_codtency      tcmptncy.codtency%type;
    v_numappl       temploy1.numappl%type;
    v_codcomp       temploy1.codcomp%type;
    v_numseq        number  := 0;
    cursor c_tcmptncy is
--      select numappl,codtency,codempid,grade
--        from tcmptncy a
--       where a.numappl  = v_numappl
--         and codtency   = v_codtency;
      select  emp.numappl,jd.codtency as typtency,jd.codskill,cpt.grade,'JD' as typjd
      from    temploy1 emp, tjobposskil jd, tcmptncy cpt
      where   emp.codempid    = b_index_codempid
      and     emp.codcomp     = jd.codcomp
      and     emp.codpos      = jd.codpos
      and     emp.numappl     = cpt.numappl(+)
      and     jd.codskill     = cpt.codtency(+)
      and     jd.codskill     = v_codtency
      union all
      select  emp.numappl,nvl(skl.codtency,'N/A') as typtency,cpt.codtency,cpt.grade,'NA' as typjd
      from    temploy1 emp, tcmptncy cpt, tcompskil skl
      where   emp.codempid    = b_index_codempid
      and     emp.numappl     = cpt.numappl
      and     cpt.codtency    = skl.codskill(+)
      and     cpt.codtency    = v_codtency
      and     not exists (select  1
                          from    tjobposskil jd
                          where   jd.codpos     = emp.codpos
                          and     jd.codcomp    = emp.codcomp
                          and     jd.codskill   = cpt.codtency
                          and     jd.codtency   = skl.codtency)
      order by typjd,typtency;

  begin
--    begin
--      select numappl,codcomp
--        into v_numappl,v_codcomp
--        from temploy1
--       where codempid = b_index_codempid;
--    exception when no_data_found then
--      v_numappl  := null;
--      v_codcomp  := null;
--    end;

    v_upd   := false;
    if tab_competency_codtency is not null then

      v_exist     := false;
      v_codtency  := tab_competency_codtency;
      begin
        select  seqno
        into    v_numseq
        from    temeslog2
        where   codempid    = b_index_codempid
        and     dtereq      = b_index_dtereq
        and     numseq      = b_index_numseq
        and     numpage     = 51
        and     fldkey      = 'CODTENCY'
        and     codseq      = v_codtency
        and     rownum      = 1;
      exception when no_data_found then
        select  nvl(max(seqno),0) + 1
        into    v_numseq
        from    temeslog2
        where   codempid    = b_index_codempid
        and     dtereq      = b_index_dtereq
        and     numseq      = b_index_numseq
        and     fldkey      = 'CODTENCY'
        and     numpage     = 51;
      end;
      for i in c_tcmptncy loop
        v_exist := true;
        upd_log2(b_index_numseq,'tcmptncych','51',v_numseq,'grade','C','codtency',v_codtency,null,'C',i.grade,tab_competency_grade,'N',v_upd);
      end loop;

      if not v_exist then
        if v_codtency is null then
          v_codtency := tab_competency_codtency;
        end if;
        tab27_status := 'A'; --user36 JAS590255 20/04/2016
        upd_log2(b_index_numseq,'tcmptncych','51',v_numseq,'grade','C','codtency',v_codtency,null,'C',null,tab_competency_grade,'N',v_upd,tab27_status);
      end if;
    else
      ess_del_tab2_7(box_item_no);
    end if;
    parameter_err := null;

    if nvl(tab5_staappr,'P') = 'C' then
      tab5_dtecancel := sysdate;
    end if;

    if v_upd then
      begin
        select count(*) into v_count
          from tempch
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 5;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        insert into tempch
        (codempid,dtereq,numseq,
         typchg,codcomp,dteinput,
         approvno,staappr,codappr,
         remarkap,dteappr,routeno,
         codinput,dtecancel,coduser)
        values
        (b_index_codempid,b_index_dtereq,b_index_numseq,
         5,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
         tab5_approvno,'P',tab5_codappr,
         tab5_remarkap,tab5_dteappr,tab5_routeno,
         global_v_codempid,tab5_dtecancel,global_v_coduser);
      else
        update tempch
           set approvno  = tab5_approvno,
               staappr   = 'P',
               codappr   = tab5_codappr,
               remarkap  = tab5_remarkap,
               dteappr   = tab5_dteappr,
               routeno   = tab5_routeno,
               codinput  = global_v_codempid,
               dtecancel = tab5_dtecancel,
               coduser	 = global_v_coduser
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 5;
      end if;
    end if;
  end;
  --
  procedure save_tab_lang_abi is
    v_upd  				  boolean;
    v_count         number  := 0;
    v_exist         boolean := false;
    v_codlang       tlangabi.codlang%type;
    v_numappl       temploy1.numappl%type;
    v_codcomp       temploy1.codcomp%type;
    v_numseq        number  := 0;
    cursor c_tlangabi is
      select numappl,codlang,codempid,flglist,flgspeak,flgread,flgwrite
        from tlangabi a
       where a.numappl  = v_numappl
         and codlang    = v_codlang
    order by codlang;

  begin
    begin
      select numappl,codcomp
        into v_numappl,v_codcomp
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    v_upd   := false;
    if tab_lang_abi_codlang is not null then

      v_exist     := false;
      v_codlang   := tab_lang_abi_codlang;
      begin
        select  seqno
        into    v_numseq
        from    temeslog2
        where   codempid    = b_index_codempid
        and     dtereq      = b_index_dtereq
        and     numseq      = b_index_numseq
        and     numpage     = 52
        and     codseq      = v_codlang
        and     rownum      = 1;
      exception when no_data_found then
        select  nvl(max(seqno),0) + 1
        into    v_numseq
        from    temeslog2
        where   codempid    = b_index_codempid
        and     dtereq      = b_index_dtereq
        and     numseq      = b_index_numseq
        and     numpage     = 52;
      end;
      for i in c_tlangabi loop
        v_exist := true;
        upd_log2(b_index_numseq,'tlangabich','52',v_numseq,'flglist','C','codlang',v_codlang,null,'C',i.flglist,tab_lang_abi_flglist,'N',v_upd);
        upd_log2(b_index_numseq,'tlangabich','52',v_numseq,'flgspeak','C','codlang',v_codlang,null,'C',i.flgspeak,tab_lang_abi_flgspeak,'N',v_upd);
        upd_log2(b_index_numseq,'tlangabich','52',v_numseq,'flgread','C','codlang',v_codlang,null,'C',i.flgread,tab_lang_abi_flgread,'N',v_upd);
        upd_log2(b_index_numseq,'tlangabich','52',v_numseq,'flgwrite','C','codlang',v_codlang,null,'C',i.flgwrite,tab_lang_abi_flgwrite,'N',v_upd);
      end loop;

      if not v_exist then
        if v_codlang is null then
          v_codlang := tab_lang_abi_codlang;
        end if;
        tab27_status := 'A'; --user36 JAS590255 20/04/2016
        upd_log2(b_index_numseq,'tlangabich','52',v_numseq,'flglist','C','codlang',v_codlang,null,'C',null,tab_lang_abi_flglist,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tlangabich','52',v_numseq,'flgspeak','C','codlang',v_codlang,null,'C',null,tab_lang_abi_flgspeak,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tlangabich','52',v_numseq,'flgread','C','codlang',v_codlang,null,'C',null,tab_lang_abi_flgread,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'tlangabich','52',v_numseq,'flgwrite','C','codlang',v_codlang,null,'C',null,tab_lang_abi_flgwrite,'N',v_upd,tab27_status);
      end if;
    else
      ess_del_tab2_7(box_item_no);
    end if;
    parameter_err := null;

    if nvl(tab5_staappr,'P') = 'C' then
      tab5_dtecancel := sysdate;
    end if;

    if v_upd then
      begin
        select count(*) into v_count
          from tempch
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 5;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        insert into tempch
        (codempid,dtereq,numseq,
         typchg,codcomp,dteinput,
         approvno,staappr,codappr,
         remarkap,dteappr,routeno,
         codinput,dtecancel,coduser)
        values
        (b_index_codempid,b_index_dtereq,b_index_numseq,
         5,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
         tab5_approvno,'P',tab5_codappr,
         tab5_remarkap,tab5_dteappr,tab5_routeno,
         global_v_codempid,tab5_dtecancel,global_v_coduser);
      else
        update tempch
           set approvno  = tab5_approvno,
               staappr   = 'P',
               codappr   = tab5_codappr,
               remarkap  = tab5_remarkap,
               dteappr   = tab5_dteappr,
               routeno   = tab5_routeno,
               codinput  = global_v_codempid,
               dtecancel = tab5_dtecancel,
               coduser	 = global_v_coduser
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 5;
      end if;
    end if;
  end;
  --
  procedure save_tab_his_reward is
    v_upd  				  boolean;
    v_count         number  := 0;
    v_exist         boolean := false;
    v_dteinput      date;
    v_numappl       temploy1.numappl%type;
    v_codcomp       temploy1.codcomp%type;
    v_numseq        number  := 0;
    cursor c_thisrewd is
      select dteinput,typrewd,desrewd1,numhmref,filename,numrefdoc
        from thisrewd a
       where a.codempid   = b_index_codempid
         and dteinput     = v_dteinput
    order by dteinput;

  begin
--    begin
--      select numappl,codcomp
--        into v_numappl,v_codcomp
--        from temploy1
--       where codempid = b_index_codempid;
--    exception when no_data_found then
--      v_numappl  := null;
--      v_codcomp  := null;
--    end;

    v_upd   := false;
    if tab_his_reward_dteinput is not null then

      v_exist     := false;
      v_dteinput  := tab_his_reward_dteinput;
      begin
        select  seqno
        into    v_numseq
        from    temeslog2
        where   codempid    = b_index_codempid
        and     dtereq      = b_index_dtereq
        and     numseq      = b_index_numseq
        and     numpage     = 53
        and     dteseq      = v_dteinput
        and     rownum      = 1;
      exception when no_data_found then
        select  nvl(max(seqno),0) + 1
        into    v_numseq
        from    temeslog2
        where   codempid    = b_index_codempid
        and     dtereq      = b_index_dtereq
        and     numseq      = b_index_numseq
        and     numpage     = 53;
      end;
      for i in c_thisrewd loop
        v_exist := true;
        upd_log2(b_index_numseq,'thisrewdch','53',v_numseq,'typrewd','D','dteinput',null,v_dteinput,'C',i.typrewd,tab_his_reward_typrewd,'N',v_upd);
        upd_log2(b_index_numseq,'thisrewdch','53',v_numseq,'desrewd1','D','dteinput',null,v_dteinput,'C',i.desrewd1,tab_his_reward_desrewd1,'N',v_upd);
        upd_log2(b_index_numseq,'thisrewdch','53',v_numseq,'numhmref','D','dteinput',null,v_dteinput,'C',i.numhmref,tab_his_reward_numhmref,'N',v_upd);
        upd_log2(b_index_numseq,'thisrewdch','53',v_numseq,'filename','D','dteinput',null,v_dteinput,'C',i.filename,tab_his_reward_filename,'N',v_upd);
      end loop;

      if not v_exist then
        if v_dteinput is null then
          v_dteinput := tab_his_reward_dteinput;
        end if;
        tab27_status := 'A'; --user36 JAS590255 20/04/2016
        upd_log2(b_index_numseq,'thisrewdch','53',v_numseq,'typrewd','D','dteinput',null,v_dteinput,'C',null,tab_his_reward_typrewd,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'thisrewdch','53',v_numseq,'desrewd1','D','dteinput',null,v_dteinput,'C',null,tab_his_reward_desrewd1,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'thisrewdch','53',v_numseq,'numhmref','D','dteinput',null,v_dteinput,'C',null,tab_his_reward_numhmref,'N',v_upd,tab27_status);
        upd_log2(b_index_numseq,'thisrewdch','53',v_numseq,'filename','D','dteinput',null,v_dteinput,'C',null,tab_his_reward_filename,'N',v_upd,tab27_status);
      end if;
    else
      ess_del_tab2_7(box_item_no);
    end if;
    parameter_err := null;

    if nvl(tab5_staappr,'P') = 'C' then
      tab5_dtecancel := sysdate;
    end if;

    if v_upd then
      begin
        select count(*) into v_count
          from tempch
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 5;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        insert into tempch
        (codempid,dtereq,numseq,
         typchg,codcomp,dteinput,
         approvno,staappr,codappr,
         remarkap,dteappr,routeno,
         codinput,dtecancel,coduser)
        values
        (b_index_codempid,b_index_dtereq,b_index_numseq,
         5,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
         tab5_approvno,'P',tab5_codappr,
         tab5_remarkap,tab5_dteappr,tab5_routeno,
         global_v_codempid,tab5_dtecancel,global_v_coduser);
      else
        update tempch
           set approvno  = tab5_approvno,
               staappr   = 'P',
               codappr   = tab5_codappr,
               remarkap  = tab5_remarkap,
               dteappr   = tab5_dteappr,
               routeno   = tab5_routeno,
               codinput  = global_v_codempid,
               dtecancel = tab5_dtecancel,
               coduser	 = global_v_coduser
         where codempid  = b_index_codempid
           and dtereq    = b_index_dtereq
           and numseq    = b_index_numseq
           and typchg    = 5;
      end if;
    end if;
  end;
  --
  procedure save_education is
    v_code				varchar2(30 char);
    v_numseq			number;
    v_numappl			temploy1.numappl%type;
    v_upd  				boolean;
    v_exist				boolean;
    v_exitch    	    boolean;
    v_aler  			boolean;
    v_count             number := 0;
    box_item_no3        number;
    v_box_json3         json_object_t;

	cursor c_teducatn is
		select numappl,numseq,codempid,codedlv,coddglv,
		       codmajsb,codminsb,codinst,codcount,numgpa,
		       stayear,dtegyear,flgeduc,dteupd,coduser
		  from teducatn
--		 where nvl(codempid,numappl) = b_index_codempid
		 where numappl  = v_numappl
		   and numseq   = v_numseq;
  begin
    begin
      select  numappl
      into    v_numappl
      from    temploy1
      where   codempid = b_index_codempid	;
    exception when no_data_found then
      v_numappl  := null;
    end;
      tab31_desc_codedlv  := get_tcodec_name('TCODEDUC',tab31_codedlv,global_v_lang);
      tab31_desc_coddglv  := get_tcodec_name('TCODDGEE',tab31_coddglv,global_v_lang);
      tab31_desc_codmajsb := get_tcodec_name('TCODMAJR',tab31_codmajsb,global_v_lang);
      tab31_desc_codminsb := get_tcodec_name('TCODSUBJ',tab31_codminsb,global_v_lang);
      tab31_desc_codinst  := get_tcodec_name('TCODINST',tab31_codinst,global_v_lang);
      tab31_desc_codcount := get_tcodec_name('TCODCNTY',tab31_codcount,global_v_lang);

      if tab31_codedlv is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRES32EC12',global_v_lang,'30'));
        return;
      end if;

      if tab31_flgeduc is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRES32EC12',global_v_lang,'120'));
        return;
      end if;
      begin
        select codcodec into v_code
          from tcodeduc
         where codcodec = tab31_codedlv;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
      end;

      if tab31_coddglv is not null then
        begin
          select codcodec into v_code
            from tcoddgee
           where codcodec = tab31_coddglv;
        exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
        end;
      end if;

      if tab31_codmajsb is not null then
        begin
          select codcodec into v_code
            from tcodmajr
           where codcodec = tab31_codmajsb;
        exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
        end;
      end if;

      if tab31_codinst is not null then
        begin
          select codcodec into v_code
            from tcodinst
           where codcodec = tab31_codinst;
        exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
        end;
      end if;

      if tab31_codcount is not null then
        begin
          select codcodec into v_code
            from tcodcnty
           where codcodec = tab31_codcount;
        exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
        end;
      end if;

      if tab31_codminsb is not null then
        begin
          select codcodec into v_code
            from tcodsubj
           where codcodec = tab31_codminsb;
        exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
        end;
      end if;

      if to_number(tab31_numgpa) > 100 then
        param_msg_error := get_error_msg_php('ES0013',global_v_lang);
        return;
      end if;

      if to_number(tab31_stayear) > to_number(to_char(sysdate,'yyyy'))then
        param_msg_error := get_error_msg_php('ES0016',global_v_lang);
        return;
      end if;

      if to_number(tab31_dtegyear) > to_number(to_char(sysdate,'yyyy')) then
        param_msg_error := get_error_msg_php('ES0017',global_v_lang);
        return;
      end if;

      if to_number(tab31_stayear) > to_number(tab31_dtegyear) then
        param_msg_error := get_error_msg_php('ES0018',global_v_lang);
        return;
      end if;

      tab3_numseq	   		  :=  tab31_numseq;
      tab3_codedlv    		:=  tab31_codedlv;
      tab3_desc_codedlv	  :=  tab31_desc_codedlv;
      tab3_coddglv    		:=  tab31_coddglv;
      tab3_desc_coddglv   :=  tab31_desc_coddglv;
      tab3_codmajsb   		:=  tab31_codmajsb;
      tab3_desc_codmajsb  :=  tab31_desc_codmajsb;
      tab3_codminsb   		:=  tab31_codminsb;
      tab3_codinst    		:=  tab31_codinst;
      tab3_desc_codinst   :=  tab31_desc_codinst;
      tab3_codcount   		:=  tab31_codcount;
      tab3_desc_codcount  :=  tab31_desc_codcount;
      tab3_numgpa     		:=  tab31_numgpa;
      tab3_dtegyear   		:=  tab31_dtegyear;
      tab3_stayear    		:=  tab31_stayear;
      tab3_flgeduc    		:=  tab31_flgeduc;

        if tab31_flgeduc = '1' then
          tab3_codedlv  := tab31_codedlv;
          tab3_codmajsb := tab31_codmajsb;

        if tab3_numseq <> tab31_numseq and tab3_flgeduc = '1' then
          tab3_flgeduc := '2';
        end if;

      end if;

      tab31_flgupdat  := 'Y' ;
      v_exist         := false;
      v_upd           := false;

      if tab3_numseq = tab31_numseq then
        v_numseq := tab3_numseq;

        for i in c_teducatn loop
          v_exist := true;
          upd_log2(b_index_numseq,'teductch','31',v_numseq,'codedlv','N','numseq',null,null,'C',i.codedlv,tab3_codedlv,'N',v_upd);
          upd_log2(b_index_numseq,'teductch','31',v_numseq,'coddglv','N','numseq',null,null,'C',i.coddglv,tab3_coddglv,'N',v_upd);
          upd_log2(b_index_numseq,'teductch','31',v_numseq,'codmajsb','N','numseq',null,null,'C',i.codmajsb,tab3_codmajsb,'N',v_upd);
          upd_log2(b_index_numseq,'teductch','31',v_numseq,'codminsb','N','numseq',null,null,'C',i.codminsb,tab3_codminsb,'N',v_upd);
          upd_log2(b_index_numseq,'teductch','31',v_numseq,'codinst','N','numseq',null,null,'C',i.codinst,tab3_codinst,'N',v_upd);
          upd_log2(b_index_numseq,'teductch','31',v_numseq,'codcount','N','numseq',null,null,'C',i.codcount,tab3_codcount,'N',v_upd);
          upd_log2(b_index_numseq,'teductch','31',v_numseq,'numgpa','N','numseq',null,null,'N',i.numgpa,tab3_numgpa,'N',v_upd);
          upd_log2(b_index_numseq,'teductch','31',v_numseq,'stayear','N','numseq',null,null,'N',i.stayear,tab3_stayear,'N',v_upd);
          upd_log2(b_index_numseq,'teductch','31',v_numseq,'dtegyear','N','numseq',null,null,'N',i.dtegyear,tab3_dtegyear,'N',v_upd);
          upd_log2(b_index_numseq,'teductch','31',v_numseq,'flgeduc','N','numseq',null,null,'C',i.flgeduc,tab3_flgeduc,'N',v_upd);
        end loop;
      end if;

      if not v_exist then
        if v_numseq is null then
          v_numseq := gen_numseq_tab3;
        end if;

        tab31_status := 'A'; --user36 JAS590255 20/04/2016
        upd_log2(b_index_numseq,'teductch','31',v_numseq,'codedlv','N','numseq',null,null,'C',null,tab31_codedlv,'N',v_upd,tab31_status);
        upd_log2(b_index_numseq,'teductch','31',v_numseq,'coddglv','N','numseq',null,null,'C',null,tab31_coddglv,'N',v_upd,tab31_status);
        upd_log2(b_index_numseq,'teductch','31',v_numseq,'codmajsb','N','numseq',null,null,'C',null,tab31_codmajsb,'N',v_upd,tab31_status);
        upd_log2(b_index_numseq,'teductch','31',v_numseq,'codminsb','N','numseq',null,null,'C',null,tab31_codminsb,'N',v_upd,tab31_status);
        upd_log2(b_index_numseq,'teductch','31',v_numseq,'codinst','N','numseq',null,null,'C',null,tab31_codinst,'N',v_upd,tab31_status);
        upd_log2(b_index_numseq,'teductch','31',v_numseq,'codcount','N','numseq',null,null,'C',null,tab31_codcount,'N',v_upd,tab31_status);
        upd_log2(b_index_numseq,'teductch','31',v_numseq,'numgpa','N','numseq',null,null,'N',null,tab31_numgpa,'N',v_upd,tab31_status);
        upd_log2(b_index_numseq,'teductch','31',v_numseq,'stayear','N','numseq',null,null,'N',null,tab31_stayear,'N',v_upd,tab31_status);
        upd_log2(b_index_numseq,'teductch','31',v_numseq,'dtegyear','N','numseq',null,null,'N',null,tab31_dtegyear,'N',v_upd,tab31_status);
        upd_log2(b_index_numseq,'teductch','31',v_numseq,'flgeduc','N','numseq',null,null,'C',null,tab31_flgeduc,'N',v_upd,tab31_status);
      end if;

      if nvl(tab3_staappr,'P') = 'C' then
        tab3_dtecancel := sysdate;
      end if;

      if v_upd then
        begin
          select count(*) into v_count
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 3;
        exception when no_data_found then
          v_count := 0;
        end;

        if v_count = 0 then
            insert into tempch ( codempid,dtereq,numseq,
                                 typchg,codcomp,dteinput,
                                 approvno,staappr,codappr,
                                 remarkap,dteappr,routeno,
                                 codinput,
                                 dtecancel,coduser)
                        values ( b_index_codempid,b_index_dtereq,b_index_numseq,
                                 3,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                                 tab3_approvno,'P',tab3_codappr,
                                 tab3_remarkap,tab3_dteappr,tab3_routeno,
                                 global_v_codempid,
                                 tab3_dtecancel,global_v_coduser);
        else
         update tempch
            set	approvno  = tab31_approvno,
                staappr   = 'P',
                codappr   = tab31_codappr,
                remarkap  = tab31_remarkap,
                dteappr   = tab31_dteappr,
                routeno   = tab31_routeno,
                codinput  = global_v_codempid,
                dtecancel = tab3_dtecancel,
                coduser	  = global_v_coduser
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 3;
        end if; --v_count = 0
      end if;   --v_upd
    commit;
  end save_education;
  --
  procedure save_tab4 is
    v_aler 		    boolean;
    v_numseq  	    number;
    v_exist         boolean;
    v_upd           boolean;
    v_count         number;
    v_code		    varchar2(10 char);
    box_item_no4    number;
    v_box_json4     json_object_t;

	cursor c_tchildrn is
		select a.*,a.rowid
		  from tchildrn a
		 where a.codempid = b_index_codempid
		   and a.numseq   = v_numseq;

  begin
        if tab4_numseq is null then
           tab4_numseq := gen_numseq_tab4;
        end if;

        if to_number(tab4_numseq) > 0 then
--          if tab4_namche is null and global_v_lang = '101' then
--            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--            return;
--          end if;
--          if tab4_namcht is null and global_v_lang = '102' then
--            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--            return;
--          end if;
--          if tab4_namch3 is null and global_v_lang = '103' then
--            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--            return;
--          end if;
--          if tab4_namch4 is null and global_v_lang = '104' then
--            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--            return;
--          end if;
--          if tab4_namch5 is null and global_v_lang = '105' then
--            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--            return;
--          end if;
--          if tab4_dtechbd is null then
--            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--            return;
--          end if;
          if tab4_codedlv is not null then
            begin
              select codcodec into v_code
              from	 tcodeduc
              where	 codcodec = tab4_codedlv;
            exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang);
            return;
            end;
          end if;
          if tab4_dtechbd > to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy') then
            param_msg_error := get_error_msg_php('HR4508',global_v_lang);
            return;
          end if;

          v_numseq := tab4_numseq;
          v_exist  := false;
          v_upd    := false;
          for i in c_tchildrn loop
            v_exist := true;
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namche','N','numseq',null,null,'C',i.namche,get_tlistval_name('CODTITLE',tab4_codtitle,'101')||tab4_namfirste||' '||tab4_namlaste,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namcht','N','numseq',null,null,'C',i.namcht,get_tlistval_name('CODTITLE',tab4_codtitle,'102')||tab4_namfirstt||' '||tab4_namlastt,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namch3','N','numseq',null,null,'C',i.namch3,get_tlistval_name('CODTITLE',tab4_codtitle,'103')||tab4_namfirst3||' '||tab4_namlast3,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namch4','N','numseq',null,null,'C',i.namch4,get_tlistval_name('CODTITLE',tab4_codtitle,'104')||tab4_namfirst4||' '||tab4_namlast4,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namch5','N','numseq',null,null,'C',i.namch5,get_tlistval_name('CODTITLE',tab4_codtitle,'105')||tab4_namfirst5||' '||tab4_namlast5,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'codtitle','N','numseq',null,null,'C',i.codtitle,tab4_codtitle,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namfirste','N','numseq',null,null,'C',i.namfirste,tab4_namfirste,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namfirstt','N','numseq',null,null,'C',i.namfirstt,tab4_namfirstt,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namfirst3','N','numseq',null,null,'C',i.namfirst3,tab4_namfirst3,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namfirst4','N','numseq',null,null,'C',i.namfirst4,tab4_namfirst4,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namfirst5','N','numseq',null,null,'C',i.namfirst5,tab4_namfirst5,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namlaste','N','numseq',null,null,'C',i.namlaste,tab4_namlaste,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namlastt','N','numseq',null,null,'C',i.namlastt,tab4_namlastt,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namlast3','N','numseq',null,null,'C',i.namlast3,tab4_namlast3,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namlast4','N','numseq',null,null,'C',i.namlast4,tab4_namlast4,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namlast5','N','numseq',null,null,'C',i.namlast5,tab4_namlast5,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'numoffid','N','numseq',null,null,'C',i.numoffid,tab4_numoffid,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'dtechbd','N','numseq',null,null,'D',to_char(i.dtechbd,'dd/mm/yyyy'),to_char(tab4_dtechbd,'dd/mm/yyyy'),'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'codsex','N','numseq',null,null,'C',i.codsex,tab4_codsex,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'codedlv','N','numseq',null,null,'C',i.codedlv,tab4_codedlv,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'stachld','N','numseq',null,null,'C',i.stachld,tab4_stachld,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'stalife','N','numseq',null,null,'C',i.stalife,tab4_stalife,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'dtedthch','N','numseq',null,null,'D',to_char(i.dtedthch,'dd/mm/yyyy'),to_char(tab4_dtedthch,'dd/mm/yyyy'),'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'flginc','N','numseq',null,null,'C',i.flginc,tab4_flginc,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'flgedlv','N','numseq',null,null,'C',i.flgedlv,tab4_flgedlv,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'flgdeduct','N','numseq',null,null,'C',i.flgdeduct,tab4_flgdeduct,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'stabf','N','numseq',null,null,'C',i.stabf,tab4_stabf,'N',v_upd);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'filename','N','numseq',null,null,'C',i.filename,tab4_filename,'N',v_upd);
          end loop;

          if not v_exist then
            tab4_status := 'A'; --user36 JAS590255 20/04/2016
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namche','N','numseq',null,null,'C',null,get_tlistval_name('CODTITLE',tab4_codtitle,'101')||tab4_namfirste||' '||tab4_namlaste,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namcht','N','numseq',null,null,'C',null,get_tlistval_name('CODTITLE',tab4_codtitle,'102')||tab4_namfirstt||' '||tab4_namlastt,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namch3','N','numseq',null,null,'C',null,get_tlistval_name('CODTITLE',tab4_codtitle,'103')||tab4_namfirst3||' '||tab4_namlast3,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namch4','N','numseq',null,null,'C',null,get_tlistval_name('CODTITLE',tab4_codtitle,'104')||tab4_namfirst4||' '||tab4_namlast4,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namch5','N','numseq',null,null,'C',null,get_tlistval_name('CODTITLE',tab4_codtitle,'105')||tab4_namfirst5||' '||tab4_namlast5,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'codtitle','N','numseq',null,null,'C',null,tab4_codtitle,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namfirste','N','numseq',null,null,'C',null,tab4_namfirste,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namfirstt','N','numseq',null,null,'C',null,tab4_namfirstt,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namfirst3','N','numseq',null,null,'C',null,tab4_namfirst3,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namfirst4','N','numseq',null,null,'C',null,tab4_namfirst4,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namfirst5','N','numseq',null,null,'C',null,tab4_namfirst5,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namlaste','N','numseq',null,null,'C',null,tab4_namlaste,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namlastt','N','numseq',null,null,'C',null,tab4_namlastt,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namlast3','N','numseq',null,null,'C',null,tab4_namlast3,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namlast4','N','numseq',null,null,'C',null,tab4_namlast4,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'namlast5','N','numseq',null,null,'C',null,tab4_namlast5,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'numoffid','N','numseq',null,null,'C',null,tab4_numoffid,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'dtechbd','N','numseq',null,null,'D',null,to_char(tab4_dtechbd,'dd/mm/yyyy'),'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'codsex','N','numseq',null,null,'C',null,tab4_codsex,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'codedlv','N','numseq',null,null,'C',null,tab4_codedlv,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'stachld','N','numseq',null,null,'C',null,tab4_stachld,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'stalife','N','numseq',null,null,'C',null,tab4_stalife,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'dtedthch','N','numseq',null,null,'D',null,to_char(tab4_dtedthch,'dd/mm/yyyy'),'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'flginc','N','numseq',null,null,'C',null,tab4_flginc,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'flgedlv','N','numseq',null,null,'C',null,tab4_flgedlv,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'flgdeduct','N','numseq',null,null,'C',null,tab4_flgdeduct,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'stabf','N','numseq',null,null,'C',null,tab4_stabf,'N',v_upd,tab4_status);
            upd_log2(b_index_numseq,'tchildch','41',v_numseq,'filename','N','numseq',null,null,'C',null,tab4_filename,'N',v_upd,tab4_status);
          end if;

          if nvl(tab4_staappr,'P') = 'C' then
            tab4_dtecancel := sysdate;
          end if;

          if v_upd then
            begin
              select count(*) into v_count
                from tempch
               where codempid = b_index_codempid
                 and dtereq   = b_index_dtereq
                 and numseq   = b_index_numseq
                 and typchg   = 4;
            exception when no_data_found then
              v_count := 0;
            end;

            if v_count = 0 then
                insert into tempch
                                    (codempid,dtereq,numseq,
                                     typchg,codcomp,dteinput,
                                     approvno,staappr,codappr,
                                     remarkap,dteappr,routeno,
                                     codinput,
                                     dtecancel,coduser)
                        values
                                    (b_index_codempid,b_index_dtereq,b_index_numseq,
                                     4,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                                     tab4_approvno,'P',tab4_codappr,
                                     tab4_remarkap,tab4_dteappr,tab4_routeno,
                                     global_v_codempid,
                                     tab4_dtecancel,global_v_coduser);
            else
             update tempch
                set	approvno  = tab4_approvno,
                    staappr   = 'P',
                    codappr   = tab4_codappr,
                    remarkap  = tab4_remarkap,
                    dteappr   = tab4_dteappr,
                    routeno   = tab4_routeno,
                    codinput  = global_v_codempid,
                    dtecancel = tab4_dtecancel,
                    coduser	  = global_v_coduser
               where codempid = b_index_codempid
                 and dtereq   = b_index_dtereq
                 and numseq   = b_index_numseq
                 and typchg   = 4;
            end if;
          end if;
        end if;
      commit;
--      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
  end save_tab4;
  --
  procedure save_tab5 is
	v_aler 		  	boolean;
	v_upd  				boolean;
	v_count			  number;

  begin
    tab5_desc_typrewd := get_tcodec_name('TCODREWD',tab5_typrewd,global_v_lang);
        if tab5_typrewd is not null then
          begin
             select codcodec into tab5_typrewd
               from tcodrewd
              where	codcodec = tab5_typrewd ;
          exception when others then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
          end ;
        else
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
        end if;

        if nvl(tab5_staappr,'P') = 'C' then
          tab5_dtecancel := sysdate;
        end if;

        tab5_staappr  := 'P';

        begin
          select codcomp,codpos,codjob,numlvl
          into   tab5_codcomp,tab5_codpos,
                 tab5_codjob,tab5_numlvl
          from   temploy1
          where  codempid = b_index_codempid;
        exception when no_data_found then
          null;
        end;

        if tab5_typrewd is not null then
            upd_log1(b_index_numseq,'trewdreq','5','typrewd','C',null,tab5_typrewd,'N',v_upd);
        end if;

        if tab5_desrewd1 is not null then
            upd_log1(b_index_numseq,'trewdreq','5','desrewd1','C',null,tab5_desrewd1,'N',v_upd);
        end if;

        if tab5_numhmref is not null then
            upd_log1(b_index_numseq,'trewdreq','5','numhmref','C',null,tab5_numhmref,'N',v_upd);
        end if;

        begin
          select count(*) into v_count
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 5;
        exception when no_data_found then
          v_count := 0;
        end;

        if v_count = 0 then
            insert into tempch (codempid,dtereq,numseq,
                                typchg,codcomp,dteinput,
                                approvno,staappr,codappr,
                                dteappr,remarkap,routeno,
                                codinput,
                                dtecancel,coduser)

                  values			 (b_index_codempid,b_index_dtereq,b_index_numseq,
                                5,tab5_codcomp,to_date(sysdate,'DD/MM/YYYY HH24:MI:SS'),
                                tab5_approvno,tab5_staappr,tab5_codappr,
                                tab5_dteappr,tab5_remarkap,tab5_routeno,
                                global_v_codempid,
                                null,global_v_coduser);
        else
            update tempch
               set approvno  = tab5_approvno,
                   staappr   = 'P',
                   codappr   = tab5_codappr,
                   remarkap  = tab5_remarkap,
                   dteappr   = tab5_dteappr,
                   routeno   = tab5_routeno,
                   codinput  = global_v_codempid,
                   dtecancel = tab5_dtecancel,
                   coduser	 = global_v_coduser
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 5;
        end if;
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
  end save_tab5;
  --
  procedure save_tab6 is
    v_aler 		    boolean;
    v_numappl     temploy1.numappl%type;
    v_numseq      number;
    v_exist  	    boolean;
    v_upd         boolean;
    v_count       number;
    box_item_no6  number;
    v_box_json6   json_object_t;

    cursor c_ttrainbf is
      select numappl,numseq,codempid,
             destrain,dtetrain,dtetren,
             desplace,desinstu,filedoc
        from ttrainbf
  --		 where codempid = b_index_codempid
       where numappl  = v_numappl
         and numseq   = v_numseq;

  begin
      begin
        select  numappl
        into    v_numappl
        from    temploy1
        where   codempid = b_index_codempid	;
      exception when no_data_found then
        v_numappl  := null;
      end;
      if tab61_destrain is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
      if tab61_dtetrain > tab61_dtetren then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
      if tab61_flgupd = 'A' then
        null;
      end if;

      tab6_numseq 	  := tab61_numseq;
      tab6_destrain	  := tab61_destrain;
      tab6_dtetrain	  := tab61_dtetrain;
      tab6_dtetren    := tab61_dtetren;
      tab6_dtetr		  := to_char(tab61_dtetrain,'dd/mm/yyyy')||' - '||to_char(tab61_dtetren,'dd/mm/yyyy');
      tab6_desplace	  := tab61_desplace;
      tab6_desinstu	  := tab61_desinstu;
      tab6_filedoc	  := tab61_filedoc;
      if nvl(tab6_staappr,'P') = 'C' then
        tab6_dtecancel := sysdate;
      end if;

      v_exist  := false;
      v_upd    := false;
--        if tab6_numseq is null then
--          tab6_numseq := gen_numseq_tab6;
--        end if;
      if tab6_numseq = tab61_numseq then
        v_numseq := tab6_numseq;
--        if tab6_numseq > 0 then
--          v_numseq := tab6_numseq;
          for i in c_ttrainbf loop
            v_exist := true;
            upd_log2(b_index_numseq,'ttrainch','61',v_numseq,'destrain','N','numseq',null,null,'C',i.destrain,tab6_destrain,'N',v_upd);
            upd_log2(b_index_numseq,'ttrainch','61',v_numseq,'dtetrain','N','numseq',null,null,'D',to_char(i.dtetrain,'dd/mm/yyyy'),to_char(tab6_dtetrain,'dd/mm/yyyy'),'N',v_upd);
            upd_log2(b_index_numseq,'ttrainch','61',v_numseq,'dtetren','N','numseq',null,null,'D',to_char(i.dtetren,'dd/mm/yyyy'),to_char(tab6_dtetren,'dd/mm/yyyy'),'N',v_upd);
            upd_log2(b_index_numseq,'ttrainch','61',v_numseq,'desplace','N','numseq',null,null,'C',i.desplace,tab6_desplace,'N',v_upd);
            upd_log2(b_index_numseq,'ttrainch','61',v_numseq,'desinstu','N','numseq',null,null,'C',i.desinstu,tab6_desinstu,'N',v_upd);
            upd_log2(b_index_numseq,'ttrainch','61',v_numseq,'filedoc','N','numseq',null,null,'C',i.filedoc,tab6_filedoc,'N',v_upd);
          end loop;
      end if;

      if not v_exist then
        if v_numseq is null then
          v_numseq := gen_numseq_tab6; -- Weerayut 21/12/2017
        end if;
        tab6_status := 'A'; --user36 JAS590255 20/04/2016
        upd_log2(b_index_numseq,'ttrainch','61',v_numseq,'destrain','N','numseq',null,null,'C',null,tab6_destrain,'N',v_upd,tab6_status);
        upd_log2(b_index_numseq,'ttrainch','61',v_numseq,'dtetrain','N','numseq',null,null,'D',null,to_char(tab6_dtetrain,'dd/mm/yyyy'),'N',v_upd,tab6_status);
        upd_log2(b_index_numseq,'ttrainch','61',v_numseq,'dtetren','N','numseq',null,null,'D',null,to_char(tab6_dtetren,'dd/mm/yyyy'),'N',v_upd,tab6_status);
        upd_log2(b_index_numseq,'ttrainch','61',v_numseq,'desplace','N','numseq',null,null,'C',null,tab6_desplace,'N',v_upd,tab6_status);
        upd_log2(b_index_numseq,'ttrainch','61',v_numseq,'desinstu','N','numseq',null,null,'C',null,tab6_desinstu,'N',v_upd,tab6_status);
        upd_log2(b_index_numseq,'ttrainch','61',v_numseq,'filedoc','N','numseq',null,null,'C',null,tab6_filedoc,'N',v_upd,tab6_status);
      end if;

      if v_upd then
        begin
          select count(*) into v_count
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 6;
        exception when no_data_found then
          v_count := 0;
        end;
        if v_count = 0 then
            insert into tempch
                                (codempid,dtereq,numseq,
                                 typchg,codcomp,dteinput,
                                 approvno,staappr,codappr,
                                 remarkap,dteappr,routeno,
                                 codinput,
                                 dtecancel,coduser)
                    values
                                (b_index_codempid,b_index_dtereq,b_index_numseq,
                                 6,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                                 tab6_approvno,'P',tab6_codappr,
                                 tab6_remarkap,tab6_dteappr,tab6_routeno,
                                 global_v_codempid,
                                 null,global_v_coduser);
        else
         update tempch
            set	approvno  = tab61_approvno,
                staappr   = 'P',
                codappr   = tab61_codappr,
                remarkap  = tab61_remarkap,
                dteappr   = tab61_dteappr,
                routeno   = tab61_routeno,
                codinput  = global_v_codempid,
                dtecancel = tab6_dtecancel,
                coduser	  = global_v_coduser
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 6;
        end if;
      end if;
--        end if;
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
  end save_tab6;

  procedure del_tab3 is
    v_del 			boolean;
    chk   			varchar2(1 char) := 'N';
    v_count 		number;
    v_countchg	    number;  --user36 JAS590255 20/04/2016
    v_upd           boolean; --user36 JAS590255 20/04/2016
    v_delseq		number; --user36 JAS590255 20/04/2016
  begin
    if param_msg_error is null then
      begin
        select count(*) into v_countchg
          from temeslog2
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and seqno   	= tab31_numseq
           and numpage  = 3;
      exception when no_data_found then
        v_countchg := 0;
      end;

      --1.for have changed data, delete temeslog2 + tempch.
      if v_countchg > 0 then
        delete temeslog2 where codempid = b_index_codempid
                           and dtereq   = b_index_dtereq
                           and seqno   	= tab31_numseq
                           and numpage  = 3;

        --v_delseq := :tab3.numseq;

      --2.for no have changed data, will delete from TEDUCATN.
      else
        --tab3_status := 'D';
        --:tab3.desc_status := get_tlistval_name('STACHG',:tab3.status,:global.v_lang);
        if nvl(b_index_numseqt3,0) = 0 then
          begin
             select nvl(max(numseq),0) + 1 into	b_index_numseqt3
               from	tempch
              where	codempid = global_v_codempid
                and dtereq   = b_index_dtereq
                and typchg   = 3;
          exception when others then
             b_index_numseqt3 := 1;
          end;
        end if;
        upd_log2_del(b_index_numseqt3,'3',tab31_numseq,'codedlv','N','numseq',null,null,'C',tab31_codedlv,tab31_codedlv,v_upd);
      end if;

      begin
				select count(*) into v_count
				  from temeslog2
				 where codempid = b_index_codempid
			     and dtereq   = b_index_dtereq
			     and numpage  = 3;
			exception when no_data_found then
				v_count := 0;
			end;

			if v_count = 0 then
				delete tempch
				 where codempid = b_index_codempid
			     and dtereq   = b_index_dtereq
			     and typchg 	= 3;
			else
				if nvl(b_index_numseqt3,0) = 0 then
					begin
						 select nvl(max(numseq),0) + 1 into	b_index_numseqt3
						   from	tempch
						  where	codempid = global_v_codempid
				        and dtereq   = b_index_dtereq
				        and typchg   = 3;
					exception when others then
						 b_index_numseqt3 := 1;
					end;
				end if;

				insert_next_step(3,b_index_numseqt3);

				begin
					select count(*) into v_count
					  from tempch
					 where codempid = b_index_codempid
					   and dtereq   = b_index_dtereq
					   and numseq   = b_index_numseqt3
					   and typchg   = 3;
				exception when no_data_found then
					v_count := 0;
				end;
				if v_count = 0 then
					insert into tempch
                      (codempid,dtereq,numseq,
                       typchg,codcomp,dteinput,
                       approvno,staappr,codappr,
                       remarkap,dteappr,routeno,
                       dtecancel,coduser)
          values
                      (b_index_codempid,b_index_dtereq,b_index_numseqt3,
                       3,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                       tab3_approvno,tab3_staappr,tab3_codappr,-- user22 :18/07/2016 : JAS590287 || :tab3.approvno,'P',:tab3.codappr,
                       tab3_remarkap,tab3_dteappr,tab3_routeno,
                       tab3_dtecancel,global_v_coduser);
				else
				 update tempch
						set	approvno  = tab3_approvno,
					 		  staappr   = tab3_staappr,-- user22 :18/07/2016 : JAS590287 || staappr   = 'P',
					 		  codappr   = tab3_codappr,
					 		  remarkap  = tab3_remarkap,
					 		  dteappr   = tab3_dteappr,
					 		  routeno   = tab3_routeno,
						 		dtecancel = tab3_dtecancel,
							  coduser	  = global_v_coduser
					 where codempid = b_index_codempid
					   and dtereq   = b_index_dtereq
					   and numseq   = b_index_numseqt3
					   and typchg   = 3;
				end if;
			end if;
      commit;
      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
    else
      rollback;
      return;
    end if;
  end del_tab3;

  procedure del_tab4 is
    v_del 			boolean;
    chk   			varchar2(1 char) := 'N';
    v_count 		number;
    v_countchg	    number;
    v_upd           boolean;
    v_delseq		number;
  begin
    if param_msg_error is null then
      begin
        select count(*) into v_countchg
          from temeslog2
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and seqno   	= tab4_numseq
           and numpage  = 4;
      exception when no_data_found then
        v_countchg := 0;
      end;

      --1.for have changed data, delete temeslog2 + tempch.
      if v_countchg > 0 then
        delete temeslog2 where codempid = b_index_codempid
                           and dtereq   = b_index_dtereq
                           and seqno   	= tab4_numseq
                           and numpage  = 4;

        --v_delseq := :tab3.numseq;

      --2.for no have changed data, will delete from TEDUCATN.
      else
        --tab3_status := 'D';
        --:tab3.desc_status := get_tlistval_name('STACHG',:tab3.status,:global.v_lang);
        if nvl(b_index_numseqt4,0) = 0 then
          begin
             select nvl(max(numseq),0) + 1 into	b_index_numseqt4
               from	tempch
              where	codempid = global_v_codempid
                and dtereq   = b_index_dtereq
                and typchg   = 4;
          exception when others then
             b_index_numseqt4 := 1;
          end;
        end if;
        upd_log2_del(b_index_numseqt4,'4',tab4_numseq,'namche','N','numseq',null,null,'C',tab4_namche,tab4_namche,v_upd);
        upd_log2_del(b_index_numseqt4,'4',tab4_numseq,'namcht','N','numseq',null,null,'C',tab4_namcht,tab4_namcht,v_upd);
        upd_log2_del(b_index_numseqt4,'4',tab4_numseq,'namch3','N','numseq',null,null,'C',tab4_namch3,tab4_namch3,v_upd);
        upd_log2_del(b_index_numseqt4,'4',tab4_numseq,'namch4','N','numseq',null,null,'C',tab4_namch4,tab4_namch4,v_upd);
        upd_log2_del(b_index_numseqt4,'4',tab4_numseq,'namch5','N','numseq',null,null,'C',tab4_namch5,tab4_namch5,v_upd);
      end if;

      begin
				select count(*) into v_count
				  from temeslog2
				 where codempid = b_index_codempid
			     and dtereq   = b_index_dtereq
			     and numpage  = 4;
			exception when no_data_found then
				v_count := 0;
			end;
			if v_count = 0 then
				delete tempch
				 where codempid = b_index_codempid
			     and dtereq   = b_index_dtereq
			     and typchg 	= 4;
			else
				if nvl(b_index_numseqt4,0) = 0 then
					begin
						 select nvl(max(numseq),0) + 1 into	b_index_numseqt4
						   from	tempch
						  where	codempid = global_v_codempid
				        and dtereq   = b_index_dtereq
				        and typchg   = 4;
					exception when others then
						 b_index_numseqt4 := 1;
					end;
				end if;

				insert_next_step(4,b_index_numseqt4);

				begin
					select count(*) into v_count
					  from tempch
					 where codempid = b_index_codempid
					   and dtereq   = b_index_dtereq
					   and numseq   = b_index_numseqt4
					   and typchg   = 4;
				exception when no_data_found then
					v_count := 0;
				end;
				if v_count = 0 then
					insert into tempch
                      (codempid,dtereq,numseq,
                       typchg,codcomp,dteinput,
                       approvno,staappr,codappr,
                       remarkap,dteappr,routeno,
                       dtecancel,coduser)
          values
                      (b_index_codempid,b_index_dtereq,b_index_numseqt4,
                       4,b_index_codcomp,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                       tab4_approvno,tab4_staappr,tab4_codappr,
                       tab4_remarkap,tab4_dteappr,tab4_routeno,
                       tab4_dtecancel,global_v_coduser);
				else
				 update tempch
						set	approvno  = tab4_approvno,
					 		  staappr   = tab4_staappr,
					 		  codappr   = tab4_codappr,
					 		  remarkap  = tab4_remarkap,
					 		  dteappr   = tab4_dteappr,
					 		  routeno   = tab4_routeno,
						 		dtecancel = tab4_dtecancel,
							  coduser	  = global_v_coduser
					 where codempid = b_index_codempid
					   and dtereq   = b_index_dtereq
					   and numseq   = b_index_numseqt4
					   and typchg   = 4;
				end if;
			end if;
      commit;
      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
    else
      rollback;
      return;
    end if;
  end del_tab4;

  procedure del_tab6 is
    v_count 	  number;
  begin
    if param_msg_error is null then
        delete temeslog2 where codempid = b_index_codempid
                           and dtereq   = b_index_dtereq
                           and numseq   = b_index_numseq
                           and seqno    = tab61_numseq
                           and numpage  = 6;

        begin
          select count(*) into v_count
            from temeslog2
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numpage  = 3;
        exception when no_data_found then
          v_count := 0;
        end;

        if v_count = 0 then
          delete tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and typchg = 6;
        end if;
        commit;
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
    else
      rollback;
      return;
    end if;
  end del_tab6;
  --
  procedure ess_save_tab1(json_str in clob, resp_json_str out clob) is
  begin
    clear_numseq;
    initial_value(json_str);
    check_index;
    insert_next_step(1,b_index_numseq); --weerayut 11/01/2018
    if param_msg_error is null then
--        insert_next_step(1,b_index_numseq); --weerayut 11/01/2018
      save_tab1;
      commit;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str   := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_tab1;
  --
  procedure ess_save_tab2_1(json_str in clob, resp_json_str out clob) is
  begin
    clear_numseq;
    initial_value(json_str);
    check_index;
    if param_msg_error is null then
      insert_next_step(2,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        save_tab2_1;
        commit;
      end if;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_tab2_1;
  --

  procedure ess_save_tab2_2(json_str in clob, resp_json_str out clob) is
  begin
    clear_numseq;
    initial_value(json_str);
    check_index;
    if param_msg_error is null then
      insert_next_step(2,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        save_tab2_2;
        commit;
      end if;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_tab2_2;
  --
  procedure ess_save_travel(json_str in clob, resp_json_str out clob) is
  begin
    clear_numseq;
    initial_value(json_str);
    check_index;
    if param_msg_error is null then
      insert_next_step(2,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        save_tab_travel;
        commit;
      end if;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_travel;
  --
  procedure ess_save_tab2_3(json_str in clob, resp_json_str out clob) is
  begin
    clear_numseq;
    initial_value(json_str);
    check_index;
    if param_msg_error is null then
      insert_next_step(2,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        save_tab2_3;
        commit;
      end if;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_tab2_3;
  --
  procedure ess_save_tab2_4(json_str in clob, resp_json_str out clob) is
  begin
    clear_numseq;
    initial_value(json_str);
    check_index;
    if param_msg_error is null then
      insert_next_step(2,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        save_tab2_4;
        commit;
      end if;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_tab2_4;
  --
  procedure ess_save_tab2_5(json_str in clob, resp_json_str out clob) is
  begin
    clear_numseq;
    initial_value(json_str);
    check_index;
    if param_msg_error is null then
      insert_next_step(2,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        save_tab2_5;
        commit;
      end if;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_tab2_5;
  --
  procedure ess_save_tab2_6(param_json_clob in clob,global_json_str in clob, resp_json_str out clob) is
    global_json_obj   json_object_t := json_object_t(global_json_str);
    json_obj          json_object_t := json_object_t(param_json_clob);
    json_obj_tb       json_object_t;
    json_obj2         clob;
    --json_obj2_tb      clob;
    --v_rowcount        number:= 0;
    v_rowcount_tb     number:= 0;
    v_coduser         varchar2(100 char);
    v_codpswd         varchar2(100 char);
    v_codempid        varchar2(100 char);
    v_lang            varchar2(100 char);
    v_exit            boolean := false;
--    b_index_numseqt2  number := 0;
    b_index_numseqt2  number; -->> User46 08-05-2019 Bug Gen Req Auto
  begin
    clear_numseq;
    initial_value(global_json_str);
--    v_coduser    := hcm_util.get_string(global_json_obj, 'p_coduser');
--    v_codpswd    := hcm_util.get_string(global_json_obj,'p_codpswd');
--    v_lang       := hcm_util.get_string(global_json_obj, 'p_lang');
    for j in 1..3 loop
      global_v_flg := j;
      chk_json_tab2_6(json_obj,j,json_obj_tb,v_rowcount_tb);
      for i in 0..v_rowcount_tb-1 loop
        param_msg_error := null;
        json_obj2  := hcm_util.get_json_t(json_obj_tb,to_char(i)).to_clob();

        initial_value_tab2_6(json_obj2,global_v_flg);

--        global_v_coduser      := v_coduser;
--        global_v_codpswd      := v_codpswd;
--        global_v_lang         := v_lang;

--        b_index_dtereq   := to_date(hcm_util.get_string(json_obj,'p_dtereq'),'dd/mm/yyyy');
--        b_index_codempid := hcm_util.get_string(json_obj, 'p_codempid_query');
--        b_index_numseq := hcm_util.get_string(json_obj, 'p_numseq');
        b_index_numseqt2 := nvl(b_index_numseqt2,b_index_numseq);
        check_index;
        if param_msg_error is null then
          if not v_exit then
            if nvl(b_index_numseqt2,0) = 0 then
              begin
                 select nvl(max(numseq),0) + 1 into	b_index_numseqt2
                   from	tempch
                  where	codempid = b_index_codempid
                    and dtereq   = b_index_dtereq
                    and typchg   = 2;
              exception when others then
                 b_index_numseqt2 := 1;
              end;
            end if;
            insert_next_step(2,b_index_numseqt2);

            v_exit := true;
          end if;
          b_index_numseq := b_index_numseqt2;
          save_tab2_6;
          commit;
        else
          rollback;
          exit;
        end if;
      end loop;
    end loop;

    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_tab2_6;
  --
  procedure ess_save_tab2_7(param_json_clob in clob, resp_json_str out clob) is
    json_obj          json_object_t;-- := json(param_json_clob);
--    global_json_obj   json := json(global_json_str);
    json_obj2         clob;
    v_rowcount        number:= 0;
    v_coduser         varchar2(100 char);
    v_codpswd         varchar2(100 char);
    v_codempid        varchar2(100 char);
    v_lang            varchar2(100 char);
    v_event           varchar2(100 char);
    v_dtereq          date;
    v_numseq          number;
  begin
    clear_numseq;
    initial_value(param_json_clob);
    json_obj    := json_object_t(hcm_util.get_string_t(json_object_t(param_json_clob),'json_input_str'));
    v_rowcount  := json_obj.get_size;
    -- check case : update without edit data table -> check is exists in log table then update staappr from 'C' to 'P'
    if v_rowcount = 0 then
--      v_codempid  := hcm_util.get_string(global_json_obj, 'p_codempid_query');
--      v_dtereq    := to_date(hcm_util.get_string(global_json_obj, 'p_dtereq'), 'dd/mm/yyyy');
--      v_numseq    := to_number(hcm_util.get_string(global_json_obj, 'p_numseq'));
      begin
        update tempch
           set staappr = 'P'
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numseq   = b_index_numseq
           and typchg   = '2';
      end;
      commit;
    elsif v_rowcount > 0 then
      for i in 0..v_rowcount-1 loop
        param_msg_error := null;
        json_obj2  := hcm_util.get_json_t(json_obj,to_char(i)).to_clob();
        initial_value_tab2_7(json_obj2);
        check_event(json_obj2,v_event);
        check_index;
        if param_msg_error is null then
          insert_next_step(2,b_index_numseq); --weerayut 11/01/2018
          if param_msg_error is null then
            if v_event in ('add', 'edit') then
              save_tab2_7;
            elsif v_event in('delete') then
--              ess_del_tab2_7(tab27_numseq);
              ess_del_temeslog2('27',tab27_numseq,'NUMSEQ');
            end if;
          else
            exit;
          end if;
        else
          exit;
        end if;
      end loop;
      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_tab2_7;
  --
  procedure ess_save_tab4(json_str_input in clob, json_str_output out clob) is
    json_obj          json_object_t;
    json_obj2         json_object_t;
    v_rowcount        number:= 0;
    v_flg             varchar2(100 char);
    v_dtereq          date;
    v_numseq          number;
  begin
    clear_numseq;
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      insert_next_step(4,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        json_obj    := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
        v_rowcount  := json_obj.get_size;
        if v_rowcount = 0 then
          begin
            update tempch
               set staappr = 'P'
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = '4';
          end;
          commit;
        elsif v_rowcount > 0 then
          for i in 0..v_rowcount-1 loop
            json_obj2            := hcm_util.get_json_t(json_obj,to_char(i));
            tab4_numseq          := hcm_util.get_string_t(json_obj2,'numseq');
            tab4_codtitle        := hcm_util.get_string_t(json_obj2,'codtitle');
            tab4_namfirste       := hcm_util.get_string_t(json_obj2,'namfirste');
            tab4_namfirstt       := hcm_util.get_string_t(json_obj2,'namfirstt');
            tab4_namfirst3       := hcm_util.get_string_t(json_obj2,'namfirst3');
            tab4_namfirst4       := hcm_util.get_string_t(json_obj2,'namfirst4');
            tab4_namfirst5       := hcm_util.get_string_t(json_obj2,'namfirst5');
            tab4_namlaste        := hcm_util.get_string_t(json_obj2,'namlaste');
            tab4_namlastt        := hcm_util.get_string_t(json_obj2,'namlastt');
            tab4_namlast3        := hcm_util.get_string_t(json_obj2,'namlast3');
            tab4_namlast4        := hcm_util.get_string_t(json_obj2,'namlast4');
            tab4_namlast5        := hcm_util.get_string_t(json_obj2,'namlast5');
            tab4_namche          := hcm_util.get_string_t(json_obj2,'namche');
            tab4_namcht          := hcm_util.get_string_t(json_obj2,'namcht');
            tab4_namch3          := hcm_util.get_string_t(json_obj2,'namch3');
            tab4_namch4          := hcm_util.get_string_t(json_obj2,'namch4');
            tab4_namch5          := hcm_util.get_string_t(json_obj2,'namch5');
            tab4_numoffid        := hcm_util.get_string_t(json_obj2,'numoffid');
            tab4_dtechbd         := to_date(hcm_util.get_string_t(json_obj2,'dtechbd'),'dd/mm/yyyy');
            tab4_codsex          := hcm_util.get_string_t(json_obj2,'codsex');
            tab4_codedlv         := hcm_util.get_string_t(json_obj2,'codedlv');
            tab4_stachld         := hcm_util.get_string_t(json_obj2,'stachld');
            tab4_stalife         := hcm_util.get_string_t(json_obj2,'stalife');
            tab4_dtedthch        := to_date(hcm_util.get_string_t(json_obj2,'dtedthch'),'dd/mm/yyyy');
            tab4_flginc          := hcm_util.get_string_t(json_obj2,'flginc');
            tab4_flgedlv         := hcm_util.get_string_t(json_obj2,'flgedlv');
            tab4_flgdeduct       := hcm_util.get_string_t(json_obj2,'flgdeduct');
            tab4_stabf           := hcm_util.get_string_t(json_obj2,'stabf');
            tab4_filename        := hcm_util.get_string_t(json_obj2,'filename');
            v_flg                := hcm_util.get_string_t(json_obj2,'flg');
            if v_flg in ('add','edit') then
              save_tab4;
            elsif v_flg = 'delete' then
              ess_del_temeslog2('41',tab4_numseq,'NUMSEQ');
            end if;
            if param_msg_error is not null then
              exit;
            end if;
          end loop;
          if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            commit;
          else
            rollback;
          end if;
        end if;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_tab4;
/*    json_obj          json := json(param_json_clob);
    global_json_obj   json := json(global_json_str);
    json_obj2         clob;
    v_rowcount        number:= 0;
    v_coduser         varchar2(100 char);
    v_codpswd         varchar2(100 char);
    v_codempid        varchar2(100 char);
    v_lang            varchar2(100 char);
    v_event           varchar2(100 char);
    v_dtereq          date;
    v_numseq          number;
  begin
    clear_numseq;
    v_coduser  := hcm_util.get_string(global_json_obj, 'p_coduser');
    v_codpswd  := hcm_util.get_string(global_json_obj,'p_codpswd');
    v_lang     := hcm_util.get_string(global_json_obj, 'p_lang');
    v_rowcount := json_obj.count;

    -- check case : update without edit data table -> check is exists in log table then update staappr from 'C' to 'P'
    if v_rowcount = 0 then
      v_codempid  := hcm_util.get_string(global_json_obj, 'p_codempid_query');
      v_dtereq    := to_date(hcm_util.get_string(global_json_obj, 'p_dtereq'), 'dd/mm/yyyy');
      v_numseq    := to_number(hcm_util.get_string(global_json_obj, 'p_numseq'));
      begin
        update tempch
           set staappr = 'P'
         where codempid = v_codempid
           and dtereq   = v_dtereq
           and numseq   = v_numseq
           and typchg   = '4';
      end;
      commit;
    end if;
    --
    for i in 0..v_rowcount-1 loop
      param_msg_error := null;
      json_obj2  := json(json_obj.get(to_char(i))).to_char();
      initial_value(json_obj2);
      initial_value_tab4(json_obj2);
      check_event(json_obj2,v_event);
      --
      global_v_coduser      := v_coduser;
      global_v_codpswd      := v_codpswd;
      global_v_lang         := v_lang;
      --
      check_index;
      if param_msg_error is null then
        insert_next_step(4,b_index_numseq); -- weerayut 11/01/2018
        if param_msg_error is null then
          if v_event in ('add','edit') then
            save_tab4;
            commit;
          elsif v_event = 'delete' then
            b_index_numseqt4 := b_index_numseq;
            del_tab4;
            commit;
          end if;
        else
          rollback;
          exit;
        end if;
      end if;
    end loop;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_tab4;
  --*/
  procedure ess_save_tab5(json_str in clob, resp_json_str out clob) is
  begin
    clear_numseq;
    initial_value(json_str);
    check_index;
    if param_msg_error is null then
      insert_next_step(5,b_index_numseq); -- weerayut 11/01/2018
      if param_msg_error is null then
        save_tab5;
        commit;
      end if;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_tab5;
  --
  procedure ess_save_tab6(json_str_input in clob, json_str_output out clob) is
--    json_obj          json := json(param_json_clob);
    json_obj          json_object_t;
--    global_json_obj   json := json(global_json_str);
    json_obj2         clob;
    v_rowcount        number:= 0;
    v_coduser         varchar2(100 char);
    v_codpswd         varchar2(100 char);
    v_codempid        varchar2(100 char);
    v_lang            varchar2(100 char);
    v_event           varchar2(100 char);
    v_dtereq          date;
    v_numseq          number;
  begin
    clear_numseq;
    initial_value(json_str_input);
    json_obj    := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
--    v_coduser  := hcm_util.get_string(global_json_obj, 'p_coduser');
--    v_codpswd  := hcm_util.get_string(global_json_obj,'p_codpswd');
--    v_lang     := hcm_util.get_string(global_json_obj, 'p_lang');
    v_rowcount := json_obj.get_size;
    -- check case : update without edit data table -> check is exists in log table then update staappr from 'C' to 'P'
    if v_rowcount = 0 then
--      v_codempid  := hcm_util.get_string(global_json_obj, 'p_codempid_query');
--      v_dtereq    := to_date(hcm_util.get_string(global_json_obj, 'p_dtereq'), 'dd/mm/yyyy');
--      v_numseq    := to_number(hcm_util.get_string(global_json_obj, 'p_numseq'));
      begin
        update tempch
           set staappr = 'P'
         where codempid = v_codempid
           and dtereq   = v_dtereq
           and numseq   = v_numseq
           and typchg   = '6';
      end;
      commit;
    elsif v_rowcount > 0 then
--      json_obj2  := json(json_obj.get(to_char(0))).to_char(); -- Weerayut 21/12/2017
--      initial_value(json_obj2); -- Weerayut 21/12/2017

      for i in 0..v_rowcount-1 loop
        param_msg_error := null;
        json_obj2  := hcm_util.get_json_t(json_obj,to_char(i)).to_clob();
        initial_value_tab6(json_obj2);
        check_event(json_obj2,v_event);

--        global_v_coduser      := v_coduser;
--        global_v_codpswd      := v_codpswd;
--        global_v_lang         := v_lang;
        --
        check_index;
        if param_msg_error is null then
          insert_next_step(6,b_index_numseq); -- weerayut 11/01/2018
          if param_msg_error is null then
            if v_event in ('add','edit') then
              save_tab6;
              commit;
            elsif v_event = 'delete' then
              del_tab6;
              commit;
            end if;
          else
            rollback;
            exit;
          end if;
        end if;
      end loop;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_tab6;
  --
  procedure ess_save_relatives(json_str_input in clob, json_str_output out clob) is
    json_obj          json_object_t;
    json_obj2         json_object_t;
    v_rowcount        number:= 0;
    v_flg             varchar2(100 char);
    v_dtereq          date;
    v_numseq          number;
  begin
    clear_numseq;
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      insert_next_step(2,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        json_obj    := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
        v_rowcount  := json_obj.get_size;
        if v_rowcount = 0 then
          begin
            update tempch
               set staappr = 'P'
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = '2';
          end;
          param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          commit;
        elsif v_rowcount > 0 then
          for i in 0..v_rowcount-1 loop
            json_obj2                  := hcm_util.get_json_t(json_obj,to_char(i));
            tab2_relatives_numseq       := hcm_util.get_string_t(json_obj2,'numseq');
            tab2_relatives_codemprl     := hcm_util.get_string_t(json_obj2,'codemprl');
            tab2_relatives_namrele      := hcm_util.get_string_t(json_obj2,'namrele');
            tab2_relatives_namrelt      := hcm_util.get_string_t(json_obj2,'namrelt');
            tab2_relatives_namrel3      := hcm_util.get_string_t(json_obj2,'namrel3');
            tab2_relatives_namrel4      := hcm_util.get_string_t(json_obj2,'namrel4');
            tab2_relatives_namrel5      := hcm_util.get_string_t(json_obj2,'namrel5');
            tab2_relatives_numtelec     := hcm_util.get_string_t(json_obj2,'numtelec');
            tab2_relatives_adrcomt      := hcm_util.get_string_t(json_obj2,'adrcomt');
            v_flg                      := hcm_util.get_string_t(json_obj2,'flg');
            if v_flg in ('add','edit') then
              save_tab_relatives;
            elsif v_flg = 'delete' then
              ess_del_temeslog2('26',tab2_relatives_numseq,'NUMSEQ');
            end if;
            if param_msg_error is not null then
              exit;
            end if;
          end loop;
          if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            commit;
          else
            rollback;
          end if;
        end if;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_relatives;
  --
  procedure ess_save_education(json_str_input in clob, json_str_output out clob) is
    json_obj          json_object_t;
    json_obj2         json_object_t;
    v_rowcount        number:= 0;
    v_flg             varchar2(100 char);
    v_dtereq          date;
    v_numseq          number;
  begin
    clear_numseq;
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      insert_next_step(3,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        json_obj    := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
        v_rowcount  := json_obj.get_size;
        if v_rowcount = 0 then
          begin
            update tempch
               set staappr = 'P'
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = '2';
          end;
          param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          commit;
        elsif v_rowcount > 0 then
          for i in 0..v_rowcount-1 loop
            json_obj2               := hcm_util.get_json_t(json_obj,to_char(i));
            tab31_numseq            := hcm_util.get_string_t(json_obj2,'numseq');
            tab31_codedlv           := hcm_util.get_string_t(json_obj2,'codedlv');
            tab31_codinst           := hcm_util.get_string_t(json_obj2,'codinst');
            tab31_coddglv           := hcm_util.get_string_t(json_obj2,'coddglv');
            tab31_codmajsb          := hcm_util.get_string_t(json_obj2,'codmajsb');
            tab31_codminsb          := hcm_util.get_string_t(json_obj2,'codminsb');
            tab31_numgpa            := hcm_util.get_string_t(json_obj2,'numgpa');
            tab31_dtegyear          := to_number(hcm_util.get_string_t(json_obj2,'dtegyear'));
            tab31_stayear           := to_number(hcm_util.get_string_t(json_obj2,'stayear'));
            tab31_flgeduc           := hcm_util.get_string_t(json_obj2,'flgeduc');
            tab31_codcount          := hcm_util.get_string_t(json_obj2,'codcount');
            v_flg                   := hcm_util.get_string_t(json_obj2,'flg');
            if v_flg in ('add','edit') then
              save_education;
            elsif v_flg = 'delete' then
              ess_del_temeslog2('31',tab31_numseq,'NUMSEQ');
            end if;
            if param_msg_error is not null then
              exit;
            end if;
          end loop;
          if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            commit;
          else
            rollback;
          end if;
        end if;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_education;
  --
  procedure ess_save_work_exp(json_str_input in clob, json_str_output out clob) is
    json_obj          json_object_t;
    json_obj2         json_object_t;
    v_rowcount        number:= 0;
    v_flg             varchar2(100 char);
    v_dtereq          date;
    v_numseq          number;
  begin
    clear_numseq;
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      insert_next_step(3,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        json_obj    := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
        v_rowcount  := json_obj.get_size;
        if v_rowcount = 0 then
          begin
            update tempch
               set staappr = 'P'
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = '2';
          end;
          param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          commit;
        elsif v_rowcount > 0 then
          for i in 0..v_rowcount-1 loop
            json_obj2                  := hcm_util.get_json_t(json_obj,to_char(i));
            tab_work_exp_numseq            := hcm_util.get_string_t(json_obj2,'numseq');
            tab_work_exp_desnoffi          := hcm_util.get_string_t(json_obj2,'desnoffi');
            tab_work_exp_deslstjob1        := hcm_util.get_string_t(json_obj2,'deslstjob1');
            tab_work_exp_deslstpos         := hcm_util.get_string_t(json_obj2,'deslstpos');
            tab_work_exp_desoffi1          := hcm_util.get_string_t(json_obj2,'desoffi1');
            tab_work_exp_numteleo          := hcm_util.get_string_t(json_obj2,'numteleo');
            tab_work_exp_namboss           := hcm_util.get_string_t(json_obj2,'namboss');
            tab_work_exp_desres            := hcm_util.get_string_t(json_obj2,'desres');
            tab_work_exp_amtincom          := hcm_util.get_string_t(json_obj2,'amtincom');
            tab_work_exp_dtestart          := to_date(hcm_util.get_string_t(json_obj2,'dtestart'),'dd/mm/yyyy');
            tab_work_exp_dteend            := to_date(hcm_util.get_string_t(json_obj2,'dteend'),'dd/mm/yyyy');
            tab_work_exp_remark            := hcm_util.get_string_t(json_obj2,'remark');
            tab_work_exp_desjob            := hcm_util.get_string_t(json_obj2,'desjob');
            tab_work_exp_desrisk           := hcm_util.get_string_t(json_obj2,'desrisk');
            tab_work_exp_desprotc          := hcm_util.get_string_t(json_obj2,'desprotc');
            v_flg                      := hcm_util.get_string_t(json_obj2,'flg');
            if v_flg in ('add','edit') then
              save_tab_work_exp;
            elsif v_flg = 'delete' then
              ess_del_temeslog2('32',tab_work_exp_numseq,'NUMSEQ');
            end if;
            if param_msg_error is not null then
              exit;
            end if;
          end loop;
          if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            commit;
          else
            rollback;
          end if;
        end if;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_work_exp;
  --
  procedure ess_save_competency(json_str_input in clob, json_str_output out clob) is
    json_obj          json_object_t;
    json_obj2         json_object_t;
    v_rowcount        number:= 0;
    v_flg             varchar2(100 char);
    v_dtereq          date;
    v_numseq          number;
  begin
    clear_numseq;
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      insert_next_step(5,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        json_obj        := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
        v_rowcount  := json_obj.get_size;
        if v_rowcount = 0 then
          begin
            update tempch
               set staappr = 'P'
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = '2';
          end;
          param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          commit;
        elsif v_rowcount > 0 then
          for i in 0..v_rowcount-1 loop
            json_obj2                   := hcm_util.get_json_t(json_obj,to_char(i));
            tab_competency_codtency     := hcm_util.get_string_t(json_obj2,'codtency');
            tab_competency_grade        := hcm_util.get_string_t(json_obj2,'grade');
            v_flg                       := hcm_util.get_string_t(json_obj2,'flg');
            if v_flg in ('add','edit') then
              save_tab_competency;
            elsif v_flg = 'delete' then
              ess_del_temeslog2('51',tab_competency_codtency,'CODTENCY','C');
            end if;
            if param_msg_error is not null then
              exit;
            end if;
          end loop;
        end if;
        if param_msg_error is null then
          param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          commit;
        else
          rollback;
        end if;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_competency;
  --
  procedure ess_save_lang_abi(json_str_input in clob, json_str_output out clob) is
    json_obj          json_object_t;
    json_obj2         json_object_t;
    v_rowcount        number:= 0;
    v_flg             varchar2(100 char);
    v_dtereq          date;
    v_numseq          number;
  begin
    clear_numseq;
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      insert_next_step(5,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        json_obj    := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
        v_rowcount  := json_obj.get_size;
        if v_rowcount = 0 then
          begin
            update tempch
               set staappr = 'P'
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = '2';
          end;
          param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          commit;
        elsif v_rowcount > 0 then
          for i in 0..v_rowcount-1 loop
            json_obj2                  := hcm_util.get_json_t(json_obj,to_char(i));
            tab_lang_abi_codlang       := hcm_util.get_string_t(json_obj2,'codlang');
            tab_lang_abi_flglist       := hcm_util.get_string_t(json_obj2,'flglist');
            tab_lang_abi_flgspeak      := hcm_util.get_string_t(json_obj2,'flgspeak');
            tab_lang_abi_flgread       := hcm_util.get_string_t(json_obj2,'flgread');
            tab_lang_abi_flgwrite      := hcm_util.get_string_t(json_obj2,'flgwrite');
            v_flg                      := hcm_util.get_string_t(json_obj2,'flg');
            if v_flg in ('add','edit') then
              save_tab_lang_abi;
            elsif v_flg = 'delete' then
              ess_del_temeslog2('52',tab_lang_abi_codlang,'CODLANG','C');
            end if;
            if param_msg_error is not null then
              exit;
            end if;
          end loop;
          if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            commit;
          else
            rollback;
          end if;
        end if;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_lang_abi;
  --
  procedure ess_save_his_reward(json_str_input in clob, json_str_output out clob) is
    json_obj          json_object_t;
    json_obj2         json_object_t;
    v_rowcount        number:= 0;
    v_flg             varchar2(100 char);
    v_dtereq          date;
    v_numseq          number;
  begin
    clear_numseq;
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      insert_next_step(5,b_index_numseq); --weerayut 11/01/2018
      if param_msg_error is null then
        json_obj    := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
        v_rowcount  := json_obj.get_size;
        if v_rowcount = 0 then
          begin
            update tempch
               set staappr = 'P'
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = '2';
          end;
          commit;
        elsif v_rowcount > 0 then
          for i in 0..v_rowcount-1 loop
            json_obj2                 := hcm_util.get_json_t(json_obj,to_char(i));
            tab_his_reward_dteinput   := to_date(hcm_util.get_string_t(json_obj2,'dteinput'),'dd/mm/yyyy');
            tab_his_reward_typrewd    := hcm_util.get_string_t(json_obj2,'typrewd');
            tab_his_reward_desrewd1   := hcm_util.get_string_t(json_obj2,'desrewd1');
            tab_his_reward_numhmref   := hcm_util.get_string_t(json_obj2,'numhmref');
            tab_his_reward_filename   := hcm_util.get_string_t(json_obj2,'filename');
            v_flg                     := hcm_util.get_string_t(json_obj2,'flg');
            v_numseq                  := hcm_util.get_string_t(json_obj2,'p_numseq');
            if v_flg in ('add','edit') then
              save_tab_his_reward;
            elsif v_flg = 'delete' then
              ess_del_temeslog2('53',v_numseq,'DTEINPUT','D');
--              ess_del_temeslog2('53',to_char(tab_his_reward_dteinput,'dd/mm/yyyy'),'DTEINPUT','D');
            end if;
            if param_msg_error is not null then
              exit;
            end if;
          end loop;
          if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            commit;
          else
            rollback;
          end if;
        end if;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_save_his_reward;
  --
  procedure ess_cancel_hres32e(json_str in clob, resp_json_str out clob) is
    json_obj    json_object_t;
    v_upd_staappr varchar(1 char);
  begin
    clear_numseq;
    initial_value(json_str);
    if b_index_dtereq is not null then
      select staappr
       into	v_staappr
       from	tempch
      where	codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and typchg   = b_index_typchg;

      if v_staappr in ('P', 'C') then
        if v_staappr = 'P' then
          v_upd_staappr := 'C';
        elsif v_staappr = 'C' then
          v_upd_staappr := 'P';
        end if;
        begin
            update tempch
               set staappr   = v_upd_staappr,
                   dtecancel = trunc(sysdate),
                   coduser   = global_v_coduser
             where codempid  = b_index_codempid
               and dtereq    = b_index_dtereq
               and numseq    = b_index_numseq
               and typchg    = b_index_typchg;
          commit;
          param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          commit;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
          rollback;
        end;
      end if;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_cancel_hres32e;
  --
  procedure ess_del_tab2_7(v_seqno in varchar2) is
    v_count 				number;

  begin
    delete temeslog2
     where codempid = b_index_codempid
       and dtereq   = b_index_dtereq
       and numseq   = b_index_numseq
       and numpage  = 27
       and seqno    = v_seqno;

    begin
      select count(*) into v_count
          from temeslog2
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numpage in (2,29);
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        delete tempch where codempid = b_index_codempid
                        and dtereq   = b_index_dtereq;
      end if;
    commit;
    param_msg_error := get_error_msg_php('HR2425',global_v_lang);
  end ess_del_tab2_7;
  --
  procedure ess_del_temeslog2(p_numpage varchar2,p_key in varchar2,p_field_key in varchar2,p_type_key varchar2 default 'N') is
    v_count 		number;
    v_upd           boolean := false;
    v_max_seq       number  := 0;
    v_code          varchar2(10 char);
  begin
    delete temeslog2
     where codempid = b_index_codempid
       and dtereq   = b_index_dtereq
       and numseq   = b_index_numseq
       and numpage  = p_numpage
       and fldkey   = p_field_key
       and seqno  = to_number(p_key)
--       and ((seqno  = to_number(p_key)) or (codseq  = p_key) or (to_char(dteseq,'dd/mm/yyyy')  = p_key))
       ;

    if p_numpage = '26' then
      begin
        select  'Y'
        into    v_code
        from    trelatives
        where   codempid      = b_index_codempid
        and     numseq        = to_number(p_key)
        and     rownum        = 1;
      exception when no_data_found then
        v_code  := null;
      end;
    elsif p_numpage = '29' then
      begin
        select  'Y'
        into    v_code
        from    tappldoc doc, temploy1 emp
        where   emp.codempid      = b_index_codempid
        and     emp.numappl       = doc.numappl
        and     doc.numseq        = to_number(p_key)
        and     rownum            = 1;
      exception when no_data_found then
        v_code  := null;
      end;
    elsif p_numpage = '31' then
      begin
        select  'Y'
        into    v_code
        from    teducatn edu, temploy1 emp
        where   emp.codempid      = b_index_codempid
        and     emp.numappl       = edu.numappl
        and     edu.numseq        = to_number(p_key)
        and     rownum            = 1;
      exception when no_data_found then
        v_code  := null;
      end;
    elsif p_numpage = '32' then
      begin
        select  'Y'
        into    v_code
        from    tapplwex wex, temploy1 emp
        where   emp.codempid      = b_index_codempid
        and     emp.numappl       = wex.numappl
        and     wex.numseq        = to_number(p_key)
        and     rownum            = 1;
      exception when no_data_found then
        v_code  := null;
      end;
    elsif p_numpage = '41' then
      begin
        select  'Y'
        into    v_code
        from    tchildrn chl
        where   chl.codempid      = b_index_codempid
        and     chl.numseq        = to_number(p_key)
        and     rownum            = 1;
      exception when no_data_found then
        v_code  := null;
      end;
    elsif p_numpage = '51' then
      begin
        select  'Y'
        into    v_code
        from    tcmptncy cmp, temploy1 emp
        where   emp.codempid      = b_index_codempid
        and     emp.numappl       = cmp.numappl
        and     cmp.codtency      = p_key
        and     rownum            = 1;
      exception when no_data_found then
        v_code  := null;
      end;
    elsif p_numpage = '52' then
      begin
        select  'Y'
        into    v_code
        from    tlangabi lng, temploy1 emp
        where   emp.codempid      = b_index_codempid
        and     emp.numappl       = lng.numappl
        and     lng.codlang       = p_key
        and     rownum            = 1;
      exception when no_data_found then
        v_code  := null;
      end;
    elsif p_numpage = '53' then
      begin
        select  'Y'
        into    v_code
        from    thisrewd rew, temploy1 emp
        where   rew.codempid      = b_index_codempid
        and     rew.dteinput      = tab_his_reward_dteinput
--        and     rew.dteinput      = to_date(tab_his_reward_dteinput,'dd/mm/yyyy')
        and     rownum            = 1;
      exception when no_data_found then
        v_code  := null;
      end;
    elsif p_numpage = '61' then
      begin
        select  'Y'
        into    v_code
        from    ttrainbf trn, temploy1 emp
        where   emp.codempid      = b_index_codempid
        and     emp.numappl       = trn.numappl
        and     trn.numseq        = to_number(p_key)
        and     rownum            = 1;
      exception when no_data_found then
        v_code  := null;
      end;
    end if;
    if v_code is not null then
      begin
        select nvl(max(seqno),0) + 1
          into v_max_seq
          from temeslog2
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numseq   = b_index_numseq
           and numpage  = p_numpage
           and fldkey   = p_field_key
           and ((seqno  = to_number(p_key)) or (codseq  = p_key) or (to_char(dteseq,'dd/mm/yyyy')  = p_key));
      end;
      if p_type_key = 'C' then
        upd_log2_del(b_index_numseq,p_numpage,v_max_seq,p_field_key,'C',p_field_key,p_key,null,'C','Delete','Delete',v_upd);
      elsif p_type_key = 'D' then
        upd_log2_del(b_index_numseq,p_numpage,v_max_seq,p_field_key,'D',p_field_key,null,p_key,'C','Delete','Delete',v_upd);
      else
        upd_log2_del(b_index_numseq,p_numpage,p_key,p_field_key,'N',p_field_key,null,null,'C','Delete','Delete',v_upd);
      end if;
    end if;

    begin
      select count(*) into v_count
          from temeslog2
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numpage  like substr(p_numpage,1,1)||'%';
      exception when no_data_found then
        v_count := 0;
      end;

    if v_count = 0 then
      delete tempch where codempid = b_index_codempid
                      and dtereq   = b_index_dtereq;
    end if;
    commit;
    param_msg_error := get_error_msg_php('HR2425',global_v_lang);
  end ess_del_temeslog2;
  --
  procedure ess_del_tab3(json_str in clob, resp_json_str out clob) is
    json_obj        json_object_t;
    v_del 		    boolean;
    chk   		    varchar2(1 char) := 'N' ;
    v_count 	    number;
  begin
    param_msg_error := null;
    initial_value(json_str);
    check_index;
    if param_msg_error is null then
      delete temeslog2 where codempid = b_index_codempid
                         and dtereq   = b_index_dtereq
                         and numseq   = b_index_numseq
                         and numpage  = 3;

      begin
        select count(*) into v_count
          from temeslog2
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numpage  = 3;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        delete tempch
         where codempid = b_index_codempid
         and   dtereq   = b_index_dtereq
         and   typchg   = 3;
      end if;
      commit;
      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
    else
      rollback;
      return;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_del_tab3;
  --
  procedure ess_del_tab4(json_str in clob, resp_json_str out clob) is
    json_obj        json_object_t;
    v_del 		    boolean;
    chk   		    varchar2(1 char) := 'N' ;
    v_count 	    number;
  begin
    param_msg_error := null;
    initial_value(json_str);

    check_index;
    if param_msg_error is null then
      delete temeslog2 where codempid = b_index_codempid
                         and dtereq   = b_index_dtereq
                         and numseq   = b_index_numseq;

      begin
        select count(*) into v_count
          from temeslog2
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numpage  = 4;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        delete tempch
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and typchg = 4;
      end if;
      commit;
      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
    else
      rollback;
      return;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end ess_del_tab4;
  --
  procedure ess_del_tab6(json_str in clob, resp_json_str out clob) is
    json_obj        json_object_t;
    v_del 		    boolean;
    chk   		    varchar2(1 char) := 'N' ;
    v_count 	    number;
  begin
    param_msg_error := null;
    initial_value(json_str);

    check_index;
    if param_msg_error is null then
      delete temeslog2 where codempid = b_index_codempid
                         and dtereq   = b_index_dtereq
                         and numseq   = b_index_numseq;

      begin
        select count(*) into v_count
          from temeslog2
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numpage  = 3;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        delete tempch
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and typchg = 6;
      end if;
      commit;
      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
    else
      rollback;
      return;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end ess_del_tab6;
  --
  function gen_numseq_tab27 return number is
    v_num       number:=0;
    v_numappl   varchar2(100 char);
    v_codcomp   varchar2(100 char);
  begin
    begin
      select numappl,codcomp
        into v_numappl,v_codcomp
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    if v_numappl is not null then
      begin
        select nvl(max(numseq),0) + 1  into v_num from(
          select numseq
            from tappldoc
           where numappl = v_numappl
        union
          select distinct(seqno)
            from temeslog2
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and numpage  = 29
             and seqno    not in (select numseq
                                    from tappldoc
                                   where numappl = v_numappl));
      end;
    end if;
    return v_num;
  end gen_numseq_tab27;

  function gen_numseq_tab3 return number is
    v_num       number:=0;
    v_numappl   varchar2(100 char);
    v_codcomp   varchar2(100 char);
  begin
    begin
      select numappl,codcomp
      into v_numappl,v_codcomp
      from   temploy1
      where  codempid = b_index_codempid	;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    if v_numappl is not null then
      begin
        select nvl(max(numseq),0) + 1 into v_num from(
          select numseq
            from teducatn
           where numappl = v_numappl
        union
          select distinct(seqno)
            from temeslog2
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and numpage  = 31
             and seqno    not in (select numseq
                                    from teducatn
                                   where numappl = v_numappl));
      end;
    end if;
    return v_num;
  end gen_numseq_tab3;

  function gen_numseq_tab4 return number is
    v_num       number:=0;
  begin
    select nvl(max(numseq),0) + 1 into v_num from(
          select numseq
            from tchildrn
       where codempid = b_index_codempid
        union
          select distinct(seqno)
            from temeslog2
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and numpage  = 41
             and seqno   not in (select numseq from tchildrn
                                              where codempid = b_index_codempid));
    return v_num;
  end gen_numseq_tab4;

  function gen_numseq_tab6 return number is
    v_num       number:=0;
    v_numappl   varchar2(100 char);
    v_codcomp   varchar2(100 char);
  begin
    begin
      select numappl,codcomp
        into v_numappl,v_codcomp
        from   temploy1
        where  codempid = b_index_codempid;
      exception when no_data_found then
        v_numappl  := null;
        v_codcomp  := null;
      end;

    if v_numappl is not null then
      begin
        select nvl(max(numseq),0) + 1 into v_num from(
            select numseq
              from ttrainbf
             where numappl = v_numappl
          union
            select distinct(seqno)
              from temeslog2
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and numpage  = 61
               and seqno   not in (select numseq
                                    from ttrainbf
                                    where numappl = v_numappl));
      end;
    end if;
    return v_num;
  end gen_numseq_tab6;
  --
  procedure gen_others_data(json_str_output out clob) is
    obj_row               json_object_t;
    obj_data              json_object_t;
    obj_row_codlist       json_object_t;
    obj_data_codlist      json_object_t;

    v_rowcnt              number;
    v_rowcnt_codlist      number;

    v_numappl             temploy1.numappl%type;
    v_value               varchar2(4000 char);
    v_value_n             varchar2(4000 char);
    v_codapp              tlistval.codapp%type;
    v_colist_flgused      tlistval.flgused%type;
    v_exists              varchar2(1 char) := 'N';
    v_flg_delete          varchar2(1 char) := 'N';

    cursor c1 is
      -- itemtype 1 = Text, 2 = Number, 3 = Date, 4 = Dropdown List
      select  tusr.column_id, toth.column_name, toth.itemtype,
              tusr.char_length, tusr.data_scale, (tusr.data_precision - tusr.data_scale) as data_precision,toth.codlist,
              desclabele,desclabelt,desclabel3,desclabel4,desclabel5,
              decode(global_v_lang,'101',desclabele
                                  ,'102',desclabelt
                                  ,'103',desclabel3
                                  ,'104',desclabel4
                                  ,'105',desclabel5) as  desclabel,
              toth.essstat
      from    user_tab_columns tusr, tempothd toth, user_col_comments cmm
      where   tusr.table_name         = 'TEMPOTHR'
      and     tusr.column_name        like 'USR_%'
      and     tusr.column_name        = toth.column_name
      and     tusr.table_name         = cmm.table_name(+)
      and     tusr.column_name        = cmm.column_name(+)
      and     toth.essstat            <> '1'
      order by tusr.column_id;

    cursor c_tlistval is
      select  codapp,numseq,list_value,
              get_tlistval_name(codapp,list_value,global_v_lang) as desc_value,
              max(decode(codlang,'101',desc_label)) as desc_valuee,
              max(decode(codlang,'102',desc_label)) as desc_valuet,
              max(decode(codlang,'103',desc_label)) as desc_value3,
              max(decode(codlang,'104',desc_label)) as desc_value4,
              max(decode(codlang,'105',desc_label)) as desc_value5
      from    tlistval
      where   codapp      = v_codapp
      and     list_value  is not null
      group by codapp,numseq,list_value
      order by numseq;
  begin
    obj_row       := json_object_t();
    v_rowcnt      := 0;
    begin
      select numappl
        into v_numappl
        from temploy1
       where codempid     = b_index_codempid;
    exception when no_data_found then
      v_numappl := null;
    end;

    begin
      select  'Y'
      into    v_exists
      from    tempothr
      where   numappl     = v_numappl;
    exception when no_data_found then
      v_exists  := 'N';
    end;

    for i in c1 loop
      obj_data          := json_object_t();
      obj_row_codlist   := json_object_t();
      v_value           := null;
      v_rowcnt          := v_rowcnt + 1;
      v_rowcnt_codlist  := 0;
      v_codapp          := i.codlist;

      if v_exists = 'Y' then
        begin
          if i.itemtype = '3' then
            execute immediate ' select to_char('||i.column_name||',''dd/mm/yyyy'') from tempothr where numappl = '''||v_numappl||''' ' INTO v_value;
          else
            execute immediate ' select '||i.column_name||' from tempothr where numappl = '''||v_numappl||''' ' INTO v_value;
          end if;
        exception when others then
          v_value   := '';
        end;
      else
        begin
          select  defaultval
          into    v_value
          from    tsetdeflh h, tsetdeflt d
          where   h.codapp            = 'HRPMC2E6'
          and     h.numpage           = 'HRPMC2E6'
          and     d.tablename         = 'TEMPOTHR'
          and     nvl(h.flgdisp,'Y')  = 'Y'
          and     h.codapp            = d.codapp
          and     h.numpage           = d.numpage
          and     d.fieldname         = i.column_name
          and     rownum  = 1;
        exception when no_data_found then
          v_value   := '';
        end;
      end if;

      begin
        select desold, desnew
          into v_value, v_value_n
          from temeslog1
         where codempid   = b_index_codempid
           and dtereq     = b_index_dtereq
           and numseq     = b_index_numseq
           and numpage    = 71
           and fldedit    = upper(i.column_name);
      exception when no_data_found then
        v_value_n := v_value;
      end;

      begin
        select  'Y'
        into    v_colist_flgused
        from    tlistval
        where   codapp            = i.codlist
        and     nvl(flgused,'N')  = 'Y'
        and     rownum            = 1;
      exception when no_data_found then
        v_colist_flgused    := 'N';
      end;

      obj_data.put('coderror','200');
      obj_data.put('column_id',i.column_id);
      obj_data.put('column_name',i.column_name);
      obj_data.put('column_value',v_value);
      obj_data.put('column_value_n',v_value_n);
      obj_data.put('itemtype',i.itemtype);
      obj_data.put('desc_itemtype',get_tlistval_name('ITEMTYPE',i.itemtype,global_v_lang));
      if i.itemtype in ('1','4') then
        obj_data.put('data_length',i.char_length);
      elsif i.itemtype = '2' and i.data_precision is not null and i.data_scale is not null then
        obj_data.put('data_length','('||i.data_precision||', '||i.data_scale||')');
      end if;
      obj_data.put('char_length',i.char_length);
      obj_data.put('data_scale',nvl(i.data_scale,'2'));
      obj_data.put('data_precision',nvl(i.data_precision,'22'));
      obj_data.put('codlist',i.codlist);
      for j in c_tlistval loop
        obj_data_codlist    := json_object_t();
        v_rowcnt_codlist    := v_rowcnt_codlist + 1;

        obj_data_codlist.put('value',j.list_value);
        obj_data_codlist.put('desc_value',j.desc_value);
        obj_data_codlist.put('desc_valuee',j.desc_valuee);
        obj_data_codlist.put('desc_valuet',j.desc_valuet);
        obj_data_codlist.put('desc_value3',j.desc_value3);
        obj_data_codlist.put('desc_value4',j.desc_value4);
        obj_data_codlist.put('desc_value5',j.desc_value5);
        obj_row_codlist.put(to_char(v_rowcnt_codlist - 1),obj_data_codlist);
      end loop;
      obj_data.put('codlist_data',obj_row_codlist);
      obj_data.put('codlist_flgused',v_colist_flgused);
      obj_data.put('desclabel',i.desclabel);
      obj_data.put('desclabele',i.desclabele);
      obj_data.put('desclabelt',i.desclabelt);
      obj_data.put('desclabel3',i.desclabel3);
      obj_data.put('desclabel4',i.desclabel4);
      obj_data.put('desclabel5',i.desclabel5);
      obj_data.put('flg_query','Y');
      obj_data.put('essstat',nvl(i.essstat,'3'));
      obj_data.put('desc_essstat',get_tlistval_name('ESSSTAT',nvl(i.essstat,'3'),global_v_lang));

      begin
        execute immediate ' select ''N'' from tempothr where '||i.column_name||' is not null and rownum = 1' INTO v_flg_delete;
      exception when others then
        v_flg_delete   := 'Y';
      end;
      obj_data.put('flg_delete',v_flg_delete);  --N-cannot Delete (disable icon Trash) ,Y-can Delete

      obj_row.put(to_char(v_rowcnt - 1), obj_data);
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  function get_others_data(json_str in clob) return clob is
    json_str_output   clob;
  begin
    initial_value(json_str);
    check_index;
    if param_msg_error is null then
      gen_others_data(json_str_output);
    end if;
    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_others_data(json_str_input clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_col_val       varchar2(4000 char);
    v_col_val_n     varchar2(4000 char);
    v_col_name      tempothd.column_name%type;

    v_upd  				  boolean := false;
    v_exist				  boolean := false;

    others_data_dtecancel date;
    --Cursor
  cursor c_temploy1 is
		select codtitle,namfirste,namfirstt,namfirst3,namfirst4,
		       namfirst5,namlaste,namlastt,namlast3,namlast4,
		       namlast5,nickname,nicknamt,nicknam3,nicknam4,nicknam5,rowid
		from	 temploy1
		where	 codempid = b_index_codempid;

	cursor c_tnamech is
		select rowid
		  from tempch
		 where codempid = b_index_codempid
		   and dtereq   = b_index_dtereq
		   and numseq   = b_index_numseq
		   and typchg   = 7;

  begin
    param_json    := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str'),'rows');
    for i in 0..param_json.get_size - 1 loop
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_col_val     := hcm_util.get_string_t(param_json_row,'column_value');
      v_col_val_n   := hcm_util.get_string_t(param_json_row,'column_value_n');
      v_col_name    := hcm_util.get_string_t(param_json_row,'column_name');
      if nvl(v_col_val,'$!#@') <> nvl(v_col_val_n,'$!#@') then
        upd_log1(b_index_numseq,'tempothreq','71',v_col_name,'C',v_col_val,v_col_val_n,'N',v_upd);
      end if;
    end loop;
    if v_upd then
      if nvl(others_data_staappr,'P') = 'C' then
         others_data_dtecancel  := sysdate;
      end if;

      for j in c_tnamech loop
        v_exist := true;

        update tempch
           set approvno  = others_data_approvno,
               staappr   = 'P',
               codappr   = others_data_codappr,
               remarkap  = others_data_remarkap,
               dteappr   = others_data_dteappr,
               routeno   = others_data_routeno,
               codinput  = global_v_codempid,
               dtecancel = tab1_dtecancel,
               coduser	 = global_v_coduser
         where rowid  = j.rowid;
      end loop;

      if not v_exist then
        insert into tempch ( codempid,dtereq,numseq,
                             typchg,dteinput,
                             codcomp,approvno,staappr,
                             codappr,remarkap,dteappr,
                             routeno,codinput,dtecancel,
                             coduser)
                    values ( b_index_codempid,b_index_dtereq,b_index_numseq,
                             7,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                             b_index_codcomp,others_data_approvno,'P',
                             others_data_codappr,others_data_remarkap,others_data_dteappr,
                             others_data_routeno,global_v_codempid,others_data_dtecancel,
                             global_v_coduser);
      end if;
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    else
      param_msg_error := get_error_msg_php('ES0078',global_v_lang);
    end if;
  end;
  --
  procedure ess_save_others_data(json_str_input in clob, json_str_output out clob) is
  begin
    clear_numseq;
    initial_value(json_str_input);
    check_index;
    insert_next_step(7,b_index_numseq);
    if param_msg_error is null then
      save_others_data(json_str_input);
      commit;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);--get_resp_json_str;
    rollback;
  end;
  --
end;

/

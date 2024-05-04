--------------------------------------------------------
--  DDL for Package Body ALERTMSG_AL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "ALERTMSG_AL" is

  procedure batchauto is
    cursor c_talalert is
  		select a.codcompy,a.mailalno,a.dteeffec
        from talalert a
       where a.dteeffec = (select max(dteeffec)
                             from talalert b
                            where b.mailalno = a.mailalno
                              and b.flgeffec = 'A'
                              and b.dteeffec <= trunc(sysdate))
    order by codcompy,mailalno;
  begin
  	for i in c_talalert loop
    	gen_typemail1(i.codcompy,i.mailalno,i.dteeffec,'Y');
    end loop;
  end;

  procedure gen_typemail1(p_codcompy varchar2 ,p_mailalno varchar2,p_dteeffec date,p_auto varchar2) is
    v_coduser      varchar2(30) := 'AUTO1';
    v_codapp       varchar2(30);
    v_cursor       number;
    v_dummy        integer;
    v_stmt         varchar2(2000);
    v_data_file    varchar2(2500);
    --
    v_check		   boolean;
    v_testsend     varchar2(10);
    v_codempid     varchar2(100);
    v_empname      varchar2(1000);
    v_codcomp      varchar2(100);
    v_compname     varchar2(1000);
    v_codpos       varchar2(100);
    v_posname      varchar2(1000);
    v_typpayroll   varchar2(100);

    v_dtestrt      date;
    v_dteend       date;
    v_period       varchar2(100);

    --
    v_codshift     varchar2(100);
    v_timstrtw     varchar2(100);
    v_timendw      varchar2(100);
    v_timin        varchar2(100);
    v_timout       varchar2(100);
    v_qtylate      varchar2(100);
    v_qtyearly     varchar2(100);
    v_qtyabsent    varchar2(100);
    v_qtytlate 	    number := 0;
    v_qtytearly     number := 0;
    v_qtytabs 		number := 0;
    v_time1        varchar2(100);
    v_time2        varchar2(100);
    v_late         varchar2(100);
    v_early        varchar2(100);
    v_absent       varchar2(100);
    v_abscont			 number;
    v_loop				 number;
    v_arrayno			 number;
    v_daycontS		 number;
    type a_text is table of varchar2(100) index by binary_integer;
    	a_dtework			a_text;

    type a_number is table of number index by binary_integer;
    	a_daycont			a_number;
    	a_daycontS		a_number;
    	a_qtyabsent		a_number;

    cursor c_talalert is
      select codcompy,mailalno,dteeffec,typemail,subject,message,syncond,flgeffec,flgperiod,dtestrt,dteend,qtydayr,dtelast,qtytlate,qtytearly,qtytabs,qtylate,qtyearly,qtyabsent,dteabsent,codsend
        from talalert
       where mailalno = p_mailalno
         and codcompy = p_codcompy
         and dteeffec = p_dteeffec;

    cursor c_talasign is
      select codcompy , mailalno,dteeffec,seqno,flgappr,codcompap,codposap,codempap,message
        from talasign
       where mailalno = p_mailalno
         and codcompy = p_codcompy
         and dteeffec = p_dteeffec
    order by seqno;

		cursor c_tattence is
			select a.dtework
			  from tattence a
			 where a.codempid = v_codempid
			   and a.dtework  between v_dtestrt and v_dteend
			   and a.typwork = 'W'
		order by dtework;

  begin
    for i in c_talalert loop
    	v_testsend := 'N';
    	if p_auto = 'N' then
        v_testsend := 'Y';
      else-- Auto
        if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
          v_testsend := 'Y';
        end if;
      end if;
      --
      if v_testsend = 'Y' then
--        v_codapp := i.mailalno||'_'||to_char(systimestamp,'ddmmyyyy_hh24missff3');
        v_codapp := i.mailalno||'_'||to_char(to_date(get_date_input(to_char(sysdate,'dd/mm/yyyy')),'dd/mm/yyyy'),'ddmmyyyy')||
                                     to_char(systimestamp,'_hh24missff3');
        --
        v_stmt := ' select codempid,codcomp,codpos,typpayroll '||
                  '   from temploy1 '||
                  '  where codempid in (select codempid '||
                                       '  from tlateabs '||
                                       ' where temploy1.codempid = tlateabs.codempid '||
                                       '   and dtework between (sysdate-90) and (sysdate+90))';
        v_stmt := v_stmt     || ' and codcomp like '''||p_codcompy||'%'' ';

        if i.syncond is not null then
          v_stmt := v_stmt||' and  (' ||i.syncond|| ') ';
        end if;
        --v_stmt := v_stmt||' and temploy1.codempid in (''53100'',''30019'',''52100'')';--afsdfsdfsfshffhbdfasfsflasdjfkkasd

        v_stmt := v_stmt||' order by codcomp,codempid';
        --
        v_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
        dbms_sql.define_column(v_cursor,1,v_codempid,100);
        dbms_sql.define_column(v_cursor,2,v_codcomp,100);
        dbms_sql.define_column(v_cursor,3,v_codpos,100);
        dbms_sql.define_column(v_cursor,4,v_typpayroll,100);


        v_dummy := dbms_sql.execute(v_cursor);
        while dbms_sql.fetch_rows(v_cursor) > 0 loop
          dbms_sql.column_value(v_cursor,1,v_codempid);
          dbms_sql.column_value(v_cursor,2,v_codcomp);
          dbms_sql.column_value(v_cursor,3,v_codpos);
          dbms_sql.column_value(v_cursor,4,v_typpayroll);
          --
          v_dtestrt := null; v_dteend := null;
          if i.flgperiod = 'M' then
          	v_dtestrt := to_date('01/'||to_char(sysdate,'mm/yyyy'),'dd/mm/yyyy');
          	v_dteend  := last_day(v_dtestrt);
          elsif i.flgperiod = 'D' then
          	begin
		          v_dtestrt   := to_date(lpad(i.dtestrt,2,'0')||to_char(sysdate,'mmyyyy'),'ddmmyyyy');
		        exception when others then
			       	begin
			       		v_dtestrt := to_date('30'||to_char(sysdate,'mmyyyy'),'ddmmyyyy');
			       	exception when others then
				       	begin
				       		v_dtestrt := to_date('29'||to_char(sysdate,'mmyyyy'),'ddmmyyyy');
				       	exception when others then
				       		v_dtestrt := to_date('28'||to_char(sysdate,'mmyyyy'),'ddmmyyyy');
				       	end;
        			end;
		        end;
	        	if v_dtestrt > trunc(sysdate) then
	        		v_dtestrt := add_months(v_dtestrt, - 1);
	        	end if;
						--
         		begin
		          if i.dtestrt > i.dteend then
		          	v_dteend   := to_date(lpad(i.dteend,2,'0')||to_char(add_months(v_dtestrt,1),'mmyyyy'),'ddmmyyyy');
		          else
		          	v_dteend   := to_date(lpad(i.dteend,2,'0')||to_char(v_dtestrt,'mmyyyy'),'ddmmyyyy');
		          end if;
		        exception when others then
		        	begin
			          if i.dtestrt > i.dteend then
			          	v_dteend   := to_date('30'||to_char(add_months(v_dtestrt,1),'mmyyyy'),'ddmmyyyy');
			          else
			          	v_dteend   := to_date('30'||to_char(v_dtestrt,'mmyyyy'),'ddmmyyyy');
			          end if;
			       	exception when others then
				       	begin
				          if i.dtestrt > i.dteend then
				          	v_dteend   := to_date('29'||to_char(add_months(v_dtestrt,1),'mmyyyy'),'ddmmyyyy');
				          else
				          	v_dteend   := to_date('29'||to_char(v_dtestrt,'mmyyyy'),'ddmmyyyy');
				          end if;
				       	exception when others then
				          if i.dtestrt > i.dteend then
				          	v_dteend   := to_date('28'||to_char(add_months(v_dtestrt,1),'mmyyyy'),'ddmmyyyy');
				          else
				          	v_dteend   := to_date('28'||to_char(v_dtestrt,'mmyyyy'),'ddmmyyyy');
				          end if;
				       	end;
        			end;
		        end;
          elsif i.flgperiod = 'P' then
						begin
							select dtestrt,dteend
							  into v_dtestrt,v_dteend
							  from tpriodal
							 where codcompy   = hcm_util.get_codcomp_level(v_codcomp,'1')
							   and typpayroll = v_typpayroll
							   and sysdate    between dtestrt and dteend
							   and rownum     = 1
							   and codpay     = (select codabs
							                      from tcontal2
							                     where codcompy = hcm_util.get_codcomp_level(v_codcomp,'1')
							                       and dteeffec = (select max(dteeffec)
							                                         from tcontal2
							                                        where codcompy = hcm_util.get_codcomp_level(v_codcomp,'1')
							                                          and dteeffec <= sysdate));
						exception when others then null;
						end;
          end if;
          v_compname := get_tcenter_name(v_codcomp,p_lang);
          v_empname  := get_temploy_name(v_codempid,p_lang);
          v_posname  := get_tpostn_name(v_codpos,p_lang);
          v_period	 := get_date_input(to_char(v_dtestrt,'dd/mm/yyyy'))||' - '||
                        get_date_input(to_char(v_dteend,'dd/mm/yyyy'));
					--
          v_check    := false;
          if i.typemail = '1' then
                v_qtylate  := null; v_qtyearly  := null; v_qtyabsent := null;
                v_qtytlate := null; v_qtytearly := null; v_qtytabs   := null;
                begin
                    select nvl(sum(qtylate),0),nvl(sum(qtyearly),0),nvl(sum(qtyabsent),0),
                                 nvl(sum(qtytlate),0),nvl(sum(qtytearly),0),nvl(sum(qtytabs),0)
                      into v_qtylate,v_qtyearly,v_qtyabsent,
                                 v_qtytlate,v_qtytearly,v_qtytabs
                      from tlateabs
                     where codempid = v_codempid
                       and dtework  between v_dtestrt and v_dteend;
                exception when no_data_found then null;
                end;
    
                if v_qtylate > i.qtylate or v_qtyearly > i.qtyearly or v_qtyabsent > i.qtyabsent or
                     v_qtytlate > i.qtytlate or v_qtytearly > i.qtytearly or v_qtytabs > i.qtytabs then
                    v_check := true;
                end if;
	          if v_check then
		          if nvl(v_qtylate,0) > 0 then
		            cal_hm_concat(v_qtylate,v_late);
		          else
		            v_late := null;
		          end if;

		          if nvl(v_qtyearly,0) > 0 then
		            cal_hm_concat(v_qtyearly,v_early);
		          else
		            v_early := null;
		          end if;

		          if nvl(v_qtyabsent,0) > 0 then
		            cal_hm_concat(v_qtyabsent,v_absent);
		          else
		            v_absent := null;
		          end if;

		          if v_qtytlate  = 0 then v_qtytlate  := null; end if;
		          if v_qtytearly = 0 then v_qtytearly := null; end if;
		          if v_qtytabs   = 0 then v_qtytabs   := null; end if;
	          	insert_ttemprpt(v_coduser||'1',v_codapp,v_period,v_codempid,v_codcomp,v_codpos,
	          	                                        v_empname,v_compname,v_posname,
	          	                                        v_qtytlate,v_late,
	          	                                        v_qtytearly,v_early,
	          	                                        v_qtytabs,v_absent,null,null);
	          end if;--v_check
          elsif i.typemail = '2' then
            v_arrayno := 0;
            v_abscont := 0;
            v_loop    := (v_dteend - v_dtestrt) + 1;
            for a in 1..v_loop loop
                a_dtework(a )  := null;
                a_daycont(a) 	 := 0;
                a_daycontS(a)  := 0;
                a_qtyabsent(a) := 0;
            end loop;
          	for r_tattence in c_tattence loop
                v_arrayno := v_arrayno + 1;
                begin
                    select qtyabsent into v_qtyabsent
                      from tlateabs
                     where codempid  = v_codempid
                       and dtework   = r_tattence.dtework
                       and qtyabsent > 0;
                    v_abscont := v_abscont + 1;
                exception when no_data_found then
                    v_abscont := 0;
                end;
                a_dtework(v_arrayno)   := to_char(r_tattence.dtework,'dd/mm/yyyy');
                a_daycont(v_arrayno)   := v_abscont;
                a_qtyabsent(v_arrayno) := v_qtyabsent;
            end loop;--c_tattence
            --for a in reverse 1..v_arrayno  loop
            v_daycontS := 0;
            for a in reverse 1..v_arrayno  loop
                if a_daycont(a) >= v_daycontS then
                    v_daycontS := a_daycont(a);
                elsif a_daycont(a) = 0 then
                    v_daycontS := 0;
                end if;
                if a_daycont(a) <> 0 then
                    a_daycontS(a) := v_daycontS;
                end if;
            end loop;--reverse 1..v_arrayno
            --
            v_daycontS := null;
            for a in 1..v_arrayno  loop
                if a_daycontS(a) >= i.dteabsent then
                    if nvl(a_qtyabsent(a),0) > 0 then
                        cal_hm_concat(a_qtyabsent(a),v_absent);
			        else
                        v_absent := null;
                    end if;
                    if v_daycontS = a_daycontS(a) then
                        insert_ttemprpt(v_coduser||'1',v_codapp,v_period,v_codempid,v_codcomp,v_codpos,
                                          v_empname,v_compname,v_posname,
                                          null,null,
                                          null,null,null,null,get_date_input(a_dtework(a)),v_absent);
                    else
                        insert_ttemprpt(v_coduser||'1',v_codapp,v_period,v_codempid,v_codcomp,v_codpos,
                                          v_empname,v_compname,v_posname,
                                          null,null,
                                          v_codempid,v_empname,v_compname,v_posname,get_date_input(a_dtework(a)),v_absent);
					end if;
                    v_daycontS := a_daycontS(a);
                else
                    v_daycontS := null;
                end if;--v_abscont >= i.dteabsent
			end loop;--1..v_arrayno
          end if;--i.typemail = '1'
        end loop;
        dbms_sql.close_cursor(v_cursor);
        --
      	for j in c_talasign loop
       		gen_recipient(j.codcompy,j.mailalno,j.dteeffec,j.seqno,j.flgappr,j.codempap,j.codcompap,j.codposap,v_coduser,v_codapp);
        	gen_email(j.codcompy,j.mailalno,j.dteeffec,v_coduser,v_codapp);
        	delete ttemprpt where codempid = v_coduser||'2' and codapp = v_codapp;
        end loop;-- talasign
        --
        delete ttemprpt where codempid like v_coduser||'%' and codapp = v_codapp;
        delete ttempprm where codempid like v_coduser||'%' and codapp = v_codapp;
        --
        if p_auto = 'Y' then
          update talalert
             set dtelast = trunc(sysdate)
           where mailalno = i.mailalno
             and codcompy = i.codcompy
             and dteeffec = i.dteeffec;
        end if;
        commit;
      end if;--v_testsend = 'Y'
    end loop;-- c_talertabs
  exception when others then null;
    dbms_sql.close_cursor(v_cursor);
  end;
  --
  procedure gen_recipient(p_codcompy varchar2 , p_mailalno varchar2,p_dteeffec date,p_seqno number,p_flgappr varchar2,p_codempap varchar2,p_codcompap varchar2, p_codposap varchar2, p_coduser varchar2, p_codapp varchar2) is
    v_codempid     varchar2(30);
    v_codcomp      varchar2(40);
    v_codpos       varchar2(30);
    v_codempidh    varchar2(30);
    v_codcomph     varchar2(40);
    v_codposh      varchar2(30);
    v_flag         varchar2(30);
    v_emphead      varchar2(30);

    cursor c_ttemprpt is
      select item1 as period,item2 as codempid,item3 as codcomp,item4 as codpos
        from ttemprpt
       where codempid = p_coduser||'1'
         and codapp   = p_codapp
    group by item1,item2,item3,item4
    order by item2;

    cursor c_head1 is
    select replace(codempidh,'%',null) codempidh,
           replace(codcomph,'%',null) codcomph,
           replace(codposh,'%',null) codposh
        from temphead
       where codempid = v_codempid
    order by numseq;

    cursor c_head2 is
    select replace(codempidh,'%',null) codempidh,
           replace(codcomph,'%',null) codcomph,
           replace(codposh,'%',null) codposh
        from temphead
       where codcomp = v_codcomp
		     and codpos  = v_codpos
    order by numseq;

    cursor c_emp is
      select codempid,email
        from temploy1
       where codempid  = nvl(v_codempidh,codempid)
         and codcomp   = nvl(v_codcomph,codcomp)
         and codpos    = nvl(v_codposh,codpos)
         and staemp in ('1','3')
      union
      select a.codempid,b.email
        from tsecpos a,temploy1 b
       where a.codempid  = b.codempid
         and a.codempid  = nvl(v_codempidh,a.codempid)
         and a.codcomp   = nvl(v_codcomph,a.codcomp)
         and a.codpos    = nvl(v_codposh,a.codpos)
         and a.dteeffec <= sysdate
         and(nvl(a.dtecancel,a.dteend) >= trunc(sysdate) or nvl(a.dtecancel,a.dteend) is null);
  begin
    --p_flgappr : 1 = head, 3 = comp + pos, 4 = emp, 5 = owner
    for i in c_ttemprpt loop
      v_codempid := i.codempid;
      v_codcomp  := i.codcomp;
      v_codpos   := i.codpos;
    	if p_flgappr = '1' then--head
	      v_flag     := 'N';
	      for r_head1 in c_head1 loop
	        v_flag     := 'Y';
	        v_codempidh := r_head1.codempidh;
	        v_codcomph  := r_head1.codcomph;
	        v_codposh   := r_head1.codposh;
	        for r_emp in c_emp loop
	          if r_emp.email is not null then
	            insert_ttemprpt(p_coduser||'2',p_codapp,v_codempid,r_emp.codempid,r_emp.email,i.period,p_seqno,p_flgappr,null,null,null,null,null,null,null,null,null);
	          end if;
	        end loop;--c_emp
	      end loop;--c_head1
	      --
	      if v_flag = 'N' then
	        for r_head2 in c_head2 loop
	          v_codempidh := r_head2.codempidh;
	          v_codcomph  := r_head2.codcomph;
	          v_codposh   := r_head2.codposh;
	          for r_emp in c_emp loop
	            if r_emp.email is not null then
	              insert_ttemprpt(p_coduser||'2',p_codapp,v_codempid,r_emp.codempid,r_emp.email,i.period,p_seqno,p_flgappr,null,null,null,null,null,null,null,null,null);
	            end if;
	          end loop;--c_emp
	        end loop;--c_head1
	      end if;
    	elsif p_flgappr = '3' then--comp + pos
        v_codempidh := p_codempap;
        v_codcomph  := p_codcompap;
        v_codposh   := p_codposap;

        for r_emp in c_emp loop
          if r_emp.email is not null then
            insert_ttemprpt(p_coduser||'2',p_codapp,v_codempid,r_emp.codempid,r_emp.email,i.period,p_seqno,p_flgappr,null,null,null,null,null,null,null,null,null);
          else
            return;
          end if;
        end loop;--c_emp
    	elsif p_flgappr = '4' then--emp
        v_codempidh := p_codempap;
        v_codcomph  := p_codcompap;
        v_codposh   := p_codposap;
        for r_emp in c_emp loop
          if r_emp.email is not null then
            insert_ttemprpt(p_coduser||'2',p_codapp,v_codempid,r_emp.codempid,r_emp.email,i.period,p_seqno,p_flgappr,null,null,null,null,null,null,null,null,null);
          end if;
        end loop;--c_emp
    	elsif p_flgappr = '5' then--owner
        v_codempidh := i.codempid;
        v_codcomph  := i.codcomp;
        v_codposh   := i.codpos;
        for r_emp in c_emp loop
          if r_emp.email is not null then
            insert_ttemprpt(p_coduser||'2',p_codapp,v_codempid,r_emp.codempid,r_emp.email,i.period,p_seqno,p_flgappr,null,null,null,null,null,null,null,null,null);
          end if;
        end loop;--c_emp
    	end if;--p_flgappr = '1'
    end loop;--c_ttemprpt
  end;--gen_recipient
  --
  procedure gen_email(p_codcompy varchar2,p_mailalno varchar2,p_dteeffec date,p_coduser varchar2, p_codapp in varchar2) is
    v_codempid     varchar2(30);
    v_item         varchar2(250);
    v_label        varchar2(250);
    v_error        clob;
    v_tempfile     varchar2(250);
    v_subject      varchar2(250 char);
    v_template     clob;
    v_headmag      long;
    v_message      clob;
    v_msg          clob;
    v_emphead      varchar2(250) := '!@#$';
    v_email        varchar2(250);
    v_period       varchar2(250);
    v_seq          number;
    crlf           varchar2(2):= chr( 13 ) || chr( 10 );
    v_typemail                  varchar2(2);
    v_numseq1                   number;
    v_numseq2                   number;
    v_seqno                     number;
    v_msg_assign                varchar2(4000 char);
    v_file_attch1               varchar2(4000 char);
    v_file_attch2               varchar2(4000 char);
    v_file_attch3               varchar2(4000 char);
    v_file_attch4               varchar2(4000 char);
    v_file_attch1_path          varchar2(4000 char);
    v_file_attch2_path          varchar2(4000 char);
    v_file_attch3_path          varchar2(4000 char);
    v_file_attch4_path          varchar2(4000 char);
    v_host_attach_file          varchar2(200 char);
    v_path_attach_file          varchar2(200 char);
    v_excel_file_name           varchar2(200 char);

    type a_varchar is table of varchar2(200) index by binary_integer;
			a_label   a_varchar;

    cursor c_tapplscr is
      select desclabelt
        from tapplscr
       where codapp = 'HRALATEC99'
         and numseq between v_numseq1 and v_numseq2
    order by numseq;

   cursor c_ttemprpt is
      select item2 as emphead,item3 as email,item4 as period,to_number(item5) as seqno
        from ttemprpt
       where codempid = p_coduser||'2'
         and codapp   = p_codapp
    group by item2,item3,item4,item5
    order by item2,item3,item4,item5;

   cursor c_ttemprpt2 is
      select item1
        from ttemprpt
       where codempid = p_coduser||'2'
         and codapp   = p_codapp
         and item2    = v_emphead
         and item3    = v_email
         and item4    = v_period
         and item5    = v_seqno;

    cursor c_ttemprpt3 is
      select item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15
        from ttemprpt
       where codempid = p_coduser||'1'
         and codapp   = p_codapp
         and item2    = v_codempid
    order by numseq;

  begin
    begin
      select subject,message,typemail,fileattch1,fileattch2,fileattch3,fileattch4
        into v_subject,v_msg,v_typemail,v_file_attch1,v_file_attch2,v_file_attch3,v_file_attch4
        from talalert
       where mailalno = p_mailalno
         and codcompy = p_codcompy
         and dteeffec = p_dteeffec;
    exception when no_data_found then null;
    end;
	  --
    begin
      select decode(p_lang,'101',messagee,'102',messaget,'103',message3,'104',message4,'105',message5,'101',messagee) msg
        into v_template
        from tfrmmail
       where codform = 'TEMPLATEAL';
    exception when others then v_template := null ;
    end ;
    if v_typemail = '1' then
    	v_numseq1 := 101;
    	v_numseq2 := 110;
		elsif v_typemail = '2' then
    	v_numseq1 := 201;
    	v_numseq2 := 206;
    end if;
    --
    for a in 1..10 loop
      a_label(a) := null;
    end loop;
    v_seq := 0;
    for i in c_tapplscr loop
      v_seq := v_seq + 1;
      a_label(v_seq) := i.desclabelt;
    end loop;--c_tapplscr
    delete ttempprm where codempid = p_coduser||'3' and codapp = p_codapp;
    insert into ttempprm(codempid,codapp,namrep,pdate,ppage,label1,label2,label3,label4,label5,label6,label7,label8,label9,label10)
                  values(p_coduser||'3',p_codapp,'subject','Date/Time','Page No :',a_label(1),a_label(2),a_label(3),a_label(4),a_label(5),a_label(6),a_label(7),a_label(8),a_label(9),a_label(10));
    commit;
    --
    if v_typemail = '1' then
	    v_item  := 'item2,item5,item6,item7,item8,item9,item10,item11,item12,item13';
	    v_label := 'label1,label2,label3,label4,label5,label6,label7,label8,label9,label10';
		elsif v_typemail = '2' then
	    v_item  := 'item10,item11,item12,item13,item14,item15';
	    v_label := 'label1,label2,label3,label4,label5,label6';
    end if;
    --
    for r1 in c_ttemprpt loop
      v_file_attch1_path := null;
      v_file_attch2_path := null;
      v_file_attch3_path := null;
      v_file_attch4_path := null;
      delete ttemprpt where codempid = p_coduser||'3' and codapp = p_codapp;
      if v_emphead <> r1.emphead then
        v_seq := 1;
      else
        v_seq := v_seq + 1;
      end if;
      v_emphead := r1.emphead;
      v_email   := r1.email;
      v_period  := r1.period;
      v_seqno   := r1.seqno;
	    begin
	      select message into v_msg_assign
	        from talasign
	       where mailalno = p_mailalno
             and codcompy = p_codcompy
	         and dteeffec = p_dteeffec
	         and seqno	  = r1.seqno;
	    exception when no_data_found then v_msg_assign := null;
	    end;
      for r2 in c_ttemprpt2 loop
        v_codempid := r2.item1;
        for r3 in c_ttemprpt3 loop
          insert_ttemprpt(p_coduser||'3',p_codapp,r3.item1,r3.item2,r3.item3,r3.item4,r3.item5,r3.item6,r3.item7,r3.item8,r3.item9,r3.item10,r3.item11,r3.item12,r3.item13,r3.item14,r3.item15);
        end loop;--c_ttemprpt3
      end loop;--c_ttemprpt2
      v_excel_file_name := r1.emphead||'_'||lpad(v_seq,3,'0')||'_auto';
      excel_mail(v_item,v_label,null,p_coduser||'3',p_codapp,v_excel_file_name);
      --
      v_message   := replace(v_template,'[P_MESSAGE]', replace(replace(v_msg,chr(10),'<br>'),' ','&nbsp;'));
      v_message   := replace(v_message,'[P_OTHERMSG]', v_msg_assign);
      v_message   := replace(v_message,'[PARA_FROM]', null);
      v_message   := replace(v_message,'<PARAM1>', r1.emphead||' '||get_temploy_name(r1.emphead,p_lang));
      v_message   := replace(v_message,'<PARAM2>', v_subject);
      v_message   := replace(v_message,'([PARA_POSITION])', null);
      v_message   := replace(v_message,'[PARA_POSITION]', null);
      v_message   := replace(v_message,'<param-01>', r1.period);
      v_message   := replace(v_message,'{param-01}', r1.period);
      v_message   := replace(v_message,'[param-01]', r1.period);
      v_message   := replace(v_message,'&lt;param-01&gt;', r1.period);
      v_message   := replace(v_message,'&nbsp;', ' ');
      v_tempfile  := get_tsetup_value('PATHEXCEL')||p_codapp||'_'||r1.emphead||'_'||lpad(v_seq,3,'0')||'_auto'||'.xls';

      -- Internal Meeting 08/03/2562 Skip Send Mail Attach File
--      begin
--        select folder
--          into v_path_attach_file
--          from tfolderd
--         where upper(codapp) like 'HRALATE';
--      exception when no_data_found then
--        v_path_attach_file := null;
--      end;
--      v_host_attach_file := get_tsetup_value('BACKEND_URL') || get_tsetup_value('PATHWORKPHP');
--      if v_path_attach_file is not null then
--        v_host_attach_file := v_host_attach_file || v_path_attach_file || '/';
--      end if;
--      if v_file_attch1 is not null then
--        v_file_attch1_path   := v_host_attach_file||v_file_attch1;
--      end if;
      
      -- if v_file_attch2 is not null then
      --   v_file_attch2_path   := v_host_attach_file||v_file_attch2;
      -- end if;
      -- if v_file_attch3 is not null then
      --   v_file_attch3_path   := v_host_attach_file||v_file_attch3;
      -- end if;
      -- if v_file_attch4 is not null then
      --   v_file_attch4_path   := v_host_attach_file||v_file_attch4;
      -- end if;
      v_error  := SendMail_AttachFile(get_tsetup_value('MAILEMAIL'),r1.email,v_subject,v_message,v_tempfile,v_file_attch1_path,v_file_attch2_path,v_file_attch3_path,v_file_attch4_path,null,null,'Oracle');
    end loop;--c_ttemprpt
    null;
  end;--gen_email
  --
  procedure insert_ttemprpt(p_codempid in varchar2,p_codapp in varchar2,p_item1 in varchar2,p_item2 in varchar2,p_item3 in varchar2,p_item4 in varchar2,p_item5 in varchar2,p_item6 in varchar2,p_item7 in varchar2,p_item8 in varchar2,p_item9 in varchar2,p_item10 in varchar2,p_item11 in varchar2,p_item12 in varchar2,p_item13 in varchar2,p_item14 in varchar2,p_item15 in varchar2) is
    v_numseq number := 0;
  begin
    begin
      select nvl(max(numseq),0) into v_numseq
        from ttemprpt
       where codempid = p_codempid
         and codapp   = p_codapp;
    end;
    v_numseq := v_numseq + 1;
		--
		insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15)
		              values(p_codempid,p_codapp,v_numseq,p_item1,p_item2,p_item3,p_item4,p_item5,p_item6,p_item7,p_item8,p_item9,p_item10,p_item11,p_item12,p_item13,p_item14,p_item15);
		commit;
	end;--insert_ttemprpt
  --
  procedure cal_hm_concat(p_qtymin number, p_hm out varchar2) is
    v_min 	number(2);
    v_hour  number;
  begin
    if p_qtymin is not null and p_qtymin > 0 then
      v_hour := trunc(p_qtymin / 60,0);
      v_min	 := mod(p_qtymin,60);
      p_hm   := to_char(v_hour,'fm999,999,990')||':'||lpad(to_char(v_min),2,'0');
    else
      p_hm := '0'||':'||'00';
    end if;
  end;--cal_hm_concat
end ALERTMSG_AL;

/

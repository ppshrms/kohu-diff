--------------------------------------------------------
--  DDL for Package Body HRPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM" is

/*
	Project : KOH
	Modify Date : 05/09/2018
	By : User37/Dispashara
	Error no : KOH-610642
	Error desc : ???????????????? ??????????????????????????????? ???????????????????????????????????
               ?????????????????????????????????????????????
*/

procedure hrpmate is
begin
  alertmail.run_alert;
  gen_birthday(null,'Y',null,null);
  gen_probation(null,'Y',null,null);
  gen_probationn(null,'Y',null,null,null);
  gen_probationp(null,'Y',null,null,null);
  gen_ttmovemt(null,'Y',null,null);
  gen_prbcodpos(null,'Y',null,null);
  gen_resign(null,'Y',null,null);
  gen_retire(null,'Y',null,null);
  gen_public_holiday(null,'Y',null,null); --<<:user32 :05/03/2018 :STA4610019
  gen_newemp(null,'Y',null,null);
end;

procedure gen_birthday (p_codcompy  in varchar2,
                        flg_log     in varchar2,
                        p_mailalno  in varchar2,
                        p_dteeffec  in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_where           clob;
  v_data_file       varchar2(2500);
  v_codempid        varchar2(10);
  v_count           number;
  v_stdate          varchar2(20);
  v_endate          varchar2(20);
  type descol is table of varchar2(2500) index by binary_integer;
  data_file         descol;
  v_typesend        varchar2(1) := 'N';
  v_testsend        varchar2(1) := 'N';
  v_dteempdb        date;

  cursor c_tpmalert is
    select mailalno,dteeffec,syncond,codsend,typemail,
           message,qtydayb,
           qtydayr,dtelast
      from tpmalert
     where codcompy = p_codcompy
       and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '10'
  order by mailalno;

begin

  for i in c_tpmalert loop
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;

    if v_testsend = 'Y' then
      v_cursor  := dbms_sql.open_cursor;
      if i.syncond is not null then
        v_where  := 'where codcomp like '''|| p_codcompy ||'%'' and  (' ||i.syncond||')';
      else
        v_where  := 'where codcomp like '''|| p_codcompy ||'%''  ';
      end if;
      if i.qtydayb is not null then -- Before
         v_stdate := to_char(sysdate,'dd/mm/yyyy');
         v_endate := to_char(sysdate + i.qtydayb,'dd/mm/yyyy');
         v_where  := v_where ||' and  staemp in (''1'',''3'') and add_months(dteempdb,trunc(  round(months_between(sysdate,dteempdb) /12) *12)) between to_date('''||v_stdate||''',''dd/mm/yyyy'') and  to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      v_stment := 'select codempid from temploy1 ' ||v_where|| ' order by codempid';
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..1 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;

      v_dummy := dbms_sql.execute(v_cursor);

      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..1 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        v_count    := 0;
        begin
          select dteempdb into v_dteempdb
          from   temploy1
          where  codempid = v_codempid;
        exception when others then
          v_dteempdb := null;
        end;

        begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and codcompy = p_codcompy
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid||to_char(sysdate,'yy')||to_char(v_dteempdb,'mm');
        exception when no_data_found then
          v_count := 0;
        end;
        if flg_log = 'N' then
           v_count := 0;
        end if;
        if v_count = 0 then
           sendmail_alert(p_codcompy, v_codempid,i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,null,v_typesend);
           if flg_log = 'Y' then
              insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid||to_char(sysdate,'yy')||to_char(v_dteempdb,'mm'),null,null,null,null,null,null,null);
           end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor);
    end if;
  end loop;
end; -- gen_birthday
--
procedure gen_probation  (p_codcompy  in varchar2,
                          flg_log     in varchar2,
                          p_mailalno  in varchar2,
                          p_dteeffec  in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';

  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             clob;
  v_label           varchar2(4000 char) := '';
  v_item            varchar2(4000 char) := '';
  v_desc            varchar2(4000 char) := '';
  v_comma           varchar2(1);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(1000 char);
  v_receiver        temploy1.codempid%type;
  v_codapman        tproasgn.codempap%type;
  v_codposap        tproasgn.codposap%type;
  v_codcompap       tproasgn.codcompap%type;
  v_codcomp         tcenter.codcomp%type;
  v_codpos          tpostn.codpos%type;
  v_codcompemp      tcenter.codcomp%type;
  v_codposemp       tpostn.codpos%type;
  v_seqno           tpmasign.seqno%type;
  v_typproba        varchar2(1 char);

  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;

  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           qtydayr,dtelast
      from tpmalert
     where codcompy = p_codcompy
       and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '20'
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver,seqno;

  cursor c_sendmail is
    select item1 codempid, item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
       and item5 = v_seqno
  order by codempid;
  
  cursor c_asign is
    select codcomp,codpos,codempid
	  from tproasgh
	 where v_codcomp   like codcomp||'%'
	   and v_codpos    like codpos
	   and v_codempid  like codempid
       and typproba = v_typproba
  order by codempid desc,codcomp desc;

  cursor c_tproasgn is
    select numseq,flgappr,codcompap,codposap,codempap
	  from tproasgn
	 where codcomp   = v_codcompemp
	   and codpos    = v_codposemp
	   and codempid  = v_codempid2
       and typproba = v_typproba
  order by numseq  ;

begin
  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno            := i.mailalno;
      v_dteeffec            := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      for i in c_tmailrpm loop
        v_count := v_count + 1;
      end loop;
      if v_count > 0 then
        v_typesend := 'A';
      else
        v_typesend := 'H';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;
      v_cursor := dbms_sql.open_cursor;

      v_where  := ' where codcomp like '''|| p_codcompy ||'%'' and staemp in (''1'') ';
      if i.qtydayb is not null then -- Before
         v_stdate := to_char(sysdate,'dd/mm/yyyy');
         v_endate := to_char(trunc((sysdate) + i.qtydayb),'dd/mm/yyyy');
         v_where  := v_where || ' and  dteduepr between to_date('''||v_stdate||''',''dd/mm/yyyy'') and  to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        v_where  := v_where||' and  (' ||i.syncond|| ') ';
      end if;

      V_STMENT := 'select codempid from temploy1  ' ||V_WHERE|| ' and codempid not in (select codempid from ttprobat where ttprobat.codempid = temploy1.codempid and ttprobat.dteduepr = temploy1.dteduepr) order by codempid';
      commit;

      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..1 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;
      v_dummy := dbms_sql.execute(v_cursor);
      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;

        for j in 1..1 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;

        v_codempid := data_file(1);
        v_count    := 0;

        begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and codcompy = p_codcompy
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid;
        exception when no_data_found then
          v_count := 0;
        end;
        if flg_log = 'N' then
           v_count := 0;
        end if;
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit; 

        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '6' then
                        v_typproba := '1';
                        begin
                            select codcomp,codpos
                              into v_codcomp,v_codpos
                              from temploy1
                             where codempid = v_codempid;
                        exception when no_data_found then null;
                        end;
                        
                        for j in c_asign loop
                            v_codcompemp   := j.codcomp;
                            v_codposemp    := j.codpos;
                            v_codempid2    := j.codempid;
                            exit;
                        end loop; --c_asign
                        for j in c_tproasgn loop
                            if j.flgappr = '1' then
                                find_approve_name(v_codempid,i.seqno,'1',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            elsif j.flgappr = '2' then
                                find_approve_name(v_codempid,i.seqno,'3',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            elsif j.flgappr = '3' then
                                find_approve_name(v_codempid,i.seqno,'4',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            end if;
                        end loop;
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,null,null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
--              hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,'codempid = '''||v_codempid||'''',v_seq,i.typemail);
            end if;
          else 
            sendmail_alert(p_codcompy,v_codempid,i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,null,v_typesend);
          end if;
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,null,null,null,null,null,null,null);
          end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert
           set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;

      if v_typesend = 'A' then
        if v_seq > 0 then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' codempid = '''||i.codempid||''' ',v_numseq,20);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
        end if;
      end if;
    end if;
  end loop;
end; --end gen_probation
--
procedure gen_probationn( p_codcompy  in varchar2,
                          flg_log     in varchar2,
                          p_mailalno  in varchar2,
                          p_dteeffec  in date,
                          p_typemail  in varchar2) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';

  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             clob;
  v_label           varchar2(4000 char) := '';
  v_item            varchar2(4000 char) := '';
  v_desc            varchar2(4000 char) := '';
  v_comma           varchar2(1);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(1000 char);
  v_receiver        temploy1.codempid%type;
  v_codapman        tproasgn.codempap%type;
  v_codposap        tproasgn.codposap%type;
  v_codcompap       tproasgn.codcompap%type;
  v_codcomp         tcenter.codcomp%type;
  v_codpos          tpostn.codpos%type;
  v_codcompemp      tcenter.codcomp%type;
  v_codposemp       tpostn.codpos%type;
  v_seqno           tpmasign.seqno%type;
  v_typproba        varchar2(1 char);

  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;
    arr_codobf   descol;

  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           qtydayr,dtelast
      from tpmalert
     where codcompy = p_codcompy
       and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
            or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = 22
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver,seqno;

  cursor c_sendmail is
    select item1 codempid, item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
       and item5 = v_seqno
  order by codempid;
  
  cursor c_asign is
    select codcomp,codpos,codempid
	  from tproasgh
	 where v_codcomp   like codcomp||'%'
	   and v_codpos    like codpos
	   and v_codempid  like codempid
       and typproba = v_typproba
  order by codempid desc,codcomp desc;

  cursor c_tproasgn is
    select numseq,flgappr,codcompap,codposap,codempap
	  from tproasgn
	 where codcomp   = v_codcompemp
	   and codpos    = v_codposemp
	   and codempid  = v_codempid2
       and typproba = v_typproba
  order by numseq  ;

begin

  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno  := i.mailalno;
      v_dteeffec  := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = para_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      for i in c_tmailrpm loop
        v_count := v_count + 1;
      end loop;
      if v_count > 0 then
        v_typesend := 'A';
      else
        v_typesend := 'H';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;
      v_cursor := dbms_sql.open_cursor;

      v_where   := ' where temploy1.codcomp like '''|| p_codcompy ||'%''
                       and temploy1.staemp in (''1'')
                       and temploy1.codempid  = ttprobatd.codempid
                       ';

      if i.qtydayb is not null then -- Before
         v_endate := to_char(trunc((sysdate) + i.qtydayb),'dd/mm/yyyy');
--         v_where  := v_where||' and ttprobatd.dtedueprn = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        v_where  := v_where||' and  (' ||i.syncond|| ') ';
      end if;

      V_STMENT := 'select temploy1.codempid
                   from temploy1, ttprobatd  ' ||
                   v_where|| '
                   order by codempid ';
      commit;
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..1 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;
      
      v_dummy := dbms_sql.execute(v_cursor);
      
      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..1 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        V_COUNT    := 0;
        begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and codcompy = p_codcompy
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid;
        exception when no_data_found then
          v_count := 0;
        end;
        if flg_log = 'N' then
           v_count := 0;
        end if;
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit;  
        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '6' then
                        v_typproba := '1';
                        begin
                            select codcomp,codpos
                              into v_codcomp,v_codpos
                              from temploy1
                             where codempid = v_codempid;
                        exception when no_data_found then null;
                        end;
                        
                        for j in c_asign loop
                            v_codcompemp   := j.codcomp;
                            v_codposemp    := j.codpos;
                            v_codempid2    := j.codempid;
                            exit;
                        end loop; --c_asign
                        for j in c_tproasgn loop
                            if j.flgappr = '1' then
                                find_approve_name(v_codempid,i.seqno,'1',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            elsif j.flgappr = '2' then
                                find_approve_name(v_codempid,i.seqno,'3',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            elsif j.flgappr = '3' then
                                find_approve_name(v_codempid,i.seqno,'4',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            end if;
                        end loop;
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,null,null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
--              hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,'v_temploy.codempid = '''||v_codempid||'''',v_seq,i.typemail);
            end if;
          else
            sendmail_alert(p_codcompy,v_codempid,i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,null,v_typesend);
          end if;
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,null,null,null,null,null,null,null);
          end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert
           set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;
      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' codempid = '''||i.codempid||''' ',v_numseq,22);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
    end if;
  end loop;
end; -- end gen_probationn
--
procedure gen_probationp( p_codcompy  in varchar2,
                          flg_log     in varchar2,
                          p_mailalno  in varchar2,
                          p_dteeffec  in date,
                          p_typemail  in varchar2) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';

  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             clob;
  v_label           varchar2(4000 char) := '';
  v_item            varchar2(4000 char) := '';
  v_desc            varchar2(4000 char) := '';
  v_comma           varchar2(1);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(1000 char);
  v_receiver        temploy1.codempid%type;
  v_codapman        tproasgn.codempap%type;
  v_codposap        tproasgn.codposap%type;
  v_codcompap       tproasgn.codcompap%type;
  v_codcomp         tcenter.codcomp%type;
  v_codpos          tpostn.codpos%type;
  v_codcompemp      tcenter.codcomp%type;
  v_codposemp       tpostn.codpos%type;
  v_seqno           tpmasign.seqno%type;
  v_typproba        varchar2(1 char);

  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;

  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           qtydayr,dtelast
      from tpmalert
     where codcompy = p_codcompy
       and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
            or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '24'
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver,seqno;

  cursor c_sendmail is
    select item1 codempid, item2 dteduepr,
           item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
       and item5 = v_seqno
  order by codempid;

begin

  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno  := i.mailalno;
      v_dteeffec  := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      for i in c_tmailrpm loop
        v_count := v_count + 1;
      end loop;
      if v_count > 0 then
        v_typesend := 'A';
      else
        v_typesend := 'H';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;
      v_cursor := dbms_sql.open_cursor;

      v_where   := ' where temploy1.codcomp like '''|| p_codcompy ||'%''
                       and ttprobat.typproba  = ''1''
                       and temploy1.codempid  = ttprobat.codempid
                       and ttprobat.codrespr  = ''P''
                       ';

      if i.qtydayb is not null then -- Before
         v_endate := to_char(trunc((sysdate) + i.qtydayb),'dd/mm/yyyy');
         v_where  := v_where||' and ttprobat.dteefpos = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        v_where  := v_where||' and  (' ||i.syncond|| ') ';
      end if;

      V_STMENT := 'select temploy1.codempid,to_char(ttprobat.dteduepr,''dd/mm/yyyy'') dteduepr
                   from temploy1, ttprobat  ' ||
                   v_where|| '
                   order by codempid ';
      commit;
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..2 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;
      v_dummy := dbms_sql.execute(v_cursor);
      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..2 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        V_COUNT    := 0;
        begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and codcompy = p_codcompy
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid
             and fieldd1  = to_date(data_file(2),'dd/mm/yyyy');
        exception when no_data_found then
          v_count := 0;
        end;
        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,data_file(2),null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
--              hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,'ttprobat.codempid = '''||v_codempid||''' and dteduepr = to_date('''||data_file(2)||''',''dd/mm/yyyy'')',v_seq,i.typemail);
            end if;
          else
            sendmail_alert(p_codcompy,v_codempid,i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,null,v_typesend);
          end if;
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,null,null,null,null,to_date(data_file(2),'dd/mm/yyyy'),null,null);
          end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert
           set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;
      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' ttprobat.codempid = '''||i.codempid||''' and ttprobat.dteduepr = to_date('''||i.dteduepr||''',''dd/mm/yyyy'') ',v_numseq,24);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
    end if;
  end loop;
end; -- end gen_probationp
--
procedure gen_file (p_codcompy in varchar2,
                    p_mailalno in varchar2,
                    p_dteeffec in date,
                    p_where    in varchar2,
                    p_seq      in number,
                    p_typemail in varchar2) is

  v_cursor       number;
  v_dummy        number;
  v_stment       varchar2(4000 char);
  v_where        varchar2(4000 char);
  v_data_file    varchar2(4000 char);
  v_codempid     temploy1.codempid%type;
  v_count        number := 0;

  type descol is table of varchar2(2500) index by binary_integer;
  data_file      descol;
  v_statment     varchar2(7000 char) := ' ';
  v_comma        varchar2(1 char) := '';
  v_funcdesc     varchar2(2000 char);
  v_pfield       varchar2(2000 char);

 cursor c1 is
    select *
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = p_mailalno
       and dteeffec = p_dteeffec
  order by numseq;

begin
  for i in 1..20 loop
    data_file(i) := null;
  end loop;
  for i in c1 loop
    if i.flgdesc = 'Y' then
      begin
        select funcdesc into v_funcdesc
          from tcoldesc
         where codtable = substr(i.pfield,1,instr(i.pfield,'.')-1)
           and codcolmn = substr(i.pfield,instr(i.pfield,'.')+1);
      exception when no_data_found then
        v_funcdesc := substr(i.pfield,instr(i.pfield,'.')+1);
      end;

      v_pfield := nvl(v_funcdesc,substr(i.pfield,instr(i.pfield,'.')+1));
      v_pfield := replace(v_pfield,'P_CODE',i.pfield);
      v_pfield := replace(v_pfield,'P_LANG',''''||p_lang||'''');
    else
      v_pfield := i.pfield;
    end if;

    v_statment := v_statment||v_comma||v_pfield;
    v_comma    := ',';
    v_count    := v_count +1;
  end loop;

  if v_statment is not null then
    v_cursor := dbms_sql.open_cursor;

    if p_typemail in ('20','22','70','80','90','100','110','120','130') then
      v_stment := 'select '||v_statment||' from v_temploy where '||p_where;
    elsif p_typemail in ('24','44') then
      v_stment := 'select '||v_statment||' from ttprobat where '||p_where;
    elsif p_typemail = '60' then
      v_stment := 'select '||v_statment||' from ttexempt,v_temploy where ttexempt.codempid = v_temploy.codempid and ' ||p_where;
    else
      v_stment := 'select '||v_statment||' from ttmovemt,v_temploy where ttmovemt.codempid = v_temploy.codempid and ' ||p_where;
    end if;
    dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);
    for j in 1..v_count loop
      dbms_sql.define_column(v_cursor,j,v_data_file,1000);
    end loop;

    v_dummy := dbms_sql.execute(v_cursor);

    loop
      if dbms_sql.fetch_rows(v_cursor) = 0 then
        exit;
      end if;
      for j in 1..v_count loop
        dbms_sql.column_value(v_cursor,j,v_data_file);
        data_file(j) := v_data_file;
      end loop;
      insert into ttemprpt (codempid,codapp,numseq,
                            item1,item2,item3,item4,item5,
                            item6,item7,item8,item9,item10,
                            item11,item12,item13,item14,item15,
                            item16,item17,item18,item19,item20)
                    values('AUTO',p_codapp_file,p_seq,
                           data_file(1),data_file(2),data_file(3),data_file(4),data_file(5),
                           data_file(6),data_file(7),data_file(8),data_file(9),data_file(10),
                           data_file(11),data_file(12),data_file(13),data_file(14),data_file(15),
                           data_file(16),data_file(17),data_file(18),data_file(19),data_file(20));
    end loop;
    dbms_sql.close_cursor(v_cursor);
  end if;
end; -- gen_file

procedure gen_ttmovemt (p_codcompy  in varchar2,
                        flg_log     in varchar2,
                        p_mailalno  in varchar2,
                        p_dteeffec  in date) is

  v_cursor       number;
  v_dummy        integer;
  v_stment       varchar2(2000);
  v_statment     varchar2(2000);
  v_where        varchar2(2000);
  v_data_file    varchar2(2500);
  v_codempid     varchar2(10);
  v_count        number;

  v_mailalno     varchar2(30);
  v_dteeffec     date;
  v_stdate       varchar2(30);
  v_endate       varchar2(30);
  v_typesend     varchar2(1);
  v_testsend     varchar2(1) := 'N';

  v_codobf       varchar2(4);
  v_numobfn      number;
  v_amtwidrwn    number;
  v_qtywidrwn    number;
  v_numobfo      number;
  v_amtwidrwo    number;
  v_qtywidrwo    number;

  r_codobf       long;
  r_numobfn      long;
  r_amtwidrwn    long;
  r_qtywidrwn    long;
  r_numobfo      long;
  r_amtwidrwo    long;
  r_qtywidrwo    long;
  v_mail_message long;

  v_seq          number := 0;
  v_numseq       number := 0;
  v_sql          varchar2(2500);
  v_label        varchar2(2500):= '';
  v_item         varchar2(2500):= '';
  v_desc         varchar2(2500):= '';
  v_comma        varchar2(1);
  v_datachg      varchar2(1) := 'N';
  v_arr          number := 0;
  v_codsend      temploy1.codempid%type;
  v_filename     varchar2(1000 char);

  type descol is table of varchar2(2500) index by binary_integer;
    data_file     descol;
    arr_codobf    descol;

  type desnum is table of number index by binary_integer;
    arr_numobfn       desnum;
    arr_amtwidrwn     desnum;
    arr_qtywidrwn     desnum;
    arr_numobfo       desnum;
    arr_amtwidrwo     desnum;
    arr_qtywidrwo     desnum;

  cursor c_tpmalert is
    select mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,--qtydaya,
           dtelast,qtydayr
     from tpmalert
    where codcompy = p_codcompy
      and
      --<<user36 STA3590309 01/09/2016
          (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
           or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
      and typemail = '30'
    /*((dteeffec = p_dteeffec) or (p_dteeffec is null and dteeffec <= trunc(sysdate)))
      and typemail = '3'
      and flgeffec = 'A'*/
      -->>user36 STA3590309 01/09/2016
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tobfcde is
    select *
      from tobfcde
     where dteend > trunc(sysdate)
        or dteend  is null
  order by codobf;

begin
  for i in 1..50 loop
    arr_codobf(i)        := null;
    arr_numobfn(i)       := null;
    arr_amtwidrwn(i)     := null;
    arr_qtywidrwn(i)     := null;
    arr_numobfo(i)       := null;
    arr_amtwidrwo(i)     := null;
    arr_qtywidrwo(i)     := null;
  end loop;
  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno  := i.mailalno;
      v_dteeffec  := i.dteeffec;
      para_codapp := i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      delete ttemprpt where codempid = 'AUTO' and codapp = para_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = para_codapp;
      commit;
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      begin
        select count(*) into v_count
          from tpmasign
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec
           and flgappr  = '5'
           and rownum   = 1;
      exception when no_data_found then
        null;
      end;
      if v_count = 0 then
        v_typesend := 'A';
      else
        v_typesend := 'N';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
           v_numseq   := v_numseq +1;
           v_statment := v_statment||v_comma||j.pfield;
           v_label    := v_label||v_comma||'label'||v_numseq;
           v_item     := v_item||v_comma||'item'||v_numseq;
           v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
           v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||para_codapp||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;

      v_cursor := dbms_sql.open_cursor;
      if i.qtydayb is not null then -- Before
         v_endate := to_char((sysdate + i.qtydayb),'dd/mm/yyyy');
--         v_stdate := to_char(sysdate,'dd/mm/yyyy');
--         v_where  := 'where  b.staemp in (''1'',''3'')and  a.dteeffec between to_date('''||v_stdate||''',''dd/mm/yyyy'') and  to_date('''||v_endate||''',''dd/mm/yyyy'') ';
         v_where  := 'where  temploy1.staemp in (''1'',''3'') and  ttmovemt.dteeffec = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;
--      if i.qtydaya is not null then -- After
--         v_stdate := to_char((sysdate - i.qtydaya),'dd/mm/yyyy');
--         v_endate := to_char(sysdate,'dd/mm/yyyy');
--         v_where  := 'where  b.staemp in (''1'',''3'')and  a.dteeffec between to_date('''||v_stdate||''',''dd/mm/yyyy'') and  to_date('''||v_endate||''',''dd/mm/yyyy'') ';
--      end if;

      if i.syncond is not null then
        if v_where is not null then
           v_where  := v_where||' and  ' ||i.syncond|| ' ';
        else
           v_where  := ' where temploy1.staemp in (''1'',''3'') and ' ||i.syncond|| ' ';
        end if;
      else
        if v_where is null then
          v_where  := ' where temploy1.staemp in (''1'',''3'') ';
        end if;
      end if;

      v_stment := 'select ttmovemt.codempid,ttmovemt.dteeffec,ttmovemt.numseq '||
                  'from ttmovemt ,temploy1 ' ||v_where|| ' '||
                  ' and ttmovemt.staupd   in (''U'',''C'') '||
                  ' and ttmovemt.codempid = temploy1.codempid '||
                  ' and temploy1.codcomp like '''|| p_codcompy ||'%'' '||
                  'order by ttmovemt.codempid,ttmovemt.dteeffec,ttmovemt.numseq';
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..3 loop
          dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;

      v_dummy := dbms_sql.execute(v_cursor);

      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..3 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        v_count    := 0;
        begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and codcompy = p_codcompy
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid
             and fieldd1  = data_file(2)
             and fieldc2  = data_file(3);
        exception when no_data_found then
          v_count := 0;
        end;
        if v_count = 0 then
          v_arr := 0;
          for k in c_tobfcde loop
            v_datachg   := 'N';
            v_numobfn   := null;
            v_amtwidrwn := null;
            v_qtywidrwn := null;
            v_numobfo   := null;
            v_amtwidrwo := null;
            v_qtywidrwo := null;

            check_ttmovemt( v_codempid,data_file(2),data_file(3),
                            k.codobf,v_datachg,v_numobfn,
                            v_amtwidrwn,v_qtywidrwn,v_numobfo,
                            v_amtwidrwo,v_qtywidrwo);

            if v_datachg = 'Y' then
              v_arr := v_arr + 1;
              arr_codobf(v_arr)        := k.codobf;
              arr_numobfn(v_arr)       := v_numobfn;
              arr_amtwidrwn(v_arr)     := v_amtwidrwn;
              arr_qtywidrwn(v_arr)     := v_qtywidrwn;
              arr_numobfo(v_arr)       := v_numobfo;
              arr_amtwidrwo(v_arr)     := v_amtwidrwo;
              arr_qtywidrwo(v_arr)     := v_qtywidrwo;
            end if;
          end loop;

          if v_arr > 0 then
            v_seq := v_seq + 1;
            if v_typesend = 'A' then
              if v_numseq > 0 then
                hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,' ttmovemt.codempid = '''||v_codempid||''' and ttmovemt.dteeffec = '''||data_file(2)||''' and ttmovemt.numseq = '''||data_file(3)||''' ',v_seq,i.typemail);
              end if;
            else
              v_mail_message := null;
              for n in 1..v_arr loop
                v_mail_message := v_mail_message||'<tr class=TextBody>
                <td width=100 align=center>'||arr_codobf(n)||'</td>
                <td width=110 align=center>'||to_char(to_number(arr_amtwidrwn(n)),'9,999,999,990.00')||'</td>
                <td width=110 align=center>'||to_char(to_number(arr_qtywidrwn(n)),'99')||'</td>
                <td width=110 align=center>'||to_char(to_number(arr_amtwidrwo(n)),'9,999,999,990.00')||'</td>
                <td width=110 align=center>'||to_char(to_number(arr_qtywidrwo(n)),'99')||'</td></tr>';
              end loop;
              v_mail_message := ' <tr class=TextBody>
                                  <td align=center><b>'||get_label_name('HRPMATEC2',p_lang,310)||'</b></td>
                                  <td align=center><b>'||get_label_name('HRPMATEC2',p_lang,320)||'</b></td>
                                  <td align=center><b>'||get_label_name('HRPMATEC2',p_lang,330)||'</b></td>
                                  <td align=center><b>'||get_label_name('HRPMATEC2',p_lang,340)||'</b></td>
                                  <td align=center><b>'||get_label_name('HRPMATEC2',p_lang,350)||'</b></td>
                                  </tr>'||v_mail_message;
              sendmail_ttmovemt(  v_codempid,data_file(2),data_file(3),
                                  p_codcompy,i.mailalno,i.dteeffec,i.codsend,
                                  i.typemail,i.message,v_mail_message,
                                  null,v_typesend);
            end if;
            if flg_log = 'Y' then
              insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,data_file(3),null,null,null,data_file(2),null,null);
            end if;
          end if;
        end if;--v_count
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;

      if v_typesend = 'A' then
        if v_seq > 0 then
          v_filename := to_char(sysdate,'yyyymmddhh24mi'); --user36 STA3590309 05/09/2016
          if v_numseq > 0 then
            excel_mail(v_item,v_label,null,'AUTO',para_codapp,v_filename); --user36 STA3590309 05/09/2016 excel_mail(v_item,v_label,null,'AUTO',v_codapp,'auto');
          end if;
          sendmail_ttmovemt(v_codsend,data_file(2),data_file(3),
                            p_codcompy,i.mailalno,i.dteeffec,i.codsend,
                            i.typemail,i.message,null,
                            v_filename,v_typesend); --user36 STA3590309 05/09/2016 v_codapp||'_auto'||'.xls',v_typesend);
        end if;
      end if;
    end if;
  end loop;
end; --gen_ttmovemt

procedure sendmail_ttmovemt(p_codempid  in varchar2,
                            p_dteeffect in date,
                            p_numseq    in number,
                            p_codcompy  in varchar2,
                            p_mailalno  in varchar2,
                            p_dteeffec  in date,
                            p_codsend   in varchar2,
                            p_typemail  in varchar2,
                            p_message   in clob,
                            p_mail_message    in clob,
                            p_filname   in varchar2,
                            p_typesend  in varchar2) is

  v_msg_to        clob := p_message;
  v_template_to   clob;
  v_mailtemplt    varchar2(15) := get_tsetup_value('MAILTEMPLT');
  v_codform       varchar2(15);
begin
  if v_mailtemplt = 'Y' then
    v_codform := 'TEMPLATE';
  else
    v_codform := 'TEMPLATE';
  end if;

  begin
    select decode(p_lang,'101',messagee,
                         '102',messaget,
                         '103',message3,
                         '104',message4,
                         '105',message5,
                         '101',messagee) msg
    into  v_template_to
    from  tfrmmail
    where codform = v_codform;
  exception when others then
    v_template_to := null;
  end;
  replace_text_ttmovemt(v_msg_to,v_template_to,p_codempid,
                        p_dteeffect,p_numseq,p_codsend,
                        p_codcompy, p_mailalno,p_dteeffec,p_typemail,
                        p_mail_message,p_typesend);
                        
  auto_execute_mail(p_codcompy,p_mailalno,p_dteeffec,p_codempid,v_msg_to,p_typemail,p_filname,p_typesend);

end;--sendmail_ttmovemt_to

procedure replace_text_ttmovemt (p_msg       in out clob,
                                 p_template  in clob,
                                 p_codempid  in varchar2,
                                 p_dteeffect in date,
                                 p_numseq    in number,
                                 p_codsend   in varchar2,
                                 p_codcompy  in varchar2,
                                 p_mailalno  in varchar2,
                                 p_dteeffec  in date,
                                 p_typemail  in varchar2,
                                 p_mail_message    in clob,
                                 p_typesend  in varchar2) is

  data_file     clob;
  crlf          varchar2( 2 ):= chr( 13 ) || chr( 10 );
  v_message     clob;
  v_template    clob;
  v_codpos      varchar2(4);
  v_cursor       number;
  v_dummy        integer;
  v_stment       varchar2(2000);
  v_where        varchar2(2000);
  v_data_file    varchar2(2500);
  v_codempid     varchar2(10);
  v_funcdesc     varchar2(100);
  v_msg          long;
  v_data_msg     long;
  v_headmag      long := null;
  v_replace      clob;
  v_mailtemplt   varchar2(15) := get_tsetup_value('MAILTEMPLT');

  type descol is table of varchar2(2500) index by binary_integer;
    data_files   descol;

  cursor c_tpmparam is
    select mailalno,numseq,codtable,fparam,ffield,descript,flgdesc
      from tpmparam
     where codcompy = p_codcompy
       and mailalno = p_mailalno
       and dteeffec = p_dteeffec
  order by fparam;

begin
  begin
    select codpos into v_codpos
      from temploy1
     where codempid = p_codsend;
  exception when no_data_found then
    v_codpos := null;
  end;

  v_template  := p_template;
  v_message   := p_msg;
  if v_mailtemplt = 'Y' then
    v_message   := replace(v_template,'[P_MESSAGE]', replace(replace(v_message,chr(10),'<br>'),' ',';'));
  else
    v_message   := replace(v_template,'[P_MESSAGE]',v_message);
    v_message   := replace(v_message,chr(10),'<br>');
  end if;
  data_file   := v_message;

  --user36 STA3590309 09/09/2016
  /*if p_typesend = 'N' then
     v_headmag := 'From: ' ||get_tsetup_value('MAILEMAIL')||  crlf ||
                  'To: <P_EMAIL>'||crlf||
                  'Subject: '||get_tlistval_name('TYPMAILPM',p_typemail,p_lang)||crlf||
                  'Content-Type: text/html'||crlf;
  else
     v_headmag := null;
  end if;*/

  if p_typesend = 'N' then
    if data_file is not null then
      for i in c_tpmparam loop
        v_funcdesc := null;
        v_cursor   := dbms_sql.open_cursor;
        if i.codtable = 'V_TEMPLOY' then
          v_stment := 'select ' ||i.ffield|| ' from ' ||i.codtable|| ' where codempid = '''||p_codempid||''' ';
        elsif i.codtable = 'TTMOVEMT' then
          v_stment := 'select ' ||i.ffield|| ' from ' ||i.codtable|| ' '||
                      ' where codempid = '''||p_codempid||''' '||
                      '   and dteeffec = '''||p_dteeffect||''' '||
                      '   and numseq   = '''||p_numseq||''' ';
        end if;

        dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

        for j in 1..1 loop
          dbms_sql.define_column(v_cursor,j,v_data_file,500);
        end loop;

        v_dummy := dbms_sql.execute(v_cursor);

        loop
          if dbms_sql.fetch_rows(v_cursor) = 0 then
            exit;
          end if;
          for j in 1..1 loop
            dbms_sql.column_value(v_cursor,j,v_data_file);
            data_files(j) := v_data_file;
          end loop;
          if i.flgdesc = 'Y' then
            begin
              select funcdesc into v_funcdesc
                from tcoldesc
               where codtable = i.codtable
                 and codcolmn = i.ffield;
            exception when no_data_found then
              v_funcdesc := null;
            end;
            v_msg := v_funcdesc;
            v_msg := replace(v_msg,'P_CODE',''''||data_files(1)||'''');
            v_msg := replace(v_msg,'P_LANG',p_lang);
            v_msg := 'select '||v_msg||' from dual ';
            v_data_msg := execute_desc(v_msg);

            data_file  := replace(data_file ,i.fparam,v_data_msg);
          else
            data_file  := replace(data_file ,i.fparam,data_files(1));
          end if;
        end loop;
        dbms_sql.close_cursor(v_cursor);
        if data_file like ('%[p_data]%') then
          v_replace := p_mail_message;
          data_file := replace(data_file ,'[p_data]','<table>'||v_replace||'</table>');
        end if;
      end loop;
    end if;
  end if;

  if data_file like ('%[PARA_FROM]%') then
    data_file  := replace(data_file  ,'[PARA_FROM]', get_temploy_name(p_codsend,p_lang));
  end if;
  if data_file like ('%[PARA_POSITION]%') then
    data_file  := replace(data_file  ,'[PARA_POSITION]',get_tpostn_name(v_codpos,p_lang));
  end if;

  p_msg := v_headmag||data_file;

end; -- Function replace_text_ttmovemt

procedure check_ttmovemt (p_codempid  in varchar2,
                          p_dteeffect in date,
                          p_numseq    in number,
                          p_codobf    in varchar2,
                          p_datachg   in out varchar2,
                          p_numobfn   in out number,
                          p_amtwidrwn in out number,
                          p_qtywidrwn in out number,
                          p_numobfo   in out number,
                          p_amtwidrwo in out number,
                          p_qtywidrwo in out number) is

  v_codempid         varchar2(10);
  v_codcomp          tcenter.codcomp%type;
  v_qtywkday         date;
  v_typemp           varchar2(4);
  v_codempmt         varchar2(4);
  v_numlvl           number(4);
  v_codpos           varchar2(4);
  v_staemp           varchar2(1);
  v_codcompt         tcenter.codcomp%type;
  v_codposnow        varchar2(4);
  v_typempt          varchar2(4);
  v_codempmtt        varchar2(4);
  v_numlvlt          number(4);
  v_amtincom         varchar2(20);
  v_amtincom1        varchar2(20);
  v_flgadjin         varchar2(1);
  v_syncond          varchar(1000);
  v_year             number(3);
  v_month            number(5);
  v_day              number(6);
  v_dteeffex         date;
  v_st               varchar2(1000);
  v_check            boolean;
  v_codobf           varchar2(10);
  v_count            number;
  v_numobfn          number;
  v_amtwidrwn        number;
  v_qtywidrwn        number;
  v_numobfo          number;
  v_amtwidrwo        number;
  v_qtywidrwo        number;
  v_pass             varchar2(1) := 'N';
  v_codcompbf        tobfcfp.codcomp%type;

  cursor c_tobfcdet is
      select * --numobf,codobf,syncond,amtwidrw,qtywidrw
       from tobfcdet
      where codobf  = v_codobf
  order by numobf;

  cursor c_tchildrn is
      select dtechbd,codedlv
       from tchildrn
      where codempid = p_codempid
  order by numseq;

begin
  begin
    select codcomp,codpos,typemp,codempmt,numlvl,
           codcompt,codposnow,typempt,codempmtt,numlvlt,amtincom1,flgadjin
      into v_codcomp,v_codpos,v_typemp,v_codempmt,v_numlvl,
           v_codcompt,v_codposnow,v_typempt,v_codempmtt,v_numlvlt,v_amtincom,v_flgadjin
      from ttmovemt
     where codempid = p_codempid
       and dteeffec = p_dteeffect
       and numseq   = p_numseq;
  exception when no_data_found then
    null;
  end;

  begin
    select amtincom1 into v_amtincom1
      from temploy3
     where codempid = p_codempid;
  exception when no_data_found then
    null;
  end;

  begin
    select dteempmt,dteeffex,staemp into v_qtywkday,v_dteeffex,v_staemp
      from temploy1
     where codempid = p_codempid;
  exception when no_data_found then
    null;
  end;

  get_service_year(v_qtywkday,nvl(v_dteeffex,sysdate),'A',v_year,v_month,v_day);
  v_month     := v_month +(v_year*12);
  v_amtincom  := stddec(v_amtincom,p_codempid,v_chken);
  v_amtincom1 := stddec(v_amtincom1,p_codempid,v_chken);

  if v_codcomp  <> v_codcompt  or
    v_codpos   <> v_codposnow or
    v_typemp   <> v_typempt   or
    v_codempmt <> v_codempmtt or
    v_numlvl   <> v_numlvlt   or
    v_flgadjin = 'Y' then

    v_codobf    := p_codobf;
    v_check     := false;
    v_numobfn   := null;
    v_amtwidrwn := null;
    v_qtywidrwn := null;
    v_numobfo   := null;
    v_amtwidrwo := null;
    v_qtywidrwo := null;

    begin
      select count(*) into v_count
        from tobfcft t1, tobfcftd t2
       where t1.codempid = p_codempid
         and t2.codobf   = v_codobf
         and t1.codempid = t2.codempid
         and t1.dtestart = t2.dtestart;
    exception when no_data_found then
      v_count := 0;
    end;
    /*User37 : Dispashara 05/01/2014 14:18 Add check condition tobfcfp when not have tobfcft*/
    if v_count = 0 then
      begin
        select codcomp
          into v_codcompbf
          from (select codcomp
                  from tobfcfp
                 where v_codcomp like codcomp||'%'
--                   and codpos = v_codpos
                order by codcomp desc)
        where rownum = 1;
      exception when no_data_found then
        v_codcompbf := null;
      end;
      begin
        select count(t1.codcomp)
          into v_count
          from tobfcfp t1,tobfcfpd t2
         where t1.codcomp = t2.codcomp
           and t1.dtestart = t2.dtestart
           and t1.numseq = t2.numseq
--           and codpos = v_codpos
           and t1.codcomp = v_codcompbf
           and t2.codobf   = v_codobf;
      exception when no_data_found then
        v_count := 0;
      end;
    end if;

    if v_count = 0 then
      for i in c_tobfcdet loop
        v_syncond := i.syncond;
        if v_syncond like '%CODEDLV%' or v_syncond like '%AGECHILD%' then
          for j in c_tchildrn loop
            v_syncond := replace(v_syncond,'V_HRBF41.CODEMPID',''''||p_codempid||'''');
            v_syncond := replace(v_syncond,'V_HRBF41.CODCOMP',''''||v_codcompt||'''');
            v_syncond := replace(v_syncond,'V_HRBF41.QTYWKDAY',v_month);
            v_syncond := replace(v_syncond,'V_HRBF41.TYPEMP',''''||v_typempt||'''');
            v_syncond := replace(v_syncond,'V_HRBF41.CODEMPMT',''''||v_codempmtt||'''');
            v_syncond := replace(v_syncond,'V_HRBF41.NUMLVL',v_numlvlt);
            v_syncond := replace(v_syncond,'V_HRBF41.CODPOS',''''||v_codposnow||'''');
            v_syncond := replace(v_syncond,'V_HRBF41.STAEMP',''''||v_staemp||'''');
            v_syncond := replace(v_syncond,'V_HRBF41.AMTINCOM1',v_amtincom);
            v_syncond := replace(v_syncond,'V_HRBF41.DTEEMPMT','to_date('''||to_char(v_qtywkday,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
            v_syncond := replace(v_syncond,'V_HRBF41.CODEDLV',j.codedlv);
            v_syncond := replace(v_syncond,'V_HRBF41.AGECHILD',nvl(trunc(months_between(sysdate,j.dtechbd)),0));

            v_st    := 'select count(*) from dual where '||v_syncond;
            v_check := execute_stmt(v_st);

            if v_check = true then
              v_pass      := 'Y';
              exit;
            end if;
          end loop;
        else
          v_pass      := 'Y';
        end if;
        if v_pass = 'Y' then
          v_syncond := replace(v_syncond,'V_HRBF41.CODEMPID',''''||p_codempid||'''');
          v_syncond := replace(v_syncond,'V_HRBF41.CODCOMP',''''||v_codcompt||'''');
          v_syncond := replace(v_syncond,'V_HRBF41.QTYWKDAY',v_month);
          v_syncond := replace(v_syncond,'V_HRBF41.TYPEMP',''''||v_typempt||'''');
          v_syncond := replace(v_syncond,'V_HRBF41.CODEMPMT',''''||v_codempmtt||'''');
          v_syncond := replace(v_syncond,'V_HRBF41.NUMLVL',v_numlvlt);
          v_syncond := replace(v_syncond,'V_HRBF41.CODPOS',''''||v_codposnow||'''');
          v_syncond := replace(v_syncond,'V_HRBF41.STAEMP',''''||v_staemp||'''');
          v_syncond := replace(v_syncond,'V_HRBF41.AMTINCOM1',v_amtincom);
          v_syncond := replace(v_syncond,'V_HRBF41.DTEEMPMT','to_date('''||to_char(v_qtywkday,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');

          v_st    := 'select count(*) from dual where '||v_syncond;
          v_check := execute_stmt(v_st);

--          if v_check = true then
--            v_numobfn   := i.numobf;
--            v_amtwidrwn := i.amtwidrw;
--            v_qtywidrwn := i.qtywidrw;
--            exit;
--          end if;
-- comment by user18
        end if;
      end loop;
      v_pass      := 'N';

      for i in c_tobfcdet loop
        v_syncond := i.syncond;
        if v_syncond like '%CODEDLV%' or v_syncond like '%AGECHILD%' then
          for j in c_tchildrn loop
            v_syncond := replace(v_syncond,'V_HRBF41.CODEMPID',''''||p_codempid||'''');
            v_syncond := replace(v_syncond,'V_HRBF41.CODCOMP',''''||v_codcomp||'''');
            v_syncond := replace(v_syncond,'V_HRBF41.QTYWKDAY',v_month);
            v_syncond := replace(v_syncond,'V_HRBF41.TYPEMP',''''||v_typemp||'''');
            v_syncond := replace(v_syncond,'V_HRBF41.CODEMPMT',''''||v_codempmt||'''');
            v_syncond := replace(v_syncond,'V_HRBF41.NUMLVL',v_numlvl);
            v_syncond := replace(v_syncond,'V_HRBF41.CODPOS',''''||v_codpos||'''');
            v_syncond := replace(v_syncond,'V_HRBF41.STAEMP',''''||v_staemp||'''');
            v_syncond := replace(v_syncond,'V_HRBF41.AMTINCOM1',v_amtincom1);
            v_syncond := replace(v_syncond,'V_HRBF41.DTEEMPMT','to_date('''||to_char(v_qtywkday,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
            v_syncond := replace(v_syncond,'V_HRBF41.CODEDLV',j.codedlv);
            v_syncond := replace(v_syncond,'V_HRBF41.AGECHILD',nvl(trunc(months_between(sysdate,j.dtechbd)),0));

            v_st    := 'select count(*) from dual where '||v_syncond;
            v_check := execute_stmt(v_st);

            if v_check = true then
                v_pass      := 'Y';
                exit;
            end if;
          end loop;
        else
          v_pass      := 'Y';
        end if;
        if v_pass = 'Y' then
          v_syncond := replace(v_syncond,'V_HRBF41.CODEMPID',''''||p_codempid||'''');
          v_syncond := replace(v_syncond,'V_HRBF41.CODCOMP',''''||v_codcomp||'''');
          v_syncond := replace(v_syncond,'V_HRBF41.QTYWKDAY',v_month);
          v_syncond := replace(v_syncond,'V_HRBF41.TYPEMP',''''||v_typemp||'''');
          v_syncond := replace(v_syncond,'V_HRBF41.CODEMPMT',''''||v_codempmt||'''');
          v_syncond := replace(v_syncond,'V_HRBF41.NUMLVL',v_numlvl);
          v_syncond := replace(v_syncond,'V_HRBF41.CODPOS',''''||v_codpos||'''');
          v_syncond := replace(v_syncond,'V_HRBF41.STAEMP',''''||v_staemp||'''');
          v_syncond := replace(v_syncond,'V_HRBF41.AMTINCOM1',v_amtincom1);
          v_syncond := replace(v_syncond,'V_HRBF41.DTEEMPMT','to_date('''||to_char(v_qtywkday,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');

          v_st    := 'select count(*) from dual where '||v_syncond;
          v_check := execute_stmt(v_st);

--          if v_check = true then
--            v_numobfo   := i.numobf;
--            v_amtwidrwo := i.amtwidrw;
--            v_qtywidrwo := i.qtywidrw;
--            exit;
--          end if;
--          comment by user18
        end if;
      end loop;

      if nvl(v_numobfn,'99') <> nvl(v_numobfo,'99') then
        p_datachg   := 'Y';
        p_numobfn   := v_numobfn;
        p_amtwidrwn := v_amtwidrwn;
        p_qtywidrwn := v_qtywidrwn;
        p_numobfo   := v_numobfo;
        p_amtwidrwo := v_amtwidrwo;
        p_qtywidrwo := v_qtywidrwo;
      end if;
    end if;--v_count = 0
  end if;

end;

procedure gen_prbcodpos (p_codcompy in varchar2,
                         flg_log    in varchar2,
                         p_mailalno in varchar2,
                         p_dteeffec in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';

  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             clob;
  v_label           varchar2(4000 char) := '';
  v_item            varchar2(4000 char) := '';
  v_desc            varchar2(4000 char) := '';
  v_comma           varchar2(1);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(1000 char);
  v_receiver        temploy1.codempid%type;
  v_codapman        tproasgn.codempap%type;
  v_codposap        tproasgn.codposap%type;
  v_codcompap       tproasgn.codcompap%type;
  v_codcomp         tcenter.codcomp%type;
  v_codpos          tpostn.codpos%type;
  v_codcompemp      tcenter.codcomp%type;
  v_codposemp       tpostn.codpos%type;
  v_seqno           tpmasign.seqno%type;
  v_typproba        varchar2(1 char);

  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;

  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           dtelast,qtydayr
      from tpmalert
     where codcompy = p_codcompy
       and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '40'
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver/*, item2 dteyreap, item3 numtime*/, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver/*,dteyreap,numtime*/,seqno;

  cursor c_sendmail is
    select item1 codempid, item2 dteeffec,
           item3 numseq, item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
--       and item2 = v_dteyreap
--       and item3 = v_numtime
       and item5 = v_seqno
  order by codempid;
  
  cursor c_asign is
    select codcomp,codpos,codempid
	  from tproasgh
	 where v_codcomp   like codcomp||'%'
	   and v_codpos    like codpos
	   and v_codempid  like codempid
       and typproba = v_typproba
  order by codempid desc,codcomp desc;

  cursor c_tproasgn is
    select numseq,flgappr,codcompap,codposap,codempap
	  from tproasgn
	 where codcomp   = v_codcompemp
	   and codpos    = v_codposemp
	   and codempid  = v_codempid2
       and typproba = v_typproba
  order by numseq  ;

begin
  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno            := i.mailalno;
      v_dteeffec            := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      begin
        select count(*) into v_count
          from tpmasign
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec
           and flgappr  = '5'
           and rownum   = 1;
      exception when no_data_found then
        v_count := 0;
      end;
      if v_count = 0 then
         v_typesend := 'A';
      else
         v_typesend := 'N';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;

      v_cursor := dbms_sql.open_cursor;
      if i.qtydayb is not null then -- Before
         v_stdate := to_char(sysdate,'dd/mm/yyyy');
         v_endate := to_char((sysdate + i.qtydayb),'dd/mm/yyyy');
         v_where  := 'where  temploy1.staemp in (''1'',''3'') and  ttmovemt.dteduepr = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        if v_where is not null then
          v_where  := v_where||' and  ' ||check_stmt(i.syncond)|| ' ';
        else
          v_where  := ' where temploy1.staemp in (''1'',''3'') and ' ||check_stmt(i.syncond)|| ' ';
        end if;
      else
        if v_where is null then
          v_where  := ' where temploy1.staemp in (''1'',''3'') ';
        end if;
      end if;

      v_stment := 'select ttmovemt.codempid, to_char(ttmovemt.dteeffec,''dd/mm/yyyy'') dteeffec, ttmovemt.numseq '||
                  'from ttmovemt, temploy1 ' ||v_where|| ' '||
                  ' and ttmovemt.staupd in (''U'',''C'') '||
                  ' and ttmovemt.codempid = temploy1.codempid '||
                  ' and temploy1.codcomp like '''|| p_codcompy ||'%'' '||
                  'order by ttmovemt.codempid, ttmovemt.dteeffec, ttmovemt.numseq';
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);
      
      for j in 1..3 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;

      v_dummy := dbms_sql.execute(v_cursor);

      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        
        for j in 1..3 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        
        v_codempid := data_file(1);
        v_count    := 0;
        
        begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and codcompy = p_codcompy
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid
             and fieldd1  = to_date(data_file(2),'dd/mm/yyyy')
             and fieldc2  = data_file(3);
        exception when no_data_found then
          v_count := 0;
        end;
        if flg_log = 'N' then
           v_count := 0;
        end if;
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit;   
        
        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '6' then
                        v_typproba := '2';
                        begin
                            select codcomp,codpos
                              into v_codcomp,v_codpos
                              from temploy1
                             where codempid = v_codempid;
                        exception when no_data_found then null;
                        end;
                        
                        for j in c_asign loop
                            v_codcompemp   := j.codcomp;
                            v_codposemp    := j.codpos;
                            v_codempid2    := j.codempid;
                            exit;
                        end loop; --c_asign
                        for j in c_tproasgn loop
                            if j.flgappr = '1' then
                                find_approve_name(v_codempid,i.seqno,'1',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            elsif j.flgappr = '2' then
                                find_approve_name(v_codempid,i.seqno,'3',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            elsif j.flgappr = '3' then
                                find_approve_name(v_codempid,i.seqno,'4',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            end if;
                        end loop;
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,data_file(2),data_file(3),r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
            end if;
          else
            sendmail_ttmovemt( v_codempid,data_file(2),data_file(3),
                                p_codcompy,i.mailalno,i.dteeffec,i.codsend,
                                i.typemail,i.message,null,null,
                                v_typesend);
          end if;
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,data_file(3),null,null,null,data_file(2),null,null);
          end if;
        end if;--v_count
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert
           set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;
      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' ttmovemt.codempid = '''||i.codempid||''' and ttmovemt.dteeffec = to_date('''||i.dteeffec||''',''dd/mm/yyyy'') and ttmovemt.numseq = '''||i.numseq||''' ',v_numseq,40);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
    end if;
  end loop;
end; --end gen_prbcodpos

procedure gen_prbcodposn (p_codcompy  in varchar2,
                         flg_log      in varchar2,
                         p_mailalno   in varchar2,
                         p_dteeffec   in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';

  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             clob;
  v_label           varchar2(4000 char) := '';
  v_item            varchar2(4000 char) := '';
  v_desc            varchar2(4000 char) := '';
  v_comma           varchar2(1);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(1000 char);
  v_receiver        temploy1.codempid%type;
  v_codapman        tproasgn.codempap%type;
  v_codposap        tproasgn.codposap%type;
  v_codcompap       tproasgn.codcompap%type;
  v_codcomp         tcenter.codcomp%type;
  v_codpos          tpostn.codpos%type;
  v_codcompemp      tcenter.codcomp%type;
  v_codposemp       tpostn.codpos%type;
  v_seqno           tpmasign.seqno%type;
  v_typproba        varchar2(1 char);

  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;
    arr_codobf   descol;

  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           dtelast,qtydayr
      from tpmalert
     where codcompy = p_codcompy
       and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = 42
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver/*, item2 dteyreap, item3 numtime*/, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver/*,dteyreap,numtime*/,seqno;

  cursor c_sendmail is
    select item1 codempid, item2 dteeffec,
           item3 numseq, item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
--       and item2 = v_dteyreap
--       and item3 = v_numtime
       and item5 = v_seqno
  order by codempid;
  
  cursor c_asign is
    select codcomp,codpos,codempid
	  from tproasgh
	 where v_codcomp   like codcomp||'%'
	   and v_codpos    like codpos
	   and v_codempid  like codempid
       and typproba = v_typproba
  order by codempid desc,codcomp desc;

  cursor c_tproasgn is
    select numseq,flgappr,codcompap,codposap,codempap
	  from tproasgn
	 where codcomp   = v_codcompemp
	   and codpos    = v_codposemp
	   and codempid  = v_codempid2
       and typproba = v_typproba
  order by numseq  ;

begin
  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno  := i.mailalno;
      v_dteeffec  := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = para_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      begin
        select count(*) into v_count
          from tpmasign
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec
           and flgappr  = '5'
           and rownum   = 1;
      exception when no_data_found then
        null;
      end;
      if v_count = 0 then
         v_typesend := 'A';
      else
         v_typesend := 'N';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;

      v_where   := ' where temploy1.staemp in (''1'',''3'') ';

      v_cursor := dbms_sql.open_cursor;
      if i.qtydayb is not null then -- Before
         v_stdate := to_char(sysdate,'dd/mm/yyyy');
         v_endate := to_char((sysdate + i.qtydayb),'dd/mm/yyyy');
         v_where  := v_where||' and ttprobatd.dtedueprn = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        v_where  := v_where||' and  ' ||check_stmt(i.syncond)|| ' ';
      end if;

      v_stment := 'select ttmovemt.codempid,to_char(ttmovemt.dteeffec,''dd/mm/yyyy'') dteeffec,ttmovemt.numseq '||
                  'from ttmovemt ,temploy1 , ttprobatd ' ||v_where|| ' '||
                  ' and ttmovemt.staupd   in (''U'',''C'') '||
                  ' and ttmovemt.codempid = temploy1.codempid '||
                  ' and ttmovemt.codempid = ttprobatd.codempid '||
                  ' and ttmovemt.dteduepr = ttprobatd.dteduepr '||
                  ' and temploy1.codcomp like '''|| p_codcompy ||'%'' '||
                  'order by ttmovemt.codempid,ttmovemt.dteeffec,ttmovemt.numseq';
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);
      
      for j in 1..3 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;

      v_dummy := dbms_sql.execute(v_cursor);

      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..3 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        v_count    := 0;
        begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and codcompy = p_codcompy
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid
             and fieldd1  = to_date(data_file(2),'dd/mm/yyyy')
             and fieldc2  = data_file(3);
        exception when no_data_found then
          v_count := 0;
        end;
        if flg_log = 'N' then
           v_count := 0;
        end if;
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit;  
        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '6' then
                        v_typproba := '2';
                        begin
                            select codcomp,codpos
                              into v_codcomp,v_codpos
                              from temploy1
                             where codempid = v_codempid;
                        exception when no_data_found then null;
                        end;
                        
                        for j in c_asign loop
                            v_codcompemp   := j.codcomp;
                            v_codposemp    := j.codpos;
                            v_codempid2    := j.codempid;
                            exit;
                        end loop; --c_asign
                        for j in c_tproasgn loop
                            if j.flgappr = '1' then
                                find_approve_name(v_codempid,i.seqno,'1',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            elsif j.flgappr = '2' then
                                find_approve_name(v_codempid,i.seqno,'3',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            elsif j.flgappr = '3' then
                                find_approve_name(v_codempid,i.seqno,'4',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            end if;
                        end loop;
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,data_file(2),data_file(3),r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
--              hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,' ttmovemt.codempid = '''||v_codempid||''' and ttmovemt.dteeffec = '''||data_file(2)||''' and ttmovemt.numseq = '''||data_file(3)||''' ',v_seq,i.typemail);
            end if;
          else
            sendmail_ttmovemt( v_codempid,data_file(2),data_file(3),
                                p_codcompy,i.mailalno,i.dteeffec,i.codsend,
                                i.typemail,i.message,null,null,
                                v_typesend);
          end if;
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,data_file(3),null,null,null,data_file(2),null,null);
          end if;
        end if;--v_count
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert
           set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;
      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' ttmovemt.codempid = '''||i.codempid||''' and ttmovemt.dteeffec = to_date('''||i.dteeffec||''',''dd/mm/yyyy'') and ttmovemt.numseq = '''||i.numseq||''' ',v_numseq,42);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
    end if;
  end loop;
end; --end gen_prbcodposn

procedure gen_prbcodposp (p_codcompy   in varchar2,
                          flg_log      in varchar2,
                          p_mailalno   in varchar2,
                          p_dteeffec   in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';

  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             clob;
  v_label           varchar2(4000 char) := '';
  v_item            varchar2(4000 char) := '';
  v_desc            varchar2(4000 char) := '';
  v_comma           varchar2(1);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(1000 char);
  v_receiver        temploy1.codempid%type;
  v_codapman        tproasgn.codempap%type;
  v_codposap        tproasgn.codposap%type;
  v_codcompap       tproasgn.codcompap%type;
  v_codcomp         tcenter.codcomp%type;
  v_codpos          tpostn.codpos%type;
  v_codcompemp      tcenter.codcomp%type;
  v_codposemp       tpostn.codpos%type;
  v_seqno           tpmasign.seqno%type;
  v_typproba        varchar2(1 char);

  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;

  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           dtelast,qtydayr
      from tpmalert
     where codcompy = p_codcompy
       and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '44'
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver/*, item2 dteyreap, item3 numtime*/, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver/*,dteyreap,numtime*/,seqno;

  cursor c_sendmail is
    select item1 codempid, item2 dteduepr,
           item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
--       and item2 = v_dteyreap
--       and item3 = v_numtime
       and item5 = v_seqno
  order by codempid;
  
  cursor c_asign is
    select codcomp,codpos,codempid
	  from tproasgh
	 where v_codcomp   like codcomp||'%'
	   and v_codpos    like codpos
	   and v_codempid  like codempid
       and typproba = v_typproba
  order by codempid desc,codcomp desc;

  cursor c_tproasgn is
    select numseq,flgappr,codcompap,codposap,codempap
	  from tproasgn
	 where codcomp   = v_codcompemp
	   and codpos    = v_codposemp
	   and codempid  = v_codempid2
       and typproba = v_typproba
  order by numseq  ;

begin
  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno  := i.mailalno;
      v_dteeffec  := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      begin
        select count(*) into v_count
          from tpmasign
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec
           and flgappr  = '5'
           and rownum   = 1;
      exception when no_data_found then
        null;
      end;
      if v_count = 0 then
         v_typesend := 'A';
      else
         v_typesend := 'N';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;

      v_cursor := dbms_sql.open_cursor;
      
      v_where   := ' where temploy1.codcomp like '''|| p_codcompy ||'%''
                       and ttprobat.typproba  = ''2''
                       and temploy1.codempid  = ttprobat.codempid
                       and ttprobat.codrespr  = ''P''
                       ';

      if i.qtydayb is not null then -- Before
         v_endate := to_char(trunc((sysdate) + i.qtydayb),'dd/mm/yyyy');
         v_where  := v_where||' and ttprobat.dteefpos = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        v_where  := v_where||' and  (' ||i.syncond|| ') ';
      end if;

      V_STMENT := 'select temploy1.codempid,to_char(ttprobat.dteduepr,''dd/mm/yyyy'') dteduepr
                   from temploy1, ttprobat  ' ||
                   v_where|| '
                   order by codempid ';
      commit;
      
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..2 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;

      v_dummy := dbms_sql.execute(v_cursor);

      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..2 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        v_count    := 0;
        begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and codcompy = p_codcompy
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid
             and fieldd1  = to_date(data_file(2),'dd/mm/yyyy');
        exception when no_data_found then
          v_count := 0;
        end;
        if flg_log = 'N' then
           v_count := 0;
        end if;
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit; 
        
        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '6' then
                        v_typproba := '2';
                        begin
                            select codcomp,codpos
                              into v_codcomp,v_codpos
                              from temploy1
                             where codempid = v_codempid;
                        exception when no_data_found then null;
                        end;
                        
                        for j in c_asign loop
                            v_codcompemp   := j.codcomp;
                            v_codposemp    := j.codpos;
                            v_codempid2    := j.codempid;
                            exit;
                        end loop; --c_asign
                        for j in c_tproasgn loop
                            if j.flgappr = '1' then
                                find_approve_name(v_codempid,i.seqno,'1',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            elsif j.flgappr = '2' then
                                find_approve_name(v_codempid,i.seqno,'3',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            elsif j.flgappr = '3' then
                                find_approve_name(v_codempid,i.seqno,'4',j.codempap,j.codcompap,j.codposap,p_codapp_receiver,p_coduser,v_codempid); --user36 STA3590309 12/09/2016
                            end if;
                        end loop;
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,data_file(2),null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
--              hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,' ttmovemt.codempid = '''||v_codempid||''' and ttmovemt.dteeffec = '''||data_file(2)||''' and ttmovemt.numseq = '''||data_file(3)||''' ',v_seq,i.typemail);
            end if;
--          else
--            sendmail_ttmovemt( v_codempid,data_file(2),data_file(3),
--                                p_codcompy,i.mailalno,i.dteeffec,i.codsend,
--                                i.typemail,i.message,null,null,
--                                v_typesend);
          end if;
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,null,null,null,null,data_file(2),null,null);
          end if;
        end if;--v_count
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert
           set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;
      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' ttprobat.codempid = '''||i.codempid||''' and ttprobat.dteduepr = to_date('''||i.dteduepr||''',''dd/mm/yyyy'') ',v_numseq,44);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
    end if;
  end loop;
end; --end gen_prbcodposp

function check_stmt (p_syncond    varchar2) return varchar2 is

  v_syncond     tpmalert.syncond%type;

  cursor c1 is
    select namfld
      from treport2
     where codapp = 'HRPMATE4'
  order by numseq;

begin
  v_syncond  := p_syncond;
  for i in c1 loop
    v_syncond := replace(upper(v_syncond),i.namfld,'a.'||i.namfld);
  end loop;
  return(v_syncond);
end;

procedure gen_public_holiday (p_codcompy  in varchar2,
                              flg_log     in varchar2,
                              p_mailalno  in varchar2,
                              p_dteeffec  in date) is

  v_cursor       number;
  v_dummy        integer;
  v_stment       varchar2(2000 char);
  v_where        varchar2(2000 char);
  v_data_file    varchar2(2500 char);
  v_codempid     temploy1.codempid%type;
  v_count        number;
  v_stdate       varchar2(20 char);
  v_endate       varchar2(20 char);

  type descol is table of varchar2(2500 char) index by binary_integer;
    data_file    descol;

  v_typesend     varchar2(1 char) := 'N';
  v_testsend     varchar2(1 char) := 'N';
  v_mailalno     varchar2(8 char);
  v_dteeffec     date;
  v_dtepublic    date;
  v_data         varchar2(1 char) := 'N';
  v_subject      varchar2(100 char);
  v_message      varchar2(4000 char);
  v_filename     varchar2(100 char);

  cursor c_tpmalert is
    select mailalno,dteeffec,syncond,codsend,typemail,
           message,qtydayb,--qtydaya,
           qtydayr,dtelast
      from tpmalert
     where codcompy = p_codcompy
       and
            (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '50'
  order by mailalno;

  cursor c_tpmpublic is
    select dtepublic,subject,message,filename
      from tpmpublic
     where codcompy = p_codcompy/*
       and dtepublic = v_dtepublic*/;

begin

  delete from ttemprpt where codapp = 'BBBBB';
  commit;

  for i in c_tpmalert loop
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;

    if v_testsend = 'Y' then
      if i.qtydayb is not null then -- Before
        v_stdate := to_char(sysdate,'dd/mm/yyyy');
        v_endate := to_char(sysdate + i.qtydayb,'dd/mm/yyyy');
      end if;
--      if i.qtydaya is not null then -- After
--        v_stdate := to_char((sysdate - i.qtydaya),'dd/mm/yyyy');
--        v_endate := to_char(sysdate,'dd/mm/yyyy');
--      end if;

      v_mailalno  := i.mailalno;
      v_dteeffec  := i.dteeffec;
      v_dtepublic := v_endate;
      v_data := 'N';

      for j in c_tpmpublic loop
        v_data := 'Y';
        v_subject  := j.subject;
        v_message  := j.message;
        v_filename := j.filename;
        exit;
      end loop;

      if v_data = 'Y' then
        if i.syncond is not null then
          if v_where is not null then
            v_where  := v_where||' and  ' ||i.syncond|| ' ';
          else
            v_where  := ' where codcomp like '''|| p_codcompy ||'%'' and staemp in (''1'',''3'') and ' ||i.syncond|| ' ';
          end if;
        else
          if v_where is null then
            v_where  := ' where codcomp like '''|| p_codcompy ||'%'' and staemp in (''1'',''3'') ';
          end if;
        end if;

        v_stment := 'select codempid from temploy1 ' ||v_where|| ' and rownum = 1 order by codempid';

        v_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

        for j in 1..1 loop
          dbms_sql.define_column(v_cursor,j,v_data_file,500);
        end loop;

        v_dummy := dbms_sql.execute(v_cursor);

        loop
          if dbms_sql.fetch_rows(v_cursor) = 0 then
            exit;
          end if;
          for j in 1..1 loop
            dbms_sql.column_value(v_cursor,j,v_data_file);
            data_file(j) := v_data_file;
          end loop;
          v_codempid := data_file(1);
          v_count    := 0;

          begin
            select count(*) into v_count
              from talertlog
             where codapp   = 'HRPMATE'
               and codcompy = p_codcompy
               and mailalno = i.mailalno
               and dteeffec = i.dteeffec
               and fieldc1  = v_codempid||to_char(v_endate,'ddmmyy');
          exception when no_data_found then
            v_count := 0;
          end;

          if v_count = 0 then
            if v_filename is not null then
              v_typesend := 'A';
            else
              v_typesend := 'N';
            end if;

            sendmail_public( v_codempid,i.mailalno,i.dteeffec,v_dtepublic,i.codsend,i.typemail,v_subject,v_message||'<br>'||i.message,v_filename,v_typesend);
            if flg_log = 'Y' then
              insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid||to_char(v_endate,'ddmmyy'),null,null,null,null,null,null,null);
            end if;
          end if;
        end loop;
        dbms_sql.close_cursor(v_cursor);
      end if;
    end if;
  end loop;
end;

procedure sendmail_public( p_codempid  in varchar2,
                           p_mailalno  in varchar2,
                           p_dteeffec  in date,
                           p_dtepublic in date,
                           p_codsend   in varchar2,
                           p_typemail  in varchar2,
                           p_subject   in varchar2,
                           p_message   in clob,
                           p_filename  in varchar2,
                           p_typesend  in varchar2) is

  v_msg_to        clob := p_message;
  v_template_to   clob;
  v_mailtemplt    varchar2(15) := get_tsetup_value('MAILTEMPLT');
  v_codform       varchar2(15);
  v_msg           clob;
  v_error         varchar2(10);
  v_temp          varchar2(500);
  v_codcomp       tcenter.codcomp%type;
  v_codpos        varchar2(4);
  v_codcompr      tcenter.codcomp%type;
  v_codposre      varchar2(4);
  v_email         varchar2(100);
  v_sender_email  varchar2(100);

begin
  if v_mailtemplt = 'Y' then
    v_codform := 'TEMPLATEAL';
--    v_codform := 'TEMPLATEPM';
  else
    v_codform := 'TEMPLATEAL';
--    v_codform := 'TEMPLTPMTT';
  end if;

  begin
    select decode(p_lang,'101',messagee,
                         '102',messaget,
                         '103',message3,
                         '104',message4,
                         '105',message5,
                         '101',messagee) msg
    into  v_template_to
    from  tfrmmail
    where codform = v_codform;
  exception when others then
    v_template_to := null;
  end;

  replace_text_public(v_msg_to,v_template_to,p_codempid,
                      p_codsend,p_mailalno,p_dteeffec,
                      p_dtepublic,p_typemail,p_typesend);

  begin
    select email --user36 STA3590309 09/09/2016 codcomp,codpos,codcompr,codposre,
      into v_email --v_codcomp,v_codpos,v_codcompr,v_codposre,
      from temploy1
     where codempid = p_codempid;
  exception when no_data_found then
    null;
  end;
  --<<user36 STA3590309 09/09/2016
	begin
    select email into v_sender_email
      from temploy1
     where codempid = p_codsend;
  exception when no_data_found then
    v_sender_email := null;
  end;
  if v_sender_email is null then
    v_sender_email := get_tsetup_value('MAILEMAIL');
  end if;
  if p_typesend = 'N' then
    v_temp := null;
  else
    v_temp := get_tsetup_value('PATHEXCEL')||p_filename;
  end if;
  -->>user36 STA3590309 09/09/2016
  if v_email is not null then
    v_msg      := v_msg_to;
    v_msg      := replace(v_msg ,'[P_OTHERMSG]',null);
    v_msg      := replace(v_msg ,'<PARAM1>', get_temploy_name(p_codempid,p_lang));
    v_msg      := replace(v_msg ,'[PARAM1]', get_temploy_name(p_codempid,p_lang));
    --<<user36 STA3590309 09/09/2016
    v_error    := SendMail_AttachFile(v_sender_email,v_email,p_subject,v_msg,v_temp,null,null,null,null);

    /*v_msg      := replace(v_msg ,'<P_EMAIL>',v_email);
    begin
      if p_typesend = 'A' then
        v_error    := SendMail_AttachFile(get_tsetup_value('MAILEMAIL'),v_email,p_subject,v_msg,v_temp,null,null,null,null);
      else
        v_error    := send_mail(v_email,v_msg);
      end if;
    exception when others then
      null;
    end;*/
    -->>user36 STA3590309 09/09/2016
  end if;

end;--sendmail_public

procedure replace_text_public(p_msg       in out clob,
                              p_template  in clob,
                              p_codempid  in varchar2,
                              p_codsend   in varchar2,
                              p_mailalno  in varchar2,
                              p_dteeffec  in date,
                              p_dtepublic in date,
                              p_typemail  in varchar2,
                              p_typesend  in varchar2) is

  data_file     clob;
  crlf          varchar2( 2 ):= chr( 13 ) || chr( 10 );
  v_message     clob;
  v_template    clob;
  v_codpos      varchar2(4);
  v_cursor       number;
  v_dummy        integer;
  v_stment       clob;
  v_where        clob;
  v_data_file    clob;
  v_codempid     varchar2(10);
  v_funcdesc     varchar2(100);
  v_msg          clob;
  v_data_msg     long;
  v_headmag      long := null;
  v_mailtemplt   varchar2(15) := get_tsetup_value('MAILTEMPLT');

  type descol is table of varchar2(2500) index by binary_integer;
    data_files   descol;

begin
  begin
    select codpos  into v_codpos
      from temploy1
     where codempid = p_codsend;
  exception when no_data_found then
    v_codpos := null;
  end;

  v_template  := p_template;
  v_message   := p_msg;

  if v_mailtemplt = 'Y' then
  	v_message   := replace(v_template,'[P_MESSAGE]', replace(replace(v_message,chr(10),'<br>'),' ',';'));
  else
  	v_message   := replace(v_template,'[P_MESSAGE]',v_message);
  	v_message   := replace(v_message,chr(10),'<br>');
  end if;
  data_file   := v_message;

  --user36 STA3590309 09/09/2016
  /*if p_typesend = 'N' then
     v_headmag := 'From: ' ||get_tsetup_value('MAILEMAIL')||  crlf ||
                  'To: <P_EMAIL>'||crlf||
                  'Subject: '||get_tlistval_name('TYPMAILPM',p_typemail,p_lang)||crlf||
                  'Content-Type: text/html'||crlf;
  else
     v_headmag := null;
  end if;*/

  if data_file like ('%[PARA_FROM]%') then
    data_file  := replace(data_file  ,'[PARA_FROM]', get_temploy_name(p_codsend,p_lang));
  end if;
  if data_file like ('%[PARA_POSITION]%') then
    data_file  := replace(data_file  ,'[PARA_POSITION]',get_tpostn_name(v_codpos,p_lang));
  end if;

  p_msg := v_headmag||data_file;

end; -- Function replace_text_public

procedure gen_resign  (p_codcompy  in varchar2,
                       flg_log    in varchar2,
                       p_mailalno in varchar2,
                       p_dteeffec in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500 char);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';
  
  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             varchar2(2500 char);
  v_label           varchar2(2500 char):= '';
  v_item            varchar2(2500 char):= '';
  v_desc            varchar2(2500 char):= '';
  v_comma           varchar2(1 char);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(500 char);
  v_receiver        temploy1.codempid%type;
  v_codapman        tproasgn.codempap%type;
  v_codposap        tproasgn.codposap%type;
  v_codcompap       tproasgn.codcompap%type;
  v_codcomp         tcenter.codcomp%type;
  v_codpos          tpostn.codpos%type;
  v_codcompemp      tcenter.codcomp%type;
  v_codposemp       tpostn.codpos%type;
  v_seqno           tpmasign.seqno%type;

  type descol is table of varchar2(2500 char) index by binary_integer;
    data_file    descol;

  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           qtydayr,dtelast
     from tpmalert
    where codcompy = p_codcompy
      and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '60'
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver,seqno;

  cursor c_sendmail is
    select item1 codempid, item2 dteeffec,
           item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
       and item5 = v_seqno
  order by codempid;
begin

  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno            := i.mailalno;
      v_dteeffec            := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      for i in c_tmailrpm loop
        v_count := v_count + 1;
      end loop;
      
      if v_count > 0 then
        v_typesend := 'A';
      else
        v_typesend := 'N';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;
      v_where := ' where temploy1.codcomp like '''|| p_codcompy||'%'' and ttexempt.STAUPD in (''C'',''U'')';
      v_cursor := dbms_sql.open_cursor;
      if i.qtydayb is not null then -- Before
        v_endate := to_char(trunc((sysdate) + i.qtydayb),'dd/mm/yyyy');
        v_where  := v_where||' and ttexempt.dteeffec = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        v_where  := v_where||' and (' ||i.syncond|| ') ';
      end if;
      
      v_stment := 'select ttexempt.codempid,to_char(ttexempt.dteeffec,''dd/mm/yyyy'') dteeffec
                   from ttexempt, temploy1 ' ||v_where|| '
                   and ttexempt.codempid = temploy1.codempid
                   order by ttexempt.codempid';
      commit;
      
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);
      for j in 1..2 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;

      v_dummy := dbms_sql.execute(v_cursor);
      
      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..2 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        v_count    := 0;
        begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and codcompy = p_codcompy
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid
             and fieldd1  = to_date(data_file(2),'dd/mm/yyyy');
        exception when no_data_found then
          v_count := 0;
        end;
        
        if flg_log = 'N' then
           v_count := 0;
        end if;
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit;  
        
        if v_count = 0 then
          v_seq     := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,data_file(2),null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
--              hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,' ttexempt.codempid = '''||v_codempid||''' and ttexempt.dteeffec = '''||data_file(2)||''' ',v_seq,i.typemail);
            end if;
          else
            v_filename := null;
            sendmail_resign(p_codcompy,v_codempid,data_file(2),i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,v_filename,v_typesend);
          end if;
          if flg_log = 'Y' then
             insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,null,null,null,null,data_file(2),null,null);
          end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert
           set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;

      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' ttexempt.codempid = '''||i.codempid||''' and ttexempt.dteeffec = to_date('''||i.dteeffec||''',''dd/mm/yyyy'') ',v_numseq,60);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
    end if;
  end loop;
end; --gen_resign

procedure sendmail_resign  (p_codcompy  in varchar2,
                            p_codempid  in varchar2,
                            p_dteeffect in date,
                            p_mailalno  in varchar2,
                            p_dteeffec  in date,
                            p_codsend   in varchar2,
                            p_typemail  in varchar2,
                            p_message   in clob,
                            p_filname   in varchar2,
                            p_typesend  in varchar2) is

  v_msg_to        clob := p_message;
  v_template_to   clob;
  v_mailtemplt    varchar2(15) := get_tsetup_value('MAILTEMPLT');
  v_codform       varchar2(15);
begin

  if v_mailtemplt = 'Y' then
    v_codform := 'TEMPLATEPM';
  else
    v_codform := 'TEMPLTPMTT';
  end if;

  begin
    select decode(p_lang,'101',messagee,
                         '102',messaget,
                         '103',message3,
                         '104',message4,
                         '105',message5,
                         '101',messagee) msg
    into  v_template_to
    from  tfrmmail
    where codform = v_codform;
  exception when others then
    v_template_to := null;
  end;

  replace_text_resign  (v_msg_to,v_template_to,p_codempid,
                        p_dteeffect,p_codsend,p_codcompy,p_mailalno,
                        p_dteeffec,p_typemail,p_typesend);

  auto_execute_mail(p_codcompy,p_mailalno,p_dteeffec,p_codempid,v_msg_to,p_typemail,p_filname,p_typesend);
end;--sendmail_resign

procedure replace_text_resign   (p_msg       in out clob,
                                 p_template  in clob,
                                 p_codempid  in varchar2,
                                 p_dteeffect in date,
                                 p_codsend   in varchar2,
                                 p_codcompy  in varchar2,
                                 p_mailalno  in varchar2,
                                 p_dteeffec  in date,
                                 p_typemail  in varchar2,
                                 p_typesend  in varchar2) is

  data_file     clob;
  crlf          varchar2( 2 ):= chr( 13 ) || chr( 10 );
  v_message     clob;
  v_template    clob;
  v_codpos      varchar2(4);
  v_cursor       number;
  v_dummy        integer;
  v_stment       varchar2(4000);
  v_where        varchar2(2000);
  v_data_file    varchar2(2500);
  v_codempid     varchar2(10);
  v_funcdesc     varchar2(100);
  v_msg          long;
  v_data_msg     long;
  v_headmag      long;
--  v_replace      long;
  v_mailtemplt  varchar2(15) := get_tsetup_value('MAILTEMPLT');

  type descol is table of varchar2(2500) index by binary_integer;
    data_files   descol;

  cursor c_tpmparam is
    select mailalno,numseq,codtable,fparam,ffield,descript,flgdesc
      from tpmparam
     where codcompy = p_codcompy
       and mailalno = p_mailalno
       and dteeffec = p_dteeffec
  order by fparam;

begin
  begin
    select codpos  into v_codpos
    from temploy1
    where codempid = p_codsend;
  exception when no_data_found then
    v_codpos := null;
  end;

  v_template  := p_template;
  v_message   := p_msg;
  v_message   := replace(v_template,'[P_MESSAGE]', v_message );
  if v_mailtemplt = 'N' then
    v_message   := replace(v_message,chr(10),'<br>');
  end if;
  v_headmag   := null;

  data_file   := v_message;

  if p_typesend = 'N' then
    if data_file is not null then
      for i in c_tpmparam loop
        v_funcdesc := null;
        v_cursor   := dbms_sql.open_cursor;
        if i.codtable = 'V_TEMPLOY' then
          v_stment := 'select ' ||i.ffield|| ' from ' ||i.codtable|| ' where codempid = '''||p_codempid||''' ';
        elsif i.codtable = 'TTEXEMPT' then
          v_stment := 'select ' ||i.ffield|| ' from ' ||i.codtable|| ' '||
                      ' where codempid = '''||p_codempid||''' '||
                      '   and dteeffec = '''||p_dteeffect||''' ';
        end if;

        dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

        for j in 1..1 loop
          dbms_sql.define_column(v_cursor,j,v_data_file,500);
        end loop;

        v_dummy := dbms_sql.execute(v_cursor);

        loop
          if dbms_sql.fetch_rows(v_cursor) = 0 then
            exit;
          end if;
          for j in 1..1 loop
            dbms_sql.column_value(v_cursor,j,v_data_file);
            data_files(j) := v_data_file;
          end loop;
          if i.flgdesc = 'Y' then
            begin
              select funcdesc into v_funcdesc
                from tcoldesc
               where codtable = i.codtable
                 and codcolmn = i.ffield;
            exception when no_data_found then
              v_funcdesc := null;
            end;
            v_msg := v_funcdesc;
            v_msg := replace(v_msg,'P_CODE',''''||data_files(1)||'''');
            v_msg := replace(v_msg,'P_LANG',p_lang);
            v_msg := 'select '||v_msg||' from dual ';
            v_data_msg := execute_desc(v_msg);

            data_file  := replace(data_file ,i.fparam,v_data_msg);
          else
            data_file  := replace(data_file ,i.fparam,data_files(1));
          end if;
        end loop;
        dbms_sql.close_cursor(v_cursor);
      end loop;
    end if;
  end if;

  if data_file like ('%[PARA_FROM]%') then
    data_file  := replace(data_file  ,'[PARA_FROM]', get_temploy_name(p_codsend,p_lang));
  end if;
  if data_file like ('%[PARA_POSITION]%') then
    data_file  := replace(data_file  ,'[PARA_POSITION]',get_tpostn_name(v_codpos,p_lang));
  end if;

  p_msg := v_headmag||data_file;

end; -- Function replace_resign


procedure gen_retire     (p_codcompy  in varchar2,
                          flg_log     in varchar2,
                          p_mailalno  in varchar2,
                          p_dteeffec  in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500 char);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';
  
  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             varchar2(2500 char);
  v_label           varchar2(2500 char):= '';
  v_item            varchar2(2500 char):= '';
  v_desc            varchar2(2500 char):= '';
  v_comma           varchar2(1 char);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(500 char);
  v_receiver        temploy1.codempid%type;
  v_codapman        tproasgn.codempap%type;
  v_codposap        tproasgn.codposap%type;
  v_codcompap       tproasgn.codcompap%type;
  v_codcomp         tcenter.codcomp%type;
  v_codpos          tpostn.codpos%type;
  v_codcompemp      tcenter.codcomp%type;
  v_codposemp       tpostn.codpos%type;
  v_seqno           tpmasign.seqno%type;

  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;
    
  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           qtydayr,dtelast
      from tpmalert
     where codcompy = p_codcompy
       and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '70'
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver,seqno;

  cursor c_sendmail is
    select item1 codempid,
           item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
       and item5 = v_seqno
  order by codempid;

begin

  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno            := i.mailalno;
      v_dteeffec            := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      for i in c_tmailrpm loop
        v_count := v_count + 1;
      end loop;
      
      if v_count > 0 then
        v_typesend := 'A';
      else
        v_typesend := 'H';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;
      v_cursor := dbms_sql.open_cursor;
      v_where := ' where temploy1.codcomp like '''|| p_codcompy||'%'' and temploy1.staemp in (''1'',''3'') ';
      if i.qtydayb is not null then -- Before
         v_stdate := to_char(sysdate,'dd/mm/yyyy');
         v_endate := to_char(trunc((sysdate) + i.qtydayb),'dd/mm/yyyy');
--         v_where  := v_where||' and  dteretire =  to_date('''||v_endate||''',''dd/mm/yyyy'') ';
         v_where  := v_where||' and  dteretire is not null ';
      end if;

      if i.syncond is not null then
        v_where  := ' and (' ||i.syncond|| ') ';
      end if;

      v_stment := 'select temploy1.codempid from temploy1  ' ||v_where|| ' order by codempid';
      commit;
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..1 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;
      v_dummy := dbms_sql.execute(v_cursor);
      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..1 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        v_count    := 0;
        begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and codcompy = p_codcompy
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid;
        exception when no_data_found then
          v_count := 0;
        end;
        
        if flg_log = 'N' then
           v_count := 0;
        end if;
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit; 
        
        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,null,null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
--              hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,'codempid = '''||v_codempid||'''',v_seq,i.typemail);
            end if;
          else
            sendmail_alert(p_codcompy,v_codempid,i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,null,v_typesend);
          end if;
          -------------------------------
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,null,null,null,null,null,null,null);
          end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert
           set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;
      ------------------
      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' codempid = '''||i.codempid||'''  ',v_numseq,70);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
      ------------------
    end if;
  end loop;
end; -- gen_retire;
--
procedure gen_newemp  (p_codcompy  in varchar2,
                       flg_log     in varchar2,
                       p_mailalno  in varchar2,
                       p_dteeffec  in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500 char);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';
  
  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             varchar2(2500 char);
  v_label           varchar2(2500 char):= '';
  v_item            varchar2(2500 char):= '';
  v_desc            varchar2(2500 char):= '';
  v_comma           varchar2(1 char);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(500 char);
  v_receiver        temploy1.codempid%type;
  v_seqno           tpmasign.seqno%type;

  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;

  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           qtydayr,dtelast
      from tpmalert
     where codcompy = p_codcompy
       and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '80'
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver,seqno;

  cursor c_sendmail is
    select item1 codempid,
           item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
       and item5 = v_seqno
  order by codempid;

begin
  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno            := i.mailalno;
      v_dteeffec            := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';
      
      for i in c_tmailrpm loop
        v_count := v_count + 1;
      end loop;
      if v_count > 0 then
        v_typesend := 'A';
      else
        v_typesend := 'H';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;
      v_cursor := dbms_sql.open_cursor;
      v_where := ' where temploy1.codcomp like '''|| p_codcompy||'%'' and temploy1.staemp in (''1'') ';
      if i.qtydayb is not null then -- Before
         v_stdate := to_char(sysdate,'dd/mm/yyyy');
         v_endate := to_char((sysdate) + i.qtydayb,'dd/mm/yyyy');
         v_where  := v_where||' and temploy1.dteempmt = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        v_where  := v_where||' and  (' ||i.syncond|| ') ';
      end if;

      V_STMENT := 'select temploy1.codempid from temploy1  ' ||V_WHERE|| ' order by codempid';
      commit;
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..1 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;
      v_dummy := dbms_sql.execute(v_cursor);
      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..1 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        v_count := 0;
        begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid;
        exception when no_data_found then
          v_count := 0;
        end;
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit;
        
        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,null,null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
--              hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,'v_temploy.codempid = '''||v_codempid||'''',v_seq,i.typemail);
            end if;
          else
            sendmail_alert(p_codcompy,v_codempid,i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,null,v_typesend);
          end if;
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,null,null,null,null,null,null,null);
          end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;

      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' codempid = '''||i.codempid||'''  ',v_numseq,80);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
    end if;
  end loop;
end; -- gen_newemp
--
procedure gen_exprworkpmit  (p_codcompy  in varchar2,
                             flg_log     in varchar2,
                             p_mailalno  in varchar2,
                             p_dteeffec  in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500 char);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';
  
  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             varchar2(2500 char);
  v_label           varchar2(2500 char):= '';
  v_item            varchar2(2500 char):= '';
  v_desc            varchar2(2500 char):= '';
  v_comma           varchar2(1 char);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(500 char);
  v_receiver        temploy1.codempid%type;
  v_seqno           tpmasign.seqno%type;

  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;

  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           qtydayr,dtelast
      from tpmalert
     where codcompy = p_codcompy
       and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '90'
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver,seqno;

  cursor c_sendmail is
    select item1 codempid,
           item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
       and item5 = v_seqno
  order by codempid;

begin

  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno            := i.mailalno;
      v_dteeffec            := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      for i in c_tmailrpm loop
        v_count := v_count + 1;
      end loop;
      if v_count > 0 then
        v_typesend := 'A';
      else
        v_typesend := 'H';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;
      v_cursor := dbms_sql.open_cursor;
      v_where := ' where temploy1.codcomp like '''|| p_codcompy||'%'' and  temploy1.codempid = temploy2.codempid and temploy1.staemp in (''1'',''3'') ';
      if i.qtydayb is not null then -- Before
         v_stdate := to_char(sysdate,'dd/mm/yyyy');
         v_endate := to_char((sysdate) + i.qtydayb,'dd/mm/yyyy');
         v_where  := v_where||' and temploy2.dteprmen = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        v_where  := v_where||' and  (' ||i.syncond|| ') ';
      end if;

      V_STMENT := 'select temploy1.codempid
                     from temploy1 , temploy2 '
                   ||V_WHERE|| ' order by temploy1.codempid';

      commit;
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..1 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;
      v_dummy := dbms_sql.execute(v_cursor);
      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..1 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        V_COUNT    := 0;
        --<<User37 TTIC610049 05/09/2018
        /*begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid;
        exception when no_data_found then
          v_count := 0;
        end;*/
        -->>User37 TTIC610049 05/09/2018
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit; 
        
        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,null,null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
            end if;
          else
            sendmail_alert(p_codcompy,v_codempid,i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,null,v_typesend);
          end if;
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,null,null,null,null,null,null,null);
          end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;

      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' codempid = '''||i.codempid||'''  ',v_numseq,90);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
    end if;
  end loop;
end; -- gen_exprworkpmit
--
procedure gen_exprvisa  (p_codcompy  in varchar2,
                         flg_log     in varchar2,
                         p_mailalno  in varchar2,
                         p_dteeffec  in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500 char);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';
  
  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             varchar2(2500 char);
  v_label           varchar2(2500 char):= '';
  v_item            varchar2(2500 char):= '';
  v_desc            varchar2(2500 char):= '';
  v_comma           varchar2(1 char);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(500 char);
  v_receiver        temploy1.codempid%type;
  v_seqno           tpmasign.seqno%type;

  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;

  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           qtydayr,dtelast
      from tpmalert
     where codcompy = p_codcompy
       and ( (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '100'
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver,seqno;

  cursor c_sendmail is
    select item1 codempid,
           item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
       and item5 = v_seqno
  order by codempid;

begin

  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno            := i.mailalno;
      v_dteeffec            := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      for i in c_tmailrpm loop
        v_count := v_count + 1;
      end loop;
      if v_count > 0 then
        v_typesend := 'A';
      else
        v_typesend := 'H';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;
      v_cursor := dbms_sql.open_cursor;
      v_where := ' where temploy1.codcomp like '''|| p_codcompy||'%'' and  temploy1.codempid = temploy2.codempid and temploy1.staemp in (''1'',''3'') ';
      if i.qtydayb is not null then -- Before
         v_stdate := to_char(sysdate,'dd/mm/yyyy');
         v_endate := to_char((sysdate) + i.qtydayb,'dd/mm/yyyy');
         v_where  := v_where||' and temploy2.dtevisaexp = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        v_where  := v_where||' and  (' ||i.syncond|| ') ';
      end if;

      V_STMENT := 'select temploy1.codempid from temploy1, temploy2 '
                  ||V_WHERE|| ' order by temploy1.codempid';

      commit;
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..1 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;
      v_dummy := dbms_sql.execute(v_cursor);
      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..1 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        v_count := 0;
        begin
          select count(*) into v_count
            from talertlog
           where codapp   = 'HRPMATE'
             and mailalno = i.mailalno
             and dteeffec = i.dteeffec
             and fieldc1  = v_codempid;
        exception when no_data_found then
          v_count := 0;
        end;
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit; 
        
        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,null,null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
--              hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,'v_temploy.codempid = '''||v_codempid||'''',v_seq,i.typemail);
            end if;
          else
            sendmail_alert(p_codcompy,v_codempid,i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,null,v_typesend);
          end if;
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,null,null,null,null,null,null,null);
          end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;

      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' codempid = '''||i.codempid||'''  ',v_numseq,100);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
    end if;
  end loop;
end; -- gen_exprvisa
--
procedure gen_exprdoc  (p_codcompy  in varchar2,
                        flg_log     in varchar2,
                        p_mailalno  in varchar2,
                        p_dteeffec  in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500 char);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';
  
  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             varchar2(2500 char);
  v_label           varchar2(2500 char):= '';
  v_item            varchar2(2500 char):= '';
  v_desc            varchar2(2500 char):= '';
  v_comma           varchar2(1 char);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(500 char);
  v_receiver        temploy1.codempid%type;
  v_seqno           tpmasign.seqno%type;

  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;

  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           qtydayr,dtelast
      from tpmalert
     where codcompy = p_codcompy
       and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '110'
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy =  p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver,seqno;

  cursor c_sendmail is
    select item1 codempid,
           item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
       and item5 = v_seqno
  order by codempid;

begin

  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno            := i.mailalno;
      v_dteeffec            := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      for i in c_tmailrpm loop
        v_count := v_count + 1;
      end loop;
      if v_count > 0 then
        v_typesend := 'A';
      else
        v_typesend := 'H';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;
      v_cursor := dbms_sql.open_cursor;
      v_where := ' where temploy1.codcomp like '''|| p_codcompy||'%'' and  temploy1.numappl = tappldoc.numappl and temploy1.staemp in (''1'',''3'') ';
      if i.qtydayb is not null then -- Before
         v_stdate := to_char(sysdate,'dd/mm/yyyy');
         v_endate := to_char((sysdate) + i.qtydayb,'dd/mm/yyyy');
         v_where  := v_where||' and tappldoc.dtedocen = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        v_where  := v_where||' and  (' ||i.syncond|| ') ';
      end if;

      V_STMENT := 'select temploy1.codempid from temploy1, tappldoc '
                    ||V_WHERE|| ' order by temploy1.codempid';

      commit;
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..1 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;
      v_dummy := dbms_sql.execute(v_cursor);
      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..1 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        V_COUNT    := 0;
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit; 

        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,null,null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
--              hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,'v_temploy.codempid = '''||v_codempid||'''',v_seq,i.typemail);
            end if;
          else
            sendmail_alert(p_codcompy,v_codempid,i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,null,v_typesend);
          end if;
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,null,null,null,null,null,null,null);
          end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;

      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' codempid = '''||i.codempid||'''  ',v_numseq,110);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
    end if;
  end loop;
end; -- gen_exprdoc
--

procedure gen_congratpos  (p_codcompy  in varchar2,
                        flg_log     in varchar2,
                        p_mailalno  in varchar2,
                        p_dteeffec  in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';

  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             clob;
  v_label           varchar2(4000 char) := '';
  v_item            varchar2(4000 char) := '';
  v_desc            varchar2(4000 char) := '';
  v_comma           varchar2(1);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(1000 char);
  v_receiver        temploy1.codempid%type;
  v_seqno           tpmasign.seqno%type;
  
  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;
    
  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           qtydayr,dtelast
      from tpmalert
     where codcompy = p_codcompy
       and (   (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '120'
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy =  p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver,seqno;

  cursor c_sendmail is
    select item1 codempid, item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
       and item5 = v_seqno
  order by codempid;
begin
  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno            := i.mailalno;
      v_dteeffec            := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      for i in c_tmailrpm loop
        v_count := v_count + 1;
      end loop;
      if v_count > 0 then
        v_typesend := 'A';
      else
        v_typesend := 'H';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for j in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||j.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||j.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;
      v_cursor := dbms_sql.open_cursor;

      if i.qtydayb is not null then -- Before
         v_stdate := to_char(sysdate,'dd/mm/yyyy');
         v_endate := to_char((sysdate) + i.qtydayb,'dd/mm/yyyy');
         v_where  := ' and ttmovemt.dteeffec = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        v_where  := v_where||' and  (' ||i.syncond|| ') ';
      end if;

      V_STMENT := 'select temploy1.codempid
                     from temploy1, ttmovemt, tcodmove
                    where temploy1.codempid = ttmovemt.codempid
                      and ttmovemt.codtrn = tcodmove.codcodec
                      and tcodmove.typmove = ''M''
                      and ttmovemt.staupd in (''C'',''U'')
                      and temploy1.codcomp like '''|| p_codcompy ||'%''
                      and ttmovemt.codposnow <> ttmovemt.codpos ' ||V_WHERE|| ' order by temploy1.codempid';

      commit;
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..1 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;
      v_dummy := dbms_sql.execute(v_cursor);
      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..1 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        V_COUNT    := 0;
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit;   

        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,null,null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
--              hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,'codempid = '''||v_codempid||'''',v_seq,i.typemail);
            end if;
          else
            sendmail_alert(p_codcompy,v_codempid,i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,null,v_typesend);
          end if;
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,null,null,null,null,null,null,null);
          end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert 
           set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;

      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' codempid = '''||i.codempid||''' ',v_numseq,120);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
    end if;
  end loop;
end; -- gen_congratpos
--

procedure gen_congratnewemp  (p_codcompy  in varchar2,
                        flg_log     in varchar2,
                        p_mailalno  in varchar2,
                        p_dteeffec  in date) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          clob;
  v_statment        clob;
  v_where           clob;
  v_data_file       varchar2(2500);
  v_codempid        temploy1.codempid%type;
  v_codempid2       temploy1.codempid%type;
  v_count           number;

  v_mailalno        tpmalert.mailalno%type;
  v_dteeffec        tpmalert.dteeffec%type;
  v_stdate          varchar2(30);
  v_endate          varchar2(30);
  v_typesend        varchar2(1);
  v_testsend        varchar2(1) := 'N';

  v_seq             number := 0;
  v_numseq          number := 0;
  v_sql             clob;
  v_label           varchar2(4000 char) := '';
  v_item            varchar2(4000 char) := '';
  v_desc            varchar2(4000 char) := '';
  v_comma           varchar2(1);
  v_datachg         varchar2(1) := 'N';
  v_codsend         temploy1.codempid%type;
  v_filename        varchar2(1000 char);
  v_receiver        temploy1.codempid%type;
  v_seqno           tpmasign.seqno%type;

  type descol is table of varchar2(2500) index by binary_integer;
    data_file    descol;

  cursor c_tpmalert is
    select codcompy,mailalno,dteeffec,syncond,codsend,typemail,
           message,subject,qtydayb,
           qtydayr,dtelast
      from tpmalert
     where codcompy = p_codcompy
       and ( (flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
             or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec) )
       and typemail = '130'
  order by mailalno;

  cursor c_tmailrpm is
    select pfield,pdesct
      from tmailrpm
     where codcompy =  p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_tpmasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from tpmasign
     where codcompy = p_codcompy
       and mailalno = v_mailalno
	   and dteeffec = v_dteeffec
  order by seqno;

  cursor c_receiver is
    select item1 receiver, to_number(item8) seqno
      from ttemprpt
     where codempid = p_coduser
       and codapp = p_codapp_receiver
  group by item1, to_number(item8)
  order by item1;

  cursor c_group_sendmail is
    select distinct item4 receiver, 
           item5 seqno
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
  order by receiver,seqno;

  cursor c_sendmail is
    select item1 codempid, item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
       and item5 = v_seqno
  order by codempid;
begin

  for i in c_tpmalert loop
    v_codsend := i.codsend;
    if p_dteeffec is not null then
      v_testsend := 'Y';
    else
      if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
        v_testsend := 'Y';
      end if;
    end if;
    if v_testsend = 'Y' then
      v_mailalno            := i.mailalno;
      v_dteeffec            := i.dteeffec;
      p_codapp              := i.codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
      p_codapp_receiver     := p_codapp||'_R';
      p_codapp_file         := p_codapp||'_X';
      
      delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp;
      delete ttempprm where codempid = 'AUTO' and codapp = p_codapp_file;
      commit;
      
      v_seq      := 0;
      v_numseq   := 0;
      v_count    := 0;
      v_statment := null;
      v_label    := null;
      v_item     := null;
      v_desc     := null;
      v_comma    := '';

      for j in c_tmailrpm loop
        v_count := v_count + 1;
      end loop;
      if v_count > 0 then
        v_typesend := 'A';
      else
        v_typesend := 'H';
      end if;
      v_count    := 0;
      if v_typesend = 'A' then
        for k in c_tmailrpm loop
          v_numseq   := v_numseq +1;
          v_statment := v_statment||v_comma||k.pfield;
          v_label    := v_label||v_comma||'label'||v_numseq;
          v_item     := v_item||v_comma||'item'||v_numseq;
          v_desc     := v_desc||v_comma||''''||k.pdesct||'''';
          v_comma    := ',';
        end loop;
        if v_numseq > 0 then
          v_sql   := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                     ' values (''AUTO'','''||p_codapp_file||''','''||i.subject||''','||'''Date/Time'',''Page No :'','||v_desc||')';
          commit;
          execute immediate v_sql;
        end if;
      end if;
      v_cursor := dbms_sql.open_cursor;

      if i.qtydayb is not null then -- Before
         v_stdate := to_char(sysdate,'dd/mm/yyyy');
         v_endate := to_char((sysdate) + i.qtydayb,'dd/mm/yyyy');
         v_where  := ' and dteempmt = to_date('''||v_endate||''',''dd/mm/yyyy'') ';
      end if;

      if i.syncond is not null then
        v_where  := v_where||' and  (' ||i.syncond|| ') ';
      end if;

      V_STMENT := 'select codempid
                     from temploy1
                    where staemp = 1 and codcomp like '''|| p_codcompy ||'%'' '
                          ||V_WHERE|| ' order by codempid';

      commit;
      dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

      for j in 1..1 loop
        dbms_sql.define_column(v_cursor,j,v_data_file,500);
      end loop;
      v_dummy := dbms_sql.execute(v_cursor);
      loop
        if dbms_sql.fetch_rows(v_cursor) = 0 then
          exit;
        end if;
        for j in 1..1 loop
          dbms_sql.column_value(v_cursor,j,v_data_file);
          data_file(j) := v_data_file;
        end loop;
        v_codempid := data_file(1);
        V_COUNT    := 0;
        
        delete ttemprpt where codapp = p_codapp_receiver and codempid = p_coduser;
        commit;   

        if v_count = 0 then
          v_seq := v_seq + 1;
          if v_typesend = 'A' then
            if v_numseq > 0 then
                for i in c_tpmasign loop
                    if i.flgappr in ('1','3','4') then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                    elsif i.flgappr = '5' then
                        find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                    end if;
                end loop;

                for r_receiver in c_receiver loop
                    insert_temp2(p_coduser,p_codapp,v_codempid,null,null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                end loop;
--              hrpm.gen_file(p_codcompy,i.mailalno,i.dteeffec,'v_temploy.codempid = '''||v_codempid||'''',v_seq,i.typemail);
            end if;
          else
            sendmail_alert(p_codcompy,v_codempid,i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,null,v_typesend);
          end if;
          if flg_log = 'Y' then
            insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,null,null,null,null,null,null,null);
          end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor);

      if flg_log = 'Y' then
        update tpmalert set dtelast = trunc(sysdate)
         where codcompy = p_codcompy
           and mailalno = i.mailalno
           and dteeffec = i.dteeffec;
      end if;

      commit;

      if v_typesend = 'A' then
        for r_group in c_group_sendmail loop
            delete ttemprpt where codempid = 'AUTO' and codapp = p_codapp_file;
            v_numseq    := 0;
            v_receiver  := r_group.receiver;
            v_seqno     := r_group.seqno;
            for i in c_sendmail loop
                v_numseq := v_numseq + 1;
                hrpm.gen_file(p_codcompy,v_mailalno,v_dteeffec,' codempid = '''||i.codempid||''' ',v_numseq,130);
            end loop;
    
            v_filename  := to_char(sysdate,'yyyymmddhh24mi');
            excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
            sendmail_group(p_codcompy, v_receiver,i.mailalno,
                            i.dteeffec,i.codsend,i.typemail,
                            i.message,v_filename,v_typesend,v_seqno);
        end loop;
      end if;
    end if;
  end loop;
end; -- gen_congratnewemp
--
procedure sendmail_alert( p_codcompy  in varchar2,
                          p_codempid  in varchar2,
                          p_mailalno  in varchar2,
                          p_dteeffec  in date,
                          p_codsend   in varchar2,
                          p_typemail  in varchar2,
                          p_message   in clob,
                          p_filname   in varchar2,
                          p_typesend  in varchar2) is
  v_msg_to        clob := p_message;
  v_template_to   clob;
  v_mailtemplt    varchar2(15) := get_tsetup_value('MAILTEMPLT');
  v_codform       varchar2(15);
  v_flgappr       varchar2(1);
  v_filename      varchar2(1000 char) := p_filname;
BEGIN
  /*
  if v_mailtemplt = 'Y' then
    v_codform := 'TEMPLATEPM';
  else
  */
  if p_typemail = '10' then
    if v_mailtemplt = 'Y' then
--      v_codform := 'TEMPLATEHD';
      v_codform := 'TEMPLATEAL';
    else
--      v_codform := 'TEMPLTHBDT';
      v_codform := 'TEMPLATEAL';
    end if;
  else
    v_codform := 'TEMPLATEAL';
--    v_codform := 'TEMPLTPMTT';
    --<< user22 : 04/02/2016 : STA3590210 ||
    begin
      select flgappr  into v_flgappr
        from tpmasign
       where codcompy = p_codcompy
         and mailalno = p_mailalno
         and dteeffec = p_dteeffec
         and flgappr  = '6'
         and rownum   = 1;
      v_codform := 'TEMPLATEAL';
    exception when no_data_found then null;
    end;
    -->> user22 : 04/02/2016 : STA3590210 ||
  end if;
 -- end if;

  begin
    select decode(p_lang,'101',messagee,
                         '102',messaget,
                         '103',message3,
                         '104',message4,
                         '105',message5,
                         '101',messagee) msg
      into v_template_to
      from tfrmmail
     where codform = v_codform;
  exception when others then
    v_template_to := null;
  end;

  if p_typemail = '10' then
    begin
      select get_tsetup_value('BACKEND_URL')||get_tsetup_value('PATHDOC')||'/BirthdayCard/'|| lpad(ROUND(dbms_random.value(1,18)),2,'0')||'.gif'
        into v_filename -- image
        from dual;
    end;
  end if;
  replace_text_sendmail(v_msg_to,v_template_to,p_codempid,p_codsend,p_codcompy,p_mailalno,p_dteeffec,p_typemail,p_typesend);
  auto_execute_mail(p_codcompy,p_mailalno,p_dteeffec,p_codempid,v_msg_to,p_typemail,v_filename,p_typesend);

end;--sendmail_alert


procedure sendmail_group( p_codcompy  in varchar2,
                          p_codempid  in varchar2,
                          p_mailalno  in varchar2,
                          p_dteeffec  in date,
                          p_codsend   in varchar2,
                          p_typemail  in varchar2,
                          p_message   in varchar2,
                          p_filname   in varchar2,
                          p_typesend  in varchar2,
                          p_seqno     in number) is
  v_msg_to        clob := p_message;
  v_template_to   clob;
  v_mailtemplt    varchar2(15) := get_tsetup_value('MAILTEMPLT');
  v_codform       varchar2(15);
  v_flgappr       varchar2(1);
  v_filename      varchar2(1000 char) := p_filname;
BEGIN
    v_codform := 'TEMPLATEAL';
    begin
        select decode(p_lang,'101',messagee,
                             '102',messaget,
                             '103',message3,
                             '104',message4,
                             '105',message5,
                             '101',messagee) msg
          into v_template_to
          from tfrmmail
         where codform = v_codform;
    exception when others then
        v_template_to := null;
    end;
    replace_text_sendmail(v_msg_to,v_template_to,p_codempid,p_codsend,p_codcompy,p_mailalno,p_dteeffec,p_typemail,p_typesend);
    auto_execute_mail_group(p_codcompy,p_mailalno,p_dteeffec,p_codempid,v_msg_to,p_typemail,v_filename,p_typesend,p_seqno);
end;--sendmail_alert

 
procedure replace_text_sendmail( p_msg       in out clob,
                               p_template  in clob,
                               p_codempid  in varchar2,
                               p_codsend   in varchar2,
                               p_codcompy  in varchar2,
                               p_mailalno  in varchar2,
                               p_dteeffec  in date,
                               p_typemail  in varchar2,
                               p_typesend  in varchar2) is

  data_file     clob;
  crlf          varchar2( 2 ):= chr( 13 ) || chr( 10 );
  v_message     clob;
  v_template    clob;
  v_codpos      varchar2(4);
  v_cursor      number;
  v_dummy       integer;
  v_stment      varchar2(2000);
  v_where       varchar2(2000);
  v_data_file   varchar2(2500);
  v_codempid    varchar2(10);
  v_funcdesc    varchar2(100);
  v_msg         long;
  v_data_msg    long;
  v_headmag     long := null;
  v_mailtemplt  varchar2(15) := get_tsetup_value('MAILTEMPLT');

  type descol is table of varchar2(2500) index by binary_integer;
    data_files  descol;

  cursor c_tpmparam is
    select mailalno,numseq,codtable,fparam,ffield,descript,flgdesc
      from tpmparam
     where codcompy = p_codcompy
       and mailalno = p_mailalno
       and dteeffec = p_dteeffec
  order by fparam;

begin
  begin
    select codpos into v_codpos
      from temploy1
     where codempid = p_codsend;
  exception when no_data_found then
    v_codpos := null;
  end;

  v_message   := p_msg;
  v_template  := p_template;

  --<<user36 STA3590309 09/09/2016
--  if v_mailtemplt = 'Y' then
--    v_message   := replace(v_template,'[P_MESSAGE]', replace(replace(v_message,chr(10),'<br>'),' ',';'));
--    v_message   := replace(replace(v_message,chr(10),'<br>'),' ',';');
--  else
    v_message   := replace(v_template,'[P_MESSAGE]',v_message);
    v_message   := replace(v_message,chr(10),'<br>');
--  end if;

  data_file := v_message;
  if p_typesend in ('H','E','N') or p_typemail in ('120','130') then
    if data_file is not null then
      for i in c_tpmparam loop
        v_cursor := dbms_sql.open_cursor;
        v_stment := 'select ' ||i.ffield|| ' from ' ||i.codtable|| ' '||
                   ' where codempid = '''||p_codempid||''' ';
        dbms_sql.parse(v_cursor,v_stment,dbms_sql.native);

        for j in 1..1 loop
          dbms_sql.define_column(v_cursor,j,v_data_file,500);
        end loop;

        v_dummy := dbms_sql.execute(v_cursor);

        loop
          if dbms_sql.fetch_rows(v_cursor) = 0 then
            exit;
          end if;
          for j in 1..1 loop
            dbms_sql.column_value(v_cursor,j,v_data_file);
            data_files(j) := v_data_file;
          end loop;
          if i.flgdesc = 'Y' then
            begin
              select funcdesc into v_funcdesc
                from tcoldesc
               where codtable = i.codtable
                 and codcolmn = i.ffield;
            exception when no_data_found then
              v_funcdesc := null;
            end;
            v_msg := v_funcdesc;
            v_msg := replace(v_msg,'P_CODE',''''||data_files(1)||'''');
            v_msg := replace(v_msg,'P_LANG',p_lang);
            v_msg := 'select '||v_msg||' from dual ';
            v_data_msg := execute_desc(v_msg);

            data_file  := replace(data_file ,i.fparam,v_data_msg);
          else
            data_file  := replace(data_file ,i.fparam,data_files(1));
          end if;
        end loop;
        dbms_sql.close_cursor(v_cursor);
      end loop;
    end if;
  end if;

  if data_file like ('%[PARA_FROM]%') then
    data_file  := replace(data_file  ,'[PARA_FROM]', get_temploy_name(p_codsend,p_lang));
  end if;
  if data_file like ('%[PARA_POSITION]%') then
    data_file  := replace(data_file  ,'[PARA_POSITION]',get_tpostn_name(v_codpos,p_lang));
  end if;
  p_msg := v_headmag||crlf||data_file;

end; -- Function replace_text_sendmail
--
procedure gen_conditions  (p_codempid  in varchar2,
                           p_codapp    in varchar2,
                           p_subject   in varchar2,
                           p_numdatets in out number,
                           p_numdatinf in out number,
                           p_numdatpay in out number,
                           p_numdatdet in out number) is


  v_unit	      varchar2(10 char);
  v_descunit	  varchar2(100 char);
  v_numseqets   number := 0;
  v_numseqinf   number := 0;
  v_numseqpay   number := 0;
  v_numseqdet   number := 0;
  v_codempid    temploy1.codempid%type;
  v_count       number := 0;
  v_dtestrpm    varchar2(100 char);
  v_dtelstpay   varchar2(100 char);
  v_zyear       number;
  v_namscoe     varchar2(100 char);
  v_numdata     number;

  cursor  c_tassets is
    select codasset,0 as qtyrcass,--qtyrcass,#########################
           dtercass
      from tassets
     where codempid	=	p_codempid
--       and nvl(qtyrcass,0)	>	nvl(qtyrtass,0) ###########################
       ;

  cursor c_tloaninf is
    select dtelonst,numcont,amtlon,amtnpfin,dteaccls,codlon,numlon
      from tloaninf
     where codempid	= p_codempid
       and amtnpfin > 0
       and staappr  = 'Y';

  cursor c_trepay is
    select a.codempid,b.codcomp,b.numlvl,
           a.amttotpay,a.amtoutstd,a.amtrepaym,
           a.qtyrepaym,a.dtestrpm,a.dtelstpay,b.typemp
      from trepay a,temploy1 b
     where a.codempid = b.codempid
       and a.amtoutstd > 0
       and a.codempid = p_codempid
       and a.dteappr = (select max(dteappr)
                          from trepay c
                         where c.codempid = a.codempid );


--  cursor c_tfunddet is
--    select codempid,codsco,desccomm,dtecomm
--      from tfunddet
--     where codempid = p_codempid
--       and dtecomm  >= sysdate
--    order  by  codsco;

	cursor c_thistrnn is
    select distinct  a.codempid,a.dtetren,b.codcours,b.descommt,b.flgcommt
      from thistrnn a,tcourse b
     where a.codempid   = p_codempid
       and a.codcours   = b.codcours
       and b.flgcommt   = 'Y'
       and a.dtecntr	  >= sysdate
    order by b.codcours;

begin
  v_zyear := pdk.check_year(p_lang);
  for r_tassets in c_tassets loop
    begin
      select max(nvl(numseq,0)) into v_numseqets
        from ttemprpt
       where codempid = 'AUTO'
         and codapp   = p_codapp||'C1';
      v_numseqets := v_numseqets + 1;
    exception when no_data_found then
      v_numseqets := 1;
    end;
    if nvl(v_numseqets,0) = 0 then
      v_numseqets := 1;
    end if;
--    begin ################################
--      select codunit	into	v_unit
--        from tasetinf
--       where codasset	=	r_tassets.codasset;
--      v_descunit := get_tcodunit_name(v_unit,p_lang);
--    exception when no_data_found then
--      v_unit := null;
--    end;
    v_codempid := null;
    if v_numseqets = 1 then
      v_codempid := p_codempid;
    end if;

    insert into ttemprpt (codempid,codapp,numseq,
                          item1,item2,item3,
                          item4,item5,item6)
                  values('AUTO',p_codapp||'C1',v_numseqets,
                         v_codempid,r_tassets.codasset,get_tasetinf_name(r_tassets.codasset,p_lang),
                         r_tassets.qtyrcass,v_descunit,to_char(r_tassets.dtercass,'dd/mm/yyyy'));
  end loop;
  if nvl(v_numseqets,0) <= 1 then
    v_count := 0;
    begin
      select count(*) into v_count
        from ttempprm
       where codempid = 'AUTO'
         and codapp   = p_codapp||'C1';
    exception when no_data_found then
      v_count := 0;
    end;
    if v_count = 0 then
      insert into ttempprm (codempid,codapp,namrep,pdate,ppage,
                            label1,label2,label3,
                            label4,label5,label6)
           values          ('AUTO',p_codapp||'C1',p_subject,'Date/Time','Page No :',
                            get_label_name('PM4IEPOP1',p_lang,20),get_label_name('PM4IEPOP1',p_lang,30),get_label_name('PM4IEPOP1',p_lang,40),
                            get_label_name('PM4IEPOP1',p_lang,50),get_label_name('PM4IEPOP1',p_lang,60),get_label_name('PM4IEPOP1',p_lang,70));
    end if;
  end if;
  ------------------------------------------------------------------------------
  for r_tloaninf in c_tloaninf loop
    begin
      select max(nvl(numseq,0)) into v_numseqinf
        from ttemprpt
       where codempid = 'AUTO'
         and codapp   = p_codapp||'C2';
      v_numseqinf := v_numseqinf + 1;
    exception when no_data_found then
      v_numseqinf := 1;
    end;
    v_codempid := null;
    if v_numseqinf = 1 then
      v_codempid := p_codempid;
    end if;

    insert into ttemprpt (codempid,codapp,numseq,
                          item1,item2,item3,
                          item4,item5,item6,
                          item7,item8)
                  values('AUTO',p_codapp||'C2',v_numseqinf,
                         v_codempid,to_char(r_tloaninf.dtelonst,'dd/mm/yyyy'),r_tloaninf.numcont,
                         to_char(r_tloaninf.amtlon,'fm9,999,990.00'),to_char(r_tloaninf.amtnpfin,'fm9,999,990.00'),to_char(r_tloaninf.dteaccls,'dd/mm/yyyy'),
                         get_ttyploan_name(r_tloaninf.codlon,p_lang),r_tloaninf.numlon);

  end loop;

  if nvl(v_numseqinf,0) <= 1 then
    v_count := 0;
    begin
      select count(*) into v_count
        from ttempprm
       where codempid = 'AUTO'
         and codapp   = p_codapp||'C2';
    exception when no_data_found then
      v_count := 0;
    end;
    if v_count = 0 then
      insert into ttempprm (codempid,codapp,namrep,pdate,ppage,
                            label1,label2,label3,
                            label4,label5,label6,
                            label7,label8)
           values          ('AUTO',p_codapp||'C2',p_subject,'Date/Time','Page No :',
                            get_label_name('PM4IEPOP2',p_lang,20),get_label_name('PM4IEPOP2',p_lang,30),get_label_name('PM4IEPOP2',p_lang,40),
                            get_label_name('PM4IEPOP2',p_lang,50),get_label_name('PM4IEPOP2',p_lang,60),get_label_name('PM4IEPOP2',p_lang,70),
                            get_label_name('PM4IEPOP2',p_lang,80),get_label_name('PM4IEPOP2',p_lang,90));
    end if;
  end if;
  ------------------------------------------------------------------------------
  for r_trepay in c_trepay loop
    begin
      select max(nvl(numseq,0)) into v_numseqpay
        from ttemprpt
       where codempid = 'AUTO'
         and codapp   = p_codapp||'C3';
      v_numseqpay := v_numseqpay + 1;
    exception when no_data_found then
      v_numseqpay := 1;
    end;
    v_codempid := null;
    if v_numseqpay = 1 then
      v_codempid := p_codempid;
    end if;
    if r_trepay.dtestrpm is not null then
      v_dtestrpm := substr(r_trepay.dtestrpm,7)||'/'||substr(r_trepay.dtestrpm,5,2)||'/'||to_char(to_number(substr(r_trepay.dtestrpm,1,4)) + v_zyear);
    end if;
		if r_trepay.dtelstpay is not null then
			v_dtelstpay	:=	substr(r_trepay.dtelstpay,7)||'/'||substr(r_trepay.dtelstpay,5,2)||'/'||to_char(to_number(substr(r_trepay.dtelstpay,1,4)) + v_zyear);
		end if;
    insert into ttemprpt (codempid,codapp,numseq,
                          item1,item2,item3,
                          item4,item5,item6,
                          item7,item8)
                  values('AUTO',p_codapp||'C3',v_numseqpay,
                         v_codempid,to_char(r_trepay.amtrepaym,'fm9,999,990.00'),r_trepay.qtyrepaym,
                         v_dtestrpm,to_char(nvl(r_trepay.amttotpay,0) + nvl(r_trepay.amtoutstd,0),'fm9,999,990.00'),to_char(r_trepay.amttotpay,'fm9,999,990.00'),
                         to_char(r_trepay.amtoutstd,'fm9,999,990.00'),v_dtelstpay);

  end loop;

  if nvl(v_numseqpay,0) <= 1 then
    v_count := 0;
    begin
      select count(*) into v_count
        from ttempprm
       where codempid = 'AUTO'
         and codapp   = p_codapp||'C3';
    exception when no_data_found then
      v_count := 0;
    end;
    if v_count = 0 then
      insert into ttempprm (codempid,codapp,namrep,pdate,ppage,
                            label1,label2,label3,
                            label4,label5,label6,
                            label7,label8)
           values          ('AUTO',p_codapp||'C3',p_subject,'Date/Time','Page No :',
                            get_label_name('PM4IEPOP3',p_lang,20),get_label_name('PM4IEPOP3',p_lang,30),get_label_name('PM4IEPOP3',p_lang,40),
                            get_label_name('PM4IEPOP3',p_lang,50),get_label_name('PM4IEPOP3',p_lang,60),get_label_name('PM4IEPOP3',p_lang,70),
                            get_label_name('PM4IEPOP3',p_lang,80),get_label_name('PM4IEPOP3',p_lang,90));
    end if;
  end if;
  ------------------------------------------------------------------------------
--  for r_tfunddet in c_tfunddet loop
--    begin
--      select max(nvl(numseq,0)) into v_numseqdet
--        from ttemprpt
--       where codempid = 'AUTO'
--         and codapp   = p_codapp||'C4';
--      v_numseqdet := v_numseqdet + 1;
--    exception when no_data_found then
--      v_numseqdet := 1;
--    end;
--    v_codempid := null;
--    if v_numseqdet = 1 then
--      v_codempid := p_codempid;
--    end if;
--
--    begin
--      select codsco||' '||decode(p_lang,'101',namscoe,
--                                        '102',namscot,
--                                        '103',namsco3,
--                                        '104',namsco4,
--                                        '105',namsco5,namscoe)
--        into v_namscoe
--        from tfundinf
--       where codsco  = r_tfunddet.codsco
--         and rownum <= 1;
--    exception when no_data_found  then
--      v_namscoe := null;
--    end;
--
--    insert into ttemprpt (codempid,codapp,numseq,
--                          item1,item2,item3,
--                          item4)
--                  values('AUTO',p_codapp||'C4',v_numseqdet,
--                         v_codempid,v_namscoe,r_tfunddet.desccomm,
--                         to_char(r_tfunddet.dtecomm,'dd/mm/yyyy'));
--  end loop;

  for r_thistrnn in c_thistrnn loop
    begin
      select max(nvl(numseq,0)) into v_numseqdet
        from ttemprpt
       where codempid = 'AUTO'
         and codapp   = p_codapp||'C4';
      v_numseqdet := v_numseqdet + 1;
    exception when no_data_found then
      v_numseqdet := 1;
    end;
    v_codempid := null;
    if v_numseqdet = 1 then
      v_codempid := p_codempid;
    end if;
    v_namscoe := r_thistrnn.codcours||' '||get_tcourse_name(r_thistrnn.codcours,p_lang);
    insert into ttemprpt (codempid,codapp,numseq,
                          item1,item2,item3,
                          item4)
                  values('AUTO',p_codapp||'C4',v_numseqdet,
                         v_codempid,v_namscoe,r_thistrnn.descommt,
                         to_char(r_thistrnn.dtetren,'dd/mm/yyyy'));
  end loop;

  if nvl(v_numseqdet,0) <= 1 then
    v_count := 0;
    begin
      select count(*) into v_count
        from ttempprm
       where codempid = 'AUTO'
         and codapp   = p_codapp||'C4';
    exception when no_data_found then
      v_count := 0;
    end;
    if v_count = 0 then
      insert into ttempprm (codempid,codapp,namrep,pdate,ppage,
                            label1,label2,label3,
                            label4)
           values          ('AUTO',p_codapp||'C4',p_subject,'Date/Time','Page No :',
                            get_label_name('PM4IEPOP4',p_lang,20),get_label_name('PM4IEPOP4',p_lang,30),get_label_name('PM4IEPOP4',p_lang,40),
                            get_label_name('PM4IEPOP4',p_lang,50));
    end if;
  end if;
  commit;

  p_numdatets := nvl(p_numdatets,0) + nvl(v_numseqets,0);
  p_numdatinf := nvl(p_numdatinf,0) + nvl(v_numseqinf,0);
  p_numdatpay := nvl(p_numdatpay,0) + nvl(v_numseqpay,0);
  p_numdatdet := nvl(p_numdatdet,0) + nvl(v_numseqdet,0);

end;

procedure auto_execute_mail (p_codcompy in varchar2,
                             p_mailalno   in varchar2,
                             p_dteeffec   in date,
                             p_codempid   in varchar2,
                             p_msg_to     in clob,
                             p_typemail   in varchar2,
                             p_file       in varchar2,
                             p_typesend   in varchar2) is
  v_msg           clob;
  v_error         clob;
  v_coduser       varchar2(10) := 'AUTOPM2';
  v_codempap      temploy1.codempid%type;
  v_codcompap     tcenter.codcomp%type;
  v_codposap      tpostn.codpos%type;
  v_temp          varchar2(500);
  v_codempid      temploy1.codempid%type;
  v_codcomp       tcenter.codcomp%type;
  v_codpos        tpostn.codpos%type;
  v_codcompemp    tcenter.codcomp%type;
  v_codposemp     tpostn.codpos%type;
  v_codcompr      tcenter.codcomp%type;
  v_codposre      tpostn.codpos%type;
  v_email         varchar2(100);
  v_sender_email  varchar2(100);
  v_tpmalert      tpmalert%rowtype;
  v_pos0          varchar2(200 char);
  v_pos1          varchar2(200 char);
  v_pos2          varchar2(200 char);
  v_pos3          varchar2(200 char);
  v_pos4          varchar2(200 char);
  v_pos5          varchar2(200 char);
  v_tempfile1     varchar2(500);
  v_tempfile2     varchar2(500);
  v_tempfile3     varchar2(500);
  v_tempfile4     varchar2(500);
  v_tempfile5     varchar2(500);
  v_typproba      varchar2(1 char);
	v_http          varchar2(1000);
	v_codusr				varchar2(100);

	cursor c_tpmasign  is
	  select seqno,flgappr,codcompap,codposap,codempap,message
	    from tpmasign
	   where codcompy = p_codcompy
         and mailalno = p_mailalno
	     and dteeffec = p_dteeffec
  order by seqno;
  --
	cursor c_asign is
		select codcomp,codpos,codempid
		  from tproasgh
	   where v_codcomp   like codcomp
	     and v_codpos    like codpos
	     and p_codempid  like codempid
         and typproba = v_typproba
  order by codempid desc,codcomp desc;

	cursor c_tproasgn is
		select numseq,flgappr,codcompap,codposap,codempap
		  from tproasgn
	   where codcomp   = v_codcompemp
	     and codpos    = v_codposemp
	     and codempid  = v_codempid
         and typproba = v_typproba
    order by  numseq  ;
  --
  cursor c_receiver is
    select item1 receiver
      from ttemprpt2
     where codempid = v_coduser
       and codapp   = p_codapp
  group by item1
  order by item1;
 v_item  varchar2(500) := 'item1,item2,item3,item4,item5';
  v_label varchar2(500) := 'label1,label2,label3,label4,label5';
begin
  begin
    select codcomp,codpos,email
      into v_codcomp,v_codpos,v_email
      from temploy1
     where codempid = p_codempid;
  exception when no_data_found then
    null;
  end;
  
  --
  if p_typemail in (20,22,24) then
    v_typproba :=  '1';
  elsif p_typemail in (40,42,44) then
    v_typproba :=  '2';
  end if;

  
  select * into v_tpmalert
     from tpmalert
    where codcompy = p_codcompy
      and mailalno = p_mailalno
      and dteeffec = p_dteeffec;
  --<<user36 STA3590309 09/09/2016
  begin
    select email into v_sender_email
      from temploy1
     where codempid = v_tpmalert.codsend;
  exception when no_data_found then
    v_sender_email := null;
  end;
  if v_sender_email is null then
    v_sender_email := get_tsetup_value('MAILEMAIL');
  end if;
  if p_typesend = 'N' then
    v_temp := null;
  else
    v_temp := get_tsetup_value('PATHEXCEL')||p_file;
  end if;
  -->>user36 STA3590309 09/09/2016
  if p_typemail <> '10' then --<> HBD
    for i in c_tpmasign loop
      delete ttemprpt2 where codapp = p_codapp and codempid = v_coduser;
      commit;
      --
      if i.flgappr in ('1','2','3','4','5') then
        gen_approve.find_approve_name(p_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp,v_coduser,p_codempid); --user36 STA3590309 12/09/2016
        --
--<< user22 : 04/02/2016 : STA3590210 ||
      elsif i.flgappr = '6' then
      
        for i in c_asign loop
          v_codcompemp   := i.codcomp;
          v_codposemp    := i.codpos;
          v_codempid     := i.codempid;
          exit;
        end loop; --c_asign

        for j in c_tproasgn loop
            if j.flgappr = '1' then
                gen_approve.find_approve_name(p_codempid,j.numseq,'1',j.codempap,j.codcompap,j.codposap,p_codapp,v_coduser,p_codempid); --user36 STA3590309 12/09/2016
            elsif j.flgappr = '2' then
                gen_approve.find_approve_name(p_codempid,j.numseq,'3',j.codempap,j.codcompap,j.codposap,p_codapp,v_coduser,p_codempid); --user36 STA3590309 12/09/2016
            elsif j.flgappr = '3' then
                gen_approve.find_approve_name(p_codempid,j.numseq,'4',j.codempap,j.codcompap,j.codposap,p_codapp,v_coduser,p_codempid); --user36 STA3590309 12/09/2016
            end if;
          --
        end loop; --c_tproasgn
-->> user22 : 04/02/2016 : STA3590210 ||
      end if;  --if i.flgappr in ('1','2','3','4','5') then
      --
      for j in c_receiver loop

        begin
          select email into v_email
            from temploy1
           where codempid = j.receiver;
        exception when no_data_found then
          v_email := null;
        end;
        if v_email is not null then
--<< user22 : 04/02/2016 : STA3590210 ||
          v_http := get_tsetup_value('LINKFORM');
          v_http := replace(v_http ,'<P_CODAPP>','HRMS31E');
          begin
            select coduser into v_codusr
              from tusrprof
             where codempid = j.receiver
               and rownum   = 1;
          exception when no_data_found then null;
          end;
          v_http := replace(v_http ,'<P_CODUSER>',v_codusr);
          v_http := replace(v_http ,'<P_LANG>',p_lang);
          v_msg  := p_msg_to;
          v_msg  := replace(v_msg ,'[P_OTHERMSG]',i.message);
          if p_lang = '102' then
            v_msg   := replace(v_msg ,'[P_HTTP]','<a href='||v_http||'>?????</a>');
          else
            v_msg   := replace(v_msg ,'[P_HTTP]','<a href='||v_http||'>Approve</a>');
          end if;
-->> user22 : 04/02/2016 : STA3590210 || +

          v_msg   := replace(v_msg ,'<PARAM1>', get_temploy_name(j.receiver,p_lang));
          if p_typesend in ( 'E' ,'H') then
            v_error := SendMail_AttachFile(v_sender_email,v_email,v_tpmalert.subject,v_msg,null,null,null,null,null);
          else
            if p_typemail = '60' then
              if p_file  is not null and  p_file <> '*@-_.' then
                v_tempfile1  := get_tsetup_value('PATHEXCEL')||p_file ||'.xls'; --user36 STA3590309 13/09/2016 cancel '_auto' in .xls name  ||v_tempfile1||'_auto'||'.xls'
              end if;
              v_error := SendMail_AttachFile(v_sender_email,v_email,v_tpmalert.subject,v_msg,v_tempfile1,v_tempfile2,v_tempfile3,v_tempfile4,v_tempfile5);
            else

                v_error := SendMail_AttachFile(v_sender_email,v_email,v_tpmalert.subject,v_msg,v_temp,null,null,null,null,null,null,'Oracle');
            end if;
          end if;
        end if;
      end loop; --c_receiver loop
    end loop; --c_tpmasign

  else --= HBD
    v_msg      := p_msg_to;
    v_msg      := replace(v_msg ,'[P_OTHERMSG]',null);
    v_msg      := replace(v_msg ,'<PARAM1>', get_temploy_name(p_codempid,p_lang));
    v_msg      := replace(v_msg ,'[PARAM1]', get_temploy_name(p_codempid,p_lang));
    begin
--      v_error  := sendmail_attachfile(v_sender_email,v_email,v_tpmalert.subject,v_msg,'https://www.aws-test.peopleplus.co.th/static/image/icon/process.gif',null,null,null,null); --user32 STA4610019 06/03/2018
      v_error  := sendmail_attachfile(v_sender_email,v_email,v_tpmalert.subject,v_msg,p_file,null,null,null,null); --user32 STA4610019 06/03/2018
--    v_error  := SendMail_AttachFile(v_sender_email,v_email,v_tpmalert.subject,v_msg,null,null,null,null,null); --user36 STA3590309 09/09/2016
    exception when others then
      null;
    end;
  end if;

end; --auto_execute_mail


procedure auto_execute_mail_group (p_codcompy in varchar2,
                             p_mailalno   in varchar2,
                             p_dteeffec   in date,
                             p_codempid   in varchar2,
                             p_msg_to     in clob,
                             p_typemail   in varchar2,
                             p_file       in varchar2,
                             p_typesend   in varchar2,
                             p_seqno      in number) is
  v_msg             clob;
  v_error           varchar2(4000 char);
  v_temp            varchar2(500);
  v_email           temploy1.email%type;
  v_sender_email    temploy1.email%type;
  v_tpmalert        tpmalert%rowtype;
  v_http            varchar2(1000);
  v_codusr	        tusrprof.coduser%type;
  v_othmessage      tpmasign.message%type;

	cursor c_tpmasign  is
        select message
          from tpmasign
         where codcompy = p_codcompy
           and mailalno = p_mailalno
           and dteeffec = p_dteeffec
           and seqno = p_seqno;

begin
    begin
        select *
          into v_tpmalert
          from tpmalert
         where codcompy = p_codcompy
           and mailalno = p_mailalno
           and dteeffec = p_dteeffec;
    exception when others then
        v_tpmalert := null;
    end;  
    
    begin
        select message
          into v_othmessage
          from tpmasign
         where codcompy = p_codcompy
           and mailalno = p_mailalno
           and dteeffec = p_dteeffec
           and seqno = p_seqno;    
    exception when others then
        v_othmessage := null;
    end;
       
    begin
        select email
          into v_sender_email
          from temploy1
         where codempid = v_tpmalert.codsend;
    exception when no_data_found then
        v_sender_email := null;
    end;

    if v_sender_email is null then
        v_sender_email := get_tsetup_value('MAILEMAIL');
    end if;

    if p_typesend = 'N' then
        v_temp := null;
    else
        v_temp := get_tsetup_value('PATHEXCEL')||p_file;
    end if;

    begin
        select email
          into v_email
          from temploy1
         where codempid = p_codempid;
    exception when no_data_found then
        v_email := null;
    end;

    if v_email is not null then
        v_http := get_tsetup_value('LINKFORM');
        v_http := replace(v_http ,'[P_CODAPP]','HRMS31E');
        begin
            select coduser into v_codusr
              from tusrprof
             where codempid = p_codempid
               and rownum = 1;
        exception when no_data_found then
            null;
        end;
        v_http := replace(v_http ,'[P_CODUSER]',v_codusr);
        v_http := replace(v_http ,'[P_LANG]',p_lang);
        v_msg  := p_msg_to;
        v_msg  := replace(v_msg ,'[P_OTHERMSG]',v_othmessage);
        v_msg   := replace(v_msg ,'[P_HTTP]','<a href='||v_http||'>'||get_label_name('SCRLABEL',p_lang,2140)||'</a>');
        v_msg   := replace(v_msg ,'[PARAM1]', get_temploy_name(p_codempid,p_lang));
        v_msg   := replace(v_msg ,'<PARAM1>', get_temploy_name(p_codempid,p_lang));
        if p_typesend in ( 'E' ,'H') then
            v_error := SendMail_AttachFile(v_sender_email,v_email,v_tpmalert.subject,v_msg,null,null,null,null,null);
        else
            v_error := SendMail_AttachFile(v_sender_email,v_email,v_tpmalert.subject,v_msg,v_temp,null,null,null,null,null,null,'Oracle');
        end if;
    end if;
end; --auto_execute_mail_group

procedure insert_talertlog (p_codcompy  in varchar2,
                            p_mailalno  in varchar2,
                            p_dteeffec  in date,
                            p_fieldc1   in varchar2,
                            p_fieldc2   in varchar2,
                            p_fieldc3   in varchar2,
                            p_fieldc4   in varchar2,
                            p_fieldc5   in varchar2,
                            p_fieldd1   in date,
                            p_fieldd2   in date,
                            p_fieldd3   in date) is

  v_numseq    number := 0;

begin

  begin
    select max(numseq) into v_numseq
      from talertlog
     where codapp   = 'HRPMATE'
       and codcompy = p_codcompy
       and mailalno = p_mailalno
       and dteeffec = p_dteeffec;
     v_numseq := nvl(v_numseq,0) + 1;
  exception when no_data_found then
    v_numseq := 1;
  end;

  insert into talertlog (
                        codapp,codcompy,mailalno,dteeffec,
                        numseq,dtesend,fieldc1,
                        fieldc2,fieldc3,fieldc4,
                        fieldc5,fieldd1,fieldd2,
                        fieldd3,coduser
                        )
         values        (
                        'HRPMATE',p_codcompy,p_mailalno,p_dteeffec,
                        v_numseq,sysdate,p_fieldc1,
                        p_fieldc2,p_fieldc3,p_fieldc4,
                        p_fieldc5,p_fieldd1,p_fieldd2,
                        p_fieldd3,p_coduser
                        );
  commit;
end;---insert_talertlog


procedure find_approve_name(p_codempid    in varchar2,    --EMPLOYEE for find all approver( or CODAPMAN from pre-seqno in AP)
                            p_seqno       in number,
                            p_flgappr     in varchar2,
                            p_codempap    in varchar2,
                            p_codcompap   in varchar2,
                            p_codposap    in varchar2,
                            p_codapp      in varchar2,
                            p_coduser     in varchar2,
                            p_stcodempid  in varchar2) is --EMPLOYEE for find all approver

  v_codempap        temploy1.codempid%type;
	v_codcompap       temploy1.codcomp%type;
  v_codposap        temploy1.codpos%type;
	v_codcomp         temploy1.codcomp%type;
  v_codpos          temploy1.codpos%type;

  v_codcompy        varchar2(10);
  v_codlinef        varchar2(4);
  v_dteeffec        date;
  v_pageno          number;
  v_rowno           number;
  v_columnno        number;
  v_torgprt         varchar2(1) := 'N';
  v_setorg2         varchar2(1) := 'N';
  v_staemp          varchar2(1);
  v_flgasem         varchar2(1);
  v_flag						varchar2(1);

  cursor c_temphead1 is
    select replace(codempidh,'%',null) codempidh,
           replace(codcomph,'%',null) codcomph,
           replace(codposh,'%',null) codposh
      from temphead
     where codempid = p_codempid
  order by codempidh;

  cursor c_temphead2 is
    select replace(codempidh,'%',null) codempidh,
           replace(codcomph,'%',null) codcomph,
           replace(codposh,'%',null) codposh
      from temphead
     where codcomp  = v_codcomp
       and codpos   = v_codpos
  order by codcomph,codposh;
  --
	cursor c_codapman is
	  select codempid from (select codempid
	                          from temploy1
	        								 where codcomp  like v_codcompap||'%'
	        									 and codpos   = v_codposap
	        									 and ( (staemp   in  ('1','3') and v_staemp = '3')
                                    or (staemp = '9' and v_staemp = '9') )
	        								 union
	        								select codempid
	        									from tsecpos
	        								 where codcomp  like v_codcompap||'%'
	        									 and codpos   = v_codposap
	        									 and dteeffec <= sysdate
	        									 and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
	        								) a
	order by codempid;

begin
  begin
    select codcomp,codpos
      into v_codcomp,v_codpos
      from temploy1
     where codempid = p_codempid;
  exception when no_data_found then return;
  end;
  --
  if p_flgappr = '1' then
  	v_flag := 'N';
    for j in c_temphead1 loop
    	v_flag := 'Y';
      v_codempap  := j.codempidh;
      v_codcompap := j.codcomph;
      v_codposap  := j.codposh;
      if j.codempidh is not null then
        insert_temp2(p_coduser,p_codapp,j.codempidh,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
      else
        v_staemp := '3';
        for r_codapman in c_codapman loop
            v_flgasem := 'Y';
            insert_temp2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
        end loop;
        if v_flgasem = 'N' then
          v_staemp := '9';
          for r_codapman in c_codapman loop
              insert_temp2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
          end loop;
        end if;
      end if;
    end loop;
    --
    if v_flag = 'N' then
	    for j in c_temphead2 loop
	      v_codempap  := j.codempidh;
	      v_codcompap := j.codcomph;
	      v_codposap  := j.codposh;
	      if j.codempidh is not null then
            insert_temp2(p_coduser,p_codapp,j.codempidh,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
	      else
	        v_staemp := '3';
	        for r_codapman in c_codapman loop
                v_flgasem := 'Y';
                insert_temp2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
	        end loop;
	        if v_flgasem = 'N' then
	          v_staemp := '9';
	          for r_codapman in c_codapman loop
                insert_temp2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
	          end loop;
	        end if;
	      end if;
	    end loop;
  	end if;
  elsif p_flgappr = '2' then
    v_torgprt     := 'N';
  elsif p_flgappr = '3' then
    v_codempap  := null;
    v_codcompap := p_codcompap;
    v_codposap  := p_codposap;
    v_staemp := '3';
    for r_codapman in c_codapman loop
      v_flgasem := 'Y';
      insert_temp2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
    end loop;
    if v_flgasem = 'N' then
      v_staemp := '9';
      for r_codapman in c_codapman loop
        insert_temp2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
      end loop;
    end if;
  elsif p_flgappr = '4' then
    v_codempap  := p_codempap;
    v_codcompap := null;
    v_codposap  := null;
    insert_temp2(p_coduser,p_codapp,p_codempap,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
  elsif p_flgappr = '5' then
    v_codempap  := p_stcodempid;
    v_codcompap := null;
    v_codposap  := null;
    insert_temp2(p_coduser,p_codapp,p_stcodempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
  elsif p_flgappr = '6' then
    if p_codempap is not null then
        v_codempap  := p_codempap;
        v_codcompap := null;
        v_codposap  := null;
        insert_temp2(p_coduser,p_codapp,p_codempap,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
    elsif p_codcompap is not null then
        v_codempap  := null;
        v_codcompap := p_codcompap;
        v_codposap  := p_codposap;
        v_staemp := '3';
        for r_codapman in c_codapman loop
          v_flgasem := 'Y';
          insert_temp2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
        end loop;
        if v_flgasem = 'N' then
          v_staemp := '9';
          for r_codapman in c_codapman loop
            insert_temp2(p_coduser,p_codapp,r_codapman.codempid,v_codempap,v_codcompap,v_codposap,p_stcodempid,p_codempid,p_flgappr,p_seqno,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
          end loop;
        end if;
    end if;
  end if;

  commit;
end;

procedure insert_ttemprpt2 (p_codempid in varchar2,p_codapp in varchar2,
                            p_item1 in varchar2,p_item2 in varchar2,p_item3 in varchar2,
                            p_item4 in varchar2,p_item5 in varchar2,p_item6 in varchar2,
                            p_item7 in varchar2,p_temp31 in number) is
  v_numseq  number;
  --call from find_approve_name--
  --item1=APPROVER,item2=CODEMPAP,item3=CODCOMPAP,item4=CODPOSAP,item5=EMPLOYEE for find all approver,
  --item6=EMPLOYEE for find all approver( or CODAPMAN from pre-seqno in AP),
  --item7=FLGAPPR,temp31=SEQNO
begin
  begin
    select nvl(max(numseq),0) + 1 into v_numseq
      from ttemprpt2
     where codempid = p_codempid
       and codapp   = p_codapp;
  exception when no_data_found then v_numseq := 1;
  end;
  --
  insert into ttemprpt2(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,temp31)
  values(p_codempid,p_codapp,v_numseq,p_item1,p_item2,p_item3,p_item4,p_item5,p_item6,p_item7,p_temp31);
  commit;
end; --insert_ttemprpt2
END;

/

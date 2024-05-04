--------------------------------------------------------
--  DDL for Package Body ALERTMSG_RP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "ALERTMSG_RP" is

  procedure batchauto is
    cursor c_trpalert is
  		select a.codcompy,a.mailalno,a.dteeffec,a.typemail
        from trpalert a
       where a.dteeffec = (select max(dteeffec)
                             from trpalert b
                            where b.mailalno = a.mailalno
                              and b.flgeffec = 'A'
                              and b.dteeffec <= trunc(sysdate))
    order by codcompy,mailalno;
  begin
  null;
  	for i in c_trpalert loop
        if i.typemail = '10' then
            gen_retire(i.codcompy, 'Y', i.mailalno, i.dteeffec, 'Y');
        elsif i.typemail = '20' then
            gen_endwork(i.codcompy, 'Y', i.mailalno, i.dteeffec, 'Y');
        elsif i.typemail = '30' then
            gen_tposempd(i.codcompy, 'Y', i.mailalno, i.dteeffec, 'Y');
        elsif i.typemail = '40' then
            gen_resign(i.codcompy, 'Y', i.mailalno, i.dteeffec, 'Y');
        end if;
    end loop;
  end;

procedure gen_retire (  p_codcompy  in varchar2,
                        flg_log     in varchar2,
                        p_mailalno  in varchar2,
                        p_dteeffec  in date,
                        p_auto      varchar2) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          varchar2(2000);
  v_where           varchar2(2000);
  v_data_file       varchar2(2500);
  v_codempid        temploy1.codempid%type;
  v_count           number;
  v_stdate          varchar2(20);
  v_endate          varchar2(20);
  type descol is table of varchar2(2500) index by binary_integer;
  data_file         descol;
  v_codsend         varchar2(10);
  v_typesend        varchar2(1) := 'N';
  v_testsend        varchar2(1) := 'N';
  v_dteempdb        date;
  v_mailalno        varchar2(30);
  v_dteeffec        date;

  v_seq             number := 0;
  v_numseq          number := 0;
  v_statment        varchar2(2000);
  v_label           varchar2(2500):= '';
  v_item            varchar2(2500):= '';
  v_desc            varchar2(2500):= '';
  v_comma           varchar2(1);
  v_sql             varchar2(4000);
  v_filename        varchar2(1000 char);
  v_seqno           trpasign.seqno%type;
  v_receiver        temploy1.codempid%type;

  cursor c_trpalert is
    select mailalno,dteeffec,syncond,codsend,typemail,
           message,qtydayb,subject,qtydayr,dtelast
      from trpalert
     where codcompy = p_codcompy
       and ((flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
           or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec))
       and typemail = '10'
     order by mailalno;

  cursor c_tmailrrp is
    select pfield,pdesct
      from tmailrrp
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_trpasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from trpasign
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
  for i in c_trpalert loop
    v_codsend   := i.codsend;
    v_testsend  := 'N';
    if p_auto = 'N' then
        v_testsend := 'Y';
    else-- Auto
        if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
            v_testsend := 'Y';
        end if;
    end if;

    if v_testsend = 'Y' then
        v_mailalno          := i.mailalno;
        v_dteeffec          := i.dteeffec;
        p_codapp            := p_codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
        p_codapp_receiver   := p_codapp||'_R';
        p_codapp_file       := p_codapp||'_X';

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

        for i in c_tmailrrp loop
            v_count := v_count + 1;
        end loop;
        if v_count > 0 then
            v_typesend := 'A';
        else
            v_typesend := 'H';
        end if;
        v_count    := 0;
        if v_typesend = 'A' then
            for j in c_tmailrrp loop
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
        v_cursor    := dbms_sql.open_cursor;
        v_where     := ' where codcomp like '''|| p_codcompy ||'%'' and staemp in (''1'',''3'') ';

        if i.syncond is not null then
            v_where := v_where || ' and ('||i.syncond||')';
        end if;

        if i.qtydayb is not null then -- Before
            v_stdate   := to_char(sysdate,'dd/mm/yyyy');
            v_endate   := to_char(sysdate + i.qtydayb,'dd/mm/yyyy');
            v_where    := v_where ||' and dteretire between to_date('''||v_stdate||''',''dd/mm/yyyy'') and to_date('''||v_endate||''',''dd/mm/yyyy'') ';
        end if;

        v_stment := 'select codempid from v_hrrpat ' ||v_where|| ' order by codempid';
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
                select count(*)
                  into v_count
                  from talertlog
                 where codapp = 'HRRPATE'
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
                        for i in c_trpasign loop
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
            update trpalert
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
                alertmsg_rp.gen_file(p_codcompy,v_mailalno,v_dteeffec,' codempid = '''||i.codempid||''' ',v_numseq,10);
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
end; -- gen_retire

procedure gen_endwork (  p_codcompy  in varchar2,
                        flg_log     in varchar2,
                        p_mailalno  in varchar2,
                        p_dteeffec  in date,
                        p_auto      varchar2) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          varchar2(2000);
  v_where           varchar2(2000);
  v_data_file       varchar2(2500);
  v_codempid        temploy1.codempid%type;
  v_count           number;
  v_stdate          varchar2(20);
  v_endate          varchar2(20);
  type descol is table of varchar2(2500) index by binary_integer;
  data_file         descol;
  v_codsend         varchar2(10);
  v_typesend        varchar2(1) := 'N';
  v_testsend        varchar2(1) := 'N';
  v_dteempdb        date;
  v_mailalno        varchar2(30);
  v_dteeffec        date;

  v_seq             number := 0;
  v_numseq          number := 0;
  v_statment        varchar2(2000);
  v_label           varchar2(2500):= '';
  v_item            varchar2(2500):= '';
  v_desc            varchar2(2500):= '';
  v_comma           varchar2(1);
  v_sql             varchar2(4000);
  v_filename        varchar2(1000 char);
  v_seqno           trpasign.seqno%type;
  v_receiver        temploy1.codempid%type;

  cursor c_trpalert is
    select mailalno,dteeffec,syncond,codsend,typemail,
           message,qtydayb,subject,qtydayr,dtelast
      from trpalert
     where codcompy = p_codcompy
       and ((flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
           or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec))
       and typemail = '20'
     order by mailalno;

  cursor c_tmailrrp is
    select pfield,pdesct
      from tmailrrp
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_trpasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from trpasign
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
  for i in c_trpalert loop
    v_codsend   := i.codsend;
    v_testsend  := 'N';
    if p_auto = 'N' then
        v_testsend := 'Y';
    else-- Auto
        if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
            v_testsend := 'Y';
        end if;
    end if;
    if v_testsend = 'Y' then
        v_mailalno  := i.mailalno;
        v_dteeffec  := i.dteeffec;
        p_codapp := p_codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
        p_codapp_receiver   := p_codapp||'_R';
        p_codapp_file       := p_codapp||'_X';

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

        for i in c_tmailrrp loop
            v_count := v_count + 1;
        end loop;
        if v_count > 0 then
            v_typesend := 'A';
        else
            v_typesend := 'H';
        end if;
        if v_typesend = 'A' then
            for j in c_tmailrrp loop
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
        v_cursor    := dbms_sql.open_cursor;
        v_where     := ' where codcomp like '''|| p_codcompy ||'%'' and  staemp = ''3'' ';

        if i.syncond is not null then
        v_where     := v_where || ' and  (' ||i.syncond||')';
        end if;

        if i.qtydayb is not null then -- Before
            v_stdate   := to_char(sysdate,'dd/mm/yyyy');
            v_endate   := to_char(sysdate + i.qtydayb,'dd/mm/yyyy');
            v_where    := v_where ||' and enwkday between to_date('''||v_stdate||''',''dd/mm/yyyy'') and to_date('''||v_endate||''',''dd/mm/yyyy'') ';
        end if;

        v_stment := 'select codempid from v_hrrpat ' ||v_where|| ' order by codempid';
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
                select count(*)
                  into v_count
                  from talertlog
                 where codapp = 'HRRPATE'
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
                        for i in c_trpasign loop
                            if i.flgappr in ('1','3','4') then
                                find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                            elsif i.flgappr = '5' then
                                find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                            end if;
                        end loop;

                        for r_receiver in c_receiver loop
                            insert_temp2(p_coduser,p_codapp,v_codempid,null,null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                        end loop;
--                        alertmsg_rp.gen_file(p_codcompy,i.mailalno,i.dteeffec,'v_temploy.codempid = '''||v_codempid||'''',v_seq,'20');
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
            update trpalert
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
                    alertmsg_rp.gen_file(p_codcompy,v_mailalno,v_dteeffec,' codempid = '''||i.codempid||''' ',v_numseq,20);
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
end; -- gen_endwork

procedure gen_tposempd (  p_codcompy  in varchar2,
                        flg_log     in varchar2,
                        p_mailalno  in varchar2,
                        p_dteeffec  in date,
                        p_auto      varchar2) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          varchar2(2000);
  v_where           varchar2(2000);
  v_data_file       varchar2(2500);
  v_codempid        temploy1.codempid%type;
  v_hrrpat2_numseq  number;
  v_count           number;
  v_stdate          varchar2(20);
  v_endate          varchar2(20);
  type descol is table of varchar2(2500) index by binary_integer;
  data_file         descol;
  v_codsend         varchar2(10);
  v_typesend        varchar2(1) := 'N';
  v_testsend        varchar2(1) := 'N';
  v_dteempdb        date;
  v_mailalno        varchar2(30);
  v_dteeffec        date;

  v_seq             number := 0;
  v_numseq          number := 0;
  v_statment        varchar2(2000);
  v_label           varchar2(2500):= '';
  v_item            varchar2(2500):= '';
  v_desc            varchar2(2500):= '';
  v_comma           varchar2(1);
  v_sql             varchar2(4000);
  v_filename        varchar2(1000 char);
  v_seqno           trpasign.seqno%type;
  v_receiver        temploy1.codempid%type;

  cursor c_trpalert is
    select mailalno,dteeffec,syncond,codsend,typemail,
           message,qtydayb,subject,qtydayr,dtelast
      from trpalert
     where codcompy = p_codcompy
       and ((flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
           or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec))
       and typemail = '30'
     order by mailalno;

  cursor c_tmailrrp is
    select pfield,pdesct
      from tmailrrp
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_trpasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from trpasign
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
           item2 numseq,
           item4 receiver
      from ttemprpt
     where codapp = p_codapp
       and codempid = p_coduser
       and item4 = v_receiver
       and item5 = v_seqno
  order by codempid;

begin
  for i in c_trpalert loop
    v_codsend   := i.codsend;
    v_testsend  := 'N';
    if p_auto = 'N' then
        v_testsend := 'Y';
    else-- Auto
        if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
            v_testsend := 'Y';
        end if;
    end if;
    if v_testsend = 'Y' then
        v_mailalno  := i.mailalno;
        v_dteeffec  := i.dteeffec;
        p_codapp := p_codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
        p_codapp_receiver   := p_codapp||'_R';
        p_codapp_file       := p_codapp||'_X';

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

        for i in c_tmailrrp loop
            v_count := v_count + 1;
        end loop;
        if v_count > 0 then
            v_typesend := 'A';
        else
            v_typesend := 'H';
        end if;
        if v_typesend = 'A' then
            for j in c_tmailrrp loop
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
        v_cursor    := dbms_sql.open_cursor;
        v_where     := ' where codcomp like '''|| p_codcompy ||'%'' ';

        if i.syncond is not null then
        v_where     := v_where || ' and  (' ||i.syncond||')';
        end if;

        if i.qtydayb is not null then -- Before
            v_stdate   := to_char(sysdate,'dd/mm/yyyy');
            v_endate   := to_char(sysdate + i.qtydayb,'dd/mm/yyyy');
--            v_where    := v_where ||' and dteposdue between to_date('''||v_stdate||''',''dd/mm/yyyy'') and to_date('''||v_endate||''',''dd/mm/yyyy'') ';
        end if;

        v_stment := 'select codempid, numseq from v_hrrpat2 ' ||v_where|| ' order by codempid,numseq';
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
            v_codempid          := data_file(1);
            v_hrrpat2_numseq    := data_file(2);
            v_count             := 0;

            begin
                select count(*)
                  into v_count
                  from talertlog
                 where codapp = 'HRRPATE'
                   and codcompy = p_codcompy
                   and mailalno = i.mailalno
                   and dteeffec = i.dteeffec
                   and fieldc1  = v_codempid
                   and fieldc2 = v_hrrpat2_numseq;
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
                        for i in c_trpasign loop
                            if i.flgappr in ('1','3','4') then
                                find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                            elsif i.flgappr = '5' then
                                find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                            end if;
                        end loop;

                        for r_receiver in c_receiver loop
                            insert_temp2(p_coduser,p_codapp,v_codempid,v_hrrpat2_numseq,null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                        end loop;
--                        alertmsg_rp.gen_file(p_codcompy,i.mailalno,i.dteeffec,'tposempd.codempid = '''||v_codempid||''' and tposempd.numseq = '||v_hrrpat2_numseq,v_seq,'30');
                    end if;
                else
                    sendmail_alert(p_codcompy,v_codempid,i.mailalno,i.dteeffec,i.codsend,i.typemail,i.message,null,v_typesend);
                end if;
                if flg_log = 'Y' then
                    insert_talertlog(p_codcompy,i.mailalno,i.dteeffec,v_codempid,v_hrrpat2_numseq,null,null,null,null,null,null);
                end if;
            end if;
        end loop;
        dbms_sql.close_cursor(v_cursor);

        if flg_log = 'Y' then
            update trpalert
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
                    alertmsg_rp.gen_file(p_codcompy,v_mailalno,v_dteeffec,' tposempd.codempid = '''||i.codempid||''' and tposempd.numseq = '||i.numseq,v_numseq,30);
                end loop;

                v_filename  := to_char(sysdate,'yyyymmddhh24mi');
                excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
                sendmail_group(p_codcompy, v_receiver,i.mailalno,
                                i.dteeffec,i.codsend,i.typemail,
                                i.message,v_filename,v_typesend,v_seqno);
            end loop;
--            if v_seq > 0 then
--                v_filename := to_char(sysdate,'yyyymmddhh24mi');
--                if v_numseq > 0 then
--                    excel_mail(v_item,v_label,null,'AUTO',p_codapp,v_filename);
--                end if;
--                sendmail_alert(p_codcompy, v_codsend,i.mailalno,
--                            i.dteeffec,i.codsend,i.typemail,
--                            i.message,v_filename,v_typesend);
--            end if;
        end if;
    end if;
  end loop;
end; -- gen_tposempd

procedure gen_resign (  p_codcompy  in varchar2,
                        flg_log     in varchar2,
                        p_mailalno  in varchar2,
                        p_dteeffec  in date,
                        p_auto      varchar2) is

  v_cursor          number;
  v_dummy           integer;
  v_stment          varchar2(2000);
  v_where           varchar2(2000);
  v_data_file       varchar2(2500);
  v_codempid        temploy1.codempid%type;
  v_hrrpat2_numseq  number;
  v_count           number;
  v_stdate          varchar2(20);
  v_endate          varchar2(20);
  type descol is table of varchar2(2500) index by binary_integer;
  data_file         descol;
  v_codsend         varchar2(10);
  v_typesend        varchar2(1) := 'N';
  v_testsend        varchar2(1) := 'N';
  v_dteempdb        date;
  v_mailalno        varchar2(30);
  v_dteeffec        date;

  v_seq             number := 0;
  v_numseq          number := 0;
  v_statment        varchar2(2000);
  v_label           varchar2(2500):= '';
  v_item            varchar2(2500):= '';
  v_desc            varchar2(2500):= '';
  v_comma           varchar2(1);
  v_sql             varchar2(4000);
  v_filename        varchar2(1000 char);
  v_seqno           trpasign.seqno%type;
  v_receiver        temploy1.codempid%type;

  cursor c_trpalert is
    select mailalno,dteeffec,syncond,codsend,typemail,
           message,qtydayb,subject,qtydayr,dtelast
      from trpalert
     where codcompy = p_codcompy
       and ((flg_log = 'Y' and flgeffec = 'A' and dteeffec <= trunc(sysdate))
           or (flg_log = 'N' and mailalno = p_mailalno and dteeffec = p_dteeffec))
       and typemail = '40'
     order by mailalno;

  cursor c_tmailrrp is
    select pfield,pdesct
      from tmailrrp
     where codcompy = p_codcompy
       and mailalno = v_mailalno
       and dteeffec = v_dteeffec
  order by numseq;

  cursor c_trpasign  is
    select seqno,flgappr,codcompap,codposap,codempap,message
      from trpasign
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
  for i in c_trpalert loop
    v_codsend   := i.codsend;
    v_testsend  := 'N';
    if p_auto = 'N' then
        v_testsend := 'Y';
    else-- Auto
        if (nvl(i.dtelast,trunc(sysdate)) + nvl(i.qtydayr,0)) <= trunc(sysdate) or i.dtelast is null then
            v_testsend := 'Y';
        end if;
    end if;

    if v_testsend = 'Y' then
        v_mailalno  := i.mailalno;
        v_dteeffec  := i.dteeffec;
        p_codapp := p_codcompy||i.mailalno||to_char(i.dteeffec,'yyyymmdd');
        p_codapp_receiver   := p_codapp||'_R';
        p_codapp_file       := p_codapp||'_X';

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

        for i in c_tmailrrp loop
            v_count := v_count + 1;
        end loop;
        if v_count > 0 then
            v_typesend := 'A';
        else
            v_typesend := 'H';
        end if;
        if v_typesend = 'A' then
            for j in c_tmailrrp loop
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
        v_cursor    := dbms_sql.open_cursor;
        v_where     := ' where codcomp like '''|| p_codcompy ||'%'' and staupd in (''C'',''U'') ';

        if i.syncond is not null then
        v_where     := v_where || ' and  (' ||i.syncond||')';
        end if;

        if i.qtydayb is not null then -- Before
--            v_stdate   := to_char(sysdate-10000,'dd/mm/yyyy');
            v_stdate   := to_char(sysdate,'dd/mm/yyyy');
            v_endate   := to_char(sysdate + i.qtydayb,'dd/mm/yyyy');
--            v_where    := v_where ||' and dteeffec between to_date('''||v_stdate||''',''dd/mm/yyyy'') and to_date('''||v_endate||''',''dd/mm/yyyy'') ';
            v_where    := v_where ||' and dteeffec between to_date('''||v_stdate||''',''dd/mm/yyyy'') and to_date(''31/12/2021'',''dd/mm/yyyy'') ';
        end if;

        v_stment := 'select codempid from ttexempt ' ||v_where|| ' order by codempid';
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
            v_codempid          := data_file(1);
            v_count             := 0;

            begin
                select count(*)
                  into v_count
                  from talertlog
                 where codapp = 'HRRPATE'
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
                        for i in c_trpasign loop
                            if i.flgappr in ('1','3','4') then
                                find_approve_name(v_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp_receiver,p_coduser,v_codempid);
                            elsif i.flgappr = '5' then
                                find_approve_name(v_codempid,i.seqno,i.flgappr,null,null,null,p_codapp_receiver,p_coduser,v_codempid);
                            end if;
                        end loop;

                        for r_receiver in c_receiver loop
                            insert_temp2(p_coduser,p_codapp,v_codempid,null,null,r_receiver.receiver,r_receiver.seqno,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                        end loop;
--                        alertmsg_rp.gen_file(p_codcompy,i.mailalno,i.dteeffec,'v_temploy.codempid = '''||v_codempid||'''',v_seq,'40');
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
            update trpalert
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
                    alertmsg_rp.gen_file(p_codcompy,v_mailalno,v_dteeffec,' ttexempt.codempid = '''||i.codempid||''' ',v_numseq,40);
                end loop;

                v_filename  := to_char(sysdate,'yyyymmddhh24mi');
                excel_mail(v_item,v_label,null,'AUTO',p_codapp_file,v_filename);
                sendmail_group(p_codcompy, v_receiver,i.mailalno,
                                i.dteeffec,i.codsend,i.typemail,
                                i.message,v_filename,v_typesend,v_seqno);
            end loop;
--            if v_seq > 0 then
--                v_filename := to_char(sysdate,'yyyymmddhh24mi');
--                if v_numseq > 0 then
--                    excel_mail(v_item,v_label,null,'AUTO',p_codapp,v_filename);
--                end if;
--                sendmail_alert(p_codcompy, v_codsend,i.mailalno,
--                            i.dteeffec,i.codsend,i.typemail,
--                            i.message,v_filename,v_typesend);
--            end if;
        end if;
    end if;
  end loop;
end; -- gen_resign

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
  v_flgchksal    tcoldesc.flgchksal%type;
  v_numseq       number;

 cursor c1 is
    select *
      from tmailrrp
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
        select funcdesc 
          into v_funcdesc
          from tcoldesc
         where codtable = substr(i.pfield,1,instr(i.pfield,'.')-1)
           and codcolmn = substr(i.pfield,instr(i.pfield,'.')+1);
      exception when no_data_found then
        v_funcdesc := null;
      end;
      if v_funcdesc is null then
        v_funcdesc := i.pfield;
      end if;

      v_pfield := v_funcdesc;
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
    if p_typemail in ('10','20') then
        v_stment := 'select '||v_statment||' from v_temploy where '||p_where;
    elsif p_typemail = '30' then
        v_stment := 'select '||v_statment||' from tposempd join v_temploy on tposempd.codempid = v_temploy.codempid where '||p_where;
    elsif p_typemail = '40' then
        v_stment := 'select '||v_statment||' from ttexempt join v_temploy on ttexempt.codempid = v_temploy.codempid where '||p_where;
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

      select max(numseq)
        into v_numseq
        from ttemprpt
       where codempid = 'AUTO'
         and codapp = p_codapp_file;

      v_numseq := nvl(v_numseq,0) + 1;

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
procedure sendmail_alert( p_codcompy  in varchar2,
                          p_codempid  in varchar2,
                          p_mailalno  in varchar2,
                          p_dteeffec  in date,
                          p_codsend   in varchar2,
                          p_typemail  in varchar2,
                          p_message   in varchar2,
                          p_filname   in varchar2,
                          p_typesend  in varchar2) is
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
end;--sendmail_group


procedure replace_text_sendmail( p_msg      in out clob,
                               p_template   in clob,
                               p_codempid   in varchar2,
                               p_codsend    in varchar2,
                               p_codcompy   in varchar2,
                               p_mailalno   in varchar2,
                               p_dteeffec   in date,
                               p_typemail   in varchar2,
                               p_typesend   in varchar2) is

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
  v_codempid    temploy1.codempid%type;
  v_funcdesc    varchar2(100);
  v_msg         clob;
  v_data_msg    clob;
  v_headmag     clob := null;
  v_mailtemplt  varchar2(15) := get_tsetup_value('MAILTEMPLT');

  type descol is table of varchar2(2500) index by binary_integer;
    data_files  descol;

  cursor c_trpparam is
    select mailalno,numseq,codtable,fparam,ffield,descript,flgdesc
      from trpparam
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

--  if v_mailtemplt = 'Y' then
--    v_message   := replace(v_template,'[P_MESSAGE]', replace(replace(v_message,chr(10),'<br>'),' ','&nbsp;'));
--    v_message   := replace(replace(v_message,chr(10),'<br>'),' ','&nbsp;');
--  else
    v_message   := replace(v_template,'[P_MESSAGE]',v_message);
--    v_message   := replace(v_message,chr(10),'<br>');
--  end if;

  data_file := v_message;
  if p_typesend in ('H','E','N') then
    if data_file is not null then
      for i in c_trpparam loop
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

procedure auto_execute_mail (p_codcompy in varchar2,
                             p_mailalno   in varchar2,
                             p_dteeffec   in date,
                             p_codempid   in varchar2,
                             p_msg_to     in clob,
                             p_typemail   in varchar2,
                             p_file       in varchar2,
                             p_typesend   in varchar2) is
  v_msg             clob;
  v_error           varchar2(4000 char);
  v_coduser         varchar2(10) := 'AUTORP2';
  v_codempap        temploy1.codempid%type;
  v_codcompap       tcenter.codcomp%type;
  v_codposap        tpostn.codpos%type;
  v_temp            varchar2(500);
  v_codempid        temploy1.codempid%type;
  v_codcomp         tcenter.codcomp%type;
  v_codpos          tpostn.codpos%type;
  v_codcompemp      tcenter.codcomp%type;
  v_codposemp       tpostn.codpos%type;
  v_codcompr        tcenter.codcomp%type;
  v_codposre        tpostn.codpos%type;
  v_email           varchar2(100);
  v_sender_email    varchar2(100);
  v_trpalert        trpalert%rowtype;
  v_pos0            varchar2(200 char);
  v_pos1            varchar2(200 char);
  v_pos2            varchar2(200 char);
  v_pos3            varchar2(200 char);
  v_pos4            varchar2(200 char);
  v_pos5            varchar2(200 char);
  v_tempfile1       varchar2(500);
  v_tempfile2       varchar2(500);
  v_tempfile3       varchar2(500);
  v_tempfile4       varchar2(500);
  v_tempfile5       varchar2(500);
  v_http            varchar2(1000);
  v_codusr	        varchar2(100);

	cursor c_trpasign  is
        select seqno,flgappr,codcompap,codposap,codempap,message
          from trpasign
         where codcompy = p_codcompy
           and mailalno = p_mailalno
           and dteeffec = p_dteeffec
      order by seqno;
  --
	cursor c_asign is
        select codcomp,codpos,codempid
          from tproasgn
         where v_codcomp like codcomp
           and v_codpos like codpos
           and p_codempid like codempid
      order by codempid desc,codcomp desc;

	cursor c_tproasgn is
		select numseq,flgappr,codcompap,codposap,codempap
		  from tproasgn
	     where codcomp   = v_codcompemp
	       and codpos    = v_codposemp
	       and codempid  = v_codempid
	       and numseq    = 1;

    cursor c_receiver is
        select item1 receiver
          from ttemprpt2
         where codempid = v_coduser
           and codapp = p_codapp
      group by item1
      order by item1;
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
    select *
      into v_trpalert
      from trpalert
     where codcompy = p_codcompy
       and mailalno = p_mailalno
       and dteeffec = p_dteeffec;

    begin
        select email
          into v_sender_email
          from temploy1
         where codempid = v_trpalert.codsend;
    exception when no_data_found then
        v_sender_email := null;
    end;

    if v_sender_email is null then
        v_sender_email := get_tsetup_value('MAILEMAIL');
    end if;

    if p_typesend = 'N' then
        v_temp := null;
    else
        v_temp := p_file;
    end if;

--    if p_typemail <> '10' then --<> HBD
        for i in c_trpasign loop
            delete ttemprpt2 where codapp = p_codapp and codempid = v_coduser;
            commit;

            if i.flgappr in ('1','3','4') then
                gen_approve.find_approve_name(p_codempid,i.seqno,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp,v_coduser,p_codempid);
            elsif i.flgappr = '5' then
                gen_approve.find_approve_name(p_codempid,i.seqno,i.flgappr,null,null,null,p_codapp,v_coduser,p_codempid);
            elsif i.flgappr = '6' then
                for i in c_asign loop
                    v_codcompemp   := i.codcomp;
                    v_codposemp    := i.codpos;
                    v_codempid     := i.codempid;
                    exit;
                end loop; --c_asign
                for i in c_tproasgn loop
                    gen_approve.find_approve_name(p_codempid,i.numseq,i.flgappr,i.codempap,i.codcompap,i.codposap,p_codapp,v_coduser,p_codempid); --user36 STA3590309 12/09/2016
                end loop; --c_tproasgn
            end if;

            for j in c_receiver loop
                begin
                  select email
                    into v_email
                    from temploy1
                   where codempid = j.receiver;
                exception when no_data_found then
                  v_email := null;
                end;

                if v_email is not null then
                    v_http := get_tsetup_value('LINKFORM');
                    v_http := replace(v_http ,'<P_CODAPP>','HRMS31E');
                    begin
                        select coduser into v_codusr
                          from tusrprof
                         where codempid = j.receiver
                           and rownum   = 1;
                    exception when no_data_found then
                        null;
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

                    v_msg   := replace(v_msg ,'<PARAM1>', get_temploy_name(j.receiver,p_lang));
                    if p_typesend in ( 'E' ,'H') then
                        v_error := SendMail_AttachFile(v_sender_email,v_email,v_trpalert.subject,v_msg,null,null,null,null,null);
                    else
                        v_error := SendMail_AttachFile(v_sender_email,v_email,v_trpalert.subject,v_msg,v_temp,null,null,null,null,null,null,'oracle');
                    end if;
                end if;
            end loop; --c_receiver loop
        end loop; --c_trpasign
--    else --= HBD
--        v_msg      := p_msg_to;
--        v_msg      := replace(v_msg ,'[P_OTHERMSG]',null);
--        v_msg      := replace(v_msg ,'<PARAM1>', get_temploy_name(p_codempid,p_lang));
--        begin
--            v_error  := sendmail_attachfile(v_sender_email,v_email,v_trpalert.subject,v_msg,p_file,null,null,null,null); --user32 STA4610019 06/03/2018
--        exception when others then
--            null;
--        end;
--    end if;
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
  v_trpalert        trpalert%rowtype;
  v_http            varchar2(1000);
  v_codusr	        tusrprof.coduser%type;
  v_othmessage      trpasign.message%type;

	cursor c_tpmasign  is
        select message
          from trpasign
         where codcompy = p_codcompy
           and mailalno = p_mailalno
           and dteeffec = p_dteeffec
           and seqno = p_seqno;

begin
    begin
        select *
          into v_trpalert
          from trpalert
         where codcompy = p_codcompy
           and mailalno = p_mailalno
           and dteeffec = p_dteeffec;
    exception when others then
        v_trpalert := null;
    end;

    begin
        select message
          into v_othmessage
          from trpasign
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
         where codempid = v_trpalert.codsend;
    exception when no_data_found then
        v_sender_email := null;
    end;

    if v_sender_email is null then
        v_sender_email := get_tsetup_value('MAILEMAIL');
    end if;

    if p_typesend = 'N' or p_file is null then
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

        if p_typesend in ( 'E' ,'H') or v_temp is null then
            v_error := SendMail_AttachFile(v_sender_email,v_email,v_trpalert.subject,v_msg,null,null,null,null,null);
        else
--            v_error := SendMail_AttachFile(v_sender_email,'peopleplus.ts1@gmail.com',v_tpmalert.subject,v_msg,v_temp,null,null,null,null,null,null,'Oracle');
            v_error := SendMail_AttachFile(v_sender_email,v_email,v_trpalert.subject,v_msg,v_temp,null,null,null,null,null,null,'Oracle');
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
    select max(numseq)
      into v_numseq
      from talertlog
     where codapp = 'HRRPATE'
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
                        'HRRPATE',p_codcompy,p_mailalno,p_dteeffec,
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

  v_dteeffec        date;
  v_torgprt         varchar2(1) := 'N';
  v_staemp          varchar2(1);
  v_flgasem         varchar2(1);
  v_flag			varchar2(1);

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
end ALERTMSG_RP;

/

--------------------------------------------------------
--  DDL for Package Body STD_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_SC" is
  procedure  get_license_Info(p_type_license out varchar2, p_license out number, p_license_Emp out number) is
    v_custname      varchar2(50) := get_tsetup_value('LCUSTNAME');
    v_dbname        varchar2(50) := ORA_DATABASE_NAME;
    v_username      varchar2(50) := user;
  begin
    begin
      select typlicenses--วิธีการนับ License ESS (1 - Concurrent User , 2 - ตามจำนวนพนักงาน)
        into p_type_license
        from tjs.tuser
       where custname    = v_custname
         and dbname      = v_dbname
         and username    = v_username;
    exception when others then null;
    end;
    if p_type_license = '2' then
      p_license      := get_license('', 'ESLICEN');-- wait for change
      begin
        select count(distinct(a.coduser))
          into p_license_Emp
          from tusrprof a, tusrproc b
         where a.coduser  = b.coduser
           and a.flgact   = '1'
           and b.codproc in (select c.codproc
                               from tprocapp c, tappprof e
                              where c.codapp    = e.codapp
                                and c.codproc   = b.codproc
                                and e.codproc   in ('ES','MS'))
           and a.coduser not in ('PPSIMP','PPSADM');
      end;
    else
      p_type_license := '1';
      p_license      := null;
      p_license_Emp  := null;
    end if;
  end;
  --

  function chk_license_by_menu(p_codproc varchar2) return varchar2 is
    v_count_ES      number;
    v_type_license  varchar2(50);
    v_license       number;
    v_license_Emp   number;
    v_count         number;
  begin
    begin
      select count(c.codapp)
        into v_count_ES
        from tprocapp c, tappprof e
       where c.codapp    = e.codapp
         and c.codproc   = p_codproc
         and e.codproc  in ('ES','MS');
    end;
    if v_count_ES > 0 then
      get_license_Info(v_type_license, v_license, v_license_Emp);
      if v_type_license = '2' then
        begin
          select count(distinct(a.coduser))
            into v_count
            from tusrprof a, tusrproc b
           where a.coduser = b.coduser
             and a.flgact  = '1'
             and b.codproc = p_codproc
             and a.coduser not in ('PPSIMP','PPSADM');
        end;
        if v_license < v_count then
          return('N');
        end if;
      end if;
    end if;
    return('Y');
  end;
  --
  function chk_license_by_user(p_codproc varchar2, p_coduser varchar2, p_flgact varchar2) return varchar2 is
    v_count_ES      number;
    v_type_license  varchar2(50);
    v_license       number;
    v_license_Emp   number;
    v_count         number;
  begin
    begin
      select count(c.codapp)
        into v_count_ES
        from tprocapp c, tappprof e
       where c.codapp    = e.codapp
         and c.codproc   = p_codproc
         and e.codproc  in ('ES','MS');
    end;
    if v_count_ES > 0 then
      get_license_Info(v_type_license, v_license, v_license_Emp);
      if v_type_license = '2' then
        begin
          select count(distinct(a.coduser))
            into v_count
            from tusrprof a, tusrproc b
           where a.coduser  = b.coduser
             and a.flgact   = '1'
             and a.coduser <> p_coduser
             and b.codproc in (select c.codproc
                                 from tprocapp c, tappprof e
                                where c.codapp    = e.codapp
                                  and c.codproc   = b.codproc
                                  and e.codproc  in ('ES','MS'))
             and a.coduser not in ('PPSIMP','PPSADM');                     
        end;
        if nvl(p_flgact,'2') = '1' then
          v_count := v_count + 1;
        end if;
        if v_license < v_count then
          return('N');
        end if;
      end if;
    end if;
    return('Y');
  end;
  --

  function chk_license_by_module(p_codproc varchar2) return varchar2 is
    v_count_ES      number;
    v_type_license  varchar2(50);
    v_license       number;
    v_license_Emp   number;
    v_count         number;
  begin
    begin
      select count(c.codapp)
        into v_count_ES
        from tprocapp c, tappprof e
       where c.codapp    = e.codapp
         and c.codproc   = p_codproc
         and e.codproc  in ('ES','MS');
    end;
    if v_count_ES > 0 then
      get_license_Info(v_type_license, v_license, v_license_Emp);
      if v_type_license = '2' then
        begin
          select count(distinct(a.coduser))
            into v_count
            from tusrprof a, tusrproc b
           where a.coduser  = b.coduser
             and a.flgact   = '1'
             and b.codproc in (select c.codproc
                                 from tprocapp c, tappprof e
                                where c.codapp    = e.codapp
                                  and c.codproc   = b.codproc
                                  and e.codproc  in ('ES','MS'))
             and a.coduser not in ('PPSIMP','PPSADM');
        end;
        if v_license < (v_count + 1) then
          return('N');
        end if;
      end if;
    end if;
    return('Y');
  end;
  --
  function chk_expire return boolean is
    v_custname      varchar2(50) := get_tsetup_value('LCUSTNAME');
    v_dbname        varchar2(50) := ORA_DATABASE_NAME;
    v_username      varchar2(50) := user;
    t_dtestrt       varchar2(50);
    t_dteend        varchar2(50);
    v_dtestrt       date;
    v_dteend        date;
    w_chk           varchar2(30);
    w_chk1          number := 0;
    w_chk2          varchar2(30);
  begin
    begin
      select dtestrt,dteend-- NOEXPIRE  , 17092557
        into t_dtestrt,t_dteend
        from tjs.tuser
       where custname    = v_custname
         and dbname      = v_dbname
         and username    = v_username;
    exception when others then null;
    end;
    --
    w_chk1 :=  nvl(ascii(substr(v_username,1,1)),32) + nvl(ascii(substr(v_username,2,1)),32) +
               nvl(ascii(substr(v_username,3,1)),32) + nvl(ascii(substr(v_username,4,1)),32) +
               nvl(ascii(substr(v_username,5,1)),32) + nvl(ascii(substr(v_username,6,1)),32) +
               nvl(ascii(substr(v_custname,1,1)),32) + nvl(ascii(substr(v_custname,2,1)),32) +
               nvl(ascii(substr(v_custname,3,1)),32) + nvl(ascii(substr(v_custname,4,1)),32) +
               nvl(ascii(substr(v_custname,5,1)),32) + nvl(ascii(substr(v_custname,6,1)),32) +
               nvl(ascii(substr(v_dbname,1,1)),32) + nvl(ascii(substr(v_dbname,2,1)),32) +
               nvl(ascii(substr(v_dbname,3,1)),32) + nvl(ascii(substr(v_dbname,4,1)),32) +
               nvl(ascii(substr(v_dbname,5,1)),32) + nvl(ascii(substr(v_dbname,6,1)),32);
    --
    /* DTESTRT */
    w_chk  := t_dtestrt;--:tuser.dtestrt;
    w_chk2 := ltrim(to_char(((w_chk1 * 23) mod 10000),'0000'));
    if w_chk is null or w_chk = '' or (substr(w_chk,5,2)||substr(w_chk,9,2)) <> w_chk2 then
      t_dtestrt := null;--:tuser.wdtestrt := null;
    else
      begin
       t_dtestrt := chr(substr(w_chk,3,2) + 21)||--:tuser.wdtestrt := chr(substr(w_chk,3,2) + 21)||
                    chr(substr(w_chk,1,2) + 13)||
                    chr(substr(w_chk,11,2) + 17)||
                    chr(substr(w_chk,15,2) + 21)||
                    chr(substr(w_chk,13,2) + 11)||
                    chr(substr(w_chk,19,2) + 13)||
                    chr(substr(w_chk,17,2) + 23)||
                    chr(substr(w_chk,7,2) + 15);
      exception when others then
        t_dtestrt := null; --:tuser.wdtestrt := null;
      end;
    end if;
    /* DTEEND */
    w_chk  :=  t_dteend;--:tuser.dteend;
    w_chk2 := ltrim(to_char(((w_chk1 * 27) mod 10000),'0000'));
    if w_chk is null or w_chk = '' or (substr(w_chk,5,2)||substr(w_chk,9,2)) <> w_chk2 then
      t_dteend := null;--:tuser.wdteend
    else
      begin
        t_dteend := chr(substr(w_chk,3,2) + 17)||--:tuser.wdteend := chr(substr(w_chk,3,2) + 17)||
                    chr(substr(w_chk,1,2) + 21)||
                    chr(substr(w_chk,11,2) + 19)||
                    chr(substr(w_chk,15,2) + 37)||
                    chr(substr(w_chk,13,2) + 27)||
                    chr(substr(w_chk,19,2) + 23)||
                    chr(substr(w_chk,17,2) + 33)||
                    chr(substr(w_chk,7,2) + 18);
      exception when others then
        t_dteend := null; --:tuser.wdteend := null;
      end;
    end if;
    --

    if t_dtestrt = 'NOEXPIRE' or t_dtestrt is null then
      v_dtestrt := to_date('01/01/1000','dd/mm/yyyy');
    else
      if substr(t_dtestrt,5,2) <= '20' then
        v_dtestrt := to_date(substr(t_dtestrt,1,2)||'/'||substr(t_dtestrt,3,2)||'/'||substr(t_dtestrt,5,4),'dd/mm/yyyy');
      else
        v_dtestrt := to_date(substr(t_dtestrt,1,2)||'/'||substr(t_dtestrt,3,2)||'/'||to_number(substr(t_dtestrt,5,4)-543),'dd/mm/yyyy');
      end if;
    end if;
    if t_dteend = 'NOEXPIRE' or t_dteend is null then
      v_dteend := to_date('01/01/4000','dd/mm/yyyy');
    else
      if substr(t_dteend,5,2) <= '20' then
        v_dteend := to_date(substr(t_dteend,1,2)||'/'||substr(t_dteend,3,2)||'/'||substr(t_dteend,5,4),'dd/mm/yyyy');
      else
        v_dteend := to_date(substr(t_dteend,1,2)||'/'||substr(t_dteend,3,2)||'/'||to_number(substr(t_dteend,5,4)-543),'dd/mm/yyyy');
      end if;
    end if;
    if sysdate between v_dtestrt and v_dteend then
      return(true); -- not expire
    end if;
    return(false);  -- expire
  end;
end;

/

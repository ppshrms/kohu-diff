--------------------------------------------------------
--  DDL for Package Body HRPY81B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY81B" as
-- last update: 30/09/2020 10:00

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(obj_detail,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_month             := to_number(hcm_util.get_string_t(obj_detail,'month'));
    p_year              := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    p_codbrsoc          := hcm_util.get_string_t(obj_detail,'codbrsoc');
    p_numbrlvl          := hcm_util.get_string_t(obj_detail,'numbrlvl');
    p_type              := hcm_util.get_string_t(obj_detail,'type');
    p_dtestr            := to_date('01' || to_char(p_month,'00') || to_char(p_year,'0000'),'ddmmyyyy');
    p_dteend            := last_day(p_dtestr);
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_process as
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_codbrsoc is not null then
      begin
        select codbrsoc
          into p_codbrsoc
          from tcodsoc
         where codbrsoc = p_codbrsoc
           and codcompy like hcm_util.get_codcomp_level(p_codcomp,1)||'%'
           and rownum   = 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodsoc');
        return;
      end;
    end if;
    if p_numbrlvl is not null then
      begin
        select numbrlvl
          into p_numbrlvl
          from tcodsoc
         where numbrlvl = p_numbrlvl
           and codcompy like hcm_util.get_codcomp_level(p_codcomp,1)||'%'
           and rownum   = 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodsoc');
        return;
      end;
    end if;
    if p_codbrsoc is not null and p_numbrlvl is not null then
      begin
        select codbrsoc
          into p_codbrsoc
          from tcodsoc
         where codbrsoc = p_codbrsoc
           and numbrlvl = p_numbrlvl
           and codcompy like hcm_util.get_codcomp_level(p_codcomp,1)||'%'
           and rownum   = 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodsoc');
        return;
      end;
    end if;
  end check_process;

  procedure get_process(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is null then
        gen_process(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;

    -- set complete batch process
    hcm_batchtask.finish_batch_process(
      p_codapp    => global_v_batch_codapp,
      p_coduser   => global_v_coduser,
      p_codalw    => global_v_batch_codalw,
      p_dtestrt   => global_v_batch_dtestrt,
      p_flgproc   => global_v_batch_flgproc,
      p_qtyproc   => global_v_batch_qtyproc,
      p_qtyerror  => global_v_batch_qtyerror,
      p_filename1 => global_v_batch_filename,
      p_pathfile1 => global_v_batch_pathfile,
      p_oracode   => param_msg_error
    );
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
  end get_process;

  function chk_flgscoc(v_codempid varchar2) return varchar2 as
    v_stmt          varchar2(4000 char);
    v_syncond       varchar2(4000 char);
    v_codcompy      tcenter.codcompy%type;
    v_codempmt      temploy1.codempmt%type;
    v_typpayroll    temploy1.typpayroll%type;
    v_typemp        temploy1.typemp%type;
    v_flgfound      boolean;
  begin
    begin
      select b.codcompy,a.codempmt,a.typpayroll,a.typemp
        into v_codcompy,v_codempmt,v_typpayroll,v_typemp
        from temploy1 a,tcenter b
       where codempid = v_codempid
         and a.codcomp = b.codcomp;
      begin
        select syncond
          into v_syncond
          from tcontrpy
         where codcompy = v_codcompy
           and dteeffec = (select max(dteeffec)
                             from tcontrpy
                            where codcompy = v_codcompy
                              and dteeffec < trunc(sysdate));
        if v_syncond is null then
          return 'Y';
        end if;
        v_syncond := replace(v_syncond,'TEMPLOY.CODEMPID'  ,''''||v_codempid||'''');
        v_syncond := replace(v_syncond,'TEMPLOY.TYPEMP'    ,''''||v_typemp||'''');
        v_syncond := replace(v_syncond,'TEMPLOY.CODEMPMT'  ,''''||v_codempmt||'''');
        v_syncond := replace(v_syncond,'TEMPLOY.TYPPAYROLL',''''||v_typpayroll||'''');
        v_stmt := 'select count(*) from dual where '||v_syncond;
        v_flgfound := execute_stmt(v_stmt);
        if v_flgfound then
          return 'N';
        else
          return 'Y';
        end if;
      exception when no_data_found then
        return 'N';
      end;
    exception when no_data_found then
      return 'N';
    end;
  end;

  function exp_in return clob as
    v_filename       varchar2(4000 char);
    in_file          utl_file.File_Type;
    out_file         utl_file.File_Type;
    v_count          number;
    v_max            date;
    v_min            date;
    data_file        varchar2(4000 char);
    v_codcompy       tcenter.codcompy%type;
    v_codbrlc        tcodsoc.codbrlc%type;
    v_dteempmt       date;
    v_exist          varchar2(1 char) := '1';

    cursor c_tcodsoc is
      select a.codcompy,a.numbrlvl,b.namcomt,
             b.adrcomt ,a.codbrlc ,b.numacsoc
        from tcodsoc a,tcompny b
       where a.codcompy = b.codcompy
         and a.codcompy = nvl(hcm_util.get_codcomp_level(p_codcomp,1),a.codcompy)
         and a.codbrsoc = p_codbrsoc
         and a.numbrlvl = nvl(p_numbrlvl,a.numbrlvl)
    order by a.codbrlc,a.numbrlvl;

    cursor c_emp is
      select a.codempid ,a.codcomp ,a.numlvl,
             a.dteempmt ,a.dtereemp,
             a.namfirstt,a.namlastt,
             b.numsaid  ,a.codtitle
        from temploy1 a ,temploy3 b
       where a.codempid = b.codempid
         and a.codcomp like v_codcompy || '%'
         and a.codcomp like p_codcomp  || '%'
         and a.staemp  in   ('1','3','9')
         and ((a.codbrlc = v_codbrlc
         and ((a.dteempmt between p_dtestr and p_dteend)
          or  (a.dtereemp between p_dtestr and p_dteend)))
          or  (a.codempid in (select t1.codempid
                                from ttmovemt t1
                               where t1.codempid = a.codempid
                                 and t1.dteeffec between p_dtestr and p_dteend
                                 and t1.codbrlc  = v_codbrlc
                                 and t1.codbrlct <> v_codbrlc
                                 and t1.staupd   in ('C','U'))))
         and a.codempid = (select t3.codempid
                             from tssmemb t3
                            where t3.codempid = a.codempid)
         and 'Y' = chk_flgscoc(a.codempid)
         and ((v_exist = '1')
          or ( v_exist = '2' and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                             and exists (select c.coduser
                                           from tusrcom c
                                          where c.coduser = global_v_coduser
                                            and a.codcomp like c.codcomp||'%')))
    order by b.numsaid;
  begin
    -- text1.txt file write /read
    v_filename := hcm_batchtask.gen_filename(lower('HRPY81B'||'_'||global_v_coduser),'txt',global_v_batch_dtestrt);
    std_deltemp.upd_ttempfile(v_filename,'A'); --'A' = Insert , update ,'D'  = delete
    if utl_file.Is_Open(out_file) then
      utl_file.Fclose(out_file);
    end if;
    out_file := utl_file.Fopen(p_file_dir,v_filename,'w');

    for r1 in c_tcodsoc loop
      v_codcompy := r1.codcompy;
      v_codbrlc  := r1.codbrlc;
      begin
        select count(a.codempid),
               max(a.dteempmt),
               min(a.dteempmt)
          into v_count,v_max,v_min
          from temploy1 a,temploy3 b
         where a.codcomp like r1.codcompy || '%'
           and a.staemp in ('1','3','9')
           and ((a.codbrlc  = r1.codbrlc and
               ((a.dteempmt between p_dtestr and p_dteend)   or
               ( a.dtereemp between p_dtestr and p_dteend))) or
               ( a.codempid in (select t1.codempid
                                  from ttmovemt t1
                                 where t1.codempid = a.codempid
                                   and t1.dteeffec between p_dtestr and p_dteend
                                   and t1.codbrlc  = r1.codbrlc
                                   and t1.codbrlct <> r1.codbrlc
                                   and t1.staupd   in ('C','U'))))
           and b.codempid = a.codempid
           and a.codempid = (select t3.codempid
                               from tssmemb t3
                              where t3.codempid = a.codempid)
           and 'Y' = chk_flgscoc(a.codempid);
      exception when no_data_found then
        v_count := 0;
        v_max   := null;
        v_min   := null;
      end;
      if v_count > 0 then
        data_file := '104'
                  || p_codbrsoc
                  || '00'
                  || rpad(nvl(r1.numacsoc,' '),10,' ')
                  || rpad(nvl(r1.numbrlvl,' '),6 ,' ')
                  || '00000'
                  || rpad(' ',16,' ')
                  || lpad(v_count,5,'0')
                  || to_char(v_min,'ddmm') || ltrim(to_char(to_number(to_char(v_min,'yyyy')) + (543),'0000'))
                  || to_char(v_max,'ddmm') || ltrim(to_char(to_number(to_char(v_max,'yyyy')) + (543),'0000'))
                  || lpad('00000',5,'0')
                  || rpad(' ',16,' ')
                  || '00000'
                  || rpad(' ',16,' ');
--        data_file := convert(data_file,'TH8TISASCII');

        data_file := '104'
                  || p_codbrsoc
                  || '00'
                  || rpad(nvl(r1.namcomt ,' '),35,' ')
                  || rpad(nvl(r1.adrcomt ,' '),90,' ');
--        data_file := convert(data_file,'TH8TISASCII');

      end if;
      for r2 in c_emp loop
        if r2.dteempmt between p_dtestr and p_dteend then
          v_dteempmt := r2.dteempmt;
        elsif r2.dtereemp between p_dtestr and p_dteend then
          v_dteempmt := r2.dtereemp;
        else
                  begin
                    select max(dteeffec) into v_dteempmt
                      from ttmovemt
                     where codempid = r2.codempid
                       and dteeffec between p_dtestr and p_dteend
                       and codbrlc  = v_codbrlc
                       and codbrlct <> v_codbrlc
                       and staupd   in ('C','U');
                  exception when no_data_found then
                    v_dteempmt := null;
                  end;
        end if;
        data_file := '608'
                  ||'40'--|| p_codbrsoc
                  || rpad(p_codbrsoc,2,'0')
                  || rpad(nvl(r1.numacsoc,' '),10,' ')
                  || rpad(nvl(r1.numbrlvl,' '),6 ,' ')
                  || rpad(nvl(r2.numsaid ,' '),13,' ')
                  || to_char(v_dteempmt,'ddmm') || ltrim(to_char(to_number(to_char(v_dteempmt,'yyyy')) + (543),'0000'))
                  || substr(r2.codtitle,1,3)
                  || rpad(nvl(r2.namfirstt,' '),30,' ')
                  || rpad(nvl(r2.namlastt ,' '),35,' ')
                  || rpad(' ',128,' ');

        p_rec := p_rec + 1;
      end loop;
    end loop;
    if p_rec = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
      return '';
    end if;
    v_exist := '2';
    p_rec := 0;
    for r1 in c_tcodsoc loop
      v_codcompy := r1.codcompy;
      v_codbrlc  := r1.codbrlc;
      begin
        select count(a.codempid),
               max(a.dteempmt),
               min(a.dteempmt)
          into v_count,v_max,v_min
          from temploy1 a,temploy3 b
         where a.codcomp like r1.codcompy || '%'
           and a.staemp in ('1','3','9')
           and ((a.codbrlc  = r1.codbrlc and
               ((a.dteempmt between p_dtestr and p_dteend)   or
               ( a.dtereemp between p_dtestr and p_dteend))) or
               ( a.codempid in (select t1.codempid
                                  from ttmovemt t1
                                 where t1.codempid = a.codempid
                                   and t1.dteeffec between p_dtestr and p_dteend
                                   and t1.codbrlc  = r1.codbrlc
                                   and t1.codbrlct <> r1.codbrlc
                                   and t1.staupd   in ('C','U'))))
           and b.codempid = a.codempid
           and a.codempid = (select t3.codempid
                               from tssmemb t3
                              where t3.codempid = a.codempid)
           and 'Y' = chk_flgscoc(a.codempid);
      exception when no_data_found then
        v_count := 0;
        v_max   := null;
        v_min   := null;
      end;
      if v_count > 0 then
        data_file := '104'
                  ||'40'--|| p_codbrsoc
                  || '00'
                  || rpad(nvl(r1.numacsoc,' '),10,' ')
                  || rpad(nvl(r1.numbrlvl,' '),6 ,' ')
                  || '00000'
                  || rpad(' ',16,' ')
                  || lpad(v_count,5,'0')
                  || to_char(v_min,'ddmm') || ltrim(to_char(to_number(to_char(v_min,'yyyy')) + (543),'0000'))
                  || to_char(v_max,'ddmm') || ltrim(to_char(to_number(to_char(v_max,'yyyy')) + (543),'0000'))
                  || lpad('00000',5,'0')
                  || rpad(' ',16,' ')
                  || '00000'
                  || rpad(' ',16,' ');
--        data_file := convert(data_file,'TH8TISASCII');

        utl_file.Put_line(out_file,data_file);
        data_file := '104'
                  ||'40'--|| p_codbrsoc
                  || '00'
                  || rpad(nvl(r1.namcomt ,' '),35,' ')
                  || rpad(nvl(r1.adrcomt ,' '),90,' ');
--        data_file := convert(data_file,'TH8TISASCII');

        utl_file.Put_line(out_file,data_file);
      end if;
      for r2 in c_emp loop
        if r2.dteempmt between p_dtestr and p_dteend then
          v_dteempmt := r2.dteempmt;
        elsif r2.dtereemp between p_dtestr and p_dteend then
          v_dteempmt := r2.dtereemp;
        else
          begin
            select max(dteeffec) into v_dteempmt
              from ttmovemt
             where codempid = r2.codempid
               and dteeffec between p_dtestr and p_dteend
               and codbrlc  = v_codbrlc
               and codbrlct <> v_codbrlc
               and staupd   in ('C','U');
          exception when no_data_found then
            v_dteempmt := null;
          end;
        end if;
        data_file := '608'
                  ||'40'--|| p_codbrsoc
                  || rpad(p_codbrsoc,2,'0')
                  || rpad(nvl(r1.numacsoc,' '),10,' ')
                  || rpad(nvl(r1.numbrlvl,' '),6 ,' ')
                  || rpad(nvl(r2.numsaid ,' '),13,' ')
                  || to_char(v_dteempmt,'ddmm') || ltrim(to_char(to_number(to_char(v_dteempmt,'yyyy')) + (543),'0000'))
                  || substr(r2.codtitle,1,3)
                  || rpad(nvl(r2.namfirstt,' '),30,' ')
                  || rpad(nvl(r2.namlastt ,' '),35,' ')
                  || rpad(' ',128,' ');
--        data_file := convert(data_file,'TH8TISASCII');

        utl_file.Put_line(out_file,data_file);
        p_rec := p_rec + 1;
      end loop;
    end loop;
    utl_file.Fclose(out_file);
    sync_log_file(v_filename);

    -- set complete batch process
    global_v_batch_filename := v_filename;
    global_v_batch_pathfile := p_file_path || v_filename;
    return p_file_path || v_filename;
  end exp_in;
  --
  function exp_out return clob as
    v_filename       varchar2(4000 char);
    in_file          utl_file.File_Type;
    out_file         utl_file.File_Type;
    v_count          number;
    v_max            date;
    v_min             date;

    v_min2            date;
    v_max2           date;

    data_file            varchar2(4000 char);
    v_flgssm            ttexempt.flgssm%type;
    v_codcompy       tcenter.codcompy%type;
    v_codbrlc           tcodsoc.codbrlc%type;
    v_dteempmt       date;
    v_dteeffex       date;
    v_exist          varchar2(1 char) := '1';
    v_flg_exist      boolean := false;

    cursor c_tcodsoc is
      select a.codcompy,a.numbrlvl,b.namcomt,
             b.adrcomt ,a.codbrlc ,b.numacsoc
        from tcodsoc a,tcompny b
       where a.codcompy = b.codcompy
         and a.codcompy = nvl(hcm_util.get_codcomp_level(p_codcomp,1),a.codcompy)
         and a.codbrsoc = p_codbrsoc
         and a.numbrlvl = nvl(p_numbrlvl,a.numbrlvl)
    order by a.codbrlc,a.numbrlvl;

    cursor c_emp is
      select a.codempid ,a.codcomp ,a.numlvl,
             a.dteempmt ,a.dtereemp,
             a.namfirstt,a.namlastt,
             b.numsaid  ,a.codtitle,
             a.dteeffex ,a.dteempdb
        from temploy1 a ,temploy3 b
       where a.codempid = b.codempid
         and a.codcomp    like p_codcomp || '%'
         and a.staemp     in   ('1','3','9')
         and ((a.codcomp  like v_codcompy || '%'                   and
               a.codbrlc  = v_codbrlc                              and
              (a.dteeffex between p_dtestr + 1 and p_dteend + 1 )) or
              (a.codempid in (select t1.codempid
                                from ttmovemt t1
                               where t1.codempid = a.codempid
                                 and t1.dteeffec between p_dtestr + 1 and p_dteend + 1
                                 and hcm_util.get_codcomp_level(t1.codcompt,1) = v_codcompy
                                 and t1.codbrlct = v_codbrlc
                                 and (hcm_util.get_codcomp_level(t1.codcomp,1) <> v_codcompy or t1.codbrlc <> v_codbrlc)
                                 and stapost2    = '0'
                                 and t1.staupd   in ('C','U')))
          or (a.codempid in  (select t2.codempid
                                from ttpminf t2
                               where t2.codempid = a.codempid
                                 and t2.dteeffec between p_dtestr + 1 and p_dteend + 1
                                 and t2.codtrn   = '0006'
                                 and hcm_util.get_codcomp_level(t2.codcomp,1) = v_codcompy
                                 and t2.codbrlc  = v_codbrlc
                                 and t2.numseq   = (select max(numseq)
                                                      from ttpminf t3
                                                     where t3.codempid = t2.codempid
                                                       and t3.dteeffec between p_dtestr + 1 and p_dteend + 1
                                                       and t3.codtrn   = '0006'
                                                       and hcm_util.get_codcomp_level(t3.codcomp,1) = v_codcompy
                                                       and t3.codbrlc  = v_codbrlc))))
         and 'Y' = chk_flgscoc(a.codempid)
         and ((v_exist = '1')
          or ( v_exist = '2' and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                             and exists (select c.coduser
                                           from tusrcom c
                                          where c.coduser = global_v_coduser
                                            and a.codcomp like c.codcomp||'%')));
  begin
    -- text1.txt file write /read
    v_filename := hcm_batchtask.gen_filename(lower('HRPY81B'||'_'||global_v_coduser),'txt',global_v_batch_dtestrt);
    std_deltemp.upd_ttempfile(v_filename,'A'); --'A' = Insert , update ,'D'  = delete
    if utl_file.Is_Open(out_file) then
      utl_file.Fclose(out_file);
    end if;
    out_file := utl_file.Fopen(p_file_dir,v_filename,'w');

    for r1 in c_tcodsoc loop
      v_codcompy := r1.codcompy;
      v_codbrlc  := r1.codbrlc;
      begin
        select count(a.codempid),
               max(a.dteempmt),
               min(a.dteempmt)
          into v_count,v_max,v_min
          from temploy1 a,temploy3 b
         where a.codempid = b.codempid
           and a.codcomp like p_codcomp || '%'
           and ((a.codcomp like v_codcompy || '%' and
                 a.codbrlc = v_codbrlc            and
                (a.dteeffex between p_dtestr + 1 and p_dteend + 1)) or
                (a.codempid in (select t1.codempid
                                  from ttmovemt t1
                                 where t1.codempid = a.codempid
                                   and t1.dteeffec between p_dtestr + 1 and p_dteend + 1
                                   and hcm_util.get_codcomp_level(t1.codcomp,1) = v_codcompy
                                   and t1.codbrlct = v_codbrlc
                                   and (hcm_util.get_codcomp_level(t1.codcomp,1) <> v_codcompy or t1.codbrlc <> v_codbrlc)
                                   and stapost2 = '0'
                                   and t1.staupd in ('C','U')))
            or (a.codempid in  (select t2.codempid
                                  from ttpminf t2
                                 where t2.codempid = a.codempid
                                   and t2.dteeffec between p_dtestr + 1 and p_dteend + 1
                                   and t2.codtrn   = '0006'
                                   and hcm_util.get_codcomp_level(t2.codcomp,1) = v_codcompy
                                   and t2.codbrlc  = v_codbrlc
                                   and t2.numseq   = (select max(numseq)
                                                        from ttpminf t3
                                                       where t3.codempid = t2.codempid
                                                         and t3.dteeffec between p_dtestr + 1 and p_dteend + 1
                                                         and t3.codtrn   = '0006'
                                                         and hcm_util.get_codcomp_level(t3.codcomp,1) = v_codcompy
                                                         and t3.codbrlc  = v_codbrlc))))
           and 'Y' = chk_flgscoc(a.codempid);
      exception when no_data_found then
        v_count := 0;
        v_max   := null;
        v_min   := null;
      end;

      for r2 in c_emp loop --1      
        p_rec := p_rec + 1;
        exit;
      end loop;  --for r2 in c_emp loop
    end loop;
    if p_rec = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
      return '';
    end if;

    v_exist := '2';
    p_rec := 0;
    for r1 in c_tcodsoc loop--2
      v_codcompy := r1.codcompy;
      v_codbrlc     := r1.codbrlc;
      begin
        select count(a.codempid),max(a.dteeffex),min(a.dteeffex)
          into v_count,v_max,v_min
          from temploy1 a,temploy3 b
         where a.codempid = b.codempid
           and a.codcomp like p_codcomp || '%'
           and ((a.codcomp like v_codcompy || '%' and
                 a.codbrlc = v_codbrlc            and
                (a.dteeffex between p_dtestr + 1 and p_dteend + 1)) or
                (a.codempid in (select t1.codempid
                                  from ttmovemt t1
                                 where t1.codempid = a.codempid
                                   and t1.dteeffec between p_dtestr + 1 and p_dteend + 1
                                   and hcm_util.get_codcomp_level(t1.codcomp,1) = v_codcompy
                                   and t1.codbrlct = v_codbrlc
                                   and (hcm_util.get_codcomp_level(t1.codcomp,1) <> v_codcompy or t1.codbrlc <> v_codbrlc)
                                   and stapost2 = '0'
                                   and t1.staupd in ('C','U')))
            or (a.codempid in  (select t2.codempid
                                  from ttpminf t2
                                 where t2.codempid = a.codempid
                                   and t2.dteeffec between p_dtestr + 1 and p_dteend + 1
                                   and t2.codtrn   = '0006'
                                   and hcm_util.get_codcomp_level(t2.codcomp,1) = v_codcompy
                                   and t2.codbrlc  = v_codbrlc
                                   and t2.numseq   = (select max(numseq)
                                                        from ttpminf t3
                                                       where t3.codempid = t2.codempid
                                                         and t3.dteeffec between p_dtestr + 1 and p_dteend + 1
                                                         and t3.codtrn   = '0006'
                                                         and hcm_util.get_codcomp_level(t3.codcomp,1) = v_codcompy
                                                         and t3.codbrlc  = v_codbrlc))))
           and 'Y' = chk_flgscoc(a.codempid);
      exception when no_data_found then
        v_count  := 0;
        v_max   := null;
        v_min    := null;
      end;

--<<redmine-PY-2253
       /*
       begin
                  select  min(a.dteeffec),max(a.dteeffec) into v_min2,v_max2
                    from ttmovemt a
                   where  a.codcomp like p_codcomp || '%'                      
                     and a.dteeffec between p_dtestr + 1 and p_dteend + 1
                     and (  (a.codbrlc  <> v_codbrlc and a.codbrlct = v_codbrlc)
                                 or  (a.codcomp  not like v_codcompy || '%' and   a.codcompt like v_codcompy || '%' ) )
                     and a.stapost2 = '0'
                     and a.staupd   in  ('C','U');
                     exception when others then
                     v_min2     := null;
                     v_max2   := null;
      end;       
      v_min   := least( nvl(v_min,v_min2)  , nvl(v_min2,v_min) );       
      v_max  := greatest( nvl(v_max,v_max2) , nvl(v_max2,v_max) );      
      */
-->>redmine-PY-2253

      if v_count > 0 then
        data_file := '104'
                  ||'40'--|| p_codbrsoc
                  || '00'
                  || rpad(nvl(r1.numacsoc,' '),10,' ')
                  || rpad(nvl(r1.numbrlvl,' '),6 ,' ')
                  || '00000'
                  || rpad(' ',16,' ')
                  || lpad('00000',5,'0')
                  || rpad(' ',16,' ')
                  || lpad(v_count,5,'0')
                  || to_char(v_min,'ddmm') || ltrim(to_char(to_number(to_char(v_min,'yyyy')) + (543),'0000'))
                  || to_char(v_max,'ddmm') || ltrim(to_char(to_number(to_char(v_max,'yyyy')) + (543),'0000'))
                  || '00000'
                  || rpad(' ',16,' ');

        utl_file.Put_line(out_file,data_file);
        data_file := '104'
                  ||'40'--|| p_codbrsoc
                  || '00'
                  || rpad(nvl(r1.namcomt ,' '),35,' ')
                  || rpad(nvl(r1.adrcomt ,' '),90,' ');

        utl_file.Put_line(out_file,data_file);
      end if;
      for r2 in c_emp loop
        v_dteeffex := r2.dteeffex;
--<<redmine-PY-2253
        --  if r2.dteeffex between p_dtestr + 1 and p_dteend + 1 then
        if (r2.dteeffex between p_dtestr + 1 and p_dteend + 1) or v_dteeffex is null then
-->>redmine-PY-2253
          v_dteeffex := r2.dteeffex;
          begin
            select  max(dteeffec) into v_dteeffex--v_dteempmt
              from ttmovemt
             where codempid  =  r2.codempid
               and dteeffec between p_dtestr + 1 and p_dteend + 1
               and (  (codbrlc  <> v_codbrlc and codbrlct = v_codbrlc)
                           or  (codcomp  not like v_codcompy || '%' and   codcompt like v_codcompy || '%' ) )
               and stapost2 = '0'
               and staupd   in  ('C','U');
          exception when no_data_found then
            v_dteeffex  := null; --v_dteempmt := null;
          end;

          if v_dteeffex is null then
            begin
              select max(dteeffec) into v_dteeffex
                from ttpminf t2
               where t2.codempid = r2.codempid
                 and t2.dteeffec between p_dtestr +1 and p_dteend + 1
                 and t2.codtrn   = '0006'
                 and hcm_util.get_codcomp_level(t2.codcomp,1) = v_codcompy
                 and t2.codbrlc  = v_codbrlc
                 and t2.numseq   = (select max(numseq)
                                      from ttpminf t3
                                     where t3.codempid = t2.codempid
                                       and t3.dteeffec between p_dtestr + 1 and p_dteend + 1
                                       and t3.codtrn   = '0006'
                                       and hcm_util.get_codcomp_level(t3.codcomp,1) = v_codcompy
                                       and t3.codbrlc  = v_codbrlc);
            exception when no_data_found then
              v_dteeffex := null;
            end;
          end if;
        end if;
        begin
					select flgssm into v_flgssm
					from   ttexempt
					where  codempid = r2.codempid
					and    dteeffec = r2.dteeffex;
				exception when no_data_found then
					v_flgssm := '1';
        end;

        data_file := '609'
                  ||'40'--|| p_codbrsoc
                  || rpad(p_codbrsoc,2,'0')
                  || rpad(nvl(r1.numacsoc,' '),10,' ')
                  || rpad(nvl(r1.numbrlvl,' '),6 ,' ')
                  || rpad(nvl(r2.numsaid ,' '),13,' ')
                  || rpad(to_char(v_dteeffex ,'ddmm') || ltrim(to_char(to_number(to_char(v_dteeffex ,'yyyy')) + (543),'0000')),8,' ')
                  || substr(r2.codtitle,1,3)
                  || rpad(nvl(r2.namfirstt,' '),30,' ')
                  || rpad(nvl(r2.namlastt ,' '),35,' ')
                  || to_char(r2.dteempdb,'ddmm') || ltrim(to_char(to_number(to_char(r2.dteempdb,'yyyy')) + (543),'0000'))
                  || v_flgssm
                  || rpad(' ',128,' ');

        utl_file.Put_line(out_file,data_file);
        p_rec := p_rec + 1;
      end loop;
    end loop;
    utl_file.Fclose(out_file);
    sync_log_file(v_filename);

    -- set complete batch process
    global_v_batch_filename := v_filename;
    global_v_batch_pathfile := p_file_path || v_filename;
    return p_file_path || v_filename;
  end exp_out;

  procedure gen_process(json_str_output out clob) as
    obj_json      json_object_t := json_object_t();
    v_path        varchar2(4000 char);
  begin
    p_dtestr := to_date('01' || to_char(p_month,'00') || to_char(p_year,'0000') ,'ddmmyyyy');
    p_dteend := last_day(p_dtestr);
    p_rec    := 0;
    if p_type = '1' then
      v_path := exp_in;
    elsif p_type = '2' then
      v_path := exp_out;
    else
      v_path := null;
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    elsif p_rec is null or p_rec = 0 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      obj_json.put('path'    ,v_path);
      obj_json.put('record'  ,to_char(nvl(p_rec,0)));
      obj_json.put('coderror','200');
      obj_json.put('response',hcm_secur.get_response('200',get_error_msg_php('HR2715',global_v_lang),global_v_lang));
      json_str_output := obj_json.to_clob;

      -- set complete batch process
      global_v_batch_flgproc  := 'Y';
      global_v_batch_qtyproc  := nvl(p_rec,0);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
  end gen_process;

  function check_index_batchtask(json_str_input clob) return varchar2 is
    v_response    varchar2(4000 char);
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is not null then
      v_response := replace(param_msg_error,'@#$%400');
    end if;
    return v_response;
  end;

end hrpy81b;

/

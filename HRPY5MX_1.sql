--------------------------------------------------------
--  DDL for Package Body HRPY5MX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5MX" as

  function get_date_label (v_numseq number,v_lang varchar2)return varchar2 is
		get_labdate   varchar2(20);
	begin
    select desc_label	into get_labdate
   	  from trptlbl
   	 where codrept   = 'HEADRPT' and
           numseq    =  v_numseq   and
           codlang   =  v_lang;
		return get_labdate;
	exception
		when others then
	 	if v_numseq = 1 then return('Date/Time');
	 	else return('Page');
	 	end if;
	end;

  function get_name_report (v_lang varchar2,v_appl varchar2)return varchar2 is
    get_repname  varchar2(100);
	begin
    select decode(v_lang,'101',desrepe,global_v_lang,desrept,
                         '103',desrep3,'103',desrep4,
                         '105',desrep5,desrepe)||'  '
   		into  get_repname
   		from  tappprof
     where tappprof.codapp  = upper(v_appl);
    return get_repname;
  exception
		when others then return(null);
	end get_name_report;

  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj        := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_stdate            := to_date(hcm_util.get_string_t(json_obj,'p_stdate'),'ddmmyyyy');
    p_endate            := to_date(hcm_util.get_string_t(json_obj,'p_endate'),'ddmmyyyy');
    p_codbrsoc          := hcm_util.get_string_t(json_obj,'p_codbrsoc');
    p_numbrlvl          := hcm_util.get_string_t(json_obj,'p_numbrlvl');
    p_status            := to_number(hcm_util.get_string_t(json_obj,'p_status'));


    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
  begin

    if p_stdate is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_endate is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_stdate > p_endate then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;
    if p_codbrsoc is not null then
      begin
        select distinct(codbrsoc) into v_codbrsoc
          from tcodsoc
         where codbrsoc = p_codbrsoc
         and numbrlvl = nvl(p_numbrlvl, numbrlvl)
         and rownum <= 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodsoc');
        return;
      end;
    end if;

  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
--      del_temp('HRPY5MX%',global_v_codempid);
--      insert_head;
      if p_status = '1' then
        p_codapp := 'HRPY5MX1';

        gen_index1(json_str_output);
      else
        p_codapp := 'HRPY5MX2';
        gen_index2(json_str_output);
      end if;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index1(json_str_output out clob) as
    obj_row           json_object_t;
    obj_row2          json_object_t;
    obj_data          json_object_t;
    obj_data2         json_object_t;
    v_rcnt            number := 0;
    v_rcnt2           number := 0;
    v_numseq          number;
    v_empid           temploy1.codempid%type;
    v_numbrlvl1       varchar2(6 char);
    v_numbrlvl        varchar2(6 char);
    v_compy           tcenter.codcompy%type;
    v_codcomp         tcenter.codcomp%type;
    v_codcompy        tcenter.codcompy%type;
    v_codcompy_de     tcenter.codcompy%type;
    v_codbrlc         varchar2(4 char);
    v_codbrlc_de      varchar2(4 char);

    v_codempid        temploy1.codempid%type;
    v_chk             varchar2(1 char) := 'N';
    v_chk_detail      varchar2(1 char) := 'N';
    v_chk1            varchar2(1 char);
    v_dtereemp        date;
    v_dteeffex        date;
    v_datenew         date;
    --
    v_desnoffi        varchar2(45 char);
    v_flgfound        boolean;
    v_flgsecu         boolean;
    v_desc            varchar2(4000 char);
    v_stmt            varchar2(4000 char);
    v_in              varchar2(1 char);
    --
    v_flg_secure      boolean := false;
    v_flg_permission  boolean := false;

    v_flg_secure_r2   boolean := false;
    v_flg_data_c1     boolean := false;

    cursor c_tcodsoc is
      select a.codcompy, a.numbrlvl, a.codbrlc, a.numtele, b.numacsoc, a.adrcome1, a.zipcode, c.syncond
      from	 tcodsoc a,tcompny b,tcontrpy c
      where	 a.codbrsoc = p_codbrsoc
      and 	 a.numbrlvl = nvl(p_numbrlvl ,a.numbrlvl)
      and    a.codcompy = c.codcompy
      and 	 a.codcompy = b.codcompy
      and   c.dteeffec  = (select max(dteeffec) from tcontrpy
                            where a.codcompy = codcompy
                            and dteeffec <= trunc(sysdate))
      order by a.codbrlc, a.numbrlvl;

      cursor c_emp is
        select a.codcomp,a.numlvl,
               a.codempid,a.codbrlc,
               a.dteempmt,  --?????????????
               a.dtereemp,--???????????????????????
               a.typemp, a.typpayroll
        from 	 temploy1 a,temploy2 b
        where  a.codcomp like v_codcompy||'%'  -- c_tcodsoc
        and 	 a.staemp in ('1','3','9')
        and	 ((a.codbrlc	= v_codbrlc        -- c_tcodsoc
        and  ((a.dteempmt between  p_stdate and p_endate)
        or 		(a.dtereemp between  p_stdate and p_endate  )))
        or 		(a.codempid in (select t1.codempid
                              from 	 ttmovemt t1
                              where  t1.codempid = a.codempid
                              and 	 t1.dteeffec between p_stdate and p_endate
                              and    hcm_util.get_codcomp_level(t1.codcomp,1) = v_codcompy
                              and 	 t1.codbrlc = v_codbrlc
                              and 	(hcm_util.get_codcomp_level(t1.codcompt,1) <> v_codcompy or t1.codbrlct <> v_codbrlc)
                              and    stapost2 = '0'
                              and 	 t1.staupd in ('C','U'))))
        and 	 b.codempid	=	a.codempid
        /*--<< user18 fix issue#2371 20210209
        and		 a.codempid = (select t3.codempid from tssmemb t3
                             where  t3.codempid = a.codempid)
        -- >>*/
        order by b.numoffid;

     --??????????????????????????????????
     cursor c_ttmovemt is
      select codcomp,codcompt,codbrlc,codbrlct
      from	 ttmovemt
      where  codempid = v_empid
      and    dteeffec between p_stdate and p_endate
      and		 codtrn		<> '0007'
      and		 codtrn in (select codcodec
                    from   tcodmove
                    where  codcodec = ttmovemt.codtrn
                    and    typmove  = 'M')
      order by dteeffec,numseq;

      cursor c_emp_detail is
      select b.numoffid,a.codempid,a.dteempmt,a.codcomp,a.numlvl,a.numappl,
               a.ocodempid,a.dteeffex,a.dtereemp,a.codbrlc,--???????????????????????
               a.typemp, a.typpayroll
        from 	 temploy1 a,temploy2 b
        where  a.codcomp like v_codcompy_de||'%'  -- c_tcodsoc
        and 	 a.staemp in ('1','3','9')
        and	 ((a.codbrlc	= v_codbrlc_de        -- c_tcodsoc
        and  ((a.dteempmt between  p_stdate and p_endate  )
        or 		(a.dtereemp between  p_stdate and p_endate  )))
        or 		(a.codempid in (select t1.codempid
                              from 	 ttmovemt t1
                              where  t1.codempid = a.codempid
                              and 	 t1.dteeffec between p_stdate and p_endate
                              and    hcm_util.get_codcomp_level(t1.codcomp,1) = v_codcompy_de
                              and 	 t1.codbrlc = v_codbrlc_de
                              and 	(hcm_util.get_codcomp_level(t1.codcompt,1) <> v_codcompy_de or t1.codbrlct <> v_codbrlc_de)
                              and    stapost2 = '0'
                              and 	 t1.staupd in ('C','U'))))
        and 	 b.codempid	=	a.codempid
        and      a.codempid = v_empid
        /*--<< user18 fix issue#2371 20210209
        and		 a.codempid = (select t3.codempid from tssmemb t3
                             where  t3.codempid = a.codempid)
        -- >>*/
        order by b.numoffid;

  begin
      flg_data := 'N';
      obj_row           := json_object_t();
      obj_row2          := json_object_t();
      flg_fecth  := 'N';
      v_flg_data_c1 := false;
      for r1 in c_tcodsoc loop
        v_flg_data_c1 := true;
        v_flg_secure := secur_main.secur7(r1.codcompy,global_v_coduser);
        if v_flg_secure then
          v_flg_permission := true;
          v_codcompy := r1.codcompy;
          v_codbrlc  := r1.codbrlc;
          obj_row2      := json_object_t();
          v_rcnt2 := 0;
          for r2 in c_emp loop
            if r1.syncond is not null then
              v_desc := r1.syncond;
              v_desc := replace(v_desc,'TEMPLOY1.CODEMPMT',''''||r2.codcomp||'''');
              v_desc := replace(v_desc,'TEMPLOY1.TYPEMP',''''||r2.typemp||'''');
              v_desc := replace(v_desc,'TEMPLOY1.CODEMPID',''''||r2.codempid||'''');
              v_desc := replace(v_desc,'TEMPLOY1.TYPPAYROLL',''''||r2.typpayroll||'''');

              v_stmt := 'select count(*) from dual where '||v_desc;
                v_flgfound := execute_stmt(v_stmt);
              if v_flgfound then   --????????????????????????????????????? Exit loop
                goto jump;         --?????????????????????????????????????  ?????????????????
              end if;
            end if;

            v_empid := r2.codempid;
            v_chk   := null;
            if (r2.dteempmt not between p_stdate and p_endate) or
               (r2.dtereemp not between p_stdate and p_endate) then
               --?????/????????????????? ID ????
              v_in := 'N';
              if r2.dtereemp is not null then
                begin
                  select max(hcm_util.get_codcomp_level(codcomp,1))
                  into   v_compy
                  from   ttpminf
                  where  codempid = v_empid
                  and    dteeffec between p_stdate and p_endate
                  and    codtrn   = '0006'
                  and    codcomp  = r2.codcomp
                  and    codbrlc  = r2.codbrlc
                  and    numseq   = (select max(numseq) from ttpminf
                                     where  codempid = v_empid
                                     and    dteeffec between p_stdate and p_endate
                                     and    codtrn   = '0006'
                                     and    codcomp  = r2.codcomp
                                     and    codbrlc  = r2.codbrlc)
                 and     rownum  = 1 ;
                exception when no_data_found then
                  v_compy	:= null;
                end;
              end if;
            end if;
            --??????????????????????????????????
            if v_compy is not null then
              if v_compy <> hcm_util.get_codcomp_level(r2.codcomp,1) then
                v_in := 'Y';
              end if;
            end if;

            --Check ??????????????????????????????????????? Movement
            if v_in = 'N' then
              for r3 in c_ttmovemt loop
                v_chk := 'N';
                --old
                begin
                  select numbrlvl
                  into	 v_numbrlvl
                  from   tcodsoc
                  where  codcompy = hcm_util.get_codcomp_level(r3.codcomp,1)
                  and    codbrlc  = r3.codbrlc;
                exception when no_data_found then
                  v_numbrlvl := null;
                end;
                --new
                begin
                  select numbrlvl
                  into	 v_numbrlvl1
                  from   tcodsoc
                  where  codcompy = hcm_util.get_codcomp_level(r3.codcompt,1)
                  and    codbrlc  = r3.codbrlct;
                exception when no_data_found then
                  v_numbrlvl1 := null;
                end;

                if  (v_numbrlvl <> v_numbrlvl1) or
                    hcm_util.get_codcomp_level(r3.codcomp,1) <> hcm_util.get_codcomp_level(r3.codcompt,1) then
                  v_chk := 'Y';
                  exit;
                end if;
              end loop; --for r3 in c_ttmovemt
            end if;

           if v_chk = 'Y' or v_chk is null then
              flg_data  := 'Y';
              v_flgsecu := secur_main.secur1(r2.codcomp,r2.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
              if v_flgsecu then
                v_flg_secure_r2 := true;
                obj_data          := json_object_t();
                v_rcnt            := v_rcnt + 1;
                obj_data.put('coderror', '200');
                obj_data.put('codbrlc', r1.codbrlc);
                obj_data.put('codbrlc_desc',  get_tcodec_name('TCODLOCA',r1.codbrlc,global_v_lang));
                obj_data.put('numbrlvl', r1.numbrlvl);
                obj_data.put('codcompy', r1.codcompy);
                obj_data.put('codcompy_desc', get_tcompny_name(r1.codcompy,global_v_lang));
                obj_data.put('numacsoc', r1.numacsoc);
                obj_data.put('numtele', r1.numtele);
                obj_data.put('zipcode', r1.zipcode);
                obj_data.put('adrcome1', r1.adrcome1);
                obj_data.put('adrcome1', replace(r1.adrcome1,chr(10),' '));

                 --detail
                v_codcompy_de := r1.codcompy;
                v_codbrlc_de  := r1.codbrlc;
--                v_rcnt2 := 0;
                  for r2_detail in c_emp_detail loop
                    v_chk_detail := 'N';
                    if r1.syncond is not null then
                      v_desc := r1.syncond;
                      v_desc := replace(v_desc,'TEMPLOY1.CODCOMP',''''||r2_detail.codcomp||'''');
                      v_desc := replace(v_desc,'TEMPLOY1.TYPEMP',''''||r2_detail.typemp||'''');
                      v_desc := replace(v_desc,'TEMPLOY1.CODEMPID',''''||r2_detail.codempid||'''');
                      v_desc := replace(v_desc,'TEMPLOY1.TYPPAYROLL',''''||r2_detail.typpayroll||'''');

                      v_stmt := 'select count(*) from dual where '||v_desc;
                        v_flgfound := execute_stmt(v_stmt);
                      if v_flgfound then   --????????????????????????????????????? Exit loop
                        goto jumpdetail;   --?????????????????????????????????????  ?????????????????
                      end if;
                    end if;

                    v_empid := r2_detail.codempid;
                    v_chk   := null;
                    if (r2.dteempmt not between p_stdate and p_endate) or
                       (r2.dtereemp not between p_stdate and p_endate) then
                       --?????/????????????????? ID ????
                      v_in := 'N';
                      if r2_detail.dtereemp is not null then
                        begin
                          select max(hcm_util.get_codcomp_level(codcomp,1))
                          into   v_compy
                          from   ttpminf
                          where  codempid = v_empid
                          and    dteeffec between p_stdate and p_endate
                          and    codtrn   = '0006'
                          and    codcomp  = r2_detail.codcomp
                          and    codbrlc  = r2_detail.codbrlc
                          and    numseq   = (select max(numseq) from ttpminf
                                             where  codempid = v_empid
                                             and    dteeffec between p_stdate and p_endate
                                             and    codtrn   = '0006'
                                             and    codcomp  = r2_detail.codcomp
                                             and    codbrlc  = r2_detail.codbrlc)
                         and     rownum  = 1 ;
                        exception when no_data_found then
                          v_compy	:= null;
                        end;
                      end if;
                    end if;
                    --??????????????????????????????????
                    if v_compy is not null then
                      if v_compy <> hcm_util.get_codcomp_level(r2_detail.codcomp,1) then
                        v_in := 'Y';
                      end if;
                    end if;

                    --Check ??????????????????????????????????????? Movement
                    if v_in = 'N' then
                      for r3_detail in c_ttmovemt loop
                        v_chk := 'N';
                        --old
                        begin
                          select numbrlvl
                          into	 v_numbrlvl
                          from   tcodsoc
                          where  codcompy = hcm_util.get_codcomp_level(r3_detail.codcomp,1)
                          and    codbrlc  = r3_detail.codbrlc;
                        exception when no_data_found then
                          v_numbrlvl := null;
                        end;
                        --new
                        begin
                          select numbrlvl
                          into	 v_numbrlvl1
                          from   tcodsoc
                          where  codcompy = hcm_util.get_codcomp_level(r3_detail.codcompt,1)
                          and    codbrlc  = r3_detail.codbrlct;
                        exception when no_data_found then
                          v_numbrlvl1 := null;
                        end;

                        if  (v_numbrlvl <> v_numbrlvl1) or
                            hcm_util.get_codcomp_level(r3_detail.codcomp,1) <> hcm_util.get_codcomp_level(r3_detail.codcompt,1) then
                          v_chk := 'Y';
                          exit;
                        end if;
                      end loop; --for r3 in c_ttmovemt
                    end if;
                    --??????????????????????????????
                    if v_chk = 'Y' or v_chk is null then
                      if r2_detail.ocodempid is not null then
                        begin
                          select codempid,dteeffex,codbrlc,codcomp
                          into   v_codempid,v_dteeffex,v_codbrlc,v_codcomp
                          from   temploy1
                          where	 codempid = r2_detail.ocodempid;
                        exception when no_data_found then
                          v_codempid := null;
                          v_dteeffex := sysdate;
                        end;
                        if v_codempid is not null then
                          if (nvl(r2_detail.dtereemp,sysdate) = v_dteeffex) and (v_codbrlc = r2_detail.codbrlc
                          and hcm_util.get_codcomp_level(v_codcomp,1) = hcm_util.get_codcomp_level(r2_detail.codcomp,1)) then
                            v_chk_detail := 'Y'; --???????????????????
                          end if;
                        end if;
                      end if;
                    end if;

                    if v_chk_detail = 'N' then   --????????????????
                      --??? ????? ?? ????????????????
                      if (r2_detail.dtereemp is not null) and (r2_detail.dtereemp between p_stdate and p_endate) then
                         v_datenew	:= r2_detail.dtereemp;
                      elsif r2_detail.dteempmt between p_stdate and p_endate then
                         v_datenew	:= r2_detail.dteempmt;
                      else
                         begin
                           select max(dteeffec)
                             into v_datenew
                             from ttmovemt
                            where codempid = r2_detail.codempid
                              and dteeffec between p_stdate and p_endate
                              and hcm_util.get_codcomp_level(codcomp,1) = r1.codcompy
                              and codbrlc = r1.codbrlc
                              and (hcm_util.get_codcomp_level(codcompt,1) <> r1.codcompy
                                      or codbrlct <> r1.codbrlc)
                              and stapost2 = '0'
                              and staupd in ('C','U');
                         exception when no_data_found then
                            v_datenew := null;
                         end;
                      end if;
                      begin
                       select desnoffi
                           into v_desnoffi
                           from tapplwex
                          where numappl =  nvl(r2_detail.numappl,r2_detail.codempid)
                          and dteend = (select max(dteend) from tapplwex where numappl =  nvl(r2_detail.numappl,r2_detail.codempid));
                        exception when no_data_found then
                          v_desnoffi := null;
                      end;
                      --push detail
--                        v_flgsecu := secur_main.secur1(r2.codcomp,r2.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
--                        if v_flgsecu = true then
                            flg_fecth := 'Y';
                            obj_data2           := json_object_t();
                            v_rcnt2             := v_rcnt2 + 1;
                            obj_data2.put('coderror', '200');
                            obj_data2.put('image', get_emp_img(r2_detail.codempid));

                            obj_data2.put('numoffid', to_char(r2_detail.numoffid));
                            obj_data2.put('codempid', to_char(r2_detail.codempid));
                            obj_data2.put('desc_codempid', get_temploy_name(r2_detail.codempid, global_v_lang));
                            obj_data2.put('dtereemp', to_char(v_datenew, 'dd/mm/yyyy'));
                            obj_data2.put('desnoffi', v_desnoffi);
                            obj_data2.put('descompall', '');
                            obj_data2.put('dteret', '');
                            obj_data2.put('flgssm', '');
                            obj_data2.put('rcnt', v_rcnt2);
                            -- insert temp report --
                            if isInsertReport then
                              insert_temp(obj_data,obj_data2);
                            end if;
                            obj_row2.put(to_char(v_rcnt2 - 1), obj_data2);
--                        end if;
                    END IF;
                    <<jumpdetail>>
                    null;
                  end loop;--detail
                  obj_data.put('children', obj_row2);
              end if;

            end if;
            <<jump>>
            null;
          end loop; -- for r2 in c_emp
        end if;

        if flg_fecth = 'Y' then
          obj_row.put(to_char(v_rcnt - 1), obj_data);
        end if;
      end loop; --loop c_tcodsoc  r1

    --
    if not v_flg_data_c1 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    elsif not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    elsif flg_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    elsif  not v_flg_secure_r2 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    elsif param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;


    json_str_output := obj_row.to_clob;
  end gen_index1;

  procedure gen_index2(json_str_output out clob) as
    obj_row           json_object_t;
    obj_row2          json_object_t;
    obj_data          json_object_t;
    obj_data2         json_object_t;
    v_rcnt            number := 0;
    v_rcnt2           number := 0;
    v_numseq          number;
    v_empid           temploy1.codempid%type;
    v_numbrlvl1       varchar2(6 char);
    v_numbrlvl        varchar2(6 char);
    v_compy           tcenter.codcompy%type;
    v_codcomp         tcenter.codcomp%type;
    v_codcompy        tcenter.codcompy%type;
    v_codcompy_de     tcenter.codcompy%type;
    v_codbrlc         varchar2(4 char);
    v_codbrlc_de      varchar2(4 char);
    v_desc_flgssm     varchar2(150 char);

    v_codempid        temploy1.codempid%type;
    v_chk             varchar2(1 char) := 'N';
    v_chk_detail      varchar2(1 char) := 'N';
    v_move            varchar2(1 char);
    v_dtereemp        date;
    v_dteeffex        date;
    v_dteeffec        date;
    v_dteeffec1       date;
    v_dateoff         date;

    v_desnoffi        varchar2(45 char);
    v_flgssm          varchar2(2 char);
    v_flgfound        boolean;
    v_flgsecu         boolean;
    v_desc            varchar2(4000 char);
    v_stmt            varchar2(4000 char);
    v_out             varchar2(1 char);
    --
    v_flg_secure      boolean := false;
    v_flg_permission  boolean := false;

    v_flg_secure_r2   boolean := false;
    v_flg_data_c1     boolean := false;

    cursor c_tcodsoc is
      select a.codcompy, a.numbrlvl, a.codbrlc, a.numtele, b.numacsoc, a.adrcome1, a.zipcode, c.syncond
      from	 tcodsoc a,tcompny b, tcontrpy c
      where	 a.codbrsoc = p_codbrsoc
      and 	 a.numbrlvl = nvl(p_numbrlvl,a.numbrlvl)
      and 	 a.codcompy = b.codcompy
      and 	 a.codcompy = c.codcompy
      and    c.dteeffec  = (select max(dteeffec) from tcontrpy
                            where a.codcompy = codcompy
                            and dteeffec <= trunc(sysdate))
      order by a.codbrlc,a.numbrlvl;

      cursor c_emp is
        select a.codcomp,a.numlvl,  a.codempid,a.staemp ,   a.dteeffex,a.codbrlc,
               a.typemp, a.typpayroll , a.dteempmt ,a.dtereemp
        from 	 temploy1 a,temploy2 b
        where  a.staemp in ('1','3','9')
        and   ((a.codcomp like v_codcompy||'%' and a.codbrlc	= v_codbrlc and (a.dteeffex between p_stdate and p_endate))
              or (a.codempid in (select t1.codempid
                                 from   ttmovemt t1
                                 where  t1.codempid = a.codempid
                                 and 	  t1.dteeffec between p_stdate and p_endate
                                 and    hcm_util.get_codcomp_level(t1.codcompt,1) = v_codcompy
                                 and 	  t1.codbrlct = v_codbrlc
                                 and 	 (hcm_util.get_codcomp_level(t1.codcomp,1) <> v_codcompy or t1.codbrlc <> v_codbrlc)
                                 and    stapost2 = '0'
                                 and 	  t1.staupd in ('C','U')))
              or (a.codempid in (select t2.codempid
                                 from   ttpminf t2
                                 where  t2.codempid = a.codempid
                                 and    t2.dteeffec between p_stdate and p_endate
                                 and    t2.codtrn   = '0006'
                                 and    hcm_util.get_codcomp_level(t2.codcomp,1)  = v_codcompy
                                 and	  t2.codbrlc  = v_codbrlc
                                 and    t2.numseq   = (select max(numseq) from ttpminf t3
                                                       where  t3.codempid = t2.codempid
                                                       and    t3.dteeffec between p_stdate and p_endate
                                                       and    t3.codtrn   = '0006'
                                                       and    hcm_util.get_codcomp_level(t3.codcomp,1)  = v_codcompy
                                                       and	  t3.codbrlc  = v_codbrlc)
                                )
                 )
             )
        and 	 b.codempid	=	a.codempid
        order by b.numoffid;

     --??????????????????????????????????
     cursor c_ttmovemt is
      select codcomp,codcompt,codbrlc,codbrlct,dteeffec
      from	 ttmovemt
      where  codempid = v_empid
      and    dteeffec between p_stdate and p_endate
      and		 codtrn		<> '0007'
      and		 codtrn in (select codcodec
                    from   tcodmove
                    where  codcodec = ttmovemt.codtrn
                    and    typmove  = 'M')
      order by dteeffec,numseq;

      cursor c_emp_detail is
        select  b.numoffid, a.codempid, a.dteeffex, a.codcomp, a.numlvl, a.numappl, a.codbrlc, a.staemp ,
                a.typpayroll,a.typemp, a.ocodempid, a.dteempmt ,a.dtereemp
          from  temploy1 a,temploy2 b
          where	a.staemp in ('1','3','9')
          and   ((a.codcomp like v_codcompy_de||'%' and a.codbrlc = v_codbrlc_de and (a.dteeffex between p_stdate and p_endate))
                  or (a.codempid in (select t1.codempid
                                     from   ttmovemt t1
                                     where  t1.codempid  = a.codempid
                                     and 	  t1.dteeffec between p_stdate and p_endate
                                     and    hcm_util.get_codcomp_level(t1.codcompt,1) = v_codcompy_de
                                     and 	  t1.codbrlct = v_codbrlc_de
                                     and 	 (hcm_util.get_codcomp_level(t1.codcomp,1) <> v_codcompy_de or t1.codbrlc <> v_codbrlc_de)
                                     and    stapost2 = '0'
                                     and 	  t1.staupd in ('C','U')))
                  or (a.codempid in (select codempid
                                     from   ttpminf t2
                                     where  t2.codempid = a.codempid
                                     and    t2.dteeffec between p_stdate and p_endate
                                     and    t2.codtrn   = '0006'
                                     and    hcm_util.get_codcomp_level(t2.codcomp,1)  = v_codcompy_de
                                     and	  t2.codbrlc  = v_codbrlc_de
                                     and    t2.numseq   = (select max(numseq) from ttpminf t3
                                                           where  t3.codempid = t2.codempid
                                                           and    t3.dteeffec between p_stdate and p_endate
                                                           and    t3.codtrn   = '0006'
                                                           and    hcm_util.get_codcomp_level(t3.codcomp,1)  = v_codcompy_de
                                                           and	  t3.codbrlc  = v_codbrlc_de)
                                    )
                     )
                )
          and b.codempid =	a.codempid
          and a.codempid = v_empid
          order by b.numoffid;


  begin

      flg_data   := 'N';
      obj_row           := json_object_t();
      obj_row2          := json_object_t();
      flg_fecth  := 'N';
      v_flg_data_c1 := false;
      for r1 in c_tcodsoc loop
        v_flg_data_c1 := true;
        v_flg_secure := secur_main.secur7(r1.codcompy,global_v_coduser);
        if v_flg_secure then
          v_flg_permission := true;

          v_codcompy := r1.codcompy;
          v_codbrlc  := r1.codbrlc;
                   obj_row2      := json_object_t();
          v_rcnt2 := 0;
          for r2 in c_emp loop

            if r1.syncond is not null then
              v_desc := r1.syncond;
              v_desc := replace(v_desc,'TEMPLOY1.CODCOMP',''''||r2.codcomp||'''');
--              v_desc := replace(v_desc,'TEMPLOY1.CODEMPMT',''''||r2.codempmt||'''');
              v_desc := replace(v_desc,'TEMPLOY1.TYPEMP',''''||r2.typemp||'''');
              v_desc := replace(v_desc,'TEMPLOY1.CODEMPID',''''||r2.codempid||'''');
              v_desc := replace(v_desc,'TEMPLOY1.TYPPAYROLL',''''||r2.typpayroll||'''');

              v_stmt := 'select count(*) from dual where '||v_desc;
                v_flgfound := execute_stmt(v_stmt);
              if v_flgfound then   --????????????????????????????????????? Exit loop

                goto jump;         --?????????????????????????????????????  ?????????????????
              end if;
            end if;


            v_empid := r2.codempid;
            v_chk   := null;
            -- check ?????
            begin
              select max(dteeffec),max(hcm_util.get_codcomp_level(codcomp,1))
              into	 v_dteeffec , v_compy
              from   ttpminf t2
              where  codempid = v_empid
              and    dteeffec between p_stdate and p_endate
              and    codtrn   = '0006'
              and    codcomp  = r2.codcomp
              and		 codbrlc  = r2.codbrlc
              and    numseq   = (select max(numseq) from ttpminf
                                   where  codempid = v_empid
                                   and    dteeffec between p_stdate and p_endate
                                   and    codtrn   = '0006'
                                   and    codcomp  = r2.codcomp
                                   and	  codbrlc  = r2.codbrlc)
             and rownum	 = 1;
            exception when no_data_found then
              v_compy			:= null;
              v_dteeffec	:= null;
            end;

            --??????????????????????
            if v_compy is not null then
              if v_compy <> hcm_util.get_codcomp_level(r2.codcomp,1) then
                v_out := 'Y';
              end if;
            end if;

            --Check ??????????????????????????????????????? Movement
            if (r2.dteeffex not between p_stdate and p_endate) or
               (v_dteeffec1 between p_stdate and p_endate) then
              --?????/????????????????? ID ?????????????????????
              v_out := 'N';
              if  v_compy is not null then
                if v_compy <> hcm_util.get_codcomp_level(r2.codcomp,1) then
                  v_out := 'Y';
                end if;
              end if;

              if v_out = 'N' then

                 for r3 in c_ttmovemt loop
                  v_chk   := 'N';
                  --old
                  begin
                    select numbrlvl
                    into	 v_numbrlvl
                    from   tcodsoc
                    where  codcompy = hcm_util.get_codcomp_level(r3.codcomp,1)
                    and    codbrlc  = r3.codbrlc;
                  exception when no_data_found then
                    v_numbrlvl := null;
                  end;
                  --new
                  begin
                    select numbrlvl
                    into	 v_numbrlvl1
                    from   tcodsoc
                    where  codcompy = hcm_util.get_codcomp_level(r3.codcompt,1)
                    and    codbrlc  = r3.codbrlct;
                  exception when no_data_found then
                    v_numbrlvl1 := null;
                  end;
                  if (v_numbrlvl <> v_numbrlvl1) or (r2.staemp = 9) or (hcm_util.get_codcomp_level(r3.codcomp,1) <> hcm_util.get_codcomp_level(r3.codcompt,1)) then
                    v_chk := 'Y';
                    exit;
                  end if;
                end loop;	--for r3 in c_ttmovemt
              end if;
            end if;  --if (r2.dteeffex not between p_stdate and p_endate) or

           if v_chk = 'Y' or v_chk is null then
              flg_data  := 'Y';
              v_flgsecu := secur_main.secur1(r2.codcomp,r2.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
              if v_flgsecu then
                v_flg_secure_r2 := true;
                obj_data          := json_object_t();
                v_rcnt            := v_rcnt + 1;

                obj_data.put('coderror', '200');
                obj_data.put('codbrlc', r1.codbrlc);
                obj_data.put('codbrlc_desc',  get_tcodec_name('TCODLOCA',r1.codbrlc,global_v_lang));
                obj_data.put('numbrlvl', r1.numbrlvl);
                obj_data.put('codcompy', r1.codcompy);
                obj_data.put('codcompy_desc', get_tcompny_name(r1.codcompy,global_v_lang));
                obj_data.put('numacsoc', r1.numacsoc);
                obj_data.put('numtele', r1.numtele);
                obj_data.put('zipcode', r1.zipcode);
                obj_data.put('adrcome1', r1.adrcome1);
                obj_data.put('adrcome1', replace(r1.adrcome1,chr(10),' '));

                 --detail
                  v_codcompy_de := r1.codcompy;
                  v_codbrlc_de  := r1.codbrlc;
--                  obj_row2      := json();
--                  v_rcnt2       := 0;
                  for r2_detail in c_emp_detail loop
                    v_chk_detail := 'N';
                    if r1.syncond is not null then
                      v_desc := r1.syncond;
                      v_desc := replace(v_desc,'TEMPLOY1.CODCOMP',''''||r2_detail.codcomp||'''');
                      v_desc := replace(v_desc,'TEMPLOY1.TYPEMP',''''||r2_detail.typemp||'''');
                      v_desc := replace(v_desc,'TEMPLOY1.CODEMPID',''''||r2_detail.codempid||'''');
                      v_desc := replace(v_desc,'TEMPLOY1.TYPPAYROLL',''''||r2_detail.typpayroll||'''');

                      v_stmt := 'select count(*) from dual where '||v_desc;
                        v_flgfound := execute_stmt(v_stmt);
                      if v_flgfound then   --????????????????????????????????????? Exit loop
                        goto jumpdetail;         --?????????????????????????????????????  ?????????????????
                      end if;
                    end if;

                    v_empid := r2_detail.codempid;
                    v_chk   := null;
                    v_move   := 'N';
                    v_dteeffec := null;
                    v_dteeffec1:= null;

                    if (r2.dteempmt not between p_stdate and p_endate) or
                       (r2.dtereemp not between p_stdate and p_endate) then
                      --?????/????????????????? ID ????
                      v_out := 'N';
                      if r2_detail.dtereemp is not null then
                         begin
                          select max(hcm_util.get_codcomp_level(codcomp,1)),max(dteeffec)
                          into	 v_compy, v_dteeffec1
                          from   ttpminf
                          where  codempid = v_empid
                          and    dteeffec between p_stdate and p_endate
                          and    codtrn   = '0006'
                          and    codcomp  = r2_detail.codcomp
                          and    codbrlc  = r2_detail.codbrlc
                          and    numseq   = (select max(numseq) from ttpminf
                                                where  codempid = v_empid
                                                and    dteeffec between p_stdate and p_endate
                                                and    codtrn   = '0006'
                                                and    codcomp  = r2_detail.codcomp
                                                and    codbrlc  = r2_detail.codbrlc)
                          and   rownum    = 1;
                        exception when no_data_found then
                          v_compy			:= null;
                          v_dteeffec1	:= null;
                        end;
                      end if;
                    end if;

                    --???? data ??? TTMOVEMT ????TTPMINF ??????????????????????
                    if (r2_detail.dteeffex not between p_stdate and p_endate) or
                       (v_dteeffec1 between p_stdate and p_endate) then

                      --?????/????????????????? ID ?????????????????????
                      v_out := 'N';
                      if  v_compy is not null then
                        if v_compy <> hcm_util.get_codcomp_level(r2_detail.codcomp,1) then
                          v_out       := 'Y';
                        end if;
                      end if;

                      if v_out = 'N' then
                        for r3_detail in c_ttmovemt loop
                          v_chk_detail   := 'N';
                          --old
                          begin
                            select numbrlvl
                            into	 v_numbrlvl
                            from   tcodsoc
                            where  codcompy = hcm_util.get_codcomp_level(r3_detail.codcomp,1)
                            and    codbrlc  = r3_detail.codbrlc;
                          exception when no_data_found then
                            v_numbrlvl := null;
                          end;
                          --new
                          begin
                            select numbrlvl
                            into	 v_numbrlvl1
                            from   tcodsoc
                            where  codcompy = hcm_util.get_codcomp_level(r3_detail.codcompt,1)
                            and    codbrlc  = r3_detail.codbrlct;
                          exception when no_data_found then
                            v_numbrlvl1 := null;
                          end;
                          if (v_numbrlvl <> v_numbrlvl1) or (r2_detail.staemp = '9') or (hcm_util.get_codcomp_level(r3_detail.codcomp,1) <> hcm_util.get_codcomp_level(r3_detail.codcompt,1)) then
                            v_chk_detail := 'Y';
                            v_dteeffec   := r3_detail.dteeffec;
                            exit;
                          end if;
                        end loop;		 --for r3_detail in c_ttmovemt
                      end if;
                    end if;

                    --??????????????????????????????
                    if v_chk = 'Y' or v_chk is null then
                      if r2_detail.ocodempid is not null then
                        begin
                          select codempid,dtereemp,codbrlc,codcomp
                          into   v_codempid,v_dtereemp,v_codbrlc,v_codcomp
                          from   temploy1
                          where	 ocodempid = r2_detail.codempid
                            and  rownum = 1 ;
                        exception when no_data_found then
                          v_codempid := null;
                          v_dtereemp := sysdate;
                          v_codbrlc  := null;
                          v_codcomp  := null;
                        end;
                        if v_codempid is not null then
                          if (nvl(v_dtereemp,sysdate) = r2_detail.dteeffex) and (v_codbrlc = r2_detail.codbrlc
                          and hcm_util.get_codcomp_level(v_codcomp,1) = hcm_util.get_codcomp_level(r2_detail.codcomp,1)) then
                            v_chk_detail := 'Y'; --???????????????????
                          end if;
                        end if;
                      end if;
                    end if;

                    if v_chk_detail = 'N' then   --????????????????
                      if v_dteeffec is not null and v_dteeffec1 is not null then
                        v_dteeffec := greatest(v_dteeffec,v_dteeffec1);
                      elsif v_dteeffec is null and v_dteeffec1 is not null then
                        v_dteeffec := v_dteeffec1;
                      end if;

                      if v_dteeffec is null then
                        begin
                         select max(dteeffec)
                         into   v_dateoff
                         from   ttmovemt
                         where  codempid = r2_detail.codempid
                           and  dteeffec between p_stdate and p_endate
                           and  hcm_util.get_codcomp_level(codcompt,1) = r1.codcompy
                           and  codbrlct = r1.codbrlc
                           and  (hcm_util.get_codcomp_level(codcomp,1) <> r1.codcompy or codbrlc <> r1.codbrlc)
                           and  staupd in ('C','U');

                           if v_dateoff is null then
                            v_dateoff := nvl(r2_detail.dteeffex,to_date('01/01/1000','dd/mm/yyyy'));
                           end if;
                        exception when no_data_found then
                            v_dateoff := nvl(r2_detail.dteeffex,to_date('01/01/1000','dd/mm/yyyy'));
                        end;
                        --????????????????????????????
                        if v_dateoff <> nvl(r2_detail.dteeffex,to_date('09/09/9999','dd/mm/yyyy')) then
                          v_move := 'Y';
                        end if	;
                      else
                        v_dateoff :=  v_dteeffec;
                      end if;

                      --????????????????????????????
                      begin
                        select flgssm
                        into   v_flgssm
                        from   ttexempt
                        where  codempid = r2_detail.codempid
                        and dteeffec = nvl(v_dteeffec,r2_detail.dteeffex);
                      exception when no_data_found then
                        v_flgssm      := null;
                      end;
                      if v_flgssm is null then
                        if (r2_detail.staemp = 9) and v_move = 'N' then
                          v_flgssm := 1;
                        else
                          v_flgssm := 7;
                        end if;
                      end if;
                      begin
                        select desc_label
                        into   v_desc_flgssm
                        from   tlistval
                        where  list_value = v_flgssm
                        and    codapp = 'FLGSSM'
                        and    codlang = global_v_lang;
                      exception when no_data_found then
                        v_desc_flgssm := null;
                      end;

                      --push detail
--                        v_flgsecu := secur_main.secur1(r2_detail.codcomp,r2_detail.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
--                        if v_flgsecu = true then
                            flg_fecth := 'Y';
                            obj_data2           := json_object_t();
                            v_rcnt2             := v_rcnt2 + 1;
                            obj_data2.put('coderror', '200');
                            obj_data2.put('image', get_emp_img(r2_detail.codempid));

                            obj_data2.put('numoffid', to_char(r2_detail.numoffid));
                            obj_data2.put('codempid', to_char(r2_detail.codempid));
                            obj_data2.put('desc_codempid', get_temploy_name(r2_detail.codempid, global_v_lang));
                            obj_data2.put('dtereemp', '');
                            obj_data2.put('desnoffi', '');
                            obj_data2.put('descompall', '');
                            obj_data2.put('dteret', to_char(v_dateoff,'dd/mm/yyyy'));
                            obj_data2.put('flgssm', v_desc_flgssm);
                            obj_data2.put('flgssm_no', v_flgssm);
                            obj_data2.put('rcnt', v_rcnt2);

                            -- insert temp report --
                            if isInsertReport then
                              insert_temp(obj_data,obj_data2);
                            end if;
                            obj_row2.put(to_char(v_rcnt2 - 1), obj_data2);
--                        end if;
                    end if;
                    <<jumpdetail>>
                    null;
                  end loop;--detail
                  obj_data.put('children', obj_row2);
              end if;
            end if;
            <<jump>>
            null;
          end loop; -- for r2 in c_emp
        end if;
         if flg_fecth = 'Y' then
          obj_row.put(to_char(v_rcnt - 1), obj_data);
        end if;
      end loop; --loop c_tcodsoc  r1

    if not v_flg_data_c1 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    elsif not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    elsif flg_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    elsif  not v_flg_secure_r2 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    elsif param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
--

    json_str_output := obj_row.to_clob;
  end gen_index2;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      del_temp('HRPY5MX%',global_v_codempid);
      if p_status = '1' then
        p_codapp := 'HRPY5MX1';
        gen_index1(json_str_output);
      else
        p_codapp := 'HRPY5MX2';
        gen_index2(json_str_output);
      end if;
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  procedure del_temp (v_codapp varchar2,v_coduser varchar2) is
	begin
		delete ttemprpt where
		codapp   like upper(v_codapp) and
		codempid = upper(v_coduser) ;
		delete ttempprm where
		codapp   like upper(v_codapp) and
		codempid = upper(v_coduser) ;
		commit;
	end;

--  procedure insert_head is
--    f_labdate1  varchar2(20);
--    f_labdate2  varchar2(20);
--    f_repname   varchar2(100);
--    v_codcompy  varchar2(10);
--    v_namcompny varchar2(150);
--    v_compname  varchar2(150);
--    v_status    varchar2(20);
--    v_codapp    varchar2(20);
--  begin
--    if p_status = '1' then --???????????
--      v_codapp := 'HRPY5MX';
--    else --?????
--      v_codapp := 'HRPY5MX2';
--    end if;
--    --
--    delete ttemfilh where coduser = global_v_coduser and codapp = v_codapp ;
--    --
--    f_repname  := get_name_report(global_v_lang,v_codapp);
--    --
--    insert into ttemfilh
--          (coduser,codapp,codcomp,namcomp,
--           namcentt,namrep,label1,label2,label3,label4)
--    values(global_v_coduser,v_codapp,v_codcompy,v_namcompny,
--           get_tcenter_name(v_codcompy,global_v_lang),f_repname,
--           p_codbrsoc,
--           p_numbrlvl,
--           to_char(p_stdate,'dd/mm/yyyy'),
--           to_char(p_endate,'dd/mm/yyyy'));
--    --
--    commit;
--  end;

  procedure insert_temp(json_header_input in json_object_t, json_detail_input in json_object_t) is
    param_json      json_object_t;
    param_json_row  json_object_t;
    json_obj        json_object_t;
    v_num           number := 0;
    v_rcnt          number := 0;
    -- header value --
    v_numacsoc      varchar2(150 char);
    v_codcompy_desc varchar2(150 char);
    v_codbrlc_desc  varchar2(150 char);
    v_numbrlvl      varchar2(150 char);
    v_adrcome1      tcodsoc.adrcome1%type;
    v_zipcode       tcodsoc.zipcode%type;
    v_numtele       tcodsoc.numtele%type;
    v_codcompy      tcodsoc.codcompy%type;
    v_codbrlc       tcodsoc.codbrlc%type;
    -- detail value --
    v_numoffid      varchar2(150 char);
    v_desc_codempid varchar2(150 char);
    v_desnoffi      varchar2(150 char);
    v_flgssm_no     varchar2(150 char);
    v_dteret        date;
    v_dtereemp      date;
    v_descompall    varchar2(150 char);
    v_folder        tfolderd.folder%type;
    v_typsign       tsetsign.typsign%type;
    v_codempid2     tsetsign.codempid%type;
    v_codpos        tsetsign.codpos%type;
    v_signname      tsetsign.signname%type;
    v_posname       tsetsign.posname%type;
    v_namsign       tsetsign.namsign%type;
    v_has_image     varchar2(1) := 'N';
    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_name          varchar2(150 char);
    v_desc_codpos   varchar2(150 char);

  begin
    -- get header --
    v_numacsoc      := hcm_util.get_string_t(json_header_input,'numacsoc');
    v_codcompy      := hcm_util.get_string_t(json_header_input,'codcompy');
    v_codcompy_desc := hcm_util.get_string_t(json_header_input,'codcompy_desc');
    v_codbrlc_desc  := hcm_util.get_string_t(json_header_input,'codbrlc_desc');
    v_numbrlvl      := hcm_util.get_string_t(json_header_input,'numbrlvl');
    v_adrcome1      := hcm_util.get_string_t(json_header_input,'adrcome1');
    v_zipcode       := hcm_util.get_string_t(json_header_input,'zipcode');
    v_numtele       := hcm_util.get_string_t(json_header_input,'numtele');
    -- get detail --
    v_rcnt          := hcm_util.get_string_t(json_detail_input,'rcnt');
    v_numoffid      := hcm_util.get_string_t(json_detail_input,'numoffid');
    v_desc_codempid := hcm_util.get_string_t(json_detail_input,'desc_codempid');
    v_desnoffi      := hcm_util.get_string_t(json_detail_input,'desnoffi');
    v_flgssm_no     := hcm_util.get_string_t(json_detail_input,'flgssm_no');
    v_dteret        := to_date(hcm_util.get_string_t(json_detail_input,'dteret'),'dd/mm/yyyy');
    v_dtereemp      := to_date(hcm_util.get_string_t(json_detail_input,'dtereemp'),'dd/mm/yyyy');
    v_descompall    := hcm_util.get_string_t(json_detail_input,'descompall');
    -- get numseq --
    begin
      select nvl(count(*), 0) + 1 into v_num
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    end;

    begin
      select typsign,codempid,codcomp,
             codpos ,signname,posname,
             namsign
        into v_typsign,v_codempid,v_codcomp,
             v_codpos ,v_signname,v_posname,
             v_namsign
        from tsetsign
       where codcompy = v_codcompy
         and coddoc = 'HRPY5MX';
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSETSIGN');
      return;
    end;

    if v_typsign = '1' then
      begin
        select get_tlistval_name('CODTITLE',codtitle,global_v_lang)||
               namfirstt|| ' ' ||namlastt,
               get_tpostn_name(codpos,global_v_lang)
          into v_name,v_desc_codpos
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then null;
      end;
      --
      begin
        select namsign into v_namsign
          from tempimge
         where codempid = v_codempid;
      exception when no_data_found then null;
      end;
      --
      begin
        select folder  into v_folder
          from tfolderd
         where codapp = 'HRPMC2E2';
      exception when no_data_found then null;
      end;
    elsif v_typsign = '2' then
      begin
        select codempid into v_codempid
          from temploy1
         where codpos = v_codpos
           and codcomp  like nvl(v_codcomp,'')||'%'
           and staemp in ('1','3')
           and rownum = 1
      order by codempid;
      exception when no_data_found then null;
      end;
      --
      begin
        select get_tlistval_name('CODTITLE',codtitle,global_v_lang)||
               namfirstt|| ' ' ||namlastt
          into v_name
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then null;
      end;
      --
      begin
        select namsign into v_namsign
          from tempimge
         where codempid = v_codempid;
      exception when no_data_found then v_namsign := null;
      end;
      --
      begin
        select folder into v_folder
          from tfolderd
         where codapp = 'HRPMC2E2';
      exception when no_data_found then null;
      end;
      v_desc_codpos := get_tpostn_name(v_codpos,global_v_lang);
    elsif v_typsign = '3' then
      v_name := v_signname;
      v_desc_codpos := v_posname;
      begin
        select folder into v_folder
          from tfolderd
         where codapp = 'HRCO02E';
      exception when no_data_found then null;
      end;
    end if;
      --<<check existing image
    if v_namsign is not null then
      v_namsign     := get_tsetup_value('PATHWORKPHP')||v_folder||'/'||v_namsign;
      v_has_image   := 'Y';
    end if;
    -->>
    -- insert temp table --
    begin
      insert into ttemprpt (codempid,codapp,numseq,
                            item1,item2,item3,item4,item5,item6,item7,
                            item8,item9,item10,item11,item12,item13,item14,item15,item16,
                            item17, item18, item19, item20)
                    values (global_v_codempid,p_codapp,v_num,
                            v_rcnt,'D',
                            v_codcompy_desc,
                            v_numacsoc,
                            v_codbrlc_desc,
                            v_numbrlvl,
                            v_adrcome1,
                            v_zipcode,
                            v_numtele,
                            v_numoffid,
                            v_desc_codempid,
                            v_desnoffi,
                            v_flgssm_no,
                            hcm_util.get_date_buddhist_era(v_dteret),
                            hcm_util.get_date_buddhist_era(v_dtereemp),
                            v_descompall,
                            v_namsign,
                            v_has_image,
                            v_name,
                            v_desc_codpos);
    exception when others then null;
    end;
    commit;
  end;
end hrpy5mx;

/

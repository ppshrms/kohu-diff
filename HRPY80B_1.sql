--------------------------------------------------------
--  DDL for Package Body HRPY80B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY80B" as

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codbrsoc          := hcm_util.get_string_t(json_obj,'p_codbrsoc');
    p_typdata           := hcm_util.get_string_t(json_obj,'p_typdata');
    p_sdate             := to_date(hcm_util.get_string_t(json_obj,'p_sdate'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcodec    varchar2(10 char);
    v_codcomp     varchar2(100 char);
    v_tmp         varchar2(1 char);
  begin

		if p_dtemthpay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dtemthpay');
		end if;

		if p_dteyrepay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyrepay');
		end if;

    if p_codbrsoc is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codbrsoc');
		end if;

    if p_sdate is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_sdate');
		end if;

    if p_codbrsoc is not null then
      begin
        select 'X'
          into v_tmp
          from tcodsoc
         where codbrsoc = p_codbrsoc
           and rownum	 <= 1;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCODSOC');
      end;
    end if;

    if p_typpayroll is not null then
	 	  begin
			  select codcodec
			    into v_codcodec
				  from tcodtypy
				 where codcodec = p_typpayroll;
 			exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCODTYPY');
 			end;
		end if;

    if p_codcomp is not null then
      begin
        select codcomp
          into v_codcomp
          from tcenter
         where codcomp like p_codcomp||'%'
           and rownum <= 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
      end;
 		end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

  end check_index;

  procedure get_process(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      process_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
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

  procedure process_data(json_str_output out clob) is
    obj_data            json_object_t;
    v_data              varchar2(1 char) := 'N';
    v_flgsecur          varchar2(1 char) := 'N';
    v_flg               varchar2(1 char);
    out_file   			    UTL_FILE.File_Type;
    data_file 			    varchar2(4000 char);
    v_dtestrt     	    date;
    v_dteend      	    date;
    v_filename    	    varchar2(255 char);
    v_dteempdb    	    date;
    v_dteempmt    	    date;
    v_codtitle1   	    varchar2(100 char);
    v_namfirstt1  	    varchar2(1000 char);
    v_namlastt1   	    varchar2(1000 char);
    v_staemp      	    varchar2(10 char);
    v_dteeffex    	    date;
    v_year				      number	:= 0;
    v_month	 			      number	:= 0;
    v_day 				      number 	:= 0;
    p_codempid    	    varchar2(100 char);
    p_dteeffec    	    date;
    t_codempid    	    varchar2(100 char);
    v_codempidt   	    varchar2(100 char);
    v_codcompyt			    varchar2(100 char);
    v_codcompt			    varchar2(100 char);
    v_numlvl			      number;
    v_typpayrollt		    varchar2(4 char);
    v_secur				      boolean;
    v_numsaid1    	    varchar2(30 char);
    v_numoffid    	    varchar2(13 char);
    v_numsaid			      varchar2(30 char) := ' ';
    v_prefix			      varchar2(30 char);
    v_codtitle 			    varchar2(30 char) := ' ';
    v_namfirstt			    varchar2(30 char) := ' ';
    v_namlastt			    varchar2(35 char)	:= ' ';
    v_amtsoc			      number := 0;
    v_amtsoca			      number := 0;
    v_amtsocc			      number := 0;
    v_totamtsoc			    number := 0;
    v_totamtsoca		    number := 0;
    v_totamtsocc		    number := 0;
    v_sumrec			      number := 0;
    v_cntrec            number := 0;
    v_numacsoc			    varchar2(4000 char)	:= ' ';
    v_namcomt			      varchar2(4000 char)	:= ' ';
    v_pctsoc			      number := 0;
    ti_sumrec           number := 0;
    v_numbrlvl			    varchar2(100 char) := ' ';
    v_codcompy			    varchar2(100 char) := ' ';
    v_codempid			    varchar2(100 char) := ' ';
    v_typpayroll		    varchar2(100 char);
    v_response          varchar2(4000 char);
    v_qtyage            tcontrpy.qtyage%type;
    v_dteeffex2   	    date;

    TYPE a_string IS TABLE OF VARCHAR2(1000 CHAR) INDEX BY BINARY_INTEGER;
      data_numsaid    a_string;
      data_prefix     a_string;
      data_namfirstt  a_string;
      data_namlastt   a_string;
    TYPE a_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      data_amtsoc     a_number;
      data_amtsoca    a_number;
      data_amtsocc    a_number;

    cursor c_tcodsoc is
      select a.codbrlc,a.numbrlvl,b.codempid,
             sum(stddec(b.amtsoc,b.codempid,v_chken)) amtsoc,
             sum(stddec(b.amtsoca,b.codempid,v_chken)) amtsoca,
             sum(stddec(b.amtsocc,b.codempid,v_chken)) amtsocc
        from tcodsoc a,ttaxcur b
       where a.codbrlc	    = b.codbrlc
         and a.codbrsoc 	= p_codbrsoc
         and a.codcompy 	= b.codcompy
         and b.codcomp like p_codcomp||'%'
         and b.typpayroll	= nvl(p_typpayroll,b.typpayroll)
         and b.dteyrepay	= p_dteyrepay
         and b.dtemthpay	= p_dtemthpay
         and b.flgsoc     = 'Y'
       group by	a.codbrlc,a.numbrlvl,b.codempid
       having (case when p_typdata='2' then sum(stddec(b.amtsoca,b.codempid,v_chken)) else 1 end) > 0
       order by	a.numbrlvl,b.codempid;

    cursor c_ttaxcur is
      select codcomp,numlvl,typpayroll
        from ttaxcur
			 where codempid  = v_codempidt
         and dteyrepay = p_dteyrepay
				 and dtemthpay = p_dtemthpay
				 and (case when p_typdata='2' then to_number(stddec(amtsoca,codempid,v_chken)) else 1 end) > 0
    order by numperiod desc;

  begin 
    v_dtestrt 	:= to_date(get_period_date(p_dtemthpay,p_dteyrepay,'S'),'dd/mm/yyyy');
    v_dteend  	:= to_date(get_period_date(p_dtemthpay,p_dteyrepay,'E'),'dd/mm/yyyy');

    v_filename := hcm_batchtask.gen_filename(lower('HRPY80B'||'_'||global_v_coduser),'txt',global_v_batch_dtestrt);
    --
    std_deltemp.upd_ttempfile(v_filename,'A');
    --
    out_file 	:= UTL_FILE.Fopen(p_file_dir,v_filename,'w');

    for r_tcodsoc in c_tcodsoc loop
      -- ???????????????????????????????? >= 60 ?? ???????????????????
      begin
        select dteempdb,dteempmt,substr(codtitle,1,3),namfirstt,namlastt,
               staemp,dteeffex
          into v_dteempdb,v_dteempmt,v_codtitle1,v_namfirstt1,v_namlastt1,
               v_staemp,v_dteeffex
          from temploy1
         where codempid = r_tcodsoc.codempid;
      exception when no_data_found then
        null;
      end;
      v_codempidt := r_tcodsoc.codempid;

      -- ???????????????????? ??????????????????????????? 1 ????????/?????????
      if (v_staemp <> '9') or (r_tcodsoc.amtsoc > 0) or (r_tcodsoc.amtsoc <= 0 and v_staemp = '9' and v_dteeffex > v_dtestrt) then

        get_service_year(v_dteempdb,v_dteempmt,'Y',v_year,v_month,v_day); -- edit 30/06/2020
--        get_service_year(v_dteempdb,p_sdate,'Y',v_year,v_month,v_day);

        for r_ttaxcur in c_ttaxcur loop
          v_codcompyt		:= hcm_util.get_codcomp_level(r_ttaxcur.codcomp,1);
          v_codcompt		:= r_ttaxcur.codcomp;
          v_numlvl			:= r_ttaxcur.numlvl;
          v_typpayrollt	:= r_ttaxcur.typpayroll;
          exit;
        end loop;

        begin
        select qtyage
          into v_qtyage
          from tcontrpy
         where codcompy	= v_codcompyt
           and dteeffec	= (select max(dteeffec)
                             from tcontrpy
                            where codcompy = v_codcompyt
                              and to_char(dteeffec,'dd/mm/yyyy') <= to_char(sysdate,'dd/mm/yyyy'));
        exception when no_data_found then
            v_qtyage := 60;
        end;

--        if v_year < v_qtyage then -- edit 30/06/2020
--        if v_year < 60 then
          p_codempid := null;
          t_codempid := null;
          begin
            select codempid,dteeffec
              into p_codempid,p_dteeffec
              from ttpminf
             where codempid = r_tcodsoc.codempid
               and dteeffec <= (select min(to_date(lpad(to_char(b.dtestrt),2,'0')||'/'||
                                                   lpad(to_char(b.dtemthpay),2,'0')||'/'||
                                                   to_char(b.dteyrepay),'DD/MM/YYYY'))
                                  from tdtepay b
                                 where b.codcompy   = v_codcompyt
                                   and b.typpayroll = v_typpayrollt
                                   and b.dteyrepay  = p_dteyrepay
                                   and b.dtemthpay  = p_dtemthpay)
              and codtrn = '0006'
              and rownum = 1;
          exception when no_data_found then
            p_codempid := null;
            p_dteeffec := null;
          end;

          if p_codempid is not null then
            begin
              select codempid
                into t_codempid
                from ttpminf
               where codempid = r_tcodsoc.codempid
                 and dteeffec >= p_dteeffec
                 and codtrn   = '0002'
                 and rownum   = 1;
            exception when no_data_found then
              t_codempid := null;
            end;
          end if;

          v_flg := 'Y';
--          if p_typdata = '1' then
--            if (p_codempid is null) or (p_codempid is not null and t_codempid is not null) or (r_tcodsoc.amtsoc > 0) then
--              v_flg := 'Y';
--            else
--              v_flg := 'N';
--            end if;
--          else
--            if (p_codempid is null and r_tcodsoc.amtsoc > 0) or
--               (p_codempid is not null and t_codempid is not null and r_tcodsoc.amtsoc > 0) or
--               (r_tcodsoc.amtsoc > 0) then
--              v_flg := 'Y';
--            else
--              v_flg := 'N';
--            end if;
--          end if;

          if v_flg = 'Y' then
            v_data := 'Y';
            ti_sumrec	:= ti_sumrec + 1;
            v_secur	:= secur_main.secur1(v_codcompt,v_numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
            if v_secur then
              v_flgsecur := 'Y';
              begin
                select b.numsaid,a.numoffid into v_numsaid1,v_numoffid
                  from temploy2 a,temploy3 b
                 where a.codempid = b.codempid
                   and a.codempid = r_tcodsoc.codempid;
              exception when no_data_found then
                v_numsaid1 := null;
                v_numoffid := null;
              end;
              if v_numsaid1 is not null then
                v_numoffid := v_numsaid1;
              end if;

              -- Put Detail Record to data block when change emp.id.
              if (r_tcodsoc.codempid <> v_codempid and v_codempid <> ' ') then
                --go_block('data');
                data_numsaid(v_sumrec)   := rpad(nvl(v_numsaid,' '),13,' ');
                data_prefix(v_sumrec)    := v_prefix;
                data_namfirstt(v_sumrec) := rpad(substr(nvl(v_namfirstt,' '),1,30),30,' ');
                data_namlastt(v_sumrec)  := rpad(substr(nvl(v_namlastt,' '),1,35),35,' ');
                data_amtsoc(v_sumrec)    := lpad(substr(to_char(v_amtsoc * 100),1,14),14,'0');
                data_amtsoca(v_sumrec)   := lpad(substr(to_char(v_amtsoca * 100),1,12),12,'0');
                data_amtsocc(v_sumrec)   := lpad(substr(to_char(v_amtsocc * 100),1,12),12,'0');
                --next_record;
                v_totamtsoc	 :=	v_totamtsoc + v_amtsoc;
                v_totamtsoca :=	v_totamtsoca + v_amtsoca;
                v_totamtsocc :=	v_totamtsocc + v_amtsocc;
                v_sumrec		 :=	v_sumrec + 1;

                v_amtsoc	:= 0;
                v_amtsoca	:= 0;
                v_amtsocc	:= 0;
              end if;
              -- End Put Detail Record to data block when change emp.id.

              -- Put Head record
              if (v_numbrlvl <> r_tcodsoc.numbrlvl and v_numbrlvl <> ' ') then
                begin
                  select a.pctsoc,b.numacsoc,b.namcomt
                    into v_pctsoc,v_numacsoc,v_namcomt
                    from tcontrpy a, tcompny b
                   where a.codcompy	= v_codcompy
                     and a.dteeffec	= (select max(dteeffec)
                                         from tcontrpy
                                        where codcompy = v_codcompy
                                          and to_char(dteeffec,'dd/mm/yyyy') <= to_char(sysdate,'dd/mm/yyyy'))--to_date(sysdate,'dd/mm/yyyy'))
                    and	b.codcompy = a.codcompy;
                exception when no_data_found then
                  v_pctsoc	 := 0;
                  v_numacsoc := ' ';
                  v_namcomt	 := ' ';
                end;

                -- Write Header to text file
                data_file := '1'||rpad(nvl(v_numacsoc,' '),10,' ')||
                             rpad(nvl(v_numbrlvl,' '),6,' ')||
                             to_char(p_sdate,'dd')||to_char(p_sdate,'mm')||
                             substr(to_char(to_number(to_char(p_sdate,'yyyy')) - global_v_zyear + 543),3,2)||
                             lpad(p_dtemthpay,2,'0')||
                             substr(to_char(p_dteyrepay - global_v_zyear + 543),3,2)||
                             rpad(nvl(v_namcomt,' '),45,' ')||lpad(v_pctsoc * 100,4,'0')||
                             lpad(v_sumrec,6,'0')||lpad(v_totamtsoc * 100,15,'0')||
                             lpad((v_totamtsoca + v_totamtsocc) * 100,14,'0')||
                             lpad((v_totamtsoca) * 100,12,'0')||
                             lpad((v_totamtsocc) * 100,12,'0');

                --UTL_FILE.Put_line(out_file,data_file);
--                data_file := convert(data_file,'TH8TISASCII');
                if data_file is not null then
                  UTL_FILE.Put_line(out_file,data_file);
                end if;

                -- Write Detail to text file
                for i in 0..v_sumrec - 1 loop
                  v_cntrec := nvl(v_cntrec,0) + 1;
                  data_file := '2'||rpad(nvl(data_numsaid(i),' '),13,' ')||
                               rpad(nvl(data_prefix(i),' '),3,' ')||
                               rpad(substr(nvl(data_namfirstt(i),' '),1,30),30,' ')||
                               rpad(substr(nvl(data_namlastt(i),' '),1,35),35,' ')||
                               lpad(substr(data_amtsoc(i),1,14),14,'0')||
                               lpad(substr(data_amtsoca(i),1,12),12,'0');

--                  data_file := convert(data_file,'TH8TISASCII');
                  if data_file is not null then
                    UTL_FILE.Put_line(out_file,rpad(data_file,135,' '));
                  end if;
                end loop;

                v_sumrec			:= 0;
                v_totamtsoc		:= 0;
                v_totamtsoca	:= 0;
              end if;
              -- Period pay ?????????????
              v_prefix  	 := v_codtitle1;
              v_amtsoc		 := v_amtsoc + greatest(nvl(r_tcodsoc.amtsoc,0),0);
              v_amtsoca		 := v_amtsoca + nvl(r_tcodsoc.amtsoca,0);
              v_amtsocc		 := v_amtsocc + nvl(r_tcodsoc.amtsocc,0);
              v_numbrlvl	 := r_tcodsoc.numbrlvl;
              v_codcompy	 := v_codcompyt;
              v_typpayroll := v_typpayrollt;
              v_codempid	 := r_tcodsoc.codempid;
              v_numsaid		 := v_numoffid;
              v_namfirstt	 := v_namfirstt1;
              v_namlastt	 := v_namlastt1;
            end if;
          end if;

--        end if; --- if v_year < 60 then

      end if; -- ???????????????????? ??????????????????????????? 1 ????????/?????????

    end loop;

    if ti_sumrec <> 0 then
      --go_block('data');
      data_numsaid(v_sumrec)   := rpad(nvl(v_numsaid,' '),13,' ');
      data_prefix(v_sumrec)    := v_prefix;
      data_namfirstt(v_sumrec) := rpad(substr(nvl(v_namfirstt,' '),1,30),30,' ');
      data_namlastt(v_sumrec)  := rpad(substr(nvl(v_namlastt,' '),1,35),35,' ');
      data_amtsoc(v_sumrec)    := lpad(substr(to_char(v_amtsoc * 100),1,14),14,'0');
      data_amtsoca(v_sumrec)   := lpad(substr(to_char(v_amtsoca * 100),1,12),12,'0');
      data_amtsocc(v_sumrec)   := lpad(substr(to_char(v_amtsocc * 100),1,12),12,'0');

      v_totamtsoc		:=	v_totamtsoc + v_amtsoc;
      v_totamtsoca	:=	v_totamtsoca + v_amtsoca;
      v_totamtsocc	:=	v_totamtsocc + v_amtsocc;
      v_sumrec			:=	v_sumrec + 1;

      v_amtsoc	:= 0;
      v_amtsoca	:= 0;
      v_amtsocc	:= 0;
    end if;

    v_dteeffex2 := to_date('01/'|| lpad(p_dtemthpay, 2, '0') || '/' || p_dteyrepay,'dd/mm/yyyy');
    v_dteeffex2 :=  LAST_DAY(v_dteeffex2);


    --Put Head record
    if ti_sumrec > 0 then
    begin
       select	a.pctsoc,b.numacsoc,b.namcomt,a.dteeffec
         into	v_pctsoc,v_numacsoc,v_namcomt,p_dteeffec
         from	tcontrpy a,tcompny b
        where	a.codcompy = v_codcompy
          and	a.dteeffec = (select max(dteeffec) from tcontrpy
                                where	codcompy = v_codcompy
--                                  and	to_char(dteeffec,'dd/mm/yyyy') <= to_char(sysdate,'dd/mm/yyyy'))
                                  and	dteeffec <= v_dteeffex2)
          and	b.codcompy = a.codcompy;
    exception when no_data_found then
      v_pctsoc		:= 0;
      v_numacsoc	:= ' ';
      v_namcomt		:= ' ';
    end;

      data_file := '1' || rpad(nvl(v_numacsoc,' '),10,' ') ||
									 rpad(nvl(v_numbrlvl,' '),6,' ') ||
									 to_char(p_sdate,'dd') || to_char(p_sdate,'mm') ||
									 substr(to_char(to_number(to_char(p_sdate,'yyyy')) - global_v_zyear + 543),3,2) ||
									 lpad(p_dtemthpay,2,'0') ||
									 substr(to_char(p_dteyrepay - global_v_zyear + 543),3,2) ||
									 rpad(nvl(v_namcomt,' '),45,' ') || lpad(v_pctsoc * 100,4,'0') ||
                   lpad(v_sumrec,6,'0') || lpad(v_totamtsoc * 100,15,'0') ||
									 lpad((v_totamtsoca + v_totamtsocc) * 100,14,'0') ||
									 lpad((v_totamtsoca) * 100,12,'0') ||
									 lpad((v_totamtsocc) * 100,12,'0');

      --UTL_FILE.Put_line(out_file,data_file);
--      data_file := convert(data_file,'TH8TISASCII');
      if data_file is not null then
        UTL_FILE.Put_line(out_file,data_file);
      end if;

      for i in 0..v_sumrec - 1 loop
        v_cntrec := nvl(v_cntrec,0) + 1;
        data_file := '2'||rpad(nvl(data_numsaid(i),' '),13,' ')||
                     rpad(nvl(data_prefix(i),' '),3,' ')||
                     rpad(substr(nvl(data_namfirstt(i),' '),1,30),30,' ')||
                     rpad(substr(nvl(data_namlastt(i),' '),1,35),35,' ')||
                     lpad(substr(data_amtsoc(i),1,14),14,'0')||
                     lpad(substr(data_amtsoca(i),1,12),12,'0');

       -- Text_IO.Put_line(out_file,rpad(data_file,135,' '));
--        data_file := convert(data_file,'TH8TISASCII');
        if data_file is not null then
          UTL_FILE.Put_line(out_file,rpad(data_file,135,' '));
        end if;
      end loop;
    end if;

    UTL_FILE.FClose(out_file);
    sync_log_file(v_filename);
    if v_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TTAXCUR');
   	elsif v_flgsecur = 'N'   then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numrec', nvl(v_cntrec,0));
      obj_data.put('path',p_file_path || v_filename);

      -- set complete batch process
      global_v_batch_flgproc  := 'Y';
      global_v_batch_qtyproc  := nvl(v_cntrec,0);
      global_v_batch_filename := v_filename;
      global_v_batch_pathfile := p_file_path || v_filename;

      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));

      json_str_output := obj_data.to_clob;
    end if;

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
  end process_data;

  function check_index_batchtask(json_str_input clob) return varchar2 is
    v_response    varchar2(4000 char);
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is not null then
      v_response := replace(param_msg_error,'@#$%400');
    end if;
    return v_response;
  end;

end HRPY80B;

/

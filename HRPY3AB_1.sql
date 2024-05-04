--------------------------------------------------------
--  DDL for Package Body HRPY3AB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY3AB" as

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    -- index params
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  function cal_hhmiss (p_st date,p_en date) return varchar2 is
    v_num  number := 0;
    v_sc   number := 0;
    v_mi   number := 0;
    v_hr   number := 0;
    v_time varchar2(500 char);
  begin
    v_num  := ((p_en - p_st) * 86400) + 1;
    v_hr   := trunc(v_num/3600);
    v_mi   := mod  (v_num,3600);
    v_sc   := mod  (v_mi ,60);
    v_mi   := trunc(v_mi /60);
    v_time := lpad(v_hr,2,0) || ':' || lpad(v_mi,2,0) || ':' || lpad(v_sc,2,0);
    return (v_time);
  end;

  procedure check_index is
    v_temp				number;
  begin
    if p_codempid is not null then
      begin
        select codempid into v_temp
        from temploy1
        where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang);
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
      p_codcomp := null;
    else
      begin
        select codcodec into v_temp
        from	tcodtypy
        where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCODTYPY');
        return;
      end;
      --
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end check_index;

  procedure get_process (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    --check_index;
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
    obj_data          json_object_t;
    o_numrec          number;
    o_time            varchar2(100 char);
    v_response        varchar2(4000 char);
    v_sysdate_before  date;
    v_sysdate_after   date;
  begin
    v_sysdate_before := sysdate;
    start_process (o_numrec) ;
    v_sysdate_after  := sysdate;
    obj_data := json_object_t();

    obj_data.put('numrec', nvl(o_numrec,0));
    obj_data.put('time', cal_hhmiss(v_sysdate_before,v_sysdate_after));

    if v_flg_data and not v_flg_se then
      obj_data.put('coderror', '400');
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    elsif not v_flg_data then
      obj_data.put('coderror', '400');
      param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TTAXCUR');
    else
      obj_data.put('coderror', '200');
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);

      -- set complete batch process
      global_v_batch_flgproc := 'Y';
      global_v_batch_qtyproc := nvl(o_numrec,0);
    end if;

    v_response := get_response_message(null,param_msg_error,global_v_lang);
    obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));

    json_str_output := obj_data.to_clob;
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


----------------------
  procedure start_process (o_numrec out number) is

  /*
  (p_codcompy		in	varchar2,
                           p_typpayroll in	varchar2,
                           p_dteyrepay  in	number,
                           p_dtemthpay  in	number,
                           p_numperiod  in	number,
                           p_coduser		in	varchar2) is
  */
  begin
    indx_codcompy     := p_codcomp;
    indx_codempid     := p_codempid;
    indx_typpayroll   := p_typpayroll;
    indx_dteyrepay    := p_dteyrepay;

    indx_dtemthpay    := p_dtemthpay;
    indx_numperiod    := p_numperiod;
    para_coduser	 	  := global_v_coduser;

    begin
      select get_numdec(numlvlsalst,global_v_coduser) numlvlst ,get_numdec(numlvlsalen,global_v_coduser) numlvlen
        into para_numlvlsalst,para_numlvlsalen
        from tusrprof
       where coduser = para_coduser ;
    exception when others then
      null;
    end ;
    -- create tprocount

    gen_group;
    -- create tprocemp
    gen_group_emp;
    -- create Job & Process
    gen_job;

    begin
      select sum(qtyproc)
      into   o_numrec
      from   tprocount
      where coduser = para_coduser and codapp = para_codapp ;
    exception when others then
      null;
    end ;

  end;

  procedure gen_group is
  begin
    delete tprocount where codapp = para_codapp and coduser = para_coduser; commit;
    for i in 1..para_numproc loop

      insert into tprocount(codapp,coduser,numproc,

                            qtyproc,flgproc,qtyerr)
                     values(para_codapp,para_coduser,i,
                            0,'N',0);
    end loop;
    commit;
  end;

  procedure gen_group_emp is
    v_numproc		number := 1;
    v_zupdsal		varchar2(50 char);
    v_flgsecu		boolean;
    v_cnt				number;
    v_rownumst	number;
    v_rownumen	number;

  cursor c_ttaxcur is
     select codempid,codcomp,numlvl
       from ttaxcur
      where dteyrepay     = (indx_dteyrepay - para_zyear)
        and dtemthpay     = indx_dtemthpay
        and numperiod     = indx_numperiod
        and codcomp       like nvl(indx_codcompy,codcomp)||'%'
        and codempid      = nvl(indx_codempid,codempid)
        and typpayroll    = nvl(indx_typpayroll,typpayroll)
   order by codempid;

  begin
    if indx_dteyrepay > 2500 then
      para_zyear  := 543;
    else
      para_zyear  := 0;
    end if;


    delete tprocemp where codapp = para_codapp and coduser = para_coduser; commit;
    for r_emp in c_ttaxcur loop
      v_flg_data := true;
      v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,para_numlvlsalst,para_numlvlsalen,v_zupdsal);
      if v_flgsecu then
        v_flg_se := true;
        begin
          insert into tprocemp(codapp,coduser,numproc,codempid)
               values         (para_codapp,para_coduser,v_numproc,r_emp.codempid);
        exception when dup_val_on_index then null;
        end;
      end if;
    end loop;
    commit;
    -- change numproc
    begin
      select count(*) into v_cnt
        from tprocemp
       where codapp  = para_codapp
         and coduser = para_coduser;

    end;

    if v_cnt > 0 then
      v_rownumst := 1;
      for i in 1..para_numproc loop
        if v_cnt < para_numproc then
          v_rownumen := v_cnt;
        else
          v_rownumen := ceil(v_cnt/para_numproc);
        end if;
        --
        update tprocemp
           set numproc = i
         where codapp  = para_codapp
           and coduser = para_coduser
           and numproc = v_numproc
           and rownum  between v_rownumst and v_rownumen;
      end loop;
    end if;
    commit;
  end;

  procedure gen_job is
    v_stmt			varchar2(1000 char);
    v_interval	varchar2(50 char);
    v_finish		varchar2(1 char);
    v_num       number := 0;

    type a_number is table of number index by binary_integer;
       a_jobno	a_number;

  begin
  hrpy3ab.cal_process(para_codapp,para_coduser,1,indx_codcompy,
                      indx_typpayroll,
                      indx_dteyrepay,
                      indx_dtemthpay,
                      indx_numperiod ); 

    /*--
    for i in 1..para_numproc loop
      v_stmt := 'hrpy3ab.cal_process('''||para_codapp||''','''||para_coduser||''','||i||','''
                ||indx_codcompy||''','''
                ||indx_typpayroll||''','
                ||indx_dteyrepay||','
                ||indx_dtemthpay||','
                ||indx_numperiod||');';

      dbms_job.submit(a_jobno(i),v_stmt,sysdate,v_interval); commit;
    end loop;


    v_finish := 'N';
    loop
      for i in 1..para_numproc loop
        begin
          select 'N' into v_finish
            from user_jobs
           where job = a_jobno(i);
          exit;
        exception when no_data_found then
          v_finish := 'Y';
        end;
      end loop;
      if v_finish = 'Y' then
        exit;
      end if;
    end loop;
    */
  end;
  --
  procedure cal_process (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcompy		in	varchar2,
                         p_typpayroll in	varchar2,
                         p_dteyrepay  in	number,
                         p_dtemthpay  in	number,
                         p_numperiod  in	number) is

    v_flgsecu			boolean;
    v_codempid		temploy1.codempid%type;
    v_codpay			tgltabi.codpay%type;
    v_empflg			varchar2(1 char);
    v_costcent    tcenter.costcent%type;
    v_dteend			date;
    v_amt					number;
    v_amt_e				number;
    v_codcomp			tcenter.codcomp%type;
    v_nummax      number;
    v_numseq      number;
    v_zupdsal     varchar2(1 char);
    v_numrec      number := 0;
    v_period      varchar2(100 char);
    v_codpaypy5   tcontrpy.codpaypy5%type;

    type p_num is table of number index by binary_integer;
      v_amtcost        p_num;

    cursor c_emp is
      select b.codempid,b.codcomp,b.numlvl,b.codcompy
        from tprocemp a, ttaxcur b
       where a.codempid   = b.codempid
         and a.codapp     = p_codapp
         and a.coduser    = p_coduser
         and a.numproc    = p_numproc
         and dteyrepay    = (indx_dteyrepay - para_zyear)
         and dtemthpay    = indx_dtemthpay
         and numperiod    = indx_numperiod
      order by a.codempid;

    cursor c_tsincexp is
      select rowid,codcomp,codpay,codcurr,flgslip,
             stddec(amtpay,codempid,para_chken) amtpay
        from tsincexp
       where codempid  = v_codempid
         and dteyrepay = (p_dteyrepay - para_zyear)
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod
         --and flgslip   = '1'
    order by codpay;

    cursor c_totsumd is
      select codcompw,costcent,sum(stddec(amtspot,codempid,para_chken)) amtpay
        from totsumd
       where codempid  = v_codempid
         and dteyrepay = (p_dteyrepay - para_zyear)
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod
    group by codcompw,costcent
    order by codcompw;

   cursor c_tothinc2 is
      select codcompw,costcent,sum(stddec(amtpay,codempid,para_chken)) amtpay
        from tothinc2
       where codempid  = v_codempid
         and dteyrepay = (p_dteyrepay - para_zyear)
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod
         and codpay     = v_codpay
    group by codcompw,costcent
    order by codcompw;

    cursor c_tothpay is
      select codcompw,costcent,sum(stddec(amtpay,codempid,para_chken)) amtpay
        from tothpay
       where codempid  = v_codempid
         and dteyrepay = (p_dteyrepay - para_zyear)
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod
         and codpay     = v_codpay
    group by codcompw,costcent
    order by codcompw;

    cursor c_tcostemp is
      select codcomp,costcent,pctchg
        from tcostemp
       where codempid = v_codempid
         and codpay   = v_codpay
         and v_period between dteyearst||lpad(dtemthst,2,'0')||lpad(numprdst,2,'0') and dteyearen||lpad(dtemthen,2,'0')||lpad(numprden,2,'0')
    order by costcent;
  begin
    if p_dteyrepay > 2500 then
      para_zyear  := 543;
    else
      para_zyear  := 0;
    end if;
    v_period := (p_dteyrepay - para_zyear)||lpad(p_dtemthpay,2,'0')||lpad(p_numperiod,2,'0') ;

    begin
      select dteend into v_dteend
        from tdtepay
       where codcompy   = p_codcompy
         and typpayroll = p_typpayroll
         and dteyrepay  = (p_dteyrepay - para_zyear)
         and dtemthpay  = p_dtemthpay
         and numperiod  = p_numperiod;
    exception when no_data_found then
      v_dteend := trunc(sysdate);
    end;

    for r_ttaxcur in c_emp loop
      v_numrec   := v_numrec + 1;
      v_codempid := r_ttaxcur.codempid;
      v_codcomp  := r_ttaxcur.codcomp;
      v_empflg   := 'N';
      delete from tsinexct
       where codempid  = v_codempid
         and dteyrepay = (p_dteyrepay - para_zyear)
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod;

         begin
          select codpaypy5 into v_codpaypy5
            from tcontrpy
           where codcompy  = r_ttaxcur.codcompy
             and dteeffec  = (select max(dteeffec)
                                from tcontrpy
                               where codcompy  = r_ttaxcur.codcompy
                                 and trunc(dteeffec)  <= trunc(sysdate));
        exception when no_data_found then v_codpaypy5 := null;
        end;
      for r_tsincexp in c_tsincexp loop
        v_codpay := r_tsincexp.codpay;
        v_amt    := r_tsincexp.amtpay;
        v_empflg := 'N';
        --1. totsumd
        if v_codpaypy5 = r_tsincexp.codpay then
              begin
                select count(codcompw) into v_nummax
                  from totsumd
                 where codempid   = r_ttaxcur.codempid
                   and dteyrepay  = (p_dteyrepay - para_zyear)
                   and dtemthpay  = p_dtemthpay
                   and numperiod  = p_numperiod
                   and codcompw  <> r_ttaxcur.codcomp;
              end;
              if v_nummax > 0 then
                v_empflg := 'Y';
                for r_totsumd in c_totsumd loop
                  upd_tsinexct(r_ttaxcur.codempid,p_dteyrepay,p_dtemthpay,p_numperiod,
                               r_tsincexp.codpay,nvl(r_totsumd.costcent,' '),
                               r_totsumd.codcompw,r_totsumd.amtpay,p_coduser);
                end loop; -- c_totsumd
                ---ให้ select codcompw,   sum(amtspot)  from totsumd group ตาม  codcompw เพื่อ Insert ลง tsinexct
              end if;
        end if;          

        --2. tothinc2
        if   v_empflg = 'N' then
            begin
              select count(codcompw) into v_nummax
                from tothinc2
               where codempid   = r_ttaxcur.codempid
                 and dteyrepay  = (p_dteyrepay - para_zyear)
                 and dtemthpay  = p_dtemthpay
                 and numperiod  = p_numperiod
                 and codcompw  <> r_ttaxcur.codcomp
                 and codpay     = v_codpay;
            end;
             if v_nummax > 0 then
                 for r_tothinc2 in c_tothinc2 loop
                      upd_tsinexct(r_ttaxcur.codempid,p_dteyrepay,p_dtemthpay,p_numperiod,
                                   r_tsincexp.codpay,nvl(r_tothinc2.costcent,' '),
                                   r_tothinc2.codcompw,r_tothinc2.amtpay,p_coduser);
                      v_empflg := 'Y';    
                 end loop; -- c_totsumd         
            end if; 
        end if;      
        --3. tothpay
        if v_empflg = 'N' then
             for r_ttothpay in c_tothpay loop
                      upd_tsinexct(r_ttaxcur.codempid,p_dteyrepay,p_dtemthpay,p_numperiod,
                                   r_tsincexp.codpay,nvl(r_ttothpay.costcent,' '),
                                   r_ttothpay.codcompw,r_ttothpay.amtpay,p_coduser);
                      v_empflg := 'Y';        
             end loop; -- c_totsumd
        end if; -- v_empflg = 'N'
        --4. tcostemp
        if v_empflg = 'N' then
          begin
            select count(*) into v_nummax
              from tcostemp
             where codempid  =  v_codempid
               and codpay    =  v_codpay
               and dteyearst||lpad(dtemthst,2,'0')||lpad(numprdst,2,'0') between v_period
               and dteyearen||lpad(dtemthen,2,'0')||lpad(numprden,2,'0') ;
          end;
          v_numseq := 0;
          for r_tcostemp in c_tcostemp loop
            v_numseq := v_numseq + 1;
            v_empflg := 'Y';
            if v_numseq = v_nummax then
              v_amt := 0;
              for j in 1..(v_nummax -1) loop
                v_amt := v_amt + round(v_amtcost(j),2);
              end loop;
              v_amt := r_tsincexp.amtpay - v_amt;
            else
              v_amt := r_tsincexp.amtpay * r_tcostemp.pctchg / 100;
              v_amtcost(v_numseq)  := v_amt;
            end if;
            --
            begin
              select nvl(costcent,' ') into v_costcent
                from tcenter
               where codcomp = r_tcostemp.codcomp;
            exception when no_data_found then
              v_costcent := ' ';
            end;
            v_codcomp := r_tcostemp.codcomp;
            upd_tsinexct(v_codempid,p_dteyrepay,p_dtemthpay,
                         p_numperiod,v_codpay,v_costcent,
                         v_codcomp,v_amt,p_coduser);
          end loop; -- for c_tcostemp
        end if; -- v_empflg = 'N'

        begin
          select nvl(costcent,' ') into v_costcent
            from tcenter
           where codcomp = r_tsincexp.codcomp;
        exception when no_data_found then
          v_costcent := ' ';
        end;
        if  v_empflg = 'N' then
          upd_tsinexct(v_codempid,p_dteyrepay,p_dtemthpay,
                       p_numperiod,v_codpay,v_costcent,
                       v_codcomp,v_amt,p_coduser);
        end if;
        --
        update tsincexp
           set costcent = v_costcent,
               dteupd   = trunc(sysdate),
               coduser  = p_coduser
         where rowid = r_tsincexp.rowid;
      end loop; -- for c_tsincexp
    end loop; -- for c_ttaxcur

    update tprocount
       set qtyproc  = nvl(qtyproc,0) + v_numrec,
           flgproc  = 'Y'
     where codapp   = p_codapp
       and coduser  = p_coduser
       and numproc  = p_numproc ;
    commit;
  exception when others then
    rollback;
  end;

  procedure upd_tsinexct(p_codempid 		in varchar2,
                         p_dteyrepay    in number,
                         p_dtemthpay    in number,
                         p_numperiod    in number,
                         p_codpay				in varchar2,
                         p_costcent			in varchar2,
                         p_codcomp			in varchar2,
                         p_amt					in number,
                         p_coduser      in varchar2) is
    v_count			number;
  begin
     select count(*) into v_count
       from tsinexct
      where	codempid  = p_codempid
        and dteyrepay	=	(p_dteyrepay - para_zyear)
        and dtemthpay	=	p_dtemthpay
        and numperiod	=	p_numperiod
        and codpay    = p_codpay
        and codcomp   = p_codcomp;
    if v_count > 0 then
      update tsinexct
         set amtpay   = stdenc(stddec(amtpay,codempid,para_chken) + p_amt,codempid,para_chken),
             costcent = p_costcent,
             dteupd   = trunc(sysdate),
             coduser  = p_coduser
      where	codempid  = p_codempid
        and dteyrepay	=	(p_dteyrepay - para_zyear)
        and dtemthpay	=	p_dtemthpay
        and numperiod	=	p_numperiod
        and codpay    = p_codpay
        and codcomp   = p_codcomp;
    else
      insert into tsinexct(codempid,dteyrepay,dtemthpay,
                           numperiod,codpay,codcomp,
                           costcent,amtpay,dteupd,coduser,dtecreate,codcreate)
             values       (p_codempid,(p_dteyrepay - para_zyear),p_dtemthpay,
                           p_numperiod,p_codpay,p_codcomp,
                           p_costcent,stdenc(p_amt,p_codempid,para_chken),
                           trunc(sysdate),p_coduser,trunc(sysdate),p_coduser);
    end if;
  end;

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

----------------------
end HRPY3AB;

/

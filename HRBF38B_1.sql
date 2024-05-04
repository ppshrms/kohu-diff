--------------------------------------------------------
--  DDL for Package Body HRBF38B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF38B" as
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

    p_dtemthpay   := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay   := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_period      := to_number(hcm_util.get_string_t(json_obj,'p_period'));
    p_month       := to_number(hcm_util.get_string_t(json_obj,'p_month'));
    p_year        := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    p_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll  := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_numisr      := hcm_util.get_string_t(json_obj,'p_numisr');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure check_index is
    v_codcodec    varchar2(10 char);
    v_codcomp     varchar2(100 char);
    v_numisr      varchar2(100 char);
    v_secur       boolean;

    cursor c_dtepay_last is
      select dteyrepay,dtemthpay,numperiod
        from tdtepay
       where codcompy = p_codcomp
         and typpayroll = p_typpayroll
         and flgcal = 'Y'
    order by dteyrepay,dtemthpay,numperiod;
  begin
    if p_codcomp is not null then
      begin
        select codcomp
          into v_codcomp
          from tcenter
         where codcomp = get_compful(p_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
      v_secur := secur_main.secur7(v_codcomp,global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;

    if p_numisr is not null then
      begin
        select numisr
          into v_numisr
          from tisrinf
         where numisr = p_numisr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tisrinf');
        return;
      end;
      if p_codcomp is not null then
        begin
          select numisr
            into v_numisr
            from tisrinf
           where numisr = p_numisr
           and p_codcomp like codcompy||'%';
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tisrinf');
          return;
        end;
      end if;
    end if;

    if p_typpayroll is not null then
      begin
        select codcodec
          into v_codcodec
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCODTYPY');
        return;
      end;
    end if;

    for r1 in c_dtepay_last loop
      if r1.dteyrepay||''||r1.dtemthpay||''||r1.numperiod = p_year||''||p_month||''||p_period then
        param_msg_error := get_error_msg_php('HR7517', global_v_lang);
        exit;
      end if;
    end loop;
    if param_msg_error is not null then
      return;
    end if;
  end check_index;
  --
  procedure process_data(json_str_output out clob) is
    obj_data        json_object_t;
    v_data          varchar2(1 char) := 'N';
--    v_flgsecur      varchar2(1 char) := 'N';
    v_flg           varchar2(1 char);
    data_file 			varchar2(4000 char);
    v_exist			varchar2(1) := 'N';
    v_secur			varchar2(1) := 'N';
    --v_timeout 	number:= get_tsetup_value('TIMEOUT') ;
    v_numproc  	number:= 5;
    v_qtyproc   number:= 0;
    v_qtyerr    number:= 0;
    v_dtestr  	date;
    v_dteend  	date;
    v_periodst	number;
    v_perioden	number;
    v_numerr	  number;
    v_time      varchar2(100 char);
    v_err       varchar2(4000 char);
    v_response  varchar2(4000 char);

    v_flgisr          varchar2(1000 char);
    v_desc_flgisr     varchar2(1000 char);

  begin
--    check_index;
		v_dtestr := sysdate;
--    create tprocount
    gen_group;
--     create tprocemp
    gen_group_emp;
--     create Job
    gen_job;

    begin
      select sum(QTYPROC), sum(QTYPROC2) into p_numrec,p_amount
        from tprocount
       where CODAPP = global_v_batch_codapp
         and CODUSER = global_v_coduser;
    exception when no_data_found then
      p_numrec := 0; p_amount := 0;
    end;
    begin
      select flgisr into v_flgisr
        from tisrinf
       where numisr = p_numisr;
    exception when no_data_found then
      v_flgisr := null;
    end;
    v_desc_flgisr := '';
    if v_flgisr is not null then
      v_desc_flgisr := get_tlistval_name('TYPEPAYINS', v_flgisr, global_v_lang);
    end if;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dtemthpay', p_dtemthpay );
    obj_data.put('dteyrepay', p_dteyrepay );
    obj_data.put('codcomp', p_codcomp );
    obj_data.put('typpayroll', p_typpayroll );
    obj_data.put('numisr', p_numisr );
    obj_data.put('period', p_period );
    obj_data.put('month', p_month );
    obj_data.put('year', p_year );
    obj_data.put('insure', v_desc_flgisr );
    obj_data.put('numrec', p_numrec);
    obj_data.put('amount', p_amount );

    param_msg_error := get_error_msg_php('HR2715',global_v_lang);
    v_response := get_response_message(null,param_msg_error,global_v_lang);
    obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end process_data;
  --
  procedure get_process(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      process_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_process;

  procedure gen_group is
  begin
    delete tprocount where codapp = global_v_batch_codapp and coduser = global_v_coduser; commit;
    for i in 1..para_numproc loop
      insert into tprocount(codapp,coduser,numproc,
                            qtyproc,flgproc,qtyerr)
                     values(global_v_batch_codapp,global_v_coduser,i,
                            0,'N',0);
    end loop;
    commit;
  end;
  procedure gen_group_emp is
    v_numproc		  number := 99;
    v_zupdsal		  varchar2(50 char);
    v_flgsecur		boolean := false;
    v_cnt				  number;
    v_rownumst	  number;
    v_rownumen	  number;

    v_periodst		number;
    v_perioden		number;

    cursor c_tinsrer is
      select a.codempid,a.flgisr,a.amtpmiumme,a.amtpmiumye,a.codcomp,a.typpayroll,b.typemp,a.numisr
        from tinsrer a, temploy1 b
       where a.codempid     = b.codempid
         and a.codcomp      like p_codcomp||'%'
         and a.typpayroll   = p_typpayroll
         and a.numisr       = nvl(p_numisr,a.numisr)
         and a.flgemp       = '1'
         and(a.amtpmiumme   > 0
          or a.amtpmiumye   > 0)
         and not exists (select c.codempid
                           from tinsdinf c, tisrinf d
                          where c.numisr     = d.numisr
                            and a.numisr     = c.numisr
                            and a.codempid   = c.codempid
                            and(
                               (d.flgisr     = '1'
                            and c.dteyear    = p_dteyrepay
                            and c.dtemonth   = p_dtemthpay)
                             or(d.flgisr     = '4'
                            and c.dteyear    = p_dteyrepay)
                                )
                         )
    order by a.codempid;

  begin

    if p_dteyrepay > 2500 then
      global_v_zyear  := 543;
    else
      global_v_zyear  := 0;
    end if;

    if nvl(p_period,0) > 0 then
      v_periodst := p_period;
      v_perioden := p_period;
    else
      v_periodst := 1;
      v_perioden := 9;
    end if;

    delete tprocemp where codapp = global_v_batch_codapp and coduser = global_v_coduser; commit;
    for r_emp in c_tinsrer loop
      v_flgsecur := secur_main.secur2(r_emp.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if v_flgsecur then
        begin
          insert into tprocemp(codapp,coduser,numproc,codempid)
               values         (global_v_batch_codapp,global_v_coduser,v_numproc,r_emp.codempid);
        exception when dup_val_on_index then null;
        end;
      end if;
    end loop;
    commit;
    -- change numproc
    begin
      select count(*) into v_cnt
        from tprocemp
       where codapp  = global_v_batch_codapp
         and coduser = global_v_coduser;
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
         where codapp  = global_v_batch_codapp
           and coduser = global_v_coduser
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

    type a_number is table of number index by binary_integer;
       a_jobno	a_number;
  begin
    for i in 1..para_numproc loop
      v_stmt := 'hrbf38b.cal_process('''||global_v_batch_codapp||''','''||global_v_coduser||''','||i||','''
                                        ||p_codcomp||''','''
                                        ||p_typpayroll||''','''
                                        ||p_numisr||''','
                                        ||p_dtemthpay||','
                                        ||p_dteyrepay||','
                                        ||p_period||','
                                        ||p_month||','
                                        ||p_year||');';
      dbms_job.submit(a_jobno(i),v_stmt,sysdate,v_interval); commit;
    end loop;
    --
    v_finish := 'N';
    loop
      for i in 1..para_numproc loop
        dbms_lock.sleep(10);
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
  end;
  --
  procedure cal_process (p_codapp   	in  varchar2,
                         p_coduser   	in  varchar2,
                         p_numproc	  in  number,
                         p_codcomp		in	varchar2,
                         p_typpayroll in	varchar2,
                         p_numisr     in	varchar2,
                         p_dtemonth   in  number,
                         p_dteyear	  in  number,
                         p_numprdpay  in	number,
                         p_dtemthpay  in	number,
                         p_dteyrepay  in	number) is
    v_rec         number := 0;
    v_amt         number := 0;
    v_numseq      number := 0;
    v_flgsecu			boolean;
    v_zupdsal     varchar2(20 char);
    v_coddisisr   tcontrbf.coddisisr%type;
    v_costcent    tcenter.costcent%type;
    v_chken       varchar2(10 char) := hcm_secur.get_v_chken;

    cursor c1_tinsrer is
      select a.numisr,a.codempid,a.dtehlpst,a.dtehlpen,a.codcomp,a.typpayroll,b.typemp,
             a.codisrp,a.amtisrp,a.amtpmiumme,a.amtpmiumye,a.amtpmiummc,a.amtpmiumyc
        from tinsrer a, temploy1 b, tprocemp z
       where a.codempid     = b.codempid
         and z.codempid     = b.codempid
	   		 and z.codapp       = p_codapp
	  		 and z.coduser      = p_coduser
	  		 and z.numproc      = p_numproc
         and a.codcomp      like p_codcomp||'%'
         and a.typpayroll   = nvl(p_typpayroll, a.typpayroll)
         and a.numisr       = nvl(p_numisr,a.numisr)
         and a.flgemp       = '1'
         and(a.amtpmiumme   > 0
          or a.amtpmiumye   > 0)
         and not exists (select c.codempid
                           from tinsdinf c, tisrinf d
                          where c.numisr     = d.numisr
                            and a.numisr     = c.numisr
                            and a.codempid   = c.codempid
                            and((d.flgisr    = '1'
                            and c.dteyear    = p_dteyear
                            and c.dtemonth   = p_dtemonth)
                             or(d.flgisr     = '4'
                            and c.dteyear    = p_dteyear)))
    order by a.codempid;
  begin
    hcm_secur.get_global_secur(p_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    --
    for r1 in c1_tinsrer loop
      if secur_main.secur2(r1.codempid,p_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        begin
          select coddisisr
            into v_coddisisr
            from tcontrbf
           where codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
             and dteeffec = (select max(dteeffec)
                               from tcontrbf
                              where codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
                                and dteeffec <= sysdate);
        exception when no_data_found then v_coddisisr := null;
        end;
        if v_coddisisr is not null and p_dteyear||lpad(p_dtemonth,2,'0') between to_char(r1.dtehlpst,'yyyymm') and to_char(r1.dtehlpen,'yyyymm') then
          begin
            insert into tinsdinf(codempid,numisr,dteyear,dtemonth,
                                 typpayroll,codcomp,codisrp,amtisrp,amtpmiume,amtpmiumc,
                                 flgtranpy,numprdpay,dtemthpay,dteyrepay,
                                 dtecreate,codcreate,dteupd,coduser)
                          values(r1.codempid,r1.numisr,p_dteyear,p_dtemonth,
                                 r1.typpayroll,r1.codcomp,r1.codisrp,r1.amtisrp,nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiumye,0),nvl(r1.amtpmiummc,0) + nvl(r1.amtpmiumyc,0),
                                 'Y',p_numprdpay,p_dtemthpay,p_dteyrepay,
                                 sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then null;
          end;
          --
          begin
            insert into tdepltdte(numisr,codcomp,typpayroll,dteyear,dtemonth,
                                  flgtrnpy,qtypmium,amtpmium,numperiod,dtemthpay,dteyrepay,
                                  dtecreate,codcreate,dteupd,coduser)
                           values(r1.numisr,r1.codcomp,r1.typpayroll,p_dteyear,p_dtemonth,
                                  'Y',1,nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiumye,0),p_numprdpay,p_dtemthpay,p_dteyrepay,
                                  sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then
            update tdepltdte
               set qtypmium    = nvl(qtypmium,0) + 1,
                   amtpmium    = nvl(amtpmium,0) + nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiumye,0),
                   dteupd      = sysdate,
                   coduser     = p_coduser
             where numisr      = r1.numisr
               and codcomp     = r1.codcomp
               and typpayroll  = r1.typpayroll
               and dteyear     = p_dteyear
               and dtemonth    = p_dtemonth;
          end;
          --
          begin
            select costcent
              into v_costcent
              from tcenter
             where codcomp  = r1.codcomp;
          exception when no_data_found then v_costcent := null;
          end;
          begin
            insert into tothinc(codempid,dteyrepay,dtemthpay,numperiod,codpay,
                                codcomp,typpayroll,typemp,
                                amtpay,
                                codsys,costcent,
                                dtecreate,codcreate,dteupd,coduser)
                         values(r1.codempid,p_dteyrepay,p_dtemthpay,p_numprdpay,v_coddisisr,
                                r1.codcomp,r1.typpayroll,r1.typemp,
                                stdenc(nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiumye,0),r1.codempid,v_chken),
                                'BF',v_costcent,
                                sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then null;
            update tothinc
               set codcomp    = r1.codcomp,
                   typpayroll = r1.typpayroll,
                   typemp     = r1.typemp,
                   amtpay     = stdenc(nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiumye,0),r1.codempid,v_chken),--stdenc(nvl(stddec(amtpay,codempid,v_chken),0) + nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiumye,0),codempid,v_chken),
                   codsys		  = 'BF',
                   costcent   = v_costcent,
                   dteupd     = sysdate,
                   coduser    = p_coduser
             where codempid   = r1.codempid
               and dteyrepay  = p_dteyrepay
               and dtemthpay  = p_dtemthpay
               and numperiod  = p_numprdpay
               and codpay     = v_coddisisr;
          end;
          --
          begin
            insert into tothinc2(codempid,dteyrepay,dtemthpay,numperiod,codpay,codcompw,
                                 amtpay,
                                 codsys,costcent,
                                 dtecreate,codcreate,dteupd,coduser)
                          values(r1.codempid,p_dteyrepay,p_dtemthpay,p_numprdpay,v_coddisisr,r1.codcomp,
                                 stdenc(nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiumye,0),r1.codempid,v_chken),
                                 'BF',v_costcent,
                                 sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then
            update tothinc2
               set amtpay     = stdenc(nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiumye,0),r1.codempid,v_chken),
                   codsys		  = 'BF',
                   costcent   = v_costcent,
                   dteupd     = sysdate,
                   coduser    = p_coduser
             where codempid   = r1.codempid
               and dteyrepay  = p_dteyrepay
               and dtemthpay  = p_dtemthpay
               and numperiod  = p_numprdpay
               and codpay     = v_coddisisr
               and codcompw   = r1.codcomp;
          end;
          --
          v_rec := nvl(v_rec,0) + 1;
          v_amt := nvl(v_amt,0) + nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiumye,0);
        end if;
      end if; -- secur_main
    end loop; --c1_temploy1 loop
    --
    update tprocount
       set qtyproc  = v_rec,
           qtyproc2 = v_amt,
           flgproc  = 'Y'
     where codapp 	= p_codapp
       and coduser 	= p_coduser
       and numproc 	= p_numproc;
    commit;
	exception when others then
    rollback;
    update tprocount
       set qtyproc  = v_rec,
           qtyproc2 = v_amt,
           flgproc  = 'E'
     where codapp 	= p_codapp
       and coduser 	= p_coduser
       and numproc 	= p_numproc;
    commit;
  end;
  --
  procedure get_flgisr(json_str_input in clob, json_str_output out clob) is
    obj_data          json_object_t;
    v_flgisr          varchar2(1000 char);
    v_desc_flgisr     varchar2(1000 char);
  begin
    initial_value(json_str_input);
    begin
      select flgisr into v_flgisr
        from tisrinf
       where numisr = p_numisr;
    exception when no_data_found then
      v_flgisr := null;
    end;

    v_desc_flgisr := '';
    if v_flgisr is not null then
      v_desc_flgisr := get_tlistval_name('TYPEPAYINS', v_flgisr, global_v_lang);
    end if;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('insure', v_desc_flgisr );
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
    --
  procedure get_lastperiod(json_str_input in clob, json_str_output out clob) is
    obj_data          json_object_t;
    v_dtemonth        TDEPLTDTE.DTEMONTH%type;
    v_dteyear         TDEPLTDTE.DTEYEAR%type;
  begin
    initial_value(json_str_input);
    
--    begin
--      select dtemonth, dteyear into v_dtemonth, v_dteyear
--        from tdepltdte
--       where numisr = p_numisr
--         and codcomp = get_compful(p_codcomp)
--         and typpayroll = p_typpayroll
--         and rownum =1
--         order by dteyear desc,dtemonth desc ;  
--      if v_dtemonth = 12 then
--        v_dtemonth := 1;
--        v_dteyear := to_char(sysdate, 'yyyy') + 1;
--      else
--        v_dtemonth := v_dtemonth + 1;
--      end if;
--    exception when no_data_found then
--      v_dtemonth := to_char(sysdate, 'mm');
--      v_dteyear := to_char(sysdate, 'yyyy');
--    end;

    --<<wanlapa #8813 01/02/2023
    begin
      select dtemonth, dteyear into v_dtemonth, v_dteyear
        from tdepltdte
       where numisr = p_numisr
         and codcomp = get_compful(p_codcomp)
         and typpayroll = p_typpayroll
         order by dteyear desc,dtemonth desc 
         fetch first 1 row only;
      
    exception when no_data_found then
      v_dtemonth := to_char(sysdate, 'mm');
      v_dteyear := to_char(sysdate, 'yyyy');
    end;
    
    if v_dtemonth = 12 then
        v_dtemonth := 1;
        v_dteyear := v_dteyear + 1;
    else
        v_dtemonth := v_dtemonth + 1;
    end if;
    
    -->>wanlapa #8813 01/02/2023

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dtemthpay', v_dtemonth );
    obj_data.put('dteyrepay', v_dteyear );
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end hrbf38b;

/

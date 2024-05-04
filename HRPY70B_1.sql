--------------------------------------------------------
--  DDL for Package Body HRPY70B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY70B" as
-- last update: 29/12/2020 20:30

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(obj_detail,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_numperiod  := to_number(hcm_util.get_string_t(obj_detail,'numperiod'));
    p_month      := to_number(hcm_util.get_string_t(obj_detail,'month'));
    p_year       := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp    := hcm_util.get_string_t(obj_detail,'codcomp');
    p_typpayroll := hcm_util.get_string_t(obj_detail,'typpayroll'); --
    p_typbank    := hcm_util.get_string_t(obj_detail,'typbank');
    p_dtepay     := to_date(hcm_util.get_string_t(obj_detail,'dtepay'),'dd/mm/yyyy');
    p_flgtrnbank    := hcm_util.get_string_t(obj_detail,'flgtrnbank');

    p_codempid   := hcm_util.get_string_t(obj_detail,'codempid_query');
    p_codpay     := hcm_util.get_string_t(obj_detail,'codpay');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_process as
    v_chk  number;
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_typbank is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typbank');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    begin
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
        return;
      end;
    end if;
    end;

    v_chk := 0;
--<< user46 14/01/2021 exception then check tdtepay2
/*    begin
      select count(dtepaymt)
        into v_chk
        from tdtepay
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and typpayroll = nvl(p_typpayroll,typpayroll)
         and dteyrepay  = p_year
         and dtemthpay  = p_month
         and numperiod  = p_numperiod;
--         and dtepaymt   = p_dtepay;
    exception when others then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tdtepay');
      return;
    end;
    if v_chk <= 0 then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tdtepay');
      return;
    end if;*/
    begin
      select 1
        into v_chk
        from tdtepay
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and typpayroll = nvl(p_typpayroll,typpayroll)
         and dteyrepay  = p_year
         and dtemthpay  = p_month
         and numperiod  = p_numperiod
         and rownum = 1;
    exception when no_data_found then
      begin
        select 2
          into v_chk
          from tdtepay2
         where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
           and typpayroll = nvl(p_typpayroll,typpayroll)
           and dteyrepay  = p_year
           and dtemthpay  = p_month
           and numperiod  = p_numperiod
           and rownum = 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tdtepay');
        return;
      end;
    end;
-->> user46 14/01/2021
  end check_process;

  procedure get_process(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is null then
        gen_process(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        rollback;
        return;
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
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
      p_oracode   => nvl(global_v_batch_error,param_msg_error)
    );
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;

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

  procedure gen_process(json_str_output out clob) as
    obj_rows        json_object_t := json_object_t();
    obj_row_temp    json_object_t := json_object_t();
    obj_data        json_object_t;
    json_str_detail clob;
    type tcode is table of varchar2(20) index by binary_integer;
    v_codincom      tcode;
    type amtmax is table of number index by binary_integer;
    v_amtmax        amtmax;
    in_file         utl_file.File_Type;
    out_file        utl_file.File_Type;
    v_rec           number := 0;
    v_totemp        number := 0;
    v_totamt        number := 0;
    v_amt           number := 0;
    v_sumamt2       number := 0;
    v_max           number := 0;
    v_amtpay        number;
    v_sumamt        number;
    v_numseq        number;
    v_sumrec        number := 0;
    v_count         number := 0;
    v_count_proc    number := 0;  -- for background process
    v_secure        number := 0;
    v_secure2       number := 0;
    v_flg_data      number := 0;
    v_fstbank       varchar2(1 char);
    v_flgover       varchar2(1 char);
    v_flg           varchar2(1 char);
    v_first         varchar2(1 char) := 'Y';
    v_flgsomeover   varchar2(1 char) := 'N';
    v_codbank2      varchar2(4000 char);
    v_numbank       varchar2(4000 char);
    data_file       varchar2(2000);
    v_filename      varchar2(4000 char);
    v_paid_date     date;
    v_secur         boolean;
    v_secur2        boolean;
    v_codbank       tbnkmdi2.codbank%type;
    v_bankfee       tbnkmdi2.bankfee%type;
    v_numacct       tbnkmdi1.numacct%type;
    v_codbkserv     tbnkmdi1.codbkserv%type;
    v_codcomp       temploy1.codcomp%type;
    v_codempmt      temploy1.codempmt%type;
    v_codempid      temploy1.codempid%type;
    v_dtepaymt      tdtepay.dtepaymt%type;
    v_dtemthpay     tdtepay.dtemthpay%type;
    v_dteyrepay     tdtepay.dteyrepay%type;
    v_task_id       varchar2(4000);
    v_group_amt     number;
    v_group_bank    varchar2(1000 char);
    cursor c_tbnkmdi2 is
      select codbank,codmedia,bankfee
        from tbnkmdi2 b
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and typbank  = p_typbank
    order by codbank;

    cursor c_ttaxcur is
      select a.codempid ,a.codcomp  ,
             a.codbank  ,a.numbank  ,a.amtnet1  ,
             a.codbank2 ,a.numbank2 ,a.amtnet2  ,
             a.dteyrepay,a.dtemthpay,a.numperiod,a.typpayroll
        from ttaxcur a
       where a.codcomp   like p_codcomp || '%'
         and a.dteyrepay = p_year
         and a.dtemthpay = p_month
         and a.numperiod = p_numperiod
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and to_number(stddec(a.amtnet,a.codempid,global_v_chken)) > 0
         and a.typpaymt  = 'BK'
         and ((a.codbank = v_codbank) or (a.codbank2 = v_codbank))
    order by a.codcomp,a.codempid;

  begin
  	-- delete temp
  	delete ttemprpt
  	where codapp = 'HRPY5JXOVR'
      and codempid = global_v_coduser;
--    commit;
    -- text1.txt file write /read
    v_filename := hcm_batchtask.gen_filename(lower('HRPY70B'||'_'||global_v_coduser),'txt',global_v_batch_dtestrt);

    std_deltemp.upd_ttempfile(v_filename,'A'); --'A' = Insert , update ,'D'  = delete
    if utl_file.Is_Open(out_file) then
      utl_file.Fclose(out_file);
    end if;
    out_file := utl_file.Fopen(p_file_dir,v_filename,'w');
    if p_typbank = '31' then
      v_sumrec := 1;
    end if;
    v_flg_data :=0;    
    for r1 in c_tbnkmdi2 loop   
      v_codbank := r1.codbank;
      v_bankfee := nvl(r1.bankfee,0);
      for r2 in c_ttaxcur loop
       v_flg_data := v_flg_data+1;
        v_secur := secur_main.secur3(r2.codcomp,r2.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_secur and v_zupdsal = 'Y' then
          v_secure := v_secure + 1;
          if r2.codbank = v_codbank then
            v_totamt  := v_totamt + to_number(stddec(r2.amtnet1,r2.codempid,global_v_chken));
            v_totemp  := v_totemp + 1;
            update ttaxcur
               set bankfee = v_bankfee,
               flgtrnbank	 = p_flgtrnbank
             where dteyrepay = r2.dteyrepay
               and dtemthpay = r2.dtemthpay
               and numperiod = r2.numperiod
               and codempid  = r2.codempid;
          end if;
          if r2.codbank2 = v_codbank then
            v_totamt := v_totamt + to_number(stddec(r2.amtnet2,r2.codempid,global_v_chken));
            v_totemp := v_totemp + 1;
            update ttaxcur
            set bankfee2 = v_bankfee,
            flgtrnbank	 = p_flgtrnbank
            where dteyrepay = r2.dteyrepay
              and dtemthpay = r2.dtemthpay
              and numperiod = r2.numperiod
              and codempid  = r2.codempid;
          end if;
        end if;
      end loop;
    end loop;
    for r_tbnkmdi1 in c_tbnkmdi2 loop
        v_codbank := r_tbnkmdi1.codbank;
        v_sumamt  :=  0;
        v_numseq  :=  0;
        v_fstbank := 'Y';
      for r_ttaxcur in c_ttaxcur loop
        v_codempid := r_ttaxcur.codempid;
        for i in 1..10 loop
          v_codincom(i) := null;
          v_amtmax(i)   := null;
        end loop;
        begin
          select codcomp,codempmt
          into   v_codcomp,v_codempmt
          from   temploy1
          where  codempid = v_codempid;
        exception when no_data_found then null;
        end;
        begin
          select amtmax1,amtmax2,amtmax3,amtmax4,amtmax5,
                 amtmax6,amtmax7,amtmax8,amtmax9,amtmax10
          into   v_amtmax(1),v_amtmax(2),v_amtmax(3),v_amtmax(4),v_amtmax(5),
                 v_amtmax(6),v_amtmax(7),v_amtmax(8),v_amtmax(9),v_amtmax(10)
          from   tcontpmd
          where  codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
            and  codempmt = v_codempmt
            and  dteeffec = (select max(dteeffec)
                             from   tcontpmd
                             where  codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                               and  codempmt = v_codempmt
                               and  dteeffec <= sysdate)
            and  amtmax1||amtmax2||amtmax3||amtmax4||amtmax5||
                 amtmax6||amtmax7||amtmax8||amtmax9||amtmax10 is not null;
        exception when no_data_found then
          goto normal_process;
        end;
        begin
          select codincom1,codincom2,codincom3,codincom4,codincom5,
                 codincom6,codincom7,codincom8,codincom9,codincom10
          into   v_codincom(1),v_codincom(2),v_codincom(3),v_codincom(4),v_codincom(5),
                 v_codincom(6),v_codincom(7),v_codincom(8),v_codincom(9),v_codincom(10)
          from    tcontpms
          where   codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
          and    dteeffec = (select max(dteeffec)
                             from   tcontpms
                             where  codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                               and  dteeffec <= trunc(sysdate));
        exception when no_data_found then null;
        end;
        for i in 1..10 loop
          if v_codincom(i) is not null and v_amtmax(i) is not null then
            chk_over_income_rep(v_codempid,r_ttaxcur.dteyrepay,r_ttaxcur.dtemthpay,r_ttaxcur.numperiod,v_codincom(i),global_v_coduser,global_v_lang,v_max,v_amt,v_flgover);
            if v_flgover = 'Y' then
              v_flgsomeover := 'Y';
            end if;
          end if;
        end loop;
        <<normal_process>>
         v_secur2 := secur_main.secur2(r_ttaxcur.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_secur2 and v_zupdsal = 'Y' then

        v_codempid :=  r_ttaxcur.codempid;
        if v_fstbank = 'Y' then
          obj_data := json_object_t();
          obj_data.put('numseq','');
          obj_data.put('acc_number','');
          obj_data.put('codempid','');
          obj_data.put('amount','');
          obj_data.put('desc_bank','');
          obj_data.put('desc_codempid','   '||get_label_name('HRPY70B4',global_v_lang,60)||' '||
                                       v_codbank||' : '||get_tcodec_name('TCODBANK',v_codbank,global_v_lang));
          obj_row_temp.put(to_char(v_count),obj_data);
          v_count := v_count + 1;
					v_fstbank := 'N';
        end if;
        for i in 1..2 loop
          v_flg := 'N';
          if (i = 1) and (r_ttaxcur.codbank = v_codbank) then
            v_amtpay   := nvl(to_number(stddec(r_ttaxcur.amtnet1,r_ttaxcur.codempid,global_v_chken)),0);
            v_codbank2 := r_ttaxcur.codbank;
            v_numbank  := substr(nvl(r_ttaxcur.numbank,' '),1,11);
            v_flg := 'Y';
          end if;
          if (i = 2) and (r_ttaxcur.codbank2 = v_codbank) then
            v_amtpay := nvl(to_number(stddec(r_ttaxcur.amtnet2,r_ttaxcur.codempid,global_v_chken)),0);
            v_codbank2 := r_ttaxcur.codbank2;
            v_numbank := substr(nvl(r_ttaxcur.numbank2,' '),1,11);
            v_flg := 'Y';
          end if;
          if v_flg = 'Y' then
            v_numseq :=  v_numseq + 1;
            v_sumrec :=  v_sumrec + 1;
            v_sumamt :=  v_sumamt + v_amtpay;
            begin
             select dtepaymt, dtemthpay, dteyrepay
               into v_dtepaymt, v_dtemthpay, v_dteyrepay
               from  tdtepay
              where codcompy  =  hcm_util.get_codcomp_level(r_ttaxcur.codcomp,1)
                and dteyrepay  = r_ttaxcur.dteyrepay
                and dtemthpay  = r_ttaxcur.dtemthpay
                and numperiod  = r_ttaxcur.numperiod
                and typpayroll = r_ttaxcur.typpayroll;

              v_paid_date := v_dtepaymt;
            exception when no_data_found then
                v_paid_date := p_dtepay;
            end;

            begin
              select numacct,codbkserv
                into v_numacct,v_codbkserv
                from tbnkmdi1
               where codcompy = hcm_util.get_codcomp_level(r_ttaxcur.codcomp,1)
                 and typbank  = p_typbank;
            exception when no_data_found then
              v_numacct   := ' ';
              v_codbkserv := ' ';
            end;
            -- create head
            if v_first = 'Y' then
              v_first := 'N';
              bank_exp.head(p_typbank,v_codbkserv,v_numacct,
                                     hcm_util.get_codcomp_level(r_ttaxcur.codcomp,1),v_totamt,
                                      v_totemp,v_paid_date,p_dtepay,
                                      0,global_v_lang,data_file,v_rec); 
              if p_typbank = '55' then
--                utl_file.Put_line(out_file,substr(data_file,1,96));
--                data_file := substr(data_file,97);
                  data_file := substr(data_file,1,96);
              end if;
--              v_sumrec := v_sumrec + nvl(v_rec,0);

              if data_file is not null then
                 utl_file.Put_line(out_file,data_file);
              end if;
              v_sumrec := v_sumrec + nvl(v_rec,0);
            end if;
            -- create detail
            bank_exp.body(p_typbank,v_codbkserv,v_numacct,v_sumrec,
                          v_codempid,v_codbank2,v_numbank,v_amtpay,v_paid_date,
                          hcm_util.get_codcomp_level(r_ttaxcur.codcomp,1),v_totemp,
                          v_totamt,p_dtepay,r_tbnkmdi1.codmedia,
                          0,global_v_lang,data_file);
            v_count_proc := v_count_proc + 1; -- for background process
            obj_data := json_object_t();
--            obj_data.put('numseq'     ,to_char(v_count + 1));
            obj_data.put('numseq'     ,to_char(v_numseq));
--            obj_data.put('acc_number'     ,r_ttaxcur.numbank);
            obj_data.put('acc_number'     ,v_numbank);
            obj_data.put('codempid'     ,r_ttaxcur.codempid);
            obj_data.put('desc_codempid', get_temploy_name (r_ttaxcur.codempid,global_v_lang));
            obj_data.put('amount'       , to_char(v_amtpay,'fm999,999,999,999,990.00'));
--            obj_data.put('desc_bank', get_tlistval_name('TBANKFMT',p_typbank,global_v_lang));
            obj_data.put('desc_bank', get_tcodec_name('TCODBANK',v_codbank2,global_v_lang));
            obj_row_temp.put(to_char(v_count),obj_data);
            v_count := v_count + 1;

            if p_typbank = '55' then
              utl_file.Put_line(out_file,substr(data_file,1,355));
              data_file := substr(data_file,356);
            end if;
            if data_file is not null then
               utl_file.Put_line(out_file,data_file);
            end if;
          end if;
        end loop;
       end if; -- end secure
      end loop;
      if v_sumamt <> 0 then
        obj_data := json_object_t();
        obj_data.put('numseq','');
        obj_data.put('acc_number','');
        obj_data.put('codempid','');
        obj_data.put('desc_bank','');
        obj_data.put('desc_codempid','   '||get_label_name('HRPY70B3',global_v_lang,70));
        obj_data.put('amount',to_char(v_sumamt,'fm999,999,999,999,990.00'));
        obj_row_temp.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      end if;
      v_sumamt2  := v_sumamt2 + v_sumamt;
    end loop;

    if v_sumrec > 0 then
      v_sumrec  := v_sumrec + 1;
       -- create tail
      bank_exp.tail(p_typbank,v_codbkserv,v_numacct,v_totemp,
                     v_totamt,v_paid_date,0,data_file);

--       data_file := convert(data_file,'TH8TISASCII');
       if data_file is not null then
        utl_file.Put_line(out_file,data_file);
       end if;
    end if;
    if v_sumamt2 <> 0 then
      obj_data := json_object_t();
      obj_data.put('numseq','');
      obj_data.put('acc_number','');
      obj_data.put('codempid','');
      obj_data.put('desc_bank','');
      obj_data.put('desc_codempid','   '||get_label_name('HRPY70B3',global_v_lang,80));
      obj_data.put('amount',to_char(v_sumamt2,'fm999,999,999,999,990.00'));
      obj_row_temp.put(to_char(v_count),obj_data);
      v_count := v_count + 1;
    end if;
    utl_file.Fclose(out_file);
    sync_log_file(v_filename);

    if v_flgsomeover = 'Y' then
          begin
            insert into ttemprpt
              (codempid, codapp, numseq,
              item1, item2, item3,
              item4, item5, item6,
              item7)
            values
              (global_v_coduser,'HRPY5JXOVR',-1,
              p_numperiod,p_month,p_year,
              p_codcomp,p_typpayroll,p_typbank,
              to_char(p_dtepay,'ddmmyyyy'));
          exception when dup_val_on_index then
            update ttemprpt
               set item1 = p_numperiod,
                   item2 = p_month,
                   item3 = p_year,
                   item4 = p_codcomp,
                   item5 = p_typpayroll,
                   item6 = p_typbank,
                   item7 = to_char(p_dtepay,'ddmmyyyy')
             where codempid = global_v_coduser
               and codapp   = 'HRPY5JXOVR'
               and numseq   = -1;
          end;

          -- set complete batch process
          global_v_batch_flgproc := 'Y';
          global_v_batch_qtyproc := v_count_proc;
          global_v_batch_filename := v_filename;
          global_v_batch_pathfile := p_file_path || v_filename; 

         if  v_sumrec = 0 and v_secure = 0 then
              obj_rows.put('coderror','400');
              obj_rows.put('flgprocess','Y');
              param_msg_error := get_error_msg_php('HR3007',global_v_lang);
              global_v_batch_error := param_msg_error;
              obj_rows.put('response',hcm_secur.get_response('400',param_msg_error,global_v_lang));
              param_msg_error := '';

              -- set complete batch process
              global_v_batch_flgproc := 'N';
              global_v_batch_qtyproc := v_count_proc;
              global_v_batch_filename := null;
              global_v_batch_pathfile := null; 
          else

              obj_rows.put('coderror','200');
              obj_rows.put('flgprocess','N');
              param_msg_error := get_error_msg_php('PM0066',global_v_lang);
              global_v_batch_error := param_msg_error;
              obj_rows.put('response',hcm_secur.get_response('200',param_msg_error,global_v_lang));
              param_msg_error := '';

              -- set complete batch process
              gen_detail1(json_str_detail);
              global_v_batch_flgproc := 'N';
              global_v_batch_qtyproc := v_count_proc;
              global_v_batch_filename := null;
              global_v_batch_pathfile := null; 
          end if;
          json_str_output := obj_rows.to_clob;

          return;

--    elsif  v_secure = 0 then --user37 #2013 Final Test Phase 1 V11 07/02/2021 and v_sumrec <>0 then 
--      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
--      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--      return;
--    elsif v_sumrec = 0 then
--      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxcur');
--      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--      return;
-- else
--      obj_rows.put('coderror','200');
--      obj_rows.put('flgprocess','Y');
--      obj_rows.put('response',hcm_secur.get_response('200',get_error_msg_php('HR2715',global_v_lang),global_v_lang));
--      obj_rows.put('path',p_file_path || v_filename);
--      obj_rows.put('detail',obj_row_temp);
--
--      -- set complete batch process
--      global_v_batch_flgproc := 'Y';
--      global_v_batch_qtyproc := v_count_proc;
--      global_v_batch_filename := v_filename;
--      global_v_batch_pathfile := p_file_path || v_filename;
--
--      json_str_output := obj_rows.to_clob;
    else 
        if v_flg_data = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxcur');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        else
            if  v_secure = 0  then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            else
                obj_rows.put('coderror','200');
                obj_rows.put('flgprocess','Y');
                obj_rows.put('response',hcm_secur.get_response('200',get_error_msg_php('HR2715',global_v_lang),global_v_lang));
                obj_rows.put('path',p_file_path || v_filename);
                obj_rows.put('detail',obj_row_temp);

              -- set complete batch process
                global_v_batch_flgproc := 'Y';
                global_v_batch_qtyproc := v_count_proc;
                global_v_batch_filename := v_filename;
                global_v_batch_pathfile := p_file_path || v_filename;        
              json_str_output := obj_rows.to_clob;
            end if;            
        end if;
    end if;
    commit;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;

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

  procedure check_detail1 as
  begin
    null;
--    if p_numperiod is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
--      return;
--    end if;
--    if p_month is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
--      return;
--    end if;
--    if p_year is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
--      return;
--    end if;
--    if p_codcomp is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
--      return;
--    end if;
--    if p_typbank is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typbank');
--      return;
--    end if;
--    if p_dtepay is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtepay');
--      return;
--    end if;
--    if p_codcomp is not null then
--      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
--      if param_msg_error is not null then
--        return;
--      end if;
--    end if;
--    begin
--    if p_typpayroll is not null then
--      begin
--        select codcodec
--          into p_typpayroll
--          from tcodtypy
--         where codcodec = p_typpayroll;
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
--        return;
--      end;
--    end if;
--    end;
--    begin
--      select dtepaymt
--        into p_dtepay
--        from tdtepay
--       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
--         and typpayroll = p_typpayroll
--         and dteyrepay  = p_year
--         and dtemthpay  = p_month
--         and numperiod  = p_numperiod
--         and dtepaymt   = p_dtepay;
--    exception when no_data_found then
--      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tdtepay');
--      return;
--    end;
  end check_detail1;

  procedure get_detail1(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail1;
    if param_msg_error is null then
        gen_detail1(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail1;

  procedure gen_detail1 (json_str_output out clob) as
  	obj_data         json_object_t;
  	obj_rows         json_object_t := json_object_t();
    obj_json         json_object_t := json_object_t();

    v_numperiod      varchar2(4000 char);
    v_month          varchar2(4000 char);
    v_year           varchar2(4000 char);
    v_codcomp2        varchar2(4000 char);
    v_typpayroll     varchar2(4000 char);
    v_typbank        varchar2(4000 char);
    v_dtepay         date;

  	v_count          number := 0;
    v_secur          boolean;
    v_zupdsal        varchar2(1 char);
    v_codcomp        tcenter.codcomp%type;
    cursor c1 is
      select codempid, codapp, numseq,
             item1   , item2 , temp33,
             item3   , item4 ,
             temp31  , temp32,
             item5,item6
        from ttemprpt
       where codapp = 'HRPY5JXOVR'
         and numseq <> -1
         and codempid = global_v_coduser
    order by numseq;
  begin
    for r1 in c1 loop
      begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = r1.item1;
      exception when no_data_found then
        v_codcomp := '';
      end;
      v_secur := secur_main.secur3(v_codcomp,r1.item1,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur and v_zupdsal = 'Y' then
        obj_data := json_object_t();
        obj_data.put('image'        , get_emp_img(r1.item1));
        obj_data.put('codempid'     , r1.item1);
        obj_data.put('desc_codempid', get_temploy_name (r1.item1,global_v_lang));
        obj_data.put('codpay'       , r1.item5);
        obj_data.put('desc_codpay'  , get_tinexinf_name(r1.item5,global_v_lang));
        obj_data.put('typpayroll'   , r1.item6);
--        obj_data.put('desc_typpayroll',get_tcodec_name('tcodtypy',r1.item4,'102'));
        obj_data.put('desc_typpayroll',r1.item4);
        obj_data.put('amtnet'       , to_char(r1.temp31,'fm999999999999990.00'));
        obj_data.put('amtmax'       , to_char(r1.temp32,'fm999999999999990.00'));
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;

        -- insert batch process detail
        hcm_batchtask.insert_batch_detail(
          p_codapp   => global_v_batch_codapp,
          p_coduser  => global_v_coduser,
          p_codalw   => global_v_batch_codalw,
          p_dtestrt  => global_v_batch_dtestrt,
          p_item01  => get_emp_img(r1.item1),
          p_item02  => r1.item1,
          p_item03  => get_temploy_name (r1.item1,global_v_lang),
          p_item04  => r1.item5,
          p_item05  => get_tinexinf_name(r1.item5,global_v_lang),
          p_item06  => r1.item6,
          p_item07  => r1.item4,
          p_item08  => to_char(r1.temp31,'fm999999999999990.00'),
          p_item09  => to_char(r1.temp32,'fm999999999999990.00')
        );
      end if;
    end loop;
    global_v_batch_qtyerror := v_count;
    obj_json.put('rows',obj_rows);
    begin
      select item1   , item2 , item3 ,
             item4   , item5 , item6 ,
             to_date(item7,'ddmmyyyy')
        into v_numperiod,v_month     ,v_year    ,
             v_codcomp2 ,v_typpayroll,v_typbank ,
             v_dtepay
        from ttemprpt
       where codapp = 'HRPY5JXOVR'
         and numseq = -1
         and codempid = global_v_coduser;
      obj_data := json_object_t();
      obj_data.put('numperiod' ,v_numperiod);
      obj_data.put('month'     ,v_month);
      obj_data.put('year'      ,v_year);
      obj_data.put('codcomp'   ,v_codcomp2);
      obj_data.put('typpayroll',v_typpayroll);
      obj_data.put('typbank'   ,v_typbank);
      obj_data.put('dtepay'    ,to_char(v_dtepay,'dd/mm/yyyy'));
      obj_json.put('detail',obj_data);
    exception when no_data_found then
     null;
    end;
    obj_json.put('coderror','200');
    json_str_output := obj_json.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail1;

  procedure check_detail2 as
    v_codcomp tcenter.codcomp%type;
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
      return;
    end if;
    if p_typbank is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typbank');
      return;
    end if;
--    if p_dtepay is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtepay');
--      return;
--    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_codempid is not null then
      begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
      end;
      if not secur_main.secur3(v_codcomp,p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
        return;
      end;
    end if;
--    begin
--      select dtepaymt
--        into p_dtepay
--        from tdtepay
--       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
--         and typpayroll = p_typpayroll
--         and dteyrepay  = p_year
--         and dtemthpay  = p_month
--         and numperiod  = p_numperiod
--         and dtepaymt   = p_dtepay;
--    exception when no_data_found then
--      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tdtepay');
--      return;
--    end;
  end check_detail2;

  procedure get_detail2(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail2;
    if param_msg_error is null then
        gen_detail2(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail2;

  procedure  gen_detail2 (json_str_output out clob) as
    obj_data        json_object_t;
    obj_rows        json_object_t := json_object_t;
    v_count         number := 0;
    v_codbank       tbnkmdi2.codbank%type;
    v_sum_bank      number := 0;
    v_sum_all       number := 0;

    cursor c_tbnkmdi2 is
      select codbank,codmedia,bankfee
        from tbnkmdi2 b
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and typbank  = p_typbank
    order by codbank;

    cursor c_ttaxcur is
      select a.codempid ,a.codcomp  ,
             a.codbank  ,a.numbank  ,stddec(a.amtnet1,a.codempid,global_v_chken) amtnet1  ,
             a.codbank2 ,a.numbank2 ,stddec(a.amtnet2,a.codempid,global_v_chken) amtnet2  ,
             a.dteyrepay,a.dtemthpay,a.numperiod,a.typpayroll
        from ttaxcur a
       where a.codcomp   like p_codcomp || '%'
         and a.dteyrepay = p_year
         and a.dtemthpay = p_month
         and a.numperiod = p_numperiod
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.codempid  = p_codempid
         and to_number(stddec(a.amtnet,a.codempid,global_v_chken)) > 0
         and a.typpaymt  = 'BK'
         and ((a.codbank = v_codbank) or (a.codbank2 = v_codbank))
    order by a.codcomp,a.codempid;
  begin
    for r1 in c_tbnkmdi2 loop
      v_codbank := r1.codbank;

      for r2 in c_ttaxcur loop
        if r2.codbank = v_codbank then
          obj_data := json_object_t();
          obj_data.put('index'    ,to_char(v_count+1));
          obj_data.put('desc_bank',get_tlistval_name('TBANKFMT',p_typbank,global_v_lang));
          obj_data.put('bank'     ,p_typbank);
          obj_data.put('numbank'  ,hcm_util.convert_numbank(r2.numbank));
          obj_data.put('amtnet'   ,to_char(r2.amtnet1,'fm999999999999990.00'));
          obj_data.put('flgskip', 'N');
          obj_data.put('coderror' ,'200');
          obj_rows.put(to_char(v_count),obj_data);
          v_sum_bank := v_sum_bank + r2.amtnet1;
          v_sum_all  := v_sum_all  + r2.amtnet1;
          v_count := v_count + 1;
        end if;
        if r2.codbank2 = v_codbank then
          obj_data := json_object_t();
          obj_data.put('index'    ,to_char(v_count+1));
          obj_data.put('desc_bank',get_tlistval_name('TBANKFMT',p_typbank,global_v_lang));
          obj_data.put('bank'     ,p_typbank);
          obj_data.put('numbank'  ,hcm_util.convert_numbank(r2.numbank2));
          obj_data.put('amtnet'   ,to_char(r2.amtnet2,'fm999999999999990.00'));
          obj_data.put('flgskip', 'N');
          obj_data.put('coderror' ,'200');
          obj_rows.put(to_char(v_count),obj_data);
          v_sum_bank := v_sum_bank + r2.amtnet2;
          v_sum_all  := v_sum_all  + r2.amtnet2;
          v_count := v_count + 1;
        end if;
      end loop;
    end loop;
    obj_data := json_object_t();
    obj_data.put('numbank'  ,get_label_name('HRPY70B3',global_v_lang,'70'));
    obj_data.put('amtnet',to_char(v_sum_bank,'fm999999999999990.00'));
    obj_data.put('flgskip', 'Y');
    obj_data.put('coderror','200');
    obj_rows.put(to_char(v_count),obj_data);
    obj_data := json_object_t();
    obj_data.put('numbank'  ,get_label_name('HRPY70B3',global_v_lang,'80'));
    obj_data.put('amtnet',to_char(v_sum_all ,'fm999999999999990.00'));
    obj_data.put('flgskip', 'Y');
    obj_data.put('coderror','200');
    obj_rows.put(to_char(v_count+1),obj_data);
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail2;

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
end hrpy70b;

/

--------------------------------------------------------
--  DDL for Package Body HRPY90B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY90B" as
-- last update: 30/09/2020 18:00

  procedure initial_value (json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_numperiod     := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
    p_dtemthpay     := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay     := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_codcompy      := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_typpayroll    := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codpfinf      := hcm_util.get_string_t(json_obj,'p_codpfinf');
    p_codplan       := hcm_util.get_string_t(json_obj,'p_codplan');
    p_numcomp       := hcm_util.get_string_t(json_obj,'p_numcomp');
    p_numfund       := hcm_util.get_string_t(json_obj,'p_numfund');
    p_dtepay        := to_date(hcm_util.get_string_t(json_obj,'p_dtepay'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_process as
    v_typpayroll  varchar2(4000 char);
    v_codpfinf    varchar2(4000 char);
    v_codplan     varchar2(4000 char);
  begin
    if p_codcompy is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    --
    if p_typpayroll is not null then
      begin
        select codcodec
          into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODTYPY');
        return;
      end;
    end if;
    --
    if p_codpfinf is not null then
      begin
        select codcodec
          into v_codpfinf
          from tcodpfinf
         where codcodec = p_codpfinf;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPFINF');
        return;
      end;
    end if;
    --
--    if p_codplan is not null then
--      begin
--        select codcodec
--          into v_codplan
--          from tcodpfpln
--         where codcodec = p_codplan;
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPFPLN');
--        return;
--      end;
--    end if;
      --
      begin
        select codpaypy3,codpaypy7
          into p_codpaypy3,p_codpaypy7
          from tcontrpy
         where codcompy = p_codcompy
           and dteeffec = (select max(dteeffec)
                             from tcontrpy
                            where	codcompy = p_codcompy
                              and	dteeffec <= trunc(sysdate));
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCONTRPY');
        return;
      end;

    --
    if p_codpfinf is not null and p_codcompy is not null then
      begin
        select pvdffmt into p_pvdffmt
          from tpfphinf
         where codcompy = p_codcompy
           and codpfinf = p_codpfinf
           and dteeffec = (select max(dteeffec) from tpfphinf
                 where codcompy = p_codcompy
                   and codpfinf = p_codpfinf);
      exception when no_data_found then
        p_pvdffmt := null;
      end;
    end if;
  end check_process;

  procedure get_pctpf as
  begin
    begin
      select pctemppf,pctcompf
       into global_v_pctemppf,global_v_pctcompf
       from ttaxcur
       where codempid  = global_t_codempid
         and numperiod = p_numperiod
         and dtemthpay = p_dtemthpay
         and dteyrepay = p_dteyrepay;
    exception when no_data_found then
      global_v_pctemppf := null;
      global_v_pctcompf := null;
    end;
  end;
  procedure get_process(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is null then
      gen_process(json_str_output);
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
      p_filename1 => global_v_batch_filename1,
      p_pathfile1 => global_v_batch_pathfile1,
      p_filename2 => global_v_batch_filename2,
      p_pathfile2 => global_v_batch_pathfile2,
      p_filename3 => global_v_batch_filename3,
      p_pathfile3 => global_v_batch_pathfile3,
      p_filename4 => global_v_batch_filename4,
      p_pathfile4 => global_v_batch_pathfile4,
      p_oracode   => param_msg_error
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
  --
  procedure exp_text_bay2(p_error_msg out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    out_file   		 utl_file.file_type;
    data_file 		 varchar2(500);
    data_file1		 varchar2(500);--Modify 22/05/2551
    data_file2		 varchar2(500);--Modify 22/05/2551
    v_filename		 varchar2(255);
    v_codempid		 varchar2(50) := null;
    v_codcomp			 varchar2(50) := null;
    v_codpfinf		 tcodpfinf.codcodec%type;
    v_secur				 boolean;
    v_amtprove		 number := 0;
    v_amtprovc		 number := 0;
    v_totamtprovc	 number := 0;
    v_totamtprove	 number := 0;
    v_totrec			 number := 0;
    v_first				 varchar2(1)	:= 'Y';
    v_namcomt			 varchar2(100);

    v_sumrec       number := 0;
    v_chksecure    varchar2(1) := 'N';
    v_datatpfmemb  varchar2(1) := 'N';
    v_dtebeg       date;
    v_dteend       date;
    --สำหรับสมาชิกเก่า
    cursor c_tpfmemb is
      select a.codempid,a.codcomp,a.dteeffec,a.dtereti,a.nummember,a.typpayroll,
             b.numlvl,b.namempt,b.dteempmt,b.codtitle,b.namfirstt,b.namlastt,
             a.codpfinf--,c.pvdffmt
        from tpfmemb a,temploy1 b--,tpfhrinf c
       where a.codcomp like p_codcompy||'%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.codpfinf = p_codpfinf
         and ((a.dteeffec < v_dtebeg) or (a.dteeffec > v_dteend))
         and a.codempid = b.codempid
--         and a.codpfinf = c.codpfinf
         and exists (select codplan
                      from tpfirinf g
                     where g.codempid =  a.codempid
                       and g.codplan  = nvl(p_codplan,g.codplan)
                       and g.dteeffec = (select max(h.dteeffec)
                                           from tpfirinf h
                                          where h.codempid = g.codempid
                                            and h.codplan  = nvl(p_codplan,h.codplan)
                                            and h.dteeffec <= trunc(sysdate)))
--                       and rownum <= 1)
      order by a.codcomp,a.codempid;

    cursor c_tsincexp is
      select codempid,
             sum(decode(codpay,p_codpaypy3,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprove,
             sum(decode(codpay,p_codpaypy7,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprovc
      from tsincexp
      where	codempid = v_codempid
      and		dteyrepay	= p_dteyrepay - global_v_zyear
      and		dtemthpay	= p_dtemthpay
      and		numperiod like p_numperiod||'%'
      and 	codpay in (p_codpaypy3,p_codpaypy7)
      and		flgslip = '1'
    group by codempid;

  begin
    begin
      select dtestrt,dteend
        into v_dtebeg, v_dteend
        from tdtepay
       where codcompy   = p_codcompy
         and typpayroll = nvl(p_typpayroll,typpayroll) --Modify 03/02/2553
         and dteyrepay  = (p_dteyrepay - global_v_zyear)
         and dtemthpay  = p_dtemthpay
         and numperiod  = p_numperiod
         and rownum <= 1;
    exception when no_data_found then
      goto error_not_exist;
    end;

    begin
      select namcomt
        into v_namcomt
        from tcompny
       where codcompy = p_codcompy;
    exception when no_data_found then	v_namcomt	:= ' ';
    end;

    for r_tpfmemb in c_tpfmemb loop
      v_secur	:= secur_main.secur1(r_tpfmemb.codcomp,r_tpfmemb.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_secur then
        v_codempid	:= r_tpfmemb.codempid;

        for r_tsincexp in c_tsincexp loop
          if (r_tsincexp.v_amtprove <> 0) or (r_tsincexp.v_amtprovc <> 0) then
            v_totamtprove := v_totamtprove + r_tsincexp.v_amtprove;
            v_totamtprovc := v_totamtprovc + r_tsincexp.v_amtprovc;
            v_totrec := v_totrec + 1;
          end if;
        end loop;
      end if;
    end loop;

    if p_sta_group = 'N' then
      v_filename := hcm_batchtask.gen_filename('C'||lpad(p_dtemthpay,2,'0')||to_char(p_dteyrepay),'txt',global_v_batch_dtestrt);
      std_deltemp.upd_ttempfile(v_filename,'A');	--'A' = Insert , update ,'D'  = delete
    end if;

    obj_row     := json_object_t();
    for r_tpfmemb in c_tpfmemb loop
      v_sumrec	    := v_sumrec + 1;
      v_secur	      := secur_main.secur1(r_tpfmemb.codcomp,r_tpfmemb.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      v_datatpfmemb := 'Y';
      if v_secur then
        v_chksecure	:= 'Y';
        v_codempid  := r_tpfmemb.codempid;

        for r_tsincexp in c_tsincexp loop
          if (r_tsincexp.v_amtprove <> 0) or (r_tsincexp.v_amtprovc <> 0) then
            p_chk_filebay2 := 'Y';
            r_tpfmemb.namempt   := nvl(r_tpfmemb.namempt,' ');
            r_tpfmemb.nummember := nvl(r_tpfmemb.nummember,' ');

            if p_sta_group = 'N' then
              -- create head
              if v_first	= 'Y' then
                v_first     := 'N';
                out_file    := utl_file.fopen(p_file_dir,v_filename, 'w');

                --waite 08/01/08 :report.codempid_desc	:= '  '||v_filename;
                pvdf_exp.head(p_pvdffmt,r_tpfmemb.typpayroll,p_numcomp,
                              p_numfund,p_dtepay,p_dtemthpay,
                              p_dteyrepay,v_totamtprove,v_totamtprovc,v_totrec,
                              v_namcomt,global_v_zyear,global_v_lang,data_file);

--                data_file := convert(data_file,'TH8TISASCII');
                if data_file is not null then
                  utl_file.put_line(out_file,data_file);
                end if;
                v_totrec :=	0;
              end if;

              -- create body
              pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                            r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                            p_numperiod,p_dtemthpay,p_dteyrepay,
                            r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                            r_tpfmemb.nummember,
                            get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                            r_tpfmemb.namfirstt,
                            r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                            r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                            2,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                            data_file,data_file1,data_file2);

--              data_file := convert(data_file,'TH8TISASCII');
              if data_file is not null then
                utl_file.put_line(out_file,data_file);
              end if;
            end if;

            -- insert data to block 'data'
            v_totrec	:= v_totrec + 1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('nummember', r_tpfmemb.nummember);
            obj_data.put('image', get_emp_img(v_codempid));
            obj_data.put('codempid', v_codempid);
            obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
            obj_data.put('codcomp', r_tpfmemb.codcomp);
            obj_data.put('amtprove', r_tsincexp.v_amtprove);
            obj_data.put('amtprovc', r_tsincexp.v_amtprovc);
            obj_data.put('amtsum', r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc);
            global_t_codempid := v_codempid;
            get_pctpf;
            obj_data.put('pctemppf', global_v_pctemppf);
            obj_data.put('pctcompf', global_v_pctcompf);
            --
            obj_row.put(to_char(v_totrec - 1), obj_data);

--            global_v_batch_qtyproc  := v_totrec;
            -- insert batch process detail
--            hcm_batchtask.insert_batch_detail(
--              p_codapp   => global_v_batch_codapp,
--              p_coduser  => global_v_coduser,
--              p_codalw   => global_v_batch_codalw,
--              p_dtestrt  => global_v_batch_dtestrt,
--              p_item01  => r_tpfmemb.nummember,
--              p_item02  => get_emp_img(v_codempid),
--              p_item03  => v_codempid,
--              p_item04  => get_temploy_name(v_codempid, global_v_lang),
--              p_item05  => r_tpfmemb.codcomp,
--              p_item06  => r_tsincexp.v_amtprove,
--              p_item07  => r_tsincexp.v_amtprovc,
--              p_item08  => r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc
--            );
          end if; --v_amtprove <> 0 or v_amtprovc <> 0
        end loop; --c_tsincexp
      end if; --pass security
    end loop; --c_tpfmemb

    if v_datatpfmemb = 'N' then
      p_error_msg      := get_error_msg_php('HR2055', global_v_lang, 'TPFMEMB');
--      json_str_output  := get_response_message(null, param_msg_error, global_v_lang);
--      rollback;
      return;
    elsif v_chksecure = 'N' then
      p_error_msg      := get_error_msg_php('HR3007',global_v_lang);
--      json_str_output  := get_response_message(null, param_msg_error, global_v_lang);
--      rollback;
      return;
    elsif v_totrec < 1 then
      p_error_msg      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
--      json_str_output  := get_response_message(null, param_msg_error, global_v_lang);
--      rollback;
      return;
    else
--      json_str_output := obj_row.to_clob;
--      --
      utl_file.fclose(out_file);
      p_filename2 := v_filename;
--      sync_log_file(v_filename);
--      commit;
    end if;
    <<error_not_exist>>
    if v_totrec < 1 then
      p_error_msg      := get_error_msg_php('HR2010', global_v_lang, 'TDTEPAY');
--      json_str_output  := get_response_message(null, param_msg_error, global_v_lang);
--      rollback;
      return;
    end if;
  --msg_error(v_totamtprove||' - '||v_totamtprovc||' - '||v_totrec,3008,null );

--    if (v_totamtprove <> 0) or (v_totamtprovc <> 0) then
--      :report.codempid_desc := :ctrl_label2.di_v70||' : ';  --'Total : ';
--      :report.amtprove := v_totamtprove;
--      :report.amtprovc := v_totamtprovc;
--      :report.amtsum   := v_totamtprove + v_totamtprovc;
--      next_record;
--    end if;
  end;
  --
  procedure exp_text_bay1(json_str_output out clob) is
    obj_row        json_object_t;
    obj_data       json_object_t;
    out_file   		 utl_file.file_type;
    data_file 		 varchar2(500);
    data_file1		 varchar2(500);--Modify 22/05/2551
    data_file2		 varchar2(500);--Modify 22/05/2551
    v_filename		 varchar2(255);
    v_codempid		 varchar2(50) := null;
    v_codcomp			 varchar2(50) :=	null;
    v_codpfinf		 tcodpfinf.codcodec%type;
    v_secur				 boolean;
    v_amtprove		 number := 0;
    v_amtprovc		 number := 0;
    v_totamtprovc	 number := 0;
    v_totamtprove	 number := 0;
    v_totrec			 number := 0;
    v_first				 varchar2(1)	:= 'Y';
    v_namcomt			 varchar2(100);

    v_sumrec        number := 0;
    v_chksecure     varchar2(1) := 'N';
    v_datatpfmemb   varchar2(1) := 'N';
    v_error_msg     varchar2(1000);
    --สำหรับสมาชิกใหม่
    cursor c_tpfmemb is
      select a.codempid,a.codcomp,a.dteeffec,a.dtereti,a.nummember,a.typpayroll,
             b.numlvl,b.codtitle,b.namfirstt,b.namlastt,b.namempt,b.dteempmt,
             b.namempe,ltrim(rtrim(b.codposre)) codposre,a.codpfinf
        from tpfmemb a,temploy1 b
       where a.codcomp like p_codcompy||'%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.codpfinf = p_codpfinf
         and a.codempid = b.codempid
         and exists (select codplan
                      from tpfirinf g
                     where g.codempid =  a.codempid
                       and g.codplan  = nvl(p_codplan,g.codplan)
                       and g.dteeffec = (select max(h.dteeffec)
                                           from tpfirinf h
                                          where h.codempid = g.codempid
                                            and h.codplan  = nvl(p_codplan,h.codplan)
                                            and h.dteeffec <= trunc(sysdate)))
--                       and rownum <= 1)
      order by a.codcomp,a.codempid;


    cursor c_tsincexp is
      select codempid,
             sum(decode(codpay,p_codpaypy3,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprove,
             sum(decode(codpay,p_codpaypy7,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprovc
       from tsincexp
      where	codempid = v_codempid
        and	dteyrepay	= p_dteyrepay - global_v_zyear
        and	dtemthpay	= p_dtemthpay
        and	numperiod like p_numperiod||'%'
        and codpay in (p_codpaypy3,p_codpaypy7)
        and flgslip = '1'
      group by codempid;

  begin
    if utl_file.is_open(out_file) then
		  utl_file.fclose(out_file);
	  end if;
    --
    begin
      select namcomt
        into v_namcomt
        from tcompny
       where codcompy = p_codcompy;
    exception when no_data_found then v_namcomt	:= ' ';
    end;

    for r_tpfmemb in c_tpfmemb loop
      v_secur	:= secur_main.secur1(r_tpfmemb.codcomp,r_tpfmemb.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      v_datatpfmemb := 'Y';
      if v_secur then
        v_chksecure := 'Y';
        v_codempid	:= r_tpfmemb.codempid;
        for r_tsincexp in c_tsincexp loop
          if (r_tsincexp.v_amtprove <> 0) or (r_tsincexp.v_amtprovc <> 0) then
            v_totamtprove := v_totamtprove + r_tsincexp.v_amtprove;
            v_totamtprovc := v_totamtprovc + r_tsincexp.v_amtprovc;
            v_totrec := v_totrec + 1;
          end if;
        end loop;
      end if;
    end loop;

    if p_sta_group = 'N' then
--      alert_error.error_data('HR2715',global_v_lang);
      v_filename := hcm_batchtask.gen_filename('M'||lpad(p_dtemthpay,2,'0')||to_char(p_dteyrepay),'txt',global_v_batch_dtestrt);
      std_deltemp.upd_ttempfile(v_filename,'A');	--'A' = Insert , update ,'D'  = delete
    end if;

    obj_row   := json_object_t();
    for r_tpfmemb in c_tpfmemb loop
      v_secur	:= secur_main.secur1(r_tpfmemb.codcomp,r_tpfmemb.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      v_datatpfmemb := 'Y'; --User37 STA11 11/02/2020
      if v_secur then
        v_chksecure := 'Y';
        v_codempid := r_tpfmemb.codempid;

        for r_tsincexp in c_tsincexp loop

          if (r_tsincexp.v_amtprove <> 0) or (r_tsincexp.v_amtprovc <> 0) then
            p_chk_filebay1 := 'Y';
            v_sumrec            := nvl(v_sumrec,0) + 1;
            r_tpfmemb.namempt   := nvl(r_tpfmemb.namempt,' ');
            r_tpfmemb.nummember := nvl(r_tpfmemb.nummember,' ');

            if p_sta_group = 'N' then
              -- create head
              if v_first	= 'Y' then
                v_first := 'N';
                out_file := utl_file.fopen(p_file_dir,v_filename, 'w');

                pvdf_exp.head(p_pvdffmt,r_tpfmemb.typpayroll,p_numcomp,
                              p_numfund,p_dtepay,p_dtemthpay,
                              p_dteyrepay,v_totamtprove,v_totamtprovc,v_totrec,
                              v_namcomt,global_v_zyear,global_v_lang,data_file);

--                data_file := convert(data_file,'TH8TISASCII');
                if data_file is not null then
                  utl_file.put_line(out_file,data_file);
                end if;

                v_totrec :=	0;
              end if;

              -- create body
              pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                            r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                            p_numperiod,p_dtemthpay,p_dteyrepay,
                            r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                            r_tpfmemb.nummember,
                            get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                            r_tpfmemb.namfirstt,
                            r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                            r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                            1,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                            data_file,data_file1,data_file2);

--              data_file := convert(data_file,'TH8TISASCII');
              if data_file is not null then
                utl_file.put_line(out_file,data_file);
              end if;
            end if;

            -- insert data to block 'data'

            v_totrec	        := v_totrec + 1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('nummember', r_tpfmemb.nummember);
            obj_data.put('image', get_emp_img(v_codempid));
            obj_data.put('codempid', v_codempid);
            obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
            obj_data.put('codcomp', r_tpfmemb.codcomp);
            obj_data.put('amtprove', r_tsincexp.v_amtprove);
            obj_data.put('amtprovc', r_tsincexp.v_amtprovc);
            obj_data.put('amtsum', r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc);
            global_t_codempid := v_codempid;
            get_pctpf;
            obj_data.put('pctemppf', global_v_pctemppf);
            obj_data.put('pctcompf', global_v_pctcompf);
            --
            obj_row.put(to_char(v_totrec - 1), obj_data);

--            global_v_batch_qtyproc  := v_totrec;
            -- insert batch process detail
--            hcm_batchtask.insert_batch_detail(
--              p_codapp   => global_v_batch_codapp,
--              p_coduser  => global_v_coduser,
--              p_codalw   => global_v_batch_codalw,
--              p_dtestrt  => global_v_batch_dtestrt,
--              p_item01  => r_tpfmemb.nummember,
--              p_item02  => get_emp_img(v_codempid),
--              p_item03  => v_codempid,
--              p_item04  => get_temploy_name(v_codempid, global_v_lang),
--              p_item05  => r_tpfmemb.codcomp,
--              p_item06  => r_tsincexp.v_amtprove,
--              p_item07  => r_tsincexp.v_amtprovc,
--              p_item08  => r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc
--            );
          end if; --v_amtprove <> 0 or v_amtprovc <> 0
        end loop; --c_tsincexp
      end if; --pass security
    end loop; --c_tpfmemb

    if v_datatpfmemb = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TPFMEMB');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_chksecure = 'N' then
      param_msg_error      := get_error_msg_php('HR3007',global_v_lang);
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_totrec < 1 then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    /*if v_totrec < 1 then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;*/
    -->>User37 STA11 11/02/2020
    else
      exp_text_bay2(v_error_msg); --สมาชิกเก่า
      if v_error_msg is not null then
        json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
        rollback;
        return;
      else
        json_str_output := obj_row.to_clob;
        --
        utl_file.fclose(out_file);
        p_filename := v_filename;
--        sync_log_file(v_filename);
        commit;
      end if;
    end if;

  end;
  --
  procedure exp_text_aia(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    out_file   		  utl_file.file_type;
    out_file1   	  utl_file.file_type;
    out_file2   	  utl_file.file_type;
    data_file 			varchar2(500);
    data_file1 			varchar2(500);
    data_file2 			varchar2(500);
    v_codempid		 	varchar2(20);
    v_codcomp			  varchar2(50) :=	null;
    v_secur				  boolean;
    v_namcomt			  tcompny.namcomt%type;
    v_codpfinf			tcodpfinf.codcodec%type;
    v_filename      varchar2(255);
    v_filename1     varchar2(255);
    v_filename2     varchar2(255);
    v_totrec			 	number := 0;
    v_totamtprove	  number := 0;
    v_totamtprovc	  number := 0;
    v_first				  varchar2(1)	:= 'Y';

    v_sumrec        number := 0;
    v_chksecure     varchar2(1) := 'N';
    v_datatpfmemb   varchar2(1) := 'N';
    cursor c_tpfmemb is
      select a.codempid,a.codcomp,a.dteeffec,a.dtereti,a.nummember,a.typpayroll,
             b.numlvl,b.codtitle,b.namfirstt,b.namlastt,b.namempt,b.dteempmt,
             b.namempe,ltrim(rtrim(b.codposre)) codposre,a.codpfinf
        from tpfmemb a,temploy1 b
       where a.codcomp    like p_codcompy||'%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.codpfinf   = p_codpfinf
         and a.codempid   = b.codempid
         and (( exists (select codplan
                      from tpfirinf g
                     where g.codempid =  a.codempid
                       and g.codplan  = nvl(p_codplan,g.codplan)
                       and g.dteeffec = (select max(h.dteeffec)
                                           from tpfirinf h
                                          where h.codempid = g.codempid
                                            and h.codplan  = nvl(p_codplan,h.codplan)
                                            and h.dteeffec <= trunc(sysdate)))
--                       and rownum <= 1)
                 and  p_codplan is not null  ) or p_codplan is null)
      order by a.codcomp,a.codempid;

    cursor c_tsincexp is
      select codempid,
             sum(decode(codpay,p_codpaypy3,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprove,
             sum(decode(codpay,p_codpaypy7,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprovc
        from tsincexp
       where codempid   = v_codempid
         and dteyrepay	= p_dteyrepay
         and dtemthpay	= p_dtemthpay
         and numperiod  like p_numperiod||'%'
         and codpay     in (p_codpaypy3,p_codpaypy7)
         and flgslip    = '1'
      group by codempid;
  begin
    if utl_file.is_open(out_file) then
		  utl_file.fclose(out_file);
	  end if;
	  if utl_file.is_open(out_file1) then
		  utl_file.fclose(out_file1);
	  end if;
		if utl_file.is_open(out_file2) then
		  utl_file.fclose(out_file2);
		end if;
    --

    begin
      select namcomt into v_namcomt
        from tcompny
       where codcompy = p_codcompy;
    exception when no_data_found then
      v_namcomt	:= ' ';
    end;

    if p_sta_group = 'N' then
      v_filename := hcm_batchtask.gen_filename(lower('HRPY90B'||'_'||global_v_coduser),'txt',global_v_batch_dtestrt);
      std_deltemp.upd_ttempfile(v_filename,'A');	--'A' = Insert , update ,'D'  = delete
      out_file 	:= utl_file.fopen(p_file_dir,v_filename,'w');
    end if;

    obj_row   := json_object_t();
    for r_tpfmemb in c_tpfmemb loop
      v_datatpfmemb := 'Y';
      v_secur	:= secur_main.secur1(r_tpfmemb.codcomp,nvl(r_tpfmemb.numlvl,0),global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_secur then
        v_chksecure	:= 'Y';
        v_codempid	:= r_tpfmemb.codempid;
        for r_tsincexp in c_tsincexp loop
          if (r_tsincexp.v_amtprove <> 0) or (r_tsincexp.v_amtprovc <> 0) then
            v_sumrec := nvl(v_sumrec,0) + 1;
            r_tpfmemb.nummember := nvl(r_tpfmemb.nummember,' ');
            r_tpfmemb.codtitle  := nvl(r_tpfmemb.codtitle,' ');
            r_tpfmemb.namfirstt := nvl(r_tpfmemb.namfirstt,' ');
            r_tpfmemb.namlastt  := nvl(r_tpfmemb.namlastt,' ');
            r_tpfmemb.codcomp   := nvl(r_tpfmemb.codcomp,' ');

            if p_sta_group = 'N' then
              -- create head
              if v_first = 'Y' then
                v_first := 'N';
                pvdf_exp.head(p_pvdffmt,r_tpfmemb.typpayroll,p_numcomp,
                              p_numfund,p_dtepay,p_dtemthpay,
                              p_dteyrepay,v_totamtprove,v_totamtprovc,v_totrec,
                              v_namcomt,global_v_zyear,global_v_lang,data_file);

                if data_file is not null then
                  utl_file.put_line(out_file,data_file);
                end if;
              end if;

              -- create body
              pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                            r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                            p_numperiod,p_dtemthpay,p_dteyrepay,
                            r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                            r_tpfmemb.nummember,
                            get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                            r_tpfmemb.namfirstt,
                            r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                            r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                            1,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                            data_file,data_file1,data_file2);

              if data_file is not null then
                utl_file.put_line(out_file,data_file);
              end if;

              if data_file1 is not null then
                utl_file.put_line(out_file1,data_file1);
              end if;

              if data_file2 is not null then
                utl_file.put_line(out_file2,data_file2);
              end if;
            end if;

            v_totrec := v_totrec + 1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('nummember', r_tpfmemb.nummember);
            obj_data.put('image', get_emp_img(v_codempid));
            obj_data.put('codempid', v_codempid);
            obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
            obj_data.put('codcomp', r_tpfmemb.codcomp);
            obj_data.put('amtprove', r_tsincexp.v_amtprove);
            obj_data.put('amtprovc', r_tsincexp.v_amtprovc);
            obj_data.put('amtsum', r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc);
            global_t_codempid := v_codempid;
            get_pctpf;
            obj_data.put('pctemppf', global_v_pctemppf);
            obj_data.put('pctcompf', global_v_pctcompf);
            --
            obj_row.put(to_char(v_totrec - 1), obj_data);

            global_v_batch_qtyproc  := v_totrec;
            -- insert batch process detail
            hcm_batchtask.insert_batch_detail(
              p_codapp   => global_v_batch_codapp,
              p_coduser  => global_v_coduser,
              p_codalw   => global_v_batch_codalw,
              p_dtestrt  => global_v_batch_dtestrt,
              p_item01  => r_tpfmemb.nummember,
              p_item02  => get_emp_img(v_codempid),
              p_item03  => v_codempid,
              p_item04  => get_temploy_name(v_codempid, global_v_lang),
              p_item05  => r_tpfmemb.codcomp,
              p_item06  => r_tsincexp.v_amtprove,
              p_item07  => r_tsincexp.v_amtprovc,
              p_item08  => r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc
            );
          end if; --v_amtprove <> 0 or v_amtprovc <> 0
        end loop; --c_tsincexp
      end if; --pass security
    end loop; --c_tpfmemb

    if v_datatpfmemb = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TPFMEMB');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_chksecure = 'N' then
      param_msg_error      := get_error_msg_php('HR3007',global_v_lang);
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_totrec < 1 then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    else
      json_str_output := obj_row.to_clob;
      --
      utl_file.fclose(out_file);
      p_filename := v_filename;
--      sync_log_file(v_filename);
      commit;
    end if;
  end;
  --
  procedure exp_text_tisco(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    out_file   		  utl_file.File_Type;
    out_file1   	  utl_file.File_Type;
    out_file2   	  utl_file.File_Type;
    out_file3   	  utl_file.File_Type;
    data_file 		  varchar2(5000 char);
    data_file1		  varchar2(5000 char);
    data_file2		  varchar2(5000 char);
    v_codempid		  varchar2(2000 char) := null;
    v_codcomp			  varchar2(2000 char) :=	null;
    v_codpfinf			tcodpfinf.codcodec%type;
    v_secur				  boolean;
    v_namcomt			  tcompny.namcomt%type;
    v_filename      varchar2(255);
    v_file1         varchar2(255);
    v_file2         varchar2(255);
    v_file3         varchar2(255);
    v_totrec			  number := 0;
    v_totamtprove	  number := 0;
    v_totamtprovc	  number := 0;
    v_sumrec        number := 0;
    v_first				  varchar2(1) := 'Y';
    v_dtechg_name   date;
    crlf            VARCHAR2(2) := CHR(10);
    v_count         number := 0;
    v_time				  varchar2(100) := null;
    v_date          date;
    v_out_file      varchar2(1) := 'N';
    v_out_file1 	  varchar2(1) := 'N';
    v_out_file2		  varchar2(1) := 'N';
    v_out_file3		  varchar2(1) := 'N';

    --<<User37 STA11 11/02/2020
    v_chksecure     varchar2(1) := 'N';
    v_datatpfmemb   varchar2(1) := 'N';
    -->>User37 STA11 11/02/2020

    cursor c_tpfmemb is
      select a.codempid,a.codcomp,a.dteeffec,a.dtereti,a.nummember,a.typpayroll,
             b.numlvl,b.codtitle,b.namfirstt,b.namlastt,b.namempt,b.dteempmt,
             b.namempe,ltrim(rtrim(b.codposre)) codposre,a.codpfinf
       from tpfmemb a,temploy1 b
      where	a.codcomp like p_codcompy||'%'
        and	a.typpayroll = nvl(p_typpayroll,a.typpayroll)
        and a.codpfinf = p_codpfinf
        and a.codempid = b.codempid
        and exists (select codplan
                      from tpfirinf g
                     where g.codempid =  a.codempid
                       and g.codplan  = nvl(p_codplan,g.codplan)
                       and g.dteeffec = (select max(h.dteeffec)
                                           from tpfirinf h
                                          where h.codempid = g.codempid
                                            and h.codplan  = nvl(p_codplan,h.codplan)
                                            and h.dteeffec <= trunc(sysdate)))
--                       and rownum <= 1)
      order by a.codcomp,a.codempid;

    cursor c_tsincexp is
      select codempid,
             sum(decode(codpay,p_codpaypy3,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprove,
             sum(decode(codpay,p_codpaypy7,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprovc
      from tsincexp
      where	codempid = v_codempid
        and	dteyrepay	= p_dteyrepay - global_v_zyear
        and	dtemthpay	= p_dtemthpay
        and	numperiod like p_numperiod||'%'
        and codpay in (p_codpaypy3,p_codpaypy7)
        and flgslip = '1'
      group by codempid;
  begin

	  if utl_file.Is_Open(out_file) then
		  utl_file.Fclose(out_file);
	  end if;
	  if utl_file.Is_Open(out_file1) then
		  utl_file.Fclose(out_file1);
	  end if;
		if utl_file.Is_Open(out_file2) then
		  utl_file.Fclose(out_file2);
		end if;
		if utl_file.Is_Open(out_file3) then
		  utl_file.Fclose(out_file3);
		end if;
    --
    begin
      select namcomt into v_namcomt
      from tcompny
      where	codcompy = p_codcompy;
    exception when no_data_found then v_namcomt	:= ' ';
    end;
    --
    v_time := to_char(sysdate,'HH24MI');
    --
    -- text1.txt file write /read
    --
    p_filename1  := 'PFIDISK1.txt';
    std_deltemp.upd_ttempfile('PFIDISK1.txt','A');
    out_file1 	:= utl_file.Fopen(p_file_dir,p_filename1,'w');
    --
    p_filename2  := 'PFIDISK2.txt';
    std_deltemp.upd_ttempfile('PFIDISK2.txt','A');
    out_file2 	:= utl_file.Fopen(p_file_dir,p_filename2,'w');
    --
    p_filename3  := 'PFIDISK3.txt';
    std_deltemp.upd_ttempfile('PFIDISK3.txt','A');
    out_file3 	:= utl_file.Fopen(p_file_dir,p_filename3,'w');

    obj_row        := json_object_t();
    for r_tpfmemb in c_tpfmemb loop

      v_secur	:= secur_main.secur1(r_tpfmemb.codcomp,r_tpfmemb.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      v_datatpfmemb := 'Y'; --User37 STA11 11/02/2020
      if v_secur then
        v_chksecure := 'Y'; --User37 STA11 11/02/2020
        v_codempid	:= r_tpfmemb.codempid;
        for r_tsincexp in c_tsincexp loop
          if (r_tsincexp.v_amtprove <> 0) or (r_tsincexp.v_amtprovc <> 0) then
            v_sumrec := nvl(v_sumrec,0) + 1;
            r_tpfmemb.nummember := nvl(r_tpfmemb.nummember,' ');
            r_tpfmemb.codtitle  := nvl(r_tpfmemb.codtitle,' ');
            r_tpfmemb.namfirstt := nvl(r_tpfmemb.namfirstt,' ');
            r_tpfmemb.namlastt  := nvl(r_tpfmemb.namlastt,' ');
            r_tpfmemb.codcomp   := nvl(r_tpfmemb.codcomp,' ');

            if p_sta_group = 'N' then
              -- create head
              if v_first = 'Y' then
                v_first := 'N';
                pvdf_exp.head(p_pvdffmt,r_tpfmemb.typpayroll,p_numcomp,
                              p_numfund,p_dtepay,p_dtemthpay,
                              p_dteyrepay,v_totamtprove,v_totamtprovc,v_totrec,
                              v_namcomt,global_v_zyear,global_v_lang,data_file);

--                data_file := convert(data_file,'TH8TISASCII');
                if data_file is not null then
                  v_out_file := 'Y';
                  utl_file.Put_line(out_file,data_file);
                end if;
              end if;

              -- create body
              begin
                select dtechg into v_dtechg_name
                from thisname
                where codempid = v_codempid
                  and dtechg <= sysdate
                  and rownum = 1
                order by dtechg;
              exception when no_data_found then v_dtechg_name := null;
              end;

              begin
                select count(*) into v_count
                from tdtepay
                where codcompy    = hcm_util.get_codcomp_level(r_tpfmemb.codcomp,1)
                  and typpayroll  = r_tpfmemb.typpayroll
                  and dteyrepay	  = p_dteyrepay - global_v_zyear
                  and dtemthpay	  = p_dtemthpay
                  and numperiod like p_numperiod||'%';
              exception when no_data_found then v_count := 0;
              end;
              if p_pvdffmt = 3 then
                ----- new member thai ------------------------
                if (to_number(to_char(r_tpfmemb.dteeffec,'mm')) = p_dtemthpay ) and
                  (to_char(r_tpfmemb.dteeffec,'yyyy') = to_char(p_dteyrepay)) and
                  (v_count > 0) then
                  pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                                r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                                p_numperiod,p_dtemthpay,p_dteyrepay,
                                r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                                r_tpfmemb.nummember,
                                get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                                r_tpfmemb.namfirstt,
                                r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                                r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                                1,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                                data_file,data_file1,data_file2);

--                  data_file := convert(data_file,'TH8TISASCII');
                  if data_file is not null then
                    v_out_file1 := 'Y';
                    utl_file.Put_line(out_file1,data_file);
                  end if;
                end if;

                ----- change details thai-----------------------
                if ((to_number(to_char(v_dtechg_name,'mm')) = p_dtemthpay ) and
                    (to_char(v_dtechg_name,'yyyy') = to_char(p_dteyrepay))) then
                  pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                                r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                                p_numperiod,p_dtemthpay,p_dteyrepay,
                                r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                                r_tpfmemb.nummember,
                                get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                                r_tpfmemb.namfirstt,
                                r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                                r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                                2,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                                data_file,data_file1,data_file2);

--                  data_file := convert(data_file,'TH8TISASCII');
                  if data_file is not null then
                    v_out_file1 := 'Y';
                    utl_file.Put_line(out_file1,data_file);
                  end if;
                end if;

                ----- new member eng -------------------------
                if (to_number(to_char(r_tpfmemb.dteeffec,'mm')) = p_dtemthpay ) and
                    (to_char(r_tpfmemb.dteeffec,'yyyy') = to_char(p_dteyrepay)) and
                    (v_count > 0 )then
                  pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                                r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                                p_numperiod,p_dtemthpay,p_dteyrepay,
                                r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                                r_tpfmemb.nummember,
                                get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                                r_tpfmemb.namfirstt,
                                r_tpfmemb.namlastt,r_tpfmemb.namempe,v_namcomt,
                                r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                                3,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                                data_file,data_file1,data_file2);

--                  data_file := convert(data_file,'TH8TISASCII');
                  if data_file is not null then
                    v_out_file2 := 'Y';
                    utl_file.Put_line(out_file2,data_file);
                  end if;
                end if;

                ----- change details eng--------------------
                if ((to_number(to_char(v_dtechg_name,'mm')) = p_dtemthpay ) and
                    (to_char(v_dtechg_name,'yyyy') = to_char(p_dteyrepay))) then
                  pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                                r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                                p_numperiod,p_dtemthpay,p_dteyrepay,
                                r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                                r_tpfmemb.nummember,
                                get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                                r_tpfmemb.namfirstt,
                                r_tpfmemb.namlastt,r_tpfmemb.namempe,v_namcomt,
                                r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                                4,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                                data_file,data_file1,data_file2);

--                  data_file := convert(data_file,'TH8TISASCII');
                  if data_file is not null then
                    v_out_file2 := 'Y';
                    utl_file.Put_line(out_file2,data_file);
                  end if;
                end if;
                ----- all -----------------------------
                pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                              r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                              p_numperiod,p_dtemthpay,p_dteyrepay,
                              r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                              r_tpfmemb.nummember,
                              get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                              r_tpfmemb.namfirstt,
                              r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                              r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                              5,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                              data_file,data_file1,data_file2);

--                data_file := convert(data_file,'TH8TISASCII');
                if data_file is not null then
                  v_out_file3 := 'Y';
                  utl_file.Put_line(out_file3,data_file);
                end if;
              else  -- typpvdf <> 3
                pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                              r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                              p_numperiod,p_dtemthpay,p_dteyrepay,
                              r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                              r_tpfmemb.nummember,
                              get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                              r_tpfmemb.namfirstt,
                              r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                              r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                              1,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                              data_file,data_file1,data_file2);

--                data_file := convert(data_file,'TH8TISASCII');
                if data_file is not null then
                  v_out_file := 'Y';
                  utl_file.Put_line(out_file,data_file);
                end if;
              end if; -- typpvdf <> 3
            end if; -- if p_sta_group = 'N'

            -- insert data to block 'data'
            v_totrec := v_totrec + 1;
            --
            obj_data         := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('nummember', r_tpfmemb.nummember);
            obj_data.put('image', get_emp_img(v_codempid));
            obj_data.put('codempid', v_codempid);
            obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
            obj_data.put('codcomp', r_tpfmemb.codcomp);
            obj_data.put('amtprove', r_tsincexp.v_amtprove);
            obj_data.put('amtprovc', r_tsincexp.v_amtprovc);
            obj_data.put('amtsum', r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc);
            global_t_codempid := v_codempid;
            get_pctpf;
            obj_data.put('pctemppf', global_v_pctemppf);
            obj_data.put('pctcompf', global_v_pctcompf);
            --
            obj_row.put(to_char(v_totrec - 1), obj_data);

            global_v_batch_qtyproc  := v_totrec;
            -- insert batch process detail
            hcm_batchtask.insert_batch_detail(
              p_codapp   => global_v_batch_codapp,
              p_coduser  => global_v_coduser,
              p_codalw   => global_v_batch_codalw,
              p_dtestrt  => global_v_batch_dtestrt,
              p_item01  => r_tpfmemb.nummember,
              p_item02  => get_emp_img(v_codempid),
              p_item03  => v_codempid,
              p_item04  => get_temploy_name(v_codempid, global_v_lang),
              p_item05  => r_tpfmemb.codcomp,
              p_item06  => r_tsincexp.v_amtprove,
              p_item07  => r_tsincexp.v_amtprovc,
              p_item08  => r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc
            );
          end if;
        end loop;
      end if;
    end loop;
    --
    --<<User37 STA11 11/02/2020
    if v_datatpfmemb = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TPFMEMB');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_chksecure = 'N' then
      param_msg_error      := get_error_msg_php('HR3007',global_v_lang);
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_totrec < 1 then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    /*if v_totrec < 1 then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;*/
    -->>User37 STA11 11/02/2020
    else
      json_str_output := obj_row.to_clob;
      --
      utl_file.Fclose(out_file);
      utl_file.Fclose(out_file1);
      utl_file.Fclose(out_file2);
      utl_file.Fclose(out_file3);
--      sync_log_file(p_filename);
--      sync_log_file(p_filename1);
--      sync_log_file(p_filename2);
--      sync_log_file(p_filename3);
      commit;
    end if;
  end exp_text_tisco;
  --
  procedure exp_text_fns(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    out_file   		  utl_file.file_type;
    out_file1   	  utl_file.file_type;-- Modify 22/05/2551
    out_file2   	  utl_file.file_type;-- Modify 22/05/2551
    data_file 			varchar2(500);
    data_file1 			varchar2(500);-- Modify 22/05/2551
    data_file2 			varchar2(500);-- Modify 22/05/2551
    v_codempid		 	varchar2(20);
    v_codcomp			  varchar2(50) :=	null;
    v_secur				  boolean;
    v_namcomt			  tcompny.namcomt%type;
    v_codpfinf			tcodpfinf.codcodec%type;
    v_filename      varchar2(255);
    v_filename1     varchar2(255);
    v_filename2     varchar2(255);
    v_totrec			 	number := 0;
    v_totamtprove	  number := 0;
    v_totamtprovc	  number := 0;
    v_first				  varchar2(1)	:= 'Y';

    v_sumrec        number := 0;
    v_chksecure     varchar2(1) := 'N';
    v_datatpfmemb   varchar2(1) := 'N';

    cursor c_tpfmemb is
      select a.codempid,a.codcomp,a.dteeffec,a.dtereti,a.nummember,a.typpayroll,
             b.numlvl,b.codtitle,b.namfirstt,b.namlastt,b.namempt,b.dteempmt,
             b.namempe,ltrim(rtrim(b.codposre)) codposre,a.codpfinf--,c.pvdffmt
        from tpfmemb a,temploy1 b--,tpfhrinf c
       where a.codcomp like p_codcompy||'%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.codpfinf = p_codpfinf
         and a.codempid = b.codempid
--         and a.codpfinf = c.codpfinf
         and exists (select codplan
                      from tpfirinf g
                     where g.codempid =  a.codempid
                       and g.codplan  = nvl(p_codplan,g.codplan)
                       and g.dteeffec = (select max(h.dteeffec)
                                           from tpfirinf h
                                          where h.codempid = g.codempid
                                            and h.codplan  = nvl(p_codplan,h.codplan)
                                            and h.dteeffec <= trunc(sysdate)))
--                       and rownum <= 1)
      order by a.codcomp,a.codempid;

    cursor c_tsincexp is
      select codempid,
            sum(decode(codpay,p_codpaypy3,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprove,
            sum(decode(codpay,p_codpaypy7,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprovc
      from tsincexp
      where	codempid = v_codempid
      and		dteyrepay	= p_dteyrepay - global_v_zyear
      and		dtemthpay	= p_dtemthpay
      and		numperiod like p_numperiod||'%'
      and 	codpay in (p_codpaypy3,p_codpaypy7)
      and		flgslip = '1'
      group by codempid;
  begin

    if p_sta_group = 'N' then
      if utl_file.is_open(out_file) then
         utl_file.fclose(out_file);
      end if;
    end if;
    begin
      select namcomt into v_namcomt
        from tcompny
       where codcompy = p_codcompy;
    exception when no_data_found then v_namcomt	:= ' ';
    end;

    if p_sta_group = 'N' then
        v_filename  := hcm_batchtask.gen_filename(lower('HRPY90B'||'_'||global_v_coduser),'txt',global_v_batch_dtestrt);
        v_filename1 := hcm_batchtask.gen_filename(lower('HRPY90B'||'1_'||global_v_coduser),'txt',global_v_batch_dtestrt);
        v_filename2 := hcm_batchtask.gen_filename(lower('HRPY90B'||'2_'||global_v_coduser),'txt',global_v_batch_dtestrt);

        std_deltemp.upd_ttempfile(v_filename,'A');	--'A' = Insert , update ,'D'  = delete
        std_deltemp.upd_ttempfile(v_filename1,'A');	--'A' = Insert , update ,'D'  = delete
        std_deltemp.upd_ttempfile(v_filename2,'A');	--'A' = Insert , update ,'D'  = delete

        out_file 	:= utl_file.fopen(p_file_dir,v_filename,'w');
        out_file1 := utl_file.fopen(p_file_dir,v_filename1,'w');-- Modify 22/05/2551
        out_file2 := utl_file.fopen(p_file_dir,v_filename2,'w');-- Modify 22/05/2551
    end if;

    obj_row     := json_object_t();
    for r_tpfmemb in c_tpfmemb loop
      v_secur	:= secur_main.secur1(r_tpfmemb.codcomp,nvl(r_tpfmemb.numlvl,0),global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      v_datatpfmemb := 'Y';
      if v_secur then
        v_chksecure	:= 'Y';
        v_codempid	:= r_tpfmemb.codempid;
        for r_tsincexp in c_tsincexp loop
          if (r_tsincexp.v_amtprove <> 0) or (r_tsincexp.v_amtprovc <> 0) then
            v_sumrec := v_sumrec + 1;
            r_tpfmemb.nummember := nvl(r_tpfmemb.nummember,' ');
            r_tpfmemb.codtitle  := nvl(r_tpfmemb.codtitle,' ');
            r_tpfmemb.namfirstt := nvl(r_tpfmemb.namfirstt,' ');
            r_tpfmemb.namlastt  := nvl(r_tpfmemb.namlastt,' ');
            r_tpfmemb.codcomp   := nvl(r_tpfmemb.codcomp,' ');

            if p_sta_group = 'N' then
                -- create body
                pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                              r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                              p_numperiod,p_dtemthpay,p_dteyrepay,
                              r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                              r_tpfmemb.nummember,
                              get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                              r_tpfmemb.namfirstt,
                              r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                              r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                              1,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                              data_file,data_file1,data_file2);

--                data_file  := convert(data_file,'TH8TISASCII');
--                data_file1 := convert(data_file1,'TH8TISASCII');
--                data_file2 := convert(data_file2,'TH8TISASCII');

                if data_file is not null then
                  utl_file.put_line(out_file,data_file);
                end if;
                -- Modify 22/05/2551
                if data_file1 is not null then
                  utl_file.put_line(out_file1,data_file1);
                end if;
                if data_file2 is not null then
                  utl_file.put_line(out_file2,data_file2);
                end if;
                -- Modify 22/05/2551 End --
            end if;

            -- insert data to block 'data'
            v_totrec := v_totrec + 1;
            obj_data         := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('nummember', r_tpfmemb.nummember);
            obj_data.put('image', get_emp_img(v_codempid));
            obj_data.put('codempid', v_codempid);
            obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
            obj_data.put('codcomp', r_tpfmemb.codcomp);
            obj_data.put('amtprove', r_tsincexp.v_amtprove);
            obj_data.put('amtprovc', r_tsincexp.v_amtprovc);
            obj_data.put('amtsum', r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc);
            global_t_codempid := v_codempid;
            get_pctpf;
            obj_data.put('pctemppf', global_v_pctemppf);
            obj_data.put('pctcompf', global_v_pctcompf);
            --
            obj_row.put(to_char(v_totrec - 1), obj_data);

            global_v_batch_qtyproc  := v_totrec;
            -- insert batch process detail
            hcm_batchtask.insert_batch_detail(
              p_codapp   => global_v_batch_codapp,
              p_coduser  => global_v_coduser,
              p_codalw   => global_v_batch_codalw,
              p_dtestrt  => global_v_batch_dtestrt,
              p_item01  => r_tpfmemb.nummember,
              p_item02  => get_emp_img(v_codempid),
              p_item03  => v_codempid,
              p_item04  => get_temploy_name(v_codempid, global_v_lang),
              p_item05  => r_tpfmemb.codcomp,
              p_item06  => r_tsincexp.v_amtprove,
              p_item07  => r_tsincexp.v_amtprovc,
              p_item08  => r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc
            );
          end if; --v_amtprove <> 0 or v_amtprovc <> 0
        end loop; --c_tsincexp
      end if; --pass security
    end loop; --c_tpfmemb

    if v_datatpfmemb = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TPFMEMB');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_chksecure = 'N' then
      param_msg_error      := get_error_msg_php('HR3007',global_v_lang);
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_totrec < 1 then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;

    -->>User37 STA11 11/02/2020
    else
      json_str_output := obj_row.to_clob;
      --
      utl_file.fclose(out_file);
      utl_file.fclose(out_file1);-- Modify 22/05/2551
      utl_file.fclose(out_file2);-- Modify 22/05/2551
      p_filename  := v_filename;
      p_filename1 := v_filename1;
      p_filename2 := v_filename2;
--      sync_log_file(v_filename);
--      sync_log_file(v_filename1);
--      sync_log_file(v_filename2);
      commit;
    end if;

  end;
  --
  procedure exp_text_tcb(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    out_file   		  utl_file.file_type;
    data_file 			varchar2(500);
    data_file1 			varchar2(500);
    data_file2 			varchar2(500);
    v_codempid		 	varchar2(20);
    v_codcomp			  varchar2(50) :=	null;
    v_secur				  boolean;
    v_namcomt			  tcompny.namcomt%type;
    v_codpfinf			tcodpfinf.codcodec%type;
    v_filename      varchar2(255);
    v_filename1     varchar2(255);
    v_filename2     varchar2(255);
    v_totrec			 	number := 0;
    v_totamtprove	  number := 0;
    v_totamtprovc	  number := 0;
    v_first				  varchar2(1)	:= 'Y';

    v_sumrec        number := 0;
    v_chksecure     varchar2(1) := 'N';
    v_datatpfmemb   varchar2(1) := 'N';

    cursor c_tpfmemb is
      select a.codempid,a.codcomp,a.dteeffec,a.dtereti,a.nummember,a.typpayroll,
             b.numlvl,b.codtitle,b.namfirstt,b.namlastt,b.namempt,b.dteempmt,
             b.namempe,ltrim(rtrim(b.codposre)) codposre,a.codpfinf--,c.pvdffmt
        from tpfmemb a,temploy1 b--,tpfhrinf c
       where a.codcomp like p_codcompy||'%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.codpfinf   = p_codpfinf
         and a.codempid   = b.codempid
--         and a.codpfinf   = c.codpfinf
         and exists (select codplan
                      from tpfirinf g
                     where g.codempid =  a.codempid
                       and g.codplan  = nvl(p_codplan,g.codplan)
                       and g.dteeffec = (select max(h.dteeffec)
                                           from tpfirinf h
                                          where h.codempid = g.codempid
                                            and h.codplan  = nvl(p_codplan,h.codplan)
                                            and h.dteeffec <= trunc(sysdate))
--                       and rownum <= 1
                    )
      order by a.codcomp,a.codempid;

    cursor c_tsincexp is
      select codempid,
            sum(decode(codpay,p_codpaypy3,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprove,
            sum(decode(codpay,p_codpaypy7,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprovc
        from tsincexp
       where codempid   = v_codempid
         and dteyrepay	= p_dteyrepay - global_v_zyear
         and dtemthpay	= p_dtemthpay
         and numperiod  like p_numperiod||'%'
         and codpay     in (p_codpaypy3,p_codpaypy7)
         and flgslip    = '1'
      group by codempid;

  begin
    if utl_file.is_open(out_file) then
       utl_file.fclose(out_file);
    end if;

    begin
      select namcomt into v_namcomt
        from tcompny
       where codcompy = p_codcompy;
    exception when no_data_found then
      v_namcomt	:= ' ';
    end;

    if p_sta_group = 'N' then
      v_filename  := hcm_batchtask.gen_filename(lower('HRPY90B'||'_'||global_v_coduser),'txt',global_v_batch_dtestrt);
      std_deltemp.upd_ttempfile(v_filename,'A');	--'A' = Insert , update ,'D'  = delete
      out_file 	:= utl_file.fopen(p_file_dir,v_filename,'w');
    end if;

    obj_row     := json_object_t();
    for r_tpfmemb in c_tpfmemb loop
      v_secur	:= secur_main.secur1(r_tpfmemb.codcomp,nvl(r_tpfmemb.numlvl,0),global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      v_datatpfmemb := 'Y';
      if v_secur then
        v_chksecure	:= 'Y';
        v_codempid	:= r_tpfmemb.codempid;
        for r_tsincexp in c_tsincexp loop
          if (r_tsincexp.v_amtprove <> 0) or (r_tsincexp.v_amtprovc <> 0) then
            v_sumrec     := v_sumrec + 1;
            r_tpfmemb.nummember := nvl(r_tpfmemb.nummember,' ');
            r_tpfmemb.codtitle  := nvl(r_tpfmemb.codtitle,' ');
            r_tpfmemb.namfirstt := nvl(r_tpfmemb.namfirstt,' ');
            r_tpfmemb.namlastt  := nvl(r_tpfmemb.namlastt,' ');
            r_tpfmemb.codcomp   := nvl(r_tpfmemb.codcomp,' ');

            if p_sta_group = 'N' then
              -- create body
              pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                            r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                            p_numperiod,p_dtemthpay,p_dteyrepay,
                            r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                            r_tpfmemb.nummember,
                            get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                            r_tpfmemb.namfirstt,
                            r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                            r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                            1,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                            data_file,data_file1,data_file2);

--              data_file  := convert(data_file,'TH8TISASCII');

              if data_file is not null then
                utl_file.put_line(out_file,data_file);
              end if;
            end if;

            -- insert data to block 'data'
            v_totrec := v_totrec + 1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('nummember', r_tpfmemb.nummember);
            obj_data.put('image', get_emp_img(v_codempid));
            obj_data.put('codempid', v_codempid);
            obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
            obj_data.put('codcomp', r_tpfmemb.codcomp);
            obj_data.put('amtprove', r_tsincexp.v_amtprove);
            obj_data.put('amtprovc', r_tsincexp.v_amtprovc);
            obj_data.put('amtsum', r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc);
            global_t_codempid := v_codempid;
            get_pctpf;
            obj_data.put('pctemppf', global_v_pctemppf);
            obj_data.put('pctcompf', global_v_pctcompf);
            --
            obj_row.put(to_char(v_totrec - 1), obj_data);

            global_v_batch_qtyproc  := v_totrec;
            -- insert batch process detail
            hcm_batchtask.insert_batch_detail(
              p_codapp   => global_v_batch_codapp,
              p_coduser  => global_v_coduser,
              p_codalw   => global_v_batch_codalw,
              p_dtestrt  => global_v_batch_dtestrt,
              p_item01  => r_tpfmemb.nummember,
              p_item02  => get_emp_img(v_codempid),
              p_item03  => v_codempid,
              p_item04  => get_temploy_name(v_codempid, global_v_lang),
              p_item05  => r_tpfmemb.codcomp,
              p_item06  => r_tsincexp.v_amtprove,
              p_item07  => r_tsincexp.v_amtprovc,
              p_item08  => r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc
            );
          end if; --v_amtprove <> 0 or v_amtprovc <> 0
        end loop; --c_tsincexp
      end if;     --pass security
    end loop;     --c_tpfmemb
    if v_datatpfmemb = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TPFMEMB');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_chksecure = 'N' then
      param_msg_error      := get_error_msg_php('HR3007',global_v_lang);
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_totrec < 1 then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    /*if v_totrec < 1 then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;*/
    -->>User37 STA11 11/02/2020
    else
      json_str_output := obj_row.to_clob;
      --
      utl_file.fclose(out_file);
      p_filename := v_filename;
--      sync_log_file(v_filename);
      commit;
    end if;

--    if (v_totamtprove <> 0) or (v_totamtprovc <> 0) then
--      :report.codempid_desc := :ctrl_label2.di_v70||' : ';   --'Total :   ';
--      :report.amtprove := v_totamtprove;
--      :report.amtprovc := v_totamtprovc;
--      :report.amtsum   := v_totamtprove + v_totamtprovc;
--      next_record;
--    end if;

--    if p_sta_group = 'N'  then
--      web.show_document(get_tsetup_value('PATHWEB')||'/temp/'||lower('HRPY90B'||'_'||global_v_coduser)||'.txt');
--    end if;
  end;
  --
  procedure exp_text_katm(json_str_output out clob) is
    obj_row        json_object_t;
    obj_data       json_object_t;
    out_file   		 utl_file.file_type;
    out_file1   	 utl_file.file_type;
    out_file2   	 utl_file.file_type;
    out_file3   	 utl_file.file_type;
    data_file 		 varchar2(500);
    data_file1		 varchar2(500);
    data_file2		 varchar2(500);
    v_filename		 varchar2(255);
    v_filename1		 varchar2(255);
    v_codempid		 varchar2(50) := null;
    v_codcomp			 varchar2(50) :=	null;
    v_codpfinf		 tcodpfinf.codcodec%type;
    v_secur				 boolean;
    v_amtprove		 number := 0;
    v_amtprovc		 number := 0;
    v_totamtprovc	 number := 0;
    v_totamtprove	 number := 0;
    v_totrec			 number := 0;
    v_first				 varchar2(1)	:= 'Y';
    v_namcomt			 varchar2(100);
    v_out_file     varchar2(1) := 'N';
    v_out_file1 	 varchar2(1) := 'N';
    v_out_file2		 varchar2(1) := 'N';
    v_out_file3		 varchar2(1) := 'N';
    v_count				 number ;

    v_sumrec       number := 0;
    v_chksecure    varchar2(1) := 'N';
    v_datatpfmemb  varchar2(1) := 'N';

    cursor c_tpfmemb is
     select a.codempid,a.codcomp,a.dteeffec,a.dtereti,a.nummember,a.typpayroll,
            b.numlvl,b.namempt,b.dteempmt,b.codtitle,b.namfirstt,b.namlastt,
            a.codpfinf--,c.pvdffmt
       from tpfmemb a,temploy1 b--,tpfhrinf c
      where a.codcomp    like p_codcompy||'%'
        and	a.typpayroll = nvl(p_typpayroll,a.typpayroll)
        and a.codpfinf   = p_codpfinf
        and a.codempid   = b.codempid
--        and a.codpfinf   = c.codpfinf
        and exists (select codplan
                      from tpfirinf g
                     where g.codempid =  a.codempid
                       and g.codplan  = nvl(p_codplan,g.codplan)
                       and g.dteeffec = (select max(h.dteeffec)
                                           from tpfirinf h
                                          where h.codempid = g.codempid
                                            and h.codplan  = nvl(p_codplan,h.codplan)
                                            and h.dteeffec <= trunc(sysdate)))
--                       and rownum <= 1)
      order by a.codcomp,a.codempid;


    cursor c_tsincexp is
      select codempid,
             sum(decode(codpay,p_codpaypy3,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprove,
             sum(decode(codpay,p_codpaypy7,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprovc
        from tsincexp
       where codempid   = v_codempid
         and dteyrepay	= p_dteyrepay - global_v_zyear
         and dtemthpay	= p_dtemthpay
         and numperiod like p_numperiod||'%'
         and codpay in (p_codpaypy3,p_codpaypy7)
         and flgslip = '1'
    group by codempid;

  begin

    if utl_file.is_open(out_file) then
       utl_file.fclose(out_file);
    end if;

    if utl_file.is_open(out_file1) then
       utl_file.fclose(out_file1);
    end if;

    begin
      select namcomt into v_namcomt
      from tcompny
      where	codcompy = p_codcompy;
    exception when no_data_found then
      v_namcomt	:= ' ';
    end;

    if p_sta_group = 'N' then
      v_filename  := hcm_batchtask.gen_filename('M'||lpad(p_dtemthpay,2,'0')||to_char(p_dteyrepay),'txt',global_v_batch_dtestrt);
      std_deltemp.upd_ttempfile(v_filename,'A');	--'A' = Insert , update ,'D'  = delete
      out_file 	:= utl_file.fopen(p_file_dir,v_filename,'w');

      v_filename1  := hcm_batchtask.gen_filename('C'||lpad(p_dtemthpay,2,'0')||to_char(p_dteyrepay),'txt',global_v_batch_dtestrt);
      std_deltemp.upd_ttempfile(v_filename1,'A');	--'A' = Insert , update ,'D'  = delete
      out_file1	:= utl_file.fopen(p_file_dir,v_filename1,'w');
    end if;

    obj_row   := json_object_t();
    for r_tpfmemb in c_tpfmemb loop

      v_secur	:= secur_main.secur1(r_tpfmemb.codcomp,r_tpfmemb.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      v_datatpfmemb := 'Y';

      if v_secur then
        v_chksecure	:= 'Y';
        v_codempid := r_tpfmemb.codempid;

        for r_tsincexp in c_tsincexp loop

          if (r_tsincexp.v_amtprove <> 0) or (r_tsincexp.v_amtprovc <> 0) then
            p_chk_filebay1 := 'Y';
            v_sumrec     := v_sumrec + 1;
            r_tpfmemb.nummember := nvl(r_tpfmemb.nummember,' ');
            r_tpfmemb.codtitle  := nvl(r_tpfmemb.codtitle,' ');
            r_tpfmemb.namfirstt := nvl(r_tpfmemb.namfirstt,' ');
            r_tpfmemb.namlastt  := nvl(r_tpfmemb.namlastt,' ');
            r_tpfmemb.codcomp   := nvl(r_tpfmemb.codcomp,' ');

            if p_sta_group = 'N' then

              begin
                select count(*) into v_count
                 from tdtepay
                where codcompy    = hcm_util.get_codcomp_level(r_tpfmemb.codcomp,'1')
                  and typpayroll  = r_tpfmemb.typpayroll
                  and dteyrepay	  = p_dteyrepay - global_v_zyear
                  and dtemthpay	  = p_dtemthpay
                  and numperiod like p_numperiod||'%';
              exception when no_data_found then
                v_count := 0;
              end;

              ----- new member thai ------------------------
              if (to_number(to_char(r_tpfmemb.dteeffec,'mm')) = p_dtemthpay ) and
                (to_char(r_tpfmemb.dteeffec,'yyyy') = to_char(p_dteyrepay)) and
                (v_count > 0) then
                pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                              r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                              p_numperiod,p_dtemthpay,p_dteyrepay,
                              r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                              r_tpfmemb.nummember,
                              get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                              r_tpfmemb.namfirstt,
                              r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                              r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                              1,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                              data_file,data_file1,data_file2);

--                data_file  := convert(data_file,'TH8TISASCII');
                if data_file is not null then
                  v_out_file1 := 'Y';
                  utl_file.put_line(out_file,data_file);
                end if;
              end if;

              -- create body
              pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                            r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                            p_numperiod,p_dtemthpay,p_dteyrepay,
                            r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                            r_tpfmemb.nummember,
                            get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                            r_tpfmemb.namfirstt,
                            r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                            r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                            2,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                            data_file,data_file1,data_file2);

--              data_file1 := convert(data_file1,'TH8TISASCII');

              if data_file1 is not null then
                v_out_file2 := 'Y';
                utl_file.put_line(out_file1,data_file1);
              end if;

            end if;

            -- insert data to block 'data'
            v_totrec	       := v_totrec + 1;
            obj_data         := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('nummember', r_tpfmemb.nummember);
            obj_data.put('image', get_emp_img(v_codempid));
            obj_data.put('codempid', v_codempid);
            obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
            obj_data.put('codcomp', r_tpfmemb.codcomp);
            obj_data.put('amtprove', r_tsincexp.v_amtprove);
            obj_data.put('amtprovc', r_tsincexp.v_amtprovc);
            obj_data.put('amtsum', r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc);
            global_t_codempid := v_codempid;
            get_pctpf;
            obj_data.put('pctemppf', global_v_pctemppf);
            obj_data.put('pctcompf', global_v_pctcompf);
            --
            obj_row.put(to_char(v_totrec - 1), obj_data);

            global_v_batch_qtyproc  := v_totrec;
            -- insert batch process detail
            hcm_batchtask.insert_batch_detail(
              p_codapp   => global_v_batch_codapp,
              p_coduser  => global_v_coduser,
              p_codalw   => global_v_batch_codalw,
              p_dtestrt  => global_v_batch_dtestrt,
              p_item01  => r_tpfmemb.nummember,
              p_item02  => get_emp_img(v_codempid),
              p_item03  => v_codempid,
              p_item04  => get_temploy_name(v_codempid, global_v_lang),
              p_item05  => r_tpfmemb.codcomp,
              p_item06  => r_tsincexp.v_amtprove,
              p_item07  => r_tsincexp.v_amtprovc,
              p_item08  => r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc
            );
          end if; --v_amtprove <> 0 or v_amtprovc <> 0

        end loop; --c_tsincexp
      end if; --pass security
    end loop; --c_tpfmemb

    if v_datatpfmemb = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TPFMEMB');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_chksecure = 'N' then
      param_msg_error      := get_error_msg_php('HR3007',global_v_lang);
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_totrec < 1 then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    else
      json_str_output := obj_row.to_clob;
      --
      utl_file.Fclose(out_file);
      utl_file.Fclose(out_file1);
      p_filename  := v_filename;
      p_filename1 := v_filename1;
--      sync_log_file(v_filename);
--      sync_log_file(v_filename1);
      commit;
    end if;

--    if (v_totamtprove <> 0) or (v_totamtprovc <> 0) then
--      :report.codempid_desc := :ctrl_label2.di_v70||' : '; --'Total : ';
--      :report.amtprove := v_totamtprove;
--      :report.amtprovc := v_totamtprovc;
--      :report.amtsum := v_totamtprove + v_totamtprovc;
--      next_record;
--    end if;

--    if p_sta_group = 'N' then
--      if v_out_file1 = 'Y' then
--           web.show_document(get_tsetup_value('PATHWEB')||'/temp/'||
--                        'M'||lpad(p_dtemthpay,2,'0')||to_char(p_dteyrepay)||'.txt');
--      end if;
--      if v_out_file2 = 'Y' then
--         web.show_document(get_tsetup_value('PATHWEB')||'/temp/'||
--                        'C'||lpad(p_dtemthpay,2,'0')||to_char(p_dteyrepay)||'.txt');
--      end if;
--    end if;
  end;
  --
  procedure chk_chg_data(p_codempid in varchar2 ,
                         p_dteeffec in date ,
                         p_codcomp in varchar2,
                         p_typpayroll in varchar2,
                         p_flg out number) is

  v_codempid       temploy1.codempid%type;
  v_amtprove_old   number;
  v_amtprovc_old   number;
  v_amtprove_new   number;
  v_amtprovc_new   number;
  v_count          number;
  v_dtechg_name    date;

  cursor c_tsincexp is
    select dteyrepay , dtemthpay , numperiod,
             sum(decode(codpay,p_codpaypy3,to_number(stddec(amtpay,codempid,global_v_chken)),0)) amtprove_old,
             sum(decode(codpay,p_codpaypy7,to_number(stddec(amtpay,codempid,global_v_chken)),0)) amtprovc_old
      from tsincexp
     where	codempid = p_codempid
       and  dteyrepay||to_char(dtemthpay,'fm00')||to_char(numperiod,'fm00')
            < (p_dteyrepay - global_v_zyear)
              ||to_char(to_number(p_dtemthpay),'fm00')||to_char(to_number(p_numperiod),'fm00')
       and 	codpay in (p_codpaypy3,p_codpaypy7)
       and	flgslip = '1'
       group by  dteyrepay , dtemthpay , numperiod
       order by  dteyrepay desc, dtemthpay desc, numperiod desc;

  begin
    begin
      select count(*) into v_count
      from  tdtepay
      where codcompy  = hcm_util.get_codcomp_level(p_codcomp,'1')
      and   typpayroll     = p_typpayroll
      and 	dteyrepay	  = p_dteyrepay - global_v_zyear
      and   dtemthpay	  = p_dtemthpay
      and  	numperiod like p_numperiod;
    exception when no_data_found then
      v_count := 0;
    end;

   if (to_number(to_char(p_dteeffec,'mm')) = p_dtemthpay ) and
       (to_char(p_dteeffec,'yyyy') = to_char(p_dteyrepay)) and (v_count > 0) then
      p_flg := 1; -- new member

   else

      begin
        select dtechg into v_dtechg_name
        from thisname
        where codempid = p_codempid
        and dtechg <= sysdate
        and rownum = 1
        order by dtechg;
      exception when no_data_found then
        v_dtechg_name := null;
      end;

      if ((to_number(to_char(v_dtechg_name,'mm')) = p_dtemthpay ) and
           (to_char(v_dtechg_name,'yyyy') = to_char(p_dteyrepay))) then
         p_flg := 2;  -- changed data
         return;
      end if;
      for i in c_tsincexp loop
        v_amtprove_old := i.amtprove_old;
        v_amtprovc_old := i.amtprovc_old;
        exit;
      end loop;

      begin  --find current data of amtprove,amtprovc
        select codempid,
              sum(decode(codpay,p_codpaypy3,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprove,
              sum(decode(codpay,p_codpaypy7,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprovc
         into v_codempid , v_amtprove_new , v_amtprovc_new
        from tsincexp
        where	codempid  = p_codempid
          and	dteyrepay	= p_dteyrepay - global_v_zyear
          and	dtemthpay	= p_dtemthpay
          and	numperiod like p_numperiod
          and  codpay in (p_codpaypy3,p_codpaypy7)
          and	flgslip = '1'
        group by codempid;
      exception when no_data_found then
         v_amtprove_new := null;
         v_amtprovc_new := null;
      end;

      if (v_amtprove_old <> v_amtprove_new) or (v_amtprovc_old <> v_amtprovc_new) then
        p_flg := 2;   -- changed data
      else
        p_flg := 3;   -- Normal
      end if;
      return;

   end if;

  end;
  --
  procedure exp_text_kasset(json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;
    out_file   		utl_file.file_type;
    data_file 		varchar2(500);
    data_file1 		varchar2(500);
    data_file2 		varchar2(500);

    v_codempid		ttaxcur.codempid%type := null;
    v_codcomp			ttaxcur.codcomp%type :=	null;
    v_secur				boolean;
    v_namcomt			tcompny.namcomt%type;
    v_filename    varchar2(255);
    v_totrec			number := 0;
    v_totamtprove	number := 0;
    v_totamtprovc	number := 0;
    v_first				varchar2(1)	:= 'Y';
    p_flg         number;

    v_sumrec        number := 0;
    v_chksecure     varchar2(1) := 'N';
    v_datatpfmemb   varchar2(1) := 'N';

    cursor c_tpfmemb is
      select a.codempid,a.codcomp,a.dteeffec,a.dtereti,a.nummember,a.typpayroll,
           b.numlvl,b.namempt,b.dteempmt,b.codtitle,b.namfirstt,b.namlastt,a.codpfinf
      from tpfmemb a,temploy1 b
     where a.codcomp like p_codcompy||'%'
       and a.codempid = b.codempid
       and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
       and a.codpfinf = p_codpfinf
       --and ((a.dteeffec < :ctrl.dtebeg) or (a.dteeffec > :ctrl.dteend))
       and (( exists (select codplan
                    from tpfirinf g
                   where g.codempid =  a.codempid
                     and g.codplan  = nvl(p_codplan,g.codplan)
                     and g.dteeffec = (select max(h.dteeffec)
                                         from tpfirinf h
                                        where h.codempid = g.codempid
                                          and h.codplan  = nvl(p_codplan,h.codplan)
                                          and h.dteeffec <= trunc(sysdate)))
--                     and rownum <= 1)
              and  p_codplan is not null  ) or p_codplan is null)
    order by a.codcomp,a.codempid;

  cursor c_tsincexp is
      select codempid,
             sum(decode(codpay,p_codpaypy3,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprove,
             sum(decode(codpay,p_codpaypy7,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprovc
      from  tsincexp
      where	codempid = v_codempid
      and		dteyrepay	= p_dteyrepay - global_v_zyear
      and		dtemthpay	= p_dtemthpay
      and		numperiod like p_numperiod||'%'
      and 	codpay in (p_codpaypy3,p_codpaypy7)
      and		flgslip = '1'
    group by codempid;

  begin
     v_sumrec := 0 ;
     if utl_file.is_open(out_file) then
        utl_file.fclose(out_file);
     end if;
     begin
        select namcomt into v_namcomt
        from tcompny
        where	codcompy = p_codcompy;
     exception when no_data_found then
        v_namcomt	:= ' ';
     end;

     v_filename  := hcm_batchtask.gen_filename(lower('HRPY90B'||'_'||global_v_coduser),'txt',global_v_batch_dtestrt);
     out_file := utl_file.fopen(p_file_dir,v_filename, 'w');



     obj_row   := json_object_t();
     for r_tpfmemb in c_tpfmemb loop
        v_secur	:= secur_main.secur1(r_tpfmemb.codcomp,nvl(r_tpfmemb.numlvl,0),global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        v_datatpfmemb := 'Y';
        if v_secur then
           v_chksecure	:= 'Y';
           v_codempid	:= r_tpfmemb.codempid;

           for r_tsincexp in c_tsincexp loop
              if (r_tsincexp.v_amtprove <> 0) or (r_tsincexp.v_amtprovc <> 0) then
                 v_sumrec := v_sumrec + 1;
                 r_tpfmemb.nummember := nvl(r_tpfmemb.nummember,' ');
                 r_tpfmemb.codtitle  := nvl(r_tpfmemb.codtitle,' ');
                 r_tpfmemb.namfirstt := nvl(r_tpfmemb.namfirstt,' ');
                 r_tpfmemb.namlastt  := nvl(r_tpfmemb.namlastt,' ');
                 r_tpfmemb.codcomp   := nvl(r_tpfmemb.codcomp,' ');

                 -- create head
                 if v_first = 'Y' then
                    v_first := 'N';
                    v_namcomt := r_tpfmemb.codcomp  ;
                    pvdf_exp.head(p_pvdffmt,r_tpfmemb.typpayroll,p_numcomp,
                                  p_numfund,p_dtepay,p_dtemthpay,
                                  p_dteyrepay,v_totamtprove,v_totamtprovc,v_totrec,
                                  v_namcomt,global_v_zyear,p_numperiod,data_file);



                    if data_file is not null then
--                       data_file := convert(data_file,'TH8TISASCII');
                       utl_file.put_line(out_file,data_file);
                    end if;
                 end if;


                 chk_chg_data(r_tpfmemb.codempid,r_tpfmemb.dteeffec,
                                r_tpfmemb.codcomp,r_tpfmemb.typpayroll,p_flg);
                 -- create body
                  pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                                r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                                p_numperiod,p_dtemthpay,p_dteyrepay,
                                r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                                r_tpfmemb.nummember,get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                                r_tpfmemb.namfirstt,r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                                r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,

                                p_flg,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                                data_file,data_file1,data_file2);

                 if data_file is not null then
--                    data_file  := convert(data_file,'TH8TISASCII');
                    utl_file.put_line(out_file,data_file);
                 end if;
                 -- insert data to block 'data'
                v_totrec := v_totrec + 1;
                obj_data         := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('nummember', r_tpfmemb.nummember);
                obj_data.put('image', get_emp_img(v_codempid));
                obj_data.put('codempid', v_codempid);
                obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
                obj_data.put('codcomp', r_tpfmemb.codcomp);
                obj_data.put('amtprove', r_tsincexp.v_amtprove);
                obj_data.put('amtprovc', r_tsincexp.v_amtprovc);
                obj_data.put('amtsum', r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc);
                global_t_codempid := v_codempid;
                get_pctpf;
                obj_data.put('pctemppf', global_v_pctemppf);
                obj_data.put('pctcompf', global_v_pctcompf);
                --
                obj_row.put(to_char(v_totrec - 1), obj_data);

                global_v_batch_qtyproc  := v_totrec;
                -- insert batch process detail
                hcm_batchtask.insert_batch_detail(
                  p_codapp   => global_v_batch_codapp,
                  p_coduser  => global_v_coduser,
                  p_codalw   => global_v_batch_codalw,
                  p_dtestrt  => global_v_batch_dtestrt,
                  p_item01  => r_tpfmemb.nummember,
                  p_item02  => get_emp_img(v_codempid),
                  p_item03  => v_codempid,
                  p_item04  => get_temploy_name(v_codempid, global_v_lang),
                  p_item05  => r_tpfmemb.codcomp,
                  p_item06  => r_tsincexp.v_amtprove,
                  p_item07  => r_tsincexp.v_amtprovc,
                  p_item08  => r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc
                );
              end if; --v_amtprove <> 0 or v_amtprovc <> 0
           end loop; --c_tsincexp
        end if; --pass security
     end loop; --c_tpfmemb

      if v_datatpfmemb = 'N' then
        param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TPFMEMB');
        json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
        rollback;
        return;
      elsif v_chksecure = 'N' then
        param_msg_error      := get_error_msg_php('HR3007',global_v_lang);
        json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
        rollback;
        return;
      elsif v_totrec < 1 then
        param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
        json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
        rollback;
        return;
      else
        json_str_output := obj_row.to_clob;
        --
        utl_file.Fclose(out_file);
        p_filename := v_filename;
--        sync_log_file(v_filename);
        commit;
      end if;

--      utl_file.fclose(out_file);

--     if (v_totamtprove <> 0) or (v_totamtprovc <> 0) then
--        go_block('report');
--        :report.codempid_desc   := :ctrl_label2.di_v70||' : ';   --'Total :   ';
--        :report.amtprove := v_totamtprove;
--        :report.amtprovc := v_totamtprovc;
--        :report.amtsum   := v_totamtprove + v_totamtprovc;
--        next_record;
--     end if;

--     web.show_document(get_tsetup_value('PATHWEB')||'/temp/'||lower('HRPY90B'||'_'||global_v_coduser)||'.txt');

  end;
  --
  procedure exp_text(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    out_file   		  utl_file.File_Type;
    data_file 			varchar2(5000 char);
    data_file1 			varchar2(5000 char);
    data_file2 			varchar2(5000 char);
    v_codempid		 	varchar2(2000 char);
    v_codcomp			  varchar2(2000 char);
    v_secur				  boolean;
    v_namcomt			  tcompny.namcomt%type;
    v_codpfinf			tcodpfinf.codcodec%type;
    v_totrec			 	number := 0;
    v_totamtprove	  number := 0;
    v_totamtprovc	  number := 0;
    v_sumrec        number := 0;
    v_first				  varchar2(1 char)	:= 'Y';

    --<<User37 STA11 11/02/2020
    v_chksecure     varchar2(1) := 'N';
    v_datatpfmemb   varchar2(1) := 'N';
    -->>User37 STA11 11/02/2020

    cursor c_tpfmemb is
      select a.codempid,a.codcomp,a.dteeffec,a.dtereti,a.nummember,a.typpayroll,
             b.numlvl,b.codtitle,b.namfirstt,b.namlastt,b.namempt,b.dteempmt,
             b.namempe,ltrim(rtrim(b.codposre)) codposre,a.codpfinf
        from tpfmemb a,temploy1 b
       where a.codcomp    like p_codcompy||'%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.codpfinf   = p_codpfinf
         and a.codempid   = b.codempid
         and (( exists (select codplan
                      from tpfirinf g
                     where g.codempid =  a.codempid
                       and g.codplan  = nvl(p_codplan,g.codplan)
                       and g.dteeffec = (select max(h.dteeffec)
                                           from tpfirinf h
                                          where h.codempid = g.codempid
                                            and h.codplan  = nvl(p_codplan,h.codplan)
                                            and h.dteeffec <= trunc(sysdate)))
--                       and rownum <= 1)
                and  p_codplan is not null  ) or p_codplan is null)
      order by a.codcomp,a.codempid;

    cursor c_tsincexp is
      select codempid,
             sum(decode(codpay,p_codpaypy3,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprove,
             sum(decode(codpay,p_codpaypy7,to_number(stddec(amtpay,codempid,global_v_chken)),0)) v_amtprovc
        from tsincexp
       where codempid   = v_codempid
         and dteyrepay	= p_dteyrepay - global_v_zyear
         and dtemthpay	= p_dtemthpay
         and numperiod  like p_numperiod||'%'
         and codpay     in (p_codpaypy3,p_codpaypy7) --comment for test
         and flgslip    = '1'
      group by codempid;
  begin
    if utl_file.Is_Open(out_file) then
       utl_file.Fclose(out_file);
    end if;
    --
    begin
      select namcomt into v_namcomt
        from tcompny
       where codcompy = p_codcompy;
    exception when no_data_found then
      v_namcomt	:= ' ';
    end;
    -- text1.txt file write /read
    p_filename := hcm_batchtask.gen_filename(lower('HRPY90B'||'_'||global_v_coduser),'txt',global_v_batch_dtestrt);
    --
    std_deltemp.upd_ttempfile(p_filename,'A');
    --
    out_file 	:= utl_file.Fopen(p_file_dir,p_filename,'w');
    --
    obj_row        := json_object_t();
    for r_tpfmemb in c_tpfmemb loop
      v_secur	:= secur_main.secur1(r_tpfmemb.codcomp,nvl(r_tpfmemb.numlvl,0),global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      v_datatpfmemb := 'Y'; --User37 STA11 11/02/2020
      if v_secur then
        v_codempid	:= r_tpfmemb.codempid;
        v_chksecure := 'Y'; --User37 STA11 11/02/2020
        for r_tsincexp in c_tsincexp loop
          if (r_tsincexp.v_amtprove <> 0) or (r_tsincexp.v_amtprovc <> 0) then
            v_sumrec := v_sumrec + 1;
            r_tpfmemb.nummember := nvl(r_tpfmemb.nummember,' ');
            r_tpfmemb.codtitle  := nvl(r_tpfmemb.codtitle,' ');
            r_tpfmemb.namfirstt := nvl(r_tpfmemb.namfirstt,' ');
            r_tpfmemb.namlastt  := nvl(r_tpfmemb.namlastt,' ');
            r_tpfmemb.codcomp   := nvl(r_tpfmemb.codcomp,' ');
            if p_sta_group = 'N' then
              -- create head
              if v_first = 'Y' then
                v_first := 'N';
                pvdf_exp.head(p_pvdffmt,r_tpfmemb.typpayroll,p_numcomp,
                              p_numfund,p_dtepay,p_dtemthpay,
                              p_dteyrepay,v_totamtprove,v_totamtprovc,v_totrec,
                              v_namcomt,global_v_zyear,global_v_lang,data_file);

--                data_file := convert(data_file,'TH8TISASCII');
                if data_file is not null then
                  utl_file.Put_line(out_file,data_file);
                end if;
              end if;

              -- create body
              pvdf_exp.body(p_pvdffmt,r_tpfmemb.codempid,r_tpfmemb.dteempmt,
                            r_tpfmemb.dteeffec,r_tpfmemb.dtereti,p_dtepay,
                            p_numperiod,p_dtemthpay,p_dteyrepay,
                            r_tpfmemb.typpayroll,p_numcomp,p_numfund,
                            r_tpfmemb.nummember,
                            get_tlistval_name('CODTITLE',r_tpfmemb.codtitle,global_v_lang),
                            r_tpfmemb.namfirstt,
                            r_tpfmemb.namlastt,r_tpfmemb.namempt,v_namcomt,
                            r_tsincexp.v_amtprove,r_tsincexp.v_amtprovc,r_tpfmemb.codcomp,
                            1,global_v_zyear,global_v_lang,p_codpfinf,global_v_chken,
                            data_file,data_file1,data_file2);

--              data_file  := convert(data_file,'TH8TISASCII');
              if data_file is not null then
                utl_file.Put_line(out_file,data_file);
              end if;

              -- insert data to block 'data'
              v_totrec := v_totrec + 1;
              --
              obj_data         := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('nummember', r_tpfmemb.nummember);
              obj_data.put('image', get_emp_img(v_codempid));
              obj_data.put('codempid', v_codempid);
              obj_data.put('dteyrepay', p_dteyrepay);
              obj_data.put('dtemthpay', p_dtemthpay);
              obj_data.put('numperiod', p_numperiod);
              obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
              obj_data.put('codcomp', r_tpfmemb.codcomp);
              obj_data.put('amtprove', r_tsincexp.v_amtprove);
              obj_data.put('amtprovc', r_tsincexp.v_amtprovc);
              obj_data.put('amtsum', r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc);
              global_t_codempid := v_codempid;
              get_pctpf;
              obj_data.put('pctemppf', global_v_pctemppf);
              obj_data.put('pctcompf', global_v_pctcompf);

              obj_row.put(to_char(v_totrec - 1), obj_data);

              global_v_batch_qtyproc  := v_totrec;
              -- insert batch process detail
              hcm_batchtask.insert_batch_detail(
                p_codapp   => global_v_batch_codapp,
                p_coduser  => global_v_coduser,
                p_codalw   => global_v_batch_codalw,
                p_dtestrt  => global_v_batch_dtestrt,
                p_item01   => r_tpfmemb.nummember,
                p_item02   => get_emp_img(v_codempid),
                p_item03   => v_codempid,
                p_item04   => p_dteyrepay,
                p_item05   => p_dtemthpay,
                p_item06   => p_numperiod,
                p_item07   => get_temploy_name(v_codempid, global_v_lang),
                p_item08   => r_tpfmemb.codcomp,
                p_item09   => r_tsincexp.v_amtprove,
                p_item10   => r_tsincexp.v_amtprovc,
                p_item11   => r_tsincexp.v_amtprove + r_tsincexp.v_amtprovc
              );
            end if;
          end if;
        end loop;
      end if;
    end loop;
    --
    --<<User37 STA11 11/02/2020
    if v_datatpfmemb = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_chksecure = 'N' then
      param_msg_error      := get_error_msg_php('HR3007',global_v_lang);
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    elsif v_totrec < 1 then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    /*if v_totrec < 1 then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;*/
    -->>User37 STA11 11/02/2020
    else
      json_str_output := obj_row.to_clob;

      utl_file.Fclose(out_file);
--      sync_log_file(p_filename);
      commit;
    end if;
  end exp_text;
  --
  procedure gen_process(json_str_output out clob) as
    obj_rows        json_object_t := json_object_t();
    disp_data       clob;
  begin
    if p_pvdffmt = '6' then -- 6-Bay,
      p_chk_filebay1 := 'N';
      p_chk_filebay2 := 'N';
      exp_text_bay1(disp_data); --สมาชิกใหม่
    elsif p_pvdffmt = '3' then  -- tisco
      exp_text_tisco(disp_data);
    elsif p_pvdffmt = '9' then  -- AIA
      exp_text_aia(disp_data);
    elsif p_pvdffmt = '14' then -- finansa
      exp_text_fns(disp_data);
    elsif p_pvdffmt = '15' then -- thanachart bank
      exp_text_tcb(disp_data);
    elsif p_pvdffmt = '17' then -- 17-KATM
      exp_text_katm(disp_data);
    elsif p_pvdffmt = '18' then -- 18-K-Asset
      exp_text_kasset(disp_data);
    else
      exp_text(disp_data);
    end if;

    if param_msg_error is null then
      obj_rows.put('coderror','200');
      obj_rows.put('response',hcm_secur.get_response('200',get_error_msg_php('HR2715',global_v_lang),global_v_lang));
      --
      if p_filename is not null then
        obj_rows.put('message1',p_file_path || p_filename);
      end if;
      if p_filename1 is not null then
        obj_rows.put('message2',p_file_path || p_filename1);
      end if;
      if p_filename2 is not null then
        obj_rows.put('message3',p_file_path || p_filename2);
      end if;
      if p_filename3 is not null then
        obj_rows.put('message4',p_file_path || p_filename3);
      end if;
      obj_rows.put('datadisp',json_object_t(disp_data));

      -- set complete batch process
      global_v_batch_flgproc  := 'Y';
      global_v_batch_filename1 := p_filename;
      global_v_batch_pathfile1 := p_file_path || p_filename;
      global_v_batch_filename2 := p_filename1;
      global_v_batch_pathfile2 := p_file_path || p_filename1;
      global_v_batch_filename3 := p_filename2;
      global_v_batch_pathfile3 := p_file_path || p_filename2;
      global_v_batch_filename4 := p_filename3;
      global_v_batch_pathfile4 := p_file_path || p_filename3;
    else
      obj_rows.put('coderror','400');
      obj_rows.put('response',hcm_secur.get_response('400',param_msg_error,global_v_lang));
    end if;

    json_str_output := obj_rows.to_clob;
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
  --
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

end hrpy90b;

/

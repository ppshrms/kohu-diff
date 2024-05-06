--------------------------------------------------------
--  DDL for Package Body HRPY91B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY91B" as
  function get_deduct(v_codeduct varchar2) return char is
     v_type varchar2(1);
  begin
     select typdeduct
     into v_type
     from tcodeduct
     where coddeduct = v_codeduct;
     return (v_type);
  exception when others then
     return ('D');
  end;

  function gtempded (v_empid 			varchar2,
                     v_codeduct 	varchar2,
                     v_type 			varchar2,
                     v_amtcode 		number,
                     p_amtsalyr 	number) return number is

    v_amtdeduct 	number(14,2);
    v_amtdemax		tdeductd.amtdemax%type;
    v_pctdemax		tdeductd.pctdemax%type;
    v_formula			tdeductd.formula%type;
    v_pctamt 			number(14,2);
    v_check  			varchar2(20);
    v_typeded  		varchar2(1);

  begin
    v_amtdeduct := v_amtcode;
    if v_amtdeduct = 0 then  --- Case : If amount is not calculated from system.
      if p_dteyrepay < to_char(sysdate,'yyyy') then
        begin
          select decode(v_type,'1',stddec(amtdeduct,codempid,global_v_chken),stddec(amtspded,codempid,global_v_chken))
          into v_amtdeduct
          from tlastempd
          where dteyrepay = p_dteyrepay - global_v_zyear
          and codempid    = v_empid
          and coddeduct   = v_codeduct;
        exception when others then
          v_amtdeduct := 0;
        end;
      else
        begin
          select decode(v_type,'1',stddec(amtdeduct,codempid,global_v_chken),stddec(amtspded,codempid,global_v_chken))
          into v_amtdeduct
          from tempded
          where codempid  = v_empid
            and coddeduct = v_codeduct;
        exception when others then
          v_amtdeduct := 0;
        end;
      end if;
    end if;  --end if  v_amtdeduct = 0
    if v_amtdeduct > 0 then
      begin
        select amtdemax, pctdemax, formula
        into   v_amtdemax, v_pctdemax, v_formula
        from   tdeductd
        where  dteyreff = (select max(dteyreff)
                             from tdeductd
                            where dteyreff <= p_dteyrepay - global_v_zyear
                              and coddeduct = v_codeduct
                              and codcompy = index_codcompy) 
          and coddeduct = v_codeduct
          and codcompy  = index_codcompy; 
      exception when others then
        v_amtdemax := null;
        v_pctdemax := null;
        v_formula := null;
      end;

      ------ Check amt max
      if (v_amtdemax > 0) then
        if v_codeduct = 'E001' then ---- Case : Provident fund
          if v_amtdeduct < 10000 then
            v_amtdeduct := 0;
          else
            v_amtdeduct := v_amtdeduct - 10000;
            v_amtdeduct := least(v_amtdeduct,v_amtdemax);
          end if;
        elsif v_codeduct = 'D001' then
          v_amtdeduct := least(v_amtdeduct,10000);
        else
          v_amtdeduct := least(v_amtdeduct,v_amtdemax);
        end if;
      end if;
      ------ Check amt %
      if v_pctdemax > 0 then
        v_pctamt := p_amtsalyr * (v_pctdemax / 100);
        v_amtdeduct := least(v_amtdeduct,v_pctamt);
      end if;

      ------ Check formula ------
      if v_formula is not null then
        if instr(v_formula,'[') > 1 then
          loop --- Loop Find Amount -> In case : formula from seq.
            v_check  := substr(v_formula,instr(v_formula,'[') +1,(instr(v_formula,']') -1) - instr(v_formula,'['));
            exit when v_check is null;
            --
            begin
              if get_deduct(v_check) = 'E' then
                p_evalue_code(substr(v_check,2))  := p_evalue_code(substr(v_check,2));
              elsif get_deduct(v_check) = 'D' then
                p_dvalue_code(substr(v_check,2))  := p_dvalue_code(substr(v_check,2));
              else
                p_ovalue_code(substr(v_check,2))  := p_ovalue_code(substr(v_check,2));
              end if;
            exception when no_data_found then
              if get_deduct(v_check) = 'E' then
                p_evalue_code(substr(v_check,2))  := null;
              elsif get_deduct(v_check) = 'D' then
                p_dvalue_code(substr(v_check,2))  := null;
              else
                p_ovalue_code(substr(v_check,2))  := null;
              end if;
            end;
            --            
            if get_deduct(v_check) = 'E' then 
              v_formula := replace(v_formula,'{['||v_check||']}',nvl(p_evalue_code(substr(v_check,2)),0));
            elsif get_deduct(v_check) = 'D' then
              v_formula := replace(v_formula,'{['||v_check||']}',nvl(p_dvalue_code(substr(v_check,2)),0));
            else
              v_formula := replace(v_formula,'{['||v_check||']}',nvl(p_ovalue_code(substr(v_check,2)),0));
            end if;
          end loop;

          v_amtdeduct := least(v_amtdeduct,execute_sql('select '||v_formula||' from dual'));

        end if;
      end if;
    end if;
    v_typeded := get_deduct(v_codeduct);
    if v_type = '1' then
        if v_typeded = 'E' then
          p_evalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
        elsif v_typeded = 'D' then
          p_dvalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
        else
          p_ovalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
        end if;
    else --v_type = '2'
        if v_typeded = 'E' then
          p_evalue_code(substr(v_codeduct,2)) := nvl(p_evalue_code(substr(v_codeduct,2)),0) + nvl(v_amtdeduct,0);
        elsif v_typeded = 'D' then
          p_dvalue_code(substr(v_codeduct,2)) := nvl(p_dvalue_code(substr(v_codeduct,2)),0) + nvl(v_amtdeduct,0);
        else
          p_ovalue_code(substr(v_codeduct,2)) := nvl(p_ovalue_code(substr(v_codeduct,2)),0) + nvl(v_amtdeduct,0);
        end if;
    end if;
    return 	nvl(v_amtdeduct,0);
  end;

  procedure exec_data
    (p_stmt		in varchar2,
     p_max		in number) IS
    v_cursor    number;
    v_stmt  		varchar2(4000);
    v_dummy     integer;
    v_desc			varchar2(4000);
  begin
    v_stmt   := p_stmt;

    v_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.V7);
    for i in 1..p_max loop
      dbms_sql.define_column(v_cursor,i,v_desc,1000);
    end loop;
    v_dummy := dbms_sql.execute(v_cursor);
    loop
      if dbms_sql.fetch_rows(v_cursor) = 0 then
        exit;
      end if;
      for i in 1..p_max loop
        dbms_sql.column_value(v_cursor,i,v_desc);
        p_var_item(i) := v_desc;
      end loop;
    end loop;
    dbms_sql.close_cursor(v_cursor);
  end exec_data;

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(obj_detail,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_dteyrepay         := to_number(hcm_util.get_string_t(obj_detail,'p_dteyrepay'));
    p_typpayroll        := hcm_util.get_string_t(obj_detail,'p_typpayroll');
    p_codempid_query    := hcm_util.get_string_t(obj_detail,'p_codempid_query');
    p_codcomp           := hcm_util.get_string_t(obj_detail,'p_codcomp');    
    b_index_delimiter   := hcm_util.get_string_t(obj_detail,'p_delimiter');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
    v_flgsecu		boolean				       := false;
    v_numlvl		temploy1.numlvl%type := null;
    v_staemp		temploy1.staemp%type := null;
    v_count     number := 0;
  begin
    if p_codempid_query is not null then
      begin
        select codcomp,numlvl,staemp
        into 	 p_codcomp,v_numlvl,v_staemp
        from   temploy1
        where  codempid = p_codempid_query;
        if v_staemp = '0' then
          param_msg_error := get_error_msg_php('HR2102',global_v_lang);
          return;
        end if;
        v_flgsecu := secur_main.secur1(p_codcomp,v_numlvl,global_v_coduser,global_v_numlvlsalst,
                                       global_v_numlvlsalen,v_zupdsal);
        if not v_flgsecu then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
    end if;
    --
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    --
    if p_typpayroll is not null then
      begin
        select codcodec into p_typpayroll
        from 	 tcodtypy
        where  codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODTYPY');
        return;
      end;
    end if;
    --
    begin
      select count(*) into v_count
        from ttaxmedia
       where dteyrepay = p_dteyrepay;
    exception when others then
      v_count := 0;
    end;
    --
    if v_count < 1 then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TTAXMEDIA');
      return;
    end if;
  end check_index;

  procedure get_process_batch(json_str_input in clob, json_str_output out clob) as
    obj_rows        json_object_t := json_object_t();
    v_exist					boolean := false;
    v_secur					boolean := false;
    v_runseq				varchar2(4000 char) := to_char(sysdate,'HH24MISS');
    v_log_name      varchar2(4000 char) := null;
    v_path_log      varchar2(4000 char) := null;
    v_message       varchar2(4000 char) := null;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data_batch(v_exist,v_secur,v_runseq);
      --
      if not v_exist then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTAXMAS');
      elsif not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      else
        v_message  := 'HR2715'||'-'||get_errorm_name('HR2715',global_v_lang);
        v_path_log := get_tsetup_value('PATHEXCEL')||global_v_batch_filename;
      end if;
    end if;
    --
    if param_msg_error is null then
      obj_rows.put('coderror','200');
      obj_rows.put('response',v_message);
      --
      if v_path_log is not null then
        obj_rows.put('message',v_path_log);
        obj_rows.put('sumrec',p_sumrec);

        -- set complete batch process
        global_v_batch_flgproc  := 'Y';
        global_v_batch_pathfile := v_path_log;
        global_v_batch_qtyproc  := p_sumrec;
      end if;
    else
      obj_rows.put('coderror','400');
      obj_rows.put('response',hcm_secur.get_response('400',param_msg_error,global_v_lang));
    end if;
    json_str_output := obj_rows.to_clob;
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
  end get_process_batch;

  procedure gen_data_batch(p_exist	out boolean, p_secur	out boolean, p_runseq in varchar) is
    v_flgsecu		  boolean := false;
    v_filename	  varchar2(255);
    out_file   	  UTL_FILE.File_Type;
    data_file 	  long;--User37 Final Test Phase 1 V11 #2931 03/12/2020 varchar2(4000);
    v_codtable  	ttaxmedia.codtable%type;
    v_codcolmn2	  ttaxmedia.codcolmn2%type;
    v_select		  varchar2(4000);
    v_where			  varchar2(4000);
    v_funcdesc	  varchar2(4000);
    v_from			  varchar2(4000);
    v_join			  varchar2(4000);
    v_concat		  varchar2(1);
    v_cursor      number := 0;
    v_stmt  		  varchar2(4000);
    v_dummy       integer;
    v_max				  number := 0;
    v_codempid	  temploy1.codempid%type;
    v_codcomp		  temploy1.codcomp%type;
    v_numlvl		  varchar2(2);
    v_stamarry	  temploy1.stamarry%type;
    v_dteeffex	  date;
    v_typtax		  temploy3.typtax%type;
    v_flgtax		  temploy3.flgtax%type;
    v_amtsalyr	  number := 0;
    v_amtproyr	  number := 0;
    v_amtsocyr	  number := 0;
    v_desc			  varchar2(4000);
    v_amt				  number := 0;
    v_sumded		  number := 0;
    v_num				  number := 0;
    v_numemp		  number := 0;
    v_length		  number := 0;
    v_seqsalyr	  number := 0;
    v_seqtax		  number := 0;
    v_seqdeduct	  number := 0;
    v_amtcalet	  number := 0;
    v_amtcalct	  number := 0;
    v_amtgrstxt	  number := 0;
    v_amtinc		  number := 0;
    v_amtnet		  number := 0;
    v_amttax		  number := 0;
    v_sumtax		  number := 0;
    v_tax				  number := 0;
    v_zupdsal		  varchar2(1);
    v_com				  varchar2(1);
    v_rund006     number := 0;
    v_rund007     number := 0;
    v_rund008     number := 0;
    v_rund010     number := 0;
    v_runn			  number := 0;
    v_runs			  number := 0;
    v_runnt			  number := 0;
    v_runst			  number := 0;
    v_dteyrepay   number := 0;
    v_dtemthpay   number := 0;
    v_numperiod   number := 0;
    v_codcompy	  varchar2(4);
    v_typpayroll	varchar2(4);
    v_ttaxmedia_exist boolean := false;
    v_found_item  varchar2(10) := 'N';
    --<<User37 Final Test Phase 1 V11 #2931 10/11/2020
    v_namspous    varchar2(200);
    v_namfirst    varchar2(200);
    v_namlast     varchar2(200);
    -->>User37 Final Test Phase 1 V11 #2931 10/11/2020
    --
    v_formula     varchar2(500);

    type v_arr is table of varchar2(150) index by binary_integer;
      v_numoffidn  		v_arr;
      v_numseqn    		v_arr;
      v_numoffidy  		v_arr;
      v_numseqy    		v_arr;

    cursor c_tchildrnsd is
      select numseq,numoffid
        from tchildrn
       where codempid   = v_codempid
         and flgedlv    = 'Y'
         and flgdeduct  = 'Y'
      order by numseq;

    cursor c_tchildrnns is
      select numseq,numoffid
        from tchildrn
       where codempid   = v_codempid
         and flgedlv    = 'N'
         and flgdeduct = 'Y'
      order by numseq;

    cursor c_ttaxmedia  is
      select seqno,numseq,codtable,coddeduct,funcdesc,codcolmn,
             codcolmn2,descol,fldtype,fldlength,fldscale
        from ttaxmedia
       where dteyrepay = p_dteyrepay
      order by seqno; ----numseq;

    cursor c_tdtepay is
      select dteyrepay,dtemthpay,numperiod
        from tdtepay
       where codcompy   = v_codcompy
         and typpayroll = v_typpayroll
         and dteyrepay  = p_dteyrepay - global_v_zyear
         and flgcal     = 'Y'
      order by dtemthpay asc,numperiod asc;
  begin
    p_exist	    := false;
    p_secur     := false;
    begin
      select count(*) into v_max
        from ttaxmedia
       where dteyrepay = p_dteyrepay;
    exception when no_data_found then
      v_max := 0;
    end;
    --
    v_where := ' where temploy1.codempid = nvl('''||p_codempid_query||''',temploy1.codempid)'||
               ' and temploy1.codcomp like '''||p_codcomp||'%'''||
               ' and temploy1.typpayroll = nvl('''||p_typpayroll||''',temploy1.typpayroll)'||
               ' and temploy1.staemp in (''1'',''3'',''9'')'||
               ' and temploy1.codempid = ttaxmas.codempid'||
               ' and ttaxmas.dteyrepay = '||(p_dteyrepay - global_v_zyear)||
               ' and TEMPLOY1.codempid = TEMPLOY3.codempid';
    v_from 	 := ' from TEMPLOY1 TEMPLOY1, TTAXMAS,TEMPLOY3 ';
    v_concat := null;
    v_select := 'select ';
    p_sumrec := 0;
    --
    for r_ttaxmedia in c_ttaxmedia loop
      v_ttaxmedia_exist := true;
      if r_ttaxmedia.codtable is not null and r_ttaxmedia.codtable <> 'TDEDUCTD' then
        if r_ttaxmedia.codtable = 'TSPOUSE' and r_ttaxmedia.codcolmn in ('CODTITLE','NAMFIRST','NAMLAST') then
          --<<User37 Final Test Phase 1 V11 #2931 10/11/2020
          if global_v_lang = '101' then
            v_namspous := 'namspe';
            v_namfirst := 'namfirste';
            v_namlast  := 'namlaste';
          elsif global_v_lang = '103' then
            v_namspous := 'namsp3';
            v_namfirst := 'namfirst3';
            v_namlast  := 'namlast3';
          elsif global_v_lang = '104' then
            v_namspous := 'namsp4';
            v_namfirst := 'namfirst4';
            v_namlast  := 'namlast5';
          elsif global_v_lang = '105' then
            v_namspous := 'namsp5';
            v_namfirst := 'namfirst5';
            v_namlast  := 'namlast5';
          else
            v_namspous := 'namspt';
            v_namfirst := 'namfirstt';
            v_namlast  := 'namlastt';
          end if;
          if r_ttaxmedia.codcolmn = 'CODTITLE' then
            v_funcdesc := 'nvl(get_tlistval_name(''CODTITLE'',tspouse.codtitle,''102''),get_tspouse(tspouse.'||v_namspous||',''CODTITLE'',''TITLE''))';
          elsif r_ttaxmedia.codcolmn = 'NAMFIRST' then
            v_funcdesc := 'nvl(tspouse.'||v_namfirst||',get_tspouse(tspouse.'||v_namspous||',null,''FIRST''))';
          elsif r_ttaxmedia.codcolmn = 'NAMLAST' then
            v_funcdesc := 'nvl(tspouse.'||v_namlast||',get_tspouse(tspouse.'||v_namspous||',null,''LAST''))';
          end if;
          /*if r_ttaxmedia.codcolmn = 'CODTITLE' then
            v_funcdesc := 'nvl(get_tlistval_name(''CODTITLE'',tspouse.codtitle,''102''),get_tspouse(tspouse.namspous,''CODTITLE'',''TITLE''))';
          elsif r_ttaxmedia.codcolmn = 'NAMFIRST' then
            v_funcdesc := 'nvl(tspouse.namfirst,get_tspouse(tspouse.namspous,null,''FIRST''))';
          elsif r_ttaxmedia.codcolmn = 'NAMLAST' then
            v_funcdesc := 'nvl(tspouse.namlast,get_tspouse(tspouse.namspous,null,''LAST''))';
          end if;*/
          -->>User37 Final Test Phase 1 V11 #2931 10/11/2020
        elsif r_ttaxmedia.funcdesc is not null and instr(r_ttaxmedia.funcdesc,'ITEM') = 0 then
          v_codtable  := r_ttaxmedia.codtable;
          v_codcolmn2 := r_ttaxmedia.codcolmn2;
          if r_ttaxmedia.codtable = 'TLASTDED' and p_dteyrepay = to_char(sysdate,'yyyy') then
            if r_ttaxmedia.codcolmn in ('AMTTAXREL','AMTRELAS') then
                v_codtable := 'TEMPLOY3';
            else
                v_codtable := 'TEMPLOY1';
            end if;
            v_codcolmn2 := replace(v_codcolmn2,'TLASTDED','TEMPLOY3');
          end if;
          v_funcdesc := r_ttaxmedia.funcdesc;
          v_funcdesc := replace(v_funcdesc,'P_CODE2',v_codcolmn2);
          v_funcdesc := replace(v_funcdesc,'P_CODE',v_codtable||'.'||r_ttaxmedia.codcolmn);
          v_funcdesc := replace(v_funcdesc,'P_CRYPT',''''||global_v_chken||'''');
        else
          if r_ttaxmedia.codtable <> 'TCHILDRN' then
            v_funcdesc := r_ttaxmedia.codtable||'.'||r_ttaxmedia.codcolmn;
          end if;
        end if;

        v_select := v_select||v_concat||v_funcdesc;
        if instr(v_from,r_ttaxmedia.codtable) = 0 then
          v_from := v_from||','||r_ttaxmedia.codtable||' '||r_ttaxmedia.codtable;
          v_join := v_join||' and temploy1.codempid = '||r_ttaxmedia.codtable||'.codempid(+) ';
        end if;

      else
        v_select := v_select||v_concat||'null';
      end if;

      v_concat := ',';
      p_var_numseq(r_ttaxmedia.seqno) 		:= r_ttaxmedia.numseq;
      p_var_fldtype(r_ttaxmedia.seqno) 	  := r_ttaxmedia.fldtype;
      p_var_fldlength(r_ttaxmedia.seqno)  := r_ttaxmedia.fldlength;
      p_var_fldscale(r_ttaxmedia.seqno) 	:= r_ttaxmedia.fldscale;
      if r_ttaxmedia.codcolmn = 'AMTSALYR' then
        v_seqsalyr := r_ttaxmedia.seqno;
      elsif r_ttaxmedia.codcolmn = 'CALTAX' then
        v_seqtax := r_ttaxmedia.seqno;
      elsif r_ttaxmedia.codcolmn = 'AMTDEDUCT' then
        v_seqdeduct := r_ttaxmedia.seqno;
      end if;
    end loop;

    if not v_ttaxmedia_exist then
        param_msg_error := get_error_msg_php('AL0017',global_v_lang);
        return;
    end if;

    --
    if UTL_FILE.Is_Open(out_file) then
      UTL_FILE.Fclose(out_file);
    end if;
    --
    v_filename := hcm_batchtask.gen_filename(lower(global_v_form||'_'||global_v_coduser)||'_'||p_runseq,'txt',global_v_batch_dtestrt);
    global_v_batch_filename := v_filename;
    std_deltemp.upd_ttempfile(v_filename,'A');	--'A' = Insert , update ,'D'  = delete
    out_file 	:=	UTL_FILE.Fopen(p_file_dir,v_filename,'w',32767);
    p_sumrec := 0;
    --
    v_stmt   := 'select temploy1.codempid,temploy1.codcomp,temploy1.numlvl,temploy1.stamarry '||
            v_from||v_where||v_join||
            ' group by temploy1.codcomp,temploy1.codempid,temploy1.numlvl,temploy1.stamarry'||
            ' order by temploy1.codcomp,temploy1.codempid,temploy1.numlvl,temploy1.stamarry';
		--
    v_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.V7);
    dbms_sql.define_column(v_cursor,1,v_codempid,8);
    dbms_sql.define_column(v_cursor,2,v_codcomp,21);
    dbms_sql.define_column(v_cursor,3,v_numlvl,2);
    dbms_sql.define_column(v_cursor,4,v_stamarry,1);
    v_dummy := dbms_sql.execute(v_cursor);
    v_numemp := 0;
    --
    v_com			:= null;
    data_file := null;

    --
    for r_ttaxmedia in c_ttaxmedia loop
      if data_file is not null then
        v_com := b_index_delimiter;
      end if;
      data_file := data_file||v_com||r_ttaxmedia.descol;
    end loop;
    --
--    data_file := convert(data_file,'TH8TISASCII');
    UTL_FILE.Put_line(out_file,data_file);
    --
    loop
      if dbms_sql.fetch_rows(v_cursor) = 0 then
        exit;
      end if;
      dbms_sql.column_value(v_cursor,1,v_codempid);
      dbms_sql.column_value(v_cursor,2,v_codcomp);
      dbms_sql.column_value(v_cursor,3,v_numlvl);
      dbms_sql.column_value(v_cursor,4,v_stamarry);
      --
      begin
        select codempid into v_codempid
        from	 tlstrevn
        where	 dteyear = (p_dteyrepay - global_v_zyear)
        and		 codempid = v_codempid;
        goto loop_next;
      exception when no_data_found then
        null;
      end;
      --
      begin
        select dteeffex,hcm_util.get_codcomp_level(codcomp,'1'),typpayroll into v_dteeffex,v_codcompy,v_typpayroll
        from	 temploy1
        where	 codempid = v_codempid;
        if to_char(v_dteeffex,'yyyy') = p_dteyrepay then
          goto loop_next;
        end if;
      exception when no_data_found then
        goto loop_next;
      end;
      --
      p_exist := true;
      v_flgsecu := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgsecu then
        p_secur := true;
        index_codcompy := hcm_util.get_codcomp_level(v_codcomp,1); 
        for i in 1..v_max loop
          p_var_item(i) := null;
        end loop;
        v_numemp := v_numemp + 1;
        v_where := ' where temploy1.codempid = '''||v_codempid||''''||
                   ' and temploy1.codempid = ttaxmas.codempid'||
                   ' and temploy1.codempid = temploy3.codempid'||
                   ' and ttaxmas.dteyrepay = '||(p_dteyrepay - global_v_zyear);
        v_desc :=	v_select||v_from||v_where||v_join;
        exec_data(v_desc,v_max);
        --
        if p_dteyrepay < to_char(sysdate,'yyyy') then
          begin
            select typtax,flgtax,stamarry into v_typtax,v_flgtax,v_stamarry
            from	 tlastded
            where	 codempid	 = v_codempid
            and 	 dteyrepay = (p_dteyrepay - global_v_zyear);
          exception when no_data_found then
            v_typtax := '1'; v_flgtax := '1'; v_stamarry := 'O';
          end;
        else
          begin
            select typtax,flgtax into v_typtax,v_flgtax
            from	 temploy3
            where	 codempid	 = v_codempid;
          exception when no_data_found then
            v_typtax := '1'; v_flgtax := '1';
          end;
        end if;
        --
        begin
          select stddec(amtsalyr,codempid,global_v_chken),
                 stddec(amtproyr,codempid,global_v_chken),
                 stddec(amtsocyr,codempid,global_v_chken),
                 stddec(amtcalet,codempid,global_v_chken),
                 stddec(amtcalct,codempid,global_v_chken),
                 stddec(amttaxyr,codempid,global_v_chken)
          into 	 v_amtsalyr,v_amtproyr,v_amtsocyr,v_amtcalet,v_amtcalct,v_tax
          from	 ttaxmas
          where	 dteyrepay = p_dteyrepay - global_v_zyear
          and		 codempid	 = v_codempid;
        exception when no_data_found then
          v_amtsalyr := 0; v_amtproyr := 0;
        end;
        p_var_amtexp    := null;
        p_var_maxexp    := null;
        p_var_amtdiff   := null;
        -- Temploy1 Block --
        p_temp_codempid := v_codempid; --to temploy1
        p_temp_stamarry := v_stamarry; --to temploy1
        p_temp_typtax	  := v_typtax;   --to temploy1
        --
        p_var_item(v_seqsalyr) := v_amtsalyr;
        p_var_item(v_seqtax)	 := round(v_tax,2);
        --
        v_sumded  := 0;
        v_rund006 := 0;
        v_rund007 := 0;
        v_rund008 := 0;
        v_rund010 := 0;

        for i in 1..100 loop
          p_dvalue_code(i) := null;
          p_evalue_code(i) := null;
          p_ovalue_code(i) := null;
        end loop;

        for r_ttaxmedia in c_ttaxmedia loop
          if r_ttaxmedia.codtable = 'TDEDUCTD' then
            if r_ttaxmedia.coddeduct in ('E001','D001') then
              v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'1',v_amtproyr,v_amtsalyr);
            elsif r_ttaxmedia.coddeduct = 'D002' then
              v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'1',v_amtsocyr,v_amtsalyr);
            elsif r_ttaxmedia.coddeduct = 'D003' then
              if v_stamarry = 'M' and v_typtax = '2' then
                v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'2',0,v_amtsalyr);
              else
                v_amt := 0;
              end if;
              elsif r_ttaxmedia.coddeduct in ('D004','D005') then
              v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'1',0,v_amtsalyr);
              if v_stamarry = 'M' and v_typtax = '2' then
                v_amt := v_amt + gtempded(v_codempid,r_ttaxmedia.coddeduct,'2',0,v_amtsalyr);
              end if;
            elsif r_ttaxmedia.coddeduct in ('D006','D007','D008','D010') then
              if r_ttaxmedia.coddeduct = 'D006' then
                v_rund006 := v_rund006 + 1;
                if v_rund006 = 1 then
                  v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'1',0,v_amtsalyr);
                else
                  if v_stamarry = 'M' and v_typtax = '2' then
                    v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'2',0,v_amtsalyr);
                  else
                    v_amt := 0;
                  end if;
                end if;
              end if;
              if r_ttaxmedia.coddeduct = 'D007' then
                v_rund007 := v_rund007 + 1;
                if v_rund007 = 1 then
                  v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'1',0,v_amtsalyr);
                else
                  if v_stamarry = 'M' and v_typtax = '2' then
                    v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'2',0,v_amtsalyr);
                  else
                    v_amt := 0;
                  end if;
                end if;
              end if;
              if r_ttaxmedia.coddeduct = 'D008' then
                v_rund008 := v_rund008 + 1;
                if v_rund008 = 1 then
                  v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'1',0,v_amtsalyr);
--                  v_amt := v_amt + gtempded(v_codempid,'D009','1',0,v_amtsalyr);
                  v_amt := v_amt;
                else
                  if v_stamarry = 'M' and v_typtax = '2' then
                    v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'2',0,v_amtsalyr);
--                    v_amt := v_amt + gtempded(v_codempid,'D009','2',0,v_amtsalyr);
                    v_amt := v_amt;
                  else
                    v_amt := 0;
                  end if;
                end if;
              end if;
              if r_ttaxmedia.coddeduct = 'D010' then
                v_rund010 := v_rund010 + 1;
                if v_rund010 = 1 then
                  v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'1',0,v_amtsalyr);
                else
                  if v_stamarry = 'M' and v_typtax = '2' then
                    v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'2',0,v_amtsalyr);
                  else
                    v_amt := 0;
                  end if;
                end if;
              end if;
            else
              v_amt := gtempded(v_codempid,r_ttaxmedia.coddeduct,'1',0,v_amtsalyr);
            end if;
            p_var_item(r_ttaxmedia.seqno) := v_amt;
            v_sumded := v_sumded + nvl(v_amt,0);
          end if;
        end loop;
        --
        for r_tdtepay in c_tdtepay loop
          v_dteyrepay := r_tdtepay.dteyrepay;
          v_dtemthpay := r_tdtepay.dtemthpay;
          v_numperiod := r_tdtepay.numperiod;
        end loop;

--        begin
--          select dteyrepay,dtemthpay,numperiod into v_dteyrepay,v_dtemthpay,v_numperiod
--            from tdtepay
--           where codcompy   = v_codcompy
--             and typpayroll = v_typpayroll
--             and dteyrepay  = (p_dteyrepay - global_v_zyear)
--             and flgcal     = 'Y'
--             and rownum     = 1
--          order by dtemthpay desc,numperiod desc;
--        exception when no_data_found then
--          null;
--        end;
        --
       /* begin
          select stddec(amtfml,codempid,global_v_chken) into v_sumded
            from ttaxmasf
           where codempid  = v_codempid
             and dteyrepay = v_dteyrepay
             and dtemthpay = v_dtemthpay
             and numperiod = v_numperiod
             and numseq    = 6;
        exception when no_data_found then
          v_sumded := 0;
        end;*/

        p_var_item(v_seqdeduct)	:= round(v_sumded,2);
        --
        for i in 1..3 loop
          v_numoffidn(i) := null;
          v_numseqn(i)   := null;
          v_numoffidy(i) := null;
          v_numseqy(i)   := null;
        end loop;
        v_runn := 0;
        for i in c_tchildrnns loop
          v_runn := v_runn + 1;
          v_numoffidn(v_runn) := i.numoffid ;
          v_numseqn(v_runn)   := i.numseq ;
        end loop;

        v_runs := 0;
        for i in c_tchildrnsd loop
          v_runs := v_runs + 1;
          v_numoffidy(v_runs) := i.numoffid ;
          v_numseqy(v_runs)   := i.numseq ;
        end loop;
        v_runnt := 0;
        v_runst := 0;
        --
        for r_ttaxmedia in c_ttaxmedia loop
          if r_ttaxmedia.codtable = 'TCHILDRN' then
            if r_ttaxmedia.codcolmn2 in ('N1','N2','N3') then
              v_runnt := v_runnt + 1;
              p_var_item(r_ttaxmedia.seqno) := v_numoffidn(v_runnt);
            end if;

            if r_ttaxmedia.codcolmn2 in ('Y1','Y2','Y3') then
              v_runst := v_runst + 1;
              p_var_item(r_ttaxmedia.seqno) := v_numoffidy(v_runst);
            end if;
          end if;
        end loop;
        --
        for r_ttaxmedia in c_ttaxmedia loop
          if instr(r_ttaxmedia.funcdesc,'ITEM') > 0 then
            v_funcdesc := r_ttaxmedia.funcdesc;
            v_funcdesc := replace(v_funcdesc,'P_SUMDED',v_sumded);
            v_funcdesc := replace(v_funcdesc,'P_FLGTAX',v_flgtax);
            v_funcdesc := replace(v_funcdesc,'P_YEAR',(p_dteyrepay - global_v_zyear));
            loop
              v_num := substr(v_funcdesc,instr(v_funcdesc,'ITEM') + 4,2);
              v_found_item  := 'N';
              for i in 1..v_max loop
                if v_num = p_var_numseq(i) then
                  v_num := i;
                  v_found_item  := 'Y';
                  exit;
                end if;
              end loop;
              if v_found_item = 'Y' then
                v_funcdesc := replace(v_funcdesc,substr(v_funcdesc,instr(v_funcdesc,'ITEM'),6),p_var_item(v_num));
              end if;
              if instr(v_funcdesc,'ITEM') = 0 or v_found_item = 'N' then
                exit;
              end if;
            end loop;
            if v_found_item = 'Y' then
              if r_ttaxmedia.fldtype = 'CHAR' then
                p_var_item(r_ttaxmedia.seqno) := nvl(execute_desc('select '||v_funcdesc||' from dual'),p_var_item(r_ttaxmedia.seqno));
              else
                p_var_item(r_ttaxmedia.seqno) := execute_sql('select '||v_funcdesc||' from dual');
              end if;
            else
              p_var_item(r_ttaxmedia.seqno) := '';
            end if;
          elsif r_ttaxmedia.codtable is null and r_ttaxmedia.funcdesc is not null then
            v_funcdesc := r_ttaxmedia.funcdesc;
            v_funcdesc := replace(v_funcdesc,'P_NUMEMP',''''||to_char(v_numemp,'fm000000')||'''');
            v_funcdesc := replace(v_funcdesc,'P_FLGPOL','''0''');
            v_funcdesc := replace(v_funcdesc,'P_CODPOL','''000''');
            v_funcdesc := replace(v_funcdesc,'P_AMBULD',''''||to_char(0,'0000000000.00')||'''');
            if r_ttaxmedia.fldtype = 'CHAR' then
              p_var_item(r_ttaxmedia.seqno) := execute_desc('select '||v_funcdesc||' from dual');
            else
              p_var_item(r_ttaxmedia.seqno) := execute_sql('select '||v_funcdesc||' from dual');
            end if;
          end if;
        end loop;
        --
        data_file := null;
        v_com     := null;--User37 Final Test Phase 1 V11 #2931 03/12/2020
        for i in 1..v_max loop
          v_length := p_var_fldlength(i);
          if p_var_fldlength(i) > 0 then
            v_length := v_length + p_var_fldscale(i) + 1;
          end if;
          if p_var_fldtype(i) = 'CHAR' then
            v_desc := rpad(substr(nvl(p_var_item(i),' '),1,v_length),v_length,' ');
          elsif p_var_fldtype(i) = 'NUMBER' then
            if p_var_fldscale(i) > 0 then
              v_desc := lpad(to_char(p_var_item(i),'fm99999999999999990.00'),v_length,' ');
            else
              v_desc := lpad(to_char(p_var_item(i),'fm99999999999999990'),v_length,' ');
            end if;
          end if;

          if data_file is not null then
            v_com := b_index_delimiter;
          end if;
          data_file := data_file||v_com||v_desc;
        end loop; -- for i

        UTL_FILE.Put_line(out_file,data_file);
        p_sumrec := p_sumrec + 1;
      end if;
      <<loop_next>>
      null;
    end loop;
    utl_file.fflush(out_file);
    utl_file.Fclose(out_file);
    sync_log_file(v_filename);
  exception when others then
    UTL_FILE.Fclose(out_file);
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    param_msg_error := get_error_msg_php('AL0017',global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
  end gen_data_batch;
  --
  procedure exec_ttaxmd(json_str_input in clob, json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;
    v_dteyreff	       number := 0;
    v_codcomp         tcenter.codcomp%type;

    cursor c_ttaxmd is
      select numseq,descol,codtable,codcolmn,codcolmn2,funcdesc,fldtype,fldlength,fldscale
        from ttaxmd
        where not exists (select * from ttaxmedia
                                  where ttaxmedia.numseq    = ttaxmd.numseq
                                    and ttaxmedia.dteyrepay = p_dteyrepay)
      --<<User37 Final Test Phase 1 V11 #2931 03/12/2020
          and numseq <> 100
      union
      select numseq,descol,codtable,codcolmn,codcolmn2,funcdesc,fldtype,fldlength,fldscale
        from ttaxmd
        where numseq = 100
      -->>User37 Final Test Phase 1 V11 #2931 03/12/2020
      order by numseq;

    cursor c_tdeductd is
      select coddeduct
        from tdeductd
       where dteyreff   = v_dteyreff
         and codcompy   = hcm_util.get_codcomp_level(v_codcomp,1)--User37 Final Test Phase 1 V11 #2931 03/12/2020 hcm_util.get_codcomp_level(p_codcomp,1)
         and not exists (select * from ttaxmedia where ttaxmedia.coddeduct = tdeductd.coddeduct and ttaxmedia.dteyrepay = p_dteyrepay)
      order by decode(substr(coddeduct,1,1),'E',1,'D',2,'O',3,9), coddeduct;

  begin
    initial_value(json_str_input);
    obj_row         := json_object_t();

    --<<User37 Final Test Phase 1 V11 #2931 03/12/2020
    if p_codempid_query is not null then
        begin
            select codcomp
              into v_codcomp
              from temploy1
             where codempid = p_codempid_query;
        exception when no_data_found then
            v_codcomp := null;
        end;
    else
        v_codcomp := p_codcomp;
    end if;
    -->>User37 Final Test Phase 1 V11 #2931 03/12/2020

    begin
      select  dteyreff into v_dteyreff
      from	  tdeductd
      where	  dteyreff  = ( select  max(dteyreff)
                            from 	  tdeductd
                            where	  dteyreff  <= p_dteyrepay - global_v_zyear
                            and     codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)) --User37 Final Test Phase 1 V11 #2931 03/12/2020 hcm_util.get_codcomp_level(p_codcomp,1) )
      and     codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)--User37 Final Test Phase 1 V11 #2931 03/12/2020 hcm_util.get_codcomp_level(p_codcomp,1)
      and     rownum = 1;
    exception when no_data_found then
      v_dteyreff := null;
    end;
    --
    for r1 in c_ttaxmd loop
      if r1.codtable = 'TDEDUCTD' then

        for r2 in c_tdeductd loop

          obj_data           := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('numseq',r1.numseq);
          obj_data.put('descol',get_tcodeduct_name(r2.coddeduct,global_v_lang));
          obj_data.put('codtable',r1.codtable);
          obj_data.put('codcolmn', r1.codcolmn);
          obj_data.put('codcolmn2',r1.codcolmn2);
          obj_data.put('coddeduct',r2.coddeduct);
          obj_data.put('funcdesc',r1.funcdesc);
          obj_data.put('fldtype',r1.fldtype);
          obj_data.put('fldlength',r1.fldlength);
          obj_data.put('fldscale',r1.fldscale);

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt          := v_rcnt + 1;
        end loop;
      elsif r1.codtable = 'TCHILDRN' then
        for i in 1..3 loop
          obj_data           := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('numseq',r1.numseq);
          obj_data.put('descol',r1.descol||get_label_name('HRPY91B',global_v_lang,'')||' '||i||' '||
                                           get_label_name('HRPY91B',global_v_lang,''));
          obj_data.put('codtable',r1.codtable);
          obj_data.put('codcolmn', r1.codcolmn);
          obj_data.put('codcolmn2','N'||i);
          obj_data.put('funcdesc',r1.funcdesc);
          obj_data.put('fldtype',r1.fldtype);
          obj_data.put('fldlength',r1.fldlength);
          obj_data.put('fldscale',r1.fldscale);

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt          := v_rcnt + 1;
        end loop;
        --
        for i in 1..3 loop
          obj_data           := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('numseq',r1.numseq);
          obj_data.put('descol',r1.descol||get_label_name('HRPY91B',global_v_lang,'')||' '||i||' '||
                                           get_label_name('HRPY91B',global_v_lang,''));
          obj_data.put('codtable',r1.codtable);
          obj_data.put('codcolmn', r1.codcolmn);
          obj_data.put('codcolmn2','Y'||i);
          obj_data.put('funcdesc',r1.funcdesc);
          obj_data.put('fldtype',r1.fldtype);
          obj_data.put('fldlength',r1.fldlength);
          obj_data.put('fldscale',r1.fldscale);

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt          := v_rcnt + 1;
        end loop;
      else
        obj_data           := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq',r1.numseq);
        obj_data.put('descol',r1.descol);
        obj_data.put('codtable',r1.codtable);
        obj_data.put('codcolmn', r1.codcolmn);
        obj_data.put('codcolmn2',r1.codcolmn2);
        obj_data.put('funcdesc',r1.funcdesc);
        obj_data.put('fldtype',r1.fldtype);
        obj_data.put('fldlength',r1.fldlength);
        obj_data.put('fldscale',r1.fldscale);

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt          := v_rcnt + 1;
      end if;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end exec_ttaxmd;

  procedure exec_ttaxmedia(json_str_input in clob, json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;
    v_dteyrepay	       number;
    v_data             varchar2(1) := 'N';

    cursor c_ttaxmedia is
      select seqno,numseq,descol,codtable,codcolmn,
             codcolmn2,coddeduct,funcdesc,fldtype,fldlength,fldscale
        from ttaxmedia
       where dteyrepay = v_dteyrepay
        order by seqno;

  begin
    initial_value(json_str_input);
    obj_row         := json_object_t();
    begin
      select dteyrepay into v_dteyrepay
      from	 ttaxmedia
      where	 dteyrepay = (select max(dteyrepay)
                            from ttaxmedia
                           where dteyrepay <= p_dteyrepay - global_v_zyear)
      and rownum = 1;
    exception when no_data_found then
      v_dteyrepay := null;
    end;
    --
    for r1 in c_ttaxmedia loop
      obj_data           := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numseq',r1.numseq);
      obj_data.put('descol',r1.descol);
      obj_data.put('codtable',r1.codtable);
      obj_data.put('codcolmn',r1.codcolmn);
      obj_data.put('codcolmn2',r1.codcolmn2);
      obj_data.put('coddeduct',r1.coddeduct);
      obj_data.put('funcdesc',r1.funcdesc);
      obj_data.put('fldtype',r1.fldtype);
      obj_data.put('fldlength',r1.fldlength);
      obj_data.put('fldscale',r1.fldscale);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt          := v_rcnt + 1;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end exec_ttaxmedia;

  procedure save_ttaxmedia(json_str_input in clob, json_str_output out clob) is
    param_json        json_object_t;
    param_json_row    json_object_t;
    v_seqno           number;
    v_numseq          number;
    v_descol          varchar2(4000 char);
    v_codtable        varchar2(4000 char);
    v_codcolmn        varchar2(4000 char);
    v_codcolmn2       varchar2(4000 char);
    v_coddeduct       varchar2(4000 char);
    v_funcdesc        varchar2(4000 char);
    v_fldtype         varchar2(4000 char);
    v_fldlength       varchar2(4000 char);
    v_fldscale        varchar2(4000 char);
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    if param_msg_error is null then
      begin
        delete from ttaxmedia where dteyrepay = p_dteyrepay;
      end;
      --
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_seqno         := i + 1;
        v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
        v_descol        := hcm_util.get_string_t(param_json_row,'descol');
        v_codtable      := hcm_util.get_string_t(param_json_row,'codtable');
        v_codcolmn      := hcm_util.get_string_t(param_json_row,'codcolmn');
        v_codcolmn2     := hcm_util.get_string_t(param_json_row,'codcolmn2');
        v_coddeduct     := hcm_util.get_string_t(param_json_row,'coddeduct');
        v_funcdesc      := hcm_util.get_string_t(param_json_row,'funcdesc');
        v_fldtype       := hcm_util.get_string_t(param_json_row,'fldtype');
        v_fldlength     := hcm_util.get_string_t(param_json_row,'fldlength');
        v_fldscale      := hcm_util.get_string_t(param_json_row,'fldscale');
--        check_save;
        if param_msg_error is null then
          begin
            insert into ttaxmedia
                        (dteyrepay,seqno,numseq,descol,codtable,codcolmn,codcolmn2,coddeduct,
                         funcdesc,fldtype,fldlength,fldscale,codcreate,coduser)
                 values (p_dteyrepay,v_seqno,v_numseq,v_descol,v_codtable,v_codcolmn,v_codcolmn2,v_coddeduct,
                         v_funcdesc,v_fldtype,v_fldlength,v_fldscale,global_v_coduser,global_v_coduser);
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end;
        end if;
      end loop;
      --
      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end save_ttaxmedia;

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

end hrpy91b;

/

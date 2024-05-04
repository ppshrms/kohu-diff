--------------------------------------------------------
--  DDL for Package Body HRES82X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES82X" AS

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

--    block b_index
    b_dteyrepay    := hcm_util.get_string_t(json_obj,'p_dteyrepay');
    b_dtemthpay    := hcm_util.get_string_t(json_obj,'p_dtemthpay');
    b_numperiod    := hcm_util.get_string_t(json_obj,'p_numperiod');
--
    p_amtincom      := hcm_util.get_string_t(json_obj,'p_amtincom');
    p_amtsalyr      := hcm_util.get_string_t(json_obj,'p_amtsalyr');
    p_amtproyr      := hcm_util.get_string_t(json_obj,'p_amtproyr');
    p_amtsocyr      := hcm_util.get_string_t(json_obj,'p_amtsocyr');
    p_amtnet        := hcm_util.get_string_t(json_obj,'p_amtnet');

  end initial_value;
  --
  procedure check_index is
    v_codempid      temploy1.codempid%type;
    v_codcomp	 	    tcenter.codcomp%type;
    v_typpayroll    varchar(10 char);
    v_dtewatch	    date;
    v_dtepaymt	    date;
    v_timwatch	    varchar2(4 char);
  begin

    -- check dtewatch
   begin
      select 	codcomp,typpayroll into	v_codcomp,v_typpayroll
      from		ttaxcur
      where		codempid	  	= global_v_codempid
      and		 	dteyrepay 		= b_dteyrepay
      and		 	dtemthpay 		= b_dtemthpay
      and			numperiod			=	b_numperiod;
    exception when no_data_found then
      v_codcomp			:= null;
      v_typpayroll	:= null;
    end;
    --
    begin
      select 	dtepaymt,dtewatch,timwatch into v_dtepaymt,v_dtewatch,v_timwatch
        from (select 	dtepaymt,dtewatch,timwatch
              from 	tdtepay
              where codcompy = hcm_util.get_codcomp_level(v_codcomp,'1')
              and typpayroll = v_typpayroll
              and numperiod = b_numperiod
              and dtemthpay = b_dtemthpay
              and dteyrepay = b_dteyrepay
              union
              select 	dtepaymt,dtewatch,timwatch
              from 	tdtepay2
              where codcompy = hcm_util.get_codcomp_level(v_codcomp,'1')
              and typpayroll = v_typpayroll
              and numperiod = b_numperiod
              and dtemthpay = b_dtemthpay
              and dteyrepay = b_dteyrepay)
        where rownum = 1;
      /*select dtepaymt,dtewatch,timwatch into v_dtepaymt,v_dtewatch,v_timwatch
        from tdtepay
       where codcompy   = hcm_util.get_codcomp_level(v_codcomp,'1')
         and typpayroll = v_typpayroll
         and numperiod  = b_numperiod
         and dtemthpay  = b_dtemthpay
         and dteyrepay  = b_dteyrepay;*/
    exception when no_data_found then
      v_dtewatch := null;
      v_timwatch := null;
    end ;

    if v_dtewatch is null then
      v_dtewatch := v_dtepaymt;
    else
      v_dtewatch := to_date(to_char(v_dtewatch,'dd/mm/yyyy')||nvl(v_timwatch,'0000'),'dd/mm/yyyyhh24mi');
    end if;

    if v_dtewatch is not null then
      if sysdate < v_dtewatch then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxmas');
        return;
      end if;
    end if;
    --
    begin
      select codempid into v_codempid
        from ttaxcur
       where codempid  = global_v_codempid
         and dteyrepay = to_number(b_dteyrepay)
         and dtemthpay = to_number(b_dtemthpay)
         and numperiod = to_number(b_numperiod);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxmas');
      return;
    end;
  end;
--
----  -- Code Tab1 Detail Start
  procedure gen_tab1_detail(json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    v_codpos      temploy1.codpos%type;
    v_codcomp     temploy1.codcomp%type;
    v_stamarry    temploy1.stamarry%type;
    v_flgtax      temploy3.flgtax%type;
    v_typtax      temploy3.typtax%type;
    v_numtaxid    temploy3.numtaxid%type;
    v_amtcalet		number;
    v_amtcalct		number;
    v_amtgrstxt		number;
    v_amt					number;
    b_dteempmt		number;
    b_dteeffex		number;
    b_amtincct    number;
    b_amtsalyr    number;
    b_amtexpct    number;
    b_amtcalt     number;
    b_amttax      number;

    b_amtproyr    number;
    b_amtsocyr    number;

    b_amtincbf    number;
    b_amtincsp    number;
    b_amttaxbf    number;
    b_amttaxsp    number;
    b_amtsaid     number;
    b_amtsasp     number;
    b_amtpf       number;
    b_amtpfsp     number;

    cursor c_ttaxmasf is
      select codempid,numseq,desproce,desproct,desproc3,desproc4,desproc5,amtfml
      from	 ttaxmasf
      where	 codempid  = global_v_codempid
      and		 dteyrepay = (b_dteyrepay)
      and 	 dtemthpay = b_dtemthpay
      and 	 numperiod = b_numperiod
      order by numseq;

    cursor c1 is
       select get_temploy_name(global_v_codempid,global_v_lang) item5,
              get_tpostn_name(codpos,global_v_lang) item6,
              get_tcenter_name(codcomp,global_v_lang) item7,
              dteempmt item8,
              dteeffex item9
       from   temploy1
       where
            codempid  = global_v_codempid;

  begin
    initial_value(json_str_input);
    obj_data := json_object_t();
--
    check_index;
    if param_msg_error is not null then
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    begin
      select  codpos, codcomp, stamarry
      into  v_codpos, v_codcomp, v_stamarry
      from temploy1
      where codempid = global_v_codempid;
    exception when no_data_found then
      v_codpos := null;
      v_codcomp := null;
      v_stamarry := null;
      b_dteempmt := null;
      b_dteeffex := null;
    end;

    begin
      select flgtax, typtax, numtaxid
        into v_flgtax, v_typtax, v_numtaxid
        from temploy3
       where codempid = global_v_codempid;
    exception when no_data_found then
      v_flgtax := null;
      v_typtax := null;
    end;

    begin
      select nvl(stddec(amtcalt,codempid,v_chken),0) +
             nvl(stddec(amtinclt,codempid,v_chken),0) +
             nvl(stddec(amtincct,codempid,v_chken),0) -
             nvl(stddec(amtexplt,codempid,v_chken),0) -
             nvl(stddec(amtexpct,codempid,v_chken),0),
             /*nvl(stddec(amtsalyr,codempid,v_chken),0),*/
             nvl(stddec(amttaxt,codempid,v_chken),0),
--             nvl(stddec(amttaxyr,codempid,v_chken),0),
             nvl(stddec(amtproyr,codempid,v_chken),0),
             nvl(stddec(amtsocyr,codempid,v_chken),0),
             nvl(stddec(amtcalet,codempid,v_chken),0),
             nvl(stddec(amtcalct,codempid,v_chken),0),
             nvl(stddec(amtgrstxt,codempid,v_chken),0)
      into b_amtincct, /*b_amtsalyr,*/
           b_amtexpct, /*b_amtcalt,*/
           b_amtproyr, b_amtsocyr,
           v_amtcalet,v_amtcalct,v_amtgrstxt
      from ttaxmas
     where codempid = global_v_codempid
       and dteyrepay = (b_dteyrepay);
    exception when no_data_found then
      b_amtincct := 0;
--      b_amtsalyr := 0;
      b_amtexpct := 0;
--      b_amtcalt  := 0;
      b_amtproyr := 0;
      b_amtsocyr := 0;
      v_amtcalet := 0;
      v_amtcalct := 0;
      v_amtgrstxt := 0;
    end;

  -- Worapong / tjs3 30/5/2013 SMTM560099
    select sum(nvl(stddec(amtcal,codempid,v_chken),0)) +
         sum(nvl(stddec(amtincl,codempid,v_chken),0)) +
         sum(nvl(stddec(amtincc,codempid,v_chken),0)) -
         sum(nvl(stddec(amtexpl,codempid,v_chken),0)) -
         sum(nvl(stddec(amtexpc,codempid,v_chken),0)),
         sum(nvl(stddec(amttax,codempid,v_chken),0))
    into b_amtincct,b_amtexpct
    from ttaxcur
    where codempid = global_v_codempid
    and dteyrepay = (b_dteyrepay)
    and ((dtemthpay = b_dtemthpay	and numperiod <= b_numperiod)
    or dtemthpay < b_dtemthpay);
  -- end Worapong / tjs3 30/5/2013 SMTM560099
    begin
      select nvl(sum(nvl(stddec(a.amttax,codempid,v_chken),0)),0),
             nvl(sum(nvl(stddec(a.amtsalyr,codempid,v_chken),0)),0),
             nvl(sum(nvl(stddec(a.amttaxyr,codempid,v_chken),0)),0)
      into b_amttax, b_amtsalyr, b_amtcalt
      from ttaxcur a
      where a.codempid = global_v_codempid
        and a.dteyrepay = (b_dteyrepay)
        and a.dtemthpay = b_dtemthpay
        and a.numperiod = b_numperiod;
  --      and a.dtemthpay in (select max(b.dtemthpay)
  --                          from ttaxcur b
  --                          where b.codempid = global_v_codempid
  --                            and b.dteyrepay = (:b_index.dteyrepay - :global.v_zyear));
    exception when no_data_found then
      b_amttax := 0;
      b_amtsalyr := 0;
      b_amtcalt := 0;
    end;

    begin
      select nvl(stddec(amtincbf,codempid,v_chken),0),
             nvl(stddec(amtincsp,codempid,v_chken),0),
             nvl(stddec(amttaxbf,codempid,v_chken),0),
             nvl(stddec(amttaxsp,codempid,v_chken),0),
             nvl(stddec(amtsaid,codempid,v_chken),0),
             nvl(stddec(amtsasp,codempid,v_chken),0),
             nvl(stddec(amtpf,codempid,v_chken),0),
             nvl(stddec(amtpfsp,codempid,v_chken),0)
      into b_amtincbf, b_amtincsp,
           b_amttaxbf, b_amttaxsp,
           b_amtsaid, b_amtsasp,
           b_amtpf, b_amtpfsp
      from ttaxmasl
      where codempid = global_v_codempid
        and dteyrepay = (b_dteyrepay)
        and dtemthpay = b_dtemthpay
        and numperiod = b_numperiod;
    exception when no_data_found then
      b_amtincbf := 0;
      b_amtincsp := 0;
      b_amttaxbf := 0;
      b_amttaxsp := 0;
      b_amtsaid  := 0;
      b_amtsasp  := 0;
      b_amtpf		 := 0;
      b_amtpfsp  := 0;
    end;
      obj_data := json_object_t();
      for r1 in c1 loop
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('codempid_desc', r1.item5);
        obj_data.put('codpos_desc', r1.item6);
        obj_data.put('codcomp_desc', r1.item7);
        obj_data.put('dteempmt', to_char(r1.item8,'dd/mm/yyyy'));
        obj_data.put('dteeffex', to_char(r1.item9,'dd/mm/yyyy'));
        obj_data.put('ti_numtaxid', to_char(v_numtaxid));
        obj_data.put('flgtax_desc', get_tlistval_name('NAMTSTAT',v_flgtax,global_v_lang));
        obj_data.put('rect2072', get_tlistval_name('NAMTAXDD',v_typtax,global_v_lang));
        obj_data.put('stamarry_desc', get_tlistval_name('NAMMARRY',v_stamarry,global_v_lang));
        obj_data.put('amtincct', to_char(b_amtincct,'fm999,999,990.00'));
        obj_data.put('amtexpct', to_char(b_amtexpct,'fm999,999,990.00'));
        obj_data.put('amtsalyr', to_char(b_amtsalyr,'fm999,999,990.00'));
        obj_data.put('amtcalt', to_char(b_amtcalt,'fm999,999,990.00'));
        obj_data.put('amttax', to_char(b_amttax,'fm999,999,990.00'));
        obj_data.put('amtincbf', to_char(b_amtincbf,'fm999,999,990.00'));
        obj_data.put('amttaxbf', to_char(b_amttaxbf,'fm999,999,990.00'));
        obj_data.put('amtsaid', to_char(b_amtsaid,'fm999,999,990.00'));
        obj_data.put('amtpf', to_char(b_amtpf,'fm999,999,990.00'));
        obj_data.put('amtincsp', to_char(b_amtincsp,'fm999,999,990.00'));
        obj_data.put('amttaxsp', to_char(b_amttaxsp,'fm999,999,990.00'));
        obj_data.put('amtsasp', to_char(b_amtsasp,'fm999,999,990.00'));
        obj_data.put('amtpfsp', to_char(b_amtpfsp,'fm999,999,990.00'));
        obj_data.put('data_tem', to_char(b_amtsalyr||','||b_amtsalyr||','||b_amtproyr ||','||  b_amtsocyr||','||v_amt));
      end loop;
--      dbms_lob.createtemporary(json_str_output, true);
--      obj_data.to_clob(json_str_output);
      json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab1_detail;
--  -- Code Tab1 Detail End
--
  -- Code TAB2_TABLE
  procedure get_index_tab1_table1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
      if param_msg_error is null then
        gen_data_tab1_table1(json_str_output);
      else
        obj_row := json_object_t();
        obj_row.put('coderror','400');
        obj_row.put('desc_coderror',param_msg_error);
        json_str_output := obj_row.to_clob;
      end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_tab1_table1(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_total             number;
    v_rcnt              number := 0;
    v_numseq            number := 0;
    v_formula 		    varchar2(1000);
    v_fmlmax 			varchar2(1000);
    v_check 			varchar2(100);
    v_maxseq 			number(3);
    v_chknum			number(20);
    v_amt				number;
    p_amtnet			number;
    v_flgtax			number;
    v_stmt		 		varchar2(2000);
    temploy1_stamarry   varchar2(2);
    v_desproce          varchar2(1000);

    cursor c_proctax is
      select numseq,formula,fmlmax,fmlmaxtot,desproce,desproct,desproc3,desproc4,desproc5
      from tproctax
      where dteyreff = (select max(dteyreff)
                        from tproctax
                        where dteyreff <= b_dteyrepay)
      and codcompy = b_codcompy
      order by numseq;
  begin
    --total
      begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into b_codcompy
          from temploy1
         where codempid = global_v_codempid;
      exception when no_data_found then
        b_codcompy := null;
      end;    

    begin
      select count(*)
        into v_total
        from tproctax
       where dteyreff = (select max(dteyreff)
                           from tproctax
                          where dteyreff <= b_dteyrepay)
    order by numseq;
    exception when no_data_found then
      v_total := 0;
    end;

    select flgtax
      into v_flgtax
      from temploy3
     where codempid = global_v_codempid;

      p_amtnet  := p_amtincom;
      v_rcnt    := 0;
      obj_row   := json_object_t();
      obj_data  := json_object_t();

      for r_proctax in c_proctax loop
        if r_proctax.numseq = 1 then
          v_formula := to_char(p_amtincom);
        else
          if r_proctax.formula is not null then
            v_formula   := r_proctax.formula;
            v_amt       := 0;
            if instr(v_formula,'[') > 0 then
              loop
                v_check := substr(v_formula,instr(v_formula,'[') +1,(instr(v_formula,']') -1) - instr(v_formula,'['));
              exit when v_check is null;
                if v_check in ('E001','D001') then
                  v_amt := v_amt + gtempded(global_v_codempid,v_check,'1',p_amtproyr,p_amtsalyr);
                elsif v_check = 'D002' then
                  v_amt := v_amt + gtempded(global_v_codempid,v_check,'1',p_amtsocyr,p_amtsalyr);
                else
                  v_amt := v_amt + gtempded(global_v_codempid,v_check,'1',0,p_amtsalyr);
                  if temploy1_stamarry = 'M' and v_flgtax = '2' then
                    v_amt := v_amt + gtempded(global_v_codempid,v_check,'2',0,p_amtsalyr);
                  end if;
                end if;
                v_formula := replace(v_formula,'['||v_check||']',v_amt);
              end loop;
              v_formula := to_char(v_amt);
            end if;
            if instr(v_formula,'}') > 1 then
              loop ---  seq
                v_check := substr(v_formula,instr(v_formula,'{') +5,(instr(v_formula,'}') -1) - instr(v_formula,'{')-4);
              exit when v_check is null;
                v_formula := replace(v_formula,'{item'||v_check||'}',declare_var.v_text(v_check));
              end loop;
            end if;
              ---- check
            if v_formula <> '0' then
              if v_flgtax = '1' then
                v_fmlmax := r_proctax.fmlmax;
              else
                v_fmlmax := r_proctax.fmlmaxtot;
              end if;
              if v_fmlmax is not null then
                v_amt := greatest(execute_sql('select '||v_formula||' from dual'),0);
                begin
                  v_chknum := nvl(to_number(v_fmlmax),0);
                  if v_chknum > 0 then
                    v_formula := to_char(least(v_amt,v_chknum));
                  end if;
                exception when others then  --- formula
                  if instr(v_fmlmax,'[') > 0 then
                    loop --- codededuct
                      v_check  := substr(v_fmlmax,instr(v_fmlmax,'[') +1,(instr(v_fmlmax,']') -1) - instr(v_fmlmax,'['));
                    exit when v_check is null;
                      if get_deduct(v_check) = 'E' then
                        v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(declare_var.evalue_code(substr(v_check,2)),0));
                      elsif get_deduct(v_check) = 'D' then
                        v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(declare_var.dvalue_code(substr(v_check,2)),0));
                      else
                        v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(declare_var.ovalue_code(substr(v_check,2)),0));
                      end if;
                    end loop;
                  end if;
                  if instr(v_fmlmax,'{') > 0 then
                    loop
                      v_check := substr(v_fmlmax,instr(v_fmlmax,'{') +5,(instr(v_fmlmax,'}') -1) - instr(v_fmlmax,'{')-4);
                      exit when v_check is null;
  --										v_fmlmax := replace(v_fmlmax,'{item'||v_check||'}',declare_var.v_dataseq(v_check));
                      v_fmlmax := replace(v_fmlmax,'{item'||v_check||'}',declare_var.v_text(v_check));
                    end loop;
                  end if;
                  v_chknum := execute_sql('select '||v_fmlmax||' from dual');
                  v_formula := to_char(least(v_amt,v_chknum));
               --   declare_var.v_dataseq(r_proctax.numseq) := greatest(least(declare_var.v_dataseq(r_proctax.numseq),v_chknum),0);
                end;
                if r_proctax.numseq = 4 then
                  declare_var.v_amtexp := to_number(v_formula);
                  declare_var.v_maxexp := v_chknum;
                end if;
              end if; --end if of check v_fmlmax is not null
            end if;
          end if;
        end if; --- end if
        declare_var.v_text(r_proctax.numseq) := '('||v_formula||')';
        v_maxseq := r_proctax.numseq;
        v_amt := execute_sql('select '||declare_var.v_text(r_proctax.numseq)||' from dual');

        if global_v_lang = '101' then
          v_desproce := r_proctax.desproce;
        elsif global_v_lang = '102' then
          v_desproce := r_proctax.desproct;
        elsif global_v_lang = '103' then
          v_desproce := r_proctax.desproc3;
        elsif global_v_lang = '104' then
          v_desproce := r_proctax.desproc4;
        elsif global_v_lang = '105' then
          v_desproce := r_proctax.desproc5;
        end if;

        --
        v_rcnt := v_rcnt+1;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('rcnt', v_rcnt);
        obj_data.put('numseg',to_char(r_proctax.numseq));
        obj_data.put('desproc',to_char(v_desproce));
        obj_data.put('amtfml',to_char(nvl(v_amt,0),'fm999,999,990.00'));

        obj_row.put(to_char(v_rcnt-1),obj_data);
        --next_record;
      end loop;
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
      json_str_output := obj_row.to_clob;
  end;
  --function in tab2 table1
  FUNCTION get_deduct(v_codeduct varchar2) RETURN char IS
     v_type varchar2(1);
  BEGIN
     select typdeduct
     into v_type
     from tcodeduct
     where coddeduct = v_codeduct;
     return (v_type);
  exception when others then
     return ('D');
  END;

  FUNCTION gtempded (v_empid 			varchar2,
                     v_codeduct 	varchar2,
                     v_type 			varchar2,
                     v_amtcode 		number,
                     p_amtsalyr 	number) RETURN number IS

    --user36 HRMS590195 13/01/2016 use index of page 2
    v_amtdeduct 	number(14,2);
    v_amtdemax		tdeductd.amtdemax%type;
    v_pctdemax		tdeductd.pctdemax%type;
    v_formula			tdeductd.formula%type;
    v_pctamt 			number(14,2);
    v_check  			varchar2(20);
    v_typeded  		varchar2(1);

  BEGIN
    v_amtdeduct := v_amtcode;
    if v_amtdeduct = 0 then
      begin
        select decode(v_type,'1',stddec(amtdeduct,codempid,v_chken),stddec(amtspded,codempid,v_chken))
        into v_amtdeduct
        from	 ttaxmasd
        where	 dteyrepay = (b_dteyrepay)
        and 	 dtemthpay = b_dtemthpay
        and 	 numperiod = b_numperiod
        and 	 codempid  = global_v_codempid
        and 	 coddeduct = v_codeduct;
      exception when others then
        v_amtdeduct := 0;
      end;
    end if;  --end if  v_amtdeduct = 0
    if v_amtdeduct > 0 then
      begin
        select amtdemax, pctdemax, formula
        into v_amtdemax, v_pctdemax, v_formula
        from tdeductd
        where dteyreff = (select max(dteyreff)
                          from tdeductd
                          where dteyreff <= b_dteyrepay
                          and coddeduct = v_codeduct)
          and coddeduct = v_codeduct;
      exception when others then
        v_amtdemax := null;
        v_pctdemax := null;
        v_formula := null;
      end;
      ------ Check amt max
      if (v_amtdemax > 0) then
        if v_codeduct = 'E001' then
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
          loop
            v_check  := substr(v_formula,instr(v_formula,'[') +1,(instr(v_formula,']') -1) - instr(v_formula,'['));
            exit when v_check is null;
            if get_deduct(v_check) = 'E' then
              v_formula := replace(v_formula,'['||v_check||']',nvl(declare_var.evalue_code(substr(v_check,2)),0));
            elsif get_deduct(v_check) = 'D' then
              v_formula := replace(v_formula,'['||v_check||']',nvl(declare_var.dvalue_code(substr(v_check,2)),0));
            else
              v_formula := replace(v_formula,'['||v_check||']',nvl(declare_var.ovalue_code(substr(v_check,2)),0));
            end if;
          end loop;
          v_amtdeduct := least(v_amtdeduct,execute_sql('select '||v_formula||' from dual'));
        end if;
      end if;
    end if;
    v_typeded := get_deduct(v_codeduct);
    if v_typeded = 'E' then
      declare_var.evalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
    elsif v_typeded = 'D' then
      declare_var.dvalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
    else
      declare_var.ovalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
    end if;
  --	upd_ttaxmasd(v_codeduct,v_type,v_amtdeduct);
    return 	nvl(v_amtdeduct,0);
  END;
  -- Code TAB2_TABLE
--
  -- Code TAB3_TABLE1 Start
  procedure get_index_tab3_table1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_tab3_table1(json_str_output);
    else
      obj_row := json_object_t();
      obj_row.put('coderror','400');
      obj_row.put('desc_coderror',param_msg_error);
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_tab3_table1(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number;
    v_rcnt          number := 0;
    v_numseq        number := 0;
    v_cnt  		      number := 0;
    v_year			    number := b_dteyrepay;


    cursor deduct_e is
      select coddeduct item7, get_tcodeduct_name(coddeduct,global_v_lang) item8,
             nvl(stddec(amtdeduct,codempid,v_chken),0) item9,
             nvl(stddec(amtspded,codempid,v_chken),0)  item10
       from ttaxmasd
      where dteyrepay = v_year
        and codempid = global_v_codempid
        and substr(coddeduct,1,1) = 'E'
        and dtemthpay = b_dtemthpay
        and numperiod = b_numperiod
      order by coddeduct;

  begin

    --total
    begin
      select count(*)
        into v_total
        from ttaxmasd
       where dteyrepay = v_year
         and codempid = global_v_codempid
         and substr(coddeduct,1,1) = 'E'
         and dtemthpay = b_dtemthpay
         and numperiod = b_numperiod
       order by coddeduct;
    exception when no_data_found then
      v_total := 0;
    end;
    v_rcnt := 0;
    obj_row := json_object_t();
    obj_data := json_object_t();
    for i in deduct_e loop
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('total', v_total);
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('coddeduct',to_char(i.item7));
      obj_data.put('coddecuct_desc',to_char(i.item8));
      obj_data.put('amtdeduct',to_char(i.item9,'fm999,999,990.00'));
      obj_data.put('amtspded',to_char(i.item10,'fm999,999,990.00'));

      obj_row.put(to_char(v_rcnt-1),obj_data);
      --next_record;
    end loop;
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
    json_str_output := obj_row.to_clob;
  end;
  -- Code TAB3_TABLE1  End

  -- Code TAB4_TABLE1
  procedure get_index_tab4_table1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
      if param_msg_error is null then
        gen_data_tab4_table1(json_str_output);
      else
        obj_row := json_object_t();
        obj_row.put('coderror','400');
        obj_row.put('desc_coderror',param_msg_error);
        json_str_output := obj_row.to_clob;
      end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_tab4_table1(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number;
    v_rcnt          number := 0;
    v_numseq        number := 0;

    cursor c1 is
      select coddeduct item7, get_tcodeduct_name(coddeduct,global_v_lang) item8,
             nvl(stddec(amtdeduct,codempid,v_chken),0) item9,
             nvl(stddec(amtspded,codempid,v_chken),0)  item10
      from ttaxmasd
      where dteyrepay = b_dteyrepay
        and codempid = global_v_codempid
        and substr(coddeduct,1,1) = 'D'
        and dtemthpay = b_dtemthpay
        and numperiod = b_numperiod
      order by coddeduct;
  begin

    --total
    begin
      select count(*)
        into v_total
        from ttaxmasd
        where dteyrepay = b_dteyrepay
          and codempid = global_v_codempid
          and substr(coddeduct,1,1) = 'D'
          and dtemthpay = b_dtemthpay
          and numperiod = b_numperiod
        order by coddeduct;
    exception when no_data_found then
      v_total := 0;
    end;

    v_rcnt := 0;
    obj_row := json_object_t();
    obj_data := json_object_t();
    for i in c1 loop
      --
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('total', v_total);
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('coddeduct',to_char(i.item7));
      obj_data.put('coddecuct_desc',to_char(i.item8));
      obj_data.put('amtdeduct',to_char(i.item9,'fm999,999,990.00'));
      obj_data.put('amtspded',to_char(i.item10,'fm999,999,990.00'));

      obj_row.put(to_char(v_rcnt-1),obj_data);
      --next_record;
    end loop;

--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
    json_str_output := obj_row.to_clob;
  end;
  -- Code TAB4_TABLE1

  -- Code TAB5_TABLE1
  procedure get_index_tab5_table1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
      if param_msg_error is null then
        gen_data_tab5_table1(json_str_output);
      else
        obj_row := json_object_t();
        obj_row.put('coderror','400');
        obj_row.put('desc_coderror',param_msg_error);
        json_str_output := obj_row.to_clob;
      end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_tab5_table1(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number;
    v_rcnt          number := 0;
    v_numseq        number := 0;

    cursor c1 is
      select coddeduct item7, get_tcodeduct_name(coddeduct,global_v_lang) item8,
             nvl(stddec(amtdeduct,codempid,v_chken),0) item9,
             nvl(stddec(amtspded,codempid,v_chken),0)  item10
      from ttaxmasd
      where dteyrepay = b_dteyrepay
        and codempid = global_v_codempid
        and substr(coddeduct,1,1) = 'O'
        and dtemthpay = b_dtemthpay
        and numperiod = b_numperiod
      order by coddeduct;
  begin

    --total
    begin
      select count(*)
        into v_total
        from ttaxmasd
        where dteyrepay = b_dteyrepay
          and codempid = global_v_codempid
          and substr(coddeduct,1,1) = 'O'
          and dtemthpay = b_dtemthpay
          and numperiod = b_numperiod
        order by coddeduct;
    exception when no_data_found then
      v_total := 0;
    end;

    v_rcnt := 0;
    obj_row := json_object_t();
    obj_data := json_object_t();
    for i in c1 loop
      --
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('total', v_total);
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('coddeduct',to_char(i.item7));
      obj_data.put('coddecuct_desc',to_char(i.item8));
      obj_data.put('amtdeduct',to_char(i.item9,'fm999,999,990.00'));
      obj_data.put('amtspded',to_char(i.item10,'fm999,999,990.00'));

      obj_row.put(to_char(v_rcnt-1),obj_data);
      --next_record;
    end loop;

--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
    json_str_output := obj_row.to_clob;
  end;
--  -- Code TAB5_TABLE1
END HRES82X;

/

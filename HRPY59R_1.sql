--------------------------------------------------------
--  DDL for Package Body HRPY59R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY59R" as
	procedure del_temp(v_codapp varchar2,v_coduser varchar2) is
	begin
		delete ttemprpt where
		codapp   = upper(v_codapp) and
		codempid = upper(v_coduser) ;
		delete ttempprm where
		codapp   = upper(v_codapp) and
		codempid = upper(v_coduser) ;
		commit;
	end;

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

  function get_label (v_codapp varchar2,v_lang varchar2,v_numseq number) return varchar2 is
    v_label   trptlbl.desc_label%type ;
	begin
	  select desc_label	into v_label
   	from trptlbl
   	where
   			 trptlbl.codrept   = upper(v_codapp) and
         trptlbl.numseq    = v_numseq  and
         trptlbl.codlang   = v_lang ;
		return v_label;
	exception
		when no_data_found then
			return ' ' ;
	end;

  function get_name_report (v_lang varchar2,v_appl varchar2)return varchar2 is
    get_repname  varchar2(100);
	begin
    select decode(v_lang,'101',desrepe,'102',desrept,
                         '103',desrep3,'103',desrep4,
                         '105',desrep5,desrepe)||'  '
   		into  get_repname
   		from  tappprof
     where tappprof.codapp  = upper(v_appl);
    return get_repname;
  exception
		when others then return(null);
	end get_name_report;

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj, 'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj, 'p_dteyrepay'));
    p_codbrsoc          := hcm_util.get_string_t(json_obj, 'p_codbrsoc');
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');
    p_typreport         := hcm_util.get_string_t(json_obj, 'p_typreport');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
   v_codbrsoc		varchar2(5) := null;
	 v_numbrlvl 	varchar2(6) := null;
	 v_codcodec   varchar2(5) := null;
  begin
    begin
     select codbrsoc,numbrlvl
       into v_codbrsoc,v_numbrlvl
       from tcodsoc
      where codbrsoc = p_codbrsoc
        and rownum  <= 1;
    exception when no_data_found then
     param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodsoc');
     return;
    end;

    if p_typpayroll is not null then
      begin
       select codcodec
         into v_codcodec
         from tcodtypy
        where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
        return;
      end;
    end if;
  end check_index;

  procedure get_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
      temp_report;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data;

  procedure gen_data(json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    obj_header_data    json_object_t;
    obj_row_data       json_object_t;
    obj_temp_data      json_object_t;

    obj_row_final      json_object_t;
    obj_data_final     json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_flgpass	         boolean;
    v_dtestrt          date;
    v_dteend           date;
    v_dteempdb         date;
    v_dteempmt         date;
    v_chksecu	  	     varchar2(1 char)	:= 'N';
    v_year		         number := 0;
    v_month            number := 0;
    v_day 		         number := 0;
    -- age
    v_qtyage           number := 0;

    p_codempid         temploy1.codempid%type;
    t_codempid         temploy1.codempid%type;
    p_dteeffec         date;
    v_pass             varchar2(1 char);
    v_count				     number;
    v_data1            varchar2(4000 char)  := 'N';
    v_numacsoc		     varchar2(4000 char) := null;
    v_numacsoc_o		   varchar2(4000 char) := null;
    v_pctsoc 	         number  := 0;
    v_pctsoc_o 	       number  := 0;
    --
    v_empid  	         temploy1.codempid%type := '@@@';
    v_seq_no           number  := 0;
    v_num					     number  := 0;
    v_numoffid	       temploy2.numoffid%type := ' ';
    v_numsaid		       temploy3.numsaid%type  := ' ';
    v_item01           varchar2(4000 char);
    v_item02           varchar2(4000 char);
    v_item03           varchar2(4000 char);
    v_item04           varchar2(4000 char);
    v_item05           varchar2(4000 char);
    v_item06           varchar2(4000 char);
    v_item07           varchar2(4000 char);
    v_item08           varchar2(4000 char);
    v_item09           varchar2(4000 char);
    v_temp01           varchar2(4000 char);
    v_temp02           varchar2(4000 char);
    v_numbrlvl         varchar2(4000 char)  := '@@@';
    v_adrcome1  	     tcodsoc.adrcome1%type  := ' ';
    v_zipcode   	     tcodsoc.zipcode%type   := ' ';
      -- for sum each numbrlvl
    v_tot_amtsoc       number := 0;
    v_tot_amtsoca      number := 0;
    v_tot_amtsocc      number := 0;
    v_codbrlc   	     varchar2(4000 char)   := '#%#%#%#';
    v_codcompy         varchar2(4000 char);
    --
    v_flgbrk           varchar2(4000 char);
    v_brch_seq_p1      number := 0;
    v_brch_seq_p3      number := 0;
    v_grd_amtsoca      number := 0;
    v_grd_record       number := 0;
    v_grd_amtsoc       number := 0;

    cursor c_emp is
      select b.codcomp,b.codempid,b.codbrlc,b.numlvl,stddec(b.amtsoc,b.codempid,v_chken) amtsoc,
             stddec(b.amtsoca,b.codempid,v_chken) amtsoca,
             stddec(b.amtsocc,b.codempid,v_chken) amtsocc,
             b.typpayroll,a.codcompy,c.staemp,c.dteeffex,
             a.numbrlvl,a.adrcome1,a.zipcode
        from tcodsoc a,ttaxcur b,temploy1 c
       where a.codbrsoc   = p_codbrsoc
         and b.dtemthpay  = p_dtemthpay
         and b.dteyrepay  = (p_dteyrepay - global_v_zyear)
         and b.typpayroll = nvl(p_typpayroll,b.typpayroll)
         and b.codcomp like a.codcompy||'%'
         and b.codbrlc    = a.codbrlc
         and b.codempid   = c.codempid
         and b.flgsoc     = 'Y'
         and ( p_typreport = 1
--Error Program #2453               or ( p_typreport <> 1 and stddec(b.amtsoca,b.codempid,v_chken) > 0 ))
               or ( p_typreport <> 1
                     and exists(
								 select	t2.codempid from ttaxcur t2
                                  where	t2.codempid  = b.codempid
                                    and	t2.dteyrepay = b.dteyrepay
                                    and	t2.dtemthpay = b.dtemthpay
                                group by codempid
								having sum(stddec(amtsoca, codempid,v_chken) ) > 0 )  ))
--Error Program #2453

       order by  a.numbrlvl,b.codbrlc,decode(global_v_lang, '101',namfirste||' '||namlaste,
                                                            '102',namfirstt||' '||namlastt,
                                                            '103',namfirst3||' '||namlast3,
                                                            '104',namfirst4||' '||namlast4,
                                                            '105',namfirst5||' '||namlast5,namlaste);
  begin
    delete from ttemfilt where codapp like 'HRPY59R%'; commit;  -- delete temp

    obj_row                := json_object_t();
    v_rcnt                 := 0;
    v_flgdata              := 'N';
    --
    for r1 in c_emp loop
      v_flgdata            := 'Y';
      exit;
    end loop;
    --
    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'ttaxcur');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;
    --
    v_flgdata              := 'N';
    --
    v_dtestrt := to_date(get_period_date(p_dtemthpay,p_dteyrepay,'S'),'dd/mm/yyyy');
	  v_dteend  := to_date(get_period_date(p_dtemthpay,p_dteyrepay,'E'),'dd/mm/yyyy');
    --
    for r1 in c_emp loop
      v_flgdata     := 'Y';
			if  (r1.staemp <> '9') or (r1.amtsoc > 0) or (r1.amtsoc <= 0 and r1.staemp = '9' and r1.dteeffex > v_dtestrt) then
        v_flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        if v_flgpass then
					v_chksecu	:=	'Y';
					begin
					  select dteempdb,dteempmt
					    into v_dteempdb,v_dteempmt
					    from temploy1
					   where codempid = r1.codempid;
					exception when no_data_found then null;
					end;
					--
				  get_service_year(v_dteempdb,v_dteempmt,'Y',v_year,v_month,v_day);
					begin
					  select qtyage into v_qtyage
						from  tcontrpy
					  where codcompy = r1.codcompy
					    and dteeffec = (select max(dteeffec)
					                     from  tcontrpy
					                     where codcompy = r1.codcompy
					                     and   dteeffec <= sysdate);
					  exception when no_data_found then null;
				  end;
          --
          if v_year < v_qtyage then
            p_codempid := null;
						t_codempid := null;
          end if;
          --
          begin
            select codempid,dteeffec  into p_codempid,p_dteeffec
              from ttpminf
             where codempid = r1.codempid
               and to_char(dteeffec,'yyyymmdd') <= (select min(lpad(b.dteyrepay,4,'0')||lpad(b.dtemthpay,2,'0')||lpad(to_char(dtestrt ,'dd'),2,'0') )
                                  from tdtepay b
                                 where b.codcompy = r1.codcompy
                                   and b.typpayroll = r1.typpayroll
                                   and b.dteyrepay  = (p_dteyrepay - global_v_zyear)
                                   and b.dtemthpay  = p_dtemthpay)
               and codtrn = '0006'
               and rownum = 1;
          exception when no_data_found then
            p_codempid := null;
            p_dteeffec := null;
          end;
          --
          if p_codempid is not null then
            begin
              select codempid into t_codempid
                from ttpminf
               where codempid = r1.codempid
                 and dteeffec >= p_dteeffec
                 and codtrn   = '0002'
                 and rownum   = 1;
            exception when no_data_found then
              t_codempid := null;
            end;
          end if;
          /*************** chk codemp ***************/
          v_pass := 'Y';
          if p_typreport = 2 then
            if r1.amtsoc > 0 then
              v_pass := 'Y';
            else
              v_pass := 'N';
            end if;
          else
            if r1.amtsoc > 0 then
              v_pass := 'Y';
            else
              select count(*)
                into v_count
                from tsincexp
                where codempid = r1.codempid
                  and dteyrepay = (p_dteyrepay - global_v_zyear)
                  and dtemthpay = p_dtemthpay
                  and codpay in (select codpay
                                 from tinexinf
                                 where flgsoc = 'Y');
              if v_count > 0 then
                v_pass := 'Y';
              else
                v_pass := 'N';
              end if;
            end if;
          end if;

          if (p_codempid is null and v_pass = 'Y') or (p_codempid is not null and t_codempid is not null and v_pass = 'Y') or (v_pass = 'Y') then
            v_data1 := 'Y';
            begin
              select numacsoc
                into v_numacsoc
                from tcompny
               where codcompy = r1.codcompy;
            exception when no_data_found then null;
            end;

            begin
             select pctsoc
               into v_pctsoc
               from tcontrpy
              where codcompy = r1.codcompy
                and dteeffec = (select max(dteeffec)
                                  from tcontrpy
                                 where codcompy   = r1.codcompy
                                   and dteeffec  <= sysdate);
            exception when no_data_found then null;
            end;
            --------------------------- HEADING Screen -------------------------------------
            obj_header_data         := json_object_t();
            obj_header_data.put('coderror', '200');
            obj_header_data.put('numacsoc', v_numacsoc);
            obj_header_data.put('p_date_month', v_pctsoc);

            if v_numbrlvl||'!@#'||v_codbrlc <> r1.numbrlvl||'!@#'||r1.codbrlc then
              v_rcnt        := v_rcnt + 1;
              v_brch_seq_p1 := v_brch_seq_p1 + 1;
              v_item02      := get_label_name('HRPY59RC2',global_v_lang,'70')|| '  ' ||r1.numbrlvl;
              v_item03      := get_label_name('HRPY59RC2',global_v_lang,'80')|| '  ' ||get_tcodec_name('TCODLOCA',r1.codbrlc,global_v_lang);
              v_flgbrk      := 'Y';
              -->> insert temp header-->>
              obj_temp_data := json_object_t();
              obj_temp_data.put('v_numseq', v_brch_seq_p1);
              obj_temp_data.put('v_item1', r1.numbrlvl);
              obj_temp_data.put('v_item2', get_tcodec_name('TCODLOCA',r1.codbrlc,global_v_lang));
              obj_temp_data.put('v_item3', 'H');
              obj_temp_data.put('v_flgbrk', v_flgbrk);
              obj_temp_data.put('v_codapp', 'HRPY59RX1');
              --
              insert_temp(obj_temp_data);
              --<< insert temp header --<<

              obj_data := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('numoffid', v_item02);
              obj_data.put('desc_codempid', v_item03);
              obj_data.put('seq_no', '');
              obj_data.put('image', '');
              obj_data.put('codempid', '');
              obj_data.put('amtsoc', '');
              obj_data.put('amtsoca', '');
              obj_data.put('flgskip', 'Y');
              obj_row.put(to_char(v_rcnt-1), obj_data);

              -- Change No.Branch then write total to temp for report
              -- for insert temp report --
              if v_numbrlvl <> '@@@' and v_codbrlc <> '#%#%#%#' then
                -->> insert temp header-->>
                v_brch_seq_p3   := v_brch_seq_p3 + 1;
                obj_temp_data   := json_object_t();
                obj_temp_data.put('v_numseq', v_brch_seq_p3);
                obj_temp_data.put('v_item1', v_tot_amtsoc);
                obj_temp_data.put('v_item2', v_tot_amtsoca);
                obj_temp_data.put('v_item3', v_numbrlvl);
                obj_temp_data.put('v_item4', v_seq_no);
                obj_temp_data.put('v_item5', v_tot_amtsoca);
                obj_temp_data.put('v_item6', nvl(v_tot_amtsoca,0) + nvl(v_tot_amtsoca,0));
                obj_temp_data.put('v_item7', v_brch_seq_p3);
                /* obj_temp_data.put('v_item8', get_tcodec_name('TCODLOCA',v_codbrlc,'102'));
                obj_temp_data.put('v_item9', v_adrcome1);
                obj_temp_data.put('v_item10', v_zipcode);
                obj_temp_data.put('v_item11', v_codbrlc);
                obj_temp_data.put('v_codapp', 'HRPY59RX2'); */
                obj_temp_data.put('v_item13', v_codbrlc);
                obj_temp_data.put('v_item14', get_tcodec_name('TCODLOCA', v_codbrlc,'102'));
                obj_temp_data.put('v_item15', v_adrcome1);
                obj_temp_data.put('v_item16', v_zipcode);
                obj_temp_data.put('v_item17', v_pctsoc_o);
                obj_temp_data.put('v_item18', v_numacsoc_o);
                obj_temp_data.put('v_item19', v_codcompy);
                obj_temp_data.put('v_codapp', 'HRPY59RX4');
                --
                insert_temp(obj_temp_data);
                --<< insert temp header --<<
                v_grd_amtsoc 	:= v_grd_amtsoc + v_tot_amtsoc;
                v_grd_amtsoca := v_grd_amtsoca + v_tot_amtsoca;
                v_grd_record 	:= v_grd_record + v_seq_no;
                v_tot_amtsoc 	:= 0;
                v_tot_amtsoca := 0;
                v_tot_amtsocc := 0;

                obj_temp_data.put('v_item8', v_grd_amtsoc);
                obj_temp_data.put('v_item9', v_grd_amtsoca);
                obj_temp_data.put('v_item10', v_grd_amtsoca);
                obj_temp_data.put('v_item11', v_grd_amtsoca + v_grd_amtsoca);
                obj_temp_data.put('v_item12', v_grd_record);
              end if;
              v_seq_no      := 0;
              v_numbrlvl    := r1.numbrlvl;
              v_codbrlc     := r1.codbrlc;
              v_codcompy    := r1.codcompy;
              v_numacsoc_o  := v_numacsoc;
              v_pctsoc_o    := v_pctsoc;
            end if;

            -- CHK EMPID --
            if (v_empid <> r1.codempid)  then
              v_empid  := r1.codempid;
              v_seq_no := v_seq_no + 1;
              v_num	 	 := v_num + 1;
              begin
               select b.numsaid,a.numoffid
                 into v_numsaid,v_numoffid
                 from temploy2 a,temploy3 b
                where a.codempid = b.codempid
                  and a.codempid = v_empid;
              exception when no_data_found then
                v_numsaid  := null;
                v_numoffid := null;
              end;
              if v_numsaid is null and v_numoffid is not null then
                v_numsaid := v_numoffid;
              end if;

              -- INSERT DETAIL --
              v_item01 	:= v_seq_no;
              v_item02  := v_numsaid;
              v_item03 	:= get_temploy_name(v_empid,global_v_lang);
              v_item04	:= get_temploy_name(v_empid,global_v_lang);
              v_item05	:= v_empid;
              v_item06 	:= v_numbrlvl;
              v_item08 	:= get_tcodec_name('TCODLOCA',r1.codbrlc,global_v_lang);
              v_item09 	:= r1.codbrlc;
              v_item07 	:= 'D';
              if nvl(r1.amtsoc,0) < 0 then
                v_temp01 	:= 0;
              else
                v_temp01 	:= nvl(r1.amtsoc,0);
              end if;

--              if nvl(r1.amtsoca,0) < 0 then
--                v_temp02 	:= 0;
--              else
--                v_temp02 	:= nvl(r1.amtsoca,0);
--              end if;

                  v_temp02 	:= nvl(r1.amtsoca,0);

--              v_temp01 	:= nvl(r1.amtsoc,0);
--              v_temp02  := nvl(r1.amtsoca,0);

              v_tot_amtsoc 	:= v_tot_amtsoc  + nvl(r1.amtsoc,0);
              v_tot_amtsoca := v_tot_amtsoca + nvl(r1.amtsoca,0);
              v_tot_amtsocc := v_tot_amtsocc + nvl(r1.amtsocc,0);

              v_adrcome1:= r1.adrcome1;
              v_zipcode := r1.zipcode;

              -->> insert temp detail-->>
              obj_temp_data    := json_object_t();
              obj_temp_data.put('v_numseq', v_num);
              obj_temp_data.put('v_item1', v_seq_no);
              obj_temp_data.put('v_item2', v_numsaid);
              obj_temp_data.put('v_item3', get_temploy_name(v_empid,global_v_lang));
              obj_temp_data.put('v_item4', v_empid);
              obj_temp_data.put('v_item5', v_numbrlvl);
              obj_temp_data.put('v_item6', get_tcodec_name('TCODLOCA',r1.codbrlc,global_v_lang));
              obj_temp_data.put('v_item7', r1.codbrlc);
              obj_temp_data.put('v_item8', 'D');
              obj_temp_data.put('v_item9', r1.codcompy);
              obj_temp_data.put('v_item10', v_numacsoc);
              obj_temp_data.put('v_temp1', v_temp01);
              obj_temp_data.put('v_temp2', v_temp02);
              obj_temp_data.put('v_codapp', 'HRPY59RX3');
              insert_temp(obj_temp_data);
              --<< insert temp detail --<<

              -->> response data -->>
              v_rcnt           := v_rcnt + 1;
              obj_data         := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('numoffid', '');
              obj_data.put('desc_codempid', '');
              obj_data.put('seq_no', v_item01);
              obj_data.put('image', get_emp_img(v_item05));
              obj_data.put('numoffid', v_item02);
              obj_data.put('desc_codempid', v_item03);
              obj_data.put('codempid', v_item05);
              obj_data.put('amtsoc', v_temp01);
              obj_data.put('amtsoca', v_temp02);

              obj_row.put(to_char(v_rcnt-1), obj_data);

              --<< response data --<<
            else

              v_temp01 	:= nvl(to_number(v_temp01),0) + nvl(r1.amtsoc,0);  --v_amtsoc;
              v_temp02  := nvl(to_number(v_temp02),0) + nvl(r1.amtsoca,0); --v_amtsoca;

              -- for print report --
              v_tot_amtsoc 	:= v_tot_amtsoc  + nvl(r1.amtsoc,0);
              v_tot_amtsoca := v_tot_amtsoca + nvl(r1.amtsoca,0);
              v_tot_amtsocc := v_tot_amtsocc + nvl(r1.amtsocc,0);

              -->> insert temp detail-->>
              obj_temp_data    := json_object_t();
              obj_temp_data.put('v_numseq', v_num);
              obj_temp_data.put('v_item1', v_seq_no);
              obj_temp_data.put('v_item2', v_numsaid);
              obj_temp_data.put('v_item3', get_temploy_name(v_empid,global_v_lang));
              obj_temp_data.put('v_item4', v_empid);
              obj_temp_data.put('v_item5', v_numbrlvl);
              obj_temp_data.put('v_item6', get_tcodec_name('TCODLOCA',r1.codbrlc,global_v_lang));
              obj_temp_data.put('v_item7', r1.codbrlc);
              obj_temp_data.put('v_item8', 'D');
              obj_temp_data.put('v_item9', r1.codcompy);
              obj_temp_data.put('v_item10', v_numacsoc);
              obj_temp_data.put('v_temp1', v_temp01);
              obj_temp_data.put('v_temp2', v_temp02);
              obj_temp_data.put('v_codapp', 'HRPY59RX3');
              insert_temp(obj_temp_data);
              --<< insert temp detail --<<

              -- Update amtsoc for same codempid and numperiod > 1 and typpayroll > 1
              -- (difference typpayroll for each numperiod in same codempid,dtemthpay,dteyrepay)
              obj_data         := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('numoffid', '');
              obj_data.put('desc_codempid', '');
              obj_data.put('seq_no', v_item01);
              obj_data.put('image', get_emp_img(v_item05));
              obj_data.put('numoffid', v_item02);
              obj_data.put('desc_codempid', v_item03);
              obj_data.put('codempid', v_item05);
              obj_data.put('amtsoc', v_temp01);
              obj_data.put('amtsoca', v_temp02);
              obj_row.put(to_char(v_rcnt-1), obj_data);



            end if;-- if codempid
          end if;-- end chk codemp
        end if;
      end if;
    end loop;
    obj_data_final  := json_object_t();
    obj_row_final    := json_object_t();
    obj_row_data     := json_object_t();
    -- header object
    obj_data_final.put('dataHead', obj_header_data);

    -- table object
    obj_row_data.put('rows',obj_row);
    obj_data_final.put('table', obj_row_data);
    obj_row_final.put('0', obj_data_final);
    --

    if v_data1 = 'Y' then
      v_brch_seq_p3   := v_brch_seq_p3 + 1;
      -->> insert temp detail-->>

      obj_temp_data   := json_object_t();
      obj_temp_data.put('v_numseq', v_brch_seq_p3);
      obj_temp_data.put('v_item1', v_tot_amtsoc);
      obj_temp_data.put('v_item2', v_tot_amtsoca);
      obj_temp_data.put('v_item3', v_numbrlvl);
      obj_temp_data.put('v_item4', v_seq_no);
      obj_temp_data.put('v_item5', v_tot_amtsocc);
      obj_temp_data.put('v_item6', nvl(v_tot_amtsoca,0) + nvl(v_tot_amtsocc,0));
      obj_temp_data.put('v_item7', v_brch_seq_p3);
      obj_temp_data.put('v_item13', v_codbrlc);
      obj_temp_data.put('v_item14', get_tcodec_name('TCODLOCA', v_codbrlc,'102'));
      obj_temp_data.put('v_item15', v_adrcome1);
      obj_temp_data.put('v_item16', v_zipcode);
      obj_temp_data.put('v_item17', v_pctsoc);
      obj_temp_data.put('v_item18', v_numacsoc);
      obj_temp_data.put('v_item19', v_codcompy);
      obj_temp_data.put('v_codapp', 'HRPY59RX4');
      --
      v_grd_amtsoc  := v_grd_amtsoc + v_tot_amtsoc;
      v_grd_amtsoca := v_grd_amtsoca + v_tot_amtsoca;
      v_grd_record  := v_grd_record + v_seq_no;
      v_tot_amtsoc  := 0;
      v_tot_amtsoca := 0;
      v_seq_no   	  := 0;
      --
      obj_temp_data.put('v_item8', v_grd_amtsoc);
      obj_temp_data.put('v_item9', v_grd_amtsoca);
      obj_temp_data.put('v_item10', v_grd_amtsoca);
      obj_temp_data.put('v_item11', v_grd_amtsoca + v_grd_amtsoca);
      obj_temp_data.put('v_item12', v_grd_record);
      --
      v_grd_amtsoc  := 0;
      v_grd_amtsoca := 0;
      v_grd_record  := 0;
      --
      insert_temp(obj_temp_data);
      --<< insert temp header --<<
    end if;
    --
    --
    if v_flgdata = 'Y' and v_chksecu ='N' then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_row_final.to_clob;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;

  procedure temp_report is
    TYPE v_label IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
    f_labdate1  		varchar2(4000 char);
    f_labdate2  		varchar2(4000 char);
    f_repname   		varchar2(4000 char);
    v_namcompy 		  varchar2(4000 char);
    v_num       		number := 0 ;
    v_num1      		number := 0;
    num        		  number := 0 ;
    month1      		varchar2(4000 char);
    v_dteyrepay 		number := 0;
    namcomp     		varchar2(4000 char);
    namloca     		varchar2(4000 char);
    p_day_month 		varchar2(4000 char);
    p_day       		varchar2(4000 char);
    P_month     		varchar2(4000 char);
    v_namerpt   		varchar2(4000 char);
    v_amount    		varchar2(4000 char);
    v_codcompy  		varchar2(4000 char);
    i							  number := 1;
    j						    number := 1;
    numrow				  number := 18; --- Max Detail At Report
    sum_temp54			number := 0;
    sum_temp55			number := 0;
    sum_temp56			number := 0;
    sum_temp57			number := 0;
    sum_temp58			number := 0;
    --# ignore value #--
    v_sumpage       number := 0;
    p_numacsoc      tcompny.numacsoc%type;
    p_date          date;
    v_codapp        varchar2(4000 char);
    v_adrcome1      varchar2(4000 char);
    v_numtele       varchar2(4000 char);
    v_numfax        varchar2(4000 char);
    v_zipcode       varchar2(4000 char);
    v_codempid      varchar2(4000 char);
    v_name          varchar2(4000 char);
    v_desc_codpos   varchar2(4000 char);
    v_chg_codbrlc   varchar2(100);
    v_seq_rep       number  := 0;

    cursor c_ttemfilt is
      select item01, item02, item03, item04, item05, item06, item07,item08,
             item09, item10, item11, item12, item13,item14,item15,item16,item17,
             item18, item19,
             temp02, temp01
        from ttemfilt
        where codapp  = v_codapp
          and coduser = global_v_coduser
      order by numseq;

  begin
    del_temp('HRPY59R',global_v_codempid);
    month1  := get_nammthful(p_dtemthpay,'102');
    v_dteyrepay  := p_dteyrepay + hcm_appsettings.get_additional_year;
    --
    v_codapp   := 'HRPY59RX3';
    for r_ttemfilt in c_ttemfilt loop
      if nvl(v_chg_codbrlc,'XXX') <> r_ttemfilt.item05 then
        v_chg_codbrlc := r_ttemfilt.item05;
        v_seq_rep     := 0;
      end if;
      if r_ttemfilt.item08 = 'D' then
        v_num     := v_num + 1;
        v_seq_rep := v_seq_rep + 1;
        insert into ttemprpt
		        (codempid,codapp,numseq,
		         item1,item2,item3,item4,item5,
             item6,item7,item8,item9,item10,item11,item12,
             item13,item14,
		  	     temp1,temp2)
		  	 values
		  	    (global_v_codempid,'HRPY59R',v_num,
		  	     1,to_char(v_seq_rep),r_ttemfilt.item02,r_ttemfilt.item03,r_ttemfilt.item04,r_ttemfilt.item05,
		  	     r_ttemfilt.item06,r_ttemfilt.item07,r_ttemfilt.item08,month1,v_dteyrepay,r_ttemfilt.item09,
             get_tcompny_name(r_ttemfilt.item09,'102'),r_ttemfilt.item10,
             r_ttemfilt.temp01,r_ttemfilt.temp02);
      end if;

     end loop;
     --
     v_codapp   := 'HRPY59RX4';
     v_seq_rep  := 0;
     for r_ttemfilt in c_ttemfilt loop
        v_num       := v_num + 1;
        v_seq_rep   := v_seq_rep + 1;

        if r_ttemfilt.item06 >= 0 then
           v_amount := get_amount_name(trunc(r_ttemfilt.item06),'102');
        end if;
        p_day_month := r_ttemfilt.item17;
        p_numacsoc  := r_ttemfilt.item18;
        namcomp     := get_tcompny_name(r_ttemfilt.item19,'102');
        begin
          select codempid into v_codempid
            from tsetsign
           where codcompy = r_ttemfilt.item19
             and coddoc = 'HRPY59R';
        exception when no_data_found then
          v_codempid    := null;
        end;
        --
        begin
          select get_tlistval_name('CODTITLE',codtitle,'102')||namfirstt|| ' ' ||namlastt,
                 get_tpostn_name(codpos,'102')
            into v_name,v_desc_codpos
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then
          v_name        := null;
          v_desc_codpos := null;
        end;

        --address--
        begin
          select adrcome1, zipcode, numtele, numfax
            into v_adrcome1, v_zipcode, v_numtele, v_numfax
            from tcodsoc
           where codcompy = r_ttemfilt.item19
              and codbrlc  = r_ttemfilt.item13;
        exception when no_data_found then
          v_adrcome1    := null;
          v_zipcode     := null;
          v_numtele     := null;
          v_numfax      := null;
        end;

        v_sumpage := floor(v_num / 16);
        if (mod(v_num,16) <= 6) then
            v_sumpage := v_sumpage + 1;
        else
            v_sumpage := v_sumpage + 2;
        end if;

        insert into ttemprpt
           (codempid,codapp,numseq,
           item1,item12,item15,
           item16,item17,item4,
           item5,item8,item13,
           temp45,temp50,
           temp46,temp51,
           temp47,temp52,
           temp48,temp53,
           temp49,item18,item9,
           item22,item23,
           item24,item25,item26,item27,
           item28,item29,item2,
           item30)
        values
           (global_v_codempid,'HRPY59R',v_num,
           2,namcomp,r_ttemfilt.item08,
           r_ttemfilt.item09,r_ttemfilt.item10,p_numacsoc,
           r_ttemfilt.item03,p_day_month,p_date,
           trunc(r_ttemfilt.item01),mod(r_ttemfilt.item01,1),
           trunc(r_ttemfilt.item02),mod(r_ttemfilt.item02,1),
           trunc(r_ttemfilt.item05),mod(r_ttemfilt.item05,1),
           trunc(r_ttemfilt.item06),mod(r_ttemfilt.item06,1),
           r_ttemfilt.item04,v_amount,r_ttemfilt.item03,
           month1,v_dteyrepay,
           r_ttemfilt.item13,r_ttemfilt.item14,
           v_adrcome1,v_zipcode,
           v_numtele,v_numfax,v_seq_rep,
           v_sumpage);
        v_num       := v_num + 1;
        --
        insert into ttemprpt
           (codempid,codapp,numseq,item1,item19,item20,temp54,temp55,temp56,temp57,temp58,
            item4,item8,item12,item13,item14,item15,item16,item2)
        values
           (global_v_codempid,'HRPY59R',v_num,3,r_ttemfilt.item07,r_ttemfilt.item03,r_ttemfilt.item01,r_ttemfilt.item02,r_ttemfilt.item05,r_ttemfilt.item06,
            r_ttemfilt.item04,p_numacsoc,p_day_month,namcomp,month1,v_dteyrepay,v_name,v_desc_codpos,v_seq_rep);
     end loop ;
    -------------------------------------
    commit;
  end;

  procedure insert_temp(json_obj json_object_t) is
    v_flgbrk     varchar2(100 char);
    v_codapp     varchar2(100 char);
    v_numseq     number := 0;
    v_cnt        number := 0;
    -- declare array value--
    type ttemfilt_arr is table of varchar2(4000 char) index by binary_integer;
      v_item   ttemfilt_arr;
      v_temp   ttemfilt_arr;
  begin
    v_flgbrk := hcm_util.get_string_t(json_obj,'v_flgbrk');
    v_codapp := hcm_util.get_string_t(json_obj,'v_codapp');
    v_numseq := to_number(hcm_util.get_string_t(json_obj,'v_numseq'));
    -- loop get item --
    for i in 1..19 loop
      v_item(i) := nvl(hcm_util.get_string_t(json_obj,'v_item'||i),null);
    end loop;
    --
    for i in 1..5 loop
      v_temp(i) := nvl(hcm_util.get_string_t(json_obj,'v_temp'||i),null);
    end loop;
    -- clear temp table --
    begin
      delete from ttemfilt where codapp = v_codapp
                             and numseq = v_numseq
                             and coduser = global_v_coduser;
--    exception when others then null;
    end;
    --
    begin
      insert into ttemfilt (coduser,codapp,numseq,flgbrk,
                            item01,item02,item03,item04,item05,
                            item06,item07,item08,item09,item10,
                            item11,item12,item13,item14,item15,
                            item16,item17,item18,item19,
                            temp01,temp02,temp03,temp04,temp05)
                     values(global_v_coduser,v_codapp,v_numseq,v_flgbrk,
                            v_item(1),v_item(2),v_item(3),v_item(4),v_item(5),
                            v_item(6),v_item(7),v_item(8),v_item(9),v_item(10),
                            v_item(11),v_item(12),v_item(13),v_item(14),v_item(15),
                            v_item(16),v_item(17),v_item(18),v_item(19),
                            v_temp(1),v_temp(2),v_temp(3),v_temp(4),v_temp(5));
--    exception when others then null;
    end;
--    commit;
  end;
end HRPY59R;

/

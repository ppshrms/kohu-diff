--------------------------------------------------------
--  DDL for Package Body HRPY95R_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY95R_BATCH" is
   /*procedure start_process1 (p_codempid  in   varchar2,
                           p_codcomp    in   varchar2,
                           p_dteyrepay  in   number,
                           p_chken      in   varchar2,
                           p_zyear      in   number,
                           p_coduser    in   varchar2,
                           p_lang       in   varchar2,
                           p_exit       out  varchar2,
                           p_secur      out  varchar2) is
    v_exist   		boolean := false;
    v_secur   		boolean := false;
    v_flgsecu			boolean := false;
    v_formula 		varchar2(1000);
    v_fmlmax 			varchar2(1000);
    v_check 			varchar2(100);
    v_maxseq 			number(3);
    v_chknum			number(20);
    v_amt					number;
    v_amtedo			number;
    v_stmt		 		varchar2(2000);
    v_numseq			number;
    v_numseqe			number;
    v_numseqd			number;
    v_numseqo			number;
    v_codempid		temploy1.codempid%type;
    v_namemp			varchar2(100);
    v_desmarry		varchar2(100);
    v_destyptax		varchar2(100);
    v_tax					number;
    v_desdeduct		varchar2(150);
    v_typded			varchar2(1);
    v_amtsalyr		number;
    v_amtinc			number;
    v_amtnet			number;
    v_amttax			number;
    v_sumtax			number;
    v_amtgrstxt		number(20,2);
    v_dtemthpay		number;
    v_numperiod		number;
    v_amtcal			number;
    v_balperd			number;
    v_zminlvl     number;
    v_zwrklvl     number;
    v_zupdsal     varchar2(1);
    v_taxa				number;
  cursor c_emp is
    select t1.codempid,t1.codcomp,t1.numlvl,t1.stamarry,t1.typpayroll,
           t3.typtax,t3.flgtax,t3.numtaxid,
           nvl(stddec(tm.amtcalt,tm.codempid,para_chken),0)  amtcalt,
           nvl(stddec(t3.amtincbf,t3.codempid,para_chken),0) amtincbf,
           nvl(stddec(t3.amttaxbf,t3.codempid,para_chken),0) amttaxbf,
           nvl(stddec(t3.amttaxsp,t3.codempid,para_chken),0) amttaxsp,
           nvl(stddec(t3.amtincsp,t3.codempid,para_chken),0) amtincsp,
           nvl(stddec(tm.amtsalyr,tm.codempid,para_chken),0) amtsalyr,
           nvl(stddec(tm.amtsocyr,tm.codempid,para_chken),0) amtsocyr,
           nvl(stddec(tm.amtproyr,tm.codempid,para_chken),0) amtproyr,
           nvl(stddec(tm.amttaxt,tm.codempid,para_chken),0)  amttaxt,
           nvl(stddec(tm.amtgrstxt,tm.codempid,p_chken),0)amtgrstxt
    from 	 temploy1 t1,temploy3 t3,ttaxmas tm
    where  t1.codempid  = nvl(indx_codempid,t1.codempid)
    and 	 t1.codcomp  like indx_codcomp
    and 	 tm.dteyrepay = indx_dteyrepay - para_zyear
    and		 t1.codempid  = t3.codempid
    and		 t1.codempid  = tm.codempid
    order by t1.codcomp,t1.codempid;
  cursor c_proctax is
    select numseq,formula,fmlmax,fmlmaxtot,
           decode(para_lang,'101',DESPROCE,'102',DESPROCT,'103',DESPROC3,
                            '104',DESPROC4,'105',DESPROC5,DESPROCT)desproc
      from tproctax
     where codcompy = indx_codcompy
       and dteyreff = (select max(dteyreff)
                         from tproctax
                        where codcompy = indx_codcompy
                          and dteyreff <= indx_dteyrepay - para_zyear)
     order by numseq;

  begin
    para_coduser   := p_coduser;
    para_chken     := p_chken;
    para_zyear     := p_zyear;
    para_lang      := p_lang;
    indx_codempid  := p_codempid;
    indx_codcomp   := p_codcomp;
    indx_codcompy  := hcm_util.get_codcomp_level(p_codcomp,1);
    indx_dteyrepay := p_dteyrepay;
    p_exit         := 'Y';
    p_secur        := 'Y';
    begin
       select get_numdec(numlvlst,para_coduser) numlvlst, get_numdec(numlvlen,para_coduser) numlvlen
         into v_zminlvl,v_zwrklvl
         from tusrprof
        where coduser = para_coduser;
     exception when others then null;
    end;
    v_numseq := 0; v_numseqe := 0; v_numseqd := 0; v_numseqo := 0;
    del_temp('HRPY95R',para_coduser);
    del_temp('HRPY95R1',para_coduser);
    del_temp('HRPY95R2',para_coduser);
    del_temp('HRPY95R3',para_coduser);
    del_temp('HRPY95R4',para_coduser);

    for r_emp in c_emp loop
      v_exist := true;
      v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,para_coduser,v_zminlvl,v_zwrklvl,v_zupdsal);
      if v_flgsecu then
        v_secur := true;
        v_maxseq := 0;
        v_codempid  := r_emp.codempid;
        v_namemp    := get_temploy_name(v_codempid,para_lang);
        v_desmarry  := get_tlistval_name('NAMMARRY',r_emp.stamarry,para_lang);
        v_destyptax := get_tlistval_name('NAMTAXDD',r_emp.typtax,para_lang);
        v_amtexp  := null;
        v_maxexp  := null;
        v_amtdiff := null;
        tep1_codempid := r_emp.codempid;
        tep1_stamarry := r_emp.stamarry;
        tep3_typtax 	 := r_emp.typtax;
        tep3_amtincsp := r_emp.amtincsp;
        v_amtsalyr := r_emp.amtsalyr;
        v_amtinc   := v_amtsalyr;

        cal_amtnet(v_amtinc,v_amtsalyr,r_emp.amtproyr,r_emp.amtsocyr,v_amtnet);

        cal_amttax(v_amtnet,'1',0,v_taxa,indx_codcompy,v_amttax);

        v_tax := v_amttax;
        for r_proctax in c_proctax loop
          v_amt := 0;
          if r_proctax.numseq = 1 then  		------- 1. ????????????????????????????????
            v_amt := v_amtsalyr;
            v_formula := to_char(v_amt);
          else
            if r_proctax.formula is not null then
              v_formula := r_proctax.formula;
              if instr(v_formula,'[') > 0 then
                loop 	--- ??????????? ????????? ???????????????????/???????
                  v_check := substr(v_formula,instr(v_formula,'[') +1,(instr(v_formula,']') -1) - instr(v_formula,'['));
                exit when v_check is null;
                  if v_check in ('E001','D001') then --- ????????????????????????????
                    v_amtedo := gtempded(v_codempid,v_check,'1',r_emp.amtproyr,v_amtsalyr);
                    v_amt := v_amt + v_amtedo;
                  elsif v_check = 'D002' then --- ?????????????????????????
                    v_amtedo := gtempded(v_codempid,v_check,'1',r_emp.amtsocyr,v_amtsalyr);
                    v_amt := v_amt + v_amtedo;
                  else
                    v_amtedo := gtempded(v_codempid,v_check,'1',0,v_amtsalyr);
                    if r_emp.stamarry = 'M' and r_emp.typtax = '2' then
                      v_amtedo := v_amtedo + gtempded(v_codempid,v_check,'2',0,tep3_amtincsp);
                    end if;
                    v_amt := v_amt + v_amtedo;
                  end if;
                  v_desdeduct := get_tcodeduct_name(v_check,para_lang);
                  v_typded 		:= get_deduct(v_check);
                  if v_typded = 'E' then
                    v_numseqe := v_numseqe + 1;
                    ins_temp('HRPY95R2',v_numseqe,v_codempid,v_namemp,r_emp.numtaxid,
                              v_desmarry,v_destyptax,v_check,v_desdeduct,v_amtedo);
                  elsif v_typded = 'D' then
                    v_numseqd := v_numseqd + 1;
                    ins_temp('HRPY95R3',v_numseqd,v_codempid,v_namemp,r_emp.numtaxid,
                              v_desmarry,v_destyptax,v_check,v_desdeduct,v_amtedo);
                  elsif v_typded = 'O' then
                    v_numseqo := v_numseqo + 1;
                    ins_temp('HRPY95R4',v_numseqo,v_codempid,v_namemp,r_emp.numtaxid,
                              v_desmarry,v_destyptax,v_check,v_desdeduct,v_amtedo);
                  end if;
                  v_formula := replace(v_formula,'['||v_check||']',v_amt);
                end loop;
                v_formula := to_char(v_amt);
              end if;
              if instr(v_formula,'}') > 1 then
                loop --- ??????????? ????????? ????????? seq
                  v_check := substr(v_formula,instr(v_formula,'{') +5,(instr(v_formula,'}') -1) - instr(v_formula,'{')-4);
                exit when v_check is null;
                  v_formula := replace(v_formula,'{item'||v_check||'}',v_text(v_check));
                end loop;
                v_amt := greatest(execute_sql('select '||v_formula||' from dual'),0);
              end if;
                ---- check ????????? ???????? ??????
              if v_formula <> '0' then
                if r_emp.typtax = '1' then -- ???????????
                  v_fmlmax := r_proctax.fmlmax;
                else
                  v_fmlmax := r_proctax.fmlmaxtot;
                end if;
                if v_fmlmax is not null then
                  v_amt := greatest(execute_sql('select '||v_formula||' from dual'),0);
                  begin
                    v_chknum := nvl(to_number(v_fmlmax),0);   --????????????????
                    if v_chknum > 0 then
                       v_amt     := to_char(least(v_amt,v_chknum));
                       v_formula := v_amt;
                    end if;
                  exception when others then  --- ??????? formula
                    if instr(v_fmlmax,'[') > 0 then
                      loop --- ??????????? ????????? ????????? codededuct
                        v_check  := substr(v_fmlmax,instr(v_fmlmax,'[') +1,(instr(v_fmlmax,']') -1) - instr(v_fmlmax,'['));
                      exit when v_check is null;
                        if get_deduct(v_check) = 'E' then
                          v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(evalue_code(substr(v_check,2)),0));
                        elsif get_deduct(v_check) = 'D' then
                          v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(dvalue_code(substr(v_check,2)),0));
                        else
                          v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(ovalue_code(substr(v_check,2)),0));
                        end if;
                      end loop;
                    end if;
                    if instr(v_fmlmax,'{') > 0 then
                      loop --- ??????????? ????????? ????????? seq
                        v_check  := substr(v_fmlmax,instr(v_fmlmax,'{') +5,(instr(v_fmlmax,'}') -1) - instr(v_fmlmax,'{')-4);
                      exit when v_check is null;
                        v_fmlmax := replace(v_fmlmax,'{item'||v_check||'}',v_text(v_check));
                      end loop;
                    end if;
                    v_chknum  := execute_sql('select '||v_fmlmax||' from dual');
                    v_amt     := to_char(least(v_amt,v_chknum));
                    v_formula := v_amt;
                  end;
                end if; --end if of check v_fmlmax is not null
              end if;
            end if;
          end if; --- end if of 1. ????????????????????????????????
          v_numseq := v_numseq + 1;
          ins_temp('HRPY95R1',v_numseq,v_codempid,v_namemp,r_emp.numtaxid,
                    v_desmarry,v_destyptax,r_proctax.numseq,r_proctax.desproc,v_amt);
          v_text(r_proctax.numseq) := '('||v_formula||')';
          v_maxseq := r_proctax.numseq;
        end loop;
        v_stmt := v_text(v_maxseq);
        v_amt  := execute_sql('select '||v_stmt||' from dual');
        if v_maxseq > 0 then
          v_numseq := v_numseq + 1;
          ins_temp('HRPY95R1',v_numseq,v_codempid,v_namemp,r_emp.numtaxid,
                    v_desmarry,v_destyptax,(v_maxseq + 1),get_label_name('HRPY95RC2',para_lang,150),v_tax);
          v_amt := nvl(r_emp.amttaxt,0) + nvl(r_emp.amttaxbf,0);
          if r_emp.typtax = '2' and r_emp.stamarry = 'M' then
            v_amt := v_amt + nvl(r_emp.amttaxsp,0);
          end if;
          v_numseq := v_numseq + 1;
          ins_temp('HRPY95R1',v_numseq,v_codempid,v_namemp,r_emp.numtaxid,
                    v_desmarry,v_destyptax,(v_maxseq + 2),get_label_name('HRPY95RC2',para_lang,160),v_amt);
          v_numseq := v_numseq + 1;
          if v_tax > v_amt then
            ins_temp('HRPY95R1',v_numseq,v_codempid,v_namemp,r_emp.numtaxid,
                      v_desmarry,v_destyptax,(v_maxseq + 3),get_label_name('HRPY95RC2',para_lang,170),(v_tax - v_amt));
          else
            ins_temp('HRPY95R1',v_numseq,v_codempid,v_namemp,r_emp.numtaxid,
                      v_desmarry,v_destyptax,(v_maxseq + 3),get_label_name('HRPY95RC2',para_lang,180),(v_amt - v_tax));
          end if;
        end if;
      end if; -- v_flgsecur
    end loop; -- for c_emp
  	if not v_exist then
      p_exit  := 'N' ;
    elsif not v_secur then
      p_secur := 'N' ;
    end if;
  end;*/

  procedure start_process2  (p_codempid  in   varchar2,
                             p_codcomp   in   varchar2,
                             p_dteyrepay in   number,
                             p_chken     in   varchar2,
                             p_zyear     in   number,
                             p_coduser   in   varchar2,
                             p_lang      in   varchar2,
                             p_exit      out  varchar2,
                             p_secur     out  varchar2,
                             global_v_codempid      in   varchar2) is
    v_flgsecu			    boolean;
    v_exist   		        boolean := false;
    v_secur   		        boolean := false;
    v_codempid 		        temploy1.codempid%type;
    v_amtsalyr 		        number := 0;
    v_amtproyr 		        number := 0;
    v_amtsocyr 		        number := 0;
    v_amtnet	 		    number := 0;
    v_amtemp 			    number := 0;
    v_amtsp 			    number := 0;
    v_amtchedu 		        number := 0;
    v_amtchned 		        number := 0;
    v_amtchedu_last 	    number := 0;
    v_amtchned_last 	    number := 0;
    v_amtincbf_last         number := 0;
    v_amttaxbf_last         number := 0;
    v_amtpf_last            number := 0;
    v_amtsocyr_last         number := 0;
    v_amtsalyr_tot          number := 0;
    v_amtsocyr_tot          number := 0;
    v_amtchedu2 	        number := 0;
    v_amtchned2 	        number := 0;
    v_amtfathr 		        number := 0;
    v_amtmothr 		        number := 0;
    v_amtfasp 		        number := 0;
    v_amtmosp 		        number := 0;
    v_amtinsu 		        number := 0;
    v_amtinsp 		        number := 0;
    v_amtltf 			    number := 0;
    v_amtint 			    number := 0;
    v_amtdedpf1 	        number := 0;
    v_amtdedpf2 	        number := 0;
    v_qtychedu		        number := 0;
    v_qtychned		        number := 0;
    v_amtrmf			    number := 0;
    v_amtdon			    number := 0;
    v_sumded			    number := 0;
    v_amttax 			    number := 0;
    v_amtmai		        number := 0;
    v_amthou			    number := 0;
    v_amtpens			    number := 0;
    v_amttrav			    number := 0;
    v_amthouse              number := 0;
    v_tax1 				    number := 0;
    v_tax2 				    number := 0;
    v_titlesp			    varchar2(100 char);
    v_firstsp			    varchar2(100 char);
    v_lastsp			    varchar2(100 char);
    v_numofidf	            varchar2(30 char);
    v_numofidm	            varchar2(30 char);
    v_numfasp			    varchar2(30 char);
    v_nummosp			    varchar2(30 char);
    v_namspous	            varchar2(200 char);
    v_numoffsp	            tspouse.numoffid%type;
    v_numtaxsp	            tspouse.numtaxid%type;
    v_numtaxid	            varchar2(10);
    v_numseq	 		    number := 0;
    v_amtexpown	            number := 0;
    v_amtincexp	            number := 0;
    v_amtinsufm	            number := 0;
    v_sign				    varchar2(1 char);
    v_flgfathr	            varchar2(1 char);
    v_flgmothr	            varchar2(1 char);
    v_flgfasp			    varchar2(1 char);
    v_flgmosp 	            varchar2(1 char);
    v_dtespbd			    date;
    ----------------------
    v_maxseq 			    number(3);
    v_dtemthpay	            number;
    v_numperiod	            number;
    v_amtcal			    number;
    v_balperd			    number;
    v_amtgrstxt	            number(20,2);
    v_amtinc			    number;
    v_sumtax			    number;
    v_amt				    number;
    v_formula 	            varchar2(1000 char);
    v_fmlmax 			    varchar2(1000 char);
    v_check 			    varchar2(100 char);
    v_chknum			    number(20);
    v_amtedo			    number;
    v_amtedosp	            number;
    v_stmt		 		    varchar2(2000 char);
    v_amtdemax              number;
    v_zminlvl               number;
    v_zwrklvl               number;
    v_zupdsal               varchar2(1 char);
    
    v_amtinsufhr	        number := 0;
    v_amtinsufsp	        number := 0;
    v_amtinsumhr	        number := 0;
    v_amtinsumsp	        number := 0;
    v_numcotax              varchar2(13 char);
    v_amtrelas  	        number := 0;
    v_amttaxrel             number := 0;
    
    v_amtgpf	            number := 0;
    v_amtteacher            number := 0;
    
    v_amte65under           number := 0;
    v_amte65above           number := 0;
    v_amts65under           number := 0;
    v_amts65above           number := 0;
    v_amtcompens	        number := 0;
    v_amtoths               number;
    v_chktaxrel             number := 0;
    
    p_coddeduct             varchar2(1000 char) := null;
    v_com                   varchar2(1 char) := null;
    v_pcttax	            number;
    v_taxa				    number;
    
    v_house				    number;
    v_dteyrrelf		        number;
    v_dteyrrelt		        number;
    v_amtproduc		        number := 0;
    -->>
    v_insu				    number := 0;
    v_numchild		        number;
    v_amtdemax008	        tdeductd.amtdemax%type;
    v_amtcute			    number;
    v_amtcuts			    number;
    v_amtssf			    number;
    v_loinhouse             number;
    v_amtpreg			    number;
    v_amtwheel		        number;
    v_amtbook			    number;
    v_amtotop			    number;
    v_sumdedall             number;

    v_codded_child1         varchar2(100 char);
    v_amtchldb              number;
    v_amtchlda              number;
    v_amtchldd              number;
    v_codded_child2         varchar2(100 char);
    v_amtchldi              number;    

    type num1 is table of number index by binary_integer;
    v_seq				num1;
    v_cnt				number;
    v_amtfml			num1;

    v_num_child_ned     number := 0;
    v_num_child_edu     number := 0;

    type t_num is table of number index by binary_integer;
    v_offid_chned       t_num;
    v_offid_chedu       t_num;

    v_payincrease       varchar2(1 char) := 'N';
    v_payover           varchar2(1 char) := 'N';
    v_qtychldb          temploy3.qtychldb%type;
    v_qtychlda          temploy3.qtychlda%type;
    v_qtychldd          temploy3.qtychldd%type;

    v_child_numseq      number;
    v_childb_numseq     number;
    v_childa_numseq     number;
    v_childd_numseq     number;
    cursor c_emp is
        select t1.codempid,t1.codcomp,t1.numlvl,t1.stamarry,t1.typpayroll,t1.codsex,t1.dteempdb,
                t1.namfirstt,t1.namlastt,
                t2.numoffid,t2.adrcontt,t2.codpostc,t2.numtelec,
                get_tsubdist_name(t2.codsubdistc,p_lang) dessubdistc,
                get_tcoddist_name(t2.coddistc,p_lang) desdistc,
                get_tcodec_name('TCODPROV',t2.codprovc,p_lang) desprovc,
                t3.typtax,t3.flgtax,t3.numtaxid,
                nvl(stddec(tm.amtcalt,tm.codempid,p_chken),0) amtcalt,
                nvl(stddec(t3.amtincbf,t3.codempid,p_chken),0) amtincbf,
                nvl(stddec(t3.amttaxbf,t3.codempid,p_chken),0) amttaxbf,
                nvl(stddec(t3.amttaxsp,t3.codempid,p_chken),0) amttaxsp,
                nvl(stddec(t3.amtincsp,t3.codempid,p_chken),0) amtincsp,
                nvl(stddec(tm.amtsalyr,tm.codempid,p_chken),0) amtsalyr,
                nvl(stddec(tm.amtsocyr,tm.codempid,p_chken),0) amtsocyr,
                nvl(stddec(tm.amtproyr,tm.codempid,p_chken),0) amtproyr,
                nvl(stddec(tm.amttaxt,tm.codempid,p_chken),0) amttaxt,
                nvl(stddec(t3.amtrelas,t3.codempid,p_chken),0)  amtrelas,
                nvl(stddec(t3.amttaxrel,t3.codempid,p_chken),0) amttaxrel,
                nvl(stddec(tm.amtgrstxt,tm.codempid,p_chken),0) amtgrstxt,
                t3.dteyrrelf,t3.dteyrrelt,qtychedu, qtychned
        from 	 temploy1 t1,temploy2 t2,temploy3 t3,ttaxmas tm
        where   ((p_codempid is not null and t1.codempid = p_codempid)
        or      (p_codempid is null 		 and t1.codcomp like p_codcomp
        and     t1.staemp in ('1','3')))
        and		 t2.codempid = t1.codempid
        and		 t3.codempid = t1.codempid
        and		 tm.codempid = t1.codempid
        and		 tm.dteyrepay = (p_dteyrepay - p_zyear)
        order by t1.codempid;

    cursor c_ttaxcur is
        select dtemthpay,numperiod,nvl(stddec(amtcal,codempid,p_chken),0) amtcal
          from ttaxcur
         where codempid = v_codempid
           and dteyrepay = p_dteyrepay - p_zyear
        order by dtemthpay desc,numperiod desc;

    cursor c_proctax is
        select numseq,formula,fmlmax,fmlmaxtot,
               decode(p_lang,'101',desproce,'102',desproct,'103',desproc3,
                             '104',DESPROC4,'105',DESPROC5,DESPROCT)desproc
          from tproctax
         where codcompy = indx_codcompy
           and dteyreff = (select max(dteyreff)
                             from tproctax
                            where codcompy = indx_codcompy
                              and dteyreff <= p_dteyrepay - p_zyear)
        order by numseq;

    cursor c_ttaxcodd is
        select numseq,
               substr(formula,instr(formula,'[') +1,(instr(formula,']') -1) - instr(formula,'[')) coddeduct
          from ttaxcodd
         where dteyreff = p_dteyrepay - p_zyear
        order by numseq;


    cursor c_childrn is
        select numoffid,to_char(dtechbd,'yyyy') dteyrebd
          from tchildrn
         where codempid  = v_codempid
           and flgdeduct = 'Y'
           and stachld = 'Y'
           and numoffid	 is not null
           and dtechbd is not null
           and to_char(dtechbd,'yyyy') <= (p_dteyrepay - p_zyear)
        order by dtechbd,numseq;

    cursor c_childrn2 is
        select numoffid,to_char(dtechbd,'yyyy') dteyrebd
          from tchildrn
         where codempid  = v_codempid
           and flgdeduct = 'Y'
           and stachld = 'N'
           and numoffid	 is not null
           and dtechbd is not null
           and to_char(dtechbd,'yyyy') <= (p_dteyrepay - p_zyear)
        order by dtechbd,numseq;

    cursor c_default_cal_deduct is
      select  fieldname, defaultval
      from    tsetdeflh h, tsetdeflt d
      where   h.codapp            = 'HRPMC2E'
      and     h.numpage           = 'HRPMC2E164'
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      order by seqno;
    -->>

  begin
    para_coduser   := p_coduser;
    para_chken     := p_chken;
    para_zyear     := p_zyear;
    para_lang      := p_lang;
    indx_codempid  := p_codempid;
    indx_codcomp   := p_codcomp;
    indx_codcompy  := hcm_util.get_codcomp_level(p_codcomp,1);
    indx_dteyrepay := p_dteyrepay;
    p_exit         := 'Y';
    p_secur        := 'Y';

    begin
      select nvl(numcotax,' ')
        into v_numcotax
        from tcompny
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,'1');
    exception when no_data_found then
      v_numcotax := ' ';
    end;

    begin
      select get_numdec(numlvlst,para_coduser) numlvlst, get_numdec(numlvlen,para_coduser) numlvlen
        into v_zminlvl,v_zwrklvl
        from tusrprof
       where coduser = p_coduser;
    exception when others then
        null;
    end;

    v_exist := false;
    v_secur := false;
    del_temp('HRPY95R5',global_v_codempid);

    for i in c_default_cal_deduct loop
      if i.fieldname = 'CODDEDUCT' then
        v_codded_child1 := i.defaultval;
      elsif i.fieldname = 'AMTCHLDB' then
        v_amtchldb := to_number(nvl(i.defaultval,0));
      elsif i.fieldname = 'AMTCHLDA' then
        v_amtchlda := to_number(nvl(i.defaultval,0));
      elsif i.fieldname = 'AMTCHLDD' then
        v_amtchldd := to_number(nvl(i.defaultval,0));
      elsif i.fieldname = 'CODDEDUCT2' then
        v_codded_child2 := i.defaultval;
      elsif i.fieldname = 'AMTCHLDI' then
        v_amtchldi := to_number(nvl(i.defaultval,0));
      end if;
    end loop;

    for r_emp in c_emp loop
      v_exist   := true;
      v_flgsecu := secur_main.secur1(r_emp.codcomp,r_emp.numlvl,p_coduser,v_zminlvl,v_zwrklvl,v_zupdsal);

      if v_flgsecu then
        v_secur := true;
        for i in 1..30 loop
          v_seq(i)          := null;
          v_amtfml(i)       := null;
          dvalue_code(i)    := null;
          evalue_code(i)    := null;
          ovalue_code(i)    := null;
        end loop;
        v_maxseq        := 0;
        v_amtgpf	      := 0;
        v_amtteacher    := 0;
        v_amte65under   := 0;
        v_amte65above   := 0;
        v_amts65under   := 0;
        v_amts65above   := 0;
        v_amtcompens	  := 0;
        v_amtproduc     := 0;
        v_sumdedall     := 0;
        --
        v_codempid      := r_emp.codempid;
        v_amtexp        := null;
        v_maxexp        := null;
        v_amtdiff       := null;
        tep1_codempid   := r_emp.codempid;
        tep1_stamarry   := r_emp.stamarry;
        tep3_typtax	    := r_emp.typtax;
        tep3_amtincsp   := r_emp.amtincsp;
        v_chktaxrel     := 0;

        begin
          select count(codempid)
            into v_chktaxrel
            from tlastded
           where codempid  = v_codempid
             and dteyrepay = (p_dteyrepay - p_zyear)
             and dteyrepay  between dteyrrelf and dteyrrelt;
        exception when no_data_found then
          v_chktaxrel := 0;
        end;

        begin
          select nvl(stddec(amtincbf,codempid,p_chken),0) amtsalyr,
                 nvl(stddec(amttaxbf,codempid,p_chken),0) amttaxbf,
                 nvl(stddec(amtpf,codempid,p_chken),0) amtpf,
                 nvl(stddec(amtsaid,codempid,p_chken),0) amtsocyr
            into v_amtincbf_last,
                 v_amttaxbf_last,
                 v_amtpf_last,
                 v_amtsocyr_last
            from tlastded
           where codempid  = v_codempid
             and dteyrepay = (p_dteyrepay - p_zyear);
        exception when no_data_found then
          v_amtincbf_last := 0;
          v_amttaxbf_last := 0;
          v_amtpf_last    := 0;
          v_amtsocyr_last := 0;
        end;

        if v_chktaxrel = 0 then
          tep3_amtrelas     := r_emp.amtrelas;
          tep3_amttaxrel    := r_emp.amttaxrel;
          v_amtrelas        := r_emp.amtrelas;
          v_amttaxrel       := r_emp.amttaxrel;
        else
          begin
            select stddec(amtrelas,codempid,p_chken) ,stddec(amttaxrel,codempid,p_chken)
              into v_amtrelas ,v_amttaxrel
              from tlastded
             where codempid  = v_codempid
               and dteyrepay = (p_dteyrepay - p_zyear)
               and dteyrepay between dteyrrelf and dteyrrelt;
          exception when no_data_found then
            null;
          end;

          tep3_amtrelas     := v_amtrelas;
          tep3_amttaxrel    := v_amttaxrel;
        end if;

        v_amtsalyr      := nvl(r_emp.amtsalyr,0) + nvl(v_amtincbf_last,0);
        v_amtinc        := v_amtsalyr;
        v_amtproyr      := nvl(r_emp.amtproyr,0) + nvl(v_amtpf_last,0);
        v_amtsocyr_tot  := nvl(r_emp.amtsocyr,0) + nvl(v_amtsocyr_last,0);
        cal_amtnet(v_amtinc,v_amtsalyr,v_amtproyr,v_amtsocyr_tot,v_amtnet);
        p_coddeduct := null;
        for i in 1..10 loop
          v_offid_chedu(i) := null;
          v_offid_chned(i) := null;
        end loop;

        begin
          select qtychldb,qtychlda,qtychldd
            into v_qtychldb,v_qtychlda,v_qtychldd
            from temploy3
           where codempid = v_codempid;
        exception when no_data_found then null;
        end;

        v_numchild			:= 0;
        v_num_child_edu     := 0;
        v_num_child_ned     := 0;
        v_childb_numseq     := 0;
        v_childa_numseq     := 0;
        v_childd_numseq     := 0;
        v_num_child_edu :=  v_qtychlda;
        if (v_qtychldb + v_qtychlda < 3) then
          v_num_child_ned := v_qtychldb + least(greatest(0,(3- (v_qtychldb + v_num_child_edu))),v_qtychldd);
          v_qtychldd      := v_num_child_ned - v_qtychldb;
        else
          v_num_child_ned := v_qtychldb;
          v_qtychldd      := 0;
        end if;

        if v_qtychldb +  v_qtychlda> 0 then
          for i in c_childrn loop
            v_numchild	:= v_numchild + 1;
            if v_numchild = 1 or i.dteyrebd < 2018 then
              if (v_childb_numseq + 1) <= v_qtychldb then
                v_childb_numseq := v_childb_numseq + 1;
                v_offid_chned(v_childb_numseq) := rpad(i.numoffid,13,'-');
              end if;
            else
              if (v_childa_numseq + 1) <= v_qtychlda then
                v_childa_numseq := v_childa_numseq + 1;
                v_offid_chedu(v_childa_numseq) := rpad(i.numoffid,13,'-');
              end if;
            end if;
          end loop;
        end if;

        if v_qtychldd > 0 then
          for i in c_childrn2 loop
            v_numchild			:= v_numchild + 1;
            if (v_childb_numseq + 1) <= v_num_child_ned then
              v_childb_numseq := v_childb_numseq + 1;
              v_offid_chned(v_childb_numseq) := rpad(i.numoffid,13,'-');
            end if;
          end loop;
        end if;

        begin
          select rpad(numofidf,13,'-'),rpad(numofidm,13,'-')
            into v_numofidf,v_numofidm
            from tfamily
           where codempid = r_emp.codempid;
        exception when no_data_found then
          v_numofidf := null;
          v_numofidm := null;
        end;

        begin
          select rpad(numfasp,13,'-'),
                 decode(rtrim(numfasp),null,'0','1'),
                 rpad(nummosp,13,'-'),
                 decode(rtrim(nummosp),null,'0','1'),
                 decode(para_lang,'101',namspe,'102',namspt,'103',namsp3,
                            '104',namsp4,'105',namsp5,namspt)namspous,
                 rpad(numoffid,13,'-'),rpad(numtaxid,13,'-'),dtespbd
            into v_numfasp,v_flgfasp,v_nummosp,v_flgmosp,
                 v_namspous,v_numoffsp,v_numtaxsp,v_dtespbd
            from tspouse
           where  codempid = r_emp.codempid;
        exception when no_data_found then
          v_numfasp  := null; v_flgfasp  := '0'; v_nummosp  := null;	v_flgmosp := '0';
          v_namspous := null; v_numoffsp := null;	v_numtaxsp := null;
        end;

        tspouse_name(v_namspous,r_emp.codsex,v_titlesp,v_firstsp,v_lastsp);
        --4.
        v_amtfathr    := 0;
        v_amtfasp     := 0;
        --5.
        v_amtmothr    := 0;
        v_amtmosp     := 0;
        --6.
        v_amtinsufhr  := 0;
        v_amtinsufm   := 0;
        v_amtinsufsp  := 0;
        v_amtinsufm   := 0;

        v_cnt := 0;
        for r_proctax in c_proctax loop
          v_amt         := 0;
          v_amtedo      := 0;
          v_amtedosp    := 0;
          if r_proctax.numseq = 1 then
            v_amt       := v_amtsalyr;
            v_formula   := to_char(v_amt);
          else
            if r_proctax.formula is not null then
                v_formula := r_proctax.formula;
                if instr(v_formula,'[') > 0 then
                    --------------------------------------------
                    loop
                      v_cnt := v_cnt + 1;
                      v_check := substr(v_formula,instr(v_formula,'[') +1,(instr(v_formula,']') -1) - instr(v_formula,'['));
                    exit when v_check is null;
                      if v_check in ('E001','D001') then
                        v_amtedo    := gtempded(v_codempid,v_check,'1',v_amtproyr,v_amtsalyr);
                        v_amt       := nvl(v_amt,0) + nvl(v_amtedo,0);
                        --------------
                        if v_check = 'E001' then
                            v_amtdedpf2 := v_amtedo;
                        else
                            v_amtdedpf1 := v_amtedo;
                        end if;
                        --
                        if r_proctax.numseq = 6 then --Deduct Row in Page 2
                          v_sumdedall := v_sumdedall + nvl(v_amtedo,0); ----
                        end if;
                        --------------
                      elsif V_CHECK = 'D002' then
                        v_amtedo    := gtempded(v_codempid,v_check,'1',v_amtsocyr_tot,v_amtsalyr);
                        v_amt       := v_amt + v_amtedo;
                        v_amtsocyr  := v_amtedo;
                        --
                        if r_proctax.numseq = 6 then --Deduct Row in Page 2
                          v_sumdedall := v_sumdedall + nvl(v_amtedo,0); ----
                        end if;
                      elsif v_check = 'D016' then-- (Temp70 เบี้ยประกันชีวิตแบบบำนาญ)
                        v_amtedo    := gtempded(v_codempid,v_check,'1',0,v_amtsalyr);
                        v_amt       := v_amt + v_amtedo; ----
                        v_amtpens   := nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                        --
                        if r_proctax.numseq = 6 then --Deduct Row in Page 2
                          v_sumdedall := v_sumdedall + nvl(v_amtedo,0); ----
                        end if;
                      else
                          if v_check is not null then
                            v_amtedo    := gtempded(v_codempid,v_check,'1',0,v_amtsalyr);
                            if r_emp.stamarry = 'M' and r_emp.typtax = '2' then
                              v_amtedosp      := gtempded(v_codempid,v_check,'2',0,tep3_amtincsp);
                            end if;
                          end if;
                          if  v_check = 'E002' then
                            v_amtgpf        := v_amtedo;
                          elsif v_check = 'E003' then
                            v_amtteacher	:= v_amtedo;
                          elsif v_check = 'E004' then
                            v_amte65above	:= v_amtedo;
                            v_amts65above	:= v_amtedosp;
                          elsif v_check = 'E005' then
                            v_amtcompens	:= v_amtedo;
                          end if;

                          v_amt   := v_amt + (v_amtedo + v_amtedosp);
                          v_com   := null;

                            for r_ttaxcodd in c_ttaxcodd loop
                                if (v_check = r_ttaxcodd.coddeduct) or (v_check = 'D009' and r_ttaxcodd.coddeduct = 'D008') then
                                    p_coddeduct := p_coddeduct||v_com||''''||r_ttaxcodd.coddeduct||'''';
                                    v_com := ',';
                                    if r_ttaxcodd.numseq = 1 then
                                      v_amtemp    := v_amtedo;
                                      v_amtsp     := v_amtedosp;
                                      --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 3 then
                                      v_amtchedu := v_num_child_edu * v_amtchlda;
                                      begin
                                          select amtdemax into v_amtdemax
                                            from tdeductd
                                           where dteyreff = (select max(dteyreff)
                                                               from tdeductd
                                                              where dteyreff <= p_dteyrepay - p_zyear
                                                                and coddeduct = r_ttaxcodd.coddeduct
                                                                and codcompy = indx_codcompy)
                                             and coddeduct = r_ttaxcodd.coddeduct
                                             and codcompy = indx_codcompy;
                                      exception when others then
                                          v_amtdemax := v_amtchedu;
                                      end;
                                      v_amtchedu := least(nvl(v_amtchedu,0),nvl(v_amtdemax,999999999999));
                                      --
                                      v_sumdedall := v_sumdedall + v_amtchedu; ----
                                    elsif r_ttaxcodd.numseq = 2 then
                                      v_amtchned := v_num_child_ned * v_amtchldb;
                                      begin
                                          select amtdemax into v_amtdemax
                                            from tdeductd
                                           where dteyreff = (select max(dteyreff)
                                                               from tdeductd
                                                              where dteyreff <= p_dteyrepay - p_zyear
                                                                and coddeduct = r_ttaxcodd.coddeduct
                                                                and codcompy = indx_codcompy)
                                             and coddeduct = r_ttaxcodd.coddeduct
                                             and codcompy = indx_codcompy;
                                      exception when others then
                                          v_amtdemax := v_amtchned;
                                      end;
                                      v_amtchned := least(nvl(v_amtchned,0),nvl(v_amtdemax,999999999999));
                                      --
                                      v_sumdedall := v_sumdedall + v_amtchned; ----
                                    elsif r_ttaxcodd.numseq = 4 then
                                      if v_numofidf is not null or nvl(v_amtedo,0) > 0 then
                                        v_amtfathr := v_amtedo;
                                        --
                                        v_sumdedall := v_sumdedall + v_amtfathr; ----
                                      end if;
                                      if v_numfasp is not null or nvl(v_amtedosp,0) > 0 then
                                        v_amtfasp  := v_amtedosp;
                                        --
                                        v_sumdedall := v_sumdedall + v_amtfasp; ----
                                      end if;
                                    elsif r_ttaxcodd.numseq = 5 then
                                        v_amtmothr := v_amtedo;
                                        v_amtmosp  := v_amtedosp;
                                        --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 6 then
                                        v_amtmai		:= nvl(v_amtedo,0) + nvl(v_amtedosp,0);  --(maimed)
                                        --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 7 then
                                        -- Father (Emp)
                                        if v_check = 'D008' then
                                            v_amtinsufhr    := v_amtedo + v_amtinsufhr;
                                            v_amtinsufm     := v_amtedo + v_amtinsufm;
                                        end if;
                                        -- Father (Spouse)
                                        if v_check = 'D008' then
                                            v_amtinsufsp    := v_amtedosp + v_amtinsufsp;
                                            v_amtinsufm     := v_amtedosp + v_amtinsufm;
                                        end if;
                                        -- Mother (Emp)
                                        if v_check = 'D009' then
                                            v_amtinsumhr	:= v_amtedo + v_amtinsumhr;
                                            v_amtinsufm     := v_amtedo + v_amtinsufm;
                                        end if;
                                        -- Mother (Spouse)
                                        if v_check = 'D009' then
                                            v_amtinsumsp    := v_amtedosp + v_amtinsumsp;
                                            v_amtinsufm     := v_amtedosp + v_amtinsufm;
                                        end if;
                                        --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 8 then 
                                        v_insu          := nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                                        begin
                                            select amtdemax into v_amtdemax
                                              from tdeductd
                                             where dteyreff = (select max(dteyreff)
                                                                 from tdeductd
                                                                where dteyreff <= p_dteyrepay - p_zyear
                                                                  and coddeduct = r_ttaxcodd.coddeduct
                                                                  and codcompy = indx_codcompy)
                                               and coddeduct = r_ttaxcodd.coddeduct
                                               and codcompy = indx_codcompy;
                                        exception when others then
                                            v_amtdemax := v_insu;
                                        end;
                                        v_insu := least(nvl(v_insu,0),nvl(v_amtdemax,999999999999));
                                        --
                                      v_sumdedall := v_sumdedall + v_insu; ----
                                    elsif r_ttaxcodd.numseq = 9 then
                                        v_amtinsu		:= v_amtedo;
                                        v_amtinsp		:= v_amtedosp;
                                        --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 10 then
                                        v_amtpens		:= nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                                        --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 11 then
                                        v_amtdedpf1		:= nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                                        --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 12 then
                                        v_amtssf		:= nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                                        --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 13 then --RMF
                                        v_amtrmf := nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                                        --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 14 then --LTF ----||--RMF
                                        v_amtpens := nvl(v_amtedo,0) + nvl(v_amtedosp,0);  --????????????????????????(pension)
                                        v_amtltf := nvl(v_amtedo,0) + nvl(v_amtedosp,0);  --????????????????????????(pension)
                                        --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 15 then --Loan interest of House hire purchase ----||--LTF
                                        v_loinhouse := nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                                        --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 16 then
                                        v_amthouse	:= nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                                        --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 18 then --Travel
                                      v_amttrav := nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                                      --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 19 then --Pregnant
                                      v_amtpreg := nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                                      --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 21 then --Wheel
                                      v_amtwheel := nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                                      v_amtproduc := v_amtproduc + v_amtwheel;
                                      --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 22 then --Book
                                      v_amtbook := nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                                      v_amtproduc := v_amtproduc + v_amtbook;
                                      --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
                                    elsif r_ttaxcodd.numseq = 23 then --Otop
                                      v_amtotop := nvl(v_amtedo,0) + nvl(v_amtedosp,0);
                                      v_amtproduc := v_amtproduc + v_amtotop;
                                      --
                                      v_sumdedall := v_sumdedall + nvl(v_amtedo,0) + nvl(v_amtedosp,0); ----
--                                    elsif r_ttaxcodd.numseq in (24,25,26) then
--                                      null;
--                                    elsif r_ttaxcodd.numseq = 52 then -- ?????????????????? 190,000 ???????????????????? 65
--                                        v_amte65under	:= v_amtedo;
--                                    elsif r_ttaxcodd.numseq = 54 then -- ??????? ???????????? 190,000 ???????????????????? 65
--                                        v_amts65under	:= v_amtedosp;
                                    end if;
                                    exit;
                                end if;
                            
                            if get_deduct(v_check) = 'D' then
                              v_amtoths := nvl(v_amtoths,0) + (v_amtedo + v_amtedosp);
                            end if;
                            
                            end loop;

--                            if instr(p_coddeduct,v_check) = 0 and get_deduct(v_check) = 'D' then
--                                v_amtoths := nvl(v_amtoths,0) + (v_amtedo + v_amtedosp);
--                            end if;
                        end if;
                        v_formula := replace(v_formula,'['||v_check||']',v_amt);
                    end loop;
                    v_formula := to_char(v_amt);
                end if;

                if instr(v_formula,'}') > 1 then
                    loop --- ??????????? ????????? ????????? seq
                        v_check := substr(v_formula,instr(v_formula,'{') +5,(instr(v_formula,'}') -1) - instr(v_formula,'{')-4);
                    exit when v_check is null;
                        v_formula := replace(v_formula,'{item'||v_check||'}',v_text(v_check));
                    end loop;
                    v_amt := greatest(execute_sql('select '||v_formula||' from dual'),0);
                end if;
                ---- check ????????? ???????? ??????
                if v_formula <> '0' then
                    if r_emp.typtax = '1' then -- ???????????
                        v_fmlmax := r_proctax.fmlmax;
                    else
                        v_fmlmax := r_proctax.fmlmaxtot;
                    end if;
                    if v_fmlmax is not null then
                        v_amt := greatest(execute_sql('select '||v_formula||' from dual'),0);
                        begin
                            v_chknum := nvl(to_number(v_fmlmax),0);   --????????????????
                            if v_chknum > 0 then
                                v_amt := to_char(least(v_amt,v_chknum));
                                v_formula := v_amt;
                            end if;
                        exception when others then  --- ??????? formula
                            if instr(v_fmlmax,'[') > 0 then
                                loop --- ??????????? ????????? ????????? codededuct
                                    v_check  := substr(v_fmlmax,instr(v_fmlmax,'[') +1,(instr(v_fmlmax,']') -1) - instr(v_fmlmax,'['));
                                exit when v_check is null;
                                    if get_deduct(v_check) = 'E' then
                                        v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(evalue_code(substr(v_check,2)),0));
                                    elsif get_deduct(v_check) = 'D' then
                                        v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(dvalue_code(substr(v_check,2)),0));
                                    else
                                        v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(ovalue_code(substr(v_check,2)),0));
                                    end if;
                                end loop;
                            end if;
                            if instr(v_fmlmax,'{') > 0 then
                                loop --- ??????????? ????????? ????????? seq
                                    v_check     := substr(v_fmlmax,instr(v_fmlmax,'{') +5,(instr(v_fmlmax,'}') -1) - instr(v_fmlmax,'{')-4);
                                exit when v_check is null;
                                    v_fmlmax    := replace(v_fmlmax,'{item'||v_check||'}',v_text(v_check));
                                end loop;
                            end if;
                            v_chknum    := execute_sql('select '||v_fmlmax||' from dual');
                            v_amt       := to_char(least(v_amt,v_chknum));
                            v_formula   := v_amt;
                        end;
                    end if; --end if of check v_fmlmax is not null
                end if;
            end if;
        end if; --- end if of 1. ????????????????????????????????
      v_amtfml(r_proctax.numseq) := v_amt;
      if r_proctax.numseq = 6 then --Deduct Row in Page 2
        v_amtfml(r_proctax.numseq) := v_sumdedall; ----
      end if;
      v_text(r_proctax.numseq) := '('||v_formula||')';
      if r_proctax.numseq = 12 then
        cal_amttax(v_amt,'1',0,v_taxa,indx_codcompy,v_amttax);
--                    cal_amttax(400000,'1',0,v_taxa,indx_codcompy,v_amttax);
      end if;
      v_maxseq := r_proctax.numseq;
    end loop;

    if v_maxseq > 0 then
      v_amtfml(v_maxseq + 1) := v_amttax;
      v_amt := nvl(r_emp.amttaxt,0) + nvl(r_emp.amttaxbf,0)+v_amttaxbf_last;   --<< add user25 Thanittha : 20/03/2018 : STA4610064
      if r_emp.typtax = '2' and r_emp.stamarry = 'M' then
        v_amt := v_amt + nvl(r_emp.amttaxsp,0);
      end if;
      v_amtfml(v_maxseq + 2) := v_amt;
    end if;
    if v_amt >= v_amttax then
      v_tax1 := v_amt - v_amttax;
      v_tax2 := 0;
    else
      v_tax1 := 0;
      v_tax2 := v_amttax - v_amt;
    end if;
    if r_emp.numoffid = r_emp.numtaxid then
      v_numtaxid := null;
    else
      v_numtaxid := nvl(substr(r_emp.numtaxid,1,10),' ');
    end if;
    --------------------------------------------------------------
    -- >> Error : STD9580130 || User39 || 25/11/2015
    
    --<<User37 29/04/2016
    v_dteyrrelf	:= null;
    v_dteyrrelt	:= null;
    if r_emp.dteyrrelf is not null then
      if to_number(to_char(sysdate,'yyyy')) > 2400 then --?.?
        if r_emp.dteyrrelf > 2400 and nvl(r_emp.dteyrrelt,r_emp.dteyrrelf) > 2400 then
          v_dteyrrelf	:= r_emp.dteyrrelf;
          v_dteyrrelt	:= nvl(r_emp.dteyrrelt,r_emp.dteyrrelf);
        else
          v_dteyrrelf	:= r_emp.dteyrrelf+543;
          v_dteyrrelt	:= nvl(r_emp.dteyrrelt,r_emp.dteyrrelf)+543;
        end if;
      else
        if r_emp.dteyrrelf > 2400 and nvl(r_emp.dteyrrelt,r_emp.dteyrrelf) > 2400 then --?.?
          v_dteyrrelf	:= r_emp.dteyrrelf-543;
          v_dteyrrelt	:= nvl(r_emp.dteyrrelt,r_emp.dteyrrelf)-543;
        else
          v_dteyrrelf	:= r_emp.dteyrrelf;
          v_dteyrrelt	:= nvl(r_emp.dteyrrelt,r_emp.dteyrrelf);
        end if;
      end if;
      -- ???? ( ?)
      if r_emp.dteyrrelf >= 2015  then
        if (p_dteyrepay - p_zyear) between r_emp.dteyrrelf and r_emp.dteyrrelt then
            v_house			:= r_emp.amtrelas;
            v_amthouse	    := v_amthouse;
        else
            v_house		    := 0;
            v_amthouse	    := 0;
        end if;
      else
        v_house			    := 0;
        v_amthouse	        := 0;
      end if;
      -- ???? ( ?)
      if r_emp.dteyrrelf < 2015  then
        if (p_dteyrepay - p_zyear) between r_emp.dteyrrelf and r_emp.dteyrrelt  then
            null;
        else
            v_amttaxrel	:= 0;
            v_amtrelas	:= 0;
        end if;
      else
        v_amttaxrel	:= 0;
        v_amtrelas	:= 0;
      end if;
    end if;
    
    if nvl(v_amtfml(13),0) > v_amttaxrel then
      v_amtfml(15) := nvl(v_amtfml(13),0) - v_amttaxrel;
    else
      v_amtfml(15) := 0;
    end if;
    
    v_amtfml(16) := v_amtfml(15) - v_amtfml(14);
    if v_amtfml(16) > 0 then
      v_payincrease := 'Y';
    elsif v_amtfml(16) < 0 then
      v_payover := 'Y';
    end if;
    v_amtfml(16) := abs(v_amtfml(16));
    
    begin
      select nvl(amtdemax,0)
        into v_amtdemax008
        from tdeductd
       where dteyreff = (select max(dteyreff)
                           from tdeductd
                          where dteyreff <= p_dteyrepay - p_zyear
                            and coddeduct = 'D008'
                            and codcompy = indx_codcompy)
         and coddeduct = 'D008'
         and codcompy = indx_codcompy;
    exception when others then
      v_amtdemax008   := 0;
    end;
    if nvl(v_amtinsufhr,0)+nvl(v_amtinsumhr,0) > v_amtdemax008 then
      v_amtcute       := (nvl(v_amtinsufhr,0)+nvl(v_amtinsumhr,0))-v_amtdemax008;
    else
      v_amtcute       := 0;
    end if;
    if nvl(v_amtinsufsp,0)+nvl(v_amtinsumsp,0) > v_amtdemax008 then
      v_amtcuts       := (nvl(v_amtinsufsp,0)+nvl(v_amtinsufsp,0))-v_amtdemax008;
    else
      v_amtcuts       := 0;
    end if;
    -->>
    v_amtcute   := 0;
    v_amtcuts   := 0;
    v_numseq    := v_numseq + 1;
    
    insert into ttemprpt (codempid,codapp,numseq,
                          item1,item2,item3,item4,item5,item6,
                          item7,item8,item9,item10,item11,item12,
                          -----------
                          item20,item21,item22,item23,
                          item24,item25,item26,item27,item28,
                          item29,item30,
                          -----------
                          temp80,temp32,
                          -----------
                          item31,
                          -----------
                          temp33,
                          temp34,temp35,temp36,temp37,temp38,temp39,
                          temp40,temp41,temp42,temp43,temp44,temp45,temp46,
                          temp47,temp48,temp49,temp50,temp51,temp52,
                          temp53,temp54,
                          -----------
                          item32,-- amt 15000
                          temp55,-- money 15000
                          item33,-- amt 17000
                          temp56,-- money 17000
    
                          item34,temp57,
                          item35,temp58,
                          item36,temp59,
                          item37,temp60,
    
                          item38,
                          item39,
                          item40,
                          item41,
                          temp61,
                          -- X1
                          temp62,
                          temp63,temp64,temp65,temp66, temp67,
    
                          item50,temp68,
                          temp69, --NO.12 change to NO.13 Travel
                          temp70,
                          temp71,temp72,
    
                          item71,item72,item73, -- >> Error : STD9580130 || User39 || 25/11/2015
                          item74,item75,item76,  -- >> Error : STD9580130 || User39 || 25/11/2015
                          item77,
                          item81,item82,item83,
                          item84,item85,
    
                          temp77,temp78,temp79,-->>User37 29/04/2016
                          temp81, temp82,
                          item78, item79
                          --<<12/05/2021 temp83 to temp93
                          ,
                          temp83,temp84,
                          temp85,temp86,temp87,
                          temp88,temp89,temp90,
                          temp91,temp92,temp93
    
                          ,item100 --for test time
                          -->>
                        )
    values (global_v_codempid,'HRPY95R5',v_numseq ,
            --- item1 to item12 ---
            (p_dteyrepay + 543 - p_zyear),rpad(r_emp.numoffid,13,'-'),to_char(r_emp.dteempdb,'dd'),
            get_nammthful(to_char(r_emp.dteempdb,'mm'),p_lang),
            (to_char(r_emp.dteempdb,'yyyy') + 543 - p_zyear),
            v_numtaxid,r_emp.namfirstt,r_emp.namlastt,r_emp.adrcontt,
            r_emp.dessubdistc,r_emp.desdistc,r_emp.desprovc,
            -----------------------
            --- item20 to item30 ---
            rpad(r_emp.codpostc,5,'-'),r_emp.numtelec,null,r_emp.stamarry,
            to_char(v_dtespbd,'dd'),
            decode(v_dtespbd,null,null,get_nammthful(to_char(v_dtespbd,'mm'),p_lang)),
            (to_char(v_dtespbd,'yyyy') + 543 - p_zyear),v_numoffsp,v_numtaxsp,
            v_firstsp,v_lastsp,
            ------------------------
            --- temp30 to temp31---
            v_tax2,v_tax1,
            ------------------------
            --- item31 ---
            rpad(v_numcotax,13,'-'),
            --- temp33 to temp54 ---
            v_amtfml(1),
            v_amtfml(2),v_amtfml(3),v_amtfml(4),v_amtfml(5),v_amtfml(6),v_amtfml(7),
            v_amtfml(8),v_amtfml(9),v_amtfml(10),v_amtfml(11),v_amtfml(12),v_amtfml(13),v_amtfml(14),
            -- << user4 19/12/2012 STA25502078
            v_amtdedpf2,v_amtgpf,v_amtteacher,v_amte65above,v_amts65above,v_amtcompens,
            -- >> user4 19/12/2012 STA25502078
            v_amtemp,v_amtsp,
            ------------------------
            v_num_child_ned, --item32,[childrn born before 2561]
            v_amtchedu , ----v_amtchned , --temp55,
            v_num_child_edu, --item33,[childrn born since 2561]
            v_amtchned , ----v_amtchedu ,--temp56
    
            ------------------------
            --- item34,temp57,
            decode(v_amtfathr,0,null,v_numofidf),	v_amtfathr,
            --- item35,temp58,
            decode(v_amtmothr,0,null,v_numofidm),	v_amtmothr,
            --- item36,temp59,
            decode(v_amtfasp,0,null,v_numfasp)  ,	v_amtfasp,
            --- item37,temp60,
            decode(v_amtmosp,0,null,v_nummosp)  ,	v_amtmosp,
            --PAN-590450
            decode(v_amtinsufhr,0,null,v_numofidf), -- item38
            decode(v_amtinsumhr,0,null,v_numofidm), -- item39
            decode(v_amtinsufsp,0,null,v_numfasp), -- item40
            decode(v_amtinsumsp,0,null,v_nummosp), -- item41
            -- X
            v_amtinsufm-v_amtcute-v_amtcuts,-- temp61 user37 16/06/2016 v_amtinsufm
            -- X1
            v_insu,-- temp62 User37  10/05/2016 (v_amtinsu + v_amtinsp),
            --- temp63 to temp67 ---
            v_amtdedpf1,v_amtrmf,v_amtltf,nvl(v_loinhouse,0) ----(v_amtint+v_amthou)
            , v_amtsocyr,
            --- item50,temp68 ---
            r_emp.codempid,v_amtmai,
    --                    r_emp.codempid,68,
            --- temp69 to temp72 ---
            v_amttrav, v_amtpens, v_amttaxrel,v_amtrelas,
            --- item71 to item77 ---
            v_offid_chned(1),v_offid_chned(2),v_offid_chned(3),  -- >> Error : STD9580130 || User39 || 25/11/2015
            v_offid_chned(4),v_offid_chned(5),v_offid_chned(6),   -- >> Error : STD9580130 || User39 || 25/11/2015
            v_offid_chned(7),
            --- item81 to item85 ---
            v_offid_chedu(1),v_offid_chedu(2),v_offid_chedu(3),
            v_offid_chedu(4),v_offid_chedu(5),
            --- temp77 to temp79 ---
            v_amthouse,nvl(v_house,0),v_amtproduc,-->>User37 29/04/2016
            v_amtfml(15),v_amtfml(16),
            v_payincrease,v_payover
            --<<12/05/2021 temp83 to temp93
            ,
            nvl((v_amtinsu + v_amtinsp),0),nvl(v_amtssf,0),
            0,0,nvl(v_amttrav,0),
            0,nvl(v_amtpreg,0),0,
            nvl(v_amtwheel,0),nvl(v_amtbook,0),nvl(v_amtotop,0)
    
            ,to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')
            -->>
        );
      end if; -- secur
      <<loop_next>>
      null;
    end loop; -- for c_emp

    commit;
    if not v_exist then
      p_exit  := 'N' ;
    elsif not v_secur then
      p_secur := 'N' ;
    end if;
  end;

  procedure del_temp (v_codapp varchar2,v_coduser varchar2) is
  begin
    delete ttemprpt
     where codapp   = upper(v_codapp) and
           codempid = upper(v_coduser) ;
    delete ttempprm
     where codapp   = upper(v_codapp) and
           codempid = upper(v_coduser) ;
    commit;
  end;

  procedure cal_amtnet (p_amtincom  in number,
                        p_amtsalyr  in number,  -- ?????????????????
                        p_amtproyr	in number,  -- ???????????????????? (??? Estimate)
                        p_amtsocyr  in number,  -- ????????????????????? (??? Estimate)
                        p_amtnet	  out number) is
    v_formula 		varchar2(1000);
    v_fmlmax 			varchar2(1000);
    v_check 			varchar2(100);
    v_maxseq 			number(3);
    v_chknum			number(20);
    v_amt					number;
    v_stmt		 		varchar2(2000);
    cursor c_proctax is
      select numseq,formula,fmlmax,fmlmaxtot,desproce,desproct,desproc3,desproc4,desproc5
        from tproctax
       where dteyreff = (select max(dteyreff)
                           from tproctax
                          where dteyreff <= indx_dteyrepay - para_zyear and codcompy = indx_codcompy)
         and codcompy = indx_codcompy
       order by numseq;
  begin

    p_amtnet := p_amtincom;
    for r_proctax in c_proctax loop
      if r_proctax.numseq = 1 then  		------- 1. ????????????????????????????????
        v_formula := to_char(p_amtincom);
      else
        if  r_proctax.formula is not null then
          v_formula := r_proctax.formula;
          v_amt := 0;
          if instr(v_formula,'[') > 0 then
            loop 	--- ??????????? ????????? ???????????????????/???????
              v_check := substr(v_formula,instr(v_formula,'[') +1,(instr(v_formula,']') -1) - instr(v_formula,'['));
            exit when v_check is null;
              if v_check in ('E001','D001') then --- ????????????????????????????
                v_amt := gtempded(tep1_codempid,v_check,'1',p_amtproyr,p_amtsalyr);
              elsif v_check = 'D002' then --- ?????????????????????????
                v_amt := gtempded(tep1_codempid,v_check,'1',p_amtsocyr,p_amtsalyr);
              else
                v_amt := gtempded(tep1_codempid,v_check,'1',0,p_amtsalyr);
                if tep1_stamarry = 'M' and tep3_typtax  = '2' then
                  v_amt := v_amt + gtempded(tep1_codempid,v_check,'2',0,tep3_amtincsp);
                end if;
              end if;
              v_formula := replace(v_formula,'['||v_check||']',v_amt);
            end loop;
            v_formula := greatest(execute_sql('select '||v_formula||' from dual'),0);
          end if;
          if instr(v_formula,'}') > 1 then
            loop --- ??????????? ????????? ????????? seq
              v_check := substr(v_formula,instr(v_formula,'{') +5,(instr(v_formula,'}') -1) - instr(v_formula,'{')-4);
            exit when v_check is null;
              v_formula := replace(v_formula,'{item'||v_check||'}',v_text(v_check));
            end loop;
          end if;
              ---- check ????????? ???????? ??????
          if v_formula <> '0' then
            if tep3_typtax = '1' then -- ???????????
               v_fmlmax := r_proctax.fmlmax;
            else
               v_fmlmax := r_proctax.fmlmaxtot;
            end if;
            if v_fmlmax is not null then
               v_amt := greatest(execute_sql('select '||v_formula||' from dual'),0);
               begin
                v_chknum := nvl(to_number(v_fmlmax),0);   --????????????????
                if v_chknum > 0 then
                   v_formula := to_char(least(v_amt,v_chknum));
                end if;
               exception when others then  --- ??????? formula
                if instr(v_fmlmax,'[') > 0 then
                  loop --- ??????????? ????????? ????????? codededuct
                    v_check  := substr(v_fmlmax,instr(v_fmlmax,'[') +1,(instr(v_fmlmax,']') -1) - instr(v_fmlmax,'['));
                  exit when v_check is null;
                    if get_deduct(v_check) = 'E' then
                      v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(evalue_code(substr(v_check,2)),0));
                    elsif get_deduct(v_check) = 'D' then
                      v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(dvalue_code(substr(v_check,2)),0));
                    else
                      v_fmlmax := replace(v_fmlmax,'['||v_check||']',nvl(ovalue_code(substr(v_check,2)),0));
                    end if;
                  end loop;
                end if;
                if instr(v_fmlmax,'{') > 0 then
                  loop --- ??????????? ????????? ????????? seq
                    v_check := substr(v_fmlmax,instr(v_fmlmax,'{') +5,(instr(v_fmlmax,'}') -1) - instr(v_fmlmax,'{')-4);
                  exit when v_check is null;
                    v_fmlmax := replace(v_fmlmax,'{item'||v_check||'}',v_text(v_check));
                  end loop;
                end if;
                v_chknum := execute_sql('select '||v_fmlmax||' from dual');
                v_formula := to_char(least(v_amt,v_chknum));
               end;
               if r_proctax.numseq = 4 then
                  v_amtexp := to_number(v_formula);
                  v_maxexp := v_chknum;
               else
                  if v_formula = v_chknum then
                     v_amtexp := null;
                  end if;
               end if;
              end if; --end if of check v_fmlmax is not null
            end if;
          end if;
        end if; --- end if of 1. ????????????????????????????????
        v_text(r_proctax.numseq) := '('||v_formula||')';
        v_maxseq := r_proctax.numseq;
        v_amt := execute_sql('select '||v_text(r_proctax.numseq)||' from dual');

      end loop;

      v_stmt := v_text(v_maxseq);
      p_amtnet := execute_sql('select '||v_stmt||' from dual');
      v_amtdiff := p_amtincom - p_amtnet;
  --	end if;
  end;

  PROCEDURE cal_amttax (p_amtnet 	   number,
                        p_flgtax		 varchar2, --1 ??? ? ???????, 2 ?.??????
                        p_sumtax  	 number,
                        p_taxa  		 number,
                        p_codcompy   varchar2,
                        p_amttax  out	 number) IS

    v_dteyreff 	number;
    v_amtcal 		number;
    v_numseq 		number;
    v_amt 			number;
    v_tax1 			number := 0;
    v_tax2 			number := 0;
    cursor c_ttaxinf is
      select numseq,amtsalst,amtsalen,pcttax,nvl(amtacccal,0) amtacccal
        from ttaxinf
       where typincom = '1'
         and codcompy = p_codcompy
         and dteyreff = (select max(dteyreff)
                          from ttaxinf
                         where typincom = '1'
                           and codcompy = p_codcompy
                           and dteyreff <= indx_dteyrepay - para_zyear)
         and p_amtnet between amtsalst and amtsalen;

    cursor c_ttaxinf2 is
      select numseq,amtsalst,pcttax,nvl(amtacccal,0) amtacccal
        from ttaxinf
       where typincom  = '1'
         and codcompy = p_codcompy
         and dteyreff = (select max(dteyreff)
                           from ttaxinf
                          where typincom = '1'
                            and codcompy = p_codcompy
                            and dteyreff <= indx_dteyrepay - para_zyear)
         and v_amt between amtsalst and amtsalen;
  BEGIN
  
    p_amttax := 0;
    if p_amtnet > 0 then
      for r1 in c_ttaxinf loop
        v_numseq := r1.numseq;
        v_amtcal :=	p_amtnet - r1.amtsalst + 1;
        if p_flgtax = '1' then
          p_amttax 	:= round(v_amtcal * r1.pcttax / 100,2) + r1.amtacccal;
        else
          p_amttax 	:= (p_sumtax * r1.pcttax / 100) /	(1 - (r1.pcttax / 100));
          p_amttax  := p_amttax + p_sumtax;
          v_amt 		:= p_amtnet + p_amttax;
          if v_amt not between r1.amtsalst and r1.amtsalen then
            for r2 in c_ttaxinf2 loop
              v_amtcal :=	p_amtnet - r2.amtsalst + 1;
              v_tax1   := (v_amtcal * r2.pcttax / 100) + r2.amtacccal;
              v_tax2   := v_tax1 - p_taxa;
              p_amttax :=	(v_tax2 * r2.pcttax / 100) / (1 - (r2.pcttax / 100));
              p_amttax := p_amttax + v_tax2;
            end loop;
          end if;
        end if;
      end loop;
    end if;
  END;
  
    FUNCTION gtempded (v_empid 			varchar2,
                       v_codeduct 	varchar2,
                       v_type 			varchar2,
                       v_amtcode 		number,
                       p_amtsalyr 	number) RETURN number IS

    v_amtdeduct 	number(14,2);
--    v_amtreturn 	number(14,2);
    v_amtdemax		tdeductd.amtdemax%type;
    v_pctdemax		tdeductd.pctdemax%type;
    v_formula			tdeductd.formula%type;
    v_pctamt 			number(14,2);
    v_check  			varchar2(20);
    v_typeded  		varchar2(1);
    v_chk_tlast   number ;
  BEGIN

    v_amtdeduct := v_amtcode;
    if v_amtdeduct = 0 then null;
      /*if indx_dteyrepay < to_number(to_char(sysdate,'yyyy')) then
        --<<user19 11/01/2017
        begin
          select count(codempid) into v_chk_tlast
            from 	tlastempd
           where  dteyrepay = indx_dteyrepay - para_zyear -- :parameter.dteyrepay
             and	codempid  = v_empid ;
        exception when others then
          v_chk_tlast := 0;
        end;
        if v_chk_tlast > 0 then
            begin
              select decode(v_type,'1',stddec(amtdeduct,codempid,para_chken),stddec(amtspded,codempid,para_chken))
                into 	v_amtdeduct
                from 	tlastempd
               where  dteyrepay = indx_dteyrepay - para_zyear
                 and	codempid  = v_empid
                 and 	coddeduct = v_codeduct;
            exception when others then
              v_amtdeduct := 0;
            end;
        else
            begin
              select decode(v_type,'1',stddec(amtdeduct,codempid,para_chken),stddec(amtspded,codempid,para_chken))
                into v_amtdeduct
                from tempded
               where codempid = v_empid
                 and coddeduct = v_codeduct;
            exception when others then
              v_amtdeduct := 0;
            end;
        end if;
        -->> user19 11/01/2017
      else
        begin
          select decode(v_type,'1',stddec(amtdeduct,codempid,para_chken),stddec(amtspded,codempid,para_chken))
          into v_amtdeduct
          from tempded
          where codempid = v_empid
            and coddeduct = v_codeduct;
        exception when others then
          v_amtdeduct := 0;
        end;
      end if;*/
      if indx_dteyrepay < to_number(to_char(sysdate,'yyyy')) then
            begin
              select decode(v_type,'1',stddec(amtdeduct,codempid,para_chken),stddec(amtspded,codempid,para_chken))
                into 	v_amtdeduct
                from 	tlastempd
               where  dteyrepay = indx_dteyrepay - para_zyear
                 and	codempid  = v_empid
                 and 	coddeduct = v_codeduct;
            exception when others then
              v_amtdeduct := 0;
            end;
        else
            begin
              select decode(v_type,'1',stddec(amtdeduct,codempid,para_chken),stddec(amtspded,codempid,para_chken))
                into v_amtdeduct
                from tempded
               where codempid = v_empid
                 and coddeduct = v_codeduct;
            exception when others then
              v_amtdeduct := 0;
            end;
        end if;      
    end if;  --end if  v_amtdeduct = 0
    
    if v_amtdeduct > 0 then
      begin
        select amtdemax, pctdemax, formula
        into v_amtdemax, v_pctdemax, v_formula
        from tdeductd
        where dteyreff = (select max(dteyreff)
                          from tdeductd
                          where dteyreff <= indx_dteyrepay - para_zyear
                          and coddeduct = v_codeduct
                          and codcompy = indx_codcompy)
          and coddeduct = v_codeduct
          and codcompy = indx_codcompy;
      exception when others then
        v_amtdemax := null;
        v_pctdemax := null;
        v_formula := null;
      end;
      ------ Check amt max
      if (v_amtdemax > 0) then
        if v_codeduct = 'E001' then ---- ????????????????????????????
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
          loop --- ??????????? ????????? ????????? seq
            v_check  := substr(v_formula,instr(v_formula,'[') +1,(instr(v_formula,']') -1) - instr(v_formula,'['));
            exit when v_check is null;
            --<<add as py91b----
            --
            begin
              if get_deduct(v_check) = 'E' then
                evalue_code(substr(v_check,2))  := evalue_code(substr(v_check,2));
              elsif get_deduct(v_check) = 'D' then
                dvalue_code(substr(v_check,2))  := dvalue_code(substr(v_check,2));
              else
                ovalue_code(substr(v_check,2))  := ovalue_code(substr(v_check,2));
              end if; 
            exception when no_data_found then
              if get_deduct(v_check) = 'E' then
                evalue_code(substr(v_check,2))  := null;
              elsif get_deduct(v_check) = 'D' then
                dvalue_code(substr(v_check,2))  := null;
              else
                ovalue_code(substr(v_check,2))  := null;
              end if;
            end;             
            --   
            if get_deduct(v_check) = 'E' then
              v_formula := replace(v_formula,'{['||v_check||']}',nvl(evalue_code(substr(v_check,2)),0));
            elsif get_deduct(v_check) = 'D' then
              v_formula := replace(v_formula,'{['||v_check||']}',nvl(dvalue_code(substr(v_check,2)),0));
            else
              v_formula := replace(v_formula,'{['||v_check||']}',nvl(ovalue_code(substr(v_check,2)),0));
            end if;
           
          end loop;
          v_amtdeduct := least(v_amtdeduct,execute_sql('select '||v_formula||' from dual'));        
        end if;
      end if;
    end if;
    v_typeded := get_deduct(v_codeduct);
    if v_type = '1' then
        if v_typeded = 'E' then
          evalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
        elsif v_typeded = 'D' then
          dvalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
        else
          ovalue_code(substr(v_codeduct,2)) := nvl(v_amtdeduct,0);
        end if;
--        v_amtreturn := nvl(v_amtdeduct,0);
    else --v_type = '2'
        if v_typeded = 'E' then
          evalue_code(substr(v_codeduct,2)) := nvl(evalue_code(substr(v_codeduct,2)),0) + nvl(v_amtdeduct,0);
--          v_amtreturn := evalue_code(substr(v_codeduct,2));
        elsif v_typeded = 'D' then
          dvalue_code(substr(v_codeduct,2)) := nvl(dvalue_code(substr(v_codeduct,2)),0) + nvl(v_amtdeduct,0);
--          v_amtreturn := dvalue_code(substr(v_codeduct,2));
        else
          ovalue_code(substr(v_codeduct,2)) := nvl(ovalue_code(substr(v_codeduct,2)),0) + nvl(v_amtdeduct,0);
--          v_amtreturn := ovalue_code(substr(v_codeduct,2));
        end if;
    end if;
     
    return 	----v_amtreturn; 
    nvl(v_amtdeduct,0);
  end;

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

  FUNCTION Execute_Sql (p_stmt in varchar2) RETURN number IS
     v_amt 		number;
  BEGIN
      execute immediate p_Stmt into v_amt;
         return v_amt;
      exception when others then
         return 0;
  end;

  procedure ins_temp  (p_codapp			in varchar2,
                       p_numseq			in number,
                       p_codempid		in varchar2,
                       p_namemp			in varchar2,
                       p_numtaxid		in varchar2,
                       p_desmarry		in varchar2,
                       p_destyptax	in varchar2,
                       p_code				in varchar2,
                       p_desc				in varchar2,
                       p_amt				in varchar2) is
  begin
    insert into ttemprpt
      (codempid,codapp,numseq,
       item1,item2,item3,item4,
       item5,item6,item7,temp31)
    values
      (para_coduser,p_codapp,p_numseq,
       indx_dteyrepay,p_codempid||'   '||p_namemp,p_numtaxid,p_desmarry,
       p_destyptax,p_code,p_desc,p_amt);
  end;

  procedure tspouse_name      (p_namspous in varchar2,
                               p_codsex   in varchar2,
                               p_titlesp out varchar2,
                               p_firstsp out varchar2,
                               p_lastsp  out varchar2) IS
	v_text varchar2(4000);
  BEGIN
    if p_namspous is not null then
      if substr(p_namspous,1,3) = '???' then
        p_titlesp := '???';
      elsif substr(p_namspous,1,6) = '??????' then
        p_titlesp := '??????';
      elsif substr(p_namspous,1,3) = '???' then
        p_titlesp := '???';
      else
        if p_codsex = 'M' then
          p_titlesp := '???';
        else
          p_titlesp := '???';
        end if;
      end if;
      v_text 		:= ltrim(replace(p_namspous,p_titlesp,null));
      if instr(v_text,' ') > 0 then
        p_firstsp := substr(v_text,1,instr(v_text,' ') - 1);
        v_text 		:= ltrim(replace(v_text,p_firstsp,null));
        p_lastsp  := nvl(ltrim(v_text),' ');
      else
        p_firstsp := v_text;
        p_lastsp  := ' ';
      end if;
    else
      p_titlesp := ' ';
      p_firstsp := ' ';
      p_lastsp  := ' ';
    end if;
  end;
end hrpy95r_batch;

/

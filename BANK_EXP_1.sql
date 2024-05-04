--------------------------------------------------------
--  DDL for Package Body BANK_EXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "BANK_EXP" IS
/* Cust-Modify: KOHU */
-- last update: 10/02/2023 12:00
-- last update: 30/09/2020 20:30
-- last update: 06/08/2021 : Add 32 . BBL (WEB)
   PROCEDURE HEAD(p_bank				in number,
  							  p_codbkserv 	in varchar2,
  							  p_numacct 		in varchar2,
  							  p_codcomp			in varchar2,
  							  p_totamt			in number,
  							  p_totemp			in number,
  							  p_dtepaymt	  in date,
                  p_dtetran			in date,
  							  p_global			in number,
  							  p_codlang			in varchar2,
  							  p_text				out varchar2,
  							  p_rec					out number) is

	    v_codbkserv				varchar2(10);
	    v_numacct					varchar2(14);
	    v_codmedia        varchar2(3);
      v_date				    varchar2(20);
      v_numcotax  	    varchar2(13);
      v_sender          varchar2(1000);
   BEGIN
      if p_bank = 1 then					-- ??????????????
			   p_text := null;
			   p_rec := 0;
      elsif p_bank = 2 then				-- ????????????????
				 v_codbkserv :=	rpad(substr(p_codbkserv,1,6),6,' ');
				 p_text	:= lpad('M',10,' ')||v_codbkserv||rpad(substr(get_tcenter_name(p_codcomp,p_codlang),1,30),30,' ')||
				 					 'DA'||to_char(p_dtepaymt,'dd')||to_char(p_dtepaymt,'mm')||
									 substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
									 lpad(substr(to_char(p_totemp),1,5),5,'0')||
									 lpad(substr(to_char(p_totamt * 100),1,10),10,'0')||'I'||lpad(' ',8,' ');
			   p_rec := 0;            
      elsif p_bank = 3 then				-- ??????????????
	 			 v_numacct :=	rpad(substr(p_numacct,1,10),10,' ');
				 p_text	:= 'H'||rpad(substr(get_tcenter_name(p_codcomp,'101'),1,25),25,' ')||
									 to_char(p_dtepaymt,'dd')||to_char(p_dtepaymt,'mm')||
									 substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
									 v_numacct||lpad(substr(to_char(p_totamt * 100),1,10),10,'0')||lpad('0',3,'0')||
									 lpad(substr(to_char(p_totemp),1,4),4,'0')||lpad('0',21,'0');
			   p_rec := 0;
			elsif p_bank = 31 then				-- ?????????????? (Pack 128)
	 			 v_numacct :=	rpad(substr(p_numacct,1,10),10,'0');
	 			 v_codbkserv := rpad(substr(p_codbkserv,1,3),3,'0');
				 p_text	:= 'H'||'000001'||v_codbkserv||v_numacct||
				 					 rpad(substr(get_tcenter_name(p_codcomp,'101'),1,25),25,' ')||
									 to_char(p_dtepaymt,'dd')||to_char(p_dtepaymt,'mm')||
									 substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
									 lpad('0',77,'0');
			   p_rec := 0;
--<< user22 : 30/07/2021 : SDT || Add 32.BBL (WEB)
			elsif p_bank = 32 then				-- ?????????????? (Pack 128)
        begin
          select numcotax
            into v_numcotax
            from tcompny
           where codcompy = p_codcomp;
        exception when no_data_found then null;
        end;
        v_numacct :=	rpad(substr(p_numacct,1,10),10,'0');
        v_codbkserv := rpad(substr(p_codbkserv,1,6),6,'0'); 
        v_date := to_char(sysdate,'DDMM')||to_char(to_number(to_char(sysdate,'yyyy')) - p_global);
        p_text	:= '001'||'~'||v_codbkserv||'~'||
                 v_numcotax||'~'||v_numacct||'~'|| 
                 'PAYROLL'||'~'||''||'~'||
                 v_date||'~'||to_char(sysdate,'HH24MMSS');
        p_rec := 0;
-->> user22 : 30/07/2021 : SDT || Add 32.BBL (WEB)
      elsif p_bank = 4 then				-- ?????????????
   			 v_codbkserv := rpad(substr(p_codbkserv,1,3),3,' ');
   			 v_numacct := rpad(substr(p_numacct,1,10),10,' ');
   			 p_text := 'H'||lpad(to_char(1),6,'0')||v_codbkserv||v_numacct||
							     rpad(substr(get_tcenter_name(p_codcomp,p_codlang),1,25),25,' ')||
							     to_char(p_dtepaymt,'dd')||to_char(p_dtepaymt,'mm')||
							     substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
							     ' '||'0'||lpad('0',75,'0');
			   p_rec := 1;
      elsif p_bank = 5 then				-- ????????????????
   			 v_numacct := rpad(substr(p_numacct,1,10),10,' ');
    		 p_text := '0'||lpad(to_char(1),5,'0')||v_numacct||lpad('0',10,'0')||
						       '0000000000000'||lpad(' ',35,' ')||
						       substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
						       to_char(p_dtepaymt,'mm')||to_char(p_dtepaymt,'dd');
			   p_rec := 1;
      elsif p_bank = 6 then				-- ?????????????
			   p_text := null;
			   p_rec := 0;
      elsif p_bank = 21 then			-- ????????????????????????? (Media)
			   p_text := null;
			   p_rec := 0;
      elsif p_bank = 22 then			-- ???????????????? (Media)
			   p_text := null;
			   p_rec := 0;
      elsif p_bank = 23 then			-- ???????????? (Media)
			   p_text := null;
			   p_rec := 0;
      elsif p_bank = 24 then			-- ?????????????? (Media)
				 v_numacct := lpad(substr(p_numacct,1,11),11,'0');

            p_text := 'H'||lpad(to_char(1),6,'0')||'002'||substr(v_numacct,1,4)||
                           v_numacct||rpad(upper(substr(get_tcenter_name(p_codcomp,'101'),1,25)),25,' ')||
                           to_char(p_dtetran,'dd')||to_char(p_dtetran,'mm')||
                           substr(to_char(to_number(to_char(p_dtetran,'yyyy')) - p_global),3,2)||
                           'U'||'N'||'1'||'D'||lpad('0',68,'0');
			   p_rec := 1;

      elsif p_bank = 25 then			-- ?????????????

            begin
            select rpad(substr(codmedia,1,3),3,'0')
             into v_codmedia
              from tbnkmdi2
             where codcompy = p_codcomp
               and typbank  = p_bank
               and rownum = 1;
            exception when no_data_found then null;
            end ;
				v_codbkserv := rpad(substr(p_codbkserv,1,3),3,'0');

				p_text :=  p_codbkserv||v_codmedia||
                           to_char(p_dtetran,'dd')||to_char(p_dtetran,'mm')||
                           substr(to_char(to_number(to_char(p_dtetran,'yyyy')) - p_global),3,2)||
                           --rpad(substr(upper(get_tcenter_name(p_codcomp,101)),1,30),30,' ')||
                           rpad(substr(p_numacct,1,30),30,' ')||
                           '712'||
                           lpad(' ',27,' ')||
                           'A'||
                           '001'||to_char(p_dtepaymt,'mm')||
                           substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
                           lpad(to_char(p_totemp),7,'0')||
                           lpad(substr(to_char(p_totamt * 100),1,15),15,'0')||
                           lpad(' ',26,' ') ;

			   p_rec := 1;
			elsif p_bank = 26 then  --head ?????????  Thai Credit
				p_text :=  '000001'||p_codbkserv||lpad('0',10,'0')||
				           lpad('0',13,'0')||lpad(' ',35,' ')||
			             substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
			             to_char(p_dtepaymt,'mm')||to_char(p_dtepaymt,'dd');
			   p_rec := 1;
			elsif p_bank = 27 then	 -- ??????????? HSBC
			  v_numacct :=	lpad(substr(p_numacct,1,12),12,'0');
			   p_text := '1'||
			   					'TH'||
			   					'HSBC'||
			   					v_numacct||
			   					'CSF'||
									lpad(trim(to_char(p_totemp,'999999')),6,'0')||
			   					lpad(ltrim(substr(to_char(p_totamt,'99999999999999.99'),1,18)),17,'0')||
			   					to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global)||to_char(p_dtepaymt,'mm')||to_char(p_dtepaymt,'dd')||
			   					'APO'||
			   					'STTC99999999'||to_char(sysdate,'ddmm')||to_char(to_number(to_char(sysdate,'yyyy')) - p_global)||to_char(sysdate,'hhmm')||
			   				  lpad(' ',54,' ')||				--filter
			   					'1';
			   p_rec := 0;
			elsif p_bank = 28 then	 -- ????????????
			   p_text := lpad(' ',8,' ')||
			   					 'M'||
			   					 rpad(substr(p_codbkserv,1,6),6,' ')||
			   					 rpad(substr(get_tcenter_name(p_codcomp,p_codlang),1,30),30,' ')||
			   					 'C'||
			   					 'A'||
			             to_char(p_dtepaymt,'ddmm')||
			             substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
									 lpad(to_char(p_totemp),5,'0')||
									 lpad(substr(to_char(p_totamt * 100),1,11),11,'0')||
									 'I';
			   p_rec := 0;
			elsif p_bank = 29 then	 -- ???????????????
			   p_text := null;
			   p_rec 	:= 0;
			elsif p_bank = 30 then	 -- CITY BANK (BEN35)
			   p_text := null;
			   p_rec 	:= 0;

--KOHU 10/02/2024

            elsif p_bank = 55 then

                v_sender  := rpad(substr(p_codbkserv,1,6),6,' ')||rpad(substr(upper(get_tcenter_name(p_codcomp,'101')),1,30),30,' '); 
                p_text	:= '10'||'1'||'000001'||'014'||'000'||
                            lpad(substr(to_char(p_totamt * 100),1,15),15,'0')||
                            to_char(p_dtepaymt,'dd')||to_char(p_dtepaymt,'mm')||
                            to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global)||
                            'C'||' '||lpad(substr(to_char(p_totemp),1,6),6,'0')||
                            v_sender||lpad(' ',238,' ');                    	
                p_rec := 0;
--KOHU 10/02/2024

/*
			elsif p_bank = 55 then				-- ???????????????? (Media)
			   p_text := '001'||
			   					 rpad(substr(p_codbkserv,1,12),12,' ')||
			   					 rpad(substr(p_codbkserv,1,12),32,' ')||----------
									 to_char(to_number(to_char(sysdate,'yyyy')) - p_global)||to_char(sysdate,'mmdd')||
									 to_char(sysdate,'hh24miss')||
			   					 'BCM'||
									 lpad(' ',32,' ');
			   p_text := p_text||'002'||
			   					 'MCL'||
									 to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global)||to_char(p_dtepaymt,'mmdd')||
			   					 rpad(substr(p_numacct,1,25),25,' ')||
			   					 '0'||substr(p_numacct,4,1)||
			   					 '0'||substr(p_numacct,1,3)||
			   					 'THB'||
									 lpad(substr(to_char(p_totamt * 1000),1,16),16,'0')||
			   					 lpad('001',8,'0')||
									 lpad(to_char(p_totemp),6,'0')||
			   					 rpad(substr(p_numacct,1,15),15,' ')||
									 lpad(' ',9,' ')||
									 ' '||
			   					 '0'||substr(p_numacct,4,1)||
			   					 '0'||substr(p_numacct,1,3);
			   p_rec := 0;
*/




      --<<user14 09/04/2013 STA2560390 add KBANK(SMART PAYROLL)(58) copy from DKSH
      elsif p_bank = 58 then			-- KBANK(SMART PAYROLL)
      	-- Length 82 --
				p_text :=  'H'||
				           'PCL'||
				           lpad(p_numacct,10,' ')||
				           lpad(' ',16,' ')||
				           to_char(p_dtepaymt,'dd-mm-yyyy')||
				           lpad(' ',5,' ')||
				           lpad(substr(p_totemp,1,18),18,'0')||
				           lpad(to_char(p_totamt,'fm99999999999999.00'),18,'0')||
				           'N';
				p_rec := 0;
			-->>user14 09/04/2013 STA2560390 add KBANK(SMART PAYROLL)(58) copy from DKSH

      elsif p_bank = 99 then			-- Modify ?????????
			   p_text := null;
			   p_rec := 0;
      end if;
   END; /* PROCEDURE HEAD */
   -------------------------------------------------------------------------------


   PROCEDURE BODY(p_bank				in number,
  							  p_codbkserv 	in varchar2,
  							 	p_numacct 		in varchar2,
  							 	p_sumrec			in number,
  							 	p_codempid		in varchar2,
  							 	p_codbank	  	in varchar2,
  							 	p_numbank			in varchar2,
  							 	p_amtpay			in number,
  							 	p_dtepaymt		in date,
  							 	p_codcomp			in varchar2,
  							 	p_totemp		 	in number,
  							 	p_totamt			in number,
  							 	p_dtetran		  in date,
  							 	p_codmedia		in varchar2,
  							 	p_global			in number,
  							 	p_codlang			in varchar2,
  							 	p_text				out varchar2) is

	    v_codbkserv				varchar2(10 char);
	    v_banch						varchar2(4 char);
	    v_numbank					varchar2(11 char);
	    v_numacct					varchar2(30 char);
	    v_namfirste				varchar2(30 char);
	    v_namfirstt				varchar2(30 char);
	    v_namlastt				varchar2(30 char);
	    v_namempe					varchar2(100 char);
	    v_namempt					varchar2(100 char);
	    v_codmedia				varchar2(100 char);
	    v_bankname				varchar2(100 char);
	    v_bankfee					number:=0;
	    v_codtitle				varchar2(100 char);

			v_numbrnch				varchar2(4 char);
			v_numbank1				varchar2(30 char);
			v_numbank2				varchar2(30 char);
			v_brnch1				  varchar2(4 char);
			v_brnch2				  varchar2(4 char);

			v_adrreg        varchar2(100 char);
	    v_adrrege				varchar2(100 char);
	    v_adrregt				varchar2(100 char);
	    v_adrreg3				varchar2(100 char);
	    v_adrreg4				varchar2(100 char);
	    v_adrreg5 			varchar2(100 char);
	    v_numoffid      varchar2(100 char);
	    v_numtaxid      varchar2(13 char);
	    v_email         varchar2(50 char);
	    v_mail					varchar2(50 char);
      v_date					varchar2(20 char);
	    v_ename					varchar2(60 char);
        v_sender          varchar2(1000);
   BEGIN
--ADEC550544
      begin
					select numbank, v_numbank2, numbrnch, numbrnch2
					  into v_numbank1, v_numbank2, v_brnch1, v_brnch2
					 from temploy3
				  where codempid = p_codempid;

						if v_numbank1 = p_numbank then
								v_numbrnch := v_brnch1;
						elsif v_numbank2 = p_numbank then
								v_numbrnch := v_brnch2;
						end if;

						if length(v_numbrnch) < 4 then
								v_numbrnch := '0'||rpad(v_numbrnch,3,' ');
						elsif v_numbrnch is null then
								v_numbrnch := '0'||rpad(substr(p_numbank,1,3),3,' ');
						end if;
				exception when no_data_found then
					v_numbrnch := '0'||rpad(substr(p_numbank,1,3),3,' ');
      end;
--ADEC550544

      if p_bank = 1 then					-- ??????????????
			   v_codbkserv := rpad(substr(p_codbkserv,1,7),7,' ');
		   /*
				begin
					select  get_tlistval_name('CODTITLE',codtitle,p_codlang),
									decode(p_codlang,'101',namfirste,'102',namfirstt,'103',namfirst3,'104',namfirst4,'105',namfirst5,namfirstt),
						 			decode(p_codlang,'101',namlaste,'102',namlastt,'103',namlast3,'104',namlast4,'105',namlast5,namlastt)
					into v_codtitle,v_namfirstt,v_namlastt
					from	 temploy1
					where	 codempid = p_codempid;
				exception when no_data_found then
					v_codtitle 	:= 	null;
					v_namfirstt :=	null;
					v_namlastt	:=	null;
				end;
				*/
				 p_text := lpad(to_char(p_sumrec),6,'0')||lpad(' ',1,' ')||'7106'||
					         lpad(' ',1,' ')||v_codbkserv||lpad(' ',1,' ')||
					         rpad(substr(p_numbank,1,10),10,' ')||lpad(' ',1,' ')||
					         lpad(substr(to_char(p_amtpay * 100),1,15),15,'0')||lpad(' ',1,' ')||
					         substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
					         to_char(p_dtepaymt,'mm')||to_char(p_dtepaymt,'dd')||lpad(' ',1,' ')||
					         rpad(substr(p_codempid,1,23),23,' ')||lpad(' ',1,' ')||
					         rpad(substr(get_temploy_name(p_codempid,p_codlang),1,50),50,' ');

      elsif p_bank = 2 then				-- ????????????????
			   p_text := rpad(substr(p_numbank,1,10),10,' ')||to_char(p_dtepaymt,'dd')||
					   			 to_char(p_dtepaymt,'mm')||
					   			 substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
					   			 lpad(substr(to_char(p_amtpay * 100),1,10),10,'0') ||
					   			 --lpad(' ',52,' ');--<< comment  By: User25/Thanittha.y Date: 19/04/2018   ErrorNo: STA4610085 HRPY70B Format SCB ???????????????????????

					   			 --<< add  By: User25/Thanittha.y Date: 19/04/2018   ErrorNo: STA4610085 HRPY70B Format SCB ???????????????????????
					   			 lpad(' ',2,' ')||
					   			 rpad('',50,' ');
					   			 --rpad(substr(get_temploy_name(p_codempid,p_codlang),1,50),50,' ');
					   			 -->> add  By: User25/Thanittha.y Date: 19/04/2018   ErrorNo: STA4610085 HRPY70B Format SCB ???????????????????????

      elsif p_bank = 3 then				-- ??????????????
				 p_text := 'I'||'0'||'001'||lpad(substr(p_codempid,1,10),10,'0')||
					  			 rpad(substr(get_temploy_name(p_codempid,p_codlang),1,35),35,' ')||
					  			 rpad(substr(p_numbank,1,10),10,' ')||lpad(substr(to_char(p_amtpay * 100),1,10),10,'0')||
					  			 lpad('0',4,'0')||'5'||lpad('0',5,'0');
			elsif p_bank = 31 then				-- ?????????????? (Pack 128)
      	 v_codbkserv := rpad(substr(p_codbkserv,1,3),3,'0');
				 p_text := 'D'||lpad(to_char(p_sumrec),6,'0')||v_codbkserv||
				 					 rpad(substr(p_numbank,1,10),10,'0')||'C'||
				 					 lpad(substr(to_char(p_amtpay * 100),1,10),10,'0')||'02'||'9'||
					  			 lpad('0',32,'0')||'0001'||lpad(substr(p_codempid,1,10),10,'0')||
					  			 lpad('0',13,'0')||
					  			 rpad(substr(get_temploy_name(p_codempid,p_codlang),1,35),35,' ');
--<< user22 : 30/07/2021 : SDT || Add 32.BBL (WEB)
			elsif p_bank = 32 then				-- ?????????????? (Pack 128)
         v_date := to_char(p_dtepaymt,'DDMM')||to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global);
         v_ename := get_temploy_name(p_codempid,'101');
         if v_ename is null then
         	 v_ename := get_temploy_name(p_codempid,'102');
         end if;
         v_codbkserv := rpad(substr(p_codbkserv,1,6),6,'0');
				 p_text := '003'||'~'||v_codbkserv||'~'||
				           p_sumrec||'~'||'PYR02'||'~'||
				           p_numbank||'~'||v_date||'~'||
				           ''||'~'||'THB'||'~'||
				           p_codempid||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           'Y'||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           'OUR'||'~'||p_amtpay * 100||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||'002'||'~'||
                   '0'||rpad(substr(p_numbank,1,3),3,'0')||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||v_ename||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||''||'~'||
				           ''||'~'||'';
-->> user22 : 30/07/2021 : SDT || Add 32.BBL (WEB)                   
      elsif p_bank = 4 then				-- ?????????????
			   v_codbkserv := rpad(substr(p_codbkserv,1,3),3,' ');
         p_text := 'D'||lpad(to_char(p_sumrec),6,'0')||v_codbkserv||
					  			 rpad(substr(p_numbank,1,10),10,' ')||'C'||
					  			 lpad(substr(to_char(p_amtpay * 100),1,10),10,'0')||'029'||lpad('0',94,'0');
      elsif p_bank = 5 then				-- ????????????????
				 p_text := '1'||lpad(to_char(p_sumrec),5,'0')||rpad(substr(p_numacct,1,10),10,' ')||
					   			 rpad(substr(p_numbank,1,10),10,' ')||
					   			 lpad(substr(to_char(p_amtpay * 100),1,13),13,'0')||
					   			 lpad(' ',35,' ')||substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
					   			 to_char(p_dtepaymt,'mm')||to_char(p_dtepaymt,'dd');
      elsif p_bank = 6 then				-- ?????????????
			   v_codbkserv := rpad(substr(p_codbkserv,1,4),4,' ');
			   p_text := v_codbkserv||'08'||rpad(substr(p_numbank,1,10),10,'0')||
			             lpad(substr(p_numbank,1,3),3,'0')||lpad(substr(p_sumrec,1,7),7,'0')||'2'||
			             lpad(substr(to_char(p_amtpay * 100),1,11),11,'0')||'001';
			   /*v_codbkserv := rpad(substr(p_codbkserv,1,6),6,' ');
				 p_text := v_codbkserv||rpad(substr(p_numbank,1,10),10,'0')||
					         rpad(substr(p_numacct,1,3),3,' ')||lpad('0',2,'0')||
					         rpad(substr(p_codempid,1,5),5,' ')||'2'||
									 ltrim(to_char(p_amtpay * 100,'000000000000'))||'01';*/  --old format

      elsif p_bank = 21 then			-- ????????????????????????? (Media)
			   p_text := rpad(substr(get_tcenter_name(p_codcomp,p_codlang),1,45),45,' ')||';'||
			   					 rpad(substr(p_totemp,1,8),8,' ')||';'||
									 lpad(ltrim(substr(to_char(p_totamt,'999999999999.99'),1,16)),15,'0')||';'||
									 rpad(substr(p_numacct,1,34),34,' ')||';'||
									 substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
									 to_char(p_dtepaymt,'mm')||to_char(p_dtepaymt,'dd')||';'||
									 substr(to_char(to_number(to_char(p_dtetran,'yyyy')) - p_global),3,2)||
									 to_char(p_dtetran,'mm')||to_char(p_dtetran,'dd')||';'||
									 rpad(substr(nvl(get_temploy_name(p_codempid,'101'),' '),1,50),50,' ')||
									 ';'||';'||';'||';'||';'||';'||';'||';'||
									 rpad(substr(nvl(get_temploy_name(p_codempid,'102'),' '),1,75),75,' ')||
									 ';'||';'||';'||';'||';'||';'||rpad(substr(nvl(p_codmedia,' '),1,3),3,' ')||
--ADEC550544									 ';'||'0'||rpad(substr(p_numbank,1,3),3,' ')||';'||lpad(substr(p_numbank,1,11),11,'0')||
									 ';'||v_numbrnch||';'||lpad(substr(p_numbank,1,11),11,'0')||
--ADEC550544
									 ';'||lpad(ltrim(substr(to_char(p_amtpay,'999999999999.99'),1,16)),15,'0')||
									 ';'||';'||'00'||';'||'0.00'||';'||'0.00'||';'||'00'||';'||'0.00'||';'||'0.00'||
									 ';'||'00'||';'||'0.00'||';'||'00'||';'||'0.00'||';'||'N'||';'||'03'||';'||
									 ';'||'01'||';'||';'||';'||'00';
      elsif p_bank = 22 then			-- ???????????????? (Media)

			   if p_codmedia in ('005','007','008','010','017','018','026','027','028','031','032','039') then
				    v_banch := '0001';
				 else
				    v_banch := '0000';
				 end if;
				 v_numacct := p_numacct;
				 if substr(v_numacct,1,1) = '0' then
				 			v_numacct := substr(v_numacct,2,14);
				 end if;

				 p_text := 'PTP@'||'TH@'||v_numacct||'@THB@'||to_char(p_amtpay,'fm99999999999990.00')||'@@'||
				           to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global)||to_char(p_dtepaymt,'mm')||to_char(p_dtepaymt,'dd')||
				 					 '@'||p_codmedia||' '||p_numbank||'@'||'@@@@@'||
									 upper(substr(get_tcompny_name(p_codcomp,'101'),1,29))||' - PTP'||
				 					 '@@@@@@'||substr(get_temploy_name(p_codempid,'101'),1,70)||'@@@@@'||
				 					 p_numbank||'@@@@@@@'||p_codmedia||v_banch||'@@@@'||'@'||'@'||'@'||'@@@@@@@@@@@@@@@@@@@'||'OUR'||
				 					 --'@@@@@@@@@@@@@@'||'@'||'@@@@@@'||'01'||'@@@@@@@@@@@@@@@@@@'||p_amtpay||'@@@@@@@@@@@@@@@';
				 					 '@@@@@@@@@@@@@@'||'@'||'@@@@@@'||'01'||'@@@@@@@@@@@@@@@@@@'||to_char(p_amtpay,'fm99999999999990.00')||'@@@@@@@@@@@@@@@@';--add @

      elsif p_bank = 23 then			-- ???????????? (Media)
			   v_codbkserv := rpad(substr(p_codbkserv,1,7),7,' ');
				 p_text := '102000001'||lpad(substr(nvl(p_codmedia,'0'),1,3),3,'0')||
--ADEC550544					     		 lpad(substr(p_numbank,1,3),4,'0')||'0'||rpad(substr(p_numbank,1,10),10,' ')||
					     		 v_numbrnch||'0'||rpad(substr(p_numbank,1,10),10,' ')||
--ADEC550544
					     		 v_codbkserv||rpad(substr(p_numacct,1,11),11,' ')||
					     		 to_char(p_dtepaymt,'dd')||to_char(p_dtepaymt,'mm')||
					     		 lpad(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),4,'0')||
					     		 '0100'||lpad(substr(to_char(p_amtpay * 100),1,12),12,'0')||
					     		 rpad(substr(nvl(upper(get_temploy_name(p_codempid,'101')),' '),1,20),20,' ')||
					     		 lpad(' ',40,' ')||rpad(' ',24,' ')||lpad(' ',136,' ')||lpad(to_char(p_sumrec),6,'0');
      elsif p_bank = 24 then			-- ?????????????? (Media)
      	    v_numbank := lpad(substr(p_numbank,1,11),11,'0');

				 p_text := 'D'||lpad(to_char(p_sumrec),6,'0')||lpad(substr(nvl(p_codmedia,'0'),1,3),3,'0')||
				 					 substr(v_numbank,1,4)||v_numbank||'C'||lpad(substr(to_char(p_amtpay * 100),1,12),12,'0')||
					  			 '01'||rpad(substr(get_temploy_name(p_codempid,'102'),1,30),30,' ')||
					  			 lpad('0',20,'0')||lpad('0',8,'0')||lpad('0',30,'0');
      elsif p_bank = 25 then			-- ?????????????
      --	 v_numbank := lpad(substr(p_numbank,1,11),11,'0');
      --   v_codbkserv := rpad(substr(p_codbkserv,1,3),3,'0');    29/01/2551
				/* p_text := '250'||v_codbkserv||rpad(substr(p_numbank,1,10),10,' ')||
				           rpad(substr(get_temploy_name(p_codempid,'101'),1,20),20,' ')||
				           lpad(substr(to_char(p_amtpay * 100),1,12),12,'0')||
				           lpad(' ',26,' ')||
				           '001'||to_char(p_dtetran,'mm')||
									 substr(to_char(to_number(to_char(p_dtetran,'yyyy')) - p_global),3,2)||
									 lpad(' ',48,' ');   */ -- old version

			--	Modify for BITEC 29/01/2551
/*				--new 08/03/48
				p_text :=  rpad(substr(p_codmedia,1,3),3,'0')||v_codbkserv||*/

					--user41 06/09/2012 tog-550010
					begin
						select codmedia
						into v_codmedia
					  from tbnkmdi2
					  where codcompy = p_codcomp
					    and codbank = p_codbank
					    and typbank = p_bank;
					exception when no_data_found then
						v_codmedia := null;
					end;

				p_text :=  rpad(substr(p_codbkserv,1,3),3,'0')||
									 rpad(substr(v_codmedia,1,3),3,'0')||
				           rpad(substr(p_numbank,1,10),10,'0')||
				           rpad(substr(nvl(get_temploy_name(p_codempid,'101'),' '),1,20),20,' ')||
				           lpad(substr(to_char(p_amtpay * 100),1,11),11,'0')||
				           lpad(' ',26,' ')||
				           '001'||to_char(p_dtepaymt,'mm')||
									 substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
									 lpad(' ',48,' ');
			elsif p_bank = 26 then	 --body ?????????  Thai Credit
				p_text :=  '1'||lpad(to_char(p_sumrec),5,'0')||
				           p_codbkserv||
				           rpad(substr(p_numbank,1,10),10,'0')||
				           lpad(substr(to_char(p_amtpay * 100),1,13),13,'0')||
				           lpad(' ',35,' ')||
				           substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
				           to_char(p_dtepaymt,'mm')||to_char(p_dtepaymt,'dd');
			elsif p_bank = 27 then	 --body ??????????? HSBC
				begin
					select namfirste,namfirstt into v_namfirste,v_namfirstt
					from	 temploy1
					where	 codempid = p_codempid;
				exception when no_data_found then
					v_namfirste := null; v_namfirstt := null;
				end;
				v_namfirste := nvl(nvl(v_namfirste,v_namfirstt),' ');
				p_text :=  '2'||lpad(to_char(p_sumrec),12,'0')||'    '||
									 lpad(trim(to_char(p_amtpay,'9999999999990.00')),16,'0')||
				           lpad(' ',8,' ')||
				           lpad(substr(p_codmedia,1,3),3,' ')||
--ADEC550544				           '0'||substr(p_numbank,1,3)||' '||
				           v_numbrnch||' '||
--ADEC550544
				           rpad(substr(p_numbank,1,20),20,' ')||
				           lpad(' ',8,' ')||
					         rpad(substr(v_namfirste,1,20),20,' ');
			elsif p_bank = 28 then	 -- ????????????
				p_text := rpad(substr(p_numbank,1,10),10,' ')||
									to_char(p_dtepaymt,'ddmm')||
									substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
									'1'||
									lpad(substr(to_char(p_amtpay * 100),1,11),11,'0')||
									rpad(substr(get_temploy_name(p_codempid,p_codlang),1,30),30,' ')||
									' '||
									lpad(' ',21,' ');
			elsif p_bank = 29 then	 -- ???????????????
	 			v_numacct :=	lpad(substr(p_numacct,1,10),10,'0');

				p_text := rpad(substr(p_numbank,1,10),10,' ')||to_char(p_dtepaymt,'ddmm')||
									substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
									lpad(substr(to_char(p_amtpay * 100),1,10),10,'0')||'000'||
									'0000'||'0000000000000'||rpad(substr(get_temploy_name(p_codempid,p_codlang),1,22),22,' ')||
									'70'||v_numacct;
			elsif p_bank = 30 then	 -- CITY BANK (BEN35)
				v_codbkserv := 	rpad(substr(p_codbkserv,1,6),6,' ');
				v_numacct 	:=	lpad(substr(p_numacct,1,10),10,'0');

				begin
					select 	bankfee	into v_bankfee
				  from 		tbnkmdi2
				  where 	codcompy = hcm_util.get_codcomp_level(p_codcomp,'1')
				  and 		codbank	 = p_codbank
				  and 		typbank	 = p_bank;
				exception when no_data_found then
					v_bankfee := null;
				end;

				--p_text := 'PTP'||'01'||rpad(substr(p_numbank,1,7),7,0)||rpad(substr(get_temploy_name(p_codempid,p_codlang),1,35),35,' ')||
				p_text := 'PTP'||'01'||rpad(substr(nvl(p_codmedia,'0'),1,3),7,'0')||rpad(substr(get_temploy_name(p_codempid,p_codlang),1,35),35,' ')||
									lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(' ',35,' ')||
									--lpad(' ',35,' ')||rpad(substr(p_numbank,1,11),11,0)||
									lpad(' ',35,' ')||lpad(substr(p_numbank,1,11),11,0)||
									lpad(substr(to_char(p_amtpay,'fm999999999990.00'),1,15),15,' ')||
									lpad('0.00',15,' ')||lpad('0.00',15,' ')||lpad(to_char(nvl(v_bankfee,0),'fm999999999990.00'),15,' ')||
									to_char(p_dtepaymt,'ddmm')||
									to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global)||lpad(' ',12,' ')||
									'OUR'||v_codbkserv||v_numacct||rpad(substr(get_tcenter_name(p_codcomp,p_codlang),1,35),35,' ');
			-- Modify 15/03/2553
			elsif p_bank = 32 then				-- ???????????????  (Media)
				p_text := 'D'||																										             	-- ????????????
									to_char(p_dtetran,'yyyymmdd')||														            -- ?????????????????????????????????
									lpad(substr(rtrim(ltrim(p_numacct)),1,10),11,'0')|| 		             	-- ???????????????????????????????????????
									to_char(p_dtepaymt,'yyyymmdd')||													            -- ?????????????????
									lpad(p_sumrec,6,'0')||																		            -- ?????????????????
									substr(p_codmedia,1,3)||																              -- ??????????????????????
--ADEC550544									lpad(substr(p_numbank,1,3),4,'0')||		   								             	-- ?????????????????
									v_numbrnch||		   								             	-- ?????????????????
--ADEC550544
									lpad(substr(p_numbank,1,10),11,'0')||											            -- ????????????????????
									rpad(substr(get_temploy_name(p_codempid,p_codlang),1,60),60,' ')||		-- ??????????????????
				          'C'||																											            -- ?????????? Credit ???? Debit
				          lpad(to_char(p_amtpay,'fm9999999999999'),13,'0')||                    -- ????????????????????????????
									'01'||																																-- ???????????????????????????????
									'00'||																																-- ??????????????
									'78'||																																-- ????????????????????????????
								  lpad(' ',10,' ')||																										-- ?????????????????????????????????????
								  lpad(' ',20,' ')||                                                    -- ?????????????????????????????????????
								  lpad(' ',38,' '); 																										-- ???????????

		  elsif p_bank = 33 then			-- ???????????????? (GIRO)

						begin
						  select  namfirste||' '|| namlaste into v_namempe
							from	 temploy1
							where	 codempid = p_codempid;
						exception when no_data_found then
							v_namempe := null;
						end;

						 p_text := 'GRO'||'01'||p_codmedia||'0000' ||
						           rpad(substr(v_namempe,1,35),35,' ')||
						           rpad(substr(' ',1,35),35,' ')||
						           rpad(substr(' ',1,35),35,' ')||
						           rpad(substr(' ',1,35),35,' ')||
						           rpad(substr(' ',1,35),35,' ')||
						           rpad(substr(' ',1,35),35,' ')||
						           lpad(substr(p_numbank,1,11),11,'0')||
						           lpad(substr(to_char(p_amtpay,'fm99999999999990.00'),1,15),15,' ')||
						           to_char(p_dtepaymt,'dd')||to_char(p_dtepaymt,'mm')||(to_number(to_char(p_dtepaymt,'yyyy'))- p_global)||
						           rpad(substr(' ',1,12),12,' ')||
						           'OUR'||
						           p_codbkserv||
						           v_numacct||
						           substr(get_tcompny_name(p_codcomp,'101'),1,43) ;


--SCB Media KOHU

        elsif p_bank = 55 then			
        
				 /*v_banch   := substr(p_numbank,1,4);
				 v_numbank := lpad(substr(p_numbank,1,15),15,'0');	*/			 

				 if p_codmedia in ('002','004','006','011','014','015','020','022',
				 	                 '024','025','034','065','066','068','070','071',
				 	                 '073') then
				 	v_numbank := lpad(substr(p_numbank,1,11),11,'0');				 
				 	v_banch   := substr(v_numbank,1,4);
				 elsif p_codmedia = '030' then
				 	v_numbank := lpad(substr(p_numbank,5,15),11,'0');		
				 	v_banch   := substr(p_numbank,1,4);		 
				 elsif p_codmedia = '017' then
				 	v_numbank := lpad(substr(p_numbank,1,11),11,'0');		
				 	v_banch   := '0001';	 
				 end if;
                 v_sender  := rpad(substr(p_codbkserv,1,6),6,' ')||rpad(substr(upper(get_tcenter_name(p_codcomp,'101')),1,30),30,' '); 
				 p_text := '10'||'2'||'000001'||rpad(substr(p_codmedia,1,3),3,' ')||
				 						--rpad(substr(p_codbkserv,4,3),3,' ')||
				            v_banch||
				            v_numbank||
				           '014'||'0000'||lpad(substr(p_numacct,1,11),11,'0')||
				           to_char(p_dtepaymt,'dd')||to_char(p_dtepaymt,'mm')||
					   			 to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global)||
				           '01'||'00'||lpad(substr(to_char(p_amtpay * 100),1,12),12,'0')||
				           lpad(' ',60,' ')||rpad(v_sender,60,' ')||'0000000000'||
				           rpad(substr(get_temploy_name(p_codempid,p_codlang),1,23),23,' ')||
				           lpad(' ',67,' ')||lpad(p_sumrec,6,'0')||lpad(' ',25,' ');		

--SCB Media KOHU

/*
			elsif p_bank = 55 then				-- ???????????????? (Media)
				begin
					select namempe,namempt into v_namempe,v_namempt
					from	 temploy1
					where	 codempid = p_codempid;
				exception when no_data_found then
					v_namempe := null; v_namempt := null;
				end;
				begin
				  select descode
				  into v_bankname
    			from tcodbank
    			where codcodec = p_codmedia;
				exception when no_data_found then
				  begin
				    select descode
				    into v_bankname
    			  from tcodbank
    			  where codcodec = substr(p_codmedia,2,2);
				  exception when no_data_found then
					  v_bankname := ' ';
				  end;
				end;
				p_text := '003'||
									lpad(to_char(p_sumrec),6,'0')||
									rpad(substr(p_numbank,1,25),25,' ')||
									lpad(substr(to_char(p_amtpay * 1000),1,16),16,'0')||
									'THB'||
									lpad('001',8,'0')||
									'NNNS'||
									lpad(' ',115,' ')||
									rpad(substr(p_codmedia,1,3),3,' ')||
									lpad(v_bankname,35,' ')||
--ADEC550544									'0'||substr(p_numbank,1,3)||
									v_numbrnch||
--ADEC550544
									lpad(' ',35,' ')||
									' '||
									'N'||
									lpad(' ',24,' ')||
									'01'||
									lpad(' ',70,' ');
				p_text := p_text||'004'||
									lpad('001',8,'0')||
									lpad(to_char(p_sumrec),6,'0')||
									lpad(' ',15,' ')||
									rpad(nvl(v_namempt,' '),100,' ')||
									lpad(' ',220,' ')||
									rpad(nvl(v_namempe,' '),70,' ')||
									lpad(' ',394,' ');


*/         

			elsif p_bank = 56 then				-- Deutsche Bank (Media)
					begin
						select namempe,namempt into v_namempe,v_namempt
						  from temploy1
						 where codempid = p_codempid;
					exception when no_data_found then null;
					end;
					begin
						select CODMEDIA
						into v_codmedia
					  from tbnkmdi2
					  where CODCOMPY = hcm_util.get_codcomp_level(p_codcomp,'1')
					    and CODBANK = p_codbank
					    and TYPBANK = p_bank;
					exception when no_data_found then
						v_codmedia := null;
					end;
/*
					-- 1-10 ------------------------------------------------
					p_text := lpad(p_numacct,35,' ')||'THB'||lpad(p_numacct,35,' ')||'THB'||'CTS'||' 15'||'N'||lpad(' ',1,' ')||'THB'||to_char(p_dtepaymt,'ddmmyyyy')||
					-- 11-20 ------------------------------------------------
					lpad(' ',2,' ')||lpad(' ',35,' ')||lpad(' ',3,' ')||lpad(' ',35,' ')||lpad(' ',8,' ')||'Y'||lpad(' ',100,' ')||lpad(substr(to_char(p_amtpay * 100),1,15),15,'0')||lpad(' ',8,' ')||lpad(' ',35,' ')||
					-- 21-30 ------------------------------------------------
					lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(p_codempid,10,' ')||lpad(v_namempt,60,' ')||lpad(p_numbank,35,' ')||lpad(' ',3,' ')||lpad(' ',35,' ')||
					-- 31-40 ------------------------------------------------
					lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(' ',2,' ')||lpad(lpad(substr(p_numbank,1,3),4,'0'),10,' ')||lpad(' ',35,' ')||lpad(' ',70,' ')||lpad(' ',11,' ')||lpad(p_codbank,17,' ')||lpad(' ',8,' ')||
					-- 41-50 ------------------------------------------------
					lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(' ',2,' ')||lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(' ',35,' ')||lpad(' ',2,' ')|| lpad(' ',11,' ')||
					-- 51-60 ------------------------------------------------
					lpad(' ',17,' ')||lpad(' ',8,' ')||lpad(' ',70,' ')||lpad(' ',70,' ')||lpad(' ',70,' ')||lpad(' ',70,' ')||lpad(' ',70,' ')||lpad(' ',70,' ')||lpad(' ',70,' ')||lpad(' ',70,' ')||
					-- 61-67 ------------------------------------------------
					lpad(' ',105,' ')||lpad(' ',8,' ')||' 01'||lpad(' ',25,' ')||lpad(' ',10 ,' ')||lpad(' ',70,' ')||lpad(' ',100,' ');
*/
					-- 1-10 ------------------------------------------------
					p_text := nvl(p_numacct,'')||';'||'THB'||';'||nvl(p_numacct,'')||';'||'THB'||';'||'CTS'||';'||'15'||';'||'N'||';'||''||';'||'THB'||';'||to_char(p_dtepaymt,'ddmmyyyy')||';'||
					-- 11-20 ------------------------------------------------
					''||';'||''||';'||''||';'||''||';'||''||';'||'Y'||';'||''||';'||lpad(substr(to_char(round(p_amtpay)),1,12),12,'0')||'.'||lpad(substr(to_char(mod(p_amtpay * 100,100)),1,2),2,'0')||';'||''||';'||''||';'||
					-- 21-30 ------------------------------------------------
					''||';'||''||';'||''||';'||''||';'||''||';'||p_codempid||';'||v_namempt||';'||p_numbank||';'||''||';'||''||';'||
					-- 31-40 ------------------------------------------------
--ADEC550544					''||';'||''||';'||''||';'||''||';'||lpad(substr(p_numbank,1,3),4,'0')||';'||''||';'||''||';'||''||';'||p_codmedia||';'||''||';'||
					''||';'||''||';'||''||';'||''||';'||v_numbrnch||';'||''||';'||''||';'||''||';'||p_codmedia||';'||''||';'||
--ADEC550544
					-- 41-50 ------------------------------------------------
					''||';'||''||';'||''||';'||''||';'||''||';'||''||';'||''||';'||''||';'||''||';'||''||';'||
					-- 51-60 ------------------------------------------------
					''||';'||''||';'||''||';'||''||';'||''||';'||''||';'||''||';'||''||';'||''||';'||''||';'||
					-- 61-67 ------------------------------------------------
					''||';'||''||';'||'01'||';'||''||';'||''||';'||''||';'||'';

      --<<user14 09/04/2013 STA2560390 add KBANK(SMART PAYROLL)(58) copy from DKSH
      elsif p_bank = 58 then --KBANK(Smart Payroll)
      	begin
      		select adrrege,adrregt,adrreg3,adrreg4,adrreg5,
      		       numoffid,t3.numtaxid,t1.email
      		into   v_adrrege,v_adrregt,v_adrreg3,v_adrreg4,v_adrreg5,
      		       v_numoffid,v_numtaxid,v_email
      		from   temploy1 t1,temploy2 t2,temploy3 t3
      		where  t1.codempid = p_codempid
      		and    t1.codempid = t2.codempid
      		and    t2.codempid = t3.codempid;
      	exception when no_data_found then
      		v_adrrege	:= null;
      		v_adrregt	:= null;
      		v_adrreg3	:= null;
      		v_adrreg4	:= null;
      		v_adrreg5 := null;
      		v_numoffid:= null;
      		v_numtaxid:= null;
      		v_email   := null;
      	end;
      	-- addr
      	if p_codlang = '101' then
      		v_adrreg := v_adrrege;
      	elsif p_codlang = '102' then
      		v_adrreg := v_adrregt;
      	elsif p_codlang = '103' then
      		v_adrreg := v_adrreg3;
      	elsif p_codlang = '104' then
      		v_adrreg := v_adrreg4;
      	elsif p_codlang = '105' then
      		v_adrreg := v_adrreg5;
      	end if;

        --banch code
        if p_codmedia in ('002','004','006','011','014','015','020','022','024',
        	                '025','034','065','066','070','071','073') then
        	 v_banch := substr(p_numbank,1,3);
        elsif p_codmedia in ('005','008','010','017','018','026','027','032') then
        	 v_banch := '001';
        elsif p_codmedia in ('028','031','039') then
        	 v_banch := '0001';
        elsif p_codmedia in ('030','067','069') then
        	v_banch  := substr(p_numbank,1,4);
        elsif p_codmedia = '033' then
        	v_banch  := lpad(substr(v_numbank,1,3),4,'0');
        end if;

        --Email
        if v_email is not null then
        	v_mail := 'E';
        else
        	v_mail := null;
        end if;

      	p_text := 'D'||
      						lpad(substr(p_sumrec,1,10),10,' ')||																--
      						lpad(to_char(p_amtpay,'fm999999999.00'),13,'0')||                   --
      						rpad(substr(get_temploy_name(p_codempid,p_codlang),1,80),80,' ')||  --
      						lpad(' ',30,' ')||--rpad(substr(v_adrreg,1,30),30,' ')||            -- 1
      						lpad(' ',30,' ')||																									-- 2
      						lpad(' ',30,' ')||																								  -- 3
      						lpad(' ',30,' ')||																									-- 4
      						lpad(substr(p_numbank,1,20),20,'0')||                               --
      						lpad(substr(p_codempid,1,16),16,' ')||                              --
      						lpad(' ',13,' ')||--lpad(substr(v_numoffid,1,13),13,' ')|| 				  --
      						lpad(substr(v_banch,1,4),4,' ')||																		--
      						lpad(substr(p_codmedia,1,3),3,' ')||															  --
      						lpad(' ',255,' ')||																								  --
      						lpad(' ',10,' ')||--lpad(substr(v_numtaxid,1,10),10,' ')||          --
      						lpad(' ',50,' ')||																									--
      						lpad(substr(nvl(v_mail,' '),1,1),1,' ')|| 													--
      						lpad(' ',50,' ')||                                                  --
      						lpad(substr(nvl(v_email,' '),1,50),50,' ')||                        --email address
      						lpad(' ',13,' ')||                                                  --
      						lpad(' ',13,' ')||																									--
      						lpad(' ',13,' ')||                                                  --
      						lpad(' ',3,' ');
      -->>user14 09/04/2013 STA2560390 add KBANK(SMART PAYROLL)(58) copy from DKSH
      elsif p_bank = 99 then			-- Modify ?????????
			   p_text := null;
      end if;
   END; /* PROCEDURE BODY */
	 -------------------------------------------------------------------------------


   PROCEDURE TAIL(p_bank				in number,
  							 	p_codbkserv 	in varchar2,
  							 	p_numacct 		in varchar2,
  							 	p_sumrec			in number,
  							 	p_totamt			in number,
 							 	  p_dtepaymt		in date,
 							 	  p_global			in number,
 							 	 	p_text				out varchar2) is

	    v_codbkserv				varchar2(10);
	    v_numacct 				varchar2(11);

   BEGIN
      if p_bank = 1 then					-- ??????????????
			   v_codbkserv := rpad(substr(p_codbkserv,1,7),7,' ');
         p_text := lpad(to_char(p_sumrec + 1),6,'0')||lpad(' ',1,' ')||'9100'||
							     lpad(' ',1,' ')||v_codbkserv||lpad(' ',1,' ')||lpad('0',10,'0')||
							 		 lpad(' ',1,' ')||lpad(substr(to_char(p_totamt * 100),1,15),15,'0')||
							 		 lpad(' ',1,' ')||'000000';
      elsif p_bank = 2 then				-- ????????????????
			   p_text := null;

      elsif p_bank = 3 then				-- ??????????????
			   p_text := null;
			elsif p_bank = 31 then				-- ?????????????? (Pack 128)
			   v_codbkserv := rpad(substr(p_codbkserv,1,3),3,'0');
			   p_text := 'T'||lpad(to_char(p_sumrec + 2),6,'0')||v_codbkserv||
									 rpad(substr(p_numacct,1,10),10,'0')||lpad('0',20,'0')||
									 lpad(to_char(p_sumrec),7,'0')||lpad(to_char(p_totamt * 100),13,'0')||
									 lpad('0',68,'0');
--<< user22 : 30/07/2021 : SDT || Add 32.BBL (WEB)
			elsif p_bank = 32 then				-- ?????????????? (Pack 128)
				 p_text := '100'||'~'||p_sumrec||'~'||p_totamt * 100;
-->> user22 : 30/07/2021 : SDT || Add 32.BBL (WEB)
      elsif p_bank = 4 then				-- ?????????????
			   v_codbkserv := rpad(substr(p_codbkserv,1,3),3,' ');
			   p_text := 'T'||lpad(to_char(p_sumrec + 2),6,'0')||v_codbkserv||
									 rpad(substr(p_numacct,1,10),10,' ')||lpad('0',20,'0')||
									 lpad(to_char(p_sumrec),7,'0')||lpad(to_char(p_totamt * 100),13,'0')||
									 lpad('0',68,'0');
      elsif p_bank = 5 then				-- ????????????????
			   p_text :=	'9'||lpad(to_char(p_sumrec + 2),5,'0')||rpad(substr(p_numacct,1,10),10,' ')||
										rpad('0',10,'0')||
										lpad(substr(to_char(p_totamt * 100),1,13),13,'0')||
										lpad(' ',35,' ')||substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
										to_char(p_dtepaymt,'mm')||to_char(p_dtepaymt,'dd');
      elsif p_bank = 6 then				-- ?????????????
			   p_text := null;
      elsif p_bank = 21 then			-- ????????????????????????? (Media)
			   p_text := null;
      elsif p_bank = 22 then			-- ???????????????? (Media)
			   p_text := null;
      elsif p_bank = 23 then			-- ???????????? (Media)
			   p_text := null;
      elsif p_bank = 24 then			-- ?????????????? (Media)
				 v_numacct := lpad(substr(p_numacct,1,11),11,'0');
			   p_text := 'T'||lpad(to_char(p_sumrec + 2),6,'0')||'002'||v_numacct||
										rpad('0',20,'0')||lpad(to_char(p_sumrec),7,'0')||
										lpad(ltrim(to_char(p_totamt*100)),13,'0')||
										rpad('0',67,'0');
			elsif p_bank = 26 then		 --Tail ?????????  Thai Credit
			   p_text := '9'||lpad(to_char(p_sumrec + 2),5,'0')||
			              p_codbkserv||lpad('0',10,'0')||
			              lpad(substr(to_char(p_totamt*100),1,13),13,'0')||
			              lpad(' ',35,' ')||
			              substr(to_char(to_number(to_char(p_dtepaymt,'yyyy')) - p_global),3,2)||
				            to_char(p_dtepaymt,'mm')||to_char(p_dtepaymt,'dd');
			elsif p_bank = 29 then	 -- ???????????????
			   p_text := null;
			elsif p_bank = 30 then	 -- CITY BANK (BEN35)
			   p_text := null;
/*
			elsif p_bank = 55 then				-- ???????????????? (Media)
				p_text := '999'||
									lpad('001',6,'0')||
									lpad(to_char(p_sumrec),6,'0')||
									lpad(substr(to_char(p_totamt * 1000),1,16),16,'0');
*/
  		elsif p_bank = 99 then			-- Modify ?????????
			   p_text := null;
      end if;
   END; /* PROCEDURE TAIL */
END;

/

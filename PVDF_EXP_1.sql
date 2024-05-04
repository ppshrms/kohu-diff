--------------------------------------------------------
--  DDL for Package Body PVDF_EXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "PVDF_EXP" IS
-- last update: 30/09/2020 18:00
   procedure head(p_pvdf				in number,
   							  p_typpayroll	in varchar2,
   							  p_numcomp			in varchar2,
   							  p_numfund  		in varchar2,
   							  p_dtepay			in date,
   							  p_dtemthpay		in varchar2,
   							  p_dteyrepay		in number,
   							  p_totamtprove in number,
   							  p_totamtprovc	in number,
   							  p_totrec			in number,
   							  p_namcomp			in varchar2,
  							 	p_global			in number,
  							 	p_codlang			in varchar2,
  							 	p_text				out varchar2) is
   v_dtepay  date;
   begin
      if p_pvdf = 1 then					-- ??????????????
				 p_text := 'A'||substr(p_typpayroll,1,1)||
									 rpad(substr(p_numfund,1,4),4,' ')||
									 to_char(p_dtepay,'dd')||to_char(p_dtepay,'mm')||
									 to_char(to_number(to_char(p_dtepay,'yyyy')) - p_global)||
									 rpad(' ',32,' ')||rpad(substr(p_numcomp,1,4),4,' ');
      elsif p_pvdf = 2 then
         p_text := null;
      elsif p_pvdf = 3 then
         p_text := null;
      elsif p_pvdf = 4 then
         p_text := null;
      elsif p_pvdf = 5 then
         p_text := null;
      elsif p_pvdf = 6 then
				 p_text := '0'||';'||rpad(substr(p_numcomp,1,7),7,' ')||';'||
		  						 lpad(p_dtemthpay,2,'0')||'/'||
		  						 lpad((p_dteyrepay - p_global + 543),4,'0')||';'||'1'||';'||
		  						 lpad(ltrim(to_char(p_totamtprove,'99999999999.99')),14,'0')||';'||
									 lpad(ltrim(to_char(p_totamtprovc,'99999999999.99')),14,'0')||';'||
									 lpad(ltrim(to_char(p_totamtprovc + p_totamtprove,'99999999999.99')),14,'0')||
									 ';'||lpad((p_totrec),10,'0')||';'||
									 to_char(p_dtepay,'dd')||'/'||to_char(p_dtepay,'mm')||'/'||
									 lpad((to_number(to_char(p_dtepay,'yyyy')) - p_global + 543),4,'0')||';'||
									 lpad(p_namcomp,50,' ')||';'||lpad(' ',36,' ');
      elsif p_pvdf = 7 then
         p_text := null;
      elsif p_pvdf = 8 then
         p_text := null;
      elsif p_pvdf = 9 then
         p_text := null;
      elsif p_pvdf = 11 then
         p_text := null;
      elsif p_pvdf = 13 then
         p_text := null;
      elsif p_pvdf = 14 then
         p_text := null;
      elsif p_pvdf = 17 then
         p_text := null;
      elsif p_pvdf = 18 then --K-Asset
        begin -- find dtepay
	      	select dtepaymt into v_dtepay
	          from tdtepay
	         where codcompy    =  hcm_util.get_codcomp_level(p_namcomp,1)
	           and typpayroll  =  p_typpayroll
	           and dteyrepay   =  p_dteyrepay - p_global
	           and dtemthpay   =  p_dtemthpay
	           and numperiod   =  p_codlang;
	      exception when no_data_found then
	        v_dtepay	:= p_dtepay;
	      end;

		    p_text := 'A'||substr(p_typpayroll,1,1)||
                  rpad(substr(p_numfund,1,4),4,' ')||
       						to_char(p_dtepay,'dd')||to_char(p_dtepay,'mm')||
			 						to_char(to_number(to_char(p_dtepay,'yyyy')) - p_global + 543)||
			 						to_char(v_dtepay,'dd')||to_char(v_dtepay,'mm')||
			 						to_char(to_number(to_char(v_dtepay,'yyyy')) - p_global + 543)||
			 						rpad(substr(p_numcomp,1,4),4,' ');

      elsif p_pvdf = 99 then
         p_text := null;

      end if;
   end; /* PROCEDURE HEAD */

   procedure body(p_pvdf				in number,
                           p_codempid		in varchar2,
   								p_dteempmt		in date,
   							  p_dteeffec		in date,
   							  p_dtereti			in date,
   							  p_dtepay			in date,
   							  p_numperiod		in number,
   							  p_dtemthpay		in varchar2,
   							  p_dteyrepay		in number,
   							  p_typpayroll	in varchar2,
   							  p_numcomp			in varchar2,
   							  p_numfund  		in varchar2,
    							p_nummember		in varchar2,
		  						p_namtitlt		in varchar2,
		  						p_namfirstt		in varchar2,
		  						p_namlastt		in varchar2,
		  						p_namempt			in varchar2,
		  						p_namcomt			in varchar2,
									p_amtprove		in number,
									p_amtprovc		in number,
									p_codcomp   	in varchar2,
									p_flg					in number,
  							 	p_global			in number,
  							 	p_codlang			in varchar2,
  							 	p_codpfinf		in varchar2,
  							 	p_chken				in varchar2,
  							 	p_text				out varchar2,
  							 	p_text1				out varchar2,
  							 	p_text2				out varchar2) is

	    v_flgnew					varchar2(1);
	    v_numtaxid				varchar2(15);
			v_numoffid	      varchar2(13);
			v_sex							varchar2(1);
			o_codcomp					varchar2(40) := ' ';
			o_codempid  			varchar2(20) := ' ';
			v_sta  			      varchar2(2);
			v_numlvl          number;
			v_codempmt        varchar2(4);
			v_unitcal1        varchar2(1);
			v_codbrlc         varchar2(4);
			v_dtepay          date;
			v_dteempdb				date;
			v_dteeffex				date;
			v_nampfic1				varchar2(100);
			v_nampfic2				varchar2(100);
			v_nampfic3				varchar2(100);
			v_out						  varchar2(100);
			v_ratepf1					number;
			v_ratepf2					number;
			v_ratepf3					number;
			v_year						number;
			v_month						number;
			v_day							number;
			v_year1						number;
			v_month1					number;
			v_day1						number;
			v_pctcompf				number;
			v_codempid				varchar2(7);
			v_SuspendFlag	  	varchar2(1);
			v_text						varchar2(2);

         v_codplan     		tpfpcinf.codplan%type;
         v_codplan2    		tpfpcinf.codplan%type;
         v_dteeffec2  			date;
         v_numseq      		number:= 0;
         v_totamte    		 	number:= 0;
         v_totamtc     		number:= 0;
         v_amthur  				number:= 0;
         v_amtday  	 			number:= 0;
         v_amtmth  				number:= 0;
         v_cimb_amtcaccu   number:= 0;--<<add  user25 Thanittha : 04/04/2017 : NTC-600017
         v_cimb_amteaccu		number:= 0;--<<add  user25 Thanittha : 04/04/2017 : NTC-600017

         v_codcompny         tcenter.codcompy%type;   

	  type p_char is table of varchar2(4) index by binary_integer;
	  	 v_codpolicy   p_char;

	  type p_num is table of number index by binary_integer;
	  	 v_amteaccu   p_num;
       v_amtcaccu   p_num;
       v_amtincom   p_num;

		cursor c1 is
			select numseq,nampfic,ratepf
			  from tpficinf
			 where codempid = p_codempid
			   and numseq  <= 3
			order by numseq;

		cursor c_tpfirinf is
		   select a.codplan,a.codpolicy,a.pctinvt qtycompst
           from tpfpcinf a
        where a.codcompy =  v_codcompny   
            and a.codpfinf    = p_codpfinf
			   and a.codplan     = v_codplan2
			   and a.dteeffec = (select max(b.dteeffec)
					                        from tpfphinf b
                                     where b.codcompy =a.codcompy
                                         and b.codpfinf    = a.codpfinf
                                         and b.dteeffec <= v_dteeffec2)
		order by a.codplan,a.codpolicy;

	 -- For MFC Find Old Codcomp
	 cursor old_codcomp is
		  select codcomp
			from   ttaxcur
			where	 codempid   = p_codempid
			and   (( dteyrepay	= p_dteyrepay - p_global and dtemthpay	= p_dtemthpay and numperiod < p_numperiod )
			        or ( dteyrepay	= p_dteyrepay - p_global and dtemthpay	< p_dtemthpay )
			        or ( dteyrepay   < p_dteyrepay - p_global))
			order by dteyrepay desc ,dtemthpay desc ,numperiod desc;

   begin
      if p_pvdf = 1 then		-- ??????????????
		  	 if (to_char(p_dteeffec,'mm') = p_dtemthpay) and
		  			(to_char(p_dteeffec,'yyyy') = to_char(p_dteyrepay)) then
						v_flgnew := 'N';
		  	 else
		  	    v_flgnew := 'A';
		  	 end if;
		  	 begin
				    select numtaxid
						into v_numtaxid
						from temploy3
						where	codempid = p_codempid;
				 exception when no_data_found then
						v_numtaxid := ' ';
				 end;
				 if v_numtaxid is null then
				 		v_numtaxid := ' ';
				 end if;
				 p_text := 'B'||v_flgnew||rpad(substr(p_numcomp,1,4),4,' ')||
		  						 rpad(substr(p_nummember,1,10),10,' ')||
		  						 rpad(substr(p_namtitlt,1,30),30,' ')||
		  						 rpad(substr(p_namfirstt,1,40),40,' ')||
		  						 rpad(substr(p_namlastt,1,40),40,' ')||
		  						 to_char(p_dteempmt,'dd')||to_char(p_dteempmt,'mm')||
									 to_char(to_number(to_char(p_dteempmt,'yyyy')) - p_global)||
									 to_char(p_dteeffec,'dd')||to_char(p_dteeffec,'mm')||
									 to_char(to_number(to_char(p_dteeffec,'yyyy')) - p_global)||
									 rpad(substr(v_numtaxid,1,15),15,' ')||
									 substr(p_typpayroll,1,1)||
									 lpad(ltrim(to_char(p_amtprove,'99999999.99')),11,'0')||
									 lpad(ltrim(to_char(p_amtprovc,'99999999.99')),11,'0')||
									 rpad(substr(p_codcomp,1,15),15,' ');
      elsif p_pvdf = 2 then 				--???????

		 		 begin
				    select unitcal1
						into v_text
						from tcontpmd
						where	codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
						and dteeffec = (select max(dteeffec)
									  	from tcontpmd
									  	where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
									  	and  dteeffec <= sysdate)
						and codempmt = (select codempmt
											from temploy1
											where codempid = p_codempid)
						and rownum = 1;
				 exception when no_data_found then
						null;
				 end;
				 if v_text = 'D' then
				 		v_text := 'D_';
				 else
				 		v_text := 'S_';
				 end if;

		     p_text := rpad(substr(p_numcomp,1,8),8,' ')||
		  						 rpad(substr(p_numfund,1,3),3,' ')||
		  						 rpad(substr(p_codempid,1,15),15,' ')||v_text||
		  						 rpad(substr(p_namtitlt,1,15),15,' ')||
		  						 rpad(substr(p_namfirstt,1,25),25,' ')||
		  						 rpad(substr(p_namlastt,1,45),45,' ')||
		  						 rpad(substr(p_namcomt,1,15),15,' ')||
		  						 rpad(substr(p_codcomp,1,15),15,' ')||
		  						 lpad(to_char(p_amtprove * 100),11,' ')||
									 lpad(to_char(p_amtprovc * 100),11,' ')||
									 rpad(' ',11,' ')||rpad(' ',11,' ')||
									 to_char(p_dtepay,'dd')||to_char(p_dtepay,'mm')||
									 to_char(to_number(to_char(p_dtepay,'yyyy')) - p_global);
      elsif p_pvdf = 3 then 				--Tisco
		  	 ----part 3---------------------------------------------------
		  	 if p_flg = 5 then
		  	 p_text := ' '||
		  	 					 rpad(substr(p_numfund,1,5),5,' ')||
		  	 					 lpad(substr(p_nummember,1,15),15,' ')||
		  	 					 '3'||
		  						 lpad(to_char(p_amtprove * 100),9,'0')||
									 lpad(to_char(p_amtprovc * 100),9,'0')||
		  	 					 '000000000'||
		  	 					 rpad(' ',79,' ');
		  	 end if;
		  	 ---- part 1---------------------------------
		  	 if p_flg = 1 or p_flg = 2 then
		  	 	 	if p_flg = 1 then v_sta :='N'; end if;
		  	 	 	if p_flg = 2 then v_sta :='A'; end if;
		  	 p_text := v_sta||
		  	 					 rpad(nvl(substr(p_numfund,1,5),' '),5,' ')||
		  	 					 lpad(substr(p_nummember,1,15),15,' ')||
		  	 					 '1'||
		  						 rpad(substr(p_namempt,1,75),75,' ')||
		  	 					 rpad(' ',31,' ');
		  	 end if;
		  	 ---- part 2-----------------------------------
		  	 if p_flg = 3 or p_flg = 4 then
		  	 	 	if p_flg = 3 then v_sta :='N'; end if;
		  	 	 	if p_flg = 4 then v_sta :='A'; end if;
		  	 	 	 begin
						    select numtaxid
								into v_numtaxid
								from temploy3
								where	codempid = p_codempid;
						 exception when no_data_found then
								v_numtaxid := ' ';
				 		 end;
		  	 p_text := v_sta||
		  	 					 rpad(nvl(substr(p_numfund,1,5),' '),5,' ')||
		  	 					 lpad(substr(p_nummember,1,15),15,' ')||
		  	 					 '2'||
		  						 rpad(substr(p_namempt,1,45),45,' ')||' '||rpad(' ',4,' ')||rpad(' ',2,' ')||
		  						 lpad(nvl(substr(v_numtaxid,1,10),' '),10,' ')||
		  						 rpad(nvl(to_char(p_dteempmt,'mmddyy'),' '),6,' ')||
		  						 rpad(nvl(to_char(p_dteeffec,'mmddyy'),' '),6,' ')||
		  	 					 rpad(' ',32,' ');
         end if;
         --------------------------------------------------------------------------

		  elsif p_pvdf = 4 then 				--?????????????
		  	 v_flgnew := ' ';
--<<redmine-2463
          if  to_number(to_char(p_dteeffec,'mm')) = p_dtemthpay   and to_number(to_char(p_dteeffec,'yyyy')) = to_char(p_dteyrepay) then
              v_flgnew := 'N';
		  	 end if;
          if to_number(to_char(p_dtereti,'mm')) = p_dtemthpay and to_number(to_char(p_dtereti,'yyyy')) = to_char(p_dteyrepay) then
		  	     v_flgnew := 'W';
		  	 end if;
-->>redmine-2463
          begin
						select numtaxid
						into v_numtaxid
						from temploy3
						where	codempid = p_codempid;
				 exception when no_data_found then
				    v_numtaxid := ' ';
				 end;
 				 if v_numtaxid is null then
				 		v_numtaxid := ' ';
				 end if;

		  	 p_text := rpad(' ',15,' ')||rpad(substr(p_numcomp,1,5),5,' ')||
		  						 rpad(substr(p_nummember,1,6),6,' ')||
		  						 rpad(substr(p_namtitlt,1,10),10,' ')||
		  						 rpad((rtrim(p_namfirstt)||' '||rtrim(p_namlastt)),45,' ')||
		  						 lpad(ltrim(to_char(p_amtprove,'9999999.99')),10,'0')||
									 lpad(ltrim(to_char(p_amtprovc,'9999999.99')),10,'0')||
									 lpad(ltrim(to_char(0,'9999999.99')),10,'0')||
									 rpad(substr(v_numtaxid,1,10),10,' ')||
									 v_flgnew||rpad(substr(p_numfund,1,5),5,' ')||
									 substr(to_char(to_number(to_char(p_dteeffec,'yyyy')) - p_global + 543),3,2)||
									 to_char(p_dteeffec,'mm')||to_char(p_dteeffec,'dd')||
									 substr(to_char(to_number(to_char(p_dtereti,'yyyy')) - p_global + 543),3,2)||
									 to_char(p_dtereti,'mm')||to_char(p_dtereti,'dd')||
									 lpad(ltrim(to_char(0,'9999999999.99')),13,'0')||
									 lpad(ltrim(to_char(0,'9999999999.99')),13,'0')||
									 lpad(ltrim(to_char(0,'9999999999.99')),13,'0')||
									 lpad(ltrim(to_char(0,'9999999999.99')),13,'0')||
									 lpad(ltrim(to_char(0,'9999999999.99')),13,'0')||
									 lpad(ltrim(to_char(0,'9999999999.99')),13,'0')||
									 lpad(ltrim(to_char(0,'9999999999.99')),13,'0')||
									 rpad(' ',35,' ');
      elsif p_pvdf = 5 then 				-- CIMB (?????????)
--<< user25 Thanittha :03/04/2017 : NTC-1601 ||
		  	begin
		  	 	select t1.numoffid,t2.numtaxid
		  	  into	 v_numoffid,v_numtaxid
		  	  from   temploy2 t1,temploy3 t2
		  	  where  t1.codempid = p_codempid
		  	  and    t1.codempid = t2.codempid;
		  	 exception when no_data_found then
		  	 	v_numoffid := null;
		  	 	v_numtaxid := null;
		  	 end;

		  	 begin
		  	   select nvl(stddec(amtcaccu,p_codempid,p_chken),0) amtcaccu,
		  	          nvl(stddec(amteaccu,p_codempid,p_chken),0) amteaccu
		  	   into   v_cimb_amtcaccu,v_cimb_amteaccu
				   from tpfmemb
				   where codempid   = p_codempid ;
		  	 exception when no_data_found then
		  	 	    v_cimb_amtcaccu :=0;
		  	 	    v_cimb_amteaccu :=0;
	      end;
		  	 if v_numoffid = v_numtaxid then
		  	 	v_numtaxid := null;
		  	 end if;

		  	 p_text := rpad(substr(p_numfund,1,5),5,' ')||				      											-- ??????????
		  						 rpad(substr(p_nummember,1,13),13,' ')||			  												-- ??????????
		  						 rpad(substr(rtrim(p_namtitlt),1,20),20,' ')||      										-- ????????????
		  						 rpad(substr(rtrim(p_namfirstt),1,60),60,' ')||       									-- ?????????
		  						 rpad(substr(rtrim(p_namlastt),1,60),60,' ')|| 													-- ?????????????

		  						 rpad(get_comp_split(p_codcomp,4),5,' ')||     															-- ????????
		  						 rpad(get_comp_split(p_codcomp,3),5,' ')||      										  				-- ????????

		  						 rpad(substr(p_codempid,1,13),13,' ')||  									    					-- ???????????

			  				   lpad(v_cimb_amtcaccu*100,10,0)||   											-- ?????????????????
									 lpad(v_cimb_amteaccu*100,10,0)||   											-- ???????????????

		  						 to_char(p_dteeffec,'yyyymmdd')||																				-- ????????????????
		  						 to_char(p_dteempmt,'yyyymmdd');																				-- ????????????????

		  	 /*--<<comment  user25 Thanittha : 04/04/2017 : NTC-600017
		  	 begin
		  	 	select t1.numoffid,t2.numtaxid
		  	  into	 v_numoffid,v_numtaxid
		  	  from   temploy2 t1,temploy3 t2
		  	  where  t1.codempid = p_codempid
		  	  and    t1.codempid = t2.codempid;
		  	 exception when no_data_found then
		  	 	v_numoffid := null;
		  	 	v_numtaxid := null;
		  	 end;
		  	 if v_numoffid = v_numtaxid then
		  	 	v_numtaxid := null;
		  	 end if;
		  	 p_text := rpad(substr(p_numfund,1,3),3,' ')||      -- ??????????
		  						 rpad(substr(p_numcomp,1,2),2,' ')||      -- ??????????
		  						 rpad(substr(p_nummember,1,10),10,' ')||  -- ??????????
		  						 rpad(substr(p_codcomp,1,8),8,' ')||      -- ????????????
		  						 rpad((rtrim(p_namtitlt)||rtrim(p_namfirstt)||' '||rtrim(p_namlastt)),50,' ')||'1'|| -- ????????,????,???????,????????????
		  						 lpad(to_char(p_amtprove * 100),11,'0')||rpad('0',11,'0')|| -- ????????
									 lpad(to_char(p_amtprovc * 100),11,'0')||rpad('0',11,'0')|| -- ??????????????????
									 rpad('0',11,'0')||rpad('0',11,'0')||
									 substr(to_char(to_number(to_char(p_dtepay,'yyyy')) - p_global + 543),3,2)||
									 to_char(p_dtepay,'mm')||to_char(p_dtepay,'dd')||                 						-- ???????????????
									 rpad(substr(v_numoffid,1,13),13,' ')||                                       -- ??????????????????
									 rpad(substr(v_numtaxid,1,10),10,' '); */                                       -- ??????????????????????
            -->> user25 Thanittha :03/04/2017 : NTC-1601 ||

      elsif p_pvdf = 6 then 				--?????????????
      	 if p_flg = 1 then
            p_text := '1'||';'||rpad(substr(p_numfund,1,7),7,' ')||';'||
  								    rpad(substr(p_nummember,1,12),12,' ')||';'||
  								    rpad(rtrim(p_namempt),50,' ')||';'||
  								    to_char(p_dteempmt,'dd')||'/'||to_char(p_dteempmt,'mm')||'/'||
									    lpad((to_number(to_char(p_dteempmt,'yyyy')) - p_global + 543),4,'0')||';'||
									    to_char(p_dteeffec,'dd')||'/'||to_char(p_dteeffec,'mm')||'/'||
									    lpad((to_number(to_char(p_dteeffec,'yyyy')) - p_global + 543),4,'0')||';'||
									    '1'||';'||'1'||';'||'1'||';'||
									    lpad(ltrim(to_char(p_amtprove,'99999999999.99')),14,'0')||';'||
									    lpad(ltrim(to_char(p_amtprovc,'99999999999.99')),14,'0')||';'||
									    '2'||';'||
									    lpad(ltrim(to_char(0,'99999999999.99')),14,'0')||';'||
									    lpad(ltrim(to_char(0,'99999999999.99')),14,'0')||';'||
									    rpad(substr(p_codcomp,1,10),10,' ');
         else
  			    p_text :=	'1'||';'||rpad(substr(p_numfund,1,7),7,' ')||';'||'1'||';'||
  										lpad(p_dtemthpay,2,'0')||'/'||lpad((p_dteyrepay - p_global + 543),4,'0')||';'||
  										rpad(substr(p_nummember,1,12),12,' ')||';'||
  										lpad(ltrim(to_char(p_amtprove,'99999999999.99')),14,'0')||';'||
											lpad(ltrim(to_char(p_amtprovc,'99999999999.99')),14,'0')||';'||
											rpad(rtrim(p_namempt),50,' ')||';'||
  										rpad(substr(p_codcomp,1,10),10,' ')||';'||
  										rpad(' ',12,' ');
         end if;
      elsif p_pvdf = 7 then 				--????????????????
		  	 p_text := rpad(substr(p_numfund,1,6),6,' ')||
		  						 rpad(substr(p_numcomp,1,3),3,' ')||
		  						 rpad(' ',10,' ')||
		  						 rpad(substr(p_nummember,1,8),8,' ')||
		  						 rpad(substr(p_codempid,1,8),8,' ')||
		  						 rpad(substr(p_namtitlt||p_namfirstt||'  '||p_namlastt,1,50),50,' ')||
		  						 rpad(' ',40,' ')||
		  						 lpad(to_char(p_amtprove * 100),10,'0')||
									 lpad(to_char(p_amtprovc * 100),10,'0')||
									 to_char(p_dteempmt,'dd')||to_char(p_dteempmt,'mm')||
									 to_char(to_number(to_char(p_dteempmt,'yyyy')) - p_global + 543)||
									 to_char(p_dteeffec,'dd')||to_char(p_dteeffec,'mm')||
									 to_char(to_number(to_char(p_dteeffec,'yyyy')) - p_global + 543)||
									 to_char(p_dtepay,'dd')||to_char(p_dtepay,'mm')||
									 to_char(to_number(to_char(p_dtepay,'yyyy')) - p_global + 543);
      elsif p_pvdf = 8 then 				-- MFC

				begin
				 select dtepaymt into v_dtepay
				 from tdtepay
				 where codcompy   = hcm_util.get_codcomp_level(p_codcomp,1)
				   and typpayroll = p_typpayroll
				   and numperiod  = p_numperiod
				   and dtemthpay  = p_dtemthpay
				   and dteyrepay  = p_dteyrepay - p_global;
				exception when no_data_found then
					v_dtepay := p_dtepay;
				end;

				begin
					select a.codplan,a.dteeffec
					  into v_codplan2,v_dteeffec2
					  from tpfirinf a
					 where a.codempid =  p_codempid
					   and a.dteeffec = (select max(b.dteeffec)
											           from tpfirinf b
											          where b.codempid = a.codempid
											            and b.dteeffec <= trunc(sysdate))
					   and rownum <= 1;
				exception when no_data_found then
					v_codplan2   := null;
					v_dteeffec2  := null;
				end;

				p_text := rpad(get_comp_split(p_codcomp,1),5,' ')||
				         rpad(p_codempid,15,' ')||
				         rpad(' ',20,' ')||
				         rpad(p_namtitlt,30,' ')||
				         rpad(p_namfirstt,40,' ')||
				         rpad(p_namlastt,110,' ')||
				         to_char(v_dtepay,'dd')||to_char(v_dtepay,'mm')||to_char(to_number(to_char(v_dtepay,'yyyy')) - p_global)||
				         lpad(ltrim(to_char(p_amtprove,'99999999.99')),11,'0')||
                     lpad(ltrim(to_char(p_amtprovc,'99999999.99')),11,'0')||
							lpad(' ',11,' ')||
							rpad(' ',50,' ')||
--<<redmine-PY-2467
							--rpad(substr(v_codplan2,1,2),2,' ');
                     rpad(substr(v_codplan2,1,4),4,' ');
-->>redmine-PY-2467

      elsif p_pvdf = 9 then 				--AIA
				begin
					select a.codplan,a.dteeffec
					  into v_codplan2,v_dteeffec2
					  from tpfirinf a
					 where a.codempid =  p_codempid
					   and a.dteeffec = (select max(b.dteeffec)
											           from tpfirinf b
											          where b.codempid = a.codempid
											            and b.dteeffec <= trunc(sysdate))
					   and rownum <= 1;
				exception when no_data_found then
					v_codplan2   := null;
					v_dteeffec2  := null;
				end;

				for i in 1..10 loop
					v_codpolicy(i)  := '  ';
					v_amteaccu(i)   := 0.00;
					v_amtcaccu(i)   := 0.00;
					v_amtincom(i)   := null;
				end loop;

				v_numseq   := 0;
				v_totamte  := 0;
				v_totamtc  := 0;
				v_codplan  :='  ';
            v_codcompny    := hcm_util.get_codcomp_level(p_codcomp,1);
				for i in c_tpfirinf loop
					v_numseq  := v_numseq + 1;
					v_codplan := i.codplan;
					v_codpolicy(v_numseq)  := i.codpolicy;
					v_amteaccu(v_numseq)   := round((nvl(p_amtprove,0) * nvl(i.qtycompst,0))/100,2);
					v_amtcaccu(v_numseq)   := round((nvl(p_amtprovc,0) * nvl(i.qtycompst,0))/100,2);
					v_totamte  := v_totamte + v_amteaccu(v_numseq);
					v_totamtc  := v_totamtc + v_amtcaccu(v_numseq);
					if v_numseq = 5 then
						exit;
					end if;
				end loop; --i in c_tpfirinf loop

				v_totamte := nvl(v_totamte,0) - nvl(p_amtprove,0);
				v_totamtc := nvl(v_totamtc,0) - nvl(p_amtprovc,0);

				v_amteaccu(1) := v_amteaccu(1) - v_totamte;
				v_amtcaccu(1) := v_amtcaccu(1) - v_totamtc;
				begin
					select a.codsex,a.codempmt,b.numoffid,c.numtaxid,
					       nvl(stddec(amtincom1,a.codempid,p_chken),0),
								 nvl(stddec(amtincom2,a.codempid,p_chken),0),
								 nvl(stddec(amtincom3,a.codempid,p_chken),0),
								 nvl(stddec(amtincom4,a.codempid,p_chken),0),
								 nvl(stddec(amtincom5,a.codempid,p_chken),0),
								 nvl(stddec(amtincom6,a.codempid,p_chken),0),
								 nvl(stddec(amtincom7,a.codempid,p_chken),0),
								 nvl(stddec(amtincom8,a.codempid,p_chken),0),
								 nvl(stddec(amtincom9,a.codempid,p_chken),0),
								 nvl(stddec(amtincom10,a.codempid,p_chken),0)
					  into v_sex,v_codempmt,v_numoffid,v_numtaxid,
					       v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
					       v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10)
					  from temploy1 a,temploy2 b,temploy3 c
					 where a.codempid = p_codempid
					   and a.codempid = b.codempid(+)
					   and a.codempid = c.codempid(+);
				exception when no_data_found then
					v_numoffid := ' ';
					v_numtaxid := ' ';
					v_sex			 := ' ';
				end;

				v_amtmth  := 0;
				get_wage_income(hcm_util.get_codcomp_level(p_codcomp,1),v_codempmt,
                                    v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
                                     v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
                                     v_amthur,v_amtday,v_amtmth);

				 p_text := rpad(substr(v_codplan,1,4),4,' ')||
                           rpad(substr(p_codempid,1,10),15,' ')||
                           rpad(substr(p_namtitlt,1,15),15,' ')||
                           rpad(substr(p_namfirstt,1,25),25,' ')||										--4.First name
                           rpad(substr(p_namlastt,1,40),40,' ')||
                           to_char(p_dteempmt,'dd')||to_char(p_dteempmt,'mm')||
                           to_char(to_number(to_char(p_dteempmt,'yyyy')) - p_global)||--6.DOE dteempmt
                           to_char(p_dteeffec,'dd')||to_char(p_dteeffec,'mm')||
                           to_char(to_number(to_char(p_dteeffec,'yyyy')) - p_global)||--7.DOP dteeffec
                           rpad(substr(v_numoffid,1,13),13,' ')||
                           rpad(substr(v_numtaxid,1,10),10,' ')||											--9.TAX ID
                           lpad(ltrim(to_char(p_amtprove,'999999990.99')),12,' ')||
                           lpad(ltrim(to_char(p_amtprovc,'999999990.99')),12,' ')||   --11.TOTAL_ER CONT
                           lpad(ltrim(to_char(v_amtmth,'999999990.00')),12,' ')||			--12.SALARY
                           rpad(substr(p_codcomp,1,40),40,' ')||rpad(substr(v_sex,1,1),1,' ')||--14.SEX
                           rpad(substr(v_codpolicy(1),1,4),4,' ')||										--15.FUND1
                           lpad(ltrim(to_char(v_amteaccu(1),'999999990.99')),12,' ')||
                           lpad(ltrim(to_char(v_amtcaccu(1),'999999990.99')),12,' ')||
                           rpad(substr(v_codpolicy(2),1,4),4,' ')||										--18.FUND2
                           lpad(ltrim(to_char(v_amteaccu(2),'999999990.99')),12,' ')||
                           lpad(ltrim(to_char(v_amtcaccu(2),'999999990.99')),12,' ')||
                           rpad(substr(v_codpolicy(3),1,4),4,' ')||										--21.FUND3
                           lpad(ltrim(to_char(v_amteaccu(3),'999999990.99')),12,' ')||
                           lpad(ltrim(to_char(v_amtcaccu(3),'999999990.99')),12,' ')||
                           rpad(substr(v_codpolicy(4),1,4),4,' ')||										--24.FUND4
                           lpad(ltrim(to_char(v_amteaccu(4),'999999990.99')),12,' ')||
                           lpad(ltrim(to_char(v_amtcaccu(4),'999999990.99')),12,' ')||
                           rpad(substr(v_codpolicy(5),1,4),4,' ')||										--27.FUND5
                           lpad(ltrim(to_char(v_amteaccu(5),'999999990.99')),12,' ')||
                           lpad(ltrim(to_char(v_amtcaccu(5),'999999990.99')),12,' ');

			elsif p_pvdf = 10 then  --Modify 22/05/2551 --
				--????????????????--
				begin
				    select t1.dteempdb,t1.dteeffex,t2.numtaxid
						into v_dteempdb,v_dteeffex,v_numtaxid
						from temploy1 t1,temploy3 t2
						where	t1.codempid = p_codempid
						and		t1.codempid = t2.codempid;
				 exception when no_data_found then
						v_numtaxid := ' ';
						v_dteempdb := ' ';
						v_dteeffex := ' ';
				 end;
				 if v_numtaxid is null then
				 		v_numtaxid := ' ';
				 end if;
				 if v_dteeffex is null then
				 	v_out := null;
				 else
				 	v_out := to_char(p_dteempmt,'dd')||to_char(v_dteeffex,'mm')||
									 lpad((to_number(to_char(v_dteeffex,'yyyy')) - p_global + 543),4,'0');
				 end if;
				 -- ??????????????????
				 for i in c1 loop
				 	if i.numseq = 1 then
				 		v_nampfic1	:= i.nampfic;
				 		v_ratepf1   := i.ratepf;
				 	elsif i.numseq = 2 then
				 		v_nampfic2	:= i.nampfic;
				 		v_ratepf2   := i.ratepf;
				 	elsif i.numseq = 3 then
				 		v_nampfic3	:= i.nampfic;
				 		v_ratepf3   := i.ratepf;
				 	else
				 		v_nampfic1	:= ' ';v_ratepf1 := ' ';
				 		v_nampfic2	:= ' ';v_ratepf2 := ' ';
				 		v_nampfic3	:= ' ';v_ratepf3 := ' ';
				 	end if;
				 end loop	;
				 --?????????????????????????
				 begin
				 	select pctcompf
				 	into	 v_pctcompf
				 	from	 ttaxcur
				 	where  codempid 	= p_codempid
				 	and		 dteyrepay 	= p_dteyrepay - p_global
				 	and		 dtemthpay 	= p_dtemthpay
				 	and		 numperiod	= p_numperiod;
				 exception when no_data_found then
				 	v_pctcompf := ' ';
				 end;
				 -- ?????????,???????????????? --
				 get_service_year(p_dteempmt,nvl(p_dtereti,sysdate),'Y',v_year,v_month,v_day);
				 if p_dteeffec is not null then
				 	get_service_year(p_dteeffec,nvl(p_dtereti,sysdate),'Y',v_year1,v_month1,v_day1);
				 end if;

				 p_text := rpad(substr(p_codcomp,1,5),5,' ')||
				 					 rpad(substr(p_codempid,1,15),15,' ')||
				 					 rpad(substr(p_codcomp,1,20),20,' ')||
				 					 rpad(substr(p_namtitlt,1,30),30,' ')||
									 rpad(substr(p_namfirstt,1,40),40,' ')||
									 rpad(substr(p_namlastt,1,110),110,' ')||
									 to_char(p_dtepay,'dd')||to_char(p_dtepay,'mm')||
									 to_char(to_number(to_char(p_dtepay,'yyyy')) - p_global + 543)||
									 lpad(ltrim(to_char(p_amtprove,'9999990.99')),11,' ')||
									 lpad(ltrim(to_char(p_amtprovc,'9999990.99')),11,' ');
			elsif p_pvdf = 11 then   -- ???.?????

				 p_text := lpad(substr(p_numcomp,1,4),4,'0')||lpad(substr(p_numfund,1,3),3,'0')||
				           rpad(substr(p_nummember,1,10),10,' ')||rpad(substr(p_namempt,1,50),50,' ')||
				           to_char(p_dteempmt,'dd')||to_char(p_dteempmt,'mm')||
									 lpad((to_number(to_char(p_dteempmt,'yyyy')) - p_global + 543),4,'0')||
				           to_char(p_dteeffec,'dd')||to_char(p_dteeffec,'mm')||
									 lpad((to_number(to_char(p_dteeffec,'yyyy')) - p_global + 543),4,'0')||
				           to_char(p_dteeffec,'dd')||to_char(p_dteeffec,'mm')||
									 lpad((to_number(to_char(p_dteeffec,'yyyy')) - p_global + 543),4,'0')||
									 lpad(ltrim(to_char(p_amtprove,'999999999990.99')),15,' ')||
									 lpad(ltrim(to_char(p_amtprovc,'999999999990.99')),15,' ');

			elsif p_pvdf = 12 then   -- ????????? (???.)

				-- find status--
			  begin
				 select nvl(numlvl,0),codempmt,codbrlc into v_numlvl , v_codempmt , v_codbrlc
				 from temploy1
				 where codempid = p_codempid
				   and rownum = 1;

				   if v_numlvl between 1 and 5 then
					   begin
					 	   select unitcal1 into v_unitcal1
					 	   from tcontpmd
					 	   where codempmt = v_codempmt
					 	     and dteeffec = (select max(dteeffec)
					 	                      from tcontpmd
					 	                      where codempmt = v_codempmt)
					 	     and rownum = 1;
					 	   if v_unitcal1 in ('H','D') then
					 	  	 v_sta := 'D';
					 	   else
					 	  	 v_sta := 'S';
					 	   end if;
					   exception when no_data_found then
					   	 v_sta := '  ';
					   end;
				   elsif v_numlvl = 6 then
				 	  v_sta := 'E1';
				   elsif v_numlvl = 7 then
				  	v_sta := 'E2';
				   elsif v_numlvl >= 8 then
				    v_sta := 'E';
				   else
				  	v_sta := '  ';
				   end if;
			  exception when no_data_found then
			  	v_numlvl    := 0;
 			  	v_codempmt  := null;
 			  	v_sta       := '  ';
			  end;

			  --find dtepay --
			  begin
			   select dtepaymt into v_dtepay
			   from tdtepay
			   where codcompy   = hcm_util.get_codcomp_level(p_codcomp,1)
			     and typpayroll = p_typpayroll
			     and numperiod  = p_numperiod
			     and dtemthpay  = p_dtemthpay
			     and dteyrepay  = p_dteyrepay - p_global;
			  exception when no_data_found then
			  	v_dtepay := p_dtepay;
			  end;

			   p_text := rpad(substr(p_numcomp,1,8),8,' ')||rpad(substr(p_numfund,1,3),3,' ')||
			             rpad(substr(p_codempid,1,15),15,' ')||rpad(substr(v_sta,1,2),2,' ')||
			             rpad(substr(p_namtitlt,1,15),15,' ')||rpad(substr(p_namfirstt,1,25),25,' ')||
			             rpad(substr(p_namlastt,1,45),45,' ')||rpad(substr(v_codbrlc,1,15),15,' ')||
			             rpad((get_comp_split(p_codcomp,3)||get_comp_split(p_codcomp,6)||get_comp_split(p_codcomp,7)),15,' ')||
                   lpad(to_char(p_amtprove * 100),11,'0')||
									 lpad(to_char(p_amtprovc * 100),11,'0')||
									 rpad('0',11,'0')||rpad('0',11,'0')||
									 to_char(v_dtepay,'dd')||to_char(v_dtepay,'mm')||
									 to_char(to_number(to_char(v_dtepay,'yyyy')) - p_global + 543)||
									 rpad(' ',1,' ')||rpad(' ',1,' ')||rpad(' ',1,' ')||rpad(' ',1,' ')||rpad(' ',1,' ')||
									 rpad(' ',55,' ');

      elsif p_pvdf = 13 then 				--?????????????
		  	 begin
				    select numoffid into v_numoffid
						  from temploy1 a,temploy2 b
						 where a.codempid = p_codempid
						   and a.codempid = b.codempid(+);
            exception when no_data_found then
						v_numoffid := ' ';
         end;

		  	 p_text := rpad(substr(p_numfund,1,5),5,' ')||','||
                        rpad(substr(p_numcomp,1,4),4,' ')||','||
                        rpad(substr(v_numoffid,1,13),13,' ')||','||
                        rpad(substr(p_namtitlt,1,30),30,' ')||','||
                        rpad(substr(p_namfirstt,1,100),100,' ')||','||
                        rpad(substr(p_namlastt,1,100),100,' ')||','||
                        rpad(substr(p_codcomp,1,10),10,' ')||','||
                        to_char(p_dteempmt,'dd')||to_char(p_dteempmt,'mm')||to_char(to_number(to_char(p_dteempmt,'yyyy')) - p_global)||','||  --?? ?????????
                        to_char(p_dteeffec,'dd')||to_char(p_dteeffec,'mm')||to_char(to_number(to_char(p_dteeffec,'yyyy')) - p_global)||','||  --?? ?????????
--<<redmine-PY-2471
                        --to_char(p_amtprove)||','||to_char(p_amtprovc);
                        trim(to_char(p_amtprove,'999999999990.99'))||','||trim(to_char(p_amtprovc,'999999999990.99'));
-->>redmine-PY-2471

      elsif p_pvdf = 14 then 				--?????? ????????
		  	 begin
				    select numoffid into v_numoffid
						  from temploy1 a,temploy2 b
						 where a.codempid = p_codempid
						   and a.codempid = b.codempid(+);
				 exception when no_data_found then
						v_numoffid := ' ';
				 end;

		  	 begin
				    select numtaxid
						into v_numtaxid
						from temploy3
						where	codempid = p_codempid;
				 exception when no_data_found then
						v_numtaxid := ' ';
				 end;

				 if length(p_codempid) < 8 then
				 		v_codempid := lpad(p_codempid,7,'0');
				 else
				 		v_codempid := substr(p_codempid,length(p_codempid)-6,length(p_codempid));
				 end if;

				 if nvl(p_amtprove,0) = 0 then
				 		v_SuspendFlag := 'S';
				 else
				 		v_SuspendFlag := ' ';
				 end if;

		  	 p_text := --rpad(substr(p_codcomp,1,5),5,' ')||			--Comp_code
                        rpad(substr(p_numfund,1,5),5,' ')||			--Comp_code
                        rpad(p_codempid,13,' ')||	--FAM Account No.
                        rpad(p_namempt,58,' ')||		--Emp_Name
                        lpad('0',3,'0')||			--Department Code
                        v_codempid|| --Customer Code
                        replace(lpad(ltrim(to_char(p_amtprovc,'99999990.99')),11,'0'),'.','')|| 	--Company Contribution
                        replace(lpad(ltrim(to_char(p_amtprove,'99999990.99')),11,'0'),'.','')||	--Employee Contribution
                        rpad('0',10,'0')||				--Over15% Contribution
                        lpad(' ',8,' ')||				--filter
                        to_char(to_number(to_char(p_dteeffec,'yyyy')) - p_global)||to_char(p_dteeffec,'dd')||to_char(p_dteeffec,'mm')||  --?? ?????????					--Entry date
                        rpad(' ',8,' ')||			--Resignation Date
                        rpad(' ',1,' ')||		  --mark
                        rpad(substr(v_numtaxid,1,10),10,' ')||	--Tax No
                        rpad(substr(v_numoffid,1,13),13,' ')||	--ID No
                        v_SuspendFlag||									--Suspend Flag
                        rpad(' ',5,' ');		 			  --choice

			elsif p_pvdf = 16 then
			  --find dtepay --
			  begin
			   select dtepaymt into v_dtepay
			   from tdtepay
			   where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
			     and typpayroll = p_typpayroll
			     and numperiod = p_numperiod
			     and dtemthpay = p_dtemthpay
			     and dteyrepay = p_dteyrepay - p_global;
			  exception when no_data_found then
			  	v_dtepay := p_dtepay;
			  end;

--IN4+' ' + ID8+ '27' +title+ '27' +name  (40) + ??????? (40)+  '70' + tdtepay.DTEPAYMT (?.?.) + 8.2 + 8.2 + ' '+'60'

						p_text  :=rpad(substr(nvl(p_numfund,'0185'),1,4),4,' ')||' '||rpad(p_codempid,35,' ')||
											rpad(substr(p_namtitlt,1,30),30,' ')||
											rpad(substr(p_namfirstt,1,40),40,' ')||
											rpad(substr(p_namlastt,1,110),110,' ')||
											to_char(v_dtepay,'dd')||to_char(v_dtepay,'mm')||to_char(to_number(to_char(v_dtepay,'yyyy')) - p_global + 543)||
									    lpad(ltrim(to_char(p_amtprove,'99999990.99')),11,'0')||	                  --Employee Contribution
									    lpad(ltrim(to_char(p_amtprovc,'99999990.99')),11,'0')|| 	                --Company Contribution
											rpad(' ',11,' ')||
											rpad(' ',50,' ');
			elsif p_pvdf = 17 then --- KATM Kung Thai

				begin
				 select dtepaymt into v_dtepay
				 from tdtepay
				 where codcompy   = hcm_util.get_codcomp_level(p_codcomp,1)
				   and typpayroll = p_typpayroll
				   and numperiod  = p_numperiod
				   and dtemthpay  = p_dtemthpay
				   and dteyrepay  = p_dteyrepay - p_global;
				exception when no_data_found then
					v_dtepay := p_dtepay;
				end;

      	 if p_flg = 1 then

					begin
					    select t1.dteempdb,t1.dteeffex,t2.numtaxid,t3.numoffid
							  into v_dteempdb,v_dteeffex,v_numtaxid,v_numoffid
							  from temploy1 t1,temploy3 t2,temploy2 t3
							where	t1.codempid = p_codempid
							  and	t1.codempid = t2.codempid
							  and	t1.codempid = t3.codempid;
					 exception when no_data_found then
							v_numtaxid := ' ';
							v_dteempdb := ' ';
							v_dteeffex := ' ';
							v_numoffid := ' ';
					 end;

						p_text := rpad(substr(p_numcomp,1,5),5,' ')||
											rpad(p_codempid,15,' ')||
											rpad(substr(p_codcomp,1,20),20,' ')||
											rpad(substr(p_namtitlt,1,30),30,' ')||
											rpad(substr(p_namfirstt,1,40),40,' ')||
											rpad(substr(p_namlastt,1,110),110,' ')||
										  rpad(substr(v_numtaxid,1,10),10,' ')||	--Tax No
										  rpad(substr(v_numoffid,1,13),13,' ')||	--ID No
										  to_char(v_dteempdb,'dd')||to_char(v_dteempdb,'mm')||to_char(to_number(to_char(v_dteempdb,'yyyy')) - p_global + 543)||
										  to_char(p_dteempmt,'dd')||to_char(p_dteempmt,'mm')||lpad((to_number(to_char(p_dteempmt,'yyyy')) - p_global + 543),4,'0')||
										  to_char(p_dteeffec,'dd')||to_char(p_dteeffec,'mm')||lpad((to_number(to_char(p_dteeffec,'yyyy')) - p_global + 543),4,'0')||
										  to_char(p_dteeffec,'dd')||to_char(p_dteeffec,'mm')||lpad((to_number(to_char(p_dteeffec,'yyyy')) - p_global + 543),4,'0')||
										  rpad(' ',1,' ')||
										  rpad(' ',40,' ')||
										  rpad(' ',6,' ')||
										  rpad(' ',40,' ')||
										  rpad(' ',6,' ')||
										  rpad(' ',40,' ')||
										  rpad(' ',6,' ');
					else
						p_text1 :=rpad(substr(p_numcomp,1,5),5,' ')||
						          rpad(p_codempid,15,' ')||
						          rpad(substr(p_codcomp,1,20),20,' ')||
											rpad(substr(p_namtitlt,1,30),30,' ')||
											rpad(substr(p_namfirstt,1,40),40,' ')||
											rpad(substr(p_namlastt,1,110),110,' ')||
											to_char(v_dtepay,'dd')||to_char(v_dtepay,'mm')||to_char(to_number(to_char(v_dtepay,'yyyy')) - p_global + 543)||
											lpad(ltrim(to_char(p_amtprove,'99999999999.99')),11,'0')||
											lpad(ltrim(to_char(p_amtprovc,'99999999999.99')),11,'0')||
											rpad(' ',11,' ')||
											rpad(' ',50,' ');
         end if;
			elsif p_pvdf = 18 then 	--  k-asset  RIST

		  	if p_flg = 1 then -- new member
		  		v_flgnew := 'N';
		  	elsif p_flg = 2 then  -- change data
		  		v_flgnew := 'C';
		  	else
		  		v_flgnew := 'A';  -- normal
		  	end if;

	  	  begin
			    select numoffid
					into v_numoffid
					from temploy2
					where	codempid = p_codempid;
			  exception when no_data_found then
					v_numoffid := ' ';
			  end;
			  if v_numoffid is null then
			 		v_numoffid := ' ';
			  end if;

			  p_text := 'B'||v_flgnew||rpad(substr(p_nummember,1,15),15,' ')||
                        rpad(substr(p_namtitlt,1,7),7,' ')||
                        rpad(substr(p_namfirstt,1,50),50,' ')||
                        rpad(substr(p_namlastt,1,50),50,' ')||
                        lpad(substr(to_char(p_amtprove * 100),1,11),11,'0')||
                        lpad(substr(to_char(p_amtprovc * 100),1,11),11,'0')||
                        rpad(' ',11,' ')||rpad(' ',11,' ')||
                        rpad(get_comp_split(p_codcomp,1),4,' ')||rpad(substr(v_numoffid,1,13),13,' ');

			elsif p_pvdf = 99 then			-- Modify ?????????
			   p_text := null;

			end if;

   END;  
END;

/

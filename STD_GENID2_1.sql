--------------------------------------------------------
--  DDL for Package Body STD_GENID2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_GENID2" IS
  PROCEDURE gen_id
		(p_codcomp   in  varchar2,
  	 p_codempmt  in  varchar2,
  	 p_codbrlc   in  varchar2,
  	 p_dteempmt  in  date,
  	 p_groupid   out varchar2,
  	 p_id        out varchar2,
		 p_year      out number,
		 p_month     out number,
		 p_running   out varchar2,
		 p_table     out varchar2,
		 p_error     out varchar2) is

		v_year		   number :=  9999;
		v_month		   number :=  99;
		v_id			   varchar2(20 char);
		v_running    varchar2(10 char);
		v_length     number;
		v_stmt		   varchar2(4000 char);
		v_count      number;
		v_rn         number;
		v_flgfound	 boolean;
		v_cond			 varchar2(1000 char);
		v_groupid    varchar2(10 char);
		type valueid is table of varchar2(1000 char) index by binary_integer;
			v_value valueid;
		cursor c_tsempidh is
			select groupid,syncond
			from tsempidh
			order by groupid;
  	cursor c1 is
			select numseq,groupid,typgrpid,typeval
			from   tsempidd
			where  groupid = v_groupid
			order by numseq;

  begin
  		<< tsempidh_loop >>
	for r_tsempidh in c_tsempidh loop
		v_flgfound := true;
		if r_tsempidh.syncond is not null then
			v_cond := r_tsempidh.syncond;
			v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||p_codcomp ||'''');
			v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||p_codempmt||'''');
			v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||p_codbrlc||'''');
			v_stmt := 'select count(*) from dual where '||v_cond;
			v_flgfound := execute_stmt(v_stmt);
		end if;
		if v_flgfound then
			v_groupid := r_tsempidh.groupid;
			exit tsempidh_loop;
		end if;
	end loop;
	if v_groupid is not null then
		p_groupid  := v_groupid;
	else
		p_error := 'HR2055';
		p_table := 'TSEMPIDH';
		return;
	end if;
----------------------------------------------------------
		for i in 1..5 loop
			v_value(i) := null;
		end loop;
  	for i in c1 loop
	  		if i.typgrpid = 'CE' then
	  				v_value(i.numseq) := substr(to_number(to_char(p_dteempmt,'yyyy'))+543,3,2);--User37 #6760 03/09/2021 v_value(i.numseq) := to_char(p_dteempmt,'yy');
	  				v_year := to_number(to_char(p_dteempmt,'yyyy'));
	  		elsif i.typgrpid = 'BE' then
	  				v_value(i.numseq) := to_char(p_dteempmt,'yy','NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI');
	  				v_year := to_number(to_char(p_dteempmt,'yyyy','NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI'));
	  		elsif i.typgrpid = 'AD' then -- user4 || 13/10/2022
	  				v_value(i.numseq) := substr(to_number(to_char(p_dteempmt,'yyyy')),3,2);
	  				v_year := to_number(to_char(p_dteempmt,'yyyy'));
	  		elsif i.typgrpid = 'MT' then
	  				v_value(i.numseq) := to_char(p_dteempmt,'mm');
	  				v_month := to_number(to_char(p_dteempmt,'mm'));
	  		elsif i.typgrpid = 'RN' then
	  			v_rn := i.numseq;
	  			v_length := length(i.typeval);
	  		elsif i.typgrpid = 'ST' then
	  				v_value(i.numseq) := i.typeval;
	  		end if;
	  end loop;
	  --
	  if v_rn is not null then
	  	--
            begin
				select to_char(running+1)
				  into v_value(v_rn)
				  from trunempid
				 where groupid  =  v_groupid
				   and ((dteyear  =  v_year) or (v_year = '9999' and dteyear = '99') or (v_year = '9999' and dteyear = '9999'))
				   and dtemonth =  v_month;
			exception when no_data_found then
				begin
					select typeval+1
						into v_value(v_rn)
					  from tsempidd
					 where groupid   =  v_groupid
				     and typgrpid  = 'RN';
				exception when no_data_found then
					null;
				end;
      end;
        if length(v_value(v_rn)) < 	v_length then
				v_value(v_rn) := lpad(v_value(v_rn),v_length,'0');
			end if;
			if length(v_value(v_rn)) > 	v_length then
				  p_error := 'PM0081';
				  p_table := null;
					return;
			end if;
	  end if;
	  --
			<< check_loop>>
			loop
				v_id := v_value(1)||v_value(2)||v_value(3)||v_value(4)||v_value(5);
				v_id := upper(v_id);
				begin
					select 1
					into v_count
					from temploy1
					where codempid = v_id ;
					v_value(v_rn) := 	v_value(v_rn)+1;
					if length(v_value(v_rn)) < 	v_length then
						v_value(v_rn) := lpad(v_value(v_rn),v_length,'0');
					end if;
					exception when no_data_found then
						begin
							select 1
							into v_count
							from ttrehire
							where codnewid = v_id;
							v_value(v_rn) := 	v_value(v_rn)+1;
							if length(v_value(v_rn)) < 	v_length then
								v_value(v_rn) := lpad(v_value(v_rn),v_length,'0');
							end if;
					exception when no_data_found then
						v_running := v_value(v_rn);
		  			exit check_loop;
				  end;
				end;
    	end loop;
		  	p_id      := v_id;
		  	p_year    := v_year;
		  	p_month   := v_month;
		  	p_running := v_running;
  end;
 --------------------------------------------------------------------------------------------------------
  PROCEDURE upd_id
  	(p_groupid  in varchar2,
  	 p_year     in number,
  	 p_month		in number,
  	 p_running  in varchar2,
  	 p_coduser  in varchar2) is
     v_year number;--User37 #6760 03/09/2021 
  begin
    --<<User37 #6760 03/09/2021 
    if p_year > 2500 then
        v_year := p_year - 543;
    else
        v_year := p_year;
    end if;
    -->>User37 #6760 03/09/2021 
    begin
	    insert into trunempid(groupid,   dteyear,   dtemonth,
	                          running,   dteupd,    coduser)
					           values(p_groupid, v_year,    p_month,
					                  p_running, sysdate,   p_coduser);
	       exception when dup_val_on_index then
							begin
								update trunempid
								    set running  = p_running,
								        coduser  = p_coduser,
								        dteupd   = sysdate
								 where groupid   = p_groupid
								   and dteyear   = v_year
								   and dtemonth  = p_month;
								exception when no_data_found then null;
								    			when others then null;
							end;
    end;
	end; -- end upd_id
end;

/

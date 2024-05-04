--------------------------------------------------------
--  DDL for Package Body HRAL23B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL23B_BATCH" is
  procedure  start_process (p_codapp   varchar2,
                            p_coduser  varchar2,
                            p_numproc  number,
                            p_dtestr   in	date,
                            p_dteend   in	date ) is
  v_num      number := 0;
  v_dtestart date ;
  v_dteend   date ;
  v_time     varchar2(100);

  cursor c_temploy1 is
    select a.codempid,codcomp,codcalen,numlvl,staemp,dteempmt,dteeffex,typpayroll,flgatten,codempmt
      from temploy1 a,tprocemp b
     where a.codempid = b.codempid
       and b.codapp  = p_codapp
       and b.coduser = p_coduser
       and b.numproc = p_numproc;

  function cal_hhmiss(p_st	date,p_en date) return varchar IS
    v_num   number	:= 0;
    v_sc   	number	:= 0;
    v_mi   	number	:= 0;
    v_hr   	number	:= 0;
    v_time  varchar2(500);

  begin
    v_num	  :=  ((p_en - p_st) * 86400) + 1;  ---- 86400 = 24*60*60
    v_hr    :=  trunc(v_num/3600);
    v_mi    :=  mod(v_num,3600);
    v_sc    :=  mod(v_mi,60);
    v_mi    :=  trunc(v_mi/60);
    v_time  :=  lpad(v_hr,2,0)||':'||lpad(v_mi,2,0)||':'||lpad(v_sc,2,0);
    return(v_time);
  end;

  begin
    v_dtestart := sysdate;
    begin
      insert into tprocount (codapp , coduser, numproc ,qtyproc ) values (p_codapp , p_coduser, p_numproc ,0 ) ;
    exception when others then null;
    end;
    v_recs := 0 ;
    for i in  c_temploy1 loop
	     create_tattence (p_codapp,p_coduser,p_numproc,
	                      p_dtestr,p_dteend,
	                      i.codempid,
	                      i.codcomp,
	                      i.codcalen,
	                      i.codempmt,
	                      i.typpayroll,
	                      i.flgatten,
	                      i.dteempmt,
	                      i.dteeffex);
    end loop;
    v_dteend := sysdate;
    v_time   := cal_hhmiss(v_dtestart,v_dteend);

    update tprocount
       set qtyproc = v_recs
     where codapp  = p_codapp
       and coduser = p_coduser
       and numproc = p_numproc ;
    commit;
  end;
  --

  procedure create_tattence
     (p_codapp     varchar2,
      p_coduser    varchar2 ,
      p_data       varchar,
      p_dtestr  	 in	date,
      p_dteend  	 in	date,
      p_codempid	 in	temploy1.codempid%type,
      p_codcomp 	 in	temploy1.codcomp%type,
      p_codcalen	 in	temploy1.codcalen%type,
      p_codempmt	 in	temploy1.codempmt%type,
      p_typpayroll in	temploy1.typpayroll%type,
      p_flgatten	 in	temploy1.flgatten%type,
      p_dteempmt	 in	temploy1.dteempmt%type,
      p_dteeffex	 in	temploy1.dteeffex%type) is

    v_exist		boolean;
    v_stdate   tgrpplan.dtework%type;
    v_endate   tgrpplan.dtework%type;
    v_date     tgrpplan.dtework%type;
    v_codempid temploy1.codempid%type;
    v_codcalen tattence.codcalen%type;
    v_codshift tattence.codshift%type;
    v_dtestrtw tgrpplan.dtework%type;
    v_dteendw  tgrpplan.dtework%type;
    v_timstrtw tattence.timstrtw%type;
    v_timendw  tattence.timendw%type;

  cursor c_tattence is
    select rowid,dtein,dteout
      from tattence
     where codempid = v_codempid
       and dtework  = v_date;

  cursor c_tattence_del is
    select rowid,dtework
      from tattence
     where codempid = p_codempid
       and dtework  >= nvl(v_stdate,dtework)
       and dtework  < p_dteempmt;

  cursor c_twkchhr is
    select codempid,codcalen,codshift
      from twkchhr
     where codempid = p_codempid
       and v_date   between dtestrt and dteend
       and(codcalen is not null
        or codshift is not null)
  order by dtestrt desc;

  begin
    select max(dteeffec) into v_stdate
      from ttpminf
     where codempid = p_codempid
       and dteeffec < p_dteempmt
       and codtrn = '0006';

    for i in c_tattence_del loop
      delete tlateabs where codempid = p_codempid and dtework = i.dtework;
      delete tleavetr where codempid = p_codempid and dtework = i.dtework;
      delete tattence where rowid = i.rowid;
    end loop;

    if p_dteempmt between p_dtestr and p_dteend then
      v_stdate := p_dteempmt;
    elsif p_dteempmt < p_dtestr then
      v_stdate := p_dtestr;
    else
      v_stdate := null;
    end if;

    v_endate := p_dteend;
    if p_dteeffex is not null then
      if p_dteeffex between p_dtestr and p_dteend then
        v_endate := p_dteeffex - 1;
      elsif p_dteeffex < p_dtestr then
        v_endate := null;
      end if;
    end if;

    if v_stdate is not null and v_endate is not null and v_stdate <= v_endate then
      v_date := v_stdate;
      while v_date <= v_endate loop
        v_exist := false;
        for r_twkchhr in c_twkchhr loop
          v_exist := true;
          v_codempid := r_twkchhr.codempid;
          v_codcalen := r_twkchhr.codcalen;
          v_codshift := r_twkchhr.codshift;
          if v_codcalen is not null then
            std_al.gen_tattence(p_codempid,v_codcalen,v_date,p_coduser,'G',p_codcomp,p_typpayroll,p_flgatten,p_codempmt,v_recs);
          elsif v_codshift is not null then
            std_al.gen_tattence(p_codempid,p_codcalen,v_date,p_coduser,'G',p_codcomp,p_typpayroll,p_flgatten,p_codempmt,v_recs);
            for r_tattence in c_tattence loop
              if r_tattence.dtein is null and r_tattence.dteout is null then
								begin
					      	select timstrtw,timendw into v_timstrtw,v_timendw
					          from tshiftcd
					         where codshift = v_codshift;
					        v_dtestrtw := v_date;
					        if to_number(v_timstrtw) >= to_number(v_timendw) then
					          v_dteendw := v_date + 1;
					        else
					          v_dteendw := v_date;
					        end if;
				        exception when no_data_found then
				          v_timstrtw := null; v_timendw := null;
				          v_dtestrtw := null; v_dteendw := null;
				        end;
                update tattence set codshift = v_codshift,
                                    dtestrtw = v_dtestrtw,
                                    timstrtw = v_timstrtw,
                                    dteendw  = v_dteendw,
                                    timendw  = v_timendw,
                                    coduser  = p_coduser
                where rowid = r_tattence.rowid;
              end if;
            end loop; -- for r_tattence
          end if;
        end loop; -- for c_twkchhr
        if not v_exist then
          std_al.gen_tattence(p_codempid,p_codcalen,v_date,p_coduser,'G',p_codcomp,p_typpayroll,p_flgatten,p_codempmt,v_recs);
        end if;
        v_date := v_date + 1;
      end loop;
    end if; -- v_stdate,v_endate is not null
  end;
end;

/

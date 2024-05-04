--------------------------------------------------------
--  DDL for Package Body HRAL24B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL24B_BATCH" is
-- last update: 13/02/2021 16:00        --SWD-ST11-1701-AL-02-Rev4.0_04.doc
-- last update: 14/04/2024
	procedure start_process is
	 v_codcomp      temploy1.codcomp%type := '%';
   v_msgerror     varchar2(4000) := null;
	 v_status       varchar2(1) := 'C';
	 v_recemp       number;
	 v_rectrans     number;
	 v_recter       number;
	 v_recchng      number;
	 v_date		      date;
	 v_dteeffec     date := sysdate - 60;
	 v_dteeffec_en  date := sysdate ;

	cursor c1 is
	  select distinct codcomp
	    from ttpminf
     where dteeffec  between v_dteeffec and v_dteeffec_en
       and flgal     = 'N'
	order by codcomp;

	begin
		begin
	    insert into tautolog (codapp,dtecall,dteprost,dteproen,status,remark,coduser)
	                   values('HRAL24B',v_dteeffec,v_dteeffec,v_dteeffec_en,null,null,p_coduser);
		end;
		--
		for i in c1 loop
			begin
			  v_codcomp := i.codcomp;
			  cal_process (v_codcomp,p_coduser,v_dteeffec,v_dteeffec_en,v_recemp,v_rectrans,v_recter,v_recchng);
			exception when others then
			  rollback;
			  v_status   := 'E';
			  v_msgerror := v_msgerror||' codcomp = '||v_codcomp;
			end;
		end loop;
		--
	  if v_status = 'C' then
			v_msgerror := 'complete '||v_recemp||':'||v_rectrans||':'||v_recter||':'||v_recchng;             
	  else
	    v_msgerror := 'error '|| v_msgerror ;
	  end if;
		--
	  update tautolog
	     set status   = v_status,
	         dteproen = sysdate,
	         remark   = v_msgerror
	   where codapp   = 'HRAL24B'
	     and dtecall  = v_dteeffec;
	  commit;
	end;
	--
  procedure cal_process(p_codcomp   in varchar2, 
                        p_coduser   in varchar2, 
                        p_dteeffec  in date,
                        p_dteeffec_en  in date,
                        v_recemp    out number, 
                        v_rectrans  out number,
                        v_recter    out number, 
                        v_recchng   out number) is
	  v_zupdsal 	      varchar2(4);
	  v_flgsecu  		    boolean;
	  v_zminlvl  		    number;
	  v_zwrklvl  		    number;
	  v_codempid 		    temploy1.codempid%type;
	  v_codtrn   		    tcodmove.codcodec%type;
	  v_date     		    tattence.dtework%type;
	  v_codcalen 		    ttmovemt.codcalen%type;

    v_dteMin 		      date;
	  v_dteMax	 	    	date;
	  v_rec			      	number := 0;
	  v_chkexemp        varchar2(1);
	  b_index_recemp    number;
	  b_index_rectrans  number;
	  b_index_recter    number;
	  b_index_recchng   number;

	cursor c_newemp_rehire is
	  select codcodec,typmove
	    from tcodmove
	   where typmove in('1','2');

	cursor c_movemt is
    select codcodec,typmove
      from tcodmove
     where typmove = 'M';

	cursor c_exempt is
    select codcodec,typmove
      from tcodmove
     where typmove = '6';

	cursor c_ttpminf is
    select codempid,dteeffec,codtrn,codcomp,numlvl,codempmt,codcalen,typpayroll,flgatten,numseq,rowid
      from ttpminf
     where dteeffec between p_dteeffec and p_dteeffec_en 
       and codtrn   = v_codtrn
       and codcomp  like p_codcomp
       and flgal    = 'N'
  order by codempid,dteeffec,numseq;

	begin
	  b_index_recemp   := 0;
	  b_index_rectrans := 0;
	  b_index_recter   := 0;
	  b_index_recchng  := 0;
	  if p_coduser <> 'AUTO' then
	    begin
	     select get_numdec(numlvlst,p_coduser) numlvlst ,get_numdec(numlvlen,p_coduser) numlvlen
	       into v_zminlvl,v_zwrklvl
	       from tusrprof
	      where coduser = p_coduser;
	    exception when others then null;
	    end;
		end if;
delete ttemprpt where codapp = 'YYY'; commit; 
    -- new employee
	  for r_newemp in c_newemp_rehire loop
      v_codtrn := r_newemp.codcodec;
      for r_ttpminf in c_ttpminf loop
        if p_coduser <> 'AUTO' then
          v_flgsecu := secur_main.secur1(r_ttpminf.codcomp,r_ttpminf.numlvl,p_coduser,v_zminlvl,v_zwrklvl,v_zupdsal);
        end if;
        if v_flgsecu or p_coduser = 'AUTO' then
--<<user14 : 13/02/2021 14:30            
          << main_loop >> loop
            begin
              select 'Y' into v_chkexemp  
                from ttpminf
               where dteeffec = r_ttpminf.dteeffec 
                 and codempid = r_ttpminf.codempid
                 and codtrn   in (select codcodec 
                                    from tcodmove 
                                   where typmove = '6')
                 and rownum   = 1;
              exit main_loop;
            exception when no_data_found then null;
            end;
-->>user14 : 13/02/2021 14:30

            v_dteMin := null;
            v_dteMax := null;    
            begin
              select min(dtework),max(dtework) into v_dteMin,v_dteMax
                from tattence
               where codcomp like r_ttpminf.codcomp;
            end;
            if v_dteMin is null then
              begin
                select min(dtework),max(dtework) into v_dteMin,v_dteMax
                  from tgrpplan
                 where codcomp  = get_tgrpwork_codcomp(r_ttpminf.codcomp,r_ttpminf.codcalen)
                   and codcalen = r_ttpminf.codcalen;
              end;
            end if; 
            v_date := greatest(v_dteMin,r_ttpminf.dteeffec);

            <<gen_loop>>                                    
            while v_date <= v_dteMax loop
--<<user14 : 13/02/2021 14:30                           
              begin
                select codcalen into v_codcalen 
                  from twkchhr
                 where codempid = r_ttpminf.codempid
                   and v_date   between dtestrt and dteend
                   and codcalen is not null
                   and rownum   = 1;
              exception when no_data_found then v_codcalen := null;
              end;
              v_codcalen  :=  nvl(v_codcalen, r_ttpminf.codcalen); 
              std_al.gen_tattence(r_ttpminf.codempid,v_codcalen,v_date, p_coduser,'N',r_ttpminf.codcomp,r_ttpminf.typpayroll,r_ttpminf.flgatten,r_ttpminf.codempmt,v_rec);-- std_al.gen_tattence(r_ttpminf.codempid,r_ttpminf.codcalen,v_date, p_coduser,'N',r_ttpminf.codcomp,r_ttpminf.typpayroll,r_ttpminf.flgatten,r_ttpminf.codempmt,v_rec);
-->>user14 : 13/02/2021 14:30    
              --
              v_date := v_date + 1;
              if v_date > v_dteMax then                                                
                exit gen_loop;
              end if;
            end loop; -- gen_newemp loop
--<< user14 : 13/02/2021 14:30  
            exit main_loop;
          end loop; -- << main_loop >> 
-->> user14 : 13/02/2021 14:30  
          --
          b_index_recemp := b_index_recemp + 1;
          update ttpminf
             set flgal   = 'Y',
                 coduser = p_coduser
           where rowid   = r_ttpminf.rowid;
        end if;  -- if v_flgsecu or p_coduser= 'AUTO' then
      end loop; -- for r_ttpminf in c_ttpminf loop  
		end loop; -- c_newemp

    --------------------------------------------------------------------------------------------------------------------------------      
	  -- movement
	  for r_movemt in c_movemt loop
      v_codtrn := r_movemt.codcodec;
      for r_ttpminf in c_ttpminf loop
        if p_coduser <> 'AUTO' then
          v_flgsecu := secur_main.secur1(r_ttpminf.codcomp,r_ttpminf.numlvl,p_coduser,v_zminlvl,v_zwrklvl,v_zupdsal);
        end if;
        if v_flgsecu or p_coduser = 'AUTO' then
          v_dteMin := null;
          v_dteMax := null;    
          begin
            select min(dtework),max(dtework) into v_dteMin,v_dteMax
              from tattence
             where codcomp like r_ttpminf.codcomp;
          end;
          if v_dteMin is null then
            begin
              select min(dtework),max(dtework) into v_dteMin,v_dteMax
                from tgrpplan
               where codcomp  = get_tgrpwork_codcomp(r_ttpminf.codcomp,r_ttpminf.codcalen)
                 and codcalen = r_ttpminf.codcalen;
            end;
          end if;
          v_date := greatest(v_dteMin,r_ttpminf.dteeffec);
          <<gen_loop>>                                    
          while v_date <= v_dteMax loop
--<<user14 : 13/02/2021 14:30                           
            begin
              select codcalen into v_codcalen 
                from twkchhr
               where codempid = r_ttpminf.codempid
                 and v_date   between dtestrt and dteend
                 and codcalen is not null
                 and rownum   = 1;
            exception when no_data_found then v_codcalen := null;
            end;
            v_codcalen  :=  nvl(v_codcalen, r_ttpminf.codcalen); 
            std_al.gen_tattence(r_ttpminf.codempid,v_codcalen,v_date, p_coduser,'M',r_ttpminf.codcomp,r_ttpminf.typpayroll,r_ttpminf.flgatten,r_ttpminf.codempmt,v_rec);-- std_al.gen_tattence(r_ttpminf.codempid,r_ttpminf.codcalen,v_date, p_coduser,'M',r_ttpminf.codcomp,r_ttpminf.typpayroll,r_ttpminf.flgatten,r_ttpminf.codempmt,v_rec);
-->>user14 : 13/02/2021 14:30    
            --
            v_date := v_date + 1;
            if v_date > v_dteMax then                                                
              exit gen_loop;
            end if;
          end loop; -- gen_newemp loop
          --
          b_index_rectrans := b_index_rectrans + 1;
          update ttpminf
             set flgal   = 'Y',
                 coduser = p_coduser
           where rowid   = r_ttpminf.rowid;
        end if;  -- if v_flgsecu or p_coduser= 'AUTO' then
      end loop; -- for r_ttpminf in c_ttpminf loop  
		end loop; -- r_movemt

    --------------------------------------------------------------------------------------------------------------------------------  
	  -- exemption
	  for r_exempt in c_movemt loop
      v_codtrn := r_exempt.codcodec;
      for r_ttpminf in c_ttpminf loop
        if p_coduser <> 'AUTO' then
          v_flgsecu := secur_main.secur1(r_ttpminf.codcomp,r_ttpminf.numlvl,p_coduser,v_zminlvl,v_zwrklvl,v_zupdsal);
        end if;
        if v_flgsecu or p_coduser = 'AUTO' then
          begin
              select min(dteeffec) into v_dteMin
                from ttpminf
               where codempid   = r_ttpminf.codempid
                 and dteeffec  >= r_ttpminf.dteeffec
                 and codtrn     in (select codcodec 
                                      from tcodmove 
                                     where typmove = '2');
              v_dteMin := v_dteMin - 1;
            exception when no_data_found then v_dteMin := null;
          end;          
          delete tattence
           where codempid  = r_ttpminf.codempid
             and dtework  between r_ttpminf.dteeffec and nvl(v_dteMin,dtework);

          delete tlateabs
           where codempid  = r_ttpminf.codempid
             and dtework  between r_ttpminf.dteeffec and nvl(v_dteMin,dtework);

          delete tleavetr
           where codempid  = r_ttpminf.codempid
             and dtework  between r_ttpminf.dteeffec and nvl(v_dteMin,dtework);

          delete tovrtime
           where codempid  = r_ttpminf.codempid
             and dtework  between r_ttpminf.dteeffec and nvl(v_dteMin,dtework);

          delete totpaydt
           where codempid  = r_ttpminf.codempid
             and dtework  between r_ttpminf.dteeffec and nvl(v_dteMin,dtework);
          --
          b_Index_recter := b_Index_recter + 1;
          update ttpminf
             set flgal   = 'Y',
                 coduser = p_coduser
           where rowid   = r_ttpminf.rowid;
        end if;  -- if v_flgsecu or p_coduser= 'AUTO' then
      end loop; -- for r_ttpminf in c_ttpminf loop  
		end loop; -- c_exempt    
		--
	  commit;
	  v_recemp   := b_index_recemp;
	  v_rectrans := b_index_rectrans;
	  v_recter   := b_index_recter;
	  v_recchng  := b_index_recchng;
	end;
end;

/

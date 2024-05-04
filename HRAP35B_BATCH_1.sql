--------------------------------------------------------
--  DDL for Package Body HRAP35B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP35B_BATCH" as

  procedure  start_process (p_dteyreap   number,
                          p_numtime    number,
                          p_codcomp    varchar2,
                          p_codempid   varchar2,
                          p_codreq     varchar2,
                          p_flgcal     varchar2,
                          p_coduser    in varchar2,
                          p_lang       in varchar2) is

    v_pctbeh            number;
    v_pctcmp            number;
    v_pctkpicp          number;
    v_pctkpiem          number;
    v_pctkpirt          number;
    v_pctta             number;
    v_pctpunsh          number;
    v_codcompy          varchar2(40 char);
    v_numappl           varchar2(40 char);

    v_qtybeh            number;
    v_qtycmp    	    number;
    v_qtykpie    	    number;
    v_qtykpid           number;
    v_qtykpic           number;
    v_qtyta             number;
    v_qtypuns           number;
    v_qtytot    	    number;

    v_qtyscor           number;
    v_qtyscort          number;
    v_qtyscorn          number;
    v_qtyscornn         number;

    v_flggrade          varchar2(1 char);
    v_codcomlvl         varchar2(40 char) := '@#';
    v_grdap             varchar2(40 char) := '@#';
    v_numempap          number := 0;
    v_numsyn            number := 0;
    v_empgrd            number := 0;
    v_countqty          number := 0;
    v_qtymaxsc          number := 0;
    v_qtyfullscc        number := 0;
    v_qtyfullscp        number := 0;
    v_codcomp           temploy1.codcomp%type;
    v_scorfta           tattpreh.scorfta%type;
    v_scorfpunsh        tattpreh.scorfpunsh%type;
    v_remarkcal         tappemp.remarkcal%type;
    
    v_stmt              clob;
    v_syncond           tnineboxap.syncond%type;
    v_flgfound          number := 0;
	type char2 is table of varchar2(4 char) index by binary_integer;
        v_arrgrdap	char2;

	type numemp is table of number index by binary_integer;
		v_arrnumemp	numemp;


    cursor c_tappemp is
        select a.codempid,dteyreap,numtime,a.codaplvl,b.staemp,a.codcomp,
               qtybeh3,qtycmp3,qtykpie3,qtykpid,qtykpic,qtytot3,qtyta,qtypuns,flgappr
          from tappemp a,temploy1 b
         where dteyreap   = p_dteyreap
           and numtime    = p_numtime
           and a.codcomp  like p_codcomp||'%'
           and a.codempid = nvl(p_codempid,a.codempid)
           and a.codempid = b.codempid
        order by a.codempid;
        
    cursor c_tapbudgt is
        select codcomp,flggrade 
          from tapbudgt
         where dteyreap   = p_dteyreap
           and codcomp    like p_codcomp||'%'
        order by codcomp desc;

    cursor c_tappemp_grade is
        select codempid,dteyreap,numtime,codaplvl,codcomp,qtytotnet,
               qtybeh3, qtycmp3, qtykpie3
          from tappemp
         where dteyreap   = p_dteyreap
           and numtime    = p_numtime
           and codcomp    like v_codcomp||'%'
           and codempid   = nvl(p_codempid,codempid)
           and grdadj     is null
        order by qtytotnet desc,codcomp,codempid;

	cursor c_tstdis is
	  select grade,pctwkstr,pctwkend,pctemp
	    from tstdis
	   where v_codcomlvl like codcomp||'%'
	     and dteyreap = (select max(dteyreap)
	                       from tstdis
	                      where v_codcomlvl like codcomp||'%'
	                        and dteyreap <= p_dteyreap)
	   order by grade;

	cursor c_tstdis_9box is
	  select grade,pctwkstr,pctwkend,pctemp
	    from tstdis
	   where v_codcomlvl like codcomp||'%'
	     and dteyreap = (select max(dteyreap)
	                       from tstdis
	                      where v_codcomlvl like codcomp||'%'
	                        and dteyreap <= p_dteyreap)
	   order by grade desc;

begin

    for r_tappemp in c_tappemp loop

        begin
            select pctbeh,pctcmp,pctkpicp,pctkpiem,pctkpirt,pctta,pctpunsh
              into v_pctbeh,v_pctcmp,v_pctkpicp,v_pctkpiem,v_pctkpirt,v_pctta,v_pctpunsh
              from taplvl
             where r_tappemp.codcomp like codcomp||'%'
               and codaplvl = r_tappemp.codaplvl
               and dteeffec = (select max(dteeffec)
                                 from taplvl
                                where r_tappemp.codcomp like codcomp||'%'
                                  and codaplvl = r_tappemp.codaplvl
                                  and dteeffec <= trunc(sysdate))
            order by codcomp desc;
        exception when no_data_found then
            null;
        end;

        v_codcompy  := hcm_util.get_codcomp_level(r_tappemp.codcomp,1);

        v_qtybeh    := round(((nvl(r_tappemp.qtybeh3,0)  * v_pctbeh) / 100),2 );
        v_qtycmp    := round(((nvl(r_tappemp.qtycmp3,0)  * v_pctcmp) / 100),2 );
        v_qtykpie   := round(((nvl(r_tappemp.qtykpie3,0) * v_pctkpiem) / 100),2 );
        
        v_remarkcal := null;
        if r_tappemp.flgappr = 'P' then
            v_remarkcal := get_tlistval_name('FLGAPPRP','I','102') ;
        elsif nvl(v_qtybeh,0) = 0 and nvl(v_qtycmp,0) = 0 and nvl(v_qtykpie,0) = 0 then
            v_remarkcal := get_error_msg_php('HR1620','102');
        end if;
        
        v_qtymaxsc := 0;
        begin
            select max(score) into v_qtymaxsc
              from tgradekpi
             where dteyreap = r_tappemp.dteyreap
               and codcompy = v_codcompy;
        exception when no_data_found then
           v_qtymaxsc := 1;
        end;        
        --KPI องค์กร
        v_qtyscor := 0;
        begin
            select sum(qtyscor),count(*) * v_qtymaxsc  into v_qtyscor,v_qtyfullscc
              from tkpicmph
             where dteyreap = r_tappemp.dteyreap
               and codcompy = v_codcompy;
        exception when no_data_found then
           v_qtyscor := 0;
        end;
        if v_qtyscor <> 0 then
            v_qtyscort  := round((v_qtyscor/v_qtyfullscc) * 100,2);
            v_qtykpic   := round(((nvl(v_qtyscort,0)  * v_pctkpirt) / 100),2 );
        end if;
        -- KPI หน่วยงาน
        v_qtyscor := 0;
        begin
            select sum(qtyscorn),sum(wgt) * v_qtymaxsc  into v_qtyscorn,v_qtyfullscp
              from tkpidph
             where dteyreap = r_tappemp.dteyreap
               and numtime  = r_tappemp.numtime
               and codcomp  = r_tappemp.codcomp;
        exception when no_data_found then
           v_qtyscorn := 0;
        end;
        if v_qtyscorn <> 0 then
            v_qtyscornn  := round((v_qtyscorn/v_qtyfullscp) * 100,0) ;
            v_qtykpid    := round(((nvl(v_qtyscornn,0)  * v_pctkpicp) / 100),2 );
        end if;

        begin
            select scorfta,scorfpunsh  into v_scorfta,v_scorfpunsh
              from tattpreh
             where codcompy  = v_codcompy
               and codaplvl  = r_tappemp.codaplvl
               and dteeffec  = (select max(dteeffec)
                                  from tattpreh
                                 where codcompy  = v_codcompy
                                   and codaplvl  = r_tappemp.codaplvl
                                   and dteeffec  <= trunc(sysdate));
        exception when no_data_found then
           v_scorfta    := 0;
           v_scorfpunsh := 0;
        end;
        v_qtyta   := 0;
        v_qtypuns := 0;
        if nvl(v_scorfta,0) <> 0 then
            v_qtyta     := round((((nvl(r_tappemp.qtyta,0)/v_scorfta)*100  * v_pctta) / 100),2 );
        end if;
        if nvl(v_scorfpunsh,0) <> 0 then
            v_qtypuns   := round((((nvl(r_tappemp.qtypuns,0)/v_scorfpunsh)*100  * v_pctpunsh) / 100),2 );
        end if;

        v_qtytot    := nvl(v_qtybeh,0) +  nvl(v_qtycmp,0) + nvl(v_qtykpie,0) +
                       nvl(v_qtykpic,0) + nvl(v_qtykpid,0) + nvl(v_qtyta,0) + nvl(v_qtypuns,0);

        update tappemp set qtytotnet = v_qtytot ,
                           qtykpic   = v_qtyscort ,
                           qtykpid   = v_qtyscornn ,
                           grdadj    = null,
                           grdappr   = null,
                           grdap     = null,
                           remarkcal = v_remarkcal
         where codempid = r_tappemp.codempid
           and dteyreap = r_tappemp.dteyreap
           and numtime  = r_tappemp.numtime;

    end loop;

    for r_tapbudgt in c_tapbudgt loop
        v_codcomp := r_tapbudgt.codcomp;
        v_codcomlvl := r_tapbudgt.codcomp;
        --cal grade 1-กำหนดคะแนน
        if r_tapbudgt.flggrade = '1' then
            for i in c_tappemp_grade loop
                begin
                    select numappl into v_numappl
                      from temploy1
                     where codempid = i.codempid;
                exception when no_data_found then
                   v_numappl := null;
                end;

                for r_tstdis in c_tstdis loop
                    if i.qtytotnet between r_tstdis.pctwkstr and r_tstdis.pctwkend then
                        v_grdap := r_tstdis.grade;
                        exit;
                    end if;
                end loop; 

                update tappemp set grdappr  = v_grdap,
                                   grdap    = v_grdap,
                                   grdadj   = 'Y'
                 where codempid = i.codempid
                   and dteyreap = i.dteyreap
                   and numtime  = i.numtime;
        
                update_tcmptncy(i.dteyreap,i.numtime,i.codempid,v_numappl,p_codreq);

            end loop;
        elsif r_tapbudgt.flggrade = '2' then --2-กำหนดคะแนนและ %พนักงาน  

            for i in 1..20 loop
                v_arrgrdap(i)  := null;
                v_arrnumemp(i) := null;
            end loop;
            v_numempap := 0;
            begin
                select count(codempid) into v_numempap
                  from tappemp
                 where dteyreap   = p_dteyreap
                   and numtime    = p_numtime
                   and codcomp    like v_codcomp||'%'
                   and flgappr    = 'C';
            exception when no_data_found then
                v_numempap := 0;
            end;
            
            for r_tstdis in c_tstdis loop
                v_numsyn := v_numsyn + 1; -- ลำดับที่ array
                v_arrgrdap(v_numsyn)  := r_tstdis.grade; -- เกรด
                v_arrnumemp(v_numsyn) := trunc((v_numempap * r_tstdis.pctemp)/100); -- จำนวนพนักงานที่จะได้ในแต่ละเกรด
            end loop;

            for i in c_tappemp_grade loop
            --cal grade
                if v_numsyn <> 0 then
                    for r_tstdis in c_tstdis loop
                        if i.qtytotnet between r_tstdis.pctwkstr and r_tstdis.pctwkend then
                            v_empgrd := 0;
                            begin
                                select count(codempid) into v_empgrd--จำนวนพนักงานทั้งหมดที่ได้เกรดนี้ไปแล้ว
                                  from tappemp
                                 where dteyreap = p_dteyreap
                                   and numtime  = p_numtime
                                   and codcomp  like v_codcomp||'%'
                                   and grdappr  = r_tstdis.grade;
                            exception when no_data_found then
                                v_empgrd := 0;
                            end;
    
                            for j in 1..v_numsyn loop
                                if v_arrgrdap(j) = r_tstdis.grade and v_empgrd < v_arrnumemp(j) then
                                    v_grdap := r_tstdis.grade;
                                    exit;
                                elsif v_arrgrdap(j) = r_tstdis.grade and v_empgrd >= v_arrnumemp(j) then
                                    v_countqty := 0;
                                    begin
                                        select count(codempid) into v_countqty
                                          from tappemp
                                         where dteyreap  = p_dteyreap
                                           and numtime   = p_numtime
                                           and codempid  <> i.codempid
                                           and grdappr   = r_tstdis.grade
                                           and qtytotnet = i.qtytotnet;
                                    exception when no_data_found then
                                        v_countqty := 0;
                                    end;
    
                                    if v_countqty = 0 then
                                        v_grdap := v_arrgrdap(j+1);
                                        exit;
                                    else
                                        v_grdap := r_tstdis.grade;
                                        exit;
                                    end if;
    
                                end if;
                            end loop;
    
                            exit;
                        end if;
                    end loop;
                end if; ---if v_numsyn <> 0 then  
            
                update tappemp set grdappr  = v_grdap,
                                   grdap    = v_grdap,
                                   grdadj   = 'Y'
                 where codempid = i.codempid
                   and dteyreap = i.dteyreap
                   and numtime  = i.numtime;
        
                update_tcmptncy(i.dteyreap,i.numtime,i.codempid,v_numappl,p_codreq);
            end loop ;  
        elsif r_tapbudgt.flggrade = '3' then --3- โดยการคิดคะแนนตามกลุ่ม 9 box   
            for i in c_tappemp_grade loop
                for r_tstdis in c_tstdis_9box loop
                    begin
                        select syncond
                          into v_syncond
                          from tnineboxap
                         where codcompy = hcm_util.get_codcomp_level(i.codcomp,1)
                           and codgroup = r_tstdis.grade
                           and dteeffec = (select max(dteeffec)
                                             from tnineboxap
                                            where codcompy = hcm_util.get_codcomp_level(i.codcomp,1)
                                              and dteeffec <= trunc(sysdate));
                    exception when others then
                        v_syncond := null;
                    end;
                    if v_syncond is not null then
                        v_stmt := v_syncond ;
                        v_stmt := replace(v_stmt,'TAPPEMP.CODCOMP',''''||i.codcomp||'''') ;
                        v_stmt := replace(v_stmt,'TAPPEMP.CODAPLVL',''''||i.codaplvl||'''') ;
                        v_stmt := replace(v_stmt,'TAPPEMP.QTYKPI',''||i.qtykpie3||'') ;
                        v_stmt := replace(v_stmt,'TAPPEMP.QTYCMP',''||i.qtycmp3||'') ;
                        v_stmt := replace(v_stmt,'TAPPEMP.QTYBEH',''||i.qtybeh3||'') ;
                        v_stmt := 'select count(*) from TAPPEMP where '||v_stmt||' and codempid ='''||i.codempid||'''' ;
                        v_flgfound  := execute_qty(v_stmt) ;
                    end if;
                    if v_flgfound <> 0 then
                        v_grdap := r_tstdis.grade;
                        exit;
                    end if;
                end loop; 

                update tappemp set grdappr  = v_grdap,
                                   grdap    = v_grdap,
                                   grdadj   = 'Y'
                 where codempid = i.codempid
                   and dteyreap = i.dteyreap
                   and numtime  = i.numtime;
                   
                update_tcmptncy(i.dteyreap,i.numtime,i.codempid,v_numappl,p_codreq);
            end loop;
        end if;
    end loop;
    for r_tappemp in c_tappemp loop
        update tappemp set grdadj    = null
         where codempid = r_tappemp.codempid
           and dteyreap = r_tappemp.dteyreap
           and numtime  = r_tappemp.numtime;
    end loop;
end;
  
  procedure start_process_9box (p_dteyreap   number,
                                p_numtime    number,
                                p_codcomp    varchar2,
                                p_codempid   varchar2,
                                p_codreq     varchar2,
                                p_flgcal     varchar2,
                                p_coduser    in varchar2,
                                p_lang       in varchar2) is
  
      v_pctbeh            number;
      v_pctcmp            number;
      v_pctkpicp          number;
      v_pctkpiem          number;
      v_pctkpirt          number;
      v_pctta             number;
      v_pctpunsh          number;
      v_numappl           varchar2(40 char);
  
      v_qtybeh            number;
      v_qtycmp    	    number;
      v_qtykpie    	    number;
      v_qtykpid           number;
      v_qtykpic           number;
      v_qtyta             number;
      v_qtypuns           number;
      v_qtytot    	    number;
  
      v_qtyscor           number;
      v_qtyscort          number;
      v_qtyscorn          number;
      v_qtyscornn         number;
  
      v_flggrade          varchar2(1 char);
      v_codcomlvl         varchar2(40 char) := '@#';
      v_grdap             varchar2(40 char) := '@#';
      v_numempap          number := 0;
      v_numsyn            number := 0;
      v_empgrd            number := 0;
      v_countqty          number := 0;
      v_qtymaxsc          number := 0;
      v_qtyfullscc        number := 0;
      v_qtyfullscp        number := 0;
      v_codcomp           temploy1.codcomp%type;
      v_scorfta           tattpreh.scorfta%type;
      v_scorfpunsh        tattpreh.scorfpunsh%type;
      v_remarkcal         tappemp.remarkcal%type;
      
      v_stmt              clob;
      v_syncond           tnineboxap.syncond%type;
      v_flgfound          number := 0;
      
      cursor c_9box is
        select syncond,codgroup
          from tnineboxap
         where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
           and dteeffec = (select max(dteeffec)
                             from tnineboxap
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
                              and dteeffec <= trunc(sysdate));
      
      cursor c_tappemp_grade is
        select *
          from tappemp
         where dteyreap   = p_dteyreap
           and numtime    = p_numtime
           and codcomp    like v_codcomp||'%'
           and codempid   = nvl(p_codempid,codempid)
           and grdap      is null
        order by codempid;
  
  begin
    --tar
    if p_codcomp is not null then
      v_codcomp := p_codcomp;
    else
      begin
        select codcomp into v_codcomp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        null;
      end;
    end if;
    
    begin
       update tappemp 
          set grdappr    = null,
              grdap      = null
         where codempid = nvl(p_codempid, codempid)
           and dteyreap = p_dteyreap
           and numtime  = p_numtime
           and exists (select codcomp 
                         from tusrcom x
                        where x.coduser = p_coduser
                          and tappemp.codcomp like x.codcomp||'%');
    end;
    hcm_secur.get_global_secur(p_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
    
    for r_tappemp in c_tappemp_grade loop
      if secur_main.secur2(r_tappemp.codempid,p_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal) then
        for r_9box in c_9box loop
          v_syncond := r_9box.syncond;
          if v_syncond is not null then
            v_stmt := v_syncond ;
            v_stmt := replace(v_stmt,'TAPPEMP.CODCOMP',''''||r_tappemp.codcomp||'''') ;
            v_stmt := replace(v_stmt,'TAPPEMP.CODAPLVL',''''||r_tappemp.codaplvl||'''') ;
            v_stmt := replace(v_stmt,'TAPPEMP.QTYKPI',''||r_tappemp.qtykpie3||'') ;
            v_stmt := replace(v_stmt,'TAPPEMP.QTYCMP',''||r_tappemp.qtycmp3||'') ;
            v_stmt := replace(v_stmt,'TAPPEMP.QTYBEH',''||r_tappemp.qtybeh3||'') ;
            v_stmt := 'select count(*) from TAPPEMP where '||v_stmt||' and codempid ='''||r_tappemp.codempid||'''' ;

            v_flgfound  := execute_qty(v_stmt) ;
          end if;
          if v_flgfound <> 0 then
            begin
              update tappemp 
                 set grdappr  = r_9box.codgroup,
                     grdap    = r_9box.codgroup
               where codempid = r_tappemp.codempid
                 and dteyreap = r_tappemp.dteyreap
                 and numtime  = r_tappemp.numtime;
            end;
            exit;
          end if;
        end loop;  
      end if;
    end loop;
  end;

  procedure  update_tcmptncy (p_dteyreap   number,
                              p_numtime    number,
                              p_codempid   varchar2,
                              p_numappl    varchar2,
                              p_codreq     varchar2) is
  
      v_codskill      varchar2(4 char);
      v_count         number := 0;
      v_codeval       varchar2(40 char);
      v_dteapman      date;
  
  
      cursor c_tappcmps is
          select codtency,codskill,gradexpct,grade,qtyscor,remark
            from  tappcmps
           where  codempid = p_codempid
             and  dteyreap = p_dteyreap
             and  numtime  = p_numtime
             and  numseq   = (select max(numseq)
                                from tappcmps
                               where codempid = p_codempid
                                 and dteyreap = p_dteyreap
                                 and numtime  = p_numtime
                          )
          order by codskill;
  
      cursor c_tcmptncy is
          select grade
            from tcmptncy
           where codempid = p_codempid
             and codtency = v_codskill ;
  
      /*cursor c_thcmptcy is
          select codempid
            from thcmptcy
           where codempid = p_codempid
             and dteeval  = trunc(sysdate)
             and codtency = v_codskill ;*/
  
  begin
      for i in c_tappcmps loop
          v_codskill  := i.codskill;
          v_count     := 0;
          for j in c_tcmptncy loop
              v_count := 1;
              update tcmptncy set grade = i.grade
               where codempid = p_codempid
                 and codtency = i.codskill;
          end loop;
  
          if v_count = 0  then
              insert into tcmptncy(numappl,codtency,grade,codempid,codcreate,coduser)
                     values		(p_numappl,i.codskill,i.grade,p_codempid,p_codreq,p_codreq);
          end if;
  
          begin
              select codapman,dteapman into v_codeval,v_dteapman
                from tappfm
               where codempid = p_codempid
                 and dteyreap = p_dteyreap
                 and numtime  = p_numtime
                 and flgappr  = 'C'
                 and numseq   = (select max(numseq) from tappfm
                                  where codempid = p_codempid
                                    and dteyreap = p_dteyreap
                                    and numtime  = p_numtime
                                    and flgappr  = 'C');
          exception when no_data_found then
              v_codeval := null;
          end;
  
          /*v_count    := 0 ;
          for k in c_thcmptcy  loop
              v_count    := 1 ;
              update thcmptcy set scorenew = i.qtyscor,
                                  grade    = i.grade,
                                  codeval  = v_codeval,
                                  dteeval  = v_dteapman,
                                  coduser  = p_codreq
              where codempid = p_codempid
                and dteeval  = v_dteapman
                and codtency = i.codskill;
          end loop;
  
          if v_count = 0 then
              insert into thcmptcy(codempid,codtency,codeval,
                                   dteeval,scorenew,coduser,
                                   codcreate,grade )
                    values        (p_codempid,i.codskill,v_codeval,
                                   v_dteapman,i.qtyscor,p_codreq,
                                   p_codreq,i.grade) ;
          end if;*/
  
      end loop;
  end;

end HRAP35B_BATCH;

/

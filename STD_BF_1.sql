--------------------------------------------------------
--  DDL for Package Body STD_BF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_BF" is
--Error ST11/STT-SS-2201/redmine9079 06/02/2023 17:18
  procedure get_medlimit (p_codempid   varchar2,
                         p_dtereq     date,
                         p_dtestart   date,
                         p_numvcher   varchar2,
                         p_typamt     varchar2,
                         p_typrel     varchar2,
                         p_amtwidrwy  out number,
                         p_qtywidrwy  out number,
                         p_amtwidrwt  out number,
                         p_amtacc     out number,
                         p_amtacc_typ out number,
                         p_qtyacc     out number,
                         p_qtyacc_typ out number,
                         p_amtbal        out number
                         ) is

    v_codpos      temploy1.codpos%type;
    v_jobgrade    temploy1.jobgrade%type;
    v_codcomp     temploy1.codcomp%type;
    v_typemp      temploy1.typemp%type;
    v_numlvl      temploy1.numlvl%type;
    v_staemp      temploy1.staemp%type;
    v_codempmt    temploy1.codempmt%type;
    v_dteempmt    temploy1.dteempmt%type;
    v_daybfst     tcontrbf.daybfst%type;
    v_mthbfst     tcontrbf.mthbfst%type;
    v_daybfen     tcontrbf.daybfen%type;
    v_mthbfen     tcontrbf.mthbfen%type;
    v_year        number;
    v_dtestr      date;
    v_dteend      date;
    v_flgfound    boolean := false;
    v_flgfound2   boolean := false;
    v_desc        tisrpinf.condisrp%type;
    v_stmt        varchar2(4000);
    v_numseq      tlmedexh.numseq%type;
    v_typamt      tlmedexp.typamt%type;
    v_cnt1        number := 0;
    v_cnt2        number := 0;
    v_cnt3        number := 0;
    v_amtwidrwy1  number;
    v_amtwidrwy2  number;
    v_amtwidrwy3  number;
    v_amtwidrwt1  number;
    v_amtwidrwt2  number;
    v_amtwidrwt3  number;
    v_qtywidrwy1  number;
    v_qtywidrwy2  number;
    v_qtywidrwy3  number;

    v_amtbal      number;
    v_typrel      tlmedexp.typrel%type;

    cursor c_tlmedexh is
      select codcompy,numseq,syncond,flgprorate
        from tlmedexh
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
    order by numseq;

  begin
    p_amtwidrwy  := 0;
    p_qtywidrwy  := 0;
    p_amtwidrwt  := 0;
    p_amtacc     := 0;
    p_amtacc_typ := 0;
    p_qtyacc     := 0;
    p_qtyacc_typ := 0;
    p_amtbal     := 0;

    begin
      select codpos,jobgrade,codcomp,typemp,numlvl,staemp,codempmt,dteempmt
        into v_codpos,v_jobgrade,v_codcomp,v_typemp,v_numlvl,v_staemp,v_codempmt,v_dteempmt
        from temploy1
       where codempid  = p_codempid;
    exception when no_data_found then return;
    end;

    begin
      select daybfst, mthbfst, daybfen, mthbfen
        into v_daybfst, v_mthbfst, v_daybfen, v_mthbfen
        from tcontrbf
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontrbf
                          where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                            and dteeffec <= sysdate);
    exception when no_data_found then return;
    end;

    if v_daybfst is null or v_mthbfst is null or v_daybfen is null or v_mthbfen is null then
      return;
    end if;

    if v_mthbfst >  v_mthbfen  then
      v_year := to_char(p_dtestart,'yyyy')-1;
      v_dtestr := to_date(v_daybfst||'/'||v_mthbfst||'/'||v_year,'dd/mm/yyyy');
      v_dteend := to_date(v_daybfen||'/'||v_mthbfen||'/'||to_char(p_dtestart,'yyyy'),'dd/mm/yyyy');
    else
      v_year := to_char(p_dtestart,'yyyy');
      v_dtestr := to_date(v_daybfst||'/'||v_mthbfst||'/'||v_year,'dd/mm/yyyy');
      v_dteend := to_date(v_daybfen||'/'||v_mthbfen||'/'||to_char(p_dtestart,'yyyy'),'dd/mm/yyyy');
    end if;



    for r1 in c_tlmedexh loop
      v_flgfound := true;
      if r1.syncond is not null then
        v_desc := r1.syncond;
        v_desc := replace(v_desc,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
        v_desc := replace(v_desc,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
        v_desc := replace(v_desc,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
        v_desc := replace(v_desc,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
        v_desc := replace(v_desc,'TEMPLOY1.NUMLVL',v_numlvl);
        v_desc := replace(v_desc,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
        v_desc := replace(v_desc,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
        v_desc := replace(v_desc,'TEMPLOY1.CODREL',''''||p_typrel||'''');

--p_typrel = E-Employee	, S-Spouse	 ,C-Children ,F-Father - Mother ,9-Family ,A-All
        v_stmt := 'select count(*) from dual where '||v_desc;
        v_flgfound := execute_stmt(v_stmt);
      end if;


--insert_ttemprpt('BF','BF',' r1.numseq='|| r1.numseq,p_typamt,p_typrel,null,'p_codempid='||p_codempid);

      if v_flgfound then
        begin
          select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
            into v_cnt1,v_amtwidrwy1,v_amtwidrwt1,v_qtywidrwy1
            from tlmedexp
           where codcompy = r1.codcompy
             and numseq   = r1.numseq
             and typamt   = p_typamt
             and typrel     = p_typrel;
        end;

        if v_cnt1 > 0 then
          p_amtwidrwy  := v_amtwidrwy1;
          p_amtwidrwt  := v_amtwidrwt1;
          p_qtywidrwy  := v_qtywidrwy1;

          v_typamt     := p_typamt;
          v_typrel       := p_typrel;
        else
          begin
            select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
              into v_cnt2,v_amtwidrwy2,v_amtwidrwt2,v_qtywidrwy2
              from tlmedexp
             where codcompy = r1.codcompy
               and numseq   = r1.numseq
               and typamt   = 'A'
               and typrel     = 'A';  
          end;

          if v_cnt2 > 0 then
                p_amtwidrwy  := v_amtwidrwy2;
                p_amtwidrwt  := v_amtwidrwt2;
                p_qtywidrwy  := v_qtywidrwy2;

                v_typamt     := 'A';
                v_typrel        := 'A';  
          else
             begin
                select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
                  into v_cnt2,v_amtwidrwy2,v_amtwidrwt2,v_qtywidrwy2
                  from tlmedexp
                 where codcompy = r1.codcompy
                   and numseq   = r1.numseq
                   and typamt   = p_typamt
                   and typrel   = 'A'; --p_typrel;
              end;

              if v_cnt2 > 0 then
                    p_amtwidrwy  := v_amtwidrwy2;
                    p_amtwidrwt  := v_amtwidrwt2;
                    p_qtywidrwy  := v_qtywidrwy2;

                    v_typamt      :=p_typamt;
                    v_typrel        := 'A'; --p_typrel;              
             else                
                     begin
                            select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
                              into v_cnt2,v_amtwidrwy2,v_amtwidrwt2,v_qtywidrwy2
                              from tlmedexp
                             where codcompy = r1.codcompy
                               and numseq   = r1.numseq
                               and typamt   = 'A'--p_typamt
                               and typrel   = p_typrel;
                          end;

                          if v_cnt2 > 0 then
                                p_amtwidrwy  := v_amtwidrwy2;
                                p_amtwidrwt  := v_amtwidrwt2;
                                p_qtywidrwy  := v_qtywidrwy2;

                                v_typamt      :='A';  --p_typamt;
                                v_typrel        :=  p_typrel;              
                         else                
                                    if p_typrel in ('M','F','C','S') then
--<<Error ST11/STT-SS-2201/redmine9079
                                               begin
                                                      select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
                                                        into v_cnt3,v_amtwidrwy3,v_amtwidrwt3,v_qtywidrwy3
                                                        from tlmedexp
                                                       where codcompy = r1.codcompy
                                                         and numseq   = r1.numseq
                                                         and typamt   =p_typamt
                                                         and typrel   = '9'; -- 9-Family
                                                end;
                                                if v_cnt3 > 0 then
                                                  p_amtwidrwy  := v_amtwidrwy3;
                                                  p_amtwidrwt  := v_amtwidrwt3;
                                                  p_qtywidrwy  := v_qtywidrwy3;

                                                  v_typamt     :=p_typamt;
                                                  v_typrel     := '9'; -- 9-Family
                                                else  --v_cnt3 = 0
                                                   begin
                                                      select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
                                                        into v_cnt3,v_amtwidrwy3,v_amtwidrwt3,v_qtywidrwy3
                                                        from tlmedexp
                                                       where codcompy = r1.codcompy
                                                         and numseq   = r1.numseq
                                                         and typamt   ='A'
                                                         and typrel   = '9'; -- 9-Family
                                                    end;
                                                    if v_cnt3 > 0 then
                                                          p_amtwidrwy  := v_amtwidrwy3;
                                                          p_amtwidrwt  := v_amtwidrwt3;
                                                          p_qtywidrwy  := v_qtywidrwy3;

                                                          v_typamt     :='A';
                                                          v_typrel        := '9'; -- 9-Family
                                                    end if;
                                                end if;   --if v_cnt3 > 0 then
-->>Error ST11/STT-SS-2201/redmine9079                           
                             end if; -- if p_typrel in ('M','F','C','S') then
                           end if;  -- if v_cnt2 > 0 then
                        end if;  -- if v_cnt2 > 0 then
                end if;  -- if v_cnt2 > 0 then
        end if; -- if v_cnt1 > 0 then

--insert_ttemprpt('BF','BF',1,p_amtwidrwy,r1.flgprorate,null,'v_typrel='||v_typrel);

        if p_amtwidrwy > 0 and r1.flgprorate = 'Y' and v_dteempmt between v_dtestr and v_dteend then
          --p_amtwidrwy := round(p_amtwidrwy * (((v_dteempmt - v_dtestr) + 1) / ((v_dteend - v_dtestr) + 1)) ,2);
          p_amtwidrwy := round(p_amtwidrwy * (((v_dteend - v_dteempmt) + 1) / ((v_dteend - v_dtestr) + 1)) ,2);
        end if; -- p_amtwidrwy > 0 

        exit;   --for r1 in c_tlmedexh loop
      end if; -- v_flgfound
    end loop; -- c_tlmedexh
    --
    if v_typrel = '9' then
--<<Error ST11/STT-SS-2201/redmine9079
    --9--Family
            begin
              select nvl(sum(amtalw),0),count(distinct(numvcher)),
                         nvl(sum(decode(typamt,v_typamt,amtalw,0)),0),count(distinct(decode(typamt,v_typamt,numvcher,null)))
                 into p_amtacc,         p_qtyacc,
                        p_amtacc_typ,   p_qtyacc_typ
                from tclnsinf
               where numvcher  <> nvl(p_numvcher,'#')
                 and codempid  = p_codempid
                 and dtecrest  between v_dtestr and v_dteend
                 and (typamt   = v_typamt or v_typamt = 'A')
                 and (v_typrel = '9' and codrel  in  ('M' ,'F','C','S') )
                 and staappov in ('P', 'Y');
            end;
-->>Error ST11/STT-SS-2201/redmine9079
    else
    --E-Employee
            begin
              select nvl(sum(amtalw),0),count(distinct(numvcher)),
                         nvl(sum(decode(typamt,v_typamt,amtalw,0)),0),
                         count(distinct(decode(typamt,v_typamt,numvcher,null)))
                 into p_amtacc,p_qtyacc,
                         p_amtacc_typ,p_qtyacc_typ
              from tclnsinf
             where numvcher  <> nvl(p_numvcher,'#')
                 and codempid  = p_codempid
                 and dtecrest  between v_dtestr and v_dteend
                 and (typamt   = v_typamt or v_typamt = 'A')
                 and (codrel      = v_typrel or v_typrel = 'A')
                 and staappov in ('P', 'Y');
            end;
    end if;

--insert_ttemprpt('BF','BF',1,'p_amtwidrwy='||p_amtwidrwy,'=p_amtacc='||p_amtacc,null,'v_typrel='||v_typrel);

    p_amtbal := p_amtwidrwy - p_amtacc;
  end;  --  procedure get_medlimit

  procedure get_condtypamt(p_codempid   varchar2,
                                                 p_dtereq     date,
                                                 p_dtestart   date,
                                                 p_numvcher   varchar2,
                                                 p_typamt     varchar2,
                                                 p_typrel     varchar2,
                                                 p_amtwidrwy  out number,
                                                 p_qtywidrwy  out number,
                                                 p_amtwidrwt  out number,
                                                 p_typamt_a   out   varchar2,
                                                 p_typrel_a     out varchar2,
                                                 p_amtwidrwy_a  out number,
                                                 p_qtywidrwy_a  out number,
                                                 p_amtwidrwt_a  out number
                                                 ) is

    v_codpos      temploy1.codpos%type;
    v_jobgrade    temploy1.jobgrade%type;
    v_codcomp     temploy1.codcomp%type;
    v_typemp      temploy1.typemp%type;
    v_numlvl      temploy1.numlvl%type;
    v_staemp      temploy1.staemp%type;
    v_codempmt    temploy1.codempmt%type;
    v_dteempmt    temploy1.dteempmt%type;
    v_daybfst     tcontrbf.daybfst%type;
    v_mthbfst     tcontrbf.mthbfst%type;
    v_daybfen     tcontrbf.daybfen%type;
    v_mthbfen     tcontrbf.mthbfen%type;
    v_year        number;
    v_dtestr      date;
    v_dteend      date;
    v_flgfound    boolean := false;
    v_flgfound2   boolean := false;
    v_desc        tisrpinf.condisrp%type;
    v_stmt        varchar2(4000);
    v_numseq      tlmedexh.numseq%type;
    v_typamt      tlmedexp.typamt%type;
    v_cnt1        number := 0;
    v_cnt2        number := 0;
    v_cnt3        number := 0;
    v_amtwidrwy1  number;
    v_amtwidrwy2  number;
    v_amtwidrwy3  number;
    v_amtwidrwt1  number;
    v_amtwidrwt2  number;
    v_amtwidrwt3  number;
    v_qtywidrwy1  number;
    v_qtywidrwy2  number;
    v_qtywidrwy3  number;
    v_amtbal      number;
    v_typrel      tlmedexp.typrel%type;

    cursor c_tlmedexh is
      select codcompy,numseq,syncond,flgprorate
        from tlmedexh
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
    order by numseq;

  begin
    p_amtwidrwy  := 0;
    p_qtywidrwy  := 0;
    p_amtwidrwt  := 0;
--
    p_typamt_a   := 'X';
    p_typrel_a     := 'X';
    p_amtwidrwy_a  := 0;
    p_qtywidrwy_a  := 0;
    p_amtwidrwt_a  := 0;

    begin
      select codpos,jobgrade,codcomp,typemp,numlvl,staemp,codempmt,dteempmt
        into v_codpos,v_jobgrade,v_codcomp,v_typemp,v_numlvl,v_staemp,v_codempmt,v_dteempmt
        from temploy1
       where codempid  = p_codempid;
    exception when no_data_found then return;
    end;

    begin
      select daybfst, mthbfst, daybfen, mthbfen
        into v_daybfst, v_mthbfst, v_daybfen, v_mthbfen
        from tcontrbf
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontrbf
                          where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                            and dteeffec <= sysdate);
    exception when no_data_found then return;
    end;

    if v_daybfst is null or v_mthbfst is null or v_daybfen is null or v_mthbfen is null then
      return;
    end if;

    if v_mthbfst >  v_mthbfen  then
      v_year := to_char(p_dtestart,'yyyy')-1;
      v_dtestr := to_date(v_daybfst||'/'||v_mthbfst||'/'||v_year,'dd/mm/yyyy');
      v_dteend := to_date(v_daybfen||'/'||v_mthbfen||'/'||to_char(p_dtestart,'yyyy'),'dd/mm/yyyy');
    else
      v_year := to_char(p_dtestart,'yyyy');
      v_dtestr := to_date(v_daybfst||'/'||v_mthbfst||'/'||v_year,'dd/mm/yyyy');
      v_dteend := to_date(v_daybfen||'/'||v_mthbfen||'/'||to_char(p_dtestart,'yyyy'),'dd/mm/yyyy');
    end if;


    for r1 in c_tlmedexh loop
      v_flgfound := true;
      if r1.syncond is not null then
        v_desc := r1.syncond;
        v_desc := replace(v_desc,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
        v_desc := replace(v_desc,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
        v_desc := replace(v_desc,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
        v_desc := replace(v_desc,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
        v_desc := replace(v_desc,'TEMPLOY1.NUMLVL',v_numlvl);
        v_desc := replace(v_desc,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
        v_desc := replace(v_desc,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
        v_desc := replace(v_desc,'TEMPLOY1.CODREL',''''||p_typrel||'''');

--p_typrel = E-Employee	, S-Spouse	 ,C-Children ,F-Father - Mother ,9-Family ,A-All
        v_stmt := 'select count(*) from dual where '||v_desc;
        v_flgfound := execute_stmt(v_stmt);
      end if;

      if v_flgfound then
        begin
          select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
            into v_cnt1,v_amtwidrwy1,v_amtwidrwt1,v_qtywidrwy1
            from tlmedexp
           where codcompy = r1.codcompy
             and numseq   = r1.numseq
             and typamt   = p_typamt
             and typrel   = p_typrel;
        end;

        if v_cnt1 > 0 then
          p_amtwidrwy  := v_amtwidrwy1;
          p_amtwidrwt  := v_amtwidrwt1;
          p_qtywidrwy  := v_qtywidrwy1;

          v_typamt     := p_typamt;
          v_typrel        := p_typrel;
        end if;


          begin
            select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
              into v_cnt2,v_amtwidrwy2,v_amtwidrwt2,v_qtywidrwy2
              from tlmedexp
             where codcompy = r1.codcompy
               and numseq   = r1.numseq
               and typamt   = 'A'
               and typrel     = 'A';--p_typrel;
          end;
          if v_cnt2 > 0 then
                p_amtwidrwy_a  := v_amtwidrwy2;
                p_amtwidrwt_a  := v_amtwidrwt2;
                p_qtywidrwy_a  := v_qtywidrwy2;

                p_typamt_a     := 'A';
                p_typrel_a       :=  'A';--p_typrel;
          else
              begin
                    select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
                      into v_cnt2,v_amtwidrwy2,v_amtwidrwt2,v_qtywidrwy2
                      from tlmedexp
                     where codcompy = r1.codcompy
                       and numseq   = r1.numseq
                       and typamt   = p_typamt
                       and typrel     = 'A';--p_typrel;
                  end;
                  if v_cnt2 > 0 then
                        p_amtwidrwy_a  := v_amtwidrwy2;
                        p_amtwidrwt_a  := v_amtwidrwt2;
                        p_qtywidrwy_a  := v_qtywidrwy2;

                        p_typamt_a     := p_typamt;
                        p_typrel_a       :=  'A';--p_typrel;
                  else
                        begin
                            select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
                              into v_cnt2,v_amtwidrwy2,v_amtwidrwt2,v_qtywidrwy2
                              from tlmedexp
                             where codcompy = r1.codcompy
                               and numseq   = r1.numseq
                               and typamt   = 'A'--p_typamt
                               and typrel   = p_typrel;
                          end;

                          if v_cnt2 > 0 then
                                p_amtwidrwy_a  := v_amtwidrwy2;
                                p_amtwidrwt_a  := v_amtwidrwt2;
                                p_qtywidrwy_a  := v_qtywidrwy2;

                                p_typamt_a      :='A';  --p_typamt;
                                p_typrel_a        :=  p_typrel;              
                         else                                                
                                      if p_typrel in ('M','F','C','S') then
--<<Error ST11/STT-SS-2201/redmine9079
                                           begin
                                                  select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
                                                    into v_cnt3,v_amtwidrwy3,v_amtwidrwt3,v_qtywidrwy3
                                                    from tlmedexp
                                                   where codcompy = r1.codcompy
                                                     and numseq   = r1.numseq
                                                     and typamt   =p_typamt
                                                     and typrel   = '9'; -- 9-Family
                                            end;
                                            if v_cnt3 > 0 then
                                              p_amtwidrwy_a  := v_amtwidrwy3;
                                              p_amtwidrwt_a  := v_amtwidrwt3;
                                              p_qtywidrwy_a  := v_qtywidrwy3;

                                              p_typamt_a     :=p_typamt;
                                              p_typrel_a        := '9'; -- 9-Family
                                            else  --v_cnt3 = 0
                                               begin
                                                  select count(codcompy),sum(amtwidrwy),sum(amtwidrwt),sum(qtywidrwy)
                                                    into v_cnt3,v_amtwidrwy3,v_amtwidrwt3,v_qtywidrwy3
                                                    from tlmedexp
                                                   where codcompy = r1.codcompy
                                                     and numseq   = r1.numseq
                                                     and typamt   ='A'
                                                     and typrel   = '9'; -- 9-Family
                                                end;
                                                if v_cnt3 > 0 then
                                                      p_amtwidrwy_a  := v_amtwidrwy3;
                                                      p_amtwidrwt_a  := v_amtwidrwt3;
                                                      p_qtywidrwy_a  := v_qtywidrwy3;

                                                      p_typamt_a     :='A';
                                                      p_typrel_a        := '9'; -- 9-Family
                                                end if;
                                            end if;   --if v_cnt3 > 0 then
-->>Error ST11/STT-SS-2201/redmine9079
                                     end if; --if p_typrel in ('F','C','S') then
                        end if;  -- if v_cnt2 > 0 then
                end if;  -- if v_cnt2 > 0 then
          end if;--v_cnt2

        if p_amtwidrwy > 0 and r1.flgprorate = 'Y' and v_dteempmt between v_dtestr and v_dteend then           
           p_amtwidrwy := round(p_amtwidrwy * (((v_dteend - v_dteempmt) + 1) / ((v_dteend - v_dtestr) + 1)) ,2);
        end if; -- p_amtwidrwy > 0
--insert_ttemprpt('BF','BF',2,p_amtwidrwy,to_char(v_dteempmt,'dd/mm/yyyy'),to_char(v_dtestr,'dd/mm/yyyy'),to_char(v_dteend,'dd/mm/yyyy'));

         if p_amtwidrwy_a > 0 and r1.flgprorate = 'Y' and v_dteempmt between v_dtestr and v_dteend then
            p_amtwidrwy_a := round(p_amtwidrwy_a * (((v_dteend - v_dteempmt) + 1) / ((v_dteend - v_dtestr) + 1)) ,2);
        end if;
        exit;

      end if; -- v_flgfound
    end loop; -- c_tlmedexh


  end;  --  procedure get_condtypamt

  procedure get_benefit(p_codempid  in varchar2, 
                        p_codobf    in varchar2, 
                        p_codrel    in varchar2,
                        p_dtereq    in date, 
                        p_numseq    in number,
                        p_numvcher  in varchar2,
                        p_amtreq    in number,
                        p_chkemp    in varchar2,--Check emp cond. 'Y'-Yes, 'N'-No                        
                        p_codunit   out varchar2,
                        p_amtvalue  out number, 
                        p_typepay   out varchar2,
                        p_typebf    out varchar2,
                        p_flglimit  out varchar2,
                        p_qtytacc   out number,--Time acc.
                        p_amtacc    out number,--Amount acc.
                        p_qtywidrw  out number,--Quantity Budget
                        p_amtwidrw  out number,--Amount Budget
                        p_qtytalw   out number,--Time Budget
                        p_error     out varchar2)
                        is

    v_syncond   tobfcde.syncond%type;
    v_dtestart  tobfcft.dtestart%type;
    v_qtyalw    tobfcftd.qtyalw%type;
    v_cond      tobfcde.syncond%type;
    v_cond2     tobfcde.syncond%type;
    v_flgExist  varchar2(2 char);
    v_flgbf     boolean;
    v_stmt      varchar2(4000 char);
    v_stmt2     varchar2(4000 char);
    v_flgcond1  number;
    v_flgcond2  number;
    v_qty_bf    number;
    v_qty_ess   number;
    v_amt_bf    number;
    v_amt_ess   number;
    v_amtreq_old  number;
    v_qtyreq_old  number;

    cursor c1 is
      select *
        from tobfcdet
       where codobf = p_codobf
       order by numobf;

  begin
    v_flgbf := false;
    begin
      select codunit,amtvalue,typepay,flglimit,typebf
        into p_codunit,p_amtvalue,p_typepay,p_flglimit,p_typebf
        from tobfcde
       where codobf = p_codobf;
    exception when no_data_found then
      p_codunit  := '';
      p_amtvalue := '';
    end;
    -- Default
    p_qtytacc  := 0;
    p_amtacc   := 0;
    p_qtywidrw := 0;
    p_amtwidrw := 0;

    begin
      select dtestart into v_dtestart
        from tobfcft
       where codempid =  p_codempid
         and dtestart = (select max(dtestart)
                           from tobfcft
                          where codempid = p_codempid
                            and p_dtereq between dtestart and nvl(dteend, p_dtereq));
      v_flgExist := 'Y';
    exception when no_data_found then
      v_dtestart  := null;
      v_flgExist  := 'N';
    end;

    if v_flgExist = 'Y' and p_chkemp = 'Y' then
      v_flgbf := true;
      begin
        select qtyalw,qtytalw into v_qtyalw, p_qtytalw
          from tobfcftd
         where codempid = p_codempid
           and dtestart = v_dtestart
           and codobf   = p_codobf;
      exception when no_data_found then
        v_qtyalw  := 0;
        p_qtytalw := 0;
      end;
      if p_typebf = 'C' then
        p_qtywidrw := v_qtyalw;
        p_amtwidrw := v_qtyalw;
      elsif p_typebf = 'T' then
        p_qtywidrw := v_qtyalw;
        p_amtwidrw := p_amtvalue * v_qtyalw;
      end if;
    elsif v_flgExist = 'N' or p_chkemp = 'N' then
      begin
        select syncond into v_syncond
          from tobfcde
         where codobf   = p_codobf
           and dtestart = (select max(dtestart)
                             from tobfcde
                            where codobf   = p_codobf
                              and p_dtereq between dtestart and dteend);
      exception when no_data_found then
        v_syncond := null;    
      end;
      if v_syncond is not null then
        v_cond := 'and ' || v_syncond;
        v_cond := replace(v_cond,'V_HRBF41.CODREL',''''||p_codrel||'''') ;
        v_stmt :=  'select count(*)'||
                   'from V_HRBF41 '||
                   'where V_HRBF41.codempid = '||''''||p_codempid||''''||' '||
                   v_cond||' '||
                   'and rownum = 1';

        execute immediate v_stmt into v_flgcond1;
        if v_flgcond1 > 0 then
          for r1 in c1 loop
            if r1.syncond is not null then
              v_cond2 := 'and ' || r1.syncond;
              v_cond2 := replace(v_cond2,'V_HRBF41.CODREL',''''||p_codrel||'''') ;
              v_stmt2 := 'select count(*)'||
                         'from V_HRBF41 '||
                         'where V_HRBF41.codempid = '||''''||p_codempid||''''||' '||
                         v_cond2||' '||
                         'and rownum = 1';

              execute immediate v_stmt2 into v_flgcond2;
              if v_flgcond2 > 0 then
                p_qtytalw := r1.qtytalw;
                if p_typebf = 'C' then
                  p_qtywidrw := r1.qtyalw;
                  p_amtwidrw := r1.qtyalw;
                elsif p_typebf = 'T' then
                  p_qtywidrw := r1.qtytalw;
                  p_amtwidrw := p_amtvalue * r1.qtytalw;
                end if;
                v_flgbf := true;
                exit;
              end if;
            end if;
          end loop;
        end if;
      end if;
    end if;
    if not v_flgbf then      
      p_error := 'HR2055';
      return;
    end if;

    --Time Acc.
    begin
      select count(*),sum(nvl(amtwidrw,0)) into v_qty_ess,v_amt_ess
        from tobfreq
       where codempid = p_codempid
         and codobf   = p_codobf
         and staappr  in ('P','A')
         and ((p_flglimit = 'M' and to_char(dtereq,'YYYYMM') = to_char(p_dtereq,'YYYYMM'))
          or  (p_flglimit = 'Y' and to_char(dtereq,'YYYY') = to_char(p_dtereq,'YYYY'))
          or  (p_flglimit = 'A'));
    exception when no_data_found then
      v_qty_ess := 0; 
      v_amt_ess := 0;
    end;

    begin
      select sum(nvl(qtytwidrw,0)),sum(nvl(amtwidrw,0)) into v_qty_bf,v_amt_bf
        from tobfsum
       where codempid = p_codempid
         and codobf   = p_codobf
         and dtemth  <> 13
         and ((p_flglimit = 'M' and dteyre  = to_char(p_dtereq,'YYYY') and dtemth   = to_char(p_dtereq,'MM'))
          or  (p_flglimit = 'Y' and dteyre  = to_char(p_dtereq,'YYYY'))
          or  (p_flglimit = 'A'));
    exception when no_data_found then
      v_qty_bf := 0;
      v_amt_bf := 0;
    end;      
    --
    p_qtytacc := nvl(v_qty_bf,0) + nvl(v_qty_ess,0);
    p_amtacc  := nvl(v_amt_bf,0) + nvl(v_amt_ess,0);
    --
    if p_numvcher is not null then --BF req.
      begin
        select nvl(qtywidrw,0) into v_amtreq_old
          from tobfinf
         where codempid = p_codempid
           and numvcher = nvl(p_numvcher,'');
        v_qtyreq_old := 1;
      exception when no_data_found then
        v_amtreq_old := 0;
        v_qtyreq_old := 0;
      end;
    else --Ess req.
      begin
        select nvl(amtwidrw,0) into v_amtreq_old
          from tobfreq
         where codempid = p_codempid
           and dtereq   = p_dtereq 
           and numseq   = p_numseq;
        v_qtyreq_old := 1;
      exception when no_data_found then
        v_amtreq_old := 0;
        v_qtyreq_old := 0;
      end;
    end if;
    --
    if (p_qtytacc - v_qtyreq_old + 1) > p_qtytalw then
      p_error := 'BF0054';
    elsif (p_amtacc - v_amtreq_old + p_amtreq) > p_qtywidrw then
      p_error := 'BF0053';
    end if;
  end get_benefit;

end;

/

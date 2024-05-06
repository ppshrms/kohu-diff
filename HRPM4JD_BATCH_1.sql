--------------------------------------------------------
--  DDL for Package Body HRPM4JD_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM4JD_BATCH" is
--last update: 08/06/2023 16:27 redmine STT#965
--08/03/2021 12:12 redmine #5479

  PROCEDURE upd_ttcanceld
   (p_codempid in varchar2,
    p_dteeffec in date,
    p_codtrn	 in varchar2,
    p_numseq	 in number,
    p_namfld	 in varchar2,
    p_desold	 in varchar2,
    p_desnew	 in varchar2)
  IS
    v_exist		boolean;
  cursor c_ttcanceld is
    select rowid
    from   ttcanceld
    where  codempid = p_codempid
    and    dteeffec = p_dteeffec
    and    codtrn	  = p_codtrn
    and    numseq   = p_numseq
    and		 namfld		= p_namfld;
  begin
    v_exist := false;
    for r_ttcanceld in c_ttcanceld loop
      v_exist := true;
      update ttcanceld
        set	 desold = p_desold,
             desnew = p_desnew,
             coduser = global_v_coduser
        where rowid = r_ttcanceld.rowid;
    end loop;
    if not v_exist then
      insert into ttcanceld
        (codempid,dteeffec,codtrn,numseq,namfld,desold,desnew,coduser,codcreate)
      values
        (p_codempid,p_dteeffec,p_codtrn,p_numseq,p_namfld,p_desold,p_desnew,global_v_coduser,global_v_coduser);
    end if;
  end;
  -- end upd_ttcanceld
  FUNCTION Get_NaxNumseq(v_codempid varchar2,v_dteeffec date,v_codtrn varchar2) RETURN number IS
    v_numseq number;
  BEGIN
    begin
      select max(numseq)
        into v_numseq
        from ttcancel
       where codempid = v_codempid
         and dteeffec = v_dteeffec
         and codtrn   = v_codtrn;
    end;
    v_numseq := nvl(v_numseq,0) + 1;
    return (v_numseq);
  END;
  -- end Get_NaxNumseq
  PROCEDURE recal_movement
    (p_codempid			in varchar2,
     p_dteeffec			in date,
     p_numseq				in number) IS
    prv_codcomp			temploy1.codcomp%type;
    v_codcompt			temploy1.codcomp%type;
    v_codcomp				temploy1.codcomp%type;
    prv_codpos			temploy1.codpos%type;
    v_codposnow			temploy1.codpos%type;
    v_codpos				temploy1.codpos%type;
    prv_codjob			temploy1.codjob%type;
    v_codjobt				temploy1.codjob%type;
    v_codjob				temploy1.codjob%type;
    prv_numlvl			temploy1.numlvl%type;
    v_numlvlt				temploy1.numlvl%type;
    v_numlvl				temploy1.numlvl%type;
    prv_codbrlc			temploy1.codbrlc%type;
    v_codbrlct			temploy1.codbrlc%type;
    v_codbrlc				temploy1.codbrlc%type;
    prv_codcalen		temploy1.codcalen%type;
    v_codcalet			temploy1.codcalen%type;
    v_codcalen			temploy1.codcalen%type;
    prv_codempmt		temploy1.codempmt%type;
    v_codempmtt			temploy1.codempmt%type;
    v_codempmt			temploy1.codempmt%type;
    prv_typpayroll	temploy1.typpayroll%type;
    v_typpayrolt		temploy1.typpayroll%type;
    v_typpayroll		temploy1.typpayroll%type;
    prv_typemp			temploy1.typemp%type;
    v_typempt				temploy1.typemp%type;
    v_typemp				temploy1.typemp%type;
    v_amtincom1			number := 0;
    v_amtincom2			number := 0;
    v_amtincom3			number := 0;
    v_amtincom4			number := 0;
    v_amtincom5			number := 0;
    v_amtincom6			number := 0;
    v_amtincom7			number := 0;
    v_amtincom8			number := 0;
    v_amtincom9			number := 0;
    v_amtincom10		number := 0;
  cursor c_ttmovemt is
    select codempid,dteeffec,numseq,codtrn,
           codcompt,codcomp,codposnow,codpos,codjobt,codjob,
           numlvlt,numlvl,codbrlct,codbrlc,codcalet,codcalen,
           codempmtt,codempmt,typpayrolt,typpayroll,typempt,typemp,
           amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
           amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
           amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,
           amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,namtab
    from ((select codempid,dteeffec,numseq,codtrn,
                  codcompt,codcomp,codposnow,codpos,codjobt,codjob,
                  numlvlt,numlvl,codbrlct,codbrlc,codcalet,codcalen,
                  codempmtt,codempmt,typpayrolt,typpayroll,typempt,typemp,
                  stddec(amtincom1,codempid,global_v_chken) amtincom1,
                  stddec(amtincom2,codempid,global_v_chken) amtincom2,
                  stddec(amtincom3,codempid,global_v_chken) amtincom3,
                  stddec(amtincom4,codempid,global_v_chken) amtincom4,
                  stddec(amtincom5,codempid,global_v_chken) amtincom5,
                  stddec(amtincom6,codempid,global_v_chken) amtincom6,
                  stddec(amtincom7,codempid,global_v_chken) amtincom7,
                  stddec(amtincom8,codempid,global_v_chken) amtincom8,
                  stddec(amtincom9,codempid,global_v_chken) amtincom9,
                  stddec(amtincom10,codempid,global_v_chken) amtincom10,
                  stddec(amtincadj1,codempid,global_v_chken) amtincadj1,
                  stddec(amtincadj2,codempid,global_v_chken) amtincadj2,
                  stddec(amtincadj3,codempid,global_v_chken) amtincadj3,
                  stddec(amtincadj4,codempid,global_v_chken) amtincadj4,
                  stddec(amtincadj5,codempid,global_v_chken) amtincadj5,
                  stddec(amtincadj6,codempid,global_v_chken) amtincadj6,
                  stddec(amtincadj7,codempid,global_v_chken) amtincadj7,
                  stddec(amtincadj8,codempid,global_v_chken) amtincadj8,
                  stddec(amtincadj9,codempid,global_v_chken) amtincadj9,
                  stddec(amtincadj10,codempid,global_v_chken) amtincadj10,
                  'TTMOVEMT' namtab
           from   ttmovemt
           where  codempid  = p_codempid)
         union
          (select codempid,dteduepr dteeffec,0 numseq,'0003' codtrn,
                  codcomp codcompt,codcomp,codpos codposnow,codpos,' ' codjobt,' ' codjob,
                  numlvl numlvlt,numlvl,codbrlc codbrlct,codbrlc,codcalen codcalet,codcalen,
                  codempmt codempmtt,codempmt,typpayroll typpayrolt,typpayroll,typemp typempt,typemp,
                  stddec(amtincom1,codempid,global_v_chken) amtincom1,
                  stddec(amtincom2,codempid,global_v_chken) amtincom2,
                  stddec(amtincom3,codempid,global_v_chken) amtincom3,
                  stddec(amtincom4,codempid,global_v_chken) amtincom4,
                  stddec(amtincom5,codempid,global_v_chken) amtincom5,
                  stddec(amtincom6,codempid,global_v_chken) amtincom6,
                  stddec(amtincom7,codempid,global_v_chken) amtincom7,
                  stddec(amtincom8,codempid,global_v_chken) amtincom8,
                  stddec(amtincom9,codempid,global_v_chken) amtincom9,
                  stddec(amtincom10,codempid,global_v_chken) amtincom10,
                  stddec(amtincadj1,codempid,global_v_chken) amtincadj1,
                  stddec(amtincadj2,codempid,global_v_chken) amtincadj2,
                  stddec(amtincadj3,codempid,global_v_chken) amtincadj3,
                  stddec(amtincadj4,codempid,global_v_chken) amtincadj4,
                  stddec(amtincadj5,codempid,global_v_chken) amtincadj5,
                  stddec(amtincadj6,codempid,global_v_chken) amtincadj6,
                  stddec(amtincadj7,codempid,global_v_chken) amtincadj7,
                  stddec(amtincadj8,codempid,global_v_chken) amtincadj8,
                  stddec(amtincadj9,codempid,global_v_chken) amtincadj9,
                  stddec(amtincadj10,codempid,global_v_chken) amtincadj10,
                  'TTPROBAT' namtab
           from   ttprobat
           where  codempid  = p_codempid))
    where ((dteeffec = p_dteeffec and numseq >= p_numseq)
    or 		 (dteeffec > p_dteeffec))
    order by dteeffec,numseq;
  begin
    for r1 in c_ttmovemt loop
      if r1.dteeffec = p_dteeffec and r1.numseq = p_numseq then
        prv_codcomp := r1.codcompt;
        prv_codpos := r1.codposnow;
        prv_codjob := r1.codjobt;
        prv_numlvl := r1.numlvlt;
        prv_codbrlc := r1.codbrlct;
        prv_codcalen := r1.codcalet;
        prv_codempmt := r1.codempmtt;
        prv_typpayroll := r1.typpayrolt;
        prv_typemp := r1.typempt;
        v_amtincom1 := nvl(r1.amtincom1,0) - r1.amtincadj1;
        v_amtincom2 := nvl(r1.amtincom2,0) - r1.amtincadj2;
        v_amtincom3 := nvl(r1.amtincom3,0) - r1.amtincadj3;
        v_amtincom4 := nvl(r1.amtincom4,0) - r1.amtincadj4;
        v_amtincom5 := nvl(r1.amtincom5,0) - r1.amtincadj5;
        v_amtincom6 := nvl(r1.amtincom6,0) - r1.amtincadj6;
        v_amtincom7 := nvl(r1.amtincom7,0) - r1.amtincadj7;
        v_amtincom8 := nvl(r1.amtincom8,0) - r1.amtincadj8;
        v_amtincom9 := nvl(r1.amtincom9,0) - r1.amtincadj9;
        v_amtincom10 := nvl(r1.amtincom10,0) - r1.amtincadj10;
        update ttmovemt
          set	amtincom1 = stdenc(v_amtincom1,codempid,global_v_chken),
              amtincom2 = stdenc(v_amtincom2,codempid,global_v_chken),
              amtincom3 = stdenc(v_amtincom3,codempid,global_v_chken),
              amtincom4 = stdenc(v_amtincom4,codempid,global_v_chken),
              amtincom5 = stdenc(v_amtincom5,codempid,global_v_chken),
              amtincom6 = stdenc(v_amtincom6,codempid,global_v_chken),
              amtincom7 = stdenc(v_amtincom7,codempid,global_v_chken),
              amtincom8 = stdenc(v_amtincom8,codempid,global_v_chken),
              amtincom9 = stdenc(v_amtincom9,codempid,global_v_chken),
              amtincom10 = stdenc(v_amtincom10,codempid,global_v_chken),
              coduser = global_v_coduser
          where codempid = p_codempid
          and		dteeffec = r1.dteeffec
          and		numseq	 = r1.numseq;
      else
        v_codcompt := prv_codcomp;	-- CODCOMP
        v_codcomp := r1.codcomp;
        if r1.codcompt = r1.codcomp then
          v_codcomp := prv_codcomp;
        end if;
        prv_codcomp := v_codcomp;
        v_codposnow := prv_codpos;	-- CODPOS
        v_codpos := r1.codpos;
        if r1.codposnow = r1.codpos then
          v_codpos := prv_codpos;
        end if;
        prv_codpos := v_codpos;
        v_codjobt := prv_codjob;	-- CODJOB
        v_codjob := r1.codjob;
        if r1.codjobt = r1.codjob then
          v_codjob := prv_codjob;
        end if;
        prv_codjob := v_codjob;
        v_numlvlt := prv_numlvl;	-- NUMLVL
        v_numlvl := r1.numlvl;
        if r1.numlvlt = r1.numlvl then
          v_numlvl := prv_numlvl;
        end if;
        prv_numlvl := v_numlvl;
        v_codbrlct := prv_codbrlc;	-- CODBRLC
        v_codbrlc := r1.codbrlc;
        if r1.codbrlct = r1.codbrlc then
          v_codbrlc := prv_codbrlc;
        end if;
        prv_codbrlc := v_codbrlc;
        v_codcalet := prv_codcalen;	-- CODCALEN
        v_codcalen := r1.codcalen;
        if r1.codcalet = r1.codcalen then
          v_codcalen := prv_codcalen;
        end if;
        prv_codcalen := v_codcalen;
        v_codempmtt := prv_codempmt;	-- CODEMPMT
        v_codempmt := r1.codempmt;
        if r1.codempmtt = r1.codempmt then
          v_codempmt := prv_codempmt;
        end if;
        prv_codempmt := v_codempmt;
        v_typpayrolt := prv_typpayroll;	-- TYPPAYROLL
        v_typpayroll := r1.typpayroll;
        if r1.typpayrolt = r1.typpayroll then
          v_typpayroll := prv_typpayroll;
        end if;
        prv_typpayroll := v_typpayroll;
        v_typempt := prv_typemp;	-- TYPEMP
        v_typemp := r1.typemp;
        if r1.typempt = r1.typemp then
          v_typemp := prv_typemp;
        end if;
        prv_typemp := v_typemp;
        v_amtincom1 := v_amtincom1 + nvl(r1.amtincadj1,0);
        v_amtincom2 := v_amtincom2 + nvl(r1.amtincadj2,0);
        v_amtincom3 := v_amtincom3 + nvl(r1.amtincadj3,0);
        v_amtincom4 := v_amtincom4 + nvl(r1.amtincadj4,0);
        v_amtincom5 := v_amtincom5 + nvl(r1.amtincadj5,0);
        v_amtincom6 := v_amtincom6 + nvl(r1.amtincadj6,0);
        v_amtincom7 := v_amtincom7 + nvl(r1.amtincadj7,0);
        v_amtincom8 := v_amtincom8 + nvl(r1.amtincadj8,0);
        v_amtincom9 := v_amtincom9 + nvl(r1.amtincadj9,0);
        v_amtincom10 := v_amtincom10 + nvl(r1.amtincadj10,0);
        if r1.namtab = 'TTMOVEMT' then
          update ttmovemt
            set	codcompt = v_codcompt,codcomp = v_codcomp,
                codjobt = v_codjobt,codjob = v_codjob,
                codposnow = v_codposnow,codpos = v_codpos,
                numlvlt = v_numlvlt,numlvl = v_numlvl,
                codbrlct = v_codbrlct,codbrlc = v_codbrlc,
                codcalet = v_codcalet,codcalen = v_codcalen,
                codempmtt = v_codempmtt,codempmt = v_codempmt,
                typpayrolt = v_typpayrolt,typpayroll = v_typpayroll,
                typempt = v_typempt,typemp = v_typemp,
                amtincom1 = stdenc(v_amtincom1,codempid,global_v_chken),
                amtincom2 = stdenc(v_amtincom2,codempid,global_v_chken),
                amtincom3 = stdenc(v_amtincom3,codempid,global_v_chken),
                amtincom4 = stdenc(v_amtincom4,codempid,global_v_chken),
                amtincom5 = stdenc(v_amtincom5,codempid,global_v_chken),
                amtincom6 = stdenc(v_amtincom6,codempid,global_v_chken),
                amtincom7 = stdenc(v_amtincom7,codempid,global_v_chken),
                amtincom8 = stdenc(v_amtincom8,codempid,global_v_chken),
                amtincom9 = stdenc(v_amtincom9,codempid,global_v_chken),
                amtincom10 = stdenc(v_amtincom10,codempid,global_v_chken),
                coduser = global_v_coduser
            where codempid = p_codempid
            and		dteeffec = r1.dteeffec
            and		numseq	 = r1.numseq;
        else
          update ttprobat
            set	codcomp = v_codcomp,
                codpos = v_codpos,numlvl = v_numlvl,
                codbrlc = v_codbrlc,codcalen = v_codcalen,
                codempmt = v_codempmt,typpayroll = v_typpayroll,
                typemp = v_typemp,
                amtincom1 = stdenc(v_amtincom1,codempid,global_v_chken),
                amtincom2 = stdenc(v_amtincom2,codempid,global_v_chken),
                amtincom3 = stdenc(v_amtincom3,codempid,global_v_chken),
                amtincom4 = stdenc(v_amtincom4,codempid,global_v_chken),
                amtincom5 = stdenc(v_amtincom5,codempid,global_v_chken),
                amtincom6 = stdenc(v_amtincom6,codempid,global_v_chken),
                amtincom7 = stdenc(v_amtincom7,codempid,global_v_chken),
                amtincom8 = stdenc(v_amtincom8,codempid,global_v_chken),
                amtincom9 = stdenc(v_amtincom9,codempid,global_v_chken),
                amtincom10 = stdenc(v_amtincom10,codempid,global_v_chken),
                coduser = global_v_coduser
            where codempid = p_codempid
            and		dteduepr = r1.dteeffec;
        end if;
      end if;
    end loop;
  end;
  -- end recal_movement
  procedure cancel_ttrehire(p_codempid varchar2,p_dteeffec date,p_codtrn varchar2,p_coduser varchar2) is
  	v_exist				boolean;
    v_codempid	  ttrehire.codempid%type;
    v_dteeffec    ttrehire.dtereemp%type;
    v_codtrn      tcodmove.codcodec%type;
    v_numseq			number;
    v_codnewid	  ttrehire.codnewid%type;
    v_flgcompDif	varchar2(1);
    v_codcomp			tcenter.codcomp%type;

  cursor c_ttrehire is
    select rowid,flgreemp,codnewid,dteduepr,staemp,--flgconti,
           codempid,codcomp
           ,staupd--User37 STA4610099 02/05/2018
    from	 ttrehire
    where	 codempid = v_codempid
    and		 dtereemp = v_dteeffec
    and		 staupd in('C','U');

  cursor c_ttcancel is
    select rowid
    from   ttcancel
    where  codempid = v_codempid
    and    dteeffec = v_dteeffec
    and    codtrn	  = v_codtrn
    and    numseq   = v_numseq;
  begin
    global_v_coduser  := p_coduser;
    v_codempid := p_codempid;
    v_dteeffec := p_dteeffec;
    v_codtrn   := p_codtrn;
    v_numseq	 := Get_NaxNumseq(v_codempid,v_dteeffec,v_codtrn);-- user22 : 20/11/2015 : BHI-580005 || v_numseq	 := 1;
    for r1 in c_ttrehire loop
      if r1.staupd = 'U' then --User37 STA4610099 02/05/2018
        v_codnewid := r1.codnewid;
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'FLGREEMP',null,r1.flgreemp);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'CODNEWID',null,r1.codnewid);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'DTEDUEPR',null,to_date(r1.dteduepr,'dd/mm/yyyy'));
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'STAEMP',null,r1.staemp);
--        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'FLGCONTI',null,r1.flgconti);
        if v_codnewid is not null then
          delete tattence where codempid = v_codnewid and dtework >= v_dteeffec;
          delete tlateabs where codempid = v_codnewid and dtework >= v_dteeffec;
          delete thismove
            where  codempid = v_codnewid
            and    dteeffec = v_dteeffec
            and		 codtrn		= v_codtrn;
          delete ttpminf
            where  codempid = v_codnewid
            and    dteeffec = v_dteeffec
            and		 codtrn		= v_codtrn;
--          if r1.flgconti = 'N' then
--            delete tchildrn where	codempid = v_codnewid;
--            delete tspouse	where	codempid = v_codnewid;
--            delete tfamily	where	codempid = v_codnewid;
--          else
--<< user22 : 10/08/2016 : STA3590307 ||
            /* -->> User46 25/05/2020 Comment Dr.*/
            v_codcomp := null;
            begin
              select codcomp into v_codcomp
                from temploy1
               where codempid = r1.codempid;
            exception when others then null;
            end ;
            v_flgcompdif := 'N';
            if hcm_util.get_codcomp_level(r1.codcomp,'1') <> hcm_util.get_codcomp_level(v_codcomp,'1') then
              v_flgcompdif := 'Y';
            end if;
          hrpm91b_batch.replace_codempid(v_codnewid,v_codempid,v_flgcompdif);
          delete temploy3 where	codempid = v_codnewid;
          delete temploy2 where	codempid = v_codnewid;
          delete temploy1 where	codempid = v_codnewid;
        else
          update temploy1
            set staemp = '9',dteeffex = (select max(dteeffec) from ttpminf
                                         where codempid = v_codempid
                                         and	 dteeffec <= v_dteeffec
                                         and	 codtrn = '0006'),
                coduser = p_coduser
            where	codempid = v_codempid;
          delete tattence where codempid = v_codempid and dtework >= v_dteeffec;
          delete tlateabs where codempid = v_codempid and dtework >= v_dteeffec;
          delete thismove
            where  codempid = v_codempid
            and    dteeffec = v_dteeffec
            and		 codtrn		= v_codtrn;
          delete ttpminf
            where  codempid = v_codempid
            and    dteeffec = v_dteeffec
            and		 codtrn		= v_codtrn;
        end if;
        v_exist := false;
        for r4 in c_ttcancel loop
          v_exist := true;
          update ttcancel
            set	 coduser = p_coduser
            where rowid = r4.rowid;
        end loop;
        if not v_exist then
          insert into ttcancel
            (codempid,dteeffec,codtrn,numseq,coduser,codcreate)
          values
            (v_codempid,v_dteeffec,v_codtrn,v_numseq,p_coduser,p_coduser);
        end if;
      end if;
      --<< User46 25/05/2020
      update ttrehire
         set staupd   = 'P',
             approvno = null,
             codappr  = null,
             dteappr  = null,
             coduser  = p_coduser
       where rowid = r1.rowid;

      delete tapmovmt
       where codapp     = 'HRPM21E'
         and codempid   = v_codempid
         and dteeffec   = v_dteeffec
         and numseq     = 1; -- v_numseq

      -- Comment Dr. delete ttrehire where rowid = r1.rowid;
      -->>
    end loop; -- c_ttrehire
  end;
  -- end cancel_ttrehire
  procedure cancel_ttprobat(p_codempid varchar2,p_dteeffec date,p_codtrn varchar2,p_typproba varchar2,p_coduser varchar2) is
    v_exist				boolean;
    v_codempid	  ttprobat.codempid%type;
    v_dteeffec    ttprobat.dteeffec%type;
    v_codtrn      tcodmove.codcodec%type;
    v_numseq			number;
    v_numoffid    tbcklst.numoffid%type;
    v_staemp			temploy1.staemp%type;
    v_typproba    ttprobat.typproba%type;
    v_dteoccup		date;
    v_amtincom1		number;
    v_amtincom2		number;
    v_amtincom3		number;
    v_amtincom4		number;
    v_amtincom5		number;
    v_amtincom6		number;
    v_amtincom7		number;
    v_amtincom8		number;
    v_amtincom9		number;
    v_amtincom10	number;
    v_amtothr			number;
    v_amtday			number;
    v_amtmth			number;
  cursor c_ttprobat is
--    select rowid,codcomp,codempmt,flgadjin,staupd, --<< user20 Date: 02/09/2021  PM Module- #6139
    select rowid,codcomp,codempmt,flgadjin,staupd,dteduepr,typpayroll,typemp,
--<< user20 Date: 02/09/2021  PM Module- #6139
           typproba,codrespr,dteoccup,/*scorepr,*/codexemp,qtyexpand,
           amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
           amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
           amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,
           amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10
    from	 ttprobat
    where	 codempid = v_codempid
    and		 dteduepr = v_dteeffec
    and		 typproba = v_typproba
    and		 staupd in('C','U');
  cursor c_ttcancel is
    select rowid
    from   ttcancel
    where  codempid = v_codempid
    and    dteeffec = v_dteeffec
    and    codtrn	  = v_codtrn
    and    numseq   = v_numseq;
  begin
    global_v_coduser  := p_coduser;
    v_codempid := p_codempid;
    v_dteeffec := p_dteeffec;
    v_codtrn   := p_codtrn;
    v_typproba := p_typproba;
    v_numseq	 := Get_NaxNumseq(v_codempid,v_dteeffec,v_codtrn);-- user22 : 20/11/2015 : BHI-580005 || v_numseq	 := 1;
    for r1 in c_ttprobat loop
      if r1.staupd = 'U' then --User37 STA4610099 02/05/2018
        v_dteoccup := r1.dteoccup;
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'TYPPROBA',null,r1.typproba);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'CODRESPR',null,r1.codrespr);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'DTEOCCUP',null,to_date(r1.dteoccup,'dd/mm/yyyy'));
--        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'SCOREPR',null,r1.scorepr);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'CODEXEMP',null,r1.codexemp);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'QTYEXPAND',null,r1.qtyexpand);
        if r1.flgadjin = 'Y' then
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM1',r1.amtincom1,r1.amtincadj1);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM2',r1.amtincom2,r1.amtincadj2);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM3',r1.amtincom3,r1.amtincadj3);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM4',r1.amtincom4,r1.amtincadj4);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM5',r1.amtincom5,r1.amtincadj5);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM6',r1.amtincom6,r1.amtincadj6);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM7',r1.amtincom7,r1.amtincadj7);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM8',r1.amtincom8,r1.amtincadj8);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM9',r1.amtincom9,r1.amtincadj9);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM10',r1.amtincom10,r1.amtincadj10);
          begin
            select stddec(amtincom1,codempid,global_v_chken),
                   stddec(amtincom2,codempid,global_v_chken),
                   stddec(amtincom3,codempid,global_v_chken),
                   stddec(amtincom4,codempid,global_v_chken),
                   stddec(amtincom5,codempid,global_v_chken),
                   stddec(amtincom6,codempid,global_v_chken),
                   stddec(amtincom7,codempid,global_v_chken),
                   stddec(amtincom8,codempid,global_v_chken),
                   stddec(amtincom9,codempid,global_v_chken),
                   stddec(amtincom10,codempid,global_v_chken)
            into 	 v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
                   v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
            from	 temploy3
            where	 codempid = v_codempid;
          exception when no_data_found then
            v_amtincom1 := 0; v_amtincom2 := 0; v_amtincom3 := 0; v_amtincom4 := 0; v_amtincom5 := 0;
            v_amtincom6 := 0; v_amtincom7 := 0; v_amtincom8 := 0; v_amtincom9 := 0; v_amtincom10 := 0;
          end;
          v_amtincom1 := nvl(v_amtincom1,0) - stddec(r1.amtincadj1,v_codempid,global_v_chken);
          v_amtincom2 := nvl(v_amtincom2,0) - stddec(r1.amtincadj2,v_codempid,global_v_chken);
          v_amtincom3 := nvl(v_amtincom3,0) - stddec(r1.amtincadj3,v_codempid,global_v_chken);
          v_amtincom4 := nvl(v_amtincom4,0) - stddec(r1.amtincadj4,v_codempid,global_v_chken);
          v_amtincom5 := nvl(v_amtincom5,0) - stddec(r1.amtincadj5,v_codempid,global_v_chken);
          v_amtincom6 := nvl(v_amtincom6,0) - stddec(r1.amtincadj6,v_codempid,global_v_chken);
          v_amtincom7 := nvl(v_amtincom7,0) - stddec(r1.amtincadj7,v_codempid,global_v_chken);
          v_amtincom8 := nvl(v_amtincom8,0) - stddec(r1.amtincadj8,v_codempid,global_v_chken);
          v_amtincom9 := nvl(v_amtincom9,0) - stddec(r1.amtincadj9,v_codempid,global_v_chken);
          v_amtincom10 := nvl(v_amtincom10,0) - stddec(r1.amtincadj10,v_codempid,global_v_chken);
          get_wage_income(hcm_util.get_codcomp_level(r1.codcomp,'1'),r1.codempmt,
                           nvl(v_amtincom1,0), nvl(v_amtincom2,0),
                           nvl(v_amtincom3,0), nvl(v_amtincom4,0),
                           nvl(v_amtincom5,0), nvl(v_amtincom6,0),
                           nvl(v_amtincom7,0), nvl(v_amtincom8,0),
                           nvl(v_amtincom9,0), nvl(v_amtincom10,0),
                           v_amtothr,v_amtday,v_amtmth);
          update temploy3
            set amtincom1  = stdenc(v_amtincom1,codempid,global_v_chken),
                amtincom2  = stdenc(v_amtincom2,codempid,global_v_chken),
                amtincom3  = stdenc(v_amtincom3,codempid,global_v_chken),
                amtincom4  = stdenc(v_amtincom4,codempid,global_v_chken),
                amtincom5  = stdenc(v_amtincom5,codempid,global_v_chken),
                amtincom6  = stdenc(v_amtincom6,codempid,global_v_chken),
                amtincom7  = stdenc(v_amtincom7,codempid,global_v_chken),
                amtincom8  = stdenc(v_amtincom8,codempid,global_v_chken),
                amtincom9  = stdenc(v_amtincom9,codempid,global_v_chken),
                amtincom10 = stdenc(v_amtincom10,codempid,global_v_chken),
                amtothr    = stdenc(v_amtothr,codempid,global_v_chken),
                amtday		 = stdenc(v_amtday,codempid,global_v_chken),
                coduser    = p_coduser
            where	codempid = v_codempid;
          delete tfincadj
            where  codempid = v_codempid
            and    dteeffec = v_dteoccup;
        end if; -- flgadjin
        if r1.staupd = 'U' then
          if r1.typproba = '1' then
            update temploy1
              set staemp = '1',dteoccup = null,coduser = p_coduser,
--<< user20 Date: 02/09/2021  PM Module- #6139
	            codempmt   = r1.codempmt,
	            typemp     = r1.typemp,
	            typpayroll = r1.typpayroll,
	            dteduepr   = r1.dteduepr,
	            dteredue   = decode(dteredue , null  ,null  , r1.dteduepr)
--<< user20 Date: 02/09/2021  PM Module- #6139
              where	codempid = v_codempid;
          else
            update temploy1
              set staemp = '3',coduser = p_coduser,
--<< user20 Date: 02/09/2021  PM Module- #6139
	            codempmt   = r1.codempmt,
	            typemp     = r1.typemp,
	            typpayroll = r1.typpayroll
--<< user20 Date: 02/09/2021  PM Module- #6139
              where	codempid = v_codempid;
          end if;
        end if;
        if r1.codrespr = 'E' then
          delete thismove
            where  codempid = v_codempid
            and    dteeffec = v_dteeffec -- dteduepr
            and	   codtrn	= v_codtrn;
        else
          delete thismove
            where  codempid = v_codempid
            and    dteeffec = v_dteoccup
            and		 codtrn		= v_codtrn;
        end if;
        v_exist := false;
        for r4 in c_ttcancel loop
          v_exist := true;
          update ttcancel
            set	 coduser = p_coduser
            where rowid = r4.rowid;
        end loop;
        if not v_exist then
          insert into ttcancel
            (codempid,dteeffec,codtrn,numseq,coduser,codcreate)
          values
            (v_codempid,v_dteeffec,v_codtrn,v_numseq,p_coduser,p_coduser);
        end if;
      end if;
      --<< User46 25/05/2020 Comment Dr.
      update ttprobat
         set staupd   = 'P',
             approvno = null,
             codappr  = null,
             dteappr  = null,
             coduser  = p_coduser
      where rowid = r1.rowid;

      delete  tappbath
      where   codempid    = v_codempid
      and     dteduepr    = v_dteeffec;

      delete  tappbatg
      where   codempid    = v_codempid
      and     dteduepr    = v_dteeffec;

      delete  tappbati
      where   codempid    = v_codempid
      and     dteduepr    = v_dteeffec;

--      delete  tappbatd
--      where   codempid    = v_codempid
--      and     dteduepr    = v_dteeffec;

--      delete ttprobat where rowid = r1.rowid;
    -->>
    end loop; -- c_ttprobat
  end;
  -- end cancel_ttprobat
  procedure cancel_ttmistk(p_codempid varchar2,p_dteeffec date,p_codtrn in out varchar2,p_coduser varchar2) is
    v_exist		  boolean;
    v_codempid	  ttmistk.codempid%type;
    v_dteeffec    ttmistk.dteeffec%type;
    v_codpunsh    ttpunsh.codpunsh%type;
    v_codtrn      tcodmove.codcodec%type;
    v_numseq	  number;

--<< user20 Date: 07/09/2021  PM Module- #6140
    v_codcomp     ttpunded.codcomp%type;
    v_dteyearst   ttpunded.dteyearst%type;
    v_dtemthst    ttpunded.dtemthst%type;
    v_numprdst    ttpunded.numprdst%type;
    v_dteyearen   ttpunded.dteyearen%type;
    v_dtemthen    ttpunded.dtemthen%type;
    v_numprden    ttpunded.numprden%type;
    v_codpay       ttpunded.codpay%type;
    v_numst        number;
    v_numen       number;
    v_stdate        date ;
    v_enddate     date ;


  cursor c_ttmistk is
    select rowid ,staupd,typpayroll,codcomp --User37 STA4610099 02/05/2018
    from	  ttmistk
    where	 codempid = v_codempid
    and	 dteeffec = v_dteeffec
    and	 staupd in('C','U');

  cursor c_ttpunsh is
    select rowid,codpunsh,flgexempt,flgblist,typpun,dtestart,dteend
    from	 ttpunsh
    where	 codempid = v_codempid
    and		 dteeffec = v_dteeffec
    order by numseq;

  cursor c_ttcancel is
    select rowid
    from   ttcancel
    where  codempid = v_codempid
    and    dteeffec = v_dteeffec
    and    codtrn	  = v_codtrn
    and    numseq   = v_numseq;

  begin
    global_v_coduser  := p_coduser;
    v_codempid := p_codempid;
    v_dteeffec := p_dteeffec;
    v_codtrn   := p_codtrn;
    v_numseq	 := Get_NaxNumseq(v_codempid,v_dteeffec,v_codtrn);-- user22 : 20/11/2015 : BHI-580005 || v_numseq	 := 1;

    for r1 in c_ttmistk loop
      if r1.staupd = 'U' then
          delete thismist
          where  codempid = v_codempid
          and    dteeffec = v_dteeffec;
        for r2 in c_ttpunsh loop

          if r2.dtestart is not null then
              v_codpunsh := r2.codpunsh;
              begin
                  select codcomp, dteyearst, dtemthst, numprdst,
                         dteyearen, dtemthen, numprden, codpay
                    into v_codcomp, v_dteyearst, v_dtemthst, v_numprdst,
                         v_dteyearen, v_dtemthen, v_numprden, v_codpay
                    from ttpunded
                   where codempid = v_codempid
                     and dteeffec = v_dteeffec
                     and codpunsh = v_codpunsh;
                  ---
                  v_numst  := v_dteyearst||lpad(v_dtemthst,2,'0') ||lpad(v_numprdst,2,'0');
                  v_numen := v_dteyearen||lpad(v_dtemthen,2,'0') ||lpad(v_numprden,2,'0');
                  begin
                       select min(dtestrt) ,max(dtestrt)
                       into v_stdate ,v_enddate
                       from  tdtepay
                       where codcompy  =  hcm_util.get_codcomp_level(r1.codcomp,1)
                       and  typpayroll = r1.typpayroll
                       and  dteyrepay|| lpad(dtemthpay,2,'0') ||lpad(numperiod,2,'0')    between v_numst and v_numen ;
                  exception when others then
                       null ;
                  end ;     
                   delete tempinc t1
                   where t1.codempid = v_codempid
                     and t1.codpay   = v_codpay
                     and t1.dtestrt between v_stdate and v_enddate ;

                  begin
                      select codempid into v_codempid
                        from tempinc t1
                       where t1.codempid = v_codempid
                         and t1.codpay   = v_codpay
                         and t1.dtestrt between r2.dtestart and nvl(r2.dteend , t1.dtestrt)
                         and exists (select codempid from ttaxcur t2
                                      where t2.codempid = v_codempid
                                        and ((t2.dteyrepay*1000) + (t2.dtemthpay*100)+ t2.numperiod) between v_numst and v_numen
                                    )
                         and rownum = 1;

                            p_codtrn := 'ERR';
                            goto loop_next;
                            return;
                      exception when others then null;
                  end;
                  ---
                exception when others then null;
              end;
          end if;-- r2.typpun = '1' and r2.dtestart is not null
--<< user20 Date: 07/09/2021  PM Module- #6140 */

          v_codpunsh := r2.codpunsh;
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,v_codpunsh, 'FLGEXEMPT='''||r2.flgexempt||'''','FLGBLIST='''||r2.flgblist||'''');
          delete thispund
            where codempid = v_codempid
            and   dteeffec = v_dteeffec
            and   codpunsh = v_codpunsh;

          delete thispun
            where codempid = v_codempid
            and   dteeffec = v_dteeffec
            and   codpunsh = v_codpunsh;

--          delete  ttpunded
--            where	codempid = v_codempid
--            and		dteeffec = v_dteeffec
--            and 	codpunsh = v_codpunsh;

          delete tapmovmt
            where codapp   = 'HRPM4GE'
            and codempid = v_codempid
            and dteeffec = v_dteeffec;

          --<< delete User46 25/05/2020 Comment Dr. ttpunsh where rowid = r2.rowid;
          update ttpunsh
             set STAUPD   = 'P',
                 coduser  = p_coduser
           where rowid    = r2.rowid;

          if r2.flgexempt = 'Y' then
            delete ttexempt where codempid = v_codempid and dteeffec = v_dteeffec;
            delete ttpminf where codempid = v_codempid and dteeffec = v_dteeffec and codtrn = '0006';
          end if;
          --<<
        end loop; -- c_ttpunsh
        v_exist := false;
        for r4 in c_ttcancel loop
          v_exist := true;
          update ttcancel
            set	 coduser = p_coduser
            where rowid = r4.rowid;
        end loop;
        if not v_exist then
          insert into ttcancel
            (codempid,dteeffec,codtrn,numseq,coduser,codcreate)
          values
            (v_codempid,v_dteeffec,v_codtrn,v_numseq,p_coduser,p_coduser);
        end if;
      end if;
      --<< User46 25/05/2020 Comment Dr. delete ttmistk where rowid = r1.rowid;
      update ttmistk
         set staupd     = 'P',
             approvno   = null,
             codappr    = null,
             dteappr    = null,
             coduser    = p_coduser
       where rowid = r1.rowid;

      delete tapmovmt
       where codapp     = 'HRPM4GE'
         and codempid   = v_codempid
         and dteeffec   = v_dteeffec
         and numseq     = v_numseq;
      -->>
    end loop; -- c_ttmistk
--<< user20 Date: 07/09/2021  PM Module- #6140
    <<loop_next>>
       null;
--<< user20 Date: 07/09/2021  PM Module- #6140
  end;
  -- end cancel_ttmistk
  procedure cancel_ttexempt(p_codempid varchar2,p_dteeffec date,p_codtrn varchar2,p_coduser varchar2) is
    v_exist				boolean;
    v_codempid	  ttexempt.codempid%type;
    v_dteeffec    ttexempt.dteeffec%type;
    v_codtrn      tcodmove.codcodec%type;
    v_numseq			number;
    v_numoffid    tbcklst.numoffid%type;
    v_staemp			temploy1.staemp%type;

    b_index_staemp			temploy1.staemp%type;
    b_index_dteoccup    temploy1.dteoccup%type;

    v_dteend           date;
--<<user14||08/06/2023 16:27 redmine STT#965
  /*
  cursor c_ttexempt is
    select rowid,flgblist
           ,staupd--User37 STA4610099 02/05/2018
    from	 ttexempt
    where	 codempid = v_codempid
    and		 dteeffec = v_dteeffec
    and		 staupd in('C','U');
  */
  cursor c_ttexempt is
    select a.rowid  ,flgblist,staupd ,
              a.codempid,  a.codcomp,b.codcalen,a.codempmt,b.typpayroll, b.flgatten ,b.dteempmt
    from ttexempt a,temploy1 b
 where	 a.codempid  = b.codempid
    and   a.codempid = v_codempid
    and   a.dteeffec    = v_dteeffec
    and   a.staupd in('C','U');
--<<user14||08/06/2023 16:27 redmine STT#965


  cursor c_ttcancel is
    select rowid
    from   ttcancel
    where  codempid = v_codempid
    and    dteeffec = v_dteeffec
    and    codtrn	  = v_codtrn
    and    numseq   = v_numseq;

  begin
    global_v_coduser  := p_coduser;
    v_codempid := p_codempid;
    v_dteeffec := p_dteeffec;
    v_codtrn   := p_codtrn;
    v_numseq	 := Get_NaxNumseq(v_codempid,v_dteeffec,v_codtrn);-- user22 : 20/11/2015 : BHI-580005 || v_numseq	 := 1;
    begin
      select staemp,dteoccup
      into   b_index_staemp,b_index_dteoccup
      from   temploy1
      where  codempid = p_codempid;
    exception when others then
      null;
    end ;
    for r1 in c_ttexempt loop
      if r1.staupd = 'U' then --User37 STA4610099 02/05/2018
        delete thismove
          where  codempid = v_codempid
          and    dteeffec = v_dteeffec
          and		 codtrn		= v_codtrn;

        delete ttpminf
          where	 codempid	 = v_codempid
          and    dteeffec  = v_dteeffec
          and    codtrn		 = v_codtrn;
        if r1.flgblist = 'Y' then
          begin
            select numoffid into v_numoffid
            from	 temploy2
            where	 codempid = v_codempid;
          exception when no_data_found then
            v_numoffid := null;
          end;
          delete tbcklst where numoffid = v_numoffid;
        end if;
        if b_index_staemp = '9' then
              if b_index_dteoccup is not null then
                v_staemp := '3';
              else
                v_staemp := '1';
              end if;
              update temploy1
                set staemp 	 = v_staemp,
                    dteeffex = null,
                    coduser = p_coduser
                where codempid   =  v_codempid;
              update tusrprof
                set flgact = '1',
                    dteupd = trunc(sysdate),
                    rcupdid = p_coduser
                where codempid = v_codempid;
        end if;
        v_exist := false;
        for r4 in c_ttcancel loop
          v_exist := true;
          update ttcancel
            set	 coduser = p_coduser
            where rowid = r4.rowid;
        end loop;
        if not v_exist then
          insert into ttcancel
            (codempid,dteeffec,codtrn,numseq,coduser)
          values
            (v_codempid,v_dteeffec,v_codtrn,v_numseq,p_coduser);
        end if;
      end if;  -- if r1.staupd = 'U' then

--<<user14||08/06/2023 16:27 redmine STT#965
        begin
            select max(dtework)  into v_dteend
            from tgrpplan
            where to_char(dtework,'yyyy') = to_char(v_dteeffec,'yyyy')
            and r1.codcomp||'%' like codcomp||'%'
            and codcalen = r1.codcalen
            and dtework > v_dteeffec;
            exception when no_data_found then
               v_dteend := null;
        end;

        if v_dteend is null then
           v_dteend := to_date('31/12/'||to_char(v_dteeffec,'yyyy'),'dd/mm/yyyy');
        end if;

        hral23b_batch.create_tattence ('HRPM4JD',p_coduser,1,
                                                                  --p_dtestr,p_dteend,
                                                                  v_dteeffec , v_dteend,
                                                                  r1.codempid,
                                                                  r1.codcomp,
                                                                  r1.codcalen,
                                                                  r1.codempmt,
                                                                  r1.typpayroll,
                                                                  r1.flgatten,
                                                                  r1.dteempmt,
                                                                  null);
                                                                  --i.dteeffex);

-->>user14||08/06/2023 16:27 redmine STT#965

      --<< User46 25/05/2020 Comment Dr. delete ttexempt where rowid = r1.rowid;
      update ttexempt
         set staupd     = 'P',
             approvno   = null,
             codappr    = null,
             dteappr    = null,
             coduser    = p_coduser
       where rowid      = r1.rowid;

      delete tapmovmt
       where codapp   = 'HRPM4IE'
         and codempid = v_codempid
         and dteeffec = v_dteeffec;
      --<<

    end loop; -- c_ttexempt
  end;
  -- end cancel_ttexempt
  procedure cancel_ttmovemt(p_codempid varchar2,p_dteeffec date,p_codtrn varchar2,p_numseq number,p_coduser varchar2) is
    v_exist				boolean;
    v_codempid	  ttmovemt.codempid%type;
    v_dteeffec    ttmovemt.dteeffec%type;
    v_codtrn      tcodmove.codcodec%type;
    v_numseq			number;
    v_numoffid    tbcklst.numoffid%type;
    v_staemp			temploy1.staemp%type;
    v_amtincom1		number;
    v_amtincom2		number;
    v_amtincom3		number;
    v_amtincom4		number;
    v_amtincom5		number;
    v_amtincom6		number;
    v_amtincom7		number;
    v_amtincom8		number;
    v_amtincom9		number;
    v_amtincom10	number;
    v_amtothr			number;
    v_amtday			number;
    v_amtmth			number;

    v_secur       number:=0;

  cursor c_ttmovemt is
    select rowid,codcompt,codcomp,codposnow,codpos,codjobt,codjob,
           numlvlt,numlvl,codbrlct,codbrlc,codcalet,codcalen,
           flgattet,flgatten,codempmtt,codempmt,typpayrolt,typpayroll,
           typempt,typemp,flgadjin,codtrn,stapost2,staupd,
           amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
           amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
           amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,
           amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,
           codgrpglt,dteefpos,dteeflvl,dteefstep,
           jobgrade,jobgradet
    from	 ttmovemt
    where	 codempid = v_codempid
    and		 dteeffec = v_dteeffec
    and    numseq   = v_numseq
    and		 staupd in('C','U');
  cursor c_ttcancel is
    select rowid
    from   ttcancel
    where  codempid = v_codempid
    and    dteeffec = v_dteeffec
    and    codtrn	  = v_codtrn
    and    numseq   = v_numseq;
  begin
    global_v_coduser  := p_coduser;
    v_codempid := p_codempid;
    v_dteeffec := p_dteeffec;
    v_codtrn   := p_codtrn;
    v_numseq	 := p_numseq;
    for r1 in c_ttmovemt loop
      if r1.staupd = 'U' then --User37 STA4610099 02/05/2018
        if r1.codtrn = '0007' then  -- Cancel Concurrent Position Update TSECPOS
          update tsecpos
            set dtecancel = null, seqcancel = 0,coduser = p_coduser
            where codempid  = v_codempid
            and 	dtecancel = v_dteeffec;
    --				and 	seqcancel = v_numseq;
        else
          if r1.stapost2 <> '0' then  -- Promotion delete TSECPOS
            delete tsecpos
              where codempid  = v_codempid
              and 	dteeffec  = v_dteeffec;
    --					and 	numseq    = v_numseq;
          end if;  --if i.stapost2 <> '0'
        end if;

        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'CODCOMP',r1.codcompt,r1.codcomp);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'CODPOS',r1.codposnow,r1.codpos);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'CODJOB',r1.codjobt,r1.codjob);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'NUMLVL',r1.numlvlt,r1.numlvl);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'CODBRLC',r1.codbrlct,r1.codbrlc);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'CODCALEN',r1.codcalet,r1.codcalen);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'FLGATTEN',r1.flgattet,r1.flgatten);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'CODEMPMT',r1.codempmtt,r1.codempmt);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'TYPPAYROLL',r1.typpayrolt,r1.typpayroll);
        upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'TYPEMP',r1.typempt,r1.typemp);
        if r1.flgadjin = 'Y' then
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM1',r1.amtincom1,r1.amtincadj1);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM2',r1.amtincom2,r1.amtincadj2);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM3',r1.amtincom3,r1.amtincadj3);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM4',r1.amtincom4,r1.amtincadj4);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM5',r1.amtincom5,r1.amtincadj5);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM6',r1.amtincom6,r1.amtincadj6);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM7',r1.amtincom7,r1.amtincadj7);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM8',r1.amtincom8,r1.amtincadj8);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM9',r1.amtincom9,r1.amtincadj9);
          upd_ttcanceld(v_codempid,v_dteeffec,v_codtrn,v_numseq,'AMTINCOM10',r1.amtincom10,r1.amtincadj10);
          begin
            select stddec(amtincom1,codempid,global_v_chken),
                   stddec(amtincom2,codempid,global_v_chken),
                   stddec(amtincom3,codempid,global_v_chken),
                   stddec(amtincom4,codempid,global_v_chken),
                   stddec(amtincom5,codempid,global_v_chken),
                   stddec(amtincom6,codempid,global_v_chken),
                   stddec(amtincom7,codempid,global_v_chken),
                   stddec(amtincom8,codempid,global_v_chken),
                   stddec(amtincom9,codempid,global_v_chken),
                   stddec(amtincom10,codempid,global_v_chken)
            into 	 v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
                   v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
            from	 temploy3
            where	 codempid = v_codempid;
          exception when no_data_found then
            v_amtincom1 := 0; v_amtincom2 := 0; v_amtincom3 := 0; v_amtincom4 := 0; v_amtincom5 := 0;
            v_amtincom6 := 0; v_amtincom7 := 0; v_amtincom8 := 0; v_amtincom9 := 0; v_amtincom10 := 0;
          end;
          v_amtincom1 := nvl(v_amtincom1,0) - stddec(r1.amtincadj1,v_codempid,global_v_chken);
          v_amtincom2 := nvl(v_amtincom2,0) - stddec(r1.amtincadj2,v_codempid,global_v_chken);
          v_amtincom3 := nvl(v_amtincom3,0) - stddec(r1.amtincadj3,v_codempid,global_v_chken);
          v_amtincom4 := nvl(v_amtincom4,0) - stddec(r1.amtincadj4,v_codempid,global_v_chken);
          v_amtincom5 := nvl(v_amtincom5,0) - stddec(r1.amtincadj5,v_codempid,global_v_chken);
          v_amtincom6 := nvl(v_amtincom6,0) - stddec(r1.amtincadj6,v_codempid,global_v_chken);
          v_amtincom7 := nvl(v_amtincom7,0) - stddec(r1.amtincadj7,v_codempid,global_v_chken);
          v_amtincom8 := nvl(v_amtincom8,0) - stddec(r1.amtincadj8,v_codempid,global_v_chken);
          v_amtincom9 := nvl(v_amtincom9,0) - stddec(r1.amtincadj9,v_codempid,global_v_chken);
          v_amtincom10 := nvl(v_amtincom10,0) - stddec(r1.amtincadj10,v_codempid,global_v_chken);
          get_wage_income(hcm_util.get_codcomp_level(r1.codcomp,'1'),r1.codempmt,
                           nvl(v_amtincom1,0), nvl(v_amtincom2,0),
                           nvl(v_amtincom3,0), nvl(v_amtincom4,0),
                           nvl(v_amtincom5,0), nvl(v_amtincom6,0),
                           nvl(v_amtincom7,0), nvl(v_amtincom8,0),
                           nvl(v_amtincom9,0), nvl(v_amtincom10,0),
                           v_amtothr,v_amtday,v_amtmth);
          update temploy3
            set amtincom1  = stdenc(v_amtincom1,codempid,global_v_chken),
                amtincom2  = stdenc(v_amtincom2,codempid,global_v_chken),
                amtincom3  = stdenc(v_amtincom3,codempid,global_v_chken),
                amtincom4  = stdenc(v_amtincom4,codempid,global_v_chken),
                amtincom5  = stdenc(v_amtincom5,codempid,global_v_chken),
                amtincom6  = stdenc(v_amtincom6,codempid,global_v_chken),
                amtincom7  = stdenc(v_amtincom7,codempid,global_v_chken),
                amtincom8  = stdenc(v_amtincom8,codempid,global_v_chken),
                amtincom9  = stdenc(v_amtincom9,codempid,global_v_chken),
                amtincom10 = stdenc(v_amtincom10,codempid,global_v_chken),
                amtothr    = stdenc(v_amtothr,codempid,global_v_chken),
                amtday		 = stdenc(v_amtday,codempid,global_v_chken),
                coduser = p_coduser
            where	codempid = v_codempid;
          delete tfincadj
            where  codempid = v_codempid
            and    dteeffec = v_dteeffec;
        end if; -- flgadjin
        if r1.stapost2 = '0' and r1.staupd = 'U' then
          update temploy1
            set codcomp    = r1.codcompt,		codpos     = r1.codposnow,
                codjob     = r1.codjobt,		numlvl     = r1.numlvlt,
                codbrlc    = r1.codbrlct,		flgatten   = r1.flgattet,
                codcalen   = r1.codcalet,		typpayroll = r1.typpayrolt,
                codempmt   = r1.codempmtt,	typemp     = r1.typempt,
                codgrpgl	 = r1.codgrpglt,	dteefpos	 = r1.dteefpos,
                dteeflvl	 = r1.dteeflvl,	dteefstep = r1.dteefstep,-- user36 07/03/2015 add save ttmovemt.dteefpos,dteeflvl,dteefstep & codgrpgl
                coduser    = p_coduser
            where	codempid = v_codempid;
        end if;
        delete thismove
          where  codempid = v_codempid
          and    dteeffec = v_dteeffec
          and		 codtrn		= v_codtrn;
        delete ttpminf
          where	 codempid	 = v_codempid
          and    dteeffec  = v_dteeffec
          and    codtrn		 = v_codtrn;
        v_exist := false;
        for r4 in c_ttcancel loop
          v_exist := true;
          update ttcancel
            set	 coduser = p_coduser
            where rowid = r4.rowid;
        end loop;
        if not v_exist then
          insert into ttcancel
            (codempid,dteeffec,codtrn,numseq,coduser,codcreate)
          values
            (v_codempid,v_dteeffec,v_codtrn,v_numseq,p_coduser,p_coduser);
        end if;

--<<redmine 5479 ST11
--        if (r1.codpos <> r1.codposnow) or  (r1.codcompt <> r1.codcomp)   or (r1.numlvl <> r1.numlvlt) or (r1.jobgrade <> r1.jobgradet) or
--           (r1.typemp <> r1.typempt)   or  (r1.codempmt <> r1.codempmtt) or (r1.codjob <> r1.codjobt) then
--       if (r1.codcompt <> r1.codcomp) or (r1.numlvl <> r1.numlvlt)  then
--           hrpm91b_batch.change_userprofile( p_codempid  => v_codempid,
--                                                           p_codcomp  => r1.codcompt,--codcompold
--                                                           p_codpos    => r1.codposnow,
--                                                           p_numlvl     => r1.numlvlt,
--                                                           p_jobgrade  => r1.jobgradet,
--                                                           p_typemp   => r1.typempt,
--                                                           p_codempmt  => r1.codempmtt,
--                                                           p_codjob   => r1.codjobt,
--                                                           p_codcompt  => r1.codcomp, --codcompnew
--                                                           p_coduser   => p_coduser ,
--                                                           p_secur     => v_secur  );
--
--        end if;
        if (r1.jobgrade <> r1.jobgradet) or (r1.codcompt <> r1.codcomp) or
             (r1.codpos <> r1.codposnow) or (r1.codjob <> r1.codjobt) or
             (r1.numlvl <> r1.numlvlt) or (r1.codempmt <> r1.codempmtt) or
             (r1.typemp <> r1.typempt) then
            hrpm91b_batch.global_v_coduser := p_coduser;
            hrpm91b_batch.ins_tusrprof(v_codempid);
        end if;
-->>redmine 5479 ST11

        recal_movement(v_codempid,v_dteeffec,v_numseq);
      end if;
      --<< User46 25/05/2020 Comment Dr.delete ttmovemt where rowid = r1.rowid;
      update ttmovemt
         set staupd     = 'P',
             approvno   = null,
             codappr    = null,
             dteappr    = null,
             coduser    = p_coduser
       where rowid      = r1.rowid;

      delete tapmovmt
       where codapp   = 'HRPM4DE'
         and codempid = v_codempid
         and dteeffec = v_dteeffec;
    end loop; -- c_ttmovemt
  end;
  -- end cancel_ttmovemt
end HRPM4JD_batch;

/

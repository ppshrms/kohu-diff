--------------------------------------------------------
--  DDL for Package Body HRCO04E_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO04E_BATCH" is
	procedure start_process is
		v_flgact			varchar2(20);

    cursor c_tcenterlog is
      select rowid,codcomp,namcente,namcentt,namcent3,namcent4,namcent5,
             codcom1,codcom2,codcom3,codcom4,codcom5,codcom6,codcom7,codcom8,codcom9,codcom10,codcompy,comlevel,
             naminit3,naminit4,naminit5,naminite,naminitt,
             flgact,codproft,costcent,compgrp,codposr,coduser
        from tcenterlog
       where dteeffec <= trunc(sysdate)
         and nvl(flgcal,'N') = 'N'
    order by codcomp,dteeffec;
	begin
    for i in c_tcenterlog loop
      if i.flgact in (1,3) then
        v_flgact := 1;
      else
        v_flgact := 2;
      end if;

      begin
        insert into tcenter(codcomp,namcente,namcentt,namcent3,namcent4,namcent5,
                            codcom1,codcom2,codcom3,codcom4,codcom5,codcom6,codcom7,codcom8,codcom9,codcom10,codcompy,comlevel,
                            naminit3,naminit4,naminit5,naminite,naminitt,
                            flgact,codproft,costcent,compgrp,codposr,
                            coduser,codcreate
                            )
                    values (i.codcomp,i.namcente,i.namcentt,i.namcent3,i.namcent4,i.namcent5,
                            i.codcom1,i.codcom2,i.codcom3,i.codcom4,i.codcom5,i.codcom6,i.codcom7,i.codcom8,i.codcom9,i.codcom10,i.codcompy,i.comlevel,
                            i.naminit3,i.naminit4,i.naminit5,i.naminite,i.naminitt,
                            v_flgact,i.codproft,i.costcent,i.compgrp,i.codposr,
                            i.coduser,i.coduser);
      exception when dup_val_on_index then
         update tcenter
            set namcente	= i.namcente,
                namcentt	= i.namcentt,
                namcent3	= i.namcent3,
                namcent4	= i.namcent4,
                namcent5	= i.namcent5,
                codcom1		= i.codcom1,
                codcom2		= i.codcom2,
                codcom3		= i.codcom3,
                codcom4		= i.codcom4,
                codcom5		= i.codcom5,
                codcom6		= i.codcom6,
                codcom7		= i.codcom7,
                codcom8		= i.codcom8,
                codcom9		= i.codcom9,
                codcom10	= i.codcom10,
                codcompy	= i.codcompy,
                comlevel	= i.comlevel,
                naminit3	= i.naminit3,
                naminit4	= i.naminit4,
                naminit5	= i.naminit5,
                naminite	= i.naminite,
                naminitt	= i.naminitt,
                flgact		= v_flgact,
                codproft	= i.codproft,
                costcent	= i.costcent,
                compgrp		= i.compgrp,
                codposr		= i.codposr,
                dteupd    = sysdate,
                coduser   = i.coduser
          where codcomp   = i.codcomp;
      end;
      --
      update tcenterlog
         set flgcal  = 'Y',
             dteupd  = trunc(sysdate)
       where rowid = i.rowid;
    end loop;
		commit;
	end;
end hrco04e_batch;

/

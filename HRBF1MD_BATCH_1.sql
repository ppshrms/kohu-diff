--------------------------------------------------------
--  DDL for Package Body HRBF1MD_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1MD_BATCH" is
  procedure cancle_tclnsinf(p_numvcher varchar2,p_dtecancl date, p_codcancl varchar2, p_descancl varchar2, p_coduser varchar2) is
    v_codempid     taccmexp.codempid%type;
    v_dteyre       taccmexp.dteyre%type;
    v_dtemonth     taccmexp.dtemonth%type;
    v_typamt       taccmexp.typamt%type;
    v_typrelate    taccmexp.typrelate%type;
    v_amtsumin     taccmexp.amtsumin%type;
    v_qtysumin     taccmexp.qtysumin%type;
    v_amtsumino    taccmexp.amtsumin%type;
    v_qtysumino    taccmexp.qtysumin%type;

    cursor c1_tclnsinf is
      select numvcher,codempid,codcomp,codpos,typpayroll,
             dtereq,namsick,codrel,codcln,coddc,typpatient,typamt,
             dtecrest,dtecreen,qtydcare,dtebill,flgdocmt,
             amtexp,amtalw,amtovrpay,amtavai,amtemp,amtpaid,
             dteappr,codappr,typpay,dtecash,dteyrepay,
             dtemthpay,numperiod,flgupd,flgtranpy,numpaymt,
             codpaymtap,dtepaymtap,qtyrepaym,amtrepaym,
             periodpayst,staappov,codappov,dteappov,remarkap,dtetranpy,approvno,amtappr
        from tclnsinf
       where numvcher   = p_numvcher;

    cursor c2_tclnsinff is
      select numvcher,numseq,filename,descfile
        from tclnsinff
       where numvcher   = p_numvcher
    order by numseq;

    cursor c3_taccmexp is
      select codempid,dteyre,dtemonth,typamt,typrelate,amtsumin,qtysumin,rowid
        from taccmexp
       where codempid  = v_codempid
         and dteyre    = v_dteyre
         and dtemonth  = v_dtemonth
         and typamt    = v_typamt
         and typrelate = v_typrelate;

  begin
    --1 insert TCLNSLOG , TCLNSLOGF
    for r1 in c1_tclnsinf loop
      begin
        insert into tclnslog(numvcher,codempid,codcomp,codpos,typpayroll,
                             dtereq,namsick,codrel,codcln,coddc,typpatient,typamt,
                             dtecrest,dtecreen,qtydcare,dtebill,flgdocmt,
                             amtexp,amtalw,amtovrpay,amtavai,amtemp,amtpaid,
                             dteappr,codappr,typpay,dtecash,dteyrepay,
                             dtemthpay,numperiod,flgupd,flgtranpy,numpaymt,
                             codpaymtap,dtepaymtap,qtyrepaym,amtrepaym,
                             periodpayst,staappov,codappov,dteappov,remarkap,dtetranpy,approvno,amtappr,
                             dtecancl,codcancl,descancl,
                             dtecreate,codcreate,dteupd,coduser)
                      values(r1.numvcher,r1.codempid,r1.codcomp,r1.codpos,r1.typpayroll,
                             r1.dtereq,r1.namsick,r1.codrel,r1.codcln,r1.coddc,r1.typpatient,r1.typamt,
                             r1.dtecrest,r1.dtecreen,r1.qtydcare,r1.dtebill,r1.flgdocmt,
                             r1.amtexp,r1.amtalw,r1.amtovrpay,r1.amtavai,r1.amtemp,r1.amtpaid,
                             r1.dteappr,r1.codappr,r1.typpay,r1.dtecash,r1.dteyrepay,
                             r1.dtemthpay,r1.numperiod,r1.flgupd,r1.flgtranpy,r1.numpaymt,
                             r1.codpaymtap,r1.dtepaymtap,r1.qtyrepaym,r1.amtrepaym,
                             r1.periodpayst,r1.staappov,r1.codappov,r1.dteappov,r1.remarkap,r1.dtetranpy,r1.approvno,r1.amtappr,
                             p_dtecancl,p_codcancl,p_descancl,
                             sysdate,p_coduser,sysdate,p_coduser);
      exception when dup_val_on_index then null;
      end;
    end loop;  -- c1_tclnsinf

    for r2 in c2_tclnsinff loop
      begin
        insert into tclnslogf(numvcher,numseq,filename,descfile,
                              dtecreate,codcreate,dteupd,coduser)
                       values(r2.numvcher,r2.numseq,r2.filename,r2.descfile ,
                              sysdate,p_coduser,sysdate,p_coduser);
      exception when dup_val_on_index then null;
      end;
    end loop;  -- c2_tclnsinff

    --2 update TACCMEXP if 0 delete TACCMEXP, TACCMLOG
    for r1 in c1_tclnsinf loop
      v_codempid  := r1.codempid;
      v_dteyre    := to_number(to_char(r1.dtereq,'yyyy'));
      v_dtemonth  := to_number(to_char(r1.dtereq,'mm'));
      v_typamt    := r1.typamt;
      v_typrelate := r1.codrel;
      for r3 in c3_taccmexp loop
        v_amtsumino  := nvl(r3.amtsumin,0);
        v_amtsumin   := greatest((nvl(r3.amtsumin,0) - nvl(r1.amtalw,0)),0);
        v_qtysumino  := nvl(r3.qtysumin,0);
        v_qtysumin   := greatest((nvl(r3.qtysumin,0) - 1),0);
        if v_amtsumin = 0 and v_qtysumin = 0 then
          delete taccmexp
           where rowid = r3.rowid;
        else
          begin
            update taccmexp
               set amtsumin  = v_amtsumin,
                   qtysumin  = v_qtysumin,
                   dteupd    = sysdate,
                   coduser   = p_coduser
             where rowid     = r3.rowid;
          end;
        end if;
        if nvl(v_amtsumino,-99999999999) <> nvl(v_amtsumin,-99999999999) then
          begin
            insert into taccmlog(codempid,dteyre,dtemonth,typamt,typrelate,dteedit,fldedit,
                                 desold,desnew,
                                 dtecreate,codcreate,dteupd,coduser)
                          values(r3.codempid,r3.dteyre,r3.dtemonth,r3.typamt,r3.typrelate,sysdate,'AMTSUMIN',
                                 v_amtsumino,v_amtsumin,
                                 sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then null;
          end;
        end if;
        if nvl(v_qtysumino,-99999999999) <> nvl(v_qtysumin,-99999999999) then
          begin
            insert into taccmlog(codempid,dteyre,dtemonth,typamt,typrelate,dteedit,fldedit,
                                 desold,desnew,
                                 dtecreate,codcreate,dteupd,coduser)
                          values(r3.codempid,r3.dteyre,r3.dtemonth,r3.typamt,r3.typrelate,sysdate,'QTYSUMIN',
                                 v_qtysumino,v_qtysumin,
                                 sysdate,p_coduser,sysdate,p_coduser);
          exception when dup_val_on_index then null;
          end;
        end if;

        -- update month 13 (Total)
        begin
          update taccmexp
             set amtsumin  = greatest((nvl(amtsumin,0) - nvl(r1.amtalw,0)),0),
                 qtysumin  = greatest((nvl(qtysumin,0) - 1),0),
                 dteupd    = sysdate,
                 coduser   = p_coduser
           where codempid  = r3.codempid
             and dteyre    = r3.dteyre
             and dtemonth  = 13
             and typamt    = r3.typamt
             and typrelate = r3.typrelate;
        end;
      end loop;  -- c3_taccmexp
    end loop;  -- c1_tclnsinf

    --3 delete TCLNSINF, TCLNSINF
    delete tclnsinf where numvcher = p_numvcher;
    delete tclnsinff where numvcher = p_numvcher;
    commit;
  end;
end;


/

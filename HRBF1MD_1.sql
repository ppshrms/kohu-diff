--------------------------------------------------------
--  DDL for Package Body HRBF1MD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1MD" is
-- last update: 17/11/2022 17:01 ||redmine-8653 

  procedure initial_value(json_str in clob) is
    json_obj                json_object_t;
  begin
    v_chken                 := hcm_secur.get_v_chken;
    json_obj                := json_object_t(json_str);
    --global
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp               := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid_query        := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtestr                := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
    p_dteend                := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');
    p_numvcher              := hcm_util.get_string_t(json_obj,'p_numvcher');
    p_dtecancl              := to_date(hcm_util.get_string_t(json_obj,'p_dtecancl'),'dd/mm/yyyy');
    p_descancl              := hcm_util.get_string_t(json_obj,'p_descancl');
    p_codcancl              := hcm_util.get_string_t(json_obj,'p_codcancl');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    flgpass     	boolean;

    /*cursor c1 is
        select codempid, dtereq, numvcher, amtalw, flgtranpy, numpaymt, staappov, amtovrpay, flgupd, dtecash
          from tclnsinf
         where codcomp like p_codcomp||'%'
           and codempid = nvl(p_codempid_query, codempid  )
           and dtereq  between p_dtestr   and p_dteend
           and  ( flgtranpy = 'N'
            or  (staappov = 'P' )
            or  (numpaymt is not null and dtecash > sysdate) )
      order by codempid, dteupd;*/

      cursor c1 is
        select codempid, dtereq, numvcher, amtalw, flgtranpy, numpaymt, staappov, amtovrpay, flgupd, dtecash
          from tclnsinf
         where codcomp like p_codcomp||'%'
           and codempid = nvl(p_codempid_query, codempid  )
           and dtereq  between p_dtestr   and p_dteend
--<<user14||17/11/2022 ||redmine-8653           
           and (   (flgtranpy = 'N' and staappov = 'P' )  or  (numpaymt is not null and dtecash > sysdate) )
-->>user14||17/11/2022 ||redmine-8653          
      order by codempid, dteupd; 

  begin

    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
            obj_data.put('numvcher',i.numvcher);
            obj_data.put('amtalw',i.amtalw);

            if i.numpaymt is not null then
                --if trunc(i.dtecash) <= trunc(sysdate) then
                --    obj_data.put('status',get_label_name('HRBF1MD3', global_v_lang, 50));
                --else
                    obj_data.put('status',get_label_name('HRBF1MD3', global_v_lang, 20));
                --end if;
            elsif i.staappov = 'P'  then
                obj_data.put('status',get_label_name('HRBF1MD3', global_v_lang, 70));
            elsif i.staappov = 'Y'  then
                obj_data.put('status',get_label_name('HRBF1MD3', global_v_lang, 60));
/*
            elsif i.flgtranpy = 'Y' then
                obj_data.put('status',get_label_name('HRBF1MD3', global_v_lang, 10));
            elsif i.staappov = 'Y' and i.amtovrpay > 0 then
                obj_data.put('status',get_label_name('HRBF1MD3', global_v_lang, 30));
            elsif i.flgupd = 'Y' then
                obj_data.put('status',get_label_name('HRBF1MD3', global_v_lang, 40));
*/
            end if;
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TCLNSINF');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;  -- procedure gen_index

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    flgpass     	boolean;

    cursor c1 is
        select *
          from tclnsinf
         where numvcher = p_numvcher;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');

            obj_data.put('codempid',i.codempid);
            obj_data.put('numvcher',i.numvcher);
            obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
            obj_data.put('dteappov',to_char(i.dteappov,'dd/mm/yyyy'));
            obj_data.put('codappov',i.codappov);
            obj_data.put('amtalw',i.amtalw);
            obj_data.put('staappov',i.staappov);
            /*if i.flgtranpy = 'Y' then
                obj_data.put('desc_staappov',get_label_name('HRBF1MD3', global_v_lang, 10));
            els*/
            if i.numpaymt is not null then
                obj_data.put('desc_staappov',get_label_name('HRBF1MD3', global_v_lang, 20));
            elsif i.staappov = 'P'  then ----
                obj_data.put('desc_staappov',get_label_name('HRBF1MD3', global_v_lang, 70));
            elsif i.staappov = 'Y'  then ----
                obj_data.put('desc_staappov',get_label_name('HRBF1MD3', global_v_lang, 60));
            /*elsif i.staappov = 'Y' and i.amtovrpay > 0 then
                obj_data.put('desc_staappov',get_label_name('HRBF1MD3', global_v_lang, 30));
            elsif i.flgupd = 'Y' then
                obj_data.put('desc_staappov',get_label_name('HRBF1MD3', global_v_lang, 40));*/
            end if;
            obj_data.put('dtecancl',to_char(sysdate,'dd/mm/yyyy'));
--            obj_data.put('dtecancl','');
            obj_data.put('codcancl',global_v_codempid);
            obj_data.put('descancl','');
            if ( i.flgtranpy = 'N'
                 or (i.staappov = 'P' )
                 or (i.numpaymt is not null and i.dtecash > sysdate)) then
                obj_data.put('flgcancel','Y');
            else
                obj_data.put('flgcancel','N');
            end if;
        end if;
    end loop;
    json_str_output := obj_data.to_clob;
  end;  -- procedure gen_index



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

   procedure post_detailsave(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        cancle_tclnsinf(p_numvcher,p_dtecancl, p_codcancl, p_descancl,global_v_coduser);
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

end;

/

--------------------------------------------------------
--  DDL for Package Body HRPY29E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY29E" is

  procedure update_tothinc(v_codempid  varchar2,
                           v_numperiod number  ,
                           v_month     number  ,
                           v_year      number  ,
                           v_codpay    varchar2) as
    v_qtypayda    number;
    v_qtypayhr    number;
    v_qtypaysc    number;
    v_amtpay      number;

    v_codcomp     tothinc.codcomp%type;
    v_typpayroll  tothinc.typpayroll%type;
    v_typemp      tothinc.typemp%type;
    v_ratepay     tothinc.ratepay%type;
    v_codsys      tothinc.codsys%type    := 'PY';
    v_costcent    tothinc.costcent%type;
    v_dtecreate   tothinc.dtecreate%type := sysdate;
    v_codcreate   tothinc.codcreate%type := global_v_coduser;
    v_dteupd      tothinc.dteupd%type    := sysdate;
    v_coduser     tothinc.coduser%type   := global_v_coduser;
  begin
    global_v_chken      := hcm_secur.get_v_chken;
    begin
      select sum(nvl(qtypayda,0)),
             sum(nvl(qtypayhr,0)),
             sum(nvl(qtypaysc,0)),
             sum(nvl(stddec(amtpay,codempid,global_v_chken),0))
        into v_qtypayda   ,v_qtypayhr   ,
             v_qtypaysc   ,v_amtpay
        from tothinc2
       where codempid  = v_codempid
         and dteyrepay = v_year
         and dtemthpay = v_month
         and numperiod = v_numperiod
         and codpay    = v_codpay;

      begin
        select a.codcomp,a.typpayroll,
               a.typemp ,b.amtday    ,
               c.costcent
          into v_codcomp,v_typpayroll,
               v_typemp ,v_ratepay   ,
               v_costcent
          from temploy1 a,temploy3 b,tcenter c
         where a.codempid = b.codempid
           and a.codcomp  = c.codcomp
           and a.codempid = v_codempid;
        begin
          insert into tothinc (codempid  ,dteyrepay,dtemthpay,
                               numperiod ,codpay   ,codcomp  ,
                               typpayroll,typemp   ,qtypayda ,
                               qtypayhr  ,qtypaysc ,ratepay  ,
                               amtpay    ,codsys   ,costcent ,
                               dtecreate ,codcreate,dteupd   ,
                               coduser)
                       values (v_codempid  ,v_year     ,v_month    ,
                               v_numperiod ,v_codpay   ,v_codcomp  ,
                               v_typpayroll,v_typemp   ,v_qtypayda ,
                               v_qtypayhr  ,v_qtypaysc ,v_ratepay  ,
                               stdenc(v_amtpay,v_codempid,global_v_chken)    ,v_codsys   ,v_costcent ,
                               v_dtecreate ,v_codcreate,v_dteupd   ,
                               v_coduser);
        exception when dup_val_on_index then
          update tothinc
             set codcomp    = v_codcomp,
                 typpayroll = v_typpayroll,
                 typemp     = v_typemp,
                 qtypayda   = v_qtypayda,
                 qtypayhr   = v_qtypayhr,
                 qtypaysc   = v_qtypaysc,
                 ratepay    = v_ratepay,
                 amtpay     = stdenc(v_amtpay,v_codempid,global_v_chken),
                 costcent   = v_costcent,
                 dteupd     = v_dteupd,
                 coduser    = v_coduser
           where codempid   = v_codempid
             and dteyrepay  = v_year
             and dtemthpay  = v_month
             and numperiod  = v_numperiod
             and codpay     = v_codpay;
        end;
      exception when no_data_found then
        null;
      end;
    exception when no_data_found then
      delete tothinc
       where codempid  = v_codempid
         and dteyrepay = v_year
         and dtemthpay = v_month
         and numperiod = v_numperiod
         and codpay    = v_codpay;
    end;
  end;


  procedure add_tlogothinc (v_numseq   number  ,v_codempid varchar2,v_codcomp varchar2,
                            v_desfld   varchar2,v_desold   varchar2,v_desnew  varchar2) as
  begin
    if nvl(v_desold,'#$%^#$%^') <> nvl(v_desnew,'#$%^#$%^') then
         begin
            insert into tlogothinc (dteupd     ,numseq     ,codempid   ,
                                    dteyrepay  ,dtemthpay  ,numperiod  ,
                                    codpay     ,codcomp    ,
                                    desfld     ,desold     ,desnew     ,
                                    dtecreate  ,codcreate  ,coduser    )
                            values (sysdate    ,v_numseq   ,v_codempid ,
                                    p_year     ,p_month    ,p_numperiod,
                                    p_codpay   ,v_codcomp  ,
                                    v_desfld   ,v_desold   ,v_desnew   ,
                                    sysdate    ,global_v_coduser,
                                    global_v_coduser);
              exception when dup_val_on_index then
                update tlogothinc
                   set codcomp = v_codcomp,
                       desfld  = v_desfld ,
                       desold  = v_desold ,
                       desnew  = v_desnew ,
                       coduser = global_v_coduser
                 where dteupd    = sysdate
                   and numseq    = v_numseq
                   and codempid  = v_codempid
                   and dteyrepay = p_year
                   and dtemthpay = p_month
                   and numperiod = p_numperiod
                   and codpay    = p_codpay;
        end;
    end if;
  end;
  procedure add_tlogothpay (v_numseq   number  ,v_codempid varchar2,v_codcomp varchar2,
                            v_desfld   varchar2,v_desold   varchar2,v_desnew  varchar2,
                            v_dtepay   date) as
  begin
   if nvl(v_desold,'#$%^#$%^') <> nvl(v_desnew,'#$%^#$%^') then
        begin
            insert into tlogothpay (dteupd     ,numseq     ,codempid   ,
                                    dteyrepay  ,dtemthpay  ,numperiod  ,
                                    codpay     ,codcomp    ,dtepay     ,
                                    desfld     ,desold     ,desnew     ,
                                    dtecreate  ,codcreate  ,coduser    )
                            values (sysdate    ,v_numseq   ,v_codempid ,
                                    p_year     ,p_month    ,p_numperiod,
                                    p_codpay   ,v_codcomp  ,v_dtepay   ,
                                    v_desfld   ,v_desold   ,v_desnew   ,
                                    sysdate    ,global_v_coduser,
                                    global_v_coduser);
          exception when dup_val_on_index then
            update tlogothpay
               set codcomp = v_codcomp,
                   desfld  = v_desfld ,
                   desold  = v_desold ,
                   desnew  = v_desnew ,
                   coduser = global_v_coduser
             where dteupd    = sysdate
               and numseq    = v_numseq
               and codempid  = v_codempid
               and dteyrepay = p_year
               and dtemthpay = p_month
               and numperiod = p_numperiod
               and codpay    = p_codpay
               and dtepay    = v_dtepay;
        end;
     end if;
  end;

--  procedure add_tothinc2 (v_codcompw varchar2, v_codempid varchar2,
  procedure add_tothinc2 (v_codcompw varchar2, v_codempid varchar2, v_codcomp2 varchar2,
--904
                          v_qtypayda number  , v_qtypayhr number  ,
                          v_qtypaysc number  , v_amtpay   number  ) as
    v_costcent tcenter.costcent%type;
    v_codcomp  tcenter.codcomp%type;
    v_codsys tothinc2.codsys%type    := 'PY';
  begin
    begin
      select costcent into v_costcent
        from tcenter
       where codcomp = v_codcompw;
    exception when no_data_found then
      v_costcent := null;
    end;
    insert into tothinc2 (codempid  ,dteyrepay,dtemthpay,
                          numperiod ,codpay   ,codcompw ,
                          qtypayda  ,qtypayhr ,qtypaysc ,
                          amtpay    ,costcent , codsys,
                          dtecreate ,codcreate,
                          dteupd    ,coduser  )
                  values (v_codempid ,p_year    ,p_month   ,
                          p_numperiod,p_codpay  ,v_codcompw,
                          v_qtypayda ,v_qtypayhr,v_qtypaysc,
                          stdenc(v_amtpay,v_codempid,global_v_chken),
                          v_costcent , v_codsys,
                          sysdate    ,global_v_coduser,
                          sysdate    ,global_v_coduser);

--904
    v_codcomp := v_codcomp2;
    if v_codcomp2 is null then
--904
        begin
          select codcomp into v_codcomp
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then
          v_codcomp := null;
        end;
--904
    end if;
--904
    add_tlogothinc (1,v_codempid,v_codcomp,'CODCOMPW',null,v_codcompw);
    add_tlogothinc (2,v_codempid,v_codcomp,'QTYPAYDA',null,v_qtypayda);
    add_tlogothinc (3,v_codempid,v_codcomp,'QTYPAYHR',null,v_qtypayhr);
    add_tlogothinc (4,v_codempid,v_codcomp,'QTYPAYSC',null,v_qtypaysc);
    add_tlogothinc (5,v_codempid,v_codcomp,'AMTPAY'  ,null,stdenc(v_amtpay,v_codempid,global_v_chken));
  exception when dup_val_on_index then
--904    edit_tothinc2 (v_codcompw,v_codempid,
    edit_tothinc2 (v_codcompw,v_codempid,v_codcomp2,
--904
                   v_qtypayda,v_qtypayhr,
                   v_qtypaysc,v_amtpay);
  end;

--904  procedure edit_tothinc2 (v_codcompw varchar2, v_codempid varchar2,
  procedure edit_tothinc2 (v_codcompw varchar2, v_codempid varchar2, v_codcomp2 varchar2,
--904
                           v_qtypayda number  , v_qtypayhr number  ,
                           v_qtypaysc number  , v_amtpay   number  ) as
    v_costcent     tcenter.costcent%type;
    v_qtypayda_old tothinc2.qtypayda%type;
    v_qtypayhr_old tothinc2.qtypayhr%type;
    v_qtypaysc_old tothinc2.qtypaysc%type;
    v_amtpay_old   tothinc2.amtpay%type;
    v_codcomp      tcenter.codcomp%type;
    v_codsys      tothinc2.codsys%type    := 'PY';
  begin
    begin
      select qtypayda,
             qtypayhr,
             qtypaysc,
             amtpay
        into v_qtypayda_old,
             v_qtypayhr_old,
             v_qtypaysc_old,
             v_amtpay_old
        from tothinc2
       where codempid   = v_codempid
         and dteyrepay  = p_year
         and dtemthpay  = p_month
         and numperiod  = p_numperiod
         and codpay     = p_codpay
         and codcompw   = v_codcompw;
    exception when no_data_found then
      v_qtypayda_old := null;
      v_qtypayhr_old := null;
      v_qtypaysc_old := null;
      v_amtpay_old   := null;
    end;
    begin
      select costcent into v_costcent
        from tcenter
       where codcomp = v_codcompw;
    exception when no_data_found then
      v_costcent := null;
    end;
    update tothinc2
       set qtypayda   = v_qtypayda,
           qtypayhr   = v_qtypayhr,
           qtypaysc   = v_qtypaysc,
           amtpay     = stdenc(v_amtpay,v_codempid,global_v_chken),
           costcent   = v_costcent,
           dteupd     = sysdate,
           coduser    = global_v_coduser
     where codempid   = v_codempid
       and dteyrepay  = p_year
       and dtemthpay  = p_month
       and numperiod  = p_numperiod
       and codpay     = p_codpay
       and codcompw   = v_codcompw;

--904
    v_codcomp := v_codcomp2;
    if v_codcomp2 is null then
--904
        begin
          select codcomp
            into v_codcomp
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then
          v_codcomp := null;
        end;
--904
    end if;
--904
    add_tlogothinc (1,v_codempid,v_codcomp,'CODCOMPW',v_codcompw    ,v_codcompw); -- it's pk (cannot change)
    add_tlogothinc (2,v_codempid,v_codcomp,'QTYPAYDA',v_qtypayda_old,v_qtypayda);
    add_tlogothinc (3,v_codempid,v_codcomp,'QTYPAYHR',v_qtypayhr_old,v_qtypayhr);
    add_tlogothinc (4,v_codempid,v_codcomp,'QTYPAYSC',v_qtypaysc_old,v_qtypaysc);
    add_tlogothinc (5,v_codempid,v_codcomp,'AMTPAY'  ,v_amtpay_old  ,v_amtpay);
  end;

  procedure delete_tothinc2 (v_codcompw varchar2, v_codempid varchar2) as
    v_qtypayda_old tothinc2.qtypayda%type;
    v_qtypayhr_old tothinc2.qtypayhr%type;
    v_qtypaysc_old tothinc2.qtypaysc%type;
    v_amtpay_old   tothinc2.amtpay%type;
    v_codcomp      tcenter.codcomp%type;
  begin
    begin
      select qtypayda,
             qtypayhr,
             qtypaysc,
             amtpay
        into v_qtypayda_old,
             v_qtypayhr_old,
             v_qtypaysc_old,
             v_amtpay_old
        from tothinc2
       where codempid   = v_codempid
         and dteyrepay  = p_year
         and dtemthpay  = p_month
         and numperiod  = p_numperiod
         and codpay     = p_codpay
         and codcompw   = v_codcompw;
    exception when no_data_found then
      v_qtypayda_old := null;
      v_qtypayhr_old := null;
      v_qtypaysc_old := null;
      v_amtpay_old   := null;
    end;
    delete tothinc2
     where codempid  = v_codempid
       and dteyrepay = p_year
       and dtemthpay = p_month
       and numperiod = p_numperiod
       and codpay    = p_codpay
       and codcompw  = v_codcompw;

    --<< user25 Date : 30/09/2021 #6923
    delete tothinc
     where codempid  = v_codempid
       and dteyrepay = p_year
       and dtemthpay = p_month
       and numperiod = p_numperiod
       and codpay    = p_codpay;
   -->> user25 Date : 30/09/2021 #6923

--Redmine #5617
    if v_codcomp is null then
        begin
          select codcomp into v_codcomp
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then
          v_codcomp := null;
        end;
    end if;
--Redmine #5617

    add_tlogothinc (1,v_codempid,v_codcomp,'CODCOMPW',v_codcompw    ,null); -- it's pk (cannot change)
    add_tlogothinc (2,v_codempid,v_codcomp,'QTYPAYDA',v_qtypayda_old,null);
    add_tlogothinc (3,v_codempid,v_codcomp,'QTYPAYHR',v_qtypayhr_old,null);
    add_tlogothinc (4,v_codempid,v_codcomp,'QTYPAYSC',v_qtypaysc_old,null);
    add_tlogothinc (5,v_codempid,v_codcomp,'AMTPAY'  ,v_amtpay_old  ,null);
  exception when others then
     null;
  end;

  procedure add_tothpay (v_codcompw varchar2, v_codempid varchar2, v_dtepay    date,
                         v_amtpay   number  , v_flgpyctax varchar2) as
    v_codcomp    tcenter.codcomp%type;
    v_typpayroll temploy1.typpayroll%type;
    v_typemp     temploy1.typemp%type;
    v_costcent   tcenter.costcent%type;
  begin
    begin
      select t1.codcomp  , t1.typpayroll,
             t1.typemp   , t2.costcent
        into v_codcomp   , v_typpayroll ,
             v_typemp    , v_costcent
        from temploy1 t1,tcenter t2
       where t1.codcomp = t2.codcomp (+)
         and t1.codempid = v_codempid;
    exception when no_data_found then
      v_codcomp    := null;
      v_typpayroll := null;
      v_typemp     := null;
      v_costcent   := null;
    end;
    insert into tothpay (codempid   ,dteyrepay  ,dtemthpay,
                         numperiod  ,codpay     ,dtepay   ,
                         codcomp    ,typpayroll ,typemp   ,
                         amtpay     ,flgpyctax  ,costcent ,
                         dtecreate  ,codcreate  ,
                         dteupd     ,coduser,
                         codcompw)
                 values (v_codempid ,p_year      ,p_month ,
                         p_numperiod,p_codpay    ,v_dtepay,
                         v_codcomp  ,v_typpayroll,v_typemp,
                         stdenc(v_amtpay,v_codempid,global_v_chken),
                         v_flgpyctax,v_costcent,
                         sysdate    ,global_v_coduser,
                         sysdate    ,global_v_coduser,
                         v_codcompw);
    add_tlogothpay (1,v_codempid,v_codcomp,'AMTPAY'   ,
                    null,stdenc(v_amtpay,v_codempid,global_v_chken),
                    v_dtepay);
    add_tlogothpay (2,v_codempid,v_codcomp,'FLGPYCTAX',
                    null,v_flgpyctax,
                    v_dtepay);
  exception when dup_val_on_index then
    edit_tothpay (v_codcompw, v_codempid, v_dtepay   ,
                  v_amtpay  , v_flgpyctax);
  end;
  procedure edit_tothpay (v_codcompw varchar2, v_codempid varchar2, v_dtepay    date,
                          v_amtpay   number  , v_flgpyctax varchar2) as
    v_codcomp       tcenter.codcomp%type;
    v_typpayroll    temploy1.typpayroll%type;
    v_typemp        temploy1.typemp%type;
    v_costcent      tcenter.costcent%type;
    v_amtpay_old    tothpay.amtpay%type;
    v_flgpyctax_old tothpay.flgpyctax%type;
  begin
    begin
      select t1.codcomp  , t1.typpayroll,
             t1.typemp   , t2.costcent
        into v_codcomp   , v_typpayroll ,
             v_typemp    , v_costcent
        from temploy1 t1,tcenter t2
       where t1.codcomp = t2.codcomp
         and t1.codempid = v_codempid;
    exception when no_data_found then
      v_codcomp    := null;
      v_typpayroll := null;
      v_typemp     := null;
      v_costcent   := null;
    end;
    begin
      select amtpay,
             flgpyctax
        into v_amtpay_old,
             v_flgpyctax_old
        from tothpay
       where codempid   = v_codempid
         and dteyrepay  = p_year
         and dtemthpay  = p_month
         and numperiod  = p_numperiod
         and codpay     = p_codpay
         and dtepay     = v_dtepay;
    exception when no_data_found then
      v_amtpay_old := null;
      v_flgpyctax_old := null;
    end;
    update tothpay
       set codcomp    = v_codcomp,
           codcompw   = v_codcompw,
           typpayroll = v_typpayroll,
           typemp     = v_typemp,
           amtpay     = stdenc(v_amtpay,v_codempid,global_v_chken),
           flgpyctax  = v_flgpyctax,
           costcent   = v_costcent,
           dteupd     = sysdate,
           coduser    = global_v_coduser
     where codempid   = v_codempid
       and dteyrepay  = p_year
       and dtemthpay  = p_month
       and numperiod  = p_numperiod
       and codpay     = p_codpay
       and dtepay     = v_dtepay;
    add_tlogothpay (1,v_codempid,v_codcomp,'AMTPAY'   ,
                    v_amtpay_old,stdenc(v_amtpay,v_codempid,global_v_chken),
                    v_dtepay);
    add_tlogothpay (2,v_codempid,v_codcomp,'FLGPYCTAX',
                    v_flgpyctax_old,v_flgpyctax,
                    v_dtepay);
  end;

  procedure delete_tothpay ( v_codcompw varchar2, v_codempid varchar2, v_dtepay date) as
    v_codcomp       tcenter.codcomp%type;
    v_amtpay_old    tothpay.amtpay%type;
    v_flgpyctax_old tothpay.flgpyctax%type;
  begin
    begin
      select codcomp
        into v_codcomp
        from temploy1
       where codempid = v_codempid;
    exception when no_data_found then
      v_codcomp    := null;
    end;
    begin
      select amtpay,
             flgpyctax
        into v_amtpay_old,
             v_flgpyctax_old
        from tothpay
       where codempid   = v_codempid
         and dteyrepay  = p_year
         and dtemthpay  = p_month
         and numperiod  = p_numperiod
         and codpay     = p_codpay
         and dtepay     = v_dtepay;
    exception when no_data_found then
      v_amtpay_old := null;
      v_flgpyctax_old := null;
    end;
    delete tothpay
     where codempid   = v_codempid
       and dteyrepay  = p_year
       and dtemthpay  = p_month
       and numperiod  = p_numperiod
       and codpay     = p_codpay
       and dtepay     = v_dtepay;
    if(v_codempid is not null) then
        add_tlogothpay (1,v_codempid,v_codcomp,'AMTPAY'   ,
                        v_amtpay_old,null,
                        v_dtepay);
        add_tlogothpay (2,v_codempid,v_codcomp,'FLGPYCTAX',
                        v_flgpyctax_old,null,
                        v_dtepay);
    end if;
  end;

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    b_index_codempid    := hcm_util.get_string_t(obj_detail,'b_index_codempid');
    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    p_codempid          := hcm_util.get_string_t(obj_detail,'codempid');
    p_typpayroll        := hcm_util.get_string_t(obj_detail,'typpayroll');
    p_numperiod         := to_number(hcm_util.get_string_t(obj_detail,'numperiod'));
    p_month             := to_number(hcm_util.get_string_t(obj_detail,'month'));
    p_year              := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure initial_value_detail (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_numperiod  := to_number(hcm_util.get_string_t(obj_detail,'numperiod'));
    p_month      := to_number(hcm_util.get_string_t(obj_detail,'month'));
    p_year       := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp    := hcm_util.get_string_t(obj_detail,'codcomp');
    p_typpayroll := hcm_util.get_string_t(obj_detail,'typpayroll');
    p_codpay     := hcm_util.get_string_t(obj_detail,'codpay');
    p_condition  := hcm_util.get_string_t(obj_detail,'condition');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value_detail;

  procedure initial_value_save (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_numperiod  := to_number(hcm_util.get_string_t(obj_detail,'numperiod'));
    p_month      := to_number(hcm_util.get_string_t(obj_detail,'month'));
    p_year       := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp    := hcm_util.get_string_t(obj_detail,'codcomp');
    p_typpayroll := hcm_util.get_string_t(obj_detail,'typpayroll');
    p_codpay     := hcm_util.get_string_t(obj_detail,'codpay');
    if hcm_util.get_json_t(obj_detail,'param_json') is not null then
      param_json := hcm_util.get_json_t(obj_detail,'param_json');
    end if;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value_save;

  procedure initial_save (json_str_input in clob) as
    obj_detail json_object_t;
    xx clob;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_numperiod         := to_number(hcm_util.get_string_t(obj_detail,'numperiod'));
    p_month             := to_number(hcm_util.get_string_t(obj_detail,'month'));
    p_year              := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    p_typpayroll        := hcm_util.get_string_t(obj_detail,'typpayroll');

    p_tab1              := hcm_util.get_json_t(hcm_util.get_json_t(obj_detail,'param_json'),'tab1');
    p_tab2              := hcm_util.get_json_t(hcm_util.get_json_t(obj_detail,'param_json'),'tab2');

    p_codpay1           := hcm_util.get_string_t(hcm_util.get_json_t(p_tab1,'detail'),'codpay');
    p_codpay2           := hcm_util.get_string_t(hcm_util.get_json_t(p_tab2,'detail'),'codpay');

    if hcm_util.get_json_t(p_tab1,'table') is not null then
      param_json1 := hcm_util.get_json_t(p_tab1,'table');
    end if;
    if hcm_util.get_json_t(p_tab2,'table') is not null then
      param_json2 := hcm_util.get_json_t(p_tab2,'table');
    end if;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_save;


  procedure check_index as
    v_count number;
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
    end if;

--    select count(*)
--      into v_count
--      from tdtepay
--     where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
--       and typpayroll = p_typpayroll
--       and dteyrepay = p_year
--       and dtemthpay = p_month
--       and numperiod = p_numperiod;
--
--    if v_count = 0 then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tdtepay');
--    end if;

  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    obj_data    json_object_t:= json_object_t();
    obj_json    json_object_t := json_object_t();
    obj_detail1 json_object_t := json_object_t();
    obj_detail2 json_object_t := json_object_t();
    obj_row1    json_object_t := json_object_t();
    obj_row2    json_object_t := json_object_t();
    v_count1    number := 0;
    v_count2    number := 0;

  begin
    obj_detail1.put('rows',obj_row1);
    obj_detail2.put('table',obj_detail1);
    obj_detail2.put('detail',obj_data);
    obj_json.put('tab1',obj_detail2);
    obj_json.put('tab2',obj_detail2);
    obj_json.put('coderror','200');
    json_str_output := obj_json.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_coscenter(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_coscenter(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_coscenter(json_str_output out clob) as
    v_costcent      tcenter.costcent%type := '';
    obj_json        json_object_t := json_object_t();
  begin
    begin
      select costcent
        into v_costcent
        from tcenter
       where codcomp like p_codcomp || '%'
         and rownum = 1
    order by codcomp;
    exception when no_data_found then null;
    end;
    if p_codcomp is not null then
      obj_json.put('costcent',v_costcent);
    end if;
    obj_json.put('coderror','200');
    json_str_output := obj_json.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_amtday(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_amtday(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  function cal_amtday(p_codempid_query  temploy1.codempid%type) return number as
    v_secur       boolean;

    v_codempmt    varchar2(100 char);
    v_codcomp     varchar2(100 char);
    v_amtincom1   number;
    v_amtincom2   number;
    v_amtincom3   number;
    v_amtincom4   number;
    v_amtincom5   number;
    v_amtincom6   number;
    v_amtincom7   number;
    v_amtincom8   number;
    v_amtincom9   number;
    v_amtincom10  number;

    v_amtpay      number;
    v_qtypayda    number;
    v_qtypayhr    number;
    v_qtypaysc    number;

    v_amthr       number := 0;
    v_amtday      number := 0;
    v_amtmth      number := 0;
  begin
    v_secur := secur_main.secur2(p_codempid_query,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
    if v_secur then

      begin
        select  emp1.codempmt,emp1.codcomp,
                stddec(amtincom1,emp1.codempid,global_v_chken),
                stddec(amtincom2,emp1.codempid,global_v_chken),
                stddec(amtincom3,emp1.codempid,global_v_chken),
                stddec(amtincom4,emp1.codempid,global_v_chken),
                stddec(amtincom5,emp1.codempid,global_v_chken),
                stddec(amtincom6,emp1.codempid,global_v_chken),
                stddec(amtincom7,emp1.codempid,global_v_chken),
                stddec(amtincom8,emp1.codempid,global_v_chken),
                stddec(amtincom9,emp1.codempid,global_v_chken),
                stddec(amtincom10,emp1.codempid,global_v_chken)
          into  v_codempmt,v_codcomp,
                v_amtincom1,v_amtincom2,
                v_amtincom3,v_amtincom4,v_amtincom5,
                v_amtincom6,v_amtincom7,v_amtincom8,
                v_amtincom9,v_amtincom10
          from temploy1 emp1, temploy3 emp3
         where emp1.codempid = p_codempid_query
           and emp1.codempid   = emp3.codempid;
      exception when no_data_found then
        v_amtincom1   := 0;
        v_amtincom2   := 0;
        v_amtincom3   := 0;
        v_amtincom4   := 0;
        v_amtincom5   := 0;
        v_amtincom6   := 0;
        v_amtincom7   := 0;
        v_amtincom8   := 0;
        v_amtincom9   := 0;
        v_amtincom10  := 0;
      end;

      get_wage_income(hcm_util.get_codcomp_level(v_codcomp, 1), v_codempmt,
                      nvl(v_amtincom1,0),nvl(v_amtincom2,0),
                      nvl(v_amtincom3,0),nvl(v_amtincom4,0),
                      nvl(v_amtincom5,0),nvl(v_amtincom6,0),
                      nvl(v_amtincom7,0),nvl(v_amtincom8,0),
                      nvl(v_amtincom9,0),nvl(v_amtincom10,0),
                      v_amthr, v_amtday, v_amtmth);
    end if;
    return v_amtday;
  end;
  --
  procedure gen_amtday(json_str_output out clob) as
    obj_json      json_object_t := json_object_t();
    v_amtday      number := 0;
  begin
    v_amtday    := cal_amtday(p_codempid);
    obj_json.put('amtday',to_char(v_amtday,'fm999999999990.00'));
    obj_json.put('coderror','200');
    json_str_output := obj_json.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_detail1 as
    v_typpayroll   varchar2(100 char);
    v_numperiod    number;
    v_flgtdtepay   varchar2(1 char);
    v_tcontpms     number;
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
      return;
    end if;
    if p_codpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpay');
      return;
    end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
    end if;
    if p_codpay is not null then
      begin
        select codpay
          into p_codpay
          from tinexinf
         where codpay = p_codpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
        return;
      end;

        begin
            select t1.numperiod, 'Y'
               into v_numperiod, v_flgtdtepay
              from tdtepay t1
             where t1.codcompy = hcm_util.get_codcomp_level(p_codcomp, 1) and
                t1.typpayroll = p_typpayroll and
                t1.dteyrepay  = p_year and
                t1.dtemthpay  = p_month and
                t1.numperiod  = p_numperiod and rownum = 1;
        exception when no_data_found then
            v_flgtdtepay := 'N' ;
        end;
        begin
            select count(*) into v_tcontpms
              from tcontpms t1
             where p_codpay in (t1.codincom1,t1.codincom2,t1.codincom3,t1.codincom4,t1.codincom5,
                                t1.codincom6,t1.codincom7,t1.codincom8,t1.codincom9,t1.codincom10)
               and codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
               and t1.dteeffec = (select max(dteeffec)
                                    from tcontpms
                                   where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                                     and dteeffec <= trunc(sysdate)) ;
        exception when no_data_found then
            v_tcontpms := 0;
        end;

-->> fix issue #2144 user18
--        if nvl(v_tcontpms,0) > 0 AND v_flgtdtepay = 'N' then
--            param_msg_error := get_error_msg_php('PY0043',global_v_lang,'tcontpms');
--            return;
--        end if;
--<< fix issue #2144 user18

        if v_flgtdtepay = 'N' then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tdtepay');
            return;
        end if;
    end if;
  end check_detail1;

  procedure get_detail1(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value_detail(json_str_input);
    check_detail1;
    if param_msg_error is null then
        gen_detail1(json_str_output);
    else
        json_str_output := get_response_message(400,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail1;

  procedure gen_detail1(json_str_output out clob) as
    obj_row          json_object_t := json_object_t();
    obj_data         json_object_t;
    v_stmt           varchar2(4000 char);
    v_secur          varchar2(4000 char);
    v_desc_coduser   varchar2(4000 char);
    v_cursor_id      integer;
    v_col            number;
    v_count          number := 0;
    v_desctab        dbms_sql.desc_tab;
    v_codempid       tothinc2.codempid%type;
    v_amtday         varchar2(4000 char);
    v_codsys         tothinc.codsys%type;
    v_codcompw       tothinc2.codcompw%type;
    v_costcent       tothinc2.costcent%type;
    v_qtypayda       tothinc2.qtypayda%type;
    v_qtypayhr       tothinc2.qtypayhr%type;
    v_qtypaysc       tothinc2.qtypaysc%type;
    v_amtpay         varchar2(4000 char);
    v_dteupd         tothinc2.dteupd%type;
    v_coduser        tothinc2.coduser%type;

    v_varchar2       varchar2(4000 char);
    v_number         number;
    v_date           date;
    v_fetch          integer;
    v_secur3   	     boolean := true;
    v_codcomp        temploy1.codcomp%type;
    v_flgtrnbank     ttaxcur.flgtrnbank%type;
  begin
    v_stmt := 'select b.codempid,to_char(stddec(d.amtday,b.codempid,''' || global_v_chken || '''),''fm999999999990.00'') amtday,
                      a.codsys  ,b.codcompw,b.costcent,
                      b.qtypayda,b.qtypayhr,b.qtypaysc,
                      to_char(stddec(b.amtpay,b.codempid,''' || global_v_chken || '''),''fm999999999990.00'') amtpay,
                      b.dteupd  ,b.coduser ,c.codcomp
                 from tothinc a,tothinc2 b,temploy1 c,temploy3 d
                where a.codempid   = b.codempid
                  and a.dteyrepay  = b.dteyrepay
                  and a.dtemthpay  = b.dtemthpay
                  and a.numperiod  = b.numperiod
                  and a.codpay     = b.codpay
                  and a.codempid   = c.codempid
                  and a.codempid   = d.codempid
                  and a.numperiod  = ' || p_numperiod ||
                ' and a.dtemthpay  = ' || p_month ||
                ' and a.dteyrepay  = ' || p_year ||
                ' and c.codcomp    like ''' || p_codcomp || '%' ||
              ''' and c.typpayroll = ''' || p_typpayroll ||
              ''' and a.codpay     = ''' || p_codpay || '''';
    begin
      v_cursor_id := dbms_sql.open_cursor;
      dbms_output.put_line(v_cursor_id);
      dbms_sql.parse(v_cursor_id, v_stmt, dbms_sql.native);
      dbms_sql.describe_columns(v_cursor_id, v_col, v_desctab);

      for i in 1 .. v_col loop
        if v_desctab(i).col_type = 1 then
          dbms_sql.define_column(v_cursor_id, i, v_varchar2, 4000);
        elsif v_desctab(i).col_type = 2 then
          dbms_sql.define_column(v_cursor_id, i, v_number);
        elsif v_desctab(i).col_type = 12 then
          dbms_sql.define_column(v_cursor_id, i, v_date);
        end if;
      end loop;

      v_fetch := dbms_sql.execute(v_cursor_id);
      while dbms_sql.fetch_rows(v_cursor_id) > 0 loop
        obj_data := json_object_t();
        dbms_sql.column_value(v_cursor_id, 1, v_codempid);
        dbms_sql.column_value(v_cursor_id, 2, v_amtday);
        dbms_sql.column_value(v_cursor_id, 3, v_codsys);
        dbms_sql.column_value(v_cursor_id, 4, v_codcompw);
        dbms_sql.column_value(v_cursor_id, 5, v_costcent);
        dbms_sql.column_value(v_cursor_id, 6, v_qtypayda);
        dbms_sql.column_value(v_cursor_id, 7, v_qtypayhr);
        dbms_sql.column_value(v_cursor_id, 8, v_qtypaysc);
        dbms_sql.column_value(v_cursor_id, 9, v_amtpay);
        dbms_sql.column_value(v_cursor_id, 10, v_dteupd);
        dbms_sql.column_value(v_cursor_id, 11, v_coduser);
        dbms_sql.column_value(v_cursor_id, 12, v_codcomp);


        v_secur3 := secur_main.secur3(v_codcomp,v_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        if v_secur3 then
          obj_data.put('codempid',v_codempid);
          obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang));
          obj_data.put('amtday',v_amtday);
          obj_data.put('codsys',v_codsys);
          obj_data.put('codcompw',v_codcompw);
          obj_data.put('desc_codcompw',get_tcenter_name(v_codcompw,global_v_lang));
          obj_data.put('costcent',v_costcent);
          obj_data.put('qtypayda',to_char(v_qtypayda,'fm9999999990'));
          obj_data.put('qtypayhr',to_char(v_qtypayhr,'fm9999999990'));
          obj_data.put('qtypaysc',to_char(v_qtypaysc,'fm9999999990'));
          obj_data.put('amtpay',v_amtpay);
          begin
            select get_temploy_name(codempid,global_v_lang)
              into v_desc_coduser
              from tusrprof
             where coduser = v_coduser;
              obj_data.put('desc_coduser',v_desc_coduser);
          exception when no_data_found then
              null;
          end;
          /*
          begin
            select nvl(flgtrnbank,'N')
              into v_flgtrnbank
              from ttaxcur
             where codempid = v_codempid
               and to_date(numperiod||'/'||dtemthpay||'/'||dteyrepay) =  to_date(p_numperiod||'/'||p_month||'/'||p_year)
               and rownum = 1;
          exception when no_data_found then
            v_flgtrnbank := 'N';
          end;
          */
          v_flgtrnbank := get_flgtrnbank (null, v_codempid,p_year, p_month,p_numperiod);
          obj_data.put('flgtrnbank', v_flgtrnbank);
          obj_data.put('coderror','200');
          obj_row.put(to_char(v_count),obj_data);
          v_count := v_count + 1;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor_id);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      if dbms_sql.is_open(v_cursor_id) then
          dbms_sql.close_cursor(v_cursor_id);
      end if;
    end;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_detail2 as
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
      return;
    end if;
    if p_codpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpay');
      return;
    end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
    end if;
    if p_codpay is not null then
      begin
        select codpay
          into p_codpay
          from tinexinf
         where codpay = p_codpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
      end;
    end if;
  end check_detail2;

  procedure get_detail2(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value_detail(json_str_input);
    check_detail2;
    if param_msg_error is null then
        gen_detail2(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail2;
  --
  procedure gen_detail2(json_str_output out clob) as
    obj_row          json_object_t := json_object_t();
    obj_data         json_object_t;
    v_stmt           varchar2(4000 char);
    v_secur          varchar2(4000 char);
    v_desc_coduser   varchar2(4000 char);
    v_cursor_id      integer;
    v_col            number;
    v_count          number := 0;
    v_desctab        dbms_sql.desc_tab;
    v_codempid       tothpay.codempid%type;
    v_dtepay         tothpay.dtepay%type;
    v_amtpay         varchar2(4000 char);
    v_flgpyctax      tothpay.flgpyctax%type;
    v_dteupd         tothpay.dteupd%type;
    v_coduser        tothpay.coduser%type;
    v_costcent       tothpay.costcent%type;

    v_varchar2       varchar2(4000 char);
    v_number         number;
    v_date           date;
    v_fetch          integer;
    v_secur3   	     boolean := true;
    v_codcomp        temploy1.codcomp%type;
    v_flgtrnbank        varchar2(1 char);
  begin
    v_stmt := 'select a.codempid,a.dtepay,
                      to_char(stddec(a.amtpay,a.codempid,''' || global_v_chken || '''),''fm999999999990.00'') amtpay,
                      a.flgpyctax,a.dteupd,a.coduser ,a.codcompw codcomp,a.costcent
                 from tothpay a,temploy1 c
                where a.codempid   = c.codempid
                  and a.numperiod  = ' || p_numperiod ||
                ' and a.dtemthpay  = ' || p_month ||
                ' and a.dteyrepay  = ' || p_year ||
                ' and c.codcomp    like ''' || p_codcomp || '%' ||
              ''' and c.typpayroll = ''' || p_typpayroll ||
              ''' and a.codpay     = ''' || p_codpay || '''';
    begin
      v_cursor_id := dbms_sql.open_cursor;
      dbms_output.put_line(v_cursor_id);
      dbms_sql.parse(v_cursor_id, v_stmt, dbms_sql.native);
      dbms_sql.describe_columns(v_cursor_id, v_col, v_desctab);

      for i in 1 .. v_col loop
        if v_desctab(i).col_type = 1 then
          dbms_sql.define_column(v_cursor_id, i, v_varchar2, 4000);
        elsif v_desctab(i).col_type = 2 then
          dbms_sql.define_column(v_cursor_id, i, v_number);
        elsif v_desctab(i).col_type = 12 then
          dbms_sql.define_column(v_cursor_id, i, v_date);
        end if;
      end loop;

      v_fetch := dbms_sql.execute(v_cursor_id);

      while dbms_sql.fetch_rows(v_cursor_id) > 0 loop
        obj_data := json_object_t();
        dbms_sql.column_value(v_cursor_id, 1, v_codempid);
        dbms_sql.column_value(v_cursor_id, 2, v_dtepay);
        dbms_sql.column_value(v_cursor_id, 3, v_amtpay);
        dbms_sql.column_value(v_cursor_id, 4, v_flgpyctax);
        dbms_sql.column_value(v_cursor_id, 5, v_dteupd);
        dbms_sql.column_value(v_cursor_id, 6, v_coduser);
        dbms_sql.column_value(v_cursor_id, 7, v_codcomp);
        dbms_sql.column_value(v_cursor_id, 8, v_costcent);

        v_secur3 := secur_main.secur3(v_codcomp,v_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        if v_secur3 then
          obj_data.put('codempid',v_codempid);
          obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang));
          obj_data.put('dtepay',to_char(v_dtepay,'dd/mm/yyyy'));
          obj_data.put('amtpay',v_amtpay);
          obj_data.put('flgpyctax',v_flgpyctax);
          obj_data.put('codcomp',v_codcomp);
          obj_data.put('costcent',v_costcent);
          obj_data.put('dteupd',to_char(v_dteupd,'dd/mm/yyyy'));
          obj_data.put('coduser',v_coduser);
          begin
            select get_temploy_name(codempid,global_v_lang)
              into v_desc_coduser
              from tusrprof
             where coduser = v_coduser;
              obj_data.put('desc_coduser',v_desc_coduser);
          exception when no_data_found then
              null;
          end;
          /*
          begin
            select 'Y'
              into v_flgtrnbank
              from ttaxcur
             where codempid = v_codempid
               and to_date(numperiod||'/'||dtemthpay||'/'||dteyrepay) =  to_date(p_numperiod||'/'||p_month||'/'||p_year)
               and rownum = 1;
          exception when no_data_found then
            v_flgtrnbank := 'N';
          end;*/
          v_flgtrnbank := get_flgtrnbank (null,v_codempid,p_year, p_month,p_numperiod);
          obj_data.put('flgtrnbank', v_flgtrnbank);
          obj_data.put('coderror','200');
          obj_row.put(to_char(v_count),obj_data);
          v_count := v_count + 1;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor_id);
    exception when others then
      if dbms_sql.is_open(v_cursor_id) then
          dbms_sql.close_cursor(v_cursor_id);
      end if;
    end;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_save1 as
    v_codpaypy5  varchar2(100 char);
  	v_flgperiod  varchar2(100 char);
    type codpay_arr is table of tinexinf.codpay%type index by binary_integer;
        v_codpay	  codpay_arr;
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
      return;
    end if;
    if p_codpay is null and param_json is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpay');
      return;
    end if;
    if p_codpay is not null and  param_json is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'param_json');
      return;
    end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
        return;
      end;
    end if;
    if p_codpay is not null then
      begin
        select codpay
          into p_codpay
          from tinexinf
         where codpay = p_codpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
        return;
      end;
      ---
      begin
        select codpay into p_codpay
          from tinexinfc
         where codpay   = p_codpay
           and codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('PY0044',global_v_lang,'tinexinfc');
        return;
      end;
      ---
      begin
				select 'Y' into	 v_flgperiod
				  from tdtepay
				 where codcompy	  = hcm_util.get_codcomp_level(p_codcomp,1)
				   and typpayroll = p_typpayroll
				   and dteyrepay  = p_year
				   and dtemthpay  = p_month
				   and numperiod  = p_numperiod;
			exception when no_data_found then
				v_flgperiod := 'N' ;
			end;
      ---
			for i in 1..10 loop
			    v_codpay(i) := null ;
			end loop;
		   ---
		  if v_flgperiod = 'N' then
            begin
				    select codincom1,codincom2,codincom3,codincom4,codincom5,
				           codincom6,codincom7,codincom8,codincom9,codincom10
				      into v_codpay(1),v_codpay(2),v_codpay(3),v_codpay(4),v_codpay(5),
				           v_codpay(6),v_codpay(7),v_codpay(8),v_codpay(9),v_codpay(10)
				      from tcontpms
				     where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                       and dteeffec = (select max(dteeffec)
				                         from tcontpms
				                        where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                                          and dteeffec <= trunc(sysdate));
			exception when others then null;
			end ;
            -->> fix issue #2144 user18
--			for i in 1..10 loop
--                if p_codpay  = nvl(v_codpay(i),'$%') then
--                    param_msg_error := get_error_msg_php('PY0043',global_v_lang,'tcontpms');
--                    return;
--                end if;
--            end loop;
            --<< fix issue #2144 user18
		  end if;
    end if;
    --
    begin
      select codpaypy5  into v_codpaypy5
        from tcontrpy
       where codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontrpy
                          where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                            and dteeffec  <= sysdate);
      exception when no_data_found then null;
    end;
    --
    if p_codpay = v_codpaypy5 then
      param_msg_error := get_error_msg_php('PY0019',global_v_lang);
      return;
    end if;
  end check_save1;

  procedure save1_data(json_str_output out clob) as
    json_obj    json_object_t;
    flgAdd      boolean;
    flgDelete   boolean;
    flgEdit     boolean;
    v_flg       varchar2(100 char);
    v_codcompw  tcenter.codcomp%type;
    v_codempid  temploy1.codempid%type;
    v_qtypayda  tothinc2.qtypayda%type;
    v_qtypayhr  tothinc2.qtypayhr%type;
    v_qtypaysc  tothinc2.qtypaysc%type;
    v_amtpay    number;
    v_staemp    varchar2(100 char);
    v_codcomp   temploy1.codcomp%type;
    cursor c1 is
      select a.codempid
        from tothinc a
       where a.numperiod = p_numperiod
         and a.dtemthpay = p_month
         and a.dteyrepay = p_year
         and a.codpay    = p_codpay
       union
      select b.codempid
        from tothinc2 b
       where b.numperiod = p_numperiod
         and b.dtemthpay = p_month
         and b.dteyrepay = p_year
         and b.codpay    = p_codpay;
  begin
    for i in 0..param_json.get_size-1 loop
      json_obj      := hcm_util.get_json_t(param_json,to_char(i));
      v_flg         := hcm_util.get_string_t(json_obj,'flg');
      v_codcompw    := hcm_util.get_string_t(json_obj,'codcompw');
      v_codempid    := hcm_util.get_string_t(json_obj,'codempid');
      v_qtypayda    := to_number(hcm_util.get_string_t(json_obj,'qtypayda'));
      v_qtypayhr    := to_number(hcm_util.get_string_t(json_obj,'qtypayhr'));
      v_qtypaysc    := to_number(hcm_util.get_string_t(json_obj,'qtypaysc'));
      v_amtpay      := to_number(hcm_util.get_string_t(json_obj,'amtpay'));
      if v_codempid is not null and not flgDelete then
       begin
         select codempid, staemp, codcomp
           into p_codempid, v_staemp, v_codcomp
           from temploy1
          where codempid = v_codempid;
            if nvl(v_staemp,0) = 0 then
               param_msg_error := get_error_msg_php('HR2102',global_v_lang);
            end if;
          exception when no_data_found then null;
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
          end;

          if not secur_main.secur3(v_codcomp,v_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal) then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          end if;
      end if;

      if param_msg_error is null then
        if v_flg = 'delete' then
          delete_tothinc2 (v_codcompw , v_codempid);
        elsif v_flg = 'add' then
--904          add_tothinc2 (v_codcompw, v_codempid,
          add_tothinc2 (v_codcompw, v_codempid, v_codcomp,
--904
                        v_qtypayda, v_qtypayhr,
                        v_qtypaysc, v_amtpay  );
        elsif v_flg = 'edit' then
--904          edit_tothinc2 (v_codcompw, v_codempid,
          edit_tothinc2 (v_codcompw, v_codempid, v_codcomp,
--904
                         v_qtypayda, v_qtypayhr,
                         v_qtypaysc, v_amtpay  );
        end if;
      end if;
    end loop;
    if param_msg_error is null then
      for r1 in c1 loop
        update_tothinc(r1.codempid, p_numperiod, p_month, p_year, p_codpay);
      end loop;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure check_save2 as
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
      return;
    end if;
    if p_codpay is null and param_json is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpay');
      return;
    end if;
    if p_codpay is not null and  param_json is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'param_json');
      return;
    end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
        return;
      end;
    end if;
    if p_codpay is not null then
      begin
        select codpay
          into p_codpay
          from tinexinf
         where codpay = p_codpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
        return;
      end;
      ---
      begin
        select codpay into p_codpay
          from tinexinfc
         where codpay   = p_codpay
           and codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('PY0044',global_v_lang,'tinexinfc');
        return;
      end;
    end if;
  end check_save2;

  procedure save2_data(json_str_output out clob) as
    json_obj    json_object_t;
    flgAdd      boolean;
    flgDelete   boolean;
    flgEdit     boolean;
    v_codempid  temploy1.codempid%type;
    v_dtepay    date;
    v_amtpay    number;
    v_flgpyctax varchar2(4000 char);
    v_staemp    varchar2(100 char);
    v_codcomp   temploy1.codcomp%type;
    v_codcompw  tcenter.codcomp%type;
    v_dtestrt   tdtepay.dtestrt%type;
    v_dteend    tdtepay.dteend%type;
    v_flg       varchar2(100 char);

    cursor c1 is
      select a.codempid
        from tothinc a
       where a.numperiod = p_numperiod
         and a.dtemthpay = p_month
         and a.dteyrepay = p_year
         and a.codpay    = p_codpay
       union
      select b.codempid
        from tothinc2 b
       where b.numperiod = p_numperiod
         and b.dtemthpay = p_month
         and b.dteyrepay = p_year
         and b.codpay    = p_codpay;
  begin
    for i in 0..param_json.get_size-1 loop
      json_obj      := hcm_util.get_json_t(param_json,to_char(i));
      v_flg         := hcm_util.get_string_t(json_obj,'flg');
      v_codempid    := hcm_util.get_string_t(json_obj,'codempid');
      v_dtepay      := to_date(hcm_util.get_string_t(json_obj,'dtepay'),'dd/mm/yyyy');
      v_amtpay      := to_number(hcm_util.get_string_t(json_obj,'amtpay'));
      v_flgpyctax   := hcm_util.get_string_t(json_obj,'flgpyctax');
      v_codcompw    := hcm_util.get_string_t(json_obj,'codcomp');
      v_flgpyctax   := hcm_util.get_string_t(json_obj,'flgpyctax');

      if v_codempid is not null then
       begin
         select codempid, staemp, codcomp
           into p_codempid, v_staemp, v_codcomp
           from temploy1
          where codempid = v_codempid;
            if nvl(v_staemp,0) = 0 then
               param_msg_error := get_error_msg_php('HR2102',global_v_lang);
            end if;
          exception when no_data_found then null;
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
          end;

          if not secur_main.secur3(v_codcomp,v_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal) then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          end if;
      end if;
      if param_msg_error is null then
          begin
            select dtestrt , dteend
              into v_dtestrt , v_dteend
              from tdtepay
             where codcompy     = hcm_util.get_codcomp_level(p_codcomp, 1)
               and typpayroll   = p_typpayroll
               and dteyrepay    = p_year
               and dtemthpay    = p_month
               and numperiod    = p_numperiod;
          exception when no_data_found then
            v_dtestrt := null;
            v_dteend  := null;
          end;

            if v_dtepay not between v_dtestrt  and  v_dteend then
              param_msg_error := get_error_msg_php('PY0070',global_v_lang);
              exit;
            end if;
          -----------
            if v_flg = 'delete' then
              delete_tothpay (v_codcompw, v_codempid, v_dtepay );
            elsif v_flg = 'add' then
              add_tothpay (v_codcompw, v_codempid , v_dtepay    ,
                           v_amtpay   , v_flgpyctax );
            elsif v_flg = 'edit' then
              edit_tothpay (v_codcompw, v_codempid, v_dtepay   ,
                            v_amtpay  , v_flgpyctax);
            end if;
      end if;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure post_save(json_str_input in clob,json_str_output out clob) as
  begin
    initial_save(json_str_input);
    param_json      := param_json1;
    p_codpay        := p_codpay1;
    check_save1;
    if param_msg_error is null then
        save1_data(json_str_output);
    end if;

    if param_msg_error is null then
        param_json      := param_json2;
        p_codpay        := p_codpay2;
        check_save2;
        if param_msg_error is null then
            save2_data(json_str_output);
        end if;
    end if;

    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message(400,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end post_save;

  procedure get_amtpay(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    json_obj      json_object_t := json_object_t(json_str_input);
    v_codempid    varchar2(100 char);
    v_codempmt    varchar2(100 char);
    v_codcomp     varchar2(100 char);
    v_amtincom1   number;
    v_amtincom2   number;
    v_amtincom3   number;
    v_amtincom4   number;
    v_amtincom5   number;
    v_amtincom6   number;
    v_amtincom7   number;
    v_amtincom8   number;
    v_amtincom9   number;
    v_amtincom10  number;

    v_amtpay      number;
    v_qtypayda    number;
    v_qtypayhr    number;
    v_qtypaysc    number;

    v_amthr       number := 0;
    v_amtday      number := 0;
    v_amtmth      number := 0;

  begin
    global_v_chken     := hcm_secur.get_v_chken;
    v_codempid  := hcm_util.get_string_t(json_obj,'p_codempid_query');
    v_qtypayda  := to_number(nvl(hcm_util.get_string_t(json_obj,'p_qtypayda'), 0));
    v_qtypayhr  := to_number(nvl(hcm_util.get_string_t(json_obj,'p_qtypayhr'), 0));
    v_qtypaysc  := to_number(nvl(hcm_util.get_string_t(json_obj,'p_qtypaysc'), 0));

    begin
   select  emp1.codempmt,emp1.codcomp,
              stddec(amtincom1,emp1.codempid,global_v_chken),
              stddec(amtincom2,emp1.codempid,global_v_chken),
              stddec(amtincom3,emp1.codempid,global_v_chken),
              stddec(amtincom4,emp1.codempid,global_v_chken),
              stddec(amtincom5,emp1.codempid,global_v_chken),
              stddec(amtincom6,emp1.codempid,global_v_chken),
              stddec(amtincom7,emp1.codempid,global_v_chken),
              stddec(amtincom8,emp1.codempid,global_v_chken),
              stddec(amtincom9,emp1.codempid,global_v_chken),
              stddec(amtincom10,emp1.codempid,global_v_chken)
        into  v_codempmt,v_codcomp,
              v_amtincom1,v_amtincom2,
              v_amtincom3,v_amtincom4,v_amtincom5,
              v_amtincom6,v_amtincom7,v_amtincom8,
              v_amtincom9,v_amtincom10
        from temploy1 emp1, temploy3 emp3
       where emp1.codempid = v_codempid
         and emp1.codempid   = emp3.codempid;
    exception when no_data_found then
      v_amtincom1   := 0;
      v_amtincom2   := 0;
      v_amtincom3   := 0;
      v_amtincom4   := 0;
      v_amtincom5   := 0;
      v_amtincom6   := 0;
      v_amtincom7   := 0;
      v_amtincom8   := 0;
      v_amtincom9   := 0;
      v_amtincom10  := 0;
    end;

    get_wage_income(hcm_util.get_codcomp_level(v_codcomp, 1), v_codempmt,
                      nvl(v_amtincom1,0),nvl(v_amtincom2,0),
                      nvl(v_amtincom3,0),nvl(v_amtincom4,0),
                      nvl(v_amtincom5,0),nvl(v_amtincom6,0),
                      nvl(v_amtincom7,0),nvl(v_amtincom8,0),
                      nvl(v_amtincom9,0),nvl(v_amtincom10,0),
                      v_amthr, v_amtday, v_amtmth);
    v_amtpay := (v_qtypayda * v_amtday) + (v_qtypayhr * v_amthr) + (v_qtypaysc * v_amthr / 60);
    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('amtpay', to_char(v_amtpay,'fm9999999990.00'));

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_amtpay;
  --
  procedure gen_condition_detail_1(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t := json_object_t();
    obj_data        json_object_t;
    json_input      json_object_t;
    json_param      json_object_t;
    json_param_row  json_object_t;
    v_stmt          varchar2(4000 char);
    v_descond       varchar2(4000 char);
    v_cursor_id     integer;
    v_col           number;
    v_count         number := 0;
    v_desctab       dbms_sql.desc_tab;
    v_codempid      tothinc2.codempid%type;
    v_amtday        number;
    v_codcompw      tothinc2.codcompw%type;
    v_costcent      tothinc2.costcent%type;
    v_qtypayda      tothinc2.qtypayda%type;
    v_qtypayhr      tothinc2.qtypayhr%type;
    v_qtypaysc      tothinc2.qtypaysc%type;
    v_amtpay        varchar2(4000 char);

    v_varchar2      varchar2(4000 char);
    v_fetch         integer;
    v_chk_secur	    boolean := true;

    v_codcomp       tcenter.codcomp%type;
    v_typpayroll    temploy1.typpayroll%type;
    v_chk_json_param  varchar2(1);
    v_flgtrnbank     ttaxcur.flgtrnbank%type;

    v_count_exists  number;
  begin
    json_input      := json_object_t(json_str_input);
    v_codcomp       := hcm_util.get_string_t(json_input,'codcomp');
    v_typpayroll    := hcm_util.get_string_t(json_input,'typpayroll');
    v_descond       := hcm_util.get_string_t(json_input,'condition');

    json_param      := hcm_util.get_json_t(json_input,'param_json');
    v_descond       := replace(v_descond,'TEMPLOY1.CODCOMP'   ,'codcomp');
    v_descond       := replace(v_descond,'TEMPLOY1.CODPOS'    ,'codpos');
    v_descond       := replace(v_descond,'TEMPLOY1.TYPPAYROLL','typpayroll');
    v_descond       := replace(v_descond,'TEMPLOY1.CODEMPMT'  ,'codempmt');
    v_descond       := replace(v_descond,'TEMPLOY1.TYPEMP'    ,'typemp');

    v_stmt  := ' select codempid,codcomp
                   from temploy1 c
                  where staemp  not in (''0'',''9'')
                    and codcomp     like ''' || v_codcomp || '%''
                    and typpayroll  = ''' || v_typpayroll || ''' ';
    if v_descond is not null then
      v_stmt := v_stmt || ' and (' || v_descond || ')';
    end if;

    obj_row   := json_object_t();
    begin
      v_cursor_id := dbms_sql.open_cursor;
      dbms_output.put_line(v_cursor_id);
      dbms_sql.parse(v_cursor_id, v_stmt, dbms_sql.native);
      dbms_sql.describe_columns(v_cursor_id, v_col, v_desctab);
      dbms_sql.define_column(v_cursor_id, 1, v_varchar2, 4000);
      dbms_sql.define_column(v_cursor_id, 2, v_varchar2, 4000);

      v_fetch := dbms_sql.execute(v_cursor_id);
      while dbms_sql.fetch_rows(v_cursor_id) > 0 loop
        dbms_sql.column_value(v_cursor_id, 1, v_codempid);
        dbms_sql.column_value(v_cursor_id, 2, v_codcomp);
        v_chk_secur   := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if v_chk_secur then
          v_chk_json_param    := 'N';
          for i in 0..json_param.get_size - 1 loop
            json_param_row    := hcm_util.get_json_t(json_param,to_char(i));
            v_qtypayda        := hcm_util.get_string_t(json_param_row,'day');
            v_qtypayhr        := hcm_util.get_string_t(json_param_row,'hour');
            v_qtypaysc        := hcm_util.get_string_t(json_param_row,'minute');
            v_amtpay          := hcm_util.get_string_t(json_param_row,'amt');
            v_codcompw        := hcm_util.get_string_t(json_param_row,'codcomp');
            obj_data          := json_object_t();
            begin
              select costcent
                into v_costcent
                from tcenter
               where codcomp like v_codcompw || '%'
                 and rownum = 1
--904              order by codcomp
              ;
            exception when no_data_found then
              v_costcent  := null;
            end;
            v_chk_json_param  := 'Y';


            select count(b.codempid)
              into v_count_exists
              from tothinc a,tothinc2 b
             where a.codempid   = b.codempid
               and a.dteyrepay  = b.dteyrepay
               and a.dtemthpay  = b.dtemthpay
               and a.numperiod  = b.numperiod
               and a.codpay     = b.codpay
               and a.numperiod  = p_numperiod
               and a.dtemthpay  = p_month
               and a.dteyrepay  = p_year
               and a.codpay     = p_codpay
               and a.codempid = v_codempid
               and b.codcompw = get_compful(v_codcompw);
            v_flgtrnbank := get_flgtrnbank (null, v_codempid,p_year, p_month,p_numperiod);
            if v_count_exists = 0 and v_flgtrnbank = 'N' then
                obj_data.put('coderror','200');
                obj_data.put('codempid',v_codempid);
                obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang));
                v_amtday    := cal_amtday(v_codempid);
                if v_zupdsal = 'Y' then
                  obj_data.put('amtday',to_char(v_amtday,'fm999,999,990.00'));
                else
                  obj_data.put('amtday','');
                end if;
    --            obj_data.put('amount',);
                obj_data.put('qtypayda',to_char(v_qtypayda,'fm9999999990'));
                obj_data.put('qtypayhr',to_char(v_qtypayhr,'fm9999999990'));
                obj_data.put('qtypaysc',to_char(v_qtypaysc,'fm9999999990'));
                obj_data.put('amtpay',v_amtpay);
                obj_data.put('codcompw',v_codcompw);
                obj_data.put('costcent',v_costcent);
                obj_data.put('codsys','PY');
                obj_data.put('dteupd','');
                obj_data.put('coduser','');
                obj_data.put('desc_coduser','');
                obj_data.put('flgAdd',true);
                obj_data.put('flgEdit',false);

                obj_data.put('flgtrnbank', v_flgtrnbank);
                obj_row.put(to_char(v_count),obj_data);
                v_count   := v_count + 1;
            end if;
          end loop;
          if v_chk_json_param = 'N' then
            v_flgtrnbank := get_flgtrnbank (null,v_codempid,p_year, p_month,p_numperiod);
            if v_flgtrnbank = 'N' then
                obj_data  := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('codempid',v_codempid);
                obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang));
                v_amtday    := cal_amtday(v_codempid);
                if v_zupdsal = 'Y' then
                  obj_data.put('amtday',v_amtday);
                else
                  obj_data.put('amtday','');
                end if;
    --            obj_data.put('amount',);
                obj_data.put('qtypayda','');
                obj_data.put('qtypayhr','');
                obj_data.put('qtypaysc','');
                obj_data.put('amtpay','');
                obj_data.put('codcompw','');
                obj_data.put('costcent','');
                obj_data.put('codsys','PY');
                obj_data.put('dteupd','');
                obj_data.put('coduser','');
                obj_data.put('desc_coduser','');
                obj_data.put('flgAdd',true);

                obj_data.put('flgtrnbank', v_flgtrnbank);
                obj_row.put(to_char(v_count),obj_data);
                v_count   := v_count + 1;
            end if;
          end if;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor_id);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      if dbms_sql.is_open(v_cursor_id) then
          dbms_sql.close_cursor(v_cursor_id);
      end if;
    end;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_condition_detail_1(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value_save(json_str_input);
    if param_msg_error is null then
      gen_condition_detail_1(json_str_input, json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_condition_detail_2(json_str_input in clob,json_str_output out clob) as
    obj_row          json_object_t := json_object_t();
    obj_data         json_object_t;
    json_input       json_object_t;
    v_stmt           varchar2(4000 char);
    v_descond        varchar2(4000 char);
    v_cursor_id      integer;
    v_col            number;
    v_count          number := 0;
    v_desctab        dbms_sql.desc_tab;
    v_codempid       tothpay.codempid%type;
    v_dtepay         tothpay.dtepay%type;
    v_amtpay         varchar2(4000 char);
    v_flgpyctax      tothpay.flgpyctax%type;

    v_varchar2       varchar2(4000 char);
    v_fetch          integer;
    v_chk_secur   	 boolean := true;
    v_codcomp        tcenter.codcomp%type;
    v_typpayroll     temploy1.typpayroll%type;
    v_flgtrnbank     ttaxcur.flgtrnbank%type;
    v_codcompw       tcenter.codcomp%type;

  begin
    json_input      := json_object_t(json_str_input);
    v_codcomp       := hcm_util.get_string_t(json_input,'codcomp');
    v_typpayroll    := hcm_util.get_string_t(json_input,'typpayroll');
    v_descond       := hcm_util.get_string_t(json_input,'condition');
    v_dtepay        := to_date(hcm_util.get_string_t(json_input,'paydate'),'dd/mm/yyyy');
    v_amtpay        := hcm_util.get_string_t(json_input,'amtpay');
    v_flgpyctax     := hcm_util.get_string_t(json_input,'flgpyctax');
    v_codcompw      := hcm_util.get_string_t(json_input,'codcompw');

    v_descond       := replace(v_descond,'TEMPLOY1.CODCOMP'   ,'codcomp');
    v_descond       := replace(v_descond,'TEMPLOY1.CODPOS'    ,'codpos');
    v_descond       := replace(v_descond,'TEMPLOY1.TYPPAYROLL','typpayroll');
    v_descond       := replace(v_descond,'TEMPLOY1.CODEMPMT'  ,'codempmt');
    v_descond       := replace(v_descond,'TEMPLOY1.TYPEMP'    ,'typemp');

    v_stmt  := ' select codempid,codcomp
                   from temploy1
                  where staemp    not in (''0'',''9'')
                    and codcomp     like ''' || v_codcomp || '%''
                    and typpayroll  = ''' || v_typpayroll || ''' ';
    if v_descond is not null then
      v_stmt := v_stmt || ' and ' || v_descond;
    end if;
    obj_row   := json_object_t();
    begin
      v_cursor_id := dbms_sql.open_cursor;
      dbms_output.put_line(v_cursor_id);
      dbms_sql.parse(v_cursor_id, v_stmt, dbms_sql.native);
      dbms_sql.describe_columns(v_cursor_id, v_col, v_desctab);
      dbms_sql.define_column(v_cursor_id, 1, v_varchar2, 4000);
      dbms_sql.define_column(v_cursor_id, 2, v_varchar2, 4000);

      v_fetch := dbms_sql.execute(v_cursor_id);
      while dbms_sql.fetch_rows(v_cursor_id) > 0 loop
        dbms_sql.column_value(v_cursor_id, 1, v_codempid);
        dbms_sql.column_value(v_cursor_id, 2, v_codcomp);
        v_chk_secur   := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if v_chk_secur then
          obj_data  := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('codempid',v_codempid);
          obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang));
          obj_data.put('dtepay',to_char(v_dtepay,'dd/mm/yyyy'));
          obj_data.put('amtpay',v_amtpay);
          obj_data.put('flgpyctax',v_flgpyctax);
          obj_data.put('codcomp',v_codcompw);
          obj_data.put('costcent','');
          obj_data.put('dteupd','');
          obj_data.put('coduser','');
          obj_data.put('desc_coduser','');
          obj_data.put('flgAdd',true);
          v_flgtrnbank := get_flgtrnbank (null, v_codempid,p_year, p_month,p_numperiod);
          obj_data.put('flgtrnbank', v_flgtrnbank);

          obj_row.put(to_char(v_count),obj_data);
          v_count := v_count + 1;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor_id);
    exception when others then
      if dbms_sql.is_open(v_cursor_id) then
          dbms_sql.close_cursor(v_cursor_id);
      end if;
    end;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_condition_detail_2(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value_save(json_str_input);
    if param_msg_error is null then
      gen_condition_detail_2(json_str_input, json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_codcompw(json_str_output out clob) is
    v_codcompw  temploy1.codcomp%type;
    obj_data    json_object_t;
  begin
    begin
      select codcomp
        into v_codcompw
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      v_codcompw  := '';
    end;

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('codcompw',v_codcompw);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_codcompw(json_str_input in clob,json_str_output out clob) is
    v_flgtrnbank     ttaxcur.flgtrnbank%type;
  begin
    initial_value(json_str_input);

    v_flgtrnbank := get_flgtrnbank (null, b_index_codempid,p_year, p_month,p_numperiod);

    if v_flgtrnbank = 'Y' then
        param_msg_error := get_error_msg_php('AL0076',global_v_lang);
    end if;
    if param_msg_error is null then
      gen_codcompw(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end HRPY29E;

/

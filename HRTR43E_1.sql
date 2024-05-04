--------------------------------------------------------
--  DDL for Package Body HRTR43E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR43E" AS
--01/08/2022
  procedure initial_value(json_str_input in clob) as
       json_obj json_object_t;
  begin
       json_obj          := json_object_t(json_str_input);
       global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
       global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
       global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_dteyear        := hcm_util.get_string_t(json_obj,'p_dteyear');
        p_codcompy       := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
        p_codcours       := hcm_util.get_string_t(json_obj,'p_codcours');
        p_codcate        := hcm_util.get_string_t(json_obj,'p_codcate');
        p_numclseq       := hcm_util.get_string_t(json_obj,'p_numclseq');
        p_codempid       := hcm_util.get_string_t(json_obj,'p_codempid_query');
        p_signature      := hcm_util.get_string_t(json_obj,'p_signature');
        p_flgsendmail    := hcm_util.get_string_t(json_obj,'p_flgwait');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
    v_temp varchar2(1 char);
  begin
--  validate year and codcompy
    if p_dteyear is null or p_codcompy is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  validate codcours and codcate
    if p_codcours is null and p_codcate is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check codcompy in tcompny
    begin
        select 'X' into v_temp
        from tcompny
        where codcompy = p_codcompy;
     exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
        return;
     end;

--  check secure7
    if secur_main.secur7(p_codcompy,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

  end check_index;

  procedure check_send_mail as
    v_temp varchar2(1 char);
  begin

    if p_flgsendmail is null or p_signature is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_signature;
     exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
     end;

  end check_send_mail;

  procedure check_approv_amount_emp as
    v_qtyemp          number;
    v_qtyemp2         number;
    p_qtyptbdg        tyrtrpln.qtyptbdg%type;
    p_qtynumcl        tyrtrpln.qtynumcl%type;
    v_qtyptbdg        number := 0; --<<user25 Date: 12/10/2021 #6672
    v_regis            number := 0; --<<user25 Date: 12/10/2021 #6672

  begin
        select count(*) into v_qtyemp -- number of people who have attended the training in current gen
          from tpotentp
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and numclseq = p_numclseq
           and codcours = p_codcours
           and staappr = 'Y';
        --
        select count(*) into v_qtyemp2 -- number of people who have attended the training
          from tpotentp
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and codcours = p_codcours
           and staappr = 'Y';
        --
        begin
            select qtyptbdg,qtynumcl into p_qtyptbdg,p_qtynumcl
            from tyrtrpln
            where dteyear = p_dteyear
              and codcompy = p_codcompy
              and codcours = p_codcours;
        exception when no_data_found then
            p_qtyptbdg := 0;
        end;
        --<<user25 Date: 12/10/2021 #6672
--        if (v_qtyemp + v_qtyemp2) > p_qtyptbdg then
--            param_msg_error := get_error_msg_php('TR0039',global_v_lang);
--            return;
--        end if;

--<<user14||01/08/2022 redmine 441 HRTR43E  by Jayjay  (dteregis)
        /*
         v_qtyptbdg := floor(p_qtyptbdg/p_qtynumcl);
        begin
          select count(*) 
          into v_regis
          from tpotentp
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and numclseq = p_numclseq
            and codcours = p_codcours
            and dteregis is not null;
        end;

       if v_regis  > v_qtyptbdg then
            param_msg_error := get_error_msg_php('TR0039',global_v_lang);
            return;
        end if;
        */
-->>user14||01/08/2022 redmine 441 HRTR43E  by Jayjay  (dteregis)

       -->>user25 Date: 12/10/2021 #6672
  end check_approv_amount_emp;

  procedure check_approv as
    v_temp           varchar2(100 char);
    p_person_number  number;
    p_qtyptbdg       tyrtrpln.qtyptbdg%type;
  begin
    begin
        select 'X' into v_temp
        from tyrtrsch
        where dteyear = p_dteyear
          and numclseq = p_numclseq
          and codcompy = p_codcompy
          and codcours = p_codcours;
    exception when no_data_found then
        v_temp := '';
    end;

    if p_stappr is null and p_dteappr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_stappr = 'W' then
        if p_dteyear is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if p_numclseq is not null then
            if v_temp is null then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tyrtrsch');
                return;
            end if;
        end if;
    end if;
  end check_approv;
  procedure validate_mail as
     v_temp      varchar2(1 char);
  begin
    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_codempid;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
            return;
         end;
  end validate_mail;

  procedure gen_index(json_str_output out clob) as
    obj_rows         json_object_t;
    obj_data         json_object_t;
    v_row            number := 0;
    p_check          varchar2(10 char);
    p_person_number  number;
    p_person_number2 number;
    p_qtyptbdg       tyrtrpln.qtyptbdg%type;
    p_qtynumcl       tyrtrpln.qtynumcl%type;
    v_boolean        boolean;
    v_flgapp         boolean := false;
    v_flgdata        boolean := false;
    v_approvno       number := 1;
    v_codapp         varchar2(10 char) := 'HRTR55E';
    v_qtyptbdg       number := 0;--<<user25 Date: 12/10/2021 #6672

    cursor c1 is
      select codcours,numclseq,dtetrst,dtetren,qtyemp,codresp
        from tyrtrsch
        where dteyear = p_dteyear
          and codcompy = p_codcompy
          and codcours = nvl(p_codcours,codcours)
          and codcate = nvl(p_codcate,codcate)
          order by codcours,numclseq;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
      v_flgdata := true;
      v_boolean := chk_flowmail.check_approve(v_codapp, i.codresp, v_approvno, global_v_codempid, null, null, p_check);
      if v_boolean then
        v_flgapp := true;
        begin
          select count(*) into p_person_number
          from tpotentp
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and numclseq = i.numclseq
            and codcours = i.codcours
            and stacours <> 'W';
        end;
        begin
          select count(*) into p_person_number2
          from tpotentp
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and numclseq = i.numclseq
            and codcours = i.codcours;
--<<--redmine 441 HRTR43E  by Jayjay            
            --and dteregis is not null;
-->>--redmine 441 HRTR43E  by Jayjay
        end;

        begin
          select qtyptbdg,qtynumcl 
          into p_qtyptbdg,p_qtynumcl
          from tyrtrpln
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and codcours = i.codcours;
        exception when no_data_found then
          p_qtyptbdg := 0;
          p_qtynumcl := 0;
        end;
        if p_qtynumcl = 0 then
          p_qtynumcl := 1;
        end if;
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('codcours',i.codcours);
        obj_data.put('codcours_name',get_tcourse_name(i.codcours,global_v_lang));
        obj_data.put('numclseq',i.numclseq);
        obj_data.put('dtetrst',to_char(i.dtetrst,'dd/mm/yyyy'));
        obj_data.put('dtetren',to_char(i.dtetren,'dd/mm/yyyy'));
        obj_data.put('qtyemp',i.qtyemp);
        obj_data.put('codresp',i.codresp);
        obj_data.put('person_number_plan',p_person_number);
        obj_data.put('person_number_regis',p_person_number2);
        --<<user25 Date: 12/10/2021 #6672
        v_qtyptbdg := floor(p_qtyptbdg/p_qtynumcl);--<<user25 Date: 12/10/2021 #6672
--        obj_data.put('person_number_budget',floor(p_qtyptbdg/p_qtynumcl));
        obj_data.put('person_number_budget',v_qtyptbdg);
        -->>user25 Date: 12/10/2021 #6672
        obj_rows.put(to_char(v_row-1),obj_data);
      end if;
    end loop;
    if not v_flgdata then ----obj_rows.count() = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tyrtrsch');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    elsif not v_flgapp then ----
      param_msg_error := get_error_msg_php('HR3008',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_rows.to_clob;
    return;

  end gen_index;

   procedure gen_data_from_approv(json_str_output out clob) as
    obj_rows         json_object_t;
    obj_data         json_object_t;
    obj_result       json_object_t;
    v_row            number := 0;
    p_person_number  number;
    p_person_number2 number;
    p_qtyptbdg       tyrtrpln.qtyptbdg%type;
    p_qtynumcl       tyrtrpln.qtynumcl%type;
    p_qtyemp         tyrtrsch.qtyemp%type;
    v_count          number;
    v_count2         number;
    v_error          varchar2(500 char);
    v_chk_secur      boolean := false;
    cursor c1 is
      select '1' typedata,codempid,codcomp,codpos,stacours,dteregis,
             staappr,dteyearn,numclsn,flgatend,flgqlify,dteappr,codappr,remarkap
        from tpotentp
       where (( dteyear = p_dteyear
                and codcompy = p_codcompy
                and codcours = p_codcours
                and numclseq = p_numclseq )
          or ( dteyearn = p_dteyear
               and numclsn = p_numclseq
               and codcompy = p_codcompy
               and codcours = p_codcours))
         and flgwait = 'Y' and staappr = 'W'
        union
        select '2' typedata,codempid,codcomp,codpos,stacours,dteregis,staappr,dteyearn,numclsn,flgatend,flgqlify,dteappr,codappr,remarkap
        from tpotentp
        where dteyear = p_dteyear
          and codcompy = p_codcompy
          and codcours = p_codcours
          and numclseq = p_numclseq
--<<--redmine 441 HRTR43E  by Jayjay          
          --and dteregis is not null
-->>--redmine 441 HRTR43E  by Jayjay          
          and staappr = 'P'
        union
        select '3' typedata,codempid,codcomp,codpos,stacours,dteregis,staappr,dteyearn,numclsn,flgatend,flgqlify,dteappr,codappr,remarkap
        from tpotentp
        where dteyear = p_dteyear
          and codcompy = p_codcompy
          and codcours = p_codcours
          and numclseq = p_numclseq
          and staappr in ('Y','N')
        order by typedata,codempid,dteregis;
    begin
    obj_rows := json_object_t();
    obj_result := json_object_t();

    begin
        select qtyptbdg,qtynumcl into p_qtyptbdg, p_qtynumcl
        from tyrtrpln
        where dteyear = p_dteyear
          and codcompy = p_codcompy
          and codcours = p_codcours;
    exception when no_data_found then
        p_qtyptbdg := 0;
    end;

    begin
        select count(*) into p_qtyemp
        from tpotentp
        where dteyear = p_dteyear
          and codcompy = p_codcompy
          and codcours = p_codcours
          and staappr = 'Y';
    exception when no_data_found then
        p_qtyemp := 0;
    end;

    begin
        select count(*) into p_person_number
        from tpotentp
        where dteyear = p_dteyear
          and codcompy = p_codcompy
          and codcours = p_codcours
          and numclseq = p_numclseq
          and staappr = 'Y';
    exception when no_data_found then
         p_person_number := 0;
    end;
    obj_result.put('coderror', '200');
    obj_result.put('qtyptbdg',p_qtyptbdg);
    obj_result.put('qtyemp',p_qtyemp);
    obj_result.put('qtyempattend',p_person_number);

    for i in c1 loop
        v_count2 := v_count2 + 1;
        v_chk_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_chk_secur then
            v_row := v_row+1;
            obj_data := json_object_t();
            if i.stacours is null then
                i.stacours := 'O';
            end if;

            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('desc_stacours',get_tlistval_name('STACOURS',i.stacours,global_v_lang));
            obj_data.put('staappr',i.staappr);
            obj_data.put('status',get_tlistval_name('TRSTAAPPR',i.staappr,global_v_lang));
            obj_data.put('dteyearn',i.dteyearn);
            obj_data.put('numclsn',i.numclsn);

            select count(*) into v_count
            from thistrnn
            where codempid = i.codempid
              and dteyear = p_dteyear
              and codcours = p_codcours;

            if v_count > 0 then
                obj_data.put('attended_trainning',get_tlistval_name('FLGQLIFY','Y',global_v_lang));
            else
                obj_data.put('attended_trainning',get_tlistval_name('FLGQLIFY','N',global_v_lang));
            end if;
            obj_data.put('qualify_status',get_tlistval_name('FLGQLIFY',i.flgqlify,global_v_lang));
            obj_data.put('dteregis',to_char(i.dteregis,'dd/mm/yyyy'));
            obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
            obj_data.put('codappr',get_temploy_name(i.codappr,global_v_lang));
            obj_data.put('remarkap',i.remarkap);

            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    if v_count2 = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TPOTENTP');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    else
        obj_result.put('table',obj_rows);
        json_str_output := obj_result.to_clob;
    end if;

    end gen_data_from_approv;

    procedure gen_employee(json_str_output out clob) as
        obj_rows         json_object_t;
        obj_data         json_object_t;
        v_row            number := 0;
        v_count          number;
        rec_temploy      temploy1%rowtype;
        v_stacours       ttpotent.stacours%type;
        v_flgqlify       varchar(1 char);
        v_dteyear        ttpotent.dteyear%type;
        v_numclseq       tpotentp.numclseq%type;
        v_staappr        tpotentp.staappr%type;
        v_dteappr        tpotentp.dteappr%type;
        v_dteregis       tpotentp.dteregis%type;

    begin
      begin
        select * into rec_temploy
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        rec_temploy := null;
      end;
      obj_rows := json_object_t();
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_codcomp',get_tcenter_name(rec_temploy.codcomp,global_v_lang));
      obj_data.put('desc_codpos',get_tpostn_name(rec_temploy.codpos,global_v_lang));
      obj_data.put('codappr',get_temploy_name(global_v_codempid,global_v_lang));

      select count(*) into v_count
      from thistrnn
      where codempid = p_codempid
        and dteyear = p_dteyear
        and codcours = p_codcours;

      if v_count > 0 then
          obj_data.put('attended_trainning',get_tlistval_name('FLGQLIFY','Y',global_v_lang));
      else
          obj_data.put('attended_trainning',get_tlistval_name('FLGQLIFY','N',global_v_lang));
      end if;

      begin
          select stacours,'Y',dteyear into v_stacours,v_flgqlify,v_dteyear
          from ttpotent
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and codcours = p_codcours
            and codempid = p_codempid;
      exception when no_data_found then
          v_stacours := 'O';
          v_flgqlify := 'N';
          v_dteyear  := '';
      end;

      begin
          select staappr,dteappr,dteregis into v_staappr,v_dteappr,v_dteregis
          from tpotentp
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and codcours = p_codcours
            and codempid = p_codempid
            and numclseq = p_numclseq;
      exception when no_data_found then
          v_staappr := '';
          v_dteappr := '';
      end;
      obj_data.put('dteyear','');
      obj_data.put('numclseq','');
      obj_data.put('status',get_tlistval_name('TRSTAAPPR','Y',global_v_lang));
      obj_data.put('staappr','Y');
      obj_data.put('dteappr',to_char(sysdate,'dd/mm/yyyy'));
      obj_data.put('dteregis',to_char(nvl(v_dteregis,sysdate),'dd/mm/yyyy'));
      obj_data.put('desc_stacours',get_tlistval_name('STACOURS',v_stacours,global_v_lang));
      obj_data.put('qualify_status',get_tlistval_name('FLGQLIFY',v_flgqlify,global_v_lang));

      json_str_output := obj_data.to_clob;
    end gen_employee;

    procedure update_waiting_list(v_codcomp varchar2, v_codpos varchar2) as
    begin
          update tpotentp
            set staappr = 'W',
                flgwait = 'Y',
                dteyearn = p_dteyearn,
                numclsn  = p_numclsn,
                dteappr  = p_dteappr,
                codappr  = global_v_codempid,
                remarkap = p_remarkap,
                coduser = global_v_coduser
            where dteyear  = p_dteyear
              and codcompy = p_codcompy
              and numclseq = p_numclseq
              and codcours = p_codcours
              and codempid = p_codempid;


    /* --#3127
        begin
            insert into tpotentp
                (dteyear,codcompy,numclseq,codcours,codempid,codcomp,
                 codpos,flgatend,remarkap,dteappr,codappr,staappr,dteregis,
                 codcreate,coduser,flgqlify,dtecreate,flgwait,dteyearn,numclsn)
            values
                (p_dteyear,p_codcompy,p_numclseq,p_codcours,p_codempid,v_codcomp,
                v_codpos,'Y',p_remarkap,p_dteappr,global_v_codempid,p_stappr,p_dteregis,
                global_v_coduser,global_v_coduser,p_flgqlify,sysdate,'Y',p_dteyear,p_numclseq);
        exception when dup_val_on_index then
            update tpotentp
            set staappr = 'W',
--                flgwait = 'Y', --#3874 เน�เธกเน�เธ�เธฑเธ�เธ—เธถเธ�เน€เธ�เธช waiting
                flgwait = 'W',
                dteyearn = p_dteyear,
                numclsn = p_numclseq,
                dteappr = p_dteappr,
                codappr = global_v_codempid,
                remarkap = p_remarkap,
                coduser = global_v_coduser
            where dteyear = p_dteyear
              and codcompy = p_codcompy
              and numclseq = p_numclseq
              and codcours = p_codcours
              and codempid = p_codempid;
        end;
        */
    end update_waiting_list;

    procedure update_tpotentp as
      v_rec     tpotentp%rowtype;
      v_exist   varchar2(1 char);
      v_numlvl    temploy1.numlvl%type;
      v_codcomp   temploy1.codcomp%type;
      v_codpos    temploy1.codpos%type;
      v_codtparg  tyrtrsch.codtparg%type;
      v_dtetrst   tyrtrsch.dtetrst%type;
      v_dtetren   tyrtrsch.dtetren%type;
    begin
        begin
            select * into v_rec
            from tpotentp
            where dteyear = p_dteyear
              and codcompy = p_codcompy
              and codcours = p_codcours
              and codempid = p_codempid
              and numclseq = p_numclseq;
              v_exist := 'Y';
        exception when no_data_found then
            v_rec := null;
            v_exist := 'N';
        end;

        begin
            select numlvl,codcomp,codpos into v_numlvl,v_codcomp,v_codpos
            from temploy1
            where codempid = p_codempid;
        exception when no_data_found then
            v_numlvl := '';
        end;
        begin
            select codtparg,dtetrst,dtetren into v_codtparg,v_dtetrst,v_dtetren
            from tyrtrsch
            where dteyear = p_dteyear
              and codcompy = p_codcompy
              and codcours = p_codcours
              and numclseq = p_numclseq;
        exception when no_data_found then
            v_codtparg := '';
        end;
        if v_exist = 'Y' and v_rec.dteyearn is not null then
          insert into tpotentp ( dteyear,codcompy,numclseq,codcours,codempid,codcomp,
                                 codpos,numlvl,codtparg,flgatend,dtetrst,dtetren,remarkap,
                                 dteappr,codappr,staappr,dteregis,codcreate,coduser,flgqlify,
                                 dtecreate,flgwait,stacours)
          values ( v_rec.dteyearn,p_codcompy,v_rec.numclsn,p_codcours,p_codempid,v_rec.codcomp,
                   v_rec.codpos,v_rec.numlvl,v_rec.codtparg,v_rec.flgatend,v_rec.dtetrst,v_rec.dtetren,p_remarkap,
                   p_dteappr,global_v_codempid,p_stappr,v_rec.dteregis,
                   global_v_coduser,global_v_coduser,v_rec.flgqlify,sysdate,p_flgwait,v_rec.stacours);
          -- delete after new record
          begin
            delete tpotentp
            where dteyear = p_dteyear
              and codcompy = p_codcompy
              and numclseq = p_numclseq
              and codcours = p_codcours
              and codempid = p_codempid;
          end;
        elsif v_exist = 'Y'  then
          update tpotentp
            set staappr  = p_stappr,
                dteappr  = p_dteappr,
                codappr  = global_v_codempid,
                remarkap = p_remarkap,
                coduser  = global_v_coduser
            where dteyear  = p_dteyear
              and codcompy = p_codcompy
              and numclseq = p_numclseq
              and codcours = p_codcours
              and codempid = p_codempid;
        end if;
    end update_tpotentp;

    procedure insert_tpotentp(v_codcomp varchar2,v_codpos varchar2) as
        v_numlvl    temploy1.numlvl%type;
        v_codtparg  tyrtrsch.codtparg%type;
        v_dtetrst   tyrtrsch.dtetrst%type;
        v_dtetren   tyrtrsch.dtetren%type;
    begin
        begin
            select numlvl into v_numlvl
            from temploy1
            where codempid = p_codempid;
        exception when no_data_found then
            v_numlvl := '';
        end;

        begin
            select codtparg,dtetrst,dtetren into v_codtparg,v_dtetrst,v_dtetren
            from tyrtrsch
            where dteyear = p_dteyear
              and codcompy = p_codcompy
              and codcours = p_codcours
              and numclseq = p_numclseq;
        exception when no_data_found then
            v_codtparg := '';
        end;

        insert into tpotentp
            (
             dteyear,codcompy,numclseq,codcours,codempid,codcomp,
             codpos,numlvl,codtparg,flgatend,dtetrst,dtetren,remarkap,
             dteappr,codappr,staappr,dteregis,codcreate,coduser,flgqlify,
             dtecreate,flgwait,stacours,
             numclsn,dteyearn
            )
        values
            (
             p_dteyear,p_codcompy,p_numclseq,p_codcours,p_codempid,v_codcomp,
             v_codpos,v_numlvl,v_codtparg,'Y',v_dtetrst,v_dtetren,p_remarkap,
             p_dteappr,global_v_codempid,p_stappr,p_dteregis,
             global_v_coduser,global_v_coduser,p_flgqlify,sysdate,p_flgwait,p_stacours,
             p_numclsn,p_dteyearn
            );
    end insert_tpotentp;

    procedure delete_tpotentp as
    begin
        delete tpotentp
        where dteyear = p_dteyear
          and codcompy = p_codcompy
          and numclseq = p_numclseq
          and codcours = p_codcours
          and codempid = p_codempid;
    end delete_tpotentp;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    BEGIN
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    end get_index;

    procedure gen_send_mail_appr(json_str_output out clob) as
        obj_rows         json;
        obj_data         json;
        v_row            number := 0;
        v_msg_to         clob;
        v_template_to    long;
        v_func_appr      long;
        v_codform        tfrmmail.codform%type;
        v_error          terrorm.errorno%type;
        v_codcours       tyrtrsch.codcours%type;
        v_numclseq       tyrtrsch.numclseq%type;
        v_dtetrst        tyrtrsch.dtetrst%type;
        v_dtetren        tyrtrsch.dtetren%type;
        v_codhotel       tyrtrsch.codhotel%type;
        v_codinsts       tyrtrsch.codinsts%type;
        v_codpos         temploy1.codpos%type;
        v_dteprest       tyrtrsch.dteprest%type;
        v_dtepreen       tyrtrsch.dtepreen%type;
        v_subject        varchar2(500 char);

        v_rowid             varchar(20);
        v_rowid_tyrtrsch    varchar(20);
        v_rowid_signature   varchar(20);

        add_month number:=0;
        v_year        varchar2(10 char);

    cursor c1 is
        select a.rowid,b.codempid,b.codcomp,b.codpos,b.email
        from tpotentp a,temploy1 b
        where a.codempid = b.codempid
          and a.dteyear = p_dteyear
          and a.codcompy = p_codcompy
          and a.numclseq = p_numclseq
          and a.codcours = p_codcours
          and a.flgwait = 'N'
          and a.staappr = 'Y'
        order by a.codempid;

    begin
        add_month := hcm_appsettings.get_additional_year*12;
        begin
            select rowid,dteprest,dtepreen into v_rowid_tyrtrsch,v_dteprest,v_dtepreen
            from tyrtrsch
            where dteyear = p_dteyear
              and codcompy = p_codcompy
              and numclseq = p_numclseq
              and codcours = p_codcours;
        exception when no_data_found then
            v_rowid := '';
            v_dteprest := '';
        end;

        if v_dteprest is not null then
            v_subject := get_label_name('HRTR43ET2',global_v_lang,'10');
            v_codform := 'HRTR43ET2';
        else
            v_subject := get_label_name('HRTR43ET1',global_v_lang,'10');
            v_codform := 'HRTR43ET1';
        end if;

        begin
            select codpos,rowid into v_codpos,v_rowid_signature
            from temploy1
            where codempid = p_signature;
        exception when no_data_found then
            v_codpos := '';
        end;

       obj_rows := json();
        for i in c1 loop
          begin
            chk_flowmail.get_message_result(v_codform,global_v_lang,v_msg_to,v_template_to);
            chk_flowmail.replace_text_frmmail(v_template_to,'TPOTENTP', i.rowid, v_subject, v_codform, '1', null, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');
            chk_flowmail.replace_param('TYRTRSCH',v_rowid_tyrtrsch,v_codform,'1',global_v_lang,v_msg_to,'N');

            v_msg_to := replace(v_msg_to,'[PARAM_7]',to_char(add_months(v_dteprest,add_month),'dd/mm/yyyy')||' - '||to_char(add_months(v_dtepreen,add_month),'dd/mm/yyyy'));
            v_msg_to := replace(v_msg_to,'[PARAM_SIGN]',get_temploy_name(p_signature,global_v_lang));
            v_msg_to := replace(v_msg_to,'[PARAM_POSITION]',get_tpostn_name(v_codpos,global_v_lang));

            v_error := chk_flowmail.send_mail_to_emp (i.codempid, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, null,null,null, null, null);

            if  v_error <> '2046' then
              param_msg_error := get_error_msg_php('HR7522',global_v_lang);
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
              return;
            else
              param_msg_error := get_error_msg_php('HR2046',global_v_lang);
              json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            end if;
          exception when others then
            param_msg_error := get_error_msg_php('HR7522',global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
          end;
        end loop;
    end gen_send_mail_appr;

    procedure gen_send_mail_wait(json_str_output out clob) as
        v_row            number := 0;
        v_msg_to         clob;
        v_template_to    long;
        v_func_appr      long;
        v_codform        tfrmmail.codform%type;
        v_error          terrorm.errorno%type;
        v_codcours       tyrtrsch.codcours%type;
        v_numclseq       tyrtrsch.numclseq%type;
        v_dtetrst        tyrtrsch.dtetrst%type;
        v_dtetren        tyrtrsch.dtetren%type;
        v_codhotel       tyrtrsch.codhotel%type;
        v_codinsts       tyrtrsch.codinsts%type;
        v_codpos         temploy1.codpos%type;
        v_dteprest       tyrtrsch.dteprest%type;
        v_subject        varchar2(500 char);
        v_dtepreen       tyrtrsch.dtepreen%type;

        v_rowid         varchar(20);
        v_rowid_tyrtrsch    varchar(20);
        v_rowid_signature   varchar(20);

    cursor c2 is
        select a.rowid,b.codempid,b.codcomp,b.codpos,b.email
        from tpotentp a,temploy1 b
        where a.codempid = b.codempid
          and a.dteyear = p_dteyear
          and a.codcompy = p_codcompy
          and a.numclseq = p_numclseq
          and a.codcours = p_codcours
          and a.flgwait = 'Y'
          and a.staappr = 'W'
        order by a.codempid;
    begin
        begin
            select rowid into v_rowid_tyrtrsch
            from tyrtrsch
            where dteyear = p_dteyear
              and codcompy = p_codcompy
              and numclseq = p_numclseq
              and codcours = p_codcours;
        exception when no_data_found then
            v_rowid := '';
        end;

            v_subject := get_label_name('HRTR43ET3',global_v_lang,'10');
            v_codform := 'HRTR43ET3';

        begin
            select codpos,rowid into v_codpos,v_rowid_signature
            from temploy1
            where codempid = p_signature;
        exception when no_data_found then
            v_codpos := '';
        end;

        for i in c2 loop
          begin
            chk_flowmail.get_message_result(v_codform,global_v_lang,v_msg_to,v_template_to);
--            chk_flowmail.replace_text_frmmail(v_template_to,'TPOTENTP', i.rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');
            chk_flowmail.replace_text_frmmail(v_template_to,'TPOTENTP', i.rowid, v_subject, v_codform, '1', null, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');
            chk_flowmail.replace_param('TYRTRSCH',v_rowid_tyrtrsch,v_codform,'1',global_v_lang,v_msg_to,'N');

            v_msg_to := replace(v_msg_to,'[PARAM_SIGN]',get_temploy_name(p_signature,global_v_lang));
            v_msg_to := replace(v_msg_to,'[PARAM_POSITION]',get_tpostn_name(v_codpos,global_v_lang));

            v_error := chk_flowmail.send_mail_to_emp (i.codempid, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, null,null,null, null);

            if  v_error <> '2046' then
              param_msg_error := get_error_msg_php('HR7522',global_v_lang);
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
              return;
            else
              param_msg_error := get_error_msg_php('HR2046',global_v_lang);
              json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            end if;
          exception when others then
            param_msg_error := get_error_msg_php('HR7522',global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
          end;
        end loop;
    end gen_send_mail_wait;

    procedure get_data_from_approv(json_str_input in clob, json_str_output out clob) as
    BEGIN
        initial_value(json_str_input);
        check_approv_amount_emp;--<<user25 Date: 12/10/2021 #6672
        if param_msg_error is null then
            gen_data_from_approv(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    end get_data_from_approv;

    procedure get_employee(json_str_input in clob, json_str_output out clob) as
    BEGIN
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_employee(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    end get_employee;

    procedure save_approve(json_str_input in clob, json_str_output out clob) as
        json_obj       json_object_t;
        data_obj       json_object_t;
        obj_searchIndex     json_object_t;
        obj_searchParams    json_object_t;

        v_item_flgedit  varchar2(100 char);
        v_flgattend     varchar2(10 char);
        v_flgqlify      varchar2(10 char);
        v_flgSelect     varchar2(2 char);
        v_codcomp       tpotentp.codcomp%type;
        v_codpos        tpotentp.codpos%type;
        v_temp          varchar(1 char);
        v_flgAdd        boolean;
        v_flgEdit       boolean;
        v_flgDelete     boolean;

    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        obj_searchIndex  := hcm_util.get_json_t(json_obj,'searchIndex');
        obj_searchParams  := hcm_util.get_json_t(json_obj,'searchParams');
        --
        p_dteyear        := hcm_util.get_string_t(obj_searchIndex,'dteyear');
        p_codcompy       := upper(hcm_util.get_string_t(obj_searchIndex,'codcompy'));
        p_codcours       := hcm_util.get_string_t(obj_searchParams,'codcours');
        p_codcate        := hcm_util.get_string_t(obj_searchIndex,'codcate');
        p_numclseq       := hcm_util.get_string_t(obj_searchParams,'numclseq');
        --
        p_count_empappr := 0;

        for i in 0..param_json.get_size-1 loop
            data_obj        := hcm_util.get_json_t(param_json,to_char(i));
            p_codempid      := hcm_util.get_string_t(data_obj,'codempid');
            p_dteyearo      := hcm_util.get_string_t(data_obj,'dteyearn');
            p_numclseqo     := hcm_util.get_string_t(data_obj,'numclsn');
            p_dteregis      := to_date(hcm_util.get_string_t(data_obj,'dteregis'),'dd/mm/yyyy');

            p_stappr        := hcm_util.get_string_t(data_obj,'p_staappr');
            p_dteappr       := to_date(hcm_util.get_string_t(data_obj,'p_dteappr'),'dd/mm/yyyy');
            p_codappr       := hcm_util.get_string_t(data_obj,'p_codappr');
            p_numclsn       := hcm_util.get_string_t(data_obj,'p_numclseq');
            p_dteyearn      := hcm_util.get_string_t(data_obj,'p_dteyear');
            p_remarkap      := hcm_util.get_string_t(data_obj,'p_remarkap');
            p_flgwait      := hcm_util.get_string_t(data_obj,'p_flgwait');

            v_flgSelect   := hcm_util.get_string_t(data_obj,'flgSelect');
            v_flgAdd      := hcm_util.get_boolean_t(data_obj,'flgAdd');
            v_flgEdit     := hcm_util.get_boolean_t(data_obj,'flgEdit');
            v_flgDelete   := hcm_util.get_boolean_t(data_obj,'flgDelete');

            if v_flgSelect = 'Y' then
              check_approv;
            end if;
            if v_flgAdd then
                if p_stappr = 'Y' then
                    p_count_empappr := p_count_empappr + 1;
                end if;

                select count(*) into v_temp
                from tpotentp
                where dteyear = p_dteyear
                  and codcompy = p_codcompy
                  and numclseq = p_numclseq
                  and codcours = p_codcours
                  and codempid = p_codempid
                  and rownum = 1;

                if v_temp > 0 then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tpotentp');
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    rollback;
                    return;
                end if;

                begin
                    select codcomp,codpos into v_codcomp,v_codpos
                    from temploy1
                    where codempid = p_codempid;
                exception when others then
                    v_codcomp := null;
                    v_codpos  := null;
                end;

                begin
                    select stacours into p_stacours
                    from ttpotent
                    where dteyear = p_dteyear
                      and codcompy = p_codcompy
                      and codcours = p_codcours
                      and codempid = p_codempid;
                exception when no_data_found then
                    p_stacours := 'O';
                end;

                p_flgwait := 'N';
                if p_stappr = 'W' then
                    p_flgwait := 'Y';
                end if;
                begin
                    select stacours into p_stacours
                    from ttpotent
                    where dteyear = p_dteyear
                      and codcompy = p_codcompy
                      and codcours = p_codcours
                      and codempid = p_codempid;
                exception when no_data_found then
                    p_stacours := 'O';
                end;
                begin
                  select 'Y' into p_flgqlify
                    from ttpotent
                   where dteyear = p_dteyear
                     and codcompy = p_codcompy
                     and codcours = p_codcours
                     and codempid = p_codempid;
                exception when no_data_found then
                    p_flgqlify := 'N';
                end;
                insert_tpotentp(v_codcomp,v_codpos);
            elsif v_flgSelect = 'Y' then
                if p_stappr = 'Y' then
                    p_count_empappr := p_count_empappr + 1;
                end if;
                if p_stappr = 'W' then
                    update_waiting_list(v_codcomp, v_codpos);
                else
                    update_tpotentp;
                end if;
            elsif v_flgDelete then
                    delete_tpotentp;
            end if;

        end loop;

        check_approv_amount_emp;

        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_approve;

    procedure save_data(json_str_input in clob, json_str_output out clob) as
        json_obj       json_object_t;
        data_obj       json_object_t;
        obj_searchIndex     json_object_t;
        obj_searchParams    json_object_t;

        v_item_flgedit  varchar2(100 char);
        v_flgattend     varchar2(10 char);
        v_flgqlify      varchar2(10 char);
        v_flgSelect     varchar2(2 char);
        v_codcomp       tpotentp.codcomp%type;
        v_codpos        tpotentp.codpos%type;
        v_temp          varchar(1 char);
        v_flg           varchar(10 char);

    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        obj_searchIndex  := hcm_util.get_json_t(json_obj,'searchIndex');
        obj_searchParams  := hcm_util.get_json_t(json_obj,'searchParams');
        --
        p_dteyear        := hcm_util.get_string_t(obj_searchIndex,'dteyear');
        p_codcompy       := upper(hcm_util.get_string_t(obj_searchIndex,'codcompy'));
        p_codcours       := hcm_util.get_string_t(obj_searchParams,'codcours');
        p_codcate        := hcm_util.get_string_t(obj_searchIndex,'codcate');
        p_numclseq       := hcm_util.get_string_t(obj_searchParams,'numclseq');
        --
        p_count_empappr := 0;

        for i in 0..param_json.get_size-1 loop
            data_obj        := hcm_util.get_json_t(param_json,to_char(i));
            p_codempid      := hcm_util.get_string_t(data_obj,'codempid');
            p_dteyearn      := hcm_util.get_string_t(data_obj,'dteyearn');
            p_numclsn       := hcm_util.get_string_t(data_obj,'numclsn');
            p_dteregis      := to_date(hcm_util.get_string_t(data_obj,'dteregis'),'dd/mm/yyyy');
            p_stappr        := hcm_util.get_string_t(data_obj,'staappr');
            p_dteappr       := to_date(hcm_util.get_string_t(data_obj,'dteappr'),'dd/mm/yyyy');
            p_codappr       := hcm_util.get_string_t(data_obj,'p_codappr');

            v_flg      := hcm_util.get_string_t(data_obj,'flg');

            if v_flg = 'add' then
                p_count_empappr := p_count_empappr + 1;

                select count(*) into v_temp
                from tpotentp
                where dteyear = p_dteyear
                  and codcompy = p_codcompy
                  and codcours = p_codcours
                  and codempid = p_codempid;

                if v_temp > 0 then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tpotentp');
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    rollback;
                    return;
                end if;

                begin
                    select codcomp,codpos into v_codcomp,v_codpos
                    from temploy1
                    where codempid = p_codempid;
                exception when others then
                    v_codcomp := null;
                    v_codpos  := null;
                end;

                begin
                    select stacours into p_stacours
                    from ttpotent
                    where dteyear = p_dteyear
                      and codcompy = p_codcompy
                      and codcours = p_codcours
                      and codempid = p_codempid;
                exception when no_data_found then
                    p_stacours := 'O';
                end;
                begin
                  select 'Y' into p_flgqlify
                    from ttpotent
                   where dteyear = p_dteyear
                     and codcompy = p_codcompy
                     and codcours = p_codcours
                     and codempid = p_codempid;
                exception when no_data_found then
                    p_flgqlify := 'N';
                end;
                insert_tpotentp(v_codcomp,v_codpos);
            elsif v_flg = 'delete' then
                    delete_tpotentp;
            end if;
        end loop;

        check_approv_amount_emp;

        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_data;

    procedure get_send_mail(json_str_input in clob, json_str_output out clob) as
      BEGIN
        initial_value(json_str_input);
        check_send_mail;
        if param_msg_error is null then
            -- N = approve
            -- Y = wait
            if p_flgsendmail = 'N' then
                gen_send_mail_appr(json_str_output);
            elsif p_flgsendmail = 'Y' then
                gen_send_mail_wait(json_str_output);
            end if;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        /*if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;*/
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_send_mail;

END HRTR43E;

/

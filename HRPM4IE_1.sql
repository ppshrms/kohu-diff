--------------------------------------------------------
--  DDL for Package Body HRPM4IE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM4IE" is
-- 21/0/2023

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure vadidate_variable_getindex(json_str_input in clob) as
  chk_bool          boolean;
  v_codcomp         temploy1.codcomp%type;
  v_numlvl          temploy1.numlvl%type;
  json_obj          json_object_t;
  begin
    json_obj           := json_object_t(json_str_input);
    p_codempid         := hcm_util.get_string_t(json_obj,'psearch_codempid');

    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if (p_codempid is not null) then
        begin
            select staemp,codcomp,numlvl into v_staemp,v_codcomp,v_numlvl
              from temploy1
             where codempid = p_codempid;

            if(v_staemp = 0) then
                param_msg_error := get_error_msg_php('HR2102',global_v_lang);
                return;
            elsif(v_staemp = 9) then
                errormsg := get_msgerror('HR2101',global_v_lang);
                return;
            end if;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang);
            return;
        end;
    end if;

    if p_codempid is not null then
        chk_bool := secur_main.secur1( v_codcomp, v_numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
        if(chk_bool = false ) then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;
  end vadidate_variable_getindex;

  procedure get_index(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
  begin
    initial_value(json_str_input);
    vadidate_variable_getindex(json_str_input);
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob)as
    obj_row         json_object_t;

    v_check          varchar2(1);
    r_codempid      ttexempt.codempid%type;
    r_dteeffec      ttexempt.dteeffec%type;
    r_numexemp      ttexempt.numexemp%type;
    r_flgblist      ttexempt.flgblist%type;
    r_codexemp      ttexempt.codexemp%type;
    r_flgssm        ttexempt.flgssm%type;
    r_numlvl        ttexempt.numlvl%type;
    r_desnote       ttexempt.desnote%type;
    r_codreq        ttexempt.codreq%type;
    r_dtecreate     ttexempt.dtecreate%type;
    r_staupd        ttexempt.staupd%type;

    v_codcomp       temploy1.codcomp%type;

    cursor c_ttexempt is
        select codempid, dteeffec, numexemp, flgblist, codexemp, flgssm, numlvl, desnote, codreq, dtecreate, staupd, dteupd, coduser,
               decode(staupd,'C','Y',staupd) staupddesc
          from ttexempt
         where codempid = p_codempid
           and dteeffec = (select max(dteeffec) from ttexempt where codempid = p_codempid);

    ttexempt_rec        c_ttexempt%ROWTYPE;
    datattexempt_found  boolean := false;
    r_flgal             ttpminf.flgal%type;
    r_flgrp             ttpminf.flgrp%type;
    r_flgap             ttpminf.flgap%type;
    r_flgbf             ttpminf.flgbf%type;
    r_flgtr             ttpminf.flgtr%type;
    r_flgpy             ttpminf.flgpy%type;
    v_del               boolean := false ;

  begin
    begin
         select CODEMPID, DTEEFFEC, NUMEXEMP, FLGBLIST, CODEXEMP, FLGSSM, NUMLVL, DESNOTE, CODREQ,DTECREATE, STAUPD
           into r_codempid, r_dteeffec, r_numexemp, r_flgblist, r_codexemp, r_flgssm, r_numlvl, r_desnote, r_codreq, r_dtecreate, r_staupd
           from ttexempt
          where codempid = p_codempid
            and dteeffec = (select max(dteeffec) from ttexempt where codempid = p_codempid);
          datattexempt_found := true;
    exception when no_data_found then
        datattexempt_found := false;
    end;
--<<26/10/2021 11:00
begin
      select 'Y'  into v_check
      from temploy1
      where codempid = p_codempid
      and dteeffex is null;
      if  r_staupd  = 'U' then
          datattexempt_found := false;
      end if;
      exception when no_data_found then
         null;
end;    
-->>26/10/2021 11:00

    obj_row := json_object_t();

    if (datattexempt_found) then
        if upper(r_staupd) in ('U','A') then
          FOR ttexempt_rec IN c_ttexempt LOOP
               obj_row.put('dteupd', TO_CHAR(ttexempt_rec.dteupd,'DD/MM/YYYY'));
               obj_row.put('codempid',ttexempt_rec.codempid);
               obj_row.put('dteeffec', TO_CHAR(ttexempt_rec.dteeffec,'DD/MM/YYYY'));
               obj_row.put('dteeffec_o', TO_CHAR(ttexempt_rec.dteeffec,'DD/MM/YYYY'));
               obj_row.put('numexemp',ttexempt_rec.numexemp);
               obj_row.put('flgblist',ttexempt_rec.flgblist);
               obj_row.put('codexemp',ttexempt_rec.codexemp);
               obj_row.put('flgssm',ttexempt_rec.flgssm);
               obj_row.put('numlvl',ttexempt_rec.numlvl);
               obj_row.put('desnote',ttexempt_rec.desnote);
               obj_row.put('codreq',ttexempt_rec.codreq);
               obj_row.put('dtecreate',TO_CHAR(ttexempt_rec.dtecreate,'DD/MM/YYYY'));
               obj_row.put('staupd',ttexempt_rec.staupd);
               obj_row.put('disableinput',true);
               obj_row.put('disablebtndelete',true);
               obj_row.put('disablebtnsave',true);
               obj_row.put('disablebtnsaveandcontinue',true);
               obj_row.put('desc_codreq',get_temploy_name(ttexempt_rec.codreq,global_v_lang));
               obj_row.put('updatebycodempid',get_codempid(ttexempt_rec.coduser));
               obj_row.put('updatebycodempname',get_format_updatebycodempname(ttexempt_rec.coduser,global_v_lang));
               obj_row.put('coderror','200');
               obj_row.put('response','');
               if upper(r_staupd) in ('U') then
                obj_row.put('disablebtnsendmail',true);
                obj_row.put('error',get_error_choose(errormsg,'HR1505',global_v_lang));
               else
                obj_row.put('error',get_error_choose(errormsg,'HR1500',global_v_lang));
                obj_row.put('disablebtnsendmail',false);
               end if;
               obj_row.put('staupd_desc', get_tlistval_name('STAAPPR', ttexempt_rec.staupddesc, global_v_lang));
          END LOOP;
        elsif (upper(r_staupd) = 'C') then
            begin
                select flgal,flgrp,flgap,
                       flgbf,flgtr,flgpy
                  into r_flgal,r_flgrp,r_flgap,
                       r_flgbf,r_flgtr,r_flgpy
                  from ttpminf
                 where codempid = p_codempid
                   and dteeffec = r_dteeffec
                   and codtrn = '0006'
                   and numseq = 1;

                if nvl(r_flgal,'N') = 'N'
                    and nvl(r_flgrp,'N') = 'N'
                    and nvl(r_flgap,'N') = 'N'
                    and nvl(r_flgbf,'N') = 'N'
                    and nvl(r_flgtr,'N') = 'N'
                    and nvl(r_flgpy,'N') = 'N' then
                    v_del := true;
                end if;
            exception when others then
                v_del 	   := true;
            end;

            if not v_del then
                obj_row.put('error',get_error_choose(errormsg,'HR1505',global_v_lang));
                obj_row.put('disablebtndelete',true);
            else
                obj_row.put('error',get_error_choose(errormsg,'',global_v_lang));
                obj_row.put('disablebtndelete',false);
            end if;

            obj_row.put('disablebtndelete',true);
            obj_row.put('disableinput',true);
            obj_row.put('disablebtnsave',true);
            obj_row.put('disablebtnsaveandcontinue',true);
            obj_row.put('disablebtnsendmail',true);

            FOR  ttexempt_rec IN c_ttexempt LOOP
               obj_row.put('dteupd', TO_CHAR(ttexempt_rec.dteupd,'DD/MM/YYYY'));
               obj_row.put('codempid',ttexempt_rec.codempid);
               obj_row.put('dteeffec',to_char(ttexempt_rec.dteeffec,'dd/mm/yyyy'));
               obj_row.put('dteeffec_o',to_char(ttexempt_rec.dteeffec,'dd/mm/yyyy'));
               obj_row.put('numexemp',ttexempt_rec.numexemp);
               obj_row.put('flgblist',ttexempt_rec.flgblist);
               obj_row.put('codexemp',ttexempt_rec.codexemp);
               obj_row.put('flgssm',ttexempt_rec.flgssm);
               obj_row.put('numlvl',ttexempt_rec.numlvl);
               obj_row.put('desnote',ttexempt_rec.desnote);
               obj_row.put('codreq',ttexempt_rec.codreq);
               obj_row.put('dtecreate',to_char(ttexempt_rec.dtecreate,'dd/mm/yyyy'));
               obj_row.put('staupd',ttexempt_rec.staupd);
               obj_row.put('desc_codreq',get_temploy_name(ttexempt_rec.codreq,global_v_lang));
               obj_row.put('updatebycodempid',get_codempid(ttexempt_rec.coduser));
               obj_row.put('updatebycodempname',get_format_updatebycodempname(ttexempt_rec.coduser,global_v_lang));
               obj_row.put('coderror','200');
               obj_row.put('response','');
               obj_row.put('staupd_desc', get_tlistval_name('STAAPPR', ttexempt_rec.staupddesc, global_v_lang));
            END LOOP;
        elsif (upper(r_staupd) in ('P','N')) then
            if (upper(r_staupd) = 'P') then
                obj_row.put('error',get_error_choose(errormsg,'',global_v_lang));
                obj_row.put('disableinput',false);
                obj_row.put('disablebtndelete',false);
                obj_row.put('disablebtnsave',false);
                obj_row.put('disablebtnsaveandcontinue',false);
                obj_row.put('disablebtnsendmail',false);
            else
--                obj_row.put('error',get_error_choose(errormsg,'HR1500',global_v_lang));
--              redmine :4449#705 Adisak
                obj_row.put('disablebtndelete',false);            -- before true
                obj_row.put('disableinput',false);                -- before true
                obj_row.put('disablebtnsave',false);              -- before true
                obj_row.put('disablebtnsaveandcontinue',false);   -- before true
                obj_row.put('disablebtnsendmail',true);
            end if;

           FOR  ttexempt_rec IN c_ttexempt LOOP
               obj_row.put('dteupd', TO_CHAR(ttexempt_rec.dteupd,'DD/MM/YYYY'));
               obj_row.put('codempid',ttexempt_rec.codempid);
               obj_row.put('dteeffec',TO_CHAR(ttexempt_rec.dteeffec,'DD/MM/YYYY'));
               obj_row.put('dteeffec_o',TO_CHAR(ttexempt_rec.dteeffec,'DD/MM/YYYY'));
               obj_row.put('numexemp',ttexempt_rec.numexemp);
               obj_row.put('flgblist',ttexempt_rec.flgblist);
               obj_row.put('codexemp',ttexempt_rec.codexemp);
               obj_row.put('flgssm',ttexempt_rec.flgssm);
               obj_row.put('numlvl',ttexempt_rec.numlvl);
               obj_row.put('desnote',ttexempt_rec.desnote);
               obj_row.put('codreq',ttexempt_rec.codreq);
               obj_row.put('dtecreate',to_char(ttexempt_rec.dtecreate,'DD/MM/YYYY'));
               obj_row.put('staupd',ttexempt_rec.staupd);
               obj_row.put('desc_codreq',get_temploy_name(ttexempt_rec.codreq,global_v_lang));
               obj_row.put('updatebycodempid',get_codempid(ttexempt_rec.coduser));
               obj_row.put('updatebycodempname',get_format_updatebycodempname(ttexempt_rec.coduser,global_v_lang));
               obj_row.put('coderror','200');
               obj_row.put('response','');
               obj_row.put('staupd_desc', get_tlistval_name('STAAPPR', ttexempt_rec.staupddesc, global_v_lang));
            END LOOP;
        end if;
    else
        -- Data Not Found
        obj_row.put('dteupd','' );
        obj_row.put('codempid',p_codempid);
        obj_row.put('updatebycodempid','');
        obj_row.put('updatebycodempname','');
        obj_row.put('dteeffec',to_char(sysdate,'DD/MM/YYYY'));
        obj_row.put('dteeffec_o',to_char(sysdate,'DD/MM/YYYY'));
        obj_row.put('numexemp','');
        obj_row.put('flgblist','');
        obj_row.put('codexemp','');
        obj_row.put('flgssm','');
        obj_row.put('numlvl','');
        obj_row.put('desnote','');
        obj_row.put('codreq',global_v_codempid);
        obj_row.put('dtecreate',to_char(sysdate,'DD/MM/YYYY'));
        obj_row.put('staupd','P');
        obj_row.put('desc_codreq','');
        obj_row.put('disableinput',false);
        obj_row.put('disablebtndelete',true);
        obj_row.put('disablebtnsave',false);
        obj_row.put('disablebtnsaveandcontinue',false);
        obj_row.put('disablebtnsendmail',true);
        obj_row.put('error',get_error_choose(errormsg,'',global_v_lang));
        obj_row.put('coderror','200');
        obj_row.put('response','');
    end if;

    begin
        select codcomp into v_codcomp
          from temploy1
         where codempid = p_codempid;
    exception when no_data_found then
        v_codcomp := null;
    end;

    obj_row.put('codcomp',v_codcomp);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

    procedure post_save (json_str_input in clob, json_str_output out clob) is
        begin
            initial_value(json_str_input);
            validate_post_save(json_str_input);
            if param_msg_error is null then
                save_data_main;
            end if;
                json_str_output := get_response_message(null, param_msg_error, global_v_lang);

      exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      end post_save;

      procedure validate_post_save(json_str_input in clob) is
        json_obj json_object_t;
        count_tcodexem      number := 0;
        count_emp           number := 0;
        v_staemp            temploy1.staemp%TYPE;
        v_staupd            ttexempt.staupd%TYPE;
        v_dteeffec          ttexempt.dteeffec%TYPE;
        date_start          date;

        v_checkapp          boolean := false;
        v_check             varchar2(500 char);

        v_approvno          ttexempt.approvno%type;
      begin
            json_obj                := json_object_t(json_str_input);
            p_detail                := hcm_util.get_string_t(json_obj, 'detail');
            obj_detail              := json_object_t(p_detail);

            p_codempid              := hcm_util.get_string_t(obj_detail, 'codempid');
            p_dteeffec              := to_date(hcm_util.get_string_t(obj_detail, 'dteeffec'), 'dd/mm/yyyy');
            p_dteeffec_o            := nvl(to_date(hcm_util.get_string_t(obj_detail, 'dteeffec_o'), 'dd/mm/yyyy'),p_dteeffec);
            p_codexemp              := hcm_util.get_string_t(obj_detail, 'codexemp');
            p_numexemp              := hcm_util.get_string_t(obj_detail, 'numexemp');
            p_desnote               := hcm_util.get_string_t(obj_detail, 'desnote');
            p_flgblist              := hcm_util.get_string_t(obj_detail, 'flgblist');
            p_flgssm                := hcm_util.get_string_t(obj_detail, 'flgssm');
            p_dteinput              := to_date(hcm_util.get_string_t(obj_detail, 'dteinput'), 'dd/mm/yyyy');
            p_codreq                := hcm_util.get_string_t(obj_detail, 'codreq');
            p_staupd                := hcm_util.get_string_t(obj_detail, 'staupd');

            begin
                select dteempmt into date_start
                from temploy1
                where codempid = p_codempid;
                exception when no_data_found then
                    date_start := null;
            end;

            if date_start > p_dteeffec then
                param_msg_error := get_error_msg_php('PM0035',global_v_lang);
            end if;

            if p_dteeffec is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;

            if p_flgblist is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;

            if p_codexemp is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;

            if p_flgssm is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;

            if p_codempid is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;

            if p_flgssm is not null then

            begin
                select count(*) into count_tcodexem
                from    tcodexem
                where codcodec = p_codexemp
                  and flgact = '1';--User37 #1811 Final Test Phase 1 V11 28/01/2020
                if count_tcodexem = 0 then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEXEM');
                end if;
            end;
            end if;

            begin
                select count(*) into count_emp
                from temploy1
                where codempid = p_codempid;
                if (count_emp = 0) then
                  param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                end if;
                exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            end;

            begin
                select staupd,dteeffec into v_staupd,v_dteeffec
                from ttexempt
                where codempid = p_codempid
                and staupd = 'U'
                and dteeffec = (select max(dteeffec)
                                from ttexempt
                                where codempid = p_codempid
                                and staupd = 'U');
             exception when no_data_found then v_staupd := null;
            end;

            if v_staupd is not null then
                if v_staupd <> 'P' and v_dteeffec = p_dteeffec then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang);
                elsif v_staupd <> 'P' and v_dteeffec >= p_dteeffec then
                    param_msg_error := get_error_msg_php('PM0035',global_v_lang);
                end if;
            end if;

            if (p_codreq is not null) then
            begin
               select staemp into v_staemp
                from temploy1
               where codempid = p_codreq;
               if(v_staemp = 0) then
                param_msg_error := get_error_msg_php('HR2102',global_v_lang,'TEMPLOY1');
                return;
                elsif(v_staemp = 9) then
                param_msg_error := get_error_msg_php('HR2101',global_v_lang,'TEMPLOY1');
                return;
               end if;
            exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
              return;
            end;

          v_approvno := 1;
          v_checkapp := chk_flowmail.check_approve ('HRPM4IE', p_codempid, v_approvno, global_v_codempid, null, null, v_check);
          IF NOT v_checkapp AND v_check = 'HR2010' THEN
            param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tfwmailc');
            return;
          END IF;
        end if;

      end validate_post_save;

      procedure save_data_main is
        count_ttexempt  number := 0;
        count_ttexemptn number := 0;
        iv_codempid     temploy1.codempid%type;
        iv_codcomp      temploy1.codcomp%type;
        iv_codjob       temploy1.codjob%type;
        iv_codpos       temploy1.codpos%type;
        iv_codempmt     temploy1.codempmt%type;
        iv_numlvl       temploy1.numlvl%type;
        iv_jobgrade     temploy1.jobgrade%type;
        iv_codgrpgl     temploy1.codgrpgl%type;
        iv_staappr      temploy1.staappr%type;
        iv_codsex       temploy1.codsex%type;
        iv_codedlv      temploy1.codedlv%type;
        iv_dteappr      temploy1.dteappr%type;
        iv_remarkap     temploy1.remarkap%type;

        v_codcomp       temploy1.codcomp%type;
        v_codjob        temploy1.codjob%type;
        v_codpos        temploy1.codpos%type;
        v_codempmt      temploy1.codempmt%type;
        v_numlvl        temploy1.numlvl%type;
--#3751
        v_jobgrade      temploy1.jobgrade%type;
        v_codgrpgl      temploy1.codgrpgl%type;
--#3751
        ttexempt_codsex temploy1.codsex%type;
        ttexempt_codedlv temploy1.codedlv%type;
        count_totwkday  number;

        v_AMTSALT       number;
        v_amtotht       number;

        begin
--          v_totwkday := ttmistk.dteeffec - temploy1.dteempmt + nvl(temploy1.qtywkday,0); --อายุงาน service year
            begin
                select count(*) into count_ttexempt
                from ttexempt
                where dteeffec = p_dteeffec_o
                and codempid = p_codempid;
            exception when others then
                param_msg_error := dbms_utility.format_error_stack  ||' '||dbms_utility.format_error_backtrace;
                return;
            end;

            begin
                select count(*) into count_ttexemptn
                from ttexempt
                where dteeffec = p_dteeffec
                and codempid = p_codempid;
            exception when others then
                param_msg_error := dbms_utility.format_error_stack  ||' '||dbms_utility.format_error_backtrace;
                return;
            end;

            begin
                select codcomp,codjob,codpos,codempmt,numlvl,
--#3751
                       jobgrade, codgrpgl
--#3751
                into v_codcomp,v_codjob,v_codpos,v_codempmt,v_numlvl,
--#3751
                     v_jobgrade, v_codgrpgl
--#3751
                from temploy1
                where codempid = p_codempid;
            end;

            begin
                select nvl(stddec(amtincom1,codempid,v_chken),0),
                       nvl(stddec(amtincom2,codempid,v_chken),0) + nvl(stddec(amtincom3,codempid,v_chken),0) + 
                       nvl(stddec(amtincom4,codempid,v_chken),0) + nvl(stddec(amtincom5,codempid,v_chken),0) + 
                       nvl(stddec(amtincom6,codempid,v_chken),0) + nvl(stddec(amtincom7,codempid,v_chken),0) + 
                       nvl(stddec(amtincom8,codempid,v_chken),0) + nvl(stddec(amtincom9,codempid,v_chken),0) + 
                       nvl(stddec(amtincom10,codempid,v_chken),0)
                into v_AMTSALT ,v_amtotht 
                from temploy3
                where codempid = p_codempid;
            --> Peerasak || SEA-HR2201 || 02022023
            exception when no_data_found then
              v_amtsalt := 0;
              v_amtotht := 0;
            --> Peerasak || SEA-HR2201 || 02022023                
            end;

            if (count_ttexempt = 0 and count_ttexemptn = 0) then
              begin
              select codsex,codedlv into ttexempt_codsex,ttexempt_codedlv
              from temploy1
              where codempid = p_codempid;
              exception when no_data_found then
                ttexempt_codsex := null;
                ttexempt_codedlv := null;
              end;
              begin
                select p_dteeffec - temploy1.dteempmt + nvl(temploy1.qtywkday,0)
                  into count_totwkday
                  from temploy1
                 where temploy1.codempid = p_codempid;
              end;
              begin

              insert into ttexempt(totwkday,codsex,codedlv,codempid, dteeffec, codcomp, codjob, codpos, codempmt, codexemp, numlvl, numexemp, desnote, flgblist, flgssm,
                                   codreq, staupd, dtecreate, codcreate, coduser,
--#3751
                                   jobgrade, codgrpgl, dteinput ,

                                   AMTSALT ,amtotht 
--#3751
                             )
              values (count_totwkday,ttexempt_codsex,ttexempt_codedlv,p_codempid, p_dteeffec, v_codcomp, v_codjob, v_codpos, v_codempmt, p_codexemp, v_numlvl, p_numexemp, p_desnote, p_flgblist, p_flgssm,
                      p_codreq, p_staupd ,sysdate/*p_dteinput*/, global_v_coduser,global_v_coduser,
--#3751
                      v_jobgrade, v_codgrpgl, sysdate,

                      stdenc(v_AMTSALT,p_codempid,v_chken) ,stdenc(v_amtotht,p_codempid,v_chken) 
--#3751
                             );
              commit;

              exception when others then
                rollback;
                param_msg_error := dbms_utility.format_error_stack  ||' '||dbms_utility.format_error_backtrace;
                return;
              end;
            else
              begin
                select codsex,codedlv
                  into ttexempt_codsex,ttexempt_codedlv
                  from temploy1
                 where codempid = p_codempid;
              exception when no_data_found then
                ttexempt_codsex := null;
                ttexempt_codedlv := null;
              end;
              begin
                select p_dteeffec - temploy1.dteempmt + nvl(temploy1.qtywkday,0)
                  into count_totwkday
                  from temploy1
                 where temploy1.codempid = p_codempid;
              end;
              begin
                if p_staupd = 'N' then
                  p_staupd := 'P';
                end if;
                update ttexempt
                    set codsex = ttexempt_codsex,
                        codedlv = ttexempt_codedlv,
                        totwkday = count_totwkday,
                        numexemp = p_numexemp,
                        desnote  = p_desnote,
                        codexemp = p_codexemp,
                        flgblist = p_flgblist,
                        flgssm = p_flgssm,
                        codcomp = v_codcomp,
                        codjob = v_codjob,
                        codpos = v_codpos,
                        codempmt = v_codempmt,
                        numlvl = v_numlvl,
                        codreq = p_codreq,
                        dteeffec = p_dteeffec,
--#3751
                        jobgrade = v_jobgrade,
                        codgrpgl = v_codgrpgl,
--#3751
                        dteupd = sysdate,
                        coduser = global_v_coduser,
-- redmine:4449 705 Adisak
                        staupd = p_staupd,
-- end
                        AMTSALT = stdenc(v_AMTSALT,p_codempid,v_chken) ,
                        amtotht = stdenc(v_amtotht,p_codempid,v_chken)
                  where dteeffec = p_dteeffec_o
                    and codempid = p_codempid;
                commit;
                exception when others then
                    rollback;
                    param_msg_error := dbms_utility.format_error_stack  ||' '||dbms_utility.format_error_backtrace;
                return;
             end;
            end if;

        param_msg_error := get_error_msg_php('HR2401', global_v_lang);

        exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    end save_data_main;


    procedure post_deldata(json_str_input in clob,json_str_output out clob) as
    begin
       initial_value(json_str_input);
       validate_deldata(json_str_input);

            if (param_msg_error <> ' ' or param_msg_error is not null) then
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            else
                deldata(json_str_output);
            end if;
       exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end post_deldata;

    procedure validate_deldata(json_str_input in clob) as
    objJson json_object_t;
    p_dteeffec_str varchar (20 char);
     begin

       objJson          := json_object_t(json_str_input);
       p_codempid       := hcm_util.get_string_t(objJson,'psearch_codempid');
       p_dteeffec_str   := hcm_util.get_string_t(objJson,'psearch_dteeffec');

       if (p_codempid is null or p_codempid = ' ') then
              param_msg_error := get_error_msg_php('HR2045',global_v_lang);
       end if;

       if (p_dteeffec_str is null or p_dteeffec_str = ' ' ) then
             param_msg_error := get_error_msg_php('HR2045',global_v_lang);
       end if;

        begin
            p_dteeffec := to_date(trim(p_dteeffec_str), 'dd/mm/yyyy');
        exception
            when others then
              param_msg_error := get_error_msg_php('HR2045', global_v_lang);
              return;
        end;

    end validate_deldata;

    procedure deldata(json_str_output out clob) as
    begin
          begin
            delete from ttexempt where CODEMPID = p_codempid and DTEEFFEC = p_dteeffec;
              commit;
                    param_msg_error := get_error_msg_php('HR2401', global_v_lang);
                    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            exception  when others then
                param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
                json_str_output := get_response_message('400', param_msg_error, global_v_lang);
          end;
    end deldata;

     procedure post_send_mail(json_str_input in clob, json_str_output out clob) as
      begin
         initial_value(json_str_input);
         validate_send_mail(json_str_input);
         if (param_msg_error <> ' ' or param_msg_error is not null) then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
         else
            send_mail(json_str_input,json_str_output);
         end if;
     end post_send_mail;

    procedure validate_send_mail(json_str_input in clob) as
        objJson json_object_t;
    begin
        objJson      := json_object_t(json_str_input);
        p_codempid   := hcm_util.get_string_t(objJson,'psearch_codempid');
        p_codreq     := hcm_util.get_string_t(objJson,'psearch_codreq');

        begin
            select rowId into v_rowid
              from ttexempt
             where codempid = p_codempid
               and dteeffec = (select max(dteeffec) from ttexempt where codempid = p_codempid);
        exception when no_data_found then
            v_rowid := null;
        end;

        if v_rowid  is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_codempid is null or  p_codempid= ' ' then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_codreq is null or p_codreq = ' '  then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end validate_send_mail;

   procedure send_mail( json_str_input in clob,json_str_output out clob) as
       v_codfrm_to      tfwmailh.codform%TYPE;
       v_msg_to         clob;
       v_template_to    clob;
       v_func_appr      tfwmailh.codappap%type;
       v_error          varchar2(10 char);
       v_approvno       ttexempt.approvno%type;
   begin
        begin
            select nvl(approvno,0) + 1
              into v_approvno
              from ttexempt
             where rowid = v_rowid;
        exception when no_data_found then
            v_approvno := 1;
        end;

        begin
            v_error := chk_flowmail.send_mail_for_approve('HRPM4IE', p_codempid, p_codreq, global_v_coduser, null, 'HRPM44U1', 960, 'E', 'P', v_approvno, null, null,'TTEXEMPT',v_rowid, '1', null);
        exception when others then
            v_error := 'HR7522';
        end;

        IF v_error = '2046' THEN
            v_error := 'HR2046';
        ELSIF v_error = '7526'   then
            v_error := 'HR7526';
        ELSE
            v_error := 'HR7522';
        END IF;  

        param_msg_error := get_error_msg_php(v_error, global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
   end send_mail;

  function get_msgerror(v_errorno in varchar2, v_lang in varchar2) return varchar2 is
    v_descripe terrorm.descripe%type;
  begin
            begin
                     SELECT decode(v_lang  ,
                                    '101',descripe,
   	                                '102',descript,
   	                                '103',descrip3,
   	                                '104',descrip4,
   	                                '105',descrip5,descripe)
                        into   v_descripe
                        from terrorm
                        where errorno = v_errorno;
               return v_errorno||' '||v_descripe;
           exception
            when no_data_found then
               return '';
           when others then
               return '';
          end;
  end get_msgerror;

function get_format_updatebycodempname (v_coduser in varchar2 , v_lang in varchar2) return  varchar2 is
begin
          return v_coduser || ' - '||get_temploy_name(get_codempid(v_coduser),v_lang);
end get_format_updatebycodempname;

  function get_error_choose(v_error_2101 in varchar2,v_push_error in varchar2,v_lang in varchar2)  return varchar2 is
  begin
           if (v_error_2101 is not null or length (trim(v_error_2101)) > 0 ) then
                       return v_error_2101;
           else
                         if (v_push_error  is not null  or length (trim(v_push_error)) > 0  ) then
                               return get_msgerror(v_push_error,v_lang);
                        else
                             return v_push_error;
                         end if;
         end if;
  end;

end HRPM4IE;

/

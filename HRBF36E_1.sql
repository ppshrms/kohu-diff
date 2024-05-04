--------------------------------------------------------
--  DDL for Package Body HRBF36E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF36E" AS
  procedure initial_value(json_str_input in clob) as
   json_obj json_object_t;
  begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codcomp          := hcm_util.get_string_t(json_obj,'p_codcomp');
        p_query_codempid   := hcm_util.get_string_t(json_obj,'p_codempid_query');
        p_numisr           := hcm_util.get_string_t(json_obj,'p_numisr');
        p_dtechng          := to_date(hcm_util.get_string_t(json_obj,'p_dtechng'),'dd/mm/yyyy');
        p_dteeffec         := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');

        p_codisrp          := hcm_util.get_string_t(json_obj,'p_codisrp');
        p_typecal          := hcm_util.get_string_t(json_obj,'p_typecal'); -- E,F
        p_flgisr           := hcm_util.get_string_t(json_obj,'p_flgisr');
        p_numfamily        := to_number(hcm_util.get_string_t(json_obj,'p_numfamily'));

        if p_dtechng is null then
          begin
            select nvl(max(dtechng),sysdate),nvl(max(dteeffec),sysdate) into p_dtechng,p_dteeffec
              from tchgins1
             where codempid = p_query_codempid
               and numisr = p_numisr;
          exception when no_data_found then
            p_dtechng := sysdate;
          end;
        end if;
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
    v_temp      varchar(1 char);
    v_staemp    temploy1.staemp%type;
    v_codcomp    temploy1.codcomp%type;
  begin
    if p_query_codempid is not null then
        begin
            select staemp,codcomp into v_staemp,v_codcomp
            from temploy1
            where codempid = p_query_codempid;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            return;
        end;

    --  check employee status
        if v_staemp = '0' then
            param_msg_error := get_error_msg_php('HR2102',global_v_lang);
            return;
        end if;
--  check secur2
        if secur_main.secur2(p_query_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;

    if p_codcomp is not null then
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp || '%'
              and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
            return;
        end;

--  check secur2
        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;
    if p_numisr is not null then
        if p_codcomp is not null then
          v_codcomp := p_codcomp;
        end if;
        begin
            select 'X' into v_temp
            from tisrinf
            where numisr = p_numisr
            and codcompy = nvl(hcm_util.get_codcomp_level(v_codcomp,1),codcompy);
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TISRINF');
            return;
        end;
    end if;
  end check_index;

  procedure check_detail as
    v_temp     varchar(1 char);
  begin
--    if p_query_codempid is null or p_numisr is null or p_dtechng is null or p_dteeffec is null then
    if p_query_codempid is null or p_numisr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
  end check_detail;

  procedure check_tab1 as
    v_temp      varchar(1 char);
    v_count     number;
    v_staemp    temploy1.staemp%type;
    v_codcomp   temploy1.codcomp%type;
    v_dtehlpst  tisrinf.dtehlpst%type;
    v_dtehlpen  tisrinf.dtehlpen%type;
  begin
    if p_codisrp is null or p_dtehlpst is null or p_dtehlpen is null or p_amtisrp is null or
       p_codecov is null or p_codfcov is null or p_codedit is null or p_dteedit is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
--  check codisrp in tcodisrp
    begin
        select 'X' into v_temp
        from tcodisrp
        where codcodec = p_codisrpo;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODISRP');
        return;
    end;
--  check codisrp in tisrpinf
    begin
        select 'X' into v_temp
        from tisrpinf
        where numisr = p_numisr
          and codisrp = p_codisrp;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TISRPINF');
        return;
    end;

    begin
        select 'X' into v_temp
          from tinsrer
         where codempid = p_query_codempid
           and numisr = p_numisr;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TINSRER');
        return;
    end;

--  check date
    if p_dtehlpst > p_dtehlpen then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

    if p_flgcodcov <> 'E' then--User37 #6784 06/09/2021
        select count(*) into v_count
          from tspouse
         where codempid = p_query_codempid;
        if v_count = 0 then
          select count(*) into v_count
            from tchildrn
           where codempid = p_query_codempid;
          if v_count = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSPOUSE');
          end if;
        end if;
    end if;

--  check codedit
    begin
        select 'X',staemp into v_temp,v_staemp
        from temploy1
        where codempid = p_codedit;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
    end;

--  check secur2
    if secur_main.secur2(p_codedit,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

--  check employee status
    if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
    elsif v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
    end if;
    begin
      select dtehlpst, dtehlpen into v_dtehlpst, v_dtehlpen
        from tisrinf
       where numisr = p_numisr;
    exception when no_data_found then
      v_dtehlpst  :=  '';
      v_dtehlpen  :=  '';
    end;
    if not ((p_dtehlpst between v_dtehlpst and v_dtehlpen) and (p_dtehlpen between v_dtehlpst and v_dtehlpen)) then
      param_msg_error := get_error_msg_php('BF0051',global_v_lang);
      return;
    end if;
  end check_tab1;

  procedure check_tab2 as
  begin
    if p_nameinsr is not null and p_flgchng is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
  end check_tab2;

  procedure check_tab3 as
  begin
    if p_nambfisr is not null and p_flgchng is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
    return;
    end if;
  end;

  procedure gen_index(json_str_output out clob) as
    obj_data        json_object_t;
    obj_rows        json_object_t;
    v_row           number := 0;
    v_chk_secur     boolean := false;
    v_count         number := 0;
    v_count_secur   number := 0;
    cursor c1 is
        select codcomp,codempid,codisrp,codecov,codfcov, numisr
        from tinsrer
        where codcomp like p_codcomp || '%'
          and codempid = nvl(p_query_codempid,codempid)
          and numisr = nvl(p_numisr, numisr)
          and flgemp = '1'
        order by codempid;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_count := v_count + 1;
        v_chk_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_chk_secur then
            v_count_secur := v_count_secur + 1;
            v_row := v_row + 1;
            obj_data  := json_object_t();
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('codisrp',i.codisrp);
            obj_data.put('desc_codisrp',get_tcodec_name('TCODISRP',i.codisrp,global_v_lang));
            obj_data.put('codecov',i.codecov);
            obj_data.put('codfcov',i.codfcov);
            if i.codecov = 'Y' then
              obj_data.put('desc_codfcov',get_label_name('HRBF36EP2',global_v_lang,160));
            end if;
            if i.codfcov = 'Y' then
              obj_data.put('desc_codfcov',get_label_name('HRBF36EP2',global_v_lang,170));
            end if;
            obj_data.put('numisr',i.numisr);
            obj_data.put('dtechng',to_char(p_dtechng,'dd/mm/yyyy'));
            obj_data.put('dteeffec',to_char(p_dteeffec,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TINSRER');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    if v_count_secur = 0 and v_count != 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    else
        json_str_output := obj_rows.to_clob;
    end if;

  end gen_index;

  procedure gen_detail_tab1(json_str_output out clob) as
    obj_data        json_object_t;
    v_tinsrer       tinsrer%rowtype;
    v_tchgins1      tchgins1%rowtype;
    v_flgisr        tisrinf.flgisr%type;
    v_amtpmiummt    tisrpre.amtpmiummt%TYPE;
    v_amtpmiumyr    tisrpre.amtpmiumyr%TYPE;
    v_pctpmium      tisrpre.pctpmium%TYPE;
    v_amtfamilyo    number := 0;
    v_amtfamily     number := 0;
    v_amtpmiummo    number := 0;
    v_amtpmiumm     number := 0;
    v_amtpmiumeo    number := 0;
    v_amtpmiumco    number := 0;
    v_flgExist      varchar2(1 char) := '';
    v_response      varchar2(4000 char) := '';
    v_codempid      temploy1.codempid%type;
    v_msg_error     varchar2(4000 char);
  begin
   begin
        select * into v_tinsrer
          from tinsrer
         where codempid = p_query_codempid
           and numisr = p_numisr;
    exception when no_data_found then
        v_tinsrer := null;
    end;
    begin
      select * into v_tchgins1
        from tchgins1
       where codempid = p_query_codempid
         and numisr = p_numisr
         and dtechng = p_dtechng;
      v_flgExist := 'Y';
    exception when no_data_found then
        v_flgExist := 'N';
        v_tchgins1 := null;
    end;
    begin
        select count(*) into v_amtfamilyo
          from tinsrdp
         where codempid = p_query_codempid
           and numisr = p_numisr;
    end;
    begin
        select count(*) into v_amtfamily
          from tchgins2
         where codempid = p_query_codempid
         and numisr = p_numisr
         and dtechng = p_dtechng;
    end;
    --
    begin
        select flgisr into v_flgisr
        from tisrinf
        where numisr = p_numisr;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TISRINF');
      return;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror',200);
    obj_data.put('codempid',p_query_codempid);
    obj_data.put('numisr',p_numisr);
    obj_data.put('dtechng',to_char(p_dtechng,'dd/mm/yyyy'));
    obj_data.put('dteeffec',to_char(p_dteeffec,'dd/mm/yyyy'));
    if v_flgExist = 'N' then
      -- New
      obj_data.put('codisrpo',v_tinsrer.codisrp);
      obj_data.put('codisrp',v_tinsrer.codisrp);
      obj_data.put('desc_codisrp',get_tcodec_name('TCODISRP',v_tinsrer.codisrp,global_v_lang));
      obj_data.put('desc_codisrpo',get_tcodec_name('TCODISRP',v_tinsrer.codisrp,global_v_lang));
      obj_data.put('flgisr',v_tinsrer.flgisr);
      obj_data.put('flgisro',v_tinsrer.flgisr);
      obj_data.put('dtehlpst',to_char(v_tinsrer.dtehlpst,'dd/mm/yyyy'));
      obj_data.put('dtehlpsto',to_char(v_tinsrer.dtehlpst,'dd/mm/yyyy'));
      obj_data.put('dtehlpen',to_char(v_tinsrer.dtehlpen,'dd/mm/yyyy'));
      obj_data.put('dtehlpeno',to_char(v_tinsrer.dtehlpen,'dd/mm/yyyy'));
      obj_data.put('amtisrp',v_tinsrer.amtisrp);
      obj_data.put('amtisrpo',v_tinsrer.amtisrp);
      obj_data.put('codecov',v_tinsrer.codecov);
      obj_data.put('codecovo',v_tinsrer.codecov);
      obj_data.put('codfcov',v_tinsrer.codfcov);
      obj_data.put('codfcovo',v_tinsrer.codfcov);
      obj_data.put('amtfamily',v_amtfamilyo);
      obj_data.put('amtfamilyo',v_amtfamilyo);
      obj_data.put('staappr','P');
      obj_data.put('flgisr',v_tinsrer.flgisr);
      if v_tinsrer.codecov = 'Y' then
        obj_data.put('flgcodcov','E');
        obj_data.put('flgcodcovo','E');
      end if;
      if v_tinsrer.codfcov = 'Y' then
        obj_data.put('flgcodcov','F');
        obj_data.put('flgcodcovo','F');
      end if;

      begin
          select nvl(amtpmiummt,0),nvl(amtpmiumyr,0),nvl(pctpmium,0) into v_amtpmiummt,v_amtpmiumyr,v_pctpmium
          from tisrpre
          where numisr = p_numisr
              and codisrp = v_tinsrer.codisrp
              and coddepen = 'E';
      exception when no_data_found then
          v_amtpmiummt  :=  0;
          v_amtpmiumyr  :=  0;
          v_pctpmium  :=  0;
      end;
      if v_flgisr = 1 then -- 1 month
        v_amtpmiumeo     := v_amtpmiummt * (v_pctpmium/100);
        v_amtpmiumco     := v_amtpmiummt - (v_amtpmiummt * (v_pctpmium/100));

        obj_data.put('amtpmiumm',to_char(v_amtpmiummt,'fm999,999,990.90'));
        obj_data.put('amtpmiummo',to_char(v_amtpmiummt,'fm999,999,990.90'));
        obj_data.put('amtpmiumy','0.00');
        obj_data.put('amtpmiumyo','0.00');
        obj_data.put('amtpmiume',to_char(v_amtpmiumeo,'fm999,999,990.90'));
        obj_data.put('amtpmiumeo',to_char(v_amtpmiumeo,'fm999,999,990.90'));
        obj_data.put('amtpmiumc',to_char(v_amtpmiumco,'fm999,999,990.90'));
        obj_data.put('amtpmiumco',to_char(v_amtpmiumco,'fm999,999,990.90'));
      elsif v_flgisr = 4 then
        v_amtpmiumeo     := v_amtpmiumyr * (v_pctpmium/100);
        v_amtpmiumco     := v_amtpmiumyr - (v_amtpmiumyr * (v_pctpmium/100));
        obj_data.put('amtpmiumm','0.00');
        obj_data.put('amtpmiummo','0.00');
        obj_data.put('amtpmiumy',to_char(v_amtpmiumyr,'fm999,999,990.90'));
        obj_data.put('amtpmiumyo',to_char(v_amtpmiumyr,'fm999,999,990.90'));
        obj_data.put('amtpmiume',to_char(v_amtpmiumeo,'fm999,999,990.90'));
        obj_data.put('amtpmiumeo',to_char(v_amtpmiumeo,'fm999,999,990.90'));
        obj_data.put('amtpmiumc',to_char(v_amtpmiumco,'fm999,999,990.90'));
        obj_data.put('amtpmiumco',to_char(v_amtpmiumco,'fm999,999,990.90'));
      end if;
      v_codempid := get_codempid(global_v_coduser);
      obj_data.put('codedit',v_codempid);
      obj_data.put('dteedit',to_char(sysdate,'dd/mm/yyyy'));
    else
      obj_data.put('flgisr',v_tchgins1.flgisr);
      obj_data.put('codisrp',v_tchgins1.codisrp);
      obj_data.put('desc_codisrp',get_tcodec_name('TCODISRP',v_tchgins1.codisrp,global_v_lang));
      obj_data.put('codfcov',v_tchgins1.codfcov);
      obj_data.put('codecov',v_tchgins1.codecov);
      obj_data.put('dtehlpst',to_char(v_tchgins1.dtehlpst,'dd/mm/yyyy'));
      obj_data.put('dtehlpen',to_char(v_tchgins1.dtehlpen,'dd/mm/yyyy'));
      obj_data.put('amtisrp',v_tchgins1.amtisrp);
      obj_data.put('amtfamily',v_amtfamily);
      if v_tchgins1.codecov = 'Y' then
        obj_data.put('flgcodcov','E');
      end if;
      if v_tchgins1.codfcov = 'Y' then
        obj_data.put('flgcodcov','F');
      end if;
      -- Old
      obj_data.put('flgisro',v_tchgins1.flgisro);
      obj_data.put('codisrpo',v_tchgins1.codisrpo);
      obj_data.put('desc_codisrpo',get_tcodec_name('TCODISRP',v_tchgins1.codisrpo,global_v_lang));
      obj_data.put('codfcovo',v_tchgins1.codfcovo);
      obj_data.put('codecovo',v_tchgins1.codecovo);
      obj_data.put('dtehlpeno',to_char(v_tchgins1.dtehlpeno,'dd/mm/yyyy'));
      obj_data.put('dtehlpsto',to_char(v_tchgins1.dtehlpsto,'dd/mm/yyyy'));
      obj_data.put('amtisrpo',v_tchgins1.amtisrpo);
      obj_data.put('amtfamilyo',v_amtfamilyo);
      if v_tchgins1.codecovo = 'Y' then
        obj_data.put('flgcodcovo','E');
      end if;
      if v_tchgins1.codfcovo = 'Y' then
        obj_data.put('flgcodcovo','F');
      end if;
      --
      if v_tchgins1.flgisr = 1 then
        obj_data.put('amtpmiummo',to_char(nvl(v_tchgins1.amtpmiummeo,0) +  nvl(v_tchgins1.amtpmiummco,0),'fm999,999,990.90'));
        obj_data.put('amtpmiumyo','0.00');
        obj_data.put('amtpmiumeo',to_char(nvl(v_tchgins1.amtpmiummeo,0),'fm999,999,990.90'));
        obj_data.put('amtpmiumco',to_char(nvl(v_tchgins1.amtpmiummco,0),'fm999,999,990.90'));
        --
        obj_data.put('amtpmiumm',to_char(nvl(v_tchgins1.amtpmiumme,0) +  nvl(v_tchgins1.amtpmiummc,0),'fm999,999,990.90'));
        obj_data.put('amtpmiumy','0.00');
        obj_data.put('amtpmiume',to_char(nvl(v_tchgins1.amtpmiumme,0),'fm999,999,990.90'));
        obj_data.put('amtpmiumc',to_char(nvl(v_tchgins1.amtpmiummc,0),'fm999,999,990.90'));
      elsif v_tchgins1.flgisr = 4 then
        obj_data.put('amtpmiummo','0.00');
        obj_data.put('amtpmiumyo',to_char(nvl(v_tchgins1.amtpmiumyco,0) +  nvl(v_tchgins1.amtpmiumyeo,0),'fm999,999,990.90'));
        obj_data.put('amtpmiumeo',to_char(nvl(v_tchgins1.amtpmiumyeo,0),'fm999,999,990.90'));
        obj_data.put('amtpmiumco',to_char(nvl(v_tchgins1.amtpmiumyco,0),'fm999,999,990.90'));
        --
        obj_data.put('amtpmiumm','0.00');
        obj_data.put('amtpmiumy',to_char(nvl(v_tchgins1.amtpmiumyc,0) +  nvl(v_tchgins1.amtpmiumye,0),'fm999,999,990.90'));
        obj_data.put('amtpmiume',to_char(nvl(v_tchgins1.amtpmiumye,0),'fm999,999,990.90'));
        obj_data.put('amtpmiumc',to_char(nvl(v_tchgins1.amtpmiumyc,0),'fm999,999,990.90'));
      end if;
      -- bottom
      v_codempid := get_codempid(global_v_coduser);
      obj_data.put('staappr',v_tchgins1.staappr);
      obj_data.put('codedit',v_codempid);
      obj_data.put('dteedit',to_char(sysdate,'dd/mm/yyyy'));
      obj_data.put('remark',v_tchgins1.remark);
--      obj_data.put('codedit',v_tchgins1.codedit);
--      obj_data.put('dteedit',to_char(v_tchgins1.dteedit,'dd/mm/yyyy'));

      -- check can edit
      if v_tchgins1.staappr = 'A' then
        v_msg_error := get_error_msg_php('HR8011',global_v_lang);
        v_response := get_response_message(null,v_msg_error,global_v_lang);
        obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
      elsif v_tchgins1.staappr in ('Y','N') then
        v_msg_error := get_error_msg_php('HR8014',global_v_lang);
        v_response := get_response_message(null,v_msg_error,global_v_lang);
        obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
      end if;
    end if;
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end gen_detail_tab1;

  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
        gen_detail_tab1(json_str_output);
        if param_msg_error is not null then
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail_tab1;

  procedure gen_detail_tab2(json_str_output out clob) as
    obj_data        json_object_t;
    obj_rows        json_object_t;
    v_row           number := 0;
    v_chkExist      number := 0;
    v_flgExist      varchar2(1 char) := 'N';
    cursor c1 is
        select nameinsr,typrelate,dteempdb
        from tinsrdp
        where codempid = p_query_codempid
          and numisr = p_numisr
        order by numseq;

    cursor c2 is
        select numseq,nameinsr,typrelate,dteempdb,flgchng
        from tchgins2
        where codempid = p_query_codempid
          and numisr = p_numisr
          and dtechng = p_dtechng
        order by numseq;
  begin
    begin
      select 'Y' into v_flgExist
        from tchgins1
       where codempid = p_query_codempid
         and numisr = p_numisr
         and dtechng = p_dtechng;
    exception when no_data_found then
        v_flgExist := 'N';
    end;
    begin
      select count(*) into v_chkExist
        from tchgins2
        where codempid = p_query_codempid
          and numisr = p_numisr
          and dtechng = p_dtechng;
    end;
    obj_rows := json_object_t();
    if v_chkExist = 0 then
      if v_flgExist = 'N' then
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('numseq','');
            obj_data.put('nameinsr',i.nameinsr);
            obj_data.put('typrelate',i.typrelate);
            obj_data.put('typrelate_name',get_tlistval_name('TYPRELATE',i.typrelate,global_v_lang));
            obj_data.put('dteempdb',to_char(i.dteempdb,'dd/mm/yyyy'));
            obj_data.put('flgchng','');
            obj_data.put('flgAdd',true);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
      end if;
    else
      for i in c2 loop
          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('numseq',i.numseq);
          obj_data.put('nameinsr',i.nameinsr);
          obj_data.put('typrelate',i.typrelate);
          obj_data.put('typrelate_name',get_tlistval_name('TYPRELATE',i.typrelate,global_v_lang));
          obj_data.put('dteempdb',to_char(i.dteempdb,'dd/mm/yyyy'));
          obj_data.put('flgchng',i.flgchng);
          obj_rows.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end gen_detail_tab2;

  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_detail_tab2(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail_tab2;

  procedure gen_detail_tab3(json_str_output out clob) as
    obj_data        json_object_t;
    obj_rows        json_object_t;
    v_row           number := 0;
    v_chkExist      number := 0;

    cursor c1 is
        select nambfisr,typrelate,ratebf
        from tbficinf
        where codempid = p_query_codempid
          and numisr = p_numisr
        order by numseq;

    cursor c2 is
        select numseq,nambfisr,typrelate,ratebf,flgchng
        from tchgins3
        where codempid = p_query_codempid
          and numisr = p_numisr
          and dtechng = p_dtechng
        order by numseq;
  begin
    begin
        select count(*) into v_chkExist
        from tchgins3
        where codempid = p_query_codempid
          and numisr = p_numisr
          and dtechng = p_dtechng;
    end;
    obj_rows := json_object_t();
    if v_chkExist = 0 then
      for i in c1 loop
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('numseq','');
        obj_data.put('nambfisr',i.nambfisr);
        obj_data.put('typrelate',i.typrelate);
        obj_data.put('typrelate_name',get_tlistval_name('TYPRELATE',i.typrelate,global_v_lang));
        obj_data.put('ratebf',i.ratebf);
        obj_data.put('flgchng','');
        obj_data.put('flgAdd',true);
        obj_rows.put(to_char(v_row-1),obj_data);
     end loop;
    else
      for i in c2 loop
          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('numseq',i.numseq);
          obj_data.put('nambfisr',i.nambfisr);
          obj_data.put('typrelate',i.typrelate);
          obj_data.put('typrelate_name',get_tlistval_name('TYPRELATE',i.typrelate,global_v_lang));
          obj_data.put('ratebf',i.ratebf);
          obj_data.put('flgchng',i.flgchng);
          obj_rows.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end gen_detail_tab3;

  procedure get_detail_tab3(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_detail_tab3(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail_tab3;

  PROCEDURE gen_valuecal_e(json_str_output out clob) AS
      json_obj     json_object_t;

      v_amtpmiummt    tisrpre.amtpmiummt%TYPE;
      v_amtpmiumyr    tisrpre.amtpmiumyr%TYPE;
      v_pctpmium      tisrpre.pctpmium%TYPE;

      v_amtmonth      tinsrer.amtpmiumme%type;
      v_amtyear       tinsrer.amtpmiumme%type;

      v_flgisr        tisrinf.flgisr%type;
      v_amtpmiume     number;
      v_amtpmiumc     number;
      obj_data     json_object_t;
      obj_head     json_object_t;

  BEGIN
      begin
          select nvl(amtpmiummt,0),nvl(amtpmiumyr,0),nvl(pctpmium,0) into v_amtpmiummt,v_amtpmiumyr,v_pctpmium
          from tisrpre
          where numisr = p_numisr
              and codisrp = p_codisrp
              and coddepen = 'E';
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tisrpre');
      end;
      begin
        select flgisr into v_flgisr
        from tisrinf
        where numisr = p_numisr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TISRINF');
      end;

      if v_flgisr = '1' then
          v_amtmonth := v_amtpmiummt;
          v_amtyear := 0;
          v_amtpmiume :=  v_amtmonth * v_pctpmium/100;
          v_amtpmiumc := v_amtmonth - v_amtpmiume;
      elsif v_flgisr = '4' then
          v_amtmonth := 0;
          v_amtyear := v_amtpmiumyr;
          v_amtpmiume :=  v_amtyear * v_pctpmium/100;
          v_amtpmiumc := v_amtyear - v_amtpmiume;
      end if;
      obj_data := json_object_t();
      obj_data.put('coderror',200);
      obj_data.put('amtpmiumm', to_char(v_amtmonth,'fm999,999,990.90'));
      obj_data.put('amtpmiumy', to_char(v_amtyear,'fm999,999,990.90'));
      obj_data.put('amtpmiume', to_char(v_amtpmiume,'fm999,999,990.90'));
      obj_data.put('amtpmiumc', to_char(v_amtpmiumc,'fm999,999,990.90'));
      json_str_output := obj_data.to_clob;

      IF param_msg_error IS NOT NULL THEN
          json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      END IF;

  EXCEPTION WHEN OTHERS THEN
          param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  END gen_valuecal_e;

  PROCEDURE gen_valuecal_f(json_str_output out clob) AS
      obj_data          json_object_t;
      -- employee
      v_amtpmiummt    tisrpre.amtpmiummt%TYPE;
      v_amtpmiumyr    tisrpre.amtpmiumyr%TYPE;
      v_pctpmium      tisrpre.pctpmium%TYPE;

      v_amtmonth      tinsrer.amtpmiumme%type;
      v_amtyear       tinsrer.amtpmiumme%type;
      -- family
      v_amtpmiummt_f    tisrpre.amtpmiummt%TYPE;
      v_amtpmiumyr_f    tisrpre.amtpmiumyr%TYPE;
      v_pctpmium_f      tisrpre.pctpmium%TYPE;

      v_amtmonth_f      tinsrer.amtpmiumme%type;
      v_amtyear_f       tinsrer.amtpmiumme%type;

      v_flgisr          tisrinf.flgisr%type;
      v_amtpmiume       number;
      v_amtpmiumc       number;
      v_amtpmiume_f     number;
      v_amtpmiumc_f     number;
      v_count           number;

  BEGIN
      select count(*) into v_count
        from tspouse
       where codempid = p_query_codempid;
      if v_count = 0 then
        select count(*) into v_count
          from tchildrn
         where codempid = p_query_codempid;
        if v_count = 0 then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSPOUSE');
        end if;
      end if;
      -- employee
      begin
          select nvl(amtpmiummt,0),nvl(amtpmiumyr,0),nvl(pctpmium,0) into v_amtpmiummt,v_amtpmiumyr,v_pctpmium
          from tisrpre
          where numisr = p_numisr
              and codisrp = p_codisrp
              and coddepen = 'E';
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tisrpre');
      end;
      begin
        select flgisr into v_flgisr
        from tisrinf
        where numisr = p_numisr;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TISRINF');
      end;
      -- monthly
      if v_flgisr = '1' then
          v_amtmonth := v_amtpmiummt;
          v_amtyear := 0;
          v_amtpmiume :=  v_amtmonth * (v_pctpmium/100);
          v_amtpmiumc := v_amtmonth - v_amtpmiume;
      -- yearly
      elsif v_flgisr = '4' then
          v_amtmonth := 0;
          v_amtyear := v_amtpmiumyr;
          v_amtpmiume :=  v_amtyear * (v_pctpmium/100);
          v_amtpmiumc := v_amtyear - v_amtpmiume;
      end if;

      -- family
      begin
          select nvl(amtpmiummt,0),nvl(amtpmiumyr,0),nvl(pctpmium,0) into v_amtpmiummt_f,v_amtpmiumyr_f,v_pctpmium_f
          from tisrpre
          where numisr = p_numisr
              and codisrp = p_codisrp
              and coddepen = 'F';
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tisrpre');
      end;
      -- monthly
      if v_flgisr = '1' then
          v_amtmonth_f := v_amtpmiummt_f;
          v_amtyear_f := 0;

          v_amtpmiume_f :=  v_amtmonth_f * (v_pctpmium_f/100) * (p_numfamily);
          v_amtpmiumc_f := v_amtmonth_f - v_amtpmiume_f;
      -- yearly
      elsif v_flgisr = '4' then
          v_amtmonth_f := 0;
          v_amtyear_f := v_amtpmiumyr_f;

          v_amtpmiume_f :=  v_amtyear_f * (v_pctpmium_f/100) * (p_numfamily);
          v_amtpmiumc_f := v_amtyear_f - v_amtpmiume_f;
      end if;

      obj_data := json_object_t();
      obj_data.put('coderror',200);
      obj_data.put('amtpmiumm', to_char(v_amtmonth + v_amtmonth_f,'fm999,999,990.90'));
      obj_data.put('amtpmiumy', to_char(v_amtyear + v_amtyear_f,'fm999,999,990.90'));
      obj_data.put('amtpmiume', to_char(v_amtpmiume + v_amtpmiume_f,'fm999,999,990.90'));
      obj_data.put('amtpmiumc', to_char(v_amtpmiumc + v_amtpmiumc_f,'fm999,999,990.90'));


      json_str_output := obj_data.to_clob;
      IF param_msg_error IS NOT NULL THEN
          json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      END IF;

  EXCEPTION WHEN OTHERS THEN
          param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  END gen_valuecal_f;

  procedure insert_tchgins1 as
    v_max     number;
    v_exist   varchar2(1 char);
  begin
    v_max := null;
    begin
        select 'Y' into v_exist
        from tchgins1
        where codempid = p_query_codempid
          and numisr = p_numisr
          and dtechng = p_dtechng;
    exception when no_data_found then
        v_exist := 'N';
    end;
    if v_exist = 'N' then
      begin
        insert into tchgins1(codempid, numisr, dtechng, dteeffec, flgchng,
                             numisro, codisrp, codisrpo, flgisr, flgisro,
                             dtehlpst, dtehlpsto, dtehlpen, dtehlpeno,
                             amtisrp, amtisrpo,amtpmiumme,amtpmiummeo, amtpmiumye,amtpmiumyeo,
                             amtpmiummc,amtpmiummco,amtpmiumyc,amtpmiumyco,
                             codecov,codecovo,codfcov,codfcovo,
                             remark,codedit,dteedit,staappr,
                             approvno,codcreate,coduser)
                      values(p_query_codempid, p_numisr, p_dtechng, p_dteeffec,'3',
                             p_numisr, p_codisrp, p_codisrpo, p_flgisr, p_flgisro,
                             p_dtehlpst, p_dtehlpsto, p_dtehlpen, p_dtehlpeno,
                             p_amtisrp, p_amtisrpo, p_amtpmiumme, p_amtpmiummeo,
                             p_amtpmiumye, p_amtpmiumyeo, p_amtpmiummc, p_amtpmiummco, p_amtpmiumyc, p_amtpmiumyco,
                             p_codecov, p_codecovo, p_codfcov, p_codfcovo,
                             p_remark, p_codedit, p_dteedit,'P',
                             v_max, global_v_coduser, global_v_coduser);
      end;
    else
      begin
        update tchgins1
           set codisrp = p_codisrp,
              dtehlpst = p_dtehlpst,
              dtehlpen = p_dtehlpen,
              amtisrp = p_amtisrp,
              codecov = p_codecov,
              codfcov = p_codfcov,
              amtpmiumme = p_amtpmiumme,
              amtpmiumye = p_amtpmiumye,
              amtpmiummc = p_amtpmiummc,
              amtpmiumyc = p_amtpmiumyc,
              remark = p_remark,
              codedit = p_codedit,
              dteedit = p_dteedit,
              coduser = global_v_coduser
        where codempid = p_query_codempid
          and numisr = p_numisr
          and dtechng = p_dtechng;
      end;
    end if;
  end insert_tchgins1;

  procedure initial_tab1(v_tab1 json_object_t) as
    data_obj       json_object_t;
    v_amtpmiummt   tisrpre.amtpmiummt%type;
    v_amtpmiumyr   tisrpre.amtpmiumyr%type;
    v_pctpmium     tisrpre.pctpmium%type;
  begin
        data_obj  := v_tab1;
        p_query_codempid   := hcm_util.get_string_t(data_obj,'codempid');
        p_numisr           := hcm_util.get_string_t(data_obj,'numisr');
        p_dtechng          := to_date(hcm_util.get_string_t(data_obj,'dtechng'),'dd/mm/yyyy');
        p_dteeffec         := to_date(hcm_util.get_string_t(data_obj,'dteeffec'),'dd/mm/yyyy');

        p_amtisrpo    := to_number(hcm_util.get_string_t(data_obj,'amtisrpo'));
        p_amtpmiummo  := to_number(replace(hcm_util.get_string_t(data_obj,'amtpmiummo'),',',''));
        p_amtpmiumyo  := to_number(replace(hcm_util.get_string_t(data_obj,'amtpmiumyo'),',',''));
        p_amtpmiumeo  := to_number(replace(hcm_util.get_string_t(data_obj,'amtpmiumeo'),',',''));
        p_amtpmiumco  := to_number(replace(hcm_util.get_string_t(data_obj,'amtpmiumco'),',',''));
        p_numfamily   := to_number(hcm_util.get_string_t(data_obj,'qtyinsrdpo'));
        p_codisrpo    := hcm_util.get_string_t(data_obj,'codisrpo');
        p_flgisro     := hcm_util.get_string_t(data_obj,'flgisro');
        p_dtehlpsto   := to_date(hcm_util.get_string_t(data_obj,'dtehlpsto'),'dd/mm/yyyy');
        p_dtehlpeno   := to_date(hcm_util.get_string_t(data_obj,'dtehlpeno'),'dd/mm/yyyy');
        p_codecovo    := nvl(hcm_util.get_string_t(data_obj,'codecovo'),'N');
        p_codfcovo    := nvl(hcm_util.get_string_t(data_obj,'codfcovo'),'N');
        p_flgcodcov   := nvl(hcm_util.get_string_t(data_obj,'flgcodcov'),'N');

        p_amtisrp     := to_number(hcm_util.get_string_t(data_obj,'amtisrp'));
        p_amtpmiumm   := to_number(replace(hcm_util.get_string_t(data_obj,'amtpmiumm'),',',''));
        p_amtpmiumy   := to_number(replace(hcm_util.get_string_t(data_obj,'amtpmiumy'),',',''));
        p_amtpmiume   := to_number(replace(hcm_util.get_string_t(data_obj,'amtpmiume'),',',''));
        p_amtpmiumc   := to_number(replace(hcm_util.get_string_t(data_obj,'amtpmiumc'),',',''));
        p_numfamilyn  := to_number(nvl(hcm_util.get_string_t(data_obj,'qtyinsrdp'),0));
        p_codisrp     := hcm_util.get_string_t(data_obj,'codisrp');
        p_flgisr      := hcm_util.get_string_t(data_obj,'flgisr');
        p_dtehlpst    := to_date(hcm_util.get_string_t(data_obj,'dtehlpst'),'dd/mm/yyyy');
        p_dtehlpen    := to_date(hcm_util.get_string_t(data_obj,'dtehlpen'),'dd/mm/yyyy');
        p_codecov     := nvl(hcm_util.get_string_t(data_obj,'codecov'),'N');
        p_codfcov     := nvl(hcm_util.get_string_t(data_obj,'codfcov'),'N');
        p_remark      := hcm_util.get_string_t(data_obj,'remark');
        p_codedit     := hcm_util.get_string_t(data_obj,'codedit');
        p_dteedit     := to_date(hcm_util.get_string_t(data_obj,'dteedit'),'dd/mm/yyyy');
        if p_flgcodcov = 'E' then
          p_codecov    := 'Y';
          p_codfcov    := 'N';
        else
          p_codecov    := 'N';
          p_codfcov    := 'Y';
        end if;
        if p_flgisro = '1' then -- month
          p_amtpmiummeo := p_amtpmiumeo;
          p_amtpmiummco := p_amtpmiumco;
          p_amtpmiumyeo := null;
          p_amtpmiumyco := null;
        elsif p_flgisro = '4' then
          p_amtpmiummeo := null;
          p_amtpmiummco := null;
          p_amtpmiumyeo := p_amtpmiumeo;
          p_amtpmiumyco := p_amtpmiumco;
        end if;
        --
        if p_flgisr = '1' then -- month
          p_amtpmiumme := p_amtpmiume;
          p_amtpmiummc := p_amtpmiumc;
          p_amtpmiumye := null;
          p_amtpmiumyc := null;
        elsif p_flgisr = '4' then
          p_amtpmiumme := null;
          p_amtpmiummc := null;
          p_amtpmiumye := p_amtpmiume;
          p_amtpmiumyc := p_amtpmiumc;
        end if;
        check_tab1;
        if param_msg_error is not null then
            return;
        end if;
        insert_tchgins1;
  end initial_tab1;

  procedure insert_tchgins2 as
    v_codsex        temploy1.codsex%type;
    v_max_numseq    number;
  begin
    begin
        select codsex into v_codsex
        from temploy1
        where codempid = p_query_codempid;
    exception when no_data_found then
        v_codsex := '';
    end;


    select max(numseq)+1 into v_max_numseq
    from tchgins2
    where codempid = p_query_codempid
      and numisr = p_numisr
      and dtechng = p_dtechng;

    if v_max_numseq is null then
        v_max_numseq := 1;
    end if;

    insert into tchgins2(codempid,numisr,dtechng,numseq,
                         flgchng,nameinsr,typrelate,dteempdb,codsex,
                         codcreate,coduser)
         values (p_query_codempid,p_numisr,p_dtechng,v_max_numseq,
                 p_flgchng,p_nameinsr,p_typrelate,p_dteempdb,v_codsex,
                 global_v_coduser,global_v_coduser);

  end insert_tchgins2;

  procedure update_tchgins2 as
  begin
    update tchgins2
    set flgchng = p_flgchng,
        nameinsr = p_nameinsr,
        typrelate = p_typrelate,
        dteempdb = p_dteempdb,
        coduser = global_v_coduser
    where codempid = p_query_codempid
      and numisr = p_numisr
      and dtechng = p_dtechng
      and numseq = p_numseq;

  end update_tchgins2;

  procedure delete_tchgins2 as
  begin
    delete from tchgins2
    where codempid = p_query_codempid
      and numisr = p_numisr
      and dtechng = p_dtechng
      and numseq = p_numseq;
  end delete_tchgins2;

  procedure initial_tab2(v_tab2 json_object_t) as
    data_obj       json_object_t;
    v_chkAmt       number;
  begin
    for i in 0..v_tab2.get_size-1 loop
        data_obj     := hcm_util.get_json_t(v_tab2,to_char(i));
        p_numseq     := to_number(hcm_util.get_string_t(data_obj,'numseq'));
        p_nameinsr   := hcm_util.get_string_t(data_obj,'namrelate');
        p_typrelate  := hcm_util.get_string_t(data_obj,'typrelate');
        p_dteempdb   := to_date(hcm_util.get_string_t(data_obj,'dteempdb'),'dd/mm/yyyy');
        p_flgchng    := hcm_util.get_string_t(data_obj,'flgchng');
        p_flag       := hcm_util.get_string_t(data_obj,'flg');

        check_tab2;
        if param_msg_error is not null then
            return;
        end if;

        if p_flag = 'add' then
            insert_tchgins2;
        elsif p_flag = 'edit' then
            update_tchgins2;
        elsif p_flag = 'delete' then
            delete_tchgins2;
        end if;
    end loop;
    begin
      select count(*) into v_chkAmt
      from tchgins2
      where codempid = p_query_codempid
        and numisr = p_numisr
        and dtechng = p_dtechng;
    end;
    if v_chkAmt <> (p_numfamilyn) then--User37 #6780 26/08/2021 (p_numfamilyn-1) then
      param_msg_error := get_error_msg_php('BF0055',global_v_lang);
      return;
    end if;
  end initial_tab2;

  procedure insert_tchgins3 as
    v_max_numseq    number;
  begin
    select max(numseq)+1 into v_max_numseq
    from tchgins3
    where codempid = p_query_codempid
      and numisr = p_numisr
      and dtechng = p_dtechng;
    if v_max_numseq is null then
        v_max_numseq := 1;
    end if;
    insert into tchgins3(codempid,numisr,dtechng,numseq,
                         nambfisr,typrelate,ratebf,flgchng,
                         codcreate,coduser)
          values(p_query_codempid,p_numisr,p_dtechng,v_max_numseq,
                 p_nambfisr,p_typrelate,p_ratebf,p_flgchng,
                 global_v_coduser,global_v_coduser);

  end insert_tchgins3;

  procedure update_tchgins3 as
  begin
    update tchgins3
    set nambfisr = p_nambfisr,
        typrelate = p_typrelate,
        ratebf = p_ratebf,
        flgchng = p_flgchng,
        coduser = global_v_coduser
    where codempid = p_query_codempid
      and numisr = p_numisr
      and dtechng = p_dtechng
      and numseq = p_numseq;

  end update_tchgins3;

  procedure delete_tchgins3 as
  begin
    delete from tchgins3
    where codempid = p_query_codempid
      and numisr = p_numisr
      and dtechng = p_dtechng
      and numseq = p_numseq;
  end delete_tchgins3;

  procedure initial_tab3(v_tab3 json_object_t) as
    data_obj       json_object_t;
    v_chkAmount    number := 0;
    v_sumrate      number := 0;
  begin
    for i in 0..v_tab3.get_size-1 loop
        data_obj     := hcm_util.get_json_t(v_tab3,to_char(i));
        p_numseq     := to_number(hcm_util.get_string_t(data_obj,'numseq'));
        p_nambfisr   := hcm_util.get_string_t(data_obj,'nambfisr');
        p_typrelate  := hcm_util.get_string_t(data_obj,'typrelate');
        p_ratebf     := hcm_util.get_string_t(data_obj,'ratebf');
        p_flgchng    := hcm_util.get_string_t(data_obj,'flgchng');
        p_flag       := hcm_util.get_string_t(data_obj,'flg');

        check_tab3;
        if param_msg_error is not null then
            return;
        end if;

        if p_flag = 'add' then
            insert_tchgins3;
        elsif p_flag = 'edit' then
            update_tchgins3;
        elsif p_flag = 'delete' then
            delete_tchgins3;
        end if;
    end loop;
    begin
      select count(*),sum(ratebf) into v_chkAmount, v_sumrate
      from tchgins3
      where codempid = p_query_codempid
        and numisr = p_numisr
        and dtechng = p_dtechng;
    end;

    if v_chkAmount > 0 and  v_sumrate <> 100 then
      param_msg_error := get_error_msg_php('PY0052',global_v_lang);
      return;
    end if;
  end initial_tab3;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
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
  END get_index;

  procedure get_valuecal(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    if p_typecal = 'E' then
        gen_valuecal_e(json_str_output);
    elsif  p_typecal = 'F' then
        gen_valuecal_f(json_str_output);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_valuecal;
  PROCEDURE gen_insurance_plan(json_str_output out clob) AS
      obj_data        json_object_t;
      v_codecov       tisrpinf.codecov%type;
      v_codfcov       tisrpinf.codfcov%type;
      v_amtisrp       tisrpinf.amtisrp%type;                                    --> Peerasak || Issue#8702 || 01/12/2022

  BEGIN
      begin
        select codecov, codfcov, amtisrp into v_codecov, v_codfcov, v_amtisrp   --> Peerasak || Issue#8702 || 01/12/2022
        from tisrpinf
        where codisrp = p_codisrp
        and numisr = p_numisr;
      exception when no_data_found then
        v_codecov := '';
        v_codfcov := '';
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tisrpinf');
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        return;
      end;

      obj_data := json_object_t();
      obj_data.put('coderror',200);
      obj_data.put('codecov', v_codecov);
      obj_data.put('codfcov', v_codfcov);
      obj_data.put('amtisrp', v_amtisrp);                                       --> Peerasak || Issue#8702 || 01/12/2022
      obj_data.put('desc_codisrp', get_tcodec_name('TCODISRP',p_codisrp,global_v_lang));
      if v_codecov = 'Y' then
        obj_data.put('flgcodcov','E');
      end if;
      if v_codfcov = 'Y' then
        obj_data.put('flgcodcov','F');
      end if;
      json_str_output := obj_data.to_clob;

      IF param_msg_error IS NOT NULL THEN
          json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      END IF;

  EXCEPTION WHEN OTHERS THEN
          param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  END gen_insurance_plan;

  procedure get_insurance_plan(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_insurance_plan(json_str_output);
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_insurance_plan;

  procedure save_detail(json_str_input in clob,json_str_output out clob) as
    json_obj       json_object_t;
    data_obj       json_object_t;
    v_temp         varchar2(1 char);
--<< user25 Date : 01/09/2021 5. BF Module #6781
    v_codempid      temploy1.codempid%type;
    v_numisr        tchgins1.numisr%type;
    v_dtechng       tchgins1.dtechng%type;
    v_approvno      number;
    v_flgpass     	boolean;
    v_check         varchar2(1 char);
    v_staappr       varchar2(1 char);
    v_error			terrorm.errorno%type;
    v_rowid         rowid;
-->> user25 Date : 01/09/2021 5. BF Module #6781

  begin
    initial_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    p_tab1      := hcm_util.get_json_t(json_obj,'changeDetails');
    p_tab2      := hcm_util.get_json_t(json_obj,'familyInsurance');
    p_tab3      := hcm_util.get_json_t(json_obj,'beneficiaries');

    if param_msg_error is null then
      initial_tab1(p_tab1);
    end if;
     if param_msg_error is null then
        initial_tab2(p_tab2);
    end if;
    if param_msg_error is null then
        initial_tab3(p_tab3);
    end if;

     if param_msg_error is null then
        commit;
--<< user25 Date : 01/09/2021 5. BF Module #6781
         v_codempid     := p_query_codempid;
         v_numisr       := p_numisr;
         v_dtechng      := p_dtechng;
         v_staappr        := 'P';
         v_approvno       := 0;

             select rowid
              into v_rowid
              from tchgins1
             where codempid = v_codempid
               and numisr     = v_numisr
               and trunc(dtechng) = v_dtechng;

            begin
                v_error := chk_flowmail.send_mail_for_approve('HRBF36E', v_codempid, global_v_codempid, global_v_coduser, null, 'HRBF3ZU1', 230, 'U', v_staappr, v_approvno + 1, null, null,'TCHGINS1',v_rowid, '1', null);
               EXCEPTION WHEN OTHERS THEN
                v_error := '2403';
            END;

            IF v_error in ('2046','2402') THEN
                param_msg_error := get_error_msg_php('HR2402', global_v_lang);
            ELSE
                param_msg_error_mail := get_error_msg_php('HR2403', global_v_lang);
            END IF;

            if param_msg_error_mail is not null then
                json_str_output := get_response_message(200,param_msg_error_mail,global_v_lang);
            else
                json_str_output := get_response_message(200,param_msg_error,global_v_lang);

            end if;
--        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
--        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
-->> user25 Date : 01/09/2021 5. BF Module #6781
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;

  exception when others then
      rollback;
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;
END HRBF36E;

/

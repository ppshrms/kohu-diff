--------------------------------------------------------
--  DDL for Package Body HRPYB6E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYB6E" as
  function is_number (p_string in varchar2) return int is
    v_new_num number;
  begin
    v_new_num := to_number(p_string);
    return 1;
  exception when others then
    return 0;
  end is_number;

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codpfinf          := hcm_util.get_string_t(json_obj, 'p_codpfinf');
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codpfinf  tpfmemb.codpfinf%type;
    v_codempid  temploy1.codempid%type;
  begin
    if p_codpfinf is null and p_codcomp is null and p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    --
    if p_codpfinf is not null then
      begin
        select codcodec into v_codpfinf
          from tcodpfinf
          where codcodec = p_codpfinf;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPFINF');
        return;
      end;
    end if;
    --
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    --
    if p_codempid is not null then
      begin
        select codempid into v_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end check_index;

  procedure check_import_data(v_codempid   in varchar2,
                              v_amteaccu   in varchar2,
                              v_amtintaccu in varchar2,
                              v_amtcaccu   in varchar2,
                              v_amtinteccu in varchar2,
                              v_codplan    in varchar2,
                              v_err_text  out varchar2) is
    v_chk_exist       varchar2(2000 char);
    v_err_code        varchar2(2000 char);
    v_codempid_tmp    varchar2(2000 char);
    v_codplan_tmp     varchar2(10 char);
  begin  null;
    -- 1.check field codempid
    if v_codempid is not null then
      if length(v_codempid) > 10 then
        v_err_code := 'HR6591';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      end if;
      --
      begin
        select codempid into v_codempid_tmp
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        v_err_code := 'HR2010';
        v_err_text := replace(get_error_msg_php(v_err_code, global_v_lang, 'temploy1',null,false),'@#$%400','');
        return;
      end;
      --
      if not secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        v_err_code := 'HR3007';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      end if;
    else
      v_err_code := 'HR2045';
      v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
      return;
    end if;
    -- 2.check field amteaccu
    if v_amteaccu is not null then
      if is_number(v_amteaccu) < 1 then
        v_err_code := 'HR2816';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      elsif length(trunc(v_amteaccu)) > 9 then
        v_err_code := 'HR6591';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      end if;
    else
      v_err_code := 'HR2045';
      v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
      return;
    end if;
    -- 3.check field amtintaccu
    if v_amtintaccu is not null then
      if is_number(v_amtintaccu) < 1 then
        v_err_code := 'HR2816';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      elsif length(trunc(v_amtintaccu)) > 9 then
        v_err_code := 'HR6591';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      end if;
    else
      v_err_code := 'HR2045';
      v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
      return;
    end if;
    -- 4.check field amtcaccu
    if v_amtcaccu is not null then
      if is_number(v_amtcaccu) < 1 then
        v_err_code := 'HR2816';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      elsif length(trunc(v_amtcaccu)) > 9 then
        v_err_code := 'HR6591';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      end if;
    else
      v_err_code := 'HR2045';
      v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
      return;
    end if;
    -- 5.check field amtinteccu
    if v_amtinteccu is not null then
      if is_number(v_amtinteccu) < 1 then
        v_err_code := 'HR2816';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      elsif length(trunc(v_amtinteccu)) > 9 then
        v_err_code := 'HR6591';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      end if;
    else
      v_err_code := 'HR2045';
      v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
      return;
    end if;
     -- 6.check field codplan
    if v_codplan is not null then
      if length(v_codplan) > 4 then
        v_err_code := 'HR6591';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      end if;

      begin
        select codcodec into v_codplan_tmp
          from tcodpfpln
         where codcodec = v_codplan;
      exception when no_data_found then
        v_err_code := 'HR2010';
        v_err_text := replace(get_error_msg_php(v_err_code, global_v_lang, 'tcodpfpln',null,false),'@#$%400','');
        return;
      end;

      begin
        select codplan into v_codplan_tmp
          from tpfmemb
         where codempid = v_codempid;
      exception when no_data_found then
        v_err_code := 'HR2010';
        v_err_text := replace(get_error_msg_php(v_err_code, global_v_lang, 'tpfmemb',null,false),'@#$%400','');
        return;
      end;

      if v_codplan_tmp <> v_codplan then
        v_err_code := 'PY0059';
        v_err_text := replace(get_error_msg_php(v_err_code, global_v_lang),'@#$%400','');
      end if;

    else
      v_err_code := 'HR2045';
      v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
      return;
    end if;
    begin
      select codempid
        into v_chk_exist
        from TPFMEMB
       where codempid = v_codempid
         and flgemp = 1;
    exception when no_data_found then
      v_err_code := 'PY0056';
      v_err_text := replace(get_error_msg_php(v_err_code, global_v_lang, 'tpfmemb',null,false),'@#$%400','');
      return;
    end;
  end check_import_data;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) is
    obj_row              json_object_t;
    obj_data             json_object_t;
    v_flg_secure         boolean := false;
    v_flg_exist          boolean := false;
    v_flg_permission     boolean := false;
    v_rcnt               number  := 0;
    v_total              number  := 0;
    --
    v_amteaccu           number  := 0;
    v_amtintaccu         number  := 0;
    v_amtcaccu           number  := 0;
    v_amtinteccu         number  := 0;
    --
    v_year				       number  := 0;
    v_month				       number  := 0;
    v_day					       number  := 0;
    --
    v_flgdpvf            tpfmemrt.flgdpvf%type;
    v_ratecret           tpfmemrt.ratecret%type;
    v_ratecsbt           tpfmemrt.ratecsbt%type;
    cursor c1 is
      select a.codpfinf,a.nummember,a.codempid,a.codcomp,a.amteaccu,a.amtintaccu,a.amtcaccu,
             a.amtinteccu,a.dteeffec,a.dtecal,a.flgemp,a.codplan,a.rowid,b.dteempmt,b.dteeffex,b.dteretire
        from tpfmemb a, temploy1 b
       where a.codpfinf = nvl(p_codpfinf,a.codpfinf)
         and a.codcomp like p_codcomp||'%'
         and a.codempid = nvl(p_codempid,a.codempid)
         and a.codempid  = b.codempid(+)
    order by a.nummember, a.codempid;

    cursor c_tpfeinf (v_codcomp varchar2,v_dteeffec date) is
      select numseq,syncond,flgconded
        from tpfeinf
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec = v_dteeffec
      order by numseq;

    cursor c_tpfdinf (v_codcomp varchar2,v_dteeffec date, v_numseq number, v_year number) is
      select ratecsbt,rateesbt
        from tpfdinf
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec = v_dteeffec
         and numseq	  = v_numseq
         and v_year between qtywkst and qtywken;
  begin
    obj_row                := json_object_t();
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tpfmemb');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    for r1 in c1 loop
      v_flg_secure := secur_main.secur2(r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
         -- decode --
        v_amteaccu       := stddec(r1.amteaccu,r1.codempid,v_chken);
        v_amtintaccu     := stddec(r1.amtintaccu,r1.codempid,v_chken);
        v_amtcaccu       := stddec(r1.amtcaccu,r1.codempid,v_chken);
        v_amtinteccu     := stddec(r1.amtinteccu,r1.codempid,v_chken);
        --
        v_ratecret := 0;
        v_ratecsbt := 0;
        obj_data         := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', r1.codcomp||' - '||get_tcenter_name(r1.codcomp, global_v_lang));
        obj_data.put('staemp', get_tlistval_name('FLGEMP',r1.flgemp,global_v_lang));
        obj_data.put('desc_codplan', r1.codplan||' - '||get_tcodec_name('tcodpfpln', r1.codplan,global_v_lang));
        obj_data.put('amteaccu', v_amteaccu);
        obj_data.put('amtintaccu', v_amtintaccu);
        obj_data.put('sumeaccu', nvl(v_amteaccu,0) + nvl(v_amtintaccu,0));
        obj_data.put('amtcaccu', v_amtcaccu);
        obj_data.put('amtinteccu', v_amtinteccu);
        obj_data.put('sumcaccu', nvl(v_amtcaccu,0) + nvl(v_amtinteccu,0));
        obj_data.put('total', nvl(v_amteaccu,0) + nvl(v_amtintaccu,0) +
                              nvl(v_amtcaccu,0) + nvl(v_amtinteccu,0));
        obj_data.put('codpfinf', r1.codpfinf);
        obj_data.put('desc_codpfinf', get_tcodec_name('TCODPFINF',r1.codpfinf,global_v_lang));
        obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
         begin
              select ratecret, ratecsbt
                into v_ratecret, v_ratecsbt
                from tpfmemrt
               where codempid = r1.codempid
                 and dteeffec = (select max(dteeffec)
                                   from tpfmemrt
                                  where codempid = r1.codempid
                                    and dteeffec < trunc(sysdate));
            exception when others then null;
            end;
            obj_data.put('rateesbt', v_ratecret);
            obj_data.put('ratecsbt', v_ratecsbt);

        for r_tpfeinf in c_tpfeinf (r1.codcomp,r1.dteeffec) loop
          v_year  := null;
          v_month := null;
          v_day   := null;
          --
          if r_tpfeinf.flgconded = '1' then
            get_service_year(r1.dteeffec,nvl(r1.dteretire,trunc(sysdate)),'Y',v_year,v_month,v_day);
          elsif r_tpfeinf.flgconded = '2' then
            get_service_year(r1.dteempmt,nvl(r1.dteeffex,trunc(sysdate)),'Y',v_year,v_month,v_day);
          end if;


        end loop;

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt           := v_rcnt + 1;
      end if;
    end loop;
    --
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_amteaccu         number;
    v_amtcaccu         number;
    v_last_rec         number;
    v_amtintaccu       number;
    v_amtinteccu       number;

    v_dteedit         date;
    v_dteeffec        varchar2(30 char);
    v_codplan         varchar2(10 char);
    v_desc_codplan    varchar2(300 char);
    v_amtaccum_tmp    varchar2(100 char);
    v_amtintaccu_tmp  varchar2(100 char);
    v_codcompy        varchar2(100 char);
    v_codpfinf        varchar2(10 char);

    cursor c_tpfpcinf is
      select codpolicy,pctinvt
        from tpfpcinf
       where codcompy = v_codcompy
         and codpfinf = v_codpfinf
         and codplan  = v_codplan
         and dteeffec = ( select max(dteeffec) from tpfpcinf
                           where codcompy = v_codcompy
                             and codpfinf = v_codpfinf
                             and codplan  = v_codplan
                             and dteeffec <= v_dteedit)
      order by codpolicy;

    cursor c_tpfbflog is
      select codempid,codplan, amteaccu, amtcaccu, amtintaccu, amtinteccu,dteedit
        from tpfbflog
       where codempid = p_codempid
         and dteedit = (select max(dteedit) from tpfbflog where codempid = p_codempid and rownum=1)
      order by dteedit desc;
    v_chk_last c_tpfbflog%rowtype;
  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;

    begin
      select hcm_util.get_codcomp_level(a.codcomp,1) ,b.codpfinf
        into v_codcompy, v_codpfinf
        from temploy1 a, tpfmemb b
       where a.codempid = p_codempid
         and a.codempid = b.codempid;
    end;

    for r1 in c_tpfbflog loop
      v_amteaccu         := stddec(r1.amteaccu,r1.codempid,v_chken);
      v_amtcaccu         := stddec(r1.amtcaccu,r1.codempid,v_chken);
      v_amtintaccu       := stddec(r1.amtintaccu,r1.codempid,v_chken);
      v_amtinteccu       := stddec(r1.amtinteccu,r1.codempid,v_chken);

      v_dteedit        := r1.dteedit;
      v_dteeffec       := to_char(r1.dteedit,'dd/mm/yyyy');
      v_codplan        := to_char(r1.codplan);
      v_desc_codplan   := get_tcodec_name('TCODPFPLN', r1.codplan,global_v_lang);
      v_amtaccum_tmp   := to_char( nvl(v_amtcaccu,0) + nvl(v_amteaccu,0));
      v_amtintaccu_tmp := to_char( nvl(v_amtintaccu,0) + nvl(v_amtinteccu,0));
    end loop;

    for r2 in c_tpfpcinf loop

      v_rcnt           := v_rcnt + 1;
      obj_data         := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dteeffec', v_dteeffec);
      obj_data.put('codplan', v_codplan);
      obj_data.put('desc_codplan', v_desc_codplan);
      obj_data.put('amtaccum', v_amtaccum_tmp);
      obj_data.put('amtintaccu', v_amtintaccu_tmp);
      obj_data.put('codpolicy', r2.codpolicy);
      obj_data.put('desc_codpolicy', get_tcodec_name('TCODPFPLC', r2.codpolicy, global_v_lang));
      obj_data.put('qtycompst', r2.pctinvt);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    obj_param_json json_object_t;
    param_json_row json_object_t;
    -- get param json
    v_codempid          tpfmemb.codempid%type;
    v_amteaccu          tpfmemb.amteaccu%type;
    v_amtintaccu        tpfmemb.amtintaccu%type;
    v_amtcaccu          tpfmemb.amtcaccu%type;
    v_amtinteccu        tpfmemb.amtinteccu%type;

    v_amteaccu_tmp      tpfmemb.amteaccu%type;
    v_amtintaccu_tmp    tpfmemb.amtintaccu%type;
    v_amtcaccu_tmp      tpfmemb.amtcaccu%type;
    v_amtinteccu_tmp    tpfmemb.amtinteccu%type;
    v_flg               varchar2(100 char);
    v_codplan           varchar2(10 char);
    v_numseq            number := 0;
  begin
    initial_value(json_str_input);
--    check_index;
    obj_param_json        := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
    if param_msg_error is null then
      for i in 0..obj_param_json.get_size-1 loop
        param_json_row    := hcm_util.get_json_t(obj_param_json,to_char(i));
        --
        v_codempid            := hcm_util.get_string_t(param_json_row,'codempid');
        v_amteaccu            := hcm_util.get_string_t(param_json_row,'amteaccu');
        v_amtintaccu          := hcm_util.get_string_t(param_json_row,'amtintaccu');
        v_amtcaccu            := hcm_util.get_string_t(param_json_row,'amtcaccu');
        v_amtinteccu          := hcm_util.get_string_t(param_json_row,'amtinteccu');
        v_flg                 := hcm_util.get_string_t(param_json_row,'flg');
        v_amteaccu_tmp        := hcm_util.get_string_t(param_json_row,'amteaccuOld');
        v_amtintaccu_tmp      := hcm_util.get_string_t(param_json_row,'amtintaccuOld');
        v_amtcaccu_tmp        := hcm_util.get_string_t(param_json_row,'amtcaccuOld');
        v_amtinteccu_tmp      := hcm_util.get_string_t(param_json_row,'amtinteccuOld');
        v_numseq              := 0;
        --
        if v_amteaccu > 999999999.99 then
            param_msg_error := get_error_msg_php('HR6591',global_v_lang,'TPFMEMB');
            exit;
        end if;
        if p_codempid is not null then
          begin
            select codempid into v_codempid
              from temploy1
             where codempid = v_codempid;
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
            exit;
          end;
          --
          if not secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            exit;
          end if;
        end if;
        if param_msg_error is null then
          if v_flg = 'edit' then
            if v_amteaccu <> v_amteaccu_tmp then
               v_numseq := v_numseq + 1;
               insert_tpfmlog(v_codempid ,'amteaccu' ,v_numseq,stdenc(v_amteaccu_tmp,v_codempid,v_chken),stdenc(v_amteaccu,v_codempid,v_chken));
            end if;
            if v_amtintaccu <> v_amtintaccu_tmp then
               v_numseq := v_numseq + 1;
               insert_tpfmlog(v_codempid ,'amtintaccu' ,v_numseq,stdenc(v_amtintaccu_tmp,v_codempid,v_chken),stdenc(v_amtintaccu,v_codempid,v_chken));
            end if;
            if v_amtcaccu <> v_amtcaccu_tmp then
               v_numseq := v_numseq + 1;
               insert_tpfmlog(v_codempid ,'amtcaccu' ,v_numseq,stdenc(v_amtcaccu_tmp,v_codempid,v_chken),stdenc(v_amtcaccu,v_codempid,v_chken));
            end if;
            if v_amtinteccu <> v_amtinteccu_tmp then
               v_numseq := v_numseq + 1;
               insert_tpfmlog(v_codempid ,'amtinteccu' ,v_numseq,stdenc(v_amtinteccu_tmp,v_codempid,v_chken),stdenc(v_amtinteccu,v_codempid,v_chken));
            end if;

            begin
              select codplan into v_codplan
                from tpfmemb
               where codempid = v_codempid;
           end;

            begin
              update tpfmemb set amteaccu    =  stdenc(v_amteaccu,v_codempid,v_chken),
                                 amtintaccu  =  stdenc(v_amtintaccu,v_codempid,v_chken),
                                 amtcaccu    =  stdenc(v_amtcaccu,v_codempid,v_chken),
                                 amtinteccu  =  stdenc(v_amtinteccu,v_codempid,v_chken),
                                 dteupd      =  trunc(sysdate),
                                 coduser     =  global_v_coduser
                           where codempid    =  v_codempid;
            end;

            if v_numseq <> 0  then
               insert_tpfbflog(v_codempid,v_codplan,stdenc(v_amteaccu,v_codempid,v_chken),stdenc(v_amtintaccu,v_codempid,v_chken),
                               stdenc(v_amtcaccu,v_codempid,v_chken),stdenc(v_amtinteccu,v_codempid,v_chken));
            end if;

          end if;
        end if;
      end loop;
      --
      if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      end if;
    end if;
     json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure import_data (json_str_input in clob, json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_flgsecu       boolean := false;
    v_rec_tran      number  := 0;
    v_rec_err       number  := 0;
    v_rcnt          number  := 0;
    v_numrec        number  := 0;
    v_numseq        number  := 0;
    --
    v_codempid      varchar2(4000 char);
    v_amteaccu      varchar2(4000 char);
    v_amtintaccu    varchar2(4000 char);
    v_amtcaccu      varchar2(4000 char);
    v_amtinteccu    varchar2(4000 char);
    v_codplan       varchar2(4000 char);
    v_err_text      varchar2(4000 char);

    v_amteaccu_tmp      varchar2(4000 char);
    v_amtintaccu_tmp    varchar2(4000 char);
    v_amtcaccu_tmp      varchar2(4000 char);
    v_amtinteccu_tmp    varchar2(4000 char);
  begin
    initial_value(json_str_input);
    param_json    := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
    --
    obj_row    := json_object_t();
    obj_result := json_object_t();
    for i in 0..param_json.get_size-1 loop
      v_numrec        := i + 1;
      v_numseq        := 0;
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
      --
      v_codempid      := hcm_util.get_string_t(param_json_row,'codempid');
      v_amteaccu      := hcm_util.get_string_t(param_json_row,'amteaccu');
      v_amtintaccu    := hcm_util.get_string_t(param_json_row,'amtintaccu');
      v_amtcaccu      := hcm_util.get_string_t(param_json_row,'amtcaccu');
      v_amtinteccu    := hcm_util.get_string_t(param_json_row,'amtinteccu');
      v_codplan       := hcm_util.get_string_t(param_json_row,'codplan');

      --
      v_err_text      := null;
      check_import_data(v_codempid,v_amteaccu,v_amtintaccu,v_amtcaccu,v_amtinteccu,v_codplan,v_err_text);
      if v_err_text is null then

          begin
            select stddec(amteaccu,v_codempid,v_chken),stddec(amtintaccu,v_codempid,v_chken),
                   stddec(amtcaccu,v_codempid,v_chken),stddec(amtinteccu,v_codempid,v_chken)
              into v_amteaccu_tmp,v_amtintaccu_tmp,v_amtcaccu_tmp,v_amtinteccu_tmp
              from tpfmemb
             where codempid = v_codempid;
          exception when no_data_found then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
          end;

      if v_amteaccu <> v_amteaccu_tmp then
         v_numseq := v_numseq + 1;
         insert_tpfmlog(v_codempid ,'amteaccu' ,v_numseq,stdenc(v_amteaccu_tmp,v_codempid,v_chken),stdenc(v_amteaccu,v_codempid,v_chken));
      end if;
      if v_amtintaccu <> v_amtintaccu_tmp then
         v_numseq := v_numseq + 1;
         insert_tpfmlog(v_codempid ,'amtintaccu' ,v_numseq,stdenc(v_amtintaccu_tmp,v_codempid,v_chken),stdenc(v_amtintaccu,v_codempid,v_chken));
      end if;
      if v_amtcaccu <> v_amtcaccu_tmp then
         v_numseq := v_numseq + 1;
         insert_tpfmlog(v_codempid ,'amtcaccu' ,v_numseq,stdenc(v_amtcaccu_tmp,v_codempid,v_chken),stdenc(v_amtcaccu,v_codempid,v_chken));
      end if;
      if v_amtinteccu <> v_amtinteccu_tmp then
         v_numseq := v_numseq + 1;
         insert_tpfmlog(v_codempid ,'amtinteccu' ,v_numseq,stdenc(v_amtinteccu_tmp,v_codempid,v_chken),stdenc(v_amtinteccu,v_codempid,v_chken));
      end if;

        begin
          update tpfmemb set amteaccu   = stdenc(to_number(v_amteaccu),v_codempid,v_chken),
                             amtintaccu = stdenc(to_number(v_amtintaccu),v_codempid,v_chken),
                             amtcaccu   = stdenc(to_number(v_amtcaccu),v_codempid,v_chken),
                             amtinteccu = stdenc(to_number(v_amtinteccu),v_codempid,v_chken),
                             coduser    = global_v_coduser
                       where codempid   = v_codempid;
        end;

        if v_numseq <> 0 then
           insert_tpfbflog(v_codempid,v_codplan,stdenc(v_amteaccu,v_codempid,v_chken),stdenc(v_amtintaccu,v_codempid,v_chken),
                           stdenc(v_amtcaccu,v_codempid,v_chken),stdenc(v_amtinteccu,v_codempid,v_chken));
        end if;
        v_rec_tran := v_rec_tran + 1;
        commit;
      else
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('error_code', v_err_text);
        obj_data.put('text', v_codempid||'|'||v_codplan||'|'||v_amteaccu||'|'||v_amtintaccu||'|'||v_amtcaccu||'|'||v_amtinteccu);
        obj_data.put('numseq', v_numrec);
        obj_result.put(to_char(v_rcnt-1),obj_data);
        --
        v_rec_err   := v_rec_err + 1;
      end if;
    end loop;
    --

    obj_row.put('coderror', '200');
    obj_row.put('rec_tran', v_rec_tran);
    obj_row.put('rec_err', v_rec_err);
    obj_row.put('response', 'HR2715'||' '||get_errorm_name('HR2715',global_v_lang));

    obj_row.put('datadisp', obj_result);
    --
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end import_data;

  procedure insert_tpfmlog(v_codempid     in varchar2,
                           v_field_name   in varchar2,
                           v_numseq       in number,
                           v_desold       in varchar2,
                           v_desnew       in varchar2) is
  begin
       begin
          insert into tpfmlog (codempid,dteedit,numpage,numseq,fldedit,
                               typkey,fldkey,desold,desnew,codtable)
                        values(v_codempid,sysdate,'HRPYB6EC10',v_numseq,v_field_name,
                               'N',v_field_name,v_desold,v_desnew,'TPFMEMB');
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_tpfmlog;

  procedure insert_tpfbflog(v_codempid     in varchar2,
                           v_codplan       in varchar2,
                           v_amteaccu      in varchar2,
                           v_amtcaccu      in varchar2,
                           v_amtintaccu    in varchar2,
                           v_amtinteccu    in varchar2
                           ) is
  begin
       begin
          insert into tpfbflog (codempid,dteedit,codplan,amteaccu,amtcaccu,
                               amtintaccu,amtinteccu)
                        values(v_codempid,sysdate,v_codplan,v_amteaccu,v_amtcaccu,
                               v_amtintaccu,v_amtinteccu);
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_tpfbflog;

end HRPYB6E;

/

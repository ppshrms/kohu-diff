--------------------------------------------------------
--  DDL for Package Body HRPYBDX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYBDX" as

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    p_codpfinf          := hcm_util.get_string_t(obj_detail,'codpfinf');
    p_dtestrt           := to_date(hcm_util.get_string_t(obj_detail,'p_dtestrt'), 'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(obj_detail,'p_dteend'), 'ddmmyyyy');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
  begin
    if p_codcomp is null and p_codpfinf is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp,codpfinf');
      return;
    end if;

    if p_codcomp is not null then
      p_codpfinf := null;
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_codpfinf is not null then
      begin
        select codcodec
          into p_codpfinf
          from tcodpfinf
         where codcodec = p_codpfinf;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodpfinf');
        return;
      end;
    end if;
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
  v_dtestr             date;
  v_dteend             date;
  v_flg_secure         boolean := false;
  v_flg_exist          boolean := false;
  v_flg_permission     boolean := false;
  obj_rows             json_object_t := json_object_t();
  obj_data             json_object_t;
  v_count              number := 0;
  v_year               number;
  v_month              number;
  v_day                number;
  cursor c1 is
 /*   select a.codempid,b.codcomp ,b.numlvl  ,a.nummember,a.dteeffec,
           a.dtereti ,a.codpfinf,b.dteempmt,b.dteeffex ,a.codreti ,
           a.rowid
      from tpfmemb a,temploy1 b
     where b.codcomp  like p_codcomp || '%'
       and a.codpfinf = nvl(p_codpfinf,a.codpfinf)
       and a.codempid = b.codempid
       and a.dtereti between p_dtestrt and p_dteend
  order by b.codcomp,a.codempid;
*/
      select a.codempid,b.codcomp ,b.numlvl ,a.dteeffec,a.codplan,
               a.dtereti ,a.codpfinf,b.dteempmt,b.dteeffex,codreti ,a.rowid
          from tpfregst a,temploy1 b
         where b.codcomp  like p_codcomp || '%'
           and a.codpfinf = nvl(p_codpfinf,a.codpfinf)
           and a.codempid = b.codempid
           and a.dtereti between p_dtestrt and p_dteend
      order by decode(p_codcomp,null,a.codempid,b.codcomp),a.codempid;


  begin

    for r1 in c1 loop
      v_flg_exist := true;
      exit;
     end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tpfregst');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    for r1 in c1 loop
      v_flg_secure := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        obj_data := json_object_t();
        obj_data.put('coderror'        ,'200');
        obj_data.put('image'           ,get_emp_img(r1.codempid));
        obj_data.put('codempid'        ,r1.codempid);
        obj_data.put('desc_codempid'   ,get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('codpfinf' ,r1.codpfinf||'-'||r1.codplan);
        obj_data.put('desc_codpfinf' ,get_tcodec_name('TCODPFINF', r1 .codpfinf,global_v_lang));
        obj_data.put('codcomp'         ,r1.codcomp);
        obj_data.put('desc_codcomp'    ,get_tcenter_name(r1.codcomp, global_v_lang ));
        obj_data.put('dteempmt'        ,to_char(r1.dteempmt,'dd/mm/yyyy'));
        obj_data.put('dteeffec'         ,to_char(r1.dteeffec ,'dd/mm/yyyy'));
        obj_data.put('dtereti'         ,to_char(r1.dtereti ,'dd/mm/yyyy'));
        obj_data.put('cause'           ,get_tcodec_name('TCODEXEM',r1.codreti,global_v_lang));
        v_year  := null;
        v_month := null;
        get_service_year(r1.dteempmt,r1.dtereti,'Y',v_year,v_month,v_day);
        obj_data.put('wrkyear'         ,to_char(v_year));
        obj_data.put('wrkmonth'        ,to_char(v_month));
        v_year  := null;
        v_month := null;
        get_service_year(r1.dteeffec,r1.dtereti,'Y',v_year,v_month,v_day);
        obj_data.put('memyear'         ,to_char(v_year));
        obj_data.put('memmonth'        ,to_char(v_month));
        obj_data.put('ratepayback'     ,get_ratecret(r1.dteeffec,r1.dtereti,r1.codpfinf,r1.codempid));


        obj_rows.put(to_char(v_count)  ,obj_data);
        v_count := v_count + 1;
      end if;
    end loop;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  function get_ratecret (v_dteeffec date,v_dtereti date,v_codpfinf varchar2,v_codempid varchar2) return varchar2 as
    v_ratecret           number;
    v_codcompy           tcenter.codcompy%type;
    v_dteempmt           date;
    v_dteempdb           date;
    v_dteeffex           date;
    v_codcomp            temploy1.codcomp%type;
    v_codpos             temploy1.codpos%type;
    v_typemp             temploy1.typemp%type;
    v_codempmt           temploy1.codempmt%type;
    v_typpayroll         temploy1.typpayroll%type;
    v_staemp             temploy1.staemp%type;
    v_numlvl             temploy1.numlvl%type;
    v_jobgrade           temploy1.jobgrade%type;
    v_flg_found          boolean;
    v_year               number;
    v_month              number;
    v_day                number;
    v_qtywork            number;
    v_cond               varchar2(4000 char);
    v_stmt               varchar2(4000 char);
    v_numseq             number;
    v_dteeffec_tmp       date;
    cursor c1 is
      select numseq,syncond,flgconded,flgconret
        from tpfeinf
       where codcompy = v_codcompy
         and dteeffec = v_dteeffec_tmp
    order by numseq;
    cursor c2 is
      select qtyyrst,qtyyren,ratecsbt
        from tpfcinf
       where codcompy = v_codcompy
         and dteeffec = v_dteeffec_tmp
         and numseq	  = v_numseq
         and v_year between qtyyrst and qtyyren;
  begin
    begin
      select ratecret into v_ratecret
        from tpfpay
       where codempid = v_codempid
         and dtereti  = (select max(dtereti)
                           from tpfpay
                          where codempid = v_codempid
                            and dtereti < trunc(sysdate));
      return to_char(v_ratecret,'fm999999999990.00');
    exception when no_data_found then
      begin
        select hcm_util.get_codcomp_level(codcomp,1),
               dteempmt  ,dteempdb    ,dteeffex      ,
               codcomp   ,codpos      ,typemp        ,
               codempmt  ,typpayroll  ,staemp        ,
               numlvl    ,jobgrade
          into v_codcompy,
               v_dteempmt,v_dteempdb  ,v_dteeffex    ,
               v_codcomp ,v_codpos    ,v_typemp      ,
               v_codempmt,v_typpayroll,v_staemp      ,
               v_numlvl  ,v_jobgrade
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        v_codcompy := null;
        v_dteempmt := null;
        v_dteempdb := null;
      end;
      --
      begin
        select dteeffec into v_dteeffec_tmp
          from tpfhinf
         where codcompy = v_codcompy
           and dteeffec = (select max(dteeffec)
                             from tpfhinf
                            where	codcompy = v_codcompy
                              and dteeffec <= trunc(sysdate));
      exception when no_data_found then
        v_dteeffec_tmp := null;
      end;
      --
      for r1 in c1 loop
        v_flg_found := true;
        v_numseq    := r1.numseq;
        if r1.syncond is not null then
          get_service_year(v_dteempmt,nvl(v_dteeffex,trunc(sysdate)),'Y',v_year,v_month,v_day);
          v_qtywork := v_year * 12 + v_month;
          get_service_year(v_dteempdb,sysdate,'Y',v_year,v_month,v_day);
          v_cond := r1.syncond;
          v_cond := replace(v_cond,'V_TEMPLOY.CODEMPID'  ,''''||v_codempid||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.CODCOMP'   ,''''||v_codcomp||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.CODPOS'    ,''''||v_codpos||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.TYPEMP'    ,''''||v_typemp||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.CODEMPMT'  ,''''||v_codempmt||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.TYPPAYROLL',''''||v_typpayroll||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.STAEMP'    ,''''||v_staemp||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.DTEEMPMT'  ,'to_date('''||to_char(v_dteempmt,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
          v_cond := replace(v_cond,'V_TEMPLOY.QTYWORK'   ,v_qtywork);
          v_cond := replace(v_cond,'V_TEMPLOY.AGES'      ,v_year);
          v_cond := replace(v_cond,'V_TEMPLOY.NUMLVL'    ,''''||v_numlvl||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.JOBGRADE'  ,''''||v_jobgrade||'''');
          v_cond := replace(v_cond,'TPFMEMB.CODPFINF'    ,''''||v_codpfinf||'''');
          v_stmt := 'select count(*) from dual where '||v_cond;
          v_flg_found := execute_stmt(v_stmt);
        end if;
        if v_flg_found then
          v_year  := null;
          v_month := null;
          v_day   := null;
          if r1.flgconret = '1' then
--            get_service_year(v_dteeffec,v_dtereti,'Y',v_year,v_month,v_day);
            get_service_year(v_dteeffec,v_dtereti,'Y',v_year,v_month,v_day);
          elsif r1.flgconret = '2' then
          	get_service_year(v_dteempmt,nvl(v_dteeffex,trunc(sysdate)),'Y',v_year,v_month,v_day);
          end if;
          v_year := (v_year * 12)  + nvl(v_month,0) ;
          for r2 in c2 loop
            return to_char(r2.ratecsbt,'fm999999999990.00');
          end loop;
          exit;
        end if;
      end loop;
    end;
    return null;
  end;
end hrpybdx;

/

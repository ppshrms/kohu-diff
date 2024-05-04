--------------------------------------------------------
--  DDL for Package Body HRPYB4E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYB4E" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := check_emp(get_emp);--web_service.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtereti_fr        := to_date(hcm_util.get_string_t(json_obj,'p_dtereti_fr'),'dd/mm/yyyy');
    p_dtereti_to        := to_date(hcm_util.get_string_t(json_obj,'p_dtereti_to'),'dd/mm/yyyy');

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_nummember         := hcm_util.get_string_t(json_obj,'p_nummember');
    p_dtereti           := to_date(hcm_util.get_string_t(json_obj,'p_dtereti'),'dd/mm/yyyy');
    p_numvcher          := hcm_util.get_string_t(json_obj,'p_numvcher');
    p_desnote           := hcm_util.get_string_t(json_obj,'p_desnote');
    p_dtevcher          := to_date(hcm_util.get_string_t(json_obj,'p_dtevcher'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
    flgsecu      boolean := false;
    v_codcomp    varchar2(100 char);
  begin
    --
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_dtereti_fr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dtereti_fr');
      return;
    end if;

    if p_dtereti_to is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dtereti_to');
      return;
    end if;

    if p_dtereti_fr > p_dtereti_to then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang,'dtereti_fr');
      return;
    end if;
  end;

  procedure check_detail is
    FLGSECU        BOOLEAN := FALSE;
    V_FLGEMP       VARCHAR2(1 CHAR);
    v_dtereti      date;
    v_flgsecu			 boolean;
    v_emp          temploy1.codempid%type;
    v_zupdsal      varchar2(8);
  begin

    if p_codempid_query is not null then
      begin
        select codempid
        into v_emp
        from temploy1
        where codempid = p_codempid_query;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      end;
      --
      v_flgsecu := secur_main.secur2(p_codempid_query,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if not v_flgsecu then
        return;
      end if;
    end if;

    begin
      select flgemp, dtereti, codpfinf, codplan into v_flgemp, v_dtereti, p_codpfinf, p_codplan
      from tpfmemb
      where codempid = p_codempid_query;
      if v_flgemp <> '2' or v_dtereti is null then
        param_msg_error := get_error_msg_php('PY0034',global_v_lang,'TPFMEMB');
        return;
      end if;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPFMEMB');
      return;
    end;

  end;
--
  procedure check_save_detail is
    v_codempid     varchar2(100 char);
  begin
    if p_codempid_query is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
      return;
    --<<nut 
    /*elsif p_sumamt1 + p_sumamt2 < p_amtretn then
      param_msg_error := get_error_msg_php('PY0024',global_v_lang);
      return;*/
    elsif (nvl(p_sumamt1,0) < nvl(p_amtretn,0)) or (nvl(p_sumamt2,0) < nvl(p_amtcaccu2,0)) then 
      param_msg_error := get_error_msg_php('PY0024',global_v_lang);
      return;
    -->>nut 
    elsif ((nvl(p_amtcaccu2,0) + nvl(p_amtretn,0))) < nvl(p_amttax,0) then--nut ((p_amtcaccu + p_amtretn) - p_amttax) < p_amttax then
      param_msg_error := get_error_msg_php('PY0018',global_v_lang);
      return;
    else
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser,global_v_lang, p_codempid_query,false);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end;

  function get_ratecsbt(v_codempid varchar2, v_codcomp varchar2) return number is
    v_dteeffec1       date;
    v_dtereti         date;
    v_codpfinf        varchar2(4000 char);

    v_desc            varchar2(4000 char);
    v_stmt            varchar2(4000 char);
    v_flgfound        boolean;
    v_numseq          number;
    v_monthmember     number;
    v_ratecret        number;
    v_monthwork       number;
    v_flgconret       tpfeinf.flgconret%type;
    v_yreexp          number;
      cursor c_emp is
        select v_temploy.*
        from 	v_temploy
        where codempid = v_codempid;

      cursor c_tpfeinf is
      select codcompy, dteeffec, numseq, syncond, flgconret
       from tpfeinf
      where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
        and dteeffec = (select max(dteeffec) from tpfhinf
                            where codcompy = codcompy
                            and codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                            and dteeffec <= trunc(sysdate))
       order by numseq;
  begin
      begin
       select max(dteeffec) into v_dteeffec1
        from tpfhinf
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec <= sysdate;
      exception when no_data_found then
        v_dteeffec1 := null;
      end;

      for r2 in c_emp loop
        for r1 in c_tpfeinf loop

          if r1.syncond is not null then
            v_desc := r1.syncond;

            v_desc := replace(v_desc,'V_TEMPLOY.CODEMPID',''''||r2.codempid||'''');
            v_desc := replace(v_desc,'V_TEMPLOY.CODCOMP',''''||r1.codcompy||'''');
            v_desc := replace(v_desc,'V_TEMPLOY.CODPOS',''''||r2.codpos||'''');
            v_desc := replace(v_desc,'V_TEMPLOY.TYPEMP',''''||r2.typemp||'''');
            v_desc := replace(v_desc,'V_TEMPLOY.CODEMPMT',''''||r2.codempmt||'''');
            v_desc := replace(v_desc,'V_TEMPLOY.TYPPAYROLL',''''||r2.typpayroll||'''');
            v_desc := replace(v_desc,'V_TEMPLOY.STAEMP',''''||r2.staemp||'''');
            v_desc := replace(v_desc,'V_TEMPLOY.DTEEMPMT',''''||r2.dteempmt||'''');
            v_desc := replace(v_desc,'V_TEMPLOY.QTYWORK',r2.qtywork); --09/12/2020 not text
            v_desc := replace(v_desc,'V_TEMPLOY.AGES',r2.ages); --09/12/2020 not text
            v_desc := replace(v_desc,'V_TEMPLOY.NUMLVL',r2.numlvl); --09/12/2020 not text
            v_desc := replace(v_desc,'V_TEMPLOY.JOBGRADE',''''||r2.jobgrade||'''');
            v_desc := replace(v_desc,'TPFMEMB.CODPFINF',''''||v_codpfinf||'''');

            v_stmt := 'select count(*) from dual where '||v_desc;
            v_flgfound := execute_stmt(v_stmt);
            if v_flgfound then
              v_numseq    := r1.numseq;
              v_flgconret := r1.flgconret;
              goto jump;
            end if;
          end if;
        end loop;
      end loop;
      <<jump>>
      if v_flgconret = 1 then
        v_yreexp := p_qtymember;
      else
        v_yreexp := p_qtywrkmth;
      end if;

      begin
        select ratecsbt
          into v_ratecret
          from tpfcinf
         where codcompy =  v_codcomp
           and dteeffec = v_dteeffec1
           and numseq	 = v_numseq
           and v_yreexp between qtyyrst and qtyyren
           and rownum <= 1;
      exception when no_data_found then
        v_dteeffec1 := null;
      end;
      return v_ratecret;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;
    v_pathfile          varchar2(100 char);
    v_flg_secure        boolean := false;
    v_flg_exist         boolean := false;
    v_flg_permission    boolean := false;

    cursor c1 is
       select codempid, dtereti, ratecret, nummember
         from tpfpay
        where codcomp like p_codcomp || '%'
          and dtereti between p_dtereti_fr and p_dtereti_to
     order by codempid;

  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
--    if not v_flg_exist then
--      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tpfpay');
--      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--      return;
--    end if;
    --
    for r1 in c1 loop
      v_flg_secure := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('rcnt', to_char(v_rcnt));

        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('nummember', r1.nummember);
        obj_data.put('dtereti', to_char(r1.dtereti,'dd/mm/yyyy'));
        v_pathfile := get_emp_img (r1.codempid);
        obj_data.put('image', nvl(v_pathfile,r1.codempid));
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if not v_flg_permission and v_rcnt > 0 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_detail (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      json_str_output := gen_detail(json_str_input);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  function gen_detail(json_str_input in clob) return clob is
    obj_detail1       json_object_t := json_object_t();
    detail1_stmt      clob;

    obj_detail2       json_object_t := json_object_t();
    obj_detail3       json_object_t := json_object_t();
    detail3_stmt      clob;

    obj_table1        json_object_t := json_object_t();
    table1_stmt       clob;

    v_row_table2      number := 0;
    obj_datatable2    json_object_t := json_object_t();
    obj_table2        json_object_t := json_object_t();
    table2_stmt       clob;

    obj_output        json_object_t := json_object_t();
    json_str_output   clob;

    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;
    v_codempid        varchar2(100 char);
    v_codpfinf        varchar2(100 char);
    v_codplan         varchar2(100 char);
    v_codreti         varchar2(100 char);
    v_dteempmt        date;
    v_dteeffec        date;
    v_dteeffec1       date;
    v_dteeffex        date;
    v_dtereti         date;

    v_yearwork        number;
    v_monthwork       number;
    v_daywork         number;
    v_yearmember      number;
    v_monthmember     number;
    v_daymember       number;

    v_sum_amtprovte   number;
    v_sum_amtprovtc   number;

    v_accmembe        number;
    v_accinte  				number;
    v_accmembc 				number;
    v_accintc  				number;
    v_amtinte  				number;
    v_amtintc  				number;
    v_rateeret 				number;
    v_amtretn         number;
    v_amtcaccu        number;
    v_amtcaccu2       number;
    v_amttax          number;
    v_numvcher        varchar2(4000 char);
    v_desc            varchar2(4000 char);
    v_stmt            varchar2(4000 char);
    v_flgfound        boolean;
    v_numseq          number;

    v_tmp_dteeffec   varchar2(20 char);
    v_old_dteeffec   varchar2(20 char);
    v_old_codplan    varchar2(10 char);
    v_all_pctinvt    number := 0;
    v_sum_rate1        varchar2(100 char);
    v_sum_rate2        varchar2(100 char);
    v_sum_rate3        varchar2(100 char);
    v_sum_rate4        varchar2(100 char);
    v_sum_total        varchar2(100 char);

    v_amteaccu           number  := 0;
    v_amtintaccu         number  := 0;
    v_amtinteccu         number  := 0;

    v_ratecsbt        tpfcinf.ratecsbt%type;

    cursor c_table1 is
            select a.codempid,a.codplan, (a.dteeffec),b.codpolicy,b.codpfinf,b.pctinvt
              from tpfirinf a, tpfpcinf b ,tpfmemb c
             where a.codempid = p_codempid_query
                 and  a.codempid = c.codempid
                  and b.codcompy = hcm_util.get_codcomp_level(c.codcomp,1)
                  and b.codpfinf = a.codpfinf
                  and b.codplan = a.codplan
                  and b.dteeffec = ( select max(d.dteeffec) from tpfpcinf d
                                 where codcompy = hcm_util.get_codcomp_level(c.codcomp,1)
                                   and codpfinf = a.codpfinf
                                   and codplan  = a.codplan
                                   and dteeffec <= a.dteeffec)

            order by a.dteeffec desc;

  begin
    initial_value(json_str_input);
    if p_dtereti is null then
      begin
        select dtereti into p_dtereti
          from tpfmemb
         where codempid = p_codempid_query;
      exception when no_data_found then
        p_dtereti := null;
        -- p_dtereti always should not null *****
      end;
    end if;

    if p_codcomp is null then
      begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into p_codcomp
          from temploy1
         where codempid = p_codempid_query;
      exception when no_data_found then
        p_codcomp := null;
      end;
    end if;

    ------------------detail1-------------------
    /*--09/12/2020
    detail1_stmt := q'[
      select t1.codempid,
             to_char(t2.dteempmt, 'dd/mm/yyyy') dteempmt,
             to_char(t1.dteeffec, 'dd/mm/yyyy') dteeffec,
             to_char(t2.dteeffex, 'dd/mm/yyyy') dteeffex,
             to_char(t1.dtereti, 'dd/mm/yyyy') dtereti,
             t1.codpfinf,
             get_tcodec_name('TCODPFINF', codpfinf, :p_lang) desc_codpfinf,
             t1.codplan,
             get_tcodec_name('TCODPFPLN', codplan, :p_lang) desc_codplan,
             t1.codreti,
             get_tcodec_name('TCODEXEM', t1.codreti, :p_lang) causeout
        from tpfmemb t1, temploy1 t2
        where t1.codempid = t2.codempid and
             t1.codempid = :p_codempid
    ]';
    hcm_statement.bind(detail1_stmt, ':p_codempid', p_codempid_query);
    hcm_statement.bind(detail1_stmt, ':p_lang', global_v_lang);*/
    find_emp_data(detail1_stmt,
                  v_yearwork,v_monthwork,v_daywork,v_yearmember,v_monthmember,v_daymember); --09/12/2020
    obj_detail1 := hcm_statement.execute_obj_t(detail1_stmt, 'record');
    /*--09/12/2020
    v_dteempmt := to_date(hcm_util.get_string_t(obj_detail1, 'dteempmt'), 'dd/mm/yyyy');
    v_dteeffex := to_date(hcm_util.get_string_t(obj_detail1, 'dteeffex'), 'dd/mm/yyyy');
    v_dteeffec := to_date(hcm_util.get_string_t(obj_detail1, 'dteeffec'), 'dd/mm/yyyy');
    v_dtereti  := to_date(hcm_util.get_string_t(obj_detail1, 'dtereti'), 'dd/mm/yyyy');
    v_codpfinf := hcm_util.get_string_t(obj_detail1, 'codpfinf');
    get_service_year(v_dteempmt,nvl(v_dteeffex ,trunc(sysdate)),'Y',v_yearwork,v_monthwork,v_daywork);
    get_service_year(v_dteeffec  , v_dtereti ,'Y',v_yearmember,v_monthmember,v_daymember);*/
    obj_detail1.put('yearwork', v_yearwork);
    obj_detail1.put('monthwork', v_monthwork);
    obj_detail1.put('daywork', v_daywork);
    obj_detail1.put('yearmember', v_yearmember);
    obj_detail1.put('monthmember', v_monthmember);
    obj_detail1.put('daymember', v_daymember);

    ------------------table1-------------------
    v_rcnt := 0;
    for r1 in c_table1 loop
      v_rcnt           := v_rcnt + 1;
      obj_data         := json_object_t();
      v_tmp_dteeffec   := to_char(r1.dteeffec,'dd/mm/yyyy');

      if v_old_dteeffec is not null and v_old_codplan is not null and (v_old_dteeffec <> v_tmp_dteeffec or v_old_codplan <> r1.codplan) then
          obj_data.put('dteeffec', '');
          obj_data.put('codplan','');
          obj_data.put('desc_codplan', '');
          obj_data.put('codpolicy', '');
          obj_data.put('desc_codpolicy', get_label_name('HRPYB4EC2',global_v_lang,'170'));
          obj_data.put('qtycompst', v_all_pctinvt);
          v_old_dteeffec   := '';
          v_old_codplan    := '';
          obj_table1.put(to_char(v_rcnt - 1), obj_data);
          v_rcnt           := v_rcnt + 1;
          v_all_pctinvt := 0;
      end if;

          obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
          obj_data.put('codplan', r1.codplan);
          obj_data.put('desc_codplan', get_tcodec_name('TCODPFPLN', r1.codplan,global_v_lang));
          obj_data.put('codpolicy', r1.codpolicy);
          obj_data.put('desc_codpolicy', get_tcodec_name('TCODPFPLC', r1.codpolicy, global_v_lang));
          obj_data.put('qtycompst', r1.pctinvt);
          v_all_pctinvt    := v_all_pctinvt + r1.pctinvt;
          v_old_dteeffec   := to_char(r1.dteeffec,'dd/mm/yyyy');
          v_old_codplan    := r1.codplan;

          obj_table1.put(to_char(v_rcnt - 1), obj_data);
       end loop;

      if v_rcnt > 0 then
          obj_data         := json_object_t();
          obj_data.put('dteeffec', '');
          obj_data.put('codplan','');
          obj_data.put('desc_codplan', '');
          obj_data.put('codpolicy', '');
          obj_data.put('desc_codpolicy', get_label_name('HRPYB4EC2',global_v_lang,'170'));
          obj_data.put('qtycompst', v_all_pctinvt);
          v_rcnt           := v_rcnt + 1;
          obj_table1.put(to_char(v_rcnt - 1), obj_data);
      end if;
    ------------------detail section 2-------------------
    v_amttax := 10;
    v_rateeret := '100';
    begin
      select stddec(amtretn, codempid, v_chken),
             stddec(amtcaccu, codempid, v_chken),
             stddec(amttax, codempid, v_chken),
             numvcher
        into v_amtretn, v_amtcaccu2, v_amttax,
             v_numvcher
        from tpfpay
       where codempid = p_codempid_query
         and dtereti  = p_dtereti;
    exception when no_data_found then
      v_amtretn     := null;
      v_amtcaccu2   := null;
      v_amttax      := null;
      v_numvcher    := null;
    end;
    p_qtywrkmth   :=  (v_yearwork*12) + v_monthwork;
    p_qtymember   :=  (v_yearmember*12) + v_monthmember;

    v_ratecsbt    := get_ratecsbt(p_codempid_query, p_codcomp);

    begin
      select stddec(amteaccu, p_codempid_query, v_chken),stddec(amtintaccu, p_codempid_query, v_chken),
             stddec(amtcaccu, p_codempid_query, v_chken),stddec(amtinteccu, p_codempid_query, v_chken)
        into v_amteaccu, v_amtintaccu, v_amtcaccu, v_amtinteccu
        from tpfmemb
       where codempid = p_codempid_query;
    exception when no_data_found then
      v_amteaccu := null;
      v_amtintaccu := null;
      v_amtcaccu := null;
      v_amtinteccu := null;
    end;

    obj_detail2.put('amteaccu', to_char(v_amteaccu,'fm999,999,999,990.00'));
    obj_detail2.put('amtintaccu', to_char(v_amtintaccu,'fm999,999,999,990.00'));
    obj_detail2.put('amtcaccu', to_char(v_amtcaccu,'fm999,999,999,990.00'));
    obj_detail2.put('amtinteccu', to_char(v_amtinteccu,'fm999,999,999,990.00'));
    obj_detail2.put('rateeret', to_char(v_rateeret));
    obj_detail2.put('ratecsbt', to_char(v_ratecsbt));

    v_sum_rate1 := nvl(v_amteaccu,0) * (v_rateeret / 100);
    v_sum_rate2 := nvl(v_amtintaccu,0) * (v_rateeret / 100);
    v_sum_rate3 := nvl(v_amtcaccu,0) * (v_ratecsbt / 100);
    v_sum_rate4 := nvl(v_amtinteccu,0) * (v_ratecsbt / 100);
    if v_amtretn is not null and v_amtcaccu2 is not null then
      v_sum_total := v_amtretn + v_amtcaccu2;
    else
      v_sum_total := v_sum_rate1 + v_sum_rate2 + v_sum_rate3 + v_sum_rate4;
    end if;
    obj_detail2.put('sum_rate1', to_char(v_sum_rate1,'FM9,999,999,990.90'));
    obj_detail2.put('sum_rate2', to_char(v_sum_rate2,'FM9,999,999,990.90'));
    obj_detail2.put('sum_rate3', to_char(v_sum_rate3,'FM9,999,999,990.90'));
    obj_detail2.put('sum_rate4', to_char(v_sum_rate4,'FM9,999,999,990.90'));

    ------------------detail3-------------------
    detail3_stmt := q'[
      select numvcher, to_char(dtevcher, 'dd/mm/yyyy') dtevcher,
            desnote
        from tpfpay
       where codempid = :p_codempid
          and dtereti = :p_dtereti
    ]';
    hcm_statement.bind(detail3_stmt, ':p_codempid', p_codempid_query);
    hcm_statement.bind(detail3_stmt, ':p_dtereti', to_char(p_dtereti, 'dd/mm/yyyy'), 'date');

    --<<nut 
    if v_amttax is null then
        v_amttax := 0.1*v_sum_total;
    end if;
    -->>nut 

    obj_detail3 := hcm_statement.execute_obj_t(detail3_stmt, 'record');
    obj_detail3.put('amtretn', nvl(v_amtretn,v_sum_rate1 + v_sum_rate2));
    obj_detail3.put('amtcaccu2', nvl(v_amtcaccu2,v_sum_rate3 + v_sum_rate4));
    obj_detail3.put('amttax', v_amttax);
    obj_detail3.put('amttotal', v_sum_total);
    obj_detail3.put('amtnet', to_char(v_sum_total - v_amttax,'FM9,999,999,990.90'));
    obj_detail3.put('numvcher', v_numvcher);

    obj_output.put('coderror', '200');
    obj_output.put('detail1', obj_detail1);
    obj_output.put('table1', obj_table1);
    obj_output.put('detail2', obj_detail2);
    obj_output.put('detail3', obj_detail3);

    json_str_output := obj_output.to_clob;
    return json_str_output;

  end gen_detail;

  procedure find_emp_data(detail1_stmt out clob,
                          v_yearwork out number,v_monthwork out number,v_daywork out number,
                          v_yearmember out number,v_monthmember out number,v_daymember out number) is
    obj_detail1       json_object_t := json_object_t();

    v_dteempmt        date;
    v_dteeffec        date;
    v_dteeffec1       date;
    v_dteeffex        date;
    v_dtereti         date;
  begin
    detail1_stmt := q'[
      select t1.codempid,
             to_char(t2.dteempmt, 'dd/mm/yyyy') dteempmt,
             to_char(t1.dteeffec, 'dd/mm/yyyy') dteeffec,
             to_char(t2.dteeffex, 'dd/mm/yyyy') dteeffex,
             to_char(t1.dtereti, 'dd/mm/yyyy') dtereti,
             t1.codpfinf,
             get_tcodec_name('TCODPFINF', codpfinf, :p_lang) desc_codpfinf,
             t1.codplan,
             get_tcodec_name('TCODPFPLN', codplan, :p_lang) desc_codplan,
             t1.codreti,
             get_tcodec_name('TCODEXEM', t1.codreti, :p_lang) causeout
        from tpfmemb t1, temploy1 t2
        where t1.codempid = t2.codempid and
             t1.codempid = :p_codempid
    ]';
    hcm_statement.bind(detail1_stmt, ':p_codempid', p_codempid_query);
    hcm_statement.bind(detail1_stmt, ':p_lang', global_v_lang);
    obj_detail1 := hcm_statement.execute_obj_t(detail1_stmt, 'record');
    v_dteempmt := to_date(hcm_util.get_string_t(obj_detail1, 'dteempmt'), 'dd/mm/yyyy');
    v_dteeffex := to_date(hcm_util.get_string_t(obj_detail1, 'dteeffex'), 'dd/mm/yyyy');
    v_dteeffec := to_date(hcm_util.get_string_t(obj_detail1, 'dteeffec'), 'dd/mm/yyyy');
    v_dtereti  := to_date(hcm_util.get_string_t(obj_detail1, 'dtereti'), 'dd/mm/yyyy');

    get_service_year(v_dteempmt,nvl(v_dteeffex ,trunc(sysdate)),'Y',v_yearwork,v_monthwork,v_daywork);
    get_service_year(v_dteeffec  , v_dtereti ,'Y',v_yearmember,v_monthmember,v_daymember);
  end find_emp_data;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    json_obj        json_object_t;
    v_flg           varchar2(1000);
    v_secur         varchar2(4000 char);
    v_rateeret 			number;
    v_ratecret 			number;
    v_amtretn       number;
    v_amtcaccu      number;

  begin
--    check_index;
    json_obj            := json_object_t(json_str_input);
    param_json          := json_object_t(hcm_util.get_string_t(json_obj,'json_input_str'));
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');

    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        --
        p_codempid_query       := hcm_util.get_string_t(param_json_row,'codempid');
        p_dtereti              := to_date(hcm_util.get_string_t(param_json_row,'dtereti'), 'dd/mm/yyyy');
        v_flg                  := hcm_util.get_string_t(param_json_row,'flg');

        v_secur := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid_query);
        if v_secur is not null then
          param_msg_error := v_secur;
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          rollback;
          return;
        end if;

        if v_flg = 'delete' then
          begin
          select stddec(amtcaccu, p_codempid_query, v_chken),
                 stddec(amtretn, p_codempid_query, v_chken),
                 rateeret, ratecret
            into v_amtcaccu, v_amtretn, v_rateeret, v_ratecret
            from tpfpay
             where codempid = p_codempid_query
            and dtereti = p_dtereti ;
          exception when no_data_found then
            v_amtcaccu := null;
            v_amtretn := null;
            v_rateeret := null;
            v_ratecret := null;
          end;

          begin
          update tpfmemb
            set rateeret = nvl(rateeret,0)-   nvl(v_rateeret,0),
                ratecret = nvl(ratecret,0) -  nvl(v_ratecret,0),
                amtcretn = stdenc(nvl(to_number(stddec(amtcretn, p_codempid_query , v_chken)),0) - nvl(v_amtcaccu,0), p_codempid_query, v_chken),
                amteretn = stdenc(nvl(to_number(stddec(amteretn, p_codempid_query, v_chken)),0) - nvl(v_amtretn,0), p_codempid_query, v_chken),
                dteupd   = trunc(sysdate),
                coduser  = global_v_coduser
          where codempid = p_codempid_query
            and dtereti = p_dtereti ;

          delete from tpfpay
                where codempid = p_codempid_query
                   and dtereti = p_dtereti ;
          end;
        end if;
      end loop;
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    json_param_obj    json_object_t := json_object_t(json_str_input);
    p_nummember       varchar2(15 char);
    t_tpfmemb         tpfmemb%rowtype;

    detail1_stmt      clob;
    v_codpfinf        varchar2(100 char);
    v_dteempmt        date;
    v_dteeffec        date;
    v_dteeffec1       date;
    v_dteeffex        date;
    v_dtereti         date;
    v_yearwork        number;
    v_monthwork       number;
    v_daywork         number;
    v_yearmember      number;
    v_monthmember     number;
    v_daymember       number;
  begin
    initial_value(json_str_input);
    p_codempid_query      := hcm_util.get_string_t(json_param_obj,'p_codempid_query');
    p_dtereti       		  := to_date(hcm_util.get_string_t(json_param_obj,'p_dtereti'), 'dd/mm/yyyy');
    p_amtcaccu2       		:= to_number(hcm_util.get_string_t(json_param_obj,'p_amtcaccu2'));
    p_amtretn       		  := to_number(hcm_util.get_string_t(json_param_obj,'p_amtretn'));
    p_amttax              := to_number(hcm_util.get_string_t(json_param_obj,'p_amttax'));
    p_numvcher            := hcm_util.get_string_t(json_param_obj,'p_numvcher');
    p_dtevcher            := to_date(hcm_util.get_string_t(json_param_obj,'p_dtevcher'), 'dd/mm/yyyy');
    p_desnote             := hcm_util.get_string_t(json_param_obj,'p_desnote');
    p_sumamt1             := to_number(hcm_util.get_string_t(json_param_obj,'p_sumamt1'));
    p_sumamt2             := to_number(hcm_util.get_string_t(json_param_obj,'p_sumamt2'));
    p_codpfinf             := hcm_util.get_string_t(json_param_obj,'p_codpfinf');

    check_save_detail;

    begin
      select codcomp, nummember into p_codcomp, p_nummember
       from tpfmemb
      where codempid = p_codempid_query;
    exception when no_data_found then
      p_codcomp := null;
    end;

    --<<09/12/2020
    p_rateeret := '100';

    find_emp_data(detail1_stmt,
                  v_yearwork,v_monthwork,v_daywork,v_yearmember,v_monthmember,v_daymember);
    p_qtywrkmth   :=  (v_yearwork*12) + v_monthwork;
    p_qtymember   :=  (v_yearmember*12) + v_monthmember;

    p_ratecret := get_ratecsbt(p_codempid_query, hcm_util.get_codcomp_level(p_codcomp,1));
    -->>09/12/2020

    if param_msg_error is null then
      if p_dtereti is null then
        begin
          select dtereti into p_dtereti
            from tpfmemb
           where codempid = p_codempid_query;
        exception when no_data_found then
          p_dtereti := null;
          p_nummember := null;
          -- p_dtereti always should not null *****
        end;
      end if;

      begin
        insert into tpfpay (
              codempid,   dtereti,    amtretn,    amtcaccu,   amttax,
              numvcher,   dtevcher,   desnote,    codcomp,    nummember,
              coduser,    codcreate,  dtecreate,  codpfinf,
              rateeret,   ratecret) --09/12/2020
             values (
              p_codempid_query,
              p_dtereti,
              stdenc(p_amtretn, p_codempid_query, v_chken),
              stdenc(p_amtcaccu2, p_codempid_query, v_chken),
              stdenc(p_amttax, p_codempid_query, v_chken),
              p_numvcher,
              p_dtevcher,
              p_desnote,
              p_codcomp, p_nummember,
              global_v_coduser, global_v_coduser, sysdate, p_codpfinf,
              p_rateeret, p_ratecret); --09/12/2020
      exception when dup_val_on_index then
        update tpfpay set amtretn  =   stdenc(p_amtretn, p_codempid_query, v_chken),
                          amtcaccu =   stdenc(p_amtcaccu2, p_codempid_query, v_chken),
                          amttax   =   stdenc(p_amttax, p_codempid_query, v_chken),
                          numvcher =   p_numvcher,
                          dtevcher =   p_dtevcher,
                          desnote  =   p_desnote,
                          dteupd   =   sysdate,
                          coduser  =   global_v_coduser,
                          codpfinf =   p_codpfinf,
                          rateeret =   p_rateeret, --09/12/2020
                          ratecret =   p_ratecret --09/12/2020
                      where codempid  = p_codempid_query
                        and dtereti =  p_dtereti;
      end;
      begin
        update tpfmemb
           set amtcretn	  = stdenc(p_amtcaccu2, p_codempid_query, v_chken),
               amteretn	  = stdenc(p_amtretn, p_codempid_query, v_chken),
               dteupd     = trunc(sysdate),
               coduser    = global_v_coduser
         where codempid   = p_codempid_query
           and dtereti    = p_dtereti;
      end;

      begin
        select *
          into t_tpfmemb
          from tpfmemb
         where codempid   = p_codempid_query;
      end;

      begin
        insert into tpfregst(codempid,dtereti,dteeffec,codreti,codpfinf,
                             codplan,amtcaccu,amtcretn,amteaccu,amteretn,
                             amtinteccu,amtintaccu,rateeret,ratecret,
                             codcreate,coduser)
        values (p_codempid_query,t_tpfmemb.dtereti,t_tpfmemb.dteeffec,t_tpfmemb.codreti,t_tpfmemb.codpfinf,
                t_tpfmemb.codplan,t_tpfmemb.amtcaccu,t_tpfmemb.amtcretn,t_tpfmemb.amteaccu,t_tpfmemb.amteretn,
                t_tpfmemb.amtinteccu,t_tpfmemb.amtintaccu,
                p_rateeret, p_ratecret, --09/12/2020 ||t_tpfmemb.rateeret,t_tpfmemb.ratecret,
                global_v_coduser,global_v_coduser);

      exception when dup_val_on_index then
        update tpfregst
           set dteeffec       = t_tpfmemb.dteeffec,
               codreti        = t_tpfmemb.codpfinf,
               codpfinf       = t_tpfmemb.codplan,
               codplan        = t_tpfmemb.codreti,
               amtcaccu       = t_tpfmemb.amtcaccu,
               amtcretn       = t_tpfmemb.amtcretn,
               amteaccu       = t_tpfmemb.amteaccu,
               amteretn       = t_tpfmemb.amteretn,
               amtinteccu     = t_tpfmemb.amtinteccu,
               amtintaccu     = t_tpfmemb.amtintaccu,
               rateeret       = p_rateeret, --09/12/2020 ||t_tpfmemb.rateeret,
               ratecret       = p_ratecret, --09/12/2020 ||t_tpfmemb.ratecret,
               coduser        = global_v_coduser
         where codempid   = p_codempid_query
           and dtereti    = t_tpfmemb.dtereti;
      end;

      if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
END HRPYB4E;

/

--------------------------------------------------------
--  DDL for Package Body HRBF5JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF5JE" as

-- last update: 27/01/2021 17:31

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_index');
    p_codlon            := hcm_util.get_string_t(json_obj,'p_codlon');
    p_amtlonap          := hcm_util.get_string_t(json_obj,'p_amtlonap');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_codlon    ttyploan.codlon%type;
    v_flgSecur  boolean;
    v_flgfound  boolean;
    v_dteempmt          temploy1.dteempmt%type;
    v_numlvl            temploy1.numlvl%type;
    v_codpos            temploy1.codpos%type;
    v_jobgrade          temploy1.jobgrade%type;
    v_condlon           ttyploan.condlon%type;
    v_statment          ttyploan.condlon%type;
    v_year              number;
    v_month             number;
    v_day               number;
  begin
    if p_codempid is not null then
      begin
        select staemp into v_staemp
        from temploy1
        where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
      v_flgSecur := secur_main.secur2(p_codempid, global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if not v_flgSecur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      end if;
      if v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang);
      return;
    end if;

    if p_codlon is not null then
      begin
        select codlon into v_codlon
        from ttyploan
        where codlon = p_codlon;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttyploan');
        return;
      end;
      begin
        select codcomp, dteempmt, numlvl, codpos, jobgrade
          into v_codcomp, v_dteempmt, v_numlvl, v_codpos, v_jobgrade
          from temploy1
        where codempid = p_codempid;
        get_service_year(v_dteempmt, sysdate, 'Y', v_year, v_month, v_day);
        begin
          select condlon
            into v_condlon
            from ttyploan
           where codlon = p_codlon;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'ttyploan');
          return;
        end;
        if v_condlon is not null then
          v_statment := v_condlon;
          v_statment := replace(v_statment, 'V_HRPMA1.CODCOMP', '''' || v_codcomp || '''');
          v_statment := replace(v_statment, 'V_HRPMA1.CODPOS', '''' || v_codpos || '''');
          v_statment := replace(v_statment, 'V_HRPMA1.NUMLVL', v_numlvl);
          v_statment := replace(v_statment, 'V_HRPMA1.JOBGRADE', '''' || v_jobgrade || '''');
          v_statment := replace(v_statment, 'V_HRPMA1.AGE', ((v_year * 12) + v_month));
          v_statment := 'select count(*) from dual where ' || v_statment;
          v_flgfound := execute_stmt(v_statment);
          if not v_flgfound then
            param_msg_error := get_error_msg_php('BF0008', global_v_lang);
            return;
          end if;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang);
      return;
    end if;
  end;
  procedure gen_detail(json_str_output out clob)as
    obj_data        json_object_t;
    v_flgAppr       boolean;
    v_flgExist      boolean := false;
    p_check         varchar2(10 char);
    v_amount        number := 0;

    v_codcomp       temploy1.codcomp%type;
    v_amtmxlon      ttyploan.amtmxlon%type;
    v_nummxlon      ttyploan.nummxlon%type;--User37 #3992 BF - PeoplePlus 31/03/2021
    v_RATEILON      tintrteh.RATEILON%type;
    v_ratelon       ttyploan.ratelon%type;
    v_interest      tintrted.rateilon%type;
    v_typintr       tintrteh.typintr%type;
    v_formula       tintrteh.formula%type;
    v_statement     tintrteh.statement%type;

    v_dteeffec      varchar2(100 char);

    --v_codcomp           temploy1.codcomp%type;
    v_codempmt          temploy1.codempmt%type;
    v_codcompy          tcompny.codcompy%type;
    v_amtincom1         temploy3.amtincom1%type;
    v_amtincom2         temploy3.amtincom2%type;
    v_amtincom3         temploy3.amtincom3%type;
    v_amtincom4         temploy3.amtincom4%type;
    v_amtincom5         temploy3.amtincom5%type;
    v_amtincom6         temploy3.amtincom6%type;
    v_amtincom7         temploy3.amtincom7%type;
    v_amtincom8         temploy3.amtincom8%type;
    v_amtincom9         temploy3.amtincom9%type;
    v_amtincom10        temploy3.amtincom10%type;
    v_amtothr           number;
    v_amtday            number;
    v_amtmth            number;


  begin
    begin
      select codcomp into v_codcomp
      from temploy1
      where codempid = p_codempid;
    exception when no_data_found then
      v_codcomp := '';
    end;
    obj_data := json_object_t();
    begin
      select amtmxlon,
             nummxlon,
             ratelon --User37 #3992 BF - PeoplePlus 31/03/2021
      into v_amtmxlon,
           v_nummxlon,
           v_ratelon--User37 #3992 BF - PeoplePlus 31/03/2021
      from ttyploan
      where codlon = p_codlon;
    exception when no_data_found then
      null;
    end;

    if v_amtmxlon is null and v_ratelon is not null then
        begin
          select codcomp, codempmt,
                 stddec(c.amtincom1, a.codempid, v_chken) amtincom1,
                 stddec(c.amtincom2, a.codempid, v_chken) amtincom2,
                 stddec(c.amtincom3, a.codempid, v_chken) amtincom3,
                 stddec(c.amtincom4, a.codempid, v_chken) amtincom4,
                 stddec(c.amtincom5, a.codempid, v_chken) amtincom5,
                 stddec(c.amtincom6, a.codempid, v_chken) amtincom6,
                 stddec(c.amtincom7, a.codempid, v_chken) amtincom7,
                 stddec(c.amtincom8, a.codempid, v_chken) amtincom8,
                 stddec(c.amtincom9, a.codempid, v_chken) amtincom9,
                 stddec(c.amtincom10, a.codempid, v_chken) amtincom10
            into v_codcomp, v_codempmt,
                 v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                 v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10
            from temploy1 a, temploy3 c
          where a.codempid = p_codempid
            and a.codempid = c.codempid;
          v_codcompy        := hcm_util.get_codcomp_level(v_codcomp, 1);
          get_wage_income(v_codcomp, v_codempmt,
                              v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                              v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10,
                              v_amtothr, v_amtday, v_amtmth);
          if v_amtmth > 0 then
            v_amtmxlon          := nvl(v_amtmth, 0) * nvl(v_ratelon, 0);
          end if;
        exception when no_data_found then
          null;
        end;
      end if;


    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('amtmxlon', v_amtmxlon);
    obj_data.put('borrow', '');
    obj_data.put('amountreq', '');
    obj_data.put('amountloan', '');
    obj_data.put('termyear', 0);
    obj_data.put('termmonth', 0);
    obj_data.put('nummxlon', v_nummxlon);--User37 #3992 BF - PeoplePlus 31/03/2021

    v_dteeffec := get_latest_dteeffec(hcm_util.get_codcomp_level(v_codcomp, 1), p_codlon);

    begin
      select rateilon, a.typintr, a.formula, a.statement into v_interest, v_typintr, v_formula, v_statement
        from tintrteh a
       where a.codcompy  = hcm_util.get_codcomp_level(v_codcomp, 1)
         and a.codlon   = p_codlon
         and a.dteeffec = to_date(v_dteeffec,'dd/mm/yyyy');
    exception when no_data_found then null;
      begin
        select rateilon into v_interest
          from tintrted a
         where a.codcompy  = hcm_util.get_codcomp_level(v_codcomp, 1)
           and a.codlon   = p_codlon
           and a.dteeffec = to_date(v_dteeffec,'dd/mm/yyyy')
           and a.amtlon = (select min(b.amtlon) from tintrted b
                                  where b.codcompy = a.codcompy
                                  and b.codlon = a.codlon
                                  and b.dteeffec = a.dteeffec
                                  and b.amtlon  >= v_amtmxlon );
      exception when no_data_found then null;
      end;
    end;
    obj_data.put('calstatus', v_typintr);
    obj_data.put('interest', v_interest);
    obj_data.put('startpaym', '');
    obj_data.put('startpayy', to_char(trunc(sysdate),'yyyy'));
    obj_data.put('calby', '1');
    obj_data.put('numinstall', '');
    obj_data.put('finalpay', '');
    obj_data.put('install', '');
    obj_data.put('formula', v_formula);
    obj_data.put('description', '');
    obj_data.put('statement', v_statement);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  function get_latest_dteeffec(v_codcompy in varchar2,v_codlon  in varchar2) return varchar2 is
    v_codcomp       temploy1.codcomp%type;
    v_dteeffec      varchar2(100 char);
  begin
    begin
      select to_char(dteeffec,'dd/mm/yyyy') into v_dteeffec
          from tintrteh a
         where a.codcompy  = v_codcompy
           and a.codlon = v_codlon
           and a.dteeffec = (select max(b.dteeffec)
                               from tintrteh b
                              where b.codcompy = a.codcompy
                               and b.codlon = b.codlon
                              and b.dteeffec <= trunc(sysdate));
    exception when no_data_found then
      v_dteeffec := to_char(trunc(sysdate),'dd/mm/yyyy');
    end;
    return v_dteeffec;
  end get_latest_dteeffec;
  function  get_curr (p_codcomp varchar2) return varchar2 Is
   v_codcurr varchar2(4);
  begin
    begin
      select codcurr
      into   v_codcurr
      from   tcontrpy
      where  codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
      and		 dteeffec in ( select max(dteeffec)
                           from   tcontrpy
                           where  dteeffec <= sysdate
                           and    codcompy = hcm_util.get_codcomp_level(p_codcomp, 1))

      and  rownum = 1 ;
      return(v_codcurr) ;
    exception when no_data_found then
      return(null);
    end ;
  end;
  procedure gen_popupdetail(json_str_output out clob)as
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_codcomp       temploy1.codcomp%type;
    v_descurr       TCODCURR.descodt%type;
  begin
    begin
      select codcomp into v_codcomp
      from temploy1
      where codempid = p_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
      return;
    end;
    v_descurr  := get_tcodec_name('TCODCURR',get_curr(v_codcomp),global_v_lang);

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('currency', v_descurr);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_popupdetail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popupdetail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure gen_popuptable(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    cursor c1 is
       select item1,item2,item3,item4,item5,item6,item7
         from ttemprpt
        where codempid = global_v_coduser
          and codapp = 'HRBF5JE2'
     order by numseq;

  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('periodno', r1.item1);
      obj_data.put('period', r1.item2);
      obj_data.put('cuoted', r1.item3);
      obj_data.put('princ', r1.item4);
      obj_data.put('interest', r1.item5);
      obj_data.put('total', r1.item6);
      obj_data.put('deposit', r1.item7);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_popuptable(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popuptable(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure gen_detail_rateilon(json_str_output out clob)as
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_codcomp       temploy1.codcomp%type;
    v_descurr       TCODCURR.descodt%type;
    v_interest       tintrted.rateilon%type;
  begin
    begin
      select codcomp into v_codcomp
      from temploy1
      where codempid = p_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
      return;
    end;
    begin
    select rateilon into v_interest
          from tintrted a
         where a.codcompy  = hcm_util.get_codcomp_level(v_codcomp, 1)
           and a.codlon   = p_codlon  --ประเภทเงินกู้   ที่ระบุ
           and a.dteeffec = (
                                      select max(b.dteeffec)
                                     from TINTRTEH b
                                    where b.codcompy  = a.codcompy
                                      and b.codlon   = a.codlon
                                      and b.dteeffec <= trunc(sysdate) )
           and a.amtlon = (select min(b.amtlon) from tintrted b
                                  where b.codcompy = a.codcompy
                                  and b.codlon = a.codlon
                                  and b.dteeffec = a.dteeffec
                                  and b.amtlon  >= p_amtlonap   --เงินกู้ที่มีสิทธิ์
                                  );
    exception when no_data_found then
      v_interest := null;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('interest', v_interest);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_rateilon(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_rateilon(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure cal_loan (json_str_input in clob, json_str_output out clob) AS

    obj_data            json_object_t;
    json_obj            json_object_t;
    v_response          varchar2(4000 char);

    v_codapp         ttemprpt.codapp%type:= 'HRBF5JE2';
    v_type              varchar2(10);
    v_amttlpay          number;
    v_qtyperiod         number;
    v_flginsert            varchar2(1);
    v_amtlast             number;
    v_amtpint           number;
    v_amtpfin          number;
    v_amtlonap         number;
    v_balamtlon        number;
    v_numseq           number;
    v_typintr          tintrteh.typintr%type;
    v_formula        tintrteh.formula%type;
    v_rateilon          tloaninf.rateilon%TYPE;
    v_statment         tloanadj.formulan%type;

    v_mthpayst	     number;
    v_dteyrpayst	     number;

    v_amtiflat              number;
    v_amtitotflat          number;
    v_qtyperip             number;
    v_sumItem4             number := 0;
    v_sumItem5             number := 0;
    v_sumItem6             number := 0;
    v_sumRndItem4          number := 0;
    v_sumRndItem5          number := 0;
    v_sumRndItem6          number := 0;

     v_item2                ttemprpt.item1%type;
     v_item3                ttemprpt.item1%type;
     v_item4                ttemprpt.item1%type;
     v_item5                ttemprpt.item1%type;
     v_item6                 ttemprpt.item1%type;
     v_item7                ttemprpt.item1%type;

  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    -- clear temp
    begin
      delete ttemprpt
      where codempid = global_v_coduser
      and codapp = 'HRBF5JE2';
    end;
    --get_data--

    v_type              := hcm_util.get_string_t(json_obj,'p_type');                --in  --1 out v_amttlpay , v_amtlast  , v_amtpint  --2 out v_qtyperiod , v_amtlast  , v_amtpint
    v_amttlpay          := hcm_util.get_string_t(json_obj,'p_amttlpay');     --in
    v_qtyperiod         := hcm_util.get_string_t(json_obj,'p_qtyperiod');   --in
    v_flginsert         := hcm_util.get_string_t(json_obj,'p_flginsert');       --in  Y use codapp HRBF5JE2
    v_formula           := hcm_util.get_string_t(json_obj,'p_formula');       --in
    v_rateilon          := nvl(hcm_util.get_string_t(json_obj,'p_rateilon'),0);        --in
    v_typintr           := hcm_util.get_string_t(json_obj,'p_typintr');        --in
    v_amtlonap          := hcm_util.get_string_t(json_obj,'p_amtlonap');        --in
    v_mthpayst	        := hcm_util.get_string_t(json_obj,'p_mthpayst');        --in
    v_dteyrpayst	      := hcm_util.get_string_t(json_obj,'p_dteyrpayst');        --in
    --v_type = 1 out v_amttlpay , v_amtlast  , v_amtpint
    --v_type = 2 out v_qtyperiod , v_amtlast  , v_amtpint

            if v_type = '1' then
                    if  v_typintr = '1' then
                         if v_rateilon > 0 then
                            v_amttlpay  := ceil(v_amtlonap/  ((1- (1/ power((1+ ((v_rateilon/12)/100)  ), v_qtyperiod)))  /  ((v_rateilon/12)/100) ));
                         else
                            v_amttlpay  := ceil(v_amtlonap/  v_qtyperiod);
                         end if;
                         v_amtpint  := 0;
                    elsif v_typintr = '2' then
                            --v_amtiflat         :=  v_amtlonap * (v_rateilon/12/100);
                            v_qtyperip  := 0;
                            v_statment := v_formula;
                            v_statment := replace(v_statment, '[A]', v_amtlonap);
                            --v_statment := replace(v_statment, '[R]',(v_rateilon/12/100)  );
                            v_statment := replace(v_statment, '[R]',(v_rateilon/100)  );
                            v_statment := replace(v_statment, '[T]',  v_qtyperiod);
                            v_statment := replace(v_statment, '[P]', (v_qtyperiod - v_qtyperip));
                            v_statment := 'select '||v_statment||' from dual';
                            v_statment := replace(v_statment,'{','');
                            v_statment := replace(v_statment,'}','');
                            v_amtiflat    := execute_qty(v_statment);

                         	v_amtitotflat     :=  v_amtiflat* v_qtyperiod;
                            v_amttlpay        :=  (v_amtlonap  +  v_amtitotflat)/v_qtyperiod;
                            v_amttlpay        := ceil(v_amttlpay);
                            v_amtpint          := v_amtiflat;
--update a set a = 'v_statment = '||v_statment ; commit ;
--v_formula = {[A]}*{[R]}
                    elsif v_typintr =  '3' then
                             v_amtiflat         :=  v_amtlonap * (v_rateilon/12/100);
                         	v_amtitotflat     :=  v_amtiflat* v_qtyperiod;
                            v_amttlpay        :=  (v_amtlonap  +  v_amtitotflat)/v_qtyperiod;
                            v_amttlpay        := ceil(v_amttlpay);
                            v_amtpint          := v_amtiflat;
                    end if;  --v_amtlast = ? , v_amtpint  = ?
         else  --if v_type = '2' then
             if  v_typintr = '1' then
                  if v_rateilon > 0 then
                      v_qtyperiod  := ceil( log(1+ ((v_rateilon/12)/100), v_amttlpay/(v_amttlpay - (v_amtlonap*((v_rateilon/12)/100)))));
                  else
                      v_qtyperiod  := ceil( v_amtlonap/v_amttlpay );
                  end if;
                 v_amtpint  := 0;
             elsif v_typintr  in ( '2' ,'3')  then
                     if  v_typintr = '2' then
                            v_qtyperip  := 0;
                            v_statment := v_formula;
                            v_statment := replace(v_statment, '[A]', v_amtlonap);
                            --v_statment := replace(v_statment, '(R)',(v_rateilon/12/100)  );
                            v_statment := replace(v_statment, '[R]',(v_rateilon/100)  );
                            v_statment := replace(v_statment, '[T]',  v_qtyperiod);
                            v_statment := replace(v_statment, '[P]', (v_qtyperiod - v_qtyperip));
                            v_statment := 'select '||v_statment||' from dual';
                            v_statment := replace(v_statment,'{','');
                            v_statment := replace(v_statment,'}','');
                            v_amtiflat    := execute_qty(v_statment);
                     elsif  v_typintr =  '3' then
                              v_amtiflat         :=  v_amtlonap * (v_rateilon/12/100);
                     end if;
                 v_qtyperiod  := ceil(v_amtlonap/ (v_amttlpay -  v_amtiflat) );
                 v_amtpint  := v_amtiflat;
             end if;
         end if;    --if v_type '1' ,  '2' then
         --<<get v_amtlast
        if  v_typintr = '1' then
                    v_balamtlon  := v_amtlonap;
                    for i in 1..v_qtyperiod loop
                           v_amtpint  :=  v_balamtlon * (v_rateilon/12/100);
                           v_amtpfin  := v_amttlpay - nvl(v_amtpint,0);
                           --v_balamtlon :=  v_balamtlon - nvl(v_amtpfin,0);
                           if   i = v_qtyperiod then
                                v_amtlast  :=  v_balamtlon + v_amtpint;
                           else
                               v_balamtlon :=  v_balamtlon - nvl(v_amtpfin,0);
                           end if;  -- if   i = v_qtyperiod then
                    end loop;  --for i in 1..v_qtyperiod loop
        elsif  v_typintr  in ('2','3')  then
               -- v_amtlast  := (v_amtlonap  +  v_amtitotflat) -  (v_amtiflat *  (v_qtyperiod -1));
                 --<<user14 25/01/2021
                 v_amtlast  := (v_amtlonap  +  v_amtitotflat) -  (v_amttlpay *  (v_qtyperiod -1));
                 -->>user14 25/01/2021
        end if;
        --<<out param
      --v_type = 1 out v_amttlpay , v_amtlast  , v_amtpint
      --v_type = 2 out v_qtyperiod , v_amtlast  , v_amtpint
        param_msg_error := get_error_msg_php('HR2715',global_v_lang);
        v_response := get_response_message(null,param_msg_error,global_v_lang);

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('amttlpay', v_amttlpay);
        obj_data.put('amtlast', v_amtlast);
        obj_data.put('amtpint', v_amtpint);
        obj_data.put('qtyperiod', v_qtyperiod);
        obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
        json_str_output := obj_data.to_clob;
        -->>out param

        --<<insert temp for popup
         if v_flginsert = 'Y' then
             v_numseq := 1;
             delete  ttemprpt where codempid = global_v_codempid and codapp  = v_codapp;
                   v_balamtlon  := v_amtlonap;
                    for i in 1..v_qtyperiod loop

                          if  v_typintr = '1' then
                                 v_amtpint  :=  v_balamtlon * (v_rateilon/12/100);
--<<user14 27/01/2021
                                 if i = v_qtyperiod then
                                    v_amttlpay := v_balamtlon + v_amtpint;
                                 end if;
-->>user14 27/01/2021
                           else--2,3
                                 v_amtpint  := v_amtiflat;
--<<user14 25/01/2021
                                 if i = v_qtyperiod then
                                    v_amttlpay := v_balamtlon + v_amtiflat;
                                 end if;
--<<user14 25/01/2021
                           end if;
                           v_amtpfin  := v_amttlpay - nvl(v_amtpint,0);  --เงินต้น
                           v_amtlast  := v_balamtlon;
                           v_balamtlon :=  v_balamtlon - nvl(v_amtpfin,0);  --คงเหลือ

                            if  v_numseq <> 1 then
                                   v_mthpayst := v_mthpayst + 1;
                                   if v_mthpayst = 13 then
                                       v_mthpayst  := 1;
                                       v_dteyrpayst := v_dteyrpayst + 1;
                                   end if;
                            end if;
                            v_item2      := lpad(v_mthpayst,2,'0')||'/'||v_dteyrpayst;
                            v_item3       := to_char(v_amtlast,'fm99,999,990.00');
--                            v_item4       := v_amtpfin;
                            v_item4       := to_char(v_amtpfin,'fm99,999,990.00');
                            if v_amtpint > 0 then
                              v_item5      := to_char(v_amtpint,'fm99,999,990.00');  --ดอกเบี้ย
--                              v_item5      := v_amtpint;  --ดอกเบี้ย
                            else
                              v_item5      := '0.00';
                            end if;
--                            v_item6       := v_amttlpay;--จ่ายต่องวด
                            v_item6       := to_char(v_amttlpay,'fm99,999,990.00');--จ่ายต่องวด
                            if v_balamtlon > 0 then
                              v_item7      := to_char(v_balamtlon,'fm99,999,990.00');
                            else
                              v_item7      := '0.00';
                            end if;
                            v_sumItem4 := v_sumItem4 + v_amtpfin;
                            v_sumItem5 := v_sumItem5 + v_amtpint;
                            v_sumItem6 := v_sumItem6 + v_amttlpay;

--                            if i <> v_qtyperiod then
                              v_sumRndItem4  := v_sumRndItem4 + to_number(v_item4,'99,999,990.00');
                              v_sumRndItem5  := v_sumRndItem5 + to_number(v_item5,'99,999,990.00');
--                              v_sumRndItem6  := v_sumRndItem6 + 0;
                              insert into ttemprpt (codempid,codapp,numseq,
                                  --data item1-7
                                  item1,    item2,   item3,
                                  item4,   item5,  item6,
                                  item7
                              )
                              values (global_v_coduser, v_codapp ,v_numseq,
                                  --data item1-7
                                  v_numseq,   v_item2,   v_item3,
                                  v_item4,   v_item5,  v_item6,
                                  v_item7);

                              v_numseq := v_numseq + 1;
--                            end if;
                    end loop;  --for i in 1..v_qtyperiod loop

                    -- last period
                    insert into ttemprpt (codempid,codapp,numseq,
                                  --data item1-7
                                  item1,    item2,   item3,
                                  item4,   item5,  item6,
                                  item7 )
                         values (global_v_coduser, v_codapp ,v_numseq,
                                  --data item1-7
                                  null,   null,   get_label_name('HRBF5JE2',global_v_lang,110),
                                  to_char(v_sumItem4,'fm99,999,990.00'), 
                                  to_char(v_sumItem5,'fm99,999,990.00'), 
                                  to_char(v_sumItem6,'fm99,999,990.00'),
                                  null);

                              v_numseq := v_numseq + 1;
                    --
                    commit;
         end if;  --if v_flginsert = 'Y' then

  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end cal_loan;

end hrbf5je;

/

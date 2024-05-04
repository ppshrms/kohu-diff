--------------------------------------------------------
--  DDL for Package Body HRPY23E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY23E" is
-- last update: 17/09/2018 16:30
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    p_numperiod    			:= to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dterepay          := to_number(hcm_util.get_string_t(json_obj,'p_dterepay'));
    p_codempid          := upper(hcm_util.get_string_t(json_obj,'p_codempid'));

    forceAdd            := hcm_util.get_string_t(json_obj,'forceAdd');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

 procedure check_index is
  v_staemp    varchar2(100 char);
  begin

    if p_codempid is not null then
      begin
        select codempid, staemp, codcomp
          into p_codempid, v_staemp, p_codcomp
          from temploy1
         where codempid = p_codempid;
          if nvl(v_staemp,0) = 0 then
               param_msg_error := get_error_msg_php('HR2102',global_v_lang);
          end if;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
      return;
    end if;
    if p_dtemthpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtemthpay');
      return;
    end if;
    if nvl(p_dterepay,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteyrepay');
      return;
    end if;
  end check_index;

  procedure check_lov_codpay (p_codcodec varchar2) is
    v_descod      varchar2(4000 char);
--    v_codpaypy5   varchar2(4000 char);
    v_codcompy       varchar2(100 char);
  begin
    begin
       select codpay
          into v_descod
          from tinexinf
         where codpay = p_codcodec;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
        return;
    end;
    --
      begin
        select t1.codcompy into v_codcompy
          from tinexinfc t1 , temploy1 t2
         where t1.codcompy = hcm_util.get_codcomp_level(t2.codcomp, 1)
           and t2.codempid = p_codempid
           and t1.codpay   = p_codcodec;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('PY0044',global_v_lang);
        return;
      end;
  end;

 procedure check_dtepay (p_codpay varchar2) is
    v_typpayroll   varchar2(100 char);
    v_numperiod    number;
    v_codincom1    varchar2(100 char);
    v_tcontpms     number;
    v_codpaypy5   varchar2(4000 char);
    v_flgtdtepay  varchar2(1 char);
  begin
    /*----
    begin

        select t1.numperiod, t2.typpayroll,'Y'
           into v_numperiod, v_typpayroll,v_flgtdtepay
          from tdtepay t1 , temploy1 t2
         where t1.codcompy = hcm_util.get_codcomp_level(t2.codcomp, 1) and
            t1.typpayroll = t2.typpayroll and
            t1.dteyrepay  = p_dterepay and
            t1.dtemthpay  = p_dtemthpay and
            t1.numperiod  = p_numperiod and
            t2.codempid = p_codempid ;
      exception when no_data_found then
        v_flgtdtepay := 'N' ;
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tdtepay');
        return;
    end;*/
 /*
     begin
        select count(*) into v_tcontpms
          from tcontpms t1 , temploy1 t2
         where p_codpay in (t1.codincom1,t1.codincom2,t1.codincom3,t1.codincom4,t1.codincom5,
                            t1.codincom6,t1.codincom7,t1.codincom8,t1.codincom9,t1.codincom10)
           and t1.codcompy = hcm_util.get_codcomp_level(t2.codcomp,1)
           and t1.dteeffec = (select max(dteeffec)
                                from tcontpms
                               where codcompy = hcm_util.get_codcomp_level(t2.codcomp,1)
                                 and dteeffec <= trunc(sysdate))
           and t2.codempid = p_codempid ;
      exception when no_data_found then
        v_tcontpms := 0;
      end;

      if nvl(v_tcontpms,0) > 0 then
        param_msg_error := get_error_msg_php('PY0043',global_v_lang,'tcontpms');
        return;
      end if;
*/
    v_codpaypy5 := null;  --#6893 || USER39 || 17/09/2021
    begin
      select codpaypy5
        into v_codpaypy5
        from tcontrpy
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontrpy
                          where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                            and dteeffec  <= sysdate);
           ----#6893 || USER39 || 17/09/2021  
            if  v_codpaypy5 is null then
               v_codpaypy5 := '0000';
            end if; 
           ----#6893 || USER39 || 17/09/2021                              
    exception when no_data_found then null;
    end;
    --
    if v_codpaypy5 is not null then
      if p_codpay = v_codpaypy5 then
        param_msg_error := get_error_msg_php('PY0019',global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCONTRPY');
      return;
    end if;
  end;

  procedure get_codcenter(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    json_obj      json_object_t := json_object_t(json_str_input);
    v_codcenter   varchar2(1000 char);
    v_codcomp     varchar2 (1000 char);
    v_total       number := 0;
  begin
    v_codcomp := hcm_util.get_string_t(json_obj,'p_codcomp');
    begin
      select costcent into v_codcenter
        from tcenter
       where codcomp = v_codcomp;
    exception when no_data_found then
      v_codcenter := null;
    end;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codcenter', v_codcenter);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_codcenter;

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

    p_amtday      number;
    p_amthr       number := 0;
    v_amtday      number := 0;
    v_amtmth      number := 0;

  begin
    v_chken     := hcm_secur.get_v_chken;
--    v_codcomp   := hcm_util.get_string(json_obj,'p_codcomp');
    v_codempid  := hcm_util.get_string_t(json_obj,'p_codempid_query');
    v_qtypayda  := to_number(nvl(hcm_util.get_string_t(json_obj,'p_qtypayda'), 0));
    v_qtypayhr  := to_number(nvl(hcm_util.get_string_t(json_obj,'p_qtypayhr'), 0));
    v_qtypaysc  := to_number(nvl(hcm_util.get_string_t(json_obj,'p_qtypaysc'), 0));

--    begin
--      select stddec(amtday, v_codempid, v_chken)
--        into p_amtday
--        from temploy3
--       where codempid = v_codempid;
--    exception when no_data_found then
--      p_amtday := 0;
--    end;
--    p_amtday    := to_number(hcm_util.get_string(json_obj,'p_amtday'));
--    begin
--      select codempmt into v_codempmt
--        from temploy1
--       where codempid = v_codempid;
--    exception when no_data_found then
--      v_codempmt := '';
--    end;

    begin
   select  emp1.codempmt,emp1.codcomp,
              stddec(amtincom1,emp1.codempid,v_chken),
              stddec(amtincom2,emp1.codempid,v_chken),
              stddec(amtincom3,emp1.codempid,v_chken),
              stddec(amtincom4,emp1.codempid,v_chken),
              stddec(amtincom5,emp1.codempid,v_chken),
              stddec(amtincom6,emp1.codempid,v_chken),
              stddec(amtincom7,emp1.codempid,v_chken),
              stddec(amtincom8,emp1.codempid,v_chken),
              stddec(amtincom9,emp1.codempid,v_chken),
              stddec(amtincom10,emp1.codempid,v_chken)
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
                      p_amthr, v_amtday, v_amtmth);
--    v_amtpay := (v_qtypayda * p_amtday) + (v_qtypayhr * p_amthr) + (v_qtypaysc * p_amthr / 60);
    v_amtpay := (v_qtypayda * v_amtday) + (v_qtypayhr * p_amthr) + (v_qtypaysc * p_amthr / 60);
    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('amtpay', to_char(v_amtpay,'fm9999999990.00'));

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_amtpay;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
--    check_dtepay;
    gen_detail (json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob) as
    obj_data          json_object_t;
    v_codempid        varchar2(100 char);
    v_dteupd          date;
    v_coduser         varchar2(100 char);
    v_dteupd_tothinc  date;
    v_coduser_tothinc varchar2(100 char);
    v_dteupd_tothpay  date;
    v_coduser_tothpay varchar2(100 char);
    v_codcompy       tcompny.codcompy%type;
    v_codempmt       temploy1.codempmt%type;
    v_codcomp        temploy1.codcomp%type;
    v_flgtrnbank     ttaxcur.flgtrnbank%type;
    v_amtothr         number;
    v_amtday          number;
    v_sumincom        number;

    v_amtincom1				  number := 0;
    v_amtincom2				  number := 0;
    v_amtincom3				  number := 0;
    v_amtincom4				  number := 0;
    v_amtincom5				  number := 0;
    v_amtincom6				  number := 0;
    v_amtincom7				  number := 0;
    v_amtincom8				  number := 0;
    v_amtincom9				  number := 0;
    v_amtincom10			  number := 0;


  begin
     v_chken     := hcm_secur.get_v_chken;
     begin
      select  emp1.codempmt,emp1.codcomp,
              stddec(amtincom1,emp1.codempid,v_chken),
              stddec(amtincom2,emp1.codempid,v_chken),
              stddec(amtincom3,emp1.codempid,v_chken),
              stddec(amtincom4,emp1.codempid,v_chken),
              stddec(amtincom5,emp1.codempid,v_chken),
              stddec(amtincom6,emp1.codempid,v_chken),
              stddec(amtincom7,emp1.codempid,v_chken),
              stddec(amtincom8,emp1.codempid,v_chken),
              stddec(amtincom9,emp1.codempid,v_chken),
              stddec(amtincom10,emp1.codempid,v_chken)
        into  v_codempmt, v_codcomp,
              v_amtincom1,v_amtincom2,
              v_amtincom3,v_amtincom4,v_amtincom5,
              v_amtincom6,v_amtincom7,v_amtincom8,
              v_amtincom9,v_amtincom10
        from temploy1 emp1, temploy3 emp3
       where emp1.codempid = p_codempid
         and emp1.codempid   = emp3.codempid;
      exception when no_data_found then
          v_amtincom1 := 0;
          v_amtincom2 := 0;
          v_amtincom3 := 0;
          v_amtincom4 := 0;
          v_amtincom5 := 0;
          v_amtincom6 := 0;
          v_amtincom7 := 0;
          v_amtincom8 := 0;
          v_amtincom9 := 0;
          v_amtincom10 := 0;
      end;

      v_codcompy  := hcm_util.get_codcomp_level(v_codcomp,1);
      get_wage_income(v_codcompy,v_codempmt,
                      nvl(v_amtincom1,0),nvl(v_amtincom2,0),
                      nvl(v_amtincom3,0),nvl(v_amtincom4,0),
                      nvl(v_amtincom5,0),nvl(v_amtincom6,0),
                      nvl(v_amtincom7,0),nvl(v_amtincom8,0),
                      nvl(v_amtincom9,0),nvl(v_amtincom10,0),
                      v_amtothr,v_amtday,v_sumincom);
    begin
     select dteupd, coduser into v_dteupd_tothinc, v_coduser_tothinc
        from tothinc
       where codempid  = p_codempid
        and  dteyrepay = p_dterepay
        and  dtemthpay = p_dtemthpay
        and  numperiod = p_numperiod
        and  rownum = 1;
    exception when no_data_found then
       v_dteupd_tothinc := null;
       v_coduser_tothinc := null;
    end;
    begin
     select dteupd, coduser into v_dteupd_tothpay, v_coduser_tothpay
      from tothpay
     where codempid  = p_codempid
      and  dteyrepay = p_dterepay
      and  dtemthpay = p_dtemthpay
      and  numperiod = p_numperiod
      and  rownum = 1;
    exception when no_data_found then
      v_dteupd_tothpay := null;
      v_coduser_tothpay := null;
    end;

    if v_dteupd_tothinc is not null and v_dteupd_tothpay is not null then
      if v_dteupd_tothinc > v_dteupd_tothpay then
        v_dteupd := v_dteupd_tothinc;
        v_coduser := v_coduser_tothinc;
      else
        v_dteupd := v_dteupd_tothpay;
        v_coduser := v_coduser_tothpay;
      end if;
    else
      if v_dteupd_tothinc is not null then
        v_dteupd := v_dteupd_tothinc;
        v_coduser := v_coduser_tothinc;
      end if;
      if v_dteupd_tothpay is not null then
        v_dteupd := v_dteupd_tothpay;
        v_coduser := v_coduser_tothpay;
      end if;
    end if;

    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('amtday', to_char(v_amtday));
    obj_data.put('amtothr', to_char(v_amtothr));
    obj_data.put('dteupd', to_char(v_dteupd, 'dd/mm/yyyy'));
    obj_data.put('coduser', v_coduser);
    obj_data.put('codempid', get_codempid(v_coduser));
    obj_data.put('codempid_query', p_codempid);
    obj_data.put('codcomp_query', v_codcomp);
    v_flgtrnbank := get_flgtrnbank ( null,p_codempid,p_dterepay, p_dtemthpay,p_numperiod);
    obj_data.put('flgtrnbank', v_flgtrnbank);
    json_str_output := obj_data.to_clob;
  end gen_detail;

 procedure get_tab1 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    gen_tab1 (json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab1;

  procedure gen_tab1 (json_str_output out clob) is
    obj_data            json_object_t;
    obj_data2           json_object_t;
    obj_row             json_object_t;
    obj_row2            json_object_t;
    v_rcnt              number := 0;
    v_rcnt2             number := 0;
    v_numseq            number := 0;
    v_codpay            varchar2(100 char) := '';
    v_hour              number;
    v_rateda            number;
    v_ratehr            number;
    v_ratesc            number;
    v_amtpay            number;
    v_temploy3          temploy3%rowtype;
    v_codempmt          temploy1.codempmt%TYPE;
    v_codcomp           temploy1.codcomp%TYPE;

    v_amtday			      varchar2(100 char);
    v_amthr			          varchar2(100 char);

    v_codempid          varchar2(100 char);
    v_sumhur            number :=0 ;
    v_sumday            number :=0 ;
    v_summth            number :=0 ;
    v_flgtrnbank     ttaxcur.flgtrnbank%type;

    cursor c_tothinc is
      select codpay, stddec(ratepay, codempid, v_chken) ratepay, codsys, codempid
        from tothinc
       where codempid  = p_codempid
        and  dteyrepay = p_dterepay
        and  dtemthpay = p_dtemthpay
        and  numperiod = p_numperiod
    order by codpay asc;

     cursor c_tothinc2 is
      select qtypayda, qtypayhr, qtypaysc, codcompw, stddec(amtpay, p_codempid, v_chken) amtpay, costcent, codsys, rowid
        from tothinc2
       where codempid  = p_codempid
        and  dteyrepay = p_dterepay
        and  dtemthpay = p_dtemthpay
        and  numperiod = p_numperiod
        and  codpay    = v_codpay
    order by codcompw asc;

  begin
    obj_row         := json_object_t();
      for c1 in c_tothinc loop
        begin
          select stddec(amtday, codempid, v_chken)
            into v_amtday
            from temploy3
           where codempid = c1.codempid ;
        end;
        obj_data          := json_object_t();
        v_rcnt            := v_rcnt + 1;
        v_numseq          := v_numseq + 1;
        obj_data.put('coderror', '200');
        obj_data.put('numseq', v_numseq);

        obj_data.put('codpay', c1.codpay);
        obj_data.put('ratepay', v_amtday);
        obj_data.put('ratepayhr', v_amthr);
         v_rcnt2           := 0;
        obj_row2          := json_object_t();

        v_codpay := c1.codpay;
        for c2 in c_tothinc2 loop
          obj_data2           := json_object_t();
          v_rcnt2             := v_rcnt2 + 1;
          obj_data2.put('coderror', '200');
          obj_data2.put('rowId', c2.rowid);
          obj_data2.put('codcomp', c2.codcompw);
          obj_data2.put('costcent', c2.costcent);
          obj_data2.put('qtypayda', c2.qtypayda);
          obj_data2.put('qtypayhr', c2.qtypayhr);
          obj_data2.put('qtypaysc', c2.qtypaysc);
          obj_data2.put('amtpay', c2.amtpay);
          obj_data2.put('codsys', c2.codsys);
          obj_row2.put(to_char(v_rcnt2 - 1), obj_data2);
        end loop;
        obj_data.put('children', obj_row2);

        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab1;

  procedure get_tab2 (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_tab2(json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab2;

  procedure gen_tab2 (json_str_output out clob) as
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_codempid          varchar2(100 char);
    v_rcnt              number := 0;
    v_flgtrnbank        ttaxcur.flgtrnbank%type;

    cursor c_tothpay is
      select rowid, codpay, dtepay, stddec(amtpay, codempid, v_chken) amtpay, flgpyctax, codcompw, costcent
        from tothpay
       where codempid = p_codempid
        and  dteyrepay = p_dterepay
        and  dtemthpay = p_dtemthpay
        and  numperiod = p_numperiod
    order by codpay asc;

  begin
    obj_row             := json_object_t();
    for c1 in c_tothpay loop
      v_rcnt       := v_rcnt+1;
      obj_data     := json_object_t();

      obj_data.put('coderror', '200');

      obj_data.put('rowId', c1.rowId);
      obj_data.put('codpay', c1.codpay);
      obj_data.put('desc_codpay', get_tinexinf_name(c1.codpay, global_v_lang));
      obj_data.put('dtepay', to_char(c1.dtepay, 'dd/mm/yyyy'));
      obj_data.put('amtpay', c1.amtpay);
      obj_data.put('flgpyctax', c1.flgpyctax);
      obj_data.put('desc_flgpyctax', get_tlistval_name('FLGPYCTAX',c1.flgpyctax, global_v_lang));
      obj_data.put('codcomp', c1.codcompw);
      obj_data.put('costcent', c1.costcent);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab2;

  procedure save_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    json_input_obj      := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));

    if param_msg_error is null then
      save_tab1 (json_str_output);
    end if;
    if param_msg_error is null then
      save_tab2 (json_str_output);
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;
--
  procedure save_tab1 (json_str_output out clob) is
    json_param_obj        json_object_t;
    json_row              json_object_t;
    json_param_obj2       json_object_t;
    json_row2             json_object_t;
    v_numseq              number;
    obj_syncond           json;
    v_codpay              varchar2(100 char);
    v_ratepay             number;
    v_codsys              varchar2(10 char);
    v_codsysOld           varchar2(10 char);
    v_flag                varchar2(100 char);
    v_codcomp             varchar2(100 char);
    v_codcompOld          varchar2(100 char);
    v_typpayroll          varchar2(100 char);
    v_typemp              varchar2(100 char);
    v_costcent            tcenter.costcent%type;
    v_costcenth           tcenter.costcent%type;
    v_qtypayda            number;
    v_qtypaydaOld         number;
    v_qtypayhr            number;
    v_qtypayhrOld         number;
    v_qtypaysc            number;
    v_qtypayscOld         number;
    v_amtpay              number;
    v_amtpayOld           number;

    v_qtyawOld            number;
    v_qtyaw               number;
    obj_formula           json_object_t;
    v_rowId               varchar2(1000 char);
    v_formula             varchar2(4000 char);
    v_flagd               varchar2(100 char);


    cursor c_tothinc2 is
      select codcompw, qtypayda, qtypayhr, qtypaysc, amtpay, codsys
        from tothinc2
       where codempid = p_codempid
        and  dteyrepay = p_dterepay
        and  dtemthpay = p_dtemthpay
        and  numperiod = p_numperiod
        AND  CODPAY    = V_CODPAY;

    cursor c_tothinc_ud is
      select codcompw, qtypayda, qtypayhr, qtypaysc, stddec(amtpay,codempid,v_chken) amtpay, codsys
        from tothinc2
       where codempid = p_codempid
        and  dteyrepay = p_dterepay
        and  dtemthpay = p_dtemthpay
        AND  numperiod = p_numperiod
        AND  codpay    = v_codpay
        and  codcompw  = v_codcomp;

  cursor c_tothinc2sum is
      select codempid,sum(stddec(amtpay,codempid,v_chken)) sum_amtpay, sum(QTYPAYDA) sum_qtypayda, sum(QTYPAYHR) sum_qtypayhr, sum(QTYPAYSC) sum_qtypaysc
        from tothinc2
       where codempid  = p_codempid
         and dteyrepay = (p_dterepay - global_v_zyear)
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod
         and codpay		 = v_codpay
    group by codempid
    order by codempid;

	cursor c_tothinc is
		 select	codcomp,codempid,dteyrepay,dtemthpay,numperiod,codpay,typemp,rowid, qtypayda, qtypayhr, qtypaysc, amtpay, codsys
			 from	tothinc
			where	codempid	= p_codempid
				and	dteyrepay	= (p_dterepay - global_v_zyear)
				and	dtemthpay	= p_dtemthpay
				and	numperiod	= p_numperiod
				and	codpay		= v_codpay
			order by codempid,dteyrepay,dtemthpay,numperiod,codpay
			for update;

  begin
     begin
      select nvl(max(numseq),0)+1 into v_numseq
        from tlogothpay
         where codempid = p_codempid
          and  dteyrepay = p_dterepay
          and  dtemthpay = p_dtemthpay
          and  numperiod = p_numperiod
          and  codpay    = v_codpay ;
       exception when no_data_found then
        v_numseq  := 1;
    end;
    json_param_obj        := hcm_util.get_json_t(json_input_obj,'tab1');

    for i in 0..json_param_obj.get_size-1 loop
      json_row            := hcm_util.get_json_t(json_param_obj,to_char(i));
      v_codpay            := hcm_util.get_string_t(json_row, 'codpay');
      v_ratepay           := hcm_util.get_string_t(json_row, 'ratepay');
--      v_codsys            := hcm_util.get_string(json_row, 'codsys');
      v_codsys            := 'PY';
      v_flag              := hcm_util.get_string_t(json_row, 'flg');
      if v_flag = 'delete' then
        for r1 in c_tothinc loop
--          begin
--           insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
--                        numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
--            VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
--                    v_codcomp, 'CODCOMPW', r1.codcompw, null, sysdate, global_v_coduser, global_v_coduser);
--          end;

          --<<User37 #2255 Final Test Phase 1 V11 08/02/2021
          if r1.qtypayda is not null then
            v_numseq := v_numseq+1;
              begin
               insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                            numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                        r1.codcomp, 'QTYPAYDA', r1.qtypayda, null, sysdate, global_v_coduser, global_v_coduser);
              end;
          end if;

          if r1.qtypayhr is not null then
              v_numseq := v_numseq+1;
               begin
               insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                            numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                        r1.codcomp, 'QTYPAYHR', r1.qtypayhr, null, sysdate, global_v_coduser, global_v_coduser);
              end;
          end if;

          if r1.qtypaysc is not null then
              v_numseq := v_numseq+1;
               begin
               insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                            numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                        r1.codcomp, 'QTYPAYSC', r1.qtypaysc, null, sysdate, global_v_coduser, global_v_coduser);
              end;
          end if;

          if r1.amtpay is not null then
              v_numseq := v_numseq+1;
               begin
               insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                            numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                        r1.codcomp, 'AMTPAY', r1.amtpay, null, sysdate, global_v_coduser, global_v_coduser);
              end;
          end if;
          -->>User37 #2255 Final Test Phase 1 V11 08/02/2021
          v_numseq := v_numseq+1;
        end loop;

        delete from tothinc2
         where codempid = p_codempid
          and  dteyrepay = p_dterepay
          and  dtemthpay = p_dtemthpay
          and  numperiod = p_numperiod
          and  codpay    = v_codpay;

        delete from tothinc
         where codempid  = p_codempid
          and  dteyrepay = p_dterepay
          and  dtemthpay = p_dtemthpay
          and  numperiod = p_numperiod
          and  codpay    = v_codpay ;

      else
        check_lov_codpay(v_codpay);
          if param_msg_error is not null then
            return;
          end if;
        check_dtepay(v_codpay);
        if param_msg_error is not null then
          return;
        end if;

        begin
         select temploy1.codcomp, temploy1.typpayroll, temploy1.typemp, costcent
          into v_codcomp, v_typpayroll, v_typemp, v_costcenth
          from temploy1, tcenter
            where temploy1.codempid = p_codempid
              and temploy1.codcomp = tcenter.codcomp;
        end;
        begin
          insert into tothinc
                 (codpay, ratepay, codsys, codempid, dteyrepay, dtemthpay,
                  numperiod, codcomp, typpayroll, typemp, qtypayda, qtypayhr, qtypaysc,
                  amtpay, costcent, codcreate, coduser, dtecreate )
          values (v_codpay, stdenc(v_ratepay,p_codempid,v_chken), v_codsys, p_codempid, p_dterepay, p_dtemthpay,
                  p_numperiod, v_codcomp, v_typpayroll, v_typemp, 0, 0, 0,
                  0, v_costcenth, global_v_coduser, global_v_coduser, sysdate);
        exception when dup_val_on_index then
          update tothinc
             set  codcomp   = v_codcomp,
                  typpayroll= v_typpayroll,
                  typemp    = v_typemp,
                  dteupd    = sysdate,
                  coduser   = global_v_coduser
            where  codempid = p_codempid
              and  dteyrepay = p_dterepay
              and  dtemthpay = p_dtemthpay
              and  numperiod = p_numperiod
              and  codpay    = v_codpay ;
        end;

        json_param_obj2       := hcm_util.get_json_t(json_row, 'children');
        for i in 0..json_param_obj2.get_size-1 loop
          json_row2              := hcm_util.get_json_t(json_param_obj2, to_char(i));
          v_codcomp              := hcm_util.get_string_t(json_row2, 'codcomp');
          v_codcompOld           := hcm_util.get_string_t(json_row2, 'codcompOld');
          v_costcent             := hcm_util.get_string_t(json_row2, 'costcent');
          v_qtypayda             := to_number(hcm_util.get_string_t(json_row2, 'qtypayda'));
          v_qtypaydaold          := to_number(hcm_util.get_string_t(json_row2, 'qtypaydaOld'));
          v_qtypayhr             := to_number(hcm_util.get_string_t(json_row2, 'qtypayhr'));
          v_qtypayhrold          := to_number(hcm_util.get_string_t(json_row2, 'qtypayhrOld'));
          v_qtypaysc             := to_number(hcm_util.get_string_t(json_row2, 'qtypaysc'));
          v_qtypayscold          := to_number(hcm_util.get_string_t(json_row2, 'qtypayscOld'));
          v_amtpay               := to_number(hcm_util.get_string_t(json_row2, 'amtpay'));
          v_amtpayOld            := to_number(hcm_util.get_string_t(json_row2, 'amtpayOld'));
--          v_codsys               := hcm_util.get_string(json_row2, 'codsys');
          v_codsys               := 'PY';
          v_codsysOld            := hcm_util.get_string_t(json_row2, 'codsysOld');

          v_flagd             := hcm_util.get_string_t(json_row2, 'flg');
          v_rowId             := hcm_util.get_string_t(json_row2, 'rowId');

          if v_flagd = 'delete' then
            for r2 in c_tothinc_ud loop
              begin
               insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                            numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                        v_codcomp, 'CODCOMPW', r2.codcompw, null, sysdate, global_v_coduser, global_v_coduser);
              end;

              if r2.qtypayda is not null then
                  v_numseq := v_numseq+1;
                  begin
                   insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                                numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                    VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                            v_codcomp, 'QTYPAYDA', r2.qtypayda, null, sysdate, global_v_coduser, global_v_coduser);
                  end;
              end if;
              if r2.qtypayhr is not null then
                  v_numseq := v_numseq+1;
                   begin
                   insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                                numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                    VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                            v_codcomp, 'QTYPAYHR', r2.qtypayhr, null, sysdate, global_v_coduser, global_v_coduser);
                  end;
              end if;
              if r2.qtypaysc is not null then
                  v_numseq := v_numseq+1;
                   begin
                   insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                                numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                    VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                            v_codcomp, 'QTYPAYSC', r2.qtypaysc, null, sysdate, global_v_coduser, global_v_coduser);
                  end;
              end if;
              if r2.amtpay is not null then
                  v_numseq := v_numseq+1;
                   begin
                   insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                                numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                    VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                            v_codcomp, 'AMTPAY', stdenc(r2.amtpay,p_codempid,v_chken), null, sysdate, global_v_coduser, global_v_coduser);
                  end;
              end if;
              v_numseq := v_numseq+1;
            end loop;
            delete from tothinc2
                where  codempid = p_codempid
                  and  dteyrepay = p_dterepay
                  and  dtemthpay = p_dtemthpay
                  and  numperiod = p_numperiod
                  and  codpay    = v_codpay
                  and  codcompw  = v_codcomp;
          elsif v_flagd = 'add' then
            begin
              insert into tothinc2
                     (codempid, dteyrepay, dtemthpay, numperiod, codpay,
                      codcompw, qtypayda, qtypayhr, qtypaysc, amtpay, costcent, codsys,dtecreate, codcreate, coduser)

              values (p_codempid,p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                      v_codcomp, v_qtypayda, v_qtypayhr, v_qtypaysc, stdenc(v_amtpay,p_codempid,v_chken), v_costcent, v_codsys,
                      sysdate, global_v_coduser, global_v_coduser);

            exception when dup_val_on_index then
              param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tothinc2');
              return;
            end;
/*
              begin
               insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                            numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                        v_codcomp, 'CODCOMPW', null, v_codcomp, sysdate, global_v_coduser, global_v_coduser);
              end;
              if v_qtypayda is not null then
                v_numseq := v_numseq+1;
                begin
                 insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                              numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                  values (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                          v_codcomp, 'QTYPAYDA', null, v_qtypayda, sysdate, global_v_coduser, global_v_coduser);
                end;
              end if;
              if v_qtypayhr is not null then
                v_numseq := v_numseq+1;
                 begin
                 insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                              numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                  values (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                          v_codcomp, 'QTYPAYHR', null, v_qtypayhr, sysdate, global_v_coduser, global_v_coduser);
                end;
              end if;
              if v_qtypaysc is not null then
                v_numseq := v_numseq+1;
                 begin
                 insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                              numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                  values (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                          v_codcomp, 'QTYPAYSC', null, v_qtypaysc, sysdate, global_v_coduser, global_v_coduser);
                end;
              end if;*/
              v_numseq := v_numseq+1;
               begin
               insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                            numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                values (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                        v_codcomp, 'AMTPAY', null, stdenc(v_amtpay,p_codempid,v_chken), sysdate, global_v_coduser, global_v_coduser);
              end;
              v_numseq := v_numseq+1;
          else
            for r2 in c_tothinc_ud loop
              if r2.codcompw != v_codcomp or r2.codcompw is null then
                  begin
                   insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                                numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                    VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                            v_codcomp, 'CODCOMPW', r2.codcompw, v_codcomp, sysdate, global_v_coduser, global_v_coduser);
                  end;
                  v_numseq := v_numseq+1;
              end if;

              if nvl(r2.qtypayda,0) <> nvl(v_qtypayda,0) then
                  begin
                   insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                                numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                    values (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                            v_codcomp, 'QTYPAYDA', r2.qtypayda, v_qtypayda, sysdate, global_v_coduser, global_v_coduser);
                  end;
                  v_numseq := v_numseq+1;
              end if;

              if nvl(r2.qtypayhr,0) <> nvl(v_qtypayhr,0) then
                  begin
                   insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                                numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                    values (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                            v_codcomp, 'QTYPAYHR', r2.qtypayhr, v_qtypayhr, sysdate, global_v_coduser, global_v_coduser);
                  end;
                  v_numseq := v_numseq+1;
              end if;

              if nvl(r2.qtypaysc,0) <> nvl(v_qtypaysc,0) then
                  begin
                   insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                                numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                    values (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                            v_codcomp, 'QTYPAYSC', r2.qtypaysc, v_qtypaysc, sysdate, global_v_coduser, global_v_coduser);
                  end;
                  v_numseq := v_numseq+1;
              end if;

              if nvl(r2.amtpay,0) <> v_amtpay then
                  begin
                   insert into tlogothinc (numseq, codempid, dteyrepay, dtemthpay,
                                numperiod, codpay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                    values (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay,
                            v_codcomp, 'AMTPAY', stdenc(r2.amtpay,p_codempid,v_chken), stdenc(v_amtpay,p_codempid,v_chken), sysdate, global_v_coduser, global_v_coduser);
                  end;
                  v_numseq := v_numseq+1;
              end if;
            end loop;
            begin
              update tothinc2
                 set codcompw  = v_codcomp,
                    qtypayda   = v_qtypayda,
                    qtypayhr   = v_qtypayhr,
                    qtypaysc   = v_qtypaysc,
                    amtpay     = stdenc(v_amtpay,p_codempid,v_chken),
                    codsys     = v_codsys,
                    costcent   = v_costcent,
                    coduser   = global_v_coduser,
                    codcreate = global_v_coduser
             where  codempid = p_codempid
              and   dteyrepay = p_dterepay
              and   dtemthpay = p_dtemthpay
              and   numperiod = p_numperiod
              and   codpay    = v_codpay
              and   codcompw  = v_codcomp;
            end;
          end if;
        end loop;
      end if;

        -- loop insert tothinc
        for r_tothinc2sum in c_tothinc2sum loop
            -- Update tothinc
            for r_tothinc in c_tothinc loop
              update	tothinc
                set	  ratepay			= stdenc(round(v_ratepay,2),p_codempid,v_chken),
                      amtpay			= stdenc(r_tothinc2sum.sum_amtpay,p_codempid,v_chken),
                      QTYPAYDA          = r_tothinc2sum.sum_qtypayda,
                      QTYPAYHR          = r_tothinc2sum.sum_qtypayhr,
                      QTYPAYSC          = r_tothinc2sum.sum_qtypaysc,
                      dteupd            = trunc(sysdate),
                      coduser			= global_v_coduser
                where rowid = r_tothinc.rowid;
            end loop; -- c_tothinc;
        end loop;
--        commit;
    end loop;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tab2 (json_str_output out clob) is
    obj_tab1              json_object_t;
    json_param_obj        json_object_t;
    json_row              json_object_t;
    v_rowid               varchar2(1000 char);
    v_codpay              varchar2(100 char);
    v_costcent            varchar2(100 char);
    v_codcomp             varchar2(100 char);
    v_codcompw            varchar2(100 char);
    v_typpayroll          varchar2(100 char);
    v_typemp              varchar2(100 char);
    v_dtepay              date;
    v_amtpay              number;
    v_amtpayOld           number;
    v_flgpyctax           varchar2(10 char);
    v_flgpyctaxOld        varchar2(10 char);
    v_flag                varchar2(10 char);
    v_numseq              number;
    v_dtestrt             tdtepay.dtestrt%type;
    v_dteend              tdtepay.dteend%type;

     cursor c_tothpay is
      select codpay, dtepay, amtpay, flgpyctax
        from tothpay
       where codempid = p_codempid
        and  dteyrepay = p_dterepay
        and  dtemthpay = p_dtemthpay
        and  numperiod = p_numperiod
        and  codpay    = v_codpay
        and  dtepay    = v_dtepay ;

  begin
    begin
      select nvl(max(numseq),0)+1 into v_numseq
        from tlogothpay
         where codempid = p_codempid
          and  dteyrepay = p_dterepay
          and  dtemthpay = p_dtemthpay
          and  numperiod = p_numperiod
          and  codpay    = v_codpay
          and  dtepay    = v_dtepay ;
       exception when no_data_found then
        v_numseq  := 1;
    end;
    json_param_obj        := hcm_util.get_json_t(json_input_obj,'tab2');
    for i in 0..json_param_obj.get_size-1 loop
      json_row            := hcm_util.get_json_t(json_param_obj,to_char(i));
      v_rowid             := hcm_util.get_string_t(json_row, 'rowId');
      v_codpay            := hcm_util.get_string_t(json_row, 'codpay');
      v_dtepay        	  := to_date(hcm_util.get_string_t(json_row, 'dtepay'), 'dd/mm/yyyy');
      v_amtpay        	  := to_number(hcm_util.get_string_t(json_row, 'amtpay'));
      v_amtpayold         := to_number(hcm_util.get_string_t(json_row, 'amtpayOld'));
      v_flgpyctax         := hcm_util.get_string_t(json_row, 'flgpyctax');
      v_flgpyctaxold      := hcm_util.get_string_t(json_row, 'flgpyctaxOld');
      v_codcompw           := hcm_util.get_string_t(json_row, 'codcomp');
--      v_codcompOld        := hcm_util.get_string(json_row, 'codcompOld');
      v_costcent          := hcm_util.get_string_t(json_row, 'costcent');
      v_flag              := hcm_util.get_string_t(json_row, 'flg');

      begin
        select  codcomp ,typpayroll
          into  v_codcomp, v_typpayroll
          from  temploy1
         where  codempid = p_codempid;
      exception when no_data_found then
        v_codcomp   := null;
        v_typpayroll := null;
      end;


      begin
        select dtestrt , dteend
          into v_dtestrt , v_dteend
          from tdtepay
         where codcompy     = hcm_util.get_codcomp_level(v_codcomp, 1)
           and typpayroll   = v_typpayroll
           and dteyrepay    = p_dterepay
           and dtemthpay    = p_dtemthpay
           and numperiod    = p_numperiod;
      exception when no_data_found then
        v_dtestrt := null;
        v_dteend  := null;
      end;


       if v_dtepay not between v_dtestrt  and  v_dteend then
          param_msg_error := get_error_msg_php('PY0070',global_v_lang);
          return;
        end if;
      -----
          if v_flag = 'delete' then
            for r1 in c_tothpay loop
              begin
               insert into tlogothpay (numseq, codempid, dteyrepay, dtemthpay,
                            numperiod, codpay, dtepay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                values (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay, v_dtepay,
                        v_codcomp, 'AMTPAY', stdenc(r1.amtpay,p_codempid,v_chken), null, sysdate, global_v_coduser, global_v_coduser);
              end;
              v_numseq := v_numseq +1;
              begin
               insert into tlogothpay (numseq, codempid, dteyrepay, dtemthpay,
                            numperiod, codpay, dtepay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay, v_dtepay,
                        v_codcomp, 'FLGPYCTAX', r1.flgpyctax, null, sysdate, global_v_coduser, global_v_coduser);
              end;
              v_numseq := v_numseq +1;
            end loop;
            delete from tothpay
             where codempid  = p_codempid
              and  dteyrepay = p_dterepay
              and  dtemthpay = p_dtemthpay
              and  numperiod = p_numperiod
              and  codpay    = v_codpay
              and  dtepay    = v_dtepay ;

          elsif v_flag = 'add' then
            check_lov_codpay(v_codpay);
            if param_msg_error is not null then
              return;
            end if;
--            check_dtepay;
--            if param_msg_error is not null then
--                return;
--              end if;
             begin
               select typpayroll, typemp
                into v_typpayroll, v_typemp
                from temploy1
                  where codempid = p_codempid;
            end;

            if v_costcent is null then
                begin
                  select costcent into v_costcent
                    from tcenter
                   where codcomp = v_codcompw;
                exception when no_data_found then
                  v_costcent := null;
                end;
            end if;

            begin
              insert into tothpay
                     (codempid, dteyrepay, dtemthpay, numperiod, codpay, dtepay, codcomp,
                      typpayroll, typemp, amtpay, flgpyctax, costcent, dtecreate, codcreate, coduser, codcompw)

              values (p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay, v_dtepay, v_codcomp,
                      v_typpayroll, v_typemp, stdenc(v_amtpay,p_codempid,v_chken), v_flgpyctax, v_costcent, sysdate, global_v_coduser, global_v_coduser, v_codcompw);
            exception when dup_val_on_index then
              param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tothpay');
              return;
            end;

              begin
               insert into tlogothpay (numseq, codempid, dteyrepay, dtemthpay,
                            numperiod, codpay, dtepay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                values (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay, v_dtepay,
                        v_codcomp, 'AMTPAY',null,stdenc(v_amtpay,p_codempid,v_chken), sysdate, global_v_coduser, global_v_coduser);
              end;
              v_numseq := v_numseq +1;
              begin
               insert into tlogothpay (numseq, codempid, dteyrepay, dtemthpay,
                            numperiod, codpay, dtepay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay, v_dtepay,
                        v_codcomp, 'FLGPYCTAX', null, v_flgpyctax, sysdate, global_v_coduser, global_v_coduser);
              end;
              v_numseq := v_numseq +1;

          else
            check_lov_codpay(v_codpay);
            if param_msg_error is not null then
              return;
            end if;
--            check_dtepay;
--            if param_msg_error is not null then
--                return;
--              end if;
            for r1 in c_tothpay loop
              if r1.amtpay <> stdenc(v_amtpay,p_codempid,v_chken) then
                  begin
                   insert into tlogothpay (numseq, codempid, dteyrepay, dtemthpay,
                                numperiod, codpay, dtepay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                    values (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay, v_dtepay,
                            v_codcomp, 'AMTPAY',r1.amtpay,stdenc(v_amtpay,p_codempid,v_chken), sysdate, global_v_coduser, global_v_coduser);
                  end;
                  v_numseq := v_numseq +1;
              end if;

              if r1.flgpyctax <> v_flgpyctax then
                  begin
                   insert into tlogothpay (numseq, codempid, dteyrepay, dtemthpay,
                                numperiod, codpay, dtepay, codcomp, desfld, desold, desnew, dtecreate, codcreate, coduser )
                    VALUES (v_numseq, p_codempid, p_dterepay, p_dtemthpay, p_numperiod, v_codpay, v_dtepay,
                            v_codcomp, 'FLGPYCTAX', r1.flgpyctax, v_flgpyctax, sysdate, global_v_coduser, global_v_coduser);
                  end;
                  v_numseq := v_numseq +1;
              end if;
            end loop;
            begin
              update tothpay
                 set codcomp   = v_codcomp,
                     codcompw = v_codcompw,
                     amtpay    = stdenc(v_amtpay,p_codempid,v_chken),
                     flgpyctax = v_flgpyctax,
                     dteupd    = sysdate,
                     coduser   = global_v_coduser
               where codempid  = p_codempid
                and  dteyrepay = p_dterepay
                and  dtemthpay = p_dtemthpay
                and  numperiod = p_numperiod
                and  codpay    = v_codpay
                and  dtepay    = v_dtepay ;
            end;
          end if;
    end loop;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

end HRPY23E;

/

--------------------------------------------------------
--  DDL for Package Body M_HRMSZ1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRMSZ1X" is
/* Cust-Modify: KOHU-HR2301 */
-- last update: 26/03/2024 17:33 

  procedure check_index is
    v_secur			boolean;
    begin

    ------------------------------------------------------
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_report is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;

    ------------------------------------------------------
  end check_index;
--
  procedure gen_data (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt            number := 0;
    v_cnt_data     number := 0;
    v_qtyotpend  number := 0;
    v_qtyot_ESS   number := 0;
    v_costcent      varchar2(40);
    v_qtyot_AL     number := 0;
    v_qtyot_AL2   number := 0;
    v_qtyotappr   number := 0;
    flgpass           boolean;
    v_first_day     date;
    v_last_day     date;
    v_qtymanpw  number := 0;
    v_qtyhwork    number := 0;
    v_qtyminabs   number := 0;
    v_qtyminlv     number := 0;
    v_work           number := 0;
    v_pctbguse     number := 0;

    cursor c1_table is 
    Select a.*
    from TBUDGETOT a
    where a.codcomp like p_codcomp || '%'
    and a.dtemonth = p_month
    and a.dteyear = p_year
--    and ((p_report = '1' and (a.qtyotappr + a.qtyotpend) <= a.qtybudget)
--      or(p_report = '2' and (a.qtyotappr + a.qtyotpend) > a.qtybudget)
--      or (p_report = '3'))
      order by a.codcomp;

    begin
        obj_row    := json_object_t();
        begin
          v_rcnt := 0;

          for c1 in c1_table loop
            flgpass := secur_main.secur7(c1.codcomp,global_v_coduser);
            if flgpass = true then

                v_first_day := TO_DATE('01-' || p_month || '-' || p_year, 'DD-MM-YYYY');
                -- หาวันที่สุดท้ายของเดือนจากวันที่ 1
                v_last_day := last_day(v_first_day);

                begin
                  select nvl(sum(nvl(b.qtyminot, a.qtyotreq)),0)
                  into   v_qtyotpend
                  from   ttotreq a, tovrtime b 
                  where  a.codcompbg = c1.codcomp 
                  and    a.dtestrt between v_first_day and v_last_day
                  and    a.staappr in ('P', 'A') 
                  and    a.numotreq = b.numotreq (+)
                  and    to_char(a.dtereq,'yyyymmdd')||lpad(a.numseq,3,'0') 
                         = (select max(to_char(c.dtereq,'yyyymmdd')||lpad(c.numseq,3,'0'))
                            from   ttotreq c
                            where  a.codempid = c.codempid            
                            and    a.dtestrt  = c.dtestrt
                            and    c.staappr  not in ('C', 'N') --user36 KOHU-HR2301 05/04/2024
                            );                
                end;

                begin
                  select sum(nvl(b.qtyminot, a.qtyotreq))
                  into   v_qtyot_ess 
                  from   ttotreq  a, tovrtime b 
                  where  a.codcompbg = c1.codcomp 
                  and    a.dtestrt  between v_first_day  and v_last_day 
                  and    a.staappr = 'Y'
                  and    a.numotreq = b.numotreq (+)
                  and    to_char(a.dtereq,'yyyymmdd')||lpad(a.numseq,3,'0') 
                         = (select max(to_char(c.dtereq,'yyyymmdd')||lpad(c.numseq,3,'0')) 
                            from   ttotreq c
                            where  a.codempid = c.codempid           
                            and    a.dtestrt  = c.dtestrt
                            and    c.staappr  not in ('C', 'N') --user36 KOHU-HR2301 05/04/2024
                            );
                end;

                begin
                    Select nvl(sum(nvl(b.qtyminot, a.qtyotreq)), 0) 
                    into v_qtyot_AL 
                    from TOTREQD a, TOVRTIME b 
                    where otbudget.get_codcompbg(nvl(a.codcompw, a.codcomp), a.dtewkreq) = c1.codcomp
                    and a.dtewkreq  between v_first_day  and v_last_day 
                    and a.numotreq = b.numotreq (+) 
                    and a.codempid = b.codempid (+)  
                    and a.dtewkreq = b.dtework (+) 
                    and a.typot = b.typot (+) 
                    and not exists (
                                    select c.numotreq
                                    from TTOTREQ c 
                                    where c.numotreq = a.numotreq
                                    )
                    and    a.numotreq     =  (Select max(c.numotreq)
                                       From   TOTREQD c
                                       Where a.codempid = c.codempid   
                                       and    a.dtewkreq   = c.dtewkreq     
                                       and    a.typot         = c.typot         
                                       );
                    end;


                begin
                    Select nvl(sum(qtyminot), 0) 
                    into v_qtyot_AL2 
                    from TOVRTIME 
                    where otbudget.get_codcompbg(nvl(codcompw, codcomp), dtework) = c1.codcomp 
                    and dtework between v_first_day and v_last_day
                    and numotreq is null;
                end;

                v_qtyotappr := v_qtyot_ESS + v_qtyot_AL + v_qtyot_AL2;


                begin
                    Select count(distinct(codempid)), sum(nvl(qtyhwork, 0)) 
                    into v_qtymanpw, v_qtyhwork 
                    from TATTENCE 
                    where codcomp = rpad(c1.codcomp,21,'0') --user36 KOHU-HR2301 #1803 26/03/2024 ||codcomp like c1.codcomp||'%' 
                    and dtework between v_first_day  and v_last_day 
                    and typwork in ('W','L');
                end;


                begin
                    Select nvl(sum(nvl(qtylate, 0) + nvl(qtyearly, 0)),0)
                    into v_qtyminabs 
                    from TLATEABS 
                    where codcomp = rpad(c1.codcomp,21,'0') --user36 KOHU-HR2301 #1803 26/03/2024 ||codcomp like c1.codcomp||'%' 
                    and dtework between v_first_day and v_last_day;
                end;


                begin
                    Select nvl(sum(nvl(qtymin, 0)), 0) 
                    into v_qtyminlv 
                    from TLEAVETR 
                    where codcomp = rpad(c1.codcomp,21,'0') --user36 KOHU-HR2301 #1803 26/03/2024 ||codcomp like c1.codcomp||'%' 
                    and dtework between v_first_day
                    and v_last_day;
                end;


                begin
                    Select costcent into v_costcent
                    From  TCENTER
                    Where codcomp like c1.codcomp || '%'
                    And    rownum = 1
                    Order by codcomp;
                end;

                v_work := v_qtyhwork - v_qtyminabs - v_qtyminlv;

                -- << KOHU-HR2301 | 000504-Nuii-Kowit-Dev | 12/12/2023 | | (4449#1557)
                IF c1.qtybudget > 0 THEN
                    v_pctbguse := nvl((nvl(v_qtyotpend,0) + nvl(v_qtyotappr,0)) / nvl(c1.qtybudget,0) * 100, 0);
                ELSE
                    v_pctbguse := 0;
                END IF;
                -- >> KOHU-HR2301 | 000504-Nuii-Kowit-Dev | 12/12/2023 | | (4449#1557)


                v_rcnt := v_rcnt+1;

                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('codcomp', c1.codcomp);
                obj_data.put('desc_codcomp', get_tcenter_name(c1.codcomp, global_v_lang));
                obj_data.put('costcent', v_costcent);
                obj_data.put('qtymanpw', v_qtymanpw);
                obj_data.put('qtywork', hcm_util.convert_minute_to_hour(nvl(v_work, 0)));
                obj_data.put('qtybudget', hcm_util.convert_minute_to_hour(nvl(c1.qtybudget, 0)));
                obj_data.put('qtyotpend', hcm_util.convert_minute_to_hour(nvl(v_qtyotpend, 0)));
                obj_data.put('qtyotappr', hcm_util.convert_minute_to_hour(nvl(v_qtyotappr, 0)));
                obj_data.put('qtyremain', hcm_util.convert_minute_to_hour(CASE  WHEN nvl(nvl(c1.qtybudget, 0) - (nvl(v_qtyotpend, 0) + nvl(v_qtyotappr, 0)), 0) >= 0 THEN nvl(nvl(c1.qtybudget, 0) - (nvl(v_qtyotpend, 0) + nvl(v_qtyotappr, 0)), 0) ELSE 0 END));
                obj_data.put('qtypercentused', nvl(v_pctbguse, 0));
                if v_work > 0 then
                obj_data.put('otcompareworkhour', nvl(((nvl(v_qtyotpend,0) + nvl(v_qtyotappr, 0))) /   nvl(v_work, 0) * 100 , 0));
                else 
                obj_data.put('otcompareworkhour', 0);
                end if;

                if p_report = '1' then
                    if v_pctbguse <= 100 then
                        v_cnt_data := v_cnt_data + 1;
                        obj_row.put(to_char(v_rcnt), obj_data);
                    end if;
                elsif p_report = '2' then
                    if v_pctbguse > 100 then
                    v_cnt_data := v_cnt_data + 1;
                    obj_row.put(to_char(v_rcnt), obj_data);
                    end if;
                else 
                     v_cnt_data := v_cnt_data + 1;
                     obj_row.put(to_char(v_rcnt), obj_data);
                end if;

            end if;
          end loop;


          if v_cnt_data = 0 then
             param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'TBUDGETOT');
            json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
            return;
          end if;
        json_str_output := obj_row.to_clob;
        end;
  end gen_data;
    --
  procedure initial_value(json_str_input in clob) as
    json_obj              json_object_t;
  begin
    json_obj              := json_object_t(json_str_input);

    --global
    global_v_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd      := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang         := hcm_util.get_string_t(json_obj,'p_lang');


    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_month             := hcm_util.get_string_t(json_obj,'p_month');
    p_year              := hcm_util.get_string_t(json_obj,'p_year');
    p_report            := to_number(hcm_util.get_string_t(json_obj,'p_report'));


    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
    -- 
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if; --param_msg_error
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
    --
END;

/

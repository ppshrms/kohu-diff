--------------------------------------------------------
--  DDL for Package Body HRBF5CX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF5CX" as

      procedure initial_value(json_str_input in clob) AS
       json_obj    json;
      begin
        json_obj            := json(json_str_input);

        --global
        global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
        global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
        global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');

         -- index params
        p_codcomp           := hcm_util.get_string(json_obj, 'p_codcomp');
        p_typpayroll        := hcm_util.get_string(json_obj, 'p_typpayroll');
        p_numperiod         := hcm_util.get_string(json_obj, 'p_numperiod');
        p_dtemthpay         := hcm_util.get_string(json_obj, 'p_dtemthpay');
        p_dteyrepay         := hcm_util.get_string(json_obj, 'p_dteyrepay');
        p_typloan          := hcm_util.get_string(json_obj, 'p_typloan');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
      end initial_value;

      procedure get_index (json_str_input in clob, json_str_output out clob) as
      begin
        initial_value(json_str_input);
        if param_msg_error is null then
          gen_index(json_str_output);
        else
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      end get_index;

      procedure gen_index (json_str_output out clob) AS
            obj_data      json;
            obj_row       json := json();
            v_rcnt        number := 0;
            v_check_codcompy        number := 0;
            v_flg_secur7     boolean := false;
            v_flg_secur3     boolean := false;
            v_flg_exist      boolean := false;
            v_flg_permission     boolean := false;
            dynamicCursor        sys_refcursor;
            v_codcompy     tdtepay.codcompy%type;
            v_dtepaymt     tdtepay.dtepaymt%type;
            v_codempid     tothinc.codempid%type;
            v_codcomp      tothinc.codcomp%type;
            v_codpay       tothinc.codpay%type;
            v_amtpay       tothinc.amtpay%type;
            v_dteyrepay    tothinc.dteyrepay%type;
            v_dtemthpay    tothinc.dtemthpay%type;
            v_numperiod    tothinc.numperiod%type;
            v_namimage     tempimge.namimage%type;
            v_codpayc      tintrteh.codpayc%type;
            v_codpayd      tintrteh.codpayd%type;
            v_stmt         clob;
            v_stmts        clob;


            cursor c1 is
                    select a.codcomp,a.codempid,a.codpay,a.amtpay,a.dteyrepay,a.dtemthpay,a.numperiod
                      from tothinc a
                     where a.codpay in (select codpaye from tintrteh where codcompy = v_codcompy and dteeffec <= v_dtepaymt)
                       and a.codcomp like p_codcomp||'%'
                       and a.numperiod = p_numperiod
                       and a.dtemthpay = p_dtemthpay
                       and a.dteyrepay = p_dteyrepay
                       and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
                  order by a.codcomp,a.codempid;

            cursor c2 is
                select   t1.codcomp,t2.codempid,t2.codpay,
                         t2.dteyrepay,t2.dtemthpay,t2.numperiod,
                         sum(stddec(t2.amtpay,t1.codempid,v_chken))  amtpay
                  from   tloanpay t1,tothinc t2,tloaninf t3
                 where   t1.codempid  = t2.codempid
                   and    t1.numperiod = t2.numperiod
                   and    t1.dtemthpay = t2.dtemthpay
                   and    t1.dteyrepay = t2.dteyrepay
                   and    t1.numcont   = t3.numcont
                   and    t1.codcomp like p_codcomp||'%'
                   and    t1.typpayroll  = nvl(p_typpayroll,t1.typpayroll)
                   and    t1.numperiod   = p_numperiod
                   and    t1.dtemthpay   = p_dtemthpay
                   and    t1.dteyrepay   = p_dteyrepay
                   and    stddec(t2.amtpay,t1.codempid,v_chken) > 0
                   and   t1.flgtranpy  = 'Y'
                   and    exists (select a.codpayc
                                    from tintrteh a
                                   where a.codcompy = v_codcompy
                                     and a.codlon = t3.codlon
                                     and t2.codpay  in (a.codpayc ,a.codpayd )
                                     and a.dteeffec = (select max(b.dteeffec) from tintrteh b
                                                        where b.codcompy = a.codcompy
                                                          and b.codlon = a.codlon
                                                          and b.dteeffec <= v_dtepaymt))
              group by t1.codcomp,t2.codempid,t2.codpay,t2.dteyrepay,t2.dtemthpay,t2.numperiod
              order by t1.codcomp,t2.codempid,t2.codpay;


      begin
              v_codcomp := get_compful(p_codcomp);
              select count(codcomp) into v_check_codcompy
              from tcenter
              where codcomp = v_codcomp;

             v_chken  := hcm_secur.get_v_chken;
              if v_check_codcompy = 0 then
                 param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
              end if;

              if p_codcomp is not null then
                  v_flg_secur7 := secur_main.secur7(p_codcomp, global_v_coduser);
                  if not v_flg_secur7 then
                      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                      return;
                  end if;
              end if;
              v_codcompy := get_codcompy(v_codcomp);
            begin
                select dtepaymt
                  into v_dtepaymt
                  from tdtepay
                 where codcompy = v_codcompy
                   and numperiod = p_numperiod
                   and dtemthpay = p_dtemthpay
                   and dteyrepay = p_dteyrepay
                   and rownum = 1;
            exception when no_data_found then
                   v_dtepaymt := null;
            end;

            if p_typloan = '1' then
                for r1 in c1 loop
                    v_flg_exist := true;
                    exit;
                end loop;
            else
                for r2 in c2 loop
                    v_flg_exist := true;
                    exit;
                end loop;
            end if;

            if not v_flg_exist then
                param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TOTHINC');
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;

            if p_typloan = '1' then
                for r1 in c1 loop
                    v_flg_secur3 := secur_main.secur3(r1.codcomp,r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);

                    if v_flg_secur3 then

                        obj_data := json();
                        obj_data.put('image',get_emp_img(r1.codempid));
                        obj_data.put('codcomp',r1.codcomp);
                        obj_data.put('codempid',r1.codempid);
                        obj_data.put('namempid',get_temploy_name(r1.codempid,global_v_lang));
                        obj_data.put('desc_codpay',get_tinexinf_name(r1.codpay,global_v_lang));
                        obj_data.put('amtpay',stddec(r1.amtpay,r1.codempid,v_chken));
                        obj_data.put('dteyrepay',r1.dteyrepay);
                        obj_data.put('dtemthpay',r1.dtemthpay);
                        obj_data.put('numperiod',r1.numperiod);
                        obj_data.put('codpay',r1.codpay);
                        obj_row.put(to_char(v_rcnt-1),obj_data);
                        v_rcnt := v_rcnt + 1;
                        v_flg_permission := true;
                    end if;
                end loop;
            else
                for r2 in c2 loop
                    v_flg_secur3 := secur_main.secur3(r2.codcomp,r2.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);

                    if v_flg_secur3 then
                        v_chken  := hcm_secur.get_v_chken;
                        obj_data := json();
                        obj_data.put('image',get_emp_img(r2.codempid));
                        obj_data.put('codcomp',r2.codcomp);
                        obj_data.put('codempid',r2.codempid);
                        obj_data.put('namempid',get_temploy_name(r2.codempid,global_v_lang));
                        obj_data.put('desc_codpay',get_tinexinf_name(r2.codpay,global_v_lang));
                        --obj_data.put('amtpay',stddec(r2.amtpay,r2.codempid,v_chken));
                        obj_data.put('amtpay',r2.amtpay) ;
                        obj_data.put('dteyrepay',r2.dteyrepay);
                        obj_data.put('dtemthpay',r2.dtemthpay);
                        obj_data.put('numperiod',r2.numperiod);
                        obj_data.put('codpay',r2.codpay);
                        obj_row.put(to_char(v_rcnt-1),obj_data);
                        v_rcnt := v_rcnt + 1;
                        v_flg_permission := true;
                    end if;
                end loop;
            end if;

        if not v_flg_permission and v_flg_exist then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      END gen_index;

end HRBF5CX;

/

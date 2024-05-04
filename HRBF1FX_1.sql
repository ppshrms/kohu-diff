--------------------------------------------------------
--  DDL for Package Body HRBF1FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1FX" AS

        procedure initial_value(json_str_input in clob) as
            json_obj    json;
        begin
            json_obj            := json(json_str_input);

            --global
            global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
            global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
            global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');

            -- index params
            p_codcomp           := hcm_util.get_string(json_obj, 'p_codcomp');
            p_dtereqst          := hcm_util.get_string(json_obj, 'p_dtereqst');
            p_dtereqen          := hcm_util.get_string(json_obj, 'p_dtereqen');
            p_dtecrest          := hcm_util.get_string(json_obj, 'p_dtecrest');
            p_dtecreen          := hcm_util.get_string(json_obj, 'p_dtecreen');
            p_typpatient        := hcm_util.get_string(json_obj, 'p_typpatient');
            p_codcln            := hcm_util.get_string(json_obj, 'p_codcln');
            p_typpay            := hcm_util.get_string(json_obj, 'p_typpay');
            p_numvcher          := hcm_util.get_string(json_obj, 'p_numvcher');

            hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        end initial_value;

      procedure get_index_withdraw (json_str_input in clob, json_str_output out clob) AS
        begin
            initial_value(json_str_input);
            if param_msg_error is null then
                gen_index_withdraw(json_str_output);
            else
                json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            end if;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      end get_index_withdraw;

      procedure gen_index_withdraw (json_str_output out clob) AS
            obj_data      json;
            obj_row       json := json();
            v_rcnt        number := 0;
            v_flg_secur7        boolean := false;
            v_flg_exist         boolean := false;
            v_flg_permission     boolean := false;
            v_check_codcompy    number := 0;
            v_check_codcln      number := 0;
            q_numvcher    tclnsinf.numvcher%type;
            q_dtereqst    tclnsinf.dtereq%type;
            q_dtereqen    tclnsinf.dtereq%type;
            q_dtecrest    tclnsinf.dtecrest%type;
            q_dtecreen    tclnsinf.dtecreen%type;
            q_codcln      varchar2(40 char);
            q_typpay      varchar2(40 char);
            v_where       varchar2(4000 char);
            v_stmt	      varchar2(5000 char);
            v_cursor		  number;
            v_dummy           integer;
            v_qty             number := 0;
            v_codcomp     tclnsinf.codcomp%type;
            v_typpay      tclnsinf.typpay%type;
            v_numvcher    tclnsinf.numvcher%type;
            v_namimage    tempimge.namimage%type;
            v_codempid    tclnsinf.codempid%type;
            v_dtereq      tclnsinf.dtereq%type;
            v_dtecrest    tclnsinf.dtecrest%type;
            v_dtecreen    tclnsinf.dtecreen%type;
            v_namsick     tclnsinf.namsick%type;
            v_codrel      tclnsinf.codrel%type;
            v_typamt      tclnsinf.typamt%type;
            v_coddc       tclnsinf.coddc%type;
            v_codcln      tclnsinf.codcln%type;
            v_amtexp      tclnsinf.amtexp%type;
            v_numpaymt    tclnsinf.numpaymt%type;
            v_amtalw      tclnsinf.amtalw%type;
            v_amtovrpay   tclnsinf.amtovrpay%type;
            v_flgdocmt    tclnsinf.flgdocmt%type;
            v_flg_secur2         boolean := false;
            v_sum_amtexp     number := 0;
            v_sum_amtalw     number := 0;
            v_sum_amtovrpay  number := 0;
            sum_total_amtexp number := 0;
            sum_total_amtalw number := 0;
            sum_total_amtovrpay number := 0;
            type array_typpay is varray(2) of varchar2(1);
            typpay array_typpay := array_typpay('1', '2');

            cursor c1 is
                    select typpay,numvcher,b.namimage,a.codempid,dtereq,dtecrest,dtecreen,namsick,codrel,typpatient,typamt,coddc,codcln,amtexp,numpaymt,amtalw,amtovrpay,flgdocmt
                      from tclnsinf a
                 left join tempimge b
                        on a.codempid = b.codempid
                     where codcomp like p_codcomp||'%'
                       and dtereq between q_dtereqst and q_dtereqen
                       and codcln = nvl(p_codcln,codcln)
                       and typpay = nvl(p_typpay,typpay)
                       and typpatient =  nvl(p_typpatient,typpatient)
                  order by dtereq,typpay,numvcher asc;

            cursor c2 is
                    select typpay,numvcher,b.namimage,a.codempid,dtereq,dtecrest,dtecreen,namsick,codrel,typpatient,typamt,coddc,codcln,amtexp,numpaymt,amtalw,amtovrpay,flgdocmt
                      from tclnsinf a
                 left join tempimge b
                        on a.codempid = b.codempid
                     where codcomp like p_codcomp||'%'
                       and dtecrest between q_dtecrest and q_dtecreen
                       and codcln = nvl(p_codcln,codcln)
                       and typpay = nvl(p_typpay,typpay)
                       and typpatient =  nvl(p_typpatient,typpatient)
                  order by dtereq,typpay,numvcher asc;



      begin
            q_dtereqst := to_date(p_dtereqst,'DD/MM/YYYY');
            q_dtereqen := to_date(p_dtereqen,'DD/MM/YYYY');
            q_dtecrest := to_date(p_dtecrest,'DD/MM/YYYY');
            q_dtecreen := to_date(p_dtecreen,'DD/MM/YYYY');

            if p_typpatient = '5' then
                p_typpatient := '';
            end if;
            if p_typpay = '3' then
                 p_typpay := '' ;
            end if;
            v_codcomp := get_compful(p_codcomp);
            select count(codcomp) into v_check_codcompy
              from tcenter
              where codcomp = v_codcomp;

              if v_check_codcompy = 0 then
                 param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
              end if;

              if q_dtereqst > q_dtereqen then
                 param_msg_error := get_error_msg_php('HR2021',global_v_lang);
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
              end if;

              if q_dtecrest > q_dtecreen then
                 param_msg_error := get_error_msg_php('HR2021',global_v_lang);
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
              end if;

                --  secur_main.secur7
              if p_codcomp is not null then
                  v_flg_secur7 := secur_main.secur7(p_codcomp, global_v_coduser);
                  if not v_flg_secur7 then
                      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                      return;
                  end if;
              end if;

              for r1 in c1 loop
                   v_flg_exist := true;
                   exit;
              end loop;

              for r2 in c2 loop
                   v_flg_exist := true;
                   exit;
              end loop;

              if not v_flg_exist then
                   param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TCLNSINF');
                   json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                   return;
              end if;

              if p_codcln is not null then
                  select count(codcln) into v_check_codcln
                    from tclninf
                   where codcln = p_codcln;
                  if v_check_codcln = 0 then
                          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCLNINF');
                          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                          return;
                  end if;
              end if;

              if p_dtereqst is not null then
                for r1 in c1 loop
                    obj_data := json();
                    v_rcnt := v_rcnt + 1;
                    v_flg_secur2 := secur_main.secur2(r1.codempid,global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                    if  v_flg_secur2 then
                        v_flg_permission := true;
                        obj_data.put('typpay',get_tlistval_name('TTYPPAYBF',r1.typpay,global_v_lang));
                        obj_data.put('numvcher',r1.numvcher);
                        obj_data.put('namimage',r1.namimage);
                        obj_data.put('codempid',r1.codempid);
                        obj_data.put('namemp',get_temploy_name(r1.codempid,global_v_lang));
                        obj_data.put('dtereq', to_char(r1.dtereq,'DD/MM/YYYY'));
                        obj_data.put('namsick', r1.namsick);
                        obj_data.put('typrel', get_tlistval_name('TTYPRELATE',r1.codrel,global_v_lang));
                        obj_data.put('typpatient', get_tlistval_name('TYPPATIENT',r1.typpatient,global_v_lang));
                        obj_data.put('typamt', get_tlistval_name('TYPAMT',r1.typamt,global_v_lang));
                        obj_data.put('dtecrest', to_char(r1.dtecrest,'DD/MM/YYYY'));
                        obj_data.put('dtecreen', to_char(r1.dtecreen,'DD/MM/YYYY'));
                        obj_data.put('namdc', get_tdcinf_name(r1.coddc,global_v_lang));
                        obj_data.put('namcln', get_tclninf_name(r1.codcln,global_v_lang));
                        obj_data.put('amtexp', r1.amtexp);
                        obj_data.put('numpaymt', r1.numpaymt);
                        obj_data.put('amtalw', r1.amtalw);
                        obj_data.put('amtovrpay', r1.amtovrpay);
                        obj_data.put('flgdocmt', get_tlistval_name('TFLGDOCMT',r1.flgdocmt,global_v_lang));
                        obj_row.put(to_char(v_rcnt-1),obj_data);
                    end if;
                end loop;
              else
                for r2 in c2 loop
                    obj_data := json();
                    v_rcnt := v_rcnt + 1;
                    v_flg_secur2 := secur_main.secur2(r2.codempid,global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                    if  v_flg_secur2 then
                        v_flg_permission := true;
                        obj_data.put('typpay',get_tlistval_name('TTYPPAYBF',r2.typpay,global_v_lang));
                        obj_data.put('numvcher',r2.numvcher);
                        obj_data.put('namimage',r2.namimage);
                        obj_data.put('codempid',r2.codempid);
                        obj_data.put('namemp',get_temploy_name(r2.codempid,global_v_lang));
                        obj_data.put('dtereq', to_char(r2.dtereq,'DD/MM/YYYY'));
                        obj_data.put('namsick', r2.namsick);
                        obj_data.put('typrel', get_tlistval_name('TTYPRELATE',r2.codrel,global_v_lang));
                        obj_data.put('typpatient', get_tlistval_name('TYPPATIENT',r2.typpatient,global_v_lang));
                        obj_data.put('typamt', get_tlistval_name('TYPAMT',r2.typamt,global_v_lang));
                        obj_data.put('dtecrest', to_char(r2.dtecrest,'DD/MM/YYYY'));
                        obj_data.put('dtecreen', to_char(r2.dtecreen,'DD/MM/YYYY'));
                        obj_data.put('namdc', get_tdcinf_name(r2.coddc,global_v_lang));
                        obj_data.put('namcln', get_tclninf_name(r2.codcln,global_v_lang));
                        obj_data.put('amtexp', r2.amtexp);
                        obj_data.put('numpaymt', r2.numpaymt);
                        obj_data.put('amtalw', r2.amtalw);
                        obj_data.put('amtovrpay', r2.amtovrpay);
                        obj_data.put('flgdocmt', get_tlistval_name('TFLGDOCMT',r2.flgdocmt,global_v_lang));
                        obj_row.put(to_char(v_rcnt-1),obj_data);
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
      end gen_index_withdraw;

      procedure get_data_withdraw (json_str_input in clob, json_str_output out clob) AS
        begin
            initial_value(json_str_input);
            if param_msg_error is null then
                gen_data_withdraw(json_str_output);
            else
                json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            end if;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      end get_data_withdraw;

      procedure gen_data_withdraw (json_str_output out clob) AS
            obj_row       json := json();
            v_rcnt        number := 0;
            v_codcomp     tclnsinf.codcomp%type;
            v_codpos      tclnsinf.codpos%type;
            v_typpay      tclnsinf.typpay%type;
            v_numvcher    tclnsinf.numvcher%type;
            v_namimage    tempimge.namimage%type;
            v_codempid    tclnsinf.codempid%type;
            v_dtereq      tclnsinf.dtereq%type;
            v_dtecrest    tclnsinf.dtecrest%type;
            v_dtecreen    tclnsinf.dtecreen%type;
            v_namsick     tclnsinf.namsick%type;
            v_codrel      tclnsinf.codrel%type;
            v_typamt      tclnsinf.typamt%type;
            v_coddc       tclnsinf.coddc%type;
            v_codcln      tclnsinf.codcln%type;
            v_amtexp      tclnsinf.amtexp%type;
            v_amtalw      tclnsinf.amtalw%type;
            v_amtovrpay   tclnsinf.amtovrpay%type;
            v_flgdocmt    tclnsinf.flgdocmt%type;
            v_dtebill     tclnsinf.dtebill%type;
            v_qtydcare    tclnsinf.qtydcare%type;
            v_dteappr     tclnsinf.dteappr%type;
            v_codappr     tclnsinf.codappr%type;
            v_typpatient  tclnsinf.typpatient%type;
            v_amtavai     tclnsinf.amtavai%type;
            v_amtemp     tclnsinf.amtemp%type;
            v_amtpaid     tclnsinf.amtpaid%type;
            v_dtecash     tclnsinf.dtecash%type;
            v_image         varchar2(1000);
            v_has_image     varchar2(1);
        begin
            begin
                select codcomp,codpos,typpay,numvcher,a.codempid,dtereq,dtecrest,dtecreen,namsick,codrel,typamt,coddc,codcln,amtexp,amtalw,amtovrpay,flgdocmt,
                       dtebill,qtydcare,dteappr,codappr,namimage,typpatient,amtavai,amtemp,amtpaid,dtecash
                  into v_codcomp,v_codpos,v_typpay,v_numvcher,v_codempid,v_dtereq,v_dtecrest,v_dtecreen,v_namsick,v_codrel,v_typamt,v_coddc,v_codcln,v_amtexp,v_amtalw,v_amtovrpay,v_flgdocmt,
                       v_dtebill,v_qtydcare,v_dteappr,v_codappr,v_namimage,v_typpatient,v_amtavai,v_amtemp,v_amtpaid,v_dtecash
                  from tclnsinf a
             left join tempimge b
                    on a.codempid = b.codempid
                 where numvcher = p_numvcher
              order by numvcher;
            exception when no_data_found then
                v_codcomp := null;
                v_codpos := null;
                v_typpay := null;
                v_numvcher := null;
                v_codempid := null;
                v_dtereq := null;
                v_dtecrest := null;
                v_dtecreen := null;
                v_namsick := null;
                v_codrel := null;
                v_typamt := null;
                v_coddc := null;
                v_codcln := null;
                v_amtexp := null;
                v_amtalw := null;
                v_amtovrpay := null;
                v_flgdocmt := null;
                v_dtebill := null;
                v_qtydcare := null;
                v_dteappr := null;
                v_codappr := null;
                v_namimage := null;
                v_typpatient := null;
                v_amtavai := null;
                v_amtemp := null;
                v_amtpaid := null;
                v_dtecash := null;
            end;
            
            if not isInsertReport then
                obj_row.put('desc_codcomp',get_tcenter_name(v_codcomp, global_v_lang));
                obj_row.put('desc_codpos',get_tpostn_name(v_codpos, global_v_lang));
                obj_row.put('typpay',get_tlistval_name('TTYPPAYBF',v_typpay,global_v_lang));
                obj_row.put('numvcher',v_numvcher);
                obj_row.put('namimage',v_namimage);
                obj_row.put('codempid',v_codempid);
                obj_row.put('namemp',get_temploy_name(v_codempid,global_v_lang));
                obj_row.put('dtereq', to_char(v_dtereq,'DD/MM/YYYY'));
                obj_row.put('dtecrest', to_char(v_dtecrest,'DD/MM/YYYY'));
                obj_row.put('dtecreen', to_char(v_dtecreen,'DD/MM/YYYY'));
                obj_row.put('namsick', v_namsick);
                obj_row.put('typrel', get_tlistval_name('TTYPRELATE',v_codrel,global_v_lang));
                obj_row.put('typpatient',get_tlistval_name('TYPPATIENT',v_typpatient,global_v_lang));
                obj_row.put('typamt', get_tlistval_name('TYPAMT',v_typamt,global_v_lang));
                obj_row.put('namdc', get_tdcinf_name(v_coddc,global_v_lang));
                obj_row.put('namcln', get_tclninf_name(v_codcln,global_v_lang));
                obj_row.put('amtexp', to_char(v_amtexp,'fm999,999,990.00'));
                obj_row.put('amtalw', to_char(v_amtalw,'fm999,999,990.00'));
                obj_row.put('amtavai', to_char(v_amtavai,'fm999,999,990.00'));
                obj_row.put('amtovrpay', to_char(v_amtovrpay,'fm999,999,990.00'));
                obj_row.put('amtemp', to_char(v_amtemp,'fm999,999,990.00'));
                obj_row.put('amtpaid', to_char(v_amtpaid,'fm999,999,990.00'));
                obj_row.put('dtecash', to_char(v_dtecash,'DD/MM/YYYY'));
                obj_row.put('flgdocmt', get_tlistval_name('TFLGDOCMT',v_flgdocmt,global_v_lang));
                obj_row.put('dtebill', to_char(v_dtebill,'DD/MM/YYYY'));
                obj_row.put('qtycare', v_qtydcare);
                obj_row.put('dteappr', to_char(v_dteappr,'DD/MM/YYYY'));
                obj_row.put('codappr', v_codappr ||' - '|| get_temploy_name(v_codappr, global_v_lang));
                obj_row.put('coderror', '200');
                dbms_lob.createtemporary(json_str_output, true);
                obj_row.to_clob(json_str_output);
            else       
                p_codempid_query := v_codempid; 
                
                begin
                    select namimage
                      into v_image
                      from tempimge
                     where codempid = p_codempid_query;
                exception when no_data_found then
                    v_image := null;
                end;
    
                if v_image is not null then
                    v_image      := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_image;
                    v_has_image   := 'Y';
                end if;
                insert into ttemprpt (codempid, codapp, numseq,
                                      item1, item2, item3, 
                                      item4, item5, 
                                      item6, item7, 
                                      item8, item9, item10,
                                      item11, item12, item13, item14, item15, item16, item17, item18, item19, item20,
                                      item21, item22, item23, item24, item25, item26,
                                      item27, item28)
                values ( global_v_codempid, 'HRBF1FX', v_numseq,
                         'DETAIL', p_numvcher, v_codempid, 
                         get_temploy_name(v_codempid,global_v_lang), get_tcenter_name(v_codcomp, global_v_lang),
                         get_tpostn_name(v_codpos, global_v_lang), hcm_util.get_date_buddhist_era(v_dtereq),
                         get_tlistval_name('TTYPRELATE',v_codrel,global_v_lang), v_namsick,get_tclninf_name(v_codcln,global_v_lang),
                         get_tdcinf_name(v_coddc,global_v_lang), get_tlistval_name('TYPPATIENT',v_typpatient,global_v_lang), 
                         get_tlistval_name('TYPAMT',v_typamt,global_v_lang), hcm_util.get_date_buddhist_era(v_dtecrest)||' - '||hcm_util.get_date_buddhist_era(v_dtecreen), 
                         hcm_util.get_date_buddhist_era(v_dtebill), v_qtydcare, get_tlistval_name('TFLGDOCMT',v_flgdocmt,global_v_lang), 
                         to_char(v_amtexp,'fm999,999,990.00'), to_char(v_amtavai,'fm999,999,990.00'), to_char(v_amtovrpay,'fm999,999,990.00'),
                         to_char(v_amtemp,'fm999,999,990.00'), to_char(v_amtpaid,'fm999,999,990.00'), 
                         hcm_util.get_date_buddhist_era(v_dteappr), v_codappr ||' - '|| get_temploy_name(v_codappr, global_v_lang),
                         get_tlistval_name('TTYPPAYBF',v_typpay,global_v_lang), hcm_util.get_date_buddhist_era(v_dtecash),
                         v_image, v_has_image);
            end if;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end gen_data_withdraw;

      procedure get_table_withdraw (json_str_input in clob, json_str_output out clob) AS
        begin
            initial_value(json_str_input);
            if param_msg_error is null then
                gen_table_withdraw(json_str_output);
            else
                json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            end if;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      end get_table_withdraw;

      procedure gen_table_withdraw (json_str_output out clob) AS
            obj_data      json;
            obj_row       json := json();
            v_rcnt        number := 0;

            cursor c1 is
                select filename,descfile
                  from tclnsinff
                 where numvcher = p_numvcher
              order by numvcher;

      begin
        if not isInsertReport then
            for r1 in c1 loop
                obj_data := json();
                v_rcnt := v_rcnt + 1;
                obj_data.put('attfile',r1.filename);
                obj_data.put('desc_attfile',r1.descfile);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end loop;
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
        else
            for r1 in c1 loop
                v_rcnt      := v_rcnt + 1;
                v_numseq    := v_numseq + 1;
                insert into ttemprpt (codempid, codapp, numseq,
                                      item1, item2, item3, 
                                      item4, item5, item6)
                values ( global_v_codempid, 'HRBF1FX', v_numseq,
                         'TABLE', p_numvcher, p_codempid_query, 
                         v_rcnt, r1.filename, r1.descfile);
            end loop;
        end if;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end gen_table_withdraw;
      
   procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and upper(codapp) like upper('HRBF1FX') || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;    
  
  procedure get_report(json_str_input in clob, json_str_output out clob) is
    json_output       clob;
    p_select_arr                    json;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
        begin
            select nvl(max(numseq), 0)
              into v_numseq
              from ttemprpt
             where codempid = global_v_codempid
               and codapp = 'HRBF1FX';
        exception when no_data_found then
            v_numseq := 0;
        end;
        
        v_numseq    := nvl(v_numseq,0) + 1;
        
        gen_data_withdraw(json_output);
        gen_table_withdraw(json_output);
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_report;

END HRBF1FX;

/

--------------------------------------------------------
--  DDL for Package Body HRBF1ZX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1ZX" AS

      procedure initial_value(json_str_input in clob) AS
                json_obj    json;
            begin
                json_obj            := json(json_str_input);

                --global
                global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
                global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
                global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');

                json_params         := hcm_util.get_json(json_obj, 'json_input_str');

                -- index
                p_codcomp           := hcm_util.get_string(json_obj, 'p_codcomp');
                p_codempid          := hcm_util.get_string(json_obj, 'p_codempid');
                p_codcln            := hcm_util.get_string(json_obj, 'p_codcln');
                p_dtestrt           := hcm_util.get_string(json_obj, 'dtestrt');
                p_dteend            := hcm_util.get_string(json_obj, 'dteend');
                p_typamt            := hcm_util.get_string(json_obj, 'p_typamt');
                -- detail
                d_codempid          := hcm_util.get_string(json_obj, 'codempid');
                d_codcln            := hcm_util.get_string(json_obj, 'codcln');
                d_dtedocmt          := hcm_util.get_string(json_obj, 'dtedocmt');
                -- relation
                p_codrel            := hcm_util.get_string(json_obj, 'codrel');
                p_numdocmt          := hcm_util.get_string(json_obj, 'numdocmt');
                -- credit
                c_typamt            := hcm_util.get_string(json_obj, 'c_typamt');
                c_codempid          := hcm_util.get_string(json_obj, 'c_codempid');
                c_dtereq            := hcm_util.get_string(json_obj, 'c_dtedocmt');
                c_dtestart          := hcm_util.get_string(json_obj, 'c_dtedocmt');
                c_typrel            := hcm_util.get_string(json_obj, 'c_codrel');

                hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
      END initial_value;

      procedure get_index_docmt (json_str_input in clob, json_str_output out clob) AS
            begin
                initial_value(json_str_input);
                if param_msg_error is null then
                    gen_index_docmt(json_str_output);
                else
                    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
                end if;
            exception when others then
                param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
                json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      END get_index_docmt;

      procedure gen_index_docmt (json_str_output out clob) AS
                obj_data      json;
                obj_row       json := json();
                v_rcnt        number := 0;
                v_check_codempid      number := 0;
                v_check_codcln        number := 0;
                v_flg_secur      boolean := false;
                v_flg_secur2     boolean := false;
                v_flg_exist      boolean := false;
                v_flg_permission     boolean := false;
                v_check_codcompy    number := 0;
                v_namimage       tempimge.namimage%type;
                v_codcomp        tclndoc.codcomp%type;
                q_dtestrt        tclndoc.dtedocmt%type;
                q_dteend         tclndoc.dtedocmt%type;

                cursor c1 is
                    select codempid,dtedocmt,numdocmt,namsick,codrel,amtroom,codcln,stadocmt
                      from tclndoc
                     where codcln = p_codcln
                       and dtedocmt between q_dtestrt and q_dteend
                       and codcomp like nvl(p_codcomp||'%',codcomp)
                       and codempid = nvl(p_codempid,codempid)
                       and typamt =  nvl(p_typamt,typamt)
                  order by codempid;

          begin
                q_dtestrt := to_date(p_dtestrt,'DD/MM/YYYY');
                q_dteend  := to_date(p_dteend,'DD/MM/YYYY');
                if p_codempid is not null then
                      v_flg_secur := secur_main.secur2(p_codempid,global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                      if not v_flg_secur then
                          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                          return;
                      end if;
                        select count(codempid) into v_check_codempid
                        from temploy1
                        where codempid = p_codempid;
                      if v_check_codempid = 0 then
                          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                          return;
                      end if;
                end if;

                if p_codcomp is not null then
                    v_codcomp := get_compful(p_codcomp);
                    select count(codcomp) into v_check_codcompy
                    from tcenter
                    where codcomp = v_codcomp;

                    if v_check_codcompy = 0 then
                            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                            return;
                    end if;
                end if;

                if q_dtestrt > q_dteend then
                        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
                        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                        return;
                end if;

                for r1 in c1 loop
                    v_flg_exist := true;
                    exit;
                end loop;

                select count(codcln) into v_check_codcln
                from tclninf
                where codcln = p_codcln;

                if v_check_codcln = 0 then
                        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCLNINF');
                        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                        return;
                end if;
                for r1 in c1 loop
                    begin
                        select  namimage
                        into    v_namimage
                        from    tempimge
                        where   codempid = r1.codempid;
                    exception when no_data_found then
                        v_namimage := r1.codempid;
                    end;
                    obj_data := json();
                    v_rcnt := v_rcnt + 1;
                    v_flg_secur2 := secur_main.secur2(r1.codempid,global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                    if  v_flg_secur2 then
                        v_flg_permission := true;
                        obj_data.put('image',v_namimage);
                        obj_data.put('codempid',r1.codempid);
                        obj_data.put('desc_codempid',get_temploy_name(r1.codempid, global_v_lang));
                        obj_data.put('dtedocmt',to_char(r1.dtedocmt,'DD/MM/YYYY'));
                        obj_data.put('numdocmt',r1.numdocmt);
                        obj_data.put('namsick',r1.namsick);
                        obj_data.put('dscrel',get_tlistval_name('TTYPRELATE',r1.codrel,global_v_lang));
                        obj_data.put('desalw',r1.amtroom);
                        obj_data.put('codcln',r1.codcln);
                        obj_data.put('stadocmt',r1.stadocmt);
                        obj_row.put(to_char(v_rcnt-1),obj_data);
                    end if;
                end loop;

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
      END gen_index_docmt;

      procedure get_detail_docmt (json_str_input in clob, json_str_output out clob) AS
            begin
                initial_value(json_str_input);
                if param_msg_error is null then
                    gen_detail_docmt(json_str_output);
                else
                    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
                end if;
            exception when others then
                param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
                json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      END get_detail_docmt;

      procedure gen_detail_docmt (json_str_output out clob) AS
                obj_row       json := json();
                v_rcnt        number := 0;
                v_codcln      tclndoc.codcln%type;
                v_dtedocmt    tclndoc.dtedocmt%type;
                v_numdocmt    tclndoc.numdocmt%type;
                v_namsick     tclndoc.namsick%type;
                v_codrel      tclndoc.codrel%type;
                v_typamt      tclndoc.typamt%type;
                v_amtbalance  tclndoc.amtroom%type;
                v_coddocmt    tclndoc.coddocmt%type;
                v_remark      tclndoc.remark%type;
                v_stadocmt      tclndoc.stadocmt%type;
                q_dtedocmt    tclndoc.dtedocmt%type;
                stmt          clob;
                v_staemp      temploy1.staemp%type;
                c_numvcher    varchar2(4 char) := '';
                p_amtwidrwy  number := 0;
                p_qtywidrwy  number := 0;
                p_amtwidrwt  number := 0;
                p_amtacc     number := 0;
                p_amtacc_typ number := 0;
                p_qtyacc     number := 0;
                p_qtyacc_typ number := 0;
                p_amtbal     number := 0;

      begin

            begin
                select  staemp
                into    v_staemp
                from    temploy1
                where   codempid = d_codempid;
            exception when no_data_found then
                v_staemp := null;
            end;
            if v_staemp = '0' then
                param_msg_error := get_error_msg_php('HR2102',global_v_lang);
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;

            q_dtedocmt := to_date(d_dtedocmt,'DD/MM/YYYY');
            begin
                select codcln,dtedocmt,numdocmt,namsick,codrel,typamt,amtroom,coddocmt,remark,stadocmt
                  into v_codcln,v_dtedocmt,v_numdocmt,v_namsick,v_codrel,v_typamt,v_amtbalance,v_coddocmt,v_remark,v_stadocmt
                  from tclndoc
                 where codcln = d_codcln
                   and codempid = d_codempid
                   and dtedocmt = to_date(q_dtedocmt)
              order by codempid;
            exception when no_data_found then
                    v_codcln   := null;
                    v_dtedocmt := q_dtedocmt;
                    v_numdocmt := null;
                    v_namsick  := null;
                    v_codrel   := 'E';
                    v_typamt := '1';
                    v_amtbalance := null;
                    v_coddocmt := global_v_codempid;
                    v_remark   := null;
                    v_stadocmt   := null;
            end;

            std_bf.get_medlimit(d_codempid,v_dtedocmt,v_dtedocmt,c_numvcher,v_typamt,v_codrel,p_amtwidrwy,p_qtywidrwy,p_amtwidrwt,p_amtacc,p_amtacc_typ,p_qtyacc,p_qtyacc_typ,p_amtbal);       
            obj_row.put('max_credit', p_amtbal);

            obj_row.put('codcln',v_codcln);
            obj_row.put('dtedocmt',to_char(v_dtedocmt,'DD/MM/YYYY'));
            obj_row.put('report_dtedocmt',to_char(v_dtedocmt,'HH24:MI'));
            obj_row.put('codempid',d_codempid);
            obj_row.put('numdocmt',v_numdocmt);
            if v_codrel = 'E' then
                obj_row.put('namsick',d_codempid);
            else
                obj_row.put('namsick',v_namsick);
            end if;
            obj_row.put('codrel',v_codrel);
            obj_row.put('typamt',v_typamt);
            obj_row.put('amtbalance',v_amtbalance);
            obj_row.put('coddocmt',v_coddocmt);
            obj_row.put('remark',v_remark);
            obj_row.put('stadocmt',v_stadocmt);
            obj_row.put('coderror', '200');

            if isInsertReport then
                insert_ttemprpt(obj_row);
            end if;

            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      END gen_detail_docmt;

      procedure get_relation_docmt (json_str_input in clob, json_str_output out clob) AS
            begin
                initial_value(json_str_input);
                if param_msg_error is null then
                    gen_relation_docmt(json_str_output);
                else
                    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
                end if;
            exception when others then
                param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
                json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      END get_relation_docmt;

      procedure gen_relation_docmt (json_str_output out clob) AS
                obj_row       json := json();
                v_rcnt        number := 0;
                v_namsick        tclndoc.namsick%type;
               v_namfathe       tfamily.namfathe%type;
               v_namfatht       tfamily.namfatht%type;
               v_namfath3       tfamily.namfath3%type;
               v_namfath4       tfamily.namfath4%type;
               v_namfath5       tfamily.namfath5%type;
               v_nammothe       tfamily.nammothe%type;
               v_nammotht       tfamily.nammotht%type;
               v_nammoth3       tfamily.nammoth3%type;
               v_nammoth4       tfamily.nammoth4%type;
               v_nammoth5       tfamily.nammoth5%type;
               v_namche         tchildrn.namche%type;
               v_namcht         tchildrn.namcht%type;
               v_namch3         tchildrn.namch3%type;
               v_namch4         tchildrn.namch4%type;
               v_namch5         tchildrn.namch5%type;
               v_namspe         tspouse.namspe%type;
               v_namspt         tspouse.namspt%type;
               v_namsp3         tspouse.namsp3%type;
               v_namsp4         tspouse.namsp4%type;
               v_namsp5         tspouse.namsp5%type;
          begin
                begin
                    select namsick into v_namsick
                      from tclndoc
                     where numdocmt = p_numdocmt
                       and codrel = p_codrel;
                exception when no_data_found then
                    v_namsick := null ;
                end;
                if v_namsick is null then
                    begin
                        select b.namfathe,b.namfatht,b.namfath3,b.namfath4,b.namfath5,
                               b.nammothe,b.nammotht,b.nammoth3,b.nammoth4,b.nammoth5,
                               c.namche,c.namcht,c.namch3,c.namch4,c.namch5,
                               d.namspe,d.namspt,d.namsp3,d.namsp4,d.namsp5
                          into v_namfathe,v_namfatht,v_namfath3,v_namfath4,v_namfath5,
                               v_nammothe,v_nammotht,v_nammoth3,v_nammoth4,v_nammoth5,
                               v_namche,v_namcht,v_namch3,v_namch4,v_namch5,
                               v_namspe,v_namspt,v_namsp3,v_namsp4,v_namsp5
                          from temploy1 a
                     left join tfamily b
                            on a.codempid = b.codempid
                     left join tchildrn c
                            on a.codempid = c.codempid
                     left join tspouse d
                            on a.codempid = d.codempid
                         where a.codempid = d_codempid
                           and rownum = 1
                      order by a.codempid;
                    exception when no_data_found then
                       v_namfathe       := null;
                       v_namfatht       := null;
                       v_namfath3       := null;
                       v_namfath4       := null;
                       v_namfath5       := null;
                       v_nammothe       := null;
                       v_nammotht       := null;
                       v_nammoth3       := null;
                       v_nammoth4       := null;
                       v_nammoth5       := null;
                       v_namche         := null;
                       v_namcht         := null;
                       v_namch3         := null;
                       v_namch4         := null;
                       v_namch5         := null;
                       v_namspe         := null;
                       v_namspt         := null;
                       v_namsp3         := null;
                       v_namsp4         := null;
                       v_namsp5         := null;
                    end;
                        if p_codrel = 'F' then
                            if v_namfathe is null and v_namfatht is null and v_namfath3 is null and v_namfath4 is null and v_namfath5 is null then
                                param_msg_error := get_error_msg_php('HR6529',global_v_lang);
                                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                                return;
                            else
                                if global_v_lang = '101' then
                                    obj_row.put('namsick',v_namfathe);
                                elsif global_v_lang = '102' then
                                    obj_row.put('namsick',v_namfatht);
                                elsif global_v_lang = '103' then
                                    obj_row.put('namsick',v_namfath3);
                                elsif global_v_lang = '104' then
                                    obj_row.put('namsick',v_namfath4);
                                elsif global_v_lang = '105' then
                                    obj_row.put('namsick',v_namfath5);
                                end if;
                            end if;
                        elsif p_codrel = 'M' then
                            if v_nammothe is null and v_nammotht is null and v_nammoth3 is null and v_nammoth4 is null and v_nammoth5 is null then
                                param_msg_error := get_error_msg_php('HR6528',global_v_lang);
                                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                                return;
                            else
                                if global_v_lang = '101' then
                                    obj_row.put('namsick',v_nammothe);
                                elsif global_v_lang = '102' then
                                    obj_row.put('namsick',v_nammotht);
                                elsif global_v_lang = '103' then
                                    obj_row.put('namsick',v_nammoth3);
                                elsif global_v_lang = '104' then
                                    obj_row.put('namsick',v_nammoth4);
                                elsif global_v_lang = '105' then
                                    obj_row.put('namsick',v_nammoth5);
                                end if;
                            end if;
                        elsif p_codrel = 'C' then
                            if v_namche is null and v_namcht is null and v_namch3 is null and v_namch4 is null and v_namch5 is null then
                                param_msg_error := get_error_msg_php('HR6526',global_v_lang);
                                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                                return;
                            else
                                if global_v_lang = '101' then
                                    obj_row.put('namsick',v_namche);
                                elsif global_v_lang = '102' then
                                    obj_row.put('namsick',v_namcht);
                                elsif global_v_lang = '103' then
                                    obj_row.put('namsick',v_namch3);
                                elsif global_v_lang = '104' then
                                    obj_row.put('namsick',v_namch4);
                                elsif global_v_lang = '105' then
                                    obj_row.put('namsick',v_namch5);
                                end if;
                            end if;
                        elsif p_codrel = 'S' then
                            if v_namspe is null and v_namspt is null and v_namsp3 is null and v_namsp4 is null and v_namsp5 is null then
                                param_msg_error := get_error_msg_php('HR6525',global_v_lang);
                                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                                return;
                            else
                                if global_v_lang = '101' then
                                    obj_row.put('namsick',v_namspe);
                                elsif global_v_lang = '102' then
                                    obj_row.put('namsick',v_namspt);
                                elsif global_v_lang = '103' then
                                    obj_row.put('namsick',v_namsp3);
                                elsif global_v_lang = '104' then
                                    obj_row.put('namsick',v_namsp4);
                                elsif global_v_lang = '105' then
                                    obj_row.put('namsick',v_namsp5);
                                end if;
                            end if;
                        else
                            obj_row.put('namsick',d_codempid);
                        end if;
                    else
                        obj_row.put('namsick',v_namsick);
                    end if;

                    if param_msg_error is null then
                        obj_row.put('coderror', '200');
                        dbms_lob.createtemporary(json_str_output, true);
                        obj_row.to_clob(json_str_output);
                    else
                        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
                    end if;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      END gen_relation_docmt;

      procedure get_credit_docmt (json_str_input in clob, json_str_output out clob) AS
            begin
                initial_value(json_str_input);
                if param_msg_error is null then
                    gen_credit_docmt(json_str_output);
                else
                    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
                end if;
            exception when others then
                param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
                json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      END get_credit_docmt;

      procedure gen_credit_docmt (json_str_output out clob) AS
                obj_row       json := json();
                v_rcnt        number := 0;
                c_numvcher    varchar2(4 char) := '';
                p_amtwidrwy  number := 0;
                p_qtywidrwy  number := 0;
                p_amtwidrwt  number := 0;
                p_amtacc     number := 0;
                p_amtacc_typ number := 0;
                p_qtyacc     number := 0;
                p_qtyacc_typ number := 0;
                p_amtbal     number := 0;
             begin
                if c_typrel = 'M' then
                    c_typrel := 'F';
                end if;
                std_bf.get_medlimit(c_codempid,to_date(c_dtereq,'ddmmyyyy'),to_date(c_dtestart,'ddmmyyyy'),c_numvcher,c_typamt,c_typrel,p_amtwidrwy,p_qtywidrwy,p_amtwidrwt,p_amtacc,p_amtacc_typ,p_qtyacc,p_qtyacc_typ,p_amtbal);               
                if p_amtbal = 0 then
                    param_msg_error := get_error_msg_php('HR6541',global_v_lang);
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    return;
                end if;
                obj_row.put('credit', p_amtbal);
                obj_row.put('max_credit', p_amtbal);
                obj_row.put('coderror', '200');
                dbms_lob.createtemporary(json_str_output, true);
                obj_row.to_clob(json_str_output);
             exception when others then
                param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
                json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      END gen_credit_docmt;

      procedure save_data_docmt(json_str_input in clob, json_str_output out clob) as
            obj_row       json := json();
            v_check_coddocmt   number := 0;
            v_check_coddc      number := 0;
            v_flg_secur      boolean := false;
            v_codcln      tclndoc.codcln%type;
            v_codcomp     tclndoc.codcomp%type;
            v_codcompy    varchar2(4 char);
            v_codcompsub  varchar2(4 char);
            v_length      number := 0;
            v_dtedocmt    tclndoc.dtedocmt%type;
            v_codempid    tclndoc.codempid%type;
            v_numdocmt    tclndoc.numdocmt%type;
            v_namsick     tclndoc.namsick%type;
            v_codrel      tclndoc.codrel%type;
            v_typamt      tclndoc.typamt%type;
            v_amtbalance  tclndoc.amtroom%type;
            v_coddocmt    tclndoc.coddocmt%type;
            v_remark      tclndoc.remark%type;
            v_year        varchar2(4 char);
            v_numgen      varchar2(8 char);
            p_amtwidrwy  number := 0;
            p_qtywidrwy  number := 0;
            p_amtwidrwt  number := 0;
            p_amtacc     number := 0;
            p_amtacc_typ number := 0;
            p_qtyacc     number := 0;
            p_qtyacc_typ number := 0;
            p_amtbal     number := 0;

        begin
            initial_value(json_str_input);
            v_codcln          := hcm_util.get_string(json_params,'codcln');
            v_dtedocmt        := to_date(hcm_util.get_string(json_params,'dtedocmt'),'DD/MM/YYYY');
            v_codempid        := hcm_util.get_string(json_params,'codempid');
            v_numdocmt        := hcm_util.get_string(json_params,'numdocmt');
            v_codrel          := hcm_util.get_string(json_params,'codrel');
            if v_codrel = 'E' then
                v_namsick         := get_temploy_name(hcm_util.get_string(json_params,'namsick'), global_v_lang);
            else
                v_namsick         := hcm_util.get_string(json_params,'namsick');
            end if;
            v_typamt          := hcm_util.get_string(json_params,'typamt');
            v_amtbalance      := hcm_util.get_string(json_params,'amtbalance');
            v_coddocmt        := hcm_util.get_string(json_params,'coddocmt');
            v_remark          := hcm_util.get_string(json_params,'remark');



            begin
                select  codcomp
                into    v_codcomp
                from    temploy1
                where   codempid = v_codempid;
            exception when no_data_found then
                v_codcomp := null;
            end;
            v_codcompy        := get_codcompy(v_codcomp);
            v_length          := length(v_codcompy);
            v_codcompsub      := substr(v_codcomp,1,v_length);
            if v_coddocmt is not null then
                  v_flg_secur := secur_main.secur2(v_coddocmt,global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                  if not v_flg_secur then
                      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                      return;
                  end if;
                    select count(codempid) into v_check_coddocmt
                    from temploy1
                    where codempid = v_coddocmt;
                  if v_check_coddocmt = 0 then
                      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                      return;
                  end if;
            end if;

--            std_bf.get_medlimit(v_codempid,v_dtedocmt,v_dtedocmt,'',v_typamt,v_codrel,p_amtwidrwy,p_qtywidrwy,p_amtwidrwt,p_amtacc,p_amtacc_typ,p_qtyacc,p_qtyacc_typ,p_amtbal);
--            if p_amtbal < to_number(v_amtbalance) then
--                --wait answer pps
--            end if;
            if v_numdocmt is not null then
                begin
                    update  tclndoc
                    set     codcln        = v_codcln,
                            dtedocmt      = v_dtedocmt,
                            codempid      = v_codempid,
                            numdocmt      = v_numdocmt,
                            namsick       = v_namsick,
                            codrel        = v_codrel,
                            typamt        = v_typamt,
                            amtroom       = v_amtbalance,
                            coddocmt      = v_coddocmt,
                            remark        = v_remark,
                            dteupd        = trunc(sysdate),
                            coduser       = global_v_coduser
                    where   numdocmt      = v_numdocmt;
                exception when others then
                    rollback;
                end;
            else
                    v_year  := to_char(sysdate,'YYYY');
                    v_year  := substr(to_char(to_number(v_year+543)),3,2);
                    select to_char(nvl(max(substr(numdocmt,v_length+3)),0) + 1,'fm0000000')
                      into v_numgen
                      from tclndoc
                     where substr(numdocmt,1,v_length) = v_codcompsub
                       and substr(numdocmt,v_length+1,2) = v_year
                  order by dtecreate;
                    v_numdocmt := v_codcompsub||v_year||v_numgen;
                    begin
                        insert into tclndoc(numdocmt,codcln,codcomp,dtedocmt,codempid,namsick,codrel,typamt,amtroom,coddocmt,remark,stadocmt,codcreate)
                        values  (v_numdocmt,v_codcln,v_codcomp,v_dtedocmt,v_codempid,v_namsick,v_codrel,v_typamt,v_amtbalance,v_coddocmt,v_remark,'P',global_v_coduser);
                    exception when dup_val_on_index then
                        null;
                    end;
            end if;

                obj_row.put('coderror', '200');
                dbms_lob.createtemporary(json_str_output, true);
                obj_row.to_clob(json_str_output);
        if param_msg_error is null then
           param_msg_error := get_error_msg_php('HR2401',global_v_lang);
           json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        else
           json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_data_docmt;

    procedure delete_index_docmt(json_str_input in clob, json_str_output out clob) as
            param_json_row  json;
            v_numdocmt      tclndoc.numdocmt%type;
            v_stadocmt      tclndoc.stadocmt%type;
            flgDelete       varchar2(6 char);
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            for i in 0..json_params.count-1 loop
            param_json_row  := hcm_util.get_json(json_params, to_char(i));
            flgDelete     := hcm_util.get_string(param_json_row,'flg');
            v_numdocmt    := hcm_util.get_string(param_json_row,'numdocmt');
            v_stadocmt    := hcm_util.get_string(param_json_row,'stadocmt');
            if flgDelete = 'delete' then
                begin
                    delete from tclndoc
                          where numdocmt = v_numdocmt;
                exception when others then
                    null;
                end;
            end if;
            end loop;
        end if;


    if param_msg_error is null then
       param_msg_error := get_error_msg_php('HR2425',global_v_lang);
       json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);

    end delete_index_docmt;

    procedure initial_report(json_str in clob) is
        json_obj        json;
    begin
        json_obj            := json(json_str);
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        json_report         := hcm_util.get_json(json_obj, 'json_input_str');

    end initial_report;

    procedure gen_report(json_str_input in clob,json_str_output out clob) is
        v_json_report       json;
        json_output         clob;
    begin
        initial_report(json_str_input);
        isInsertReport := true;
        if param_msg_error is null then
          clear_ttemprpt;
          for i in 0..json_report.count-1 loop
            v_json_report       := hcm_util.get_json(json_report, to_char(i));
            d_codempid          := hcm_util.get_string(v_json_report, 'codempid');
            d_codcln            := hcm_util.get_string(v_json_report, 'codcln');
            d_dtedocmt          := hcm_util.get_string(v_json_report, 'dtedocmt');
            p_codapp            := 'HRBF1ZX';
            gen_detail_docmt(json_output);
          end loop;
        end if;

        if param_msg_error is null then
          param_msg_error := get_error_msg_php('HR2715',global_v_lang);
          commit;
        else
          rollback;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end gen_report;

    procedure clear_ttemprpt is
    begin
        begin
          delete
            from ttemprpt
           where codempid = global_v_codempid
             and codapp = 'HRBF1ZX';
        exception when others then
          null;
        end;
    end clear_ttemprpt;

    procedure insert_ttemprpt(obj_data in json) is
        v_numseq            number := 0;
        v_namsick     tclndoc.namsick%type;
    begin
        begin
          select nvl(max(numseq), 0)
            into v_numseq
            from ttemprpt
           where codempid = global_v_codempid
             and codapp   = p_codapp;
        exception when no_data_found then
          null;
        end;
        if hcm_util.get_string(obj_data, 'codrel') = 'E' then
                v_namsick := get_temploy_name(hcm_util.get_string(obj_data, 'namsick'),global_v_lang);
        else
            v_namsick := hcm_util.get_string(obj_data, 'namsick');
        end if;
        v_numseq := v_numseq + 1;
        begin
          insert
            into ttemprpt
               (
                 codempid, codapp, numseq,
                 item1, item2, item3, item4, item5, item6, item7, item8, item9, item10
               )
          values
               (
                 global_v_codempid, p_codapp, v_numseq,
                 nvl(hcm_util.get_string(obj_data, 'codcln'), ''),
                 nvl(hcm_util.get_string(obj_data, 'codempid'), ''),
                 nvl(get_display_date(hcm_util.get_string(obj_data, 'dtedocmt'),1),'') ||' '|| nvl(hcm_util.get_string(obj_data, 'report_dtedocmt'),''),
                 nvl(hcm_util.get_string(obj_data, 'numdocmt'), ''),
                 nvl(v_namsick, ''),
                 nvl(get_tlistval_name( 'TTYPRELATE', hcm_util.get_string(obj_data, 'codrel'), global_v_lang), ''),
                 nvl(get_tlistval_name( 'TYPAMT', hcm_util.get_string(obj_data, 'typamt'), global_v_lang), ''),
                 nvl(to_char(hcm_util.get_string(obj_data, 'amtbalance'), 'fm999,999,990.00'), ''),
                 nvl(hcm_util.get_string(obj_data, 'coddocmt') || ' - ' || get_temploy_name(hcm_util.get_string(obj_data, 'coddocmt'), global_v_lang), ''),
                 nvl(hcm_util.get_string(obj_data, 'remark'), '')
               );
        exception when others then
          null;
        end;
    end insert_ttemprpt;

END HRBF1ZX;

/

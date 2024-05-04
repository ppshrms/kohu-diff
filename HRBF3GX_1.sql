--------------------------------------------------------
--  DDL for Package Body HRBF3GX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF3GX" as

      procedure initial_value(json_str_input in clob) as
        json_obj    json;
      begin
        json_obj            := json(json_str_input);

        --global
        global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
        global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
        global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');

        p_codcomp           := hcm_util.get_string(json_obj, 'p_codcomp');
        p_numisr            := hcm_util.get_string(json_obj, 'p_numisr');
        p_dtemonth          := hcm_util.get_string(json_obj, 'p_dtemonth');
        p_dteyear           := hcm_util.get_string(json_obj, 'p_dteyear');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
      end initial_value;


      procedure check_index is
        v_codcomp   tcenter.codcomp%type;
        v_staemp    temploy1.staemp%type;
        v_flgSecur  boolean;
        --

        v_count_tcenter      number;
        v_count_numisr       number;
        v_rcnt               number := 1;
        v_flg_secure         boolean := false;
        v_flg_permission     boolean := false;
        v_flg_exist          boolean := false;
        v_check_tisrinf      number := 0;
        v_flgisr             tisrinf.flgisr%type;
        v_namimage           tempimge.namimage%type;
        v_cover              varchar2(50 char);
        --
      begin

    -- check codcomp exist in tcenter
        begin
            select count(codcomp)
              into v_count_tcenter
              from tcenter
             where codcomp like p_codcomp||'%'
               and rownum = 1;
        end;
        if v_count_tcenter = 0 then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
            return;
        end if;

        -- secur_main.secur7
        v_flg_secure := secur_main.secur7(p_codcomp, global_v_coduser);
        if not v_flg_secure then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

        -- check numisr exist in tisrinf
        begin
            select count(numisr)
              into v_count_numisr
              from tisrinf
             where numisr = p_numisr
               and rownum = 1;
        end;
        if v_count_numisr = 0 then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TISRINF');
            return;
        end if;

        -- check permission for codcompy
        begin
            select count(numisr)
              into v_check_tisrinf
              from tisrinf
             where numisr = p_numisr
               and codcompy = hcm_util.get_codcomp_level(p_codcomp,1) 
               and rownum = 1;
        end;--    
        if v_check_tisrinf = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TISRINF');
            return;
        end if;

--         begin
--            select count(numisr)
--              into v_check_tisrinf
--              from tinsrer
--             where numisr = p_numisr
--               and codcomp like p_codcomp||'%'
--               and rownum = 1;
--        end;
--        if v_check_tisrinf = 0 then
--            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TINSRER');
--            return;
--        end if;
      end;


      procedure get_header(json_str_input in clob, json_str_output out clob) as
      begin
        initial_value(json_str_input);
        if param_msg_error is null then
          gen_header(json_str_output);
        else
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      end get_header;

      procedure gen_header(json_str_output out clob) as
          obj_row           json := json ();
          v_flgisr          tisrinf.flgisr%type;
      begin
          begin
             select  flgisr
             into    v_flgisr
             from    tisrinf
             where   numisr = p_numisr;
          exception when no_data_found then
            v_flgisr := null;
          end;
          obj_row.put('flgisr', get_tlistval_name('TYPEPAYINS', v_flgisr, global_v_lang));
          obj_row.put('coderror', '200');
          dbms_lob.createtemporary(json_str_output, true);
          obj_row.to_clob(json_str_output);
      exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      end gen_header;

      procedure get_table (json_str_input in clob, json_str_output out clob) as
      begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
          gen_table(json_str_output);
        else
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      end get_table;

      procedure gen_table (json_str_output out clob) as
        obj_row              json    := json();
        obj_data             json;
        v_count_tcenter      number;
        v_count_numisr       number;
        v_rcnt               number := 1;
        v_flg_secure         boolean := false;
        v_flg_permission     boolean := false;
        v_flg_exist          boolean := false;
        v_check_tisrinf      number := 0;
        v_flgisr             tisrinf.flgisr%type;
        v_namimage           tempimge.namimage%type;
        v_cover              varchar2(50 char);

        cursor c1 is
            select a.codempid,a.codisrp,b.codecov,b.codfcov,a.amtisrp,a.amtpmiume,a.amtpmiumc,a.numisr,a.dteyear,a.dtemonth
              from tinsdinf a, tinsrer b
             where a.codempid  = b.codempid
               and a.numisr    = b.numisr
               and a.codcomp   like p_codcomp||'%'
               and a.numisr    = p_numisr
               and a.dtemonth  = p_dtemonth
               and a.dteyear   = p_dteyear
               and a.flgtranpy = 'Y'
          order by a.codempid;

          cursor c2 is
            select codempid,codisrp,codecov,codfcov,amtisrp,amtpmiumme,amtpmiummc,amtpmiumye,amtpmiumyc,numisr
              from tinsrer
             where codcomp like p_codcomp||'%'
               and numisr = p_numisr
          order by codempid;
      begin
        -- check exist by search condition
        if p_dtemonth is not null then
            for r1 in c1 loop
                v_flg_exist := true;
                -- secur_main.secur2
                v_flg_secure := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                if v_flg_secure then
                   v_flg_permission := true;
                    begin
                        select  namimage
                        into    v_namimage
                        from    tempimge
                        where   codempid = r1.codempid;
                    exception when no_data_found then
                        v_namimage := r1.codempid;
                    end;
                    obj_data := json();
                    obj_data.put('image', v_namimage);
                    obj_data.put('codempid', r1.codempid);
                    obj_data.put('namempid', get_temploy_name(r1.codempid, global_v_lang));
                    obj_data.put('codisrp', get_tcodec_name('TCODISRP', r1.codisrp, global_v_lang));
                    if r1.codecov = 'Y' then
                        v_cover := get_tlistval_name('TYPBENEFIT', 'E', global_v_lang);
                    end if;
                    if r1.codfcov = 'Y' then
                        v_cover := get_tlistval_name('TYPBENEFIT', 'E', global_v_lang)||', '||get_tlistval_name('TYPBENEFIT', 'F', global_v_lang);
                    end if;
                    obj_data.put('codcov', v_cover);
                    obj_data.put('amtisrp', r1.amtisrp);
                    obj_data.put('amtpmium', r1.amtpmiume + r1.amtpmiumc);
                    obj_data.put('amtpmiume', r1.amtpmiume);
                    obj_data.put('amtpmiumc', r1.amtpmiumc);
                    obj_data.put('numisr', r1.numisr);
                    obj_row.put(to_char(v_rcnt-1),obj_data);
                    v_rcnt := v_rcnt + 1;
                end if;
            end loop;
        else
            for r2 in c2 loop
            v_flg_exist := true;
            -- secur_main.secur2
            v_flg_secure := secur_main.secur2(r2.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
            if v_flg_secure then
               v_flg_permission := true;
                begin
                    select  namimage
                    into    v_namimage
                    from    tempimge
                    where   codempid = r2.codempid;
                exception when no_data_found then
                    v_namimage := null;
                end;
                obj_data := json();
                obj_data.put('image', v_namimage);
                obj_data.put('codempid', r2.codempid);
                obj_data.put('namempid', get_temploy_name(r2.codempid, global_v_lang));
                obj_data.put('codisrp', get_tcodec_name('TCODISRP', r2.codisrp, global_v_lang));
                if r2.codecov = 'Y' then
                    v_cover := get_tlistval_name('TYPBENEFIT', 'E', global_v_lang);
                end if;
                if r2.codfcov = 'Y' then
                    v_cover := get_tlistval_name('TYPBENEFIT', 'E', global_v_lang)||', '||get_tlistval_name('TYPBENEFIT', 'F', global_v_lang);
                end if;
                obj_data.put('codcov', v_cover);
                obj_data.put('amtisrp', r2.amtisrp);
                begin
                    select  flgisr
                    into    v_flgisr
                    from    tisrinf
                    where   numisr = r2.numisr;
                exception when no_data_found then
                    v_flgisr := null;
                end;
                if v_flgisr = '1' then
                    obj_data.put('amtpmium', r2.amtpmiumme + r2.amtpmiummc);
                    obj_data.put('amtpmiume', r2.amtpmiumme);
                    obj_data.put('amtpmiumc', r2.amtpmiummc);
                elsif v_flgisr = '4' then
                    obj_data.put('amtpmium', r2.amtpmiumye + r2.amtpmiumyc);
                    obj_data.put('amtpmiume', r2.amtpmiumye);
                    obj_data.put('amtpmiumc', r2.amtpmiumyc);
                end if;
                obj_data.put('numisr', r2.numisr);
                obj_row.put(to_char(v_rcnt-1),obj_data);
                v_rcnt := v_rcnt + 1;
            end if;
         end loop;
        end if;

        if not v_flg_exist then
           if p_dtemonth is not null then
              param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TINSDINF');
           else
              param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TINSRER');
           end if;
           json_str_output := get_response_message('400',param_msg_error,global_v_lang);
           return;
        end if;

        if not v_flg_permission and v_flg_exist then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
          return;
        end if;

        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
      exception when others then
         param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
         json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      end gen_table;

end HRBF3GX;

/

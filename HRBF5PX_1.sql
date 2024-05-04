--------------------------------------------------------
--  DDL for Package Body HRBF5PX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF5PX" as

  procedure initial_value(json_str_input in clob) as
    json_obj    json;
  begin
    json_obj            := json(json_str_input);

    -- global
    global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
    global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');

    p_codcomp           := hcm_util.get_string(json_obj, 'p_codcomp');
    p_dteadjustfr       := hcm_util.get_string(json_obj, 'p_dteadjustfr');
    p_dteadjustto       := hcm_util.get_string(json_obj, 'p_dteadjustto');
    p_codlon            := hcm_util.get_string(json_obj, 'p_codlon');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

 procedure check_index as
        v_temp varchar2(1 char);
    begin

        -- บังคับการใส่ข้อมูล
        if p_codcomp is null  then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        -- รหัสหน่วยงานให้ Check Security โดยใช้ secur_main.secur7 หากไม่มีสิทธิ์ดูข้อมูลให้ Alert HR3007
        if p_codcomp is not null then

            -- รหัสหน่วยงาน ต้องมีข้อมูลในตาราง TCENTER (HR2010)
            begin
                select 'X' into v_temp
                from tcenter
                where codcomp like p_codcomp||'%' and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                return;
            end;
            -------
            if secur_main.secur7(p_codcomp,global_v_coduser) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;

        if  p_dteadjustto is null or p_dteadjustfr is null  then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        else
            -- check date adjust end > start
            if to_date(p_dteadjustto,'dd/mm/yyyy') < to_date(p_dteadjustfr,'dd/mm/yyyy') then
                param_msg_error := get_error_msg_php('HR2021',global_v_lang);
                return;
            end if;
        end if;


        -- รหัสประเภทเงินกู้ ต้องมีข้อมูลในตาราง TTYPLOAN (HR2010)
        begin
            select 'X'
            into v_temp
            from ttyploan
            where codlon like nvl(p_codlon,codlon)
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TTYPLOAN');
            return;
        end;
       ---


    end check_index;


  procedure get_index (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;


  procedure gen_index (json_str_output out clob) as
    obj_row              json    := json();
    obj_data             json;
    v_rcnt               number := 1;
    v_count_tcenter      number;
    v_count_ttyploan     number;
    v_flg_exist          boolean := false;
    v_flg_secur1         boolean := false;
    v_flg_secur2         boolean := false;
    v_flg_secur7         boolean := false;
    v_flg_permission     boolean := false;
    v_namimage           tempimge.namimage%type;
    arr_new_val          dbms_sql.varchar2_table;
    arr_old_val          dbms_sql.varchar2_table;

    cursor c1 is
        select a.codempid,numlvl,dteadjust,dteeffec,numcont,codlon,typtran,
               a.coduser,a.dteupd,
               amtpayo,amtpayn,amtlono,amtlonn,
               amtpinto,amtpintn,amtpfino,amtpfinn,
               amtpinto2,amtpintn2,ratelono,ratelonn,
               amtrpmto,amtrpmtn,qtypayo,qtypayn,
               formulao,formulan,a.codcomp
          from tloanadj a, temploy1 b
         where a.codempid = b.codempid
           and a.codcomp like p_codcomp||'%'
           and trunc(a.dteadjust) between to_date(p_dteadjustfr,'dd/mm/yyyy') and to_date(p_dteadjustto,'dd/mm/yyyy')
           and a.codlon = nvl(p_codlon,a.codlon)
      order by a.dteadjust,a.codempid;

  begin


    for r1 in c1 loop
        v_flg_exist := true;
        v_flg_secur1 := secur_main.secur1(r1.codcomp, r1.numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
        if v_flg_secur1 then
            v_flg_permission := true;
            begin
                select  namimage
                  into  v_namimage
                  from  tempimge
                 where  codempid = r1.codempid;
            exception when no_data_found then
                v_namimage := r1.codempid;
            end;

            arr_old_val(1)  := to_char(r1.amtpayo, 'fm999,999,990.00');
            arr_old_val(2)  := to_char(r1.amtlono, 'fm999,999,990.00');
            arr_old_val(3)  := to_char(r1.amtpinto, 'fm999,999,990.00');
            arr_old_val(4)  := to_char(r1.amtpfino, 'fm999,999,990.00');
            arr_old_val(5)  := to_char(r1.amtpinto2, 'fm999,999,990.00');
            arr_old_val(6)  := to_char(r1.ratelono, 'fm990.00');
            arr_old_val(7)  := to_char(r1.amtrpmto, 'fm999,999,990.00');
            arr_old_val(8)  := r1.qtypayo;
            arr_old_val(9)  := hcm_formula.get_description(r1.formulao,global_v_lang);--User37 #3450 BF Module 08/04/2021 r1.formulao;

            arr_new_val(1)  := to_char(r1.amtpayn, 'fm999,999,990.00');
            arr_new_val(2)  := to_char(r1.amtlonn, 'fm999,999,990.00');
            arr_new_val(3)  := to_char(r1.amtpintn, 'fm999,999,990.00');
            arr_new_val(4)  := to_char(r1.amtpfinn, 'fm999,999,990.00');
            arr_new_val(5)  := to_char(r1.amtpintn2, 'fm999,999,990.00');
            arr_new_val(6)  := to_char(r1.ratelonn, 'fm990.00');
            arr_new_val(7)  := to_char(r1.amtrpmtn, 'fm999,999,990.00');
            arr_new_val(8)  := r1.qtypayn;
            arr_new_val(9)  := hcm_formula.get_description(r1.formulan,global_v_lang);--User37 #3450 BF Module 08/04/2021 r1.formulan;

            for i in arr_new_val.first..arr_new_val.last loop
                if arr_new_val(i) is not null then
                    obj_data := json();
                    if r1.dteadjust = trunc(r1.dteadjust) then
                        obj_data.put('dteadjust', to_char(r1.dteadjust,'dd/mm/yyyy'));
                    else
                        obj_data.put('dteadjust', to_char(r1.dteadjust,'dd/mm/yyyy hh24:mi'));
                    end if;
                    obj_data.put('dteeffec', to_char(r1.dteeffec, 'dd/mm/yyyy'));
                    obj_data.put('image', v_namimage);
                    obj_data.put('codempid', r1.codempid);
                    obj_data.put('namempid', get_temploy_name(r1.codempid, global_v_lang));
                    obj_data.put('desc_codlon', get_ttyplone_name(r1.codlon, global_v_lang));
                    obj_data.put('numcont', r1.numcont);
                    obj_data.put('typtran', r1.typtran);
                    obj_data.put('desc_typtran', get_tlistval_name('TYPADJLOAN', r1.typtran, global_v_lang));
                    obj_data.put('label_detail', get_label_name('HRBF5PXC3', global_v_lang, i||'0'));
                    obj_data.put('old', arr_old_val(i));
                    obj_data.put('new', arr_new_val(i));
                    --<<User37 #3450 BF - iNET 05/04/2021
                    --obj_data.put('coduser', get_temploy_name(r1.coduser, global_v_lang));
                    obj_data.put('coduser', get_temploy_name(get_codempid(r1.coduser), global_v_lang));
                    -->>User37 #3450 BF - iNET 05/04/2021
                    obj_data.put('dteupd', to_char(r1.dteupd, 'dd/mm/yyyy'));
                    obj_row.put(to_char(v_rcnt-1),obj_data);
                    v_rcnt := v_rcnt + 1;
                end if;
            end loop;
            end if;
    end loop;

     if not v_flg_exist and not v_flg_permission  then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

     if  v_flg_exist and not v_flg_permission  then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;



--    for r1 in c1 loop
--        -- secur_main.secur1 and secur_main.secur2
--        v_flg_secur1 := secur_main.secur1(p_codcomp, r1.numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
--        v_flg_secur2 := secur_main.secur2(r1.codempid,global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
--        if v_flg_secur1 and v_flg_secur2 then
--            v_flg_permission := true;
--            begin
--                select  namimage
--                  into  v_namimage
--                  from  tempimge
--                 where  codempid = r1.codempid;
--            exception when no_data_found then
--                v_namimage := r1.codempid;
--            end;
--
--            arr_old_val(1)  := to_char(r1.amtpayo, 'fm999,999,990.00');
--            arr_old_val(2)  := to_char(r1.amtlono, 'fm999,999,990.00');
--            arr_old_val(3)  := to_char(r1.amtpinto, 'fm999,999,990.00');
--            arr_old_val(4)  := to_char(r1.amtpfino, 'fm999,999,990.00');
--            arr_old_val(5)  := to_char(r1.amtpinto2, 'fm999,999,990.00');
--            arr_old_val(6)  := to_char(r1.ratelono, 'fm990.00');
--            arr_old_val(7)  := to_char(r1.amtrpmto, 'fm999,999,990.00');
--            arr_old_val(8)  := r1.qtypayo;
--            arr_old_val(9)  := r1.formulao;
--
--            arr_new_val(1)  := to_char(r1.amtpayn, 'fm999,999,990.00');
--            arr_new_val(2)  := to_char(r1.amtlonn, 'fm999,999,990.00');
--            arr_new_val(3)  := to_char(r1.amtpintn, 'fm999,999,990.00');
--            arr_new_val(4)  := to_char(r1.amtpfinn, 'fm999,999,990.00');
--            arr_new_val(5)  := to_char(r1.amtpintn2, 'fm999,999,990.00');
--            arr_new_val(6)  := to_char(r1.ratelonn, 'fm990.00');
--            arr_new_val(7)  := to_char(r1.amtrpmtn, 'fm999,999,990.00');
--            arr_new_val(8)  := r1.qtypayn;
--            arr_new_val(9)  := r1.formulan;
--
--            for i in arr_new_val.first..arr_new_val.last loop
--                if arr_new_val(i) is not null then
--                    obj_data := json();
--                    if r1.dteadjust = trunc(r1.dteadjust) then
--                        obj_data.put('dteadjust', to_char(r1.dteadjust,'dd/mm/yyyy'));
--                    else
--                        obj_data.put('dteadjust', to_char(r1.dteadjust,'dd/mm/yyyy hh24:mi'));
--                    end if;
--                    obj_data.put('dteeffec', to_char(r1.dteeffec, v_format_date));
--                    obj_data.put('image', v_namimage);
--                    obj_data.put('codempid', r1.codempid);
--                    obj_data.put('namempid', get_temploy_name(r1.codempid, global_v_lang));
--                    obj_data.put('desc_codlon', get_ttyplone_name(r1.codlon, global_v_lang));
--                    obj_data.put('numcont', r1.numcont);
--                    obj_data.put('typtran', r1.typtran);
--                    obj_data.put('desc_typtran', get_tlistval_name('TYPADJLOAN', r1.typtran, global_v_lang));
--                    obj_data.put('label_detail', get_label_name('HRBF5PXC3', global_v_lang, i||'0'));
--                    obj_data.put('old', arr_old_val(i));
--                    obj_data.put('new', arr_new_val(i));
--                    obj_data.put('coduser', get_temploy_name(r1.coduser, global_v_lang));
--                    obj_data.put('dteupd', to_char(r1.dteupd, v_format_date));
--                    obj_row.put(to_char(v_rcnt-1),obj_data);
--                    v_rcnt := v_rcnt + 1;
--                end if;
--            end loop;
--        end if;
--    end loop;

--    if not v_flg_permission and v_flg_exist then
--      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
--      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--      return;
--    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
     param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
     json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

end HRBF5PX;

/

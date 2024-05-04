--------------------------------------------------------
--  DDL for Package Body HRPY22E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY22E" as
  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail, 'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail, 'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail, 'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_numperiod         := hcm_util.get_number_t(obj_detail, 'numperiod');
    p_month             := hcm_util.get_number_t(obj_detail, 'month');
    p_year              := hcm_util.get_number_t(obj_detail, 'year');
    p_codcomp           := hcm_util.get_string_t(obj_detail, 'codcomp');
    p_codcompw          := replace(hcm_util.get_string_t(obj_detail, 'codcompw'),'-','');
    p_typpayroll        := hcm_util.get_string_t(obj_detail, 'typpayroll');
    p_codempid          := hcm_util.get_string_t(obj_detail, 'codempid_query');
    p_qtysmot           := null;
    p_amtottot          := null;
    param_json          := hcm_util.get_json_t(obj_detail, 'param_json');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'numperiod');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'year');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodtypy');
      end;
    end if;
  end check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as -- p_numperiod p_month p_year / p_codcomp p_typpayroll
    obj_rows            json_object_t := json_object_t();
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_codempid          temploy1.codempid%type;
    v_flgsecu           boolean;
    v_exist             boolean := false;
    v_fetch             boolean := false;
    v_flgtrnbank        varchar2(1 char);

    cursor c1 is -- a.codempid, b.codcompw, a.codcomp, b.qtysmot, a.amtothr, b.amtspot
      select a.codempid, a.codcomp, stddec(a.amtothr, a.codempid, global_v_chken) amtothr,
             b.numlvl, a.typpayroll
        from totsum a, temploy1 b
       where a.numperiod  = p_numperiod
         and a.dtemthpay  = p_month
         and a.dteyrepay  = p_year
         and a.codcomp    like p_codcomp || '%'
         and a.typpayroll = nvl(p_typpayroll, a.typpayroll)
         and a.codempid   = b.codempid
--         and b.numlvl between global_v_zminlvl and global_v_zwrklvl
         and exists (select c.coduser
                       from tusrcom c
                      where c.coduser = global_v_coduser
                        and b.codcomp like c.codcomp || '%')
    order by a.codempid;

    cursor c2 is
      select codcompw, sum(qtysmot) qtysmot, sum(nvl(stddec(amtspot, codempid, global_v_chken), 0)) amtspot
        from totsumd
       where codempid  = v_codempid
         and numperiod = p_numperiod
         and dtemthpay = p_month
         and dteyrepay = p_year
    group by codcompw
    order by codcompw;
  begin
    for r1 in c1 loop
      v_exist := true;
      v_flgsecu := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgsecu then
          v_fetch := true;
          v_codempid := r1.codempid;
          for r2 in c2 loop
            v_rcnt   := v_rcnt + 1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('codempid', r1.codempid);
            obj_data.put('numperiod', p_numperiod);
            obj_data.put('month', p_month);
            obj_data.put('year', p_year);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcompw', hcm_util.get_codcomp_level(r2.codcompw,'','-'));
            obj_data.put('desc_codcompw', get_tcenter_name(r2.codcompw, global_v_lang));
            obj_data.put('codcompwd', r2.codcompw);--User37 #6888 25/10/2021 
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
            obj_data.put('qtysmot', to_char(r2.qtysmot));
            obj_data.put('typpayroll', r1.typpayroll);
            -- if r1.numlvl between global_v_numlvlsalst and global_v_numlvlsalen then
            if v_zupdsal = 'Y' then
              obj_data.put('amtothr', to_char(r1.amtothr));
              obj_data.put('amtspot', to_char(r2.amtspot));
            else
              obj_data.put('amtothr', '');
              obj_data.put('amtspot', '');
            end if;
            -- end if;
            begin
              select nvl(flgtrnbank,'N')
                into v_flgtrnbank
                from ttaxcur
               where codempid = v_codempid
                 and to_date(numperiod||'/'||dtemthpay||'/'||dteyrepay) =  to_date(p_numperiod||'/'||p_month||'/'||p_year)
                 and rownum = 1;
            exception when no_data_found then
              v_flgtrnbank := 'N';
            end;
            obj_data.put('flgtrnbank', v_flgtrnbank);
            obj_rows.put(to_char(v_rcnt - 1), obj_data);
          end loop;
      end if;
    end loop;
--    if v_exist and not v_fetch then
--        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
--        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
--    else
        json_str_output := obj_rows.to_clob;
--    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

  procedure check_detail as
    v_staemp temploy1.staemp%type;
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'numperiod');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'year');
      return;
    end if;
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'codempid');
      return;
    end if;
    if p_codempid is not null then
      if not secur_main.secur2(p_codempid, global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
      begin
        select staemp
          into v_staemp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
      end;
      if v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102', global_v_lang);
        return;
      end if;
    end if;
  end check_detail;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
        gen_detail(json_str_output);
    else
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob) as
    obj_data            json_object_t := json_object_t();
    v_amtothr           temploy3.amtothr%type;
    v_flgtrnbank        varchar2(1 char);
  begin
    begin
      select stddec(amtothr, codempid, global_v_chken)
        into v_amtothr
        from temploy3
        where codempid = p_codempid;
    exception when no_data_found then
      v_amtothr := 0;
    end;
     begin
      select flgtrnbank
        into v_flgtrnbank
        from ttaxcur
       where codempid = p_codempid
         and to_date(numperiod||'/'||dtemthpay||'/'||dteyrepay) =  to_date(p_numperiod||'/'||p_month||'/'||p_year)
         and rownum = 1;
    exception when no_data_found then
      v_flgtrnbank := 'N';
    end;
    obj_data.put('coderror', '200');
    obj_data.put('amtothr', to_char(v_amtothr));
    obj_data.put('flgtrnbank', v_flgtrnbank);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;

  procedure get_detail_table(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail_table(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail_table;

  procedure gen_detail_table (json_str_output out clob) as
    obj_rows            json_object_t := json_object_t();
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1_totsumd is
      select rtesmot, qtysmot, stddec(amtspot, codempid, global_v_chken) amtspot,codsys
        from totsumd
       where codempid   = p_codempid
         and numperiod  = p_numperiod
         and dtemthpay  = p_month
         and dteyrepay  = p_year
         and codcompw   = get_compful(p_codcompw)
    order by rtesmot, qtysmot;

  begin
    for r1 in c1_totsumd loop
      v_rcnt    := v_rcnt + 1;
      obj_data  := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('rtesmot', to_char(r1.rtesmot));
      obj_data.put('qtysmot', hcm_util.convert_minute_to_hour(r1.qtysmot));
      obj_data.put('amtspot', to_char(r1.amtspot, 'fm999999999990.00'));
      obj_data.put('codsys', r1.codsys);
      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail_table;

  procedure check_save_index as
  begin
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end check_save_index;

  procedure post_save_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end post_save_index;

  procedure save_index(json_str_output out clob) as
    json_obj        json_object_t;
    v_flg           varchar2(4000 char);
  begin
    for i in 0..param_json.get_size-1 loop
      if param_msg_error is not null then
        exit;
      end if;
      json_obj      := hcm_util.get_json_t(param_json, to_char(i));
      v_flg         := hcm_util.get_string_t(json_obj, 'flg');
      if v_flg = 'delete' then
        p_codempid  := hcm_util.get_string_t(json_obj, 'codempid');
        p_codcompw  := hcm_util.get_string_t(json_obj, 'codcompwd');--User37 #6888 25/10/2021 p_codcompw  := replace(hcm_util.get_string_t(json_obj, 'codcompw'),'-','');
        p_numperiod := hcm_util.get_string_t(json_obj, 'numperiod');
        p_month     := hcm_util.get_string_t(json_obj, 'month');
        p_year      := hcm_util.get_string_t(json_obj, 'year');
        check_save_index;
        if param_msg_error is not null then
          exit;
        end if; 
        delete_totsumd(p_codempid, p_numperiod, p_month, p_year, null, p_codcompw);
      end if;
    end loop;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      rollback;
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;

  procedure check_save_detail as
    v_staemp temploy1.staemp%type;
  begin
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_codempid is not null then
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
      begin
        select staemp
          into v_staemp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
      end;
      if v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102', global_v_lang);
        return;
      end if;
    end if;
  end check_save_detail;

  procedure post_save_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_detail(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure save_detail(json_str_output out clob) as
    json_obj        json_object_t;
    v_flg           varchar2(10 char);
    v_rtesmot       totsumd.rtesmot%type;
    v_qtysmot       totsumd.qtysmot%type;
    v_amtspot       totsumd.amtspot%type;
    v_codsys       totsumd.codsys%type;
    v_costcent      tcenter.costcent%type;
  begin
    for i in 0..param_json.get_size-1 loop
      if param_msg_error is not null then
        exit;
      end if;
      json_obj      := hcm_util.get_json_t(param_json, to_char(i));
      v_flg         := hcm_util.get_string_t(json_obj, 'flg');
      v_rtesmot     := hcm_util.get_string_t(json_obj, 'rtesmot');
      v_qtysmot     := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj, 'qtysmot'));
      v_codsys      := hcm_util.get_string_t(json_obj, 'codsys');
      v_amtspot     := hcm_util.get_string_t(json_obj, 'amtspot');
      if v_flg = 'delete' then
        delete_totsumd (p_codempid, p_numperiod, p_month, p_year, v_rtesmot, p_codcompw);
      else
        begin
          select costcent
            into v_costcent
            from tcenter
           where codcomp = p_codcompw;
        exception when no_data_found then
          v_costcent := null;
        end;
        check_save_detail;
        if param_msg_error is not null then
          exit;
        end if;

        if v_flg ='edit' then
          update totsumd
            set qtysmot   = v_qtysmot,
                amtspot   = stdenc(v_amtspot, p_codempid, global_v_chken),
                costcent  = v_costcent,
                coduser   = global_v_coduser,
                codsys    = v_codsys
          where codempid  = p_codempid
            and dteyrepay = p_year
            and dtemthpay = p_month
            and numperiod = p_numperiod
            and rtesmot   = v_rtesmot
            and codcompw  = p_codcompw;
        else
            begin
              insert into totsumd
              (codempid, dteyrepay, dtemthpay, numperiod,
              rtesmot, codcompw, qtysmot, amtspot,
              costcent, codcreate, codsys)
              values
              (p_codempid, p_year, p_month, p_numperiod,
              v_rtesmot, p_codcompw, v_qtysmot, stdenc(v_amtspot, p_codempid, global_v_chken),
              v_costcent, global_v_coduser, v_codsys);
            exception when dup_val_on_index then
              update totsumd
                set qtysmot   = v_qtysmot,
                    amtspot   = stdenc(v_amtspot, p_codempid, global_v_chken),
                    costcent  = v_costcent,
                    coduser   = global_v_coduser,
                    codsys    = v_codsys
              where codempid  = p_codempid
                and dteyrepay = p_year
                and dtemthpay = p_month
                and numperiod = p_numperiod
                and rtesmot   = v_rtesmot
                and codcompw  = p_codcompw;
            end;
        end if;
        update_totsum;
        insert_totsum (p_codempid, p_numperiod, p_month, p_year, v_costcent);
        if param_msg_error is not null then
          exit;
        end if;
      end if;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      commit;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure insert_totsum (v_codempid varchar2, v_numperiod varchar2, v_month varchar2, v_year varchar2, v_costcent varchar2 default null)as
    v_codcomp           temploy1.codcomp%type;
    v_typpayroll        temploy1.typpayroll%type;
    v_typemp            temploy1.typemp%type;
    v_amtothr           temploy3.amtothr%type;
    v_costcent2         tcenter.costcent%type;
  begin
    begin
      select codcomp, typpayroll, typemp
        into v_codcomp, v_typpayroll, v_typemp
        from temploy1
       where codempid = v_codempid;
    exception when no_data_found then
      v_codcomp    := null;
      v_typpayroll := null;
      v_typemp     := null;
    end;
    begin
      select amtothr into v_amtothr
        from temploy3
       where codempid = v_codempid;
    exception when no_data_found then
      v_amtothr := null;
    end;

--<< user20 Date: 11/09/2021  #6889
    if v_costcent is null then
        begin
          select costcent into v_costcent2
            from tcenter
           where codcomp = p_codcompw;
        exception when no_data_found then
          v_costcent2 := null;
        end;
    end if;
--<< user20 Date: 11/09/2021  #6889

    begin
      insert into totsum
      (codempid, dteyrepay, dtemthpay, numperiod,
       codcomp, typpayroll, typemp, qtysmot,
       amtottot, amtothr, codcreate, costcent)
      values
      (v_codempid, v_year, v_month, v_numperiod,
       v_codcomp, v_typpayroll, v_typemp, p_qtysmot,
--<< user20 Date: 11/09/2021  #6889       p_amtottot, v_amtothr, global_v_coduser, v_costcent);
       p_amtottot, v_amtothr, global_v_coduser, nvl(v_costcent, v_costcent2));
--<< user20 Date: 11/09/2021  #6889
    exception when dup_val_on_index then
      update totsum
         set codcomp    = v_codcomp,
             typpayroll = v_typpayroll,
             typemp     = v_typemp,
             qtysmot    = p_qtysmot,
             amtottot   = p_amtottot,
             amtothr    = v_amtothr,
--<< user20 Date: 11/09/2021  #6889             costcent   = v_costcent,
             costcent   = nvl(v_costcent, v_costcent2),
--<< user20 Date: 11/09/2021  #6889
             coduser    = global_v_coduser
       where codempid   = v_codempid
         and dteyrepay  = v_year
         and dtemthpay  = v_month
         and numperiod  = v_numperiod;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_totsum;

  procedure delete_totsumd (v_codempid  varchar2, v_numperiod varchar2, v_month varchar2, v_year varchar2, v_rtesmot varchar2, v_codcompw varchar2) as
    v_count number := 0;
  begin
    begin
      delete totsumd
      where codempid  = v_codempid
        and numperiod = v_numperiod
        and dtemthpay = v_month
        and dteyrepay = v_year
        and rtesmot   = nvl(v_rtesmot, rtesmot)
        and codcompw  = v_codcompw;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;

    begin
      select count(*)
        into v_count
        from totsumd
       where codempid  = v_codempid
         and numperiod = v_numperiod
         and dtemthpay = v_month
         and dteyrepay = v_year;
    exception when no_data_found then
      v_count := 0;
    end;
    if v_count = 0 then
      delete_totsum(v_codempid, v_numperiod, v_month, v_year);
    else
      update_totsum;
      insert_totsum (v_codempid, v_numperiod, v_month, v_year);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end delete_totsumd;

  procedure delete_totsum (v_codempid varchar2, v_numperiod varchar2, v_month varchar2, v_year varchar2) as
  begin
    delete totsum
     where codempid  = v_codempid
       and numperiod = v_numperiod
       and dtemthpay = v_month
       and dteyrepay = v_year;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end delete_totsum;

  procedure update_totsum as
  begin
    begin
      select sum(qtysmot), stdenc(sum(nvl(stddec(amtspot, codempid, global_v_chken), 0)), p_codempid, global_v_chken)
        into p_qtysmot, p_amtottot
        from totsumd
       where codempid  = p_codempid
         and numperiod = p_numperiod
         and dtemthpay = p_month
         and dteyrepay = p_year;
    exception when no_data_found then
      p_qtysmot  := null;
      p_amtottot := null;
    end;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end update_totsum;

  procedure gen_codcompw(json_str_output out clob) as
    obj_data            json_object_t := json_object_t();
    v_codcomp           temploy1.codcomp%type;
  begin
    begin
      select codcomp
        into v_codcomp
        from temploy1
        where codempid = p_codempid;
    exception when no_data_found then
      v_codcomp := null;
    end;

    obj_data.put('coderror', '200');
    obj_data.put('codcompw', to_char(v_codcomp));
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_codcompw;

  procedure get_codcompw(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_codcompw(json_str_output);
    else
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_codcompw;

end hrpy22e;

/

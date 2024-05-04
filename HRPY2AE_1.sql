--------------------------------------------------------
--  DDL for Package Body HRPY2AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY2AE" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := check_emp(get_emp); --web_service.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));

    p_costcent          := hcm_util.get_string_t(json_obj,'p_costcent');
    p_codpay            := hcm_util.get_string_t(json_obj,'p_codpay');
    p_amtpay            := to_number(hcm_util.get_string_t(json_obj,'p_amtpay'));
    p_flgcharge         := to_number(hcm_util.get_string_t(json_obj,'p_flgcharge'));


    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
    flgsecu boolean := false;
    v_staemp       varchar2(100 char);
  begin
    if nvl(p_dteyrepay,0) <= 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteyrepay');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    --
    if p_codempid is not null then
      begin
        select codempid into p_codempid
        from temploy1
        where codempid = p_codempid;
      exception when no_data_found then null;
       param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      end;

      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,global_v_zupdsal) then
         param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      end if;
    end if;

    end;

  procedure check_save_index(v_codcomp varchar2) is
    v_count number;
  begin
    begin
      select count(codcomp)
        into v_count
        from tcenter
       where codcomp = v_codcomp;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
      return;
    end;
  end;
--
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
    obj_data        json_object_t;
    obj_data2       json_object_t;
    obj_row         json_object_t;
    obj_row2        json_object_t;
    obj_result      json_object_t;
    v_flgsecu       boolean;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_secur         varchar2(4000 char);
    v_permission    boolean := false;
    v_exist         boolean := false;
    v_namimage      varchar2(1000 char);
    v_pathfile      varchar2(1000 char);
    v_folder        varchar2(1000 char);
    v_amtpay        varchar2(1000 char);

    v_codempid      varchar2(1000 char);
    v_codpay        varchar2(1000 char);
    v_flgcharge     varchar2(10 char);
    v_count         number;
    v_zupdsal       varchar2(1000 char);
    v_flg_exist     boolean := false;
    v_flg_3007      boolean := false;

     cursor c_tsincexp is
      select codempid, codpay, codcomp, stddec(amtpay, codempid, v_chken) amtpay, dteyrepay, dtemthpay, numperiod, numlvl
        from tsincexp
         where dteyrepay = p_dteyrepay
          and dtemthpay  = p_dtemthpay
          and numperiod  = p_numperiod
          and codempid   = nvl(p_codempid, codempid)
          and codcomp  like nvl(p_codcomp, codcomp)||'%'
      order by codempid,codpay;

    cursor c_tsinexct is
      select codcomp, costcent, stddec(amtpay, codempid, v_chken) amtpay
        from tsinexct
       where codempid   = v_codempid
        and dteyrepay = p_dteyrepay
        and dtemthpay = p_dtemthpay
        and numperiod = p_numperiod
        and codpay  = v_codpay
       order by codempid;

  begin
    obj_row           := json_object_t();

    for r1 in c_tsincexp loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tsincexp');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    for c1 in c_tsincexp loop
      v_amtpay := '';
     v_flgsecu := secur_main.secur1(c1.codcomp,c1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
     if v_flgsecu then
      v_permission := true;
      obj_data          := json_object_t();
      v_rcnt            := v_rcnt + 1;
      begin
        select flgcharge into v_flgcharge
        from tcostemp
         where dteyearst = c1.dteyrepay
          and dtemthst  = c1.dtemthpay
          and numprdst  = c1.numperiod
          and codempid   = c1.codempid
          and codcomp    = c1.codcomp
          and codpay     = c1.codpay ;
        exception when no_data_found then
        v_flgcharge := '2';
      end;

      if v_zupdsal = 'Y' then
          v_amtpay := c1.amtpay;
          v_flg_3007 := true;
          obj_data.put('coderror', '200');
          obj_data.put('codempid', c1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(c1.codempid, global_v_lang));
          obj_data.put('codpay', c1.codpay);
          obj_data.put('desc_codpay', get_tinexinf_name(c1.codpay, global_v_lang));
          obj_data.put('amtpay', v_amtpay);
          obj_data.put('flgcharge', v_flgcharge);
          v_pathfile := get_emp_img (c1.codempid);
          obj_data.put('image', v_pathfile);

          v_rcnt2           := 0;
          obj_row2          := json_object_t();
          v_codpay          := c1.codpay;
          v_codempid        := c1.codempid;

          begin
           select count(*) into v_count
            from tsinexct
           where codempid   = v_codempid
            and dteyrepay = p_dteyrepay
            and dtemthpay = p_dtemthpay
            and numperiod = p_numperiod
            and codpay  = v_codpay;
          exception when no_data_found then
            v_count := 0;
          end;
          if v_count > 0 then
            for c2 in c_tsinexct loop
              obj_data2           := json_object_t();
              v_rcnt2             := v_rcnt2 + 1;
              obj_data2.put('codcomp', c2.codcomp);
              obj_data2.put('costcent', c2.costcent);
              obj_data2.put('amtpayC', to_char(c2.amtpay));
              obj_data2.put('pccharge', to_char(c2.amtpay*100/v_amtpay));
              obj_row2.put(to_char(v_rcnt2 - 1), obj_data2);
            end loop;
          else
            obj_data2           := json_object_t();
            v_rcnt2             := v_rcnt2 + 1;
            obj_data2.put('codcomp', '');
            obj_data2.put('costcent', '');
            obj_data2.put('amtpayC', '');
            obj_data2.put('flgAdd', true);
            obj_row2.put(to_char(v_rcnt2 - 1), obj_data2);
          end if;
          obj_data.put('children', obj_row2);
          obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
     end if;
    end loop;

    if v_flg_3007 then
        json_str_output := obj_row.to_clob;
    else
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output   := get_response_message(null,param_msg_error, global_v_lang);
    end if;


  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

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

  procedure get_detail (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    null;
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail(json_str_output out clob) as
    obj_data     json_object_t;
    obj_row      json_object_t;
    v_dtestrt    date;
    v_dteend     date;
    v_row        number := 0;

  begin
    begin
      select dtestrt, dteend
        into v_dtestrt, v_dteend
        from tdtepay
       where numperiod = p_numperiod
         and dtemthpay = p_dtemthpay
         and dteyrepay = p_dteyrepay
         and codcompy  = hcm_util.get_codcomp_level(hcm_util.get_temploy_field(p_codempid, 'codcomp'), 1)
         and typpayroll = hcm_util.get_temploy_field(p_codempid, 'TYPPAYROLL');
    exception when no_data_found then
      v_dtestrt := null;
      v_dteend  := null;
    end;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dtestrt', to_char(v_dtestrt,'dd/mm/yyyy'));
    obj_data.put('dteend', to_char(v_dteend,'dd/mm/yyyy'));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;

  procedure get_detail1 (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    null;
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail1(json_str_output out clob) as
    obj_response    json_object_t;
    obj_detail      json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_dtestrt       date;
    v_dteend        date;
    v_row           number := 0;

    /*cursor c1 is
      select dtework,
             get_tcenter_name(t1.codcomp, global_v_lang) desc_codcomp,
             decode(global_v_lang, '101', get_label_name('HRPY2AEC1',101,'140')
                                 , '102', get_label_name('HRPY2AEC1',102,'140')
                                 , '103', get_label_name('HRPY2AEC1',103,'140')
                                 , '104', get_label_name('HRPY2AEC1',104,'140')
                                 , '105', get_label_name('HRPY2AEC1',105,'140'),
                                 get_label_name('HRPY2AEC1',101,'140')) description,
             t2.timstrtw timstrt,
             t2.timendw timend
        from twkchhr t1, tattence t2
       where t1.codempid = p_codempid
         and t1.codempid = t2.codempid
         and t1.dtestrt = t2.dtework
         and t1.dtestrt   between v_dtestrt and v_dteend
         and t1.codcompo is not null
         and t1.codcompo <> t2.codcomp
      union
      select dtework,
             get_tcenter_name(codcompw, global_v_lang) desc_codcomp,
             get_tlistval_name('TYPOT', typot, global_v_lang) description,
             timstrt,
             timend
        from tovrtime
       where codempid = p_codempid
        and dtework   between v_dtestrt and v_dteend
        and codcompw is not null;*/
    cursor c1 is
      select dtework,
             get_tcenter_name(nvl(codcompw,codcomp), global_v_lang) desc_codcomp,
             decode(global_v_lang, '101', get_label_name('HRPY2AEC1',101,'140')
                                 , '102', get_label_name('HRPY2AEC1',102,'140')
                                 , '103', get_label_name('HRPY2AEC1',103,'140')
                                 , '104', get_label_name('HRPY2AEC1',104,'140')
                                 , '105', get_label_name('HRPY2AEC1',105,'140'),
                                 get_label_name('HRPY2AEC1',101,'140')) description,
             timoutst timstrt,
             timouten timend,
             nvl(costcentw,costcent) costcent
        from v_tattence_cc
       where codempid = p_codempid
         and dtework  between v_dtestrt and v_dteend;
  begin
    begin
      select dtestrt, dteend
        into v_dtestrt, v_dteend
        from tdtepay
       where numperiod = p_numperiod
         and dtemthpay = p_dtemthpay
         and dteyrepay = p_dteyrepay
         and codcompy  = hcm_util.get_codcomp_level(hcm_util.get_temploy_field(p_codempid, 'codcomp'), 1)
         and typpayroll = hcm_util.get_temploy_field(p_codempid, 'TYPPAYROLL');
    exception when no_data_found then
      v_dtestrt := null;
      v_dteend  := null;
    end;

    obj_row := json_object_t();
    for r1 in c1 loop
      v_row   := v_row + 1 ;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtework', to_char(r1.dtework,'dd/mm/yyyy'));
      obj_data.put('desc_codcomp', r1.desc_codcomp);
      obj_data.put('hourtyp', r1.description);
      obj_data.put('costcent', r1.costcent);
      obj_data.put('timstrt', substr(r1.timstrt,1,2)||':'||substr(r1.timstrt,3,2));
      obj_data.put('timend', substr(r1.timend,1,2)||':'||substr(r1.timend,3,2));

      obj_row.put(to_char(v_row - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail1;

  procedure get_detail2 (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail2(json_str_output out clob) as
    obj_data     json_object_t;
    obj_row      json_object_t;
    v_row        number := 0;
    cursor c1 is
      select codpay, codcomp , costcent, pctchg
        from tcostemp
       where dteyearst = p_dteyrepay
        and dtemthst   = p_dtemthpay
        and numprdst   = p_numperiod
        and codempid   = p_codempid
        and codpay     = p_codpay ;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codpay', r1.codpay);
      obj_data.put('desc_codpay', get_tinexinf_name(r1.codpay, global_v_lang));
      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
      obj_data.put('costcent', r1.costcent);
      obj_data.put('pctchg', r1.pctchg);

      obj_row.put(to_char(v_row - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob();
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail2;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    json_obj             json_object_t :=json_object_t(json_str_input);
    json_row             json_object_t;
    json_children        json_object_t;
    obj_syncond          json_object_t;
    obj_children         json_object_t;
    param_json           json_object_t;
    v_flg_parent         varchar2(100 char);
    v_flg_child          varchar2(100 char);
    v_numseq             number;
    v_codpay             varchar2(100 char);
    v_codcomp            varchar2(100 char);
    v_codcompOld         varchar2(100 char);
    v_codempid           varchar2(100 char);
    v_costcent           varchar2(100 char);
    v_costcentold        varchar2(100 char);
    v_amtpayold          number;
    v_sum_amtpay         number;
    v_amtpay             number;
    v_amtpayP            number;

  begin
    initial_value(json_str_input);
    p_numperiod := to_number(hcm_util.get_string_t(json_obj, 'p_numperiod'));
    p_dtemthpay := to_number(hcm_util.get_string_t(json_obj, 'p_dtemthpay'));
    p_dteyrepay := to_number(hcm_util.get_string_t(json_obj, 'p_dteyrepay'));
    param_json  := hcm_util.get_json_t(json_obj,'param_json');

    for i in 0..param_json.get_size-1 loop
      v_sum_amtpay  := 0;
      json_row      := hcm_util.get_json_t(param_json,to_char(i));
      v_codpay      := hcm_util.get_string_t(json_row,'codpay');
      v_codempid    := hcm_util.get_string_t(json_row, 'codempid');
      v_amtpayP     := hcm_util.get_string_t(json_row, 'amtpay');

      obj_children          := hcm_util.get_json_t(json_row,'children');
      for j in 0..obj_children.get_size-1 loop
        json_children          := hcm_util.get_json_t(obj_children,to_char(j));
        v_flg_child            := hcm_util.get_string_t(json_children, 'flg');
        v_costcent             := hcm_util.get_string_t(json_children, 'costcent');
        v_amtpay               := to_number(hcm_util.get_string_t(json_children, 'amtpayC'));
        v_codcompOld           := hcm_util.get_string_t(json_children, 'codcompOld');
        v_codcomp              := hcm_util.get_string_t(json_children, 'codcomp');
        if v_codcomp is not null then
          check_save_index(v_codcomp);
          if param_msg_error is null then
            if v_flg_child = 'delete' then
              delete from tsinexct
                where codempid  = v_codempid
                  and codcomp   = v_codcompOld
                  and dteyrepay = p_dteyrepay
                  and dtemthpay = p_dtemthpay
                  and numperiod = p_numperiod
                  and codpay  = v_codpay;
            elsif v_flg_child = 'add' then
              begin
                delete from tsinexct
                  where codempid   = v_codempid
                    and codcomp   = v_codcomp
                    and dteyrepay = p_dteyrepay
                    and dtemthpay = p_dtemthpay
                    and numperiod = p_numperiod
                    and codpay  = v_codpay;
                insert into tsinexct
                            (codempid, codcomp ,dteyrepay, dtemthpay, numperiod, codpay, costcent, amtpay, dteupd, coduser)
                     values (v_codempid, v_codcomp, p_dteyrepay, p_dtemthpay, p_numperiod, v_codpay, v_costcent,
                            stdenc(v_amtpay, v_codempid, v_chken), sysdate, global_v_coduser);
              end;
            elsif v_flg_child = 'edit' then
              update tsinexct
                 set codcomp = v_codcomp,
                     costcent = v_costcent,
                     amtpay   = stdenc(v_amtpay, v_codempid, v_chken),
                     coduser = global_v_coduser,
                     dteupd  = sysdate
              where codempid   = v_codempid
                and codcomp   = v_codcompOld
                and dteyrepay = p_dteyrepay
                and dtemthpay = p_dtemthpay
                and numperiod = p_numperiod
                and codpay  = v_codpay;
            end if;
          else
            goto jump;
          end if;
        end if;
      end loop;

      begin
         select sum(stddec(amtpay, codempid, v_chken)) into v_sum_amtpay
           from tsinexct
          where codempid   = v_codempid
            and dteyrepay = p_dteyrepay
            and dtemthpay = p_dtemthpay
            and numperiod = p_numperiod
            and codpay  = v_codpay;
      end;
      --
      if v_sum_amtpay <> v_amtpayP then
        param_msg_error := get_error_msg_php('PY0027',global_v_lang);
        goto jump;
      end if;
    end loop;
    <<jump>>
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    else
      rollback;
    end if;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

END HRPY2AE;

/

--------------------------------------------------------
--  DDL for Package Body HRPY27E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY27E" as

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_date is
   v_dtestrt       number;
   v_dteend        number;
  begin
    v_dtestrt := lpad(substr(p_dteyrepay_st,1,4),4,0)||
                 lpad(substr(p_dtemthpay_st,1,2),2,0)||
                 lpad(substr(p_numperiod_st,1,2),2,0);

    v_dteend  := lpad(substr(nvl(p_dteyrepay_en,0),1,4),4,0)||
                 lpad(substr(nvl(p_dtemthpay_en,0),1,2),2,0)||
                 lpad(substr(nvl(p_numperiod_en,0),1,2),2,0);
    --
    if v_dtestrt > v_dteend and v_dteend <> 0 then
       if p_dteyrepay_st > p_dteyrepay_en then
          param_msg_error := get_error_msg_php('HR2022', global_v_lang);
          return;
       elsif p_dtemthpay_st > p_dtemthpay_en then
          param_msg_error := get_error_msg_php('HR2022', global_v_lang);
          return;
       else
          param_msg_error := get_error_msg_php('HR2022', global_v_lang);
          return;
       end if;
    end if;
  end;

  procedure check_index is
    v_typpayroll temploy1.typpayroll%type;
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
      p_codcomp := p_codcomp||'%';
    end if;
    --
    if p_typpayroll is not null then
      begin
        select codcodec
          into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodtypy');
        return;
      end;
    end if;
    --
    if p_codempid is not null then
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end check_index;

  procedure get_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data;

  procedure gen_data(json_str_output out clob) is
    obj_row              json_object_t;
    obj_data             json_object_t;
    v_rcnt               number;
    v_total              number := 0;
    v_codapp             varchar2(100 char) := 'HRPY27E';
    v_flg_secure         boolean := false;
    v_flg_exist          boolean := false;
    v_flg_permission     boolean := false;
    v_flgtrnbank         varchar2(1 char);
    v_yremthper          varchar2(8 char);

    cursor c1 is
      select a.codempid,a.dteyrepay_st,a.dtemthpay_st,a.numperiod_st,
             a.dteyrepay_en,a.dtemthpay_en,a.numperiod_en,a.flgpaymt,a.remark
        from ttyppymt a, temploy1 b
       where a.codempid = b.codempid
         and a.codempid in (select codempid from temploy1
                             where (p_codcomp is null or codcomp like nvl(p_codcomp,codcomp))
                               and (p_typpayroll is null or typpayroll like nvl(p_typpayroll,typpayroll))
                               and staemp <> 0)
         and a.codempid = b.codempid(+)
       order by a.codempid;
  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    --
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
--    if not v_flg_exist then
--      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttyppymt');
--      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--      return;
--    end if;
    --
    for r1 in c1 loop
      v_flg_secure := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;

        obj_data         := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', r1.codempid||'-'||get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('dteyrepay_st', r1.dteyrepay_st);
        obj_data.put('dtemthpay_st', r1.dtemthpay_st);
        obj_data.put('numperiod_st', r1.numperiod_st);
        obj_data.put('dteyrepay_en', r1.dteyrepay_en);
        obj_data.put('dtemthpay_en', r1.dtemthpay_en);
        obj_data.put('numperiod_en', r1.numperiod_en);
        obj_data.put('flgpaymt', r1.flgpaymt);
        obj_data.put('remark', r1.remark);
        -- description data--
        obj_data.put('desc_dtemthpay_st', get_tlistval_name('NAMMTHFUL',r1.dtemthpay_st,global_v_lang));
        obj_data.put('desc_dtemthpay_en', get_tlistval_name('NAMMTHFUL',r1.dtemthpay_en,global_v_lang));
        obj_data.put('desc_flgpaymt', get_tlistval_name('TYPEPAYINC',r1.flgpaymt,global_v_lang));
        /*
        begin
          select nvl(flgtrnbank,'N')
            into v_flgtrnbank
            from ttaxcur
           where codempid = r1.codempid
             and rownum = 1
             and dteyrepay||lpad(dtemthpay,2,'0')||numperiod = (select max(dteyrepay||lpad(dtemthpay,2,'0')||numperiod)
                                                                  from ttaxcur
                                                                 where codempid   = r1.codempid
                                                                   and dteyrepay||lpad(dtemthpay,2,'0')||numperiod >= (r1.dteyrepay_en||lpad(r1.dtemthpay_en,2,'0')||r1.numperiod_en));
        exception when no_data_found then
          v_flgtrnbank := 'N';
        end;
        */
        begin
            select max(DTEYREPAY||lpad(DTEMTHPAY,2,0)||lpad(NUMPERIOD,2,0))
            into v_yremthper
            from ttaxcur
            where codempid = r1.codempid;
            exception when others then
            v_yremthper := '00010101';
        end;

        if to_number(r1.dteyrepay_st||lpad(r1.dtemthpay_st,2,0)||lpad(r1.numperiod_st,2,0)) < to_number(v_yremthper) then
           v_flgtrnbank := 'Y';
        else
           v_flgtrnbank := 'N';
        end if;
        obj_data.put('flgtrnbank', v_flgtrnbank);
        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt           := v_rcnt + 1;
      end if;
    end loop;
    --
    if not v_flg_permission and v_flg_exist then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    obj_param_json  json_object_t;
    param_json_row  json_object_t;
    v_flg           varchar2(100 char);
    v_staemp        varchar2(100 char);
    v_chk           varchar2(1 char); --<<user25 Date:26/08/2021 3.PY Module  #6165

  begin
    initial_value(json_str_input);
    check_index;
    obj_param_json        := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
    if param_msg_error is null then
      for i in 0..obj_param_json.get_size-1 loop
        param_json_row    := hcm_util.get_json_t(obj_param_json,to_char(i));
        --
        p_codempid        := hcm_util.get_string_t(param_json_row,'codempid');
        p_dteyrepay_st    := to_number(hcm_util.get_string_t(param_json_row,'dteyrepay_st'));
        p_dtemthpay_st    := to_number(hcm_util.get_string_t(param_json_row,'dtemthpay_st'));
        p_numperiod_st    := to_number(hcm_util.get_string_t(param_json_row,'numperiod_st'));
        p_dteyrepay_en    := to_number(hcm_util.get_string_t(param_json_row,'dteyrepay_en'));
        p_dtemthpay_en    := to_number(hcm_util.get_string_t(param_json_row,'dtemthpay_en'));
        p_numperiod_en    := to_number(hcm_util.get_string_t(param_json_row,'numperiod_en'));
        p_flgpaymt        := hcm_util.get_string_t(param_json_row,'flgpaymt');
        p_remark          := hcm_util.get_string_t(param_json_row,'remark');
        v_flg             := hcm_util.get_string_t(param_json_row,'flg');
        --
        if p_codempid is not null then
          begin
            select codempid, staemp
              into p_codempid, v_staemp
              from temploy1
             where codempid = p_codempid;
             --
             if nvl(v_staemp,0) = 0 then
               param_msg_error := get_error_msg_php('HR2102',global_v_lang);
             end if;
             --
          exception when no_data_found then null;
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
          end;
          --
          if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          end if;
        end if;

--<<user25 Date:26/08/2021 3.PY Module  #6165
      begin
      select 1
            into v_chk
            from ttyppymt
            where codempid   = p_codempid
            and (dteyrepay_st <>  p_dteyrepay_st  or dtemthpay_st <>  p_dtemthpay_st or numperiod_st <>  p_numperiod_st)
            and (  dteyrepay_st||lpad(dtemthpay_st,2,0)||lpad(numperiod_st,2,0)         between p_dteyrepay_st||lpad(p_dtemthpay_st,2,0)||lpad(p_numperiod_st,2,0)
                                                                                            and p_dteyrepay_en||lpad(p_dtemthpay_en,2,0)||lpad(p_numperiod_en,2,0)
                or dteyrepay_en||lpad(dtemthpay_en,2,0)||lpad(numperiod_en,2,0)         between p_dteyrepay_st||lpad(p_dtemthpay_st,2,0)||lpad(p_numperiod_st,2,0)
                                                                                            and p_dteyrepay_en||lpad(p_dtemthpay_en,2,0)||lpad(p_numperiod_en,2,0)
                or p_dteyrepay_st||lpad(p_dtemthpay_st,2,0)||lpad(p_numperiod_st,2,0)   between dteyrepay_st||lpad(dtemthpay_st,2,0)||lpad(numperiod_st,2,0)
                                                                                            and dteyrepay_en||lpad(dtemthpay_en,2,0)||lpad(numperiod_en,2,0)
                or p_dteyrepay_en||lpad(p_dtemthpay_en,2,0)||lpad(p_numperiod_en,2,0)   between dteyrepay_st||lpad(dtemthpay_st,2,0)||lpad(numperiod_st,2,0)
                                                                                            and dteyrepay_en||lpad(dtemthpay_en,2,0)||lpad(numperiod_en,2,0)
            )
            and rownum = 1;
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TTYPPYMT');
        exception when no_data_found then null;
      end;
-->>user25 Date:26/08/2021 3.PY Module  #6165

        --
        check_date;
        if param_msg_error is null then
          if v_flg = 'delete' then
            delete from ttyppymt where codempid = p_codempid
            --<<user25 Date:26/08/2021 3.PY Module  #6167
            and dteyrepay_st =  p_dteyrepay_st
            and dtemthpay_st =  p_dtemthpay_st
            and numperiod_st =  p_numperiod_st
            -->>user25 Date:26/08/2021 3.PY Module  #6167
            ;
          else
            begin
              insert into ttyppymt(codempid,dteyrepay_st,dtemthpay_st,numperiod_st,dteyrepay_en,
                                   dtemthpay_en,numperiod_en,flgpaymt,remark,coduser,codcreate)
                            values(p_codempid,p_dteyrepay_st,p_dtemthpay_st,p_numperiod_st,p_dteyrepay_en,
                                   p_dtemthpay_en,p_numperiod_en,p_flgpaymt,p_remark,global_v_coduser,global_v_coduser);
            exception when dup_val_on_index then
       --<<user25 Date:26/08/2021 3.PY Module  #6167
            /*
                            update  ttyppymt 
                            set   dteyrepay_st = p_dteyrepay_st,
                                  dtemthpay_st = p_dtemthpay_st,
                                  numperiod_st = p_numperiod_st,
                                  dteyrepay_en = p_dteyrepay_en,
                                  dtemthpay_en = p_dtemthpay_en,
                                  numperiod_en = p_numperiod_en,
                                  flgpaymt     = p_flgpaymt,
                                  remark       = p_remark,
                                  coduser      = global_v_coduser
                            where codempid     = p_codempid
            */
                      update ttyppymt 
                      set     dteyrepay_en = p_dteyrepay_en,
                              dtemthpay_en = p_dtemthpay_en,
                              numperiod_en = p_numperiod_en,
                              flgpaymt     = p_flgpaymt,
                              remark       = p_remark,
                              coduser      = global_v_coduser
                        where codempid     = p_codempid
                          and dteyrepay_st =  p_dteyrepay_st
                            and dtemthpay_st =  p_dtemthpay_st
                            and numperiod_st =  p_numperiod_st;
       -->>user25 Date:26/08/2021 3.PY Module  #6167
            end;
          end if;
        end if;
      end loop;
      --
      if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      end if;
    end if;
     json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

end HRPY27E;

/

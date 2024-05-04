--------------------------------------------------------
--  DDL for Package Body HRPY5AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5AE" as
  -->>30/07/2020<<--
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtemthpay         := hcm_util.get_string_t(json_obj,'p_dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj,'p_dteyrepay');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure check_index is
    v_error   varchar2(1000 char);
  begin
    if p_codcomp is null and p_codempid_query is null then
      param_msg_error   := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_codcomp is not null then
      v_error   := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;
    end if;

    if p_codempid_query is not null then
      v_error   := hcm_secur.secur_codempid(global_v_coduser,global_v_lang,p_codempid_query);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;
    end if;

--    if p_status is null then
--      param_msg_error   := get_error_msg_php('HR2045', global_v_lang);
--      return;
--    end if;
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_rcnt        number  := 0;

    v_secur       boolean := false;
    v_zupdsal     varchar2(1);
    cursor c1 is
      select codempid,codcomp,typpayroll,
             stddec(amtloanstu,codempid,global_v_chken) amtloanstu,
             stddec(amtloanstuf,codempid,global_v_chken) amtloanstuf,
             status,codremark,
             dtemthpay,
             dteyrepay
        from tloanslf
       where codempid = nvl(p_codempid_query,codempid)
         and codcomp like p_codcomp||'%'
         and dtemthpay = p_dtemthpay
         and dteyrepay = p_dteyrepay
      order by codempid;
  begin
    obj_row     := json_object_t();
    for r1 in c1 loop
      v_secur   := secur_main.secur2(r1.codempid, global_v_coduser,
                                     global_v_zminlvl, global_v_zwrklvl, v_zupdsal,
                                     global_v_numlvlsalst, global_v_numlvlsalst);
      if v_secur then
        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codempid',r1.codempid);
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('typpayroll',r1.typpayroll);
        obj_data.put('desc_typpayroll',get_tcodec_name('tcodtypy', r1.typpayroll, global_v_lang));
--        if v_zupdsal = 'Y' then
        obj_data.put('amtloanstu',r1.amtloanstu);
        obj_data.put('amtloanstuf',r1.amtloanstuf);
        obj_data.put('dtemthpay',r1.dtemthpay);
        obj_data.put('dteyrepay',r1.dteyrepay);
--        end if;
        obj_data.put('status',r1.status);
--<<user20 Date : 12/10/2022 #8418
        obj_data.put('codremark',r1.codremark);
--<<user20 Date : 12/10/2022 #8418
        obj_data.put('desc_status',get_tlistval_name('LOANSTUDY',r1.status,global_v_lang));
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt    := v_rcnt + 1;
      end if;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_index(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure insert_tloanslf(t_tloanslf tloanslf%rowtype) is
  begin
    begin
      insert into tloanslf (codempid, dteyrepay, dtemthpay, codcomp, typpayroll,
                            amtloanstu, amtloanstuf, status,
--<<user20 Date : 12/10/2022 #8418
                            codremark,
--<<user20 Date : 12/10/2022 #8418
                            dtecreate, codcreate, dteupd, coduser)
      values (t_tloanslf.codempid, t_tloanslf.dteyrepay, t_tloanslf.dtemthpay, t_tloanslf.codcomp, t_tloanslf.typpayroll,
              t_tloanslf.amtloanstu, t_tloanslf.amtloanstuf, t_tloanslf.status,
--<<user20 Date : 12/10/2022 #8418
              t_tloanslf.codremark,
--<<user20 Date : 12/10/2022 #8418
              sysdate, global_v_coduser, sysdate, global_v_coduser);
    exception when dup_val_on_index then
      update tloanslf
         set codcomp        = t_tloanslf.codcomp,
             typpayroll     = t_tloanslf.typpayroll,
             amtloanstu     = t_tloanslf.amtloanstu,
             amtloanstuf    = t_tloanslf.amtloanstuf,
             status         = t_tloanslf.status,
--<<user20 Date : 12/10/2022 #8418
             codremark      = t_tloanslf.codremark,
--<<user20 Date : 12/10/2022 #8418
             dteupd         = sysdate,
             coduser        = global_v_coduser
       where codempid       = t_tloanslf.codempid
         and dteyrepay      = t_tloanslf.dteyrepay
         and dtemthpay      = t_tloanslf.dtemthpay;
    end;
  end;
  --
  procedure save_data(json_str_input in clob,json_str_output out clob) is
    v_json_input    json_object_t := json_object_t(json_str_input);
    v_json_comp     json_object_t;
    v_json_comp_row json_object_t;

    t_tloanslf      tloanslf%rowtype;
    v_amtloanstu    number;
    v_amtloanstuf   number;
    v_periodded     varchar2(1000 char);
    v_staemp        temploy1.staemp%type;

    v_secur         boolean := false;
    v_flg           varchar2(100);
    v_chk           varchar2(1);
    v_zupdsal       varchar2(1);
  begin
    initial_value(json_str_input);
    v_json_comp                     := hcm_util.get_json_t(v_json_input,'params_json');
    for i in 0..(v_json_comp.get_size - 1) loop
      v_json_comp_row               := hcm_util.get_json_t(v_json_comp,to_char(i));
      t_tloanslf.codempid           := hcm_util.get_string_t(v_json_comp_row,'codempid');
      t_tloanslf.dteyrepay          := hcm_util.get_string_t(v_json_comp_row,'dteyrepay');
      t_tloanslf.dtemthpay          := hcm_util.get_string_t(v_json_comp_row,'dtemthpay');
      t_tloanslf.codcomp            := hcm_util.get_string_t(v_json_comp_row,'codcomp');
      t_tloanslf.typpayroll         := hcm_util.get_string_t(v_json_comp_row,'typpayroll');
      v_amtloanstu                  := to_number(hcm_util.get_string_t(v_json_comp_row,'amtloanstu'));
      v_amtloanstuf                 := to_number(hcm_util.get_string_t(v_json_comp_row,'amtloanstuf'));
      t_tloanslf.status             := hcm_util.get_string_t(v_json_comp_row,'status');
--<<user20 Date : 12/10/2022 #8418
      t_tloanslf.codremark          := hcm_util.get_string_t(v_json_comp_row,'codremark');
--<<user20 Date : 12/10/2022 #8418

/*
if t_tloanslf.codremark is null then
    t_tloanslf.codremark := nvl( t_tloanslf.codremark ,'1');
end if;
-- */
      v_flg                         := hcm_util.get_string_t(v_json_comp_row,'flg');
      t_tloanslf.amtloanstu         := stdenc(v_amtloanstu,t_tloanslf.codempid,global_v_chken);
      t_tloanslf.amtloanstuf        := stdenc(v_amtloanstuf,t_tloanslf.codempid,global_v_chken);

      if v_flg in ('add', 'edit') then
        begin
          select staemp
            into v_staemp
            from temploy1
           where codempid     = t_tloanslf.codempid;
        exception when no_data_found then
          param_msg_error   := get_error_msg_php('HR2010', global_v_lang,'temploy1');
          exit;
        end;
        --
        if v_staemp = '9' then
          param_msg_error   := get_error_msg_php('HR2101', global_v_lang);
          exit;
        elsif v_staemp = '0' then
          param_msg_error   := get_error_msg_php('HR2102', global_v_lang);
          exit;
        end if;
        --
        if t_tloanslf.codcomp not like p_codcomp||'%' then
          param_msg_error   := get_error_msg_php('HR2104', global_v_lang);
          exit;
        end if;
        --
        if v_flg = 'add' then
          begin
            select 'Y'
              into v_chk
              from tloanslf
             where codempid = t_tloanslf.codempid
               and dteyrepay = t_tloanslf.dteyrepay
               and dtemthpay = t_tloanslf.dtemthpay;
            param_msg_error := get_error_msg_php('HR2005', global_v_lang);
            exit;
          exception when no_data_found then null; end;
        end if;
        --
        v_secur   := secur_main.secur2(t_tloanslf.codempid, global_v_coduser,
                                       global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
        if v_secur then
          insert_tloanslf(t_tloanslf);
        else
          param_msg_error   := get_error_msg_php('HR3007', global_v_lang);
          exit;
        end if;
      elsif v_flg = 'delete' then
        delete tloanslf
         where codempid = t_tloanslf.codempid
           and dteyrepay = t_tloanslf.dteyrepay
           and dtemthpay = t_tloanslf.dtemthpay;
      end if;
    end loop;

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
    else
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  function validate_column return varchar2 is
    v_flgsecu   boolean   := false;
    v_staemp    temploy1.staemp%type;
    v_remark    varchar2(4000);
    v_zupdsal   varchar2(1);
    v_error			boolean;
    v_check     varchar2(1);
    v_max       number;
  begin
    -- v_text(1) = codempid
    if v_text(1) is null then
      v_remark	:= v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(1)||')';
    else
      v_error := hcm_validate.check_length(v_text(1),'temploy1','codempid',v_max);
      if v_error then
        v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(1)||' Max: '||v_max||')';
      else
        begin
          select staemp
            into v_staemp
            from temploy1
           where codempid   = v_text(1);

          if v_staemp = '9' then
            v_remark	:= v_remark||','||get_errorm_name('HR2101',global_v_lang);
          elsif v_staemp = '0' then
            v_remark	:= v_remark||','||get_errorm_name('HR2102',global_v_lang);
          end if;

          v_flgsecu := secur_main.secur2(v_text(1),global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
          if not v_flgsecu then
            v_remark	:= v_remark||','||get_errorm_name('HR3007',global_v_lang);
          end if;

--          begin
--            select 'Y'
--              into v_check
--              from tloanstudy
--             where codempid   = v_text(1);
--            v_remark	:= v_remark||','||get_errorm_name('HR2005',global_v_lang);
--          exception when no_data_found then
--            null;
--          end;
        exception when no_data_found then
          v_remark	:= v_remark||','||get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
        end;
      end if;
    end if;

    -- v_text(2) = dteyrepay
    if v_text(2) is null then
      v_remark	:= v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(2)||')';
    else
      v_error := hcm_validate.check_number(v_text(2));
      if v_error then
        v_remark := v_remark||','||get_errorm_name('HR2816',global_v_lang)||' ('||v_head(2)||' - '||v_text(2)||')';
      else
        v_error   := hcm_validate.check_length(v_text(2),'TLOANSLF','DTEYREPAY',v_max);
        if v_error then
          v_remark := v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(2)||' Max: '||v_max||')';
        end if;
      end if;
    end if;

    -- v_text(3) = dtemthpay
    if v_text(3) is null then
      v_remark	:= v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(3)||')';
    else
      v_error := hcm_validate.check_number(v_text(3));
      if v_error then
        v_remark := v_remark||','||get_errorm_name('HR2816',global_v_lang)||' ('||v_head(3)||' - '||v_text(3)||')';
      else
        v_error   := hcm_validate.check_length(v_text(3),'TLOANSLF','DTEMTHPAY',v_max);
        if v_error then
          v_remark := v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(3)||' Max: '||v_max||')';
        else
          if to_number(v_text(3)) > 12 then
            v_error  := true;
            v_remark := v_remark||','||get_errorm_name('HR2057',global_v_lang)||' ('||v_head(3)||' - '||v_text(3)||')';
          end if;
        end if;
      end if;
    end if;

    -- v_text(4) = amtloanstu
    if v_text(4) is not null then
      v_error := hcm_validate.check_number(v_text(4));
      if v_error then
        v_remark := v_remark||','||get_errorm_name('HR2816',global_v_lang)||' ('||v_head(4)||' - '||v_text(4)||')';
      else
        if to_number(v_text(4)) > 99999999.99 then
          v_remark := v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(4)||' Max: 99999999.99)';
        end if;
      end if;
    end if;
    -- v_text(5) = amtloanstuf
    if v_text(5) is not null then
      v_error := hcm_validate.check_number(v_text(5));
      if v_error then
        v_remark := v_remark||','||get_errorm_name('HR2816',global_v_lang)||' ('||v_head(5)||' - '||v_text(5)||')';
      else
        if to_number(v_text(5)) > 99999999.99 then
          v_remark := v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(5)||' Max: 99999999.99)';
        end if;
      end if;
    end if;

    if v_text(4) is null and v_text(5) is null then
      v_remark	:= v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(4)||','||v_head(5)||')';
    end if;
    -- v_text(6) = status
    if v_text(6) is null then
      v_remark	:= v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(6)||')';
    else
      if upper(v_text(6)) not in ('P','C') then
        v_remark := v_remark||','||v_head(4)||' '||get_errorm_name('HR2057',global_v_lang)||' (''P'',''C'')';
      end if;
    end if;

--<<user20 Date : 12/10/2022 #8418
    if v_text(7) is not null then   -- v_text(7) = codremark
          begin
            select 'Y' into v_check
              from tlistval
             where codapp = 'REMLOANSLF'
               and list_value = v_text(7)
               and rownum = 1;
          exception when no_data_found then
            v_remark	:= v_remark||','||v_head(7)||' '||get_errorm_name('HR2010',global_v_lang)||' (TLISTVAL)';
          end;
    else null;
    end if;
--<<user20 Date : 12/10/2022 #8418

    return substr(v_remark,2);
  end;
  --
  procedure generate_column(json_str_input in clob, json_str_output out clob) is
    param_import      json_object_t;
    param_import_row  json_object_t;
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;
    v_err_msg         varchar2(4000);
    v_codcomp         tcenter.codcomp%type;
    v_typpayroll      temploy1.typpayroll%type;
  begin
    -- Label table
    v_head(1)   := get_label_name('HRPY5AEP1',global_v_lang, 100);
    v_head(2)   := get_label_name('HRPY5AEP1',global_v_lang, 160);
    v_head(3)   := get_label_name('HRPY5AEP1',global_v_lang, 170);
    v_head(4)   := get_label_name('HRPY5AEP1',global_v_lang, 120);
    v_head(5)   := get_label_name('HRPY5AEP1',global_v_lang, 130);
    v_head(6)   := get_label_name('HRPY5AEC1',global_v_lang, 120);
--<<user20 Date : 12/10/2022 #8418
    v_head(7)   := get_label_name('HRPY5AEP1',global_v_lang, 140);
--<<user20 Date : 12/10/2022 #8418
    --
    -- Column Name
    v_column(1)   := 'codempid';
    v_column(2)   := 'dteyrepay';
    v_column(3)   := 'dtemthpay';
    v_column(4)   := 'amtloanstu';
    v_column(5)   := 'amtloanstuf';
    v_column(6)   := 'status';
--<<user20 Date : 12/10/2022 #8418
    v_column(7)   := 'codremark';
  --<<user20 Date : 12/10/2022 #8418
    --
    param_import  := hcm_util.get_json_t(json_object_t(json_str_input),'params_json');
    obj_row       := json_object_t();
    for i in 0..(param_import.get_size - 1) loop
      obj_data      := json_object_t();
      obj_data.put('coderror','200');
      param_import_row    := hcm_util.get_json_t(param_import,to_char(i));
      for k in 1..v_column.count loop
        v_text(k)         := hcm_util.get_string_t(param_import_row,v_column(k));

/*--
if k = 7 then
v_text(k) := nvl(v_text(k),'1');
end if;
-- */
        obj_data.put(v_column(k),v_text(k));
      end loop;
      v_err_msg     := validate_column;
      if v_err_msg is not null then
        obj_data.put('statusicon','<span class="glyphicon glyphicon-remove _text-red" aria-hidden="true"></span>');
        obj_data.put('flgerror','Y');
        obj_data.put('flg','');
        obj_data.put('descerror',v_err_msg);
      else
        begin
          select codcomp, typpayroll
            into v_codcomp, v_typpayroll
            from temploy1
           where codempid   = v_text(1);
        exception when no_data_found then
          null;
        end;
        obj_data.put('statusicon','<span class="glyphicon glyphicon-ok _text-green" aria-hidden="true"></span>');
        obj_data.put('flgerror','N');
        obj_data.put('flg','edit');
        obj_data.put('codcomp',v_codcomp);
        obj_data.put('typpayroll',v_typpayroll);
        obj_data.put('desc_codempid',get_temploy_name(v_text(1),global_v_lang));
        obj_data.put('descerror','');
      end if;

      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure submit_import (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    generate_column(json_str_input,json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure process_import (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    save_data(json_str_input, json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

--------------------------------------------------------
--  DDL for Package Body HRAL96E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL96E" is
-- last update : 08/08/2020
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codaward          := hcm_util.get_string_t(json_obj,'p_codaward');
    p_qtyoldacc         := to_number(hcm_util.get_string_t(json_obj,'p_qtyoldacc'));
    p_qtyaccaw          := to_number(hcm_util.get_string_t(json_obj,'p_qtyaccaw'));

    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));

    p_dtecalc           := to_date(hcm_util.get_string_t(json_obj,'p_dtecalc'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
    flgsecu boolean := false;
  begin
    --
    if p_codaward is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codaward');
      return;
    end if;
    --
    begin
      select codcodec into p_codaward
      from   tcodawrd
      where  codcodec = p_codaward;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codaward');
      return;
    end;
    --
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
          return;
      end if;
    end if;
  end;

  procedure check_detail is
    flgsecu boolean := false;
  begin
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
      return;
    end if;
    --
    if p_codaward is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codaward');
      return;
    end if;
    --
    begin
      select codcodec into p_codaward
        from   tcodawrd
       where  codcodec = p_codaward;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODAWRD');
      return;
    end;
    --
    begin
      select codempid into p_codempid
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
      return;
    end;
    --
    if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal) then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;
  end;

  procedure check_save_detail is
  begin
    if p_codaward is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codaward');
      return;
    else
      begin
        select codcodec
          into p_codaward
          from tcodawrd
         where codcodec = p_codaward;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODAWRD');
        return;
      end;
    end if;
--    if p_qtyaccaw is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'qtyaccaw');
--      return;
--    end if;
--    if p_dtecalc is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtecalc');
--      return;
--    end if;
--    if p_qtyaccaw < 0 then
--      param_msg_error := get_error_msg_php('AL0006',global_v_lang,'qtyaccaw < 0');
--      return;
--    end if;
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
      return;
    else
      begin
        select codempid into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure check_save_detail_table (p_flg varchar2) is
  v_code varchar2(20 char);
  begin
    if p_flg = 'I' then
      if nvl(p_dteyrepay,0) <= 0 then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteyrepay');
        return;
      elsif p_dtemthpay is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtemthpay');
        return;
      elsif p_numperiod is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numperiod');
        return;
--      elsif p_qtyoldacc is null then
--        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'qtyoldacc');
--        return;
--      elsif p_qtyaccaw is null then
--        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'qtyaccaw');
--        return;
      end if;
      --
--      if p_qtyoldacc is null then
--        param_msg_error := get_error_msg_php('AL0006',global_v_lang,'qtyoldacc');
--        return;
--      elsif p_qtyaccaw < 0 then
--        param_msg_error := get_error_msg_php('AL0006',global_v_lang,'qtyaccaw');
--        return;
--      end if;
      --
      begin
        select codempid into v_code
          from tempawrd2
         where codaward   = p_codaward
           and codempid   = p_codempid
           and dteyrepay  = (p_dteyrepay - global_v_zyear)
           and dtemthpay  = p_dtemthpay
           and numperiod  = p_numperiod;
        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'dteyrepay');
        return;
      exception when no_data_found then null;
      end;

       if p_dtecalc is null then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tpriodal');
        return;
      end if;

    elsif p_flg = 'U' then
      if p_qtyaccaw is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'qtyaccaw');
        return;
      end if;
      --
      if p_qtyaccaw < 0 then
        param_msg_error := get_error_msg_php('AL0006',global_v_lang,'qtyaccaw');
        return;
      end if;

    end if;
  end;

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
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_flgsecu       boolean := false;
    v_rcnt          number  := 0;
    v_secur         varchar2(4000 char);
    v_permission    boolean := false;
    v_exist         boolean := false;
    v_namimage      varchar2(1000 char);
    v_pathfile      varchar2(1000 char);
    v_folder        varchar2(1000 char);

    cursor c1 is
      select a.codempid, a.codaward , a.qtyaccaw, a.dtecalc, a.qtyoldacc
        from tempawrd a, temploy1 b
       where a.codempid = b.codempid
         and a.codaward = p_codaward
         and b.codcomp  like p_codcomp||'%'
         and b.staemp in ('1','3')
      order by codempid;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    obj_result := json_object_t();

    begin
      select folder
        into v_folder
        from tfolderd
       where codapp = 'HRPMC2E';
    exception when no_data_found then
      v_folder := null;
    end;
    --
    for r1 in c1 loop
      v_flgsecu := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
      if v_flgsecu then
        v_permission := true;
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('rcnt', to_char(v_rcnt));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('codaward', r1.codaward);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('qtyaccaw', r1.qtyaccaw);
        obj_data.put('dtecalc', to_char(r1.dtecalc,'dd/mm/yyyy'));
        v_pathfile := get_emp_img (r1.codempid);
        obj_data.put('image', v_pathfile);
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
    --
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_detail;
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
    obj_row      json_object_t;
    v_codempid   varchar2(1000 char);
    v_codaward   varchar2(1000 char);
    v_qtyaccaw   number;
    v_dtecalc    date;
    v_coduser    tempawrd.coduser%type;
    v_dteupd     tempawrd.dteupd%type;
    v_userid     tempawrd.codempid%type;
  begin
    begin
      select codempid, codaward , qtyaccaw, dtecalc, coduser, dteupd
        into v_codempid, v_codaward , v_qtyaccaw, v_dtecalc, v_coduser, v_dteupd
        from tempawrd
       where codempid = p_codempid
         and codaward = p_codaward;
    exception when no_data_found then
      v_codempid  := p_codempid;
      v_codaward  := p_codaward;
    end;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codempid', v_codempid);
    obj_row.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
    obj_row.put('codaward', v_codaward);
    obj_row.put('qtyaccaw', v_qtyaccaw);
    obj_row.put('dtecalc', to_char(v_dtecalc,'dd/mm/yyyy'));
    obj_row.put('desc_codaward', get_tcodec_name('tcodawrd',v_codaward, global_v_lang));
    obj_row.put('dteupd',to_char(v_dteupd, 'dd/mm/yyyy'));
    obj_row.put('coduser',v_coduser || '-' || get_temploy_name(get_codempid(v_coduser),global_v_lang));
    obj_row.put('desc_coduser',(get_temploy_name(get_codempid(v_coduser),global_v_lang)));
    obj_row.put('userid',(get_codempid(v_coduser)));

    --
    if isInsertReport then
      insert_ttemprpt(obj_row);
    end if;
    --

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_att_award(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_att_award(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_att_award(json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;

    cursor c1 is
      select dteyrepay, dtemthpay, numperiod, qtyoldacc, qtyaccaw, dtecalc
       from tempawrd2
      where codempid = p_codempid
        and codaward = p_codaward
      order by dteyrepay desc,dtemthpay desc,numperiod desc;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    obj_result := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('dteyrepay', r1.dteyrepay);
      obj_data.put('dtemthpay', r1.dtemthpay);
      obj_data.put('numperiod', r1.numperiod);
      obj_data.put('qtyoldacc', r1.qtyoldacc);
      obj_data.put('qtyaccaw', r1.qtyaccaw);
      obj_data.put('numseq', v_rcnt);
      obj_data.put('dtecalc', to_char(r1.dtecalc,'dd/mm/yyyy')); -- wait f
      --
      if isInsertReport then
        insert_ttemprpt(obj_data);
      end if;
      --

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_index_rows      json_object_t;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..json_index_rows.get_size-1 loop
        p_index_rows      := hcm_util.get_json_t(json_index_rows, to_char(i));
        p_codempid        := hcm_util.get_string_t(p_index_rows, 'codempid');
        p_codaward        := hcm_util.get_string_t(p_index_rows, 'codaward');
        p_codapp := 'HRAL96E';
        gen_detail(json_output);
        p_codapp := 'HRAL96E1';
        gen_att_award(json_output);
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
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_dtecalc           date;
    v_dtecalc_          varchar2(100 char) := '';

    v_codaward    	  	varchar2(1000 char) := '';
    v_desc_codaward    	varchar2(1000 char) := '';
    v_desc_codempid    	varchar2(1000 char) := '';
    v_qtyaccaw    	  	varchar2(1000 char) := '';
    v_dteyrepay    	  	varchar2(1000 char) := '';
    v_dtemthpay    	  	varchar2(1000 char) := '';
    v_numperiod    	  	varchar2(1000 char) := '';
    v_qtyoldacc    	  	varchar2(1000 char) := '';
    v_numseq_    	  		varchar2(1000 char) := '';
  begin
    v_year      := hcm_appsettings.get_additional_year;
    v_codaward      			:= nvl(hcm_util.get_string_t(obj_data, 'codaward'), '');
    v_desc_codaward      	:= nvl(hcm_util.get_string_t(obj_data, 'desc_codaward'), '');
    v_desc_codempid      	:= nvl(hcm_util.get_string_t(obj_data, 'desc_codempid'), '');
    v_qtyaccaw      			:= nvl(hcm_util.get_string_t(obj_data, 'qtyaccaw'), '');
    v_dteyrepay      			:= nvl((to_char(to_number(hcm_util.get_string_t(obj_data, 'dteyrepay'))+ v_year)), ' ');
    v_dtemthpay      			:= nvl(get_tlistval_name('NAMMTHFUL',hcm_util.get_string_t(obj_data, 'dtemthpay'),global_v_lang), ' ');
    v_numperiod      			:= nvl(hcm_util.get_string_t(obj_data, 'numperiod'), '');
    v_qtyoldacc      			:= nvl(hcm_util.get_string_t(obj_data, 'qtyoldacc'), '');
    v_numseq_      				:= nvl(hcm_util.get_string_t(obj_data, 'numseq'), '');

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq    := v_numseq + 1;
    v_dtecalc   := to_date(hcm_util.get_string_t(obj_data, 'dtecalc'), 'DD/MM/YYYY');
    v_dtecalc_  := to_char(v_dtecalc, 'DD/MM/') || (to_number(to_char(v_dtecalc, 'YYYY')) + v_year);

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,item1, item2, item3, item4,item5, item6, item7, item8, item9,
             item10, item11, item12, item13
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
            v_codaward,
            v_desc_codaward,
            p_codempid,
            v_desc_codempid,
            v_qtyaccaw,
            v_dtecalc_,
            v_dteyrepay,
            v_dtemthpay,
            v_numperiod,
            v_qtyoldacc,
            v_qtyaccaw,
            v_numseq_,
            v_dtecalc_
      );
    exception when others then
        null;
    end;
  end insert_ttemprpt;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    json_obj        json_object_t;
    v_flg           varchar2(1000);
    v_secur         varchar2(4000 char);
  begin
--    check_index;
    json_obj            := json_object_t(json_str_input);
    param_json          := hcm_util.get_json_t(json_obj, 'json_input_str');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
        --
        p_codempid      := hcm_util.get_string_t(param_json_row,'codempid');
        p_codaward      := hcm_util.get_string_t(param_json_row,'codaward');
        v_flg           := hcm_util.get_string_t(param_json_row,'flg');
        --
        if v_flg = 'delete' then
          begin
            delete from tempawrd
                  where codempid = p_codempid
                    and codaward = p_codaward;

            delete from tempawrd2
                  where codempid  = p_codempid
                    and codaward  = p_codaward;
          end;
        end if;
      end loop;
      commit;
      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_flg           varchar2(1000);
    v_qtyaccaw     tempawrd2.qtyaccaw%type;
  begin
    initial_value(json_str_input);
    check_save_detail;

    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then
      p_qtyaccaw  := nvl(p_qtyaccaw,0);
      if p_qtyaccaw = 0 then
        p_qtyoldacc := 0;
      else
        p_qtyoldacc := p_qtyaccaw - 1;
      end if;


      --
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
        --
        p_dteyrepay := to_number(hcm_util.get_string_t(param_json_row,'dteyrepay'));
        p_dtemthpay := to_number(hcm_util.get_string_t(param_json_row,'dtemthpay'));
        p_numperiod := to_number(hcm_util.get_string_t(param_json_row,'numperiod'));
        p_qtyaccaw  := to_number(hcm_util.get_string_t(param_json_row,'qtyaccaw'));
        p_qtyoldacc := to_number(hcm_util.get_string_t(param_json_row,'qtyoldacc'));
        p_dtecalc   := to_date(hcm_util.get_string_t(param_json_row,'dtecalc'),'dd/mm/yyyy');
        v_flg       := hcm_util.get_string_t(param_json_row,'flg');
        --
        if v_flg = 'add' then
          check_save_detail_table('I');
          if param_msg_error is null then
              begin
                insert into tempawrd2 (dteyrepay, dtemthpay, numperiod, codempid, codaward, qtyaccaw, qtyoldacc, dtecalc, dteupd, coduser, codcreate, dtecreate)
                     values (p_dteyrepay, p_dtemthpay, p_numperiod, p_codempid, p_codaward, p_qtyaccaw, p_qtyoldacc,p_dtecalc, sysdate, global_v_coduser, global_v_coduser,sysdate);
                     commit;
              exception when dup_val_on_index then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tempawrd2');
              end;
              begin
                  select qtyaccaw into v_qtyaccaw from tempawrd2 t1
                   where codempid = p_codempid
                     and codaward = p_codaward
                     and lpad(DTEYREPAY,4,'0')||lpad(DTEMTHPAY,2,'0')||NUMPERIOD = (
                            select max(lpad(DTEYREPAY,4,'0')||lpad(DTEMTHPAY,2,'0')||NUMPERIOD)
                             from tempawrd2 t2
                             where t2.codempid = p_codempid
                             and t2.codaward = p_codaward
                             and (lpad(t2.DTEYREPAY,4,'0')||lpad(t2.DTEMTHPAY,2,'0')||t2.NUMPERIOD) < lpad(p_dteyrepay,4,'0')||lpad(p_dtemthpay,2,'0')||p_numperiod
                             );
              exception when others then
               v_qtyaccaw := null;
              end;
              begin
                  update tempawrd2 t1
                     set qtyoldacc = v_qtyaccaw
                   where codempid = p_codempid
                     and codaward = p_codaward
                     and dteyrepay = p_dteyrepay
                     and dtemthpay = p_dtemthpay
                     and numperiod = p_numperiod;

              end;

               begin
                  update tempawrd2 t1
                     set qtyoldacc = p_qtyaccaw
                   where codempid = p_codempid
                     and codaward = p_codaward
                     and lpad(dteyrepay,4,'0')||lpad(dtemthpay,2,'0')||numperiod = (
                            select min(lpad(dteyrepay,4,'0')||lpad(dtemthpay,2,'0')||numperiod)
                             from tempawrd2 t2
                             where t2.codempid = p_codempid
                             and t2.codaward = p_codaward
                             and (lpad(t2.dteyrepay,4,'0')||lpad(t2.dtemthpay,2,'0')||t2.numperiod) > lpad(p_dteyrepay,4,'0')||lpad(p_dtemthpay,2,'0')||p_numperiod
                             );
              end;
          end if;
        elsif v_flg = 'edit' then
          check_save_detail_table('U');
          if param_msg_error is null then
              begin
                update tempawrd2 set qtyaccaw  = p_qtyaccaw,
                                     qtyoldacc = p_qtyoldacc,
                                     dtecalc   = p_dtecalc,
                                     dteupd    = sysdate,
                                     coduser   = global_v_coduser,
                                     codcreate   = global_v_coduser
                               where dteyrepay = p_dteyrepay
                                 and dtemthpay = p_dtemthpay
                                 and numperiod = p_numperiod
                                 and codempid  = p_codempid
                                 and codaward  = p_codaward;
              end;
              begin
                  update tempawrd2 t1
                     set qtyoldacc = p_qtyaccaw
                   where codempid = p_codempid
                     and codaward = p_codaward
                     and lpad(dteyrepay,4,'0')||lpad(dtemthpay,2,'0')||numperiod = (
                            select min(lpad(dteyrepay,4,'0')||lpad(dtemthpay,2,'0')||numperiod)
                             from tempawrd2 t2
                             where t2.codempid = p_codempid
                             and t2.codaward = p_codaward
                             and (lpad(t2.dteyrepay,4,'0')||lpad(t2.dtemthpay,2,'0')||t2.numperiod) > lpad(p_dteyrepay,4,'0')||lpad(p_dtemthpay,2,'0')||p_numperiod
                             );
              end;
          end if;
        elsif v_flg = 'delete' then
          delete from tempawrd2
                where dteyrepay = p_dteyrepay
                  and dtemthpay = p_dtemthpay
                  and numperiod = p_numperiod
                  and codempid  = p_codempid
                  and codaward  = p_codaward;
        end if;
      end loop;

      begin
          select qtyoldacc, qtyaccaw,dtecalc
          into p_qtyoldacc, p_qtyaccaw,p_dtecalc
          from tempawrd2
          where codempid = p_codempid
            and codaward = p_codaward
            and rownum <= 1
          order by dteyrepay desc,dtemthpay desc,numperiod desc;
       exception when others then
         p_qtyoldacc := 0;
         p_qtyaccaw := 0;
         p_dtecalc := null;
      end;

      begin
        insert into tempawrd (codempid, codaward, qtyoldacc, qtyaccaw, dtecalc, dteupd, coduser, codcreate,dtecreate)
             values (p_codempid, p_codaward, p_qtyoldacc, p_qtyaccaw, p_dtecalc, sysdate, global_v_coduser, global_v_coduser,sysdate);
      exception when dup_val_on_index then
        update tempawrd set qtyoldacc = p_qtyoldacc,
                            qtyaccaw  = p_qtyaccaw,
                            dtecalc   = p_dtecalc,
                            dteupd    = sysdate,
                            coduser   = global_v_coduser,
                            codcreate   = global_v_coduser
                      where codempid  = p_codempid
                        and codaward  = p_codaward;
      end;

      if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_dtecalc (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_dtecalc(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_dtecalc(json_str_output out clob) as
    obj_row      json_object_t;
    v_codempid   temploy1.codempid%type;
    v_codaward   tempawrd.codaward%type;
    v_qtyaccaw   number;
    v_dtecalc    date;
    v_codcompy   temploy1.codcomp%type;
    v_typpayroll temploy1.typpayroll%type;
    v_codpay     tcontraw.codpay%type;
    v_dteend     tpriodal.dteend%type;

  begin
    begin
      select hcm_util.get_codcomp_level(codcomp,1), typpayroll
        into v_codcompy, v_typpayroll
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      v_codcompy  := null;
      v_typpayroll  := null;
    end;

    begin
      select codpay
        into v_codpay
        from tcontraw
       where codcompy = v_codcompy
         and codaward = p_codaward
         and dteeffec = (select max(dteeffec) from tcontraw
                           where codcompy = v_codcompy
                             and codaward = p_codaward);
    exception when no_data_found then
      v_codpay  := null;
    end;

    begin
      select dteend
        into v_dteend
        from tpriodal
       where codcompy = v_codcompy
         and typpayroll = v_typpayroll
         and codpay = v_codpay
         and dteyrepay = p_dteyrepay
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod;
    exception when no_data_found then
      v_dteend  := null;
    end;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('dtecalc', to_char(v_dteend,'dd/mm/yyyy'));

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
END HRAL96E;

/

--------------------------------------------------------
--  DDL for Package Body HRPY2JX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY2JX" as

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
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_dtepayst          := to_date(hcm_util.get_string_t(json_obj, 'p_dtepayst'),'dd/mm/yyyy');
    p_dtepayen          := to_date(hcm_util.get_string_t(json_obj, 'p_dtepayen'),'dd/mm/yyyy');
    p_data              := hcm_util.get_json_t(json_obj,'p_data');
    p_codlegald         := hcm_util.get_string_t(json_obj, 'p_codlegald');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codempid    temploy1.codempid%type;
  begin
    if p_codempid is not null then
      begin
        select codempid into v_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal) = false then
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
    obj_row            json_object_t;
    obj_data           json_object_t;
    obj_child_data     json_object_t;
    obj_child_row      json_object_t;
    v_rcnt             number;
    v_rcnt_child       number;
    v_flg_permission   boolean := false;
    v_flgdata          varchar2(1 char) := 'N';
    v_temp_legald      varchar2(100 char) := '@@@@@';
    v_total            number := 0;
    v_secur            boolean := false;

    cursor c1 is
      select a.codlegald
        from tlegalexe a
       where exists(select b.codempid from tlegalprd b
                     where b.codempid  = a.codempid
                       and b.numcaselw = a.numcaselw
                       and b.codempid  = p_codempid
                       and b.dtepay between p_dtepayst and p_dtepayen)
        and ((a.codlegald <> p_codlegald_x and p_codlegald_x is not null) or p_codlegald_x is null)
      group by a.codlegald
      order by a.codlegald; --#6160 || User39 || 6/9/2021;

    cursor c2 (p_codlegald varchar2) is
      select a.codempid,a.codcomp,a.dtemthpay,a.dtepay,a.typpaymt,a.numref,a.numtime,a.numcaselw,
             nvl(stddec(a.amtded,a.codempid,v_chken),0) amtded,
             nvl(stddec(a.amtbal,a.codempid,v_chken),0) amtbal
        from tlegalprd a, tlegalexe b
       where a.codempid  = b.codempid
         and a.numcaselw = b.numcaselw
         and b.codlegald = p_codlegald
         and a.codempid  = p_codempid
         and a.dtepay between p_dtepayst and p_dtepayen
         order by  dteyrepay asc,
         dtemthpay  asc ;--a.dtepay;
  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    v_flgdata              := 'N';
    --
    for r1 in c1 loop
      v_flgdata            := 'Y';
      exit;
    end loop;


    --
    if v_flgdata = 'N' then
      if not isInsertReport then
        param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tlegalprd');
        json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
        return;
       end if;
    end if;
    --
    v_flgdata              := 'N';
    --
    for r1 in c1 loop
      v_flgdata        := 'Y';
      v_rcnt_child     := 0;
      obj_data         := json_object_t();
      obj_child_row    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codlegald', r1.codlegald);
      obj_data.put('desc_codlegald', r1.codlegald || ' - ' || get_tcodec_name('TCODLEGALD',r1.codlegald, global_v_lang));
      obj_data.put('codempid', p_codempid);
      obj_data.put('dtepayst', to_char(p_dtepayst,'dd/mm/yyyy'));
      obj_data.put('dtepayen', to_char(p_dtepayen,'dd/mm/yyyy'));
      for r2 in c2 (r1.codlegald) loop
        v_secur := secur_main.secur3(r2.codcomp,r2.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        if v_secur then
          v_flg_permission := true;
          if (v_temp_legald <> r1.codlegald) then
            obj_child_data         := json_object_t();
            obj_child_data.put('coderror', '200');
            obj_child_data.put('codlegald',r1.codlegald);
            obj_child_data.put('numref', get_label_name('HRPY2JXC2',global_v_lang,'70'));
            obj_child_data.put('amtbal', nvl(r2.amtded,0) + nvl(r2.amtbal,0));

            obj_child_row.put(to_char(v_rcnt_child), obj_child_data);
            v_rcnt_child    := v_rcnt_child + 1;
            v_temp_legald   := r1.codlegald;
          end if;
          obj_child_data         := json_object_t();
          obj_child_data.put('coderror', '200');
          obj_child_data.put('codlegald',r1.codlegald);
          obj_child_data.put('dtemthpay', get_nammthful(r2.dtemthpay, global_v_lang));
          obj_child_data.put('dtepay', to_char(r2.dtepay,'dd/mm/yyyy'));
          obj_child_data.put('amtded', r2.amtded);
          obj_child_data.put('typpaymt', get_tlistval_name('TYPPAYMT',r2.typpaymt, global_v_lang));
          obj_child_data.put('numref', r2.numref);
          obj_child_data.put('amtbal', r2.amtbal);
          obj_child_data.put('numcaselw', r2.numcaselw);
          obj_child_data.put('numtime', r2.numtime);
          obj_child_data.put('codempid', r2.codempid);

          obj_child_row.put(to_char(v_rcnt_child), obj_child_data);
          v_rcnt_child    := v_rcnt_child + 1;
        end if;
      end loop;
      obj_data.put('children', obj_child_row);
      --report--
      if isInsertReport then
        insert_ttemprpt_data(obj_data);
      end if;
      --
      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt           := v_rcnt + 1;
    end loop;
    --
    if not v_flg_permission then
      if not isInsertReport then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        return;
      end if;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;

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

  procedure get_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    obj_main            json_object_t;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    obj_main := json_object_t();
    if param_msg_error is null then
      p_codapp := 'HRPY2JX';
      clear_ttemprpt;
      obj_main.put('codlegald',p_codlegald);
      obj_main.put('codempid',p_codempid);
      obj_main.put('dtepayst',to_char(p_dtepayst,'dd/mm/yyyy'));
      obj_main.put('dtepayen',to_char(p_dtepayen,'dd/mm/yyyy'));
      obj_main.put('children',p_data);
      insert_ttemprpt_data(obj_main);
      p_codlegald_x := p_codlegald;
      gen_data(json_output);
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
  end get_report;

  procedure insert_ttemprpt_data(obj_data in json_object_t) is
    json_data_rows      json_object_t;
    v_data_rows         json_object_t;
    v_numseq            number := 0;
    v_codlegald         varchar2(1000 char);
    v_codempid          varchar2(1000 char);
    v_dtepayst          varchar2(1000 char);
    v_dtepayen          varchar2(1000 char);
    v_thyear            varchar2(1000 char);
    v_month             varchar2(1000 char);
    v_desc_codlegald    varchar2(1000 char);
    v_desc_codcomp      varchar2(1000 char);
    v_dtepay            date;
    v_image             varchar2(1000 char) := '';
    v_flgimg            varchar2(1 char) := 'N';
    v_item4             varchar2(1000 char);
    v_item5  varchar2(1000 char);
    v_item6  varchar2(1000 char);
    v_item7  varchar2(1000 char);
    v_item8  varchar2(1000 char);
    v_item9  varchar2(1000 char);
    v_item10  varchar2(1000 char);
    v_item11  varchar2(1000 char);
    v_item12  varchar2(1000 char);
    v_item13  varchar2(1000 char);
    v_item14  varchar2(1000 char);
  begin
    v_codlegald       := hcm_util.get_string_t(obj_data, 'codlegald');
    v_desc_codlegald  := v_codlegald||' - '||get_tcodelegald_name(v_codlegald, global_v_lang);
    v_codempid        := hcm_util.get_string_t(obj_data, 'codempid');
    v_dtepayst        := hcm_util.get_string_t(obj_data, 'dtepayst');
    v_dtepayen        := hcm_util.get_string_t(obj_data, 'dtepayen');

    json_data_rows     := hcm_util.get_json_t(obj_data, 'children');
    for i in 0..json_data_rows.get_size-1 loop
      v_data_rows      := hcm_util.get_json_t(json_data_rows, to_char(i));
      v_dtepay         := to_date(hcm_util.get_string_t(v_data_rows, 'dtepay'), 'dd/mm/yyyy');
      --
      if v_codempid is not null then
          begin
            select get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||namimage, 'Y'
             into v_image,v_flgimg
             from tempimge
             where codempid = v_codempid;
          exception when no_data_found then
            v_image := '';
            v_flgimg := 'N';
          end;
      else
        v_image := '';
        v_flgimg := 'N';
      end if;


      begin
        select nvl(max(numseq), 0) into v_numseq
          from ttemprpt
         where codempid = global_v_codempid
           and codapp   = p_codapp;
      exception when no_data_found then null;
      end;
      v_numseq     := v_numseq + 1;
      v_item4 := hcm_util.get_date_buddhist_era(to_date(v_dtepayst,'dd/mm/yyyy'));
      v_item5 := hcm_util.get_date_buddhist_era(to_date(v_dtepayen,'dd/mm/yyyy'));
      v_item6 := nvl(hcm_util.get_string_t(v_data_rows, 'codempid'), ' ');
      v_item7 := nvl(hcm_util.get_string_t(v_data_rows, 'dtemthpay'), ' ');
      if v_dtepay is not null then
        v_item8 := hcm_util.get_date_buddhist_era(v_dtepay);
      else
        v_item8 := '';
      end if;
      v_item9 := nvl(to_char(hcm_util.get_string_t(v_data_rows, 'amtded'),'FM9,999,999,990.00'), ' ');
      v_item10 := nvl(to_char(hcm_util.get_string_t(v_data_rows, 'amtbal'),'FM9,999,999,990.00'), ' ');
      v_item11 := nvl(hcm_util.get_string_t(v_data_rows, 'typpaymt'), ' ');
      v_item12 := nvl(hcm_util.get_string_t(v_data_rows, 'numref'), ' ');
      v_item13 := nvl(hcm_util.get_string_t(v_data_rows, 'numcaselw'), ' ');
      v_item14 := nvl(hcm_util.get_string_t(v_data_rows, 'numtime'), ' ');
      --
      begin
        insert
          into ttemprpt
             (
               codempid, codapp, numseq,
               item1, item2, item3,
               item4,
               item5,
               item6,
               item7, item8,
               item9, item10, item11, item12, item13, item14,
               item15,
               item16
             )
        values
             ( global_v_codempid, p_codapp, v_numseq,
               v_codlegald, v_desc_codlegald, v_codempid,
               v_item4,
               v_item5,
               v_item6,
               v_item7,
               v_item8,
               v_item9,
               v_item10,
               v_item11,
               v_item12,
               v_item13,
               v_item14,
               v_image,
               v_flgimg
        );
      exception when others then null;
      end;
    end loop;
  end insert_ttemprpt_data;
end HRPY2JX;

/

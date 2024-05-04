--------------------------------------------------------
--  DDL for Package Body HRBFS2X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBFS2X" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codcompy          := hcm_util.get_string_t(json_obj, 'p_codcompy');
    p_dteyre            := to_number(hcm_util.get_number_t(json_obj, 'p_dteyre'));
    p_flginput          := to_char(hcm_util.get_number_t(json_obj, 'p_flginput'));

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy         tcompny.codcompy%type;
  begin
    if p_codcompy is not null then
      begin
        select codcompy
          into v_codcompy
          from tcompny
         where codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcompny');
        return;
      end;
      if not secur_main.secur7(p_codcompy, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    clear_ttemprpt;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_sum               number := 0;
    v_qtyhuman          number := 0;
    v_qtywidrw          number := 0;
    v_total             number := 0;
    v_codcomp           tobfdep.codcomp%type := '@#$%';
    v_codobf            tobfdep.codobf%type := 0;
    v_desc_qtywidrw     varchar2(500 char);
    v_graph_title       varchar2(500 char);
    v_codcomp_level     varchar2(200 char);
    v_desc_codcomp      varchar2(500 char);
    v_desc_codobf       varchar2(500 char);
    v_codcomp_compare   tobfdep.codcomp%type;
    v_found             boolean := false;

    cursor c1 is
      select a.codcomp, a.codobf, b.codunit, b.typebf, b.typepay, sum(a.qtyhuman) qtyhuman ,sum( a.qtywidrw) qtywidrw, sum(a.amtwidrw) amtwidrw
        from tobfdep a, tobfcde b
       where a.codobf  = b.codobf
         and a.codcomp like p_codcompy || '%'
         and a.dteyre  = p_dteyre
       group by a.codcomp, a.codobf, b.codunit, b.typebf, b.typepay
       order by a.codcomp, a.codobf ;


    cursor c1_group_codcomp is
      select a.codcomp
        from tobfdep a, tobfcde b
       where a.codobf  = b.codobf
         and a.codcomp like p_codcompy || '%'
         and a.dteyre  = p_dteyre
       group by a.codcomp;

    cursor c1_group_codobf is
      select a1.codobf
        from tobfdep a1, tobfcde b1
       where a1.codobf  = b1.codobf
         and a1.codcomp like p_codcompy || '%'
         and a1.dteyre  = p_dteyre
         and a1.codobf  not in (
          select a.codobf
            from tobfdep a, tobfcde b
           where a.codobf  = b.codobf
             and a.codcomp = v_codcomp_compare
             and a.dteyre  = p_dteyre
         )
       group by a1.codobf;

    cursor c2 is
      --select a.codcomp, a.codobf, b.codunit, a.qtyhuman, a.qtywidrw, a.amtwidrw, b.typepay
      select a.codcomp, a.codobf, b.codunit, b.typepay, sum(a.qtyhuman) qtyhuman ,sum( a.qtywidrw) qtywidrw, sum(a.amtwidrw) amtwidrw
        from tobfdep a, tobfcde b
       where a.codobf  = b.codobf
         and a.codcomp like p_codcompy || '%'
         and a.dteyre  = p_dteyre
         group by a.codcomp, a.codobf, b.codunit, b.typepay
       order by a.codobf, a.codcomp;
  begin
    obj_row       := json_object_t();

    if p_flginput = '1' then
      v_graph_title   := get_label_name('HRBFS2X', global_v_lang, 150);
      for i in c1 loop
        v_found     := true;
        if secur_main.secur7(i.codcomp, global_v_coduser) then
          if v_rcnt > 0 and i.codcomp <> v_codcomp then
            v_rcnt      := v_rcnt + 1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('flgsum', 'Y');
            obj_data.put('qtywidrw', get_label_name('HRBFS2X', global_v_lang, 170));
            obj_data.put('amtwidrw', to_char(v_sum));
            obj_row.put(to_char(v_rcnt - 1), obj_data);
            v_sum       := 0;
          end if;
          v_rcnt          := v_rcnt + 1;
          obj_data        := json_object_t();

          v_desc_qtywidrw := i.qtywidrw;
--17/08/2021
--          if i.typepay = 'C' then
--            v_desc_qtywidrw := to_char(i.qtywidrw, 'fm99,999,990.90');
--          end if;
          if i.typebf = 'C' then
            v_desc_qtywidrw := to_char(i.qtywidrw, 'fm99,999,990.90');
          else
            v_desc_qtywidrw := to_char(i.qtywidrw, 'fm99,999,990');
          end if;
--17/08/2021

          v_codcomp_level   := hcm_util.get_codcomp_level(i.codcomp, null, '-', 'Y');
          v_desc_codcomp    := get_tcenter_name(i.codcomp, global_v_lang);
          v_desc_codobf     := get_tobfcde_name(i.codobf, global_v_lang);
          obj_data.put('coderror', '200');
          obj_data.put('flgsum', '');
          obj_data.put('codcomp', v_codcomp_level);
          obj_data.put('desc_codcomp', v_desc_codcomp);
          obj_data.put('codobf', i.codobf);
          obj_data.put('desc_codobf', get_tobfcde_name(i.codobf, global_v_lang));
          obj_data.put('desc_codunit', get_tcodunit_name(i.codunit, global_v_lang));
          obj_data.put('qtyhuman', to_char(i.qtyhuman, 'fm99,999,990'));
          obj_data.put('qtywidrw', v_desc_qtywidrw);
          obj_data.put('amtwidrw', to_char(i.amtwidrw, 'fm99,999,990.90'));          
--17/08/2021
--          obj_data.put('qtyhuman', to_char(i.qtyhuman, 'fm99,999,990'));
--          obj_data.put('qtywidrw', to_char(i.qtywidrw, 'fm99,999,990'));
--          obj_data.put('amtwidrw', to_char(i.amtwidrw, 'fm99,999,990.00'));
--17/08/2021
          obj_data.put('typepay', i.typepay);
          v_sum       := v_sum + i.amtwidrw;
          v_total     := v_total + i.amtwidrw;
          v_codcomp   := i.codcomp;

          insert_ttemprpt(
            v_graph_title,
            get_label_name('HRBFS2X', global_v_lang, 190), null, null, v_codcomp_level, v_codcomp_level,
            null, i.codobf, v_desc_codobf, get_label_name('HRBFS2X', global_v_lang, 190), i.qtyhuman,
            null, null, null
          );
          insert_ttemprpt(
            v_graph_title,
            get_label_name('HRBFS2X', global_v_lang, 200), null, null, v_codcomp_level, v_codcomp_level,
            null, i.codobf, v_desc_codobf, get_label_name('HRBFS2X', global_v_lang, 200), i.amtwidrw,
            null, null, null
          );
          insert_ttemprpt(
            v_graph_title,
            get_label_name('HRBFS2X', global_v_lang, 130), null, null, v_codcomp_level, v_codcomp_level,
            null, i.codobf, v_desc_codobf, get_label_name('HRBFS2X', global_v_lang, 130), i.qtywidrw,
            null, null, null
          );
          obj_row.put(to_char(v_rcnt - 1), obj_data);
        end if;
      end loop;
      for i_comp in c1_group_codcomp loop
        if secur_main.secur7(i_comp.codcomp, global_v_coduser) then
          v_codcomp_compare   := i_comp.codcomp;
          for i_obf in c1_group_codobf loop
            v_codcomp_level   := hcm_util.get_codcomp_level(v_codcomp_compare, null, '-', 'Y');
            v_desc_codcomp    := get_tcenter_name(v_codcomp_compare, global_v_lang);
            v_desc_codobf     := get_tobfcde_name(i_obf.codobf, global_v_lang);
            insert_ttemprpt(
              v_graph_title,
              get_label_name('HRBFS2X', global_v_lang, 190), null, null, v_codcomp_level, v_codcomp_level,
              null, i_obf.codobf, v_desc_codobf, get_label_name('HRBFS2X', global_v_lang, 190), '0',
              null, null, null
            );
            insert_ttemprpt(
              v_graph_title,
              get_label_name('HRBFS2X', global_v_lang, 200), null, null, v_codcomp_level, v_codcomp_level,
              null, i_obf.codobf, v_desc_codobf, get_label_name('HRBFS2X', global_v_lang, 200), '0',
              null, null, null
            );
            insert_ttemprpt(
              v_graph_title,
              get_label_name('HRBFS2X', global_v_lang, 130), null, null, v_codcomp_level, v_codcomp_level,
              null, i_obf.codobf, v_desc_codobf, get_label_name('HRBFS2X', global_v_lang, 130), '0',
              null, null, null
            );
          end loop;
        end if;
      end loop;

      if obj_row.get_size > 0 then
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('flgsum', 'Y');
        obj_data.put('qtywidrw', get_label_name('HRBFS2X', global_v_lang, 170));
        obj_data.put('amtwidrw', to_char(v_sum));
        obj_row.put(to_char(v_rcnt - 1), obj_data);
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('flgsum', 'Y');
        obj_data.put('qtywidrw', get_label_name('HRBFS2X', global_v_lang, 180));
        obj_data.put('amtwidrw', to_char(v_total));
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    else
      v_graph_title   := get_label_name('HRBFS2X', global_v_lang, 160);
      for j in c2 loop
        v_found     := true;
        if secur_main.secur7(j.codcomp, global_v_coduser) then
          if v_rcnt > 0 and j.codobf <> v_codobf then
            v_rcnt      := v_rcnt + 1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('flgsum', 'Y');
            obj_data.put('qtywidrw', get_label_name('HRBFS2X', global_v_lang, 170));
            obj_data.put('amtwidrw', to_char(v_sum));
            obj_row.put(to_char(v_rcnt - 1), obj_data);
            v_sum       := 0;
            v_qtyhuman  := 0;
            v_qtywidrw  := 0;
          end if;
          v_rcnt          := v_rcnt + 1;
          obj_data        := json_object_t();
          v_desc_qtywidrw := j.qtywidrw;
          if j.typepay = 'C' then
            v_desc_qtywidrw := to_char(j.qtywidrw, 'fm99,999,990.90');
          end if;
          v_codcomp_level   := hcm_util.get_codcomp_level(j.codcomp, null, '-', 'Y');
          v_desc_codobf     := get_tobfcde_name(j.codobf, global_v_lang);
          obj_data.put('coderror', '200');
          obj_data.put('flgsum', '');
          obj_data.put('codcomp', v_codcomp_level);
          obj_data.put('desc_codcomp',get_tcenter_name(j.codcomp, global_v_lang));
          obj_data.put('codobf', j.codobf);
          obj_data.put('desc_codobf', v_desc_codobf);
          obj_data.put('desc_codunit', get_tcodunit_name(j.codunit, global_v_lang));
          obj_data.put('qtyhuman', j.qtyhuman);
          obj_data.put('qtywidrw', v_desc_qtywidrw);
          obj_data.put('amtwidrw', j.amtwidrw);
          obj_data.put('typepay', j.typepay);
          v_sum       := v_sum + j.amtwidrw;
          v_qtyhuman  := v_qtyhuman + j.qtyhuman;
          v_qtywidrw  := v_qtywidrw + j.qtywidrw;
          v_total     := v_total + j.amtwidrw;
          v_codobf    := j.codobf;

          insert_ttemprpt(
            v_graph_title,
            get_label_name('HRBFS2X', global_v_lang, 190), null, null, j.codobf, v_desc_codobf,
            null, v_codcomp_level, v_codcomp_level, get_label_name('HRBFS2X', global_v_lang, 190), j.qtyhuman,
            null, null, null
          );
          insert_ttemprpt(
            v_graph_title,
            get_label_name('HRBFS2X', global_v_lang, 200), null, null, j.codobf, v_desc_codobf,
            null, v_codcomp_level, v_codcomp_level, get_label_name('HRBFS2X', global_v_lang, 200), j.amtwidrw,
            null, null, null
          );
          insert_ttemprpt(
            v_graph_title,
            get_label_name('HRBFS2X', global_v_lang, 130), null, null, j.codobf, v_desc_codobf,
            null, v_codcomp_level, v_codcomp_level, get_label_name('HRBFS2X', global_v_lang, 130), j.qtywidrw,
            null, null, null
          );
          obj_row.put(to_char(v_rcnt - 1), obj_data);
        end if;
      end loop;
      for j_comp in c1_group_codcomp loop
        if secur_main.secur7(j_comp.codcomp, global_v_coduser) then
          v_codcomp_compare   := j_comp.codcomp;
          for i_obf in c1_group_codobf loop
            v_codcomp_level   := hcm_util.get_codcomp_level(v_codcomp_compare, null, '-', 'Y');
            v_desc_codcomp    := get_tcenter_name(v_codcomp_compare, global_v_lang);
            v_desc_codobf     := get_tobfcde_name(i_obf.codobf, global_v_lang);
            insert_ttemprpt(
              v_graph_title,
              get_label_name('HRBFS2X', global_v_lang, 190), null, null, i_obf.codobf, v_desc_codobf,
              null, v_codcomp_level, v_codcomp_level, get_label_name('HRBFS2X', global_v_lang, 190), '0',
              null, null, null
            );
            insert_ttemprpt(
              v_graph_title,
              get_label_name('HRBFS2X', global_v_lang, 200), null, null, i_obf.codobf, v_desc_codobf,
              null, v_codcomp_level, v_codcomp_level, get_label_name('HRBFS2X', global_v_lang, 200), '0',
              null, null, null
            );
            insert_ttemprpt(
              v_graph_title,
              get_label_name('HRBFS2X', global_v_lang, 130), null, null, i_obf.codobf, v_desc_codobf,
              null, v_codcomp_level, v_codcomp_level, get_label_name('HRBFS2X', global_v_lang, 130), '0',
              null, null, null
            );
          end loop;
        end if;
      end loop;

      if obj_row.get_size > 0 then
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('flgsum', 'Y');
        obj_data.put('qtywidrw', get_label_name('HRBFS2X', global_v_lang, 170));
        obj_data.put('amtwidrw', to_char(v_sum));
        obj_row.put(to_char(v_rcnt - 1), obj_data);
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('flgsum', 'Y');
        obj_data.put('qtywidrw', get_label_name('HRBFS2X', global_v_lang, 180));
        obj_data.put('amtwidrw', to_char(v_total));
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end if;
    if obj_row.get_size > 0 then
      json_str_output := obj_row.to_clob;
    else
      if v_found then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tobfdep');
      end if;
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  function get_ttemprpt_numseq (v_codapp varchar2) return number is
  begin
    begin
      select nvl(max(numseq), 0)
        into p_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = v_codapp;
    exception when no_data_found then
      null;
    end;
    return p_numseq;
  end;

  procedure insert_ttemprpt(
    v_graph_title varchar2,
    v_item1 varchar2,
    v_item2 varchar2,
    v_item3 varchar2,
    v_item4 varchar2,
    v_item5 varchar2,
    v_item6 varchar2,
    v_item7 varchar2,
    v_item8 varchar2,
    v_item9 varchar2,
    v_item10 varchar2,
    v_item11 varchar2,
    v_item12 varchar2,
    v_item13 varchar2
  ) is
  begin
    p_numseq            := p_numseq + 1;

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5,
             item6, item7, item8, item9, item10,
             item11, item12, item13,
             item31
           )
      values
           (
             global_v_codempid, p_codapp, p_numseq,
             v_item1, -- item1
             v_item2, -- item2
             v_item3, -- item3
             v_item4, -- item4
             v_item5, -- item5
             v_item6, -- item6
             v_item7, -- item7
             v_item8, -- item8
             v_item9, -- item9
             v_item10, -- item10
             v_item11, -- item11
             v_item12, -- item12
             v_item13, -- item13
             v_graph_title -- item31
           );
    exception when dup_val_on_index then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt;
end HRBFS2X;

/

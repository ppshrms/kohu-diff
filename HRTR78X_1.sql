--------------------------------------------------------
--  DDL for Package Body HRTR78X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR78X" AS

procedure initial_value(json_str_input in clob) as
        json_obj    json;
    begin
        json_obj            := json(json_str_input);

        --global
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');

        -- index params
        p_codcompy          := hcm_util.get_string(json_obj, 'p_codcompy');
        p_monthst           := hcm_util.get_string(json_obj, 'p_monthst');
        p_yearst            := hcm_util.get_string(json_obj, 'p_yearst');
        p_monthen           := hcm_util.get_string(json_obj, 'p_monthen');
        p_yearen            := hcm_util.get_string(json_obj, 'p_yearen');
        p_flgreport         := hcm_util.get_string(json_obj, 'p_flgreport');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    end initial_value;

    procedure get_index_codcours(json_str_input in clob, json_str_output out clob) as
        begin
        initial_value(json_str_input);
        if param_msg_error is null then
          gen_index_codcours(json_str_output);
        else
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end get_index_codcours;

    procedure gen_index_codcours (json_str_output out clob) as
        obj_data          json;
        obj_row           json    := json();
        json_obj_graph    json    := json();
        v_rcnt            number  := 0;
        v_flg_exist       boolean := false;
        v_flg_secure      boolean := false;
        v_check_codcompy  number  := 0;

        cursor c1 is
          select b.codcate, a.codcours, a.codtparg, count(a.numclseq) count_numclseq,
                 sum(a.qtyppc) sum_qtyppc, sum(amttotexp) sum_amttotexp
            from thisclss a, tcourse b
           where a.codcours = b.codcours
             and a.codcompy = p_codcompy
             and a.dteyear between p_yearst and p_yearen
             and dtemonth between to_number(p_monthst) and to_number(p_monthen)
        group by b.codcate, a.codcours, a.codtparg
        order by b.codcate, a.codcours, a.codtparg;

        begin
        select count(codcompy) into v_check_codcompy
              from tcompny
              where codcompy = p_codcompy;

              if v_check_codcompy = 0 then
                 param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
              end if;

              for r1 in c1 loop
                 v_flg_exist := true;
                 exit;
              end loop;

              if not v_flg_exist then
                 param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THISCLSS');
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
              end if;

              --  secur_main.secur7
              if p_codcompy is not null then
                  v_flg_secure := secur_main.secur7(p_codcompy, global_v_coduser);
                  if not v_flg_secure then
                      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                      return;
                  end if;
              end if;

              for r1 in c1 loop
                 v_rcnt := v_rcnt + 1;
                 obj_data := json();
                 obj_data.put('codcate', r1.codcate);
                 obj_data.put('desc_codcate', get_tcodec_name('TCODCATE', r1.codcate, global_v_lang));
                 obj_data.put('codcourse', r1.codcours);
                 obj_data.put('desc_codcourse', get_tcourse_name(r1.codcours, global_v_lang));
                 obj_data.put('gen', r1.count_numclseq);
                 obj_data.put('participant', r1.sum_qtyppc);
                 obj_data.put('expenses', r1.sum_amttotexp);
                 obj_row.put(to_char(v_rcnt-1),obj_data);
--              end if;
              end loop;
      json_obj_graph := obj_row;
      gen_graph(json_obj_graph);
      dbms_lob.createtemporary(json_str_output, true);
      obj_row.to_clob(json_str_output);

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_index_codcours;

    procedure get_index_codexpn(json_str_input in clob, json_str_output out clob) as
    begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_codexpn(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end get_index_codexpn;

    procedure gen_index_codexpn (json_str_output out clob) as
        obj_data          json;
        obj_data_child    json;
        obj_data_row      json;
        obj_row           json    := json();
        json_obj_graph    json    := json();
        v_rcnt            number  := 0;
        v_rcnt_child      number;
        v_flg_exist       boolean := false;
        v_flg_secure      boolean := false;
        v_check_codcompy  number  := 0;
        v_temp_month      tcosttr.dtemonth%type;
        v_temp_year       tcosttr.dteyear%type;
        v_descode         tcodexpn.descode%type;
        v_descodt         tcodexpn.descodt%type;
        v_descod3         tcodexpn.descod3%type;
        v_descod4         tcodexpn.descod4%type;
        v_descod5         tcodexpn.descod5%type;
        v_typexpn         thiscost.typexpn%type;

        cursor c1 is
           select distinct dteyear, dtemonth
             from tcosttr
            where codcompy = p_codcompy
              and dteyear between p_yearst and p_yearen
              and dtemonth between to_number(p_monthst) and to_number(p_monthen)
         order by dteyear, to_number(dtemonth);

        cursor c2 is
          select codexpn, sum(amtcost) sum_amtcost
            from tcosttr
           where codcompy = p_codcompy
             and dteyear = v_temp_year
             and dtemonth = v_temp_month
        group by codexpn
        order by codexpn;

        begin
          select count(codcompy) into v_check_codcompy
          from tcompny
          where codcompy = p_codcompy;

          if v_check_codcompy = 0 then
             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
             json_str_output := get_response_message('400',param_msg_error,global_v_lang);
             return;
          end if;

          for r1 in c1 loop
             v_flg_exist := true;
             exit;
          end loop;

          if not v_flg_exist then
             param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TCOSTTR');
             json_str_output := get_response_message('400',param_msg_error,global_v_lang);
             return;
          end if;

          --  secur_main.secur7
          if p_codcompy is not null then
              v_flg_secure := secur_main.secur7(p_codcompy, global_v_coduser);
              if not v_flg_secure then
                  param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                  json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                  return;
              end if;
          end if;

          for r1 in c1 loop
             v_rcnt := v_rcnt + 1;
             v_rcnt_child := 0;
             v_temp_year  := r1.dteyear;
             v_temp_month := r1.dtemonth;

             obj_data := json();
             obj_data_row := json();
             obj_data_row.put('month', r1.dtemonth);
             obj_data_row.put('year', r1.dteyear);

             for r2 in c2 loop
                 v_rcnt_child := v_rcnt_child + 1;
                 obj_data_child := json();
                 obj_data_child.put('codexpend', r2.codexpn);

                 begin
                     select descode, descodt, descod3, descod4, descod5
                       into v_descode, v_descodt, v_descod3, v_descod4, v_descod5
                       from tcodexpn
                      where codexpn = r2.codexpn;
                      exception when no_data_found then
                        v_descode := '';
                        v_descodt := '';
                        v_descod3 := '';
                        v_descod4 := '';
                        v_descod5 := '';
                  end;

                if global_v_lang = '101' then
                    obj_data_child.put('desc_codexpend', v_descode);
                elsif global_v_lang = '102' then
                    obj_data_child.put('desc_codexpend', v_descodt);
                elsif global_v_lang = '103' then
                    obj_data_child.put('desc_codexpend', v_descod3);
                elsif global_v_lang = '104' then
                    obj_data_child.put('desc_codexpend', v_descod4);
                elsif global_v_lang = '105' then
                    obj_data_child.put('desc_codexpend', v_descod5);
                end if;

                begin
                    select typexpn
                      into v_typexpn
                      from thiscost
                     where codexpn = r2.codexpn and rownum = 1;
                 exception when no_data_found then
                       v_typexpn := '';
                end;

                 obj_data_child.put('typexpend', get_tlistval_name('TYPEXPN', v_typexpn, global_v_lang));
                 obj_data_child.put('amount', r2.sum_amtcost);
                 obj_data.put(to_char(v_rcnt_child-1),obj_data_child);
             end loop;
             obj_data_row.put('children', obj_data);
             obj_row.put(to_char(v_rcnt-1),obj_data_row);
          end loop;
      json_obj_graph := obj_row;
      gen_graph(json_obj_graph);
      dbms_lob.createtemporary(json_str_output, true);
      obj_row.to_clob(json_str_output);

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_index_codexpn;

    procedure get_index_month(json_str_input in clob, json_str_output out clob) as
    begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_month(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end get_index_month;

    procedure gen_index_month (json_str_output out clob) as
        obj_data          json;
        obj_row           json    := json();
        json_obj_graph    json    := json();
        v_rcnt            number  := 0;
        v_flg_exist       boolean := false;
        v_flg_secure      boolean := false;
        v_check_codcompy  number  := 0;
        v_temp_month      thisclss.dtemonth%type := '';
        v_temp_year       thisclss.dteyear%type  := 0;
        v_count_repeat    number  := 0;
        v_sum_qtyppc      number  := 0;
        v_sum_qtytrmin    number  := 0;
        v_sum_amttotexp   number  := 0;

        cursor c1 is
          select distinct dteyear, dtemonth
            from thisclss
           where codcompy = p_codcompy
             and dteyear between p_yearst and p_yearen
             and dtemonth between to_number(p_monthst) and to_number(p_monthen)
        group by dteyear, dtemonth
        order by dteyear, to_number(dtemonth);

        cursor c2 is
            select distinct dteyear, dtemonth, codcours, count(numclseq) count_numclseq,
                  sum(qtyppc) sum_qtyppc, sum(qtytrmin) sum_qtytrmin, sum(amttotexp) sum_amttotexp
            from thisclss
            where codcompy = p_codcompy
            and dteyear = v_temp_year
            and dtemonth = v_temp_month
            group by dteyear, dtemonth, codcours
            order by dteyear, to_number(dtemonth), codcours;

        begin
        select count(codcompy) into v_check_codcompy
              from tcompny
              where codcompy = p_codcompy;

              if v_check_codcompy = 0 then
                 param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
              end if;

              for r1 in c1 loop
                 v_flg_exist := true;
                 exit;
              end loop;

              if not v_flg_exist then
                 param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THISCLSS');
                 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                 return;
              end if;

              --  secur_main.secur7
              if p_codcompy is not null then
                  v_flg_secure := secur_main.secur7(p_codcompy, global_v_coduser);
                  if not v_flg_secure then
                      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                      return;
                  end if;
              end if;

              for r1 in c1 loop
                v_temp_month := r1.dtemonth;
                v_temp_year  := r1.dteyear;
                for r2 in c2 loop
                    v_sum_qtyppc    := v_sum_qtyppc + r2.sum_qtyppc;
                    v_sum_qtytrmin  := v_sum_qtytrmin + r2.sum_qtytrmin;
                    v_sum_amttotexp := v_sum_amttotexp + r2.sum_amttotexp;
                    obj_data := json();
                    v_rcnt := v_rcnt + 1;
                    obj_data.put('month', get_tlistval_name('NAMMTHFUL', r2.dtemonth ,global_v_lang));
                    obj_data.put('codcourse', r2.codcours);
                    obj_data.put('desc_codcourse', get_tcourse_name(r2.codcours, global_v_lang));
                    obj_data.put('gen', r2.count_numclseq);
                    obj_data.put('participant', r2.sum_qtyppc);
                    obj_data.put('totalhour', r2.sum_qtytrmin);
                    obj_data.put('expenses', r2.sum_amttotexp);
                    obj_row.put(to_char(v_rcnt-1),obj_data);
                end loop;
                obj_data := json();
                v_rcnt := v_rcnt + 1;
                obj_data.put('month', get_tlistval_name('NAMMTHFUL', v_temp_month ,global_v_lang));
                obj_data.put('month_short', get_tlistval_name('NAMMTHABB', v_temp_month ,global_v_lang));
                obj_data.put('codcourse', '');
                obj_data.put('desc_codcourse', '');
                obj_data.put('gen', get_label_name('HRTR78X4', global_v_lang, '80'));
                obj_data.put('participant', v_sum_qtyppc);
                obj_data.put('totalhour', v_sum_qtytrmin);
                obj_data.put('expenses', v_sum_amttotexp);
                obj_row.put(to_char(v_rcnt-1),obj_data);
                v_sum_qtyppc    := 0;
                v_sum_qtytrmin  := 0;
                v_sum_amttotexp := 0;
              end loop;
      json_obj_graph := obj_row;
      gen_graph(json_obj_graph);
      dbms_lob.createtemporary(json_str_output, true);
      obj_row.to_clob(json_str_output);

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_index_month;

    procedure gen_graph(obj_row in json) as
        obj_data    json;
        v_codempid  ttemprpt.codempid%type := global_v_codempid;
        v_codapp    ttemprpt.codapp%type := 'HRTR78X';
        v_numseq    ttemprpt.numseq%type := 1;
        v_item1     ttemprpt.item1%type  := null;
        v_item2     ttemprpt.item2%type  := null;
        v_item3     ttemprpt.item3%type  := null;
        v_item4     ttemprpt.item4%type;
        v_item5     ttemprpt.item5%type;
        v_item6     ttemprpt.item6%type;
        v_item7     ttemprpt.item7%type;
        v_item8     ttemprpt.item8%type;
        v_item9     ttemprpt.item9%type  := get_label_name('HRTR78X4', global_v_lang, '70');
        v_item10    ttemprpt.item10%type;
        v_item31    ttemprpt.item31%type;

        v_numitem4        number := 1;
        type t_codcours is table of thisclss.codcours%type;
        type t_codcours_val is table of number index by thisclss.codcours%type;
        type t_codexpn is table of tcosttr.codexpn%type;
        type t_codexpn_val is table of number index by tcosttr.codexpn%type;
        type t_desc_codexpn is table of tcodexpn.descode%type;

        v_dtcodcours t_codcours := t_codcours();
        v_codcours_val t_codcours_val  := t_codcours_val();
        v_dtcodexpn t_codexpn := t_codexpn();
        v_codexpn_val t_codexpn_val := t_codexpn_val();
        v_desc_codexpn t_desc_codexpn := t_desc_codexpn();

        v_children       json;
        param_children   json;
    begin
        v_item31 := get_label_name('HRTR78X5', global_v_lang, p_flgreport||'0');
        begin
          delete
            from ttemprpt
           where codempid = v_codempid
             and codapp = v_codapp;
        exception when others then
          rollback;
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
          return;
        end;
        if p_flgreport = 1 then
            v_item6  := get_label_name('HRTR78X4', global_v_lang, '30');
            for v_row in 1..obj_row.count loop
              obj_data      := hcm_util.get_json(obj_row, to_char(v_row - 1));
              v_dtcodcours.extend();
              v_dtcodcours(v_dtcodcours.last) := hcm_util.get_string(obj_data,'codcourse');
            end loop;

            v_dtcodcours := v_dtcodcours multiset intersect distinct v_dtcodcours;

            for i in 1..v_dtcodcours.count loop
                  v_codcours_val(v_dtcodcours(i)) := 0;
            end loop;
            for v_row in 1..obj_row.count loop
                obj_data     := hcm_util.get_json(obj_row, to_char(v_row - 1));
                for i in v_dtcodcours.first..v_dtcodcours.last loop
                      if v_dtcodcours(i) = hcm_util.get_string(obj_data,'codcourse') then
                           v_codcours_val(v_dtcodcours(i)) := v_codcours_val(v_dtcodcours(i)) + hcm_util.get_string(obj_data,'expenses');
                      end if;
                end loop;
            end loop;
            for i in v_dtcodcours.first..v_dtcodcours.last loop
                for j in v_dtcodcours.first..v_dtcodcours.last loop
                    v_item4  := v_numitem4;
                    v_item5  := v_dtcodcours(i);
                    v_item7  := v_dtcodcours(j);
                    v_item8  := v_dtcodcours(j)||' - '||get_tcourse_name(v_dtcodcours(j), global_v_lang);
                    if i = j then
                        v_item10 := v_codcours_val(v_dtcodcours(i));
                    else
                        v_item10 := 0;
                    end if;
                      begin
                        insert into ttemprpt
                          (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31)
                        values
                          (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31 );
                      exception when dup_val_on_index then
                        rollback;
                        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                        return;
                      end;
                      v_numseq := v_numseq + 1;
                end loop;
                v_numitem4 := v_numitem4 + 1;
            end loop;

        elsif p_flgreport = 2 then
            v_item6  := get_label_name('HRTR78X3', global_v_lang, '10');
            for v_row in 1..obj_row.count loop
                obj_data      := hcm_util.get_json(obj_row, to_char(v_row - 1));
                v_children    := hcm_util.get_json(obj_data, 'children');
                for i in 0..v_children.count-1 loop
                    param_children  := hcm_util.get_json(v_children, to_char(i));
                    v_dtcodexpn.extend();
                    v_dtcodexpn(v_dtcodexpn.last) := hcm_util.get_string(param_children,'codexpend');
                end loop;
            end loop;

            v_dtcodexpn := v_dtcodexpn multiset intersect distinct v_dtcodexpn;

            for i in 1..v_dtcodexpn.count loop
                  v_codexpn_val(v_dtcodexpn(i)) := 0;
            end loop;
            for v_row in 1..obj_row.count loop
                obj_data      := hcm_util.get_json(obj_row, to_char(v_row - 1));
                v_children    := hcm_util.get_json(obj_data, 'children');
                for i in v_dtcodexpn.first..v_dtcodexpn.last loop
                      for j in 0..v_children.count-1 loop
                            param_children  := hcm_util.get_json(v_children, to_char(j));
                            if v_dtcodexpn(i) = hcm_util.get_string(param_children,'codexpend') then
                                v_codexpn_val(v_dtcodexpn(i)) := v_codexpn_val(v_dtcodexpn(i)) + hcm_util.get_string(param_children,'amount');
                                v_desc_codexpn.extend();
                                v_desc_codexpn(v_desc_codexpn.last) := hcm_util.get_string(param_children,'desc_codexpend');
                            end if;
                      end loop;
                end loop;
            end loop;
            for i in v_dtcodexpn.first..v_dtcodexpn.last loop
                for j in v_dtcodexpn.first..v_dtcodexpn.last loop
                    v_item4  := v_numitem4;
                    v_item5  := v_dtcodexpn(i);
                    v_item7  := v_dtcodexpn(j);
                    v_item8  := v_dtcodexpn(j)||' - '||v_desc_codexpn(j);
                    if i = j then
                        v_item10 := v_codexpn_val(v_dtcodexpn(i));
                    else
                        v_item10 := 0;
                    end if;
                      begin
                        insert into ttemprpt
                          (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31)
                        values
                          (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31 );
                      exception when dup_val_on_index then
                        rollback;
                        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                        return;
                      end;
                      v_numseq := v_numseq + 1;
                end loop;
                v_numitem4 := v_numitem4 + 1;
            end loop;

        elsif p_flgreport = 3 then
            v_item6       := get_label_name('HRTR78X4', global_v_lang, '10');
            for v_row in 1..obj_row.count loop
              obj_data      := hcm_util.get_json(obj_row, to_char(v_row - 1));
              if get_label_name('HRTR78X4', global_v_lang, '80') = hcm_util.get_string(obj_data,'gen') then
                  continue;
              end if;
              v_dtcodcours.extend();
              v_dtcodcours(v_dtcodcours.last) := hcm_util.get_string(obj_data,'codcourse');
            end loop;

            v_dtcodcours := v_dtcodcours multiset intersect distinct v_dtcodcours;

            for i in 1..v_dtcodcours.count loop
                  v_codcours_val(v_dtcodcours(i)) := 0;
            end loop;

            for v_row in 1..obj_row.count loop
                  obj_data      := hcm_util.get_json(obj_row, to_char(v_row - 1));
                  if get_label_name('HRTR78X4', global_v_lang, '80') = hcm_util.get_string(obj_data,'gen') then
                      v_item4       := v_numitem4;
                      v_item5       := hcm_util.get_string(obj_data,'month_short');
                      for i in v_dtcodcours.first..v_dtcodcours.last loop
                          v_item7  := v_dtcodcours(i);
                          v_item8  := v_dtcodcours(i)||' - '||get_tcourse_name(v_dtcodcours(i), global_v_lang);
                          v_item10 := v_codcours_val(v_dtcodcours(i));
                          begin
                            insert into ttemprpt
                              (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31)
                            values
                              (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31 );
                          exception when dup_val_on_index then
                            rollback;
                            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                            return;
                          end;
                          v_numseq := v_numseq + 1;
                      end loop;
                      v_numitem4 := v_numitem4 + 1;
                      for i in 1..v_dtcodcours.count loop
                          v_codcours_val(v_dtcodcours(i)) := 0;
                     end loop;
                  else
                      for i in v_dtcodcours.first..v_dtcodcours.last loop
                          if v_dtcodcours(i) = hcm_util.get_string(obj_data,'codcourse') then
                             v_codcours_val(v_dtcodcours(i)) := hcm_util.get_string(obj_data,'expenses');
                          end if;
                      end loop;
                  end if;
            end loop;
        end if;
    end gen_graph;

END HRTR78X;


/

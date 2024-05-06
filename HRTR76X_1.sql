--------------------------------------------------------
--  DDL for Package Body HRTR76X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR76X" AS

      procedure initial_value(json_str_input in clob) as
            json_obj    json;
        begin
            json_obj            := json(json_str_input);

            global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
            global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
            global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');

            json_params         := hcm_util.get_json(json_obj, 'hcmhrtr76x');
            p_codcompy          := hcm_util.get_string(json_obj,'codcompy');
            p_dteyear           := hcm_util.get_string(json_obj, 'dteyear');

            hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        end initial_value;

     procedure get_index_month (json_str_input in clob, json_str_output out clob) AS
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
      END get_index_month;

      procedure gen_index_month (json_str_output out clob) AS
            obj_data      json;
            obj_row       json;
            json_obj_graph json  := json();
            v_codcomp     varchar2(40 char);
            v_rcnt        number :=0;
            v_sumytd      number :=0;
            v_budget      number :=0;
            v_sumamt      number :=0;
            v_chkcodcompy number :=0;
            v_flg_exist   boolean := false;
            v_flg_secure  boolean := false;
            v_flg_secure2  boolean := false;
            v_flg_permission     boolean := false;
            type array_month is varray(12) of varchar2(3);
            month array_month := array_month('jan', 'fab', 'mar','apr','may','jun','jul','aug','sep','oct','nov','dec');

             cursor c1 is
                select distinct codcomp
                 from thistrnn
                where codcomp like p_codcompy||'%'
                  and dteyear = p_dteyear
                  and codtparg = '2';

             cursor c2 is
                select dtemonth,sum(amtcost) sumamt
                 from thistrnn
                where codcomp like v_codcomp||'%'
                  and dteyear = p_dteyear
                  and codtparg = '2'
             group by dtemonth
             order by to_number(dtemonth);
        begin
            select count(codcompy) into v_chkcodcompy
                   from tcompny
                  where codcompy like p_codcompy||'%';

            if v_chkcodcompy = 0 then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;

            for r1 in c1 loop
                v_flg_exist := true;
                exit;
            end loop;

            if not v_flg_exist then
                param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THISTRNN');
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

                obj_row := json();
                for r1 in c1 loop
                    v_flg_secure2 := secur_main.secur7(r1.codcomp, global_v_coduser);
                    if v_flg_secure2 then
                        v_flg_permission := true;
                        v_codcomp := r1.codcomp;
                        v_rcnt := v_rcnt + 1;
                        obj_data := json();
                    for i in 1..month.count loop
                        obj_data.put(month(i), 0);
                    end loop;
                        obj_data.put('codcomp', get_codcomp_bylevel(r1.codcomp, 10 , '-'));
                        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
                    for r2 in c2 loop
                        select sum(bugtrout) into v_budget
                          from ttrnbudg
                         where dteyear = p_dteyear
                           and r1.codcomp like codcomp||'%';
                        v_sumytd := v_sumytd + r2.sumamt;
                        if r2.dtemonth = '1' then
                            obj_data.put('jan', r2.sumamt);
                        elsif r2.dtemonth = '2' then
                            obj_data.put('fab', r2.sumamt);
                        elsif r2.dtemonth = '3' then
                            obj_data.put('mar', r2.sumamt);
                        elsif r2.dtemonth = '4' then
                            obj_data.put('apr', r2.sumamt);
                        elsif r2.dtemonth = '5' then
                            obj_data.put('may', r2.sumamt);
                        elsif r2.dtemonth = '6' then
                            obj_data.put('jun', r2.sumamt);
                        elsif r2.dtemonth = '7' then
                            obj_data.put('jul', r2.sumamt);
                        elsif r2.dtemonth = '8' then
                            obj_data.put('aug', r2.sumamt);
                        elsif r2.dtemonth = '9' then
                            obj_data.put('sep', r2.sumamt);
                        elsif r2.dtemonth = '10' then
                            obj_data.put('oct', r2.sumamt);
                        elsif r2.dtemonth = '11' then
                            obj_data.put('nov', r2.sumamt);
                        elsif r2.dtemonth = '12' then
                            obj_data.put('dec', r2.sumamt);
                        end if;
                        obj_data.put('ytd', v_sumytd);
                        obj_data.put('budget', v_budget);
                    end loop;
                        v_sumytd := 0;
                        obj_row.put(to_char(v_rcnt-1),obj_data);
                    end if;
                end loop;

            if not v_flg_permission and v_flg_exist then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;

            json_obj_graph := obj_row;
            gen_graph(json_obj_graph);
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      END gen_index_month;

     procedure get_index_costcenter (json_str_input in clob, json_str_output out clob) AS
         begin
            initial_value(json_str_input);
            if param_msg_error is null then
              gen_index_costcenter(json_str_output);
            else
              json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            end if;

      exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      END get_index_costcenter;


      procedure gen_index_costcenter (json_str_output out clob) AS
            obj_data      json;
            obj_row       json;
            json_obj_graph json  := json();
            v_rcnt        number :=0;
            v_budget      number :=0;
            v_flg_exist   boolean := false;
            v_flg_secure  boolean := false;
            v_flg_secure2  boolean := false;
            v_flg_permission     boolean := false;

            cursor c1 is
                select a.codcomp,count(codempid)count_codempid,sum(amtcost)sumamt,b.costcent
                 from thistrnn a
            left join tcenter b on a.codcomp = b.codcomp
                where a.codcomp like p_codcompy||'%'
                  and dteyear = p_dteyear
                  and codtparg = '2'
             group by a.codcomp,b.costcent
             order by a.codcomp,b.costcent;

        begin
            for r1 in c1 loop
                v_flg_exist := true;
                exit;
            end loop;

            if not v_flg_exist then
                param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THISTRNN');
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

              obj_row := json();
              for r1 in c1 loop
                    v_flg_secure2 := secur_main.secur7(r1.codcomp, global_v_coduser);
                    if v_flg_secure2 then
                        v_flg_permission := true;
                        v_rcnt := v_rcnt + 1;
                        obj_data := json();
                        obj_data.put('codcomp', get_codcomp_bylevel(r1.codcomp, 10 , '-'));
                        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
                        obj_data.put('costcent', r1.costcent);
                        obj_data.put('desc_costcent', get_tcoscent_name(r1.costcent, global_v_lang));
                        obj_data.put('amount', r1.sumamt);
                        obj_data.put('qtytrnn', r1.count_codempid);
                        obj_row.put(to_char(v_rcnt-1),obj_data);
                    end if;
              end loop;

              if not v_flg_permission and v_flg_exist then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
              end if;

            json_obj_graph := obj_row;
            gen_graph(json_obj_graph);
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
      exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      END gen_index_costcenter;


      procedure gen_graph(obj_row in json) as
        obj_data    json;
        obj_data2   json;
        v_codempid  ttemprpt.codempid%type := global_v_codempid;
        v_codapp    ttemprpt.codapp%type := 'HRTR76X';
        v_numseq    ttemprpt.numseq%type := 1;
        v_item1     ttemprpt.item1%type;
        v_item2     ttemprpt.item2%type;
        v_item3     ttemprpt.item3%type;
        v_item4     ttemprpt.item4%type;
        v_item5     ttemprpt.item5%type;
        v_item6     ttemprpt.item6%type;
        v_item7     ttemprpt.item7%type;
        v_item8     ttemprpt.item8%type;
        v_item9     ttemprpt.item9%type := get_label_name('HRTR76XC1', global_v_lang, '230');
        v_item10    ttemprpt.item10%type;
        v_item31    ttemprpt.item31%type;

        v_count         number :=1;
        v_numcodcomp     number := 1;
        v_flg            number;
        v_year           thistrnn.dteyear%type;
        v_numitem4       number := 1;
        type array_month is varray(12) of number;
        v_array_month array_month := array_month(0,0,0,0,0,0,0,0,0,0,0,0);

        type arr_month is varray(12) of varchar2(3);
        month arr_month := arr_month('jan', 'fab', 'mar','apr','may','jun','jul','aug','sep','oct','nov','dec');
        month_dp arr_month := arr_month();

        type t_month_num is table of number;
        v_month_num t_month_num := t_month_num();

    begin
        v_flg := hcm_util.get_string(json_params,'reportType');
        v_item31 := get_label_name('HRTR76XC3', global_v_lang, v_flg||'0');

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

        if v_flg = '1' then
          for v_row in 1..obj_row.count loop
              obj_data   := hcm_util.get_json(obj_row, to_char(v_row - 1));
              for i in 1..month.count loop
                 v_array_month(i) := v_array_month(i) + hcm_util.get_string(obj_data,month(i));
              end loop;
          end loop;
           for i in 1..month.count loop
                    if v_array_month(i) > 0 then
                        month_dp.extend();
                        month_dp(v_count) := month(i);
                        v_month_num.extend();
                        v_month_num(v_count) := i;
                        v_count := v_count + 1;
                    end if;
           end loop;
            for i in 1..month_dp.count loop
                for v_row in 1..obj_row.count loop
                   obj_data   := hcm_util.get_json(obj_row, to_char(v_row - 1));
                   v_item1       := null;
                   v_item2       := null;
                   v_item3       := null;
                   v_item4       := lpad(v_numitem4, 2, '0');
                   v_item5       := get_tlistval_name('NAMMTHABB', v_month_num(i) ,global_v_lang);
                   v_item6       := null;
                   v_item7       := hcm_util.get_string(obj_data,'codcomp');
                   v_item8       := hcm_util.get_string(obj_data,'desc_codcomp');
                   v_item10      := hcm_util.get_string(obj_data,month_dp(i));
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

        else
             for i in 1..obj_row.count loop
                   obj_data   := hcm_util.get_json(obj_row, to_char(i - 1));
                   v_item5       := hcm_util.get_string(obj_data,'desc_codcomp');
                for j in 1..obj_row.count loop
                   obj_data2   := hcm_util.get_json(obj_row, to_char(j - 1));
                   v_item1       := null;
                   v_item2       := null;
                   v_item3       := null;
                   v_item4       := v_numitem4;
                   v_item6       := null;
                   v_item7       := hcm_util.get_string(obj_data2,'codcomp');
                   v_item8       := hcm_util.get_string(obj_data2,'desc_codcomp');

                   if i = j then
                        v_item10      := hcm_util.get_string(obj_data2,'amount');
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
        end if;
    end gen_graph;

END HRTR76X;

/

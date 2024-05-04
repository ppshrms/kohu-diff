--------------------------------------------------------
--  DDL for Package Body HRBF1SX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1SX" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        p_codcomp         := upper(hcm_util.get_string(json_obj,'codcomp'));
        p_compgrp         := upper(hcm_util.get_string(json_obj,'compgrp'));
        p_comp_level      := (to_number(hcm_util.get_string(json_obj,'comp_level')));
        p_dte_start       := to_date(hcm_util.get_string(json_obj,'dte_start'),'dd/mm/yyyy');
        p_dte_end         := to_date(hcm_util.get_string(json_obj,'dte_end'),'dd/mm/yyyy');
        p_coddc           := upper(hcm_util.get_string(json_obj,'coddc'));
        p_codrel          := upper(hcm_util.get_string(json_obj,'codrel'));

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    end initial_value;

    procedure check_index as
        v_temp          varchar2( 1 char );
    begin

        if p_comp_level is null or (p_dte_start is null and p_dte_end is not null) or (p_dte_start is not null and p_dte_end is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_codcomp is not null then
            -- check HR3007
            param_msg_error := hcm_secur.secur_codcomp( global_v_coduser, global_v_lang, p_codcomp);
            if param_msg_error is not null then
                return;
            end if;
        end if;

        if p_dte_start > p_dte_end then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;

        if p_compgrp is not null then
            begin
                select 'X' into v_temp
                  from tcompgrp
                 where codcodec = p_compgrp;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPGRP');
                return;
            end;
        end if;

        if p_coddc is not null then
            begin
                select 'X' into v_temp
                  from tdcinf
                 where codcodec = p_coddc;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TDCINF');
                return;
            end;
        end if;

        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

    end check_index;

    procedure create_graph_data_count(v_numseq number, v_item2 varchar2, v_codcomp varchar2,v_value_emp varchar2,v_value_fam varchar2) as
        v_item1     ttemprpt.item1%type;
        v_item5     ttemprpt.item5%type;
        v_item6     ttemprpt.item6%type;
        v_item8     ttemprpt.item8%type;
        v_item9     ttemprpt.item9%type;
        v_item31    ttemprpt.item31%type;
    begin
        v_item1     := get_label_name('HRBF1SXP1',global_v_lang,'90'); -- Number of Drawdowns	จำนวนคนเบิก
        v_item5     := get_tcenter_name(get_compful(v_codcomp),global_v_lang);
        v_item6     := get_label_name('HRBF1SXP1',global_v_lang,'80'); -- Department	หน่วยงาน
        v_item31    := get_tappprof_name('HRBF1SX', '2',global_v_lang);
        v_item8     := get_label_name('HRBF1SXP1',global_v_lang,'100');  -- Employee	พนักงาน
        insert into ttemprpt (codempid,codapp,numseq,item1,item2,item4,item5,item6,item7,item8,item9,item10,item31)
             values (global_v_codempid,'HRBF1SX',v_numseq,v_item1,v_item2,v_codcomp,v_item5,v_item6,'1',v_item8,v_item1,v_value_emp,v_item31);

        v_item8     := get_label_name('HRBF1SXP1',global_v_lang,'110');
        insert into ttemprpt (codempid,codapp,numseq,item1,item2,item4,item5,item6,item7,item8,item9,item10,item31)
             values (global_v_codempid,'HRBF1SX',v_numseq+1,v_item1,v_item2,v_codcomp,v_item5,v_item6,'2',v_item8,v_item1,v_value_fam,v_item31);
    end create_graph_data_count;

    procedure create_graph_data_sum(v_numseq number, v_item2 varchar2, v_codcomp varchar2,v_value_emp varchar2,v_value_fam varchar2) as
        v_item1     ttemprpt.item1%type;
        v_item5     ttemprpt.item5%type;
        v_item6     ttemprpt.item6%type;
        v_item8     ttemprpt.item8%type;
        v_item9     ttemprpt.item9%type;
        v_item31    ttemprpt.item31%type;
    begin
        v_item1     := get_label_name('HRBF1SXP1',global_v_lang,'120'); -- Withdrawal Amount	จำนวนเงินเบิก
        v_item5     := get_tcenter_name(get_compful(v_codcomp),global_v_lang);
        v_item6     := get_label_name('HRBF1SXP1',global_v_lang,'80'); -- Department	หน่วยงาน
        v_item31    := get_tappprof_name('HRBF1SX', '2',global_v_lang);
        v_item8     := get_label_name('HRBF1SXP1',global_v_lang,'100'); -- Employee	พนักงาน
        insert into ttemprpt (codempid,codapp,numseq,item1,item2,item4,item5,item6,item7,item8,item9,item10,item31)
             values (global_v_codempid,'HRBF1SX',v_numseq,v_item1,v_item2,v_codcomp,v_item5,v_item6,'1',v_item8,v_item1,v_value_emp,v_item31);

        v_item8     := get_label_name('HRBF1SXP1',global_v_lang,'110');
        insert into ttemprpt (codempid,codapp,numseq,item1,item2,item4,item5,item6,item7,item8,item9,item10,item31)
             values (global_v_codempid,'HRBF1SX',v_numseq+1,v_item1,v_item2,v_codcomp,v_item5,v_item6,'2',v_item8,v_item1,v_value_fam,v_item31);
    end create_graph_data_sum;

    procedure gen_index(json_str_output out clob) as
        obj_rows                json;
        obj_rows_sum            json;
        obj_head                json;
        v_row                   number := 0;
        v_row_graph             number := 0;
        v_emp_count             number := 0;
        v_nemp_count            number := 0;
        v_emp_sum               number := 0;
        v_nemp_sum              number := 0;
        v_total_emp_count       number := 0;
        v_total_nemp_count      number := 0;
        v_total_emp_sum         number := 0;
        v_total_nemp_sum        number := 0;
        v_all_total_emp_count   number := 0;
        v_all_total_nemp_count  number := 0;
        v_all_total_emp_sum     number := 0;
        v_all_total_nemp_sum    number := 0;
        v_last_coddc            tclnsinf.coddc%type;

        v_cur_codcompsub        tclnsinf.codcomp%type;
        v_cur_coddc             tclnsinf.coddc%type;

        cursor c1 is
            select  a.coddc, hcm_util.get_codcomp_level(a.codcomp,p_comp_level) codcompsub
              from tclnsinf a,tcenter b
             where a.codcomp = b.codcomp
               and ( b.compgrp = nvl(p_compgrp, b.compgrp) or nvl(p_compgrp, b.compgrp) is null)
               and b.codcomp like nvl(p_codcomp||'%', b.codcomp)
               and dtereq between nvl(p_dte_start, dtereq) and nvl(p_dte_end,dtereq)
               and coddc = nvl(p_coddc, coddc)
          group by a.coddc, hcm_util.get_codcomp_level(a.codcomp,p_comp_level)
          order by a.coddc, hcm_util.get_codcomp_level(a.codcomp,p_comp_level);

        cursor c_emp_count is
            select a.codcomp,a.codempid
             from tclnsinf a, tcenter b
            where a.codcomp = b.codcomp
              and hcm_util.get_codcomp_level(b.codcomp,p_comp_level) = v_cur_codcompsub
              and coddc = v_cur_coddc
              and dtereq between nvl(p_dte_start, dtereq) and nvl(p_dte_end,dtereq)
              and a.codrel = 'E'
         order by coddc, hcm_util.get_codcomp_level(v_cur_codcompsub,p_comp_level);

        cursor c_nemp_count is
            select a.codcomp,a.codempid
              from tclnsinf a,tcenter b
             where a.codcomp = b.codcomp
               and hcm_util.get_codcomp_level(b.codcomp,p_comp_level) = v_cur_codcompsub
               and coddc = v_cur_coddc
               and dtereq between nvl(p_dte_start, dtereq) and nvl(p_dte_end,dtereq)
               and a.codrel <> 'E'
         order by coddc, hcm_util.get_codcomp_level(v_cur_codcompsub,p_comp_level);

        cursor c_emp_sum is
            select  a.codcomp, a.codempid, a.amtalw
              from tclnsinf a,tcenter b
             where a.codcomp = b.codcomp
               and hcm_util.get_codcomp_level(b.codcomp,p_comp_level) = v_cur_codcompsub
               and coddc = v_cur_coddc
               and dtereq between nvl(p_dte_start, dtereq) and nvl(p_dte_end,dtereq)
               and a.codrel = 'E'
         order by coddc, hcm_util.get_codcomp_level(v_cur_codcompsub,p_comp_level);

        cursor c_nemp_sum is
            select  a.codcomp, a.codempid,a.amtalw
              from tclnsinf a,tcenter b
             where a.codcomp = b.codcomp
               and hcm_util.get_codcomp_level(b.codcomp,p_comp_level) = v_cur_codcompsub
               and coddc = v_cur_coddc
               and dtereq between nvl(p_dte_start, dtereq) and nvl(p_dte_end,dtereq)
               and a.codrel <> 'E'
         order by coddc, hcm_util.get_codcomp_level(v_cur_codcompsub,p_comp_level);

    begin
        delete from ttemprpt
              where codapp = 'HRBF1SX'
                and codempid = global_v_codempid;
        commit;
        obj_head := json();
        for i in c1 loop

            if secur_main.secur7(p_codcomp, global_v_coduser) then
                v_row := v_row+1;
                obj_rows := json();
                if v_last_coddc is null then
                    v_last_coddc := i.coddc;
                end if;
                v_cur_coddc       := i.coddc;
                v_cur_codcompsub  := i.codcompsub;
                obj_rows.put('coddc',i.coddc);
                obj_rows.put('coddcname',get_tdcinf_name(i.coddc,global_v_lang));
                obj_rows.put('codcomp',i.codcompsub);
                obj_rows.put('codcompname',get_tcenter_name(i.codcompsub,global_v_lang));

                v_emp_count := 0;
                for j in c_emp_count loop
                    if secur_main.secur2(j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = true then
                        v_emp_count := v_emp_count+1;
                    end if;
                end loop;
                obj_rows.put('empnumdra',v_emp_count);

                v_nemp_count := 0;
                for j in c_nemp_count loop
                    if secur_main.secur2(j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = true then
                        v_nemp_count := v_nemp_count+1;
                    end if;
                end loop;
                obj_rows.put('faminumdra',v_nemp_count);

                v_emp_sum := 0;
                for j in c_emp_sum loop
                    if secur_main.secur2(j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = true then
                        v_emp_sum := v_emp_sum+j.amtalw;
                    end if;
                end loop;
                obj_rows.put('empnumwith',v_emp_sum);

                v_nemp_sum := 0;
                for j in c_nemp_sum loop
                    if secur_main.secur2(j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = true then
                        v_nemp_sum := v_nemp_sum+j.amtalw;
                    end if;
                end loop;
                obj_rows.put('faminumwith',v_nemp_sum);

                if v_last_coddc = i.coddc then
                    v_total_emp_count    := v_total_emp_count + v_emp_count;
                    v_total_nemp_count   := v_total_nemp_count + v_nemp_count;
                    v_total_emp_sum      := v_total_emp_sum + v_emp_sum;
                    v_total_nemp_sum     := v_total_nemp_sum + v_nemp_sum;
                else
                    obj_rows_sum := json();
                    obj_rows_sum.put('coddc',v_last_coddc);
                    obj_rows_sum.put('codcompname',get_label_name('HRBF1SXP2',global_v_lang,'180'));
                    obj_rows_sum.put('empnumdra',v_total_emp_count);
                    obj_rows_sum.put('faminumdra',v_total_nemp_count);
                    obj_rows_sum.put('empnumwith',v_total_emp_sum);
                    obj_rows_sum.put('faminumwith',v_total_nemp_sum);
                    obj_head.put(v_row-1,obj_rows_sum);
                    v_last_coddc        := i.coddc;
                    v_total_emp_count   := v_emp_count;
                    v_total_nemp_count  := v_nemp_count;
                    v_total_emp_sum     := v_emp_sum;
                    v_total_nemp_sum    := v_nemp_sum;
                    v_row               := v_row+1;
                end if;
                v_all_total_emp_count   := v_all_total_emp_count + v_emp_count;
                v_all_total_nemp_count  := v_all_total_nemp_count + v_nemp_count;
                v_all_total_emp_sum     := v_all_total_emp_sum + v_emp_sum;
                v_all_total_nemp_sum    := v_all_total_nemp_sum + v_nemp_sum;
                obj_head.put(v_row-1,obj_rows);

                create_graph_data_count( v_row_graph, get_tdcinf_name(i.coddc,global_v_lang),i.codcompsub,v_emp_count,v_nemp_count);
                v_row_graph := v_row_graph+2;

                create_graph_data_sum( v_row_graph, get_tdcinf_name(i.coddc,global_v_lang),i.codcompsub,v_emp_sum, v_nemp_sum);
                v_row_graph := v_row_graph+2;
            end if;
        end loop;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TACCMEXP');
        else
            v_row := v_row+1;
            obj_rows_sum := json();
            obj_rows_sum.put('coddc',v_last_coddc);
            obj_rows_sum.put('codcompname',get_label_name('HRBF1SXP2',global_v_lang,'180'));
            obj_rows_sum.put('empnumdra',v_total_emp_count);
            obj_rows_sum.put('faminumdra',v_total_nemp_count);
            obj_rows_sum.put('empnumwith',v_total_emp_sum);
            obj_rows_sum.put('faminumwith',v_total_nemp_sum);
            obj_head.put(v_row-1,obj_rows_sum);

            v_row := v_row+1;
            obj_rows_sum.put('coddc',p_coddc);
            obj_rows_sum.put('codcompname',get_label_name('HRBF1SXP2',global_v_lang,'190'));
            obj_rows_sum.put('empnumdra',v_all_total_emp_count);
            obj_rows_sum.put('faminumdra',v_all_total_nemp_count);
            obj_rows_sum.put('empnumwith',v_all_total_emp_sum);
            obj_rows_sum.put('faminumwith',v_all_total_nemp_sum);
            obj_head.put(v_row-1,obj_rows_sum);
        end if;

        dbms_lob.createtemporary(json_str_output, true);
        obj_head.to_clob(json_str_output);

    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure gen_detail_emp(json_str_output out clob) as
        obj_rows        json;
        obj_data        json;
        obj_result      json;

        v_row           number := 0;

        cursor c1detail is
            select a.codcomp,coddc, codempid, namsick, codrel, typpatient, dtereq, dtecrest, dtecreen, amtalw, codcln
              from tclnsinf a
             where a.codcomp like  p_codcomp||'%'
              and a.coddc = p_coddc
              and dtereq between nvl(p_dte_start, dtereq) and nvl(p_dte_end,dtereq)
              and a.codrel = 'E'
         order by coddc, codempid;

    begin
        obj_rows := json();
        for i in c1detail loop
            if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = true then
                v_row := v_row+1;
                obj_data := json();
                obj_data.put('coddc',i.coddc);
                obj_data.put('coddcdetail',get_tdcinf_name(i.coddc,global_v_lang));
                obj_data.put('image',get_emp_img(i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('empname',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('namsick',i.namsick);
                obj_data.put('codrel',i.codrel);
                obj_data.put('typpatient',get_tlistval_name('TYPPATIENT', i.typpatient,global_v_lang));
                obj_data.put('typrelate',get_tlistval_name('TTYPRELATE', i.codrel,global_v_lang));
                obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
                obj_data.put('dtecrest',to_char(i.dtecrest,'dd/mm/yyyy'));
                obj_data.put('dtecreen',to_char(i.dtecreen,'dd/mm/yyyy'));
                obj_data.put('codcln',get_tclninf_name(i.codcln,global_v_lang));
                obj_data.put('amtalw', i.amtalw);
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_detail_emp;

    procedure gen_detail_nemp(json_str_output out clob) as
        obj_rows        json;
        obj_data        json;
        obj_result      json;

        v_row           number := 0;

        cursor c1detail is
            select a.codcomp,coddc, codempid, namsick, codrel, typpatient, dtereq, dtecrest, dtecreen, amtalw, codcln
              from tclnsinf a
             where a.codcomp  like  p_codcomp||'%'
              and a.coddc = p_coddc
              and dtereq between nvl(p_dte_start, dtereq) and nvl(p_dte_end,dtereq)
              and a.codrel <> 'E'
         order by coddc, codempid;

    begin
        obj_rows := json();
        for i in c1detail loop
            if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = true then
                v_row := v_row+1;
                obj_data := json();
                obj_data.put('coddc',i.coddc);
                obj_data.put('coddcdetail',get_tdcinf_name(i.coddc,global_v_lang));
                obj_data.put('image',get_emp_img(i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('empname',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('namsick',i.namsick);
                obj_data.put('codrel',i.codrel);
                obj_data.put('typpatient',get_tlistval_name('TYPPATIENT', i.typpatient,global_v_lang));
                obj_data.put('typrelate',get_tlistval_name('TTYPRELATE', i.codrel,global_v_lang));
                obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
                obj_data.put('dtecrest',to_char(i.dtecrest,'dd/mm/yyyy'));
                obj_data.put('dtecreen',to_char(i.dtecreen,'dd/mm/yyyy'));
                obj_data.put('codcln',get_tclninf_name(i.codcln,global_v_lang));
                obj_data.put('amtalw', i.amtalw);
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_detail_nemp;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
        v_temp varchar2(1);
    begin
        initial_value(json_str_input);

        if param_msg_error is null then
            if p_codrel = 'E' then
                gen_detail_emp(json_str_output);
            else
                gen_detail_nemp(json_str_output);
            end if;
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;


    procedure gen_detail_total_emp(json_str_output out clob) as
        obj_rows        json;
        obj_data        json;
        obj_result      json;

        v_row           number := 0;

        cursor c1detail is
            select coddc, codempid, namsick, codrel, typpatient, dtereq, dtecrest, dtecreen, amtalw, codcln, b.codcomp
              from tclnsinf a, tcenter b
             where a.codcomp like  p_codcomp||'%'
              and a.coddc = nvl(p_coddc, coddc)
              and a.codrel = 'E'
              and a.codcomp = b.codcomp
              and ( b.compgrp = nvl(p_compgrp, b.compgrp) or nvl(p_compgrp, b.compgrp) is null)
              and dtereq between nvl(p_dte_start, dtereq) and nvl(p_dte_end,dtereq)
         order by coddc, codempid;

    begin
        obj_rows := json();
        for i in c1detail loop
            if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = true then
                v_row := v_row+1;
                obj_data := json();
                obj_data.put('coddc',i.coddc);
                obj_data.put('coddcdetail',get_tdcinf_name(i.coddc,global_v_lang));
                obj_data.put('image',get_emp_img(i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('empname',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('namsick',i.namsick);
                obj_data.put('codrel',i.codrel);
                obj_data.put('typpatient',get_tlistval_name('TYPPATIENT', i.typpatient,global_v_lang));
                obj_data.put('typrelate',get_tlistval_name('TTYPRELATE', i.codrel,global_v_lang));
                obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
                obj_data.put('dtecrest',to_char(i.dtecrest,'dd/mm/yyyy'));
                obj_data.put('dtecreen',to_char(i.dtecreen,'dd/mm/yyyy'));
                obj_data.put('codcln',get_tclninf_name(i.codcln,global_v_lang));
                obj_data.put('amtalw', i.amtalw);
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_detail_total_emp;

    procedure gen_detail_total_nemp(json_str_output out clob) as
        obj_rows        json;
        obj_data        json;
        obj_result      json;

        v_row           number := 0;

        cursor c1detail is
            select a.codcomp, coddc, codempid, namsick, codrel, typpatient, dtereq, dtecrest, dtecreen, amtalw, codcln
              from tclnsinf a,tcenter b
             where a.codcomp = b.codcomp
              and ( b.compgrp = nvl(p_compgrp, b.compgrp) or nvl(p_compgrp, b.compgrp) is null)
              and a.codcomp  like  p_codcomp||'%'
              and dtereq between nvl(p_dte_start, dtereq) and nvl(p_dte_end,dtereq)
              and a.coddc = nvl(p_coddc, coddc)
              and a.codrel <> 'E'
         order by coddc, codempid;

    begin
        obj_rows := json();
        for i in c1detail loop
            if secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = true then
                v_row := v_row+1;
                obj_data := json();
                obj_data.put('coddc',i.coddc);
                obj_data.put('coddcdetail',get_tdcinf_name(i.coddc,global_v_lang));
                obj_data.put('image',get_emp_img(i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('empname',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('namsick',i.namsick);
                obj_data.put('codrel',i.codrel);
                obj_data.put('typpatient',get_tlistval_name('TYPPATIENT', i.typpatient,global_v_lang));
                obj_data.put('typrelate',get_tlistval_name('TTYPRELATE', i.codrel,global_v_lang));
                obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
                obj_data.put('dtecrest',to_char(i.dtecrest,'dd/mm/yyyy'));
                obj_data.put('dtecreen',to_char(i.dtecreen,'dd/mm/yyyy'));
                obj_data.put('codcln',get_tclninf_name(i.codcln,global_v_lang));
                obj_data.put('amtalw', i.amtalw);
                obj_data.put('amtalw', i.amtalw);
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_detail_total_nemp;

    procedure get_detail_total(json_str_input in clob, json_str_output out clob) as
        v_temp varchar2(1);
    begin
        initial_value(json_str_input);

        if param_msg_error is null then
            if p_codrel = 'E' then
                gen_detail_total_emp(json_str_output);
            else
                gen_detail_total_nemp(json_str_output);
            end if;
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail_total;

  procedure get_list_tsetcomp (json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_json_input    json_object_t;
    v_rcnt          number := 0;
    v_codcomp       tcenter.codcomp%type;

    cursor c_tsetcomp is
      select numseq
        from tsetcomp
       where nvl(qtycode,0) > 0
    order by numseq;
  begin
    initial_value(json_str_input);
    v_json_input    := json_object_t(json_str_input);
    v_codcomp       := hcm_util.get_string_t(v_json_input,'codcomp');
    obj_row         := json_object_t();
    for r1 in c_tsetcomp loop
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('comlevel', r1.numseq);
      if r1.numseq = 1 then
        obj_data.put('namecomlevel', get_label_name('SCRLABEL',global_v_lang,2250));
      else
        obj_data.put('namecomlevel', get_comp_label(v_codcomp,r1.numseq,global_v_lang));
      end if;

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

END HRBF1SX;


/

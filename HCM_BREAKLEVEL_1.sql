--------------------------------------------------------
--  DDL for Package Body HCM_BREAKLEVEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_BREAKLEVEL" is
    procedure initial_value(json_obj in json_object_t) is
    begin
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        p_codapp          := hcm_util.get_string_t(json_obj,'codapp');
    end initial_value;

    --start function used for get_breaklevel only
    function get_sumrecord(param_sum in json_object_t) return varchar2 is
        v_sumrecord    varchar2(1 char);
    begin
        v_sumrecord := nvl(hcm_util.get_string_t(param_sum,'sumRecord'), 'N');
        if v_sumrecord = 'A' then
            v_sumrecord := 'Y';
        end if;

        return v_sumrecord;
    end;
    function get_sumamount(param_sum in json_object_t) return varchar2 is
        v_sumamount    varchar2(1 char);
    begin
        if hcm_util.get_string_t(param_sum,'sumRecord') = 'A' then
            v_sumamount := 'Y';
        elsif hcm_util.get_string_t(param_sum,'sumRecord') = 'Y' then
            v_sumamount := 'N';
        else
            v_sumamount := 'Y';
        end if;

        return v_sumamount;
    end;
    function get_sumbreak(param_sum in json_object_t) return varchar2 is
        v_sumitem       varchar2(50 char);
        v_sumbreak      varchar2(1 char);
    begin
        v_sumitem   := hcm_util.get_string_t(param_sum,'sumItem');
        v_sumbreak  := hcm_util.get_string_t(param_sum,'sumBreak');
        if hcm_util.get_string_t(param_sum,'sumBreak') is null then
            if v_sumitem is null then
                v_sumbreak := 'Y';
            else
                v_sumbreak := 'N';
            end if;
        else
            if upper(hcm_util.get_string_t(param_sum,'sumBreak')) = 'Y' or upper(hcm_util.get_string_t(param_sum,'sumBreak')) = 'N' then
                v_sumbreak := hcm_util.get_string_t(param_sum,'sumBreak');
            else
                v_sumbreak := 'N';
            end if;
        end if;

        return v_sumbreak;
    end;
    function get_flgsum(param_sum in json_object_t) return varchar2 is
        v_flgsum    varchar2(1 char);
    begin
        if param_sum.get_size > 0 and hcm_util.get_json_t(param_sum, 'fields').get_size > 0 then
            v_flgsum := hcm_util.get_string_t(param_sum,'flgsum');
        else
            if hcm_util.get_string_t(param_sum,'sumRecord') = 'Y' then v_flgsum := 'Y'; else v_flgsum := 'N'; end if;
        end if;

        return v_flgsum;
    end;
    function get_desc_sum_disp_field(param_sum in json_object_t, param_break in json_object_t) return varchar2 is
        v_desc_sum_disp_field   varchar2(50 char);
    begin
        v_desc_sum_disp_field := nvl(hcm_util.get_string_t(param_sum,'desc_sum_disp_field'), hcm_util.get_string_t(param_break,'desc_company_disp_field'));

        return v_desc_sum_disp_field;
    end;
    function get_disp_sum_record_field(param_sum in json_object_t, param_break in json_object_t) return varchar2 is
        v_disp_sum_record_field   varchar2(50 char);
    begin
        v_disp_sum_record_field     := nvl(hcm_util.get_string_t(param_sum,'disp_sum_record_field'), hcm_util.get_string_t(param_break,'desc_company_disp_field'));

        return v_disp_sum_record_field;
    end;
    function get_qtyavgwk (p_codempid in varchar2, p_codcomp in varchar2) return number is
        v_qtyavgwk    number;
        v_codcomp     varchar2(100 char);
        v_codcompy    varchar2(100 char);
    begin
        if p_codcomp is not null then
            v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
        elsif p_codempid is not null then
            begin
                select codcomp into v_codcomp
                  from temploy1
                 where codempid = p_codempid;
                v_codcompy := hcm_util.get_codcomp_level(v_codcomp,1);
            exception when no_data_found then
                v_codcompy := '';
            end;
        else
            begin
                select codcomp into v_codcomp
                  from temploy1
                 where codempid = global_v_codempid;
                v_codcompy := hcm_util.get_codcomp_level(v_codcomp,1);
            exception when no_data_found then
                v_codcompy := '';
            end;
        end if;

        begin
            select qtyavgwk into v_qtyavgwk
            from tcontral
            where codcompy = v_codcompy
              and dteeffec = (select max(dteeffec)
                                from tcontral
                               where codcompy = v_codcompy
                                 and dteeffec <= sysdate);
        exception when no_data_found then
            v_qtyavgwk := 480;
        end;
        return v_qtyavgwk;
    end;
    function conv_dhm_to_min(p_value in varchar2,p_qtyavhwk in number,p_type in varchar2) return number is
        v_day   number;
        v_hr    number;
        v_min   number;
        o_min   number;
    begin
        if p_type = '1' then
            v_day := nvl(to_number(regexp_substr(p_value,'[^:]+',1,1) ),0);
            v_hr  := nvl(to_number(regexp_substr(p_value,'[^:]+',1,2) ),0);
            v_min := nvl(to_number(regexp_substr(p_value,'[^:]+',1,3) ),0);
            o_min := v_day * p_qtyavhwk + v_hr * 60 + v_min;
        else
            v_hr  := nvl(to_number(regexp_substr(p_value,'[^:]+',1,1) ),0);
            v_min := nvl(to_number(regexp_substr(p_value,'[^:]+',1,2) ),0);
            o_min := v_hr * 60 + v_min;
        end if;
        return o_min;
    end;
    function get_min_field_data(p_min_field_data in varchar2, p_sum_type in varchar2, v_day_break in number) return number is
        v_min_field_data       number := 0;
    begin
        if p_sum_type is null then
          v_min_field_data := nvl(to_number(replace(p_min_field_data,',',null)), 0);
        else
            if upper(p_sum_type) = 'DD:HH:MM' then
                v_min_field_data := conv_dhm_to_min(replace(p_min_field_data,',',''), v_day_break, 1);
            elsif upper(p_sum_type) = 'HH:MM' then
                v_min_field_data := conv_dhm_to_min(replace(p_min_field_data,',',''), v_day_break, 2);
            end if;
        end if;

        return v_min_field_data;
    end;
    function conv_min_to_dhm(p_value in number,p_qtyavhwk in number,p_type in varchar2) return varchar2 is
        v_day   number;
        v_hr    number;
        v_min   number;
    begin
        if p_type = '1' then
            v_day := floor(p_value / p_qtyavhwk);
            v_hr  := floor( (p_value - v_day * p_qtyavhwk) / 60);
            v_min := ( p_value - v_day * p_qtyavhwk ) - ( v_hr * 60 );
            return to_char(v_day,'fm999,990') || ':' || lpad(to_char(v_hr),2,'0') || ':' || lpad(to_char(v_min),2,'0');
        else
            v_hr  := floor(p_value / 60);
            v_min := ( p_value - v_hr * 60 );
            return to_char(v_hr,'fm999,990') || ':' || lpad(to_char(v_min),2,'0');
        end if;
    end;
    function get_display_field_data(p_display_field_data in varchar2, p_disp_type in varchar2, v_day_break in number) return varchar2 is
        v_disp_field_data       varchar2(1000 char);
    begin
        if p_disp_type is null then
            --<<User37 #5969 11/06/2021 
                if instr(p_display_field_data,'.') > 0 then
                    v_disp_field_data := to_char(p_display_field_data,'fm999,999,999.99');
                else
                    v_disp_field_data := to_char(p_display_field_data,'fm999,999,999');
                end if;
            --v_disp_field_data := to_char(p_display_field_data);
            -->>User37 #5969 11/06/2021 
        else
            if upper(p_disp_type) = 'DD:HH:MM' then
                v_disp_field_data := conv_min_to_dhm(p_display_field_data, v_day_break, 1);
            elsif upper(p_disp_type) = 'HH:MM' then
                v_disp_field_data := conv_min_to_dhm(p_display_field_data, v_day_break, 2);
            end if;
        end if;
    return v_disp_field_data;
    end;
    procedure sumbreak_label_local(p_codcomp in varchar2, o_codcomp in varchar2, p_comlevel in number, v_total_sumbreak_label varchar2, v_setcomp_label_list in array_varchar, v_sum_qtycode_incremental_list in array_number, p_label out varchar2, p_desc out varchar2, p_pass out boolean) is
        v_codcompo              tcenter.codcomp%type;
        v_codcompn              tcenter.codcomp%type;
        v_compo                 varchar2(40 char);
        v_compn                 varchar2(40 char);
        v_sum_qty_code_current  number := 0;
        v_next_qtycode          number := 3;
    begin
        v_sum_qty_code_current := v_sum_qtycode_incremental_list(p_comlevel);
        if v_sum_qtycode_incremental_list.exists(p_comlevel + 1) then
            v_next_qtycode := v_sum_qtycode_incremental_list(p_comlevel + 1) - v_sum_qty_code_current;
        end if;

        v_codcompn := p_codcomp;
        v_codcompo := o_codcomp;
        v_compn := substr(v_codcompn, 1, v_sum_qty_code_current);
        v_compo := substr(v_codcompo, 1, v_sum_qty_code_current);

        p_label := null;
        p_desc  := null;
        p_pass  := false;
        if (v_compn <> v_compo and substr(v_codcompo, (v_sum_qty_code_current - 2), v_next_qtycode) <> '000') then
            p_label := ' ' || v_total_sumbreak_label;
            p_desc  := v_setcomp_label_list(p_comlevel);
            p_pass  := true;
        end if;
    end;
    procedure comp_label_local(p_codcomp in varchar2, o_codcomp in varchar2, p_comlevel in number, v_setcomp_label_list in array_varchar, v_sum_qtycode_incremental_list in array_number, p_label out varchar2, p_desc out varchar2, p_pass out boolean) is
        v_codcompo                  tcenter.codcomp%type;
        v_codcompn                  tcenter.codcomp%type;
        v_compo                     varchar2(40 char);
        v_compn                     varchar2(40 char);
        v_totoal_tsetcomp           number := 0;
        v_qtycode                   number := 0;
        v_sum_qtycode_previous      number := 0;
    begin
        v_totoal_tsetcomp := v_sum_qtycode_incremental_list.count;
        if p_comlevel <= 1 then
            v_sum_qtycode_previous   := 0;
        else
            v_sum_qtycode_previous   := v_sum_qtycode_incremental_list(p_comlevel - 1);
        end if;
        v_qtycode       := v_sum_qtycode_incremental_list(p_comlevel) - v_sum_qtycode_previous;

        v_codcompn      := p_codcomp;
        v_codcompo      := rpad(nvl(o_codcomp, ' '), 40, ' ');
        v_compn         := substr(p_codcomp,  v_sum_qtycode_previous + 1, v_qtycode);
        v_compo         := substr(v_codcompo, v_sum_qtycode_previous + 1, v_qtycode);

        p_label := null;
        p_desc  := null;
        p_pass  := false;
        if v_compn <> v_compo and v_compn <> lpad('0', v_qtycode, '0') then
            if p_comlevel <= v_totoal_tsetcomp then
                p_label := v_setcomp_label_list(p_comlevel);
                p_desc  := get_tcenter_name(substr(p_codcomp, 1, (v_qtycode + v_sum_qtycode_previous)), global_v_lang);
            end if;
            p_pass := true;
        end if;
    end;
    procedure initial_column(param_column       in json_object_t,
                             v_max_column       in number,
                             obj_data_temp      out json_object_t,
                             v_columns          out array_varchar) is

        param_column_row    json_object_t;
        v_sum_qtycode       number := 0;
    begin
        obj_data_temp := json_object_t();
        for v_column_index in 0..v_max_column - 1 loop
            param_column_row := hcm_util.get_json_t(param_column, to_char(v_column_index));
                v_columns(v_column_index) := hcm_util.get_string_t(param_column_row,'key');

            obj_data_temp.put(v_columns(v_column_index), '');
        end loop;
    end;
    --
    procedure initial_setcomp_label_list(param_level                      in json_object_t,
                                         v_codcompy                       in tcompny.codcompy%type,
                                         v_max_breaklevel                 out number,
                                         v_setcomp_label_list             out array_varchar,
                                         v_breaklevel                     out array_varchar,
                                         v_sum_qtycode_incremental_list   out array_number) is

        param_column_row    json_object_t;
        v_sum_qtycode       number := 0;
        v_unit_label        tapplscr.desclabele%type;
        cursor c_tsetcomp is
            select sc.numseq,
                   decode(global_v_lang ,'101',cc.namcente
                                        ,'102',cc.namcentt
                                        ,'103',cc.namcent3
                                        ,'104',cc.namcent4
                                        ,'105',cc.namcent5) namcent,
                   sc.qtycode
              from tsetcomp sc, tcompnyc cc
             where sc.numseq        = cc.comlevel(+)
               and cc.codcompy(+)   = v_codcompy
          order by sc.numseq;
    begin
        v_max_breaklevel  := 0;
        v_unit_label      := get_label_name('SCRLABEL',global_v_lang,2490);
        for r_tsetcomp in c_tsetcomp loop
            if r_tsetcomp.numseq = 1 then
              v_setcomp_label_list(r_tsetcomp.numseq) := get_label_name('SCRLABEL',global_v_lang,2250);
            else
              v_setcomp_label_list(r_tsetcomp.numseq) := nvl(r_tsetcomp.namcent,v_unit_label || to_char(r_tsetcomp.numseq));
            end if;
            v_sum_qtycode := v_sum_qtycode + r_tsetcomp.qtycode;
            v_sum_qtycode_incremental_list(r_tsetcomp.numseq) := v_sum_qtycode;

            v_breaklevel(r_tsetcomp.numseq) := hcm_util.get_string_t(param_level,'level' || to_char(r_tsetcomp.numseq));
            if v_breaklevel(r_tsetcomp.numseq) = 'Y' then
                v_max_breaklevel := r_tsetcomp.numseq;
            end if;
        end loop;
    end;
    --
    procedure initial_sum_param(param_column in json_object_t, v_max_column in number, v_columns in array_varchar, v_sumitem in varchar2, v_sumgroup in varchar2, param_fields in json_object_t,
                                v_labelcodapp in varchar2, v_labelindex in varchar2,
                                v_labelsumitemcodapp in varchar2, v_labelsumitemindex in varchar2,
                                v_labelsumbreakcodapp in varchar2, v_labelsumbreakindex in varchar2,
                                v_labelsumgroupcodapp in varchar2, v_labelsumgroupindex in varchar2,
                                v_sumitem_index                 out number,
                                v_sumgroup_index                out number,
                                v_total_label                   out varchar2,
                                v_total_sumitem_label           out varchar2,
                                v_total_sumbreak_label          out varchar2,
                                v_total_sumgroup_label          out varchar2,
                                v_record_label                  out varchar2,
                                v_index_of_column_key_list      out map_number,
                                v_sumitem_amount_by_column      out array_number,
                                v_sumgroup_amount_by_column     out array_number,
                                v_sumamount_by_column           out array_number,
                                v_sumrecord_by_level            out array_number,
                                v_sumamount_by_level_by_column  out array_number_2d,
                                v_sum_field                     out array_varchar,
                                v_disp_field                    out array_varchar,
                                v_sum_type                      out array_varchar,
                                v_disp_type                     out array_varchar) is

        param_fields_row    json_object_t;
        v_max_tsetcomp      number := 0;
    begin
        if v_labelcodapp is not null and v_labelindex is not null then
            v_total_label := get_label_name(v_labelcodapp, global_v_lang, v_labelindex);
        else
            v_total_label := get_label_name('SCRLABEL', global_v_lang, '2430');
        end if;

        if v_labelsumitemcodapp is not null and v_labelsumitemindex is not null then
            v_total_sumitem_label := get_label_name(v_labelsumitemcodapp, global_v_lang, v_labelsumitemindex);
        else
            if v_labelcodapp is not null and v_labelindex is not null then
                v_total_sumitem_label := get_label_name(v_labelcodapp, global_v_lang, v_labelindex);
            else
                v_total_sumitem_label := get_label_name('SCRLABEL', global_v_lang, '2430');
            end if;
        end if;

        if v_labelsumbreakcodapp is not null and v_labelsumbreakindex is not null then
            v_total_sumbreak_label := get_label_name(v_labelsumbreakcodapp, global_v_lang, v_labelsumbreakindex);
        else
            if v_labelcodapp is not null and v_labelindex is not null then
                v_total_sumbreak_label := get_label_name(v_labelcodapp, global_v_lang, v_labelindex);
            else
                v_total_sumbreak_label := get_label_name('SCRLABEL', global_v_lang, '2430');
            end if;
        end if;

        if v_labelsumgroupcodapp is not null and v_labelsumgroupindex is not null then
            v_total_sumgroup_label := get_label_name(v_labelsumgroupcodapp, global_v_lang, v_labelsumgroupindex);
        else
            if v_labelcodapp is not null and v_labelindex is not null then
                v_total_sumgroup_label := get_label_name(v_labelcodapp, global_v_lang, v_labelindex);
            else
                v_total_sumgroup_label := get_label_name('SCRLABEL', global_v_lang, '2430');
            end if;
        end if;

        v_record_label := get_label_name('SCRLABEL', global_v_lang, 1900);

        for v_column_index in 0..v_max_column - 1 loop
            v_sumitem_amount_by_column(v_column_index) := 0;
            v_sumgroup_amount_by_column(v_column_index) := 0;
            v_sumamount_by_column(v_column_index) := 0;
            v_index_of_column_key_list(v_columns(v_column_index)) := v_column_index;

            if v_sumitem = v_columns(v_column_index) then
                v_sumitem_index := v_column_index;
            end if;
            if v_sumgroup = v_columns(v_column_index) then
                v_sumgroup_index := v_column_index;
            end if;
        end loop;

        begin
            select max(numseq) into v_max_tsetcomp
              from tsetcomp
          order by numseq;
        exception when no_data_found then
            v_max_tsetcomp := 0;
        end;
        for v_setcomp_numseq in 1..v_max_tsetcomp loop
            v_sumrecord_by_level(v_setcomp_numseq) := 0;
            for v_column_index in 0..v_max_column - 1 loop
                v_sumamount_by_level_by_column(v_setcomp_numseq)(v_column_index) := 0;
            end loop;
        end loop;

        for v_field_index in 0..param_fields.get_size - 1 loop
            param_fields_row := hcm_util.get_json_t(param_fields, to_char(v_field_index));
                v_sum_field(v_field_index)  := hcm_util.get_string_t(param_fields_row,'sum_field');
                v_disp_field(v_field_index) := hcm_util.get_string_t(param_fields_row,'disp_field');
                v_sum_type(v_field_index)   := hcm_util.get_string_t(param_fields_row,'sum_type');
                v_disp_type(v_field_index)  := hcm_util.get_string_t(param_fields_row,'disp_type');
        end loop;
    end;
    procedure display_sum_object_row(param_data_row in json_object_t,
                                     v_flgsum in varchar2, v_sumbreak in varchar2, v_sumitem in varchar2, v_sumitem_index in number, v_sumgroup in varchar2, v_sumgroup_index in number,
                                     v_sumrecord in varchar2, v_sumamount in varchar2, v_disp_sum_record_field in varchar2, v_desc_sum_disp_field in varchar2,
                                     v_total_label in varchar2, v_total_sumitem_label in varchar2, v_total_sumbreak_label in varchar2, v_total_sumgroup_label in varchar2, v_record_label in varchar2,
                                     v_current_codcomp_data in varchar2, v_previous_codcomp_data in varchar2,
                                     v_current_sumitem_data in varchar2, v_previous_sumitem_data in varchar2,
                                     v_current_sumgroup_data in varchar2, v_previous_sumgroup_data in varchar2,
                                     v_max_breaklevel in number, v_day_break in number,
                                     obj_data_temp in json_object_t,v_index_of_column_key_list in map_number,
                                     v_columns in array_varchar, v_breaklevel in array_varchar, v_setcomp_label_list in array_varchar, v_sum_field in array_varchar, v_disp_type in array_varchar, v_disp_field in array_varchar,
                                     v_sum_qtycode_incremental_list in array_number,
                                     v_sumrecord_by_level in out array_number,
                                     v_sumamount_by_level_by_column in out array_number_2d,
                                     v_sumitem_amount_by_column in out array_number,
                                     v_sumitem_record in out number,
                                     v_sumgroup_amount_by_column in out array_number,
                                     v_sumgroup_record in out number,
                                     v_row in out number,
                                     obj_row in out json_object_t) is

        v_column_index              number;
        v_disp_field_data           varchar2(1000 char);
        v_comp_total1               varchar2(1000 char);
        v_comp_total2               varchar2(1000 char);
        v_flg_sum_pass              boolean := false;
        obj_data                    json_object_t;
    begin
        if v_flgsum = 'Y' then
            if v_sumitem is not null then
                if v_current_sumitem_data <> v_previous_sumitem_data and v_previous_sumitem_data <> '!@#$%' then
                    v_row := v_row + 1;
                    obj_data := json_object_t(obj_data_temp.to_clob);
                    if v_sumamount = 'Y' then
                        obj_data.put(v_desc_sum_disp_field, v_total_sumitem_label || ':' || v_previous_sumitem_data);
                        for v_field_index in 0..v_sum_field.count - 1 loop
                            if v_index_of_column_key_list.exists(v_sum_field(v_field_index)) then
                                v_column_index := v_index_of_column_key_list(v_sum_field(v_field_index));
                                v_disp_field_data := get_display_field_data(v_sumitem_amount_by_column(v_column_index), v_disp_type(v_field_index), v_day_break);
                                obj_data.put(v_disp_field(v_field_index), v_disp_field_data);
                                --clear sum data
                                v_sumitem_amount_by_column(v_column_index) := 0;
                            end if;
                        end loop;
                    end if;
                    if v_sumrecord = 'Y' then
                        obj_data.put(v_disp_sum_record_field, v_total_sumitem_label || ':' || v_previous_sumitem_data || ' ' || to_char(v_sumitem_record,'fm999,999,999') || ' ' || v_record_label);
                    end if;
                    obj_data.put('flgbreak', '');
                    obj_data.put('breaklvl', '');
                    obj_data.put('flgsum', 'Y');
                    obj_row.put(to_char(v_row - 1), obj_data);

                    --clear sum data
                    v_sumitem_record := 0;
                end if;
            end if;
            if v_sumbreak = 'Y' then
                for v_level in reverse 1..v_max_breaklevel loop
                  if v_sumrecord_by_level(v_level) > 0 then
                    if v_breaklevel(v_level) = 'Y' and v_previous_codcomp_data <> '!@#$%' then
                        sumbreak_label_local(v_current_codcomp_data, v_previous_codcomp_data, v_level, v_total_sumbreak_label, v_setcomp_label_list, v_sum_qtycode_incremental_list, v_comp_total1, v_comp_total2, v_flg_sum_pass);
                        if v_flg_sum_pass = true then
                            v_row := v_row + 1;
                            obj_data := json_object_t(obj_data_temp.to_clob);
                            if v_sumamount = 'Y' then
                                obj_data.put(v_desc_sum_disp_field, v_comp_total1 || ':' || v_comp_total2);
                                for v_field_index in 0..v_sum_field.count - 1 loop
                                    if v_index_of_column_key_list.exists(v_sum_field(v_field_index)) then
                                        v_column_index := v_index_of_column_key_list(v_sum_field(v_field_index));
                                        v_disp_field_data := get_display_field_data(v_sumamount_by_level_by_column(v_level)(v_column_index), v_disp_type(v_field_index), v_day_break);
                                        obj_data.put(v_disp_field(v_field_index), v_disp_field_data);

                                        --clear sum data
                                        v_sumamount_by_level_by_column(v_level)(v_column_index) := 0;
                                    end if;
                                end loop;
                            end if;
                            if v_sumrecord = 'Y' then
                                obj_data.put(v_disp_sum_record_field, v_comp_total1 || ':' || v_comp_total2 || ' ' || to_char(v_sumrecord_by_level(v_level),'fm999,999,999') || ' ' || v_record_label);
                            end if;
                            obj_data.put('flgbreak', '');
                            obj_data.put('breaklvl', v_level);
                            obj_data.put('flgsum', 'Y');
                            obj_row.put(to_char(v_row - 1), obj_data);

                            --clear sum data
                            v_sumrecord_by_level(v_level) := 0;
                        end if;
                    end if;
                  end if;
                end loop;
            end if;
            if v_sumgroup is not null then
                if v_current_sumgroup_data <> v_previous_sumgroup_data and v_previous_sumgroup_data <> '!@#$%' then
                    v_row := v_row + 1;
                    obj_data := json_object_t(obj_data_temp.to_clob);
                    if v_sumamount = 'Y' then
                        obj_data.put(v_desc_sum_disp_field, v_total_sumgroup_label || ':' || v_previous_sumgroup_data);
                        for v_field_index in 0..v_sum_field.count - 1 loop
                            if v_index_of_column_key_list.exists(v_sum_field(v_field_index)) then
                                v_column_index := v_index_of_column_key_list(v_sum_field(v_field_index));
                                v_disp_field_data := get_display_field_data(v_sumgroup_amount_by_column(v_column_index), v_disp_type(v_field_index), v_day_break);
                                obj_data.put(v_disp_field(v_field_index), v_disp_field_data);
                                --clear sum data
                                v_sumgroup_amount_by_column(v_column_index) := 0;
                            end if;
                        end loop;
                    end if;
                    if v_sumrecord = 'Y' then
                        obj_data.put(v_disp_sum_record_field, v_total_sumgroup_label || ':' || v_previous_sumgroup_data || ' ' || to_char(v_sumgroup_record,'fm999,999,999') || ' ' || v_record_label);
                    end if;
                    obj_data.put('flgbreak', '');
                    obj_data.put('breaklvl', '');
                    obj_data.put('flgsum', 'Y');
                    obj_row.put(to_char(v_row - 1), obj_data);

                    --clear sum data
                    v_sumgroup_record := 0;
                end if;
            end if;
        end if;
    end;
    procedure display_break_object_row(v_current_codcomp_data in varchar2, v_previous_codcomp_data in varchar2,
                                       v_company_disp_field in varchar2, v_desc_company_disp_field in varchar2,
                                       v_max_breaklevel in number,
                                       obj_data_temp in json_object_t,
                                       v_breaklevel in array_varchar, v_setcomp_label_list in array_varchar, v_sum_qtycode_incremental_list in array_number,
                                       v_row in out number,
                                       obj_row in out json_object_t) is

        obj_data        json_object_t;
        v_comp_label1   varchar2(1000 char);
        v_comp_label2   varchar2(1000 char);
        v_flg_comp_pass boolean := false;
    begin
        for v_level in 1..v_max_breaklevel loop
            if v_breaklevel(v_level) = 'Y' then
                comp_label_local(v_current_codcomp_data, v_previous_codcomp_data, v_level, v_setcomp_label_list, v_sum_qtycode_incremental_list, v_comp_label1, v_comp_label2, v_flg_comp_pass);
                if v_flg_comp_pass = true then
                    v_row := v_row + 1;
                    obj_data := json_object_t(obj_data_temp.to_clob);
                    obj_data.put(v_company_disp_field, v_comp_label1);
                    obj_data.put(v_desc_company_disp_field, v_comp_label2);
                    obj_data.put('flgbreak','Y');
                    obj_data.put('breaklvl', v_level);
                    obj_data.put('flgsum','');
                    obj_row.put(to_char(v_row - 1), obj_data);
                end if;
            end if;
        end loop;
    end;
    procedure count_sum_param(param_data_row in json_object_t,
                              v_flgsum in varchar2, v_sumbreak in varchar2, v_sumitem in varchar2, v_sumgroup in varchar2, v_sumrecord in varchar2, v_sumamount in varchar2,
                              v_comlevel in number, v_day_break in number,
                              v_breaklevel in array_varchar, v_sum_field in array_varchar, v_sum_type in array_varchar, v_index_of_column_key_list in map_number,
                              v_sumrecord_by_level            in out array_number,
                              v_sumtotal_record               in out number,
                              v_sumamount_by_level_by_column  in out array_number_2d,
                              v_sumamount_by_column           in out array_number,
                              v_sumitem_amount_by_column      in out array_number,
                              v_sumitem_record                in out number,
                              v_sumgroup_amount_by_column     in out array_number,
                              v_sumgroup_record               in out number) is

        v_column_index          number;
        v_current_sumitem_data  varchar2(1000 char);
        v_current_sumgroup_data varchar2(1000 char);
    begin
        if v_flgsum = 'Y' then
            if v_sumitem is not null then
                if v_sumamount = 'Y' then
                    for v_field_index in 0..v_sum_field.count - 1 loop
                        if v_index_of_column_key_list.exists(v_sum_field(v_field_index)) then
                            v_column_index := v_index_of_column_key_list(v_sum_field(v_field_index));
                            v_sumitem_amount_by_column(v_column_index) := v_sumitem_amount_by_column(v_column_index) + get_min_field_data(hcm_util.get_string_t(param_data_row, v_sum_field(v_field_index)), v_sum_type(v_field_index), v_day_break);
                            v_sumamount_by_column(v_column_index) := v_sumamount_by_column(v_column_index) + get_min_field_data(hcm_util.get_string_t(param_data_row, v_sum_field(v_field_index)), v_sum_type(v_field_index), v_day_break);
                        end if;
                    end loop;
                end if;
                if v_sumrecord = 'Y' then
                    v_sumitem_record := v_sumitem_record + 1;
                end if;
            end if;
            if v_sumbreak = 'Y' then
                if v_sumamount = 'Y' then
                    for v_field_index in 0..v_sum_field.count - 1 loop
                        if v_index_of_column_key_list.exists(v_sum_field(v_field_index)) then
                            v_column_index := v_index_of_column_key_list(v_sum_field(v_field_index));
                            for v_level in 1..v_comlevel loop
                                if v_breaklevel(v_level) = 'Y' then
                                    v_sumamount_by_level_by_column(v_level)(v_column_index) := v_sumamount_by_level_by_column(v_level)(v_column_index) + get_min_field_data(hcm_util.get_string_t(param_data_row, v_sum_field(v_field_index)), v_sum_type(v_field_index), v_day_break);
                                end if;
                            end loop;
                            v_sumamount_by_column(v_column_index) := v_sumamount_by_column(v_column_index) + get_min_field_data(hcm_util.get_string_t(param_data_row, v_sum_field(v_field_index)), v_sum_type(v_field_index), v_day_break);
                        end if;
                    end loop;
                end if;
--                if v_sumrecord = 'Y' then
                    for v_level in 1..v_comlevel loop
                        if v_breaklevel(v_level) = 'Y' then
                            v_sumrecord_by_level(v_level) := v_sumrecord_by_level(v_level) + 1;
                        end if;
                    end loop;
--                end if;
            end if;
            if v_sumgroup is not null then
                if v_sumamount = 'Y' then
                    for v_field_index in 0..v_sum_field.count - 1 loop
                        if v_index_of_column_key_list.exists(v_sum_field(v_field_index)) then
                            v_column_index := v_index_of_column_key_list(v_sum_field(v_field_index));
                            v_sumgroup_amount_by_column(v_column_index) := v_sumgroup_amount_by_column(v_column_index) + get_min_field_data(hcm_util.get_string_t(param_data_row, v_sum_field(v_field_index)), v_sum_type(v_field_index), v_day_break);
                        end if;
                    end loop;
                end if;
                if v_sumrecord = 'Y' then
                    v_sumgroup_record := v_sumgroup_record + 1;
                end if;
            end if;
            if v_sumitem is not null or v_sumbreak = 'Y' or v_sumgroup is not null then
                if v_sumrecord = 'Y' then
                    v_sumtotal_record := v_sumtotal_record + 1;
                end if;
            end if;
        end if;
    end;
    procedure display_data_object_row(param_data_row in json_object_t, v_row in out number, obj_row in out json_object_t) is
        obj_data        json_object_t := json_object_t(param_data_row.to_clob);
    begin
        v_row := v_row + 1;
        obj_data.put('flgbreak', '');
        obj_data.put('breaklvl', '');
        obj_data.put('flgsum', '');
        obj_row.put(to_char(v_row - 1), obj_data);
    end;
    procedure display_last_sum_object_row(param_data_row in json_object_t,
                                          v_flgsum in varchar2, v_sumbreak in varchar2, v_sumitem in varchar2, v_sumitem_index in number, v_sumgroup in varchar2, v_sumgroup_index in number,
                                          v_sumrecord in varchar2, v_sumamount in varchar2, v_disp_sum_record_field in varchar2, v_desc_sum_disp_field in varchar2,
                                          v_total_label in varchar2, v_total_sumitem_label in varchar2, v_total_sumbreak_label in varchar2, v_total_sumgroup_label in varchar2, v_record_label in varchar2,
                                          v_current_codcomp_data in varchar2, v_previous_codcomp_data in varchar2,
                                          v_current_sumitem_data in varchar2, v_previous_sumitem_data in varchar2,
                                          v_current_sumgroup_data in varchar2, v_previous_sumgroup_data in varchar2,
                                          v_max_breaklevel in number, v_day_break in number,
                                          obj_data_temp in json_object_t,v_index_of_column_key_list in map_number,
                                          v_columns in array_varchar, v_breaklevel in array_varchar, v_setcomp_label_list in array_varchar, v_sum_field in array_varchar, v_disp_type in array_varchar, v_disp_field in array_varchar,
                                          v_sum_qtycode_incremental_list in array_number,
                                          v_sumrecord_by_level in array_number,
                                          v_sumamount_by_level_by_column in array_number_2d,
                                          v_sumitem_amount_by_column in array_number, v_sumitem_record in number,
                                          v_sumgroup_amount_by_column in array_number, v_sumgroup_record in number,
                                          v_sumamount_by_column in array_number, v_sumtotal_record in number,
                                          v_row in out number,
                                          obj_row in out json_object_t) is

        v_column_index              number;
        v_disp_field_data           varchar2(1000 char);
        v_comp_total1               varchar2(1000 char);
        v_comp_total2               varchar2(1000 char);
        v_flg_sum_pass              boolean := false;
        obj_data                    json_object_t;
    begin
        if v_flgsum = 'Y' then
            --start sum feature logic (display last sum data)
            if v_sumitem is not null then
                v_row := v_row + 1;
                obj_data := json_object_t(obj_data_temp.to_clob);
                if v_sumamount = 'Y' then
                    obj_data.put(v_desc_sum_disp_field, v_total_sumitem_label || ':' || v_previous_sumitem_data);
                    for v_field_index in 0..v_sum_field.count - 1 loop
                        if v_index_of_column_key_list.exists(v_sum_field(v_field_index)) then
                            v_column_index := v_index_of_column_key_list(v_sum_field(v_field_index));
                            v_disp_field_data := get_display_field_data(v_sumitem_amount_by_column(v_column_index), v_disp_type(v_field_index), v_day_break);
                            obj_data.put(v_disp_field(v_field_index), v_disp_field_data);
                        end if;
                    end loop;
                end if;
                if v_sumrecord = 'Y' then
                    obj_data.put(v_disp_sum_record_field, v_total_sumitem_label || ':' || v_previous_sumitem_data || ' ' || v_sumitem_record || ' ' || v_record_label);
                end if;
                obj_data.put('flgbreak', '');
                obj_data.put('breaklvl', '');
                obj_data.put('flgsum', 'Y');
                obj_row.put(to_char(v_row - 1), obj_data);
            end if;
            if v_sumbreak = 'Y' then
                for v_level in reverse 1..v_max_breaklevel loop
                  if v_sumrecord_by_level(v_level) > 0 then
                    if v_breaklevel(v_level) = 'Y' then
                        sumbreak_label_local(' ', v_previous_codcomp_data, v_level, v_total_sumbreak_label, v_setcomp_label_list, v_sum_qtycode_incremental_list, v_comp_total1, v_comp_total2, v_flg_sum_pass);
                        if v_flg_sum_pass = true then
                            v_row := v_row + 1;
                            obj_data := json_object_t(obj_data_temp.to_clob);
                            if v_sumamount = 'Y' then
                                obj_data.put(v_desc_sum_disp_field, v_comp_total1 || ':' || v_comp_total2);
                                for v_field_index in 0..v_sum_field.count - 1 loop
                                    if v_index_of_column_key_list.exists(v_sum_field(v_field_index)) then
                                        v_column_index := v_index_of_column_key_list(v_sum_field(v_field_index));
                                        v_disp_field_data := get_display_field_data(v_sumamount_by_level_by_column(v_level)(v_column_index), v_disp_type(v_field_index), v_day_break);
                                        obj_data.put(v_disp_field(v_field_index), v_disp_field_data);
                                    end if;
                                end loop;
                            end if;
                            if v_sumrecord = 'Y' then
                                obj_data.put(v_disp_sum_record_field, v_comp_total1 || ':' || v_comp_total2 || ' ' || to_char(v_sumrecord_by_level(v_level),'fm999,999,999') || ' ' || v_record_label);
                            end if;
                            obj_data.put('flgbreak', '');
                            obj_data.put('breaklvl', v_level);
                            obj_data.put('flgsum', 'Y');
                            obj_row.put(to_char(v_row - 1), obj_data);
                        end if;
                    end if;
                  end if;
                end loop;
            end if;
            if v_sumgroup is not null then
                v_row := v_row + 1;
                obj_data := json_object_t(obj_data_temp.to_clob);
                if v_sumamount = 'Y' then
                    obj_data.put(v_desc_sum_disp_field, v_total_sumgroup_label || ':' || v_previous_sumgroup_data);
                    for v_field_index in 0..v_sum_field.count - 1 loop
                        if v_index_of_column_key_list.exists(v_sum_field(v_field_index)) then
                            v_column_index := v_index_of_column_key_list(v_sum_field(v_field_index));
                            v_disp_field_data := get_display_field_data(v_sumgroup_amount_by_column(v_column_index), v_disp_type(v_field_index), v_day_break);
                            obj_data.put(v_disp_field(v_field_index), v_disp_field_data);
                        end if;
                    end loop;
                end if;
                if v_sumrecord = 'Y' then
                    obj_data.put(v_disp_sum_record_field, v_total_sumgroup_label || ':' || v_previous_sumgroup_data || ' ' || v_sumgroup_record || ' ' || v_record_label);
                end if;
                obj_data.put('flgbreak', '');
                obj_data.put('breaklvl', '');
                obj_data.put('flgsum', 'Y');
                obj_row.put(to_char(v_row - 1), obj_data);
            end if;
            --end sum feature logic (display last sum data)

            --start sum feature logic (display last sum total data)
            v_row := v_row + 1;
            obj_data := json_object_t(obj_data_temp.to_clob);
            if v_sumamount = 'Y' then
                obj_data.put(v_desc_sum_disp_field, v_total_label);
                for v_field_index in 0..v_sum_field.count - 1 loop
                    if v_index_of_column_key_list.exists(v_sum_field(v_field_index)) then
                        v_column_index := v_index_of_column_key_list(v_sum_field(v_field_index));
                        v_disp_field_data := get_display_field_data(v_sumamount_by_column(v_column_index), v_disp_type(v_field_index), v_day_break);
                        obj_data.put(v_disp_field(v_field_index), v_disp_field_data);
                    end if;
                end loop;
            end if;
            if v_sumrecord = 'Y' then
                obj_data.put(v_disp_sum_record_field, v_total_label || ' ' || to_char(v_sumtotal_record,'fm999,999,999') || ' ' || v_record_label);
            end if;
            obj_data.put('flgbreak', '');
            obj_data.put('breaklvl', '');
            obj_data.put('flgsum', 'Y');
            obj_row.put(to_char(v_row - 1), obj_data);
            --end sum feature logic (display last sum total data)
        end if;
    end;
    --end function used for get_breaklevel only

    function get_breaklevel(json_str_input in clob) return clob is
        --input param
        json_obj                                json_object_t := json_object_t(json_str_input);
            json_obj1                           json_object_t;          --json_input_str1
                param_column                    json_object_t;          --columns
                param_data                      json_object_t;          --data
            json_obj2                           json_object_t;          --json_input_str2
                param_break                     json_object_t;          --break
                    v_codempid_break_field      varchar2(50 char);      --codempid_break_field
                    v_codcomp_break_field       varchar2(50 char);      --codcomp_break_field
                    v_company_disp_field        varchar2(50 char);      --company_disp_field
                    v_desc_company_disp_field   varchar2(50 char);      --desc_company_disp_field
                    param_level                 json_object_t;          --breaklevel
                param_sum                       json_object_t;          --sum
                    v_labelcodapp               varchar2(50 char);      --labelCodapp
                    v_labelindex                varchar2(50 char);      --labelIndex
                    v_flgsum                    varchar2(1 char);       --flgsum (Y/N) or [condition)]
                    v_sumrecord                 varchar2(1 char);       --sumRecord (A/Y/N) or [condition]
                    v_sumamount                 varchar2(1 char);       --[condition]
                    v_labelsumitemcodapp        varchar2(50 char);      --labelSumItemCodapp
                    v_labelsumitemindex         varchar2(50 char);      --labelSumItemIndex
                    v_sumitem                   varchar2(50 char);      --sumItem
                    v_labelsumbreakcodapp       varchar2(50 char);      --labelSumBreakCodapp
                    v_labelsumbreakindex        varchar2(50 char);      --labelSumBreakIndex
                    v_sumbreak                  varchar2(1 char);       --sumBreak (Y/N) or [condition from sumItem]
                    v_labelsumgroupcodapp       varchar2(50 char);      --labelSumGroupCodapp
                    v_labelsumgroupindex        varchar2(50 char);      --labelSumGroupIndex
                    v_sumgroup                  varchar2(50 char);      --sumGroup
                    v_desc_sum_disp_field       varchar2(50 char);      --desc_sum_disp_field or [condition]
                    v_disp_sum_record_field     varchar2(50 char);      --disp_sum_record_field
                    param_fields                json_object_t;          --fields

        --main feature param
        param_data_row                          json_object_t;
        obj_data_temp                           json_object_t;
        param_previous_skip_data_row            json_object_t;
        v_current_codcomp_data                  tcenter.codcomp%type;
        v_previous_codcomp_data                 tcenter.codcomp%type := '!@#$%';
        v_current_sumitem_data                  varchar2(1000 char);
        v_previous_sumitem_data                 varchar2(1000 char) := '!@#$%';
        v_current_sumgroup_data                 varchar2(1000 char);
        v_previous_sumgroup_data                varchar2(1000 char) := '!@#$%';
        v_flgbreak_data                         varchar2(1 char);
        v_flgsum_data                           varchar2(1 char);
        v_flgskip_data                          varchar2(1 char);
        v_row                                   number := 0;
        v_comlevel                              number := 0;
        v_max_breaklevel                        number := 0;
        v_max_column                            number := 0;
        v_day_break                             number := 0;

        v_columns                               array_varchar;
        v_breaklevel                            array_varchar;
        v_setcomp_label_list                    array_varchar;
        v_sum_qtycode_incremental_list          array_number;

        --sum feature param
        v_sumitem_index                         number := 0;
        v_sumgroup_index                        number := 0;
        v_total_label                           varchar2(1000 char);
        v_total_sumitem_label                   varchar2(1000 char);
        v_total_sumbreak_label                  varchar2(1000 char);
        v_total_sumgroup_label                  varchar2(1000 char);
        v_record_label                          varchar2(1000 char);
        v_index_of_column_key_list              map_number;
        v_sum_field                             array_varchar;
        v_disp_field                            array_varchar;
        v_sum_type                              array_varchar;
        v_disp_type                             array_varchar;

        --sum counter param
        v_sumrecord_by_level                    array_number;
        v_sumamount_by_column                   array_number;
        v_sumamount_by_level_by_column          array_number_2d;
        v_sumitem_amount_by_column              array_number;
        v_sumitem_record                        number := 0;
        v_sumgroup_amount_by_column             array_number;
        v_sumgroup_record                       number := 0;
        v_sumtotal_record                       number := 0;

        --output param
        json_str_output                         clob;
        json_obj_output                         json_object_t := json_object_t();
        obj_data                                json_object_t := json_object_t();
        obj_row                                 json_object_t := json_object_t();
        v_response                              varchar2(1000 char);
    begin
        initial_value(json_obj);
        json_obj1 := hcm_util.get_json_t(json_obj,'json_input_str1');
            param_column    := hcm_util.get_json_t(json_obj1, 'columns');
            param_data      := hcm_util.get_json_t(json_obj1, 'data');
        json_obj2 := hcm_util.get_json_t(json_obj,'json_input_str2');
            param_break     := hcm_util.get_json_t(json_obj2, 'break');
                v_codempid_break_field      := hcm_util.get_string_t(param_break,'codempid_break_field');
                v_codcomp_break_field       := hcm_util.get_string_t(param_break,'codcomp_break_field');
                v_company_disp_field        := hcm_util.get_string_t(param_break,'company_disp_field');
                v_desc_company_disp_field   := hcm_util.get_string_t(param_break,'desc_company_disp_field');
                param_level                 := hcm_util.get_json_t(param_break, 'breaklevel');
            param_sum       := hcm_util.get_json_t(json_obj2, 'sum');
                v_labelcodapp               := hcm_util.get_string_t(param_sum,'labelCodapp');
                v_labelindex                := hcm_util.get_string_t(param_sum,'labelIndex');
                v_labelsumitemcodapp        := hcm_util.get_string_t(param_sum,'labelSumItemCodapp');
                v_labelsumitemindex         := hcm_util.get_string_t(param_sum,'labelSumItemIndex');
                v_labelsumbreakcodapp       := hcm_util.get_string_t(param_sum,'labelSumBreakCodapp');
                v_labelsumbreakindex        := hcm_util.get_string_t(param_sum,'labelSumBreakIndex');
                v_labelsumgroupcodapp       := hcm_util.get_string_t(param_sum,'labelSumGroupCodapp');
                v_labelsumgroupindex        := hcm_util.get_string_t(param_sum,'labelSumGroupIndex');
                v_flgsum                    := get_flgsum(param_sum);
                v_sumrecord                 := get_sumrecord(param_sum);
                v_sumamount                 := get_sumamount(param_sum);
                v_sumitem                   := hcm_util.get_string_t(param_sum,'sumItem');
                v_sumbreak                  := get_sumbreak(param_sum);
                v_sumgroup                  := hcm_util.get_string_t(param_sum,'sumGroup');
                v_desc_sum_disp_field       := get_desc_sum_disp_field(param_sum, param_break);
                v_disp_sum_record_field     := get_disp_sum_record_field(param_sum, param_break);
                param_fields                := hcm_util.get_json_t(param_sum, 'fields');

        v_max_column := param_column.get_size;

        initial_column(param_column,
                       v_max_column,
                       obj_data_temp,
                       v_columns);

        initial_sum_param(param_column, v_max_column, v_columns, v_sumitem, v_sumgroup, param_fields,
                          v_labelcodapp, v_labelindex,
                          v_labelsumitemcodapp, v_labelsumitemindex,
                          v_labelsumbreakcodapp, v_labelsumbreakindex,
                          v_labelsumgroupcodapp, v_labelsumgroupindex,
                          --out param
                          v_sumitem_index, v_sumgroup_index,
                          v_total_label,
                          v_total_sumitem_label,
                          v_total_sumbreak_label,
                          v_total_sumgroup_label,
                          v_record_label,
                          v_index_of_column_key_list,
                          v_sumitem_amount_by_column,
                          v_sumgroup_amount_by_column,
                          v_sumamount_by_column,
                          v_sumrecord_by_level,
                          v_sumamount_by_level_by_column,
                          v_sum_field,
                          v_disp_field,
                          v_sum_type,
                          v_disp_type);
        for v_data_index in 0..param_data.get_size - 1 loop
            param_data_row := hcm_util.get_json_t(param_data, to_char(v_data_index));
            v_flgbreak_data  := nvl(hcm_util.get_string_t(param_data_row,'flgbreak'), 'N');
            v_flgsum_data    := nvl(hcm_util.get_string_t(param_data_row,'flgsum'), 'N');
            v_flgskip_data   := nvl(hcm_util.get_string_t(param_data_row,'flgskip'), 'N');

            if v_flgbreak_data = 'N' and v_flgsum_data = 'N' then
                if v_flgskip_data = 'N' then
                    v_current_codcomp_data  := replace(hcm_util.get_string_t(param_data_row,v_codcomp_break_field),'-'); --<< Fix #6778

                    if hcm_util.get_codcomp_level(v_current_codcomp_data, 1) <> hcm_util.get_codcomp_level(v_previous_codcomp_data, 1) then
                        v_day_break := get_qtyavgwk(null, v_current_codcomp_data);
                    end if;

                    if v_sumitem is not null then
                        v_current_sumitem_data  := hcm_util.get_string_t(param_data_row, v_columns(v_sumitem_index));
                    end if;

                    if v_sumgroup is not null then
                        v_current_sumgroup_data  := hcm_util.get_string_t(param_data_row, v_columns(v_sumgroup_index));
                    end if;

                    initial_setcomp_label_list(param_level,hcm_util.get_codcomp_level(v_current_codcomp_data,1),
                                               v_max_breaklevel,
                                               v_setcomp_label_list,
                                               v_breaklevel,
                                               v_sum_qtycode_incremental_list);

                    display_sum_object_row(param_data_row,
                                           v_flgsum, v_sumbreak, v_sumitem, v_sumitem_index, v_sumgroup, v_sumgroup_index,
                                           v_sumrecord, v_sumamount, v_disp_sum_record_field, v_desc_sum_disp_field,
                                           v_total_label, v_total_sumitem_label, v_total_sumbreak_label, v_total_sumgroup_label, v_record_label,
                                           v_current_codcomp_data, v_previous_codcomp_data,
                                           v_current_sumitem_data, v_previous_sumitem_data,
                                           v_current_sumgroup_data, v_previous_sumgroup_data,
                                           v_max_breaklevel, v_day_break,
                                           obj_data_temp, v_index_of_column_key_list,
                                           v_columns, v_breaklevel, v_setcomp_label_list, v_sum_field, v_disp_type, v_disp_field,
                                           v_sum_qtycode_incremental_list,
                                           --out param
                                           v_sumrecord_by_level, v_sumamount_by_level_by_column, v_sumitem_amount_by_column, v_sumitem_record, v_sumgroup_amount_by_column, v_sumgroup_record,
                                           v_row,
                                           obj_row);

                    if v_sumitem is not null then
                        v_previous_sumitem_data := v_current_sumitem_data;
                    end if;

                    if v_sumgroup is not null then
                        v_previous_sumgroup_data := v_current_sumgroup_data;
                    end if;

                    if v_current_codcomp_data <> v_previous_codcomp_data then
                        begin
                            select comlevel into v_comlevel
                              from tcenter
                             where codcomp = v_current_codcomp_data;
                        exception when no_data_found then
                            v_comlevel := 0;
                        end;

                        display_break_object_row(v_current_codcomp_data, v_previous_codcomp_data,
                                                 v_company_disp_field, v_desc_company_disp_field,
                                                 v_max_breaklevel,
                                                 obj_data_temp,
                                                 v_breaklevel, v_setcomp_label_list, v_sum_qtycode_incremental_list,
                                                 --out param
                                                 v_row,
                                                 obj_row);
                    end if;

                    count_sum_param(param_data_row,
                                    v_flgsum, v_sumbreak, v_sumitem, v_sumgroup, v_sumrecord, v_sumamount,
                                    v_comlevel, v_day_break,
                                    v_breaklevel, v_sum_field, v_sum_type, v_index_of_column_key_list,
                                    --out param
                                    v_sumrecord_by_level,
                                    v_sumtotal_record,
                                    v_sumamount_by_level_by_column,
                                    v_sumamount_by_column,
                                    v_sumitem_amount_by_column,
                                    v_sumitem_record,
                                    v_sumgroup_amount_by_column,
                                    v_sumgroup_record);

                    display_data_object_row(param_data_row,
                                            --out param
                                            v_row,
                                            obj_row);

                    v_previous_codcomp_data  := v_current_codcomp_data;
                else
                    param_previous_skip_data_row := param_data_row;
                    if param_previous_skip_data_row is not null then
                        display_data_object_row(param_previous_skip_data_row,
                                                --out param
                                                v_row,
                                                obj_row);
                        param_previous_skip_data_row := null;
                    end if;
                end if; -- end v_flgskip_data = 'N'
            end if;
        end loop;
        if param_previous_skip_data_row is not null then
            display_data_object_row(param_previous_skip_data_row,
                                    --out param
                                    v_row,
                                    obj_row);
            param_previous_skip_data_row := null;
        end if;

        display_last_sum_object_row(param_data_row,
                                    v_flgsum, v_sumbreak, v_sumitem, v_sumitem_index, v_sumgroup, v_sumgroup_index,
                                    v_sumrecord, v_sumamount, v_disp_sum_record_field, v_desc_sum_disp_field,
                                    v_total_label, v_total_sumitem_label, v_total_sumbreak_label, v_total_sumgroup_label, v_record_label,
                                    ' ', v_previous_codcomp_data,
                                    ' ', v_previous_sumitem_data,
                                    ' ', v_previous_sumgroup_data,
                                    v_max_breaklevel, v_day_break,
                                    obj_data_temp, v_index_of_column_key_list,
                                    v_columns, v_breaklevel, v_setcomp_label_list, v_sum_field, v_disp_type, v_disp_field,
                                    v_sum_qtycode_incremental_list,
                                    v_sumrecord_by_level, v_sumamount_by_level_by_column, v_sumitem_amount_by_column, v_sumitem_record, v_sumgroup_amount_by_column, v_sumgroup_record,
                                    v_sumamount_by_column, v_sumtotal_record,
                                    --out param
                                    v_row,
                                    obj_row);

        v_response := get_response_message(null, param_msg_error, global_v_lang);

        json_obj_output.put('coderror',hcm_util.get_string_t(json_object_t(v_response),'coderror') );
        json_obj_output.put('response',hcm_util.get_string_t(json_object_t(v_response),'response') );
        json_obj_output.put('param_json',obj_row);

        json_str_output := json_obj_output.to_clob;

        return json_str_output;
    exception when others then
        obj_data := json_object_t ();
        obj_data.put('coderror',dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace);
        obj_data.put('desc_coderror',dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace);

        json_str_output := obj_data.to_clob;

        return json_str_output;
    end;

    procedure get_comp_setup(json_str_input in clob, json_str_output out clob) as
        obj_row       json_object_t;
        obj_data      json_object_t;
        json_input    json_object_t  := json_object_t(json_str_input);
        v_row         number := 0;
        v_codcomp         varchar2(1000 char);
        v_codcompy        varchar2(1000 char);
        v_codempid_query  varchar2(1000 char);
        cursor c_tsetcomp is
          select sc.numseq,
                 cc.namcente,cc.namcentt,cc.namcent3,cc.namcent4,cc.namcent5
            from tsetcomp sc, tcompnyc cc
           where sc.numseq        = cc.comlevel(+)
             and cc.codcompy(+)   = v_codcompy
          order by sc.numseq;
    begin
        initial_value(json_object_t(json_str_input));
        v_codcomp         := hcm_util.get_string_t(json_input,'p_codcomp');
        v_codempid_query  := hcm_util.get_string_t(json_input,'p_codempid_query');
        obj_row         := json_object_t();
        if v_codcomp is not null then
          v_codcompy      := hcm_util.get_codcomp_level(v_codcomp,1);
        elsif v_codempid_query is not null then
          begin
            select hcm_util.get_codcomp_level(codcomp,1)
              into v_codcompy
              from temploy1
             where codempid = v_codempid_query;
          exception when no_data_found then
            v_codcompy    := null;
          end;
        end if;


        for r_tsetcomp in c_tsetcomp loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('numseq', to_char(r_tsetcomp.numseq) );
            obj_data.put('level', 'level' || to_char(r_tsetcomp.numseq) );
            if r_tsetcomp.numseq = 1 then
              obj_data.put('namcente', get_label_name('SCRLABEL','101',2250));
              obj_data.put('namcentt', get_label_name('SCRLABEL','102',2250));
              obj_data.put('namcent3', get_label_name('SCRLABEL','103',2250));
              obj_data.put('namcent4', get_label_name('SCRLABEL','104',2250));
              obj_data.put('namcent5', get_label_name('SCRLABEL','105',2250));
            else
              obj_data.put('namcente', nvl(r_tsetcomp.namcente,get_label_name('SCRLABEL','101',2490)||to_char(r_tsetcomp.numseq)));
              obj_data.put('namcentt', nvl(r_tsetcomp.namcentt,get_label_name('SCRLABEL','102',2490)||to_char(r_tsetcomp.numseq)));
              obj_data.put('namcent3', nvl(r_tsetcomp.namcent3,get_label_name('SCRLABEL','103',2490)||to_char(r_tsetcomp.numseq)));
              obj_data.put('namcent4', nvl(r_tsetcomp.namcent4,get_label_name('SCRLABEL','104',2490)||to_char(r_tsetcomp.numseq)));
              obj_data.put('namcent5', nvl(r_tsetcomp.namcent5,get_label_name('SCRLABEL','105',2490)||to_char(r_tsetcomp.numseq)));
            end if;
            obj_row.put(to_char(v_row - 1), obj_data);
        end loop;

        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', to_char(11) );
        obj_data.put('level', 'total');
        obj_data.put('namcente', 'Total');
        obj_data.put('namcentt', 'Total');
        obj_data.put('namcent3', 'Total');
        obj_data.put('namcent4', 'Total');
        obj_data.put('namcent5', 'Total');
        obj_row.put(to_char(v_row - 1), obj_data);

        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;

    procedure get_level(json_str_input in clob,json_str_output out clob) as
        obj_row        json_object_t;
        json_obj       json_object_t := json_object_t(json_str_input);
        v_flglevel1    varchar2(1 char);
        v_flglevel2    varchar2(1 char);
        v_flglevel3    varchar2(1 char);
        v_flglevel4    varchar2(1 char);
        v_flglevel5    varchar2(1 char);
        v_flglevel6    varchar2(1 char);
        v_flglevel7    varchar2(1 char);
        v_flglevel8    varchar2(1 char);
        v_flglevel9    varchar2(1 char);
        v_flglevel10   varchar2(1 char);
        v_flgtotal     varchar2(1 char);
    begin
        initial_value(json_obj);
        begin
            select flglevel1,flglevel2,flglevel3,
                   flglevel4,flglevel5,flglevel6,
                   flglevel7,flglevel8,flglevel9,
                   flglevel10,flgtotal
              into v_flglevel1,v_flglevel2,v_flglevel3,
                   v_flglevel4,v_flglevel5,v_flglevel6,
                   v_flglevel7,v_flglevel8,v_flglevel9,
                   v_flglevel10,v_flgtotal
              from tbreaklvl
             where codapp = upper(p_codapp)
               and coduser = global_v_coduser;
        exception when no_data_found then
            v_flglevel1 := null;
            v_flglevel2 := null;
            v_flglevel3 := null;
            v_flglevel4 := null;
            v_flglevel5 := null;
            v_flglevel6 := null;
            v_flglevel7 := null;
            v_flglevel8 := null;
            v_flglevel9 := null;
            v_flglevel10 := null;
            v_flgtotal := null;
        end;
        obj_row := json_object_t();
        obj_row.put('coderror', '200');
        obj_row.put('flglevel1', v_flglevel1);
        obj_row.put('flglevel2', v_flglevel2);
        obj_row.put('flglevel3', v_flglevel3);
        obj_row.put('flglevel4', v_flglevel4);
        obj_row.put('flglevel5', v_flglevel5);
        obj_row.put('flglevel6', v_flglevel6);
        obj_row.put('flglevel7', v_flglevel7);
        obj_row.put('flglevel8', v_flglevel8);
        obj_row.put('flglevel9', v_flglevel9);
        obj_row.put('flglevel10', v_flglevel10);
        obj_row.put('flgtotal', v_flgtotal);

        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_level;

    procedure save_level(json_str_input in clob,json_str_output out clob) is
        json_obj          json_object_t := json_object_t(json_str_input);
        p_flglevel1       varchar2(1 char);
        p_flglevel2       varchar2(1 char);
        p_flglevel3       varchar2(1 char);
        p_flglevel4       varchar2(1 char);
        p_flglevel5       varchar2(1 char);
        p_flglevel6       varchar2(1 char);
        p_flglevel7       varchar2(1 char);
        p_flglevel8       varchar2(1 char);
        p_flglevel9       varchar2(1 char);
        p_flglevel10      varchar2(1 char);
        p_flgtotal        varchar2(1 char);
    begin
        initial_value(json_obj);
        p_flglevel1  := hcm_util.get_string_t(json_obj, 'flglevel1');
        p_flglevel2  := hcm_util.get_string_t(json_obj, 'flglevel2');
        p_flglevel3  := hcm_util.get_string_t(json_obj, 'flglevel3');
        p_flglevel4  := hcm_util.get_string_t(json_obj, 'flglevel4');
        p_flglevel5  := hcm_util.get_string_t(json_obj, 'flglevel5');
        p_flglevel6  := hcm_util.get_string_t(json_obj, 'flglevel6');
        p_flglevel7  := hcm_util.get_string_t(json_obj, 'flglevel7');
        p_flglevel8  := hcm_util.get_string_t(json_obj, 'flglevel8');
        p_flglevel9  := hcm_util.get_string_t(json_obj, 'flglevel9');
        p_flglevel10 := hcm_util.get_string_t(json_obj, 'flglevel10');
        p_flgtotal   := hcm_util.get_string_t(json_obj, 'flgtotal');

        begin
            insert into tbreaklvl (
                codapp,      coduser,
                flglevel1,   flglevel2,   flglevel3,
                flglevel4,   flglevel5,   flglevel6,
                flglevel7,   flglevel8,   flglevel9,
                flglevel10,  flgtotal,    dteupd
            ) values (
                p_codapp,    global_v_coduser,
                p_flglevel1, p_flglevel2, p_flglevel3,
                p_flglevel4, p_flglevel5, p_flglevel6,
                p_flglevel7, p_flglevel8, p_flglevel9,
                p_flglevel10,p_flgtotal,  sysdate
            );
        exception when dup_val_on_index then
            begin
                update tbreaklvl
                    set flglevel1  = p_flglevel1,
                        flglevel2  = p_flglevel2,
                        flglevel3  = p_flglevel3,
                        flglevel4  = p_flglevel4,
                        flglevel5  = p_flglevel8,
                        flglevel6  = p_flglevel6,
                        flglevel7  = p_flglevel7,
                        flglevel8  = p_flglevel8,
                        flglevel9  = p_flglevel9,
                        flglevel10 = p_flglevel10,
                        flgtotal = p_flgtotal
            where codapp = p_codapp
              and coduser = global_v_coduser;
            exception when others then
                rollback;
            end;
        end;

        if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            commit;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_level;

end hcm_breaklevel;

/

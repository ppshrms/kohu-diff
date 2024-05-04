--------------------------------------------------------
--  DDL for Package Body HRBF48X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF48X" AS

  procedure initial_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
        p_dtemthst        := hcm_util.get_string_t(json_obj,'p_dtemthst');
        p_dteyrest        := hcm_util.get_string_t(json_obj,'p_dteyrest');
        p_dtemthen        := hcm_util.get_string_t(json_obj,'p_dtemthen');
        p_dteyreen        := hcm_util.get_string_t(json_obj,'p_dteyreen');
        p_codobf1         := hcm_util.get_string_t(json_obj,'p_codobf1');
        p_codobf2         := hcm_util.get_string_t(json_obj,'p_codobf2');
        p_codobf3         := hcm_util.get_string_t(json_obj,'p_codobf3');
        p_codobf4         := hcm_util.get_string_t(json_obj,'p_codobf4');
        p_codobf5         := hcm_util.get_string_t(json_obj,'p_codobf5');

  end initial_value;

  procedure clear_ttemprpt is
    begin
        begin
            delete
            from  ttemprpt
            where codempid = global_v_codempid
            and   codapp   = 'HRBF48X';
        exception when others then
    null;
    end;
  end clear_ttemprpt;

   function get_max_numseq return number as
    p_numseq         number;
    max_numseq       number;
  begin
--  get max numseq
    select max(numseq) into max_numseq
        from ttemprpt
        where codempid = global_v_codempid
          and codapp = 'HRBF48X';
    if max_numseq is null then
        max_numseq := 0 ;
    end if;

    p_numseq := max_numseq+1;

    return p_numseq;

  end;

  procedure check_index as
    v_temp          varchar(1 char);
    p_codobf        tobfcde.codobf%type;
    obj_codobf      json_object_t;

  begin
--  check null parameters
    if p_codcomp is null or p_dtemthst is null or p_dteyrest is null or p_dtemthen is null or  p_dteyreen is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_codobf1 is null and p_codobf2 is null and p_codobf3 is null and p_codobf4 is null and p_codobf5 is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check codcomp in tcenter
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
    end;

--  check secure7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

--  check date
    if to_date(get_period_date(p_dtemthst,p_dteyrest,'S'),'dd/mm/yyyy') > to_date(get_period_date(p_dtemthen,p_dteyreen,''),'dd/mm/yyyy') then
        param_msg_error := get_error_msg_php('HR2022',global_v_lang);
        return;
    end if;

--  check codobf
    obj_codobf := json_object_t();
    obj_codobf.put(to_char(0),p_codobf1);
    obj_codobf.put(to_char(1),p_codobf2);
    obj_codobf.put(to_char(2),p_codobf3);
    obj_codobf.put(to_char(3),p_codobf4);
    obj_codobf.put(to_char(4),p_codobf5);

    for i in 0..obj_codobf.get_size-1 loop
        if hcm_util.get_string_t(obj_codobf,(i)) is not null then
            p_codobf := hcm_util.get_string_t(obj_codobf,(i));
            begin
                select 'X' into v_temp
                from tobfcde
                where codobf = p_codobf;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TOBFCDE');
                return;
            end;
--  check codcomp in tobfcompy
            begin
                select 'X' into v_temp
                from tobfcompy
                where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                  and codobf = p_codobf;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TOBFCOMPY');
                return;
            end;
        end if;
    end loop;

  end check_index;

  procedure insert_ttemprpt_codcomp_type(v_row number,v_codcomp varchar2,v_codobf varchar2,v_amtwidrw number) as
    v_temp1     ttemprpt.item1%type;
    v_item5     ttemprpt.item4%type;
    v_item8     ttemprpt.item8%type;
    v_item9     ttemprpt.item9%type;
    v_item31    ttemprpt.item31%type;

  begin
    v_temp1 := get_label_name('HRBF48X',global_v_lang,'160');
    v_item5 := get_tcenter_name(v_codcomp,global_v_lang);
    v_item8 := get_tobfcde_name(v_codobf,global_v_lang);
    v_item9 := get_label_name('HRBF48X',global_v_lang,'190');
    v_item31 := get_label_name('HRBF48X',global_v_lang,'200');

    insert into ttemprpt
        (
         codempid, codapp, numseq, item1, item4, item5,
         item7, item8, item9, item10, item14, item31
        )
    values
        (
         global_v_codempid, 'HRBF48X', v_row,v_temp1, v_codcomp, v_item5, v_codobf,
         v_item8, v_item9, v_amtwidrw, 'A', v_item31
        );

  end insert_ttemprpt_codcomp_type;

   procedure insert_ttemprpt_codobf_type(v_row number,v_codcomp varchar2,v_codobf varchar2,v_amtwidrw number) as
    v_temp1     ttemprpt.item1%type;
    v_item5     ttemprpt.item4%type;
    v_item8     ttemprpt.item8%type;
    v_item9     ttemprpt.item9%type;
    v_item31    ttemprpt.item31%type;

  begin
    v_temp1 := get_label_name('HRBF48X',global_v_lang,'170');
    v_item5 := get_tobfcde_name(v_codobf,global_v_lang);
    v_item8 := get_tcenter_name(v_codcomp,global_v_lang);
    v_item9 := get_label_name('HRBF48X',global_v_lang,'180');
    v_item31 := get_label_name('HRBF48X',global_v_lang,'200');

    insert into ttemprpt
        (
         codempid, codapp, numseq, item1, item4, item5,
         item7, item8, item9, item10, item14, item31
        )
    values
        (
         global_v_codempid, 'HRBF48X', v_row,v_temp1, v_codobf, v_item5,
         v_codcomp, v_item8, v_item9, v_amtwidrw, 'B', v_item31
        );

  end insert_ttemprpt_codobf_type;

  procedure gen_data_by_codobf(v_index in number,v_codobf in varchar2,v_codcomp in varchar2,v_total out number) as
  begin
    if v_codobf = null then
        v_total := 0;
        return;
    end if;
    begin
        select sum(a.qtywidrw)
        into v_total
        from tobfdep a, tobfcde b
        where a.codcomp = v_codcomp
          and (a.dteyre||lpad(a.dtemth,2,'0') between p_dteyrest||lpad(p_dtemthst,2,'0')and p_dteyreen||lpad(p_dtemthen,2,'0'))
          and a.codobf = v_codobf
          and a.codobf = b.codobf
        group by a.codcomp,a.codobf
        order by a.codcomp,a.codobf;
    exception when no_data_found then
        v_total := 0;
    end;

  end gen_data_by_codobf;

  procedure gen_index(json_str_output out clob) as
    obj_data        json_object_t;
    obj_rows        json_object_t;
    obj_main        json_object_t;
    obj_detail      json_object_t;
    v_row           number := 0;
    v_secur         varchar2(1 char) := 'N';
    v_count         number := 0;
    v_count_secur   number := 0;
    v_counter       number := 0;
    v_chk_secur     boolean := false;
    v_row_graph     number := 0;
    v_codcomp       tobfdep.codcomp%type;
    v_codobf        tobfcde.codobf%type;
    v_total         number :=0;

    cursor c1 is
        select distinct a.codcomp
        from tobfdep a
        where a.codcomp like p_codcomp || '%'
          and (a.dteyre||lpad(a.dtemth,2,'0') between p_dteyrest||lpad(p_dtemthst,2,'0') and p_dteyreen||lpad(p_dtemthen,2,'0'))
          and a.codobf in(p_codobf1,p_codobf2,p_codobf3,p_codobf4,p_codobf5)
        order by a.codcomp;

    obj_codobf        json_object_t;
    v_codobf_count  number :=0;

  begin
    obj_rows        := json_object_t();
    obj_main        := json_object_t();
    obj_detail      := json_object_t();
    obj_main.put('coderror',200);
--    obj_detail.put('coderror',200);
--    obj_detail.put('codobf1','');
--    obj_detail.put('codobf2','');
--    obj_detail.put('codobf3','');
--    obj_detail.put('codobf4','');
--    obj_detail.put('codobf5','');

    obj_codobf      := json_object_t();
    if p_codobf1 is not null then
        v_codobf_count := v_codobf_count+1;
        obj_codobf.put(to_char(v_codobf_count),p_codobf1);
--        obj_detail.put('codobf'||to_char(v_codobf_count),p_codobf1);
        obj_detail.put('desc_codobf'||to_char(v_codobf_count),get_tobfcde_name(p_codobf1,global_v_lang));
    end if;
    if p_codobf2 is not null then
        v_codobf_count := v_codobf_count+1;
        obj_codobf.put(to_char(v_codobf_count),p_codobf2);
--        obj_detail.put('codobf'||to_char(v_codobf_count),p_codobf2);
        obj_detail.put('desc_codobf'||to_char(v_codobf_count),get_tobfcde_name(p_codobf2,global_v_lang));
    end if;
    if p_codobf3 is not null then
        v_codobf_count := v_codobf_count+1;
        obj_codobf.put(to_char(v_codobf_count),p_codobf3);
--        obj_detail.put('codobf'||to_char(v_codobf_count),p_codobf3);
        obj_detail.put('desc_codobf'||to_char(v_codobf_count),get_tobfcde_name(p_codobf3,global_v_lang));
    end if;
    if p_codobf4 is not null then
        v_codobf_count := v_codobf_count+1;
        obj_codobf.put(to_char(v_codobf_count),p_codobf4);
--        obj_detail.put('codobf'||to_char(v_codobf_count),p_codobf4);
        obj_detail.put('desc_codobf'||to_char(v_codobf_count),get_tobfcde_name(p_codobf4,global_v_lang));
    end if;
    if p_codobf5 is not null then
        v_codobf_count := v_codobf_count+1;
        obj_codobf.put(to_char(v_codobf_count),p_codobf5);
--        obj_detail.put('codobf'||to_char(v_codobf_count),p_codobf5);
        obj_detail.put('desc_codobf'||to_char(v_codobf_count),get_tobfcde_name(p_codobf5,global_v_lang));
    end if;

    for i in c1 loop
        v_count := v_count + 1;
        v_chk_secur := secur_main.secur7(i.codcomp,global_v_coduser);
        if v_chk_secur then
            v_count_secur := v_count_secur + 1;
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('coderror',200);
    --<< user25 Date: 23/08/2021 #6758
          --obj_data.put('codcomp',i.codcomp); 
            obj_data.put('codcomp',hcm_util.get_codcomp_level(i.codcomp,null,'-','Y'));
    -->> user25 Date: 23/08/2021 #6758
            obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));
            v_counter := 0;
            for j in 1..obj_codobf.get_size loop
                v_counter := v_counter+1;
                gen_data_by_codobf(v_counter,hcm_util.get_string_t(obj_codobf,to_char(j)),i.codcomp,v_total);
                obj_data.put('codobf'||v_counter,hcm_util.get_string_t(obj_codobf,to_char(j)));
                obj_data.put('codobf_name'||v_counter,get_tobfcde_name(hcm_util.get_string_t(obj_codobf,to_char(j)),global_v_lang));
                --<<User37 #5969 11/06/2021
                if instr(v_total,'.') > 0 then
                    obj_data.put('amtwidrw'||v_counter,to_char(nvl(v_total,0),'fm999,999,999.99'));
                else
                    obj_data.put('amtwidrw'||v_counter,to_char(nvl(v_total,0),'fm999,999,999'));
                end if;
                -- obj_data.put('amtwidrw'||v_counter,v_total);
                -->>User37 #5969 11/06/2021
                v_row_graph := v_row_graph + 1;
                    insert_ttemprpt_codcomp_type(v_row_graph,i.codcomp,hcm_util.get_string_t(obj_codobf,to_char(j)),v_total);
                v_row_graph := v_row_graph + 1;
                    insert_ttemprpt_codobf_type(v_row_graph,i.codcomp,hcm_util.get_string_t(obj_codobf,to_char(j)),v_total);
            end loop;
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TOBFDEP');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    elsif v_count != 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    obj_main.put('header',obj_detail);
    obj_main.put('table',obj_rows);

    json_str_output := obj_main.to_clob;
  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_index;
    clear_ttemprpt;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index;

END HRBF48X;

/

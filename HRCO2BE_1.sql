--------------------------------------------------------
--  DDL for Package Body HRCO2BE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2BE" AS

        --update 30/10/2562 10:30

  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
    p_codform         := upper(hcm_util.get_string_t(json_obj,'p_codform'));
    p_codapp          := 'HRCO2BE';
    p_numgrup         := to_number(hcm_util.get_string_t(json_obj,'p_numgrup'));

    json_index_rows   := hcm_util.get_json_t(json_obj,'p_index_rows');
  end initial_value;

   procedure check_detail(object_data json_object_t) as
        p_codform varchar2(4 char);
        v_temp varchar2(1 char);
    begin
        p_codform  := hcm_util.get_string_t(object_data,'p_codform');
        if p_codform is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang, get_label_name('HRCO2BE', global_v_lang, 390));
            return;
        end if;
        begin
            select 'X' into v_temp
            from tintview
            where codform like p_codform||'%'
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;
        if secur_main.secur7(p_codform,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end check_detail; --ตรวจสอบรหัสแบบฟอร์มการประเมิน

   procedure get_index(json_str_input in clob, json_str_output out clob) as
          json_obj    json_object_t;
    obj_data_index    json_object_t;
     obj_row_index    json_object_t;
             v_row	  number := 0;

        cursor c3 is
        select *
        from TINTVIEW
        order by codform;
  begin
    initial_value(json_str_input);
    obj_row_index    := json_object_t();
    for i in c3 loop
        v_row := v_row + 1;
        obj_data_index := json_object_t();
        obj_data_index.put('coderror','200');
        obj_data_index.put('codform',i.codform);
        if(global_v_lang='101') then
            obj_data_index.put('desform',i.desforme);
        elsif(global_v_lang='102') then
            obj_data_index.put('desform',i.desformt);
        elsif(global_v_lang='103') then
            obj_data_index.put('desform',i.desform3);
        elsif(global_v_lang='104') then
            obj_data_index.put('desform',i.desform4);
        elsif(global_v_lang='105') then
            obj_data_index.put('desform',i.desform5);
        end if;
        obj_data_index.put('qtytscor',i.qtytscor);
        obj_data_index.put('typform',i.typform);
        obj_data_index.put('desc_typform',GET_TLISTVAL_NAME('TYPFORM',i.typform,global_v_lang));
        obj_data_index.put('dteupd',i.dteupd);
        obj_data_index.put('coduser',i.coduser);
        obj_row_index.put(to_char(v_row-1),obj_data_index);
    end loop;
        json_str_output := obj_row_index.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
  --ดึงค่าจากตาราง TINTVIEW

   procedure check_get_detail as
        v_temp  varchar2(1 char);
    begin
        if (p_codform is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang, get_label_name('HRCO2BE', global_v_lang, 390));
            return;
        end if;
    end check_get_detail; --ตรวจสอบค่าว่างของรหัสแบบฟอร์ม

   procedure validate_saveGrade(v_codform varchar2,v_typform varchar2,v_desformt varchar2,v_desform3 varchar2,v_desform4 varchar2,v_desform5 varchar2,v_desforme varchar2,param_json json_object_t) as
        obj_data_detail json_object_t;
        v_grditem     tintscor.grditem%type;
        v_grad        tintscor.grad%type;
        v_qtyscor     tintscor.qtyscor%type;
        v_descgrde    tintscor.descgrde%type;
        v_descgrdt    tintscor.descgrdt%type;
        v_descgrd3    tintscor.descgrd3%type;
        v_descgrd4    tintscor.descgrd4%type;
        v_descgrd5    tintscor.descgrd5%type;
        v_definitt    tintscor.definitt%type;
        v_definite    tintscor.definite%type;
        v_definit3    tintscor.definit3%type;
        v_definit4    tintscor.definit4%type;
        v_definit5    tintscor.definit5%type;
    begin
    for i in 0..param_json.get_size-1 loop
   obj_data_detail   := hcm_util.get_json_t(param_json,to_char(i));
            v_grad   := hcm_util.get_string_t(obj_data_detail,'grad');
         v_qtyscor   := hcm_util.get_string_t(obj_data_detail,'qtyscor');
        v_descgrde   := hcm_util.get_string_t(obj_data_detail,'descgrde');
        v_descgrdt   := hcm_util.get_string_t(obj_data_detail,'descgrdt');
        v_descgrd3   := hcm_util.get_string_t(obj_data_detail,'descgrd3');
        v_descgrd4   := hcm_util.get_string_t(obj_data_detail,'descgrd4');
        v_descgrd5   := hcm_util.get_string_t(obj_data_detail,'descgrd5');
        v_definitt   := hcm_util.get_string_t(obj_data_detail,'definitt');
        v_definite   := hcm_util.get_string_t(obj_data_detail,'definite');
        v_definit3   := hcm_util.get_string_t(obj_data_detail,'definit3');
        v_definit4   := hcm_util.get_string_t(obj_data_detail,'definit4');
        v_definit5   := hcm_util.get_string_t(obj_data_detail,'definit5');

            if (v_grad is null) then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 130));
                return;
            end if;
            if (v_codform is null) then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 390));
                return;
            end if;
            if (v_qtyscor is null) then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 160));
                return;
            end if;
            if (global_v_lang ='101') and ((v_descgrde is null) or (v_definite is null)) then
                if (v_descgrde is null) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 590));
                elsif (v_definite is null) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 600));
                end if;
                return;
            end if;
            if (global_v_lang ='102') and ((v_descgrdt is null) or (v_definitt is null)) then
                if (v_descgrdt is null) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 590));
                elsif (v_definitt is null) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 600));
                end if;
                return;
            end if;
            if (global_v_lang ='103') and ((v_descgrd3 is null) or (v_definit3 is null)) then
                if (v_descgrd3 is null) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 590));
                elsif (v_definit3 is null) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 600));
                end if;
                return;
            end if;
            if (global_v_lang ='104') and ((v_descgrd4 is null) or (v_definit4 is null)) then
                if (v_descgrd4 is null) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 590));
                elsif (v_definit4 is null) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 600));
                end if;
                return;
            end if;
            if (global_v_lang ='105') and ((v_descgrd5 is null) or (v_definit5 is null)) then
                if (v_descgrd5 is null) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 590));
                elsif (v_definit5 is null) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 600));
                end if;
                return;
            end if;
        end loop;

        if (v_typform is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 110));
            return;
        end if;
        if (v_codform is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 70));
            return;
        end if;
        if (global_v_lang ='101') and (v_desforme is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 170));
            return;
        end if;
        if (global_v_lang ='102') and (v_desformt is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 170));
            return;
        end if;
        if (global_v_lang ='103') and (v_desform3 is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 170));
            return;
        end if;
        if (global_v_lang ='104') and (v_desform4 is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 170));
            return;
        end if;
        if (global_v_lang ='105') and (v_desform5 is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 170));
            return;
        end if;

    end validate_saveGrade; -- ตรวจสอบค่าว่างของรายละเอียดและคำจำกัดความต้องระบุ

   procedure validate_delete(v_codform varchar2) as
        v_count_TAPLVL    number;
        v_count_TAPPBEHH  number;
        v_count_TAPPLCFM  number;
        v_count_TAPPOINF  number;
        v_count_TCANDATEH number;
        v_count_THISINST  number;
        v_count_TTPROEVL  number;
        v_count_TFWMAILH  number;
   begin
               select count(*)
               into v_count_TAPLVL
               from TAPLVL
               where upper(codform) = upper(v_codform);
            if v_count_TAPLVL > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'TAPLVL');
                return;
            end if;
               select count(*)
               into v_count_TAPPBEHH
               from TAPPEMP
               where upper(codform) = upper(v_codform);
            if v_count_TAPPBEHH > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'TAPPEMP');
                return;
            end if;
               select count(*)
               into v_count_TAPPLCFM
               from TAPPLCFM
               where upper(codform) = upper(v_codform);
            if v_count_TAPPLCFM > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'TAPPLCFM');
                return;
            end if;
               select count(*)
               into v_count_TAPPOINF
               from TAPPOINF
               where upper(codform) = upper(v_codform);
            if v_count_TAPPOINF > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'TAPPOINF');
                return;
            end if;

               select count(*)
               into v_count_THISINST
               from THISINST
               where upper(codform) = upper(v_codform);
            if v_count_THISINST > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'THISINST');
                return;
            end if;
               select count(*)
               into v_count_TTPROEVL
               from TTPROEVL
               where upper(codform) = upper(v_codform);
            if v_count_TTPROEVL > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'TTPROEVL');
                return;
            end if;
               select count(*)
               into v_count_TFWMAILH
               from TFWMAILH
               where upper(codform) = upper(v_codform);
            if v_count_TFWMAILH > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'TFWMAILH');
                return;
            end if;

    end validate_delete; -- ตรวจสอบก่อนทำการลบรหัสแบบฟอร์ม

   procedure gen_detail(json_str_output out clob) as
        obj_result json_object_t;
        obj_tab1 json_object_t;
        obj_tab2 json_object_t;
        obj_rows json_object_t;
        obj_data_detail json_object_t;
        v_row number := 0;
        numgrup_count number(2,0);
        max_qtyScor number;
        sum_numgrup_qtyScor number;
        sum_choice number(2,0);
        rec_tintview tintview%rowtype;
        cursor c1 is
            select * from tintscor
            where codform = p_codform
            order by grditem;

        cursor c2 is
            select  codform,
                    numgrup,
                    desgrupe,
                    desgrupt,
                    desgrup3,
                    desgrup4,
                    desgrup5,
                    dteupd,
                    coduser
            from tintvews

            where codform = p_codform;

        cursor c3 is
            select * from tintview
            where upper(codform) = upper(p_codform)
            order by codform;
    begin
        obj_result := json_object_t();
        begin
            select * into rec_tintview
            from tintview
            where codform = p_codform;
            obj_result.put('flgedit','Edit');
        exception when no_data_found then
            obj_result.put('flgedit','Add');
            rec_tintview := null;
        end;
                for i in c3 loop
            v_row := v_row + 1;
            obj_result.put('coderror','200');
            obj_result.put('codform',i.codform);
            obj_result.put('desforme',i.desforme);
            obj_result.put('desformt',i.desformt);
            obj_result.put('desform3',i.desform3);
            obj_result.put('desform4',i.desform4);
            obj_result.put('desform5',i.desform5);
            obj_result.put('qtytscor',i.qtytscor);
            obj_result.put('typform',i.typform);
            obj_result.put('des_typform',GET_TLISTVAL_NAME('TYPFORM',i.typform,global_v_lang));
            obj_result.put('dteupd',i.dteupd);
            obj_result.put('coduser',i.coduser);
            obj_result.put(to_char(v_row-1),obj_result);
        end loop;
        obj_rows := json_object_t();
        v_row := 0;
        for r1 in c1 loop
            v_row := v_row + 1;
            obj_data_detail := json_object_t();
            obj_data_detail.put('codform',r1.codform);
            obj_data_detail.put('grditem',r1.grditem);
            obj_data_detail.put('grad',r1.grad);
            obj_data_detail.put('qtyscor',r1.qtyscor);
            obj_data_detail.put('descgrde',r1.descgrde);
            obj_data_detail.put('definite',r1.definite);
            obj_data_detail.put('descgrdt',r1.descgrdt);
            obj_data_detail.put('definitt',r1.definitt);
            obj_data_detail.put('descgrd3',r1.descgrd3);
            obj_data_detail.put('definit3',r1.definit3);
            obj_data_detail.put('descgrd4',r1.descgrd4);
            obj_data_detail.put('definit4',r1.definit4);
            obj_data_detail.put('descgrd5',r1.descgrd5);
            obj_data_detail.put('definit5',r1.definit5);
            obj_data_detail.put('dteupd',r1.dteupd);
            obj_data_detail.put('coduser',r1.coduser);

            obj_rows.put(to_char(v_row-1),obj_data_detail);
        end loop;
            obj_tab1 := json_object_t();
            obj_tab1.put('rows',obj_rows);
            obj_result.put('tab1',obj_tab1);

            obj_rows := json_object_t();
            v_row := 0;


        for r2 in c2 loop

          begin
            select
            count (*) as num_count into numgrup_count
            from  tintvewd
            where codform = r2.codform
            and   numgrup = r2.numgrup
            group by numgrup having count(numgrup) >= 1 ;
          exception when no_data_found then
            numgrup_count := 0;
          end;

          begin
            select
            sum(qtyfscor) as max_score into sum_numgrup_qtyScor
            from tintvewd
            where codform = r2.codform
            and numgrup = r2.numgrup;
          exception when others then
            sum_numgrup_qtyScor := 0;
          end;

          begin
            select
            count(numitem) as sum_choice into sum_choice
            from tintvewd
            where codform = r2.codform;
          exception when others then
            sum_choice := 0;
          end;

            v_row := v_row + 1;
            obj_data_detail := json_object_t();
            obj_data_detail.put('codform',r2.codform);
            obj_data_detail.put('numgrup',r2.numgrup);
            if(global_v_lang='101') then
                obj_data_detail.put('desgrup',r2.desgrupe);
            elsif(global_v_lang='102') then
                obj_data_detail.put('desgrup',r2.desgrupt);
            elsif(global_v_lang='103') then
                obj_data_detail.put('desgrup',r2.desgrup3);
            elsif(global_v_lang='104') then
                obj_data_detail.put('desgrup',r2.desgrup4);
            elsif(global_v_lang='105') then
                obj_data_detail.put('desgrup',r2.desgrup5);
            end if;
            obj_data_detail.put('numItem_count',numgrup_count);
            obj_data_detail.put('sum_MaxScore',sum_numgrup_qtyScor);
            obj_data_detail.put('dteupd',r2.dteupd);
            obj_data_detail.put('coduser',r2.coduser);
            obj_rows.put(to_char(v_row-1),obj_data_detail);
        end loop;
            obj_tab2 := json_object_t();
            obj_tab2.put('rows',obj_rows);
            obj_result.put('tab2',obj_tab2);

            obj_data_detail := json_object_t();
            obj_data_detail.put('rows',obj_result);
            json_str_output := obj_data_detail.to_clob;

    end gen_detail; -- ดึงข้อมูลจากรายละเอียดจากตาราง TINTVEWS TINTVEWD TINTSCOR ตามรหัสแบบฟอร์ม p_codform

   procedure gen_tintvews(json_str_output out clob) as
        json_obj    json_object_t;
    obj_data_index    json_object_t;
     obj_row_index    json_object_t;
             v_row	  number := 0;
        count_item    number;
         max_grade    number;
         sum_score    number;
        cursor c3 is
        select *
        from tintvews where
        codform = p_codform
        order by codform;
  begin

    obj_row_index    := json_object_t();
    for i in c3 loop
        v_row := v_row + 1;
        obj_data_index := json_object_t();
        obj_data_index.put('coderror','200');
        obj_data_index.put('codform',i.codform);
        obj_data_index.put('numgrup',i.numgrup);
        if(global_v_lang='101') then
            obj_data_index.put('desgrup',i.desgrupe);
        elsif(global_v_lang='102') then
            obj_data_index.put('desgrup',i.desgrupt);
        elsif(global_v_lang='103') then
            obj_data_index.put('desgrup',i.desgrup3);
        elsif(global_v_lang='104') then
            obj_data_index.put('desgrup',i.desgrup4);
        elsif(global_v_lang='105') then
            obj_data_index.put('desgrup',i.desgrup5);
        end if;
        obj_data_index.put('qtyfscor',i.qtyfscor);
        obj_data_index.put('dteupd',i.dteupd);
        obj_data_index.put('coduser',i.coduser);
        obj_row_index.put(to_char(v_row-1),obj_data_index);
    end loop;
        json_str_output := obj_row_index.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_tintvews; --ดึงค่าจากตาราง TINTVEWD

   procedure get_data_tintvews(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
        gen_tintvews(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_data_tintvews; -- เรียกใช้ gen_tintvews

   procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_get_detail;
        if param_msg_error is null then
        gen_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail; -- เรียกใช้ gen_detail

   procedure delete_tintview(json_str_output out clob) as
         json_obj json_object_t;
         v_codform tintview.codform%type;
    begin
        for i in 0..param_json.get_size-1 loop

            v_codform   := upper(hcm_util.get_string_t(param_json,to_char(i)));
            validate_delete(v_codform);

            delete tintview
             where codform  = v_codform;

            delete tintvews
             where codform  = v_codform;

            delete tintvewd
             where codform  = v_codform;

            delete tintscor
             where codform  = v_codform;
        end loop;
        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end delete_tintview; --ลบค่ารหัสแบบฟอร์ม

   procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        delete_tintview(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index; -- เรียกใช้ delete_tintview

   procedure gen_formDetail(p_codform varchar2,p_numgrup number,json_str_output out clob) as
        json_obj json_object_t;
        obj_result json_object_t;
        obj_tab1 json_object_t;
        obj_tab2 json_object_t;
        obj_rows json_object_t;
        obj_data json_object_t;
        v_row number := 0;
        max_score number;
        max_score2 number;
        max_grade number;
        sum_wgt_max_score number;
        rec_tintvews tintvews%rowtype;

        cursor c1 is
            select * from tintvewd
            where numgrup = p_numgrup
            and codform = p_codform
            order by numitem;
        begin
        obj_result  := json_object_t();

        begin
            select * into rec_tintvews
            from tintvews
            where codform = p_codform
            and numgrup = p_numgrup ;

            obj_result.put('flgedit','Edit');
        exception when no_data_found then
            obj_result.put('flgedit','Add');
        begin
            select
            max(qtyscor) into max_grade
            from  tintscor
            where codform = p_codform;
            obj_result.put('max_grade_add',max_grade);
        end;
            rec_tintvews := null;
        end;
            obj_result.put('codform',rec_tintvews.codform);
            obj_result.put('numgrup',rec_tintvews.numgrup);
            obj_result.put('desgrupe',rec_tintvews.desgrupe);
            obj_result.put('desgrupt',rec_tintvews.desgrupt);
            obj_result.put('desgrup3',rec_tintvews.desgrup3);
            obj_result.put('desgrup4',rec_tintvews.desgrup4);
            obj_result.put('desgrup5',rec_tintvews.desgrup5);

        obj_rows := json_object_t();
        for r1 in c1 loop
    begin
            max_score :=0;
            select
            max(qtyscor) into max_score
            from  tintscor
            where codform = r1.codform;

--            sum_wgt_max_score := (r1.qtywgt*max_score);
            sum_wgt_max_score := (max_score);
    end;
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('numgrup',r1.numgrup);
            obj_data.put('numitem',r1.numitem);
            obj_data.put('desiteme',r1.desiteme);
            obj_data.put('definite',r1.definite);
            obj_data.put('desitemt',r1.desitemt);
            obj_data.put('definitt',r1.definitt);
            obj_data.put('desitem3',r1.desitem3);
            obj_data.put('definit3',r1.definit3);
            obj_data.put('desitem4',r1.desitem4);
            obj_data.put('definit4',r1.definit4);
            obj_data.put('desitem5',r1.desitem5);
            obj_data.put('definit5',r1.definit5);
            obj_data.put('qtywgt',r1.qtywgt);
            obj_data.put('max_score',sum_wgt_max_score);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
            obj_result.put('max_grade',max_score);
            obj_result.put('rows',obj_rows);

            obj_data := json_object_t();
            obj_data.put('rows',obj_result);
        json_str_output := obj_data.to_clob;
    end gen_formDetail; --ดึงค่าจากตาราง TINTVEWD TINTVEWS

   procedure get_formDetail(json_str_input in clob, json_str_output out clob) AS
        json_obj json_object_t;
        p_codform tintvews.codform%type;
        p_numgrup tintvews.numgrup%type;
    begin
        initial_value(json_str_input);
        check_get_detail;
        json_obj     := json_object_t(json_str_input);
        p_codform    := upper(hcm_util.get_string_t(json_obj,'p_codform'));
        p_numgrup    := hcm_util.get_string_t(json_obj,'p_numgrup');
        if p_codform is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 70));
        end if;
        if param_msg_error is null then
            gen_formDetail(p_codform,p_numgrup,json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_formDetail; -- เรียกใช้ gen_formDetail

   procedure validate_formDetail(json_str_input in clob, json_str_output out clob) AS

            json_obj json_object_t;
            p_qtywgt number;

    begin
        for i in 0..param_json.get_size-1 loop
            json_obj    := hcm_util.get_json_t(param_json,to_char(i));
            p_qtywgt    := hcm_util.get_string_t(json_obj,'qtywgt');
        if p_qtywgt is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 330));
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
    end loop;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END validate_formDetail; --ตรวจเช็คค่าว่างของน้ำหนักก่อนบันทึก

   procedure check_tab_formDetail(v_codform varchar2 ,v_numgrup number,v_desgrupe varchar2,v_desgrupt varchar2,v_desgrup3 varchar2,v_desgrup4 varchar2,v_desgrup5 varchar2) as
        json_obj    json_object_t;

        v_numitem   tintvewd.numitem%type;
        v_desiteme  tintvewd.desiteme%type;
        v_desitemt  tintvewd.desitemt%type;
        v_desitem3  tintvewd.desitem3%type;
        v_desitem4  tintvewd.desitem4%type;
        v_desitem5  tintvewd.desitem5%type;
        v_qtyfscor  tintvewd.qtyfscor%type;
        v_qtywgt    tintvewd.qtywgt%type;
        v_definitt  tintvewd.definitt%type;
        v_definite  tintvewd.definite%type;
        v_definit3  tintvewd.definit3%type;
        v_definit4  tintvewd.definit4%type;
        v_definit5  tintvewd.definit5%type;
        v_flgedit   varchar2(10 char);
    begin
        for i in 0..param_json.get_size-1 loop
            json_obj       := hcm_util.get_json_t(param_json,to_char(i));
            v_numitem      := hcm_util.get_string_t(json_obj,'numitem');
            v_desiteme     := hcm_util.get_string_t(json_obj,'desiteme');
            v_desitemt     := hcm_util.get_string_t(json_obj,'desitemt');
            v_desitem3     := hcm_util.get_string_t(json_obj,'desitem3');
            v_desitem4     := hcm_util.get_string_t(json_obj,'desitem4');
            v_desitem5     := hcm_util.get_string_t(json_obj,'desitem5');
            v_qtyfscor     := hcm_util.get_string_t(json_obj,'qtyfscor');
            v_qtywgt       := hcm_util.get_string_t(json_obj,'qtywgt');
            v_definitt     := hcm_util.get_string_t(json_obj,'definitt');
            v_definite     := hcm_util.get_string_t(json_obj,'definite');
            v_definit3     := hcm_util.get_string_t(json_obj,'definit3');
            v_definit4     := hcm_util.get_string_t(json_obj,'definit4');
            v_definit5     := hcm_util.get_string_t(json_obj,'definit5');
            v_flgedit      := hcm_util.get_string_t(json_obj,'flgedit');
            if (v_numitem is null) then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 550));
                return;
            end if;
            if (v_codform is null) then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 390));
                return;
            end if;
            if (global_v_lang ='101') and ((v_desiteme is null) or (v_definite is null) or (v_desgrupe is null)) then
                if v_desiteme is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 560));
                elsif v_definite is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 580));
                elsif v_desgrupe is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 570));
                end if;
                return;
            end if;
            if (global_v_lang ='102') and ((v_desitemt is null) or (v_definitt is null) or (v_desgrupt is null)) then
                if v_desitemt is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 560));
                elsif v_definitt is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 580));
                elsif v_desgrupt is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 570));
                end if;
                return;
            end if;
            if (global_v_lang ='103') and ((v_desitem3 is null) or (v_definit3 is null) or (v_desgrup3 is null)) then
                if v_desitem3 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 560));
                elsif v_definit3 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 580));
                elsif v_desgrup3 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 570));
                end if;
                return;
            end if;
            if (global_v_lang ='104') and ((v_desitem4 is null) or (v_definit4 is null) or (v_desgrup4 is null)) then
                if v_desitem4 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 560));
                elsif v_definit4 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 580));
                elsif v_desgrup4 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 570));
                end if;
                return;
            end if;
            if (global_v_lang ='105') and ((v_desitem5 is null) or (v_definit5 is null) or (v_desgrup5 is null)) then
                if v_desitem5 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 560));
                elsif v_definit5 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 580));
                elsif v_desgrup5 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRCO2BE', global_v_lang, 570));
                end if;
                return;
            end if;
        end loop;
    end check_tab_formDetail; --ตรวจสอบค่าว่างตามภาษาที่ใช้

   procedure save_data_formDetail(v_codform varchar2,v_flgedit varchar2,v_numgrup number,json_str_output out clob) as
        json_obj    json_object_t;
        v_numitem      tintvewd.numitem%type;
        v_desiteme     tintvewd.desiteme%type;
        v_desitemt     tintvewd.desitemt%type;
        v_desitem3     tintvewd.desitem3%type;
        v_desitem4     tintvewd.desitem4%type;
        v_desitem5     tintvewd.desitem5%type;
        v_qtyfscor     tintvewd.qtyfscor%type;
        v_definitt     tintvewd.definitt%type;
        v_definite     tintvewd.definit3%type;
        v_definit3     tintvewd.definit4%type;
        v_definit4     tintvewd.definit5%type;
        v_definit5     tintvewd.definit5%type;
        v_qtywgt       tintvewd.qtywgt%type;
        v_item_flgedit varchar2(10 char);
        v_sum_qtyfscor number;
             max_score number;
        v_wight_result number;
        sum_qtyfscor_i number;
        sum_qtyfscor_tintvews number;
    begin
        v_sum_qtyfscor :=0;
        for i in 0..param_json.get_size-1 loop
            json_obj    := hcm_util.get_json_t(param_json,to_char(i));
            v_numitem   := to_number(hcm_util.get_string_t(json_obj,'numitem'));
            v_desiteme  := hcm_util.get_string_t(json_obj,'desiteme');
            v_desitemt  := hcm_util.get_string_t(json_obj,'desitemt');
            v_desitem3  := hcm_util.get_string_t(json_obj,'desitem3');
            v_desitem4  := hcm_util.get_string_t(json_obj,'desitem4');
            v_desitem5  := hcm_util.get_string_t(json_obj,'desitem5');
            v_qtyfscor  := to_number(hcm_util.get_string_t(json_obj,'max_score'));
            v_definitt  := hcm_util.get_string_t(json_obj,'definitt');
            v_definite  := hcm_util.get_string_t(json_obj,'definite');
            v_definit3  := hcm_util.get_string_t(json_obj,'definit3');
            v_definit4  := hcm_util.get_string_t(json_obj,'definit4');
            v_definit5  := hcm_util.get_string_t(json_obj,'definit5');
            v_qtywgt    := to_number(hcm_util.get_string_t(json_obj,'qtywgt'));
            v_item_flgedit := hcm_util.get_string_t(json_obj,'flgedit');
            if v_item_flgedit = 'Add' then
                begin
                    insert into tintvewd (codform,numgrup,numitem,desiteme,desitemt
                                ,desitem3,desitem4,desitem5,qtyfscor,definitt,definite,definit3,definit4,definit5,qtywgt,dtecreate,codcreate,dteupd,coduser)
                         values (v_codform,v_numgrup,v_numitem,v_desiteme,v_desitemt
                                ,v_desitem3,v_desitem4,v_desitem5,v_qtyfscor,v_definitt,v_definite,v_definit3,v_definit4,v_definit5,v_qtywgt,sysdate,global_v_coduser,sysdate
                                ,global_v_coduser);
                exception when dup_val_on_index then
                  update tintvewd
                     set desiteme = v_desiteme,
                         desitemt = v_desitemt,
                         desitem3 = v_desitem3,
                         desitem4 = v_desitem4,
                         desitem5 = v_desitem5,
                         qtyfscor = v_qtyfscor,
                         qtywgt   = v_qtywgt,
                         definitt = v_definitt,
                         definite = v_definite,
                         definit3 = v_definit3,
                         definit4 = v_definit4,
                         definit5 = v_definit5,
                         dteupd   = sysdate,
                         coduser  = global_v_coduser
                   where codform  = v_codform
                     and numgrup  = v_numgrup
                     and numitem  = v_numitem;
                end;
            elsif v_item_flgedit = 'Edit' then
                update tintvewd
                   set desiteme = v_desiteme,
                       desitemt = v_desitemt,
                       desitem3 = v_desitem3,
                       desitem4 = v_desitem4,
                       desitem5 = v_desitem5,
                       qtyfscor = v_qtyfscor,
                       qtywgt   = v_qtywgt,
                       definitt = v_definitt,
                       definite = v_definite,
                       definit3 = v_definit3,
                       definit4 = v_definit4,
                       definit5 = v_definit5,
                       dteupd   = sysdate,
                       coduser  = global_v_coduser
                 where codform  = v_codform
                   and numgrup  = v_numgrup
                   and numitem  = v_numitem;
            elsif v_item_flgedit = 'Delete' then
                delete from tintvewd
                 where codform  = v_codform
                   and numgrup  = v_numgrup
                   and numitem  = v_numitem;
            end if;
                    select sum(qtyfscor) into sum_qtyfscor_i
                    from tintvewd
                    where codform  = v_codform
                    and   numgrup  = v_numgrup;

                    update tintvews
                    set qtyfscor   = sum_qtyfscor_i
                    where codform  = v_codform
                    and   numgrup  = v_numgrup;

                    select sum(qtyfscor) into sum_qtyfscor_tintvews
                    from tintvews
                    where codform  = v_codform;

                    update tintview
                    set  qtytscor   = sum_qtyfscor_tintvews
                    where codform  = v_codform;

        end loop;


        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_data_formDetail; -- INSERT UPDATE DELETE ค่าในตาราง TINTVEWD TINTVEWS

   procedure save_data_GroupDetail(
   v_codform varchar2,
   v_flgedit_grup varchar2,
   v_numgrup number,
   v_desgrupe varchar2,
   v_desgrupt varchar2,
   v_desgrup3 varchar2,
   v_desgrup4 varchar2,
   v_desgrup5 varchar2,
   json_str_output out clob) as

    begin
            if v_flgedit_grup = 'Add' then
                begin
                    insert into tintvews (codform,numgrup,desgrupt,desgrupe,desgrup3,desgrup4,desgrup5,dtecreate,codcreate,dteupd,coduser)
                         values (v_codform,v_numgrup,v_desgrupt,v_desgrupe,v_desgrup3,v_desgrup4
                                ,v_desgrup5,sysdate,global_v_coduser,sysdate,global_v_coduser);
                  exception when dup_val_on_index then
                    update tintvews
                       set desgrupt = v_desgrupt,
                           desgrupe = v_desgrupe,
                           desgrup3 = v_desgrup3,
                           desgrup4 = v_desgrup4,
                           desgrup5 = v_desgrup5,
                           dteupd   = sysdate,
                           coduser  = global_v_coduser
                     where codform  = v_codform
                        and numgrup = v_numgrup;
                end;
            elsif v_flgedit_grup = 'Edit' then
                update tintvews
                   set desgrupt = v_desgrupt,
                       desgrupe = v_desgrupe,
                       desgrup3 = v_desgrup3,
                       desgrup4 = v_desgrup4,
                       desgrup5 = v_desgrup5,
                       dteupd   = sysdate,
                       coduser  = global_v_coduser
                 where codform  = v_codform
                    and numgrup = v_numgrup;
            end if;

    end save_data_GroupDetail;  -- SAVE ข้อมูลรายละเอียดส่วน

   procedure get_copy_codform(json_str_input in clob, json_str_output out clob) as
     json_obj      json_object_t;
            obj_data_index    json_object_t;
             obj_row_index    json_object_t;
                     v_row	  number := 0;

                cursor c3 is
                select *
                from tintview
                order by codform;
          begin
          initial_value(json_str_input);
            obj_row_index    := json_object_t();
            for i in c3 loop
                v_row := v_row + 1;
                obj_data_index := json_object_t();
                obj_data_index.put('coderror','200');
                obj_data_index.put('codform',i.codform);
                if(global_v_lang='101') then
                    obj_data_index.put('desform',i.desforme);
                elsif(global_v_lang='102') then
                    obj_data_index.put('desform',i.desformt);
                elsif(global_v_lang='103') then
                    obj_data_index.put('desform',i.desform3);
                elsif(global_v_lang='104') then
                    obj_data_index.put('desform',i.desform4);
                elsif(global_v_lang='105') then
                    obj_data_index.put('desform',i.desform5);
                end if;
                obj_data_index.put('typform',i.typform);
                obj_data_index.put('des_typform',GET_TLISTVAL_NAME('TYPFORM',i.typform,global_v_lang));
                obj_data_index.put('dteupd',i.dteupd);
                obj_data_index.put('coduser',i.coduser);
                obj_row_index.put(to_char(v_row-1),obj_data_index);
            end loop;
                json_str_output := obj_row_index.to_clob;
            exception when others then
                param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_copy_codform; -- copy ค่าตามรหัสแบบฟอร์ม

   procedure save_formDetail(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        v_codform     tintvewd.codform%type;
        v_numgrup     tintvewd.numgrup%type;
        v_desgrupe    tintvews.desgrupe%type;
        v_desgrupt    tintvews.desgrupt%type;
        v_desgrup3    tintvews.desgrup3%type;
        v_desgrup4    tintvews.desgrup4%type;
        v_desgrup5    tintvews.desgrup5%type;
        v_flgedit        varchar2(10 char);
        v_flgedit_grup   varchar2(10 char);
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        v_flgedit   := hcm_util.get_string_t(json_obj,'flgedit');
        v_flgedit_grup   := hcm_util.get_string_t(json_obj,'p_flgedit');
        v_codform   := upper(hcm_util.get_string_t(json_obj,'p_codform'));
        v_numgrup   := to_number(hcm_util.get_string_t(json_obj,'p_numgrup'));
        v_desgrupe  := hcm_util.get_string_t(json_obj,'p_desgrupe');
        v_desgrupt  := hcm_util.get_string_t(json_obj,'p_desgrupt');
        v_desgrup3  := hcm_util.get_string_t(json_obj,'p_desgrup3');
        v_desgrup4  := hcm_util.get_string_t(json_obj,'p_desgrup4');
        v_desgrup5  := hcm_util.get_string_t(json_obj,'p_desgrup5');
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        check_tab_formDetail(v_codform,v_numgrup,v_desgrupe,v_desgrupt,v_desgrup3,v_desgrup4,v_desgrup5);
        if param_msg_error is null then
            save_data_GroupDetail(v_codform,v_flgedit_grup,v_numgrup,v_desgrupe,v_desgrupt,v_desgrup3,v_desgrup4,v_desgrup5,json_str_output);
            save_data_formDetail(v_codform,v_flgedit,v_numgrup,json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_formDetail; --เรียกใช้ check_tab_formDetail save_data_GroupDetail save_data_formDetail

   procedure save_Grade(v_codform varchar2,v_flgedit varchar2, json_str_output out clob) as
        json_obj    json_object_t;
        obj_numgrup  json_object_t;
        v_numgrup     tintvews.numgrup%type;
        v_grditem     tintscor.grditem%type;
        v_grad        tintscor.grad%type;
        v_qtyscor     tintscor.qtyscor%type;
        v_descgrde    tintscor.descgrde%type;
        v_descgrdt    tintscor.descgrdt%type;
        v_descgrd3    tintscor.descgrd3%type;
        v_descgrd4    tintscor.descgrd4%type;
        v_descgrd5    tintscor.descgrd5%type;
        v_definitt    tintscor.definitt%type;
        v_definite    tintscor.definite%type;
        v_definit3    tintscor.definit3%type;
        v_definit4    tintscor.definit4%type;
        v_definit5    tintscor.definit5%type;
        v_numgroup    tintvews.numgrup%type;
        v_qtywgt      tintvewd.qtywgt%type;
        v_qtywgt_add  tintvewd.qtywgt%type;
        v_qtywgt_del  tintvewd.qtywgt%type;
        vx_qtywgt     number;
        max_value     number;
        sum_value     number;
        qtywgt_value  number;
        sum_qtyfscor  number;
        sum_qtyfscor_tintvews number;
        cursor c_tintvews is
        select * from tintvews
        where codform = v_codform;

        cursor c_tintvewd is
        select * from tintvewd
        where codform = v_codform;

        v_item_flgedit   varchar2(10 char);
    begin
        for i in 0..param_json.get_size-1 loop

            json_obj    := hcm_util.get_json_t(param_json,to_char(i));
            v_grditem   := hcm_util.get_string_t(json_obj,'grditem');
            v_grad      := hcm_util.get_string_t(json_obj,'grad');
            v_qtyscor   := to_number(hcm_util.get_string_t(json_obj,'qtyscor'));
            v_descgrde  := hcm_util.get_string_t(json_obj,'descgrde');
            v_descgrdt  := hcm_util.get_string_t(json_obj,'descgrdt');
            v_descgrd3  := hcm_util.get_string_t(json_obj,'descgrd3');
            v_descgrd4  := hcm_util.get_string_t(json_obj,'descgrd4');
            v_descgrd5  := hcm_util.get_string_t(json_obj,'descgrd5');
            v_definitt  := hcm_util.get_string_t(json_obj,'definitt');
            v_definite  := hcm_util.get_string_t(json_obj,'definite');
            v_definit3  := hcm_util.get_string_t(json_obj,'definit3');
            v_definit4  := hcm_util.get_string_t(json_obj,'definit4');
            v_definit5  := hcm_util.get_string_t(json_obj,'definit5');
            obj_numgrup := hcm_util.get_json_t(param_json,'del_numgrup');
            v_item_flgedit := hcm_util.get_string_t(json_obj,'flgedit');
            if v_item_flgedit = 'Add' then
                begin
                    insert into tintscor (codform,grditem,grad,qtyscor,descgrde
                                ,descgrdt,descgrd3,descgrd4,descgrd5,definitt,definite,definit3,definit4,definit5,dtecreate,codcreate,dteupd,coduser)
                         values (v_codform,v_grditem,v_grad,v_qtyscor,v_descgrde
                                ,v_descgrdt,v_descgrd3,v_descgrd4,v_descgrd5,v_definitt,v_definite,v_definit3,v_definit4,v_definit5,sysdate,global_v_coduser,sysdate
                                ,global_v_coduser);

                exception when dup_val_on_index then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tintscor');
                    rollback;
                    exit;
                end;
            elsif v_item_flgedit = 'Edit' then
                update tintscor
                   set grad     = v_grad,
                       qtyscor  = v_qtyscor,
                       descgrde = v_descgrde,
                       descgrdt = v_descgrdt,
                       descgrd3 = v_descgrd3,
                       descgrd4 = v_descgrd4,
                       descgrd5 = v_descgrd5,
                       definitt = v_definitt,
                       definite = v_definite,
                       definit3 = v_definit3,
                       definit4 = v_definit4,
                       definit5 = v_definit5,
                       dteupd   = sysdate,
                       coduser  = global_v_coduser
                 where codform  = v_codform
                   and grditem  = v_grditem;

            elsif v_item_flgedit = 'Delete' then
                delete from tintscor
                 where codform  = v_codform
                   and grditem  = v_grditem;

            end if;
        end loop;
                    select max(qtyscor) into max_value
                    from tintscor
                    where codform = v_codform;
                    sum_value := max_value;

                    for t1 in c_tintvewd loop
                    v_qtywgt  := t1.qtywgt;
                    update tintvewd
                    set    qtyfscor = (v_qtywgt*sum_value)
                    where  codform  = v_codform
                    and    numgrup  = t1.numgrup
                    and    numitem  = t1.numitem;

                    select sum(qtyfscor) into sum_qtyfscor
                    from tintvewd
                    where codform = v_codform
                    and   numgrup  = t1.numgrup;

                    update tintvews
                    set qtyfscor = sum_qtyfscor
                    where codform = v_codform
                    and   numgrup  = t1.numgrup;

                    select sum(qtyfscor) into sum_qtyfscor_tintvews
                    from tintvews
                    where codform = v_codform;

                    update tintview
                    set qtytscor = sum_qtyfscor_tintvews
                    where codform = v_codform;
                    end loop;

        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    end save_Grade; -- ADD UPDATE DELETE ค่าในตาราง TINTVEWD TINTVEWS TINTSCOR

   procedure delete_formDetail(v_codform varchar2,param_numgrup json_object_t,json_str_output out clob) AS
        v_numgrup tintvews.numgrup%type;
      begin
        for i_grup in 0..param_numgrup.get_size-1 loop
        v_numgrup    := to_number(hcm_util.get_string_t(param_numgrup,to_char(i_grup)));
        delete tintvews
         where codform  = v_codform
           and numgrup  = v_numgrup;

        delete tintvewd
         where codform  = v_codform
           and numgrup  = v_numgrup;
        end loop;

    END delete_formDetail; --ลบค่าส่วนที่

   procedure save_formDetailCopy(v_codform varchar2,v_codform_copy varchar2,param_numgrup json_object_t,json_str_output out clob) AS
        json_obj    json_object_t;
        obj_result  json_object_t;
        v_numgrup tintvews.numgrup%type;
        rec_tintvewd tintvewd%rowtype;
        rec_tintvews tintvews%rowtype;
        num_data tintvewd.numitem%type;
        sum_qtyfscor_i number;
        sum_qtyfscor_tintvews number;
        cursor v_numitem is
        select *
        from tintvewd
        where upper(codform) = v_codform_copy
        and numgrup = v_numgrup;
      begin

        for i_grup in 0..param_numgrup.get_size-1 loop
            v_numgrup    := to_number(hcm_util.get_string_t(param_numgrup,to_char(i_grup)));

            select * into rec_tintvews
            from tintvews
            where upper(codform) = v_codform_copy
            and numgrup = v_numgrup;

                    insert into tintvews (codform,numgrup,desgrupe,desgrupt
                                ,desgrup3,desgrup4,desgrup5,qtyfscor,dtecreate,codcreate,dteupd,coduser)
                         values (v_codform,rec_tintvews.numgrup,rec_tintvews.desgrupe,rec_tintvews.desgrupt
                                ,rec_tintvews.desgrup3,rec_tintvews.desgrup4,rec_tintvews.desgrup5,rec_tintvews.qtyfscor,sysdate,global_v_coduser,sysdate
                                ,global_v_coduser);

            for c_item in v_numitem loop
            select * into rec_tintvewd
            from tintvewd
            where upper(codform) = v_codform_copy
            and numgrup = v_numgrup
            and numitem = c_item.numitem;
                    insert into tintvewd (codform,numgrup,numitem,desiteme,desitemt
                                ,desitem3,desitem4,desitem5,qtyfscor,definitt,definite,definit3,definit4,definit5,qtywgt,dtecreate,codcreate,dteupd,coduser)
                         values (v_codform,rec_tintvewd.numgrup,rec_tintvewd.numitem,rec_tintvewd.desiteme,rec_tintvewd.desitemt
                                ,rec_tintvewd.desitem3,rec_tintvewd.desitem4,rec_tintvewd.desitem5,rec_tintvewd.qtyfscor,rec_tintvewd.definitt,rec_tintvewd.definite,rec_tintvewd.definit3,
                                rec_tintvewd.definit4,rec_tintvewd.definit5,rec_tintvewd.qtywgt,sysdate,global_v_coduser,sysdate
                                ,global_v_coduser);
           end loop;
        end loop;

        select sum(qtyfscor) into sum_qtyfscor_i
        from tintvewd
        where codform  = v_codform
        and   numgrup  = v_numgrup;

        update tintvews
        set qtyfscor   = sum_qtyfscor_i
        where codform  = v_codform
        and   numgrup  = v_numgrup;

        select sum(qtyfscor) into sum_qtyfscor_tintvews
        from tintvews
        where codform  = v_codform;

        update tintview
        set  qtytscor   = sum_qtyfscor_tintvews
        where codform  = v_codform;

        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
    END save_formDetailCopy; --ลบค่าส่วนที่

   procedure save_GradeCopy(v_codform varchar2,v_codform_copy varchar2,v_flgedit varchar2, json_str_output out clob) as
        json_obj    json_object_t;
        v_numgrup     tintvews.numgrup%type;
        v_grditem     tintscor.grditem%type;
        v_grad        tintscor.grad%type;
        v_qtyscor     tintscor.qtyscor%type;
        v_descgrde    tintscor.descgrde%type;
        v_descgrdt    tintscor.descgrdt%type;
        v_descgrd3    tintscor.descgrd3%type;
        v_descgrd4    tintscor.descgrd4%type;
        v_descgrd5    tintscor.descgrd5%type;
        v_definitt    tintscor.definitt%type;
        v_definite    tintscor.definite%type;
        v_definit3    tintscor.definit3%type;
        v_definit4    tintscor.definit4%type;
        v_definit5    tintscor.definit5%type;
        v_numgroup    tintvews.numgrup%type;
        v_qtywgt      tintvewd.qtywgt%type;
        max_value     number;
        sum_value     number;
        sum_qtyfscor  number;
        sum_qtyfscor_tintvews number;
        v_item_flgedit   varchar2(10 char);

        cursor c_tintvewd is
        select * from tintvewd
        where codform = v_codform;
    begin
        for i in 0..param_json.get_size-1 loop

            json_obj    := hcm_util.get_json_t(param_json,to_char(i));
            v_grditem   := hcm_util.get_string_t(json_obj,'grditem');
            v_grad      := hcm_util.get_string_t(json_obj,'grad');
            v_qtyscor   := to_number(hcm_util.get_string_t(json_obj,'qtyscor'));
            v_descgrde  := hcm_util.get_string_t(json_obj,'descgrde');
            v_descgrdt  := hcm_util.get_string_t(json_obj,'descgrdt');
            v_descgrd3  := hcm_util.get_string_t(json_obj,'descgrd3');
            v_descgrd4  := hcm_util.get_string_t(json_obj,'descgrd4');
            v_descgrd5  := hcm_util.get_string_t(json_obj,'descgrd5');
            v_definitt  := hcm_util.get_string_t(json_obj,'definitt');
            v_definite  := hcm_util.get_string_t(json_obj,'definite');
            v_definit3  := hcm_util.get_string_t(json_obj,'definit3');
            v_definit4  := hcm_util.get_string_t(json_obj,'definit4');
            v_definit5  := hcm_util.get_string_t(json_obj,'definit5');
            v_item_flgedit := hcm_util.get_string_t(json_obj,'flgedit');
            if v_item_flgedit = 'Add' then
                begin
                    insert into tintscor (codform,grditem,grad,qtyscor,descgrde
                                ,descgrdt,descgrd3,descgrd4,descgrd5,definitt,definite,definit3,definit4,definit5,dtecreate,codcreate,dteupd,coduser)
                         values (v_codform,v_grditem,v_grad,v_qtyscor,v_descgrde
                                ,v_descgrdt,v_descgrd3,v_descgrd4,v_descgrd5,v_definitt,v_definite,v_definit3,v_definit4,v_definit5,sysdate,global_v_coduser,sysdate
                                ,global_v_coduser);
                exception when dup_val_on_index then
                  update tintscor
                     set grad        = v_grad,
                         qtyscor     = v_qtyscor,
                         descgrde    = v_descgrde,
                         descgrdt    = v_descgrdt,
                         descgrd3    = v_descgrd3,
                         descgrd4    = v_descgrd4,
                         descgrd5    = v_descgrd5,
                         definitt    = v_definitt,
                         definite    = v_definite,
                         definit3    = v_definit3,
                         definit4    = v_definit4,
                         definit5    = v_definit5,
                         coduser     = global_v_coduser
                   where codform     = v_codform
                     and grditem     = v_grditem;
                end;
            end if;
        end loop;
        select max(qtyscor) into max_value
                    from tintscor
                    where codform = v_codform;
                    sum_value := max_value;

                    for t1 in c_tintvewd loop
                    v_qtywgt  := t1.qtywgt;
                    update tintvewd
                    set    qtyfscor = (v_qtywgt*sum_value)
                    where  codform  = v_codform
                    and    numgrup  = t1.numgrup
                    and    numitem  = t1.numitem;

                    select sum(qtyfscor) into sum_qtyfscor
                    from tintvewd
                    where codform = v_codform
                    and   numgrup  = t1.numgrup;

                    update tintvews
                    set qtyfscor = sum_qtyfscor
                    where codform = v_codform
                    and   numgrup  = t1.numgrup;

                    select sum(qtyfscor) into sum_qtyfscor_tintvews
                    from tintvews
                    where codform = v_codform;

                    update tintview
                    set qtytscor = sum_qtyfscor_tintvews
                    where codform = v_codform;
                    end loop;

    end save_GradeCopy;  --บันทึกค่าที่คัดลอกมาลงตาราง TINTSCOR

   procedure save_dataTintview(
   v_codform varchar2,
   v_figedit varchar2,
   v_desformt varchar2,
   v_desforme varchar2,
   v_desform3 varchar2,
   v_desform4 varchar2,
   v_desform5 varchar2,
   v_typform varchar2,
   v_qtytscor number,
   json_str_output out clob)AS

    begin
            if v_figedit = 'Add' then
                begin
                    insert into tintview (codform,desformt,desforme,desform3,desform4,desform5,typform,qtytscor,dtecreate,codcreate,dteupd,coduser)
                         values (v_codform,v_desformt,v_desforme,v_desform3,v_desform4
                                ,v_desform5,v_typform,v_qtytscor,sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tintview');
                    rollback;
                end;
            elsif v_figedit = 'Edit' then
                update tintview
                   set desformt = v_desformt,
                       desforme = v_desforme,
                       desform3 = v_desform3,
                       desform4 = v_desform4,
                       desform5 = v_desform5,
                       typform  = v_typform,
                       qtytscor = v_qtytscor,
                       dteupd   = sysdate,
                       coduser  = global_v_coduser
                 where codform  = v_codform;
            end if;

  END save_dataTintview; -- บันทีกรายละเอียดแบบฟอร์ม

   procedure delete_grupChoice(v_codform varchar2,json_str_output out clob) as
         json_obj json_object_t;
    begin
            delete tintvews
             where codform  = v_codform;

            delete tintvewd
             where codform  = v_codform;

            delete tintscor
             where codform  = v_codform;

    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end delete_grupChoice; --prepare to copy

   procedure save_gradeDetail(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        param_numgrup json_object_t;
        v_flgedit   varchar2(10 char);
        v_codform  tintscor.codform%type;
        v_numgrup  tintvews.numgrup%type;
        v_typform   tintview.typform%type;
        v_desforme  tintview.desformt%type;
        v_desformt  tintview.desforme%type;
        v_desform3  tintview.desform3%type;
        v_desform4  tintview.desform4%type;
        v_desform5  tintview.desform5%type;
        v_qtytscor  tintview.qtytscor%type;
        v_codform_copy tintscor.codform%type;
        v_isCopy   varchar2(1 char);
    begin
        initial_value(json_str_input);
        json_obj       := json_object_t(json_str_input);
        v_flgedit      := hcm_util.get_string_t(json_obj,'flgedit');
        v_codform      := upper(hcm_util.get_string_t(json_obj,'p_codform'));
        v_numgrup      := hcm_util.get_string_t(json_obj,'p_numgrup');
        v_typform      := hcm_util.get_string_t(json_obj,'p_typform');
        v_desformt     := hcm_util.get_string_t(json_obj,'p_desformt');
        v_desforme     := hcm_util.get_string_t(json_obj,'p_desforme');
        v_desform3     := hcm_util.get_string_t(json_obj,'p_desform3');
        v_desform4     := hcm_util.get_string_t(json_obj,'p_desform4');
        v_desform5     := hcm_util.get_string_t(json_obj,'p_desform5');
        v_qtytscor     := hcm_util.get_string_t(json_obj,'p_qtytscor');
        param_json     := hcm_util.get_json_t(json_obj,'tab1');
        param_numgrup  := hcm_util.get_json_t(json_obj,'tab2');
        v_isCopy       := hcm_util.get_string_t(json_obj,'isCopy');
        v_codform_copy := upper(hcm_util.get_string_t(json_obj,'p_codform_copy'));
        validate_saveGrade(v_codform,v_typform,v_desformt,v_desform3,v_desform4,v_desform5,v_desforme,param_json);
        if param_msg_error is null then
            if v_isCopy = 'Y' then -- ถ้า copy เข้าโหมด
                delete_grupChoice(v_codform,json_str_output);
                save_dataTintview(v_codform,v_flgedit,v_desformt,v_desforme,v_desform3,v_desform4,v_desform5,v_typform,v_qtytscor,json_str_output);
                save_formDetailCopy(v_codform,v_codform_copy,param_numgrup,json_str_output);
                save_GradeCopy(v_codform,v_codform_copy,v_flgedit,json_str_output);
            else
                save_dataTintview(v_codform,v_flgedit,v_desformt,v_desforme,v_desform3,v_desform4,v_desform5,v_typform,v_qtytscor,json_str_output);
                delete_formDetail(v_codform,param_numgrup,json_str_output);
                save_Grade(v_codform,v_flgedit,json_str_output);
            end if;
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
            rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_gradeDetail; -- เรียกใช้ save_dataTintview validate_saveGrade delete_formDetail save_Grade

    procedure clear_ttemprpt is
        begin
            begin
                delete
                from  ttemprpt
                where codempid = global_v_codempid
                and   codapp   = p_codapp;
            exception when others then
        null;
        end;
    end clear_ttemprpt; -- clear temp

    procedure gen_report_tintscor(json_str_output out clob) is
        descgrd tintscor.descgrde%type;
        definit tintscor.definite%type;
        desform tintview.desforme%type;
        json_obj json_object_t;
        v_codform tintview.codform%type;
        max_numseq number;
        p_numseq   number;
        rec_tintview tintview%rowtype;
        cursor r_tintscor is
        select *
        from tintscor
        where upper(codform) = v_codform order by qtyscor desc;


    begin
        for i in 0..param_json.get_size-1 loop

            v_codform   := upper(hcm_util.get_string_t(param_json,to_char(i)));
        for rtap1 in r_tintscor loop
            begin
                select max(numseq) into max_numseq
                from ttemprpt where codempid = global_v_codempid
                and codapp = p_codapp;
                if max_numseq is null then
                max_numseq :=0 ;
                end if;
                end;

                select * into rec_tintview
                from tintview
                where codform = rtap1.codform;

                 p_numseq := max_numseq+1;
                if(global_v_lang='101') then
                    desform := rec_tintview.desforme;
                    descgrd := rtap1.descgrde;
                    definit := rtap1.definite;
                elsif(global_v_lang='102') then
                    desform := rec_tintview.desformt;
                    descgrd := rtap1.descgrdt;
                    definit := rtap1.definitt;
                elsif(global_v_lang='103') then
                    desform := rec_tintview.desform3;
                    descgrd := rtap1.descgrd3;
                    definit := rtap1.definit3;
                elsif(global_v_lang='104') then
                    desform := rec_tintview.desform4;
                    descgrd := rtap1.descgrd4;
                    definit := rtap1.definit4;
                elsif(global_v_lang='105') then
                    desform := rec_tintview.desform5;
                    descgrd := rtap1.descgrd5;
                    definit := rtap1.definit5;
                end if;
            insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3
                    ,item4,item5,item6,item7,item8,item9)
            values (global_v_codempid,p_codapp,p_numseq,'tab1',v_codform,rtap1.grditem
                    ,rtap1.grad,to_char(rtap1.qtyscor,'fm999,999,999,990.00'),descgrd,definit,desform,rec_tintview.qtytscor);
         end loop;
        end loop;


    end gen_report_tintscor;

    procedure gen_report_tintvewd(json_str_output out clob) is
        desitem tintvewd.desiteme%type;
        definit tintvewd.definite%type;
        v_codform tintview.codform%type;
        desgrup tintvews.desgrupe%type;
        rec_tintvews tintvews%rowtype;
        max_numseq number;
        p_numseq   number;
        cursor r_tintvewd is
        select *
        from tintvewd
        where upper(codform) = v_codform;


    begin
        for i in 0..param_json.get_size-1 loop

            v_codform   := upper(hcm_util.get_string_t(param_json,to_char(i)));
        for rtap2 in r_tintvewd loop
            begin
                select max(numseq) into max_numseq
                from ttemprpt where codempid = global_v_codempid
                and codapp = p_codapp;
                if max_numseq is null then
                max_numseq :=0 ;
                end if;
                end;
                p_numseq := max_numseq+1;

                select * into rec_tintvews
                from tintvews
                where codform = rtap2.codform
                and numgrup = rtap2.numgrup;

                if(global_v_lang='101') then
                    desgrup :=rec_tintvews.desgrupe;
                    desitem := rtap2.desiteme;
                    definit := rtap2.definite;
                elsif(global_v_lang='102') then
                    desgrup :=rec_tintvews.desgrupt;
                    desitem := rtap2.desitemt;
                    definit := rtap2.definitt;
                elsif(global_v_lang='103') then
                    desgrup :=rec_tintvews.desgrup3;
                    desitem := rtap2.desitem3;
                    definit := rtap2.definit3;
                elsif(global_v_lang='104') then
                    desgrup :=rec_tintvews.desgrup4;
                    desitem := rtap2.desitem4;
                    definit := rtap2.definit4;
                elsif(global_v_lang='105') then
                    desgrup :=rec_tintvews.desgrup5;
                    desitem := rtap2.desitem5;
                    definit := rtap2.definit5;
                end if;
            insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3
                    ,item4,item5,item6,item7,item8,item9,item10)
            values (global_v_codempid,p_codapp,p_numseq,'tab2',v_codform,rtap2.numgrup
                    ,rtap2.numitem,desitem,to_char(rtap2.qtyfscor,'fm999,999,999,990.00'),to_char(rtap2.qtywgt,'fm999,999,999,990.00'),definit,desgrup,to_char(rec_tintvews.qtyfscor,'fm999,999,999,990.00'));
         end loop;
        end loop;


    end gen_report_tintvewd;
     procedure get_report(json_str_input in clob, json_str_output out clob) as
 json_obj    json_object_t;
        v_codform     tintvewd.codform%type;
        v_numgrup     tintvewd.numgrup%type;
        v_desgrupe    tintvews.desgrupe%type;
        v_desgrupt    tintvews.desgrupt%type;
        v_desgrup3    tintvews.desgrup3%type;
        v_desgrup4    tintvews.desgrup4%type;
        v_desgrup5    tintvews.desgrup5%type;
        v_flgedit        varchar2(10 char);
        v_flgedit_grup   varchar2(10 char);
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        v_flgedit   := hcm_util.get_string_t(json_obj,'flgedit');
        v_codform   := upper(hcm_util.get_string_t(json_obj,'p_codform'));
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
            clear_ttemprpt;
        if param_msg_error is null then
            gen_report_tintscor(json_str_output);
            gen_report_tintvewd(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_report;

END HRCO2BE;

/

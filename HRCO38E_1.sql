--------------------------------------------------------
--  DDL for Package Body HRCO38E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO38E" as

    -- Update 03/10/2019 16:45

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codapp      := upper(hcm_util.get_string_t(json_obj,'p_codapp'));
        p_desc        := lower(hcm_util.get_string_t(json_obj,'p_desc'));
        p_value       := upper(hcm_util.get_string_t(json_obj,'p_value'));

    end initial_value;

    procedure gen_index(json_str_output out clob) as
        obj_result  json_object_t;
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
--        v_typeauth  tusrprof.typeauth%type;
        v_desc            tlistval.desc_label%type := '%';
        v_value           tlistval.list_value%type := '%';
        cursor c_tlistval is
            select * from tlistval
            where codapp = nvl(p_codapp,codapp)
            and   codlang = global_v_lang
            --and  codapp in (select codapp from tlistval where upper(desc_label) like '%'||upper(v_desc)||'%' and numseq = 0)
            and  codapp in (select codapp from tlistval where upper(desc_label) like '%'||upper(v_desc)||'%' )
            and  codapp in (select codapp from tlistval where upper(list_value) like v_value and numseq <> 0)
            and   numseq = 0
            order by codapp,numseq;
--          select *
--            from tlistval
--           where codapp = nvl(p_codapp,codapp)
--             and codlang = global_v_lang
--             and ((desc_label like '%'||p_desc||'%'  and numseq = 0) or
--                   (list_value like '%'||p_value||'%'  and numseq <> 0) )
--          order by codapp,numseq;
    begin
        if p_desc is not null then
            v_desc  := '%'||p_desc||'%';
        end if;
        if p_value is not null then
            v_value := '%'||p_value||'%';
        end if;

        obj_rows := json_object_t();
        for i in c_tlistval loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('codapp',i.codapp);
            obj_data.put('desc_label',i.desc_label);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_rows.to_clob;
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure check_get_detail as
        v_temp varchar2(1 char);
    begin
        if p_codapp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- กรณีที่ระบุประเภทข้อมูลที่ไม่มีในระบบให้ Alert HR2010 ข้อมูลไม่มีอยู่ในฐานข้อมูล(TLISTVAL)
        begin
            select 'X' into v_temp
            from tlistval
            where codapp = p_codapp
            and numseq = 0
            and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TLISTVAL');
            return;
        end;
    end check_get_detail;

    procedure gen_detail(json_str_output out clob) as
        obj_result    json_object_t;
        obj_rows      json_object_t;
        obj_data      json_object_t;
        v_row         number := 0;
        v_nolang      number := 0;
        v_typeauth    tusrprof.typeauth%type;
        v_numseq      tlistval.numseq%type;
        v_desc_label  tlistval.desc_label%type;
        rec_tlisval   tlistval%rowtype;
        v_desclabel   tlistval.desc_label%type;
        cursor c1 is
            select * from tlistval
            where codapp = p_codapp
            and numseq <> 0
            and codlang = 101
            order by numseq;

        cursor c_tlanguage is
            select codlang
            from tlanguage
            where codlang2 is not null
            order by codlang;

        cursor c_title is
            select *
              from tlistval
             where codapp = p_codapp
               and numseq = 0
             order by numseq;
    begin
        obj_rows := json_object_t();
        obj_data := json_object_t();
        for r1 in c1 loop
            v_numseq :=  r1.numseq;
            v_row := v_row + 1;
            obj_result := json_object_t();
            obj_result.put('numseq',r1.numseq);
            if nvl(r1.flgused,'Y') = 'Y' then
              obj_result.put('flgused_',true);
            else
              obj_result.put('flgused_',false);
            end if;
            obj_result.put('flgused',nvl(r1.flgused,'Y'));
            obj_result.put('list_value',r1.list_value);
            v_nolang := 1;
            for r2 in c_tlanguage loop
                v_desc_label := '';
                begin
                    select desc_label into v_desc_label from tlistval
                    where codapp = p_codapp
                    and numseq = v_numseq
                    and codlang = r2.codlang;
                exception when no_data_found then
                    v_desc_label := '';
                end;
                obj_result.put('desc_label'||v_nolang,v_desc_label);
                v_nolang := v_nolang + 1;
            end loop;
            obj_rows.put(to_char(v_row-1),obj_result);
        end loop;
--
--        begin
--            select typeauth into v_typeauth
--            from tusrprof
--            where coduser = global_v_coduser;
--        exception when others then
--            v_typeauth := null;
--        end;
--        obj_result := json_object_t();
        v_row := 0;
        for r3 in c_title loop
          v_row :=  v_row + 1;
          obj_data.put('desc_label'||(v_row),r3.desc_label);
        end loop;
        begin
          select typeauth
            into v_typeauth
            from tusrprof
           where coduser = global_v_coduser;
        end;
        begin
          select desc_label into v_desclabel
            from tlistval
           where codapp = p_codapp
             and codlang = global_v_lang
             and numseq = 0;
        exception when no_data_found then
          v_desclabel := '';
        end;
        obj_data.put('coderror', '200');
        obj_data.put('typeauth',v_typeauth);
        obj_data.put('desc_label',v_desclabel);
        obj_data.put('table',obj_rows);
        obj_data.put('codapp',p_codapp);
--        obj_data.put('detail',obj_data);
        json_str_output := obj_data.to_clob;
    end gen_detail;

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
    end get_detail;

    procedure get_langcolumn(json_str_input in clob, json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_rcnt      number := 0;
        v_desclabel tcodlang.descode%type;
        cursor c1 is
          select codlang2, namabb
            from tlanguage
           where codlang2 is not null
           order by codlang;
    begin
        initial_value(json_str_input);
        obj_rows    := json_object_t();
        for r1 in c1 loop
          obj_rows.put('desc_label'||(v_rcnt+1),r1.namabb);
          v_rcnt := v_rcnt + 1;
        end loop;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('language',obj_rows);
        json_str_output := obj_data.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_langcolumn;

    procedure validate_save(json_str_input in clob) as
        v_desc_101  tlistval.desc_label%type;
        v_desc_102  tlistval.desc_label%type;
        v_desc_103  tlistval.desc_label%type;
        v_desc_104  tlistval.desc_label%type;
        v_desc_105  tlistval.desc_label%type;
        v_flg   varchar2(10 char);
        json_obj    json_object_t;
        obj_detail    json_object_t;
        obj_table    json_object_t;
        obj_data    json_object_t;
        v_101       tlistval.desc_label%type;
        v_102       tlistval.desc_label%type;
        v_103       tlistval.desc_label%type;
        v_104       tlistval.desc_label%type;
        v_105       tlistval.desc_label%type;
        v_list_value    tlistval.list_value%type;
        v_numseq    tlistval.numseq%type;
        v_isdup     varchar2(1 char);
        cursor c_lang is
            select codlang from tlanguage
            where codlang2 is not null
            and codlang not in (101,102)
            order by codlang;
    begin
        json_obj        := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        obj_detail  := hcm_util.get_json_t(json_obj,'detail');
        param_json      := hcm_util.get_json_t(json_obj,'table');
        v_desc_101  := hcm_util.get_string_t(obj_detail,'desc_labele');
        v_desc_102  := hcm_util.get_string_t(obj_detail,'desc_labelt');
        if (v_desc_101 is null) or (v_desc_102 is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        for i in 0..param_json.get_size-1 loop
            obj_data      := hcm_util.get_json_t(param_json,to_char(i));
            v_101         := hcm_util.get_string_t(obj_data,'desc_label1');
            v_102         := hcm_util.get_string_t(obj_data,'desc_label2');
            v_list_value  := upper(hcm_util.get_string_t(obj_data,'list_value'));
            v_numseq      := to_number(hcm_util.get_string_t(obj_data,'numseq'));
            v_flg         := hcm_util.get_string_t(obj_data,'flg');
            if v_flg <> 'delete' then
                if (v_101 is null) or (v_102 is null) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    exit;
                end if;
            end if;
        end loop;
    end validate_save;

    procedure save_tlistval(v_codlang varchar2,v_numseq number,v_label varchar2,v_value varchar2,v_flgused varchar2) as
        v_count number := 0;
        v_temp  varchar2(1 char);
    begin
        if v_label is null then
            return;
        end if;
        begin
            select 'X' into v_temp
            from tlistval
            where codapp = p_codapp
            and codlang = v_codlang
            and numseq = v_numseq;

            update tlistval
            set desc_label = v_label,
                list_value = v_value,
                flgused = v_flgused,
                dteupd = sysdate,
                coduser = global_v_coduser
            where codapp = p_codapp
            and codlang = v_codlang
            and numseq = v_numseq;
        exception when no_data_found then
            insert into tlistval(codapp,codlang,numseq,desc_label,
                list_value,flgused,dteupd,coduser,dtecreate,codcreate)
            values(p_codapp,v_codlang,v_numseq,v_label,v_value,v_flgused,
                sysdate,global_v_coduser,sysdate,global_v_coduser);
        end;
    end save_tlistval;

    procedure save_data(json_str_input in clob, json_str_output out clob) as
        v_desc_101  tlistval.desc_label%type;
        v_desc_102  tlistval.desc_label%type;
        v_desc_103  tlistval.desc_label%type;
        v_desc_104  tlistval.desc_label%type;
        v_desc_105  tlistval.desc_label%type;
        v_101       tlistval.desc_label%type;
        v_102       tlistval.desc_label%type;
        v_103       tlistval.desc_label%type;
        v_104       tlistval.desc_label%type;
        v_105       tlistval.desc_label%type;
        v_flgused   tlistval.flgused%type;
        v_list_value    tlistval.list_value%type;
        v_numseq      tlistval.numseq%type;
        v_flg         varchar2(10 char);
        json_obj      json_object_t;
        obj_data      json_object_t;
        obj_detail    json_object_t;
        obj_table     json_object_t;
        v_count       number;
    begin
        json_obj        := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        obj_detail  := hcm_util.get_json_t(json_obj,'detail');
        param_json      := hcm_util.get_json_t(json_obj,'table');

        v_desc_101  := hcm_util.get_string_t(obj_detail,'desc_labele');
        v_desc_102  := hcm_util.get_string_t(obj_detail,'desc_labelt');
        v_desc_103  := hcm_util.get_string_t(obj_detail,'desc_labelt3');
        v_desc_104  := hcm_util.get_string_t(obj_detail,'desc_labelt4');
        v_desc_105  := hcm_util.get_string_t(obj_detail,'desc_labelt5');
        begin
          update tlistval
             set desc_label = v_desc_101,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where codapp = p_codapp
             and codlang = '101'
             and numseq = 0;
          update tlistval
             set desc_label = v_desc_102,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where codapp = p_codapp
             and codlang = '102'
             and numseq = 0;
          update tlistval
             set desc_label = v_desc_103,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where codapp = p_codapp
             and codlang = '103'
             and numseq = 0;
          update tlistval
             set desc_label = v_desc_104,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where codapp = p_codapp
             and codlang = '104'
             and numseq = 0;
          update tlistval
             set desc_label = v_desc_105,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where codapp = p_codapp
             and codlang = '105'
             and numseq = 0;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        end;
        for i in 0..param_json.get_size-1 loop
            obj_data := hcm_util.get_json_t(param_json,to_char(i));
            v_101 := hcm_util.get_string_t(obj_data,'desc_label1');
            v_102 := hcm_util.get_string_t(obj_data,'desc_label2');
            v_103 := hcm_util.get_string_t(obj_data,'desc_label3');
            v_104 := hcm_util.get_string_t(obj_data,'desc_label4');
            v_105 := hcm_util.get_string_t(obj_data,'desc_label5');
            v_list_value  := upper(hcm_util.get_string_t(obj_data,'list_value'));
            v_flgused     := nvl(hcm_util.get_string_t(obj_data,'flgused'),'N');
            v_numseq      := to_number(hcm_util.get_string_t(obj_data,'numseq'));
            v_flg         := hcm_util.get_string_t(obj_data,'flg');
            if v_numseq is null then
              begin
                select max(numseq)+1
                  into v_numseq
                  from tlistval
                 where codapp = p_codapp
                   and codlang = '101';
              exception when no_data_found then
                v_numseq := 1;
              end;
            end if;
            if v_flg = 'add' then
--                if v_101 is not null then
                    insert into tlistval(codapp,codlang,numseq,desc_label,
                        list_value,flgused,dteupd,coduser,dtecreate,codcreate)
                    values(p_codapp,'101',v_numseq,v_101,v_list_value,v_flgused,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);
--                end if;
--                if v_102 is not null then
                    insert into tlistval(codapp,codlang,numseq,desc_label,
                        list_value,flgused,dteupd,coduser,dtecreate,codcreate)
                    values(p_codapp,'102',v_numseq,v_102,v_list_value,v_flgused,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);
--                end if;
--                if v_103 is not null then
                    insert into tlistval(codapp,codlang,numseq,desc_label,
                        list_value,flgused,dteupd,coduser,dtecreate,codcreate)
                    values(p_codapp,'103',v_numseq,v_103,v_list_value,v_flgused,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);
--                end if;
--                if v_104 is not null then
                    insert into tlistval(codapp,codlang,numseq,desc_label,
                        list_value,flgused,dteupd,coduser,dtecreate,codcreate)
                    values(p_codapp,'104',v_numseq,v_104,v_list_value,v_flgused,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);
--                end if;
--                if v_105 is not null then
                    insert into tlistval(codapp,codlang,numseq,desc_label,
                        list_value,flgused,dteupd,coduser,dtecreate,codcreate)
                    values(p_codapp,'105',v_numseq,v_105,v_list_value,v_flgused,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);
--                end if;
            elsif v_flg = 'edit' then
                save_tlistval('101',v_numseq,v_101,v_list_value,v_flgused);
                save_tlistval('102',v_numseq,v_102,v_list_value,v_flgused);
                save_tlistval('103',v_numseq,v_103,v_list_value,v_flgused);
                save_tlistval('104',v_numseq,v_104,v_list_value,v_flgused);
                save_tlistval('105',v_numseq,v_105,v_list_value,v_flgused);
            elsif v_flg = 'delete' then
                delete from tlistval
                where codapp = p_codapp
                and numseq = v_numseq;
            end if;
        end loop;
        if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            commit;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            rollback;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_data;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        validate_save(json_str_input);
        if param_msg_error is null then
            save_data(json_str_input,json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

end HRCO38E;

/

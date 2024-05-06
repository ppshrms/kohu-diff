--------------------------------------------------------
--  DDL for Package Body HRCO21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO21E" as

    -- Update 12/11/2019 11:10

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codapp          := 'HRCO21E';
        p_codjob          := upper(hcm_util.get_string_t(json_obj,'p_codjob'));
    end initial_value;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        cursor c1 is
            select * from tjobcode order by codjob;
    begin
        initial_value(json_str_input);
        obj_rows := json_object_t();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('codjob',i.codjob);
            obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

      json_str_output := obj_rows.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
      obj_data    json_object_t;
      v_codjob    tjobcode.codjob%type;
      v_count1       number;
      v_count2       number;
    begin
        initial_value(json_str_input);
        param_json      := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        for i in 0..param_json.get_size-1 loop
            obj_data  := hcm_util.get_json_t(param_json,to_char(i));
            v_codjob  := hcm_util.get_string_t(obj_data,'codjob');
            begin
                select count(*)
                  into v_count1
                  from temploy1
                 where codjob = v_codjob;

            exception when others then
                v_count1 := 0;
            end;

            begin
                select count(*)
                  into v_count2
                  from thismove
                 where codjob = v_codjob;
            exception when others then
                v_count2 :=0;
            end;

            if v_count1 + v_count2 > 0 then
                param_msg_error := get_error_msg_php('HR1450',global_v_lang);
                exit;
            else
                delete tjobcode where codjob = v_codjob;
                delete tjobdet where codjob = v_codjob;
                delete tjobresp where codjob = v_codjob;
                delete tjobeduc where codjob = v_codjob;
            end if;
        end loop;
        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        else
            rollback;
        end if;
        json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_index;

    function get_tab_tjobcode return json_object_t as
        obj_result  json_object_t;
        obj_data    json_object_t;
        obj_syncond json_object_t;
        rec_tjobcode    tjobcode%rowtype;
        v_amtcolla      tjobcode.amtcolla%type;
        v_amtguarntr    varchar2(11 char);
        v_desguar       tjobcode.desguar%type;
        v_desjob        tjobcode.desjob%type;
        v_namjob3       tjobcode.namjob3%type;
        v_namjob4       tjobcode.namjob4%type;
        v_namjob5       tjobcode.namjob5%type;
        v_namjobe       tjobcode.namjobe%type;
        v_namjobt       tjobcode.namjobt%type;
        v_namjob        tjobcode.namjobe%type;
        v_qtyguar       tjobcode.qtyguar%type;
        v_statement     tjobcode.statement%type;
        v_syncond       tjobcode.syncond%type;
        v_desc_syncond  varchar2(4000 char);
    begin
        obj_result := json_object_t();
        obj_data := json_object_t();
        begin
            select amtcolla,amtguarntr,desguar,desjob,
                   namjob3,namjob4,namjob5,namjobe,namjobt,
                   qtyguar,statement,syncond,decode(global_v_lang,'101',namjobe
                                                                 ,'102',namjobt
                                                                 ,'103',namjob3
                                                                 ,'104',namjob4
                                                                 ,'105',namjob5) as namjob
              into v_amtcolla,v_amtguarntr,v_desguar,v_desjob,
                   v_namjob3,v_namjob4,v_namjob5,v_namjobe,v_namjobt,
                   v_qtyguar,v_statement,v_syncond, v_namjob
              from tjobcode 
             where codjob = p_codjob;
            obj_result.put('flgedit','Edit');
        exception when no_data_found then
            obj_result.put('flgedit','Add');
        end;
        if v_syncond is not null then
          v_desc_syncond := get_logical_name('HRCO21E',v_syncond,global_v_lang);
        else
          v_syncond := '';
          v_desc_syncond  := '';
          v_statement := empty_clob();
        end if;
        obj_data.put('desjob',nvl(v_desjob,''));
        obj_data.put('amtcolla',nvl(v_amtcolla,''));
        obj_data.put('qtyguar',nvl(v_qtyguar,''));
        obj_data.put('amtguarntr',nvl(v_amtguarntr,''));
        obj_data.put('desguar',nvl(v_desguar,''));
        obj_syncond := json_object_t();
        obj_syncond.put('code',v_syncond); -- เงื่อนไขพนักงานที่อยู่ในกลุ่ม
        obj_syncond.put('description',v_desc_syncond); -- รายละเอียด
        obj_syncond.put('statement',nvl(v_statement,empty_clob()));
        obj_data.put('syncond',obj_syncond);
        obj_result.put('namjob',v_namjob);
        obj_result.put('namjobe',v_namjobe);
        obj_result.put('namjobt',v_namjobt);
        obj_result.put('namjob3',v_namjob3);
        obj_result.put('namjob4',v_namjob4);
        obj_result.put('namjob5',v_namjob5);
        obj_result.put('tab1',obj_data);
        return obj_result;
    end get_tab_tjobcode;

    function get_tab_tjobdet return json_object_t as
        obj_result  json_object_t;
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;

        cursor c1 is
            select * from tjobdet
            where codjob = p_codjob
            order by itemno;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('itemno',i.itemno);
            obj_data.put('namitem',i.namitem);
            obj_data.put('descrip',nvl(i.descrip,''));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        obj_result := json_object_t();
        obj_result.put('rows',obj_rows);
        return obj_result;
    end get_tab_tjobdet;

    function get_tab_tjobresp return json_object_t as
        obj_result  json_object_t;
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;

        cursor c1 is
            select * from tjobresp
            where codjob = p_codjob
            order by itemno;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('itemno',i.itemno);
            obj_data.put('namitem',i.namitem);
            obj_data.put('descrip',nvl(i.descrip,''));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        obj_result := json_object_t();
        obj_result.put('rows',obj_rows);
        return obj_result;
    end get_tab_tjobresp;

    function get_tab_tjobeduc return json_object_t as
        obj_result  json_object_t;
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;

        cursor c1 is
            select * from tjobeduc
            where codjob = p_codjob
            order by seqno;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('seqno',i.seqno);
            obj_data.put('codedlv',i.codedlv);
            obj_data.put('desc_codedlv',get_tcodec_name('TCODEDUC',i.codedlv,global_v_lang));
            obj_data.put('codmajsb',i.codmajsb);
            obj_data.put('desc_codmajsb',get_tcodec_name('TCODMAJR',i.codmajsb,global_v_lang));
            obj_data.put('numgpa',i.numgpa);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        obj_result := json_object_t();
        obj_result.put('rows',obj_rows);
        return obj_result;
    end get_tab_tjobeduc;

    procedure gen_detail(json_str_output out clob) as
        obj_result  json_object_t;
        obj_rows    json_object_t;
        v_row       number := 0;
    begin
        obj_rows    := json_object_t();
        obj_result  := json_object_t();
        obj_result  := get_tab_tjobcode;
        obj_result.put('tab2',get_tab_tjobdet);
        obj_result.put('tab3',get_tab_tjobresp);
        obj_result.put('tab4',get_tab_tjobeduc);
        obj_rows.put('0',obj_result);

        json_str_output := obj_rows.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
         initial_value(json_str_input);
         gen_detail(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure validate_save as
        tab1        json_object_t;
        tab2        json_object_t;
        tab3        json_object_t;
        tab4        json_object_t;
        obj_data    json_object_t;
        v_desjob    tjobcode.desjob%type;
        v_namitem   tjobdet.namitem%type;
        v_itemno    tjobdet.itemno%type;
        v_flgedit   varchar2(10 char);
        v_codedlv   tjobeduc.codedlv%type;
        v_codmajsb  tjobeduc.codmajsb%type;
        v_temp      varchar2(1 char);
    begin
        tab1        := hcm_util.get_json_t(param_json,'tab1');
        tab2        := hcm_util.get_json_t(param_json,'tab2');
        tab3        := hcm_util.get_json_t(param_json,'tab3');
        tab4        := hcm_util.get_json_t(param_json,'tab4');
        v_desjob    := hcm_util.get_string_t(tab1,'desjob');
        -- Tab รายละเอียดลักษณะงาน ข้อมูลที่ต้องระบุความรับผิดชอบ ถ้าไม่ระบุข้อมูลให้ Alert  HR2045
        if v_desjob is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'v_desjob');
            return;
        end if;
        for a in 0..tab2.get_size-1 loop
          obj_data  := hcm_util.get_json_t(tab2,to_char(a));
          v_namitem := hcm_util.get_string_t(obj_data,'namitem');
          v_itemno  := to_number(hcm_util.get_string_t(obj_data,'itemno'));
          v_flgedit := hcm_util.get_string_t(obj_data,'flg');
          if (v_flgedit != 'delete') and (v_namitem is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
          end if;
        end loop;
        for b in 0..tab3.get_size-1 loop
            obj_data  := hcm_util.get_json_t(tab3,to_char(b));
            v_namitem := hcm_util.get_string_t(obj_data,'namitem');
            v_itemno  := to_number(hcm_util.get_string_t(obj_data,'itemno'));
            v_flgedit := hcm_util.get_string_t(obj_data,'flg');
            if (v_flgedit != 'delete') and (v_namitem is null) then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                return;
            end if;
        end loop;
        for c in 0..tab4.get_size-1 loop
            obj_data    := hcm_util.get_json_t(tab4,to_char(c));
            v_codedlv   := upper(hcm_util.get_string_t(obj_data,'codedlv'));
            v_codmajsb  := upper(hcm_util.get_string_t(obj_data,'codmajsb'));
            v_flgedit   := hcm_util.get_string_t(obj_data,'flg');
            if v_flgedit != 'delete' then
                if (v_codedlv is null) or (v_codedlv is null) then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    return;
                end if;
                begin
                    select 'X' into v_temp from tcodeduc where codcodec = v_codedlv;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodeduc');
                    return;
                end;
                if v_codmajsb is not null then
                    begin
                        select 'X' into v_temp from tcodmajr where codcodec = v_codmajsb;
                    exception when no_data_found then
                        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodmajr');
                        return;
                    end;
                end if;
            end if;
        end loop;
    end validate_save;

    procedure save_tjobcode as
        details       json_object_t;
        tab1          json_object_t;
        obj_syncond   json_object_t;
        v_namjobe     tjobcode.namjobe%type;
        v_namjobt     tjobcode.namjobt%type;
        v_namjob3     tjobcode.namjob3%type;
        v_namjob4     tjobcode.namjob4%type;
        v_namjob5     tjobcode.namjob5%type;
        v_desjob      tjobcode.desjob%type;
        v_amtcolla    tjobcode.amtcolla%type;
        v_qtyguar     tjobcode.qtyguar%type;
--        v_qtyyrsur  tjobcode.qtyyrsur%type;
        v_syncond     tjobcode.syncond%type;
        v_statement   tjobcode.statement%type;
        v_desguar     tjobcode.desguar%type;
        v_amtguarntr  tjobcode.amtguarntr%type;
        v_flgedit   varchar2(10 char);
    begin
        details       := hcm_util.get_json_t(param_json,'details');
        p_codjob      := hcm_util.get_string_t(details,'codjob');
        v_namjobe     := hcm_util.get_string_t(details,'namjobe');
        v_namjobt     := hcm_util.get_string_t(details,'namjobt');
        v_namjob3     := hcm_util.get_string_t(details,'namjob3');
        v_namjob4     := hcm_util.get_string_t(details,'namjob4');
        v_namjob5     := hcm_util.get_string_t(details,'namjob5');
        v_flgedit     := hcm_util.get_string_t(param_json,'flgedit');

        tab1          := hcm_util.get_json_t(param_json,'tab1');
        v_desjob      := hcm_util.get_string_t(tab1,'desjob');
        v_amtcolla    := to_number(hcm_util.get_string_t(tab1,'amtcolla'));
        v_qtyguar     := to_number(hcm_util.get_string_t(tab1,'qtyguar'));
--        v_qtyyrsur  := to_number(hcm_util.get_string(tab1,'qtyyrsur'));
        obj_syncond   := hcm_util.get_json_t(tab1,'syncond');
        v_syncond     := hcm_util.get_string_t(obj_syncond,'code');
        v_statement   := hcm_util.get_string_t(obj_syncond,'statement');
        v_desguar     := hcm_util.get_string_t(tab1,'desguar');
        v_amtguarntr  := hcm_util.get_string_t(tab1,'amtguarntr');
--        if v_flgedit = 'Add' then
--        elsif v_flgedit = 'Edit' then
--        end if;
        begin
            insert into tjobcode(codjob,namjobe,namjobt,namjob3,namjob4,namjob5,amtguarntr,
                desjob,amtcolla,qtyguar,syncond,statement,desguar,dteupd,coduser,dtecreate,codcreate)
            values(p_codjob,v_namjobe,v_namjobt,v_namjob3,v_namjob4,v_namjob5,v_amtguarntr,
                v_desjob,v_amtcolla,v_qtyguar,v_syncond,v_statement,v_desguar,
                sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            update tjobcode set
                namjobe = v_namjobe,
                namjobt = v_namjobt,
                namjob3 = v_namjob3,
                namjob4 = v_namjob4,
                namjob5 = v_namjob5,
                desjob = v_desjob,
                amtcolla = v_amtcolla,
                qtyguar = v_qtyguar,
                amtguarntr = v_amtguarntr,
                syncond = v_syncond,
                statement = v_statement,
                desguar = v_desguar,
                dteupd = sysdate,
                coduser = global_v_coduser
            where codjob = p_codjob;
        end;
    end save_tjobcode;

    procedure save_tjobdet as
        tab2        json_object_t;
        obj_data    json_object_t;
        v_itemno    tjobdet.itemno%type;
        v_namitem   tjobdet.namitem%type;
        v_descrip   tjobdet.descrip%type;
        v_flgedit   varchar2(10 char);
    begin
        tab2        := hcm_util.get_json_t(param_json,'tab2');
        for i in 0..tab2.get_size-1 loop
            obj_data  := hcm_util.get_json_t(tab2,to_char(i));
            v_itemno  := to_number(hcm_util.get_string_t(obj_data,'itemno'));
            v_namitem := hcm_util.get_string_t(obj_data,'namitem');
            v_descrip := hcm_util.get_string_t(obj_data,'descrip');
            v_flgedit := hcm_util.get_string_t(obj_data,'flg');
            if v_flgedit = 'add' then
                begin
                    insert into tjobdet(codjob,itemno,namitem,descrip,dteupd,coduser,dtecreate,codcreate)
                    values(p_codjob,v_itemno,v_namitem,v_descrip,sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tjobdet');
                    return;
                end;
            elsif v_flgedit = 'edit' then
                update tjobdet set
                    namitem = v_namitem,
                    descrip = v_descrip,
                    dteupd  = sysdate,
                    coduser = global_v_coduser
                where codjob = p_codjob
                and itemno = v_itemno;
            elsif v_flgedit = 'delete' then
                delete from tjobdet where codjob = p_codjob and itemno = v_itemno;
            end if;
        end loop;
    end save_tjobdet;

    procedure save_tjobresp as
        tab3        json_object_t;
        obj_data    json_object_t;
        v_itemno    tjobdet.itemno%type;
        v_namitem   tjobdet.namitem%type;
        v_descrip   tjobdet.descrip%type;
        v_flgedit   varchar2(10 char);
    begin
        tab3        := hcm_util.get_json_t(param_json,'tab3');
        for i in 0..tab3.get_size-1 loop
            obj_data  := hcm_util.get_json_t(tab3,to_char(i));
            v_itemno  := to_number(hcm_util.get_string_t(obj_data,'itemno'));
            v_namitem := hcm_util.get_string_t(obj_data,'namitem');
            v_descrip := hcm_util.get_string_t(obj_data,'descrip');
            v_flgedit := hcm_util.get_string_t(obj_data,'flg');
            if v_flgedit = 'add' then
                begin
                    insert into tjobresp(codjob,itemno,namitem,descrip,dteupd,coduser,dtecreate,codcreate)
                    values(p_codjob,v_itemno,v_namitem,v_descrip,sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tjobresp');
                    return;
                end;
            elsif v_flgedit = 'edit' then
                update tjobresp set
                    namitem = v_namitem,
                    descrip = v_descrip,
                    dteupd  = sysdate,
                    coduser = global_v_coduser
                where codjob = p_codjob
                and itemno = v_itemno;
            elsif v_flgedit = 'delete' then
                delete from tjobresp where codjob = p_codjob and itemno = v_itemno;
            end if;
        end loop;
    end save_tjobresp;

    procedure save_tjobeduc as
        tab4        json_object_t;
        obj_data    json_object_t;
        v_seqno     tjobeduc.seqno%type;
        v_codedlv   tjobeduc.codedlv%type;
        v_codmajsb  tjobeduc.codmajsb%type;
        v_numgpa    tjobeduc.numgpa%type;
        v_flgedit   varchar2(10 char);
        v_count     number;
    begin
        tab4        := hcm_util.get_json_t(param_json,'tab4');
        for i in 0..tab4.get_size-1 loop
            obj_data    := hcm_util.get_json_t(tab4,to_char(i));
            v_seqno     := to_number(hcm_util.get_string_t(obj_data,'seqno'));
            v_codedlv   := upper(hcm_util.get_string_t(obj_data,'codedlv'));
            v_codmajsb  := upper(hcm_util.get_string_t(obj_data,'codmajsb'));
            v_numgpa    := to_number(hcm_util.get_string_t(obj_data,'numgpa'));
            v_flgedit   := hcm_util.get_string_t(obj_data,'flg');
            if v_seqno is null then
              select nvl(max(seqno),0) + 1 into v_seqno
                from tjobeduc
               where codjob = p_codjob;
            end if;
            if v_flgedit = 'add' then
                begin
                    insert into tjobeduc(codjob,seqno,codedlv,codmajsb,numgpa,dteupd,coduser,dtecreate,codcreate)
                    values(p_codjob,v_seqno,v_codedlv,v_codmajsb,v_numgpa,sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tjobeduc');
                    return;
                end;
            elsif v_flgedit = 'edit' then
                update tjobeduc set
                    codedlv = v_codedlv,
                    codmajsb = v_codmajsb,
                    numgpa = v_numgpa,
                    dteupd  = sysdate,
                    coduser = global_v_coduser
                where codjob = p_codjob
                and seqno = v_seqno;
            elsif v_flgedit = 'delete' then
                delete from tjobeduc where codjob = p_codjob and seqno = v_seqno;
            end if;
            -- ต้องมีข้อมูลอย่างน้อย 1 รายการ
            begin
                select count(*)
                into v_count
                from tjobeduc
                where codjob = p_codjob
                order by seqno;
            exception when no_data_found then
                v_count := 0;
            end;
            if v_count = 0 then
                param_msg_error := get_error_msg_php('HR7598',global_v_lang,'tjobeduc');
                return;
            end if;
        end loop;
    end save_tjobeduc;

    procedure save_data(json_str_output out clob) as
    begin
        save_tjobcode;
        save_tjobdet;
        save_tjobresp;
        save_tjobeduc;
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
        json_obj    json_object_t;
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := json_obj;
--        param_json      := hcm_util.get_json_t(json_obj,'param_json');
        validate_save;
        if param_msg_error is null then
            save_data(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

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

    procedure gen_report_tjobcode(json_str_output out clob) is
        namjob      tjobcode.namjobe%type;
        json_obj    json_object_t;
        v_codjob    tjobcode.codjob%type;
        max_numseq  number;
        p_numseq    number;

        cursor r_tjobcode is
            select *
              from tjobcode
             where upper(codjob) = v_codjob;
    begin
        for i in 0..param_json.get_size-1 loop
            json_obj    := hcm_util.get_json_t(param_json,to_char(i));
            v_codjob    := upper(hcm_util.get_string_t(json_obj,'codjob'));
            for rtab1 in r_tjobcode loop
                begin
                    select max(numseq) 
                      into max_numseq
                      from ttemprpt 
                     where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;

                p_numseq := max_numseq+1;

                if(global_v_lang='101') then
                    namjob := rtab1.namjobe;
                elsif(global_v_lang='102') then
                    namjob := rtab1.namjobt;
                elsif(global_v_lang='103') then
                    namjob := rtab1.namjob3;
                elsif(global_v_lang='104') then
                    namjob := rtab1.namjob4;
                elsif(global_v_lang='105') then
                    namjob := rtab1.namjob5;
                end if;
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,
                item7,item8,item9,item10)
                values (global_v_codempid,p_codapp,p_numseq,'DETAIL',v_codjob,v_codjob,namjob,rtab1.desjob,get_logical_name('HRCO21E',rtab1.syncond,global_v_lang),
                trim(TO_CHAR(rtab1.amtcolla, '999,999,990.00')),rtab1.qtyguar,trim(TO_CHAR(rtab1.amtguarntr, '999,999,990.00')),rtab1.desguar);
             end loop;
        end loop;

    end gen_report_tjobcode;

    procedure gen_report_tjobdet is
        json_obj        json_object_t;
        v_codjob        tjobdet.codjob%type;
        max_numseq      number;
        p_numseq        number;

        cursor r_tjobdet is
            select *
              from tjobdet
             where upper(codjob) = v_codjob;
    begin
        for i in 0..param_json.get_size-1 loop
            json_obj    := hcm_util.get_json_t(param_json,to_char(i));
            v_codjob    := upper(hcm_util.get_string_t(json_obj,'codjob'));
            for rtab2 in r_tjobdet loop
                begin
                    select max(numseq) 
                      into max_numseq
                      from ttemprpt 
                     where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;

                p_numseq := max_numseq+1;
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5)
                values (global_v_codempid,p_codapp,p_numseq,'TABLE1',v_codjob,rtab2.itemno,rtab2.namitem,rtab2.descrip);
             end loop;
        end loop;
    end gen_report_tjobdet;

    procedure gen_report_tjobresp is
        json_obj    json_object_t;
        v_codjob    tjobresp.codjob%type;
        max_numseq  number;
        p_numseq    number;

        cursor r_tjobresp is
            select *
              from tjobresp
             where upper(codjob) = v_codjob;
    begin
        for i in 0..param_json.get_size-1 loop
            json_obj    := hcm_util.get_json_t(param_json,to_char(i));
            v_codjob    := upper(hcm_util.get_string_t(json_obj,'codjob'));
            for rtab3 in r_tjobresp loop
                begin
                    select max(numseq) 
                      into max_numseq
                      from ttemprpt 
                     where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;

                p_numseq := max_numseq+1;

                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5)
                values (global_v_codempid,p_codapp,p_numseq,'TABLE2',v_codjob,rtab3.itemno,rtab3.namitem,rtab3.descrip);
             end loop;
        end loop;

    end gen_report_tjobresp;

    procedure gen_report_tjobeduc is
        des_majr      tcodmajr.descode%type;
        des_educ      tcodeduc.descode%type;
        json_obj      json_object_t;
        v_codjob      tjobeduc.codjob%type;
        max_numseq    number;
        p_numseq      number;
        rec_tcodeduc  tcodeduc%rowtype;
        rec_tcodmajr  tcodmajr%rowtype;

        cursor r_tjobeduc is
            select *
              from tjobeduc
             where upper(codjob) = v_codjob;
    begin
        for i in 0..param_json.get_size-1 loop
            json_obj    := hcm_util.get_json_t(param_json,to_char(i));
            v_codjob    := upper(hcm_util.get_string_t(json_obj,'codjob'));
            for rtab4 in r_tjobeduc loop
                begin
                    select max(numseq) 
                      into max_numseq
                      from ttemprpt 
                     where codempid = global_v_codempid
                       and codapp = p_codapp;
                    if max_numseq is null then
                        max_numseq :=0 ;
                    end if;
                end;

                p_numseq := max_numseq+1;

                des_educ    := get_tcodec_name ('TCODEDUC',rtab4.codedlv,global_v_lang);
                des_majr    := get_tcodec_name ('TCODMAJR',rtab4.codmajsb,global_v_lang);
                insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6)
                values (global_v_codempid,p_codapp,p_numseq,'TABLE3',v_codjob,rtab4.seqno,rtab4.codedlv ||' - '||des_educ,rtab4.codmajsb || ' - ' ||des_majr,rtab4.numgpa);
             end loop;
        end loop;


    end gen_report_tjobeduc;

     procedure get_report(json_str_input in clob, json_str_output out clob) as
        json_obj            json_object_t;
        v_numgrup           tintvewd.numgrup%type;
        v_desgrupe          tintvews.desgrupe%type;
        v_desgrupt          tintvews.desgrupt%type;
        v_desgrup3          tintvews.desgrup3%type;
        v_desgrup4          tintvews.desgrup4%type;
        v_desgrup5          tintvews.desgrup5%type;
        v_flgedit           varchar2(10 char);
        v_flgedit_grup      varchar2(10 char);
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        v_flgedit   := hcm_util.get_string_t(json_obj,'flgedit');
        param_json  := hcm_util.get_json_t(json_obj,'p_index_rows');
        clear_ttemprpt;
        if param_msg_error is null then
            gen_report_tjobcode(json_str_output);
            gen_report_tjobdet();
            gen_report_tjobresp();
            gen_report_tjobeduc();
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

end HRCO21E;

/

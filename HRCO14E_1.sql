--------------------------------------------------------
--  DDL for Package Body HRCO14E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO14E" as

    -- Update 09/09/2019 16:30

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codform         := upper(hcm_util.get_string_t(json_obj,'p_codform'));
    end initial_value;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        cursor c1 is
            select codform,typfrm,flgstd,decode(global_v_lang,'101',descode,'102',descodt
                   ,'103',descod3,'104',descod4,'105',descod5) desc_codform
              from tfrmmail
          order by codform;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('codform',i.codform);
            obj_data.put('desc_codform',i.desc_codform);
            obj_data.put('typfrm',i.typfrm);
            obj_data.put('desc_typfrm',get_tlistval_name('TYPFRM',i.typfrm,global_v_lang));
            obj_data.put('flgstd',i.flgstd);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_rows.to_clob;
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        gen_index(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure check_index as
    begin
        if p_codform is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end check_index;

    function gen_list_tfrmmailp return json_object_t as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        cursor c1 is
            select a.*,decode(global_v_lang,'101',descripe,'102',descript
                   ,'103',descrip3,'104',descrip4,'105',descrip5) desc_param
              from tfrmmailp a
             where codform = p_codform;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_row    := v_row+1;
            obj_data := json_object_t();
            obj_data.put('numseq',i.numseq);
            obj_data.put('fparam',i.fparam);
            obj_data.put('desc_param',i.desc_param);
            obj_data.put('parameter',i.codtable||'.'||i.ffield);
            -- add
            obj_data.put('codtable',i.codtable);
            obj_data.put('ffield',i.ffield);
            obj_data.put('descripe',i.descripe);
            obj_data.put('descript',i.descript);
            obj_data.put('descrip3',i.descrip3);
            obj_data.put('descrip4',i.descrip4);
            obj_data.put('descrip5',i.descrip5);
            obj_data.put('flgstd',i.flgstd);
            obj_data.put('flgdesc',i.flgdesc);

            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        return obj_rows;
    end gen_list_tfrmmailp;

    procedure gen_detail(json_str_output out clob) as
        obj_result      json_object_t;
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        rec_tfrmmail    tfrmmail%rowtype;
        v_typparam      tfrmmail.typparam%type;
        v_message       tfrmmail.messagee%type;
        v_descod        tfrmmail.descode%type;
    begin
        obj_result  := json_object_t();
        begin
            select *
              into rec_tfrmmail
              from tfrmmail
             where codform = p_codform;
            obj_result.put('flgedit','Edit');
        exception when no_data_found then
            rec_tfrmmail := null;
            obj_result.put('flgedit','Add');
        end;
        begin
            select decode(global_v_lang, '101',messagee,
                                         '102',messaget,
                                         '103',message3,
                                         '104',message4,
                                         '105',message5) message,
                   decode(global_v_lang, '101',descode,
                                         '102',descodt,
                                         '103',descod3,
                                         '104',descod4,
                                         '105',descod5) descod
              into v_message, v_descod
              from tfrmmail
             where codform = p_codform;
        exception when no_data_found then
            v_message := '';
        end;
        v_typparam := rec_tfrmmail.typparam;
        obj_result.put('codform',rec_tfrmmail.codform);
        obj_result.put('typfrm',rec_tfrmmail.typfrm);
        obj_result.put('typparam',rec_tfrmmail.typparam);
--        obj_result.put('flgstd','N');
        obj_result.put('flgstd',nvl(rec_tfrmmail.flgstd,'N'));
        obj_result.put('descod',v_descod);
        obj_result.put('descode',rec_tfrmmail.descode);
        obj_result.put('descodt',rec_tfrmmail.descodt);
        obj_result.put('descod3',rec_tfrmmail.descod3);
        obj_result.put('descod4',rec_tfrmmail.descod4);
        obj_result.put('descod5',rec_tfrmmail.descod5);
        obj_result.put('message',v_message);
        obj_result.put('messagee',rec_tfrmmail.messagee);
        obj_result.put('messaget',rec_tfrmmail.messaget);
        obj_result.put('message3',rec_tfrmmail.message3);
        obj_result.put('message4',rec_tfrmmail.message4);
        obj_result.put('message5',rec_tfrmmail.message5);
        obj_result.put('flglang',global_v_lang);

        obj_rows := json_object_t();
        obj_rows := gen_list_tfrmmailp;
        obj_result.put('parameters',obj_rows);
        obj_data := json_object_t();
        obj_data.put('0',obj_result);

        json_str_output := obj_data.to_clob;
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    function gen_data_tfrmmailp(json_obj json_object_t) return json_object_t as
        obj_data        json_object_t;
        v_numseq        tfrmmailp.numseq%type;
        rec_tfrmmailp   tfrmmailp%rowtype;
    begin
        v_numseq        := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
        begin
            select *
              into rec_tfrmmailp
              from tfrmmailp
             where codform = p_codform
               and numseq = v_numseq;
        exception when no_data_found then
            rec_tfrmmailp := null;
        end;

        obj_data := json_object_t();
        obj_data.put('numseq',rec_tfrmmailp.numseq);
        obj_data.put('codtable',rec_tfrmmailp.codtable);
        obj_data.put('fparam',rec_tfrmmailp.fparam);
        obj_data.put('ffield',rec_tfrmmailp.ffield);
        obj_data.put('descripe',rec_tfrmmailp.descripe);
        obj_data.put('descript',rec_tfrmmailp.descript);
        obj_data.put('descrip3',rec_tfrmmailp.descrip3);
        obj_data.put('descrip4',rec_tfrmmailp.descrip4);
        obj_data.put('descrip5',rec_tfrmmailp.descrip5);
        obj_data.put('flgstd',rec_tfrmmailp.flgstd);
        obj_data.put('flgdesc',rec_tfrmmailp.flgdesc);

        return obj_data;
    end gen_data_tfrmmailp;

    procedure get_parameter_detail(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        obj_result  json_object_t;
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            json_obj := json_object_t(json_str_input);
            obj_result := json_object_t();
            obj_result.put('0',gen_data_tfrmmailp(json_obj));
            json_str_output := obj_result.to_clob;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_parameter_detail;

    procedure validate_save_parameter_detail(json_str_input in clob) as
        json_obj    json_object_t;
        v_numseq        tfrmmailp.numseq%type;
        v_codtable      tfrmmailp.codtable%type;
        v_fparam        tfrmmailp.fparam%type;
        v_ffield        tfrmmailp.ffield%type;
        v_descripe      tfrmmailp.descripe%type;
        v_descript      tfrmmailp.descript%type;
        v_descrip3      tfrmmailp.descrip3%type;
        v_descrip4      tfrmmailp.descrip4%type;
        v_descrip5      tfrmmailp.descrip5%type;
        v_flgdesc       tfrmmailp.flgdesc%type;
        v_flgedit       varchar2(10 char);
        v_desnull       varchar2(1 char) := 'N';
        v_temp          varchar2(1 char);
        v_count         number;
    begin
        json_obj    := json_object_t(json_str_input);
        v_numseq        := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
        v_codtable      := upper(hcm_util.get_string_t(json_obj,'codtable'));
        v_fparam        := upper(hcm_util.get_string_t(json_obj,'fparam'));
        v_ffield        := upper(hcm_util.get_string_t(json_obj,'ffield'));
        v_descripe      := hcm_util.get_string_t(json_obj,'descripe');
        v_descript      := hcm_util.get_string_t(json_obj,'descript');
        v_descrip3      := hcm_util.get_string_t(json_obj,'descrip3');
        v_descrip4      := hcm_util.get_string_t(json_obj,'descrip4');
        v_descrip5      := hcm_util.get_string_t(json_obj,'descrip5');
        v_flgdesc       := hcm_util.get_string_t(json_obj,'flgdesc');
        v_flgedit       := hcm_util.get_string_t(json_obj,'flgedit');

        if (v_codtable is null)
            or (v_fparam is null) or (v_ffield is null)
        then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if v_flgedit != 'Add' and v_numseq is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if global_v_lang = '101' and v_descripe is null then
            v_desnull := 'Y';
        elsif global_v_lang = '102' and v_descript is null then
            v_desnull := 'Y';
        elsif global_v_lang = '103' and v_descrip3 is null then
            v_desnull := 'Y';
        elsif global_v_lang = '104' and v_descrip4 is null then
            v_desnull := 'Y';
        elsif global_v_lang = '105' and v_descrip5 is null then
            v_desnull := 'Y';
        end if;
        if v_desnull = 'Y' then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if v_codtable is not null then
            begin
                select 'X'
                  into v_temp
                  from tfrmtab
                 where codtable = v_codtable
                   and typfrm = (select typfrm
                                   from tfrmmail
                                  where codform = p_codform);
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tfrmtab');
                return;
            end;
        end if;
        if v_ffield is not null then
            begin
                select 'X'
                  into v_temp
                  from user_tab_columns
                 where table_name = v_codtable
                   and column_name = v_ffield;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'user_tab_columns');
                return;
            end;
        end if;
        if v_flgedit = 'Add' or v_flgedit = 'Edit' then
            begin
                select count(*)
                  into v_count
                  from tfrmmailp
                 where codform = p_codform
                   and fparam = v_fparam
                   and numseq <> nvl(v_numseq,0);
            exception when no_data_found then
                v_count := 0;
            end;
            if (v_flgedit in ('Add','Edit') and v_count > 0) then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tfrmmailp');
                return;
            end if;
        end if;
    end validate_save_parameter_detail;

    procedure save_data_tfrmmailp(json_obj json_object_t) as
        v_numseq        tfrmmailp.numseq%type;
        v_codtable      tfrmmailp.codtable%type;
        v_fparam        tfrmmailp.fparam%type;
        v_ffield        tfrmmailp.ffield%type;
        v_descripe      tfrmmailp.descripe%type;
        v_descript      tfrmmailp.descript%type;
        v_descrip3      tfrmmailp.descrip3%type;
        v_descrip4      tfrmmailp.descrip4%type;
        v_descrip5      tfrmmailp.descrip5%type;
        v_flgdesc       tfrmmailp.flgdesc%type;
        v_flgedit       varchar2(10 char);
    begin
        v_numseq        := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
        v_codtable      := upper(hcm_util.get_string_t(json_obj,'codtable'));
        v_fparam        := upper(hcm_util.get_string_t(json_obj,'fparam'));
        v_ffield        := upper(hcm_util.get_string_t(json_obj,'ffield'));
        v_descripe      := hcm_util.get_string_t(json_obj,'descripe');
        v_descript      := hcm_util.get_string_t(json_obj,'descript');
        v_descrip3      := hcm_util.get_string_t(json_obj,'descrip3');
        v_descrip4      := hcm_util.get_string_t(json_obj,'descrip4');
        v_descrip5      := hcm_util.get_string_t(json_obj,'descrip5');
        v_flgdesc       := hcm_util.get_string_t(json_obj,'flgdesc');
        v_flgedit       := hcm_util.get_string_t(json_obj,'flgedit');
        if v_flgedit = 'Add' then
            begin
                select nvl(max(numseq),0)+1
                  into v_numseq
                  from tfrmmailp
                 where codform = p_codform;
            exception when no_data_found then
                v_numseq := 1;
            end;
            insert into tfrmmailp(codform,numseq,codtable,fparam,ffield
                        ,descripe,descript,descrip3,descrip4,descrip5,flgstd,flgdesc
                        ,dtecreate,codcreate,dteupd,coduser)
                 values (p_codform,v_numseq,v_codtable,v_fparam,v_ffield
                        ,v_descripe,v_descript,v_descrip3,v_descrip4,v_descrip5,'N'
                        ,v_flgdesc,sysdate,global_v_coduser,sysdate,global_v_coduser);
        elsif v_flgedit = 'Edit' then
            update tfrmmailp
               set codtable = v_codtable,
                   fparam   = v_fparam,
                   ffield   = v_ffield,
                   descripe = v_descripe,
                   descript = v_descript,
                   descrip3 = v_descrip3,
                   descrip4 = v_descrip4,
                   descrip5 = v_descrip5,
                   flgdesc  = v_flgdesc,
                   dteupd   = sysdate,
                   coduser  = global_v_coduser
             where codform  = p_codform
               and numseq   = v_numseq;
        elsif v_flgedit = 'Delete' then
            delete from tfrmmailp
             where codform  = p_codform
               and numseq   = v_numseq;
        end if;
    end save_data_tfrmmailp;

    procedure save_parameter_detail(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
    begin
        initial_value(json_str_input);
        check_index;
        validate_save_parameter_detail(json_str_input);
        if param_msg_error is null then
            json_obj    := json_object_t(json_str_input);
            save_data_tfrmmailp(json_obj);
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
    end save_parameter_detail;

    procedure get_list_params(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        obj_rows    json_object_t;
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        obj_rows    := json_object_t();
        obj_rows    := gen_list_tfrmmailp;
        json_str_output := obj_rows.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_list_params;

    procedure validate_list_columns(json_obj json_object_t) as
        v_codtable  tcoldesc.codtable%type;
        v_temp      varchar2(1 char);
    begin
        v_codtable  := upper(hcm_util.get_string_t(json_obj,'p_codtable'));
        if v_codtable is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        begin
            select 'X'
              into v_temp
              from user_tab_comments
             where table_name = v_codtable;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'user_tab_comments');
            return;
        end;
    end validate_list_columns;

    procedure gen_list_columns(json_obj json_object_t,json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_codtable      tcoldesc.codtable%type;
        cursor c_tcoldesc is
            select a.*,decode(global_v_lang,'101',descole,'102',descolt
                   ,'103',descol3,'104',descol4,'105',descol5) descol
              from tcoldesc a
             where codtable = v_codtable
             order by column_id;
    begin
        v_codtable  := upper(hcm_util.get_string_t(json_obj,'p_codtable'));
        obj_rows    := json_object_t();
        for i in c_tcoldesc loop
            v_row     := v_row+1;
            obj_data  := json_object_t();
            obj_data.put('codcolmn',i.codcolmn);
            obj_data.put('desc_codcolmn',i.descol);
            obj_data.put('flgdesc','N');
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_rows.to_clob;
    end gen_list_columns;

    procedure get_list_columns(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
    begin
        initial_value(json_str_input);
        json_obj := json_object_t(json_str_input);
        validate_list_columns(json_obj);
        if param_msg_error is null then
            gen_list_columns(json_obj,json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_list_columns;

    procedure validate_list_tables(json_obj json_object_t) as
        v_typfrm    tfrmtab.typfrm%type;
    begin
        v_typfrm    := upper(hcm_util.get_string_t(json_obj,'p_typfrm'));
        if v_typfrm is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end validate_list_tables;

    procedure gen_list_tables(json_obj json_object_t,json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        v_typfrm    tfrmtab.typfrm%type;
        cursor c_tfrmtab is
            select typfrm,numseq,codtable
              from tfrmtab
             where typfrm = v_typfrm
             order by codtable;
    begin
        v_typfrm    := upper(hcm_util.get_string_t(json_obj,'p_typfrm'));
        obj_rows    := json_object_t();
        for i in c_tfrmtab loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('numseq',i.numseq);
            obj_data.put('codtable',i.codtable);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_rows.to_clob;
    end gen_list_tables;

    procedure get_list_tables(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
    begin
        initial_value(json_str_input);
        json_obj := json_object_t(json_str_input);
        validate_list_tables(json_obj);
        if param_msg_error is null then
            gen_list_tables(json_obj,json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_list_tables;

    procedure validate_save_detail(json_obj json_object_t) as
        v_desnull       varchar2(1 char);
        v_typfrm        tfrmmail.typfrm%type;
        v_typparam      tfrmmail.typparam%type;
        v_descode       tfrmmail.descode%type;
        v_descodt       tfrmmail.descodt%type;
        v_descod3       tfrmmail.descod3%type;
        v_descod4       tfrmmail.descod4%type;
        v_descod5       tfrmmail.descod5%type;
        v_message       tfrmmail.messagee%type;
        v_messagee      tfrmmail.messagee%type;
        v_messaget      tfrmmail.messaget%type;
        v_message3      tfrmmail.message3%type;
        v_message4      tfrmmail.message4%type;
        v_message5      tfrmmail.message5%type;
        v_message_lang  varchar2(10 char);
        delete_params   json_object_t;
        v_numseq        tfrmmailp.numseq%type;
        v_flgstd        tfrmmailp.flgstd%type;
        v_flgcopy       varchar2(1 char);
        v_codform_copy  tfrmmailp.codform%type;
        obj_param       json_object_t;
    begin
        v_typfrm        := upper(hcm_util.get_string_t(json_obj,'p_typfrm'));
        v_typparam      := hcm_util.get_string_t(json_obj,'p_typparam');
        v_descode       := hcm_util.get_string_t(json_obj,'descode');
        v_descodt       := hcm_util.get_string_t(json_obj,'descodt');
        v_descod3       := hcm_util.get_string_t(json_obj,'descod3');
        v_descod4       := hcm_util.get_string_t(json_obj,'descod4');
        v_descod5       := hcm_util.get_string_t(json_obj,'descod5');
        v_message       := hcm_util.get_string_t(json_obj,'message');
        v_messagee      := hcm_util.get_string_t(json_obj,'messagee');
        v_messaget      := hcm_util.get_string_t(json_obj,'messaget');
        v_message3      := hcm_util.get_string_t(json_obj,'message3');
        v_message4      := hcm_util.get_string_t(json_obj,'message4');
        v_message5      := hcm_util.get_string_t(json_obj,'message5');
        v_message_lang  := nvl(hcm_util.get_string_t(json_obj,'message_lang'),global_v_lang);
        v_flgcopy       := hcm_util.get_string_t(json_obj,'flgcopy');
        v_codform_copy  := hcm_util.get_string_t(json_obj,'codform_copy');
        delete_params   := hcm_util.get_json_t(json_obj,'delete_params');
        if p_codform is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if v_flgcopy = 'Y' and v_codform_copy is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if global_v_lang = '101' and v_descode is null then
            v_desnull := 'Y';
        elsif global_v_lang = '102' and v_descodt is null then
            v_desnull := 'Y';
        elsif global_v_lang = '103' and v_descod3 is null then
            v_desnull := 'Y';
        elsif global_v_lang = '104' and v_descod4 is null then
            v_desnull := 'Y';
        elsif global_v_lang = '105' and v_descod5 is null then
            v_desnull := 'Y';
        end if;
        if v_desnull = 'Y' then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if (v_typfrm is null) or (v_message is null) then
            param_msg_error:= get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        for i in 0..delete_params.get_size-1 loop
            obj_param := hcm_util.get_json_t(delete_params,to_char(i));
            v_numseq := to_number(hcm_util.get_string_t(obj_param,'numseq'));
            if v_numseq is null then
                param_msg_error:= get_error_msg_php('HR2045',global_v_lang);
                return;
            end if;
        end loop;
    end validate_save_detail;

    procedure copy_params(v_codform_copy varchar2) as
        obj_data    json_object_t;
        cursor c1 is
            select *
              from tfrmmailp
             where codform = v_codform_copy;
    begin
        delete from tfrmmailp where codform = p_codform;
        for i in c1 loop
            obj_data := json_object_t();
            obj_data.put('flgedit','Add');
            obj_data.put('numseq',i.numseq);
            obj_data.put('codtable',i.codtable);
            obj_data.put('fparam',i.fparam);
            obj_data.put('ffield',i.ffield);
            obj_data.put('descripe',i.descripe);
            obj_data.put('descript',i.descript);
            obj_data.put('descrip3',i.descrip3);
            obj_data.put('descrip4',i.descrip4);
            obj_data.put('descrip5',i.descrip5);
            obj_data.put('flgstd','N');
            obj_data.put('flgdesc',i.flgdesc);
            save_data_tfrmmailp(obj_data);
        end loop;
    end ;

    procedure save_data_tfrmmail(json_obj json_object_t) as
        v_typfrm        tfrmmail.typfrm%type;
        v_typparam      tfrmmail.typparam%type;
        v_descode       tfrmmail.descode%type;
        v_descodt       tfrmmail.descodt%type;
        v_descod3       tfrmmail.descod3%type;
        v_descod4       tfrmmail.descod4%type;
        v_descod5       tfrmmail.descod5%type;
        v_message       tfrmmail.messagee%type;
        v_messagee      tfrmmail.messagee%type;
        v_messaget      tfrmmail.messaget%type;
        v_message3      tfrmmail.message3%type;
        v_message4      tfrmmail.message4%type;
        v_message5      tfrmmail.message5%type;
        v_message_lang  varchar2(10 char);
        v_flgedit       varchar2(10 char);
        v_flgcopy       varchar2(1 char) := 'N';
        v_codform_copy  tfrmmail.codform%type;
        params          json_object_t;
        obj_param       json_object_t;
    begin
        v_typfrm          := upper(hcm_util.get_string_t(json_obj,'p_typfrm'));
        v_typparam        := hcm_util.get_string_t(json_obj,'p_typparam');
        v_descode         := hcm_util.get_string_t(json_obj,'descode');
        v_descodt         := hcm_util.get_string_t(json_obj,'descodt');
        v_descod3         := hcm_util.get_string_t(json_obj,'descod3');
        v_descod4         := hcm_util.get_string_t(json_obj,'descod4');
        v_descod5         := hcm_util.get_string_t(json_obj,'descod5');
        v_message         := hcm_util.get_string_t(json_obj,'message');
        v_messagee        := hcm_util.get_string_t(json_obj,'messagee');
        v_messaget        := hcm_util.get_string_t(json_obj,'messaget');
        v_message3        := hcm_util.get_string_t(json_obj,'message3');
        v_message4        := hcm_util.get_string_t(json_obj,'message4');
        v_message5        := hcm_util.get_string_t(json_obj,'message5');
        v_message_lang    := nvl(hcm_util.get_string_t(json_obj,'message_lang'),global_v_lang);
        v_flgedit         := hcm_util.get_string_t(json_obj,'flgedit');
        v_flgcopy         := hcm_util.get_string_t(json_obj,'flgcopy');
        v_codform_copy    := hcm_util.get_string_t(json_obj,'codform_copy');
        params            := hcm_util.get_json_t(json_obj,'params');
        -- detail
        if v_flgedit = 'Add' then
            insert into tfrmmail (codform,typfrm,typparam,flgstd,descode,descodt,descod3,descod4,descod5,
                                  messagee,messaget,message3,message4,message5,dtecreate,codcreate,dteupd,coduser)
                 values (p_codform,v_typfrm,v_typparam,'N',v_descode,v_descodt,v_descod3,v_descod4,v_descod5,
                         v_messagee,v_messaget,v_message3,v_message4,v_message5,sysdate,global_v_coduser,sysdate,global_v_coduser);
        elsif v_flgedit = 'Edit' then
            update tfrmmail
               set typfrm = v_typfrm,
                   typparam = v_typparam,
                   descode = v_descode,
                   descodt = v_descodt,
                   descod3 = v_descod3,
                   descod4 = v_descod4,
                   descod5 = v_descod5,
                   messagee = v_messagee,
                   messaget = v_messaget,
                   message3 = v_message3,
                   message4 = v_message4,
                   message5 = v_message5,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codform = p_codform;
        end if;

        -- save params
        if v_flgcopy = 'Y' then
            delete from tfrmmailp where codform = p_codform;
        end if;
        for i in 0..params.get_size-1 loop
            obj_param := hcm_util.get_json_t(params,to_char(i));
            obj_param.put('p_typparam',v_typparam);
            obj_param.put('p_numseq',hcm_util.get_string_t(obj_param,'numseq'));
            if v_flgcopy = 'Y' then
                obj_param.put('flgedit','Add');
            end if;
            save_data_tfrmmailp(obj_param);
        end loop;
    end save_data_tfrmmail;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
    begin
        initial_value(json_str_input);
        json_obj := json_object_t(json_str_input);
        validate_save_detail(json_obj);
        if param_msg_error is null then
            save_data_tfrmmail(json_obj);
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
    end save_detail;

    procedure validate_save_index as
        v_codform   tfrmmail.codform%type;
        v_flgstd    tfrmmail.flgstd%type;
    begin
        for i in 0..param_json.get_size-1 loop
            v_codform := upper(hcm_util.get_string_t(param_json,to_char(i)));
            begin
                select flgstd
                  into v_flgstd
                  from tfrmmail
                 where codform = v_codform;
            exception when no_data_found then
                v_flgstd := 'N';
            end;
            if v_flgstd = 'Y' then
                param_msg_error := get_error_msg_php('HR1500',global_v_lang);
                exit;
            end if;
        end loop;
    end validate_save_index;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        param_json      := hcm_util.get_json_t(json_obj,'param_json');
        validate_save_index;
        if param_msg_error is null then
            for i in 0..param_json.get_size-1 loop
                p_codform := upper(hcm_util.get_string_t(param_json,to_char(i)));
                delete from tfrmmail where codform = p_codform;
                delete from tfrmmailp where codform = p_codform;
            end loop;
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
    end save_index;

    procedure get_list_copy(json_str_input in clob, json_str_output out clob) as
        obj_data    json_object_t;
        obj_rows    json_object_t;
        v_row       number := 0;
        cursor c1 is
            select codform,decode(global_v_lang,'101',descode,
                                                '102',descodt,
                                                '103',descod3,
                                                '104',descod4,
                                                '105',descod5) desc_codform
              from tfrmmail
             where codform <> p_codform
          order by codform;
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            obj_rows    := json_object_t();
            for i in c1 loop
                v_row := v_row+1;
                obj_data := json_object_t();
                obj_data.put('codform',i.codform);
                obj_data.put('desc_codform',i.desc_codform);
                obj_rows.put(to_char(v_row-1),obj_data);
            end loop;
            json_str_output := obj_rows.to_clob;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_list_copy;

end HRCO14E;

/

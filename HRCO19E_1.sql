--------------------------------------------------------
--  DDL for Package Body HRCO19E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO19E" as

    -- Update 05/09/2019 11:00

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codcodec        := upper(hcm_util.get_string_t(json_obj,'p_codcodec'));
    end initial_value;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        cursor c1 is
            select *
              from tcodskil
          order by codcodec;
    begin
        initial_value(json_str_input);
        obj_rows    := json_object_t();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('codcodec',i.codcodec);
            obj_data.put('desc_codcodec',get_tcodec_name('TCODSKIL',i.codcodec,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_rows.to_clob;
    end get_index;

    function validate_import(json_obj json_object_t, v_coderror out varchar, v_text out varchar2, v_error_fld out varchar2) return boolean as
        v_codcodec  varchar2(1000);
        v_descode   varchar2(1000);
        v_descodt   varchar2(1000);
        v_descod3   varchar2(1000);
        v_descod4   varchar2(1000);
        v_descod5   varchar2(1000);
        v_definite  varchar2(1000);
        v_definitt  varchar2(1000);
        v_definit3  varchar2(1000);
        v_definit4  varchar2(1000);
        v_definit5  varchar2(1000);
        v_table     varchar2(10 char) := 'tcodskil';
    begin
        v_codcodec  := hcm_util.get_string_t(json_obj,'codcodec');
        v_descode   := hcm_util.get_string_t(json_obj,'descode');
        v_descodt   := hcm_util.get_string_t(json_obj,'descodt');
        v_descod3   := hcm_util.get_string_t(json_obj,'descod3');
        v_descod4   := hcm_util.get_string_t(json_obj,'descod4');
        v_descod5   := hcm_util.get_string_t(json_obj,'descod5');
        v_definite  := hcm_util.get_string_t(json_obj,'definite');
        v_definitt  := hcm_util.get_string_t(json_obj,'definitt');
        v_definit3  := hcm_util.get_string_t(json_obj,'definit3');
        v_definit4  := hcm_util.get_string_t(json_obj,'definit4');
        v_definit5  := hcm_util.get_string_t(json_obj,'definit5');
        v_text      := v_codcodec||'|'||v_descode||'|'||v_descodt||'|'||
                       v_descod3||'|'||v_descod4||'|'||v_descod5||'|'||
                       v_definite||'|'||v_definitt||'|'||v_definit3||'|'||
                       v_definit4||'|'||v_definit5;
        if v_codcodec is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'codcodec)';
            return false;
        end if;
        if (length(v_codcodec)>4) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'codcodec)';
            return false;
        end if;
        if (length(v_descode)>150) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'descode)';
            return false;
        end if;
        if (length(v_descodt)>150) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'descodt)';
            return false;
        end if;
        if (length(v_descod3)>150) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'descod3)';
            return false;
        end if;
        if (length(v_descod4)>150) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'descod4)';
            return false;
        end if;
        if (length(v_descod5)>150) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'descod5)';
            return false;
        end if;
        if (length(v_definite)>500) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'definite)';
            return false;
        end if;
        if (length(v_definitt)>500) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'definitt)';
            return false;
        end if;
        if (length(v_definit3)>500) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'definit3)';
            return false;
        end if;
        if (length(v_definit4)>500) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'definit4)';
            return false;
        end if;
        if (length(v_definit5)>500) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'definit5)';
            return false;
        end if;
        return true;
    end validate_import;

    procedure save_tcodskil(obj_data json_object_t) as
        v_codcodec  tcodskil.codcodec%type;
        v_descode   tcodskil.descode%type;
        v_descodt   tcodskil.descodt%type;
        v_descod3   tcodskil.descod3%type;
        v_descod4   tcodskil.descod4%type;
        v_descod5   tcodskil.descod5%type;
        v_definite  tcodskil.definite%type;
        v_definitt  tcodskil.definitt%type;
        v_definit3  tcodskil.definit3%type;
        v_definit4  tcodskil.definit4%type;
        v_definit5  tcodskil.definit5%type;
        v_grade     tskilscor.grade%type;
        param_json_delete   json_object_t;
    begin
        v_codcodec  := upper(hcm_util.get_string_t(obj_data,'codcodec'));
        v_descode   := hcm_util.get_string_t(obj_data,'descode');
        v_descodt   := hcm_util.get_string_t(obj_data,'descodt');
        v_descod3   := hcm_util.get_string_t(obj_data,'descod3');
        v_descod4   := hcm_util.get_string_t(obj_data,'descod4');
        v_descod5   := hcm_util.get_string_t(obj_data,'descod5');
        v_definite  := hcm_util.get_string_t(obj_data,'definite');
        v_definitt  := hcm_util.get_string_t(obj_data,'definitt');
        v_definit3  := hcm_util.get_string_t(obj_data,'definit3');
        v_definit4  := hcm_util.get_string_t(obj_data,'definit4');
        v_definit5  := hcm_util.get_string_t(obj_data,'definit5');
        
        param_json_delete  := hcm_util.get_json_t(obj_data,'param_json');
        begin
            insert into tcodskil(codcodec,descode,descodt,descod3,descod4,descod5
                        ,definite,definitt,definit3,definit4,definit5,flgcorr,flgact
                        ,codcreate,dtecreate,coduser,dteupd)
                 values (v_codcodec,v_descode,v_descodt,v_descod3,v_descod4,v_descod5
                        ,v_definite,v_definitt,v_definit3,v_definit4,v_definit5,0,'1'
                        ,global_v_coduser,sysdate,global_v_coduser,sysdate);
        exception when dup_val_on_index then
            update tcodskil
               set descode = v_descode,
                   descodt = v_descodt,
                   descod3 = v_descod3,
                   descod4 = v_descod4,
                   descod5 = v_descod5,
                   definite = v_definite,
                   definitt = v_definitt,
                   definit3 = v_definit3,
                   definit4 = v_definit4,
                   definit5 = v_definit5,
                   coduser  = global_v_coduser,
                   dteupd   = sysdate
             where codcodec = v_codcodec;
        end;
        for i in 0..param_json_delete.get_size-1 loop
            v_grade := hcm_util.get_string_t(param_json_delete,to_char(i));
            delete from tskilscor where codskill = v_codcodec and grade = v_grade;
            delete from tcomptnh where codskill = v_codcodec and grade = v_grade;
            delete from tcomptcr where codskill = v_codcodec and grade = v_grade;
            delete from tcomptdev where codskill = v_codcodec and grade = v_grade;
        end loop;
    end save_tcodskil;

    procedure import_data_process(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        data_obj    json_object_t;
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_coderror  terrorm.errorno%type;
        v_rec_err   number := 0;
        v_rec_tran  number := 0;
        obj_result  json_object_t;
        v_text      varchar2(5000 char);
        v_error_fld varchar2(100 char);
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        obj_rows    := json_object_t();
        for i in 0..param_json.get_size-1 loop
            data_obj := hcm_util.get_json_t(param_json,to_char(i));
            if (validate_import(data_obj,v_coderror,v_text,v_error_fld)) = false then
                v_row := v_row+1;
                v_rec_err := v_rec_err+1;
                obj_data := json_object_t();
                obj_data.put('numseq',i + 1);
                obj_data.put('error_code',v_coderror||' '||get_errorm_name(v_coderror,global_v_lang)||' '||v_error_fld);
                obj_data.put('text',v_text);
                obj_rows.put(to_char(v_row-1),obj_data);
            else
                v_rec_tran := v_rec_tran+1;
                save_tcodskil(data_obj);
            end if;
        end loop;
        commit;
        obj_result  := json_object_t();

        obj_data    := json_object_t();
        obj_data.put('rec_tran', v_rec_tran);
        obj_data.put('rec_err', v_rec_err);
        obj_data.put('response',replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
        obj_result.put('detail',obj_data);

        obj_data    := json_object_t();
        obj_data.put('rows',obj_rows);
        obj_result.put('table',obj_data);

        obj_rows    := json_object_t();
        obj_rows.put('datadisp',obj_result);
        json_str_output := obj_rows.to_clob;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end import_data_process;

    procedure gen_detail(json_str_output out clob) as
        obj_result      json_object_t;
        obj_rows        json_object_t;
        obj_data        json_object_t;
        rec_tcodskil    tcodskil%rowtype;
        v_flgedit       varchar2(10 char);
        v_row           number := 0;
        cursor c_scor is
            select codskill,grade
              from tskilscor
             where codskill = p_codcodec
          order by grade;
    begin
        begin
            select *
              into rec_tcodskil
              from tcodskil
             where codcodec = p_codcodec;
            v_flgedit    := 'Edit';
        exception when no_data_found then
            rec_tcodskil := null;
            v_flgedit    := 'Add';
        end;
        obj_result    := json_object_t();
        obj_result.put('flgedit',v_flgedit);
        obj_result.put('codcodec',rec_tcodskil.codcodec);
        obj_result.put('descode',rec_tcodskil.descode);
        obj_result.put('descodt',rec_tcodskil.descodt);
        obj_result.put('descod3',rec_tcodskil.descod3);
        obj_result.put('descod4',rec_tcodskil.descod4);
        obj_result.put('descod5',rec_tcodskil.descod5);
        obj_result.put('definite',rec_tcodskil.definite);
        obj_result.put('definitt',rec_tcodskil.definitt);
        obj_result.put('definit3',rec_tcodskil.definit3);
        obj_result.put('definit4',rec_tcodskil.definit4);
        obj_result.put('definit5',rec_tcodskil.definit5);
        obj_rows := json_object_t();
        for i in c_scor loop
            v_row   := v_row + 1;
            obj_data    := json_object_t();
            obj_data.put('grade',i.grade);
            obj_data.put('desc_grade',get_tskilscor_name(p_codcodec,i.grade,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        obj_result.put('rows',obj_rows);
        obj_data := json_object_t();
        obj_data.put('0',obj_result);

        json_str_output := obj_data.to_clob;
    end gen_detail;

    procedure validate_get_detail as
    begin
        if p_codcodec is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end validate_get_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        validate_get_detail;
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure validate_save_detail(json_str_input in clob) as
        json_obj    json_object_t;
        v_descode   tcodskil.descode%type;
        v_descodt   tcodskil.descodt%type;
        v_descod3   tcodskil.descod3%type;
        v_descod4   tcodskil.descod4%type;
        v_descod5   tcodskil.descod5%type;
    begin
        json_obj    := json_object_t(json_str_input);
        v_descode   := hcm_util.get_string_t(json_obj,'descode');
        v_descodt   := hcm_util.get_string_t(json_obj,'descodt');
        v_descod3   := hcm_util.get_string_t(json_obj,'descod3');
        v_descod4   := hcm_util.get_string_t(json_obj,'descod4');
        v_descod5   := hcm_util.get_string_t(json_obj,'descod5');
        if p_codcodec is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if global_v_lang = '101' and v_descode is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '102' and v_descodt is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '103' and v_descod3 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '104' and v_descod4 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif global_v_lang = '105' and v_descod5 is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end validate_save_detail;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        obj_data    json_object_t;
    begin
        initial_value(json_str_input);
        validate_save_detail(json_str_input);
        if param_msg_error is null then
            obj_data := json_object_t(json_str_input);
            obj_data.put('codcodec',p_codcodec);
            save_tcodskil(obj_data);
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

    procedure validate_get_skill_score(json_str_input in clob) as
        json_obj json_object_t;
        v_grade     tskilscor.grade%type;
    begin
        json_obj    := json_object_t(json_str_input);
        v_grade     := upper(hcm_util.get_string_t(json_obj,'p_grade'));

        if p_codcodec is null or v_grade is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end validate_get_skill_score;

    function gen_tcomptnh(v_grade varchar2) return json_object_t as
        json_obj        json_object_t;
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        cursor c_tcomptnh is
            select *
              from tcomptnh
             where codskill = p_codcodec
               and grade = v_grade
          order by numseq;
    begin
        obj_rows := json_object_t();
        for i in c_tcomptnh loop
            v_row   := v_row + 1;
            obj_data    := json_object_t();
            obj_data.put('numseq',i.numseq);
            obj_data.put('measure',i.measure);
            obj_data.put('measurt',i.measurt);
            obj_data.put('measur3',i.measur3);
            obj_data.put('measur4',i.measur4);
            obj_data.put('measur5',i.measur5);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        return obj_rows;
    end gen_tcomptnh;

    function gen_tcomptcr(v_grade varchar2) return json_object_t as
        json_obj        json_object_t;
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        cursor c_tcomptcr is
            select *
              from tcomptcr
             where codskill = p_codcodec
               and grade = v_grade
          order by codcours;
    begin
        obj_rows := json_object_t();
        for i in c_tcomptcr loop
            v_row   := v_row + 1;
            obj_data    := json_object_t();
            obj_data.put('codcours',i.codcours);
            obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        return obj_rows;
    end gen_tcomptcr;

    procedure get_tcomptnh(json_str_input in clob, json_str_output out clob) as
        json_obj        json_object_t;
        obj_data        json_object_t;
        v_grade         tskilscor.grade%type;
        v_row           number := 0;
    begin
        json_obj    := json_object_t(json_str_input);
        v_grade     := upper(hcm_util.get_string_t(json_obj,'p_grade'));
        initial_value(json_str_input);
        validate_get_skill_score(json_str_input);
        if param_msg_error is null then
            obj_data := json_object_t();
            obj_data := gen_tcomptnh(v_grade);
            json_str_output := obj_data.to_clob;
            return;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_tcomptnh;

    procedure gen_skill_score(json_str_input in clob, json_str_output out clob) as
        json_obj        json_object_t;
        obj_result      json_object_t;
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_grade         tskilscor.grade%type;
        rec_tskilscor   tskilscor%rowtype;
        v_flgedit       varchar2(10 char);
        v_row           number := 0;

        cursor c_tcomptnh is
            select *
              from tcomptnh
             where codskill = p_codcodec
               and grade = v_grade
          order by numseq;
    begin
        json_obj    := json_object_t(json_str_input);
        v_grade     := upper(hcm_util.get_string_t(json_obj,'p_grade'));
        begin
            select *
              into rec_tskilscor
              from tskilscor
             where codskill = p_codcodec
               and grade = v_grade;
            v_flgedit := 'Edit';
        exception when no_data_found then
            rec_tskilscor := null;
            v_flgedit := 'Add';
        end;
        obj_result    := json_object_t();
        obj_result.put('flgedit',v_flgedit);
        obj_result.put('codskill',p_codcodec);
        obj_result.put('grade',rec_tskilscor.grade);
        obj_result.put('namgrade',rec_tskilscor.namgrade);
        obj_result.put('namgradt',rec_tskilscor.namgradt);
        obj_result.put('namgrad3',rec_tskilscor.namgrad3);
        obj_result.put('namgrad4',rec_tskilscor.namgrad4);
        obj_result.put('namgrad5',rec_tskilscor.namgrad5);
        obj_data := json_object_t();
        obj_data.put('0',obj_result);

        json_str_output := obj_data.to_clob;
    end gen_skill_score;

    procedure get_skill_score(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        validate_get_skill_score(json_str_input);
        if param_msg_error is null then
            gen_skill_score(json_str_input, json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_skill_score;

    function validate_import_tcomptnh(json_obj json_object_t, v_coderror out varchar, v_text out varchar2, v_error_fld out varchar2) return boolean as
        v_codskill  varchar2(1000);
        v_grade     varchar2(1000);
        v_numseq    number;
        v_measure   varchar2(1000);
        v_measurt   varchar2(1000);
        v_measur3   varchar2(1000);
        v_measur4   varchar2(1000);
        v_measur5   varchar2(1000);
        v_table     varchar2(10 char) := 'tcomptnh';
        v_temp      varchar2(1 char);
    begin
        v_codskill  := upper(hcm_util.get_string_t(json_obj,'codskill'));
        v_grade     := upper(hcm_util.get_string_t(json_obj,'grade'));
        v_numseq    := to_number(hcm_util.get_string_t(json_obj,'numseq'));
        v_measure   := hcm_util.get_string_t(json_obj,'measure');
        v_measurt   := hcm_util.get_string_t(json_obj,'measurt');
        v_measur3   := hcm_util.get_string_t(json_obj,'measur3');
        v_measur4   := hcm_util.get_string_t(json_obj,'measur4');
        v_measur5   := hcm_util.get_string_t(json_obj,'measur5');
        v_text      := v_codskill||'|'||v_grade||'|'||v_numseq||'|'||
                       v_measure||'|'||v_measurt||'|'||v_measur3||'|'||
                       v_measur4||'|'||v_measur5;
        if v_codskill is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'codskill)';
            return false;
        end if;
        if v_grade is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'grade)';
            return false;
        end if;
        if v_numseq is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'numseq)';
            return false;
        end if;
        if (length(v_codskill)>4) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'codskill)';
            return false;
        end if;
        if (length(v_grade)>2) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'grade)';
            return false;
        end if;
        if (length(v_numseq)>2) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'grade)';
            return false;
        end if;
        begin
            select 'X'
              into v_temp
              from tcodskil
             where codcodec = v_codskill;
        exception when no_data_found then
            v_coderror  := 'HR2010';
            v_error_fld := 'tcodskil'||'('||'codskill)';
            return false;
        end;
        if (length(v_measure)>500) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'measure)';
            return false;
        end if;
        if (length(v_measurt)>500) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'measurt)';
            return false;
        end if;
        if (length(v_measur3)>500) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'measur3)';
            return false;
        end if;
        if (length(v_measur4)>500) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'measur4)';
            return false;
        end if;
        if (length(v_measur5)>500) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'measur5)';
            return false;
        end if;
        return true;
    end validate_import_tcomptnh;

    procedure save_data_tcomptnh(json_obj json_object_t) as
        v_codskill  tcomptnh.codskill%type;
        v_grade     tcomptnh.grade%type;
        v_numseq    tcomptnh.numseq%type;
        v_measure   tcomptnh.measure%type;
        v_measurt   tcomptnh.measurt%type;
        v_measur3   tcomptnh.measur3%type;
        v_measur4   tcomptnh.measur4%type;
        v_measur5   tcomptnh.measur5%type;
        v_flgedit   varchar2(10 char);
    begin
        v_codskill  := upper(hcm_util.get_string_t(json_obj,'codskill'));
        v_grade     := upper(hcm_util.get_string_t(json_obj,'grade'));
        v_numseq    := to_number(hcm_util.get_string_t(json_obj,'numseq'));
        v_measure   := hcm_util.get_string_t(json_obj,'measure');
        v_measurt   := hcm_util.get_string_t(json_obj,'measurt');
        v_measur3   := hcm_util.get_string_t(json_obj,'measur3');
        v_measur4   := hcm_util.get_string_t(json_obj,'measur4');
        v_measur5   := hcm_util.get_string_t(json_obj,'measur5');
        v_flgedit   := hcm_util.get_string_t(json_obj,'flgedit');
        if v_flgedit = 'Delete' then
            delete from tcomptnh
                  where codskill = v_codskill
                    and grade = v_grade
                    and numseq = v_numseq;
        else
            begin
                insert
                  into tcomptnh(codskill,grade,numseq,measure,measurt,measur3
                       ,measur4,measur5,dtecreate,codcreate,dteupd,coduser)
                values (v_codskill,v_grade,v_numseq,v_measure,v_measurt,v_measur3
                       ,v_measur4,v_measur5,sysdate,global_v_coduser,sysdate
                       ,global_v_coduser);
            exception when dup_val_on_index then
                update tcomptnh
                   set measure = v_measure,
                       measurt = v_measurt,
                       measur3 = v_measur3,
                       measur4 = v_measur4,
                       measur5 = v_measur5,
                       dteupd  = sysdate,
                       coduser  = global_v_coduser
                 where codskill = v_codskill
                   and grade = v_grade
                   and numseq = v_numseq;
            end;
        end if;
    end save_data_tcomptnh;

    procedure import_data_tcomptnh(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        data_obj    json_object_t;
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_coderror  terrorm.errorno%type;
        v_rec_err   number := 0;
        v_rec_tran  number := 0;
        obj_result  json_object_t;
        v_text      varchar2(5000 char);
        v_error_fld varchar2(100 char);
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        obj_rows    := json_object_t();
        for i in 0..param_json.get_size-1 loop
            data_obj := hcm_util.get_json_t(param_json,to_char(i));
            if (validate_import_tcomptnh(data_obj,v_coderror,v_text,v_error_fld)) = false then
                v_row := v_row+1;
                v_rec_err := v_rec_err+1;
                obj_data := json_object_t();
                obj_data.put('numseq',i + 1);
                obj_data.put('error_code',v_coderror||' '||get_errorm_name(v_coderror,global_v_lang)||' '||v_error_fld);
                obj_data.put('text',v_text);
                obj_rows.put(to_char(v_row-1),obj_data);
            else
                v_rec_tran := v_rec_tran+1;
                save_data_tcomptnh(data_obj);
            end if;
        end loop;
        commit;
        obj_result  := json_object_t();

        obj_data    := json_object_t();
        obj_data.put('rec_tran', v_rec_tran);
        obj_data.put('rec_err', v_rec_err);
        obj_data.put('response',replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
        obj_result.put('detail',obj_data);

        obj_data    := json_object_t();
        obj_data.put('rows',obj_rows);
        obj_result.put('table',obj_data);

        obj_rows    := json_object_t();
        obj_rows.put('datadisp',obj_result);
        json_str_output := obj_rows.to_clob;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end import_data_tcomptnh;

    procedure get_tcomptcr(json_str_input in clob, json_str_output out clob) as
        json_obj        json_object_t;
        obj_data        json_object_t;
        v_grade         tcomptcr.grade%type;
        v_row           number := 0;
    begin
        json_obj    := json_object_t(json_str_input);
        v_grade     := upper(hcm_util.get_string_t(json_obj,'p_grade'));
        initial_value(json_str_input);
        validate_get_skill_score(json_str_input);
        if param_msg_error is null then
            obj_data := json_object_t();
            obj_data := gen_tcomptcr(v_grade);
            json_str_output := obj_data.to_clob;
            return;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_tcomptcr;

    function validate_import_tcomptcr(json_obj json_object_t, v_coderror out varchar, v_text out varchar2, v_error_fld out varchar2) return boolean as
        v_codskill  varchar2(100);
        v_grade     varchar2(100);
        v_codcours  varchar2(100);
        v_table     varchar2(10 char) := 'tcomptcr';
        v_temp      varchar2(1 char);
    begin
        v_codskill  := upper(hcm_util.get_string_t(json_obj,'codskill'));
        v_grade     := upper(hcm_util.get_string_t(json_obj,'grade'));
        v_codcours  := upper(hcm_util.get_string_t(json_obj,'codcours'));
        v_text      := v_codskill||'|'||v_grade||'|'||v_codcours;
        if v_codskill is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'codskill)';
            return false;
        end if;
        if v_grade is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'grade)';
            return false;
        end if;
        if v_codcours is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'codcours)';
            return false;
        end if;
        if (length(v_codskill)>4) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'codskill)';
            return false;
        end if;
        if (length(v_grade)>2) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'grade)';
            return false;
        end if;
        if (length(v_codcours)>6) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'codcours)';
            return false;
        end if;
        begin
            select 'X'
              into v_temp
              from tcodskil
             where codcodec = v_codskill;
        exception when no_data_found then
            v_coderror  := 'HR2010';
            v_error_fld := 'tcodskill'||'('||'codskill,grade)';
            return false;
        end;
        begin
            select 'X'
            into v_temp
            from tcourse
            where codcours = v_codcours;
        exception when no_data_found then
            v_coderror  := 'HR2010';
            v_error_fld := 'tcourse'||'('||'codcours)';
            return false;
        end;
        return true;
    end validate_import_tcomptcr;

    procedure save_data_tcomptcr(json_obj json_object_t) as
        v_codskill  tcomptcr.codskill%type;
        v_grade     tcomptcr.grade%type;
        v_codcours  tcomptcr.codcours%type;
        v_flgedit   varchar2(10 char);
    begin
        v_codskill  := upper(hcm_util.get_string_t(json_obj,'codskill'));
        v_grade     := upper(hcm_util.get_string_t(json_obj,'grade'));
        v_codcours  := upper(hcm_util.get_string_t(json_obj,'codcours'));
        v_flgedit   := hcm_util.get_string_t(json_obj,'flgedit');
        if v_flgedit = 'Delete' then
            delete from tcomptcr
                  where codskill = v_codskill
                    and grade    = v_grade
                    and codcours = v_codcours;
        else
            begin
                insert
                  into tcomptcr(codskill,grade,codcours,dtecreate,codcreate,dteupd,coduser)
                values (v_codskill,v_grade,v_codcours,sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update tcomptcr
                   set dteupd   = sysdate,
                       coduser  = global_v_coduser
                 where codskill = v_codskill
                   and grade    = v_grade
                   and codcours = v_codcours;
            end;
        end if;
    end save_data_tcomptcr;

    procedure import_data_tcomptcr(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        data_obj    json_object_t;
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_coderror  terrorm.errorno%type;
        v_rec_err   number := 0;
        v_rec_tran  number := 0;
        obj_result  json_object_t;
        v_text      varchar2(5000 char);
        v_error_fld varchar2(100 char);
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        obj_rows    := json_object_t();
        for i in 0..param_json.get_size-1 loop
            data_obj := hcm_util.get_json_t(param_json,to_char(i));
            if (validate_import_tcomptcr(data_obj,v_coderror,v_text,v_error_fld)) = false then
                v_row := v_row+1;
                v_rec_err := v_rec_err+1;
                obj_data := json_object_t();
                obj_data.put('numseq',i + 1);
                obj_data.put('error_code',v_coderror||' '||get_errorm_name(v_coderror,global_v_lang)||' '||v_error_fld);
                obj_data.put('text',v_text);
                obj_rows.put(to_char(v_row-1),obj_data);
            else
                v_rec_tran := v_rec_tran+1;
                save_data_tcomptcr(data_obj);
            end if;
        end loop;
        commit;
        obj_result  := json_object_t();

        obj_data    := json_object_t();
        obj_data.put('rec_tran', v_rec_tran);
        obj_data.put('rec_err', v_rec_err);
        obj_data.put('response',replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
        obj_result.put('detail',obj_data);

        obj_data    := json_object_t();
        obj_data.put('rows',obj_rows);
        obj_result.put('table',obj_data);

        obj_rows    := json_object_t();
        obj_rows.put('datadisp',obj_result);
        json_str_output := obj_rows.to_clob;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end import_data_tcomptcr;

    function gen_tcomptdev(v_grade varchar2) return json_object_t as
        json_obj        json_object_t;
        obj_rows        json_object_t;
        obj_data        json_object_t;
        v_row           number := 0;
        cursor c_tcomptdev is
            select *
              from tcomptdev
             where codskill = p_codcodec
               and grade = v_grade
          order by coddevp;
    begin
        obj_rows := json_object_t();
        for i in c_tcomptdev loop
            v_row   := v_row + 1;
            obj_data    := json_object_t();
            obj_data.put('coddevp',i.coddevp);
            obj_data.put('desdevp',i.desdevp);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        return obj_rows;
    end gen_tcomptdev;

    procedure get_tcomptdev(json_str_input in clob, json_str_output out clob) as
        json_obj        json_object_t;
        obj_data        json_object_t;
        v_grade         tcomptdev.grade%type;
        v_row           number := 0;
    begin
        json_obj    := json_object_t(json_str_input);
        v_grade     := upper(hcm_util.get_string_t(json_obj,'p_grade'));
        initial_value(json_str_input);
        validate_get_skill_score(json_str_input);
        if param_msg_error is null then
            obj_data := json_object_t();
            obj_data := gen_tcomptdev(v_grade);
            json_str_output := obj_data.to_clob;
            return;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_tcomptdev;

    function validate_import_tcomptdev(json_obj json_object_t, v_coderror out varchar, v_text out varchar2, v_error_fld out varchar2) return boolean as
        v_codskill  varchar2(100);
        v_grade     varchar2(100);
        v_coddevp   varchar2(100);
        v_desdevp   varchar2(1000);
        v_table     varchar2(10 char) := 'tcomptdev';
        v_temp      varchar2(1 char);
    begin
        v_codskill  := upper(hcm_util.get_string_t(json_obj,'codskill'));
        v_grade     := upper(hcm_util.get_string_t(json_obj,'grade'));
        v_coddevp   := upper(hcm_util.get_string_t(json_obj,'coddevp'));
        v_desdevp   := hcm_util.get_string_t(json_obj,'desdevp');
        v_text      := v_codskill||'|'||v_grade||'|'||v_coddevp||'|'||v_desdevp;
        if v_codskill is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'codskill)';
            return false;
        end if;
        if v_grade is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'grade)';
            return false;
        end if;
        if v_coddevp is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'coddevp)';
            return false;
        end if;
        if (length(v_codskill)>4) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'codskill)';
            return false;
        end if;
        if (length(v_grade)>2) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'grade)';
            return false;
        end if;
        if (length(v_coddevp)>4) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'coddevp)';
            return false;
        end if;
        if (length(v_desdevp)>500) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'desdevp)';
            return false;
        end if;
        begin
            select 'X'
              into v_temp
              from tcodskil
             where codcodec = v_codskill;
        exception when no_data_found then
            v_coderror  := 'HR2010';
            v_error_fld := 'tcodskil'||'('||'codskill)';
            return false;
        end;
        begin
            select 'X'
            into v_temp
            from tcoddevt
            where codcodec = v_coddevp;
        exception when no_data_found then
            v_coderror  := 'HR2010';
            v_error_fld := 'tcoddevt'||'('||'coddevp)';
            return false;
        end;
        return true;
    end validate_import_tcomptdev;

    procedure save_data_tcomptdev(json_obj json_object_t) as
        v_codskill  tcomptdev.codskill%type;
        v_grade     tcomptdev.grade%type;
        v_coddevp   tcomptdev.coddevp%type;
        v_desdevp   tcomptdev.desdevp%type;
        v_flgedit   varchar2(10 char);
    begin
        v_codskill  := upper(hcm_util.get_string_t(json_obj,'codskill'));
        v_grade     := upper(hcm_util.get_string_t(json_obj,'grade'));
        v_coddevp   := upper(hcm_util.get_string_t(json_obj,'coddevp'));
        v_desdevp   := hcm_util.get_string_t(json_obj,'desdevp');
        v_flgedit   := hcm_util.get_string_t(json_obj,'flgedit');
        if v_flgedit = 'Delete' then
            delete from tcomptdev
                 where codskill = v_codskill
                   and grade    = v_grade
                   and coddevp  = v_coddevp;
        else
            begin
                insert
                  into tcomptdev(codskill,grade,coddevp,desdevp,dtecreate,codcreate,dteupd,coduser)
                values (v_codskill,v_grade,v_coddevp,v_desdevp,sysdate,global_v_coduser,sysdate
                        ,global_v_coduser);
            exception when dup_val_on_index then
                update tcomptdev
                   set desdevp  = v_desdevp,
                       dteupd   = sysdate,
                       coduser  = global_v_coduser
                 where codskill = v_codskill
                   and grade    = v_grade
                   and coddevp  = v_coddevp;
            end;
        end if;
    end save_data_tcomptdev;

    procedure import_data_tcomptdev(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        data_obj    json_object_t;
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_coderror  terrorm.errorno%type;
        v_rec_err   number := 0;
        v_rec_tran  number := 0;
        obj_result  json_object_t;
        v_text      varchar2(5000 char);
        v_error_fld varchar2(100 char);
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        obj_rows    := json_object_t();
        for i in 0..param_json.get_size-1 loop
            data_obj := hcm_util.get_json_t(param_json,to_char(i));
            if (validate_import_tcomptdev(data_obj,v_coderror,v_text,v_error_fld)) = false then
                v_row := v_row+1;
                v_rec_err := v_rec_err+1;
                obj_data := json_object_t();
                obj_data.put('numseq',i + 1);
                obj_data.put('error_code',v_coderror||' '||get_errorm_name(v_coderror,global_v_lang)||' '||v_error_fld);
                obj_data.put('text',v_text);
                obj_rows.put(to_char(v_row-1),obj_data);
            else
                v_rec_tran := v_rec_tran+1;
                save_data_tcomptdev(data_obj);
            end if;
        end loop;
        commit;
        obj_result  := json_object_t();

        obj_data    := json_object_t();
        obj_data.put('rec_tran', v_rec_tran);
        obj_data.put('rec_err', v_rec_err);
        obj_data.put('response',replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
        obj_result.put('detail',obj_data);

        obj_data    := json_object_t();
        obj_data.put('rows',obj_rows);
        obj_result.put('table',obj_data);

        obj_rows    := json_object_t();
        obj_rows.put('datadisp',obj_result);
        json_str_output := obj_rows.to_clob;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end import_data_tcomptdev;

    procedure validate_save_skill_score(json_obj json_object_t) as
        v_grade     tskilscor.grade%type;
        v_namgrade  tskilscor.namgrade%type;
        v_namgradt  tskilscor.namgradt%type;
        v_namgrad3  tskilscor.namgrad3%type;
        v_namgrad4  tskilscor.namgrad4%type;
        v_namgrad5  tskilscor.namgrad5%type;
    begin
        v_grade     := upper(hcm_util.get_string_t(json_obj,'p_grade'));
        v_namgrade  := hcm_util.get_string_t(json_obj,'namgrade');
        v_namgradt  := hcm_util.get_string_t(json_obj,'namgradt');
        v_namgrad3  := hcm_util.get_string_t(json_obj,'namgrad3');
        v_namgrad4  := hcm_util.get_string_t(json_obj,'namgrad4');
        v_namgrad5  := hcm_util.get_string_t(json_obj,'namgrad5');
        if (p_codcodec is null) or (v_grade is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if (global_v_lang = '101') and (v_namgrade is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif (global_v_lang = '102') and (v_namgradt is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif (global_v_lang = '103') and (v_namgrad3 is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif (global_v_lang = '104') and (v_namgrad4 is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif (global_v_lang = '105') and (v_namgrad5 is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end validate_save_skill_score;

    procedure save_data_tskilscore(json_obj json_object_t) as
        v_grade     tskilscor.grade%type;
        v_namgrade  tskilscor.namgrade%type;
        v_namgradt  tskilscor.namgradt%type;
        v_namgrad3  tskilscor.namgrad3%type;
        v_namgrad4  tskilscor.namgrad4%type;
        v_namgrad5  tskilscor.namgrad5%type;
        tab_tcomptnh    json_object_t;
        obj_data    json_object_t;
    begin
        v_grade     := upper(hcm_util.get_string_t(json_obj,'p_grade'));
        v_namgrade  := hcm_util.get_string_t(json_obj,'namgrade');
        v_namgradt  := hcm_util.get_string_t(json_obj,'namgradt');
        v_namgrad3  := hcm_util.get_string_t(json_obj,'namgrad3');
        v_namgrad4  := hcm_util.get_string_t(json_obj,'namgrad4');
        v_namgrad5  := hcm_util.get_string_t(json_obj,'namgrad5');
        tab_tcomptnh    := hcm_util.get_json_t(json_obj,'tcomptnh');
        begin
            insert
              into tskilscor(codskill,grade,namgrade,namgradt,namgrad3,namgrad4
                   ,namgrad5,dtecreate,codcreate,dteupd,coduser)
            values (p_codcodec,v_grade,v_namgrade,v_namgradt,v_namgrad3,v_namgrad4
                    ,v_namgrad5,sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            update tskilscor
               set namgrade = v_namgrade,
                   namgradt = v_namgradt,
                   namgrad3 = v_namgrad3,
                   namgrad4 = v_namgrad4,
                   namgrad5 = v_namgrad5,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codskill = p_codcodec
               and grade = v_grade;
        end;
    end save_data_tskilscore;

    procedure validate_save_tcomptnh(json_obj json_object_t) as
        v_codskill  tcomptnh.codskill%type;
        v_grade     tcomptnh.grade%type;
        v_numseq    tcomptnh.numseq%type;
        v_measure   tcomptnh.measure%type;
        v_measurt   tcomptnh.measurt%type;
        v_measur3   tcomptnh.measur3%type;
        v_measur4   tcomptnh.measur4%type;
        v_measur5   tcomptnh.measur5%type;
        v_flgedit   varchar2(10 char);
        v_count     number;
    begin
        v_codskill  := upper(hcm_util.get_string_t(json_obj,'codskill'));
        v_grade     := upper(hcm_util.get_string_t(json_obj,'grade'));
        v_numseq    := to_number(hcm_util.get_string_t(json_obj,'numseq'));
        v_measure   := hcm_util.get_string_t(json_obj,'measure');
        v_measurt   := hcm_util.get_string_t(json_obj,'measurt');
        v_measur3   := hcm_util.get_string_t(json_obj,'measur3');
        v_measur4   := hcm_util.get_string_t(json_obj,'measur4');
        v_measur5   := hcm_util.get_string_t(json_obj,'measur5');
        v_flgedit   := hcm_util.get_string_t(json_obj,'flgedit');
        if v_numseq is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if (global_v_lang = 101) and (v_measure is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif (global_v_lang = 102) and (v_measurt is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif (global_v_lang = 103) and (v_measur3 is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif (global_v_lang = 104) and (v_measur4 is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif (global_v_lang = 105) and (v_measur5 is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if v_flgedit = 'Add' then
            begin
                select count(*)
                into v_count
                from tcomptnh
                where codskill = v_codskill
                and grade = v_grade
                and numseq = v_numseq;
            exception when no_data_found then
                v_count := 0;
            end;
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tcomptnh');
                return;
            end if;
        end if;
    end;

    procedure validate_save_tcomptcr(json_obj json_object_t) as
        v_codskill  tcomptcr.codskill%type;
        v_grade     tcomptcr.grade%type;
        v_codcours  tcomptcr.codcours%type;
        v_temp      varchar2(1 char);
        v_flgedit   varchar2(10 char);
        v_count     number;
    begin
        v_codskill  := upper(hcm_util.get_string_t(json_obj,'codskill'));
        v_grade     := upper(hcm_util.get_string_t(json_obj,'grade'));
        v_codcours  := upper(hcm_util.get_string_t(json_obj,'codcours'));
        v_flgedit   := hcm_util.get_string_t(json_obj,'flgedit');
        if v_codcours is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if v_flgedit = 'Add' then
            begin
                select count(*)
                into v_count
                from tcomptcr
                where codskill = v_codskill
                and grade = v_grade
                and codcours = v_codcours;
            exception when no_data_found then
                v_count := 0;
            end;
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tcomptcr');
                return;
            end if;
        end if;
        begin
            select 'X'
            into v_temp
            from tcourse
            where codcours = v_codcours;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcourse');
            return;
        end;
    end validate_save_tcomptcr;

    procedure validate_save_tcomptdev(json_obj json_object_t) as
        v_codskill  tcomptdev.codskill%type;
        v_grade     tcomptdev.grade%type;
        v_coddevp   tcomptdev.coddevp%type;
        v_desdevp   tcomptdev.desdevp%type;
        v_temp      varchar2(1 char);
        v_flgedit   varchar2(10 char);
        v_count     number;
    begin
        v_codskill  := upper(hcm_util.get_string_t(json_obj,'codskill'));
        v_grade     := upper(hcm_util.get_string_t(json_obj,'grade'));
        v_coddevp   := upper(hcm_util.get_string_t(json_obj,'coddevp'));
        v_desdevp   := hcm_util.get_string_t(json_obj,'desdevp');
        v_flgedit   := hcm_util.get_string_t(json_obj,'flgedit');
        if v_coddevp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if v_flgedit = 'Add' then
            begin
                select count(*)
                into v_count
                from tcomptdev
                where codskill = v_codskill
                and grade = v_grade
                and coddevp = v_coddevp;
            exception when no_data_found then
                v_count := 0;
            end;
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tcomptdev');
                return;
            end if;
        end if;
        begin
            select 'X'
            into v_temp
            from tcoddevt
            where codcodec = v_coddevp;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcoddevt');
            return;
        end;
    end validate_save_tcomptdev;

    procedure save_tab_tcomptdev(json_obj json_object_t) as
        v_grade         tcomptcr.grade%type;
        tab_tcomptdev    json_object_t;
        obj_data        json_object_t;
    begin
        tab_tcomptdev    := hcm_util.get_json_t(json_obj,'tcomptdev');
        v_grade         := upper(hcm_util.get_string_t(json_obj,'p_grade'));
        for tab2 in 0..tab_tcomptdev.get_size-1 loop
            obj_data := hcm_util.get_json_t(tab_tcomptdev,to_char(tab2));
            obj_data.put('codskill',p_codcodec);
            obj_data.put('grade',v_grade);
            validate_save_tcomptdev(obj_data);
            if param_msg_error is not null then
                exit;
            end if;
            save_data_tcomptdev(obj_data);
        end loop;
    end save_tab_tcomptdev;

    procedure save_tab_tcomptcr(json_obj json_object_t) as
        v_grade         tcomptcr.grade%type;
        tab_tcomptcr    json_object_t;
        obj_data        json_object_t;
    begin
        tab_tcomptcr    := hcm_util.get_json_t(json_obj,'tcomptcr');
        v_grade         := upper(hcm_util.get_string_t(json_obj,'p_grade'));
        for tab2 in 0..tab_tcomptcr.get_size-1 loop
            obj_data := hcm_util.get_json_t(tab_tcomptcr,to_char(tab2));
            obj_data.put('codskill',p_codcodec);
            obj_data.put('grade',v_grade);
            validate_save_tcomptcr(obj_data);
            if param_msg_error is not null then
                exit;
            end if;
            save_data_tcomptcr(obj_data);
        end loop;
    end save_tab_tcomptcr;

    procedure save_tab_tcomptnh(json_obj json_object_t) as
        v_grade         tcomptnh.grade%type;
        tab_tcomptnh    json_object_t;
        obj_data        json_object_t;
    begin
        tab_tcomptnh    := hcm_util.get_json_t(json_obj,'tcomptnh');
        v_grade         := upper(hcm_util.get_string_t(json_obj,'p_grade'));
        for tab1 in 0..tab_tcomptnh.get_size-1 loop
            obj_data := hcm_util.get_json_t(tab_tcomptnh,to_char(tab1));
            obj_data.put('codskill',p_codcodec);
            obj_data.put('grade',v_grade);
            validate_save_tcomptnh(obj_data);
            if param_msg_error is not null then
                exit;
            end if;
            save_data_tcomptnh(obj_data);
        end loop;
    end save_tab_tcomptnh;

    procedure save_skill_score(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        json_obj.put('codcodec',p_codcodec);
        validate_save_skill_score(json_obj);
        if param_msg_error is null then
            save_data_tskilscore(json_obj);
            save_tab_tcomptnh(json_obj);
            if param_msg_error is not null then
                rollback;
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;
            save_tab_tcomptcr(json_obj);
            if param_msg_error is not null then
                rollback;
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;
            save_tab_tcomptdev(json_obj);
            if param_msg_error is not null then
                rollback;
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;
            commit;
            save_tcodskil(json_obj);
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_skill_score;

    procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        v_count     number;
    begin
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            p_codcodec  := hcm_util.get_string_t(param_json,to_char(i));
            validate_get_detail;
            begin
                select count(*)
                  into v_count
                  from tcmptncy
                 where codtency = p_codcodec;
            exception when others then
                v_count := 0;
            end;
            
            if v_count > 0 then
                param_msg_error := get_error_msg_php('HR1450',global_v_lang);
            else
                begin
                    select count(*)
                      into v_count
                      from tjobposskil
                     where codskill = p_codcodec;
                exception when others then
                    v_count := 0;
                end;
            
                if v_count > 0 then
                    param_msg_error := get_error_msg_php('HR1450',global_v_lang);
                end if;
            end if;
            
            if param_msg_error is not null then
                exit;
            end if;
            delete tcodskil  where codcodec = p_codcodec;
            delete tskilscor where codskill = p_codcodec;
            delete tcomptnh  where codskill = p_codcodec;
            delete tcomptcr  where codskill = p_codcodec;
            delete tcomptdev where codskill = p_codcodec;
        end loop;
        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        else
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
    end save_index;

end HRCO19E;

/

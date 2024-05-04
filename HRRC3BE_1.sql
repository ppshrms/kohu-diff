--------------------------------------------------------
--  DDL for Package Body HRRC3BE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC3BE" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj            := json_object_t(json_str_input);
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

        -- index param
        p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
        p_numappl           := hcm_util.get_string_t(json_obj,'p_numappl');
        p_datest            := to_date(hcm_util.get_string_t(json_obj,'p_datest'),'dd/mm/yyyy');
        p_dateen            := to_date(hcm_util.get_string_t(json_obj,'p_dateen'),'dd/mm/yyyy');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    end initial_value;

    procedure check_index as
    begin
        -- ฟิลด์ที่บังคับใส่ข้อมูล
        if p_codpos is null or p_numappl is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end;

    procedure get_data (json_str_input in clob, json_str_output out clob) is
    begin
        initial_value (json_str_input);
        check_index;
        gen_data (json_str_output);
    exception when others then
        param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end get_data;

    procedure gen_data(json_str_output out clob) as
        obj_row             json_object_t;
        obj_data            json_object_t;
        v_rcnt              number := 0;
        v_name              varchar2(1000 char);
        v_data              varchar2(1 char) := 'N';
        v_flgsecur          varchar2(1 char) := 'N';
        v_check_secur       boolean;
        cursor c1 is
            select *
              from tapplinf
             where numappl = nvl(p_numappl,numappl)
               and (codpos1 = nvl(p_codpos,codpos1)
                    or codpos2 = nvl(p_codpos,codpos2))
               and trunc(dteappl) between nvl(trunc(p_datest),trunc(dteappl)) and nvl(trunc(p_dateen),trunc(dteappl))
            order by numappl;
    begin
        obj_row         := json_object_t();

        for i in c1 loop
            v_data       := 'Y';
            v_check_secur     := secur_main.secur7(i.codcompl,global_v_coduser);
            v_check_secur     := true;
            if v_check_secur then
                v_flgsecur   := 'Y';
                v_rcnt       := v_rcnt+1;
                obj_data     := json_object_t();

                if global_v_lang = '101' then
                    v_name := i.namempe;
                elsif global_v_lang = '102' then
                    v_name := i.namempt;
                elsif global_v_lang = '103' then
                    v_name := i.namemp3;
                elsif global_v_lang = '104' then
                    v_name := i.namemp4;
                elsif global_v_lang = '105' then
                    v_name := i.namemp5;
                else
                    v_name := i.namempt;
                end if;

                obj_data.put('coderror', '200');
                obj_data.put('image', get_emp_img(i.codempid));
                obj_data.put('numappl', i.numappl);
                obj_data.put('namemp', v_name);
                obj_data.put('codpos1', get_tpostn_name(i.codpos1,global_v_lang));
                obj_data.put('codpos2', get_tpostn_name(i.codpos2,global_v_lang));
                obj_data.put('numreql', i.numreql);
                obj_data.put('codposl', get_tpostn_name(i.codposl,global_v_lang));
                obj_data.put('statappl', get_tlistval_name('STATAPPL',i.statappl,global_v_lang));
                obj_data.put('dteappl', i.dteappl);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;
        end loop;
        if v_data = 'N' then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tapplinf');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        elsif v_flgsecur = 'N' then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        else
            json_str_output := obj_row.to_clob;
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_data;

    procedure gen_detail (json_str_output out clob) is
        obj_row                 json_object_t;
        obj_data                json_object_t;
        v_rcnt                  number;
        cursor c1 is
            select *
              from tappfoll
             where numappl = p_numappl
            order by dtefoll desc, statappl desc ;
    begin
        obj_row                := json_object_t();
        v_rcnt                 := 0;

        delete from ttemprpt where codempid = 'A211';commit;   
        insert_ttemprpt('A211','A211',p_numappl,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));           

        for i in c1 loop
          obj_data             := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('dtefoll', to_char(i.dtefoll, 'DD/MM/YYYY'));
          obj_data.put('statappl', i.statappl);
          obj_data.put('desc_statappl', get_tlistval_name('STATAPPL',i.statappl,global_v_lang));
          obj_data.put('codrej', i.codrej);
          obj_data.put('desc_codrej', get_tcodec_name ('TCODREJE',i.codrej,global_v_lang));
          obj_data.put('remark', i.remark);
          obj_data.put('dteupd', to_char(i.dteupd,'dd/mm/yyyy'));
          obj_data.put('coduser', get_temploy_name(pdk.check_codempid(i.coduser),global_v_lang));

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt  := v_rcnt + 1;
        end loop;

        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
    end gen_detail;

    procedure get_detail (json_str_input in clob, json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
          gen_detail(json_str_output);
        else
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    function validate_save(v_dtefoll date,v_numappl varchar2,v_statappl varchar2,v_codrej number,v_flg varchar2) return boolean as
        v_check varchar2(1 char);
        v_count number := 0;
    begin
        if v_flg in ('ADD') then
            if v_statappl not in ('22','32','42','53','54','62','63') then
                param_msg_error := get_error_msg_php('RC0040',global_v_lang);
                return false;
            end if;
            begin
                select 'X' into v_check
                from tappfoll
                where numappl = v_numappl
                  and trunc(dtefoll) = trunc(v_dtefoll)
                  and statappl = v_statappl;
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TAPPFOLL');
                return false;
            exception when no_data_found then
                null;
            end;
        end if;
        if v_flg in ('ADD','EDIT') then
            begin
                select 'X' into v_check
                from tcodreje
                where codcodec = v_codrej;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODREJE');
                return false;
            end;
        end if;
        return true;
    end;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_param_obj      json_object_t;
        json_row            json_object_t;

        v_codrej            tappfoll.codrej%type;
        v_codrejOld         tappfoll.codrej%type;
        v_coduser           varchar2(1000 char);
        v_desc_codrej       varchar2(1000 char);
        v_desc_statappl     varchar2(1000 char);
        v_dtefoll           date;
        v_dtefollOld        date;
        v_dteupd            date;
        v_flg               varchar2(1000 char);
        v_remark            tappfoll.remark%type;
        v_remarkOld         tappfoll.remark%type;
        v_statappl          tappfoll.statappl%type;
        v_statapplOld       tappfoll.statappl%type;
        v_numreqst          tappfoll.statappl%type;
        v_codpos            tappfoll.statappl%type;
        v_max_dtefoll       date;
        v_validate          boolean;
        v_max_dte_sta       number;
        v_statappll         tappfoll.statappl%type;
        v_codrejl           tappfoll.codrej%type;
        v_codfolll          tappfoll.coduser%type;
        v_dtefolll          date;

        cursor c1 is
            select statappl,codrej,coduser,dteupd
              from tappfoll
             where numappl = p_numappl
               and to_number(to_char(dtefoll,'yyyymmdd')||statappl) < to_number(to_char(v_dtefoll,'yyyymmdd')||v_statappl)
            order by dtefoll desc, statappl desc;

        cursor c2 is
            select statappl,dtefoll,codrej
              from tappfoll
             where numappl = p_numappl
            order by dtefoll desc, statappl desc;

    begin
        initial_value(json_str_input);

        begin  
            select item1 into v2_numappl from ttemprpt where codempid = 'A211';
            p_numappl := v2_numappl;
        exception when no_data_found then
            p_numappl := null;
        end;

        json_param_obj            := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        if param_msg_error is null then
            for i in 0..json_param_obj.get_size-1 loop
                json_row        := hcm_util.get_json_t(json_param_obj, to_char(i));

                v_codrej        := hcm_util.get_string_t(json_row,'codrej');
                v_codrejOld     := hcm_util.get_string_t(json_row,'codrejOld');
                v_coduser       := hcm_util.get_string_t(json_row,'coduser');
                v_desc_codrej   := hcm_util.get_string_t(json_row,'desc_codrej');
                v_desc_statappl := hcm_util.get_string_t(json_row,'desc_statappl');
                v_dtefoll       := to_date(hcm_util.get_string_t(json_row,'dtefoll'),'dd/mm/yyyy'); --user39
                v_dtefollOld    := to_date(hcm_util.get_string_t(json_row,'dtefollOld'),'dd/mm/yyyy');
                v_dteupd        := to_date(hcm_util.get_string_t(json_row,'dteupd'),'dd/mm/yyyy');
                v_flg           := hcm_util.get_string_t(json_row,'flg');
                v_remark        := hcm_util.get_string_t(json_row,'remark');
                v_remarkOld     := hcm_util.get_string_t(json_row,'remarkOld');
                v_statappl      := hcm_util.get_string_t(json_row,'statappl'); --user39
                v_statapplOld   := hcm_util.get_string_t(json_row,'statapplOld');

                v_validate := validate_save(trunc(v_dtefoll),p_numappl,v_statappl,v_codrej,upper(v_flg));
                if v_validate = false then
                    exit;
                end if;

                begin
                    select v_numreqst,v_codpos
                      into v_numreqst,v_codpos
                      from tapplinf
                     where numappl = p_numappl;
                exception when no_data_found then
                    v_numreqst  := null;
                    v_codpos    := null;
                end;

                if upper(v_flg) = 'ADD' then    
                    insert into tappfoll (numappl,dtefoll,statappl,codrej, --user39 NUMAPPL DTEFOLL STATAPPL
                                          remark,codappr,numreqst,codpos,
                                          dtecreate,codcreate,dteupd,coduser)
                                  values (p_numappl,trunc(v_dtefoll),v_statappl,v_codrej,
                                          v_remark,null,v_numreqst,v_codpos,
                                          sysdate,global_v_coduser,sysdate,global_v_coduser);

                elsif upper(v_flg) = 'EDIT' then
                    update tappfoll set remark  = v_remark,
                                        codrej  = v_codrej,
                                        coduser = global_v_coduser,
                                        dteupd  = sysdate
                                  where numappl = p_numappl
                                    and trunc(dtefoll) = trunc(v_dtefoll)
                                    and statappl = v_statappl;
                elsif upper(v_flg) = 'DELETE' then
                    delete from tappfoll
                          where numappl = p_numappl
                            and trunc(dtefoll) = trunc(v_dtefoll)
                            and statappl = v_statappl;

                    begin
                        select max(trunc(dtefoll))
                          into v_max_dtefoll
                          from tappfoll
                         where numappl = p_numappl;
                    exception when no_data_found then
                        v_max_dtefoll  := null;
                    end;

                    if v_max_dtefoll = trunc(v_dtefoll) then
                        v_statappll := null;
                        v_codrejl   := null;
                        v_codfolll  := null;
                        v_dtefolll  := null;
                        for j in c1 loop
                            v_statappll := j.statappl;
                            v_codrejl   := j.codrej;
                            v_codfolll  := j.coduser;
                            v_dtefolll  := j.dteupd;
                            exit;
                        end loop;
                        update tapplinf set statappl = v_statappll,
                                            codrej   = v_codrejl,
                                            codfoll  = v_codfolll,
                                            dtefoll  = v_dtefolll,
                                            coduser  = global_v_coduser,
                                            dteupd   = sysdate
                                  where numappl = p_numappl;
                    end if;
                end if;
            end loop;
            if param_msg_error is null then
                commit;
                for j in c2 loop
                        update tapplinf set statappl = j.statappl,
                                            codrej   = j.codrej,
                                            codfoll  = global_v_coduser,
                                            dtefoll  = sysdate,
                                            coduser  = global_v_coduser,
                                            dteupd   = sysdate
                                  where numappl = p_numappl;
                        exit;
                end loop;
                commit;
                param_msg_error := get_error_msg_php('HR2401',global_v_lang);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            else
                rollback;
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            end if;
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end;
end HRRC3BE;

/

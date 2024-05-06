--------------------------------------------------------
--  DDL for Package Body HRTR1DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR1DE" AS

    procedure initial_value(json_str in clob) is
        json_obj   json := json(json_str);
    begin
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        json_params         := hcm_util.get_json(json_obj, 'json_input_str');

        b_index_codinsts    := hcm_util.get_string(json_obj, 'codinsts');

    end initial_value;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
        obj_data          json;
        obj_row           json;
        v_stmt		      varchar2(5000 char);
        v_cursor	      number;
        v_qty             number;
        v_cond            varchar2(4000 char) := '';
        v_rcnt            number := 0;
        v_row             number := 0;
        v_count           number := 0;
        v_codinsts        varchar2(4 char);
        v_naminst         varchar2(150 char);
        v_codprovr        varchar2(4 char);
        v_coddistr        varchar2(4 char);
        v_typinsts        varchar2(4 char);
        v_flgusesv        varchar2(5 char) := '';
        v_descod          varchar2(150 char);
        v_namdist         varchar2(150 char);

        dynamicCursor     SYS_REFCURSOR;

        cursor c_all is
            select      codinsts, get_tinstitu_name(codinsts,global_v_lang) nameinsts,
                        get_tcoddist_name(coddistr,global_v_lang) namedistr,
                        get_tcodec_name('TCODPROV',codprovr,global_v_lang) nameprovr,
                        get_tlistval_name('TYPINSTS', typinsts, global_v_lang) typinsts
            from        tinstitu
            order by    codinsts;

        cursor c_v_hrtr1de is
            select distinct  codinsts,
                    get_tinstitu_name(codinsts,global_v_lang) nameinsts,
                    get_tcoddist_name(coddistr,global_v_lang) namedistr,
                    get_tcodec_name('TCODPROV',codprovr,global_v_lang) nameprovr,
                    get_tlistval_name('TYPINSTS', typinsts, global_v_lang) typinsts
            from v_hrtr1d order by codinsts;

    begin
        initial_value(json_str_input);
        v_cond := hcm_util.get_string(hcm_util.get_json(json_params, 'syncond'), 'code');

        if v_cond is null then
            obj_row     := json();
            v_rcnt      := 0;
            for r1 in c_all loop
                v_rcnt := v_rcnt + 1;
                obj_data := json();
                obj_data.put('codinsts', r1.codinsts);
                obj_data.put('naminst', r1.nameinsts);
                obj_data.put('namedistr', r1.namedistr);
                obj_data.put('nameprovr', r1.nameprovr);
                obj_data.put('typinsts', r1.typinsts);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end loop;
        else
            obj_row     := json();
            v_rcnt      := 0;
            for r2 in c_v_hrtr1de loop
                v_cond := hcm_util.get_string(hcm_util.get_json(json_params, 'syncond'), 'code');
                v_count := 0;
                begin
                    select  count(*) into v_count
                      from  tinscour
                     where  codinsts = r2.codinsts
                       and  dtetrlst is not null;
                exception when no_data_found then
                    v_count := 0;
                end;

                v_flgusesv  := '''N''';
                if v_count <> 0 then
                    v_flgusesv := '''Y''';
                end if;

                v_cond  := replace(v_cond, 'TINSTITU.');
                v_cond  := replace(v_cond, 'TINSCOUR.');
                v_cond  := replace(v_cond, 'NAMINSTS', 'GET_TINSTITU_NAME(CODINSTS,' ||global_v_lang ||')');
                v_cond  := replace(v_cond, 'NAMECOURS', 'GET_TCOURSE_NAME(CODCOURS,' ||global_v_lang ||')');
                v_cond  := replace(v_cond, 'CODPROVR like', 'GET_TCODEC_NAME(''TCODPROV'',CODPROVR,'||global_v_lang||') like');
                v_cond  := replace(v_cond, 'CODDISTR like', 'GET_TCODDIST_NAME(CODDISTR,' ||global_v_lang ||') like ');
                v_cond  := replace(v_cond, 'CODPROVR not like', 'GET_TCODEC_NAME(''TCODPROV'',CODPROVR,'||global_v_lang||') not like');
                v_cond  := replace(v_cond, 'CODDISTR not like', 'GET_TCODDIST_NAME(CODDISTR,' ||global_v_lang ||') not like ');
                v_cond  := replace(v_cond, 'FLGUSESV', v_flgusesv);

                v_stmt  := 'select distinct codinsts from v_hrtr1d where ' || v_cond;
                open dynamicCursor for v_stmt;
                loop
                    fetch dynamicCursor into v_codinsts;
                    exit when dynamicCursor%NOTFOUND;
                    if v_codinsts = r2.codinsts then
                        v_rcnt := v_rcnt + 1;
                        obj_data := json();
                        obj_data.put('codinsts', r2.codinsts);
                        obj_data.put('naminst', r2.nameinsts);
                        obj_data.put('namedistr', r2.namedistr);
                        obj_data.put('nameprovr', r2.nameprovr);
                        obj_data.put('typinsts', r2.typinsts);
                        obj_row.put(to_char(v_rcnt-1),obj_data);
                    end if;
                end loop;
                close dynamicCursor;
            end loop;
        end if;

        if param_msg_error is not null then
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        else
            dbms_lob.createtemporary(json_str_output, true);
            obj_row.to_clob(json_str_output);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
      initial_value(json_str_input);
      if param_msg_error is null then
        gen_detail(json_str_output);
      end if;
      if param_msg_error is not null then
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure gen_detail(json_str_output out clob) as
      obj_row           json;
      v_codinsts        varchar2(4 char);
      v_naminst         varchar2(150 char);
      v_naminste        varchar2(150 char);
      v_naminstt        varchar2(150 char);
      v_naminst3        varchar2(150 char);
      v_naminst4        varchar2(150 char);
      v_naminst5        varchar2(150 char);
      v_addinstt        varchar2(100 char);
      v_codprovr        varchar2(4 char);
      v_coddistr        varchar2(4 char);
      v_codsubdistr     varchar2(4 char);
      v_namimgmap       varchar2(60 char);
      v_typinsts        varchar2(4 char);
      v_namcontr        varchar2(60 char);
      v_numtelec        varchar2(20 char);
      v_email           varchar2(50 char);
      v_remark          varchar2(1000 char);
      v_dteupd          date;
      v_coduser         varchar2(50 char);
      v_namimgemp       VARCHAR2(4000 CHAR);

    begin
      begin
        select codinsts,naminste,naminstt,naminst3,naminst4,naminst5,
               addinstt,codprovr,coddistr,codsubdistr,namimgmap,typinsts,
               namcontr,namcontr,numtelec,email,remark,dteupd,coduser
          into v_codinsts,v_naminste,v_naminstt,v_naminst3,v_naminst4,v_naminst5,
               v_addinstt,v_codprovr,v_coddistr,v_codsubdistr,v_namimgmap,v_typinsts,
               v_namcontr,v_namcontr,v_numtelec,v_email,v_remark,v_dteupd,v_coduser
          from tinstitu
         where codinsts = b_index_codinsts;
      exception when no_data_found then
        v_codinsts        := null;
        v_naminste        := null;
        v_naminstt        := null;
        v_naminst3        := null;
        v_naminst4        := null;
        v_naminst5        := null;
        v_addinstt        := null;
        v_codprovr        := null;
        v_coddistr        := null;
        v_codsubdistr     := null;
        v_namimgmap       := null;
        v_typinsts        := 'P';
        v_namcontr        := null;
        v_numtelec        := null;
        v_email           := null;
        v_remark          := null;
        v_dteupd          := null;
        v_coduser         := null;
      end;

      begin
          select value img
            into v_namimgemp
            FROM tusrconfig
           WHERE coduser = v_coduser
             AND codvalue = 'PROFILEIMG';
      exception when no_data_found then
        v_namimgemp       := null;
      end;

      obj_row := json();
      obj_row.put('codinsts',b_index_codinsts);
      obj_row.put('addinstt', v_addinstt);
      obj_row.put('codprovr', v_codprovr);
      obj_row.put('coddistr', v_coddistr);
      obj_row.put('codsubdistr', v_codsubdistr);
      obj_row.put('namimgmap', v_namimgmap);
      obj_row.put('typinsts', v_typinsts);
      obj_row.put('text_typinsts', get_tlistval_name('TYPINSTS', v_typinsts, global_v_lang));
      obj_row.put('namcontr', v_namcontr);
      obj_row.put('numtelec', v_numtelec);
      obj_row.put('email', v_email);
      obj_row.put('remark', v_remark);
      obj_row.put('dteupd', HCM_UTIL.convert_date_time_to_dtetime(v_dteupd, null));
      if v_coduser is not null then
        obj_row.put('coduser',v_coduser || ' - ' || get_temploy_name(GET_CODEMPID(v_coduser), global_v_lang));
      else
        obj_row.put('coduser','');
      end if;
      obj_row.put('namimgemp', v_namimgemp);
      obj_row.put('naminste', v_naminste);
      obj_row.put('naminstt', v_naminstt);
      obj_row.put('naminst3', v_naminst3);
      obj_row.put('naminst4', v_naminst4);
      obj_row.put('naminst5', v_naminst5);
      obj_row.put('naminst', get_tinstitu_name(v_codinsts,global_v_lang));
      obj_row.put('coderror', '200');

      if isInsertReport then
          insert_ttemprpt(obj_row);
      end if;

      dbms_lob.createtemporary(json_str_output, true);
      obj_row.to_clob(json_str_output);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_detail;

    procedure get_service_detail(json_str_input in clob, json_str_output out clob) as
    begin
      initial_value(json_str_input);
      if param_msg_error is null then
        gen_service_detail(json_str_output);
      end if;
      if param_msg_error is not null then
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_service_detail;

    procedure gen_service_detail(json_str_output out clob) as
        obj_row           json;
        obj_data          json;
        v_row             number := 0;
        cursor c1 is
            select codcours, codunit, amtcours, dtetrlst, qtyscore
            from tinscour
            where codinsts = b_index_codinsts;
    begin
        obj_row := json();
        for i in c1 loop
            v_row       := v_row + 1;
            obj_data    := json();
            obj_data.put('codcours', i.codcours);
            obj_data.put('codunit', i.codunit);
            obj_data.put('amtcours', i.amtcours);
            obj_data.put('dtetrlst', to_char(i.dtetrlst,'dd/mm/yyyy'));
            obj_data.put('qtyscore', to_char(i.qtyscore,'fm999,999,990.00'));
            obj_data.put('coderror', '200');
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;

        if isInsertReport then
            insert_ttemprpt(obj_row);
        end if;

        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_service_detail;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
    begin
      initial_value(json_str_input);
      if param_msg_error is null then
        save_tab1(json_str_output);
      end if;
      if param_msg_error is null then
         save_tab2(json_str_output);
      end if;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;

    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

    procedure save_tab1(json_str_output out clob) as
        v_tab1            json;
        param_json_row    json;
        v_codinsts        varchar2(4 char);
        v_naminste        varchar2(150 char);
        v_naminstt        varchar2(150 char);
        v_naminst3        varchar2(150 char);
        v_naminst4        varchar2(150 char);
        v_naminst5        varchar2(150 char);
        v_addinstt        varchar2(100 char);
        v_typinsts        varchar2(4 char);
        v_codprovr        varchar2(4 char);
        v_coddistr        varchar2(4 char);
        v_codsubdistr     varchar2(4 char);
        v_namimgmap       varchar2(60 char);
        v_namcontr        varchar2(60 char);
        v_numtelec        varchar2(20 char);
        v_email           varchar2(50 char);
        v_remark          varchar2(1000 char);
    begin
        v_tab1            := hcm_util.get_json(json_params, 'detail_institution');
        v_codinsts        := hcm_util.get_string(v_tab1,'codinsts');
        v_naminste        := hcm_util.get_string(v_tab1,'naminste');
        v_naminstt        := hcm_util.get_string(v_tab1,'naminstt');
        v_naminst3        := hcm_util.get_string(v_tab1,'naminst3');
        v_naminst4        := hcm_util.get_string(v_tab1,'naminst4');
        v_naminst5        := hcm_util.get_string(v_tab1,'naminst5');
        v_addinstt        := hcm_util.get_string(v_tab1,'addinstt');
        v_typinsts        := hcm_util.get_string(v_tab1,'typinsts');
        v_codsubdistr     := hcm_util.get_string(v_tab1,'codsubdistr');
        v_coddistr        := hcm_util.get_string(v_tab1,'coddistr');
        v_codprovr        := hcm_util.get_string(v_tab1,'codprovr');
        v_namimgmap       := hcm_util.get_string(v_tab1,'namimgmap');
        v_namcontr        := hcm_util.get_string(v_tab1,'namcontr');
        v_numtelec        := hcm_util.get_string(v_tab1,'numtelec');
        v_email           := hcm_util.get_string(v_tab1,'email');
        v_remark          := hcm_util.get_string(v_tab1,'remark');

        if v_codinsts is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;

        begin
            insert into tinstitu(codinsts,naminste,naminstt,naminst3,naminst4,naminst5,addinstt,typinsts,
                        codsubdistr,coddistr,codprovr,namimgmap,namcontr,numtelec,email,remark,dteupd,codcreate,coduser)
                        values (v_codinsts,v_naminste,v_naminstt,v_naminst3,v_naminst4,v_naminst5,v_addinstt,
                        v_typinsts,v_codsubdistr,v_coddistr,v_codprovr,v_namimgmap,v_namcontr,v_numtelec,v_email,
                        v_remark,trunc(sysdate),global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
            begin
                update  tinstitu
                set     naminste    = v_naminste,
                        naminstt    = v_naminstt,
                        naminst3    = v_naminst3,
                        naminst4    = v_naminst4,
                        naminst5    = v_naminst5,
                        addinstt    = v_addinstt,
                        typinsts    = v_typinsts,
                        codsubdistr = v_codsubdistr,
                        coddistr    = v_coddistr,
                        codprovr    = v_codprovr,
                        namimgmap   = v_namimgmap,
                        namcontr    = v_namcontr,
                        numtelec    = v_numtelec,
                        email       = v_email,
                        remark      = v_remark,
                        dteupd      = trunc(sysdate),
                        coduser     = global_v_coduser
                where   codinsts    = v_codinsts;
            exception when others then
                rollback;
            end;
        end;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_tab1;

    procedure save_tab2(json_str_output out clob) as
          v_tab1            json := hcm_util.get_json(json_params, 'detail_institution');
          v_tab2            json := hcm_util.get_json(json_params, 'table_course');
          v_tab2_rows       json := hcm_util.get_json(v_tab2, 'rows');
          param_json_row    json;
          v_codinsts        varchar2(4 char);
          v_codcours        varchar2(6 char);
          v_codunit         varchar2(4 char);
          v_amtcours        number;
          v_flg             varchar2(6 char);
    begin
        if param_msg_error is null then
            for i in 0..v_tab2_rows.count-1 loop
                param_json_row  := hcm_util.get_json(v_tab2_rows, to_char(i));
                v_codinsts      := hcm_util.get_string(v_tab1,'codinsts');
                v_flg           := hcm_util.get_string(param_json_row,'flg');
                v_codcours      := hcm_util.get_string(param_json_row,'codcours');
                v_codunit       := hcm_util.get_string(param_json_row,'codunit');
                v_amtcours      := hcm_util.get_string(param_json_row,'amtcours');
                if v_codinsts is null then
                   param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;

                if param_msg_error is null then
                    if v_flg = 'delete' then
                    begin
                        delete tinscour
                        where codinsts   = v_codinsts and codcours = v_codcours;
                        exception when others then
                            rollback;
                    end;
                    elsif v_flg = 'add' then
                    begin
                          insert into tinscour(codinsts,codcours,codunit,amtcours,dtecreate,codcreate)
                               values (v_codinsts,v_codcours,v_codunit,v_amtcours,trunc(sysdate),global_v_coduser);
                          exception when dup_val_on_index then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang);
                    end;
                    elsif v_flg = 'edit' then
                    begin
                        update    tinscour
                        set    codunit    = v_codunit,
                               amtcours   = v_amtcours,
                               dteupd     = trunc(sysdate),
                               coduser    = global_v_coduser
                        where  codinsts   = v_codinsts and codcours = v_codcours;
                        exception when others then
                            rollback;
                    end;
                    end if;
                end if;
            end loop;
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_tab2;


    procedure delete_data(json_str_input in clob, json_str_output out clob) as
          param_json_row    json;
          v_codinsts        varchar2(4 char);
          v_check_thistrnn  varchar2(4 char);
          v_check_tyrtrsch  varchar2(4 char);
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            for i in 0..json_params.count-1 loop
                param_json_row   := hcm_util.get_json(json_params, to_char(i));
                v_codinsts       := hcm_util.get_string(param_json_row,'codinsts');
            if v_codinsts is null then
                param_msg_error  := get_error_msg_php('HR2045',global_v_lang);
            end if;
            if param_msg_error is null then
                    begin
                    select codinsts into v_check_tyrtrsch
                    from tyrtrsch
                    where codinsts = v_codinsts
                      and rownum = 1;
                    exception when no_data_found then
                        v_check_thistrnn := null;
                    end;
                    begin
                    select codinsts into v_check_thistrnn
                    from thistrnn
                    where codinsts = v_codinsts
                      and rownum = 1;
                    exception when no_data_found then
                        v_check_tyrtrsch := null;
                    end;
                    if v_check_tyrtrsch is not null or v_check_thistrnn is not null then
                        param_msg_error := get_error_msg_php('HR1450',global_v_lang);
                    else
                        begin
                            delete from tinstitu
                            where codinsts = v_codinsts;
                        exception when others then
                            null;
                        end;
                    end if;
            end if;
            end loop;
        end if;
        if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2425',global_v_lang);
            commit;
        else
            rollback;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end delete_data;

    procedure initial_report(json_str in clob) is
        json_obj        json;
    begin
        json_obj            := json(json_str);
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        json_codinsts        := hcm_util.get_json(json_obj, 'p_codinsts');
    end initial_report;

    procedure gen_report(json_str_input in clob,json_str_output out clob) is
        json_output       clob;
    begin
        initial_report(json_str_input);
        isInsertReport := true;
        if param_msg_error is null then
          clear_ttemprpt;
          for i in 0..json_codinsts.count-1 loop
            b_index_codinsts := hcm_util.get_string(json_codinsts, to_char(i));
            p_codapp            := 'HRTR1DE1';
            gen_detail(json_output);
            p_codapp            := 'HRTR1DE2';
            gen_service_detail(json_output);
          end loop;
        end if;

        if param_msg_error is null then
          param_msg_error := get_error_msg_php('HR2715',global_v_lang);
          commit;
        else
          rollback;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end gen_report;

    procedure clear_ttemprpt is
    begin
        begin
          delete
            from ttemprpt
           where codempid = global_v_codempid
             and codapp   IN ('HRTR1DE1', 'HRTR1DE2');
        exception when others then
          null;
        end;
    end clear_ttemprpt;

    procedure insert_ttemprpt(obj_data in json) is
        v_numseq            number := 0;
    begin
        if p_codapp = 'HRTR1DE1' then
            begin
              select nvl(max(numseq), 0)
                into v_numseq
                from ttemprpt
               where codempid = global_v_codempid
                 and codapp   = p_codapp;
            exception when no_data_found then
              null;
            end;
            v_numseq := v_numseq + 1;
            begin
              insert
                into ttemprpt
                   (
                     codempid, codapp, numseq,
                     item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11
                   )
              values
                   (
                     global_v_codempid, p_codapp, v_numseq,
                     nvl(hcm_util.get_string(obj_data, 'codinsts'), ''),
                     nvl(hcm_util.get_string(obj_data, 'naminst'), ''),
                     nvl(hcm_util.get_string(obj_data, 'addinstt'), ''),
                     nvl(get_tcodec_name('TCODPROV', hcm_util.get_string(obj_data, 'codprovr'), global_v_lang), ''),
                     nvl(get_tcoddist_name(hcm_util.get_string(obj_data, 'coddistr'), global_v_lang), ''),
                     nvl(get_tsubdist_name(hcm_util.get_string(obj_data, 'codsubdistr'), global_v_lang), ''),
                     nvl(hcm_util.get_string(obj_data, 'text_typinsts'), ''),
                     nvl(hcm_util.get_string(obj_data, 'namcontr'), ''),
                     nvl(hcm_util.get_string(obj_data, 'numtelec'), ''),
                     nvl(hcm_util.get_string(obj_data, 'email'), ''),
                     nvl(hcm_util.get_string(obj_data, 'remark'), '')
                   );
            exception when others then
              null;
            end;
        elsif p_codapp = 'HRTR1DE2' then
            for i in 0..obj_data.count-1 loop
                begin
                  select nvl(max(numseq), 0)
                    into v_numseq
                    from ttemprpt
                   where codempid = global_v_codempid
                     and codapp   = p_codapp;
                exception when no_data_found then
                  null;
                end;
                v_numseq := v_numseq + 1;

                begin
                  insert
                    into ttemprpt
                       (
                         codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7
                       )
                  values
                       (
                         global_v_codempid, p_codapp, v_numseq,
                         b_index_codinsts,
                         nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codcours'), '')||' - '||
                         get_tcourse_name(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codcours'), global_v_lang),
                         nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codunit'), '')||' - '||
                         get_tcodunit_name(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codunit'), global_v_lang),
                         to_char(nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'amtcours'), ''),'fm999,999,990.00'),
                         replace(get_date_input(nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'dtetrlst'), '')),'//',''),
                         nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'qtyscore'), ''),
                         to_char(i+1)
                       );
                exception when others then
                  null;
                end;
            end loop;
        end if;
    end insert_ttemprpt;

END HRTR1DE;

/

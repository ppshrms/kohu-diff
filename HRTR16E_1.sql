--------------------------------------------------------
--  DDL for Package Body HRTR16E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR16E" is

    procedure initial_value(json_str in clob) is
        json_obj   json := json(json_str);
    begin
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        json_params         := hcm_util.get_json(json_obj, 'json_input_str');

        b_index_codhotel    := hcm_util.get_string(json_obj, 'codhotel');

    end initial_value;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
        obj_data          json;
        obj_row           json;
        v_stmt			  varchar2(5000 char);
        v_sql			  varchar2(5000 char);
        v_cursor		  number;
        v_dummy           integer;
        v_cond            varchar2(4000 char) := '';
        v_rcnt            number := 0;
        v_codhotel        varchar2(4 char);
        v_namhotee        varchar2(150 char);
        v_namhotet        varchar2(150 char);
        v_namhote3        varchar2(150 char);
        v_namhote4        varchar2(150 char);
        v_namhote5        varchar2(150 char);
        v_namhote         varchar2(150 char);
        v_coddistr        varchar2(4 CHAR);
        v_codprovr        varchar2(4 CHAR);
        v_qtypermin       number(5, 0);
        v_qtypermax       number(5, 0);
        v_row             number := 0;
        v_qty             number := 0;
        v_instr           number := 0;

    cursor c1 is
        select codhotel,get_thotelif_name(codhotel,global_v_lang) namehotel,
               get_tcoddist_name(coddistr,global_v_lang) namedistr,
               get_tcodec_name('TCODPROV',codprovr,global_v_lang) nameprovr,
               qtypermin,qtypermax
          from thotelif
          order by codhotel;
    begin
        initial_value(json_str_input);
        v_cond := hcm_util.get_string(hcm_util.get_json(json_params, 'syncond'), 'code');
        if v_cond is not null then
            v_cond := replace(v_cond,'THOTELIF.');
            v_cond := replace(v_cond,'THOTELSE.');
            v_cond := replace(v_cond, 'CODPROVR like', 'GET_TCODEC_NAME(''TCODPROV'',CODPROVR,' ||global_v_lang ||') like ');
            v_cond := replace(v_cond, 'CODDISTR like', 'GET_TCODDIST_NAME(CODDISTR,' ||global_v_lang ||') like ');
            v_cond := replace(v_cond, 'CODPROVR not like', 'GET_TCODEC_NAME(''TCODPROV'',CODPROVR,' ||global_v_lang ||') not like ');
            v_cond := replace(v_cond, 'CODDISTR not like', 'GET_TCODDIST_NAME(CODDISTR,' ||global_v_lang ||') not like ');
            v_stmt := 'select distinct codhotel,coddistr,codprovr,qtypermin,qtypermax from v_hrtr16 where '||v_cond;
            v_stmt := upper(v_stmt);
            v_qty  := execute_qty(v_stmt);
            v_cursor  := dbms_sql.open_cursor;
            dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
            dbms_sql.define_column(v_cursor,1,v_codhotel,4);
            dbms_sql.define_column(v_cursor,2,v_coddistr,4);
            dbms_sql.define_column(v_cursor,3,v_codprovr,4);
            dbms_sql.define_column(v_cursor,4,v_qtypermin);
            dbms_sql.define_column(v_cursor,5,v_qtypermax);

            v_dummy := dbms_sql.execute(v_cursor);
            obj_row := json();
            while (dbms_sql.fetch_rows(v_cursor) > 0) loop
                dbms_sql.column_value(v_cursor,1,v_codhotel);
                dbms_sql.column_value(v_cursor,2,v_coddistr);
                dbms_sql.column_value(v_cursor,3,v_codprovr);
                dbms_sql.column_value(v_cursor,4,v_qtypermin);
                dbms_sql.column_value(v_cursor,5,v_qtypermax);
                v_rcnt := v_rcnt + 1;
                obj_data := json();
                obj_data.put('codhotel', v_codhotel);
                obj_data.put('namhote', get_thotelif_name(v_codhotel,global_v_lang));
                obj_data.put('namedistr', get_tcoddist_name(v_coddistr,global_v_lang));
                obj_data.put('nameprovr', get_tcodec_name('TCODPROV',v_codprovr,global_v_lang));
                obj_data.put('qtypermin', v_qtypermin);
                obj_data.put('qtypermax', v_qtypermax);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end loop;
        else
            obj_row := json();
            for i in c1 loop
                v_rcnt := v_rcnt + 1;
                obj_data := json();
                obj_data.put('codhotel', i.codhotel);
                obj_data.put('namhote', i.namehotel);
                obj_data.put('namedistr', i.namedistr);
                obj_data.put('nameprovr', i.nameprovr);
                obj_data.put('qtypermin', i.qtypermin);
                obj_data.put('qtypermax', i.qtypermax);
                obj_row.put(to_char(v_rcnt-1),obj_data);
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
      v_codhotel        varchar2(4 char);
      v_namhotee        varchar2(150 char);
      v_namhotet        varchar2(150 char);
      v_namhote3        varchar2(150 char);
      v_namhote4        varchar2(150 char);
      v_namhote5        varchar2(150 char);
      v_addhotel        varchar2(150 char);
      v_codsubdistr     varchar2(4 char);
      v_coddistr        varchar2(4 char);
      v_codprovr        varchar2(4 char);
      v_namimgmap       varchar2(60 char);
      v_qtyroom         number(4, 0);
      v_qtypermin       number(5, 0);
      v_qtypermax       number(5, 0);
      v_namcontr        varchar2(60 char);
      v_numtelec        varchar2(20 char);
      v_email           varchar2(50 char);
      v_remark          varchar2(1000 char);
      v_latitude        varchar2(50 char);
      v_longitude       varchar2(50 char);
      v_dteupd          date;
      v_coduser         varchar2(50 char);
      v_namimgemp       VARCHAR2(4000 CHAR);
    begin
      begin
        select thotelif.codhotel,namhotee,namhotet,namhote3,namhote4,namhote5,
               addhotel,codsubdistr,coddistr,codprovr,namimgmap,qtyroom,
               qtypermin,qtypermax,namcontr,numtelec,email,remark,latitude,longitude,dteupd,coduser
          into v_codhotel,v_namhotee,v_namhotet,v_namhote3,v_namhote4,v_namhote5,
               v_addhotel,v_codsubdistr,v_coddistr,v_codprovr,v_namimgmap,v_qtyroom,
               v_qtypermin,v_qtypermax,v_namcontr,v_numtelec,v_email,v_remark,v_latitude,v_longitude,v_dteupd,v_coduser
          from thotelif
         where thotelif.codhotel = b_index_codhotel;
      exception when no_data_found then
        v_codhotel        := null;
        v_namhotee        := null;
        v_namhotet        := null;
        v_namhote3        := null;
        v_namhote4        := null;
        v_namhote5        := null;
        v_addhotel        := null;
        v_codsubdistr     := null;
        v_coddistr        := null;
        v_codprovr        := null;
        v_namimgmap       := null;
        v_qtyroom         := null;
        v_qtypermin       := null;
        v_qtypermax       := null;
        v_namcontr        := null;
        v_numtelec        := null;
        v_email           := null;
        v_remark          := null;
        v_latitude        := null;
        v_longitude       := null;
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

      obj_row.put('codhotel',b_index_codhotel);
      obj_row.put('addhotel', v_addhotel);
      obj_row.put('namhotee',v_namhotee);
      obj_row.put('namhotet',v_namhotet);
      obj_row.put('namhote3',v_namhote3);
      obj_row.put('namhote4',v_namhote4);
      obj_row.put('namhote5',v_namhote5);
      obj_row.put('codsubdistr', v_codsubdistr);
      obj_row.put('coddistr', v_coddistr);
      obj_row.put('codprovr', v_codprovr);
      obj_row.put('namimgmap', v_namimgmap);
      obj_row.put('qtyroom', v_qtyroom);
      obj_row.put('qtypermin', v_qtypermin);
      obj_row.put('qtypermax', v_qtypermax);
      obj_row.put('namcontr', v_namcontr);
      obj_row.put('numtelec', v_numtelec);
      obj_row.put('email', v_email);
      obj_row.put('remark', v_remark);
      obj_row.put('latitude', v_latitude);
      obj_row.put('longitude', v_longitude);
      obj_row.put('dteupd', HCM_UTIL.convert_date_time_to_dtetime(v_dteupd, null));
      if v_coduser is not null then
        obj_row.put('coduser',v_coduser || ' - ' || get_temploy_name(GET_CODEMPID(v_coduser), global_v_lang));
      else
        obj_row.put('coduser','');
      end if;

      obj_row.put('namimgemp', v_namimgemp);
      if global_v_lang = '101' then
         obj_row.put('namhote',v_namhotee);
      elsif global_v_lang = '102' then
         obj_row.put('namhote',v_namhotet);
      elsif global_v_lang = '103' then
         obj_row.put('namhote',v_namhote3);
      elsif global_v_lang = '104' then
         obj_row.put('namhote',v_namhote4);
      elsif global_v_lang = '105' then
         obj_row.put('namhote',v_namhote5);
      end if;
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
            select codserv, codunit, amtserv
            from thotelse
            where codhotel = b_index_codhotel;
    begin
        obj_row := json();
        for i in c1 loop
            v_row       := v_row + 1;
            obj_data    := json();
            obj_data.put('codserv', i.codserv);
            obj_data.put('codunit', i.codunit);
            obj_data.put('amtserv', i.amtserv);
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

    procedure delete_data(json_str_input in clob, json_str_output out clob) as
            param_json_row  json;
            v_chk_thistrnn    varchar2(4 char);
            v_chk_tyrtrsch    varchar2(4 char);
    begin
        initial_value(json_str_input);

        if param_msg_error is null then
            for i in 0..json_params.count-1 loop
            param_json_row  := hcm_util.get_json(json_params, to_char(i));
            b_index_codhotel    := hcm_util.get_string(param_json_row,'codhotel');
            if b_index_codhotel is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;
            if param_msg_error is null then
                    begin
                    select codhotel into v_chk_tyrtrsch
                    from tyrtrsch
                    where codhotel = b_index_codhotel
                    and rownum = 1;
                    exception when no_data_found then
                        v_chk_tyrtrsch := null;
                    end;
                    begin
                    select codhotel into v_chk_thistrnn
                    from thistrnn
                    where codhotel = b_index_codhotel
                    and rownum = 1;
                    exception when no_data_found then
                        v_chk_thistrnn := null;
                    end;
                    if v_chk_thistrnn is not null or v_chk_tyrtrsch is not null then
                        param_msg_error := get_error_msg_php('HR1450',global_v_lang);
                    else
                        begin
                            delete from thotelif
                            where codhotel = b_index_codhotel;
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
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);

    end delete_data;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
      v_tab1            json := hcm_util.get_json(json_params, 'detail_place');

    begin
      initial_value(json_str_input);
      if param_msg_error is null then
        save_tab1(json_str_output);
      end if;
      if param_msg_error is null then
         save_tab2(json_str_output);
      end if;
      if param_msg_error is null then
         param_msg_error := get_error_msg_php('HR2401', global_v_lang);
         json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        rollback;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;


    procedure save_tab1(json_str_output out clob) as
        v_tab1            json;
        param_json_row    json;
        v_codhotel        varchar2(4 char);
        v_namhotee        varchar2(150 char);
        v_namhotet        varchar2(150 char);
        v_namhote3        varchar2(150 char);
        v_namhote4        varchar2(150 char);
        v_namhote5        varchar2(150 char);
        v_addhotel        varchar2(150 char);
        v_codsubdistr     varchar2(4 char);
        v_coddistr        varchar2(4 char);
        v_codprovr        varchar2(4 char);
        v_namimgmap       varchar2(60 char);
        v_qtyroom         number(4, 0);
        v_qtypermin       number(5, 0);
        v_qtypermax       number(5, 0);
        v_namcontr        varchar2(60 char);
        v_numtelec        varchar2(20 char);
        v_email           varchar2(50 char);
        v_remark          varchar2(1000 char);
        v_latitude        varchar2(50 char);
        v_longitude       varchar2(50 char);
    begin
        v_tab1              := hcm_util.get_json(json_params, 'detail_place');
        b_index_codhotel    := hcm_util.get_string(v_tab1,'codhotel');
        v_codhotel          := hcm_util.get_string(v_tab1,'codhotel');
        v_namhotee          := hcm_util.get_string(v_tab1,'namhotee');
        v_namhotet          := hcm_util.get_string(v_tab1,'namhotet');
        v_namhote3          := hcm_util.get_string(v_tab1,'namhote3');
        v_namhote4          := hcm_util.get_string(v_tab1,'namhote4');
        v_namhote5          := hcm_util.get_string(v_tab1,'namhote5');
        v_addhotel          := hcm_util.get_string(v_tab1,'addhotel');
        v_codsubdistr       := hcm_util.get_string(v_tab1,'codsubdistr');
        v_coddistr          := hcm_util.get_string(v_tab1,'coddistr');
        v_codprovr          := hcm_util.get_string(v_tab1,'codprovr');
        v_namimgmap         := hcm_util.get_string(v_tab1,'namimgmap');
        v_qtyroom           := hcm_util.get_string(v_tab1,'qtyroom');
        v_qtypermin         := hcm_util.get_string(v_tab1,'qtypermin');
        v_qtypermax         := hcm_util.get_string(v_tab1,'qtypermax');
        v_namcontr          := hcm_util.get_string(v_tab1,'namcontr');
        v_numtelec          := hcm_util.get_string(v_tab1,'numtelec');
        v_email             := hcm_util.get_string(v_tab1,'email');
        v_remark            := hcm_util.get_string(v_tab1,'remark');
        v_latitude          := hcm_util.get_string(v_tab1,'latitude');
        v_longitude         := hcm_util.get_string(v_tab1,'longitude');

        if v_codhotel is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;
        if global_v_lang = '101' then
                if v_namhotee is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;
        elsif global_v_lang = '102' then
                if v_namhotet is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;
        elsif global_v_lang = '103' then
                if v_namhote3 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;
        elsif global_v_lang = '104' then
                if v_namhote4 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;
        elsif global_v_lang = '105' then
                if v_namhote5 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;
        end if;
        if v_numtelec is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;
        if v_namcontr is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;
        if v_codsubdistr is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;
        if v_coddistr is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;
        if v_codprovr is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;
        if v_qtypermin is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;
        if v_qtypermax is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;
        if (v_latitude is null and v_longitude is not null) or (v_latitude is not null and v_longitude is null)  then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;

        begin
            insert into thotelif(codhotel,namhotee,namhotet,namhote3,namhote4,namhote5,addhotel,codsubdistr,coddistr,codprovr,
                     namimgmap,qtyroom,qtypermin,qtypermax,namcontr,numtelec,email,remark,latitude,longitude,dteupd,codcreate,coduser)
            values  (v_codhotel,v_namhotee,v_namhotet,v_namhote3,v_namhote4,v_namhote5,v_addhotel,v_codsubdistr,v_coddistr,v_codprovr,
                     v_namimgmap,v_qtyroom,v_qtypermin,v_qtypermax,v_namcontr,v_numtelec,v_email,v_remark,v_latitude,v_longitude,trunc(sysdate),global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
            begin
                update  thotelif
                set     namhotee      = v_namhotee,
                        namhotet      = v_namhotet,
                        namhote3      = v_namhote3,
                        namhote4      = v_namhote4,
                        namhote5      = v_namhote5,
                        addhotel      = v_addhotel,
                        codsubdistr   = v_codsubdistr,
                        coddistr      = v_coddistr,
                        codprovr      = v_codprovr,
                        namimgmap     = v_namimgmap,
                        qtyroom       = v_qtyroom,
                        qtypermin     = v_qtypermin,
                        qtypermax     = v_qtypermax,
                        namcontr      = v_namcontr,
                        numtelec      = v_numtelec,
                        email         = v_email,
                        remark        = v_remark,
                        latitude      = v_latitude,
                        longitude      = v_longitude,
                        dteupd        = trunc(sysdate),
                        coduser       = global_v_coduser
                where   codhotel      = v_codhotel;
            exception when others then
                rollback;
            end;
        end;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_tab1;

    procedure save_tab2(json_str_output out clob) as

          v_tab2            json := hcm_util.get_json(json_params, 'table_service');
          v_tab2_rows       json := hcm_util.get_json(v_tab2, 'rows');
          param_json_row    json;
          v_flg             varchar2(6 char);
          v_codserv         varchar2(4 char);
          v_codunit         varchar2(4 char);
          v_amtserv         number;
          v_flgadd          varchar2(5 char);
          v_flgdelete       varchar2(5 char);
          v_flgedit         varchar2(5 char);
    begin
        if param_msg_error is null then
            for i in 0..v_tab2_rows.count-1 loop
                param_json_row  := hcm_util.get_json(v_tab2_rows, to_char(i));
                v_flg           := hcm_util.get_string(param_json_row,'flg');
                v_flgadd        := hcm_util.get_string(param_json_row,'flgAdd');
                v_flgdelete     := hcm_util.get_string(param_json_row,'flgDelete');
                v_flgedit       := hcm_util.get_string(param_json_row,'flgEdit');
                v_codserv       := hcm_util.get_string(param_json_row,'codserv');
                v_codunit       := hcm_util.get_string(param_json_row,'codunit');
                v_amtserv       := hcm_util.get_string(param_json_row,'amtserv');
            if b_index_codhotel is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;
            if param_msg_error is null then
                if v_flg = 'add' then
                    begin
                        insert into thotelse(codhotel,codserv,codunit,amtserv,dtecreate,codcreate)
                        values (b_index_codhotel,v_codserv,v_codunit,v_amtserv,trunc(sysdate),global_v_coduser);
                    exception when dup_val_on_index then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang);
                            rollback;
                        end;
                    elsif v_flg = 'edit' then
                         begin
                            update  thotelse
                            set
                                    codunit   = v_codunit,
                                    amtserv   = v_amtserv,
                                    dteupd    = trunc(sysdate),
                                    coduser   = global_v_coduser
                            where   codhotel = b_index_codhotel and codserv = v_codserv;
                        exception when others then
                            rollback;
                        end;
                    elsif v_flg = 'delete' then
                        begin
                            delete thotelse
                            where codhotel = b_index_codhotel and codserv = v_codserv;
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

    procedure initial_report(json_str in clob) is
        json_obj        json;
    begin
        json_obj            := json(json_str);
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        json_codhotel       := hcm_util.get_json(json_obj, 'p_codhotel');

    end initial_report;

    procedure gen_report(json_str_input in clob,json_str_output out clob) is
        json_output       clob;
    begin
        initial_report(json_str_input);
        isInsertReport := true;
        if param_msg_error is null then
          clear_ttemprpt;
          for i in 0..json_codhotel.count-1 loop
            b_index_codhotel := hcm_util.get_string(json_codhotel, to_char(i));
            p_codapp            := 'HRTR16E1';
            gen_detail(json_output);
            p_codapp            := 'HRTR16E2';
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
             and codapp IN ('HRTR16E1', 'HRTR16E2');
        exception when others then
          null;
        end;
    end clear_ttemprpt;

    procedure insert_ttemprpt(obj_data in json) is
        v_numseq            number := 0;
    begin
        if p_codapp = 'HRTR16E1' then
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
                     item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12, item13, item14, item15
                   )
              values
                   (
                     global_v_codempid, p_codapp, v_numseq,
                     nvl(hcm_util.get_string(obj_data, 'codhotel'), ''), nvl(hcm_util.get_string(obj_data, 'namhote'), ''), nvl(hcm_util.get_string(obj_data, 'addhotel'), ''),
                     nvl(get_tcodec_name('TCODPROV', hcm_util.get_string(obj_data, 'codprovr'), global_v_lang), ''), nvl(get_tcoddist_name(hcm_util.get_string(obj_data, 'coddistr'), global_v_lang), ''),
                     nvl(get_tsubdist_name(hcm_util.get_string(obj_data, 'codsubdistr'), global_v_lang), ''), nvl(hcm_util.get_string(obj_data, 'latitude'), ''), nvl(hcm_util.get_string(obj_data, 'longitude'), ''),
                     nvl(hcm_util.get_string(obj_data, 'qtyroom'), ''), nvl(hcm_util.get_string(obj_data, 'qtypermin'), ''),
                     nvl(hcm_util.get_string(obj_data, 'qtypermax'), ''), nvl(hcm_util.get_string(obj_data, 'namcontr'), ''),
                     nvl(hcm_util.get_string(obj_data, 'numtelec'), ''), nvl(hcm_util.get_string(obj_data, 'email'), ''),
                     nvl(hcm_util.get_string(obj_data, 'remark'), '')
                   );
            exception when others then
              null;
            end;
        elsif p_codapp = 'HRTR16E2' then
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
                         codempid, codapp, numseq, item1, item2, item3, item4, item5
                       )
                  values
                       (
                         global_v_codempid, p_codapp, v_numseq,
                         b_index_codhotel,
                         nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codserv'), '')||' - '||get_tcodec_name('TCODSERV',nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codserv'), ''), global_v_lang),
                         nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codunit'), '')||' - '||get_tcodunit_name(nvl(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'codunit'), ''),global_v_lang),
                         nvl(to_char(hcm_util.get_string(hcm_util.get_json(obj_data, to_char(i)), 'amtserv'),'999,999,999,999.99'), ''),
                         to_char(i+1)
                       );
                exception when others then
                  null;
                end;
            end loop;
        end if;
    end insert_ttemprpt;

END HRTR16E;


/

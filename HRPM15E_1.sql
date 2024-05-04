--------------------------------------------------------
--  DDL for Package Body HRPM15E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM15E" is
-- last update: 04/01/2018 12:23

  procedure initial_value (json_str in clob) is
    json_obj    json_object_t;
  begin
    v_chken               := hcm_secur.get_v_chken;
    json_obj              := json_object_t(json_str);
    --global
    global_v_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd      := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang         := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning     := hcm_util.get_string_t(json_obj,'p_lrunning');
    -- index
    p_coduser             := hcm_util.get_string_t(json_obj,'p_coduser');
    p_codempid            := hcm_util.get_string_t(json_obj,'p_codempid');
    p_codcompy            := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
    p_lang                := hcm_util.get_string_t(json_obj,'p_lang');

    -- search
    p_groupid             := hcm_util.get_string_t(json_obj,'p_groupid');

  end initial_value;
  procedure gen_index (json_str_output out clob) as
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_data_groupname  json_object_t;
    obj_row_groupname   json_object_t;
    obj_data_syncond    json_object_t;
    obj_row_syncond     json_object_t;
    obj_row_1           json_object_t;
    obj_data_1          json_object_t;
    v_groupid           tsempidh.groupid%type;
    count_loop          number := 0;
    count_loop_format   number := 0;
    v_lastempid                varchar2(100);
    cursor c_tsempidh is
      select  groupid,    namempidt,    namempide,  namempid3,
              namempid4,  namempid5,    syncond,    statement,
              decode(global_v_lang,'101',namempide
                                  ,'102',namempidt
                                  ,'103',namempid3
                                  ,'104',namempid4
                                  ,'105',namempid5) as namempid
      from    tsempidh hh
--      where   exists (select  1
--                      from    tsempidd dd
--                      where   hh.groupid  = dd.groupid)
      order by groupid;

    cursor c_tsempidd is
      select  numseq, typgrpid, typeval
      from    tsempidd
      where   groupid     = v_groupid
      order by numseq;

    cursor c_trunempid is
      select groupid, dteyear, dtemonth, running
--             decode(dteyear,9999,'',dteyear) as dteyear,
--             decode(dtemonth,99,'',dtemonth) as dtemonth,
        from trunempid t1
       where lpad(dteyear,4,'0')||lpad(dtemonth,2,'0')||lpad(running,8,'0') = (select  max(lpad(dteyear,4,'0')||lpad(dtemonth,2,'0')||lpad(running,8,'0'))
                                                                               from    trunempid t2
                                                                               where   t1.groupid    = t2.groupid)
      and     groupid   = v_groupid
      order by groupid;
  begin
    obj_row   := json_object_t();
    for r_tsempidh in c_tsempidh loop
      count_loop          := count_loop + 1;
      count_loop_format   := 0;
--      obj_data_syncond    := json_object_t();
--      obj_data_groupname  := json_object_t();
      obj_row_1           := json_object_t();
      obj_data            := json_object_t();
      v_groupid           := r_tsempidh.groupid;

--      obj_data_syncond.put('code', r_tsempidh.syncond);
--      obj_data_syncond.put('description', get_logical_name('HRPM15E',r_tsempidh.syncond,global_v_lang));
--      obj_data_syncond.put('statement', r_tsempidh.statement);
--      obj_data_groupname.put('desc_codshifte', r_tsempidh.namempide);
--      obj_data_groupname.put('desc_codshiftt', r_tsempidh.namempidt);
--      obj_data_groupname.put('desc_codshift3', r_tsempidh.namempid3);
--      obj_data_groupname.put('desc_codshift4', r_tsempidh.namempid4);
--      obj_data_groupname.put('desc_codshift5', r_tsempidh.namempid5);
--      for r_tsempidd in c_tsempidd loop
--        obj_data_1        := json_object_t();
--        count_loop_format := count_loop_format + 1;
--        obj_data_1.put('numseq', r_tsempidd.numseq);
--        obj_data_1.put('typgrpid', r_tsempidd.typgrpid);
--        obj_data_1.put('value', r_tsempidd.typeval);
--        obj_data_1.put('typeval', length(to_char(r_tsempidd.typeval)));
--        obj_row_1.put(to_char(count_loop_format - 1), obj_data_1);
--      end loop;
      v_lastempid  := '';
      for r_runemp in c_trunempid loop
        for r_tsempidd in c_tsempidd loop
          if r_runemp.dteyear is not null then
            if r_tsempidd.typgrpid in ('CE','BE','AD') then --type group id ( CE = year ,  MT = month  , ST = constant  RN = Running )
              if r_runemp.dteyear = 99 then--User37 #2493 Final Test Phase 1 V11 01/02/2021 9999 then
                v_lastempid := v_lastempid||null;
              else
                --v_lastempid := v_lastempid||to_char(substr(r_runemp.dteyear+543,3,2));--nut v_lastempid := v_lastempid||to_char(r_runemp.dteyear);--user37 #5431 Final Test Phase 1 V11 03/03/2021 v_lastempid := v_lastempid||to_char(substr(r_runemp.dteyear,3,2));
                if r_tsempidd.typgrpid in ('CE','BE') then -- 2565
                  v_lastempid := v_lastempid||to_char(substr(r_runemp.dteyear+543,3,2));
                else -- 2022
                  v_lastempid := v_lastempid||to_char(substr(r_runemp.dteyear,3,2));
                end if;
              end if;
            elsif r_tsempidd.typgrpid = 'MT' then
              if r_runemp.dtemonth = 99 then
                v_lastempid := v_lastempid||null;
              else
                v_lastempid := v_lastempid||lpad(r_runemp.dtemonth,2,'0');
              end if;
            elsif r_tsempidd.typgrpid = 'RN' then
              v_lastempid := v_lastempid||lpad(r_runemp.running,length(r_tsempidd.typeval),'0');
            elsif r_tsempidd.typgrpid = 'ST' then
              v_lastempid := v_lastempid||r_tsempidd.typeval;
            end if;
          end if;
        end loop;
      end loop;
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', count_loop);
      obj_data.put('groupid', r_tsempidh.groupid);
      obj_data.put('namempid', r_tsempidh.namempid);
      obj_data.put('lastempid', v_lastempid);
--      obj_data.put('syncond', obj_data_syncond);
--      obj_data.put('typgrpids', obj_row_1);
--      obj_data.put('groupname', obj_data_groupname);
      obj_row.put(to_char(count_loop - 1), obj_data);
    end loop;

--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_index (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_index(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure gen_search (json_str_output out clob) as
    obj_data            json_object_t;
    obj_data_syncond    json_object_t;

    obj_row             json_object_t;
    obj_data_groupname  json_object_t;
    obj_row_groupname   json_object_t;
    obj_row_syncond     json_object_t;
    obj_row_1           json_object_t;
    obj_data_1          json_object_t;
    count_loop          number := 0;
    count_loop_format   number := 0;
    count_st            number := 0;
    v_lastempid         varchar2(100);
    v_groupid           tsempidh.groupid%type;
    v_namempid          tsempidh.namempidt%type;
    v_namempide         tsempidh.namempide%type;
    v_namempidt         tsempidh.namempidt%type;
    v_namempid3         tsempidh.namempid3%type;
    v_namempid4         tsempidh.namempid4%type;
    v_namempid5         tsempidh.namempid5%type;
    v_syncond           tsempidh.syncond%type;
    v_statement         tsempidh.statement%type;
    v_addyear           number;

    cursor c_tsempidd is
      select  numseq, typgrpid, typeval
      from    tsempidd
      where   groupid     = v_groupid
      order by numseq;

    cursor c_trunempid is
      select  groupid,
--              decode(dteyear,9999,'',dteyear) as dteyear,
--              decode(dtemonth,99,'',dtemonth) as dtemonth,
              dteyear,
              dtemonth,
              running
      from    trunempid t1
      where   lpad(dteyear,4,'0')||lpad(dtemonth,2,'0')||lpad(running,6,'0') = (select  max(lpad(dteyear,4,'0')||lpad(dtemonth,2,'0')||lpad(running,6,'0'))
                                                                                from    trunempid t2
                                                                                where   t1.groupid    = t2.groupid)
      and     groupid   = v_groupid
      order by groupid;
  begin
    begin
      select  groupid, namempide,namempidt,namempid3,namempid4,namempid5, get_logical_name('HRPM15E',syncond,global_v_lang),statement,
              decode(global_v_lang,'101',namempide
                                  ,'102',namempidt
                                  ,'103',namempid3
                                  ,'104',namempid4
                                  ,'105',namempid5) as namempid
      into v_groupid, v_namempide, v_namempidt, v_namempid3, v_namempid4, v_namempid5, v_syncond, v_statement, v_namempid
      from    tsempidh hh
--      where   exists (select  1
--                      from    tsempidd dd
--                      where   hh.groupid  = dd.groupid)
      where     groupid   = p_groupid
      order by groupid;
    exception when no_data_found then
      v_groupid := ''; v_namempide := ''; v_namempidt := ''; v_namempid3 := ''; v_namempid4 := ''; v_namempid5 := '';
      v_syncond := ''; v_statement := '[]'; v_namempid := '';
    end;
    obj_data          := json_object_t();
    obj_data_syncond  := json_object_t();
    obj_row_1         := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('rcnt', count_loop);
    obj_data.put('groupid', p_groupid);
    obj_data.put('namempid', v_namempid);
    obj_data.put('namempide', v_namempide);
    obj_data.put('namempidt', v_namempidt);
    obj_data.put('namempid3', v_namempid3);
    obj_data.put('namempid4', v_namempid4);
    obj_data.put('namempid5', v_namempid5);

    obj_data_syncond.put('code', v_syncond);
    obj_data_syncond.put('description', v_syncond);
    obj_data_syncond.put('statement', v_statement);

    obj_data.put('syncond', obj_data_syncond);
          v_lastempid  := '';
      for r_runemp in c_trunempid loop
        for r_tsempidd in c_tsempidd loop
          obj_data_1        := json_object_t();
          count_loop_format := count_loop_format + 1;
          obj_data_1.put('numseq', r_tsempidd.numseq);
          if r_runemp.dteyear is not null then
            if r_tsempidd.typgrpid in ('CE','BE','AD') then
              if r_runemp.dteyear = 99 then--User37 #2493 Final Test Phase 1 V11 01/02/2021 9999 then
                v_lastempid := v_lastempid||null;
              else
                --v_lastempid := v_lastempid||to_char(substr(r_runemp.dteyear+543,3,2));
                if r_tsempidd.typgrpid in ('CE','BE') then -- 2565
                  v_addyear := 543;
                else -- 2022
                  v_addyear := 0;
                end if;
                v_lastempid := v_lastempid||to_char(substr(r_runemp.dteyear + v_addyear,3,2));
              end if;
              obj_data_1.put('typgrpid', r_tsempidd.typgrpid);
              --<<User37 #2493 Final Test Phase 1 V11 01/02/2021
              --obj_data_1.put('value', to_char(sysdate,'yy'));
              --obj_data_1.put('value', to_char(substr(to_number(to_char(sysdate,'yyyy'))+543,-2,2)));--nut obj_data_1.put('value', to_char(sysdate,'yyyy'));
              obj_data_1.put('value', to_char(substr(to_number(to_char(sysdate,'yyyy'))+v_addyear,-2,2)));--nut obj_data_1.put('value', to_char(sysdate,'yyyy'));
              -->>User37 #2493 Final Test Phase 1 V11 01/02/2021
              --obj_data_1.put('value_last', to_char(substr((to_number(r_runemp.dteyear)+543),3,2)));--nut obj_data_1.put('value_last', to_char(substr(r_runemp.dteyear,3,2)));
              obj_data_1.put('value_last', to_char(substr((to_number(r_runemp.dteyear)+v_addyear),3,2)));--nut obj_data_1.put('value_last', to_char(substr(r_runemp.dteyear,3,2)));
              obj_data_1.put('typeval', '2');
            elsif r_tsempidd.typgrpid = 'MT' then
              if r_runemp.dtemonth = 99 then
                v_lastempid := v_lastempid||null;
              else
                v_lastempid := v_lastempid||lpad(r_runemp.dtemonth,2,'0');
              end if;
              obj_data_1.put('typgrpid', r_tsempidd.typgrpid);
              obj_data_1.put('value', to_char(sysdate,'mm'));
              obj_data_1.put('value_last', lpad(r_runemp.dtemonth,2,'0'));
              obj_data_1.put('typeval', '2');
            elsif r_tsempidd.typgrpid = 'RN' then
              v_lastempid := v_lastempid||lpad(r_runemp.running,length(r_tsempidd.typeval),'0');
              obj_data_1.put('typgrpid', r_tsempidd.typgrpid);
              if (to_char(sysdate,'mm') = r_runemp.dtemonth and to_char(sysdate,'yy') = to_char(substr(r_runemp.dteyear,3,2)))
                or (to_char(sysdate,'mm') = r_runemp.dtemonth and r_runemp.dteyear = 99)--User37 #2493 Final Test Phase 1 V11 01/02/2021 9999)
                or (to_char(sysdate,'yyyy') = r_runemp.dteyear and r_runemp.dtemonth = 99) then
                obj_data_1.put('value', lpad(r_runemp.running,length(r_tsempidd.typeval),'0'));
              else
                obj_data_1.put('value', r_tsempidd.typeval);
              end if;
              obj_data_1.put('value_last', lpad(r_runemp.running,length(r_tsempidd.typeval),'0'));
              obj_data_1.put('typeval', length(to_char(r_tsempidd.typeval)));
            elsif r_tsempidd.typgrpid = 'ST' then
              count_st    := count_st + 1;
              v_lastempid := v_lastempid||r_tsempidd.typeval;
              if count_st > 1 then
                obj_data_1.put('typgrpid', r_tsempidd.typgrpid||count_st);
              else
                obj_data_1.put('typgrpid', r_tsempidd.typgrpid);
              end if;
              obj_data_1.put('value', r_tsempidd.typeval);
              obj_data_1.put('value_last', r_tsempidd.typeval);
              obj_data_1.put('typeval', length(to_char(r_tsempidd.typeval)));
            end if;
          end if;
          obj_row_1.put(to_char(count_loop_format - 1), obj_data_1);
        end loop;
      end loop;

      obj_data.put('lastempid', v_lastempid);
      obj_data.put('typgrpids', obj_row_1);

      json_str_output := obj_data.to_clob;
--    obj_row   := json();
--    for r_tsempidh in c_tsempidh loop
--      count_loop          := count_loop + 1;
--      count_loop_format   := 0;
--      obj_data_syncond    := json();
--      obj_data_groupname  := json();
--      obj_row_1           := json();
--      obj_data            := json();
--      v_groupid           := r_tsempidh.groupid;
--
--      obj_data.put('coderror', '200');
--      obj_data.put('rcnt', count_loop);
--      obj_data.put('groupid', r_tsempidh.groupid);
--      obj_data.put('namepid', r_tsempidh.namempid);
--      obj_data.put('namepide', r_tsempidh.namempide);
--      obj_data.put('namepidt', r_tsempidh.namempidt);
--      obj_data.put('namepid3', r_tsempidh.namempid3);
--      obj_data.put('namepid4', r_tsempidh.namempid4);
--      obj_data.put('namepid5', r_tsempidh.namempid5);
--
--      obj_data_syncond.put('code', r_tsempidh.syncond);
--      obj_data_syncond.put('description', get_logical_name('HRPM15E',r_tsempidh.syncond,global_v_lang));
--      obj_data_syncond.put('statement', r_tsempidh.statement);
--      obj_data_groupname.put('desc_codshifte', r_tsempidh.namempide);
--      obj_data_groupname.put('desc_codshiftt', r_tsempidh.namempidt);
--      obj_data_groupname.put('desc_codshift3', r_tsempidh.namempid3);
--      obj_data_groupname.put('desc_codshift4', r_tsempidh.namempid4);
--      obj_data_groupname.put('desc_codshift5', r_tsempidh.namempid5);
--      /* for r_tsempidd in c_tsempidd loop
--        obj_data_1        := json();
--        count_loop_format := count_loop_format + 1;
--        obj_data_1.put('numseq', r_tsempidd.numseq);
--        obj_data_1.put('typgrpid', r_tsempidd.typgrpid);
--        obj_data_1.put('value', r_tsempidd.typeval);
--        obj_data_1.put('typeval', length(to_char(r_tsempidd.typeval)));
--        obj_row_1.put(to_char(count_loop_format - 1), obj_data_1);
--      end loop; */

--
--      obj_data.put('groupname', obj_data_groupname);
--      obj_row.put(to_char(count_loop - 1), obj_data);
--    end loop;

--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_search (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_search(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure delete_data(json_str_input in clob, json_str_output out clob) as
    param_json            json_object_t;
    param_json_row        json_object_t;
    json_row_delete       json_object_t;
    str_delete_groupid    varchar2(100 char);
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    if param_msg_error is null then
       for i in 0..param_json.get_size-1 loop
        json_row_delete := json_object_t();
        json_row_delete := hcm_util.get_json_t(param_json,to_char(i));
        str_delete_groupid := hcm_util.get_string_t(json_row_delete, 'groupid');
        begin
          delete from TSEMPIDH where GROUPID = str_delete_groupid;
          delete from TRUNEMPID where GROUPID = str_delete_groupid;
          delete from TSEMPIDD where GROUPID = str_delete_groupid;
        end;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        json_str_output := param_msg_error;
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  procedure save_data (json_str_input in clob, json_str_output out clob) as
    json_param_obj          json_object_t;
    json_input_obj          json_object_t;
    json_row                json_object_t;
    json_row_delete         json_object_t;
    json_obj                json_object_t;
    obj_data                json_object_t;
    obj_item                json_object_t;
    obj_typgrpids           json_object_t;
    obj_groupnameemp        json_object_t;
    --
    obj_syncond             json_object_t;
    v_rcntyear              varchar2(100 char);
    v_year                  varchar2(100 char);
    v_month                 varchar2(100 char);
    v_running               varchar2(100 char);
    v_nowgrpid              trunempid.groupid%type;
    v_nowdteyear            trunempid.dteyear%type;
    v_nowdtemonth           trunempid.dtemonth%type;
    v_nowrunning            trunempid.running%type;

    v_codempid              temploy1.codempid%type;
    str_groupid             tsempidh.groupid%type;
    str_namempid            tsempidh.namempide%type;
    str_namempide           tsempidh.namempide%type;
    str_namempidt           tsempidh.namempidt%type;
    str_namempid3           tsempidh.namempid3%type;
    str_namempid4           tsempidh.namempid4%type;
    str_namempid5           tsempidh.namempid5%type;
    str_statement           tsempidh.statement%type;
    str_syncond             tsempidh.syncond%type;
    v_checkCE               varchar2(100 char);
    v_checkMT               varchar2(100 char);

    str_delete_groupid      varchar2(100 char);
    str_lastfullid          varchar2(500 char);
    str_rownumber           varchar2(500 char);
    str_falg_insert         varchar2(500 char);
    str_flag                varchar2(500 char);
    str_numseq              varchar2(100 char);
    str_name                varchar2(100 char);
    str_desc                varchar2(100 char);
    str_disabled            varchar2(100 char);
    str_typgrpid            varchar2(100 char);
    str_type                varchar2(100 char);
    str_typeval             varchar2(100 char);
    str_value               varchar2(100 char);
    str_digit               varchar2(100 char);

    str_description         varchar2(100 char);
    str_lastid              varchar2(100 char);
    str_lastempid           varchar2(100 char);
    flag_monthANDyear       number := 0;
    str_msg_code            varchar2(10 char);
    flag_msg_code           varchar2(10 char);
    str_dtecreate           date;
    str_CODCREATE           varchar2(10 char);
    count_groupid           number := 0;
    count_numseq            number := 0;
    count_runid             number := 0;
    str_falg_del            varchar2(5 char);
    str_codempid            varchar2(10 char);
    v_sync_loop             tsempidh.syncond%type;
    v_sync_save             tsempidh.syncond%type;
    v_chk                   varchar2(10 char);--nut
    cursor c_other_syncond is
      select syncond
        from tsempidh
       where groupid <> str_groupid;
  begin
    initial_value(json_str_input);

    json_obj            := json_object_t(json_str_input);
    str_codempid        := hcm_util.get_string_t(json_obj,'p_codempid'); -- ต้องเปลี่ยน

    obj_item            := hcm_util.get_json_t(json_obj,'params');
    str_groupid         := hcm_util.get_string_t(obj_item, 'groupid');
    str_namempide       := hcm_util.get_string_t(obj_item, 'namempide');
    str_namempidt       := hcm_util.get_string_t(obj_item, 'namempidt');
    str_namempid3       := hcm_util.get_string_t(obj_item, 'namempid3');
    str_namempid4       := hcm_util.get_string_t(obj_item, 'namempid4');
    str_namempid5       := hcm_util.get_string_t(obj_item, 'namempid5');
    str_lastid          := hcm_util.get_string_t(obj_item, 'lastid');
    str_lastempid       := hcm_util.get_string_t(obj_item, 'lastempid');

    obj_syncond         := hcm_util.get_json_t(obj_item,'syncond');
    str_statement       := hcm_util.get_string_t(obj_syncond, 'statement');
    str_syncond         := hcm_util.get_string_t(obj_syncond, 'code');

    obj_typgrpids       := hcm_util.get_json_t(obj_item,'typgrpids');
    if str_groupid is not null then

      select listagg(tt) within group(order by tt)
      into   v_sync_save
      from(
        select regexp_substr(str_syncond,'[^ ]+',1,level) as tt
        from dual
        connect by regexp_substr(str_syncond,'[^ ]+',1,level) is not null
        order by 1
      );

      for i in c_other_syncond loop
        select listagg(tt) within group(order by tt)
        into   v_sync_loop
        from(
          select regexp_substr(i.syncond,'[^ ]+',1,level) as tt
          from dual
          connect by regexp_substr(i.syncond,'[^ ]+',1,level) is not null
          order by 1
        );
        if v_sync_save = v_sync_loop then
          param_msg_error := get_error_msg_php('PM0111',global_v_lang);
          exit;
        end if;
      end loop;

      if param_msg_error is not null then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
      end if;

      if length(str_lastid) > 10 then
        param_msg_error := get_error_msg_php('PM0070',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
      end if;

      --<<User37 #2492 Final Test Phase 1 V11 05/02/2021
      begin
        select 'X'
          into v_chk
          from tsempidh
         where groupid <> str_groupid
           and syncond = str_syncond;
           param_msg_error := get_error_msg_php('PM0111',global_v_lang);
           json_str_output := get_response_message(null,param_msg_error,global_v_lang);
           return;
      exception when no_data_found then
        null;
      end;
      -->>User37 #2492 Final Test Phase 1 V11 05/02/2021

      begin
        select count(groupid) into count_groupid
          from TSEMPIDH
         where GROUPID = str_groupid;
      exception when no_data_found then
        count_groupid := 0;
      end;

      begin
        select count(groupid) into count_runid
          from trunempid
         where groupid = str_groupid;
      exception when no_data_found then
        count_runid := 0;
      end;
      str_msg_code := '';
      if count_groupid = 0 then
        begin
          insert into tsempidh
                      (groupid, namempide, namempidt, namempid3, namempid4, namempid5,
                       syncond, statement, codcreate)
          values (str_groupid,str_namempide,str_namempidt,str_namempid3,str_namempid4,str_namempid5,
                       str_syncond, str_statement, global_v_coduser);
        exception when dup_val_on_index then
          null;
        end;
        begin
          insert into trunempid
                        (groupid, dteyear, dtemonth,running, codcreate,coduser,dtecreate,dteupd)
                 values (str_groupid, 99/*User37 #2493 Final Test Phase 1 V11 01/02/2021 9999*/, 99, 0, global_v_coduser,global_v_coduser,sysdate,sysdate);
        exception when dup_val_on_index then
          null;
        end;
        -- check type group id
        for i in 0..obj_typgrpids.get_size-1 loop
          json_row    := json_object_t();
          json_row    := hcm_util.get_json_t(obj_typgrpids,to_char(i));
          str_typgrpid    := hcm_util.get_string_t(json_row, 'typgrpid');

          if str_typgrpid in ('CE','BE','AD') then -- if str_typgrpid = 'CE' then
            v_year := str_typgrpid;
          elsif str_typgrpid = 'MT' then
            v_month := str_typgrpid;
          end if;
        end loop;
        if v_month is not null and v_year is null then
          param_msg_error := get_error_msg_php('PM0072',global_v_lang);
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          rollback;
          return;
        end if;
        --
        begin
          delete from tsempidd where groupid = str_groupid;
        end;
        for i in 0..obj_typgrpids.get_size-1 loop
          json_row    := json_object_t();
          json_row    := hcm_util.get_json_t(obj_typgrpids,to_char(i));

--          str_numseq    := hcm_util.get_string(json_row, 'numseq');
          str_name      := hcm_util.get_string_t(json_row, 'name');
          str_desc      := hcm_util.get_string_t(json_row, 'desc');
          str_disabled  := hcm_util.get_string_t(json_row, 'disabled');
          str_typgrpid  := hcm_util.get_string_t(json_row, 'typgrpid');
          str_type      := hcm_util.get_string_t(json_row, 'type');
          str_typeval   := hcm_util.get_string_t(json_row, 'typeval');
          str_value     := hcm_util.get_string_t(json_row, 'value');

          if str_typgrpid = 'ST2' or str_typgrpid = 'ST3' then
            str_typgrpid := 'ST';
          end if;
          /* TSEMPIDD */
          insert into tsempidd
                  (groupid, numseq, typgrpid, typeval, codcreate, coduser)
           values (str_groupid, i+1, str_typgrpid, str_value, global_v_coduser, global_v_coduser);
          /* trunempid -- case insert year month running */
          if str_typgrpid in ('CE','BE') then -- 2565
            begin
              if str_value = '' then
                /* case exam year input blank insert 99 */
                update trunempid set dteyear = 99/*User37 #2493 Final Test Phase 1 V11 01/02/2021 '9999'*/ ,CODUSER = global_v_coduser where groupid = str_groupid;
              else
                /* case exam year input 18 insert 2018 */
                flag_monthandyear := flag_monthandyear+1;
                v_rcntyear := substr(to_char(sysdate,'yyyy'),1,2);
                --<<User37 #2493 Final Test Phase 1 V11 01/02/2021
                --update trunempid set dteyear = v_rcntyear||str_value ,CODUSER = global_v_coduser where groupid = str_groupid;
                --update trunempid set dteyear = str_value ,CODUSER = global_v_coduser where groupid = str_groupid;
                update trunempid set dteyear = to_number(25||str_value)-543 ,CODUSER = global_v_coduser where groupid = str_groupid;--nut 
                -->>User37 #2493 Final Test Phase 1 V11 01/02/2021
              end if;
            end;
          elsif str_typgrpid in ('AD') then -- 2022 || user4 || 13/10/2022
            begin
              if str_value = '' then
                /* case exam year input blank insert 99 */
                update trunempid set dteyear = 99 ,CODUSER = global_v_coduser where groupid = str_groupid;
              else
                /* case exam year input 18 insert 2018 */
                flag_monthandyear := flag_monthandyear+1;
                v_rcntyear := substr(to_char(sysdate,'yyyy'),1,2);
                update trunempid set dteyear = to_number(v_rcntyear||str_value) ,CODUSER = global_v_coduser where groupid = str_groupid; 
              end if;
            end;
          elsif str_typgrpid = 'MT' then
            begin
              if str_value = '' then
                /* case exam month input blank insert 99 */
                update TRUNEMPID set DTEMONTH = 99  ,CODUSER = global_v_coduser where GROUPID = str_groupid;
              else
                /* case exam month */
                flag_monthANDyear := flag_monthANDyear+3;
                update TRUNEMPID set DTEMONTH = str_value  ,CODUSER = global_v_coduser where GROUPID = str_groupid;
              end if;
            end;
          elsif str_typgrpid = 'RN' then
            begin
              update TSEMPIDD set TYPEVAL = LPAD('0', str_typeval, '0') ,CODUSER = global_v_coduser where GROUPID = str_groupid and TYPGRPID = 'RN';
              update TRUNEMPID set RUNNING = str_value ,CODUSER = global_v_coduser where GROUPID = str_groupid;
            end;
          end if;
        end loop;
      elsif count_groupid = 1 then -- case update
        if count_runid = 0 then
          begin
            insert into trunempid
                          (groupid, dteyear, dtemonth,running, codcreate,coduser,dtecreate,dteupd)
                   values (str_groupid, 99/*User37 #2493 Final Test Phase 1 V11 01/02/2021 9999*/, 99, 0, global_v_coduser,global_v_coduser,sysdate,sysdate);
          exception when dup_val_on_index then
            null;
          end;
        end if;
        -- check group type
        for i in 0..obj_typgrpids.get_size-1 loop
          json_row    := json_object_t();
          json_row    := hcm_util.get_json_t(obj_typgrpids,to_char(i));
          str_typgrpid    := hcm_util.get_string_t(json_row, 'typgrpid');
          /* TRUNEMPID -- case Update YEAR MONTH RUNNING */
          if str_typgrpid in ('CE','BE','AD') then -- if str_typgrpid = 'CE' then
            v_year := str_typgrpid;
          elsif str_typgrpid = 'MT' then
            v_month := str_typgrpid;
          end if;
        end loop;
        if v_month is not null and v_year is null then
          param_msg_error := get_error_msg_php('PM0072',global_v_lang);
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          rollback;
          return;
        end if;

        begin -- update group id
          update tsempidh
             set namempide  = str_namempide,
                 namempidt  = str_namempidt,
                 namempid3  = str_namempid3,
                 namempid4  = str_namempid4,
                 namempid5  = str_namempid5,
                 syncond    = str_syncond,
                 statement  = str_statement,
                 coduser    = global_v_coduser
           where groupid = str_groupid;
        end;

        begin
          delete from tsempidd where groupid = str_groupid;
        end;
--
        for i in 0..obj_typgrpids.get_size-1 loop
          json_row      := json_object_t();
          json_row      := hcm_util.get_json_t(obj_typgrpids,to_char(i));
--            str_numseq    := hcm_util.get_string(json_row, 'numseq');
          str_name      := hcm_util.get_string_t(json_row, 'name');
          str_desc      := hcm_util.get_string_t(json_row, 'desc');
          str_disabled  := hcm_util.get_string_t(json_row, 'disabled');
          str_typgrpid  := hcm_util.get_string_t(json_row, 'typgrpid');
          str_type      := hcm_util.get_string_t(json_row, 'type');
          str_typeval   := hcm_util.get_string_t(json_row, 'typeval');
          str_value     := hcm_util.get_string_t(json_row, 'value');

          begin
            select groupid,dteyear,dtemonth,running
              into v_nowgrpid, v_nowdteyear, v_nowdtemonth, v_nowrunning
              from trunempid t1
             where lpad(dteyear,4,'0')||lpad(dtemonth,2,'0')||lpad(running,8,'0') = (select  max(lpad(dteyear,4,'0')||lpad(dtemonth,2,'0')||lpad(running,8,'0'))
                                                                                      from    trunempid t2
                                                                                      where   t1.groupid    = t2.groupid)
               and groupid = str_groupid
            order by groupid;
          exception when no_data_found then
            v_nowgrpid := ''; v_nowdteyear := ''; v_nowdtemonth := ''; v_nowrunning := '';
          end;
          if str_typgrpid = 'ST2' or str_typgrpid = 'ST3' then
            str_typgrpid := 'ST';
          end if;
            /* TRUNEMPID -- case Update YEAR MONTH RUNNING */
          if str_typgrpid = 'ST' then
            begin
              insert into TSEMPIDD (GROUPID, NUMSEQ, TYPGRPID,TYPEVAL, CODCREATE, coduser)
              values (str_groupid, i+1, str_typgrpid, str_value, global_v_coduser,global_v_coduser);
            end;
          elsif str_typgrpid in ('CE','BE') then -- 2565
            begin
              insert into TSEMPIDD (GROUPID, NUMSEQ, TYPGRPID,TYPEVAL, CODCREATE,coduser)
              values (str_groupid, i+1, str_typgrpid, str_value, global_v_coduser,global_v_coduser);
              if str_value = '' then
              /* case exam year input blank insert 99 */
                update TRUNEMPID set DTEYEAR = 99/*User37 #2493 Final Test Phase 1 V11 01/02/2021 '9999'*/,CODUSER = global_v_coduser where GROUPID = str_groupid;
              else
                /* case exam year input 18 insert 2018 */
                v_checkCE := str_typgrpid;
                v_rcntyear := substr(to_char(sysdate,'yyyy'),1,2);
                update TRUNEMPID
                   set DTEYEAR  = to_number('25'||str_value)-543,--nut str_value, --User37 #2493 Final Test Phase 1 V11 01/02/2021 v_rcntyear||str_value,
                       CODUSER  = global_v_coduser
                 where GROUPID  = str_groupid
                   and DTEYEAR  = v_nowdteyear
                   and dtemonth = v_nowdtemonth;
              end if;
            end;
          elsif str_typgrpid = 'AD' then -- 2022 || user4 || 13/10/2022
            begin
              insert into TSEMPIDD (GROUPID, NUMSEQ, TYPGRPID,TYPEVAL, CODCREATE,coduser)
              values (str_groupid, i+1, str_typgrpid, str_value, global_v_coduser,global_v_coduser);
              if str_value = '' then
              /* case exam year input blank insert 99 */
                update TRUNEMPID set DTEYEAR = 99,CODUSER = global_v_coduser where GROUPID = str_groupid;
              else
                /* case exam year input 18 insert 2018 */
                v_checkCE := str_typgrpid;
                v_rcntyear := substr(to_char(sysdate,'yyyy'),1,2);
                update TRUNEMPID
                   set DTEYEAR  = to_number(v_rcntyear||str_value),
                       CODUSER  = global_v_coduser
                 where GROUPID  = str_groupid
                   and DTEYEAR  = v_nowdteyear
                   and dtemonth = v_nowdtemonth;
              end if;
            end;
          elsif str_typgrpid = 'MT' then
            begin
              insert into TSEMPIDD (GROUPID, NUMSEQ, TYPGRPID,TYPEVAL, CODCREATE,coduser)
              values (str_groupid, i+1, str_typgrpid, str_value, global_v_coduser,global_v_coduser);
              if str_value = '' then
                /* case exam month input blank insert 99 */
                update TRUNEMPID set DTEMONTH = '99',CODUSER = global_v_coduser where GROUPID = str_groupid;
              else
                /* case exam month */
                v_checkMT := str_typgrpid;
                update TRUNEMPID
                   set DTEMONTH   = str_value,
                       CODUSER    = global_v_coduser
                 where GROUPID    = str_groupid
                   and DTEYEAR    = v_nowdteyear
                   and dtemonth   = v_nowdtemonth;
              end if;
            end;
          elsif str_typgrpid = 'RN' then
            begin
              insert into TSEMPIDD (GROUPID, NUMSEQ, TYPGRPID,TYPEVAL, CODCREATE,coduser)
              values (str_groupid, i+1, str_typgrpid, LPAD('0', str_typeval, '0'), global_v_coduser,global_v_coduser);
            end;
            begin
              select codempid into v_codempid from temploy1 where codempid = str_lastid;
            exception when no_data_found then
              v_codempid := '';
            end;
            if v_codempid is not null then
              update TRUNEMPID set RUNNING = to_number(str_value) + 1,CODUSER = global_v_coduser
               where GROUPID = str_groupid
                and DTEYEAR    = v_nowdteyear
                and dtemonth   = v_nowdtemonth;
            else
              update TRUNEMPID set RUNNING = to_number(str_value),CODUSER = global_v_coduser
               where GROUPID = str_groupid
                 and DTEYEAR    = v_nowdteyear
                 and dtemonth   = v_nowdtemonth;
            end if;
        end if;
        end loop;
        -- Check if MT change
        begin
          select groupid,dteyear,dtemonth,running
            into v_nowgrpid, v_nowdteyear, v_nowdtemonth, v_nowrunning
            from trunempid t1
           where lpad(dteyear,4,'0')||lpad(dtemonth,2,'0')||lpad(running,8,'0') = (select  max(lpad(dteyear,4,'0')||lpad(dtemonth,2,'0')||lpad(running,8,'0'))
                                                                                    from    trunempid t2
                                                                                    where   t1.groupid    = t2.groupid)
             and groupid = str_groupid
          order by groupid;
        exception when no_data_found then
          v_nowgrpid := ''; v_nowdteyear := ''; v_nowdtemonth := ''; v_nowrunning := '';
        end;
        if v_checkMT is null then
          update TRUNEMPID
             set DTEMONTH   = 99,
                 CODUSER    = global_v_coduser
           where GROUPID    = str_groupid
             and DTEYEAR    = v_nowdteyear
             and dtemonth   = v_nowdtemonth;
        end if;

        -- Check if CE change
        begin
          select groupid,dteyear,dtemonth,running
            into v_nowgrpid, v_nowdteyear, v_nowdtemonth, v_nowrunning
            from trunempid t1
           where lpad(dteyear,4,'0')||lpad(dtemonth,2,'0')||lpad(running,8,'0') = (select  max(lpad(dteyear,4,'0')||lpad(dtemonth,2,'0')||lpad(running,8,'0'))
                                                                                    from    trunempid t2
                                                                                    where   t1.groupid    = t2.groupid)
             and groupid = str_groupid
          order by groupid;
        exception when no_data_found then
          v_nowgrpid := ''; v_nowdteyear := ''; v_nowdtemonth := ''; v_nowrunning := '';
        end;
        if v_checkCE is null then
          --<<User37 #2493 Final Test Phase 1 V11 01/02/2021
          delete trunempid where GROUPID = str_groupid and DTEYEAR = v_nowdteyear and dtemonth = v_nowdtemonth;
          begin
              insert into trunempid
                            (groupid, dteyear, dtemonth,running, codcreate,coduser,dtecreate,dteupd)
                     values (str_groupid, 99, v_nowdtemonth, 0, global_v_coduser,global_v_coduser,sysdate,sysdate);
          exception when dup_val_on_index then
            null;
          end;
          /*update TRUNEMPID
             set DTEYEAR    = 99,--User37 #2493 Final Test Phase 1 V11 01/02/2021 9999,
                 CODUSER    = global_v_coduser
           where GROUPID    = str_groupid
             and DTEYEAR    = v_nowdteyear
             and dtemonth   = v_nowdtemonth;*/
          -->>User37 #2493 Final Test Phase 1 V11 01/02/2021
        end if;
      end if;
    end if;
    if param_msg_error is null then
			param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
		end if;
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

--  function check_typgrpid(obj_item in varchar2) return varchar2 is
--    obj_json_typgrpids  json;
--    json_obj            json;
--    str_groupid         varchar2(100 char);
--    str_typgrpid        varchar2(100 char);
--    flag_monthANDyear   number := 0;
--    str_year            varchar2(100 char);
--    str_month           varchar2(100 char);
--    json_row            json;
--  BEGIN
--    json_obj            := json(obj_item);
--    obj_json_typgrpids  := json(json_obj.get('typgrpids'));
--    for i in 0..obj_json_typgrpids.count-1 loop
--      json_row        :=  json(obj_json_typgrpids.get(to_char(i)));
--      str_typgrpid    := hcm_util.get_string(json_row, 'typgrpid');
--
--      /* TRUNEMPID -- case Update YEAR MONTH RUNNING */
--      if str_typgrpid = 'CE' then
--        str_year := str_typgrpid;
--      elsif str_typgrpid = 'MT' then
--        str_month := str_typgrpid;
--      end if;
--    end loop;
--    return 'aaa';
--  EXCEPTION WHEN OTHERS THEN
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--  end check_typgrpid;

  /* procedure genSearch (json_str_output out clob) as
    obj_row     json;
    obj_data    json;
    obj_data_syncond  json;
    obj_row_syncond   json;
    obj_row_1   json;
    obj_data_1    json;
    obj_data_groupname  json;
    count_loop_seq    number := 0;
    count_loop    number := 0;
    v_codempid    varchar2( 100 char);
    resultName    varchar2( 100 char);
    desc_codshifte    varchar2( 100 char);
    desc_codshiftt    varchar2( 100 char);
    desc_codshift3    varchar2( 100 char);
    desc_codshift4    varchar2( 100 char);
    desc_codshift5    varchar2( 100 char);

    cursor c_temploy1 is
    SELECT
    TSEMPIDH.GROUPID,
    TSEMPIDH.NAMEMPIDT,
    TSEMPIDH.NAMEMPIDE,
    TSEMPIDH.NAMEMPID3,
    TSEMPIDH.NAMEMPID4,
    TSEMPIDH.NAMEMPID5,
    TSEMPIDH.SYNCOND,
    TSEMPIDH."STATEMENT",
    TSEMPIDD.NUMSEQ,
    TSEMPIDD.TYPGRPID,
    TSEMPIDD.TYPEVAL,
    TRUNEMPID.DTEYEAR,
    TRUNEMPID.DTEMONTH,
    TRUNEMPID.RUNNING
    FROM
    TSEMPIDH
    JOIN TSEMPIDD ON TSEMPIDH.GROUPID = TSEMPIDD.GROUPID
    JOIN TRUNEMPID ON TSEMPIDD.GROUPID = TRUNEMPID.GROUPID
    WHERE
    TSEMPIDH.GROUPID = p_groupid
    ORDER BY
    TSEMPIDH.GROUPID,
    TSEMPIDD.NUMSEQ;
    dataVal     varchar2( 100 char);
    namempide   varchar2( 100 char);
    numseq      varchar2( 100 char);
    code      varchar2( 1000 char);
    str_des     varchar2( 1000 char);
    str_statement   varchar2( 2000 char);
    typeval     varchar2( 100 char);
    typgrpid    varchar2( 100 char);
    digit     varchar2( 100 char);
    dataVal_new   varchar2( 100 char);
    tempGroup   varchar2( 100 char) := '0';
    count_TYPGRPID    number := 1;
  begin
    obj_data := json();
    obj_row := json();

    obj_data_1 := json();
    obj_row_1 := json();
    obj_data_syncond := json();
    obj_row_syncond := json();

    obj_data_groupname := json;
    for r1 in c_temploy1 loop
      if r1.GroupID = tempGroup or tempGroup = '0' then
        dataVal_new := r1.TYPEVAL;

        if r1.TYPGRPID = 'RN' then
          typeval := r1.RUNNING;
          digit := length(to_char(r1.TYPEVAL));
          dataVal_new := LPAD(r1.RUNNING, digit, '0');

        else
          typeval := r1.TYPEVAL;
          dataVal_new := dataVal_new;
        end if;
        if r1.TYPGRPID = 'ST' then
          if count_TYPGRPID = 1 then
            typgrpid := r1.TYPGRPID;
          else
            typgrpid := CONCAT(r1.TYPGRPID, count_TYPGRPID);
          end if;
          count_TYPGRPID := count_TYPGRPID+1;
        else
          typgrpid := r1.TYPGRPID;
        end if;

        dataVal := CONCAT(dataVal, dataVal_new);
        namempide := r1.NAMEMPIDT;
        tempGroup := r1.GroupID;
        numseq := r1.NUMSEQ;
        str_statement := r1."STATEMENT";
        code := r1.SYNCOND;

        desc_codshifte := r1.NAMEMPIDE;
        desc_codshiftt := r1.NAMEMPIDT;
        desc_codshift3 := r1.NAMEMPID3;
        desc_codshift4 := r1.NAMEMPID4;
        desc_codshift5 := r1.NAMEMPID5;
        obj_data_1.put('numseq', numseq);
        obj_data_1.put('typgrpid', typgrpid);
        obj_data_1.put('value', typeval);
        obj_data_1.put('typeval', digit);
        obj_row_1.put(to_char(count_loop_seq), obj_data_1);
        count_loop_seq := count_loop_seq+1;

      end if;
    end loop;
    if tempGroup <> '0' then
      str_des := get_logical_name('HRPM15E',code,p_lang);

      obj_data_syncond.put('code', code);
      obj_data_syncond.put('description', str_des);
      obj_data_syncond.put('statement', str_statement);
      obj_data_groupname.put('desc_codshifte', desc_codshifte);
      obj_data_groupname.put('desc_codshiftt', desc_codshiftt);
      obj_data_groupname.put('desc_codshift3', desc_codshift3);
      obj_data_groupname.put('desc_codshift4', desc_codshift4);
      obj_data_groupname.put('desc_codshift5', desc_codshift5);

      obj_data.put('coderror', '200');
      obj_data.put('rownumber', count_loop+1);
      obj_data.put('p_groupid', tempGroup);
      obj_data.put('p_namepidt', namempide);
      obj_data.put('p_lastempid', dataVal);
      obj_data.put('p_syncond', obj_data_syncond);
      obj_data.put('p_typgrpids', obj_row_1);
      obj_data.put('p_groupname', obj_data_groupname);
      obj_row.put(to_char(count_loop+1), obj_data);
    else
      obj_data_1 := json();
      obj_data_1.put('numseq', 1);
      obj_data_1.put('typgrpid', 'RN');
      obj_data_1.put('value', 0);
      obj_data_1.put('typeval', 1);
      obj_row_1.put(0, obj_data_1);
      obj_data.put('coderror', '200');
      obj_data.put('rownumber', '');
      obj_data.put('p_groupid', p_groupid);
      obj_data.put('p_namepidt', '');
      obj_data.put('p_lastempid', '');
      obj_data.put('p_syncond', '');
      obj_data.put('p_typgrpids', obj_row_1);
      obj_row.put(to_char(count_loop+1), obj_data);
    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; */

  /* procedure genIndex (json_str_output out clob) as
    obj_row     json;
    obj_data    json;
    obj_data_groupname  json;
    obj_row_groupname json;
    obj_data_syncond  json;
    obj_row_syncond   json;
    obj_row_1   json;
    obj_data_1    json;
    count_loop_seq    number := 0;
    count_loop    number := 0;
    v_codempid    varchar2( 100 char);
    resultName    varchar2( 100 char);

    cursor c_temploy1 is
    SELECT
    TSEMPIDH.GROUPID,
    TSEMPIDH.NAMEMPIDT,
    TSEMPIDH.NAMEMPIDE,
    TSEMPIDH.NAMEMPID3,
    TSEMPIDH.NAMEMPID4,
    TSEMPIDH.NAMEMPID5,
    TSEMPIDH.SYNCOND,
    TSEMPIDH."STATEMENT",
    TSEMPIDD.NUMSEQ,
    TSEMPIDD.TYPGRPID,
    TSEMPIDD.TYPEVAL,
    TRUNEMPID.DTEYEAR,
    TRUNEMPID.DTEMONTH,
    TRUNEMPID.RUNNING
    FROM
    TSEMPIDH
    JOIN TSEMPIDD ON TSEMPIDH.GROUPID = TSEMPIDD.GROUPID
    JOIN TRUNEMPID ON TSEMPIDD.GROUPID = TRUNEMPID.GROUPID
    ORDER BY
    TSEMPIDH.GROUPID,
    TSEMPIDD.NUMSEQ;
    dataVal     varchar2( 100 char);
    namempide   varchar2( 100 char);
    numseq      varchar2( 100 char);

    desc_codshifte    varchar2( 100 char);
    desc_codshiftt    varchar2( 100 char);
    desc_codshift3    varchar2( 100 char);
    desc_codshift4    varchar2( 100 char);
    desc_codshift5    varchar2( 100 char);
    code      varchar2( 1000 char);
    str_des     varchar2( 1000 char);
    str_statement   varchar2( 2000 char);
    typeval     varchar2( 100 char);
    typgrpid    varchar2( 100 char);
    digit     varchar2( 100 char);
    dataVal_new   varchar2( 100 char);
    tempGroup   varchar2( 100 char) := '0';
    count_TYPGRPID    number := 1;

  begin
    obj_data := json();
    obj_row := json();
    obj_data_1 := json();
    obj_row_1 := json();

    obj_data_groupname := json;
    obj_row_groupname := json;
    obj_data_syncond := json;
    obj_row_syncond := json;

    for r1 in c_temploy1 loop
      obj_data_1 := json();
      if r1.GroupID = tempGroup or tempGroup = '0' then

        dataVal_new := r1.TYPEVAL;
        if r1.TYPGRPID = 'RN' then

          typeval := r1.RUNNING;
          digit := length(to_char(r1.TYPEVAL));
          dataVal_new := LPAD(r1.RUNNING, digit, '0');
        else
          typeval := r1.TYPEVAL;
          dataVal_new := dataVal_new;
        end if;

        if r1.TYPGRPID = 'ST' then
          if count_TYPGRPID = 1 then
            typgrpid := r1.TYPGRPID;
          else
            typgrpid := CONCAT(r1.TYPGRPID, count_TYPGRPID);
          end if;
          count_TYPGRPID := count_TYPGRPID+1;
        else
          typgrpid := r1.TYPGRPID;
        end if;

        dataVal := CONCAT(dataVal, dataVal_new);
        namempide := r1.NAMEMPIDT;
        tempGroup := r1.GroupID;
        numseq := r1.NUMSEQ;
        str_statement := r1."STATEMENT";
        code := r1.SYNCOND;
        desc_codshifte := r1.NAMEMPIDE;
        desc_codshiftt := r1.NAMEMPIDT;
        desc_codshift3 := r1.NAMEMPID3;
        desc_codshift4 := r1.NAMEMPID4;
        desc_codshift5 := r1.NAMEMPID5;
        get_groupname(tempGroup,global_v_lang,namempide);

        obj_data_1.put('numseq', numseq);
        obj_data_1.put('typgrpid', typgrpid);
        obj_data_1.put('value', typeval);
        obj_data_1.put('typeval', digit);
        obj_row_1.put(to_char(count_loop_seq), obj_data_1);
        count_loop_seq := count_loop_seq+1;
      else
        count_loop := count_loop + 1;
        str_des := get_logical_name('HRPM15E',code,p_lang);

        obj_data_syncond.put('code', code);
        obj_data_syncond.put('description', str_des);
        obj_data_syncond.put('statement', str_statement);
        obj_data_groupname.put('desc_codshifte', desc_codshifte);
        obj_data_groupname.put('desc_codshiftt', desc_codshiftt);
        obj_data_groupname.put('desc_codshift3', desc_codshift3);
        obj_data_groupname.put('desc_codshift4', desc_codshift4);
        obj_data_groupname.put('desc_codshift5', desc_codshift5);


        obj_data.put('coderror', '200');
        obj_data.put('rownumber', count_loop);
        obj_data.put('p_groupid', tempGroup);
        obj_data.put('p_namepidt', namempide);
        obj_data.put('p_lastempid', dataVal);
        obj_data.put('p_syncond', obj_data_syncond);
        obj_data.put('p_typgrpids', obj_row_1);
        obj_data.put('p_groupname', obj_data_groupname);
        obj_row.put(to_char(count_loop), obj_data);
        obj_row_1 := json();
        obj_data_syncond := json();
        count_loop_seq := 0;
        count_TYPGRPID := 1;

        dataVal := r1.TYPEVAL;
        tempGroup := r1.GroupID;
        typeval := r1.TYPEVAL;
        namempide := r1.NAMEMPIDT;
        desc_codshifte := r1.NAMEMPIDE;
        desc_codshiftt := r1.NAMEMPIDT;
        desc_codshift3 := r1.NAMEMPID3;
        desc_codshift4 := r1.NAMEMPID4;
        desc_codshift5 := r1.NAMEMPID5;
        numseq := r1.NUMSEQ;
        str_statement := r1."STATEMENT";
        code := r1.SYNCOND;
        digit := length(to_char(r1.TYPEVAL));
        str_des := get_logical_name('HRPM15E',code,p_lang);
        get_groupname(tempGroup,global_v_lang,namempide);
        obj_data_syncond.put('code', code);
        obj_data_syncond.put('description', str_des);
        obj_data_syncond.put('statement', str_statement);

        if r1.TYPGRPID = 'ST' then
          if count_TYPGRPID = 1 then
            typgrpid := r1.TYPGRPID;
          else
            typgrpid := CONCAT(r1.TYPGRPID, count_TYPGRPID);
          end if;
          count_TYPGRPID := count_TYPGRPID+1;
        else
          typgrpid := r1.TYPGRPID;
        end if;
        obj_data_1 := json();
        obj_data_1.put('numseq', numseq);
        obj_data_1.put('typgrpid', typgrpid);
        obj_data_1.put('value', typeval);
        obj_data_1.put('typeval', digit);
        obj_row_1.put(to_char(count_loop_seq), obj_data_1);

        count_loop_seq := count_loop_seq+1;
      end if;
    end loop;

    if tempGroup <> '0' then
      str_des := get_logical_name('HRPM15E',code,p_lang);
      obj_data_syncond.put('code', code);
      obj_data_syncond.put('description', str_des);
      obj_data_syncond.put('statement', str_statement);

      obj_data_groupname.put('desc_codshifte', desc_codshifte);
      obj_data_groupname.put('desc_codshiftt', desc_codshiftt);
      obj_data_groupname.put('desc_codshift3', desc_codshift3);
      obj_data_groupname.put('desc_codshift4', desc_codshift4);
      obj_data_groupname.put('desc_codshift5', desc_codshift5);
      obj_data.put('coderror', '200');
      obj_data.put('rownumber', count_loop+1);
      obj_data.put('p_groupid', tempGroup);
      obj_data.put('p_namepidt', namempide);
      obj_data.put('p_lastempid', dataVal);
      obj_data.put('p_syncond', obj_data_syncond);
      obj_data.put('p_typgrpids', obj_row_1);
      obj_data.put('p_groupname', obj_data_groupname);
      obj_row.put(to_char(count_loop+1), obj_data);
    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; */

end HRPM15E;

/

--------------------------------------------------------
--  DDL for Package Body HRCO2AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2AE" AS
  procedure check_index is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codprov is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codprov');
      return;
    end if;
  end;
  --
  procedure check_save_dist is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_descod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_descod');
      return;
    end if;
  end;
  --
  procedure check_tsubdist is
    error_secur VARCHAR2(4000 CHAR);
    v_check_codsubdist number:=0;
  begin
    if p_descodsubdist is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'descodsubdist');
      return;
    end if;
    if p_codsubdist is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codsubdist');
      return;
    else
      begin
        select count(CODSUBDIST)
        into v_check_codsubdist
        from tsubdist
        where CODSUBDIST = p_codsubdist;
      end;
      if v_check_codsubdist > 0 then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpost');
        return;
      end if;
    end if;
  end;
  --
  procedure check_tcoddist is
    error_secur VARCHAR2(4000 CHAR);
    v_check_codsubdist number:=0;
  begin
    if p_namdist is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'namdist');
      return;
    end if;
    if p_codpost is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpost');
      return;
    end if;
  end;
  --
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
--    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    param_msg_error   := '';
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codprov           := hcm_util.get_string_t(json_obj,'codprov');
    p_coddist           := hcm_util.get_string_t(json_obj,'coddist');
    p_codsubdist        := hcm_util.get_string_t(json_obj,'codsubdist');
    p_codpost           := hcm_util.get_string_t(json_obj,'codpost');
    --

    p_descod               := hcm_util.get_string_t(json_obj,'descod');
    p_descodt              := hcm_util.get_string_t(json_obj,'descodt');
    p_descode              := hcm_util.get_string_t(json_obj,'descode');
    p_descod3              := hcm_util.get_string_t(json_obj,'descod3');
    p_descod4              := hcm_util.get_string_t(json_obj,'descod4');
    p_descod5              := hcm_util.get_string_t(json_obj,'descod5');

    p_namdist               := hcm_util.get_string_t(json_obj,'namdist');
    p_namdistt              := hcm_util.get_string_t(json_obj,'namdistt');
    p_namdiste              := hcm_util.get_string_t(json_obj,'namdiste');
    p_namdist3              := hcm_util.get_string_t(json_obj,'namdist3');
    p_namdist4              := hcm_util.get_string_t(json_obj,'namdist4');
    p_namdist5              := hcm_util.get_string_t(json_obj,'namdist5');

    p_descodsubdist         := hcm_util.get_string_t(json_obj,'descodsubdist');
    p_descodsubdiste        := hcm_util.get_string_t(json_obj,'descodsubdiste');
    p_descodsubdistt        := hcm_util.get_string_t(json_obj,'descodsubdistt');
    p_descodsubdist3        := hcm_util.get_string_t(json_obj,'descodsubdist3');
    p_descodsubdist4        := hcm_util.get_string_t(json_obj,'descodsubdist4');
    p_descodsubdist5        := hcm_util.get_string_t(json_obj,'descodsubdist5');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure get_tcodprov (json_str_input in clob,json_str_output out clob) is

  begin
    initial_value(json_str_input);
    gen_tcodprov(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tcodprov;
  --
  procedure gen_tcodprov (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt      number  := 0;
     cursor c1 is
        select CODCODEC,DESCODE,DESCODT,DESCOD3,DESCOD4,DESCOD5,
               decode(global_v_lang,'101',DESCODE
                                   ,'102',DESCODT
                                   ,'103',DESCOD3
                                   ,'104',DESCOD4
                                   ,'105',DESCOD5) as DESCOD
        from tcodprov
        order by CODCODEC;
  begin

    obj_row   := json_object_t();
    v_rcnt    := 0;
    for i in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codcodec', i.CODCODEC);
      obj_data.put('descod', i.DESCOD);
      obj_data.put('descode', i.DESCODE);
      obj_data.put('descodt', i.DESCODT);
      obj_data.put('descod3', i.DESCOD3);
      obj_data.put('descod4', i.DESCOD4);
      obj_data.put('descod5', i.DESCOD5);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tcodprov;
  --
  procedure gen_province_detail (json_str_output out clob) is
    obj_row            json_object_t;
     cursor c1 is
        select CODCODEC,DESCODE,DESCODT,DESCOD3,DESCOD4,DESCOD5,
               decode(global_v_lang,'101',DESCODE
                                   ,'102',DESCODT
                                   ,'103',DESCOD3
                                   ,'104',DESCOD4
                                   ,'105',DESCOD5) as DESCOD
        from tcodprov
        where CODCODEC = p_codprov
        order by CODCODEC;
  begin

    obj_row   := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codcodec', p_codprov);
    for i in c1 loop
      obj_row.put('descod', i.DESCOD);
      obj_row.put('descode', i.DESCODE);
      obj_row.put('descodt', i.DESCODT);
      obj_row.put('descod3', i.DESCOD3);
      obj_row.put('descod4', i.DESCOD4);
      obj_row.put('descod5', i.DESCOD5);
    end loop;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_province_detail;
  --
  procedure get_province_detail (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_province_detail(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_province_detail;
  --
  procedure gen_district_detail (json_str_output out clob) is
    obj_row            json_object_t;
    v_lastcode         tsubdist.codsubdist%type  := '';
     cursor c1 is
        select CODDIST,NAMDISTE,NAMDISTT,NAMDIST3,NAMDIST4,NAMDIST5,CODPOST,
               decode(global_v_lang,'101',NAMDISTE
                                   ,'102',NAMDISTT
                                   ,'103',NAMDIST3
                                   ,'104',NAMDIST4
                                   ,'105',NAMDIST5) as DESCODDIST
        from tcoddist
        where CODDIST = p_coddist
        order by CODDIST;
  begin
    select max(codsubdist) as maxcod
    into v_lastcode
    from tsubdist;

    obj_row   := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('coddist', p_coddist);
    obj_row.put('lstcodsubdist',v_lastcode);
    for i in c1 loop
      obj_row.put('namdist', i.DESCODDIST);
      obj_row.put('namdiste', i.NAMDISTE);
      obj_row.put('namdistt', i.NAMDISTT);
      obj_row.put('namdist3', i.NAMDIST3);
      obj_row.put('namdist4', i.NAMDIST4);
      obj_row.put('namdist5', i.NAMDIST5);
      obj_row.put('codpost', i.CODPOST);
    end loop;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_district_detail;
  --
  procedure get_district_detail (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_district_detail(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_district_detail;
  --
  procedure get_tcoddist (json_str_input in clob,json_str_output out clob) is

  begin
    initial_value(json_str_input);
    check_index;
    gen_tcoddist(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tcoddist;
  --
  procedure gen_tcoddist (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt      number  := 0;
     cursor c1 is
        select CODDIST,NAMDISTE,NAMDISTT,NAMDIST3,NAMDIST4,NAMDIST5,CODPOST,CODPROV,
               decode(global_v_lang,'101',NAMDISTE
                                   ,'102',NAMDISTT
                                   ,'103',NAMDIST3
                                   ,'104',NAMDIST4
                                   ,'105',NAMDIST5) as DESCODDIST
        from tcoddist
        where CODPROV = p_codprov
        order by CODDIST;
  begin

    obj_row   := json_object_t();
    v_rcnt    := 0;
    for i in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('coddist', i.CODDIST);
      obj_data.put('namdist', i.DESCODDIST);
      obj_data.put('namdiste', i.NAMDISTE);
      obj_data.put('namdistt', i.NAMDISTT);
      obj_data.put('namdist3', i.NAMDIST3);
      obj_data.put('namdist4', i.NAMDIST4);
      obj_data.put('namdist5', i.NAMDIST5);
      obj_data.put('codprov', i.CODPROV);
      obj_data.put('codpost', i.CODPOST);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tcoddist;
  --
  procedure get_tsubdist (json_str_input in clob,json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt      number  := 0;
     cursor c1 is
        select CODSUBDIST,NAMSUBDISTE,NAMSUBDISTT,NAMSUBDIST3,NAMSUBDIST4,NAMSUBDIST5,CODDIST,CODPROV,CODPOST as codpostsubdist,
               decode(global_v_lang,'101',NAMSUBDISTE
                                   ,'102',NAMSUBDISTT
                                   ,'103',NAMSUBDIST3
                                   ,'104',NAMSUBDIST4
                                   ,'105',NAMSUBDIST5) as DESCODSUBDIST,
               (select codpost FROM TCODDIST WHERE CODDIST = p_coddist ) as codpost
        from tsubdist
        where CODPROV = p_codprov
        and CODDIST = p_coddist
        order by CODSUBDIST;
  begin
    initial_value(json_str_input);
    obj_row   := json_object_t();
    v_rcnt    := 0;
    for i in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codsubdist', i.CODSUBDIST);
      obj_data.put('descodsubdist', i.DESCODSUBDIST);
      obj_data.put('namsubdiste', i.NAMSUBDISTE);
      obj_data.put('namsubdistt', i.NAMSUBDISTT);
      obj_data.put('namsubdist3', i.NAMSUBDIST3);
      obj_data.put('namsubdist4', i.NAMSUBDIST4);
      obj_data.put('namsubdist5', i.NAMSUBDIST5);
      obj_data.put('coddist', i.CODDIST);
      obj_data.put('codprov', i.CODPROV);
      obj_data.put('codpost', nvl(i.codpostsubdist,i.codpost)); -- arnon || 28/12/2022 || #8829 || obj_data.put('codpost', i.codpostsubdist);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tsubdist;
  --
  procedure delete_data_province(json_str_output out clob) is
    v_count1    number;
    v_count2    number;
    v_count3    number;
    v_count4    number;
    v_count5    number;
  begin
    begin
        begin
            select count(*)
              into v_count1
              from temploy2
             where p_codprov in (codprovc,codprovi,codprovr);
        exception when others then
          v_count1 := 0;
        end;    
        begin
            select count(*)
              into v_count2
              from tapplinf
             where p_codprov in (coddomcl,codprov,codprovc,codprovr);
        exception when others then
          v_count2 := 0;
        end;       
        begin
            select count(*)
              into v_count3
              from tcompny
             where codprovr = p_codprov;
        exception when others then
          v_count3 := 0;
        end;       
        begin
            select count(*)
              into v_count4
              from tcust
             where codprovr = p_codprov;
        exception when others then
          v_count4 := 0;
        end;       
        begin
            select count(*)
              into v_count5
              from tclninf
             where codprovr = p_codprov;
        exception when others then
          v_count5 := 0;
        end;   

        if (v_count1 + v_count2 + v_count3 + v_count4 + v_count5 > 0) then
            param_msg_error := get_error_msg_php('HR1450',global_v_lang);
            rollback;
        else 
            delete tsubdist where codprov = p_codprov;
            delete tcoddist where codprov = p_codprov;
            delete tcodprov where codcodec = p_codprov;
        end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  --
  procedure delete_data_district(json_str_output out clob) is
    v_count1    number;
    v_count2    number;
    v_count3    number;
    v_count4    number;
    v_count5    number;  
  begin
    begin
        begin
            select count(*)
              into v_count1
              from temploy2
             where p_coddist in (coddistc,coddistr);
        exception when others then
          v_count1 := 0;
        end;    
        begin
            select count(*)
              into v_count2
              from tapplinf
             where p_coddist in (coddistc,coddistr);
        exception when others then
          v_count2 := 0;
        end;       
        begin
            select count(*)
              into v_count3
              from tcompny
             where coddist = p_coddist;
        exception when others then
          v_count3 := 0;
        end;       
        begin
            select count(*)
              into v_count4
              from tcust
             where coddist = p_coddist;
        exception when others then
          v_count4 := 0;
        end;       
        begin
            select count(*)
              into v_count5
              from tclninf
             where coddistr = p_coddist;
        exception when others then
          v_count5 := 0;
        end;   

        if (v_count1 + v_count2 + v_count3 + v_count4 + v_count5 > 0) then
            param_msg_error := get_error_msg_php('HR1450',global_v_lang);
            rollback;
        else 
            delete tsubdist where coddist = p_coddist;
            delete tcoddist where coddist = p_coddist;
        end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  --
  procedure delete_tcodprov (json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

      p_flg       := hcm_util.get_string_t(param_json_row,'flg');
      p_codprov   := hcm_util.get_string_t(param_json_row,'codprov');

      if(p_flg = 'delete') then
        delete_data_province(json_str_output);
        if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            rollback;
            return;
        end if;
      end if;

    end loop;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure check_new_province is
    v_check_codprov number:=0;
  begin
    begin
        select count(CODCODEC)
        into v_check_codprov
        from tcodprov
        where CODCODEC = p_codprov;

        if v_check_codprov > 0 then
          UPDATE tcodprov
          SET DESCODE = p_descode,
              DESCODT = p_descodt,
              DESCOD3 = p_descod3,
              DESCOD4 = p_descod4,
              DESCOD5 = p_descod5,
              DTEUPD = sysdate,
              CODUSER = global_v_coduser
          WHERE CODCODEC = p_codprov;
        else
          insert into tcodprov (CODCODEC,DESCODE,DESCODT,DESCOD3,DESCOD4,DESCOD5,CODCREATE, DTECREATE, CODUSER)
          values (p_codprov, p_descode, p_descodt, p_descod3, p_descod4, p_descod5, global_v_coduser, sysdate, global_v_coduser);
        end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  --
  procedure check_new_district is
    v_check_coddist number:=0;
  begin
    begin
        select count(CODDIST)
        into v_check_coddist
        from tcoddist
        where CODDIST = p_coddist;

        if v_check_coddist > 0 then
          UPDATE tcoddist
          SET NAMDISTE = p_namdiste,
              NAMDISTT = p_namdistt,
              NAMDIST3 = p_namdist3,
              NAMDIST4 = p_namdist4,
              NAMDIST5 = p_namdist5,
              CODPOST = p_codpost,
              DTEUPD = sysdate,
              CODUSER = global_v_coduser
          WHERE CODDIST = p_coddist;
        else
          insert into tcoddist (CODDIST,NAMDISTE,NAMDISTT,NAMDIST3,NAMDIST4,NAMDIST5,CODPROV,CODPOST, DTECREATE, CODCREATE,CODUSER)
          values (p_coddist, p_namdiste, p_namdistt, p_namdist3, p_namdist4, p_namdist5, p_codprov, p_codpost, sysdate, global_v_coduser,global_v_coduser);
        end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  --
  procedure check_new_subdistrict is
    v_check_subdist number:=0;
  begin
    begin
        select count(CODSUBDIST)
        into v_check_subdist
        from tsubdist
        where CODSUBDIST = p_codsubdist;

        if v_check_subdist > 0 then
          param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TSUBDIST');
        end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  --
  procedure delete_tcoddist (json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    check_save_dist;
    if param_msg_error is null then
      check_new_province;

      param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

        p_flg       := hcm_util.get_string_t(param_json_row,'flg');
        p_coddist   := hcm_util.get_string_t(param_json_row,'coddist');

        if(p_flg = 'delete') then
          delete_data_district(json_str_output);
          if param_msg_error is not null then
            exit;
--              json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--              rollback;
--              return;
          end if;
        end if;

      end loop;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
--      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure save_tsubdist (json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_check_codsubdist number:=0;
    v_count1    number;
    v_count2    number;
    v_count3    number;
    v_count4    number;
    v_count5    number;    
  begin
    initial_value(json_str_input);

    if param_msg_error is null then
      check_new_province;
      check_new_district;

      param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

        p_flg                   := hcm_util.get_string_t(param_json_row,'flg');
        p_codsubdist            := hcm_util.get_string_t(param_json_row,'codsubdist');
        p_descodsubdist         := hcm_util.get_string_t(param_json_row,'descodsubdist');
        p_descodsubdiste        := hcm_util.get_string_t(param_json_row,'descodsubdiste');
        p_descodsubdistt        := hcm_util.get_string_t(param_json_row,'descodsubdistt');
        p_descodsubdist3        := hcm_util.get_string_t(param_json_row,'descodsubdist3');
        p_descodsubdist4        := hcm_util.get_string_t(param_json_row,'descodsubdist4');
        p_descodsubdist5        := hcm_util.get_string_t(param_json_row,'descodsubdist5');
        p_codpostsubdist        := hcm_util.get_string_t(param_json_row,'codpost');

        if(p_flg = 'delete') then
            begin
                select count(*)
                  into v_count1
                  from temploy2
                 where p_codsubdist in (codsubdistc,codsubdistr);
            exception when others then
              v_count1 := 0;
            end;    
            begin
                select count(*)
                  into v_count2
                  from tapplinf
                 where p_codsubdist in (codsubdistc,codsubdistr);
            exception when others then
              v_count2 := 0;
            end;       
            begin
                select count(*)
                  into v_count3
                  from tcompny
                 where codsubdist = p_codsubdist;
            exception when others then
              v_count3 := 0;
            end;       
            begin
                select count(*)
                  into v_count4
                  from tcust
                 where codsubdist = p_codsubdist;
            exception when others then
              v_count4 := 0;
            end;       
            begin
                select count(*)
                  into v_count5
                  from tclninf
                 where codsubdistr = p_codsubdist;
            exception when others then
              v_count5 := 0;
            end;   
            if (v_count1 + v_count2 + v_count3 + v_count4 + v_count5 > 0) then
                param_msg_error := get_error_msg_php('HR1450',global_v_lang);
                exit;
            else 
                delete tsubdist where CODSUBDIST = p_codsubdist;
            end if;    
        elsif(p_flg = 'add') then
          check_tsubdist;
          check_new_subdistrict;
          exit when param_msg_error is not null;
          begin
              insert into tsubdist (codsubdist,namsubdiste,namsubdistt,namsubdist3,namsubdist4,namsubdist5,
              coddist,codprov,codpost,dtecreate,codcreate,coduser)
              values (p_codsubdist, p_descodsubdiste, p_descodsubdistt, p_descodsubdist3, p_descodsubdist4, p_descodsubdist5, 
              p_coddist, p_codprov, p_codpostsubdist, sysdate, global_v_coduser, global_v_coduser);
          end;   
        elsif(p_flg = 'edit') then
          begin
            update tsubdist
               set namsubdiste = p_descodsubdiste,
                   namsubdistt = p_descodsubdistt,
                   namsubdist3 = p_descodsubdist3,
                   namsubdist4 = p_descodsubdist4,
                   namsubdist5 = p_descodsubdist5,
                   coddist     = p_coddist,
                   codprov     = p_codprov,
                   coduser     = global_v_coduser
            where codsubdist   = p_codsubdist;
          end;
        end if;
      end loop;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
      return;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;

END HRCO2AE;

/

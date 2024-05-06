--------------------------------------------------------
--  DDL for Package Body HRCO01E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO01E" AS
  procedure initial_value (json_str in clob) is
    json_obj            json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- detail
    p_codcompy          := upper(hcm_util.get_string_t(json_obj, 'codcompy'));
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'dteeffec'),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj, 'numitem');
    p_flgTab3NotEdit    := hcm_util.get_boolean_t(json_obj, 'flgTab3NotEdit');
    p_isAfterSave       := nvl(hcm_util.get_string_t(json_obj, 'isAfterSave'),'N');
    p_namcome           := hcm_util.get_string_t(json_obj, 'namcome');
    p_namcomt           := hcm_util.get_string_t(json_obj, 'namcomt');
    p_namcom3           := hcm_util.get_string_t(json_obj, 'namcom3');
    p_namcom4           := hcm_util.get_string_t(json_obj, 'namcom4');
    p_namcom5           := hcm_util.get_string_t(json_obj, 'namcom5');
    p_namste            := hcm_util.get_string_t(json_obj, 'namste');
    p_namstt            := hcm_util.get_string_t(json_obj, 'namstt');
    p_namst3            := hcm_util.get_string_t(json_obj, 'namst3');
    p_namst4            := hcm_util.get_string_t(json_obj, 'namst4');
    p_namst5            := hcm_util.get_string_t(json_obj, 'namst5');
    p_adrcome           := hcm_util.get_string_t(json_obj, 'adrcome');
    p_adrcomt           := hcm_util.get_string_t(json_obj, 'adrcomt');
    p_adrcom3           := hcm_util.get_string_t(json_obj, 'adrcom3');
    p_adrcom4           := hcm_util.get_string_t(json_obj, 'adrcom4');
    p_adrcom5           := hcm_util.get_string_t(json_obj, 'adrcom5');
    p_numtele           := hcm_util.get_string_t(json_obj, 'numtele');
    p_numfax            := hcm_util.get_string_t(json_obj, 'numfax');
    p_numcotax          := hcm_util.get_string_t(json_obj, 'numcotax');
    p_descomp           := hcm_util.get_string_t(json_obj, 'descomp');
    p_numacsoc          := hcm_util.get_string_t(json_obj, 'numacsoc');
    p_zipcode           := hcm_util.get_string_t(json_obj, 'zipcode');
    p_email             := hcm_util.get_string_t(json_obj, 'email');
    p_website           := hcm_util.get_string_t(json_obj, 'website');
    p_comimage          := hcm_util.get_string_t(json_obj, 'comimage');
    p_namimgcom         := hcm_util.get_string_t(json_obj, 'namimgcom');
    p_namimgmap         := hcm_util.get_string_t(json_obj, 'namimgmap');
    p_addrnoe           := hcm_util.get_string_t(json_obj, 'addrnoe');
    p_addrnot           := hcm_util.get_string_t(json_obj, 'addrnot');
    p_addrno3           := hcm_util.get_string_t(json_obj, 'addrno3');
    p_addrno4           := hcm_util.get_string_t(json_obj, 'addrno4');
    p_addrno5           := hcm_util.get_string_t(json_obj, 'addrno5');
    p_soie              := hcm_util.get_string_t(json_obj, 'soie');
    p_soit              := hcm_util.get_string_t(json_obj, 'soit');
    p_soi3              := hcm_util.get_string_t(json_obj, 'soi3');
    p_soi4              := hcm_util.get_string_t(json_obj, 'soi4');
    p_soi5              := hcm_util.get_string_t(json_obj, 'soi5');
    p_mooe              := hcm_util.get_string_t(json_obj, 'mooe');
    p_moot              := hcm_util.get_string_t(json_obj, 'moot');
    p_moo3              := hcm_util.get_string_t(json_obj, 'moo3');
    p_moo4              := hcm_util.get_string_t(json_obj, 'moo4');
    p_moo5              := hcm_util.get_string_t(json_obj, 'moo5');
    p_roade             := hcm_util.get_string_t(json_obj, 'roade');
    p_roadt             := hcm_util.get_string_t(json_obj, 'roadt');
    p_road3             := hcm_util.get_string_t(json_obj, 'road3');
    p_road4             := hcm_util.get_string_t(json_obj, 'road4');
    p_road5             := hcm_util.get_string_t(json_obj, 'road5');
    p_villagee          := hcm_util.get_string_t(json_obj, 'villagee');
    p_villaget          := hcm_util.get_string_t(json_obj, 'villaget');
    p_village3          := hcm_util.get_string_t(json_obj, 'village3');
    p_village4          := hcm_util.get_string_t(json_obj, 'village4');
    p_village5          := hcm_util.get_string_t(json_obj, 'village5');
    p_codsubdist        := hcm_util.get_string_t(json_obj, 'codsubdist');
    p_coddist           := hcm_util.get_string_t(json_obj, 'coddist');
    p_codprovr          := hcm_util.get_string_t(json_obj, 'codprovr');
    p_numacdsd          := hcm_util.get_string_t(json_obj, 'numacdsd');
    p_numcotax          := hcm_util.get_string_t(json_obj, 'numcotax');
    p_buildinge         := hcm_util.get_string_t(json_obj, 'buildinge');
    p_buildingt         := hcm_util.get_string_t(json_obj, 'buildingt');
    p_building3         := hcm_util.get_string_t(json_obj, 'building3');
    p_building4         := hcm_util.get_string_t(json_obj, 'building4');
    p_building5         := hcm_util.get_string_t(json_obj, 'building5');
    p_roomnoe           := hcm_util.get_string_t(json_obj, 'roomnoe');
    p_roomnot           := hcm_util.get_string_t(json_obj, 'roomnot');
    p_roomno3           := hcm_util.get_string_t(json_obj, 'roomno3');
    p_roomno4           := hcm_util.get_string_t(json_obj, 'roomno4');
    p_roomno5           := hcm_util.get_string_t(json_obj, 'roomno5');
    p_floore            := hcm_util.get_string_t(json_obj, 'floore');
    p_floort            := hcm_util.get_string_t(json_obj, 'floort');
    p_floor3            := hcm_util.get_string_t(json_obj, 'floor3');
    p_floor4            := hcm_util.get_string_t(json_obj, 'floor4');
    p_floor5            := hcm_util.get_string_t(json_obj, 'floor5');
    p_namimgcover       := hcm_util.get_string_t(json_obj, 'namimgcover');
    p_namimgmobi        := hcm_util.get_string_t(json_obj, 'namimgmobi');
    p_welcomemsge       := hcm_util.get_string_t(json_obj, 'welcomemsge');
    p_welcomemsgt       := hcm_util.get_string_t(json_obj, 'welcomemsgt');
    p_welcomemsg3       := hcm_util.get_string_t(json_obj, 'welcomemsg3');
    p_welcomemsg4       := hcm_util.get_string_t(json_obj, 'welcomemsg4');
    p_welcomemsg5       := hcm_util.get_string_t(json_obj, 'welcomemsg5');
    p_typbusiness       := hcm_util.get_string_t(json_obj, 'typbusiness');
    p_ageretrf          := hcm_util.get_string_t(json_obj, 'ageretrf');
    p_ageretrm          := hcm_util.get_string_t(json_obj, 'ageretrm');
    p_contmsge          := hcm_util.get_string_t(json_obj, 'contmsge');
    p_contmsgt          := hcm_util.get_string_t(json_obj, 'contmsgt');
    p_contmsg3          := hcm_util.get_string_t(json_obj, 'contmsg3');
    p_contmsg4          := hcm_util.get_string_t(json_obj, 'contmsg4');
    p_contmsg5          := hcm_util.get_string_t(json_obj, 'contmsg5');
    p_compgrp           := hcm_util.get_string_t(json_obj, 'compgrp');
    -- save_index
    param_json          := hcm_util.get_json_t(json_obj, 'param_json');

    -- report
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_secur AS
  v_tcompny number;
  begin
    select count(codcompy)
    into v_tcompny
    from tcompny
    where codcompy = p_codcompy;
    if v_tcompny > 0 then
      if not secur_main.secur7(p_codcompy, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
  end;
  procedure check_save AS
    v_numseq          tsetcomp.numseq%type;
    v_qtycode         tsetcomp.qtycode%type;
  begin
    select numseq,qtycode
    into v_numseq, v_qtycode
    from tsetcomp
    where numseq = 1;
    if LENGTH(p_codcompy) != v_qtycode then
      param_msg_error := replace(get_error_msg_php('CO0001', global_v_lang),'[P-DIGITS]',v_qtycode);
      return;
    end if;
    if length(p_zipcode) != 5 then
      param_msg_error := get_error_msg_php('HR6591', global_v_lang,'zipcode');
      return;
    end if;
    if length(p_numtele) > 30 then
      param_msg_error := get_error_msg_php('HR6591', global_v_lang,'numtele');
      return;
    end if;
    if length(p_numfax) > 20 then
      param_msg_error := get_error_msg_php('HR6591', global_v_lang,'numfax');
      return;
    end if;
    if length(p_email) > 50 then
      param_msg_error := get_error_msg_php('HR6591', global_v_lang,'email');
      return;
    end if;
    if length(p_website) > 50 then
      param_msg_error := get_error_msg_php('HR6591', global_v_lang,'website');
      return;
    end if;

    if length(p_numcotax) > 13 then
      param_msg_error := get_error_msg_php('HR6591', global_v_lang,'numcotax');
      return;
    end if;
    if length(p_numacsoc) > 10 then
      param_msg_error := get_error_msg_php('HR6591', global_v_lang,'numacsoc');
      return;
    end if;
    if length(p_numacdsd) > 50 then
      param_msg_error := get_error_msg_php('HR6591', global_v_lang,'numacdsd');
      return;
    end if;
    if length(p_descomp) > 500 then
      param_msg_error := get_error_msg_php('HR6591', global_v_lang,'descomp');
      return;
    end if;
    if p_codcompy = p_compgrp then
      param_msg_error := get_error_msg_php('CO0038', global_v_lang);
      return;
    end if;
  exception when others then
    null;
  end;

  procedure check_process AS
  begin
    if p_ageretrf is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang,'ageretrf');
      return;
    end if;
    if p_ageretrf is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang,'ageretrf');
      return;
    end if;
  exception when others then
    null;
  end;

  procedure check_dteeffec_detail AS
    v_dteeffec TPDPAITEM.dteeffec%type;
    v_chkExist number;
    v_chkExtPdpa number;
    v_chkImprov number;
  begin
    p_dteeffec_tmp := p_dteeffec;
    p_flgChkDteeff := false;
    begin
      select count(*) into v_chkExist
      from TPDPAITEM
      where codcompy = p_codcompy;
    end;
    if v_chkExist = 0 then
      p_flgChkDteeff := false;
    else
      if p_dteeffec is null then
        begin
          select max(dteeffec)
            into p_dteeffec
            from TPDPAITEM
           where codcompy = p_codcompy
             and dteeffec <= trunc(sysdate)
             and rownum = 1;
        exception when no_data_found then
          null;
        end;
        if p_dteeffec < trunc(sysdate) then
            p_flgChkDteeff := true;
        else
          p_flgChkDteeff := false;
        end if;
        -- check improve
        if p_dteeffec = trunc(sysdate) then
          begin
            select count(*) into v_chkImprov
            from tempconst
            where codcompy = p_codcompy
            and dteeffec = p_dteeffec;
          end;
          if v_chkImprov > 0 then
            p_flgChkDteeff := true;
          end if;
        end if;
      else
        if p_dteeffec_tmp < trunc(sysdate) then
          begin
            select max(dteeffec)
              into p_dteeffec
              from TPDPAITEM
             where codcompy = p_codcompy
               and dteeffec <= p_dteeffec_tmp
               and rownum = 1;
          exception when no_data_found then
            null;
          end;
          p_flgChkDteeff := true;
        elsif p_dteeffec_tmp = trunc(sysdate) then
          begin
            select max(dteeffec)
              into p_dteeffec
              from TPDPAITEM
             where codcompy = p_codcompy
               and dteeffec <= trunc(sysdate)
               and rownum = 1;
          exception when no_data_found then
            null;
          end;
          if p_dteeffec_tmp <> p_dteeffec then
            p_flgAdd := true;
          end if;
          if p_isAfterSave = 'Y' then
            select count(*) into v_chkExtPdpa
              from TPDPAITEM
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec_tmp;
            --
            if v_chkExtPdpa = 0 then
              p_flgAdd := false;
            end if;
            if p_dteeffec < trunc(sysdate) then
              p_flgAfterSave := true;
            end if;
            --
          end if;
        elsif p_dteeffec_tmp > trunc(sysdate) then
          select count(*) into v_chkExtPdpa
            from TPDPAITEM
           where codcompy = p_codcompy
             and dteeffec = p_dteeffec_tmp;
          if v_chkExtPdpa = 0 then
            begin
              select max(dteeffec)
                into p_dteeffec
                from TPDPAITEM
               where codcompy = p_codcompy
                 and dteeffec <= p_dteeffec_tmp
                 and rownum = 1;
            exception when no_data_found then
              null;
            end;
            if p_dteeffec_tmp <> p_dteeffec then
              p_flgAdd := true;
            end if;
          end if;
          if p_isAfterSave = 'Y' then
            select count(*) into v_chkExtPdpa
              from TPDPAITEM
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec_tmp;
            --
            if v_chkExtPdpa = 0 then
              p_flgAdd := false;
            end if;
            if p_dteeffec < trunc(sysdate) then
              p_flgAfterSave := true;
            end if;
            --
          end if;
        end if;
        -- check improve
        if p_dteeffec_tmp = trunc(sysdate) then
          begin
            select count(*) into v_chkImprov
            from tempconst
            where codcompy = p_codcompy
            and dteeffec = p_dteeffec_tmp;
          end;
          if v_chkImprov > 0 then
            p_flgChkDteeff := true;
            p_errorno := 'PM0090';
          end if;
        end if;
      end if;
    end if;
  exception when others then
    null;
  end;

  procedure check_dteeffec AS
    v_dteeffec TPDPAITEM.dteeffec%type;
    v_chkExist number;
    v_chkExtPdpa number;
    v_chkImprov number;
  begin
    p_dteeffec_tmp := p_dteeffec;
    p_flgChkDteeff := false;
    begin
      select count(*) into v_chkExist
      from TPDPAITEM
      where codcompy = p_codcompy;
    end;
    if v_chkExist = 0 then
      p_flgChkDteeff := false;
    else
      if p_dteeffec is null then
        begin
          select max(dteeffec)
            into p_dteeffec
            from TPDPAITEM
           where codcompy = p_codcompy
             and dteeffec <= trunc(sysdate)
             and rownum = 1;
        exception when no_data_found then
          null;
        end;
        if p_dteeffec < trunc(sysdate) then
            p_flgChkDteeff := true;
        else
          p_flgChkDteeff := false;
        end if;
        -- check improve
        if p_dteeffec = trunc(sysdate) then
          begin
            select count(*) into v_chkImprov
            from tempconst
            where codcompy = p_codcompy
            and dteeffec = p_dteeffec;
          end;
          if v_chkImprov > 0 then
            p_flgChkDteeff := true;
          end if;
        end if;
      else
        if p_dteeffec_tmp < trunc(sysdate) then
          begin
            select max(dteeffec)
              into p_dteeffec
              from TPDPAITEM
             where codcompy = p_codcompy
               and dteeffec <= p_dteeffec_tmp
               and rownum = 1;
          exception when no_data_found then
            null;
          end;
          p_flgChkDteeff := true;
        elsif p_dteeffec_tmp = trunc(sysdate) then
          begin
            select max(dteeffec)
              into p_dteeffec
              from TPDPAITEM
             where codcompy = p_codcompy
               and dteeffec <= trunc(sysdate)
               and rownum = 1;
          exception when no_data_found then
            null;
          end;
          if p_dteeffec_tmp <> p_dteeffec then
            p_flgAdd := true;
          end if;
        elsif p_dteeffec_tmp > trunc(sysdate) then
          select count(*) into v_chkExtPdpa
            from TPDPAITEM
           where codcompy = p_codcompy
             and dteeffec = p_dteeffec_tmp;
          if v_chkExtPdpa = 0 then
            begin
              select max(dteeffec)
                into p_dteeffec
                from TPDPAITEM
               where codcompy = p_codcompy
                 and dteeffec <= p_dteeffec_tmp
                 and rownum = 1;
            exception when no_data_found then
              null;
            end;
            if p_dteeffec_tmp <> p_dteeffec then
              p_flgAdd := true;
            end if;
          end if;
        end if;
        -- check improve
        if p_dteeffec_tmp = trunc(sysdate) then
          begin
            select count(*) into v_chkImprov
            from tempconst
            where codcompy = p_codcompy
            and dteeffec = p_dteeffec_tmp;
          end;
          if v_chkImprov > 0 then
            p_flgChkDteeff := true;
            p_errorno := 'PM0090';
          end if;
        end if;
        -- save case after save
--        if p_flgTab3NotEdit then
--          p_dteeffec := p_dteeffec_tmp;
--          p_flgChkDteeff := false;
--        end if;
      end if;
    end if;
  exception when others then
    null;
  end;

  procedure get_index (json_str_input in clob,json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    gen_index(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index (json_str_output out clob) AS
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgsecu       boolean := false;
    cursor c1 is
      select namimgcom, codcompy
        from tcompny
      order by codcompy ;
  begin
    obj_row           := json_object_t();

    for r1 in c1 loop
      v_rcnt          := v_rcnt+1;
      obj_data        := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('namcom', get_tcompny_name(r1.codcompy, global_v_lang));
      obj_data.put('logo', r1.namimgcom);
      obj_data.put('logo_image', '/'||get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRCO01E1')||'/'||r1.namimgcom);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END gen_index;

  procedure get_detail (json_str_input in clob,json_str_output out clob) AS
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
--    check_secur;
    check_save;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
       json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) AS
    obj_data        json_object_t;
    obj_pdpa        json_object_t;
    v_tcompny       tcompny%rowtype;
    v_namcom        tcompny.namcome%type;
    v_namst         tcompny.namste%type;
    v_adrcom        tcompny.adrcome%type;
    v_addrno        tcompny.addrnoe%type;
    v_soi           tcompny.soie%type;
    v_moo           tcompny.mooe%type;
    v_road          tcompny.roade%type;
    v_village       tcompny.villagee%type;
    v_building      tcompny.buildinge%type;
    v_roomno        tcompny.roomnoe%type;
    v_floor         tcompny.floore%type;
    v_welcomemsg    tcompny.welcomemsge%type;
    v_contmsg       tcompny.contmsge%type;
  begin
    begin
      select  *
        into v_tcompny
        from tcompny
       where codcompy = p_codcompy;
      select  decode(global_v_lang, '101', namcome,
                                    '102', namcomt,
                                    '103', namcom3,
                                    '104', namcom4,
                                    '105', namcom5,
                                    namcome),
              decode(global_v_lang, '101', namste,
                                    '102', namstt,
                                    '103', namst3,
                                    '104', namst4,
                                    '105', namst5,
                                    namste),
              decode(global_v_lang, '101', adrcome,
                                    '102', adrcomt,
                                    '103', adrcom3,
                                    '104', adrcom4,
                                    '105', adrcom5,
                                    adrcome),
              decode(global_v_lang, '101', addrnoe,
                                    '102', addrnot,
                                    '103', addrno3,
                                    '104', addrno4,
                                    '105', addrno5,
                                    addrnoe),
              decode(global_v_lang, '101', soie,
                                    '102', soit,
                                    '103', soi3,
                                    '104', soi4,
                                    '105', soi5,
                                    soie),
              decode(global_v_lang, '101', mooe,
                                    '102', moot,
                                    '103', moo3,
                                    '104', moo4,
                                    '105', moo5,
                                    mooe),
              decode(global_v_lang, '101', roade,
                                    '102', roadt,
                                    '103', road3,
                                    '104', road4,
                                    '105', road5,
                                    roade),
              decode(global_v_lang, '101', villagee,
                                    '102', villaget,
                                    '103', village3,
                                    '104', village4,
                                    '105', village5,
                                    villagee),
              decode(global_v_lang, '101', buildinge,
                                    '102', buildingt,
                                    '103', building3,
                                    '104', building4,
                                    '105', building5,
                                    buildinge),
              decode(global_v_lang, '101', roomnoe,
                                    '102', roomnot,
                                    '103', roomno3,
                                    '104', roomno4,
                                    '105', roomno5,
                                    roomnoe),
              decode(global_v_lang, '101', floore,
                                    '102', floort,
                                    '103', floor3,
                                    '104', floor4,
                                    '105', floor5,
                                    floore),
              decode(global_v_lang, '101', welcomemsge,
                                    '102', welcomemsgt,
                                    '103', welcomemsg3,
                                    '104', welcomemsg4,
                                    '105', welcomemsg5,
                                    welcomemsge),
              decode(global_v_lang, '101', contmsge,
                                    '102', contmsgt,
                                    '103', contmsg3,
                                    '104', contmsg4,
                                    '105', contmsg5,
                                    welcomemsge)
        into v_namcom, v_namst, v_adrcom, v_addrno, v_soi, v_moo, v_road, v_village, v_building, v_roomno, v_floor, v_welcomemsg,v_contmsg
        from tcompny
       where codcompy = p_codcompy;
    exception when no_data_found then
      null;
    end;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcompy', p_codcompy);
      obj_data.put('namcom', v_namcom);
      obj_data.put('namcome', v_tcompny.namcome);
      obj_data.put('namcomt', v_tcompny.namcomt);
      obj_data.put('namcom3', v_tcompny.namcom3);
      obj_data.put('namcom4', v_tcompny.namcom4);
      obj_data.put('namcom5', v_tcompny.namcom5);
      obj_data.put('namst', v_namst);
      obj_data.put('namste', v_tcompny.namste);
      obj_data.put('namstt', v_tcompny.namstt);
      obj_data.put('namst3', v_tcompny.namst3);
      obj_data.put('namst4', v_tcompny.namst4);
      obj_data.put('namst5', v_tcompny.namst5);
      obj_data.put('adrcom', v_adrcom);
      obj_data.put('adrcome', v_tcompny.adrcome);
      obj_data.put('adrcomt', v_tcompny.adrcomt);
      obj_data.put('adrcom3', v_tcompny.adrcom3);
      obj_data.put('adrcom4', v_tcompny.adrcom4);
      obj_data.put('adrcom5', v_tcompny.adrcom5);
      obj_data.put('numtele', v_tcompny.numtele);
      obj_data.put('numfax', v_tcompny.numfax);
      obj_data.put('numcotax', v_tcompny.numcotax);
      obj_data.put('descomp', v_tcompny.descomp);
      obj_data.put('numacsoc', v_tcompny.numacsoc);
      obj_data.put('zipcode', v_tcompny.zipcode);
      obj_data.put('email', v_tcompny.email);
      obj_data.put('website', v_tcompny.website);
      obj_data.put('comimage', v_tcompny.comimage);
      obj_data.put('namimgcom', v_tcompny.namimgcom);
      obj_data.put('namimgmap', v_tcompny.namimgmap);
      obj_data.put('addrno', v_addrno);
      obj_data.put('addrnoe', v_tcompny.addrnoe);
      obj_data.put('addrnot', v_tcompny.addrnot);
      obj_data.put('addrno3', v_tcompny.addrno3);
      obj_data.put('addrno4', v_tcompny.addrno4);
      obj_data.put('addrno5', v_tcompny.addrno5);
      obj_data.put('soi', v_soi);
      obj_data.put('soie', v_tcompny.soie);
      obj_data.put('soit', v_tcompny.soit);
      obj_data.put('soi3', v_tcompny.soi3);
      obj_data.put('soi4', v_tcompny.soi4);
      obj_data.put('soi5', v_tcompny.soi5);
      obj_data.put('moo', v_moo);
      obj_data.put('mooe', v_tcompny.mooe);
      obj_data.put('moot', v_tcompny.moot);
      obj_data.put('moo3', v_tcompny.moo3);
      obj_data.put('moo4', v_tcompny.moo4);
      obj_data.put('moo5', v_tcompny.moo5);
      obj_data.put('road', v_road);
      obj_data.put('roade', v_tcompny.roade);
      obj_data.put('roadt', v_tcompny.roadt);
      obj_data.put('road3', v_tcompny.road3);
      obj_data.put('road4', v_tcompny.road4);
      obj_data.put('road5', v_tcompny.road5);
      obj_data.put('village', v_village);
      obj_data.put('villagee', v_tcompny.villagee);
      obj_data.put('villaget', v_tcompny.villaget);
      obj_data.put('village3', v_tcompny.village3);
      obj_data.put('village4', v_tcompny.village4);
      obj_data.put('village5', v_tcompny.village5);
      obj_data.put('codsubdist', v_tcompny.codsubdist);
      obj_data.put('coddist', v_tcompny.coddist);
      obj_data.put('codprovr', v_tcompny.codprovr);
      obj_data.put('numacdsd', v_tcompny.numacdsd);
--      obj_data.put('numcotax', v_tcompny.numcotax);
      obj_data.put('building', v_building);
      obj_data.put('buildinge', v_tcompny.buildinge);
      obj_data.put('buildingt', v_tcompny.buildingt);
      obj_data.put('building3', v_tcompny.building3);
      obj_data.put('building4', v_tcompny.building4);
      obj_data.put('building5', v_tcompny.building5);
      obj_data.put('roomno', v_roomno);
      obj_data.put('roomnoe', v_tcompny.roomnoe);
      obj_data.put('roomnot', v_tcompny.roomnot);
      obj_data.put('roomno3', v_tcompny.roomno3);
      obj_data.put('roomno4', v_tcompny.roomno4);
      obj_data.put('roomno5', v_tcompny.roomno5);
      obj_data.put('floor', v_floor);
      obj_data.put('floore', v_tcompny.floore);
      obj_data.put('floort', v_tcompny.floort);
      obj_data.put('floor3', v_tcompny.floor3);
      obj_data.put('floor4', v_tcompny.floor4);
      obj_data.put('floor5', v_tcompny.floor5);
      obj_data.put('namimgcover', v_tcompny.namimgcover);
      obj_data.put('welcomemsg', v_welcomemsg);
      obj_data.put('welcomemsge', v_tcompny.welcomemsge);
      obj_data.put('welcomemsgt', v_tcompny.welcomemsgt);
      obj_data.put('welcomemsg3', v_tcompny.welcomemsg3);
      obj_data.put('welcomemsg4', v_tcompny.welcomemsg4);
      obj_data.put('welcomemsg5', v_tcompny.welcomemsg5);
      obj_data.put('typbusiness', v_tcompny.typbusiness);
      obj_data.put('ageretrf', v_tcompny.ageretrf);
      obj_data.put('ageretrm', v_tcompny.ageretrm);
      obj_data.put('contmsg', v_contmsg);
      obj_data.put('contmsge', v_tcompny.contmsge);
      obj_data.put('contmsgt', v_tcompny.contmsgt);
      obj_data.put('contmsg3', v_tcompny.contmsg3);
      obj_data.put('contmsg4', v_tcompny.contmsg4);
      obj_data.put('contmsg5', v_tcompny.contmsg5);
      obj_data.put('compgrp', v_tcompny.compgrp);
      obj_data.put('codlang', global_v_lang);
      obj_pdpa := json_object_t();
      check_dteeffec_detail;
      obj_pdpa := get_policy(p_codcompy);
      obj_data.put('dteeff', to_char(p_dteeffec,'dd/mm/yyyy'));
      obj_data.put('flgChkDteeff', p_flgChkDteeff);
      obj_data.put('flgAfterSave', p_flgAfterSave);
      obj_data.put('table', obj_pdpa);

      obj_data.put('dteupd', to_char(v_tcompny.dteupd, 'dd/mm/yyyy'));
      obj_data.put('coduser', v_tcompny.coduser);
      obj_data.put('codimage', get_codempid(v_tcompny.coduser));
      obj_data.put('desc_coduser', v_tcompny.coduser || ' - ' || get_temploy_name(get_codempid(v_tcompny.coduser), global_v_lang));

      obj_data.put('namimgmobi', v_tcompny.namimgmobi);
    if isInsertReport then
      insert_ttemprpt(obj_data);
    end if;
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END gen_detail;

  procedure gen_detail_PDPA (json_str_output out clob) AS
    obj_data        json_object_t;
    obj_pdpa        json_object_t;
    v_isCopy        varchar2(2 char);
  begin
      obj_data    := json_object_t();
      obj_pdpa := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('msgerror', '');

      check_dteeffec;
      obj_pdpa := get_policy(p_codcompy);
      obj_data.put('table', obj_pdpa);
      obj_data.put('flgChkDteeff', p_flgChkDteeff);
      if p_dteeffec_tmp < trunc(sysdate) then
        obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
      else
        obj_data.put('dteeffec', to_char(p_dteeffec_tmp,'dd/mm/yyyy'));
      end if;
      if p_flgChkDteeff then
        if p_errorno is not null then
          obj_data.put('msgerror', replace(get_error_msg_php(p_errorno,global_v_lang),'@#$%400',''));
        else
          obj_data.put('msgerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',''));
        end if;
      end if;
      json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END gen_detail_PDPA;

  procedure get_detail_PDPA (json_str_input in clob,json_str_output out clob) AS
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_PDPA(json_str_output);
    else
       json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_PDPA;

  function get_policy(v_codcompy in varchar2) return json_object_t is
    v_out_json    json_object_t;
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_codcomp     temploy1.codcomp%type;
    v_rcnt         number := 0;
    cursor c1 is
      select codcompy,dteeffec,numitem,desobjte,desobjtt,desobjt3,desobjt4,desobjt5,desiteme,desitemt,desitem3,desitem4,desitem5,
             decode(global_v_lang,'101',desobjte ,'102',desobjtt ,'103',desobjt3 ,'104',desobjt4 ,'105',desobjt5) as desobjt, 
             decode(global_v_lang,'101',desiteme ,'102',desitemt ,'103',desitem3 ,'104',desitem4 ,'105',desitem5) as desitem 
        from TPDPAITEM
       where codcompy = v_codcompy
       and dteeffec = p_dteeffec
       order by codcompy,numitem;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_rcnt          := v_rcnt+1;
      obj_data        := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numitem', r1.numitem);
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
      obj_data.put('desobjt', nvl(r1.desobjt,'') );
      obj_data.put('desobjte', nvl(r1.desobjte,'') );
      obj_data.put('desobjtt', nvl(r1.desobjtt,'') );
      obj_data.put('desobjt3', nvl(r1.desobjt3,'') );
      obj_data.put('desobjt4', nvl(r1.desobjt4,'') );
      obj_data.put('desobjt5', nvl(r1.desobjt5,'') );
      obj_data.put('desitem', nvl(r1.desitem,'') );
      obj_data.put('desiteme', nvl(r1.desiteme,'') );
      obj_data.put('desitemt', nvl(r1.desitemt,'') );
      obj_data.put('desitem3', nvl(r1.desitem3,'') );
      obj_data.put('desitem4', nvl(r1.desitem4,'') );
      obj_data.put('desitem5', nvl(r1.desitem5,'') );
      obj_data.put('flgAdd', p_flgAdd );
--      obj_data.put('logo', r1.namimgcom);
--      obj_data.put('logo_image', '/'||get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRCO01E1')||'/'||r1.namimgcom);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;
    return obj_row;
  end get_policy;

  procedure gen_popupPdpa (json_str_output out clob) AS
    obj_data        json_object_t;
    obj_pdpa        json_object_t;
    v_desobjt       tpdpaitem.desobjte%type;
    v_desobjte      tpdpaitem.desobjte%type;
    v_desobjtt      tpdpaitem.desobjtt%type;
    v_desobjt3      tpdpaitem.desobjt3%type;
    v_desobjt4      tpdpaitem.desobjt4%type;
    v_desobjt5      tpdpaitem.desobjt5%type;
    v_desitem       tpdpaitem.desiteme%type;
    v_desiteme      tpdpaitem.desiteme%type;
    v_desitemt      tpdpaitem.desitemt%type;
    v_desitem3      tpdpaitem.desitem3%type;
    v_desitem4      tpdpaitem.desitem4%type;
    v_desitem5      tpdpaitem.desitem5%type;
  begin
    begin
      select desobjte, desobjtt, desobjt3, desobjt4, desobjt5, desiteme, desitemt, desitem3, desitem4, desitem5,
             decode(global_v_lang,'101',desobjte ,'102',desobjtt ,'103',desobjt3 ,'104',desobjt4 ,'105',desobjt5) as desobjt, 
             decode(global_v_lang,'101',desiteme ,'102',desitemt ,'103',desitem3 ,'104',desitem4 ,'105',desitem5) as desitem 
        into v_desobjte, v_desobjtt, v_desobjt3, v_desobjt4, v_desobjt5, v_desiteme, v_desitemt, v_desitem3, v_desitem4, v_desitem5,
             v_desobjt, v_desitem
        from tpdpaitem
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec
         and numitem = p_numseq;
    exception when no_data_found then
      null;
    end;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numitem', p_numseq);
      obj_data.put('desobjt', nvl(v_desobjt,'') );
      obj_data.put('desobjte', nvl(v_desobjte,'') );
      obj_data.put('desobjtt', nvl(v_desobjtt,'') );
      obj_data.put('desobjt3', nvl(v_desobjt3,'') );
      obj_data.put('desobjt4', nvl(v_desobjt4,'') );
      obj_data.put('desobjt5', nvl(v_desobjt5,'') );
      obj_data.put('desitem', nvl(v_desitem,'') );
      obj_data.put('desiteme', nvl(v_desiteme,'') );
      obj_data.put('desitemt', nvl(v_desitemt,'') );
      obj_data.put('desitem3', nvl(v_desitem3,'') );
      obj_data.put('desitem4', nvl(v_desitem4,'') );
      obj_data.put('desitem5', nvl(v_desitem5,'') );
      json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END gen_popupPdpa;

  procedure popupPdpa (json_str_input in clob,json_str_output out clob) AS
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popupPdpa(json_str_output);
    else
       json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end popupPdpa;

  procedure gen_list_pdpa (json_str_output out clob) AS
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgsecu       boolean := false;
    cursor c1 is
      select distinct dteeffec
        from tpdpaitem
       where codcompy = p_codcompy
       order by dteeffec ;
  begin
    obj_row           := json_object_t();
    for r1 in c1 loop
      v_rcnt          := v_rcnt+1;
      obj_data        := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcompy', p_codcompy);
      obj_data.put('desc_codcompy', get_tcenter_name(p_codcompy,global_v_lang));
      obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END gen_list_pdpa;

  procedure list_pdpa (json_str_input in clob,json_str_output out clob) AS
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_list_pdpa(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end list_pdpa;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    obj_data          json_object_t;
    v_codcompy        tcompny.codcompy%type;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        if param_msg_error is null then
          obj_data        := hcm_util.get_json_t(param_json, to_char(i));
          v_codcompy      := hcm_util.get_string_t(obj_data, 'codcompy');
          begin
            delete tcompny
            where codcompy = v_codcompy;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
          end;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2425', global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;

  procedure save_data(json_str_input in clob, json_str_output out clob) is
    v_desshifte         varchar2(150 char);
    v_desshiftt         varchar2(150 char);
    v_desshift3         varchar2(150 char);
    v_desshift4         varchar2(150 char);
    v_desshift5         varchar2(150 char);
    type codcomtype     is table of varchar2(100 char) index by binary_integer;
    arr_codcomp         codcomtype;
    v_codcomp           tcenter.codcomp%type;
    v_numrec            number;

    v_adrcome tcompny.adrcome%type;
    v_adrcomt tcompny.adrcomt%type;
    v_adrcom3 tcompny.adrcom3%type;
    v_adrcom4 tcompny.adrcom4%type;
    v_adrcom5 tcompny.adrcom5%type;

    v_buildinge varchar2(200 char);
    v_buildingt varchar2(200 char);
    v_building3 varchar2(200 char);
    v_building4 varchar2(200 char);
    v_building5 varchar2(200 char);

    v_roomnoe varchar2(200 char);
    v_roomnot varchar2(200 char);
    v_roomno3 varchar2(200 char);
    v_roomno4 varchar2(200 char);
    v_roomno5 varchar2(200 char);

    v_floore varchar2(200 char);
    v_floort varchar2(200 char);
    v_floor3 varchar2(200 char);
    v_floor4 varchar2(200 char);
    v_floor5 varchar2(200 char);

    v_villagee varchar2(200 char);
    v_villaget varchar2(200 char);
    v_village3 varchar2(200 char);
    v_village4 varchar2(200 char);
    v_village5 varchar2(200 char);

    v_addrnoe varchar2(200 char);
    v_addrnot varchar2(200 char);
    v_addrno3 varchar2(200 char);
    v_addrno4 varchar2(200 char);
    v_addrno5 varchar2(200 char);

    v_mooe 		varchar2(200 char);
    v_moot 		varchar2(200 char);
    v_moo3 		varchar2(200 char);
    v_moo4 		varchar2(200 char);
    v_moo5 		varchar2(200 char);

    v_soie 		varchar2(200 char);
    v_soit 		varchar2(200 char);
    v_soi3 		varchar2(200 char);
    v_soi4 		varchar2(200 char);
    v_soi5 		varchar2(200 char);

    v_roade 	varchar2(200 char);
    v_roadt 	varchar2(200 char);
    v_road3 	varchar2(200 char);
    v_road4 	varchar2(200 char);
    v_road5 	varchar2(200 char);

    v_subdise  varchar2(200 char);
    v_subdist  varchar2(200 char);
    v_subdis3  varchar2(200 char);
    v_subdis4  varchar2(200 char);
    v_subdis5  varchar2(200 char);

    v_dise     varchar2(200 char);
    v_dist     varchar2(200 char);
    v_dis3     varchar2(200 char);
    v_dis4     varchar2(200 char);
    v_dis5     varchar2(200 char);

    v_prove    varchar2(200 char);
    v_provt    varchar2(200 char);
    v_prov3    varchar2(200 char);
    v_prov4    varchar2(200 char);
    v_prov5    varchar2(200 char);


    v_codapp    varchar2(10 char) := 'HRCO01EC2';

    obj_data    json_object_t;
    v_flg       varchar2(10 char);
    v_numseq       tpdpaitem.numitem%type;
    v_desobjte      tpdpaitem.desobjte%type;
    v_desobjtt      tpdpaitem.desobjtt%type;
    v_desobjt3      tpdpaitem.desobjt3%type;
    v_desobjt4      tpdpaitem.desobjt4%type;
    v_desobjt5      tpdpaitem.desobjt5%type;
    v_desiteme      tpdpaitem.desiteme%type;
    v_desitemt      tpdpaitem.desitemt%type;
    v_desitem3      tpdpaitem.desitem3%type;
    v_desitem4      tpdpaitem.desitem4%type;
    v_desitem5      tpdpaitem.desitem5%type;
    cursor c_tsetcomp is
      select numseq, qtycode
        from tsetcomp
       order by numseq, qtycode;

  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
      begin

        v_buildinge := case when p_buildinge is not null then get_label_name(v_codapp,'101','50') || ' ' || p_buildinge || ' ' else '' end;
        v_buildingt := case when p_buildingt is not null then get_label_name(v_codapp,'102','50') || ' ' || p_buildingt || ' ' else '' end;
        v_building3 := case when p_building3 is not null then get_label_name(v_codapp,'103','50') || ' ' || p_building3 || ' ' else '' end;
        v_building4 := case when p_building4 is not null then get_label_name(v_codapp,'104','50') || ' ' || p_building4 || ' ' else '' end;
        v_building5 := case when p_building5 is not null then get_label_name(v_codapp,'105','50') || ' ' || p_building5 || ' ' else '' end;

        v_roomnoe := case when p_roomnoe is not null then get_label_name(v_codapp,'101','60') || ' ' || p_roomnoe || ' ' else '' end;
        v_roomnot := case when p_roomnot is not null then get_label_name(v_codapp,'102','60') || ' ' || p_roomnot || ' ' else '' end;
        v_roomno3 := case when p_roomno3 is not null then get_label_name(v_codapp,'103','60') || ' ' || p_roomno3 || ' ' else '' end;
        v_roomno4 := case when p_roomno4 is not null then get_label_name(v_codapp,'104','60') || ' ' || p_roomno4 || ' ' else '' end;
        v_roomno5 := case when p_roomno5 is not null then get_label_name(v_codapp,'105','60') || ' ' || p_roomno5 || ' ' else '' end;

        v_floore := case when p_floore is not null then get_label_name(v_codapp,'101','70') || ' ' || p_floore || ' ' else '' end;
        v_floort := case when p_floort is not null then get_label_name(v_codapp,'102','70') || ' ' || p_floort || ' ' else '' end;
        v_floor3 := case when p_floor3 is not null then get_label_name(v_codapp,'103','70') || ' ' || p_floor3 || ' ' else '' end;
        v_floor4 := case when p_floor4 is not null then get_label_name(v_codapp,'104','70') || ' ' || p_floor4 || ' ' else '' end;
        v_floor5 := case when p_floor5 is not null then get_label_name(v_codapp,'105','70') || ' ' || p_floor5 || ' ' else '' end;

        v_villagee := case when p_villagee is not null then get_label_name(v_codapp,'101','80') || ' ' || p_villagee || ' ' else '' end;
        v_villaget := case when p_villaget is not null then get_label_name(v_codapp,'102','80') || ' ' || p_villaget || ' ' else '' end;
        v_village3 := case when p_village3 is not null then get_label_name(v_codapp,'103','80') || ' ' || p_village3 || ' ' else '' end;
        v_village4 := case when p_village4 is not null then get_label_name(v_codapp,'104','80') || ' ' || p_village4 || ' ' else '' end;
        v_village5 := case when p_village5 is not null then get_label_name(v_codapp,'105','80') || ' ' || p_village5 || ' ' else '' end;

        v_addrnoe := case when p_addrnoe is not null then get_label_name(v_codapp,'101','90') || ' ' || p_addrnoe || ' ' else '' end;
        v_addrnot := case when p_addrnot is not null then get_label_name(v_codapp,'102','90') || ' ' || p_addrnot || ' ' else '' end;
        v_addrno3 := case when p_addrno3 is not null then get_label_name(v_codapp,'103','90') || ' ' || p_addrno3 || ' ' else '' end;
        v_addrno4 := case when p_addrno4 is not null then get_label_name(v_codapp,'104','90') || ' ' || p_addrno4 || ' ' else '' end;
        v_addrno5 := case when p_addrno5 is not null then get_label_name(v_codapp,'105','90') || ' ' || p_addrno5 || ' ' else '' end;

        v_mooe := case when p_mooe is not null then get_label_name(v_codapp,'101','100') || ' ' || p_mooe || ' ' else '' end;
        v_moot := case when p_moot is not null then get_label_name(v_codapp,'102','100') || ' ' || p_moot || ' ' else '' end;
        v_moo3 := case when p_moo3 is not null then get_label_name(v_codapp,'103','100') || ' ' || p_moo3 || ' ' else '' end;
        v_moo4 := case when p_moo4 is not null then get_label_name(v_codapp,'104','100') || ' ' || p_moo4 || ' ' else '' end;
        v_moo5 := case when p_moo5 is not null then get_label_name(v_codapp,'105','100') || ' ' || p_moo5 || ' ' else '' end;

        v_soie := case when p_soie is not null then get_label_name(v_codapp,'101','110') || ' ' || p_soie || ' ' else '' end;
        v_soit := case when p_soit is not null then get_label_name(v_codapp,'102','110') || ' ' || p_soit || ' ' else '' end;
        v_soi3 := case when p_soi3 is not null then get_label_name(v_codapp,'103','110') || ' ' || p_soi3 || ' ' else '' end;
        v_soi4 := case when p_soi4 is not null then get_label_name(v_codapp,'104','110') || ' ' || p_soi4 || ' ' else '' end;
        v_soi5 := case when p_soi5 is not null then get_label_name(v_codapp,'105','110') || ' ' || p_soi5 || ' ' else '' end;

        v_roade := case when p_roade is not null then get_label_name(v_codapp,'101','120') || ' ' || p_roade || ' ' else '' end;
        v_roadt := case when p_roadt is not null then get_label_name(v_codapp,'102','120') || ' ' || p_roadt || ' ' else '' end;
        v_road3 := case when p_road3 is not null then get_label_name(v_codapp,'103','120') || ' ' || p_road3 || ' ' else '' end;
        v_road4 := case when p_road4 is not null then get_label_name(v_codapp,'104','120') || ' ' || p_road4 || ' ' else '' end;
        v_road5 := case when p_road5 is not null then get_label_name(v_codapp,'105','120') || ' ' || p_road5 || ' ' else '' end;


        if p_codprovr = '1000' then
          v_subdise := get_label_name(v_codapp,'101','260') || ' ' || get_tsubdist_name(p_codsubdist,'101') || ' ';
          v_subdist := get_label_name(v_codapp,'102','260') || ' ' || get_tsubdist_name(p_codsubdist,'102') || ' ';
          v_subdis3 := get_label_name(v_codapp,'103','260') || ' ' || get_tsubdist_name(p_codsubdist,'103') || ' ';
          v_subdis4 := get_label_name(v_codapp,'104','260') || ' ' || get_tsubdist_name(p_codsubdist,'104') || ' ';
          v_subdis5 := get_label_name(v_codapp,'105','260') || ' ' || get_tsubdist_name(p_codsubdist,'105') || ' ';
        else
          v_subdise := get_label_name(v_codapp,'101','250') || ' ' || get_tsubdist_name(p_codsubdist,'101') || ' ';
          v_subdist := get_label_name(v_codapp,'102','250') || ' ' || get_tsubdist_name(p_codsubdist,'102') || ' ';
          v_subdis3 := get_label_name(v_codapp,'103','250') || ' ' || get_tsubdist_name(p_codsubdist,'103') || ' ';
          v_subdis4 := get_label_name(v_codapp,'104','250') || ' ' || get_tsubdist_name(p_codsubdist,'104') || ' ';
          v_subdis5 := get_label_name(v_codapp,'105','250') || ' ' || get_tsubdist_name(p_codsubdist,'105') || ' ';
        end if;

        if p_codprovr = '1000' then
          v_dise := get_label_name(v_codapp,'101','240') || ' ' || get_tcoddist_name(p_coddist,'101') || ' ';
          v_dist := get_label_name(v_codapp,'102','240') || ' ' || get_tcoddist_name(p_coddist,'102') || ' ';
          v_dis3 := get_label_name(v_codapp,'103','240') || ' ' || get_tcoddist_name(p_coddist,'103') || ' ';
          v_dis4 := get_label_name(v_codapp,'104','240') || ' ' || get_tcoddist_name(p_coddist,'104') || ' ';
          v_dis5 := get_label_name(v_codapp,'105','240') || ' ' || get_tcoddist_name(p_coddist,'105') || ' ';
        else
          v_dise := get_label_name(v_codapp,'101','230') || ' ' || get_tcoddist_name(p_coddist,'101') || ' ';
          v_dist := get_label_name(v_codapp,'102','230') || ' ' || get_tcoddist_name(p_coddist,'102') || ' ';
          v_dis3 := get_label_name(v_codapp,'103','230') || ' ' || get_tcoddist_name(p_coddist,'103') || ' ';
          v_dis4 := get_label_name(v_codapp,'104','230') || ' ' || get_tcoddist_name(p_coddist,'104') || ' ';
          v_dis5 := get_label_name(v_codapp,'105','230') || ' ' || get_tcoddist_name(p_coddist,'105') || ' ';
        end if;

        v_prove := get_label_name(v_codapp,'101','140') || ' ' || get_tcodec_name('TCODPROV', p_codprovr,'101');
        v_provt := get_label_name(v_codapp,'102','140') || ' ' || get_tcodec_name('TCODPROV', p_codprovr,'102');
        v_prov3 := get_label_name(v_codapp,'103','140') || ' ' || get_tcodec_name('TCODPROV', p_codprovr,'103');
        v_prov4 := get_label_name(v_codapp,'104','140') || ' ' || get_tcodec_name('TCODPROV', p_codprovr,'104');
        v_prov5 := get_label_name(v_codapp,'105','140') || ' ' || get_tcodec_name('TCODPROV', p_codprovr,'105');

        v_adrcome := v_buildinge || v_roomnoe || v_floore || v_villagee || v_addrnoe || v_mooe || v_soie || v_roade || v_subdise || v_dise || v_prove;
        v_adrcomt := v_buildingt || v_roomnot || v_floort || v_villaget || v_addrnot || v_moot || v_soit || v_roadt || v_subdist || v_dist || v_provt;
        v_adrcom3 := v_building3 || v_roomno3 || v_floor3 || v_village3 || v_addrno3 || v_moo3 || v_soi3 || v_road3 || v_subdis3 || v_dis3 || v_prov3;
        v_adrcom4 := v_building4 || v_roomno4 || v_floor4 || v_village4 || v_addrno4 || v_moo4 || v_soi4 || v_road4 || v_subdis4 || v_dis4 || v_prov4;
        v_adrcom5 := v_building5 || v_roomno5 || v_floor5 || v_village5 || v_addrno5 || v_moo5 || v_soi5 || v_road5 || v_subdis5 || v_dis5 || v_prov5;

        insert into tcompny
        (codcompy, namcome, namcomt, namcom3, namcom4, namcom5, namste, namstt, namst3, namst4, namst5,
        adrcome, adrcomt, adrcom3, adrcom4, adrcom5, numtele, numfax, /*numcotax,*/
        descomp, numacsoc, zipcode, email, website, comimage, namimgcom, namimgmap,
        addrnoe, addrnot, addrno3, addrno4, addrno5, soie, soit, soi3, soi4, soi5,
        mooe, moot, moo3, moo4, moo5, roade, roadt, road3, road4, road5,
        villagee, villaget, village3, village4, village5, codsubdist, coddist, codprovr,
        numacdsd, buildinge, buildingt, building3, building4, building5,
        roomnoe, roomnot, roomno3, roomno4, roomno5, floore, floort, floor3, floor4, floor5,
        namimgcover, welcomemsge, welcomemsgt, welcomemsg3, welcomemsg4, welcomemsg5, typbusiness,
        ageretrf, ageretrm, contmsge, contmsgt, contmsg3, contmsg4, contmsg5, compgrp, codcreate, coduser,
        namimgmobi)
        values
        (p_codcompy, p_namcome, p_namcomt, p_namcom3, p_namcom4, p_namcom5, p_namste, p_namstt, p_namst3, p_namst4, p_namst5,
        v_adrcome, v_adrcomt, v_adrcom3, v_adrcom4, v_adrcom5, p_numtele, p_numfax, /*p_numcotax,*/
        p_descomp, p_numacsoc, p_zipcode, p_email, p_website, p_comimage, p_namimgcom, p_namimgmap,
        p_addrnoe, p_addrnot, p_addrno3, p_addrno4, p_addrno5, p_soie, p_soit, p_soi3, p_soi4, p_soi5,
        p_mooe, p_moot, p_moo3, p_moo4, p_moo5, p_roade, p_roadt, p_road3, p_road4, p_road5,
        p_villagee, p_villaget, p_village3, p_village4, p_village5, p_codsubdist, p_coddist, p_codprovr,
        p_numacdsd, p_buildinge, p_buildingt, p_building3, p_building4, p_building5,
        p_roomnoe, p_roomnot, p_roomno3, p_roomno4, p_roomno5, p_floore, p_floort, p_floor3, p_floor4, p_floor5,
        p_namimgcover, p_welcomemsge, p_welcomemsgt, p_welcomemsg3, p_welcomemsg4, p_welcomemsg5, p_typbusiness,
        p_ageretrf, p_ageretrm,p_contmsge, p_contmsgt, p_contmsg3, p_contmsg4, p_contmsg5, p_compgrp, global_v_coduser, global_v_coduser,
        p_namimgmobi);
      exception when dup_val_on_index then
        update  tcompny
            set  namcome = p_namcome,
                namcomt = p_namcomt,
                namcom3 = p_namcom3,
                namcom4 = p_namcom4,
                namcom5 = p_namcom5,
                namste = p_namste,
                namstt = p_namstt,
                namst3 = p_namst3,
                namst4 = p_namst4,
                namst5 = p_namst5,
                adrcome = v_adrcome,
                adrcomt = v_adrcomt,
                adrcom3 = v_adrcom3,
                adrcom4 = v_adrcom4,
                adrcom5 = v_adrcom5,
                numtele = p_numtele,
                numfax = p_numfax,
                numcotax = p_numcotax,
                descomp = p_descomp,
                numacsoc = p_numacsoc,
                zipcode = p_zipcode,
                email = p_email,
                website = p_website,
                comimage = p_comimage,
                namimgcom = p_namimgcom,
                namimgmap = p_namimgmap,
                addrnoe = p_addrnoe,
                addrnot = p_addrnot,
                addrno3 = p_addrno3,
                addrno4 = p_addrno4,
                addrno5 = p_addrno5,
                soie = p_soie,
                soit = p_soit,
                soi3 = p_soi3,
                soi4 = p_soi4,
                soi5 = p_soi5,
                mooe = p_mooe,
                moot = p_moot,
                moo3 = p_moo3,
                moo4 = p_moo4,
                moo5 = p_moo5,
                roade = p_roade,
                roadt = p_roadt,
                road3 = p_road3,
                road4 = p_road4,
                road5 = p_road5,
                villagee = p_villagee,
                villaget = p_villaget,
                village3 = p_village3,
                village4 = p_village4,
                village5 = p_village5,
                codsubdist = p_codsubdist,
                coddist = p_coddist,
                codprovr = p_codprovr,
                numacdsd = p_numacdsd,
                buildinge = p_buildinge,
                buildingt = p_buildingt,
                building3 = p_building3,
                building4 = p_building4,
                building5 = p_building5,
                roomnoe = p_roomnoe,
                roomnot = p_roomnot,
                roomno3 = p_roomno3,
                roomno4 = p_roomno4,
                roomno5 = p_roomno5,
                floore = p_floore,
                floort = p_floort,
                floor3 = p_floor3,
                floor4 = p_floor4,
                floor5 = p_floor5,
                namimgcover = p_namimgcover,
                welcomemsge = p_welcomemsge,
                welcomemsgt = p_welcomemsgt,
                welcomemsg3 = p_welcomemsg3,
                welcomemsg4 = p_welcomemsg4,
                welcomemsg5 = p_welcomemsg5,
                typbusiness = p_typbusiness,
                ageretrf    = p_ageretrf,
                ageretrm    = p_ageretrm,
                contmsge = p_contmsge,
                contmsgt = p_contmsgt,
                contmsg3 = p_contmsg3,
                contmsg4 = p_contmsg4,
                contmsg5 = p_contmsg5,
                compgrp = p_compgrp,
                coduser = global_v_coduser,
                namimgmobi = p_namimgmobi
          where codcompy = p_codcompy;
      end;
      v_numrec := 0;
      for i in 1..10 loop
        arr_codcomp(i) := null;
      end loop;
      v_codcomp := '';
      for i in c_tsetcomp loop
         if i.numseq = 1 then
            arr_codcomp(1) := p_codcompy;
            v_codcomp      := p_codcompy;
         elsif (nvl(i.qtycode, 0) <> 0) then
            arr_codcomp(i.numseq) := lpad(0, nvl(i.qtycode, 0), '0');
            v_codcomp             := v_codcomp || lpad(0, nvl(i.qtycode, 0), '0');
         else
            arr_codcomp(i.numseq) := null;
         end if;
      end loop;
      begin
        select count(*)
          into v_numrec
          from tcenter
         where codcomp = v_codcomp;
      exception when no_data_found then
          v_numrec :=0;
      end;
      if v_numrec = 0 then
        begin
          insert into tcenter
                (
                  codcompy, codcom1, codcom2, codcom3, codcom4, codcom5, codcom6, codcom7, codcom8, codcom9, codcom10,
                  codcomp, namcente, namcentt, namcent3, namcent4, namcent5, comlevel, flgact, codcreate)
            values
                (
                  p_codcompy, arr_codcomp(1), arr_codcomp(2), arr_codcomp(3), arr_codcomp(4), arr_codcomp(5), arr_codcomp(6), arr_codcomp(7), arr_codcomp(8), arr_codcomp(9), arr_codcomp(10),
                  v_codcomp, p_namcome, p_namcomt, p_namcom3, p_namcom4, p_namcom5, 1, '1', global_v_coduser
                );
        exception when dup_val_on_index then
          null;
        end;
      else
        begin
          update tcenter
             set  codcompy = p_codcompy,
                  codcom1  = arr_codcomp(1),
                  codcom2  = arr_codcomp(2),
                  codcom3  = arr_codcomp(3),
                  codcom4  = arr_codcomp(4),
                  codcom5  = arr_codcomp(5),
                  codcom6  = arr_codcomp(6),
                  codcom7  = arr_codcomp(7),
                  codcom8  = arr_codcomp(8),
                  codcom9  = arr_codcomp(9),
                  codcom10 = arr_codcomp(10),
                  namcente = p_namcome,
                  namcentt = p_namcomt,
                  namcent3 = p_namcom3,
                  namcent4 = p_namcom4,
                  namcent5 = p_namcom5,
                  comlevel = 1,
                  flgact   = '1',
                  coduser  = global_v_coduser
            where codcomp = v_codcomp;
        end;
      end if;

      --
      for i in 0..param_json.get_size-1 loop
        obj_data    := hcm_util.get_json_t(param_json, to_char(i));
        v_flg       := hcm_util.get_string_t(obj_data, 'flg');
        v_numseq    := hcm_util.get_string_t(obj_data, 'numitem');
        v_desobjte      := hcm_util.get_string_t(obj_data, 'desobjte');
        v_desobjtt      := hcm_util.get_string_t(obj_data, 'desobjtt');
        v_desobjt3      := hcm_util.get_string_t(obj_data, 'desobjt3');
        v_desobjt4      := hcm_util.get_string_t(obj_data, 'desobjt4');
        v_desobjt5      := hcm_util.get_string_t(obj_data, 'desobjt5');
        v_desiteme      := hcm_util.get_string_t(obj_data, 'desiteme');
        v_desitemt      := hcm_util.get_string_t(obj_data, 'desitemt');
        v_desitem3      := hcm_util.get_string_t(obj_data, 'desitem3');
        v_desitem4      := hcm_util.get_string_t(obj_data, 'desitem4');
        v_desitem5      := hcm_util.get_string_t(obj_data, 'desitem5');

        if v_numseq is null then
          begin
            select nvl(max(numitem),0) + 1 into v_numseq
              from tpdpaitem
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec;
          exception when no_data_found then
            v_numseq := 1;
          end;
        end if;
        if v_flg = 'add' or v_flg = 'edit' then
          begin
            insert into tpdpaitem (codcompy,dteeffec,numitem,
                                  desobjte,desobjtt,desobjt3,desobjt4,desobjt5,
                                  desiteme,desitemt,desitem3,desitem4,desitem5,codcreate)
              values ( p_codcompy, p_dteeffec, v_numseq, v_desobjte, v_desobjtt, v_desobjt3, v_desobjt4, v_desobjt5, 
                       v_desiteme, v_desitemt, v_desitem3, v_desitem4, v_desitem5, global_v_coduser);
          exception when dup_val_on_index then
            update tpdpaitem 
              set desobjte = v_desobjte,
                  desobjtt = v_desobjtt,
                  desobjt3 = v_desobjt3,
                  desobjt4 = v_desobjt4,
                  desobjt5 = v_desobjt5,
                  desiteme = v_desiteme,
                  desitemt = v_desitemt,
                  desitem3 = v_desitem3,
                  desitem4 = v_desitem4,
                  desitem5 = v_desitem5
            where codcompy = p_codcompy 
            and dteeffec = p_dteeffec
            and numitem = v_numseq;
          end;
        elsif v_flg = 'delete' then
          begin
            delete tpdpaitem 
             where codcompy = p_codcompy 
               and dteeffec = p_dteeffec
               and numitem = v_numseq;
          end;
        end if;
      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_data;

  procedure process_dteretire(json_str_input in clob, json_str_output out clob) is
    cursor c_temploy1 is
        select codempid ,dteretire ,codsex ,dteempdb
          from temploy1
         where codcomp like p_codcompy||'%'
           and staemp <> '9';
    v_error varchar2(4000);
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        if (p_ageretrf is null and p_ageretrm is null) then
            v_error := get_label_name('HRCO01EC3', global_v_lang, '160')||'/'||get_label_name('HRCO01EC3', global_v_lang, '170');
            param_msg_error := get_error_msg_php('HR2045',global_v_lang,v_error);
        else
            for r1 in c_temploy1 loop
                if r1.dteempdb is not null then
                    if r1.codsex = 'M' and p_ageretrm is not null then
                        update temploy1
                           set dteretire = trunc(add_months(r1.dteempdb,(12* p_ageretrm ))) - 1
                         where codempid = r1.codempid;
                    elsif r1.codsex = 'F' and p_ageretrf is not null then
                        update temploy1
                           set dteretire = trunc(add_months(r1.dteempdb,(12*  p_ageretrf ))) - 1
                         where codempid = r1.codempid;
                    end if;
                end if;
                commit;
            end loop;
        end if;
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
  end process_dteretire;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    param_json          := hcm_util.get_json_t(json_obj, 'param_json');
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..param_json.get_size-1 loop
        p_codcompy := hcm_util.get_string_t(param_json, to_char(i));
        p_dteeffec := null;
        gen_detail(json_output);
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
         and codapp   like p_codapp||'%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt(obj_data in json_object_t) is
    obj_rprt            json_object_t;
    param_rprt          json_object_t;
    v_numseq            number := 0;
    v_desc_codprov      varchar2(4000 char) := '';
    v_desc_codsubdist   varchar2(4000 char) := '';
    v_desc_coddist      varchar2(4000 char) := '';
    v_namimgcover       tcompny.namimgcover%type;
    v_namimgcom         tcompny.namimgcom%type;
    v_namimgmap         tcompny.namimgmap%type;
    v_namimgmobi        tcompny.namimgmobi%type;
    v_codcompy        varchar2(4000 char);
    v_namcom          varchar2(4000 char);
    v_namst           varchar2(4000 char);
    v_adrcom          varchar2(4000 char);
    v_numtele         varchar2(4000 char);
    v_numfax          varchar2(4000 char);
    v_numcotax        varchar2(4000 char);
    v_descomp         varchar2(4000 char);
    v_numacsoc        varchar2(4000 char);
    v_zipcode         varchar2(4000 char);
    v_email           varchar2(4000 char);
    v_website         varchar2(4000 char);
    v_comimage        varchar2(4000 char);
    v_addrno          varchar2(4000 char);
    v_soi             varchar2(4000 char);
    v_moo             varchar2(4000 char);
    v_road            varchar2(4000 char);
    v_village         varchar2(4000 char);
    v_building        varchar2(4000 char);
    v_roomno          varchar2(4000 char);
    v_floor           varchar2(4000 char);
    v_welcomemsg      varchar2(4000 char);
    v_coduser         varchar2(4000 char);
    v_typbusiness     varchar2(4000 char);
    v_contmsg         tcompny.contmsge%type;
    v_codprovr        varchar2(4000 char);
    v_coddist         varchar2(4000 char);
    v_codsubdist        tcompny.codsubdist%type;
    v_compgrp           tcompny.compgrp%type;
    v_numacdsd          tcompny.numacdsd%type;
    v_ageretrf          tcompny.ageretrf%type;
    v_ageretrm          tcompny.ageretrm%type;
    v_dteeffec          varchar2(100 char);
    v_numitem           number;
    numYearReport       number;
    v_desobjt           varchar2(4000 char);
    v_desitem           varchar2(4000 char);
  begin
    p_codapp := 'HRCO01E';
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
    v_codprovr := hcm_util.get_string_t(obj_data, 'codprovr');
    begin
      select decode(global_v_lang,'101',DESCODE
                                   ,'102',DESCODT
                                   ,'103',DESCOD3
                                   ,'104',DESCOD4
                                   ,'105',DESCOD5) as DESCOD
        into v_desc_codprov
        from tcodprov
        where codcodec = v_codprovr;
    exception when no_data_found then
      v_desc_codprov := '';
    end;

    v_coddist := hcm_util.get_string_t(obj_data, 'coddist');
    begin
      select decode(global_v_lang,'101',NAMDISTE
                                   ,'102',NAMDISTT
                                   ,'103',NAMDIST3
                                   ,'104',NAMDIST4
                                   ,'105',NAMDIST5) as DESCODDIST
        into v_desc_coddist
        from tcoddist
        where coddist = v_coddist;
    exception when no_data_found then
      v_desc_coddist := '';
    end;
    v_codsubdist := hcm_util.get_string_t(obj_data, 'codsubdist');
    begin
      select decode(global_v_lang,'101',NAMSUBDISTE
                                   ,'102',NAMSUBDISTT
                                   ,'103',NAMSUBDIST3
                                   ,'104',NAMSUBDIST4
                                   ,'105',NAMSUBDIST5) as DESCODSUBDIST
        into v_desc_codsubdist
        from tsubdist
        where codsubdist = v_codsubdist;
    exception when no_data_found then
      v_desc_codsubdist := '';
    end;

    v_codcompy := hcm_util.get_string_t(obj_data, 'codcompy');
    begin
      select get_tfolderd('HRCO01E1')||'/'||namimgcom, 
             get_tfolderd('HRCO01E2')||'/'||namimgcover, 
             get_tfolderd('HRCO01E3')||'/'||namimgmap,
             get_tfolderd('HRCO01E2')||'/'||namimgmobi
       into v_namimgcom, v_namimgcover, v_namimgmap, v_namimgmobi
       from tcompny
       where codcompy = v_codcompy;
    exception when no_data_found then
      null;
    end;
    --
    v_codcompy    := nvl(hcm_util.get_string_t(obj_data, 'codcompy'), '');
    v_namcom      := nvl(hcm_util.get_string_t(obj_data, 'namcom'), '');
    v_namst       := nvl(hcm_util.get_string_t(obj_data, 'namst'), '');
    v_adrcom      := nvl(hcm_util.get_string_t(obj_data, 'adrcom'), '');
    v_numtele     := nvl(hcm_util.get_string_t(obj_data, 'numtele'), '');
    v_numfax      := nvl(hcm_util.get_string_t(obj_data, 'numfax'), '');
    v_numcotax    := nvl(hcm_util.get_string_t(obj_data, 'numcotax'), '');
    v_descomp     := nvl(hcm_util.get_string_t(obj_data, 'descomp'), '');
    v_numacsoc    := nvl(hcm_util.get_string_t(obj_data, 'numacsoc'), '');
    v_zipcode     := nvl(hcm_util.get_string_t(obj_data, 'zipcode'), '');
    v_email       := nvl(hcm_util.get_string_t(obj_data, 'email'), '');
    v_website     := nvl(hcm_util.get_string_t(obj_data, 'website'), '');
    v_comimage    := nvl(hcm_util.get_string_t(obj_data, 'comimage'), '');
    v_addrno      := nvl(hcm_util.get_string_t(obj_data, 'addrno'), '');
    v_soi         := nvl(hcm_util.get_string_t(obj_data, 'soi'), '');
    v_moo         := nvl(hcm_util.get_string_t(obj_data, 'moo'), '');
    v_road        := nvl(hcm_util.get_string_t(obj_data, 'road'), '');
    v_village     := nvl(hcm_util.get_string_t(obj_data, 'village'), '');
    v_numacdsd    := nvl(hcm_util.get_string_t(obj_data, 'numacdsd'), '');
    v_building    := nvl(hcm_util.get_string_t(obj_data, 'building'), '');
    v_roomno      := nvl(hcm_util.get_string_t(obj_data, 'roomno'), '');
    v_floor       := nvl(hcm_util.get_string_t(obj_data, 'floor'), '');
    v_welcomemsg  := nvl(hcm_util.get_string_t(obj_data, 'welcomemsg'), '');
    v_coduser     := nvl(hcm_util.get_string_t(obj_data, 'coduser'), '');
    v_typbusiness := nvl(hcm_util.get_string_t(obj_data, 'typbusiness'), '');
    v_contmsg     := nvl(hcm_util.get_string_t(obj_data, 'contmsg'), '');
    v_compgrp     := nvl(hcm_util.get_string_t(obj_data, 'compgrp'), '');
    v_ageretrf      := nvl(hcm_util.get_string_t(obj_data, 'ageretrf'), '');
    v_ageretrm      := nvl(hcm_util.get_string_t(obj_data, 'ageretrm'), '');
    v_dteeffec      := nvl(hcm_util.get_string_t(obj_data, 'dteeff'), '');
    numYearReport   := HCM_APPSETTINGS.get_additional_year();
    v_dteeffec      := to_char(add_months(to_date(v_dteeffec,'dd/mm/yyyy'), numYearReport*12),'dd/mm/yyyy');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5,
             item6, item7, item8, item9, item10,
             item11, item12, item13, item14, item15,
             item16, item17, item18, item19, item20,
             item21, item22, item23, item24, item25,
             item26,item27,item28,item29,item30,item31, item32,
             CLOB1,item33,item34,temp1,temp2,item35
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             v_codcompy, v_namcom, v_namst, v_adrcom, v_numtele,
             v_numfax, v_numcotax, v_descomp, v_numacsoc, v_zipcode,
             v_email,
             v_website,
             v_comimage,
             nvl(v_namimgcom, ''),
             nvl(v_namimgmap, ''),
             v_addrno,
             v_soi,
             v_moo,
             v_road,
             v_village,
             v_numacdsd,
             nvl(v_desc_codprov, ''),
             nvl(v_desc_codsubdist, ''),
             nvl(v_desc_coddist, ''),
             v_numcotax,
             v_building,
             v_roomno,
             v_floor,
             v_welcomemsg,
             nvl(v_namimgcover, ''),
             v_coduser,
             v_typbusiness,
             regexp_replace(v_contmsg, '<.*?>'),
             v_compgrp || ' - '||get_tcodec_name('TCOMPGRP',v_compgrp,global_v_lang),
             v_dteeffec,
             v_ageretrm,
             v_ageretrf,
             nvl(v_namimgmobi, '')
           );
    end;
    p_codapp := 'HRCO01E2';
    begin
      select nvl(max(numseq), 0) + 1
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    param_rprt := hcm_util.get_json_t(obj_data, 'table');
    for i in 0..param_rprt.get_size-1 loop
      obj_rprt        := hcm_util.get_json_t(param_rprt, to_char(i));
      v_numitem       := to_number(hcm_util.get_string_t(obj_rprt, 'numitem'));
      v_desobjt       := hcm_util.get_string_t(obj_rprt, 'desobjt');
      v_desitem       := hcm_util.get_string_t(obj_rprt, 'desitem');
      begin
        insert
          into ttemprpt (codempid, codapp, numseq,
                         item1, item2, item3)
        values ( global_v_codempid, p_codapp, v_numseq,
                 v_codcompy, v_numitem, v_desobjt);
      exception when others then
        null;
      end;
      v_numseq := v_numseq + 1;
    end loop;
  end insert_ttemprpt;
END HRCO01E;

/

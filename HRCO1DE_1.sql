--------------------------------------------------------
--  DDL for Package Body HRCO1DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO1DE" AS
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

    p_roomno            := upper(hcm_util.get_string_t(json_obj, 'p_roomno'));
    json_param          := hcm_util.get_json_t(json_obj, 'saveParams');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure gen_index (json_str_output out clob) AS
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgsecu       boolean := false;
    v_chkExist      varchar2(1 char);
    cursor c1 is
      select ROOMNO,FLOOR,BUILDING,QTYPERS,STATUS,
             decode(global_v_lang, '101', roomname,
                                    '102', roomnamt,
                                    '103', roomnam3,
                                    '104', roomnam4,
                                    '105', roomnam5) roomnam
        from tcodroom
      order by roomno ;
  begin
    obj_row           := json_object_t();

    for r1 in c1 loop
      v_rcnt          := v_rcnt+1;
      obj_data        := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('roomno', r1.ROOMNO);
      obj_data.put('roomnam', r1.roomnam);
      obj_data.put('floor', r1.FLOOR);
      obj_data.put('building', r1.BUILDING);
      obj_data.put('qtypers', r1.QTYPERS);
      obj_data.put('status', r1.STATUS);
      if r1.status = 'A' then
        obj_data.put('desc_status', get_label_name('HRCO1DE2',global_v_lang,120));
      else
        obj_data.put('desc_status', get_label_name('HRCO1DE2',global_v_lang,130));
      end if;
      begin
        select 'Y' into v_chkExist
        from TROOMREQ
        where roomno = r1.ROOMNO
        and rownum = 1;
      exception when no_data_found then
        v_chkExist := 'N';  
      end;
      obj_data.put('flgTroomreq', v_chkExist);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END gen_index;

  procedure get_index (json_str_input in clob,json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    gen_index(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure gen_detail (json_str_output out clob) AS
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgsecu       boolean := false;
    v_chkExist      varchar2(1 char);
    v_roomnam       tcodroom.roomname%type;
    v_roomname      tcodroom.roomname%type;
    v_roomnamt      tcodroom.roomnamt%type;
    v_roomnam3      tcodroom.roomnam3%type;
    v_roomnam4      tcodroom.roomnam4%type;
    v_roomnam5      tcodroom.roomnam5%type;
    v_floor         tcodroom.floor%type;
    v_building      tcodroom.building%type;
    v_remark        tcodroom.remark%type;
    v_accessori     tcodroom.accessori%type;
    v_qtypers       tcodroom.qtypers%type;
    v_status        tcodroom.status%type;
    v_codrespon1        tcodroom.codrespon1%type;
    v_namimgroom        tcodroom.namimgroom%type;
    v_codrespon2        tcodroom.codrespon2%type;

  begin
    obj_row           := json_object_t();
    begin
    select roomname,roomnamt,roomnam3,roomnam4,roomnam5,floor,building,remark,accessori,qtypers,status,codrespon1,namimgroom,codrespon2,
           decode(global_v_lang,'101', roomname,
                                '102', roomnamt,
                                '103', roomnam3,
                                '104', roomnam4,
                                '105', roomnam5) roomnam
        into v_roomname,v_roomnamt,v_roomnam3,v_roomnam4,v_roomnam5,v_floor,v_building,v_remark,v_accessori,v_qtypers,v_status,v_codrespon1,v_namimgroom,v_codrespon2,v_roomnam
        from tcodroom
        where roomno = p_roomno;
    exception when no_data_found then
      null;
    end;

    obj_data        := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('roomno', p_roomno);
    obj_data.put('roomnam', v_roomnam);
    obj_data.put('roomname', v_roomnam);
    obj_data.put('roomnamt', v_roomnamt);
    obj_data.put('roomnam3', v_roomnam3);
    obj_data.put('roomnam4', v_roomnam4);
    obj_data.put('roomnam5', v_roomnam5);
    obj_data.put('floor', v_floor);
    obj_data.put('building', v_building);
    obj_data.put('qtypers', v_qtypers);
    obj_data.put('namimgroom', v_namimgroom);
    obj_data.put('accessori', v_accessori);
    obj_data.put('remark', v_remark);
    obj_data.put('status', v_status);
    obj_data.put('codrespon1', v_codrespon1);
    obj_data.put('codrespon2', v_codrespon2);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END gen_detail;

  procedure get_detail (json_str_input in clob,json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    gen_detail(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure check_save is
    error_secur VARCHAR2(4000 CHAR);
  begin
    p_codrespon1    := hcm_util.get_string_t(json_param, 'codrespon1');
    p_codrespon2    := hcm_util.get_string_t(json_param, 'codrespon2');

    if p_codrespon1 = p_codrespon2 then
      param_msg_error := get_error_msg_php('CO0040',global_v_lang);
      return;
    end if;
  end;
  procedure update_tcodroom is
    v_numrec number;
  begin
    p_roomno              := upper(hcm_util.get_string_t(json_param, 'roomno'));
    p_roomname            := hcm_util.get_string_t(json_param, 'roomname');
    p_roomnamt            := hcm_util.get_string_t(json_param, 'roomnamt');
    p_roomnam3            := hcm_util.get_string_t(json_param, 'roomnam3');
    p_roomnam4            := hcm_util.get_string_t(json_param, 'roomnam4');
    p_roomnam5            := hcm_util.get_string_t(json_param, 'roomnam5');
    p_floor               := hcm_util.get_string_t(json_param, 'floor');
    p_building            := hcm_util.get_string_t(json_param, 'building');
    p_qtypers             := hcm_util.get_string_t(json_param, 'qtypers');
    p_namimgroom          := hcm_util.get_string_t(json_param, 'namimgroom');
    p_accessori           := hcm_util.get_string_t(json_param, 'accessori');
    p_remark              := hcm_util.get_string_t(json_param, 'remark');
    p_status              := hcm_util.get_string_t(json_param, 'status');
    p_codrespon1          := hcm_util.get_string_t(json_param, 'codrespon1');
    p_codrespon2          := hcm_util.get_string_t(json_param, 'codrespon2');
   begin
    SELECT Count (*)  into v_numrec
      from tcodroom
     where roomno = p_roomno;
   end;
    if v_numrec = 0 then 
        insert into tcodroom (ROOMNO,ROOMNAME,ROOMNAMT,ROOMNAM3,ROOMNAM4,ROOMNAM5,
                              FLOOR,BUILDING,REMARK,ACCESSORI,QTYPERS,STATUS,
                              CODRESPON1,NAMIMGROOM,CODRESPON2,CODCREATE,CODUSER)
                       values (p_roomno, p_roomname, p_roomnamt, p_roomnam3, p_roomnam4, p_roomnam5,
                       p_floor, p_building, p_remark, p_accessori, p_qtypers, p_status, p_codrespon1, p_namimgroom, p_codrespon2,
                       global_v_coduser, global_v_coduser);
    else
        begin
          update tcodroom
          set roomname    = p_roomname,
              roomnamt    = p_roomnamt,
              roomnam3    = p_roomnam3,
              roomnam4    = p_roomnam4,
              roomnam5    = p_roomnam5,
              floor       = p_floor,
              building    = p_building,
              remark      = p_remark,
              accessori   = p_accessori,
              qtypers     = p_qtypers,
              status      = p_status,
              codrespon1  = p_codrespon1,
              namimgroom  = p_namimgroom,
              codrespon2  = p_codrespon2,
              dteupd      = sysdate,
              coduser     = global_v_coduser
          where roomno = p_roomno;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          rollback;
        end;    
    end if;
  end;
  procedure save_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_save();
    if param_msg_error is null then
      update_tcodroom();
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  procedure delete_index(json_str_input in clob,json_str_output out clob) is
    param_json_row  json_object_t;
    json_obj        json_object_t;
    v_flg           varchar2(10 char);
    v_numlereq      tlereqst.numlereq%type;
  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    json_param          := hcm_util.get_json_t(json_obj, 'param_json');
    for i in 0..json_param.get_size-1 loop null;
      param_json_row  := hcm_util.get_json_t(json_param,to_char(i));
      v_flg           := hcm_util.get_string_t(param_json_row,'flg');
      p_roomno        := hcm_util.get_string_t(param_json_row,'roomno');
      if v_flg = 'delete' then
        delete tcodroom where roomno = p_roomno;
      end if;
    end loop;
    commit;
    param_msg_error := get_error_msg_php('HR2425',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end delete_index;
END HRCO1DE;

/

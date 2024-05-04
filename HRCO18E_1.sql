--------------------------------------------------------
--  DDL for Package Body HRCO18E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO18E" AS
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin

    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    param_msg_error     := '';
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codtency          := hcm_util.get_string_t(json_obj,'codtency');
    p_namtncy           := hcm_util.get_string_t(json_obj,'namtncy');
    p_namtncye          := hcm_util.get_string_t(json_obj,'namtncye');
    p_namtncyt          := hcm_util.get_string_t(json_obj,'namtncyt');
    p_namtncy3          := hcm_util.get_string_t(json_obj,'namtncy3');
    p_namtncy4          := hcm_util.get_string_t(json_obj,'namtncy4');
    p_namtncy5          := hcm_util.get_string_t(json_obj,'namtncy5');

    p_codskill           := hcm_util.get_string_t(json_obj,'codskill');
    p_descod            := hcm_util.get_string_t(json_obj,'descod');
    p_descode           := hcm_util.get_string_t(json_obj,'descode');
    p_descodt           := hcm_util.get_string_t(json_obj,'descodt');
    p_descod3           := hcm_util.get_string_t(json_obj,'descod3');
    p_descod4           := hcm_util.get_string_t(json_obj,'descod4');
    p_descod5           := hcm_util.get_string_t(json_obj,'descod5');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure check_save is
    error_secur VARCHAR2(4000 CHAR);
    v_codtency          TCOMPSKIL.CODTENCY%TYPE;
  begin
    if p_codtency is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_codtency');
      return;
    end if;
    if p_namtncy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_namtncy');
      return;
    end if;
    if p_codskill is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_codskill');
      return;
    end if;
    if p_descod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_descod');
      return;
    end if;
    begin
      select codtency into v_codtency
      from   tcompskil
      where  codtency <> p_codtency
      and    codskill = p_codskill
      and rownum = 1;
    exception when no_data_found then
      v_codtency := '';
    end;
    if v_codtency is not null then
      param_msg_error := get_error_msg_php('CO0010',global_v_lang,'TCOMPSKIL');
      return;
    end if;
  end;
  --
  procedure check_save_tcomptnc is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codtency is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_codtency');
      return;
    end if;
    if p_namtncy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_namtncy');
      return;
    end if;
  end;
  --
  procedure gen_tcomptnc (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt      number  := 0;
     cursor c1 is
        select CODTENCY,NAMTNCYE,NAMTNCYT,NAMTNCY3,NAMTNCY4,NAMTNCY5,
               decode(global_v_lang,'101',NAMTNCYE
                                   ,'102',NAMTNCYT
                                   ,'103',NAMTNCY3
                                   ,'104',NAMTNCY4
                                   ,'105',NAMTNCY5) as NAMTNCY
        from tcomptnc
        order by CODTENCY;
  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;
    for i in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codtency', i.CODTENCY);
      obj_data.put('namtncy', i.NAMTNCY);
      obj_data.put('namtncye', i.NAMTNCYE);
      obj_data.put('namtncyt', i.NAMTNCYT);
      obj_data.put('namtncy3', i.NAMTNCY3);
      obj_data.put('namtncy4', i.NAMTNCY4);
      obj_data.put('namtncy5', i.NAMTNCY5);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_tcomptnc (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_tcomptnc(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_tcompskil (json_str_output out clob) is
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
        from tcodskil
        where CODCODEC IN (select codskill from tcompskil where codtency = p_codtency)
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
  end;
  --
  procedure get_tcompskil (json_str_input in clob,json_str_output out clob) is

  begin
    initial_value(json_str_input);
    gen_tcompskil(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_gradskil (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt      number  := 0;
     cursor c1 is
        select CODSKILL,GRADE,NAMGRADE,NAMGRADT,NAMGRAD3,NAMGRAD4,NAMGRAD5,
               decode(global_v_lang,'101',NAMGRADE
                                   ,'102',NAMGRADT
                                   ,'103',NAMGRAD3
                                   ,'104',NAMGRAD4
                                   ,'105',NAMGRAD5) as namgrad
        from tskilscor
        where CODSKILL = p_codskill
        order by CODSKILL;
  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;
    for i in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codskill', i.CODSKILL);
      obj_data.put('grade', i.GRADE);
      obj_data.put('namgrad', i.namgrad);
      obj_data.put('namgrade', i.NAMGRADE);
      obj_data.put('namgradt', i.NAMGRADT);
      obj_data.put('namgrad3', i.NAMGRAD3);
      obj_data.put('namgrad4', i.NAMGRAD4);
      obj_data.put('namgrad5', i.NAMGRAD5);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_gradskil (json_str_input in clob,json_str_output out clob) is

  begin
    initial_value(json_str_input);
    gen_gradskil(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_tcomptnc_detail (json_str_output out clob) is
    obj_row            json_object_t;
     cursor c1 is
        select CODTENCY,NAMTNCYE,NAMTNCYT,NAMTNCY3,NAMTNCY4,NAMTNCY5,
               decode(global_v_lang,'101',NAMTNCYE
                                   ,'102',NAMTNCYT
                                   ,'103',NAMTNCY3
                                   ,'104',NAMTNCY4
                                   ,'105',NAMTNCY5) as NAMTNCY
        from tcomptnc
        where CODTENCY = p_codtency
        order by CODTENCY;
  begin

    obj_row   := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codtency', p_codtency);
    for i in c1 loop
      obj_row.put('namtncy', i.NAMTNCY);
      obj_row.put('namtncye', i.NAMTNCYE);
      obj_row.put('namtncyt', i.NAMTNCYT);
      obj_row.put('namtncy3', i.NAMTNCY3);
      obj_row.put('namtncy4', i.NAMTNCY4);
      obj_row.put('namtncy5', i.NAMTNCY5);
    end loop;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_tcomptnc_detail (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_tcomptnc_detail(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_tcompskil_detail (json_str_output out clob) is
    obj_row            json_object_t;
     cursor c1 is
        select CODCODEC,DESCODE,DESCODT,DESCOD3,DESCOD4,DESCOD5,
               decode(global_v_lang,'101',DESCODE
                                   ,'102',DESCODT
                                   ,'103',DESCOD3
                                   ,'104',DESCOD4
                                   ,'105',DESCOD5) as DESCOD
        from tcodskil
        where CODCODEC = p_codskill
        order by CODCODEC;
  begin

    obj_row   := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codcodec', p_codskill);
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
  end;
  --
  procedure get_tcompskil_detail (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_tcompskil_detail(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure delete_tcomptnc (json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

      p_flg         := hcm_util.get_string_t(param_json_row,'flg');
      p_codtency    := hcm_util.get_string_t(param_json_row,'codtency');

      if(p_flg = 'delete') then
        delete tcompskil where codtency = p_codtency;
        delete tcomptnc where codtency = p_codtency;
      end if;

    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure save_detail (json_str_input in clob, json_str_output out clob) as
    param_json        json_object_t;
    param_json_row    json_object_t;
    v_check_exisitng  number:=0;
    v_codtency        varchar2(100 char);
  begin
    initial_value(json_str_input);
    check_save_tcomptnc;

    if param_msg_error is null then

      begin
          select count(codtency)
          into v_check_exisitng
          from tcomptnc
          where codtency = p_codtency;

          if v_check_exisitng > 0 then
            UPDATE tcomptnc
            SET namtncyt = p_namtncyt,
                namtncye = p_namtncye,
                namtncy3 = p_namtncy3,
                namtncy4 = p_namtncy4,
                namtncy5 = p_namtncy5,
                coduser  = global_v_coduser
            WHERE codtency = p_codtency;
          else
            insert into tcomptnc (codtency,namtncyt,namtncye,namtncy3,namtncy4,namtncy5, CODCREATE,coduser)
            values (p_codtency, p_namtncyt, p_namtncye, p_namtncy3, p_namtncy4, p_namtncy5, global_v_coduser, global_v_coduser);
          end if;
      exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
      end;
      param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
      for i in 0..param_json.get_size-1 loop

        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

        p_flg         := hcm_util.get_string_t(param_json_row,'flg');
        p_codskill     := hcm_util.get_string_t(param_json_row,'codskill');
        p_descode     := hcm_util.get_string_t(param_json_row,'descode');
        p_descodt     := hcm_util.get_string_t(param_json_row,'descodt');
        p_descod3     := hcm_util.get_string_t(param_json_row,'descod3');
        p_descod4     := hcm_util.get_string_t(param_json_row,'descod4');
        p_descod5     := hcm_util.get_string_t(param_json_row,'descod5');

        if p_flg = 'delete' then
          begin
            delete tcompskil where codtency = p_codtency and codskill = p_codskill;
          end;
        elsif p_flg = 'add' then
          begin
            select codtency into v_codtency
            from   tcompskil
            where  codtency <> p_codtency
            and    codskill = p_codskill
            and rownum = 1;
          exception when no_data_found then
            v_codtency := '';
          end;
          if v_codtency is not null then
            param_msg_error := get_error_msg_php('CO0010',global_v_lang,'TCOMPSKIL');
          else
            select count(codtency)
              into v_check_exisitng
              from tcompskil
             where codtency = p_codtency
               and codskill = p_codskill;

            if v_check_exisitng < 1 then
              insert into tcompskil (codtency,codskill,codcreate, coduser)
              values (p_codtency, p_codskill, global_v_coduser, global_v_coduser);
            end if;
          end if;
        end if;
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
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure save_tcompskil(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_check_exisitng number:=0;
  begin
    initial_value(json_str_input);

    check_save;

    if param_msg_error is null then
        begin
          select count(codtency)
          into v_check_exisitng
          from tcomptnc
          where codtency = p_codtency;

          if v_check_exisitng > 0 then
            UPDATE tcomptnc
            SET namtncyt = p_namtncyt,
                namtncye = p_namtncye,
                namtncy3 = p_namtncy3,
                namtncy4 = p_namtncy4,
                namtncy5 = p_namtncy5,
                coduser  = global_v_coduser
            WHERE codtency = p_codtency;
          else
            insert into tcomptnc (codtency,namtncyt,namtncye,namtncy3,namtncy4,namtncy5, codcreate,coduser)
            values (p_codtency, p_namtncyt, p_namtncye, p_namtncy3, p_namtncy4, p_namtncy5, global_v_coduser, global_v_coduser);
          end if;
        exception when others then
          rollback;
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
        end;
        ---
        begin
          select count(codcodec)
          into v_check_exisitng
          from tcodskil
          where codcodec = p_codskill;

          if v_check_exisitng > 0 then
            UPDATE tcodskil
            SET descodt = p_descodt,
                descode = p_descode,
                descod3 = p_descod3,
                descod4 = p_descod4,
                descod5 = p_descod5,
                coduser = global_v_coduser
            WHERE codcodec = p_codskill;
          else
           insert into tcodskil (codcodec,descodt,descode,descod3,descod4,descod5,coduser,codcreate)
           values (p_codskill, p_descodt, p_descode, p_descod3, p_descod4, p_descod5, global_v_coduser, global_v_coduser);
          end if;
        exception when others then
          rollback;
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
        end;

        begin
          select count(codtency)
          into v_check_exisitng
          from tcompskil
          where codtency = p_codtency
          and codskill = p_codskill;
          if v_check_exisitng < 1 then
            insert into tcompskil (codtency,codskill,codcreate, coduser)
            values (p_codtency, p_codskill, global_v_coduser, global_v_coduser);
          end if;
        exception when others then
          rollback;
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
        end;

      param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

        p_flg           := hcm_util.get_string_t(param_json_row,'flg');
        p_grade         := hcm_util.get_string_t(param_json_row,'grade');
        p_namgrad       := hcm_util.get_string_t(param_json_row,'namgrad');
        p_namgrade      := hcm_util.get_string_t(param_json_row,'namgrade');
        p_namgradt      := hcm_util.get_string_t(param_json_row,'namgradt');
        p_namgrad3      := hcm_util.get_string_t(param_json_row,'namgrad3');
        p_namgrad4      := hcm_util.get_string_t(param_json_row,'namgrad4');
        p_namgrad5      := hcm_util.get_string_t(param_json_row,'namgrad5');

        if(p_flg = 'delete') then
          begin
            delete tskilscor where codskill = p_codskill and grade = p_grade;
          end;
        end if;
        if(p_flg = 'add') then
          begin
            insert into tskilscor (codskill,grade,namgrade,namgradt,namgrad3,namgrad4,namgrad5,codcreate,coduser)
            values (p_codskill, p_grade, p_namgrade, p_namgradt, p_namgrad3, p_namgrad4, p_namgrad5, global_v_coduser, global_v_coduser);
          end;
        end if;
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
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure get_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_error         varchar2(1000 char);
    v_flgsecu       boolean := false;
    v_rec_tran      number;
    v_rec_err       number;
    v_numseq        varchar2(1000 char);
    v_rcnt          number  := 0;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      format_text_json(json_str_input, v_rec_tran, v_rec_err);
    end if;
    --
    obj_row    := json_object_t();
    obj_result := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('rec_tran', v_rec_tran);
    obj_row.put('rec_err', v_rec_err);
    obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
    --
    if p_numseq.exists(p_numseq.first) then
      for i in p_numseq.first .. p_numseq.last
      loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('text', p_text(i));
        obj_data.put('error_code', p_error_code(i));
        obj_data.put('numseq', p_numseq(i) + 1);
        obj_result.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    obj_row.put('datadisp', obj_result);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    --
    data_file 		   varchar2(6000);
    v_column			   number := 7;
    v_error				   boolean;
    v_err_code  	   varchar2(1000);
    v_err_filed  	   varchar2(1000);
    v_err_table		   varchar2(20);
    i 						   number;
    j 						   number;
    k  						   number;
    v_numseq    	   number := 0;
    --
    --
    v_code				   varchar2(100);
    v_flgsecu			   boolean;
    v_cnt					   number := 0;
    v_dteleave		   date;
    v_coderr         varchar2(4000 char);
    v_num            number := 0;

    type text is table of varchar2(4000) index by binary_integer;
    v_text   text;
    v_filed  text;

    v_chk_compskil   TCOMPSKIL.CODTENCY%TYPE;
    v_chk_exist      number :=0;
    v_chk_codtency   varchar2(100);
    v_chk_codskil    varchar2(100);

    v_codtency       varchar2(4);
    v_namtncye       varchar2(150);
    v_namtncyt       varchar2(150);
    v_namtncy3       varchar2(150);
    v_namtncy4       varchar2(150);
    v_namtncy5       varchar2(150);
    v_codskil        varchar2(4);

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;
    --
    for i in 1..v_column loop
      v_filed(i) := null;
    end loop;
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
        -- get text columns from json
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_filed(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;

    for r1 in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data, to_char(r1));
      begin
        v_err_code  := null;
        v_err_filed := null;
        v_err_table := null;
        v_numseq    := v_numseq;
        v_error 	  := false;

        <<cal_loop>> loop
          v_text(1)   := hcm_util.get_string_t(param_json_row,'codtency');
          v_text(2)   := hcm_util.get_string_t(param_json_row,'namtncye');
          v_text(3)   := hcm_util.get_string_t(param_json_row,'namtncyt');
          v_text(4)   := hcm_util.get_string_t(param_json_row,'namtncy3');
          v_text(5)   := hcm_util.get_string_t(param_json_row,'namtncy4');
          v_text(6)   := hcm_util.get_string_t(param_json_row,'namtncy5');
          v_text(7)   := hcm_util.get_string_t(param_json_row,'codskill');

          data_file := null;
          for i in 1..7 loop
              data_file := v_text(1)||','||v_text(2)||','||v_text(3)||','||v_text(4)||','||v_text(5)||','||v_text(6)||','||v_text(7);
              if v_text(i) is null and (i = 1 or i = 2 or i = 7) then
                v_error	 	  := true;
                v_err_code  := 'HR2045';
                v_err_filed := v_filed(i);
                if i = 1 or i = 2 then
                  v_err_table := 'TCOMPTNC';
                else
                  v_err_table := 'TCODSKIL';
                end if;
                exit cal_loop;
              end if;
          end loop;
         -- 1.codtency
           i := 1;
           if length(v_text(i)) > 4 then
             v_error     := true;
             v_err_code  := 'HR6591';
             v_err_filed := v_filed(i);
              exit cal_loop;
           end if;
           v_codtency := upper(v_text(i));
        -- 2.namtncye
           i := 2;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_namtncye := upper(v_text(i));
        -- 3.namtncyt
           i := 3;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_namtncyt := upper(v_text(i));
        -- 4.namtncy3
           i := 4;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_namtncy3 := upper(v_text(i));
        -- 5.namtncy4
           i := 5;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_namtncy4 := upper(v_text(i));
        -- 6.namtncy5
           i := 6;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_namtncy5 := upper(v_text(i));
        -- 7.codskill
           i := 7;
           if v_text(i) is not null then
             if length(v_text(i)) > 4 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           begin
             select codcodec
             into v_chk_codskil
             from tcodskil
             where codcodec = upper(v_text(i));

           exception when no_data_found then
              v_error     := true;
              v_err_code  := 'HR2010';
              v_err_table := 'TCODSKIL';
              v_err_filed := upper(v_filed(i));
              exit cal_loop;
           end;

           begin
            select codtency into v_chk_compskil
            from   tcompskil
            where  codtency <> upper(v_text(1))
            and    codskill = upper(v_text(i))
            and rownum = 1;
          exception when no_data_found then
            v_chk_compskil := '';
          end;
          if v_chk_compskil is not null then
              v_error     := true;
              v_err_code  := 'CO0010';
              v_err_table := 'TCOMPSKIL';
              v_err_filed := upper(v_filed(i));
              exit cal_loop;
          end if;
          v_codskil := upper(v_text(i));
          exit cal_loop;
        end loop;

        if not v_error then
          v_rec_tran := v_rec_tran + 1;
          begin
            begin
             select codtency
             into v_chk_codtency
             from tcomptnc
             where codtency = upper(v_codtency);

            exception when no_data_found then
              v_chk_codtency := null;
            end;
            if v_chk_codtency is null then
              insert into tcomptnc (codtency,namtncyt,namtncye,namtncy3,namtncy4,namtncy5, codcreate,coduser)
              values (v_codtency, v_namtncyt, v_namtncye, v_namtncy3, v_namtncy4, v_namtncy5, global_v_coduser, global_v_coduser);

            else
              UPDATE tcomptnc
              SET namtncyt = v_namtncyt,
                  namtncye = v_namtncye,
                  namtncy3 = v_namtncy3,
                  namtncy4 = v_namtncy4,
                  namtncy5 = v_namtncy5,
                  coduser = global_v_coduser
              WHERE codtency = v_codtency;
            end if;


              insert into tcompskil (codtency,codskill, codcreate, coduser)
              values (v_codtency, v_codskil, global_v_coduser, global_v_coduser);
            exception when others then
              null;
          end;
        else
          v_rec_error      := v_rec_error + 1;
          v_cnt            := v_cnt+1;
          -- puch value in array
          p_text(v_cnt)       := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||'['||v_err_filed||']';
          p_numseq(v_cnt)     := r1;
        end if;

      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;
END HRCO18E;

/

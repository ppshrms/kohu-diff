--------------------------------------------------------
--  DDL for Package Body HRAL53E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL53E" is
-- last update: 20/02/2018 12:02

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codcompy          := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'), 'dd/mm/yyyy');
    p_dteeffecOld       := p_dteeffec;
    p_isAddOrigin       := hcm_util.get_string_t(json_obj,'p_isAddOrigin');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure initial_value_detail(json_str_input in clob) as
    json_input        json_object_t;
    param_json        json_object_t;
    json_obj_tab1     json_object_t;
  begin
    json_input        := json_object_t(json_str_input);
    param_json        := hcm_util.get_json_t(json_input,'param_json');

    -- params save tab1
    json_obj_tab1     := hcm_util.get_json_t(param_json,'tab1');
    p_flgmthvac       := hcm_util.get_string_t(json_obj_tab1,'flgmthvac');
    p_daylevst        := to_number(hcm_util.get_string_t(json_obj_tab1,'daylevst'));
    p_mthlevst        := to_number(hcm_util.get_string_t(json_obj_tab1,'mthlevst'));
    p_dayleven        := to_number(hcm_util.get_string_t(json_obj_tab1,'dayleven'));
    p_mthleven        := to_number(hcm_util.get_string_t(json_obj_tab1,'mthleven'));
    p_qtyday          := to_number(hcm_util.get_string_t(json_obj_tab1,'qtyday'));
    p_flgcal          := hcm_util.get_string_t(json_obj_tab1,'flgcal');
    p_typround        := hcm_util.get_string_t(json_obj_tab1,'typround');
    -- new requirement --
    p_flgresign       := hcm_util.get_string_t(json_obj_tab1,'flgresign');
    p_flguse          := hcm_util.get_string_t(json_obj_tab1,'flguse');

    -- params save tab2
    p_json_tab1       := hcm_util.get_json_t(param_json, 'tab2');
  end initial_value_detail;

  procedure check_index is
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'codcompy');
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dteeffec');
      return;
    end if;
  end check_index;

  procedure get_flg_status (json_str_input in clob, json_str_output out clob) is
    obj_data            json_object_t;
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      obj_data        := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('isEdit', isEdit);
      obj_data.put('isAdd', isAdd);
      obj_data.put('isAddOrigin', isAddOrigin);
      if isAdd or isEdit then
        obj_data.put('dteeffec', to_char(p_dteeffecOld, 'dd/mm/yyyy'));
        obj_data.put('msqerror','');
      else
        obj_data.put('dteeffec', to_char(p_dteeffec, 'dd/mm/yyyy'));
        obj_data.put('msqerror',replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',''));
      end if;

      obj_data.put('dteupd',to_char(p_dteupd, 'dd/mm/yyyy'));
      obj_data.put('codimage',(p_codempid));
      obj_data.put('desc_coduser',p_desc_coduser);


      json_str_output := obj_data.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_flg_status;

  procedure gen_flg_status as
    v_dteeffec        date;
    cursor c_tcontrlv is
      select dteupd, coduser
        from tcontrlv
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec
         and rownum = 1;

  begin
    begin
      select dteeffec
        into v_dteeffec
        from tcontrlv
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec;
      if p_dteeffec >= trunc(sysdate) then
        isEdit := true;
      end if;
    exception when no_data_found then
      if p_dteeffec < trunc(sysdate) then
        isEdit := false;
      else
        isAdd := true;
      end if;
      begin
        select max(dteeffec)
          into v_dteeffec
          from tcontrlv
          where codcompy = p_codcompy
            and dteeffec <= p_dteeffec;
      end;
      if v_dteeffec is null then
          begin
            select min(dteeffec)
              into v_dteeffec
              from tcontrlv
              where codcompy = p_codcompy
                and dteeffec > p_dteeffec;
          end;

          if v_dteeffec is null then
            isAdd := true;
            isAddOrigin := true;
          else
            isAdd := false;
            isEdit := false;
            p_dteeffec    := v_dteeffec;
          end if;
      else
        p_dteeffec    := v_dteeffec;
      end if;
    end;
    --
    if p_isAddOrigin = 'Y' then
      isEdit := true;
      isAdd  := false;
      isAddOrigin := true;
    end if;

    for c1 in c_tcontrlv loop
      p_dteupd := c1.dteupd;
      p_codempid := get_codempid(c1.coduser);
      p_desc_coduser := get_temploy_name(p_codempid,global_v_lang);
    end loop;

  end;

  procedure get_tab1(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_tab1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab1;

  procedure gen_tab1(json_str_output out clob) as
    obj_data          json_object_t;
    v_has_data        boolean:= false;
    cursor c_tcontrlv is
      select flgmthvac, daylevst, mthlevst, dayleven, mthleven, qtyday, flgcal, typround, flgresign, flguse
        from tcontrlv
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec
         and rownum = 1;

    cursor c_tleavety is
      select daylevst , mthlevst, dayleven, mthleven
        from tleavety
       where typleave = 'V'
        and rownum = 1
    order by typleave;

  begin
    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('flgmthvac', '2');
    obj_data.put('daylevst', '');
    obj_data.put('mthlevst', '');
    obj_data.put('dayleven', '');
    obj_data.put('mthleven', '');
    obj_data.put('qtyday', '');
    obj_data.put('flgcal', '1');
    obj_data.put('flguse', '1');
    obj_data.put('flgresign', '1');
    obj_data.put('typround', '');
    for c1 in c_tcontrlv loop
      v_has_data := true;
      obj_data.put('flgmthvac', c1.flgmthvac);
      obj_data.put('daylevst', to_char(c1.daylevst));
      obj_data.put('mthlevst', to_char(c1.mthlevst));
      obj_data.put('dayleven', to_char(c1.dayleven));
      obj_data.put('mthleven', to_char(c1.mthleven));
      obj_data.put('qtyday', to_char(c1.qtyday));
      obj_data.put('flgcal', c1.flgcal);
      obj_data.put('typround', c1.typround);
      obj_data.put('flgresign', c1.flgresign);
      obj_data.put('flguse', c1.flguse);
    end loop;

    if not v_has_data then
      for c2 in c_tleavety loop
         obj_data.put('daylevst', to_char(c2.daylevst));
         obj_data.put('mthlevst', to_char(c2.mthlevst));
         obj_data.put('dayleven', to_char(c2.dayleven));
         obj_data.put('mthleven', to_char(c2.mthleven));
      end loop;
    end if;

    json_str_output := obj_data.to_clob;
  end gen_tab1;

  procedure get_tab2(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tab2;

  procedure gen_tab2(json_str_output out clob) as
    obj_row           json_object_t;
    obj_row2          json_object_t;
    obj_data          json_object_t;
    obj_data2         json_object_t;
    v_rcnt            number := 0;
    v_rcnt2           number := 0;
    v_numseq          number;
    cursor c_tratevac is
      select numseq, syncond, statement
        from tratevac
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec;
    cursor c_tratevac2 is
      select qtylwkst, qtylwken, qtymin, qtymax, qtylimit, mthprien, flgcal, qtywkbeg, rowId
        from tratevac2
       where codcompy = p_codcompy
         and dteeffec = p_dteeffec
         and numseq = v_numseq;
  begin
    obj_row           := json_object_t();
    for c1 in c_tratevac loop
      obj_data          := json_object_t();
      v_rcnt            := v_rcnt + 1;

      obj_data.put('coderror', '200');
      obj_data.put('flgAdd', isAdd);
      obj_data.put('numseq', to_char(c1.numseq));

      obj_data.put('syncond', c1.syncond);
      obj_data.put('desc_syncond', get_logical_desc(c1.statement));
      obj_data.put('statement_syncond', c1.statement);

      v_numseq          := c1.numseq;
      v_rcnt2           := 0;
      obj_row2          := json_object_t();
      for c2 in c_tratevac2 loop
        obj_data2           := json_object_t();
        v_rcnt2             := v_rcnt2 + 1;
        obj_data2.put('coderror', '200');
        obj_data2.put('flgAdd', isAdd);
        obj_data2.put('qtylwkst', to_char(c2.qtylwkst));
        obj_data2.put('qtylwken', to_char(c2.qtylwken));
        obj_data2.put('qtymin', to_char(c2.qtymin));
        obj_data2.put('qtymax', to_char(c2.qtymax));
        obj_data2.put('qtylimit', to_char(c2.qtylimit));
        obj_data2.put('mthprien', to_char(c2.mthprien));
        obj_data2.put('flgcal', c2.flgcal);
        obj_data2.put('qtywkbeg', to_char(c2.qtywkbeg));
        obj_data2.put('rowId', to_char(c2.rowId));

        obj_row2.put(to_char(v_rcnt2 - 1), obj_data2);
      end loop;
      obj_data.put('children', obj_row2);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_tab2;

  procedure save_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      initial_value_detail(json_str_input);
      param_msg_error := hcm_validate.validate_lov('typround', p_typround, global_v_lang);
      if param_msg_error is null then
        save_detail_tab1;
      end if;
      if param_msg_error is null then
        save_detail_tab2;
      end if;
      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      end if;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;

  procedure save_detail_tab1 as
  begin
    insert into tcontrlv
                (codcompy, dteeffec, flgmthvac, daylevst, mthlevst, dayleven, mthleven, qtyday, flgcal, flgresign, flguse, typround, codcreate, coduser
                ,dteupd,dtecreate--User37 TDK-SS2101 27/07/2021
                )
         values (p_codcompy, p_dteeffec, p_flgmthvac, p_daylevst, p_mthlevst, p_dayleven, p_mthleven, p_qtyday, p_flgcal, p_flgresign, p_flguse, p_typround, global_v_coduser, global_v_coduser
                ,sysdate,sysdate--User37 TDK-SS2101 27/07/2021
                );
  exception when dup_val_on_index then
    update tcontrlv
       set flgmthvac =  p_flgmthvac,
           daylevst  =  p_daylevst,
           mthlevst  =  p_mthlevst,
           dayleven  =  p_dayleven,
           mthleven  =  p_mthleven,
           qtyday    =  p_qtyday,
           flgcal    =  p_flgcal,
           typround  =  p_typround,
           coduser   =  global_v_coduser,
           dteupd     = sysdate, --User37 TDK-SS2101 27/07/2021
           -- new reauirement --
           flgresign =  p_flgresign,
           flguse    =  p_flguse
     where codcompy  =  p_codcompy
       and dteeffec  =  p_dteeffec;
  end save_detail_tab1;

  procedure save_detail_tab2 as
    json_row                json_object_t;
    json_children           json_object_t;
    obj_syncond             json_object_t;
    obj_children            json_object_t;

    v_flgDelete             varchar2(100 char);
    v_numseq                number;
    v_syncond               varchar2(4000 char);
    v_statement_syncond     clob;

    v_childFlgDelete        varchar2(100 char);
    v_qtylwkst              number := 0;
    v_qtylwkstOld           number := 0;
    v_childRowId            varchar2(1000 char);
    v_qtylwken              number;
    v_qtymin                number;
    v_qtymax                number;
    v_qtylimit              number;
    v_mthprien              number;
    v_flgcal                varchar2(100 char);
    v_qtywkbeg              number;
  begin
    for i in 0..p_json_tab1.get_size-1 loop
      json_row              := hcm_util.get_json_t(p_json_tab1,to_char(i));
      v_flgDelete           := hcm_util.get_string_t(json_row, 'flg');
      v_numseq              := to_number(hcm_util.get_string_t(json_row, 'numseq'));
      obj_syncond           := hcm_util.get_json_t(json_row,'syncond');
      v_syncond             := hcm_util.get_string_t(obj_syncond, 'code');
      v_statement_syncond   := hcm_util.get_string_t(obj_syncond, 'statement');
      if v_flgDelete = 'delete' then
        delete from tratevac
              where codcompy = p_codcompy
                and dteeffec = p_dteeffec
                and numseq = v_numseq;

        delete from tratevac2
              where codcompy = p_codcompy
                and dteeffec = p_dteeffec
                and numseq = v_numseq;
      else
        if v_numseq is null then
          begin
            select (nvl(max(numseq), 0) + 1)
              into v_numseq
              from tratevac
             where codcompy = p_codcompy
               and dteeffec = p_dteeffec
          order by numseq desc;
          end;
        end if;
        begin
          insert into tratevac
                      (codcompy, dteeffec, numseq, syncond, statement, codcreate, coduser)
               values (p_codcompy, p_dteeffec, v_numseq, v_syncond, v_statement_syncond, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          update tratevac
             set syncond = v_syncond,
                 statement = v_statement_syncond,
                 coduser = global_v_coduser
           where codcompy = p_codcompy
             and dteeffec = p_dteeffec
             and numseq = v_numseq;
        end;
        obj_children          := hcm_util.get_json_t(json_row,'children');
        for j in 0..obj_children.get_size-1 loop
          json_children           := hcm_util.get_json_t(obj_children,to_char(j));
          v_childFlgDelete        := hcm_util.get_string_t(json_children, 'flg');
          v_qtylwkst              := to_number(hcm_util.get_string_t(json_children, 'qtylwkst'));
          v_qtylwkstOld           := to_number(hcm_util.get_string_t(json_children, 'qtylwkstOld'));
          v_qtylwken              := to_number(hcm_util.get_string_t(json_children, 'qtylwken'));
          v_qtymin                := to_number(hcm_util.get_string_t(json_children, 'qtymin'));
          v_qtymax                := to_number(hcm_util.get_string_t(json_children, 'qtymax'));
          v_qtylimit              := to_number(hcm_util.get_string_t(json_children, 'qtylimit'));
          v_mthprien              := to_number(hcm_util.get_string_t(json_children, 'mthprien'));
          v_flgcal                := hcm_util.get_string_t(json_children, 'flgcal');
          v_qtywkbeg              := to_number(hcm_util.get_string_t(json_children, 'qtywkbeg'));
          v_childRowId            := hcm_util.get_string_t(json_children, 'rowId');

          if v_mthprien is not null then
            param_msg_error := hcm_validate.validate_lov('nammthful', v_mthprien, global_v_lang);
            if param_msg_error is not null then
              return;
            end if;
          end if;
          param_msg_error := hcm_validate.validate_lov('lvmethod', v_flgcal, global_v_lang);
          if param_msg_error is not null then
            return;
          end if;

          if v_childFlgDelete = 'delete' then
            delete from tratevac2
                  where codcompy = p_codcompy
                    and dteeffec = p_dteeffec
                    and numseq = v_numseq
                    and qtylwkst = v_qtylwkst;
          else
            --<<User37 #5729 2.AL Module 30/04/2021
            begin
                select qtylwkst
                  into v_qtylwkst
                  from tratevac2
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and numseq = v_numseq
                   and (
                    (v_qtylwkst between qtylwkst and qtylwken - 1) or
                    (v_qtylwken - 1 between qtylwkst and qtylwken - 1)
                   )
                   and (rowId <> v_childRowId or v_childRowId is null)
                   and rownum = 1;
                param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tratevac2');
                return;
            exception when no_data_found then
                null;
            end;
            -->>User37 #5729 2.AL Module 30/04/2021
            begin
              select qtylwkst
                into v_qtylwkst
                from tratevac2
               where codcompy = p_codcompy
                 and dteeffec = p_dteeffec
                 and numseq = v_numseq
                 and qtylwkst = v_qtylwkst
                 and rowId <> v_childRowId;
              param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tratevac2');
              return;
            exception when no_data_found then
              if v_childFlgDelete = 'add' then
                  begin
                    insert into tratevac2
                                (codcompy, dteeffec, numseq, qtylwkst,
                                 qtylwken, qtymin, qtymax, qtylimit,
                                 mthprien, flgcal, qtywkbeg, codcreate, coduser)
                         values (p_codcompy, p_dteeffec, v_numseq, v_qtylwkst,
                                 v_qtylwken, v_qtymin, v_qtymax, v_qtylimit,
                                 v_mthprien, v_flgcal, v_qtywkbeg, global_v_coduser, global_v_coduser);
                  exception when others then
                    param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tratevac2');
                    return;
                end;
                elsif v_childFlgDelete = 'edit' then
                  begin
                      update tratevac2
                         set qtylwkst = v_qtylwkst,
                             qtylwken = v_qtylwken,
                             qtymin = v_qtymin,
                             qtymax = v_qtymax,
                             qtylimit = v_qtylimit,
                             mthprien = v_mthprien,
                             flgcal = v_flgcal,
                             qtywkbeg = v_qtywkbeg,
                             coduser = global_v_coduser
                       where codcompy = p_codcompy
                         and dteeffec = p_dteeffec
                         and numseq = v_numseq
                         and qtylwkst = v_qtylwkstOld;
                    exception when others then
                      param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tratevac2');
                      return;
                    end;
                  end if;
            end;
          end if;
        end loop;
      end if;
    end loop;
  end save_detail_tab2;

end HRAL53E;

/

--------------------------------------------------------
--  DDL for Package Body HRAL13E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL13E" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codcompyCopy      := hcm_util.get_string_t(json_obj,'p_codcompyCopy');
    p_typleave          := hcm_util.get_string_t(json_obj,'p_typleave');
    p_flgCopy           := hcm_util.get_string_t(json_obj,'p_flgCopy');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    end if;

    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
    if param_msg_error is not null then
      return;
    end if;
  end;

  procedure check_detail is
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    end if;
    if p_typleave is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typleave');
      return;
    end if;
    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
    if param_msg_error is not null then
      return;
    end if;
  end;

  procedure get_index_shift(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index_shift(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index_shift(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_numseq        number := 0;
    v_codapp        varchar2(20 char) := 'HRAL13E';

    cursor c1 is
      select codcompy, codshift
        from tshifcom
       where codcompy = nvl(p_codcompyCopy,p_codcompy)
      order by codshift;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('codcompy', p_codcompy);
      obj_data.put('desc_codcompy', get_tcenter_name(p_codcompy,global_v_lang));
      obj_data.put('codshift', r1.codshift);
      obj_data.put('desc_codshift', get_tshiftcd_name(r1.codshift,global_v_lang));
      if p_flgCopy = 'Y' then
        obj_data.put('flgAdd', true);
        obj_data.put('flg', 'add');
      else
        obj_data.put('flgAdd', false);
      end if;

      if isInsertReport then
        insert_ttemprpt_codshift(obj_data);
      end if;

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index_leave(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index_leave(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index_leave(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_data2       json_object_t;
    obj_row2        json_object_t;
    obj_result      json_object_t;
    obj_popup_row   json_object_t;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_numseq        number := 0;
    v_codapp        varchar2(20 char) := 'HRAL13E';
    v_typleave      tleavcomess.typleave%type;

    cursor c1 is
      select codcompy, typleave
        from tleavcom
       where codcompy = nvl(p_codcompyCopy,p_codcompy)
      order by typleave;

    cursor c2 is
      select codcompy, typleave, codleave--User37 #5760 2.AL Module 27/04/2021 , flgess
        from tleavcomess
       where codcompy = nvl(p_codcompyCopy,p_codcompy)
         and typleave = v_typleave
      order by typleave,codleave;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      v_typleave    := r1.typleave;

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('codcompy', p_codcompy);
      obj_data.put('desc_codcompy', get_tcenter_name(p_codcompy,global_v_lang));
      obj_data.put('typleave', r1.typleave);
      obj_data.put('desc_typleave', get_tleavety_name(r1.typleave,global_v_lang));
      if p_flgCopy = 'Y' then
        obj_data.put('flgAdd', true);
        obj_data.put('flg', 'add');
      else
        obj_data.put('flgAdd', false);
      end if;

      obj_row2 := json_object_t();
      obj_data2 := json_object_t();
      obj_popup_row := json_object_t();
      v_rcnt2       := 0;
      for r2 in c2 loop
        v_rcnt2 := v_rcnt2+1;
        obj_data2 := json_object_t();
        obj_data2.put('codcompy', p_codcompy);
        obj_data2.put('desc_codcompy', get_tcenter_name(p_codcompy,global_v_lang));
        obj_data2.put('typleave', r2.typleave);
        obj_data2.put('desc_typleave', get_tleavety_name(r2.typleave,global_v_lang));
        obj_data2.put('codleave', r2.codleave);
        obj_data2.put('desc_codleave', get_tleavecd_name(r2.codleave,global_v_lang));
        --User37 #5760 2.AL Module 27/04/2021 obj_data2.put('flgess', r2.flgess);
        --User37 #5760 2.AL Module 27/04/2021 obj_data2.put('desc_flgess', get_tlistval_name('ESSCODLV',r2.flgess, global_v_lang));
        if p_flgCopy = 'Y' then
            obj_data2.put('flgAdd', true);
            obj_data2.put('flg', 'add');
        else
            obj_data2.put('flgAdd', false);
        end if;
        obj_row2.put(to_char(v_rcnt2-1),obj_data2);
      end loop;
      obj_popup_row.put('rows', obj_row2);
      obj_data.put('popup', obj_popup_row);

      if isInsertReport then
        insert_ttemprpt_typleave(obj_data);
      end if;

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_leave(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail_leave(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_leave(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_numseq        number := 0;
    v_codapp        varchar2(20 char) := 'HRAL13E';

    cursor c1 is
      select codcompy, typleave, codleave--User37 #5760 2.AL Module 27/04/2021 , flgess
        from tleavcomess
       where codcompy = p_codcompy
         and typleave = nvl(p_typleave,typleave)
      order by typleave,codleave;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('desc_codcompy', get_tcenter_name(r1.codcompy,global_v_lang));
      obj_data.put('typleave', r1.typleave);
      obj_data.put('desc_typleave', get_tleavety_name(r1.typleave,global_v_lang));
      obj_data.put('codleave', r1.codleave);
      obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave,global_v_lang));
      --User37 #5760 2.AL Module 27/04/2021 obj_data.put('flgess', r1.flgess);
      --User37 #5760 2.AL Module 27/04/2021 obj_data.put('desc_flgess', get_tlistval_name('ESSCODLV',r1.flgess, global_v_lang));

      if isInsertReport then
        insert_ttemprpt_codleave(obj_data);
      end if;

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;


  procedure post_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_index_shift(json_str_input);
    end if;
    if param_msg_error is null then
      save_index_leave(json_str_input);
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
  end;

  procedure save_index_shift(json_str_input in clob) as
    param_json_row  json_object_t;
    param_json      json_object_t;
    v_flg           varchar2(100 char);
    v_codshift      varchar2(100 char);
  begin
    if p_flgCopy = 'Y' then
        begin
            delete tshifcom
             where codcompy = p_codcompy;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            return;
        end ;
    end if;
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str_shift');
    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
      p_codcompy      := hcm_util.get_string_t(param_json_row,'codcompy');
      p_codshift      := hcm_util.get_string_t(param_json_row,'codshift');
      v_flg           := hcm_util.get_string_t(param_json_row,'flg');

      if p_codshift is null then
         param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codshift');
         return;
      end if;

      if v_flg = 'add' then
        begin
          select codshift
            into v_codshift
            from tshiftcd
            where codshift = upper(p_codshift);
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tshiftcd');
          return;
        end;
        begin
          insert into tshifcom (codcompy, codshift, codcreate, coduser)
               values (p_codcompy, p_codshift, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tshifcom');
          return;
        end;
      elsif v_flg = 'delete' then
        begin
          delete from tshifcom
                where codcompy = p_codcompy
                  and codshift = p_codshift;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          return;
        end;
      end if;
    end loop;
  end save_index_shift;

  procedure save_index_leave(json_str_input in clob) as
    param_json_row  json_object_t;
    param_json_popup_row  json_object_t;
    param_json      json_object_t;
    param_json_popup json_object_t;
    v_flg           varchar2(100 char);
    v_flg_popup     varchar2(100 char);
    v_codleave      varchar2(100 char);
    v_typleave      varchar2(100 char);
    p_codleaveOld   tleavcomess.codleave%type;
  begin
    if p_flgCopy = 'Y' then
        begin
            delete tleavcom
             where codcompy = p_codcompy;
            delete tleavcomess
             where codcompy = p_codcompy;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            return;
        end ;
    end if;
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str_leave');
    for i in 0..param_json.get_size-1 loop
        param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
        p_codcompy        := hcm_util.get_string_t(param_json_row,'codcompy');
        p_typleave        := hcm_util.get_string_t(param_json_row,'typleave');
        p_typleaveOld     := hcm_util.get_string_t(param_json_row,'typleaveOld');
        v_flg             := hcm_util.get_string_t(param_json_row,'flg');
        param_json_popup := hcm_util.get_json_t(hcm_util.get_json_t(param_json_row,'popup'),'rows');
--        param_json_popup  := hcm_util.get_json(param_json_row,'popup');

        if v_flg = 'add' then
            begin
                select typleave
                  into v_typleave
                  from tleavety
                 where typleave = upper(p_typleave);
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tleavety');
                return;
            end;
            begin
              insert into tleavcom (codcompy, typleave, codcreate, coduser)
                   values (p_codcompy, p_typleave, global_v_coduser, global_v_coduser);
            exception when dup_val_on_index then
              param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tleavcom');
              return;
            end;
        elsif v_flg = 'edit' then
            begin
              update tleavcom
                 set typleave = p_typleave
               where codcompy = p_codcompy
                 and typleave = p_typleaveOld;
            exception when dup_val_on_index then
              param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tleavcom');
              return;
            end;
        elsif v_flg = 'delete' then
            begin
              delete from tleavcom
                    where codcompy = p_codcompy
                      and typleave = nvl(p_typleaveOld,p_typleave);
            exception when others then
              param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
              return;
            end;

            begin
              delete from tleavcomess
                    where codcompy = p_codcompy
                      and typleave = nvl(p_typleaveOld,p_typleave);
            exception when others then
              param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
              return;
            end;
        end if;

        if v_flg in ('add','edit') then
            for j in 0..param_json_popup.get_size-1 loop
                param_json_popup_row := hcm_util.get_json_t(param_json_popup,to_char(j));
                p_codleave      := hcm_util.get_string_t(param_json_popup_row,'codleave');
                p_codleaveOld   := hcm_util.get_string_t(param_json_popup_row,'codleaveOld');
                p_flgess        := hcm_util.get_string_t(param_json_popup_row,'flgess');
                v_flg_popup     := hcm_util.get_string_t(param_json_popup_row,'flg');
                if p_codleave is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codleave');
                    return;
                end if;

                if v_flg_popup = 'add' then
                    begin
                      select codleave
                        into v_codleave
                        from tleavecd
                        where codleave = upper(p_codleave);
                    exception when no_data_found then
                      param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tleavecd');
                      return;
                    end;
                    begin
                      --<<User37 #5760 2.AL Module 27/04/2021 
                      --insert into tleavcomess (codcompy, typleave, codleave, flgess, codcreate, coduser)
                      --     values (p_codcompy, p_typleave, p_codleave, p_flgess, global_v_coduser, global_v_coduser);
                      insert into tleavcomess (codcompy, typleave, codleave, codcreate, coduser)
                           values (p_codcompy, p_typleave, p_codleave, global_v_coduser, global_v_coduser);
                      -->>User37 #5760 2.AL Module 27/04/2021 
                    exception when dup_val_on_index then
                      param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tleavcomess');
                      return;
                    end;
                elsif v_flg_popup = 'edit' then
                    begin
                      update tleavcomess
                         set --User37 #5760 2.AL Module 27/04/2021 flgess = p_flgess,
                             codleave = p_codleave
                       where codcompy = p_codcompy
                         and typleave = p_typleave
                         and codleave = p_codleaveOld;
                    exception when dup_val_on_index then
                      param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tleavcomess');
                      return;
                    end;
                elsif v_flg_popup = 'delete' then
                    begin
                      delete from tleavcomess
                            where codcompy = p_codcompy
                              and typleave = p_typleave
                              and codleave = p_codleaveOld;
                    exception when others then
                      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                      return;
                    end;
                end if;
            end loop;
        end if;
    end loop;
  end save_index_leave;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcompy          := hcm_util.get_string_t(json_obj, 'p_codcompy');
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    obj_data          json_object_t;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      obj_data      := json_object_t();
      obj_data.put('codcompy', p_codcompy);
      obj_data.put('desc_codcompy', get_tcenter_name(p_codcompy, global_v_lang));
      p_codapp := 'HRAL13E';
      insert_ttemprpt_codshift(obj_data);
      p_codapp := 'HRAL13E1';
      gen_index_shift(json_output);
      p_codapp := 'HRAL13E3';
      gen_detail_leave(json_output);
--      p_codapp := 'HRAL13E3';
--      gen_index_leave(json_output);
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
         and codapp   like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt_codshift(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_codcompy          varchar2(1000 char) := '';
    v_desc_codcompy    	varchar2(1000 char) := '';
    v_codshift     			varchar2(1000 char) := '';
    v_desc_codshift     varchar2(1000 char) := '';
  begin
    v_codcompy        := nvl(hcm_util.get_string_t(obj_data, 'codcompy'), ' ');
    v_desc_codcompy   := nvl(hcm_util.get_string_t(obj_data, 'desc_codcompy'), ' ');
    v_codshift        := nvl(hcm_util.get_string_t(obj_data, 'codshift'), ' ');
    v_desc_codshift   := nvl(hcm_util.get_string_t(obj_data, 'desc_codshift'), ' ');
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
           ( codempid, codapp, numseq, item1, item2, item3, item4, item5 )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             v_codcompy,
             v_desc_codcompy,
             null,
             v_codshift,
             v_desc_codshift
           );
    exception when others then
      null;
    end;
  end insert_ttemprpt_codshift;

  procedure insert_ttemprpt_typleave(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_codcompy          varchar2(1000 char) := '';
    v_desc_codcompy    	varchar2(1000 char) := '';
    v_typleave     		varchar2(1000 char) := '';
    v_desc_typleave     varchar2(1000 char) := '';
  begin
     v_codcompy        := nvl(hcm_util.get_string_t(obj_data, 'codcompy'), ' ');
     v_desc_codcompy   := nvl(hcm_util.get_string_t(obj_data, 'desc_codcompy'), ' ');
     v_typleave        := nvl(hcm_util.get_string_t(obj_data, 'typleave'), ' ');
     v_desc_typleave   := nvl(hcm_util.get_string_t(obj_data, 'desc_typleave'), ' ');
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
           ( codempid, codapp, numseq, item1, item2, item3, item4, item5 )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             v_codcompy,
             v_desc_codcompy,
             null,
             v_typleave,
             v_desc_typleave
           );
    exception when others then
      null;
    end;
  end insert_ttemprpt_typleave;

  procedure insert_ttemprpt_codleave(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_codcompy          varchar2(1000 char) := '';
    v_desc_codcompy    	varchar2(1000 char) := '';
    v_typleave     		varchar2(1000 char) := '';
    v_desc_typleave     varchar2(1000 char) := '';
    v_codleave     			varchar2(1000 char) := '';
    v_desc_codleave     varchar2(1000 char) := '';
    v_desc_flgess       varchar2(1000 char) := '';
  begin
     v_codcompy        := nvl(hcm_util.get_string_t(obj_data, 'codcompy'), ' ');
     v_desc_codcompy   := nvl(hcm_util.get_string_t(obj_data, 'desc_codcompy'), ' ');
     v_typleave        := nvl(hcm_util.get_string_t(obj_data, 'typleave'), ' ');
     v_desc_typleave   := nvl(hcm_util.get_string_t(obj_data, 'desc_typleave'), ' ');
     v_codleave        := nvl(hcm_util.get_string_t(obj_data, 'codleave'), ' ');
     v_desc_codleave   := nvl(hcm_util.get_string_t(obj_data, 'desc_codleave'), ' ');
     v_desc_flgess     := nvl(hcm_util.get_string_t(obj_data, 'desc_flgess'), ' ');
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
           ( codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8 )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             v_codcompy,
             v_desc_codcompy,
             null,
             v_typleave,
             v_desc_typleave,
             v_codleave,
             v_desc_codleave,
             v_desc_flgess
           );
    exception when others then
      null;
    end;
  end insert_ttemprpt_codleave;
  --
  procedure get_codshift_all(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
      select  codshift,decode(global_v_lang,'101',desshifte,
                                            '102',desshiftt,
                                            '103',desshift3,
                                            '104',desshift4,
                                            '105',desshift5) desc_codshift,timstrtw,timendw
        from  tshiftcd
    order by  codshift;
  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codshift',i.codshift);
      obj_data.put('desc_codshift',i.desc_codshift);
      obj_data.put('schedule',substr(i.timstrtw,1,2)||':'||substr(i.timstrtw,3,2)||'-'||substr(i.timendw,1,2)||':'||substr(i.timendw,3,2));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codshift_all;
  --
  procedure get_codleave_all(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c1 is
      select codleave,decode(global_v_lang,'101',namleavcde,
                                            '102',namleavcdt,
                                            '103',namleavcd3,
                                            '104',namleavcd4,
                                            '105',namleavcd5) desc_codleave
        from tleavecd
       where typleave = p_typleave
    order by codleave, typleave;
  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codleave',i.codleave);
      obj_data.put('desc_codleave',i.desc_codleave);
      obj_data.put('flgess','Y');
      obj_data.put('desc_flgess',get_tlistval_name('ESSCODLV','Y', global_v_lang));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codleave_all;

  --
  procedure get_typleave_all(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_popup_data  json_object_t;
    obj_row         json_object_t;
    obj_popup       json_object_t;
    obj_popup_row   json_object_t;
    v_row           number := 0;
    v_row_popup     number := 0;
    v_typleave      tleavety.typleave%type;
    cursor c1 is
      select  typleave,decode(global_v_lang,'101',namleavtye,
                                            '102',namleavtyt,
                                            '103',namleavty3,
                                            '104',namleavty4,
                                            '105',namleavty5) desc_typleave
        from  tleavety
    order by  typleave;

    cursor c2 is
        select codleave
          from tleavecd
         where typleave = v_typleave
      order by codleave;
  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();

    for r1 in c1 loop
      v_typleave    := r1.typleave;
      v_row         := v_row + 1;
      obj_data      := json_object_t();
      obj_popup     := json_object_t();
      obj_popup_row := json_object_t();

      obj_data.put('coderror','200');
      obj_data.put('typleave',r1.typleave);
      obj_data.put('desc_typleave',r1.desc_typleave);
      v_row_popup   := 0;
      for r2 in c2 loop
        v_row_popup := v_row_popup + 1;
        obj_popup_data  := json_object_t();
        obj_popup_data.put('codcompy', p_codcompy);
        obj_popup_data.put('desc_codcompy', get_tcenter_name(p_codcompy,global_v_lang));
        obj_popup_data.put('typleave', r1.typleave);
        obj_popup_data.put('desc_typleave', get_tleavety_name(r1.typleave,global_v_lang));
        obj_popup_data.put('codleave', r2.codleave);
        obj_popup_data.put('desc_codleave', get_tleavecd_name(r2.codleave,global_v_lang));
        obj_popup_data.put('flgess', 'Y');
        obj_popup_data.put('desc_flgess', get_tlistval_name('ESSCODLV','Y', global_v_lang));
        obj_popup_data.put('flg','add');
        obj_popup_data.put('flgAdd',true);
        obj_popup_row.put(to_char(v_row_popup-1),obj_popup_data);
      end loop;
      obj_popup.put('rows',obj_popup_row);
      obj_data.put('popup',obj_popup);
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_typleave_all;

  procedure get_codleave_bytype(json_str_input in clob, json_str_output out clob) as
    obj_data            json_object_t;
    obj_popup           json_object_t;
    obj_popup_data      json_object_t;
    obj_popup_row       json_object_t;
    v_row_popup         number := 0;
    cursor c1 is
      select codleave,decode(global_v_lang,'101',namleavcde,
                                            '102',namleavcdt,
                                            '103',namleavcd3,
                                            '104',namleavcd4,
                                            '105',namleavcd5) desc_codleave
        from tleavecd
       where typleave = p_typleave
    order by codleave;
  begin
    initial_value(json_str_input);
    obj_popup       := json_object_t();
    obj_popup_row   := json_object_t();
    obj_data        := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('codcompy', p_codcompy);
    obj_data.put('typleave',p_typleave);
    obj_data.put('desc_typleave',get_tleavety_name(p_typleave,global_v_lang));
    v_row_popup   := 0;
    for r1 in c1 loop
        v_row_popup := v_row_popup + 1;
        obj_popup_data := json_object_t();
        obj_popup_data.put('codcompy', p_codcompy);
        obj_popup_data.put('desc_codcompy', get_tcenter_name(p_codcompy,global_v_lang));
        obj_popup_data.put('typleave', p_typleave);
        obj_popup_data.put('desc_typleave', get_tleavety_name(p_typleave,global_v_lang));
        obj_popup_data.put('codleave', r1.codleave);
        obj_popup_data.put('desc_codleave', get_tleavecd_name(r1.codleave,global_v_lang));
        obj_popup_data.put('flgess', 'Y');
        obj_popup_data.put('desc_flgess', get_tlistval_name('ESSCODLV','Y', global_v_lang));
        obj_popup_data.put('flg','add');
        obj_popup_data.put('flgAdd',true);
        obj_popup_row.put(to_char(v_row_popup-1),obj_popup_data);
    end loop;
    obj_popup.put('rows',obj_popup_row);
    obj_data.put('popup',obj_popup);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codleave_bytype;

  procedure get_copylist(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_copylist(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_copylist(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_numseq        number := 0;
    v_codapp        varchar2(20 char) := 'HRAL13E';

    cursor c1 is

      select distinct codcompy
        from tshifcom
       where codcompy <> p_codcompy
      union
      select distinct codcompy
        from tleavcom
       where codcompy <> p_codcompy;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('desc_codcompy', get_tcenter_name(r1.codcompy,global_v_lang));

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end HRAL13E;

/

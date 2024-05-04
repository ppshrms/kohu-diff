--------------------------------------------------------
--  DDL for Package Body HRAP15E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP15E" as
  procedure initial_value(json_str in clob) is
    json_obj                json_object_t;
  begin
    v_chken                 := hcm_secur.get_v_chken;
    json_obj                := json_object_t(json_str);
    --global
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    p_dteyreap              := hcm_util.get_string_t(json_obj,'p_dteyreap');
    p_numseq                := hcm_util.get_string_t(json_obj,'p_numseq');
    p_codcomp               := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid              := hcm_util.get_string_t(json_obj,'p_codempid_query');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row             json_object_t;  
    obj_data            json_object_t;
    v_statement         clob;
    flg_data            varchar2(1) := 'N';
    v_check             boolean;
    v_codcomp           taplvl.codcomp%type;
    v_rcnt              number := 0;
    --<<user25 Date: 07/10/2021 3. AP Module #4401 #4407
    v_flgAplvl          varchar2(1) := 'N';
    v_count             number := 0;
     v_flgsecu          boolean := false;
    v_chksecu           boolean := false;
    -->>user25 Date: 07/10/2021 3. AP Module #4401 #4407   

    cursor c1 is
      select codempid, codcomp, codpos, codaplvl, codcomlvl
        from tempaplvl
       where dteyreap = p_dteyreap
         and numseq = p_numseq
         and codcomp like p_codcomp||'%'
         and codempid = nvl(p_codempid,codempid)
    order by codcomlvl, codempid;

    cursor c2 is
      select codempid, codcomp, codpos
        from temploy1
       where codcomp like p_codcomp||'%'
         and codempid = nvl(p_codempid,codempid)
         and staemp <> '9'
    order by codempid;

    cursor c3 is
      select a.codcomp, a.codaplvl, a.condap
        from taplvl a
       where v_codcomp like a.codcomp||'%'
         and a.dteeffec = (select max(b.dteeffec)
                             from taplvl b
                            where b.codaplvl = a.codaplvl
                              and b.codcomp = a.codcomp
                              and dteeffec <= trunc(sysdate))
    order by a.codcomp desc,codaplvl;
  begin
    -- taplvld
    obj_row     := json_object_t();
    v_rcnt      := 0;
    for i in c1 loop
        flg_data := 'Y';
--      if secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        v_count := v_count +1;
        v_flgsecu := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgsecu then
          v_chksecu := true;
          v_rcnt    := v_rcnt+1;
          obj_data  := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('image', get_emp_img (i.codempid));
          obj_data.put('codempid', i.codempid);
          obj_data.put('codcomp', i.codcomp);
          obj_data.put('codpos', i.codpos);
          obj_data.put('codaplvl', i.codaplvl);
          obj_data.put('codcomlvl', i.codcomlvl);
          obj_data.put('flgFirstLoad',true);
          begin
            select 'Y'
              into v_flgAplvl
              from tappemp  
             where codempid = i.codempid
               and dteyreap = p_dteyreap
               and numtime  = p_numseq
               and flgappr  = 'C';
            exception when no_data_found then
            v_flgAplvl := 'N';      
          end;
          obj_data.put('flgAplvl',v_flgAplvl);
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
--<<user25 Date: 07/10/2021 3. AP Module #4404
--    if flg_data = 'N' then
--        for i in c2 loop
--            if secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
--                v_codcomp := i.codcomp;
--                for r3 in c3 loop
--                    v_statement := 'select count(*) from v_hrap14e where codempid = '''||i.codempid || ''' and staemp <> 9 and '|| r3.condap;
--                    v_check := EXECUTE_STMT(v_statement);
--                    if v_check then
--                      v_rcnt    := v_rcnt+1;
--                      obj_data  := json_object_t();
--                      obj_data.put('coderror', '200');
--                      obj_data.put('flgAdd', true);
--                      obj_data.put('image', get_emp_img (i.codempid));
--                      obj_data.put('codempid', i.codempid);
--                      obj_data.put('codcomp', i.codcomp);
--                      obj_data.put('codpos', i.codpos);
--                      obj_data.put('codaplvl', r3.codaplvl);
--                      obj_data.put('codcomlvl', r3.codcomp);
--                      obj_data.put('flgFirstLoad',true);
--                      begin
--                        select 'Y'
--                          into v_flgAplvl
--                          from tappemp  
--                         where codempid = i.codempid
--                           and dteyreap = p_dteyreap
--                           and numtime  = p_numseq
--                           and flgappr  = 'C';
--                        exception when no_data_found then
--                        v_flgAplvl := 'N';      
--                      end;
--                      obj_data.put('flgAplvl',v_flgAplvl);
--                      obj_row.put(to_char(v_rcnt-1),obj_data);
--                      exit;
--                    end if;
--                end loop;
--            end if;
--        end loop;
--    end if;
        if v_count = 0 then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tempaplvl');
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
        elsif not v_chksecu  then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
        end if;
-->>user25 Date: 07/10/2021 3. AP Module #4404        
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_index is
     v_codcomp   tcenter.codcomp%type;
     v_codempid  temploy1.codempid%type;
     v_staemp    temploy1.staemp%type;
  begin

    if p_codcomp is null and p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_codcomp is not null then
      begin
        select codcomp into v_codcomp
          from tcenter
         where codcomp = get_compful(p_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_codempid is not null then
      begin
        select codempid into v_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TEMPLOY1');
        return;
      end;

      select staemp
        into v_staemp
        from temploy1
       where codempid = p_codempid;
      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101', global_v_lang);
        return;
      end if;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;

    if p_dteyreap is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_numseq is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure get_data_codempid(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_codempid(p_codempid);
    if param_msg_error is null then
      gen_data_codempid(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_codempid(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_num           number(10) := 0;

    v_cursor        number;
    v_idx           number := 0;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(4000 char);
    v_check         boolean;
    v_statement     clob;
    v_codcomp       temploy1.codcomp%type;

    cursor c2 is
      select codempid, codcomp, codpos
        from temploy1
       where codempid = p_codempid
         and staemp <> '9'
    order by codempid;

    cursor c3 is
      select a.codcomp, a.codaplvl, a.condap
        from taplvl a
       where v_codcomp like a.codcomp||'%'
         and a.dteeffec = (select max(b.dteeffec)
                             from taplvl b
                            where b.codaplvl = a.codaplvl
                              and b.codcomp = a.codcomp
                              and dteeffec <= trunc(sysdate))
    order by a.codcomp desc,codaplvl;
  begin

    v_rcnt  := 0;
    obj_data := json_object_t();
    for r2 in c2 loop
        if secur_main.secur3(r2.codcomp,r2.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
            v_codcomp := r2.codcomp;
            for r3 in c3 loop
                v_statement := 'select count(*) from v_hrap14e where codempid = '''||r2.codempid || ''' and staemp <> 9 and '|| r3.condap;
                v_check     := EXECUTE_STMT(v_statement);
                if v_check then
                  v_flgdata     := 'Y';
                  v_rcnt        := v_rcnt+1;
                  obj_data      := json_object_t();
                  obj_data.put('coderror', '200');
                  obj_data.put('image', get_emp_img (r2.codempid));
                  obj_data.put('codempid', r2.codempid);
                  obj_data.put('codcomp', r2.codcomp);
                  obj_data.put('codpos', r2.codpos);
                  obj_data.put('codaplvl', r3.codaplvl);
                  obj_data.put('codcomlvl', r3.codcomp);
                end if;
            end loop;
        end if;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'V_HRAP14E');
      json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_data.to_clob;
  end;

  procedure check_save(json_str_input in clob) is
     v_codcomp      tcenter.codcomp%type;
     param_json     json_object_t;
     obj_formula    json_object_t;
     obj_table      json_object_t;
  begin
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'params');
    obj_formula   := hcm_util.get_json_t(param_json,'formula');
    obj_table     := hcm_util.get_json_t(param_json,'table');
  end;
  --
  procedure check_codempid(p_codempid varchar2) is
     v_codempid     temploy1.codempid%type;
     v_staemp       temploy1.staemp%type;
  begin
      begin
        select codempid
          into v_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TEMPLOY1');
        return;
      end;

      select staemp
        into v_staemp
        from temploy1
       where codempid = v_codempid;
      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101', global_v_lang);
        return;
      end if;

      if not secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
  end;

  procedure check_codcomlvl(p_codcomlvl varchar2, p_codaplvl varchar2) is
     v_codcomlvl    taplvl.codcomp%type;
  begin
      begin
        select a.codcomp
          into v_codcomlvl
          from taplvl a
         where codcomp = p_codcomlvl
           and codaplvl = p_codaplvl
           and dteeffec = (select max(b.dteeffec)
                             from taplvl b
                             where b.codcomp = a.codcomp
                               and b.codaplvl = a.codaplvl
                               and b.dteeffec <= trunc(sysdate));
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TAPLVL');
        return;
      end;
  end;
  procedure post_save (json_str_input in clob, json_str_output out clob) as
    param_json          json_object_t;
    param_json_row      json_object_t;

    v_flg	            varchar2(1000 char);
    v_codempid          tempaplvl.codempid%type;
    v_codempidOld       tempaplvl.codempid%type;
    chk_codempid        tempaplvl.codempid%type;
    v_codcomlvl         tempaplvl.codcomlvl%type;
    v_codaplvl          tempaplvl.codaplvl%type;
    v_codcomp           tempaplvl.codcomp%type;
    v_codpos            tempaplvl.codpos%type;
  begin
    initial_value(json_str_input);
--    check_save(json_str_input);

    param_json      := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');

    for i in 0..param_json.get_size-1 loop
      param_json_row        := hcm_util.get_json_t(param_json,to_char(i));
      v_flg                 := hcm_util.get_string_t(param_json_row,'flg');
      v_codempid            := hcm_util.get_string_t(param_json_row,'codempid');
      v_codempidOld         := hcm_util.get_string_t(param_json_row,'codempidOld');
      v_codcomlvl           := hcm_util.get_string_t(param_json_row,'codcomlvl');
      v_codaplvl            := hcm_util.get_string_t(param_json_row,'codaplvl');
      v_codcomp             := hcm_util.get_string_t(param_json_row,'codcomp');
      v_codpos              := hcm_util.get_string_t(param_json_row,'codpos');

      if v_flg = 'add' or (v_flg = 'edit' and v_codempid != v_codempidOld) then
        begin
            select codempid
              into chk_codempid
              from tempaplvl
             where dteyreap = p_dteyreap
               and numseq = p_numseq
               and codempid = v_codempid;
        exception when others then
            chk_codempid := null;
        end;

        if chk_codempid is not null then
            param_msg_error := get_error_msg_php('HR1503',global_v_lang);
            exit;
        end if;

      end if;

      if v_flg = 'add' then
        check_codempid(v_codempid);
        if param_msg_error is not null then
            exit;
        end if;
        check_codcomlvl(v_codcomlvl, v_codaplvl);
        if param_msg_error is not null then
            exit;
        end if;

        begin
          insert into tempaplvl(dteyreap,numseq,codempid,codaplvl,
                                codcomlvl,codcomp,codpos,
                                dtecreate,codcreate,dteupd,coduser)
                        values (p_dteyreap,p_numseq,v_codempid,v_codaplvl,
                                v_codcomlvl,v_codcomp,v_codpos,
                                sysdate,global_v_coduser,sysdate,global_v_coduser);
        end;

      elsif v_flg = 'delete' then
        begin
          delete tempaplvl
           where dteyreap = p_dteyreap
             and numseq = p_numseq
             and codempid = v_codempidOld;
        end;
      elsif v_flg = 'edit' then
        check_codempid(v_codempid);
        if param_msg_error is not null then
            exit;
        end if;
        check_codcomlvl(v_codcomlvl, v_codaplvl);
        if param_msg_error is not null then
            exit;
        end if;
        begin
          update tempaplvl
             set codempid =	v_codempid,
                 codaplvl = v_codaplvl,
                 codcomlvl = v_codcomlvl,
                 codcomp = v_codcomp,
                 codpos = v_codpos,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where dteyreap = p_dteyreap
             and numseq = p_numseq
             and codempid = v_codempidOld;
        end;
      end if;
    end loop;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      rollback;
      return;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --
end HRAP15E;

/

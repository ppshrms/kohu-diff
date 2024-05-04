--------------------------------------------------------
--  DDL for Package Body HRPYB3E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYB3E" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := '';--web_service.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

--    p_codcomp           := hcm_util.get_string(json_obj,'p_codcomp');
    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codpfinf          := hcm_util.get_string_t(json_obj,'p_codpfinf');
    p_pvdffmt           := hcm_util.get_string_t(json_obj,'p_pvdffmt');
    p_numcomp           := hcm_util.get_string_t(json_obj,'p_numcomp');
    p_flgsearch         := hcm_util.get_string_t(json_obj,'p_flgsearch');

    p_codplan           := hcm_util.get_string_t(json_obj,'p_codplan');
    p_codpolicy         := hcm_util.get_string_t(json_obj,'p_codpolicy');
    p_pctinvt           := to_number(hcm_util.get_string_t(json_obj,'p_pctinvt'));
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
    p_dteeffecQuery     := to_date(hcm_util.get_string_t(json_obj,'p_dteeffecQuery'),'dd/mm/yyyy');
    p_dteeffecOld       := p_dteeffec;

    forceAdd            := hcm_util.get_string_t(json_obj,'forceAdd');
--    p_isAddOrigin       := hcm_util.get_string(json_obj,'p_isAddOrigin');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
    flgsecu boolean := false;
  begin
    --
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeffec');
      return;
    end if;
  end;

  procedure get_flg_status (json_str_input in clob, json_str_output out clob) is
    obj_data            json_object_t;
    v_response      varchar2(1000 char);
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      obj_data        := json_object_t();
      if v_flgDisabled then
        v_response  := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null);
      end if;
      obj_data.put('coderror', '200');
      obj_data.put('isEdit', isEdit);
      obj_data.put('isAdd', isAdd);
      obj_data.put('msqerror', v_response);

      obj_data.put('dteeffec', to_char(p_dteeffec, 'DD/MM/YYYY'));

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
    v_count           number := 0;
    v_maxdteeffec     date;
  begin
    begin
     select count(*) into v_count
       from tcontraw
      where codcompy = p_codcompy
       and dteeffec  = p_dteeffec;
    exception when no_data_found then
      v_count := 0;
    end;

    if v_count = 0 then
      select max(dteeffec) into v_maxdteeffec
        from tpfphinf
       where codcompy = p_codcompy
         and dteeffec <= p_dteeffec;

--      if p_flgsearch <> 'Y' then
--        p_dteeffec := v_maxdteeffec;
--      end if;
      if v_maxdteeffec is null then
        select min(dteeffec) into v_maxdteeffec
          from tpfphinf
         where codcompy = p_codcompy
           and dteeffec > p_dteeffec;
        if v_maxdteeffec is null then
            v_flgDisabled       := false;
        else 
            v_flgDisabled       := true;
            p_dteeffecquery     := v_maxdteeffec;
            p_dteeffec          := v_maxdteeffec;
        end if;
      else  
        if p_dteeffec < trunc(sysdate) then
            v_flgDisabled       := true;
            p_dteeffecquery     := v_maxdteeffec;
            p_dteeffec          := v_maxdteeffec;
        else
            v_flgDisabled       := false;
            p_dteeffecquery     := v_maxdteeffec;
        end if;
      end if;
    else
      if p_dteeffec < trunc(sysdate) then
        v_flgDisabled := true;
      else
        v_flgDisabled := false;
      end if;
      p_dteeffecquery := p_dteeffec;
    end if;

    if p_dteeffecquery < p_dteeffec then
        isAdd           := true; 
        isEdit          := false;
    else
        isAdd           := false;
        isEdit          := not v_flgDisabled;
    end if;

    if forceAdd = 'Y' then
      isEdit := false;
      isAdd  := true;
    end if;
  end;

  procedure check_detail is
    flgsecu boolean := false;
    v_codcodec    varchar2(100 char);
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_codpfinf is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpfinf');
      return;
    end if;
    begin
      select codcodec into v_codcodec
        from  tcodpfinf
       where  codcodec = p_codpfinf;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodpfinf ');
      return;
    end;
  end;

  procedure check_save_detail is
  v_codpfinf   varchar2(100 char);
  begin
    if p_codpfinf is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpfinf');
      return;
    else
      begin
        select codcodec
          into v_codpfinf
          from tcodpfinf
         where codcodec = p_codpfinf;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodpfinf');
        return;
      end;
    end if;
    if p_pvdffmt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'pvdffmt');
      return;
    end if;
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end;

  procedure check_save_detail_tableP is
  v_code         varchar2(20 char);
  v_codcodec    varchar2(100 char);
  begin
    if p_codplan is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcodec');
      return;
    else
      begin
        select codcodec
          into v_codcodec
          from tcodpfpln
         where codcodec = p_codplan;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodpfpln');
        return;
      end;
    end if;
  end;

  procedure check_save_detail_tableC is
  v_code         varchar2(20 char);
  v_codcodec    varchar2(100 char);
  begin
    if p_codpolicy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcodec');
      return;
    else
      begin
        select codcodec
          into v_codcodec
          from tcodpfplc
         where codcodec = p_codpolicy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodpfplc');
        return;
      end;
      if p_pctinvt is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'pctinvt');
        return;
      end if;
    end if;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_flg_status;
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_flgsecu       boolean;
    v_rcnt          number := 0;
    v_secur         varchar2(4000 char);
    v_permission    boolean := false;
    v_exist         boolean := false;

    cursor c1 is
      select codcompy, dteeffec , codpfinf, pvdffmt, numcomp
        from tpfphinf
       where codcompy = p_codcompy
         and dteeffec = p_dteeffecquery
      order by codpfinf;

  begin
    gen_flg_status;
    obj_row     := json_object_t();
    obj_data    := json_object_t();
    obj_result  := json_object_t();

    for r1 in c1 loop
      v_secur :=  hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, r1.codcompy);
      if v_secur is null then
        v_permission := true;
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('rcnt', to_char(v_rcnt));

        obj_data.put('codcompy', r1.codcompy);
--        obj_data.put('dteeffec', to_char(r1.dteeffec,'DD/MM/YYYY'));
        obj_data.put('dteeffec', to_char(p_dteeffec,'DD/MM/YYYY'));
        obj_data.put('dteeffeco', to_char(p_dteeffecquery,'DD/MM/YYYY'));
        obj_data.put('codpfinf', r1.codpfinf);
        obj_data.put('desc_codpfinf', get_tcodec_name('TCODPFINF',r1.codpfinf,global_v_lang));
        obj_data.put('pvdffmt', r1.pvdffmt);
        obj_data.put('desc_pvdffmt', get_tlistval_name('TPVDFFMT',r1.pvdffmt,global_v_lang));
        obj_data.put('numcomp', r1.numcomp);
        obj_data.put('flgAdd', isAdd);

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
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

  procedure get_detail (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_flg_status;
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail(json_str_output out clob) as
    obj_response    json_object_t;
    obj_detail      json_object_t;
    obj_row         json_object_t;
    obj_row2        json_object_t;
    obj_data        json_object_t;
    obj_data2       json_object_t;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_pvdffmt       varchar2(100 char);
    v_numcomp       varchar2(100 char);
    v_codplan       varchar2(100 char);
    v_codpfinf      varchar2(100 char);
    v_codpolicy     varchar2(100 char);
    v_response      varchar2(4000 char);

    cursor c_tpfpcinf is
      select distinct(codplan)
        from tpfpcinf
       where codcompy  = p_codcompy
        and dteeffec = p_dteeffecquery
        and  codpfinf  = p_codpfinf
    order by codplan asc;

     cursor c_tpfpcinf2 is
      select codpolicy, pctinvt,dteeffec
        from tpfpcinf
       where codcompy  = p_codcompy
        and dteeffec = p_dteeffecquery
        and  codpfinf  = p_codpfinf
        and  codplan =   v_codplan
    order by codpolicy asc;

  begin
    begin
      select pvdffmt, numcomp
        into v_pvdffmt, v_numcomp
        from tpfphinf
       where codcompy = p_codcompy
        and dteeffec = p_dteeffecquery
         and codpfinf = p_codpfinf;
    exception when no_data_found then
      v_pvdffmt  := null;
      v_numcomp  := null;
    end;
    obj_response := json_object_t();
    obj_detail := json_object_t();
    obj_detail.put('pvdffmt', v_pvdffmt);
    obj_detail.put('numcomp', v_numcomp);

    obj_row := json_object_t();
    for c1 in c_tpfpcinf loop
      obj_data          := json_object_t();
      v_rcnt            := v_rcnt + 1;
      v_codplan         := c1.codplan;
--        v_numseq          := v_numseq + 1;
      obj_data.put('codplan', c1.codplan);

      v_rcnt2           := 0;
      obj_row2          := json_object_t();

      for c2 in c_tpfpcinf2 loop
        obj_data2           := json_object_t();
        v_rcnt2             := v_rcnt2 + 1;

        obj_data2.put('codpolicy', c2.codpolicy);
        obj_data2.put('pctinvt', to_char(c2.pctinvt,'fm999,999,999,990.00'));
        obj_data2.put('flgAdd', isAdd);
        obj_row2.put(to_char(v_rcnt2 - 1), obj_data2);
      end loop;
      obj_data.put('children', obj_row2);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    if v_flgDisabled then
      v_response  := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null);
    end if;
    obj_response.put('coderror', '200');
    obj_response.put('isAdd', isAdd);
    obj_response.put('isEdit', isEdit);
    obj_response.put('msqerror', v_response);
    obj_response.put('detail', obj_detail);
    obj_response.put('table', obj_row);

    json_str_output := obj_response.to_clob();
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    json_obj        json_object_t;
    v_flg           varchar2(1000);
    v_secur         varchar2(4000 char);
    v_tpfphinf      tpfphinf%rowtype;

    cursor c1 is
      select *
        from tpfpcinf
       where codcompy = p_codcompy
         and dteeffec = p_dteeffeco
         and codpfinf = p_codpfinf
    order by codplan asc;    
  begin
--    check_index;
    param_json          := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
    json_obj            := json_object_t(json_str_input);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');

    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        --
        p_codcompy      := hcm_util.get_string_t(param_json_row,'codcompy');
        p_dteeffec      := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'), 'dd/mm/yyyy');
        p_dteeffeco     := to_date(hcm_util.get_string_t(param_json_row,'dteeffeco'), 'dd/mm/yyyy');
        p_codpfinf      := hcm_util.get_string_t(param_json_row,'codpfinf');
        v_flg           := hcm_util.get_string_t(param_json_row,'flg');
        v_secur :=  hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
        if v_secur is not null then
          param_msg_error := v_secur;
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          rollback;
          return;
        end if;
        if v_flg = 'delete' then
          begin
            delete from tpfphinf
                  where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and codpfinf = p_codpfinf;

            delete from tpfpcinf
                  where  codcompy  = p_codcompy
                    and  dteeffec  = p_dteeffec
                    and  codpfinf  = p_codpfinf ;
          end;
        elsif  v_flg = 'add' then  
            select * 
              into v_tpfphinf
              from tpfphinf
             where codcompy = p_codcompy
               and dteeffec = p_dteeffeco
               and codpfinf = p_codpfinf;

            begin
                insert into tpfphinf (codcompy, dteeffec, codpfinf, pvdffmt, numcomp, dtecreate,codcreate,dteupd,coduser)
                values (p_codcompy, p_dteeffec, p_codpfinf, v_tpfphinf.pvdffmt, v_tpfphinf.numcomp,sysdate, global_v_coduser,sysdate,global_v_coduser);

                for r1 in c1 loop
                    begin
                        insert into tpfpcinf (codcompy, dteeffec, codpfinf, codplan, codpolicy, pctinvt, dtecreate,codcreate,dteupd,coduser)
                             values (p_codcompy, p_dteeffec, p_codpfinf, r1.codplan, r1.codpolicy, r1.pctinvt,sysdate, global_v_coduser,sysdate,global_v_coduser);                
                    exception when dup_val_on_index then
                        null;
                    end;
                end loop;                 
            exception when dup_val_on_index then
                null;
            end;
        end if;
      end loop;
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    json_obj             json_object_t :=json_object_t(json_str_input);
    json_row             json_object_t;
    json_children        json_object_t;
    obj_syncond          json_object_t;
    obj_children         json_object_t;
    param_json           json_object_t;
    index_json           json_object_t;
    param_json_row       json_object_t;
    v_flg_parent         varchar2(100);
    v_flg_child          varchar2(100);
    v_numseq             number;
    v_codcompy           varchar2(100);
    v_codpfinf           varchar2(100);
    p_codpfinf_detail    varchar2(100);
    v_pvdffmt            varchar2(100);
    v_codplan            varchar2(100);
    v_numcomp            varchar2(100);
    v_codpolicy          varchar2(100);
    v_pctinvt            number;
    v_pctinvtOld         number;
    v_dteeffec           date;
    v_sum_pctinvt        number;
    v_flgAdd            boolean;
    v_flgDelete         boolean;
    v_tpfphinf      tpfphinf%rowtype;

    cursor c1 is
      select *
        from tpfpcinf
       where codcompy = p_codcompy
         and dteeffec = p_dteeffeco
         and codpfinf = p_codpfinf
    order by codplan asc;    

  begin
    initial_value(json_str_input);
    check_save_detail;
    if param_msg_error is null then
        index_json          := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'p_index'),'rows');
        p_codpfinf_detail   := hcm_util.get_string_t(json_obj, 'p_codpfinf');
        for i in 0..index_json.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(index_json,to_char(i));
            p_codcompy      := hcm_util.get_string_t(param_json_row,'codcompy');
            p_dteeffec      := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'), 'dd/mm/yyyy');
            p_dteeffeco     := to_date(hcm_util.get_string_t(param_json_row,'dteeffeco'), 'dd/mm/yyyy');
            p_codpfinf      := hcm_util.get_string_t(param_json_row,'codpfinf');
            v_flgAdd        := hcm_util.get_boolean_t(param_json_row,'flgAdd');
            v_flgDelete     := hcm_util.get_boolean_t(param_json_row,'flgDelete');

            if p_codpfinf <> p_codpfinf_detail then
                if v_flgDelete then
                  begin
                    delete from tpfphinf
                          where codcompy = p_codcompy
                           and dteeffec = p_dteeffec
                           and codpfinf = p_codpfinf;

                    delete from tpfpcinf
                          where  codcompy  = p_codcompy
                            and  dteeffec  = p_dteeffec
                            and  codpfinf  = p_codpfinf ;
                  end;
                elsif v_flgAdd then  
                    select * 
                      into v_tpfphinf
                      from tpfphinf
                     where codcompy = p_codcompy
                       and dteeffec = p_dteeffeco
                       and codpfinf = p_codpfinf;

                    begin
                        insert into tpfphinf (codcompy, dteeffec, codpfinf, pvdffmt, numcomp, dtecreate,codcreate,dteupd,coduser)
                        values (p_codcompy, p_dteeffec, p_codpfinf, v_tpfphinf.pvdffmt, v_tpfphinf.numcomp,sysdate, global_v_coduser,sysdate,global_v_coduser);

                        for r1 in c1 loop
                            begin
                                insert into tpfpcinf (codcompy, dteeffec, codpfinf, codplan, codpolicy, pctinvt, dtecreate,codcreate,dteupd,coduser)
                                     values (p_codcompy, p_dteeffec, p_codpfinf, r1.codplan, r1.codpolicy, r1.pctinvt,sysdate, global_v_coduser,sysdate,global_v_coduser);                
                            exception when dup_val_on_index then
                                null;
                            end;
                        end loop;                 
                    exception when dup_val_on_index then
                        null;
                    end;
                end if;
            end if;
        end loop;

        p_codcompy  := hcm_util.get_string_t(json_obj, 'p_codcompy');
        p_codpfinf  := hcm_util.get_string_t(json_obj, 'p_codpfinf');
        p_pvdffmt   := hcm_util.get_string_t(json_obj, 'p_pvdffmt');
        p_dteeffec  := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'), 'dd/mm/yyyy');
        p_numcomp   := hcm_util.get_string_t(json_obj, 'p_numcomp');
        param_json  := hcm_util.get_json_t(json_obj,'p_param_json');

        begin
            insert into tpfphinf (codcompy, dteeffec, codpfinf, pvdffmt, numcomp, dteupd, coduser, codcreate,dtecreate)
                 values (p_codcompy, p_dteeffec, p_codpfinf, p_pvdffmt, p_numcomp, sysdate, global_v_coduser, global_v_coduser,sysdate);
        exception when dup_val_on_index then
            update tpfphinf set pvdffmt   = p_pvdffmt,
                                numcomp   = p_numcomp,
                                dteupd    = sysdate,
                                coduser   = global_v_coduser
                          where codcompy = p_codcompy
                             and dteeffec = p_dteeffec
                             and codpfinf = p_codpfinf;
        end;
      /* insert and update logic Don't Remove That!!!!
          parent delete	 => delete parent and child

          parent add, child add => insert child
          parent add, child null => impossible
          parent edit, child edit => update child
          parent edit, child add => insert child
          parent edit, child null => impossible

          parent null, child add => insert child
          parent null, child edit => update child
          parent null, child delete => delete child
      */
        for i in 0..param_json.get_size-1 loop
            v_sum_pctinvt         := 0;
            json_row              := hcm_util.get_json_t(param_json,to_char(i));
            v_flg_parent          := hcm_util.get_string_t(json_row, 'flg');
            p_codplan             := hcm_util.get_string_t(json_row,'codplan');
            p_codplanOld          := hcm_util.get_string_t(json_row,'codplanOld');
            check_save_detail_tableP;
            if v_flg_parent = 'delete' then
              delete from tpfpcinf
                   where  codcompy   = p_codcompy
                      and  dteeffec  = p_dteeffec
                      and  codpfinf  = p_codpfinf
                      and  codplan   = p_codplanOld;
            else
                obj_children          := hcm_util.get_json_t(json_row,'children');
                for j in 0..obj_children.get_size-1 loop
                    json_children           := hcm_util.get_json_t(obj_children,to_char(j));
                    v_flg_child             := hcm_util.get_string_t(json_children, 'flg');
                    p_codpolicy             := hcm_util.get_string_t(json_children, 'codpolicy');
                    p_codpolicyOld          := hcm_util.get_string_t(json_children, 'codpolicyOld');
                    p_pctinvt               := to_number(hcm_util.get_string_t(json_children, 'pctinvt'));
                    p_pctinvtold            := to_number(hcm_util.get_string_t(json_children, 'pctinvtOld'));
                    check_save_detail_tableC;
                    if v_flg_child = 'delete' then
                      delete from tpfpcinf
                         where codcompy = p_codcompy
                           and dteeffec = p_dteeffec
                           and  codpfinf  = p_codpfinf
                           and  codplan   = p_codplan
                           and  codpolicy = p_codpolicyOld;
                    else
                      if ((v_flg_parent = 'add' or v_flg_parent = 'edit' or v_flg_parent is null or v_flg_parent = '') and v_flg_child = 'add') then
                        insert into tpfpcinf
                                    (codcompy, dteeffec, codplan, codpfinf, codpolicy, pctinvt, dtecreate,codcreate,dteupd,coduser)
                             values (p_codcompy, p_dteeffec, p_codplan, p_codpfinf, p_codpolicy, p_pctinvt,sysdate, global_v_coduser,sysdate,global_v_coduser);
                      elsif ((v_flg_parent = 'edit' or v_flg_parent is null or v_flg_parent = '') and v_flg_child = 'edit') then
                        update tpfpcinf
                           set pctinvt = p_pctinvt,
                               coduser = global_v_coduser,
                               dteupd  = sysdate
                        where codcompy = p_codcompy
                         and dteeffec  = p_dteeffec
                         and codpfinf = p_codpfinf
                         and codplan  =  p_codplanOld
                         and codpolicy = p_codpolicyOld;
                      end if;
                    end if;
                end loop;
            end if;
            begin
                select sum(pctinvt) into v_sum_pctinvt
                  from tpfpcinf
                 where codcompy = p_codcompy
                   and dteeffec = p_dteeffec
                   and codpfinf  = p_codpfinf
                   and codplan   = p_codplan;
            end;

            if v_sum_pctinvt != 100 then
                param_msg_error := get_error_msg_php('PY0039',global_v_lang);
                goto jump;
            end if;
        end loop;
        <<jump>>
        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        else
            rollback;
        end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
END HRPYB3E;

/

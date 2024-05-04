--------------------------------------------------------
--  DDL for Package Body HRAL1KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL1KE" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codcomp   := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codcalen  := hcm_util.get_string_t(json_obj,'p_codcalen');
    b_index_dteeffec  := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteeffec')),'dd/mm/yyyy');

    v_dteeffec  := to_date(trim(hcm_util.get_string_t(json_obj,'dteeffec')),'dd/mm/yyyy');
    v_startday  := to_number(hcm_util.get_string_t(json_obj,'startday'));
    v_codcalen  := hcm_util.get_string_t(json_obj,'codcalen');
    v_codcomp   := hcm_util.get_string_t(json_obj,'codcomp');
    --v_numseq    := to_number(hcm_util.get_string_t(json_obj,'numseq'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure check_index is
    v_secur boolean := false;
  begin
    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end check_index;
  --
  procedure check_index2 is
    v_secur boolean := false;
  begin
    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeffec');
      return;
    end if;
  end check_index2;
  --
  procedure check_save is
  begin
    if v_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if v_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteeffec');
      return;
    end if;
    if v_startday is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'startday');
      return;
    end if;
  end check_save;

  procedure check_insert(p_codshift varchar2, p_codcomp varchar2) is
    v_temp    varchar2(500 char);
  begin
    begin
      select codshift
        into v_temp
        from tshiftcd
       where codshift = p_codshift;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codshift');
      return;
    end;
    --
    begin
      select codshift
        into v_temp
        from tshifcom
       where codshift = p_codshift
         and codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('AL0061',global_v_lang,'tshifcom');
      return;
    end;
  end;

  --
  function gen_numseq(p_codcomp  in varchar2,
                      p_codcalen in varchar2,
                      p_dteeffec in date) return number is
    v_numseq  number;
  begin
    begin
      select nvl(max(numseq),0)+1 into v_numseq
        from tgrpwork
       where codcomp  = p_codcomp
         and codcalen = p_codcalen
         and dteeffec = p_dteeffec;
    exception when no_data_found then
      v_numseq := 1;
    end;

    return v_numseq;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end gen_numseq;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row		    number := 0;
    cursor c1 is
        select distinct codcomp,codcalen,dteeffec
          from tgrpwork
         where codcomp like b_index_codcomp||'%'
      order by codcomp, codcalen;
  begin
    initial_value(json_str_input);
    check_index;
    obj_row := json_object_t();

    if param_msg_error is null then
      for i in c1 loop
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codcomp',i.codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
        obj_data.put('codcalen',i.codcalen);
        obj_data.put('desc_codcalen',get_tcodec_name('TCODWORK',i.codcalen,global_v_lang));
        obj_data.put('dteeffec', to_char(i.dteeffec,'dd/mm/yyyy'));
        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
  --
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    json_obj    json_object_t;
    data_row    clob;
    v_row		    number := 0;
    v_response  varchar2(1000);
    v_dteeffec  date;
   /* cursor c1 is
      select distinct b.codcalen,dteeffec
        from tgrpwork a,temploy1 b
       where a.codcomp  = get_codcompy(b.codcomp)
         and a.codcalen = b.codcalen
         and b.codcomp like b_index_codcomp||'%'
         and b.staemp <> '9'
      union
      select codcalen,null as dteeffec
        from temploy1
       where codcomp like b_index_codcomp||'%'
         and codcalen not in (select distinct b.codcalen
                                from tgrpwork a,temploy1 b
                               where a.codcomp  = get_codcompy(b.codcomp)
                                 and a.codcalen = b.codcalen
                                 and b.codcomp like b_index_codcomp ||'%'
                                 and b.staemp <> '9')
         and staemp <> '9'
    group by codcalen
    order by codcalen;*/
    cursor c1 is
      select distinct codcalen
        from temploy1
       where codcomp like b_index_codcomp||'%'
         and staemp <> '9'
    order by codcalen;

  begin
    initial_value(json_str_input);
    check_index;
    json_obj := json_object_t();
    obj_row := json_object_t();

    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codcalen',i.codcalen);
      obj_data.put('desc_codcalen',get_tcodec_name('TCODWORK',i.codcalen,global_v_lang));
      begin
        select max(dteeffec)
          into v_dteeffec
          from tgrpwork
         where codcomp  = b_index_codcomp
           and codcalen = i.codcalen;
      exception when no_data_found then null;
      end;
      obj_data.put('dteeffec', nvl(to_char(v_dteeffec,'dd/mm/yyyy'),null));
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    data_row := obj_row.to_clob;

    v_response := get_response_message(null,param_msg_error,global_v_lang);
    json_obj.put('coderror',hcm_util.get_string_t(json_object_t(v_response),'coderror'));
    json_obj.put('response',hcm_util.get_string_t(json_object_t(v_response),'response'));
    json_obj.put('codcomp',b_index_codcomp);
    json_obj.put('table',data_row);

    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;
  --
  procedure get_detail2(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    json_obj    json_object_t;
    data_row    clob;
    v_row		    number := 0;
    v_startday  number;
    v_response  varchar2(1000);
    v_dteeffec  date;
    flgAdd      boolean;

    cursor c1 is
      select numseq,codshift,qtydwpp,qtydhpp,qtydaych,startday
        from tgrpwork
       where codcomp  = b_index_codcomp
         and codcalen = b_index_codcalen
         and dteeffec = v_dteeffec
    order by numseq;
  begin
    initial_value(json_str_input);
    check_index2;
    json_obj := json_object_t();
    obj_row  := json_object_t();
    begin
      select max(dteeffec) into v_dteeffec
        from tgrpwork
       where codcomp = b_index_codcomp
         and codcalen = b_index_codcalen
         and dteeffec = (select max(dteeffec)
                           from tgrpwork
                          where codcomp = b_index_codcomp
                            and codcalen = b_index_codcalen
                            and dteeffec <= b_index_dteeffec);
    exception when others then
      v_dteeffec := null;
    end;

    if v_dteeffec is null then
        begin
          select min(dteeffec) into v_dteeffec
            from tgrpwork
           where codcomp = b_index_codcomp
             and codcalen = b_index_codcalen
             and dteeffec = (select min(dteeffec)
                               from tgrpwork
                              where codcomp = b_index_codcomp
                                and codcalen = b_index_codcalen
                                and dteeffec > b_index_dteeffec);
        exception when others then
          v_dteeffec := null;
        end;        
    end if;

    if v_dteeffec is not null then
      begin
        select distinct startday
          into v_startday
          from tgrpwork
         where codcomp  = b_index_codcomp
           and codcalen = b_index_codcalen
           and dteeffec = nvl(v_dteeffec,dteeffec)
           and startday is not null;
      exception when others then
        v_startday := null;
      end;
    end if;
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('numseq',i.numseq);
      obj_data.put('codshift',i.codshift);
      obj_data.put('qtydwpp',i.qtydwpp);
      obj_data.put('qtydhpp',i.qtydhpp);
      obj_data.put('qtydaych',i.qtydaych);
      obj_data.put('startday',i.startday);
      if b_index_dteeffec < trunc(sysdate) then
        obj_data.put('flgAdd',false);
      else
        if b_index_dteeffec = v_dteeffec then
          obj_data.put('flgAdd',false);
        else
          obj_data.put('flgAdd',true);
        end if;
      end if;
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    data_row := obj_row.to_clob;

    v_response := get_response_message(null,param_msg_error,global_v_lang);
    json_obj.put('coderror',hcm_util.get_string_t(json_object_t(v_response),'coderror'));
    json_obj.put('response',hcm_util.get_string_t(json_object_t(v_response),'response'));
    if b_index_dteeffec < trunc(sysdate) and v_row > 0 then
      json_obj.put('dteeffec',to_char(v_dteeffec,'dd/mm/yyyy'));
      param_msg_error := get_error_msg_php('HR1501',global_v_lang);
      v_response      := get_response_message(null,param_msg_error,global_v_lang);
      json_obj.put('warning_message',hcm_util.get_string_t(json_object_t(v_response),'response'));
    else
      json_obj.put('dteeffec',to_char(b_index_dteeffec,'dd/mm/yyyy'));
      json_obj.put('warning_message', '');
    end if;
    json_obj.put('startday',v_startday);
    json_obj.put('table',data_row);

    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail2;
  --
  procedure save_data(json_str_input in clob,json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_numseq        number;
    v_sum           number := 0;
    v_codshift      varchar2(100 char);
    v_qtydwpp       number;
    v_qtydhpp       number;
    v_qtydaych      number;
    v_flg           varchar2(10 char);
    v_temp          varchar2(100 char);
    v_have_data     tgrpwork.codcomp%type;
  begin
    initial_value(json_str_input);
    check_save;
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then
      if param_json.get_size > 0 then
        for i in 0..param_json.get_size-1 loop
          param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
          v_numseq    := hcm_util.get_string_t(param_json_row,'numseq');
          v_codshift  := hcm_util.get_string_t(param_json_row,'codshift');
          v_qtydwpp   := nvl(hcm_util.get_string_t(param_json_row,'qtydwpp'),0);
          v_qtydhpp   := nvl(hcm_util.get_string_t(param_json_row,'qtydhpp'),0);
          v_qtydaych  := nvl(hcm_util.get_string_t(param_json_row,'qtydaych'),0);
          v_flg       := hcm_util.get_string_t(param_json_row,'flg');

          if v_flg = 'add' then
            check_insert(v_codshift,v_codcomp);
            if param_msg_error is null then
              if v_sum = 0 then
                v_numseq := gen_numseq(v_codcomp,v_codcalen,v_dteeffec);
                v_sum := v_numseq;
              else
                v_numseq := v_sum + 1;
                v_sum := v_sum + 1;
              end if;
              begin

                insert into tgrpwork(codcomp, codcalen, dteeffec, numseq, codshift,
                                     qtydwpp, qtydhpp, qtydaych, startday, codcreate, coduser)
                             values (v_codcomp, v_codcalen, v_dteeffec, v_numseq, v_codshift,
                                     v_qtydwpp, v_qtydhpp, v_qtydaych, v_startday, global_v_coduser, global_v_coduser);
              exception when dup_val_on_index then
                begin
                  update  tgrpwork
                  set     codshift = v_codshift,
                          qtydwpp  = v_qtydwpp,
                          qtydhpp  = v_qtydhpp,
                          qtydaych = v_qtydaych,
                          startday = v_startday,
                          coduser  = global_v_coduser
                    where codcomp  = v_codcomp
                      and codcalen = v_codcalen
                      and dteeffec = v_dteeffec
                      and numseq   = v_numseq;
                exception when others then
                  rollback;
                end;
              end;
            end if;
          elsif v_flg = 'edit' then
           check_insert(v_codshift,v_codcomp);
           begin
              update  tgrpwork
              set     codshift = v_codshift,
                      qtydwpp  = v_qtydwpp,
                      qtydhpp  = v_qtydhpp,
                      qtydaych = v_qtydaych,
                      startday = v_startday,
                      coduser  = global_v_coduser
                where codcomp  = v_codcomp
                  and codcalen = v_codcalen
                  and dteeffec = v_dteeffec
                  and numseq   = v_numseq;
            exception when others then
              rollback;
            end;
          elsif v_flg = 'delete' then
              delete from tgrpwork
                    where codcomp  = v_codcomp
                      and codcalen = v_codcalen
                      and dteeffec = v_dteeffec
                      and numseq   = v_numseq;
          end if;
        end loop;
      else
        begin
          select codcomp
            into v_have_data
            from tgrpwork
           where codcomp  = v_codcomp
             and codcalen = v_codcalen
             and rownum <= 1;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2870', global_v_lang);
        end;
      end if;

      if param_msg_error is null then
        if v_flg = 'add' or v_flg = 'edit' then
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        elsif v_flg = 'delete' then 
            param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        end if;
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_data;

end HRAL1KE;

/

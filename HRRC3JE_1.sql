--------------------------------------------------------
--  DDL for Package Body HRRC3JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC3JE" AS

  procedure initial_current_user_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_current_user_value;

  procedure initial_params(data_obj json_object_t) as
  begin
--  index parameter
    p_codemprc     := hcm_util.get_string_t(data_obj,'p_codemprc');
    p_codcomp      := hcm_util.get_string_t(data_obj,'p_codcomp');
    p_dtereqst     := to_date(hcm_util.get_string_t(data_obj,'p_dtereqst'),'dd/mm/yyyy');
    p_dtereqen     := to_date(hcm_util.get_string_t(data_obj,'p_dtereqen'),'dd/mm/yyyy');
    p_flgtrans     := hcm_util.get_string_t(data_obj,'p_flgtrans');
--  detail parameter
    p_codpos       := hcm_util.get_string_t(data_obj,'p_codpos');
    p_numreqst     := hcm_util.get_string_t(data_obj,'p_numreqst');
    p_codjob       := hcm_util.get_string_t(data_obj,'p_codjob');

    if p_codpos is null then
      p_codpos       := hcm_util.get_string_t(data_obj,'codpos');
    end if;
    if p_flgtrans is null then
      p_flgtrans       := hcm_util.get_string_t(data_obj,'flgtrans');
    end if;
    if p_numreqst is null then
      p_numreqst       := hcm_util.get_string_t(data_obj,'numreqst');
    end if;
--  save parameter
    p_dtepost      := to_date(hcm_util.get_string_t(data_obj,'p_dtepost'), 'dd/mm/yyyy');
    if p_dtepost is null then
      p_dtepost       := to_date(hcm_util.get_string_t(data_obj,'dtepost'), 'dd/mm/yyyy');
    end if;
    p_codjobpost   := hcm_util.get_string_t(data_obj,'p_codjobpost');
    p_flag         := hcm_util.get_string_t(data_obj,'p_flag');
    p_dteclose     := to_date(hcm_util.get_string_t(data_obj,'p_dteclose'),'dd/mm/yyyy');
    p_welfare      := hcm_util.get_string_t(data_obj,'p_welfare');
    p_remark       := hcm_util.get_string_t(data_obj,'p_remark');

  end initial_params;

  function check_index return boolean as
    v_temp     varchar(1 char);
  begin
--  check recuiter
    begin
      select 'X' into v_temp
        from temploy1
       where codempid = p_codemprc
         and staemp in('1', '3');
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TEMPLOY1');
      return false;
    end;

--  check secur2
    if secur_main.secur2(p_codemprc,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = false then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return false;
    end if;

--  check codcomp
    if p_codcomp is not null then
      begin
        select 'X' into v_temp
          from tcenter
         where codcomp like codcomp || '%'
           and rownum = 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
        return false;
      end;

--  check secur 7
      if secur_main.secur7(p_codcomp, global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return false;
      end if;
    end if;

--  check date
    if p_dtereqst > p_dtereqen then
        param_msg_error := get_error_msg_php('HR2021', global_v_lang);
        return false;
    end if;

    return true;

  end;

  function check_params return boolean as
    v_temp      varchar(1 char);
    v_counter   number := 0;
  begin

    if p_dteclose < p_dtepost then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return false;
    end if;

    if p_flag = 'add' then
      begin
        select count(codjobpost) into v_counter
          from tjobpost
         where numreqst   = p_numreqst
           and codpos     = p_codpos
           and codjobpost = p_codjobpost
           and dtepost    = p_dtepost;
      end;
      if v_counter <> 0 then
        param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'TJOBPOST');
        return false;
      end if;

    elsif p_flag = 'delete' then ----
      if trunc(sysdate) > p_dtepost then ----
        param_msg_error := get_error_msg_php('HR1490', global_v_lang); ----temporary errorno
        return false;
      end if;

      begin
        select count(codjobpost) into v_counter
          from tjobposte
         where codcomp    = p_codcomp
           and codjobpost = p_codjobpost
           and dtepost    = p_dtepost;
      end;
      if v_counter <> 0 then
--#8184 || 17/08/2022
        delete from tjobposte where codcomp = p_codcomp and codjobpost = p_codjobpost and dtepost = p_dtepost;
        --param_msg_error := get_error_msg_php('CO0030', global_v_lang, 'TJOBPOSTE');
        --return false;
--#8184 || 17/08/2022
      end if;
    end if;

    return true;

  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_dtepost       tjobpost.dtepost%type;
    v_dteclose      tjobpost.dteclose%type;
    v_qtyjobpost    number;
    v_flgtrans      tjobpost.flgtrans%type := 'Y';
    v_istransferable  number := 0;
    v_codjob        tjobdet.codjob%type;
    v_jobdesc       varchar2(4000 char);
    v_isfirst       boolean;
    row_id          varchar2(1000 char);
    cursor c1 is
      select a.numreqst, b.codpos, b.dtereqm, b.codbrlc, b.codjob,
             b.desnote, a.codcomp, b.qtyreq, b.dteopen, b.dteclose, statement
             , b.welfare -- softberry || 16/02/2023 || #8852
      from treqest1 a, treqest2 b
      where a.numreqst = b.numreqst
        and b.flgrecut in ('E','O')
--          and b.flgrecut = 'E'
        and b.codemprc = p_codemprc
        and a.codcomp like nvl(p_codcomp || '%', a.codcomp)
        and a.dtereq between p_dtereqst and p_dtereqen
      order by a.numreqst, b.codpos;
    cursor c2 is
      select itemno, namitem
      from tjobdet
      where codjob = v_codjob
      order by itemno asc;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
      v_codjob := i.codjob;
      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('numreqst', i.numreqst);
      obj_data.put('codpos', i.codpos);
      obj_data.put('codcomp', i.codcomp);
      obj_data.put('codcompy',get_codcomp_bylevel(i.codcomp, 1, null));
      obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
      obj_data.put('dtereqm', to_char(i.dtereqm, 'dd/mm/yyyy'));
      obj_data.put('codbrlc', i.codbrlc);
      obj_data.put('desc_codbrlc', get_tcodec_name('TCODLOCA',i.codbrlc, global_v_lang));
      obj_data.put('codjob', i.codjob);
      obj_data.put('desc_syncond',get_logical_desc(i.statement));
      obj_data.put('desc_codjob', i.codjob);
      obj_data.put('desnote', i.desnote);
      obj_data.put('qtyreq', i.qtyreq);   -- Adisak 20/03/2023 14:46 redmine 4448#8183
      obj_data.put('welfare', i.welfare); -- softberry || 16/02/2023 || #8852

      v_jobdesc := '';
      v_isfirst := true;
      for r2 in c2 loop
        if not v_isfirst then
          v_jobdesc := v_jobdesc || '<br>';
        end if;
        v_isfirst := false;
        v_jobdesc := v_jobdesc || r2.itemno || '. ' || r2.namitem;
      end loop;
      obj_data.put('jobdesc', v_jobdesc);
      begin
        select max(dtepost), count(distinct codjobpost) into v_dtepost, v_qtyjobpost
          from tjobpost
         where numreqst = i.numreqst
           and codpos = i.codpos;
      end;
      begin
        select  dteclose
        into    v_dteclose
        from    tjobpost
        where   dtepost = (select max(dtepost) from tjobpost where numreqst = i.numreqst and codpos = i.codpos)
        and     numreqst = i.numreqst
        and     codpos = i.codpos;
      exception when no_data_found then
        v_dteclose := i.dteclose;
      end;
      begin
        select count('x') into v_istransferable
        from tjobpost
        where numreqst = i.numreqst
          and codpos = i.codpos
          and codjobpost = '0001'
          and flgtrans = 'N';
      end;
      if v_istransferable > 0 then
        obj_data.put('istransferable', 'Y');
      else
        obj_data.put('istransferable', 'N');
      end if;
      obj_data.put('flgtrans', v_flgtrans);
      obj_data.put('dtepost', to_char(v_dtepost, 'dd/mm/yyyy'));
      obj_data.put('dteopen', to_char(v_dtepost, 'dd/mm/yyyy'));     -- Adisak 20/03/2023 14:46 redmine 4448#8183
      obj_data.put('dteclose', to_char(v_dteclose, 'dd/mm/yyyy'));   -- Adisak 20/03/2023 14:46 redmine 4448#8183
      obj_data.put('qtyjobpost', v_qtyjobpost);
      obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
--    dbms_lob.createtemporary(json_str_output, true);
    json_str_output := obj_rows.to_clob;

  end gen_index;

  procedure gen_detail(json_str_output out clob) as
    obj_data        json_object_t;
    obj_rows        json_object_t;
    v_row           number := 0;
    v_welfare       treqest2.welfare%type;

    cursor c1 is
      select dtepost, codjobpost, dteclose, remark, codcomp
      from tjobpost
      where numreqst = p_numreqst
        and codpos = p_codpos
      order by dtepost, codjobpost;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('dtepost', to_char(i.dtepost, 'dd/mm/yyyy'));
      obj_data.put('codjobpost', i.codjobpost);
      obj_data.put('dteclose', to_char(i.dteclose, 'dd/mm/yyyy'));
      obj_data.put('remark', i.remark);
      obj_data.put('codcomp', i.codcomp);
      begin
        select welfare into v_welfare
          from treqest2
         where numreqst = p_numreqst
           and codpos = p_codpos;
      exception when no_data_found then
        v_welfare := '';
      end;
      obj_data.put('welfare', v_welfare);
      obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_detail;

  procedure gen_jobdescription(json_str_output out clob) as
    obj_data        json_object_t;
    obj_row        json_object_t;

    v_row  number :=0;

  cursor c1 is
    select itemno, namitem
    from tjobdet
    where codjob = p_codjob
    order by itemno asc;

  begin

    obj_row := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('itemno', i.itemno);
        obj_data.put('namitem', i.namitem);
        obj_row.put(v_row-1, obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_jobdescription;

  procedure insert_or_update_tjobpost(v_treqest1_codcomp varchar2) as
  begin
    begin
        insert into tjobpost
            (
                numreqst, codpos, codjobpost, dtepost, codcomp,
                dteclose, welfare, flgtrans, remark,
                codcreate, coduser
            )
        values
            (
                p_numreqst, p_codpos, p_codjobpost, p_dtepost, rpad(v_treqest1_codcomp,40,'0'),
                p_dteclose, p_welfare, 'N', p_remark, global_v_coduser, global_v_coduser
            );
    exception when dup_val_on_index then
     update tjobpost
        set codcomp = p_codcomp,
            dteclose = p_dteclose,
            welfare = p_welfare,
            remark = p_remark,
            coduser = global_v_coduser,
            flgtrans = 'N'
        where numreqst = p_numreqst
          and codpos= p_codpos
          and codjobpost = p_codjobpost
          and dtepost = p_dtepost;
    end;

  end insert_or_update_tjobpost;

  procedure delete_tjobpost as
  begin
--    if sysdate > p_dtepost then  -- #8184 || 17/08/2022|
        delete tjobpost
        where numreqst = p_numreqst
          and codpos = p_codpos
          and codjobpost = p_codjobpost
          and dtepost = p_dtepost;
--    end if;  -- #8184 || 17/08/2022

  end delete_tjobpost;

  procedure insert_or_update_tjobposte(v_qtypos number,v_treqest1_codcomp  treqest1.codcomp%type) as
  begin
    begin
        insert into tjobposte
            (
                codjobpost, dtepost, codcomp, qtypos,
                codcreate, coduser
            )
        values
            (
                p_codjobpost, p_dtepost, rpad(v_treqest1_codcomp,40,'0'), v_qtypos,
                global_v_coduser, global_v_coduser

            );
    exception when DUP_VAL_ON_INDEX then
        update tjobposte
        set qtypos = v_qtypos
        where codjobpost = p_codjobpost
          and dtepost = p_dtepost
          and codcomp = p_codcomp;
    end;

  end insert_or_update_tjobposte;

  procedure update_treqest1 as
  begin
    update treqest1
    set stareq = 'P'
    where numreqst = p_numreqst
      and nvl(stareq, 'N') = 'N';

  end update_treqest1;

  procedure update_treqest2 as
  begin
    update treqest2
    set dtepost = p_dtepost,
        welfare = p_welfare
    where numreqst = p_numreqst
      and codpos = p_codpos
      and dtepost is null;

  end update_treqest2;

  procedure insert_job as
  begin
        update tjobpost
        set flgtrans = nvl(p_flgtrans, 'N')
        where codpos = p_codpos
        and numreqst = p_numreqst
        and dtepost = p_dtepost
        and codjobpost = '0001';
  end insert_job;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  begin
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    if check_index then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index;

  procedure get_detail(json_str_input in clob, json_str_output out clob) AS
  begin
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_detail(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_detail;

  procedure get_jobdescription(json_str_input in clob, json_str_output out clob) AS
  begin
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_jobdescription(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_jobdescription;

  procedure save_index(json_str_input in clob, json_str_output out clob) AS
    json_obj            json_object_t;
    data_obj            json_object_t;
    v_qtypos            number := 0;
    v_treqest1_codcomp  treqest1.codcomp%type;
  begin
    initial_current_user_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    v_treqest1_codcomp := hcm_util.get_string_t(json_obj, 'p_codcomp');
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    initial_params(json_obj);
    begin
        update treqest2
        set welfare = p_welfare
        where numreqst = p_numreqst
          and codpos = p_codpos;
    end;
    for i in 0..param_json.get_size-1 loop
      data_obj  := hcm_util.get_json_t(param_json, to_char(i));
      initial_params(data_obj);
      if check_params then ----
        if p_flag = 'delete' then
          delete_tjobpost;
        else
          insert_or_update_tjobpost(v_treqest1_codcomp);

          begin
            select count(*) into v_qtypos
              from tjobpost
             where codjobpost = p_codjobpost
               and dtepost    = p_dtepost
               and codcomp    = v_treqest1_codcomp;
          end;

          insert_or_update_tjobposte(v_qtypos,v_treqest1_codcomp);

          update_treqest2;

          update_treqest1;

        end if;
      else
        exit;
      end if;
        /*----
        if p_flag = 'delete' then
            delete_tjobpost;
        else
            if check_params then

                insert_or_update_tjobpost(v_treqest1_codcomp);

                select count(*) into v_qtypos
                from tjobpost
                where codjobpost = p_codjobpost
                  and dtepost = p_dtepost
                  and codcomp = p_codcomp;

                insert_or_update_tjobposte(v_qtypos,v_treqest1_codcomp);

                update_treqest2;

                update_treqest1;

            else
                exit;
            end if;
        end if;*/
    end loop;

    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END save_index;

  procedure save_transfer(json_str_input in clob, json_str_output out clob) AS
    json_obj       json_object_t;
    data_obj       json_object_t;
    v_qtypos       number := 0;
  begin
    initial_current_user_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    for i in 0..param_json.get_size-1 loop
        data_obj := hcm_util.get_json_t(param_json,to_char(i));
        initial_params(data_obj);
        insert_job;
    end loop;

    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END save_transfer;

  procedure gen_export_excel_data(json_str_output out clob) as
    data_obj    json_object_t;
    obj_data    json_object_t;
    obj_rows    json_object_t := json_object_t();
    v_row       number := 0;
    v_codbrlc   treqest2.codbrlc%type;
    v_qtyreq    treqest2.qtyreq%type;
    v_codjob    treqest2.codjob%type;
    v_jobdesc   clob;
    v_desnote   treqest2.desnote%type;
    v_syncond   treqest2.syncond%type;
    v_statement   treqest2.statement%type;
    v_flgcond   treqest2.flgcond%type;
    v_flgjob    treqest2.flgjob%type;
    v_codemprc  treqest2.codemprc%type;
    v_email     temploy1.email%type;

    cursor c1 is
      select numreqst,codpos,codjobpost,dtepost,codcomp,dteclose,welfare,rownum
        from tjobpost
       where numreqst = p_numreqst
         and codpos = p_codpos
         and codjobpost = '0001'
         and flgtrans = 'N'
       order by numreqst,codpos,codjobpost;

    cursor c2 is
      select itemno, namitem
        from tjobdet
       where codjob = v_codjob
       order by itemno asc;
  begin
    for i in 0..param_json.get_size-1 loop
      data_obj := hcm_util.get_json_t(param_json,to_char(i));
      initial_params(data_obj);
      for i in c1 loop
        v_row := v_row+1;
        begin
          select codbrlc, qtyreq, codjob, desnote, flgcond, flgjob, syncond, codemprc, statement
            into v_codbrlc, v_qtyreq, v_codjob, v_desnote, v_flgcond, v_flgjob, v_syncond, v_codemprc,v_statement
            from treqest2
           where numreqst = i.numreqst
             and codpos = i.codpos;
        exception when no_data_found then
          v_codbrlc := '';
        end;
        for b in c2 loop
          v_jobdesc := v_jobdesc||b.itemno||'. '||b.namitem||chr(10);
        end loop;
        if v_flgcond = 'Y' then
          v_syncond := v_syncond;
        elsif v_flgjob = 'Y' then
          begin
            select syncond, statement into v_syncond, v_statement
              from tjobcode
             where codjob = v_codjob;
          exception when no_data_found then
            v_syncond := '';
          end;
        end if;
        begin
          select email into v_email
            from temploy1
           where codempid = v_codemprc;
        exception when no_data_found then
          v_codemprc := '';
        end;
        obj_data := json_object_t();
        obj_data.put('job_id',to_char(sysdate,'yyyymmdd')||lpad(i.rownum,4,'0'));
        obj_data.put('numreqst',i.numreqst);
        obj_data.put('codpos',i.codpos);
        obj_data.put('codcompy',substr(i.codcomp,1,3));
        obj_data.put('codcomp',i.codcomp);
        obj_data.put('codcompy',get_codcomp_bylevel(i.codcomp, 1, null));
        obj_data.put('codbrlc',v_codbrlc);
        obj_data.put('codjobpost',i.codjobpost);
        obj_data.put('dtepost',to_char(i.dtepost,'dd/mm/yyyy'));
        obj_data.put('dteclose',to_char(i.dteclose,'dd/mm/yyyy'));
        obj_data.put('qtyreq',v_qtyreq);
        obj_data.put('jobdesc',v_jobdesc);
        obj_data.put('jobspec',v_desnote);
        obj_data.put('welfare',i.welfare);
        obj_data.put('syncond',v_syncond);
        obj_data.put('desc_syncond',get_logical_desc(v_statement));
        obj_data.put('codemprc',v_codemprc);
        obj_data.put('emailemprc',v_email);
        obj_data.put('codjob', get_tjobcode_name(v_codjob,global_v_lang));
        obj_rows.put(to_char(v_row-1),obj_data);
      end loop;
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);
  end gen_export_excel_data;

  procedure get_export_excel_data(json_str_input in clob, json_str_output out clob) as
    json_obj    json_object_t;
  begin
    initial_current_user_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    gen_export_excel_data(json_str_output);
   exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_export_excel_data;

END HRRC3JE;

/

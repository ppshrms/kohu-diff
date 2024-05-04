--------------------------------------------------------
--  DDL for Package Body HRRC26E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC26E" AS

  procedure initial_current_user_value(json_str_input in clob) as
   json_obj json_object_t;
  begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

  end initial_current_user_value;

  procedure initial_params(data_obj json_object_t) as
  begin
--  get detail parameter
        p_codcomp       := hcm_util.get_string_t(data_obj, 'p_codcomp');
        p_codpos        := hcm_util.get_string_t(data_obj, 'p_codpos');
        p_dteapplst     := to_date(hcm_util.get_string_t(data_obj, 'p_dteapplst'), 'dd/mm/yyyy');
        p_dteapplen     := to_date(hcm_util.get_string_t(data_obj, 'p_dteapplen'), 'dd/mm/yyyy');
        p_statappl      := hcm_util.get_string_t(data_obj, 'p_statappl');
        p_syncond       := hcm_util.get_string_t(data_obj, 'p_syncond');
        p_list_syncond  := hcm_util.get_json_t(data_obj, 'p_list_syncond');
--  save index parameter
        p_numreqst      := hcm_util.get_string_t(data_obj, 'p_numreqst');
        p_qtyscore      := hcm_util.get_string_t(data_obj, 'p_qtyscore');
        p_numappl       := hcm_util.get_string_t(data_obj, 'p_numappl');

  end initial_params;

  function check_index return boolean as
    v_temp      varchar(1 char);
    v_qtyreq    number := 0;
    v_qtyact    number := 0;
  begin
--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
        return false;
    end;

--  check secur7 
    if secur_main.secur7(p_codcomp, global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return false;
    end if;

--  check position
    begin
        select 'X' into v_temp
        from tpostn
        where codpos = p_codpos;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TPOSTN');
        return false;
    end;

--  check date
    if p_dteapplst > p_dteapplen then
        param_msg_error := get_error_msg_php('HR2021', global_v_lang);
        return false;
    end if;

    begin
      select nvl(sum(qtyreq),0),nvl(sum(qtyact),0) into v_qtyreq,v_qtyact
        from treqest2
       where codcomp  like p_codcomp || '%'
         and codpos   = p_codpos
         and flgrecut in ('E','O');
    end;

    if v_qtyreq = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TREQEST2');
      return false;
    elsif v_qtyact >= v_qtyreq then
      param_msg_error := get_error_msg_php('HR4502', global_v_lang);
      return false;
    end if;

    return true;
  end;

  function check_params return boolean as
    v_qtyact   treqest2.qtyact%type;
    v_qtyreq   treqest2.qtyreq%type;
  begin
    if p_statappl = '21' then
      begin
        select qtyact, qtyreq into v_qtyact, v_qtyreq
          from treqest2
         where numreqst = p_numreqst
           and codpos   = p_codpos
           and flgrecut in ('E','O');
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TREQEST2');
          return false;
      end;

      if v_qtyact >= v_qtyreq then
        param_msg_error := get_error_msg_php('HR4502', global_v_lang);
        return false;
      end if;
    end if;
    return true;
  end;

  procedure gen_detail(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_statement     long;
    v_count         number := 0;
    data_obj        json_object_t;
    obj_syncond     json_object_t;
    v_syncond       long;
    v_score         varchar(10 char);
    obj_score1      json_object_t := json_object_t();
    obj_score2      json_object_t := json_object_t();
    obj_score3      json_object_t := json_object_t();
    obj_score4      json_object_t := json_object_t();
    obj_score5      json_object_t := json_object_t();
    obj_score0      json_object_t := json_object_t(); -- softberry || 10/02/2023 || #8840
    v_row1          number :=0;
    v_row2          number :=0;
    v_row3          number :=0;
    v_row4          number :=0;
    v_row5          number :=0;
    v_row0          number :=0;  -- softberry || 10/02/2023 || #8840
    sv_age          number :=0;
    v_data          varchar2(1) := 'N';
    v2_exists       varchar2(1) := 'N';
    v_resume_name   tappldoc.namdoc%type;
    v_resume_file   tappldoc.filedoc%type;

  cursor c1 is
    select a.numappl, decode(global_v_lang, '101', a.namempe,
                                            '102', a.namempt,
                                            '103', a.namemp3,
                                            '104', a.namemp4,
                                            '105', a.namemp5) namemp,
            a.dteappl, a.codposl, statappl, numreql, numdoc,dteempdb
       from tapplinf a
      where (a.codcompl is null or a.codcompl like p_codcomp||'%')
        and (a.codpos1  = p_codpos
         or  a.codpos2  is not null and a.codpos2 = p_codpos)
        and dteappl     between p_dteapplst and p_dteapplen
        and a.statappl  = p_statappl
   order by a.numappl;

  begin
    obj_rows := json_object_t();
    v2_exists := 'N';
    for i in c1 loop
      if p_syncond is not null and v2_exists = 'N' then--V_HRRC26.SV_EXP
        v2_exists := 'Y';
        p_syncond := ' and '||p_syncond;
        p_syncond := replace(p_syncond,'V_HRRC26.CODEDLV','TEDUCATN.CODEDLV');-- boy 02/04/2022 : delete this line when fix error
        p_syncond := replace(p_syncond,'V_HRRC26E.NUMGPA','TEDUCATN.NUMGPA');--'TEDUCATN.NUMGPA');        
        p_syncond := replace(p_syncond,'V_HRRC26.CODLANG','TLANGABI.CODLANG');  -- softberry || 20/03/2023 || #8694      
        p_syncond := replace(p_syncond,'V_HRRC26.SV_EXP','TRUNC(TRUNC(MONTHS_BETWEEN(sysdate,NVL(TAPPLWEX.DTESTART,sysdate))) / 12)'); --#8180 || 09/08/2022       
        sv_age    := trunc(( months_between(sysdate,i.dteempdb)/12));
        p_syncond := replace(p_syncond,'TAPPLINF.SV_AGE',sv_age);        
      end if;
      v_statement := 'select count(tapplinf.numappl) '||
                     '  from tapplinf, tapplfm, teducatn, tapplref, tapplwex, tcmptncy, tlangabi '||   -- softberry || 20/03/2023 || #8694 ||  '  from tapplinf, tapplfm, teducatn, tapplref, tapplwex, tcmptncy '||   
                     ' where tapplinf.numappl = '||''''||i.numappl||''''||' '||
                     '   and tapplinf.numappl = tapplfm.numappl(+) '||
                     '   and tapplinf.numappl = teducatn.numappl(+) '||
                     '   and tapplinf.numappl = tapplref.numappl(+) '||
                     '   and tapplinf.numappl = tapplwex.numappl(+) '||
                     '   and tapplinf.numappl = tlangabi.numappl(+) '|| -- softberry || 20/03/2023 || #8694
                     '   and tapplinf.numappl = tcmptncy.numappl(+) '||p_syncond;  
      execute immediate v_statement into v_count;
      if v_count > 0 then
        v_data   := 'Y';
        v_count  := 0;
        v_score  := 0;
        for i2 in 0..p_list_syncond.get_size-1 loop
          data_obj    := hcm_util.get_json_t(p_list_syncond, to_char(i2));
          --v_score     := hcm_util.get_string_t(data_obj, 'score');
          obj_syncond := hcm_util.get_json_t(data_obj, 'syncond');
          v_syncond   := hcm_util.get_string_t(obj_syncond, 'code');
          if v_syncond is not null then
            v_syncond := replace(v_syncond,'V_HRRC26.CODLANG','TLANGABI.CODLANG');  -- softberry || 20/03/2023 || #8694
            v_syncond := ' and '||v_syncond;
            v_syncond := replace(v_syncond,'V_HRRC15E','v_hrrc26');-- boy 02/04/2022 : delete this line when fix error

            v_statement := 'select count(v_hrrc26.numappl) '||
                           '  from v_hrrc26 '||
                           ' where v_hrrc26.numappl = '||''''||i.numappl||''''||' '||v_syncond;
            execute immediate v_statement into v_count;
              if v_count > 0 then
                v_score  := hcm_util.get_string_t(data_obj, 'score');
                exit;
              end if; -- v_count > 0
          end if;
        end loop; -- i2 in 0..p_list_syncond.get_size-1
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('status', i.statappl);
        obj_data.put('desc_status', get_tlistval_name('STATAPPL', i.statappl, global_v_lang));
        obj_data.put('score', v_score);
        obj_data.put('scored', v_score);
        obj_data.put('numappl', i.numappl);
        obj_data.put('name', i.namemp);
        obj_data.put('dteappl', to_char(i.dteappl, 'dd/mm/yyyy'));
        obj_data.put('desc_codpos', get_tpostn_name(i.codposl, global_v_lang));
        obj_data.put('desc_codposa', '');
        obj_data.put('numreq', i.numreql);
        obj_data.put('codposr', i.codposl);
        obj_data.put('desc_codposr', get_tpostn_name(i.codposl, global_v_lang));
        begin
            select namdoc, filedoc into v_resume_name,v_resume_file
              from tappldoc
             where numappl = i.numappl
               and flgresume = 'Y';
        exception when no_data_found then
            v_resume_name := null;
            v_resume_file := null;
        end;
        obj_data.put('resume',v_resume_name);
        obj_data.put('path_filename',get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||v_resume_file); -- adisak redmine#9311 04/04/2023 19:10

        if v_score = '1' then
          v_row1 := v_row1+1;
          obj_score1.put(to_char(v_row1-1),obj_data);
        elsif v_score = '2' then
          v_row2 := v_row2+1;
          obj_score2.put(to_char(v_row2-1),obj_data);
        elsif v_score = '3' then
          v_row3 := v_row3+1;
          obj_score3.put(to_char(v_row3-1),obj_data);
        elsif v_score = '4' then
          v_row4 := v_row4+1;
          obj_score4.put(to_char(v_row4-1),obj_data);
        elsif v_score = '5' then
          v_row5 := v_row5+1;
          obj_score5.put(to_char(v_row5-1),obj_data);
--<<  softberry || 10/02/2023 || #8840
        else
          v_row0 := v_row0+1;
          obj_score0.put(to_char(v_row0-1),obj_data);  
-->>  softberry || 10/02/2023 || #8840        
        end if;
      end if; -- v_count > 0
    end loop; -- i in c1 loop

    v_row := 0;
    for i1 in 0..obj_score5.get_size-1 loop
        v_row := v_row+1;
        obj_rows.put(to_char(v_row-1),obj_score5.get(to_char(i1)));
    end loop;
    for i2 in 0..obj_score4.get_size-1 loop
      v_row := v_row+1;
      obj_rows.put(to_char(v_row-1),obj_score4.get(to_char(i2)));
    end loop;
    for i3 in 0..obj_score3.get_size-1 loop
      v_row := v_row+1;
      obj_rows.put(to_char(v_row-1),obj_score3.get(to_char(i3)));
    end loop;
    for i4 in 0..obj_score2.get_size-1 loop
      v_row := v_row+1;
      obj_rows.put(to_char(v_row-1),obj_score2.get(to_char(i4)));
    end loop;
    for i5 in 0..obj_score1.get_size-1 loop
      v_row := v_row+1;
      obj_rows.put(to_char(v_row-1),obj_score1.get(to_char(i5)));
    end loop;
--<<  softberry || 10/02/2023 || #8840
    for i0 in 0..obj_score0.get_size-1 loop
      v_row := v_row+1;
      obj_rows.put(to_char(v_row-1),obj_score0.get(to_char(i0)));
    end loop;
-->> softberry || 10/02/2023 || #8840
    if v_data = 'N' then -- if obj_rows.get_size() = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPLINF');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    else
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end if;
  end gen_detail;

  procedure gen_index_syncond(json_str_output out clob) as
    obj_row             json_object_t;
    obj_syncond         json_object_t;
    obj_data            json_object_t;
    v_row               number  := 0;

    cursor c1 is
        select numseq, syncond, qtyscore ,statement
          from tposcond
         where codapp = 'HRRC26E'
           and codpos = p_codpos
         order by numseq;
    begin
        obj_row := json_object_t();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('code',i.syncond);
            obj_data.put('description',get_logical_desc(i.statement));
            obj_data.put('statement',i.statement);
            obj_syncond := json_object_t();
            obj_syncond.put('syncond',obj_data);
            obj_syncond.put('qtyscore',i.qtyscore);
            obj_syncond.put('grade','');
            obj_row.put(to_char(v_row-1),obj_syncond);
        end loop;

        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);

  end gen_index_syncond;

  procedure update_tapplinf as
    v_codcomp   treqest1.codcomp%type; -- user4 || 29/03/2023 || 4448#9317
  begin
    --<< user4 || 29/03/2023 || 4448#9317
    begin
        select codcomp into v_codcomp from treqest1 where numreqst = p_numreqst;
    exception when no_data_found then
        v_codcomp := null;
    end;
    -->> user4 || 29/03/2023 || 4448#9317

    update tapplinf
    set statappl = p_statappl,
        numreql = p_numreqst,
        codposl = p_codpos,
        codcompl = v_codcomp, -- user4 || 29/03/2023 || 4448#9317
        qtyscore = p_qtyscore,
        dtefoll = sysdate,
        coduser = global_v_coduser
    where numappl = p_numappl;

  end update_tapplinf;

  procedure insert_tappfoll as
  begin
    insert into tappfoll
        (
            numappl, dtefoll, statappl, numreqst, codpos, codcreate, coduser
        )
    values
        (
            p_numappl, sysdate, p_statappl, p_numreqst, p_codpos, global_v_coduser, global_v_coduser
        );

  end insert_tappfoll;

  procedure update_treqest1 as
  begin
    update treqest1
       set dterec = sysdate,
           coduser = global_v_coduser
     where numreqst = p_numreqst;

  end update_treqest1;

  procedure update_treqest2 as
  begin
    update treqest2
       set dtechoose = sysdate,
           coduser = global_v_coduser
     where numreqst = p_numreqst
       and codpos = p_codpos;

  end update_treqest2;

  procedure get_detail(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    if check_index then
        gen_detail(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_detail;

  procedure get_index_syncond(json_str_input in clob, json_str_output out clob) as
  begin
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_index_syncond(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  end get_index_syncond;

  procedure save_index(json_str_input in clob, json_str_output out clob) AS
    json_obj       json_object_t;
    data_obj       json_object_t;
  begin
    initial_current_user_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    for i in 0..param_json.get_size-1 loop
        data_obj  := hcm_util.get_json_t(param_json, to_char(i));
        initial_params(data_obj);
        if check_params then
           update_tapplinf;
           insert_tappfoll;
           update_treqest1;
           update_treqest2;
        else
            exit;
        end if;
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

    procedure send_mail_a(data_obj json_object_t) as
        v_rowid         varchar(20);

        json_obj        json_object_t;
        v_codform       TFWMAILH.codform%TYPE;
        v_codapp        TFWMAILH.codapp%TYPE;

        v_error             varchar2(4000 char);
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr           varchar2(500 char);
        v_subject           varchar2(500 char);

        v_msg           clob;

        v_email         varchar(200);
        v_codintview    treqest1.codintview%type;

        v_numreqst      tapplinf.numreql%type;
        v_numappl       tapplinf.numappl%type;
        v_status        tapplinf.statappl%type;

    begin

        v_subject  := get_label_name('HRRC26E1', global_v_lang, 80);
        v_codapp   := 'HRRC26E';
        begin
            select codform into v_codform
            from tfwmailh
            where codapp = v_codapp;
        exception when no_data_found then
            v_codform  := 'HRRC26E';
        end;

        v_numreqst  := hcm_util.get_string_t(data_obj, 'numreq');
        v_numappl   := hcm_util.get_string_t(data_obj, 'numappl');
        v_status   := hcm_util.get_string_t(data_obj, 'status');

        if v_status = '21' then

          chk_flowmail.get_message(v_codapp, global_v_lang, v_msg_to, v_templete_to, v_func_appr);

          -- replace employee param
          begin
              select rowid into v_rowid
              from TAPPLINF
              where numappl = v_numappl;
          exception when no_data_found then
              v_rowid := '';
          end;
          chk_flowmail.replace_text_frmmail(v_templete_to, 'TAPPLINF', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

          -- replace employee param email reciever param
          begin
              select rowid,codintview into v_rowid,v_codintview
              from treqest1
              where numreqst = v_numreqst;
          exception when no_data_found then
              v_rowid := '';
              v_codintview := '';
          end;
          chk_flowmail.replace_text_frmmail(v_templete_to, 'TREQEST1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

          -- replace sender
          begin
              select rowid into v_rowid
              from temploy1
              where codempid = global_v_codempid;
          exception when no_data_found then
              v_rowid := '';
          end;
          chk_flowmail.replace_text_frmmail(v_templete_to, 'TEMPLOY1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');


          begin
              select email into v_email
              from temploy1
              where codempid = v_codintview;
          exception when no_data_found then
              v_email := '';
          end;
          v_error := chk_flowmail.send_mail_to_emp (v_codintview, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, null,null,null, null);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    end send_mail_a;

  procedure send_email(json_str_input in clob, json_str_output out clob) AS
        json_obj        json_object_t;
        data_obj        json_object_t;
    begin
        initial_current_user_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            data_obj    := hcm_util.get_json_t(param_json, to_char(i));
            send_mail_a(data_obj);
        end loop;
        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end send_email;

END HRRC26E;

/

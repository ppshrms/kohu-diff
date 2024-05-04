--------------------------------------------------------
--  DDL for Package Body HRRC34E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC34E" AS

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
--  get index parameter
        p_codempts        := hcm_util.get_string_t(data_obj,'p_codempts');
        p_dteappoist      := to_date(hcm_util.get_string_t(data_obj,'p_dteappoist'),'dd/mm/yyyy');
        p_dteappoien      := to_date(hcm_util.get_string_t(data_obj,'p_dteappoien'),'dd/mm/yyyy');
--  get detail parameter
        p_numappl         := hcm_util.get_string_t(data_obj,'p_numappl');
        p_numreqrq        := hcm_util.get_string_t(data_obj,'p_numreqrq');
        p_codpos          := hcm_util.get_string_t(data_obj,'p_codpos');
        p_numapseq        := hcm_util.get_string_t(data_obj,'p_numapseq');
--  get detail assessment paramter
        p_codform        := hcm_util.get_string_t(data_obj,'p_codform');
        p_numgrup        := hcm_util.get_string_t(data_obj,'p_numgrup');
--  save index paramter
        p_numitem        := hcm_util.get_string_t(data_obj,'p_numitem');
        p_qtyfscor       := hcm_util.get_string_t(data_obj,'p_qtyfscor');
        p_grade          := hcm_util.get_string_t(data_obj,'p_grade');
        p_qtyscore       := nvl(hcm_util.get_string_t(data_obj,'p_qtyscore'),0);
        p_descnote       := hcm_util.get_string_t(data_obj,'p_descnote');
--  save index2 parameter
        p_stapphinv      := hcm_util.get_string_t(data_obj,'p_stapphinv');
        p_codasapl       := hcm_util.get_string_t(data_obj,'p_codasapl');
        p_stasign        := hcm_util.get_string_t(data_obj,'p_stasign');
        p_qtyscoreavg    := to_number(hcm_util.get_string_t(data_obj,'p_qtyscoreavg'));
        p_codasapll      := hcm_util.get_string_t(data_obj,'p_codasapll');

  end initial_params;

  procedure initial_params_save_index(data_obj json_object_t) as
    begin

--  save index paramter
        p_numitem        := hcm_util.get_string_t(data_obj,'numitem');
        p_qtyfscor       := hcm_util.get_string_t(data_obj,'qtyfscor');
        p_grade          := hcm_util.get_string_t(data_obj,'grade');
        p_qtyscore       := nvl(hcm_util.get_string_t(data_obj,'qtyscor'),0); -- softberry || 23/02/2023 || #9134 || p_qtyscore       := nvl(hcm_util.get_string_t(data_obj,'qtyscore'),0);

  end initial_params_save_index;

  function check_index return boolean as
    v_temp    varchar(1 char);
  begin
    begin
        select 'X' into v_temp
        from tappoinfint
        where codempts = p_codempts
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPOINFINT');
        return false;
    end;

--  check secur2
    if secur_main.secur2(p_codempts,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return false;
    end if;

    if p_dteappoist > p_dteappoien then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return false;
    end if;

    return true;

  end;

  function check_grade return boolean as
    v_temp      varchar(1 char);
  begin
    if p_grade is not null then
      begin
          select 'X' into v_temp
          from tintscor
          where codform = p_codform
            and grad = p_grade;
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TINTSCOR');
          return false;
      end;
    end if;
    return true;
  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_qtyscore      tappoinf.qtyscoreavg%type;
    v_codasapl      tappoinf.codasapl%type;
    v_count_pass    number := 0;
    v_count_fail    number := 0;
    v_resume_name   tappldoc.namdoc%type;
    v_resume_file   tappldoc.filedoc%type;
    cursor c1 is
        select a.dteappoi, a.numappl, decode(global_v_lang, '101', namempe,
                                                            '102', namempt,
                                                            '103', namemp3,
                                                            '104', namemp4,
                                                            '105', namemp5) namemp,
                a.codposrq, a.numreqrq, c.codposl, c.codcompl, b.stapphinv, b.qtyscore,
                b.codasapl, a.numapseq, a.qtyscoreavg, c.namimage
        from tappoinf a, tappoinfint b, tapplinf c
        where a.numappl = b.numappl
          and a.numreqrq = b.numreqrq
          and a.codposrq = b.codposrq
          and a.numapseq = b.numapseq
          and a.numappl = c.numappl
          and b.codempts = p_codempts
          and b.dteappoi between p_dteappoist and p_dteappoien
        order by a.dteappoi, a.numappl;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('dteappoi', to_char(i.dteappoi, 'dd/mm/yyyy'));
        obj_data.put('image', i.namimage);
        obj_data.put('numappl', i.numappl);
        obj_data.put('desc_namemp', i.namemp);
        obj_data.put('codposrq', i.codposrq);
        obj_data.put('desc_codposrq', get_tpostn_name(i.codposrq, global_v_lang));
        obj_data.put('numreqrq', i.numreqrq);
        obj_data.put('codposl', i.codposl);
        obj_data.put('desc_codposl', get_tpostn_name(i.codposl, global_v_lang));
        obj_data.put('codcompl', i.codcompl);
        obj_data.put('desc_codcompl', get_tcenter_name(i.codcompl, global_v_lang));
        obj_data.put('staapphinv', get_tlistval_name('STAPPHINV', i.stapphinv, global_v_lang));
        if i.stapphinv = 'C' then
            v_qtyscore := i.qtyscoreavg;
            v_codasapl := i.codasapl;
        else
            begin
                select avg(qtyscore) into v_qtyscore
                from tappoinfint
                where numappl = i.numappl
                and numreqrq = i.numreqrq
                and codposrq = i.codposrq
                and numapseq = i.numapseq
                and codasapl in ('P','F') -- softberry || 15/03/2023 || #9270
                and stapphinv = 'C';
            end;

            begin
                select count(*) into v_count_pass
                  from tappoinfint
                 where numappl = i.numappl
                and numreqrq = i.numreqrq
                and codposrq = i.codposrq
                and numapseq = i.numapseq
                and stapphinv = 'C'
                and codasapl = 'P';
            end;

            begin
                select count(*) into v_count_fail
                  from tappoinfint
                 where numappl = i.numappl
                and numreqrq = i.numreqrq
                and codposrq = i.codposrq
                and numapseq = i.numapseq
                and stapphinv = 'C'
                and codasapl = 'F';
            end;

        end if;
        if v_count_pass >= v_count_fail then
            v_codasapl := 'P';
        else
            v_codasapl := 'F';
        end if;
        if i.stapphinv = 'C' then
            obj_data.put('qtyscoreavg', v_qtyscore);
            obj_data.put('codasapl', get_tlistval_name('CODASAPL', v_codasapl, global_v_lang));
        else -- สถานะ = ‘อยู่ระหว่างการสัมภาษณ์’    คะแนนที่ได้และผลการประเมิน = Blank
            obj_data.put('qtyscoreavg', '');
            obj_data.put('codasapl', '');
        end if;
        obj_data.put('numapseq', i.numapseq);
        obj_data.put('desc_codempts', get_temploy_name(p_codempts, global_v_lang));

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
--        obj_data.put('path_filename',v_resume_file);
        obj_data.put('path_filename',get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||v_resume_file); -- adisak redmine#9314 04/04/2023 17:37
        obj_data.put('icon1','<i class="fas fa-pencil-alt"></i>');
        obj_data.put('icon2','<i class="fas fa-info-circle"></i>');
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    if obj_rows.get_size() = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPOINFINT');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    else
        json_str_output := obj_rows.to_clob;
    end if;

  end gen_index;

  function gen_detail_table1 return json_object_t as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_codform       tappoinf.codform%type;
    v_count         number;
    v_qtyscore      tapposec.qtyscore%type;

    cursor c1 is
        select codform
        from tappoinf
        where numappl = p_numappl
          and numreqrq = p_numreqrq
          and codposrq = p_codpos
          and numapseq = p_numapseq; -- user4 || 25/04/2023 || 4448#7996

    cursor c2 is
        select numgrup, decode(global_v_lang, '101', desgrupe,
                                     '102', desgrupt,
                                     '103', desgrup3,
                                     '104', desgrup4,
                                     '105', desgrup5) desgrup,
               qtyfscor
        from tintvews
        where codform = v_codform
        order by numgrup;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_codform := i.codform;
        for i2 in c2 loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('codform', i.codform);
            obj_data.put('desc_codform', get_tintview_name(i.codform, global_v_lang));
            obj_data.put('numgrup', i2.numgrup);
            obj_data.put('desc_numgrup', i2.desgrup);

            select count(*) into v_count
            from tintvewd
            where codform = i.codform
              and numgrup = i2.numgrup;

            obj_data.put('total', v_count);
            obj_data.put('qtyfscor', i2.qtyfscor);

            begin
                select qtyscore into v_qtyscore
                from  tapposec
                where numappl = p_numappl
                  and numreqrq = p_numreqrq
                  and codposrq = p_codpos
                  and numapseq = p_numapseq
                  and codempts = p_codempts
                  and numgrup = i2.numgrup;
            exception when no_data_found then
                v_qtyscore := '';
            end;

            obj_data.put('qtyscore', v_qtyscore);
            obj_rows.put(to_char(v_row-1),obj_data);

        end loop;

    end loop;

    return obj_rows;

  end;

  function gen_detail_table2(v_codcomp varchar2, v_codposrq varchar2, v_codform varchar2) return json_object_t as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_qtyscore      tintvewp.qtyscore%type;
    cursor c1 is
        select a.codempts, b.codpos, a.qtyscore, a.codasapl,
               a.descnote
        from tappoinfint a, temploy1 b
        where a.codempts = b.codempid
          and a.numappl = p_numappl
          and a.numreqrq = p_numreqrq
          and a.codposrq = p_codpos
          and a.numapseq = p_numapseq -- user4 || 25/04/2023 || 4448#7996
        order by codempts;

  begin
    obj_rows := json_object_t();
    begin
        select qtyscore into v_qtyscore
          from tintvewp 
         where v_codcomp = rpad(codcomp, length(v_codcomp), '0')      -- Adisak redmine#9306 05/04/2023 14:51
--        where codcomp = v_codcomp
           and codpos = v_codposrq
           and codform = v_codform;                                   -- Adisak redmine#9306 05/04/2023 14:51
    exception when no_data_found then
        v_qtyscore := 0;
    end;

    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('codempts', i.codempts);
        obj_data.put('desc_codempts', get_temploy_name(i.codempts, global_v_lang));
        obj_data.put('codpos', i.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
        obj_data.put('qtyscore', i.qtyscore);
        obj_data.put('pass_score', v_qtyscore);
        obj_data.put('codasapl', get_tlistval_name('CODASAPL', i.codasapl, global_v_lang));
        obj_data.put('descnote', i.descnote);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    return obj_rows;

  end;

  procedure gen_detail(json_str_output out clob) as
    obj_data                json_object_t;
    v_stapphinv             tappoinfint.stapphinv%type;
    v_codasapl              tappoinfint.codasapl%type;
    v_descnote              tappoinfint.descnote%type;
    v_stasign               tapphinv.stasign%type;
    v_codasapl2             tappoinf.codasapl%type;
    v_codform               tappoinf.codform%type;
    v_count_tappoinfint     number :=0;
    v_codcomp               tapphinv.codcomp%type;
    v_codposrq              tapphinv.codposrq%type;
  begin
    begin
        select codasapl, codform
        into v_codasapl2, v_codform
        from tappoinf
        where numappl = p_numappl
          and numreqrq = p_numreqrq
          and codposrq = p_codpos
          and numapseq = p_numapseq;
    exception when no_data_found then
        v_codasapl2 := '';
    end;

    begin
        select codasapl,stapphinv,descnote into v_codasapl,v_stapphinv,v_descnote
        from tappoinfint
        where numappl = p_numappl
          and numreqrq = p_numreqrq
          and codposrq = p_codpos
          and numapseq = p_numapseq
          and codempts = p_codempts;
    exception when no_data_found then
        v_codasapl := '';
        v_stapphinv := '';
    end;

    begin
        select stasign, codcomp, codposrq into v_stasign, v_codcomp, v_codposrq
        from tapphinv
        where numappl = p_numappl
          and numreqrq = p_numreqrq
          and codposrq = p_codpos;
    exception when no_data_found then
        v_stasign := '';
    end;

    obj_data := json_object_t();
    obj_data.put('codform', v_codform);
    obj_data.put('desc_codform', get_tintview_name(v_codform, global_v_lang));
    obj_data.put('stapphinv', v_stapphinv);
    obj_data.put('codasapl', v_codasapl);
--    obj_data.put('stasign', v_stasign);
    obj_data.put('codasapll', v_codasapl2);
    obj_data.put('descnote', v_descnote);
    obj_data.put('table', gen_detail_table1);
    obj_data.put('table2', gen_detail_table2(v_codcomp, v_codposrq, v_codform));
    begin
        select count(*) into v_count_tappoinfint
          from tappoinfint
         where stapphinv = 'P'
         and numappl = p_numappl
         and numreqrq = p_numreqrq
         and codposrq = p_codpos;
    end;
    if v_count_tappoinfint > 0 then
        obj_data.put('flgsave_final','N');
    else
        obj_data.put('flgsave_final','Y');
    end if;
    obj_data.put('coderror', 200);

    json_str_output := obj_data.to_clob;
  end gen_detail;

  procedure gen_detail_assessment(json_str_output out clob) as
    obj_result      json_object_t;
    obj_rows        json_object_t;
    obj_data        json_object_t;
    obj_vewd        json_object_t;
    v_row           number := 0;
    v_row_result    number := 0;
    v_grad          tintscor.grad%type;
    v_qtyscor       tintscor.qtyscor%type;

    cursor c_vews is
        select numgrup, decode(global_v_lang, '101', desgrupe,
                                     '102', desgrupt,
                                     '103', desgrup3,
                                     '104', desgrup4,
                                     '105', desgrup5) desgrup,
               qtyfscor
        from tintvews
        where codform = p_codform
        order by numgrup;

    cursor c_vewd is
      select numitem, decode(global_v_lang, '101', desiteme,
                                     '102', desitemt,
                                     '103', desitem3,
                                     '104', desitem4,
                                     '105', desitem5) desitem,
               qtywgt, qtyfscor, decode(global_v_lang, '101', definitt,
                                                       '102', definite,
                                                       '103', definit3,
                                                       '104', definit4,
                                                       '105', definit5) definit
        from tintvewd
        where codform = p_codform
         and numgrup = p_numgrup
        order by numitem;

  begin
    obj_result := json_object_t();
    for i in c_vews loop
        v_row_result := v_row_result + 1;
        obj_rows := json_object_t();
        p_numgrup := i.numgrup;
        obj_rows.put('numgrup', i.numgrup);
        obj_rows.put('desgrup', i.desgrup);
        obj_vewd := json_object_t();
        v_row := 0;
        for j in c_vewd loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('numitem', j.numitem);
            obj_data.put('desitem', j.desitem);
            obj_data.put('abstc', j.definit);
            obj_data.put('weight', j.qtywgt);
            obj_data.put('qtyfscor', j.qtyfscor);
            begin
                select grade, qtyscore into v_grad, v_qtyscor
                from TAPPODET
                where numreqrq = p_numreqrq
                  and numappl =  p_numappl
                  and codposrq = p_codpos
                  and numapseq = p_numapseq
                  and codempts = p_codempts
                  and numgrup = i.numgrup
                  and numitem = j.numitem;
            exception when no_data_found then
                v_grad    := '';
                v_qtyscor := '';
            end;
            obj_data.put('qtyscor', v_qtyscor);
            obj_data.put('grade', v_grad);
            obj_vewd.put(to_char(v_row-1),obj_data);
        end loop;
        obj_rows.put('children',obj_vewd);
        obj_result.put(to_char(v_row_result-1),obj_rows);
    end loop;

    json_str_output := obj_result.to_clob;
  end gen_detail_assessment;

  procedure insert_or_update_tappodet as
  begin
    begin
        insert into tappodet
            (
                numappl, numreqrq, codposrq, numapseq, codempts,
                numgrup, numitem, qtyfscor, grade, qtyscore,
                codcreate, coduser
            )
        values
            (
                p_numappl, p_numreqrq, p_codpos, p_numapseq, p_codempts,
                p_numgrup, p_numitem, p_qtyfscor, p_grade, p_qtyscore,
                global_v_coduser, global_v_coduser
            );
    exception when dup_val_on_index then
        update tappodet
        set qtyfscor = p_qtyfscor,
            grade = p_grade,
            qtyscore = p_qtyscore,
            coduser = global_v_coduser
        where numappl = p_numappl
          and numreqrq = p_numreqrq
          and codposrq = p_codpos
          and numapseq = p_numapseq
          and codempts = p_codempts
          and numgrup = p_numgrup
          and numitem = p_numitem;

    end;
 end insert_or_update_tappodet;

 procedure insert_or_update_tapposec(v_sum_sec_qtyfscor tapposec.qtyfscor%type,v_sum_sec_qtyscore tapposec.qtyscore%type) as
 begin
    begin
        insert into tapposec
            (
                numappl, numreqrq, codposrq, numapseq, codempts,
                numgrup, qtyfscor, qtyscore, codcreate, coduser
            )
        values
            (
                p_numappl, p_numreqrq, p_codpos, p_numapseq, p_codempts,
                p_numgrup, v_sum_sec_qtyfscor, v_sum_sec_qtyscore, global_v_coduser, global_v_coduser
            );
    exception when dup_val_on_index then
        update tapposec
        set qtyfscor = v_sum_sec_qtyfscor,
            qtyscore = v_sum_sec_qtyscore,
            coduser = global_v_coduser
        where numappl = p_numappl
          and numreqrq = p_numreqrq
          and codposrq = p_codpos
          and numapseq = p_numapseq
          and codempts = p_codempts
          and numgrup = p_numgrup;

    end;
 end insert_or_update_tapposec;

 procedure update_tappoinfint(v_sum_infint_qtyscore tappoinfint.qtyscore%type) as
    v_codcomp  tapphinv.codcomp%type;
    v_qtyscore tintvewp.qtyscore%type;
    v_codform  tintvewp.codform%type;
 begin
    -- Adisak redmine#9306 05/04/2023 14:51
    begin
      select codcomp into v_codcomp
      from tapphinv
      where numappl = p_numappl
        and numreqrq = p_numreqrq
        and codposrq = p_codpos;
    exception when no_data_found then
      v_codcomp := '';
    end;
    begin
      select codform
      into v_codform
      from tappoinf
      where numappl = p_numappl
        and numreqrq = p_numreqrq
        and codposrq = p_codpos
        and numapseq = p_numapseq;
    exception when no_data_found then
      v_codform := '';
    end;
    select qtyscore into v_qtyscore
      from tintvewp 
     where v_codcomp = rpad(codcomp, length(v_codcomp), '0')
       and codpos = p_codpos
       and codform = v_codform;                                   

    p_codasapl := 'F';
    if v_qtyscore <= v_sum_infint_qtyscore then
      p_codasapl := 'P';
    end if;
    -- Adisak redmine#9306 05/04/2023 14:51
    update tappoinfint
    set qtyscore = v_sum_infint_qtyscore,
        descnote = p_descnote,
        codasapl = p_codasapl,
        coduser = global_v_coduser
    where numappl = p_numappl
      and numreqrq = p_numreqrq
      and codposrq = p_codpos
      and codempts = p_codempts;

 end update_tappoinfint;

 procedure update_tappoinfint2 as
 begin
    update tappoinfint
    set stapphinv = p_stapphinv,
        codasapl = p_codasapl,
        coduser = global_v_coduser
    where numappl = p_numappl
      and numreqrq = p_numreqrq
      and codposrq = p_codpos
      and codempts = p_codempts;

 end update_tappoinfint2;

 procedure update_tappoinf as
 begin
    update tappoinf
    set codasapl = p_codasapll,
        stapphinv = 'C',
        qtyscoreavg = p_qtyscoreavg,
        coduser = global_v_coduser
    where numappl = p_numappl
      and numreqrq = p_numreqrq
      and codposrq = p_codpos
      and numapseq = p_numapseq;

 end update_tappoinf;

 procedure update_tapphinv as

 begin

    if  p_codasapll = 'P' then
        p_stasign := 'Y';
    elsif  p_codasapll = 'N' then
        p_stasign := 'N';
    end if;

    begin
        update tapphinv
        set codappr = p_codempts,
            dteappr = sysdate,
            stasign = p_stasign,
            coduser = global_v_coduser
        where numappl = p_numappl
          and numreqrq = p_numreqrq
          and codposrq = p_codpos;
    end;

 end update_tapphinv;

 procedure update_treqest2 as
 begin
    update treqest2
    set dteintview = sysdate,
        coduser = global_v_coduser
    where numreqst = p_numreqrq
      and codpos = p_codpos;

 end update_treqest2;

 procedure update_tappinf as
 begin
    update tapplinf
    set statappl = '50',
        dtefoll = sysdate,
        coduser = global_v_coduser
    where numappl = p_numappl;

 end update_tappinf;

 procedure get_index(json_str_input in clob, json_str_output out clob) AS
 BEGIN
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
 BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_detail(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_detail;

 procedure get_detail_assessment(json_str_input in clob, json_str_output out clob) AS
 BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_detail_assessment(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_detail_assessment;

  procedure save_index(json_str_input in clob, json_str_output out clob) AS
    json_obj       json_object_t;
    data_obj       json_object_t;
    sec_obj        json_object_t;
    item_obj       json_object_t;

    v_sum_sec_qtyfscor      tapposec.qtyfscor%type;
    v_sum_sec_qtyscore      tapposec.qtyscore%type;

    v_sum_infint_qtyscore   tappoinfint.qtyscore%type := 0;
  begin
    initial_current_user_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    initial_params(json_obj);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    for i in 0..param_json.get_size-1 loop
        sec_obj     := hcm_util.get_json_t(param_json, to_char(i));
        p_numgrup   := hcm_util.get_string_t(sec_obj,'numgrup');
        p_codform   := hcm_util.get_string_t(sec_obj,'codform');
        -- ssx
        data_obj  := hcm_util.get_json_t(sec_obj, 'children');
        v_sum_sec_qtyfscor := 0;
        v_sum_sec_qtyscore := 0;
        for j in 0..data_obj.get_size-1 loop
            item_obj := hcm_util.get_json_t(data_obj, to_char(j));
            initial_params_save_index(item_obj);
            if check_grade then
                insert_or_update_tappodet;
                v_sum_sec_qtyfscor := v_sum_sec_qtyfscor + p_qtyfscor;
                v_sum_sec_qtyscore := v_sum_sec_qtyscore + p_qtyscore;
            else
                exit;
            end if;
        end loop;

        insert_or_update_tapposec(v_sum_sec_qtyfscor,v_sum_sec_qtyscore);
        v_sum_infint_qtyscore  := v_sum_infint_qtyscore + v_sum_sec_qtyscore;
    end loop;
    update_tappoinfint(v_sum_infint_qtyscore);
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

  procedure save_index2(json_str_input in clob, json_str_output out clob) AS
    json_obj            json_object_t;
    data_obj            json_object_t;
    v_count_tappoinfint number;
  begin
    initial_current_user_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    initial_params(json_obj);
    update_tappoinfint2;

    begin
        select count(*) into v_count_tappoinfint
          from tappoinfint
         where stapphinv = 'P'
         and numappl = p_numappl
         and numreqrq = p_numreqrq
         and codposrq = p_codpos;
    end;
--    if v_count_tappoinfint = 0 then
        update_tappoinf;
        update_tapphinv;
--    end if;

--    for i in 0..param_json.count-1 loop
--        data_obj  := hcm_util.get_json_t(param_json, to_char(i));
--        initial_params(data_obj);
--        update_tappoinfint2;
--        if p_stapphinv = 'C' then
--            update_tappoinf;
--            update_tapphinv;
--        end if;
--    end loop;

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

  END save_index2;

  procedure get_drilldown(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_rows    json_object_t := json_object_t();
    v_row       number :=0;
    v_sum_act   number :=0;
    v_sum_req   number :=0;
    v_status    varchar2(1 char) := 'P';
    cursor c1 is
        select numapseq,dteappoi,typappty,descnote,stapphinv,qtyfscore,qtyscoreavg,codasapl
          from tappoinf
         where numappl = p_numappl
           and numreqrq = p_numreqrq
           and codposrq = p_codpos
      order by numapseq;
  begin
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('numapseq',i.numapseq);
        obj_data.put('dteappoi',to_char(i.dteappoi,'dd/mm/yyyy'));
        obj_data.put('typappty',get_tlistval_name('TYPAPPOINT',i.numapseq,global_v_lang));
        obj_data.put('descnote',i.descnote);
        obj_data.put('stapphinv',get_tlistval_name('STAPPHINV',i.stapphinv,global_v_lang));
        obj_data.put('qtyfscore',i.qtyfscore);
        obj_data.put('qtyscore',i.qtyscoreavg);
        v_sum_act :=v_sum_act + i.qtyscoreavg;
        v_sum_req :=v_sum_req + i.qtyfscore;
        if i.codasapl = 'F' then
            v_status := 'F';
        end if;
        obj_data.put('codasapl',get_tlistval_name('TCODASAPL',i.codasapl,global_v_lang));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
--    if v_row > 0 then
--        v_row := v_row+1;
--        obj_data := json();
--        obj_data.put('numapseq','');
--        obj_data.put('dteappoi','');
--        obj_data.put('typappty','');
--        obj_data.put('descnote','');
--        obj_data.put('stapphinv',get_label_name('HRRC34EC2',global_v_lang,80));
--        obj_data.put('qtyfscore',v_sum_req);
--        obj_data.put('qtyscore',v_sum_act);
--        obj_data.put('codasapl',get_tlistval_name('TCODASAPL',v_status,global_v_lang));
--        obj_rows.put(to_char(v_row-1),obj_data);
--    end if;

    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_drilldown;

  procedure get_drilldown_interview(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_rows    json_object_t := json_object_t();
    v_row       number :=0;
    v_stapphinv tappoinf.stapphinv%type;
    v_codasapl  tappoinf.codasapl%type;
    v_sum_score number :=0;
    v_count_pass    number :=0;
    v_count_fail    number :=0;
    cursor c1 is
        select a.codempts,b.codpos,a.qtyscore,a.codasapl,a.descnote
        from tappoinfint a, temploy1 b
        where a.codempts = b.codempid
        and a.numappl = p_numappl
        and a.numreqrq = p_numreqrq
        and a.codposrq = p_codpos
        and a.numapseq = p_numapseq;
  begin
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    begin
        select stapphinv into v_stapphinv
          from tappoinf
         where numappl = p_numappl
           and numreqrq = p_numreqrq
           and codposrq = p_codpos
           and numapseq = p_numapseq;
    exception when no_data_found then
        v_stapphinv := null;
    end;
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('desc_codempts',get_temploy_name(i.codempts,global_v_lang));
        obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
        obj_data.put('qtyscore',i.qtyscore);
        obj_data.put('desc_codasapl',get_tlistval_name('CODASAPL',i.codasapl, global_v_lang));
        obj_data.put('descnote',i.descnote);
        obj_rows.put(to_char(v_row-1),obj_data);
        v_sum_score := v_sum_score + i.qtyscore;
        if  i.codasapl = 'P' then
            v_count_pass := v_count_pass+1;
        else
            v_count_fail := v_count_fail+1;
        end if;
    end loop;
    if v_row > 0 then
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('desc_codempts',get_label_name('HRRC34EC2',global_v_lang,110));
        obj_data.put('desc_codpos','');
        obj_data.put('qtyscore',v_sum_score/v_row);
        if v_stapphinv = 'C' then
            obj_data.put('desc_codasapl',get_tlistval_name('TCODASAPL',v_codasapl,global_v_lang));
        else
            if v_count_pass >= v_count_fail then
                obj_data.put('desc_codasapl',get_tlistval_name('TCODASAPL','P',global_v_lang));
            else
                obj_data.put('desc_codasapl',get_tlistval_name('TCODASAPL','F',global_v_lang));
            end if;
        end if;
        obj_data.put('descnote','');
        obj_rows.put(to_char(v_row-1),obj_data);
    end if;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_drilldown_interview;

END HRRC34E;

/

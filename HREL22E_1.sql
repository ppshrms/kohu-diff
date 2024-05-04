--------------------------------------------------------
--  DDL for Package Body HREL22E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL22E" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_coduser     := global_v_coduser;
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_codcours    := hcm_util.get_string_t(json_obj,'p_codcours');
    b_index_codsubj     := hcm_util.get_string_t(json_obj,'p_codsubj');
    b_index_dteyear     := hcm_util.get_string_t(json_obj,'p_dteyear');
    b_index_numclseq    := hcm_util.get_string_t(json_obj,'p_numclseq');
    b_index_dtecourst   := to_date(hcm_util.get_string_t(json_obj,'p_dtecourst'),'dd/mm/yyyy hh24:mi');
    b_index_dtesubjst   := to_date(hcm_util.get_string_t(json_obj,'p_dtesubjst'),'dd/mm/yyyy hh24:mi');
  end;
  --
  procedure gen_subject_detail(json_str_output out clob) is
    obj_data          json_object_t;
    obj_subject       json_object_t;
    obj_chapter_row   json_object_t;
    obj_chapter_data  json_object_t;

    v_dessubj         tvsubject.dessubj%type;
    v_flglearn        tvsubject.flglearn%type;
    v_codcatexm       tvsubject.codcatexm%type;
    v_flgexam         tvsubject.flgexam%type;
    v_staexam         tvsubject.staexam%type;
    v_dtesubjst       tlrnsubj.dtesubjst%type;
    v_dtegradtn       tlrnsubj.dtegradtn%type;
    v_staresult       tlrnsubj.staexam%type;
    v_score           tlrnsubj.score%type;
    v_codexam         tlrnsubj.codexam%type;
    v_stalearn        tlrnsubj.stalearn%type;
    v_prev_stalearn   tlrnchap.stalearn%type;

    v_codcomp         temploy1.codcomp%type;
    v_codpos          temploy1.codpos%type;

    v_rcnt            number := 0;
    v_can_learn       varchar2(1);
    v_chk_chapt_lrn   varchar2(1) := 'Y';
    v_dtetest         date;
    cursor c_tlrnchap is
      select tv.chaptno,
             decode(global_v_lang,'101',tv.namchapte
                                 ,'102',tv.namchaptt
                                 ,'103',tv.namchapt3
                                 ,'104',tv.namchapt4
                                 ,'105',tv.namchapt5
                                 ,tv.namchapte) as namchapt,
             lrn.dtechapst,lrn.dtechapen,lrn.qtytrainm,lrn.staexam,lrn.stalearn
        from tvchapter tv, tlrnchap lrn
       where tv.codcours        = b_index_codcours
         and tv.codsubj         = b_index_codsubj
         and lrn.codempid(+)    = b_index_codempid
         and lrn.codcours(+)    = tv.codcours
         and lrn.codsubj(+)     = tv.codsubj
         and lrn.chaptno(+)     = tv.chaptno
         and lrn.dtecourst(+)   = b_index_dtecourst
      order by tv.chaptno;
  begin
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid   = b_index_codempid;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      return;
    end;
    --
    begin
      select nvl(flgexam,'3'),dessubj,flglearn,staexam
        into v_flgexam,v_dessubj,v_flglearn,v_staexam
        from tvsubject
       where codcours     = b_index_codcours
         and codsubj      = b_index_codsubj
         and rownum = 1;
    end;
    --
    begin
      select staexam,score,codexam,dtesubjst,dtegradtn,stalearn
        into v_staresult,v_score,v_codexam,v_dtesubjst,v_dtegradtn,v_stalearn
        from tlrnsubj
       where codempid     = b_index_codempid
         and codcours     = b_index_codcours
         and dtecourst    = b_index_dtecourst
         and codsubj      = b_index_codsubj
         and rownum = 1;
    exception when no_data_found then
      begin
        select codexam,codcatexm
          into v_codexam,v_codcatexm
          from tvsubject
         where codcours   = b_index_codcours
           and codsubj    = b_index_codsubj;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvsubject');
        return;
      end;
      if v_codcatexm is not null then
        begin
          select codexam into v_codexam
            from (select codexam
                  from tvtest
                  where codcatexm   = v_codcatexm
                  order by dbms_random.random
                  )
           where rownum = 1;
        exception when no_data_found then
          param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvtest');
          return;
        end;
      end if;
    end;
    --
    if v_flgexam = '1' then
      if v_staresult <> 'Y' then
        begin
          select max(dtetest)
            into v_dtetest
            from ttestemp
           where codempid     = b_index_codempid
             and codexam      = v_codexam
             and typetest     = '2'
             and typtest      = case when b_index_dteyear is not null and b_index_numclseq is not null then '5' else '4' end;
        end;
      end if;
    end if;
    --
    obj_data      := json_object_t();
    obj_data.put('coderror','200');
    obj_subject   := json_object_t();
    obj_subject.put('codempid',b_index_codempid);
    obj_subject.put('desc_codempid',get_temploy_name(b_index_codempid,global_v_lang));
    obj_subject.put('codcomp',v_codcomp);
    obj_subject.put('codpos',v_codpos);
    obj_subject.put('codcours',b_index_codcours);
    obj_subject.put('desc_codcours',get_tcourse_name(b_index_codcours,global_v_lang));
--    obj_subject.put('codexampr',v_codexampr);
    obj_subject.put('codsubj',b_index_codsubj);
    obj_subject.put('desc_codsubj',get_tsubject_name(b_index_codsubj,global_v_lang));
    obj_subject.put('dtesubjst',to_char(v_dtesubjst,'dd/mm/yyyy hh24:mi'));
    obj_subject.put('dtegradtn',to_char(v_dtegradtn,'dd/mm/yyyy hh24:mi'));
    obj_subject.put('flglearn',v_flglearn);
    obj_subject.put('desc_flglearn',get_tlistval_name('FLGLEARN',v_flglearn,global_v_lang));
    obj_subject.put('codexam',v_codexam);
    obj_subject.put('desc_codexam',get_tvtest_name(v_codexam,global_v_lang));
    obj_subject.put('score',to_char(v_score,'fm999,990.00'));
    obj_subject.put('staposttest',v_staresult);
    obj_subject.put('desc_staexam',get_tlistval_name('STAEXAM',v_staresult,global_v_lang));
    obj_subject.put('dtetrain',to_char(b_index_dtecourst,'dd/mm/yyyy hh24:mi'));
    obj_subject.put('stalearn',v_stalearn);
    obj_subject.put('flgexam',v_flgexam);
    obj_subject.put('dtetest',to_char(nvl(v_dtetest,sysdate),'dd/mm/yyyy'));
    obj_chapter_row   := json_object_t();
    --
    for i in c_tlrnchap loop
      obj_chapter_data    := json_object_t();
      obj_chapter_data.put('chaptno',i.chaptno);
      obj_chapter_data.put('namchapt',get_label_name('HREL22E',global_v_lang,220)||' '||i.chaptno||' - '||i.namchapt);
      obj_chapter_data.put('dtechapst',to_char(i.dtechapst,'dd/mm/yyyy hh24:mi'));
      obj_chapter_data.put('dtechapen',to_char(i.dtechapen,'dd/mm/yyyy hh24:mi'));
      obj_chapter_data.put('qtytrainm',hcm_util.convert_minute_to_hour(i.qtytrainm));
      obj_chapter_data.put('staexam',i.staexam);
      obj_chapter_data.put('desc_staexam',get_tlistval_name('STATEST',i.staexam,global_v_lang));
      obj_chapter_data.put('stalearn',nvl(i.stalearn,'P'));
      obj_chapter_data.put('desc_stalearn',get_tlistval_name('STALEARN',nvl(i.stalearn,'P'),global_v_lang));
      if nvl(i.stalearn,'P') <> 'C' then
        v_chk_chapt_lrn   := 'N';
      end if;
      v_can_learn := 'N';
      if v_flglearn = '1' then
        if v_rcnt = 0 then
          v_can_learn       := 'Y';
          v_prev_stalearn   := i.stalearn;
        else
          if i.stalearn = 'C' or v_prev_stalearn = 'C' then
            v_can_learn     := 'Y';
          end if;
          v_prev_stalearn   := i.stalearn;
        end if;
      else
        v_can_learn   := 'Y';
      end if;
      if v_can_learn = 'Y' then
        obj_chapter_data.put('video','<i class="fa fa-video-camera"></i>');
      end if;
      obj_chapter_row.put(to_char(v_rcnt),obj_chapter_data);
      v_rcnt := v_rcnt + 1;
    end loop;
    --
    if v_stalearn <> 'C' then
      obj_subject.put('staexam','N');
      if v_flgexam = '1' then
        if v_staexam = 'Y' then
          if v_staresult = 'Y' then
            obj_subject.put('staexam','Y');
          end if;
        else
          if v_staresult is not null then
            obj_subject.put('staexam','Y');
          end if;
        end if;
      elsif v_flgexam in ('2','3') then
        if v_chk_chapt_lrn = 'Y' then
          obj_subject.put('staexam','Y');
        end if;
      else
        obj_subject.put('staexam',v_staresult);
      end if;
    end if;
    obj_data.put('subject',obj_subject);
    obj_data.put('chapter',obj_chapter_row);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_subject_detail(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_subject_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure insert_learn_start(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    v_codsubj       tlrnsubj.codsubj%type;
    v_codexam       tlrnsubj.codexam%type;
    v_chaptno       tlrnchap.chaptno%type;
  begin
    json_input      := json_object_t(json_str_input);
    v_codsubj       := hcm_util.get_string_t(json_input,'codsubj');
    v_codexam       := hcm_util.get_string_t(json_input,'codexam');
    v_chaptno       := hcm_util.get_string_t(json_input,'chaptno');
    begin
      insert into tlrnsubj(codempid,codcours,dtecourst,codsubj,codexam,stalearn,codcreate,coduser)
      values (b_index_codempid,b_index_codcours,b_index_dtecourst,v_codsubj,v_codexam,'P',global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then null;
    end;
    --
    begin
      insert into tlrnchap(codempid,codcours,dtecourst,codsubj,chaptno,stalearn,codcreate,coduser)
      values (b_index_codempid,b_index_codcours,b_index_dtecourst,v_codsubj,v_chaptno,'P',global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then null;
    end;
    --
    begin
      update tlrncourse
         set codsubj    = v_codsubj,
             chaptno    = v_chaptno,
             coduser    = global_v_coduser
       where codempid   = b_index_codempid
         and codcours   = b_index_codcours
         and dtecourst  = b_index_dtecourst
         and stalearn   in ('P','A');
    end;

    commit;
    param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
  end;
  --
  procedure save_done_subject(json_str_input in clob) is
--    json_input      json_object_t;
    v_staexam     tvsubject.staexam%type;
    v_flgexam     tvsubject.flgexam%type;
    v_qtychapt    number;
    v_qty_learn_c number;
    v_qty_all_sub number;
  begin
--    json_intput     := json_object_t(json_str_input);
    begin
      select staexam,flgexam
        into v_staexam,v_flgexam
        from tvsubject
       where codcours   = b_index_codcours
         and codsubj    = b_index_codsubj;
    exception when no_data_found then
      v_staexam   := 'N';
    end;
    --
    if nvl(v_staexam,'N') = 'Y' and v_flgexam = '1' then
      begin
        select staexam
          into v_staexam
          from tlrnsubj
         where codcours   = b_index_codcours
           and codsubj    = b_index_codsubj
           and codempid   = b_index_codempid   --#4670 || 24/05/2022
           and dtecourst  = b_index_dtecourst; --#4670 || 24/05/2022   
      exception when no_data_found then
        v_staexam   := 'N';
      end;
      if v_staexam = 'Y' then
        update tlrnsubj
           set stalearn   = 'C',
               coduser    = global_v_coduser
         where codempid   = b_index_codempid
           and codcours   = b_index_codcours
           and dtecourst  = b_index_dtecourst
           and codsubj    = b_index_codsubj;
      end if;
    else
      begin
        select count(*)
          into v_qtychapt
          from tlrnchap
         where codempid     = b_index_codempid
           and codcours     = b_index_codcours
           and codsubj      = b_index_codsubj
           and stalearn     = 'C';
      end;
      --
      update tlrnsubj
         set stalearn   = 'C',
             dtegradtn  = trunc(sysdate),
             qtychapt   = v_qtychapt,
             coduser    = global_v_coduser
       where codempid   = b_index_codempid
         and codcours   = b_index_codcours
         and dtecourst  = b_index_dtecourst
         and codsubj    = b_index_codsubj;
    end if;
    --
    begin
      select count(1)
        into v_qty_learn_c
        from tlrnsubj
       where codempid   = b_index_codempid
         and codcours   = b_index_codcours
         and dtecourst  = b_index_dtecourst
         and stalearn   = 'C';
    end;
    --
    begin
      select count(1)
        into v_qty_all_sub
        from tvsubject
       where codcours   = b_index_codcours;
    end;
    --
    begin
      update tlrncourse
         set codsubj    = b_index_codsubj,
             stalearn   = decode(v_qty_learn_c,v_qty_all_sub,'Y','A'),
             coduser    = global_v_coduser
       where codempid   = b_index_codempid
         and codcours   = b_index_codcours
         and dtecourst  = b_index_dtecourst;
    end;
    commit;
    param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
  end;
  --
  procedure done_subject(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_done_subject(json_str_input);
    if param_msg_error is null then
      save_done_subject(json_str_input);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure leave_subject(json_str_input in clob,json_str_output out clob) is
    json_input    json_object_t;
    v_codexam     tlrnsubj.codexam%type;
--    v_stalearn    tlrnsubj.stalearn%type;
--    v_chaptno     tlrnchap.chaptno%type;
    v_qtychapt    number;
  begin
    initial_value(json_str_input);
    json_input      := json_object_t(json_str_input);
    v_codexam       := hcm_util.get_string_t(json_input,'p_codexam');
--    begin
--      select count(*)
--        into v_qtychapt
--        from tlrnchap
--       where codempid     = b_index_codempid
--         and codcours     = b_index_codcours
--         and dtecourst    = b_index_dtecourst
--         and codsubj      = b_index_codsubj
--         and stalearn     = 'C';
--    end;
--    --
--    begin
--      insert into tlrnsubj(codempid,codcours,dtecourst,codsubj,
--                           codexam,stalearn,codcreate,coduser)
--      values (b_index_codempid,b_index_codcours,b_index_dtecourst,b_index_codsubj,
--              v_codexam,'P',global_v_coduser,global_v_coduser);
--    exception when dup_val_on_index then null; end;
--    --
--    begin
--      update tlrncourse
--         set codsubj      = b_index_codsubj,
--             coduser      = global_v_coduser
--       where codempid     = b_index_codempid
--         and codcours     = b_index_codcours
--         and dtecourst    = b_index_dtecourst
--         and stalearn     in ('P','A');
--    end;
--
--    commit;
    param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

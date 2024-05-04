--------------------------------------------------------
--  DDL for Package Body HREL23E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL23E" as
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
    b_index_chaptno     := hcm_util.get_string_t(json_obj,'p_chaptno');
    b_index_dtecourst   := to_date(nvl(hcm_util.get_string_t(json_obj,'p_dtecourst'),to_char(sysdate,'dd/mm/yyyy hh24:mi')),'dd/mm/yyyy hh24:mi');
    b_index_dtesubjst   := to_date(nvl(hcm_util.get_string_t(json_obj,'p_dtesubjst'),to_char(sysdate,'dd/mm/yyyy hh24:mi')),'dd/mm/yyyy hh24:mi');
    b_index_dteyear     := hcm_util.get_string_t(json_obj,'p_dteyear');
    b_index_numclseq    := hcm_util.get_string_t(json_obj,'p_numclseq');
--    b_index_dtechapst   := to_date(nvl(hcm_util.get_string_t(json_obj,'p_dtechapst'),to_char(sysdate,'dd/mm/yyyy hh24:mi')),'dd/mm/yyyy hh24:mi');
  end;
  --
  procedure gen_chapter_detail(json_str_output out clob) is
    obj_data        json_object_t;
    v_codexam       tlrnchap.codexam%type;
    v_score         tlrnchap.score%type;
    v_stalearn      tlrnchap.stalearn%type;
    v_qtytrainm     tlrnchap.qtytrainm%type;
    v_staresult     tlrnchap.staexam%type;
    v_dtechapst     tlrnchap.dtechapst%type;
    v_namchapt      tvchapter.namchapte%type;
    v_filemedia     tvchapter.filemedia%type;
    v_namemedia     tvchapter.namemedia%type;
    v_namelink      tvchapter.namelink%type;
    v_min_chaptno   tvchapter.chaptno%type;
    v_max_chaptno   tvchapter.chaptno%type;
    v_codcatexm     tvchapter.codcatexm%type;
    v_flgexam       tvchapter.flgexam%type;
    v_staexam       tvchapter.staexam%type;
    v_typfile       tvchapter.typfile%type;
    v_desclink      tvchapter.desclink%type;
    v_filedoc       tvchapter.filedoc%type;
    v_namefiled     tvchapter.namefiled%type;
    v_qtytrmin      tvchapter.qtytrmin%type;
    v_flglearn      tvsubject.flglearn%type;
    v_exm_subj      tvsubject.codexam%type;
    v_catexm_subj   tvsubject.codcatexm%type;

    v_catpre_cs     tvcourse.codcatpre%type;
    v_exampr_cs     tvcourse.codexampr%type;
    v_catpo_cs      tvcourse.codcatpo%type;
    v_exampo_cs     tvcourse.codexampo%type;

    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;

    v_qtychapt          number;
    v_path_filemedia    varchar2(200);
    v_path_filedoc      varchar2(200);
    v_curr_date_time    date := to_date(to_char(sysdate,'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi');
    v_dtetest           date;
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
      select decode(global_v_lang,'101',t3.namchapte
                                 ,'102',t3.namchaptt
                                 ,'103',t3.namchapt3
                                 ,'104',t3.namchapt4
                                 ,'105',t3.namchapt5) namchap,
             t3.filemedia,t3.namemedia,t3.namelink,t3.codexam,t3.codcatexm,
             t3.flgexam,t3.typfile,t3.desclink,t3.filedoc,t3.namefiled,t3.qtytrmin,
             t3.staexam,t2.codexam,t2.codcatexm,
             t1.codcatpre,t1.codexampr,t1.codcatpo,t1.codexampo
        into v_namchapt,v_filemedia,v_namemedia,v_namelink,v_codexam,v_codcatexm,
             v_flgexam,v_typfile,v_desclink,v_filedoc,v_namefiled,v_qtytrmin,
             v_staexam,v_exm_subj,v_catexm_subj,
             v_catpre_cs,v_exampr_cs,v_catpo_cs,v_exampo_cs
        from tvcourse t1,tvsubject t2,tvchapter t3
       where t2.codcours    = b_index_codcours
         and t2.codsubj     = b_index_codsubj
         and t3.chaptno     = b_index_chaptno
         and t1.codcours    = t2.codcours
         and t2.codcours    = t3.codcours
         and t2.codsubj     = t3.codsubj;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvchapter');
      return;
    end;
    --
    if v_catexm_subj is not null then
      get_random_exam_by_category(v_catexm_subj,global_v_lang,v_exm_subj,param_msg_error);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    --
    if v_catpre_cs is not null then
      get_random_exam_by_category(v_catpre_cs,global_v_lang,v_exampr_cs,param_msg_error);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    --
    if v_catpo_cs is not null then
      get_random_exam_by_category(v_catpo_cs,global_v_lang,v_exampo_cs,param_msg_error);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    --
    begin
      select score,staexam,codexam,stalearn,qtytrainm,dtechapst
        into v_score,v_staresult,v_codexam,v_stalearn,v_qtytrainm,v_dtechapst
        from tlrnchap
       where codempid   = b_index_codempid
         and codcours   = b_index_codcours
         and dtecourst  = b_index_dtecourst
         and codsubj    = b_index_codsubj
         and chaptno    = b_index_chaptno;
    exception when no_data_found then
      if v_codcatexm is not null then
        if v_catexm_subj is not null then
          get_random_exam_by_category(v_codcatexm,global_v_lang,v_codexam,param_msg_error);
          if param_msg_error is not null then
            return;
          end if;
        end if;
        if param_msg_error is not null then
          param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvtest');
          return;
        end if;
      end if;
      insert into tlrnchap(codempid,codcours,dtecourst,codsubj,
                           chaptno,dtechapst,dtesubjst,codexam,
                           stalearn,codcreate,coduser)
      values (b_index_codempid,b_index_codcours,b_index_dtecourst,b_index_codsubj,
              b_index_chaptno,v_curr_date_time,b_index_dtesubjst,v_codexam,
              'A',global_v_coduser,global_v_coduser);
    end;
    --
    begin
      insert into tlrnsubj(codempid,codcours,dtecourst,codsubj,
                           stalearn,dtesubjst,codcreate,coduser,
                           codexam)
      values (b_index_codempid,b_index_codcours,b_index_dtecourst,b_index_codsubj,
              'A',v_curr_date_time,global_v_coduser,global_v_coduser,
              v_exm_subj);
    exception when dup_val_on_index then
      update tlrnsubj
         set stalearn   = 'A',
             dtesubjst  = v_curr_date_time,
             coduser    = global_v_coduser
       where codempid   = b_index_codempid
         and codcours   = b_index_codcours
         and dtecourst  = b_index_dtecourst
         and codsubj    = b_index_codsubj
         and dtesubjst  is null;
    end;
    --
    begin
      insert into tlrncourse(codempid,codcours,dtecourst,stalearn,
                             dteyear,numclseq,codsubj,chaptno,
                             codcreate,coduser,
                             codexampr,codexampo)
      values (b_index_codempid,b_index_codcours,b_index_dtecourst,'A',
              b_index_dteyear,b_index_numclseq,b_index_codsubj,b_index_chaptno,
              global_v_coduser,global_v_coduser,
              v_exampr_cs,v_exampo_cs);
    exception when dup_val_on_index then
      if v_stalearn <> 'C' then
        update tlrncourse
           set codsubj    = b_index_codsubj,
               chaptno    = b_index_chaptno,
               codexampr  = v_exampr_cs,
               codexampo  = v_exampo_cs,
               coduser    = global_v_coduser
         where codempid   = b_index_codempid
           and codcours   = b_index_codcours
           and dtecourst  = b_index_dtecourst;
      end if;
    end;
    --
    begin
      select min(chaptno),max(chaptno),count(1)
        into v_min_chaptno,v_max_chaptno,v_qtychapt
        from tvchapter
       where codcours     = b_index_codcours
         and codsubj      = b_index_codsubj;
    end;
    --
    begin
      select flglearn --sort by chapter no
        into v_flglearn
        from tvsubject
       where codcours     = b_index_codcours
         and codsubj      = b_index_codsubj;
    exception when no_data_found then
      null;
    end;
    --
    if v_flgexam = '1' then
      if nvl(v_staresult,'N') <> 'Y' then
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
    v_path_filemedia  := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HREL01E2')||'/'||v_filemedia;
    v_path_filedoc    := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HREL01E3')||'/'||v_filedoc;
    obj_data  := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('codempid',b_index_codempid);
    obj_data.put('desc_codempid',get_temploy_name(b_index_codempid,global_v_lang));
    obj_data.put('codcomp',v_codcomp);
    obj_data.put('codpos',v_codpos);
    obj_data.put('codcours',b_index_codcours);
    obj_data.put('desc_codcours',get_tcourse_name(b_index_codcours,global_v_lang));
    obj_data.put('codsubj',b_index_codsubj);
    obj_data.put('desc_codsubj',get_tsubject_name(b_index_codsubj,global_v_lang));
    obj_data.put('chaptno',b_index_chaptno);
    obj_data.put('namchapt',v_namchapt);
    obj_data.put('flglearn',v_flglearn);
    obj_data.put('desc_flglearn',get_tlistval_name('FLGLEARN',v_flglearn,global_v_lang));
    obj_data.put('flgexam',v_flgexam);
    obj_data.put('qtychapt',v_qtychapt);
    obj_data.put('chaptnoFirst',v_min_chaptno);
    obj_data.put('chaptnoLast',v_max_chaptno);
    obj_data.put('score',to_char(v_score,'fm999,990.00'));
    obj_data.put('staposttest',v_staresult);
--    if v_flgexam = '2' and v_stalearn in ('C','Y') then
--      obj_data.put('staexam','Y');
--    end if;
    obj_data.put('desc_staexam',get_tlistval_name('STATEST',v_staresult,global_v_lang));
    obj_data.put('codexam',v_codexam);
    obj_data.put('desc_codexam',get_tvtest_name(v_codexam,global_v_lang));
    obj_data.put('typfile',v_typfile); -- obj_data.put('typfile',nvl(v_typfile,'L')); -- user4 || 09/08/2022
    obj_data.put('path_filemedia',v_path_filemedia);
    obj_data.put('filemedia',v_filemedia);
    obj_data.put('namemedia',v_namemedia);
    obj_data.put('namelink',v_namelink);
    obj_data.put('desclink',v_desclink);
    obj_data.put('filedoc',v_filedoc);
    obj_data.put('path_filedoc',v_path_filedoc);
    obj_data.put('namefiled',v_namefiled);
    obj_data.put('stalearn',v_stalearn);
    obj_data.put('qtytrainm',v_qtytrainm);
    obj_data.put('qtytrmin',nvl(v_qtytrmin,0));
    obj_data.put('dtechapst',to_char(nvl(v_dtechapst,sysdate),'dd/mm/yyyy hh24:mi'));
    if v_stalearn <> 'C' then
      if v_flgexam = '1' then
        if v_staexam = 'Y' then
          if v_staresult = 'Y' then
            obj_data.put('staexam','Y');
          else
            obj_data.put('staexam','N');
          end if;
        else
          if v_staresult is not null then
            obj_data.put('staexam','Y');
          else
            obj_data.put('staexam','N');
          end if;
        end if;
      else
        if v_stalearn = 'A' and v_qtytrainm is not null then
          obj_data.put('staexam','Y');
        else
          obj_data.put('staexam','N');
        end if;
      end if;
    end if;
    obj_data.put('dtetest',to_char(nvl(v_dtetest,sysdate),'dd/mm/yyyy'));
    json_str_output   := obj_data.to_clob;
    commit;
  end;
  --
  procedure get_chapter_detail(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_chapter_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_watched(json_str_input in clob,json_str_output out clob) is
    json_input    json_object_t;
    obj_data      json_object_t;
    v_dtechapst   tlrnchap.dtechapst%type;
    v_dtechapen   tlrnchap.dtechapen%type;
    v_dtecourst   tlrnchap.dtecourst%type;
--    v_dtesubjst   tlrnchap.dtesubjst%type;
    v_qtytrainm   tlrnchap.qtytrainm%type;
    v_stalearn    tlrnchap.stalearn%type;
    v_codexam     tlrnchap.codexam%type;
    v_staresult   tlrnchap.staexam%type;
    v_flgexam     tvchapter.flgexam%type;
    v_staexam     tvchapter.staexam%type;
    v_curr_date_time    date := to_date(to_char(sysdate,'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi');
  begin
    json_input      := json_object_t(json_str_input);
    v_dtechapst     := to_date(hcm_util.get_string_t(json_input,'dtechapst'),'dd/mm/yyyy hh24:mi');
--    v_dtechapen     := to_date(hcm_util.get_string_t(json_input,'dtechapen'),'dd/mm/yyyy hh24:mi');
    v_qtytrainm     := (v_curr_date_time - v_dtechapst)*1440;
    v_codexam       := hcm_util.get_string_t(json_input,'codexam');
    --
    begin
      select stalearn,staexam
        into v_stalearn,v_staresult
        from tlrnchap
       where codempid     = b_index_codempid
         and codcours     = b_index_codcours
         and dtecourst    = b_index_dtecourst
         and codsubj      = b_index_codsubj
         and chaptno      = b_index_chaptno;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvchapter');
      return;
    end;
    --+
    obj_data      := json_object_t();
    obj_data.put('coderror','200');
    if nvl(v_stalearn,'P') <> 'C' then
      begin
        select decode(flgexam,'1','Y','A'),staexam
          into v_stalearn,v_staexam
          from tvchapter
         where codcours     = b_index_codcours
           and codsubj      = b_index_codsubj
           and chaptno      = b_index_chaptno;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvchapter');
        return;
      end;
      if param_msg_error is null then
        begin
          insert into tlrnchap(codempid,codcours,dtecourst,codsubj,
                               chaptno,dtechapst,dtechapen,dtesubjst,
                               codexam,stalearn,qtytrainm,
                               codcreate,coduser)
          values (b_index_codempid,b_index_codcours,b_index_dtecourst,b_index_codsubj,
                  b_index_chaptno,v_dtechapst,v_dtechapen,b_index_dtesubjst,
                  v_codexam,v_stalearn,v_qtytrainm,
                  global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
          update tlrnchap
             set dtechapen    = v_curr_date_time,
                 qtytrainm    = (v_curr_date_time - v_dtechapst)*1440,
                 stalearn     = v_stalearn,
                 coduser      = global_v_coduser
           where codempid   = b_index_codempid
             and codcours   = b_index_codcours
             and dtecourst  = b_index_dtecourst
             and codsubj    = b_index_codsubj
             and chaptno    = b_index_chaptno
             and stalearn   <> 'C';
        end;
        commit;

        obj_data.put('stalearn',v_stalearn);
        if v_stalearn = 'A' then
          obj_data.put('staexam','Y');
        else
          if v_staexam = 'Y' then
            if v_staresult = 'Y' then
              obj_data.put('staexam','Y');
            else
              obj_data.put('staexam','N');
            end if;
          else
            if v_staresult is not null then
              obj_data.put('staexam','Y');
            else
              obj_data.put('staexam','N');
            end if;
          end if;
        end if;

      end if;
    end if;
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure watched_accept(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_watched(json_str_input, json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure exit_chapter(json_str_input in clob,json_str_output out clob) is
    json_input    json_object_t;
    v_dtechapst   tlrnchap.dtechapst%type;
    v_dtechapen   tlrnchap.dtechapen%type;
    v_dtecourst   tlrnchap.dtecourst%type;
--    v_dtesubjst   tlrnchap.dtesubjst%type;
    v_qtytrainm   tlrnchap.qtytrainm%type;
    v_stalearn    tlrnchap.stalearn%type;
    v_codexam     tlrnchap.codexam%type;
    v_qtytrmin    tvchapter.qtytrmin%type;
    v_qtychapt    tlrnsubj.qtychapt%type;

    v_curr_date_time    date := to_date(to_char(sysdate,'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi');
  begin
    initial_value(json_str_input);
    json_input      := json_object_t(json_str_input);
--    v_qtytrainm     := hcm_util.get_string_t(json_input,'p_qtytrainm');
    v_codexam       := hcm_util.get_string_t(json_input,'codexam');
    begin
      select decode(flgexam,'1','Y','P'),nvl(qtytrmin,qtytrainm)
        into v_stalearn,v_qtytrmin
        from tvchapter
       where codcours     = b_index_codcours
         and codsubj      = b_index_codsubj
         and chaptno      = b_index_chaptno;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvchapter');
    end;
    --
--    if nvl(v_qtytrainm,0) < nvl(v_qtytrmin,0) then
--      v_stalearn  := 'A';
--    end if;
    --
--    begin
--      insert into tlrnchap(codempid,codcours,dtecourst,codsubj,
--                           chaptno,dtechapst,dtesubjst,
--                           codexam,stalearn,qtytrainm,
--                           codcreate,coduser)
--      values (b_index_codempid,b_index_codcours,b_index_dtecourst,b_index_codsubj,
--              b_index_chaptno,v_curr_date_time,b_index_dtesubjst,
--              v_codexam,'A',v_qtytrainm,
--              global_v_coduser,global_v_coduser);
--    exception when dup_val_on_index then
--      update tlrnchap
--         set stalearn     = v_stalearn,
--             coduser      = global_v_coduser
--       where codempid   = b_index_codempid
--         and codcours   = b_index_codcours
--         and dtecourst  = b_index_dtecourst
--         and codsubj    = b_index_codsubj
--         and chaptno    = b_index_chaptno
--         and nvl(stalearn,'P')   not in ('C','Y');
--    end;

    begin
      select count(*)
        into v_qtychapt
        from tlrnchap
       where codempid     = b_index_codempid
         and codcours     = b_index_codcours
         and dtecourst    = b_index_dtecourst
         and codsubj      = b_index_codsubj
         and stalearn     = 'C';
    end;
    --
    begin
      insert into tlrnsubj(codempid,codcours,dtecourst,codsubj,
                           dtesubjst,codexam,stalearn,codcreate,
                           coduser)
      values (b_index_codempid,b_index_codcours,b_index_dtecourst,b_index_codsubj,
              v_curr_date_time,v_codexam,'A',global_v_coduser,
              global_v_coduser);
    exception when dup_val_on_index then
      update tlrnsubj
         set stalearn     = 'A',
             qtychapt     = v_qtychapt,
             coduser      = global_v_lang
       where codempid     = b_index_codempid
         and codcours     = b_index_codcours
         and dtecourst    = b_index_dtecourst
         and codsubj      = b_index_codsubj
         and nvl(stalearn,'P') not in ('C','Y');
    end;
    --
    begin
      update tlrncourse
         set stalearn     = 'A',
             codsubj      = b_index_codsubj,
             chaptno      = b_index_chaptno,
             coduser      = global_v_coduser
       where codempid     = b_index_codempid
         and codcours     = b_index_codcours
         and dtecourst    = b_index_dtecourst
         and nvl(stalearn,'P') in ('P','A');
    end;

    commit;
    param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_done_chapter(json_str_input in clob) is
    json_input    json_object_t;
    v_qtychapt    tlrnsubj.qtychapt%type;
    v_flgexam     tvsubject.flgexam%type;
    v_all_qtychapt    number;
    v_qty_chapt_subj    number;
    v_curr_date_time    date := to_date(to_char(sysdate,'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi');
  begin
    update tlrnchap
       set stalearn     = 'C',
           dtechapen    = v_curr_date_time,
           qtytrainm    = (v_curr_date_time - dtechapst)*1440,
           coduser      = global_v_coduser
     where codempid     = b_index_codempid
       and codcours     = b_index_codcours
       and dtecourst    = b_index_dtecourst
       and codsubj      = b_index_codsubj
       and chaptno      = b_index_chaptno
       and nvl(stalearn,'P') <> 'C';
    --
    begin
      select count(*)
        into v_qtychapt -- chapter of subject
        from tlrnchap
       where codempid     = b_index_codempid
         and codcours     = b_index_codcours
         and dtecourst    = b_index_dtecourst
         and codsubj      = b_index_codsubj
         and stalearn     = 'C';
    end;
    --
    begin
      select count(*)
        into v_qty_chapt_subj
        from tvchapter
       where codcours     = b_index_codcours
         and codsubj      = b_index_codsubj;
    end;
    --
    begin
      select flgexam
        into v_flgexam
        from tvsubject
       where codcours   = b_index_codcours
         and codsubj    = b_index_codsubj;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvsubject');
    end;
    --
    update tlrnsubj
       set qtychapt     = v_qtychapt,
           stalearn     = decode(v_qty_chapt_subj,v_qtychapt,decode(v_flgexam,'1','Y','A'),'A'),
           coduser      = global_v_coduser
     where codempid     = b_index_codempid
       and codcours     = b_index_codcours
       and dtecourst    = b_index_dtecourst
       and codsubj      = b_index_codsubj
       and nvl(stalearn,'P') <> 'C';
    --
    begin
      select count(*)
        into v_all_qtychapt -- all chapter
        from tvchapter
       where codcours     = b_index_codcours;
--    exception when no_data_found then
--      param_msg_error     := get_error_msg_php('HR2010',global_v_lang,'tvcourse');
--      return;
    end;
    --
    begin
      select count(*)
        into v_qtychapt -- chapter of course
        from tlrnchap
       where codempid     = b_index_codempid
         and codcours     = b_index_codcours
         and dtecourst    = b_index_dtecourst
         and stalearn     = 'C';
    end;
    --
    update tlrncourse
       set codsubj      = b_index_codsubj,
           chaptno      = b_index_chaptno,
           pctprogress  = nvl(v_qtychapt,0)*100/v_all_qtychapt,
           coduser      = global_v_coduser
     where codempid     = b_index_codempid
       and codcours     = b_index_codcours
       and dtecourst    = b_index_dtecourst
       and nvl(stalearn,'P') <> 'C';

    commit;
    param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
  end;
  --
  procedure done_chapter(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_done_subject(json_str_input);
    if param_msg_error is null then
      save_done_chapter(json_str_input);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

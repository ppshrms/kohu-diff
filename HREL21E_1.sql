--------------------------------------------------------
--  DDL for Package Body HREL21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL21E" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codcours    := hcm_util.get_string_t(json_obj,'p_codcours');
    b_index_numclseq    := hcm_util.get_string_t(json_obj,'p_numclseq');
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid');
    b_index_dteyear     := hcm_util.get_string_t(json_obj,'p_dteyear');
    b_index_dtecourst   := to_date(nvl(hcm_util.get_string_t(json_obj,'p_dtecourst'),to_char(sysdate,'dd/mm/yyyy hh24:mi')),'dd/mm/yyyy hh24:mi');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    begin
      select typcours,flgdata
        into p_typcours,p_flgdata
        from tvcourse
       where codcours   = b_index_codcours;
    exception when no_data_found then null;
    end;
  end;
  --
  procedure get_random_exam_by_category(p_codcatexm varchar2,
                                        p_codexam   out varchar2,
                                        p_msg_error out varchar2) is
    v_codexam     tvtest.codexam%type;
    v_msg_error   varchar2(4000);
  begin
    if p_codcatexm is not null then
      begin
        select codexam into v_codexam
          from (
            select codexam
              from tvtest
             where codcatexm   = p_codcatexm
            order by dbms_random.random
          )
         where rownum = 1;
      exception when no_data_found then
        v_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvtest');
      end;
    end if;
    p_codexam     := v_codexam;
    p_msg_error   := v_msg_error;
  end;
  --
  procedure gen_course_detail(json_str_output out clob) is
    obj_data          json_object_t;
    v_codcours        tcourse.codcours%type;
    v_desc_codcours   tcourse.namcourse%type;
    v_descours        tcourse.descours%type;
    v_descobjt        tcourse.descobjt%type;
    v_typcours        tcourse.typcours%type;
    v_codcatpre       tvcourse.codcatpre%type;
    v_codcatpo        tvcourse.codcatpo%type;
    v_descours2       tvcourse.descours%type;
    v_qtysubj         tvcourse.qtysubj%type;
    v_filemedia       tvcourse.filemedia%type;
    v_flgpretest      tvcourse.flgpreteset%type;
    v_flgposttest     tvcourse.flgposttest%type;
    v_staresult       tvcourse.staresult%type;
    v_dtetrst         tpotentp.dtetrst%type;
    v_dtetren         tpotentp.dtetren%type;
    v_codexampr       tlrncourse.codexampr%type;
    v_codexampo       tlrncourse.codexampo%type;
    v_stapreteset     tlrncourse.stapreteset%type;
    v_staposttest     tlrncourse.staposttest%type;
    v_qtyprescr       tlrncourse.qtyprescr%type;
    v_qtyposscr       tlrncourse.qtyposscr%type;
    v_stalearn        tlrncourse.stalearn%type;
    v_dteprest        tyrtrsch.dteprest%type;
    v_dtepreen        tyrtrsch.dtepreen%type;
    v_dtepostst       tyrtrsch.dtepostst%type;
    v_dteposten       tyrtrsch.dteposten%type;

    v_codcompy        tcompny.codcompy%type;
    v_codcomp         temploy1.codcomp%type;
    v_codpos          temploy1.codpos%type;
    v_path_filemedia  varchar2(2000);
    v_cnt_stalrn_y    number;
    v_cnt_stalrn_n    number;
    v_flgfinish       varchar2(1) := 'N';
    v_dtetest_pre     date;
    v_dtetest_post    date;
    
  begin
    begin
      select codcours,
             get_tcourse_name(codcours,global_v_lang),
             descours,descobjt
        into v_codcours,v_desc_codcours,v_descours,v_descobjt
        from tcourse
       where codcours   = b_index_codcours;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tcourse');
      return;
    end;

    begin
      select descours,codexampr,codexampo,codcatpre,codcatpo,
             typcours,qtysubj,filemedia,flgpreteset,flgposttest,
             staresult
        into v_descours2,v_codexampr,v_codexampo,v_codcatpre,v_codcatpo,
             v_typcours,v_qtysubj,v_filemedia,v_flgpretest,v_flgposttest,
             v_staresult
        from tvcourse
       where codcours   = b_index_codcours
         and rownum     = 1;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvcourse');
      return;
    end;

    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid   = b_index_codempid;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      return;
    end;
    v_codcompy    := hcm_util.get_codcomp_level(v_codcomp,1);
    begin
      select dtetrst,dtetren
        into v_dtetrst,v_dtetren
        from tpotentp
       where dteyear    = b_index_dteyear
         and codcompy   = v_codcompy
         and numclseq   = b_index_numclseq
         and codcours   = b_index_codcours
         and codempid   = b_index_codempid;
    exception when no_data_found then
      v_dtetrst   := null;
      v_dtetren   := null;
    end;
    
    begin
      select nvl(codexampr,v_codexampr) as codexampr,nvl(codexampo,v_codexampo) as codexampo,stapreteset,
             staposttest,qtyprescr,qtyposscr,stalearn
        into v_codexampr,v_codexampo,v_stapreteset,
             v_staposttest,v_qtyprescr,v_qtyposscr,v_stalearn
        from tlrncourse
       where codempid     = b_index_codempid
         and codcours     = b_index_codcours
         and dtecourst    = b_index_dtecourst;
    exception when no_data_found then
      if v_codcatpre is not null then
        get_random_exam_by_category(v_codcatpre,v_codexampr,param_msg_error);
        if param_msg_error is not null then
          return;
        end if;
      end if;
      if v_codcatpo is not null then
        get_random_exam_by_category(v_codcatpo,v_codexampo,param_msg_error);
        if param_msg_error is not null then
          return;
        end if;
      end if;
    end;
    begin
      select dteprest,dtepreen,dtepostst,dteposten
        into v_dteprest,v_dtepreen,v_dtepostst,v_dteposten
        from tyrtrsch
       where dteyear    = b_index_dteyear
         and codcompy   = v_codcompy
         and codcours   = b_index_codcours
         and numclseq   = b_index_numclseq;
    exception when no_data_found then
      v_dteprest    := null;
      v_dtepreen    := null;
      v_dtepostst   := null;
      v_dteposten   := null;
    end;
    --
    begin
      select sum(decode(stalearn,'C',1,0)) as cnt_y,
             sum(decode(stalearn,'C',0,1)) as cnt_n
        into v_cnt_stalrn_y,v_cnt_stalrn_n
        from tlrnsubj
       where codempid     = b_index_codempid
         and codcours     = b_index_codcours
         and dtecourst    = b_index_dtecourst;
    end;
    --
    -- begin
    --   select max(decode(typetest,'1',dtetest)),max(decode(typetest,'2',dtetest))
    --     into v_dtetest_pre,v_dtetest_post
    --     from ttestemp
    --    where codempid     = b_index_codempid
    --      and codexam      = v_codexampr
    --      and typtest      = case when b_index_dteyear is not null and b_index_numclseq is not null then '5' else '4' end;
    -- end;
    -- --
    -- if trunc(sysdate) between v_dteprest and v_dtepreen then
    --   v_flgposttest   := 'Y';
    -- else
    --   v_flgposttest   := 'N';
    -- end if;
    --
    -- if trunc(sysdate) between v_dtepostst and v_dteposten then
    --   if v_flgposttest  = 'Y' then
    --     if v_stalearn = 'Y' then
    --       v_flgposttest   := 'Y';
    --     else
    --       v_flgposttest   := 'N';
    --     end if;
    --     if v_staresult = 'Y' then
    --       if v_staposttest = 'Y' then
    --         v_flgfinish     := 'Y';
    --       else
    --         v_flgfinish     := 'N';
    --       end if;
    --     else
    --       if v_staposttest is not null then
    --         v_flgfinish     := 'Y';
    --       else
    --         v_flgfinish     := 'N';
    --       end if;
    --     end if;
    --   else
    --     if v_cnt_stalrn_y > 0 and v_cnt_stalrn_n = 0 then
    --       v_flgfinish       := 'Y';
    --     else
    --       v_flgfinish       := 'N';
    --     end if;
    --   end if;
    -- else
    --   v_flgposttest   := 'N';
    -- end if;
    if nvl(v_stalearn,'P') <> 'C' then
      if trunc(sysdate) between v_dtepostst and v_dteposten then
        if v_flgposttest  = 'Y' then
          if v_stalearn = 'Y' then
              v_flgposttest   := 'Y';
          else
              v_flgposttest   := 'N';
          end if;
          if v_staresult = 'Y' then
            -- if v_flgpostansfull = 'N' then
            --   if v_staposttest <> 'W' then
            --     v_staposttest   := v_staposttest||'F';
            --   end if;
            --   v_flgfinish     := 'N';
            -- else
            if v_staposttest = 'Y' then
              v_flgfinish     := 'Y';
            else
              v_flgfinish     := 'N';
            end if;
            -- end if;
          else
            if v_staposttest is not null then
              v_flgfinish     := 'Y';
            else
              v_flgfinish     := 'N';
            end if;
          end if;
        else
          if v_cnt_stalrn_y > 0 and v_cnt_stalrn_n = 0 then
              v_flgfinish       := 'Y';
          else
              v_flgfinish       := 'N';
          end if;
        end if;
      else
--        if v_flgposttest  = 'Y' and v_stalearn = 'Y' then
--          if v_staposttest = 'N' then
--            begin
--              select dtetest, 'Y'
--                into v_dtetest_post, v_flgposttest
--                from ttestemp
--               where codempid     = b_index_codempid
--                 and codexam      = v_codexampr
--                 and typtest      = case when b_index_dteyear is not null and b_index_numclseq is not null then '5' else '4' end
--                 and typetest     = '2';
--            exception when no_data_found then
--              null;
--            end;
--          end if;
--        end if;
        v_flgposttest   := 'N';
      end if;
    end if;
    --
    v_path_filemedia  := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HREL01E')||'/'||v_filemedia;
    obj_data      := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('codempid',b_index_codempid);
    obj_data.put('desc_codempid',get_temploy_name(b_index_codempid,global_v_lang));
    obj_data.put('codcomp',v_codcomp);
    obj_data.put('codpos',v_codpos);
    obj_data.put('codcours',v_codcours);
    obj_data.put('desc_codcours',v_desc_codcours);
    obj_data.put('descours',v_descours);
    obj_data.put('dtecourst',to_char(b_index_dtecourst,'dd/mm/yyyy hh24:mi'));
    obj_data.put('descobjt',v_descobjt);
    obj_data.put('typcours',v_typcours);
    obj_data.put('descourstv',v_descours2);
    obj_data.put('dtetrst',to_char(v_dtetrst,'dd/mm/yyyy hh24:mi'));
    obj_data.put('dtetren',to_char(v_dtetren,'dd/mm/yyyy hh24:mi'));
    obj_data.put('codexampr',v_codexampr);
    obj_data.put('desc_codexampr',get_tvtest_name(v_codexampr,global_v_lang));
    obj_data.put('dteprest',to_char(v_dteprest,'dd/mm/yyyy hh24:mi'));
    obj_data.put('dtepreen',to_char(v_dtepreen,'dd/mm/yyyy hh24:mi'));
    obj_data.put('qtyprescr',v_qtyprescr);
    obj_data.put('flgPretestDisp',v_flgpretest);
    obj_data.put('stapreteset',v_stapreteset);
    obj_data.put('desc_stapreteset',get_tlistval_name('STATEST',v_stapreteset,global_v_lang));
    obj_data.put('codexampo',v_codexampo);
    obj_data.put('desc_codexampo',get_tvtest_name(v_codexampo,global_v_lang));
    obj_data.put('dtepostst',to_char(v_dtepostst,'dd/mm/yyyy hh24:mi'));
    obj_data.put('dteposten',to_char(v_dteposten,'dd/mm/yyyy hh24:mi'));
    obj_data.put('qtyposscr',v_qtyposscr);
    obj_data.put('flgPosttestDisp',v_flgposttest);
    obj_data.put('staposttest',v_staposttest);
    obj_data.put('desc_staposttest',get_tlistval_name('STATEST',v_staposttest,global_v_lang));
    obj_data.put('qtysubj',v_qtysubj);
    obj_data.put('filemedia',v_filemedia);
    obj_data.put('path_filemedia',v_path_filemedia);
    obj_data.put('stalearn',v_stalearn);
    obj_data.put('flgfinish',v_flgfinish);
    obj_data.put('dtetest_pre',to_char(nvl(v_dtetest_pre,sysdate),'dd/mm/yyyy'));
    obj_data.put('dtetest_post',to_char(nvl(v_dtetest_post,sysdate),'dd/mm/yyyy'));
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_course_detail(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_course_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure post_pre_test(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    v_codexampr     tlrncourse.codexampr%type;
    v_codexampo     tlrncourse.codexampo%type;
    v_sysdate       date := to_date(to_char(sysdate,'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi');
    v_typtest       ttestemp.typtest%type := '4';
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
  begin
    initial_value(json_str_input);
    json_input      := json_object_t(json_str_input);
    v_codexampr     := hcm_util.get_string_t(json_input,'codexampr');
    v_codexampo     := hcm_util.get_string_t(json_input,'codexampo');
    begin
      select codcomp, codpos
        into v_codcomp, v_codpos
        from temploy1
       where codempid   = b_index_codempid;
    end;
    begin
      insert into tlrncourse (codempid,codcours,dtecourst,stalearn,
                              codexampr,codexampo,flgdata,typcours,dteyear,
                              numclseq,codcreate,coduser)
      values (b_index_codempid,b_index_codcours,b_index_dtecourst,'P',
              v_codexampr,v_codexampo,p_flgdata,p_typcours,b_index_dteyear,
              b_index_numclseq,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      null;
    end;
    --
    if b_index_dteyear is not null and b_index_numclseq is not null then
      v_typtest     := '2';
    end if;
    begin
      insert into ttestemp (codempid,codexam,dtetest,namtest,
                            dtetestst,typtest,dteyear,numclseq,
                            codcours,flgtest,flglogin,codcomp,
                            codpos,codcreate,coduser)
      values (b_index_codempid,v_codexampr,v_sysdate,get_temploy_name(b_index_codempid,global_v_lang),
              v_sysdate,v_typtest,b_index_dteyear,b_index_numclseq,
              b_index_codcours,'P','3',v_codcomp,
              v_codpos,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      null;
    end;
    commit;
    param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure post_pos_test(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    v_codexampo     tlrncourse.codexampo%type;
    v_sysdate       date := to_date(to_char(sysdate,'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi');
    v_typtest       ttestemp.typtest%type := '4';
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_check         varchar2(1) := 'N';
  begin
    initial_value(json_str_input);
    json_input      := json_object_t(json_str_input);
    v_codexampo     := hcm_util.get_string_t(json_input,'codexampo');
    begin
      select 'Y'
        into v_check
        from ttestemp
       where codempid   = b_index_codempid
         and codexam    = v_codexampo
         and dtetest    = (select dtetest
                             from ttestemp
                            where codempid            = b_index_codempid
                              and codexam             = v_codexampo
                              and nvl(dteyear,9999)   = nvl(b_index_dteyear,nvl(dteyear,9999))
                              and nvl(numclseq,99)    = nvl(b_index_numclseq,nvl(numclseq,99))
                              and codcours            = b_index_codcours
                              and rownum              = 1);
    exception when no_data_found then
      begin
        select codcomp,codpos
          into v_codcomp,v_codpos
          from temploy1
         where codempid   = b_index_codempid;
      end;
      if b_index_dteyear is not null and b_index_numclseq is not null then
        v_typtest     := '2';
      end if;
      begin
        insert into ttestemp (codempid,codexam,dtetest,namtest,
                              dtetestst,typtest,dteyear,numclseq,
                              codcours,flgtest,flglogin,codcomp,
                              codpos,codcreate,coduser)
        values (b_index_codempid,v_codexampo,v_sysdate,get_temploy_name(b_index_codempid,global_v_lang),
                v_sysdate,v_typtest,b_index_dteyear,b_index_numclseq,
                b_index_codcours,'P','3',v_codcomp,
                v_codpos,global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        null;
      end;
    end;

    commit;
    param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_subject(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_codsubj       tvsubject.codsubj%type;
    v_codcompy      tcompny.codcompy%type;
    v_show_icon     varchar2(1) := 'N';
    v_pre_test      varchar2(1) := 'N';
    v_flgpretest    tvcourse.flgpreteset%type;
    cursor c_tsubject is
      select codsubj,get_tsubject_name(codsubj,global_v_lang) desc_codsubj,
             qtychapt
        from tvsubject
       where codcours   = b_index_codcours
      order by codsubj;

    cursor c_tlrnsubj is
      select staexam,dtesubjst,stalearn
        from tlrnsubj
       where codempid     = b_index_codempid
         and codcours     = b_index_codcours
         and dtecourst    = b_index_dtecourst
         and codsubj      = v_codsubj;
  begin
    begin
      select hcm_util.get_codcomp_level(codcomp,1)
        into v_codcompy
        from temploy1
       where codempid   = b_index_codempid;
    end;
    --
    begin
      select flgpreteset
        into v_flgpretest
        from tvcourse
       where codcours   = b_index_codcours
         and rownum     = 1;
    exception when no_data_found then null;
    end;
    --
    begin
      select 'Y'
        into v_pre_test
        from tlrncourse
        where codempid     = b_index_codempid
          and codcours     = b_index_codcours
          and dtecourst    = b_index_dtecourst
          and qtyprescr    is not null;
    exception when no_data_found then
      v_pre_test := 'N';
    end;
    
    if nvl(v_flgpretest,'N') <> 'Y' then
      v_pre_test      := 'Y';
    end if;
    --
    obj_row       := json_object_t();
    if b_index_numclseq is not null then
      begin
        select 'Y'
          into v_show_icon
          from tyrtrsch
         where dteyear     = b_index_dteyear
           and codcompy    = v_codcompy
           and codcours    = b_index_codcours
           and numclseq    = b_index_numclseq
           and trunc(sysdate) between dtetrst and dtetren;
      exception when no_data_found then
        v_show_icon   := 'N';
      end;
    else
      v_show_icon   := 'Y';
    end if;
    --
    for r_tsubject in c_tsubject loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      if v_show_icon = 'Y' and v_pre_test = 'Y' then
        obj_data.put('icon','<i class="fa fa-book"></i>');
      end if;
      obj_data.put('codsubj',r_tsubject.codsubj);
      obj_data.put('desc_codsubj',r_tsubject.desc_codsubj);
      obj_data.put('qtychapt',r_tsubject.qtychapt);
      obj_data.put('desc_stalearn',get_tlistval_name('STALEARN','P',global_v_lang));
      v_codsubj   := r_tsubject.codsubj;
      for r_tlrnsubj in c_tlrnsubj loop
        obj_data.put('staexam',r_tlrnsubj.staexam);
        obj_data.put('desc_staexam',get_tlistval_name('STATEST',r_tlrnsubj.staexam,global_v_lang));
        obj_data.put('dtesubjst',to_char(r_tlrnsubj.dtesubjst,'dd/mm/yyyy hh24:mi'));
        obj_data.put('stalearn',r_tlrnsubj.stalearn);
        obj_data.put('desc_stalearn',get_tlistval_name('STALEARN',nvl(r_tlrnsubj.stalearn,'P'),global_v_lang));
      end loop;
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_subject(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_subject(json_str_input,json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure leave_course(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    json_couse      json_object_t;
    json_couse_data json_object_t;
    v_qtysubj       tvcourse.qtysubj%type;
    v_codexampr     tlrncourse.codexampr%type;
    v_codexampo     tlrncourse.codexampo%type;
--    v_codsubj       tlrncourse.codsubj%type;
--    v_chaptno       tlrncourse.chaptno%type;
    v_sysdate       date := to_date(to_char(sysdate,'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi');
    v_progress      number;
    v_sum_qtychapt  number;

    v_typtest       ttestemp.typtest%type := '4';
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
  begin
--    initial_value(json_str_input);
--    json_input      := json_object_t(json_str_input);
--    json_couse      := hcm_util.get_json_t(json_input,'course');
--    json_couse_data := hcm_util.get_json_t(json_couse,'courseData');
--    v_codexampr     := hcm_util.get_string_t(json_couse_data,'codexampr');
--    v_codexampo     := hcm_util.get_string_t(json_couse_data,'codexampo');
--    v_codsubj       := hcm_util.get_string_t(json_input,'codsubj');
--    v_chaptno       := hcm_util.get_string_t(json_input,'chaptno');
--    begin
--      select sum(qtychapt)
--        into v_sum_qtychapt
--        from tlrnsubj t1
--       where codempid   = b_index_codempid
--         and codcours   = b_index_codcours
--         and dtecourst  = b_index_dtecourst;
--    end;
--
--    begin
--      select qtysubj
--        into v_qtysubj
--        from tvcourse
--       where codcours   = b_index_codcours
--         and rownum     = 1;
--    exception when no_data_found then
--      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvcourse');
--      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
--      return;
--    end;
--
--    v_progress      := v_sum_qtychapt*100/v_qtysubj;
--    begin
--      insert into tlrncourse (codempid,codcours,dtecourst,stalearn,
--                              codexampr,codexampo,flgdata,typcours,
--                              dteyear,numclseq,--codsubj,chaptno,
--                              pctprogress,codcreate,coduser)
--      values (b_index_codempid,b_index_codcours,b_index_dtecourst,'P',
--              v_codexampr,v_codexampo,p_flgdata,p_typcours,
--              b_index_dteyear,b_index_numclseq,--v_codsubj,v_chaptno,
--              v_progress,global_v_coduser,global_v_coduser);
--    exception when dup_val_on_index then null;
--      update tlrncourse
--         set codsubj         = v_codsubj,
--             chaptno         = v_chaptno,
--             pctprogress     = v_progress,
--             coduser         = global_v_coduser
--       where codempid        = b_index_codempid
--         and codcours        = b_index_codcours
--         and dtecourst       = b_index_dtecourst;
--    end;

--    commit;
    param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure take_exam(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    json_couse      json_object_t;
    json_couse_data json_object_t;
    v_qtysubj       tvcourse.qtysubj%type;
    v_codexampr     tlrncourse.codexampr%type;
    v_codexampo     tlrncourse.codexampo%type;
    v_sysdate       date := to_date(to_char(sysdate,'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi');

    v_typtest       ttestemp.typtest%type := '4';
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
  begin
    initial_value(json_str_input);
    json_input      := json_object_t(json_str_input);
    json_couse      := hcm_util.get_json_t(json_input,'course');
    json_couse_data := hcm_util.get_json_t(json_couse,'courseData');
    v_codexampr     := hcm_util.get_string_t(json_couse_data,'codexampr');
    v_codexampo     := hcm_util.get_string_t(json_couse_data,'codexampo');

    begin
      select qtysubj
        into v_qtysubj
        from tvcourse
       where codcours   = b_index_codcours
         and rownum     = 1;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvcourse');
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end;

    begin
      insert into tlrncourse (codempid,codcours,dtecourst,stalearn,
                              codexampr,codexampo,flgdata,typcours,
                              dteyear,numclseq,codcreate,coduser)
      values (b_index_codempid,b_index_codcours,b_index_dtecourst,'P',
              v_codexampr,v_codexampo,p_flgdata,p_typcours,
              b_index_dteyear,b_index_numclseq,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then null;
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
  procedure check_done_course(json_str_input in clob) is
--    json_input    json_object_t;
    v_staposttest varchar2(1) := 'N';
    v_qtyprescr   number := 0;
    v_qtyposscr   number := 0;
  begin
--    json_input    := json_object_t(json_str_input);
    begin
      select flgposttest
        into p_flgposttest
        from tvcourse
       where codcours     = b_index_codcours
         and flgposttest  = 'Y';
    exception when no_data_found then
      p_flgposttest   := null;
    end;

    if p_flgposttest = 'Y' then
      begin
        select nvl(qtyprescr,0),nvl(qtyposscr,0),staposttest
          into v_qtyprescr,v_qtyposscr,v_staposttest
          from tlrncourse
         where codempid        = b_index_codempid
           and codcours        = b_index_codcours
           and dtecourst       = b_index_dtecourst;
      exception when no_data_found then
        v_qtyprescr    := 0;
        v_qtyposscr    := 0;
        v_staposttest  := 'N';
      end;
      if v_qtyposscr = 0 then
        param_msg_error   := get_error_msg_php('EL0014',global_v_lang);
        return;
      end if;
--      if v_staposttest = 'N' then
--        param_msg_error   := get_error_msg_php('EL0016',global_v_lang);
--        return;
--      end if;

      if v_qtyposscr > 0 and v_staposttest = 'Y' then
        update thistrnn
           set qtyposscr    = v_qtyposscr,
               qtyprescr    = v_qtyprescr,
               coduser      = global_v_coduser
         where codempid   = b_index_codempid
           and dteyear    = b_index_dteyear
           and codcours   = b_index_codcours
           and numclseq   = b_index_numclseq;
      end if;
    end if;
  end;
  --
  procedure save_done_course(json_str_input in clob) is
--    json_input      json_object_t;
    v_dtegradtn     tlrncourse.dtegradtn%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_codcompy      tcompny.codcompy%type;
    v_qtytrmin      tvchapter.qtytrmin%type;
    v_qtytrainm     tlrnchap.qtytrainm%type;

    v_dtetrst       date;
    v_dtetren       date;
    v_sysdate       date := to_date(to_char(sysdate,'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi');
    v_check         varchar2(1) := 'N';
    v_trhr          varchar2(100);
    v_tmhr          varchar2(100);
    v_pct_trhr      number;
  begin
--    json_input      := json_object_t(json_str_input);
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid   = b_index_codempid;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'temploy1');
    end;
    --
    v_codcompy    := hcm_util.get_codcomp_level(v_codcomp,1);
    --
    begin
      select nvl(max(dtegradtn),v_sysdate)
        into v_dtegradtn
        from tlrnsubj
       where codempid     = b_index_codempid
         and codcours     = b_index_codcours
         and dtecourst    = b_index_dtecourst;
    end;
    --

    update tlrncourse
       set dtegradtn       = v_dtegradtn,
           stalearn        = 'C', --Complete
           pctprogress     = 100, --100% Progress
           coduser         = global_v_coduser
     where codempid        = b_index_codempid
       and codcours        = b_index_codcours
       and dtecourst       = b_index_dtecourst;
    --
    if p_typcours = 'Y' then
      begin
        select 'Y'
          into v_check
          from tyrtrsch
         where dteyear    = b_index_dteyear
           and codcompy   = v_codcompy
           and codcours   = b_index_codcours
           and numclseq   = b_index_numclseq
           and dteprest is not null
           and dtepostst is not null;
      exception when no_data_found then
        null;
      end;
      if (p_flgposttest = 'Y' and v_check = 'Y') or p_flgposttest = 'N' then
        update tpotentp
           set flgatend   = 'Y',
               coduser    = global_v_coduser
         where codempid   = b_index_codempid
           and dteyear    = b_index_dteyear
           and codcompy   = v_codcompy
           and codcours   = b_index_codcours
           and numclseq   = b_index_numclseq;
      end if;
    elsif p_typcours = 'O' and p_flgdata = 'Y' then
      begin
        select dtetrst,dtetren
          into v_dtetrst,v_dtetren
          from tpotentp
         where dteyear    = b_index_dteyear
           and codcompy   = v_codcompy
           and numclseq   = b_index_numclseq
           and codcours   = b_index_codcours
           and codempid   = b_index_codempid
           and rownum     = 1;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tpotentp');
        return;
      end;
      --
      begin
        select sum(qtytrmin)
          into v_qtytrmin
          from tvchapter
         where codcours   = b_index_codcours;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvchapter');
        return;
      end;
      --
      begin
        select sum(qtytrainm)
          into v_qtytrainm
          from tlrnchap
         where codempid   = b_index_codempid
           and codcours   = b_index_codcours
           and dtecourst  = b_index_dtecourst;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'tvchapter');
        return;
      end;
      --
      v_trhr      := hcm_util.convert_minute_to_hour(v_qtytrmin);
      v_tmhr      := hcm_util.convert_minute_to_hour(v_qtytrainm);
      v_pct_trhr  := v_qtytrainm*100/v_qtytrmin;
      insert into thistrnn(codempid,dteyear,codcours,numclseq,
                           dtemonth,codpos,codcomp,codtparg,
                           dtetrst,dtetren,qtytrmin,qtytrpln,
                           pcttr,codcreate,coduser)
      values (b_index_codempid,b_index_dteyear,b_index_codcours,b_index_numclseq,
              to_number(to_char(v_dtetrst,'mm')),v_codpos,v_codcomp,'1',
              v_dtetrst,v_dtetren,v_qtytrainm,v_qtytrmin,
              v_pct_trhr,global_v_coduser,global_v_coduser);
    end if;

    begin
      insert into thisclss(dteyear,codcompy,codcours,numclseq,dtemonth,
                           codtparg,objective,codresp,codhotel,codinsts,
                           dtetrst,dtetren,timestr,timeend,qtyppc,
                           qtytrmin,amttotexp,amtcost,
                           typtrain,dteprest,dtepreen,codexampr,
                           dtepostst,dteposten,codexampo,
                           qtyppcac,costcent,flgcerti,codcreate,coduser)
      select dteyear,codcompy,codcours,numclseq,to_char(dtetrst,'mm'),
             codtparg,descobjt,codresp,codhotel,codinsts,
             dtetrst,dtetren,timestr,timeend,qtyemp,
             qtytrmin,amtclbdg,amttremp,
             typtrain,dteprest,dtepreen,codexampr,
             dtepostst,dteposten,codexampo,
             qtyppc,costcent,flgcerti,global_v_coduser,global_v_coduser
       from tyrtrsch
      where dteyear     = b_index_dteyear
        and codcompy    = v_codcompy
        and codcours    = b_index_codcours
        and numclseq    = b_index_numclseq;
    exception when no_data_found then null;
              when dup_val_on_index then null;
    end;

    commit;
    param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
  end;
  --
  procedure done_course(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_done_course(json_str_input);
    if param_msg_error is null then
      save_done_course(json_str_input);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

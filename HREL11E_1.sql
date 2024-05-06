--------------------------------------------------------
--  DDL for Package Body HREL11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL11E" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    b_index_dteyear     := hcm_util.get_string_t(json_obj,'p_dteyear');
    b_index_dtemonth    := lpad(hcm_util.get_string_t(json_obj,'p_dtemonth'),2,'0');

    b_index_dteyear     := nvl(b_index_dteyear,to_char(sysdate,'yyyy'));
    b_index_dtemonth    := nvl(b_index_dtemonth,to_char(sysdate,'mm'));

    begin
      select codcomp
        into global_v_codcomp
        from temploy1
       where codempid    = global_v_codempid;
    exception when no_data_found then
      null;
    end;

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure gen_graph_learning(json_str_output out clob) is
    obj_data        json_object_t;
    v_curr_year     number := to_number(to_char(sysdate,'yyyy'));
    v_codcompy      tcompny.codcompy%type;
    cursor c_lrncourse is
      select sum(decode(cours_month,'01',1,0)) as qtymth01,
             sum(decode(cours_month,'02',1,0)) as qtymth02,
             sum(decode(cours_month,'03',1,0)) as qtymth03,
             sum(decode(cours_month,'04',1,0)) as qtymth04,
             sum(decode(cours_month,'05',1,0)) as qtymth05,
             sum(decode(cours_month,'06',1,0)) as qtymth06,
             sum(decode(cours_month,'07',1,0)) as qtymth07,
             sum(decode(cours_month,'08',1,0)) as qtymth08,
             sum(decode(cours_month,'09',1,0)) as qtymth09,
             sum(decode(cours_month,'10',1,0)) as qtymth10,
             sum(decode(cours_month,'11',1,0)) as qtymth11,
             sum(decode(cours_month,'12',1,0)) as qtymth12
        from (select distinct codempid,to_char(dtecourst,'mm') as cours_month
                from tlrncourse
               where to_char(dtecourst,'yyyy') = v_curr_year
                 and b_index_dteyear           = v_curr_year)
      order by cours_month;

    cursor c_tlrnels is
      select qtyemp1,qtyemp2,qtyemp3,qtyemp4,
             qtyemp5,qtyemp6,qtyemp7,qtyemp8,
             qtyemp9,qtyemp10,qtyemp11,qtyemp12
        from tlrnels
       where dteyear  = b_index_dteyear
       and codcompy   = v_codcompy; -- #4675||04/05/2022||user39

  begin
    v_codcompy    := hcm_util.get_codcomp_level(global_v_codcomp,1);
    for r_lrncourse in c_lrncourse loop
      begin
        insert into tlrnels(dteyear,codcompy,dtelast,qtyemp1,qtyemp2,
                            qtyemp3,qtyemp4,qtyemp5,qtyemp6,qtyemp7,
                            qtyemp8,qtyemp9,qtyemp10,qtyemp11,qtyemp12,
                            codcreate,coduser)
        values (v_curr_year,v_codcompy,trunc(sysdate),r_lrncourse.qtymth01,r_lrncourse.qtymth02,
                r_lrncourse.qtymth03,r_lrncourse.qtymth04,r_lrncourse.qtymth05,r_lrncourse.qtymth06,r_lrncourse.qtymth07,
                r_lrncourse.qtymth08,r_lrncourse.qtymth09,r_lrncourse.qtymth10,r_lrncourse.qtymth11,r_lrncourse.qtymth12,
                global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        update tlrnels
           set dtelast      = trunc(sysdate),
               qtyemp1      = r_lrncourse.qtymth01,
               qtyemp2      = r_lrncourse.qtymth02,
               qtyemp3      = r_lrncourse.qtymth03,
               qtyemp4      = r_lrncourse.qtymth04,
               qtyemp5      = r_lrncourse.qtymth05,
               qtyemp6      = r_lrncourse.qtymth06,
               qtyemp7      = r_lrncourse.qtymth07,
               qtyemp8      = r_lrncourse.qtymth08,
               qtyemp9      = r_lrncourse.qtymth09,
               qtyemp10     = r_lrncourse.qtymth10,
               qtyemp11     = r_lrncourse.qtymth11,
               qtyemp12     = r_lrncourse.qtymth12,
               coduser      = global_v_coduser
         where codcompy     = v_codcompy
           and dteyear      = v_curr_year;
      end;
    end loop;

    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    for r_tlrnels in c_tlrnels loop                        
      obj_data.put('qtyemp1',r_tlrnels.qtyemp1);            
      obj_data.put('qtyemp2',r_tlrnels.qtyemp2);
      obj_data.put('qtyemp3',r_tlrnels.qtyemp3);
      obj_data.put('qtyemp4',r_tlrnels.qtyemp4);
      obj_data.put('qtyemp5',r_tlrnels.qtyemp5);
      obj_data.put('qtyemp6',r_tlrnels.qtyemp6);
      obj_data.put('qtyemp7',r_tlrnels.qtyemp7);
      obj_data.put('qtyemp8',r_tlrnels.qtyemp8);
      obj_data.put('qtyemp9',r_tlrnels.qtyemp9);
      obj_data.put('qtyemp10',r_tlrnels.qtyemp10);
      obj_data.put('qtyemp11',r_tlrnels.qtyemp11);
      obj_data.put('qtyemp12',r_tlrnels.qtyemp12);
      obj_data.put('label1',get_tlistval_name('NAMMTHABB','1',global_v_lang));
      obj_data.put('label2',get_tlistval_name('NAMMTHABB','2',global_v_lang));
      obj_data.put('label3',get_tlistval_name('NAMMTHABB','3',global_v_lang));
      obj_data.put('label4',get_tlistval_name('NAMMTHABB','4',global_v_lang));
      obj_data.put('label5',get_tlistval_name('NAMMTHABB','5',global_v_lang));
      obj_data.put('label6',get_tlistval_name('NAMMTHABB','6',global_v_lang));
      obj_data.put('label7',get_tlistval_name('NAMMTHABB','7',global_v_lang));
      obj_data.put('label8',get_tlistval_name('NAMMTHABB','8',global_v_lang));
      obj_data.put('label9',get_tlistval_name('NAMMTHABB','9',global_v_lang));
      obj_data.put('label10',get_tlistval_name('NAMMTHABB','10',global_v_lang));
      obj_data.put('label11',get_tlistval_name('NAMMTHABB','11',global_v_lang));
      obj_data.put('label12',get_tlistval_name('NAMMTHABB','12',global_v_lang));
    end loop;

    commit;
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_graph_learning(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_graph_learning(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_calendar(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_curr_year     number := to_number(to_char(sysdate,'yyyy'));
    v_codcompy      tcompny.codcompy%type;
    v_dtestrt       date;
    v_dteend        date;

    cursor c1 is
      select a.dteyear,a.codcompy,a.dtetrst,a.dtetren,a.dteupd,
             decode(global_v_lang,'101',b.namcourse
                                 ,'102',b.namcourst
                                 ,'103',b.namcours3
                                 ,'104',b.namcours4
                                 ,'105',b.namcours5
                                 ,b.namcourst) as namcours,
             b.namcourse,b.namcourst,b.namcours3,b.namcours4,b.namcours5
        from tpotentp a, tcourse b
       where a.codcours   = b.codcours
         and a.codempid   = global_v_codempid
         and a.flgatend   = 'N'
         and a.staappr    = 'Y'
         and b.flgelern   = 'Y'
--         and (to_char(a.dtetrst,'mmyyyy') = b_index_dtemonth||b_index_dteyear
--           or to_char(a.dtetren,'mmyyyy') = b_index_dtemonth||b_index_dteyear)--TestCase
      order by dtetrst;

    cursor c_gen_date is
      select day as date_train
      from (select v_dtestrt - 1 + level day
              from dual
           connect by level <= v_dteend - v_dtestrt + 1);
  begin
    obj_row   := json_object_t();

    for i in c1 loop
      v_dtestrt   := i.dtetrst;
      v_dteend    := i.dtetren;
      for k in c_gen_date loop
        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codcompy',i.codcompy);
        obj_data.put('coduser','');
        obj_data.put('desholdy',i.namcours);
        obj_data.put('desholdye',i.namcourse);
        obj_data.put('desholdyt',i.namcourst);
        obj_data.put('desholdy3',i.namcours3);
        obj_data.put('desholdy4',i.namcours4);
        obj_data.put('desholdy5',i.namcours5);
        obj_data.put('dtedate',to_char(k.date_train,'dd/mm/yyyy'));
        obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy hh24:mi'));
        obj_data.put('dteyear',i.dteyear);
        obj_data.put('typwork','S'); --Hard S
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt  := v_rcnt + 1;
      end loop;
    end loop;

    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_calendar(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_calendar(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_open_el(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_row_course  json_object_t;
    obj_data_course json_object_t;
    v_rcnt          number := 0;
    v_rcnt_course   number := 0;
    v_curr_year     number := to_number(to_char(sysdate,'yyyy'));
    v_codcompy      tcompny.codcompy%type;
    v_codcate       tvcourse.codcate%type;

    cursor c1 is
      select distinct b.codcate
        from tcourse a, tvcourse b
       where a.codcours   = b.codcours
         and a.flgelern   = 'Y'
         and b.typcours   = 'O'
         and b.flgdashboard   = 'Y'
         and not exists (select 1
                           from tlrncourse c
                          where c.codempid    = global_v_codempid
                            and c.stalearn    = 'A'
                            and c.codcours    = a.codcours)
      order by codcate;

    cursor c2 is
      select b.codcours
        from tcourse a, tvcourse b
       where a.codcours   = b.codcours
         and a.flgelern   = 'Y'
         and b.typcours   = 'O'
         and b.flgdashboard   = 'Y'
         and b.codcate    = v_codcate
         and not exists (select 1
                           from tlrncourse c
                          where c.codempid    = global_v_codempid
                            and c.stalearn    = 'A'
                            and c.codcours    = a.codcours)
      order by codcours;

  begin
    obj_row   := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codcate',i.codcate);
      obj_data.put('desc_codcate',get_tcodec_name('TCODCATE',i.codcate,global_v_lang));
      v_codcate       := i.codcate;
      obj_row_course  := json_object_t();
      v_rcnt_course   := 0;
      for j in c2 loop
        obj_data_course   := json_object_t();
        obj_data_course.put('codcours',j.codcours);
        obj_data_course.put('desc_codcours',get_tcourse_name(j.codcours,global_v_lang));
        obj_row_course.put(to_char(v_rcnt_course),obj_data_course);
        v_rcnt_course := v_rcnt_course + 1;
      end loop;
      obj_data.put('course',obj_row_course);
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;

    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_open_el(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_open_el(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_course_study(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;

    v_codcompy      tcompny.codcompy%type;
--    v_dtetrst       tpotentp.dtetrst%type;
--    v_dtetren       tpotentp.dtetren%type;
    v_chaptno       tlrncourse.chaptno%type;
    v_codsubj       tlrncourse.codsubj%type;
    v_stalearn_chapter  tlrnchap.stalearn%type;
    v_stalearn_subject  tlrnsubj.stalearn%type;
    v_stalearn_course   tlrncourse.stalearn%type;

    cursor c1 is
      select decode(a.stalearn,null,c.dtetrst,a.dtecourst) as dtetrst,
             decode(a.stalearn,null,c.dtetren,a.dtegradtn) as dtetren,
             b.filemedia,b.codcours,a.dtecourst,a.dteyear,a.numclseq,
             nvl(a.pctprogress,0) as pctprogress,a.codsubj,a.chaptno,a.stalearn
        from tlrncourse a, tvcourse b, tpotentp c, tcourse d
       where a.codcours   = b.codcours
         and a.codempid   = global_v_codempid
         and a.stalearn   <> 'C'
         and a.codempid   = c.codempid(+)
--         and c.codcompy   = v_codcompy
         and a.codcours   = c.codcours(+)
         and a.dteyear    = c.dteyear(+)
         and a.numclseq   = c.numclseq(+)
         and c.flgatend(+) = 'N'
         and d.codcours   = a.codcours
         and d.flgelern   <> 'N'
         and trunc(sysdate) <= c.dtetren(+)
      union
      select a.dtetrst,a.dtetren,b.filemedia,b.codcours,null as dtecourst,a.dteyear,a.numclseq,
             0 as pctprogress,'' as codsubj,null as chaptno,'P' as stalearn
        from tpotentp a, tvcourse b, tcourse d
       where a.codcours   = b.codcours
         and a.codempid   = global_v_codempid
         and a.flgatend   = 'N'
         and a.staappr    = 'Y'
         and b.typcours   = 'Y'
         and b.codcours   = d.codcours
         and d.flgelern   <> 'N'
         and trunc(sysdate) <= a.dtetren
         and not exists (select 1
                           from tlrncourse c
                          where c.codempid    = a.codempid
                            and c.codcours    = a.codcours
                            and c.dteyear     = a.dteyear
                            and c.numclseq    = a.numclseq)
      order by dtetrst;

  begin
    obj_row     := json_object_t();
    v_codcompy  := hcm_util.get_codcomp_level(global_v_codcomp,1);
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('filemedia',i.filemedia);
      obj_data.put('codcours',i.codcours);
      obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
      obj_data.put('dtecourst',to_char(nvl(i.dtecourst,sysdate),'dd/mm/yyyy hh24:mi'));
      obj_data.put('dtetrst',to_char(i.dtetrst,'dd/mm/yyyy hh24:mi'));
      obj_data.put('dtetren',to_char(i.dtetren,'dd/mm/yyyy hh24:mi'));
      obj_data.put('progress',i.pctprogress||'%');

      if trunc(sysdate) between trunc(i.dtetrst) and nvl(i.dtetren,trunc(sysdate)) then
        obj_data.put('flgChecklearn', 'Y'); -- flgChecklearn: mockFlglearn[d - 1], // ไว้เช็คกรณียังไม่ถึงกำหนดเรียน Y = เปิดเข้าเรียนได้, N = ยังเข้าเรียนไม่ได้
      end if;

      v_chaptno           := i.chaptno;
      v_codsubj           := i.codsubj;
      v_stalearn_chapter  := null;
      v_stalearn_subject  := null;
      v_stalearn_course   := i.stalearn;

      if v_chaptno is not null then
        begin
          select stalearn
            into v_stalearn_subject
            from tlrnsubj
           where codempid     = global_v_codempid
             and dtecourst    = i.dtecourst
             and codcours     = i.codcours
             and codsubj      = i.codsubj;

          if v_stalearn_subject = 'C' then
            begin
              select min(tv.codsubj)
                into v_codsubj
                from tvsubject tv, tlrnsubj lrn
               where tv.codcours      = i.codcours
                 and tv.codcours      = lrn.codcours(+)
                 and tv.codsubj       = lrn.codsubj(+)
                 and lrn.codempid(+)  = global_v_codempid
                 and lrn.dtecourst(+) = i.dtecourst
                 and nvl(lrn.stalearn,'P') <> 'C';
            end;
            if v_codsubj is null then
              v_stalearn_course   := 'Y';
            else
              v_stalearn_subject  := 'A';
            end if;
          end if;
        exception when no_data_found then null;
        end;

        v_chaptno := i.chaptno;

        if v_stalearn_course <> 'Y' then
          begin
            select min(tv.chaptno)
              into v_chaptno
              from tvchapter tv, tlrnchap lrn
             where tv.codcours    = i.codcours
               and tv.codsubj     = v_codsubj
               and tv.codcours    = lrn.codcours(+)
               and tv.codsubj     = lrn.codsubj(+)
               and tv.chaptno     = lrn.chaptno(+)
               and lrn.codempid(+) = global_v_codempid
               and lrn.dtecourst(+) = i.dtecourst
               and nvl(lrn.stalearn,'P') <> 'C';
          end;
          if v_chaptno is null then
            v_stalearn_chapter  := 'C';
          else
            v_stalearn_chapter  := 'A';
          end if;
        end if;
      end if;

      obj_data.put('codsubj',v_codsubj);
      obj_data.put('desccodsubj',get_tsubject_name(v_codsubj,global_v_lang));
      obj_data.put('stalearn_subj',v_stalearn_subject);
      obj_data.put('chaptno',v_chaptno);
      obj_data.put('stalearn_chapt',v_stalearn_chapter);
      obj_data.put('dteyear',i.dteyear);
      obj_data.put('numclseq',i.numclseq);
      obj_data.put('stalearn',v_stalearn_course);
--      dtechapst: '', // param
--      flglearn: '' // param

      obj_row.put(to_char(v_rcnt),obj_data);

      v_rcnt  := v_rcnt + 1;
    end loop;

    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_course_study(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_course_study(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_learn_history(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;

    cursor c1 is
      select b.dtecourst,a.codcours,a.flgposttest,b.staposttest,
             b.dteyear,b.numclseq
        from tvcourse a,tlrncourse b
       where a.codcours   = b.codcours
         and b.codempid   = global_v_codempid
         and b.dtecourst  = (select max(dtecourst)
                              from tlrncourse c
                             where codempid   = global_v_codempid
                               and c.codcours = a.codcours)
         and b.stalearn   in ('C','Y')
      order by dtecourst desc;

  begin
    obj_row   := json_object_t();

    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('dtecourst',to_char(i.dtecourst,'dd/mm/yyyy hh24:mi'));
      obj_data.put('codcours',i.codcours);
      obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
      obj_data.put('flgposttest',i.flgposttest);

      if i.flgposttest = 'Y' then
        obj_data.put('staposttest', i.staposttest);
        if i.staposttest <> 'Y' and i.staposttest <> 'N' then 
          obj_data.put('staposttest', '');
        end if;
      else
        obj_data.put('staposttest','');
      end if;

      obj_data.put('dteyear',i.dteyear);
      obj_data.put('numclseq',i.numclseq);

      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;

    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_learn_history(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_learn_history(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_top_rank(json_str_output out clob) is
    obj_output        json_object_t;
    obj_data_header   json_object_t;
    obj_row_detail    json_object_t;
    obj_data_detail   json_object_t;
    v_rcnt            number := 0;
    v_sum_qtycount    number := 0;
--    v_curr_year       number := to_number(to_char(sysdate,'yyyy'));
    v_codcompy        tcompny.codcompy%type;

    cursor c1 is
      select a.codcours,c.filemedia,count(b.codempid) as qtycount
        from tlrncourse a,temploy1 b,tvcourse c
       where a.codempid   = b.codempid
         and a.codcours   = c.codcours
         and hcm_util.get_codcomp_level(b.codcomp,1) = v_codcompy
         and to_char(a.dtecourst,'yyyy') = b_index_dteyear
         and a.typcours   = 'O'
      group by a.codcours,c.filemedia
      order by qtycount desc,codcours;

  begin
    v_codcompy      := hcm_util.get_codcomp_level(global_v_codcomp,1);
    obj_output      := json_object_t();
    obj_output.put('coderror','200');
    obj_data_header   := json_object_t();
    obj_data_header.put('codcompy',v_codcompy);
    obj_data_header.put('desc_codcompy',get_tcompny_name(v_codcompy,global_v_lang));
    obj_data_header.put('dteyear',b_index_dteyear);

    obj_row_detail  := json_object_t();

    for i in c1 loop
      obj_data_detail    := json_object_t();
      obj_data_detail.put('coderror','200');
      obj_data_detail.put('codcours',i.codcours);
      obj_data_detail.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
      obj_data_detail.put('filemedia',i.filemedia);
      obj_data_detail.put('qtycount',i.qtycount);
      obj_row_detail.put(to_char(v_rcnt),obj_data_detail);
      v_rcnt  := v_rcnt + 1;
      v_sum_qtycount  := v_sum_qtycount + i.qtycount;

      if v_rcnt = 10 then
        exit;
      end if;
    end loop;

    obj_data_header.put('valuemax',v_sum_qtycount);
    obj_output.put('header',obj_data_header);
    obj_output.put('table',obj_row_detail);
    json_str_output   := obj_output.to_clob;
  end;
  --
  procedure get_top_rank(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_top_rank(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

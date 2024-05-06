--------------------------------------------------------
--  DDL for Package Body HREL43E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL43E" is

  procedure initial_value(json_str in varchar2) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    global_v_lang       := nvl(global_v_lang,'102');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempidQuery');

    p_codlogin          := hcm_util.get_string_t(json_obj,'p_codlogin');
    p_codpwd            := hcm_util.get_string_t(json_obj,'p_codpwd');

    p_codexam           := hcm_util.get_string_t(json_obj,'p_codexam');
    p_typeexam           := hcm_util.get_string_t(json_obj,'p_typeexam');

    p_codapp  := lower(hcm_util.get_string_t(json_obj,'p_codapp'));


    p_dteyear      := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_numclseq     := hcm_util.get_string_t(json_obj,'p_numclseq');
    p_codcours     := hcm_util.get_string_t(json_obj,'p_codcours');
    p_typtest      := hcm_util.get_string_t(json_obj,'p_typtest');
    p_codsubj      := hcm_util.get_string_t(json_obj,'p_codsubj');
    p_chaptno      := hcm_util.get_string_t(json_obj,'p_chaptno');
    p_dtetrain     := to_date(hcm_util.get_string_t(json_obj,'p_dtetrain'),'dd/mm/yyyy hh24:mi');
    p_dtetest      := to_date(hcm_util.get_string_t(json_obj,'p_dtetest'),'dd/mm/yyyy');
    p_namtest      := hcm_util.get_string_t(json_obj,'p_namtest');
    p_codpswd      := hcm_util.get_string_t(json_obj,'p_codpswd');
    p_dtetestst    := to_date(hcm_util.get_string_t(json_obj,'p_dtetestst'),'dd/mm/yyyy');
    p_numappl      := hcm_util.get_string_t(json_obj,'p_numappl');
    p_numreql      := hcm_util.get_string_t(json_obj,'p_numreql');
    p_codcompl     := hcm_util.get_string_t(json_obj,'p_codcompl');
    p_codposl      := hcm_util.get_string_t(json_obj,'p_codposl');
    p_flglogin     := hcm_util.get_string_t(json_obj,'p_flglogin');
    p_flgtest      := hcm_util.get_string_t(json_obj,'p_flgtest');
    p_typetest     := hcm_util.get_string_t(json_obj,'p_typetest');
    p_codcomp      := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codpos       := hcm_util.get_string_t(json_obj,'p_codpos');
    p_dtecourst    := to_date(hcm_util.get_string_t(json_obj,'p_dtecourst'),'dd/mm/yyyy hh24:mi');
    p_numapseq     := hcm_util.get_string_t(json_obj,'p_numapseq');
    p_codposrq     := hcm_util.get_string_t(json_obj,'p_codposrq');
    p_numreqrq     := hcm_util.get_string_t(json_obj,'p_numreqrq');
    p_codquest     := hcm_util.get_string_t(json_obj,'p_codquest');

   hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_count_comp  number := 0;
    v_secur       boolean := false;
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
      return;
    else
      begin
            select count(*) into v_count_comp
            from tcenter
            where codcomp like p_codcomp || '%' ;
        exception when others then null;
        end;
        if v_count_comp < 1 then
             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
             return;
        end if;
         v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
          if not v_secur then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
          end if;
    end if;

  end;

  procedure gen_index_emp(json_str_output out clob) is
    obj_data            json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_codpos            temploy1.codpos%type;
    v_codcomp           temploy1.codcomp%type;
    v_staemp            temploy1.staemp%type;
    v_flggrade          varchar2(2 char);

    begin
        begin
          select codpos,codcomp,staemp
           into v_codpos,v_codcomp,v_staemp
            from temploy1
           where codempid  = p_codempid;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang);
        end;

        if param_msg_error is null then
           if v_staemp = 9 then
              param_msg_error := get_error_msg_php('HR2101', global_v_lang);
           elsif v_staemp = 0 then
              param_msg_error := get_error_msg_php('HR2102', global_v_lang);
           else
             obj_data := json_object_t();
             obj_data.put('coderror','200');
             obj_data.put('codpos',v_codpos);
             obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
             obj_data.put('codcomp',v_codcomp);
             obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
           end if;
        end if;

        if param_msg_error is null then
           json_str_output := obj_data.to_clob;
          return;
        else
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
        end if;

  end gen_index_emp;

  procedure get_index_emp (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_index_emp(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_namexame          tvtest.namexame%type;
    v_codexam           tvtest.codexam%type;
    v_codcatexm         tvtest.codcatexm%type;
    v_qtyscore          tvtest.qtyscore%type;
    v_qtyexammin        tvtest.qtyexammin%type;
    v_desc_qtyexammin   tvtest.qtyexammin%type;
    v_qtyalrtmin        tvtest.qtyalrtmin%type;
    v_qtyexam           tvtest.qtyexam%type;
    v_desexam           tvtest.desexam%type;

    v_staresult         tvcourse.staresult%type;

    v_flgtest_tr        varchar2(2 char);
    v_dtecreate         ttestemp.dtecreate%type;
    v_flgtimeout        varchar2(2 char) := 'N';
    v_flgtest2          varchar2(2 char) := 'N';
    v_flgtest          varchar2(2 char) := 'N';
    v_statest            varchar2(2 char) := 'N';
    cursor c1 is
        select codexam,decode(global_v_lang,'101',namsubje,
                                  '102',namsubj2,
                                  '103',namsubj3,
                                  '104',namsubj4,
                                  '105',namsubj5) as namsubje ,codquest,
              qtyscore,typeexam,qtyexam

            from tvquest
          where codexam = p_codexam;
    begin

          obj_row := json_object_t();

          for r1 in c1 loop
             v_count := v_count +1;
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('numseq',v_count);
              obj_data.put('iddesexam',v_count || '. ' ||r1.namsubje);
              obj_row.put(to_char(v_row), obj_data);
              v_row        := v_row + 1;
          end loop;

          begin
            select codexam,decode(global_v_lang,'101',namexame,
                                  '102',namexam2,
                                  '103',namexam3,
                                  '104',namexam4,
                                  '105',namexam5) as namexame ,codcatexm,
              qtyscore,qtyexammin,qtyexam,desexam,qtyalrtmin
              into v_codexam,v_namexame,v_codcatexm,v_qtyscore,v_qtyexammin,v_qtyexam,v_desexam,v_qtyalrtmin
            from tvtest
          where codexam = p_codexam;
          exception when no_data_found then
          null;
          end;
--          v_desc_qtyexammin := v_qtyexammin;
          v_desc_qtyexammin := v_qtyexammin * 60;
          begin
            select 'Y',dtecreate into v_flgtest_tr,v_dtecreate
            from ttestemp
            where codempid = p_codempid
              and codexam = p_codexam
              and dtetest = p_dtetest
              and typtest = p_typtest
              and typetest = p_typetest;
          exception when no_data_found then
            v_flgtest_tr := 'N';
            v_dtecreate := null;
          end;

          begin
            select staresult
              into v_staresult
              from tvcourse
             where codcours = p_codcours;
          exception when no_data_found then null;
          end;

--          if p_codcours is not null and p_codsubj is null and p_chaptno is null then
--            begin
--              select 'Y'
--                into v_flgtest_tr
--                from tlrncourse
--               where codempid       = p_codempid
--                 and codcours       = p_codcours
--                 and dtecourst      = p_dtecourst
--                 and (flgpreansfull  = 'N' or flgpostansfull = 'N' or
--                      (v_staresult = 'Y' and staposttest = 'N'));
--            exception when no_data_found then
--              v_flgtest_tr  := 'N';
--            end;
--          end if;

          if  p_codapp in ('hrel21e','hrel22e','hrel23e') then
              begin
                select statest,flgtest,dtecreate into v_statest,v_flgtest,v_dtecreate
                from ttestemp
                where codempid = p_codempid
                  and codexam = p_codexam
                  and dtetest = p_dtetest
                  and typtest = p_typtest
                  and typetest = p_typetest;
              exception when no_data_found then
                v_flgtest_tr := 'N';
                v_dtecreate := null;
              end;
              if v_statest = 'N' and v_flgtest = 'G' then
                  v_flgtest_tr := 'N';
              end if;

          end if;

          if v_flgtest_tr = 'Y' then
             v_qtyexammin := floor((sysdate - to_date(v_dtecreate,'yyyy-mm-dd hh24:mi:ss'))*60*24*60);
             v_qtyexammin := v_desc_qtyexammin - v_qtyexammin;
            if v_qtyexammin < 0 then
              v_qtyexammin := 0;
            end if;
          else 
            v_qtyexammin := v_qtyexammin * 60;
          end if;

        if v_flgtest_tr = 'Y' then
             begin
                select flgtest into v_flgtest2
                from ttestemp
                where codempid = p_codempid
                and codexam = p_codexam
                and dtetest = p_dtetest
                and typtest = p_typtest
                and typetest = p_typetest;
             exception when no_data_found then
              null;
             end;

            if v_flgtest2 = 'C' or v_flgtest2 = 'G' then
               v_qtyexammin := 0;
            end if;
          end if;

          if v_qtyexammin = 0 then
            v_flgtimeout := 'Y';
          end if;

          v_desc_qtyexammin := v_desc_qtyexammin / 60;
          v_qtyexammin := v_qtyexammin ;
          v_qtyalrtmin := v_qtyalrtmin * 60;

          obj_result := json_object_t();
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codexam', v_codexam);
          obj_data.put('namexame', v_namexame);
          obj_data.put('codcatexm', v_codcatexm);
          obj_data.put('qtyscore', v_qtyscore);
          obj_data.put('qtyexammin', v_qtyexammin);
          obj_data.put('qtyalrtmin', v_qtyalrtmin);
          obj_data.put('desc_qtyexammin', v_desc_qtyexammin);
          obj_data.put('flgtimeout', v_flgtimeout);
          obj_data.put('qtyexam', v_qtyexam);
          obj_data.put('desexam', v_desexam);
          obj_data.put('codempid', p_codempid);

          obj_result.put('coderror', '200');
          obj_result.put('detail', obj_data);
          obj_result.put('table', obj_row);

          json_str_output := obj_result.to_clob;

  end gen_index;

  procedure get_index (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail(json_str_output out clob) is
   v_lrn_statest       varchar2(1);
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_namexame          tvtest.namexame%type;
    v_codexam           tvtest.codexam%type;
    v_codcatexm         tvtest.codcatexm%type;
    v_qtyexammin        tvtest.qtyexammin%type;
    v_qtyexam           tvtest.qtyexam%type;
    v_desexam           tvtest.desexam%type;
    v_codquest          ttestempd.codquest%type;
    v_qtyans            number := 0;
    v_flgtest_tr        varchar2(2 char);
    v_flgtest           varchar2(2 char);
    v_flgtest2          varchar2(2 char);
    v_flg_subjective    varchar2(2 char):='N';
    v_statest           varchar2(100 char):='';
    v_typtest           ttestemp.typtest%type;
    v_statest2          ttestemp.statest%type;

    v_total_answer      number := 0;
    v_flg_ansfull       varchar2(2 char):='N';

    v_total_qtyscore    tvquestd1.qtyscore%type := 0;
    v_score             tvquestd1.qtyscore%type;
    v_qtyscore          tvquestd1.qtyscore%type;
    v_result_score      tvquestd1.qtyscore%type;
    v_qtyscrpass        tvtest.qtyscrpass%type;
    v_codasapl          tappoinf.codasapl%type;

    el_codempid         tpotentp.codempid%type;
    el_dteyear          tpotentp.dteyear%type;
--    el_dtemonth         tpotentp.dtemonth%type;
    el_codcours         tpotentp.codcours%type;
    el_numclseq         tpotentp.numclseq%type;
    el_codpos           tpotentp.codpos%type;
    el_codcomp          tpotentp.codcomp%type;
    el_codtparg         tpotentp.codtparg%type;
    el_codhotel	        tyrtrsch.codhotel%type;
    el_codinsts	        tyrtrsch.codinsts%type;
    el_codinst	        tyrtrsch.codinst%type;
    el_dtetrst	        tyrtrsch.dtetrst%type;
    el_dtetren	        tyrtrsch.dtetren%type;
    el_timestr	        tyrtrsch.timestr%type;
    el_timeend	        tyrtrsch.timeend%type;
    el_qtytrmin	        tyrtrsch.qtytrmin%type;
    el_amtcost	        tyrtrsch.amttremp%type;
    el_dtetrflw	        tyrtrsch.timeend%type;
    el_qtytrpln	        tyrtrsch.qtytrmin%type;
    el_namfirste	      tinstruc.namfirste%type;
    el_namfirstt	      tinstruc.namfirste%type;
    el_namfirst3	      tinstruc.namfirste%type;
    el_namfirst4	      tinstruc.namfirste%type;
    el_namfirst5	      tinstruc.namfirste%type;
    el_qtytrflw	        tcourse.qtytrflw%type;
    el_flgcommt	        tcourse.flgcommt%type;
    el_descommt	        tcourse.descommt%type;
    el_descommtn	      tcourse.descommt2%type;
    el_qtyprescr	      thistrnn.qtyprescr%type;
    el_qtyposscr	      thistrnn.qtyposscr%type;

--    el_codplan          thisclss.codplan%type;
--    el_codrespn         thisclss.codrespn%type;
    el_typtrain         thisclss.typtrain%type;
--    el_flgupdcmp        thisclss.flgupdcmp%type;
--    el_desbenefit       thisclss.desbenefit%type;
--    el_descomment       thisclss.descomment%type;
--    el_dessummary       thisclss.dessummary%type;
--    el_destrfu1         thisclss.objective%type;
--    el_codcate	        tcourse.codcate%type;
    v_staresult	        tvcourse.staresult%type;
--    el_codcrte          tpotentp.codappr%type;
--    el_dteexam1	        thistrnn.dteexam1%type;
--    el_dteexam2	        thistrnn.dteexam2%type;
--    el_codexam	        thistrnn.codexam%type;
--    el_codexam2	        thistrnn.codexam2%type;

    v_flganswer         varchar2(1 char) := 'N';
    v_retest            varchar2(10) := 'N';
    pr_codexam          ttestemp.codexam%type; 
    pr_dtetest          ttestemp.dtetest%type; 
    pr_qtyscore         ttestemp.qtyscore%type;
    pr_score            ttestemp.score%type; 
    po_codexam          ttestemp.codexam%type; 
    po_dtetest          ttestemp.dtetest%type; 
    po_qtyscore         ttestemp.qtyscore%type;
    po_score            ttestemp.score%type; 
    v_timexam           ttestemp.timexam%type; 
    el_statest          ttestemp.statest%type;
    el_flgtest          ttestemp.flgtest%type;

    v_codcours	        tvcourse.codcours%type;

    cursor c1 is
        select codexam,decode(global_v_lang,'101',namsubje,
                                  '102',namsubj2,
                                  '103',namsubj3,
                                  '104',namsubj4,
                                  '105',namsubj5) as namsubje ,codquest,
              qtyscore,typeexam,qtyexam

            from tvquest
          where codexam = p_codexam;

    cursor c2 is
        select a.answer,a.numans ,a.codquest,b.typeexam,a.numques
        from  ttestempd a, tvquest b
        where a.codempid = p_codempid
           and a.codexam = p_codexam
           and a.codquest = v_codquest
          and a.dtetest  = p_dtetest
          and a.codexam = b.codexam
          and a.codquest = b.codquest
          and (a.numans is not null or  a.answer is not null)
          and typtest = p_typtest
          and typetest = p_typetest;

    cursor c3 is
        select sum(score) sum_score
        from  ttestempd a, tvquest b
        where a.codempid = p_codempid
           and a.codexam = p_codexam
           and a.codquest = v_codquest
          and a.dtetest  = p_dtetest
          and a.codexam = b.codexam
          and a.codquest = b.codquest
          and (a.numans is not null or  a.answer is not null)
          and typtest = p_typtest
          and typetest = p_typetest
          group by a.codquest;

    begin

/*      begin
        select flgshwans, staresult
        into v_flganswer, v_staresult
        from tvcourse
        where codcours = p_codcours;
      exception when no_data_found then
        v_flganswer := 'N';
      end;*/

      if p_flg_send_exam <> 'Y' then  
          if  p_codapp in ('hrel21e','hrel22e','hrel23e') then
              begin
                select statest,flgtest into v_statest,v_flgtest
                from ttestemp
                where codempid = p_codempid
                  and codexam = p_codexam
                  and dtetest = p_dtetest
                  and typtest = p_typtest
                  and typetest = p_typetest;
              exception when no_data_found then
                v_flgtest_tr := 'N';
              end;
              if v_statest = 'N' and v_flgtest = 'G' then
                  v_flgtest_tr := 'Y';


                  begin
                    delete from ttestempd
                    where codempid = p_codempid
                      and codexam = p_codexam
                      and dtetest = p_dtetest
                      and typtest = p_typtest
                      and typetest = p_typetest;
                  exception when others then
                    null;
                  end;
                  commit;
              end if;

          end if;
        end if;

        obj_result := json_object_t;
        obj_row := json_object_t();
        v_result_score := 0;
        for r1 in c1 loop
            v_count := v_count +1;
            v_flgtest := 'T';

              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('numseq',v_count);
              obj_data.put('namsubje',r1.namsubje);
              obj_data.put('typeexam',r1.typeexam);
              obj_data.put('desc_typeexam',get_tlistval_name('TYPEEXAM2',r1.typeexam,global_v_lang));
              obj_data.put('qtyscore',r1.qtyscore);
              obj_data.put('qtyexam',r1.qtyexam);
              obj_data.put('flganswer','N');
              v_qtyans := 0;
              begin
                  select count(*) into v_qtyans
                  from ttestempd
                  where codempid = p_codempid
                  and codexam = p_codexam
                  and dtetest = p_dtetest
                  and codquest = r1.codquest
                  and (numans is not null or answer is not null)
                  and typtest = p_typtest
                  and typetest = p_typetest;
              exception when no_data_found then
                v_qtyans := 0;
              end;

--              begin
--                  select flgtest,typtest,statest 
--                  into v_flgtest2,v_typtest,v_statest2
--                  from ttestemp
--                  where codempid = p_codempid
--                  and codexam = p_codexam
--                  and dtetest = p_dtetest
--                  and typtest = p_typtest
--                  and typetest = p_typetest;
--              exception when no_data_found then
--                null;
--              end;
--             
--              if v_flgtest2 = 'C' or v_flgtest2 = 'G' then
--                 v_flgtest := 'Y';
--                 
--                 if r1.typeexam <> 4 then
--                  obj_data.put('flganswer',v_flganswer);
--                  else
--                  obj_data.put('flganswer','N');
--                  end if;
--              else
--                if v_qtyans > 0  then
--                  v_flgtest := 'P';
--                end if;
--              end if;
--
--              v_total_answer := v_total_answer + v_qtyans;
--              
--              
--              obj_data.put('flgtest',v_flgtest);
--              obj_data.put('qtyans',v_qtyans);
--              obj_data.put('codquest',r1.codquest);
--              if v_typtest = '1' then
--                obj_data.put('descTyptest',get_tlistval_name('TYPTEST','1',global_v_lang));
--              else
--                obj_data.put('descTyptest',get_tlistval_name('TYPTEST','2',global_v_lang));
--              end if;
--              obj_data.put('desc_codempid',p_namtest);
--              obj_data.put('statest',get_tlistval_name('STATEST', v_statest2, global_v_lang));
              v_codquest := r1.codquest;

              if p_flg_send_exam = 'Y' then -- send exam
                v_total_qtyscore := 0;
                for r2 in c2 loop
                v_score := '';
                v_qtyscore :=0;
                  if r2.typeexam = 1 or r2.typeexam = 2 then

                      begin
                        select qtyscore into v_score
                        from  tvquestd1
                        where codexam = p_codexam
                        and codquest = r1.codquest
                        and numques = r2.numques
                        and numans = r2.numans;
                      exception when no_data_found then
                        v_score :=0;
                       end;
                    elsif r2.typeexam = 3 then
                        begin
                          select score into v_score
                          from  tvquestd2
                          where codexam = p_codexam
                          and codquest = r1.codquest
                          and numques = r2.numques
                          and numans = r2.numans;
                        exception when no_data_found then
                          v_score :=0;
                         end;
                    elsif r2.typeexam = 4 then
                            v_score := null;
                    end if;

                      begin
                        select qtyscore into v_qtyscore
                        from  tvquestd1
                        where codexam = p_codexam
                        and codquest = r1.codquest
                        and numques = r2.numques;
                      exception when no_data_found then
                        v_qtyscore :=0;
                       end;

                    begin
                        update ttestempd
                        set qtyscore = v_qtyscore,
                               score = v_score
                        where codempid = p_codempid
                        and  codexam = p_codexam
                        and  dtetest = p_dtetest
                        and  codquest = r1.codquest
                        and  numques = r2.numques
                        and typtest = p_typtest
                        and typetest = p_typetest;
                    exception when others then
                      null;
                    end;

                    v_total_qtyscore := v_total_qtyscore + v_score;
                end loop;

                if r1.typeexam <> 4 then
                  obj_data.put('score',v_total_qtyscore);
                  v_result_score   := v_result_score + v_total_qtyscore;
                  obj_data.put('flganswer',v_flganswer);
                else
                  v_flg_subjective := 'Y';
                  obj_data.put('score', get_label_name('HREL51EC2',global_v_lang,210));
                  obj_data.put('flganswer','N');
                end if;

                begin
                  select qtyscrpass,qtyscore,qtyexam into v_qtyscrpass,v_qtyscore,v_qtyexam
                  from  tvtest
                  where codexam = p_codexam;
                exception when no_data_found then
                  v_qtyscrpass :=0;
                 end;

                 if v_result_score >= v_qtyscrpass then
                    v_statest := 'Y';
                    v_lrn_statest := 'Y';
                 else
                    v_statest := 'N';
                    v_lrn_statest := 'N';
                 end if;
                 if v_flg_subjective = 'Y' then
                   v_flgtest := 'C';
                   v_statest := '';
                 else
                   v_flgtest := 'G';
                 end if;
                 begin
                    update ttestemp
                    set flgtest = v_flgtest,
                        qtyscore = v_qtyscore,
                        score = v_result_score,
                        statest = v_statest,
                        coduser = global_v_coduser
                  where codempid = p_codempid
                    and codexam = p_codexam
                    and dtetest = p_dtetest
                    and typtest = p_typtest
                    and typetest = p_typetest;
                  exception when others then
                  param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                  null;
                end;
              else -- check score when complete
                if v_flgtest = 'Y' then

                    v_total_qtyscore := 0;
                    for r2 in c2 loop
                    v_score := '';
                    v_qtyscore :=0;
                      if r2.typeexam = 1 or r2.typeexam = 2 then

                          begin
                            select qtyscore into v_score
                            from  tvquestd1
                            where codexam = p_codexam
                            and codquest = r1.codquest
                            and numques = r2.numques
                            and numans = r2.numans;
                          exception when no_data_found then
                            v_score :=0;
                           end;
                        elsif r2.typeexam = 3 then
                            begin
                              select score into v_score
                              from  tvquestd2
                              where codexam = p_codexam
                              and codquest = r1.codquest
                              and numques = r2.numques
                              and numans = r2.numans;
                            exception when no_data_found then
                              v_score :=0;
                             end;
                        elsif r2.typeexam = 4 then
                            v_score := null;
                        end if;

                          begin
                            select qtyscore into v_qtyscore
                            from  tvquestd1
                            where codexam = p_codexam
                            and codquest = r1.codquest
                            and numques = r2.numques;
                          exception when no_data_found then
                            v_qtyscore :=0;
                           end;

                        begin
                            update ttestempd
                            set qtyscore = v_qtyscore,
                                   score = v_score
                            where codempid = p_codempid
                            and  codexam = p_codexam
                            and  dtetest = p_dtetest
                            and  codquest = r1.codquest
                            and  numques = r2.numques
                            and typtest = p_typtest
                            and typetest = p_typetest;
                        exception when others then
                          null;
                        end;

                        v_total_qtyscore := v_total_qtyscore + v_score;
                    end loop;

                    if r1.typeexam <> 4 then
                      obj_data.put('score',v_total_qtyscore);
                      v_result_score   := v_result_score + v_total_qtyscore;
                      obj_data.put('flganswer',v_flganswer);
                    else
                      v_flg_subjective := 'Y';
                      obj_data.put('score', get_label_name('HREL51EC2',global_v_lang,210));
                      obj_data.put('flganswer','N');
                    end if; 
                    begin
                      select qtyscrpass,qtyscore,qtyexam into v_qtyscrpass,v_qtyscore,v_qtyexam
                      from  tvtest
                      where codexam = p_codexam;
                    exception when no_data_found then
                      v_qtyscrpass :=0;
                     end;
                     if v_result_score >= v_qtyscrpass then
                        v_statest := 'Y';
                        v_lrn_statest := 'Y';
                     else
                        v_statest := 'N';
                        v_lrn_statest := 'N';
                     end if;
                end if;


              end if;  -- end send exam

              if v_flgtest_tr = 'N' then
                  begin
                      select flgtest,typtest,statest 
                      into v_flgtest2,v_typtest,v_statest2
                      from ttestemp
                      where codempid = p_codempid
                      and codexam = p_codexam
                      and dtetest = p_dtetest
                      and typtest = p_typtest
                      and typetest = p_typetest;
                  exception when no_data_found then
                    null;
                  end;
              end if;

              if v_flgtest2 = 'C' or v_flgtest2 = 'G' then
                 v_flgtest := 'Y';

                 if r1.typeexam <> 4 then
                  obj_data.put('flganswer',v_flganswer);
                  else
                  obj_data.put('flganswer','N');
                  end if;
              else
                if v_qtyans > 0  then
                  v_flgtest := 'P';
                end if;
              end if;

              v_total_answer := v_total_answer + v_qtyans;

              if v_flgtest_tr = 'Y' then
                 v_flgtest := 'T';
              end if;
              if p_flg_send_exam = 'Y' then
                 v_flgtest := 'Y';
              end if;

              obj_data.put('flgtest',v_flgtest);
              obj_data.put('qtyans',v_qtyans);
              obj_data.put('codquest',r1.codquest);
              if v_typtest = '1' then
                obj_data.put('descTyptest',get_tlistval_name('TYPTEST','1',global_v_lang));
              else
                obj_data.put('descTyptest',get_tlistval_name('TYPTEST','2',global_v_lang));
              end if;
              obj_data.put('desc_codempid',p_namtest);
              obj_data.put('statest',get_tlistval_name('STATEST', v_statest2, global_v_lang));
              if p_flg_send_exam = 'Y' then
                if v_flg_subjective <> 'Y' then
                    for r3 in c3 loop
                      obj_data.put('score',r3.sum_score);
                    end loop;
                end if;
              end if;
              obj_row.put(to_char(v_row), obj_data);
              v_row        := v_row + 1;
          end loop;

          if v_flg_subjective = 'Y' then
             v_statest := '';
             v_lrn_statest  := 'W';
          end if;

         if p_flg_send_exam = 'Y' then -- send exam
             if v_flg_subjective = 'Y' then
               v_flgtest := 'C';
             else
               v_flgtest := 'G';
             end if;

--            begin
--                update ttestemp
--                set flgtest = v_flgtest,
--                    qtyscore = v_qtyscore,
--                    score = v_result_score,
--                    statest = v_statest,
--                    coduser = global_v_coduser
--              where codempid = p_codempid
--                and codexam = p_codexam
--                and dtetest = p_dtetest
--                and typtest = p_typtest
--                and typetest = p_typetest;
--              exception when others then
--              param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--              null;
--            end;
            if v_flg_subjective = 'Y' then
              v_statest := 'C';
               v_lrn_statest  := 'W';
            end if;
            if v_total_answer = v_qtyexam then
              v_flg_ansfull := 'Y';
            end if;

            if p_codapp = 'hrel21e' then
               if p_typetest = '1' then
                  begin
                      update tlrncourse
                        set stapreteset =  v_lrn_statest,
                            qtyprescr   =  v_result_score,
--                            flgpreansfull = v_flg_ansfull,
                            coduser     = global_v_coduser
                       where codempid   = p_codempid
                         and codcours   = p_codcours
                         and dtecourst  = p_dtecourst ;
                  exception when others then
                    null;
                  end;
               elsif p_typetest = '2' then
                   begin
                      update tlrncourse
                        set staposttest =  v_lrn_statest,
                            qtyposscr   =  v_result_score,
--                          flgpostansfull = v_flg_ansfull,
                                coduser = global_v_coduser
                      where codempid = p_codempid
                         and codcours  = p_codcours
                         and dtecourst  = p_dtecourst ;
                    exception when others then
                    null;
                  end;
               end if;
            elsif p_codapp = 'hrel22e' then
                  begin
                      update tlrnsubj
                        set staexam =  v_lrn_statest,
                            score   =  v_result_score,
                           coduser  = global_v_coduser
                      where codempid = p_codempid
                         and codcours  = p_codcours
                         and dtecourst  = p_dtecourst
                         and codsubj  = p_codsubj ;
                    exception when others then
                    null;
                  end;
            elsif p_codapp = 'hrel23e' then
                  begin
                      update tlrnchap
                        set staexam =  v_lrn_statest,
                            score   =  v_result_score,
                            coduser = global_v_coduser
                      where codempid = p_codempid
                         and codcours  = p_codcours
                         and dtecourst  = p_dtecourst
                         and codsubj  = p_codsubj
                         and chaptno  = p_chaptno ;
                    exception when others then
                    null;
                  end;
            end if;

            if v_flgtest = 'G' then
                if v_statest = 'Y' then
                   v_codasapl := 'P';
                elsif v_statest = 'N' then
                   v_codasapl := 'F';
                end if;
               if p_codapp = 'hrel42e' then
                  begin

                      update tappoinf
                        set qtyfscore =  v_qtyscore,
--                            numgrd   =  v_result_score,
                            codasapl   =  v_codasapl,
                            stapphinv   =  'C',
                            coduser = global_v_coduser
                      where numappl = p_numappl
                         and numreqrq  = p_numreqrq
                         and codposrq  = p_codposrq
                         and numapseq  = p_numapseq;
                    exception when others then
                    null;
                  end;
               elsif p_codapp = 'hrel41e' then

                     if p_typtest = '2' then
                        begin
                          select codexam,dtetest,qtyscore,score
                          into pr_codexam,pr_dtetest,pr_qtyscore,pr_score
                          from ttestemp
                          where codempid = p_codempid
                          and codexam = p_codexam
                          and dtetest = p_dtetest
                          and typtest = '2'
                          and typetest = '1' ;
                        exception when no_data_found then
                          pr_codexam := null;
                          pr_dtetest := null;
                          pr_qtyscore := null;
                          pr_score := null;
                        end;
                        begin
                          select codexam,dtetest,qtyscore,score
                          into po_codexam,po_dtetest,po_qtyscore,po_score
                          from ttestemp
                          where codempid = p_codempid
                          and codexam = p_codexam
                          and dtetest = p_dtetest
                          and typtest = '2'
                          and typetest = '2' ;
                        exception when no_data_found then
                          po_codexam := null;
                          po_dtetest := null;
                          po_qtyscore := null;
                          po_score := null;
                        end;

                        begin
                            select qtytrflw,flgcommt,descommt,descommt2
                            into el_qtytrflw,el_flgcommt,el_descommt,el_descommtn
                            from tcourse
                            where codcours = p_codcours;
                         exception when no_data_found then
                            el_qtytrflw := null;
                            el_flgcommt := null;
                            el_descommt := null;
                            el_descommtn := null;
                         end;

                         begin
                            insert into thistrnn(codempid,dteyear,codcours,numclseq,codpos,codcomp,codtparg,
                                        qtyprescr,qtyposscr,remarks,codhotel,codinsts,codinst,
                                        naminse,naminst,namins3,namins4,namins5,
                                        dtetrst,dtetren,timestr,timeend,qtytrmin,amtcost,
                                        numcert,dtecert,typtrain,descomptr,
                                        qtytrflw,dtetrflw,flgcommt,dtecomexp,
                                        descommt,descommtn,content,flgtrain,desfollow,
                                        dtecrte,dtecntr,qtytrpln,pcttr,flgtrevl
                            )

                            values(el_codempid,el_dteyear,el_codcours,el_numclseq,el_codpos,el_codcomp,el_codtparg,
                                    el_qtyprescr,el_qtyposscr,null,el_codhotel,el_codinsts,el_codinst,
                                    el_namfirste,el_namfirstt,el_namfirst3,el_namfirst4,el_namfirst5,
                                    el_dtetrst,el_dtetren,el_timestr,el_timeend,el_qtytrmin,el_amtcost,
                                    null,null,el_typtrain,null,
                                    el_qtytrflw,el_dtetrflw,el_flgcommt,null,
                                    el_descommt,el_descommtn,null,null,null,
                                    null,null,el_qtytrpln,null,v_codasapl
                            );
                         exception when dup_val_on_index then
                          update thistrnn
                          set codpos     = el_codpos,
                              codcomp    = el_codcomp,
                              codtparg   = el_codtparg,
                              qtyprescr  = el_qtyprescr,
                              qtyposscr  = el_qtyposscr,
                              remarks    = null,
                              codhotel   = el_codhotel,
                              codinsts   = el_codinsts,
                              codinst    = el_codinst,
                              naminse    = el_namfirste,
                              naminst    = el_namfirstt,
                              namins3    = el_namfirst3,
                              namins4    = el_namfirst4,
                              namins5    = el_namfirst5,
                              dtetrst    = el_dtetrst,
                              dtetren    = el_dtetren,
                              timestr    = el_timestr,
                              timeend    = el_timeend,
                              qtytrmin   = el_qtytrmin,
                              amtcost    = el_amtcost,
                              numcert    = null,
                              dtecert    = null,
                              typtrain   = el_typtrain,
                              descomptr  = null,
                              qtytrflw   = el_qtytrflw,
                              dtetrflw   = el_dtetrflw,
                              flgcommt   = el_flgcommt,
                              dtecomexp  = null,
                              descommt   = el_descommt,
                              descommtn  = el_descommtn,
                              content    = null,
                              flgtrain   = null,
                              desfollow  = null,
                              dtecrte    = null,
                              dtecntr    = null,
                              qtytrpln   = el_qtytrpln,
                              pcttr      = null,
                              flgtrevl   = v_codasapl
                              where codempid = el_codempid
                              and dteyear = el_dteyear
                              and codcours = el_codcours
                              and numclseq = el_numclseq;
                         end;

                     end if;
               end if;
            end if;

         end if;  -- end send exam

         if v_flgtest = 'T' then
           v_flgtest := '';
         end if;

         if v_flgtest_tr = 'Y' then
             v_flgtest := '';
             v_statest := '';
         end if;
          obj_data := json_object_t();
          obj_data.put('statest',v_statest);
          obj_data.put('flgtest',v_flgtest);
          obj_data.put('flganswer',v_flganswer);

          obj_result.put('coderror', '200');
          obj_result.put('detail', obj_data);
          obj_result.put('table', obj_row);
          json_str_output := obj_result.to_clob;

         if p_flg_send_exam <> 'Y' then

              if p_codcomp is null then
                begin
                  select codcomp,codpos
                  into p_codcomp,p_codpos
                  from temploy1
                  where codempid = p_codempid;
                exception when no_data_found then
                  p_codcomp := null;
                  p_codpos := null;
                end;
              end if;

              begin
                select (timexam+1),flgtest,statest
                  into v_timexam,el_flgtest,el_statest
                  from ttestemp
                 where codempid = p_codempid
                   and codexam = p_codexam
                   and dtetest = p_dtetest
                   and typtest = p_typtest
                   and typetest = p_typetest;
               exception when no_data_found then
                 v_timexam := 1;
                 el_flgtest := null;
                 el_statest := null;
               end;
               begin
                select codempidc
                  into p_codempidc
                  from ttestchk
                 where codcomp = p_codcomp
                   and codexam = p_codexam
                   and numseq = (select min(numseq)
                                   from ttestchk
                                  where codcomp = p_codcomp
                                    and codexam = p_codexam);
              exception when no_data_found then
                 p_codempidc := '';
               end;
            if el_flgtest is null then
                begin
                    insert into ttestemp(codempid,codexam,dtetest,typtest,typetest,dteyear,numclseq,codcours,codsubj,chaptno,
                                        dtetrain,namtest,codpswd,dtetestst,numappl,numreql,
                                        codcompl,codposl,flglogin,flgtest,codcomp,codpos,codcreate,coduser,timexam,
                                        codempidc)
                                  values(p_codempid,p_codexam,p_dtetest,p_typtest,p_typetest,p_dteyear,p_numclseq,p_codcours,p_codsubj,p_chaptno,
                                         p_dtetrain,p_namtest,p_codpswd,p_dtetestst,p_numappl,p_numreql,p_codcompl,
                                         p_codposl,p_flglogin,p_flgtest,p_codcomp,p_codpos,global_v_coduser,global_v_coduser,v_timexam,
                                         p_codempidc);
                    exception when dup_val_on_index then
                    null;
                end;
            else
                if el_flgtest = 'G' and el_statest = 'N' then
                  begin
                   update ttestemp set dteyear = p_dteyear,
                          numclseq = p_numclseq,
                          codcours = p_codcours,
                          codsubj = p_codsubj,
                          chaptno = p_chaptno,
                          dtetrain = p_dtetrain,
                          namtest = p_namtest,
                          codpswd = p_codpswd,
                          dtetestst = p_dtetestst,
                          numappl = p_numappl,
                          numreql = p_numreql,
                          codcompl = p_codcompl,
                          codposl = p_codposl,
                          flglogin = p_flglogin,
                          codcomp = p_codcomp,
                          codpos = p_codpos,
                          codcreate = global_v_coduser,
                          coduser = global_v_coduser,
                          timexam = v_timexam,
                          codempidc = p_codempidc
                          where codempid = p_codempid
                          and codexam = p_codexam
                          and dtetest = p_dtetest
                          and typtest = p_typtest
                          and typetest = p_typetest ;
                  end;
                end if;
            end if;
          end if;

  end gen_detail;

  procedure get_detail (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_exam(json_str_output out clob) is
    obj_row             json_object_t;
    obj_row2            json_object_t;
    obj_data            json_object_t;
    obj_data2           json_object_t;
    obj_result          json_object_t;
    obj_result_row      json_object_t;
    obj_temp            json_object_t;
    obj_temp_row        json_object_t;
    obj_detail          json_object_t;
    v_row               number := 0;
    v_row2              number := 0;
    v_count             number := 0;
    v_numseq            number := 0;
    v_item              number := 0;
    v_namsubje          tvquest.namsubje%type;
    v_qtyexam           tvquest.qtyexam%type;
    v_qtyscore          tvquest.qtyscore%type;
    v_typeexam          tvquest.typeexam%type;
    v_filename          tvquestd1.filename%type;
    v_numques           tvquestd1.numques%type;

    v_old_typeexam      varchar2(10 char) := '!@#';
    v_codquest          tvquest.codquest%type;
    v_test_type         varchar2(20 char) := '';

    v_folder_q          tfolderd.folder%type;
    v_folder_a          tfolderd.folder%type;
    v_answer            ttestempd.answer%type;
    v_numans            ttestempd.numans%type;
    cursor c1 is
        select a.codquest,decode(global_v_lang,'101',desquese,
                                  '102',desques2,
                                  '103',desques3,
                                  '104',desques4,
                                  '105',desques5) as desquese ,numques,
              filename,a.qtyscore,numans,
              decode(global_v_lang,'101',namsubje,
                                  '102',namsubj2,
                                  '103',namsubj3,
                                  '104',namsubj4,
                                  '105',namsubj5) as namsubje,
              b.qtyexam,b.qtyscore b_qtyscore,b.typeexam

            from tvquestd1 a, tvquest b
          where a.codexam = p_codexam
          and a.codexam = b.codexam
          and a.codquest = b.codquest
          and a.codquest = p_codquest
          order by a.codquest,a.numques ;

      cursor c2 is
           select numans,decode(global_v_lang,'101',desanse,
                                  '102',desans2,
                                  '103',desans3,
                                  '104',desans4,
                                  '105',desans5) as desanse,filename,codquest,numques
            from tvquestd2
            where codexam  = p_codexam
              and codquest = v_codquest
              and numques  = v_numques;
    begin

            begin
                select folder
                  into v_folder_q
                  from tfolderd
                 where codapp = 'HREL31E1';
            exception when no_data_found then
                v_folder_q := null;
            end;

            begin
                select folder
                  into v_folder_a
                  from tfolderd
                 where codapp = 'HREL31E2';
            exception when no_data_found then
                v_folder_a := null;
            end;

        obj_result := json_object_t();
        obj_result_row := json_object_t();
        obj_result.put('coderror', '200');
        obj_row := json_object_t();

        for r1 in c1 loop

          v_typeexam     := r1.typeexam;
          if v_old_typeexam = '3' then
            v_test_type := 'evaluate';
          elsif v_old_typeexam = '4' then
            v_test_type := 'subjective';
          elsif v_old_typeexam = '1' then
            v_test_type := 'select';
          elsif v_old_typeexam = '2' then
            v_test_type := 'rightwrong';
           end if;

          if v_old_typeexam <> '!@#' and v_old_typeexam <> v_typeexam then
             v_row := v_row + 1;


              v_numseq := v_numseq + 1;
              obj_temp := json_object_t();
              obj_temp.put('coderror', '200');

              obj_temp_row := json_object_t();
              obj_temp_row.put('coderror', '200');

              obj_detail := json_object_t();
              obj_detail.put('coderror', '200');

              obj_detail.put('numseq', v_numseq);
              obj_detail.put('v_namsubje', v_namsubje);
              obj_detail.put('qtyexam', v_qtyexam);
              obj_detail.put('qtyscore', v_qtyscore);
              obj_detail.put('typeexam', v_old_typeexam);

              obj_temp_row.put('rows', obj_row);

              obj_temp.put('table', obj_temp_row);
              obj_temp.put('detail', obj_detail);
              obj_result.put(v_test_type, obj_temp);
              obj_row := json_object_t();
              v_row   := 0;

          end if;
            v_old_typeexam := v_typeexam;
            v_codquest     := r1.codquest;
            v_namsubje     := r1.namsubje;
            v_qtyexam      := r1.qtyexam;
            v_qtyscore     := r1.qtyscore;
            v_numques      := r1.numques;
            v_count := v_count +1;
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('numques',r1.numques);
              obj_data.put('desques',r1.numques || '. ' || r1.desquese);
              v_filename := '';
              if r1.filename is not null then
                 v_filename := get_tsetup_value('PATHWORKPHP')||v_folder_q||'/'||r1.filename;
              end if;
              obj_data.put('filenamehead',v_filename);
              obj_data.put('codquest',r1.codquest);
              obj_data.put('numques',r1.numques);
              v_answer := '';
              v_numans := '';

              begin
                select answer,numans
                into   v_answer,v_numans
                from  ttestempd
                where codempid = p_codempid
                and  codexam = p_codexam
                and  dtetest = p_dtetest
                and  codquest = r1.codquest
                and  numques = r1.numques
                and typtest = p_typtest
                and typetest = p_typetest;
              exception when no_data_found then
                v_answer := '';
                v_numans := '';
              end;

              if v_answer is not null then
                obj_data.put('answer',v_answer);
              else
                obj_data.put('answer',to_char(v_numans));
              end if;
              v_item := 0;
              v_row2 := 0;
              obj_row2 := json_object_t();
              for r2 in c2 loop
                v_item := v_item + 1;

                obj_data2 := json_object_t();
                obj_data2.put('coderror','200');
                obj_data2.put('item',to_char(v_item));
                obj_data2.put('grad',CHR(64+r2.numans));
                obj_data2.put('desc_grditem',r2.desanse);
                v_filename := '';
                if r2.filename is not null then
                   v_filename := get_tsetup_value('PATHWORKPHP')||v_folder_a||'/'||r2.filename;
                end if;

                obj_data2.put('filename',v_filename);
                if v_numans =  v_item then
                  obj_data2.put('numans',v_numans);
                else
                  obj_data2.put('numans','');
                end if;
                obj_data2.put('codquest', r2.codquest);
                obj_data2.put('numques', r2.numques);
                obj_row2.put(to_char(v_row2), obj_data2);
                v_row2        := v_row2 + 1;
              end loop;
              obj_data.put('desanse',obj_row2);
              obj_row.put(to_char(v_row), obj_data);
              v_row        := v_row + 1;
          end loop;

              obj_temp := json_object_t();
              obj_temp.put('coderror', '200');

              obj_temp_row := json_object_t();
              obj_temp_row.put('coderror', '200');
              v_numseq := v_numseq + 1;
              obj_detail := json_object_t();
              obj_detail.put('coderror', '200');

              obj_detail.put('numseq', v_numseq);
              obj_detail.put('v_namsubje', v_namsubje);
              obj_detail.put('qtyexam', v_qtyexam);
              obj_detail.put('qtyscore', v_qtyscore);
              obj_detail.put('typeexam', v_typeexam);

              obj_temp_row.put('rows', obj_row);
              if v_typeexam = '3' then
                v_test_type := 'evaluate';
              elsif v_typeexam = '4' then
                v_test_type := 'subjective';
              elsif v_typeexam = '1' then
                v_test_type := 'select';
              elsif v_typeexam = '2' then
                v_test_type := 'rightwrong';
              end if;

              obj_temp.put('table', obj_temp_row);
              obj_temp.put('detail', obj_detail);
              obj_result.put(v_test_type, obj_temp);

              if hcm_util.get_string_t(obj_result,'evaluate') is null and hcm_util.get_json_t(obj_result,'evaluate').get_size = 0  then
                obj_temp_row := json_object_t();
                obj_temp_row.put('rows', json_object_t());
                obj_temp := json_object_t();
                obj_temp.put('table', obj_temp_row);
                obj_temp.put('detail', json_object_t());
                obj_result.put('evaluate', obj_temp);
              end if;
              if hcm_util.get_string_t(obj_result,'subjective') is null and hcm_util.get_json_t(obj_result,'subjective').get_size = 0 then
                obj_temp_row := json_object_t();
                obj_temp_row.put('rows', json_object_t());
                obj_temp := json_object_t();
                obj_temp.put('table', obj_temp_row);
                obj_temp.put('detail', json_object_t());
                obj_result.put('subjective', obj_temp);
              end if;
              if hcm_util.get_string_t(obj_result,'select') is null and hcm_util.get_json_t(obj_result,'select').get_size = 0 then
                obj_temp_row := json_object_t();
                obj_temp_row.put('rows', json_object_t());
                obj_temp := json_object_t();
                obj_temp.put('table', obj_temp_row);
                obj_temp.put('detail', json_object_t());
                obj_result.put('select', obj_temp);
              end if;
              if hcm_util.get_string_t(obj_result,'rightwrong') is null and hcm_util.get_json_t(obj_result,'rightwrong').get_size = 0 then
                obj_temp_row := json_object_t();
                obj_temp_row.put('rows', json_object_t());
                obj_temp := json_object_t();
                obj_temp.put('table', obj_temp_row);
                obj_temp.put('detail', json_object_t());
                obj_result.put('rightwrong', obj_temp);
              end if;

          json_str_output := obj_result.to_clob;

  end gen_detail_exam;

  procedure get_detail_exam (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail_exam(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_exam(json_str_input in clob,json_str_output out clob) is
    param_json       json_object_t;
    param_desanse       json_object_t;
    param_answer     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    v_error_remark    varchar2(4000);
    obj_data          json_object_t;
    obj_row           json_object_t;
    obj_result           json_object_t;
    json_result           json_object_t;
    v_rcnt            number  := 0;

    v_error				   boolean;
    v_err_code  	   varchar2(1000 char);
    v_err_field  	   varchar2(1000 char);
    v_err_table		   varchar2(20 char);
    v_flgfound  	   boolean;
    v_cnt					   number := 0;
    v_num            number := 0;
    v_ascii          number := 0;

    v_choice         varchar2(10 char);
    v_ans            ttestempd.answer%type;
    v_answer         ttestempd.answer%type;
    v_numans         ttestempd.numans%type;
    v_codquest       tvquestd1.codquest%type;
    v_numques        tvquestd1.numques%type;
  begin
    obj_row := json_object_t();
    obj_result := json_object_t();

    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
--    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');


    for rw in 0..param_json.get_size-1 loop

      param_json_row  := hcm_util.get_json_t(param_json,to_char(rw));
      param_desanse   := hcm_util.get_json_t(param_json_row, 'desanse');
      v_err_field   := hcm_util.get_string_t(param_json_row, 'desques');
      v_ans         := hcm_util.get_string_t(param_json_row, 'answer');
      v_codquest         := hcm_util.get_string_t(param_json_row, 'codquest');
      v_numques         := hcm_util.get_string_t(param_json_row, 'numques');
      v_answer := '';
      v_numans := '';

      if p_typeexam = '4' then
        v_answer := v_ans;
      else
        v_numans := to_number(v_ans);
      end if;


      begin
        insert into ttestempd(codempid,codexam,dtetest,codquest,numques,typtest,typetest,answer,numans,codcreate,coduser)
                       values(p_codempid,p_codexam,p_dtetest,v_codquest,v_numques,p_typtest,p_typetest,v_answer,
                              v_numans,p_codempid,p_codempid);
      exception when dup_val_on_index then
         update ttestempd
            set answer = v_answer,
                numans = v_numans,
                coduser = p_codempid
          where codempid = p_codempid
            and codexam  = p_codexam
--            and dtetest  = trunc(sysdate)
            and dtetest  = p_dtetest --ss
            and codquest  = v_codquest
            and numques  = v_numques
            and typtest = p_typtest
            and typetest = p_typetest;

      end;


    end loop;
    gen_detail(json_str_output);


  end;

  procedure post_save_exam (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    save_exam(json_str_input,json_str_output);
    commit;
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure send_exam(json_str_output out clob) is
    obj_row             json_object_t;

    begin

    p_flg_send_exam := 'Y';
    gen_detail(json_str_output);

  end send_exam;

  procedure post_send_exam (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            send_exam(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end hrel43e;

/

--------------------------------------------------------
--  DDL for Package Body HREL41E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL41E" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codlogin          := hcm_util.get_string_t(json_obj,'p_codlogin');

    p_flgtest        := hcm_util.get_string_t(json_obj,'p_flgtest');
    p_codempid       := hcm_util.get_string_t(json_obj,'p_codempidQuery');
    p_codexam        := hcm_util.get_string_t(json_obj,'p_codexam');
    p_dtetest        := to_date(hcm_util.get_string_t(json_obj,'p_dtetest'),'dd/mm/yyyy');
    p_namtest        := hcm_util.get_string_t(json_obj,'p_namtest');
    p_dtetestst      := to_date(hcm_util.get_string_t(json_obj,'p_dtetestst'),'dd/mm/yyyy');
    p_codpos         := hcm_util.get_string_t(json_obj,'p_codpos');
    p_codcomp        := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dteyear       := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_numclseq       := hcm_util.get_string_t(json_obj,'p_numclseq');
    p_codcours       := hcm_util.get_string_t(json_obj,'p_codcours');
    p_typtest        := hcm_util.get_string_t(json_obj,'p_typtest');
    p_namempt        := hcm_util.get_string_t(json_obj,'p_namempt');

   hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_count_comp  number := 0;
    v_secur  boolean := false;
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
--        check_index();
        if param_msg_error is null then
            gen_index_emp(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_codpos            temploy1.codpos%type;
    v_codcomp           temploy1.codcomp%type;
    v_staemp            temploy1.staemp%type;
    v_flgtest_tr        varchar2(2 char);
    v_flgbtn            varchar2(2 char);
    v_dtetest           ttestemp.dtetest%type;

    cursor c1 is
      select dteyear,codcompy,codcours,numclseq,dteprest,dtepreen,codexampr
              ,dtepostst,dteposten,codexampo,flgatend, flgtype,dtetemp1,dtetemp2 from(
      select a.dteyear,a.codcompy,a.codcours,a.numclseq,dteprest,dtepreen,codexampr
              ,dtepostst,dteposten,codexampo,flgatend,'Pre' flgtype,dteprest dtetemp1,null dtetemp2
        from tyrtrsch a, tpotentp b
       where a.dteyear = b.dteyear
         and a.codcompy = b.codcompy
         and a.codcours = b.codcours
         and a.numclseq = b.numclseq
         and b.codempid = p_codempid
         and (a.codexampr is not null and dtepreen >= trunc(sysdate))
        union all
          select a.dteyear,a.codcompy,a.codcours,a.numclseq,dteprest,dtepreen,codexampr
             ,dtepostst,dteposten,codexampo,flgatend,'Post' flgtype,null dtetemp1,dtepostst dtetemp2
        from tyrtrsch a, tpotentp b
       where a.dteyear = b.dteyear
         and a.codcompy = b.codcompy
         and a.codcours = b.codcours
         and a.numclseq = b.numclseq
         and b.codempid = p_codempid
         and (a.codexampo is not null and dteposten >= trunc(sysdate)) 
         )
         order by codcours,dteyear,numclseq,dtetemp1,dtetemp2;

    cursor c2 is
      select a.remark, a.dtetestst, a.dtetesten, 
           replace(a.codcatexm,'%', null) codcatexm, replace(a.codexam,'%', null) codexam
      from ttestset a , ttestsetd b
     where a.codcomp     = b.codcomp
       and a.dtetestst   = b.dtetestst
       and a.dtetesten   = b.dtetesten
       and a.codcatexm   = b.codcatexm
       and a.codexam     = b.codexam
       and b.codempid    = p_codempid
       and  a.dtetesten >= trunc(sysdate) 
    order by dtetestst;

    begin
    
        v_dtetest := trunc(sysdate);
        
         obj_row := json_object_t();

        if p_flgtest = '2' then
         for r1 in c1 loop
            
            v_flgbtn := 'N';
            if r1.flgtype = 'Post' and r1.codexampo is not null and r1.flgatend = 'Y' then
              begin
                select 'Y' into v_flgtest_tr
                from ttestemp
                where codempid = p_codempid
                  and codcours = r1.codcours
                  and dteyear  = r1.dteyear
                  and numclseq = r1.numclseq
                  and codexam = r1.codexampo
                  and typetest = '2'
                  and typtest = '2';
              exception when no_data_found then
                v_flgtest_tr := 'N';
              end;

               if v_flgtest_tr = 'N' then
                 obj_data := json_object_t();
                 obj_data.put('coderror','200');
                 obj_data.put('desc_typtest','');
                 obj_data.put('dtetestst','');
                 obj_data.put('dtetesten','');
                 obj_data.put('codexam','');
                 obj_data.put('typtest','2');
                 obj_data.put('desc_typtest',get_label_name('HREL01E1',global_v_lang,70));
                 obj_data.put('dtetestst',to_char(r1.dtepostst,'dd/mm/yyyy'));
                 obj_data.put('dtetesten',to_char(r1.dteposten,'dd/mm/yyyy'));
                 obj_data.put('codexam',r1.codexampo);
                 obj_data.put('desc_codexam',get_tvtest_name(r1.codexampo,global_v_lang));
                    if trunc(sysdate) between r1.dtepostst and r1.dteposten then
                      v_flgbtn := 'Y';
                    end if;
                 obj_data.put('flgtest',v_flgbtn);
                 obj_data.put('codcours',r1.codcours);
                 obj_data.put('desc_codcours',get_tcourse_name(r1.codcours,global_v_lang));
                 obj_data.put('dteyear',r1.dteyear);
                 obj_data.put('numclseq',r1.numclseq);
                 obj_data.put('dtetest',to_char(v_dtetest,'dd/mm/yyyy'));
                 obj_row.put(to_char(v_row), obj_data);
                 v_row := v_row + 1;
               end if;
             end if;
            
             if r1.flgtype = 'Pre' and r1.codexampr is not null then
              begin
                select 'Y' into v_flgtest_tr
                from ttestemp
                where codempid = p_codempid
                  and codcours = r1.codcours
                  and dteyear  = r1.dteyear
                  and numclseq = r1.numclseq
                  and codexam = r1.codexampr
                  and typetest = '1'
                  and typtest = '2';
              exception when no_data_found then
                v_flgtest_tr := 'N';
              end;

               if v_flgtest_tr = 'N' then
                 obj_data := json_object_t();
                 obj_data.put('coderror','200');
                 obj_data.put('desc_typtest','');
                 obj_data.put('dtetestst','');
                 obj_data.put('dtetesten','');
                 obj_data.put('codexam','');
                 obj_data.put('typtest','1');
                 obj_data.put('desc_typtest',get_label_name('HREL01E1',global_v_lang,60));
                 obj_data.put('dtetestst',to_char(r1.dteprest,'dd/mm/yyyy'));
                 obj_data.put('dtetesten',to_char(r1.dtepreen,'dd/mm/yyyy'));
                 obj_data.put('codexam',r1.codexampr);
                 obj_data.put('desc_codexam',get_tvtest_name(r1.codexampr,global_v_lang));
                    if trunc(sysdate) between r1.dteprest and r1.dtepreen then
                      v_flgbtn := 'Y';
                    end if;
                 obj_data.put('flgtest',v_flgbtn);
                 obj_data.put('codcours',r1.codcours);
                 obj_data.put('desc_codcours',get_tcourse_name(r1.codcours,global_v_lang));
                 obj_data.put('dteyear',r1.dteyear);
                 obj_data.put('numclseq',r1.numclseq);
                 obj_data.put('dtetest',to_char(v_dtetest,'dd/mm/yyyy'));
                 obj_row.put(to_char(v_row), obj_data);
                 v_row := v_row + 1;
               end if;
             end if;
         end loop;

          if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tpotentp');
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
            return;
          else
            json_str_output := obj_row.to_clob;
          end if;
        end if;

        if p_flgtest = '3' then
         for r2 in c2 loop
            v_flgbtn := 'N';

              begin
                select 'Y' into v_flgtest_tr
                from ttestemp
                where codempid = p_codempid
                  and dtetestst = r2.dtetestst
                  and codexam = r2.codexam
                  and typtest = '3';
              exception when no_data_found then
                v_flgtest_tr := 'N';
              end;

               if v_flgtest_tr = 'N' then
                 obj_data := json_object_t();
                 obj_data.put('coderror','200');


                 if trunc(sysdate) between r2.dtetestst and r2.dtetesten then
                      v_flgbtn := 'Y';
                    end if;
                 obj_data.put('flgtest',v_flgbtn);
                 obj_data.put('remark',r2.remark);
                 obj_data.put('dtetestst',to_char(r2.dtetestst,'dd/mm/yyyy'));
                 obj_data.put('dtetesten',to_char(r2.dtetesten,'dd/mm/yyyy'));
                 obj_data.put('codexam',r2.codexam);
                 obj_data.put('desc_codexam',get_tvtest_name(r2.codexam,global_v_lang));
                 obj_data.put('dtetest',to_char(v_dtetest,'dd/mm/yyyy'));
                 obj_data.put('typtest','2');
                 obj_row.put(to_char(v_row), obj_data);
                 v_row := v_row + 1;
               end if;

         end loop;

          if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055', global_v_lang,'ttestset');
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
            return;
          else
            json_str_output := obj_row.to_clob;
          end if;

        end if;

        if param_msg_error is null then
           json_str_output := obj_row.to_clob;
          return;
        else 
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
        end if;

  end gen_detail;

  procedure get_detail (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
--        check_index();
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
    obj_data            json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_numappl           tappoinf.numappl%type;
    v_codexam           tappoinf.codexam%type;
    v_dteappoi          tappoinf.dteappoi%type;
    v_namempt           tapplinf.namempt%type;
    v_codcompl          tapplinf.codcompl%type;
    v_codposl           tapplinf.codposl%type;
    v_numreql           tapplinf.codposl%type;
    v_flgtest_tr        varchar2(2 char);
    v_codcompyl         tcenter.codcomp%type;
    begin

        begin
          select a.numappl, codexam, dteappoi, namempt, codcompl, codposl,numreql
             into v_numappl, v_codexam, v_dteappoi, v_namempt, v_codcompl, v_codposl, v_numreql
            from tappoinf a, tapplinf b
          where a.numappl = b.numappl
             and codlogin = p_codlogin
            and dteappoi  = trunc(sysdate);
        exception when no_data_found then
          null;
        end;



        begin
          insert into ttestemp(codempid,codexam,dtetest,namtest,codpswd,dtetestst,
                                numappl,numreql,codcompl,codposl,typtest,flglogin,flgtest,codcomp,codpos,
                                dteyear,numclseq,codcours)
                        values(p_codempid,p_codexam,trunc(sysdate),p_namempt,'',p_dtetestst,
                               p_numappl,p_numreql,p_codcompl,p_codposl,p_typtest,'2','P',p_codcomp,p_codpos,
                               p_dteyear,p_numclseq,p_codcours);
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          null;
        end;

        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);


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
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;



end hrel41e;

/

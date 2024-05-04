--------------------------------------------------------
--  DDL for Package Body HRES88E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES88E" is
-- last update: 24/02/2023 18:19

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
    obj_syncond         json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    ---------------------------------------------
    p_dtereqst          := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereqst')),'dd/mm/yyyy');
    p_dtereqen          := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereqen')),'dd/mm/yyyy');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempidQuery');
    p_dtereq            := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereq')),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_codjob            := hcm_util.get_string_t(json_obj,'p_codjob');

    p_amtincom          := hcm_util.get_string_t(json_obj,'p_amtincom');
    p_codbrlc           := hcm_util.get_string_t(json_obj,'p_codbrlc');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempr           := hcm_util.get_string_t(json_obj,'p_codempr');
    p_codempmt          := hcm_util.get_string_t(json_obj,'p_codempmt');
    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    p_codrearq          := hcm_util.get_string_t(json_obj,'p_codrearq');
    p_flgcond           := hcm_util.get_string_t(json_obj,'p_flgcond');
    p_flgjob            := hcm_util.get_string_t(json_obj,'p_flgjob');
    p_flgrecut          := hcm_util.get_string_t(json_obj,'p_flgrecut');
    p_qtyreq            := hcm_util.get_string_t(json_obj,'p_qtyreq');
    p_remarkap          := hcm_util.get_string_t(json_obj,'p_remarkap');

    obj_syncond         := hcm_util.get_json_t(json_obj,'p_syncond');
    p_syncond           := hcm_util.get_string_t(obj_syncond,'code');
    p_statement         := hcm_util.get_string_t(obj_syncond,'statement');

  end initial_value;

  function char_time_to_format_time (p_tim varchar2) return varchar2 is
  begin
    if p_tim is not null then
      return substr(p_tim, 1, 2) || ':' || substr(p_tim, 3, 2);
    else
      return p_tim;
    end if;
  exception when others then
    return p_tim;
  end;

  procedure check_index is
    v_count_comp    number := 0;
    v_secur         boolean := false;
  begin
    null;
  end;
  --
 procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;

    cursor c1 is
      select codempid,dtereq,numseq,codcomp,codpos,qtyreq,staappr,codappr,
             approvno,remarkap,routeno
        from tjobreq
        where codempid = global_v_codempid
          and dtereq between nvl(p_dtereqst,dtereq) and nvl(p_dtereqen,dtereq)
          order by dtereq Desc,numseq Desc;
  begin
    v_rcnt      := 0;
    obj_row     := json_object_t();
    obj_data    := json_object_t();
    for r1 in c1 loop
      v_rcnt    := v_rcnt+1;
      obj_data.put('coderror', 200);
      obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
      obj_data.put('numseq', r1.numseq);
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
      obj_data.put('codpos', r1.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
      obj_data.put('qtyreq', r1.qtyreq);
      obj_data.put('staappr', r1.staappr);
      obj_data.put('status', get_tlistval_name('ESSTAREQ', r1.staappr,global_v_lang));
      obj_data.put('remarkap', r1.remarkap);
      obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
      obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES88E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,nvl(trim(r1.approvno),'0'),global_v_lang));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;

 procedure get_index (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
--        check_index();
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
    obj_data        json_object_t;
    obj_syncond     json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_pathweb       varchar2(4000 char);
    v_codasset      tasetinf.codasset%type;
    v_job_remark    varchar2(4000 char);

    cursor c1 is
      select codempid,dtereq,numseq,codcomp,codpos,codjob,qtyreq,staappr,codappr,
             approvno,remarkap,routeno,codempmt,amtincom,flgrecut,
             codrearq,syncond,statement,codempr,codbrlc,flgjob,flgcond
        from tjobreq
        where codempid = global_v_codempid
          and dtereq = p_dtereq
          and numseq = p_numseq;
  begin
    v_rcnt      := 0;
    obj_data    := json_object_t();
    -- << add surachai | 25/02/2023 #9113
    if p_numseq is null then
        begin
          select max(nvl(numseq,0)) + 1
          into v_numseq
          from tjobreq
          where codempid = global_v_codempid
          and dtereq = p_dtereq;

--        exception when no_data_found then
--          v_numseq := 1;
        end;
        if v_numseq is null then
          v_numseq := 1;
        end if;
    end if;
    -- >>
    for r1 in c1 loop
      v_rcnt    := v_rcnt+1;
      obj_data.put('coderror', 200);
      obj_data.put('numseq', r1.numseq);
      obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('codpos', r1.codpos);
      obj_data.put('codjob', r1.codjob);
      obj_data.put('codempmt', r1.codempmt);
      obj_data.put('codbrlc', r1.codbrlc);
      obj_data.put('amtincom', r1.amtincom);
      obj_data.put('flgrecut', r1.flgrecut);

      obj_data.put('staappr', r1.staappr);                                      --> Peerasak || Issue#8330 || 27022023

      if r1.flgjob = 'Y' then
        obj_data.put('flgproperty', '1');
        begin
          select statement
            into v_job_remark
            from tjobcode
           where codjob = r1.codjob;
        exception when no_data_found then
          v_job_remark := null;
        end;
        obj_data.put('jobremark', get_logical_desc(v_job_remark));
      elsif r1.flgcond = 'Y' then
        obj_data.put('flgproperty', '2');
      end if;
      obj_data.put('flgjob', r1.flgjob);
      obj_data.put('flgcond', r1.flgcond);


      obj_data.put('remarkap', r1.remarkap);
      obj_data.put('codrearq', r1.codrearq);
      obj_data.put('codempr', r1.codempr);

      obj_syncond := json_object_t();
      obj_syncond.put('code',nvl(r1.syncond,''));
      obj_syncond.put('description',get_logical_desc(r1.statement));
      if r1.statement is not null then
        obj_syncond.put('statement',r1.statement);
      else
       obj_syncond.put('statement','');
      end if;
      obj_data.put('syncond',obj_syncond);
      obj_data.put('qtyreq', r1.qtyreq);
    end loop;

    if v_rcnt = 0 then
      obj_data.put('coderror', 200);
      obj_data.put('dtereq', to_char(sysdate,'dd/mm/yyyy'));
--      obj_data.put('numseq', 1); -- bk surachai | 25/02/2023
      obj_data.put('numseq', v_numseq); -- add surachai | 25/02/2023
      obj_syncond := json_object_t();
      obj_syncond.put('code','');
      obj_syncond.put('description','');
      obj_syncond.put('statement','');
      obj_data.put('syncond',obj_syncond);
    end if;

    json_str_output := obj_data.to_clob;
  end;

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

  procedure gen_job_remark(json_str_output out clob) is
    obj_data        json_object_t;
    v_job_remark    tjobcode.statement%type;
  begin
    begin
      select statement
      into v_job_remark
      from tjobcode
      where codjob = p_codjob;
    exception when no_data_found then
      v_job_remark := null;
    end;

    obj_data := json_object_t();
    obj_data.put('coderror', 200);
    obj_data.put('job_remark', get_logical_desc(v_job_remark));
    json_str_output := obj_data.to_clob;
  end;

  procedure get_job_remark (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_job_remark(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_detail_save as
   p_temp         varchar2(100 char);
   v_secur        boolean := false;
   v_dte_tempst   date;
   v_dte_tempend  date;
   v_temp         number :=0;
   v_exist        varchar2(1 char) := 'N';
  begin
   null;
  end;

  procedure detail_save(json_str_output out clob) as
    v_codapp          varchar2(10) := 'HRES88E';
    param_json_row    json_object_t;
    param_json        json_object_t;
    v_flg             varchar2(100 char);
    v_seqno           tassetreq.seqno%type;
    v_routeno    	  tjobreq.routeno%type;
    v_approvno    	  tjobreq.approvno%type;
    v_table			  varchar2(50 char);
    v_error			  varchar2(100 char);
    v_codempid_next   temploy1.codempid%type;
    v_codempap        temploy1.codempid%type;
    v_codcompap       tcenter.codcomp%type;
    max_approvno      tjobreq.approvno%type;
    v_count           number := 0;
    v_remark          varchar2(200) := get_label_name('HRES62EC2',global_v_lang,130);
  begin
    v_approvno          :=  0 ;
    tjobreq_staappr     := 'P' ;

    chk_workflow.find_next_approve(v_codapp,v_routeno,global_v_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,global_v_codempid,null);
    if v_routeno is null then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'twkflph');
        return;
      end if;

      chk_workflow.find_approval(v_codapp,global_v_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,v_table,v_error);
      if v_error is not null then
        param_msg_error := get_error_msg_php(v_error,global_v_lang,v_table);
        return;
      end if;

      --Loop Check Next step
     loop
       v_codempid_next := chk_workflow.check_next_step(v_codapp,v_routeno,global_v_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,global_v_codempid);
       if  v_codempid_next is not null then
          begin
            select approvno
              into max_approvno
              from twkflowh
             where routeno = v_routeno;
          exception when no_data_found then
            max_approvno := 0;
          end;
        v_approvno         := v_approvno + 1 ;
        tjobreq_codappr    := v_codempid_next ;
        tjobreq_staappr    := 'A' ;
        tjobreq_dteappr    := trunc(sysdate);
        tjobreq_remarkap   := v_remark;
        tjobreq_approvno   := v_approvno ;
        if max_approvno <> v_approvno then
            begin
                    select count(*)
                      into v_count
                      from tapjobrq
                     where codempid = global_v_codempid
                       and dtereq = p_dtereq
                       and numseq = p_numseq
                       and approvno = v_approvno;
                exception when no_data_found then
                    v_count := 0;
                end;

                if v_count = 0 then
                    insert into tapjobrq (codempid,dtereq,numseq,approvno,
                                           codappr,dteappr,dteapph,
                                           staappr,remark,coduser)
                    values  (global_v_codempid,p_dtereq,p_numseq,v_approvno,
                               v_codempid_next,trunc(sysdate),trunc(sysdate),
                               'A',v_remark,global_v_coduser);
            else
                    update tapjobrq
                       set codappr = v_codempid_next,
                           dteappr = trunc(sysdate),
                           staappr = 'A',
                           remark = v_remark ,
                           coduser = global_v_coduser
                     where codempid = global_v_codempid
                       and dtereq = p_dtereq
                       and numseq = p_numseq
                       and approvno = v_approvno;
            end if;

            chk_workflow.find_next_approve(v_codapp,v_routeno,global_v_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,global_v_codempid,null);
           end if;
       else
          exit ;
       end if;
     end loop ;
    tjobreq_approvno     := v_approvno ;
    tjobreq_routeno      := v_routeno ;
  end ;

  procedure save_tjobreq is
  v_numseq    tjobreq.numseq%type;
  begin
    begin
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      if p_numseq is null then
        begin
          select max(nvl(numseq,0)) + 1
          into v_numseq
          from tjobreq
          where codempid = global_v_codempid
          and dtereq = p_dtereq;
        end;
        --<<user36 ST11 #9232 09/03/2022
        if v_numseq is null then
          v_numseq := 1;
        end if;
        -->>user36 ST11 #9232 09/03/2022
      else
        v_numseq := p_numseq;
      end if;
        insert into tjobreq (codempid,dtereq,numseq,codcomp,codpos,codjob,
                             codempmt,qtyreq,amtincom,
                             flgrecut,codrearq,staappr,
                             dteupd,coduser,codappr,dteappr,approvno,
                             remarkap,flgjob,
                             flgcond,routeno,
                             syncond,statement,codempr,codbrlc)
        values (global_v_codempid,p_dtereq,v_numseq,p_codcomp,p_codpos,p_codjob,
                p_codempmt,p_qtyreq,p_amtincom,
                p_flgrecut,p_codrearq,tjobreq_staappr,
                trunc(sysdate),global_v_coduser,tjobreq_codappr,tjobreq_dteappr,tjobreq_approvno,
                p_remarkap,p_flgjob,
                p_flgcond,tjobreq_routeno,
                p_syncond,p_statement,p_codempr,p_codbrlc);
    exception when dup_val_on_index then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);

      begin
        update tjobreq
               set codjob = p_codjob,
                   codempmt = p_codempmt,
                   qtyreq = p_qtyreq,
                   amtincom = p_amtincom,
                   flgrecut = p_flgrecut,
                   codrearq = p_codrearq,
                   staappr = tjobreq_staappr,
                   dteupd = trunc(sysdate),
                   coduser = global_v_coduser,
                   codappr = tjobreq_codappr,
                   dteappr = tjobreq_dteappr,
                   approvno = tjobreq_approvno,
                   remarkap = p_remarkap,
                   flgjob = p_flgjob,
                   flgcond = p_flgcond,
                   routeno = tjobreq_routeno,
                   syncond = p_syncond,
                   statement = p_statement,
                   codempr = p_codempr,
                   codbrlc = p_codbrlc,
                   codpos = p_codpos,
                   codcomp = p_codcomp
             where codempid = global_v_codempid
               and numseq = p_numseq
               and dtereq = p_dtereq;
        exception when others then
          rollback;
        end;
    end;
  end;

  procedure post_detail_save(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail_save;

    if param_msg_error is null then
      detail_save(json_str_output);
        if param_msg_error is null then
          save_tjobreq;
          commit;
           json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
         json_str_output := get_response_message(null,param_msg_error,global_v_lang);
         return;
        end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure delete_index(json_str_output out clob) is
    obj_data        json_object_t;
    v_job_remark    varchar2(1000 char);
  begin
    begin
        update tjobreq
           set staappr = 'C',
               dtecancel = trunc(sysdate),
               coduser = global_v_coduser
         where codempid = global_v_codempid
           and dtereq = p_dtereq
           and numseq = p_numseq;
    exception when others then
      null;
    end;

    param_msg_error := get_error_msg_php('HR2421',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;

  procedure post_delete(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      delete_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

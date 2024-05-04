--------------------------------------------------------
--  DDL for Package Body HRESS4E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRESS4E" is
-- last update: 26/07/2016 11:58


  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
    obj_syncond       json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    ---------------------------------------------
     p_dtereqst         := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereqst')),'dd/mm/yyyy');
     p_dtereqen         := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereqen')),'dd/mm/yyyy');
     p_codempid         := hcm_util.get_string_t(json_obj,'p_codempidQuery');






     ---------------------------------------------------------------------
     p_dtest         := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtest')),'dd/mm/yyyy');
     p_dteen         := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteen')),'dd/mm/yyyy');
     p_dtereq           := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereq')),'dd/mm/yyyy');
     p_codcomp      := hcm_util.get_string_t(json_obj,'p_codcomp');
     p_codjob        := hcm_util.get_string_t(json_obj,'p_codjob');
     p_codpos        := hcm_util.get_string_t(json_obj,'p_codpos');
     p_numreqst      := hcm_util.get_string_t(json_obj,'p_numreqst');
     p_numseq           := hcm_util.get_string_t(json_obj,'p_numseq');
     p_remarks           := hcm_util.get_string_t(json_obj,'p_remarks');

     p_dtestart         := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtestart')),'dd/mm/yyyy');


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
    v_count_comp  number := 0;
    v_secur  boolean := false;
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
      select codempid,dtereq,numseq,codcomp,codpos,staappr,codappr,
             approvno,remarkap,routeno
        from tircreq
        where codempid = global_v_codempid
          and dtereq between nvl(p_dtest,dtereq) and nvl(p_dteen,dtereq)
          order by dtereq Desc,numseq Desc;


  begin

    v_rcnt := 0;

    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data.put('coderror', 200);
      obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
      obj_data.put('numseq', r1.numseq);
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
      obj_data.put('codpos', r1.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));

      obj_data.put('staappr', r1.staappr);
      obj_data.put('status', get_tlistval_name('ESSTAREQ', r1.staappr,global_v_lang));
      obj_data.put('remarkap', r1.remarkap);
      obj_data.put('desc_codappr', get_temploy_name((r1.codappr),global_v_lang));
      obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRESS4E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,nvl(trim(r1.approvno),'0'),global_v_lang));
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
    obj_data2        json_object_t;
    obj_row        json_object_t;
    obj_result        json_object_t;
    obj_syncond        json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_staappr       tircreq.staappr%type;

    cursor c1 is
      select b.numreqst,b.codpos,b.codcomp,b.codjob,b.dteopen,b.qtyreq,b.dteclose
        from treqest1 a, treqest2 b
        where a.numreqst = b.numreqst
          and b.flgrecut in ('I','O')
          and (b.dteclose is null or b.dteclose > trunc(sysdate))
          and a.stareq not in ('C','X')
          and nvl(b.qtyreq,0) > nvl(b.qtyact,0)
          order by b.codcomp,b.codpos;


  begin

    v_rcnt := 0;
    v_staappr := '';
    obj_row := json_object_t();
    obj_result := json_object_t();
    obj_data2 := json_object_t();

    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', 200);
      obj_data.put('filetext', '<i class="fa fa-file-text _text-blue"></i>');
      obj_data.put('info', '<i class="fa fa-info-circle _text-blue"></i>');
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
      obj_data.put('codpos', r1.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
      obj_data.put('codjob', r1.codjob);
      obj_data.put('desc_codjob', get_tjobcode_name(r1.codjob,global_v_lang));
      obj_data.put('dteopen', to_char(r1.dteopen,'dd/mm/yyyy'));
      obj_data.put('dteclose', to_char(r1.dteclose,'dd/mm/yyyy'));
      obj_data.put('qtyreq', r1.qtyreq);
      obj_data.put('numreqst', r1.numreqst);

      obj_data.put('dtestart', to_char('','dd/mm/yyyy'));
      obj_data.put('remarks', r1.qtyreq);
      obj_data.put('flgStatus', '');
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;


    json_str_output := obj_row.to_clob;
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

  procedure gen_popup_info(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    obj_temp        json_object_t;
    obj_syncond     json_object_t;
    v_rcnt          number;
    v_job_remark    tjobcode.statement%type;
    v_namjob        tjobcode.namjobe%type;
    v_syncond       tjobcode.syncond%type;
    cursor c1 is
      select b.numreqst,b.codpos,b.codcomp,b.codjob,b.dteopen,b.qtyreq,b.codbrlc,
             b.dteclose,b.desnote,syncond,statement,flgcond,flgjob,a.desnote remarks
        from  treqest2 b,treqest1 a
        where b.numreqst = p_numreqst
          and b.codpos = p_codpos
          and b.numreqst = a.numreqst;

    cursor c2 is
      select decode(global_v_lang,'101', namjobe ,
                                 '102', namjobt,
                                 '103', namjob3,
                                 '104', namjob4,
                                 '105', namjob5,namjobe) namjob,desjob,amtcolla,
                                 qtyguar,syncond,statement
        from  tjobcode
        where codjob = p_codjob;

     cursor c3 is
      select itemno,namitem,descrip
        from  tjobdet
        where codjob = p_codjob
        order by itemno;

     cursor c4 is
      select itemno,namitem,descrip
        from  tjobresp
        where codjob = p_codjob
       order by itemno;

    cursor c5 is
      select codedlv,codmajsb,numgpa
        from  tjobeduc
        where codjob = p_codjob
      order by seqno;
  begin


    obj_result := json_object_t();
    obj_result.put('coderror', 200);
    obj_data := json_object_t();

    for r1 in c1 loop

    begin
      select statement ,decode(global_v_lang,'101', namjobe ,
                                 '102', namjobt,
                                 '103', namjob3,
                                 '104', namjob4,
                                 '105', namjob5,namjobe) namjob
      into v_job_remark,v_namjob
      from tjobcode
      where codjob = r1.codjob;
    exception when no_data_found then
      v_job_remark := null;
    end;

    if r1.flgjob = 'Y' then
      v_syncond := get_logical_desc(v_job_remark);
    end if;

    if r1.flgcond = 'Y' then
      v_syncond := get_logical_desc(r1.statement);
    end if;

     obj_data.put('coderror', 200);
      obj_data.put('numreqst', r1.numreqst);
      obj_data.put('codpos', r1.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
      obj_data.put('codjob', r1.codjob);
      obj_data.put('desc_codjob', v_namjob);
      obj_data.put('companyold', get_tcodec_name('tcodloca',r1.codbrlc,global_v_lang));
      obj_data.put('desnote', r1.desnote);
      obj_data.put('remark', r1.remarks);
      obj_data.put('syncond',v_syncond);
    end loop;
    obj_result.put('treqest2', obj_data);

    obj_data := json_object_t();
    for r2 in c2 loop
      obj_data.put('coderror', 200);
      obj_data.put('namjob', r2.namjob);
      obj_data.put('desjob', r2.desjob);
      obj_data.put('amtcolla', to_char(r2.amtcolla,'fm999,999,999,990.00'));
      obj_data.put('qtyguar', r2.qtyguar);
      obj_data.put('syncond',get_logical_desc(r2.statement));
    end loop;
    obj_result.put('tjobcode', obj_data);

    obj_row  := json_object_t();
    obj_data := json_object_t();
    obj_temp := json_object_t();
    v_rcnt := 0;
    for r3 in c3 loop
      v_rcnt := v_rcnt + 1;
      obj_data.put('coderror', 200);
      obj_data.put('itemno', r3.itemno);
      obj_data.put('namitem', r3.namitem);
      obj_data.put('descrip', r3.descrip);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    obj_temp.put('rows', obj_row);
    obj_result.put('tjobdet', obj_temp);

    obj_row  := json_object_t();
    obj_data := json_object_t();
    obj_temp := json_object_t();
    v_rcnt := 0;
    for r4 in c4 loop
      v_rcnt := v_rcnt + 1;
      obj_data.put('coderror', 200);
      obj_data.put('itemno', r4.itemno);
      obj_data.put('namitem', r4.namitem);
      obj_data.put('descrip', r4.descrip);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    obj_temp.put('rows', obj_row);
    obj_result.put('tjobresp', obj_temp);

    obj_row  := json_object_t();
    obj_data := json_object_t();
    obj_temp := json_object_t();
    v_rcnt := 0;
    for r5 in c5 loop
      v_rcnt := v_rcnt + 1;
      obj_data.put('coderror', 200);
      obj_data.put('codedlv', r5.codedlv);
      obj_data.put('desc_codedlv', get_tcodec_name('TCODEDUC',r5.codedlv,global_v_lang));
      obj_data.put('codmajsb', r5.codmajsb);
      obj_data.put('desc_codmajsb', get_tcodec_name('TCODMAJR',r5.codmajsb,global_v_lang));
      obj_data.put('numgpa', r5.numgpa);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    obj_temp.put('rows', obj_row);
    obj_result.put('tjobeduc', obj_temp);

    json_str_output := obj_result.to_clob;
  end;

  procedure get_popup_info (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_popup_info(json_str_output);
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
    v_codapp          varchar2(10) := 'HRESS4E';
    param_json_row    json_object_t;
    param_json        json_object_t;
    v_flg             varchar2(100 char);
    v_seqno           tassetreq.seqno%type;
    v_routeno    			tircreq.routeno%type;
    v_approvno    	  tircreq.approvno%type;
    v_table			      varchar2(50 char);
    v_error			      varchar2(100 char);
    v_codempid_next   temploy1.codempid%type;
    v_codempap        temploy1.codempid%type;
    v_codcompap       tcenter.codcomp%type;
    max_approvno      tircreq.approvno%type;
    v_count           number := 0;
    v_remark          varchar2(200) := get_label_name('HRES62EC2',global_v_lang,130);
  begin
    v_approvno         :=  0 ;
    tircreq_staappr    := 'P' ;

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
        v_approvno          := v_approvno + 1 ;
        tircreq_codappr    := v_codempid_next ;
        tircreq_staappr    := 'A' ;
        tircreq_dteappr    := trunc(sysdate);
        tircreq_remarkap   := v_remark;
        tircreq_approvno   := v_approvno ;
        if max_approvno <> v_approvno then

            begin
                select  count(*) into v_count
                 from   tapempch
                 where  codempid = global_v_codempid
                 and    dtereq   = p_dtereq
                 and    numseq    = p_numseq
                 and    approvno =  v_approvno
                 and    typreq =  v_codapp;
            exception when no_data_found then  v_count := 0;
            end;

            if v_count = 0 then
              insert into tapempch
                      (codempid,dtereq,numseq,approvno,typreq,
                       codappr,dteappr,
                       staappr,remark,coduser,dteapph,
                       dtecreate,codcreate,dteupd)
              values  (global_v_codempid,p_dtereq,p_numseq,v_approvno,v_codapp,
                       v_codempid_next,trunc(sysdate),
                       'A',v_remark,global_v_coduser,sysdate,
                       sysdate,global_v_coduser,sysdate);
            else
              update tapempch  set codappr   = v_codempid_next,
                                  dteappr   = trunc(sysdate),
                                  staappr   = 'A',
                                  remark    = v_remark ,
                                  coduser   = global_v_coduser ,
                                  dteupd   = sysdate
              where codempid  = global_v_codempid
              and    dtereq   = p_dtereq
              and    numseq    = p_numseq
              and   approvno  = v_approvno;
            end if;

            chk_workflow.find_next_approve(v_codapp,v_routeno,global_v_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,global_v_codempid,null);
           end if;
       else
          exit ;
       end if;
     end loop ;
    tircreq_approvno     := v_approvno ;
    tircreq_routeno      := v_routeno ;

  end ;

  procedure save_tircreq is
  v_numseq    tircreq.numseq%type;
  v_codbrlc    tircreq.codbrlc%type;

  begin

    begin
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);

      if p_numseq is null then
        begin
          select nvl(max(numseq),0) + 1
          into v_numseq
          from tircreq
          where codempid = global_v_codempid
          and dtereq = p_dtereq;
        exception when no_data_found then
          v_numseq := 1;
        end;
      else
        v_numseq := p_numseq;
      end if;

      insert into tircreq
      (codempid,dtereq,numseq,numreqst,codcomp,codpos,codjob,
        codbrlc,remarks,dtestart,routeno,approvno,staappr,
        codinput,dteinput,codappr,dteappr,
        dtecreate,codcreate,dteupd,coduser
       )
      values
      (global_v_codempid,p_dtereq,v_numseq,p_numreqst,p_codcomp,p_codpos,p_codjob,
      v_codbrlc,p_remarks,p_dtestart,tircreq_routeno,tircreq_approvno,tircreq_staappr,
      global_v_coduser,trunc(sysdate),tircreq_codappr,tircreq_dteappr,
      sysdate,global_v_coduser, sysdate,global_v_coduser
       );
    exception when dup_val_on_index then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      begin
        update tircreq
        set   dtestart = p_dtestart,
              remarks = p_remarks,
              numreqst = p_numreqst,
              staappr   = tircreq_staappr,
              dteupd    = trunc(sysdate),
              coduser  = global_v_coduser,
              codappr  = tircreq_codappr,
              dteappr   = tircreq_dteappr,
              approvno   = tircreq_approvno,
              routeno   = tircreq_routeno
        where codempid  = global_v_codempid
          and numseq     = p_numseq
          and dtereq    = p_dtereq;

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
          save_tircreq;
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
    v_popup_info    varchar2(1000 char);
  begin

    begin
      update  tircreq
         set  staappr   = 'C',
              dtecancel = trunc(sysdate),
              coduser 	= global_v_coduser
       where  codempid  = global_v_codempid
         and  dtereq    = p_dtereq
         and  numseq    = p_numseq;
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

  procedure gen_job_app(json_str_output out clob) is
    obj_data        json_object_t;

    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_staappr       tircreq.staappr%type;

    cursor c1 is
      select codempid,dtereq,numseq,staappr,numreqst,codcomp,codpos,codjob,codbrlc,remarks,dtestart
        from tircreq
        where codempid = global_v_codempid
        and dtereq = p_dtereq
        and numseq = p_numseq
        ;

  begin

    v_rcnt := 0;
    v_staappr := '';

    obj_data := json_object_t();
    obj_data.put('coderror', 200);
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data.put('codempid', r1.codempid);
      obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
      obj_data.put('numseq', r1.numseq);
      obj_data.put('staappr', r1.staappr);
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('codpos', r1.codpos);
      obj_data.put('codjob', r1.codjob);
      obj_data.put('remarks', r1.remarks);
      obj_data.put('numreqst', r1.numreqst);
      obj_data.put('dtestart', to_char(r1.dtestart,'dd/mm/yyyy'));

    end loop;

    if p_numseq is null then
        begin
          select nvl(max(numseq),0)+1
          into v_numseq
          from tircreq
          where dtereq = trunc(sysdate)
          and codempid = global_v_codempid;
        exception when no_data_found then
          v_numseq := 1;
        end;
    else
      v_numseq := p_numseq;
    end if;

    if v_rcnt = 0 then
      obj_data.put('codempid', global_v_codempid);
      obj_data.put('dtereq', to_char(p_dtereq,'dd/mm/yyyy'));
      obj_data.put('numseq', v_numseq);
      obj_data.put('staappr', '');
      obj_data.put('codcomp', p_codcomp);
      obj_data.put('codpos', p_codpos);
      obj_data.put('codjob', p_codjob);
      obj_data.put('remarks','');
      obj_data.put('numreqst', p_numreqst);
      obj_data.put('dtestart', '');
    end if;


    json_str_output := obj_data.to_clob;
  end;

  procedure get_job_app (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_job_app(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end;

/

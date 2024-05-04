--------------------------------------------------------
--  DDL for Package Body HRES91E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES91E" is
-- last update: 26/07/2016 13:16

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');
    p_codcours          := hcm_util.get_string_t(json_obj,'p_codcours');
    p_dteyear           := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_numclseq          := hcm_util.get_string_t(json_obj,'p_numclseq');

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'ddmmyyyy');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');

  end initial_value;
  --
  procedure check_save(json_str in clob) is
    json_obj        json_object_t;
    v_dteyear       tpotentp.dteyear%type;
    v_codcompy      tpotentp.codcompy%type;
    v_numclseq      tpotentp.numclseq%type;
    v_codcours      tpotentp.codcours%type;
    v_codempid      tpotentp.codempid%type;
    v_count_tpotentp    number;
    v_tpotentp          tpotentp%rowtype;
  begin
    json_obj            := json_object_t(json_str);
    v_dteyear           := hcm_util.get_string_t(json_obj,'dteyear');
    v_codcompy          := hcm_util.get_string_t(json_obj,'codcompy');
    v_numclseq          := hcm_util.get_string_t(json_obj,'numclseq');
    v_codcours          := hcm_util.get_string_t(json_obj,'codcours');
    v_codempid          := hcm_util.get_string_t(json_obj,'codempid');
    
    select count(*)
      into v_count_tpotentp
      from tpotentp
     where dteyear = v_dteyear
       and codcompy = v_codcompy
       and numclseq = v_numclseq
       and codcours = v_codcours
       and codempid = v_codempid
       and flgatend not in ('Y','C');
       
    if v_count_tpotentp = 0 then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TPOTENTP');
        return;
    end if;
    
    begin
        select codtparg
          into p_codtparg
          from tpotentp
         where dteyear = v_dteyear
           and codcompy = v_codcompy
           and numclseq = v_numclseq
           and codcours = v_codcours
           and codempid = v_codempid;        
    exception when no_data_found then
        p_codtparg := null;
    end;
       
  end check_save;
  
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  --
  procedure gen_index (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;

    v_next_codappr  varchar2(1000);

	cursor c1 is
		select *
          from ttrncerq
         where dtereq between p_dtestr and p_dteend
           and codempid = global_v_codempid
      order by dtereq desc, numseq desc;

  begin
    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c1 loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        v_next_codappr := chk_workflow.get_next_approve('HRES91E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),
                                        r1.numseq, r1.approvno,global_v_lang);

        obj_data.put('coderror', '200');
        obj_data.put('numseq', r1.numseq);
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('codcours', r1.codcours);
        obj_data.put('desc_course', get_tcourse_name(r1.codcours,global_v_lang));
        obj_data.put('status', get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang));
        obj_data.put('remarkap', r1.remarkap);
        obj_data.put('codappr', r1.codappr || ' - ' || get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('next_codappr', v_next_codappr);
        obj_data.put('dteyear', r1.dteyear);
        obj_data.put('numclseq', r1.numclseq);
        obj_data.put('staappr', r1.staappr);
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end;
  --

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_detail (json_str_output out clob) is
    obj_detail      json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_tyrtrsch      tyrtrsch%rowtype;
    max_numseq      number;
    
	cursor c1 is
		select *
          from ttrncerq
         where codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq = p_numseq;

  begin
    obj_detail      := json_object_t();
    obj_detail.put('coderror', '200');

    for r1 in c1 loop
        begin
            select *
              into v_tyrtrsch
              from tyrtrsch
             where dteyear = r1.dteyear
               and codcompy = r1.codcompy
               and codcours = r1.codcours
               and numclseq = r1.numclseq;        
        exception when no_data_found then
            v_tyrtrsch := null;
        end;

        obj_detail.put('codempid', r1.codempid);
        obj_detail.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_detail.put('numseq', r1.numseq);
        obj_detail.put('codcours', r1.codcours);
        obj_detail.put('dtetrst', to_char(v_tyrtrsch.dtetrst,'dd/mm/yyyy'));
        obj_detail.put('dtetren', to_char(v_tyrtrsch.dtetren,'dd/mm/yyyy'));
        obj_detail.put('dteyear', r1.dteyear);
        obj_detail.put('remark', r1.desreq);
        obj_detail.put('codhotel', v_tyrtrsch.codhotel);
        obj_detail.put('codinsts', v_tyrtrsch.codinsts);
        obj_detail.put('codinstruc', v_tyrtrsch.codinst);
        obj_detail.put('numclseq', to_char(r1.numclseq));
        obj_detail.put('staappr', r1.staappr);
        obj_detail.put('qtyhour', trunc(v_tyrtrsch.qtytrmin/60)||':'||lpad(mod(v_tyrtrsch.qtytrmin,60),2,'0'));
        obj_detail.put('codinput', r1.codinput);
        obj_detail.put('codcomp', r1.codcomp);
        obj_detail.put('codcompy', r1.codcompy);
    end loop;
    json_str_output := obj_detail.to_clob;
  end;
--

  procedure get_detail_create(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_create(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_detail_create (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_costcent      tcenter.costcent%type;
    v_codcomp       temploy1.codcomp%type;

    max_numseq      number;
  begin
    v_rcnt := 0;
    obj_main        := json_object_t();
    obj_row         := json_object_t();
    obj_detail      := json_object_t();

    select max(numseq)
      into max_numseq
      from ttrncerq
     where codempid = p_codempid_query
       and dtereq = p_dtereq;
    max_numseq := nvl(max_numseq,0) + 1;

    begin
        select codcomp
          into v_codcomp
          from temploy1 
         where codempid = p_codempid_query; 
    exception when no_data_found then
        v_codcomp := null;
    end;
    obj_detail.put('coderror', '200');
    obj_detail.put('codempid', p_codempid_query);
    obj_detail.put('dtereq', to_char(p_dtereq,'dd/mm/yyyy'));
    obj_detail.put('numseq', max_numseq);
    obj_detail.put('codcours', '');
    obj_detail.put('dtetrst', '');
    obj_detail.put('dtetren', '');
    obj_detail.put('dteyear', '');
    obj_detail.put('remark', '');
    obj_detail.put('codhotel', '');
    obj_detail.put('codinsts', '');
    obj_detail.put('codinstruc', '');
    obj_detail.put('numclseq', '');
    obj_detail.put('staappr', '');
    obj_detail.put('qtyhour', '');
    obj_detail.put('codinput', global_v_codempid);
    obj_detail.put('codcomp', v_codcomp);
    obj_detail.put('codcompy', hcm_util.get_codcomp_level(v_codcomp,1));

    json_str_output := obj_detail.to_clob;
  end;

  procedure get_numclseq(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_numclseq(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_numclseq (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;

    max_numseq      number;
    v_flg_thistrnn  boolean;
    v_tyrtrsch      tyrtrsch%rowtype;
    v_codcompy      tcompny.codcompy%type;
  begin
    v_rcnt := 0;
    obj_main        := json_object_t();
    obj_row         := json_object_t();
    obj_detail      := json_object_t();

    begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into v_codcompy
          from temploy1
         where codempid = global_v_codempid;
    exception when no_data_found then
        v_codcompy := null;
    end;

    begin
        select *
          into v_tyrtrsch
          from tyrtrsch
         where numclseq = p_numclseq
           and codcours = p_codcours
           and dteyear = p_dteyear
           and codcompy = v_codcompy
      order by dtetrst desc;     
        v_flg_thistrnn := true;
    exception when no_data_found then
        v_tyrtrsch      := null;
    end;

    obj_detail.put('coderror', '200');
    obj_detail.put('dtetrst', to_char(v_tyrtrsch.dtetrst,'dd/mm/yyyy'));
    obj_detail.put('dtetren', to_char(v_tyrtrsch.dtetren,'dd/mm/yyyy'));
    obj_detail.put('qtyhour', trunc(v_tyrtrsch.qtytrmin/60)||':'||lpad(mod(v_tyrtrsch.qtytrmin,60),2,'0'));
    obj_detail.put('codinstruc', v_tyrtrsch.codinst);
    obj_detail.put('codinsts', v_tyrtrsch.codinsts);
    obj_detail.put('codhotel', v_tyrtrsch.codhotel);
    
    json_str_output := obj_detail.to_clob;
  end;  


  procedure insert_next_step IS
    v_codapp              varchar2(10 char) := 'HRES91E';
    v_codempid_next       temploy1.codempid%type;
    v_approv              temploy1.codempid%type;
    parameter_v_approvno  ttrncerq.approvno%type;
    v_routeno             ttrncerq.routeno%type;
    v_desc                ttrncerq.remarkap%type := substr(get_label_name('HCM_APPRFLW',global_v_lang,10), 1, 200);
    v_table               varchar2(50 char);
    v_error               varchar2(50 char);
  begin
    parameter_v_approvno  :=  0;
    --
    p_dtecancel           := null;
    p_staappr             := 'P';
    chk_workflow.find_next_approve(v_codapp, v_routeno, p_codempid_query, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, global_v_codempid,p_codtparg);

    -- <<
    if v_routeno is null then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'twkflph');
      return;
    end if;
    --
    chk_workflow.find_approval(v_codapp, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, v_table, v_error);
    if v_error is not null then
      param_msg_error := get_error_msg_php(v_error, global_v_lang, v_table);
      return;
    end if;
    -- >>

    loop

      v_codempid_next := chk_workflow.check_next_step2(v_codapp, v_routeno, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, v_codapp, null, parameter_v_approvno, global_v_codempid);

      if v_codempid_next is not null then
         parameter_v_approvno := parameter_v_approvno + 1;
         p_codappr         := v_codempid_next;
         p_staappr         := 'A';
         p_dteappr         := trunc(sysdate);
         p_remarkap        := v_desc;
         p_approvno        := parameter_v_approvno;
         v_approv          := v_codempid_next;

        begin
          insert into taptrcerq (codempid,dtereq,numseq,approvno,
                                 codappr,dteappr,staappr,remark,
                                 dteapph,dtesnd,
                                 dtecreate,codcreate,dteupd,coduser)
                values         (p_codempid_query, p_dtereq2save, p_numseq, parameter_v_approvno, 
                                v_codempid_next, trunc(sysdate), 'A',v_desc, 
                                sysdate,null,
                                sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
          update taptrcerq
             set codappr = v_codempid_next,
                 dteappr = trunc(sysdate),
                 staappr = 'A',
                 remark = v_desc,
                 dteapph = sysdate,
                 coduser   = global_v_coduser,
                 dteupd    = sysdate
           where codempid  = p_codempid_query
             and dtereq    = p_dtereq2save
             and numseq    = p_numseq
             and approvno  = parameter_v_approvno;
        end;

        chk_workflow.find_next_approve(v_codapp, v_routeno, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, v_codempid_next);
      else
        exit;
      end if;
    end loop;
    p_approvno     := parameter_v_approvno;
    p_routeno      := v_routeno;
  end;  

  procedure save_ttrncerq(json_str_input in clob,json_str_output out clob) as
    json_obj                json_object_t;
    v_flg                   varchar2(100 char);

    v_codcours              ttrncanrq.codcours%type;

    v_dteyear               ttrncerq.dteyear%type;
    v_numclseq              ttrncerq.numclseq%type;
    v_desreq                ttrncerq.desreq%type;
    v_codcomp               ttrncanrq.codcomp%type;
    v_qtytrmin              ttrncanrq.qtytrmin%type;
    v_codhotel              ttrncanrq.codhotel%type;
    v_codinst               ttrncanrq.codinst%type;
    v_codinsts              ttrncanrq.codinsts%type;
    v_tyrtrsch              tyrtrsch%rowtype;
    
    v_codcompy              ttrncerq.codcompy%type;
  begin
    json_obj            := json_object_t(json_str_input);
    v_codcours	        := hcm_util.get_string_t(json_obj,'codcours');
--
    v_dteyear           := hcm_util.get_string_t(json_obj,'dteyear');
    v_codcompy          := hcm_util.get_string_t(json_obj,'codcompy');
    v_numclseq          := hcm_util.get_string_t(json_obj,'numclseq');
    v_desreq            := hcm_util.get_string_t(json_obj,'desreq');
    v_codcomp           := hcm_util.get_string_t(json_obj,'codcomp');
    begin
        insert into ttrncerq (codempid,dtereq,numseq,
                              dteyear,codcompy,codcours,numclseq,
                              codcancel,desreq,flgnotic,codcomp,
                              codappr,dteappr,approvno,remarkap,
                              staappr,routeno,flgsend,codinput,
                              dtecancel,dteinput,dtesnd,dteapph,flgagency,
                              dtecreate,codcreate,dteupd,coduser)
        values ( p_codempid_query, p_dtereq2save, p_numseq,
                 v_dteyear, v_codcompy, v_codcours, v_numclseq,
                 null, v_desreq, 'N', v_codcomp,
                 p_codappr, p_dteappr, p_approvno, p_remarkap,
                 p_staappr, p_routeno, 'N', global_v_codempid,
                 sysdate, sysdate, null, sysdate, 'N',
                 sysdate, global_v_coduser, sysdate, global_v_coduser);
    exception when dup_val_on_index then
        update ttrncerq
           set dteyear = v_dteyear,
               codcompy = v_codcompy,
               codcours = v_codcours,
               numclseq = v_numclseq,
               desreq = v_desreq,
               codcomp = v_codcomp,
               codappr = p_codappr,
               dteappr = p_dteappr,
               approvno = p_approvno,
               remarkap = p_remarkap,
               staappr = p_staappr,
               routeno = p_routeno,
               codinput = global_v_codempid,
               dteinput = sysdate,
               dteapph = sysdate,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codempid = p_codempid_query
           and dtereq = p_dtereq2save
           and numseq = p_numseq;
    end;

    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end save_ttrncerq;
  --
  procedure post_save(json_str_input in clob,json_str_output out clob) as
    json_obj                json_object_t;
  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    p_codempid_query    := hcm_util.get_string_t(json_obj,'codempid');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'dtereq'),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj,'numseq');    
    p_dtereq2save       := p_dtereq; 
    
--    check_save(json_str_input);
    if param_msg_error is null then
      insert_next_step;
    end if;
    if param_msg_error is null then
      save_ttrncerq(json_str_input ,json_str_output);
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;  

  procedure save_cancel(json_str_input in clob,json_str_output out clob) as
  begin
    update ttrncerq
       set staappr = 'C',
           dtecancel = sysdate,
           codcancel = global_v_codempid
     where codempid = p_codempid_query
       and dtereq = p_dtereq
       and numseq = p_numseq;
    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end save_cancel;
  --
  procedure post_cancel(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_cancel(json_str_input,json_str_output);
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

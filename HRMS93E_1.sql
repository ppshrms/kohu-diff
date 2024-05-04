--------------------------------------------------------
--  DDL for Package Body HRMS93E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS93E" is
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
    param_json          := hcm_util.get_json_t(json_obj,'param_json');

  end initial_value;
  --
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
          from ttrncanrq
         where dtereq between p_dtestr and p_dteend
           and codcours = nvl(p_codcours,codcours)
           and dteyear = nvl(p_dteyear,dteyear)
           and numclseq = nvl(p_numclseq,numclseq)
      order by dtereq desc, numseq desc;

  begin
    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c1 loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        v_next_codappr := chk_workflow.get_next_approve('HRMS93E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),
                                        r1.numseq, r1.approvno,global_v_lang);

        obj_data.put('coderror', '200');
        obj_data.put('numseq', v_rcnt);
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('codcours', r1.codcours);
        obj_data.put('desc_codcours', get_tcourse_name(r1.codcours,global_v_lang));
        obj_data.put('dteyear', r1.dteyear);
        obj_data.put('numclseq', r1.numclseq);
        obj_data.put('seqno', r1.numseq);
        obj_data.put('status', get_tlistval_name('ESSTAREQ',r1.stappr,global_v_lang));
        obj_data.put('staappr', r1.stappr);
        obj_data.put('remark', r1.remarkap);
        obj_data.put('codappr', r1.codappr || ' - ' || get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('next_codappr', v_next_codappr);

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
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;

    v_qtytrhur      tcourse.qtytrhur%type;
    v_coddevp       tcourse.coddevp%type;
    v_objective     tobjemp.objective%type;
    v_codhotel      tyrtrsch.codhotel%type;
    v_timstrt       ttrsched.timstrt%type;
    v_timend        ttrsched.timend%type;
    v_latitude      thotelif.latitude%type;
    v_longitude     thotelif.longitude%type;
    v_radius        thotelif.radius%type;

    v_tpotentpd     tpotentpd%rowtype;
    v_tyrtrsch      tyrtrsch%rowtype;
    v_next_codappr  varchar2(1000);

    v_thistrnn      thistrnn%rowtype;
    v_plancond      tyrtrpln.plancond%type;
    max_numseq      number;
    v_flg_thistrnn  boolean;
    v_qtyemp        tyrtrsch.qtyemp%type;

	cursor c1 is
		select *
          from ttrncanrq
         where codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq = p_numseq;

  begin
    obj_detail      := json_object_t();
    obj_detail.put('coderror', '200');


    for r1 in c1 loop
        begin
            select qtyemp
              into v_qtyemp
              from tyrtrsch
             where dteyear = r1.dteyear
               and codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
               and codcours = r1.codcours
               and numclseq = r1.numclseq;        
        exception when no_data_found then
            v_qtyemp := 0;
        end;

        obj_detail.put('codempid', r1.codempid);
        obj_detail.put('numseq', r1.numseq);
        obj_detail.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_detail.put('staappr', r1.stappr);
        obj_detail.put('codcours', r1.codcours);
        obj_detail.put('dteyear', r1.dteyear);
        obj_detail.put('numclseq', to_char(r1.numclseq));
        obj_detail.put('dtetrst', to_char(r1.dtetrst,'dd/mm/yyyy'));
        obj_detail.put('dtetren', to_char(r1.dtetren,'dd/mm/yyyy'));
        obj_detail.put('qtytrmin', trunc(r1.qtytrmin/60)||':'||lpad(mod(r1.qtytrmin,60),2,'0'));
        obj_detail.put('codinsts', r1.codinsts);
        obj_detail.put('desc_codinsts', get_tinstitu_name(r1.codinsts, global_v_lang));
        obj_detail.put('codhotel', r1.codhotel);
        obj_detail.put('desc_codhotel', get_thotelif_name(r1.codhotel,global_v_lang));
        obj_detail.put('codinst', r1.codinst);
        obj_detail.put('desc_codinst', get_tinstruc_name(r1.codinst, global_v_lang));
        obj_detail.put('qtyemp', v_qtyemp);
        obj_detail.put('codcancel', r1.codcancel);
        obj_detail.put('desreq', r1.desreq);
        obj_detail.put('codempcanl', r1.codinput);
        obj_detail.put('seqno', '');
        obj_detail.put('codcomp', r1.codcomp);
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
      from ttrncanrq
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
    obj_detail.put('numseq', max_numseq);
    obj_detail.put('dtereq', to_char(p_dtereq,'dd/mm/yyyy'));
    obj_detail.put('staappr', '');
    obj_detail.put('codcours', '');
    obj_detail.put('dteyear', '');
    obj_detail.put('numclseq', '');
    obj_detail.put('dtetrst', '');
    obj_detail.put('dtetren', '');
    obj_detail.put('qtytrmin', '');
    obj_detail.put('codinsts', '');
    obj_detail.put('codhotel', '');
    obj_detail.put('codinst', '');
    obj_detail.put('qtyemp', '');
    obj_detail.put('codcancel', '');
    obj_detail.put('desreq', '');
    obj_detail.put('codempcanl', '');
    obj_detail.put('seqno', '');
    obj_detail.put('codcomp', v_codcomp);

    json_str_output := obj_detail.to_clob;
  end;


  procedure get_codcours(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_codcours(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_codcours (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_codcompy      tcompny.codcompy%type;

    max_numseq      number;
    v_flg_thistrnn  boolean;
    v_tyrtrsch      tyrtrsch%rowtype;
  begin
    v_rcnt          := 0;
    obj_main        := json_object_t();
    obj_row         := json_object_t();
    obj_detail      := json_object_t();

    select hcm_util.get_codcomp_level(codcomp,1)
      into v_codcompy
      from temploy1
     where codempid = global_v_codempid;

    begin
        select *
          into v_tyrtrsch
          from tyrtrsch
         where dteyear = p_dteyear
           and codcompy = v_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq;     
    exception when no_data_found then
        v_tyrtrsch      := null;
    end;

    obj_detail.put('coderror', '200');
    obj_detail.put('dtetrst', to_char(v_tyrtrsch.dtetrst,'dd/mm/yyyy'));
    obj_detail.put('dtetren', to_char(v_tyrtrsch.dtetrst,'dd/mm/yyyy'));
    obj_detail.put('qtytrmin', trunc(v_tyrtrsch.qtytrmin/60)||':'||lpad(mod(v_tyrtrsch.qtytrmin,60),2,'0'));
    obj_detail.put('codinsts', v_tyrtrsch.codinsts);
    obj_detail.put('desc_codinsts', get_tinstitu_name(v_tyrtrsch.codinsts, global_v_lang));
    obj_detail.put('codhotel', v_tyrtrsch.codhotel);
    obj_detail.put('desc_codhotel', get_thotelif_name(v_tyrtrsch.codhotel,global_v_lang));
    obj_detail.put('codinst', v_tyrtrsch.codinst);
    obj_detail.put('desc_codinst', get_tinstruc_name(v_tyrtrsch.codinst, global_v_lang));
    obj_detail.put('qtyemp', v_tyrtrsch.qtyemp);
    obj_detail.put('codempcanl', global_v_codempid);

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
         where codempid = p_codempid_query;
    exception when no_data_found then
        v_codcompy := null;
    end;

    begin
        select *
          into v_tyrtrsch
          from tyrtrsch
         where numclseq = p_numclseq
           and codcours = p_codcours
           and dteyear = to_char(sysdate,'YYYY')
           and codcompy = v_codcompy
      order by dtetrst desc;     
        v_flg_thistrnn := true;
    exception when no_data_found then
        v_tyrtrsch      := null;
    end;

    obj_detail.put('coderror', '200');
    obj_detail.put('codcours',p_codcours);
    obj_detail.put('dtetrst', to_char(v_tyrtrsch.dtetrst,'dd/mm/yyyy'));
    obj_detail.put('dtetren', to_char(v_tyrtrsch.dtetren,'dd/mm/yyyy'));
    obj_detail.put('timst', v_tyrtrsch.timestr);
    obj_detail.put('timen', v_tyrtrsch.timeend);
    obj_detail.put('qtyhour', trunc(v_tyrtrsch.qtytrmin/60)||':'||lpad(mod(v_tyrtrsch.qtytrmin,60),2,'0'));
    obj_detail.put('dteregisst', to_char(v_tyrtrsch.dteregst,'dd/mm/yyyy'));
    obj_detail.put('dteregisen', to_char(v_tyrtrsch.dteregen,'dd/mm/yyyy'));
    obj_detail.put('desc_codhotel', get_thotelif_name(v_tyrtrsch.codhotel,global_v_lang));
    obj_detail.put('desc_codinsts', get_tinstitu_name(v_tyrtrsch.codinsts, global_v_lang));
    obj_detail.put('amtbudg', v_tyrtrsch.amttremp);
    obj_detail.put('daysum', '');
    obj_detail.put('coscent', v_tyrtrsch.costcent);

    json_str_output := obj_detail.to_clob;
  end;  


  procedure insert_next_step IS
    v_codapp              varchar2(10 char) := 'HRMS93E';
    v_codempid_next       temploy1.codempid%type;
    v_approv              temploy1.codempid%type;
    parameter_v_approvno  ttrncanrq.approvno%type;
    v_routeno             ttrncanrq.routeno%type;
    v_desc                ttrncanrq.remarkap%type := substr(get_label_name('HCM_APPRFLW',global_v_lang,10), 1, 200);
    v_table               varchar2(50 char);
    v_error               varchar2(50 char);
  begin
    parameter_v_approvno  :=  0;
    --
    p_dtecancel           := null;
    p_staappr             := 'P';
    chk_workflow.find_next_approve(v_codapp, v_routeno, p_codempid_query, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, global_v_codempid);

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
          insert into taptrcanrq (codempid,dtereq,numseq,approvno,codappr,
                                  dteappr,staappr,remark,dteapph,
                                  dtecreate,codcreate,dteupd,coduser)
                values         (p_codempid_query, p_dtereq2save, p_numseq, parameter_v_approvno, v_codempid_next, 
                                trunc(sysdate), 'A',v_desc, sysdate,
                                sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
          update taptrcanrq
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

  procedure save_ttrncanrq(json_str_input in clob,json_str_output out clob) as
    param_json_row          json_object_t;
    param_json_child        json_object_t;
    param_json_row_child    json_object_t;
    file_json               json_object_t;
    v_flg                   varchar2(100 char);

    v_codcours              ttrncanrq.codcours%type;

    v_dtetrst               ttrncanrq.dtetrst%type;
    v_dtetren               ttrncanrq.dtetren%type;
    v_dteyear               ttrncanrq.dteyear%type;
    v_numclseq              ttrncanrq.numclseq%type;
    v_codcancel             ttrncanrq.codcancel%type;
    v_desreq                ttrncanrq.desreq%type;
    v_codcomp               ttrncanrq.codcomp%type;
    v_qtytrmin              ttrncanrq.qtytrmin%type;
    v_codhotel              ttrncanrq.codhotel%type;
    v_codinst               ttrncanrq.codinst%type;
    v_codinsts              ttrncanrq.codinsts%type;
    v_tyrtrsch              tyrtrsch%rowtype;

  begin
    v_codcours	        := hcm_util.get_string_t(param_json,'codcours');

    v_dteyear           := hcm_util.get_string_t(param_json,'dteyear');
    v_numclseq          := hcm_util.get_string_t(param_json,'numclseq');
    v_codcancel         := hcm_util.get_string_t(param_json,'codcancel');
    v_desreq            := hcm_util.get_string_t(param_json,'desreq');
    v_codcomp           := hcm_util.get_string_t(param_json,'codcomp');
    v_dtetrst	        := to_date(hcm_util.get_string_t(param_json,'dtetrst'),'dd/mm/yyyy');
    v_dtetren	        := to_date(hcm_util.get_string_t(param_json,'dtetren'),'dd/mm/yyyy');
    v_qtytrmin          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(param_json,'qtytrmin'));
    v_codhotel          := hcm_util.get_string_t(param_json,'codhotel');
    v_codinst           := hcm_util.get_string_t(param_json,'codinst');
    v_codinsts          := hcm_util.get_string_t(param_json,'codinsts');    

    begin
        select *
          into v_tyrtrsch
          from tyrtrsch 
         where dteyear = v_dteyear
           and codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and codcours = v_codcours
           and numclseq = v_numclseq;
    exception when no_data_found then
        v_tyrtrsch := null;
    end;

    begin
        insert into ttrncanrq (codempid,dtereq,numseq,
                               codcours,dteyear,numclseq,codcancel,desreq,
                               codcomp,codappr,dteappr,approvno,remarkap,
                               stappr,routeno,
                               codinput,dtecancel,dteinput,dtesnd,dteapph,
                               dtetrst,dtetren,timestr,timeend,qtytrmin,
                               codhotel,codinst,codinsts,
                               dtecreate,codcreate,dteupd,coduser)
        values ( p_codempid_query,p_dtereq2save,p_numseq,
                 v_codcours,v_dteyear,v_numclseq,v_codcancel,v_desreq,
                 v_codcomp,p_codappr,p_dteappr,p_approvno,p_remarkap,
                 p_staappr,p_routeno,
                 global_v_codempid,sysdate,sysdate,null,sysdate,
                 v_dtetrst,v_dtetren,v_tyrtrsch.timestr,v_tyrtrsch.timeend,v_tyrtrsch.qtytrmin,
                 v_codhotel,v_codinst,v_codinsts,
                 sysdate,global_v_coduser,sysdate,global_v_coduser);
    exception when dup_val_on_index then
        update ttrncanrq
           set codcours = v_codcours,
               dteyear = v_dteyear,
               numclseq = v_numclseq,
               codcancel = v_codcancel,
               desreq = v_desreq,
               codcomp = v_codcomp,
               codappr = p_codappr,
               dteappr = p_dteappr,
               approvno = p_approvno,
               remarkap = p_remarkap,
               stappr = p_staappr,
               routeno = p_routeno,
               codinput = global_v_codempid,
               dtetrst = v_dtetrst,
               dtetren = v_dtetren,
               timestr = v_tyrtrsch.timestr,
               timeend = v_tyrtrsch.timeend,
               qtytrmin = v_tyrtrsch.qtytrmin,
               codhotel = v_codhotel,
               codinst = v_codinst,
               codinsts = v_codinsts,
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
  end save_ttrncanrq;
  --
  procedure post_save(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    p_dtereq2save       := p_dtereq;    
--    check_save;
    if param_msg_error is null then
      insert_next_step;
    end if;
    if param_msg_error is null then
      save_ttrncanrq(json_str_input ,json_str_output);
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
    update ttrncanrq
       set stappr = 'C',
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

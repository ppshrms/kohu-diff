--------------------------------------------------------
--  DDL for Package Body HRMS6JU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS6JU" is
-- last update: 27/09/2022 10:44

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_registeren        := hcm_util.get_string_t(json_obj,'p_registeren');
    p_registerst        := hcm_util.get_string_t(json_obj,'p_registerst');
    p_latitude          := hcm_util.get_string_t(json_obj,'p_latitude');
    p_longitude         := hcm_util.get_string_t(json_obj,'p_longitude');
    param_json          := hcm_util.get_json_t(json_obj,'param_json');

    p_dtereqst          := to_date(hcm_util.get_string_t(json_obj,'p_dtest'),'ddmmyyyy');
    p_dtereqen          := to_date(hcm_util.get_string_t(json_obj,'p_dteen'),'ddmmyyyy');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');

    p_dteyear           := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_numclseq          := hcm_util.get_string_t(json_obj,'p_numclseq');
    p_codcours          := hcm_util.get_string_t(json_obj,'p_codcours');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'ddmmyyyy');

    p_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'ddmmyyyy');
    p_flgConfirm        := hcm_util.get_string_t(json_obj,'p_flgconfirm');
    p_remarkap          := hcm_util.get_string_t(json_obj,'p_remark_not_appr');

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
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;

    v_qtytrhur      tcourse.qtytrhur%type;
    v_coddevp       tcourse.coddevp%type;
    v_objective     tobjemp.objective%type;
    v_codhotel      tyrtrsch.codhotel%type;
    v_timstrt       ttrsched.timstrt%type;
    v_timend        ttrsched.timend%type;

    v_tpotentpd     tpotentpd%rowtype;
    v_next_codappr  varchar2(1000);
    v_qtyapprovno   number;
    v_statuscc      varchar2(1);
    v_flgdata       varchar2(1) := 'N';
    v_appno         number := 0;
    v_plancond      tyrtrpln.plancond%type;
    v_tyrtrsch      tyrtrsch%rowtype;
    v_thistrnn      thistrnn%rowtype;
    v_flg_thistrnn  boolean;
    
    v_codempid      thistrnn.codempid%type;
    v_codcours      thistrnn.codcours%type;

    cursor c1 is
		select *
          from ttrnreq a
         where a.codempid = nvl(p_codempid_query,a.codempid)
           and decode(a.staappr,'A','P',a.staappr) = nvl(p_staappr,decode(a.staappr,'A','P',a.staappr))
           and ((p_staappr in ('Y','N') and trunc(a.dteappr) between nvl(trunc(p_dtereqst),a.dteappr) and nvl(trunc(p_dtereqen),a.dteappr)) or (p_staappr = 'P'))
           and ('Y' = chk_workflow.check_privilege('HRES6IE',
                            a.codempid,
                            a.dtereq,
                            a.numseq,
                            nvl(a.approvno,0)+1,
                            global_v_codempid)
                or ((routeno,nvl(approvno,0)+1) in (select routeno,numseq
                                                      from twkflowde c
                                                     where c.routeno = a.routeno
                                                       and c.codempid = global_v_codempid)
                     and ((sysdate - nvl(a.dteapph,a.dteinput))*1440 >= (select hrtotal from twkflpf where codapp = 'HRES6IE'))))
        order by codempid,dtereq desc,numseq ;
        
   cursor c2 is
    select *
      from thistrnn
     where codempid = v_codempid
       and codcours = v_codcours
  order by dtetrst desc;

  begin
    v_rcnt := 0;
    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata   := 'Y';
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid,global_v_lang));
        obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
        obj_data.put('numseq',i.numseq);
        obj_data.put('numclseq',to_char(i.numclseq));
        if i.codcours is null then
            obj_data.put('desc_codcours', i.namcourse);
        else
            obj_data.put('desc_codcours', get_tcourse_name(i.codcours,global_v_lang));
        end if;
        obj_data.put('namcourse',get_tlistval_name('CODTPARG',i.codtparg,global_v_lang));
        obj_data.put('status',get_tlistval_name('ESSTAREQ',i.staappr,global_v_lang));
        obj_data.put('staapprcc',i.staappr);
        begin
            select approvno
              into v_qtyapprovno
              from twkflowh
             where routeno = i.routeno;
        exception when no_data_found then
            v_qtyapprovno := null;
        end;
        v_appno   := nvl(i.approvno,0)+1;
        if v_appno = v_qtyapprovno then
            v_statuscc := 'E';
        else
            v_statuscc := 'N';
        end if;
        obj_data.put('chk_appr',v_statuscc);--Y-- Final Approve
        obj_data.put('desc_codappr', get_temploy_name(i.codappr,global_v_lang));
        obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
        obj_data.put('remark',i.remarkap);
        v_next_codappr := chk_workflow.get_next_approve('HRES6IE',i.codempid,to_char(i.dtereq,'dd/mm/yyyy'),i.numseq,i.approvno,global_v_lang);
        obj_data.put('desc_codempap',v_next_codappr);
        obj_data.put('approvno',v_appno);
        
        
        -- user18 2022/03/28
        begin
            select plancond
              into v_plancond
              from tyrtrpln
             where dteyear = i.dteyear
               and codcompy = hcm_util.get_codcomp_level(i.codcomp,1)
               and codcours = i.codcours;
        exception when no_data_found then
            v_plancond := null;
        end;

        begin
            select *
              into v_tyrtrsch
              from tyrtrsch
             where dteyear = i.dteyear
               and codcompy = hcm_util.get_codcomp_level(i.codcomp,1)
               and codcours = i.codcours
               and numclseq = i.numclseq;
        exception when no_data_found then
            v_tyrtrsch := null;
        end;
        
        v_codempid  := i.codempid;
        v_codcours  := i.codcours;
        v_flg_thistrnn := false;
        v_thistrnn     := null;
        for r2 in c2 loop
            v_thistrnn.dtetrst      := r2.dtetrst;
            v_thistrnn.dtetren      := r2.dtetren;
            v_thistrnn.numclseq     := r2.numclseq;
            v_flg_thistrnn          := true;
            exit;
        end loop;
        
        obj_data.put('codtparg',i.codtparg);
        obj_data.put('codcours',i.codcours);
        obj_data.put('codcompy',hcm_util.get_codcomp_level(i.codcomp,1));
        obj_data.put('dteyear',i.dteyear);
        obj_data.put('source',get_tlistval_name('STACOURS',v_plancond,global_v_lang));
        obj_data.put('otrain',i.staemptr);
        obj_data.put('dteregisst',to_char(v_tyrtrsch.dteregst,'dd/mm/yyyy'));
        obj_data.put('dteregisen',to_char(v_tyrtrsch.dteregen,'dd/mm/yyyy'));
        obj_data.put('dtetrst', to_char(i.dtetrst,'dd/mm/yyyy'));
        obj_data.put('dtetren', to_char(i.dtetren,'dd/mm/yyyy'));
        obj_data.put('timst', to_char(to_date(i.timestr,'hh24:mi'),'hh24mi'));
        obj_data.put('timen', to_char(to_date(i.timeend,'hh24:mi'),'hh24mi'));
        obj_data.put('qtyhour',trunc(i.qtytrmin/60)||':'||lpad(mod(i.qtytrmin,60),2,'0'));

        if i.codhotel is null then
            obj_data.put('desc_codhotel', i.namhotel);
        else
            obj_data.put('desc_codhotel', get_thotelif_name(i.codhotel,global_v_lang));
        end if;

        if i.codinsts is null then
            obj_data.put('desc_codinsts', i.naminsts);
        else
            obj_data.put('desc_codinsts', get_tinstitu_name(i.codinsts, global_v_lang));
        end if;
        if v_flg_thistrnn then
            obj_data.put('attend', 'Y');
        else
            obj_data.put('attend', 'N');
        end if;
        obj_data.put('dtetrsto', to_char(v_thistrnn.dtetrst,'dd/mm/yyyy'));
        obj_data.put('dtetreno', to_char(v_thistrnn.dtetren,'dd/mm/yyyy'));
        obj_data.put('numclseq1', to_char(v_thistrnn.numclseq));
        obj_data.put('amtbudg', i.amttremp);
        obj_data.put('daysum', i.qtytrflw);
        obj_data.put('coscent', i.costcent);
        obj_data.put('dtepay', to_char(i.dteduepay,'dd/mm/yyyy'));
        obj_data.put('flgreq', i.flgreq);
        -- user18 2022/03/28
        
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end;
  --

  procedure get_tyrtrsch(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tyrtrsch(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_tyrtrsch (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;

    v_tyrtrsch      tyrtrsch%rowtype;
    v_plancond      tyrtrpln.plancond%type;
    v_thistrnn      thistrnn%rowtype;
    v_flg_thistrnn  boolean;
    v_chk           varchar2(1);
    v_numclseq       tyrtrsch.numclseq%type;
        
   cursor c1 is
    select *
      from thistrnn
     where codempid = p_codempid_query
       and codcours = p_codcours
  order by dtetrst desc;

  begin
    v_rcnt := 0;
    obj_main        := json_object_t();
    obj_row         := json_object_t();
    obj_detail      := json_object_t();   

    begin
        select *
          into v_tyrtrsch
          from tyrtrsch
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq;
    exception when no_data_found then
        null;
    end;

    begin
        select plancond 
          into v_plancond
          from tyrtrpln
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and codcours = p_codcours;
    exception when no_data_found then
        v_plancond := null;
    end;

    v_flg_thistrnn := false;
    v_thistrnn     := null;
    for r1 in c1 loop
        v_thistrnn.dtetrst      := r1.dtetrst;
        v_thistrnn.dtetren      := r1.dtetren;
        v_thistrnn.numclseq     := r1.numclseq;
        v_flg_thistrnn          := true;
        exit;
    end loop;
    begin
        select 'Y'
          into v_chk
          from tyrtrsch
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq
           and nvl(flgconf,'X') <> 'C' ;
    exception when no_data_found then
        v_chk := 'N';
    end;
    
    if v_chk = 'Y' then
        v_numclseq   := p_numclseq;
    else
        v_numclseq   := 0;
    end if;

    obj_detail.put('coderror', '200');
    obj_detail.put('codcours', p_codcours);
    obj_detail.put('numclseq', to_char(v_numclseq));
    obj_detail.put('dteyear', p_dteyear);
    obj_detail.put('desc_codcours', get_tcourse_name(p_codcours,global_v_lang));
    obj_detail.put('staemptr', v_tyrtrsch.staemptr);
    obj_detail.put('otrain', v_tyrtrsch.staemptr);
    obj_detail.put('dteregisst', to_char(v_tyrtrsch.dteregst,'dd/mm/yyyy'));
    obj_detail.put('dteregisen', to_char(v_tyrtrsch.dteregen,'dd/mm/yyyy'));
    obj_detail.put('dtetrst', to_char(v_tyrtrsch.dtetrst,'dd/mm/yyyy'));
    obj_detail.put('dtetren', to_char(v_tyrtrsch.dtetren,'dd/mm/yyyy'));
    obj_detail.put('timst', to_char(to_date(v_tyrtrsch.timestr,'hh24:mi'),'hh24mi'));
    obj_detail.put('timen', to_char(to_date(v_tyrtrsch.timeend,'hh24:mi'),'hh24mi'));
    obj_detail.put('qtyhour', trunc(v_tyrtrsch.qtytrmin/60)||':'||lpad(mod(v_tyrtrsch.qtytrmin,60),2,'0'));
    obj_detail.put('codhotel',v_tyrtrsch.codhotel);
    obj_detail.put('desc_codhotel', get_thotelif_name(v_tyrtrsch.codhotel,global_v_lang));
    obj_detail.put('codinsts',v_tyrtrsch.codinsts);
    obj_detail.put('desc_codinsts', get_tinstitu_name(v_tyrtrsch.codinsts, global_v_lang));
    obj_detail.put('amtbudg', v_tyrtrsch.amttremp);
    obj_detail.put('coscent', v_tyrtrsch.costcent);
    obj_detail.put('codtparg', v_tyrtrsch.codtparg);
    obj_detail.put('source', get_tlistval_name('STACOURS',v_plancond,global_v_lang));
    if v_flg_thistrnn then 
        obj_detail.put('attend', 'Y');
    else
        obj_detail.put('attend', 'N');
    end if;
    obj_detail.put('dtetrsto', to_char(v_thistrnn.dtetrst,'dd/mm/yyyy'));
    obj_detail.put('dtetreno', to_char(v_thistrnn.dtetren,'dd/mm/yyyy'));
    obj_detail.put('numclseq1', to_char(v_thistrnn.numclseq));

    json_str_output := obj_detail.to_clob;
  end;

  procedure save_approve(json_str_input in clob,json_str_output out clob) as
    param_json_row          json_object_t;
    param_json_child        json_object_t;
    param_json_row_child    json_object_t;
    file_json               json_object_t;
    v_flg                   varchar2(100 char);

    v_dtetrst               ttrnreq.dtetrst%type;
    v_dtetren               ttrnreq.dtetren%type;
    v_amtbudg               ttrnreq.amttremp%type;
    v_remark                ttrnreq.remark%type;
    v_staappr               ttrnreq.staappr%type;
    v_codinput              ttrnreq.codinput%type;
--    v_filename              ttrnreq.%type;
    v_place                 ttrnreq.namhotel%type;
    v_desc_codinsts         ttrnreq.naminsts%type;
--    v_name_codinput         ttrnreq.%type;
    v_codtparg              ttrnreq.codtparg%type;
--    v_codcompy              ttrnreq.%type;
    v_codcomp               ttrnreq.codcomp%type;
    v_dteduepay             ttrnreq.dteduepay%type;
    v_costcent              ttrnreq.costcent%type;
    v_flgreq                ttrnreq.flgreq%type;
    v_filename              ttrnreqf.filename%type;
    v_descfile              ttrnreqf.descfile%type;
    v_seqno                 ttrnreqf.seqno%type;

    v_ttrnreq               ttrnreq%rowtype;
    v_temploy1              temploy1%rowtype;

    v_codapp                varchar2(10 char) := 'HRES6IE';
    v_codempid_next         temploy1.codempid%type;
    v_approv                temploy1.codempid%type;
    parameter_v_approvno    ttrnreq.approvno%type;
    v_routeno               ttrnreq.routeno%type;
    v_desc                  ttrnreq.remarkap%type := substr(get_label_name('HCM_APPRFLW',global_v_lang,10), 1, 200);
    p_codappr               temploy1.codempid%type := pdk.Check_Codempid(global_v_coduser);
    v_table                 varchar2(50 char);
    v_error                 varchar2(50 char);
    v_max_approv            number;
    v_approvno              number;
    v_chk                   varchar2(1 char);
    v_count                 number;
    v_numclseq              number;
    v_timestr               varchar2(4 char);
    v_timeend               varchar2(4 char);
    v_amtcost               number;
    v_qtytrflw              number;
    v_row_id                varchar2(200 char);
    v_numseq                number;
    v_staemptr              ttrnreq.staemptr%type;
    v_codhotel              ttrnreq.codhotel%type;
    v_codinsts              ttrnreq.codinsts%type;
    v_qtytrhr	            number;
    v_qtytrmin	            number;
    v_codeappr              temploy1.codempid%type;
    
    v_tyrtrsch              tyrtrsch%rowtype;

    cursor c1 is
        select seqno,filename,descfile
          from ttrnreqf
         where codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq = p_numseq
      order by seqno;
  begin
    file_json           := json_object_t(json_str_input);--hcm_util.get_json_t(param_json,'table');
--    v_codtparg          := hcm_util.get_string_t(file_json,'codtparg');
--    v_staemptr          := hcm_util.get_string_t(file_json,'staemptr');
    v_dtetrst	        := to_date(hcm_util.get_string_t(param_json,'dtetrst'),'dd/mm/yyyy');
    v_dtetren	        := to_date(hcm_util.get_string_t(param_json,'dtetren'),'dd/mm/yyyy');
    v_ttrnreq.costcent  := hcm_util.get_string_t(param_json,'coscent');
--    v_timestr           := hcm_util.get_string_t(file_json,'timestr');
--    v_timeend           := hcm_util.get_string_t(file_json,'timeend');
    v_qtytrmin	        := hcm_util.convert_hour_to_minute (hcm_util.get_string_t(param_json,'qtytrhr'))/60;
--    v_codhotel          := hcm_util.get_string_t(file_json,'codhotel');
--    v_codinsts          := hcm_util.get_string_t(file_json,'codinsts');
    v_amtcost	        := to_number(hcm_util.get_string_t(param_json,'amtbudg'));
    v_qtytrflw	        := nvl(to_number(hcm_util.get_string_t(param_json,'daysum')),0)/30;

    begin
        select *
          into v_ttrnreq
          from ttrnreq
         where codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq = p_numseq;
    exception when no_data_found then 
        v_ttrnreq := null;
    end;
    
    if v_ttrnreq.flgreq = '1' then
        v_tyrtrsch.dteregen   := to_date(hcm_util.get_string_t(file_json,'dteregisen'),'dd/mm/yyyy');
        if p_dteappr > v_tyrtrsch.dteregen then
          param_msg_error := get_error_msg_php('ES0061', global_v_lang);
          return;
        end if;
    end if;

    begin
        select rowid
          into v_row_id
          from ttrnreq
         where codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq = p_numseq;
    exception when no_data_found then 
        v_ttrnreq := null;
    end;

    chk_workflow.find_next_approve(v_codapp, v_routeno, p_codempid_query, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, v_ttrnreq.approvno, global_v_codempid,v_ttrnreq.codtparg);

    if v_routeno is null then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'twkflph');
      return;
    end if;

    begin
        select approvno into v_max_approv
          from twkflowh
         where routeno = v_ttrnreq.routeno ;
    exception when no_data_found then
        v_max_approv := 0 ;
    end;  

    --if nvl(v_ttrnreq.approvno,0)+1 = 
    v_approvno := nvl(v_ttrnreq.approvno,0) + 1 ;

    begin
        select count(*) into v_count
          from taptrnrq
         where codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq = p_numseq
           and approvno = v_approvno;
    exception when no_data_found then
        v_count := 0;
    end;

    if v_count = 0 then
        insert into taptrnrq(codempid,dtereq,numseq,approvno,
                             dteyear,codcompy,codcours,numclseq,
                             staappr,remark,dteapph,dtesnd,
                             codappr,dteappr,dtecreate,codcreate,
                             dteupd,coduser)
              values(p_codempid_query,p_dtereq,p_numseq,v_approvno,
                     p_dteyear,p_codcompy,p_codcours,p_numclseq,
                     v_staappr,p_remarkap,sysdate,null,
                     global_v_codempid,sysdate,sysdate,global_v_coduser,
                     sysdate,global_v_coduser);
    else
        update taptrnrq
           set dteyear    = p_dteyear,
               codcompy   = p_codcompy,
               codcours   = p_codcours,
               numclseq   = p_numclseq,
               staappr    = v_staappr,
               remark     = p_remarkap,
               codappr    = global_v_codempid,
               dteappr    = p_dteappr,
               dteapph    = trunc(sysdate),
               coduser    = global_v_coduser,
               dteupd     = sysdate
         where codempid = p_codempid_query
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and approvno = v_approvno;
    end if;

    if nvl(v_ttrnreq.approvno,0)+1 = v_max_approv then --Approve Final
        v_staappr := 'Y';
        begin
            select *
              into v_temploy1
              from temploy1
             where codempid = p_codempid_query;
        exception when no_data_found then 
            v_temploy1 := null;
        end;
        if p_codtparg = 1 then -- 1-in, 2-out
            begin
                select 'Y'
                  into v_chk
                  from tyrtrsch
                 where dteyear = p_dteyear
                   and codcompy = p_codcompy
                   and codcours = p_codcours
                   and numclseq = p_numclseq
                   and flgconf <> 'C' ;
            exception when no_data_found then
                v_chk := 'N';
            end;
            if v_chk = 'N' then
                param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tyrtrsch');
                return;
            end if;

            if v_ttrnreq.flgreq = '2' then --1-confrim 2-request
                begin
                    insert into tpotentp(dteyear,codcompy,numclseq,codcours,
                                         codempid,codcomp,codpos,numlvl,
                                         codtparg,flgatend,dtetrst,dtetren,
                                         stacours,flgwait,dteyearn,numclsn,
                                         remarkap,dteappr,codappr,staappr,
                                         staconfm,dteregis,dteapprm,costcent,
                                         flgqlify,dtecreate,codcreate,dteupd,coduser)
                                values  (p_dteyear,p_codcompy,p_numclseq,p_codcours,
                                         p_codempid_query,v_ttrnreq.codcomp,v_temploy1.codpos,v_temploy1.numlvl,
                                         p_codtparg,'N',v_dtetrst,v_dtetren,
                                         'S','N',null,null,
                                         null,null,null,'P',
                                         'Y',null,p_dteappr,v_ttrnreq.costcent,
                                         'N',sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when others then null;
                end;
            else --v_ttrnreq.flgreq = '1'
                update tpotentp
                   set dteregis = v_ttrnreq.dteinput,
                       dteupd   = sysdate,
                       coduser  = global_v_coduser
                 where dteyear = p_dteyear
                   and codcompy = p_codcompy
                   and codcours = p_codcours
                   and numclseq = p_numclseq;
            end if;
        else--2-Out 
            begin
                select numclseq
                  into v_numclseq
                  from thistrnn
                 where codempid = p_codempid_query
                   and dteyear = p_dteyear
                   and codcours = p_codcours
                   and dtetrst = v_dtetrst;
            exception when no_data_found then
                select max(numclseq)
                  into v_numclseq
                  from thistrnn
                 where codempid = p_codempid_query
                   and dteyear = p_dteyear
                   and codcours = p_codcours;
                v_numclseq := nvl(v_numclseq,0) + 1;   
            end;
--            v_numclseq := nvl(v_numclseq,0) + 1;
            begin
                insert into thistrnn(codempid,dteyear,codcours,numclseq,
                                     dtemonth,codpos,codcomp,codtparg,
                                     flgtrevl,qtyprescr,qtyposscr,remarks,
                                     codhotel,codinsts,codinst,naminse,
                                     naminst,namins3,namins4,namins5,
                                     dtetrst,dtetren,timestr,timeend,
                                     qtytrmin,amtcost,numcert,dtecert,
                                     typtrain,descomptr,qtytrflw,dtetrflw,
                                     flgcommt,dtecomexp,descommt,descommtn,
                                     content,flgtrain,desfollow,dtecrte,
                                     dtecntr,costcent,qtytrpln,pcttr,
                                     dtecreate,codcreate,dteupd,coduser
                                    )
                            values  (
                                     p_codempid_query,p_dteyear,p_codcours,v_numclseq,
                                     to_number(to_char(v_dtetrst,'mm')),v_temploy1.codpos,v_ttrnreq.codcomp,'2',
                                     null,null,null,p_remarkap,
                                     null,null,null,null,
                                     null,null,null,null,
                                     v_dtetrst,v_dtetren,v_timestr,v_timeend,
                                     v_qtytrmin,v_amtcost,null,null,
                                     null,null,v_qtytrflw,add_months(v_dtetren,v_qtytrflw),
                                     'N',null,null,null,
                                     null,'N',null,null,
                                     null,v_ttrnreq.costcent,null,null,
                                     sysdate,global_v_coduser,sysdate,global_v_coduser
                                    );
            exception when others then null;
            end;

            begin
                select max(numseq)
                  into v_numseq
                  from thistrnf
                 where codempid = p_codempid_query
                   and dteyear  = p_dteyear
                   and codcours = p_codcours
                   and numclseq = v_numclseq;
            exception when no_data_found then 
                v_numseq := 0;
            end;

            for i in c1 loop
                v_numseq := nvl(v_numseq,0)+1;
                begin
                    insert into thistrnf(codempid,dteyear,codcours,numclseq,
                                         numseq,filename,descfile,dtecreate,
                                         codcreate,dteupd,coduser
                                        )
                                values  (p_codempid_query,p_dteyear,p_codcours,v_numclseq,
                                         v_numseq,i.filename,i.descfile,sysdate,
                                         global_v_coduser,sysdate,global_v_coduser
                                        );
                exception when others then null;
                end;
            end loop;
        end if;

        update ttrnreq
           set /*dteyear = p_dteyear,
               codcours = p_codcours,
               numclseq = p_numclseq,
               codtparg = v_codtparg,
               staemptr = v_staemptr,*/
               codappr  = global_v_codempid,
               /*dtetrst  = v_dtetrst,
               dtetren  = v_dtetren,
               timestr  = v_timestr,
               timeend  = v_timeend,
               qtytrmin = v_qtytrmin,
               codhotel = v_codhotel,
               codinsts = v_codinsts,
               amttremp = v_amtcost,
               qtytrflw = v_qtytrflw,*/
               dteappr  = p_dteappr,
               approvno = p_approvno,
               staappr  = 'Y',
               remarkap = p_remarkap,
               dteapph  = sysdate,
               dteupd   = sysdate,
               coduser  = global_v_coduser
         where codempid = p_codempid_query
           and dtereq   = p_dtereq
           and numseq   =  p_numseq;
    else
        v_staappr := 'A';
        v_count   := 0;

        chk_workflow.find_next_approve('HRES6IE',v_ttrnreq.routeno,p_codempid_query,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,global_v_codempid);

        loop
          v_approv := chk_workflow.check_next_step('HRES6IE',v_ttrnreq.routeno,p_codempid_query,p_dteyear,p_numseq,v_approvno,global_v_codempid);
          if  v_approv is not null then
            v_remark   := v_desc;
            v_approvno := v_approvno + 1 ;
            v_codeappr := v_approv ;
            begin
              select  count(*) into v_count
               from   taptrnrq
               where  codempid = p_codempid_query
               and    dtereq   = p_dtereq
               and    numseq   = p_numseq
               and    approvno = v_approvno;
            exception when no_data_found then  v_count := 0;
            end;
            if v_count = 0 then
              insert into taptrnrq
                    (codempid,dtereq,numseq,approvno,
                     dteyear,codcompy,codcours,numclseq,
                     staappr,remark,dteapph,dtesnd,
                     codappr,dteappr,dtecreate,codcreate,
                     dteupd,coduser
                     )
              values(
                     p_codempid_query,p_dtereq,p_numseq,v_approvno,
                     p_dteyear,p_codcompy,p_codcours,p_numclseq,
                     v_staappr,p_remarkap,sysdate,null,
                     v_codeappr,sysdate,sysdate,global_v_coduser,
                     sysdate,global_v_coduser
                     );
            else
              update taptrnrq
                 set dteyear    = p_dteyear,
                     codcompy   = p_codcompy,
                     codcours   = p_codcours,
                     numclseq   = p_numclseq,
                     staappr    = v_staappr,
                     remark     = p_remarkap,
                     codappr    = v_codeappr,
                     dteappr    = to_date(sysdate,'dd/mm/yyyy'),
                     dteapph    = sysdate,
                     coduser    = global_v_coduser,
                     dteupd     = sysdate
               where codempid = p_codempid_query
                 and dtereq   = p_dtereq
                 and numseq   = p_numseq
                 and approvno = v_approvno;
            end if;
            chk_workflow.find_next_approve('HRES6IE',v_ttrnreq.routeno,p_codempid_query,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,global_v_codempid);
          else
            exit ;
          end if;
        end loop ;

        update ttrnreq
           set codappr   = global_v_codempid,
               dteappr   = p_dteappr,
               approvno  = v_approvno,
               staappr   = v_staappr,
               remarkap  = p_remarkap,
               dteapph   = sysdate,
               dteupd   = sysdate,
               coduser  = global_v_coduser
         where codempid  = p_codempid_query
           and dtereq    = p_dtereq
           and numseq   =  p_numseq;
    end if;

    commit;

    --sendmail
    begin 
      chk_workflow.sendmail_to_approve( p_codapp        => 'HRES6IE',
                                        p_codtable_req  => 'ttrnreq',
                                        p_rowid_req     => v_row_id,
                                        p_codtable_appr => 'taptrnrq',
                                        p_codempid      => p_codempid_query,
                                        p_dtereq        => p_dtereq,
                                        p_seqno         => p_numseq,
                                        p_staappr       => v_staappr,
                                        p_approvno      => v_approvno,
                                        p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                        p_subject_mail_numseq  => '60',
                                        p_lang          => global_v_lang,
                                        p_coduser       => global_v_coduser);
    exception when others then
      param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
    end;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end save_approve;
  --
  procedure approve(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    p_codempid_query	:= hcm_util.get_string_t(param_json,'codempid');
    p_dtereq	        := to_date(hcm_util.get_string_t(param_json,'dtereq'),'dd/mm/yyyy');
    p_codcours	        := hcm_util.get_string_t(param_json,'codcours');
    p_numclseq	        := hcm_util.get_string_t(param_json,'numclseq');
    p_dteyear	        := hcm_util.get_string_t(param_json,'dteyear');
    p_codcompy	        := hcm_util.get_string_t(param_json,'codcompy');
    p_dtereq2save       := p_dtereq;    
    p_numseq            := hcm_util.get_string_t(param_json,'numseq');
    p_codtparg	        := hcm_util.get_string_t(param_json,'codtparg');
    p_dteappr	        := to_date(hcm_util.get_string_t(param_json,'dteappr'),'dd/mm/yyyy');
    p_approvno          := hcm_util.get_string_t(param_json,'approvno');
    if param_msg_error is null then
      save_approve(json_str_input ,json_str_output);
    end if;
    
    if param_msg_error is not null then
      rollback;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      if param_msg_error_mail is not null then
        json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    end if;
    
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;  

  procedure save_notapprove(json_str_input in clob,json_str_output out clob) as
    v_ttrnreq   ttrnreq%rowtype;
    json_input      json_object_t;
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_codempid      temploy1.codempid%type;
    v_dtereq        ttrnreq.dtereq%type;
    v_numseq        ttrnreq.numseq%type;
    v_approvno      ttrnreq.approvno%type;
    v_count         number;
  begin
    json_input    := json_object_t(json_str_input);
    param_json    := hcm_util.get_json_t(json_input,'param_json');
    for i in 0..(param_json.get_size - 1) loop
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_codempid        := hcm_util.get_string_t(param_json_row,'p_codempid');
      v_dtereq          := to_date(hcm_util.get_string_t(param_json_row,'p_dtereq'),'dd/mm/yyyy');
      v_numseq          := hcm_util.get_string_t(param_json_row,'p_numseq');
      v_approvno        := hcm_util.get_string_t(param_json_row,'p_approvno');

      begin
        select count(*)
          into v_count
          from taptrnrq
         where codempid = v_codempid
           and dtereq = v_dtereq
           and numseq = v_numseq
           and approvno = v_approvno;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        insert into taptrnrq(codempid,dtereq,numseq,approvno,
                             dteyear,codcompy,codcours,numclseq,
                             staappr,remark,dteapph,dtesnd,
                             codappr,dteappr,dtecreate,codcreate,
                             dteupd,coduser)
              values(v_codempid,v_dtereq,v_numseq,v_approvno,
                     null,null,null,null,
                     'N',p_remarkap,sysdate,null,
                     global_v_codempid,sysdate,sysdate,global_v_coduser,
                     sysdate,global_v_coduser);
      else
        update taptrnrq
           set dteyear    = null,
               codcompy   = null,
               codcours   = null,
               numclseq   = null,
               staappr    = 'N',
               remark     = p_remarkap,
               codappr    = global_v_codempid,
               dteappr    = sysdate,
               dteapph    = trunc(sysdate),
               coduser    = global_v_coduser,
               dteupd     = sysdate
         where codempid = v_codempid
           and dtereq   = v_dtereq
           and numseq   = v_numseq
           and approvno = v_approvno;
      end if;
    
      update ttrnreq
         set codappr   = global_v_codempid,
             dteappr   = trunc(sysdate),
             approvno  = v_approvno,
             staappr   = 'N',
             remarkap  = p_remarkap,
             dteapph   = trunc(sysdate),
             dteupd    = sysdate,
             coduser   = global_v_coduser
       where codempid  = v_codempid
         and dtereq    = v_dtereq
         and numseq    = v_numseq;
    end loop;
    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end save_notapprove;
  --
  procedure notapprove(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_notapprove(json_str_input,json_str_output);
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

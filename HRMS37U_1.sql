--------------------------------------------------------
--  DDL for Package Body HRMS37U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS37U" is
-- last update: 27/09/2022 10:44

  procedure initial_value(json_str in clob) AS
    json_obj        json_object_t := json_object_t(json_str);
  begin
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_dtest             := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtest')),'dd/mm/yyyy');
    p_dteen             := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteen')),'dd/mm/yyyy');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtereq            := hcm_util.get_string_t(json_obj,'p_dtereq');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    v_codappr           := pdk.check_codempid(global_v_coduser);
        -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'remarkApprove');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'remarkReject');
    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  END initial_value;
  --
  procedure gen_index(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    p_codcomp     varchar2(100 char);
    p_start       number;
    p_end         number;
    v_nextappr    varchar2(100 char);

    v_chk        varchar(4 char);
    v_appno      VARCHAR2(4 char);
    v_found      VARCHAR2(1 char);
    v_dtest      DATE ;
    v_dteen      DATE ;
    v_rcnt       NUMBER;
    v_row        NUMBER := 0;
    CURSOR c1 IS
      select dtereq,codempid,numseq,codappr,a.approvno appno,staappr,dteappr,remarkap,
             codform,hcm_util.get_codcomp_level(codcomp,1) vcodcomp,/*User37 ST11 29/07/2021 flginc,*/b.approvno qtyapp,
             get_temploy_name(codempid,global_v_lang) ename,
             get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status
             --User37 ST11 29/07/2021 get_tcodec_name('tcodtypcrt',a.typcertif,global_v_lang) typcer   --user39 : 05/06/15 : STA4580065
       from  trefreq a ,twkflowh b
       where staappr  IN ('P','A')
        and ('Y' = chk_workflow.check_privilege('HRES36E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
               -- Replace Approve
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                        from   twkflowde c
                                                        where  c.routeno  = a.routeno
                                                        and    c.codempid = v_codappr)
        and ((sysdate - nvl(dteapph,dteinput))*1440) >= (select  hrtotal  from twkflpf where codapp ='HRES36E')))
        and a.routeno = b.routeno
        and (codempid = nvl(p_codempid,codempid)/* or lower(get_temploy_name(codempid,102)) like '%'||lower(p_codempid)||'%'*/)
        ORDER BY  codempid,dtereq,numseq;

    CURSOR c2 IS
        select dtereq,codempid,numseq,codappr,approvno,staappr,dteappr,
               codform,hcm_util.get_codcomp_level(codcomp,1) vcodcomp,/*User37 ST11 29/07/2021 flginc,*/remarkap,
               get_temploy_name(codempid,global_v_lang) ename,
               get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status
               --User37 ST11 29/07/2021 get_tcodec_name('tcodtypcrt',typcertif,global_v_lang) typcer  --user39 : 05/06/15 : STA4580065
          from trefreq
           where (codempid = nvl(p_codempid,codempid) /*or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%'*/)
           and (codempid ,dtereq,numseq) in
                                     ( select codempid,dtereq,numseq
                                         from tapempch
                                        where staappr = decode(p_staappr,'Y','A',p_staappr)
                                          and typreq  = 'HRES36E'
                                          and codappr = v_codappr
                                          and dteappr between nvl(p_dtest,dteappr) and nvl(p_dteen,dteappr) )
            order by codempid,dtereq,numseq;
  begin
    if p_staappr in ('P') then
      obj_row  := json_object_t();

      for r1 in c1 loop
        v_appno  := nvl(r1.appno,0) + 1;
        if nvl(r1.appno,0)+1 = r1.qtyapp THEN
           v_chk := 'E' ;
        else
           v_chk := v_appno ;
        end if; 
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('desc_coderror','');
        obj_data.put('httpcode','');
        obj_data.put('flg','');
        obj_data.put('approvno',nvl(v_appno,' '));
        obj_data.put('chk_appr',nvl(v_chk,' '));
        obj_data.put('image',get_emp_img (r1.codempid)); --user56
        obj_data.put('codempid',nvl(r1.codempid,''));
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq',nvl(to_char(r1.dtereq ,'dd/mm/yyyy'),' '));
        obj_data.put('numseq',nvl(to_char(r1.numseq),' '));
        --User37 ST11 29/07/2021 obj_data.put('typcer',nvl(r1.typcer,' '));
        obj_data.put('status',nvl(r1.status,' '));
        obj_data.put('desc_codappr',nvl(get_temploy_name(r1.codappr,global_v_lang),' '));
        obj_data.put('dteappr',nvl(to_char(r1.dteappr,'dd/mm/yyyy'),' '));
        obj_data.put('remark',nvl(r1.remarkap,' '));
        obj_data.put('desc_codempap',nvl(get_temploy_name(global_v_codempid,global_v_lang),' '));
        obj_data.put('codappr',nvl(r1.codappr,' '));
        obj_data.put('staappr',nvl(r1.staappr,' '));
        obj_data.put('desc_codform' , get_tfmrefr_name(r1.codform,global_v_lang));--User37 ST11 29/07/2021 

        obj_row.put(to_char(v_row-1),obj_data);

      end loop;
    else
      obj_row  := json_object_t();
      for r1 in c2 loop
        v_nextappr :=  null ;
        if r1.staappr = 'A' then
          v_nextappr := chk_workflow.get_next_approve('HRES36E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang);
        end if;
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('desc_coderror','');
        obj_data.put('httpcode','');
        obj_data.put('flg','');
        obj_data.put('approvno',nvl(v_appno,' '));
        obj_data.put('chk_appr',nvl(v_chk,' '));
        obj_data.put('codempid',nvl(r1.codempid,' '));
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq',nvl(to_char(r1.dtereq ,'dd/mm/yyyy'),' '));
        obj_data.put('numseq',nvl(to_char(r1.numseq),' '));
        --User37 ST11 29/07/2021 obj_data.put('typcer',nvl(r1.typcer,' '));
        obj_data.put('status',nvl(r1.status,' '));
        obj_data.put('desc_codappr',nvl(get_temploy_name(r1.codappr,global_v_lang),' '));
        obj_data.put('dteappr',nvl(to_char(r1.dteappr,'dd/mm/yyyy'),' '));
        obj_data.put('remark',nvl(r1.remarkap,' '));
        obj_data.put('desc_codempap',nvl(v_nextappr,' '));
        obj_data.put('codappr',nvl(r1.codappr,' '));
        obj_data.put('staappr',nvl(r1.staappr,' '));
        obj_data.put('desc_codform' , get_tfmrefr_name(r1.codform,global_v_lang));--User37 ST11 29/07/2021 

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as

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
  -- detail_ref
  procedure gen_detail(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;

    v_desnote         varchar2(500 char);
    v_dteuse          varchar2(100 char);
    --User37 ST11 29/07/2021 v_flginc          varchar2(100 char);
    v_dtereq          varchar2(100 char);
    v_numseq          varchar2(100 char);
    --User37 ST11 29/07/2021 v_typcer          varchar2(100 char);
    v_travel_period   varchar2(100 char);
    v_country         varchar2(100 char);
    v_codform         varchar2(500 char);--User37 ST11 29/07/2021 
  begin
    --<<User37 ST11 29/07/2021 
    /*begin
      select desnote,to_char(dteuse,'dd/mm/yyyy'),flginc,to_char(dtereq,'dd/mm/yyyy'),numseq,get_tcodec_name('tcodtypcrt',typcertif,global_v_lang) typcer,travel_period,country
        into v_desnote,v_dteuse,v_flginc,v_dtereq,v_numseq,v_typcer,v_travel_period,v_country
        from trefreq
       where codempid = p_codempid
         and dtereq = to_date(p_dtereq,'dd/mm/yyyy')
         and numseq = to_number(p_numseq);
    exception when no_data_found then
        v_desnote := '';
        v_dteuse := '';
        v_flginc := '';
        v_dtereq := '';
        v_numseq := '';
        v_typcer := '';
        v_travel_period := '';
        v_country := '';
    end;*/
    begin
      select desnote,to_char(dteuse,'dd/mm/yyyy'),to_char(dtereq,'dd/mm/yyyy'),numseq,travel_period,country,codform
        into v_desnote,v_dteuse,v_dtereq,v_numseq,v_travel_period,v_country,v_codform
        from trefreq
       where codempid = p_codempid
         and dtereq = to_date(p_dtereq,'dd/mm/yyyy')
         and numseq = to_number(p_numseq);
    exception when no_data_found then
        v_desnote := '';
        v_dteuse := '';
        v_dtereq := '';
        v_numseq := '';
        v_travel_period := '';
        v_country := '';
    end;
    -->>User37 ST11 29/07/2021 
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('codempid',nvl(p_codempid,''));
      obj_row.put('desc_codempid', get_temploy_name(p_codempid,global_v_lang));
      obj_row.put('dtereq',v_dtereq);
      obj_row.put('numseq',v_numseq);
      obj_row.put('desnote',v_desnote);
      obj_row.put('dteuse',v_dteuse);
      --<<User37 ST11 29/07/2021 
      --obj_row.put('flginc',v_flginc);
      --obj_row.put('typcer',v_typcer);
      obj_row.put('desc_codform' , v_codform||' - '||get_tfmrefr_name(v_codform,global_v_lang));
      -->>User37 ST11 29/07/2021 
      obj_row.put('travel_period',v_travel_period);
      obj_row.put('country',v_country);

      json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
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
  procedure approve(p_coduser          in varchar2,
                    global_v_lang      in varchar2,
                    p_total            in varchar2,
                    p_status           in varchar2,
                    p_appseq           in number,
                    p_chk              in varchar2,
                    p_codempid         in varchar2,
                    p_numseq           in number,
                    p_dtereq           in varchar2,
                    p_dteappr          in varchar2,
                    p_remark           in varchar2,
                    param_flgwarn      in out varchar2) is

      v_codapp    tempaprq.codapp%type   := 'HRES36E';
      p_codappr   temploy1.codempid%type := pdk.check_codempid(p_coduser); -- tik edit --
      v_appno     varchar2(200 char);
      v_approve   varchar2(10 char);
      v_id        varchar2(200 char);
      v_reqdte    date;
      v_count     number := 0;
      v_codeappr  temploy1.codempid%type;
      v_approvno  number;
      v_approv    temploy1.codempid%type;
      v_staappr   varchar2(1 char);

      p_desc       varchar2(600 char);
      v_desc       varchar2(600 char) :=get_label_name('HCM_APPRFLW',global_v_lang,10);-- user22 : 04/07/2016 : STA4590287 || v_desc      varchar2(200 char);
      v_trefreq    trefreq%rowtype;
      v_remark     varchar2(7000 char):=replace(replace(p_remark,'^$','&'),'^@','#');

      v_codempap   temploy1.codempid%type;
      v_codcompap  tcenter.codcomp%type;
      v_codposap   tpostn.codpos%type;
      v_numseq     number := 0;
      v_row_id     varchar2(200);
      v_dteappr    date;

  begin
      v_appno   := p_appseq;
      v_approve := p_chk;
      v_id      := p_codempid;
      v_reqdte  := to_date(p_dtereq,'dd/mm/yyyy');
      v_dteappr := to_date(p_dteappr,'dd/mm/yyyy');
      v_numseq  := p_numseq;

      -- Check Data
      if v_dteappr < v_reqdte then
         --pdk.error_approve('HR2020',null,'datebox',p_lang);
         param_code_error := 'HR2020';
         param_httpcode := 'dteappr';
         return;
      end if;
      ---------------------------------------------------
      v_remark  := p_remark;
      v_remark  := replace(v_remark,'.',chr(13));
      v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');

      begin
        select count(*) into v_count
          from tapempch
         where codempid = v_id
           and dtereq   = v_reqdte
           and typreq   = v_codapp
           and numseq   = v_numseq
           and approvno = v_appno;
      exception when no_data_found then
        v_count := 0;
      end;

      begin
       select *
         into v_trefreq
         from trefreq
        where codempid = v_id
          and dtereq   = v_reqdte
          and numseq   = v_numseq ;
      exception when no_data_found then
          v_trefreq := null;
      end;
      p_desc := v_trefreq.desnote;

      if v_count = 0 then
              insert into tapempch
                                  (
                                   codempid,dtereq,typreq,numseq,
                                   approvno,codappr,dteappr,
                                   staappr,remark,coduser,dteapph
                                   )
                          values
                                  (
                                   v_id,v_reqdte,v_codapp,v_numseq,
                                   v_appno,p_codappr,v_dteappr,
                                   p_status,v_remark,p_coduser,sysdate
                                   );
      else
          update tapempch set codappr   = p_codappr,
                              dteappr   = v_dteappr,
                              staappr   = p_status,
                              remark    = v_remark ,
                              coduser   = p_coduser,
                              dteapph   = sysdate
              where codempid = v_id
                and dtereq   = v_reqdte
                and typreq   = v_codapp
                and numseq   = v_numseq
                and approvno = v_appno;
      end if;


      -- Check Next Step

      v_codeappr  :=  p_codappr ;
      v_approvno  :=  v_appno;


      chk_workflow.find_next_approve(v_codapp,v_trefreq.routeno,v_id,to_char(v_reqdte,'dd/mm/yyyy'),v_numseq,v_appno,p_codappr);

      if  p_status = 'A' and v_approve <> 'E'   then
           --loop check next step
           loop
--<< user22 : 04/07/2016 : STA4590287 ||
              v_approv := chk_workflow.check_next_step2(v_codapp,v_trefreq.routeno,v_id,to_char(v_reqdte,'dd/mm/yyyy'),v_numseq,v_codapp,null,v_approvno,p_codappr);
              --v_approv := chk_workflow.chk_nextstep(v_codapp,v_trefreq.routeno,v_approvno,v_codempap,v_codcompap,v_codposap);
-->> user22 : 04/07/2016 : STA4590287 ||
               if  v_approv is not null then
                 v_remark   := v_desc;
                 v_approvno := v_approvno + 1 ;
                 v_codeappr := v_approv ;
                  begin
                    select count(*) into v_count
                      from tapempch
                     where codempid = v_id
                       and dtereq   = v_reqdte
                       and typreq   = v_codapp
                       and numseq   = v_numseq
                       and approvno = v_approvno;
                  exception when no_data_found then
                    v_count := 0;
                  end;
                  if v_count = 0 then
                          insert into tapempch
                                              (
                                               codempid,dtereq,typreq,numseq,
                                               approvno,codappr,dteappr,
                                               staappr,remark,coduser,dteapph
                                               )
                                      values
                                              (
                                               v_id,v_reqdte,v_codapp,v_numseq,
                                               v_approvno,v_codeappr,v_dteappr,
                                               p_status,v_remark,p_coduser,sysdate
                                              );
                  else
                      update tapempch set codappr   = v_codeappr,
                                          dteappr   = v_dteappr,
                                          staappr   = p_status,
                                          remark    = v_remark,
                                          coduser   = p_coduser,
                                          dteapph   = sysdate
                          where codempid = v_id
                            and dtereq   = v_reqdte
                            and typreq   = v_codapp
                            and numseq   = v_numseq
                            and approvno = v_approvno;
                  end if;
             else
               exit ;
             end if;
              chk_workflow.find_next_approve(v_codapp,v_trefreq.routeno,v_id,to_char(v_reqdte,'dd/mm/yyyy'),v_numseq,v_appno,p_codappr);
           end loop ;

          update trefreq set approvno  = v_approvno,
                             codappr   = v_codeappr,
                             dteappr   = v_dteappr,
                             staappr   = p_status,
                             remarkap  = v_remark,
                             coduser   = p_coduser,
                             dteapph   = sysdate
                       where codempid  = v_id
                         and dtereq    = v_reqdte
                         and numseq    = v_numseq;

      END IF;
      -- End Check Next Step

      -- Update Table Request
      v_staappr    := p_status ;
      if v_approve = 'E' and v_staappr = 'A' then
         v_staappr := 'Y';
      end if;

          update trefreq set approvno  = v_approvno,
                             codappr   = v_codeappr,
                             dteappr   = v_dteappr,
                             staappr   = v_staappr,
                             remarkap  = v_remark,
                             coduser   = p_coduser,
                             dteapph   = sysdate
                      where codempid = v_id
                        and dtereq   = v_reqdte
                        and numseq   = v_numseq ;
      commit;
      -- Send Mail

      begin
          select rowid
          into v_row_id
          from trefreq
          where codempid = v_id
            and dtereq   = v_reqdte
            and numseq   = v_numseq;
      exception when no_data_found then
          v_trefreq := null;
      end;
      
      begin 
        chk_workflow.sendmail_to_approve( p_codapp        => v_codapp,
                                          p_codtable_req  => 'tapempch',
                                          p_rowid_req     => v_row_id,
                                          p_codtable_appr => 'taplverq',
                                          p_codempid      => v_id,
                                          p_dtereq        => v_reqdte,
                                          p_seqno         => v_numseq,
                                          p_typchg        => v_codapp,
                                          p_staappr       => v_staappr,
                                          p_approvno      => v_approvno,
                                          p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                          p_subject_mail_numseq  => '20',
                                          p_lang          => global_v_lang,
                                          p_coduser       => global_v_coduser);
      exception when others then
        param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
      end;

   EXCEPTION WHEN others THEN
      rollback ;
      --pdk.error_page(sqlerrm,'X');
      param_sqlerrm := sqlerrm;
  end;  -- Procedure Approve
  --

 procedure process_approve(json_str_input in clob, json_str_output out clob) is
    json_obj              json_object_t;
    json_obj2             json_object_t;
    v_coduser             varchar2(100 char);
    v_remark_appr         varchar2(4000 char);
    v_remark_not_appr     varchar2(4000 char);
    v_rowcount      number:= 0;
    v_staappr       varchar2(200);
    v_appseq        number;
    v_chk           varchar2(10);
    v_numseq        number;
    v_codempid      varchar2(200);
    v_dtereq        varchar2(200);
    v_dteappr       varchar2(200);
    v_remark        varchar2(2000);
    errm_str        varchar2(4000);
--    resp_obj        json :=  json();
    resp_str        varchar2(4000 char);
    param_flgwarn   varchar2(200);

  begin
    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input).get_object('param_json');
    v_rowcount := json_obj.get_size;
--    for i in 0..json_obj.get_size-1 loop
--      json_obj2   := json_object_t(json_obj.get(to_char(i)));

      v_staappr       := hcm_util.get_string_t(json_obj, 'p_staappr');
      v_chk           := hcm_util.get_string_t(json_obj, 'p_chk_appr');
      v_codempid      := hcm_util.get_string_t(json_obj, 'p_codempid');
      v_numseq        := to_number(hcm_util.get_string_t(json_obj, 'p_numseq'));
      v_appseq        := to_number(hcm_util.get_string_t(json_obj, 'p_approvno'));
      v_dtereq        := hcm_util.get_string_t(json_obj, 'p_dtereq');
      v_dteappr       := hcm_util.get_string_t(json_obj, 'p_dteappr');
      param_flgwarn   := hcm_util.get_string_t(json_obj, 'p_flgwarn');

      --<< user20 Date: 01/09/2021  MS Module- #6653
      v_staappr := nvl(v_staappr, 'A');
      -->> user20 Date: 01/09/2021  MS Module- #6653

      if v_staappr = 'A' then
         v_remark := p_remark_appr;
      elsif v_staappr = 'N' then
         v_remark := p_remark_not_appr;
      end if;

      --<< user20 Date: 01/09/2021  MS Module- #6653
      v_remark := substr(v_remark, 1, 500);
      -->> user20 Date: 01/09/2021  MS Module- #6653

      approve(global_v_coduser,global_v_lang,to_char(v_rowcount),v_staappr,v_appseq,v_chk,v_codempid,v_numseq,v_dtereq,v_dteappr,v_remark,param_flgwarn);
--      exit when param_msg_error is not null;
--    end loop;
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
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end process_approve;

  procedure datatest(json_str in clob) as
    json_obj    json_object_t  := json_object_t(json_str);

    v_flgcreate varchar2(4000 char);
    v_coduser   varchar2(4000 char);
    v_codcomp   varchar2(4000 char);
    v_codempid  varchar2(4000 char);
    v_numseq    number;
    v_dtereq    date;
    v_routeno   varchar2(4000 char);
  begin
    v_flgcreate := hcm_util.get_string_t(json_obj,'p_flgcreate');
    v_coduser   := hcm_util.get_string_t(json_obj,'p_coduser');
    v_codcomp   := hcm_util.get_string_t(json_obj,'p_codcomp');
    v_codempid  := hcm_util.get_string_t(json_obj,'p_codempid');
    v_numseq    := to_number(hcm_util.get_string_t(json_obj,'p_dataseed'));
    v_dtereq    := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy hh24.mi.ss');
    v_routeno   := hcm_util.get_string_t(json_obj,'p_routeno');

    if v_flgcreate = 'Y' or v_flgcreate = 'N' then
      delete trefreq
       where codempid = v_codempid
         and dtereq   = v_dtereq
         and numseq   = v_numseq;

      delete tapempch
       where codempid = v_codempid
         and dtereq   = v_dtereq
         and numseq   = v_numseq;
    end if;

    if v_flgcreate = 'Y' then
      --<<User37 ST11 29/07/2021 
      insert into trefreq
        (codempid,dtereq,numseq,desnote,
        numcerti,codappr,staappr,
        codcomp,remarkap,dteuse,dteappr,
        approvno,codform,routeno,
        flgsend,dtecancel,
        dteinput,dtesnd,dteupd,coduser,
        dteapph,flgagency)
      values
        (v_codempid,v_dtereq,v_numseq,'test-desnote',
        null,null,'P',
        v_codcomp,null,v_dtereq,null,
        0,null,v_routeno,
        null,null,
        sysdate,null,sysdate,v_coduser,
        null,null);
      /*insert into trefreq
        (codempid,dtereq,numseq,desnote,
        flginc,numcerti,codappr,staappr,
        codcomp,remarkap,dteuse,dteappr,
        approvno,codform,routeno,
        flgsend,dtecancel,
        dteinput,dtesnd,dteupd,coduser,
        dteapph,flgagency,typcertif)
      values
        (v_codempid,v_dtereq,v_numseq,'test-desnote',
        'Y',null,null,'P',
        v_codcomp,null,v_dtereq,null,
        0,null,v_routeno,
        null,null,
        sysdate,null,sysdate,v_coduser,
        null,null,'0001');*/
        -->>User37 ST11 29/07/2021 
    end if;

    commit;
  end datatest;
end;

/

--------------------------------------------------------
--  DDL for Package Body HRMSS3U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMSS3U" is
-- last update: 27/09/2022 10:44

  procedure initial_value(json_str in clob) is
    json_obj      json_object_t;
  begin
    json_obj           := json_object_t(json_str);
    --global
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_dtest             := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtest')),'dd/mm/yyyy');
    p_dteen             := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteen')),'dd/mm/yyyy');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtereq            := hcm_util.get_string_t(json_obj,'p_dtereq');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    v_codappr           := pdk.check_codempid(global_v_coduser);
    p_appseq            := to_number(hcm_util.get_string_t(json_obj, 'p_approvno'));
    -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure gen_index(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_dtest       date ;
    v_dteen       date ;
    v_chk         varchar(4 char);
    v_appno       varchar(4 char);
    v_nextappr    varchar2(100 char);
    v_date        date;
    v_row         number := 0;

    cursor c1 is
    select codempid,codappr,a.approvno appno,codcomp,remarkap,dteappr,
             get_temploy_name(codempid,global_v_lang) ename,staappr,
             get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,
             dtereq,seqno,b.approvno qtyapp, a.flgemp
       from  tpfmemrq a ,twkflowh b
       where staappr in ('P','A')
       and   ('Y' = chk_workflow.check_privilege('HRESS2E',codempid,dtereq,seqno,(nvl(a.approvno,0) + 1),v_codappr)
              -- Replace Approve
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                        from   twkflowde c
                                                        where  c.routeno  = a.routeno
                                                        and    c.codempid = v_codappr)
              and trunc(((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRESS2E')))
        and a.routeno = b.routeno
--        and a.codcomp like p_codcomp||'%'
        and (a.codempid = nvl(p_codempid,a.codempid) or lower(get_temploy_name(a.codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
        order by  codempid,dtereq;

    cursor c2 is
      select codempid,codappr,approvno,codcomp ,dtereq,seqno,dteappr,remarkap,
               get_temploy_name(codempid,global_v_lang) ename,staappr,
               get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,
               get_tcenter_name(codcomp,global_v_lang) namcomp, flgemp

      from  tpfmemrq
--      where codcomp like p_codcomp||'%'
      where (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
      and (codempid ,dtereq,seqno) in
                      (select codempid,dtereq,numseq
                       from  tapempch
                       where staappr = decode(p_staappr,'Y','A',p_staappr)
                       and   codappr = v_codappr
                       and   dteappr between nvl(p_dtest,dteappr) and nvl(p_dteen,dteappr) )
       order by  codempid,dtereq;

  begin
    if p_staappr = 'P' then
      obj_row  := json_object_t();
      for r1 in c1 loop
        v_row := v_row+1;
        v_appno  := nvl(r1.appno,0) + 1;
        if nvl(r1.appno,0)+1 = r1.qtyapp then
           v_chk := 'E' ;
        else
           v_chk := v_appno ;
        end if;
        v_date := to_char(r1.dtereq ,'DD/MM/')||to_number(to_char(r1.dtereq,'YYYY'));
        --
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('desc_coderror','');
        obj_data.put('httpcode','');
        obj_data.put('flg','');
        obj_data.put('approvno',nvl(v_appno,' '));
        obj_data.put('chk_appr',nvl(v_chk,' '));
        obj_data.put('image',get_emp_img(r1.codempid));
        obj_data.put('codempid',nvl(r1.codempid,''));
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq',nvl(to_char(r1.dtereq ,'dd/mm/yyyy'),' '));
        obj_data.put('numseq',nvl(to_char(r1.seqno),' '));
        obj_data.put('status',nvl(r1.status,' '));
        obj_data.put('desc_codappr',nvl(get_temploy_name(r1.codappr,global_v_lang),' '));
        obj_data.put('dteappr',nvl(to_char(r1.dteappr,'dd/mm/yyyy'),' '));
        obj_data.put('remark',nvl(r1.remarkap,' '));
        obj_data.put('desc_codempap',get_temploy_name(global_v_codempid,global_v_lang));
        obj_data.put('flgemp',r1.flgemp);
        obj_data.put('codappr',nvl(r1.codappr,' '));
        obj_data.put('staappr',nvl(r1.staappr,' '));

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    else
      obj_row  := json_object_t();
      for r1 in c2 loop
        v_date := to_char(r1.dtereq ,'DD/MM/')||to_number(to_char(r1.dtereq,'YYYY'));
        v_nextappr := null;
       if r1.staappr = 'A' then
          v_nextappr := chk_workflow.get_next_approve('HRESS2E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.seqno,r1.approvno,global_v_lang);
        end if;
        --
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('desc_coderror','');
        obj_data.put('httpcode','');
        obj_data.put('flg','');
        obj_data.put('approvno',nvl(v_appno,' '));
        obj_data.put('chk_appr',nvl(v_chk,' '));
        obj_data.put('image',get_emp_img(r1.codempid));
        obj_data.put('codempid',nvl(r1.codempid,''));
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq',nvl(to_char(r1.dtereq ,'dd/mm/yyyy'),' '));
        obj_data.put('numseq',nvl(to_char(r1.seqno),' '));
        obj_data.put('status',nvl(r1.status,' '));
        obj_data.put('desc_codappr',nvl(get_temploy_name(r1.codappr,global_v_lang),' '));
        obj_data.put('dteappr',nvl(to_char(r1.dteappr,'dd/mm/yyyy'),' '));
        obj_data.put('remark',nvl(r1.remarkap,' '));
        obj_data.put('desc_codempap',v_nextappr);
        obj_data.put('flgemp',r1.flgemp);
        obj_data.put('codappr',nvl(r1.codappr,' '));
        obj_data.put('staappr',nvl(r1.staappr,' '));

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;
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
  --
  procedure gen_detail_tab1(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    r_tpfmemrq    tpfmemrq%rowtype;
    v_flg1        varchar2(30 char);
    v_flg2        varchar2(30 char);
    v_dteeffec    date;
    v_qtycompst   number;
  begin
    begin
      select *
       into r_tpfmemrq
       from tpfmemrq
      where codempid  = p_codempid
        and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
        and seqno     = p_numseq ;
    exception when others then
      null ;
    end ;

    begin
      select max(dteeffec),sum(qtycompst)
        into v_dteeffec,v_qtycompst
        from tpfmemrq2
       where codempid = p_codempid
         and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
         and seqno    = p_numseq
    group by dteeffec;
    exception when others then
      null ;
    end ;

    if  r_tpfmemrq.flgemp = 1 or r_tpfmemrq.flgemp = 0 then
      v_flg1  := 'checked';
      v_flg2 := null;
     else
      v_flg1  := null;
      v_flg2 := 'checked';
     end if;

      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('codempid',nvl(r_tpfmemrq.codempid,''));
      obj_row.put('desc_codempid', get_temploy_name(r_tpfmemrq.codempid,global_v_lang));
      obj_row.put('codpfinf',nvl(r_tpfmemrq.codpfinf,' '));
      obj_row.put('desc_codpfinf',get_tcodec_name('TCODPFINF',r_tpfmemrq.codpfinf,global_v_lang));
      obj_row.put('nummember',nvl(r_tpfmemrq.nummember,' '));
      obj_row.put('dteeffec',nvl(to_char(r_tpfmemrq.dteeffec,'dd/mm/yyyy'),' '));
      obj_row.put('flgemp',nvl(r_tpfmemrq.flgemp,' '));
      obj_row.put('dtereti',nvl(to_char(r_tpfmemrq.dtereti,'dd/mm/yyyy'),' '));
      obj_row.put('remark',nvl(r_tpfmemrq.remark,' '));
      obj_row.put('ratereta',nvl(to_char(r_tpfmemrq.ratereta),' '));
      obj_row.put('dtechg',nvl(to_char(r_tpfmemrq.dtechg,'dd/mm/yyyy'),' '));
      obj_row.put('dteplann',nvl(to_char(r_tpfmemrq.dteplann,'dd/mm/yyyy'),' '));
      obj_row.put('dteeffec2',nvl(to_char(v_dteeffec,'dd/mm/yyyy'),' '));
      obj_row.put('dtereq',to_char(to_date(p_dtereq,'dd/mm/yyyy'),'dd/mm/yyyy'));
      obj_row.put('desc_codreti',get_tcodec_name('TCODEXEM',r_tpfmemrq.codreti,global_v_lang));
      obj_row.put('codpolicy','');
      obj_row.put('desc_codpolicy','');
      obj_row.put('qtycompst','');

      json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob) as

  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_table_tab1(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;

    v_sum           number := 0;
    v_row           number := 0;

    cursor c1 is
        select codempid,dtereq,seqno,codplan,codpolicy,dteeffec,dteupd,qtycompst,coduser
          from tpfmemrq2
         where codempid = p_codempid
           and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
           and seqno    = to_number(p_numseq)
      order by codpolicy;
  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('desc_coderror','');
      obj_data.put('httpcode','');
      obj_data.put('flg','');
      obj_data.put('codpolicy',nvl(r1.codpolicy,' '));
      obj_data.put('desc_codpolicy',nvl(get_tcodec_name('TCODPFPLC',r1.codpolicy,global_v_lang),' '));
      obj_data.put('qtycompst',nvl(to_char(r1.qtycompst,'fm990.00'),' '));

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_table_tab1(json_str_input in clob, json_str_output out clob) as

  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_table_tab1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
    --
  procedure gen_table_tab2(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;

    v_sum           number := 0;
    v_row           number := 0;

    cursor c1 is
       select codempid,numseq,seqno,dtereq,dteupd,ratepf,desrel,adrpfic,coduser,nampfic
         from tprofreq
        where codempid = p_codempid
          and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
          and seqno    = to_number(p_numseq)
     order by numseq;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      obj_data := json_object_t();
      v_row := v_row+1;
      obj_data.put('coderror','200');
      obj_data.put('desc_coderror','');
      obj_data.put('httpcode','');
      obj_data.put('flg','');
      obj_data.put('numseq',nvl(to_char(r1.numseq),' '));
      obj_data.put('nampfic',nvl(r1.nampfic,' '));
      obj_data.put('adrpfic',nvl(r1.adrpfic,' '));
      obj_data.put('desrel',nvl(r1.desrel,' '));
      obj_data.put('ratepf',nvl(to_char(r1.ratepf),' '));

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_table_tab2(json_str_input in clob, json_str_output out clob) as

  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_table_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detailsubmit_tab1(json_str_input in clob, json_str_output out clob) as
    obj_data          json_object_t;
    v_intdate         varchar2(50 char);
    v_codappid        temploy1.codempid%type;
    v_name            varchar2(100 char);
    v_dteeffec        date;
    v_remark          varchar2(500 char);
    v_remarkap        varchar2(1000 char);

  cursor c2 is
     select  *
       from tapempch
      where codempid  = p_codempid
        and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
        and numseq    = p_numseq
        and typreq    = 'HRESS2E'
        and approvno  < p_appseq
     order by codempid,approvno ;

  begin
    initial_value(json_str_input);
    v_codappid    := pdk.check_codempid(global_v_coduser);
    v_name        := get_temploy_name(v_codappid,global_v_lang);
    v_intdate     := to_char(sysdate,'DD/MM/')||to_char(to_number(to_char(sysdate,'YYYY')) );
    if p_appseq > 1 then
      for n in c2 loop
        v_remarkap := replace(n.remark,chr(10),' ');
        v_dteeffec   := n.dteeffec;
        v_remark     := n.remark ;
      end loop;
    else
      begin
        select dtereq into v_dteeffec
        from   tpfmemrq
        where  codempid  = p_codempid
        and    dtereq    = p_dtereq
        and    seqno     = p_numseq;
      exception when others then null;
      end ;
    end if;
    --
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid',p_codempid);
    obj_data.put('desc_codempid',get_temploy_name(p_codempid,global_v_lang));
    obj_data.put('approvno',p_appseq);
    obj_data.put('codappr',v_codappid);
    obj_data.put('desc_codappr',v_name);
    obj_data.put('dteappr',v_intdate);
    obj_data.put('dteeffec',to_char(v_dteeffec,'dd/mm/yyyy'));
    obj_data.put('staappr',p_staappr);
    obj_data.put('status',get_tlistval_name('ESSTAREQ',p_staappr,global_v_lang));
    obj_data.put('remark',v_remark);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detailsubmit_tab1;
  --
  function get_log_numseq(p_numpage varchar2, p_codempid varchar2) return number is
    v_log_seq     number;
    v_sysdate     date  := trunc(sysdate);
  begin
    select nvl(max(numseq),0)+1 into v_log_seq
      from tpfmlog
     where codempid = p_codempid
       and trunc(dteedit) = v_sysdate
       and numpage = 'HRPYB2C20';
    return v_log_seq;
  end;
  --
  procedure upd_log
     (p_codempid varchar2,
      p_numpage varchar2,
      p_fldedit varchar2,
      p_typkey varchar2,
      p_desold varchar2,
      p_desnew varchar2,
      p_codtable varchar2,
      p_numseq number,
      p_codseq date default null,
      p_dteseq date default null) as

      v_datenew 	 date;
      v_dateold 	 date;
      v_desnew 	 varchar2(500) ;
      v_desold 	 varchar2(500) ;
      v_codcomp    varchar2(40) ;
  begin
      if (p_desold is null and p_desnew is not null) or
         (p_desold is not null and p_desnew is null) or
         (p_desold <> p_desnew) then
          v_desnew := p_desnew ;
          v_desold := p_desold ;
          if  p_typkey = 'D' then
              if  p_desnew is not null and global_v_zyear = 543 then
                  v_datenew := add_months(to_date(v_desnew,'dd/mm/yyyy'),-(543*12));
                  v_desnew  := to_char(v_datenew,'dd/mm/yyyy') ;
              end if;
              if  p_desold is not null and global_v_zyear = 543 then
                  v_dateold := add_months(to_date(v_desold,'dd/mm/yyyy'),-(543*12));
                  v_desold  := to_char(v_dateold,'dd/mm/yyyy') ;
              end if;
          end if;
          begin
            select codcomp into v_codcomp
            from temploy1
            where codempid = p_codempid;
          end;
          insert into tpfmlog (codempid,dteedit,numpage,numseq,fldedit,typkey,fldkey,
                               codcomp,desold,desnew,codtable,codseq,codcreate,coduser)
          values (p_codempid,sysdate,p_numpage,p_numseq,p_fldedit,p_typkey,p_fldedit,
                  v_codcomp,v_desold,v_desnew,p_codtable,p_codseq,global_v_coduser,global_v_coduser);
      end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    rollback;
  end upd_log;
  --
  procedure approve(p_coduser          in varchar2,
                    p_lang             in varchar2,
                    p_total            in varchar2,
                    p_status           in varchar2,
                    p_appseq           in number,
                    p_chk              in varchar2,
                    p_codempid         in varchar2,
                    p_numseq           in number,
                    p_dtereq           in varchar2,
                    p_dteappr          in varchar2,
                    p_dteeffec         in varchar2,
                    p_remark           in varchar2,
                    p_flgemp           in varchar2,
                    param_flgwarn      in out varchar2) is

    --  Request
    rq_codempid temploy1.codempid%type;
    rq_dtereq   date ;
    rq_seqno    number ;
    rq_approvno number ;
    rq_chk      varchar2(10 char);

    v_tpfmemrq  tpfmemrq %rowtype;
    v_approvno  number := null;
    ap_approvno number := null;
    v_count     number := 0;
    v_staappr   varchar2(1 char);
    p_codappr   temploy1.codempid%type := pdk.check_codempid(p_coduser);
    v_codeappr  temploy1.codempid%type;
    v_approv    temploy1.codempid%type;
    v_desc      varchar2(600 char) := get_label_name('HCM_APPRFLW',global_v_lang,10);-- user22 : 04/07/2016 : STA3590287 || v_desc      varchar2(200 char);

    v_appseq    number;
    v_appnochk  temploy1.codempid%type;
    v_pos0      varchar2(200 char);
    v_pos1      varchar2(200 char);
    v_pos2      varchar2(200 char);
    v_pos3      varchar2(200 char);
    v_pos4      varchar2(200 char);
    v_pos5      varchar2(200 char);

    v_codempid  temploy1.codempid%type;
    v_codappid  temploy1.codempid%type;
    v_seqno     varchar2(100 char);
    v_status    varchar2(100 char);
    p_error     varchar2(10 char);
    v_amtalw    number ;

    v_codcompy  varchar2(4 char) ;
    v_typemp    varchar2(4 char) ;
    v_numlvl    number;
    v_max_allow number ;
    v_acc       number ;
    v_amtwidrwo number ;
    v_amtwidrwi number ;
    v_available number ;
    v_msg_to    varchar2(7000 char) ;
    v_msg_cc    varchar2(7000 char) ;
    v_msg_not   varchar2(7000 char) ;
    msg_error   varchar2(10 char) ;

    ---Transaction--
    v_codempmt    varchar2(4 char)  := ' ';
    v_typpayroll  varchar2(4 char)  := ' ';
    v_codcalen    varchar2(4 char)  := ' ';
    v_codpos      tpostn.codpos%type  := ' ';
    v_codjob      varchar2(4 char)  := ' ';
    v_codbrlc     varchar2(4 char)  := ' ';
    v_codcomp     tcenter.codcomp%type := ' ';
    v_codedlv     varchar2(4 char)  := ' ';
    v_flgatten    varchar2(1 char)  := ' ';
    v_codsex      varchar2(1 char)  := ' ';
    v_rowid       varchar2(36 char) := ' ';
    v_codcodec    varchar2(4 char)  := ' ';
    v_numseq      number := 0;
    v_amtincom1   varchar2(20 char);
    v_amtincom2   varchar2(20 char);
    v_amtincom3   varchar2(20 char);
    v_amtincom4   varchar2(20 char);
    v_amtincom5   varchar2(20 char);
    v_amtincom6   varchar2(20 char);
    v_amtincom7   varchar2(20 char);
    v_amtincom8   varchar2(20 char);
    v_amtincom9   varchar2(20 char);
    v_amtincom10  varchar2(20 char);
    v_amtothr     varchar2(20 char);
    v_codcurr     varchar2(4 char) ;

    v_codappr     tapempch.codappr%type;
    v_dteappr     tapempch.dteappr%type;
    v_dteeffec    tapempch.dteeffec%type;
    v_dtereq      tapempch.dtereq%type;
    v_remark      tapempch.remark%type;
    v_codempap    temploy1.codempid%type;
    v_codcompap   tcenter.codcomp%type;
    v_codposap    tpostn.codpos%type;
    v_tprofreq    tprofreq %rowtype;
    v_chkmem      number:=0;
    v_chkmemrt    number:=0;

    v_amtcaccu    varchar2(20 char);
    v_amtcretn    varchar2(20 char);
    v_amteaccu    varchar2(20 char);
    v_amteretn    varchar2(20 char);
    v_amtinteccu  varchar2(20 char);
    v_amtintaccu  varchar2(20 char);
    v_flgcontrb   varchar2(20 char);
    v_flgcontrc   varchar2(20 char);

    v_emp         number := 0;
    v_emp1        number := 0;
    v_max_approv  number;

    v_dteeffrinf  tpfirinf.dteeffec%type;
    v_dteeffreq2  tpfmemrq2.dteeffec%type;
    v_first				varchar2(1 char);
    v_row_id      varchar2(200 char);

    rec_old_tpfmemb     tpfmemb%rowtype;
    rec_tpfdinf         tpfdinf%rowtype;
    rec_old_tpfmemrt    tpfmemrt%rowtype;
    tpfdinf_ratecsbt    tpfdinf.ratecsbt%type;
    v_log_numseq        number;
    v_sysdate           date  := trunc(sysdate);

    cursor c_tprofreq is
      select *
        from tprofreq
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and seqno    = v_seqno
      order by numseq;

    cursor c_tpfmemrq2 is
      select *
        from tpfmemrq2
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and seqno    = v_seqno
      order by codpolicy;

  begin
    v_staappr :=  p_status;
    v_zyear   := pdk.check_year(p_lang);
    v_remark  := p_remark;
    v_remark  := replace(v_remark,'.',chr(13));
    v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');
    --
    v_appseq    := p_appseq;
    v_appnochk  := p_chk;
    v_status    := p_status;
    v_codempid  := p_codempid;
    v_dtereq    := p_dtereq;
    v_seqno     := p_numseq;

    rq_codempid   := v_codempid;
    rq_seqno      := v_appseq;
    rq_chk        := v_appnochk;
    rq_dtereq     := v_dtereq  ;
    -- Step 1 => Check Data
    begin
     select * into  v_tpfmemrq
       from tpfmemrq
      where codempid =  rq_codempid
        and dtereq   =  rq_dtereq
        and seqno    = v_seqno;
    exception when others then
     v_tpfmemrq := null ;
    end ;
    ap_approvno := v_appseq ;

    begin
      select approvno into v_max_approv
      from   twkflowh
      where  routeno = v_tpfmemrq.routeno ;
    exception when no_data_found then
      v_max_approv := 0 ;
    end ;

    begin
     select count(*) into  v_count
       from tapempch
      where codempid = rq_codempid
        and dtereq   = rq_dtereq
        and numseq   = v_seqno
        and typreq   = 'HRESS2E'
        and approvno = ap_approvno;
    exception when no_data_found then
        v_count := 0;
    end;

    -- Step 2 => Insert Table Request Detail
    if v_count = 0 then
        insert into tapempch(codempid,dtereq,numseq,typreq,approvno,
                   codappr,dteappr,staappr,remark,dteeffec,
                   dteupd,coduser,dteapph)
        values  (rq_codempid,rq_dtereq,v_seqno,'HRESS2E',ap_approvno,
                 p_codappr,p_dteappr,v_staappr,v_remark,p_dteeffec,
                 to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),p_coduser,sysdate);
    else
       update tapempch  
          set codappr   = p_codappr,
              dteappr   = p_dteappr,
              dteeffec  = p_dteeffec,
              staappr   = v_staappr,
              coduser   = p_coduser,
              dteapph  = sysdate

       where codempid = rq_codempid
       and   dtereq   = rq_dtereq
       and   numseq    = v_seqno
       and   typreq   = 'HRESS2E'
       and   approvno = ap_approvno;
    end if;

    -- Step 3 => Check Next Step
    v_codeappr  :=  p_codappr ;
    v_approvno  :=  ap_approvno;

    chk_workflow.find_next_approve('HRESS2E',v_tpfmemrq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),v_seqno,ap_approvno,p_codappr);
    if p_status = 'A' and rq_chk <> 'E' then
      loop
        v_approv := chk_workflow.check_next_step2('HRESS2E',v_tpfmemrq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),v_seqno,'HRESS2E',null,v_approvno,p_codappr);
        if  v_approv is not null then
          v_remark   := v_desc; -- user22 : 04/07/2016 : STA3590287 ||
          v_approvno := v_approvno + 1 ;
          v_codeappr := v_approv ;
          begin
            select  count(*) into v_count
             from   tapempch
             where  codempid   =  rq_codempid
                and   dtereq   =  rq_dtereq
                and   numseq   = v_seqno
                and   typreq   =  'HRESS2E'
                and   approvno =  v_approvno;
          exception when no_data_found then  v_count := 0;
          end;

          if v_count = 0  then
            insert into tapempch(codempid,dtereq,numseq,typreq,approvno,
                        codappr,dteappr,staappr,remark,dteeffec,
                        dteupd,coduser,dteapph)
              values   (rq_codempid,v_tpfmemrq.dtereq,v_seqno,'HRESS2E',v_approvno,
                        v_codeappr,p_dteappr,v_staappr,v_remark,p_dteeffec,
                        to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),p_coduser,sysdate);
          else
            update  tapempch
            set     codappr   = v_codeappr,
                    dteappr   = p_dteappr,
                    dteeffec  = p_dteeffec,
                    staappr   = 'A',
                    coduser   = p_coduser,
                    dteapph   = sysdate
            where codempid = rq_codempid
            and   dtereq   = rq_dtereq
            and   numseq   = v_seqno
            and   typreq   = 'HRESS2E'
            and   approvno = v_approvno;
          end if;
          chk_workflow.find_next_approve('HRESS2E',v_tpfmemrq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),v_seqno,v_approvno,p_codappr);-- user22 : 04/07/2016 : STA3590287 || v_approv := chk_workflow.Check_Next_Approve('HRESS2E',v_tpfmemrq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),v_seqno,v_approvno,p_codappr);
        else
          exit ;
        end if;
      end loop ;

      update tpfmemrq set
                         approvno  = v_approvno ,
                         codappr   = v_codeappr,
                         dteappr   = p_dteappr,
                         staappr   = 'A',
                         remarkap  = v_remark,
                         coduser   = p_coduser,
                         dteapph   = sysdate
      where   codempid = rq_codempid
      and     dtereq   = rq_dtereq
      and     seqno    = v_seqno;
    end if;

    -- Step 4 => Update Table Request and Insert Transaction
    if v_max_approv = v_approvno then
      rq_chk := 'E' ;
    end if;
    v_staappr := p_status ;

    if rq_chk = 'E' and p_status = 'A' then -- last approve
      v_staappr := 'Y';
      begin
        select *
          into v_tpfmemrq
          from tpfmemrq
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and seqno    = v_seqno;
      exception when no_data_found then null;
      end;

      begin
        select typpayroll
          into v_typpayroll
          from temploy1
         where codempid = rq_codempid;
      exception when no_data_found then null;
      end;

      if v_tpfmemrq.flgemp = '0' then
        v_tpfmemrq.flgemp   :=  '1';
        v_amtcaccu          :=  '0';
        v_amtcretn          :=  '0';
        v_amteaccu          :=  '0';
        v_amteretn          :=  '0';
        v_amtinteccu        :=  '0';
        v_amtintaccu        :=  '0';
        v_tpfmemrq.nummember:=  rq_codempid;
        v_flgcontrb         :=  '2';
        v_flgcontrc         :=  '2';
      elsif v_tpfmemrq.flgemp = '1' then
        v_flgcontrb     :=  '2';
      end if;

      --1 ins/upd tpfmemb
      begin
        select count(*) into v_chkmem
          from tpfmemb
         where codempid = rq_codempid ;
      end;
      v_log_numseq  := get_log_numseq('HRPYB2C10',rq_codempid);
      if v_chkmem = 0 then
        insert into tpfmemb(codempid,dteeffec,flgemp,dtereti,nummember,
                            amtcaccu,amtcretn,amteaccu,amteretn,amtinteccu,amtintaccu,
                            typpayroll,codcomp,rateeret,codpfinf,dteupd,coduser)
                     values(rq_codempid,p_dteeffec,v_tpfmemrq.flgemp,v_tpfmemrq.dtereti,v_tpfmemrq.nummember,
                            v_amtcaccu,v_amtcretn,v_amteaccu,v_amteretn,v_amtinteccu,v_amtintaccu,
                            v_typpayroll,v_tpfmemrq.codcomp,v_tpfmemrq.ratereta,v_tpfmemrq.codpfinf,trunc(sysdate),p_coduser);
        upd_log(rq_codempid,'HRPYB2C10','CODEMPID','C',null,p_codempid,'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','DTEEFFEC','D',null,to_char(v_tpfmemrq.dteeffec,'dd/mm/yyyy'),'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','FLGEMP','C',null,v_tpfmemrq.flgemp,'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','NUMMEMBER','C',null,v_tpfmemrq.nummember,'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','CODPFINF','C',null,v_tpfmemrq.codpfinf,'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','CODPLAN','C',null,v_tpfmemrq.codplann,'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','DTERETI','D',null,to_char(v_tpfmemrq.dtereti,'dd/mm/yyyy'),'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','CODRETI','C',null,v_tpfmemrq.codreti,'TPFMEMB',v_log_numseq);
      else
        update tpfmemb
           set flgemp    = v_tpfmemrq.flgemp,
               dtereti   = v_tpfmemrq.dtereti,
               rateeret  = v_tpfmemrq.ratereta,
               codpfinf  = v_tpfmemrq.codpfinf,
               dteupd    = trunc(sysdate),
               coduser   = p_coduser
         where codempid  = rq_codempid;
        upd_log(rq_codempid,'HRPYB2C10','DTEEFFEC','D',to_char(rec_old_tpfmemb.dteeffec,'dd/mm/yyyy'),to_char(v_tpfmemrq.dteeffec,'dd/mm/yyyy'),'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','FLGEMP','C',rec_old_tpfmemb.flgemp,v_tpfmemrq.flgemp,'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','NUMMEMBER','C',rec_old_tpfmemb.nummember,v_tpfmemrq.nummember,'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','CODPFINF','C',rec_old_tpfmemb.codpfinf,v_tpfmemrq.codpfinf,'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','CODPLAN','C',rec_old_tpfmemb.codplan,v_tpfmemrq.codplann,'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','DTERETI','D',to_char(rec_old_tpfmemb.dtereti,'dd/mm/yyyy'),to_char(v_tpfmemrq.dtereti,'dd/mm/yyyy'),'TPFMEMB',v_log_numseq);
        upd_log(rq_codempid,'HRPYB2C10','CODRETI','C',rec_old_tpfmemb.codreti,v_tpfmemrq.codreti,'TPFMEMB',v_log_numseq);
      end if;
      --
      if nvl(v_tpfmemrq.flgemp,0) <> '2' then
      --2 ins/upd tpfmemrt
        begin
          select count(*) into v_chkmemrt
            from tpfmemrt
           where codempid = rq_codempid
             and dteeffec = v_tpfmemrq.dtechg;
        end;
        --
        begin
          select *
            into rec_old_tpfmemrt
            from tpfmemrt
           where codempid = p_codempid
             and dteeffec = v_tpfmemrq.dtechg;
        exception when no_data_found then
          null;
        end;
        begin
          select * into rec_tpfdinf
            from tpfdinf
           where codcompy = get_codcompy(rec_old_tpfmemb.codcomp)
             and dteeffec = (select max(dteeffec) 
                             from tpfdinf 
                             where dteeffec <= sysdate 
                             and codcompy = get_codcompy(rec_old_tpfmemb.codcomp) 
                             and numseq = v_numseq)
             and numseq = v_numseq
             and (select trunc(months_between(sysdate,dteempmt))
                    from temploy1
                   where codempid = p_codempid)
                  between qtywkst and qtywken;
        exception when no_data_found then
          null;
        end;
        v_log_numseq  := get_log_numseq('HRPYB2C12',rq_codempid);
        if v_chkmemrt = 0 then
          insert into tpfmemrt (codempid, dteeffec, flgdpvf, ratecret, ratecsbt,
                                codcreate,coduser)
                        values (rq_codempid, v_tpfmemrq.dtechg, '2', v_tpfmemrq.ratereta, rec_tpfdinf.ratecsbt,
                                global_v_coduser, global_v_coduser);
          upd_log(rq_codempid,'HRPYB2C12','CODEMPID','C',null,rq_codempid,'TPFMEMRT',v_log_numseq);
          upd_log(rq_codempid,'HRPYB2C12','DTEEFFEC','D',null,to_char(v_tpfmemrq.dtechg,'dd/mm/yyyy'),'TPFMEMRT',v_log_numseq);
          upd_log(rq_codempid,'HRPYB2C12','FLGDPVF','C',null,'2','TPFMEMRT',v_log_numseq);
          upd_log(rq_codempid,'HRPYB2C12','RATECRET','N',null,v_tpfmemrq.ratereta,'TPFMEMRT',v_log_numseq);                   
--          insert into tpfmemrt(codempid,dteeffec,ratecret,dteupd,coduser)
--                        values(rq_codempid,v_tpfmemrq.dtechg,v_tpfmemrq.ratereta,trunc(sysdate),p_coduser);
        else
          upd_log(rq_codempid,'HRPYB2C12','FLGDPVF','C',rec_old_tpfmemrt.flgdpvf,2,'TPFMEMRT',v_log_numseq);
          upd_log(rq_codempid,'HRPYB2C12','RATECRET','N',rec_old_tpfmemrt.ratecret,v_tpfmemrq.ratereta,'TPFMEMRT',v_log_numseq, null, v_tpfmemrq.dtechg);
          update tpfmemrt
             set ratecret  = v_tpfmemrq.ratereta,
                 dteupd    = trunc(sysdate),
                 coduser   = p_coduser
           where codempid  = rq_codempid
             and dteeffec  = v_tpfmemrq.dtechg;
        end if;

        --3 del/ins tpfirinf
        v_first	:= 'Y';
        for i in c_tpfmemrq2 loop
          if v_first = 'Y' then
            v_first	:= 'N';
            delete tpfirinf where codempid = i.codempid and dteeffec = v_tpfmemrq.dtechg;
          end if;

          /*
          -- Change structure tpfirinf wait for Fix
          insert into tpfirinf(codempid,dteeffec,codpolicy,
                               codplan,qtycompst,dteupd,coduser)
                        values(i.codempid,v_tpfmemrq.dteplann,i.codpolicy, -- USER55 || 09/05/2019 || v_tpfmemrq.dtechg
                               i.codplan,i.qtycompst,trunc(sysdate),p_coduser);*/

        end loop;
      end if; --v_tpfmemrq.flgemp <> '2'

      --4 del/ins tpficinf
      delete tpficinf where codempid = rq_codempid ;
      --
      for i in c_tprofreq loop
        insert into tpficinf(codempid,numseq,nampfic,adrpfic,
                             desrel,ratepf,dteupd,coduser)
                      values(i.codempid,i.numseq,i.nampfic,i.adrpfic,
                             i.desrel,i.ratepf,trunc(sysdate),p_coduser);
      end loop;
      --
      begin
        select *
          into rec_old_tpfmemb
          from tpfmemb
         where codempid = rq_codempid;
      exception when no_data_found then
        null;
      end;

      v_log_numseq  := get_log_numseq('HRPYB2C12',rq_codempid);
      if p_flgemp = '2' then
        begin
          insert into tpfregst (codempid, dtereti, dteeffec, codpfinf,
                                codplan, codreti, amtcaccu, amtcretn,
                                amteaccu, amteretn, amtinteccu, amtintaccu,
                                rateeret, ratecret, codcreate, coduser)
          values (rq_codempid, rec_old_tpfmemb.dtereti, rec_old_tpfmemb.dteeffec, rec_old_tpfmemb.codpfinf,
                  rec_old_tpfmemb.codplan, rec_old_tpfmemb.codreti, rec_old_tpfmemb.amtcaccu, rec_old_tpfmemb.amtcretn,
                  rec_old_tpfmemb.amteaccu, rec_old_tpfmemb.amteretn, rec_old_tpfmemb.amtinteccu, rec_old_tpfmemb.amtintaccu,
                  rec_old_tpfmemb.rateeret, rec_old_tpfmemb.ratecret, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          update tpfregst
             set dteeffec    = rec_old_tpfmemb.dteeffec,
                 codreti     = rec_old_tpfmemb.codreti,
                 amtcaccu    = rec_old_tpfmemb.amtcaccu,
                 amtcretn    = rec_old_tpfmemb.amtcretn,
                 amteaccu    = rec_old_tpfmemb.amteaccu,
                 amteretn    = rec_old_tpfmemb.amteretn,
                 amtinteccu  = rec_old_tpfmemb.amtinteccu,
                 amtintaccu  = rec_old_tpfmemb.amtintaccu,
                 rateeret    = rec_old_tpfmemb.rateeret,
                 ratecret    = rec_old_tpfmemb.ratecret,
                 codpfinf    = rec_old_tpfmemb.codpfinf,
                 codplan     = rec_old_tpfmemb.codplan,
                 coduser     = global_v_coduser
          where codempid = rq_codempid
            and dtereti = rec_old_tpfmemb.dtereti;
        end;
        if v_tpfmemrq.codplann <> rec_old_tpfmemb.codplan or v_tpfmemrq.codpfinf <> rec_old_tpfmemb.codpfinf then
          v_log_numseq  := get_log_numseq('HRPYB2C11',rq_codempid);
          insert into tpfirinf (codempid,dteeffec,codplan,codpfinf,
                                codcreate,coduser)
          values (p_codempid,v_sysdate,v_tpfmemrq.codplann,v_tpfmemrq.codpfinf,
                  global_v_coduser,global_v_coduser);
          upd_log(rq_codempid,'HRPYB2C11','DTEEFFEC','D',null,to_char(v_sysdate,'dd/mm/yyyy'),'TPFIRINF',v_log_numseq,v_tpfmemrq.codplann);
          upd_log(rq_codempid,'HRPYB2C11','CODPLAN','C',rec_old_tpfmemb.codplan,v_tpfmemrq.codplann,'TPFIRINF',v_log_numseq,v_tpfmemrq.codplann);
          upd_log(rq_codempid,'HRPYB2C11','CODPFINF','C',rec_old_tpfmemb.codpfinf,v_tpfmemrq.codpfinf,'TPFIRINF',v_log_numseq,v_tpfmemrq.codplann);
        end if;
      end if;

    end if;
    -->> user22 : 30/03/2015

    update tpfmemrq
     set    staappr   = v_staappr,
            codappr   = v_codeappr,
            approvno  = v_approvno,
            dteappr   = p_dteappr,
            dteeffec  = p_dteeffec,
            coduser   = p_coduser,
            remarkap  = v_remark,
            dteapph   = sysdate
    where   codempid = rq_codempid
    and     dtereq   = rq_dtereq
    and     seqno    = v_seqno ;

    commit;
    --Step 5 Send Mail--
    begin
        select *
        into  v_tpfmemrq
        from  tpfmemrq
        where codempid =  rq_codempid
        and   dtereq   =  rq_dtereq
        and   seqno    = v_seqno ;
    exception when others then
     v_tpfmemrq := null ;
    end ;

    begin
        select rowid
        into v_row_id
        from  tpfmemrq
        where codempid =  rq_codempid
        and   dtereq   =  rq_dtereq
        and   seqno    = v_seqno ;
    exception when others then
        v_row_id := null;
    end;

    begin
        chk_workflow.sendmail_to_approve( p_codapp        => 'HRESS2E',
                                          p_codtable_req  => 'tpfmemrq',
                                          p_rowid_req     => v_row_id,
                                          p_codtable_appr => 'tapempch',
                                          p_codempid      => rq_codempid,
                                          p_dtereq        => rq_dtereq,
                                          p_seqno         => v_seqno,
                                          p_typchg        => 'HRESS2E',
                                          p_staappr       => v_staappr,
                                          p_approvno      => v_approvno,
                                          p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                          p_subject_mail_numseq  => '90',
                                          p_lang          => global_v_lang,
                                          p_coduser       => global_v_coduser);
     exception when others then
        param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
     end;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;

    rollback ;
    param_sqlerrm := sqlerrm;
  end;  -- Procedure Approve
  --
  procedure process_approve(json_str_input in clob, json_str_output out clob) is
    json_obj              json_object_t;
    json_obj2             json_object_t;

    v_rowcount      number:= 0;
    v_staappr       varchar2(400);
    v_appseq        number;
    v_chk           varchar2(10);
    v_numseq        number;
    v_codempid      varchar2(400);
    v_dtereq        varchar2(400);
    v_dteappr       varchar2(400);
    v_dteeffec      varchar2(400);
    v_flgemp        varchar2(400);

    v_remark        varchar2(4000);
    errm_str        varchar2(4000);
    resp_obj        json_object_t :=  json_object_t();
    resp_str        varchar2(4000 char);
    param_flgwarn   varchar2(200);

  begin
    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input).get_object('param_json');
    v_rowcount := json_obj.get_size;

      v_flgemp    := hcm_util.get_string_t(json_obj, 'p_flgemp');
      v_staappr   := hcm_util.get_string_t(json_obj, 'p_staappr');
      v_appseq    := to_number(hcm_util.get_string_t(json_obj, 'p_approvno'));
      v_chk       := hcm_util.get_string_t(json_obj, 'p_chk_appr');
      v_numseq    := to_number(hcm_util.get_string_t(json_obj, 'p_numseq'));
      v_codempid  := hcm_util.get_string_t(json_obj, 'p_codempid');
      v_dtereq    := to_date(hcm_util.get_string_t(json_obj, 'p_dtereq'),'dd/mm/yyyy');
      v_dteappr   := to_date(hcm_util.get_string_t(json_obj, 'p_dteappr'),'dd/mm/yyyy');
      v_dteeffec  := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'),'dd/mm/yyyy');
      param_flgwarn  := hcm_util.get_string_t(json_obj, 'p_flgwarn');

      v_staappr := nvl(v_staappr, 'A');
      if v_staappr = 'A' then
         v_remark := p_remark_appr;
      elsif v_staappr = 'N' then
         v_remark := p_remark_not_appr;
      end if;

      approve(global_v_coduser, global_v_lang, to_char(v_rowcount), v_staappr, v_appseq, v_chk,
              v_codempid, v_numseq, v_dtereq, v_dteappr, v_dteeffec, v_remark, v_flgemp, param_flgwarn);

      if param_msg_error is not null then
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      else
        commit;
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
  --
  procedure datatest(json_str in clob) as
    json_obj    json_object_t  := json_object_t(json_str);

    v_flgcreate varchar2(4000 char);
    v_coduser   varchar2(4000 char);
    v_codcomp   varchar2(4000 char);
    v_codempid  varchar2(4000 char);
    v_numseq 		number;
    v_dtereq		date;
    v_routeno   varchar2(4000 char);
  begin
    v_flgcreate := hcm_util.get_string_t(json_obj,'p_flgcreate');
    v_coduser   := hcm_util.get_string_t(json_obj,'p_coduser');
    v_codcomp   := hcm_util.get_string_t(json_obj,'p_codcomp');
    v_codempid  := hcm_util.get_string_t(json_obj,'p_codempid');
    v_numseq    := to_number(hcm_util.get_string_t(json_obj,'p_dataseed'));
    v_dtereq	  := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy hh24.mi.ss');
    v_routeno   := hcm_util.get_string_t(json_obj,'p_routeno');

    if v_flgcreate = 'Y' or v_flgcreate = 'N' then
      delete tpfmemrq
       where codempid = v_codempid
         and dtereq   = v_dtereq
         and seqno   = v_numseq;

--      tpfmemrq2 ??
--      tprofreq
--      insert or update tapempch
--      insert or update tpfmemb
--      insert or update tpfmemrt
--      insert tpfirinf
    end if;

    if v_flgcreate = 'Y' then
      null;
    end if;

    commit;
  end datatest;
end;

/

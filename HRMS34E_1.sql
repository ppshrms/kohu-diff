--------------------------------------------------------
--  DDL for Package Body HRMS34E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS34E" AS
  procedure initial_value(json_str in clob) AS
    json_obj        json_object_t := json_object_t(json_str);
  begin
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
--    b_index_codcomp     := rpad(hcm_util.get_string_t(json_obj,'p_codcomp'),21,'0');
--    p_limit             := hcm_util.get_string_t(json_obj,'p_limit');
--    p_start             := hcm_util.get_string_t(json_obj,'p_start');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');
    p_dtereq_st         := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_st'),'dd/mm/yyyy');
    p_dtereq_en         := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_en'),'dd/mm/yyyy');
    b_index_numseq      := hcm_util.get_string_t(json_obj,'p_numseq');
    b_index_dtereq      := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    --save_detail
    tab1_dtemov         := to_date(hcm_util.get_string_t(json_obj,'p_dtemov'),'dd/mm/yyyy');
    tab1_codcomp        := rpad(hcm_util.get_string_t(json_obj,'p_codcomp'),21,'0');
    tab1_codpos         := hcm_util.get_string_t(json_obj,'p_codpos');
    tab1_codjob         := hcm_util.get_string_t(json_obj,'p_codjob');
    tab1_codloca        := hcm_util.get_string_t(json_obj,'p_codloca');
    tab1_remark         := hcm_util.get_string_t(json_obj,'p_remark');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');
  END initial_value;
  --
  procedure gen_index(json_str_output out clob) AS
   obj_row       json_object_t;
    obj_data      json_object_t;
    v_total       number := 0;
    v_rcnt        number := 0;

  --cursor
  cursor c1 is
      select dtereq,dtemov,codcomp,numseq,codbrlc,staappr,remarkap,dteeffec,codappr,codempid,approvno
        from tmovereq
       where codcomp like b_index_codcomp||'%'
         and codempid = nvl(b_index_codempid,codempid)
         and dtereq between p_dtereq_st and p_dtereq_en
    order by dtereq desc,numseq desc;

--    select dtereq,dtemov,codcomp,numseq,codbrlc,staappr,remarkap,dteeffec,codappr,codempid,approvno from (
--    select dtereq,dtemov,codcomp,numseq,codbrlc,staappr,remarkap,dteeffec,codappr,codempid,approvno,rownum cnt from (
--    select dtereq,dtemov,codcomp,numseq,codbrlc,staappr,remarkap,dteeffec,codappr,codempid,approvno
--      from tmovereq
--     where codempid = b_index_codempid
--       and dtereq between p_dtereq_st and p_dtereq_en
--    order by dtereq desc,numseq desc))
--      where cnt between p_start and  (p_start + p_limit)-1 ;
  begin
    begin
      select count(*) into v_total
        from tmovereq
       where codcomp like b_index_codcomp||'%'
         and codempid = nvl(b_index_codempid,codempid)
         and dtereq between p_dtereq_st and p_dtereq_en
      order by dtereq desc,numseq desc;
    end;

    v_rcnt := 0;
    obj_row := json_object_t();
    obj_data := json_object_t();
    for i in c1 loop
    --
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('total', v_total);
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
      obj_data.put('numseq',i.numseq);
      obj_data.put('dtemov',nvl(to_char(i.dtemov,'dd/mm/yyyy'),''));
      obj_data.put('codcomp',nvl(i.codcomp,''));
      obj_data.put('desc_codcomp',nvl(get_tcenter_name(i.codcomp,global_v_lang),''));
      obj_data.put('codbrlc',nvl(i.codbrlc,''));
      obj_data.put('desc_codbrlc',nvl(get_tcodloca_name(i.codbrlc,global_v_lang),''));
      obj_data.put('status',nvl(get_tlistval_name('ESSTAREQ',i.staappr,global_v_lang),''));
      obj_data.put('staappr',nvl(i.staappr,''));
      obj_data.put('dteeffec',nvl(to_char(i.dteeffec,'dd/mm/yyyy'),''));
      obj_data.put('remarkap',nvl(replace(i.remarkap,chr(13)||chr(10),' '),''));
      obj_data.put('dteeffec',nvl(to_char(i.dteeffec,'dd/mm/yyyy'),''));
      obj_data.put('codappr',nvl(i.codappr,''));
      obj_data.put('desc_codappr',nvl(get_temploy_name(i.codappr,global_v_lang),''));
      obj_data.put('codempap',nvl(chk_workflow.get_next_approve('HRES34E',i.codempid,to_char(i.dtereq,'dd/mm/yyyy'),i.numseq,i.approvno,global_v_lang),''));
      obj_data.put('approvno',nvl(to_char(i.approvno),' '));

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_index(json_str_input in clob, json_str_output out clob) AS
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
  procedure gen_detail(json_str_output out clob) AS
    obj_row               json_object_t;
    detail_codempid       varchar2(4000 char);
    detail_dtereq         varchar2(4000 char);
    detail_numseq         varchar2(4000 char);
    detail_dtemov         date;
    detail_codcomp        varchar2(4000 char);
    detail_codcompt       varchar2(4000 char);
    detail_codpos         varchar2(4000 char);
    detail_codjob         varchar2(4000 char);
    detail_codbrlc        varchar2(4000 char);
    detail_descreq1       varchar2(4000 char);
    detail_desc_codpos    varchar2(4000 char);
    detail_desc_codjob    varchar2(4000 char);
    detail_desc_codbrlc   varchar2(4000 char);
    detail_desc_codcomp   varchar2(4000 char);
    detail_staappr        varchar2(4000 char);

  begin
    obj_row := json_object_t();

    --gen_data
    begin
      select dtemov,codcomp,codpos,codjob,codbrlc,descreq1,staappr
        into detail_dtemov,detail_codcomp,detail_codpos,detail_codjob,detail_codbrlc,detail_descreq1,detail_staappr
        from tmovereq
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq;
    exception when no_data_found then
      null;
    end;
      --
    detail_desc_codpos  	:= get_tpostn_name(detail_codpos,global_v_lang);
    detail_desc_codjob  	:= get_tjobcode_name(detail_codjob,global_v_lang);
    detail_desc_codbrlc 	:= get_tcodloca_name(detail_codbrlc,global_v_lang);
    detail_desc_codcomp   := get_tcenter_name(detail_codcomp,global_v_lang);
    --
    obj_row := json_object_t();
    obj_row.put('coderror','200');
    obj_row.put('desc_coderror','');
    obj_row.put('httpcode','');
    obj_row.put('flg','');
    obj_row.put('v_numseq',nvl(b_index_numseq,' '));
    obj_row.put('dtereq',nvl(to_char(b_index_dtereq,'dd/mm/yyyy'),' '));
    obj_row.put('dtemov',nvl(to_char(detail_dtemov,'dd/mm/yyyy'),' '));
    obj_row.put('codcomp',nvl(detail_codcomp,' '));
    obj_row.put('desc_codcomp',nvl(detail_desc_codcomp,' '));
    obj_row.put('codpos',nvl(detail_codpos,' '));
    obj_row.put('desc_codpos',nvl(detail_desc_codpos,' '));
    obj_row.put('codjob',nvl(detail_codjob,' '));
    obj_row.put('desc_codjob',nvl(detail_desc_codjob,' '));
    obj_row.put('codbrlc',nvl(detail_codbrlc,' '));
    obj_row.put('desc_codbrlc',nvl(detail_desc_codbrlc,' '));
    obj_row.put('descreq1',nvl(detail_descreq1,' '));
    obj_row.put('staappr',nvl(detail_staappr,' '));

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_detail(json_str_input in clob, json_str_output out clob) AS
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
  procedure gen_create(json_str_output out clob) AS
    obj_row         json_object_t;
    detail_codempid varchar2(4000 char);
    detail_dtereq   varchar2(4000 char);
    detail_numseq   varchar2(4000 char);
    detail_dtemov   varchar2(4000 char);
    detail_codcomp  varchar2(4000 char);
    detail_codcompt varchar2(4000 char);
    detail_codpos   varchar2(4000 char);
    detail_codjob   varchar2(4000 char);
    detail_codbrlc  varchar2(4000 char);
    detail_descreq1 varchar2(4000 char);

  begin
    obj_row := json_object_t();
      --gen_numseq
    select nvl(max(numseq),0) + 1
      into b_index_numseq
      from tmovereq
     where codempid = b_index_codempid
       and dtereq   = b_index_dtereq;
      --
    obj_row.put('coderror','200');
    obj_row.put('desc_coderror','');
    obj_row.put('httpcode','');
    obj_row.put('flg','');
    obj_row.put('v_numseq',nvl(b_index_numseq,''));
    obj_row.put('dtereq',nvl(to_char(b_index_dtereq,'dd/mm/yyyy'),' '));
    obj_row.put('dtemov','');
    obj_row.put('codcomp','');
    obj_row.put('desc_codcomp','');
    obj_row.put('codpos','');
    obj_row.put('desc_codpos','');
    obj_row.put('codjob','');
    obj_row.put('desc_codjob','');
    obj_row.put('codbrlc','');
    obj_row.put('desc_codbrlc','');
    obj_row.put('descreq1','');
    obj_row.put('staappr','');

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_create(json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_create(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_check_status(json_str_input in clob, json_str_output out clob) as
    obj_row     json_object_t;

    cursor c1 is
     select dtereq,numseq,staappr
      from  tmovereq
     where  codempid  = b_index_codempid
       and  dtereq    = b_index_dtereq
       and  numseq    = b_index_numseq;
  begin
    initial_value(json_str_input);

    for r1 in c1 loop
      if r1.staappr not in  ('P','C') then
        param_msg_error := get_error_msg_php('HR1490',global_v_lang);
      elsif b_index_dtereq < trunc(sysdate) then
        param_msg_error := get_error_msg_php('HR1515',global_v_lang);
      else
        param_msg_error := '';
      end if;
    end loop;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_check_status;
  --
  procedure ess_cancel_tmovereq(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    v_staappr     varchar(1 char);
    v_httpstatus  varchar2(100 char) := '200';
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    if b_index_dtereq is not null then
      if p_staappr = 'P' then
        v_staappr := 'C';
        begin
          update tmovereq
             set staappr = 'C' ,
                 dtecancel = sysdate,
                 coduser 	 = global_v_coduser
           where codempid  = b_index_codempid
             and dtereq    = b_index_dtereq
             and numseq    = b_index_numseq;
          commit;
          param_msg_error := get_error_msg_php('HR2421',global_v_lang);
          commit;
        exception when others then
          param_msg_error := sqlerrm;
          v_httpstatus := '400';
          rollback;
        end;
      elsif p_staappr = 'C' then
        param_msg_error := get_error_msg_php('HR1506',global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR1490',global_v_lang);
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end ess_cancel_tmovereq;
  --
  procedure ess_save_detail(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);

    check_index_detail;
    if param_msg_error is null then
      insert_next_step;
      if param_msg_error is null then
        save_detail;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end ess_save_detail;
  --
  procedure save_detail is
    v_count     number :=0;
    v_codcompt  varchar2(4000 char);
  begin
  --
    begin
    select count(*)
      into v_count
      from tmovereq
      where codempid  = b_index_codempid
        and dtereq    = b_index_dtereq
        and numseq    = b_index_numseq;
    end;
    --
    if v_count = 0 then
      begin
        select codcomp
          into v_codcompt
          from temploy1
         where codempid = b_index_codempid;
      exception when no_data_found then
        v_codcompt := '';
      end;
      insert into tmovereq( codempid,numseq,dtereq,codpos,
                            codjob,codbrlc,descreq1,staappr,
                            dteappr,dteeffec,dteupd,flgagency,
                            coduser,remarkap,codtrn,approvno,
                            routeno,
                            flgsend,dtecancel,dteinput,dtesnd,
                            dteapph,codcompt,dtemov,codcomp)

                    values( b_index_codempid,b_index_numseq,b_index_dtereq,tab1_codpos,
                            tab1_codjob,tab1_codloca,tab1_remark,p_staappr,
                            tab1_dteappr,tab1_remarkap,sysdate,null,
                            global_v_coduser,tab1_remarkap,null,tab1_approvno,
                            tab1_routeno,
                            null,tab1_dtecancel,sysdate,null,
                            null,v_codcompt,tab1_dtemov,tab1_codcomp);
         else
            update tmovereq set codempid  = b_index_codempid,
                                numseq    = b_index_numseq,
                                dtereq    = b_index_dtereq,
                                codpos    = tab1_codpos,
                                codjob    = tab1_codjob,
                                codbrlc   = tab1_codloca,
                                descreq1  = tab1_remark,
                                staappr   = p_staappr,
                                dteappr   = trunc(sysdate),
                                dteeffec  = sysdate,
                                dteupd    = sysdate,
                                flgagency = null,
                                coduser   = global_v_coduser,
                                remarkap  = tab1_remarkap,
                                codtrn    = null,
                                approvno  = tab1_approvno,
                                routeno   = tab1_routeno,
                                flgsend   = null,
                                dtecancel = tab1_dtecancel,
                                dtesnd    = null,
                                dteapph   = sysdate,
--                                codcompt  = b_index_codcomp,
                                codcomp   = tab1_codcomp,
                                dtemov    = tab1_dtemov

           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq;
        end if;
  end save_detail;
  --
  procedure check_index_detail is
  begin
      if tab1_dtemov is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;

      if tab1_codcomp is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;

      if tab1_codpos is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;

      if tab1_codjob is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;

      if tab1_codloca is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;

      if to_date(tab1_dtemov) < trunc(sysdate) then
        param_msg_error := get_error_msg_php('HR8519',global_v_lang);
        return;
      end if;

  end check_index_detail;
  --
  procedure check_index is
  begin
    --index
    if p_dtereq_st is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_dtereq_en is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_dtereq_st > p_dtereq_en  then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end;
  --
  PROCEDURE insert_next_step IS

    v_codapp     varchar2(10) := 'HRES34E';
    v_count      number := 0;
    v_table			 varchar2(50);
    v_error			 varchar2(50);
    v_codcompt   varchar2(4000 char);

  begin
 		   v_approvno         := 0;
		   v_codempap         := b_index_codempid;
       --
       b_index_dteinput   := sysdate;
       --
		   if p_staappr = 'C' then
		   	 tab1_dteinput := sysdate;
		   end if;

		   tab1_dtecancel  := null;
		   p_staappr       := 'P';

	     chk_workflow.find_next_approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dteinput,'dd/mm/yyyy'),b_index_numseq,v_approvno,v_codempap);

    --<< user22 : 20/08/2016 : HRMS590307 ||
      if v_routeno is null then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'twkflph');
        return;
      end if;
      --
      chk_workflow.find_approval(v_codapp,b_index_codempid,to_char(b_index_dteinput,'dd/mm/yyyy'),b_index_numseq,v_approvno,v_table,v_error);
      if v_error is not null then
        param_msg_error := get_error_msg_php(v_error,global_v_lang,v_table);
        return;
      end if;
    -->> user22 : 20/08/2016 : HRMS590307 ||

      loop
--       v_codempid_next := chk_workflow.check_next_approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dteinput,'dd/mm/yyyy'),b_index_numseq,v_approvno,v_codempap);
       v_codempid_next := chk_workflow.check_next_step(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dteinput,'dd/mm/yyyy'),b_index_numseq,v_approvno,v_codempap);

       if  v_codempid_next is not null then

         v_approvno      := v_approvno + 1 ;
         tab1_codappr    := v_codempid_next ;
         p_staappr       := 'A' ;
         tab1_dteappr    := trunc(sysdate);
         tab1_remarkap   := v_remark;
         tab1_approvno   := v_approvno;

          begin
            select count(*)
              into v_count
              from tapmoverq
             where codempid  = b_index_codempid
               and dtereq    = b_index_dteinput
               and numseq    = b_index_numseq
               and approvno  = v_approvno;
          exception when no_data_found then  v_count := 0;
          end;
          --
          begin
            select codcomp
              into v_codcompt
              from temploy1
             where codempid = b_index_codempid;
          exception when no_data_found then
            v_codcompt := '';
          end;

          if v_count = 0 then
            insert into tapmoverq
                    (codempid,dtereq,numseq,approvno,dtemov,codappr,dteappr,
                     codcomp,codcompt,codpos,codjob,codbrlc,dteeffec,
                     staappr,remarkap,coduser,dteapph)
            values  (b_index_codempid,b_index_dteinput,b_index_numseq,v_approvno,
                     tab1_dtemov,tab1_codappr,trunc(sysdate),tab1_codcomp,v_codcompt,
                     tab1_codpos,tab1_codjob,tab1_codloca,null,
                     p_staappr,tab1_remarkap,global_v_coduser,sysdate);
          else
            update tapmoverq set codappr   = tab1_codappr,
                                 dteappr   = trunc(sysdate),
                                 staappr   = p_staappr,
                                 remarkap  = v_remark ,
                                 coduser   = global_v_coduser,
                                 dteapph   = sysdate
               where  codempid  = b_index_codempid
               and    dtereq    = b_index_dteinput
               and		numseq		=	b_index_numseq
               and    approvno  = v_approvno;
          end if;
          chk_workflow.find_next_approve(v_codapp ,v_routeno,b_index_codempid,to_char(b_index_dteinput,'dd/mm/yyyy'),b_index_numseq,v_approvno,v_codempid_next);
       else
          exit ;
       end if;
    end loop;

    tab1_approvno     := v_approvno;
    tab1_routeno      := v_routeno;
    tab1_codempap     := v_codempap;
    tab1_codcompap    := v_codcompap;
    tab1_codposap     := v_codposap;
    commit;
  end;
END HRMS34E;

/

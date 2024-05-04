--------------------------------------------------------
--  DDL for Package Body HRRP34U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP34U" is
-- last update: 07/08/2020 09:40

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
    logic			          json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');

    p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');
    p_numisr            := hcm_util.get_string_t(json_obj,'p_numisr');

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtechng           := to_date(hcm_util.get_string_t(json_obj,'p_dtechng'),'ddmmyyyy');

    p_index_rows        := hcm_util.get_json_t(json_obj,'p_index_rows');
    p_selected_rows     := hcm_util.get_json_t(json_obj,'p_selected_rows');

    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'ddmmyyyy');

    p_condition         := hcm_util.get_string_t(json_obj,'p_condition');
    p_stasuccr          := hcm_util.get_string_t(json_obj,'p_stasuccr');
    p_numseq            := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    p_dteposdue         := to_date(hcm_util.get_string_t(json_obj,'p_dteposdue'),'ddmmyyyy');


    p_codemprq          := hcm_util.get_string_t(json_obj,'p_codemprq');
    p_flg               := hcm_util.get_string_t(json_obj,'p_flg');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

--p_codcomp := get_compful(p_codcomp); --for test,wait deploy front
  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_secur         varchar2(1 char) := 'N';
    v_flgpass     	boolean;

    v_cursor        number;
    v_idx           number := 0;
    v_codcompn      temploy1.codcomp%type;
    v_codposn       temploy1.codpos%type;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(4000 char);
    v_approvno      number;
    v_check         varchar2(500 char);
    v_codempid      tpromoted.codempid%type;
    v_stapromote    tpromote.stapromote%type;
    --user36 #4541 13/09/2021 where = p_codcomp Only (Full codcomp from index)/cancel get_compful.

    cursor c1 is
      select tpromoted.*,tpromote.stapromote
        from tpromoted ,tpromote
       where tpromoted.codcomp  = p_codcomp 
         and tpromoted.codpos   = p_codpos
         and tpromoted.dtereq   = nvl(p_dtereq, tpromoted.dtereq)
         and tpromoted.codcomp  = tpromote.codcomp
         and tpromoted.codpos   = tpromote.codpos
         and tpromoted.dtereq   = tpromote.dtereq
         and tpromote.staappr   <> 'C' --user36 #4547 14/09/2021 ||and tpromote.staappr   in ('P','A')
    order by codempid;

    cursor c2 is
      select *
        from tposempd
       where codcomp  = p_codcomp 
         and codpos   = p_codpos
         and codempid = v_codempid
    order by codempid;

    cursor c3 is
      select *
        from tsuccpln
       where codcomp  = p_codcomp 
         and codpos   = p_codpos
         and codempid = v_codempid
    order by codempid;

  begin
    --table
    v_rcnt  := 0;
    obj_row := json_object_t();

    for r1 in c1 loop
      v_flgdata     := 'Y';
      v_codempid    := r1.codempid;
      v_stapromote  := r1.stapromote;
      v_approvno    := nvl(r1.approvno,0) + 1;
      v_flgpass     := chk_flowmail.check_approve('HRRP33E', r1.codempid, v_approvno, global_v_codempid, r1.codcomp, r1.codpos, v_check);
      if (v_flgpass) then
        v_secur       := 'Y';
        obj_data      := json_object_t();
        v_rcnt        := v_rcnt + 1;
        obj_data.put('coderror', '200');
        obj_data.put('image', nvl(get_emp_img(r1.codempid), r1.codempid));
        obj_data.put('codempid',r1.codempid);
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid, global_v_lang));
        begin
          select codcomp, codpos
            into v_codcompn, v_codposn
            from temploy1
           where codempid= v_codempid;
        exception when others then
          v_codcompn := null;
          v_codposn  := null;
        end;
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('codpos',r1.codpos);
        obj_data.put('dtereq',to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('codcompn',v_codcompn);
        obj_data.put('desc_codcompn',get_tcenter_name(v_codcompn,global_v_lang));
        obj_data.put('codposn',v_codposn);
        obj_data.put('desc_codposn',get_tpostn_name(v_codposn,global_v_lang));
        if v_stapromote = '4' then
          for r2 in c2 loop
            obj_data.put('dteposdue', to_char(r2.dteposdue,'dd/mm/yyyy'));
          end loop;
        else
          for r3 in c3 loop
            obj_data.put('numseq',r3.numseq);
            obj_data.put('stasuccr',r3.stasuccr);
            obj_data.put('desc_stasuccr',GET_TLISTVAL_NAME('STASUCCR', r3.stasuccr, global_v_lang));
            obj_data.put('dteappr',to_char(r3.dteappr,'dd/mm/yyyy'));
            obj_data.put('codappr',r3.codappr);
            obj_data.put('desc_codappr',get_temploy_name(r3.codappr,global_v_lang));
            obj_data.put('dteyear',r3.dteyear);
            obj_data.put('numtime',r3.numtime);
          end loop;
        end if;
        obj_data.put('approvno',v_approvno);
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
    if v_flgdata = 'Y' AND v_secur = 'Y' then
      json_str_output := obj_row.to_clob;
    elsif v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TPROMOTED');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_secur = 'N' then
      param_msg_error := get_error_msg_php('HR3008', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;

  --
  procedure get_date(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_flgdata       varchar2(1 char) := 'N';
    cursor c1 is
      select *
        from tpromote
       where codcomp  = p_codcomp 
         and codpos   = p_codpos
         and dtereq   = p_dtereq;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    if param_msg_error is null then
      for r1 in c1 loop
        obj_row.put('dtereq',to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_row.put('codemprq',r1.codemprq);
        obj_row.put('coderror', '200');
      end loop;
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_index is
    v_flgSecur  boolean;
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';
    --user36 #4541 13/09/2021 where = p_codcomp Only (Full codcomp from index)/cancel get_compful.

    cursor c1 is
      select *
        from tcenter
       where codcomp = p_codcomp; 

    cursor c2 is
      select *
        from tpostn
       where codpos = p_codpos;

  begin
    if p_codcomp is not null then
      for i in c1 loop
        v_data  := 'Y';
        v_flgSecur := secur_main.secur7(p_codcomp,global_v_coduser);
        if v_flgSecur then
          v_chkSecur  := 'Y';
        end if;
      end loop;
      if v_data = 'N' then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      elsif v_chkSecur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    v_data := 'N';
    if p_codpos is not null then
      for i in c2 loop
        v_data  := 'Y';
      end loop;
      if v_data = 'N' then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
        return;
      end if;
    end if;
  end;

  procedure check_save is
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';
    v_codempid  temploy1.codempid%type;
    v_flgsecu   boolean;
    v_zupdsal   varchar2(400 char);
    v_staemp    temploy1.staemp%type;
  begin
    if p_flg = 'add' then
      if p_dtereq < trunc(sysdate) then
        param_msg_error := get_error_msg_php('HR8519',global_v_lang);
        return;
      end if;
    end if;

    if p_codemprq is not null then
      begin
        select codempid
          into v_codempid
          from temploy1
         where codempid = p_codemprq;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;

      v_flgsecu := secur_main.secur2(p_codemprq,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if not v_flgsecu then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;

      begin
        select staemp
          into v_staemp
          from temploy1
         where codempid = p_codemprq;
      exception when no_data_found then null;
      end;
      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      elsif v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure get_index_popup(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_popup(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index_popup(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_budget        number := 0;
    v_current       number := 0;
    v_ttexempt      number := 0;
    v_tranfero      number := 0;
    v_treqest       number := 0;
    v_treqestp      number := 0;
    v_treqestf      number := 0;
    v_tranferi      number := 0;
    v_vacancy       number := 0;
    --user36 #4541 13/09/2021 where = p_codcomp Only (Full codcomp from index)/cancel get_compful.

  begin
    v_rcnt          := 1;
    obj_row         := json_object_t();
    obj_data        := json_object_t();

    begin
      select nvl(qtybudgt,0)
        into v_budget
        from tbudgetm
       where codcomp    = p_codcomp 
         and codpos     = p_codpos
         and dteyrbug   = to_number(to_char(p_dtereq,'YYYY'))
         and dtemthbug  = to_number(to_char(p_dtereq,'MM'))
         and dtereq = (select max(dtereq)
                         from tbudgetm
                        where codcomp   = p_codcomp 
                          and codpos    = p_codpos
                          and dteyrbug  = to_number(to_char(p_dtereq,'YYYY'))
                          and dtemthbug = to_number(to_char(p_dtereq,'MM')));
    exception when others then
      v_budget := 0;
    end;

    begin
      select count(codempid)
        into v_current
        from temploy1
       where codcomp  = p_codcomp 
         and codpos   = p_codpos
         and staemp   in ('1','3');
    exception when others then
      v_budget := 0;
    end;

    begin
      select count(codempid)
        into v_ttexempt
        from ttexempt
       where codcomp  = p_codcomp 
         and codpos   = p_codpos
         and staupd   = 'C'
         and dteeffec > sysdate;
    exception when others then
      v_ttexempt := 0;
    end;

    begin
      select count(codempid)
        into v_tranfero
        from ttmovemt
       where codcompt   = p_codcomp
         and codposnow  = p_codpos
         and (codcomp   <> p_codcomp or codpos <> p_codpos) 
         and staupd     = 'C'
         and dteeffec   > sysdate;
    exception when others then
      v_tranfero := 0;
    end;

    begin
      select sum(qtyreq)
        into v_treqestp
        from treqest1 a, treqest2 b
       where a.numreqst = b.numreqst
         and b.codcomp  = p_codcomp 
         and b.codpos   = p_codpos
         and a.stareq   = 'P';
    exception when others then
      v_treqestp := 0;
    end;

    begin
      select sum(qtyreq - qtyact)
        into v_treqestf
        from treqest1 a, treqest2 b
       where a.numreqst = b.numreqst
         and b.codcomp  = p_codcomp 
         and b.codpos   = p_codpos
         and a.stareq   = 'F';
    exception when others then
      v_treqestf := 0;
    end;
    v_treqest := nvl(v_treqestp,0) + nvl(v_treqestf,0);

    if v_treqest = 0 then
      begin
        select count(codempid)
          into v_treqest
          from temploy1
         where codcomp  = p_codcomp 
           and codpos   = p_codpos
           and staemp   = '0';
      exception when others then
        v_treqest := 0;
      end;
    end if;

    begin
      select count(codempid)
        into v_tranferi
        from ttmovemt
       where (codcompt <> p_codcomp or codposnow <> p_codpos)
         and  codcomp  = p_codcomp 
         and codpos   = p_codpos
         and staupd   = 'C'
         and dteeffec > sysdate;
    exception when others then
      v_tranferi := 0;
    end;
    v_vacancy := v_budget - v_current + v_treqest + v_tranferi - v_ttexempt - v_tranfero;
    v_vacancy := greatest(v_vacancy,0); 

    obj_data.put('budget',v_budget);
    obj_data.put('current',v_current);
    obj_data.put('tranfero',v_tranfero + v_ttexempt);
    obj_data.put('tranferi',v_tranferi + v_treqest);
    obj_data.put('vacancy',v_vacancy);
    obj_row.put(to_char(v_rcnt-1),obj_data);
    json_str_output := obj_row.to_clob;
  end;

  procedure get_index_approve(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_approve(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index_approve(json_str_output out clob) is
    obj_data_main   json_object_t;
    obj_row_main    json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_row           json_object_t;

    v_rcnt_main     number := 0;
    v_rcnt          number := 0;

    v_codempid      tpromoted.codempid%type;
    v_codcomp       tpromoted.codcomp%type;
    v_codpos        tpromoted.codpos%type;
    v_dtereq        tpromoted.dtereq%type;

    v_approvno      number;
    v_flgpass     	boolean;
    v_check         varchar2(500 char);

    cursor c1 is
      select *
        from tappromote
       where codempid = v_codempid
         and codcomp = v_codcomp
         and codpos = v_codpos
         and dtereq = v_dtereq
         and approvno < v_approvno
    order by approvno;
  begin
    v_rcnt_main     := 0;
    obj_row_main    := json_object_t();
    for i in 0..p_index_rows.get_size-1 loop
      v_rcnt          := 0;
      v_row           := json_object_t();
      v_row           := hcm_util.get_json_t(p_index_rows,to_char(i));
      v_codempid      := hcm_util.get_string_t(v_row,'codempid');
      v_codcomp       := hcm_util.get_string_t(v_row,'codcomp');
      v_codpos        := hcm_util.get_string_t(v_row,'codpos');
      v_dtereq        := to_date(hcm_util.get_string_t(v_row,'dtereq'),'dd/mm/yyyy');
      v_approvno      := to_number(hcm_util.get_string_t(v_row,'approvno'));

      v_rcnt_main     := v_rcnt_main + 1;
      v_flgpass       := chk_flowmail.check_approve('HRRP33E', v_codempid, v_approvno, global_v_codempid, null, null, v_check);
      obj_row         := json_object_t();
      for r1 in c1 loop
        v_rcnt := v_rcnt +1;
        obj_data        := json_object_t();
        obj_data.put('codempid',v_codempid);
        obj_data.put('dtereq',to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('codpos',r1.codpos);
        obj_data.put('numseq',r1.approvno);
        obj_data.put('approvno',r1.approvno);
        obj_data.put('codappr',r1.codappr);
        obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('staappr',r1.staappr);
        obj_data.put('remark',r1.remarkap);
        obj_data.put('disabled',true);
        obj_data.put('flglastappr',false);
        obj_data.put('dteeffec','');
        obj_data.put('codtrn','');
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;

      v_rcnt          := v_rcnt +1;
      obj_data        := json_object_t();
      obj_data.put('codempid',v_codempid);
      obj_data.put('dtereq',to_char(v_dtereq,'dd/mm/yyyy'));
      obj_data.put('codcomp',v_codcomp);
      obj_data.put('codpos',v_codpos);
      obj_data.put('numseq',v_approvno);
      obj_data.put('approvno',v_approvno);
      obj_data.put('codappr',global_v_codempid);
      obj_data.put('dteappr',to_char(trunc(sysdate),'dd/mm/yyyy'));
      obj_data.put('staappr','Y');
      obj_data.put('remark','');
      obj_data.put('disabled',false);
      if v_check = 'Y' then
        obj_data.put('flglastappr',true);
        obj_data.put('dteeffec',to_char(trunc(sysdate),'dd/mm/yyyy'));
        obj_data.put('codtrn','');
      else
        obj_data.put('flglastappr',false);
        obj_data.put('dteeffec','');
        obj_data.put('codtrn','');
      end if;
      obj_row.put(to_char(v_rcnt-1),obj_data);

      obj_data_main   := json_object_t();
      obj_data_main.put('coderror', '200');
      obj_data_main.put('codempid',v_codempid);
      obj_data_main.put('desc_codempid',get_temploy_name(v_codempid, global_v_lang));
      obj_data_main.put('detail',obj_row);
      obj_row_main.put(to_char(v_rcnt_main-1),obj_data_main);
    end loop;

    json_str_output := obj_row_main.to_clob;
  end;

  procedure send_approve(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    v_codcomp       tappromote.codcomp%type;
    v_codpos        tappromote.codpos%type;
    v_dtereq        tappromote.dtereq%type;
    v_codempid      tappromote.codempid%type;
    v_approvno      tappromote.approvno%type;
    v_codappr       tappromote.codappr%type;
    v_dteappr       tappromote.dteappr%type;
    v_remark        tappromote.remarkap%type;
    v_staappr       tappromote.staappr%type;
    v_staappr2      tappromote.staappr%type;
    v_dteeffec      tpromoted.dteeffec%type;
    v_codtrn        tpromoted.codtrn%type;
    v_msg_to        clob;
    v_templete_to   clob;
    v_func_appr     tfwmailh.codappap%type;
    v_rowid         rowid;
    v_error			    terrorm.errorno%type;
    v_codform		    tfwmailh.codform%type;
    v_codformno     tfwmailh.codformno%type; ----
    v_flgsecu       boolean;
    v_zupdsal       varchar2(400);

    v_flgpass       boolean;
    v_check         varchar2(500 char);
    v_flgchng       tchgins1.flgchng%type;

    v_numseq        ttmovemt.numseq%type;
    v_stapost2      ttmovemt.stapost2%type;
    v_codcompt      ttmovemt.codcompt%type;
    v_codposnow     ttmovemt.codposnow%type;
    v_flgduepr      ttmovemt.flgduepr%type;
    v_flggroup      ttmovemt.flggroup%type;
    v_flgadjin      ttmovemt.flgadjin%type;
    v_flgrp         ttmovemt.flgrp%type;
    v_amtincom      ttmovemt.amtincom1%type;
    v_amtincadj     ttmovemt.amtincadj1%type;
    v_staupd        ttmovemt.staupd%type;
    v_codreq        ttmovemt.codreq%type;

    v_codjob        ttmovemt.codjob%type;
    v_numlvl        ttmovemt.numlvl%type;
    v_codbrlc       ttmovemt.codbrlc%type;
    v_codcalen      ttmovemt.codcalen%type;
    v_flgatten      ttmovemt.flgatten%type;
    v_codempmt      ttmovemt.codempmt%type;
    v_typpayroll    ttmovemt.typpayroll%type;
    v_typemp        ttmovemt.typemp%type;
    v_codsex        ttmovemt.codsex%type;
    v_amtothr       ttmovemt.amtothr%type;
    v_jobgrade      ttmovemt.jobgrade%type;
    v_codgrpgl      ttmovemt.codgrpgl%type;
    v_dteefpos      ttmovemt.dteefpos%type;
    v_dteeflvl      ttmovemt.dteeflvl%type;
    v_dteefstep     ttmovemt.dteefstep%type;
    v_codcurr       ttmovemt.codcurr%type;
    v_flglastappr   boolean;
  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
      begin --user36 #4548 10/09/2021
        select codform,codformno
          into v_codform,v_codformno
          from tfwmailh
         where codapp = 'HRRP34U';
      exception
      when no_data_found then
        v_codform := null;
        v_codformno := null;
      end;
      
      for i in 0..p_selected_rows.get_size-1 loop
          obj_row     := json_object_t();
          obj_row     := hcm_util.get_json_t(p_selected_rows,to_char(i));
          v_staappr   := hcm_util.get_string_t(obj_row,'staappr');
          v_codtrn    := hcm_util.get_string_t(obj_row,'codtrn');
          v_flglastappr := hcm_util.get_boolean_t(obj_row,'flglastappr');
          if v_flglastappr and v_codtrn is null and v_staappr = 'Y' then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
          end if;
      end loop;
      
      begin
        for i in 0..p_selected_rows.get_size-1 loop
          obj_row     := json_object_t();
          obj_row     := hcm_util.get_json_t(p_selected_rows,to_char(i));
          v_codcomp   := hcm_util.get_string_t(obj_row,'codcomp');
          v_codpos    := hcm_util.get_string_t(obj_row,'codpos');
          v_dtereq    := to_date(hcm_util.get_string_t(obj_row,'dtereq'),'dd/mm/yyyy');
          v_codempid  := hcm_util.get_string_t(obj_row,'codempid');
          v_approvno  := hcm_util.get_string_t(obj_row,'approvno');
          v_dteappr   := to_date(hcm_util.get_string_t(obj_row,'dteappr'),'dd/mm/yyyy');
          v_codappr   := hcm_util.get_string_t(obj_row,'codappr');
          v_staappr   := hcm_util.get_string_t(obj_row,'staappr');
          v_remark    := hcm_util.get_string_t(obj_row,'remark');
          v_dteeffec  := to_date(hcm_util.get_string_t(obj_row,'dteeffec'),'dd/mm/yyyy');
          v_codtrn    := hcm_util.get_string_t(obj_row,'codtrn');
          v_flglastappr := hcm_util.get_boolean_t(obj_row,'flglastappr');
          begin
            select rowid
              into v_rowid
              from tpromoted
             where codcomp  = v_codcomp
               and codpos   = v_codpos
               and dtereq   = v_dtereq
               and codempid = v_codempid;
          exception when no_data_found then null;
          end;
          begin
            select codemprq
              into v_codreq
              from tpromote
             where codcomp  = v_codcomp
               and codpos   = v_codpos
               and dtereq   = v_dtereq;
          exception when others then
            v_codreq := null;
          end;

          insert into tappromote (codcomp,codpos,dtereq,codempid,approvno,
                                 dteappr,codappr,staappr,remarkap,
                                 dtecreate,codcreate,dteupd,coduser)
          values (v_codcomp,v_codpos,v_dtereq,v_codempid,v_approvno,
                                 v_dteappr,v_codappr,v_staappr,v_remark,
                                 sysdate,global_v_coduser,sysdate,global_v_coduser);

          if v_staappr = 'N' then
            update tpromote
               set staappr = 'C',
                   codappr = v_codappr,
                   dteappr = v_dteappr
             where codcomp = v_codcomp
               and codpos = v_codpos
               and dtereq = v_dtereq;

            update tpromoted
               set staappr = v_staappr,
                   codappr = v_codappr,
                   dteappr = v_dteappr,
                   remarkap = v_remark,
                   approvno = v_approvno
             where codcomp = v_codcomp
               and codpos = v_codpos
               and dtereq = v_dtereq
               and codempid = v_codempid;

            --<<user36 #4548 10/09/2021 add send mail for Not Approve
            ---ส่งเมล NO Approve แจ้ง Reply ผู้อนุมัติที่กำหนดใน CO            
            begin
              v_error := chk_flowmail.send_mail_reply('HRRP34U',v_codempid,v_codreq,v_codappr, global_v_coduser, NULL, 'HRRP34U1', 330, 'U', v_staappr, v_approvno, v_codcomp, v_codpos, 'TPROMOTED', v_rowid, null, null);              
            exception when others then
              param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
            end;
            -->>
          else
            v_flgpass := chk_flowmail.check_approve('HRRP33E', v_codempid, v_approvno, global_v_codempid, null, null, v_check);
            if v_check = 'Y' then --Last Approve Step
              v_staappr2 := 'Y';

              update tpromote
                 set staappr = 'C', --user36 #4547 14/09/2021 ||v_staappr2,
                     codappr = v_codappr,
                     dteappr = v_dteappr
               where codcomp = v_codcomp
                 and codpos = v_codpos
                 and dtereq = v_dtereq;

              update tpromoted
                 set staappr = v_staappr2,
                     codappr = v_codappr,
                     dteappr = v_dteappr,
                     remarkap = v_remark,
                     dteeffec = v_dteeffec,
                     codtrn = v_codtrn,
                     approvno = v_approvno
               where codcomp = v_codcomp
                 and codpos = v_codpos
                 and dtereq = v_dtereq
                 and codempid = v_codempid;        

              begin
                select nvl(max(numseq),0) + 1
                  into v_numseq
                  from ttmovemt
                 where codempid = v_codempid
                   and dteeffec = v_dteeffec;
              exception when others then
                v_numseq := 1;
              end;

              /*begin
                select codemprq
                  into v_codreq
                  from tpromote
                 where codcomp = v_codcomp
                   and codpos = v_codpos
                   and dtereq = v_dtereq;
              exception when others then
                v_numseq := 1;
              end;*/

              v_stapost2  := '0';
              v_flgduepr  := 'N';
              v_flggroup  := 'N';
              v_flgadjin  := 'N';
              v_flgrp     := 'N';
              v_staupd    := 'C';
              v_amtincom  := stdenc(0, v_codempid, global_v_chken);
              v_amtincadj := stdenc(0, v_codempid, global_v_chken);
              v_amtothr   := stdenc(0, v_codempid, global_v_chken);

              begin
                select codcomp, codpos, codjob, numlvl, codbrlc, codcalen, flgatten,
                       codempmt, typpayroll, typemp, codsex,
                       jobgrade, codgrpgl, dteefpos, dteeflvl, dteefstep
                  into v_codcompt, v_codposnow, v_codjob, v_numlvl, v_codbrlc, v_codcalen, v_flgatten,
                       v_codempmt, v_typpayroll, v_typemp, v_codsex,
                       v_jobgrade, v_codgrpgl, v_dteefpos, v_dteeflvl, v_dteefstep
                  from temploy1
                 where codempid = v_codempid;
              exception when no_data_found then null;
              end;

              begin
                select codcurr
                  into v_codcurr
                  from temploy3
                 where codempid = v_codempid;
              exception when no_data_found then null;
              end;

              insert into ttmovemt (codempid,dteeffec,numseq,codtrn,codcomp,
                                  codpos,codjob,numlvl,codbrlc,codcalen,
                                  flgatten,stapost2,dteduepr,flgduepr,codcompt, ----add dteduepr=dteeffec
                                  codposnow,codjobt,numlvlt,codbrlct,codcalet,
                                  flgattet,flgadjin,codsex,flgrp,staupd,
                                  codempmtt,codempmt,typpayrolt,typpayroll,typempt,typemp,
                                  amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                                  amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                                  amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,
                                  amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,
                                  amtothr,codcurr,codappr,dteappr,remarkap,
                                  flggroup,codreq,jobgrade,jobgradet,codgrpgl,
                                  codgrpglt,dteefpos,dteeflvl,dteefstep,approvno,
                                  dtecreate,codcreate,dteupd,coduser)
                        values (v_codempid,v_dteeffec,v_numseq,v_codtrn,v_codcomp,
                                v_codpos,v_codjob, v_numlvl, v_codbrlc, v_codcalen,
                                v_flgatten,v_stapost2,v_dteeffec,v_flgduepr,v_codcompt,
                                v_codposnow,v_codjob, v_numlvl, v_codbrlc, v_codcalen,
                                v_flgatten,v_flgadjin,v_codsex,v_flgrp,v_staupd,
                                v_codempmt,v_codempmt,v_typpayroll,v_typpayroll,v_typemp,v_typemp,
                                v_amtincom,v_amtincom,v_amtincom,v_amtincom,v_amtincom,
                                v_amtincom,v_amtincom,v_amtincom,v_amtincom,v_amtincom,
                                v_amtincadj,v_amtincadj,v_amtincadj,v_amtincadj,v_amtincadj,
                                v_amtincadj,v_amtincadj,v_amtincadj,v_amtincadj,v_amtincadj,
                                v_amtothr,v_codcurr,v_codappr,v_dteappr,v_remark,
                                v_flggroup,v_codreq,v_jobgrade,v_jobgrade,v_codgrpgl,
                                v_codgrpgl,v_dteefpos,v_dteeflvl,v_dteefstep,v_approvno,
                                sysdate,global_v_coduser,sysdate,global_v_coduser);
              ---ส่งเมลหาผู้ขออนุมัติ
              /*--user36 #4548 10/09/2021
              v_codform := 'HRRP34U';
              begin
                chk_flowmail.get_message_result(v_codform, global_v_lang, v_msg_to, v_templete_to);
                chk_flowmail.replace_text_frmmail(v_templete_to, 'TPROMOTED', v_rowid, get_label_name('HRRP34U1', global_v_lang, 330), v_codform, '1', null, global_v_coduser, global_v_lang, v_msg_to);
                v_error := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL, get_label_name('HRRP34U1', global_v_lang, 330), 'U', global_v_lang, null);
              */
              begin --user36 #4548 10/09/2021
                v_error := chk_flowmail.send_mail_reply('HRRP34U',v_codempid,v_codreq,v_codappr, global_v_coduser, NULL, 'HRRP34U1', 330, 'U', v_staappr, v_approvno, v_codcomp, v_codpos, 'TPROMOTED', v_rowid, null, null); --user36 #4548 10/09/2021
              exception when others then
                param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
              end;

            else --Not Last Approve Step
              v_staappr2 := 'A';
              update tpromoted
                 set staappr = v_staappr2,
                     codappr = v_codappr,
                     dteappr = v_dteappr,
                     remarkap = v_remark,
                     approvno = v_approvno
               where codcomp = v_codcomp
                 and codpos = v_codpos
                 and dtereq = v_dtereq
                 and codempid = v_codempid;
                 
                 
              begin --user36 #4548 10/09/2021
                v_error := chk_flowmail.send_mail_reply('HRRP34U',v_codempid,v_codreq,v_codappr, global_v_coduser, NULL, 'HRRP34U1', 330, 'U', v_staappr, v_approvno, v_codcomp, v_codpos, 'TPROMOTED', v_rowid, null, null); --user36 #4548 10/09/2021
              exception when others then
                param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
              end;
              
              --Send mail to Next Approve Step
              begin
                --user36 #4548 10/09/2021
--                chk_flowmail.get_message('HRRP34U', global_v_lang, v_msg_to, v_templete_to, v_func_appr);
--                chk_flowmail.replace_text_frmmail(v_templete_to, 'TPROMOTED', v_rowid, get_label_name('HRRP34U1', global_v_lang, 320), v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to);
--                v_error := chk_flowmail.send_mail_to_approve('HRRP34U' , v_codempid, global_v_coduser, v_msg_to, NULL, get_label_name('HRRP34U1', global_v_lang, 320), 'U', v_staappr, global_v_lang, v_approvno + 1, null, null);
                
                v_error := chk_flowmail.send_mail_for_approve('HRRP33E', v_codempid, v_codreq, global_v_coduser, null, 'HRRP34U1', 320, 'U', v_staappr, v_approvno + 1, null, null,'TPROMOTED',v_rowid, '1', 'Oracle');
              exception when others then
                param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
              end;
            end if;
          end if;
        end loop;
        commit;
      exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end;
      if param_msg_error_mail is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      else
        json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_change_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_change_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_change_detail(json_str_output out clob) is
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_qtyf          number;
    v_qtyfo         number;
    cursor c1 is
      select *
        from tchgins1
       where codempid = p_codempid_query
         and numisr = p_numisr
         and dtechng = p_dtechng;
  begin
    v_rcnt          := 0;
    obj_data        := json_object_t();

    for r1 in c1 loop
      obj_data.put('coderror', '200');
      obj_data.put('codisrpo', r1.codisrpo);
      obj_data.put('desc_codisrpo', get_tcodec_name('TCODISRP', r1.codisrpo, global_v_lang));
      obj_data.put('codisrp', r1.codisrp);
      obj_data.put('desc_codisrp', get_tcodec_name('TCODISRP', r1.codisrp, global_v_lang));
      obj_data.put('dtehlpst', to_char(r1.dtehlpst,'dd/mm/yyyy'));
      obj_data.put('dtehlpsto', to_char(r1.dtehlpsto,'dd/mm/yyyy'));
      obj_data.put('dtehlpen', to_char(r1.dtehlpen,'dd/mm/yyyy'));
      obj_data.put('dtehlpeno', to_char(r1.dtehlpeno,'dd/mm/yyyy'));
      obj_data.put('amtisrp', to_char(nvl(r1.amtisrp,0),'fm999,999,999,990.00'));
      obj_data.put('amtisrpo', to_char(nvl(r1.amtisrpo,0),'fm999,999,999,990.00'));
      if r1.codecovo = 'Y' and r1.codfcovo = 'Y' then
        obj_data.put('desc_codcovo', get_label_name('HRBF3ZU2',global_v_lang,170));
      elsif r1.codecovo = 'Y' then
        obj_data.put('desc_codcovo', get_label_name('HRBF3ZU2',global_v_lang,160));
      else
        obj_data.put('desc_codcovo', get_label_name('HRBF3ZU2',global_v_lang,270));
      end if;
      if r1.codecov = 'Y' and r1.codfcov = 'Y' then
        obj_data.put('desc_codcov', get_label_name('HRBF3ZU2',global_v_lang,170));
      elsif r1.codecov = 'Y' then
        obj_data.put('desc_codcov', get_label_name('HRBF3ZU2',global_v_lang,160));
      else
        obj_data.put('desc_codcov', get_label_name('HRBF3ZU2',global_v_lang,270));
      end if;
      if nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiummc,0) > 0 then
        obj_data.put('flgmonth',true);
      else
        obj_data.put('flgmonth',false);
      end if;
      obj_data.put('amtpmiumm', to_char(nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiummc,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiummo', to_char(nvl(r1.amtpmiummeo,0) + nvl(r1.amtpmiummco,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumy', to_char(nvl(r1.amtpmiumye,0) + nvl(r1.amtpmiumyc,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumyo', to_char(nvl(r1.amtpmiumyeo,0) + nvl(r1.amtpmiumyco,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumme', to_char(nvl(r1.amtpmiumme,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiummeo', to_char(nvl(r1.amtpmiummeo,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumye', to_char(nvl(r1.amtpmiumye,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumyeo', to_char(nvl(r1.amtpmiumyeo,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiummc', to_char(nvl(r1.amtpmiummc,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiummco', to_char(nvl(r1.amtpmiummco,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumyc', to_char(nvl(r1.amtpmiumyc,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumyco', to_char(nvl(r1.amtpmiumyco,0),'fm999,999,999,990.00'));
      obj_data.put('remark',r1.remark);
      obj_data.put('dteupdate',to_char(r1.dteupd,'dd/mm/yyyy'));
      obj_data.put('updateby',get_codempid(r1.coduser) || ' - ' || get_temploy_name(get_codempid(r1.coduser),global_v_lang));

      begin
          select count(numseq)
            into v_qtyfo
            from tinsrdp
           where codempid = p_codempid_query
             and numisr = p_numisr;
      exception when others then
        v_qtyfo := 0;
      end;

      begin
        select count(numseq)
          into v_qtyf
          from tchgins2
         where codempid = p_codempid_query
           and numisr = p_numisr
           and dtechng = p_dtechng;
      exception when others then
        v_qtyf := 0;
      end;

      obj_data.put('qtyf',v_qtyf);
      obj_data.put('qtyfo',v_qtyfo);

    end loop;
    json_str_output := obj_data.to_clob;
  end;

  procedure get_list_insured(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_list_insured(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_list_insured(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    cursor c1 is
        select *
          from tchgins2
         where codempid = p_codempid_query
           and numisr = p_numisr
           and dtechng = p_dtechng
      order by numseq;

    cursor c2 is
        select *
          from tinsrdp
         where codempid = p_codempid_query
           and numisr = p_numisr
      order by numseq;
  begin
    v_rcnt  := 0;
    obj_row := json_object_t();

    for r1 in c1 loop
      v_flgdata     := 'Y';
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
      obj_data.put('numisr', r1.numisr);
      obj_data.put('dtechng', to_char(r1.dtechng,'dd/mm/yyyy'));
      obj_data.put('numseq', r1.numseq);
      obj_data.put('nameinsr', r1.nameinsr);
      obj_data.put('typrelate', r1.typrelate);
      obj_data.put('desc_typrelate', get_tlistval_name('TYPRELATE',r1.typrelate,global_v_lang));
      obj_data.put('dteempdb', to_char(r1.dteempdb,'dd/mm/yyyy'));
      obj_data.put('flgchng', get_tlistval_name('FLGCHNG',r1.flgchng,global_v_lang));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_flgdata = 'N' then
      for r2 in c2 loop
        v_rcnt        := v_rcnt+1;
        obj_data      := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', r2.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r2.codempid,global_v_lang));
        obj_data.put('numisr', r2.numisr);
        obj_data.put('dtechng', '');
        obj_data.put('numseq', r2.numseq);
        obj_data.put('nameinsr', r2.nameinsr);
        obj_data.put('typrelate', r2.typrelate);
        obj_data.put('desc_typrelate', get_tlistval_name('TYPRELATE',r2.typrelate,global_v_lang));
        obj_data.put('dteempdb', to_char(r2.dteempdb,'dd/mm/yyyy'));
        obj_data.put('flgchng', '');
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end;

  procedure get_beneficiary(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_beneficiary(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_beneficiary(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    cursor c1 is
      select *
        from tchgins3
       where codempid = p_codempid_query
         and numisr = p_numisr
         and dtechng = p_dtechng
    order by numseq;

    cursor c2 is
      select *
        from tbficinf
       where codempid = p_codempid_query
         and numisr = p_numisr
    order by numseq;
  begin
    v_rcnt  := 0;
    obj_row := json_object_t();

    for r1 in c1 loop
      v_flgdata     := 'Y';
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
      obj_data.put('numisr', r1.numisr);
      obj_data.put('dtechng', to_char(r1.dtechng,'dd/mm/yyyy'));
      obj_data.put('numseq', r1.numseq);
      obj_data.put('nambfisr', r1.nambfisr);
      obj_data.put('typrelate', r1.typrelate);
      obj_data.put('desc_typrelate', get_tlistval_name('TYPRELATE',r1.typrelate,global_v_lang));
      obj_data.put('ratebf', to_char(nvl(r1.ratebf,0),'fm9,999,999.00'));
      obj_data.put('flgchng', get_tlistval_name('FLGCHNG',r1.flgchng,global_v_lang));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_flgdata = 'N' then
      for r2 in c2 loop
        v_rcnt        := v_rcnt+1;
        obj_data      := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', r2.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r2.codempid,global_v_lang));
        obj_data.put('numisr', r2.numisr);
        obj_data.put('dtechng', '');
        obj_data.put('numseq', r2.numseq);
        obj_data.put('nambfisr', r2.nambfisr);
        obj_data.put('typrelate', r2.typrelate);
        obj_data.put('desc_typrelate', get_tlistval_name('TYPRELATE',r2.typrelate,global_v_lang));
        obj_data.put('ratebf', to_char(nvl(r2.ratebf,0),'fm9,999,999.00'));
        obj_data.put('flgchng', '');
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end;
end;

/

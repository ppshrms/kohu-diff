--------------------------------------------------------
--  DDL for Package Body HRRP2AU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP2AU" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_year        := hcm_util.get_string_t(json_obj,'p_year');
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_codlinef    := hcm_util.get_string_t(json_obj,'p_codlinef');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codpos      := hcm_util.get_string_t(json_obj,'p_codpos');
    b_index_dtereq      := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure check_index is
    v_error   varchar2(4000);
  begin
    -- p_compgrp check in frontend
    -- b_index_codlinef check in frontend
    if b_index_codcompy is not null then
      v_error   := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcompy);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;
    end if;
    if b_index_codcomp is not null then
      v_error   := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;
    end if;
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_chk_flow      boolean := false;
    v_chk_data      varchar2(1) := 'N';
    v_chk_secur     varchar2(1) := 'N';
    v_check         varchar2(50);
    v_approvno      tbudget.approvno%type;
    v_flg_found     varchar2(1) := 'N';

    cursor c_budget is
      select c.dteyrbug, c.codcomp, c.codpos, c.qtyreqyr, c.amttotbudgt,c.remarkrq,
             c.dtereq, c.codemprq, c.staappr , c.dteappr, c.codappr, c.approvno
        from tbudget c
       where dteyrbug   = b_index_year
         and staappr    in ('P','A')
         and ((codcomp   like b_index_codcomp||'%' and b_index_codcomp is not null)
           or (codcomp,codpos) in (select b.codcompp, b.codpospr
                                    from thisorg a, thisorg2 b
                                   where a.codcompy     = b.codcompy
                                     and a.codlinef     = b.codlinef
                                     and a.dteeffec     = b.dteeffec
                                     and a.codcompy     = nvl(b_index_codcompy,a.codcompy)
                                     and a.codlinef     = nvl(b_index_codlinef,a.codlinef)
                                     and b.codcompp     like b_index_codcomp||'%'
                                     and to_char(a.dteeffec,'yyyy') <= b_index_year
                                     and a.staorg       = 'A'))
      order by c.codcomp, c.codpos;

  begin
    obj_row   := json_object_t();
    for i in c_budget loop
      v_chk_data    := 'Y';
      v_approvno    := nvl(i.approvno,0) + 1;
      v_chk_flow    := chk_flowmail.check_approve('HRRP23E',i.codemprq,v_approvno,global_v_codempid,null,null,v_check);
      if v_chk_flow then
        v_chk_secur := 'Y';
        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('dteyrbug',i.dteyrbug);
        obj_data.put('codcomp',i.codcomp);
        obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp, global_v_lang));
        obj_data.put('codpos',i.codpos);
        obj_data.put('desc_codpos',get_tpostn_name(i.codpos , global_v_lang));
        obj_data.put('qtyreq',i.qtyreqyr);
        obj_data.put('budget',to_char(i.amttotbudgt,'fm999,999,999,990.00'));
        obj_data.put('remark',i.remarkrq);
        obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
        obj_data.put('codemprq',i.codemprq);
        obj_data.put('reqby',i.codemprq||' - '||get_temploy_name(i.codemprq,global_v_lang));
        obj_data.put('staappr',i.staappr);
        obj_data.put('desc_status',get_tlistval_name('STAAPPR', i.staappr,global_v_lang));
        obj_data.put('dteapprov',to_char(i.dteappr,'dd/mm/yyyy'));
        obj_data.put('codappr',i.codappr);
        obj_data.put('approvby',i.codappr||' - '||get_temploy_name(i.codappr,global_v_lang));

        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt      := v_rcnt + 1;
      end if;
    end loop;
    if v_chk_data = 'N' then
      begin
        select 'X'
          into v_flg_found
          from thisorg a, thisorg2 b
         where a.codcompy     = b.codcompy
           and a.codlinef     = b.codlinef
           and a.dteeffec     = b.dteeffec
           and a.codcompy     = nvl(b_index_codcompy,a.codcompy)
           and a.codlinef     = nvl(b_index_codlinef,a.codlinef)
           and b.codcompp     like b_index_codcomp||'%'
           and to_char(a.dteeffec,'yyyy') <= b_index_year
           and a.staorg       = 'A'
           and rownum         = 1;
        param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'tbudget');
        return;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'thisorg2');
        return;
      end;
    elsif v_chk_secur = 'N' then
      param_msg_error   := get_error_msg_php('HR3008',global_v_lang);
      return;
    end if;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_index(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_approve(json_str_input in clob, json_str_output out clob) is
    json_input      json_object_t := json_object_t(json_str_input);
    param_json      json_object_t;
    param_json_row  json_object_t;

    obj_budget_row      json_object_t;
    obj_budget_data     json_object_t;
    obj_apbg_row        json_object_t;
    obj_apbg_data       json_object_t;
    v_rcnt_bg           number := 0;
    v_rcnt_apbg         number := 0;
    v_approvno          number := 0;

    v_dteyrbug      number;
    v_codcomp       tbudget.codcomp%type;
    v_codpos        tbudget.codpos%type;
    v_dtereq        date;
    v_flg_true      boolean := true;
    v_flg_false     boolean := false;
    v_codemprq      tbudget.codemprq%type;
    v_check         varchar2(50);
--    v_codemprq      tbudget.codemprq%type;
    cursor c_tapbudget is
      select approvno,staappr,codappr,dteappr,remarkap
        from tapbudget
       where dteyrbug   = v_dteyrbug
         and codcomp    = v_codcomp
         and codpos     = v_codpos
         and dtereq     = v_dtereq
      order by approvno;
  begin
    param_json      := hcm_util.get_json_t(json_input,'param_json');
    obj_budget_row  := json_object_t();
    for i in 0..(param_json.get_size - 1) loop
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_dteyrbug        := to_number(hcm_util.get_string_t(param_json_row,'dteyrbug'));
      v_codcomp         := hcm_util.get_string_t(param_json_row,'codcomp');
      v_codpos          := hcm_util.get_string_t(param_json_row,'codpos');
      v_dtereq          := to_date(hcm_util.get_string_t(param_json_row,'dtereq'),'dd/mm/yyyy');
      v_codemprq        := hcm_util.get_string_t(param_json_row,'codemprq');
      obj_budget_data   := json_object_t();

      obj_budget_data.put('coderror','200');
      obj_budget_data.put('dteyrbug',v_dteyrbug);
      obj_budget_data.put('codcomp',v_codcomp);
      obj_budget_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
      obj_budget_data.put('codpos',v_codpos);
      obj_budget_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
      obj_budget_data.put('dtereq',to_char(v_dtereq,'dd/mm/yyyy'));

      obj_apbg_row     := json_object_t();
      v_rcnt_apbg      := 0;
      v_approvno := 0; --User37 #7149 1. RP Module 08/12/2021 
      for r_tapbudget in c_tapbudget loop
        obj_apbg_data    := json_object_t();
        obj_apbg_data.put('numseq',r_tapbudget.approvno);
        obj_apbg_data.put('status',replace(r_tapbudget.staappr,'A','Y'));
        obj_apbg_data.put('approvby',r_tapbudget.codappr);
        obj_apbg_data.put('dteapprov',to_char(r_tapbudget.dteappr,'dd/mm/yyyy'));
        obj_apbg_data.put('remark',r_tapbudget.remarkap);
        obj_apbg_data.put('flgdisabled',v_flg_true);
        obj_apbg_row.put(to_char(v_rcnt_apbg),obj_apbg_data);
        v_approvno      := r_tapbudget.approvno;
        v_rcnt_apbg     := v_rcnt_apbg + 1;
      end loop;
      v_approvno := v_approvno +1;
      if chk_flowmail.check_approve('HRRP23E',v_codemprq,v_approvno,global_v_codempid,null,null,v_check) then
          obj_apbg_data     := json_object_t();
          obj_apbg_data.put('numseq',to_char(v_approvno));
          obj_apbg_data.put('status','Y');
          obj_apbg_data.put('approvby',global_v_codempid);
          obj_apbg_data.put('dteapprov',to_char(sysdate,'dd/mm/yyyy'));
          obj_apbg_data.put('remark','');
          obj_apbg_data.put('flgdisabled',v_flg_false);
          obj_apbg_row.put(to_char(v_rcnt_apbg),obj_apbg_data);
      end if;
      obj_budget_data.put('detail',obj_apbg_row);
      obj_budget_row.put(to_char(v_rcnt_bg),obj_budget_data);
      v_rcnt_bg    := v_rcnt_bg + 1;
    end loop;
    json_str_output   := obj_budget_row.to_clob;
  end;
  --
  procedure get_detail_approve(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_approve(json_str_input,json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure send_mail_to_approve(para_dteyrbug   tbudget.dteyrbug%type,
                                 para_codcomp    tbudget.codcomp%type,
                                 para_codpos     tbudget.codpos%type,
                                 para_dtereq     tbudget.dtereq%type,
                                 para_codemprq   tbudget.codemprq%type,
                                 para_approvno   tbudget.approvno%type,
                                 para_staappr    tbudget.staappr%type,
                                 para_last       varchar2) is
    v_codapp        varchar2(100) := 'HRRP23E';
    v_o_msg_to      clob;
    v_template_to   clob;
    v_func_appr     clob;
    v_codform       tfwmailh.codform%type;
    v_rowid         varchar2(1000);
    v_subject_label varchar2(200);
    v_error         varchar2(100);

    v_item        varchar2(500) := 'item1,item2,item3,item4';
    v_label       varchar2(500) := 'label1,label2,label3,label4';
    v_file_name   varchar2(500) := 'HRRP2AU';
  begin
    v_file_name     := global_v_codempid||'_'||to_char(sysdate,'yyyymmddhh24miss');
    excel_mail(v_item,v_label,null,global_v_codempid,'HRRP2AU',v_file_name);
    --
    begin
      select rowid
        into v_rowid
        from tbudget
       where dteyrbug   = para_dteyrbug
         and codcomp    = para_codcomp
         and codpos     = para_codpos
         and dtereq     = para_dtereq;
    exception when no_data_found then
      null;
    end;

    begin
        v_error := chk_flowmail.send_mail_for_approve('HRRP23E', para_codemprq, global_v_codempid, global_v_coduser, v_file_name, 'HRRP2AU2', 900, 'E', 'P', para_approvno, null, null,'TBUDGET',v_rowid, '1', 'Oracle');
    EXCEPTION WHEN OTHERS THEN
        null;
    END;

    IF v_error in ('2046','2402') THEN
      param_msg_error_mail := get_error_msg_php('HR2402', global_v_lang);
    ELSE
      param_msg_error_mail := get_error_msg_php('HR2403', global_v_lang);
    end if;
  end;
  --
  procedure process_approve(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    param_json_row        json_object_t;
    param_aporg           json_object_t;
    param_aporg_row       json_object_t;

    v_dteyrbug            number;
    v_codcomp             tbudget.codcomp%type;
    v_codpos              tbudget.codpos%type;
    v_dtereq              tbudget.dtereq%type;
    v_dteappr             tbudget.dteappr%type;
    v_staappr             tbudget.staappr%type;
    v_remarkap            tbudget.remarkap%type;
    v_codappr             tbudget.codappr%type;
    v_approvno            tbudget.approvno%type;
    v_qtyreqyr            number;
    v_amttotbudgt         varchar2(500);
    v_codemprq            tbudget.codemprq%type;

    v_chk_flow            boolean := false;
    v_check_last          varchar2(100);
    v_desc_codcomp        varchar2(500);
    v_desc_codpos         varchar2(500);
    v_rowid               varchar2(1000);
    v_error_cc            varchar2(500);
  begin
    json_input          := json_object_t(json_str_input);
    param_json          := hcm_util.get_json_t(json_input,'param_json');
    delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRP2AU';
    delete from ttempprm where codempid = global_v_codempid and codapp = 'HRRP2AU';
    -- insert temp for gen excel --
    insert into ttempprm (codempid,codapp,namrep,pdate,ppage,
                          label1,label2,label3,label4)
    values(global_v_codempid,'HRRP2AU','HRRP2AU',to_char(sysdate,'dd/mm/yyyy'),'page1',
           get_label_name('HRRP2AU1',global_v_lang,50),
           get_label_name('HRRP2AU1',global_v_lang,60),
           get_label_name('HRRP2AU1',global_v_lang,70),
           get_label_name('HRRP2AU1',global_v_lang,80));
    --
    for i in 0..(param_json.get_size - 1) loop
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_dteyrbug        := to_number(hcm_util.get_string_t(param_json_row,'dteyrbug'));
      v_codcomp         := hcm_util.get_string_t(param_json_row,'codcomp');
      v_desc_codcomp    := hcm_util.get_string_t(param_json_row,'desc_codcomp');
      v_codpos          := hcm_util.get_string_t(param_json_row,'codpos');
      v_desc_codpos     := hcm_util.get_string_t(param_json_row,'desc_codpos');
      v_dtereq          := to_date(hcm_util.get_string_t(param_json_row,'dtereq'),'dd/mm/yyyy');

      -----
      begin
        select qtyreqyr,to_char(amttotbudgt,'fm999,999,999,990.00') as amttotbudgt,codemprq
          into v_qtyreqyr,v_amttotbudgt,v_codemprq
          from tbudget
         where dteyrbug   = v_dteyrbug
           and codcomp    = v_codcomp
           and codpos     = v_codpos
           and dtereq     = v_dtereq;
      exception when no_data_found then
        v_qtyreqyr        := null;
        v_amttotbudgt     := null;
        v_codemprq        := null;
      end;
      delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRP2AU';
      ------------------

      param_aporg       := hcm_util.get_json_t(param_json_row,'detail');
      param_aporg_row   := hcm_util.get_json_t(param_aporg,to_char(param_aporg.get_size - 1));
      v_approvno        := hcm_util.get_string_t(param_aporg_row,'numseq');
      v_codappr         := hcm_util.get_string_t(param_aporg_row,'approvby');
      v_dteappr         := to_date(hcm_util.get_string_t(param_aporg_row,'dteapprov'),'dd/mm/yyyy');
      v_staappr         := hcm_util.get_string_t(param_aporg_row,'status');
      v_remarkap        := hcm_util.get_string_t(param_aporg_row,'remark');

      --<<User37 #7149 1. RP Module 08/12/2021 
      if v_dteyrbug is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteyrbug');
      end if;
      if v_codcomp is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      end if;
      if v_codpos is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpos');
      end if;
      if v_dtereq is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtereq');
      end if;
      if v_approvno is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'numseq');
      end if;
      -->>User37 #7149 1. RP Module 08/12/2021 

      v_chk_flow          := chk_flowmail.check_approve('HRRP23E',v_codemprq,v_approvno,global_v_codempid,null,null,v_check_last);
      if v_staappr = 'Y' then
        if v_check_last = 'Y' then
          update tbudget
             set staappr    = 'Y',
                 approvno   = v_approvno,
                 dteappr    = v_dteappr,
                 remarkap   = v_remarkap,
                 codappr    = v_codappr,
                 coduser    = global_v_coduser
           where dteyrbug   = v_dteyrbug
             and codcomp    = v_codcomp
             and codpos     = v_codpos
             and dtereq     = v_dtereq;
        else
          update tbudget
             set staappr    = 'A',
                 approvno   = v_approvno,
                 dteappr    = v_dteappr,
                 remarkap   = v_remarkap,
                 codappr    = v_codappr,
                 coduser    = global_v_coduser
           where dteyrbug   = v_dteyrbug
             and codcomp    = v_codcomp
             and codpos     = v_codpos
             and dtereq     = v_dtereq;
          -- insert temp for gen excel --
          insert into ttemprpt (codempid,codapp,numseq,
                                item1,item2,item3,item4)
          values(global_v_codempid,'HRRP2AU',(i + 1),
                 v_desc_codcomp,v_desc_codpos,v_qtyreqyr,v_amttotbudgt);
          --
          send_mail_to_approve(v_dteyrbug,v_codcomp,v_codpos,v_dtereq,v_codemprq,v_approvno + 1,v_staappr,v_check_last);
        end if;
      elsif v_staappr = 'N' then
        update tbudget
           set staappr    = 'N',
               approvno   = v_approvno,
               dteappr    = v_dteappr,
               remarkap   = v_remarkap,
               codappr    = v_codappr,
               coduser    = global_v_coduser
         where dteyrbug   = v_dteyrbug
           and codcomp    = v_codcomp
           and codpos     = v_codpos
           and dtereq     = v_dtereq;
      elsif v_check_last = 'HR2010' then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tfwmailc');
      end if;

      begin
        insert into tapbudget(dteyrbug, codcomp, codpos, dtereq, approvno,
                      codappr, dteappr, staappr, remarkap, codcreate, coduser)
        values (v_dteyrbug, v_codcomp, v_codpos, v_dtereq, v_approvno,
        v_codappr, v_dteappr, v_staappr, v_remarkap, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        update tapbudget
           set codappr    = v_codappr,
               dteappr    = v_dteappr,
               staappr    = v_staappr,
               remarkap   = v_remarkap,
               coduser    = global_v_coduser
         where dteyrbug   = v_dteyrbug
           and codcomp    = v_codcomp
           and codpos     = v_codpos
           and dtereq     = v_dtereq
           and approvno   = v_approvno;
      end;

      begin
          v_error_cc := chk_flowmail.send_mail_reply('HRRP2AU', v_codemprq, v_codemprq , global_v_codempid, global_v_coduser, null, 'HRRP2AU2', 900, 'U', v_staappr, v_approvno, null, null, 'TBUDGET', v_rowid, '1', null);
      EXCEPTION WHEN OTHERS THEN
          null;
      END;
    end loop;

    if param_msg_error_mail is not null then
      commit;
      json_str_output   := get_response_message(201,param_msg_error_mail,global_v_lang);
      return;
    elsif param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure approve(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      process_approve(json_str_input,json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

--------------------------------------------------------
--  DDL for Package Body HRAP55U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP55U" is
-- last update: 07/08/2020 09:40

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
    logic			    json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    p_dteyreap          := to_number(hcm_util.get_string_t(json_obj,'p_dteyreap'));
    p_numtime           := to_number(hcm_util.get_string_t(json_obj,'p_numtime'));
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codbon            := hcm_util.get_string_t(json_obj,'p_codbon');

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');

    p_index_rows        := hcm_util.get_json_t(json_obj,'p_index_rows');
    p_selected_rows     := hcm_util.get_json_t(json_obj,'p_selected_rows');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --

  procedure check_index is
    v_flgSecur  boolean;
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';
    cursor c1 is
        select *
          from tcenter
         where codcomp = get_compful(p_codcomp);
  begin
    if  p_codcomp is not null then
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
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_main        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_secur         varchar2(1 char) := 'N';
    v_flgpass     	boolean;

    v_cursor        number;
    v_idx           number := 0;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(4000 char);
    v_approvno      number;
    v_check         varchar2(500 char);
    v_amtbudg       number;
    v_actalpay      number;
    cursor c1 is
        select *
          from tbonus
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codcomp like p_codcomp || '%'
           and codbon = p_codbon
           and staappr in ('P','A')
      order by codempid;
  begin
    --table
    v_rcnt      := 0;
    obj_row     := json_object_t();
    obj_main    := json_object_t();

    for r1 in c1 loop
      v_flgdata     := 'Y';
      v_approvno    := nvl(r1.approvno,0) + 1;
      v_flgpass     := chk_flowmail.check_approve('HRAP54B', r1.codempid, v_approvno, global_v_codempid, null, null, v_check);
      if (v_flgpass) then
          v_secur       := 'Y';
          obj_data      := json_object_t();
          v_rcnt        := v_rcnt + 1;
          obj_data.put('coderror', '200');
          obj_data.put('image', nvl(get_emp_img(r1.codempid), r1.codempid));
          obj_data.put('codempid',r1.codempid);
          obj_data.put('desc_codempid',get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('codpos',r1.codpos);
          obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
          obj_data.put('codcomp',r1.codcomp);
          obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
          obj_data.put('grade',r1.grade);
          obj_data.put('amtsal',stddec(r1.amtsal, r1.codempid, global_v_chken));
          obj_data.put('qtybon',r1.qtybon);
          obj_data.put('amtbon',stddec(r1.amtbon, r1.codempid, global_v_chken));
          obj_data.put('pctdedbo',r1.pctdedbo);
          obj_data.put('amtadjbo',stddec(r1.amtadjbo, r1.codempid, global_v_chken));
          obj_data.put('amtnbon',stddec(r1.amtnbon, r1.codempid, global_v_chken));
          v_actalpay := nvl(v_actalpay,0) + stddec(r1.amtnbon, r1.codempid, global_v_chken);
          obj_data.put('remarkadj',r1.remarkadj);
          obj_data.put('approvno',v_approvno);
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    select sum(nvl(amtbudg,0))
      into v_amtbudg
      from tbonparh
     where dteyreap = p_dteyreap
       and numtime = p_numtime
       and codcomp like p_codcomp || '%'
       and codbon = p_codbon;

    obj_main.put('coderror', '200');
    obj_main.put('amtbudg',nvl(v_amtbudg,0));
    obj_main.put('actalpay',v_actalpay);
    obj_main.put('table',obj_row);

    if v_flgdata = 'Y' AND v_secur = 'Y' then
      json_str_output := obj_main.to_clob;
    elsif v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TBONUS');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_secur = 'N' then
      param_msg_error := get_error_msg_php('HR3008', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;

  procedure get_tappempta(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_tappempta(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_tappempta(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_main        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_secur         varchar2(1 char) := 'N';
    v_flgpass     	boolean;

    v_cursor        number;
    v_idx           number := 0;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(4000 char);
    v_approvno      number;
    v_check         varchar2(500 char);
    v_qtyscor       tappempta.qtyscor%type := 0;
    v_codaplvl      tempaplvl.codaplvl%type;
    v_scorfta       tattpreh.scorfta%type;

    cursor c1 is
        select *
          from tappempta
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
      order by codgrplv;
  begin
    --table
    v_rcnt      := 0;
    obj_row     := json_object_t();
    obj_main    := json_object_t();

    for r1 in c1 loop
      obj_data      := json_object_t();
      v_rcnt        := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codgrplv',r1.codgrplv);
      obj_data.put('desc_codgrplv',get_tlistval_name('GRPLEAVE',r1.codgrplv,global_v_lang));
      obj_data.put('qtyleav',r1.qtyleav);
      obj_data.put('qtyscor',r1.qtyscor);
      v_qtyscor := v_qtyscor + r1.qtyscor;
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    begin
        select codaplvl
          into v_codaplvl
          from tempaplvl
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numseq = p_numtime;
    exception when no_data_found then
        v_codaplvl := null;
    end;


    begin
        select scorfta
          into v_scorfta
          from tattpreh
         where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
           and codaplvl = v_codaplvl
           and dteeffec = (select max(dteeffec)
                             from tattpreh
                            where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                              and codaplvl = v_codaplvl
                              and dteeffec <= trunc(sysdate));
    exception when no_data_found then
        v_scorfta := 0;
    end;

    obj_main.put('coderror', '200');
    obj_main.put('scorfta',v_scorfta);
    obj_main.put('qtyscor',nvl(v_scorfta,0) - nvl(v_qtyscor,0));
    obj_main.put('table',obj_row);
    json_str_output := obj_main.to_clob;
  end;

  procedure get_tappempmt(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_tappempmt(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_tappempmt(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_main        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_secur         varchar2(1 char) := 'N';
    v_flgpass     	boolean;

    v_cursor        number;
    v_idx           number := 0;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(4000 char);
    v_approvno      number;
    v_check         varchar2(500 char);
    v_qtyscor       tappempta.qtyscor%type := 0;
    v_codaplvl      tempaplvl.codaplvl%type;
    v_scorfpunsh    tattpreh.scorfpunsh%type;

    cursor c1 is
        select *
          from tappempmt
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
      order by codpunsh;
  begin
    --table
    v_rcnt      := 0;
    obj_row     := json_object_t();
    obj_main    := json_object_t();

    for r1 in c1 loop
      obj_data      := json_object_t();
      v_rcnt        := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codpunsh',r1.codpunsh);
      obj_data.put('desc_codpunsh',get_tcodec_name('TCODPUNH', r1.codpunsh, global_v_lang));
      obj_data.put('qtypunsh',r1.qtypunsh);
      obj_data.put('qtyscor',r1.qtyscor);
      v_qtyscor := v_qtyscor + r1.qtyscor;
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    begin
        select codaplvl
          into v_codaplvl
          from tempaplvl
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numseq = p_numtime;
    exception when no_data_found then
        v_codaplvl := null;
    end;

    begin
        select scorfpunsh
          into v_scorfpunsh
          from tattpreh
         where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
           and codaplvl = v_codaplvl
           and dteeffec = (select max(dteeffec)
                             from tattpreh
                            where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                              and codaplvl = v_codaplvl
                              and dteeffec <= trunc(sysdate));
    exception when no_data_found then
        v_scorfpunsh := 0;
    end;

    obj_main.put('coderror', '200');
    obj_main.put('scorfpunsh',v_scorfpunsh);
    obj_main.put('qtyscor',nvl(v_scorfpunsh,0) - nvl(v_qtyscor,0));
    obj_main.put('table',obj_row);
    json_str_output := obj_main.to_clob;
  end;
  --
  procedure check_save is
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';
    v_codempid  temploy1.codempid%type;
    v_flgsecu   boolean;
    v_zupdsal   varchar2(400 char);
    v_staemp    temploy1.staemp%type;
  begin
    null;
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index_popup(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_approvno      number;
    v_codempid      tlogbonus.codempid%type;
    v_flgpass     	boolean;
    cursor c1 is
        select *
          from tbonus
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codcomp like p_codcomp || '%'
           and codbon = p_codbon
           and staappr in ('P','A')
      order by codempid;

    cursor c2 is
        select *
          from tlogbonus
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codbon = p_codbon
           and codempid = v_codempid
      order by codempid, dteedit;
  begin
    v_rcnt          := 0;
    obj_row         := json_object_t();
    obj_data        := json_object_t();
    for r1 in c1 loop
      v_approvno    := nvl(r1.approvno,0) + 1;
      v_flgpass     := chk_flowmail.check_approve('HRAP54B', r1.codempid, v_approvno, global_v_codempid, null, null, v_check);
      v_codempid    := r1.codempid;

      if (v_flgpass) then
          for r2 in c2 loop
              obj_data      := json_object_t();
              v_rcnt        := v_rcnt + 1;
              obj_data.put('coderror', '200');
              obj_data.put('image', nvl(get_emp_img(r2.codempid), r2.codempid));
              obj_data.put('codempid',r2.codempid);
              obj_data.put('desc_codempid',get_temploy_name(r1.codempid, global_v_lang));
              obj_data.put('dteedit',to_char(r2.dteedit,'dd/mm/yyyy') || ' ' || to_char(r2.dteedit, 'HH24:MI'));
              obj_data.put('amtbon',stddec(r1.amtbon, r2.codempid, global_v_chken));
              obj_data.put('amtbonadj',stddec(r2.amtbonadj, r2.codempid, global_v_chken));
              obj_data.put('desc_coduser',get_temploy_name(get_codempid(r2.coduser), global_v_lang));
              obj_data.put('dteupd',to_char(r2.dteupd,'dd/mm/yyyy'));
              obj_row.put(to_char(v_rcnt-1),obj_data);
          end loop;
      end if;
    end loop;
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
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

    v_codempid      tapbonus.codempid%type;

    v_approvno      number;
    v_flgpass     	boolean;
    v_check         varchar2(500 char);
    v_amtadjbo      number;
    v_amtadjboOld   number;
    v_amtnbon       number;
    v_codpos        temploy1.codpos%type;
    v_codcomp       temploy1.codcomp%type;

    cursor c1 is
        select *
          from tapbonus
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codbon = p_codbon
           and codempid = v_codempid
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
        v_codpos        := hcm_util.get_string_t(v_row,'codpos');
        v_codcomp       := hcm_util.get_string_t(v_row,'codcomp');
        v_approvno      := to_number(hcm_util.get_string_t(v_row,'approvno'));
        v_amtadjbo      := to_number(hcm_util.get_string_t(v_row,'amtadjbo'));
        v_amtadjboOld   := to_number(hcm_util.get_string_t(v_row,'amtadjboOld'));
        v_amtnbon       := to_number(hcm_util.get_string_t(v_row,'amtnbon'));

        v_rcnt_main     := v_rcnt_main + 1;
        v_flgpass       := chk_flowmail.check_approve('HRAP54B', v_codempid, v_approvno, global_v_codempid, null, null, v_check);
        obj_row         := json_object_t();
        for r1 in c1 loop
            v_rcnt          := v_rcnt +1;
            obj_data        := json_object_t();
            obj_data.put('codempid',v_codempid);
            obj_data.put('dteyreap',p_dteyreap);
            obj_data.put('numtime',p_numtime);
            obj_data.put('codbon',p_codbon);
            obj_data.put('numseq',r1.approvno);
            obj_data.put('approvno',r1.approvno);
            obj_data.put('codappr',r1.codappr);
            obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
            obj_data.put('staappr',r1.staappr);
            obj_data.put('remark',r1.remarkap);
            obj_data.put('amtadjbo',v_amtadjbo);
            obj_data.put('amtadjboOld',v_amtadjboOld);
            obj_data.put('amtnbon',v_amtnbon);
            obj_data.put('disabled',true);
            obj_data.put('flglastappr',false);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;

        if v_flgpass then
            v_rcnt          := v_rcnt +1;
            obj_data        := json_object_t();
            obj_data.put('codempid',v_codempid);
            obj_data.put('dteyreap',p_dteyreap);
            obj_data.put('numtime',p_numtime);
            obj_data.put('codbon',p_codbon);
            obj_data.put('numseq',v_approvno);
            obj_data.put('approvno',v_approvno);
            obj_data.put('codappr',global_v_codempid);
            obj_data.put('dteappr',to_char(trunc(sysdate),'dd/mm/yyyy'));
            obj_data.put('staappr','Y');
            obj_data.put('remark','');
            obj_data.put('amtadjbo',v_amtadjbo);
            obj_data.put('amtadjboOld',v_amtadjboOld);
            obj_data.put('amtnbon',v_amtnbon);
            obj_data.put('disabled',false);
            if v_check = 'Y' then
                obj_data.put('flglastappr',true);
            else
                obj_data.put('flglastappr',false);
            end if;
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;

        obj_data_main   := json_object_t();
        obj_data_main.put('coderror', '200');
        obj_data_main.put('codempid',v_codempid);
        obj_data_main.put('desc_codempid',get_temploy_name(v_codempid, global_v_lang));
        obj_data_main.put('codpos',v_codpos);
        obj_data_main.put('desc_codpos',get_tpostn_name(v_codpos, global_v_lang));
        obj_data_main.put('codcomp',v_codcomp);
        obj_data_main.put('desc_codcomp',get_tcenter_name(v_codcomp, global_v_lang));
        obj_data_main.put('detail',obj_row);
        obj_row_main.put(to_char(v_rcnt_main-1),obj_data_main);
    end loop;

    json_str_output := obj_row_main.to_clob;
  end;

  procedure send_approve(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    v_dteyreap      tapbonus.dteyreap%type;
    v_numtime       tapbonus.numtime%type;
    v_codbon        tapbonus.codbon%type;
    v_codempid      tapbonus.codempid%type;
    v_approvno      tapbonus.approvno%type;
    v_codappr       tapbonus.codappr%type;
    v_dteappr       tapbonus.dteappr%type;
    v_remark        tapbonus.remarkap%type;
    v_staappr       tapbonus.staappr%type;
    v_staappr2      tapbonus.staappr%type;

    v_amtadjbo      number;
    v_amtadjboOld   number;
    v_amtnbon       number;
    v_dteedit       tlogbonus.dteedit%type;

    v_msg_to        clob;
	v_templete_to   clob;
    v_func_appr     tfwmailh.codappap%type;
    v_rowid         rowid;
    v_error			terrorm.errorno%type;
	v_codform		tfwmailh.codform%type;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(400);

    v_flgpass       boolean;
    v_check         varchar2(500 char);
  begin
    initial_value(json_str_input);
--    check_save;
    if param_msg_error is null then
        begin
            for i in 0..p_selected_rows.get_size-1 loop
                obj_row     := json_object_t();
				obj_row     := hcm_util.get_json_t(p_selected_rows,to_char(i));
                v_dteyreap  := hcm_util.get_string_t(obj_row,'dteyreap');
                v_numtime   := hcm_util.get_string_t(obj_row,'numtime');
                v_codbon    := hcm_util.get_string_t(obj_row,'codbon');
                v_codempid  := hcm_util.get_string_t(obj_row,'codempid');
                v_approvno  := hcm_util.get_string_t(obj_row,'approvno');
                v_dteappr   := to_date(hcm_util.get_string_t(obj_row,'dteappr'),'dd/mm/yyyy');
                v_codappr   := hcm_util.get_string_t(obj_row,'codappr');
                v_staappr   := hcm_util.get_string_t(obj_row,'staappr');
                v_remark    := hcm_util.get_string_t(obj_row,'remark');
                v_amtadjbo      := to_number(hcm_util.get_string_t(obj_row,'amtadjbo'));
                v_amtadjboOld   := to_number(hcm_util.get_string_t(obj_row,'amtadjboOld'));
                v_amtnbon       := to_number(hcm_util.get_string_t(obj_row,'amtnbon'));

                insert into tapbonus (dteyreap,numtime,codbon,codempid,approvno,
                                      codappr,dteappr,staappr,remarkap,
                                      dtecreate,codcreate,dteupd,coduser)
                              values (v_dteyreap,v_numtime,v_codbon,v_codempid,v_approvno,
                                      v_codappr,v_dteappr,v_staappr,v_remark,
                                      sysdate,global_v_coduser,sysdate,global_v_coduser);

                if v_staappr = 'N' then
                    update tbonus
                       set staappr = v_staappr,
                           codappr = v_codappr,
                           dteappr = v_dteappr,
                           remarkap = v_remark,
                           approvno = v_approvno
                     where dteyreap = v_dteyreap
                       and numtime = v_numtime
                       and codbon = v_codbon
                       and codempid = v_codempid;
                else
                    if v_amtadjbo <> v_amtadjboOld then
                        v_dteedit := sysdate;
                        begin
                            insert into tlogbonus (dteyreap,numtime,codbon,codempid,dteedit,
                                                   amtbonadj,codadj,dteadj,
                                                   dtecreate,codcreate,dteupd,coduser)
                                           values (v_dteyreap, v_numtime, v_codbon, v_codempid, v_dteedit,
                                                   stdenc(v_amtadjbo, v_codempid, global_v_chken), global_v_codempid, sysdate,
                                                   sysdate, global_v_coduser,sysdate, global_v_coduser);
                        exception when dup_val_on_index then
                            update tlogbonus
                               set amtbonadj = stdenc(v_amtadjbo, v_codempid, global_v_chken),
                                   codadj = global_v_codempid,
                                   dteadj = sysdate,
                                   dteupd = sysdate,
                                   coduser = global_v_coduser
                             where dteyreap = v_dteyreap
                               and numtime = v_numtime
                               and codbon = v_codbon
                               and codempid = v_codempid
                               and dteedit = v_dteedit;
                        end;

                        update tbonus
                           set amtadjbo = stdenc(v_amtadjbo, v_codempid, global_v_chken),
                               amtnbon = stdenc(v_amtnbon, v_codempid, global_v_chken)
                         where dteyreap = v_dteyreap
                           and numtime = v_numtime
                           and codbon = v_codbon
                           and codempid = v_codempid;

                    end if;

                    v_flgpass := chk_flowmail.check_approve('HRAP54B', v_codempid, v_approvno, global_v_codempid, null, null, v_check);
                    if v_check = 'Y' then
                        v_staappr2 := 'Y';

                        update tbonus
                           set staappr = v_staappr2,
                               codappr = v_codappr,
                               dteappr = v_dteappr,
                               remarkap = v_remark,
                               approvno = v_approvno
                         where dteyreap = v_dteyreap
                           and numtime = v_numtime
                           and codbon = v_codbon
                           and codempid = v_codempid;

                        select rowid
                          into v_rowid
                          from tbonus
                         where dteyreap = v_dteyreap
                           and numtime = v_numtime
                           and codbon = v_codbon
                           and codempid = v_codempid;

                        ---ส่งเมลหาผู้ขออนุมัติ
--                        v_codform := 'HRAP55U';
--                        begin
--                            chk_flowmail.get_message_result(v_codform, global_v_lang, v_msg_to, v_templete_to);
--                            chk_flowmail.replace_text_frmmail(v_templete_to, 'TBONUS', v_rowid, get_label_name('HRAP55U1', global_v_lang, 330), v_codform, '1', null, global_v_coduser, global_v_lang, v_msg_to);
--                            v_error := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL, get_label_name('HRAP55U1', global_v_lang, 330), 'U', global_v_lang, null);
--                        exception when others then
--                            param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
--                        end;
                    else
                        v_staappr2 := 'A';
                        update tbonus
                           set staappr = v_staappr2,
                               codappr = v_codappr,
                               dteappr = v_dteappr,
                               remarkap = v_remark,
                               approvno = v_approvno
                         where dteyreap = v_dteyreap
                           and numtime = v_numtime
                           and codbon = v_codbon
                           and codempid = v_codempid;

                        select rowid
                          into v_rowid
                          from tbonus
                         where dteyreap = v_dteyreap
                           and numtime = v_numtime
                           and codbon = v_codbon
                           and codempid = v_codempid;
                        begin
                            v_error := chk_flowmail.send_mail_for_approve('HRAP54B', v_codempid, global_v_codempid, global_v_coduser, null, 'HRAP55U1', 320, 'U', v_staappr, 1, null, null,'TBONUS',v_rowid, '1', null);
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

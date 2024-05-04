--------------------------------------------------------
--  DDL for Package Body HRAP37U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP37U" is
-- last update: 07/08/2020 09:40
  function is_number (p_string in varchar2) return int is
    v_new_num number;
  begin
    v_new_num := to_number(p_string);
    return 1;
  exception when others then
    return 0;
  end is_number;

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
    v_sumadj        number;
    v_pctadjsal     number;
    cursor c1 is
        select *
          from tapprais
         where dteyreap = p_dteyreap
           and codcomp like p_codcomp || '%'
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
      v_flgpass     := chk_flowmail.check_approve('HRAP39B', r1.codempid, v_approvno, global_v_codempid, null, null, v_check);
      if (v_flgpass) then
          v_secur       := 'Y';
          obj_data      := json_object_t();
          v_rcnt        := v_rcnt + 1;
          obj_data.put('coderror', '200');
          obj_data.put('image', nvl(get_emp_img(r1.codempid), r1.codempid));
          obj_data.put('codempid',r1.codempid);
          obj_data.put('desc_codempid',get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('codcomp',r1.codcomp);
          obj_data.put('amtsal',greatest(stddec(r1.amtsal, r1.codempid, global_v_chken),0));
          obj_data.put('qtyscore',r1.qtyscore);
          obj_data.put('grade',r1.grade);
          obj_data.put('jobgrade',r1.jobgrade);
          obj_data.put('desc_jobgrade',get_tcodec_name('TCODJOBG',r1.jobgrade,global_v_lang));
          obj_data.put('amtmidsal',stddec(r1.amtmidsal, r1.codempid, global_v_chken));
          if r1.pctadjsal is null then
            if stddec(r1.amtsal, r1.codempid, global_v_chken) > 0 then
              v_pctadjsal := round((stddec(r1.amtbudg, r1.codempid, global_v_chken) / greatest(stddec(r1.amtsal, r1.codempid, global_v_chken),0)) * 100,2);
            end if;
            obj_data.put('pctadjsal',to_char(v_pctadjsal,'fm90.00'));
          else
            obj_data.put('pctadjsal',to_char(r1.pctadjsal,'fm90.00'));
          end if;

          obj_data.put('amtbudg',stddec(r1.amtbudg, r1.codempid, global_v_chken));
          obj_data.put('amtadj',stddec(r1.amtadj, r1.codempid, global_v_chken));
          obj_data.put('amtsaln',stddec(r1.amtsaln, r1.codempid, global_v_chken));
          obj_data.put('desc_staappr',get_tlistval_name('STAAPPR',r1.staappr,global_v_lang));
          obj_data.put('last_approvno',r1.approvno);
          obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
          obj_data.put('flgsal',r1.flgsal);
          obj_data.put('amtceiling',stddec(r1.amtceiling, r1.codempid, global_v_chken));
          obj_data.put('amtminsal',stddec(r1.amtminsal, r1.codempid, global_v_chken));

          v_sumadj := nvl(v_sumadj,0) + nvl(stddec(r1.amtbudg, r1.codempid, global_v_chken),0) + nvl(stddec(r1.amtadj, r1.codempid, global_v_chken),0);
          obj_data.put('approvno',v_approvno);
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    select sum(nvl(amtbudg,0))
      into v_amtbudg
      from tapbudgt
     where dteyreap = p_dteyreap
       and codcomp like p_codcomp || '%';

    obj_main.put('coderror', '200');
    obj_main.put('amtbudg',nvl(v_amtbudg,0));
    obj_main.put('different',nvl(v_amtbudg,0) - v_sumadj);
    obj_main.put('table',obj_row);

    if v_flgdata = 'Y' AND v_secur = 'Y' then
      json_str_output := obj_main.to_clob;
    elsif v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TAPPRAIS');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_secur = 'N' then
      param_msg_error := get_error_msg_php('HR3008', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
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
          from tapprais
         where dteyreap = p_dteyreap
           and codcomp like p_codcomp || '%'
           and staappr in ('P','A')
      order by codempid;

    cursor c2 is
        select *
          from tlogapprais
         where dteyreap = p_dteyreap
           and codempid = v_codempid
      order by codempid, dteedit;
  begin
    v_rcnt          := 0;
    obj_row         := json_object_t();
    obj_data        := json_object_t();
    for r1 in c1 loop
      v_approvno    := nvl(r1.approvno,0) + 1;
      v_flgpass     := chk_flowmail.check_approve('HRAP39B', r1.codempid, v_approvno, global_v_codempid, null, null, v_check);
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
              obj_data.put('qtyscore',r2.qtyscore);
              obj_data.put('grade',r2.grade);
              obj_data.put('pctcalsal',r2.pctcalsal);
              obj_data.put('pctsal',r2.pctsal);
              obj_data.put('amtadj',stddec(r2.amtadj, r2.codempid, global_v_chken));
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

    v_codempid      tapsaladj.codempid%type;
    v_codcomp       tapprais.codcomp%type;

    v_approvno      number;
    v_flgpass     	boolean;
    v_check         varchar2(500 char);
    v_pctadjsal     tapprais.pctadjsal%type;
    v_pctadjsalOld  tapprais.pctadjsal%type;
    v_amtbudg       tapprais.amtbudg%type;
    v_amtbudgOld    tapprais.amtbudg%type;
    v_amtadj        number;
    v_amtadjOld     number;
    v_amtsaln       number;
    v_amtsalnOld    number;
    v_amtsal        number;

    cursor c1 is
        select *
          from tapsaladj
         where dteyreap = p_dteyreap
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
        v_codcomp       := hcm_util.get_string_t(v_row,'codcomp');
        v_approvno      := to_number(hcm_util.get_string_t(v_row,'approvno'));
        v_pctadjsal     := to_number(hcm_util.get_string_t(v_row,'pctadjsal'));
        v_amtbudg       := to_number(hcm_util.get_string_t(v_row,'amtbudg'));
        v_amtadj        := to_number(hcm_util.get_string_t(v_row,'amtadj'));
        v_amtsaln       := to_number(hcm_util.get_string_t(v_row,'amtsaln'));

        v_rcnt_main     := v_rcnt_main + 1;
        v_flgpass       := chk_flowmail.check_approve('HRAP39B', v_codempid, v_approvno, global_v_codempid, null, null, v_check);
        obj_row         := json_object_t();
        for r1 in c1 loop
            v_rcnt          := v_rcnt +1;
            obj_data        := json_object_t();
            obj_data.put('codempid',v_codempid);
--            obj_data.put('codcomadj',r1.codcomadj);
            obj_data.put('codcomadj',p_codcomp);
            obj_data.put('dteyreap',p_dteyreap);
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
            obj_data.put('pctadjsal',v_pctadjsal);
            obj_data.put('amtbudg',v_amtbudg);
            obj_data.put('amtadj',v_amtadj);
            obj_data.put('amtsaln',v_amtsaln);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;

        v_rcnt          := v_rcnt +1;
        obj_data        := json_object_t();
        obj_data.put('codempid',v_codempid);
--        obj_data.put('codcomadj',v_codcomp);
        obj_data.put('codcomadj',p_codcomp);
        obj_data.put('dteyreap',p_dteyreap);
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

        obj_data.put('pctadjsal',v_pctadjsal);
        obj_data.put('amtbudg',v_amtbudg);
        obj_data.put('amtadj',v_amtadj);
        obj_data.put('amtsaln',v_amtsaln);

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

    v_dteedit       tlogbonus.dteedit%type;

    v_msg_to        clob;
	v_templete_to   clob;
    v_func_appr     tfwmailh.codappap%type;
    v_rowid         rowid;
    v_error			terrorm.errorno%type;
	v_codform		tfwmailh.codform%type;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(400);
    v_codcomadj     tapsaladj.codcomadj%type;
    v_dteeffec      tapsaladj.dteeffec%type;
    v_codtrn        tapsaladj.codtrn%type;

    v_flgpass       boolean;
    v_check         varchar2(500 char);

    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_codjob        temploy1.codjob%type;
    v_numlvl        temploy1.numlvl%type;
    v_codbrlc       temploy1.codbrlc%type;
    v_codcalen      temploy1.codcalen%type;
    v_flgatten      temploy1.flgatten%type;
    v_dteefpos      temploy1.dteefpos%type;
    v_dteduepr      temploy1.dteduepr%type;
    v_codedlv       temploy1.codedlv%type;
    v_codsex        temploy1.codsex%type;
    v_codempmt      temploy1.codempmt%type;
    v_typpayroll    temploy1.typpayroll%type;
    v_typemp        temploy1.typemp%type;
    v_dteempmt      temploy1.dteempmt%type;
    v_amtincom1     number;
    v_amtincadj1    number;
    v_amtincom2     number;
    v_amtincom3     number;
    v_amtincom4     number;
    v_amtincom5     number;
    v_amtincom6     number;
    v_amtincom7     number;
    v_amtincom8     number;
    v_amtincom9     number;
    v_amtincom10    number;
    v_codcurr       temploy3.codcurr%type;

    v_amtothr       number;
    v_amtday        number;
    v_amtmth        number;
    v_numseq        ttmovemt.numseq%type;
    tapprais_codcomp        tapprais.codcomp%type;
    tapprais_amtsal         tapprais.amtsal%type;
    v_amtsaln               number;
    v_pctadjsal             tapprais.pctadjsal%type;
    v_amtbudg               number;
    v_amtadj                number;

    cursor c1 is
        select *
          from tapprais
         where codempid = v_codempid
           and dteyreap = v_dteyreap;

  begin
    initial_value(json_str_input);
--    check_save;
    if param_msg_error is null then
        begin
            for i in 0..p_selected_rows.get_size-1 loop
                obj_row         := json_object_t();
				obj_row         := hcm_util.get_json_t(p_selected_rows,to_char(i));
                v_dteyreap      := hcm_util.get_string_t(obj_row,'dteyreap');
                v_codempid      := hcm_util.get_string_t(obj_row,'codempid');
                v_approvno      := hcm_util.get_string_t(obj_row,'approvno');
                v_dteappr       := to_date(hcm_util.get_string_t(obj_row,'dteappr'),'dd/mm/yyyy');
                v_codappr       := hcm_util.get_string_t(obj_row,'codappr');
                v_staappr       := hcm_util.get_string_t(obj_row,'staappr');
                v_remark        := hcm_util.get_string_t(obj_row,'remark');
                v_amtincom1     := hcm_util.get_string_t(obj_row,'amtsaln');
                v_amtsaln       := hcm_util.get_string_t(obj_row,'amtsaln');
                v_pctadjsal     := hcm_util.get_string_t(obj_row,'pctadjsal');
                v_amtbudg       := hcm_util.get_string_t(obj_row,'amtbudg');
                v_amtadj        := hcm_util.get_string_t(obj_row,'amtadj');

                v_amtincadj1    := to_number(v_amtbudg) + to_number(v_amtadj);

                v_codcomadj     := hcm_util.get_string_t(obj_row,'codcomadj');
                v_dteeffec      := to_date(hcm_util.get_string_t(obj_row,'dteeffec'),'dd/mm/yyyy');
                v_codtrn        := hcm_util.get_string_t(obj_row,'codtrn');

                begin
                insert into tapsaladj (dteyreap,codcomadj,codempid,approvno,
                                       dteappr,codappr,staappr,remarkap,dteeffec,codtrn,
                                       dtecreate,codcreate,dteupd,coduser)
                              values (v_dteyreap,v_codcomadj,v_codempid,v_approvno,
                                      v_dteappr,v_codappr,v_staappr,v_remark,v_dteeffec,v_codtrn,
                                      sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    update tapsaladj
                       set dteappr = v_dteappr,
                           codappr = v_codappr,
                           staappr = v_staappr,
                           remarkap = v_remark,
                           dteeffec = v_dteeffec,
                           codtrn = v_codtrn
                     where dteyreap = v_dteyreap
                       and codcomadj = v_codcomadj
                       and codempid = v_codempid
                       and approvno = v_approvno;
                end ;

                if v_staappr = 'N' then
                    update tapprais
                       set staappr = v_staappr,
                           codappr = v_codappr,
                           dteappr = v_dteappr,
                           remarkap = v_remark,
                           approvno = v_approvno
                     where dteyreap = v_dteyreap
                       and codempid = v_codempid;
                else
                    if (v_pctadjsal is not null and v_pctadjsal > 0)
                        or (v_amtbudg is not null and v_amtbudg > 0)
                        or (v_amtadj is not null and v_amtadj > 0) then
                        v_dteedit := sysdate;

                        for r1 in c1 loop
                            begin
                                insert into tlogapprais (codempid,dteyreap,dteedit,amtsal,pctsal,
                                                         amtbudg,amtadj,amtsaln,grade,qtyscore,pctcalsal,
                                                         dtecreate,codcreate,dteupd,coduser)
                                               values (v_codempid, v_dteyreap, v_dteedit, r1.amtsal, v_pctadjsal,
                                                       stdenc(v_amtbudg, v_codempid, global_v_chken),
                                                       stdenc(v_amtadj, v_codempid, global_v_chken),
                                                       stdenc(v_amtsaln, v_codempid, global_v_chken),
                                                       r1.grade, r1.qtyscore, r1.pctcalsal,
                                                       sysdate, global_v_coduser,sysdate, global_v_coduser);
                            exception when others then
                                null;
                            end;
                        end loop;

                        update tapprais
                           set pctadjsal = v_pctadjsal,
                               amtbudg = stdenc(v_amtbudg, v_codempid, global_v_chken),
                               amtadj = stdenc(v_amtadj, v_codempid, global_v_chken),
                               amtsaln = stdenc(v_amtsaln, v_codempid, global_v_chken),
                               codadj = global_v_coduser,
                               dteadj = sysdate,
                               dteupd = sysdate,
                               coduser = global_v_coduser
                         where codempid = v_codempid
                           and dteyreap = v_dteyreap;

                    end if;

                    v_flgpass := chk_flowmail.check_approve('HRAP39B', v_codempid, v_approvno, global_v_codempid, null, null, v_check);
                    if v_check = 'Y' then
                        v_staappr2 := 'Y';

                        update tapprais
                           set staappr = v_staappr2,
                               codappr = v_codappr,
                               dteappr = v_dteappr,
                               remarkap = v_remark,
                               approvno = v_approvno,
                               flgtrnpm = 'Y',
                               dtetrnpm = v_dteappr,
                               dteeffec = v_dteeffec,
                               codtrn = v_codtrn
                         where dteyreap = v_dteyreap
                           and codempid = v_codempid;

                        select a.codcomp, a.codpos, a.codjob, a.numlvl,
                               a.codbrlc, a.codcalen, a.flgatten, a.dteefpos, a.dteduepr,
                               a.codedlv, a.codsex, a.codempmt, a.typpayroll, a.typemp,
                               a.dteempmt,
                               stddec(b.amtincom2, a.codempid, global_v_chken) amtincom2,
                               stddec(b.amtincom3, a.codempid, global_v_chken) amtincom3,
                               stddec(b.amtincom4, a.codempid, global_v_chken) amtincom4,
                               stddec(b.amtincom5, a.codempid, global_v_chken) amtincom5,
                               stddec(b.amtincom6, a.codempid, global_v_chken) amtincom6,
                               stddec(b.amtincom7, a.codempid, global_v_chken) amtincom7,
                               stddec(b.amtincom8, a.codempid, global_v_chken) amtincom8,
                               stddec(b.amtincom9, a.codempid, global_v_chken) amtincom9,
                               stddec(b.amtincom10, a.codempid, global_v_chken) amtincom10,
                               b.codcurr
                          into v_codcomp, v_codpos, v_codjob, v_numlvl,
                               v_codbrlc, v_codcalen, v_flgatten, v_dteefpos, v_dteduepr,
                               v_codedlv, v_codsex, v_codempmt, v_typpayroll, v_typemp,
                               v_dteempmt,
                               v_amtincom2, v_amtincom3,
                               v_amtincom4, v_amtincom5,
                               v_amtincom6, v_amtincom7,
                               v_amtincom8, v_amtincom9,
                               v_amtincom10,v_codcurr
                          from temploy1 a, temploy3 b
                         where a.codempid = v_codempid
                           and a.codempid = b.codempid;

                        get_wage_income(hcm_util.get_codcomp_level(v_codcomp,1), v_codempmt, v_amtincom1,
                                               v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
                                               v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10,
                                               v_amtothr, v_amtday, v_amtmth);

                        begin
                            select nvl(max(numseq),0) + 1
                              into v_numseq
                              from ttmovemt
                             where codempid = v_codempid
                               and dteeffec = v_dteeffec;
                        exception when others then
                            v_numseq := 1;
                        end;

                        begin
                            insert into ttmovemt (codempid,dteeffec,numseq,codtrn,codcomp,
                                                codpos,codjob,numlvl,codbrlc,codcalen,
                                                flgatten,flgduepr,codcompt,
                                                codposnow,codjobt,numlvlt,codbrlct,codcalet,
                                                flgattet,codedlv,flgadjin,codsex,staupd,
                                                codempmtt,codempmt,typpayrolt,typpayroll,typempt,typemp,
                                                amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                                                amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                                                amtincadj1,
                                                amtothr,codcurr,codappr,dteappr,remarkap,
                                                approvno,
                                                dtecreate,codcreate,dteupd,coduser)
                            values (v_codempid,v_dteeffec,v_numseq,v_codtrn,v_codcomp,
                                    v_codpos,v_codjob, v_numlvl, v_codbrlc, v_codcalen,
                                    v_flgatten,null,v_codcomp,
                                    v_codpos,v_codjob, v_numlvl, v_codbrlc, v_codcalen,
                                    v_flgatten,v_codedlv,'Y',v_codsex,'C',
                                    v_codempmt,v_codempmt,v_typpayroll,v_typpayroll,v_typemp,v_typemp,
                                    stdenc(v_amtincom1, v_codempid, global_v_chken), stdenc(v_amtincom2, v_codempid, global_v_chken),
                                    stdenc(v_amtincom3, v_codempid, global_v_chken), stdenc(v_amtincom4, v_codempid, global_v_chken),
                                    stdenc(v_amtincom5, v_codempid, global_v_chken), stdenc(v_amtincom6, v_codempid, global_v_chken),
                                    stdenc(v_amtincom7, v_codempid, global_v_chken), stdenc(v_amtincom8, v_codempid, global_v_chken),
                                    stdenc(v_amtincom9, v_codempid, global_v_chken), stdenc(v_amtincom10, v_codempid, global_v_chken),
                                    stdenc(v_amtincadj1, v_codempid, global_v_chken),
                                    stdenc(v_amtothr, v_codempid, global_v_chken),v_codcurr,v_codappr,v_dteappr,v_remark,
                                    v_approvno,
                                    sysdate,global_v_coduser,sysdate,global_v_coduser);
                        exception when others then
                            null;
                        end;

                        select codcomp, amtsal
                          into tapprais_codcomp, tapprais_amtsal
                          from tapprais
                         where codempid = v_codempid
                           and dteyreap = v_dteyreap;
                        begin

                            insert into ttranpm (dteyreap,codempid,codcomp,codtrn,dteeffec,
                                                 amtsal,amtadj,amtsaln,pctnet,codappr,
                                                 dteappr,remarkap,
                                                 dtecreate,codcreate,dteupd,coduser)
                                         values (v_dteyreap,v_codempid,tapprais_codcomp,v_codtrn,v_dteeffec,
                                                 tapprais_amtsal,stdenc(v_amtincadj1, v_codempid, global_v_chken),
                                                 stdenc(v_amtsaln, v_codempid, global_v_chken),
                                                 round(v_amtincadj1*100/stddec(tapprais_amtsal, v_codempid, global_v_chken),2),
                                                 v_codappr, v_dteappr,v_remark,
                                                 sysdate,global_v_coduser,sysdate,global_v_coduser);
                        exception when dup_val_on_index then
                            update ttranpm
                               set codcomp = tapprais_codcomp,
                                   codtrn = v_codtrn,
                                   dteeffec = v_dteeffec,
                                   amtsal = tapprais_amtsal,
                                   amtadj = stdenc(v_amtincadj1, v_codempid, global_v_chken),
                                   amtsaln = stdenc(v_amtsaln, v_codempid, global_v_chken),
                                   pctnet = round(v_amtincadj1*100/stddec(tapprais_amtsal, v_codempid, global_v_chken),2),
                                   codappr = v_codappr,
                                   dteappr = v_dteappr,
                                   remarkap = v_remark,
                                   dteupd = sysdate,
                                   coduser = global_v_coduser
                             where dteyreap = v_dteyreap and codempid = v_codempid;
                        end;

--                        select rowid
--                          into v_rowid
--                          from tapprais
--                         where dteyreap = v_dteyreap
--                           and codempid = v_codempid;

                        ---ส่งเมลหาผู้ขออนุมัติ
--                        v_codform := 'HRAP37U';
--                        begin
--                            chk_flowmail.get_message_result(v_codform, global_v_lang, v_msg_to, v_templete_to);
--                            chk_flowmail.replace_text_frmmail(v_templete_to, 'TBONUS', v_rowid, get_label_name('HRAP37U1', global_v_lang, 330), v_codform, '1', null, global_v_coduser, global_v_lang, v_msg_to);
--                            v_error := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL, get_label_name('HRAP37U1', global_v_lang, 330), 'U', global_v_lang, null);
--                        exception when others then
--                            param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
--                        end;
                    else
                        v_staappr2 := 'A';
                        update tapprais
                           set staappr = v_staappr2,
                               codappr = v_codappr,
                               dteappr = v_dteappr,
                               remarkap = v_remark,
                               approvno = v_approvno
                         where dteyreap = v_dteyreap
                           and codempid = v_codempid;

                        select rowid
                          into v_rowid
                          from tapprais
                         where dteyreap = v_dteyreap
                           and codempid = v_codempid;
                        begin
                            v_error := chk_flowmail.send_mail_for_approve('HRAP39B', v_codempid, global_v_codempid, global_v_coduser, null, 'HRAP37U1', 320, 'U', v_staappr, v_approvno + 1, null, null,'TAPPRAIS',v_rowid, '1', null);
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

  procedure check_import_data(v_codempid    in varchar2,
                              v_codcomp     in varchar2,
                              v_codpos      in varchar2,
                              v_qtyscore    in varchar2,
                              v_pctcalsal   in varchar2,
                              v_amtbudg     in varchar2,
                              v_amtadj      in varchar2,
                              v_err_text    out varchar2) is
    v_chk_exist         varchar2(2000 char);
    v_err_code          varchar2(2000 char);
    v_codempid_tmp      varchar2(2000 char);
    v_staemp            temploy1.staemp%type;
    v_codcomp_tmp       temploy1.codcomp%type;
    v_codpos_tmp        temploy1.codpos%type;
    v_codplan_tmp       varchar2(10 char);
  begin  null;
    -- 1.check field codempid
    if v_codempid is not null then
      begin
        select codempid,staemp
          into v_codempid_tmp, v_staemp
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        v_err_code := 'HR2010';
        v_err_text := replace(get_error_msg_php(v_err_code, global_v_lang, 'temploy1',null,false),'@#$%400','');
        return;
      end;
      --
      if v_staemp = '9' then
        v_err_code := 'HR2101';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      end if;
      --
      if not secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        v_err_code := 'HR3007';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      end if;
    else
      v_err_code := 'HR2045';
      v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
      return;
    end if;
    -- 2. check field codcomp
    if v_codcomp is not null then
      begin
        select codcomp
          into v_codcomp_tmp
          from tcenter
         where codcomp = get_compful(v_codcomp);
      exception when no_data_found then
        v_err_code := 'HR2010';
        v_err_text := replace(get_error_msg_php(v_err_code, global_v_lang, 'TCENTER',null,false),'@#$%400','');
        return;
      end;
    else
      v_err_code := 'HR2045';
      v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
      return;
    end if;
    -- 3. check field codpos
    if v_codpos is not null then
      begin
        select codpos
          into v_codpos_tmp
          from tpostn
         where codpos = v_codpos;
      exception when no_data_found then
        v_err_code := 'HR2010';
        v_err_text := replace(get_error_msg_php(v_err_code, global_v_lang, 'TPOTSN',null,false),'@#$%400','');
        return;
      end;
    else
      v_err_code := 'HR2045';
      v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
      return;
    end if;
    -- 4.check field qtyscore
    if v_qtyscore is not null then
      if is_number(v_qtyscore) < 1 then
        v_err_code := 'HR2816';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      elsif to_number(v_qtyscore) < -999.99 or to_number(v_qtyscore) > 999.99 then
        v_err_code := 'HR2020';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang)||v_qtyscore;
        return;
      end if;
    end if;
    -- 5.check field qtyscore
    if v_pctcalsal is not null then
      if is_number(v_pctcalsal) < 1 then
        v_err_code := 'HR2816';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      elsif to_number(v_pctcalsal) < -999.99 or to_number(v_pctcalsal) > 999.99 then
        v_err_code := 'HR2020';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang)||v_pctcalsal;
        return;
      end if;
    end if;
    -- 6.check field amtbudg
    if v_amtbudg is not null then
      if is_number(v_amtbudg) < 1 then
        v_err_code := 'HR2816';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      elsif to_number(v_amtbudg) < -9999999.99 or to_number(v_amtbudg) > 9999999.99 then
        v_err_code := 'HR2020';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang)||v_amtbudg;
        return;
      end if;
    end if;
    -- 7.check field amtadj
    if v_amtadj is not null then
      if is_number(v_amtadj) < 1 then
        v_err_code := 'HR2816';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
        return;
      elsif to_number(v_amtadj) < -9999999.99 or to_number(v_amtadj) > 9999999.99 then
        v_err_code := 'HR2020';
        v_err_text := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang)||v_amtadj;
        return;
      end if;
    end if;
  end check_import_data;

  procedure import_data (json_str_input in clob, json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_flgsecu       boolean := false;
    v_rec_tran      number  := 0;
    v_rec_err       number  := 0;
    v_rcnt          number  := 0;
    v_numrec        number  := 0;
    v_numseq        number  := 0;
    --

    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_qtyscore      varchar2(4000 char);
    v_grade         tapprais.grade%type;
    v_pctcalsal     varchar2(4000 char);
    v_amtbudg       varchar2(4000 char);
    v_amtadj        varchar2(4000 char);
    v_remark        tapprais.remark%type;
    v_err_text      varchar2(4000 char);

    v_typpayroll    temploy1.typpayroll%type;
    v_jobgrade      temploy1.jobgrade%type;
    v_dteempmt      temploy1.dteempmt%type;
    v_amtincom1     temploy3.amtincom1%type;
    v_amtmaxsa      tsalstr.amtmaxsa%type;
    v_amtminsa      tsalstr.amtminsa%type;
    v_midpoint      tsalstr.midpoint%type;
    v_amtsaln       number;
  begin
    initial_value(json_str_input);
    param_json    := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'param_json'));
    --
    obj_row    := json_object_t();
    obj_result := json_object_t();
    for i in 0..param_json.get_size-1 loop
      v_numrec          := i + 1;
      v_numseq          := 0;
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      --

      v_codempid        := hcm_util.get_string_t(param_json_row,'codempid');
      v_codcomp         := hcm_util.get_string_t(param_json_row,'codcomp');
      v_codpos          := hcm_util.get_string_t(param_json_row,'codpos');
      v_qtyscore        := hcm_util.get_string_t(param_json_row,'qtyscore');
      v_grade           := hcm_util.get_string_t(param_json_row,'grade');
      v_pctcalsal       := hcm_util.get_string_t(param_json_row,'pctcalsal');
      v_amtbudg         := hcm_util.get_string_t(param_json_row,'amtbudg');
      v_amtadj          := hcm_util.get_string_t(param_json_row,'amtadj');
      v_remark          := hcm_util.get_string_t(param_json_row,'remark');

      --
      v_err_text        := null;

      check_import_data(v_codempid,v_codcomp,v_codpos,v_qtyscore,v_pctcalsal,v_amtbudg,v_amtadj,v_err_text);
      if v_err_text is null then
          begin
            select typpayroll, jobgrade, dteempmt
              into v_typpayroll, v_jobgrade, v_dteempmt
              from temploy1
             where codempid = v_codempid;
          exception when no_data_found then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
          end;
          begin
            select amtincom1
              into v_amtincom1
              from temploy3
             where codempid = v_codempid;
          exception when no_data_found then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
          end;
          begin
            select amtmaxsa, amtminsa, midpoint
              into v_amtmaxsa,v_amtminsa, v_midpoint
              from tsalstr
             where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
               and dteyreap = p_dteyreap
               and jobgrade = v_jobgrade;
          exception when no_data_found then
            null;
--            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--            return;
          end;

          v_amtsaln := stddec(v_amtincom1, v_codempid, global_v_chken) + stddec(v_amtbudg, v_codempid, global_v_chken) + stddec(v_amtadj, v_codempid, global_v_chken);
          begin
            insert into tapprais (codempid,dteyreap,codcomp,codpos,
                                  typpayroll,jobgrade,qtywork,flgsal,
                                  grade,qtyscore,pctcalsal,amtmidsal,
                                  amtsal,amtbudg,amtadj,amtsaln,
                                  amtceiling,amtminsal,remark,flgtrnpy,
                                  dtecreate,codcreate,dteupd,coduser)
                          values (v_codempid,p_dteyreap,v_codcomp,v_codpos,
                                  v_typpayroll,v_jobgrade,trunc(months_between(sysdate,v_dteempmt)),'Y',
                                  v_grade,v_qtyscore,v_pctcalsal,v_midpoint,
                                  v_amtincom1,v_amtbudg,v_amtadj,stdenc(v_amtsaln, v_codempid, global_v_chken),
                                  v_amtmaxsa,v_amtminsa,v_remark,'N',
                                  sysdate,global_v_coduser,sysdate,global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;



        v_rec_tran := v_rec_tran + 1;
        commit;
      else
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('error_code', v_err_text);
        obj_data.put('text', v_codempid||'|'||v_codcomp||'|'||v_codpos||'|'||v_qtyscore||'|'||v_pctcalsal||'|'||v_amtbudg||'|'||v_amtadj);
        obj_data.put('numseq', v_numrec);
        obj_result.put(to_char(v_rcnt-1),obj_data);
        --
        v_rec_err   := v_rec_err + 1;
      end if;
    end loop;
    --

    obj_row.put('coderror', '200');
    obj_row.put('rec_tran', v_rec_tran);
    obj_row.put('rec_err', v_rec_err);
    obj_row.put('response', 'HR2715'||' '||get_errorm_name('HR2715',global_v_lang));

    obj_row.put('datadisp', obj_result);
    --
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end import_data;
  
  procedure cal_adjsalary(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_codcomp       tapbudgt.codcomp%type;
    v_formusal      tapbudgt.formusal%type;
    v_statement     tapbudgt.statement%type;
    
    v_formusalds    clob;
    v_amtmidsal     number;
    v_pctadjsal     number;
    v_amtsal        number;
    v_amtbudg       number;
    v_amtadj        number;
    v_amtsaln       number;
    
    obj_searchIndex json_object_t;
    obj_dataRow     json_object_t;
    json_obj        json_object_t;

    cursor c1 is
        select codcomp, formusal, statement
          from tapbudgt
         where p_codcomp like codcomp||'%'
           and dteyreap = p_dteyreap
      order by codcomp desc ;
  begin
    initial_value(json_str_input);
    json_obj        := json_object_t(json_str_input);
    obj_searchIndex := hcm_util.get_json_t(json_obj,'searchIndex');
    obj_dataRow     := hcm_util.get_json_t(json_obj,'dataRow');
    
    p_dteyreap      := to_number(hcm_util.get_string_t(obj_searchIndex,'dteyreap'));
    
    p_codcomp       := hcm_util.get_string_t(obj_dataRow,'codcomp');
    v_amtmidsal     := hcm_util.get_string_t(obj_dataRow,'amtmidsal');
    v_pctadjsal     := hcm_util.get_string_t(obj_dataRow,'pctadjsal');
    v_amtsal        := hcm_util.get_string_t(obj_dataRow,'amtsal');
    v_amtadj        := hcm_util.get_string_t(obj_dataRow,'amtadj');
    
    obj_data        := json_object_t();
    for r1 in c1 loop
        v_codcomp   := r1.codcomp;
        v_formusal  := r1.formusal;
        v_statement := r1.statement;
        exit;
    end loop;
    
    if param_msg_error is null then
        begin
            v_formusalds    := v_formusal;
            v_formusalds    := replace(v_formusalds,'{[AMTMID]}',''||v_amtmidsal||'') ;
            v_formusalds    := replace(v_formusalds,'{[AMTINC]}',''||v_pctadjsal||'') ;
            v_formusalds    := replace(v_formusalds,'{[AMTSAL]}',''||v_amtsal||'') ;
            v_amtbudg       := execute_sql('select '||v_formusalds||' from dual');
            v_amtsaln       := v_amtsal + v_amtbudg + v_amtadj;
            
            obj_data.put('coderror', '200');
            obj_data.put('amtbudg', v_amtbudg);
            obj_data.put('amtsaln', v_amtsaln);
            json_str_output := obj_data.to_clob;
            return;
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

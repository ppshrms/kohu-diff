--------------------------------------------------------
--  DDL for Package Body HRAP25U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP25U" is
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
    p_codincom          := hcm_util.get_string_t(json_obj,'p_codincom');

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
    if p_dteyreap is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_numtime is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;        
    end if;

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
    cursor c1 is
          select codcomadj,codincom,numemp,
                 stddec(amttadj,codemprq,v_chken) amttadj,
                 staappr,approvno,dteappr,
                 codemprq,dteyreap,numtime,numdoc
            from ttemadj1
           where dteyreap = p_dteyreap
             and numtime = p_numtime
             and codcomadj like p_codcomp||'%'
             and staappr in ('P' ,'A')
        order by dteyreap,numtime,codcomadj,codincom;
  begin
    --table
    v_rcnt      := 0;
    obj_row     := json_object_t();
    obj_main    := json_object_t();

    for r1 in c1 loop
      v_flgdata     := 'Y';
      v_approvno    := nvl(r1.approvno,0) + 1;
      v_flgpass     := chk_flowmail.check_approve('HRAP23E', r1.codemprq, v_approvno, global_v_codempid, null, null, v_check);
      if (v_flgpass) then
          v_secur       := 'Y';
          obj_data      := json_object_t();
          v_rcnt        := v_rcnt + 1;
          obj_data.put('coderror', '200');
          obj_data.put('codcomp',r1.codcomadj);
          obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomadj, global_v_lang));
          obj_data.put('codincom',r1.codincom);
          obj_data.put('desc_codincom',get_tinexinf_name(r1.codincom ,global_v_lang)); 
          obj_data.put('numemp',r1.numemp);
          obj_data.put('amttadj',r1.amttadj);
          obj_data.put('desc_staappr',get_tlistval_name('STAAPPR',r1.staappr,global_v_lang));
          obj_data.put('last_approvno',r1.approvno);
          obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
          obj_data.put('codemprq',r1.codemprq);
          obj_data.put('approvno',v_approvno);
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_flgdata = 'Y' AND v_secur = 'Y' then
      json_str_output := obj_row.to_clob;
    elsif v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TTEMADJ1');
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

    v_codemprq      ttemadj1.codemprq%type;
    v_codcomp       taptempadj.codcomadj%type;
    v_codincom      taptempadj.codincom%type;

    v_approvno      number;
    v_flgpass     	boolean;
    v_check         varchar2(500 char);

    cursor c1 is
        select *
          from taptempadj
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codcomadj = v_codcomp
           and codincom = v_codincom
           and approvno < v_approvno
      order by approvno;
  begin

    v_rcnt_main     := 0;
    obj_row_main    := json_object_t();
    for i in 0..p_index_rows.get_size-1 loop
        v_rcnt          := 0;
        v_row           := json_object_t();
        v_row           := hcm_util.get_json_t(p_index_rows,to_char(i));
        v_codemprq      := hcm_util.get_string_t(v_row,'codemprq');
        v_codcomp       := hcm_util.get_string_t(v_row,'codcomp');
        v_codincom      := hcm_util.get_string_t(v_row,'codincom');
        v_approvno      := to_number(hcm_util.get_string_t(v_row,'approvno'));

        v_rcnt_main     := v_rcnt_main + 1;
        v_flgpass       := chk_flowmail.check_approve('HRAP23E', v_codemprq, v_approvno, global_v_codempid, null, null, v_check);
        obj_row         := json_object_t();
        for r1 in c1 loop
            v_rcnt          := v_rcnt +1;
            obj_data        := json_object_t();
            obj_data.put('codemprq',v_codemprq);
            obj_data.put('codcomadj',v_codcomp);
            obj_data.put('dteyreap',p_dteyreap);
            obj_data.put('numtime',r1.numtime);
            obj_data.put('codincom',r1.codincom);
            obj_data.put('numseq',r1.approvno);
            obj_data.put('approvno',r1.approvno);
            obj_data.put('codappr',r1.codappr);
            obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
            obj_data.put('staappr',r1.staappr);
            obj_data.put('remark',r1.remarkap);
            obj_data.put('disabled',true);
            obj_data.put('flglastappr',false);
            obj_data.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
            obj_data.put('codtrn',r1.codtrn);
            obj_data.put('numannou',r1.numannou);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;

        v_rcnt          := v_rcnt +1;
        obj_data        := json_object_t();
        obj_data.put('codemprq',v_codemprq);
        obj_data.put('codcomadj',v_codcomp);
        obj_data.put('dteyreap',p_dteyreap);
        obj_data.put('numtime',p_numtime);
        obj_data.put('codincom',v_codincom);
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
            obj_data.put('numannou','');
        else
            obj_data.put('flglastappr',false);
            obj_data.put('dteeffec',to_char(trunc(sysdate),'dd/mm/yyyy'));
            obj_data.put('codtrn','');
            obj_data.put('numannou','');
        end if;

        obj_row.put(to_char(v_rcnt-1),obj_data);

        obj_data_main   := json_object_t();
        obj_data_main.put('coderror', '200');
        obj_data_main.put('codcomp',v_codcomp);
        obj_data_main.put('desc_codcomp',get_tcenter_name(v_codcomp, global_v_lang));
        obj_data_main.put('codincom',v_codincom);
        obj_data_main.put('desc_codincom',get_tinexinf_name(v_codincom ,global_v_lang));
        obj_data_main.put('detail',obj_row);
        obj_row_main.put(to_char(v_rcnt_main-1),obj_data_main);
    end loop;

    json_str_output := obj_row_main.to_clob;
  end;

  procedure send_approve(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    v_dteyreap      taptempadj.dteyreap%type;
    v_numtime       taptempadj.numtime%type;
    v_codincom      taptempadj.codincom%type;
    v_codcomadj     taptempadj.codcomadj%type;
    v_approvno      taptempadj.approvno%type;
    v_codemprq       ttemadj1.codemprq%type;
    v_codappr       taptempadj.codappr%type;
    v_dteappr       taptempadj.dteappr%type;
    v_remark        taptempadj.remarkap%type;
    v_staappr       taptempadj.staappr%type;
    v_staappr2      taptempadj.staappr%type;
    v_dteeffec      taptempadj.dteeffec%type;
    v_codtrn        taptempadj.codtrn%type;
    v_numannou      taptempadj.numannou%type;

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
    v_amtincom1             number;
    v_amtincom2             number;
    v_amtincom3             number;
    v_amtincom4             number;
    v_amtincom5             number;
    v_amtincom6             number;
    v_amtincom7             number;
    v_amtincom8             number;
    v_amtincom9             number;
    v_amtincom10            number;
    v_amtincadj1            number;
    v_amtincadj2            number;
    v_amtincadj3            number;
    v_amtincadj4            number;
    v_amtincadj5            number;
    v_amtincadj6            number;
    v_amtincadj7            number;
    v_amtincadj8            number;
    v_amtincadj9            number;
    v_amtincadj10           number;
    v_codcurr               temploy3.codcurr%type;

    v_amtothr               number;
    v_amtday                number;
    v_amtmth                number;
    v_numseq                ttmovemt.numseq%type;
    tapprais_codcomp        tapprais.codcomp%type;
    tapprais_amtsal         tapprais.amtsal%type;
    v_amtsaln               number;
    v_pctadjsal             tapprais.pctadjsal%type;
    v_amtbudg               number;
    v_amtadj                number;

    v_codempid              ttemadj2.codempid%type;

    v_codincom1             tcontpms.codincom1%type;
    v_codincom2             tcontpms.codincom2%type;
    v_codincom3             tcontpms.codincom3%type;
    v_codincom4             tcontpms.codincom4%type;
    v_codincom5             tcontpms.codincom5%type;
    v_codincom6             tcontpms.codincom6%type;
    v_codincom7             tcontpms.codincom7%type;
    v_codincom8             tcontpms.codincom8%type;
    v_codincom9             tcontpms.codincom9%type;
    v_codincom10            tcontpms.codincom10%type;
    v_seq                   number;
    v_filename              varchar2(1000 char);
    cursor c_ttemadj2 is
        select dteyreap, numtime, codincom,
               codempid, codcomp, numlvl,
               stddec(amtincnw,codempid,v_chken) amtincnw,
               stddec(amtadj,codempid,v_chken) amtadj,
               decode(stddec(amtincod,codempid,v_chken),0,0,round(((stddec(amtincnw,codempid,v_chken) - stddec(amtincod,codempid,v_chken))/stddec(amtincod,codempid,v_chken))*100,2)) ratechge,
               stddec(amtincod,codempid,v_chken) amtincod
          from ttemadj2
         where dteyreap = v_dteyreap
           and numtime = v_numtime
           and codincom = v_codincom
           and codcomadj = v_codcomadj
      order by codempid;

  begin
    initial_value(json_str_input);
--    check_save;
    if param_msg_error is null then
        begin
            for i in 0..p_selected_rows.get_size-1 loop
                delete ttemprpt where codapp = 'HRAP25U' and codempid = global_v_codempid;
                delete ttempprm where codapp = 'HRAP25U' and codempid = global_v_codempid;

                obj_row         := json_object_t();
				obj_row         := hcm_util.get_json_t(p_selected_rows,to_char(i));
                v_dteyreap      := hcm_util.get_string_t(obj_row,'dteyreap');
                v_numtime       := hcm_util.get_string_t(obj_row,'numtime');
                v_codcomadj     := hcm_util.get_string_t(obj_row,'codcomadj');
                v_codincom      := hcm_util.get_string_t(obj_row,'codincom');

                v_codemprq       := hcm_util.get_string_t(obj_row,'codemprq');
                v_approvno      := hcm_util.get_string_t(obj_row,'approvno');
                v_dteappr       := to_date(hcm_util.get_string_t(obj_row,'dteappr'),'dd/mm/yyyy');
                v_codappr       := hcm_util.get_string_t(obj_row,'codappr');
                v_staappr       := hcm_util.get_string_t(obj_row,'staappr');
                v_remark        := hcm_util.get_string_t(obj_row,'remark');

                v_dteeffec      := to_date(hcm_util.get_string_t(obj_row,'dteeffec'),'dd/mm/yyyy');
                v_codtrn        := hcm_util.get_string_t(obj_row,'codtrn');
                v_numannou      := hcm_util.get_string_t(obj_row,'numannou');

                insert into  ttempprm (codempid,codapp,namrep,pdate,ppage,
                                       label1,label2,label3,
                                       label4,label5,label6)
                               values (global_v_codempid, 'HRAP25U',get_label_name('HRAP25U5', global_v_lang, 10), 'Date/Time','Page No :',
                                       get_label_name('HRAP25U5', global_v_lang, 20),
                                       get_label_name('HRAP25U5', global_v_lang, 30),
                                       get_label_name('HRAP25U5', global_v_lang, 40),
                                       get_label_name('HRAP25U5', global_v_lang, 50),
                                       get_label_name('HRAP25U5', global_v_lang, 60),
                                       get_label_name('HRAP25U5', global_v_lang, 70)
                                       );

                v_seq := 0;

                for r_ttemadj2 in c_ttemadj2 loop 
                    v_seq := v_seq + 1;  
                    insert into  ttemprpt (codempid,codapp,numseq,
                                           item1,item2,item3,
                                           item4,item5,item6)
                                   values (global_v_codempid, 'HRAP25U', v_seq,
                                           r_ttemadj2.codempid, get_temploy_name(r_ttemadj2.codempid, global_v_lang), 
                                           to_char(r_ttemadj2.amtincod,'fm999,999,999,990.00'),
                                           to_char(r_ttemadj2.ratechge,'fm999,999,999,990.00'), 
                                           to_char(r_ttemadj2.amtadj,'fm999,999,999,990.00'), 
                                           to_char(r_ttemadj2.amtincnw,'fm999,999,999,990.00'));
                end loop;
                commit;

                v_filename  := 'HRAP25U_'||to_char(sysdate,'yyyymmddhh24mi');

                begin
                    insert into taptempadj (dteyreap,numtime,codcomadj,codincom,
                                            approvno,codappr,dteappr,staappr,remarkap,
                                            dteeffec,codtrn,numannou,
                                            dtecreate,codcreate,dteupd,coduser)
                                  values (v_dteyreap,v_numtime,v_codcomadj,v_codincom,
                                          v_approvno,v_codappr,v_dteappr,v_staappr,v_remark,
                                          v_dteeffec,v_codtrn,v_numannou,
                                          sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    null;
                end;
                if v_staappr = 'N' then
                    update ttemadj1
                       set staappr = v_staappr,
                           codappr = v_codappr,
                           dteappr = v_dteappr,
                           remarkap = v_remark,
                           approvno = v_approvno
                     where dteyreap = v_dteyreap
                       and numtime = v_numtime
                       and codcomadj = v_codcomadj
                       and codincom = v_codincom;
                else
                    v_flgpass := chk_flowmail.check_approve('HRAP23E', v_codemprq, v_approvno, global_v_codempid, null, null, v_check);
                    if v_check = 'Y' then
                        v_staappr2 := 'Y';

                        update ttemadj1
                           set staappr = v_staappr2,
                               codappr = v_codappr,
                               dteappr = v_dteappr,
                               remarkap = v_remark,
                               approvno = v_approvno,
                               dteeffec = v_dteeffec,
                               codtrn = v_codtrn,
                               numdoc = v_numannou
                         where dteyreap = v_dteyreap
                           and numtime = v_numtime
                           and codcomadj = v_codcomadj
                           and codincom = v_codincom;

                        for r_ttemadj2 in c_ttemadj2 loop
                            v_codempid := r_ttemadj2.codempid;

                            select a.codcomp, a.codpos, a.codjob, a.numlvl,
                                   a.codbrlc, a.codcalen, a.flgatten, a.dteefpos, a.dteduepr,
                                   a.codedlv, a.codsex, a.codempmt, a.typpayroll, a.typemp,
                                   a.dteempmt,
                                   stddec(b.amtincom1, a.codempid, global_v_chken) amtincom1,
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
                                   v_dteempmt, v_amtincom1,
                                   v_amtincom2, v_amtincom3,
                                   v_amtincom4, v_amtincom5,
                                   v_amtincom6, v_amtincom7,
                                   v_amtincom8, v_amtincom9,
                                   v_amtincom10,v_codcurr
                              from temploy1 a, temploy3 b
                             where a.codempid = v_codempid
                               and a.codempid = b.codempid
                               and a.staemp in ('1','3');

                            select codincom1,codincom2,codincom3,codincom4,codincom5,
                                   codincom6,codincom7,codincom8,codincom9,codincom10
                              into v_codincom1,v_codincom2,v_codincom3,v_codincom4,v_codincom5,
                                   v_codincom6,v_codincom7,v_codincom8,v_codincom9,v_codincom10
                              from tcontpms
                             where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                               and dteeffec = (select max(dteeffec)
                                                 from tcontpms
                                                where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                                                  and dteeffec <= trunc(sysdate));

                            v_amtincadj1    := v_amtincom1;
                            v_amtincadj2    := v_amtincom2;
                            v_amtincadj3    := v_amtincom3;
                            v_amtincadj4    := v_amtincom4;
                            v_amtincadj5    := v_amtincom5;
                            v_amtincadj6    := v_amtincom6;
                            v_amtincadj7    := v_amtincom7;
                            v_amtincadj8    := v_amtincom8;
                            v_amtincadj9    := v_amtincom9;
                            v_amtincadj10   := v_amtincom10;

                            if v_codincom = v_codincom1 then
                                v_amtincom1 := r_ttemadj2.amtincnw;
                                v_amtincadj1 := r_ttemadj2.amtadj;
                            elsif v_codincom = v_codincom2 then
                                v_amtincom2 := r_ttemadj2.amtincnw;
                                v_amtincadj2 := r_ttemadj2.amtadj;
                            elsif v_codincom = v_codincom3 then
                                v_amtincom3 := r_ttemadj2.amtincnw;
                                v_amtincadj3 := r_ttemadj2.amtadj;
                            elsif v_codincom = v_codincom4 then
                                v_amtincom4 := r_ttemadj2.amtincnw;
                                v_amtincadj4 := r_ttemadj2.amtadj;
                            elsif v_codincom = v_codincom5 then
                                v_amtincom5 := r_ttemadj2.amtincnw;
                                v_amtincadj5 := r_ttemadj2.amtadj;
                            elsif v_codincom = v_codincom6 then
                                v_amtincom6 := r_ttemadj2.amtincnw;
                                v_amtincadj6 := r_ttemadj2.amtadj;
                            elsif v_codincom = v_codincom7 then
                                v_amtincom7 := r_ttemadj2.amtincnw;
                                v_amtincadj7 := r_ttemadj2.amtadj;
                            elsif v_codincom = v_codincom8 then
                                v_amtincom8 := r_ttemadj2.amtincnw;
                                v_amtincadj8 := r_ttemadj2.amtadj;
                            elsif v_codincom = v_codincom9 then
                                v_amtincom9 := r_ttemadj2.amtincnw;
                                v_amtincadj9 := r_ttemadj2.amtadj;
                            elsif v_codincom = v_codincom10 then
                                v_amtincom10 := r_ttemadj2.amtincnw;
                                v_amtincadj10 := r_ttemadj2.amtadj;
                            end if;
                            get_wage_income(hcm_util.get_codcomp_level(v_codcomp,1), v_codempmt,
                                               v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
                                               v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10,
                                               v_amtothr, v_amtday, v_amtmth);

                            v_amtothr   := round(v_amtothr,2);
                            v_amtday    := round(v_amtday,2);
                            v_amtmth    := round(v_amtmth,2);
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
                                                    amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,
                                                    amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,
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
                                        stdenc(v_amtincadj1, v_codempid, global_v_chken),stdenc(v_amtincadj2, v_codempid, global_v_chken),
                                        stdenc(v_amtincadj3, v_codempid, global_v_chken),stdenc(v_amtincadj4, v_codempid, global_v_chken),
                                        stdenc(v_amtincadj5, v_codempid, global_v_chken),stdenc(v_amtincadj6, v_codempid, global_v_chken),
                                        stdenc(v_amtincadj7, v_codempid, global_v_chken),stdenc(v_amtincadj8, v_codempid, global_v_chken),
                                        stdenc(v_amtincadj9, v_codempid, global_v_chken),stdenc(v_amtincadj10, v_codempid, global_v_chken),
                                        stdenc(v_amtothr, v_codempid, global_v_chken),v_codcurr,v_codappr,v_dteappr,v_remark,
                                        v_approvno,
                                        sysdate,global_v_coduser,sysdate,global_v_coduser);
                            exception when others then
                                null;
                            end;
                        end loop;
                    else
                        v_staappr2 := 'A';
                        update ttemadj1
                           set staappr = v_staappr2,
                               codappr = v_codappr,
                               dteappr = v_dteappr,
                               remarkap = v_remark,
                               approvno = v_approvno
                         where dteyreap = v_dteyreap
                           and numtime = v_numtime
                           and codcomadj = v_codcomadj
                           and codincom = v_codincom;

                        select rowid
                          into v_rowid
                          from ttemadj1
                         where dteyreap = v_dteyreap
                           and numtime = v_numtime
                           and codcomadj = v_codcomadj
                           and codincom = v_codincom;

                        begin
                            excel_mail('item1,item2,item3,item4,item5,item6','label1,label2,label3,label4,label5,label6',null,global_v_codempid, 'HRAP25U',v_filename);  
                            v_error := chk_flowmail.send_mail_for_approve('HRAP23E', v_codemprq, global_v_codempid, global_v_coduser, v_filename, 'HRAP25U1', 140, 'U', v_staappr, v_approvno + 1, null, null,'TTEMADJ1',v_rowid, '1', 'Oracle');
                        exception when others then
                          param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
                        end;  
                    end if;
                  end if;             
                begin
                    select rowid
                      into v_rowid
                      from ttemadj1
                     where dteyreap = v_dteyreap
                       and numtime = v_numtime
                       and codcomadj = v_codcomadj
                       and codincom = v_codincom;
                exception when no_data_found then
                    v_rowid := null;
                end;

                ---ส่งเมลหาผู้ขออนุมัติ
                begin
                    excel_mail('item1,item2,item3,item4,item5,item6','label1,label2,label3,label4,label5,label6',null,global_v_codempid, 'HRAP25U',v_filename);  
                    v_error := chk_flowmail.send_mail_reply('HRAP25U', v_codemprq, v_codemprq , global_v_codempid, global_v_coduser, v_filename, 'HRAP25U1', 140, 'U', v_staappr, v_approvno, null, null, 'TTEMADJ1', v_rowid, '1', 'Oracle');
                exception when others then
                    null;
--                    param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
                end;  
            end loop;
            commit;
        exception when others then
            rollback;
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end;
        if param_msg_error_mail is null then
          param_msg_error := get_error_msg_php('HR2402',global_v_lang);
          json_str_output := get_response_message(200,param_msg_error,global_v_lang);
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


  procedure gen_detail(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    obj_syncond         json_object_t;
    obj_formula         json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_flgsecu           boolean := false;
    cursor c1 is
        select codcomadj,codincom,numemp,
               stddec(amttadj,codemprq,v_chken) amttadj,
               staappr,dteappr,
               codemprq,dteyreap,
--               stddec(amtmax,hcm_util.get_codcomp_level(codcomadj,1),v_chken) amtmax,
--               stddec(amtmin,hcm_util.get_codcomp_level(codcomadj,1),v_chken) amtmin,
               amtmax,
               amtmin,
               dteadjin,formula,formulas,descond,desconds
          from ttemadj1
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codcomadj = p_codcomp
           and codincom = p_codincom;	  
  begin
    obj_result      := json_object_t;
    obj_row         := json_object_t();
    obj_syncond     := json_object_t();
    obj_formula     := json_object_t();
    begin
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        for r1 in c1 loop
            obj_data.put('amtmax',r1.amtmax);
            obj_data.put('amtmin',r1.amtmin);
            obj_data.put('amttadj',to_char(r1.amttadj,'fm999,999,999,990.00'));
            obj_data.put('codemprq',r1.codemprq);
            obj_data.put('desc_codemprq',get_temploy_name(r1.codemprq,global_v_lang));
            obj_data.put('dteadjin',to_char(r1.dteadjin,'dd/mm/yyyy'));
            obj_data.put('desc_codincom',get_tinexinf_name(r1.codincom ,global_v_lang)); 
            obj_data.put('numemp',r1.numemp);
            obj_data.put('staappr',get_tlistval_name('STAAPPR', r1.staappr,global_v_lang));
            obj_formula.put('code', r1.formulas);
            obj_formula.put('description', r1.formula);
--            obj_formula.put('description', hcm_formula.get_description(r1.formulas, global_v_lang));
            obj_data.put('formula',obj_formula);
            obj_syncond.put('code', r1.descond);
            obj_syncond.put('description', get_logical_desc(r1.desconds));
            obj_syncond.put('statement', r1.desconds);
            obj_data.put('syncond', obj_syncond);
        end loop;
    exception when others then 
        null;
    end;
    json_str_output := obj_data.to_clob;
  end ;

  procedure get_detail (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_table(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_pctsal            number := 0;
    v_secur             boolean := false;
    v_rcnt              number := 0;
    v_zupdsal           varchar2(100);

    cursor c1 is
        select codcomadj,codincom,stddec(amtincnw,codempid,v_chken) amtincnw,
               stddec(amtadj,codempid,v_chken) amtadj,
               stddec(amtincod,codempid,v_chken) amtincod,
               dteyreap,codempid,codcomp,numlvl
          from ttemadj2
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codcomadj like p_codcomp||'%'
           and codincom = p_codincom
      order by codempid;	
  begin
    v_rcnt      := 0;
    obj_row     := json_object_t();
    for r1 in c1 loop
        v_secur   := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,
                                     v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);    

--        if v_secur and v_zupdsal = 'Y' then
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            v_rcnt := v_rcnt + 1;
            obj_data.put('image',get_emp_img(r1.codempid));
            obj_data.put('codempid',r1.codempid);
            obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
            obj_data.put('codincom',r1.codincom);
            obj_data.put('desc_codincom',get_tinexinf_name(r1.codincom ,global_v_lang)); 
            obj_data.put('amtincod',r1.amtincod);
            obj_data.put('amtadj',r1.amtadj);
            obj_data.put('amtincnw',r1.amtincnw);
            if r1.amtincod = 0 then
                v_pctsal := 0;
            else
                v_pctsal := (r1.amtadj/r1.amtincod)*100;
            end if;

            obj_data.put('pctsal',to_char(v_pctsal,'FM99990.00'));
            obj_row.put(to_char(v_rcnt-1),obj_data);
--        end if;
    end loop;
    json_str_output := obj_row.to_clob;
  end ;

  procedure get_detail_table (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail_table(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;
end;

/

--------------------------------------------------------
--  DDL for Package Body HRRP4CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP4CE" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_year        := hcm_util.get_string_t(json_obj,'p_year');
    b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numtime');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codpos      := hcm_util.get_string_t(json_obj,'p_codpos');
    p_codappr           := hcm_util.get_string_t(json_obj,'p_codappr');
    p_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'dd/mm/yyyy');
    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_typcond           := hcm_util.get_string_t(json_obj,'p_typcond');
    p_stmt              := hcm_util.get_string_t(json_obj,'p_stmt');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure check_index is
    v_error   varchar2(4000);
  begin
    -- b_index_codpos check in frontend
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
    v_secur         boolean := false;
    v_chk_data      varchar2(1) := 'N';
    v_chk_secur     varchar2(1) := 'N';
    v_check         varchar2(50);
    v_approvno      tbudget.approvno%type;
    v_flg_found     varchar2(1) := 'N';
    obj_row_tb1     json_object_t;
    obj_row_tb2     json_object_t;
    obj_tb1         json_object_t;
    obj_tb2         json_object_t;

    cursor c_tsuccpln is
      select *
        from tsuccpln
       where dteyear    = b_index_year
         and numtime    = b_index_numtime
         and codcomp    like b_index_codcomp||'%'
         and codpos     = b_index_codpos
      order by numseq;

  begin
    obj_row   := json_object_t();
    for i in c_tsuccpln loop
      v_chk_data    := 'Y';
      v_secur       := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if v_secur then
        v_chk_secur := 'Y';
        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid',i.codempid);
        obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
        obj_data.put('codcomp',i.codcompe);
        obj_data.put('desc_codcomp',get_tcenter_name(i.codcompe, global_v_lang));
        obj_data.put('codpos',i.codpose);
        obj_data.put('desc_codpos',get_tpostn_name(i.codpose , global_v_lang));
        obj_data.put('codcompn',i.codcompe);
        obj_data.put('desc_codcompn',get_tcenter_name(i.codcompe, global_v_lang));
        obj_data.put('codposn',i.codpose);
        obj_data.put('desc_codposn',get_tpostn_name(i.codpose , global_v_lang));
        obj_data.put('numseq',i.numseq);
        obj_data.put('stasuccr',i.stasuccr);
        obj_data.put('desc_stasuccr',GET_TLISTVAL_NAME('STASUCCR', i.stasuccr, global_v_lang));
        obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
        obj_data.put('codappr',i.codappr);
        obj_data.put('desc_codappr',get_temploy_name(i.codappr,global_v_lang));
        obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
        obj_data.put('remark',i.remarkap);
        obj_data.put('coursreq','<span class="fa fa-pencil text-blue" aria-hidden="true"></span>');
        obj_row_tb1     := json_object_t();
        obj_tb1         := json_object_t();
        p_codempid_query := i.codempid;
        gen_detail_course(obj_row_tb1);
        obj_tb1.put('rows',obj_row_tb1);
        obj_data.put('table1',obj_tb1);

        obj_row_tb2     := json_object_t();
        obj_tb2         := json_object_t();
        gen_detail_develop(obj_row_tb2);
        obj_tb2.put('rows',obj_row_tb2);
        obj_data.put('table2',obj_tb2);

        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt      := v_rcnt + 1;
      end if;
    end loop;
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

  procedure get_index_detail(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure gen_index_detail(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_secur         boolean := false;
    v_chk_data      varchar2(1) := 'N';
    v_chk_secur     varchar2(1) := 'N';
    v_check         varchar2(50);
    v_approvno      tbudget.approvno%type;
    v_flg_found     varchar2(1) := 'N';

    cursor c_tsuccpln is
      select *
        from tsuccpln
       where dteyear    = b_index_year
         and numtime    = b_index_numtime
         and codcomp    like b_index_codcomp||'%'
         and codpos     = b_index_codpos
         and dteappr    is not null
      order by dteappr desc;

  begin
    obj_data   := json_object_t();
    for i in c_tsuccpln loop
      v_chk_data    := 'Y';
      v_secur       := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if v_secur then
        v_chk_secur := 'Y';
        obj_data.put('coderror','200');
        obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
        obj_data.put('codappr',i.codappr);
        v_rcnt      := v_rcnt + 1;
        exit;
      end if;
    end loop;
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure check_save(json_str_input in clob) is ----
    json_input              json_object_t;
    param_json              json_object_t;
    param_json_row          json_object_t;

    v_codcomp               tbudget.codcomp%type;
    v_codpos                tbudget.codpos%type;
  begin
    json_input          := json_object_t(json_str_input);
    param_json          := hcm_util.get_json_t(json_input,'param_json');

    for i in 0..(param_json.get_size - 1) loop

      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_codcomp         := hcm_util.get_string_t(param_json_row,'codcomp');
      v_codpos          := hcm_util.get_string_t(param_json_row,'codpos');

      if get_compful(b_index_codcomp) = v_codcomp and b_index_codpos = v_codpos then
        param_msg_error := get_error_msg_php('RP0038', global_v_lang);
        return;
      end if;
    end loop;
  end;
  --
  procedure save_index(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_save(json_str_input); ----
    if param_msg_error is null then
      process_save_index(json_str_input, json_str_output);
    else
      rollback;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure process_save_index(json_str_input in clob,json_str_output out clob) is
    json_input              json_object_t;
    param_json              json_object_t;
    param_json_row          json_object_t;
    param_detail1           json_object_t;
    param_detail1_row       json_object_t;
    param_detail2           json_object_t;
    param_detail2_row       json_object_t;

    v_dteyrbug              number;
    v_codcomp               tbudget.codcomp%type;
    v_codpos                tbudget.codpos%type;

    v_codempid              tsuccpln.codempid%type;
    v_flg                   varchar2(50);
    v_stasuccr              tsuccpln.stasuccr%type;
    v_remarkap              tsuccpln.remarkap%type;
    v_dteeffec              tsuccpln.dteeffec%type;
    v_numseq                tsuccpln.numseq%type;

    v_codcours              tsucctrn.codcours%type;
    v_dtestr                tsucctrn.dtestr%type;
    v_dteend                tsucctrn.dteend%type;
    v_dtetrst               tsucctrn.dtetrst%type;
    v_dtetren               tsucctrn.dtetren%type;

    v_coddevp               tsuccdev.coddevp%type;
    v_desdevp               tsuccdev.desdevp%type;
    v_destarget             tsuccdev.destarget%type;
    v_desresults            tsuccdev.desresults%type;
    v_flg_detail            varchar2(50);
    v_grade_current         tcmptncy.grade%type;
    v_flgAdd                boolean;
    v_flgEdit               boolean;
    v_flgDelete             boolean;

    json_output json_object_t;

    cursor c_tjobposskil is
      select *
        from tjobposskil
       where codcomp    like b_index_codcomp||'%'
         and codpos     = b_index_codpos
      order by codskill;
  begin

    json_input          := json_object_t(json_str_input);
    param_json          := hcm_util.get_json_t(json_input,'param_json');

    for i in 0..(param_json.get_size - 1) loop

      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_codcomp         := hcm_util.get_string_t(param_json_row,'codcomp');
      v_codpos          := hcm_util.get_string_t(param_json_row,'codpos');
      v_codempid        := hcm_util.get_string_t(param_json_row,'codempid');
      v_stasuccr        := hcm_util.get_string_t(param_json_row,'stasuccr');
      v_remarkap        := hcm_util.get_string_t(param_json_row,'remark');
      v_dteeffec        := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
      v_numseq          := to_number(hcm_util.get_string_t(param_json_row,'numseq'));
      v_flg             := hcm_util.get_string_t(param_json_row,'flg');
      param_detail1     := hcm_util.get_json_t(param_json_row,'table1');
      param_detail1     := hcm_util.get_json_t(param_detail1,'rows');
      param_detail2     := hcm_util.get_json_t(param_json_row,'table2');
      param_detail2     := hcm_util.get_json_t(param_detail2,'rows');
--      param_detail_row
      -----
      if v_flg = 'add' or v_flg = 'edit' then
         begin
             insert into tsuccpln (codcomp,codpos,dteyear,numtime,numseq,codempid,    --b_index_codcomp || #7112 || 28/10/2021
                                   codcompe,codpose,stasuccr,dteappr,codappr,
                                   remarkap,dteeffec,dtecreate,codcreate,dteupd,coduser)
             values (rpad(b_index_codcomp,40,'0'),b_index_codpos,b_index_year,b_index_numtime,v_numseq,v_codempid,
                     v_codcomp,v_codpos,v_stasuccr,p_dteappr,p_codappr,
                     v_remarkap,v_dteeffec,sysdate,global_v_coduser,sysdate,global_v_coduser);
         exception when dup_val_on_index then
            update tsuccpln
               set codempid = v_codempid,
                   codcompe = v_codcomp,
                   codpose = v_codpos,
                   stasuccr = v_stasuccr,
                   dteappr = p_dteappr,
                   codappr = p_codappr,
                   remarkap = v_remarkap,
                   dteeffec = v_dteeffec,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codcomp = b_index_codcomp
               and codpos = b_index_codpos
               and dteyear = b_index_year
               and numtime = b_index_numtime
               and numseq = v_numseq;
         end;

         for r1 in c_tjobposskil loop
            begin
                select nvl(grade,0)
                  into v_grade_current
                  from tcmptncy
                 where codtency = r1.codskill
                   and codempid = v_codempid;
            exception when others then
                v_grade_current := 0;
            end;

            begin
            insert into tsuccmpc (codempid,codcomp,codpos,codtency,grade,
                                  grdemp,dtecreate,codcreate,dteupd,coduser)
            values (v_codempid,rpad(b_index_codcomp,40,'0'),b_index_codpos,r1.codskill,r1.grade,  --b_index_codcomp || #7112 || 28/10/2021
                    v_grade_current,sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update tsuccmpc
                   set grade = r1.grade,
                       grdemp = v_grade_current,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codempid = v_codempid
                   and codcomp = b_index_codcomp
                   and codpos = b_index_codpos
                   and codtency = r1.codskill;
            end;
         end loop;

         for j in 0..(param_detail1.get_size - 1) loop
            param_detail1_row    := hcm_util.get_json_t(param_detail1,to_char(j));
            v_codcours           := hcm_util.get_string_t(param_detail1_row,'codcours');
            v_dtestr             := to_date(hcm_util.get_string_t(param_detail1_row,'dtetargst'),'dd/mm/yyyy');
            v_dteend             := to_date(hcm_util.get_string_t(param_detail1_row,'dtetargen'),'dd/mm/yyyy');
            v_dtetrst            := to_date(hcm_util.get_string_t(param_detail1_row,'dtetrin'),'dd/mm/yyyy');
            v_dtetren            := to_date(hcm_util.get_string_t(param_detail1_row,'dtetrin'),'dd/mm/yyyy');
            v_flg_detail         := hcm_util.get_string_t(param_detail1_row,'flg');
            v_flgAdd             := hcm_util.get_boolean_t(param_detail1_row,'flgAdd');
            v_flgEdit            := hcm_util.get_boolean_t(param_detail1_row,'flgEdit');
            v_flgDelete          := hcm_util.get_boolean_t(param_detail1_row,'flgDelete');


            begin
                if v_flgAdd then
                    insert into tsucctrn (codempid,codcomp,codpos,codcours,
                                          dtestr,dteend,dtetrst,dtetren,
                                          dtecreate,codcreate,dteupd,coduser)
                    values (v_codempid,rpad(b_index_codcomp,40,'0'),b_index_codpos,v_codcours, --b_index_codcomp || #7112 ||  28/10/2021
                                          v_dtestr,v_dteend,v_dtetrst,v_dtetren,
                                          sysdate,global_v_coduser,sysdate,global_v_coduser);
                elsif v_flgEdit then
                    update tsucctrn
                       set dtestr = v_dtestr,
                           dteend = v_dteend,
                           dtetrst = v_dtetrst,
                           dtetren = v_dtetren,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codempid = v_codempid
                       and codcomp = b_index_codcomp
                       and codpos = b_index_codpos
                       and codcours = v_codcours;
                elsif v_flgDelete then
                    delete tsucctrn
                     where codempid = v_codempid
                       and codcomp = b_index_codcomp
                       and codpos = b_index_codpos
                       and codcours = v_codcours;
                end if;
            exception when others then
                param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                rollback;
                return;
            end;
         end loop;


         for k in 0..(param_detail2.get_size - 1) loop    
            param_detail2_row   := hcm_util.get_json_t(param_detail2,to_char(k));
            v_coddevp           := hcm_util.get_string_t(param_detail2_row,'coddevp');
            v_desdevp           := hcm_util.get_string_t(param_detail2_row,'desdevp');
            v_destarget         := hcm_util.get_string_t(param_detail2_row,'destarget');
            v_dtestr            := to_date(hcm_util.get_string_t(param_detail2_row,'dtestr'),'dd/mm/yyyy');
            v_dteend            := to_date(hcm_util.get_string_t(param_detail2_row,'dteend'),'dd/mm/yyyy');
            v_desresults        := hcm_util.get_string_t(param_detail2_row,'desresults'); -- #7117 || 01/06/2022          
            v_flg_detail        := hcm_util.get_string_t(param_detail2_row,'flg');
            v_flgAdd            := hcm_util.get_boolean_t(param_detail2_row,'flgAdd');
            v_flgEdit           := hcm_util.get_boolean_t(param_detail2_row,'flgEdit');
            v_flgDelete         := hcm_util.get_boolean_t(param_detail2_row,'flgDelete');
            begin
                if v_flgAdd then
                    insert into tsuccdev (codempid,codcomp,codpos,coddevp,
                                          desdevp,destarget,dtestr,dteend,
                                          desresults,dtecreate,codcreate,dteupd,coduser)
                    values (v_codempid,rpad(b_index_codcomp,40,'0'),b_index_codpos,v_coddevp, --b_index_codcomp || #7112 || 28/10/2021
                                          v_desdevp,v_destarget,v_dtestr,v_dteend,
                                          v_desresults,sysdate,global_v_coduser,sysdate,global_v_coduser);
                elsif v_flgEdit then
                    update tsuccdev
                       set desdevp = v_desdevp,
                           destarget = v_destarget,
                           dtestr = v_dtestr,
                           dteend = v_dteend,
                           desresults = v_desresults,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codempid = v_codempid
                       and codcomp = b_index_codcomp
                       and codpos = b_index_codpos
                       and coddevp = v_coddevp;
                elsif v_flgDelete then
                    delete tsuccdev
                     where codempid = v_codempid
                       and codcomp = b_index_codcomp
                       and codpos = b_index_codpos
                       and coddevp = v_coddevp;
                end if;
            exception when others then
                param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                rollback;
                exit;
            end;
         end loop;
      elsif v_flg = 'delete' then
          begin
            delete tsuccpln
             where codempid = v_codempid
               and codcomp like  b_index_codcomp||'%'
               and codpos = b_index_codpos
               and dteyear = b_index_year
               and numtime = b_index_numtime;

            delete tsuccmpc
             where codempid = v_codempid
               and codcomp like  b_index_codcomp||'%'
               and codpos = b_index_codpos;

            delete tsucctrn
             where codempid = v_codempid
               and codcomp like  b_index_codcomp||'%'
               and codpos = b_index_codpos;

            delete tsuccdev
             where codempid = v_codempid
               and codcomp like  b_index_codcomp||'%'
               and codpos = b_index_codpos;
            commit;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            rollback;
            exit;
          end;
      end if;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure get_data_codempid(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data_codempid(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_codempid(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_code1         varchar2(3000);
    v_code2         varchar2(3000);
    v_code3         varchar2(3000);
    v_sub_col       varchar2(1) := 'N';
    v_num           number(10) := 0;

    v_cursor        number;
    v_codcomp       varchar2(100);
    v_idx           number := 0;
    v_codcompn      temploy1.codcomp%type;
    v_codposn       temploy1.codpos%type;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(4000 char);
    obj_row_tb1     json_object_t;
    obj_row_tb2     json_object_t;
    obj_tb1         json_object_t;
    obj_tb2         json_object_t;

    cursor c1 is
        select *
          from temploy1
         where codempid = p_codempid_query;
  begin
      obj_data := json_object_t();
      for r1 in c1 loop
        v_flgdata := 'Y';
        v_flgsecu := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgsecu then
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', nvl(get_emp_img(r1.codempid),r1.codempid));
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
            obj_data.put('codpos',r1.codpos);
            obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
            obj_data.put('codcompn', r1.codcomp);
            obj_data.put('desc_codcompn', get_tcenter_name(r1.codcomp,global_v_lang));
            obj_data.put('codposn',r1.codpos);
            obj_data.put('desc_codposn', get_tpostn_name(r1.codpos,global_v_lang));
            obj_data.put('dteeffec',to_char(r1.dteefpos,'dd/mm/yyyy'));
            obj_data.put('coursreq', '<span class="fa fa-pencil text-blue" aria-hidden="true"></span>');
            obj_data.put('flgAdd',true);

            obj_row_tb1     := json_object_t();
            obj_tb1         := json_object_t();
            gen_detail_course(obj_row_tb1);
            obj_tb1.put('rows',obj_row_tb1);
            obj_data.put('table1',obj_tb1);

            obj_row_tb2     := json_object_t();
            obj_tb2         := json_object_t();
            gen_detail_develop(obj_row_tb2);
            obj_tb2.put('rows',obj_row_tb2);
            obj_data.put('table2',obj_tb2);
        end if;
      end loop;

      if v_flgdata = 'N' then
        param_msg_error     := get_error_msg_php('HR2055',global_v_lang,'TPOSEMPD');
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    json_str_output := obj_data.to_clob;
  end;

  procedure get_list_codemp(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_list_codemp(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_list_codemp(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_data_detail json_object_t;
    obj_row_output  json_object_t;
    v_rcnt          number := 0;
    v_flgsecur      boolean;
    v_stmt          varchar2(4000 char);

    v_codempid      temploy1.codempid%type;
    v_codpos        temploy1.codpos%type;
    v_codcomp       temploy1.codcomp%type;
    v_agework       number;
    v_year          number;
    v_month         number;
    v_day           number;
    v_dteempmt      temploy1.dteempmt%type;

    v_condition     ttalent.syncond%type;
    v_syncond       ttalent.syncond%type;
    v_cursor_id     integer;
    v_col           number;
    v_count         number := 0;
    v_chkExist      number := 0;
    v_desctab       dbms_sql.desc_tab;
    v_varchar2      varchar2(4000 char);
    v_fetch         integer;
    obj_row_tb1     json_object_t;
    obj_row_tb2     json_object_t;
    obj_tb1         json_object_t;
    obj_tb2         json_object_t;
    cursor c1 is
      select dteyear,numtime,dteeffec
        from tsuccpln
       where codempid = v_codempid
         and codcomp like b_index_codcomp||'%'
         and codpos = b_index_codpos
         and dteyear = b_index_year
         and numtime = b_index_numtime
       order by codempid;
  begin
    obj_row   := json_object_t();
    obj_data  := json_object_t();
    v_condition := p_stmt;
    if p_typcond = '1' then
        v_stmt := 'select distinct codempid,codcompe,codpose,agework '||
                  'from ttalente '||
                  'where '||v_condition||' '||
                  'and exists (select b.codempid '||
                              'from temploy1 b, temploy2 c '||
                              'where ttalente.codempid = b.codempid '||
                              'and   b.codempid = c.codempid '||
                              'and   b.staemp  in (''1'',''3'') ) '||
                  'order by codempid ';
    elsif p_typcond = 'N' then
        v_stmt := 'select distinct V_RP_EMP.codempid,codcomp,codpos,agework '||
                  'from V_RP_EMP, temploy2 b '||
                  'where staemp  in (''1'',''3'') '||
                  'and '||v_condition||' '||
                  'and   V_RP_EMP.codempid = b.codempid '||
                  'order by V_RP_EMP.codempid ';
    else
        v_stmt := 'select distinct codempid,codcomp,codpos,agework '||
                  'from tnineboxe '||
                  'where '||v_condition||' '||
                  'and staappr = ''Y'' '||
                  'and dteyear = (select max(dteyear) '||
                                 'from tnineboxe '||
                                 'where '||v_condition||' '||' ) '||
                  'and exists (select b.codempid '||
                              'from temploy1 b, temploy2 c '||
                              'where tnineboxe.codempid = b.codempid '||
                              'and   b.codempid = c.codempid '||
                              'and   b.staemp  in (''1'',''3'') ) '||
                  'order by codempid ';
    end if;

    begin
      v_cursor_id  := dbms_sql.open_cursor;
      dbms_sql.parse(v_cursor_id,v_stmt,dbms_sql.native);
      dbms_sql.define_column(v_cursor_id, 1, v_codempid, 100);
      dbms_sql.define_column(v_cursor_id, 2, v_codcomp, 100);
      dbms_sql.define_column(v_cursor_id, 3, v_codpos, 100);
      dbms_sql.define_column(v_cursor_id, 4, v_agework);

      v_fetch := dbms_sql.execute(v_cursor_id);
      while dbms_sql.fetch_rows(v_cursor_id) > 0 loop
        dbms_sql.column_value(v_cursor_id, 1, v_codempid);
        dbms_sql.column_value(v_cursor_id, 2, v_codcomp);
        dbms_sql.column_value(v_cursor_id, 3, v_codpos);
        dbms_sql.column_value(v_cursor_id, 4, v_agework);

        v_flgsecur   := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
        if v_flgsecur then
          obj_data  := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('image', nvl(get_emp_img(v_codempid),v_codempid));
          obj_data.put('codempid',v_codempid);
          obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang));
          obj_data.put('codcomp', v_codcomp);
          obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
          obj_data.put('codpos', v_codpos);
          obj_data.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
          obj_data.put('codcompn', v_codcomp);
          obj_data.put('desc_codcompn', get_tcenter_name(v_codcomp, global_v_lang));
          obj_data.put('codposn', v_codpos);
          obj_data.put('desc_codposn', get_tpostn_name(v_codpos, global_v_lang));
          obj_data.put('agework', floor(v_agework/12)||'('|| mod(v_agework,12) ||')');

          for r1 in c1 loop
              obj_data.put('yeartime', hcm_util.get_year_buddhist_era(r1.dteyear)||'/'||r1.numtime);
              obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
          end loop;
          obj_data.put('numseq', '');
          obj_data.put('stasuccr', '');
          obj_data.put('flgAdd', true);
          obj_data.put('coursreq', '<span class="fa fa-pencil text-blue" aria-hidden="true"></span>');
          p_codempid_query := v_codempid;
          obj_row_tb1     := json_object_t();
          obj_tb1         := json_object_t();
          gen_detail_course(obj_row_tb1);
          obj_tb1.put('rows',obj_row_tb1);
          obj_data.put('table1',obj_tb1);

          obj_row_tb2     := json_object_t();
          obj_tb2         := json_object_t();
          gen_detail_develop(obj_row_tb2);
          obj_tb2.put('rows',obj_row_tb2);
          obj_data.put('table2',obj_tb2);

          obj_row.put(to_char(v_count),obj_data);
          v_count := v_count + 1;
        end if;
      end loop;
      dbms_sql.close_cursor(v_cursor_id);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      if dbms_sql.is_open(v_cursor_id) then
        dbms_sql.close_cursor(v_cursor_id);
      end if;
    end;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_course(json_str_input in clob,json_str_output out clob) is
  json_output json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail_course(json_output);
      json_str_output := json_output.to_clob;
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_course(json_output out json_object_t) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_numseq        number := 0;
    v_secur         boolean := true;
    v_chk_data      varchar2(1) := 'N';
    v_chk_secur     varchar2(1) := 'N';
    v_check         varchar2(50);
    v_approvno      tbudget.approvno%type;
    v_flg_found     varchar2(1) := 'N';
    v_grade_current     tcmptncy.grade%type;
    v_codskill          tcomptcr.codskill%type;
    v_dtestr            date;
    v_dteend            date;
    v_dtetrst           date;
    v_flgAdd            boolean;
    v_flg               varchar2(10 char);
    v_grade_expect      tjobposskil.grade%type;
    v_item2     ttemprpt.item2%type;
    v_item3     ttemprpt.item3%type;
    v_item4     ttemprpt.item4%type;
    v_item5     ttemprpt.item5%type;
    v_item6     ttemprpt.item6%type;
    cursor c_tjobposskil is
      select *
        from tjobposskil
       where codcomp    like b_index_codcomp||'%'
         and codpos     = b_index_codpos
      order by codskill;

    cursor c_tcomptcr is
      select *
        from tcomptcr
       where codskill = v_codskill
         and grade > v_grade_current
         and grade <= v_grade_expect
      order by codcours;

    cursor c_tab1 is
      select distinct item1
        from ttemprpt
       where codempid = global_v_codempid
         and codapp = 'HRRP4CE';
  begin
    begin
      delete from ttemprpt
      where codempid = global_v_codempid
      and codapp = 'HRRP4CE';
    end;
    obj_row   := json_object_t();
    for r1 in c_tjobposskil loop

        v_codskill  := r1.codskill;
        v_grade_expect := r1.grade;
        begin
            select nvl(grade,0)
              into v_grade_current
              from tcmptncy
             where codtency = r1.codskill
               and codempid = p_codempid_query;
        exception when others then
            v_grade_current := 0;
        end;
        for r2 in c_tcomptcr loop
            begin
                select dtestr,dteend,dtetrst
                  into v_dtestr,v_dteend,v_dtetrst
                  from tsucctrn
                 where codempid = p_codempid_query
                   --and codcomp like b_index_codcomp||'%' -- #7117 || 01/06/2022
                   and codcomp = b_index_codcomp
                   and codpos = b_index_codpos
                   and codcours = r2.codcours;

                v_flgAdd := false;
                v_flg := 'N';
            exception when no_data_found then
                v_dtestr := null;
                v_dteend := null;
                v_dtetrst := null;
                v_flgAdd := true;
                v_flg := 'Y';
            end;

            if  v_flg = 'N' then      -- #7117 || 01/06/2022
                v_numseq := v_numseq +1;
                begin
                  insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6)
                  values (global_v_codempid, 'HRRP4CE', v_numseq, r2.codcours, r2.codcours||v_grade_current,
                          to_char(v_dtestr,'dd/mm/yyyy'), to_char(v_dteend,'dd/mm/yyyy'), to_char(v_dtetrst,'dd/mm/yyyy'), v_flg);

                end;
            end if;  -- #7117 || 01/06/2022

        end loop;
    end loop;

    for r3 in c_tab1 loop
      begin
        select item2,item3,item4,item5,item6
        into v_item2,v_item3,v_item4,v_item5,v_item6
        from ttemprpt
        where codempid = global_v_codempid
        and codapp = 'HRRP4CE'
        and item1 = r3.item1
        and rownum = 1;
      end;
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('numseq', v_rcnt + 1);
      obj_data.put('codcours',r3.item1);
      obj_data.put('desc_codcours',v_item2);
      obj_data.put('dtetargst',nvl(v_item3,''));
      obj_data.put('dtetargen',nvl(v_item4,''));
      obj_data.put('dtetrin',nvl(v_item5,''));
      if v_item6 = 'Y' then
        obj_data.put('flgAdd',true);
      else
        obj_data.put('flgAdd',false);
      end if;
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt      := v_rcnt + 1;
    end loop;
    json_output   := obj_row;
  end;
  --

  procedure get_detail_develop(json_str_input in clob,json_str_output out clob) is
  json_output json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail_develop(json_output);
      json_str_output := json_output.to_clob;
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure gen_detail_develop(json_output out json_object_t) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_numseq        number := 0;
    v_secur         boolean := true;
    v_chk_data      varchar2(1) := 'N';
    v_chk_secur     varchar2(1) := 'N';
    v_check         varchar2(50);
    v_approvno      tbudget.approvno%type;
    v_flg_found     varchar2(1) := 'N';
    v_flg           varchar2(1) := 'N';
    v_grade_current     tcmptncy.grade%type;
    v_codskill          tcomptcr.codskill%type;
    v_dtestr            date;
    v_dteend            date;
    v_dtetrst           date;
    v_flgAdd            boolean;
    v_grade_expect      tjobposskil.grade%type;
    v_destarget         tsuccdev.destarget%type;
    v_desresults        tsuccdev.desresults%type;

    v_item2     ttemprpt.item2%type;
    v_item3     ttemprpt.item3%type;
    v_item4     ttemprpt.item4%type;
    v_item5     ttemprpt.item5%type;
    v_item6     ttemprpt.item6%type;
    v_item7     ttemprpt.item7%type;
    v_item8     ttemprpt.item8%type;
    cursor c_tjobposskil is
      select *
        from tjobposskil
       where codcomp    like b_index_codcomp||'%'
         and codpos     = b_index_codpos
      order by codskill;

    cursor c_tcomptdev is
      select *
        from tcomptdev
       where codskill = v_codskill
         and grade > v_grade_current
         and grade <= v_grade_expect
      order by coddevp;

    cursor c_tab2 is
      select distinct item1
        from ttemprpt
       where codempid = global_v_codempid
         and codapp = 'HRRP4CE2';
  begin
    begin
      delete from ttemprpt
      where codempid = global_v_codempid
      and codapp = 'HRRP4CE2';
    end;
    obj_row   := json_object_t();
    for r1 in c_tjobposskil loop
        v_codskill          := r1.codskill;
        v_grade_expect      := r1.grade;
        begin
            select nvl(grade,0)
              into v_grade_current
              from tcmptncy
             where codtency = r1.codskill
               and codempid = p_codempid_query;
        exception when others then
            v_grade_current := 0;
        end;
        for r2 in c_tcomptdev loop
            begin
                select destarget,dtestr,dteend,desresults
                  into v_destarget,v_dtestr,v_dteend,v_desresults
                  from tsuccdev
                 where codempid = p_codempid_query
                   and codcomp like b_index_codcomp||'%'
                   and codpos = b_index_codpos
                   and coddevp = r2.coddevp;
                v_flgAdd := false;
                v_flg := 'N';
            exception when no_data_found then
                v_destarget     := null;
                v_desresults    := null;
                v_dtestr        := null;
                v_dteend        := null;
                v_flgAdd        := true;
                v_flg           := 'Y';
            end;
            v_numseq := v_numseq +1;

            begin
              insert into ttemprpt (codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8)
              values (global_v_codempid, 'HRRP4CE2', v_numseq, r2.coddevp, r2.coddevp, r2.desdevp, v_destarget,
              to_char(v_dtestr,'dd/mm/yyyy'), to_char(v_dteend,'dd/mm/yyyy'), v_desresults, v_flg);
            end;
        end loop;
    end loop;
    for r3 in c_tab2 loop

      begin
        select item2,item3,item4,item5,item6,item7,item8
        into v_item2,v_item3,v_item4,v_item5,v_item6,v_item7,v_item8
        from ttemprpt
        where codempid = global_v_codempid
        and codapp = 'HRRP4CE2'
        and item1 = r3.item1
        and rownum = 1;
      end;
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('numseq',v_rcnt + 1);
      obj_data.put('coddevp',r3.item1);
      obj_data.put('desc_coddevp',v_item2);
      obj_data.put('desdevp',v_item3);
      obj_data.put('destarget',nvl(v_item4,''));
      obj_data.put('dtestr',nvl(v_item5,''));
      obj_data.put('dteend',nvl(v_item6,''));
      obj_data.put('desresults',nvl(v_item7,''));
      if v_item8 = 'Y' then
        obj_data.put('flgAdd',true);
      else
        obj_data.put('flgAdd',false);
      end if;
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt      := v_rcnt + 1;
    end loop;
    json_output   := obj_row;
  end;
  --

  procedure send_email(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      process_send_email(json_str_input, json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure process_send_email(json_str_input in clob,json_str_output out clob) is
    json_input              json_object_t;
    param_json              json_object_t;
    param_json_row          json_object_t;
    param_aporg             json_object_t;
    param_aporg_row         json_object_t;

    v_dteyrbug              number;
    v_codcomp               tbudget.codcomp%type;
    v_codpos                tbudget.codpos%type;

    v_codempid              tsuccpln.codempid%type;
    v_flg                   varchar2(50);
    v_stasuccr              tsuccpln.stasuccr%type;
    v_remarkap              tsuccpln.remarkap%type;
    v_dteeffec              tsuccpln.dteeffec%type;
    v_numseq                tsuccpln.numseq%type;
    v_rowid                 rowid;
    v_msg_to                clob;
	v_templete_to           clob;
    v_error			        terrorm.errorno%type;
  begin
    json_input          := json_object_t(json_str_input);
    param_json          := hcm_util.get_json_t(json_input,'param_json');

    for i in 0..(param_json.get_size - 1) loop

      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_codempid        := hcm_util.get_string_t(param_json_row,'codempid');
      v_numseq          := to_number(hcm_util.get_string_t(param_json_row,'numseq'));
        select rowid
          into v_rowid
          from tsuccpln
         where codcomp like b_index_codcomp || '%'
           and codpos = b_index_codpos
           and dteyear = b_index_year
           and numtime = b_index_numtime
           and numseq = v_numseq
           and codempid = v_codempid;

        begin
            chk_flowmail.get_message_result('HRRP4CE', global_v_lang, v_msg_to, v_templete_to);
            chk_flowmail.replace_text_frmmail(v_templete_to, 'TSUCCPLN', v_rowid,  get_label_name('HRRP4CE1', global_v_lang, 200), 'HRRP4CE', '1', null, global_v_coduser, global_v_lang, v_msg_to);
            v_error := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL,  get_label_name('HRRP4CE1', global_v_lang, 200), 'U', global_v_lang, null);
        exception when others then
          param_msg_error_mail := get_error_msg_php('HR7522',global_v_lang);
        end;
        if param_msg_error_mail is not null then
            json_str_output := get_response_message(null, param_msg_error_mail, global_v_lang);
            return;
        end if;
        if v_error not in  ('2402','2046') then
            param_msg_error := get_error_msg_php('HR'||v_error, global_v_lang);
            json_str_output := get_response_message(NULL, param_msg_error, global_v_lang);
            return;
        end if;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2046',global_v_lang);
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  end;
end;

/

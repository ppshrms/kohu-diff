--------------------------------------------------------
--  DDL for Package Body HRTR6DX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR6DX" is
-- last update: 19/01/2021 16:00
 procedure initial_value(json_str_input in clob) as
    json_obj json;
  begin
    json_obj            := json(json_str_input);
    global_v_coduser    := json_ext.get_string(json_obj,'p_coduser');
    global_v_lang       := json_ext.get_string(json_obj,'p_lang');

    p_year              := hcm_util.get_string(json_obj,'p_year');
    p_codcomp           := hcm_util.get_string(json_obj,'p_codcomp');
    p_codcours          := hcm_util.get_string(json_obj,'p_codcours');
    p_numclseq          := hcm_util.get_string(json_obj,'p_numclseq');
    p_codempid          := hcm_util.get_string(json_obj,'p_codempid');

end initial_value;
----------------------------------------------------------------------------------------
procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
  if param_msg_error is null then
    gen_index(json_str_output);
  else
    json_str_output := get_response_message(400,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_index;
----------------------------------------------------------------------------------------
procedure check_index as
    v_flgsecu                  boolean := false;
    v_count_codcomp            number := 0;
    v_count_codcours           number := 0;
  begin
    if p_codcomp is not null then
        select count(*)
        into   v_count_codcomp
        from tcenter t
        where upper(t.codcomp) like upper(p_codcomp)||'%';

        if v_count_codcomp = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
           return;
        end if ;
        v_flgsecu := secur_main.secur7(p_codcomp,global_v_coduser);
        if not v_flgsecu then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codcomp');
          return;
        end if;
    end if;
    if p_codcours is not null then
        select count(*)
        into   v_count_codcours
        from tcourse t
        where t.codcours = p_codcours;

        if v_count_codcours = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOURSE');
           return;
        end if ;
    end if;
end check_index;
----------------------------------------------------------------------------------------
procedure gen_index(json_str_output out clob) as
    obj_data                          json;
    obj_row                           json;
    v_rcnt                            number := 0;

    cursor c_thistrnn is
           select a.codempid, a.dteyear, a.codcours, a.numclseq ,a.codcomp, a.dtetrst, a.dtetren,
                  get_temploy_name(a.codempid, global_v_lang) as desc_codempid,
                  get_tcenter_name(a.codcomp, global_v_lang) as desc_codcomp,
                  get_tpostn_name(b.codpos, global_v_lang) as desc_codpos,
              b.codpos, c.qtyprescr, c.qtyposscr, c.codeval, c.dteeval, c.flgeval,
              a.rowid,
              get_tcourse_name(a.codcours,global_v_lang) as desc_codcours,
              get_temploy_name(c.codeval, global_v_lang) as desc_codeval
           from thistrnn a, temploy1 b, ttrimph c
           where a.dteyear = p_year
             and a.numclseq = p_numclseq
             and upper(a.codcours) = upper(p_codcours)
             and a.codcomp like upper(p_codcomp)||'%'
             and a.codempid = b.codempid
             and c.codempid = a.codempid
             and c.dteyear = a.dteyear
             and c.codcours = a.codcours
             and c.numclseq = a.numclseq
            order by a.dteyear, a.codcomp, a.codempid, a.numclseq;

  begin
    obj_row     := json();
    v_rcnt              := 0;
    for r_thistrnn in c_thistrnn loop
          v_rcnt      := v_rcnt+1;
          obj_data    := json();
          obj_data.put('coderror', '200');
          obj_data.put('image', get_emp_img(r_thistrnn.codempid));
          obj_data.put('codempid', r_thistrnn.codempid);
          obj_data.put('desc_codempid', r_thistrnn.desc_codempid);
          obj_data.put('desc_codcomp', r_thistrnn.desc_codcomp);
          obj_data.put('codpos', r_thistrnn.codpos);
          obj_data.put('desc_codpos', r_thistrnn.desc_codpos);
          obj_data.put('qtyprescr', r_thistrnn.qtyprescr);
          obj_data.put('qtyposscr', r_thistrnn.qtyposscr);
          obj_data.put('flgeval', r_thistrnn.flgeval);
          obj_data.put('codeval', r_thistrnn.codeval);
          obj_data.put('dteeval', to_char(r_thistrnn.dteeval, 'dd/mm/yyyy'));
          obj_data.put('dtetrst', to_char(r_thistrnn.dtetrst, 'dd/mm/yyyy'));
          obj_data.put('dtetren', to_char(r_thistrnn.dtetren, 'dd/mm/yyyy'));
          obj_data.put('year', r_thistrnn.dteyear);
          obj_data.put('codcours', r_thistrnn.codcours);
          obj_data.put('numclseq', r_thistrnn.numclseq);
          obj_data.put('desc_codeval', r_thistrnn.desc_codeval);
          obj_data.put('desc_flgeval', get_tlistval_name('FLGEVAL',r_thistrnn.flgeval,global_v_lang));

          obj_data.put('desc_codcours', r_thistrnn.desc_codcours);
          obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);

    if v_rcnt = 0 then
      param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'THISTRNN');
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    end if;

exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_index;
----------------------------------------------------------------------------------------
procedure get_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
  if param_msg_error is null then
    gen_detail(json_str_output);
  else
    json_str_output := get_response_message(400,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_detail;
----------------------------------------------------------------------------------------
procedure gen_detail(json_str_output out clob) as
    obj_data                          json;
    obj_row                           json;
    v_rcnt                            number := 0;

    cursor c_thistrnn is
            select a.codform,
                   get_tintview_name(a.codform,global_v_lang) as desc_codform,
                   get_tlistval_name('FLGEVAL',a.flgeval,global_v_lang) as desc_flgeval,
                   b.numitem,
                   get_tintvewd_name(a.codform,1,b.numitem,global_v_lang) as descommt,
                   b.qtyprescr, b.qtyposscr,
                   case
                      when b.qtyprescr > b.qtyposscr then 'D'
                      when b.qtyprescr < b.qtyposscr then 'I'
                      when b.qtyprescr = b.qtyposscr then 'U'
                   end as flgeval
            from ttrimph a, ttrimpi b
            where a.codempid = b.codempid
                  and a.dteyear = b.dteyear
                  and a.codcours = b.codcours
                  and a.numclseq = b.numclseq
                  and a.codempid = p_codempid
                  and a.dteyear = p_year
                  and upper(a.codcours) = upper(p_codcours)
                  and a.numclseq = p_numclseq;

  begin
    obj_row     := json();
    v_rcnt              := 0;
    for r_thistrnn in c_thistrnn loop
          v_rcnt      := v_rcnt+1;
          obj_data    := json();
          obj_data.put('coderror', '200');
          obj_data.put('codform', r_thistrnn.codform);
          obj_data.put('desc_codform', r_thistrnn.desc_codform);
          obj_data.put('desc_flgeval', r_thistrnn.desc_flgeval);
          obj_data.put('numitem', r_thistrnn.numitem);
          obj_data.put('descommt', r_thistrnn.descommt);
          obj_data.put('qtyprescr', r_thistrnn.qtyprescr);
          obj_data.put('qtyposscr', r_thistrnn.qtyposscr);
          obj_data.put('flgeval', get_tlistval_name('FLGEVAL',r_thistrnn.flgeval,global_v_lang));
          obj_row.put(to_char(v_rcnt-1),obj_data);

          if isInsertReport then
            insert_ttemprpt_sub(obj_data);
          end if;

    end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);

exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_detail;
----------------------------------------------------------------------------------------
procedure initial_report(json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
    p_codapp            := hcm_util.get_string(json_obj,'p_codapp');

    begin
      json_select_arr   := json(json_obj.get('p_params_select'));
      if json_select_arr.count = 0 then
        json_select_arr := null;
      end if;
    exception when others then
      null;
    end;
  end initial_report;
----------------------------------------------------------------------------------------
procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output                     clob;
    p_select_arr                    json;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..json_select_arr.count-1 loop
        p_select_arr        := hcm_util.get_json(json_select_arr, to_char(i));
        p_codempid          := hcm_util.get_string(p_select_arr, 'codempid');
        p_year              := hcm_util.get_string(p_select_arr, 'year');
        p_codcours          := hcm_util.get_string(p_select_arr, 'codcours');
        p_numclseq          := hcm_util.get_string(p_select_arr, 'numclseq');
        p_desc_codempid     := hcm_util.get_string(p_select_arr, 'desc_codempid');
        p_desc_codpos       := hcm_util.get_string(p_select_arr, 'desc_codpos');
        p_desc_codcours     := hcm_util.get_string(p_select_arr, 'desc_codcours');
        p_dtetrst           := to_date(json_ext.get_string(p_select_arr,'dtetrst'),'dd/mm/yyyy');
        p_dtetren           := to_date(json_ext.get_string(p_select_arr,'dtetren'),'dd/mm/yyyy');

        insert_ttemprpt_main;
        gen_detail(json_output);
      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;
----------------------------------------------------------------------------------------
procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and upper(codapp) like upper(p_codapp) || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;
----------------------------------------------------------------------------------------
procedure insert_ttemprpt_main is
    v_numseq            number := 0;
    v_seq               number := 1;
    v_desc_codform      varchar2(1000 char);
    v_desc_flgeval      varchar2(1000 char);
    v_flg_img           varchar2(1 char) := 'N';
    v_emp_image         varchar2(1000 char);
    v_qtyprescr         number := 1;
    v_qtyposscr         number := 1;
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and upper(codapp)   = upper(p_codapp)||'_MAIN';
    exception when no_data_found then
      null;
    end;

    begin
      select nvl(max(item1), 0)
        into v_seq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = upper(p_codapp)||'_MAIN'
         and item2 = p_codempid
         and item3 = p_codcours
         and item4 = p_year
         and item5 = p_numclseq;
    exception when no_data_found then
      null;
    end;

    begin
      select get_tintview_name(c.codform,global_v_lang), get_tlistval_name('FLGEVAL',c.flgeval,global_v_lang),
             c.qtyprescr, c.qtyposscr
        into v_desc_codform, v_desc_flgeval, v_qtyprescr, v_qtyposscr
        from ttrimph c
       where c.codempid = p_codempid
             and c.dteyear = p_year
             and upper(c.codcours) = upper(p_codcours)
             and c.numclseq = p_numclseq;
    exception when no_data_found then
      null;
    end;

    v_emp_image                   := get_emp_img(p_codempid);
    if v_emp_image <> p_codempid then
      v_emp_image   := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_emp_image;
      v_flg_img     := 'Y';
    end if;

    v_numseq                    := v_numseq + 1;
    v_seq                       := v_seq + 1;

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5,
             item6, item7, item8, item9, item10,
             item11, item12, item13, item14, item15, item16
           )
      values
           (
             global_v_codempid, upper(p_codapp)||'_MAIN', v_numseq,
             v_seq, p_codempid, p_codcours, p_year, p_numclseq,
             p_desc_codempid, p_desc_codpos, p_desc_codcours, to_char(p_dtetrst, 'dd/mm/yyyy'), to_char(p_dtetren, 'dd/mm/yyyy'),
             v_desc_codform, v_desc_flgeval, v_emp_image, v_flg_img ,v_qtyprescr, v_qtyposscr
           );
    exception when others then
      null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_main;
----------------------------------------------------------------------------------------
procedure insert_ttemprpt_sub(obj_data in json) is
    v_numseq              number := 0;
    v_seq                 number := 1;
    v_descommt            varchar2(1000 char);
    v_qtyprescr           ttrimpi.qtyprescr%type;
    v_qtyposscr           ttrimpi.qtyposscr%type;
    v_flgeval             varchar2(1000 char);
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and upper(codapp)   = upper(p_codapp)||'_SUB';
    exception when no_data_found then
      null;
    end;

    begin
      select nvl(max(item1), 0)
        into v_seq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = upper(p_codapp)||'_SUB'
         and item2 = p_codempid
         and item3 = p_codcours
         and item4 = p_year
         and item5 = p_numclseq;
    exception when no_data_found then
      null;
    end;
    v_numseq               := v_numseq + 1;
    v_seq                  := v_seq + 1;
    v_descommt             := hcm_util.get_string(obj_data, 'descommt');
    v_qtyprescr            := hcm_util.get_string(obj_data, 'qtyprescr');
    v_qtyposscr            := hcm_util.get_string(obj_data, 'qtyposscr');
    v_flgeval              := hcm_util.get_string(obj_data, 'flgeval');

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5,
             item6, item7, item8, item9
           )
      values
           (
             global_v_codempid, upper(p_codapp)||'_SUB', v_numseq, v_seq,
             p_codempid,
             p_codcours,
             p_year,
             p_numclseq,
             v_descommt,
             v_qtyprescr,
             v_qtyposscr,
             v_flgeval
           );
    exception when others then
      null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_sub;
----------------------------------------------------------------------------------------

end HRTR6DX;

/

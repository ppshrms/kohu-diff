--------------------------------------------------------
--  DDL for Package Body HRTR6CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR6CE" is
-- last update: 14/02/2021 20:00
 procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj                           := json_object_t(json_str_input);

    global_v_coduser       := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang          := hcm_util.get_string_t(json_obj,'p_lang');

    p_year                 := hcm_util.get_string_t(json_obj,'p_year');
    p_codcomp              := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codcours             := hcm_util.get_string_t(json_obj,'p_codcours');
    p_numclseq             := hcm_util.get_string_t(json_obj,'p_numclseq');
    p_codempid             := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codpos               := hcm_util.get_string_t(json_obj,'p_codpos');
    p_codeval              := hcm_util.get_string_t(json_obj,'p_codeval');
    p_new_docform          := hcm_util.get_string_t(json_obj,'p_new_docform');
    p_codform              := hcm_util.get_string_t(json_obj,'p_codform');
    json_params            := hcm_util.get_json_t(json_obj, 'params');
    p_save_codempid        := hcm_util.get_string_t(json_obj,'p_save_codempid');
    p_save_year            := hcm_util.get_string_t(json_obj,'p_save_year');
    p_save_numclseq        := hcm_util.get_string_t(json_obj,'p_save_numclseq');
    p_save_codcours        := hcm_util.get_string_t(json_obj,'p_save_codcours');
    p_save_codeval         := hcm_util.get_string_t(json_obj,'p_save_codeval');
    p_save_dteeval         := to_date(hcm_util.get_string_t(json_obj,'p_save_dteeval'),'dd/mm/yyyy');
    p_save_codform         := hcm_util.get_string_t(json_obj,'p_save_codform');
    p_save_flgperform      := hcm_util.get_string_t(json_obj,'p_save_flgperform');
    p_save_comment_sugges  := hcm_util.get_string_t(json_obj,'p_save_comment_sugges');
    save_table_form_obj      := hcm_util.get_json_t(json_obj, 'p_save_table_form');
    save_ttrimpi_obj         := hcm_util.get_json_t(json_obj, 'p_save_table_form');
    save_thistrnp_obj        := hcm_util.get_json_t(json_obj, 'p_save_table2');
    save_ttrimps_obj         := hcm_util.get_json_t(json_obj, 'p_save_table3');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
----------------------------------------------------------------------------------------
  procedure get_index_table(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
  if param_msg_error is null then
    gen_index_table(json_str_output);
    return;
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end ;
----------------------------------------------------------------------------------------
  procedure check_index as
    v_count_codcomp     number;
    v_flgsecu           boolean := false;
    v_flgsecu2          boolean := false;
    v_count_codempid    number;
    v_count_codpos      number;
    v_count_codeval     number;
  begin
    if p_year is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_codcomp is null and p_codempid is null and p_codpos is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_codcours is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_numclseq is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_codcomp is not null then
        select count(t.codcomp)
        into   v_count_codcomp
        from tcenter t
        where upper(t.codcomp) like upper(p_codcomp)||'%';

        if v_count_codcomp = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
           return;
        end if ;
        v_flgsecu2 := secur_main.secur7(p_codcomp,global_v_coduser);
        if not v_flgsecu2 then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codcomp');
          return;
        end if;
    end if;
    if p_codempid is not null then
        select count(t.codempid)
        into   v_count_codempid
        from temploy1 t
        where upper(t.codempid) = upper(p_codempid);

        if v_count_codempid = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
           return;
        end if ;
        v_flgsecu := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        if not v_flgsecu  then
           param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        end if;
    end if;
    if p_codpos is not null then
        select count(t.codpos)
        into   v_count_codpos
        from tpostn t
        where upper(t.codpos) = upper(p_codpos);

        if v_count_codpos = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
           return;
        end if ;
    end if;
    if p_codeval is not null then
        select count(t.codempid)
        into   v_count_codeval
        from temploy1 t
        where upper(t.codempid) = upper(p_codeval);

        if v_count_codeval = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
           return;
        end if ;
    end if;
  end check_index;
----------------------------------------------------------------------------------------
  procedure gen_index_table(json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;
    v_data      number := 0;

    cursor cl_index is
      select a.codempid,a.codcomp,a.codcours,a.numclseq,a.codtparg,a.dtetrst,
      a.dtetren,b.codeval,b.dteeval,b.flgeval,a.dteyear, b.codform,
      (select c.codpos from temploy1 c where c.codempid = a.codempid) as codpos
      from thistrnn a
      left join ttrimph b on a.codempid = b.codempid and a.dteyear = b.dteyear and a.codcours = b.codcours and a.numclseq = b.numclseq
      where a.codcomp  like nvl(p_codcomp||'%',a.codcomp)
          and a.codempid = nvl(p_codempid,a.codempid)
          and a.dteyear = p_year
          and upper(a.codcours) = upper(p_codcours)
          and a.numclseq = p_numclseq
          and a.dtetrflw is not null
          and ( (p_codeval is null) or
                (p_codeval is not null and exists ( select b.codeval
                                                    from ttrimph b
                                                    where b.codempid = a.codempid
                                                      and b.dteyear = a.dteyear
                                                      and b.codcours= a.codcours
                                                      and b.numclseq = a.numclseq
                                                      and b.codeval = p_codeval )
                ) )
    order by a.codempid;

  begin
    obj_row     := json_object_t();
    for cl in cl_index loop
      v_data := v_data + 1;
      if secur_main.secur2(cl.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', cl.codempid);
        obj_data.put('image', get_emp_img (cl.codempid));
        obj_data.put('desc_codempid', get_temploy_name(cl.codempid,global_v_lang));
        obj_data.put('codcomp', cl.codcomp);
        obj_data.put('codcours', cl.codcours);
        obj_data.put('desc_codcours', get_tcourse_name(cl.codcours,global_v_lang));
        obj_data.put('numclseq', cl.numclseq);
        obj_data.put('codtparg', cl.codtparg);
        obj_data.put('codempid', cl.codempid);
        obj_data.put('dtestrt', to_char(cl.dtetrst, 'dd/mm/yyyy'));
        obj_data.put('dteend', to_char(cl.dtetren, 'dd/mm/yyyy'));
        obj_data.put('desc_codeval', nvl(get_temploy_name(cl.codeval,global_v_lang),''));
        obj_data.put('dteeval', to_char(cl.dteeval, 'dd/mm/yyyy'));
        obj_data.put('assmt', get_tlistval_name('FLGEVAL',cl.flgeval,global_v_lang));
        obj_data.put('dteyear', cl.dteyear);
        obj_data.put('codeval', cl.codeval);
        obj_data.put('codform', cl.codform);
        obj_data.put('codpos', cl.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(cl.codpos,global_v_lang));
        obj_data.put('desc_codtparg', get_tlistval_name('TCODTPARG',cl.codtparg,global_v_lang));
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
    if v_data = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thistrnn');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    elsif v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_index_table;

   procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
  if param_msg_error is null then
    gen_index(json_str_output);
    return;
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    obj_data    json_object_t;
    v_codpos  temploy1.codpos%type;
  begin
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    if p_codeval is not null then
      begin
        select  codpos into v_codpos
        from temploy1
        where codempid = p_codeval;
      exception when no_data_found then
        v_codpos := null;
      end;
    end if;

    if v_codpos is not null then
      obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
    else
      obj_data.put('desc_codpos', '');
    end if;
    json_str_output := obj_data.to_clob();
  end;

----------------------------------------------------------------------------------------
procedure get_detail_form(json_str_input in clob,json_str_output out clob) as
  v_codform    ttrimph.codform%type;
  begin
  initial_value(json_str_input);
  if param_msg_error is null then
    v_codform    := get_codform_ttrimph(p_codempid,p_year,p_codcours,p_numclseq);
    if v_codform = p_codform then
      gen_detail_form1(json_str_output);
      return;
    else
      gen_detail_form2(json_str_output);
      return;
    end if;
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_detail_form;
----------------------------------------------------------------------------------------
function get_codform_ttrimph(p_codempid in varchar2,p_year in varchar2,p_codcours in varchar2,p_numclseq in varchar2) return varchar2 IS
    v_codform    ttrimph.codform%type;
   begin
    begin
      select a.codform
      into v_codform
      from ttrimph a
      where a.codempid = p_codempid
          and a.dteyear = p_year
          and a.codcours = p_codcours
          and a.numclseq = p_numclseq;

      exception when no_data_found then
          null;
      end;
  return  v_codform ;
END;
--------------------------------------------------------------------------
procedure gen_detail_form2(json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;

    cursor cs is
      select t2.numitem,t2.qtyfscor, t2.qtyfscor as qtyprescr, t2.qtyfscor as qtyposscr, 'U' as flgeval,
             decode(global_v_lang,'101', t2.desiteme,
                                  '102', t2.desitemt,
                                  '103', t2.desitem3,
                                  '104', t2.desitem4,
                                  '105', t2.desitem5,
                                  t2.desiteme) as desc_numitem
      from tintvewd t2
      where t2.codform = p_codform
      and   t2.numgrup = 1;
  begin
    obj_row     := json_object_t();
    for cl in cs loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');

      obj_data.put('numitem', cl.numitem);
      obj_data.put('desc_numitem', cl.desc_numitem);
      obj_data.put('qtyfscor', cl.qtyfscor);
      obj_data.put('beftrn', cl.qtyprescr);
      obj_data.put('afttrn', cl.qtyposscr);
      obj_data.put('assmt', get_tlistval_name('FLGEVAL',cl.flgeval,global_v_lang));

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TINTVEWD');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_detail_form2;
----------------------------------------------------------------------------------------
procedure gen_detail_form1(json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;

    cursor cs is
    select b.numitem, b.qtyfscor, b.qtyprescr,b.qtyposscr,
           case
              when b.qtyprescr > b.qtyposscr then 'D'
              when b.qtyprescr < b.qtyposscr then 'I'
              when b.qtyprescr = b.qtyposscr then 'U'
            end as flgeval,
           (select decode(global_v_lang, '101', c.desiteme,
                            '102', c.desitemt,
                            '103', c.desitem3,
                            '104', c.desitem4,
                            '105', c.desitem5,
                            c.desiteme)
           from tintvewd c
           where c.codform = a.codform and c.numitem = b.numitem and c.numgrup = '1') as desc_numitem
    from ttrimph a, ttrimpi b
    where b.codempid = p_codempid
          and b.dteyear = p_year
          and b.codcours = p_codcours
          and b.numclseq = p_numclseq
          and a.codform = a.codform
          and b.codempid = a.codempid
          and b.dteyear = a.dteyear
          and b.codcours = a.codcours
          and b.numclseq = a.numclseq;
  begin
    obj_row     := json_object_t();
    for cl in cs loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numitem', cl.numitem);
        obj_data.put('desc_numitem', cl.desc_numitem);
        obj_data.put('qtyfscor', cl.qtyfscor);
        obj_data.put('beftrn', cl.qtyprescr);
        obj_data.put('afttrn', cl.qtyposscr);
        obj_data.put('assmt', get_tlistval_name('FLGEVAL',cl.flgeval,global_v_lang));
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_detail_form1;
----------------------------------------------------------------------------------------
procedure get_detail_plan(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
  if param_msg_error is null then
    gen_detail_plan(json_str_output);
    return;
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_detail_plan;
----------------------------------------------------------------------------------------
procedure gen_detail_plan(json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;

    cursor cs is
    select t.codempid, t.dteyear, t.codcours, t.numclseq, t.numseq, t.descplan,
           t.dtestr,t.dteend,t.descomment
    from thistrnp t
    where t.codempid = p_codempid
          and t.dteyear = p_year
          and t.codcours = p_codcours
          and t.numclseq = p_numclseq;
  begin
    obj_row     := json_object_t();
    for cl in cs loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', cl.codempid);
        obj_data.put('year', cl.dteyear);
        obj_data.put('codcours', cl.codcours);
        obj_data.put('numclseq', cl.numclseq);
        obj_data.put('numseq', cl.numseq);
        obj_data.put('descplan', cl.descplan);
        obj_data.put('descomment', cl.descomment);
        obj_data.put('dtestrt', to_char(cl.dtestr, 'dd/mm/yyyy'));
        obj_data.put('dteend', to_char(cl.dteend, 'dd/mm/yyyy'));
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_detail_plan;
----------------------------------------------------------------------------------------
procedure get_detail_comment_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
  if param_msg_error is null then
    gen_detail_comment_detail(json_str_output);
    return;
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_detail_comment_detail;
----------------------------------------------------------------------------------------
procedure gen_detail_comment_detail(json_str_output out clob) as
    obj_data               json_object_t;
    v_codempid             ttrimph.codempid%type;
    v_dteyear              ttrimph.dteyear%type;
    v_codcours             ttrimph.codcours%type;
    v_numclseq             ttrimph.numclseq%type;
    v_descommt             ttrimph.descommt%type;
    begin
      begin
      select t.codempid, t.dteyear, t.codcours, t.numclseq,t.descommt
      into v_codempid, v_dteyear, v_codcours, v_numclseq, v_descommt
      from ttrimph t
      where t.codempid = p_codempid
            and t.dteyear = p_year
            and t.codcours = p_codcours
            and t.numclseq = p_numclseq;
      exception when no_data_found then
          null;
      end;

      obj_data          := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', v_codempid);
      obj_data.put('year', v_dteyear);
      obj_data.put('codcours', v_codcours);
      obj_data.put('numclseq', v_numclseq);
      obj_data.put('descommt', v_descommt);
      dbms_lob.createtemporary(json_str_output, true);
      obj_data.to_clob(json_str_output);

     exception when others then
      param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
      json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_detail_comment_detail;
----------------------------------------------------------------------------------------
procedure get_detail_comment_table(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
  if param_msg_error is null then
    gen_detail_comment_table(json_str_output);
    return;
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_detail_comment_table;
----------------------------------------------------------------------------------------
procedure gen_detail_comment_table(json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;

    cursor cs is
    select t.codempid, t.dteyear, t.codcours, t.numclseq, t.numseq, t.descomment
    from ttrimps t
    where t.codempid = p_codempid
          and t.dteyear = p_year
          and t.codcours = p_codcours
          and t.numclseq = p_numclseq;
  begin
    obj_row     := json_object_t();
    for cl in cs loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', cl.codempid);
        obj_data.put('year', cl.dteyear);
        obj_data.put('codcours', cl.codcours);
        obj_data.put('numclseq', cl.numclseq);
        obj_data.put('numseq', cl.numseq);
        obj_data.put('descomment', cl.descomment);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_detail_comment_table;
----------------------------------------------------------------------------------------
procedure get_detail_from_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
  if param_msg_error is null then
    gen_detail_from_detail(json_str_output);
    return;
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_detail_from_detail;
----------------------------------------------------------------------------------------
procedure gen_detail_from_detail(json_str_output out clob) as
    obj_data            json_object_t;
    v_flgperform        ttrimph.flgeval%type;
    v_codeval           ttrimph.codeval%type;
    v_dteeval           ttrimph.dteeval%type;
    v_codform           ttrimph.codform%type;
    v_flgedit           boolean:= true;
    begin
      begin
      select t.flgeval, t.codeval,t.dteeval,t.codform
      into v_flgperform, v_codeval, v_dteeval, v_codform
      from ttrimph t
      where t.codempid = p_codempid
            and t.dteyear = p_year
            and t.codcours = p_codcours
            and t.numclseq = p_numclseq;
      exception when no_data_found then
        v_flgedit := false;
        v_flgperform := 'U';
        begin ----
          select codform into v_codform
          from   tcourse
          where  codcours = p_codcours;
        exception when no_data_found then 
          v_codform := null;
        end;
      end;
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('flgperform', v_flgperform);
      obj_data.put('codeval', v_codeval);
      obj_data.put('dteeval', to_char(v_dteeval, 'dd/mm/yyyy'));
      obj_data.put('codform', v_codform);
      obj_data.put('desc_codform', get_tintview_name(v_codform,global_v_lang));
      obj_data.put('flgedit', v_flgedit);
      dbms_lob.createtemporary(json_str_output, true);
      obj_data.to_clob(json_str_output);
     exception when others then
      param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
      json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_detail_from_detail;
----------------------------------------------------------------------------------------
procedure get_new_codform(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
  if param_msg_error is null then
    gen_new_codform(json_str_output);
    return;
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_new_codform;
----------------------------------------------------------------------------------------
procedure gen_new_codform(json_str_output out clob) as
    obj_data            json_object_t;
    v_codform           tcourse.codform%type;
    begin
      begin
      select t.codform
      into v_codform
      from tcourse t
      where t.codcours = p_codcours;
      exception when no_data_found then
                null;
      end;
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codform', v_codform);

      dbms_lob.createtemporary(json_str_output, true);
      obj_data.to_clob(json_str_output);

     exception when others then
      param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
      json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_new_codform;
----------------------------------------------------------------------------------------
procedure save_all (json_str_input in clob,json_str_output out clob) is

    begin
      initial_value (json_str_input);

      /*json_str_output := get_response_message('400','p_save_year ' || p_save_year || 'p_save_numclseq ' || p_save_codcours,global_v_lang);
      return;*/

           if param_msg_error is null then
              save_ttrimph (save_table_form_obj,param_msg_error);
               if param_msg_error is not null then
                  rollback ;
                  json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
                  return ;
               end if;
           else
               json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
              return ;
           end if;
      ------------------------------------------------------------
       save_ttrimpi (save_ttrimpi_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       save_thistrnp (save_thistrnp_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       save_ttrimps (save_ttrimps_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
   exception when others then
    rollback ;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
end save_all;
--------------------------------------------------------------------------
procedure save_ttrimph (save_table_form_obj in json_object_t, param_msg_error out varchar2) is
    save_table_form_obj_rows      json_object_t;
    json_row                  json_object_t;
    v_codform_old             ttrimph.codform%type;
    v_qtyfscor                ttrimph.qtyfscor%type;
    v_beftrn                  ttrimph.qtyprescr%type;
    v_afttrn                  ttrimph.qtyposscr%type;
    v_sum_qtyfscor            number := 0;
    v_sum_beftrn              number := 0;
    v_sum_afttrn              number := 0;
begin
    save_table_form_obj_rows := save_table_form_obj ;
    for i in 0..save_table_form_obj_rows.get_size - 1 loop
      json_row          := hcm_util.get_json_t(save_table_form_obj_rows, to_char(i));

      v_qtyfscor        := hcm_util.get_string_t(json_row, 'qtyfscor');
      v_beftrn          := hcm_util.get_string_t(json_row, 'beftrn');
      v_afttrn          := hcm_util.get_string_t(json_row, 'afttrn');
      v_sum_qtyfscor    := v_sum_qtyfscor + v_qtyfscor;
      v_sum_beftrn      := v_sum_beftrn + v_beftrn;
      v_sum_afttrn      := v_sum_afttrn + v_afttrn;
    end loop;
    begin

          begin
            select t.codform
            into v_codform_old
            from ttrimph t
            where t.codempid = p_save_codempid
                  and t.dteyear = p_save_year
                  and t.codcours = p_save_codcours
                  and t.numclseq = p_save_numclseq;
            exception when no_data_found then
                      v_codform_old      := null;
          end;
          if v_codform_old != p_save_codform and v_codform_old is not null then
             delete from ttrimpi t
             where t.codempid = p_save_codempid
                and t.dteyear = p_save_year
                and t.codcours = p_save_codcours
                and t.numclseq = p_save_numclseq;
          end if;
          insert into ttrimph
               (
                 codempid ,dteyear, codcours, numclseq, codeval, dteeval, codform,
                 qtyfscor, qtyprescr, qtyposscr, flgeval, descommt, dtecreate, codcreate
               )
          values
               (
                 p_save_codempid, p_save_year ,p_save_codcours, p_save_numclseq, p_save_codeval, p_save_dteeval, p_save_codform,
                 v_sum_qtyfscor, v_sum_beftrn, v_sum_afttrn, p_save_flgperform, p_save_comment_sugges, sysdate, global_v_coduser
               );
          exception when DUP_VAL_ON_INDEX then
                    update ttrimph set
                       codeval =  p_save_codeval,
                       dteeval =  p_save_dteeval,
                       codform =  p_save_codform,
                       qtyfscor =  v_sum_qtyfscor,
                       qtyprescr =  v_sum_beftrn,
                       qtyposscr =  v_sum_afttrn,
                       flgeval =  p_save_flgperform,
                       descommt =  p_save_comment_sugges,
                       dteupd =  sysdate,
                       coduser = global_v_coduser
                    where codempid = p_save_codempid
                          and dteyear = p_save_year
                          and codcours = p_save_codcours
                          and numclseq = p_save_numclseq ;
     end;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_ttrimph ;
--------------------------------------------------------------------------
procedure save_ttrimpi (save_ttrimpi_obj in json_object_t, param_msg_error out varchar2) is
    save_ttrimpi_obj_rows      json_object_t;
    json_row                   json_object_t;
    v_numitem                  ttrimpi.numitem%type;
    v_qtyfscor                 ttrimpi.qtyfscor%type;
    v_beftrn                   ttrimpi.qtyprescr%type;
    v_afttrn                   ttrimpi.qtyposscr%type;
begin
    save_ttrimpi_obj_rows := save_ttrimpi_obj ;
    for i in 0..save_ttrimpi_obj_rows.get_size - 1 loop
      json_row          := hcm_util.get_json_t(save_ttrimpi_obj_rows, to_char(i));
      v_numitem         := hcm_util.get_string_t(json_row, 'numitem');
      v_qtyfscor        := hcm_util.get_string_t(json_row, 'qtyfscor');
      v_beftrn          := hcm_util.get_string_t(json_row, 'beftrn');
      v_afttrn          := hcm_util.get_string_t(json_row, 'afttrn');
      begin
          insert into ttrimpi
                 (
                 codempid, dteyear, codcours, numclseq,
                 numitem, qtyfscor, qtyprescr, qtyposscr,
                 codcreate, dtecreate
                 )
          values
                 (
                 p_save_codempid, p_save_year, p_save_codcours, p_save_numclseq,
                 v_numitem, v_qtyfscor, v_beftrn, v_afttrn,
                 global_v_coduser, sysdate
                 );
      exception when DUP_VAL_ON_INDEX then
          update ttrimpi
          set numitem = v_numitem,
              qtyfscor = v_qtyfscor,
              qtyprescr = v_beftrn,
              qtyposscr = v_afttrn,
              dteupd = sysdate,
              coduser = global_v_coduser
          where codempid = p_save_codempid
                and dteyear = p_save_year
                and codcours = p_save_codcours
                and numclseq = p_save_numclseq
                and numitem = v_numitem ;
       end;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_ttrimpi ;
--------------------------------------------------------------------------
procedure save_thistrnp (save_thistrnp_obj in json_object_t, param_msg_error out varchar2) is
    save_thistrnp_obj_rows      json_object_t;
    json_row                   json_object_t;
    v_descomment               thistrnp.descomment%type;
    v_numseq                   thistrnp.numseq%type;
begin

    save_thistrnp_obj_rows := save_thistrnp_obj ;
    for i in 0..save_thistrnp_obj_rows.get_size - 1 loop
      json_row          := hcm_util.get_json_t(save_thistrnp_obj_rows, to_char(i));
      v_descomment      := hcm_util.get_string_t(json_row, 'descomment');
      v_numseq          := hcm_util.get_string_t(json_row, 'numseq');
      begin
          update thistrnp
          set descomment = v_descomment,
              dteupd = sysdate,
              coduser = global_v_coduser
          where codempid = p_save_codempid
                and dteyear = p_save_year
                and codcours = p_save_codcours
                and numclseq = p_save_numclseq
                and numseq = v_numseq ;
       end;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_thistrnp ;
--------------------------------------------------------------------------
procedure save_ttrimps (save_ttrimps_obj in json_object_t, param_msg_error out varchar2) is
    save_ttrimps_obj_rows      json_object_t;
    json_row                   json_object_t;
    v_flg                      varchar2(100 char);
    v_descomment               ttrimps.descomment%type;
    v_numseq                   ttrimps.numseq%type;
    v_flgAdd                   boolean;
    v_flgEdit                  boolean;
begin
    save_ttrimps_obj_rows := save_ttrimps_obj ;

    for i in 0..save_ttrimps_obj_rows.get_size - 1 loop
      json_row          := hcm_util.get_json_t(save_ttrimps_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string_t(json_row, 'flg');
      v_descomment      := hcm_util.get_string_t(json_row, 'descomment');
      v_numseq          := hcm_util.get_string_t(json_row, 'numseq');
      v_flgAdd             := hcm_util.get_boolean_t(json_row, 'flgAdd');
      v_flgEdit             := hcm_util.get_boolean_t(json_row, 'flgEdit');

      if v_flgAdd = true then
          select nvl(max(numseq),0)+1
          into   v_numseq
          from   ttrimps
          where  codempid = p_save_codempid
             and upper(codcours) = upper(p_save_codcours)
             and dteyear = p_save_year
             and numclseq = p_save_numclseq;
          --------------------------------------
          /*param_msg_error   := 'v_numseq ' || v_numseq || ' p_save_codempid ' || p_save_codempid || ' p_save_codcours ' || p_save_codcours || ' p_save_year ' || p_save_year || ' p_save_numclseq ' || p_save_numclseq;
          return; */
          insert into ttrimps
                 (codempid, codcours, dteyear, numclseq, numseq, descomment, codcreate, coduser, dtecreate )
          values
                 (p_save_codempid, p_save_codcours, p_save_year , p_save_numclseq, v_numseq, v_descomment, global_v_coduser, global_v_coduser, sysdate );
          /*param_msg_error   := p_save_codempid || ' ' || p_save_codcours || ' ' || p_save_year || ' ' || p_save_numclseq || ' ' || v_numseq || ' ' || v_descomment;
          return; */
      elsif v_flgEdit = true then
          update ttrimps
          set descomment = v_descomment,
              dteupd = sysdate,
              coduser = global_v_coduser
          where codempid = p_save_codempid
                and upper(codcours) = upper(p_save_codcours)
                and dteyear = p_save_year
                and numclseq = p_save_numclseq
                and numseq = v_numseq;
           /*param_msg_error   := p_save_codempid || ' ' || p_save_codcours || ' ' || p_save_year || ' ' || p_save_numclseq || ' ' || v_numseq || ' ' || v_descomment;
           return; */
      end if;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_ttrimps ;
--------------------------------------------------------------------------
procedure delete_index (json_str_input in clob, json_str_output out clob) is
    json_row            json_object_t;
    v_flg               varchar2(100 char);
    v_codcours          thistrnn.codcours%type;
    v_codempid          thistrnn.codempid%type;
    v_year              thistrnn.dteyear%type;
    v_numclseq          thistrnn.numclseq%type;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.get_size - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        v_codcours        := hcm_util.get_string_t(json_row, 'codcours');
        v_codempid        := hcm_util.get_string_t(json_row, 'codempid');
        v_year            := hcm_util.get_string_t(json_row, 'dteyear');
        v_numclseq        := hcm_util.get_string_t(json_row, 'numclseq');

        if v_flg = 'delete' then
           begin
                 delete from ttrimph
                 where codcours = v_codcours
                       and codempid = v_codempid
                       and dteyear = v_year
                       and numclseq = v_numclseq;

                 delete from ttrimpi
                 where codcours = v_codcours
                       and codempid = v_codempid
                       and dteyear = v_year
                       and numclseq = v_numclseq;

                 delete from ttrimps
                 where codcours = v_codcours
                       and codempid = v_codempid
                       and dteyear = v_year
                       and numclseq = v_numclseq;

                 update thistrnp
                set descomment = null,
                    dteupd = sysdate,
                    coduser = global_v_coduser
                where codempid = v_codempid
                      and upper(codcours) = upper(v_codcours)
                      and dteyear = v_year
                      and numclseq = v_numclseq;
           end;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2425', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end delete_index;
----------------------------------------------------------------------------------
procedure get_eval_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);

  if param_msg_error is null then
         gen_eval_detail(json_str_output);
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_eval_detail;
----------------------------------------------------------------------------------------
procedure gen_eval_detail(json_str_output out clob) as
    obj_data            json_object_t;
    v_flgperform        ttrimph.flgeval%type;
    v_codeval           ttrimph.codeval%type;
    v_dteeval           ttrimph.dteeval%type;
    v_codform           ttrimph.codform%type;

    begin
      begin
      select t.flgeval, t.codeval,t.dteeval
      into v_flgperform, v_codeval, v_dteeval
      from ttrimph t
      where t.codempid = p_codempid
            and t.dteyear = p_year
            and t.codcours = p_codcours
            and t.numclseq = p_numclseq
            and t.codform = p_codform;
      exception when no_data_found then
          null;
      end;
      v_codform         := get_codform_ttrimph(p_codempid,p_year,p_codcours,p_numclseq);
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('flgperform', nvl(v_flgperform,'U'));
      obj_data.put('codform', p_codform);
      obj_data.put('codformo', v_codform);
      obj_data.put('desc_codform', get_tintview_name(p_codform,global_v_lang));

      dbms_lob.createtemporary(json_str_output, true);
      obj_data.to_clob(json_str_output);

     exception when others then
      param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
      json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_eval_detail;
----------------------------------------------------------------------------------------
procedure get_position (json_str_input in clob, json_str_output out clob) is
    obj_data    json_object_t;
    v_position  temploy1.codpos%type;
  begin
    initial_value (json_str_input);
    v_position := '' ;
    if param_msg_error is null then
        select codpos
        into   v_position
        from temploy1
        where codempid = p_codeval ;
    end if;
    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('position', get_tpostn_name(v_position, global_v_lang));
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_position;
----------------------------------------------------------------------------------------

end HRTR6CE;

/

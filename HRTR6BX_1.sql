--------------------------------------------------------
--  DDL for Package Body HRTR6BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR6BX" is
-- last update: 09/07/2020 16:55
 procedure initial_value(json_str_input in clob) as
    json_obj json;
  begin
    json_obj            := json(json_str_input);
    param_msg_error     := '';

    global_v_coduser    := json_ext.get_string(json_obj,'p_coduser');
    global_v_lang       := json_ext.get_string(json_obj,'p_lang');

    p_dteyear           := hcm_util.get_string(json_obj,'p_dteyear');
    p_codcomp           := hcm_util.get_string(json_obj,'p_codcomp');
    p_codcours          := hcm_util.get_string(json_obj,'p_codcours');
    p_numclseq          := hcm_util.get_string(json_obj,'p_numclseq');
    p_typetest          := hcm_util.get_string(json_obj,'p_typetest');
    p_codexam           := hcm_util.get_string(json_obj,'p_codexam');
    p_stdte             := to_date(json_ext.get_string(json_obj,'p_stdte'),'ddmmyyyy');
    p_endte             := to_date(json_ext.get_string(json_obj,'p_endte'),'ddmmyyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);--User37 #2996 4. TR Module 26/04/2021

end initial_value;
----------------------------------------------------------------------------------------
procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
  if param_msg_error is null then
     if p_dteyear is not null and p_codcomp is not null and p_codcours is not null and p_numclseq is not null and p_typetest is not null then
        gen_index_1(json_str_output);
     else
        gen_index_2(json_str_output);
     end if;
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
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
    v_count_codexam            number := 0;
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
       where upper(t.codcours) = upper(p_codcours);

       if v_count_codcours = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOURSE');
           return;
        end if ;
    end if;

    if p_stdte > p_endte then
       param_msg_error := get_error_msg_php('HR2020',global_v_lang);
           return;
    end if;

    if p_codexam is not null then
       select count(*)
       into   v_count_codexam
       from tcodexam t
       where upper(t.codcodec) = upper(p_codexam);

       if v_count_codexam = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEXAM');
           return;
        end if ;
    end if;
end check_index;
----------------------------------------------------------------------------------------
procedure gen_index_1(json_str_output out clob) as
    obj_data                          json;
    obj_row                           json;
    v_rcnt                            number := 0;
    --<<User37 #2996 4. TR Module 26/04/2021
    v_flg_secur                       boolean := false;
    v_zupdsal                         varchar2(4 char);
    v_data                            varchar2(1 char):= 'N';
    v_secu                            varchar2(1 char):= 'N';
    -->>User37 #2996 4. TR Module 26/04/2021

    cursor c_thistrnn is
           select a.codempid,dteexam,a.codexam,b.codpos,qtyexam,qtytest,grdtest, b.codcomp,a.rowid
          from ttrtesth a, temploy1 b, thisclss c
          where decode(p_typetest, 1,c.codexampr,c.codexampo) = a.codexam
              and a.codempid =b.codempid
              and b.staemp in ('1','3')
              and (
              (p_typetest = 1 and a.dteexam between c.dteprest and c.dtepreen)
              or
              (p_typetest = 2 and a.dteexam between c.dtepostst and c.dteposten))
              and c.dteyear = p_dteyear
              and b.codcomp like upper(p_codcomp)||'%'
              and upper(c.codcours) = upper(p_codcours)
              and c.numclseq = p_numclseq
              and decode(p_typetest, 1,c.codexampr,c.codexampo) = a.codexam
          order by qtytest desc;
  begin
    obj_row     := json();
    v_rcnt              := 0;
    for r_thistrnn in c_thistrnn loop
        --<<User37 #2996 4. TR Module 26/04/2021
        v_data      := 'Y';
        v_flg_secur := secur_main.secur2(r_thistrnn.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl, v_zupdsal);
        if v_flg_secur then
            v_secu      := 'Y';
        -->>User37 #2996 4. TR Module 26/04/2021
            v_rcnt      := v_rcnt+1;
            obj_data    := json();
            obj_data.put('coderror', '200');
            obj_data.put('image', get_emp_img(r_thistrnn.codempid));
            obj_data.put('codempid', r_thistrnn.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r_thistrnn.codempid,global_v_lang));
            obj_data.put('desc_codcomp', get_tcenter_name(r_thistrnn.codcomp,global_v_lang));
            obj_data.put('qtyexam', r_thistrnn.qtyexam);
            obj_data.put('qtytest', r_thistrnn.qtytest);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);

    --<<User37 #2996 4. TR Module 26/04/2021
    if v_data = 'N' then
        param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'THISCLSS');
        json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
    elsif v_secu = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    /*if v_rcnt = 0 then
      param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'THISCLSS');
      json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
    end if;*/
    -->>User37 #2996 4. TR Module 26/04/2021

exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_index_1;
----------------------------------------------------------------------------------------
procedure gen_index_2(json_str_output out clob) as
    obj_data                          json;
    obj_row                           json;
    v_rcnt                            number := 0;
    --<<User37 #2996 4. TR Module 26/04/2021
    v_flg_secur                       boolean := false;
    v_zupdsal                         varchar2(4 char);
    v_data                            varchar2(1 char):= 'N';
    v_secu                            varchar2(1 char):= 'N';
    -->>User37 #2996 4. TR Module 26/04/2021
    cursor c_thistrnn is
          select a.codempid, dteexam, codexam, b.codpos, qtyexam, qtytest, grdtest, b.codcomp, a. rowid
          from ttrtesth a, temploy1 b
          where upper(codexam) = upper(p_codexam)
                and a.codempid = b.codempid
                and b.codcomp like upper(nvl(p_codcomp,b.codcomp))||'%'
                and staemp in ('1','3')
                and dteexam between p_stdte and p_endte
          order by qtytest desc;
  begin
    obj_row     := json();
    v_rcnt              := 0;
    for r_thistrnn in c_thistrnn loop
        --<<User37 #2996 4. TR Module 26/04/2021
        v_data      := 'Y';
        v_flg_secur := secur_main.secur2(r_thistrnn.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl, v_zupdsal);
        if v_flg_secur then
            v_secu      := 'Y';
        -->>User37 #2996 4. TR Module 26/04/2021
            v_rcnt      := v_rcnt+1;
            obj_data    := json();
            obj_data.put('coderror', '200');
            obj_data.put('image', get_emp_img(r_thistrnn.codempid));
            obj_data.put('codempid', r_thistrnn.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r_thistrnn.codempid,global_v_lang));
            obj_data.put('desc_codcomp', get_tcenter_name(r_thistrnn.codcomp,global_v_lang));
            obj_data.put('qtyexam', r_thistrnn.qtyexam);
            obj_data.put('qtytest', r_thistrnn.qtytest);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);

    --<<User37 #2996 4. TR Module 26/04/2021
    if v_data = 'N' then
        param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'TTRTESTH');
        json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
    elsif v_secu = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    /*
    if v_rcnt = 0 then
      param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'TTRTESTH');
      json_str_output   := get_response_message(400, param_msg_error, global_v_lang);
    end if;*/
    -->>User37 #2996 4. TR Module 26/04/2021

exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_index_2;
----------------------------------------------------------------------------------------
procedure get_index_header(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
  if param_msg_error is null then
     if p_dteyear is not null and p_codcomp is not null and p_codcours is not null and p_numclseq is not null and p_typetest is not null then
       gen_index_header_1(json_str_output);
     else
       gen_index_header_2(json_str_output);
     end if;
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_index_header;
----------------------------------------------------------------------------------------
procedure gen_index_header_1(json_str_output out clob) as
    obj_data               json;
    v_total                number;
    v_average              number;

  begin
    begin
      select nvl(count(qtyexam),0) as total, nvl(avg(qtytest),0) as average
      into v_total, v_average
          from ttrtesth a, temploy1 b, thisclss c
          where decode(p_typetest, 1,c.codexampr,c.codexampo) = a.codexam
              and a.codempid =b.codempid
              and b.staemp in ('1','3')
              and (
              (p_typetest = 1 and a.dteexam between c.dteprest and c.dtepreen)
              or
              (p_typetest = 2 and a.dteexam between c.dtepostst and c.dteposten))
              and c.dteyear = p_dteyear
              and b.codcomp like upper(p_codcomp)||'%'
              and upper(c.codcours) = upper(p_codcours)
              and c.numclseq = p_numclseq
              and decode(p_typetest, 1,c.codexampr,c.codexampo) = a.codexam
              --<<User37 #2996 4. TR Module 26/04/2021
              and exists (select codcomp
                            from tusrcom x
                           where x.coduser = global_v_coduser
                             and b.codcomp like x.codcomp||'%')
              and b.numlvl between global_v_zminlvl and global_v_zwrklvl
              -->>User37 #2996 4. TR Module 26/04/2021
              ;

    exception when no_data_found then
        null;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('total', v_total);
    obj_data.put('average', v_average);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_index_header_1;
----------------------------------------------------------------------------------------
procedure gen_index_header_2(json_str_output out clob) as
    obj_data               json;
    v_total                number;
    v_average              number;

  begin
    begin
      select nvl(count(qtyexam),0) as total, nvl(avg(qtytest),0) as average
      into v_total, v_average
          from ttrtesth a, temploy1 b
          where upper(codexam) = upper(p_codexam)
                and a.codempid = b.codempid
                and b.codcomp like upper(nvl(p_codcomp,b.codcomp))||'%'
                and staemp in ('1','3')
                and dteexam between p_stdte and p_endte
                --<<User37 #2996 4. TR Module 26/04/2021
                and exists (select codcomp
                              from tusrcom x
                             where x.coduser = global_v_coduser
                               and b.codcomp like x.codcomp||'%')
                and b.numlvl between global_v_zminlvl and global_v_zwrklvl
                -->>User37 #2996 4. TR Module 26/04/2021
                ;

    exception when no_data_found then
        null;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('total', v_total);
    obj_data.put('average', v_average);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_index_header_2;
----------------------------------------------------------------------------------------

end HRTR6BX;

/

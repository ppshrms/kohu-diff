--------------------------------------------------------
--  DDL for Package Body HRTR7QX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR7QX" is
-- last update: 11/08/2020 14:00

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    --block b_index
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codpos      := hcm_util.get_string_t(json_obj,'p_codpos');

    --block drilldown
    b_index_dteeffec    := hcm_util.get_string_t(json_obj,'p_dteeffec');
    b_index_numlevel    := hcm_util.get_string_t(json_obj,'p_numlevel');
    b_index_codcompp    := hcm_util.get_string_t(json_obj,'p_codcompp');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_head(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_index_data(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
--      gen_head(json_str_output);
--      json(json_str_output).print;

      gen_data(json_str_output);
--      json(json_str_output).print;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_head(json_str_output out clob) is
    obj_row_codskill json_object_t;
    obj_row_codcours json_object_t;
    obj_data        json_object_t;
    obj_data_skil   json_object_t;
    v_seq           number := 0;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);
    v_month         varchar2(2 char);
    v_codcomp       varchar2(400 char);
    v_codpos        varchar2(400 char);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);

    v_codcompy      varchar2(400 char);
    v_codlinef      varchar2(400 char);
    v_dteeffec      date;
    v_codcompr      varchar2(400 char);
    v_codskill      varchar2(400 char);

    cursor c1 is
      select a.codskill
        from tcomptcr a, tjobposskil b
       where a.codskill = b.codskill
         and a.grade <= b.grade
         and b.codcomp like b_index_codcomp||'%'
         and b.codpos  = b_index_codpos
      group by a.codskill
      order by a.codskill;

    cursor c2 is
      select a.codcours
        from tcomptcr a, tjobposskil b
       where a.codskill = b.codskill
         and a.grade <= b.grade
         and b.codcomp like b_index_codcomp||'%'
         and b.codpos  = b_index_codpos
         and a.codskill = v_codskill
      group by a.codskill, a.codcours
      order by a.codskill, a.codcours;

  begin

    --HEAD REPORT 2 ROW
    obj_row_codskill := json_object_t();
    for i in c1 loop
          v_codskill  := i.codskill;
          v_rcnt2     := 0;

          obj_row_codcours := json_object_t();
          for k in c2 loop
              v_seq := v_seq + 1;  --count run mattrix

              v_rcnt2 := v_rcnt2 + 1;
              obj_data := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('codcours',k.codcours); --
              obj_data.put('desc_codcours',get_tcourse_name(k.codcours , global_v_lang));
              obj_row_codcours.put(to_char(v_rcnt2-1),obj_data);
             exit when v_seq > 100;  --Check Run Matrix Not Over 100 Col.
          end loop;

          v_rcnt := v_rcnt + 1;
          obj_data_skil := json_object_t();
          obj_data_skil.put('coderror', '200');
          obj_data_skil.put('codskill',i.codskill);         --
          obj_data_skil.put('desc_codskill',get_tcodec_name('TCODSKIL',i.codskill,global_v_lang)); --

          obj_data_skil.put('codcours', obj_row_codcours);

          obj_row_codskill.put(to_char(v_rcnt-1),obj_data_skil);
        exit when v_seq > 100;      --Check Run Matrix Not Over 100 Col.
    end loop;

    if v_rcnt > 0 then
      json_str_output := obj_row_codskill.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TCOMPTCR');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data(json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;
    obj_key_data  json_object_t;
    v_rcnt        number := 0;
    v_rcnt2       number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_cnt           number;

    cursor c1 is
      select a.codempid, a.codcomp, a.codpos
        from temploy1 a
       where a.codcomp like b_index_codcomp||'%'
         and a.codpos  = b_index_codpos
         and exists(select codempid from thistrnn t2 where t2.codempid = a.codempid)
      order by a.codempid;

    cursor c2 is
      select a.codcours
        from tcomptcr a, tjobposskil b
       where a.codskill = b.codskill
         and a.grade <= b.grade
         and b.codcomp like b_index_codcomp||'%'
         and b.codpos  = b_index_codpos
      group by a.codskill, a.codcours
      order by a.codskill, a.codcours;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_flgdata := 'Y';

      flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if flgpass then
         v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('image', get_emp_img(i.codempid));
          obj_data.put('codempid',i.codempid);
          obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
          obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
          v_rcnt2 := 0;
          for k in c2 loop
              v_rcnt2 := v_rcnt2+1;
              begin
                  select count(codempid) into v_cnt
                    from thistrnn
                   where codempid = i.codempid
                     and codcours = k.codcours;
                  exception when others then v_cnt := null;
              end;
              obj_data.put('cnt_emp'||v_rcnt2 , v_cnt);
            exit when v_rcnt2 > 100;  --Check Run Matrix Not Over 100 Col.
          end loop;
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_rcnt > 0 then
      obj_key_data  := json_object_t();
      obj_key_data.put('coderror', '200');
      obj_key_data.put('rows', obj_row);
      json_str_output := obj_key_data.to_clob;
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'thistrnn');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_total_column(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    flgpass     boolean;
    v_rcnt2     number := 0;
    cursor c1 is
      select a.codempid, a.codcomp, a.codpos
        from temploy1 a
       where a.codcomp like b_index_codcomp||'%'
         and a.codpos  = b_index_codpos
         and exists(select codempid from thistrnn t2 where t2.codempid = a.codempid)
       order by a.codempid;

    cursor c2 is
      select a.codcours
        from tcomptcr a, tjobposskil b
       where a.codskill = b.codskill
         and a.grade <= b.grade
         and b.codcomp like b_index_codcomp||'%'
         and b.codpos  = b_index_codpos
      group by a.codskill, a.codcours
      order by a.codskill, a.codcours;
  begin
    initial_value(json_str_input);
    for i in c1 loop
      flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if flgpass then
          v_rcnt2 := 0;
          for k in c2 loop
              v_rcnt2 := v_rcnt2+1;
            exit when v_rcnt2 > 100;  --Check Run Matrix Not Over 100 Col.
          end loop;
      end if;
    end loop;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('totalColumn',v_rcnt2); --
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;


/

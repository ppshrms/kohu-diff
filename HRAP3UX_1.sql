--------------------------------------------------------
--  DDL for Package Body HRAP3UX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3UX" is
-- last update: 25/08/2020 15:47
  procedure initial_value(json_str in clob) is
      json_obj        json_object_t;
      begin
        v_chken             := hcm_secur.get_v_chken;
        json_obj            := json_object_t(json_str);
        --global
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
       --b_index
        b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_dteyreap');
        b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numtime');
        b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
        --screen
        b_index_codkpino     := hcm_util.get_string_t(json_obj,'p_codkpino');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
      end initial_value;
  --
  procedure get_index1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_index1(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);

cursor c1 is
        select  b.dteyreap,b.numtime,b.codcomp, b.objective
        from    tobjdep b
       where    b.dteyreap   = b_index_dteyreap
         and    b.numtime    = b_index_numtime
         and    b.codcomp    = b_index_codcomp--User37 #7241 3. AP Module 03/12/2021 like   b_index_codcomp||'%'
         and   ((v_chksecu  = 1 )
                or (v_chksecu = '2' and exists (select codcomp from tusrcom x
                                 where x.coduser = global_v_coduser
                                   and b.codcomp like b.codcomp||'%')
            )) 
        order by codcomp;--User37 #7241 3. AP Module 03/12/2021 

 begin
    obj_row := json_object_t();
    v_chksecu := '1';
    for i in c1 loop
        v_flgdata := 'Y';
    end loop;
    if v_flgdata = 'Y' then
        v_chksecu := '2';
        for i in c1 loop
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('dteyreap',i.dteyreap);
            obj_data.put('numtime',i.numtime);
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('objective',i.objective);
            exit;--User37 #7241 3. AP Module 03/12/2021 
        -- obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
    end if; --v_flgdata
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TOBJDEP');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
     -- json_str_output := obj_row.to_clob;
      json_str_output := obj_data.to_clob;
    end if;
  end;
  --

  procedure get_index2(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_index2(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    v_dteyrbug      number;
    flgpass     	boolean;
    v_sumscr        number :=0;
    v_sumtotscr     number :=0;
    v_old_kpino     varchar2(4) := '####';
    v_wgt_all       number :=0;
    v_codkpino      tkpidph.codkpino%type :='!@#$';--User37 #7241 3. AP Module 03/12/2021 

cursor c1 is
    select  a.dteyreap,a.numtime,a.codcomp ,a.codkpino, a.kpides kpinodes,a.wgt, a.target, nvl(a.kpivalue,0) kpivalue,
            nvl(b.score,0)score , b.kpides grddes, b.grade
      from  tkpidph a, tkpidpg b
     where  a.dteyreap  = b_index_dteyreap
       and  a.numtime   = b_index_numtime
       and  a.codcomp   = b_index_codcomp--User37 #7241 3. AP Module 03/12/2021 like b_index_codcomp||'%'
       and  a.dteyreap  = b.dteyreap
       and  a.numtime   = b.numtime
       and  a.codcomp   = b.codcomp
       and  a.codkpino  = b.codkpino
  order by  a.codkpino , b.score desc;

 begin
    obj_row := json_object_t();
    v_chksecu := '1';
    for i in c1 loop
        v_flgdata := 'Y';
    end loop;
    if v_flgdata = 'Y' then
        for i in c1 loop
           --- total each kpi (not last)---
           if i.codkpino <> nvl(v_old_kpino,'####') then
             v_old_kpino := i.codkpino;
              if v_rcnt > 0 then
                v_rcnt := v_rcnt+1;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('flgsum','Y');
                obj_data.put('codkpino','');
                obj_data.put('kpinodes',get_label_name('HRAP3UXC2',global_v_lang,100));--Sumรวม
                obj_data.put('wgt','');
                obj_data.put('value','');
                obj_data.put('target','');
                obj_data.put('qtyscor',v_sumscr);
                obj_data.put('score_condition','');
                obj_data.put('codcomp',i.codcomp);
                obj_row.put(to_char(v_rcnt-1),obj_data);
              end if;
              v_sumscr :=0;
           end if;
            ------------  data of kpi---------
            flgpass := secur_main.secur7(i.codcomp,global_v_coduser);
            if flgpass then
                v_flgsecu := 'Y';
                v_rcnt := v_rcnt+1;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('info',i.codkpino);
                obj_data.put('codkpino',i.codkpino);
                obj_data.put('kpinodes',i.kpinodes);
                obj_data.put('wgt',i.wgt);
                --<<User37 #7241 3. AP Module 03/12/2021 
                if i.codkpino <> v_codkpino then
                  v_wgt_all := nvl(v_wgt_all,0)+nvl(i.wgt,0);
                  v_codkpino := i.codkpino;
                end if;
                obj_data.put('value',to_char(i.kpivalue,'fm999,999,999,990.00'));
                --obj_data.put('value',to_char(i.kpivalue,'fm990.00'));
                -->>User37 #7241 3. AP Module 03/12/2021 
                obj_data.put('target',i.target);
                obj_data.put('qtyscor',to_char(i.score,'fm99,990.00'));
                obj_data.put('score_condition',i.grddes);
                v_sumscr    := v_sumscr+i.score;
                v_sumtotscr := v_sumtotscr+i.score;
                --adjust
                obj_data.put('dteyear',b_index_dteyreap);
                obj_data.put('numseq',b_index_numtime);
                obj_data.put('codcomp',i.codcomp);
                obj_data.put('dteyreap',i.dteyreap);
                obj_data.put('numtime',i.numtime);
                obj_data.put('grade',i.grade);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;
        end loop;
        if v_flgsecu = 'Y' then
          if v_rcnt > 0 then
            --- total each kpi (last)---
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('flgsum','Y');
            obj_data.put('codkpino','');
            obj_data.put('kpinodes',get_label_name('HRAP3UXC2',global_v_lang,100));--Sumรวม
            obj_data.put('wgt','');
            obj_data.put('value','');
            obj_data.put('target','');
            obj_data.put('qtyscor',v_sumscr);
            obj_data.put('score_condition','');
            obj_row.put(to_char(v_rcnt-1),obj_data);
            --- grand total---
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('flgsum','Y');
            obj_data.put('codkpino','');
            obj_data.put('kpinodes',get_label_name('HRAP3UXC2',global_v_lang,90));--Total-รวมทั้งหมด
            obj_data.put('wgt',to_char(v_wgt_all,'fm999,999,999,990.00'));--User37 #7241 3. AP Module 03/12/2021 obj_data.put('wgt',''); 
            obj_data.put('value','');
            obj_data.put('target','');
            obj_data.put('qtyscor',v_sumtotscr);
            obj_data.put('score_condition','');
            obj_row.put(to_char(v_rcnt-1),obj_data);
         end if;
      end if;
    end if; --v_flgdata

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TKPIDPH');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --


  procedure gen_detail(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    flgpass     	boolean;

cursor c1 is
    select  dteyreap,numtime,codcomp,codkpino,codempid,codpos, target, kpivalue, targtstr, targtend
      from  tkpidpem
     where  dteyreap   = b_index_dteyreap
       and  numtime    = b_index_numtime
       and  codcomp    = b_index_codcomp
       and  codkpino   = b_index_codkpino
   order by codempid;

 begin
    obj_row := json_object_t();
    v_chksecu := '1';
    for i in c1 loop
        v_flgdata := 'Y';
    end loop;
    if v_flgdata = 'Y' then
        for i in c1 loop
            flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
            if flgpass then
                v_flgsecu := 'Y';
                v_rcnt := v_rcnt+1;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('#',v_rcnt);
                obj_data.put('image',get_emp_img(i.codempid));
                obj_data.put('dteyreap',i.dteyreap);
                obj_data.put('numtime',i.numtime);
                obj_data.put('codcomp',i.codcomp);
                obj_data.put('codkpino',i.codkpino);
                obj_data.put('codempid',i.codempid);
                obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('desc_pos',get_tpostn_name(i.codpos,global_v_lang));
                obj_data.put('target',i.target);
                obj_data.put('value',to_char(i.kpivalue,'fm999,999,999,990.00'));--User37 #7241 3. AP Module 03/12/2021 obj_data.put('value',to_char(i.kpivalue,'fm990.00'));
                obj_data.put('dtestrt',to_char(i.targtstr,'dd/mm/yyyy'));
                obj_data.put('dteend',to_char(i.targtend,'dd/mm/yyyy'));
                obj_row.put(to_char(v_rcnt-1),obj_data);

            end if;
        end loop;
    end if; --v_flgdata

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TKPIDPEM');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --------
end;

/

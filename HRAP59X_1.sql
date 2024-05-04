--------------------------------------------------------
--  DDL for Package Body HRAP59X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP59X" is
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
        b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_year');
        b_index_numtime     := hcm_util.get_string_t(json_obj,'p_seqno');
        b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
        b_index_codbon      := hcm_util.get_string_t(json_obj,'p_codbonus');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
      end initial_value;
  --
  procedure get_index1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_data1(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_month         varchar2(2 char);
    v_chksecu       varchar2(1);
    v_dteyrbug      number;
    v_codcompp      varchar2(400 char);
    v_codpospr      varchar2(400 char);
    v_amtnbon       number;

cursor c1 is
    select b.dteyreap, b.numtime, b.codcomp, b.codbon, nvl(b.amtbudg,0) amtbudg
    from   tbonus a, tbonparh b
    where  a.dteyreap   = b_index_dteyreap
    and    a.numtime    = b_index_numtime
    and    a.codcomp    like b_index_codcomp||'%'--User37 #4478 AP - PeoplePlus 19/02/2021 = b_index_codcomp
    and    a.codbon     = b_index_codbon
    and    a.dteyreap   = b.dteyreap
    and    a.numtime    = b.numtime
    and    a.codbon     = b.codbon
    and    a.codcomp    like b.codcomp||'%'--User37 #4478 AP - PeoplePlus 19/02/2021 = b.codcomp
    and    nvl(stddec(a.amtnbon,a.codempid,v_chken),0) > 0
    and   ((v_chksecu  = 1 )
          or (v_chksecu = '2' and exists (select codcomp from tusrcom x
                                 where x.coduser = global_v_coduser
                                   and b.codcomp like b.codcomp||'%')
            ))
   order by a.codcomp;


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
            obj_data.put('codbon',i.codbon);
            obj_data.put('desc_bon',get_tcodec_name('TCODBONS',i.codbon,global_v_lang));
            obj_data.put('budget',to_char(i.amtbudg,'fm9,999,999,990.00'));

            begin
                select sum(nvl(stddec(amtnbon,codempid,v_chken),0)) amtnbon
                into   v_amtnbon
                from   tbonus
                where  dteyreap   = b_index_dteyreap
                and    numtime    = b_index_numtime
                and    codcomp    = b_index_codcomp
                and    codbon     = b_index_codbon
                and    nvl(stddec(amtnbon,codempid,v_chken),0) > 0;
                exception when no_data_found then v_amtnbon := 0;
            end;
            obj_data.put('cost',to_char(v_amtnbon,'fm9,999,999,990.00'));
        -- obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
    end if; --v_flgdata
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TBONPARH');
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
      gen_data2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --


  procedure gen_data2(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    v_dteyrbug      number;
    v_year          number;
    v_month         number;
    v_day           number;
    flgpass     	boolean;

cursor c1 is
    select   a.dteyreap, a.numtime, a.codcomp, a.codbon, a.codempid,  a.codpos, a.dteempmt,a.grade,b.dteend,a.remarkadj,
             nvl(stddec(a.amtsal,a.codempid,v_chken),0) amtsal,
             nvl(stddec(a.amtbon,a.codempid,v_chken),0) amtbon,
             nvl(stddec(a.amtadjbo,a.codempid,v_chken),0) amtadjbo,
             nvl(stddec(a.amtnbon,a.codempid,v_chken),0) amtnbon,
             nvl(a.qtybon,0) qtybon,
             nvl(a.pctdedbo,0) pctdedbo,
             b.typbon
    from    tbonus a, tbonparh b
    where   a.dteyreap = b_index_dteyreap
    and     a.numtime    = b_index_numtime
    and     a.codcomp    like b_index_codcomp||'%'--User37 #4478 AP - PeoplePlus 19/02/2021 = b_index_codcomp
    and     a.codbon     = b_index_codbon
    and     a.dteyreap   = b.dteyreap
    and     a.numtime    = b.numtime
    and     a.codbon     = b.codbon
    and     a.codcomp    like b.codcomp||'%'--User37 #4478 AP - PeoplePlus 19/02/2021 = b.codcomp
    and     nvl(stddec(a.amtnbon,a.codempid,v_chken),0) > 0
   order by a.codcomp,  a.codempid;

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
                obj_data.put('codcomp',i.codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
                obj_data.put('image',get_emp_img(i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
                get_service_year(i.dteempmt,i.dteend,'Y',v_year,v_month,v_day);
                --obj_data.put('v_year',to_char(v_year,'fm90'));
                --obj_data.put('v_month',to_char(v_month,'fm90'));
                obj_data.put('qtywork',to_char(v_year,'fm90')||':'||to_char(v_month,'fm90'));
                if i.typbon = '1' then--ตามผลการประเมิน
                    obj_data.put('grade',i.grade);
                    obj_data.put('desc_grade',get_tstdis_name (i.codcomp, i.dteyreap, i.grade,global_v_lang) );
                else  --ตามเงื่อนไข
                    obj_data.put('grade','');
                    obj_data.put('desc_grade','');
                end if;
                obj_data.put('salary',i.amtsal);
                obj_data.put('rate',to_char(i.qtybon,'fm990.00'));
                obj_data.put('increate',to_char(i.amtadjbo,'fm9,999,999,990.00'));
                obj_data.put('percent',to_char(i.pctdedbo,'fm990.00'));
                obj_data.put('total',to_char(i.amtnbon,'fm9,999,999,990.00'));
                obj_data.put('remark',i.remarkadj);
                --adjust
                obj_data.put('dteyreap',b_index_dteyreap);
                obj_data.put('numtime',b_index_numtime);
                obj_data.put('codbon',b_index_codbon);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;
        end loop;
    end if; --v_flgdata

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TBONUS');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --

end;

/

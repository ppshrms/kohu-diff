--------------------------------------------------------
--  DDL for Package Body HRAP57X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP57X" is
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
    v_chksecu       varchar2(1);
    v_dteyrbug      number;
    v_year          number;
    v_month         number;
    v_day           number;
    flgpass     	boolean;
    v_numseq        number;
    v_ratecond      varchar2(1000);
    v_codempid      varchar2(10);

cursor c1 is
    select   a.dteyreap, a.numtime, a.codcomp, a.codbon, a.codempid,  a.codpos, a.dteempmt,a.grade,a.remarkadj,
             b.typbon, b.codcomp codcomp2
    from    tbonus a, tbonparh b
    where   a.dteyreap   = b_index_dteyreap
    and     a.numtime    = b_index_numtime
    and     a.codcomp    like b_index_codcomp || '%'
    and     a.codbon     = b_index_codbon
    and     a.dteyreap   = b.dteyreap
    and     a.numtime    = b.numtime
    and     a.codbon     = b.codbon
    and     a.codcomp    like b.codcomp || '%'
    and     nvl(stddec(a.amtnbon,a.codempid,v_chken),0) <= 0
   order by a.codcomp,  a.codempid;


cursor c2 is
    select   dteyreap,numtime,codcomp,codempid, 0 qtyadjtot ,0 qtyta, 0 qtypuns
    from tbonus
        where   dteyreap   = b_index_dteyreap
        and     numtime    = b_index_numtime
        and     codcomp    like b_index_codcomp || '%'
        and     codbon     = b_index_codbon
        and     codempid   = v_codempid
        and     nvl(stddec(amtnbon,codempid,v_chken),0) <=0
    union
    select dteyreap,numtime,codcomp,codempid, nvl(qtyadjtot,0) qtyadjtot ,  nvl(qtyta,0)  qtyta, nvl(qtypuns,0)  qtypuns
    from tappemp
        where   dteyreap   = b_index_dteyreap
        and     numtime    = b_index_numtime
        and     codcomp    like b_index_codcomp || '%'
        and     codempid   = v_codempid
        and      nvl(flgbonus,'N') = 'N'
    order by  dteyreap,numtime,codcomp,codempid;

 cursor c3 is
    select   a.dteyreap, a.numtime, a.codcomp, a.codbon, a.codempid,  a.codpos
    from    tbonus a, tbonparh b
    where   a.dteyreap   = b_index_dteyreap
    and     a.numtime    = b_index_numtime
    and     a.codcomp    like b_index_codcomp || '%'
    and     a.codbon     = b_index_codbon
    and     a.dteyreap   = b.dteyreap
    and     a.numtime    = b.numtime
    and     a.codbon     = b.codbon
    and     a.codempid   = v_codempid
    and     nvl(stddec(a.amtnbon,a.codempid,v_chken),0) <=0
   order by a.codempid;


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
            v_codempid := i.codempid;
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('dtein',to_char(i.dteempmt,'dd/mm/yyyy'));
            obj_data.put('score','');
            obj_data.put('grade','');
            obj_data.put('detail','');
            obj_data.put('discout','');
            obj_data.put('discard','');
            if i.typbon = '1' then --“ตามผลการประเมิน”
                v_codempid := i.codempid;
                for n in c2 loop
                    obj_data.put('score',to_char(n.qtyadjtot,'fm9,990.00'));
                    obj_data.put('grade',i.grade);
                    obj_data.put('detail',get_tstdis_name (i.codcomp2,i.dteyreap,i.grade,global_v_lang) );
                    obj_data.put('discout',to_char(n.qtyta,'fm9,990.00'));
                    obj_data.put('discard',to_char(n.qtypuns,'fm9,990.00'));
                end loop;
            else--“ตามเงื่อนไข”
                v_codempid := i.codempid;
                for k in c3 loop
                    obj_data.put('score','');
                    begin
                        select  numseq , ratecond
                        into    v_numseq , v_ratecond
                        from    tbonparc
                        where   dteyreap   = k.dteyreap
                        and     numtime    = k.numtime
                        and     codcomp    = k.codcomp
                        and     codbon     = k.codbon;
                        exception when no_data_found then
                            v_numseq    := null;
                            v_ratecond  := null;
                    end;
                    obj_data.put('grade',to_char(v_numseq,'fm990'));
                    obj_data.put('detail',v_ratecond);
                    obj_data.put('discout','');
                    obj_data.put('discard','');
                end loop;
            end if;
            obj_data.put('remark',i.remarkadj);
            --adjust
            obj_data.put('dteyreap',b_index_dteyreap);
            obj_data.put('numtime',b_index_numtime);
            obj_data.put('codbon',b_index_codbon);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;--flgpass
    end loop; --c1
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

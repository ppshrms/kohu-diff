--------------------------------------------------------
--  DDL for Package Body HRAP16X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP16X" is
-- last update: 02/06/2021 11:00

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

    b_index_dteyreap      := to_number(hcm_util.get_string_t(json_obj,'p_dteyear'));
    b_index_numtime       := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    b_index_codcomp       := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codaplvl      := hcm_util.get_string_t(json_obj,'p_codcodec');
    b_index_codempid      := hcm_util.get_string_t(json_obj,'p_codempid');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
    v_staemp        varchar2(1 char);
  begin
    initial_value(json_str_input);

--#4412
    if b_index_codempid is not null then
      begin
        select staemp into v_staemp
          from temploy1
         where codempid = b_index_codempid;

        if v_staemp = '9' then
            param_msg_error := get_error_msg_php('HR2101', global_v_lang, 'temploy1');
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;
      exception when no_data_found then null;
      end;
    end if;
--#4412

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
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_codempid      varchar2(100 char) := '!@#$';
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_seqno         number := 0;


    cursor c1 is
        select codempid,numseq,codapman,codposap,codcompap,codaplvl,flgapman,dteyreap,numtime
          from tappfm
         where dteyreap = b_index_dteyreap
           and numtime = b_index_numtime
           and codcomp like b_index_codcomp||'%'
           and codaplvl = nvl(b_index_codaplvl,codaplvl)
           and codempid = nvl(b_index_codempid,codempid)
        order by codaplvl,codempid,numseq;

  begin
    obj_row := json_object_t();
    if b_index_codempid is not null then
        for i in c1 loop
            v_flgdata := 'Y';
            flgpass := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
            if flgpass then
                v_flgsecu := 'Y';
                v_rcnt := v_rcnt+1;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('desc_codapman', get_temploy_name(i.codapman,global_v_lang));
                obj_data.put('desc_codcomp', get_tcenter_name(i.codcompap,global_v_lang));
                obj_data.put('desc_codpos', get_tpostn_name(i.codposap,global_v_lang));
                obj_data.put('desc_form', get_tlistval_name('FLGDISP',i.flgapman,global_v_lang));

                obj_data.put('codempid', i.codempid);
                obj_data.put('dteyreap', i.dteyreap);
                obj_data.put('numtime', i.numtime);
                obj_data.put('numseq', i.numseq);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;
        end loop;
    else
        for i in c1 loop
            v_flgdata := 'Y';
            flgpass := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
            if flgpass then
                v_flgsecu := 'Y';
                v_rcnt := v_rcnt+1;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                if v_codempid <> i.codempid then
                    v_codempid := i.codempid;
                    v_seqno := v_seqno+1;
                end if;
                obj_data.put('seqno', v_seqno);
                obj_data.put('codcodec', get_tcodec_name('TCODAPLV',i.codaplvl,global_v_lang));
                obj_data.put('codempid', i.codempid);
                obj_data.put('desc_codempid', get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('numseq', i.numseq);
                obj_data.put('desc_codapman', get_temploy_name(i.codapman,global_v_lang));
                obj_data.put('desc_codcomp', get_tcenter_name(i.codcompap,global_v_lang));
                obj_data.put('desc_codpos', get_tpostn_name(i.codposap,global_v_lang));
                obj_data.put('desc_form', get_tlistval_name('FLGDISP',i.flgapman,global_v_lang));

                obj_data.put('dteyreap', i.dteyreap);
                obj_data.put('numtime', i.numtime);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;
        end loop;
    end if;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappfm');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --
  procedure get_data_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_detail(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    obj_rowmain     json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	  boolean;
    v_zupdsal   	  varchar2(4);
    v_chksecu       varchar2(1);
    v_chk           number;
    v_codpos        temploy1.codpos%type;
    v_jobgrade      temploy1.jobgrade%type;

    cursor c1 is
        select codempid,numseq,codapman,codposap,codcompap,codaplvl,flgapman
          from tappfm
         where dteyreap = b_index_dteyreap
           and numtime = b_index_numtime
           and codcomp like b_index_codcomp||'%'
           and codaplvl = nvl(b_index_codaplvl,codaplvl)
           and codempid = nvl(b_index_codempid,codempid)
        order by codaplvl,codempid,numseq;
  begin
    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codaplvl', i.codaplvl||'-'||get_tcodec_name('TCODAPLV',i.codaplvl,global_v_lang));
            exit;
        end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappfm');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_data.to_clob;
    end if;
  end;
  --
end;

/

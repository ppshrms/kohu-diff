--------------------------------------------------------
--  DDL for Package Body HRAP38X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP38X" is
-- last update: 25/08/2020 12:12

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
    b_index_year        := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index_detail(json_str_output out clob) is
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
      select codempid,codcomp,codtrn,dteeffec,codappr,dteappr
        from ttranpm
       where dteyreap = b_index_year
         and codempid = nvl(b_index_codempid,codempid)
         and codcomp like b_index_codcomp||'%'
      order by codcomp,codempid;

  begin
    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('year',b_index_year);
            if b_index_codcomp is null then
                obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
            else
                obj_data.put('desc_codcomp',get_tcenter_name(b_index_codcomp,global_v_lang));
            end if;

            obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
            obj_data.put('desc_codtrn',get_tcodec_name('TCODMOVE',i.codtrn,global_v_lang));
            obj_data.put('dteappr',to_char(i.dteeffec,'dd/mm/yyyy'));
            if i.codappr is not null then
                obj_data.put('desc_codappr',i.codappr||' - '||get_temploy_name(i.codappr,global_v_lang));
            else
                obj_data.put('desc_codappr','');
            end if;
            exit;
        end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttranpm');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_data.to_clob;
    end if;
  end;
  --
  procedure get_index_table(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index_table(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

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
      select codempid,codcomp,amtsal,amtsaln,pctnet,remarkap,dteyreap,dteeffec
        from ttranpm
       where dteyreap = b_index_year
         and codempid = nvl(b_index_codempid,codempid)
         and codcomp like b_index_codcomp||'%'
      order by codcomp,codempid;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            begin
                select codpos,jobgrade
                  into v_codpos,v_jobgrade
                  from temploy1
                 where codempid = i.codempid;
            exception when no_data_found then
                v_codpos := null;
                v_jobgrade := null;
            end;
            obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
            obj_data.put('desc_jobgrade',get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang));
            obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
            if v_zupdsal = 'Y' then
                obj_data.put('amtsal',to_char(stddec(i.amtsal,i.codempid,v_chken),'fm999,999,990.00'));
                obj_data.put('amtsaln',to_char(stddec(i.amtsaln,i.codempid,v_chken),'fm999,999,990.00'));
            else
                obj_data.put('amtsal','0.00');
                obj_data.put('amtsaln','0.00');
            end if;
            obj_data.put('pctnet',to_char(i.pctnet,'fm999,999,990.00'));
            obj_data.put('remarkap',i.remarkap);
            obj_data.put('dteyreap',i.dteyreap);   
            obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));  
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttranpm');
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

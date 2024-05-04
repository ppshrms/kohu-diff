--------------------------------------------------------
--  DDL for Package Body HRAP24X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP24X" is
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
    b_index_dteyear     := to_number(hcm_util.get_string_t(json_obj,'p_dteyear'));
    b_index_numtime     := to_number(hcm_util.get_string_t(json_obj,'p_numtime'));
    b_index_codincom    := hcm_util.get_string_t(json_obj,'p_codincom');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_typrep      := nvl(hcm_util.get_string_t(json_obj,'p_typrep'),'1');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --

  procedure check_index is
     v_codpay   varchar2(4 char);
  begin

    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_codincom is not null then
      begin
        select codpay
          into v_codpay
          from tinexinf
         where codpay = b_index_codincom;
      exception when no_data_found then
        v_codpay := null;
      end;
      if v_codpay is null then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tinexinf');
        return;
      end if;
    end if;
  end;
  --

  procedure get_index_tableAdjust(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_tableAdjust(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_index_tableAdjust(json_str_output out clob)
  is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_chksecu       varchar2(1);
    v_chk           number;
    v_codpos        temploy1.codpos%type;
    v_jobgrade      temploy1.jobgrade%type;

    cursor c1 is
      select dteyreap ,numtime ,codcomadj ,codincom ,dteadjin
        from ttemadj1
       where dteyreap  =  nvl(b_index_dteyear,dteyreap)
         and numtime   =  nvl(b_index_numtime,numtime)
         and codcomadj =  nvl(b_index_codcomp,codcomadj)
         and codincom  =  nvl(b_index_codincom,codincom)
    order by dteyreap ,numtime ,codcomadj ,codincom ;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur7(i.codcomadj,global_v_coduser);
        --flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('dteyear',i.dteyreap);
            obj_data.put('numtime',i.numtime);
            obj_data.put('codcomp',i.codcomadj);
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomadj ,global_v_lang));
            obj_data.put('codincom',i.codincom);
            obj_data.put('desc_codincom',get_tinexinf_name(i.codincom ,global_v_lang));
            obj_data.put('dteadjin',to_char(i.dteadjin,'dd/mm/yyyy'));
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttemadj1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --

  procedure get_index_tableDesc (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_tableDesc(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_index_tableDesc (json_str_output out clob)
    is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_chksecu       varchar2(1);
    v_chk           number;
    v_codpos        temploy1.codpos%type;
    v_jobgrade      temploy1.jobgrade%type;
    v_amtincod      number;
    v_amt_percent   number;
    v_amtadj        number;
    v_amtincnw      number;
    cursor c1 is
       select a.codcomp ,a.codempid ,a.amtincod ,a.amtadj ,a.amtincnw ,a.numlvl , 
              a.numtime, a.dteyreap, a.codincom,a.codcomadj,
              a.codpos ,a.jobgrade ,b.dteempmt ,c.staappr ,a.rowid
          from ttemadj2 a,temploy1 b,ttemadj1 c
         where a.dteyreap = b_index_dteyear
           and a.numtime  = b_index_numtime
           and a.codincom = b_index_codincom
           and a.codcomp  like b_index_codcomp||'%'
           and a.codempid = b.codempid
           and a.dteyreap = c.dteyreap
           and a.numtime  = c.numtime
           and a.codincom = c.codincom
           and a.codcomadj = c.codcomadj
        order by a.codcomp,a.codempid,a.dteyreap,a.codincom,a.numtime;

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
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('codpos',i.codpos);
            obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('numlvl',i.numlvl);
            obj_data.put('desc_jobgrade',get_tcodec_name('TCODJOBG',i.jobgrade,global_v_lang));
            obj_data.put('dteempmt',to_char(i.dteempmt,'dd/mm/yyyy'));
            obj_data.put('numtime',i.numtime);
            obj_data.put('dteyreap',i.dteyreap);
            obj_data.put('codincom',i.codincom);
            obj_data.put('codcomadj',i.codcomadj);
            if v_zupdsal = 'Y' then
                v_amtincod := stddec(i.amtincod,i.codempid,v_chken);
                v_amtadj := stddec(i.amtadj,i.codempid,v_chken);
                v_amtincnw := stddec(i.amtincnw,i.codempid,v_chken);
--                v_amt_percent := to_char((stddec(i.amtadj,i.codempid,v_chken)/stddec(i.amtincod,i.codempid,v_chken)) * 100,'fm990.00');
                if v_amtincod <> 0 then
                  v_amt_percent := (v_amtadj/v_amtincod) * 100;
                else
                  v_amt_percent := 0;
                end if;
                obj_data.put('amtincod',to_char(v_amtincod,'fm9,999,990.00'));--User37 #3843 Demo Test V.11 24/12/2020 obj_data.put('amtincod',v_amtincod);
                obj_data.put('amt_percent',to_char(v_amt_percent,'fm9,990.00'));
                obj_data.put('amtadj',to_char(v_amtadj,'fm9,999,990.00'));--User37 #3843 Demo Test V.11 24/12/2020 obj_data.put('amtadj',v_amtadj);
                obj_data.put('amtincnw',to_char(v_amtincnw,'fm9,999,990.00'));--User37 #3843 Demo Test V.11 24/12/2020 obj_data.put('amtincnw',v_amtincnw);
            elsif v_zupdsal = 'N' then
                obj_data.put('amtincod','');
                obj_data.put('amt_percent','');
                obj_data.put('amtadj','');
                obj_data.put('amtincnw','');
            end if;
            obj_data.put('staappr',i.staappr);
            obj_data.put('desc_staappr',get_tlistval_name('STAAPPR',i.staappr,global_v_lang));
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttemadj2');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure get_index_tableSum (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_tableSum(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_index_tableSum (json_str_output out clob)
    is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_chksecu       varchar2(1);
    v_chk           number;
    v_codpos        temploy1.codpos%type;
    v_jobgrade      temploy1.jobgrade%type;

    cursor c1 is
        select codcomp ,count(codempid) numemp ,
               sum(nvl(stddec(amtincod,codempid,v_chken),0)) amtincod ,
               sum(nvl(stddec(amtadj,codempid,v_chken),0))   amtadj ,
               sum(nvl(stddec(amtincnw,codempid,v_chken),0)) amtincnw,
               dteyreap, numtime, codincom, codcomadj
          from ttemadj2
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codincom = b_index_codincom
           and codcomp  like b_index_codcomp||'%'
	       /*
           and exists(select b.codcomp
                       from ttusrcom b
                      where b.coduser = global_v_coduser
                        and ttemadj2.codcomp like b.codcomp||'%')
           */
           and numlvl between global_v_zminlvl and global_v_zwrklvl
           group by codcomp, dteyreap, codincom, numtime, codcomadj
           order by codcomp,dteyreap,codincom,numtime ;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur7(i.codcomp,global_v_coduser);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codcomp',hcm_util.get_codcomp_level(i.codcomp,null,'-','Y'));
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('numemp',i.numemp);
            obj_data.put('amtincod',i.amtincod);
            obj_data.put('amtadj',i.amtadj);
            obj_data.put('amtincnw',i.amtincnw);
            obj_data.put('dteyreap',i.dteyreap);
            obj_data.put('numtime',i.numtime);
            obj_data.put('codincom',i.codincom);
            obj_data.put('codcomadj',i.codcomadj);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttemadj2');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

end;

/

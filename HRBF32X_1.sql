--------------------------------------------------------
--  DDL for Package Body HRBF32X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF32X" AS

  procedure initial_value(json_str_input in clob) as
   json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomp       := hcm_util.get_string(json_obj,'p_codcomp');
        p_numisr        := hcm_util.get_string(json_obj,'p_numisr');
        p_flgchng       := hcm_util.get_string(json_obj,'p_flgchng');
        p_dtechngst     := to_date(hcm_util.get_string(json_obj,'p_dtechngst'),'dd/mm/yyyy');
        p_dtechngen     := to_date(hcm_util.get_string(json_obj,'p_dtechngen'),'dd/mm/yyyy');

  end initial_value;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
--  check null parameters
    if p_codcomp is null or p_numisr is null or p_flgchng is null or p_dtechngst is null or p_dtechngen is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp||'%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
    end;

--  check secure7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

    begin
        select 'X' into v_temp
        from tisrinf
        where numisr = p_numisr
          and codcompy like hcm_util.get_codcomp_level(p_codcomp,1) || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TISRINF');
        return;
    end;

--  check numisr
    begin
        select 'X' into v_temp
        from tisrinf
        where numisr = p_numisr;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tisrinf');
        return;
    end;

    if p_dtechngst > p_dtechngen then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

  end check_index;

  procedure get_data_emp_new(obj_rows in out json,v_count in out number,v_secur_count in out number) as
    obj_data        json;
    v_chk_secur     boolean := false;
    v_row           number := 0;
    cursor c1 is
        select codempid,v_seq,v_name v_name,v_typrelate,codisrpo,
               codisrp,amtisrpo,amtisrp,dtehlpsto,dtehlpeno,dtehlpst,dtehlpen,dteeffec,
               ord_numseq
        from(
             select a.codempid,1 as v_seq,get_temploy_name(a.codempid,global_v_lang) as v_name,'E' as v_typrelate,
                    null as codisrpo,a.codisrp,null as amtisrpo,a.amtisrp,null as dtehlpsto,null as dtehlpeno,a.dtehlpst,a.dtehlpen,a.dtehlpst as dteeffec,
                    0 ord_numseq
             from tinsrer a,temploy1 b
             where a.codempid = b.codempid
               and b.codcomp like p_codcomp || '%'
               and a.numisr = p_numisr
               and a.dtehlpst between p_dtechngst and p_dtechngen
               and a.flgemp = '1'
        union
            select a.codempid,2 as v_seq,b.nameinsr as v_name,b.typrelate,
                   a.codisrpo,a.codisrp,a.amtisrpo,a.amtisrp,a.dtehlpsto,a.dtehlpeno,a.dtehlpst,a.dtehlpen,a.dteeffec,
                   b.numseq ord_numseq
            from tchgins1 a, tchgins2 b, temploy1 c
            where a.codempid = c.codempid
              and a.codempid = b.codempid
              and a.numisr = b.numisr
              and a.dtechng = b.dtechng
              and c.codcomp like p_codcomp || '%'
              and a.numisr = p_numisr
              and b.flgchng = p_flgchng
              and a.dtechng between p_dtechngst and p_dtechngen
        )
    order by codempid,v_seq,ord_numseq,codisrpo,dteeffec;
  begin
    obj_rows := json();
    for i in c1 loop
        v_count := v_count + 1;
        v_chk_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if v_chk_secur then
            v_secur_count := v_secur_count + 1;
            v_row := v_row + 1;
            obj_data := json();
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('recipient_name',i.v_name);
            obj_data.put('typrelate',i.v_typrelate);
            --<<User37 #5750 5. BF Module 21/04/2021
            --obj_data.put('typrelate_name',get_tlistval_name('TYPRELATE',i.v_typrelate,global_v_lang));
            obj_data.put('typrelate_name',get_tlistval_name('TYPERELATE',i.v_typrelate,global_v_lang));
            -->>User37 #5750 5. BF Module 21/04/2021
            obj_data.put('codisrpo',get_tcodec_name('TCODISRP',i.codisrpo,global_v_lang));
            obj_data.put('codisrp',get_tcodec_name('TCODISRP',i.codisrp,global_v_lang));
            obj_data.put('amtisrpo',i.amtisrpo);
            obj_data.put('amtisrp',i.amtisrp);
            obj_data.put('old_insurance_period','');
            obj_data.put('new_insurance_period',(i.dtehlpen-i.dtehlpst) + 1);
            obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;
  end;

  procedure get_data_emp_resign(obj_rows in out json,v_count in out number,v_secur_count in out number) as
    obj_data        json;
    v_chk_secur     boolean := false;
    v_row           number := 0;
    cursor c1 is
        select codempid,v_seq,v_name v_name,v_typrelate,codisrpo,
               codisrp,amtisrpo,amtisrp,dtehlpsto,dtehlpeno,dtehlpst,dtehlpen,dteeffec,
               ord_numseq
        from(
             select a.codempid,1 as v_seq,get_temploy_name(a.codempid,global_v_lang) as v_name,'E' as v_typrelate,
                    a.codisrpo,a.codisrp,a.amtisrpo,a.amtisrp,a.dtehlpsto,a.dtehlpeno,a.dtehlpst,a.dtehlpen,a.dteeffec,
                    0 ord_numseq
             from tchgins1 a,temploy1 b
             where b.codcomp like p_codcomp || '%'
               and a.codempid = b.codempid
               and a.numisr = p_numisr
               and a.flgchng = p_flgchng
               and a.dtechng between p_dtechngst and p_dtechngen
        union
            select a.codempid,2 as v_seq,b.nameinsr as v_name,b.typrelate,
                   a.codisrpo,a.codisrp,a.amtisrpo,a.amtisrp,a.dtehlpsto,a.dtehlpeno,a.dtehlpst,a.dtehlpen,a.dteeffec,
                   b.numseq ord_numseq
            from tchgins1 a, tchgins2 b, temploy1 c
            where a.codempid = b.codempid
              and a.numisr = b.numisr
              and a.dtechng = b.dtechng
              and c.codcomp like p_codcomp || '%'
              and a.codempid = c.codempid
              and a.numisr = p_numisr
              and b.flgchng = p_flgchng
              and a.dtechng between p_dtechngst and p_dtechngen
        )
        order by codempid,v_seq, ord_numseq, codisrpo,dteeffec;
  begin
    obj_rows := json();
    for i in c1 loop
        v_count := v_count + 1;
        v_chk_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if v_chk_secur then
            v_secur_count := v_secur_count + 1;
            v_row := v_row + 1;
            obj_data := json();
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('recipient_name',i.v_name);
            obj_data.put('typrelate',i.v_typrelate);
            --<<User37 #5750 5. BF Module 21/04/2021
            --obj_data.put('typrelate_name',get_tlistval_name('TYPRELATE',i.v_typrelate,global_v_lang));
            obj_data.put('typrelate_name',get_tlistval_name('TYPERELATE',i.v_typrelate,global_v_lang));
            -->>User37 #5750 5. BF Module 21/04/2021
            obj_data.put('codisrpo',get_tcodec_name('TCODISRP',i.codisrpo,global_v_lang));
            obj_data.put('codisrp',get_tcodec_name('TCODISRP',i.codisrp,global_v_lang));
            obj_data.put('amtisrpo',i.amtisrpo);
            obj_data.put('amtisrp',i.amtisrp);
            obj_data.put('old_insurance_period',(i.dtehlpeno-i.dtehlpsto)+1);
            obj_data.put('new_insurance_period','');
            obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;
  end;

  procedure get_data_emp_change(obj_rows in out json,v_count in out number,v_secur_count in out number) as
    obj_data        json;
    v_chk_secur     boolean := false;
    v_row           number := 0;
    cursor c1 is
        select a.codempid, get_temploy_name(a.codempid,global_v_lang) as v_name,'E' as v_typrelate,
               codisrp,amtisrpo,amtisrp,dtehlpsto,dtehlpeno,dtehlpst,dtehlpen,dteeffec,codisrpo
        from tchgins1 a, temploy1 c
        where a.codempid = c.codempid
          and c.codcomp like p_codcomp || '%'
          and a.numisr = p_numisr
          and a.dtechng between  p_dtechngst and p_dtechngen
          and a.flgchng = p_flgchng
          and(nvl(a.codisrpo, '!@#') <> nvl(a.codisrp, '!@#')
           or nvl(a.amtisrpo, 999999999999999) <> nvl(a.amtisrp,999999999999999)
           or nvl(a.dtehlpsto, to_date('01/01/1111', 'dd/mm/yyyy')) <> nvl(a.dtehlpst, to_date('01/01/1111', 'dd/mm/yyyy'))
           or nvl(a.dtehlpeno, to_date('01/01/1111', 'dd/mm/yyyy')) <> nvl(a.dtehlpen, to_date('01/01/1111', 'dd/mm/yyyy')))
        order by codempid, dteeffec;
  begin
    obj_rows := json();
    for i in c1 loop
        v_count := v_count + 1;
        v_chk_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if v_chk_secur then
            v_secur_count := v_secur_count + 1;
            v_row := v_row + 1;
            obj_data := json();
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('recipient_name',i.v_name);
            obj_data.put('typrelate',i.v_typrelate);
            --<<User37 #5750 5. BF Module 21/04/2021
            --obj_data.put('typrelate_name',get_tlistval_name('TYPRELATE',i.v_typrelate,global_v_lang));
            obj_data.put('typrelate_name',get_tlistval_name('TYPERELATE',i.v_typrelate,global_v_lang));
            -->>User37 #5750 5. BF Module 21/04/2021
            obj_data.put('codisrpo',get_tcodec_name('TCODISRP',i.codisrpo,global_v_lang));
            obj_data.put('codisrp',get_tcodec_name('TCODISRP',i.codisrp,global_v_lang));
            obj_data.put('amtisrpo',i.amtisrpo);
            obj_data.put('amtisrp',i.amtisrp);            
            obj_data.put('old_insurance_period',trunc(i.dtehlpeno - i.dtehlpsto)+1); --#8215 || 17/08/2022
            obj_data.put('new_insurance_period',trunc(i.dtehlpen - i.dtehlpst)+1); --#8215 || 17/08/2022
            obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;
  end;

  procedure gen_index(json_str_output out clob) as
    obj_data       json;
    obj_rows       json;
    v_row          number := 0;
    v_chk_secur    boolean := false;
    v_count        number := 0;
    v_secur_count  number := 0;
  begin
    obj_rows := json();
    if p_flgchng = '1' then
        get_data_emp_new(obj_rows,v_count,v_secur_count);
    elsif p_flgchng = '2' then
        get_data_emp_resign(obj_rows,v_count,v_secur_count);
    elsif p_flgchng = '3' then
        get_data_emp_change(obj_rows,v_count,v_secur_count);
    end if;

    if v_count != 0 and v_secur_count = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    if v_count = 0 then
        if p_flgchng = '1' then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tinsrer');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        elsif p_flgchng in ('2','3') then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tchgins1');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
    end if;

--    if v_count = 0 then
--        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tchgins1');
--        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--        return;
--    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index;

END HRBF32X;

/

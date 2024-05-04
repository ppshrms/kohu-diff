--------------------------------------------------------
--  DDL for Package Body HRBF1HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1HX" as

  procedure initial_value(json_str_input in clob) as
    json_obj    json;
  begin
    json_obj            := json(json_str_input);

    --global
    global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
    global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');

    p_codcomp           := hcm_util.get_string(json_obj, 'p_codcomp');
    p_syncond           := hcm_util.get_string(json_obj, 'p_syncond');
    p_dteyear           := hcm_util.get_string(json_obj, 'p_dteyear');
    p_dtemonthfr        := hcm_util.get_string(json_obj, 'p_dtemonthfr');
    p_dteyearfr         := hcm_util.get_string(json_obj, 'p_dteyearfr');
    p_dtemonthto        := hcm_util.get_string(json_obj, 'p_dtemonthto');
    p_dteyearto         := hcm_util.get_string(json_obj, 'p_dteyearto');
    p_typamt            := hcm_util.get_string(json_obj, 'p_typamt');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) as
    obj_row              json    := json();
    obj_data             json;
    v_dtestrt            date;
    v_dteend             date;
    v_rcnt               number := 1;
    v_count_tcenter      number;
    v_flg_exist          boolean := false;
    v_flg_secure         boolean := false;
    v_flg_permission     boolean := false;
    v_stmt               clob;
    v_syncond            varchar2(4000 char) := '';
    v_namimage           tempimge.namimage%type;
    v_codempid           taccmexp.codempid%type;
    v_typamt             taccmexp.typamt%type;
    v_strqry_typamt      varchar2(100 char);
    v_codpos             temploy1.codpos%type;
    v_jobgrade           temploy1.jobgrade%type;
    v_typemp             temploy1.typemp%type;
    v_codempmt           temploy1.codempmt%type;
    v_numlvl             temploy1.numlvl%type;
    v_sum_amtwidrwt_emp  number;
    v_sum_amtsumin_emp   number;
    v_emp_balance        number;
    v_sum_amtwidrwt_fam  number;
    v_sum_amtsumin_fam   number;
    v_fmy_balance        number;
    v_stround            varchar2(10 char);
    v_enround            varchar2(10 char);

    dynamicCursor        sys_refcursor;

  begin
    -- validate date input
    v_dtestrt := to_date(p_dtemonthfr||'/'||p_dteyearfr, 'mm/yyyy');
    v_dteend  := to_date(p_dtemonthto||'/'||p_dteyearto, 'mm/yyyy');
    if v_dteend < v_dtestrt then
        param_msg_error := get_error_msg_php('HR2022',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    -- check codcomp exist in tcenter
    begin
        select count(codcomp)
          into v_count_tcenter
          from tcenter
         where codcomp like p_codcomp||'%'
           and rownum = 1;
    end;
    if v_count_tcenter = 0 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    -- check date input and budget fiscal date
    if p_dteyear is not null then
        begin
           select p_dteyear||'/'||lpad(mthbfst,2,'0'),
                  p_dteyear||'/'||lpad(mthbfen,2,'0')
             into v_stround, v_enround
             from tcontrbf
            where codcompy = get_codcompy(get_compful(p_codcomp))
              and dteeffec = ( select max(dteeffec)
                                 from tcontrbf
                                where codcompy = get_codcompy(get_compful(p_codcomp))
                                  and dteeffec <= trunc(sysdate)
                              );
        exception when no_data_found then
                  null;
        end;
    end if;

    if substr(v_enround,6) < substr(v_stround,6) then
        v_enround := substr(v_enround,1,4) + 1||substr(v_enround,5);
    end if;

    if p_dteyearfr||'/'||lpad(p_dtemonthfr,2,'0') < v_stround or p_dteyearto||'/'||lpad(p_dtemonthto,2,'0') > v_enround then
        param_msg_error := get_error_msg_php('BF0062',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    -- secur_main.secur7
    v_flg_secure := secur_main.secur7(p_codcomp, global_v_coduser);
    if not v_flg_secure then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    if p_syncond is not null then
        v_syncond := p_syncond;
        v_syncond := replace(v_syncond,'TEMPLOY1.');
    else
        v_syncond := ' 1=1 ';
    end if;

    if p_typamt = 'Z' or p_typamt is null then
        v_strqry_typamt := ' 1=1 ';
    else
        v_strqry_typamt := ' typamt = nvl('''||p_typamt ||''', typamt) ';
    end if;

    v_stmt := ' select a.codempid,typamt,codpos,jobgrade,typemp,codempmt,numlvl,
                       sum(decode(typrelate ,''E'',amtwidrwt,0)) sum_amtwidrwt_emp,
                       sum(decode(typrelate ,''E'',amtsumin,0))  sum_amtsumin_emp,
                       sum(decode(typrelate ,''E'',0,amtwidrwt)) sum_amtwidrwt_fam,
                       sum(decode(typrelate ,''E'',0,amtsumin))  sum_amtsumin_fam
                  from taccmexp a, temploy1 b
                 where a.codempid = b.codempid
                   and a.codcomp like ''' || p_codcomp || '%''' ||
                 ' and dteyre||''/''||lpad(dtemonth,2,''0'') between ' || p_dteyearfr ||'||''/''||lpad(' || p_dtemonthfr || ',2,''0'') and '||
                                                                          p_dteyearto ||'||''/''||lpad(' || p_dtemonthto || ',2,''0'')' ||
                 ' and (' || v_strqry_typamt || ')' ||
                 ' and (' || v_syncond || ')' ||
                 ' group by a.codempid,typamt,codpos,jobgrade,typemp,codempmt,numlvl ' ||
                 ' order by a.codempid,typamt,codpos,jobgrade,typemp,codempmt,numlvl';

    open dynamicCursor for v_stmt;
    loop
        fetch dynamicCursor into v_codempid,v_typamt,v_codpos,v_jobgrade,v_typemp,v_codempmt,v_numlvl,
                                 v_sum_amtwidrwt_emp,v_sum_amtsumin_emp,v_sum_amtwidrwt_fam,v_sum_amtsumin_fam;
        exit when dynamicCursor%notfound;
            v_flg_exist := true;
            -- secur_main.secur2
            v_flg_secure := secur_main.secur2(v_codempid,global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
            if v_flg_secure then
                v_flg_permission := true;
                begin
                    select  namimage
                    into    v_namimage
                    from    tempimge
                    where   codempid = v_codempid;
                exception when no_data_found then
                    v_namimage := v_codempid;
                end;
                obj_data := json();
                obj_data.put('namimge', v_namimage);
                obj_data.put('codempid', v_codempid);
                obj_data.put('namempid', get_temploy_name(v_codempid, global_v_lang));
                obj_data.put('desc_typamt', get_tlistval_name('TYPAMT',v_typamt,global_v_lang));
                obj_data.put('foremp', get_label_name('HRBF1HXC2', global_v_lang, '50'));
                obj_data.put('feamt', nvl(v_sum_amtwidrwt_emp,0));
                obj_data.put('feamtacc', nvl(v_sum_amtsumin_emp,0));
                obj_data.put('feamtbalance', nvl(v_sum_amtwidrwt_emp - v_sum_amtsumin_emp,0));
                obj_data.put('forfmy', get_label_name('HRBF1HXC2', global_v_lang, '60'));
                obj_data.put('ffamt', nvl(v_sum_amtwidrwt_fam,0));
                obj_data.put('ffamtacc', nvl(v_sum_amtsumin_fam,0));
                obj_data.put('ffamtbalance', nvl(v_sum_amtwidrwt_fam - v_sum_amtsumin_fam,0));
                obj_row.put(to_char(v_rcnt-1),obj_data);
                v_rcnt := v_rcnt + 1;
            end if;
    end loop;
    close dynamicCursor;

    -- check exist by search condition
    if not v_flg_exist then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TACCMEXP');
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;

    -- check permission
    if not v_flg_permission and v_flg_exist then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
     param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
     json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;

end HRBF1HX;


/

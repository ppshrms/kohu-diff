--------------------------------------------------------
--  DDL for Package Body HRPM8AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM8AX" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');


    pa_codempid               :=  hcm_util.get_string_t(json_obj,'pa_codempid');
    pa_codcomp                :=  hcm_util.get_string_t(json_obj,'pa_codcomp');
    pa_logical_json           :=  hcm_util.get_json_t(json_obj,'pa_logical');
    pa_logical                :=  hcm_util.get_string_t(pa_logical_json,'code');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;



  procedure get_index(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
  begin
    initial_value(json_str_input);
    vadidate_variable_getindex(json_str_input);
    if param_msg_error is null then
        gen_index(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  end;

   procedure vadidate_variable_getindex(json_str_input in clob) as
    chk_bool boolean;
    tmp      varchar(1000);
  BEGIN
        if pa_codcomp  is not null and pa_codempid is not null then
          pa_codcomp := '';
        end if;

        if (pa_codcomp is null and pa_codempid is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
            return ;
        end if;

        if (pa_codcomp is not null) then
        begin
           select codcomp into tmp
            from tcenter
           where codcomp like pa_codcomp||'%'
           and rownum <=1;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'');
          return;
        end;
        end if;

        if (pa_codempid is not null and pa_codempid <> '') then
        begin
           select codempid into tmp
            from temploy1
           where codempid = pa_codempid
           and rownum <=1;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'');
          return;
        end;
        end if;

        if (pa_codempid is not null and pa_logical is not null) then
            pa_logical := '';
        end if;

       if (pa_codcomp is not null) then
       param_msg_error := HCM_SECUR.SECUR_CODCOMP(global_v_coduser,global_v_lang,pa_codcomp);
       if(param_msg_error is not null ) then
       param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
        return;
       end if;
       end if;

       if (pa_codempid is not null) then
       chk_bool := secur_main.secur2(pa_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
       if(chk_bool = false ) then
       param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
        return;
       end if;
       end if;

  END vadidate_variable_getindex;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_sql_statement varchar2(4000);
    v_data_exist    boolean := false;
    v_codempid      v_hrpm8a.codempid%TYPE;
    v_dteempmt      v_hrpm8a.dteempmt%TYPE;
    v_dterecv       v_hrpm8a.dterecv%TYPE;
    v_codcomp       v_hrpm8a.codcomp%TYPE;
    v_filedoc       v_hrpm8a.filedoc%TYPE;
    v_typdoc        v_hrpm8a.typdoc%TYPE;
    v_count         number := 0;
    v_cksecur       boolean;
    v_secur_codcomp temploy1.codcomp%TYPE;
    v_secur_numlvl  temploy1.numlvl%TYPE;
    v_numappl       v_hrpm8a.numappl%TYPE;
    v_numseq        v_hrpm8a.numseq%TYPE;
    --<<User37 #1773 Final Test Phase 1 V11 02/02/2021
    v_data          varchar2(1) := 'N';
    v_secur         varchar2(1) := 'N';
    -->>User37 #1773 Final Test Phase 1 V11 02/02/2021
    v_namdoc        v_hrpm8a.namdoc%TYPE;--User37 #1775 Final Test Phase 1 V11 02/02/2021
        --<<User37 #1775 Final Test Phase 1 V11 02/02/2021
        /*cursor c1 is select distinct a.codempid,a.dteempmt,a.dterecv,a.codcomp,a.filedoc,
                    a.numseq,a.TYPDOC,a.namdoc
                    from v_hrpm8a a
                    where a.codempid = nvl(pa_codempid,codempid)
                    and a.codcomp like nvl(pa_codcomp||'%','%');*/
        cursor c1 is
            select distinct a.codempid,a.dteempmt,a.dterecv,a.codcomp,a.filedoc,
                   a.numseq,a.TYPDOC,a.namdoc,a.numappl
              from v_hrpm8a a
             where a.codempid = nvl(pa_codempid,codempid)
               and a.codcomp like nvl(pa_codcomp||'%','%')
            order by a.codcomp,a.codempid;
        -->>User37 #1775 Final Test Phase 1 V11 02/02/2021


    TYPE  vhrpm8a_cursor IS REF CURSOR;
    vhrpm8a_cv     vhrpm8a_cursor;
    vhrpm8a_roc    v_hrpm8a%ROWTYPE;
    vhrpm8a_codempid  v_hrpm8a.codempid%TYPE;
    v_descret VARCHAR2(500);
    begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    if (pa_logical is null or pa_logical = ' ') then
      for r1 in c1 loop
        --<<User37 #1773 Final Test Phase 1 V11 02/02/2021
        v_data      := 'Y';
        v_cksecur   := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_cksecur then
            v_secur := 'Y';
            -->>User37 #1773 Final Test Phase 1 V11 02/02/2021
            v_rcnt      := v_rcnt+1;
            obj_data    := json_object_t();
            v_data_exist := true;

            obj_data.put('coderror', '200');
            obj_data.put('rcnt', to_char(v_rcnt));
            obj_data.put('image', get_emp_img( r1.codempid));
            obj_data.put('codempid', r1.codempid);
            obj_data.put('name', get_temploy_name( r1.codempid , global_v_lang));
            obj_data.put('dep', get_tcenter_name( r1.codcomp , global_v_lang));
            obj_data.put('dteen', to_char(r1.dteempmt,'dd/mm/yyyy'));
            obj_data.put('dtere', to_char(r1.dterecv,'dd/mm/yyyy') );
            obj_data.put('type', get_tcodec_name ('TCODTYDOC',r1.TYPDOC, global_v_lang));
            obj_data.put('file', nvl(r1.namdoc,r1.filedoc) );
            obj_data.put('path_filename', get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E')||'/'||r1.filedoc );

            obj_data.put('numappl',r1.numappl );
            obj_data.put('numseq', to_char(r1.numseq) );

            /*User37 #1773 Final Test Phase 1 V11 02/02/2021 if pa_codempid is not null then
            begin
            select codcomp,numlvl into v_secur_codcomp,v_secur_numlvl
            from temploy1
            where codempid = r1.codempid;
            end;
            v_secur := secur_main.secur1( v_secur_codcomp, v_secur_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if v_secur = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
            end if;
            end if;*/

            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
      end loop;
    else
      --<<User37 #1775 Final Test Phase 1 V11 02/02/2021
      --v_sql_statement := 'select codempid,dteempmt,dterecv,codcomp,nvl(namdoc,filedoc) filedoc,TYPDOC from v_hrpm8a V_HRPM8A where '||pa_logical;
      v_sql_statement := 'select distinct codempid,dteempmt,dterecv,codcomp,filedoc,namdoc,TYPDOC,numappl,numseq from v_hrpm8a V_HRPM8A where '||pa_logical||
                         ' and codempid = nvl('''||pa_codempid||''',codempid) and codcomp like nvl('''||pa_codcomp||'%'',''%'')'||' order by codcomp,codempid';
      -->>User37 #1775 Final Test Phase 1 V11 02/02/2021

      OPEN vhrpm8a_cv FOR v_sql_statement;
      loop
        --<<User37 #1775 Final Test Phase 1 V11 02/02/2021
        --FETCH vhrpm8a_cv INTO v_codempid,v_dteempmt,v_dterecv,v_codcomp,v_filedoc,v_typdoc;
        FETCH vhrpm8a_cv INTO v_codempid,v_dteempmt,v_dterecv,v_codcomp,v_filedoc,v_namdoc,v_typdoc,v_numappl,v_numseq;
        -->>User37 #1775 Final Test Phase 1 V11 02/02/2021
        EXIT WHEN vhrpm8a_cv%NOTFOUND;
        --<<User37 #1773 Final Test Phase 1 V11 02/02/2021
        v_data      := 'Y';
        v_cksecur   := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_cksecur then
            v_secur := 'Y';
            -->>User37 #1773 Final Test Phase 1 V11 02/02/2021
            v_data_exist := true;
            v_rcnt      := v_rcnt+1;
            obj_data    := json_object_t();

            obj_data.put('coderror', '200');
            obj_data.put('rcnt', to_char(v_rcnt));
            obj_data.put('image', get_emp_img( v_codempid));
            obj_data.put('codempid', v_codempid);
            obj_data.put('name', get_temploy_name( v_codempid , global_v_lang));
            obj_data.put('dep', get_tcenter_name( v_codcomp , global_v_lang));
            obj_data.put('dteen', to_char(v_dteempmt,'dd/mm/yyyy'));
            obj_data.put('dtere', to_char(v_dterecv,'dd/mm/yyyy') );
            obj_data.put('type', get_tcodec_name ('TCODTYDOC',v_TYPDOC, global_v_lang));
            --<<User37 #1775 Final Test Phase 1 V11 02/02/2021
            --obj_data.put('file', v_filedoc );
            obj_data.put('file', nvl(v_namdoc,v_filedoc) );
            -->>User37 #1775 Final Test Phase 1 V11 02/02/2021
            obj_data.put('path_filename', get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E')||'/'||v_filedoc );

            obj_data.put('numappl', v_numappl );
            obj_data.put('numseq', v_numseq );

            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
      end loop;
    end if;

    --<<User37 #1773 Final Test Phase 1 V11 02/02/2021
    if v_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tappldoc');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_secur = 'N' then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
    /*if v_data_exist then
      json_str_output := obj_row.to_clob();
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'tappldoc');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;*/
    -->>User37 #1773 Final Test Phase 1 V11 02/02/2021
  end;

end HRPM8AX;

/

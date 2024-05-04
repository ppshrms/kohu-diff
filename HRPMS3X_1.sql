--------------------------------------------------------
--  DDL for Package Body HRPMS3X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMS3X" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;

  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    pa_codcomp          := hcm_util.get_string_t(json_obj,'pa_codcomp');
    pa_year             := hcm_util.get_string_t(json_obj,'pa_year');
    pa_month1           := hcm_util.get_string_t(json_obj,'pa_month1');
    pa_month2           := hcm_util.get_string_t(json_obj,'pa_month2');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure vadidate_variable_getindex(json_str_input in clob) as

   tmp      tcenter.codcomp%type;

  BEGIN
        if (pa_codcomp is null) OR (pa_year is null) OR (pa_month1 is null) OR (pa_month2 is null) then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return ;
        end if;


        if( to_number(pa_month1) > to_number(pa_month2) ) then
           param_msg_error := get_error_msg_php('HR2032',global_v_lang);
          return ;
        end if;


         if (pa_codcomp is not null) then
        begin
           select codcomp into tmp
            from tcenter
           where codcomp like pa_codcomp||'%'
           and rownum <=1;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'pa_codcomp');
          return;
        end;
        end if;

    if (pa_codcomp is not null) then
       param_msg_error := HCM_SECUR.SECUR_CODCOMP(global_v_coduser,global_v_lang,pa_codcomp);
       if(param_msg_error is not null ) then
         param_msg_error := get_error_msg_php('3007',global_v_lang, 'pa_codempid');
        return;
       end if;
    end if;

  END vadidate_variable_getindex;

  procedure get_index(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
  begin
    initial_value(json_str_input);
    vadidate_variable_getindex(json_str_input);

    if param_msg_error is null then
        gen_index(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_no            number := 0;
    t_year          number;
    t_month         number;
    t_day           number;
    v_dtestrt       date := to_date('01/'||pa_month1||'/'||pa_year,'dd/mm/yyyy');
    v_dtestrt2       date := to_date('01/'||pa_month2||'/'||pa_year,'dd/mm/yyyy');
    v_dteend        date := last_day(v_dtestrt2);
    v_month         number;
    count1          number := 0;
    count2          number := 0;
    count3          number := 0;
    count4          number := 0;
    sum_count       number := 0;
    month_eff_lasted   number := 0;
    v_codcomp       ttexempt.codcomp%type;
    v_codempid      ttexempt.codempid%type;
    v_secur         boolean := false;
    v_permission    boolean := false;
    v_data_exist    boolean := false;
    v_month_tmp     varchar2(100);
    v_month_code    varchar2(100);

    sql_stmt    varchar2(500);
    type nowemp is table of number index by binary_integer;
    graphval  nowemp;

    cursor c1 is
      select codempid,codcomp,dteeffec,totwkday,
             codexemp,to_number(to_char(dteeffec,'mm')) month_eff,
             GET_TPOSTN_NAME(codpos,global_v_lang) as codpos ,
             CASE FLGBLIST
              WHEN 'Y' THEN
              get_label_name('HRPMS3X',global_v_lang,5)
              WHEN 'N' THEN
              get_label_name('HRPMS3X',global_v_lang,6)
             END AS FLGBLIST,AMTSALT
        from ttexempt
       where codcomp like pa_codcomp||'%'
         and dteeffec between v_dtestrt and v_dteend
         and staupd in ('C','U')
       order by to_number(to_char(dteeffec,'mm')),codempid;

  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    begin
    DELETE FROM TTEMPRPT
    WHERE  CODAPP = 'HRPMS3X'
    AND CODEMPID = global_v_codempid;
    end;
    for r1 in c1 loop

      obj_data    := json_object_t();
      v_codcomp := r1.codcomp;
      v_codempid := r1.codempid;
      get_service_year(r1.dteeffec - r1.totwkday,r1.dteeffec,'Y',t_year, t_month, t_day);
      v_month := (to_char(t_year*12)+to_char(trunc(t_month,0)));

      v_data_exist := true;
      v_secur := secur_main.secur3(v_codcomp,v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

      if v_secur then
        v_permission := true;
        v_month_tmp := ltrim(r1.month_eff, '0');
        v_month_code := ltrim(r1.month_eff, '0');
        v_rcnt      := v_rcnt+1;
        begin
          sql_stmt := 'select desc_label
          from tlistval
          where codapp = :NAMMTHFUL
          and numseq = :mnseq
          and codlang = :global_v_lang
          order by numseq';
          execute immediate sql_stmt into v_month_tmp using 'NAMMTHFUL',v_month_tmp,global_v_lang;
        end;
        if month_eff_lasted <> r1.month_eff then
          v_no  := v_no + 1;
          month_eff_lasted := r1.month_eff;
        end if;
        obj_data.put('coderror', '200');
        obj_data.put('rcnt', to_char(v_rcnt));
        obj_data.put('no', v_no);
        obj_data.put('month', v_month_tmp);
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('dteext', to_char(r1.dteeffec,'dd/mm/yyyy'));
        obj_data.put('yearage', t_year);
        obj_data.put('monthage', t_month);
        obj_data.put('dayage', t_day);
        obj_data.put('reason', get_tcodec_name('TCODEXEM',r1.codexemp,global_v_lang));
        obj_data.put('p_codempid', global_v_codempid);
        obj_data.put('p_codcomp', v_codcomp);
        obj_data.put('p_dtestrt',to_char(v_dtestrt,'dd/mm/yyyy'));
        obj_data.put('p_dteend', to_char(v_dteend,'dd/mm/yyyy'));

        if v_month between 0 and 3 or (v_month = 4 and t_month + t_day = 0) then -- Adisak redmine#9334 28/04/2023 12:07
          count1 := count1+1;
        elsif v_month between 4 and 11 or (v_month = 12 and t_month + t_day = 0) then
          count2 := count2+1;
        elsif v_month between 12 and 35 or (v_month = 36 and t_month + t_day = 0) then
          count3 := count3+1;
        elsif v_month between 36 and 9999 then
          count4 := count4+1;
        end if;

        sum_count := count1+count2+count3+count4;
        obj_data.put('count1', count1 );
        obj_data.put('count2', count2 );
        obj_data.put('count3', count3 );
        obj_data.put('count4', count4 );
        obj_data.put('sum_count', sum_count );
        obj_row.put(to_char(v_rcnt-1),obj_data);

      end if;
    end loop;

    graphval(1) := count1;
    graphval(2) := count2;
    graphval(3) := count3;
    graphval(4) := count4;
    --graph
        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM4, ITEM5, ITEM7, ITEM8,ITEM9,ITEM10, ITEM31)
        VALUES (global_v_codempid,'HRPMS3X',1,
                '1',
                get_label_name('HRPMS3X1',global_v_lang,140),
                v_month_code,
--                v_month_tmp,
                get_label_name('HRPMS3X1',global_v_lang,90),
                get_label_name('HRPMS3X_GRAPH',global_v_lang,2),
                count1,
                get_label_name('HRPMS3X_GRAPH',global_v_lang,1)
                );

        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM4,ITEM5,ITEM7,ITEM8,ITEM9,ITEM10, ITEM31)
        VALUES (global_v_codempid,'HRPMS3X',2,
                '2',
                get_label_name('HRPMS3X1',global_v_lang,150),
                v_month_code,
--                v_month_tmp,
                get_label_name('HRPMS3X1',global_v_lang,90),
                get_label_name('HRPMS3X_GRAPH',global_v_lang,2),
                count2,
                get_label_name('HRPMS3X_GRAPH',global_v_lang,1)
                );

        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM4,ITEM5,ITEM7, ITEM8,ITEM9,ITEM10, ITEM31)
        VALUES (global_v_codempid,'HRPMS3X',3,
                '3',
                get_label_name('HRPMS3X1',global_v_lang,160),
                v_month_code,
--                v_month_tmp,
                get_label_name('HRPMS3X1',global_v_lang,90),
                get_label_name('HRPMS3X_GRAPH',global_v_lang,2),
                count3,
                get_label_name('HRPMS3X_GRAPH',global_v_lang,1)
                );

        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ, ITEM4, ITEM5, ITEM7,ITEM8,ITEM9,ITEM10 ,ITEM31)
        VALUES (global_v_codempid,'HRPMS3X',4,
                '4',
                get_label_name('HRPMS3X1',global_v_lang,170),
                v_month_code,
--                v_month_tmp,
                get_label_name('HRPMS3X1',global_v_lang,90),
                get_label_name('HRPMS3X_GRAPH',global_v_lang,2),
                count4,
                get_label_name('HRPMS3X_GRAPH',global_v_lang,1)
                );

    if v_data_exist then
      if v_permission then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
			  json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
    else
        param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'ttexempt' );
			  json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;



  procedure get_index_report(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
  begin
    initial_value(json_str_input);
    vadidate_variable_getindex(json_str_input);

    if param_msg_error is null then
        gen_index_report(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index_report(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    t_year          number;
    t_month         number;
    t_day           number;
    v_dtestrt       date := to_date('01/'||pa_month1||'/'||pa_year,'dd/mm/yyyy');
    v_dtestrt2      date := to_date('01/'||pa_month2||'/'||pa_year,'dd/mm/yyyy');
    v_dteend        date := last_day(v_dtestrt2);
    v_month         number;
    count1          number := 0;
    count2          number := 0;
    count3          number := 0;
    count4          number := 0;
    sum_count       number := 0;
    v_codcomp           varchar2(100 char);
    v_codempid          varchar2(100 char);
    v_secur             boolean := false;
    v_permission        boolean := false;
    v_data_exist        boolean := false;
    v_month_tmp     varchar2(100);
    v_count_ttemprpt  varchar2(500 char);
    v_strmonth   varchar2(100);
    v_endmonth   varchar2(100);
    sql_stmt    varchar2(500);

    cursor c1 is select codempid,codcomp,dteeffec,totwkday,codexemp,to_number(to_char(dteeffec,'mm')) month_eff,
    GET_TPOSTN_NAME(codpos,GLOBAL_V_LANG) as codpos ,CASE
		FLGBLIST
		WHEN 'Y' THEN
		get_label_name('HRPMS3X',GLOBAL_V_LANG,5)
		WHEN 'N' THEN
		get_label_name('HRPMS3X',GLOBAL_V_LANG,6)
	END AS FLGBLIST,AMTSALT
                from ttexempt
                where codcomp like pa_codcomp||'%'
                and to_char(dteeffec,'YYYYMMDD') between to_char(v_dtestrt,'YYYYMMDD') and to_char(v_dteend,'YYYYMMDD')
                and staupd in ('C','U')
                order by to_number(to_char(dteeffec,'mm')),codempid;

  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    begin

    DELETE FROM TTEMPRPT
    WHERE  CODAPP = 'HRPMS3X_REPORT'
    AND CODEMPID = global_v_codempid;
    end;

    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      v_codcomp := r1.codcomp;
      v_codempid := r1.codempid;
      get_service_year(r1.dteeffec - r1.totwkday,r1.dteeffec,'Y',t_year, t_month, t_day);
      v_month := (to_char(t_year*12)+to_char(trunc(t_month,0)));

      v_data_exist := true;
      v_secur := secur_main.secur3(v_codcomp,v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

      if v_secur then
        v_permission := true;
        v_month_tmp := ltrim(r1.month_eff, '0');

        v_month_tmp := get_tlistval_name('NAMMTHFUL',v_month_tmp,GLOBAL_V_LANG);

        obj_data.put('coderror', '200');

        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,ITEM12,ITEM13)
        VALUES (global_v_codempid, 'HRPMS3X_REPORT',v_rcnt,pa_codcomp,to_char(v_dtestrt,'dd/mm/yyyy'),to_char(v_dteend,'dd/mm/yyyy'),to_char(v_rcnt),v_month_tmp,r1.codempid,
        get_temploy_name(r1.codempid,GLOBAL_V_LANG),get_tcenter_name(r1.codcomp,GLOBAL_V_LANG),to_char(r1.dteeffec,'dd/mm/yyyy'),
        t_year,t_month,t_day,get_tcodec_name('TCODEXEM',r1.codexemp,GLOBAL_V_LANG));

        obj_row.put(to_char(v_rcnt-1),obj_data);

        if v_month between 0 and 3 or (v_month = 4 and t_month + t_day = 0) then -- Adisak redmine#9334 28/04/2023 12:07
          count1 := count1+1;
        elsif v_month between 4 and 11 or (v_month = 12 and t_month + t_day = 0) then
          count2 := count2+1;
        elsif v_month between 12 and 35 or (v_month = 36 and t_month + t_day = 0) then
          count3 := count3+1;
        elsif v_month between 36 and 9999 then
          count4 := count4+1;
        end if;

      end if;

    end loop;


    sum_count := count1+count2+count3+count4;
    obj_row.put(to_char(v_rcnt-1),obj_data);

    v_strmonth := get_tlistval_name('NAMMTHFUL',pa_month1,GLOBAL_V_LANG);
    v_endmonth := get_tlistval_name('NAMMTHFUL',pa_month2,GLOBAL_V_LANG);


    INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,ITEM12)
    VALUES (global_v_codempid, 'HRPMS3X_REPORT',0,pa_codcomp,to_char(v_dtestrt,'dd/mm/yyyy'),to_char(v_dteend,'dd/mm/yyyy'),count1,count2,count3,count4,sum_count,
    GET_TCENTER_NAME(pa_codcomp,global_v_lang),v_strmonth,v_endmonth,pa_year);

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end HRPMS3X;

/

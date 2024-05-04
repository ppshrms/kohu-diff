--------------------------------------------------------
--  DDL for Package Body HRPM35X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM35X" is
-- last update: 09/02/2021 18:01 #2768

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typreport       := hcm_util.get_string_t(json_obj,'p_typreport');
    p_typreport       := substr(p_typreport,-1);
    p_nameval         := hcm_util.get_string_t(json_obj,'p_nameval');
    p_yearstrt        := hcm_util.get_string_t(json_obj,'p_yearstrt');
    p_monthstrt       := hcm_util.get_string_t(json_obj,'p_monthstrt');
    p_yearend         := hcm_util.get_string_t(json_obj,'p_yearend');
    p_monthend        := hcm_util.get_string_t(json_obj,'p_monthend');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure vadidate_variable_getindex(json_str_input in clob) as
   tmp      varchar(1000);
   v_nummonth   number;
  begin

        if p_codcomp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
            return ;
        end if;

         if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
            if param_msg_error is not null then
                return;
            end if;
        end if;

        if (p_codcomp is not null) then
        begin
           select codcomp into tmp
            from tcenter
           where codcomp like p_codcomp||'%'
           and rownum <=1;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'');
          return;
        end;
        end if;

        if p_typreport is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
            return ;
        end if;

--        if p_nameval is null then
--            param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
--            return ;
--        end if;

        if p_yearstrt is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
            return ;
        end if;

        if p_monthstrt is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
            return ;
        end if;

        if p_yearend is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
            return ;
        end if;

        if p_monthend is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
            return ;
        end if;

        if (p_yearstrt > p_yearend) then
            param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
          return ;
        end if;

        if( p_monthstrt > 12 ) then
           param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
          return ;
        end if;

        if( p_monthend > 12 ) then
           param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
          return ;
        end if;

 --- check qty month--
   if p_yearstrt =  p_yearend then
     if  to_number(p_monthstrt) > to_number(p_monthend) then
         param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
        return ;
     end if;

   else
    SELECT abs(trunc(MONTHS_BETWEEN(TO_DATE('01'||lpad(p_monthstrt,2,'0')||p_yearstrt,'DDMMYYYY'), TO_DATE('01'||lpad(p_monthend,2,'0')||p_yearend,'DDMMYYYY') ))) + 1 "Months"
    into v_nummonth
    FROM DUAL;

    if v_nummonth > 12 then
        param_msg_error := get_error_msg_php('PM0103',global_v_lang, '');
        return ;
    end if;

--      if (p_yearend -  p_yearstrt) > 0 then
--        if (p_yearend -  p_yearstrt) > 1 then
--          param_msg_error := get_error_msg_php('PM0103',global_v_lang, '');
--          return ;
--        else
--            if ( p_monthstrt <= p_monthend) then
--                param_msg_error := get_error_msg_php('PM0103',global_v_lang, '');
--                return ;
--            end if;
--        end if;
--     end if;
   end if;
   -----

  end vadidate_variable_getindex;

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
    obj_month       json_object_t;
    obj_row         json_object_t;
    obj_main        json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_loop          number :=1;
    v_qtyemp        varchar2(500);
    numseq          number :=1;
    tmp_qty         number :=0;
    month_n         varchar2(200);
    v_secur         boolean := false;
    v_permission    boolean := false;
    v_data_exist    boolean := false;

    v_nummonth      number;
    v_curmonth      number;
    v_curyear       number;

    type tyyyymm is table of varchar2(6 char) index by binary_integer;
      v_yearmonth  tyyyymm;

    type tmm is table of number index by binary_integer;
      v_monthorder  tmm;

    cursor c1 is
      select codcomp,codpos,
             sum(case when monthnum = v_yearmonth(1) then 1 else 0 end ) qtyjan,
             sum(case when monthnum = v_yearmonth(2) then 1 else 0 end ) qtyfeb,
             sum(case when monthnum = v_yearmonth(3) then 1 else 0 end ) qtymar,
             sum(case when monthnum = v_yearmonth(4) then 1 else 0 end ) qtyapr,
             sum(case when monthnum = v_yearmonth(5) then 1 else 0 end ) qtymay,
             sum(case when monthnum = v_yearmonth(6) then 1 else 0 end ) qtyjun,
             sum(case when monthnum = v_yearmonth(7) then 1 else 0 end ) qtyjul,
             sum(case when monthnum = v_yearmonth(8) then 1 else 0 end ) qtyaug,
             sum(case when monthnum = v_yearmonth(9) then 1 else 0 end ) qtysep,
             sum(case when monthnum = v_yearmonth(10) then 1 else 0 end ) qtyoct,
             sum(case when monthnum = v_yearmonth(11) then 1 else 0 end ) qtynov,
             sum(case when monthnum = v_yearmonth(12) then 1 else 0 end ) qtydec
      from (  select hcm_util.get_codcomp_level(a.codcomp, p_typreport) codcomp,a.codpos,to_char(a.dteoccup,'YYYYMM') monthnum
              from ttprobat a
              where a.codcomp like p_codcomp||'%' 
              and  0 <> (    select count(ts.codcomp)
                             from  tusrcom ts
                             where ts.coduser = global_v_coduser
                             and   a.codcomp like ts.codcomp || '%'
                             and   rownum <= 1)                                                              
            and to_char(a.dteoccup,'YYYYMM') between p_yearstrt||lpad(p_monthstrt,2,'0') and p_yearend||lpad(p_monthend,2,'0')
            and a.typproba = '1'
            )
      group by codcomp,codpos
      order by codcomp,codpos;

  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    delete ttemprpt
    where codapp = 'HRPM35X'
    and   codempid = global_v_codempid;
    for i in 1..12 loop
      v_yearmonth(i)    := '000000';
      v_monthorder(i)      := 0;
    end loop;

    select abs(trunc(months_between(to_date('01'||lpad(p_monthstrt,2,'0')||p_yearstrt,'DDMMYYYY'), to_date('01'||lpad(p_monthend,2,'0')||p_yearend,'DDMMYYYY') ))) + 1 "Months"
    into v_nummonth
    from dual;

    obj_month   := json_object_t();
    v_curyear   := p_yearstrt;
    for i in 0..v_nummonth - 1 loop
        v_curmonth := mod(p_monthstrt + i,12);
        if v_curmonth = 0 then
            v_curmonth  := 12;
        end if;
        v_yearmonth(i+1)    := v_curyear||lpad(v_curmonth,2,'0');
        v_monthorder(i+1)   := v_curmonth;
        if v_curmonth = 12 then
            v_curyear   := v_curyear + 1;
        end if;
        obj_month.put('month'||(i+1), get_tlistval_name('NAMMTHFUL',v_curmonth ,  global_v_lang));
    end loop;

    for r1 in c1 loop
      v_data_exist := true;

      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
      obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
      obj_data.put('m1', r1.qtyjan);
      obj_data.put('m2', r1.qtyfeb);
      obj_data.put('m3', r1.qtymar);
      obj_data.put('m4', r1.qtyapr);
      obj_data.put('m5', r1.qtymay);
      obj_data.put('m6', r1.qtyjun);
      obj_data.put('m7', r1.qtyjul);
      obj_data.put('m8', r1.qtyaug);
      obj_data.put('m9', r1.qtysep);
      obj_data.put('m10', r1.qtyoct);
      obj_data.put('m11', r1.qtynov);
      obj_data.put('m12', r1.qtydec);
      obj_row.put(to_char(v_rcnt-1),obj_data);

      for j in 1..12 loop
                    month_n := get_tlistval_name('NAMMTHFUL',v_monthorder(j) ,  global_v_lang);
                    if j = 1 then tmp_qty := r1.qtyjan;
--                      month_n := get_tlistval_name('NAMMTHFUL',v_monthorder(j) ,  global_v_lang);
                    elsif j = 2 then tmp_qty := r1.qtyfeb;
--                      month_n := get_tlistval_name('NAMMTHFUL',j ,  global_v_lang);
                    elsif j = 3 then tmp_qty := r1.qtymar;
--                      month_n := get_tlistval_name('NAMMTHFUL',j ,  global_v_lang);
                    elsif j = 4 then tmp_qty := r1.qtyapr;
--                      month_n := get_tlistval_name('NAMMTHFUL',j ,  global_v_lang);
                    elsif j = 5 then tmp_qty := r1.qtymay;
--                      month_n := get_tlistval_name('NAMMTHFUL',j ,  global_v_lang);
                    elsif j = 6 then tmp_qty := r1.qtyjun;
--                      month_n := get_tlistval_name('NAMMTHFUL',j ,  global_v_lang);
                    elsif j = 7 then tmp_qty := r1.qtyjul;
--                      month_n := get_tlistval_name('NAMMTHFUL',j ,  global_v_lang);
                    elsif j = 8 then tmp_qty := r1.qtyaug;
--                      month_n := get_tlistval_name('NAMMTHFUL',j ,  global_v_lang);
                    elsif j = 9 then tmp_qty := r1.qtysep;
--                      month_n := get_tlistval_name('NAMMTHFUL',j ,  global_v_lang);
                    elsif j = 10 then tmp_qty := r1.qtyoct;
--                      month_n := get_tlistval_name('NAMMTHFUL',j ,  global_v_lang);
                    elsif j = 11 then tmp_qty := r1.qtynov;
--                      month_n := get_tlistval_name('NAMMTHFUL',j ,  global_v_lang);
                    elsif j = 12 then tmp_qty := r1.qtydec;
--                      month_n := get_tlistval_name('NAMMTHFUL',j ,  global_v_lang);
                    else tmp_qty := 0;
                    end if;
                    begin
                        insert into ttemprpt (codempid,codapp,numseq,
                                                      item2,
                                                      item4,
                                                      item5,
                                                      item6,
                                                      item8,
                                                      item9,
                                                      item10,
                                                      item31)
                                          values (global_v_codempid, 'HRPM35X',numseq ,
                                                      get_tcenter_name(r1.codcomp,global_v_lang),--item2
                                                      lpad(j,3,0),   --item4-X
                                                      month_n,     --item5-X
                                                      get_label_name('HRPM35X',global_v_lang,'20'), --item6-X
                                                      get_tpostn_name(r1.codpos,global_v_lang), --item8
                                                      get_label_name('HRPM35X',global_v_lang,'10'), --item9-Y
                                                      tmp_qty, --item10  value
                                                      get_label_name('HRPM35X',global_v_lang,'30') --item31
                                                      );

                    end;
                    numseq := numseq + 1;
         if numseq > v_nummonth then
          exit;
        end if;
      end loop; --for j in 1..12 loop
    end loop;
    obj_main    := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('month', obj_month);
    obj_main.put('table', obj_row);

    if v_rcnt = 0  then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttprobat');
    end if;
		if param_msg_error is null then
			json_str_output := obj_row.to_clob;
		else
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;


  procedure get_month(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
  begin
    initial_value(json_str_input);
    vadidate_variable_getindex(json_str_input);

    if param_msg_error is null then
        gen_month(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_month(json_str_output out clob)as
    obj_data        json_object_t;
    obj_month       json_object_t;
    obj_row         json_object_t;
    obj_main        json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_loop          number :=1;
    v_qtyemp        varchar2(500);
    numseq          number :=1;
    tmp_qty         number :=0;
    month_n         varchar2(200);
    v_secur         boolean := false;
    v_permission    boolean := false;
    v_data_exist    boolean := false;

    v_nummonth      number;
    v_curmonth      number;
    v_curyear       number;

  begin
    SELECT abs(trunc(MONTHS_BETWEEN(TO_DATE('01'||lpad(p_monthstrt,2,'0')||p_yearstrt,'DDMMYYYY'), TO_DATE('01'||lpad(p_monthend,2,'0')||p_yearend,'DDMMYYYY') ))) + 1 "Months"
    into v_nummonth
    FROM DUAL;

    obj_month   := json_object_t();
    v_curyear   := p_yearstrt;
    for i in 0..v_nummonth - 1 loop
        v_curmonth := mod(p_monthstrt + i,12);
        if v_curmonth = 0 then
            v_curmonth  := 12;
        end if;
        if v_curmonth = 12 then
            v_curyear   := v_curyear + 1;
        end if;
        obj_month.put('month'||(i+1), get_tlistval_name('NAMMTHFUL',v_curmonth ,  global_v_lang));
    end loop;

    obj_main    := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('month', obj_month);

    json_str_output := obj_main.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end hrpm35x;

/

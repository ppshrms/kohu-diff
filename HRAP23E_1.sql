--------------------------------------------------------
--  DDL for Package Body HRAP23E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP23E" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_dteyreap');
    b_index_codcomadj   := hcm_util.get_string_t(json_obj,'p_codcomadj');
    b_index_codincom    := hcm_util.get_string_t(json_obj,'p_codincom');
    begin
      select codcurr into global_v_codcurr
        from tcontrpy
       where codcompy = hcm_util.get_codcomp_level(b_index_codcomadj,1)
         and dteeffec = (select max(dteeffec)
                           from tcontrpy
                          where codcompy = hcm_util.get_codcomp_level(b_index_codcomadj,1)
                            and dteeffec <= trunc(sysdate));
    exception when no_data_found then null;
    end;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure set_codincom is
    type t_codincom is table of tcontpms.codincom1%type index by binary_integer;
    v_codincom    t_codincom;
    v_codcompy    tcompny.codcompy%type;
  begin
    v_codcompy  := hcm_util.get_codcomp_level(b_index_codcomadj,1);
    begin
      select codincom1,codincom2,codincom3,codincom4,codincom5,
             codincom6,codincom7,codincom8,codincom9,codincom10
        into v_codincom(1),v_codincom(2),v_codincom(3),v_codincom(4),v_codincom(5),
             v_codincom(6),v_codincom(7),v_codincom(8),v_codincom(9),v_codincom(10)
        from tcontpms
       where codcompy   = v_codcompy
         and dteeffec   = (select max(dteeffec)
                             from tcontpms
                            where codcompy  = v_codcompy
                              and dteeffec  <= trunc(sysdate))
         and rownum <= 1;
    exception when no_data_found then
      param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'TORGPRT');
    end;

    for i in 1..10 loop
      if b_index_codincom = v_codincom(i) then
        parameter_ptr := i;
        exit;
      end if;
    end loop;

    if parameter_ptr is null then
      param_msg_error   := get_error_msg_php('HR2010',global_v_lang,'TCONTPMS');
    end if;
  end;
  --
  procedure check_index is
    v_error   varchar2(4000);
  begin
    if b_index_codcomadj is not null then
      v_error   := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomadj);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;
    end if;
    set_codincom;
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_secure        boolean := false;
    cursor c1 is
      select numtime,codcomadj,dteadjin,numemp,
             stddec(amttadj,codemprq,global_v_chken) as amttadj,
             dteappr,staappr
        from ttemadj1
       where dteyreap   = b_index_dteyreap
         and codincom   = b_index_codincom
         and codcomadj  = b_index_codcomadj
      order by codcomadj,numtime,dteadjin;
  begin
    obj_row   := json_object_t();
    for i in c1 loop
--      v_secure    := secur_main.secur7(b_index_codcomadj,global_v_coduser);
--      if v_secure then
        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('numtime',i.numtime);
        obj_data.put('codcomadj',i.codcomadj);
        obj_data.put('desc_codcomadj',get_tcenter_name(i.codcomadj,global_v_lang));
        obj_data.put('dteadjin',to_char(i.dteadjin,'dd/mm/yyyy'));
        obj_data.put('numemp',i.numemp);
        obj_data.put('amttadj',to_char(i.amttadj,'fm999,999,999,990.00'));
        obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
        obj_data.put('staappr',i.staappr);
        obj_data.put('status',get_tlistval_name('STAAPPR',i.staappr,global_v_lang));
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt      := v_rcnt + 1;
--      end if;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_index(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_condition(json_str_input in clob, json_str_output out clob) is
    json_input          json_object_t;
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    obj_syncond         json_object_t;
    obj_formula         json_object_t;

    v_numtime           ttemadj1.numtime%type;

    v_row               number := 0;
    v_count             number := 0;
    v_flgsecu           boolean := false;
    v_flg_sendmail      varchar2(1) := 'N';
    cursor c1 is
        select codcomadj,codincom,numemp,
               stddec(amttadj,codemprq,global_v_chken) amttadj,
               staappr,dteappr,
               codemprq,dteyreap,
               amtmax,
               amtmin,
               dteadjin,formula,formulas,descond,desconds
          from ttemadj1
         where dteyreap     = b_index_dteyreap
           and numtime      = v_numtime
           and codcomadj    = b_index_codcomadj
           and codincom     = b_index_codincom;
  begin
    json_input  := json_object_t(json_str_input);
    v_numtime   := hcm_util.get_string_t(json_input,'p_numtime');

    obj_result      := json_object_t;
    obj_row         := json_object_t();
    obj_syncond     := json_object_t();
    obj_formula     := json_object_t();

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('dteadjin',to_char(sysdate,'dd/mm/yyyy'));
    obj_formula.put('code', '');
    obj_formula.put('description', '');
    obj_data.put('formula',obj_formula);
    obj_syncond.put('code', '');
    obj_syncond.put('description', '');
    obj_syncond.put('statement', '');
    obj_data.put('syncond', obj_syncond);
    obj_data.put('flg_sendmail',v_flg_sendmail);

    begin
      select 'Y'
        into v_flg_sendmail
        from ttemadj2
       where dteyreap     = b_index_dteyreap
         and numtime      = v_numtime
         and codcomadj    = b_index_codcomadj
         and codincom     = b_index_codincom
         and rownum       = 1;
    exception when no_data_found then
      v_flg_sendmail  := 'N';
    end;

    for r1 in c1 loop
      obj_data.put('amtmax',r1.amtmax);
      obj_data.put('amtmin',r1.amtmin);
      obj_data.put('amttadj',to_char(r1.amttadj,'fm999,999,999,990.00'));
      obj_data.put('codemprq',r1.codemprq);
      obj_data.put('desc_codemprq',get_temploy_name(r1.codemprq,global_v_lang));
      obj_data.put('dteadjin',to_char(r1.dteadjin,'dd/mm/yyyy'));
      obj_data.put('desc_codincom',get_tinexinf_name(r1.codincom ,global_v_lang));
      obj_data.put('numemp',r1.numemp);
      obj_data.put('staappr',r1.staappr);
      obj_data.put('status',get_tlistval_name('STAAPPR', r1.staappr,global_v_lang));
      obj_data.put('flg_sendmail',v_flg_sendmail);
      obj_formula.put('code', r1.formulas);
      obj_formula.put('description', r1.formula);
      obj_data.put('formula',obj_formula);
      obj_syncond.put('code', r1.descond);
      obj_syncond.put('description', get_logical_desc(r1.desconds));
      obj_syncond.put('statement', r1.desconds);
      obj_data.put('syncond', obj_syncond);
    end loop;
    json_str_output := obj_data.to_clob;
  end ;
  --
  procedure get_condition(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_condition(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_list_emp(json_str_input in clob, json_str_output out clob) is
    json_input          json_object_t;
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_pctsal            number := 0;
    v_flgsecu           boolean := false;
    v_rcnt              number := 0;
    v_numtime           ttemadj1.numtime%type;
    v_secur             boolean := false;
    v_zupdsal           varchar2(100);

    cursor c1 is
      select codcomadj,codincom,stddec(amtincnw,codempid,global_v_chken) amtincnw,
             stddec(amtadj,codempid,global_v_chken) amtadj,
             stddec(amtincod,codempid,global_v_chken) amtincod,
             dteyreap,codempid,numlvl,codcomp
        from ttemadj2
       where dteyreap   = b_index_dteyreap
         and numtime    = v_numtime
         and codcomadj  = b_index_codcomadj
         and codincom   = b_index_codincom
      order by codempid;
  begin
    json_input  := json_object_t(json_str_input);
    v_numtime   := hcm_util.get_string_t(json_input,'p_numtime');
    v_rcnt      := 0;
    obj_row     := json_object_t();
    for r1 in c1 loop
      v_secur   := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,
                                     v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

      if v_secur and v_zupdsal = 'Y' then
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          v_rcnt := v_rcnt + 1;
          obj_data.put('image',get_emp_img(r1.codempid));
          obj_data.put('codempid',r1.codempid);
          obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('amtincod',r1.amtincod);
          obj_data.put('amtadj',r1.amtadj);
          obj_data.put('amtincnw',r1.amtincnw);
          if r1.amtincod = 0 then
            v_pctsal := 0;
          else
            v_pctsal := (r1.amtadj/r1.amtincod)*100;
          end if;
          obj_data.put('pctsal',to_char(v_pctsal,'fm999,999,999,990.00'));
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_list_emp (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_list_emp(json_str_input, json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_process(json_str_input in clob,json_str_output out clob) is
    json_str        json_object_t;
    obj_data        json_object_t;
    obj_row_emp     json_object_t;
    obj_data_emp    json_object_t;
    v_descond       ttemadj1.descond%type;
    v_descondt      ttemadj1.descond%type;
    v_formula       ttemadj1.formula%type;
    v_amtmin        ttemadj1.amtmin%type;
    v_amtmax        ttemadj1.amtmax%type;
    v_codempid      v_temploy.codempid%type;
    v_codcomp       v_temploy.codcomp%type;
    v_codpos        v_temploy.codpos%type;
    v_numlvl        v_temploy.numlvl%type;
    v_typemp        v_temploy.typemp%type;
    v_codedlv       v_temploy.codedlv%type;
    v_dteempmt      v_temploy.dteempmt%type;
    v_amtbscsal     number;
    v_amtincom      number;
    v_codcurr       v_temploy.codcurr%type;

    v_statment      varchar2(4000 char);
    v_formula_replace varchar2(1000 char);
    v_cursor		    number;
    v_dummy         integer;
    v_secur         boolean;
    v_zupdsal       varchar2(10);
    v_ratechge      number;
    v_amt_before_adj number;
    v_amt_after_adj number;
    v_adj_percent   number;
    v_amtadjin      number;
    v_rcnt          number := 0;
    v_sum_amtadjin  number := 0;
  begin
    set_codincom;
    json_str    := json_object_t(json_str_input);
    v_descondt  := hcm_util.get_string_t(hcm_util.get_json_t(json_str,'syncond'),'code');
    v_formula   := hcm_util.get_string_t(hcm_util.get_json_t(json_str,'formula'),'code');
    v_amtmin    := hcm_util.get_string_t(json_str,'amtmin');
    v_amtmax    := hcm_util.get_string_t(json_str,'amtmax');

    v_descondt  := replace(v_descondt,'TEMPLOY1.',null);
    v_descondt  := replace(v_descondt,'TEMPLOY3.',null);
    v_descondt  := replace(v_descondt,'V_TEMPLOY.',null); --<<user46 fix #4502 18/11/2021
    v_descondt  := replace(v_descondt,'AGE_POS.',null);
    v_descond   := v_descondt;

    v_descond   := replace(v_descond,'AMTINCOM1','to_number(nvl(stddec(amtincom1,codempid,'''||global_v_chken||'''),0))');
    v_descond   := replace(v_descond,'AMTINCOM2','to_number(nvl(stddec(amtincom2,codempid,'''||global_v_chken||'''),0))');
    v_descond   := replace(v_descond,'AMTINCOM3','to_number(nvl(stddec(amtincom3,codempid,'''||global_v_chken||'''),0))');
    v_descond   := replace(v_descond,'AMTINCOM4','to_number(nvl(stddec(amtincom4,codempid,'''||global_v_chken||'''),0))');
    v_descond   := replace(v_descond,'AMTINCOM5','to_number(nvl(stddec(amtincom5,codempid,'''||global_v_chken||'''),0))');
    v_descond   := replace(v_descond,'AMTINCOM6','to_number(nvl(stddec(amtincom6,codempid,'''||global_v_chken||'''),0))');
    v_descond   := replace(v_descond,'AMTINCOM7','to_number(nvl(stddec(amtincom7,codempid,'''||global_v_chken||'''),0))');
    v_descond   := replace(v_descond,'AMTINCOM8','to_number(nvl(stddec(amtincom8,codempid,'''||global_v_chken||'''),0))');
    v_descond   := replace(v_descond,'AMTINCOM9','to_number(nvl(stddec(amtincom9,codempid,'''||global_v_chken||'''),0))');
    v_descond   := replace(v_descond,'AMTINCOM10','to_number(nvl(stddec(amtincom10,codempid,'''||global_v_chken||'''),0))');
    v_descond   := replace(v_descond,'AMTDAY','to_number(nvl(stddec(amtday,codempid,'''||global_v_chken||'''),0))');
    v_descond   := replace(v_descond,'AMTOTHR','to_number(nvl(stddec(amtothr,codempid,'''||global_v_chken||'''),0))');
    v_statment  := 'select codempid,codcomp,codpos,numlvl,typemp,
                           codedlv,dteempmt,stddec(amtincom1,codempid,'''||global_v_chken||''') amtbscsal,
                           decode('''||parameter_ptr||''' ,1,stddec(amtincom1,codempid,'''||global_v_chken||''')
                                                          ,2,stddec(amtincom2,codempid,'''||global_v_chken||''')
                                                          ,3,stddec(amtincom3,codempid,'''||global_v_chken||''')
                                                          ,4,stddec(amtincom4,codempid,'''||global_v_chken||''')
                                                          ,5,stddec(amtincom5,codempid,'''||global_v_chken||''')
                                                          ,6,stddec(amtincom6,codempid,'''||global_v_chken||''')
                                                          ,7,stddec(amtincom7,codempid,'''||global_v_chken||''')
                                                          ,8,stddec(amtincom8,codempid,'''||global_v_chken||''')
                                                          ,9,stddec(amtincom9,codempid,'''||global_v_chken||''')
                                                          ,10,stddec(amtincom10,codempid,'''||global_v_chken||'''),0) amtincom ,codcurr '||
                 ' from v_temploy where '||nvl(v_descond,' 1 = 2 ')||
                 ' and staemp in (''1'',''3'') '||
                 ' and codcomp like '''||b_index_codcomadj||'%''' ||
                 ' order by codempid';
    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_statment,dbms_sql.native);
    dbms_sql.define_column(v_cursor,1,v_codempid,1000);
    dbms_sql.define_column(v_cursor,2,v_codcomp,1000);
    dbms_sql.define_column(v_cursor,3,v_codpos,1000);
    dbms_sql.define_column(v_cursor,4,v_numlvl);
    dbms_sql.define_column(v_cursor,5,v_typemp,1000);
    dbms_sql.define_column(v_cursor,6,v_codedlv,1000);
    dbms_sql.define_column(v_cursor,7,v_dteempmt);
    dbms_sql.define_column(v_cursor,8,v_amtbscsal);
    dbms_sql.define_column(v_cursor,9,v_amtincom);
    dbms_sql.define_column(v_cursor,10,v_codcurr,1000);
    v_dummy   := dbms_sql.execute(v_cursor);
    obj_data  := json_object_t();
    obj_data.put('coderror','200');
    obj_row_emp := json_object_t();
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      obj_data_emp  := json_object_t();
      dbms_sql.column_value(v_cursor,1,v_codempid);
      dbms_sql.column_value(v_cursor,2,v_codcomp);
      dbms_sql.column_value(v_cursor,3,v_codpos);
      dbms_sql.column_value(v_cursor,4,v_numlvl);
      dbms_sql.column_value(v_cursor,5,v_typemp);
      dbms_sql.column_value(v_cursor,6,v_codedlv);
      dbms_sql.column_value(v_cursor,7,v_dteempmt);
      dbms_sql.column_value(v_cursor,8,v_amtbscsal);
      dbms_sql.column_value(v_cursor,9,v_amtincom);
      dbms_sql.column_value(v_cursor,10,v_codcurr);
      v_secur   := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,
                                     v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
--      if v_secur then
      if v_secur and v_zupdsal = 'Y' then
        v_adj_percent     := 0;
        v_ratechge        := get_exchange_rate(b_index_dteyreap,to_number(to_char(sysdate,'mm')),
                                               nvl(global_v_codcurr,v_codcurr),nvl(v_codcurr,global_v_codcurr));
        if v_amtincom < 0 then
          v_amtincom  := 0;
        end if;
        v_amt_before_adj  := v_amtincom*v_ratechge;

        v_formula_replace := replace(v_formula,'{&'||b_index_codincom||'}',v_amtincom);
				v_amtadjin        := execute_sql('select '||v_formula_replace||' from dual ');

        v_amt_after_adj   := greatest(nvl(v_amtmin,(v_amt_before_adj + v_amtadjin)),(v_amt_before_adj + v_amtadjin));
        v_amt_after_adj   := least(nvl(v_amtmax,v_amt_after_adj),v_amt_after_adj);

        v_amtadjin        := v_amt_after_adj - v_amt_before_adj;

        if nvl(v_amt_before_adj,0) > 0 then
          v_adj_percent     := v_amtadjin*100/v_amt_before_adj;
        end if;
        obj_data_emp.put('image',get_emp_img(v_codempid));
        obj_data_emp.put('codempid',v_codempid);
        obj_data_emp.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang));
        obj_data_emp.put('amtincod',to_char(v_amt_before_adj,'fm999,999,990.00'));
        obj_data_emp.put('pctsal',to_char(v_adj_percent,'fm999,999,990.00'));
        obj_data_emp.put('amtadj',to_char(v_amtadjin,'fm999,999,990.00'));
        obj_data_emp.put('amtincnw',to_char(v_amt_after_adj,'fm999,999,990.00'));
        obj_row_emp.put(to_char(v_rcnt),obj_data_emp);
        v_rcnt            := v_rcnt + 1;
        v_sum_amtadjin    := v_sum_amtadjin + v_amtadjin;
      end if;
    end loop;
    json_str_output   := obj_row_emp.to_clob;
  end;
  --
  procedure get_process(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_process(json_str_input,json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure insert_ttemadj1(t_ttemadj1 ttemadj1%rowtype) is
  begin
    begin
      insert into ttemadj1(dteyreap,numtime,codcomadj,
                           codincom,dteadjin,codemprq,
                           descond,formula,numdoc,
                           numemp,amttadj,amtmin,
                           amtmax,dteeffec,codtrn,
                           staappr,approvno,desconds,
                           formulas,codcreate,coduser)
      values (b_index_dteyreap,t_ttemadj1.numtime,b_index_codcomadj,
              b_index_codincom,t_ttemadj1.dteadjin,t_ttemadj1.codemprq,
              t_ttemadj1.descond,t_ttemadj1.formula,t_ttemadj1.numdoc,
              t_ttemadj1.numemp,t_ttemadj1.amttadj,t_ttemadj1.amtmin,
              t_ttemadj1.amtmax,t_ttemadj1.dteeffec,t_ttemadj1.codtrn,
              t_ttemadj1.staappr,t_ttemadj1.approvno,t_ttemadj1.desconds,
              t_ttemadj1.formulas,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update ttemadj1
         set dteadjin     = t_ttemadj1.dteadjin,
             codemprq     = t_ttemadj1.codemprq,
             descond      = t_ttemadj1.descond,
             formula      = t_ttemadj1.formula,
             numdoc       = t_ttemadj1.numdoc,
             numemp       = t_ttemadj1.numemp,
             amttadj      = t_ttemadj1.amttadj,
             amtmin       = t_ttemadj1.amtmin,
             amtmax       = t_ttemadj1.amtmax,
             dteeffec     = t_ttemadj1.dteeffec,
             codtrn       = t_ttemadj1.codtrn,
             staappr      = t_ttemadj1.staappr,
             approvno     = t_ttemadj1.approvno,
             desconds     = t_ttemadj1.desconds,
             formulas     = t_ttemadj1.formulas,
             coduser      = global_v_coduser
       where dteyreap     = b_index_dteyreap
         and numtime      = t_ttemadj1.numtime
         and codcomadj    = b_index_codcomadj
         and codincom     = b_index_codincom;
    end;
  end;
  --
  procedure insert_ttemadj2(t_ttemadj2 ttemadj2%rowtype) is
    v_codcomp     temploy1.codcomp%type;
    v_jobgrade    temploy1.jobgrade%type;
    v_codpos      temploy1.codpos%type;
    v_numlvl      temploy1.numlvl%type;
  begin
    begin
      select codcomp,jobgrade,codpos,numlvl
        into v_codcomp,v_jobgrade,v_codpos,v_numlvl
        from temploy1
       where codempid   = t_ttemadj2.codempid;
    end;
    begin
      insert into ttemadj2(dteyreap,numtime,codcomadj,
                           codincom,codempid,codcomp,
                           jobgrade,codpos,numlvl,
                           amtincod,amtincnw,amtadj,
                           codcreate,coduser)
      values (b_index_dteyreap,t_ttemadj2.numtime,b_index_codcomadj,
              b_index_codincom,t_ttemadj2.codempid,v_codcomp,
              v_jobgrade,v_codpos,v_numlvl,
              t_ttemadj2.amtincod,t_ttemadj2.amtincnw,t_ttemadj2.amtadj,
              global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update ttemadj2
         set amtincod   = t_ttemadj2.amtincod,
             amtincnw   = t_ttemadj2.amtincnw,
             amtadj     = t_ttemadj2.amtadj,
             coduser    = global_v_coduser
       where dteyreap     = b_index_dteyreap
         and numtime      = t_ttemadj2.numtime
         and codcomadj    = b_index_codcomadj
         and codincom     = b_index_codincom
         and codempid     = t_ttemadj2.codempid;
    end;
  end;
  --
  procedure save_adj(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    json_detail           json_object_t;
    json_str_tables       clob;
    json_tables           json_object_t;
    json_table_row        json_object_t;

    t_ttemadj1            ttemadj1%rowtype;
    t_ttemadj2            ttemadj2%rowtype;
    v_flg                 varchar2(10);
    v_amtincod            number;
    v_amtincnw            number;
    v_amtadj              number;
    v_sum_amtadj          number := 0;
  begin
    initial_value(json_str_input);
    json_input            := json_object_t(json_str_input);
    param_json            := hcm_util.get_json_t(json_input,'param_json');
    t_ttemadj1.numtime    := hcm_util.get_string_t(json_input,'p_numtime');
    t_ttemadj1.amtmax     := hcm_util.get_string_t(param_json,'amtmax');
    t_ttemadj1.amtmin     := hcm_util.get_string_t(param_json,'amtmin');
--    t_ttemadj1.amttadj    := hcm_util.get_string_t(param_json,'amttadj');
    t_ttemadj1.codemprq   := hcm_util.get_string_t(param_json,'codemprq');
    t_ttemadj1.dteadjin   := to_date(hcm_util.get_string_t(param_json,'dteadjin'),'dd/mm/yyyy');
--    t_ttemadj1.numemp     := hcm_util.get_string_t(param_json,'numemp');
    t_ttemadj1.staappr    := 'P';
    t_ttemadj1.formulas   := hcm_util.get_string_t(hcm_util.get_json_t(param_json,'formula'),'code');
    t_ttemadj1.formula    := hcm_util.get_string_t(hcm_util.get_json_t(param_json,'formula'),'description');
    t_ttemadj1.descond    := hcm_util.get_string_t(hcm_util.get_json_t(param_json,'syncond'),'code');
    t_ttemadj1.desconds   := hcm_util.get_string_t(hcm_util.get_json_t(param_json,'syncond'),'statement');

    delete from ttemadj2
    where dteyreap = b_index_dteyreap
    and numtime = t_ttemadj1.numtime
    and codcomadj = b_index_codcomadj
    and codincom = b_index_codincom;

    gen_process(param_json.to_clob,json_str_tables);
    json_tables             := json_object_t(json_str_tables);
    for i in 0..(json_tables.get_size - 1) loop
      json_table_row        := hcm_util.get_json_t(json_tables,to_char(i));
      t_ttemadj2.numtime    := t_ttemadj1.numtime;
      t_ttemadj2.codincom   := hcm_util.get_string_t(json_table_row,'codincom');
      t_ttemadj2.codempid   := hcm_util.get_string_t(json_table_row,'codempid');
      v_amtincod            := replace(hcm_util.get_string_t(json_table_row,'amtincod'),',','');
      v_amtincnw            := replace(hcm_util.get_string_t(json_table_row,'amtincnw'),',','');
      v_amtadj              := replace(hcm_util.get_string_t(json_table_row,'amtadj'),',','');
      t_ttemadj2.amtincod   := stdenc(v_amtincod,t_ttemadj2.codempid,global_v_chken);
      t_ttemadj2.amtincnw   := stdenc(v_amtincnw,t_ttemadj2.codempid,global_v_chken);
      t_ttemadj2.amtadj     := stdenc(v_amtadj,t_ttemadj2.codempid,global_v_chken);
      v_sum_amtadj          := nvl(v_amtadj,0) + v_sum_amtadj;
      insert_ttemadj2(t_ttemadj2);
    end loop;
    t_ttemadj1.amttadj    := stdenc(trunc(v_sum_amtadj,2),t_ttemadj1.codemprq,global_v_chken);
    t_ttemadj1.numemp     := json_tables.get_size;
    insert_ttemadj1(t_ttemadj1);

    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_index(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    param_json_row        json_object_t;
    v_numtime             ttemadj1.numtime%type;
    v_flg                 varchar2(50);
  begin
    initial_value(json_str_input);
    json_input            := json_object_t(json_str_input);
    param_json            := hcm_util.get_json_t(json_input,'param_json');
    for i in 0..(param_json.get_size - 1) loop
      param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
      v_numtime           := hcm_util.get_string_t(param_json_row,'numtime');
      v_flg               := hcm_util.get_string_t(param_json_row,'flg');
      if v_flg = 'delete' then
        delete ttemadj1
         where dteyreap    = b_index_dteyreap
           and numtime     = v_numtime
           and codcomadj   = b_index_codcomadj
           and codincom    = b_index_codincom;

        delete ttemadj2
         where dteyreap    = b_index_dteyreap
           and numtime     = v_numtime
           and codcomadj   = b_index_codcomadj
           and codincom    = b_index_codincom;
      end if;
    end loop;

    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure send_mail_to_approve(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    v_numtime       ttemadj1.numtime%type;
    v_codemprq      ttemadj1.codemprq%type;
    v_codapp        varchar2(100) := 'HRAP23E';
    v_o_msg_to      clob;
    v_template_to   clob;
    v_func_appr     clob;
    v_codform       tfwmailh.codform%type;
    v_rowid         varchar2(1000);
    v_subject_label varchar2(200);
    v_error         varchar2(100);

    v_item        varchar2(500) := 'item1,item2,item3,item4,item5,item6';
    v_label       varchar2(500) := 'label1,label2,label3,label4,label5,label6';
    v_file_name   varchar2(500) := 'HRAP23E';
  begin
    initial_value(json_str_input);
    json_input      := json_object_t(json_str_input);
    v_numtime       := hcm_util.get_string_t(json_input,'p_numtime');

    v_subject_label := get_label_name('HRAP23E3',global_v_lang,810);
    v_file_name     := global_v_codempid||'_'||to_char(sysdate,'yyyymmddhh24miss');

    delete from ttemprpt where codapp = 'HRAP23E' and codempid = global_v_codempid;
    delete from ttempprm where codapp = 'HRAP23E' and codempid = global_v_codempid;

    insert into ttempprm (codempid,codapp,namrep,pdate,ppage,
                          label1,label2,label3,label4,label5,label6)
    values(global_v_codempid,'HRAP23E','HRAP23E',to_char(sysdate,'dd/mm/yyyy'),'page1',
           get_label_name('HRAP23E3',global_v_lang,20),
           get_label_name('HRAP23E3',global_v_lang,30),
           get_label_name('HRAP23E3',global_v_lang,40),
           get_label_name('HRAP23E3',global_v_lang,50),
           get_label_name('HRAP23E3',global_v_lang,60),
           get_label_name('HRAP23E3',global_v_lang,70));

    begin
      insert into ttemprpt (codempid,codapp,numseq,
                            item1,item2,item3,item4,item5,item6)
      select global_v_codempid,'HRAP23E',rownum,
             codempid,get_temploy_name(codempid,global_v_lang),
             to_char(stddec(amtincod,codempid,global_v_chken),'999,999,999,990.00'),
             case when stddec(amtincod,codempid,global_v_chken) > 0 then
               to_char(stddec(amtadj,codempid,global_v_chken)*100/stddec(amtincod,codempid,global_v_chken),'999,999,990.00')
             else
               '0.00'
             end,
             to_char(stddec(amtadj,codempid,global_v_chken),'999,999,999,990.00'),
             to_char(stddec(amtincnw,codempid,global_v_chken),'999,999,999,990.00')
        from ttemadj2
       where dteyreap     = b_index_dteyreap
         and numtime      = v_numtime
         and codcomadj    = b_index_codcomadj
         and codincom     = b_index_codincom
    order by codempid;
    end;
    commit;

    excel_mail(v_item,v_label,null,global_v_codempid,'HRAP23E',v_file_name);
    --
    begin
      select rowid,codemprq
        into v_rowid,v_codemprq
        from ttemadj1
       where dteyreap     = b_index_dteyreap
         and numtime      = v_numtime
         and codcomadj    = b_index_codcomadj
         and codincom     = b_index_codincom;
    exception when no_data_found then
      null;
    end;

    v_error := chk_flowmail.send_mail_for_approve('HRAP23E', v_codemprq, global_v_codempid, global_v_coduser, v_file_name, 'HRAP23E3', 810, 'E', 'P', 1, null, null,'TTEMADJ1',v_rowid, '1', 'Oracle');

    param_msg_error   := get_error_msg_php('HR2046',global_v_lang);
    json_str_output := get_response_message(201,param_msg_error,global_v_lang);
    commit;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

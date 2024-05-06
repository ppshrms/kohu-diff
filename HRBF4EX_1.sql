--------------------------------------------------------
--  DDL for Package Body HRBF4EX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF4EX" AS

  procedure initial_value(json_str_input in clob) as
    json_obj json;
  begin
    json_obj          := json(json_str_input);
    global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_codcomp         := upper(hcm_util.get_string(json_obj,'p_codcomp'));
    p_dtemthst        := to_number(hcm_util.get_string(json_obj,'p_dtemthst'));
    p_dteyrest        := to_number(hcm_util.get_string(json_obj,'p_dteyrest'));
    p_dtemthen        := to_number(hcm_util.get_string(json_obj,'p_dtemthen'));
    p_dteyeen         := to_number(hcm_util.get_string(json_obj,'p_dteyeen'));
  end initial_value;

  function check_statement (v_codempid temploy1.codempid%type, v_syncond tobfcde.syncond%type, v_table varchar2 default 'TEMPLOY1') return boolean AS ----
    v_flgfound        boolean := false;
    v_statment        varchar2(1000 char);
    v_staemp          temploy1.staemp%type;
    v_codcomp         temploy1.codcomp%type;
    v_codpos          temploy1.codpos%type;
    v_numlvl          temploy1.numlvl%type;
    v_codjob          temploy1.codjob%type;
    v_codempmt        temploy1.codempmt%type;
    v_typemp          temploy1.typemp%type;
    v_typpayroll      temploy1.typpayroll%type;
    v_codbrlc         temploy1.codbrlc%type;
    v_codcalen        temploy1.codcalen%type;
    v_jobgrade        temploy1.jobgrade%type;
    v_codgrpgl        temploy1.codgrpgl%type;
    v_dteeffec        ttmovemt.dteeffec%type;
    v_amthour         number;
    v_amtday          number;
    v_amtmth          number;

  begin
    if v_syncond is not null then
      v_flgfound        := false;
      v_dteeffec        := to_date('31/12/' || to_char(p_dteyeen),'dd/mm/yyyy');
      begin
        select staemp, codcomp, codpos, numlvl, codjob, codempmt, typemp, typpayroll, codbrlc, codcalen, jobgrade, codgrpgl
          into v_staemp, v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp, v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        null;
      end;
      std_al.get_movemt (v_codempid, v_dteeffec, 'C', 'U',
                         v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp, v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl,
                         v_amthour, v_amtday, v_amtmth);                         
      v_statment := v_syncond;
      v_statment := replace(v_statment, v_table || '.STAEMP','''' || v_staemp || '''');
      v_statment := replace(v_statment, v_table || '.CODCOMP','''' || v_codcomp || '''');
      v_statment := replace(v_statment, v_table || '.CODPOS','''' || v_codpos || '''');
      v_statment := replace(v_statment, v_table || '.NUMLVL', v_numlvl);
      v_statment := replace(v_statment, v_table || '.CODJOB','''' || v_codjob || '''');
      v_statment := replace(v_statment, v_table || '.CODEMPMT','''' || v_codempmt || '''');
      v_statment := replace(v_statment, v_table || '.TYPEMP','''' || v_typemp || '''');
      v_statment := replace(v_statment, v_table || '.TYPPAYROLL','''' || v_typpayroll || '''');
      v_statment := replace(v_statment, v_table || '.CODBRLC','''' || v_codbrlc || '''');
      v_statment := replace(v_statment, v_table || '.CODCALEN','''' || v_codcalen || '''');
      v_statment := replace(v_statment, v_table || '.JOBGRADE','''' || v_jobgrade || '''');
      v_statment := replace(v_statment, v_table || '.CODGRPGL','''' || v_codgrpgl || '''');
      v_statment := 'select count(*) from dual where ' || v_statment;
      v_flgfound := execute_stmt(v_statment);
      return v_flgfound;
    end if;
    return true;
  end check_statement;

  procedure check_index as
    v_temp      varchar(1 char);
  begin

    if p_codcomp is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check codcomp in tcenter
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp|| '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
    end;

--  check secure7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

--  check date
    if to_date(get_period_date(p_dtemthst,p_dteyrest,'S'),'dd/mm/yyyy') > to_date(get_period_date(p_dtemthen,p_dteyeen,'S'),'dd/mm/yyyy') then
        param_msg_error := get_error_msg_php('HR2022',global_v_lang);
        return;
    end if;

  end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json;
    obj_data        json;
    v_row           number := 0;
    v_row_secur     number := 0;
    v_codobf        tobfcde.codobf%type;
    v_qtyalw        tobfcdet.qtyalw%type;
    v_syncond       tobfcde.syncond%type;
    v_syncond2      tobfcdet.syncond%type;
    v_numobf        tobfcdet.numobf%type;
    v_qtyflglimit   number := 0;
    v_amtalwyr      tobfcft.amtalwyr%type;
    v_secur         varchar2(1 char) := 'N';
    v_chk_secur     boolean := false; 
    v_empsyn        varchar2(1 char) := 'N';

    cursor c1 is
      select a.codempid,a.codobf,sum(a.qtywidrw) as qtywidrw,sum(a.qtytwidrw) qtytwidrw,
            sum(a.amtwidrw) amtwidrw,
            c.flglimit,
--            0 dteyre,0 dtemth -- surachai bk 01/12/2022 || #8758
            a.dteyre,a.dtemth
      from tobfsum a,temploy1 b,tobfcde c
      where b.codcomp like p_codcomp || '%'
      and a.dteyre||lpad(a.dtemth,2,'0') between p_dteyrest||lpad(p_dtemthst,2,'0')
      and p_dteyeen||lpad(p_dtemthen,2,'0')
      and a.codempid = b.codempid
      and a.codobf = c.codobf
--    group by a.codempid,a.codobf,c.flglimit -- surachai bk 01/12/2022 || #8758
    group by a.codempid,a.codobf,c.flglimit,dteyre,dtemth
    order by a.codempid,a.codobf;

    cursor c_tobfbgyr is ----
      select dteeffec, numseq, syncond, amtalwyr
        from tobfbgyr
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tobfbgyr
                          where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                            and trunc(dteeffec) <= trunc(to_date('31/12/' || to_char(p_dteyeen), 'DD/MM/YYYY')))
    order by numseq;

    cursor c_obfsyn is ----
      select a.codobf,a.syncond,b.numobf,b.syncond syncond2,b.qtyalw into v_codobf,v_syncond,v_numobf,v_syncond2,v_qtyalw
        from tobfcde a,tobfcdet b,tobfcompy c
       where a.codobf   = b.codobf
         and a.codobf   = c.codobf 
         and a.codobf   = v_codobf 
         and c.codcompy = hcm_util.get_codcomp_level(p_codcomp,1) 
         and a.dtestart = (select max(dtestart)
                             from tobfcde
                            where codobf = v_codobf
                              and dtestart <= sysdate)        
    order by b.numobf;

  BEGIN
    obj_rows := json();
    for i in c1 loop
      v_row := v_row+1;
      v_chk_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_chk_secur then
        v_secur := 'Y';
        v_row_secur := v_row_secur+1;
        obj_data := json();
        obj_data.put('image',get_emp_img(i.codempid));
        obj_data.put('codempid',i.codempid);
        obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
        obj_data.put('dteyre',i.dteyre);
        obj_data.put('dtemth',i.dtemth);
        obj_data.put('codobf',i.codobf);
        obj_data.put('codobf_name',get_tobfcde_name(i.codobf,global_v_lang));
        obj_data.put('flglimit',i.flglimit);
        obj_data.put('flglimit_name',get_tlistval_name('TYPELIMIT',i.flglimit,global_v_lang));
        obj_data.put('qtywidrw',i.qtywidrw);
--      get data from tobfcft
        begin
          ----select b.codobf,b.qtyalw into v_codobf,v_qtyalw
          select 'Y',b.qtyalw into v_empsyn,v_qtyalw
            from tobfcft a, tobfcftd b
           where a.codempid = b.codempid
             and a.dtestart = b.dtestart
             and a.codempid = i.codempid
             and b.codobf   = i.codobf
             and a.dtestart = (select max(dtestart)
                                 from tobfcft
                                where codempid = i.codempid
                                  and dtestart <= sysdate);
        exception when no_data_found then
          v_empsyn := 'N'; ----v_codobf := null; ----'';
          v_qtyalw := 0;
        end;
        --      override when tobfcft no data found
        /*if v_codobf is null then ---- and v_qtyalw = 0 then
          begin
            select a.codobf,a.syncond,b.numobf,b.syncond syncond2,b.qtyalw into v_codobf,v_syncond,v_numobf,v_syncond2,v_qtyalw
              from tobfcde a,tobfcdet b,tobfcompy c
             where a.codobf   = b.codobf
               and a.codobf   = c.codobf ----
               and a.codobf   = i.codobf ----
               and c.codcompy = hcm_util.get_codcomp_level(p_codcomp,1) ----
               and a.dtestart = (select max(dtestart)
                                   from tobfcde
                                  where codobf = i.codobf ----
                                    and dtestart <= sysdate)
              and rownum = 1
            order by b.numobf; ----order by a.codobf,b.numobf
          exception when no_data_found then
            v_codobf   := null; ----;
            v_syncond  := null; ----'';
            v_numobf   := 0;
            v_syncond2 := null; ----'';
            v_qtyalw   := 0;
          end;
        end if;

        if i.flglimit = 'Y' or i.flglimit = 'A' then
          v_qtyflglimit := v_qtyalw;
          obj_data.put('qtyflglimit',v_qtyflglimit);
        else
          v_qtyflglimit := v_qtyalw * round(months_between(to_date(get_period_date(p_dtemthen,p_dteyeen,''),'dd/mm/yyyy'),to_date(get_period_date(p_dtemthst,p_dteyrest,'S'),'dd/mm/yyyy')));
          obj_data.put('qtyflglimit',v_qtyflglimit);
        end if;
        obj_data.put('qty_remainning',v_qtyflglimit - i.qtywidrw);*/
        ----<<
        if v_empsyn = 'N' then
          v_codobf := i.codobf;
          v_qtyflglimit := 0;
          for j in c_obfsyn loop
            if  check_statement(i.codempid, j.syncond, 'V_HRBF41') 
            and check_statement(i.codempid, j.syncond2, 'V_HRBF41') then
              v_qtyalw := j.qtyalw;  
              exit;
            end if;
          end loop;
        end if;
        if i.flglimit = 'Y' or i.flglimit = 'A' then
          v_qtyflglimit := v_qtyalw;
        else
          v_qtyflglimit := v_qtyalw * round(months_between(to_date(get_period_date(p_dtemthen,p_dteyeen,''),'dd/mm/yyyy'),to_date(get_period_date(p_dtemthst,p_dteyrest,'S'),'dd/mm/yyyy')));
        end if;
        obj_data.put('qtyflglimit',v_qtyflglimit);
        obj_data.put('qty_remainning',greatest((v_qtyflglimit - i.qtywidrw) ,0));
        ---->>
        obj_data.put('qtytwidrw',i.qtytwidrw);
        obj_data.put('amtwidrw',i.amtwidrw);
        begin
          select amtalwyr into v_amtalwyr
          from tobfcft
          where codempid = i.codempid
            and dtestart = (select max(dtestart)
                            from tobfcft
                            where codempid = i.codempid
                            and dtestart <= sysdate);
        exception when no_data_found then
          ----v_amtalwyr := 0;
          for j in c_tobfbgyr loop
            if check_statement(i.codempid, j.syncond, 'V_HRBF41') then
              v_amtalwyr := hral71b_batch.cal_formula(i.codempid, j.amtalwyr, j.dteeffec);
              exit;
            end if;
          end loop;
        end;

        obj_data.put('amtalwyr',v_amtalwyr);
        obj_rows.put(to_char(v_row_secur-1),obj_data);
      end if;
    end loop;

    if v_row > 0 and v_row_secur = 0 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    if v_row = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TOBFSUM');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
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

END HRBF4EX;

/

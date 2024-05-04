--------------------------------------------------------
--  DDL for Package Body HRBF4HE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF4HE" AS
--user14:24/01/2023 redmine695
  procedure initial_value(json_str_input in clob) as
   json_obj json;
  begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_query_codempid  := hcm_util.get_string(json_obj,'p_query_codempid');
        p_codcomp         := hcm_util.get_string(json_obj,'p_codcomp');
        p_codobf          := hcm_util.get_string(json_obj,'p_codobf');
        p_dtestart        := to_date(hcm_util.get_string(json_obj,'p_dtestart'),'dd/mm/yyyy');

  end initial_value;

  procedure check_index as
   v_temp      varchar(1 char);
  begin
--  check cdocomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1 ;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
    end;

--  check secure7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

  end check_index;

  procedure check_detail as
   v_temp      varchar(1 char);
  begin
    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_query_codempid;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
    end;

--  check secure2
    if secur_main.secur2(p_query_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_query_codempid
        and staemp <> 9;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
    end;

    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_query_codempid
        and staemp <> 0;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
    end;

  end check_detail;

  procedure check_params_tab1 as
   v_temp    varchar(1 char);
   v_dteend  tobfcft.dteend%type;

  begin
    if p_codappr is null or p_dteappr is null or p_amtalwyr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
--  check codempid
    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_codappr;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
    end;

    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_query_codempid;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
    end;
--  check status employee
    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_codappr
          and staemp <> 9;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
    end;
--  check new employee
    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_codappr
          and staemp <> 0;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
    end;

--  check secure2
    if secur_main.secur2(p_codappr,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

--  check date
    if p_dtestart > p_dteappr then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

--  check dtestart < system date
    if p_flag = 'Add' then
        if p_dtestart < to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy') then
            param_msg_error := get_error_msg_php('HR8519',global_v_lang);
            return;
        end if;

        begin
            select dteend into v_dteend
            from tobfcft
            where codempid = p_query_codempid
              and dtestart = (select max(dtestart) from tobfcft
                              where codempid = p_query_codempid
                                and dtestart < p_dtestart);
        exception when no_data_found then
            return;
        end;

        if v_dteend is null then
            param_msg_error := get_error_msg_php('HR2507',global_v_lang);
            return;
        end if;

    end if;


  end check_params_tab1;

  procedure check_params_tab2 as
    v_temp      varchar(1 char);
  begin

    if p_sumQtymonyer >  p_amtalwyr then
        param_msg_error := get_error_msg_php('BF0071',global_v_lang);
        return;
    end if;

    begin
        select 'X' into v_temp
        from tobfcde
        where codobf = p_codobf;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TOBFCDE');
        return;
    end;

    begin
        select 'X' into v_temp
        from tobfcompy
        where codobf = p_codobf
          and codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TOBFCOMPY ');
        return;
    end;

    begin
        select 'X' into v_temp
        from tobfcde
        where codobf = p_codobf
          and typegroup = '2';
    exception when no_data_found then
        param_msg_error := get_error_msg_php('BF0057',global_v_lang);
        return;
    end;

  end check_params_tab2;

  function gen_data_from_tobfcde(p_codobf in varchar2) return json as
    obj_data        json;
    v_codunit       tobfcde.codunit%type;
    v_flglimit      tobfcde.flglimit%type;
    v_amtvalue      tobfcde.amtvalue%type;
    v_typebf        tobfcde.typebf%type;
    v_qtyalw        tobfcdet.qtyalw%type;
    v_qtytalw       tobfcdet.qtytalw%type;
    v_count         number := 0;
    v_statement     long;
    v_syncond       tobfcde.syncond%type;

  begin
--  get data from tobfcde
    begin
        --select codunit,flglimit,amtvalue,'where '||syncond,typebf 
         select codunit,flglimit,amtvalue,  syncond,   typebf 
           into v_codunit,v_flglimit,v_amtvalue,v_syncond,   v_typebf
        from tobfcde
        where codobf = p_codobf;
    exception when no_data_found then
        v_codunit  := '';
        v_flglimit := '';
        v_amtvalue := '';
        v_syncond  := '';
        v_typebf  := '';
    end;
--  get data from tobfcdet
    begin
        select sum(qtyalw),sum(qtytalw) into v_qtyalw,v_qtytalw
        from tobfcdet
        where codobf = p_codobf;
    exception when no_data_found then
        v_qtyalw  := '';
        v_qtytalw := '';
    end;
    if v_syncond is not null then 

--<<user14:24/01/2023 redmine695        
       v_syncond  := 'where  ('||v_syncond||') ';
-->>user14:24/01/2023 redmine695    

--    v_statement := 'select count(*) from v_ hrbf41 '||v_syncond -- surachai bk 02/12/2022 || 4448 new bf >> #8704
        v_statement := 'select count(*) from v_hrbf41 '||v_syncond||' and codempid = '''||p_query_codempid||'''';
        execute immediate v_statement into v_count;
    end if;

    if v_count = 0 then
        v_qtyalw  := '';
        v_qtytalw := '';
    end if;

    obj_data := json();
    obj_data.put('codunit',v_codunit);
    obj_data.put('flglimit',v_flglimit);
    obj_data.put('amtvalue',v_amtvalue);
    obj_data.put('qtyalw',v_qtyalw);
    obj_data.put('qtytalw',v_qtytalw);
    obj_data.put('typebf',v_typebf);

    return obj_data;

  end;

  procedure gen_index(json_str_output out clob) as
    obj_data        json;
    obj_rows        json;
    v_row           number := 0;
    v_chk_secur     boolean := false;
    v_count         number := 0;
    v_flag          boolean := false;

    cursor c1 is
        select codempid,dtestart,dteend,codappr,dteappr
        from tobfcft
        where codcomp like p_codcomp || '%'
          and codempid = nvl(p_query_codempid,codempid)
        order by codempid,dtestart;
  begin
    obj_rows := json();
    for i in c1 loop
        v_chk_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_chk_secur then
            select count(*) into v_count
            from tobfinf  
            where codempid = i.codempid
              and codobf in (select codobf
                             from tobfcftd
                             where codempid = i.codempid
                               and dtestart = i.dtestart);
            v_row := v_row+1;
            obj_data := json();
            if v_count > 0 then
                v_flag := true;
            else
                 v_flag := false;
            end if;

            obj_data.put('flag',v_flag);
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('dtestart',to_char(i.dtestart,'dd/mm/yyyy'));
            obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
            obj_data.put('codappr',i.codappr);
            obj_data.put('codappr_name',get_temploy_name(i.codappr,global_v_lang));
            obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);


  end gen_index;

  procedure gen_detail(json_str_output out clob) as
    obj_data        json;
    v_codappr       tobfcft.codappr%type;
    v_dteappr       tobfcft.dteappr%type;
    v_dteend        tobfcft.dteend%type;
    v_codcomp       tobfcft.codcomp%type;
    v_amtalwyr      tobfcft.amtalwyr%type := 0;
    v_flag          varchar(50 char);
    v_dteeffec      tobfbgyr.dteeffec%type;
    v_syncond       tobfbgyr.syncond%type;
    v_statement     long;
    v_count         varchar2(10 char);

    cursor c1 is
--<<user14:24/01/2023 redmine695          
        --select dteeffec, 'and '||syncond as syncond, amtalwyr
        select dteeffec, 'and ('||syncond||') ' as syncond, amtalwyr
-->>user14:24/01/2023 redmine695        
        from tobfbgyr
        where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
          and dteeffec = (select max(dteeffec)
                          from tobfbgyr
                          where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                            and dteeffec <= sysdate)
        order by numseq;

  begin
    begin
        select 'Edit',codappr,dteappr,dteend 
          into v_flag,v_codappr,v_dteappr,v_dteend
        from tobfcft
        where codempid = p_query_codempid
          and dtestart = p_dtestart;
    exception when no_data_found then
        v_codappr  := '';
        v_dteappr  := '';
        v_dteend   := '';
        v_flag     := 'Add';
    end;

    begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = p_query_codempid;
    exception when no_data_found then
        v_codcomp := null;
    end;

    for i in c1 loop      
        --v_statement := 'select count(*) from v_hrbf41 where codempid = '''||p_query_codempid||''' '||i.syncond;
        v_statement := 'select count(*) from v_hrbf41 where codempid = '''||p_query_codempid||''' '||i.syncond;
        execute immediate v_statement into v_count;
        if v_count > 0 then
            v_amtalwyr := hral71b_batch.cal_formula(p_query_codempid, i.amtalwyr, i.dteeffec);
            exit;
        end if;
    end loop;

    obj_data := json();
    obj_data.put('flag',v_flag);
    obj_data.put('codappr',v_codappr);
    obj_data.put('codappr_name',get_temploy_name(v_codappr,global_v_lang));
    obj_data.put('dteappr',to_char(v_dteappr,'dd/mm/yyyy'));
    obj_data.put('dteend',to_char(v_dteend,'dd/mm/yyyy'));
    obj_data.put('amtalwyr',v_amtalwyr);
    obj_data.put('coderror',200);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  end gen_detail;

  procedure gen_detail_table(json_str_output out clob) as
   obj_data     json;
   obj_rows     json;
   v_row        number := 0;
   v_tobfcdet   json;
   cursor c1 is
    select codobf,flglimit,amtvalue,qtyalw,qtytalw,amtalw
    from tobfcftd
    where codempid = p_query_codempid
      and dtestart = p_dtestart
    order by codobf;
  begin
    obj_rows := json();
    for i in c1 loop
        v_tobfcdet := gen_data_from_tobfcde(i.codobf);
        obj_data := json();
        v_row := v_row+1;
        obj_data.put('codobf',i.codobf);
        obj_data.put('codunit',hcm_util.get_string(v_tobfcdet,'codunit'));
        obj_data.put('codunit_name',get_tcodec_name('TCODUNIT',hcm_util.get_string(v_tobfcdet,'codunit'),global_v_lang));
        obj_data.put('typebf',hcm_util.get_string(v_tobfcdet,'typebf'));
        obj_data.put('flglimit',i.flglimit);
        obj_data.put('flglimit_name',get_tlistval_name('TYPELIMIT',i.flglimit,global_v_lang));
        obj_data.put('amtvalue',i.amtvalue);
        obj_data.put('qtyalw',i.qtyalw);
        obj_data.put('amtalw',i.amtalw);
        obj_data.put('qtytalw',i.qtytalw);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_detail_table;


  procedure gen_tobfcde(json_str_output out clob) as
    obj_data        json;
    v_tobfcdet      json;
  begin
    obj_data := json();
    v_tobfcdet := gen_data_from_tobfcde(p_codobf);
    obj_data.put('codunit',hcm_util.get_string(v_tobfcdet,'codunit'));
    obj_data.put('codunit_name',get_tcodec_name('TCODUNIT',hcm_util.get_string(v_tobfcdet,'codunit'),global_v_lang));
    obj_data.put('flglimit',hcm_util.get_string(v_tobfcdet,'flglimit'));
    obj_data.put('flglimit_name',get_tlistval_name('TYPELIMIT',hcm_util.get_string(v_tobfcdet,'flglimit'),global_v_lang));
    obj_data.put('amtvalue',hcm_util.get_string(v_tobfcdet,'amtvalue'));
    obj_data.put('qtyalw',hcm_util.get_string(v_tobfcdet,'qtyalw'));
    obj_data.put('qtytalw',hcm_util.get_string(v_tobfcdet,'qtytalw'));
    obj_data.put('typebf',hcm_util.get_string(v_tobfcdet,'typebf'));
    obj_data.put('coderror',200);
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  end gen_tobfcde;

  procedure insert_tobfcft as
  begin
    insert into tobfcft(codempid,dtestart,dteend,codcomp,codappr,dteappr,amtalwyr,codcreate,coduser)
    values(p_query_codempid,p_dtestart,p_dteend,p_codcomp,p_codappr,p_dteappr,p_amtalwyr,global_v_coduser,global_v_coduser);
  end insert_tobfcft;

  procedure update_tobfcft as
  begin
    update tobfcft
    set dtestart = p_dtestart,
        dteend = p_dteend,
        codcomp = p_codcomp,
        codappr = p_codappr,
        dteappr = p_dteappr,
        amtalwyr = p_amtalwyr,
        coduser = global_v_coduser
    where codempid = p_query_codempid
      and dtestart = p_dtestart;
  end;

  procedure delete_tobfcft as
  begin
    delete from tobfcft
    where codempid = p_query_codempid
      and dtestart = p_dtestart;
  end delete_tobfcft;

  procedure insert_tobfcftd as
  begin
    insert into tobfcftd(codempid,dtestart,codobf,flglimit,amtvalue,qtyalw,qtytalw,amtalw,codcreate,coduser)
    values(p_query_codempid,p_dtestart,p_codobf,p_flglimit,p_amtvalue,p_qtyalw,p_qtytalw,p_amtalw,global_v_coduser,global_v_coduser);
  end insert_tobfcftd;

  procedure update_tobfcftd as
  begin
    update tobfcftd
    set dtestart = p_dtestart,
        flglimit = p_flglimit,
        codobf = p_codobf,
        amtvalue = p_amtvalue,
        qtyalw = p_qtyalw,
        qtytalw = p_qtytalw,
        amtalw = p_amtalw,
        coduser = global_v_coduser
    where codempid = p_query_codempid
      and dtestart = p_dtestart
      and codobf = p_codobf;
 end update_tobfcftd;

 procedure delete_tobfcftd as
 begin
    delete from tobfcftd
    where codempid = p_query_codempid
      and dtestart = p_dtestart
      and codobf = p_codobf;
 end delete_tobfcftd;

 procedure delete_all_tobfcftd as
 begin
    delete from tobfcftd
    where codempid = p_query_codempid
      and dtestart = p_dtestart;
 end delete_all_tobfcftd;

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

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
        gen_detail(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure get_detail_table(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
        gen_detail_table(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_table;


  procedure get_data_from_tobfcde(json_str_input in clob, json_str_output out clob) as
    begin
    initial_value(json_str_input);
    gen_tobfcde(json_str_output);
  exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  end get_data_from_tobfcde;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    json_obj       json;
    data_obj       json;
    data_obj2      json;
    v_sum_amt_codbf  number :=0;
    v_amt_codbf  number :=0;
  begin
    initial_value(json_str_input);
    json_obj    := json(json_str_input);
    param_json  := hcm_util.get_json(json_obj,'param_json');
    for i in 0..param_json.count-1 loop
        data_obj          := hcm_util.get_json(param_json,to_char(i));
        p_codcomp         := hcm_util.get_string(data_obj,'p_codcomp');
        p_query_codempid  := upper(hcm_util.get_string(data_obj,'p_query_codempid'));
        p_dtestart        := to_date(hcm_util.get_string(data_obj,'p_dtestart'),'dd/mm/yyyy');
        p_codappr         := upper(hcm_util.get_string(data_obj,'p_codappr'));
        p_dteappr         := to_date(hcm_util.get_string(data_obj,'p_dteappr'),'dd/mm/yyyy');
        p_dteend          := to_date(hcm_util.get_string(data_obj,'p_dteend'),'dd/mm/yyyy');
        p_amtalwyr        := to_number(hcm_util.get_string(data_obj,'p_amtalwyr'));
        p_sumQtymonyer    := to_number(hcm_util.get_string(data_obj,'p_sumQtymonyer'));
        p_sumQtymony      := to_number(hcm_util.get_string(data_obj,'p_sumQtymony'));        
        p_flag            := hcm_util.get_string(data_obj,'p_flag');
        p_table           := hcm_util.get_json(data_obj,'p_table');
        begin
            select codcomp into p_codcomp
              from temploy1
             where codempid = p_query_codempid;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1 ');
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end;
        if p_flag != 'Delete' then
            check_params_tab1;
            if param_msg_error is not null then
                rollback;
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;
        end if;

        if p_flag = 'Add' then
            insert_tobfcft;
        elsif p_flag = 'Edit' then
            update_tobfcft;
        elsif p_flag = 'Delete' then
            delete_tobfcft;
            delete_all_tobfcftd;
        end if;

        for i in 0..p_table.count-1 loop
            data_obj2    := hcm_util.get_json(p_table,to_char(i));
            p_codobf     := hcm_util.get_string(data_obj2,'p_codobf');
            p_codunit    := hcm_util.get_string(data_obj2,'p_codunit');
            p_flglimit   := hcm_util.get_string(data_obj2,'p_flglimit');
            p_amtvalue   := to_number(hcm_util.get_string(data_obj2,'p_amtvalue'));
            p_qtyalw     := to_number(hcm_util.get_string(data_obj2,'p_qtyalw'));
            p_qtytalw    := to_number(hcm_util.get_string(data_obj2,'p_qtytalw'));
            p_amtalw     := to_number(hcm_util.get_string(data_obj2,'p_amtalw'));
            p_flag2      := hcm_util.get_string(data_obj2,'p_flag2');

           v_amt_codbf := nvl(p_amtvalue,0)*nvl(p_qtyalw,0);
           v_sum_amt_codbf := v_sum_amt_codbf+v_amt_codbf;
            check_params_tab2;
            if param_msg_error is not null then
                rollback;
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;

            if p_flag2 = 'Add' then
                insert_tobfcftd;
            elsif p_flag2 = 'Edit' then
                update_tobfcftd;
            elsif p_flag2 = 'Delete' then
                delete_tobfcftd;
            end if;

        end loop;   

    end loop;

    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

END HRBF4HE;

/

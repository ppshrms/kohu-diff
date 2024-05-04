--------------------------------------------------------
--  DDL for Package Body HRBF41E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF41E" AS

 procedure initial_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        p_codobf          := hcm_util.get_string_t(json_obj,'p_codobf');

  end initial_value;

  procedure check_detail as
    v_temp      varchar(1 char);
  begin
--  check null
    if p_codobf is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
  end check_detail;

  procedure check_params_tab1 as
    v_temp      varchar(1 char);
    v_chk       number := 0;
  begin
--  check null parameter
    if p_typegroup is null or p_codunit is null or p_amtvalue is null or p_desnote is null or p_flglimit is null or p_flgfamily is null or
       p_dtestart is null or p_dteend is null or p_syncond is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
    end if;

--  check null description
    if global_v_lang = '101' and p_desobfe is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    elsif global_v_lang = '102' and p_desobft is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    elsif global_v_lang = '103' and p_desobf3 is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    elsif global_v_lang = '104' and p_desobf4 is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    elsif global_v_lang = '105' and p_desobf5 is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check codunit
    begin
        select 'X' into v_temp
        from TCODUNIT
        where codcodec = p_codunit;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODUNIT');
        return;
    end;

    if p_codsize is not null then
        begin
            select 'X' into v_temp
            from tcodsize
            where codcodec = p_codsize;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODSIZE');
            return;
        end;
    end if;

    if p_dtestart > p_dteend then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

    begin
      select count(*)
        into v_chk
        from tobfcde
       where codobf = p_codobf;
    exception when no_data_found then
      v_chk := 0;
    end;
    if v_chk = 0 and p_dtestart < trunc(sysdate) then
      param_msg_error := get_error_msg_php('HR8519',global_v_lang);
      return;
    end if;
  end check_params_tab1;

  procedure check_params_tab2 as
  begin
--  check null parameters
    if p_syncond2 is null or p_qtyalw is null or p_qtytalw is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
  end check_params_tab2;

  procedure gen_index(json_str_output out clob) as
    obj_data     json_object_t;
    obj_rows     json_object_t;
    v_row        number := 0;
    v_flgused    varchar(1 char);
    v_flag       number := 0;
    cursor c1 is
        select  codobf,decode(global_v_lang, 101,desobfe,
                                             102,desobft,
                                             103,desobf3,
                                             104,desobf4,
                                             105,desobf5) desobf,dtestart,dteend
        from tobfcde
        order by codobf;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_flgused := 'N';
            v_flag := 0;
            begin
              select sum(counter) into v_flag
              from (
                  select count(*) as counter
                  from tobfcompy
                  where codobf = i.codobf
                    and rownum = 1
                  union
                  select count(*) as counter
                  from tobfinf
                  where codobf = i.codobf
                    and rownum = 1
              );
            exception when others then
              v_flag := 0;
            end;

            if v_flag > 0 then
              v_flgused := 'Y';
            else
              v_flgused := 'N';
            end if;

            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('flgused',v_flgused);
            obj_data.put('codobf',i.codobf);
            obj_data.put('desobf',i.desobf);
            obj_data.put('dtestart',to_char(i.dtestart,'dd/mm/yyyy'));
            obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);

  end gen_index;

  procedure gen_detail_tab1(json_str_output out clob) as
    obj_data     json_object_t;
    obj_data2    json_object_t;
    v_flag       varchar(50 char);
    v_count      number := 0;
    v_flgused    varchar(1 char) := 'N';

    cursor c1 is
      select codobf,typebf,typepay,typegroup,namimage,desobfe,
             desobft,desobf3,desobf4,desobf5,codunit,amtvalue,codsize,
             descsize,desnote,flglimit,flgfamily,typrelate,dtestart,dteend,
              syncond,statement,filename,decode(global_v_lang,'101',desobfe,
                                  '102',desobft,
                                  '103',desobf3,
                                  '104',desobf4,
                                  '105',desobf5) desobf
      from tobfcde
        where codobf = p_codobf;


  begin


    obj_data  := json_object_t();
    obj_data2 := json_object_t();
     v_flag    := 'Add';
    for r1 in c1 loop

         begin
            select sum(counter) into v_count
            from (
                select count(*) as counter
                from tobfcompy
                where codobf = p_codobf
                  and rownum = 1
                union
                select count(*) as counter
                from tobfinf
                where codobf = p_codobf
                  and rownum = 1
            );
          exception when others then
            v_count := 0;
        end;

        if v_count > 0 then
          v_flgused := 'Y';
        else
          v_flgused := 'N';
        end if;

      v_flag := 'Edit';
      obj_data.put('coderror',200);
      obj_data.put('flag',v_flag);
      obj_data.put('flgused',v_flgused);
      obj_data.put('codobf',r1.codobf);
      obj_data.put('typebf',r1.typebf);
      obj_data.put('typepay',r1.typepay);
      obj_data.put('typegroup',r1.typegroup);
      obj_data.put('namimage',r1.namimage);
      obj_data.put('desobf',r1.desobf);
      obj_data.put('desobfe',r1.desobfe);
      obj_data.put('desobft',r1.desobft);
      obj_data.put('desobf3',r1.desobf3);
      obj_data.put('desobf4',r1.desobf4);
      obj_data.put('desobf5',r1.desobf5);
      obj_data.put('codunit',r1.codunit);
      obj_data.put('codunit_name',get_tcodec_name('TCODUNIT',r1.codunit,global_v_lang));
      obj_data.put('amtvalue',r1.amtvalue);
      obj_data.put('codsize',r1.codsize);
      obj_data.put('descsize',r1.descsize);
      obj_data.put('desnote',r1.desnote);
      obj_data.put('flglimit',r1.flglimit);
      obj_data.put('flglimit_name',get_tlistval_name('TYPELIMIT',r1.flglimit,global_v_lang));
      obj_data.put('flgfamily',r1.flgfamily);
      obj_data.put('typrelate',r1.typrelate);
      obj_data.put('typrelate_name',get_tlistval_name('TYPRELATE',r1.typrelate,global_v_lang));
      obj_data.put('dtestart',to_char(r1.dtestart,'dd/mm/yyyy'));
      obj_data.put('dteend',to_char(r1.dteend,'dd/mm/yyyy'));

      obj_data2.put('code',r1.syncond);
      obj_data2.put('description',get_logical_desc(r1.statement));

      obj_data2.put('statement',r1.statement);

      obj_data.put('syncond',obj_data2);
      obj_data.put('filename',r1.filename);
    end loop;

    if v_flag  = 'Add' then
      obj_data.put('coderror',200);
      obj_data.put('flag',v_flag);
      obj_data.put('flgused',v_flgused);
      obj_data.put('codobf',p_codobf);
      obj_data.put('typebf','C');
      obj_data.put('typepay','1');
      obj_data.put('typegroup','2');
      obj_data.put('namimage','');
      obj_data.put('desobf','');
      obj_data.put('desobfe','');
      obj_data.put('desobft','');
      obj_data.put('desobf3','');
      obj_data.put('desobf4','');
      obj_data.put('desobf5','');
      obj_data.put('codunit','');
      obj_data.put('codunit_name','');
      obj_data.put('amtvalue','');
      obj_data.put('codsize','');
      obj_data.put('descsize','');
      obj_data.put('desnote','');
      obj_data.put('flglimit','');
      obj_data.put('flglimit_name','');
      obj_data.put('flgfamily','');
      obj_data.put('typrelate','');
      obj_data.put('typrelate_name','');
      obj_data.put('dtestart','');
      obj_data.put('dteend','');

      obj_data2.put('code','');
      obj_data2.put('description','');

      obj_data2.put('statement','');

      obj_data.put('syncond',obj_data2);
      obj_data.put('filename','');
    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  end gen_detail_tab1;

  procedure gen_detail_tab2(json_str_output out clob) as
    obj_data     json_object_t;
    obj_data2    json_object_t;
    obj_rows     json_object_t;
    v_typebf     tobfcde.typebf%type;
    v_row        number := 0;
    cursor c1 is
        select numobf,syncond,qtyalw,qtytalw,statement
        from tobfcdet
        where codobf = p_codobf
        order by codobf;
  begin

    begin
      select typebf
        into v_typebf
        from tobfcde
       where codobf = p_codobf;
    exception when others then
      v_typebf := null;
    end;

    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row + 1;
        obj_data  := json_object_t();
        obj_data2 := json_object_t();
        obj_data.put('numobf',i.numobf);
--      Add logical statement
        obj_data2.put('code',i.syncond);
--        obj_data2.put('description',get_logical_name('HRBF41E',i.syncond,global_v_lang));
        obj_data2.put('description',get_logical_desc(i.statement));
        obj_data2.put('statement',i.statement);

        obj_data.put('syncond',obj_data2);
        obj_data.put('qtyalw',i.qtyalw);
        obj_data.put('qtytalw',i.qtytalw);
        obj_data.put('typebf',v_typebf);

        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_detail_tab2;

  procedure insert_tobfcde as
  begin
    insert into tobfcde(codobf,desobfe,desobft,desobf3,desobf4,desobf5,typebf,typegroup,typepay,namimage,codunit,amtvalue,
                        codsize,descsize,desnote,flglimit,flgfamily,typrelate,dtestart,dteend,filename,syncond,
                        codcreate,coduser,statement)
    values(p_codobf,p_desobfe,p_desobft,p_desobf3,p_desobf4,p_desobf5,p_typebf,p_typegroup,p_typepay,p_namimage,p_codunit,p_amtvalue,p_codsize,
          p_descsize,p_desnote,p_flglimit,p_flgfamily,p_typrelate,p_dtestart,p_dteend,p_filename,p_syncond,global_v_coduser,global_v_coduser,p_statement);
  end insert_tobfcde;

  procedure update_tobfcde as
  begin
    update tobfcde
    set desobfe = p_desobfe,--User37 #6670 ST11 17/08/2021 desobfe,
        desobft = p_desobft,
        desobf3 = p_desobf3,
        desobf4 = p_desobf4,
        desobf5 = p_desobf5,
        typebf = p_typebf,
        typepay = p_typepay,
        typegroup = p_typegroup,
        namimage = p_namimage,
        codunit = p_codunit,
        amtvalue = p_amtvalue,
        codsize = p_codsize,
        descsize = p_descsize,
        desnote = p_desnote,
        flglimit = p_flglimit,
        flgfamily = p_flgfamily,
        typrelate = p_typrelate,
        dtestart = p_dtestart,
        dteend = p_dteend,
        filename = p_filename,
        syncond = p_syncond,
        statement = p_statement,
        coduser = global_v_coduser
    where codobf = p_codobf;

  end update_tobfcde;

  procedure delete_tobfcde as
  begin
    delete from tobfcde
    where codobf = p_codobf;
  end delete_tobfcde;

  procedure insert_tobfcdet as
    v_max_numseq    tobfcdet.numobf%type;
  begin
    select max(numobf)+1 into v_max_numseq
    from tobfcdet
    where codobf = p_codobf;

    if v_max_numseq is null then
        v_max_numseq := 1;
    end if;

    insert into tobfcdet(codobf,numobf,syncond,statement,qtyalw,qtytalw,codcreate,coduser)
--    values(p_codobf,v_max_numseq,p_syncond2,p_statement,p_qtyalw,p_qtytalw,global_v_coduser,global_v_coduser); -- user4 || 4449#538||  16/12/2022 p_statement,
    values(p_codobf,v_max_numseq,p_syncond2,p_statement2,p_qtyalw,p_qtytalw,global_v_coduser,global_v_coduser);

  end insert_tobfcdet;

  procedure update_tobfcdet as
  begin
    update tobfcdet
    set numobf = p_numobf,
        syncond = p_syncond2,
        statement = p_statement2,--User37 ST11 Recode 25/06/2021 p_statement,
        qtyalw = p_qtyalw,
        qtytalw = p_qtytalw,
        coduser = global_v_coduser
    where codobf = p_codobf
      and numobf = p_numobf;
  end update_tobfcdet;

  procedure delete_tobfcdet as
  begin
    delete from tobfcdet
    where codobf = p_codobf
      and numobf = p_numobf;
  end delete_tobfcdet;

  procedure delete_all_tobfcdet as
  begin
    delete from tobfcdet
    where codobf = p_codobf;
  end delete_all_tobfcdet;

  procedure initial_tab2(p_tab2 json_object_t) as
    data_obj       json_object_t;
  begin
    for i in 0..p_tab2.get_size-1 loop--for i in 0..p_tab2.count-1 loop
        data_obj := hcm_util.get_json_t(p_tab2,to_char(i));
        p_numobf       := hcm_util.get_string_t(data_obj,'numobf');
        p_syncond2     := hcm_util.get_string_t(hcm_util.get_json_t(data_obj,'syncond'),'code');
        p_statement    := hcm_util.get_string_t(hcm_util.get_json_t(data_obj,'syncond'),'statement');
        p_qtyalw       := to_number(hcm_util.get_string_t(data_obj,'qtyalw'));
        p_qtytalw      := to_number(hcm_util.get_string_t(data_obj,'qtytalw'));
        p_flag2        := hcm_util.get_string_t(data_obj,'p_flag2');

        check_params_tab2;
        if param_msg_error is not null then
            return;
        end if;

        if p_flag2 = 'Add' then
            insert_tobfcdet;
        elsif p_flag2 = 'Edit' then
            update_tobfcdet;
        elsif p_flag2 = 'Delete' then
            delete_tobfcdet;
        end if;
    end loop;

  end initial_tab2;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_index(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index;

  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
        gen_detail_tab1(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_tab1;

  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail_tab2(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_tab2;

  procedure save_index(json_str_input in clob, json_str_output out clob) AS
    json_obj       json_object_t;
    data_obj       json_object_t;
    data_obj2      json_object_t;
    v_count        number;
    v_count2       number;
  begin
    initial_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    for i in 0..param_json.get_size-1 loop--for i in 0..param_json.count-1 loop
        data_obj := hcm_util.get_json_t(param_json,to_char(i));
        p_codobf        := hcm_util.get_string_t(data_obj,'p_codobf');
        p_typebf        := hcm_util.get_string_t(data_obj,'p_typebf');
        p_typepay       := hcm_util.get_string_t(data_obj,'p_typepay');
        p_typegroup     := hcm_util.get_string_t(data_obj,'p_typegroup');
        p_desobfe       := hcm_util.get_string_t(data_obj,'p_desobfe');
        p_desobft       := hcm_util.get_string_t(data_obj,'p_desobft');
        p_desobf3       := hcm_util.get_string_t(data_obj,'p_desobf3');
        p_desobf4       := hcm_util.get_string_t(data_obj,'p_desobf4');
        p_desobf5       := hcm_util.get_string_t(data_obj,'p_desobf5');
        p_namimage      := hcm_util.get_string_t(data_obj,'p_namimage');
        p_codunit       := hcm_util.get_string_t(data_obj,'p_codunit');
        p_amtvalue      := hcm_util.get_string_t(data_obj,'p_amtvalue');
        p_codsize       := hcm_util.get_string_t(data_obj,'p_codsize');
        p_descsize      := hcm_util.get_string_t(data_obj,'p_descsize');
        p_desnote       := hcm_util.get_string_t(data_obj,'p_desnote');
        p_flglimit      := hcm_util.get_string_t(data_obj,'p_flglimit');
        p_flgfamily     := hcm_util.get_string_t(data_obj,'p_flgfamily');
        p_typrelate     := hcm_util.get_string_t(data_obj,'p_typrelate');
        p_dtestart      := to_date(hcm_util.get_string_t(data_obj,'p_dtestart'),'dd/mm/yyyy');
        p_dteend        := to_date(hcm_util.get_string_t(data_obj,'p_dteend'),'dd/mm/yyyy');
        p_syncond       := hcm_util.get_string_t(data_obj,'p_syncond');
        p_statement     := hcm_util.get_string_t(data_obj,'p_statement');
        p_filename      := hcm_util.get_string_t(data_obj,'p_filename');
        p_flag          := hcm_util.get_string_t(data_obj,'p_flag');
        p_tab2          := hcm_util.get_json_t(data_obj,'p_tab2');

        if p_flag != 'Delete' then
            check_params_tab1;
            if param_msg_error is not null then
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;
        end if;

       if p_flag = 'Add' then
            insert_tobfcde;
        elsif p_flag = 'Edit' then
            update_tobfcde;
        elsif p_flag = 'Delete' then

               select count(*)
               into v_count
               from tobfcompy
               where upper(codobf) = upper(p_codobf);
            if v_count > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'tobfcompy');
                     json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                return;
            end if;

               select count(*)
               into v_count2
               from tobfinf
               where upper(codobf) = upper(p_codobf);
            if v_count2 > 0 then
                     param_msg_error := get_error_msg_php('HR1450',global_v_lang,'tobfinf');
                     json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                return;
            end if;

                delete_tobfcde;
                delete_all_tobfcdet;

        end if;

        initial_tab2(p_tab2);

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

  --<<User37 ST11 Recode 25/06/2021
  procedure save_detail(json_str_input in clob, json_str_output out clob) AS
    json_obj        json_object_t;
    data_obj        json_object_t;
    data_obj2       json_object_t;
    p_param_json    json_object_t;
    json_row        json_object_t;
    v_count         number;
    v_count2        number;
    obj_syncond     json_object_t;
    obj_syncond2    json_object_t;
    v_chk           number := 0;
  begin
    initial_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    p_param_json              := hcm_util.get_json_t(json_obj,'param_json');
    data_obj := hcm_util.get_json_t(p_param_json,'tab1');
    data_obj2 := hcm_util.get_json_t(p_param_json,'tab2');

    p_codobf        := hcm_util.get_string_t(data_obj,'codobf');
    p_typebf        := hcm_util.get_string_t(data_obj,'typebf');
    p_typepay       := hcm_util.get_string_t(data_obj,'typepay');
    p_typegroup     := hcm_util.get_string_t(data_obj,'typegroup');
    p_typrelate     := hcm_util.get_string_t(data_obj,'typrelate');
    p_desobfe       := hcm_util.get_string_t(data_obj,'desobfe');
    p_desobft       := hcm_util.get_string_t(data_obj,'desobft');
    p_desobf3       := hcm_util.get_string_t(data_obj,'desobf3');
    p_desobf4       := hcm_util.get_string_t(data_obj,'desobf4');
    p_desobf5       := hcm_util.get_string_t(data_obj,'desobf5');
    p_namimage      := hcm_util.get_string_t(data_obj,'namimage');
    p_codunit       := hcm_util.get_string_t(data_obj,'codunit');
    p_amtvalue      := hcm_util.get_string_t(data_obj,'amtvalue');
    p_codsize       := hcm_util.get_string_t(data_obj,'codsize');
    p_descsize      := hcm_util.get_string_t(data_obj,'descsize');
    p_desnote       := hcm_util.get_string_t(data_obj,'desnote');
    p_flglimit      := hcm_util.get_string_t(data_obj,'flglimit');
    p_flgfamily     := hcm_util.get_string_t(data_obj,'flgfamily');

    p_dtestart      := to_date(hcm_util.get_string_t(data_obj,'dtestart'),'dd/mm/yyyy');
    p_dteend        := to_date(hcm_util.get_string_t(data_obj,'dteend'),'dd/mm/yyyy');
    obj_syncond     := hcm_util.get_json_t(data_obj,'syncond');
    p_syncond       := hcm_util.get_string_t(obj_syncond, 'code');
    p_statement     := hcm_util.get_string_t(obj_syncond, 'statement');
    p_filename      := hcm_util.get_string_t(data_obj,'filename');
    p_flag          := hcm_util.get_string_t(data_obj,'flag');

    check_params_tab1;
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    begin
      select count(*)
        into v_chk
        from tobfcde
       where codobf = p_codobf;
    exception when no_data_found then
      v_chk := 0;
    end;
    if v_chk = 0 then
      insert_tobfcde;
    else
      update_tobfcde;
    end if;

    for i in 0..data_obj2.get_size-1 loop
      json_row       := hcm_util.get_json_t(data_obj2,to_char(i));
      p_numobf       := hcm_util.get_string_t(json_row,'numobf');
      obj_syncond2   := hcm_util.get_json_t(json_row,'syncond');
      p_syncond2     := hcm_util.get_string_t(obj_syncond2, 'code');
      p_statement2   := hcm_util.get_string_t(obj_syncond2, 'statement');
      p_qtyalw       := to_number(hcm_util.get_string_t(json_row,'qtyalw'));
      p_qtytalw      := to_number(hcm_util.get_string_t(json_row,'qtytalw'));
      p_flag2        := hcm_util.get_string_t(json_row,'flg');

      check_params_tab2;
      if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        rollback;
        return;
      end if;
      begin
        select count(*)
          into v_chk
          from tobfcdet
         where codobf = p_codobf
           and numobf = p_numobf;
      exception when no_data_found then
        v_chk := 0;
      end;
      if p_flag2 = 'delete' then
        delete_tobfcdet;
      else
          if v_chk = 0 then
            insert_tobfcdet;
          else
            update_tobfcdet;
          end if;
      end if;
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
  end save_detail;

  procedure delete_index(json_str_input in clob, json_str_output out clob) AS
    json_obj        json_object_t;
    p_param_json    json_object_t;
    json_row        json_object_t;
    v_codobf        tobfcde.codobf%type;
    v_flg           varchar2(10 char);
    v_flgused       varchar2(10 char);

  begin
    initial_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    p_param_json              := hcm_util.get_json_t(json_obj,'param_json');

    for i in 0..p_param_json.get_size-1 loop
      json_row       := hcm_util.get_json_t(p_param_json,to_char(i));
      v_codobf       := hcm_util.get_string_t(json_row,'codobf');
      v_flg          := hcm_util.get_string_t(json_row,'flg');
      v_flgused      := hcm_util.get_string_t(json_row,'flgused');
      if v_flg = 'delete' then
        if nvl(v_flgused,'N') = 'Y' then
            param_msg_error := get_error_msg_php('CO0030',global_v_lang);
            return;
        else
            delete tobfcde where codobf = v_codobf;
            delete tobfcdet where codobf = v_codobf;
        end if;
      end if;
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
  end delete_index;
  -->>User37 ST11 Recode 25/06/2021
END HRBF41E;

/

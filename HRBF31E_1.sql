--------------------------------------------------------
--  DDL for Package Body HRBF31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF31E" AS

  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcompy        := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_numisr          := hcm_util.get_string_t(json_obj,'p_numisr');

    p_codcompyCopy    := hcm_util.get_string_t(json_obj,'p_codcompyCopy');
    p_numisrCopy      := hcm_util.get_string_t(json_obj,'p_numisrCopy');
    p_codisrp         := hcm_util.get_string_t(json_obj,'p_codisrp');
    p_flgisr          := hcm_util.get_string_t(json_obj,'p_flgisr');
    p_flgemp          := hcm_util.get_string_t(json_obj,'p_flgemp');
    if p_codcompyCopy is not null then
        p_flgcopy   := 'Y';
    else
        p_flgcopy   := 'N';
    end if;
  end initial_value;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
    if p_codcompy is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    begin
        select 'X' into v_temp
        from tcompny
        where codcompy = p_codcompy;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
        return;
    end;

--  check secur7
    if secur_main.secur7(p_codcompy,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;
  end check_index;

  procedure check_params1 as
    v_temp      varchar(1 char);
  begin
    if p_codcompy is null or p_namisrco is null or p_descisr is null or p_dtehlpst is null or
       p_dtehlpen is null or p_flgisr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'xxx');
        return;
    end if;

    begin
        select 'X' into v_temp
        from tcompny
        where codcompy = p_codcompy;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
        return;
    end;

    if p_dtehlpst > p_dtehlpen then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

  end check_params1;

  procedure check_params2 as
    v_temp     varchar(1 char);
  begin
    if p_descisrp is null or p_amtisrp is null or p_codecov is null or p_codfcov is null or p_condisrp is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRBF31E_2',global_v_lang,120));
        return;
    end if;

  end check_params2;

  procedure check_params3 as
  begin
    if p_amtpmiummt is null and p_amtpmiumyr is null or p_pctpmium is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRBF31E_3',global_v_lang,90));
        return;
    end if;

  end check_params3;

  procedure gen_index(json_str_output out clob) as
    obj_data     json_object_t;
    obj_rows     json_object_t;
    v_row        number := 0;
    v_count      number;
    cursor c1 is
        select numisr,decode(global_v_lang, 101,namisre,
                                            102,namisrt,
                                            103,namisr3,
                                            104,namisr4,
                                            105,namisr5) namisr,
               namisrco
          from tisrinf
         where codcompy = p_codcompy
      order by numisr;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row       := v_row + 1;
        obj_data    := json_object_t();

        begin
            select count(*)
              into v_count
              from tinsrer
             where numisr = i.numisr;
        exception when others then
            v_count := 0;
        end;

        if v_count > 0 then
            obj_data.put('flgDeleteDisabled',true);
        else
            obj_data.put('flgDeleteDisabled',false);
        end if;
        obj_data.put('numisr',i.numisr);
        obj_data.put('namisr',i.namisr);
        obj_data.put('namisrco',i.namisrco);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);
  end gen_index;

  procedure gen_detail(json_str_output out clob) as
    obj_data     json_object_t;
    v_secur      varchar2(1 char) := 'N';
    v_chk_secur  boolean := false;
    v_codcompy   tisrinf.codcompy%type;
    v_namisr     tisrinf.namisre%type;
    v_namisre    tisrinf.namisre%type;
    v_namisrt    tisrinf.namisrt%type;
    v_namisr3    tisrinf.namisr3%type;
    v_namisr4    tisrinf.namisr4%type;
    v_namisr5    tisrinf.namisr5%type;
    v_namisrco   tisrinf.namisrco%type;
    v_descisr    tisrinf.descisr%type;
    v_dtehlpst   tisrinf.dtehlpst%type;
    v_dtehlpen   tisrinf.dtehlpen%type;
    v_flgisr     tisrinf.flgisr%type;
    v_filename   tisrinf.filename%type;
    v_flag       varchar(50 char) := 'edit';
    v_count      number;
  begin

    begin
        select codcompy,namisre,namisrt,namisr3,namisr4,namisr5,
               namisrco,descisr,dtehlpst,dtehlpen,flgisr,filename,
               decode(global_v_lang, 101,namisre,
                                            102,namisrt,
                                            103,namisr3,
                                            104,namisr4,
                                            105,namisr5) namisr
        into v_codcompy,v_namisre,v_namisrt,v_namisr3,v_namisr4,v_namisr5,v_namisrco,v_descisr,v_dtehlpst,v_dtehlpen,v_flgisr,v_filename,
             v_namisr
        from tisrinf
        where numisr = nvl(p_numisrCopy,p_numisr);
    exception when no_data_found then
        v_codcompy  := '';
        v_namisre   := '';
        v_namisrt   := '';
        v_namisr3   := '';
        v_namisr4   := '';
        v_namisr5   := '';
        v_namisrco  := '';
        v_descisr   := '';
        v_dtehlpst  := '';
        v_dtehlpen  := '';
        v_flgisr    := '';
        v_filename  := '';
    end;

    begin
        select count(*)
          into v_count
          from tinsrer
         where numisr = p_numisr;
    exception when others then
        v_count := 0;
    end;

    v_chk_secur := secur_main.secur7(p_codcompy,global_v_coduser);
    if v_chk_secur then
        v_secur := 'Y';
        obj_data := json_object_t();
        obj_data.put('flgCopy',p_flgcopy);
        obj_data.put('codcompy',v_codcompy);
        obj_data.put('numisr',p_numisr);
        obj_data.put('namisr',v_namisr);
        obj_data.put('namisre',v_namisre);
        obj_data.put('namisrt',v_namisrt);
        obj_data.put('namisr3',v_namisr3);
        obj_data.put('namisr4',v_namisr4);
        obj_data.put('namisr5',v_namisr5);
        obj_data.put('namisrco',v_namisrco);
        obj_data.put('descisr',v_descisr);
        obj_data.put('dtehlpst',to_char(v_dtehlpst,'dd/mm/yyyy'));
        obj_data.put('dtehlpen',to_char(v_dtehlpen,'dd/mm/yyyy'));
        obj_data.put('flgisr',v_flgisr);
        obj_data.put('filename',v_filename);
        if v_count > 0 then
            obj_data.put('flgDisabled',true);
        else
            obj_data.put('flgDisabled',false);
        end if;
        obj_data.put('coderror',200);
    end if;

    if v_secur = 'Y' then
        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
    else
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;

  end gen_detail;

  procedure gen_detail_table(json_str_output out clob) as
    obj_data        json_object_t;
    obj_rows        json_object_t;
    obj_data2       json_object_t;
    v_row           number := 0;
    obj_table       json_object_t;
    table2_output   clob;
    v_count         number;
    cursor c1 is
        select codisrp,descisrp,amtisrp,codecov,codfcov,condisrp,statement
          from tisrpinf
         where numisr = nvl(p_numisrCopy,p_numisr);
  begin
    begin
        select count(*)
          into v_count
          from tinsrer
         where numisr = p_numisr;
    exception when others then
        v_count := 0;
    end;

    obj_rows := json_object_t();
    for i in c1 loop
        v_row       := v_row + 1;
        obj_data    := json_object_t();
        obj_data2   := json_object_t();
        obj_table   := json_object_t();
        p_codisrp   := i.codisrp;

        if p_flgcopy = 'Y' then
            obj_data.put('flgAdd',true);
        else
            obj_data.put('flgAdd',false);
        end if;
        obj_data.put('codisrp',i.codisrp);
        obj_data.put('descisrp',i.descisrp);
        obj_data.put('amtisrp',i.amtisrp);
        if i.codecov = 'Y' then
            obj_data.put('flgemp', '1');
            obj_data.put('desc_flgemp', get_label_name('HRBF31E_3',global_v_lang,70));
        else
            obj_data.put('flgemp', '2');
            obj_data.put('desc_flgemp', get_label_name('HRBF31E_3',global_v_lang,80));
        end if;
        obj_data.put('codecov',i.codecov);
        obj_data.put('codfcov',i.codfcov);
        obj_data2.put('code',i.condisrp);
        obj_data2.put('description',nvl(get_logical_desc(i.statement),''));
--        obj_data2.put('description',get_logical_name('HRBF31E',i.condisrp,global_v_lang));
        obj_data2.put('statement',trim(nvl(i.statement,' ')));
        obj_data.put('conditions',obj_data2);
        if v_count > 0 then
            obj_data.put('flgDisabled',true);
        else
            obj_data.put('flgDisabled',false);
        end if;
        gen_detail2_table(table2_output);
        obj_data.put('table',json_object_t(table2_output));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_detail_table;

  procedure gen_detail2(json_str_output out clob) as
    obj_data     json_object_t;
    obj_data2    json_object_t;
    v_tisrpinf   tisrpinf%rowtype;
    v_flag       varchar(50 char) := 'edit';
    v_count      number;
  begin
    begin
        select * into v_tisrpinf
          from tisrpinf
         where numisr = p_numisr
           and codisrp = p_codisrp;
    exception when no_data_found then
        v_tisrpinf := null;
        v_flag     := 'add';
        v_tisrpinf.codecov := 'Y';
    end;

    begin
        select count(*)
          into v_count
          from tinsrer
         where numisr = p_numisr;
    exception when others then
        v_count := 0;
    end;

    obj_data  := json_object_t();
    obj_data2 := json_object_t();

    obj_data.put('flag',v_flag);
    obj_data.put('codisrp',p_codisrp);
    obj_data.put('descisrp',v_tisrpinf.descisrp);
    obj_data.put('amtisrp',v_tisrpinf.amtisrp);
    if v_tisrpinf.codecov = 'Y' then
        obj_data.put('flgemp','1');
    elsif v_tisrpinf.codfcov = 'Y' then
        obj_data.put('flgemp','2');
    end if;
    obj_data.put('codecov',v_tisrpinf.codecov);
    obj_data.put('codfcov',v_tisrpinf.codfcov);

    obj_data2.put('code',nvl(v_tisrpinf.condisrp,''));
    obj_data2.put('description',nvl(get_logical_desc(v_tisrpinf.statement),''));
--    obj_data2.put('description',nvl(get_logical_name('HRBF31E',v_tisrpinf.condisrp,global_v_lang),''));
    obj_data2.put('statement',trim(nvl(v_tisrpinf.statement,' ')));
    obj_data.put('conditions',obj_data2);
    if v_count > 0 then
        obj_data.put('flgDisabled',true);
    else
        obj_data.put('flgDisabled',false);
    end if;
    obj_data.put('coderror',200);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  end gen_detail2;

  procedure gen_detail2_table(json_str_output out clob) as
    obj_data     json_object_t;
    obj_rows     json_object_t;
    v_row        number := 0;
    v_flgisr    tisrinf.flgisr%type;
    cursor c1 is
        select coddepen,amtpmiummt,amtpmiumyr,pctpmium
          from tisrpre
         where numisr = nvl(p_numisrCopy,p_numisr)
           and codisrp = p_codisrp;
  begin

    begin
        select flgisr
          into v_flgisr
          from tisrinf
         where numisr = nvl(p_numisrCopy,p_numisr);
    exception when no_data_found then
        v_flgisr := '1';
    end;

    if p_flgisr is not null then
        v_flgisr := p_flgisr;
    end if;

    obj_rows := json_object_t();
    for i in c1 loop
        v_row       := v_row + 1;
        obj_data    := json_object_t();

        if v_flgisr = '1' then
            obj_data.put('flgcondition','1');
            obj_data.put('amtpmium',nvl(i.amtpmiummt,0));
        else
            obj_data.put('flgcondition','4');
            obj_data.put('amtpmium',nvl(i.amtpmiumyr,0));
        end if;

        obj_data.put('coddepen',i.coddepen);
        obj_data.put('desc_coddepen',get_tlistval_name('TYPBENEFIT',i.coddepen,global_v_lang));

        obj_data.put('pctpmium',nvl(i.pctpmium,0));
        if p_numisrCopy is not null then
            obj_data.put('flgAdd',true);
        else
            obj_data.put('flgAdd',false);
        end if;
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    if v_row = 0 then
        v_row       := v_row + 1;
        obj_data    := json_object_t();
        if v_flgisr = '1' then
            obj_data.put('flgcondition','1');
        else
            obj_data.put('flgcondition','4');
        end if;
        obj_data.put('coddepen','E');
        obj_data.put('desc_coddepen',get_tlistval_name('TYPBENEFIT','E',global_v_lang));
        obj_data.put('amtpmium','');
        obj_data.put('pctpmium','');
        obj_rows.put(to_char(v_row-1),obj_data);
    end if;
    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);
  end gen_detail2_table;

  procedure update_tisrinf as
  begin
    update tisrinf
    set codcompy = p_codcompy,
        namisre = p_namisre,
        namisrt = p_namisrt,
        namisr3 = p_namisr3,
        namisr4 = p_namisr4,
        namisr5 = p_namisr5,
        namisrco = p_namisrco,
        descisr = p_descisr,
        dtehlpst = p_dtehlpst,
        dtehlpen = p_dtehlpen,
        flgisr = p_flgisr,
        filename = p_filename,
        coduser = global_v_coduser
    where numisr = p_numisr;
  end update_tisrinf;

  procedure insert_tisrinf as
  begin
    begin
        insert into tisrinf(numisr,codcompy,namisre,namisrt,namisr3,namisr4,namisr5,namisrco,descisr,dtehlpst,dtehlpen,flgisr,filename,codcreate,coduser)
        values(p_numisr,p_codcompy,p_namisre,p_namisrt,p_namisr3,p_namisr4,p_namisr5,p_namisrco,p_descisr,p_dtehlpst,p_dtehlpen,p_flgisr,p_filename,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
        update_tisrinf;
    end;
  end insert_tisrinf;

  procedure delete_tisrinf as
  begin
    delete from tisrinf
     where numisr = p_numisr;
  end delete_tisrinf;

  procedure update_tisrpinf as
  begin
    update tisrpinf
    set descisrp = p_descisrp,
        amtisrp = p_amtisrp,
        codecov = p_codecov,
        codfcov = p_codfcov,
        condisrp = p_condisrp,
        statement = p_statement,
        coduser = global_v_coduser
    where numisr = p_numisr
      and codisrp = p_codisrp;
  end update_tisrpinf;

  procedure insert_tisrpinf as
  begin
    begin
        insert into tisrpinf(numisr,codisrp,descisrp,amtisrp,codecov,codfcov,condisrp,statement,codcreate,coduser)
        values(p_numisr,p_codisrp,p_descisrp,p_amtisrp,p_codecov,p_codfcov,p_condisrp,p_statement,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
        update_tisrpinf;
    end; end insert_tisrpinf;

  procedure delete_tisrpinf as
  begin
    delete from tisrpinf
    where numisr = p_numisr
    and codisrp = p_codisrp;
  end delete_tisrpinf;

  procedure delete_all_tisrpinf as
  begin
    delete from tisrpinf
     where numisr = p_numisr;
  end delete_all_tisrpinf;

  procedure update_tisrpre as
  begin
    update tisrpre
    set amtpmiummt = p_amtpmiummt,
        amtpmiumyr = p_amtpmiumyr,
        pctpmium = p_pctpmium,
        coduser = global_v_coduser
    where numisr = p_numisr
      and codisrp = p_codisrp
      and coddepen = p_coddepen;
  end update_tisrpre;

  procedure insert_tisrpre as
  begin
    begin
        insert into tisrpre(numisr,codisrp,coddepen,amtpmiummt,amtpmiumyr,pctpmium,codcreate,coduser)
        values(p_numisr,p_codisrp,p_coddepen,p_amtpmiummt,p_amtpmiumyr,p_pctpmium,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
        update_tisrpre;
    end;
  end insert_tisrpre;

  procedure delete_tisrpre as
  begin
    delete tisrpre
     where numisr = p_numisr
       and codisrp = p_codisrp;
  end delete_tisrpre;

  procedure delete_all_tisrpre as
  begin
    delete from tisrpre
     where numisr = p_numisr;
  end delete_all_tisrpre;

  procedure initial_tisrpre_table(v_table json_object_t) as
    data_obj    json_object_t;
  begin
    for i in 0..v_table.get_size-1 loop
        data_obj        := hcm_util.get_json_t(v_table,to_char(i));
        p_coddepen      := hcm_util.get_string_t(data_obj,'coddepen');
        p_amtpmium      := to_number(hcm_util.get_string_t(data_obj,'amtpmium'));
        p_pctpmium      := to_number(hcm_util.get_string_t(data_obj,'pctpmium'));

        if p_flgisr = 1 then
            p_amtpmiumyr    := null;
            p_amtpmiummt    := p_amtpmium;
        else
            p_amtpmiummt    := null;
            p_amtpmiumyr    := p_amtpmium;
        end if;

        check_params3;
        if param_msg_error is not null then
            return;
        end if;

        insert_tisrpre;
    end loop;
  end initial_tisrpre_table;

  procedure gen_popup_copylist(json_str_output out clob) as
    obj_data     json_object_t;
    obj_rows     json_object_t;
    v_row        number := 0;

    cursor c1 is
        select codcompy,numisr,decode(global_v_lang, 101,namisre,
                                            102,namisrt,
                                            103,namisr3,
                                            104,namisr4,
                                            105,namisr5) namisr,
               dtehlpst,dtehlpen
          from tisrinf
         where /*codcompy = p_codcompy
           and*/ numisr <> p_numisr
        order by codcompy,dtehlpst desc,numisr;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        if secur_main.secur7(i.codcompy,global_v_coduser) then
            v_row  := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('numisr',i.numisr);
            obj_data.put('codcompy',i.codcompy);
            obj_data.put('namisr',i.namisr);
            obj_data.put('dtehlpst',to_char(i.dtehlpst,'dd/mm/yyyy'));
            obj_data.put('dtehlpen',to_char(i.dtehlpen,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_popup_copylist;

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

  procedure get_detail(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_detail(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail;

  procedure get_detail_table(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_detail_table(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail_table;

  procedure get_detail2(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_detail2(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail2;

  procedure get_detail2_table(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_detail2_table(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail2_table;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    json_obj       json_object_t;
    data_obj       json_object_t;
  begin
    initial_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    for i in 0..param_json.get_size-1 loop
        data_obj    := hcm_util.get_json_t(param_json,to_char(i));
        p_codcompy  := upper(hcm_util.get_string_t(data_obj,'codcompy'));
        p_numisr    := hcm_util.get_string_t(data_obj,'numisr');

        delete_tisrinf;
        delete_all_tisrpinf;
        delete_all_tisrpre;
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

  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    data_obj        json_object_t;
    detail_obj      json_object_t;
    p_flg           varchar2(100);
    p_flgemp        varchar2(1);
  begin
    initial_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    detail_obj  := hcm_util.get_json_t(json_obj,'detail');
    param_json  := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'param_json'),'rows');

    p_namisre   := hcm_util.get_string_t(detail_obj,'namisre');
    p_namisrt   := hcm_util.get_string_t(detail_obj,'namisrt');
    p_namisr3   := hcm_util.get_string_t(detail_obj,'namisr3');
    p_namisr4   := hcm_util.get_string_t(detail_obj,'namisr4');
    p_namisr5   := hcm_util.get_string_t(detail_obj,'namisr5');
    p_namisrco  := hcm_util.get_string_t(detail_obj,'namisrco');
    p_descisr   := hcm_util.get_string_t(detail_obj,'descisr');
    p_dtehlpst  := to_date(hcm_util.get_string_t(detail_obj,'dtehlpst'),'dd/mm/yyyy');
    p_dtehlpen  := to_date(hcm_util.get_string_t(detail_obj,'dtehlpen'),'dd/mm/yyyy');
    p_flgisr    := hcm_util.get_string_t(detail_obj,'flgisr');
    p_filename  := hcm_util.get_string_t(detail_obj,'filename');

    check_params1;
    if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    insert_tisrinf;

    for i in 0..param_json.get_size-1 loop
        data_obj    := hcm_util.get_json_t(param_json,to_char(i));
        p_codisrp   := hcm_util.get_string_t(data_obj,'codisrp');
        p_descisrp  := hcm_util.get_string_t(data_obj,'descisrp');
        p_amtisrp   := to_number(hcm_util.get_string_t(data_obj,'amtisrp'));
        p_condisrp  := hcm_util.get_string_t(hcm_util.get_json_t(data_obj,'conditions'),'code');
        p_statement := hcm_util.get_string_t(hcm_util.get_json_t(data_obj,'conditions'),'statement');
        p_flgemp    := hcm_util.get_string_t(data_obj,'flgemp');
        p_flgDelete := hcm_util.get_boolean_t(data_obj,'flgDelete');

        if p_flgemp = '1' then
            p_codecov   := 'Y';
            p_codfcov   := 'N';
        else
            p_codecov   := 'N';
            p_codfcov   := 'Y';
        end if;

        p_table     := hcm_util.get_json_t(hcm_util.get_json_t(data_obj,'table'),'rows');

        if p_flgDelete then
            delete_tisrpinf;
            delete_tisrpre;
        else
            insert_tisrpinf;
            delete_tisrpre;
            initial_tisrpre_table(p_table);
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

  procedure save_detail2(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    data_obj        json_object_t;
    detail_obj      json_object_t;
    detail2_obj     json_object_t;
    p_flg           varchar2(100);
    p_flgemp        varchar2(1);
    p_codisrp2      tisrpinf.codisrp%type;
  begin
    initial_value(json_str_input);
    json_obj        := json_object_t(json_str_input);
    detail_obj      := hcm_util.get_json_t(json_obj,'detail');
    detail2_obj     := hcm_util.get_json_t(json_obj,'detail2');
    p_codisrp2      := hcm_util.get_string_t(detail2_obj,'codisrp');
    param_json      := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'param_json'),'rows');

    p_namisre   := hcm_util.get_string_t(detail_obj,'namisre');
    p_namisrt   := hcm_util.get_string_t(detail_obj,'namisrt');
    p_namisr3   := hcm_util.get_string_t(detail_obj,'namisr3');
    p_namisr4   := hcm_util.get_string_t(detail_obj,'namisr4');
    p_namisr5   := hcm_util.get_string_t(detail_obj,'namisr5');
    p_namisrco  := hcm_util.get_string_t(detail_obj,'namisrco');
    p_descisr   := hcm_util.get_string_t(detail_obj,'descisr');
    p_dtehlpst  := to_date(hcm_util.get_string_t(detail_obj,'dtehlpst'),'dd/mm/yyyy');
    p_dtehlpen  := to_date(hcm_util.get_string_t(detail_obj,'dtehlpen'),'dd/mm/yyyy');
    p_flgisr    := hcm_util.get_string_t(detail_obj,'flgisr');
    p_filename  := hcm_util.get_string_t(detail_obj,'filename');

    check_params1;
    if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    insert_tisrinf;

    for i in 0..param_json.get_size-1 loop
        data_obj    := hcm_util.get_json_t(param_json,to_char(i));
        p_codisrp   := hcm_util.get_string_t(data_obj,'codisrp');
        p_descisrp  := hcm_util.get_string_t(data_obj,'descisrp');
        p_amtisrp   := to_number(hcm_util.get_string_t(data_obj,'amtisrp'));
        p_condisrp  := hcm_util.get_string_t(hcm_util.get_json_t(data_obj,'conditions'),'code');
        p_statement := hcm_util.get_string_t(hcm_util.get_json_t(data_obj,'conditions'),'statement');
        p_flgemp    := hcm_util.get_string_t(data_obj,'flgemp');
        p_flgDelete := hcm_util.get_boolean_t(data_obj,'flgDelete');

        if p_flgemp = '1' then
            p_codecov   := 'Y';
            p_codfcov   := 'N';
        else
            p_codecov   := 'N';
            p_codfcov   := 'Y';
        end if;

        p_table     := hcm_util.get_json_t(hcm_util.get_json_t(data_obj,'table'),'rows');

        if p_codisrp2 != p_condisrp then
            if (p_flgDelete) then
                delete_tisrpinf;
                delete_tisrpre;
            else
                insert_tisrpinf;
                delete_tisrpre;
                initial_tisrpre_table(p_table);
            end if;
        end if;
    end loop;

    if p_codisrp2 is not null then
        p_codisrp   := hcm_util.get_string_t(detail2_obj,'codisrp');
        p_descisrp  := hcm_util.get_string_t(detail2_obj,'descisrp');
        p_amtisrp   := to_number(hcm_util.get_string_t(detail2_obj,'amtisrp'));
        p_condisrp  := hcm_util.get_string_t(hcm_util.get_json_t(detail2_obj,'conditions'),'code');
        p_statement := hcm_util.get_string_t(hcm_util.get_json_t(detail2_obj,'conditions'),'statement');
        p_flgemp    := hcm_util.get_string_t(detail2_obj,'flgemp');

        if p_flgemp = '1' then
            p_codecov   := 'Y';
            p_codfcov   := 'N';
        else
            p_codecov   := 'N';
            p_codfcov   := 'Y';
        end if;
        param_msg_error := null;

        check_params2;


        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;

        p_table     := hcm_util.get_json_t(hcm_util.get_json_t(detail2_obj,'table'),'rows');
--        insert_tisrpinf;
--        delete_tisrpre;
--        initial_tisrpre_table(p_table);

        insert_tisrpinf;
 if p_numisrCopy is null then 
        delete_tisrpre;
        initial_tisrpre_table(p_table);
 else 
    --<< user25 Date:18/07/2021 #5894
        p_table  := hcm_util.get_json_t(json_obj,'param_json2');
        initial_tisrpre_table(p_table);
    -->> user25 Date:18/07/2021 #5894
 end if;
    end if;

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
  end save_detail2;

  procedure get_popup_copylist(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_popup_copylist(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_popup_copylist;

  procedure get_call_table(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_call_table(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_call_table;

  procedure gen_call_table(json_str_output out clob) as
    obj_data     json_object_t;
    obj_rows     json_object_t;
    v_row        number := 0;
  begin
    obj_rows := json_object_t();

    v_row := v_row + 1;
    obj_data := json_object_t();
    obj_data.put('flgcondition',p_flgisr);
    obj_data.put('coddepen','E');
    obj_data.put('desc_coddepen',get_tlistval_name('TYPBENEFIT','E',global_v_lang));
    obj_data.put('amtpmium','');
    obj_data.put('pctpmium','');
    obj_rows.put(to_char(v_row-1),obj_data);

    if p_flgemp = 2 then
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('flgcondition',p_flgisr);
        obj_data.put('coddepen','F');
        obj_data.put('desc_coddepen',get_tlistval_name('TYPBENEFIT','F',global_v_lang));
        obj_data.put('amtpmium','');
        obj_data.put('pctpmium','');
        obj_rows.put(to_char(v_row-1),obj_data);
    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_call_table;
END HRBF31E;

/

--------------------------------------------------------
--  DDL for Package Body HRBF21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF21E" AS

   procedure initial_value(json_str_input in clob) as
        json_obj json;
   begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codempid_query  := hcm_util.get_string(json_obj,'p_codempid_query');
        p_dtereqst        := to_date(hcm_util.get_string(json_obj,'p_dtereqst'),'dd/mm/yyyy');
        p_dtereqen        := to_date(hcm_util.get_string(json_obj,'p_dtereqen'),'dd/mm/yyyy');
        p_dteacdst        := to_date(hcm_util.get_string(json_obj,'p_dteacdst'),'dd/mm/yyyy');
        p_dteacden        := to_date(hcm_util.get_string(json_obj,'p_dteacden'),'dd/mm/yyyy');

        p_dteacd        := to_date(hcm_util.get_string(json_obj,'p_dteacd'),'dd/mm/yyyy');
  end initial_value;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
--  check null parameters
    if p_codempid_query is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check employee in temploy1
    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_codempid_query;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
    end;

--  check secur2
    if secur_main.secur2(p_codempid_query,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

--  check date
    if p_dtereqst > p_dtereqen then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

  end check_index;

  procedure check_description_params as
  begin
    if p_dteinform < p_dteacd then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang,'dteinform');
       return;
    end if;

    if p_dtestr < p_dteacd then
       param_msg_error := get_error_msg_php('HR2020',global_v_lang,'dtestr');
       return;
    end if;

    if p_dtesmit < p_dteacd then
       param_msg_error := get_error_msg_php('HR2020',global_v_lang,'dtesmit');
       return;
    end if;
  end check_description_params;

  procedure check_compensation_params as
  begin
--  check null parameters
    if p_typpens is null or p_despens is null or p_amtpens is null or p_dtest is null or p_dteend2 is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_dtest > p_dteend2 then
       param_msg_error := get_error_msg_php('HR2021',global_v_lang);
       return;
    end if;

  end check_compensation_params;

  procedure check_list_form_params as
  begin
--  check null parameters
    if p_description is null or p_filename is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
  end check_list_form_params;

  procedure gen_index(json_str_output out clob) as
    obj_rows    json;
    obj_data    json;
    v_row       number := 0;
    cursor c1 is
        select dtesmit,dteacd,placeacd,codcomp,stawc
          from thwccase
         where codempid = p_codempid_query
           and ((dtesmit between p_dtereqst and p_dtereqen and p_dtereqst is not null)
                or (dteacd between p_dteacdst and p_dteacden and p_dteacdst is not null))
      order by dtesmit desc;
  begin
    obj_rows := json();
    for i in c1 loop
        v_row       := v_row+1;
        obj_data    := json();
        obj_data.put('dtesmit',to_char(i.dtesmit,'dd/mm/yyyy'));
        obj_data.put('dteacd',to_char(i.dteacd,'dd/mm/yyyy'));
        obj_data.put('placeacd',i.placeacd);
        obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
        obj_data.put('stawc',i.stawc);--User37 #6034 24/08/2021
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);
  end gen_index;

  procedure gen_detail_tab1(json_str_output out clob) as
   obj_data         json;
   v_codcomp        temploy1.codcomp%type;
   v_codempmt       temploy1.codempmt%type;
   v_codclnsc       temploy2.codclnsc%type;                                       --> Peerasak || Issue# || 30/11/2022
   
   v_amtincom1      temploy3.amtincom1%type;
   v_amtincom2      temploy3.amtincom2%type;
   v_amtincom3      temploy3.amtincom3%type;
   v_amtincom4      temploy3.amtincom4%type;
   v_amtincom5      temploy3.amtincom5%type;
   v_amtincom6      temploy3.amtincom6%type;
   v_amtincom7      temploy3.amtincom7%type;
   v_amtincom8      temploy3.amtincom8%type;
   v_amtincom9      temploy3.amtincom9%type;
   v_amtincom10     temploy3.amtincom10%type;
   v_sumhur         number;
   v_sumday         number;
   v_summth         number;
   v_thwccase       thwccase%rowtype;
   v_other_income   number := 0;
  begin
    begin
        select a.codcomp, a.codempmt, b.codclnsc 
          into v_codcomp,v_codempmt, v_codclnsc                                 --> Peerasak || Issue#8748 || 30/11/2022
          from temploy1 a, temploy2 b                                           --> Peerasak || Issue#8748 || 30/11/2022
         where a.codempid = b.codempid
           and a.codempid = p_codempid_query;
    exception when no_data_found then
        v_codcomp  := '';
        v_codempmt := '';
    end;

    begin
        select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
          into v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
          from temploy3
         where codempid = p_codempid_query;
    exception when no_data_found then
        v_amtincom1  := '';
        v_amtincom2  := '';
        v_amtincom3  := '';
        v_amtincom4  := '';
        v_amtincom5  := '';
        v_amtincom6  := '';
        v_amtincom7  := '';
        v_amtincom8  := '';
        v_amtincom9  := '';
        v_amtincom10 := '';
    end;

    v_amtincom1  := stddec(v_amtincom1,p_codempid_query,hcm_secur.get_v_chken);
    v_amtincom2  := stddec(v_amtincom2,p_codempid_query,hcm_secur.get_v_chken);
    v_amtincom3  := stddec(v_amtincom3,p_codempid_query,hcm_secur.get_v_chken);
    v_amtincom4  := stddec(v_amtincom4,p_codempid_query,hcm_secur.get_v_chken);
    v_amtincom5  := stddec(v_amtincom5,p_codempid_query,hcm_secur.get_v_chken);
    v_amtincom6  := stddec(v_amtincom6,p_codempid_query,hcm_secur.get_v_chken);
    v_amtincom7  := stddec(v_amtincom7,p_codempid_query,hcm_secur.get_v_chken);
    v_amtincom8  := stddec(v_amtincom8,p_codempid_query,hcm_secur.get_v_chken);
    v_amtincom9  := stddec(v_amtincom9,p_codempid_query,hcm_secur.get_v_chken);
    v_amtincom10 := stddec(v_amtincom10,p_codempid_query,hcm_secur.get_v_chken);

    get_wage_income(v_codcomp, v_codempmt, v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5, v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10, v_sumhur, v_sumday, v_summth);

--  sum other income
    v_other_income := v_amtincom2 + v_amtincom3 + v_amtincom4 + v_amtincom5 + v_amtincom6 + v_amtincom7 + v_amtincom8 + v_amtincom9 + v_amtincom10;

    begin
        select *
          into v_thwccase
          from thwccase
         where codempid = p_codempid_query
           and dteacd = p_dteacd;
    exception when no_data_found then
        obj_data := json();
        obj_data.put('flag','Add');
        obj_data.put('sumday',v_sumday);
        obj_data.put('summth',v_summth);
        obj_data.put('codclnpriv', v_codclnsc);                                  --> Peerasak || Issue#8748 || 30/11/2022
        obj_data.put('other_income',v_other_income);
        obj_data.put('dteacd',to_char(p_dteacd,'dd/mm/yyyy'));                  --User37 #6036 24/08/2021
        obj_data.put('coderror',200);

        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
        return;
    end;
    
    obj_data := json();
    obj_data.put('flag','Edit');
    obj_data.put('addwitness',v_thwccase.addrwitness);
    obj_data.put('amtadvance',v_thwccase.amtacomp);
    obj_data.put('codappr',v_thwccase.namappr);
    obj_data.put('codclnacd', v_thwccase.codcln);               
    obj_data.put('codclnpriv', nvl(v_thwccase.codclnright,v_codclnsc));         --> Peerasak || Issue#8748 || 30/11/2022
    obj_data.put('coddistrict',v_thwccase.coddist);
    obj_data.put('codprov',v_thwccase.codprov);
    obj_data.put('codsubdist',v_thwccase.codsubdist);
    obj_data.put('desacd',v_thwccase.desnote);
    obj_data.put('desresult',v_thwccase.resultacd);
    obj_data.put('dteacd',to_char(v_thwccase.dteacd,'dd/mm/yyyy'));
    obj_data.put('dteadmit',to_char(v_thwccase.dteadmit,'dd/mm/yyyy'));
    obj_data.put('dteend',to_char(v_thwccase.dteend,'dd/mm/yyyy'));
    obj_data.put('dteinform',to_char(v_thwccase.dtenotifi,'dd/mm/yyyy'));
    obj_data.put('dtesmit',to_char(v_thwccase.dtesmit,'dd/mm/yyyy'));
    obj_data.put('dtestr',to_char(v_thwccase.dtestr,'dd/mm/yyyy'));
    obj_data.put('leave_day',to_char(v_thwccase.dtestr,'dd/mm/yyyy')||'-'||to_char(v_thwccase.dteend,'dd/mm/yyyy'));
    obj_data.put('placeacd',v_thwccase.placeacd);
    obj_data.put('namwitness',v_thwccase.namwitness);
    obj_data.put('numpatient',v_thwccase.idpatient);
    obj_data.put('numwc',v_thwccase.numwc);
    obj_data.put('stawc',v_thwccase.stawc);
    obj_data.put('flgstawc',v_thwccase.stawc);
    obj_data.put('timeacd',substr(v_thwccase.timeacd,1,2)||':'||substr(v_thwccase.timeacd,3,2));
    obj_data.put('other_income',v_other_income);
    obj_data.put('sumday',v_sumday);
    obj_data.put('summth',v_summth);
    obj_data.put('coderror',200);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  end gen_detail_tab1;

  procedure gen_detail_tab1_table(json_str_output out clob) as
     obj_data      json;
     obj_rows      json;
     v_row         number := 0;
     cursor c1 is
        select numseq,description,filename
          from thwcattch
         where codempid = p_codempid_query
           and dteacd = p_dteacd;
  begin
    obj_rows := json();
    for i in c1 loop
        v_row       := v_row+1;
        obj_data    := json();
        obj_data.put('numseq',i.numseq);
        obj_data.put('description',i.description);
        obj_data.put('filename',i.filename);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);
  end gen_detail_tab1_table;

  procedure gen_detail_tab2(json_str_output out clob) as
     obj_data      json;
     obj_rows      json;
     v_row         number := 0;
     cursor c1 is
        select typpens,despens,amtpens,dtest,dteend
          from tdwccase
         where codempid = p_codempid_query
           and dteacd = p_dteacd;
   begin
    obj_rows := json();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json();
        obj_data.put('typpens',i.typpens);
        obj_data.put('typpens_name',get_tlistval_name('TYPPENS',i.typpens,global_v_lang));
        obj_data.put('despens',i.despens);
        obj_data.put('amtpens',i.amtpens);
        obj_data.put('dtest',to_char(i.dtest,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);
  end gen_detail_tab2;

  procedure insert_thwccase as
  begin
    insert into thwccase(codempid,dteacd,codcomp,placeacd,codprov,
                         coddist,codsubdist,timeacd,dtenotifi,dtestr,
                         dteend,desnote,resultacd,namwitness,addrwitness,
                         codcln,idpatient,codclnright,amtacomp,amtpens,
                         namappr,amtday,amtmonth,amtother,dtesmit,
                         dteadmit,stawc,numwc,
                         dtecreate,codcreate,dteupd,coduser)
                  values(p_codempid_query,p_dteacd,p_codcomp,p_location,p_codprov,
                         p_coddistrict,p_codsubdist,p_timeacd,p_dteinform,p_dtestr,
                         p_dteend1,p_desacd,p_desresult,p_namwitness,p_addwitness,
                         p_codclnacd,p_numpatient,p_codclnpriv,p_amtadvance,null,
                         p_codapprove,p_amtday,p_amtmonth,p_amtother,p_dtesmit,
                         p_dteadmit,p_stawc,p_numwc,
                         sysdate,global_v_coduser,sysdate,global_v_coduser);
  end insert_thwccase;

  procedure insert_tdwccase as
  begin
    insert into tdwccase(codempid,dteacd,typpens,despens,
                         amtpens,dtest,dteend,
                         dtecreate,codcreate,dteupd,coduser)
                  values(p_codempid_query,p_dteacd,p_typpens,p_despens,
                         p_amtpens,p_dtest,p_dteend2,
                         sysdate,global_v_coduser,sysdate,global_v_coduser);
  end insert_tdwccase;

  procedure update_thwccase as
  begin
    update thwccase
       set codcomp = p_codcomp,
           placeacd = p_location,
           codprov = p_codprov,
           coddist = p_coddistrict,
           codsubdist = p_codsubdist,
           timeacd = p_timeacd,
           dtenotifi = p_dteinform,
           dtestr = p_dtestr,
           dteend = p_dteend1,
           desnote = p_desacd,
           resultacd = p_desresult,
           namwitness = p_namwitness,
           addrwitness = p_addwitness,
           codcln = p_codclnacd,
           idpatient = p_numpatient,
           codclnright = p_codclnpriv,
           amtacomp = p_amtadvance,
--           amtpens = null,
           namappr = p_codapprove,
           amtday = p_amtday,
           amtmonth = p_amtmonth,
           amtother = p_amtother,
           dtesmit = p_dtesmit,
           dteadmit = p_dteadmit,
           stawc =p_stawc,
           numwc = p_numwc,
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteacd = p_dteacd;
  end update_thwccase;

  procedure update_tdwccase as
  begin
    update tdwccase
       set typpens = p_typpens,
           despens = p_despens,
           amtpens = p_amtpens,
           dtest = p_dtest,
           dteend = p_dteend2,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteacd = p_dteacd
       and typpens = p_typpensOld;
  end update_tdwccase;

  procedure update_thwcattch as
  begin
    update thwcattch
       set description = p_description,
           filename = p_filename,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteacd = p_dteacd
       and numseq = p_numseq;
  end update_thwcattch;

  procedure insert_thwcattch as
    v_max_numseq    thwcattch.numseq%type;
  begin
    begin
        select max(numseq) into v_max_numseq
          from thwcattch
         where codempid = p_codempid_query
           and dteacd = p_dteacd;
    end;
    begin
        insert into thwcattch(codempid,dteacd,numseq,description,filename,codcreate,coduser)
        values(p_codempid_query,p_dteacd,nvl(v_max_numseq,0)+1,p_description,p_filename,global_v_coduser,global_v_coduser);
--    exception when dup_val_on_index then
--        p_numseq := nvl(v_max_numseq,0)+1;
--        update_thwcattch;
    end;
  end insert_thwcattch;

  procedure delete_thwccase as
  begin
    delete from thwccase
     where codempid = p_codempid_query
       and dteacd = p_dteacd;
  end delete_thwccase;

  procedure delete_tdwccase as
  begin
    delete from tdwccase
     where codempid = p_codempid_query
       and dteacd = p_dteacd
       and typpens = p_typpens;
  end delete_tdwccase;

  procedure delete_thwcattch as
  begin
    delete from thwcattch
     where codempid = p_codempid_query
       and dteacd = p_dteacd;
  end delete_thwcattch;

  procedure delete_thwcattch_each as
  begin
    delete from thwcattch
    where codempid = p_codempid_query
      and dteacd = p_dteacd
      and numseq = p_numseq;
  end delete_thwcattch_each;

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

  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_detail_tab1(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_tab1;

  procedure get_detail_tab1_table(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_detail_tab1_table(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_tab1_table;

  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_detail_tab2(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_tab2;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    json_obj       json;
    data_obj       json;
    data_obj2      json;
    data_obj3      json;
  begin
    initial_value(json_str_input);
    json_obj    := json(json_str_input);
    param_json  := hcm_util.get_json(json_obj,'param_json');
    for i in 0..param_json.count-1 loop
        data_obj            := hcm_util.get_json(param_json,to_char(i));
        p_codempid_query    := upper(hcm_util.get_string(data_obj,'p_codempid_query'));
        p_dteacd            := to_date(hcm_util.get_string(data_obj,'dteacd'),'dd/mm/yyyy');
        delete_thwccase;
        delete_tdwccase;
        delete_thwcattch;
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
    json_obj        json;
    data_obj        json;
    data_obj2       json;
    data_obj3       json;
    detail_obj      json;
    v_sum_amtpens   number;
  begin
    initial_value(json_str_input);
    json_obj            := json(json_str_input);

    detail_obj          := hcm_util.get_json(hcm_util.get_json(json_obj,'tab1'),'detail');
    p_addwitness        := hcm_util.get_string(detail_obj,'addwitness');
    p_amtadvance        := hcm_util.get_string(detail_obj,'amtadvance');
    p_codapprove        := upper(hcm_util.get_string(detail_obj,'codappr'));
    p_codclnacd         := hcm_util.get_string(detail_obj,'codclnacd');
    p_codclnpriv        := hcm_util.get_string(detail_obj,'codclnpriv');
    p_coddistrict       := upper(hcm_util.get_string(detail_obj,'coddistrict'));
    p_codprov           := upper(hcm_util.get_string(detail_obj,'codprov'));
    p_codsubdist        := upper(hcm_util.get_string(detail_obj,'codsubdist'));
    p_desacd            := hcm_util.get_string(detail_obj,'desacd');
    p_desresult         := hcm_util.get_string(detail_obj,'desresult');
    p_dteadmit          := to_date(hcm_util.get_string(detail_obj,'dteadmit'),'dd/mm/yyyy');
    p_dteend1           := to_date(hcm_util.get_string(detail_obj,'dteend'),'dd/mm/yyyy');
    p_dteinform         := to_date(hcm_util.get_string(detail_obj,'dteinform'),'dd/mm/yyyy');
    p_dtesmit           := to_date(hcm_util.get_string(detail_obj,'dtesmit'),'dd/mm/yyyy');
    p_dtestr            := to_date(hcm_util.get_string(detail_obj,'dtestr'),'dd/mm/yyyy');
    p_flag              := hcm_util.get_string(detail_obj,'flag');
    p_namwitness        := hcm_util.get_string(detail_obj,'namwitness');
    p_numpatient        := hcm_util.get_string(detail_obj,'numpatient');
    p_numwc             := hcm_util.get_string(detail_obj,'numwc');
    p_location          := hcm_util.get_string(detail_obj,'placeacd');
    p_stawc             := hcm_util.get_string(detail_obj,'stawc');
    p_timeacd           := replace(hcm_util.get_string(detail_obj,'timeacd'),':');

    p_amtday            := hcm_util.get_string(detail_obj,'sumday');
    p_amtmonth          := hcm_util.get_string(detail_obj,'summth');
    p_amtother          := hcm_util.get_string(detail_obj,'other_income');

    p_listform          := hcm_util.get_json(hcm_util.get_json(json_obj,'tab1'),'table');
    p_compensation      := hcm_util.get_json(json_obj,'tab2');

    begin
        select codcomp into p_codcomp
          from temploy1
         where codempid = p_codempid_query;
    exception when no_data_found then
        p_codcomp := '';
    end;

--      check desciption parameters
    check_description_params;

    --<<User37 #6030 23/08/2021
    if p_codapprove = global_v_codempid then
        param_msg_error := get_error_msg_php('BF0080',global_v_lang);
    end if;
    -->>User37 #6030 23/08/2021

    if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    if p_flag = 'Add' then
        insert_thwccase;
    elsif p_flag = 'Edit' then
        update_thwccase;
    end if;

--      loop listform for get data
    for i in 0..p_listform.count-1 loop
        data_obj3       := hcm_util.get_json(p_listform,to_char(i));
        p_numseq        := to_number(hcm_util.get_string(data_obj3,'numseq'));
        p_description   := hcm_util.get_string(data_obj3,'description');
        p_filename      := hcm_util.get_string(data_obj3,'filename');
        p_flag3         := hcm_util.get_string(data_obj3,'flg');

        if p_flag3 = 'add' then
            check_list_form_params;
            if param_msg_error is not null then
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;
            insert_thwcattch;
        elsif p_flag3 = 'edit' then
            check_list_form_params;
            if param_msg_error is not null then
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;
            update_thwcattch;
        elsif p_flag3 = 'delete' then
            delete_thwcattch_each;
        end if;
    end loop;

--      loop compensation for get data
    for i in 0..p_compensation.count-1 loop
        data_obj2 := hcm_util.get_json(p_compensation,to_char(i));
--          initial compensation parameters
        p_typpens           := hcm_util.get_string(data_obj2,'typpens');
        p_typpensOld        := hcm_util.get_string(data_obj2,'typpensOld');
        p_despens           := hcm_util.get_string(data_obj2,'despens');
        p_amtpens           := hcm_util.get_string(data_obj2,'amtpens');
        p_dtest             := to_date(hcm_util.get_string(data_obj2,'dtest'),'dd/mm/yyyy');
        p_dteend2           := to_date(hcm_util.get_string(data_obj2,'dteend'),'dd/mm/yyyy');
        p_flag2             := hcm_util.get_string(data_obj2,'flg');

--          check compensation parameters
        check_compensation_params;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;

        if p_flag2 = 'add' then
            insert_tdwccase;
        elsif p_flag2 = 'edit' then
            update_tdwccase;
        elsif p_flag2 = 'delete' then
            delete_tdwccase;
        end if;
    end loop;

    begin
        select sum(amtpens)
          into v_sum_amtpens
          from tdwccase
         where codempid = p_codempid_query
           and dteacd = p_dteacd;
    exception when others then
        v_sum_amtpens := 0;
    end;

    begin
        update thwccase
           set amtpens = v_sum_amtpens
         where codempid = p_codempid_query
           and dteacd = p_dteacd;
    exception when others then
        null;
    end;

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
END HRBF21E;

/

--------------------------------------------------------
--  DDL for Package Body HRBF90E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF90E" AS

  procedure initial_value(json_str_input in clob) as
   json_obj json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_codempid_query  := hcm_util.get_string_t(json_obj,'p_codempid_query');

  end initial_value;

  procedure check_index as
    v_temp      varchar(1 char);
    v_codcomp   temploy1.codcomp%type;
  begin
--  check null parameter
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
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
    end;

--  get codcomp
    begin
        select codcomp into v_codcomp
        from temploy1
        where codempid = p_codempid_query;
    exception when no_data_found then
        v_codcomp := '';
    end;

--  check secur3
    if secur_main.secur3(v_codcomp,p_codempid_query,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

  end check_index;

  procedure check_tab1 as
    v_temp      varchar(1 char);
  begin
    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_codempid_query;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
    end;

  end check_tab1;

  procedure check_tab2 as
    v_dob   temploy1.dteempdb%type;
  begin
    begin
        select dteempdb into v_dob
        from temploy1
        where codempid = p_codempid_query;
    exception when no_data_found then
        v_dob := '';
    end;
    if p_descsick is not null and p_dteyear is null or p_dteyear is not null and p_descsick is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if to_number(p_dteyear)+543 < 2500  then
        param_msg_error := get_error_msg_php('BF0048',global_v_lang);
        return;
    end if;

    if p_dteyear < to_char(v_dob, 'yyyy') then
        param_msg_error := get_error_msg_php('BF0061',global_v_lang);
        return;
    end if;

  end check_tab2;

  procedure check_tab3 as
  begin
    if p_descrelate is not null and p_descsick2 is null or p_descrelate is null and p_descsick2 is not null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
  end check_tab3;

  procedure gen_tab1(json_str_output out clob) as
    obj_data        json_object_t;
    v_thisheal      thisheal%rowtype;
    v_flag          varchar(50 char) := 'Edit';
    v_flgheal1_0        boolean := false;
    v_flgheal1_1        boolean := false;
    v_flgheal2_0        boolean := false;
    v_flgheal2_1        boolean := false;
    v_flgheal3_0        boolean := false;
    v_flgheal3_1        boolean := false;
    v_flgheal4_0        boolean := false;
    v_flgheal4_1        boolean := false;
    v_flgheal5_0        boolean := false;
    v_flgheal5_1        boolean := false;
    v_flgheal6_0        boolean := false;
    v_flgheal6_1        boolean := false;
    v_flgheal7_0        boolean := false;
    v_flgheal7_1        boolean := false;
    v_flgheal8_0        boolean := false;
    v_flgheal8_1        boolean := false;
    v_flgheal8_2        boolean := false;
    v_flgheal9_0        boolean := false;
    v_flgheal9_1        boolean := false;
    v_flgheal9_2        boolean := false;
    v_flgheal9_3        boolean := false;
    v_flgheal9_4        boolean := false;
    v_flgheal9_5        boolean := false;
    V_remark1       thisheal.remark1%type;
    V_remark2       thisheal.remark2%type;
    V_remark3       thisheal.remark3%type;
    V_remark4       thisheal.remark4%type;
    V_remark5       thisheal.remark5%type;
    V_remark6       thisheal.remark6%type;
    V_remark7       thisheal.remark7%type;
    V_qtymth8       thisheal.qtymth8%type;
    V_qtymth9       thisheal.qtymth9%type;
    V_qtysmoke      thisheal.qtysmoke%type;
    V_qtysmoke2     thisheal.qtysmoke2%type;
    V_qtyyear8      thisheal.qtyyear8%type;
    V_qtyyear9      thisheal.qtyyear9%type;
  begin
    begin
        select * into v_thisheal
        from thisheal
        where codempid = p_codempid_query;
    exception when no_data_found then
        v_flag     := 'Add';
        v_thisheal := null;
    end;

    if v_thisheal.flgheal1 = 0 then
        v_flgheal1_0 := true;
    else
        v_flgheal1_1 := true;
    end if;

    if v_thisheal.flgheal2 = 0 then
        v_flgheal2_0 := true;
    else
        v_flgheal2_1 := true;
    end if;

    if v_thisheal.flgheal3 = 0 then
        v_flgheal3_0 := true;
    else
        v_flgheal3_1 := true;
    end if;

    if v_thisheal.flgheal4 = 0 then
        v_flgheal4_0 := true;
    else
        v_flgheal4_1 := true;
    end if;

    if v_thisheal.flgheal5 = 0 then
        v_flgheal5_0 := true;
    else
        v_flgheal5_1 := true;
    end if;

    if v_thisheal.flgheal6 = 0 then
        v_flgheal6_0 := true;
    else
        v_flgheal6_1 := true;
    end if;

    if v_thisheal.flgheal7 = 0 then
        v_flgheal7_0 := true;
    else
        v_flgheal7_1 := true;
    end if;

    if v_thisheal.flgheal8 = 0 then
        v_flgheal8_0 := true;
    elsif v_thisheal.flgheal8 = 1 then
        v_flgheal8_1 := true;
    else
        v_flgheal8_2 := true;
    end if;

--<< user25 Date : 01/09/2021 5. BF Module #6827
    if v_thisheal.flgheal9 = 0 then
        v_flgheal9_0 := true;
    elsif v_thisheal.flgheal9 = 1 then
        v_flgheal9_1 := true;
    elsif v_thisheal.flgheal9 = 2 then
        v_flgheal9_2 := true;
    elsif v_thisheal.flgheal9 = 3 then
        v_flgheal9_3 := true;
    elsif v_thisheal.flgheal9 = 4 then
        v_flgheal9_4 := true;
    else
        v_flgheal9_5 := true;
    end if;
/*
    if v_thisheal.flgheal9 = 0 then
        v_flgheal9_0 := true;
    elsif v_thisheal.flgheal8 = 1 then
        v_flgheal9_1 := true;
    elsif v_thisheal.flgheal8 = 2 then
        v_flgheal9_2 := true;
    elsif v_thisheal.flgheal8 = 3 then
        v_flgheal9_3 := true;
    elsif v_thisheal.flgheal8 = 4 then
        v_flgheal9_4 := true;
    else
        v_flgheal9_5 := true;
    end if;
*/
-->> user25 Date : 01/09/2021 5. BF Module #6827

    obj_data := json_object_t();
    obj_data.put('coderror',200);
    obj_data.put('flgheal1_0',v_flgheal1_0);
    obj_data.put('flgheal1_1',v_flgheal1_1);
    obj_data.put('flgheal2_0',v_flgheal2_0);
    obj_data.put('flgheal2_1',v_flgheal2_1);
    obj_data.put('flgheal3_0',v_flgheal3_0);
    obj_data.put('flgheal3_1',v_flgheal3_1);
    obj_data.put('flgheal4_0',v_flgheal4_0);
    obj_data.put('flgheal4_1',v_flgheal4_1);
    obj_data.put('flgheal5_0',v_flgheal5_0);
    obj_data.put('flgheal5_1',v_flgheal5_1);
    obj_data.put('flgheal6_0',v_flgheal6_0);
    obj_data.put('flgheal6_1',v_flgheal6_1);
    obj_data.put('flgheal7_0',v_flgheal7_0);
    obj_data.put('flgheal7_1',v_flgheal7_1);
    obj_data.put('flgheal8_0',v_flgheal8_0);
    obj_data.put('flgheal8_1',v_flgheal8_1);
    obj_data.put('flgheal8_2',v_flgheal8_2);
    obj_data.put('flgheal9_0',v_flgheal9_0);
    obj_data.put('flgheal9_1',v_flgheal9_1);
    obj_data.put('flgheal9_2',v_flgheal9_2);
    obj_data.put('flgheal9_3',v_flgheal9_3);
    obj_data.put('flgheal9_4',v_flgheal9_4);
    obj_data.put('flgheal9_5',v_flgheal9_5);
    obj_data.put('remark1',v_thisheal.remark1);
    obj_data.put('remark2',v_thisheal.remark2);
    obj_data.put('remark3',v_thisheal.remark3);
    obj_data.put('remark4',v_thisheal.remark4);
    obj_data.put('remark5',v_thisheal.remark5);
    obj_data.put('remark6',v_thisheal.remark6);
    obj_data.put('remark7',v_thisheal.remark7);
    obj_data.put('qtymth8',v_thisheal.qtymth8);
    obj_data.put('qtymth9',v_thisheal.qtymth9);
    obj_data.put('qtysmoke',v_thisheal.qtysmoke);
    obj_data.put('qtysmoke2',v_thisheal.qtysmoke2);
    obj_data.put('qtyyear8',v_thisheal.qtyyear8);
    obj_data.put('qtyyear9',v_thisheal.qtyyear9);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  end gen_tab1;

  procedure gen_tab2(json_str_output out clob) as
    obj_rows        json;
    obj_data        json;
    v_row           number := 0;
    cursor c1 is
        select descsick,dteyear,numseq
        from thisheald
        where codempid = p_codempid_query
        order by numseq;
  begin
    obj_rows := json();
    for i in c1 loop
        v_row := v_row + 1;
        obj_data := json();
        obj_data.put('numseq',i.numseq);
        obj_data.put('descsick',i.descsick);
        obj_data.put('dteyear',i.dteyear);
        obj_data.put('dteyearq',1957);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_tab2;

  procedure gen_tab3(json_str_output out clob) as
    obj_rows        json;
    obj_data        json;
    v_row           number := 0;
    cursor c1 is
        select descrelate,descsick,numseq
        from thishealf
        where codempid = p_codempid_query
        order by numseq;
  begin
    obj_rows := json();
    for i in c1 loop
        v_row := v_row + 1;
        obj_data := json();
        obj_data.put('numseq',i.numseq);
        obj_data.put('descrelate',i.descrelate);
        obj_data.put('descsick',i.descsick);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_tab3;

  procedure gen_tab4(json_str_output out clob) as
    obj_data        json;
    v_desnote       thisheal.desnote%type;
  begin
    begin
        select desnote into v_desnote
        from thisheal
        where codempid = p_codempid_query;
    exception when no_data_found then
        v_desnote := '';
    end;

    obj_data := json();
    obj_data.put('desnote',v_desnote);
    obj_data.put('coderror',200);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  end gen_tab4;

  procedure initial_tab1(p_tab1 json_object_t) as
    data_obj    json_object_t;
    v_flgheal1_0        boolean := false;
    v_flgheal1_1        boolean := false;
    v_flgheal2_0        boolean := false;
    v_flgheal2_1        boolean := false;
    v_flgheal3_0        boolean := false;
    v_flgheal3_1        boolean := false;
    v_flgheal4_0        boolean := false;
    v_flgheal4_1        boolean := false;
    v_flgheal5_0        boolean := false;
    v_flgheal5_1        boolean := false;
    v_flgheal6_0        boolean := false;
    v_flgheal6_1        boolean := false;
    v_flgheal7_0        boolean := false;
    v_flgheal7_1        boolean := false;
    v_flgheal8_0        boolean := false;
    v_flgheal8_1        boolean := false;
    v_flgheal8_2        boolean := false;
    v_flgheal9_0        boolean := false;
    v_flgheal9_1        boolean := false;
    v_flgheal9_2        boolean := false;
    v_flgheal9_3        boolean := false;
    v_flgheal9_4        boolean := false;
    v_flgheal9_5        boolean := false;
  begin
    v_flgheal1_0        := hcm_util.get_boolean_t(p_tab1,'flgheal1_0');
    v_flgheal1_1        := hcm_util.get_boolean_t(p_tab1,'flgheal1_1');
    v_flgheal2_0        := hcm_util.get_boolean_t(p_tab1,'flgheal2_0');
    v_flgheal2_1        := hcm_util.get_boolean_t(p_tab1,'flgheal2_1');
    v_flgheal3_0        := hcm_util.get_boolean_t(p_tab1,'flgheal3_0');
    v_flgheal3_1        := hcm_util.get_boolean_t(p_tab1,'flgheal3_1');
    v_flgheal4_0        := hcm_util.get_boolean_t(p_tab1,'flgheal4_0');
    v_flgheal4_1        := hcm_util.get_boolean_t(p_tab1,'flgheal4_1');
    v_flgheal5_0        := hcm_util.get_boolean_t(p_tab1,'flgheal5_0');
    v_flgheal5_1        := hcm_util.get_boolean_t(p_tab1,'flgheal5_1');
    v_flgheal6_0        := hcm_util.get_boolean_t(p_tab1,'flgheal6_0');
    v_flgheal6_1        := hcm_util.get_boolean_t(p_tab1,'flgheal6_1');
    v_flgheal7_0        := hcm_util.get_boolean_t(p_tab1,'flgheal7_0');
    v_flgheal7_1        := hcm_util.get_boolean_t(p_tab1,'flgheal7_1');
    v_flgheal8_0        := hcm_util.get_boolean_t(p_tab1,'flgheal8_0');
    v_flgheal8_1        := hcm_util.get_boolean_t(p_tab1,'flgheal8_1');
    v_flgheal8_2        := hcm_util.get_boolean_t(p_tab1,'flgheal8_2');
--    v_flgheal9_0        := hcm_util.get_boolean_t(p_tab1,'flgheal9_0');
--    v_flgheal9_1        := hcm_util.get_boolean_t(p_tab1,'flgheal9_1');
--    v_flgheal9_2        := hcm_util.get_boolean_t(p_tab1,'flgheal9_2');
--    v_flgheal9_3        := hcm_util.get_boolean_t(p_tab1,'flgheal9_3');
--    v_flgheal9_4        := hcm_util.get_boolean_t(p_tab1,'flgheal9_4');
--    v_flgheal9_5        := hcm_util.get_boolean_t(p_tab1,'flgheal9_5');

    v_flgheal9_0        := nvl(hcm_util.get_boolean_t(p_tab1,'flgheal9_0'),false);
    v_flgheal9_1        := nvl(hcm_util.get_boolean_t(p_tab1,'flgheal9_1'),false);
    v_flgheal9_2        := nvl(hcm_util.get_boolean_t(p_tab1,'flgheal9_2'),false);
    v_flgheal9_3        := nvl(hcm_util.get_boolean_t(p_tab1,'flgheal9_3'),false);
    v_flgheal9_4        := nvl(hcm_util.get_boolean_t(p_tab1,'flgheal9_4'),false);
    v_flgheal9_5        := nvl(hcm_util.get_boolean_t(p_tab1,'flgheal9_5'),false);

    p_remark1         := hcm_util.get_string_t(p_tab1,'remark1');
    p_remark2         := hcm_util.get_string_t(p_tab1,'remark2');
    p_remark3         := hcm_util.get_string_t(p_tab1,'remark3');
    p_remark4         := hcm_util.get_string_t(p_tab1,'remark4');
    p_remark5         := hcm_util.get_string_t(p_tab1,'remark5');
    p_remark6         := hcm_util.get_string_t(p_tab1,'remark6');
    p_remark7         := hcm_util.get_string_t(p_tab1,'remark7');

    if v_flgheal1_0 then
        p_flgheal1 := 0;
        p_remark1   := null;
    elsif v_flgheal1_1 then
        p_flgheal1 := 1;
    end if;

    if v_flgheal2_0 then
        p_flgheal2 := 0;
        p_remark2   := null;
    elsif v_flgheal2_1 then
        p_flgheal2 := 1;
    end if;

    if v_flgheal3_0 then
        p_flgheal3 := 0;
        p_remark3   := null;
    elsif v_flgheal3_1 then
        p_flgheal3 := 1;
    end if;

    if v_flgheal4_0 then
        p_flgheal4 := 0;
        p_remark4   := null;
    elsif v_flgheal4_1 then
        p_flgheal4 := 1;
    end if;

    if v_flgheal5_0 then
        p_flgheal5 := 0;
        p_remark5   := null;
    elsif v_flgheal5_1 then
        p_flgheal5 := 1;
    end if;

    if v_flgheal6_0 then
        p_flgheal6 := 0;
        p_remark6   := null;
    elsif v_flgheal6_1 then
        p_flgheal6 := 1;
    end if;

    if v_flgheal7_0 then
        p_flgheal7 := 0;
        p_remark7   := null;
    elsif v_flgheal3_1 then
        p_flgheal7 := 1;
    end if;

    if v_flgheal8_0 then
        p_flgheal8 := 0;
    elsif v_flgheal8_1 then
        p_flgheal8 := 1;
    elsif v_flgheal8_2 then
        p_flgheal8 := 2;
    end if;

    if v_flgheal9_0 then
        p_flgheal9 := 0;
    elsif v_flgheal9_1 then
        p_flgheal9 := 1;
    elsif v_flgheal9_2 then
        p_flgheal9 := 2;
    elsif v_flgheal9_3 then
        p_flgheal9 := 3;
    elsif v_flgheal9_4 then
        p_flgheal9 := 4;
    elsif v_flgheal9_5 then
        p_flgheal9 := 5;
    end if;
    p_qtysmoke        := hcm_util.get_string_t(p_tab1,'qtysmoke');
    p_qtyyear8        := hcm_util.get_string_t(p_tab1,'qtyyear8');
    p_qtymth8         := hcm_util.get_string_t(p_tab1,'qtymth8');
    p_qtysmoke2       := hcm_util.get_string_t(p_tab1,'qtysmoke2');
    p_qtyyear9        := hcm_util.get_string_t(p_tab1,'qtyyear9');
    p_qtymth9         := hcm_util.get_string_t(p_tab1,'qtymth9');
    p_desnote         := hcm_util.get_string_t(p_tab4,'desnote');

    check_tab1;
    if param_msg_error is not null then
        return;
    end if;

   begin
         insert into thisheal(codempid,flgheal1,remark1,flgheal2,remark2,flgheal3,remark3,flgheal4,remark4,flgheal5,remark5,flgheal6,remark6
                             ,flgheal7,remark7,flgheal8,qtysmoke,qtyyear8,qtymth8,qtysmoke2,flgheal9,qtyyear9,qtymth9,desnote,codcreate,coduser)
        values(p_codempid_query,p_flgheal1,p_remark1,p_flgheal2,p_remark2,p_flgheal3,p_remark3,p_flgheal4,p_remark4,p_flgheal5,p_remark5,p_flgheal6,p_remark6
              ,p_flgheal7,p_remark7,p_flgheal8,p_qtysmoke,p_qtyyear8,p_qtymth8,p_qtysmoke2,p_flgheal9,p_qtyyear9,p_qtymth9,p_desnote,global_v_coduser,global_v_coduser);
        p_flag := 'Add';
    exception when dup_val_on_index then
        update thisheal
        set flgheal1 = p_flgheal1,
            remark1 = p_remark1,
            flgheal2 = p_flgheal2,
            remark2 = p_remark2,
            flgheal3 = p_flgheal3,
            remark3 = p_remark3,
            flgheal4 = p_flgheal4,
            remark4 = p_remark4,
            flgheal5 = p_flgheal5,
            remark5 = p_remark5,
            flgheal6 = p_flgheal6,
            remark6 = p_remark6,
            flgheal7 = p_flgheal7,
            remark7 = p_remark7,
            flgheal8 = p_flgheal8,
            qtysmoke = p_qtysmoke,
            qtyyear8 = p_qtyyear8,
            qtymth8 = p_qtymth8,
            qtysmoke2 = p_qtysmoke2,
            flgheal9 = p_flgheal9,
            qtyyear9 = p_qtyyear9,
            qtymth9 = p_qtymth9,
            desnote = p_desnote,
            coduser = global_v_coduser
        where codempid = p_codempid_query;
        p_flag := 'Edit';
    end;
  end initial_tab1;

procedure initial_tab2(p_tab2 json_object_t) as
    data_obj    json_object_t;
    v_flg       varchar2(100);
  begin
    for i in 0..p_tab2.get_size-1 loop
        data_obj          := hcm_util.get_json_t(p_tab2,to_char(i));
        p_descsick        := hcm_util.get_string_t(data_obj,'descsick');
        p_dteyear         := hcm_util.get_string_t(data_obj,'dteyear');
        p_numseq          := to_number(hcm_util.get_string_t(data_obj,'numseq'));
        v_flg             := hcm_util.get_string_t(data_obj,'flg');

        check_tab2;
        if param_msg_error is not null then
            return;
        end if;

        if v_flg = 'add' then
            select max(numseq)+1 into p_numseq
            from thisheald
            where codempid = p_codempid_query;
            if p_numseq is null then
                p_numseq := 1;
            end if;
            insert into thisheald(codempid,numseq,descsick,dteyear,codcreate,coduser)
            values(p_codempid_query,p_numseq,p_descsick,p_dteyear,global_v_coduser,global_v_coduser);
        elsif v_flg = 'edit' then
            update thisheald
            set descsick = p_descsick,
                dteyear = p_dteyear,
                coduser = global_v_coduser
            where codempid = p_codempid_query
              and numseq = p_numseq;
        elsif v_flg = 'delete' then
            delete from thisheald
            where codempid = p_codempid_query
              and numseq = p_numseq;
        end if;

    end loop;

  end initial_tab2;

procedure initial_tab3(p_tab3 json_object_t) as
    data_obj    json_object_t;
  begin
    for i in 0..p_tab3.get_size-1 loop
        data_obj          := hcm_util.get_json_t(p_tab3,to_char(i));
        p_descrelate      := hcm_util.get_string_t(data_obj,'descrelate');
        p_descsick2       := hcm_util.get_string_t(data_obj,'descsick');
        p_numseq2         := to_number(hcm_util.get_string_t(data_obj,'numseq'));
        p_flag            := hcm_util.get_string_t(data_obj,'flg');

        check_tab3;
        if param_msg_error is not null then
            return;
        end if;

        if p_flag = 'add' then
            select max(numseq)+1 into p_numseq2
            from thishealf
            where codempid = p_codempid_query;

            if p_numseq2 is null then
                p_numseq2 := 1;
            end if;

            insert into thishealf(codempid,numseq,descrelate,descsick,codcreate,coduser)
            values(p_codempid_query,p_numseq2,p_descrelate,p_descsick2,global_v_coduser,global_v_coduser);
        elsif p_flag = 'edit' then
            update thishealf
            set descrelate = p_descrelate,
                descsick = p_descsick,
                coduser = global_v_coduser
            where codempid = p_codempid_query
              and numseq = p_numseq2;
        elsif p_flag = 'delete' then
            delete from thishealf
            where codempid = p_codempid_query
              and numseq = p_numseq2;
        end if;

    end loop;

  end initial_tab3;

  procedure get_index_tab1(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_tab1(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index_tab1;

  procedure get_index_tab2(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_tab2(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index_tab2;

  procedure get_index_tab3(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_tab3(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index_tab3;

  procedure get_index_tab4(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_tab4(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index_tab4;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    json_obj    json_object_t;
    data_obj    json_object_t;
  begin
    initial_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    p_tab1              := hcm_util.get_json_t(param_json,'tab1');
    p_tab2              := hcm_util.get_json_t(param_json,'tab2');
    p_tab3              := hcm_util.get_json_t(param_json,'tab3');
    p_tab4              := hcm_util.get_json_t(param_json,'tab4');
    p_desnote           := hcm_util.get_string_t(p_tab4,'p_desnote');

    initial_tab1(p_tab1);
    if param_msg_error is null then
        initial_tab2(p_tab2);
    end if;
    if param_msg_error is null then
        initial_tab3(p_tab3);
    end if;
    if param_msg_error is not null then
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

END HRBF90E;

/

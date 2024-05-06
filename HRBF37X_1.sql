--------------------------------------------------------
--  DDL for Package Body HRBF37X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF37X" AS
  procedure initial_value(json_str_input in clob) as
   json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcomp         :=  hcm_util.get_string(json_obj,'p_codcomp');
        p_numisr          :=  hcm_util.get_string(json_obj,'p_numisr');
        p_codisrp         :=  hcm_util.get_string(json_obj,'p_codisrp');

  end initial_value;

  procedure check_index as
    v_temp     varchar(1 char);
  begin
    if p_codcomp is null or p_numisr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
    end;

--  check secur7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

--  check numisr
    begin
        select 'X' into v_temp
        from tisrinf
        where numisr = p_numisr;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TISRINF');
        return;
    end;

    begin
        select 'X' into v_temp
        from tisrinf
        where numisr = p_numisr
          and codcompy like get_codcompy(p_codcomp) || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TISRINF');
        return;
    end;

--  check codisrp
    if p_codisrp is not null then
        begin
            select 'X' into v_temp
            from tcodisrp
            where codcodec = p_codisrp;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODISRP');
            return;
        end;

        begin
            select 'X' into v_temp
            from tisrpinf
            where codisrp = p_codisrp
              and numisr = p_numisr;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TISRPINF');
            return;
        end;
    end if;


  end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_data        json;
    obj_rows        json;
    obj_data1       json;--nut 
    obj_data2       json;
    obj_rows2       json;
    v_row           number := 0;
    v_row2          number := 0;
    v_secur         varchar2(1 char) := 'N';
    v_chk_secur     boolean := false;
    v_numisr        tinsrer.numisr%type;
    v_codempid      temploy1.codempid%type;
    v_count         number := 0;
    v_desc_flgisr   varchar2(100 char);--nut 

cursor c1 is
    select codisrp,numisr,codempid, nameinsr,codsex,typrelate,dteempdb,amtisrp,codcomp, numseq
    from
        (
          select a.codisrp,a.numisr,a.codempid,get_temploy_name(a.codempid,global_v_lang) nameinsr,b.codsex,'E' typrelate,b.dteempdb,a.amtisrp,a.codcomp, 0 numseq
                from tinsrer a, temploy1 b
                where a.codcomp like p_codcomp || '%'
                  and a.numisr = p_numisr
                  and a.codisrp = nvl(p_codisrp,a.codisrp)
                  and a.flgemp = 1
                  and a.codempid = b.codempid       
        union  
                select  a.codisrp,a.numisr,a.codempid, c.nameinsr,c.codsex ,c.typrelate ,c.dteempdb , null amtisrp, null codcomp, c.numseq numseq
                from tinsrer a, temploy1 b, tinsrdp c
                where a.codcomp like p_codcomp || '%'
                  and a.numisr = p_numisr
                  and a.codisrp = nvl(p_codisrp,a.codisrp)
                  and a.flgemp = 1
                  and a.codempid = b.codempid
                  and a.codempid = c.codempid(+)
                  and a.numisr   = c.numisr(+)
        )
    where nameinsr is not null
    order by codisrp,codempid,numseq;


  begin
    --nut obj_rows := json();
    --<<nut 
    begin
        select get_tlistval_name('TYPEPAYINS',flgisr,global_v_lang)
          into v_desc_flgisr
          from tisrinf
         where numisr = p_numisr;
    exception when no_data_found then
        v_desc_flgisr := '';
    end;
    obj_data  := json();
    obj_data.put('desc_flgisr',v_desc_flgisr);
    -->>Nut 
    obj_rows := json();
    for i in c1 loop
        v_count := v_count+1;
        v_chk_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_chk_secur then
            v_numisr := i.numisr;
            v_codempid := i.codempid;
            v_secur := 'Y';
            v_row := v_row + 1;
            --<<Nut 
            obj_data2 := json();
            obj_data2.put('numisr',i.numisr);
            /*obj_data2.put('codisrp',i.codisrp);
            obj_data2.put('codisrp_name',get_tcodec_name('TCODISRP',i.codisrp,global_v_lang));
            obj_data2.put('codempid',i.codempid);
            obj_data2.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data2.put('nameinsr',i.nameinsr);
            obj_data2.put('typrelate',i.typrelate);
            obj_data2.put('typrelate_name',get_tlistval_name('TTYPRELATE',i.typrelate,global_v_lang));
            obj_data2.put('codsex',i.codsex);
            obj_data2.put('codsex_name',get_tlistval_name('NAMSEX',i.codsex,global_v_lang));
            obj_data2.put('dteempdb',to_char(i.dteempdb,'dd/mm/yyyy'));
            obj_data2.put('amtisrp',i.amtisrp);
            obj_data2.put('codcomp',i.codcomp);
            obj_data2.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));*/
            obj_rows.put(to_char(v_row-1),obj_data2);
            /*obj_data  := json();
            obj_data.put('numisr',i.numisr);
            obj_data.put('codisrp',i.codisrp);
            obj_data.put('codisrp_name',get_tcodec_name('TCODISRP',i.codisrp,global_v_lang));
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('nameinsr',i.nameinsr);
            obj_data.put('typrelate',i.typrelate);
            obj_data.put('typrelate_name',get_tlistval_name('TTYPRELATE',i.typrelate,global_v_lang));
            obj_data.put('codsex',i.codsex);
            obj_data.put('codsex_name',get_tlistval_name('NAMSEX',i.codsex,global_v_lang));
            obj_data.put('dteempdb',to_char(i.dteempdb,'dd/mm/yyyy'));
            obj_data.put('amtisrp',i.amtisrp);
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);*/
            -->>Nut 
        end if;
    end loop;
    obj_data2.put('table', obj_rows);
    --obj_rows.put(to_char(v_row-1),obj_data1);

    if obj_rows.count() = 0 and v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TINSRER');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    elsif obj_rows.count() = 0 and v_count > 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    if v_secur = 'Y' then
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end if;
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

  --<<nut 
  procedure gen_detail(json_str_output out clob) as
    obj_data        json_object_t;
    v_tobfcomp      tobfcomp%rowtype;
    v_flag          varchar(50 char) := '';
    v_errorno       varchar2(100);
    v_flgvoucher    varchar2(1 char);
    v_flgtranpy     varchar2(1 char);
    v_desc_flgisr   varchar2(1000 char);
    v_count         number := 0;
    v_secur         varchar2(1 char) := 'N';
    v_chk_secur     boolean;
    obj_table       json_object_t;
    clob_table      clob;

    cursor c1 is
        select codisrp,numisr,codempid, nameinsr,codsex,typrelate,dteempdb,amtisrp,codcomp, numseq
        from
            (
              select a.codisrp,a.numisr,a.codempid,get_temploy_name(a.codempid,global_v_lang) nameinsr,b.codsex,'E' typrelate,b.dteempdb,a.amtisrp,a.codcomp, 0 numseq
                    from tinsrer a, temploy1 b
                    where a.codcomp like p_codcomp || '%'
                      and a.numisr = p_numisr
                      and a.codisrp = nvl(p_codisrp,a.codisrp)
                      and a.flgemp = 1
                      and a.codempid = b.codempid       
            union  
                select  a.codisrp,a.numisr,a.codempid, c.nameinsr,c.codsex ,c.typrelate ,c.dteempdb , null amtisrp, null codcomp, c.numseq numseq
                from tinsrer a, temploy1 b, tinsrdp c
                where a.codcomp like p_codcomp || '%'
                  and a.numisr = p_numisr
                  and a.codisrp = nvl(p_codisrp,a.codisrp)
                  and a.flgemp = 1
                  and a.codempid = b.codempid
                  and a.codempid = c.codempid(+)
                  and a.numisr   = c.numisr(+)
            )
        where nameinsr is not null
        order by codisrp,codempid,numseq;
    begin
        obj_table := json_object_t();
        for i in c1 loop
            v_count := v_count+1;
            v_chk_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if v_chk_secur then
                v_secur := 'Y';
                exit;
            end if;
        end loop;
        if v_count > 0 and v_secur = 'Y' then
            begin
                select get_tlistval_name('TYPEPAYINS',flgisr,global_v_lang)
                  into v_desc_flgisr
                  from tisrinf
                 where numisr = p_numisr;
            exception when no_data_found then
                v_desc_flgisr := '';
            end;
            obj_data := json_object_t();
            obj_data.put('desc_flgisr',v_desc_flgisr);

            gen_detail_table(clob_table);
            obj_data.put('table',json_object_t(clob_table));

            obj_data.put('coderror',200);
            json_str_output := obj_data.to_clob;
        elsif v_count = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TINSRER');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        elsif v_secur = 'N' then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) AS
    BEGIN
        initial_value(json_str_input);
        gen_detail(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END get_detail;

    procedure gen_detail_table(json_str_output out clob) as
        obj_rows        json_object_t;
        obj_data        json_object_t;
        obj_data_att    json_object_t;
        obj_row_att     json_object_t;
        v_row           number := 0;
        v_row_att       number := 0;
        v_amtvalue      tobfcde.amtvalue%type;
        v_codunit       tobfcde.codunit%type;
        v_typebf        tobfcde.typebf%type;
        v_codobf        tobfcde.codobf%type;
        v_costcenter    tcenter.costcent%type;
        v_staemp        temploy1.staemp%type;
        v_codpos        temploy1.codpos%type;
        v_dteefpos      date;
        v_flgtranpy     varchar2(1 char);
        v_error         varchar2(100 char);
        v_tobfcomp      tobfcomp%rowtype;
        v_amtwidrw      number;
        v_secur         varchar2(1 char) := 'Y';
        v_count         number := 0;
        v_chk_secur     boolean;

        ---------------------
        cursor c1 is
            select codisrp,numisr,codempid, nameinsr,codsex,typrelate,dteempdb,amtisrp,codcomp, numseq
            from
                (
                  select a.codisrp,a.numisr,a.codempid,get_temploy_name(a.codempid,global_v_lang) nameinsr,b.codsex,'E' typrelate,b.dteempdb,a.amtisrp,a.codcomp, 0 numseq
                        from tinsrer a, temploy1 b
                        where a.codcomp like p_codcomp || '%'
                          and a.numisr = p_numisr
                          and a.codisrp = nvl(p_codisrp,a.codisrp)
                          and a.flgemp = 1
                          and a.codempid = b.codempid       
                union  
                        select  a.codisrp,a.numisr,a.codempid, c.nameinsr,c.codsex ,c.typrelate ,c.dteempdb , null amtisrp, null codcomp, c.numseq numseq
                        from tinsrer a, temploy1 b, tinsrdp c
                        where a.codcomp like p_codcomp || '%'
                          and a.numisr = p_numisr
                          and a.codisrp = nvl(p_codisrp,a.codisrp)
                          and a.flgemp = 1
                          and a.codempid = b.codempid
                          and a.codempid = c.codempid(+)
                          and a.numisr   = c.numisr(+)
                )
            where nameinsr is not null
            order by codisrp,codempid,numseq;
    begin
        obj_rows := json_object_t();
        for i in c1 loop
            v_count := v_count+1;
            v_chk_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if v_chk_secur then
                v_row := v_row + 1;
                v_secur := 'Y';
                obj_data := json_object_t(); 
                obj_data.put('numisr',i.numisr);
                obj_data.put('codisrp',i.codisrp);
                obj_data.put('codisrp_name',get_tcodec_name('TCODISRP',i.codisrp,global_v_lang));
                obj_data.put('codempid',i.codempid);
                obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('nameinsr',i.nameinsr);
                obj_data.put('typrelate',i.typrelate);
                obj_data.put('typrelate_name',get_tlistval_name('TTYPRELATE',i.typrelate,global_v_lang));
                obj_data.put('codsex',i.codsex);
                obj_data.put('codsex_name',get_tlistval_name('NAMSEX',i.codsex,global_v_lang));
                obj_data.put('dteempdb',to_char(i.dteempdb,'dd/mm/yyyy'));
                obj_data.put('amtisrp',i.amtisrp);
                obj_data.put('codcomp',i.codcomp);
                obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));
                obj_data.put('coderror',200);
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;

--        if v_count = 0 then
--            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TINSRER');
--            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--            return;
--        elsif v_secur = 'N' then
--            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
--            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--            return;
--        end if;
        json_str_output := obj_rows.to_clob;
    end gen_detail_table;

    procedure get_detail_table(json_str_input in clob, json_str_output out clob) AS
    BEGIN
        initial_value(json_str_input);
        gen_detail_table(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END get_detail_table;

    -->>nut 
END HRBF37X;

/

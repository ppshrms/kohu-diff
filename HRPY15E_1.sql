--------------------------------------------------------
--  DDL for Package Body HRPY15E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY15E" as

  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_empname  := hcm_service.get_empname(json_str_input);
  end initial_value;

  procedure check_get_index(p_codcompy varchar2,p_dteeffec date) as
    v_secure    varchar2(4000 char) := null;
    v_check_company boolean;
    v_check_dteeffec boolean;
  begin
    v_check_company := check_has_codcompy(p_codcompy);
    if v_check_company = false then
        return;
    end if;
    v_secure        := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcompy);
    if v_secure is not null then
        param_msg_error := v_secure;
    end if;
--    v_check_dteeffec := check_dteeffec_index(p_codcompy,p_dteeffec);
--    if v_check_company = false then
--        return;
--    end if;
  end;

  function set_index_obj_data(tcontrpy_rec tcontrpy%rowtype) return json_object_t is
    obj_data    json_object_t;
    v_codempid  varchar2(10 char) := '';
  begin
    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('codcompy',tcontrpy_rec.codcompy);
    obj_data.put('dteeffec',to_char(tcontrpy_rec.dteeffec, 'dd/mm/yyyy'));
    obj_data.put('codpaypy1',tcontrpy_rec.codpaypy1);
    obj_data.put('codpaypy2',tcontrpy_rec.codpaypy2);
    obj_data.put('codpaypy3',tcontrpy_rec.codpaypy3);
    obj_data.put('codpaypy4',tcontrpy_rec.codpaypy4);
    obj_data.put('codpaypy5',tcontrpy_rec.codpaypy5);
    obj_data.put('codpaypy6',tcontrpy_rec.codpaypy6);
    obj_data.put('codpaypy7',tcontrpy_rec.codpaypy7);
    obj_data.put('codpaypy8',tcontrpy_rec.codpaypy8);
    obj_data.put('codpaypy9',tcontrpy_rec.codpaypy9);
    obj_data.put('codpaypy10',tcontrpy_rec.codpaypy10);
    obj_data.put('codpaypy11',tcontrpy_rec.codpaypy11);
    obj_data.put('codpaypy12',tcontrpy_rec.codpaypy12);
    obj_data.put('codpaypy13',tcontrpy_rec.codpaypy13);
    obj_data.put('codpaypy14',tcontrpy_rec.codpaypy14);
    obj_data.put('typesitm',tcontrpy_rec.typesitm);
    obj_data.put('typededtax',tcontrpy_rec.typededtax);
    obj_data.put('amtminsoc',tcontrpy_rec.amtminsoc);
    obj_data.put('amtmaxsoc',tcontrpy_rec.amtmaxsoc);
    obj_data.put('qtyage',tcontrpy_rec.qtyage);
    obj_data.put('flgfml',tcontrpy_rec.flgfml);
    obj_data.put('flgfmlsc',tcontrpy_rec.flgfmlsc);
    obj_data.put('syncond',tcontrpy_rec.syncond);
    obj_data.put('statement',tcontrpy_rec.statement);
    obj_data.put('pctsoc',tcontrpy_rec.pctsoc);
    obj_data.put('pctsocc',tcontrpy_rec.pctsocc);
    obj_data.put('desc_syncond', get_logical_name('HRPY15E',tcontrpy_rec.syncond,global_v_lang));
    obj_data.put('codcurr',tcontrpy_rec.codcurr);
    obj_data.put('dteupd',to_char(tcontrpy_rec.dteupd, 'dd/mm/yyyy'));
    obj_data.put('codempid_edit',get_codempid(tcontrpy_rec.coduser));
    obj_data.put('editby',get_codempid(tcontrpy_rec.coduser)||' - '||get_temploy_name(get_codempid(tcontrpy_rec.coduser),global_v_lang));
    return obj_data;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    json_obj            json_object_t;
    obj_data            json_object_t;
    obj_row             json_object_t;
    p_codcompy          varchar2(10 char);
    p_dteeffec          date;
    tcontrpy_rec        tcontrpy%rowtype;
    v_found_count       number := 0;
    v_not_found_count   number := 0;
    v_after_found_count number := 0;
    v_secure            varchar2(4000 char) := null;
    v_check_company     boolean;
    v_codcurr           varchar2(4 char) := null;
    v_dteeffec          date;

    cursor c_foundcount is
        select count(*) as found_count
          from tcontrpy
         where codcompy = p_codcompy
           and trunc(dteeffec) = p_dteeffec;

    cursor c_notfoundcount is
        select count(*) as notfound_count,max(dteeffec) as dteeffec
          from tcontrpy
         where codcompy = p_codcompy
           and dteeffec = (
                        select max(dteeffec)
                        from tcontrpy
                        where dteeffec <= p_dteeffec and
                        codcompy = p_codcompy
                    );

    cursor c_aftercount is
        select count(*) as notfound_count,min(dteeffec) as dteeffec
          from tcontrpy
         where codcompy = p_codcompy
           and dteeffec = (
                        select min(dteeffec)
                        from tcontrpy
                        where dteeffec > p_dteeffec and
                        codcompy = p_codcompy
                    );

  begin
    initial_value(json_str_input);
    json_obj        := json_object_t(json_str_input);
    p_codcompy      := hcm_util.get_string_t(json_obj,'codcomp');
    p_dteeffec      := to_date(hcm_util.get_string_t(json_obj,'dteeffec'), 'dd/mm/yyyy');
    check_get_index(p_codcompy,p_dteeffec);
    if param_msg_error is not null then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
    obj_row         := json_object_t();
    obj_data        := json_object_t();

    -- c_vfoundcount
    for r1 in c_foundcount loop
        v_found_count := r1.found_count;
        exit;
    end loop;

    -- c_vnotfoundcount
    for r2 in c_notfoundcount loop
        v_not_found_count := r2.notfound_count;
        v_dteeffec := r2.dteeffec;
        exit;
    end loop;



    if v_found_count > 0 then
        begin
            select *
              into tcontrpy_rec
              from tcontrpy
             where codcompy = p_codcompy
               and trunc(dteeffec) = p_dteeffec
          order by dteeffec;

            obj_data := set_index_obj_data(tcontrpy_rec);
            if (p_dteeffec < trunc(sysdate)) then
                obj_data.put('canedit',false);
                obj_data.put('warning',get_error_msg_php('HR1501',global_v_lang));
            else
                obj_data.put('flgsave','edit');
                obj_data.put('canedit',true);
            end if;
        exception when others then null;
        end;
    else
        if v_not_found_count > 0 then
            begin
                select *
                  into tcontrpy_rec
                  from tcontrpy
                 where codcompy = p_codcompy
                   and dteeffec = v_dteeffec
              order by dteeffec desc;
            exception when others then
                null;
            end;
            obj_data := set_index_obj_data(tcontrpy_rec);
            if p_dteeffec >= trunc(sysdate) then
                obj_data.put('flgsave','add');
                obj_data.put('canedit',true);
                obj_data.put('typededtax',1);
                obj_data.put('typesitm',1);
                obj_data.put('flgfmlsc',4);
            else
                obj_data.put('canedit',false);
                obj_data.put('warning',get_error_msg_php('HR1501',global_v_lang));
            end if;
        else
            for r3 in c_aftercount loop
                v_after_found_count := r3.notfound_count;
                v_dteeffec := r3.dteeffec;
                exit;
            end loop;

            if v_after_found_count > 0 then
                begin
                    select *
                      into tcontrpy_rec
                      from tcontrpy
                     where codcompy = p_codcompy
                       and dteeffec = v_dteeffec
                  order by dteeffec desc;
                exception when others then
                    null;
                end;
                obj_data := set_index_obj_data(tcontrpy_rec);
                obj_data.put('canedit',false);
                obj_data.put('warning',get_error_msg_php('HR1501',global_v_lang));
            else
                begin
                    select codcurr
                      into v_codcurr
                      from tcontrpy
                     where codcompy = p_codcompy
                       and dteeffec = ( select max(dteeffec)
                                          from tcontrpy
                                         where dteeffec <= p_dteeffec );
                exception when no_data_found then
                    v_codcurr := null;
                end;
                obj_data.put('coderror','200');
                obj_data.put('codcompy',p_codcompy);
                obj_data.put('dteeffec',to_char(p_dteeffec, 'dd/mm/yyyy'));
                obj_data.put('codcurr',v_codcurr);
                obj_data.put('flgsave','add');
                obj_data.put('canedit',true);
            end if;

        end if;
    end if;
    obj_row.put(1,obj_data);
    json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    v_codcompy      varchar2(4 char);
    v_dteeffec      date;
    v_codpaypy1     varchar2(4 char);
    v_codpaypy2     varchar2(4 char);
    v_codpaypy3     varchar2(4 char);
    v_codpaypy4     varchar2(4 char);
    v_codpaypy5     varchar2(4 char);
    v_codpaypy6     varchar2(4 char);
    v_codpaypy7     varchar2(4 char);
    v_codpaypy8     varchar2(4 char);
    v_codpaypy9     varchar2(4 char);
    v_codpaypy10    varchar2(4 char);
    v_codpaypy11    varchar2(4 char);
    v_codpaypy12    varchar2(4 char);
    v_codpaypy13    varchar2(4 char);
    v_codpaypy14    varchar2(4 char);
    v_typesitm      varchar2(1 char);
    v_typededtax    varchar2(1 char);
    v_amtminsoc     number(8,2);
    v_amtmaxsoc     number(8,2);
    v_pctsocc       tcontrpy.pctsocc%type;
    v_qtyage        number;
    v_flgfml        varchar2(1 char);
    v_flgfmlsc      varchar2(1 char);
    v_syncond       varchar2(1000 char);
    v_pctsoc        number(5,2);
    v_codcurr       varchar2(4 char);
    v_flgsave       varchar2(6 char);
    v_statement     clob;
  begin
    initial_value(json_str_input);
    json_obj   := json_object_t(json_str_input);
    check_save(json_str_input);
    if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    v_codcompy      := hcm_util.get_string_t(json_obj,'codcompy');
    v_dteeffec      := to_date(hcm_util.get_string_t(json_obj,'dteeffec'),'dd/mm/yyyy');
    v_codpaypy1     := hcm_util.get_string_t(json_obj,'codpaypy1');
    v_codpaypy2     := hcm_util.get_string_t(json_obj,'codpaypy2');
    v_codpaypy3     := hcm_util.get_string_t(json_obj,'codpaypy3');
    v_codpaypy4     := hcm_util.get_string_t(json_obj,'codpaypy4');
    v_codpaypy5     := hcm_util.get_string_t(json_obj,'codpaypy5');
    v_codpaypy6     := hcm_util.get_string_t(json_obj,'codpaypy6');
    v_codpaypy7     := hcm_util.get_string_t(json_obj,'codpaypy7');
    v_codpaypy8     := hcm_util.get_string_t(json_obj,'codpaypy8');
    v_codpaypy9     := hcm_util.get_string_t(json_obj,'codpaypy9');
    v_codpaypy10    := hcm_util.get_string_t(json_obj,'codpaypy10');
    v_codpaypy11    := hcm_util.get_string_t(json_obj,'codpaypy11');
    v_codpaypy12    := hcm_util.get_string_t(json_obj,'codpaypy12');
    v_codpaypy13    := hcm_util.get_string_t(json_obj,'codpaypy13');
    v_codpaypy14    := hcm_util.get_string_t(json_obj,'codpaypy14');
    v_typesitm      := hcm_util.get_string_t(json_obj,'typesitm');
    v_typededtax    := hcm_util.get_string_t(json_obj,'typededtax');
    v_amtminsoc     := to_number(hcm_util.get_string_t(json_obj,'amtminsoc'));
    v_amtmaxsoc     := to_number(hcm_util.get_string_t(json_obj,'amtmaxsoc'));
    v_qtyage        := to_number(hcm_util.get_string_t(json_obj,'qtyage'));
    v_flgfml        := hcm_util.get_string_t(json_obj,'flgfml');
    v_flgfmlsc      := hcm_util.get_string_t(json_obj,'flgfmlsc');
    v_syncond       := hcm_util.get_string_t(json_obj,'syncond');
    v_pctsoc        := to_number(hcm_util.get_string_t(json_obj,'pctsoc'));
    v_codcurr       := hcm_util.get_string_t(json_obj,'codcurr');
    v_flgsave       := hcm_util.get_string_t(json_obj,'flgsave');
    v_statement     := hcm_util.get_string_t(json_obj,'statement');
    v_pctsocc       := hcm_util.get_string_t(json_obj,'pctsocc');
    begin
        if v_flgsave = 'add' then
          insert into tcontrpy ( codcompy, dteeffec, codpaypy1, codpaypy2, codpaypy3, codpaypy4, codpaypy5, codpaypy6,
                                 codpaypy7, codpaypy8, codpaypy9, codpaypy10, codpaypy11, codpaypy12, codpaypy13, codpaypy14,
                                 typesitm, typededtax, amtminsoc, amtmaxsoc, qtyage, flgfml, flgfmlsc,
                                 syncond, pctsoc, codcurr, dtecreate, codcreate, coduser, statement, pctsocc )
               values ( v_codcompy, v_dteeffec, v_codpaypy1, v_codpaypy2, v_codpaypy3, v_codpaypy4, v_codpaypy5, v_codpaypy6,
                                 v_codpaypy7, v_codpaypy8, v_codpaypy9, v_codpaypy10, v_codpaypy11, v_codpaypy12, v_codpaypy13, v_codpaypy14,
                                 v_typesitm, v_typededtax, v_amtminsoc, v_amtmaxsoc, v_qtyage, v_flgfml, v_flgfmlsc,
                                 v_syncond, v_pctsoc, v_codcurr, sysdate, global_v_coduser, global_v_coduser, v_statement, v_pctsocc );
        elsif v_flgsave = 'edit' then
            update tcontrpy
            set codpaypy1   = v_codpaypy1,
                codpaypy2   = v_codpaypy2,
                codpaypy3   = v_codpaypy3,
                codpaypy4   = v_codpaypy4,
                codpaypy5   = v_codpaypy5,
                codpaypy6   = v_codpaypy6,
                codpaypy7   = v_codpaypy7,
                codpaypy8   = v_codpaypy8,
                codpaypy9   = v_codpaypy9,
                codpaypy10  = v_codpaypy10,
                codpaypy11  = v_codpaypy11,
                codpaypy12  = v_codpaypy12,
                codpaypy13  = v_codpaypy13,
                codpaypy14  = v_codpaypy14,
                typesitm    = v_typesitm,
                typededtax  = v_typededtax,
                amtminsoc   = v_amtminsoc,
                amtmaxsoc   = v_amtmaxsoc,
                qtyage      = v_qtyage,
                flgfml      = v_flgfml,
                flgfmlsc    = v_flgfmlsc,
                syncond     = v_syncond,
                pctsoc      = v_pctsoc,
                codcurr     = v_codcurr,
                dteupd      = sysdate,
                coduser     = global_v_coduser,
                statement   = v_statement,
                pctsocc     = v_pctsocc
            where
                codcompy = v_codcompy and
                dteeffec = v_dteeffec;
        end if;
    end;
    if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
    else
        rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure check_save(json_str_input in clob) as
    json_obj     json_object_t;
    c_codcompy   varchar2(4 char);
    c_codpaypy1  varchar2(4 char);
    c_codpaypy2  varchar2(4 char);
    c_codpaypy3  varchar2(4 char);
    c_codpaypy4  varchar2(4 char);
    c_codpaypy5  varchar2(4 char);
    c_codpaypy8  varchar2(4 char);
    c_codpaypy9  varchar2(4 char);
    c_codpaypy10 varchar2(4 char);
    c_codpaypy11 varchar2(4 char);
    c_codpaypy12 varchar2(4 char);
    c_codpaypy13 varchar2(4 char);
    c_codpaypy14 varchar2(4 char);
    c_amtminsoc  varchar2(10 char);
    c_amtmaxsoc  varchar2(10 char);
  begin
    json_obj    := json_object_t(json_str_input);
    c_codcompy  := hcm_util.get_string_t(json_obj,'codcompy');
    c_codpaypy1 := hcm_util.get_string_t(json_obj,'codpaypy1');
    c_codpaypy2 := hcm_util.get_string_t(json_obj,'codpaypy2');
    c_codpaypy3 := hcm_util.get_string_t(json_obj,'codpaypy3');
    c_codpaypy4 := hcm_util.get_string_t(json_obj,'codpaypy4');
    c_codpaypy5 := hcm_util.get_string_t(json_obj,'codpaypy5');
    c_codpaypy8 := hcm_util.get_string_t(json_obj,'codpaypy8');
    c_codpaypy9 := hcm_util.get_string_t(json_obj,'codpaypy9');
    c_codpaypy10 := hcm_util.get_string_t(json_obj,'codpaypy10');
    c_codpaypy11 := hcm_util.get_string_t(json_obj,'codpaypy11');
    c_codpaypy12 := hcm_util.get_string_t(json_obj,'codpaypy12');
    c_codpaypy13 := hcm_util.get_string_t(json_obj,'codpaypy13');
    c_codpaypy14 := hcm_util.get_string_t(json_obj,'codpaypy14');
    c_amtminsoc := hcm_util.get_string_t(json_obj,'amtminsoc');
    c_amtmaxsoc := hcm_util.get_string_t(json_obj,'amtmaxsoc');

    if check_codpay(c_codpaypy1,'PY0003',c_codcompy,'6') = false then
        return;
    end if;
    if check_codpay(c_codpaypy2,'PY0031',c_codcompy,'4','5') = false then
        return;
    end if;
    if check_codpay(c_codpaypy3,'PY0031',c_codcompy,'4','5') = false then
        return;
    end if;
    if check_codpay(c_codpaypy4,'PY0030',c_codcompy,'2','3') = false then
        return;
    end if;
    if check_codpay(c_codpaypy5,'PY0030',c_codcompy,'2','3') = false then
        return;
    end if;
    if check_codpay(c_codpaypy8,'PY0030',c_codcompy,'2','3') = false then
        return;
    end if;
    if check_codpay(c_codpaypy9,'PY0055',c_codcompy,'7') = false then
        return;
    end if;
    if check_codpay(c_codpaypy10,'PY0003',c_codcompy,'6') = false then
        return;
    end if;
    if check_codpay(c_codpaypy11,'PY0003',c_codcompy,'6') = false then
        return;
    end if;
    if check_codpay(c_codpaypy12,'PY0030',c_codcompy,'5') = false then
        return;
    end if;
    if check_codpay(c_codpaypy13,'PY0030',c_codcompy,'5') = false then
        return;
    end if;
    if check_codpay(c_codpaypy14,'PY0030',c_codcompy,'5') = false then
        return;
    end if;
    if check_salary(c_amtminsoc,c_amtmaxsoc) = false then
        return;
    end if;

  end check_save;

  function check_codpay(p_codpay varchar2,error_code varchar2,p_codcompy varchar2,p_typpay1 varchar2,p_typpay2 varchar2 default null) return boolean is
    v_result    boolean := true;
    v_typpay    varchar2(1 char);
    v_count_tinexinf     number := 0;
    v_count_tinexinfc    number := 0;
  begin

    if p_codpay is not null then
        begin
            select count(*)into v_count_tinexinf
            from tinexinf
            where codpay = p_codpay;
        exception when others then null;
        end;
        if v_count_tinexinf < 1 then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
            v_result := false;
            return v_result;
        end if;
        begin
            select count(*)into v_count_tinexinfc
            from tinexinfc
            where
            codcompy = p_codcompy and
            codpay = p_codpay;
        exception when others then null;
        end;
        if v_count_tinexinfc < 1 then
            param_msg_error := get_error_msg_php('PY0044',global_v_lang,p_codpay||' - '||get_tinexinf_name(p_codpay,global_v_lang));
            v_result := false;
            return v_result;
        end if;

        select typpay into v_typpay from tinexinf where codpay = p_codpay;
        if p_typpay2 is null then
            if v_typpay != p_typpay1 then
                param_msg_error := get_error_msg_php(error_code,global_v_lang);
                v_result := false;
                return v_result;
            end if;
        else
            if v_typpay != p_typpay1 and v_typpay != p_typpay2 then
                param_msg_error := get_error_msg_php(error_code,global_v_lang);
                v_result := false;
                return v_result;
            end if;
        end if;
    end if;
    return v_result;
  end;

  function check_salary(p_amtminsoc varchar2,p_amtmaxsoc varchar2) return boolean is
    v_amtminsoc     number(8,2) := 0;
    v_amtmaxsoc     number(8,2) := 0;
  begin
    if p_amtminsoc is not null then
        v_amtminsoc  := to_number(p_amtminsoc);
    end if;
    if p_amtmaxsoc is not null then
        v_amtmaxsoc  := to_number(p_amtmaxsoc);
    end if;
    if (v_amtminsoc > v_amtmaxsoc) then
        param_msg_error := get_error_msg_php('HR2022',global_v_lang);
        return false;
    end if;
    return true;
  end;

  function check_has_codcompy(p_codcompy varchar2) return boolean is
  v_count       number := 0;
  begin
    begin
        select count(*) into v_count
        from tcompny
        where codcompy = p_codcompy;
    exception when others then null;
    end;
    if v_count < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
        return false;
    end if;
    return true;
  end;

  function check_dteeffec_index(p_codcompy varchar2,p_dteeffec date) return boolean is
    v_count     number := 0;
  begin
    begin
        select count(*) into v_count
        from tcontrpy
        where
            codcompy = p_codcompy and
            dteeffec < p_dteeffec;
    exception when others then null;
    end;
    if p_dteeffec < trunc(sysdate) and v_count > 0 then
        param_msg_error := get_error_msg_php('HR1501',global_v_lang);
        return false;
    end if;
    return true;
  end;

  procedure get_income(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_row           number  := 0;
    v_length        number;
    p_row           number;
    p_codcompy      varchar2(10 char);
    v_condition     boolean;
    cursor c1 is
      select
          a.codpay,
          a.descpaye,
          a.descpayt,
          a.descpay3,
          a.descpay4,
          a.descpay5,
          a.typpay
      from tinexinf a
      left join tinexinfc b
      on a.codpay = b.codpay
      where b.codcompy = p_codcompy
      order by a.typpay,a.codpay;
  begin
    initial_value(json_str_input);
    json_obj          := json_object_t(json_str_input);
    obj_row := json_object_t();
    p_row   := to_number(hcm_util.get_string_t(json_obj,'row'));
    p_codcompy  := hcm_util.get_string_t(json_obj,'codcompy');
    for i in c1 loop
        if p_row = 1 then
            if i.typpay = '6' then
                v_condition := true;
            end if;
        elsif p_row in (2,3) then
            if i.typpay = '4' or i.typpay = '5' then
                v_condition := true;
            end if;
        elsif p_row in (4,5,8) then
            if i.typpay = '2' or i.typpay = '3' then
                v_condition := true;
            end if;
        elsif p_row in (6,7,9) then
            v_condition := true;
        else
            v_condition := false;
        end if;

        if v_condition = true then
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codpay',i.codpay);
            obj_data.put('descpaye',i.descpaye);
            obj_data.put('descpayt',i.descpayt);
            obj_data.put('descpay3',i.descpay3);
            obj_data.put('descpay4',i.descpay4);
            obj_data.put('descpay5',i.descpay5);
            obj_row.put(to_char(v_row-1),obj_data);
        end if;

    end loop;
    json_str_output := obj_row.to_clob;
  end get_income;

end HRPY15E;

/

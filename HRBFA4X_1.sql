--------------------------------------------------------
--  DDL for Package Body HRBFA4X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBFA4X" AS
  procedure initial_value(json_str_input in clob) as
   json_obj json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_dteyear         := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_codcomp         := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
    p_query_codempid  := upper(hcm_util.get_string_t(json_obj,'p_query_codempid'));
    p_dtehealst       := to_date(hcm_util.get_string_t(json_obj,'p_dtehealst'),'dd/mm/yyyy');
    p_dtehealen       := to_date(hcm_util.get_string_t(json_obj,'p_dtehealen'),'dd/mm/yyyy');
    p_codprgheal      := upper(hcm_util.get_string_t(json_obj,'p_codprgheal'));
    v_codapp          := 'HRBFA4X';

  end initial_value;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
--  check codcomp in tcenter
    if p_codcomp is not null then
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp || '%'
              and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;

--  check secur7
        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;

--  check employee in temploy1
    if p_query_codempid is not null then
        begin
            select 'X' into v_temp
            from temploy1
            where codempid = p_query_codempid;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
            return;
        end;

--  check secur2
        if secur_main.secur2(p_query_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;

  end check_index;

  procedure clear_ttemprpt is
  begin
    begin
        delete
        from  ttemprpt
        where codempid = global_v_codempid
          and codapp   = v_codapp;
    exception when others then
        null;
    end;
  end clear_ttemprpt;

  function get_max_numseq return number as
    p_numseq         number;
    max_numseq       number;
  begin
--  get max numseq
    select max(numseq) into max_numseq
        from ttemprpt
        where codempid = global_v_codempid
          and codapp = v_codapp;
    if max_numseq is null then
        max_numseq := 0 ;
    end if;

    p_numseq := max_numseq+1;

    return p_numseq;

  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_count         number := 0;
    v_count_secur   number := 0;
    v_chk_secur     boolean := false;
    cursor c1 is
        select t2.codempid,t1.codcomp,t1.dteheal,t1.codprgheal,t1.codcln,t1.amtheal,t1.descheal,t1.dtefollow
        from thealinf1 t1,temploy1 t2
        where t1.codempid = t2.codempid
          and t1.dteyear = p_dteyear
          and t1.codcomp like p_codcomp || '%'
          and t2.codempid = nvl(p_query_codempid,t2.codempid)
          and t1.codprgheal = nvl(p_codprgheal,t1.codprgheal)
          and t1.dteheal between nvl(p_dtehealst,t1.dteheal) and nvl(p_dtehealen,t1.dteheal)
        order by t1.codcomp,t1.codempid,t1.dteheal;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_count := v_count + 1;
        v_chk_secur := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if v_chk_secur then
            v_count_secur := v_count_secur + 1;
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('dteheal',to_char(i.dteheal,'dd/mm/yyyy'));
            obj_data.put('codprgheal',i.codprgheal);
            obj_data.put('codprgheal_name',get_thealcde_name(i.codprgheal,global_v_lang));
            obj_data.put('codcln',i.codcln);
            obj_data.put('codcln_name',get_tclninf_name(i.codcln,global_v_lang));
            obj_data.put('amtheal',i.amtheal);
            obj_data.put('descheal',i.descheal);
            obj_data.put('dtefollow',to_char(i.dtefollow,'dd/mm/yyyy'));
            obj_data.put('dteyear',p_dteyear);--User37 #6800 01/09/2021
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

     if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thealinf1');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    elsif v_count != 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
     end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_index;

  function gen_table(v_codempid varchar2,v_codprgheal varchar2) return json_object_t as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    obj_data_rows   json_object_t;--User37 #6800 01/09/2021
    v_row           number := 0;
    v_qtysetup      thealcde2.qtysetup%type;
    cursor c1 is
        select codheal,descheck,chkresult,descheal,codprgheal
        from thealinf2
        where codempid = v_codempid
          and dteyear = p_dteyear
          and codprgheal = nvl(v_codprgheal,codprgheal)
        order by codheal;
  begin
    obj_rows := json_object_t();
    obj_data_rows := json_object_t();--User37 #6800 01/09/2021
    for i in c1 loop
        begin
            select qtysetup into v_qtysetup
            from thealcde2
            where codprgheal = nvl(v_codprgheal,codprgheal)
              and codheal = i.codheal;
        exception when no_data_found then
            v_qtysetup := '';
            begin
                select qtysetup into v_qtysetup
                  from thealcde2
                 where codheal = i.codheal
                   and rownum <= 1
                   order by codprgheal;
            exception when no_data_found then
              v_qtysetup := '';
            end;
        end;
        obj_data := json_object_t();
        v_row := v_row+1;
        obj_data.put('codprgheal',nvl(i.codprgheal,''));
        obj_data.put('codheal',nvl(i.codheal,''));
        obj_data.put('codheal_name',nvl(GET_TCODEC_NAME('TCODHEAL',i.codheal,global_v_lang),''));
        obj_data.put('qtysetup',nvl(v_qtysetup,''));
        obj_data.put('descheck',nvl(i.descheck,''));
        obj_data.put('chkresult',nvl(i.chkresult,''));
        obj_data.put('chkresult_name',nvl(get_tlistval_name('CHKRESUL',i.chkresult,global_v_lang),''));
        obj_data.put('descheal',nvl(i.descheal,''));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    obj_data_rows.put('rows',obj_rows);--User37 #6800 01/09/2021
    return obj_data_rows;--User37 #6800 01/09/2021 return obj_rows;

  end;

  procedure gen_detail(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_chk_secur     boolean := false;
    v_row_secur     number :=0;
    v_count         number := 0;
    --<<User37 #6800 08/09/2021 
    v_codempid      thealinf1.codempid%type;
    v_codprgheal    thealinf1.codprgheal%type;
    obj_data2       json_object_t;
    obj_rows2       json_object_t;
    v_row2          number := 0;

    /*cursor c1 is
        select t1.dteyear, t2.codempid,t1.codcomp,t1.dteheal,t1.codprgheal,t1.codcln,t1.amtheal,t1.namdoc,t1.numcert,t1.namdoc2,t1.numcert2,t1.descheal,t1.dtefollow
        from thealinf1 t1,temploy1 t2
        where t1.codempid = t2.codempid
          and t1.dteyear = p_dteyear
          and t1.codcomp like p_codcomp || '%'
          and t1.codempid = nvl(p_query_codempid,t2.codempid)
          and t1.codprgheal = nvl(p_codprgheal,t1.codprgheal)
          and t1.dteheal between nvl(p_dtehealst,t1.dteheal) and nvl(p_dtehealen,t1.dteheal)
          order by t1.codcomp,t1.codempid,t1.dteheal;*/
    cursor c1 is
        select t2.codcomp,t1.codempid
        from thealinf1 t1,temploy1 t2
        where t1.codempid = t2.codempid
          and t1.dteyear = p_dteyear
          and t1.codcomp like p_codcomp || '%'
          and t1.codempid = nvl(p_query_codempid,t2.codempid)
          and t1.codprgheal = nvl(p_codprgheal,t1.codprgheal)
          and t1.dteheal between nvl(p_dtehealst,t1.dteheal) and nvl(p_dtehealen,t1.dteheal)
          group by t2.codcomp,t1.codempid
          order by t2.codcomp,t1.codempid;
    cursor c2 is
        select t1.dteyear, t2.codempid,t1.codcomp,t1.dteheal,t1.codprgheal,t1.codcln,t1.amtheal,t1.namdoc,t1.numcert,t1.namdoc2,t1.numcert2,t1.descheal,t1.dtefollow
        from thealinf1 t1,temploy1 t2
        where t1.codempid = t2.codempid
          and t1.dteyear = p_dteyear
          and t1.codempid = v_codempid
          and t1.dteheal between nvl(p_dtehealst,t1.dteheal) and nvl(p_dtehealen,t1.dteheal)
          order by t1.codcomp,t1.codempid,t1.codprgheal,t1.dteheal;
    -->>User37 #6800 08/09/2021 
  begin
    obj_rows := json_object_t();
    --<<User37 #6800 08/09/2021 
    for i in c1 loop
        v_count := v_count+1;
        v_chk_secur := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if v_chk_secur then
            v_row := v_row + 1;
            obj_data := json_object_t();
            v_row_secur := v_row_secur+1;
            obj_data := json_object_t();
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_cod_name',i.codempid||' - '||get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('dteyear',p_dteyear);
            obj_data.put('codcomp',i.codcomp);
            v_codempid      := i.codempid;
            v_row2          := 0;
            obj_rows2 := json_object_t();
            for j in c2 loop
                --codprogram
                v_row2      := v_row2 + 1;
                obj_data2   := json_object_t();
                obj_data2.put('codempid',j.codempid);
                if j.amtheal is not null then
                    obj_data2.put('amtheal',j.amtheal);
                else
                    obj_data2.put('amtheal','');
                end if;
                obj_data2.put('codcln',nvl(j.codcln,''));
                obj_data2.put('codcln_name',nvl(get_tclninf_name(j.codcln,global_v_lang),''));
                obj_data2.put('codcomp',nvl(i.codcomp,''));
                obj_data2.put('codcomp_name',nvl(get_tcenter_name(i.codcomp,global_v_lang),''));
                obj_data2.put('codprgheal',nvl(j.codprgheal,''));
                obj_data2.put('codprgheal_cod_name',nvl(j.codprgheal||' - '||get_thealcde_name(j.codprgheal,global_v_lang),''));
                obj_data2.put('codprgheal_name',nvl(get_thealcde_name(j.codprgheal,global_v_lang),''));
                obj_data2.put('descheal',nvl(j.descheal,''));
                obj_data2.put('dtefollow',nvl(to_char(j.dtefollow,'dd/mm/yyyy'),''));
                obj_data2.put('dteyear',nvl(j.dteyear,''));
                obj_data2.put('namdoc',nvl(j.namdoc,''));
                obj_data2.put('dteheal',nvl(to_char(j.dteheal,'dd/mm/yyyy'),''));
                obj_data2.put('namdoc2',nvl(j.namdoc2,''));
                obj_data2.put('numcert',nvl(j.numcert,''));
                obj_data2.put('numcert2',nvl(j.numcert2,''));
                obj_data2.put('table',gen_table(j.codempid,j.codprgheal));
                obj_rows2.put(to_char(v_row2-1),obj_data2);
            end loop;
            obj_data.put('codprogram',obj_rows2);--User37 #6800 01/09/2021
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;
    /*for i in c1 loop
        v_count := v_count+1;
        v_chk_secur := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if v_chk_secur then
            v_row := v_row + 1;
            obj_data := json_object_t();
            v_row_secur := v_row_secur+1;
            obj_data.put('dteyear',i.dteyear);
            obj_data.put('codprgheal',i.codprgheal);
            obj_data.put('codprgheal_name',get_thealcde_name(i.codprgheal,global_v_lang));
            obj_data.put('codprgheal_cod_name',i.codprgheal||' - '||get_thealcde_name(i.codprgheal,global_v_lang));
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('emp_cod_name',i.codempid||' - '||get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));--User37 #6800 01/09/2021 obj_data.put('codcomp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('dteheal',to_char(i.dteheal,'dd/mm/yyyy'));
            obj_data.put('codcln',i.codcln);
            obj_data.put('codcln_name',get_tclninf_name(i.codcln,global_v_lang));
            obj_data.put('amtheal',i.amtheal);
            obj_data.put('namdoc',i.namdoc);
            obj_data.put('numcert',i.numcert);
            obj_data.put('namdoc2',i.namdoc2);
            obj_data.put('numcert2',i.numcert2);
            obj_data.put('descheal',i.descheal);
            obj_data.put('dtefollow',to_char(i.dtefollow,'dd/mm/yyyy'));
            obj_data.put('table',gen_table(i.codempid,i.codprgheal));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;*/
    -->>User37 #6800 08/09/2021 

    if v_row_secur = 0 and v_count != 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THEALINF1');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_detail;

  procedure gen_report(json_str_input in clob,json_str_output out clob) as
    add_month               number:=0;
    json_obj                json_object_t;
    data_obj                json_object_t;
    v_max_numseq             number;
    v_codempid               temploy1.codempid%type;
    v_codcomp                temploy1.codcomp%type;
    v_dteheal                thealinf1.dteheal%type;
    v_codprgheal             thealinf1.codprgheal%type;
    v_codcln                 thealinf1.codcln%type;
    v_amtheal                varchar2(20 char);--thealinf1.amtheal%type;
    v_namdoc                 thealinf1.namdoc%type;
    v_numcert                thealinf1.numcert%type;
    v_namdoc2                thealinf1.namdoc2%type;
    v_numcert2               thealinf1.numcert2%type;
    v_descheal               thealinf1.descheal%type;
    v_dtefollow              thealinf1.dtefollow%type;
    v_codapp                 varchar2(20 char) := 'HRBFA4X';
    v_codprgheal_name        varchar2(500 char);
    v_qtysetup               thealcde2.qtysetup%type;
    v_row                    number := 0;
    v_dteyear                thealinf1.dteyear%type;
    v_report_year                thealinf1.dteyear%type;

    v_found_thealinf1       boolean;
    v_count_thealinf2       number;
    --<<User37 #6800 08/09/2021 
    v_folder                varchar2(600);
    v_emp_image             varchar2(600);
    v_flg_img               varchar2(1) := 'N';
    v_seq                   number;

    cursor c1 is
      select t1.dteyear, t2.codempid,t2.codcomp,t1.dteheal,t1.codprgheal,t1.codcln,t1.amtheal,t1.namdoc,t1.numcert,t1.namdoc2,t1.numcert2,t1.descheal,t1.dtefollow
        from thealinf1 t1,temploy1 t2
        where t1.codempid = t2.codempid
          and t1.dteyear = p_dteyear
          and t1.codempid = nvl(p_query_codempid,t1.codempid)
          and t1.codcomp like p_codcomp || '%'
          and t1.codprgheal = nvl(p_codprgheal,t1.codprgheal)
          and t1.dteheal between nvl(p_dtehealst,t1.dteheal) and nvl(p_dtehealen,t1.dteheal)
          order by t1.codcomp,t1.codempid,t1.codprgheal,t1.dteheal;
    cursor c2 is
        select codheal,descheck,chkresult,descheal,codprgheal
        from thealinf2
        where codempid = v_codempid
          and dteyear = p_dteyear
          and codprgheal = v_codprgheal
        order by codheal;
    /*cursor c1 is
        select codheal,descheck,chkresult,descheal
        from thealinf2
        where codempid = v_codempid
          and dteyear = v_dteyear
          and codprgheal = v_codprgheal
        order by codheal;*/
    -->>User37 #6800 08/09/2021 
  begin
    --<<User37 #6800 08/09/2021 
    initial_value(json_str_input);
    add_month := hcm_appsettings.get_additional_year*12;
    v_report_year := p_dteyear+hcm_appsettings.get_additional_year;
    v_folder      := get_tfolderd('HRPMC2E1');
    delete ttemprpt where codempid = global_v_codempid and codapp = v_codapp;
    for i in c1 loop
      if i.amtheal is not null then
        v_amtheal := to_char(i.amtheal,'fm999,999,990.00');
      else
        v_amtheal := '-';
      end if;
      v_emp_image   := get_emp_img(i.codempid);
      if v_emp_image like '%.%' then
        v_emp_image   := get_tsetup_value('PATHWORKPHP')||v_folder||'/'||v_emp_image;
        v_flg_img     := 'Y';
      else
        v_emp_image   := '';
        v_flg_img     := 'N';
      end if;
      v_max_numseq := nvl(v_max_numseq,0) + 1;
      insert into ttemprpt(codempid,codapp,numseq,
                           item1,item2,item3,
                           item4,item5,item6,
                           item7,item8,item9,
                           item10,item11,item12,
                           item13,item14,item15,
                           item16,item17,item18)
                    values(global_v_codempid, v_codapp, v_max_numseq,
                           'DETAIL',v_report_year,i.codempid,
                           get_temploy_name(i.codempid,global_v_lang),get_tcenter_name(i.codcomp,global_v_lang),i.codprgheal,
                           get_thealcde_name(i.codprgheal,global_v_lang),to_char(add_months(i.dteheal,add_month),'dd/mm/yyyy'),i.codcln || ' - ' ||get_tclninf_name(i.codcln,global_v_lang),
                           v_amtheal,nvl(i.namdoc,'-'),nvl(i.namdoc2,'-'),
                           nvl(i.numcert,'-'),nvl(i.numcert2,'-'),nvl(i.descheal,'-'),
                           nvl(to_char(add_months(i.dtefollow,add_month),'dd/mm/yyyy'),'-'),v_emp_image,v_flg_img);
      v_codempid    := i.codempid;
      v_codprgheal  := i.codprgheal;
      v_seq         := 0;
      for j in c2 loop
        v_max_numseq := nvl(v_max_numseq,0) + 1;
        v_seq        := nvl(v_seq,0) + 1;
        begin
            select qtysetup into v_qtysetup
            from thealcde2
            where codprgheal = nvl(v_codprgheal,codprgheal)
              and codheal = j.codheal;
        exception when no_data_found then
            v_qtysetup := '';
            begin
                select qtysetup into v_qtysetup
                  from thealcde2
                 where codheal = j.codheal
                   and rownum <= 1
                   order by codprgheal;
            exception when no_data_found then
              v_qtysetup := '';
            end;
        end;
        insert into ttemprpt(codempid,codapp,numseq,
                             item1,item2,item3,
                             item4,item5,item6,
                             item7,item8,item9,
                             item10,item11)
                      values(global_v_codempid, v_codapp, v_max_numseq,
                             'TABLE',v_report_year,v_codempid,
                             v_codprgheal,v_seq,j.codheal,
                             nvl(GET_TCODEC_NAME('TCODHEAL',j.codheal,global_v_lang),''),nvl(v_qtysetup,''),nvl(j.descheck,''),
                             nvl(get_tlistval_name('CHKRESUL',j.chkresult,global_v_lang),''),nvl(j.descheal,''));
      end loop;
    end loop;
    /*json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'p_data');
    for i in 0..param_json.get_size-1 loop--for i in 0..param_json.count-1 loop
        data_obj := hcm_util.get_json_t(param_json,to_char(i));
        v_dteyear         := to_number(hcm_util.get_string_t(data_obj,'p_dteyear'));
        v_codcomp         := upper(hcm_util.get_string_t(data_obj,'p_codcomp'));
        v_codprgheal      := hcm_util.get_string_t(data_obj,'p_codprgheal');
        v_codempid        := hcm_util.get_string_t(data_obj,'p_query_codempid');

        v_found_thealinf1 := true;
        begin
            select t1.dteheal,t1.codcln,t1.amtheal,t1.namdoc,t1.numcert,t1.namdoc2,t1.numcert2,t1.descheal,t1.dtefollow
            into v_dteheal,v_codcln,v_amtheal,v_namdoc,v_numcert,v_namdoc2,v_numcert2,v_descheal,v_dtefollow
            from thealinf1 t1,temploy1 t2
            where t1.codempid = t2.codempid
              and t1.dteyear = v_dteyear
              and t1.codcomp = v_codcomp
              and t1.codprgheal = v_codprgheal
              and t1.codempid = v_codempid
              order by t1.codempid,t1.dteheal;
        exception when no_data_found then
            v_found_thealinf1 := false;
        end;

        if v_found_thealinf1 then
            --  insert header
            if global_v_lang ='102' then
                add_month := 543*12;
                v_report_year := v_dteyear+543;
            end if;
            v_max_numseq := get_max_numseq;
            v_codprgheal_name := v_codprgheal || ' - ' || get_thealcde_name(v_codprgheal,global_v_lang);
            insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15,item16,item17,item18,item19,item20,item21,item22,item23,item24,item25,
                                item26,item27,item28,item29,item35,item36,item37)
            values(global_v_codempid, v_codapp, v_max_numseq, v_report_year, v_codprgheal_name, v_codempid || ' - ' || get_temploy_name(v_codempid,global_v_lang),
                   to_char(add_months(v_dteheal,add_month),'dd/mm/yyyy'),get_tcenter_name(v_codcomp,global_v_lang),v_codcln || ' - ' ||get_tclninf_name(v_codcln,global_v_lang),v_amtheal,
                   v_namdoc,v_numcert,v_namdoc2,v_numcert2,v_descheal,to_char(add_months(v_dtefollow,add_month),'dd/mm/yyyy'),'header',get_label_name('HRBFA4XP3',global_v_lang,10), get_label_name('HRBFA4XP3',global_v_lang,40),
                   get_label_name('HRBFA4XP3', global_v_lang,20), get_label_name('HRBFA4XP3',global_v_lang,50), get_label_name('HRBFA4XP3',global_v_lang,30), get_label_name('HRBFA4XP3',global_v_lang,60),
                   get_label_name('HRBFA4XP3',global_v_lang,70), get_label_name('HRBFA4XP3',global_v_lang,80), get_label_name('HRBFA4XP3',global_v_lang,90), get_label_name('HRBFA4XP3',global_v_lang,100),
                   get_label_name('HRBFA4XP3',global_v_lang,110), get_label_name('HRBFA4XP3',global_v_lang,120),get_label_name('HRBFA4XP3',global_v_lang,130), get_label_name('HRBFA4XP3',global_v_lang,140),
                   get_label_name('HRBFA4XP3',global_v_lang,150),v_codempid,v_dteyear,v_codprgheal);
            --  insert list_codheal
            v_count_thealinf2 := 0;
            v_row := 0;
            for i in c1 loop
                v_count_thealinf2 := v_count_thealinf2+1;
                v_row := v_row+1;
                begin
                    select qtysetup into v_qtysetup
                    from thealcde2
                    where codprgheal = nvl(v_codprgheal,codprgheal)
                      and codheal = i.codheal
                      and rownum = 1
                      order by codprgheal;
                exception when no_data_found then
                    v_qtysetup := '';
                    begin
                        select qtysetup into v_qtysetup
                          from thealcde2
                         where codheal = i.codheal
                           and rownum <= 1
                           order by codprgheal;
                    exception when no_data_found then
                      v_qtysetup := '';
                    end;
                end;
                v_max_numseq := get_max_numseq;
                insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item12,item35,item36,item37)
                values(global_v_codempid, v_codapp, v_max_numseq, v_row, i.codheal, GET_TCODEC_NAME('TCODHEAL',i.codheal,global_v_lang), v_qtysetup, i.descheck, get_tlistval_name('CHKRESUL',i.chkresult,global_v_lang), i.descheal, 'list_codheal',v_codempid,v_dteyear,v_codprgheal);
            end loop;
            if v_count_thealinf2 = 0 then
                v_max_numseq := get_max_numseq;
                insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item12,item35,item36,item37)
                values(global_v_codempid, v_codapp, v_max_numseq, '', '', '', '', '', '', '', 'list_codheal',v_codempid,v_dteyear,v_codprgheal);
            end if;
        end if;
    end loop;*/
    commit;
    -->>User37 #6800 08/09/2021 
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end gen_report;

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
    gen_detail(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  end get_detail;

  procedure get_report(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    clear_ttemprpt;
    if param_msg_error is null then
        gen_report(json_str_input,json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_report;


END HRBFA4X;

/

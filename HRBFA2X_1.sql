--------------------------------------------------------
--  DDL for Package Body HRBFA2X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBFA2X" AS

  procedure initial_value(json_str_input in clob) as
   json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codprgheal      := hcm_util.get_string(json_obj,'p_codprgheal');
        p_codcomp         := hcm_util.get_string(json_obj,'p_codcomp');
        p_dteyear         := hcm_util.get_string(json_obj,'p_dteyear');
        p_query_codempid  := hcm_util.get_string(json_obj,'p_query_codempid');
        p_dtehealst       := to_date(hcm_util.get_string(json_obj,'p_dtehealst'),'dd/mm/yyyy');
        p_dtehealen       := to_date(hcm_util.get_string(json_obj,'p_dtehealen'),'dd/mm/yyyy');

  end initial_value;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
    if p_codprgheal is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_codcomp is not null then
        begin
            select 'X' into v_temp
            from thealcde
            where codprgheal = p_codprgheal;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'thealcde');
            return;
        end;

--  check secure7
        if secur_main.secur7(p_codcomp,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;

    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
    end;

  end check_index;

  procedure check_mail as
    v_temp      varchar(1 char);
  begin
-- check codempid
    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_query_codempid;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
    end;

-- check date
    if p_dtehealen < sysdate then
        param_msg_error := get_error_msg_php('HR8519',global_v_lang);
        return;
    end if;

  end check_mail;

  procedure gen_index(json_str_output out clob) as
    obj_rows            json;
    obj_data            json;
    v_row               number := 0;
    v_row_secur         number := 0;
    v_statement         long;
    v_qtymth            thealcde.qtymth%type;
    v_dteheal           thealinf1.dteheal%type;
    v_age               varchar2(1000 char);
    v_secur             varchar2(1 char) := 'N';
    v_chk_secur         boolean := false;
    v_codcomp           temploy1.codcomp%type;
    v_codsex            temploy1.codsex%type;
    v_dteempdb          temploy1.dteempdb%type;
    v_header_dteheal    thealinf.dteheal%type;
    v_head_dtehealen    thealinf.dtehealen%type;
    v_year              number;
    v_month             number;
    v_day               number;
    v_cnt_data          number;

    cursor c1 is
      select codempid,codcomp,dteheal,dtehealen
        from thealinf1
       where dteyear = p_dteyear
         and codprgheal = p_codprgheal
         and codcomp like nvl(p_codcomp,codcomp) || '%'
         and dteheal is null
    order by codcomp,codempid;

  begin
    obj_rows := json();
    for i in c1 loop
        v_row       := v_row + 1;
        v_chk_secur := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_chk_secur then
            v_row_secur     := v_row_secur+1;
            v_secur         := 'Y';
            begin
                select codsex,dteempdb into v_codsex,v_dteempdb
                  from temploy1
                 where codempid = i.codempid;
            exception when no_data_found then
                v_codsex   := '';
                v_dteempdb := '';
            end;
            get_service_year(v_dteempdb,sysdate,'Y',v_year,v_month,v_day);
--  get data from thealcde
            begin
                select qtymth into v_qtymth
                  from thealcde
                 where codprgheal = p_codprgheal;
            exception when no_data_found then
                v_qtymth  := 0;
            end;

            if i.dteheal is null then
                select max(dteheal) into i.dteheal
                  from thealinf1
                 where codempid = i.codempid
                   and codprgheal = p_codprgheal
                   and dteyear < p_dteyear;
            end if;

            if i.dtehealen is null then
--                i.dtehealen := add_months(i.dteheal, v_qtymth);
                begin
                    select add_months(max(dteheal),v_qtymth) into i.dtehealen
                      from thealinf1
                     where codempid = i.codempid
                       and codprgheal = p_codprgheal
                       and dteyear < p_dteyear;
                exception when no_data_found then
                    i.dtehealen := i.dtehealen;
                end;
            end if;

            if p_codcomp is not null then
                begin
                    select min(dteheal),max(dtehealen),count(*) into v_header_dteheal,v_head_dtehealen,v_cnt_data
                      from thealinf
                    where dteyear    = p_dteyear
                      and codcomp    like p_codcomp || '%'
                      and codprgheal = p_codprgheal;
                    if v_cnt_data > 1 then
                      v_header_dteheal := '';
                      v_head_dtehealen := '';
                    end if;
                exception when no_data_found then
                    v_header_dteheal := '';
                    v_head_dtehealen := '';
                end;
            end if;

            v_age := get_age(v_dteempdb,sysdate);
            obj_data := json();
            obj_data.put('header_dteheal',to_char(v_header_dteheal,'dd/mm/yyyy'));
            obj_data.put('header_dtehealen',to_char(v_head_dtehealen,'dd/mm/yyyy'));
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('codsex',v_codsex);
            obj_data.put('codsex_name',get_tlistval_name('NAMSEX',v_codsex,global_v_lang));
            obj_data.put('age',v_year || '(' || v_month || ')');
            if i.dteheal is null then
                begin
                    select max(dteheal) into i.dteheal
                    from thealinf1
                    where codempid = i.codempid
                      and codprgheal = p_codprgheal
                      and dteyear < p_dteyear;
                exception when no_data_found then
                    i.dteheal := i.dteheal;
                end;
            end if;
            obj_data.put('dte_last_check',to_char(i.dteheal,'dd/mm/yyyy'));
            obj_data.put('dte_due',to_char(i.dtehealen,'dd/mm/yyyy'));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if; -- end if v_chk_secur
    end loop;

    if v_row > 0 and v_row_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    elsif v_row = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THEALINF1');
        return;
    end if;
    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

  end gen_index;

  procedure gen_mail(json_str_output out clob) as
    o_msg_to            clob;
    p_template_to       clob;
    v_rowid             ROWID;
    v_error             varchar2(1000 char);
    v_subject           varchar2(500 char);
    v_func_appr         varchar2(500 char);
    v_codapp            ttemprpt.codapp%TYPE;
    v_codform           TFWMAILH.codform%TYPE;

    -- excel param
    v_count             number;
    v_excel_filename    varchar2(1000 char);
    v_filepath          varchar2(1000 char);
    v_column            varchar2(1000 char);
    v_labels            varchar2(1000 char);
    v_year              number;
    v_month             number;
    v_day               number;
    v_qtymth            number;
    v_maillang          temploy1.maillang%type;

    cursor c_excel is --export Excel
      select a.codempid,a.codcomp,a.dteheal,a.dtehealen,b.codsex,b.dteempdb
        from thealinf1 a,temploy1 b
       where a.codempid = b.codempid
         and a.dteyear = p_dteyear
         and a.codprgheal = p_codprgheal
         and a.codcomp like nvl(p_codcomp,a.codcomp) || '%'
         and a.dteheal is null;
  begin
    v_maillang := chk_flowmail.get_emp_mail_lang(p_query_codempid);

    begin
        select decode(v_maillang,101,descode,102,descodt,103,descod3,104,descod4,105,descod5) subject
          into v_subject
          from tfrmmail
         where codform = 'HRBFA2X';
    exception when no_data_found then
        v_subject := get_label_name('HRBFA2XP2', v_maillang, 40);
    end;
    v_codapp    := 'HRBFA2X';
    begin
        select codform into v_codform
          from tfwmailh
         where codapp = v_codapp;
    exception when no_data_found then
        v_codform := v_codform;
    end;
    begin
        select rowid
          into v_rowid
          from (select thealinf1.*, row_number() over (order by codcomp) as seqnum
                  from thealinf1
                 where dteyear = p_dteyear
                   and codprgheal = p_codprgheal
                   and codcomp like p_codcomp||'%') t1
         where seqnum = 1;
    exception when no_data_found then
        v_rowid := null;
    end;

    if p_dtehealst is null then
        p_dtehealst := trunc(sysdate);
    end if;

-- excel
    begin
        delete from ttemprpt
         where codempid = global_v_codempid
           and codapp   = v_codapp;
    exception when others then
        null;
    end;
    begin
        delete from ttempprm
         where codempid = global_v_codempid
           and codapp   = v_codapp;
    exception when others then
        null;
    end;
    begin
        insert into ttempprm (codempid, codapp, label1, label2, label3, label4, label5, label6)
            values (global_v_codempid, v_codapp, get_label_name('HRBFA2XP1', v_maillang, 50), get_label_name('HRBFA2XP1', v_maillang, 60), get_label_name('HRBFA2XP1', v_maillang, 70), get_label_name('HRBFA2XP1', v_maillang, 80), get_label_name('HRBFA2XP1', v_maillang, 90), get_label_name('HRBFA2XP1', v_maillang, 100));
        exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'TTEMPPRM');
    end;
    v_count := 0;
    for j in c_excel loop
        v_count := v_count+1;
        get_service_year(j.dteempdb,sysdate,'Y',v_year,v_month,v_day);
        begin
            select qtymth into v_qtymth
              from thealcde
             where codprgheal = p_codprgheal;
        exception when no_data_found then
            v_qtymth  := 0;
        end;

        if j.dteheal is null then
            select max(dteheal) into j.dteheal
              from thealinf1
             where codempid = j.codempid
               and codprgheal = p_codprgheal
               and dteyear < p_dteyear;
        end if;

        if j.dtehealen is null then
--                i.dtehealen := add_months(i.dteheal, v_qtymth);
            begin
                select add_months(max(dteheal),v_qtymth)
                  into j.dtehealen
                  from thealinf1
                 where codempid = j.codempid
                   and codprgheal = p_codprgheal
                   and dteyear < p_dteyear;
            exception when no_data_found then
                j.dtehealen := j.dtehealen;
            end;
        end if;

        begin
            insert into ttemprpt (codempid, codapp, numseq, item1, item2, item3, item4,
                                  item5, item6)
                 values (global_v_codempid, v_codapp, v_count, j.codempid, get_temploy_name(j.codempid,v_maillang), get_tlistval_name('NAMSEX',j.codsex,v_maillang), v_year || '(' || v_month || ')',
                         hcm_util.get_date_buddhist_era(j.dteheal), hcm_util.get_date_buddhist_era(j.dtehealen));
        exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'TTEMPRPT');
        end;
        --
        update thealinf1 set dtehealen = nvl(j.dtehealen,p_dtehealen)
         where codempid   = j.codempid
           and codprgheal = p_codprgheal
           and dteyear    = p_dteyear;
    end loop;
    commit;

    v_excel_filename      := global_v_codempid || '_excelmail';
    v_filepath            := get_tsetup_value('PATHEXCEL') || v_excel_filename;
    v_column              := 'item1, item2, item3, item4, item5, item6';
    v_labels              := 'label1, label2, label3, label4, label5, label6';
    excel_mail(v_column, v_labels, null, global_v_codempid, v_codapp, v_excel_filename);

    chk_flowmail.get_message_result('HRBFA2X' ,v_maillang,o_msg_to,p_template_to);
    begin
        select decode(v_maillang,'101',messagee,
                             '102',messaget,
                             '103',message3,
                             '104',message4,
                             '105',message5,
                             '101',messagee) msg
          into p_template_to
          from tfrmmail
         where codform = 'TEMPLATE' ;
    exception when others then
        p_template_to := null ;
    end ;

    chk_flowmail.replace_text_frmmail(p_template_to, 'THEALINF1', v_rowid, v_subject, 'HRBFA2X', '1',
                                      null, global_v_coduser, v_maillang, o_msg_to,'N',v_excel_filename);
    o_msg_to := replace(o_msg_to,'<PARAM-03>',hcm_util.get_date_buddhist_era(p_dtehealst));
    o_msg_to := replace(o_msg_to,'<PARAM-04>',hcm_util.get_date_buddhist_era(p_dtehealen));
    v_error := chk_flowmail.send_mail_to_emp (p_query_codempid, global_v_coduser, o_msg_to,
                                              NULL, v_subject, 'E', v_maillang, v_excel_filename,null,null,'Oracle');
  end gen_mail;

  procedure get_index(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index;

  procedure send_mail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    update thealinf1
       set dtehealen  = p_dtehealen
     where dteyear    = p_dteyear
       and codprgheal = p_codprgheal
       and codempid   = p_query_codempid
       and codcomp like nvl(p_codcomp, '')||'%'
       and dteheal is null;
    gen_mail(json_str_output);
    if param_msg_error is not null then
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
        commit;
        param_msg_error := get_error_msg_php('HR2046',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end send_mail;

END HRBFA2X;

/

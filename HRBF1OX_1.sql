--------------------------------------------------------
--  DDL for Package Body HRBF1OX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1OX" is
-- last update: 28/11/2022 10:16
-- last update: 31/08/2020 18:16

  procedure initial_value(json_str in clob) is
    json_obj                json_object_t;
  begin
    v_chken                 := hcm_secur.get_v_chken;
    json_obj                := json_object_t(json_str);
    --global
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');

    --block b_index--
    b_index_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codempid        := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_dtestr          := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'ddmmyyyy');
    b_index_dteend          := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');
    b_index_typbf1ox        := hcm_util.get_string_t(json_obj,'p_typbf1ox');
    p_datarows              := hcm_util.get_json_t(json_obj,'param_json');
    --> Peerasak || Issue#8700 || 25/11/2022
    p_payment_voucher       := hcm_util.get_string_t(json_obj,'p_payment_voucher');
    p_paymentstrt           := to_date(hcm_util.get_string_t(json_obj,'p_paymentstrt'),'ddmmyyyy');
    p_paymentend            := to_date(hcm_util.get_string_t(json_obj,'p_paymentend'),'ddmmyyyy');
    --> Peerasak || Issue#8700 || 25/11/2022

    param_msg_error         := null;

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);

    if param_msg_error is null then
      if b_index_typbf1ox = '1' then
        gen_data(json_str_output);
      elsif b_index_typbf1ox = '2' then
        gen_data2(json_str_output);
      elsif b_index_typbf1ox = '3' then
        gen_data3(json_str_output);
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);
    v_costcent      tcenter.costcent%type;
    flgpass     	  boolean;

    --> Peerasak || Issue#8700 || 25/11/2022
    v_codincrt      tcontrbf.codincrt%type;
    v_withdraw      varchar2(4000 char);
    --> Peerasak || Issue#8700 || 25/11/2022

    cursor c1 is
         select a.rowid,
                a.codempid, a.codcomp, a.numpaymt, a.dtereq,
                a.dtecash, a.numvcher, a.amtemp, a.codappr,
                a.dteappr, a.dtepaymt, a.dtepaymtap, a.amtalw
           from tclnsinf a
          where a.codcomp like b_index_codcomp||'%'
            and a.codempid = nvl(b_index_codempid , a.codempid)
--            and (a.dtecash  between b_index_dtestr and b_index_dteend)
            and a.typpay    = '1'
            and a.staappov  = 'Y'
            and nvl(a.amtemp,0) > 0
            --> Peerasak || Issue#8700 || 25/11/2022
            and (
              ('Y' = p_payment_voucher and trunc(a.dtepaymtap) between nvl(p_paymentstrt, a.dtepaymtap) and nvl(p_paymentend, a.dtepaymtap)) or
              ('N' = p_payment_voucher and trunc(a.dtecash) between nvl(b_index_dtestr, a.dtecash) and nvl(b_index_dteend, a.dtecash))
            )
            and (
              ('Y' = p_payment_voucher and a.numpaymt is not null) or ('N' = p_payment_voucher and a.numpaymt is null)
            )
            --> Peerasak || Issue#8700 || 25/11/2022
       order by codempid , dtereq ;

  begin
    obj_row := json_object_t();

    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            begin
              select costcent into v_costcent
                from tcenter
               where codcomp = i.codcomp;
            exception when no_data_found then
              v_costcent := null;
            end;

            begin
              select codincrt into v_codincrt
                from tcontrbf
               where codcompy = b_index_codcomp
                 and dteeffec = (
                   select max(dteeffec)
                     from tcontrbf
                    where codcompy = b_index_codcomp
                      and dteeffec < sysdate
                );
            exception when no_data_found then
              v_codincrt := '';
            end;

            --> Peerasak || 05/12/2022
              begin
                select listagg(get_tcodec_name('TCODEXP', codexp, 102) || ' - ' || amtreq, ',') within group (order by codexp)
                into v_withdraw
                from ttravinfd
                group by numtravrq
                having numtravrq = i.numpaymt;
              exception when no_data_found then
                v_withdraw := '';
              end;
            --> Peerasak || 05/12/2022

            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('rowid',i.rowid);
            obj_data.put('paymentno',i.numpaymt);
            obj_data.put('image', get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('costcent',v_costcent);
            obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
            --> Peerasak || Issue#8700 || 25/11/2022
            obj_data.put('withdraw', v_withdraw);
            obj_data.put('codobf', v_codincrt);
            obj_data.put('desc_codobf',get_tinexinf_name(v_codincrt, global_v_lang));
            obj_data.put('dtepaymt',i.dtepaymt);
            obj_data.put('paymentdate', to_char(i.dtepaymtap, 'dd/mm/yyyy'));
            --> Peerasak || Issue#8700 || 25/11/2022
            obj_data.put('dtepayment',to_char(i.dtecash,'dd/mm/yyyy'));
            obj_data.put('numreq',i.numvcher);

            --> Peerasak || --- || 16/03/2023
            obj_data.put('amount', i.amtalw);
            -- obj_data.put('amount', i.amtemp);
            --> Peerasak || --- || 16/03/2023

            obj_data.put('codappr', get_temploy_name(i.codappr,global_v_lang));
            obj_data.put('dteappr', to_char(i.dteappr ,'dd/mm/yyyy'));
            obj_data.put('codcomp',i.codcomp);
            --obj_data.put('numvcher',i.numvcher); --a.numvcher
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TCLNSINF');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;  -- procedure gen_data

  procedure gen_data2 (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);
    v_costcent      tcenter.costcent%type;
    flgpass     	  boolean;
    v_codincbf      VARCHAR2(4 CHAR);

    v_codexp        VARCHAR2(4000 CHAR);

     cursor c1 is
      select a.rowid,
             a.codempid, a.dtereq, a.codcomp, a.numpaymt, a.numvcher,
             a.amtwidrw, a.codappr, a.dteappr, a.codobf,
             a.dtepay, a.desnote, a.dtepaymt
        from tobfinf a
     where a.codcomp  like b_index_codcomp||'%'
         and a.codempid = nvl(b_index_codempid , a.codempid)
--         and a.dtepay between b_index_dtestr and b_index_dteend
         and a.typepay    = '1'
         and nvl(a.flgvoucher,'N') = 'N'
         and nvl(a.amtwidrw,0) > 0
         --> Peerasak || Issue#8700 || 17/02/2023
         and (
          ('Y' = p_payment_voucher and trunc(a.dtepaymt) between nvl(p_paymentstrt, a.dtepaymt) and nvl(p_paymentend, a.dtepaymt)) or
          ('N' = p_payment_voucher and trunc(a.dtepay) between nvl(b_index_dtestr, a.dtepay) and nvl(b_index_dteend, a.dtepay))
         )
         --> Peerasak || Issue#8700 || 17/02/2023

         --> Peerasak || Issue#8700 || 25/11/2022
         and (
            ('Y' = p_payment_voucher and a.numpaymt is not null) or
            ('N' = p_payment_voucher and a.numpaymt is null)
         )
         --> Peerasak || Issue#8700 || 25/11/2022
    order by a.codempid, a.dtereq;

  begin
    obj_row := json_object_t();

    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            begin
              select costcent into v_costcent
                from tcenter
               where codcomp = i.codcomp;
            exception when no_data_found then
              v_costcent := null;
            end;

            --> Peerasak || 05/12/2022
              begin
                SELECT LISTAGG(get_tcodec_name('TCODEXP', CODEXP, 102) || ' - ' || AMTREQ, ',') WITHIN GROUP (ORDER BY CODEXP)
                INTO v_codexp
                FROM TTRAVINFD
                GROUP BY NUMTRAVRQ
                having NUMTRAVRQ = i.numpaymt;
              exception when no_data_found then
                v_codexp := '';
              end;
            --> Peerasak || 05/12/2022

            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('rowid',i.rowid);
            obj_data.put('paymentno',i.numpaymt);
            obj_data.put('image', get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('costcent',v_costcent);
            obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
            obj_data.put('withdraw',i.desnote);

            --> Peerasak || 05/12/2022
            begin
              select b.codincbf
              into v_codincbf
              from tobfinf a, tobfcompy b
              where hcm_util.get_codcompy(a.codcomp) = b.codcompy
              and a.numvcher = i.numvcher
              and b.codobf = i.codobf;
            exception when no_data_found then
              v_codincbf := '';
            end;

--            obj_data.put('codobf', i.codobf);
--            obj_data.put('desc_codobf',get_tobfcde_name(i.codobf,global_v_lang) );

            obj_data.put('codobf', v_codincbf);
            obj_data.put('desc_codobf',get_tinexinf_name(v_codincbf, global_v_lang));
            --> Peerasak || 05/12/2022

            --> Peerasak || Issue#8700 || 25/11/2022
            obj_data.put('dtepaymt', i.dtepaymt);
            obj_data.put('paymentdate', to_char(i.dtepaymt, 'dd/mm/yyyy'));
            obj_data.put('desc_codexp', v_codexp);
            --> Peerasak || Issue#8700 || 25/11/2022

            obj_data.put('dtepayment',to_char(i.dtepay,'dd/mm/yyyy'));
            obj_data.put('numreq',i.numvcher);
            obj_data.put('amount', i.amtwidrw);
            obj_data.put('codappr', get_temploy_name(i.codappr,global_v_lang));
            obj_data.put('dteappr', to_char(i.dteappr ,'dd/mm/yyyy'));
            obj_data.put('codcomp',i.codcomp);
            --obj_data.put('numvcher',i.numvcher); --i.numvcher

            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TOBFINF');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;  -- procedure gen_data2

    procedure gen_data3 (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);
    v_costcent      tcenter.costcent%type;
    flgpass     	  boolean;

    --> Peerasak || Issue#8700 || 25/11/2022
    v_codinctv      tcontrbf.codinctv%type;
--    v_withdraw      ttravinfd.codexp%type;
    v_withdraw      varchar2(4000 char);
    --> Peerasak || Issue#8700 || 25/11/2022

    cursor c1 is
      select a.rowid,
               a.codempid, a.dtereq ,a.codcomp ,a.numpaymt ,a.remark,
               a.location, a.dtepay, a.amtreq, a.codappr, a.dteappr,
               a.numtravrq, a.dtepaymt
       from ttravinf a
      where a.codcomp    like b_index_codcomp||'%'
        and a.codempid   = nvl(b_index_codempid , a.codempid)
--        and a.dtepay     between  b_index_dtestr  and b_index_dteend
        and a.typepay    = '1'
        and nvl(a.flgvoucher,'N') = 'N'
        and nvl(a.amtreq,0) > 0
        --> Peerasak || Issue#8700 || 25/11/2022
        and (
          ('Y' = p_payment_voucher and trunc(a.dtepaymt) between nvl(p_paymentstrt, a.dtepaymt) and nvl(p_paymentend, a.dtepaymt)) or
          ('N' = p_payment_voucher and trunc(a.dtepay) between nvl(b_index_dtestr, a.dtepay) and nvl(b_index_dteend, a.dtepay))
        )
        and (
          ('Y' = p_payment_voucher and a.numpaymt is not null) or
          ('N' = p_payment_voucher and a.numpaymt is null)
        )
        --> Peerasak || Issue#8700 || 25/11/2022
   order by a.codempid, a.dtereq;

  begin
    obj_row := json_object_t();

    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
             begin
                select costcent into v_costcent
                  from tcenter
                 where codcomp = i.codcomp;
               exception when no_data_found then
                v_costcent := null;
             end;

            begin
              select codinctv
                into v_codinctv
                from tcontrbf
               where codcompy = b_index_codcomp
                 and dteeffec = (
                   select max(dteeffec)
                     from tcontrbf
                    where codcompy = b_index_codcomp
                      and dteeffec < sysdate
                );
            exception when no_data_found then
              null;
            end;

            --> Peerasak || 05/12/2022
              begin
                select listagg(get_tcodec_name('TCODEXP', codexp, 102) || ' - ' || amtreq, ',') within group (order by codexp)
                into v_withdraw
                from ttravinfd
                group by numtravrq
                having numtravrq = i.numtravrq;
              exception when no_data_found then
                v_withdraw := '';
              end;
            --> Peerasak || 05/12/2022

            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('rowid',i.rowid);
            obj_data.put('paymentno',i.numpaymt);
            obj_data.put('image', get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('costcent',v_costcent);
            obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
--            obj_data.put('withdraw',i.location);
            --> Peerasak || Issue#8700 || 25/11/2022
            obj_data.put('paymentdate', to_char(i.dtepaymt, 'dd/mm/yyyy'));
            obj_data.put('codobf', v_codinctv);
            obj_data.put('desc_codobf', get_tinexinf_name(v_codinctv, global_v_lang));
            obj_data.put('withdraw', v_withdraw);
            obj_data.put('dtepayment',to_char(i.dtepay,'dd/mm/yyyy'));
            --> Peerasak || Issue#8700 || 25/11/2022
            obj_data.put('numreq',i.numtravrq);
            obj_data.put('amount', i.amtreq);
            obj_data.put('codappr', get_temploy_name(i.codappr,global_v_lang));
            obj_data.put('dteappr', to_char(i.dteappr ,'dd/mm/yyyy'));
            obj_data.put('codcomp',i.codcomp);

            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TTRAVINF');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
   end; --procedure gen_data3

  procedure gen_numpaymt (json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;

    v_codempid          temploy1.codempid%type;
    v_codcomp           temploy1.codcomp%type;
    v_numpaymt          tclnsinf.numpaymt%type;

    v_codcompy          tcompny.codcompy%type;
    v_year              number;
    v_yy                varchar2(2);
    v_running           number;
    v_strt              number;

    v_dtepay            date;
    v_rowid             rowid;
    v_error		   	    terrorm.errorno%type;
    v_first             boolean:=true;

    v_flgsecu           boolean;
    v_zupdsal           varchar2(400);

  begin
    initial_value(json_str_input);

    if param_msg_error is null then
        begin
            for i in 0..p_datarows.get_size-1 loop
                obj_row         := json_object_t();
                obj_row         := hcm_util.get_json_t(p_datarows,to_char(i));
                v_codempid      := hcm_util.get_string_t(obj_row,'codempid');
                v_codcomp       := hcm_util.get_string_t(obj_row,'codcomp');

                v_rowid_query   := hcm_util.get_string_t(obj_row,'rowid');
                v_dtepay        := to_date(hcm_util.get_string_t(obj_row,'dtepayment') , 'dd/mm/yyyy');
                v_numpaymt      := hcm_util.get_string_t(obj_row,'paymentno');

                --gen numpaymt
                v_codcompy      := hcm_util.get_codcomp_level(v_codcomp, '1');
                v_year          := to_number(to_char(sysdate,'yyyy'));
                v_yy            := to_char(sysdate,'yy','NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI');
                if v_numpaymt is null then
                    if b_index_typbf1ox = '1' then   --(tclnsinf)    --MD Exe. MD||codcompy||yr_thai(2)||running No.
                         --NUMPAYMT(15 CHAR) running 7 Digits
                         --Exe.  MDCOMY63||0000009
                        if v_first then
                            v_first := false;
                            begin
                                select max(numpaymt)
                                  into v_numpaymt
                                  from tclnsinf a
                                 where a.codcomp like v_codcompy||'%'
                                   and to_number(to_char( a.dtecash,'yyyy')) = v_year;
                            end;

                            v_strt      := nvl(length(v_codcompy),0) + 4;
                            v_numpaymt  := substr(v_numpaymt,v_strt+1);

                            begin
                                v_running := to_number(v_numpaymt);
                            exception when others then
                                v_running := 0;
                            end;
                         end if;
                         --seq2
                         v_running  := nvl(v_running,0) + 1;
                         v_numpaymt := 'MD'||v_codcompy||v_yy||lpad(v_running,(15-v_strt),'0');

                         --update data
                         update tclnsinf
                            set numpaymt = v_numpaymt,
                              dtepaymtap = sysdate,
                                dtepaymt = sysdate,                             --> Peerasak || Issue#8700 || 25/11/2022
                                coduser = global_v_coduser
                          where rowid = v_rowid_query;

                    elsif b_index_typbf1ox = '2' then  --BF  (tobfinf)
                        --Exe.  BFCOMY63||0000009
                        if v_first then
                            v_first := false;

                            begin
                                select max(numpaymt) into v_numpaymt
                                  from tobfinf a
                                 where a.codcomp like v_codcompy||'%'
                                   and to_number(to_char( a.dtepay,'yyyy')) = v_year;
                            end;

                            v_strt       := nvl(length(v_codcompy),0) + 4;
                            v_numpaymt   := substr(v_numpaymt,v_strt+1);

                            begin
                                v_running   := to_number(v_numpaymt);
                            exception when others then
                                v_running   := 0;
                            end;
                        end if;
                        --seq2
                        v_running  := nvl(v_running,0) + 1;
                        v_numpaymt := 'BF'||v_codcompy||v_yy||lpad(v_running,(15-v_strt),'0');

                        --update data
                        update tobfinf
                           set numpaymt = v_numpaymt,
                               dtepaymt = sysdate,                              --> Peerasak || Issue#8700 || 25/11/2022
                               coduser = global_v_coduser
                         where rowid = v_rowid_query;
                    elsif b_index_typbf1ox = '3' then  --TV
                        --Exe.  TVCOMY63||0000009
                        if v_first then
                            v_first := false;
                            begin
                                select max(numpaymt) into v_numpaymt
                                  from ttravinf a
                                 where a.codcomp like v_codcompy||'%'
                                   and to_number(to_char(a.dtepay,'yyyy')) = v_year;
                            end;
                            v_strt      := nvl(length(v_codcompy),0) + 4;
                            v_numpaymt  := substr(v_numpaymt,v_strt+1);
                            begin
                                v_running := to_number(v_numpaymt);
                            exception when others then
                                v_running := 0;
                            end;
                        end if;
                        --seq2
                        v_running   := nvl(v_running,0) + 1;
                        v_numpaymt  := 'TV'||v_codcompy||v_yy||lpad(v_running,(15-v_strt),'0');

                        --update data
                        update ttravinf
                           set numpaymt = v_numpaymt,
                               dtepaymt = sysdate,                              --> Peerasak || Issue#8700 || 25/11/2022
                               coduser = global_v_coduser
                         where rowid = v_rowid_query;
                    end if; --if v_flg = 'add' then
                end if;
            end loop;  --for i in 0..p_datarows.get_size-1 loop
            commit;
        exception when others then
            rollback;
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end;

        param_msg_error := get_error_msg_php('HR2715',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;   --procedure gen_numpaymt

  	procedure clear_ttemprpt is
	begin
		begin
			delete
			  from ttemprpt
			 where codempid = global_v_codempid
			   and codapp      = v_codapp;
		exception when others then
			null;
		end;
	end clear_ttemprpt;

   procedure initial_report(json_str in clob) is
		json_obj		json_object_t;
	begin
		json_obj                := json_object_t(json_str);
		global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
		global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');
		p_datarows              := hcm_util.get_json_t(json_obj, 'param_json');
	end initial_report;

   procedure gen_report(json_str_input in clob,json_str_output out clob) is
        json_output             clob;
        obj_row                 json_object_t;
        v_numpaymt              tclnsinf.numpaymt%type;
        v_no_numpaymt           boolean := false;

	begin
		initial_value(json_str_input);
		initial_report(json_str_input);
    v_codapp := 'HRBF1OX';      

		if param_msg_error is null then
			clear_ttemprpt;
			for i in 0..p_datarows.get_size-1 loop
        obj_row             := hcm_util.get_json_t(p_datarows, to_char(i));
				v_numpaymt       := hcm_util.get_string_t(obj_row, 'paymentno');
        if v_numpaymt is null then
            v_no_numpaymt := true;
            exit;
        end if;
			end loop;

      if not v_no_numpaymt then
          for i in 0..p_datarows.get_size-1 loop
              obj_row             := hcm_util.get_json_t(p_datarows, to_char(i));
              v_rowid_query       := hcm_util.get_string_t(obj_row, 'rowid');
              insert_report(json_str_output);
             commit;
          end loop;
      else
          param_msg_error := get_error_msg_php('BF0060',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
          return;
      end if;
		end if;

		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
	json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_report;

   procedure check_vouchernumber(json_str_input in clob,json_str_output out clob) is
        json_output             clob;
        obj_row                 json_object_t;
        v_numpaymt              tclnsinf.numpaymt%type;
        v_no_numpaymt           boolean := false;
	begin
		initial_value(json_str_input);
		initial_report(json_str_input);

		if param_msg_error is null then
			clear_ttemprpt;
			for i in 0..p_datarows.get_size-1 loop
                obj_row          := hcm_util.get_json_t(p_datarows, to_char(i));
				v_numpaymt       := hcm_util.get_string_t(obj_row, 'paymentno');
                if v_numpaymt is null then
                    v_no_numpaymt := true;
                    exit;
                end if;
			end loop;
            if v_no_numpaymt then
                param_msg_error := get_error_msg_php('BF0060',global_v_lang);
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;
		end if;

		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
	json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end check_vouchernumber;

   procedure InsertTmpVoucher(json_str_input in clob,json_str_output out clob) is
        json_output             clob;
        obj_row                 json_object_t;
        obj_row_sub             json_object_t;
        obj_data                json_object_t;
        obj_data_sub            json_object_t;
        v_row                   number := 0;
        v_row_sub               number := 0;
        v_numpaymt              tclnsinf.numpaymt%type;
        v_no_numpaymt           boolean := false;
        v_codempid              tclnsinf.codempid%type;

        cursor c1 is
            select distinct item1 codempid
              from ttemprpt
             where codempid= global_v_codempid
               and codapp = v_codapp;
        cursor c2 is
            select item1 codempid, item2 paymentno, item3
              from ttemprpt
             where codempid= global_v_codempid
               and codapp = v_codapp
               and item1 = v_codempid;
	begin
		initial_value(json_str_input);
		initial_report(json_str_input);
        v_codapp := 'HRBF1OXR1';
		if param_msg_error is null then
			clear_ttemprpt;
			for i in 0..p_datarows.get_size-1 loop
                obj_row             := hcm_util.get_json_t(p_datarows, to_char(i));
                v_numpaymt          := hcm_util.get_string_t(obj_row, 'paymentno');
                v_codempid          := hcm_util.get_string_t(obj_row, 'codempid');
                v_rowid_query       := hcm_util.get_string_t(obj_row, 'rowid');
                v_numseq            := v_numseq + 1;
                begin
                    insert into ttemprpt (codempid, codapp, numseq,
                                          item1, item2, item3)
                    values(global_v_codempid, v_codapp, v_numseq,
                           v_codempid, v_numpaymt, v_rowid_query);
                exception when dup_val_on_index then
                    null;
                end;
			end loop;
		end if;

        obj_row := json_object_t;
        for r1 in c1 loop
            v_row := v_row + 1;
            obj_data := json_object_t;
            v_codempid  := r1.codempid;
            obj_data.put('codempid',r1.codempid);
            v_row_sub   := 0;
            obj_row_sub := json_object_t;
            for r2 in c2 loop
                v_row_sub   := v_row_sub + 1;
                obj_data_sub := json_object_t;
                obj_data_sub.put('codempid',r2.codempid);
                obj_data_sub.put('paymentno',r2.paymentno);
                obj_data_sub.put('rowid',r2.item3);
                obj_row_sub.put(to_char(v_row_sub-1),obj_data_sub);
            end loop;
            obj_data.put('voucher',obj_row_sub);
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;

		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
	json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end InsertTmpVoucher;

  PROCEDURE insert_report (json_str_output OUT CLOB) IS
    v_namtypay            tapplscr.desclabelt%type;
    v_numseq_numtravrq    NUMBER := 0;
    v_numtravrq           VARCHAR2(12 CHAR);
    v_costcent            tcenter.costcent%type;
    v_labelbf             tapplscr.desclabelt%type;
    v_labeltot            tapplscr.desclabelt%type;
    v_item22              tapplscr.desclabelt%type;
    v_item23              tapplscr.desclabelt%type;

    cursor c1 is
      select '1' typpay,
             a.numpaymt , a.dtecash   dtepay,
             a.codempid   , a.codcomp ,
             a.amtalw  amtpay  ,
             a.dteappr , a.codappr , a.numvcher
        from tclnsinf a
       where a.rowid = v_rowid_query
         and b_index_typbf1ox = '1'
       union
      select '2' typpay,
             a.numpaymt , a.dtepay   dtepay,
             a.codempid   , a.codcomp ,
             a.amtwidrw  amtpay  ,
             a.dteappr    , a.codappr , a.numvcher
        from tobfinf a
       where a.rowid = v_rowid_query
         and b_index_typbf1ox = '2'
       union
      select '3' typpay,
             a.numpaymt , a.dtepay   dtepay,
             a.codempid   , a.codcomp ,
             a.amtreq  amtpay  ,
             a.dteappr , a.codappr , a.numtravrq
        from ttravinf a
       where a.rowid = v_rowid_query
         and b_index_typbf1ox = '3';

    cursor c2 is
      select get_tcodec_name('TCODEXP', codexp, 102) as codexp, amtreq
        from ttravinfd
       where numtravrq = v_numtravrq;

	BEGIN
		obj_row := json_object_t();

		for i in C1 loop
      begin
          select costcent into v_costcent
            from tcenter
           where codcomp = i.codcomp;
         exception when no_data_found then
          v_costcent := null;
      end;

      v_namtypay          := get_tlistval_name('TYPBF1OX',i.typpay, global_v_lang);
--      v_namtypay          := get_label_name('HRBF1OX',global_v_lang,910) ;  --cash
      v_labelbf           := get_tlistval_name('TYPBF1OX',i.typpay, global_v_lang);
      v_labeltot          := get_label_name('HRBF1OX',global_v_lang,920) ;  --total

      v_numseq    := v_numseq + 1;
      insert into ttemprpt (codempid,codapp,numseq,
          --key
          item1,    item2, item3,
          --header
          item11,  item12,   item13,  item14,   item15,
          item16,  item17,   item18,
          --detail
          item21,  item22,   item23
      )
      values (global_v_codempid, v_codapp ,v_numseq,
      --key item1-2
      'HEAD' , i.numvcher, i.numpaymt,
      --header item11-18
      i.numpaymt, hcm_util.get_date_buddhist_era(i.dtepay),  i.codempid||' - '||get_temploy_name(i.codempid,global_v_lang),  get_tcenter_name(i.codcomp,global_v_lang), v_costcent,
      v_namtypay, hcm_util.get_date_buddhist_era(i.dteappr), i.codappr||' - '||get_temploy_name(i.codappr,global_v_lang),
      --detail
      null,  null, null);            


      if i.typpay = 3 then        
        v_numtravrq := i.numvcher;

        for r1 in c2 loop
          v_item22 := r1.codexp;
          v_item23 := to_char(r1.amtreq,'fm999,999,990.00');

          v_numseq := v_numseq + 1;
          v_numseq_numtravrq := v_numseq_numtravrq + 1;
          insert into ttemprpt (codempid,codapp,numseq,
                --key
                item1,    item2,   item3, item4,
                --header
                item11,  item12,   item13,  item14,   item15,
                item16,  item17,   item18,
                --detail
                item21,  item22,   item23
          )
          values (global_v_codempid, v_codapp ,v_numseq,
                --key item1-2
                'DETAIL' , i.numvcher, i.numpaymt, v_numseq_numtravrq,
                --header item11-18
                i.numpaymt, hcm_util.get_date_buddhist_era(i.dtepay), i.codempid||' - '||get_temploy_name(i.codempid,global_v_lang), get_tcenter_name(i.codcomp,global_v_lang), v_costcent,
                v_namtypay, hcm_util.get_date_buddhist_era(i.dteappr), i.codappr||' - '||get_temploy_name(i.codappr,global_v_lang),
                --detail
                null,  v_item22, v_item23);          
        end loop;

        -- Summay Row
        v_numseq := v_numseq + 1;
        v_numseq_numtravrq := v_numseq_numtravrq + 1;

        v_item22    := v_labeltot;
        v_item23    := to_char(i.amtpay,'fm999,999,990.00');

        insert into ttemprpt (codempid,codapp,numseq,
              --key
              item1,    item2,   item3, item4,
              --header
              item11,  item12,   item13,  item14,   item15,
              item16,  item17,   item18,
              --detail
              item21,  item22,   item23
        )
        values (global_v_codempid, v_codapp ,v_numseq,
              --key item1-2
              'DETAIL' , i.numvcher, i.numpaymt, v_numseq_numtravrq,
              --header item11-18
              i.numpaymt, hcm_util.get_date_buddhist_era(i.dtepay), i.codempid||' - '||get_temploy_name(i.codempid,global_v_lang), get_tcenter_name(i.codcomp,global_v_lang), v_costcent,
              v_namtypay, hcm_util.get_date_buddhist_era(i.dteappr), i.codappr||' - '||get_temploy_name(i.codappr,global_v_lang),
              --detail
              null,  v_item22, v_item23);
      else
        --Detail  record1,2
        for j in 1..2 loop
          if j = 1 then
            v_item22    := v_labelbf;
--            v_item23    := to_char(i.amtpay,'fm999,999,990.00');
          elsif j = 2 then
            v_item22    := v_labeltot;
--            v_item23    := to_char(i.amtpay,'fm999,999,990.00');
          end if;

          v_item23    := to_char(i.amtpay,'fm999,999,990.00');

          v_numseq := v_numseq + 1;
          insert into ttemprpt (codempid,codapp,numseq,
                --key
                item1,    item2,   item3, item4,
                --header
                item11,  item12,   item13,  item14,   item15,
                item16,  item17,   item18,
                --detail
                item21,  item22,   item23
          )
          values (global_v_codempid, v_codapp ,v_numseq,
                --key item1-2
                'DETAIL' , i.numvcher, i.numpaymt, j,
                --header item11-18
                i.numpaymt, hcm_util.get_date_buddhist_era(i.dtepay), i.codempid||' - '||get_temploy_name(i.codempid,global_v_lang), get_tcenter_name(i.codcomp,global_v_lang), v_costcent,
                v_namtypay, hcm_util.get_date_buddhist_era(i.dteappr), i.codappr||' - '||get_temploy_name(i.codappr,global_v_lang),
                --detail
                null,  v_item22, v_item23);          
        end loop;  --for j in 1..2 loop
      end if;
		end loop;   --for i in C1 loop
    json_str_output := obj_row.to_clob;
	EXCEPTION WHEN OTHERS THEN
        param_msg_error := dbms_utility.format_error_stack|| ' '|| dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END insert_report;

  procedure send_mailemp(json_str_input in clob, json_str_output out clob) as
    obj_row             json_object_t;
    v_msg_to            clob;
    v_templete_to       clob;

    v_codempid          temploy1.codempid%type;
    v_error			    terrorm.errorno%type;
    v_fromemail         temploy1.email%type;
    v_empemail          temploy1.email%type;
    v_filename1   	    varchar2(1000 char);
    v_subject           tapplscr.desclabelt%type;
    v_numpaymt          tclnsinf.numpaymt%type;
    v_no_numpaymt       boolean := false;
  begin
    initial_value(json_str_input);
    param_msg_error := null;
    if param_msg_error is null then
        v_fromemail     :=  get_tsetup_value('MAILEMAIL');
        begin
            for i in 0..p_datarows.get_size-1 loop
                obj_row             := json_object_t();
                obj_row             := hcm_util.get_json_t(p_datarows,to_char(i));
                v_rowid_query       := hcm_util.get_string_t(obj_row,'rowid');          --Key
                v_codempid          := hcm_util.get_string_t(obj_row,'codempid');
                v_filename1         := hcm_util.get_string_t(obj_row,'filename');

                begin
                    select email into v_empemail
                      from temploy1
                     where codempid = v_codempid;
                exception when no_data_found then
                    v_empemail := null ;
                end ;

                if v_empemail is not null  then
                      ---sendmail owner Request
                      v_rowid_query := null;
                      if b_index_typbf1ox = '1' then  --tclnsinf
                            v_subject  := get_label_name('HRBF1OX', global_v_lang, 810);
                            chk_flowmail.get_message_result('HRBF1OX1', global_v_lang, v_msg_to, v_templete_to);
                            chk_flowmail.replace_text_frmmail(v_templete_to, null, v_rowid_query , v_subject , 'HRBF1OX1', '1', null, global_v_coduser, global_v_lang, v_msg_to, p_file => v_filename1);
                      elsif b_index_typbf1ox = '2' then  --tobfinf
                            v_subject  := get_label_name('HRBF1OX', global_v_lang, 820);
                            chk_flowmail.get_message_result('HRBF1OX2', global_v_lang, v_msg_to, v_templete_to);
                            chk_flowmail.replace_text_frmmail(v_templete_to, null,  v_rowid_query , v_subject , 'HRBF1OX2', '1', null, global_v_coduser, global_v_lang, v_msg_to, p_file => v_filename1);
                      elsif b_index_typbf1ox = '3' then  --ttravinf
                            v_subject  := get_label_name('HRBF1OX', global_v_lang, 830);
                            chk_flowmail.get_message_result('HRBF1OX3', global_v_lang, v_msg_to, v_templete_to);
                            chk_flowmail.replace_text_frmmail(v_templete_to, null, v_rowid_query , v_subject , 'HRBF1OX3', '1', null, global_v_coduser, global_v_lang, v_msg_to, p_file => v_filename1);
                      end if;
                      --Test sendmail    v_filename1 := 'https://www.aws-test.peopleplus.co.th/static/image/icon/process.gif';
                      v_error := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, v_filename1,null,null, null);
                end if; --if v_empemail is not null
            end loop;  --for i in 0..p_selected_rows.get_size-1 loop
        exception when others then
            rollback;
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end;
        param_msg_error := get_error_msg_php('HR'||v_error,global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end send_mailemp;
end;

/

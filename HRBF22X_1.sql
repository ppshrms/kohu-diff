--------------------------------------------------------
--  DDL for Package Body HRBF22X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF22X" AS

 procedure initial_value(json_str_input in clob) as
   json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_query_codempid  := hcm_util.get_string(json_obj,'p_query_codempid');
        p_dteacd          := to_date(hcm_util.get_string(json_obj,'p_dteacd'),'dd/mm/yyyy');
        p_dtesmit         := to_date(hcm_util.get_string(json_obj,'p_dtesmit'),'dd/mm/yyyy');

        v_codapp          := 'HRBF22X';

  end initial_value;

  procedure check_report as
    v_temp  varchar(1 char);
  begin
--  check null parameters
    if p_query_codempid is null or p_dteacd is null and p_dtesmit is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check employee in temploy1
    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_query_codempid;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
    end;

--  check secure2
    if global_v_coduser is not null then
        if secur_main.secur2(p_query_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;
  end check_report;

  procedure clear_ttemprpt is
    begin
        begin
            delete
            from  ttemprpt
            where codempid = global_v_codempid
            and   codapp   = v_codapp;
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
        where codempid = p_query_codempid
          and codapp = v_codapp;
    if max_numseq is null then
        max_numseq := 0 ;
    end if;

    p_numseq := max_numseq+1;

    return p_numseq;

  end;

  function get_codincom(v_amtincome varchar2, v_numseq varchar2, v_codcomp varchar2) return varchar2 as
    v_codincome   tcontpms.codincom1%type := '';
    v_statment    long;
  begin
    if v_amtincome <> '0' then ---- if v_amtincome is not null or v_amtincome != '' then
        v_statment := 'select codincom'||v_numseq||
                      ' from tcontpms a'||
                      ' where a.codcompy = '||''''||get_codcompy(v_codcomp)||''''||
                      '   and a.dteeffec =(select max(b.dteeffec) from tcontpms b'||
                                    ' where b.codcompy = a.codcompy'||
                                    ' and b.dteeffec <= trunc(sysdate))';

        execute immediate v_statment into v_codincome;

    end if;

    return v_codincome;

  end;

  procedure gen_report(json_str_output out clob) as
   v_thwccase           thwccase%rowtype;
   v_max_numseq         number;
   v_numacdsd           tcompny.numacdsd%type;
   v_codsubdist         tcompny.codsubdist%type;
   v_coddist            tcompny.coddist%type;
   v_codprovr           tcompny.codprovr%type;
   v_typbusiness        tcompny.typbusiness%type;
   v_count              number;
   v_codbrlc            temploy1.codbrlc%type;
   v_emp_adr            temploy2.adrregt%type;
   v_emp_codsubdistr    temploy2.codsubdistr%type;
   v_emp_coddistr       temploy2.codsubdistr%type;
   v_emp_codprovr       temploy2.codprovr%type;
   v_emp_numoffid       temploy2.numoffid%type;
   v_emp_numsaid        temploy3.numsaid%type;
   v_emp_dteempmt       temploy1.dteempmt%type;
   v_emp_codpos         temploy1.codpos%type;
   v_emp_codcomp        temploy1.codcomp%type;
   v_codempmt           temploy1.codempmt%type;
   v_emp_dob            temploy1.dteempdb%type;
   v_amtincom1          temploy3.amtincom1%type;
   v_amtincom2          temploy3.amtincom2%type;
   v_amtincom3          temploy3.amtincom3%type;
   v_amtincom4          temploy3.amtincom4%type;
   v_amtincom5          temploy3.amtincom5%type;
   v_amtincom6          temploy3.amtincom6%type;
   v_amtincom7          temploy3.amtincom7%type;
   v_amtincom8          temploy3.amtincom8%type;
   v_amtincom9          temploy3.amtincom9%type;
   v_amtincom10         temploy3.amtincom10%type;
   v_sumhur             number;
   v_sumday             number;
   v_summth             number;
   v_other_income       number;
   v_unitcal1           tcontpmd.unitcal1%type;
   v_unitamt            number;
   v_r_name             varchar2(100 char);
   v_r_position         varchar2(100 char);
   v_signname           varchar2(100 char);
   v_addrno             tcompny.addrnoe%type;
   v_moo                tcompny.mooe%type;
   v_soi                tcompny.soie%type;
   v_road               tcompny.roade%type;
   v_zipcode            tcompny.zipcode%type;
   v_phone_no           tcompny.NUMTELE%type;
   v_timstrtw           tattence.timstrtw%type;
   v_timendw            tattence.timendw%type;
   v_qtydwpp            tgrpwork.qtydwpp%type;
   v_emp_codcalen       temploy1.codcalen%type;
   v_emp_codpostr       temploy2.codpostr%type;
   v_emp_nummobile      temploy1.nummobile%type;
   add_month            number := 543*12;
   v_other_income_name  long;
   v_codtitle           temploy1.codtitle%type;
   v_codtitle_mr        varchar2(5 char) := '';
   v_codtitle_mrs       varchar2(5 char) := '';
   v_codtitle_miss      varchar2(5 char) := '';
   v_item56             varchar2(1); -- codtitle
   v_empname_notitle    varchar2(500);

   cursor c_tgrpwork is
    select qtydwpp
    from tgrpwork a
    where v_emp_codcomp like codcomp || '%'
      and codcalen = v_emp_codcalen
      and dteeffec = (select max(b.dteeffec) from tgrpwork b
                       where b.codcomp = a.codcomp
                         and b.codcalen = a.codcalen and  b.dteeffec <= SYSDATE)
    order by codcomp desc;
  begin

--  get data from thwccase
    begin
        select * into v_thwccase
        from thwccase
        where codempid = p_query_codempid
          and dteacd = nvl(p_dteacd,dteacd)
          and ((dtesmit = p_dtesmit and p_dtesmit is not null) or p_dtesmit is null);
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'THWCCASE');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end;

--  get data from tcompny
    begin
        select numacdsd,codsubdist,coddist,codprovr,typbusiness,
        decode(global_v_lang, '101', addrnoe,
                              '102', addrnot,
                              '103', addrno3,
                              '104', addrno4,
                              '105', addrno5) addrno,
        decode(global_v_lang, '101', mooe,
                              '102', moot,
                              '103', moo3,
                              '104', moo4,
                              '105', moo5) moo,
        decode(global_v_lang, '101', soie,
                              '102', soit,
                              '103', soi3,
                              '104', soi4,
                              '105', soi5) soi,
        decode(global_v_lang, '101', roade,
                              '102', roadt,
                              '103', road3,
                              '104', road4,
                              '105', road5) road,
        zipcode,numtele
        into v_numacdsd,v_codsubdist,v_coddist,v_codprovr,v_typbusiness,v_addrno,v_moo,v_soi,v_road,v_zipcode,v_phone_no
        from tcompny
        where codcompy = hcm_util.get_codcomp_level(v_thwccase.codcomp,1);
    exception when no_data_found then
        v_numacdsd    := '';
        v_codsubdist  := '';
        v_coddist     := '';
        v_codprovr    := '';
        v_typbusiness := '';
        v_addrno      := '';
        v_moo         := '';
    end;    

--  count employee
    begin
        select count(codempid) into v_count
        from temploy1
        where codcomp like hcm_util.get_codcomp_level(v_thwccase.codcomp,1) || '%'
          and staemp in ('1','3');
    exception when no_data_found then
        v_count := 0;
    end;

--  get data from temploy1
    begin
        select decode(global_v_lang,'101',namfirste || ' ' || namlaste,
                '102',namfirstt || ' ' || namlastt,
                '103',namfirst3 || ' ' || namlast3,
                '104',namfirst4 || ' ' || namlast4,
                '105',namfirst5 || ' ' || namlast5,
                namfirste || ' ' || namlaste) empname,
            codtitle, codbrlc, dteempmt, codpos, codcomp, codempmt, codcalen, nummobile, dteempdb
        into v_empname_notitle,v_codtitle, v_codbrlc, v_emp_dteempmt, v_emp_codpos, v_emp_codcomp, v_codempmt, v_emp_codcalen, v_emp_nummobile, v_emp_dob
        from temploy1
        where codempid = p_query_codempid;
    exception when no_data_found then
        v_codbrlc      := '';
        v_emp_dteempmt := '';
        v_emp_codpos   := '';
    end;

    if v_codtitle = '003' then
        v_codtitle_mr   := ')';
        v_item56        := '1';
    elsif v_codtitle = '005' then
        v_codtitle_mrs := '(';
        v_item56        := '2';
    elsif v_codtitle = '004' then
        v_codtitle_miss := '(';
        v_item56        := '3';
    end if;

--  get data from temploy2
    begin
        select decode(global_v_lang,101,adrrege,
                                    102,adrregt,
                                    103,adrreg3,
                                    104,adrreg4,
                                    105,adrreg5) address,
              CODSUBDISTR,CODDISTR,CODPROVR,numoffid,codpostr
        into v_emp_adr,v_emp_codsubdistr,v_emp_coddistr,v_emp_codprovr,v_emp_numoffid,v_emp_codpostr
        from temploy2
        where codempid = p_query_codempid;
    exception when no_data_found then
        v_emp_adr           := '';
        v_emp_codsubdistr   := '';
        v_emp_coddistr      := '';
        v_emp_codprovr      := '';
        v_emp_numoffid      := '';
    end;

--  get data from temploy3
    begin
        select numsaid into v_emp_numsaid
        from temploy3
        where codempid = p_query_codempid;
    exception when no_data_found then
        v_emp_numsaid := '';
    end;

--  get data from tcontpmd
    begin
        select unitcal1 into v_unitcal1
        from tcontpmd
        where codcompy = hcm_util.get_codcomp_level(v_thwccase.codcomp,1)
          and rownum = 1
        order by DTEEFFEC desc;
    exception when no_data_found then
        v_unitcal1 := '';
    end;

--  get income
    begin
        select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
        into v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
        from temploy3
        where codempid = p_query_codempid;
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

--  decode income
    v_amtincom1  := stddec(v_amtincom1,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom2  := stddec(v_amtincom2,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom3  := stddec(v_amtincom3,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom4  := stddec(v_amtincom4,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom5  := stddec(v_amtincom5,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom6  := stddec(v_amtincom6,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom7  := stddec(v_amtincom7,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom8  := stddec(v_amtincom8,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom9  := stddec(v_amtincom9,p_query_codempid,hcm_secur.get_v_chken);
    v_amtincom10 := stddec(v_amtincom10,p_query_codempid,hcm_secur.get_v_chken);
    get_wage_income(v_emp_codcomp, v_codempmt, v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5, v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10, v_sumhur, v_sumday, v_summth);
--  sum other income
    v_other_income := v_amtincom2 + v_amtincom3 + v_amtincom4 + v_amtincom5 + v_amtincom6 + v_amtincom7 + v_amtincom8 + v_amtincom9 + v_amtincom10;
    if v_unitcal1 = 'H' then
        v_unitamt := v_sumhur;
    elsif v_unitcal1 = 'D' then
        v_unitamt := v_sumday;
    elsif v_unitcal1 = 'M' then
        v_unitamt := v_summth;
    end if;

--Redmine 2800
    if secur_main.secur2(p_query_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal) = false then
        v_unitamt := null;
    end if;
--Redmine 2800

    begin
        select timstrtw,timendw into v_timstrtw,v_timendw
        from tattence
        where codempid = v_thwccase.codempid
          and dtework = v_thwccase.dteacd;
--          and rownum = 1;
    exception when no_data_found then
        v_timendw := '';
        v_timstrtw :=  '';
    end;

    begin
        for i in c_tgrpwork loop
            v_qtydwpp := i.qtydwpp;
            exit;
        end loop;
    end;

    v_max_numseq := get_max_numseq;
    v_signname := get_tsetup_value('PATHWORKPHP')||get_tsetsign('HRBF22X',hcm_util.get_codcomp_level(v_thwccase.codcomp,1),global_v_lang,v_r_name,v_r_position);

    v_other_income_name := regexp_replace(replace(/*get_tinexinf_name(get_codincom(v_amtincom1, '1', v_thwccase.codcomp), global_v_lang)||'  '||*/get_tinexinf_name(get_codincom(v_amtincom2, '2', v_thwccase.codcomp), global_v_lang)||'  '||get_tinexinf_name(get_codincom(v_amtincom3, '3', v_thwccase.codcomp), global_v_lang)||'  '||
                           get_tinexinf_name(get_codincom(v_amtincom4, '4', v_thwccase.codcomp), global_v_lang)||'  '||get_tinexinf_name(get_codincom(v_amtincom5, '5', v_thwccase.codcomp), global_v_lang)||'  '||get_tinexinf_name(get_codincom(v_amtincom6, '6', v_thwccase.codcomp), global_v_lang)||'  '||
                           get_tinexinf_name(get_codincom(v_amtincom7, '7', v_thwccase.codcomp), global_v_lang)||'  '||get_tinexinf_name(get_codincom(v_amtincom8, '8', v_thwccase.codcomp), global_v_lang)||'  '||get_tinexinf_name(get_codincom(v_amtincom9, '9', v_thwccase.codcomp), global_v_lang)||'  '||
                           get_tinexinf_name(get_codincom(v_amtincom10, '10', v_thwccase.codcomp), global_v_lang), '***************'), '[[:space:]]+',', ');

--  insert article 1
    insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15,item16,item18,item19,item20,item21,item22,item23,
                        item24,item25,item26,item27,item28,item29,item30,item31,item32,item33,item34,item35,item36,item37,item38,item39,item40,item41,item42,item43,item44,item45,item46,item47,item48,item49,item50,item51,
                        item52,item53,item54,item55,item56,item57)
    values(global_v_codempid, v_codapp, v_max_numseq,
--         article 1
           get_tcompny_name(hcm_util.get_codcomp_level(v_thwccase.codcomp,1),global_v_lang), v_numacdsd, v_addrno, v_moo, v_soi, v_road, get_tsubdist_name(v_codsubdist,global_v_lang), get_tcoddist_name(v_coddist,global_v_lang), get_tcodec_name('TCODPROV',v_codprovr,global_v_lang),
           v_zipcode, v_phone_no, v_typbusiness, v_count, get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang),
--         article2
           v_empname_notitle, v_emp_adr, get_tcoddist_name(v_emp_coddistr,global_v_lang), get_tcoddist_name(v_emp_coddistr,global_v_lang),
           get_tcodec_name('TCODPROV',v_emp_codprovr,global_v_lang), v_emp_numoffid, v_emp_numsaid,
--         article3
           hcm_util.get_date_buddhist_era(v_emp_dteempmt),get_tpostn_name(v_emp_codpos,global_v_lang),
--         article4
           char_time_to_format_time(v_timstrtw), char_time_to_format_time(v_timendw), v_qtydwpp,
--         article5
           to_char(v_unitamt,'fm999,999,990.00'),
--         article6
--           v_other_income,
           v_other_income_name,
--         article7
           v_thwccase.placeacd, get_tsubdist_name(v_thwccase.codsubdist,global_v_lang), get_tcoddist_name(v_thwccase.coddist,global_v_lang),get_tcodec_name('TCODPROV',v_thwccase.codprov,global_v_lang),
--         article8
           hcm_util.get_date_buddhist_era(v_thwccase.dteacd), substr(v_thwccase.timeacd,1,2)||':'||substr(v_thwccase.timeacd,3,2), hcm_util.get_date_buddhist_era(v_thwccase.dtenotifi),
--         article9
           hcm_util.get_date_buddhist_era(v_thwccase.dtestr), hcm_util.get_date_buddhist_era(v_thwccase.dteend + 1),
--         article10
           v_thwccase.desnote,
--         article11
           v_thwccase.resultacd,
--         article12
           v_thwccase.namwitness || ' ' ||v_thwccase.addrwitness,
--         article13
           get_tclninf_name(v_thwccase.codclnright,global_v_lang),
--         article14
           get_tclninf_name(v_thwccase.codcln,global_v_lang), v_thwccase.idpatient,
--         'footer'
           v_signname, v_r_name, v_r_position, hcm_util.get_date_buddhist_era(sysdate),
--         'article2 '
           substr(get_age(v_emp_dob,sysdate),0,2),'detail',v_emp_codpostr,v_emp_nummobile,
--         codtitle
           v_codtitle_mr, v_codtitle_mrs, v_codtitle_miss, v_item56,v_unitcal1);

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);

  end gen_report;

  procedure get_report(json_str_input in clob,json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_report;
    clear_ttemprpt;
    if param_msg_error is null then
        gen_report(json_str_output);
    else

        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_report;

END HRBF22X;

/

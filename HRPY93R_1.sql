--------------------------------------------------------
--  DDL for Package Body HRPY93R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY93R" as
  function split_number_id (v_item number) return varchar2 as
    v_cnt           number := 0;
    v_text_numoffid varchar2(1000 char);
  begin
    if length(v_item) = 13 then
      for r1 in 1..17 loop
        if r1 in ('2','7','13','16') then -- concat symbols
          v_text_numoffid :=  v_text_numoffid || '-';
        else
          v_cnt := v_cnt + 1;
          v_text_numoffid :=  v_text_numoffid || substr(v_item, v_cnt, 1);
        end if;
      end loop;
    else
      v_text_numoffid := v_item;
    end if;
    return v_text_numoffid;
  end split_number_id;

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_year              := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    p_codrevn           := hcm_util.get_string_t(obj_detail,'codrevn');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_detail1 as
      v_secur boolean := false;
  begin
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
      v_secur :=  secur_main.secur7(p_codcomp,global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_codrevn is not null then
      begin
        select codcodec
          into p_codrevn
          from tcodrevn
         where codcodec = p_codrevn;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodrevn');
      end;
    end if;
  end check_detail1;

  procedure get_detail1(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail1;
    if param_msg_error is null then
        gen_detail1(json_str_output);
        if param_msg_error is not null then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          rollback;
        end if;
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail1;

  procedure gen_detail1(json_str_output out clob) as
    v_count_process     number := 0;
    v_numcotax          tcompny.numcotax%type;
    v_namcomt           tcompny.namcomt%type;
    v_buildingt         tcompny.buildingt%type;
    v_roomnot           tcompny.roomnot%type;
    v_floort            tcompny.floort%type;
    v_villaget          tcompny.villaget%type;
    v_addrnot           tcompny.addrnot%type;
    v_moot              tcompny.moot%type;
    v_soit              tcompny.soit%type;
    v_roadt             tcompny.roadt%type;
    v_desc_codsubdist   varchar2(4000 char);
    v_desc_coddist      varchar2(4000 char);
    v_desc_codprovr     varchar2(4000 char);
    v_zipcode           tcompny.zipcode%type;
    v_numtele           tcompny.numtele%type;

    v_page              number;
    v_rec1              number;
    v_income1           varchar2(100);
    v_income_deci1      varchar2(100);
    v_tax1              varchar2(100);
    v_tax_deci1         varchar2(100);
    v_rec2              number;
    v_income2           varchar2(100);
    v_income_deci2      varchar2(100);
    v_tax2              varchar2(100);
    v_tax_deci2         varchar2(100);
    v_rec3              number;
    v_income3           varchar2(100);
    v_income_deci3      varchar2(100);
    v_tax3              varchar2(100);
    v_tax_deci3         varchar2(100);
    v_rec4              number;
    v_income4           varchar2(100);
    v_income_deci4      varchar2(100);
    v_tax4              varchar2(100);
    v_tax_deci4         varchar2(100);
    v_rec5              number;
    v_income5           varchar2(100);
    v_income_deci5      varchar2(100);
    v_tax5              varchar2(100);
    v_tax_deci5         varchar2(100);
    v_recall            number := 0;
    v_incomeall         number := 0;
    v_income_deciall    varchar2(100);
    v_taxall            number := 0;
    v_tax_deciall       varchar2(100);

    v_typsign           tsetsign.typsign%type;
    v_codempid          tsetsign.codempid%type;
    v_codcomp           tsetsign.codcomp%type;
    v_codpos            tsetsign.codpos%type;
    v_signname          tsetsign.signname%type;
    v_posname           tsetsign.posname%type;
    v_namsign           tsetsign.namsign%type;

    v_name              varchar2(4000 char);
    v_desc_codpos       varchar2(4000 char);
    v_folder            tfolderd.folder%type;

    obj_json            json_object_t;
    v_codrevn           tcodrevn.codcodec%type;
    v_has_image         varchar2(1) := 'N';

    -- page
    v_all_page         number := 0;
    v_current_page     number := 0;
    v_resultmod        number;
    v_resultdivide     number;

    v_flgsecu         boolean;
    v_fetch           boolean;
    v_flg_exist boolean := false;


    cursor c1(v_codcodec tcodrevn.codcodec%type) is
        select codcodec
          from tcodrevn
         where codcodec = v_codcodec;
    cursor c2 is
      select typinc,(count(distinct codempid)) numrec,
             sum(nvl(stddec(amtinc,codempid,global_v_chken),0)) amtinc,
             sum(nvl(stddec(amttax,codempid,global_v_chken),0)) amttax
        from ttaxinc
       where codcomp   like p_codcomp || '%'
         and dteyrepay = p_year
         and typinc    = nvl(p_codrevn,typinc)
         and typinc    = v_codrevn
         -- and to_number(stddec(amtinc,codempid,global_v_chken)) > 0
         and numlvl between global_v_numlvlsalst and global_v_numlvlsalen
         and exists(select tusrcom.codcomp
                      from tusrcom
                     where tusrcom.coduser = global_v_coduser
                       and ttaxinc.codcomp  like tusrcom.codcomp || '%')
    group by typinc
    order by typinc;

    cursor c3 is
      select codempid
        from ttaxinc
       where codcomp   like p_codcomp || '%'
         and dteyrepay = p_year
         and typinc    = nvl(p_codrevn,typinc)
         And typinc in ('1101','1201','1301','1401','1501')
         --and to_number(stddec(amtinc,codempid,global_v_chken)) > 0
    group by codempid
    order by codempid;
  begin
    -- 1/3
    begin
      select numcotax,namcomt ,buildingt,roomnot,
             floort    ,villaget,addrnot  ,moot   ,
             soit      ,roadt  ,
             get_tsubdist_name(codsubdist,global_v_lang),
             get_tcoddist_name(coddist,global_v_lang),
             get_tcodec_name('TCODPROV',codprovr,global_v_lang),
             zipcode   ,numtele
        into v_numcotax,v_namcomt ,v_buildingt,v_roomnot,
             v_floort    ,v_villaget,v_addrnot  ,v_moot   ,
             v_soit      ,v_roadt   ,
             v_desc_codsubdist,
             v_desc_coddist   ,
             v_desc_codprovr  ,
             v_zipcode   ,v_numtele
        from tcompny
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
    exception when no_data_found then
      null;
    end;
    -- 2/3

    v_current_page := 0;
    v_all_page := 0;
    v_fetch := false;
    v_flg_exist:= false;
    for r3 in c3 loop
        v_flg_exist := true;
        v_flgsecu := secur_main.secur2(r3.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
        if v_zupdsal = 'Y' then
            v_fetch := true;
        end if;
    end loop;

    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxinc');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    if not v_fetch then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    for r1 in c1('1101') loop -- 1
      v_codrevn := r1.codcodec;
      for r2 in c2 loop
        v_rec1        := r2.numrec;
        v_income1     := hcm_util.get_split_decimal(r2.amtinc,'I');
        v_tax1        := hcm_util.get_split_decimal(r2.amttax,'I');
        v_income_deci1:= hcm_util.get_split_decimal(r2.amtinc,'D');
        v_tax_deci1   := hcm_util.get_split_decimal(r2.amttax,'D');

        v_recall         := v_recall + r2.numrec;
        v_incomeall      := v_incomeall + r2.amtinc;
        v_taxall         := v_taxall + r2.amttax;

        v_resultmod := mod(r2.numrec,10);
        v_resultdivide := floor(r2.numrec/10);

        if v_resultdivide = 0 AND v_resultmod <= 6 then
            v_current_page := 1;
        elsif v_resultmod <= 6 then
            v_current_page := v_resultdivide + 1;
        else
            v_current_page := v_resultdivide + 2;
        end if;
        v_all_page := nvl(v_all_page,0) + nvl(v_current_page,0);

      end loop;
    end loop;
    for r1 in c1('1201') loop -- 2
      v_codrevn := r1.codcodec;
      for r2 in c2 loop
        v_rec2        := r2.numrec;
        v_income2     := hcm_util.get_split_decimal(r2.amtinc,'I');
        v_tax2        := hcm_util.get_split_decimal(r2.amttax,'I');
        v_income_deci2:= hcm_util.get_split_decimal(r2.amtinc,'D');
        v_tax_deci2   := hcm_util.get_split_decimal(r2.amttax,'D');

        v_recall         := v_recall + r2.numrec;
        v_incomeall      := v_incomeall + r2.amtinc;
        v_taxall         := v_taxall + r2.amttax;

        v_resultmod := mod(r2.numrec,10);
        v_resultdivide := floor(r2.numrec/10);

        if v_resultdivide = 0 AND v_resultmod <= 6 then
            v_current_page := 1;
        elsif v_resultmod <= 6 then
            v_current_page := v_resultdivide + 1;
        else
            v_current_page := v_resultdivide + 2;
        end if;
        v_all_page := nvl(v_all_page,0) + nvl(v_current_page,0);
      end loop;
    end loop;
    for r1 in c1('1301') loop -- 3
      v_codrevn := r1.codcodec;
      for r2 in c2 loop
        v_rec3        := r2.numrec;
        v_income3     := hcm_util.get_split_decimal(r2.amtinc,'I');
        v_tax3        := hcm_util.get_split_decimal(r2.amttax,'I');
        v_income_deci3:= hcm_util.get_split_decimal(r2.amtinc,'D');
        v_tax_deci3   := hcm_util.get_split_decimal(r2.amttax,'D');

        v_recall         := v_recall + r2.numrec;
        v_incomeall      := v_incomeall + r2.amtinc;
        v_taxall         := v_taxall + r2.amttax;

        v_resultmod := mod(r2.numrec,10);
        v_resultdivide := floor(r2.numrec/10);

        if v_resultdivide = 0 AND v_resultmod <= 6 then
            v_current_page := 1;
        elsif v_resultmod <= 6 then
            v_current_page := v_resultdivide + 1;
        else
            v_current_page := v_resultdivide + 2;
        end if;
        v_all_page := nvl(v_all_page,0) + nvl(v_current_page,0);
      end loop;
    end loop;
    for r1 in c1('1401') loop -- 4
      v_codrevn := r1.codcodec;
      for r2 in c2 loop
        v_rec4        := r2.numrec;
        v_income4     := hcm_util.get_split_decimal(r2.amtinc,'I');
        v_tax4        := hcm_util.get_split_decimal(r2.amttax,'I');
        v_income_deci4:= hcm_util.get_split_decimal(r2.amtinc,'D');
        v_tax_deci4   := hcm_util.get_split_decimal(r2.amttax,'D');

        v_recall         := v_recall + r2.numrec;
        v_incomeall      := v_incomeall + r2.amtinc;
        v_taxall         := v_taxall + r2.amttax;

        v_resultmod := mod(r2.numrec,10);
        v_resultdivide := floor(r2.numrec/10);

        if v_resultdivide = 0 AND v_resultmod <= 6 then
            v_current_page := 1;
        elsif v_resultmod <= 6 then
            v_current_page := v_resultdivide + 1;
        else
            v_current_page := v_resultdivide + 2;
        end if;
        v_all_page := nvl(v_all_page,0) + nvl(v_current_page,0);
      end loop;
    end loop;
    for r1 in c1('1501') loop -- 5
      v_codrevn := r1.codcodec;
      for r2 in c2 loop
        v_rec5        := r2.numrec;
        v_income5     := hcm_util.get_split_decimal(r2.amtinc,'I');
        v_tax5        := hcm_util.get_split_decimal(r2.amttax,'I');
        v_income_deci5:= hcm_util.get_split_decimal(r2.amtinc,'D');
        v_tax_deci5   := hcm_util.get_split_decimal(r2.amttax,'D');

        v_recall         := v_recall + r2.numrec;
        v_incomeall      := v_incomeall + r2.amtinc;
        v_taxall         := v_taxall + r2.amttax;

        v_resultmod := mod(r2.numrec,10);
        v_resultdivide := floor(r2.numrec/10);

        if v_resultdivide = 0 AND v_resultmod <= 6 then
            v_current_page := 1;
        elsif v_resultmod <= 6 then
            v_current_page := v_resultdivide + 1;
        else
            v_current_page := v_resultdivide + 2;
        end if;
        v_all_page := nvl(v_all_page,0) + nvl(v_current_page,0);
      end loop;
    end loop;
    v_count_process := v_recall;
    v_income_deciall := hcm_util.get_split_decimal(v_incomeall,'D');
    v_tax_deciall    := hcm_util.get_split_decimal(v_taxall,'D');
--    v_page           := ceil(v_recall/p_record_per_page);
    v_page           := v_all_page;
    -- 3/3
    begin
      begin
        select typsign,codempid,codcomp,
               codpos ,signname,posname,
               namsign
          into v_typsign,v_codempid,v_codcomp,
               v_codpos ,v_signname,v_posname,
               v_namsign
          from tsetsign
         where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
           and coddoc = 'HRPY93R';
      exception when no_data_found then null;
      end;
      if v_typsign = '1' then
        begin
          select get_tlistval_name('CODTITLE',codtitle,global_v_lang)||
                 namfirstt|| ' ' ||namlastt,
                 get_tpostn_name(codpos,global_v_lang)
            into v_name,v_desc_codpos
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then null;
        end;
        --
        begin
          select namsign into v_namsign
            from tempimge
           where codempid = v_codempid;
        exception when no_data_found then null;
        end;
        --
        begin
        select folder into v_folder
          from tfolderd
         where codapp = 'HRPMC2E2';
        exception when no_data_found then null;
        end;
      elsif v_typsign = '2' then
        begin
          select codempid into v_codempid
            from temploy1
           where codpos = v_codpos
             and hcm_util.get_codcomp_level(codcomp, 1) = v_codcomp
             and staemp in ('1','3')
             and rownum = 1;
        exception when no_data_found then null;
        end;
        --
        v_desc_codpos := get_tpostn_name(v_codpos,global_v_lang);
        begin
          select get_tlistval_name('CODTITLE',codtitle,global_v_lang)||
                 namfirstt|| ' ' ||namlastt
            into v_name
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then null;
        end;
        --
        begin
          select namsign into v_namsign
            from tempimge
           where codempid = v_codempid;
        exception when no_data_found then null;
        end;
        --
        begin
          select folder into v_folder
            from tfolderd
           where codapp = 'HRPMC2E2';
        exception when no_data_found then null;
        end;
      elsif v_typsign = '3' then
        v_name := v_signname;
        v_desc_codpos := v_posname;
        begin
          select folder into v_folder
            from tfolderd
           where codapp = 'HRCO02E';
        exception when no_data_found then null;
        end;
      else
        v_name := '';
        v_desc_codpos := '';
        v_folder := '';
      end if;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSETSIGN');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;
    --<<check existing image
    if v_namsign is not null then
      v_namsign     := get_tsetup_value('PATHWORKPHP')||v_folder||'/'||v_namsign;
      v_has_image   := 'Y';
    end if;
    -->>
    delete ttemprpt
     where codempid = global_v_codempid
       and codapp   = p_codapp1;
    commit;
    begin
      insert into ttemprpt(codempid    ,codapp      ,numseq      ,
                           item1       ,item2       ,item3       ,item4       ,item5       ,
                           item6       ,item7       ,item8       ,item9       ,item10      ,
                           item11      ,item12      ,item13      ,item14      ,item15      ,
                           item16      ,item17      ,item18      ,item19      ,item20      ,
                           item21      ,item22      ,item23      ,item24      ,item25      ,
                           item26      ,item27      ,item28      ,item29      ,item30      ,
                           item31      ,item32      ,item33      ,item34      ,item35      ,
                           item36      ,item37      ,item38      ,item39      ,item40      ,
                           item41      ,item42      ,item43      ,
                           item44      ,item45      ,
                           item46      ,item47      ,
                           item48      ,item49      ,item50      ,
                           item51      ,item52      )
                    values(global_v_codempid,p_codapp1,1,
                           v_numcotax     ,v_namcomt        ,v_buildingt      ,v_roomnot        ,v_floort         ,
                           v_villaget       ,v_addrnot        ,v_moot           ,v_soit           ,v_roadt          ,
                           v_desc_codsubdist,v_desc_coddist   ,v_desc_codprovr  ,v_zipcode        ,v_numtele        ,
                           p_year + 543         ,v_page           ,v_rec1           ,v_income1        ,v_income_deci1   ,
                           v_tax1           ,v_tax_deci1      ,v_rec2           ,v_income2        ,v_income_deci2   ,
                           v_tax2           ,v_tax_deci2      ,v_rec3           ,v_income3        ,v_income_deci3   ,
                           v_tax3           ,v_tax_deci3      ,v_rec4           ,v_income4        ,v_income_deci4   ,
                           v_tax4           ,v_tax_deci4      ,v_rec5           ,v_income5        ,v_income_deci5   ,
                           v_tax5           ,v_tax_deci5      ,v_recall ,
                           hcm_util.get_split_decimal(v_incomeall,'I'),v_income_deciall ,
                           hcm_util.get_split_decimal(v_taxall,'I')   ,v_tax_deciall ,
                           v_name           ,v_desc_codpos    ,v_namsign        ,
                           v_folder         ,v_has_image      );
    end;
    obj_json := json_object_t();
    obj_json.put('coderror','200');
    obj_json.put('coduser',global_v_coduser);
    obj_json.put('process',to_char(v_count_process));
    obj_json.put('codapp',p_codapp1);
    obj_json.put('response',
    hcm_secur.get_response('200',get_error_msg_php('HR2710',global_v_lang),global_v_lang));
    json_str_output := obj_json.to_clob;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail1;

  procedure check_detail2 as
      v_secur boolean := false;
  begin
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_codrevn is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codrevn');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
      v_secur :=  secur_main.secur7(p_codcomp,global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_codrevn is not null then
      begin
        select codcodec
          into p_codrevn
          from tcodrevn
         where codcodec = p_codrevn;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodrevn');
      end;
    end if;
  end check_detail2;

  procedure get_detail2(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail2;
    if param_msg_error is null then
        gen_detail2(json_str_output);
        if param_msg_error is not null then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          rollback;
        end if;
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail2;

  procedure gen_numseq (v_codempid varchar2,v_numseq number) as
    v_record number := 0;
  begin
    select count(codempid)
      into v_record
      from ttaxrep
     where codempid = v_codempid
       and dteyear  = p_year
       and codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
    if v_record = 0 then
      insert into ttaxrep(codempid,dteyear,codcompy,
                          numseq,typform,dteupd,coduser)
                   values(v_codempid,p_year,hcm_util.get_codcomp_level(p_codcomp,1),
                          v_numseq,2,trunc(sysdate),global_v_coduser);
    else
      update ttaxrep
         set numseq = v_numseq,
             typform = 2,
             dteupd = trunc(sysdate),
             coduser = global_v_coduser
       where codempid = v_codempid
         and dteyear = p_year
         and codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
    end if;
  end;

  procedure gen_detail2(json_str_output out clob) as
--    v_count_process     number := 0;

    v_numcotax        tcompny.numcotax%type;

    v_typsign           tsetsign.typsign%type;
    v_codempid          tsetsign.codempid%type;
    v_codcomp           tsetsign.codcomp%type;
    v_codpos            tsetsign.codpos%type;
    v_signname          tsetsign.signname%type;
    v_posname           tsetsign.posname%type;
    v_namsign           tsetsign.namsign%type;

    v_name              varchar2(4000 char);
    v_desc_codpos       varchar2(4000 char);
    v_folder            tfolderd.folder%type;

    v_amtinc       varchar2(100 char);
    v_amttax       varchar2(4000 char);

    v_count       number := 0;
    obj_data      json_object_t;
    obj_rows      json_object_t := json_object_t();
    obj_detail    json_object_t := json_object_t();
    obj_json      json_object_t := json_object_t();
    cursor c1 is
      select codempid,
             sum(nvl(stddec(amtinc,codempid,global_v_chken),0)) amtinc,
             sum(nvl(stddec(amttax,codempid,global_v_chken),0)) amttax
        from ttaxinc
       where codcomp   like p_codcomp || '%'
         and dteyrepay = p_year
         and typinc    = nvl(p_codrevn,typinc)
       --  and to_number(stddec(amtinc,codempid,global_v_chken)) > 0
--         and numlvl between global_v_numlvlsalst and global_v_numlvlsalen
--         and exists(select tusrcom.codcomp
--                      from tusrcom
--                     where tusrcom.coduser = global_v_coduser
--                       and ttaxinc.codcomp  like tusrcom.codcomp || '%')
    group by codempid
    order by codempid;
    v_flg_exist boolean := false;
    v_numrec    number;

    v_numoffid   temploy2.numoffid%type;
    v_numtaxid   temploy3.numtaxid%type;
    v_flgtax     temploy3.flgtax%type;
    v_codtitle   temploy1.codtitle%type;
    v_namfirstt  temploy1.namfirstt%type;
    v_namlastt   temploy1.namlastt%type;
    v_adrregt    temploy2.adrregt%type;
    v_codsubdistr temploy2.codsubdistr%type;
    v_coddistr   temploy2.coddistr%type;
    v_codprovr   temploy2.codprovr%type;
    v_codpostr   temploy2.codpostr%type;
    v_title_prefix varchar2(500 char);
    v_t2_address   varchar2(4000 char);
    v_amtinc_all number := 0;
    v_amttax_all number := 0;
    v_text_numoffid   varchar2(4000 char);
    v_text_numtaxid   varchar2(4000 char);
    v_flgsecu         boolean;
    v_fetch           boolean;
    v_has_image       varchar2(1) := 'N';
    v_codrevn         number;
  begin
    begin
      select (count(distinct codempid))
        into v_numrec
        from ttaxinc
       where codcomp   like p_codcomp || '%'
         and dteyrepay = p_year
         and typinc    = nvl(p_codrevn,typinc)
         --and to_number(stddec(amtinc,codempid,global_v_chken)) > 0
         and numlvl between global_v_numlvlsalst and global_v_numlvlsalen
         and exists(select tusrcom.codcomp
                      from tusrcom
                     where tusrcom.coduser = global_v_coduser
                       and ttaxinc.codcomp  like tusrcom.codcomp || '%')
;
    exception when no_data_found then
      v_numrec := 0;
    end;
    v_numrec := ceil(v_numrec/p_record_per_page);
    begin
      select numcotax into v_numcotax
        from tcompny
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
    exception when no_data_found then null;
    end;
    --
    begin
      select typsign,codempid,codcomp,
             codpos ,signname,posname,
             namsign
        into v_typsign,v_codempid,v_codcomp,
             v_codpos ,v_signname,v_posname,
             v_namsign
        from tsetsign
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and coddoc = 'HRPY93R';
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSETSIGN');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;

    if v_typsign = '1' then
      begin
        select get_tlistval_name('CODTITLE',codtitle,global_v_lang)||
               namfirstt|| ' ' ||namlastt,
               get_tpostn_name(codpos,global_v_lang)
          into v_name,v_desc_codpos
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then null;
      end;
      --
      begin
        select namsign into v_namsign
          from tempimge
         where codempid = v_codempid;
      exception when no_data_found then null;
      end;
      --
      begin
        select folder  into v_folder
          from tfolderd
         where codapp = 'HRPMC2E2';
      exception when no_data_found then null;
      end;
    elsif v_typsign = '2' then
      begin
        select codempid into v_codempid
          from temploy1
         where codpos = v_codpos
           and hcm_util.get_codcomp_level(codcomp, 1) = v_codcomp
           and staemp in ('1','3')
           and rownum =1
      order by codempid;
      exception when no_data_found then null;
      end;
      --
      v_desc_codpos := get_tpostn_name(v_codpos,global_v_lang);
      begin
        select get_tlistval_name('CODTITLE',codtitle,global_v_lang)||
               namfirstt|| ' ' ||namlastt
          into v_name
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then null;
      end;
      --
      begin
        select namsign into v_namsign
          from tempimge
         where codempid = v_codempid;
      exception when no_data_found then v_namsign := null;
      end;
      --
      begin
        select folder into v_folder
          from tfolderd
         where codapp = 'HRPMC2E2';
      exception when no_data_found then null;
      end;
    elsif v_typsign = '3' then
      v_name := v_signname;
      v_desc_codpos := get_tpostn_name(v_codpos,global_v_lang);
      begin
        select folder into v_folder
          from tfolderd
         where codapp = 'HRCO02E';
      exception when no_data_found then null;
      end;
    end if;
    --
    delete ttemprpt
     where codempid = global_v_codempid
       and codapp   = p_codapp2;
   delete ttemprpt
     where codempid = global_v_codempid
       and codapp   = p_codapp3;

    v_fetch := false;
    --<<check existing image
    if v_namsign is not null then
      v_namsign     := get_tsetup_value('PATHWORKPHP')||v_folder||'/'||v_namsign;
      v_has_image   := 'Y';
    end if;
    -->>

    for r1 in c1 loop -- ttaxinc
      v_flg_exist := true;
      -- v_flgsecu := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      v_flgsecu := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);

      -- v_flgsecu := true;
      if v_zupdsal = 'Y' then

          v_fetch := true;
          obj_data := json_object_t();
          -- temploy1 temploy2 temploy3
          begin
            select t2.numoffid ,t3.numtaxid,t3.flgtax , t1.codtitle,
                   decode(global_v_lang,'101',t1.namfirste
                                       ,'102',t1.namfirstt
                                       ,'103',t1.namfirst3
                                       ,'104',t1.namfirst4
                                       ,'105',t1.namfirst5
                                       ,t1.namfirste),
                   decode(global_v_lang,'101',t1.namlaste
                                       ,'102',t1.namlastt
                                       ,'103',t1.namlast3
                                       ,'104',t1.namlast4
                                       ,'105',t1.namlast5
                                       ,t1.namlaste),
                   decode(global_v_lang,'101',t2.adrrege,
                                        '102',t2.adrregt,
                                        '103',t2.adrreg3,
                                        '104',t2.adrreg4,
                                        '105',t2.adrreg5,
                                        t2.adrrege),
                   t2.codsubdistr,t2.coddistr,t2.codprovr,t2.codpostr
              into v_numoffid  ,v_numtaxid ,v_flgtax , v_codtitle,
                   v_namfirstt ,v_namlastt ,v_adrregt,
                   v_codsubdistr,v_coddistr,v_codprovr,v_codpostr
              from temploy1 t1,temploy2 t2,temploy3 t3
             where t1.codempid = t2.codempid
               and t1.codempid = t3.codempid
               and t1.codempid = r1.codempid;
          exception when no_data_found then
            v_numoffid  := '';
            v_numtaxid  := '';
            v_flgtax    := '';
            v_namfirstt := '';
            v_namlastt  := '';
            v_adrregt   := '';
          end;

          v_amtinc := TRIM(to_char(r1.amtinc,'999,999,999,999.99'));
          v_amttax := TRIM(to_char(r1.amttax,'999,999,999,999.99'));

          obj_data.put('numseq',to_char(v_count + 1));
          obj_data.put('image',get_emp_img(r1.codempid));
          obj_data.put('codempid',r1.codempid);
          obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('numoffid',v_numoffid);
          obj_data.put('numtaxid',v_numtaxid);
          obj_data.put('amtinc',to_char(r1.amtinc,'fm999,999,999,990.00'));
--          obj_data.put('amtinc',v_amtinc);
          obj_data.put('amttax',to_char(r1.amttax,'fm999,999,999,990.00'));
--          obj_data.put('amttax',v_amttax);
          obj_data.put('flgtax',v_flgtax);
          obj_data.put('flgskip', '');
    --      obj_data.put('coderror','200');
          obj_rows.put(to_char(v_count),obj_data);

          v_amtinc_all := v_amtinc_all + r1.amtinc;
          v_amttax_all := v_amttax_all + r1.amttax;
          --
          v_title_prefix  := get_tlistval_name('CODTITLE',v_codtitle,global_v_lang);
          v_t2_address    := v_adrregt ||' '||
                             get_tsubdist_name(v_codsubdistr,global_v_lang) ||' '||
                             get_tcoddist_name(v_coddistr,global_v_lang)    ||' '||
                             get_tcodec_name('tcodprov',v_codprovr,global_v_lang) ||' '|| v_codpostr;
--          v_text_numtaxid := split_number_id(v_numcotax);
--          v_text_numoffid := split_number_id(v_numtaxid);
      v_text_numtaxid := v_numcotax;
      v_text_numoffid := rpad(v_numoffid,13,'-');

    if p_codrevn = '1101' then
        v_codrevn := 1;
    elsif p_codrevn = '1201' then
        v_codrevn := 2;
    elsif p_codrevn = '1301' then
        v_codrevn := 3;
    elsif p_codrevn = '1401' then
        v_codrevn := 4;
    elsif p_codrevn = '1501' then
        v_codrevn := 5;
    end if;

          insert into ttemprpt(codempid,codapp,numseq,
                               item1   ,item2 ,item3 ,
                               item4   ,item5 ,item6 ,
                               item7   ,item8 ,
                               item9   ,
                               item10,item11,
                               item12  ,item13,
                               item14  ,item15,
                               item16  ,item17, item18, item19)
                        values(global_v_codempid,p_codapp3,v_count + 1,
                               v_text_numtaxid,v_name,v_desc_codpos ,
                               to_char(1 + floor(((v_count + 1)/p_record_per_page))) ,v_numrec ,to_char(mod(v_count,p_record_per_page)+1),
                               to_char(v_count + 1),v_text_numoffid,
                               v_title_prefix || v_namfirstt, v_namlastt, v_t2_address  ,
                               hcm_util.get_split_decimal(v_amtinc,'I'),hcm_util.get_split_decimal(v_amtinc,'D'),
                               hcm_util.get_split_decimal(r1.amttax,'I'),hcm_util.get_split_decimal(r1.amttax,'D'),
                               v_flgtax, v_folder, v_namsign, v_codrevn);
          v_count := v_count + 1;

          gen_numseq(r1.codempid,v_count);
      end if;

    end loop;

    obj_data := json_object_t();
    obj_data.put('numtaxid',get_label_name('HRPY93R2',global_v_lang,130)); -- tapplscr
    obj_data.put('amtinc',to_char(v_amtinc_all,'fm999,999,999,990.00'));
    obj_data.put('amttax',to_char(v_amttax_all,'fm999,999,999,990.00'));
    obj_data.put('flgskip', 'Y');
--    obj_data.put('coderror','200');
    obj_rows.put(to_char(v_count),obj_data);

    obj_json.put('table',obj_rows);
--    obj_detail.put('process',);
    obj_json.put('process',to_char(v_count));
    obj_json.put('coderror','200');
    --<<Insert header, footer



    insert into ttemprpt(codempid,codapp,numseq,
                         item1   ,item2, item3 ,
                         item17, item18, item19,
                         item20  ,item21,
                         item22  ,item23,
                         item24)
                  values(global_v_codempid     ,p_codapp2     ,1             ,
                         v_text_numtaxid       ,v_name        ,v_desc_codpos ,
                         v_folder              ,v_namsign     ,v_codrevn,
                         hcm_util.get_split_decimal(v_amtinc_all,'I'),hcm_util.get_split_decimal(v_amtinc_all,'D'),
                         hcm_util.get_split_decimal(v_amttax_all,'I'),hcm_util.get_split_decimal(v_amttax_all,'D'),
                         v_has_image);
    -->>
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxinc');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    if not v_fetch then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_json.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail2;

  procedure check_detail3 as
      v_secur boolean := false;
  begin
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_codrevn is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codrevn');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
      v_secur :=  secur_main.secur7(p_codcomp,global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_codrevn is not null then
      begin
        select codcodec
          into p_codrevn
          from tcodrevn
         where codcodec = p_codrevn;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodrevn');
      end;
    end if;
  end check_detail3;

  procedure get_detail3(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail3;
    if param_msg_error is null then
        gen_detail3(json_str_output);
        if param_msg_error is not null then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          rollback;
        end if;
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail3;

  procedure gen_detail3(json_str_output out clob) as
    obj_json            json_object_t := json_object_t();
    v_count             number := 0;
    v_numcotax    varchar2(4000 char) := '';
    v_numoffid    varchar2(4000 char) := '';
    v_numtaxid    varchar2(4000 char) := '';
    v_codtitle    varchar2(4000 char) := '';
    v_namfirstt   varchar2(4000 char) := '';
    v_namlastt    varchar2(4000 char) := '';
    v_adrregt     varchar2(4000 char) := '';
    v_adrcontt    varchar2(4000 char) := '';
    v_codpostr    varchar2(4000 char) := '';
    v_seqinc      varchar2(4000 char) := '';
    v_dtepay      date;
    v_flgtax      varchar2(4000 char) := '';
    v_typpayroll  varchar2(4000 char) := '';
    --<< user25 Date 15/020/2022
    v_codsubdistr temploy2.codsubdistr%type;
    v_coddistr    temploy2.coddistr%type;
    v_codprovr    temploy2.codprovr%type;
    -->> user25 Date 15/020/2022
--    v_data        varchar2(6000 char):= '';
    v_data        clob:= '';
    cursor c1 is
      select codempid,
             sum(nvl(stddec(amtinc,codempid,global_v_chken),0)) amtinc,
             sum(nvl(stddec(amttax,codempid,global_v_chken),0)) amttax
        from ttaxinc
       where codcomp   like p_codcomp || '%'
         and dteyrepay = p_year
         and typinc    = p_codrevn
        -- and to_number(stddec(amtinc,codempid,global_v_chken)) > 0
         and numlvl between global_v_numlvlsalst and global_v_numlvlsalen
         and exists(select tusrcom.codcomp
                      from tusrcom
                     where tusrcom.coduser = global_v_coduser
                       and ttaxinc.codcomp  like tusrcom.codcomp || '%')
    group by codempid
    order by codempid;
    cursor c_tcodrevn is
      select codcodec,rownum
        from tcodrevn
    order by codcodec;
    cursor c_tdtepay is
      select dtepaymt
        from tdtepay
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and typpayroll = v_typpayroll
         and dteyrepay = p_year
      order by dtemthpay desc,numperiod desc;
    data_file       varchar2(2000);
    v_filename      varchar2(4000 char);
    in_file         utl_file.File_Type;
    out_file        utl_file.File_Type;
  begin
    -- text1.txt file write /read
    v_filename := lower('HRPY93R'||'_'||global_v_coduser)||'.txt';
    std_deltemp.upd_ttempfile(lower('HRPY93R'||'_'||global_v_coduser)||'.txt','A'); --'A' = Insert , update ,'D'  = delete
    out_file := utl_file.Fopen(p_file_dir,v_filename,'W');
    for r_tcodrevn in c_tcodrevn loop
      if r_tcodrevn.codcodec = p_codrevn then
        v_seqinc := to_char(r_tcodrevn.rownum);
        exit;
      end if;
    end loop;
    begin
      select numcotax
        into v_numcotax
        from tcompny
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
    exception when no_data_found then
      v_numcotax   := null;
    end;
    for r1 in c1 loop
      begin
        select t2.numoffid ,t3.numtaxid,t1.codtitle,
               t1.namfirstt,t1.namlastt,t2.adrregt ,
               t2.adrcontt ,t2.codpostr,t3.flgtax  ,
               t1.typpayroll,
               t2.codsubdistr,t2.coddistr,t2.codprovr --<< user25 Date 15/020/2022
          into v_numoffid ,v_numtaxid,v_codtitle,
               v_namfirstt,v_namlastt,v_adrregt ,
               v_adrcontt ,v_codpostr,v_flgtax  ,
               v_typpayroll,
               v_codsubdistr,v_coddistr,v_codprovr --<< user25 Date 15/020/2022
          from temploy1 t1,temploy2 t2,temploy3 t3
         where t1.codempid = t2.codempid
           and t1.codempid = t3.codempid
           and t1.codempid = r1.codempid;
      exception when no_data_found then
        v_numoffid  := null;
        v_numtaxid  := null;
        v_codtitle  := null;
        v_namfirstt := null;
        v_namlastt  := null;
        v_adrregt   := null;
        v_adrcontt  := null;
        v_codpostr  := null;
        v_flgtax    := null;
        v_typpayroll:= null;
        v_codsubdistr := null;
        v_coddistr := null;
        v_codprovr := null;
      end;
      v_dtepay := null;
      for r_tdtepay in c_tdtepay loop
        v_dtepay := r_tdtepay.dtepaymt;
        exit;
      end loop;
--      v_data := '0000' || '|' ||
--                substr(nvl(v_numcotax,rpad('0',13,'0')),1,13) || '|' ||
--                substr(nvl(v_numcotax,rpad('0',13,'0')),1,10) || '|' ||
--                '0000' || '|' ||
--                substr(nvl(v_numoffid,rpad('0',13,'0')),1,13) || '|' ||
--                substr(nvl(v_numtaxid,rpad('0',10,'0')),1,10) || '|' ||
--                substr(get_tlistval_name('CODTITLE',v_codtitle,global_v_lang),1,40) || '|' ||
--                substr(v_namfirstt,1,80) || '|' ||
--                substr(v_namlastt ,1,80) || '|' ||
--                substr(v_adrregt  ,1,80) || '|' ||
--                substr(v_adrcontt ,1,80) || '|' ||
--                substr(to_char(v_codpostr),1,5) || '1' ||
--                '00' || '|' ||
--                to_char(p_year + 543) || '|' ||
--                to_char(v_seqinc) || '|' ||
--                to_char(v_dtepay,'ddmm') || to_char(to_number((to_char(v_dtepay,'yyyy'))) + 543) || '|' ||
--                ltrim(to_char(nvl(r1.amtinc,0),'9999999999990.00')) || '|' ||
--                ltrim(to_char(nvl(r1.amttax,0),'9999999999990.00')) || '|' ||
--                v_flgtax;

      v_data := '00' || '|' ||
                substr(nvl(v_numcotax,rpad('0',13,'0')),1,13) || '|' ||
                substr(nvl(v_numcotax,rpad('0',13,'0')),1,10) || '|' ||
                '0000' || '|' ||
                substr(nvl(v_numoffid,rpad('0',13,'0')),1,13) || '|' ||
                substr(nvl(v_numtaxid,rpad('0',10,'0')),1,10) || '|' ||
                substr(get_tlistval_name('CODTITLE',v_codtitle,global_v_lang),1,40) || '|' ||
                substr(v_namfirstt,1,80) || '|' ||
                substr(v_namlastt ,1,80) || '|' ||
                substr(v_adrregt  ,1,80) || '|' ||
                --<< user25 Date:15/02/2022
                --substr(v_adrcontt ,1,80) || '|' ||
                substr(get_tsubdist_name(v_codsubdistr,global_v_lang) ,1,80) || '|' ||
                substr(get_tcoddist_name(v_coddistr,global_v_lang) ,1,80) || '|' ||
                substr(get_tcodec_name('tcodprov',v_codprovr,global_v_lang) ,1,80) || '|' ||
                -->> user25 Date:15/02/2022
                substr(to_char(v_codpostr),1,5) || '|' ||
                '00' || '|' ||
                to_char(p_year + 543) || '|' ||
                to_char(v_seqinc) || '|' ||
                to_char(v_dtepay,'ddmm') || to_char(to_number((to_char(v_dtepay,'yyyy'))) + 543) || '|' ||
                '0'||'|'||
                ltrim(to_char(nvl(r1.amtinc,0),'9999999999990.00')) || '|' ||
                ltrim(to_char(nvl(r1.amttax,0),'9999999999990.00')) || '|' ||
                v_flgtax;

      utl_file.Put_line(out_file, v_data);

      v_count := v_count + 1;
    end loop;
    utl_file.fclose(out_file);

    sync_log_file(v_filename);
    obj_json.put('process',to_char(v_count));
    if v_count > 0 then
      obj_json.put('path',p_file_path || v_filename);
    end if;
    obj_json.put('coderror','200');
    obj_json.put('response',get_errorm_name('HR2715',global_v_lang));
    json_str_output := obj_json.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail3;
end hrpy93r;

/

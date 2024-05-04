--------------------------------------------------------
--  DDL for Package Body HRPY92R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY92R" as
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

  procedure cleartemptable as
  begin
--    delete ttempprm
--     where codapp like 'HRPY92R%'
--       and codempid = global_v_codempid;
    delete ttemprpt
     where codapp like 'HRPY92R%'
       and codempid = global_v_codempid;
    commit;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return;
  end;

  function get_tsetsign_name (v_codcompy varchar2, v_codapp varchar2) return varchar2 is
    v_typsign  tsetsign.typsign%type;
    v_codempid tsetsign.codempid%type;
    v_codcomp  tsetsign.codcomp%type;
    v_codpos   tsetsign.codpos%type;
    v_signname tsetsign.signname%type;
    v_posname  tsetsign.posname%type;
    v_namsign  tsetsign.namsign%type;

    v_image_name varchar2(4000 char);
    v_path       varchar2(4000 char);
    v_image_path varchar2(4000 char);
  begin
    begin
      select typsign  ,codempid  ,codcomp  ,
             codpos   ,signname  ,posname  ,
             namsign
        into v_typsign,v_codempid,v_codcomp,
             v_codpos ,v_signname,v_posname,
             v_namsign
        from tsetsign
       where codcompy = v_codcompy
         and coddoc   = v_codapp;
    exception when no_data_found then
      return null;
    end;

    if v_typsign in ('1','2') then
      if v_typsign = '1' then
        begin
          select codpos
            into v_codpos
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then
          return null;
        end;

      elsif v_typsign = '2' then
        begin
          select codempid
            into v_codempid
            from temploy1
           where codcomp like v_codcomp || '%'
             and codpos  = v_codpos
             and staemp  in ('1','3')
             and rownum  = 1
        order by codempid;
        exception when no_data_found then
          return null;
        end;
      end if;
      p_desc_codempid := get_temploy_name(v_codempid,global_v_lang);
      p_desc_position := get_tpostn_name(v_codpos,global_v_lang);
      begin
        select namsign
          into v_image_name
          from tempimge
         where codempid = v_codempid;
      exception when no_data_found then
        return null;
      end;
      begin
        select folder
          into v_path
          from tfolderd
         where codapp = 'HRPMC2E2';
      exception when no_data_found then
        return null;
      end;

    elsif v_typsign = '3' then
      p_desc_codempid := v_signname;
      p_desc_position := v_posname;
      v_image_name    := v_namsign;
      begin
        select folder
          into v_path
          from tfolderd
         where codapp = 'HRCO02E';
      exception when no_data_found then
        return null;
      end;
    else
      return null;
    end if;

    if v_image_name is not null then
      v_image_path := get_tsetup_value('PATHWORKPHP')||v_path || '/' || v_image_name;
    end if;
    return v_image_path;
  exception when no_data_found then
    return null;
  end;

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_month             := to_number(hcm_util.get_string_t(obj_detail,'month'));
    p_year              := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    p_typpayroll        := hcm_util.get_string_t(obj_detail,'typpayroll');
    p_typeData          := hcm_util.get_string_t(obj_detail,'typeData');
    p_codrevn           := hcm_util.get_string_t(obj_detail,'codrevn');
    p_dtepay            := to_date(hcm_util.get_string_t(obj_detail,'dtepay'),'dd/mm/yyyy');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_detail as
  begin
--    if p_month is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
--      return;
--    end if;
--    if p_year is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
--      return;
--    end if;
--    if p_codcomp is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
--      return;
--    end if;
--    if p_typeData is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typeData');
--      return;
--    end if;
--    if p_codrevn is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codrevn');
--      return;
--    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
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
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end check_detail;

  procedure get_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob) as
    -- header
    v_numcotax      tcompny.numcotax%type;
    v_codrevn         number := 0;
    v_h_desc_codempid varchar2(4000 char);
    v_h_desc_position varchar2(4000 char);
    v_img_path        varchar2(4000 char);
    v_all_page        number := 0;
    v_now_page        number;

    -- body
    obj_data          json_object_t;
    obj_rows          json_object_t := json_object_t();
    v_count           number := 0;
    v_count2          number := 0;
    v_sum_amtinc      number := 0;
    v_sum_amttax      number := 0;

    -- data
    v_codtitle        temploy1.codtitle%type;
    v_typpayyroll     ttaxinc.typpayroll%type;

    v_desc_codempid   varchar2(4000 char);
    v_title_prefix    varchar2(4000 char);
    v_desc_name       varchar2(4000 char);
    v_desc_surname    varchar2(4000 char);
    v_numoffid        temploy2.numoffid%type;
    v_numtaxid        temploy3.numtaxid%type;
    v_text_numoffid   varchar2(4000 char);
    v_text_numtaxid   varchar2(4000 char);
    v_dtepay          date;
    v_flgtax          temploy3.flgtax%type;
    v_has_image       varchar2(1) := 'N';
    v_flg_data        varchar2(10) := 'N';
    v_flg_secure      varchar2(10) := 'N';
    v_chk_secur       varchar2(10) := 'N';
    cursor c_tcodrevn is
      select codcodec
        from tcodrevn
    order by codcodec;
    cursor c1 is
      select codempid,
             nvl(sum(to_number(stddec(amtinc,codempid,global_v_chken))),0) amtinc,
             nvl(sum(to_number(stddec(amttax,codempid,global_v_chken))),0) amttax
        from ttaxinc
        where codcomp like p_codcomp || '%'
         and dteyrepay  = p_year
         and dtemthpay  = p_month
         and typinc     = nvl(p_codrevn,typinc)
         and typpayroll = nvl(p_typpayroll,typpayroll)
         and (
               ( v_chk_secur = 'N')
               or
               ( v_chk_secur = 'Y'
                 and numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                 and exists(select codcomp
                              from tusrcom
                             where coduser = global_v_coduser
                               and ttaxinc.codcomp like codcomp || '%') )
              )
      having ((p_typeData = '1'
             and nvl(sum(to_number(stddec(amtinc,codempid,global_v_chken))),0) <> 0
              or nvl(sum(to_number(stddec(amttax,codempid,global_v_chken))),0) <> 0))
          or ((p_typeData = '2') and nvl(sum(to_number(stddec(amttax,codempid,global_v_chken))),0) <> 0)
    group by codempid
    order by codempid;
  begin
    -- header
    begin
      select numcotax
        into v_numcotax
        from tcompny
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;
    -- Check Exists Data --
    for r1 in c1 loop
      v_flg_data  := 'Y';
      exit;
    end loop;
    v_chk_secur   := 'Y';
--    for r_tcodrevn in c_tcodrevn loop
--      v_codrevn := v_codrevn + 1;
--      if p_codrevn = r_tcodrevn.codcodec then
--        exit;
--      end if;
--    end loop;
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

    for r1 in c1 loop
      v_all_page := v_all_page + 1;
      v_sum_amtinc := v_sum_amtinc + r1.amtinc;
      v_sum_amttax := v_sum_amttax + r1.amttax;
    end loop;
    v_all_page := ceil(v_all_page/10);
    v_img_path := get_tsetsign_name(hcm_util.get_codcomp_level(p_codcomp,1),'HRPY92R');
    if v_img_path is not null then
      v_has_image := 'Y';
    end if;
    v_h_desc_codempid := p_desc_codempid;
    v_h_desc_position := p_desc_position;

    -- clear old temp
    cleartemptable;
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;


    -- body
    v_now_page := 1;
    for r1 in c1 loop
      v_flg_secure  := 'Y';
      v_count       := v_count  + 1; -- json
      v_count2      := v_count2 + 1; -- row in page
      if v_count2 = 9 then
        v_count2 := 1;
        v_now_page := v_now_page + 1; -- page
      end if;
      -- more detail
      v_desc_codempid := get_temploy_name(r1.codempid,global_v_lang);
      begin
        select codtitle,
               decode(global_v_lang,'101',namfirste
                                   ,'102',namfirstt
                                   ,'103',namfirst3
                                   ,'104',namfirst4
                                   ,'105',namfirst5
                                   ,namfirste),
               decode(global_v_lang,'101',namlaste
                                   ,'102',namlastt
                                   ,'103',namlast3
                                   ,'104',namlast4
                                   ,'105',namlast5
                                   ,namlaste)
          into v_codtitle,v_desc_name,v_desc_surname
          from temploy1
         where codempid = r1.codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      v_title_prefix  := get_tlistval_name('CODTITLE',v_codtitle,global_v_lang);
      begin
        select numoffid
          into v_numoffid
          from temploy2
         where codempid = r1.codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy2');
        return;
      end;
      begin
        select numtaxid,flgtax
          into v_numtaxid,v_flgtax
          from temploy3
         where codempid = r1.codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy3');
        return;
      end;
      if p_dtepay is not null then
        v_dtepay := p_dtepay;
      else
        begin
          select typpayroll
            into v_typpayyroll
            from ttaxinc
           where codcomp like p_codcomp || '%'
             and codempid = r1.codempid
             and dteyrepay = p_year
             and dtemthpay = p_month
             and numperiod = (select max(numperiod)
                                from ttaxinc
                               where codcomp like p_codcomp || '%'
                                 and codempid = r1.codempid
                                 and dteyrepay = p_year
                                 and dtemthpay = p_month
                                 and typinc    = p_codrevn)
             and typinc = p_codrevn;
        exception when no_data_found then
          v_typpayyroll := null;
        end;
        begin
          select dtepaymt
            into v_dtepay
            from tdtepay
           where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
             and typpayroll = v_typpayyroll
             and dteyrepay = p_year
             and dtemthpay = p_month
             and numperiod = (select max(numperiod)
                                from tdtepay
                               where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                                 and typpayroll = v_typpayyroll
                                 and dteyrepay  = p_year
                                 and dtemthpay  = p_month);
        exception when no_data_found then
          v_dtepay := null;
        end;
      end if;
      -- * header - v_numcotax     ,v_now_page       ,v_all_page       , -- header
      -- *          v_codrevn        ,v_sum_amtinc     ,v_sum_amttax     , -- header
      -- *          v_img_path       ,v_h_desc_codempid,v_h_desc_position  -- header
      -- * body   - v_count         ,v_count2          ,v_codempid        ,
      -- *          v_desc_codempid ,v_desc_name       ,v_desc_surname    ,
      -- *          v_title_prefix  ,v_numoffid        ,v_numtaxid        ,
      -- *          v_dtepay        ,r1.amtinc         ,r1.amttax         ,
      -- *          v_flgtax
--      v_text_numtaxid := split_number_id(v_numcotax);
--      v_text_numoffid := split_number_id(v_numoffid);
      v_text_numtaxid := v_numcotax;
      v_text_numoffid := rpad(v_numoffid,13,'-');

      -- add to temp table
      insert into ttemprpt(codempid         ,codapp           ,numseq           , -- pk
                           item1            ,item2            ,item3            , -- header
                           item4            ,item5            ,item6            , -- header
                           item7            ,item8            ,item9            , -- header
                           item31           ,item32           ,item33           ,
                           item34           ,item35           ,item36           ,
                           item37           ,item38           ,
                           item39           ,item40 )
                    values(global_v_codempid,'HRPY92R3'       ,v_count          , -- pk
                           v_text_numtaxid  ,v_now_page       ,v_all_page       , -- header
--                           v_codrevn        ,v_sum_amtinc     ,v_sum_amttax     , -- header
                           v_codrevn        ,hcm_util.get_split_decimal(v_sum_amtinc,'I'),hcm_util.get_split_decimal(v_sum_amttax,'I')     , -- header
                           v_img_path       ,v_h_desc_codempid,v_h_desc_position, -- header
                           v_count          ,v_title_prefix || v_desc_name, v_desc_surname ,
                           v_text_numoffid  ,hcm_util.get_date_buddhist_era (v_dtepay)     ,hcm_util.get_split_decimal(r1.amtinc,'I'),
                           hcm_util.get_split_decimal(r1.amttax,'I')  ,v_flgtax,
                           hcm_util.get_split_decimal(r1.amtinc,'D')  ,hcm_util.get_split_decimal(r1.amttax,'D'));
      -- json_str_output
      obj_data := json_object_t();
      obj_data.put('index'        ,to_char(v_count));
      obj_data.put('image'        ,get_emp_img(r1.codempid));
      obj_data.put('codempid'     ,r1.codempid);
      obj_data.put('desc_codempid',v_desc_codempid);
      obj_data.put('numoffid'     ,v_numoffid);
      obj_data.put('numtaxid'     ,v_numtaxid);
      obj_data.put('dtepay'       ,to_char(v_dtepay,'dd/mm/yyyy'));
      obj_data.put('amtinc'       ,to_char(r1.amtinc,'fm9999999999990.00'));
      obj_data.put('amttax'       ,to_char(r1.amttax,'fm9999999999990.00'));
      obj_data.put('flgtax'       ,v_flgtax);
      obj_data.put('coderror'     ,'200');
      obj_rows.put(to_char(v_count - 1),obj_data);
    end loop;

    if v_flg_data = 'Y' and v_flg_secure = 'Y' then
      insert into ttemprpt(codempid       ,codapp           ,numseq           , -- pk
                           item1          ,
                           item4          ,item5            ,item6            , -- header
                           item7          ,item8            ,item9            , -- header
                           item41         ,item42           ,
                           item43         )
                    values(global_v_codempid,'HRPY92R2'       ,1          , -- pk
                           rpad(v_text_numtaxid, 13, ' ')  ,
                           v_codrevn        ,hcm_util.get_split_decimal(v_sum_amtinc,'I') ,hcm_util.get_split_decimal(v_sum_amttax,'I')     , -- header
                           v_img_path       ,v_h_desc_codempid  ,v_h_desc_position, -- header
                           hcm_util.get_split_decimal(v_sum_amtinc,'D') ,hcm_util.get_split_decimal(v_sum_amttax,'D'),
                           v_has_image);
      json_str_output := obj_rows.to_clob;
    elsif v_flg_data = 'Y' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxinc');
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end gen_detail;

  procedure check_process1 as
  begin
--    if p_month is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
--      return;
--    end if;
--    if p_year is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
--      return;
--    end if;
--    if p_codcomp is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
--      return;
--    end if;
--    if p_typeData is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typeData');
--      return;
--    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
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
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end check_process1;

  procedure get_process1(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_process1;
    if param_msg_error is null then
        gen_process1(json_str_output);
    end if;
    if param_msg_error is not null then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_process1;

  procedure gen_process1(json_str_output out clob) as
    -- tcompny
    v_numcotax         tcompny.numcotax%type;
    v_namcomt          tcompny.namcomt%type;
    v_buildingt        tcompny.buildingt%type;
    v_roomnot          tcompny.roomnot%type;
    v_floort           tcompny.floort%type;
    v_villaget         tcompny.villaget%type;
    v_addrnot          tcompny.addrnot%type;
    v_moot             tcompny.moot%type;
    v_soit             tcompny.soit%type;
    v_roadt            tcompny.roadt%type;
    v_codsubdist       tcompny.codsubdist%type;
    v_coddist          tcompny.coddist%type;
    v_codprovr         tcompny.codprovr%type;
    v_zipcode          tcompny.zipcode%type;
    v_numtele          tcompny.numtele%type;
    v_desc_codsubdist  varchar2(4000 char);
    v_desc_coddist     varchar2(4000 char);
    v_dec_codprovr     varchar2(4000 char);
    -- ttaxinc 1-5
    v_count            number := 1;
    v_typinc1          number;
    v_amtinc1          varchar2(100);
    v_amttax1          varchar2(100);
    v_amtinc1_deci     varchar2(100);
    v_amttax1_deci     varchar2(100);
    v_typinc2          number;
    v_amtinc2          varchar2(100);
    v_amttax2          varchar2(100);
    v_amtinc2_deci     varchar2(100);
    v_amttax2_deci     varchar2(100);
    v_typinc3          number;
    v_amtinc3          varchar2(100);
    v_amttax3          varchar2(100);
    v_amtinc3_deci     varchar2(100);
    v_amttax3_deci     varchar2(100);
    v_typinc4          number;
    v_amtinc4          varchar2(100);
    v_amttax4          varchar2(100);
    v_amtinc4_deci     varchar2(100);
    v_amttax4_deci     varchar2(100);
    v_typinc5          number;
    v_amtinc5          varchar2(100);
    v_amttax5          varchar2(100);
    v_amtinc5_deci     varchar2(100);
    v_amttax5_deci     varchar2(100);
    -- summary
    v_sum_typinc       number := 0;
    v_sum_amtinc       number := 0;
    v_sum_amttax       number := 0;
    v_sum_process      number := 0;
    -- page
    v_all_page         number := 0;
    v_current_page     number := 0;
    v_resultmod        number;
    v_resultdivide     number;
    -- signature
    v_img_path         varchar2(4000 char);
    v_h_desc_codempid  varchar2(4000 char);
    v_h_desc_position  varchar2(4000 char);
    -- json
    obj_data           json_object_t := json_object_t();
    v_has_image        varchar2(1)  := 'N';

    v_empcount1         number;
    v_empcount2         number;
    v_empcount3         number;
    v_empcount4         number;
    v_empcount5         number;
    v_sum_empcount      number;
    v_flg_data          varchar2(10) := 'N';
    v_flg_secure        varchar2(10) := 'N';
    v_chk_secur         varchar2(10) := 'N';
    cursor c_tcodrevn is
      select codcodec
        from tcodrevn where codcodec in ('1101','1201','1301','1401','1501')
    order by codcodec;

    cursor c2 is
          select typinc,sum(amtinc) amtinc ,sum(amttax) amttax, count(codempid) numrec
          from
          (
              select typinc,
                     nvl(sum(to_number(stddec(amtinc,codempid,global_v_chken))),0) amtinc,
                     nvl(sum(to_number(stddec(amttax,codempid,global_v_chken))),0) amttax,
                     codempid
                from ttaxinc
               where codcomp like p_codcomp || '%'
                 and dteyrepay  = p_year
                 and dtemthpay  = p_month
                 and typinc     = nvl(p_codrevn,typinc)
                 and typpayroll = nvl(p_typpayroll,typpayroll)
                 and (
                       ( v_chk_secur = 'N')
                       or
                       ( v_chk_secur = 'Y'
                         and numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                         and exists(select codcomp
                                      from tusrcom
                                     where coduser = global_v_coduser
                                       and ttaxinc.codcomp like codcomp || '%') )
                      )
              having ((p_typeData = '1'
                     and nvl(sum(to_number(stddec(amtinc,codempid,global_v_chken))),0) <> 0
                      or nvl(sum(to_number(stddec(amttax,codempid,global_v_chken))),0) <> 0))
                  or ((p_typeData = '2') and nvl(sum(to_number(stddec(amttax,codempid,global_v_chken))),0) <> 0)
            group by typinc,codempid
           )
        group by typinc
        order by typinc;

  begin
    -- clear old temp
    cleartemptable;
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    begin
      select numcotax  ,namcomt    ,buildingt    ,roomnot   ,
             floort      ,villaget   ,addrnot      ,moot      ,
             soit        ,roadt      ,codsubdist   ,coddist   ,
             codprovr    ,zipcode    ,numtele
        into v_numcotax, v_namcomt  ,v_buildingt  ,v_roomnot ,
             v_floort    ,v_villaget ,v_addrnot    ,v_moot    ,
             v_soit      ,v_roadt    ,v_codsubdist ,v_coddist ,
             v_codprovr  ,v_zipcode  ,v_numtele
        from tcompny
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
    exception when others then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;

    -- Check Exists Data --
    for r1 in c2 loop
      v_flg_data  := 'Y';
      exit;
    end loop;
    -- p_month p_year
    v_current_page  := 0;
    v_all_page      := 0;
    v_chk_secur     := 'Y';
    for r1 in c2 loop
      if r1.numrec > 0 then
        v_flg_secure  := 'Y';
        for r_tcodrevn in c_tcodrevn loop
          if r1.typinc = r_tcodrevn.codcodec then
            if r_tcodrevn.codcodec = '1101' then
              v_typinc1         := r1.typinc;
              v_amtinc1         := hcm_util.get_split_decimal(r1.amtinc,'I');
              v_amtinc1_deci    := hcm_util.get_split_decimal(r1.amtinc,'D');
              v_amttax1         := hcm_util.get_split_decimal(r1.amttax,'I');
              v_amttax1_deci    := hcm_util.get_split_decimal(r1.amttax,'D');
              v_empcount1       := r1.numrec;
            elsif r_tcodrevn.codcodec = '1201' then
              v_typinc2         := r1.typinc;
              v_amtinc2         := hcm_util.get_split_decimal(r1.amtinc,'I');
              v_amtinc2_deci    := hcm_util.get_split_decimal(r1.amtinc,'D');
              v_amttax2         := hcm_util.get_split_decimal(r1.amttax,'I');
              v_amttax2_deci    := hcm_util.get_split_decimal(r1.amttax,'D');
              v_empcount2       := r1.numrec;
            elsif r_tcodrevn.codcodec = '1301' then
              v_typinc3         := r1.typinc;
              v_amtinc3         := hcm_util.get_split_decimal(r1.amtinc,'I');
              v_amtinc3_deci    := hcm_util.get_split_decimal(r1.amtinc,'D');
              v_amttax3         := hcm_util.get_split_decimal(r1.amttax,'I');
              v_amttax3_deci    := hcm_util.get_split_decimal(r1.amttax,'D');
              v_empcount3       := r1.numrec;
            elsif r_tcodrevn.codcodec = '1401' then
              v_typinc4         := r1.typinc;
              v_amtinc4         := hcm_util.get_split_decimal(r1.amtinc,'I');
              v_amtinc4_deci    := hcm_util.get_split_decimal(r1.amtinc,'D');
              v_amttax4         := hcm_util.get_split_decimal(r1.amttax,'I');
              v_amttax4_deci    := hcm_util.get_split_decimal(r1.amttax,'D');
              v_empcount4       := r1.numrec;
            elsif r_tcodrevn.codcodec = '1501' then
              v_typinc5         := r1.typinc;
              v_amtinc5         := hcm_util.get_split_decimal(r1.amtinc,'I');
              v_amtinc5_deci    := hcm_util.get_split_decimal(r1.amtinc,'D');
              v_amttax5         := hcm_util.get_split_decimal(r1.amttax,'I');
              v_amttax5_deci    := hcm_util.get_split_decimal(r1.amttax,'D');
              v_empcount5       := r1.numrec;
            end if;

            v_resultmod := mod(r1.numrec,10);
            v_resultdivide := floor(r1.numrec/10);

            if v_resultdivide = 0 AND v_resultmod <= 6 then
                v_current_page := 1;
            elsif v_resultmod <= 6 then
                v_current_page := v_resultdivide + 1;
            else
                v_current_page := v_resultdivide + 2;
            end if;

            v_all_page := nvl(v_all_page,0) + nvl(v_current_page,0);
            v_sum_empcount := nvl(v_sum_empcount,0) + nvl(r1.numrec,0);
            v_sum_amtinc   := v_sum_amtinc + r1.amtinc;
            v_sum_amttax   := v_sum_amttax + r1.amttax;
            v_sum_process  := nvl(v_sum_process,0) + 1;
          end if;
        end loop;
      end if;
    end loop;
    -- signature
    v_img_path := get_tsetsign_name(hcm_util.get_codcomp_level(p_codcomp,1),'HRPY92R');

    v_desc_codsubdist := get_tsubdist_name(v_codsubdist, global_v_lang);
    v_desc_coddist    := get_tcoddist_name(v_coddist, global_v_lang);
    v_dec_codprovr    := get_tcodec_name('TCODPROV',v_codprovr, global_v_lang);

    if v_img_path is not null then
      v_has_image := 'Y';
    end if;
    v_h_desc_codempid := p_desc_codempid;
    v_h_desc_position := p_desc_position;
    -- insert to temp table
    if v_flg_data = 'Y' and v_flg_secure = 'Y' then
      insert into ttemprpt(codempid         ,codapp           ,numseq           ,
                           item1            ,item2            ,item3            ,
                           item4            ,item5            ,item6            ,
                           item7            ,item8            ,item9            ,
                           item10           ,item11           ,item12           ,
                           item13           ,item14           ,item15           ,
                           item16           ,item17           ,item18           ,
                           item19           ,item20           ,item21           ,
                           item22           ,item23           ,item24           ,
                           item25           ,item26           ,item27           ,
                           item28           ,item29           ,item30           ,
                           item31           ,item32           ,item33           ,
                           item34           ,item35           ,item36           ,
                           item37           ,item38           ,item39           ,item40   ,
                           item41           ,item42           ,item43           ,item44   ,
                           item45           ,item46           ,item47,
                           item48,
                           item49, item50,
                           item51, item52,
                           item53, item54
                           )
                    values(global_v_codempid,'HRPY92R1'       ,'1'              ,
                           rpad(v_numcotax, 13, ' ')     ,v_namcomt        ,v_buildingt      ,
                           v_roomnot        ,v_floort         ,v_villaget       ,
                           v_addrnot        ,v_moot           ,v_soit           ,
                           v_roadt          ,v_desc_codsubdist,v_desc_coddist   ,
                           v_dec_codprovr   ,v_zipcode        ,v_numtele        ,
                           p_month          ,p_year + 543,
                           v_all_page      ,
                           v_empcount1        ,v_amtinc1        ,v_amttax1        ,
                           v_empcount2        ,v_amtinc2        ,v_amttax2        ,
                           v_empcount3        ,v_amtinc3        ,v_amttax3        ,
                           v_empcount4        ,v_amtinc4        ,v_amttax4        ,
                           v_empcount5        ,v_amtinc5        ,v_amttax5        ,
                           v_img_path       ,v_h_desc_codempid,v_h_desc_position,
                           v_amtinc1_deci   ,v_amttax1_deci   ,v_amtinc2_deci   ,v_amttax2_deci   ,
                           v_amtinc3_deci   ,v_amttax3_deci   ,v_amtinc4_deci   ,v_amttax4_deci   ,
                           v_amtinc5_deci   ,v_amttax5_deci   ,v_has_image,
                           v_sum_empcount,
                           hcm_util.get_split_decimal(v_sum_amtinc,'I'), hcm_util.get_split_decimal(v_sum_amtinc,'D'),
                           hcm_util.get_split_decimal(v_sum_amttax,'I'), hcm_util.get_split_decimal(v_sum_amttax,'D'),
                           hcm_util.get_split_decimal(v_sum_amttax + 0,'I'), hcm_util.get_split_decimal(v_sum_amttax + 0,'D')
                           );
      -- json
      obj_data.put('coderror','200');
  --    obj_data.put('process',to_char(v_sum_process));
      obj_data.put('process',to_char(v_sum_empcount));
      obj_data.put('response',
      hcm_secur.get_response('200',get_error_msg_php('HR2710',global_v_lang),global_v_lang));
      json_str_output := obj_data.to_clob;
    elsif v_flg_data = 'Y' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxinc');
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_process1;

  procedure check_process2 as
  begin
--    if p_month is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
--      return;
--    end if;
--    if p_year is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
--      return;
--    end if;
--    if p_codcomp is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
--      return;
--    end if;
--    if p_typeData is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typeData');
--      return;
--    end if;
--    if p_codrevn is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codrevn');
--      return;
--    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
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
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end check_process2;

  procedure get_process2(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_process2;
    if param_msg_error is null then
        gen_process2(json_str_output);
    end if;
    if param_msg_error is not null then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_process2;

  procedure gen_process2(json_str_output out clob) as
    -- header
    v_numcotax      tcompny.numcotax%type;
    v_codrevn         number := 0;
    v_h_desc_codempid varchar2(4000 char);
    v_h_desc_position varchar2(4000 char);
    v_img_path        varchar2(4000 char);
    v_all_page        number := 0;
    v_now_page        number;

    -- body
    obj_data          json_object_t;
    obj_rows          json_object_t := json_object_t();
    obj_json          json_object_t := json_object_t();
    v_count           number := 0;
    v_count2          number := 0;
    v_sum_amtinc      number := 0;
    v_sum_amttax      number := 0;

    -- data
    v_codtitle        temploy1.codtitle%type;
    v_typpayyroll     ttaxinc.typpayroll%type;

    v_desc_codempid   varchar2(4000 char);
    v_title_prefix    varchar2(4000 char);
    v_desc_name       varchar2(4000 char);
    v_desc_surname    varchar2(4000 char);
    v_numoffid        temploy2.numoffid%type;
    v_adrreg          temploy2.adrrege%type;
    v_adrcont         temploy2.adrconte%type;
    v_codpostr        temploy2.codpostr%type;
    v_numtaxid        temploy3.numtaxid%type;
    v_dtepay          date;
    v_flgtax          temploy3.flgtax%type;
    v_flg_data        varchar2(10) := 'N';
    v_flg_secure      varchar2(10) := 'N';
    v_chk_secur       varchar2(10) := 'N';
    cursor c_tcodrevn is
      select codcodec
        from tcodrevn
    order by codcodec;
    cursor c1 is
      select codempid,
             nvl(sum(to_number(stddec(amtinc,codempid,global_v_chken))),0) amtinc,
             nvl(sum(to_number(stddec(amttax,codempid,global_v_chken))),0) amttax
        from ttaxinc
       where codcomp like p_codcomp || '%'
         and dteyrepay  = p_year
         and dtemthpay  = p_month
         and typinc     = nvl(p_codrevn,typinc)
         and typpayroll = nvl(p_typpayroll,typpayroll)
         and (
               ( v_chk_secur = 'N')
               or
               ( v_chk_secur = 'Y'
                 and numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                 and exists(select codcomp
                              from tusrcom
                             where coduser = global_v_coduser
                               and ttaxinc.codcomp like codcomp || '%') )
              )
      having ((p_typeData = '1'
             and nvl(sum(to_number(stddec(amtinc,codempid,global_v_chken))),0) <> 0
              or nvl(sum(to_number(stddec(amttax,codempid,global_v_chken))),0) <> 0))
          or ((p_typeData = '2') and nvl(sum(to_number(stddec(amttax,codempid,global_v_chken))),0) <> 0)
    group by codempid
    order by codempid;
  begin
    begin
      select numcotax
        into v_numcotax
        from tcompny
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;

    for r_tcodrevn in c_tcodrevn loop
      v_codrevn := v_codrevn + 1;
      if p_codrevn = r_tcodrevn.codcodec then
        exit;
      end if;
    end loop;

    for r1 in c1 loop
      v_flg_data  := 'Y';
      exit;
    end loop;
    v_chk_secur   := 'Y';

    for r1 in c1 loop
--      v_count  := v_count  + 1;
      v_flg_secure  := 'Y';
      if v_count2 = 9 then
        v_count2 := 1;
        v_now_page := v_now_page + 1; -- page
      end if;
      -- more detail
      v_desc_codempid := get_temploy_name(r1.codempid,global_v_lang);
      begin
        select codtitle,
               decode(global_v_lang,'101',namfirste
                                   ,'102',namfirstt
                                   ,'103',namfirst3
                                   ,'104',namfirst4
                                   ,'105',namfirst5
                                   ,namfirste),
               decode(global_v_lang,'101',namlaste
                                   ,'102',namlastt
                                   ,'103',namlast3
                                   ,'104',namlast4
                                   ,'105',namlast5
                                   ,namlaste)
          into v_codtitle,v_desc_name,v_desc_surname
          from temploy1
         where codempid = r1.codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      v_title_prefix  := get_tlistval_name('CODTITLE',v_codtitle,global_v_lang);
      begin
        select numoffid,
               decode(global_v_lang,'101',adrrege,
                                    '102',adrregt,
                                    '103',adrreg3,
                                    '104',adrreg4,
                                    '105',adrreg5,
                                    adrrege),
               decode(global_v_lang,'101',adrconte,
                                    '102',adrcontt,
                                    '103',adrcont3,
                                    '104',adrcont4,
                                    '105',adrcont5,
                                    adrconte),
               codpostr
          into v_numoffid ,v_adrreg,
               v_adrcont  ,v_codpostr
          from temploy2
         where codempid = r1.codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy2');
        return;
      end;
      begin
        select numtaxid,flgtax
          into v_numtaxid,v_flgtax
          from temploy3
         where codempid = r1.codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy3');
        return;
      end;
      if p_dtepay is not null then
        v_dtepay := p_dtepay;
      else
        begin
          select typpayroll
            into v_typpayyroll
            from ttaxinc
           where codcomp like p_codcomp || '%'
             and codempid = r1.codempid
             and dteyrepay = p_year
             and dtemthpay = p_month
             and numperiod = (select max(numperiod)
                                from ttaxinc
                               where codcomp like p_codcomp || '%'
                                 and codempid = r1.codempid
                                 and dteyrepay = p_year
                                 and dtemthpay = p_month
                                 and typinc    = p_codrevn)
             and typinc = p_codrevn;
        exception when no_data_found then
          v_typpayyroll := null;
        end;
        begin
          select dtepaymt
            into v_dtepay
            from tdtepay
           where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
             and typpayroll = v_typpayyroll
             and dteyrepay = p_year
             and dtemthpay = p_month
             and numperiod = (select max(numperiod)
                                from tdtepay
                               where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                                 and typpayroll = v_typpayyroll
                                 and dteyrepay  = p_year
                                 and dtemthpay  = p_month);
        exception when no_data_found then
          v_dtepay := null;
        end;
      end if;
      -- * header - v_numcotax     ,v_now_page       ,v_all_page       , -- header
      -- *          v_codrevn        ,v_sum_amtinc     ,v_sum_amttax     , -- header
      -- *          v_img_path       ,v_h_desc_codempid,v_h_desc_position  -- header
      -- * body   - v_count         ,v_count2          ,v_codempid        ,
      -- *          v_desc_codempid ,v_desc_name       ,v_desc_surname    ,
      -- *          v_title_prefix  ,v_numoffid        ,v_numtaxid        ,
      -- *          v_dtepay        ,r1.amtinc         ,r1.amttax         ,
      -- *          v_flgtax

      obj_data := json_object_t();
      obj_data.put('index1'      ,'00');
      obj_data.put('numcotax'  ,v_numcotax);
      obj_data.put('numcotax'    ,v_numcotax);
      obj_data.put('index2'      ,'0000');
      obj_data.put('numoffid'    ,v_numoffid);
      obj_data.put('numtaxid'    ,v_numtaxid);
      if v_numtaxid = v_numoffid then
        obj_data.put('numtaxid'  ,rpad('0',10,'0'));
      elsif length(v_numoffid) = 13 and length(v_numtaxid) > 10 then
        obj_data.put('numtaxid'  ,rpad('0',10,'0'));
      elsif length(v_numoffid) <> 13 and length(v_numtaxid) <= 10 then
        obj_data.put('numoffid'  ,rpad('0',13,'0'));
      elsif length(v_numoffid) <> 13 and length(v_numtaxid) > 10 then
        obj_data.put('numoffid'  ,substr(v_numtaxid,1,13));
        obj_data.put('numtaxid'  ,rpad('0',10,'0'));
      end if;
      obj_data.put('title_prefix',v_title_prefix);
      obj_data.put('desc_name'   ,v_desc_name);
      obj_data.put('desc_surname',v_desc_surname);
      obj_data.put('adrreg'      ,v_adrreg);
      obj_data.put('adrcont'     ,v_adrcont);
      obj_data.put('codpostr'    ,v_codpostr);
      obj_data.put('month'       ,to_char(p_month));
      obj_data.put('year'        ,to_char(p_year + 543));
      obj_data.put('codrevn'     ,v_codrevn);
      obj_data.put('dtepay'      ,to_char(v_dtepay,'ddmm') || to_char(to_number(to_char(v_dtepay,'yyyy')) + 543));
      obj_data.put('index3'      ,'0');
      obj_data.put('amtinc'      ,to_char(r1.amtinc,'fm9999999999990.00'));
      obj_data.put('amttax'      ,to_char(r1.amttax,'fm9999999999990.00'));
      obj_data.put('flgtax'      ,v_flgtax);
      obj_rows.put(to_char(v_count),obj_data);
      v_count := v_count + 1;
    end loop;
    if v_flg_data = 'Y' and v_flg_secure = 'Y' then
      obj_json.put('coderror','200');
      obj_json.put('process',to_char(v_count));
      obj_json.put('rows',obj_rows);
      obj_json.put('filename','HRPY92R_' || global_v_coduser || '.txt');
      obj_json.put('response',hcm_secur.get_response('200',get_error_msg_php('HR2715',global_v_lang),global_v_lang));
      json_str_output := obj_json.to_clob;
    elsif v_flg_data = 'Y' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxinc');
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_process2;

  procedure clear_temp(json_str_input in clob,json_str_output out clob) as
    obj_rows  json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      cleartemptable;
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
    obj_rows := json_object_t();
    obj_rows.put('coderror','200');
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end hrpy92r;

/
